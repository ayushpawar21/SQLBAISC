--[Stocky HotFix Version]=425
DELETE FROM Versioncontrol WHERE Hotfixid='425'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('425','3.1.0.3','D','2015-08-21','2015-08-21','2015-08-21',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
/*
    CR RELEASE DETAILS :    
	1. Auto Backup Changes
*/
DELETE FROM Autobackupconfiguration WHERE MODULEID='AUTOBACKUP15'
INSERT INTO Autobackupconfiguration(ModuleId,ModuleName,[Description],[Status],Condition,ConfigValue,BackupDate,SeqNo) 
SELECT 'AUTOBACKUP15','AutomaticBackup','Take Backup in Removeable Disk',1,'',0.00,GETDATE(),15
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnKitProductTaxGroupId')
DROP FUNCTION Fn_ReturnKitProductTaxGroupId
GO
/*
--SELECT * FROM Fn_ReturnKitProductTaxGroupId()
SELECT KITPRDID,MAX(TAXPERC) TAXPERC FROM Fn_ReturnKitProductTaxGroupId() GROUP BY KITPRDID
*/
CREATE FUNCTION Fn_ReturnKitProductTaxGroupId()
RETURNS @KITMAXPRODUCTTAX TABLE
(
	KITPRDID	INT,
	TAXGROUPID	INT,
	TAXPERC		NUMERIC(18,2)
)
AS
/**************************************************************************************************
* FUNCTION	: Fn_ReturnKitProductTaxGroupId
* PURPOSE	: TO RETURN MAX TAXPERC GROUP ID FOR KIT PRODUCT
* CREATED	: PRAVEENRAJ BHASKARAN 22/07/2015
****************************************************************************************************/
BEGIN
	DECLARE @KITPRDID TABLE
	(
		KITPRDID	INT
	)

	DECLARE @KITPRODUCT TABLE
	(
		KITPRDID	INT,
		TAXGROUPID	INT
	)

	DECLARE @KITPRD INT
	INSERT INTO @KITPRDID
	SELECT DISTINCT KITPRDID FROM KitProduct(NOLOCK)
		
		DECLARE CUR_KIT CURSOR FOR SELECT KITPRDID FROM @KITPRDID
		OPEN CUR_KIT
		FETCH NEXT FROM CUR_KIT INTO @KITPRD
		WHILE @@FETCH_STATUS=0
		BEGIN
				INSERT INTO @KITPRODUCT(KITPRDID,TAXGROUPID)
				SELECT DISTINCT K.KitPrdid,PB.TaxGroupId 
				FROM KitProduct K 
				INNER JOIN KITPRODUCTBATCH KB ON K.PRDID=KB.PrdId
				INNER JOIN PRODUCTBATCH PB ON PB.PrdId=K.PrdId AND PB.PrdBatId=CASE KB.PrdBatId WHEN 0 THEN PB.PrdBatId ELSE KB.PrdBatId END
				INNER JOIN PRODUCT P ON P.PRDID=K.PrdId AND P.PrdId=KB.PrdId
				WHERE K.KitPrdid=@KITPRD
				
		FETCH NEXT FROM CUR_KIT INTO @KITPRD
		END
		CLOSE CUR_KIT
		DEALLOCATE CUR_KIT

		IF EXISTS (SELECT * FROM @KITPRODUCT)
		BEGIN
				DECLARE @KITTAXPRDID INT
				DECLARE @KITTAXGROUPID INT
				DECLARE @RTRGRP INT
				
				SELECT @RTRGRP=MAX(TAXGROUPID) FROM  TAXGROUPSETTING WHERE TaxGroup=1
				
				DECLARE CUR_KITTAX CURSOR FOR SELECT KITPRDID,TAXGROUPID FROM @KITPRODUCT
				OPEN CUR_KITTAX
				FETCH NEXT FROM CUR_KITTAX INTO @KITTAXPRDID,@KITTAXGROUPID
				WHILE @@FETCH_STATUS=0
				BEGIN
						--INSERT INTO @KITMAXPRODUCTTAX(KITPRDID,TAXGROUPID,TAXPERC)
					
					INSERT INTO @KITMAXPRODUCTTAX(KITPRDID,TAXGROUPID,TAXPERC)
					SELECT DISTINCT @KITTAXPRDID,@KITTAXGROUPID,MAX(A.ColVal) TAXPERC FROM TAXSETTINGDETAIL A 
					INNER JOIN  (SELECT MAX(TAXSEQID) AS TAXSEQID FROM TAXSETTINGMASTER WHERE PrdId=@KITTAXGROUPID AND RTRID=@RTRGRP) B ON A.TAXSEQID=B.TAXSEQID
					WHERE A.ColId=0
					GROUP BY A.TaxSeqId
				FETCH NEXT FROM CUR_KITTAX INTO @KITTAXPRDID,@KITTAXGROUPID
				END
				CLOSE CUR_KITTAX
				DEALLOCATE CUR_KITTAX
		END
RETURN
END
GO
IF NOT EXISTS (SELECT B.name FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.ID WHERE A.name='KitProduct' AND B.name='SlabId')
BEGIN
	ALTER TABLE KitProduct ADD SlabId INT DEFAULT 0 WITH VALUES
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnKitItemMandatory')
DROP FUNCTION Fn_ReturnKitItemMandatory
GO
--SELECT * FROM Fn_ReturnKitItemMandatory(1,1)
CREATE FUNCTION Fn_ReturnKitItemMandatory (@PI_PRDID INT,@Pi_TranQty INT)
RETURNS @KITPRDUCT_DT TABLE
(
	PrdId		INT,
	PrdBatId	INT,
	Qty			INT,
	MANDATORY	INT,
	SLABID		INT,
	TRANQTY		INT,
	STOCKQTY	INT
)
AS
/*********************************
* PROCEDURE	: Fn_ReturnKitItemMandatory
* PURPOSE	: To Return Kit Products based on Mandatory,Non Mandatory
* CREATED	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 15/07/2015
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {Date} {Developer}  {Brief modification description}
*********************************/
BEGIN

	DECLARE @KITPRDUCT_MANDATORY TABLE
	(
		PrdId		INT,
		PrdBatId	INT,
		Qty			INT,
		MANDATORY	INT,
		SLABID		INT
	)

	DECLARE @SLABDETAILS TABLE 
	(
		SLNO INT IDENTITY(1,1),
		SLABID INT
	)

	DECLARE @KITPRDUCT_NONMANDATORY TABLE
	(
		PrdId		INT,
		PrdBatId	INT,
		Qty			INT,
		MANDATORY	INT,
		SlabId		INT
	)
	
	DECLARE @CNTSLABDT INT
	DECLARE @SLABID INT
	DECLARE @SLNO INT
	DECLARE @PrdId INT
	DECLARE @PrdBatId INT
	DECLARE @Qty INT
	
	INSERT INTO @KITPRDUCT_MANDATORY
	SELECT KP.PrdId,KPB.PrdBatId,KP.Qty,KP.MANDATORY,KP.SLABID
	FROM KitProduct KP (NOLOCK)
	INNER JOIN KitProductBatch KPB (NOLOCK) ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
	WHERE KP.KitPrdId = @PI_PRDID AND MANDATORY=1

	
	INSERT INTO @KITPRDUCT_NONMANDATORY(PrdId,PrdBatId,Qty,MANDATORY,SlabId)
	SELECT KP.PrdId,KPB.PrdBatId,KP.Qty,KP.MANDATORY,KP.SLABID
	FROM KitProduct KP (NOLOCK)
	INNER JOIN KitProductBatch KPB (NOLOCK) ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
	WHERE KP.KitPrdId = @PI_PRDID AND MANDATORY=0
	
	INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY,SLABID,TRANQTY,STOCKQTY)
	SELECT PrdId,PrdBatId,Qty,MANDATORY,SLABID,@Pi_TranQty,@Pi_TranQty*QTY FROM @KITPRDUCT_MANDATORY	
	
	INSERT INTO @SLABDETAILS(SLABID)
	SELECT DISTINCT SLABID FROM @KITPRDUCT_NONMANDATORY
	
	SET @SLNO=1
	SELECT @CNTSLABDT=COUNT(DISTINCT SLABID) FROM @KITPRDUCT_NONMANDATORY
	
	WHILE @CNTSLABDT>=@SLNO
	BEGIN
			SELECT @SLABID=SLABID FROM @SLABDETAILS WHERE SLNO=@SLNO	
			DECLARE CUR_KIT CURSOR FOR SELECT PrdId,PrdBatId,Qty FROM @KITPRDUCT_NONMANDATORY WHERE SLABID=@SLABID
			OPEN CUR_KIT
			FETCH NEXT FROM CUR_KIT INTO @PrdId,@PrdBatId,@Qty
			WHILE @@FETCH_STATUS=0
			BEGIN
				IF NOT EXISTS (SELECT * FROM @KITPRDUCT_DT WHERE MANDATORY=0 AND SlabId=@SLABID)
				BEGIN
					IF @PrdBatId=0
					BEGIN
						INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY,SLABID,TRANQTY,STOCKQTY)
						SELECT TOP 1 K.PrdId,K.PrdBatId,K.Qty,K.MANDATORY,K.SlabId,@Pi_TranQty,@Pi_TranQty*QTY FROM TEMP_KitProductBatch_Mandatory T
						INNER JOIN @KITPRDUCT_NONMANDATORY K ON K.PRDID=T.PRDID  WHERE K.PrdId=@PRDID AND K.SlabId=@SLABID AND T.Stock>=(@Qty*@Pi_TranQty)
					END
					ELSE
					BEGIN
						INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY,SLABID,TRANQTY,STOCKQTY)
						SELECT TOP 1 K.PrdId,K.PrdBatId,K.Qty,K.MANDATORY,K.SlabId,@Pi_TranQty,@Pi_TranQty*QTY FROM TEMP_KitProductBatch_Mandatory T
						INNER JOIN @KITPRDUCT_NONMANDATORY K ON K.PRDID=T.PRDID AND K.PrdBatId=T.PRDBATID  
						WHERE K.PrdId=@PRDID AND K.PRDBATID=@PrdBatId AND K.SlabId=@SLABID AND T.Stock>=(@Qty*@Pi_TranQty)
					END
				END
				--IF EXISTS (SELECT * FROM @KITPRDUCT_DT WHERE MANDATORY=0)
				--BEGIN
				--	CLOSE CUR_KIT
				--	DEALLOCATE CUR_KIT
				--	RETURN
				--END
			FETCH NEXT FROM CUR_KIT INTO @PrdId,@PrdBatId,@Qty
			END
			CLOSE CUR_KIT
			DEALLOCATE CUR_KIT
			
			IF EXISTS (SELECT * FROM KITPRODUCT (NOLOCK) WHERE MANDATORY=0 AND KitPrdid=@PI_PRDID AND SLABID=@SLABID)
			BEGIN
				IF NOT EXISTS (SELECT * FROM @KITPRDUCT_DT WHERE MANDATORY=0 AND SLABID=@SLABID)
				BEGIN
					INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY,SLABID,TRANQTY,STOCKQTY)
					SELECT TOP 1 KP.PrdId,KPB.PrdBatId,KP.Qty,KP.MANDATORY,KP.SLABID,@PI_TRANQTY,@Pi_TranQty*QTY
					FROM KitProduct KP (NOLOCK)
					INNER JOIN KitProductBatch KPB (NOLOCK) ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
					WHERE KP.KitPrdId = @PI_PRDID AND MANDATORY=0 AND KP.SLABID=@SLABID
				END
			END
			--IF EXISTS (SELECT * FROM KITPRODUCT (NOLOCK) WHERE MANDATORY=0 AND KitPrdid=@PI_PRDID)
			--BEGIN
			--	IF NOT EXISTS (SELECT * FROM @KITPRDUCT_DT WHERE MANDATORY=0)
			--	BEGIN
			--		INSERT INTO @KITPRDUCT_DT (PrdId,PrdBatId,Qty,MANDATORY)
			--		SELECT TOP 1 KP.PrdId,KPB.PrdBatId,KP.Qty,KP.MANDATORY
			--		FROM KitProduct KP (NOLOCK)
			--		INNER JOIN KitProductBatch KPB (NOLOCK) ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
			--		WHERE KP.KitPrdId = @PI_PRDID AND MANDATORY=0
			--	END
			--END	
		SET @SLNO=@SLNO+1
	END
	
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_UpdateKitItemDt')
DROP PROCEDURE Proc_UpdateKitItemDt
GO
/*
BEGIN TRANSACTION
EXEC Proc_UpdateKitItemDt 1,18,1,1,1,16798,1,'2015-08-19',1,2,8,'979',1,2,0
--select * from ProductBatchLocation where Prdid IN (895,1010)
--select * from StockLedger where Prdid IN (895,1010) and TransDate = '2013-01-18' 
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_UpdateKitItemDt]
(
	@Pi_ColId   		INT,
	@Pi_SLColId		INT,
	@Pi_Type  		INT,
	@Pi_SLType		INT,
	@Pi_PrdId  		INT,
	@Pi_PrdBatId  		INT,
	@Pi_LcnId  		INT,
	@Pi_TranDate  		DATETIME,
	@Pi_TranQty  		NUMERIC(38,0),
	@Pi_UsrId  		INT,
	@Pi_TransId		INT,
	@Pi_TransNo		nVARCHAR(50),
	@Pi_TransType		INT,
	@Pi_SlNo		INT,
	@Po_KsErrNo  		INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UpdateKitItemDt
* PURPOSE	: General SP for Updating Kit Item Stock
* CREATED	: Thrinath 
* CREATED DATE	: 28/08/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
	
*********************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @sSql AS VARCHAR(2500)
	DECLARE @ErrNo AS INT
	DECLARE @PrdId AS INT
	DECLARE @PrdBatId AS INT
	DECLARE @Qty AS INT
	DECLARE @TotalQty AS INT
	DECLARE @ExistQty AS INT
	DECLARE @FieldName AS VARCHAR(200)
	DECLARE @FieldName1 AS VARCHAR(200)
	DECLARE @ExistPrdId AS INT
	DECLARE @ExistPrdBatId AS INT
	DECLARE @PrdBatLcnStock AS INT
	SET @Po_KsErrNo=0
	DECLARE @SALID BIGINT
	
	SELECT @FieldName = CASE @Pi_ColId
		WHEN 1 THEN '(PrdBatLcnSih - PrdBatLcnResSih)'
		WHEN 2 THEN '(PrdBatLcnUih - PrdBatLcnResUih)'
		WHEN 3 THEN '(PrdBatLcnfre - PrdBatLcnResFre)' 
		WHEN 4 THEN '(PrdBatLcnSih - PrdBatLcnResSih)'
		WHEN 5 THEN '(PrdBatLcnUih - PrdBatLcnResUih)'
		WHEN 6 THEN '(PrdBatLcnfre - PrdBatLcnResFre)' END
		
   SELECT @FieldName1 = CASE @Pi_ColId
		WHEN 1 THEN 'PrdBatLcnResSih'
		WHEN 2 THEN 'PrdBatLcnResUih'
		WHEN 3 THEN 'PrdBatLcnResFre' 
		WHEN 4 THEN 'PrdBatLcnResSih'
		WHEN 5 THEN 'PrdBatLcnResUih'
		WHEN 6 THEN 'PrdBatLcnResFre' END				
	
	CREATE  TABLE #KitProduct(PrdId INT,PrdBatId INT,Qty NUMERIC(38,0))
	CREATE  TABLE #KitBatch(PrdId INT,PrdBatId INT,Stock NUMERIC(38,0))
	IF @Pi_TransType = 1  --For Taking In The Stock
	BEGIN
		SELECT @SALID=ISNULL(SALID,0) FROM ReturnHeader (NOLOCK) WHERE ReturnID=@Pi_TransNo
		IF @Pi_TransId=8
		BEGIN
			INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
			SELECT DISTINCT KP.PrdId,KPB.PrdBatId,KP.Qty 
			FROM KitProduct KP
			INNER JOIN KitProductBatch KPB
			ON KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId
			INNER JOIN KitProductTransDt T ON T.KitPrdId=KP.KitPrdid AND T.PRDID=KP.PrdId AND T.PrdId=KPB.PrdId
			WHERE KP.KitPrdId = @Pi_PrdId AND T.TransId=1 AND T.TransNo=@SALID
			ORDER BY KP.PrdId,KPB.PrdBatId
		END
		ELSE
		BEGIN
			INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
			SELECT KP.PrdId,KPB.PrdBatId,KP.Qty 
			FROM KitProduct KP,KitProductBatch KPB
			WHERE KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId AND 
			KP.KitPrdId = @Pi_PrdId 
			ORDER BY KP.PrdId,KPB.PrdBatId
		END
		SELECT PrdId,PrdBatId,Qty FROM #KitProduct
		
		DECLARE Cur_KitProduct CURSOR FOR 	
			SELECT PrdId,PrdBatId,Qty FROM #KitProduct
		
		OPEN Cur_KitProduct
			FETCH NEXT FROM Cur_KitProduct
			INTO @PrdId,@PrdBatId,@Qty
		WHILE @@FETCH_STATUS=0
		BEGIN
			DELETE FROM #KitBatch
			SET @TotalQty=@Qty*@Pi_TranQty		
			IF @PrdBatId=0
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT PrdId,PrdBatId,1 AS Qty FROM ProductBatch
				WHERE PrdId= @PrdId  AND PrdBatId IN (SELECT MIN(PrdBatId)
				FROM ProductBatch WHERE PrdId=@PrdId) ORDER BY PrdBatId
			END
			ELSE
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT PB.PrdId,PB.PrdBatId,1 FROM ProductBatch PB,KitProductBatch KPB
				WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB.PrdBatId AND 
				KPB.PrdBatId IN(SELECT MIN(KPB1.PrdBatId)FROM ProductBatch PB,KitProductBatch KPB1
				WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB1.PrdBatId) ORDER BY KPB.PrdBatId
			END
				
			SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
				ORDER BY PrdBatId
				
			DECLARE Cur_KitPrdBatch CURSOR FOR 	
				SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
				ORDER BY PrdBatId
			OPEN Cur_KitPrdBatch
			FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			WHILE @@FETCH_STATUS=0
			BEGIN
				DELETE FROM KitProductTransDt 
					WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
					PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
					SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
					AND TransNo = @Pi_TransNo 
				INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,PrdBatId,LcnId,
					SalTransQty,UnSalTransQty,OfferTransQty,KitQty,Availability,LastModBy,
					LastModDate,AuthId,AuthDate) VALUES
				(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,@ExistPrdBatId,@Pi_LcnId,
					CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
 					CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
					CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
					@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
					
				--SELECT * FROM KitProductTransDt
				
				EXEC Proc_UpdateProductBatchLocation @Pi_ColId,@Pi_Type,@ExistPrdId,@ExistPrdBatId,
					@Pi_LcnId,@Pi_TranDate,@TotalQty,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
				IF @ErrNo = 1
				BEGIN
					SET @Po_KsErrNo = 1
					CLOSE Cur_KitPrdBatch
					DEALLOCATE Cur_KitPrdBatch
					CLOSE Cur_KitProduct
					DEALLOCATE Cur_KitProduct
					
					RETURN 
				END
				EXEC Proc_UpdateStockLedger @Pi_SLColId,@Pi_SLType,@ExistPrdId,@ExistPrdBatId,
					@Pi_LcnId,@Pi_TranDate,@TotalQty,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
				IF @ErrNo = 1
				BEGIN
					SET @Po_KsErrNo = 1
					CLOSE Cur_KitPrdBatch
					DEALLOCATE Cur_KitPrdBatch
					CLOSE Cur_KitProduct
					DEALLOCATE Cur_KitProduct
					
					RETURN 
				END
				FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			END
			CLOSE Cur_KitPrdBatch
			DEALLOCATE Cur_KitPrdBatch		
			FETCH NEXT FROM Cur_KitProduct
			INTO @PrdId,@PrdBatId,@Qty
		
		END
		CLOSE Cur_KitProduct
		DEALLOCATE Cur_KitProduct
		SET @Po_KsErrNo = 0
		RETURN @Po_KsErrNo
	END
	ELSE	--For Taking Out the Stock
	BEGIN
		IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6 --Added By SathishKumar Veeramani 2013/01/09
		BEGIN
			EXEC Proc_GetKitItemMandatory @Pi_ColId,@Pi_SLColId,@Pi_Type,@Pi_SLType,@Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,
										  @Pi_TranQty,@Pi_UsrId,@Pi_TransId,@Pi_TransNo,@Pi_TransType,@Pi_SlNo
			INSERT INTO #KitProduct (PrdId,PrdBatId,Qty)
			SELECT DISTINCT PrdId,PrdBatId,Qty FROM Fn_ReturnKitItemMandatory(@Pi_PrdId,@Pi_TranQty)
			--SELECT KP.PrdId,KPB.PrdBatId,KP.Qty FROM KitProduct KP,
			--	KitProductBatch KPB WHERE KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId AND 
			--	KP.KitPrdId = @Pi_PrdId ORDER BY KP.PrdId,KPB.PrdBatId
		END
		ELSE
		BEGIN
			PRINT 'B'
--			--->Added By Nanda on 21/01/2010
--			DELETE FROM KitProductTransDt
--
--			INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
--			SELECT KP.PrdId,KPB.PrdBatId,KP.Qty 
--				FROM KitProduct KP,KitProductBatch KPB
--  				WHERE KP.KitPrdId=KPB.KitPrdId AND KP.PrdId=KPB.PrdId AND 
--				KP.KitPrdId = @Pi_PrdId 
--				ORDER BY KP.PrdId,KPB.PrdBatId
--
--			SELECT PrdId,PrdBatId,Qty FROM #KitProduct
--
--			DECLARE Cur_KitProductNew CURSOR FOR 	
--				SELECT PrdId,PrdBatId,Qty FROM #KitProduct
--			
--			OPEN Cur_KitProductNew
--				FETCH NEXT FROM Cur_KitProductNew
--				INTO @PrdId,@PrdBatId,@Qty
--
--			WHILE @@FETCH_STATUS=0
--			BEGIN
--				DELETE FROM #KitBatch
--
--				SET @TotalQty=@Qty*@Pi_TranQty		
--
--				IF @PrdBatId=0
--				BEGIN
--					INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
--					SELECT PrdId,PrdBatId,1 AS Qty FROM ProductBatch
--						WHERE PrdId= @PrdId  AND PrdBatId IN (SELECT Max(PrdBatId)
--						FROM ProductBatch WHERE PrdId=@PrdId) 
--				END
--				ELSE
--				BEGIN
--					INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
--						SELECT PB.PrdId,PB.PrdBatId,1 FROM ProductBatch PB,KitProductBatch KPB
--						WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB.PrdBatId AND 
--						KPB.PrdBatId IN(SELECT MAX(KPB1.PrdBatId)FROM ProductBatch PB,KitProductBatch KPB1
--						WHERE PB.PrdId=@PrdId AND PB.PrdBatId=KPB1.PrdBatId)
--				END	
--
--				SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
--					ORDER BY PrdBatId
--
--				DECLARE Cur_KitPrdBatchNew CURSOR FOR 	
--					SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
--					ORDER BY PrdBatId
--
--				OPEN Cur_KitPrdBatchNew
--				FETCH NEXT FROM Cur_KitPrdBatchNew
--					INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
--
--				WHILE @@FETCH_STATUS=0
--				BEGIN
--					DELETE FROM KitProductTransDt 
--					WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
--					PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
--					SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
--					AND TransNo = @Pi_TransNo 
--
--					INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,PrdBatId,LcnId,
--					SalTransQty,UnSalTransQty,OfferTransQty,KitQty,Availability,LastModBy,
--					LastModDate,AuthId,AuthDate) VALUES
--					(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,@ExistPrdBatId,@Pi_LcnId,
--					CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
--					CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
--					CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
--					@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
--
--					SELECT 'Nanda2'
--					SELECT * FROM KitProductTransDt
--
--					FETCH NEXT FROM Cur_KitPrdBatchNew
--					INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
--				END
--				CLOSE Cur_KitPrdBatchNew
--				DEALLOCATE Cur_KitPrdBatchNew		
--
--				FETCH NEXT FROM Cur_KitProductNew
--				INTO @PrdId,@PrdBatId,@Qty
--			
--			END
--			CLOSE Cur_KitProductNew
--			DEALLOCATE Cur_KitProductNew
--
--			DELETE FROM #KitProduct
--			--->Till Here
			INSERT INTO #KitProduct (PrdId ,PrdBatId,Qty)
			SELECT DISTINCT KP.PrdId,KP.PrdBatId,KitQty FROM KitProductTransDt KP
				WHERE KP.KitPrdId=@Pi_PrdId AND KP.KitPrdBatId=@Pi_PrdBatId AND 
				KP.SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
				AND TransNo = @Pi_TransNo ORDER BY KP.PrdId,KP.PrdBatId
		END
		--SELECT PrdId,PrdBatId,Qty FROM #KitProduct
		IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6
		BEGIN
			IF @Pi_ColId > 0 AND @Pi_SLColId > 0
			BEGIN
				DELETE FROM KitProductTransDt 
				WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
				--PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
				SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
				AND TransNo = @Pi_TransNo
			END
		END
			
		DECLARE Cur_KitProduct CURSOR FOR 	
		SELECT PrdId,PrdBatId,Qty FROM #KitProduct		
		OPEN Cur_KitProduct
		FETCH NEXT FROM Cur_KitProduct
		INTO @PrdId,@PrdBatId,@Qty
		WHILE @@FETCH_STATUS=0
		BEGIN
		   -- SELECT @PrdId,@PrdBatId,@Qty
			DELETE FROM #KitBatch
			SET @TotalQty=@Qty*@Pi_TranQty
			IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6 --Added By SathishKumar Veeramani 2013/01/10
			BEGIN
			    IF @Pi_SLType = 2 AND @Pi_ColId <> 0 AND @Pi_SLColId <> 0--Cash Bill
					BEGIN
					SELECT 'A'
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM('
						+CAST(@FieldName1 AS VARCHAR(50))+ ') FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId Having Sum('
						+CAST(@FieldName1 AS VARCHAR(50))+ ') >=' + CAST(@TotalQty AS VARCHAR(50))
					--PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,'
						+CAST(@FieldName1 AS VARCHAR(50))+' FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					--PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_ColId = 4 AND @Pi_SLColId = 0 AND @Pi_SLType = 2
				BEGIN
				    SELECT 'B'
				    	SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnResSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						HAVING SUM(PrdBatLcnResSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					--PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,
						(PrdBatLcnResSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId AND PrdBatLcnResSih > 0'
					--PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_SLType = 2 AND @Pi_ColId <> 0 AND @Pi_SLColId = 0 AND @Pi_ColId <> 4--Delivery Bill
					BEGIN
					SELECT 'C'
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						Having SUM(PrdBatLcnSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					--PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,(PrdBatLcnSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId'
					--PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_ColId = 0 AND @Pi_SLType = 2 --Cancel Bill
				BEGIN
				SELECT 'D'
				    	SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM(PrdBatLcnSih - PrdBatLcnResSih) 
						FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId 
						HAVING SUM(PrdBatLcnSih - PrdBatLcnResSih)>=' + CAST(@TotalQty AS VARCHAR(50))
					--PRINT @sSql
					EXEC(@sSql)
					IF NOT EXISTS(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,
						(PrdBatLcnSih - PrdBatLcnResSih)FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					--PRINT @sSql
					EXEC(@sSql)	
				END
				ELSE IF @Pi_SLType <> 2 --Credit Bill
				BEGIN
				SELECT 'E'
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT 0 as PrdId,0 as PrdBatId,SUM('
						+CAST(@FieldName AS VARCHAR(50))+ ') FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId Having Sum('
						+CAST(@FieldName AS VARCHAR(50))+ ') >=' + CAST(@TotalQty AS VARCHAR(50))
					--PRINT @sSql
					EXEC(@sSql)
					IF NOT Exists(SELECT * FROM #KitBatch)
					BEGIN
						SET @Po_KsErrNo = 1
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
					
					DELETE FROM #KitBatch
					SET @sSql='INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
						SELECT DISTINCT ' + CAST(@PrdId AS VARCHAR(10)) + ',PBL.PrdBatId,'
						+CAST(@FieldName AS VARCHAR(50))+' FROM ProductBatchLocation PBL,KitProductBatch KPB
						WHERE PBL.PrdId='+CAST(@PrdId AS VARCHAR(10))+' AND PBL.PrdBatId= (CASE ' + 
						CAST(@PrdBatId AS VARCHAR(10))+ ' WHEN 0 THEN PBL.PrdBatId ELSE KPB.PrdBatId END) AND 
						PBL.LcnId='+CAST(@Pi_LcnId AS VARCHAR(10)) + ' AND KitPrdId= ' +
						CAST(@Pi_PrdId AS VARCHAR(50)) + ' AND PBL.PrdId = KPB.PrdId '
					--PRINT @sSql
					EXEC(@sSql)				
				END---------------------------------Till Here 2013/01/10
			END
			ELSE
			BEGIN
				INSERT INTO #KitBatch (PrdId,PrdBatId,Stock)
				SELECT DISTINCT KP.PrdId,KP.PrdBatId,
					CASE @Pi_ColId 	WHEN 1 THEN SalTransQty
							WHEN 2 THEN UnSalTransQty
							WHEN 3 THEN OfferTransQty
							WHEN 4 THEN SalTransQty
							WHEN 5 THEN UnSalTransQty
							WHEN 6 THEN OfferTransQty 
							WHEN 0 THEN 
								CASE @Pi_SLColId WHEN 7 THEN SalTransQty
									WHEN 9 THEN OfferTransQty END
							END
					FROM KitProductTransDt KP
					WHERE KP.KitPrdId=@Pi_PrdId AND KP.KitPrdBatId=@Pi_PrdBatId AND 
						KP.PrdId=@PrdId AND KP.PrdBatId=@PrdBatId AND 
						KP.SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
						AND TransNo = @Pi_TransNo 
					ORDER BY KP.PrdId,KP.PrdBatId
			END
			
			--SELECT 'Botree',PrdId,PrdBatId,Stock FROM #KitBatch 
			--ORDER BY PrdBatId
			
			 
								 
			DECLARE Cur_KitPrdBatch CURSOR FOR 	
				SELECT PrdId,PrdBatId,Stock FROM #KitBatch 
				ORDER BY PrdBatId
			OPEN Cur_KitPrdBatch
			FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			WHILE @@FETCH_STATUS=0
			BEGIN
					IF @TotalQty > 0
				BEGIN
				IF @Pi_Type=1 OR @Pi_Type=2 OR @Pi_TransId = 6 --Added by Sathishkumar Veeramani 2012/01/09
				BEGIN
					IF @PrdBatLcnStock>=@TotalQty
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							
							DELETE FROM KitProductTransDt 
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo 
		
							INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,
								PrdBatId,LcnId,SalTransQty,UnSalTransQty,OfferTransQty,KitQty,
								Availability,LastModBy,LastModDate,AuthId,AuthDate)
							VALUES(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								   @ExistPrdBatId,@Pi_LcnId,
								   CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
			 					   CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
								   CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
								   @Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
								
							 --   SELECT @Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								--@ExistPrdBatId,@Pi_LcnId,
								--CASE @Pi_ColId WHEN 1 THEN @TotalQty WHEN 4 THEN @TotalQty ELSE 0 END,
			 				--	CASE @Pi_ColId WHEN 2 THEN @TotalQty WHEN 5 THEN @TotalQty ELSE 0 END,
								--CASE @Pi_ColId WHEN 3 THEN @TotalQty WHEN 6 THEN @TotalQty ELSE 0 END,
								--@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate
								--Select 'Software',* from KitProductTransDt
						END
						SET @PrdBatLcnStock = @TotalQty
						SET @TotalQty = 0
					END
					ELSE
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							
							DELETE FROM KitProductTransDt 
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@ExistPrdId AND PrdBatId=@ExistPrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo 
		
							INSERT INTO KitProductTransDt(TransId,TransNo,KitPrdId,KitPrdBatId,SlNo,PrdId,
								PrdBatId,LcnId,SalTransQty,UnSalTransQty,OfferTransQty,KitQty,
								Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES
							(@Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
								@ExistPrdBatId,@Pi_LcnId,
								CASE @Pi_ColId WHEN 1 THEN @PrdBatLcnStock WHEN 4 THEN @PrdBatLcnStock ELSE 0 END,
			 					CASE @Pi_ColId WHEN 2 THEN @PrdBatLcnStock WHEN 5 THEN @PrdBatLcnStock ELSE 0 END,
								CASE @Pi_ColId WHEN 3 THEN @PrdBatLcnStock WHEN 6 THEN @PrdBatLcnStock ELSE 0 END,
								@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate)
							--select @Pi_TransId,@Pi_TransNo,@Pi_PrdId,@Pi_PrdBatId,@Pi_SlNo,@ExistPrdId,
							--	@ExistPrdBatId,@Pi_LcnId,
							--	CASE @Pi_ColId WHEN 1 THEN @PrdBatLcnStock WHEN 4 THEN @PrdBatLcnStock ELSE 0 END,
			 			--		CASE @Pi_ColId WHEN 2 THEN @PrdBatLcnStock WHEN 5 THEN @PrdBatLcnStock ELSE 0 END,
							--	CASE @Pi_ColId WHEN 3 THEN @PrdBatLcnStock WHEN 6 THEN @PrdBatLcnStock ELSE 0 END,
							--	@Qty,1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate
						END
						SET @TotalQty = @TotalQty - @PrdBatLcnStock
					END
				END
				ELSE
				BEGIN
					IF @PrdBatLcnStock>=@TotalQty
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							
							UPDATE KitProductTransDt SET 
								SalTransQty = SalTransQty - (CASE @Pi_ColId WHEN 1 THEN @TotalQty 
									WHEN 4 THEN @TotalQty ELSE 0 END),
								UnSalTransQty = UnSalTransQty - (CASE @Pi_ColId WHEN 2 THEN @TotalQty 
									WHEN 5 THEN @TotalQty ELSE 0 END),
								OfferTransQty = OfferTransQty - (CASE @Pi_ColId WHEN 3 THEN @TotalQty 
									WHEN 6 THEN @TotalQty ELSE 0 END)
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@PrdId AND PrdBatId=@PrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo
						END
						SET @PrdBatLcnStock = @TotalQty
						SET @TotalQty = 0
					END
					ELSE
					BEGIN
						IF @Pi_ColId > 0 AND @Pi_SLColId > 0
						BEGIN
							
							UPDATE KitProductTransDt SET 
								SalTransQty = SalTransQty - (CASE @Pi_ColId WHEN 1 THEN @PrdBatLcnStock 
									WHEN 4 THEN @PrdBatLcnStock ELSE 0 END),
								UnSalTransQty = UnSalTransQty - (CASE @Pi_ColId WHEN 2 THEN @PrdBatLcnStock 
									WHEN 5 THEN @PrdBatLcnStock ELSE 0 END),
								OfferTransQty = OfferTransQty - (CASE @Pi_ColId WHEN 3 THEN @PrdBatLcnStock 
									WHEN 6 THEN @PrdBatLcnStock ELSE 0 END)
							WHERE KitPrdId=@Pi_PrdId AND KitPrdBatId=@Pi_PrdBatId AND 
								PrdId=@PrdId AND PrdBatId=@PrdBatId AND 
								SlNo = @Pi_SlNo AND LcnId = @Pi_LcnId AND TransId = @Pi_TransId
								AND TransNo = @Pi_TransNo
						END
						SET @TotalQty = @TotalQty - @PrdBatLcnStock
					END
				END
				
				IF @Pi_ColId > 0 
				BEGIN
					EXEC Proc_UpdateProductBatchLocation @Pi_ColId,@Pi_Type,@ExistPrdId,@ExistPrdBatId,
						@Pi_LcnId,@Pi_TranDate,@PrdBatLcnStock,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
		
					IF @ErrNo = 1
					BEGIN
						SET @Po_KsErrNo = 1
		
						CLOSE Cur_KitPrdBatch
						DEALLOCATE Cur_KitPrdBatch
		
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
				END
				IF @Pi_SLColId > 0
				BEGIN
					EXEC Proc_UpdateStockLedger @Pi_SLColId,@Pi_SLType,@ExistPrdId,@ExistPrdBatId,
						@Pi_LcnId,@Pi_TranDate,@PrdBatLcnStock,@Pi_UsrId,@Pi_ErrNo=@ErrNo OUTPUT
		
					IF @ErrNo = 1
					BEGIN
						SET @Po_KsErrNo = 1
		
						CLOSE Cur_KitPrdBatch
						DEALLOCATE Cur_KitPrdBatch
		
						CLOSE Cur_KitProduct
						DEALLOCATE Cur_KitProduct
						
						RETURN 
					END
				END
				END
				FETCH NEXT FROM Cur_KitPrdBatch
				INTO @ExistPrdId,@ExistPrdBatId,@PrdBatLcnStock
			END
			CLOSE Cur_KitPrdBatch
			DEALLOCATE Cur_KitPrdBatch		
		
			FETCH NEXT FROM Cur_KitProduct
			INTO @PrdId,@PrdBatId,@Qty
		END
		IF @TotalQty > 0
		BEGIN 
			SET @Po_KsErrNo = 1
			CLOSE Cur_KitProduct
			DEALLOCATE Cur_KitProduct
					
			RETURN 
		END
		CLOSE Cur_KitProduct
		DEALLOCATE Cur_KitProduct
		
		DELETE FROM KitProductTransDt WHERE (SalTransQty + UnSalTransQty + OfferTransQty) = 0
		SET @Po_KsErrNo = 0
		RETURN @Po_KsErrNo
	END
	RETURN @Po_KsErrNo
END
GO
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id WHERE A.name='Cn2Cs_Prk_KitProducts' AND B.name='SlabID')
BEGIN
	ALTER TABLE Cn2Cs_Prk_KitProducts ADD SlabID INT DEFAULT 0 WITH VALUES
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ImportKitProduct')
DROP PROCEDURE Proc_ImportKitProduct
GO
CREATE PROCEDURE Proc_ImportKitProduct
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportKitProduct
* PURPOSE	: To Insert records from xml file in the Table Cn2Cs_Prk_KitProducts
* CREATED	: Sathishkumar Veeramani
* CREATED DATE	: 17/12/2012
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {Date} {Developer}  {Brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER 
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Cn2Cs_Prk_KitProducts([DistCode],[KitItemCode],[ProductCode],[ProductBatchCode],[Quantity],[DownloadFlag],[CreatedDate]
	,Mandatory,ValidFrom,ValidTill,SlabID)
	SELECT [DistCode],[KitItemCode],[ProductCode],[ProductBatchCode],[Quantity],[DownloadFlag],[CreatedDate],Mandatory,ValidFrom,ValidTill,SlabID
	FROM OPENXML (@hdoc,'/Root/Console2CS_KitItemMaster',1)
	WITH (
		[DistCode] 			NVARCHAR(50),
		[KitItemCode]		NVARCHAR(100),
		[ProductCode]		NVARCHAR(100),
		[ProductBatchCode]  NVARCHAR(50),
		[Quantity]          NUMERIC(18,0),
		[DownloadFlag]		NVARCHAR(10),
        [CreatedDate]		DATETIME,
        Mandatory			NVARCHAR(50),
        ValidFrom			DATETIME,
        ValidTill			DATETIME,
        SlabID				INT
	) XMLObj
	
	EXEC sp_xml_removedocument @hDoc 
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cn2Cs_KitProduct')
DROP PROCEDURE Proc_Cn2Cs_KitProduct
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_KitProduct 0
SELECT * FROM Cn2Cs_Prk_KitProducts
SELECT TaxGroupId,* FROM PRODUCT WHERE PRDTYPE=3
--UPDATE Cn2Cs_Prk_KitProducts SET DOWNLOADFLAG='D'
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_KitProduct]
(
	@Po_ErrNo INT OUTPUT
)
AS
/**************************************************************************************************
* PROCEDURE	: Proc_Cn2Cs_KitProduct
* PURPOSE	: To Insert and Update records Of KitProduct And KitProductBatch
* CREATED	: Sathishkumar Veeramani on 17/12/2012
****************************************************************************************************
* DATE         AUTHOR				DESCRIPTION
15/07/2015	PRAVEENRAJ BHASKARAN	Added Mandatory,ValidFrom,Valid Till For CCRSTPAR0092
**************************************************************************************************/
SET NOCOUNT ON
BEGIN
    SET @Po_ErrNo = 0
	DECLARE @DistCode AS  NVARCHAR(50)
	DECLARE @CmpId AS INT
	SELECT @DistCode=ISNULL(DistributorCode,'') FROM Distributor
	SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1
	DELETE FROM Cn2Cs_Prk_KitProducts WHERE DownloadFlag = 'Y'
	
--->Added By Sathishkumar Veeramani on 17/12/2012
	IF EXISTS (SELECT * FROM SysObjects WHERE Xtype = 'U' AND name = 'KitProductToAvoid')
	BEGIN
		DROP TABLE KitProductToAvoid	
	END
	CREATE TABLE KitProductToAvoid
	(
	    KitPrdCCode NVARCHAR(100),
		PrdCCode    NVARCHAR(100),
		PrdBatCode  NVARCHAR(100) 
	)
--Kit Product	
	DECLARE @KitProductCode TABLE
	(
	 KitPrdId NUMERIC(18,0),
	 KitPrdCCode NVARCHAR(100)
	)
--Kit Sub Product	
	DECLARE @KitSubProductCode TABLE
	(
	 PrdId NUMERIC(18,0),
	 PrdCCode NVARCHAR(100),
	 KitPrdCCode NVARCHAR(100),
	 Qty NUMERIC (18,0),
	 Mandatory TINYINT,
	 ValidFrom	DATETIME,
	 ValidTill DATETIME,
	 SLABID		INT
	)
--Existing Kit Product	
	DECLARE @ExistingKitProduct TABLE
	(
	 KitPrdId NUMERIC(18,0),
	 PrdId NUMERIC(18,0)
	)
--Till Here	
	IF EXISTS(SELECT DISTINCT KitItemCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE KitItemCode NOT IN 
	         (SELECT PrdCCode FROM Product WITH (NOLOCK) WHERE PrdType = 3)) 
	BEGIN
		INSERT INTO KitProductToAvoid(KitPrdCCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT KitItemCode,ProductCode,ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE KitItemCode NOT IN 
	    (SELECT PrdCCode FROM Product WITH (NOLOCK) WHERE PrdType = 3)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product','PrdCCode','KirProduct:'+KitItemCode+' Not Available in Product Master' FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
        WHERE KitItemCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK) WHERE PrdType = 3)
	END
	IF EXISTS(SELECT DISTINCT ProductCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)))
	BEGIN
		INSERT INTO KitProductToAvoid(KitPrdCCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT KitItemCode,ProductCode,ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
		WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK))
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 2,'Product','PrdCCode','Product:'+KitItemCode+' Not Available in Product Master' FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
		WHERE KitItemCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK))
	END
	IF EXISTS(SELECT DISTINCT ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE ProductBatchCode NOT IN 
	         (SELECT PrdBatCode FROM ProductBatch WITH (NOLOCK)) AND LTRIM(ProductBatchCode) <> 'All')
	BEGIN
		INSERT INTO KitProductToAvoid(KitPrdCCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT KitItemCode,ProductCode,ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
		WHERE ProductBatchCode NOT IN (SELECT PrdBatCode FROM ProductBatch WITH (NOLOCK)) AND LTRIM(ProductBatchCode) <> 'All'
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 3,'Product Batch','PrdBatcode','Product Batch'+ProductBatchCode+ 'Not Available in Product Batch' FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK)
		WHERE ProductBatchCode NOT IN (SELECT PrdBatCode FROM ProductBatch WITH (NOLOCK)) AND LTRIM(ProductBatchCode) <> 'All'
	END
	IF EXISTS (SELECT DISTINCT ProductCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) WHERE UPPER(LTRIM(RTRIM(MANDATORY))) NOT IN ('YES','NO'))
	BEGIN
		INSERT INTO KitProductToAvoid(KitPrdCCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT KitItemCode,ProductCode,ProductBatchCode FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) 
		WHERE UPPER(LTRIM(RTRIM(MANDATORY))) NOT IN ('YES','NO')
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 4,'KitProduct','MANDATORY','Mandatory Must be Yes/No For the Kit Item '+KitItemCode
		FROM Cn2Cs_Prk_KitProducts WITH (NOLOCK) 
		WHERE UPPER(LTRIM(RTRIM(MANDATORY))) NOT IN ('YES','NO')
	END
--Kit Product Id 
     INSERT INTO @KitProductCode (KitPrdId,KitPrdCCode) 
     SELECT DISTINCT A.PrdId AS KitPrdId,C.KitItemCode
     FROM Product A WITH (NOLOCK),Cn2Cs_Prk_KitProducts C WITH (NOLOCK) 
     WHERE A.PrdCCode = C.KitItemCode AND A.PrdType = 3 AND C.DownloadFlag = 'D' AND C.KitItemCode+'~'+C.ProductCode NOT IN
     (SELECT KitPrdCCode+'~'+PrdCCode FROM KitProductToAvoid)
--Kit Sub Prdoduct Id
    IF EXISTS (SELECT * FROM @KitProductCode)
    BEGIN
         INSERT INTO @KitSubProductCode (PrdId,PrdCCode,KitPrdCCode,Qty,Mandatory,ValidFrom,ValidTill,SLABID)
		 SELECT DISTINCT A.PrdId AS PrdId,C.ProductCode,C.KitItemCode,Quantity AS Qty,CASE UPPER(LTRIM(RTRIM(C.Mandatory))) WHEN 'YES' THEN 1 ELSE 0 END,
		 CONVERT(VARCHAR(10),C.ValidFrom,121),CONVERT(VARCHAR(10),C.ValidTill,121),C.SLABID
		 FROM Product A WITH (NOLOCK),Cn2Cs_Prk_KitProducts C WITH (NOLOCK) 
		 WHERE A.PrdCCode = C.ProductCode AND DownloadFlag = 'D' AND C.KitItemCode+'~'+C.ProductCode NOT IN
		 (SELECT KitPrdCCode+'~'+PrdCCode FROM KitProductToAvoid) --GROUP BY A.PrdId,C.ProductCode,C.KitItemCode
    END
--Existing KitProduct & KitSubProducts
    IF EXISTS (SELECT * FROM @KitSubProductCode)
    BEGIN
      INSERT INTO @ExistingKitProduct (KitPrdId,PrdId)
      SELECT KitPrdid,PrdId FROM KitProduct WITH (NOLOCK) WHERE CAST(KitPrdid AS NVARCHAR(10))+'~'+CAST(Prdid AS NVARCHAR(10)) IN
     (SELECT CAST(KitPrdid AS NVARCHAR(10))+'~'+CAST(Prdid AS NVARCHAR(10)) FROM @KitProductCode A,@KitSubProductCode B
      WHERE A.KitPrdCCode = B.KitPrdCCode)
    END        
 --KitProduct & KitSubProducts Not Exisits     
     INSERT INTO KitProduct (KitPrdid,PrdId,Qty,CmpId,Availability,LastModBy,LastModDate,AuthId,AuthDate,Mandatory,ValidFrom,ValidTill,SlabId)     
     SELECT DISTINCT A.KitPrdId AS KitPrdId,B.PrdId,SUM(B.Qty) AS Qty,@CmpId,1,1,CONVERT(NVARCHAr(10),GETDATE(),121),1,
     CONVERT(NVARCHAr(10),GETDATE(),121),B.Mandatory,B.ValidFrom,B.ValidTill,B.SLABID
     FROM @KitProductCode A,@KitSubProductCode B WHERE A.KitPrdCCode = B.KitPrdCCode AND CAST(A.KitPrdId AS NVARCHAR(10))+'~'+CAST(B.PrdId AS NVARCHAR(10)) 
     NOT IN (SELECT CAST(KitPrdId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10)) FROM @ExistingKitProduct)
     GROUP BY A.KitPrdId,B.PrdId,B.Mandatory,B.ValidFrom,B.ValidTill,B.SLABID
     
     INSERT INTO KitProductBatch (KitPrdId,PrdId,PrdBatId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
     SELECT DISTINCT A.KitPrdId AS KitPrdId,B.PrdId,0,1,1,CONVERT(NVARCHAr(10),GETDATE(),121),1,CONVERT(NVARCHAr(10),GETDATE(),121)
     FROM @KitProductCode A,@KitSubProductCode B WHERE A.KitPrdCCode = B.KitPrdCCode AND CAST(A.KitPrdId AS NVARCHAR(10))+'~'+CAST(B.PrdId AS NVARCHAR(10)) 
     NOT IN (SELECT CAST(KitPrdId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10)) FROM @ExistingKitProduct)
     GROUP BY A.KitPrdId,B.PrdId
 --KitProduct & KitSubProducts Exists    
     UPDATE A SET A.Qty = Z.Qty FROM KitProduct A INNER JOIN (
     SELECT C.KitPrdId,C.PrdId,SUM(Qty) AS Qty FROM @KitProductCode A,@KitSubProductCode B,@ExistingKitProduct C 
     WHERE A.KitPrdCCode = B.KitPrdCCode AND A.KitPrdId = C.KitPrdId AND B.PrdId = C.PrdId GROUP BY C.KitPrdId,C.PrdId ) Z ON 
     A.KitprdId = Z.KitPrdId AND A.Prdid = Z.PrdId        
 --DownloadFlag Updation
     SELECT KitPrdId,PrdCCode AS KitPrdCode INTO #KitProduct FROM KitProduct A WITH (NOLOCK),Product B WITH (NOLOCK) 
     WHERE A.KitPrdid = B.PrdId AND B.PrdType = 3
     SELECT KitPrdCode,PrdCCode INTO #DownloadKitProduct FROM #KitProduct A WITH (NOLOCK),KitProduct C WITH (NOLOCK),Product B WITH (NOLOCK)
     WHERE A.KitPrdid = C.KitPrdid AND C.PrdId = B.PrdId 
     
    UPDATE PB SET PB.TaxGroupId=X.TAXGROUPID
    FROM PRODUCT P 
	INNER JOIN 
		(SELECT A.KITPRDID,A.TAXGROUPID FROM Fn_ReturnKitProductTaxGroupId() A INNER JOIN
		(SELECT KITPRDID,MAX(TAXPERC) TAXPERC FROM Fn_ReturnKitProductTaxGroupId() GROUP BY KITPRDID) B ON A.KITPRDID=B.KITPRDID
		AND A.TAXPERC=B.TAXPERC) X ON X.KITPRDID=P.PrdId
	INNER JOIN #DownloadKitProduct D ON D.KitPrdCode=P.PrdCCode
	INNER JOIN ProductBatch PB ON P.PrdId=PB.PrdId AND PB.PrdId=X.KITPRDID
	
	UPDATE P SET P.TaxGroupId=X.TAXGROUPID
    FROM PRODUCT P 
	INNER JOIN 
		(SELECT A.KITPRDID,A.TAXGROUPID FROM Fn_ReturnKitProductTaxGroupId() A INNER JOIN
		(SELECT KITPRDID,MAX(TAXPERC) TAXPERC FROM Fn_ReturnKitProductTaxGroupId() GROUP BY KITPRDID) B ON A.KITPRDID=B.KITPRDID
		AND A.TAXPERC=B.TAXPERC) X ON X.KITPRDID=P.PrdId
	INNER JOIN #DownloadKitProduct D ON D.KitPrdCode=P.PrdCCode
	
    UPDATE Cn2Cs_Prk_KitProducts SET DownloadFlag = 'Y' WHERE KitItemCode+'~'+ProductCode
    IN (SELECT KitPrdCode+'~'+ PrdCCode FROM #DownloadKitProduct)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptBillTemplateFinal')
DROP PROCEDURE Proc_RptBillTemplateFinal
GO
--exec PROC_RptBillTemplateFinal 16,1,0,'Parle',0,0,1,'RptBt_View_Final1_BillTemplate'
CREATE PROCEDURE Proc_RptBillTemplateFinal
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT,
	@Pi_BTTblName   	NVARCHAR(50)
)
AS
/***************************************************************************************************
* PROCEDURE	: Proc_RptBillTemplateFinal
* PURPOSE	: General Procedure
* NOTES		: 	
* CREATED	:
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
* 01.10.2009		Panneer						Added Tax summary Report Part(UserId Condition)
* 10/07/2015		PRAVEENRAJ BHASKARAN	    Added Grammge For Parle
****************************************************************************************************/
SET NOCOUNT ON
BEGIN
	--Added By Murugan 04/09/2009
	DECLARE @FieldCount AS INT
	DECLARE @UomStatus AS INT	
	DECLARE @UOMCODE AS nVARCHAR(25)
	DECLARE @pUOMID as INT
	DECLARE @UomFieldList as nVARCHAR(3000)
	DECLARE @UomFields as nVARCHAR(3000)
	DECLARE @UomFields1 as nVARCHAR(3000)
	--END
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @sSql		AS 	nVarChar(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	Declare @Sub_Val 	AS	TINYINT
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @FromBillNo 	AS  	BIGINT
	DECLARE @TOBillNo   	AS  	BIGINT
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @vFieldName   	AS	nvarchar(255)
	DECLARE @vFieldType	AS	nvarchar(10)
	DECLARE @vFieldLength	as	nvarchar(10)
	DECLARE @FieldList	as      nvarchar(4000)
	DECLARE @FieldTypeList	as	varchar(8000)
	DECLARE @FieldTypeList2 as	varchar(8000)
	DECLARE @DeliveredBill 	AS	INT
	DECLARE @SSQL1 AS NVARCHAR(4000)
	DECLARE @FieldList1	as      nvarchar(4000)
	--For B&L Bill Print Configurtion
	SELECT @DeliveredBill=Status FROM  Configuration WHERE ModuleName='Discount & Tax Collection' AND ModuleId='DISTAXCOLL5'
	IF @DeliveredBill=1
	BEGIN		
		DELETE FROM RptBillToPrint WHERE [Bill Number] IN(
		SELECT SalInvNo FROM SalesInvoice WHERE DlvSts NOT IN(4,5))
	END
	--Till Here
	--Added By Murugan 04/09/2009
	--print @Pi_BTTblName
	SET @FieldCount=0
	SELECT @UomStatus=Isnull(Status,0) FROM configuration  WHERE ModuleName='General Configuration' and ModuleId='GENCONFIG22' and SeqNo=22
	--Till Here
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	DECLARE CurField CURSOR FOR
	select sc.name fieldname,st.name fieldtype,sc.length from syscolumns sc, systypes st
	where sc.id in (select id from sysobjects where name like @Pi_BTTblName )
	and sc.xtype = st.xtype
	and sc.xusertype = st.xusertype
	Set @FieldList = ''
	Set @FieldTypeList = ''
	OPEN CurField
	FETCH CurField INTO @vFieldName,@vFieldType,@vFieldLength
	WHILE @@Fetch_Status = 0
	BEGIN
		if len(@FieldTypeList) > 3060
		begin
			Set @FieldTypeList2 = @FieldTypeList
			Set @FieldTypeList = ''
		end
		--->Added By Nanda on 12/03/2010
		IF LEN(@FieldList)>3060
		BEGIN
			SET @FieldList1=@FieldList
			SET @FieldList=''
		END
		--->Till Here
		if @vFieldName = 'UsrId'
		begin
			Set @FieldList = @FieldList  + 'V.[' + @vFieldName + '] , '
		end
		else
		begin
			Set @FieldList = @FieldList  + '[' + @vFieldName + '] , '
		end
		if @vFieldType = 'nvarchar' or @vFieldType = 'varchar' or @vFieldType = 'char'
		begin
			Set @FieldTypeList = @FieldTypeList + '[' + @vFieldName + '] ' + @vFieldType + '(' + @vFieldLength + ')' + ','
		end
		else if @vFieldType = 'numeric'
		begin
		    SELECT 'A',@vFieldName
			Set @FieldTypeList = @FieldTypeList + '[' + @vFieldName + '] ' + @vFieldType + '(38,2)' + ','
		end
		else
		begin
			Set @FieldTypeList = @FieldTypeList + '[' + @vFieldName + '] ' + @vFieldType + ','
		end
		FETCH CurField INTO @vFieldName,@vFieldType,@vFieldLength
	END
	Set @FieldList = left(@FieldList,len(@FieldList)-1)
	Set @FieldTypeList = left(@FieldTypeList,len(@FieldTypeList)-1)
	CLOSE CurField
	DEALLOCATE CurField
	
	--Added by Murugan UomCoversion 04/09/2009
	IF @UomStatus=1
	BEGIN	
		TRUNCATE TABLE BillTemplateUomBased	
		SET @UomFieldList=''
		SET @UomFields=''
		SET @UomFields1=''
		SET @FieldCount= @FieldCount+1	
		DECLARE CUR_UOM CURSOR
		FOR SELECT UOMID,UOMCODE FROM UOMMASTER  Order BY UOMID
		OPEN CUR_UOM
		FETCH NEXT FROM CUR_UOM INTO @pUOMID,@UOMCODE
		WHILE @@FETCH_STATUS=0
		BEGIN
			SET @FieldCount= @FieldCount+1
			SET @UomFieldList=@UomFieldList+'['+@UOMCODE +'] INT,'
			SET @UomFields=@UomFields+'0 AS ['+@UOMCODE +'],'
			SET @UomFields1=@UomFields1+'['+@UOMCODE +'],'	
			INSERT INTO BillTemplateUomBased(ColId,UOMID,UomCode)
			VALUES (@FieldCount,@pUOMID,@UOMCODE)
	
		FETCH NEXT FROM CUR_UOM INTO @pUOMID,@UOMCODE
		END	
		CLOSE CUR_UOM
		DEALLOCATE CUR_UOM
		SET @UomFieldList= subString(@UomFieldList,1,Len(Ltrim(rtrim(@UomFieldList)))-1)
		SET @UomFields= subString(@UomFields,1,Len(Ltrim(rtrim(@UomFields)))-1)
		SET @UomFields1= subString(@UomFields1,1,Len(Ltrim(rtrim(@UomFields1)))-1)		
		
	END
	-----
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [RptBillTemplateFinal]
	IF @UomStatus=1
	BEGIN	
		EXEC('CREATE TABLE RptBillTemplateFinal
		(' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500),'+ @UomFieldList +')')
	END
	ELSE
	BEGIN
		EXEC('CREATE TABLE RptBillTemplateFinal
		(' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500))')
	END
	SET @TblName = 'RptBillTemplateFinal'
	SET @TblStruct = @FieldTypeList2 + @FieldTypeList
	SET @TblFields = @FieldTypeList2 + @FieldTypeList
	IF @Pi_GetFromSnap = 1
	BEGIN
		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
		SET @DBNAME =   @DBNAME
	END
	ELSE
	BEGIN
		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo =3
		SET @DBNAME = @PI_DBNAME + @DBNAME
	END
	--Nanda01
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		DELETE FROM RptBillTemplateFinal Where UsrId = @Pi_UsrId
		IF @UomStatus=1
		BEGIN
			EXEC ('INSERT INTO RptBillTemplateFinal (' + @FieldList1+@FieldList + ','+ @UomFields1 + ')' +
			'Select  DISTINCT' + @FieldList1+@FieldList +','+ @UomFields+'  from ' + @Pi_BTTblName + ' V,RptBillToPrint T Where V.[Sales Invoice Number] = T.[Bill Number]')
		END
		ELSE
		BEGIN
			--SELECT 'Nanda002'	
			Exec ('INSERT INTO RptBillTemplateFinal (' +@FieldList1+ @FieldList + ')' +
			'Select  DISTINCT' + @FieldList1+ @FieldList + '  from ' + @Pi_BTTblName + ' V,RptBillToPrint T Where V.[Sales Invoice Number] = T.[Bill Number]')
		END
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO RptBillTemplateFinal ' +
				'(' + @TblFields + ')' +
			' SELECT DISTINCT' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName + ' Where UsrId = ' + @Pi_UsrId
		
			EXEC (@SSQL)
			PRINT @SSQL
			PRINT 'Retrived Data From Purged Table'
		END
		IF @Pi_SnapRequired = 1
		   BEGIN
			SELECT @NewSnapId = @Pi_SnapId
			EXEC Proc_SnapShot_Report @NewSnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
			IF @ErrNo = 0
			   BEGIN
				SET @sSql = 'INSERT INTO [' + @DBNAME + '].dbo.' + @TblName +
					'(SnapId,UserId,RptId,' + @TblFields + ')' +
					' SELECT ' + CAST(@NewSnapId AS VARCHAR(10)) +
					' ,' + CAST(@Pi_UsrId AS VARCHAR(10)) +
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM RptBillTemplateFinal'
		
				EXEC (@SSQL)
				PRINT 'Saved Data Into SnapShot Table'
			   END
		   END
	END
	--Nanda02
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		   BEGIN
			SET @SSQL = 'INSERT INTO RptBillTemplateFinal ' +
				'(' + @TblFields + ')' +
				' SELECT DISTINCT' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
				' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
				' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
				' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))
			EXEC (@SSQL)
			PRINT 'Retrived Data From Snap Shot Table'
		   END
		ELSE
		   BEGIN
			PRINT 'DataBase or Table not Found'
		   END
	END
	--Update SplitUp Tax Amount & Perc
	IF @UomStatus=1
	BEGIN	
		EXEC Proc_BillTemplateUOM @Pi_UsrId
	END
--	EXEC Proc_BillPrintingTax @Pi_UsrId
		
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 1')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 1]=BillPrintTaxTemp.[Tax1Perc]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount1')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount1]=BillPrintTaxTemp.[Tax1Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 2')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 2]=BillPrintTaxTemp.[Tax2Perc],[RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount2')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 3')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 3]=BillPrintTaxTemp.[Tax3Perc]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount3')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount3] =BillPrintTaxTemp.[Tax3Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 4')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 4]=BillPrintTaxTemp.[Tax4Perc],[RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount4')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 5')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 5]=BillPrintTaxTemp.[Tax5Perc],[RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount5')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	--Till Here
	--- Sl No added  ---
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Product SL No')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Product SL No]=SalesInvoiceProduct.[SlNo]
		FROM SalesInvoiceProduct,Product,ProductBatch WHERE [RptBillTemplateFinal].SalId=SalesInvoiceProduct.[SalId] AND [RptBillTemplateFinal].[Product Code]=Product.[PrdCCode]
		AND Product.Prdid=SalesInvoiceProduct.prdid
		And ProductBatch.Prdid=Product.Prdid and ProductBatch.PrdBatid=SalesInvoiceProduct.PrdBatId
		AND [RptBillTemplateFinal].[Batch Code] =ProductBatch.[PrdBatCode]'
		EXEC (@SSQL1)
	END	
	--- End Sl No
	--->Added By Nanda on 2011/02/24 for Henkel
	if not exists (Select Id,name from Syscolumns where name = 'Product Weight' and id in (Select id from 
		Sysobjects where name ='RptBillTemplateFinal'))
	begin
		ALTER TABLE [dbo].[RptBillTemplateFinal]
		ADD [Product Weight] NUMERIC(38,6) NULL DEFAULT 0 WITH VALUES
	END
	
	if not exists (Select Id,name from Syscolumns where name = 'Product UPC' and id in (Select id from 
		Sysobjects where name ='RptBillTemplateFinal'))
	begin
		ALTER TABLE [dbo].[RptBillTemplateFinal]
		ADD [Product UPC] NUMERIC(38,6) NULL DEFAULT 0 WITH VALUES
	END
	
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Product Weight')
	BEGIN
		SET @SSQL1='UPDATE Rpt SET Rpt.[Product Weight]=P.PrdWgt*(CASE P.PrdUnitId WHEN 2 THEN Rpt.[Base Qty]/1000 ELSE Rpt.[Base Qty] END)
		FROM Product P,RptBillTemplateFinal Rpt WHERE P.PrdCCode=Rpt.[Product Code] AND P.PrdUnitId IN (2,3)'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Product UPC')
	BEGIN
		SET @SSQL1='UPDATE Rpt SET Rpt.[Product UPC]=Rpt.[Base Qty]/P.ConversionFactor 
					FROM 
					(
						SELECT P.PrdId,P.PrdCCode,MAX(U.ConversionFactor)AS ConversionFactor FROM Product P,UOMGroup U
						WHERE P.UOMGroupId=U.UOMGroupId
						GROUP BY P.PrdId,P.PrdCCode
					) P,RptBillTemplateFinal Rpt WHERE P.PrdCCode=Rpt.[Product Code]'
		EXEC (@SSQL1)
	END
	--->Till Here
	--Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM RptBillTemplateFinal
	-- Till Here
	Delete From RptBillTemplate_Tax Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_Other Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_Replacement Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_CrDbAdjustment Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_MarketReturn Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_SampleIssue Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_Scheme Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_PrdUOMDetails Where UsrId = @Pi_UsrId
	---------------------------------TAX (SubReport)
--	Select @Sub_Val = TaxDt  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
--	If @Sub_Val = 1
--	Begin
        DELETE FROM RptBillTemplate_Tax WHERE UsrId = @Pi_UsrId    
		Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)
		SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId
		FROM SalesInvoiceProductTax SI , TaxConfiguration T,SalesInvoice S,RptBillToPrint B
		WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc HAVING SUM(TaxAmount) > 0 --Muthuvel
--	End
	------------------------------ Other
	--Select @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	--If @Sub_Val = 1
	--Begin
	    Delete From RptBillTemplate_Other Where UsrId = @Pi_UsrId
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)
		SELECT SI.SalId,S.SalInvNo,
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,
		Adjamt Amount,@Pi_UsrId
		FROM SalInvOtherAdj SI,PurSalAccConfig P,SalesInvoice S,RptBillToPrint B
		WHERE P.TransactionId = 2
		and SI.AccDescId = P.AccDescId
		and SI.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
	--End
	---------------------------------------Replacement
	--Select @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	--If @Sub_Val = 1
	--Begin
		Delete From RptBillTemplate_Replacement Where UsrId = @Pi_UsrId
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId
		FROM ReplacementHd H, ReplacementOut D, Product P, ProductBatch PB,SalesInvoice SI,RptBillToPrint B
		WHERE H.SalId <> 0
		and H.RepRefNo = D.RepRefNo
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = SI.SalId
		and SI.SalInvNo = B.[Bill Number]
	--End
	----------------------------------Credit Debit Adjus
	--Select @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	--If @Sub_Val = 1
	--Begin
	    Delete From RptBillTemplate_CrDbAdjustment Where UsrId = @Pi_UsrId
		Insert into RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,UsrId)
		Select A.SalId,S.SalInvNo,CrNoteNumber,A.CrAdjAmount,@Pi_UsrId
		from SalInvCrNoteAdj A,SalesInvoice S,RptBillToPrint B
		Where A.SalId = s.SalId
		and S.SalInvNo = B.[Bill Number]
		Union All
		Select A.SalId,S.SalInvNo,DbNoteNumber,A.DbAdjAmount,@Pi_UsrId
		from SalInvDbNoteAdj A,SalesInvoice S,RptBillToPrint B
		Where A.SalId = s.SalId
		and S.SalInvNo = B.[Bill Number]
	--End
	---------------------------------------Market Return
--	Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
--	If @Sub_Val = 1
--	Begin
		Delete from RptBillTemplate_MarketReturn where UsrId = @Pi_UsrId
		Insert into RptBillTemplate_MarketReturn(Type,SalId,SalInvNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Amount,UsrId)
		Select 'Market Return' Type ,H.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,BaseQty,PrdNetAmt,@Pi_UsrId
		From ReturnHeader H,ReturnProduct D,Product P,ProductBatch PB,SalesInvoice S,RptBillToPrint B
		Where returntype = 1
		and H.ReturnID = D.ReturnID
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
		Union ALL
		Select 'Market Return Free Product' Type,D.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,D.BaseQty,GrossAmount,@Pi_UsrId
		From ReturnPrdHdForScheme D,Product P,ProductBatch PB,SalesInvoice S,RptBillToPrint B,ReturnHeader H,ReturnProduct T
		WHERE returntype = 1 AND
		D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = T.SalId
		and H.ReturnID = T.ReturnID
		and S.SalInvNo = B.[Bill Number]
--	End
	------------------------------ SampleIssue
	Select @Sub_Val = SampleIssue FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_SampleIssue(SalId,SalInvNo,SchId,SchCode,SchName,PrdId,PrdCCode,CmpId,CmpCode,
		CmpName,PrdDCode,PrdShrtName,PrdBatId,PrdBatCode,UomId,UomCode,Qty,TobeReturned,DueDate,UsrId)
		SELECT A.SalId,C.SalInvNo,D.SchId,D.SchCode,D.SchDsc,B.PrdId,
		E.PrdCCode,E.CmpId,F.CmpCode,F.CmpName,E.PrdDCode,E.PrdShrtName,B.PrdBatId,G.PrdBatCode,
		B.IssueUomID,H.UomCode,B.IssueQty,CASE B.TobeReturned WHEN 0 THEN 'No' ELSE 'Yes' END AS TobeReturned,
		B.DueDate,@Pi_UsrId
		FROM SampleIssueHd A WITH (NOLOCK)
		INNER JOIN SampleIssueDt B WITH(NOLOCK)ON A.IssueId=B.IssueID
		INNER JOIN SalesInvoice C WITH(NOLOCK)ON A.SalId=C.SalId
		INNER JOIN SampleSchemeMaster D WITH(NOLOCK)ON B.SchId=D.SchId
		INNER JOIN Product E WITH (NOLOCK) ON B.PrdID=E.PrdId
		INNER JOIN Company F WITH (NOLOCK) ON E.CmpId=F.CmpId
		INNER JOIN ProductBatch G WITH (NOLOCK) ON E.PrdID=G.PrdID AND B.PrdBatId=G.PrdBatId
		INNER JOIN UOMMaster H WITH (NOLOCK) ON B.IssueUomID=H.UomID
		INNER JOIN RptBillToPrint I WITH (NOLOCK) ON C.SalInvNo=I.[Bill Number]
	End
	--->Added By Nanda on 10/03/2010
	------------------------------ Scheme
	Select @Sub_Val = [Scheme] FROM BillTemplateHD WHERE TempName=SUBSTRING(@Pi_BTTblName,18,LEN(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemeValue,SchemeCumulativePoints,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISL.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',
		0,'',0,0,SUM(SISL.DiscountPerAmount+SISL.FlatAmount),0,0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceSchemeLineWise SISL,SchemeMaster SM,RptBillToPrint RBT
		WHERE SISL.SchId=SM.SchId AND SI.SalId=SISL.SalId AND RBT.[Bill Number]=SI.SalInvNo
		GROUP BY SI.SalId,SI.SalInvNo,SISL.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc
		HAVING SUM(SISL.DiscountPerAmount+SISL.FlatAmount)>0
		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemeValue,SchemeCumulativePoints,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.FreePrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.FreePrdBatId,PB.PrdBatCode,SISFP.FreeQty,PBD.PrdBatDetailValue,SISFP.FreeQty*PBD.PrdBatDetailValue,0,0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceSchemeDtFreePrd SISFP,SchemeMaster SM,RptBillToPrint RBT,Product P,ProductBatch PB,
		ProductBatchDetails PBD,BatchCreation BC
		WHERE SISFP.SchId=SM.SchId AND SI.SalId=SISFP.SalId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.FreePrdId=P.PrdId AND SISFP.FreePrdBatId=PB.PrdBatId AND PB.PrdBatId=PBD.PrdBatId AND
		PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1
		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemeValue,SchemeCumulativePoints,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.GiftPrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.GiftPrdBatId,PB.PrdBatCode,SISFP.GiftQty,PBD.PrdBatDetailValue,SISFP.GiftQty*PBD.PrdBatDetailValue,0,0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceSchemeDtFreePrd SISFP,SchemeMaster SM,RptBillToPrint RBT,Product P,ProductBatch PB,
		ProductBatchDetails PBD,BatchCreation BC
		WHERE SISFP.SchId=SM.SchId AND SI.SalId=SISFP.SalId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.GiftPrdId=P.PrdId AND SISFP.GiftPrdBatId=PB.PrdBatId AND PB.PrdBatId=PBD.PrdBatId AND
		PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1
		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemeValue,SchemeCumulativePoints,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SIWD.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',
		0,'',0,0,SUM(SIWD.AdjAmt),0,0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceWindowDisplay SIWD,SchemeMaster SM,RptBillToPrint RBT
		WHERE SIWD.SchId=SM.SchId AND SI.SalId=SIWD.SalId AND RBT.[Bill Number]=SI.SalInvNo
		GROUP BY SI.SalId,SI.SalInvNo,SIWD.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc
		UPDATE RPT SET SalInvSchemeValue=A.SalInvSchemeValue
		FROM RptBillTemplate_Scheme RPT,(SELECT SalId,SUM(SchemeValueInAmt) AS SalInvSchemeValue FROM RptBillTemplate_Scheme GROUP BY SalId)A
		WHERE A.SAlId=RPT.SalId
		--->Added By Jay on 09/12/2010
		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemeValue,SchemeCumulativePoints,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.PrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.PrdBatId,PB.PrdBatCode,0,PBD.PrdBatDetailValue,0,SUM(Points),0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceSchemeDtPoints SISFP,SchemeMaster SM,
		RptBillToPrint RBT,Product P,ProductBatch PB,ProductBatchDetails PBD,BatchCreation BC
		WHERE SI.SalId=SISFP.SalId AND SISFP.SchId=SM.SchId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.PrdId=P.PrdId AND SISFP.PrdBatId=PB.PrdBatId AND RBT.UsrId=@Pi_UsrId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1 AND LEN(SISFP.ReDimRefId)=0		
		GROUP BY SI.SalId,SI.SalInvNo,SISFP.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.PrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,
		P.PrdName,SISFP.PrdBatId,PB.PrdBatCode,PBD.PrdBatDetailValue
		--->Till Here
		--->Added By Nanda on 22/12/2010 
		UPDATE R SET SchemeCumulativePoints=A.CumulativePoints
		FROM RptBillTemplate_Scheme R,SalesInvoice SI,
		(SELECT SI.RtrId,SISP.SchId,SUM(SISP.Points-SISP.ReturnPoints) AS CumulativePoints
		FROM SalesInvoiceSchemeDtPoints SISP
		INNER JOIN SalesInvoice SI ON SI.SalId=SISP.SalId AND SI.DlvSts<>3
		--INNER JOIN RptBillToPrint R ON R.[Bill Number]=SI.SalInvNo
		GROUP BY SI.RtrId,SISP.SchId) A
		WHERE R.SalId=SI.SalId AND A.RtrId=SI.RtrId
		--->Till Here		
	End
	--->Till Here	
	--->Added By Nanda on 14/03/2011
	------------------------------ Prd UOM Details
	--INSERT INTO RptBillTemplate_PrdUOMDetails(SalId,SalInvNo,TotPrdVolume,TotPrdKG,TotPrdLtrs,TotPrdUnits,
	--TotPrdDrums,TotPrdCartons,TotPrdBuckets,TotPrdPieces,TotPrdBags,UsrId)	
	--SELECT SalId,SalInvNo,SUM(TotPrdVolume) AS TotPrdVolume,SUM(TotPrdKG) AS TotPrdKG,SUM(TotPrdLtrs) AS TotPrdLtrs,SUM(TotPrdUnits) AS TotPrdUnits,
	--SUM(TotPrdDrums) AS TotPrdDrums,SUM(TotPrdCartons) AS TotPrdCartons,SUM(TotPrdBuckets) AS TotPrdBuckets,SUM(TotPrdPieces) AS TotPrdPieces,SUM(TotPrdBags) AS TotPrdBags,@Pi_UsrId
	--FROM
	--(
	--	SELECT DISTINCT SI.SalId,SI.SalInvNo,SIP.PrdId,SIP.BaseQty*dbo.Fn_ReturnProductVolumeInLtrs(SIP.PrdId) AS TotPrdVolume,
	--	SIP.BaseQty*P.PrdUpSKU * (CASE P.PrdUnitId WHEN 2 THEN .001 WHEN 3 THEN 1 ELSE 0 END) AS TotPrdKG,
	--	SIP.BaseQty * P.PrdWgt * (CASE P.PrdUnitId WHEN 4 THEN .001 WHEN 5 THEN 1 ELSE 0 END) AS TotPrdLtrs,
	--	SIP.BaseQty*(CASE P.PrdUnitId WHEN 1 THEN 0 ELSE 0 END) AS TotPrdUnits,
	--	(CASE ISNULL(UMP1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMP2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP2.UOM2Qty,0) END) AS TotPrdPieces,
	--	(CASE ISNULL(UMBU1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMBU2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU2.UOM2Qty,0) END) AS TotPrdBuckets,
	--	(CASE ISNULL(UMBA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMBA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA2.UOM2Qty,0) END) AS TotPrdBags,
	--	(CASE ISNULL(UMDR1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMDR2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR2.UOM2Qty,0) END) AS TotPrdDrums,
	--	(CASE ISNULL(UMCA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMCA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA2.UOM2Qty,0) END)+ 
	--	CEILING((CASE ISNULL(UMCN1.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN1.UOM1Qty,0) AS NUMERIC(38,6))/CAST(UGC1.ConvFact AS NUMERIC(38,6)) END))+
	--	CEILING((CASE ISNULL(UMCN2.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN2.UOM2Qty,0) AS NUMERIC(38,6))/CAST(UGC2.ConvFact AS NUMERIC(38,6)) END)) AS TotPrdCartons
	--	FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
	--	INNER JOIN RptBillToPrint Rpt ON SI.SalInvNo = Rpt.[Bill Number] AND Rpt.UsrId=@Pi_UsrId
	--	INNER JOIN Product P ON SIP.PrdID=P.PrdID
	--	INNER JOIN ProductBatch PB ON SIP.PrdBatID=PB.PrdBatID AND P.PrdID=PB.PrdId
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPP1 ON SI.SalId=SIPP1.SalId AND SIP.PrdID=SIPP1.PrdID AND SIP.PrdBatID=SIPP1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPP2 ON SI.SalId=SIPP2.SalId AND SIP.PrdID=SIPP2.PrdID AND SIP.PrdBatID=SIPP2.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPBU1 ON SI.SalId=SIPBU1.SalId AND SIP.PrdID=SIPBU1.PrdID AND SIP.PrdBatID=SIPBU1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPBU2 ON SI.SalId=SIPBU2.SalId AND SIP.PrdID=SIPBU2.PrdID AND SIP.PrdBatID=SIPBU2.PrdBatID		
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPBA1 ON SI.SalId=SIPBA1.SalId AND SIP.PrdID=SIPBA1.PrdID AND SIP.PrdBatID=SIPBA1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPBA2 ON SI.SalId=SIPBA2.SalId AND SIP.PrdID=SIPBA2.PrdID AND SIP.PrdBatID=SIPBA2.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPDR1 ON SI.SalId=SIPDR1.SalId AND SIP.PrdID=SIPDR1.PrdID AND SIP.PrdBatID=SIPDR1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPDR2 ON SI.SalId=SIPDR2.SalId AND SIP.PrdID=SIPDR2.PrdID AND SIP.PrdBatID=SIPDR2.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPCA1 ON SI.SalId=SIPCA1.SalId AND SIP.PrdID=SIPCA1.PrdID AND SIP.PrdBatID=SIPCA1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPCA2 ON SI.SalId=SIPCA2.SalId AND SIP.PrdID=SIPCA2.PrdID AND SIP.PrdBatID=SIPCA2.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPCN1 ON SI.SalId=SIPCN1.SalId AND SIP.PrdID=SIPCN1.PrdID AND SIP.PrdBatID=SIPCN1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPCN2 ON SI.SalId=SIPCN2.SalId AND SIP.PrdID=SIPCN2.PrdID AND SIP.PrdBatID=SIPCN2.PrdBatID
	--	LEFT OUTER JOIN UOMMaster UMP1 ON UMP1.UOMId=SIPP1.UOM1Id AND UMP1.UOMDescription='PIECES'
	--	LEFT OUTER JOIN UOMMaster UMP2 ON UMP1.UOMId=SIPP2.UOM2Id AND UMP2.UOMDescription='PIECES'
	--	LEFT OUTER JOIN UOMMaster UMBU1 ON UMBU1.UOMId=SIPBU1.UOM1Id AND UMBU1.UOMDescription='BUCKETS' 
	--	LEFT OUTER JOIN UOMMaster UMBU2 ON UMBU1.UOMId=SIPBU2.UOM2Id AND UMBU2.UOMDescription='BUCKETS'
	--	LEFT OUTER JOIN UOMMaster UMBA1 ON UMBA1.UOMId=SIPBA1.UOM1Id AND UMBA1.UOMDescription='BAGS' 
	--	LEFT OUTER JOIN UOMMaster UMBA2 ON UMBA1.UOMId=SIPBA2.UOM2Id AND UMBA2.UOMDescription='BAGS'
	--	LEFT OUTER JOIN UOMMaster UMDR1 ON UMDR1.UOMId=SIPDR1.UOM1Id AND UMDR1.UOMDescription='DRUMS' 
	--	LEFT OUTER JOIN UOMMaster UMDR2 ON UMDR1.UOMId=SIPDR2.UOM2Id AND UMDR2.UOMDescription='DRUMS'
	--	LEFT OUTER JOIN UOMMaster UMCA1 ON UMCA1.UOMId=SIPCA1.UOM1Id AND UMCA1.UOMDescription='CARTONS' 
	--	LEFT OUTER JOIN UOMMaster UMCA2 ON UMCA1.UOMId=SIPCA2.UOM2Id AND UMCA2.UOMDescription='CARTONS'
	--	LEFT OUTER JOIN UOMMaster UMCN1 ON UMCN1.UOMId=SIPCN1.UOM1Id AND UMCN1.UOMDescription='CANS' 
	--	LEFT OUTER JOIN UOMMaster UMCN2 ON UMCN1.UOMId=SIPCN2.UOM2Id AND UMCN2.UOMDescription='CANS'
	--	LEFT OUTER JOIN (
	--	SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG
	--	WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN ( 
	--	SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )
	--	GROUP BY P.PrdID) UGC1 ON SIPCN1.PrdId=UGC1.PrdID
	--	LEFT OUTER JOIN (
	--	SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG
	--	WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN ( 
	--	SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )
	--	GROUP BY P.PrdID) UGC2 ON SIPCN2.PrdId=UGC2.PrdID
	--) A
	--GROUP BY SalId,SalInvNo
	--->Till Here
	--Added By Sathishkumar Veeramani 2012/12/13
	IF NOT EXISTS (SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')AND name = 'Payment Mode')
	BEGIN
	     ALTER TABLE RptBillTemplateFinal ADD [Payment Mode] NVARCHAR(20)
	END
	IF Exists(SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')AND name = 'Payment Mode')    
	BEGIN    
		SET @SSQL1='UPDATE A SET A.[Payment Mode] = Z.[Payment Mode] FROM RptBillTemplateFinal A INNER JOIN 
					(SELECT SalId,(CASE RtrPayMode WHEN 1 THEN ''Cash'' ELSE ''Cheque'' END) AS [Payment Mode] FROM SalesInvoice WITH (NOLOCK)) Z ON A.Salid = Z.SalId 
					AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
		EXEC (@SSQL1)    
	END
	--Till Here
	--->Added By Nanda on 23/03/2010-For Grouping the details based on product for nondrug products
	IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreeBillPrinting01' AND ModuleName='Botree Bill Printing' AND Status=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplateFinal_Group]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
		DROP TABLE [RptBillTemplateFinal_Group]
		SELECT * INTO RptBillTemplateFinal_Group FROM RptBillTemplateFinal
		DELETE FROM RptBillTemplateFinal
		INSERT INTO RptBillTemplateFinal
		(
			[SalId],[Sales Invoice Number],[Product Code],[Product Name],[Product Short Name],[Product SL No],[Product Type],[Scheme Points],
			[Base Qty],[Batch Code],[Batch Expiry Date],[Batch Manufacturing Date],
			[Batch MRP],[Batch Selling Rate],[Bill Date],[Bill Doc Ref. Number],[Bill Mode],[Bill Type],
			[CD Disc Base Qty Amount],[CD Disc Effect Amount],
			[CD Disc Header Amount],[CD Disc LineUnit Amount],
			[CD Disc Qty Percentage],[CD Disc Unit Percentage],
			[CD Disc UOM Amount],[CD Disc UOM Percentage],
			[DB Disc Base Qty Amount],[DB Disc Effect Amount],
			[DB Disc Header Amount],[DB Disc LineUnit Amount],
			[DB Disc Qty Percentage],[DB Disc Unit Percentage],
			[DB Disc UOM Amount],[DB Disc UOM Percentage],
			[Line Base Qty Amount],[Line Base Qty Percentage],
			[Line Effect Amount],[Line Unit Amount],
			[Line Unit Percentage],[Line UOM1 Amount],[Line UOM1 Percentage],
			[Manual Free Qty],
			[Sch Disc Base Qty Amount],[Sch Disc Effect Amount],
			[Sch Disc Header Amount],[Sch Disc LineUnit Amount],
			[Sch Disc Qty Percentage],[Sch Disc Unit Percentage],
			[Sch Disc UOM Amount],[Sch Disc UOM Percentage],
			[Spl. Disc Base Qty Amount],[Spl. Disc Effect Amount],
			[Spl. Disc Header Amount],[Spl. Disc LineUnit Amount],
			[Spl. Disc Qty Percentage],[Spl. Disc Unit Percentage],
			[Spl. Disc UOM Amount],[Spl. Disc UOM Percentage],
			[Tax 1],[Tax 2],[Tax 3],[Tax 4],
			[Tax Amount1],[Tax Amount2],[Tax Amount3],[Tax Amount4],
			[Tax Amt Base Qty Amount],[Tax Amt Effect Amount],
			[Tax Amt Header Amount],[Tax Amt LineUnit Amount],
			[Tax Amt Qty Percentage],[Tax Amt Unit Percentage],
			[Tax Amt UOM Amount],[Tax Amt UOM Percentage],
			[Uom 1 Desc],[Uom 1 Qty],[Uom 2 Desc],[Uom 2 Qty],[Vehicle Name],
			[SalesInvoice ActNetRateAmount],[SalesInvoice CDPer],[SalesInvoice CRAdjAmount],[SalesInvoice DBAdjAmount],[SalesInvoice GrossAmount],
			[SalesInvoice Line Gross Amount],[SalesInvoice Line Net Amount],
			[SalesInvoice MarketRetAmount],[SalesInvoice NetAmount],[SalesInvoice NetRateDiffAmount],
			[SalesInvoice OnAccountAmount],[SalesInvoice OtherCharges],[SalesInvoice RateDiffAmount],[SalesInvoice ReplacementDiffAmount],[SalesInvoice RoundOffAmt],
			[SalesInvoice TotalAddition],[SalesInvoice TotalDeduction],[SalesInvoice WindowDisplayAmount],[SalesMan Code],[SalesMan Name],
			[Route Code],[Route Name],
			[Retailer Address1],[Retailer Address2],[Retailer Address3],[Retailer Code],[Retailer ContactPerson],[Retailer Coverage Mode],
			[Retailer Credit Bills],[Retailer Credit Days],[Retailer Credit Limit],[Retailer CSTNo],[Retailer Deposit Amount],[Retailer Drug ExpiryDate],
			[Retailer Drug License No],[Retailer EmailId],[Retailer GeoLevel],[Retailer License ExpiryDate],[Retailer License No],[Retailer Name],
			[Retailer OffPhone1],[Retailer OffPhone2],[Retailer OnAccount],[Retailer Pestcide ExpiryDate],[Retailer Pestcide LicNo],[Retailer PhoneNo],
			[Retailer Pin Code],[Retailer ResPhone1],[Retailer ResPhone2],[Retailer Ship Address1],[Retailer Ship Address2],[Retailer Ship Address3],
			[Retailer ShipId],[Retailer TaxType],[Retailer TINNo],[Retailer Village],[Tax Type],[TIN Number],
			[Company Address1],[Company Address2],[Company Address3],[Company Code],[Company Contact Person],
			[Company EmailId],[Company Fax Number],[Company Name],[Company Phone Number],[Contact Person],[CST Number],
			[DC DATE],[DC NUMBER],[Delivery Boy],[Delivery Date],[Deposit Amount],
			[Distributor Address1],[Distributor Address2],[Distributor Address3],[Distributor Code],[Distributor Name],
			[Drug Batch Description],[Drug Licence Number 1],[Drug Licence Number 2],[Drug1 Expiry Date],[Drug2 Expiry Date],
			[EAN Code],[EmailID],[Geo Level],[Interim Sales],[Licence Number],
			[LST Number],[Order Date],[Order Number],
			[Pesticide Expiry Date],[Pesticide Licence Number],[PhoneNo],[PinCode],[Remarks],
			[UsrId],[Visibility],[Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd]
		)		
		SELECT
		[SalId],
		[Sales Invoice Number],
		[Product Code],[Product Name],[Product Short Name],MIN([Product SL No]) AS [Product SL No],[Product Type],[Scheme Points],
		SUM([Base Qty]) AS [Base Qty],
		'' AS [Batch Code],MAX([Batch Expiry Date]) AS [Batch Expiry Date],MIN([Batch Manufacturing Date]) AS [Batch Manufacturing Date],
		[Batch MRP],[Batch Selling Rate],[Bill Date],[Bill Doc Ref. Number],[Bill Mode],[Bill Type],
		SUM([CD Disc Base Qty Amount]) AS [CD Disc Base Qty Amount],SUM([CD Disc Effect Amount]) AS [CD Disc Effect Amount],
		SUM(DISTINCT [CD Disc Header Amount]) AS [CD Disc Header Amount],SUM([CD Disc LineUnit Amount]) AS [CD Disc LineUnit Amount],
		--SUM([CD Disc Qty Percentage]) AS [CD Disc Qty Percentage],SUM([CD Disc Unit Percentage]) AS [CD Disc Unit Percentage],
		[CD Disc Qty Percentage],[CD Disc Unit Percentage],
		SUM([CD Disc UOM Amount]),SUM([CD Disc UOM Percentage]) AS [CD Disc UOM Percentage],
		SUM([DB Disc Base Qty Amount]) AS [DB Disc Base Qty Amount],SUM([DB Disc Effect Amount]) AS [DB Disc Effect Amount],
		SUM(DISTINCT [DB Disc Header Amount]) AS [DB Disc Header Amount],SUM([DB Disc LineUnit Amount]) AS [DB Disc LineUnit Amount],
		--SUM([DB Disc Qty Percentage]) AS [DB Disc Qty Percentage],SUM([DB Disc Unit Percentage]) AS [DB Disc Unit Percentage],
		[DB Disc Qty Percentage],SUM([DB Disc Unit Percentage]),
		SUM([DB Disc UOM Amount]) AS [DB Disc UOM Amount],SUM([DB Disc UOM Percentage]) AS [DB Disc UOM Percentage],
		SUM([Line Base Qty Amount]) AS [Line Base Qty Amount],SUM([Line Base Qty Percentage]) AS [Line Base Qty Percentage],
		SUM([Line Effect Amount]) AS [Line Effect Amount],
		--SUM([Line Unit Amount]) AS [Line Unit Amount],
		[Line Unit Amount],
		SUM([Line Unit Percentage]) AS [Line Unit Percentage],SUM([Line UOM1 Amount]) AS [Line UOM1 Amount],SUM([Line UOM1 Percentage]) AS [Line UOM1 Percentage],
		SUM([Manual Free Qty]),
		SUM([Sch Disc Base Qty Amount]) AS [Sch Disc Base Qty Amount],SUM([Sch Disc Effect Amount]) AS [Sch Disc Effect Amount],
		SUM(DISTINCT [Sch Disc Header Amount]) AS [Sch Disc Header Amount],SUM([Sch Disc LineUnit Amount]) AS [Sch Disc LineUnit Amount],
		--SUM([Sch Disc Qty Percentage]) AS [Sch Disc Qty Percentage],SUM([Sch Disc Unit Percentage]) AS [Sch Disc Unit Percentage],
		[Sch Disc Qty Percentage],[Sch Disc Unit Percentage],
		SUM([Sch Disc UOM Amount]) AS [Sch Disc UOM Amount],SUM([Sch Disc UOM Percentage]) AS [Sch Disc UOM Percentage],
		SUM([Spl. Disc Base Qty Amount]) AS [Spl. Disc Base Qty Amount],SUM([Spl. Disc Effect Amount]) AS [Spl. Disc Effect Amount],
		SUM(DISTINCT [Spl. Disc Header Amount]) AS [Spl. Disc Header Amount],SUM([Spl. Disc LineUnit Amount]) AS [Spl. Disc LineUnit Amount],
		--SUM([Spl. Disc Qty Percentage]) AS [Spl. Disc Qty Percentage],SUM([Spl. Disc Unit Percentage]) AS [Spl. Disc Unit Percentage],
		[Spl. Disc Qty Percentage],[Spl. Disc Unit Percentage],
		SUM([Spl. Disc UOM Amount]) AS [Spl. Disc UOM Amount],SUM([Spl. Disc UOM Percentage]) AS [Spl. Disc UOM Percentage],
		--SUM([Tax 1]) AS [Tax 1],SUM([Tax 2]) AS [Tax 2],SUM([Tax 3]) AS [Tax 3],SUM([Tax 4]) AS [Tax 4],
		[Tax 1],[Tax 2],[Tax 3],[Tax 4],
		SUM([Tax Amount1]) AS [Tax Amount1],SUM([Tax Amount2]) AS [Tax Amount2],SUM([Tax Amount3]) AS [Tax Amount3],SUM([Tax Amount4]) AS [Tax Amount4],
		SUM([Tax Amt Base Qty Amount]) AS [Tax Amt Base Qty Amount],SUM([Tax Amt Effect Amount]) AS [Tax Amt Effect Amount],
		SUM(DISTINCT [Tax Amt Header Amount]) AS [Tax Amt Header Amount],SUM([Tax Amt LineUnit Amount]) AS [Tax Amt LineUnit Amount],
		SUM([Tax Amt Qty Percentage]) AS [Tax Amt Qty Percentage],SUM([Tax Amt Unit Percentage]) AS [Tax Amt Unit Percentage],
		SUM([Tax Amt UOM Amount]) AS [Tax Amt UOM Amount],SUM([Tax Amt UOM Percentage]) AS [Tax Amt UOM Percentage],
		'' AS [Uom 1 Desc],SUM([Base Qty]) AS [Uom 1 Qty],'' AS [Uom 2 Desc],0 AS [Uom 2 Qty],[Vehicle Name],
		[SalesInvoice ActNetRateAmount],[SalesInvoice CDPer],[SalesInvoice CRAdjAmount],[SalesInvoice DBAdjAmount],[SalesInvoice GrossAmount],
		SUM([SalesInvoice Line Gross Amount]) AS [SalesInvoice Line Gross Amount],SUM([SalesInvoice Line Net Amount]) AS [SalesInvoice Line Net Amount],
		[SalesInvoice MarketRetAmount],[SalesInvoice NetAmount],[SalesInvoice NetRateDiffAmount],
		[SalesInvoice OnAccountAmount],[SalesInvoice OtherCharges],[SalesInvoice RateDiffAmount],[SalesInvoice ReplacementDiffAmount],[SalesInvoice RoundOffAmt],
		[SalesInvoice TotalAddition],[SalesInvoice TotalDeduction],[SalesInvoice WindowDisplayAmount],[SalesMan Code],[SalesMan Name],
		[Route Code],[Route Name],
		[Retailer Address1],[Retailer Address2],[Retailer Address3],[Retailer Code],[Retailer ContactPerson],[Retailer Coverage Mode],
		[Retailer Credit Bills],[Retailer Credit Days],[Retailer Credit Limit],[Retailer CSTNo],[Retailer Deposit Amount],[Retailer Drug ExpiryDate],
		[Retailer Drug License No],[Retailer EmailId],[Retailer GeoLevel],[Retailer License ExpiryDate],[Retailer License No],[Retailer Name],
		[Retailer OffPhone1],[Retailer OffPhone2],[Retailer OnAccount],[Retailer Pestcide ExpiryDate],[Retailer Pestcide LicNo],[Retailer PhoneNo],
		[Retailer Pin Code],[Retailer ResPhone1],[Retailer ResPhone2],[Retailer Ship Address1],[Retailer Ship Address2],[Retailer Ship Address3],
		[Retailer ShipId],[Retailer TaxType],[Retailer TINNo],[Retailer Village],[Tax Type],[TIN Number],
		[Company Address1],[Company Address2],[Company Address3],[Company Code],[Company Contact Person],
		[Company EmailId],[Company Fax Number],[Company Name],[Company Phone Number],[Contact Person],[CST Number],
		[DC DATE],[DC NUMBER],[Delivery Boy],[Delivery Date],[Deposit Amount],
		[Distributor Address1],[Distributor Address2],[Distributor Address3],[Distributor Code],[Distributor Name],
		[Drug Batch Description],[Drug Licence Number 1],[Drug Licence Number 2],[Drug1 Expiry Date],[Drug2 Expiry Date],
		[EAN Code],[EmailID],[Geo Level],[Interim Sales],[Licence Number],
		[LST Number],[Order Date],[Order Number],
		[Pesticide Expiry Date],[Pesticide Licence Number],[PhoneNo],[PinCode],[Remarks],
		[UsrId],[Visibility],[Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd]
		FROM RptBillTemplateFinal_Group,Product P
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType<>5
		GROUP BY [Batch MRP],[Batch Selling Rate],[Bill Date],[Bill Doc Ref. Number],[Bill Mode],[Bill Type],
		[Company Address1],[Company Address2],[Company Address3],[Company Code],[Company Contact Person],
		[Company EmailId],[Company Fax Number],[Company Name],[Company Phone Number],[Contact Person],[CST Number],
		[DC DATE],[DC NUMBER],[Delivery Boy],[Delivery Date],[Deposit Amount],
		[Distributor Address1],[Distributor Address2],[Distributor Address3],[Distributor Code],[Distributor Name],
		[Drug Batch Description],[Drug Licence Number 1],[Drug Licence Number 2],[Drug1 Expiry Date],[Drug2 Expiry Date],
		[EAN Code],[EmailID],[Geo Level],[Interim Sales],[Licence Number],
		[LST Number],
		[Order Date],[Order Number],
		[Pesticide Expiry Date],[Pesticide Licence Number],[PhoneNo],[PinCode],
		[Product Code],[Product Name],[Product Short Name],[Product Type],
		[Remarks],
		[Retailer Address1],[Retailer Address2],[Retailer Address3],[Retailer Code],[Retailer ContactPerson],[Retailer Coverage Mode],
		[Retailer Credit Bills],[Retailer Credit Days],[Retailer Credit Limit],[Retailer CSTNo],[Retailer Deposit Amount],[Retailer Drug ExpiryDate],
		[Retailer Drug License No],[Retailer EmailId],[Retailer GeoLevel],[Retailer License ExpiryDate],[Retailer License No],[Retailer Name],
		[Retailer OffPhone1],[Retailer OffPhone2],[Retailer OnAccount],[Retailer Pestcide ExpiryDate],[Retailer Pestcide LicNo],[Retailer PhoneNo],
		[Retailer Pin Code],[Retailer ResPhone1],[Retailer ResPhone2],[Retailer Ship Address1],[Retailer Ship Address2],[Retailer Ship Address3],
		[Retailer ShipId],[Retailer TaxType],[Retailer TINNo],[Retailer Village],
		[Route Code],[Route Name],
		[Sales Invoice Number],[SalesInvoice ActNetRateAmount],[SalesInvoice CDPer],[SalesInvoice CRAdjAmount],[SalesInvoice DBAdjAmount],[SalesInvoice GrossAmount],
		[SalesInvoice MarketRetAmount],[SalesInvoice NetAmount],[SalesInvoice NetRateDiffAmount],
		[SalesInvoice OnAccountAmount],[SalesInvoice OtherCharges],[SalesInvoice RateDiffAmount],[SalesInvoice ReplacementDiffAmount],[SalesInvoice RoundOffAmt],
		[SalesInvoice TotalAddition],[SalesInvoice TotalDeduction],[SalesInvoice WindowDisplayAmount],[SalesMan Code],[SalesMan Name],
		[SalId],
		[Scheme Points],
		[Tax Type],[TIN Number],
		[Vehicle Name],[Tax 1],[Tax 2],[Tax 3],[Tax 4],
		[CD Disc Qty Percentage],[CD Disc Unit Percentage],
		[DB Disc Qty Percentage],--[DB Disc Unit Percentage],
		[Line Unit Amount],
		[Sch Disc Qty Percentage],[Sch Disc Unit Percentage],
		[Spl. Disc Qty Percentage],[Spl. Disc Unit Percentage],		
		[UsrId],[Visibility],[AmtInWrd]
		UNION ALL
		SELECT [SalId],[Sales Invoice Number],[Product Code],[Product Name],[Product Short Name],[Product SL No],[Product Type],[Scheme Points],
		[Base Qty],[Batch Code],[Batch Expiry Date],[Batch Manufacturing Date],
		[Batch MRP],[Batch Selling Rate],[Bill Date],[Bill Doc Ref. Number],[Bill Mode],[Bill Type],
		[CD Disc Base Qty Amount],[CD Disc Effect Amount],
		[CD Disc Header Amount],[CD Disc LineUnit Amount],
		[CD Disc Qty Percentage],[CD Disc Unit Percentage],
		[CD Disc UOM Amount],[CD Disc UOM Percentage],
		[DB Disc Base Qty Amount],[DB Disc Effect Amount],
		[DB Disc Header Amount],[DB Disc LineUnit Amount],
		[DB Disc Qty Percentage],[DB Disc Unit Percentage],
		[DB Disc UOM Amount],[DB Disc UOM Percentage],
		[Line Base Qty Amount],[Line Base Qty Percentage],
		[Line Effect Amount],[Line Unit Amount],
		[Line Unit Percentage],[Line UOM1 Amount],[Line UOM1 Percentage],
		[Manual Free Qty],
		[Sch Disc Base Qty Amount],[Sch Disc Effect Amount],
		[Sch Disc Header Amount],[Sch Disc LineUnit Amount],
		[Sch Disc Qty Percentage],[Sch Disc Unit Percentage],
		[Sch Disc UOM Amount],[Sch Disc UOM Percentage],
		[Spl. Disc Base Qty Amount],[Spl. Disc Effect Amount],
		[Spl. Disc Header Amount],[Spl. Disc LineUnit Amount],
		[Spl. Disc Qty Percentage],[Spl. Disc Unit Percentage],
		[Spl. Disc UOM Amount],[Spl. Disc UOM Percentage],
		[Tax 1],[Tax 2],[Tax 3],[Tax 4],
		[Tax Amount1],[Tax Amount2],[Tax Amount3],[Tax Amount4],
		[Tax Amt Base Qty Amount],[Tax Amt Effect Amount],
		[Tax Amt Header Amount],[Tax Amt LineUnit Amount],
		[Tax Amt Qty Percentage],[Tax Amt Unit Percentage],
		[Tax Amt UOM Amount],[Tax Amt UOM Percentage],
		[Uom 1 Desc],[Uom 1 Qty],[Uom 2 Desc],[Uom 2 Qty],[Vehicle Name],
		[SalesInvoice ActNetRateAmount],[SalesInvoice CDPer],[SalesInvoice CRAdjAmount],[SalesInvoice DBAdjAmount],[SalesInvoice GrossAmount],
		[SalesInvoice Line Gross Amount],[SalesInvoice Line Net Amount],
		[SalesInvoice MarketRetAmount],[SalesInvoice NetAmount],[SalesInvoice NetRateDiffAmount],
		[SalesInvoice OnAccountAmount],[SalesInvoice OtherCharges],[SalesInvoice RateDiffAmount],[SalesInvoice ReplacementDiffAmount],[SalesInvoice RoundOffAmt],
		[SalesInvoice TotalAddition],[SalesInvoice TotalDeduction],[SalesInvoice WindowDisplayAmount],[SalesMan Code],[SalesMan Name],
		[Route Code],[Route Name],
		[Retailer Address1],[Retailer Address2],[Retailer Address3],[Retailer Code],[Retailer ContactPerson],[Retailer Coverage Mode],
		[Retailer Credit Bills],[Retailer Credit Days],[Retailer Credit Limit],[Retailer CSTNo],[Retailer Deposit Amount],[Retailer Drug ExpiryDate],
		[Retailer Drug License No],[Retailer EmailId],[Retailer GeoLevel],[Retailer License ExpiryDate],[Retailer License No],[Retailer Name],
		[Retailer OffPhone1],[Retailer OffPhone2],[Retailer OnAccount],[Retailer Pestcide ExpiryDate],[Retailer Pestcide LicNo],[Retailer PhoneNo],
		[Retailer Pin Code],[Retailer ResPhone1],[Retailer ResPhone2],[Retailer Ship Address1],[Retailer Ship Address2],[Retailer Ship Address3],
		[Retailer ShipId],[Retailer TaxType],[Retailer TINNo],[Retailer Village],[Tax Type],[TIN Number],
		[Company Address1],[Company Address2],[Company Address3],[Company Code],[Company Contact Person],
		[Company EmailId],[Company Fax Number],[Company Name],[Company Phone Number],[Contact Person],[CST Number],
		[DC DATE],[DC NUMBER],[Delivery Boy],[Delivery Date],[Deposit Amount],
		[Distributor Address1],[Distributor Address2],[Distributor Address3],[Distributor Code],[Distributor Name],
		[Drug Batch Description],[Drug Licence Number 1],[Drug Licence Number 2],[Drug1 Expiry Date],[Drug2 Expiry Date],
		[EAN Code],[EmailID],[Geo Level],[Interim Sales],[Licence Number],
		[LST Number],[Order Date],[Order Number],
		[Pesticide Expiry Date],[Pesticide Licence Number],[PhoneNo],[PinCode],[Remarks],
		[UsrId],[Visibility],[Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd]
		FROM RptBillTemplateFinal_Group,Product P
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5
	END	
	--->Till Here
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDisc')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD InvDisc NUMERIC (18,2) DEFAULT 0 WITH VALUES 
		END
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDiscPer')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD InvDiscPer NUMERIC (18,2) DEFAULT 0 WITH VALUES 
		END
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='SalesmanPhoneNo')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD SalesmanPhoneNo NUMERIC (18,0) DEFAULT 0 WITH VALUES 
		END		
		
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='Grammage')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD Grammage NUMERIC (38,2) DEFAULT 0 WITH VALUES 
		END
		
		IF Exists(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDisc')    
		BEGIN    
			SET @SSQL1='UPDATE A SET A.InvDisc=B.SalInvLvlDisc FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) 
						ON A.[Sales Invoice Number]=B.SalInvNo AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
			EXEC (@SSQL1)    
		END 
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDiscPer')    
		BEGIN  
			SET @SSQL1='UPDATE A SET A.InvDiscPer=B.SalInvLvlDiscPer FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) 
						ON A.[Sales Invoice Number]=B.SalInvNo AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
			EXEC (@SSQL1)    
		END
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='SalesmanPhoneNo')    
		BEGIN  
			SET @SSQL1='UPDATE A SET A.SalesmanPhoneNo=ISNULL(B.SMPhoneNumber,0) FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesMan B (NOLOCK) 
						ON A.[SalesMan Code]=B.SMCode AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
			EXEC (@SSQL1)    
		END
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='Grammage')    
		BEGIN 
					--SET @SSQL1=' UPDATE RPT SET RPT.Grammage=X.Grammage FROM RptBillTemplateFinal RPT (NOLOCK) 
					--				INNER JOIN (
					--					SELECT SP.[Sales Invoice Number],P.PRDID,P.PrdCCode,P.PrdDCode,U.PrdUnitCode,ISNULL(
					--					CASE U.PRDUNITID WHEN 2 THEN ISNULL(SUM(PrdWgt * SP.[Base Qty]),0)/1000
					--					WHEN 3 THEN ISNULL(SUM(PrdWgt * SP.[Base Qty]),0) END,0) AS Grammage
					--					FROM RptBillTemplateFinal SP (NOLOCK)
					--					INNER JOIN Product P (NOLOCK) ON P.PrdCCode=SP.[Product Code]
					--					INNER JOIN PRODUCTUNIT U (NOLOCK) ON P.PrdUnitId=U.PrdUnitId
					--					WHERE SP.USRID=
					--					GROUP BY P.PRDID,P.PrdCCode,P.PrdDCode,U.PrdUnitCode,U.PRDUNITID,SP.[Sales Invoice Number]
					--				) X ON X.PrdCCode=RPT.[PRODUCT CODE] AND X.[Sales Invoice Number]=RPT.[Sales Invoice Number] WHERE RPT.UsrId='+CAST(@Pi_UsrId AS VARCHAR(10))+''					    
					SET @SSQL1=' UPDATE RPT SET RPT.Grammage=X.Grammage FROM RptBillTemplateFinal RPT (NOLOCK) 
									INNER JOIN (
										SELECT SP.[Sales Invoice Number],P.PRDID,P.PrdCCode,P.PrdDCode,P.PrdWgt Grammage
										FROM RptBillTemplateFinal SP (NOLOCK)
										INNER JOIN Product P (NOLOCK) ON P.PrdCCode=SP.[Product Code]
										WHERE SP.USRID='+CAST(@Pi_UsrId AS VARCHAR(10))+'
									) X ON X.PrdCCode=RPT.[PRODUCT CODE] AND X.[Sales Invoice Number]=RPT.[Sales Invoice Number] WHERE RPT.UsrId='+CAST(@Pi_UsrId AS VARCHAR(10))+''					    
									
					EXEC (@SSQL1)    
		END	 
	
	IF EXISTS (SELECT A.SalId FROM SalInvoiceDeliveryChallan A INNER JOIN SalesInvoice B
				ON A.SalId=B.SalId INNER JOIN RptBillToPrint C ON C.[Bill Number]=SalInvNo)
	BEGIN
		TRUNCATE TABLE RptFinalBillTemplate_DC
		INSERT INTO RptFinalBillTemplate_DC(SalId,InvNo,DCNo,DCDate)
		SELECT A.SalId,B.SalInvNo,A.DCNo,DCDate FROM SalInvoiceDeliveryChallan A INNER JOIN SalesInvoice B
		ON A.SalId=B.SalId INNER JOIN RptBillToPrint C ON C.[Bill Number]=SalInvNo
	END
	ELSE
	BEGIN
		TRUNCATE TABLE RptFinalBillTemplate_DC
	END
	RETURN
END
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.3',425
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE FixId = 425)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(425,'D','2015-08-21',GETDATE(),1,'Core Stocky Service Pack 425')