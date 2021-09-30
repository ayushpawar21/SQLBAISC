--[Stocky HotFix Version]=343
Delete from Versioncontrol where Hotfixid='343'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('343','2.0.0.5','D','2010-10-23','2010-10-23','2010-10-23',convert(varchar(11),getdate()),'JNJ;Major:FBM changes;Minor:')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 343' ,'343'
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_UDCDefaults]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_UDCDefaults]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_UDCDefaults]
(
	[DistCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MasterName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ColumnName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ColumnValue] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DownLoadFlag] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Import_UDCDefaults]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Import_UDCDefaults]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_Import_Configuration '<Root></Root>'

CREATE    PROCEDURE [dbo].[Proc_Import_UDCDefaults]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_UDCDefaults
* PURPOSE		: To Insert and Update records  from xml file in the Table Cn2Cs_Prk_UDCDefaults
* CREATED		: Nandakumar R.G
* CREATED DATE	: 09/08/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	DELETE FROM Cn2Cs_Prk_UDCDefaults WHERE DownLoadFlag='Y'

	INSERT INTO Cn2Cs_Prk_UDCDefaults(DistCode,MasterName,ColumnName,ColumnValue,DownLoadFlag)
	SELECT DistCode,MasterName,ColumnName,ColumnValue,DownLoadFlag
	FROM OPENXML (@hdoc,'/Root/Console2CS_UDCMasterValue',1)
	WITH 
	(	
			[DistCode]		NVARCHAR(100), 
			[MasterName]	NVARCHAR(100),
			[ColumnName]	NVARCHAR(100),						
			[ColumnValue]	NVARCHAR(100),			
			[DownLoadFlag]	NVARCHAR(10) 
	) XMLObj

	EXECUTE sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_UDCDefaults]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_UDCDefaults]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_UDCDefaults 0
SELECT * FROM Cn2Cs_Prk_UDCDefaults
ROLLBACK TRANSACTION
*/

CREATE            Procedure [dbo].[Proc_Cn2Cs_UDCDefaults]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_UDCDefaults
* PURPOSE		: To Validate the UDC Default Values Downloaded from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 09/08/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN

	SET @Po_ErrNo=0

	DECLARE @MasterName		NVARCHAR(100)
	DECLARE @ColumnName		NVARCHAR(100)
	DECLARE @ColumnValue	NVARCHAR(100)
	
	DECLARE @SeqId			INT
	DECLARE @MasterId		INT
	DECLARE @UDCMasterId	INT


	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'UDCDefToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE UDCDefToAvoid	
	END

	CREATE TABLE UDCDefToAvoid
	(		
		MasterName		NVARCHAR(200),
		ColumnName		NVARCHAR(200)
	)

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(MasterName,'')='') 
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(MasterName,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','MasterName','Module Name should not be empty'
		FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(MasterName,'')=''
	END

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnName,'')='') 
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnName,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','ColumnName','Column Name should not be empty'
		FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnName,'')=''
	END

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnValue,'')='') 
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnValue,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','ColumnValue','Column Value should not be empty'
		FROM Cn2Cs_Prk_UDCDefaults WHERE ISNULL(ColumnValue,'')=''
	END

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName NOT IN 
	(SELECT MAsterName FROM UDCHd)) 
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName NOT IN 
		(SELECT MAsterName FROM UDCHd)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','MasterName','Master Name:'+MasterName+' not available'
		FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName NOT IN 
		(SELECT MAsterName FROM UDCHd)
	END

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName+'~'+ColumnName NOT IN 
	(SELECT UH.MasterName+'~'+UM.ColumnName FROM UDCHd UH,UDCMaster UM WHERE UH.MasterId=UM.MasterId)) 
	BEGIN
		INSERT INTO UDCDefToAvoid(MasterName,ColumnName)
		SELECT MasterName,ColumnName FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName+'~'+ColumnName NOT IN 
		(SELECT UH.MasterName+'~'+UM.ColumnName FROM UDCHd UH,UDCMaster UM WHERE UH.MasterId=UM.MasterId)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_UDCDefaults','UDC Master','UDC Name:'+ColumnName+' not available for:'+MasterName
		FROM Cn2Cs_Prk_UDCDefaults WHERE MasterName+'~'+ColumnName NOT IN 
		(SELECT UH.MasterName+'~'+UM.ColumnName FROM UDCHd UH,UDCMaster UM WHERE UH.MasterId=UM.MasterId)
	END

	DECLARE Cur_UDCDef CURSOR
	FOR SELECT MasterName,ColumnName,ColumnValue
	FROM Cn2Cs_Prk_UDCDefaults WHERE DownLoadFlag='D' AND ISNULL(MasterName,'')+'~'+ISNULL(ColumnName,'') 
	NOT IN (SELECT ISNULL(MasterName,'')+'~'+ISNULL(ColumnName,'') FROM UDCDefToAvoid)
	OPEN Cur_UDCDef
	FETCH NEXT FROM Cur_UDCDef INTO @MasterName,@ColumnName,@ColumnValue
	WHILE @@FETCH_STATUS=0
	BEGIN

		SELECT @MasterId=MasterId FROM UDCHd WHERE MasterName=@MasterName
		SELECT @UdcMasterId=UdcMasterId FROM UdcMaster WHERE ColumnName=@ColumnName

		IF NOT EXISTS(SELECT * FROM UDCDefault WHERE MasterId=@MasterId AND 
		UDCMasterId=@UDCMasterId AND ColValue=@ColumnValue)
		BEGIN
			SELECT @SeqId=ISNULL(MAX(SeqId),0)+1 FROM UDCDefault WHERE MasterId=@MasterId AND 
			UDCMasterId=@UDCMasterId

			INSERT UDCDefault(SeqId,MasterId,UdcMasterId,ColValue)
			SELECT @SeqId,@MasterId,@UDCMasterId,@ColumnValue
		END

		FETCH NEXT FROM Cur_UDCDef INTO @MasterName,@ColumnName,@ColumnValue
	END
	CLOSE Cur_UDCDef
	DEALLOCATE Cur_UDCDef

	UPDATE Cn2Cs_Prk_UDCDefaults SET DownLoadFlag='Y' WHERE DownLoadFlag='D' AND ISNULL(MasterName,'')+'~'+ISNULL(ColumnName,'')
	NOT IN (SELECT ISNULL(MasterName,'')+'~'+ISNULL(ColumnName,'') FROM UDCDefToAvoid)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_DefaultPriceUpdation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_DefaultPriceUpdation]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
BEGIN TRANSACTION
EXEC Proc_DefaultPriceUpdation 4871,22302,1
--SELECT * FROM ProductBatchDetails ORDER BY PriceId
--WHERE PriceId>19
--SELECT * FROM ValueDifferenceClaim
--SELECT * FROM ExistPriceDetails
ROLLBACK TRANSACTION
*/
CREATE	PROCEDURE [dbo].[Proc_DefaultPriceUpdation]
(
	@Pi_ExistPrdBatId	INT,
	@Pi_ExistPriceId	INT,
	@Pi_UserId			INT
)
AS
/*********************************
* PROCEDURE		: Proc_DefaultPriceUpdation
* PURPOSE		: To update the latest Price
* CREATED		: Nandakumar R.G
* CREATED DATE	: 25/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @PrdId		INT
	DECLARE @PrdBatId	INT
	DECLARE @PriceId	INT
	DECLARE @PrdCCode	NVARCHAR(200)
	DECLARE @PrdBatCode	NVARCHAR(200)
	DECLARE @MRP		NUMERIC(38,6)
	DECLARE @LSP		NUMERIC(38,6)
	DECLARE @SellRate	NUMERIC(38,6)
	DECLARE @ClaimRate	NUMERIC(38,6)
	DECLARE @DClaimRate	NUMERIC(38,6)
	DECLARE @LSPChange		NUMERIC(38,6)
	DECLARE @StockInHand	NUMERIC(38,0)
	DECLARE @ValDiffRefNo	NVARCHAR(50)
	
	DECLARE @OldPriceId		INT
	DECLARE @OldLSP			NUMERIC(38,6)
	DECLARE @NewPriceId		INT
	DECLARE @NewPrdBatId	INT
	DECLARE @NewPrdBatCode	NVARCHAR(200)
	DECLARE @BatchSeqId		INT

	DECLARE @Check INT
	SET @Check=0

	if exists (select * from dbo.sysobjects where id = object_id(N'[ExistPriceDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [ExistPriceDetails]

	SELECT A.MRP,A.LSP,A.SR,A.CR,A.DCR,A.PrdId,MAX(A.PrdBatId) AS PrdBatId,MAX(A.BatchSeqId) AS BatchSeqId
	INTO ExistPriceDetails
	FROM
	(
		SELECT P.PrdId,P.PrdCCode,PB.PrdBatId,PB.PrdBatCode,PBDM.PriceId,PBDM.BatchSeqId,
		PBDM.PrdBatDetailValue AS MRP,PBDL.PrdBatDetailValue AS LSP,PBDS.PrdBatDetailValue AS SR,PBDC.PrdBatDetailValue AS CR,PBDD.PrdBatDetailValue AS DCR
		FROM Product P (NOLOCK) 
		INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.PrdId
		INNER JOIN ProductBatchDetails PBDM (NOLOCK) ON PB.PrdBatId=PBDM.PrdBatId 
		INNER JOIN BatchCreation BCM (NOLOCK) ON BCM.BatchSeqId=PBDM.BatchSeqId AND BCM.SlNo=PBDM.SlNo AND BCM.MRP=1
		INNER JOIN ProductBatchDetails PBDL (NOLOCK) ON PB.PrdBatId=PBDL.PrdBatId 
		INNER JOIN BatchCreation BCL (NOLOCK) ON BCL.BatchSeqId=PBDL.BatchSeqId AND BCL.SlNo=PBDL.SlNo AND BCL.ListPrice=1
		INNER JOIN ProductBatchDetails PBDS (NOLOCK) ON PB.PrdBatId=PBDS.PrdBatId 
		INNER JOIN BatchCreation BCS (NOLOCK) ON BCS.BatchSeqId=PBDS.BatchSeqId AND BCS.SlNo=PBDS.SlNo AND BCS.SelRte=1
		INNER JOIN ProductBatchDetails PBDC (NOLOCK) ON PB.PrdBatId=PBDC.PrdBatId 
		INNER JOIN BatchCreation BCC (NOLOCK) ON BCC.BatchSeqId=PBDC.BatchSeqId AND BCC.SlNo=PBDC.SlNo AND BCC.ClmRte=1
		INNER JOIN ProductBatchDetails PBDD (NOLOCK) ON PB.PrdBatId=PBDD.PrdBatId 
		INNER JOIN BatchCreation BCD (NOLOCK) ON BCD.BatchSeqId=PBDD.BatchSeqId AND BCD.SlNo=PBDD.SlNo AND BCD.RefCode='E'
		WHERE PBDM.PriceId>@Pi_ExistPriceId AND PBDL.PriceId>@Pi_ExistPriceId AND PBDS.PriceId>@Pi_ExistPriceId 
		AND PBDC.PriceId>@Pi_ExistPriceId AND PBDD.PriceId>@Pi_ExistPriceId 
		AND PBDM.DefaultPrice=1 AND PBDL.DefaultPrice=1 AND PBDS.DefaultPrice=1 AND PBDC.DefaultPrice=1 AND PBDD.DefaultPrice=1 
	) A GROUP BY A.MRP,A.LSP,A.SR,A.CR,A.DCR,A.PrdId

	DECLARE Cur_ProductBatch CURSOR
	FOR SELECT PrdId,PrdBatId,BatchSeqId,MRP,LSP,SR,CR,DCR
	FROM ExistPriceDetails (NOLOCK) 	
	ORDER BY PrdId,PrdBatId
	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId,@BatchSeqId,@MRP,@LSP,@SellRate,@ClaimRate,@DClaimRate
	WHILE @@FETCH_STATUS=0
	BEGIN
			--SELECT @PrdId,@PrdCCode,@PrdBatId,@PrdBatCode,@PriceId,@BatchSeqId,@MRP,@LSP,@SellRate,@ClaimRate,@DClaimRate
			if exists (select * from dbo.sysobjects where id = object_id(N'[ExistNewPriceDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
			drop table [ExistNewPriceDetails]

			SELECT PrdBatId,PrdBatCode,A.LSP-@LSP AS LSPChange,A.LSP AS OldLSP,A.PriceId AS OldPriceId
			INTO ExistNewPriceDetails
			FROM
			(
				SELECT P.PrdId,P.PrdCCode,PB.PrdBatId,PB.PrdBatCode,PBDL.PriceId,
				PBDL.PrdBatDetailValue AS LSP,PBDS.PrdBatDetailValue AS SR,PBDC.PrdBatDetailValue AS CR,PBDD.PrdBatDetailValue AS DCR
				FROM Product P (NOLOCK) 
				INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.PrdId 
				INNER JOIN ProductBatchDetails PBDM (NOLOCK) ON PB.PrdBatId=PBDM.PrdBatId 
				INNER JOIN BatchCreation BCM (NOLOCK) ON BCM.BatchSeqId=PBDM.BatchSeqId AND BCM.SlNo=PBDM.SlNo AND BCM.MRP=1
				INNER JOIN ProductBatchDetails PBDL (NOLOCK) ON PB.PrdBatId=PBDL.PrdBatId 
				INNER JOIN BatchCreation BCL (NOLOCK) ON BCL.BatchSeqId=PBDL.BatchSeqId AND BCL.SlNo=PBDL.SlNo AND BCL.ListPrice=1
				INNER JOIN ProductBatchDetails PBDS (NOLOCK) ON PB.PrdBatId=PBDS.PrdBatId 
				INNER JOIN BatchCreation BCS (NOLOCK) ON BCS.BatchSeqId=PBDS.BatchSeqId AND BCS.SlNo=PBDS.SlNo AND BCS.SelRte=1
				INNER JOIN ProductBatchDetails PBDC (NOLOCK) ON PB.PrdBatId=PBDC.PrdBatId 
				INNER JOIN BatchCreation BCC (NOLOCK) ON BCC.BatchSeqId=PBDC.BatchSeqId AND BCC.SlNo=PBDC.SlNo AND BCC.ClmRte=1
				INNER JOIN ProductBatchDetails PBDD (NOLOCK) ON PB.PrdBatId=PBDD.PrdBatId 
				INNER JOIN BatchCreation BCD (NOLOCK) ON BCD.BatchSeqId=PBDD.BatchSeqId AND BCD.SlNo=PBDD.SlNo AND BCD.RefCode='E'
				WHERE P.PrdId=@PrdId AND PBDM.PrdBatDetailValue=@MRP AND PBDM.DefaultPrice=1	
				AND PBDL.DefaultPrice=1 AND PBDS.DefaultPrice=1 AND PBDC.DefaultPrice=1 AND PBDD.DefaultPrice=1
			) A
			WHERE A.LSP<>@LSP OR A.SR<>@SellRate OR A.CR<>@ClaimRate OR A.DCR<>@DClaimRate

			DECLARE Cur_NewProductBatch CURSOR
			FOR SELECT PrdBatId,PrdBatCode,LSPChange,OldLSP,OldPriceId
			FROM ExistNewPriceDetails (NOLOCK)
			OPEN Cur_NewProductBatch
			FETCH NEXT FROM Cur_NewProductBatch INTO @NewPrdBatId,@NewPrdBatCode,@LSPChange,@OldLSP,@OldPriceId
			WHILE @@FETCH_STATUS=0
			BEGIN
				---SELECT @NewPrdBatId,@NewPrdBatCode,@LSPChange,@OldLSP,@OldPriceId
				SELECT @NewPriceId=dbo.Fn_GetPrimaryKeyInteger('ProductBatchDetails','PriceId',YEAR(GETDATE()),MONTH(GETDATE()))		
				UPDATE Counters SET CurrValue=@NewPriceId WHERE TabName='ProductBatchDetails' AND FldName='PriceId'
				
				UPDATE ProductBatchDetails SET DefaultPrice=0 WHERE PrdBatId=@NewPrdBatId

				UPDATE ProductBatch SET DefaultPriceId=@NewPriceId WHERE PrdBatId=@NewPrdBatId

				INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @NewPriceId,@NewPrdBatId,@NewPrdBatCode+'-'+CAST(@MRP AS NVARCHAR(20))+'-'+CAST(@LSP AS NVARCHAR(20))
				+'-'+CAST(@SellRate AS NVARCHAR(20))+'-'+CAST(@ClaimRate AS NVARCHAR(20))+'-'+CAST(@DClaimRate AS NVARCHAR(20)),
				@BatchSeqId,1,@MRP,1,1,1,1,GETDATE(),1,GETDATE()								
				UNION ALL
				SELECT @NewPriceId,@NewPrdBatId,@NewPrdBatCode+'-'+CAST(@MRP AS NVARCHAR(20))+'-'+CAST(@LSP AS NVARCHAR(20))
				+'-'+CAST(@SellRate AS NVARCHAR(20))+'-'+CAST(@ClaimRate AS NVARCHAR(20))+'-'+CAST(@DClaimRate AS NVARCHAR(20)),
				@BatchSeqId,2,@LSP,1,1,1,1,GETDATE(),1,GETDATE()
				UNION ALL				
				SELECT @NewPriceId,@NewPrdBatId,@NewPrdBatCode+'-'+CAST(@MRP AS NVARCHAR(20))+'-'+CAST(@LSP AS NVARCHAR(20))
				+'-'+CAST(@SellRate AS NVARCHAR(20))+'-'+CAST(@ClaimRate AS NVARCHAR(20))+'-'+CAST(@DClaimRate AS NVARCHAR(20)),
				@BatchSeqId,3,@SellRate,1,1,1,1,GETDATE(),1,GETDATE()
				UNION ALL				
				SELECT @NewPriceId,@NewPrdBatId,@NewPrdBatCode+'-'+CAST(@MRP AS NVARCHAR(20))+'-'+CAST(@LSP AS NVARCHAR(20))
				+'-'+CAST(@SellRate AS NVARCHAR(20))+'-'+CAST(@ClaimRate AS NVARCHAR(20))+'-'+CAST(@DClaimRate AS NVARCHAR(20)),
				@BatchSeqId,4,@ClaimRate,1,1,1,1,GETDATE(),1,GETDATE()
				UNION ALL				
				SELECT @NewPriceId,@NewPrdBatId,@NewPrdBatCode+'-'+CAST(@MRP AS NVARCHAR(20))+'-'+CAST(@LSP AS NVARCHAR(20))
				+'-'+CAST(@SellRate AS NVARCHAR(20))+'-'+CAST(@ClaimRate AS NVARCHAR(20))+'-'+CAST(@DClaimRate AS NVARCHAR(20)),
				@BatchSeqId,5,@DClaimRate,1,1,1,1,GETDATE(),1,GETDATE()	

				IF @LSPChange<>0
				BEGIN
					SELECT @StockInHand=ISNULL(SUM(PrdBatLcnSih+PrdBatLcnUih-PrdBatLcnRessih-PrdBatLcnResUih),0)
					FROM ProductBatchLocation (NOLOCK) WHERE PrdId=@PrdId AND PrdBatId=@NewPrdBatId			
					--SELECT @ValDiffRefNo,GETDATE(),@PrdId,(@StockInHand*@LSPChange),1,1,GETDATE(),1,GETDATE()
					--SELECT @StockInHand
					IF @StockInHand>0
					BEGIN
						SELECT @ValDiffRefNo = dbo.Fn_GetPrimaryKeyString('ValueDifferenceClaim','ValDiffRefNo',CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
						
						INSERT INTO ValueDifferenceClaim(ValDiffRefNo,Date,PrdId,PrdBatId,OldPriceId,NewPriceId,OldPrice,NewPrice,Qty,ValueDiff,ClaimAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@ValDiffRefNo,GETDATE(),@PrdId,@NewPrdBatId,@OldPriceId,@NewPriceId,@OldLSP,@LSP,@StockInHand,@LSPChange,@StockInHand*@LSPChange,1,1,GETDATE(),1,GETDATE())
						UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'ValueDifferenceClaim' AND FldName = 'ValDiffRefNo'
					END
				END
				FETCH NEXT FROM Cur_NewProductBatch INTO @NewPrdBatId,@NewPrdBatCode,@LSPChange,@OldLSP,@OldPriceId
			END
			CLOSE Cur_NewProductBatch
			DEALLOCATE Cur_NewProductBatch
		
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId,@BatchSeqId,@MRP,@LSP,@SellRate,@ClaimRate,@DClaimRate
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_RptCurrentStockUOMBASED')
DROP PROCEDURE  Proc_RptCurrentStockUOMBASED
GO
--EXEC Proc_RptCurrentStockUOMBASED 5,2,0,'Dabur1',0,0,1,0
--EXEC Proc_RptCurrentStockUOMBASED 5,1,5,'Nestle 2.0.0.5',1,0,1,0
CREATE  PROCEDURE [Proc_RptCurrentStockUOMBASED]
	(
		@Pi_RptId  INT,
		@Pi_UsrId  INT,
		@Pi_SnapId  INT,
		@Pi_DbName  nvarchar(50),
		@Pi_SnapRequired INT,
		@Pi_GetFromSnap  INT,
		@Pi_CurrencyId  INT,
		@Po_Errno  INT OUTPUT
	)
AS
/*********************************
* PROCEDURE : Proc_RptCurrentStockUOMBASED
* PURPOSE : To get the Current Stock details for Report
* CREATED : MURUGAN.R
* CREATED DATE : 01/09/2009
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON
	DECLARE @NewSnapId  AS INT
	DECLARE @DBNAME  AS  nvarchar(50)
	DECLARE @TblName  AS nvarchar(500)
	DECLARE @TblStruct  AS nVarchar(4000)
	DECLARE @TblFields  AS nVarchar(4000)
	DECLARE @sSql  AS  nVarChar(4000)
	DECLARE @ErrNo   AS INT
	DECLARE @PurDBName AS nVarChar(50)
	--Filter Variable
	DECLARE @CmpId          AS Int
	DECLARE @LcnId          AS Int
	DECLARE @CmpPrdCtgId  AS Int
	DECLARE @PrdCtgMainId  AS Int
	DECLARE @StockValue      AS Int
	DECLARE @DispBatch  AS Int
	DECLARE @PrdStatus       AS Int
	DECLARE @PrdBatId        AS Int
	DECLARE @PrdBatStatus       AS Int
	DECLARE @SupTaxGroupId      AS Int
	DECLARE @RtrTaxFroupId      AS Int
	DECLARE @fPrdCatPrdId       AS Int
	DECLARE @StockType       AS Int
	DECLARE @fPrdId        AS Int
	DECLARE @sStockType       AS NVARCHAR(20)
	--Till Here
	--Assgin Value for the Filter Variable
	
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @StockValue = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))
	SET @DispBatch = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
	SET @PrdBatStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))
	SET @PrdBatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
	SET @SupTaxGroupId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,18,@Pi_UsrId))
	SET @RtrTaxFroupId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,19,@Pi_UsrId))
	SET @StockType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))
	--Till Here
	--If Product Category Filter is available
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	--Till Here
	EXEC Proc_CurrentStockReportUOMBASED @Pi_RptId,@Pi_UsrId

	IF @StockType=1
	BEGIN
		SET @sStockType='Saleable'
	END
	ELSE IF @StockType=2
	BEGIN
		SET @sStockType='UnSaleable'
	END
	ELSE IF @StockType=3
	BEGIN
		SET @sStockType='Offer'
	END

	Create TABLE #RptCurrentStockUOMBASED
	(
		PrdId    INT,
		PrdDcode  NVARCHAR(100),
		PrdName   NVARCHAR(200),
		PrdBatId              INT,
		PrdBatCode   NVARCHAR(100),
		MRP                NUMERIC (38,6),
		DisplayRate         NUMERIC (38,6),
		[StockValue Saleable]       NUMERIC (38,6),
		[StockValue UnSaleable]      NUMERIC (38,6),
		[Total StockValue]         NUMERIC (38,6),
		UOMCONVERTEDQTY INT,
		ORDERID INT,
		StockingType Varchar(50),
		UOMID INT,UOMCODE VARCHAR(50)	,	
		StockType	INT
		
	)
	
	
	SET @TblName = '#RptCurrentStockUOMBASED'
	SET @TblStruct = ' PrdId      INT,
	PrdDcode    NVARCHAR(100),
	PrdName     NVARCHAR(200),
	PrdBatId           INT,
	PrdBatCode     NVARCHAR(100),
	MRP             NUMERIC (38,6),
	DisplayRate    NUMERIC (38,6),
	[StockValue Saleable]       NUMERIC (38,6),
	[StockValue UnSaleable]      NUMERIC (38,6),
	[Total StockValue]         NUMERIC (38,6),
	UOMCONVERTEDQTY INT,
	ORDERID INT,
	StockingType Varchar(50),
	UOMID INT,UOMCODE VARCHAR(50),
	StockType	INT'	
	SET @TblFields = 'PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
	[StockValue Saleable] ,[StockValue UnSaleable] ,[Total StockValue],UOMCONVERTEDQTY ,ORDERID,StockingType,UOMID,UOMCODE,[StockType]'
	IF @Pi_GetFromSnap = 1
	BEGIN
		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
		SET @DBNAME = @DBNAME
	END
	ELSE
	BEGIN
		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo =3
		SET @DBNAME = @PI_DBNAME + @DBNAME
	END
	SET @Po_Errno = 0
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data
	BEGIN
			IF @DispBatch=2
			BEGIN
				INSERT INTO #RptCurrentStockUOMBASED (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				[StockValue Saleable] ,[StockValue UnSaleable] ,[Total StockValue],UOMCONVERTEDQTY ,ORDERID,StockingType,UOMID,UOMCODE ,StockType)
				SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SELLINGRATE,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(LISTPRICE,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,				
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UNSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UNListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UNMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TOTSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TOTListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TOTMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,
				UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE,@StockType
				FROM RptCurrentStockWithUom
				WHERE
--				(CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
--				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
--				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
--				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
--				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
--				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
--				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
--				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
--				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
--				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 				
				GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
					MRP,ListPrice,SELLINGRATE,UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE
			END
			ELSE
			BEGIN
				INSERT INTO #RptCurrentStockUOMBASED (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				[StockValue Saleable] ,[StockValue UnSaleable] ,[Total StockValue],UOMCONVERTEDQTY ,ORDERID,StockingType,UOMID,UOMCODE,StockType )
				SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SELLINGRATE,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(LISTPRICE,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,				
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UNSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UNListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UNMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TOTSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TOTListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TOTMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,
					UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE,@StockType
				FROM RptCurrentStockWithUom
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 				
				GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
					MRP,ListPrice,SELLINGRATE,UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE
			END
	IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptCurrentStockUOMBASED ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+' WHERE (CmpId=(CASE '+CAST(@CmpId AS NVARCHAR(10))+' WHEN 0 THEN CmpId ELSE 0 END ) OR
			CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',4,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (LcnId=(CASE '+CAST(@LcnId AS NVARCHAR(10))+' WHEN 0 THEN LcnId ELSE 0 END ) OR
			LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',22,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdId = (CASE '+CAST(@fPrdCatPrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
			PrdId IN (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',26,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdId = (CASE'+CAST(@fPrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
			PrdId in (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',5,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdStatus=(CASE '+CAST(@PrdStatus AS NVARCHAR(10))+' WHEN 0 THEN PrdStatus ELSE 0 END ) OR
			PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',24,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (Status=(CASE '+CAST(@PrdBatStatus AS NVARCHAR(10))+' WHEN 0 THEN Status ELSE 0 END ) OR
			Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',25,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate'
			EXEC (@SSQL)
			--UPDATE #RptCurrentStockUOMBASED SET DispBatch=@DispBatch
			--PRINT 'Retrived Data From Purged Table'
		END
		IF @Pi_SnapRequired = 1
		BEGIN
			SELECT @NewSnapId = @Pi_SnapId
			EXEC Proc_SnapShot_Report @NewSnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
			@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
			SET @sSql = 'INSERT INTO [' + @DBNAME + '].dbo.' + @TblName +
			'(SnapId,UserId,RptId,' + @TblFields + ')' +
			' SELECT ' + CAST(@NewSnapId AS VARCHAR(10)) +
			' ,' + CAST(@Pi_UsrId AS VARCHAR(10)) +
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCurrentStockUOMBASED'
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		END
	END
	ELSE    --To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptCurrentStockUOMBASED ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
			' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
			' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
			' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))
			EXEC (@SSQL)
			PRINT 'Retrived Data From Snap Shot Table'
		END
		ELSE
		BEGIN
			SET @Po_Errno = 1
			PRINT 'DataBase or Table not Found'
			RETURN
		END
	END
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStockUOMBASED
	
--	IF @StockType=0
--	BEGIN
		SELECT * FROM #RptCurrentStockUOMBASED 
--	END
--	ELSE
--	BEGIN
--		SELECT * FROM #RptCurrentStockUOMBASED WHERE StockingType=@sStockType
--	END
END	
GO 

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_CurrentStockReportUOMBASED')
DROP PROCEDURE  Proc_CurrentStockReportUOMBASED
GO
-- EXEC Proc_CurrentStockReportUOMBASED 5,2 
CREATE PROCEDURE [Proc_CurrentStockReportUOMBASED]    
/************************************************************
* VIEW	: Proc_CurrentStockReportUOMBASED
* PURPOSE	: To get the Current Stock of the Products with Batch details (With Out Tax)
* CREATED BY	: MURUGAN.R
* CREATED DATE	: 01/09/2009
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
(
	@Pi_RptId AS INT,
	@Pi_UsrId AS INT
)
AS
BEGIN
	CREATE TABLE #RptCurrentStockWithUomTemp
	(
		LCNID INT,
		LCNNAME VARCHAR(100),
		PRDID INT,
		PRDDCODE VARCHAR(100),
		PRDNAME VARCHAR(150),
		PRDBATID INT,
		PRDBATCODE VARCHAR(150),
		MRP NUMERIC(36,6),
		SELLINGRATE NUMERIC(36,6),
		LISTPRICE NUMERIC(36,6),
		[SalMRP] NUMERIC(36,6),
		[SalSelRate] NUMERIC(36,6),
		[SalListPrc] NUMERIC(36,6),
		[UNMRP] NUMERIC(36,6),
		[UNSelRate] NUMERIC(36,6),
		[UNListPrc] NUMERIC(36,6),
		[TOTMRP] NUMERIC(36,6),
		[TOTSelRate] NUMERIC(36,6),
		[TOTListPrc] NUMERIC(36,6),
		STOCKONHAND INT,
		UOMID INT,
		UOMCODE VARCHAR(50),
		CONVERSIONFACTOR INT,
		STOCKINGTYPE VARCHAR(50),
		ORDERID INT,
		UOMCONVERTEDQTY INT,
		PrdStatus INT,
		Status INT,
		CmpId INT, 
		PrdCtgValMainId INT,
		CmpPrdCtgId INT,
		PrdCtgValLinkCode VarChar(100)
	)

	DECLARE @SupZeroStock AS INT
	DECLARE @DispBatch AS INT
	DECLARE @CmpId AS INT
	DECLARE @LcnId AS INT
	DECLARE @PrdStatus AS INT
	DECLARE @PrdBatStatus AS INT

	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	SET @DispBatch = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
	SET @PrdBatStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))
	
	PRINT 'start'
	--SET @DispBatch=2
	PRINT @SupZeroStock
	PRINT @CmpId
	PRINT @LcnId
	PRINT @PrdStatus
	PRINT @PrdBatStatus
	PRINT @DispBatch
	PRINT 'End'


	TRUNCATE TABLE RptCurrentStockWithUom
	IF (@DispBatch=1)
	BEGIN
		INSERT INTO #RptCurrentStockWithUomTemp
		(LCNID,LCNNAME,PRDID,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
		[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
		,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
		,CmpPrdCtgId,PrdCtgValLinkCode)
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP)  AS [SalMRP],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate))  AS [SalSelRate],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate))  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Saleable' as StockingType,
			1 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid	
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
			Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
			Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
			Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
			Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
		GROUP BY  PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
		PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status	 			
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			0   AS [SalMRP],
			0  AS [SalSelRate],
			0 AS [SalListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP)   AS [UNMRP],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate))  AS [UNSelRate],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate)) AS [UNListPrc],
			0   AS [TOTMRP],
			0  AS [TOTSelRate],
			0 AS [TOTListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Unsaleable' as StockingType,
			2 as OrderId,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode 
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 
		GROUP BY  PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
			PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status		
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			0  AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0 AS [TOTSelRate],
			0 AS [TOTListPrc],	
			SUM((PrdBatLcnFre-PrdBatLcnResFre)) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Offer' as StockingType,
			3 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 	
		GROUP BY  PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
			PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status	
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			0  AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ))   AS [TOTMRP],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate)))  AS [TOTSelRate],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate) )) AS [TOTListPrc],
			SUM(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
			(PrdBatLcnFre-PrdBatLcnResFre))) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Total StockOnHand' as StockingType,
			4 as OrderId,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode 
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 
			GROUP BY  PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
				PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status	
	END	
	ELSE IF @DispBatch=2
	BEGIN
			INSERT INTO #RptCurrentStockWithUomTemp
			(LCNID,LCNNAME,PRDID,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
			[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
			,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
			,CmpPrdCtgId,PrdCtgValLinkCode)
			SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP)  AS [SalMRP],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate))  AS [SalSelRate],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate))  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Saleable' as StockingType,
			1 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 	
					
			GROUP BY PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			0 AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP )  AS [UNMRP],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate))  AS [UNSelRate],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate)) AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'UnSaleable' as StockingType,
			2 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))	
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 			
			GROUP BY PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			0 AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnFre-PrdBatLcnResFre)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Offer' as StockingType,
			3 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 				
			GROUP BY PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR

		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			0 AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ) )  AS [TOTMRP],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate)))  AS [TOTSelRate],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate) )) AS [TOTListPrc],
			SUM(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
			(PrdBatLcnFre-PrdBatLcnResFre))) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Total StockOnHand' as StockingType,
			4 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 	
			GROUP BY PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR	
	
	END
--
--		SELECT * FROM #RptCurrentStockWithUomTemp
--	
--return	
		IF @SupZeroStock=1
		BEGIN
			INSERT INTO RptCurrentStockWithUom
			(LCNID,LCNNAME,PRDID,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
			[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
			,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
			,CmpPrdCtgId,PrdCtgValLinkCode) SELECT * FROM #RptCurrentStockWithUomTemp WHERE STOCKONHAND>0
		END
		ELSE
		BEGIN
			INSERT INTO RptCurrentStockWithUom
			(LCNID,LCNNAME,PRDID,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
			[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
			,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
			,CmpPrdCtgId,PrdCtgValLinkCode) SELECT * FROM #RptCurrentStockWithUomTemp WHERE STOCKONHAND>=0
		END

		

		
		Select Prdid,Prdbatid,Lcnid,[SalMRP],[SalSelRate],[SalListPrc]
		INTO #RptCurrentStockWithUom FROM RptCurrentStockWithUom WHERE ORDERID=1

		Update RPT1 SET RPT1.[SalMRP]=RPT.[SalMRP],RPT1.[SalSelRate]=RPT.[SalSelRate],
		RPT1.[SalListPrc]=RPT.[SalListPrc] FROM RptCurrentStockWithUom RPT1 INNER JOIN
		#RptCurrentStockWithUom RPT ON RPT1.Prdid=Rpt.Prdid
		and rpt1.Prdbatid=rpt.prdbatid and rpt1.lcnid=rpt.lcnid

		Select Prdid,Prdbatid,Lcnid,[UNMRP],[UNSelRate],[UNListPrc]
		INTO #RptCurrentStockWithUom1 FROM RptCurrentStockWithUom WHERE ORDERID=2

		Update RPT1 SET RPT1.[UNMRP]=RPT.[UNMRP],RPT1.[UNSelRate]=RPT.[UNSelRate],
		RPT1.[UNListPrc]=RPT.[UNListPrc] FROM RptCurrentStockWithUom RPT1 INNER JOIN
		#RptCurrentStockWithUom1 RPT ON RPT1.Prdid=Rpt.Prdid
		and rpt1.Prdbatid=rpt.prdbatid and rpt1.lcnid=rpt.lcnid

		Select Prdid,Prdbatid,Lcnid,[TOTMRP],[TOTSelRate],[TOTListPrc]
		INTO #RptCurrentStockWithUom4 FROM RptCurrentStockWithUom WHERE ORDERID=4

		Update RPT1 SET RPT1.[TOTMRP]=RPT.[TOTMRP],RPT1.[TOTSelRate]=RPT.[TOTSelRate],
		RPT1.[TOTListPrc]=RPT.[TOTListPrc] FROM RptCurrentStockWithUom RPT1 INNER JOIN
		#RptCurrentStockWithUom4 RPT ON RPT1.Prdid=Rpt.Prdid
		and rpt1.Prdbatid=rpt.prdbatid and rpt1.lcnid=rpt.lcnid
	
		---FIND UOM QTY

		DECLARE @Prdid AS INT
		DECLARE @Prdbatid AS INT
		DECLARE @OrderId AS INT
		DECLARE @LcnId1 AS INT
		DECLARE @Prdid1 AS INT
		DECLARE @Prdbatid1 AS INT
		DECLARE @CONVERSIONFACTOR AS INT
		DECLARE @StockOnHand AS INT
		DECLARE @UOMID AS INT
		DECLARE @Converted as INT
		DECLARE @Remainder as INT

			DECLARE CUR_UOM CURSOR
			FOR 
				SELECT DISTINCT P.PrdId,RT.Prdbatid,OrderID,StockOnHand
				FROM Product P (NOLOCK),RptCurrentStockWithUom RT (NOLOCK) WHERE P.Prdid=RT.Prdid 
				Order By P.Prdid,OrderId 
			OPEN CUR_UOM
			FETCH NEXT FROM CUR_UOM INTO @Prdid,@Prdbatid,@OrderId,@StockOnHand
			WHILE @@FETCH_STATUS=0
			BEGIN
					SET	@Converted=0
					SET @Remainder=0				
					DECLARE CUR_UOMCONVERT CURSOR
					FOR 
					SELECT Prdid,Prdbatid,UOMID,CONVERSIONFACTOR FROM RptCurrentStockWithUom (NOLOCK) WHERE PRDID=@Prdid and Prdbatid=@Prdbatid  and OrderId=@OrderId  and StockOnhand>0  and CONVERSIONFACTOR>0  Order by CONVERSIONFACTOR DESC
					OPEN CUR_UOMCONVERT
					FETCH NEXT FROM CUR_UOMCONVERT INTO  @Prdid1,@Prdbatid1,@UOMID,@CONVERSIONFACTOR
					WHILE @@FETCH_STATUS=0
					BEGIN
						IF @StockOnHand>= @CONVERSIONFACTOR
						BEGIN
							SET	@Converted=CAST(@StockOnHand/@CONVERSIONFACTOR as INT)
							SET @Remainder=CAST(@StockOnHand%@CONVERSIONFACTOR AS INT)
							SET @StockOnHand=@Remainder						
							UPDATE RptCurrentStockWithUom SET UOMCONVERTEDQTY=Isnull(@Converted,0)  WHERE PRDID=@Prdid1 and Prdbatid=@Prdbatid1 and Uomid=@UOMID and OrderId=@OrderId 
						END					
						
					FETCH NEXT FROM CUR_UOMCONVERT INTO @Prdid1,@Prdbatid1,@UOMID,@CONVERSIONFACTOR
					END	
					CLOSE CUR_UOMCONVERT
					DEALLOCATE CUR_UOMCONVERT
					SET @StockOnHand=0
			FETCH NEXT FROM CUR_UOM INTO @Prdid,@Prdbatid,@OrderId,@StockOnHand
			END	
			CLOSE CUR_UOM
			DEALLOCATE CUR_UOM

	--	SELECT * FROM RptCurrentStockWithUom
		--TILL HERE
END  
GO 

IF  EXISTS (SELECT * FROM sysobjects WHERE xtype='V' AND name='View_CurrentStockReport')
DROP VIEW [View_CurrentStockReport]
GO 
CREATE View [View_CurrentStockReport]
/************************************************************
* VIEW	: View_CurrentStockReport
* PURPOSE	: To get the Current Stock of the Products with Batch details
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 26/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode,
	Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,
	DPH.SellingRate+TxRpt.SellingTaxAmount AS SelRate,DPH.PurchaseRate+TxRpt.PurchaseTaxAmount AS ListPrice,
	(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
	(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
	(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
	((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
	(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
	(PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP  AS SalMRP,
	(PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP  AS UnSalMRP,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ) AS TotMRP,
	(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS SalSelRate,
	(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS UnSalSelRate,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate+TxRpt.SellingTaxAmount) ) AS TotSelRate,
	(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS SalListPrice,
	(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS UnSalListPrice,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount) ) AS TotListPrice,
	Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,TxRpt.UsrId
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
	ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
	DefaultPriceHistory DPH (NOLOCK) ,
	TaxForReport TxRpt (NOLOCK),
	ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
	AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
	AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
	AND TxRpt.PrdBatId=PrdBat.PrdBatId  AND TxRpt.PrdId=Prd.PrdId AND TxRpt.Rptid=5
	--AND PBDM.DefaultPrice=1  AND PBDR.DefaultPrice=1  AND PBDL.DefaultPrice=1
	--AND PrdBat.DefaultPriceId=PBDM.PriceId  AND PrdBat.DefaultPriceId=PBDR.PriceId  AND PrdBat.DefaultPriceId=PBDL.PriceId
GO


IF  EXISTS (SELECT * FROM sysobjects WHERE xtype='V' AND name='View_CurrentStockReportNTax')
DROP VIEW [View_CurrentStockReportNTax]
GO 
CREATE View [View_CurrentStockReportNTax]
/************************************************************
* VIEW	: View_CurrentStockReportNTax
* PURPOSE	: To get the Current Stock of the Products with Batch details (With Out Tax)
* CREATED BY	: Srivatchan
* CREATED DATE	: 24/07/2009
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode,
	Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,
	--DPH.SellingRate+TxRpt.SellingTaxAmount AS SelRate,
	DPH.SellingRate AS SelRate,
	--DPH.PurchaseRate+TxRpt.PurchaseTaxAmount AS ListPrice,
	DPH.PurchaseRate AS ListPrice,
	(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
	(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
	(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
	((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
	(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
	(PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP  AS SalMRP,
	(PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP  AS UnSalMRP,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ) AS TotMRP,
	--(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS SalSelRate,
	(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate)  AS SalSelRate,
	--(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS UnSalSelRate,
	(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate)  AS UnSalSelRate,
	--(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate+TxRpt.SellingTaxAmount) ) AS TotSelRate,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate) ) AS TotSelRate,
	--(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS SalListPrice,
	(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate)  AS SalListPrice,
	(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate)  AS UnSalListPrice,
	--(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS UnSalListPrice,
	--(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount) ) AS TotListPrice,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate) ) AS TotListPrice,
	Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
	ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
	DefaultPriceHistory DPH (NOLOCK) ,
	--TaxForReport TxRpt (NOLOCK),
	ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
	AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
	AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
	--AND TxRpt.PrdBatId=PrdBat.PrdBatId  AND TxRpt.PrdId=Prd.PrdId AND TxRpt.Rptid=5
	--AND PBDM.DefaultPrice=1  AND PBDR.DefaultPrice=1  AND PBDL.DefaultPrice=1
	--AND PrdBat.DefaultPriceId=PBDM.PriceId  AND PrdBat.DefaultPriceId=PBDR.PriceId  AND PrdBat.DefaultPriceId=PBDL.PriceId
GO


IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_RptReportToBill')
DROP PROCEDURE  Proc_RptReportToBill
GO
-- EXEC Proc_RptReportToBill 2,16,0,1
CREATE PROCEDURE [Proc_RptReportToBill]
(
	@Pi_UsrId INT,
	@Pi_RptId INT,
	@Pi_Sel INT,
	@Pi_InvDC INT
)
AS
/***************************************************************************************************
* PROCEDURE: Proc_RptReportToBill
* PURPOSE: General Procedure
* NOTES:
* CREATED: Nanda	 
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
* 01.10.2009		Panneer	   Checked in Invoice Type Condition
****************************************************************************************************/


SET NOCOUNT ON
BEGIN
	--Filter Variable
	DECLARE @FromBillNo AS  BIGINT
	DECLARE @ToBillNo   AS  BIGINT
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SelBillNo  AS  BIGINT
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME

	--Assgin Value for the Filter Variable
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @FromBillNo = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @TOBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	SET @SelBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId))
	SET @FromDate =(SELECT  TOP 1 dSELECTed FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSELECTed FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))

	IF @Pi_Sel = 1
	BEGIN
		 SELECT @FromBillNo = Min(SalId) FROM SalesInvoice
		 SELECT @ToBillNo = Max(SalId) FROM SalesInvoice
        
	END

	DELETE from RptBillToPrint where [UsrId] = @Pi_UsrId

	IF @Pi_InvDC=2
	BEGIN	
		INSERT INTO  RptBillToPrint
		SELECT DISTINCT [SalInvNo],@Pi_UsrId FROM SalesInvoice
		WHERE
		 (SalId=(CASE @SelBillNo WHEN 0 THEN SalId ELSE 0 END) OR
							SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId)))
		AND
		 (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
							SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		AND
		 (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
							RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		AND
		 (DlvRMId=(CASE @RMId WHEN 0 THEN DlvRMId ELSE 0 END) OR
							DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)))
		AND (SalId BETWEEN @FromBillNo AND @ToBillNo)

		AND (SalInvDate BETWEEN @FromDate AND @ToDate)
		AND InvType=0
	END
	ELSE
	BEGIN
		--->Added By Nanda on 24/09/2009
		IF @Pi_Sel = 0
		BEGIN
			PRINT 'Start'
			DECLARE @FromId INT
			DECLARE @ToId INT
			DECLARE @StartBill AS nvarchar(100)
			DECLARE @EndBill AS nvarchar(500)

			DECLARE @FromSeq INT
			DECLARE @ToSeq INT

			SELECT @FromId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=14 
			SELECT @ToId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=15
			
			PRINT 'ID'			
			PRINT @FromId
			PRINT @ToId
			PRINT 'ID End'
			
			SELECT  @StartBill= SalInvno FROM SalesInvoice WHERE SalId=@FromId
			SELECT  @EndBill=	SalInvno FROM SalesInvoice WHERE SalId=@ToId		

			SELECT @FromSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@FromId
			SELECT @ToSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@ToId			

			INSERT INTO  RptBillToPrint		
			SELECT DISTINCT [SalInvNo],@Pi_UsrId FROM SalesInvoice
			WHERE
			 (SalId IN (SELECT SalId FROM SalInvoiceDeliveryChallan WHERE SeqNo BETWEEN @FromSeq AND @ToSeq)) OR 
			 (SalId IN (SELECT SalId FROM SalesInvoice WHERE SalInvno BETWEEN @StartBill AND @EndBill))	
			AND
			 (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
								SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND
			 (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
								RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND
			 (DlvRMId=(CASE @RMId WHEN 0 THEN DlvRMId ELSE 0 END) OR
								DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)))
			AND (SalInvDate BETWEEN @FromDate AND @ToDate)

			AND InvType=1			
		END
		ELSE--->Till Here
		BEGIN
			INSERT INTO  RptBillToPrint		
			SELECT DISTINCT [SalInvNo],@Pi_UsrId FROM SalesInvoice
			WHERE
			 (SalId=(CASE @SelBillNo WHEN 0 THEN SalId ELSE 0 END) OR
								SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId)))
			AND
			 (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
								SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND
			 (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
								RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND
			 (DlvRMId=(CASE @RMId WHEN 0 THEN DlvRMId ELSE 0 END) OR
								DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)))
			AND (SalId BETWEEN @FromBillNo AND @ToBillNo)
			AND (SalInvDate BETWEEN @FromDate AND @ToDate)
			AND InvType=1
		END
	END
END
GO

--SRF-Nanda-151-001

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyQPSSchemeInBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyQPSSchemeInBill]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme WHERE SchId=28
--SELECT * FROM BillAppliedSchemeHd
--DELETE FROM BillAppliedSchemeHd
EXEC Proc_ApplyQPSSchemeInBill 151,947,0,2,2
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd WHERE TransId = 2 And UsrId = 1
SELECT * FROM BillAppliedSchemeHd
--SELECT * FROM SalesInvoiceQPSCumulative(NOLOCK) WHERE SchId=30
--SELECT * FROM SchemeMaster
--SELECT * FROM Retailer
ROLLBACK TRANSACTION
*/
CREATE        Procedure [dbo].[Proc_ApplyQPSSchemeInBill]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT		
)
AS
/*********************************
* PROCEDURE	: Proc_ApplyQPSSchemeInBill
* PURPOSE	: To Apply the QPS Scheme and Get the Scheme Details for the Selected Scheme
* CREATED	: Thrinath
* CREATED DATE	: 31/05/2007
* NOTE		: General SP for Returning the Scheme Details for the Selected QPS Scheme
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN		
	DECLARE @SchType		INT
	DECLARE @SchCode		nVarChar(40)
	DECLARE @BatchLevel		INT
	DECLARE @FlexiSch		INT
	DECLARE @FlexiSchType		INT
	DECLARE @CombiScheme		INT
	DECLARE @SchLevelId		INT
	DECLARE @ProRata		INT
	DECLARE @Qps			INT
	DECLARE @QPSReset		INT
	DECLARE @QPSResetAvail		INT
	DECLARE @PurOfEveryReq		INT
	DECLARE @SchemeBudget		NUMERIC(38,6)
	DECLARE @SlabId			INT
	DECLARE @NoOfTimes		NUMERIC(38,6)
	DECLARE @GrossAmount		NUMERIC(38,6)
	DECLARE @TotalValue		NUMERIC(38,6)
	DECLARE @SlabAssginValue	NUMERIC(38,6)
	DECLARE @SchemeLvlMode		INT
	DECLARE @PrdIdRem		INT
	DECLARE @PrdBatIdRem		INT
	DECLARE @PrdCtgValMainIdRem	INT
	DECLARE @FrmSchAchRem		NUMERIC(38,6)
	DECLARE @FrmUomAchRem		INT
	DECLARE @FromQtyRem		NUMERIC(38,6)
	DECLARE @UomIdRem		INT
	DECLARE @AssignQty 		NUMERIC(38,6)
	DECLARE @AssignAmount 		NUMERIC(38,6)
	DECLARE @AssignKG 		NUMERIC(38,6)
	DECLARE @AssignLitre 		NUMERIC(38,6)
	DECLARE @BudgetUtilized		NUMERIC(38,6)
	DECLARE @BillDate		DATETIME
	DECLARE @FrmValidDate		DateTime
	DECLARE @ToValidDate		DateTime
	DECLARE @QPSBasedOn		INT
	DECLARE @SchValidTill	DATETIME
	DECLARE @SchValidFrom	DATETIME

	DECLARE @RangeBase		INT

	DECLARE @TempBilled TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		SchemeOnQty 		NUMERIC(38,0),
		SchemeOnAmount		NUMERIC(38,6),
		SchemeOnKG		NUMERIC(38,6),
		SchemeOnLitre		NUMERIC(38,6),
		SchId 			INT
	)
	DECLARE @TempBilled1 TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		SchemeOnQty 		NUMERIC(38,0),
		SchemeOnAmount		NUMERIC(38,6),
		SchemeOnKG		NUMERIC(38,6),
		SchemeOnLitre		NUMERIC(38,6),
		SchId 			INT
	)
	DECLARE @TempRedeem TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		SchemeOnQty 		NUMERIC(38,0),
		SchemeOnAmount		NUMERIC(38,6),
		SchemeOnKG		NUMERIC(38,6),
		SchemeOnLitre		NUMERIC(38,6),
		SchId 			INT
	)
	DECLARE @TempHier TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT
	)
	DECLARE @TempBilledAch TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		ToSchAch		NUMERIC(38,6),
		ToUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT,
		ToQty			NUMERIC(38,6),
		ToUomId			INT
	)
	DECLARE @TempBilledQpsReset TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		ToSchAch		NUMERIC(38,6),
		ToUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT,
		ToQty			NUMERIC(38,6),
		ToUomId			INT
	)
	DECLARE @TempSchSlabAmt TABLE
	(
		ForEveryQty		NUMERIC(38,6),
		ForEveryUomId		INT,
		DiscPer			NUMERIC(10,6),
		FlatAmt			NUMERIC(38,6),
		Points			INT,
		FlxDisc			TINYINT,
		FlxValueDisc		TINYINT,
		FlxFreePrd		TINYINT,
		FlxGiftPrd		TINYINT,
		FlxPoints		TINYINT
	)
	DECLARE @TempSchSlabFree TABLE
	(
		ForEveryQty		NUMERIC(38,6),
		ForEveryUomId		INT,
		FreePrdId		INT,
		FreeQty			INT
	)
	DECLARE @TempSchSlabGift TABLE
	(
		ForEveryQty		NUMERIC(38,6),
		ForEveryUomId		INT,
		GiftPrdId		INT,
		GiftQty			INT
	)
	DECLARE  @BillAppliedSchemeHd TABLE
	(
		SchId			INT,
		SchCode 		NVARCHAR (40) ,
		FlexiSch 		TINYINT,
		FlexiSchType 		TINYINT,
		SlabId 			INT,
		SchemeAmount 		NUMERIC(38, 6),
		SchemeDiscount 		NUMERIC(38, 6),
		Points 			INT ,
		FlxDisc 		TINYINT,
		FlxValueDisc 		TINYINT,
		FlxFreePrd 		TINYINT,
		FlxGiftPrd 		TINYINT,
		FlxPoints 		TINYINT,
		FreePrdId 		INT,
		FreePrdBatId 		INT,
		FreeToBeGiven 		INT,
		GiftPrdId 		INT,
		GiftPrdBatId 		INT,
		GiftToBeGiven 		INT,
		NoOfTimes 		NUMERIC(38, 6),
		IsSelected 		TINYINT,
		SchBudget 		NUMERIC(38, 6),
		BudgetUtilized 		NUMERIC(38, 6),
		TransId 		TINYINT,
		Usrid 			INT,
		PrdId			INT,
		PrdBatId		INT
	)
	DECLARE @MoreBatch TABLE
	(
		SchId		INT,
		SlabId		INT,
		PrdId		INT,
		PrdCnt		INT,
		PrdBatCnt	INT
	)
	DECLARE @TempBillAppliedSchemeHd TABLE
	(
		SchId		int,
		SchCode		nvarchar(50),
		FlexiSch	tinyint,
		FlexiSchType	tinyint,
		SlabId		int,
		SchemeAmount	numeric(32,6),
		SchemeDiscount	numeric(32,6),
		Points		int,
		FlxDisc		tinyint,
		FlxValueDisc	tinyint,
		FlxFreePrd	tinyint,
		FlxGiftPrd	tinyint,
		FlxPoints	tinyint,
		FreePrdId	int,
		FreePrdBatId	int,
		FreeToBeGiven	int,
		GiftPrdId	int,
		GiftPrdBatId	int,
		GiftToBeGiven	int,
		NoOfTimes	numeric(32,6),
		IsSelected	tinyint,
		SchBudget	numeric(32,6),
		BudgetUtilized	numeric(32,6),
		TransId		tinyint,
		Usrid		int,
		PrdId		int,
		PrdBatId	int,
		SchType		int
	)
	DECLARE @NotExitProduct TABLE
	(
		Schid INT,
		Rtrid INT,
		SchemeOnQty INT,
		SchemeOnAmount Numeric(32,4),
		SchemeOnKG  NUMERIC(38,6),
		SchemeOnLitre  NUMERIC(38,6)
		
	)
	--NNN
	DECLARE @QPSGivenFlat TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	SELECT @SchCode = SchCode,@SchType = SchType,@BatchLevel = BatchLevel,@FlexiSch = FlexiSch,@RangeBase=[Range],
		@FlexiSchType = FlexiSchType,@CombiScheme = CombiSch,@SchLevelId = SchLevelId,@ProRata = ProRata,
		@Qps = QPS,@QPSReset = QPSReset,@SchemeBudget = Budget,@PurOfEveryReq = PurofEvery,
		@SchemeLvlMode = SchemeLvlMode,@QPSBasedOn=ApyQPSSch,@SchValidFrom=SchValidFrom,@SchValidTill=SchValidTill
	FROM SchemeMaster WHERE SchId = @Pi_SchId AND MasterType=1
	IF Exists (SELECT * FROM SalesInvoice WHERE SalId = @Pi_SalId)
		SELECT @BillDate = SalInvDate FROM SalesInvoice WHERE SalId = @Pi_SalId
	ELSE
		SET @BillDate = CONVERT(VARCHAR(10),GETDATE(),121)
	IF Exists(SELECT * FROM SchemeMaster WHERE SchId = @Pi_SchId AND SchValidTill >= @BillDate)
	BEGIN
		--From the current Bill
		-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
		SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,
			ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,
			ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
			WHEN 3 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnKg,
			ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
			WHEN 5 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnLitre,@Pi_SchId
			FROM BilledPrdHdForScheme A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
			A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
			INNER JOIN Product C ON A.PrdId = C.PrdId
			INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
			WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId
			GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
--		SELECT '1',* FROM @TempBilled1
	END
	IF @QPS <> 0
	BEGIN
		--From all the Bills
		--To Add the Cumulative Qty
		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
		SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.SumQty),0) AS SchemeOnQty,
			ISNULL(SUM(A.SumValue),0) AS SchemeOnAmount,
			ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(SumInKG),0)
			WHEN 3 THEN ISNULL(SUM(SumInKG),0) END,0) AS SchemeOnKg,
			ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(SumInLitre),0)
			WHEN 5 THEN ISNULL(SUM(SumInLitre),0) END,0) AS SchemeOnLitre,@Pi_SchId
			FROM SalesInvoiceQPSCumulative A (NOLOCK)
			INNER JOIN Product C ON A.PrdId = C.PrdId
			INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
			WHERE A.SchId = @Pi_SchId AND A.RtrId = @Pi_RtrId
			GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
--		SELECT '2',* FROM @TempBilled1
--		IF @QPSBasedOn<>1
--		BEGIN
			--To Subtract Non Deliverbill
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				Select SIP.Prdid,SIP.Prdbatid,
				-1 *ISNULL(SUM(SIP.BaseQty),0) AS SchemeOnQty,
				-1 *ISNULL(SUM(SIP.BaseQty *PrdUom1EditedSelRate),0) AS SchemeOnAmount,
				-1 *ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0)/1000
				WHEN 3 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0) END,0) AS SchemeOnKg,
				-1 *ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0)/1000
				WHEN 5 THEN ISNULL(SUM(PrdWgt * SIP.BaseQty),0) END,0) AS SchemeOnLitre,@Pi_SchId
				From SalesInvoice SI (NOLOCK)
				INNER JOIN SalesInvoiceProduct SIP (NOLOCK)	ON SI.Salid=SIP.Salid AND SI.SalInvdate BETWEEN @SchValidFrom AND @SchValidTill
				INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON SIP.PrdId = B.PrdId
				AND SIP.PrdBatId = CASE B.PrdBatId WHEN 0 THEN SIP.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C (NOLOCK) ON SIP.PrdId = C.PrdId
				INNER JOIN ProductUnit D (NOLOCK) ON C.PrdUnitId = D.PrdUnitId
				WHERE Dlvsts in(1,2) and Rtrid=@Pi_RtrId and SI.Salid <>@Pi_SalId
				and SI.Salid Not in(Select Salid from SalesInvoiceSchemeQPSGiven (NOLOCK) where Salid<>@Pi_SalId and  schid=@Pi_SchId)
				Group by SIP.Prdid,SIP.Prdbatid,D.PrdUnitId
--		END
--		SELECT '3',* FROM @TempBilled1
		IF @Pi_SalId<>0
		BEGIN
			--To Subtract the Billed Qty in Edit Mode
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,-1 * ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,
				-1 * ISNULL(SUM(A.BaseQty * A.PrdUnitSelRate),0) AS SchemeOnAmount,
				-1 * ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
				WHEN 3 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnKg,
				-1 * ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
				WHEN 5 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnLitre,@Pi_SchId
				FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C ON A.PrdId = C.PrdId
				INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
				WHERE A.SalId = @Pi_SalId
				GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
		END
--		SELECT '4',* FROM @TempBilled1
		--NNN
		IF @QPSBasedOn=1 OR (@QPSBasedOn<>1 AND @FlexiSch=1)
		BEGIN
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
			SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
				-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
				-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
				FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
				AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
		END
--		SELECT '5',* FROM @TempBilled1
		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SumQty),0) AS SchemeOnQty,
			ISNULL(SUM(SumValue),0) AS SchemeOnAmount,ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
			ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
			FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
			GROUP BY PrdId,PrdBatId
--		SELECT * FROM @TempBilled1
	END
--	SELECT '6',* FROM @TempBilled1
	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
		ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
		GROUP BY PrdId,PrdBatId,SchId
	--To Get the Product Details for the Selected Level
	IF @SchemeLvlMode = 0
	BEGIN
		SELECT @SchLevelId = SUBSTRING(LevelName,6,LEN(LevelName)) from ProductCategoryLevel
			WHERE CmpPrdCtgId = @SchLevelId
		
		INSERT INTO @TempHier (PrdId,PrdBatId,PrdCtgValMainId)
		SELECT DISTINCT D.PrdId,E.PrdBatId,C.PrdCtgValMainId FROM ProductCategoryValue C
		INNER JOIN ( Select LEFT(PrdCtgValLinkCode,@SchLevelId*5) as PrdCtgValLinkCode,A.Prdid from Product A
		INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId
		INNER JOIN @TempBilled F ON A.PrdId = F.PrdId) AS D ON
		D.PrdCtgValLinkCode = C.PrdCtgValLinkCode INNER JOIN ProductBatch E
		ON D.PrdId = E.PrdId
	END
	ELSE
	BEGIN
		INSERT INTO @TempHier (PrdId,PrdBatId,PrdCtgValMainId)
		SELECT DISTINCT A.PrdId As PrdId,E.PrdBatId,D.PrdCtgValMainId FROM @TempBilled A
		INNER JOIN UdcDetails C on C.MasterRecordId =A.PrdId
		INNER JOIN SchemeProducts D ON A.SchId = D.SchId AND
		D.PrdCtgValMainId = C.UDCUniqueId
		INNER JOIN ProductBatch E ON A.PrdId = E.PrdId
		WHERE A.SchId=@Pi_Schid
	END
	--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
	INSERT INTO @TempBilledAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,
	FromQty,UomId,ToQty,ToUomId)
	SELECT G.PrdId,G.PrdBatId,G.PrdCtgValMainId,ISNULL(CASE @SchType
	WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
	WHEN 2 THEN SUM(SchemeOnAmount)
	WHEN 3 THEN (CASE A.UomId
			WHEN 2 THEN SUM(SchemeOnKg)*1000
			WHEN 3 THEN SUM(SchemeOnKg)
			WHEN 4 THEN SUM(SchemeOnLitre)*1000
			WHEN 5 THEN SUM(SchemeOnLitre)	END)
		END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
	ISNULL(CASE @SchType
	WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
	WHEN 2 THEN SUM(SchemeOnAmount)
	WHEN 3 THEN (CASE A.ToUomId
			WHEN 2 THEN SUM(SchemeOnKg) * 1000
			WHEN 3 THEN SUM(SchemeOnKg)
			WHEN 4 THEN SUM(SchemeOnLitre) * 1000
			WHEN 5 THEN SUM(SchemeOnLitre)	END)
		END,0) AS ToSchAch,A.ToUomId AS ToUomAch,
	A.Slabid,(A.PurQty + A.FromQty) as FromQty,A.UomId,A.ToQty,A.ToUomId
	FROM SchemeSlabs A
	INNER JOIN @TempBilled B ON A.SchId = B.SchId AND A.SchId = @Pi_SchId
	INNER JOIN Product C ON B.PrdId = C.PrdId
	INNER JOIN @TempHier G ON B.PrdId = G.PrdId AND B.PrdBatId = G.PrdBatId
	LEFT OUTER JOIN UomGroup D ON D.UomGroupId = C.UomGroupId AND D.UomId = A.UomId
	LEFT OUTER JOIN UomGroup E ON E.UomGroupId = C.UomGroupId AND E.UomId = A.UomId
	GROUP BY G.PrdId,G.PrdBatId,G.PrdCtgValMainId,A.UomId,A.Slabid,A.PurQty,A.FromQty,A.ToUomId,A.ToQty
	INSERT INTO @TempBilledQpsReset(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,
	FromQty,UomId,ToQty,ToUomId)
	SELECT PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,
	FromQty,UomId,ToQty,ToUomId FROM @TempBilledAch
	SET @QPSResetAvail = 0
--	SELECT * FROM @TempBilled
--	SELECT 'N',@QPSReset
	IF @QPSReset <> 0
	BEGIN
		--Select the Applicable Slab for the Scheme
		SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
			INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId AND A.PrdId = B.PrdId
			AND A.PrdBatId = B.PrdBatId AND A.PrdCtgValMainId = B.PrdCtgValMainId
			GROUP BY A.SlabId,B.FromQty,B.ToQty
			HAVING SUM(A.FrmSchAch) >= B.FromQty AND
			SUM(A.ToSchAch) <= (CASE B.ToQty WHEN 0 THEN SUM(A.ToSchAch) ELSE B.ToQty END)
			ORDER BY A.SlabId DESC) As SlabId
		IF @SlabId = (SELECT MAX(SlabId) FROM SchemeSlabs WHERE SchId = @Pi_SchId)
		BEGIN
			SET @QPSResetAvail = 1
		END
		SELECT @SlabId
	END
	SELECT @TotalValue = ISNULL(SUM(FrmSchAch),0) FROM @TempBilledAch WHERE SlabId =1
	
--	SELECT 'N',@QPSResetAvail
	IF @QPSResetAvail = 1
	BEGIN
		IF EXISTS (SELECT SlabId FROM SchemeSlabs WHERE SchId = @Pi_SchId AND SlabId = @SlabId
				AND ToQty > 0)
		BEGIN
			IF EXISTS (SELECT SlabId FROM SchemeSlabs WHERE SchId = @Pi_SchId AND SlabId = @SlabId
				AND ToQty < @TotalValue)
			BEGIN
				SELECT @SlabAssginValue = ToQty FROM SchemeSlabs WHERE SchId = @Pi_SchId
					AND SlabId = @SlabId
			END
			ELSE
			BEGIN
				SELECT @SlabAssginValue = @TotalValue
			END
		END
		ELSE
		BEGIN
			SELECT @SlabAssginValue = (PurQty + FromQty) FROM SchemeSlabs WHERE SchId = @Pi_SchId
					AND SlabId = @SlabId
		END
	END
	ELSE
	BEGIN
		SELECT @SlabAssginValue = @TotalValue
	END
	WHILE (@TotalValue) > 0
	BEGIN
		DELETE FROM @TempRedeem
		--Select the Applicable Slab for the Scheme
		SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
			INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId
			GROUP BY A.SlabId,B.FromQty,B.ToQty
			HAVING @SlabAssginValue >= B.FromQty AND
			@SlabAssginValue <= (CASE B.ToQty WHEN 0 THEN @SlabAssginValue ELSE B.ToQty END)
			ORDER BY A.SlabId DESC) As SlabId
		IF ISNULL(@SlabId,0) = 0
		BEGIN
			SET @TotalValue = 0
			SET @SlabAssginValue = 0
		END
		--Store the Slab Amount Details into a temp table
		INSERT INTO @TempSchSlabAmt (ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,
			FlxFreePrd,FlxGiftPrd,FlxPoints)
		SELECT ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints
			FROM SchemeSlabs WHERE Schid = @Pi_SchId And SlabId = @SlabId
		
		--Store the Slab Free Product Details into a temp table
		INSERT INTO @TempSchSlabFree(ForEveryQty,ForEveryUomId,FreePrdId,FreeQty)
		SELECT A.ForEveryQty,A.ForEveryUomId,B.PrdId,B.FreeQty From
			SchemeSlabs A INNER JOIN SchemeSlabFrePrds B ON A.Schid = B.Schid
			AND A.SlabId = B.SlabId INNER JOIN Product C ON B.PrdId = C.PrdId
			WHERE A.Schid = @Pi_SchId And A.SlabId = @SlabId AND C.PrdType <> 4
		
		--Store the Slab Gift Product Details into a temp table
		INSERT INTO @TempSchSlabGift(ForEveryQty,ForEveryUomId,GiftPrdId,GiftQty)
		SELECT A.ForEveryQty,A.ForEveryUomId,B.PrdId,B.FreeQty From
			SchemeSlabs A INNER JOIN SchemeSlabFrePrds B ON A.Schid = B.Schid
			AND A.SlabId = B.SlabId INNER JOIN Product C ON B.PrdId = C.PrdId
			WHERE A.Schid = @Pi_SchId And A.SlabId = @SlabId AND C.PrdType = 4
		--To Get the Number of Times the Scheme should apply
		IF @PurOfEveryReq = 0
		BEGIN
			SET @NoOfTimes = 1
		END
		ELSE
		BEGIN
			SELECT @NoOfTimes = @SlabAssginValue / (CASE B.ForEveryQty WHEN 0 THEN 1 ELSE B.ForEveryQty END) FROM
				@TempBilledAch A INNER JOIN @TempSchSlabAmt B ON A.SlabId = @SlabId
			IF @ProRata = 0
			BEGIN
				SET @NoOfTimes = FLOOR(@NoOfTimes)	
			END
			IF @ProRata = 1
			BEGIN
				SET @NoOfTimes = ROUND(@NoOfTimes,0)
			END
			IF @ProRata = 2
			BEGIN	
				SET @NoOfTimes = ROUND(@NoOfTimes,6)
			END
		END
--		SELECT 'SSSS',* FROM @TempBilledAch
		
		--->Qty Based
		IF @SchType = 1
		BEGIN		
			DECLARE Cur_Redeem Cursor For
				SELECT PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,
					FromQty,UomId FROM @TempBilledAch
					WHERE SlabId = @SlabId ORDER BY FrmSchAch Desc
			OPEN Cur_Redeem
			FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
				@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
			WHILE @@FETCH_STATUS =0
			BEGIN
				SELECT @SlabAssginValue
				WHILE @SlabAssginValue > CAST(0 AS NUMERIC(38,6))
				BEGIN
					SET @AssignQty  = 0
					SET @AssignAmount = 0
					SET @AssignKG = 0
					SET @AssignLitre = 0
					SELECT @SlabAssginValue
					SELECT @FrmSchAchRem
					IF @SlabAssginValue > @FrmSchAchRem
					BEGIN
						SET @TotalValue = @TotalValue - @FrmSchAchRem
						UPDATE @TempBilledAch Set FrmSchach = FrmSchAch - @FrmSchAchRem,
							ToSchAch = ToSchAch - @FrmSchAchRem
							WHERE PrdId = @PrdIdRem AND PrdBatId = @PrdBatIdRem AND
							PrdCtgValMainId = @PrdCtgValMainIdRem
						SELECT @AssignQty = @FrmSchAchRem * ConversionFactor FROM
							Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
							AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
					END
					ELSE
					BEGIN
						SET @TotalValue = @TotalValue - @SlabAssginValue
						UPDATE @TempBilledAch Set FrmSchach = FrmSchAch - @SlabAssginValue,
							ToSchAch = ToSchAch - @SlabAssginValue
							WHERE PrdId = @PrdIdRem AND PrdBatId = @PrdBatIdRem AND
							PrdCtgValMainId = @PrdCtgValMainIdRem
						SELECT @AssignQty = @SlabAssginValue * ConversionFactor FROM
							Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
							AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
					END
					SET @SlabAssginValue = @SlabAssginValue - @FrmSchAchRem
					UPDATE @TempBilledQPSReset Set FrmSchach = FrmSchAch - @FrmSchAchRem
						WHERE PrdId = @PrdIdRem AND PrdBatId = @PrdBatIdRem AND
						PrdCtgValMainId = @PrdCtgValMainIdRem
					SET @AssignAmount = (SELECT TOP 1 (D.PrdBatDetailValue * @AssignQty)
						FROM ProductBatch A (NOLOCK) INNER JOIN
						ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatId
							INNER JOIN BatchCreation E (NOLOCK)
							ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo
							AND E.SelRte = 1 WHERE A.PrdBatId = @PrdBatIdRem)
					SET @AssignKG = (SELECT CASE PrdUnitId WHEN 2 THEN
						(PrdWgt * @AssignQty / 1000) WHEN 3 THEN
						(PrdWgt * @AssignQty) ELSE
						0 END FROM Product WHERE PrdId = @PrdIdRem )
					SET @AssignLitre = (SELECT CASE PrdUnitId WHEN 4 THEN
						(PrdWgt * @AssignQty / 1000) WHEN 5 THEN
						(PrdWgt * @AssignQty) ELSE
						0 END FROM Product WHERE PrdId = @PrdIdRem )
					INSERT INTO @TempRedeem(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,
						SchemeOnKG,SchemeOnLitre,SchId)
					SELECT @PrdIdRem,@PrdBatIdRem,@AssignQty,@AssignAmount,
						@AssignKG,@AssignLitre,@Pi_SchId
					IF EXISTS (SELECT PrdId From @TempBilledAch WHERE PrdId = @PrdIdRem AND
						PrdBatId = @PrdBatIdRem AND PrdCtgValMainId = @PrdCtgValMainIdRem
						AND SlabId = @SlabId AND FrmSchach <= 0)
							BREAK
					ELSE
							CONTINUE
				END
				FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
				@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
				@UomIdRem
			END
			CLOSE Cur_Redeem
			DEALLOCATE Cur_Redeem
		END
		--->Amt Based
		IF @SchType = 2
		BEGIN
			DECLARE Cur_Redeem Cursor For
				SELECT PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,
					FromQty,UomId FROM @TempBilledAch
					WHERE SlabId = @SlabId ORDER BY FrmSchAch Desc
			OPEN Cur_Redeem
			FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
				@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
			WHILE @@FETCH_STATUS =0
			BEGIN
--				SELECT 'Slab',@SlabAssginValue 
--				SELECT 'Slab',* FROM BillAppliedSchemeHd
				WHILE @SlabAssginValue > CAST(0 AS NUMERIC(38,6))
				BEGIN
					SET @AssignQty  = 0
					SET @AssignAmount = 0
					SET @AssignKG = 0
					SET @AssignLitre = 0
					IF @SlabAssginValue > @FrmSchAchRem
					BEGIN
						SET @TotalValue = @TotalValue - @FrmSchAchRem
						UPDATE @TempBilledAch Set FrmSchach = FrmSchAch - @FrmSchAchRem,
							ToSchAch = ToSchAch - @FrmSchAchRem
							WHERE PrdId = @PrdIdRem AND PrdBatId = @PrdBatIdRem AND
							PrdCtgValMainId = @PrdCtgValMainIdRem
						SET @AssignAmount = @FrmSchAchRem
					END
					ELSE
					BEGIN
						SET @TotalValue = @TotalValue - @SlabAssginValue
						UPDATE @TempBilledAch Set FrmSchach = FrmSchAch - @SlabAssginValue,
							ToSchAch = ToSchAch - @SlabAssginValue
							WHERE PrdId = @PrdIdRem AND PrdBatId = @PrdBatIdRem AND
							PrdCtgValMainId = @PrdCtgValMainIdRem
						SET @AssignAmount = @SlabAssginValue
					END
					SET @SlabAssginValue = @SlabAssginValue - @FrmSchAchRem
					UPDATE @TempBilledQPSReset Set FrmSchach = FrmSchAch - @FrmSchAchRem
						WHERE PrdId = @PrdIdRem AND PrdBatId = @PrdBatIdRem AND
						PrdCtgValMainId = @PrdCtgValMainIdRem
					SET @AssignQty = (SELECT TOP 1 @AssignAmount /
							CASE D.PrdBatDetailValue WHEN 0 THEN 1 ELSE
							D.PrdBatDetailValue END
						FROM ProductBatch A (NOLOCK) INNER JOIN
						ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatId
							INNER JOIN BatchCreation E (NOLOCK)
							ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo
							AND E.SelRte = 1 WHERE A.PrdBatId = @PrdBatIdRem)
					SET @AssignKG = (SELECT CASE PrdUnitId WHEN 2 THEN
						(PrdWgt * @AssignQty / 1000) WHEN 3 THEN
						(PrdWgt * @AssignQty) ELSE
						0 END FROM Product WHERE PrdId = @PrdIdRem )
					SET @AssignLitre = (SELECT CASE PrdUnitId WHEN 4 THEN
						(PrdWgt * @AssignQty / 1000) WHEN 5 THEN
						(PrdWgt * @AssignQty) ELSE
						0 END FROM Product WHERE PrdId = @PrdIdRem )
					INSERT INTO @TempRedeem(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,
						SchemeOnKG,SchemeOnLitre,SchId)
					SELECT @PrdIdRem,@PrdBatIdRem,@AssignQty,@AssignAmount,
						@AssignKG,@AssignLitre,@Pi_SchId
					IF EXISTS (SELECT PrdId From @TempBilledAch WHERE PrdId = @PrdIdRem AND
						PrdBatId = @PrdBatIdRem AND PrdCtgValMainId = @PrdCtgValMainIdRem
						AND SlabId = @SlabId AND FrmSchach <= 0)
							BREAK
					ELSE
							CONTINUE
--					SELECT 'S1',* FROM @TempRedeem
--					SELECT 'S1',* FROM @TempBilledAch
--					SELECT 'S1',* FROM @TempBilledQPSReset
				END
				FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
				@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
				@UomIdRem
				
			END
			CLOSE Cur_Redeem
			DEALLOCATE Cur_Redeem
		END
		--->Weight Based
		IF @SchType = 3
		BEGIN
			DECLARE Cur_Redeem Cursor For
				SELECT PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,
					FromQty,UomId FROM @TempBilledAch
					WHERE SlabId = @SlabId ORDER BY FrmSchAch Desc
			OPEN Cur_Redeem
			FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
				@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
			WHILE @@FETCH_STATUS =0
			BEGIN
				WHILE @SlabAssginValue > CAST(0 AS NUMERIC(38,6))
				BEGIN
					SET @AssignQty  = 0
					SET @AssignAmount = 0
					SET @AssignKG = 0
					SET @AssignLitre = 0
					IF @SlabAssginValue > @FrmSchAchRem
					BEGIN
						SET @TotalValue = @TotalValue - @FrmSchAchRem
						UPDATE @TempBilledAch Set FrmSchach = FrmSchAch - @FrmSchAchRem,
							ToSchAch = ToSchAch - @FrmSchAchRem
							WHERE PrdId = @PrdIdRem AND PrdBatId = @PrdBatIdRem AND
							PrdCtgValMainId = @PrdCtgValMainIdRem
						SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
							(@FrmSchAchRem / 1000) WHEN 3 THEN 						(@FrmSchAchRem) ELSE
							0 END FROM Product WHERE PrdId = @PrdIdRem)
		
						SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
							(@FrmSchAchRem / 1000) WHEN 5 THEN
							(@FrmSchAchRem) ELSE
							0 END FROM Product WHERE PrdId = @PrdIdRem)
					END
					ELSE
					BEGIN
						SET @TotalValue = @TotalValue - @SlabAssginValue
						UPDATE @TempBilledAch Set FrmSchach = FrmSchAch - @SlabAssginValue,
							ToSchAch = ToSchAch - @SlabAssginValue
							WHERE PrdId = @PrdIdRem AND PrdBatId = @PrdBatIdRem AND
							PrdCtgValMainId = @PrdCtgValMainIdRem
						SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
							(@SlabAssginValue / 1000) WHEN 3 THEN
							(@SlabAssginValue) ELSE
							0 END FROM Product WHERE PrdId = @PrdIdRem)
		
						SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
							(@SlabAssginValue / 1000) WHEN 5 THEN
							(@SlabAssginValue) ELSE
							0 END FROM Product WHERE PrdId = @PrdIdRem)
					END
					SET @SlabAssginValue = @SlabAssginValue - @FrmSchAchRem
					UPDATE @TempBilledQPSReset Set FrmSchach = FrmSchAch - @FrmSchAchRem
						WHERE PrdId = @PrdIdRem AND PrdBatId = @PrdBatIdRem AND
						PrdCtgValMainId = @PrdCtgValMainIdRem
					SET @AssignQty = (SELECT CASE PrdUnitId
						WHEN 2 THEN
							(@AssignKG /(CASE PrdWgt WHEN 0 THEN 1 ELSE
								PrdWgt END / 1000))
						WHEN 3 THEN
							(@AssignKG/(CASE PrdWgt WHEN 0 THEN 1 ELSE PrdWgt END))
						WHEN 4 THEN
							(@AssignLitre /(CASE PrdWgt WHEN 0 THEN 1 ELSE
								PrdWgt END / 1000))
						WHEN 5 THEN
							(@AssignLitre/(CASE PrdWgt WHEN 0 THEN 1
								ELSE PrdWgt END))
						ELSE
							0 END FROM Product WHERE PrdId = @PrdIdRem)
					SET @AssignAmount = (SELECT TOP 1 (D.PrdBatDetailValue * @AssignQty)
						FROM ProductBatch A (NOLOCK) INNER JOIN
						ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatId
							INNER JOIN BatchCreation E (NOLOCK)
							ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo
							AND E.SelRte = 1 WHERE A.PrdBatId = @PrdBatIdRem)
					INSERT INTO @TempRedeem(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,
						SchemeOnKG,SchemeOnLitre,SchId)
					SELECT @PrdIdRem,@PrdBatIdRem,@AssignQty,@AssignAmount,
						@AssignKG,@AssignLitre,@Pi_SchId
					IF EXISTS (SELECT PrdId From @TempBilledAch WHERE PrdId = @PrdIdRem AND
						PrdBatId = @PrdBatIdRem AND PrdCtgValMainId = @PrdCtgValMainIdRem
						AND SlabId = @SlabId AND FrmSchach <= 0)
							BREAK
					ELSE
							CONTINUE
				END
				FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
				@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
				@UomIdRem
				
			END
			CLOSE Cur_Redeem
			DEALLOCATE Cur_Redeem
		END
		
		--SELECT * FROM @TempRedeem		
		INSERT INTO BilledPrdRedeemedForQPS (RtrId,SchId,PrdId,PrdBatId,SumQty,SumValue,SumInKG,
			SumInLitre,UserId,TransId)
		SELECT @Pi_RtrId,@Pi_SchId,PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,
			SchemeOnLitre,@Pi_UsrId,@Pi_TransId FROM @TempRedeem
		--To Store the Gross amount for the Scheme billed Product
		SELECT @GrossAmount = ISNULL(SUM(SchemeOnAmount),0) FROM @TempRedeem
		--To Calculate the Scheme Flat Amount and Discount Percentage
		--Scheme Discount for Flat amount = ((FlatAmt * (LineLevel Gross / Total Gross) * 100)/100) * number of times
		--Scheme Discount for Disc Perc   = (LineLevel Gross * Disc Percentage) / 100
		INSERT INTO @BILLAPPLIEDSCHEMEHD(SCHID,SCHCODE,FLEXISCH,FLEXISCHTYPE,SLABID,SCHEMEAMOUNT,SCHEMEDISCOUNT,
	 		POINTS,FLXDISC,FLXVALUEDISC,FLXFREEPRD,FLXGIFTPRD,FLXPOINTS,FREEPRDID,
	 		FREEPRDBATID,FREETOBEGIVEN,GIFTPRDID,GIFTPRDBATID,GIFTTOBEGIVEN,NOOFTIMES,ISSELECTED,SCHBUDGET,
	 		BUDGETUTILIZED,TRANSID,USRID,PrdId,PrdBatId)
		SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,
			SchemeDiscount AS SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
			FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,
			IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
			FROM
			(	SELECT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
				@SlabId as SlabId,PrdId,PrdBatId,
				(CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END) As Contri,
				--((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
				FlatAmt
				As SchemeAmount, DiscPer AS SchemeDiscount,(Points *@NoOfTimes) as Points,
				FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,0 as FreePrdId,0 as FreePrdBatId,
				0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,
				0 as IsSelected,@SchemeBudget as SchBudget,0 as BudgetUtilized,@Pi_TransId As TransId,
				@Pi_UsrId as UsrId FROM @TempRedeem , @TempSchSlabAmt
				WHERE (FlatAmt + DiscPer + FlxDisc + FlxValueDisc + FlxFreePrd + FlxGiftPrd + Points) >=0
			) AS B
			GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeDiscount,Points,FlxDisc,FlxValueDisc,
			FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,
			GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
		
		--To Calculate the Free Qty to be given
		INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
	 		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
	 		FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
	 		BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
		SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
			@SlabId as SlabId,0 as SchAmount,0 as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
			0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,FreePrdId,0 as FreePrdBatId,
			CASE @SchType
				WHEN 1 THEN
					CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN ROUND((FreeQty*@NoOfTimes),0) ELSE FreeQty END
				WHEN 2 THEN
					CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN ROUND((FreeQty*@NoOfTimes),0) ELSE FreeQty END
				WHEN 3 THEN
					CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN ROUND((FreeQty*@NoOfTimes),0) ELSE FreeQty END
			END as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
			0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
			0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,MAX(PrdId) AS PrdId,MAX(PrdBatId) AS PrdBatId
			FROM @TempBilled , @TempSchSlabFree
			GROUP BY FreePrdId,FreeQty,ForEveryQty
		--To Calculate the Gift Qty to be given
		INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
			Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
			FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
			BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
		SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
			@SlabId as SlabId,0 as SchAmount,0 as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
			0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,0 As FreePrdId,0 as FreePrdBatId,
			0 as FreeToBeGiven,GiftPrdId as GiftPrdId,0 as GiftPrdBatId,
			CASE @SchType
				WHEN 1 THEN
					CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN ROUND((GiftQty*@NoOfTimes),0) ELSE GiftQty END
				WHEN 2 THEN
					CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN ROUND((GiftQty*@NoOfTimes),0) ELSE GiftQty END
				WHEN 3 THEN
					CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN ROUND((GiftQty*@NoOfTimes),0) ELSE GiftQty END
			END as GiftToBeGiven,@NoOfTimes as NoOfTimes,0 as IsSelected,
			@SchemeBudget as SchBudget,0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,MAX(PrdId) AS PrdId,MAX(PrdBatId) AS PrdBatId
			FROM @TempBilled , @TempSchSlabGift
			GROUP BY GiftPrdId,GiftQty,ForEveryQty
		
		SET @SlabAssginValue = 0
		SET @QPSResetAvail = 0
		SET @SlabId = 0
		
		SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
			INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId AND A.PrdId = B.PrdId
			AND A.PrdBatId = B.PrdBatId AND A.PrdCtgValMainId = B.PrdCtgValMainId
			GROUP BY A.SlabId,B.FromQty,B.ToQty
			HAVING SUM(A.FrmSchAch) >= B.FromQty AND
			SUM(A.ToSchAch) <= (CASE B.ToQty WHEN 0 THEN SUM(A.ToSchAch) ELSE B.ToQty END)
			ORDER BY A.SlabId DESC) As SlabId
		IF ISNULL(@SlabId,0) = (SELECT MAX(SlabId) FROM SchemeSlabs WHERE SchId = @Pi_SchId)
		BEGIN
			SET @QPSResetAvail = 1
		END
		IF @QPSResetAvail = 1
		BEGIN
			IF EXISTS (SELECT SlabId FROM SchemeSlabs WHERE SchId = @Pi_SchId AND SlabId = @SlabId
					AND ToQty > 0)
			BEGIN
				IF EXISTS (SELECT SlabId FROM SchemeSlabs WHERE SchId = @Pi_SchId AND SlabId = @SlabId
					AND ToQty < @TotalValue)
				BEGIN
					SELECT @SlabAssginValue = ToQty FROM SchemeSlabs WHERE SchId = @Pi_SchId
						AND SlabId = @SlabId
				END
				ELSE
				BEGIN
					SELECT @SlabAssginValue = @TotalValue
				END
			END
			ELSE
			BEGIN
				SELECT @SlabAssginValue = (PurQty + FromQty) FROM SchemeSlabs WHERE SchId = @Pi_SchId
						AND SlabId = @SlabId
			END
		END
		ELSE
		BEGIN
			SELECT @SlabAssginValue = @TotalValue
		END
		
		IF ISNULL(@SlabId,0) = 0
		BEGIN
			SET @TotalValue = 0
			SET @SlabAssginValue = 0
		END
		DELETE FROM @TempSchSlabAmt
		DELETE FROM @TempSchSlabFree
	END
	INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
		FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
		BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
	SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount),SUM(SchemeDiscount),
		SUM(Points),FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,(FreePrdId) as FreePrdId ,
		FreePrdBatId,SUM(FreeToBeGiven),GiftPrdId,GiftPrdBatId,SUM(GiftToBeGiven),SUM(NoOfTimes),
		IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,0 FROM @BillAppliedSchemeHd
		GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,FlxDisc,FlxValueDisc,FlxFreePrd,
		FlxGiftPrd,FlxPoints,FreePrdId
		,FreePrdBatId,GiftPrdId,GiftPrdBatId,IsSelected,
		SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
	IF EXISTS (SELECT * FROM SchemeRtrLevelValidation WHERE Schid = @Pi_SchId AND RtrId = @Pi_RtrId)
	BEGIN
		SELECT @FrmValidDate = FromDate , @ToValidDate = ToDate,@SchemeBudget = BudgetAllocated
			FROM SchemeRtrLevelValidation WHERE @BillDate between fromdate and todate
			AND Schid = @Pi_SchId AND RtrId = @Pi_RtrId
		SELECT @BudgetUtilized = dbo.Fn_ReturnBudgetUtilizedForRtr(@Pi_SchId,@Pi_RtrId,@FrmValidDate,@ToValidDate)
	END
	ELSE
	BEGIN
		SELECT @BudgetUtilized = dbo.Fn_ReturnBudgetUtilized(@Pi_SchId)
	END
	IF EXISTS (SELECT A.PrdBatId FROM StockLedger A LEFT OUTER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
	AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
	AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId
	AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0)
	BEGIN
		UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
		PrdId IN (
			SELECT A.PrdId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
		PrdBatId NOT IN (
			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
		(FreeToBeGiven+GiftToBeGiven) > 0 AND FlexiSch<>1
	END
	ELSE
	BEGIN
		INSERT INTO @MoreBatch SELECT SchId,SlabId,PrdId,COUNT(DISTINCT PrdId),
			COUNT(DISTINCT PrdBatId) FROM BillAppliedSchemeHd
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId GROUP BY SchId,SlabId,PrdId
			HAVING COUNT(DISTINCT PrdBatId)> 1
		IF EXISTS (SELECT * FROM @MoreBatch WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
		BEGIN
			INSERT INTO @TempBillAppliedSchemeHd
			SELECT A.* FROM BillAppliedSchemeHd A INNER JOIN @MoreBatch B
			ON A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.PrdId=B.PrdId
			WHERE A.SchId=@Pi_SchId AND A.SlabId=@SlabId
			AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND A.FlexiSch<>1
			AND A.PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
			WHERE SchCode=@SchCode AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 )
			UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
			PrdId IN (SELECT PrdId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId) AND
			PrdBatId IN (SELECT PrdBatId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
			AND SchemeAmount =0
		END
	END
	SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
	AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId
	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
	EXEC Proc_ApplyDiscountScheme @Pi_SchId,@Pi_UsrId,@Pi_TransId
	UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
	SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
	TransId = @Pi_TransId AND Usrid = @Pi_UsrId
	--SELECT * FROM BilledPrdHdForQPSScheme
	--NNN
--	SELECT * FROM BillAppliedSchemeHd
	INSERT INTO @QPSGivenFlat
	SELECT SchId,SUM(FlatAmount)
	FROM
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount,0) AS FlatAmount
	FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
	(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd) A,
	SalesInvoice SI
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeDiscount=0 AND SM.QPS=1 AND FlexiSch=0
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
	AND SISl.SlabId<=A.SlabId
	) A
	GROUP BY A.SchId
--	SELECT SISL.*
--	FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,BillAppliedSchemeHd A,SalesInvoice SI
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeDiscount=0 AND SM.QPS=1
--	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
--	--AND SISl.SlabId<=A.SlabId
--	--GROUP BY SISL.SchId
--	SELECT * FROM BillAppliedSchemeHd
--
--	SELECT 'N',* FROM @QPSGivenFlat
	UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-Amount
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	
	DECLARE @MSSchId AS INT
	DECLARE @MaxSlabId AS INT
	DECLARE @AmtToReduced AS NUMERIC(38,6)
	DECLARE Cur_QPSSlabs CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabs
	FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN
	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenFlat WHERE SchId=@MSSchId)
			BEGIN
			SELECT @AmtToReduced=SchemeAmount FROM BillAppliedSchemeHd 
			WHERE SlabId=@MaxSlabId AND SchId=@MSSchId
--			SELECT '1111',@AmtToReduced
			UPDATE BillAppliedSchemeHd SET SchemeAmount=0
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
			END
		END
		ELSE
		BEGIN
--			SELECT '222',* FROM @QPSGivenFlat WHERE SchId=@MSSchId
--			SELECT '222',* FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId
			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount+@AmtToReduced-Amount
			FROM  @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=@MSSchId 
			AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
			AND A.SchId=BillAppliedSchemeHd.SchId
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs
--	UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-Amount
--	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId	
--	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
--	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
--	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
--	AND CAST(BillAppliedSchemeHd.SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10)) IN 
--	(SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(MAX(SlabId) AS NVARCHAR(10)) FROM BillAppliedSchemeHd GROUP BY SchId)
	SELECT * FROM BillAppliedSchemeHd
	DELETE FROM BillAppliedSchemeHd WHERE SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd=0
	IF @QPS<>0 AND @QPSReset<>0	
	BEGIN
		DELETE FROM BillAppliedSchemeHd WHERE CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
		NOT IN (SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BilledPrdHdForQPSScheme WHERE QPSPrd=0 AND SchId=@Pi_SchId) 
		AND SchId=@Pi_SchId AND SchId IN (
		SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	END
	--Added By Murugan
	IF @QPS<>0
	BEGIN
		DELETE FROM BilledPrdHdForQPSScheme WHERE Transid=@Pi_TransId and Usrid=@Pi_UsrId AND SchId=@Pi_SchId
		INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
		SELECT RowId,@Pi_RtrId,BP.PrdId,BP.Prdbatid,SelRate,BaseQty,BaseQty*SelRate AS SchemeOnAmount,MRP,@Pi_TransId,@Pi_UsrId,ListPrice,0,@Pi_SchId
		From BilledPrdHdForScheme BP WHERE BP.TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND BP.RtrId=@Pi_RtrId --AND BP.SchId=@Pi_SchId

		IF @FlexiSch=0
		BEGIN
			INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
			From @TempBilled TB 		
		END
		ELSE
		BEGIN
			INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
			From @TempBilled TB WHERE CAST(TB.PrdId AS NVARCHAR(10))+'~'+CAST(TB.PrdBatId AS NVARCHAR(10)) IN
			(SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BilledPrdHdForScheme)		
			
--			--->For QPS Flexi(Range Based Started with Slab From 1)
--			IF @RangeBase=1
--			BEGIN
--				UPDATE BP SET GrossAmount=GrossAmount+SchemeOnAmount,BaseQty=(BaseQty+SchemeOnQty)
--				FROM BilledPrdHdForQPSScheme BP, 
--				(SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
--				-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
--				-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre
--				FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
--				AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId) A
--				WHERE BP.PrdId=A.PrdId AND BP.PrdBatId=A.PrdBatId AND BP.RowId=10000
--			END
		END
	END
	--Till Here	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-151-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApportionSchemeAmountInLine]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApportionSchemeAmountInLine]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--DELETE FROM ApportionSchemeDetails 
--DELETE FROM BilledPrdHdForQPSScheme
--DELETE FROM BilledPrdHdForScheme
--DELETE FROM BillAppliedSchemeHd
DELETE FROM ApportionSchemeDetails
--SELECT * FROM BillAppliedSchemeHd(NOLOCK)
EXEC Proc_ApportionSchemeAmountInLine 1,2
SELECT * FROM ApportionSchemeDetails WHERE TransId=2
ROLLBACK TRANSACTION
*/

CREATE   PROCEDURE [dbo].[Proc_ApportionSchemeAmountInLine]
(
	@Pi_UsrId   INT,
	@Pi_TransId  INT
)
AS
/*********************************
* PROCEDURE		: Proc_ApportionSchemeAmountInLine
* PURPOSE		: To Apportion the Scheme amount line wise
* CREATED		: Thrinath
* CREATED DATE	: 25/04/2007
* NOTE			: General SP for Returning Scheme amount line wise
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}       {developer}        {brief modification description}
* 28/04/2009    Nandakumar R.G    Modified for Discount Calculation on MRP with Tax
* 10/04/2010    Nandakumar R.G    Modified for QPS Scheme
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchId   INT
	DECLARE @SlabId  INT
	DECLARE @RefCode nVarChar(10)
	DECLARE @RtrId  INT
	DECLARE @PrdCnt  INT
	DECLARE @PrdBatCnt INT
	DECLARE @PrdId  INT
	DECLARE @MRP  INT
	DECLARE @WithTax INT
	DECLARE @BillSeqId  INT
	DECLARE @QPS  INT
	DECLARE @QPSDateQty  INT
	DECLARE @Combi  INT
	--NNN
	DECLARE @RtrQPSId  INT
	DECLARE @TempSchGross TABLE
	(
		SchId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	DECLARE @TempPrdGross TABLE
	(
		SchId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	DECLARE @FreeQtyDt TABLE
	(
		FreePrdid  INT,
		FreePrdBatId  INT,
		FreeQty   INT
	)
	DECLARE @FreeQtyRow TABLE
	(
		RowId   INT,
		PrdId   INT,
		PrdBatId  INT
	)
	DECLARE @PDSchID TABLE
	(
		PrdId   INT,
		PrdBatId  INT,
		PDSchId   INT,
		PDSlabId  INT
	)
	DECLARE @SchFlatAmt TABLE
	(
		SchId  INT,
		SlabId  INT,
		FlatAmt  NUMERIC(18,6),
		DiscPer  NUMERIC(18,6),
		SchType  INT
	)
	DECLARE @MoreBatch TABLE
	(
		SchId  INT,
		SlabId  INT,
		PrdId  INT,
		PrdCnt  INT,
		PrdBatCnt INT,
		SchType  INT
	)
	DECLARE @QPSGivenDisc TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @QPSGivenFlat TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @RtrQPSIds TABLE
	(
		RtrId   INT,		
		SchId   INT
	)
	DECLARE @QPSNowAvailable TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	--NNN
	DECLARE @TempSchGrossQPS TABLE
	(
		SchId   INT,
		SlabId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	--NNN
	DECLARE @TempPrdGrossQPS TABLE
	(
		SchId   INT,
		SlabId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	--NNN
	SELECT @RtrQPSId=RtrId FROM BilledPrdHdForQPSScheme WHERE TransId= @Pi_TransId AND UsrId=@Pi_UsrId
	if exists (select * from dbo.sysobjects where id = object_id(N'TP') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TP
	if exists (select * from dbo.sysobjects where id = object_id(N'TG') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TG
	if exists (select * from dbo.sysobjects where id = object_id(N'TPQ') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TPQ
	if exists (select * from dbo.sysobjects where id = object_id(N'TGQ') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TGQ
	if exists (select * from dbo.sysobjects where id = object_id(N'SchMaxSlab') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table SchMaxSlab
	SET @RtrId = (SELECT TOP 1 RtrId FROM BilledPrdHdForScheme WHERE TransID = @Pi_TransId
	AND UsrId = @Pi_Usrid)
	DECLARE  CurSchid CURSOR FOR
	SELECT DISTINCT Schid,SlabId FROM BillAppliedSchemeHd WHERE IsSelected = 1
	AND TransID = @Pi_TransId AND UsrId = @Pi_Usrid
	OPEN CurSchid
	FETCH NEXT FROM CurSchid INTO @SchId,@SlabId
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SELECT @QPS =QPS,@Combi=CombiSch,@QPSDateQty=ApyQPSSch	FROM SchemeMaster WHERE Schid=@SchId	
		SELECT @MRP=ApplyOnMRPSelRte,@WithTax=ApplyOnTax FROM SchemeMaster WHERE --MasterType=2 AND
		SchId=@SchId
		
		IF NOT EXISTS(SELECT * FROM @TempSchGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 OR (@Combi=1 AND @QPS=1)
			BEGIN
				IF EXISTS(SELECT * FROM SchemeAnotherPrdDt WHERE SchId=@SchId AND SlabId=@SlabId)
				BEGIN
					INSERT INTO @TempSchGross (SchId,GrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN SchemeAnotherPrdDt C ON A.PrdId=C.PrdId AND C.SchId=@SchId AND C.SlabId=@SlabId
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
				ELSE
				BEGIN 
					INSERT INTO @TempSchGross (SchId,GrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF  @QPS<>0 AND @Combi=0
			BEGIN
				INSERT INTO @TempSchGross (SchId,GrossAmount)
				SELECT @SchId,
				CASE @MRP
				WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
				WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
				WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
				as GrossAmount FROM BilledPrdHdForQPSScheme A
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND QPSPrd=1 AND A.SchId=@SchId
			END	
		END
		IF NOT EXISTS(SELECT * FROM @TempPrdGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 OR (@Combi=1 AND @QPS=1)
			BEGIN			
				--SELECT @SchId,@MRP,@WithTax,@SlabId	
				IF EXISTS(SELECT * FROM Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId))
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END 
				ELSE
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF @QPS<>0 AND @Combi=0
			BEGIN
--				IF @QPSDateQty=2 
--				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					AS GrossAmount FROM BilledPrdHdForQPSScheme A
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=1 AND A.SchId=@SchId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					AS GrossAmount FROM BilledPrdHdForQPSScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId
					--NNN
					IF @QPSDateQty=2 
					BEGIN
						UPDATE TPGS SET TPGS.RowId=BP.RowId
						FROM @TempPrdGross  TPGS,BilledPrdHdForQPSScheme BP
						WHERE TPGS.PrdId=BP.PrdId AND TPGS.PrdBatId=BP.PrdBatId AND UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND BP.RowId<>10000
						AND TPGS.SchId=BP.SchId

--						SELECT 'S',* FROM @TempPrdGross
--						UPDATE TPGS SET TPGS.RowId=BP.RowId
--						FROM @TempPrdGross  TPGS,
--						(
--							SELECT SchId,ISNULL(MIN(RowId),2) RowId FROM BilledPrdHdForQPSScheme
--							GROUP BY SchId
--						) AS BP
--						WHERE TPGS.SchId=BP.SchId
--						SELECT 'NS',SchId,SUM(GrossAmount) AS OtherGross FROM @TempPrdGross WHERE RowId=10000
--						GROUP BY SchID
						
						UPDATE C SET C.GrossAmount=C.GrossAmount+A.OtherGross
						FROM @TempPrdGross C,
						(SELECT SchId,SUM(GrossAmount) AS OtherGross FROM @TempPrdGross WHERE RowId=10000
						GROUP BY SchID) A,
						(SELECT SchId,ISNULL(MIN(RowId),2)  AS RowId FROM @TempPrdGross WHERE RowId<>10000 
						GROUP BY SchId) B
						WHERE A.SchId=B.SchId AND B.SchId=C.SchId AND B.RowId=C.RowId
						DELETE FROM @TempPrdGross WHERE RowId=10000
--						SELECT 'S',* FROM @TempPrdGross
					END
					ELSE
					BEGIN
						UPDATE TPGS SET TPGS.RowId=BP.RowId
						FROM @TempPrdGross  TPGS,
						(
							SELECT SchId,ISNULL(MIN(RowId),2) RowId FROM BilledPrdHdForQPSScheme
							WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
							GROUP BY SchId
						) AS BP
						WHERE TPGS.SchId=BP.SchId --AND TPGS.PrdBatId=BP.PrdBatId
					END	
					---
--				END
--				ELSE
--				BEGIN
--					SELECT 'NNN'
--					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
--					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
--					CASE @MRP
--					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
--					WHEN 2 THEN A.GrossAmount
--					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
--					AS GrossAmount FROM BilledPrdHdForQPSScheme A
--					LEFT JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
--					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
--					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=0					
--					UNION ALL
--					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
--					CASE @MRP
--					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
--					WHEN 2 THEN A.GrossAmount
--					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
--					AS GrossAmount FROM BilledPrdHdForQPSScheme A
--					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
--					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId
--				END
			END
		END
		INSERT INTO @MoreBatch SELECT SchId,SlabId,PrdId,COUNT(DISTINCT PrdId),
		COUNT(DISTINCT PrdBatId),SchType FROM BillAppliedSchemeHd
		WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId GROUP BY SchId,SlabId,PrdId,SchType
		HAVING COUNT(DISTINCT PrdBatId)> 1
		IF EXISTS (SELECT * FROM @MoreBatch WHERE SchId=@SchId AND SlabId=@SlabId)
		BEGIN
			INSERT INTO @SchFlatAmt
			SELECT SchId,SlabId,FlatAmt,DiscPer,0 FROM SchemeSlabs
			WHERE SchId=@SchId AND SlabId=@SlabId
			INSERT INTO @SchFlatAmt
			SELECT SchId,SlabId,FlatAmt,DiscPer,1 FROM SchemeAnotherPrdDt
			WHERE SchId=@SchId AND SlabId=@SlabId
		END
	FETCH NEXT FROM CurSchid INTO @SchId,@SlabId
	END
	CLOSE CurSchid
	DEALLOCATE CurSchid
	----->
	SELECT DISTINCT * INTO TG FROM @TempSchGross
	SELECT DISTINCT * INTO TP FROM @TempPrdGross
	DELETE FROM @TempPrdGross
	
	INSERT INTO @TempPrdGross
	SELECT * FROM TP 
	
	---->For Scheme on Another Product QPS
--	UPDATE TPG SET TPG.GrossAmount=(TPG.GrossAmount/TSG.BilledGross)*TSG1.GrossAmount
--	FROM @TempPrdGross TPG,(SELECT SchId,SUM(GrossAmount) AS BilledGross FROM @TempPrdGross GROUP BY SchId) TSG,
--	@TempSchGross TSG1,SchemeMaster SM 
--	WHERE TPG.SchId=TSG.SchId AND TSG.SchId=TSG1.SchId AND SM.SchId=TPG.SchId
	
	UPDATE TPG SET TPG.GrossAmount=(TPG.GrossAmount/TSG.BilledGross)*TSG1.GrossAmount
	FROM @TempPrdGross TPG,(SELECT SchId,SUM(GrossAmount) AS BilledGross FROM @TempPrdGross GROUP BY SchId) TSG,
	@TempSchGross TSG1,SchemeMaster SM ,SchemeAnotherPrdHd SMA
	WHERE TPG.SchId=TSG.SchId AND TSG.SchId=TSG1.SchId AND SM.SchId=TPG.SchId AND SM.SchId=SMA.SchId
	----->	

	DECLARE  CurMoreBatch CURSOR FOR
	SELECT DISTINCT Schid,SlabId,PrdId,PrdCnt,PrdBatCnt FROM @MoreBatch
	OPEN CurMoreBatch
	FETCH NEXT FROM CurMoreBatch INTO @SchId,@SlabId,@PrdId,@PrdCnt,@PrdBatCnt
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS (SELECT A.PrdBatId FROM StockLedger A LEFT OUTER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId
			AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0)
		BEGIN
			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
			WHERE SchId=@SchId AND SlabId=@SlabId AND PrdId=@PrdId AND
			PrdBatId NOT IN (
			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
			(SchemeAmount) > 0  AND IsSelected = 1 AND SchType=0
			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
			WHERE SchId=@SchId AND SlabId=@SlabId AND PrdId=@PrdId AND
			PrdBatId NOT IN (
			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
			(SchemeAmount) > 0  AND IsSelected = 1 AND SchType=1
		END
		--Commented By Nanda on 22/10/2009
		--  ELSE
		--  BEGIN
		--   UPDATE BillAppliedSchemeHd Set SchemeAmount=0
		--   WHERE SchId=@SchId AND SlabId=@SlabId  AND SchType=0
		--   AND PrdId=@PrdId AND IsSelected = 1 AND (SchemeAmount+SchemeDiscount)>0 AND
		--   PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
		--   WHERE SchId=@SchId AND SlabId=@SlabId
		--   AND PrdId=@PrdId  AND (SchemeAmount)>0 AND IsSelected = 1 AND SchType=0)
		--   UPDATE BillAppliedSchemeHd Set SchemeAmount=0
		--   WHERE SchId=@SchId AND SlabId=@SlabId  AND SchType=1
		--   AND PrdId=@PrdId AND IsSelected = 1 AND (SchemeAmount+SchemeDiscount)>0 AND
		--   PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
		--   WHERE SchId=@SchId AND SlabId=@SlabId
		--   AND PrdId=@PrdId  AND (SchemeAmount)>0 AND IsSelected = 1 AND SchType=1)
		--  END
		--  UPDATE BillAppliedSchemeHd Set SchemeAmount= C.FlatAmt
		--  FROM @TempPrdGross A
		--  INNER JOIN BillAppliedSchemeHd B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId
		--  INNER JOIN @SchFlatAmt C ON A.SchId=C.SchId AND B.SlabId=C.SlabId
		--  WHERE (B.SchemeAmount)>0 AND B.PrdId=@PrdId  AND B.SchType=0
		--  AND B.PrdBatId IN
		--   (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd WHERE SchId=@SchId AND SlabId=@SlabId
		--   AND PrdId=@PrdId AND  IsSelected = 1 AND (SchemeAmount)>0 AND SchType=0 )
		--
		--  UPDATE BillAppliedSchemeHd Set SchemeAmount= C.FlatAmt
		--  FROM @TempPrdGross A
		--  INNER JOIN BillAppliedSchemeHd B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId
		--  INNER JOIN @SchFlatAmt C ON A.SchId=C.SchId AND B.SlabId=C.SlabId
		--  WHERE B.SchemeAmount>0 AND B.PrdId=@PrdId  AND B.SchType=1
		--  AND B.PrdBatId IN
		--   (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd WHERE SchId=@SchId AND SlabId=@SlabId
		--   AND PrdId=@PrdId AND  IsSelected = 1 AND SchemeAmount>0 AND SchType=1 )
		--Till Here
	FETCH NEXT FROM CurMoreBatch INTO @SchId,@SlabId,@PrdId,@PrdCnt,@PrdBatCnt
	END
	CLOSE CurMoreBatch
	DEALLOCATE CurMoreBatch
	
	IF EXISTS (SELECT Status FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 )
	BEGIN
		SELECT @RefCode = Condition FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1
		INSERT INTO @PDSchID (PrdId,PrdBatId,PDSchId,PDSlabId)
		SELECT SP.PrdId,SP.PrdBatId,BAS.SchId AS PDSchId,MIN(BAS.SlabId) AS PDSlabId
		FROM @TempPrdGross SP
		INNER JOIN BillAppliedSchemeHd BAS ON SP.SchId=BAS.SchId AND SchemeDiscount>0
		INNER JOIN (SELECT DISTINCT SP1.PrdId,SP1.PrdBatId,MIN(BAS1.SchId) AS MinSchId
		FROM BillAppliedSchemeHd BAS1,@TempPrdGross SP1
		WHERE SP1.SchId=BAS1.SchId
		AND SchemeDiscount >0 AND BAS1.UsrId = @Pi_Usrid AND BAS1.TransId = @Pi_TransId
		GROUP BY SP1.PrdId,SP1.PrdBatId) AS A ON A.MinSchId=BAS.SchId AND A.PrdId=SP.PrdId
		AND A.PrdBatId=SP.PrdBatId AND BAS.UsrId = @Pi_Usrid AND BAS.TransId = @Pi_TransId
		GROUP BY SP.PrdId,SP.PrdBatId,BAS.SchId
		IF @Pi_TransId=2
		BEGIN
			DECLARE @DiscPer TABLE
			(
				PrdId  INT,
				PrdBatId INT,
				DiscPer  NUMERIC(18,6),
				GrossAmount NUMERIC(18,6),
				RowId  INT
			)
			INSERT INTO @DiscPer
			SELECT SP1.PrdId,SP1.PrdBatId,ISNULL(SUM(BAS1.SchemeDiscount),0),SP1.GrossAmount,SP1.RowId
			FROM BillAppliedSchemeHd BAS1 LEFT OUTER JOIN @TempPrdGross SP1
			ON SP1.SchId=BAS1.SchId AND SP1.PrdId=BAS1.PrdId AND SP1.PrdBatId=BAS1.PrdBatId WHERE IsSelected=1 AND
			SchemeDiscount>0 AND BAS1.UsrId = @Pi_Usrid AND BAS1.TransId = @Pi_TransId
			GROUP BY SP1.PrdId,SP1.PrdBatId,SP1.RowId,SP1.GrossAmount
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			--    (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			--SchemeAmount As SchemeAmount,
			CASE 
				WHEN QPS=1 THEN
					(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
				ELSE  
					SchemeAmount 
				END  
			As SchemeAmount,
			C.GrossAmount - (C.GrossAmount / (1  +
			(
			(
				CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
					WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
						CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) --Second Case Start
							WHEN 1 THEN  
								D.PrdBatDetailValue  
							ELSE 0 
						END     --Second Case End
					ELSE 0 
				END) + SchemeDiscount)/100))      --First Case END
			As SchemeDiscount,0 As FreeQty,
			@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount
			FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
			A.SchId = B.SchId INNER JOIN @TempPrdGross C ON A.Schid = C.SchId
			AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId and B.SchId = C.SchId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid	 		
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON C.PrdId= PD.PrdId AND
			(CASE PD.PrdBatId WHEN 0 THEN C.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			AND PD.PDSchId=A.SchId
			WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND (A.SchemeAmount + A.SchemeDiscount) > 0
			SELECT  A.RowId,A.PrdId,A.PrdBatId,D.PrdBatDetailValue,
			C.GrossAmount - (C.GrossAmount / (1  +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(F.SchId AS NVARCHAR(10))+'-'+CAST(F.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			 D.PrdBatDetailValue  END     --Second Case End
			ELSE 0 END) + DiscPer)/100)) AS SchAmt,F.SchId,F.SlabId
			INTO #TempFinal
			FROM @DiscPer A
			INNER JOIN @TempPrdGross C ON  A.PrdId = C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId AND D.PrdbatId=A.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON A.PrdId= PD.PrdId AND PD.PDSchId=C.SchId AND
			(CASE PD.PrdBatId WHEN 0 THEN A.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			INNER JOIN BillAppliedSchemeHd F ON F.SchId=PD.PDSCHID AND A.PrdId=F.PrdId AND A.PrdBatId=F.PrdBatId
			
			SELECT A.RowId,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,A.DiscPer,
			--(A.DiscPer+isnull(PrdbatDetailValue,0))/SUM(A.DiscPer+isnull(PrdbatDetailValue,0))
			(A.DiscPer+isnull(PrdbatDetailValue,0))
			as DISC,
			isnull(SUM(A.DiscPer+PrdbatDetailValue),SUM(A.DiscPer)) AS DiscSUM,ISNULL(B.SchAmt,0) AS SchAmt,
			CASE  WHEN (ISNULL(PrdbatDetailValue,0)>0 AND A.DiscPer > 0 )THEN 1
			  WHEN (ISNULL(PrdbatDetailValue,0)=0 AND A.DiscPer > 0) THEN 2
			  ELSE 3 END as Status
			INTO #TempSch1
			FROM ApportionSchemeDetails A LEFT OUTER JOIN #TempFinal B ON
			A.RowId =B.RowId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId
			AND A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.DiscPer > 0
			GROUP BY A.RowId,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,A.DiscPer,B.PrdbatDetailValue,B.SchAmt
			UPDATE #TempSch1 SET SchAmt=B.SchAmt
			FROM #TempFinal B
			WHERE  #TempSch1.RowId=B.RowId AND #TempSch1.PrdId=B.PrdId AND #TempSch1.PrdBatId=B.PrdBatId
			SELECT A.RowId,A.PrdId,A.PrdBatId,ISNULL(SUM(Disc),0) AS SUMDisc
			INTO #TempSch2
			FROM #TempSch1 A
			GROUP BY A.RowId,A.PrdId,A.PrdBatId
			UPDATE #TempSch1 SET DiscSUM=ISNULL((Disc/NULLIF(SUMDisc,0)),0)*SchAmt
			FROM #TempSch2 B
			WHERE #TempSch1.RowId=B.RowId AND #TempSch1.PrdId=B.PrdId AND #TempSch1.PrdBatId=B.PrdBatId
			UPDATE ApportionSchemeDetails SET SchemeDiscount=DiscSUM
			FROM #TempSch1 B,ApportionSchemeDetails A
			WHERE A.RowId=B.RowId AND A.PrdId = B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId AND
			A.SlabId= B.SlabId AND B.Status<3
		END
		ELSE
		BEGIN
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount,
			C.GrossAmount - (C.GrossAmount /(1 +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			D.PrdBatDetailValue  ELSE 0 END     --Second Case End
			ELSE 0 END) + SchemeDiscount)/100))       --First Case END
			As SchemeDiscount,0 As FreeQty,
			@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
			FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
			A.SchId = B.SchId AND (A.SchemeAmount + A.SchemeDiscount) > 0
			INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId AND
			A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid	 	
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON C.PrdId= PD.PrdId AND
			(CASE PD.PrdBatId WHEN 0 THEN C.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		END
	END
	ELSE
	BEGIN
		---->For Scheme on Another Product QPS
--		SELECT * FROM BillAppliedSchemeHd
--		SELECT * FROM @TempSchGross
--		SELECT * FROM @TempPrdGross
		IF EXISTS(SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		BEGIN
			SELECT DISTINCT TP.SchId,BA.SlabId,TP.PrdId,TP.PrdBatId,TP.RowId,TP.GrossAmount 
			INTO TPQ FROM BillAppliedSchemeHd BA
			INNER JOIN SchemeMaster SM ON BA.SchId=SM.SchId AND Sm.QPS=1 AND SM.QPSReset=1
			INNER JOIN @TempPrdGross TP ON TP.SchId=BA.SchId
			SELECT DISTINCT TG.SchId,BA.SlabId,TG.GrossAmount 
			INTO TGQ FROM BillAppliedSchemeHd BA
			INNER JOIN SchemeMaster SM ON BA.SchId=SM.SchId AND Sm.QPS=1 AND SM.QPSReset=1
			INNER JOIN @TempSchGross TG ON TG.SchId=BA.SchId
			
			SELECT A.SchId,A.MaxSlabId,SS.PurQty
			INTO SchMaxSlab FROM
			(SELECT SM.SchId,MAX(SS.SlabId) AS MaxSlabId
			FROM SchemeMaster SM,SchemeSlabs SS
			WHERE SM.SchId=SS.SchId AND SM.QPSReset=1 
			GROUP BY SM.SchId) A,
			SchemeSlabs SS
			WHERE A.SchId=SS.SchId AND A.MaxSlabId=SS.SlabId 
	--		SELECT * FROM TG
	--		SELECT * FROM TP
	--
	--		SELECT * FROM TGQ
	--		--SELECT * FROM SchMaxSlab 
	--		SELECT * FROM TPQ
	--		SELECT * FROM BillAppliedSchemeHd
			DECLARE @MSSchId AS INT
			DECLARE @MaxSlabId AS INT
			DECLARE @MSPurQty AS NUMERIC(38,6)
			DECLARE Cur_QPSSlabs CURSOR FOR 
			SELECT SchId,MaxSlabId,PurQty
			FROM SchMaxSlab
			OPEN Cur_QPSSlabs
			FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId,@MSPurQty
			WHILE @@FETCH_STATUS=0
			BEGIN		
				UPDATE TGQ SET GrossAmount=@MSPurQty 
				WHERE SchId=@MSSchId AND SlabId=@MaxSlabId
				UPDATE TGQ SET GrossAmount=GrossAmount-@MSPurQty 
				WHERE SchId=@MSSchId AND SlabId<@MaxSlabId
				FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId,@MSPurQty
			END
			CLOSE Cur_QPSSlabs
			DEALLOCATE Cur_QPSSlabs
			UPDATE T SET T.GrossAmount=(T.GrossAmount/TG.GrossAmount)*TGQ.GrossAmount
			FROM TPQ T,TG,TGQ
			WHERE T.SchId=TG.SchId AND TG.SchId=TGQ.SchId AND TGQ.SlabId=T.SlabId 	

			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
			SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount
			,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
			@Pi_TransId AS TransId,@Pi_UsrId AS UsrId,SchemeDiscount,A.SchType
			FROM BillAppliedSchemeHd A INNER JOIN TGQ B ON
			A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
			INNER JOIN TPQ C ON A.Schid = C.SchId and B.SchId = C.SchId AND A.SlabId=B.SlabId AND B.SlabId=C.SlabId
			--AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
			WHERE A.UsrId = @Pi_UsrId AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)	
			AND SM.SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
			AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
			GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		END
		
		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT DISTINCT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId		
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid and SM.QPS=1 	  		
		INNER JOIN SchemeAnotherPrdDt SOP ON SM.SchId=SOP.SchId AND A.SchId=SOP.SchId AND A.SlabId=SOP.SlabId
		AND A.PrdId=SOP.PrdId AND SOP.Prdid=C.PrdId 
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1 
		AND SM.SchId IN (SELECT SchId FROM SchemeAnotherPrdHd)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		--AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		---->
	END
	INSERT INTO @FreeQtyDt (FreePrdid,FreePrdBatId,FreeQty)
	--SELECT FreePrdId,FreePrdBatId,Sum(FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
	SELECT FreePrdId,FreePrdBatId,Sum(DISTINCT FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY FreePrdId,FreePrdBatId

	INSERT INTO @FreeQtyRow (RowId,PrdId,PrdBatId)
	SELECT MIN(A.RowId) as RowId,A.Prdid,A.PrdBatId FROM BilledPrdHdForScheme A
	INNER JOIN BillAppliedSchemeHd B ON A.PrdId = B.PrdId AND
	A.PrdBatid = B.PrdBatId
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND
	B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY A.Prdid,A.PrdBatId
	UPDATE ApportionSchemeDetails SET FreeQty = A.FreeQty FROM
	@FreeQtyDt A INNER JOIN @FreeQtyRow B ON
	A.FreePrdId  = B.PrdId
	WHERE ApportionSchemeDetails.RowId = B.RowId
	AND ApportionSchemeDetails.UsrId = @Pi_Usrid AND
	ApportionSchemeDetails.TransId = @Pi_TransId

	--->Added By Nanda on 20/09/2010
	SELECT * INTO #TempApp FROM ApportionSchemeDetails	
	DELETE FROM ApportionSchemeDetails
	INSERT INTO ApportionSchemeDetails
	SELECT DISTINCT * FROM #TempApp
	--->Till Here

--	DELETE FROM ApportionSchemeDetails WHERE SchemeAmount=0 AND SchemeDiscount=0 and FreeQty=0
--	EXEC Proc_RDDiscount @RtrId,@Pi_TransId,@Pi_Usrid
	--SELECT * FROM ApportionSchemeDetails
--	INSERT INTO @QPSGivenFlat
--	SELECT SchId,ISNULL(SUM(FlatAmount),0) FROM SalesInvoiceSchemeLineWise 
--	WHERE SchId IN (SELECT A.SchId FROM ApportionSchemeDetails A,SchemeMaster SM 
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeDiscount=0 AND SM.QPS=1
--	AND A.SchId=SM.SchId)   
--	GROUP BY SchId
	--SELECT 'Jessey',@RtrQPSId
--	INSERT INTO @QPSGivenFlat
--	SELECT SISL.SchId,ISNULL(SUM(FlatAmount),0) 
--	FROM SalesInvoiceSchemeLineWise SISL,ApportionSchemeDetails A,SchemeMaster SM ,SalesInvoice SI
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeDiscount=0 AND SM.QPS=1
--	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@RtrQPSId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
--	AND SISl.SlabId<=A.SlabId
--	GROUP BY SISL.SchId
--
--	SELECT * FROM @QPSGivenFlat
--
--	UPDATE ApportionSchemeDetails SET SchemeAmount=SchemeAmount-Amount
--	FROM @QPSGivenFlat A WHERE ApportionSchemeDetails.SchId=A.SchId	
--	INSERT INTO @QPSGivenDisc
--	SELECT SchId,ISNULL(SUM(DiscountPerAmount),0) FROM SalesInvoiceSchemeLineWise 
--	WHERE SchId IN (SELECT A.SchId FROM ApportionSchemeDetails A,SchemeMaster SM 
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeAmount=0 AND SM.QPS=1
--	AND A.SchId=SM.SchId)   
--	GROUP BY SchId	
--	INSERT INTO @QPSGivenDisc
--	SELECT SISL.SchId,ISNULL(SUM(DiscountPerAmount),0) 
--	FROM SalesInvoiceSchemeLineWise SISL,ApportionSchemeDetails A,SchemeMaster SM ,SalesInvoice SI
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeAmount=0 AND SM.QPS=1
--	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@RtrQPSId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
--	AND SISl.SlabId<=A.SlabId
--	GROUP BY SISL.SchId
	--SELECT * FROM ApportionSchemeDetails

	UPDATE ApportionSchemeDetails SET SchemeAmount=SchemeAmount+SchAmt,SchemeDiscount=SchemeDiscount+SchDisc
	FROM 
	(SELECT SchId,SUM(SchemeAmount) SchAmt,SUM(SchemeDiscount) SchDisc FROM ApportionSchemeDetails
	WHERE RowId=10000 GROUP BY SchId) A,
	(SELECT SchId,MIN(RowId) RowId FROM ApportionSchemeDetails
	GROUP BY SchId) B
	WHERE ApportionSchemeDetails.SchId =  A.SchId AND A.SchId=B.SchId 
	AND ApportionSchemeDetails.RowId=B.RowId  

	DELETE FROM ApportionSchemeDetails WHERE RowId=10000
	INSERT INTO @RtrQPSIds
	SELECT DISTINCT RtrId,SchId FROM BilledPrdHdForQPSScheme WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	
	--SELECT * FROM @RtrQPSIds
--	INSERT INTO @QPSGivenDisc
--	SELECT SISL.SchId,ISNULL(SUM(DiscountPerAmount),0) 
--	FROM SalesInvoiceSchemeLineWise SISL,ApportionSchemeDetails A,SchemeMaster SM ,SalesInvoice SI,
--	@RtrQPSIds RQPS
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeAmount=0 AND SM.QPS=1
--	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
--	AND SISl.SlabId<=A.SlabId
--	GROUP BY SISL.SchId
----------------	INSERT INTO @QPSGivenDisc
----------------	SELECT SISL.SchId,ISNULL(SUM(DiscountPerAmount),0) 
----------------	FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails WHERE SchemeAmount=0) A,SchemeMaster SM ,SalesInvoice SI,
----------------	@RtrQPSIds RQPS
----------------	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 --AND A.SchemeAmount=0 
----------------	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
----------------	AND SISl.SlabId<=A.SlabId
----------------	GROUP BY SISL.SchId
	--SELECT 'RQPS',* FROM @RtrQPSIds

	INSERT INTO @QPSGivenDisc
	SELECT A.SchId,SUM(A.DiscountPerAmount) FROM 
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount
	FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails WHERE SchemeAmount=0) A,SchemeMaster SM ,SalesInvoice SI,
	@RtrQPSIds RQPS
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
	AND SISl.SlabId<=A.SlabId) A
	GROUP BY A.SchId

	SELECT 'NNN',* FROM @QPSGivenDisc
	SELECT 'NNN',* FROM ApportionSchemeDetails

	INSERT INTO @QPSNowAvailable
	SELECT A.SchId,SUM(SchemeDiscount)-B.Amount FROM ApportionSchemeDetails A,@QPSGivenDisc B
	WHERE A.SchId=B.SchId
	GROUP BY A.SchId,B.Amount

	SELECT * FROM @QPSNowAvailable

--	UPDATE ApportionSchemeDetails SET SchemeDiscount=SchemeDiscount-Amount
--	FROM @QPSGivenDisc A WHERE ApportionSchemeDetails.SchId=A.SchId	

	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId

	--SELECT * FROM ApportionSchemeDetails
--	UPDATE ApportionSchemeDetails SET SchemeAmount=SchemeAmount+SchAmt,SchemeDiscount=SchemeDiscount+SchDisc
--	FROM 
--	(SELECT SchId,SUM(SchemeAmount) SchAmt,SUM(SchemeDiscount) SchDisc FROM ApportionSchemeDetails
--	WHERE RowId=10000 GROUP BY SchId) A,
--	(SELECT SchId,MIN(RowId) RowId FROM ApportionSchemeDetails
--	GROUP BY SchId) B
--	WHERE ApportionSchemeDetails.SchId =  A.SchId AND A.SchId=B.SchId 
--	AND ApportionSchemeDetails.RowId=B.RowId  
--
--	DELETE FROM ApportionSchemeDetails WHERE RowId=10000
	--SELECT * FROM ApportionSchemeDetails
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-151-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnBilledSchemeDet]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnBilledSchemeDet]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM Fn_ReturnBilledSchemeDet(13237)
CREATE     FUNCTION [dbo].[Fn_ReturnBilledSchemeDet]
(
	@Pi_SalId BIGINT
)
RETURNS @BilledSchemeDet TABLE
(
	SchId			Int,
	SchCode			nVarChar(40),
	FlexiSch		TinyInt,
	FlexiSchType		TinyInt,
	SlabId			Int,
	SchType			INT,
	SchemeAmount		Numeric(38,6),
	SchemeDiscount		Numeric(38,6),
	Points			INT,
	FlxDisc			TINYINT,
	FlxValueDisc		TINYINT,
	FlxFreePrd		TINYINT,
	FlxGiftPrd		TINYINT,
	FlxPoints		TINYINT,
	FreePrdId 		INT,
	FreePrdBatId		INT,
	FreeToBeGiven		INT,
	GiftPrdId 		INT,
	GiftPrdBatId		INT,
	GiftToBeGiven		INT,
	NoOfTimes		Numeric(38,6),
	IsSelected		TINYINT,
	SchBudget		Numeric(38,6),
	BudgetUtilized		Numeric(38,6),
	LineType		TINYINT,
	PrdId			INT,
	PrdBatId		INT
)
AS
/*********************************
* FUNCTION: Fn_ReturnBilledSchemeDet
* PURPOSE: Returns the Scheme Details for the Selected Bill Number
* NOTES:
* CREATED: Thrinath Kola	02-05-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	--For Scheme On Another Product
	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		ISNULL(SUM(FlatAmount),0) AS SchemeAmount,ISNULL(A.DiscPer,0) AS SchemeDiscount,
		ISNULL(E.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,0 as FreePrdId,
		0 as FreePrdBatId,0 as FreeToBeGiven,0 As GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType,A.PrdId,A.PrdBatId
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		LEFT OUTER JOIN SalesInvoiceSchemeDtPoints E ON E.SalId = A.SalId
		AND A.SchId = E.SchId AND A.SlabId = E.SlabId AND A.SchType=E.SchType
		WHERE A.SalId = @Pi_SalId AND A.SchId IN (SELECT SchId FROM SchemeAnotherPrdHd) 
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,A.DiscPer,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,Budget,B.NoOfTimes,E.Points,A.PrdId,A.PrdBatId

	--For Normal Scheme 
	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		ISNULL(SUM(FlatAmount),0) AS SchemeAmount,ISNULL(A.DiscPer,0) AS SchemeDiscount,
		ISNULL(E.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,0 as FreePrdId,
		0 as FreePrdBatId,0 as FreeToBeGiven,0 As GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType, 0 AS PrdId,0 AS PrdBatId
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		LEFT OUTER JOIN SalesInvoiceSchemeDtPoints E ON E.SalId = A.SalId
		AND A.SchId = E.SchId AND A.SlabId = E.SlabId AND A.SchType=E.SchType
		WHERE A.SalId = @Pi_SalId AND A.SchId NOT IN (SELECT SchId FROM SchemeAnotherPrdHd) AND (ISNULL(FlatAmount,0)+ISNULL(A.DiscPer,0))>0 
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,A.DiscPer,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,Budget,B.NoOfTimes,E.Points

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,0 AS SchemeAmount,0 AS SchemeDiscount,
		0 As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId as FreePrdId,
		FreePrdBatId as FreePrdBatId,ISNULL(SUM(FreeQty),0) as FreeToBeGiven,GiftPrdId As GiftPrdId,
		GiftPrdBatId as GiftPrdBatId,ISNULL(SUM(GiftQty),0) as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,2 as LineType,0,0
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId AND FreePrdId > 0
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId,
		A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId,C.Budget,B.NoOfTimes

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,0 AS SchemeAmount,0 AS SchemeDiscount,
		0 As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId as FreePrdId,
		FreePrdBatId as FreePrdBatId,ISNULL(SUM(FreeQty),0) as FreeToBeGiven,GiftPrdId As GiftPrdId,
		GiftPrdBatId as GiftPrdBatId,ISNULL(SUM(GiftQty),0) as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,3 as LineType,0,0
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId AND GiftPrdId > 0
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId,
		A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId,C.Budget,B.NoOfTimes

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,0 AS SchType,
		ISNULL(SUM(A.FlatAmount),0) AS SchemeAmount,ISNULL(SUM(A.DiscountPerAmount),0) AS SchemeDiscount,
		ISNULL(A.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,
		A.FreePrdId as FreePrdId,0 as FreePrdBatId,ISNULL(SUM(FreeQty),0) as FreeToBeGiven,
		0 As GiftPrdId,	0 as GiftPrdBatId,0 as GiftToBeGiven,
		0 AS NoOfTimes,0 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,0 as LineType,0,0
		FROM SalesInvoiceUnSelectedScheme A
		INNER JOIN SchemeMaster C ON A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON A.SchId = D.SchId AND A.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,A.Points,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId,C.Budget

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,B.SchType,
		0 AS SchemeAmount,0 AS SchemeDiscount,
		ISNULL(A.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,
		0 as FreePrdId,0 as FreePrdBatId,0 as FreeToBeGiven,
		0 As GiftPrdId,	0 as GiftPrdBatId,0 as GiftToBeGiven,
		B.NoOfTimes AS NoOfTimes,1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType,0,0
		FROM SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON A.SchId = D.SchId AND A.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId --AND A.SalId Not IN (Select SalId From SalesInvoiceSchemeLineWise
			--WHERE SalId = @Pi_SalId)
		AND A.POints>0
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,B.SchType,A.Points,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,C.Budget,B.NoOfTimes

		UPDATE @BilledSchemeDet SET SchemeDiscount = DiscountPercent
			FROM SalesInvoiceSchemeFlexiDt B, @BilledSchemeDet A WHERE B.SalId = @Pi_SalId
			AND A.SchId = B.SchId AND A.SlabId = B.SlabId AND A.FreeToBeGiven = 0
			AND A.GiftToBeGiven = 0

		UPDATE @BilledSchemeDet SET FlxDisc = 0,FlxValueDisc = 0,FlxPoints = 0
			WHERE FreeToBeGiven > 0 or GiftToBeGiven > 0
	RETURN
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-151-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBTBillTemplate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBTBillTemplate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_RptBTBillTemplate]
(
	@Pi_UsrId Int = 1,
	@Pi_Type INT,
	@Pi_InvDC INT
)
AS
/*********************************
* PROCEDURE		: Proc_RptBTBillTemplate
* PURPOSE		: To Get the Bill Details 
* CREATED		: Nandakumar R.G
* CREATED DATE	: 29/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @FROMBillId AS  VARCHAR(25)
	DECLARE @ToBillId   AS  VARCHAR(25)
	DECLARE @Cnt AS INT
	DECLARE @TempSalId TABLE
	(
		SalId INT
	)
	DECLARE  @RptBillTemplate Table
	(
		[Base Qty] numeric(38,0),
		[Batch Code] nvarchar(50),
		[Batch Expiry Date] datetime,
		[Batch Manufacturing Date] datetime,
		[Batch MRP] numeric(38,2),
		[Batch Selling Rate] numeric(38,2),
		[Bill Date] datetime,
		[Bill Doc Ref. Number] nvarchar(50),
		[Bill Mode] tinyint,
		[Bill Type] tinyint,
		[CD Disc Base Qty Amount] numeric(38,2),
		[CD Disc Effect Amount] numeric(38,2),
		[CD Disc Header Amount] numeric(38,2),
		[CD Disc LineUnit Amount] numeric(38,2),
		[CD Disc Qty Percentage] numeric(38,2),
		[CD Disc Unit Percentage] numeric(38,2),
		[CD Disc UOM Amount] numeric(38,2),
		[CD Disc UOM Percentage] numeric(38,2),
		[Company Address1] nvarchar(50),
		[Company Address2] nvarchar(50),
		[Company Address3] nvarchar(50),
		[Company Code] nvarchar(20),
		[Company Contact Person] nvarchar(100),
		[Company EmailId] nvarchar(50),
		[Company Fax Number] nvarchar(50),
		[Company Name] nvarchar(100),
		[Company Phone Number] nvarchar(50),
		[Contact Person] nvarchar(50),
		[CST Number] nvarchar(50),
		[DB Disc Base Qty Amount] numeric(38,2),
		[DB Disc Effect Amount] numeric(38,2),
		[DB Disc Header Amount] numeric(38,2),
		[DB Disc LineUnit Amount] numeric(38,2),
		[DB Disc Qty Percentage] numeric(38,2),
		[DB Disc Unit Percentage] numeric(38,2),
		[DB Disc UOM Amount] numeric(38,2),
		[DB Disc UOM Percentage] numeric(38,2),
		[DC DATE] DATETIME,
		[DC NUMBER] nvarchar(100),
		[Delivery Boy] nvarchar(50),
		[Delivery Date] datetime,
		[Deposit Amount] numeric(38,2),
		[Distributor Address1] nvarchar(50),
		[Distributor Address2] nvarchar(50),
		[Distributor Address3] nvarchar(50),
		[Distributor Code] nvarchar(20),
		[Distributor Name] nvarchar(50),
		[Drug Batch Description] nvarchar(50),
		[Drug Licence Number 1] nvarchar(50),
		[Drug Licence Number 2] nvarchar(50),
		[Drug1 Expiry Date] DateTime,
		[Drug2 Expiry Date] DateTime,
		[EAN Code] varchar(50),
		[EmailID] nvarchar(50),
		[Geo Level] nvarchar(50),
		[Interim Sales] tinyint,
		[Licence Number] nvarchar(50),
		[Line Base Qty Amount] numeric(38,2),
		[Line Base Qty Percentage] numeric(38,2),
		[Line Effect Amount] numeric(38,2),
		[Line Unit Amount] numeric(38,2),
		[Line Unit Percentage] numeric(38,2),
		[Line UOM1 Amount] numeric(38,2),
		[Line UOM1 Percentage] numeric(38,2),
		[LST Number] nvarchar(50),
		[Manual Free Qty] int,
		[Order Date] datetime,
		[Order Number] nvarchar(50),
		[Pesticide Expiry Date] DateTime,
		[Pesticide Licence Number] nvarchar(50),
		[PhoneNo] nvarchar(50),
		[PinCode] int,
		[Product Code] nvarchar(50),
		[Product Name] nvarchar(200),
		[Product Short Name] nvarchar(100),
		[Product SL No] Int,
		[Product Type] int,
		[Remarks] nvarchar(200),
		[Retailer Address1] nvarchar(100),
		[Retailer Address2] nvarchar(100),
		[Retailer Address3] nvarchar(100),
		[Retailer Code] nvarchar(50),
		[Retailer ContactPerson] nvarchar(100),
		[Retailer Coverage Mode] tinyint,
		[Retailer Credit Bills] int,
		[Retailer Credit Days] int,
		[Retailer Credit Limit] numeric(38,2),
		[Retailer CSTNo] nvarchar(50),
		[Retailer Deposit Amount] numeric(38,2),
		[Retailer Drug ExpiryDate] datetime,
		[Retailer Drug License No] nvarchar(50),
		[Retailer EmailId] nvarchar(100),
		[Retailer GeoLevel] nvarchar(50),
		[Retailer License ExpiryDate] datetime,
		[Retailer License No] nvarchar(50),
		[Retailer Name] nvarchar(150),
		[Retailer OffPhone1] nvarchar(50),
		[Retailer OffPhone2] nvarchar(50),
		[Retailer OnAccount] numeric(38,2),
		[Retailer Pestcide ExpiryDate] datetime,
		[Retailer Pestcide LicNo] nvarchar(50),
		[Retailer PhoneNo] nvarchar(50),
		[Retailer Pin Code] nvarchar(50),
		[Retailer ResPhone1] nvarchar(50),
		[Retailer ResPhone2] nvarchar(50),
		[Retailer Ship Address1] nvarchar(100),
		[Retailer Ship Address2] nvarchar(100),
		[Retailer Ship Address3] nvarchar(100),
		[Retailer ShipId] int,
		[Retailer TaxType] tinyint,
		[Retailer TINNo] nvarchar(50),
		[Retailer Village] nvarchar(100),
		[Route Code] nvarchar(50),
		[Route Name] nvarchar(50),
		[Sales Invoice Number] nvarchar(50),
		[SalesInvoice ActNetRateAmount] numeric(38,2),
		[SalesInvoice CDPer] numeric(9,6),
		[SalesInvoice CRAdjAmount] numeric(38,2),
		[SalesInvoice DBAdjAmount] numeric(38,2),
		[SalesInvoice GrossAmount] numeric(38,2),
		[SalesInvoice Line Gross Amount] numeric(38,2),
		[SalesInvoice Line Net Amount] numeric(38,2),
		[SalesInvoice MarketRetAmount] numeric(38,2),
		[SalesInvoice NetAmount] numeric(38,2),
		[SalesInvoice NetRateDiffAmount] numeric(38,2),
		[SalesInvoice OnAccountAmount] numeric(38,2),
		[SalesInvoice OtherCharges] numeric(38,2),
		[SalesInvoice RateDiffAmount] numeric(38,2),
		[SalesInvoice ReplacementDiffAmount] numeric(38,2),
		[SalesInvoice RoundOffAmt] numeric(38,2),
		[SalesInvoice TotalAddition] numeric(38,2),
		[SalesInvoice TotalDeduction] numeric(38,2),
		[SalesInvoice WindowDisplayAmount] numeric(38,2),
		[SalesMan Code] nvarchar(50),
		[SalesMan Name] nvarchar(50),
		[SalId] int,
		[Sch Disc Base Qty Amount] numeric(38,2),
		[Sch Disc Effect Amount] numeric(38,2),
		[Sch Disc Header Amount] numeric(38,2),
		[Sch Disc LineUnit Amount] numeric(38,2),
		[Sch Disc Qty Percentage] numeric(38,2),
		[Sch Disc Unit Percentage] numeric(38,2),
		[Sch Disc UOM Amount] numeric(38,2),
		[Sch Disc UOM Percentage] numeric(38,2),
		[Scheme Points] numeric(38,2),
		[Spl. Disc Base Qty Amount] numeric(38,2),
		[Spl. Disc Effect Amount] numeric(38,2),
		[Spl. Disc Header Amount] numeric(38,2),
		[Spl. Disc LineUnit Amount] numeric(38,2),
		[Spl. Disc Qty Percentage] numeric(38,2),
		[Spl. Disc Unit Percentage] numeric(38,2),
		[Spl. Disc UOM Amount] numeric(38,2),
		[Spl. Disc UOM Percentage] numeric(38,2),
		[Tax 1] numeric(38,2),
		[Tax 2] numeric(38,2),
		[Tax 3] numeric(38,2),
		[Tax 4] numeric(38,2),
		[Tax Amount1] numeric(38,2),
		[Tax Amount2] numeric(38,2),
		[Tax Amount3] numeric(38,2),
		[Tax Amount4] numeric(38,2),
		[Tax Amt Base Qty Amount] numeric(38,2),
		[Tax Amt Effect Amount] numeric(38,2),
		[Tax Amt Header Amount] numeric(38,2),
		[Tax Amt LineUnit Amount] numeric(38,2),
		[Tax Amt Qty Percentage] numeric(38,2),
		[Tax Amt Unit Percentage] numeric(38,2),
		[Tax Amt UOM Amount] numeric(38,2),
		[Tax Amt UOM Percentage] numeric(38,2),
		[Tax Type] tinyint,
		[TIN Number] nvarchar(50),
		[Uom 1 Desc] nvarchar(50),
		[Uom 1 Qty] int,
		[Uom 2 Desc] nvarchar(50),
		[Uom 2 Qty] int,
		[Vehicle Name] nvarchar(50),
		UsrId int,
		Visibility tinyint
	)
	IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplate]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
	DROP TABLE [RptBillTemplate]
	TRUNCATE TABLE RptSELECTedBills
	IF @Pi_Type=1
	BEGIN
		INSERT INTO @TempSalId
		SELECT SelValue FROM ReportFilterDt
		WHERE RptId = 16 AND SelId = 34
		INSERT INTO RptSELECTedBills
		SELECT SalId FROM @TempSalId
	END
	ELSE
	BEGIN
		IF @Pi_InvDC=1
		BEGIN
			DECLARE @FROMId INT
			DECLARE @ToId INT
			DECLARE @FROMSeq INT
			DECLARE @ToSeq INT
			SELECT @FROMId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=14
			SELECT @ToId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=15
			SELECT @FROMSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@FROMId
			SELECT @ToSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@ToId
			
			INSERT INTO RptSELECTedBills
			SELECT SalId FROM SalInvoiceDeliveryChallan WHERE SeqNo BETWEEN @FROMSeq AND @ToSeq
		END
		ELSE
		BEGIN
			SELECT @FROMBillId=SelValue FROM ReportFilterDt WHERE RptId = 16 AND SelId = 14
			SELECT @ToBillId=SelValue FROM ReportFilterDt WHERE RptId = 16 AND SelId = 15
			INSERT INTO RptSELECTedBills
			SELECT SalId FROM SalesINvoice(NOLOCK) WHERE SalId BETWEEN @FROMBillId AND @ToBillId
		END
	END
	IF @Pi_Type=1
	BEGIN
		INSERT INTO @RptBillTemplate
		SELECT DISTINCT BaseQty,PrdBatCode,ExpDate,MnfDate,MRP,[Selling Rate],SalInvDate,SalInvRef,BillMode,BillType,
		[CD Disc_Amount_Dt],[CD Disc_EffectAmt_Dt],[CD Disc_HD],[CD Disc_UnitAmt_Dt],[CD Disc_QtyPerc_Dt],[CD Disc_UnitPerc_Dt],[CD Disc_UomAmt_Dt],
		[CD Disc_UomPerc_Dt],Address1,Address2,Address3,CmpCode,ContactPerson,EmailId,FaxNumber,CmpName,PhoneNumber,D_ContactPerson,CSTNo,
		[DB Disc_Amount_Dt],[DB Disc_EffectAmt_Dt],[DB Disc_HD],[DB Disc_UnitAmt_Dt],[DB Disc_QtyPerc_Dt],[DB Disc_UnitPerc_Dt],[DB Disc_UomAmt_Dt],
		[DB Disc_UomPerc_Dt],DCDate,DCNo,DlvBoyName,SalDlvDate,DepositAmt,DistributorAdd1,DistributorAdd2,DistributorAdd3,DistributorCode,
		DistributorName,DrugBatchDesc,DrugLicNo1,DrugLicNo2,Drug1ExpiryDate,Drug2ExpiryDate,EANCode,D_EmailID,D_GeoLevelName,InterimSales,LicNo,
		LineBaseQtyAmount,LineBaseQtyPerc,LineEffectAmount,LineUnitamount,LineUnitPerc,LineUom1Amount,LineUom1Perc,LSTNo,SalManFreeQty,OrderDate,
		OrderKeyNo,PestExpiryDate,PestLicNo,PhoneNo,PinCode,PrdCCode,PrdName,PrdShrtName,SLNo,PrdType,Remarks,RtrAdd1,RtrAdd2,RtrAdd3,RtrCode,
		RtrContactPerson,RtrCovMode,RtrCrBills,RtrCrDays,RtrCrLimit,RtrCSTNo,RtrDepositAmt,RtrDrugExpiryDate,RtrDrugLicNo,RtrEmailId,
		GeoLevelName,RtrLicExpiryDate,RtrLicNo,RtrName,RtrOffPhone1,RtrOffPhone2,RtrOnAcc,RtrPestExpiryDate,RtrPestLicNo,RtrPhoneNo,RtrPinNo,
		RtrResPhone1,RtrResPhone2,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipId,RtrTaxType,RtrTINNo,VillageName,RMCode,RMName,SalInvNo,
		SalActNetRateAmount,SalCDPer,CRAdjAmount,DBAdjAmount,SalGrossAmount,PrdGrossAmountAftEdit,PrdNetAmount,MarketRetAmount,SalNetAmt,
		SalNetRateDiffAmount,OnAccountAmount,OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,
		WindowDisplayamount,SMCode,SMName,SalId,[Sch Disc_Amount_Dt],[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],
		[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],
		[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],
		Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],
		[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,
		Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility
		FROM
		(
			SELECT DisDt.*,RepAll.*
			FROM
			(
				SELECT D.DistributorCode,D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3, D.PinCode,D.PhoneNo,
				D.ContactPerson D_ContactPerson,D.EmailID D_EmailID,D.TaxType,D.TINNo,D.DepositAmt,GL.GeoLevelName D_GeoLevelName,
				D.CSTNo,D.LSTNo,D.LicNo,D.DrugLicNo1,D.Drug1ExpiryDate,D.DrugLicNo2,D.Drug2ExpiryDate,D.PestLicNo , D.PestExpiryDate
				FROM Distributor D WITH (NOLOCK)
				LEFT OUTER JOIN Geography G WITH (NOLOCK) ON D.GeoMainId = G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL WITH (NOLOCK) ON G.GeoLevelId = GL.GeoLevelId
			) DisDt ,
			(
				SELECT RepHD.*,RepDt.* FROM
				(
					SELECT SalesInv.* , RtrDt.*, HDAmt.* FROM
					(
						SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
						RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,
						SalRateDiffAmount,SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,
						Replacementdiffamount,TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,
						SalRoundOffAmt,V.VehicleId,V.VehicleCode,D.DlvBoyId , D.DlvBoyName FROM SalesInvoice SI WITH (NOLOCK)
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					) SalesInv
					LEFT OUTER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,
						R.RtrCrLimit,R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,
						GL.GeoLevelName,RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2 , R.RtrOffPhone1, R.RtrOffPhone2, R.RtrOnAcc FROM Retailer R WITH (NOLOCK)
						INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK) WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					LEFT OUTER JOIN
					(
						SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
						FROM SalesInvoice SI
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D') D ON SI.SalId = D.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E') E ON SI.SalId = E.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F') F ON SI.SalId = F.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G') G ON SI.SalId = G.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H') H ON SI.SalId = H.SalId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					)HDAmt ON SalesInv.SalIdHD = HDAmt.SalId
				) RepHD
				LEFT OUTER JOIN
				(
					SELECT SalesInvPrd.*,LiAmt.*,LNUOM.*,BATPRC.MRP,BATPRC.[Selling Rate]
					FROM
					(
						SELECT SPR.*,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,
							U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,SIP.Uom2Qty,SIP.BaseQty,
							SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,BPT.Tax3Perc,
							BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
							FROM SalesInvoiceProduct SIP WITH (NOLOCK)
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId
							INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.SchId,LW.slabId,LW.PrdId, LW.PrdBatId, PO.Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								LEFT OUTER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId AND LW.SchId = PO.SchId AND
								--LW.SlabId = PO.SlabId
								LW.SlabId = PO.SlabId AND LW.PrdId=PO.PrdId AND LW.PrdBatId=PO.PrdBatId 
								WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills)
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
--							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
--							P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,'0' Uom1Qty,
--							'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
--							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
--							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
--							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
--							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,'0' Uom1Qty,
							'0' UOM2,'0' Uom2Qty,SUM(SIP.FreeQty) BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							GROUP BY SIP.SalId,SIP.FreePrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.FreePrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,SIP.FreePriceId
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax4Amount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
--							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
--							P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
--							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
--							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
--							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
--							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
--							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SUM(SIP.GiftQty) AS BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							GROUP BY SIP.SalId,SIP.GiftPrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,SIP.GiftPriceId
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt]
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1
					AND SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						FROM SalesInvoiceProduct WITH (NOLOCK)
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						SELECT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
						FROM
						(
							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
							FROM ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1 )
						) MRP
						LEFT OUTER JOIN
						(
						SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
						FROM ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
						WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1 )
						) SelRtr ON MRP.PrdId = SelRtr.PrdId AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId
						AND MRP.PriceId=SelRtr.PriceId
					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  WHERE SalId IN (SELECT SalId FROM @TempSalId)
	END
	ELSE
	BEGIN
		INSERT INTO @RptBillTemplate
		SELECT DISTINCT BaseQty,PrdBatCode,ExpDate,MnfDate,MRP,[Selling Rate],SalInvDate,SalInvRef,BillMode,BillType,[CD Disc_Amount_Dt],
		[CD Disc_EffectAmt_Dt],[CD Disc_HD],[CD Disc_UnitAmt_Dt],[CD Disc_QtyPerc_Dt],[CD Disc_UnitPerc_Dt],[CD Disc_UomAmt_Dt],[CD Disc_UomPerc_Dt],
		Address1,Address2,Address3,CmpCode,ContactPerson,EmailId,FaxNumber,CmpName,PhoneNumber,D_ContactPerson,CSTNo,[DB Disc_Amount_Dt],
		[DB Disc_EffectAmt_Dt],[DB Disc_HD],[DB Disc_UnitAmt_Dt],[DB Disc_QtyPerc_Dt],[DB Disc_UnitPerc_Dt],[DB Disc_UomAmt_Dt],[DB Disc_UomPerc_Dt],
		DCDate,DCNo,DlvBoyName,SalDlvDate,DepositAmt,DistributorAdd1,DistributorAdd2,DistributorAdd3,DistributorCode,DistributorName,DrugBatchDesc,
		DrugLicNo1,DrugLicNo2,Drug1ExpiryDate,Drug2ExpiryDate,EANCode,D_EmailID,D_GeoLevelName,InterimSales,LicNo,LineBaseQtyAmount,LineBaseQtyPerc,
		LineEffectAmount,LineUnitamount,LineUnitPerc,LineUom1Amount,LineUom1Perc,LSTNo,SalManFreeQty,OrderDate,OrderKeyNo,PestExpiryDate,PestLicNo,
		PhoneNo,PinCode,PrdCCode,PrdName,PrdShrtName,SLNo,PrdType,Remarks,RtrAdd1,RtrAdd2,RtrAdd3,RtrCode,RtrContactPerson,RtrCovMode,
		RtrCrBills,RtrCrDays,RtrCrLimit,RtrCSTNo,RtrDepositAmt,RtrDrugExpiryDate,RtrDrugLicNo,RtrEmailId,GeoLevelName,RtrLicExpiryDate,RtrLicNo,
		RtrName,RtrOffPhone1,RtrOffPhone2,RtrOnAcc,RtrPestExpiryDate,RtrPestLicNo,RtrPhoneNo,RtrPinNo,RtrResPhone1,RtrResPhone2,
		RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipId,RtrTaxType,RtrTINNo,VillageName,RMCode,RMName,SalInvNo,SalActNetRateAmount,SalCDPer,
		CRAdjAmount,DBAdjAmount,SalGrossAmount,PrdGrossAmountAftEdit,PrdNetAmount,MarketRetAmount,SalNetAmt,SalNetRateDiffAmount,OnAccountAmount,
		OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,WindowDisplayamount,SMCode,SMName,SalId,
		[Sch Disc_Amount_Dt],[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],
		[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],
		[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,
		Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],
		[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility
		FROM
		(
			SELECT DisDt.*,RepAll.*
			FROM
			(
				SELECT D.DistributorCode,D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3, D.PinCode,D.PhoneNo,
				D.ContactPerson D_ContactPerson,D.EmailID D_EmailID,D.TaxType,D.TINNo,D.DepositAmt,GL.GeoLevelName D_GeoLevelName,
				D.CSTNo,D.LSTNo,D.LicNo,D.DrugLicNo1,D.Drug1ExpiryDate,D.DrugLicNo2,D.Drug2ExpiryDate,D.PestLicNo , D.PestExpiryDate
				FROM Distributor D WITH (NOLOCK)
				LEFT OUTER JOIN Geography G WITH (NOLOCK) ON D.GeoMainId = G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL WITH (NOLOCK) ON G.GeoLevelId = GL.GeoLevelId
			) DisDt ,
			(
				SELECT RepHD.*,RepDt.* FROM
				(
					SELECT SalesInv.* , RtrDt.*, HDAmt.* FROM
					(
						SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
						RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,SalRateDiffAmount,
						SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,Replacementdiffamount,
						TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,SalRoundOffAmt,V.VehicleId,V.VehicleCode,
						D.DlvBoyId,D.DlvBoyName
						FROM SalesInvoice SI WITH (NOLOCK)
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					) SalesInv
					LEFT OUTER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,R.RtrCrLimit,
						R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,GL.GeoLevelName,
						RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2,R.RtrOffPhone1,R.RtrOffPhone2,R.RtrOnAcc
						FROM Retailer R WITH (NOLOCK)
						INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK)
						WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					LEFT OUTER JOIN
					(
						SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
						FROM SalesInvoice SI
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					)HDAmt ON SalesInv.SalIdHD = HDAmt.SalId
				) RepHD
				LEFT OUTER JOIN
				(
					SELECT SalesInvPrd.*,LiAmt.*,LNUOM.*,BATPRC.MRP,BATPRC.[Selling Rate]
					FROM
					(
						SELECT SPR.*,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,
						C.EmailId,C.ContactPerson
						FROM
						(
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,
							P.PrdName,P.PrdShrtName,P.CmpId,P.PrdType,SIP.PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,
							U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,SIP.Uom2Qty,SIP.BaseQty,
							SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,
							BPT.Tax3Perc,BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
							FROM SalesInvoiceProduct SIP WITH (NOLOCK)
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId
							INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.SchId,LW.slabId,LW.PrdId, LW.PrdBatId, PO.Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								LEFT OUTER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId
								AND LW.SchId = PO.SchId AND LW.SlabId = PO.SlabId
								WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills)
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax4Amount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt]
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1 AND
					SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						FROM SalesInvoiceProduct WITH (NOLOCK)
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						SELECT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
						FROM
						(
							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
							FROM ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1 )
						) MRP
						LEFT OUTER JOIN
						(
							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
							FROM ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1 )
						) SelRtr ON MRP.PrdId = SelRtr.PrdId
						AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId AND MRP.PriceId=SelRtr.PriceId
					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  WHERE SalId IN (SELECT SalId FROM RptSELECTedBills)
	END
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[RptBTBillTemplate]')
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	DROP TABLE [RptBTBillTemplate]
	SELECT DISTINCT * INTO RptBTBillTemplate FROM @RptBillTemplate
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-151-005

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PK_SalesInvoiceSchemeDtPoints_SalId_SchId_SlabId_SchType]') and OBJECTPROPERTY(id, N'IsPrimaryKey') = 1)
ALTER TABLE [dbo].[SalesInvoiceSchemeDtPoints] DROP CONSTRAINT [PK_SalesInvoiceSchemeDtPoints_SalId_SchId_SlabId_SchType]
GO

--SRF-Nanda-159-001

UPDATE SchemeMaster SET Budget=0 WHERE SchStatus=1 AND GETDATE() BETWEEN SchValidFrom AND SchValidTill 
AND FBM=1

UPDATE S SET S.Budget=S.Budget+A.DiscAmt
FROM SchemeMaster S,
(
	SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
	WHERE TransId IN(3,5)
	GROUP BY SchId
) A
WHERE S.FBM=1 AND S.SchId=A.SchId
AND S.SchStatus=1 AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill

--SRF-Nanda-159-002

if exists (select * from dbo.sysobjects where id = object_id(N'[FBMSchemeOpen]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [FBMSchemeOpen]
GO

CREATE TABLE [dbo].[FBMSchemeOpen]
(
	[PrdId] [int] NULL,
	[FBMIn] [numeric](38, 6) NULL,
	[FBMOut] [numeric](38, 6) NULL,
	[Balance] [numeric](38, 6) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-159-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_FBMTrack]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_FBMTrack]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT Budget,* FROM SchemeMaster WHERE SchId IN (153,156,157)
EXEC Proc_FBMTrack 3,'SLR1000158',158,'2010-10-09',2,0
SELECT * FROM FBMTrackIn WHERE SchId=157
SELECT Budget,* FROM SchemeMaster WHERE SchId IN (153,156,157)
ROLLBACK TRANSACTION
*/
CREATE        PROCEDURE [dbo].[Proc_FBMTrack]
(
	@Pi_TransId		INT,
	@Pi_TransRefNo	NVARCHAR(50),
	@Pi_TransRefId	INT,
	@Pi_TransDate	DATETIME,
	@Pi_UserId		INT, 
	@Po_ErrNo		INT		OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_FBMTrack
* PURPOSE		: To Track FBM
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 16/04/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 2010/06/30	Nanda		 Integrated 'Upload' Flag
*********************************/
SET NOCOUNT ON
BEGIN		

	--Billing-FBM Out
	IF @Pi_TransId=2  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut-FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId

		DELETE FROM FBMTrackOut WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		DELETE FROM FBMSchDetails WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 		

		INSERT INTO FBMTrackOut(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyOut,Rate,GrossAmtOut,DiscAmtOut,DiscPerc,
		Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT SISL.PrdId,SISL.PrdBatId,SISL.SchId,SI.SalInvDate,2,@Pi_TransRefId,SI.SalInvNo,1,SIP.BaseQty,SIP.PrdUom1EditedSelRate,SIP.PrdGrossAmount,
		(SISL.FlatAmount+SISL.DiscountPerAmount),((SISL.FlatAmount+SISL.DiscountPerAmount)/SIP.PrdGrossAmount)*100,
		1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM SalesInvoice SI
		INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=@Pi_TransRefId AND SIP.SalId=SI.SalId 
		INNER JOIN SalesInvoiceSchemeLineWise SISL ON SISL.SalId=SI.SalId AND SISL.RowId=SIP.SlNo
		AND (SISL.FlatAmount+SISL.DiscountPerAmount)>0
		INNER JOIN SchemeMaster SM ON SM.SchId=SISL.SchId AND SM.FBM=1 
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut+FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,0,SUM(DiscAmtOut) AS DiscAmtOut,-1* SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId
	END

	--Billing Delivery Process Cancelled Bill-FBM Cancel
	IF @Pi_TransId=29  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut-FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId=2 AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackOut WHERE TransId=2 AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 		
		DELETE FROM FBMSchDetails WHERE TransId=2 AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 		
	END
	
	--Purchase Return-FBM Out
	IF @Pi_TransId=7  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut-FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackOut WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackOut(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyOut,Rate,GrossAmtOut,DiscAmtOut,DiscPerc,
		Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT SIP.PrdId,SIP.PrdBatId,0,SI.PurRetDate,7,@Pi_TransRefId,SI.PurRetRefNo,1,SIP.RetSalBaseQty+SIP.RetUnSalBaseQty,SIP.PrdUnitLSP,SIP.PrdGrossAmount,
		(SIP.PrdDiscount/SIP.PrdGrossAmount)*PBD.PrdBatDetailValue*(SIP.RetSalBaseQty+SIP.RetUnSalBaseQty),(SIP.PrdDiscount/SIP.PrdGrossAmount)*100,
		1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM PurchaseReturn SI
		INNER JOIN PurchaseReturnProduct SIP ON SI.PurRetId=@Pi_TransRefId AND SIP.PurRetId=SI.PurRetId AND SIP.PrdDiscount>0
		INNER JOIN ProductBatch PB ON PB.PrdId=SIP.PrdId AND PB.PrdBatId=SIP.PrdBatId   
		INNER JOIN ProductBatchDetails PBD ON PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1
		INNER JOIN BatchCreation BC ON BC.BatchSeqId=PBD.BatchSeqId AND PBD.SlNo=BC.SlNo AND BC.SelRte=1
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut+FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,0,SUM(DiscAmtOut) AS DiscAmtOut,-1* SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId
	END

	--Purchase-FBM In
	IF @Pi_TransId=5  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn-FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackIn WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,DiscAmtIn,DiscPerc,
		SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT SIP.PrdId,SIP.PrdBatId,0,SI.GoodsRcvdDate,5,@Pi_TransRefId,SI.PurRcptRefNo,1,SIP.InvBaseQty,SIP.PrdUnitLSP,SIP.PrdGrossAmount,
		SIP.PrdDiscount,(SIP.PrdDiscount/SIP.PrdGrossAmount)*100,PBD.PrdBatDetailValue,
		PBD.PrdBatDetailValue*(SIP.PrdDiscount/SIP.PrdGrossAmount)*SIP.InvBaseQty,1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM PurchaseReceipt SI
		INNER JOIN PurchaseReceiptProduct SIP ON SI.PurRcptId=@Pi_TransRefId AND SIP.PurRcptId=SI.PurRcptId AND SIP.PrdDiscount>0
		INNER JOIN ProductBatch PB ON PB.PrdId=SIP.PrdId AND PB.PrdBatId=SIP.PrdBatId   
		INNER JOIN ProductBatchDetails PBD ON PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1
		INNER JOIN BatchCreation BC ON BC.BatchSeqId=PBD.BatchSeqId AND PBD.SlNo=BC.SlNo AND BC.SelRte=1
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn+FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn,0,SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId
	END

	--Sales Return-FBM In
	IF @Pi_TransId=3  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn-FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackIn WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,DiscAmtIn,DiscPerc,
		SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT SIP.PrdId,SIP.PrdBatId,SISL.SchId,SI.ReturnDate,3,@Pi_TransRefId,SI.ReturnCode,1,SIP.BaseQty,SIP.PrdEditSelRte,SIP.PrdGrossAmt,
		SISL.ReturnFlatAmount+SISL.ReturnDiscountPerAmount,((SISL.ReturnFlatAmount+SISL.ReturnDiscountPerAmount)/SIP.PrdGrossAmt)*100,SIP.PrdEditSelRte,SISL.ReturnFlatAmount+SISL.ReturnDiscountPerAmount,
		1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM ReturnHeader SI
		INNER JOIN ReturnProduct SIP ON SI.ReturnID=@Pi_TransRefId AND SIP.ReturnID=SI.ReturnID 
		INNER JOIN ReturnSchemeLineDt SISL ON SISL.ReturnID=SI.ReturnID AND SISL.RowId=SIP.SlNo AND
		SISL.ReturnFlatAmount+SISL.ReturnDiscountPerAmount>0
		INNER JOIN SchemeMaster SM ON SM.SchId=SISL.SchId AND SM.FBM=1
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn+FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtIn>0
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn,0,SUM(DiscAmtIn) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtIn>0
		GROUP BY PrdId
	END

	--FBM Switching-FBM Out
	IF @Pi_TransId=255  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut-FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackOut WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackOut(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyOut,
		Rate,GrossAmtOut,DiscAmtOut,DiscPerc,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT PrdId,0,0,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,FBMSRefNo,1,0,0,0,
		FBMAmtTransfered,100,1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM FBMSwitchingDetails WHERE FBMSRefNo=@Pi_TransRefNo
		
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut+FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,0,SUM(DiscAmtOut) AS DiscAmtOut,-1* SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId

		--FBM In
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn-FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackIn WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,DiscAmtIn,DiscPerc,
		SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT ToPrdId,0,0,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,FBMSRefNo,1,0,0,0,FBMAmtTransfered,
		100,0,FBMAmtTransfered,1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM FBMSwitching WHERE FBMSRefNo=@Pi_TransRefNo
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn+FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn,0,SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId
	END

	--Scheme Master-FBM In-Opening Balance
	IF @Pi_TransId=45  
	BEGIN

		IF NOT EXISTS(SELECT * FROM SchemeProducts WHERE SchId=@Pi_TransRefId AND PrdCtgValMainId>0)
		BEGIN
			SELECT @Pi_TransRefId AS SchId,Sp.PrdId 
			INTO #TempSchProducts
			FROM SchemeProducts SP,SchemeMaster SM		
			WHERE SM.SchId=SP.SchId AND SM.SchCode=@Pi_TransRefno AND SM.SchId=@Pi_TransRefId AND SM.FBM=1			

			DELETE FROM FBMSchemeOpen
	
			INSERT INTO FBMSchemeOpen(PrdId,FBMIn,FBMOut,Balance)			
			SELECT FBM.PrdId,SUM(FBM.DiscAmtOut) AS FBMIn,0,0
			FROM FBMTrackIn FBM,#TempSchProducts T
			WHERE FBM.PrdId=T.PrdId AND FBM.TransId<>45
			GROUP BY FBM.PrdId

			UPDATE A SET FBMOut=B.FBMOut
			FROM
			FBMSchemeOpen A,
			(SELECT FBM.PrdId,SUM(FBM.DiscAmtOut) AS FBMOut
			FROM FBMTrackOut FBM,#TempSchProducts T
			WHERE FBM.PrdId=T.PrdId AND FBM.TransId<>45 
			GROUP BY FBM.PrdId)B
			WHERE A.PrdId=B.PrdId

			INSERT INTO FBMSchemeOpen(PrdId,FBMIn,FBMOut,Balance)
			SELECT FBM.PrdId,0,SUM(FBM.DiscAmtOut) AS FBMOut,0
			FROM FBMTrackOut FBM,#TempSchProducts T
			WHERE FBM.PrdId=T.PrdId AND FBM.PrdId NOT IN (SELECT PrdId FROM FBMSchemeOpen)
			AND FBM.TransId<>45
			GROUP BY FBM.PrdId

			UPDATE FBMSchemeOpen SET Balance=FBMIn-FBMOut			
		
			DELETE FROM FBMTrackIn WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo

			INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,
			DiscAmtIn,DiscPerc,SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
			SELECT PrdId,0,@Pi_TransRefId,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,@Pi_TransRefno,1,0,0,0,Balance,100,0,Balance,
			1,1,GETDATE(),1,GETDATE(),0 FROM FBMSchemeOpen			
		END
		ELSE
		BEGIN
			SELECT A.SchId,E.PrdId
			INTO #TempSchProductsCtg
			FROM SchemeMaster A
			INNER JOIN SchemeProducts B ON A.SchId = B.SchId
			INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
			INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
			INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
			WHERE A.FBM=1 AND A.SchId=@Pi_TransRefId AND A.SchCode =@Pi_TransRefNo

			DELETE FROM FBMSchemeOpen
	
			INSERT INTO FBMSchemeOpen(PrdId,FBMIn,FBMOut,Balance)			
			SELECT FBM.PrdId,SUM(FBM.DiscAmtOut) AS FBMIn,0,0
			FROM FBMTrackIn FBM,#TempSchProductsCtg T
			WHERE FBM.PrdId=T.PrdId AND FBM.TransId<>45
			GROUP BY FBM.PrdId

			UPDATE A SET FBMOut=B.FBMOut
			FROM
			FBMSchemeOpen A,
			(SELECT FBM.PrdId,SUM(FBM.DiscAmtOut) AS FBMOut
			FROM FBMTrackOut FBM,#TempSchProductsCtg T
			WHERE FBM.PrdId=T.PrdId AND FBM.TransId<>45
			GROUP BY FBM.PrdId)B
			WHERE A.PrdId=B.PrdId

			INSERT INTO FBMSchemeOpen(PrdId,FBMIn,FBMOut,Balance)
			SELECT FBM.PrdId,0,SUM(FBM.DiscAmtOut) AS FBMOut,0
			FROM FBMTrackOut FBM,#TempSchProductsCtg T
			WHERE FBM.PrdId=T.PrdId AND FBM.PrdId NOT IN (SELECT PrdId FROM FBMSchemeOpen)
			AND FBM.TransId<>45
			GROUP BY FBM.PrdId

			UPDATE FBMSchemeOpen SET Balance=FBMIn-FBMOut			

			DELETE FROM FBMTrackIn WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo

			INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,
			DiscAmtIn,DiscPerc,SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
			SELECT PrdId,0,@Pi_TransRefId,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,@Pi_TransRefno,1,0,0,0,Balance,100,0,Balance,
			1,1,GETDATE(),1,GETDATE(),0 FROM FBMSchemeOpen
		END	
	END

	EXEC Proc_UpdateFBMSchemeBudget @Pi_TransId,@Pi_TransRefNo,@Pi_TransRefId,@Pi_TransDate,@Pi_UserId,0

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-159-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_UpdateFBMSchemeBudget]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_UpdateFBMSchemeBudget]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_UpdateFBMSchemeBudget 45,'SCH1000157',157,'2010-10-09',2,0
--SELECT * FROM FBMTrackIn WHERE PrdId=272
SELECT * FROM FBMSchDetails WHERE SchId=157
SELECT Budget,* FROM SchemeMaster WHERE SchId=157
ROLLBACK TRANSACTION
*/

CREATE        PROCEDURE [dbo].[Proc_UpdateFBMSchemeBudget]
(
	@Pi_TransId		INT,
	@Pi_TransRefNo	NVARCHAR(50),
	@Pi_TransRefId	INT,
	@Pi_TransDate	DATETIME,
	@Pi_UserId		INT,
	@Po_ErrNo		INT		OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_UpdateFBMSchemeBudget
* PURPOSE		: To Track FBM(Free Bonus Merchandise)
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 16/04/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
	IF @Pi_TransId=2 OR @Pi_TransId=7
	BEGIN
		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)

		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackOut F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					

		UNION

		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackOut G ON B.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId										

		--->Added By Nanda on 08/10/2010 For PRN 
		IF @Pi_TransId=7
		BEGIN
			UPDATE S SET S.Budget=S.Budget-A.DiscAmt		
			FROM SchemeMaster S,
			(
				SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId =@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
				GROUP BY SchId
			) A
			WHERE S.FBM=1 AND S.SchId=A.SchId
			AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchvalidTill AND SchStatus=1
		END
		--->Till Here
	END

	IF @Pi_TransId=3 OR @Pi_TransId=5 OR @Pi_TransId=45
	BEGIN
		
		IF @Pi_TransId=45
		BEGIN
			DELETE FROM FBMSchDetails WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			INSERT INTO FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
			Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT TransId,TransRefId,TransRefNo,FBMDate,SchId,0,PrdId,DiscAmtOut,1,1,GETDATE(),1,GETDATE()
			FROM FBMTrackIn WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
		END
		ELSE
		BEGIN
			INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
			Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,F.DiscAmtOut,
			1,1,GETDATE(),1,GETDATE()
			FROM SchemeMaster A
			INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
			INNER JOIN Product C On B.Prdid = C.PrdId 
			INNER JOIN FBMTrackIn F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
			AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					

			UNION

			SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,G.DiscAmtOut,
			1,1,GETDATE(),1,GETDATE()
			FROM SchemeMaster A
			INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
			INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
			INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
			INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
			INNER JOIN ProductBatch F On F.PrdId = E.Prdid
			INNER JOIN FBMTrackIn G ON B.PrdId=G.PrdId AND TransId=@Pi_TransId 
			AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
		END
						
		--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
		UPDATE S SET S.Budget=A.DiscAmt
		FROM SchemeMaster S,
		(
			SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
			FROM
			(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
			WHERE TransId IN (3,5,45) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			GROUP BY SchId
			) AA LEFT OUTER JOIN
			(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
			WHERE TransId IN (7) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			GROUP BY SchId
			) BB ON AA.SchId=BB.SChId			
		) A
		WHERE S.FBM=1 AND S.SchId=A.SchId 
		AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchvalidTill AND SchStatus=1
	END
	
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-159-005

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnBudgetUtilizedForRtr]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnBudgetUtilizedForRtr]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[Fn_ReturnBudgetUtilizedForRtr]
(
	@Pi_SchId	INT,
	@Pi_RtrId	INT,
	@FromDate	DATETIME,
	@ToDate		DATETIME
)
RETURNS NUMERIC(38,6)
AS
/*********************************
* FUNCTION: Fn_ReturnBudgetUtilizedForRtr
* PURPOSE: Returns the Budget Utilized for the Selected Scheme Wise Retailer
* NOTES: 
* CREATED: Boopathy	05-12-2007
* MODIFIED 
* DATE			AUTHOR     DESCRIPTION
------------------------------------------------
* 22/04/2010	Nanda	   Added FBM Scheme	
*********************************/
BEGIN

	DECLARE @SchemeAmt 		NUMERIC(38,6)
	DECLARE @FreeValue		NUMERIC(38,6)
	DECLARE @GiftValue		NUMERIC(38,6)
	DECLARE @Points			INT
	DECLARE @RetSchemeAmt 	NUMERIC(38,6)
	DECLARE @RetFreeValue	NUMERIC(38,6)
	DECLARE @RetGiftValue	NUMERIC(38,6)
	DECLARE @RetPoints		INT
	DECLARE @WindowAmt		NUMERIC(38,6)
	DECLARE @BudgetUtilized	NUMERIC(38,6)
	DECLARE @FBMSchAmt		NUMERIC(38,6)

	SELECT @SchemeAmt = (ISNULL(SUM(FlatAmount - ReturnFlatAmount),0) + 
		ISNULL(SUM(DiscountPerAmount - ReturnDiscountPerAmount),0))
		FROM SalesInvoiceSchemeLineWise A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
		WHERE A.SchId = @Pi_SchId AND DlvSts <> 3 AND B.SalInvDate Between @FromDate and @ToDate AND B.RtrId =@Pi_RtrId

	SELECT @FreeValue = ISNULL(SUM((FreeQty - ReturnFreeQty) * D.PrdBatDetailValue),0)
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
		WHERE A.SchId = @Pi_SchId AND DlvSts <> 3 AND B.SalInvDate Between @FromDate and @ToDate AND B.RtrId =@Pi_RtrId

	SELECT @GiftValue = ISNULL(SUM((GiftQty - ReturnGiftQty) * D.PrdBatDetailValue),0)
		FROM SalesInvoiceSchemeDtFreePrd A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
		WHERE S.SchId = @Pi_SchId AND DlvSts <> 3 AND B.SalInvDate Between @FromDate and @ToDate AND B.RtrId =@Pi_RtrId

--	SELECT @Points = ISNULL(SUM(Points - ReturnPoints),0) 
--		FROM SalesInvoiceSchemeDtPoints A
--		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
--		INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
--		WHERE A.SchId = @Pi_SchId
--		AND DlvSts <> 3 AND B.SalInvDate Between @FromDate and @ToDate AND B.RtrId =@Pi_RtrId
--
--	SELECT @RetSchemeAmt = (ISNULL(SUM(ReturnFlatAmount),0) + 
--		ISNULL(SUM(ReturnDiscountPerAmount),0))
--		FROM ReturnSchemeLineDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
--		WHERE SchId = @Pi_SchId AND Status = 1 AND B.RtrId =@Pi_RtrId AND B.ReturnDate Between @FromDate and @ToDate
--
--	SELECT @RetFreeValue = ISNULL(SUM(ReturnFreeQty * D.PrdBatDetailValue),0)
--		FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
--		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
--		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
--		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
--			ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
--		WHERE SchId = @Pi_SchId AND B.Status = 1 AND B.RtrId =@Pi_RtrId AND B.ReturnDate Between @FromDate and @ToDate
--
--	SELECT @RetGiftValue = ISNULL(SUM(ReturnGiftQty * D.PrdBatDetailValue),0)
--		FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
--		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
--		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
--		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
--			ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
--		WHERE SchId = @Pi_SchId AND B.Status = 1 AND B.RtrId =@Pi_RtrId AND B.ReturnDate Between @FromDate and @ToDate
--
--	SELECT @RetPoints = ISNULL(SUM(ReturnPoints),0) FROM ReturnSchemePointsDt A
--		INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId WHERE SchId = @Pi_SchId
--		AND Status = 0 AND B.RtrId =@Pi_RtrId AND B.ReturnDate Between @FromDate and @ToDate

	SELECT @WindowAmt = ISNULL(SUM(AdjAmt),0) FROM SalesInvoiceWindowDisplay A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		WHERE SchId = @Pi_SchId AND DlvSts <> 3 AND B.RtrId =@Pi_RtrId AND B.SalInvDate Between @FromDate and @ToDate

	SELECT @WindowAmt = @WindowAmt + ISNULL(SUM(Amount),0) FROM ChequeDisbursalMaster A 
		INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo 
		WHERE TransId = @Pi_SchId AND TransType = 1 AND B.RtrId =@Pi_RtrId And A.ChqDisDate Between @FromDate and @ToDate

	SELECT @FBMSchAmt=ISNULL(SUM(DiscAmt),0) FROM FBMSchDetails WHERE SchId=@Pi_SchId AND TransId IN (2)

	SET @BudgetUtilized = (@SchemeAmt + @FreeValue + @GiftValue + @Points + @WindowAmt)
		- (@RetSchemeAmt + @RetFreeValue + @RetGiftValue + @RetPoints)+ @FBMSchAmt

	RETURN(@BudgetUtilized)
END 




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-083-026

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnBudgetUtilized]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnBudgetUtilized]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[Fn_ReturnBudgetUtilized]
(
	@Pi_SchId INT
)
RETURNS NUMERIC(38,6)
AS
/***********************************************
* FUNCTION: Fn_ReturnBudgetUtilized
* PURPOSE: Returns the Budget Utilized for the Selected Scheme
* NOTES:
* CREATED: Thrinath Kola	11-06-2007
* MODIFIED
* DATE			AUTHOR     DESCRIPTION
------------------------------------------------
* 22/04/2010	Nanda	   Added FBM Scheme	
************************************************/
BEGIN
	DECLARE @SchemeAmt 		NUMERIC(38,6)
	DECLARE @FreeValue		NUMERIC(38,6)
	DECLARE @GiftValue		NUMERIC(38,6)
	DECLARE @Points			INT
	DECLARE @RetSchemeAmt 	NUMERIC(38,6)
	DECLARE @RetFreeValue	NUMERIC(38,6)
	DECLARE @RetGiftValue	NUMERIC(38,6)
	DECLARE @RetPoints		INT
	DECLARE @WindowAmt		NUMERIC(38,6)
	DECLARE @BudgetUtilized	NUMERIC(38,6)
	DECLARE @FBMSchAmt		NUMERIC(38,6)

	SET @Points=0
	SET @RetPoints=0

	SELECT @SchemeAmt = (ISNULL(SUM(FlatAmount - ReturnFlatAmount),0) +
		ISNULL(SUM(DiscountPerAmount - ReturnDiscountPerAmount),0))
		FROM SalesInvoiceSchemeLineWise A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
		WHERE A.SchId = @Pi_SchId AND DlvSts <> 3

	SELECT @FreeValue = ISNULL(SUM((FreeQty - ReturnFreeQty) * D.PrdBatDetailValue),0)
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
		WHERE A.SchId = @Pi_SchId AND DlvSts <> 3

	SELECT @GiftValue = ISNULL(SUM((GiftQty - ReturnGiftQty) * D.PrdBatDetailValue),0)
		FROM SalesInvoiceSchemeDtFreePrd A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
		WHERE A.SchId = @Pi_SchId AND DlvSts <> 3

--	 SELECT @Points = ISNULL(SUM(Points - ReturnPoints),0) FROM SalesInvoiceSchemeDtPoints A
-- 		INNER JOIN SalesInvoice B ON A.SalId = B.SalId WHERE SchId = @Pi_SchId
-- 		AND DlvSts <> 3
--	 SELECT @RetSchemeAmt = (ISNULL(SUM(ReturnFlatAmount),0) +
-- 		ISNULL(SUM(ReturnDiscountPerAmount),0))
-- 		FROM ReturnSchemeLineDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
-- 		WHERE SchId = @Pi_SchId AND Status = 0
--
--	 SELECT @RetFreeValue = ISNULL(SUM(ReturnFreeQty * D.PrdBatDetailValue),0)
-- 		FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
-- 		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND
-- 		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON
-- 		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
--			 ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
-- 		WHERE SchId = @Pi_SchId AND B.Status = 0
--
--	 SELECT @RetGiftValue = ISNULL(SUM(ReturnGiftQty * D.PrdBatDetailValue),0)
-- 		FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
-- 		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND
-- 		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON
-- 		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
--			 ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
-- 		WHERE SchId = @Pi_SchId AND B.Status = 0
--	 SELECT @RetPoints = ISNULL(SUM(ReturnPoints),0) FROM ReturnSchemePointsDt A
-- 		INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId WHERE SchId = @Pi_SchId
-- 		AND Status = 0

	SELECT @WindowAmt = ISNULL(SUM(AdjAmt),0) FROM SalesInvoiceWindowDisplay A
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		WHERE SchId = @Pi_SchId AND DlvSts <> 3

	SELECT @WindowAmt = @WindowAmt + ISNULL(SUM(Amount),0) FROM ChequeDisbursalMaster A
		INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo
		WHERE TransId = @Pi_SchId AND TransType = 1

	SELECT @FBMSchAmt=ISNULL(SUM(DiscAmt),0) FROM FBMSchDetails WHERE SchId=@Pi_SchId AND TransId IN (2)

	SET @BudgetUtilized = (@SchemeAmt + @FreeValue + @GiftValue + @Points + @WindowAmt+ @FBMSchAmt)
	-- 	- (@RetSchemeAmt + @RetFreeValue + @RetGiftValue + @RetPoints)
	RETURN(@BudgetUtilized)

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-083-027

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnBudgetUtilizedWithOutPrimary]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnBudgetUtilizedWithOutPrimary]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SELECT dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(6)
CREATE      FUNCTION [dbo].[Fn_ReturnBudgetUtilizedWithOutPrimary]
(
	@Pi_SchId INT
)
RETURNS NUMERIC(38,6)
AS
/*********************************
* FUNCTION	: Fn_ReturnBudgetUtilized
* PURPOSE	: Returns the Budget Utilized for the Selected Scheme
* NOTES		: 
* CREATED	: Boopathy.P	08-08-2008
* MODIFIED 
* DATE			AUTHOR     DESCRIPTION
------------------------------------------------
* 22/04/2010	Nanda	   Added FBM Scheme	
*********************************/
BEGIN

	DECLARE @SchemeAmt 	NUMERIC(38,6)
	DECLARE @FreeValue	NUMERIC(38,6)
	DECLARE @GiftValue	NUMERIC(38,6)
	DECLARE @Points		INT
	DECLARE @RetSchemeAmt 	NUMERIC(38,6)
	DECLARE @RetFreeValue	NUMERIC(38,6)
	DECLARE @RetGiftValue	NUMERIC(38,6)
	DECLARE @RetPoints		INT
	DECLARE @WindowAmt	NUMERIC(38,6)
	DECLARE @BudgetUtilized	NUMERIC(38,6)
	DECLARE @FBMSchAmt		NUMERIC(38,6)

	SET @Points=0
	SET @RetPoints=0

	SELECT @SchemeAmt = (ISNULL(SUM(FlatAmount- ReturnFlatAmount),0) + 
		ISNULL(SUM((DiscountPerAmount-PrimarySchemeAmt)- (ReturnDiscountPerAmount-PrimarySchemeAmt)),0))
		FROM SalesInvoiceSchemeLineWise A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
		WHERE A.SchId = @Pi_SchId AND DlvSts <> 3


	SELECT @FreeValue = ISNULL(SUM((FreeQty - ReturnFreeQty) * D.PrdBatDetailValue),0)
		FROM SalesInvoiceSchemeDtFreePrd A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.SelRte = 1 
		INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
		WHERE A.SchId = @Pi_SchId AND DlvSts <> 3

	SELECT @GiftValue = ISNULL(SUM((GiftQty - ReturnGiftQty) * D.PrdBatDetailValue),0)
		FROM SalesInvoiceSchemeDtFreePrd A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.SelRte = 1 
		INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
		WHERE A.SchId = @Pi_SchId AND DlvSts <> 3

	SELECT @WindowAmt = ISNULL(SUM(AdjAmt),0) FROM SalesInvoiceWindowDisplay A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		WHERE SchId = @Pi_SchId AND DlvSts <> 3

	SELECT @WindowAmt = @WindowAmt + ISNULL(SUM(Amount),0) FROM ChequeDisbursalMaster A 
		INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo 
		WHERE TransId = @Pi_SchId AND TransType = 1

	SELECT @FBMSchAmt=ISNULL(SUM(DiscAmt),0) FROM FBMSchDetails WHERE SchId=@Pi_SchId AND TransId IN (2)

	SET @BudgetUtilized = (@SchemeAmt + @FreeValue + @GiftValue + @Points + @WindowAmt + @FBMSchAmt)

	RETURN(@BudgetUtilized)
END 


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-159-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ReturnSchemeApplicable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ReturnSchemeApplicable]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-- EXEC Proc_ReturnSchemeApplicable 5,32,1542,1,2,81,''
--EXEC Proc_ReturnSchemeApplicable 1,1,1,1,2,4,0
CREATE    PROCEDURE [dbo].[Proc_ReturnSchemeApplicable]
(
	@Pi_SrpId		INT,
	@Pi_RmId		INT,
	@Pi_RtrId		INT,
	@Pi_BillType		INT,
	@Pi_BillMode		INT,
	@Pi_SchId  		INT,
	@Po_Applicable 		INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ReturnSchemeApplicable
* PURPOSE	: To Return whether the Scheme is applicable for the Retailer or Not
* CREATED	: Thrinath
* CREATED DATE	: 12/04/2007
* NOTE		: General SP for Returning the whether the Scheme is applicable for the Retailer or Not
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @RetDet TABLE
	(
		RtrId 				INT,
		RtrValueClassId		INT,
		CtgMainId			INT,
		CtgLinkId           INT,
		CtgLevelId			INT,
		RtrPotentialClassId	INT,
		RtrKeyAcc			INT,
		VillageId			INT,
		CtgLinkCode         NVARCHAR(100)
	)
	DECLARE @RMDet TABLE
	(
		RMId				INT,
		RMVanRoute			INT,
		RMSRouteType		INT,
		RMLocalUpcountry	INT
	)
	DECLARE @VillageDet TABLE
	(
		VillageId			INT,
		RoadCondition		INT,
		Incomelevel			INT,
		Acceptability		INT,
		Awareness			INT
	)
	DECLARE @SchemeRetAttr TABLE
	(
		AttrType			INT,
		AttrId				INT
	)
	DECLARE @AttrType 				INT
	DECLARE	@AttrId					INT
	DECLARE @Applicable_SM			INT
	DECLARE @Applicable_RM			INT
	DECLARE @Applicable_Vill		INT
	DECLARE @Applicable_RtrLvl		INT
	DECLARE @Applicable_RtrVal		INT
	DECLARE @Applicable_VC			INT
	DECLARE @Applicable_PC			INT
	DECLARE @Applicable_Rtr			INT
	DECLARE @Applicable_BT			INT
	DECLARE @Applicable_BM			INT
	DECLARE @Applicable_RT			INT
	DECLARE @Applicable_CT			INT
	DECLARE @Applicable_VRC			INT
	DECLARE @Applicable_VI			INT
	DECLARE @Applicable_VA			INT
	DECLARE @Applicable_VAw			INT
	DECLARE @Applicable_RouteType	INT
	DECLARE @Applicable_LocUpC		INT
	DECLARE @Applicable_VanRoute	INT
	SET @Applicable_SM=0
	SET @Applicable_RM=0
	SET @Applicable_Vill=0
	SET @Applicable_RtrLvl=0
	SET @Applicable_RtrVal=0
	SET @Applicable_VC=0
	SET @Applicable_PC=0
	SET @Applicable_Rtr=0
	SET @Applicable_BT=0
	SET @Applicable_BM=0
	SET @Applicable_RT=0
	SET @Applicable_CT=0
	SET @Applicable_VRC=0
	SET @Applicable_VI=0
	SET @Applicable_VA=0
	SET @Applicable_VAw=0
	SET @Applicable_RouteType=0
	SET @Applicable_LocUpC=0
	SET @Applicable_VanRoute=0	
	SET @Po_Applicable = 1

	INSERT INTO @RetDet(RtrId,RtrValueClassId,CtgMainId,CtgLinkId,CtgLevelId,RtrPotentialClassId,RtrKeyAcc,VillageId,CtgLinkCode)
	SELECT R.RtrId,RVCM.RtrValueClassId,RC.CtgMainId,RC.CtgLinkId,RCL.CtgLevelId,
		ISNULL(RPCM.RtrPotentialClassId,0) AS RtrPotentialClassId,R.RtrKeyAcc,R.VillageId,RC.CtgLinkCode
		FROM Retailer  R INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId and R.RtrId = @Pi_RtrId
		INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
		INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
		LEFT OUTER JOIN RetailerPotentialClassmap RPCM on R.RtrId = RPCM.RtrId
		LEFT OUTER JOIN RetailerPotentialClass [RPC] on RPCM.RtrPotentialClassId = [RPC].RtrClassId
	
	INSERT INTO @RMDet(RMId,RMVanRoute,RMSRouteType,RMLocalUpcountry)
	SELECT  RMId,RMVanRoute,RMSRouteType,RMLocalUpcountry
		FROM RouteMaster RM WHERE RM.RMId = @Pi_RmId
	INSERT INTO @VillageDet(VillageId,RoadCondition,Incomelevel,Acceptability,Awareness)
	SELECT  A.VillageId,ISNULL(RoadCondition,0),ISNULL(Incomelevel,0),ISNULL(Acceptability,0),
		ISNULL(Awareness,0) FROM @RetDet A  LEFT OUTER JOIN Routevillage RV
		ON A.VillageId = RV.VillageId
	INSERT INTO @SchemeRetAttr (AttrType,AttrId)
	SELECT AttrType,AttrId FROM SchemeRetAttr  WHERE SchId = @Pi_SchId AND AttrId > 0 ORDER BY AttrType
	
	IF NOT EXISTS(SELECT AttrId FROM SchemeRetAttr WHERE SchId = @Pi_SchId AND AttrType=3)
	BEGIN
		SET @Applicable_Vill=1
	END
	IF NOT EXISTS(SELECT AttrId FROM SchemeRetAttr WHERE SchId = @Pi_SchId AND AttrType=7)
	BEGIN
		SET @Applicable_PC=1
	END
	DECLARE  CurSch1 CURSOR FOR
	SELECT DISTINCT AttrType FROM SchemeRetAttr WHERE AttrId=0 AND SchId = @Pi_SchId ORDER BY AttrType
		OPEN CurSch1
		FETCH NEXT FROM CurSch1 INTO @AttrType
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @AttrType = 1
			SET @Applicable_SM=1
		ELSE IF @AttrType =2
			SET @Applicable_RM=1
		ELSE IF @AttrType =3
			SET @Applicable_Vill=1
		ELSE IF @AttrType =4
			SET @Applicable_RtrLvl=1
		ELSE IF @AttrType =5
			SET @Applicable_RtrVal=1
		ELSE IF @AttrType =6
			SET @Applicable_VC=1
		ELSE IF @AttrType =7
			SET @Applicable_PC=1
		ELSE IF @AttrType =8
			SET @Applicable_Rtr=1
		ELSE IF @AttrType =10
			SET @Applicable_BT=1
		ELSE IF @AttrType =11
			SET @Applicable_BM=1
		ELSE IF @AttrType =12
			SET @Applicable_RT=1
		ELSE IF @AttrType =13
			SET @Applicable_CT=1
		ELSE IF @AttrType =14
			SET @Applicable_VRC=1
		ELSE IF @AttrType =15
			SET @Applicable_VI=1
		ELSE IF @AttrType =16
			SET @Applicable_VA=1
		ELSE IF @AttrType =17
			SET @Applicable_VAw=1
		ELSE IF @AttrType =18
			SET @Applicable_RouteType=1
		ELSE IF @AttrType =19
			SET @Applicable_LocUpC=1
		ELSE IF @AttrType =20
			SET @Applicable_VanRoute=1		
		
		FETCH NEXT FROM CurSch1 INTO @AttrType
	END
	CLOSE CurSch1
	DEALLOCATE CurSch1
	
	DECLARE  CurSch CURSOR FOR
	SELECT AttrType,AttrId FROM @SchemeRetAttr ORDER BY AttrType
		OPEN CurSch
		FETCH NEXT FROM CurSch INTO @AttrType,@AttrId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @AttrType = 1 AND @Applicable_SM=0		--SalesMan
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_SrpId)
				SET @Applicable_SM = 1
		END
		IF @AttrType = 2 AND @Applicable_RM=0		--Route
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_RmId)
				SET @Applicable_RM = 1
		END
		IF @AttrType = 3 AND @Applicable_Vill=0		--Village
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.VillageId AND A.AttrType = @AttrType)
				SET @Applicable_Vill = 1
		END
--		IF @AttrType = 4 AND @Applicable_RtrLvl=0		--Retailer Category Level
--		BEGIN
--			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
--						ON A.AttrId = B.CtgLevelId  AND A.AttrType = @AttrType)
--				SET @Applicable_RtrLvl = 1
--		END
		IF @AttrType = 5 AND @Applicable_RtrVal=0		--Retailer Category Level Value
		BEGIN
			IF (SELECT COUNT(A.AttrId) FROM @SchemeRetAttr A WHERE A.AttrType = 4)=1
			BEGIN
				IF EXISTS(SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN RetailerCategoryLevel B
							ON A.AttrId = B.CtgLevelId  AND A.AttrType = 4 AND LevelName='Level1')
				BEGIN
					IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.CtgLinkId AND A.AttrType = @AttrType)
							SET @Applicable_RtrVal = 1			
				END
				ELSE
				BEGIN
					IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
								ON A.AttrId = B.CtgMainId AND A.AttrType = @AttrType)
					BEGIN
						SET @Applicable_RtrVal = 1
					END
				END
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
								ON A.AttrId = B.CtgMainId AND A.AttrType = @AttrType)
				BEGIN
					SET @Applicable_RtrVal = 1
				END
			END
		END
		IF @AttrType = 6 AND @Applicable_VC=0		--Retailer Class Value
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.RtrValueClassId AND A.AttrType = @AttrType)
				SET @Applicable_VC = 1
		END
--		IF @AttrType = 7 AND @Applicable_PC=0		--Retailer Potential Class
--		BEGIN
--			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A LEFT JOIN @RetDet B
--						ON A.AttrId = B.RtrPotentialClassId AND A.AttrType = @AttrType)
--				SET @Applicable_PC = 1
--		END
		IF @AttrType = 8 AND @Applicable_Rtr=0		--Retailer
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_RtrId)
			BEGIN
				SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_RtrId
				SET @Applicable_Rtr = 1
			END
		END
		IF @AttrType = 10 AND @Applicable_BT=0		--Bill Type
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_BillType)
				SET @Applicable_BT = 1
		END
		IF @AttrType = 11 AND @Applicable_BM=0		--Bill Mode
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_BillMode)
				SET @Applicable_BM = 1
		END
		IF @AttrType = 12 AND @Applicable_RT=0		--Retailer Type
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.RtrKeyAcc AND A.AttrType = @AttrType)
				SET @Applicable_RT = 1
		END
		IF @AttrType = 13 AND @Applicable_CT=0		--Class Type
		BEGIN
			IF EXISTS (SELECT B.RtrPotentialClassId FROM @RetDet B WHERE B.RtrPotentialClassId > 0 )
				SET @Applicable_CT = 1
		END
		IF @AttrType = 14 AND @Applicable_VRC=0		--Village Road Condition
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.RoadCondition AND A.AttrType = @AttrType)
				SET @Applicable_VRC = 1
		END
		IF @AttrType = 15 AND @Applicable_VI=0		--Village Income Level
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.Incomelevel AND A.AttrType = @AttrType)
				SET @Applicable_VI = 1
		END
		IF @AttrType = 16 AND @Applicable_VA=0		--Village Acceptability
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.Acceptability AND A.AttrType = @AttrType)
				SET @Applicable_VA = 1
		END
		IF @AttrType = 17 AND @Applicable_VAw=0		--Village Awareness
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.Awareness AND A.AttrType = @AttrType)
				SET @Applicable_VAw = 1
		END
		IF @AttrType = 18 AND @Applicable_RouteType=0		--Route Type
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RMDet B
						ON A.AttrId = B.RMSRouteType AND A.AttrType = @AttrType)
				SET @Applicable_RouteType = 1
		END
		IF @AttrType = 19 AND @Applicable_LocUpC=0		--Local / UpCountry
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RMDet B
						ON A.AttrId = B.RMLocalUpcountry AND A.AttrType = @AttrType)
				SET @Applicable_LocUpC = 1
		END
		IF @AttrType = 20 AND @Applicable_VanRoute=0		--Van / NonVan Route
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RMDet B
						ON A.AttrId = B.RMVanRoute AND A.AttrType = @AttrType)
				SET @Applicable_VanRoute = 1
		END
		FETCH NEXT FROM CurSch INTO @AttrType,@AttrId
	END
	CLOSE CurSch
	DEALLOCATE CurSch
--	PRINT @Applicable_SM
--	PRINT @Applicable_RM
--	PRINT @Applicable_Vill
--	PRINT @Applicable_RtrLvl
--	PRINT @Applicable_RtrVal
--	PRINT @Applicable_VC
--	PRINT @Applicable_PC
--	PRINT @Applicable_Rtr
--	PRINT @Applicable_BT
--	PRINT @Applicable_BM
--	PRINT @Applicable_RT
--	PRINT @Applicable_CT
--	PRINT @Applicable_VRC
--	PRINT @Applicable_VI
--	PRINT @Applicable_VA
--	PRINT @Applicable_VAw
--	PRINT @Applicable_RouteType
--	PRINT @Applicable_LocUpC
--	PRINT @Applicable_VanRoute
	IF @Applicable_SM=1 AND @Applicable_RM=1 AND @Applicable_Vill=1 AND --@Applicable_RtrLvl=1 AND
	@Applicable_RtrVal=1 AND @Applicable_VC=1 AND @Applicable_PC=1 AND @Applicable_Rtr = 1 AND
	@Applicable_BT=1 AND @Applicable_BM=1 AND @Applicable_RT=1 AND @Applicable_CT=1 AND
	@Applicable_VRC=1 AND @Applicable_VI=1 AND @Applicable_VA=1 AND @Applicable_VAw=1 AND
	@Applicable_RouteType=1 AND @Applicable_LocUpC=1 AND @Applicable_VanRoute=1
	BEGIN
		SET @Po_Applicable=1
	END
	ELSE
	BEGIN
		SET @Po_Applicable=0
	END

	--->Added By Nanda on 08/10/2010 for FBM Validations
	IF @Po_Applicable=1
	BEGIN
		IF EXISTS(SELECT * FROM SchemeMaster WHERE SchId=@Pi_SchId AND FBM=1)
		BEGIN
			IF EXISTS(SELECT * FROM SchemeMaster WHERE SchId=@Pi_SchId AND Budget>0)
			BEGIN
				SET @Po_Applicable=1
			END
			ELSE
			BEGIN
				SET @Po_Applicable=0
			END
		END
	END
	--->Till Here

	--PRINT @Po_Applicable
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-159-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeMaster 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeMaster]
(
	@Po_ErrNo INT OUTPUT
)
AS
/**************************************************************************************************
* PROCEDURE	: Proc_Cn2Cs_BLSchemeMaster
* PURPOSE	: To Insert and Update records Of Scheme Master
* CREATED	: Boopathy.P on 31/12/2008
* DATE         AUTHOR       DESCRIPTION
****************************************************************************************************
* 25.08.2009   Panneer		Added BudgetAllocationNo in SchemeMaster Table
* 20.10.2009   Thiru		Added SchBasedOn in SchemeMaster Table		
* 22/04/2010   Nanda 		Added FBM
**************************************************************************************************/
SET NOCOUNT ON
BEGIN

	DECLARE @SchCode 		AS NVARCHAR(100)
	DECLARE @SchDesc 		AS NVARCHAR(200)
	DECLARE @CmpCode 		AS NVARCHAR(50)
	DECLARE @ClmAble 		AS NVARCHAR(50)
	DECLARE @ClmAmtOn 		AS NVARCHAR(50)
	DECLARE @ClmGrpCode		AS NVARCHAR(50)
	DECLARE @SelnOn			AS NVARCHAR(50)
	DECLARE @SelLvl			AS NVARCHAR(50)
	DECLARE @SchType		AS NVARCHAR(50)
	DECLARE @BatLvl			AS NVARCHAR(50)
	DECLARE @FlxSch			AS NVARCHAR(50)
	DECLARE @FlxCond		AS NVARCHAR(50)
	DECLARE @CombiSch		AS NVARCHAR(50)
	DECLARE @Range			AS NVARCHAR(50)
	DECLARE @ProRata		AS NVARCHAR(50)
	DECLARE @Qps			AS NVARCHAR(50)
	DECLARE @QpsReset		AS NVARCHAR(50)
	DECLARE @ApyQpsOn		AS NVARCHAR(50)
	DECLARE @ForEvery		AS NVARCHAR(50)
	DECLARE @SchStartDate	AS NVARCHAR(50)
	DECLARE @SchEndDate		AS NVARCHAR(50)
	DECLARE @SchBudget		AS NVARCHAR(50)
	DECLARE @EditSch		AS NVARCHAR(50)
	DECLARE @AdjDisSch		AS NVARCHAR(50)
	DECLARE @SetDisMode		AS NVARCHAR(50)
	DECLARE @SchStatus		AS NVARCHAR(50)
	DECLARE @SchBasedOn		AS NVARCHAR(50)
	DECLARE @StatusId		AS INT
	DECLARE @CmpId			AS INT
	DECLARE @ClmGrpId		AS INT
	DECLARE @CmpPrdCtgId	AS INT
	DECLARE @ClmableId		AS INT
	DECLARE @ClmAmtOnId		AS INT
	DECLARE @SelMode		AS INT
	DECLARE @SchTypeId		AS INT
	DECLARE @BatId			AS INT
	DECLARE @FlexiId		AS INT
	DECLARE @FlexiConId		AS INT
	DECLARE @CombiId		AS INT
	DECLARE @RangeId		AS INT
	DECLARE @ProRateId		AS INT
	DECLARE @QPSId			AS INT
	DECLARE @QPSResetId		AS INT
	DECLARE @AdjustSchId	AS INT
	DECLARE @ApplySchId		AS INT
	DECLARE @ForEveryId		AS INT
	DECLARE @SettleSchId	AS INT
	DECLARE @EditSchId		AS INT
	DECLARE @ChkCount		AS INT		
	DECLARE @ConFig			AS INT
	DECLARE @CmpCnt			AS INT
	DECLARE @EtlCnt			AS INT
	DECLARE @SLevel			AS INT
	DECLARE @SchBasedOnId	AS INT
	DECLARE @ErrDesc		AS NVARCHAR(1000)
	DECLARE @TabName		AS NVARCHAR(50)
	DECLARE @GetKey			AS INT
	DECLARE @GetKeyStr		AS NVARCHAR(200)
	DECLARE @Taction		AS INT
	DECLARE @sSQL			AS VARCHAR(4000)
	DECLARE @iCnt			AS INT
	DECLARE @BudgetAllocationNo	AS NVARCHAR(100)
	
	DECLARE @FBM	AS NVARCHAR(10)
	DECLARE @FBMId	AS INT

	DECLARE @FBMDate AS DATETIME

	SET @TabName = 'Etl_Prk_SchemeHD_Slabs_Rules'

	SET @Po_ErrNo =0
	SET @AdjustSchId=0
	SET @iCnt=0

	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	DECLARE @DistCode AS  NVARCHAR(50)
	SELECT @DistCode=ISNULL(DistributorCode,'') FROM Distributor

	--->Added By Nanda on 17/09/2009
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SchToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE SchToAvoid	
	END

	CREATE TABLE SchToAvoid
	(
		CmpSchCode NVARCHAR(50)
	)

	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi
	WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product'))
	BEGIN
		INSERT INTO SchToAvoid(CmpSchCode)
		SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi
		WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product')
		AND PrdCode<>'ALL'

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','CmpSchCode','Product :'+PrdCode+' not Available for Scheme:'+CmpSchCode FROM Etl_Prk_SchemeProducts_Combi
		WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product')
		AND PrdCode<>'ALL'

		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)		
		SELECT @DistCode,'Scheme',CmpSchCode,'Product',PrdCode,'','N'
		FROM Etl_Prk_SchemeProducts_Combi
		WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND 
		CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product')
		AND PrdCode<>'ALL'
	END

	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes))
	BEGIN
		INSERT INTO SchToAvoid(CmpSchCode)
		SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','Attributes','Attributes not Available for Scheme:'+CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes)
	END

	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi))
	BEGIN
		INSERT INTO SchToAvoid(CmpSchCode)
		SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','Products','Scheme Products not Available for Scheme:'+CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi)
	END

	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules))
	BEGIN
		INSERT INTO SchToAvoid(CmpSchCode)
		SELECT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','Header','Header not Available for Scheme:'+CmpSchCode FROM Etl_Prk_Scheme_OnAttributes
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules)
	END
	--->Till Here

	DECLARE Cur_SchMaster CURSOR
	FOR SELECT DISTINCT
	ISNULL([CmpSchCode],'') AS [Company Scheme Code],
	ISNULL([SchDsc],'') AS [Scheme Description],
	ISNULL([CmpCode],'') AS [Company Code],
	ISNULL([Claimable],'') AS [Claimable],
	ISNULL([ClmAmton],'') AS [Claim Amount On],
	ISNULL([ClmGroupCode],'') AS [Claim Group Code],
	ISNULL([SchemeLevelMode],'') AS [Selection On],
	ISNULL([SchLevel],'') AS [Selection Level Value],
	ISNULL([SchType],'') AS [Scheme Type],
	ISNULL([BatchLevel],'') AS [Batch Level],
	ISNULL([FlexiSch],'') AS [Flexi Scheme],
	ISNULL([FlexiSchType],'') AS [Flexi Conditional],
	ISNULL([CombiSch],'') AS [Combi Scheme],
	ISNULL([Range],'') AS [Range],
	ISNULL([ProRata],'') AS [Pro - Rata],
	ISNULL([Qps],'NO') AS [Qps],
	ISNULL([QPSReset],'') AS [Qps Reset],
	ISNULL([ApyQPSSch],'') AS [Qps Based On],
	ISNULL([PurofEvery],'') AS [Allow For Every],
	ISNULL([SchValidFrom],'') AS [Scheme Start Date],
	ISNULL([SchValidTill],'') AS [Scheme End Date],
	ISNULL([Budget],'') AS [Scheme Budget],
	ISNULL([EditScheme],'') AS [Allow Editing Scheme],
	ISNULL([AdjWinDispOnlyOnce],'0') AS [Adjust Display Once],
	ISNULL([SetWindowDisp],'') AS [Settle Display Through],
	ISNULL(SchStatus,'') AS SchStatus,
	ISNULL(BudgetAllocationNo,'') AS BudgetAllocationNo,
	ISNULL(SchBasedOn,'') AS SchemeBasedOn,
	ISNULL(FBM,'No') AS FBM
	FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'			 
	ORDER BY [Company Scheme Code]
	OPEN Cur_SchMaster
	FETCH NEXT FROM Cur_SchMaster INTO @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
	, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
	, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch,
	@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM	
	WHILE @@FETCH_STATUS=0
	BEGIN

		SET @SchBasedOn='RETAILER'
		SET @Po_ErrNo =0		

		SET @Taction = 2
		SET @iCnt=@iCnt+1
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchDesc))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Description should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (2,@TabName,'Scheme Description',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@CmpCode))= ''
		BEGIN
			SET @ErrDesc = 'Company should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (3,@TabName,'Company',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ClmAble))= ''
		BEGIN
			SET @ErrDesc = 'Claimable should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (4,@TabName,'Claimable',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ClmAmtOn))= ''
		BEGIN
			SET @ErrDesc = 'Claim Amount On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (5,@TabName,'Claim Amount On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SelnOn))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level Type should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (6,@TabName,'Scheme Level Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SelLvl))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (7,@TabName,'Scheme Level',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchType))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Type should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (8,@TabName,'Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@BatLvl))= ''
		BEGIN
			SET @ErrDesc = 'Batch Level should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (9,@TabName,'Batch Level',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@FlxSch))= ''
		BEGIN
			SET @ErrDesc = 'Flexi Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (10,@TabName,'Flexi Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@FlxCond))= ''
		BEGIN
			SET @ErrDesc = 'Flexi Scheme Type should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (11,@TabName,'Flexi Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@CombiSch))= ''
		BEGIN
			SET @ErrDesc = 'Combi Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (12,@TabName,'Combi Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@Range))= ''
		BEGIN
			SET @ErrDesc = 'Range should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (13,@TabName,'Range Based Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ProRata))= ''
		BEGIN
			SET @ErrDesc = 'Pro-Rata should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (14,@TabName,'Pro-Rata',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@Qps))= ''
		BEGIN
			SET @ErrDesc = 'QPS Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (15,@TabName,'QPS Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@QpsReset))= ''
		BEGIN
			SET @ErrDesc = 'QPS Reset should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (16,@TabName,'QPS Reset',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ApyQpsOn))= ''
		BEGIN
			SET @ErrDesc = 'Apply QPS Scheme Based On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (17,@TabName,'Apply QPS Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchStartDate))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Start Date should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (19,@TabName,'Start Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LEN(LTRIM(RTRIM(@SchStartDate)))<10
		BEGIN
			SET @ErrDesc = 'Scheme Start Date is not Date Format for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (20,@TabName,'Scheme Start Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF ISDATE(LTRIM(RTRIM(@SchStartDate))) = 0
		BEGIN
			SET @ErrDesc = 'Invalid Scheme Start Date for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (21,@TabName,'Scheme Start Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchEndDate))= ''
		BEGIN
			SET @ErrDesc = 'Scheme End Date should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (23,@TabName,'End Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LEN(LTRIM(RTRIM(@SchEndDate)))<10
		BEGIN
			SET @ErrDesc = 'Scheme End Date is not in Date Format for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (24,@TabName,'Scheme End Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF ISDATE(LTRIM(RTRIM(@SchEndDate))) = 0
		BEGIN
			SET @ErrDesc = 'Invalid Scheme End Date for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (25,@TabName,'Scheme End Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@EditSch))= ''
		BEGIN
			SET @ErrDesc = 'Allow Editing Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (28,@TabName,'Editing Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SetDisMode))= ''
		BEGIN
			SET @ErrDesc = 'Settle Window Display Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (30,@TabName,'Settle Window Display Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SelnOn))= ''
		BEGIN
			SET @ErrDesc = 'Selection On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (31,@TabName,'Selction On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchStatus))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Status should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (32,@TabName,'Scheme Status',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchBasedOn))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Based On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (70,@TabName,'SchemeBasedOn',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@SchBasedOn)))<> 'RETAILER') AND (UPPER(LTRIM(RTRIM(@SchBasedOn)))<> 'KEY GROUP'))
		BEGIN
			SET @ErrDesc = 'Scheme Based On should be (RETAILER OR KEY GROUP) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (71,@TabName,'SchemeBasedOn',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@SelnOn)))<> 'UDC') AND (UPPER(LTRIM(RTRIM(@SelnOn)))<> 'PRODUCT'))
		BEGIN
			SET @ErrDesc = 'Selection On should be (UDC OR PRODUCT) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (33,@TabName,'Selction On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@ClmAble)))<> 'YES') AND (UPPER(LTRIM(RTRIM(@ClmAble)))<> 'NO'))
		BEGIN
			SET @ErrDesc = 'Claimable should be (YES OR NO) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (34,@TabName,'Claimable',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@SchStatus)))<> 'ACTIVE') AND (UPPER(LTRIM(RTRIM(@SchStatus)))<> 'INACTIVE'))
		BEGIN
			SET @ErrDesc = 'Scheme Stauts should be (ACTIVE OR INACTIVE) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (35,@TabName,'Scheme Stauts',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF (UPPER(LTRIM(RTRIM(@ClmAble)))= 'YES')
		BEGIN
			IF LTRIM(RTRIM(@ClmGrpCode))= ''
			BEGIN
				SET @ErrDesc = 'Claim Group Code should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (36,@TabName,'Claim Group Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF (UPPER(LTRIM(RTRIM(@ClmAmtOn)))<> 'PURCHASE RATE' AND UPPER(LTRIM(RTRIM(@ClmAmtOn)))<> 'SELLING RATE')
		BEGIN
			SET @ErrDesc = 'Claimable Amount should be (PURCHASE RATE OR SELLING RATE) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (37,@TabName,'Claimable Amount',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF (UPPER(LTRIM(RTRIM(@SchType)))<>'WINDOW DISPLAY' AND UPPER(LTRIM(RTRIM(@SchType)))<>'AMOUNT'
		   AND UPPER(LTRIM(RTRIM(@SchType)))<>'WEIGHT' AND UPPER(LTRIM(RTRIM(@SchType)))<>'QUANTITY')
		BEGIN
			SET @ErrDesc = 'Scheme Type should be (WINDOW DISPLAY OR AMOUNT OR WEIGHT OR QUANTITY) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (38,@TabName,'Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF (UPPER(LTRIM(RTRIM(@SchType)))='WINDOW DISPLAY')
		BEGIN
			IF (UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' AND UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Batch Level should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (39,@TabName,'Batch Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme should be (NO) for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (40,@TabName,'Flexi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxCond)))<> 'UNCONDITIONAL')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme Type should be (UNCONDITIONAL) for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (41,@TabName,'Flexi Scheme Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@CombiSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Combi Scheme should be (NO) for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (42,@TabName,'Combi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Range)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Range should be (NO) for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (43,@TabName,'Range',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@ProRata)))<> 'YES' AND UPPER(LTRIM(RTRIM(@ProRata)))<> 'NO'
			   AND UPPER(LTRIM(RTRIM(@ProRata)))<> 'ACTUAL')
			BEGIN
				SET @ErrDesc = 'Pro-Rata should be (YES OR NO OR ACTUAL) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (44,@TabName,'Pro-Rata',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Qps)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS should be (NO) for WINDOW DISPLAY SCHEME for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (45,@TabName,'QPS Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@QpsReset)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS Reset should be (NO)for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (46,@TabName,'QPS Reset',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LTRIM(RTRIM(@AdjDisSch))= ''
			BEGIN
				SET @ErrDesc = 'Adjust Window Display Scheme Only Once should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (47,@TabName,'Adjust Window Display Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@SetDisMode)))<> 'CASH' AND UPPER(LTRIM(RTRIM(@SetDisMode)))<> 'CHEQUE')
			BEGIN
				SET @ErrDesc = 'Settle Window Display Should be (CASH OR CHEQUE) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (48,@TabName,'SETTLE WINDOW DISPLAY',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'DATE')
			BEGIN
				SET @ErrDesc = 'Apply QPS Scheme Should be (DATE) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (50,@TabName,'Apply QPS Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		ELSE IF (UPPER(LTRIM(RTRIM(@SchType)))='AMOUNT' AND UPPER(LTRIM(RTRIM(@SchType)))='WEIGHT'
			AND UPPER(LTRIM(RTRIM(@SchType)))='QUANTITY')
		BEGIN
			IF UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' OR UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO'
			BEGIN
				SET @ErrDesc = 'Batch Level should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (51,@TabName,'Batch Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxSch)))<> 'YES' AND UPPER(LTRIM(RTRIM(@FlxSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (52,@TabName,'Flexi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxCond)))<> 'UNCONDITIONAL' AND UPPER(LTRIM(RTRIM(@FlxCond)))<> 'CONDITIONAL')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme Type should be (UNCONDITIONAL OR CONDITIONAL) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (53,@TabName,'Flexi Scheme Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxSch)))= 'NO')
			BEGIN
				IF (UPPER(LTRIM(RTRIM(@FlxCond)))= 'CONDITIONAL')
				BEGIN
					SET @ErrDesc = 'Flexi Scheme Type should be UNCONDITIONAL When Flexi Scheme is YES for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (54,@TabName,'Flexi Scheme Type',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@CombiSch)))<> 'YES' AND UPPER(LTRIM(RTRIM(@CombiSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Combi Scheme should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (55,@TabName,'Combi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Range)))<> 'YES' AND UPPER(LTRIM(RTRIM(@Range)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Range should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (56,@TabName,'Range',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@ProRata)))<> 'YES' AND UPPER(LTRIM(RTRIM(@ProRata)))<> 'NO'
			   OR UPPER(LTRIM(RTRIM(@ProRata)))<> 'ACTUAL')
			BEGIN
				SET @ErrDesc = 'Pro-Rata should be (YES OR NO OR ACTUAL) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (57,@TabName,'Pro-Rata',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@CombiSch)))<> 'YES')
			BEGIN
				IF (UPPER(LTRIM(RTRIM(@Range)))<> 'NO')
				BEGIN
					SET @ErrDesc = 'IF COMBI SCHEME is YES, Then RANGE should be (NO) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (58,@TabName,'Range',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF (UPPER(LTRIM(RTRIM(@ProRata)))<> 'NO')
				BEGIN
					SET @ErrDesc = 'IF COMBI SCHEME is YES, Then PRO-RATA should be (NO) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (59,@TabName,'Pro-Rata',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Qps)))<> 'YES' AND UPPER(LTRIM(RTRIM(@Qps)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (60,@TabName,'QPS Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@QpsReset)))<> 'YES' AND UPPER(LTRIM(RTRIM(@QpsReset)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS Reset should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (61,@TabName,'QPS Reset',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF UPPER(LTRIM(RTRIM(@Qps)))= 'NO'
			BEGIN
				IF UPPER(LTRIM(RTRIM(@QpsReset)))= 'YES'
				BEGIN
					SET @ErrDesc = 'IF QPS SCHEME is NO, Then QPS Reset should be (NO) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (62,@TabName,'QPS Reset',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'DATE'
				BEGIN
					SET @ErrDesc = 'IF QPS SCHEME is NO,Apply QPS Scheme Should be (DATE) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (63,@TabName,'Apply QPS Scheme',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@Qps)))= 'YES'
			BEGIN
				IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'DATE' AND UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'QUANTITY'
				BEGIN
					SET @ErrDesc = 'Apply QPS Scheme Should be (DATE OR QUANTITY) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (64,@TabName,'Apply QPS Scheme',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@SetDisMode)))<> 'CASH'
			BEGIN
				SET @ErrDesc = 'Settle Window Display Should be (CASH) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (65,@TabName,'SETTLE WINDOW DISPLAY',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END

		IF @Po_ErrNo = 0
		BEGIN
			IF NOT EXISTS(SELECT CmpId FROM Company WHERE CmpCode=LTRIM(RTRIM(@CmpCode)))
			BEGIN
				SET @ErrDesc = 'Company Not Found for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (66,@TabName,'Company',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE
			BEGIN
				SELECT @CmpId=CmpId FROM Company WHERE CmpCode=LTRIM(RTRIM(@CmpCode))
			END
		END


		IF @Po_ErrNo = 0
		BEGIN

			SET @GetKey=0
			SET @GetKeyStr=''

			IF NOT EXISTS(SELECT SchId FROM SchemeMaster SM WHERE CMPID=@CmpId AND SM.CmpSchCode=LTRIM(RTRIM(@SchCode)))
			BEGIN
				SELECT @GetKey= dbo.Fn_GetPrimaryKeyInteger('SchemeMaster','SchId',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
				SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('SchemeMaster','SchCode',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))				
				SET @Taction = 2
			END
			ELSE
			BEGIN
				SELECT @GetKey=SchId,@GetKeyStr=SchCode FROM SchemeMaster WHERE CMPID=@CmpId AND CmpSchCode=LTRIM(RTRIM(@SchCode))
				SET @Taction = 1
			END
		END

		IF @GetKey=0	
		BEGIN
			SET @ErrDesc = 'Scheme Id should be greater than zero Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (67,@TabName,'Scheme Id',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END

		IF LEN(LTRIM(RTRIM(@GetKeyStr )))=''
		BEGIN
			SET @ErrDesc = 'Scheme Code should be greater than zero Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (67,@TabName,'Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END

		IF @Taction = 2
		BEGIN 
			IF @GetKey<=(SELECT ISNULL(MAX(SchId),0) AS SchId FROM SchemeMaster)
			BEGIN
				SET @ErrDesc = 'Reset the counters/Check the system date'
				INSERT INTO Errorlog VALUES (67,@TabName,'SchId',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END

		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@SchBasedOn)))= 'RETAILER'
				SET @SchBasedOnId=1
			ELSE IF UPPER(LTRIM(RTRIM(@SchBasedOn)))= 'KEY GROUP'
				SET @SchBasedOnId=2
		END 

		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@ClmAble)))='YES'
			BEGIN
				IF NOT EXISTS(SELECT ClmGrpId FROM ClaimGroupMaster WHERE ClmGrpCode=LTRIM(RTRIM(@ClmGrpCode)))
				BEGIN
					SET @ErrDesc = 'Claim Group Not Found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (67,@TabName,'Claim Group',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @ClmGrpId=ClmGrpId FROM ClaimGroupMaster WHERE ClmGrpCode=LTRIM(RTRIM(@ClmGrpCode))
				END
			END
			ELSE
			BEGIN
				SET @ClmGrpId=0
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@SelnOn)))='PRODUCT' OR UPPER(LTRIM(RTRIM(@SelnOn)))='SKU' OR UPPER(LTRIM(RTRIM(@SelnOn)))='MATERIAL'
			BEGIN
				IF NOT EXISTS(SELECT CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
					AND CmpPrdCtgName=UPPER(LTRIM(RTRIM(@SelLvl))) AND LevelName <> 'Level1')
				BEGIN
					SET @ErrDesc = 'Product Category Level Not Found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (68,@TabName,'Product Category',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
					AND CmpPrdCtgName=LTRIM(RTRIM(@SelLvl)) AND LevelName <> 'Level1'
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@SelnOn)))='UDC'
			BEGIN
				IF NOT EXISTS(SELECT DISTINCT A.UdcMasterId FROM UdcMaster A
					INNER JOIN UdcHD B ON A.MasterId=B.MasterId WHERE B.MasterId=1 AND A.COLUMNNAME=LTRIM(RTRIM(@SelLvl)))
				BEGIN
					SET @ErrDesc = 'Product Category Level Not Found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (69,@TabName,'Product Category',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @CmpPrdCtgId=A.UdcMasterId FROM UdcMaster A INNER JOIN UdcHD B ON
					A.MasterId=B.MasterId WHERE B.MasterId=1 AND A.COLUMNNAME=LTRIM(RTRIM(@SelLvl))
				END
			END
		END

		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@SchStatus)))= 'ACTIVE'
				SET @StatusId=1
			ELSE IF UPPER(LTRIM(RTRIM(@SchStatus)))= 'INACTIVE'
				SET @StatusId=0
			IF UPPER(LTRIM(RTRIM(@ClmAble)))= 'YES'
				SET @ClmableId=1
			ELSE IF UPPER(LTRIM(RTRIM(@ClmAble)))= 'NO'
				SET @ClmableId=0
			
			IF UPPER(LTRIM(RTRIM(@ClmAmtOn)))= 'PURCHASE RATE'
				SET @ClmAmtOnId=1
			ELSE IF UPPER(LTRIM(RTRIM(@ClmAmtOn)))= 'SELLING RATE'
				SET @ClmAmtOnId=2
			
			IF UPPER(LTRIM(RTRIM(@SelnOn)))= 'UDC'
				SET @SelMode=1
			ELSE IF UPPER(LTRIM(RTRIM(@SelnOn)))= 'PRODUCT'
				SET @SelMode=0
			
			IF UPPER(LTRIM(RTRIM(@SchType)))='WINDOW DISPLAY'
				SET @SchTypeId=4
			ELSE IF UPPER(LTRIM(RTRIM(@SchType)))='AMOUNT'
				SET @SchTypeId=2
			ELSE IF UPPER(LTRIM(RTRIM(@SchType)))='WEIGHT'
				SET @SchTypeId=3
			ELSE IF UPPER(LTRIM(RTRIM(@SchType)))='QUANTITY'
				SET @SchTypeId=1
			
			IF UPPER(LTRIM(RTRIM(@BatLvl)))= 'YES'
				SET @BatId=1
			ELSE IF UPPER(LTRIM(RTRIM(@BatLvl)))= 'NO'
				SET @BatId=0
			
			
			IF UPPER(LTRIM(RTRIM(@FlxSch)))= 'YES'
				SET @FlexiId=1
			ELSE IF UPPER(LTRIM(RTRIM(@FlxSch)))= 'NO'
				SET @FlexiId=0
			
			IF UPPER(LTRIM(RTRIM(@FlxCond)))= 'UNCONDITIONAL'
				SET @FlexiConId=2
			ELSE IF UPPER(LTRIM(RTRIM(@FlxCond)))= 'CONDITIONAL'
				SET @FlexiConId=1
			ELSE
				SET @FlexiConId=2
			
			IF UPPER(LTRIM(RTRIM(@CombiSch)))= 'YES'				
				SET @CombiId=1
			ELSE IF UPPER(LTRIM(RTRIM(@CombiSch)))= 'NO'
				SET @CombiId=0
			
			IF UPPER(LTRIM(RTRIM(@Range)))= 'YES'
				SET @RangeId=1
			ELSE IF UPPER(LTRIM(RTRIM(@Range)))= 'NO'
				SET @RangeId=0
			
			IF UPPER(LTRIM(RTRIM(@ProRata)))= 'YES'
				SET @ProRateId=1
			ELSE IF UPPER(LTRIM(RTRIM(@ProRata)))= 'NO'
				SET @ProRateId=0
			ELSE IF UPPER(LTRIM(RTRIM(@ProRata)))= 'ACTUAL'
				SET @ProRateId=2
			
			IF UPPER(LTRIM(RTRIM(@Qps)))= 'YES'
				SET @QPSId=1
			ELSE IF UPPER(LTRIM(RTRIM(@Qps)))= 'NO'
				SET @QPSId=0
			
			IF UPPER(LTRIM(RTRIM(@ForEvery)))= 'YES'
				SET @ForEveryId=1
			ELSE IF UPPER(LTRIM(RTRIM(@ForEvery)))= 'NO'
				SET @ForEveryId=0
			IF UPPER(LTRIM(RTRIM(@EditSch)))= 'YES'
				SET @EditSchId=0
			ELSE IF UPPER(LTRIM(RTRIM(@EditSch)))= 'NO'
				SET @EditSchId=0
			IF UPPER(LTRIM(RTRIM(@QpsReset)))= 'YES'
				SET @QPSResetId=1
			ELSE IF UPPER(LTRIM(RTRIM(@QpsReset)))= 'NO'
				SET @QPSResetId=0
			IF LTRIM(RTRIM(@SchBudget))= ''
			BEGIN
				SET @SchBudget=0
			END

			IF @SchTypeId=4
			BEGIN
				IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))= 'DATE'
					SET @ApplySchId=1
				IF UPPER(LTRIM(RTRIM(@SetDisMode)))= 'CASH'
					SET @SettleSchId=1
				ELSE IF UPPER(LTRIM(RTRIM(@SetDisMode)))= 'CHEQUE'
					SET @SettleSchId=2
				IF LTRIM(RTRIM(@AdjDisSch))= 'NO'
					SET @AdjustSchId=0
				ELSE IF LTRIM(RTRIM(@AdjDisSch))= 'YES'
					SET @AdjustSchId=1
			END
			ELSE
			BEGIN
				IF @QPSId=1
				BEGIN
					IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))= 'DATE'
						SET @ApplySchId=1
					ELSE IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))='QUANTITY'
						SET @ApplySchId=2
					SET @SettleSchId=1
				END
				ELSE
				BEGIN
					SET @SettleSchId=1
					SET @ApplySchId=1
				END
			END
		END

		IF @Po_ErrNo = 0
		BEGIN
			IF @FBM='Yes'
			BEGIN
				SET @FBMId=1
				SET @SchBudget=0
			END
			ELSE
			BEGIN
				SET @FBMId=0
			END
		END

		IF @Po_ErrNo = 0
		BEGIN
			IF @Taction=1
			BEGIN
				EXEC Proc_DependencyCheck 'SchemeMaster',@GetKey
				SELECT @ChkCount=COUNT(*) FROM TempDepCheck
				IF @ChkCount > 0
				BEGIN
					UPDATE SCHEMEMASTER SET SchValidTill=LTRIM(RTRIM(@SchEndDate)),
					Budget=@SchBudget,SchStatus=@StatusId WHERE SchId=@GetKey
				END
				ELSE
				BEGIN
					DELETE FROM SchemeProducts WHERE SchId=@GetKey
					DELETE FROM SchemeRetAttr WHERE SchId=@GetKey
					DELETE FROM SchemeSlabCombiPrds WHERE SchId=@GetKey
					DELETE FROM SchemeSlabFrePrds WHERE SchId=@GetKey
					DELETE FROM SchemeSlabMultiFrePrds WHERE SchId=@GetKey
					DELETE FROM dbo.SchemeRtrLevelValidation WHERE SchId=@GetKey
					DELETE FROM dbo.SchemeRuleSettings WHERE SchId=@GetKey
					DELETE FROM dbo.SchemeAnotherPrdDt WHERE SchId=@GetKey
					DELETE FROM dbo.SchemeAnotherPrdHd WHERE SchId=@GetKey
					DELETE FROM SchemeSlabs WHERE SchId=@GetKey
					
					UPDATE SCHEMEMASTER SET SchDsc=LTRIM(RTRIM(@SchDesc)),CmpId=@CmpId,
					Claimable=@ClmableId,ClmAmton=@ClmAmtOnId,ClmRefId=@ClmGrpId,
					SchLevelId=@CmpPrdCtgId,SchType=@SchTypeId,BatchLevel=@BatId,
					FlexiSch=@FlexiId,FlexiSchType=@FlexiConId,CombiSch=@CombiId,
					Range=@RangeId,ProRata=@ProRateId,QPS=@QPSId,QPSReset=@QPSResetId,
					SchValidFrom=LTRIM(RTRIM(@SchStartDate)),SchValidTill=LTRIM(RTRIM(@SchEndDate)),
					Budget=@SchBudget,ApyQPSSch=@ApplySchId,SetWindowDisp=@SettleSchId,
					SchemeLvlMode=@SelMode,SchStatus=@StatusId WHERE SchId=@GetKey

					INSERT INTO SchemeRuleSettings(SchId,SchConfig,SchRules,NoofBills,FromDate,ToDate,MarketVisit,ApplySchBasedOn,
					EnableRtrLvl,AllowSaving,AllowSelection,Availability,LastModBy,LastModDate,AuthId,AuthDate,CalScheme,NoOfRtr,RtrCount)
					Select SchId,0,-1,-1,NULL,NULL,-1,-1,0,0,0,1,1,LastModDate,1,LastModDate,1,0,0 from schememaster (NOLOCK) where Claimable=1
					and SchId Not In(Select SchId from SchemeRuleSettings (NOLOCK))
				END
			END
			ELSE IF @Taction=2
			BEGIN
				IF @ConFig=1
				BEGIN
					SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
					IF @CmpPrdCtgId<@SLevel
					BEGIN
						SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
						WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='NO'
						AND A.SlabId=0 AND A.SlabValue=0
	
						SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
						WHERE A.[PrdCode] IN (SELECT b.PrdCtgValCode FROM ProductCategoryValue B) AND
						A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='NO'
						AND A.SlabId=0 AND A.SlabValue=0
					END
					ELSE
					BEGIN
						SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
						WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='YES'
						AND A.SlabId=0 AND A.SlabValue=0
						SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
						WHERE A.[PrdCode] IN (SELECT PrdCCode FROM Product)
						AND  A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='YES'
						AND A.SlabId=0 AND A.SlabValue=0
					END
						IF @EtlCnt=@CmpCnt
						BEGIN
							SELECT @EtlCnt=COUNT([PrdCode]) FROM Etl_Prk_Scheme_Free_Multi_Products A (NOLOCK)
							WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode))
	
							SELECT @CmpCnt=COUNT([PrdCode]) FROM Etl_Prk_Scheme_Free_Multi_Products A (NOLOCK)
							INNER JOIN Product B ON A.[PrdCode]=b.PrdCCode
							WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode))

							IF @EtlCnt=@CmpCnt
							BEGIN	
								INSERT INTO SchemeMaster(SchId,SchCode,SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
								CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
								ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
								PurofEvery,ApyQPSSch,SetWindowDisp,Availability,LastModBy,LastModDate,AuthId,
								AuthDate,EditScheme,SchemeLvlMode,MasterType,ApplyOnMRPSelRte,ApplyOnTax,BudgetAllocationNo,AllowPrdSelc,ExcludeDM,SchBasedOn,Download,FBM)
								VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
								LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
								@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
								@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
								@ApplySchId,@SettleSchId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,
								CONVERT(VARCHAR(10),GETDATE(),121),@EditSchId,@SelMode,1,2,0,@BudgetAllocationNo,0,0,@SchBasedOnId,1,@FBMId)
				
								UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchId'
								UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchCode'

								IF @FBMId=1
								BEGIN
									SET @GetKeyStr=LTRIM(RTRIM(@GetKeyStr))
									SELECT @FBMDate=CONVERT(VARCHAR(10),GETDATE(),121)
									EXEC Proc_FBMTrack 45,@GetKeyStr,@GetKey,@FBMDate,1,0
								END

							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeRuleSettings_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM Etl_Prk_SchemeRtrLevelValidation_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM Etl_Prk_SchemeAnotherPrdHd_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM Etl_Prk_SchemeAnotherPrdDt_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeAttribute_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeProduct_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeSlabCombiPrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeSlabFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeSlabMultiFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeSlabs_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								
								INSERT INTO ETL_Prk_SchemeMaster_Temp(SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
								CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
								ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
								PurofEvery,ApyQPSSch,SetWindowDisp,EditScheme,SchemeLvlMode,UpLoadFlag,BudgetAllocationNo,SchBasedOn,Download) VALUES
								(LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
								@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
								@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
								@ApplySchId,@SettleSchId,@EditSchId,@SelMode,'N',@BudgetAllocationNo,@SchBasedOnId,1)
							END
						END
						ELSE
						BEGIN
							DELETE FROM Etl_Prk_SchemeRuleSettings_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM Etl_Prk_SchemeRtrLevelValidation_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM Etl_Prk_SchemeAnotherPrdHd_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM Etl_Prk_SchemeAnotherPrdDt_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeAttribute_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeProduct_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeSlabCombiPrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeSlabFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeSlabMultiFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeSlabs_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							
							INSERT INTO ETL_Prk_SchemeMaster_Temp(SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
							CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
							ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
							PurofEvery,ApyQPSSch,SetWindowDisp,EditScheme,SchemeLvlMode,UpLoadFlag,BudgetAllocationNo,SchBasedOn,Download) VALUES
							(LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
							@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
							@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
							@ApplySchId,@SettleSchId,@EditSchId,@SelMode,'N',@BudgetAllocationNo,@SchBasedOnId,1)
						END							
				END
				ELSE
				BEGIN
					INSERT INTO SchemeMaster(SchId,SchCode,SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
					CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
					ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
					PurofEvery,ApyQPSSch,SetWindowDisp,Availability,LastModBy,LastModDate,AuthId,
					AuthDate,EditScheme,SchemeLvlMode,MasterType,ApplyOnMRPSelRte,ApplyOnTax,BudgetAllocationNo,
					AllowPrdSelc,ExcludeDM,SchBasedOn,Download,FBM)
					VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
					LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
					@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
					@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
					@ApplySchId,@SettleSchId,1,1,convert(varchar(10),getdate(),121),1,
					convert(varchar(10),getdate(),121),@EditSchId,@SelMode,1,2,0,@BudgetAllocationNo,0,0,@SchBasedOnId,1,@FBMId)
	
					UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchId'
					UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchCode'

					INSERT INTO SchemeRuleSettings(SchId,SchConfig,SchRules,NoofBills,FromDate,ToDate,MarketVisit,ApplySchBasedOn,
					EnableRtrLvl,AllowSaving,AllowSelection,Availability,LastModBy,LastModDate,AuthId,AuthDate,CalScheme,NoOfRtr,RtrCount)
					Select SchId,0,-1,-1,NULL,NULL,-1,-1,0,0,0,1,1,LastModDate,1,LastModDate,1,0,0 from schememaster (NOLOCK) where Claimable=1
					AND SchId Not In(Select SchId from SchemeRuleSettings (NOLOCK))

					IF @FBMId=1
					BEGIN
						SET @GetKeyStr=LTRIM(RTRIM(@GetKeyStr))
						SELECT @FBMDate=CONVERT(VARCHAR(10),GETDATE(),121)
						EXEC Proc_FBMTrack 45,@GetKeyStr,@GetKey,@FBMDate,1,0
					END
				END
			END
		END

		FETCH NEXT FROM Cur_SchMaster INTO  @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
		, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
		, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch,
		@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM
	END

	CLOSE Cur_SchMaster
	DEALLOCATE Cur_SchMaster
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-159-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_FBMTrackReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_FBMTrackReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_FBMTrackReport 212,2
--SELECT * FROM TempFBMTrackReport
CREATE      Proc [dbo].[Proc_FBMTrackReport]
(
	@Pi_RptId INT,
	@Pi_UsrId INT
)
AS
/************************************************************
* VIEW	: Proc_ASRTemplate
* PURPOSE	: To get the Retailer Sales Details
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 29/03/2010
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
BEGIN
SET NOCOUNT ON
	DECLARE @FromDate AS DATETIME
	DECLARE @ToDate AS DATETIME
	DECLARE @CmpId AS INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @PrdStatus AS INT 

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))

	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId

	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))

	DECLARE  @TempFBMTrackReport TABLE 
	(
		FBMDate					DATETIME,
		PrdId					INT,
		PrdCCode				NVARCHAR(100),
		PrdName					NVARCHAR(200),
		Opening					NUMERIC(38,2),
		Purchase				NUMERIC(38,2),
		SalesReturn				NUMERIC(38,2),
		FBMIN					NUMERIC(38,2),
		Sales					NUMERIC(38,2),
		PurchaseReturn			NUMERIC(38,2),
		FBMOut					NUMERIC(38,2),
		Closing					NUMERIC(38,2)
	) 
	DELETE FROM  @TempFBMTrackReport 
	TRUNCATE TABLE TempFBMTrackReport
	INSERT INTO @TempFBMTrackReport(FBMDate,PrdId,PrdCCode,PrdName,Opening,Purchase,SalesReturn,FBMIN,Sales,
					PurchaseReturn,FBMOut,Closing)
	SELECT FBMDate,PrdId,PrdCCode,PrdName,0 AS Opening,SUM(Purchase),SUM(SalesReturn),SUM(FBMIN),
			SUM(Sales),SUM(PurchaseReturn),SUM(FBMOut),0 AS Closing FROM (
	SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,SUM(FBMIN.DiscAmtOut) AS Purchase,
			0 AS SalesReturn,0 AS FBMIN,0 AS Sales,
			0 AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackIn FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))) 
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=5
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			SUM(FBMIN.DiscAmtOut) AS SalesReturn,0 AS FBMIN,0 AS Sales,
			0 AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackIn FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=3
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			0 AS SalesReturn,SUM(FBMIN.DiscAmtOut) AS FBMIN,0 AS Sales,
			0 AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackIn FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE  (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=255
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			0 AS SalesReturn,0 AS FBMIN,SUM(FBMIN.DiscAmtOut) AS Sales,
			0 AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackOut FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=2
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			0 AS SalesReturn,0 AS FBMIN,0 AS Sales,
			SUM(FBMIN.DiscAmtOut) AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackOut FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=7
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION 
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			0 AS SalesReturn,0 AS FBMIN,0 AS Sales,
			0 AS PurchaseReturn,SUM(FBMIN.DiscAmtOut)  AS FBMOut,0 AS Closing
		  	FROM FBMTrackOut FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=255
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	) A GROUP BY PrdId,PrdCCode,PrdName,FBMDate
	

	UPDATE @TempFBMTrackReport SET Closing=ABS((Purchase+SalesReturn+FBMIN)-(Sales+PurchaseReturn+FBMOut))

	SELECT A.FBMDate,A.PrdId,SUM(Closing) Opening INTO #OpenFBM FROM @TempFBMTrackReport A,
	(
		SELECT MAX(FBMDate) AS FBMDate,PrdId  FROM @TempFBMTrackReport WHERE FBMDate < @FromDate 
		GROUP BY PrdId
	) B
	WHERE A.FBMDate=B.FBMDate AND A.PrdId=B.PrdId GROUP BY A.FBMDate,A.PrdId
	
	INSERT INTO TempFBMTrackReport(FBMDate,PrdId,PrdCCode,PrdName,Opening,Purchase,SalesReturn,FBMIN,Sales,
					PurchaseReturn,FBMOut)
	SELECT @ToDate,PrdId,PrdCCode,PrdName,0,Purchase,SalesReturn,FBMIN,Sales,
					PurchaseReturn,FBMOut FROM @TempFBMTrackReport WHERE FBMDate BETWEEN @FromDate AND @ToDate

	UPDATE TempFBMTrackReport SET Opening =OPN.Opening FROM #OpenFBM OPN,
	TempFBMTrackReport WHERE TempFBMTrackReport.PrdId=OPN.PrdId	

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-159-009

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptFBMTrackReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptFBMTrackReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_RptFBMTrackReport 212,2,0,'Corestocky',0,0,1
CREATE	PROCEDURE [dbo].[Proc_RptFBMTrackReport]
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT,  
	@Po_Errno  INT OUTPUT 
)
AS
BEGIN
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_RptFBMTrackReport
* PURPOSE: General Procedure
* NOTES:
* CREATED: MarySubashini.S	07-06-2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DECLARE @FromDate			AS DATETIME
	DECLARE @ToDate				AS DATETIME
	DECLARE @NewSnapId 			AS	INT
	DECLARE @DBNAME				AS 	NVARCHAR(50)
	DECLARE @TblName 			AS	NVARCHAR(500)
	DECLARE @TblStruct 			AS	VARCHAR(8000)
	DECLARE @TblFields 			AS	VARCHAR(8000)
	DECLARE @sSql				AS 	VARCHAR(8000)
	DECLARE @ErrNo	 			AS	INT
	DECLARE @PurDBName			AS	NVARCHAR(50)
	DECLARE @Type				AS	INT
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	CREATE          TABLE #RptFBMTrackReport
	(
		PrdId					INT,
		PrdCCode				NVARCHAR(100),
		PrdName					NVARCHAR(200),
		Opening					NUMERIC(38,2),
		Purchase				NUMERIC(38,2),
		SalesReturn				NUMERIC(38,2),
		FBMIN					NUMERIC(38,2),
		Sales					NUMERIC(38,2),
		PurchaseReturn			NUMERIC(38,2),
		FBMOut					NUMERIC(38,2),
		Closing					NUMERIC(38,2)
	)
		SET @TblName = 'RptFBMTrackReport'
		SET @TblStruct = '	PrdId					INT,
							PrdCCode				NVARCHAR(100),
							PrdName					NVARCHAR(200),
							Opening					NUMERIC(38,2),
							Purchase				NUMERIC(38,2),
							SalesReturn				NUMERIC(38,2),
							FBMIN					NUMERIC(38,2),
							Sales					NUMERIC(38,2),
							PurchaseReturn			NUMERIC(38,2),
							FBMOut					NUMERIC(38,2)
							Closing					NUMERIC(38,2)'
	SET @TblFields = 'PrdId,PrdCCode,PrdName,Opening,Purchase,SalesReturn,FBMIN,Sales,
					PurchaseReturn,FBMOut,Closing'
	IF @Pi_GetFromSnap = 1
	BEGIN
		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
		SET @DBNAME =  @DBNAME
	END
	ELSE
	BEGIN
		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo =3
		SET @DBNAME = @PI_DBNAME + @DBNAME
	END
	EXEC Proc_FBMTrackReport @Pi_RptId,@Pi_UsrId
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		
		INSERT INTO #RptFBMTrackReport (PrdId,PrdCCode,PrdName,Opening,Purchase,SalesReturn,FBMIN,Sales,
					PurchaseReturn,FBMOut,Closing)
			SELECT PrdId,PrdCCode,PrdName,Opening,SUM(Purchase),SUM(SalesReturn),SUM(FBMIN),SUM(Sales),
					SUM(PurchaseReturn),SUM(FBMOut),
					ABS(SUM(Opening)+SUM(Purchase)+SUM(SalesReturn)+SUM(FBMIN))-
					(SUM(Sales)+SUM(PurchaseReturn)+SUM(FBMOut)) AS Closing FROM TempFBMTrackReport 
			GROUP BY PrdId,PrdCCode,PrdName,Opening
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptFBMTrackReport ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ ' WHERE (FilterType = (CASE ' + CAST(@Type AS nVarchar(10)) 
			EXEC (@SSQL)
			PRINT 'Retrived Data From Purged Table'
		END
		IF @Pi_SnapRequired = 1
		   BEGIN
			SELECT @NewSnapId = @Pi_SnapId
			EXEC Proc_SnapShot_Report @NewSnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
			SET @sSql = 'INSERT INTO [' + @DBNAME + '].dbo.' + @TblName +
				'(SnapId,UserId,RptId,' + @TblFields + ')' +
				' SELECT ' + CAST(@NewSnapId AS VARCHAR(10)) +
				' ,' + CAST(@Pi_UsrId AS VARCHAR(10)) +
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptFBMTrackReport'
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		   END
	END
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		   BEGIN
			SET @SSQL = 'INSERT INTO #RptFBMTrackReport ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
				' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
				' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
				' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))
			EXEC (@SSQL)
			PRINT 'Retrived Data From Snap Shot Table'
		   END
		ELSE
		   BEGIN
	--		SET @Po_Errno = 1`
			PRINT 'DataBase or Table not Found'
			RETURN
		   END
	END
	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptFBMTrackReport
	IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='RptFBMTrackReport_Excel')
		BEGIN 
			DROP TABLE RptFBMTrackReport_Excel
			CREATE  TABLE RptFBMTrackReport_Excel
			(
				RtrId					INT,
				PrdCCode				NVARCHAR(100),
				PrdName					NVARCHAR(200),
				Opening					NUMERIC(38,2),
				Purchase				NUMERIC(38,2),
				SalesReturn				NUMERIC(38,2),
				FBMIN					NUMERIC(38,2),
				Sales					NUMERIC(38,2),
				PurchaseReturn			NUMERIC(38,2),
				FBMOut					NUMERIC(38,2),
				Closing					NUMERIC(38,2)
			)
	    END 
	ELSE
		BEGIN 
			DROP TABLE RptFBMTrackReport_Excel
			CREATE  TABLE RptFBMTrackReport_Excel
			(
				RtrId					INT,
				PrdCCode				NVARCHAR(100),
				PrdName					NVARCHAR(200),
				Opening					NUMERIC(38,2),
				Purchase				NUMERIC(38,2),
				SalesReturn				NUMERIC(38,2),
				FBMIN					NUMERIC(38,2),
				Sales					NUMERIC(38,2),
				PurchaseReturn			NUMERIC(38,2),
				FBMOut					NUMERIC(38,2),
				Closing					NUMERIC(38,2)
			)
	    END
	INSERT INTO RptFBMTrackReport_Excel  SELECT *  FROM #RptFBMTrackReport
	SELECT * FROM #RptFBMTrackReport 
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-160-001

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_FBMTrack]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_FBMTrack]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT Budget,* FROM SchemeMaster WHERE SchId IN (153,156,157)
EXEC Proc_FBMTrack 3,'SLR1000158',158,'2010-10-09',2,0
SELECT * FROM FBMTrackIn WHERE SchId=157
SELECT Budget,* FROM SchemeMaster WHERE SchId IN (153,156,157)
ROLLBACK TRANSACTION
*/
CREATE        PROCEDURE [dbo].[Proc_FBMTrack]
(
	@Pi_TransId		INT,
	@Pi_TransRefNo	NVARCHAR(50),
	@Pi_TransRefId	INT,
	@Pi_TransDate	DATETIME,
	@Pi_UserId		INT, 
	@Po_ErrNo		INT		OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_FBMTrack
* PURPOSE		: To Track FBM
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 16/04/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 2010/06/30	Nanda		 Integrated 'Upload' Flag
*********************************/
SET NOCOUNT ON
BEGIN		

	--Billing-FBM Out
	IF @Pi_TransId=2  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut-FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId

		DELETE FROM FBMTrackOut WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		DELETE FROM FBMSchDetails WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 		

		INSERT INTO FBMTrackOut(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyOut,Rate,GrossAmtOut,DiscAmtOut,DiscPerc,
		Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT SISL.PrdId,SISL.PrdBatId,SISL.SchId,SI.SalInvDate,2,@Pi_TransRefId,SI.SalInvNo,1,SIP.BaseQty,SIP.PrdUom1EditedSelRate,SIP.PrdGrossAmount,
		(SISL.FlatAmount+SISL.DiscountPerAmount),((SISL.FlatAmount+SISL.DiscountPerAmount)/SIP.PrdGrossAmount)*100,
		1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM SalesInvoice SI
		INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=@Pi_TransRefId AND SIP.SalId=SI.SalId 
		INNER JOIN SalesInvoiceSchemeLineWise SISL ON SISL.SalId=SI.SalId AND SISL.RowId=SIP.SlNo
		AND (SISL.FlatAmount+SISL.DiscountPerAmount)>0
		INNER JOIN SchemeMaster SM ON SM.SchId=SISL.SchId AND SM.FBM=1 
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut+FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,0,SUM(DiscAmtOut) AS DiscAmtOut,-1* SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId
	END

	--Billing Delivery Process Cancelled Bill-FBM Cancel
	IF @Pi_TransId=29  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut-FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId=2 AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackOut WHERE TransId=2 AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 		
		DELETE FROM FBMSchDetails WHERE TransId=2 AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 		
	END
	
	--Purchase Return-FBM Out
	IF @Pi_TransId=7  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut-FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackOut WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackOut(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyOut,Rate,GrossAmtOut,DiscAmtOut,DiscPerc,
		Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT SIP.PrdId,SIP.PrdBatId,0,SI.PurRetDate,7,@Pi_TransRefId,SI.PurRetRefNo,1,SIP.RetSalBaseQty+SIP.RetUnSalBaseQty,SIP.PrdUnitLSP,SIP.PrdGrossAmount,
		(SIP.PrdDiscount/SIP.PrdGrossAmount)*PBD.PrdBatDetailValue*(SIP.RetSalBaseQty+SIP.RetUnSalBaseQty),(SIP.PrdDiscount/SIP.PrdGrossAmount)*100,
		1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM PurchaseReturn SI
		INNER JOIN PurchaseReturnProduct SIP ON SI.PurRetId=@Pi_TransRefId AND SIP.PurRetId=SI.PurRetId AND SIP.PrdDiscount>0
		INNER JOIN ProductBatch PB ON PB.PrdId=SIP.PrdId AND PB.PrdBatId=SIP.PrdBatId   
		INNER JOIN ProductBatchDetails PBD ON PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1
		INNER JOIN BatchCreation BC ON BC.BatchSeqId=PBD.BatchSeqId AND PBD.SlNo=BC.SlNo AND BC.SelRte=1
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut+FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,0,SUM(DiscAmtOut) AS DiscAmtOut,-1* SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId
	END

	--Purchase-FBM In
	IF @Pi_TransId=5  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn-FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackIn WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,DiscAmtIn,DiscPerc,
		SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT SIP.PrdId,SIP.PrdBatId,0,SI.GoodsRcvdDate,5,@Pi_TransRefId,SI.PurRcptRefNo,1,SIP.InvBaseQty,SIP.PrdUnitLSP,SIP.PrdGrossAmount,
		SIP.PrdDiscount,(SIP.PrdDiscount/SIP.PrdGrossAmount)*100,PBD.PrdBatDetailValue,
		PBD.PrdBatDetailValue*(SIP.PrdDiscount/SIP.PrdGrossAmount)*SIP.InvBaseQty,1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM PurchaseReceipt SI
		INNER JOIN PurchaseReceiptProduct SIP ON SI.PurRcptId=@Pi_TransRefId AND SIP.PurRcptId=SI.PurRcptId AND SIP.PrdDiscount>0
		INNER JOIN ProductBatch PB ON PB.PrdId=SIP.PrdId AND PB.PrdBatId=SIP.PrdBatId   
		INNER JOIN ProductBatchDetails PBD ON PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1
		INNER JOIN BatchCreation BC ON BC.BatchSeqId=PBD.BatchSeqId AND PBD.SlNo=BC.SlNo AND BC.SelRte=1
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn+FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn,0,SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId
	END

	--Sales Return-FBM In
	IF @Pi_TransId=3  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn-FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackIn WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,DiscAmtIn,DiscPerc,
		SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT SIP.PrdId,SIP.PrdBatId,SISL.SchId,SI.ReturnDate,3,@Pi_TransRefId,SI.ReturnCode,1,SIP.BaseQty,SIP.PrdEditSelRte,SIP.PrdGrossAmt,
		SISL.ReturnFlatAmount+SISL.ReturnDiscountPerAmount,((SISL.ReturnFlatAmount+SISL.ReturnDiscountPerAmount)/SIP.PrdGrossAmt)*100,SIP.PrdEditSelRte,SISL.ReturnFlatAmount+SISL.ReturnDiscountPerAmount,
		1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM ReturnHeader SI
		INNER JOIN ReturnProduct SIP ON SI.ReturnID=@Pi_TransRefId AND SIP.ReturnID=SI.ReturnID 
		INNER JOIN ReturnSchemeLineDt SISL ON SISL.ReturnID=SI.ReturnID AND SISL.RowId=SIP.SlNo AND
		SISL.ReturnFlatAmount+SISL.ReturnDiscountPerAmount>0
		INNER JOIN SchemeMaster SM ON SM.SchId=SISL.SchId AND SM.FBM=1
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn+FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtIn>0
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn,0,SUM(DiscAmtIn) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtIn>0
		GROUP BY PrdId
	END

	--FBM Switching-FBM Out
	IF @Pi_TransId=255  
	BEGIN
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut-FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackOut WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackOut(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyOut,
		Rate,GrossAmtOut,DiscAmtOut,DiscPerc,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT PrdId,0,0,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,FBMSRefNo,1,0,0,0,
		FBMAmtTransfered,100,1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM FBMSwitchingDetails WHERE FBMSRefNo=@Pi_TransRefNo
		
		UPDATE FBML SET FBML.DiscAmtOut=FBML.DiscAmtOut+FBMO.DiscAmtOut,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtOut
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtOut 
			FROM FBMTrackOut
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,0,SUM(DiscAmtOut) AS DiscAmtOut,-1* SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId

		--FBM In
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn-FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt-FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtIn) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		DELETE FROM FBMTrackIn WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo 
		INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,DiscAmtIn,DiscPerc,
		SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
		SELECT ToPrdId,0,0,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,FBMSRefNo,1,0,0,0,FBMAmtTransfered,
		100,0,FBMAmtTransfered,1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE(),0  
		FROM FBMSwitching WHERE FBMSRefNo=@Pi_TransRefNo
		UPDATE FBML SET FBML.DiscAmtIn=FBML.DiscAmtIn+FBMO.DiscAmtIn,FBML.AvlDiscAmt=FBML.AvlDiscAmt+FBMO.DiscAmtIn
		FROM FBMLedger FBML,
		(
			SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn 
			FROM FBMTrackIn
			WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND DiscAmtOut>0 
			GROUP BY PrdId
		) FBMO
		WHERE FBML.PrdId=FBMO.PrdId
		INSERT INTO FBMLedger(PrdId,DiscAmtIn,DiscAmtOut,AvlDiscAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT PrdId,SUM(DiscAmtOut) AS DiscAmtIn,0,SUM(DiscAmtOut) AS AvlDiscAmt,1,1,GETDATE(),1,GETDATE()
		FROM FBMTrackIn
		WHERE TransId= @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo AND 
		PrdId NOT IN (SELECT PrdId FROM FBMLedger) AND DiscAmtOut>0
		GROUP BY PrdId
	END

	--Scheme Master-FBM In-Opening Balance
	IF @Pi_TransId=45  
	BEGIN

		IF NOT EXISTS(SELECT * FROM SchemeProducts WHERE SchId=@Pi_TransRefId AND PrdCtgValMainId>0)
		BEGIN

			DELETE FROM FBMTrackIn WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			--DELETE FROM FBMTrackIn WHERE SchId=@Pi_TransId

			SELECT @Pi_TransRefId AS SchId,Sp.PrdId 
			INTO #TempSchProducts
			FROM SchemeProducts SP,SchemeMaster SM		
			WHERE SM.SchId=SP.SchId AND SM.SchCode=@Pi_TransRefno AND SM.SchId=@Pi_TransRefId AND SM.FBM=1			

			DELETE FROM FBMSchemeOpen
	
			INSERT INTO FBMSchemeOpen(PrdId,FBMIn,FBMOut,Balance)			
			SELECT FBM.PrdId,SUM(FBM.DiscAmtOut) AS FBMIn,0,0
			FROM FBMTrackIn FBM,#TempSchProducts T
			WHERE FBM.PrdId=T.PrdId AND FBM.TransId<>45
			GROUP BY FBM.PrdId

			UPDATE A SET FBMOut=B.FBMOut
			FROM
			FBMSchemeOpen A,
			(SELECT FBM.PrdId,SUM(FBM.DiscAmtOut) AS FBMOut
			FROM FBMTrackOut FBM,#TempSchProducts T
			WHERE FBM.PrdId=T.PrdId AND FBM.TransId<>45 
			GROUP BY FBM.PrdId)B
			WHERE A.PrdId=B.PrdId

			INSERT INTO FBMSchemeOpen(PrdId,FBMIn,FBMOut,Balance)
			SELECT FBM.PrdId,0,SUM(FBM.DiscAmtOut) AS FBMOut,0
			FROM FBMTrackOut FBM,#TempSchProducts T
			WHERE FBM.PrdId=T.PrdId AND FBM.PrdId NOT IN (SELECT PrdId FROM FBMSchemeOpen)
			AND FBM.TransId<>45
			GROUP BY FBM.PrdId

			UPDATE FBMSchemeOpen SET Balance=FBMIn-FBMOut			
		
			INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,
			DiscAmtIn,DiscPerc,SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
			SELECT PrdId,0,@Pi_TransRefId,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,@Pi_TransRefno,1,0,0,0,Balance,100,0,Balance,
			1,1,GETDATE(),1,GETDATE(),0 FROM FBMSchemeOpen			
		END
		ELSE
		BEGIN

			DELETE FROM FBMTrackIn WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			--DELETE FROM FBMTrackIn WHERE SchId=@Pi_TransId

			SELECT A.SchId,E.PrdId
			INTO #TempSchProductsCtg
			FROM SchemeMaster A
			INNER JOIN SchemeProducts B ON A.SchId = B.SchId
			INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
			INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
			INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
			WHERE A.FBM=1 AND A.SchId=@Pi_TransRefId AND A.SchCode =@Pi_TransRefNo

			DELETE FROM FBMSchemeOpen
	
			INSERT INTO FBMSchemeOpen(PrdId,FBMIn,FBMOut,Balance)			
			SELECT FBM.PrdId,SUM(FBM.DiscAmtOut) AS FBMIn,0,0
			FROM FBMTrackIn FBM,#TempSchProductsCtg T
			WHERE FBM.PrdId=T.PrdId AND FBM.TransId<>45
			GROUP BY FBM.PrdId

			UPDATE A SET FBMOut=B.FBMOut
			FROM
			FBMSchemeOpen A,
			(SELECT FBM.PrdId,SUM(FBM.DiscAmtOut) AS FBMOut
			FROM FBMTrackOut FBM,#TempSchProductsCtg T
			WHERE FBM.PrdId=T.PrdId AND FBM.TransId<>45
			GROUP BY FBM.PrdId)B
			WHERE A.PrdId=B.PrdId

			INSERT INTO FBMSchemeOpen(PrdId,FBMIn,FBMOut,Balance)
			SELECT FBM.PrdId,0,SUM(FBM.DiscAmtOut) AS FBMOut,0
			FROM FBMTrackOut FBM,#TempSchProductsCtg T
			WHERE FBM.PrdId=T.PrdId AND FBM.PrdId NOT IN (SELECT PrdId FROM FBMSchemeOpen)
			AND FBM.TransId<>45
			GROUP BY FBM.PrdId

			UPDATE FBMSchemeOpen SET Balance=FBMIn-FBMOut			

			INSERT INTO FBMTrackIn(PrdId,PrdBatId,SchId,FBMDate,TransId,TransRefId,TransRefNo,DiscType,QtyIn,PurchaseRate,GrossAmtIn,
			DiscAmtIn,DiscPerc,SellingRate,DiscAmtOut,Availability,LastModBy,LastModDate,AuthId,AuthDate,Upload)
			SELECT PrdId,0,@Pi_TransRefId,@Pi_TransDate,@Pi_TransId,@Pi_TransRefId,@Pi_TransRefno,1,0,0,0,Balance,100,0,Balance,
			1,1,GETDATE(),1,GETDATE(),0 FROM FBMSchemeOpen
		END	
	END

	EXEC Proc_UpdateFBMSchemeBudget @Pi_TransId,@Pi_TransRefNo,@Pi_TransRefId,@Pi_TransDate,@Pi_UserId,0

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-160-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_UpdateFBMSchemeBudget]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_UpdateFBMSchemeBudget]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_UpdateFBMSchemeBudget 45,'SCH1000157',157,'2010-10-09',2,0
--SELECT * FROM FBMTrackIn WHERE PrdId=272
SELECT * FROM FBMSchDetails WHERE SchId=157
SELECT Budget,* FROM SchemeMaster WHERE SchId=157
ROLLBACK TRANSACTION
*/

CREATE        PROCEDURE [dbo].[Proc_UpdateFBMSchemeBudget]
(
	@Pi_TransId		INT,
	@Pi_TransRefNo	NVARCHAR(50),
	@Pi_TransRefId	INT,
	@Pi_TransDate	DATETIME,
	@Pi_UserId		INT,
	@Po_ErrNo		INT		OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_UpdateFBMSchemeBudget
* PURPOSE		: To Track FBM(Free Bonus Merchandise)
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 16/04/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
	IF @Pi_TransId=2 OR @Pi_TransId=7
	BEGIN
		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)

		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackOut F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					

		UNION

		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackOut G ON B.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId										

		--->Added By Nanda on 08/10/2010 For PRN 
		IF @Pi_TransId=7
		BEGIN
			UPDATE S SET S.Budget=S.Budget-A.DiscAmt		
			FROM SchemeMaster S,
			(
				SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId =@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
				GROUP BY SchId
			) A
			WHERE S.FBM=1 AND S.SchId=A.SchId
			AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill AND SchStatus=1
		END
		--->Till Here
	END

	IF @Pi_TransId=3 OR @Pi_TransId=5 OR @Pi_TransId=45
	BEGIN
		
		IF @Pi_TransId=45
		BEGIN
			DELETE FROM FBMSchDetails WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			DELETE FROM FBMSchDetails WHERE SchId=@Pi_TransRefId

			INSERT INTO FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
			Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT TransId,TransRefId,TransRefNo,FBMDate,SchId,0,PrdId,DiscAmtOut,1,1,GETDATE(),1,GETDATE()
			FROM FBMTrackIn WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo

			--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
			UPDATE S SET S.Budget=A.DiscAmt
			FROM SchemeMaster S,
			(
				SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
				FROM
				(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId = @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
				GROUP BY SchId
				) AA LEFT OUTER JOIN
				(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId IN (0)
				GROUP BY SchId
				) BB ON AA.SchId=BB.SChId			
			) A
			WHERE S.FBM=1 AND S.SchId=A.SchId 
			AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill AND SchStatus=1
		END
		ELSE
		BEGIN
			INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
			Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,F.DiscAmtOut,
			1,1,GETDATE(),1,GETDATE()
			FROM SchemeMaster A
			INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
			INNER JOIN Product C On B.Prdid = C.PrdId 
			INNER JOIN FBMTrackIn F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
			AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					

			UNION

			SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,G.DiscAmtOut,
			1,1,GETDATE(),1,GETDATE()
			FROM SchemeMaster A
			INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
			INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
			INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
			INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
			INNER JOIN ProductBatch F On F.PrdId = E.Prdid
			INNER JOIN FBMTrackIn G ON B.PrdId=G.PrdId AND TransId=@Pi_TransId 
			AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
						
			--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
			UPDATE S SET S.Budget=A.DiscAmt
			FROM SchemeMaster S,
			(
				SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
				FROM
				(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId IN (3,5,45,255) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
				GROUP BY SchId
				) AA LEFT OUTER JOIN
				(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId IN (7) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
				GROUP BY SchId
				) BB ON AA.SchId=BB.SChId			
			) A
			WHERE S.FBM=1 AND S.SchId=A.SchId 
			AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill AND SchStatus=1
		END
	END

	IF @Pi_TransId=255
	BEGIN
		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,-1*F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackOut F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					

		UNION

		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,-1*G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackOut G ON B.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId										

		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackIn F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					

		UNION

		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackIn G ON B.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		

		--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
		UPDATE S SET S.Budget=A.DiscAmt
		FROM SchemeMaster S,
		(
			SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
			FROM
			(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
			WHERE TransId IN (3,5,45,255) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			GROUP BY SchId
			) AA LEFT OUTER JOIN
			(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
			WHERE TransId IN (7) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			GROUP BY SchId
			) BB ON AA.SchId=BB.SChId			
		) A
		WHERE S.FBM=1 AND S.SchId=A.SchId 
		AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill AND SchStatus=1
	END
	
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-160-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApportionSchemeAmountInLine]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApportionSchemeAmountInLine]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--DELETE FROM ApportionSchemeDetails 
--DELETE FROM BilledPrdHdForQPSScheme
--DELETE FROM BilledPrdHdForScheme
--DELETE FROM BillAppliedSchemeHd
DELETE FROM ApportionSchemeDetails
--SELECT * FROM BillAppliedSchemeHd(NOLOCK)
EXEC Proc_ApportionSchemeAmountInLine 2,2
SELECT * FROM ApportionSchemeDetails WHERE TransId=2
ROLLBACK TRANSACTION
*/
CREATE   PROCEDURE [dbo].[Proc_ApportionSchemeAmountInLine]
(
	@Pi_UsrId   INT,
	@Pi_TransId  INT
)
AS
/*********************************
* PROCEDURE		: Proc_ApportionSchemeAmountInLine
* PURPOSE		: To Apportion the Scheme amount line wise
* CREATED		: Thrinath
* CREATED DATE	: 25/04/2007
* NOTE			: General SP for Returning Scheme amount line wise
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}       {developer}        {brief modification description}
* 28/04/2009    Nandakumar R.G    Modified for Discount Calculation on MRP with Tax
* 10/04/2010    Nandakumar R.G    Modified for QPS Scheme
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchId   INT
	DECLARE @SlabId  INT
	DECLARE @RefCode nVarChar(10)
	DECLARE @RtrId  INT
	DECLARE @PrdCnt  INT
	DECLARE @PrdBatCnt INT
	DECLARE @PrdId  INT
	DECLARE @MRP  INT
	DECLARE @WithTax INT
	DECLARE @BillSeqId  INT
	DECLARE @QPS  INT
	DECLARE @QPSDateQty  INT
	DECLARE @Combi  INT
	--NNN
	DECLARE @RtrQPSId  INT
	DECLARE @TempSchGross TABLE
	(
		SchId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	DECLARE @TempPrdGross TABLE
	(
		SchId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	DECLARE @FreeQtyDt TABLE
	(
		FreePrdid  INT,
		FreePrdBatId  INT,
		FreeQty   INT
	)
	DECLARE @FreeQtyRow TABLE
	(
		RowId   INT,
		PrdId   INT,
		PrdBatId  INT
	)
	DECLARE @PDSchID TABLE
	(
		PrdId   INT,
		PrdBatId  INT,
		PDSchId   INT,
		PDSlabId  INT
	)
	DECLARE @SchFlatAmt TABLE
	(
		SchId  INT,
		SlabId  INT,
		FlatAmt  NUMERIC(18,6),
		DiscPer  NUMERIC(18,6),
		SchType  INT
	)
	DECLARE @MoreBatch TABLE
	(
		SchId  INT,
		SlabId  INT,
		PrdId  INT,
		PrdCnt  INT,
		PrdBatCnt INT,
		SchType  INT
	)
	DECLARE @QPSGivenDisc TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @QPSGivenFlat TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @RtrQPSIds TABLE
	(
		RtrId   INT,		
		SchId   INT
	)
	DECLARE @QPSNowAvailable TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	--NNN
	DECLARE @TempSchGrossQPS TABLE
	(
		SchId   INT,
		SlabId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	--NNN
	DECLARE @TempPrdGrossQPS TABLE
	(
		SchId   INT,
		SlabId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	--NNN
	SELECT @RtrQPSId=RtrId FROM BilledPrdHdForQPSScheme WHERE TransId= @Pi_TransId AND UsrId=@Pi_UsrId
	if exists (select * from dbo.sysobjects where id = object_id(N'TP') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TP
	if exists (select * from dbo.sysobjects where id = object_id(N'TG') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TG
	if exists (select * from dbo.sysobjects where id = object_id(N'TPQ') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TPQ
	if exists (select * from dbo.sysobjects where id = object_id(N'TGQ') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TGQ
	if exists (select * from dbo.sysobjects where id = object_id(N'SchMaxSlab') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table SchMaxSlab
	SET @RtrId = (SELECT TOP 1 RtrId FROM BilledPrdHdForScheme WHERE TransID = @Pi_TransId
	AND UsrId = @Pi_Usrid)
	DECLARE  CurSchid CURSOR FOR
	SELECT DISTINCT Schid,SlabId FROM BillAppliedSchemeHd WHERE IsSelected = 1
	AND TransID = @Pi_TransId AND UsrId = @Pi_Usrid
	OPEN CurSchid
	FETCH NEXT FROM CurSchid INTO @SchId,@SlabId
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SELECT @QPS =QPS,@Combi=CombiSch,@QPSDateQty=ApyQPSSch	FROM SchemeMaster WHERE Schid=@SchId	
		SELECT @MRP=ApplyOnMRPSelRte,@WithTax=ApplyOnTax FROM SchemeMaster WHERE --MasterType=2 AND
		SchId=@SchId
		
		IF NOT EXISTS(SELECT * FROM @TempSchGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 OR (@Combi=1 AND @QPS=1)
			BEGIN
				IF EXISTS(SELECT * FROM SchemeAnotherPrdDt WHERE SchId=@SchId AND SlabId=@SlabId)
				BEGIN
					INSERT INTO @TempSchGross (SchId,GrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN SchemeAnotherPrdDt C ON A.PrdId=C.PrdId AND C.SchId=@SchId AND C.SlabId=@SlabId
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
				ELSE
				BEGIN 
					INSERT INTO @TempSchGross (SchId,GrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF  @QPS<>0 AND @Combi=0
			BEGIN
				INSERT INTO @TempSchGross (SchId,GrossAmount)
				SELECT @SchId,
				CASE @MRP
				WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
				WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
				WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
				as GrossAmount FROM BilledPrdHdForQPSScheme A
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND QPSPrd=1 AND A.SchId=@SchId
			END	
		END
		IF NOT EXISTS(SELECT * FROM @TempPrdGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 OR (@Combi=1 AND @QPS=1)
			BEGIN			
				--SELECT @SchId,@MRP,@WithTax,@SlabId	
				IF EXISTS(SELECT * FROM Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId))
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END 
				ELSE
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF @QPS<>0 AND @Combi=0
			BEGIN
--				IF @QPSDateQty=2 
--				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					AS GrossAmount FROM BilledPrdHdForQPSScheme A
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=1 AND A.SchId=@SchId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					AS GrossAmount FROM BilledPrdHdForQPSScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId
					--NNN
					IF @QPSDateQty=2 
					BEGIN
						UPDATE TPGS SET TPGS.RowId=BP.RowId
						FROM @TempPrdGross  TPGS,BilledPrdHdForQPSScheme BP
						WHERE TPGS.PrdId=BP.PrdId AND TPGS.PrdBatId=BP.PrdBatId AND UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND BP.RowId<>10000
						AND TPGS.SchId=BP.SchId
--						SELECT 'S',* FROM @TempPrdGross
--						UPDATE TPGS SET TPGS.RowId=BP.RowId
--						FROM @TempPrdGross  TPGS,
--						(
--							SELECT SchId,ISNULL(MIN(RowId),2) RowId FROM BilledPrdHdForQPSScheme
--							GROUP BY SchId
--						) AS BP
--						WHERE TPGS.SchId=BP.SchId
--						SELECT 'NS',SchId,SUM(GrossAmount) AS OtherGross FROM @TempPrdGross WHERE RowId=10000
--						GROUP BY SchID
						
						UPDATE C SET C.GrossAmount=C.GrossAmount+A.OtherGross
						FROM @TempPrdGross C,
						(SELECT SchId,SUM(GrossAmount) AS OtherGross FROM @TempPrdGross WHERE RowId=10000
						GROUP BY SchID) A,
						(SELECT SchId,ISNULL(MIN(RowId),2)  AS RowId FROM @TempPrdGross WHERE RowId<>10000 
						GROUP BY SchId) B
						WHERE A.SchId=B.SchId AND B.SchId=C.SchId AND B.RowId=C.RowId
						DELETE FROM @TempPrdGross WHERE RowId=10000
--						SELECT 'S',* FROM @TempPrdGross
					END
					ELSE
					BEGIN
						UPDATE TPGS SET TPGS.RowId=BP.RowId
						FROM @TempPrdGross  TPGS,
						(
							SELECT SchId,ISNULL(MIN(RowId),2) RowId FROM BilledPrdHdForQPSScheme
							WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
							GROUP BY SchId
						) AS BP
						WHERE TPGS.SchId=BP.SchId --AND TPGS.PrdBatId=BP.PrdBatId
					END	
					---
--				END
--				ELSE
--				BEGIN
--					SELECT 'NNN'
--					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
--					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
--					CASE @MRP
--					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
--					WHEN 2 THEN A.GrossAmount
--					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
--					AS GrossAmount FROM BilledPrdHdForQPSScheme A
--					LEFT JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
--					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
--					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=0					
--					UNION ALL
--					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
--					CASE @MRP
--					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
--					WHEN 2 THEN A.GrossAmount
--					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
--					AS GrossAmount FROM BilledPrdHdForQPSScheme A
--					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
--					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId
--				END
			END
		END
		INSERT INTO @MoreBatch SELECT SchId,SlabId,PrdId,COUNT(DISTINCT PrdId),
		COUNT(DISTINCT PrdBatId),SchType FROM BillAppliedSchemeHd
		WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId GROUP BY SchId,SlabId,PrdId,SchType
		HAVING COUNT(DISTINCT PrdBatId)> 1
		IF EXISTS (SELECT * FROM @MoreBatch WHERE SchId=@SchId AND SlabId=@SlabId)
		BEGIN
			INSERT INTO @SchFlatAmt
			SELECT SchId,SlabId,FlatAmt,DiscPer,0 FROM SchemeSlabs
			WHERE SchId=@SchId AND SlabId=@SlabId
			INSERT INTO @SchFlatAmt
			SELECT SchId,SlabId,FlatAmt,DiscPer,1 FROM SchemeAnotherPrdDt
			WHERE SchId=@SchId AND SlabId=@SlabId
		END
	FETCH NEXT FROM CurSchid INTO @SchId,@SlabId
	END
	CLOSE CurSchid
	DEALLOCATE CurSchid
	----->
	SELECT DISTINCT * INTO TG FROM @TempSchGross
	SELECT DISTINCT * INTO TP FROM @TempPrdGross
	DELETE FROM @TempPrdGross
	
	INSERT INTO @TempPrdGross
	SELECT * FROM TP 
	
	---->For Scheme on Another Product QPS
--	UPDATE TPG SET TPG.GrossAmount=(TPG.GrossAmount/TSG.BilledGross)*TSG1.GrossAmount
--	FROM @TempPrdGross TPG,(SELECT SchId,SUM(GrossAmount) AS BilledGross FROM @TempPrdGross GROUP BY SchId) TSG,
--	@TempSchGross TSG1,SchemeMaster SM 
--	WHERE TPG.SchId=TSG.SchId AND TSG.SchId=TSG1.SchId AND SM.SchId=TPG.SchId
	
	UPDATE TPG SET TPG.GrossAmount=(TPG.GrossAmount/TSG.BilledGross)*TSG1.GrossAmount
	FROM @TempPrdGross TPG,(SELECT SchId,SUM(GrossAmount) AS BilledGross FROM @TempPrdGross GROUP BY SchId) TSG,
	@TempSchGross TSG1,SchemeMaster SM ,SchemeAnotherPrdHd SMA
	WHERE TPG.SchId=TSG.SchId AND TSG.SchId=TSG1.SchId AND SM.SchId=TPG.SchId AND SM.SchId=SMA.SchId
	----->	
	DECLARE  CurMoreBatch CURSOR FOR
	SELECT DISTINCT Schid,SlabId,PrdId,PrdCnt,PrdBatCnt FROM @MoreBatch
	OPEN CurMoreBatch
	FETCH NEXT FROM CurMoreBatch INTO @SchId,@SlabId,@PrdId,@PrdCnt,@PrdBatCnt
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS (SELECT A.PrdBatId FROM StockLedger A LEFT OUTER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId
			AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0)
		BEGIN
			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
			WHERE SchId=@SchId AND SlabId=@SlabId AND PrdId=@PrdId AND
			PrdBatId NOT IN (
			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
			(SchemeAmount) > 0  AND IsSelected = 1 AND SchType=0
			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
			WHERE SchId=@SchId AND SlabId=@SlabId AND PrdId=@PrdId AND
			PrdBatId NOT IN (
			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
			(SchemeAmount) > 0  AND IsSelected = 1 AND SchType=1
		END
		--Commented By Nanda on 22/10/2009
		--  ELSE
		--  BEGIN
		--   UPDATE BillAppliedSchemeHd Set SchemeAmount=0
		--   WHERE SchId=@SchId AND SlabId=@SlabId  AND SchType=0
		--   AND PrdId=@PrdId AND IsSelected = 1 AND (SchemeAmount+SchemeDiscount)>0 AND
		--   PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
		--   WHERE SchId=@SchId AND SlabId=@SlabId
		--   AND PrdId=@PrdId  AND (SchemeAmount)>0 AND IsSelected = 1 AND SchType=0)
		--   UPDATE BillAppliedSchemeHd Set SchemeAmount=0
		--   WHERE SchId=@SchId AND SlabId=@SlabId  AND SchType=1
		--   AND PrdId=@PrdId AND IsSelected = 1 AND (SchemeAmount+SchemeDiscount)>0 AND
		--   PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
		--   WHERE SchId=@SchId AND SlabId=@SlabId
		--   AND PrdId=@PrdId  AND (SchemeAmount)>0 AND IsSelected = 1 AND SchType=1)
		--  END
		--  UPDATE BillAppliedSchemeHd Set SchemeAmount= C.FlatAmt
		--  FROM @TempPrdGross A
		--  INNER JOIN BillAppliedSchemeHd B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId
		--  INNER JOIN @SchFlatAmt C ON A.SchId=C.SchId AND B.SlabId=C.SlabId
		--  WHERE (B.SchemeAmount)>0 AND B.PrdId=@PrdId  AND B.SchType=0
		--  AND B.PrdBatId IN
		--   (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd WHERE SchId=@SchId AND SlabId=@SlabId
		--   AND PrdId=@PrdId AND  IsSelected = 1 AND (SchemeAmount)>0 AND SchType=0 )
		--
		--  UPDATE BillAppliedSchemeHd Set SchemeAmount= C.FlatAmt
		--  FROM @TempPrdGross A
		--  INNER JOIN BillAppliedSchemeHd B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId
		--  INNER JOIN @SchFlatAmt C ON A.SchId=C.SchId AND B.SlabId=C.SlabId
		--  WHERE B.SchemeAmount>0 AND B.PrdId=@PrdId  AND B.SchType=1
		--  AND B.PrdBatId IN
		--   (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd WHERE SchId=@SchId AND SlabId=@SlabId
		--   AND PrdId=@PrdId AND  IsSelected = 1 AND SchemeAmount>0 AND SchType=1 )
		--Till Here
	FETCH NEXT FROM CurMoreBatch INTO @SchId,@SlabId,@PrdId,@PrdCnt,@PrdBatCnt
	END
	CLOSE CurMoreBatch
	DEALLOCATE CurMoreBatch
	
	IF EXISTS (SELECT Status FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 )
	BEGIN
		SELECT @RefCode = Condition FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1
		INSERT INTO @PDSchID (PrdId,PrdBatId,PDSchId,PDSlabId)
		SELECT SP.PrdId,SP.PrdBatId,BAS.SchId AS PDSchId,MIN(BAS.SlabId) AS PDSlabId
		FROM @TempPrdGross SP
		INNER JOIN BillAppliedSchemeHd BAS ON SP.SchId=BAS.SchId AND SchemeDiscount>0
		INNER JOIN (SELECT DISTINCT SP1.PrdId,SP1.PrdBatId,MIN(BAS1.SchId) AS MinSchId
		FROM BillAppliedSchemeHd BAS1,@TempPrdGross SP1
		WHERE SP1.SchId=BAS1.SchId
		AND SchemeDiscount >0 AND BAS1.UsrId = @Pi_Usrid AND BAS1.TransId = @Pi_TransId
		GROUP BY SP1.PrdId,SP1.PrdBatId) AS A ON A.MinSchId=BAS.SchId AND A.PrdId=SP.PrdId
		AND A.PrdBatId=SP.PrdBatId AND BAS.UsrId = @Pi_Usrid AND BAS.TransId = @Pi_TransId
		GROUP BY SP.PrdId,SP.PrdBatId,BAS.SchId
		IF @Pi_TransId=2
		BEGIN
			DECLARE @DiscPer TABLE
			(
				PrdId  INT,
				PrdBatId INT,
				DiscPer  NUMERIC(18,6),
				GrossAmount NUMERIC(18,6),
				RowId  INT
			)
			INSERT INTO @DiscPer
			SELECT SP1.PrdId,SP1.PrdBatId,ISNULL(SUM(BAS1.SchemeDiscount),0),SP1.GrossAmount,SP1.RowId
			FROM BillAppliedSchemeHd BAS1 LEFT OUTER JOIN @TempPrdGross SP1
			ON SP1.SchId=BAS1.SchId AND SP1.PrdId=BAS1.PrdId AND SP1.PrdBatId=BAS1.PrdBatId WHERE IsSelected=1 AND
			SchemeDiscount>0 AND BAS1.UsrId = @Pi_Usrid AND BAS1.TransId = @Pi_TransId
			GROUP BY SP1.PrdId,SP1.PrdBatId,SP1.RowId,SP1.GrossAmount
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			--    (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			--SchemeAmount As SchemeAmount,
			CASE 
				WHEN QPS=1 THEN
					(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
				ELSE  
					SchemeAmount 
				END  
			As SchemeAmount,
			C.GrossAmount - (C.GrossAmount / (1  +
			(
			(
				CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
					WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
						CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) --Second Case Start
							WHEN 1 THEN  
								D.PrdBatDetailValue  
							ELSE 0 
						END     --Second Case End
					ELSE 0 
				END) + SchemeDiscount)/100))      --First Case END
			As SchemeDiscount,0 As FreeQty,
			@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount
			FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
			A.SchId = B.SchId INNER JOIN @TempPrdGross C ON A.Schid = C.SchId
			AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId and B.SchId = C.SchId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid	 		
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON C.PrdId= PD.PrdId AND
			(CASE PD.PrdBatId WHEN 0 THEN C.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			AND PD.PDSchId=A.SchId
			WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND (A.SchemeAmount + A.SchemeDiscount) > 0
			SELECT  A.RowId,A.PrdId,A.PrdBatId,D.PrdBatDetailValue,
			C.GrossAmount - (C.GrossAmount / (1  +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(F.SchId AS NVARCHAR(10))+'-'+CAST(F.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			 D.PrdBatDetailValue  END     --Second Case End
			ELSE 0 END) + DiscPer)/100)) AS SchAmt,F.SchId,F.SlabId
			INTO #TempFinal
			FROM @DiscPer A
			INNER JOIN @TempPrdGross C ON  A.PrdId = C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId AND D.PrdbatId=A.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON A.PrdId= PD.PrdId AND PD.PDSchId=C.SchId AND
			(CASE PD.PrdBatId WHEN 0 THEN A.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			INNER JOIN BillAppliedSchemeHd F ON F.SchId=PD.PDSCHID AND A.PrdId=F.PrdId AND A.PrdBatId=F.PrdBatId
			
			SELECT A.RowId,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,A.DiscPer,
			--(A.DiscPer+isnull(PrdbatDetailValue,0))/SUM(A.DiscPer+isnull(PrdbatDetailValue,0))
			(A.DiscPer+isnull(PrdbatDetailValue,0))
			as DISC,
			isnull(SUM(A.DiscPer+PrdbatDetailValue),SUM(A.DiscPer)) AS DiscSUM,ISNULL(B.SchAmt,0) AS SchAmt,
			CASE  WHEN (ISNULL(PrdbatDetailValue,0)>0 AND A.DiscPer > 0 )THEN 1
			  WHEN (ISNULL(PrdbatDetailValue,0)=0 AND A.DiscPer > 0) THEN 2
			  ELSE 3 END as Status
			INTO #TempSch1
			FROM ApportionSchemeDetails A LEFT OUTER JOIN #TempFinal B ON
			A.RowId =B.RowId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId
			AND A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.DiscPer > 0
			GROUP BY A.RowId,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,A.DiscPer,B.PrdbatDetailValue,B.SchAmt
			UPDATE #TempSch1 SET SchAmt=B.SchAmt
			FROM #TempFinal B
			WHERE  #TempSch1.RowId=B.RowId AND #TempSch1.PrdId=B.PrdId AND #TempSch1.PrdBatId=B.PrdBatId
			SELECT A.RowId,A.PrdId,A.PrdBatId,ISNULL(SUM(Disc),0) AS SUMDisc
			INTO #TempSch2
			FROM #TempSch1 A
			GROUP BY A.RowId,A.PrdId,A.PrdBatId
			UPDATE #TempSch1 SET DiscSUM=ISNULL((Disc/NULLIF(SUMDisc,0)),0)*SchAmt
			FROM #TempSch2 B
			WHERE #TempSch1.RowId=B.RowId AND #TempSch1.PrdId=B.PrdId AND #TempSch1.PrdBatId=B.PrdBatId
			UPDATE ApportionSchemeDetails SET SchemeDiscount=DiscSUM
			FROM #TempSch1 B,ApportionSchemeDetails A
			WHERE A.RowId=B.RowId AND A.PrdId = B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId AND
			A.SlabId= B.SlabId AND B.Status<3
		END
		ELSE
		BEGIN
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount,
			C.GrossAmount - (C.GrossAmount /(1 +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			D.PrdBatDetailValue  ELSE 0 END     --Second Case End
			ELSE 0 END) + SchemeDiscount)/100))       --First Case END
			As SchemeDiscount,0 As FreeQty,
			@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
			FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
			A.SchId = B.SchId AND (A.SchemeAmount + A.SchemeDiscount) > 0
			INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId AND
			A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid	 	
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON C.PrdId= PD.PrdId AND
			(CASE PD.PrdBatId WHEN 0 THEN C.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		END
	END
	ELSE
	BEGIN
		---->For Scheme on Another Product QPS
--		SELECT * FROM BillAppliedSchemeHd
--		SELECT * FROM @TempSchGross
--		SELECT * FROM @TempPrdGross
		IF EXISTS(SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		BEGIN
			SELECT DISTINCT TP.SchId,BA.SlabId,TP.PrdId,TP.PrdBatId,TP.RowId,TP.GrossAmount 
			INTO TPQ FROM BillAppliedSchemeHd BA
			INNER JOIN SchemeMaster SM ON BA.SchId=SM.SchId AND Sm.QPS=1 AND SM.QPSReset=1
			INNER JOIN @TempPrdGross TP ON TP.SchId=BA.SchId
			SELECT DISTINCT TG.SchId,BA.SlabId,TG.GrossAmount 
			INTO TGQ FROM BillAppliedSchemeHd BA
			INNER JOIN SchemeMaster SM ON BA.SchId=SM.SchId AND Sm.QPS=1 AND SM.QPSReset=1
			INNER JOIN @TempSchGross TG ON TG.SchId=BA.SchId
			
			SELECT A.SchId,A.MaxSlabId,SS.PurQty
			INTO SchMaxSlab FROM
			(SELECT SM.SchId,MAX(SS.SlabId) AS MaxSlabId
			FROM SchemeMaster SM,SchemeSlabs SS
			WHERE SM.SchId=SS.SchId AND SM.QPSReset=1 
			GROUP BY SM.SchId) A,
			SchemeSlabs SS
			WHERE A.SchId=SS.SchId AND A.MaxSlabId=SS.SlabId 
	--		SELECT * FROM TG
	--		SELECT * FROM TP
	--
	--		SELECT * FROM TGQ
	--		--SELECT * FROM SchMaxSlab 
	--		SELECT * FROM TPQ
	--		SELECT * FROM BillAppliedSchemeHd
			DECLARE @MSSchId AS INT
			DECLARE @MaxSlabId AS INT
			DECLARE @MSPurQty AS NUMERIC(38,6)
			DECLARE Cur_QPSSlabs CURSOR FOR 
			SELECT SchId,MaxSlabId,PurQty
			FROM SchMaxSlab
			OPEN Cur_QPSSlabs
			FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId,@MSPurQty
			WHILE @@FETCH_STATUS=0
			BEGIN		
				UPDATE TGQ SET GrossAmount=@MSPurQty 
				WHERE SchId=@MSSchId AND SlabId=@MaxSlabId
				UPDATE TGQ SET GrossAmount=GrossAmount-@MSPurQty 
				WHERE SchId=@MSSchId AND SlabId<@MaxSlabId
				FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId,@MSPurQty
			END
			CLOSE Cur_QPSSlabs
			DEALLOCATE Cur_QPSSlabs
			UPDATE T SET T.GrossAmount=(T.GrossAmount/TG.GrossAmount)*TGQ.GrossAmount
			FROM TPQ T,TG,TGQ
			WHERE T.SchId=TG.SchId AND TG.SchId=TGQ.SchId AND TGQ.SlabId=T.SlabId 	
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
			SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount
			,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
			@Pi_TransId AS TransId,@Pi_UsrId AS UsrId,SchemeDiscount,A.SchType
			FROM BillAppliedSchemeHd A INNER JOIN TGQ B ON
			A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
			INNER JOIN TPQ C ON A.Schid = C.SchId and B.SchId = C.SchId AND A.SlabId=B.SlabId AND B.SlabId=C.SlabId
			--AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
			WHERE A.UsrId = @Pi_UsrId AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)	
			AND SM.SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
			AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
			GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		END

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT DISTINCT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId		
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid and SM.QPS=1 	  		
		INNER JOIN SchemeAnotherPrdDt SOP ON SM.SchId=SOP.SchId AND A.SchId=SOP.SchId AND A.SlabId=SOP.SlabId
		AND A.PrdId=SOP.PrdId AND SOP.Prdid=C.PrdId 
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1 
		AND SM.SchId IN (SELECT SchId FROM SchemeAnotherPrdHd)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
		AND SM.CombiSch=0
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
--		AND C.SchId NOT IN (SELECT LEFT(CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10)),CHARINDEX('~',CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10)))-1) AS SSS
--		FROM TP GROUP BY CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))
--		HAVING COUNT(PrdBatId)>1)		
--
--		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
--		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
--		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
--		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
--		Case WHEN QPS=1 THEN
--		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
--		ELSE  SchemeAmount END  As SchemeAmount
--		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
--		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
--		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
--		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
--		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
--		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
--		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
--		AND SM.CombiSch=0
--		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
--		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
--		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
--		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
--		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
--		AND C.SchId IN (SELECT LEFT(CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10)),CHARINDEX('~',CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10)))-1) AS SSS
--		FROM TP GROUP BY CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))
--		HAVING COUNT(PrdBatId)>1)

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
		AND SM.CombiSch=1
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		---->
	END

	INSERT INTO @FreeQtyDt (FreePrdid,FreePrdBatId,FreeQty)
	--SELECT FreePrdId,FreePrdBatId,Sum(FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
	SELECT FreePrdId,FreePrdBatId,Sum(DISTINCT FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY FreePrdId,FreePrdBatId
	INSERT INTO @FreeQtyRow (RowId,PrdId,PrdBatId)
	SELECT MIN(A.RowId) as RowId,A.Prdid,A.PrdBatId FROM BilledPrdHdForScheme A
	INNER JOIN BillAppliedSchemeHd B ON A.PrdId = B.PrdId AND
	A.PrdBatid = B.PrdBatId
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND
	B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY A.Prdid,A.PrdBatId
	UPDATE ApportionSchemeDetails SET FreeQty = A.FreeQty FROM
	@FreeQtyDt A INNER JOIN @FreeQtyRow B ON
	A.FreePrdId  = B.PrdId
	WHERE ApportionSchemeDetails.RowId = B.RowId
	AND ApportionSchemeDetails.UsrId = @Pi_Usrid AND
	ApportionSchemeDetails.TransId = @Pi_TransId

	--->Added By Nanda on 20/09/2010
	SELECT * INTO #TempApp FROM ApportionSchemeDetails	
	DELETE FROM ApportionSchemeDetails
	INSERT INTO ApportionSchemeDetails
	SELECT DISTINCT * FROM #TempApp
	--->Till Here

	UPDATE ApportionSchemeDetails SET SchemeAmount=SchemeAmount+SchAmt,SchemeDiscount=SchemeDiscount+SchDisc
	FROM 
	(SELECT SchId,SUM(SchemeAmount) SchAmt,SUM(SchemeDiscount) SchDisc FROM ApportionSchemeDetails
	WHERE RowId=10000 GROUP BY SchId) A,
	(SELECT SchId,MIN(RowId) RowId FROM ApportionSchemeDetails
	GROUP BY SchId) B
	WHERE ApportionSchemeDetails.SchId =  A.SchId AND A.SchId=B.SchId 
	AND ApportionSchemeDetails.RowId=B.RowId  
	DELETE FROM ApportionSchemeDetails WHERE RowId=10000
	INSERT INTO @RtrQPSIds
	SELECT DISTINCT RtrId,SchId FROM BilledPrdHdForQPSScheme WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	
	INSERT INTO @QPSGivenDisc
	SELECT A.SchId,SUM(A.DiscountPerAmount) FROM 
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount
	FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails WHERE SchemeAmount=0) A,SchemeMaster SM ,SalesInvoice SI,
	@RtrQPSIds RQPS
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
	AND SISl.SlabId<=A.SlabId) A
	GROUP BY A.SchId

	INSERT INTO @QPSNowAvailable
	SELECT A.SchId,SUM(SchemeDiscount)-B.Amount FROM ApportionSchemeDetails A,@QPSGivenDisc B
	WHERE A.SchId=B.SchId
	GROUP BY A.SchId,B.Amount
	SELECT * FROM @QPSNowAvailable

	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-161-001
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_FBMTrackReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_FBMTrackReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_FBMTrackReport 212,2
--SELECT * FROM TempFBMTrackReport
CREATE      Proc [dbo].[Proc_FBMTrackReport]
(
	@Pi_RptId INT,
	@Pi_UsrId INT
)
AS
/************************************************************
* VIEW	: Proc_ASRTemplate
* PURPOSE	: To get the Retailer Sales Details
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 29/03/2010
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
BEGIN
SET NOCOUNT ON
	DECLARE @FromDate AS DATETIME
	DECLARE @ToDate AS DATETIME
	DECLARE @CmpId AS INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @PrdStatus AS INT 
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	DECLARE  @TempFBMTrackReport TABLE 
	(
		FBMDate					DATETIME,
		PrdId					INT,
		PrdCCode				NVARCHAR(100),
		PrdName					NVARCHAR(200),
		Opening					NUMERIC(38,2),
		Purchase				NUMERIC(38,2),
		SalesReturn				NUMERIC(38,2),
		FBMIN					NUMERIC(38,2),
		Sales					NUMERIC(38,2),
		PurchaseReturn			NUMERIC(38,2),
		FBMOut					NUMERIC(38,2),
		Closing					NUMERIC(38,2)
	) 
	DELETE FROM  @TempFBMTrackReport 
	TRUNCATE TABLE TempFBMTrackReport
	INSERT INTO @TempFBMTrackReport(FBMDate,PrdId,PrdCCode,PrdName,Opening,Purchase,SalesReturn,FBMIN,Sales,
					PurchaseReturn,FBMOut,Closing)
	SELECT FBMDate,PrdId,PrdCCode,PrdName,0 AS Opening,SUM(Purchase),SUM(SalesReturn),SUM(FBMIN),
			SUM(Sales),SUM(PurchaseReturn),SUM(FBMOut),0 AS Closing FROM (
	SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,SUM(FBMIN.DiscAmtOut) AS Purchase,
			0 AS SalesReturn,0 AS FBMIN,0 AS Sales,
			0 AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackIn FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))) 
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=5
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			SUM(FBMIN.DiscAmtOut) AS SalesReturn,0 AS FBMIN,0 AS Sales,
			0 AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackIn FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=3
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			0 AS SalesReturn,SUM(FBMIN.DiscAmtOut) AS FBMIN,0 AS Sales,
			0 AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackIn FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE  (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=255
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			0 AS SalesReturn,0 AS FBMIN,SUM(FBMIN.DiscAmtOut) AS Sales,
			0 AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackOut FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=2
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			0 AS SalesReturn,0 AS FBMIN,0 AS Sales,
			SUM(FBMIN.DiscAmtOut) AS PurchaseReturn,0 AS FBMOut,0 AS Closing
		  	FROM FBMTrackOut FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=7
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	UNION 
		SELECT FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName,0 AS Opening,0 AS Purchase,
			0 AS SalesReturn,0 AS FBMIN,0 AS Sales,
			0 AS PurchaseReturn,SUM(FBMIN.DiscAmtOut)  AS FBMOut,0 AS Closing
		  	FROM FBMTrackOut FBMIN 
				INNER JOIN Product P  ON P.PrdId=FBMIN.PrdId
		  	WHERE (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId Else 0 END) OR
				P.CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			AND	(FBMIN.PrdId = (CASE @PrdCatId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (FBMIN.PrdId = (CASE @PrdId WHEN 0 THEN FBMIN.PrdId ELSE 0 END) OR
				FBMIN.PrdId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			AND (P.PrdStatus=(CASE @PrdStatus WHEN 0 THEN P.PrdStatus ELSE 0 END ) OR
				P.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND FBMIN.PrdId NOT IN (SELECT PrdId FROM Dbo.Fn_ReturnSchemeProductForFBM(@ToDate))
			AND FBMIN.TransId=255
		GROUP BY FBMIN.FBMDate,FBMIN.PrdId,P.PrdCCode,P.PrdName
	) A GROUP BY PrdId,PrdCCode,PrdName,FBMDate
	
	UPDATE @TempFBMTrackReport SET Closing=ABS((Purchase+SalesReturn+FBMIN)-(Sales+PurchaseReturn+FBMOut))

--	SELECT A.FBMDate,A.PrdId,SUM(Closing) Opening INTO #OpenFBM FROM @TempFBMTrackReport A,
--	(
--		SELECT MAX(FBMDate) AS FBMDate,PrdId  FROM @TempFBMTrackReport WHERE FBMDate < @FromDate 
--		GROUP BY PrdId
--	) B
--	WHERE A.FBMDate=B.FBMDate AND A.PrdId=B.PrdId GROUP BY A.FBMDate,A.PrdId

	SELECT A.PrdId,SUM(OPening+Purchase+SalesReturn+FBMIn)-SUM(Sales+PurchaseReturn+FBMOut) AS Opening INTO #OpenFBM FROM @TempFBMTrackReport A
	WHERE FBMDate < @FromDate 
	GROUP BY PrdId	
	
	INSERT INTO TempFBMTrackReport(FBMDate,PrdId,PrdCCode,PrdName,Opening,Purchase,SalesReturn,FBMIN,Sales,
					PurchaseReturn,FBMOut)
	SELECT @ToDate,PrdId,PrdCCode,PrdName,0,Purchase,SalesReturn,FBMIN,Sales,
					PurchaseReturn,FBMOut FROM @TempFBMTrackReport WHERE FBMDate BETWEEN @FromDate AND @ToDate

	UPDATE TempFBMTrackReport SET Opening =OPN.Opening FROM #OpenFBM OPN,
	TempFBMTrackReport WHERE TempFBMTrackReport.PrdId=OPN.PrdId	

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApportionSchemeAmountInLine]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApportionSchemeAmountInLine]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--DELETE FROM ApportionSchemeDetails 
--DELETE FROM BilledPrdHdForQPSScheme
--DELETE FROM BilledPrdHdForScheme
--DELETE FROM BillAppliedSchemeHd
SELECT * FROM BillAppliedSchemeHd
DELETE FROM ApportionSchemeDetails
--SELECT * FROM BillAppliedSchemeHd(NOLOCK)
EXEC Proc_ApportionSchemeAmountInLine 2,2
SELECT * FROM ApportionSchemeDetails WHERE TransId=2
ROLLBACK TRANSACTION
*/
CREATE   PROCEDURE [dbo].[Proc_ApportionSchemeAmountInLine]
(
	@Pi_UsrId   INT,
	@Pi_TransId  INT
)
AS
/*********************************
* PROCEDURE		: Proc_ApportionSchemeAmountInLine
* PURPOSE		: To Apportion the Scheme amount line wise
* CREATED		: Thrinath
* CREATED DATE	: 25/04/2007
* NOTE			: General SP for Returning Scheme amount line wise
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}       {developer}        {brief modification description}
* 28/04/2009    Nandakumar R.G    Modified for Discount Calculation on MRP with Tax
* 10/04/2010    Nandakumar R.G    Modified for QPS Scheme
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchId   INT
	DECLARE @SlabId  INT
	DECLARE @RefCode nVarChar(10)
	DECLARE @RtrId  INT
	DECLARE @PrdCnt  INT
	DECLARE @PrdBatCnt INT
	DECLARE @PrdId  INT
	DECLARE @MRP  INT
	DECLARE @WithTax INT
	DECLARE @BillSeqId  INT
	DECLARE @QPS  INT
	DECLARE @QPSDateQty  INT
	DECLARE @Combi  INT
	--NNN
	DECLARE @RtrQPSId  INT
	DECLARE @TempSchGross TABLE
	(
		SchId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	DECLARE @TempPrdGross TABLE
	(
		SchId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	DECLARE @FreeQtyDt TABLE
	(
		FreePrdid  INT,
		FreePrdBatId  INT,
		FreeQty   INT
	)
	DECLARE @FreeQtyRow TABLE
	(
		RowId   INT,
		PrdId   INT,
		PrdBatId  INT
	)
	DECLARE @PDSchID TABLE
	(
		PrdId   INT,
		PrdBatId  INT,
		PDSchId   INT,
		PDSlabId  INT
	)
	DECLARE @SchFlatAmt TABLE
	(
		SchId  INT,
		SlabId  INT,
		FlatAmt  NUMERIC(18,6),
		DiscPer  NUMERIC(18,6),
		SchType  INT
	)
	DECLARE @MoreBatch TABLE
	(
		SchId  INT,
		SlabId  INT,
		PrdId  INT,
		PrdCnt  INT,
		PrdBatCnt INT,
		SchType  INT
	)
	DECLARE @QPSGivenDisc TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @QPSGivenFlat TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @RtrQPSIds TABLE
	(
		RtrId   INT,		
		SchId   INT
	)
	DECLARE @QPSNowAvailable TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	--NNN
	DECLARE @TempSchGrossQPS TABLE
	(
		SchId   INT,
		SlabId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	--NNN
	DECLARE @TempPrdGrossQPS TABLE
	(
		SchId   INT,
		SlabId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	--NNN
	SELECT @RtrQPSId=RtrId FROM BilledPrdHdForQPSScheme WHERE TransId= @Pi_TransId AND UsrId=@Pi_UsrId
	if exists (select * from dbo.sysobjects where id = object_id(N'TP') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TP
	if exists (select * from dbo.sysobjects where id = object_id(N'TG') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TG
	if exists (select * from dbo.sysobjects where id = object_id(N'TPQ') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TPQ
	if exists (select * from dbo.sysobjects where id = object_id(N'TGQ') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TGQ
	if exists (select * from dbo.sysobjects where id = object_id(N'SchMaxSlab') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table SchMaxSlab
	SET @RtrId = (SELECT TOP 1 RtrId FROM BilledPrdHdForScheme WHERE TransID = @Pi_TransId
	AND UsrId = @Pi_Usrid)
	DECLARE  CurSchid CURSOR FOR
	SELECT DISTINCT Schid,SlabId FROM BillAppliedSchemeHd WHERE IsSelected = 1
	AND TransID = @Pi_TransId AND UsrId = @Pi_Usrid
	OPEN CurSchid
	FETCH NEXT FROM CurSchid INTO @SchId,@SlabId
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SELECT @QPS =QPS,@Combi=CombiSch,@QPSDateQty=ApyQPSSch	FROM SchemeMaster WHERE Schid=@SchId	
		SELECT @MRP=ApplyOnMRPSelRte,@WithTax=ApplyOnTax FROM SchemeMaster WHERE --MasterType=2 AND
		SchId=@SchId
		
		IF NOT EXISTS(SELECT * FROM @TempSchGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 OR (@Combi=1 AND @QPS=1)
			BEGIN
				IF EXISTS(SELECT * FROM SchemeAnotherPrdDt WHERE SchId=@SchId AND SlabId=@SlabId)
				BEGIN
					INSERT INTO @TempSchGross (SchId,GrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN SchemeAnotherPrdDt C ON A.PrdId=C.PrdId AND C.SchId=@SchId AND C.SlabId=@SlabId
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
				ELSE
				BEGIN 
					INSERT INTO @TempSchGross (SchId,GrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF  @QPS<>0 AND @Combi=0
			BEGIN
				INSERT INTO @TempSchGross (SchId,GrossAmount)
				SELECT @SchId,
				CASE @MRP
				WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
				WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
				WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
				as GrossAmount FROM BilledPrdHdForQPSScheme A
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND QPSPrd=1 AND A.SchId=@SchId
			END	
		END
		IF NOT EXISTS(SELECT * FROM @TempPrdGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 OR (@Combi=1 AND @QPS=1)
			BEGIN			
				--SELECT @SchId,@MRP,@WithTax,@SlabId	
				IF EXISTS(SELECT * FROM Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId))
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END 
				ELSE
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF @QPS<>0 AND @Combi=0
			BEGIN
--				IF @QPSDateQty=2 
--				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					AS GrossAmount FROM BilledPrdHdForQPSScheme A
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=1 AND A.SchId=@SchId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					AS GrossAmount FROM BilledPrdHdForQPSScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId
					--NNN
					IF @QPSDateQty=2 
					BEGIN
						UPDATE TPGS SET TPGS.RowId=BP.RowId
						FROM @TempPrdGross  TPGS,BilledPrdHdForQPSScheme BP
						WHERE TPGS.PrdId=BP.PrdId AND TPGS.PrdBatId=BP.PrdBatId AND UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND BP.RowId<>10000
						AND TPGS.SchId=BP.SchId
--						SELECT 'S',* FROM @TempPrdGross
--						UPDATE TPGS SET TPGS.RowId=BP.RowId
--						FROM @TempPrdGross  TPGS,
--						(
--							SELECT SchId,ISNULL(MIN(RowId),2) RowId FROM BilledPrdHdForQPSScheme
--							GROUP BY SchId
--						) AS BP
--						WHERE TPGS.SchId=BP.SchId
--						SELECT 'NS',SchId,SUM(GrossAmount) AS OtherGross FROM @TempPrdGross WHERE RowId=10000
--						GROUP BY SchID
						
						UPDATE C SET C.GrossAmount=C.GrossAmount+A.OtherGross
						FROM @TempPrdGross C,
						(SELECT SchId,SUM(GrossAmount) AS OtherGross FROM @TempPrdGross WHERE RowId=10000
						GROUP BY SchID) A,
						(SELECT SchId,ISNULL(MIN(RowId),2)  AS RowId FROM @TempPrdGross WHERE RowId<>10000 
						GROUP BY SchId) B
						WHERE A.SchId=B.SchId AND B.SchId=C.SchId AND B.RowId=C.RowId
						DELETE FROM @TempPrdGross WHERE RowId=10000
--						SELECT 'S',* FROM @TempPrdGross
					END
					ELSE
					BEGIN
						UPDATE TPGS SET TPGS.RowId=BP.RowId
						FROM @TempPrdGross  TPGS,
						(
							SELECT SchId,ISNULL(MIN(RowId),2) RowId FROM BilledPrdHdForQPSScheme
							WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
							GROUP BY SchId
						) AS BP
						WHERE TPGS.SchId=BP.SchId --AND TPGS.PrdBatId=BP.PrdBatId
					END	
					---
--				END
--				ELSE
--				BEGIN
--					SELECT 'NNN'
--					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
--					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
--					CASE @MRP
--					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
--					WHEN 2 THEN A.GrossAmount
--					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
--					AS GrossAmount FROM BilledPrdHdForQPSScheme A
--					LEFT JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
--					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
--					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=0					
--					UNION ALL
--					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
--					CASE @MRP
--					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
--					WHEN 2 THEN A.GrossAmount
--					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
--					AS GrossAmount FROM BilledPrdHdForQPSScheme A
--					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
--					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId
--				END
			END
		END
		INSERT INTO @MoreBatch SELECT SchId,SlabId,PrdId,COUNT(DISTINCT PrdId),
		COUNT(DISTINCT PrdBatId),SchType FROM BillAppliedSchemeHd
		WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId GROUP BY SchId,SlabId,PrdId,SchType
		HAVING COUNT(DISTINCT PrdBatId)> 1
		IF EXISTS (SELECT * FROM @MoreBatch WHERE SchId=@SchId AND SlabId=@SlabId)
		BEGIN
			INSERT INTO @SchFlatAmt
			SELECT SchId,SlabId,FlatAmt,DiscPer,0 FROM SchemeSlabs
			WHERE SchId=@SchId AND SlabId=@SlabId
			INSERT INTO @SchFlatAmt
			SELECT SchId,SlabId,FlatAmt,DiscPer,1 FROM SchemeAnotherPrdDt
			WHERE SchId=@SchId AND SlabId=@SlabId
		END
	FETCH NEXT FROM CurSchid INTO @SchId,@SlabId
	END
	CLOSE CurSchid
	DEALLOCATE CurSchid
	----->
	SELECT DISTINCT * INTO TG FROM @TempSchGross
	SELECT DISTINCT * INTO TP FROM @TempPrdGross
	DELETE FROM @TempPrdGross
	
	INSERT INTO @TempPrdGross
	SELECT * FROM TP 
	
	---->For Scheme on Another Product QPS	
	UPDATE TPG SET TPG.GrossAmount=(TPG.GrossAmount/TSG.BilledGross)*TSG1.GrossAmount
	FROM @TempPrdGross TPG,(SELECT SchId,SUM(GrossAmount) AS BilledGross FROM @TempPrdGross GROUP BY SchId) TSG,
	@TempSchGross TSG1,SchemeMaster SM ,SchemeAnotherPrdHd SMA
	WHERE TPG.SchId=TSG.SchId AND TSG.SchId=TSG1.SchId AND SM.SchId=TPG.SchId AND SM.SchId=SMA.SchId
	----->	

	--->Commented By Nanda on 13/10/2010
--	DECLARE  CurMoreBatch CURSOR FOR
--	SELECT DISTINCT Schid,SlabId,PrdId,PrdCnt,PrdBatCnt FROM @MoreBatch
--	OPEN CurMoreBatch
--	FETCH NEXT FROM CurMoreBatch INTO @SchId,@SlabId,@PrdId,@PrdCnt,@PrdBatCnt
--	WHILE @@FETCH_STATUS = 0
--	BEGIN
--		IF EXISTS (SELECT A.PrdBatId FROM StockLedger A LEFT OUTER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId
--			AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0)
--		BEGIN
--			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
--			WHERE SchId=@SchId AND SlabId=@SlabId AND PrdId=@PrdId AND
--			PrdBatId NOT IN (
--			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
--			(SchemeAmount) > 0  AND IsSelected = 1 AND SchType=0
--
--			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
--			WHERE SchId=@SchId AND SlabId=@SlabId AND PrdId=@PrdId AND
--			PrdBatId NOT IN (
--			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
--			(SchemeAmount) > 0  AND IsSelected = 1 AND SchType=1
--		END		
--		ELSE
--		BEGIN
--			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
--			WHERE SchId=@SchId AND SlabId=@SlabId  AND SchType=0
--			AND PrdId=@PrdId AND IsSelected = 1 AND (SchemeAmount+SchemeDiscount)>0 AND
--			PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
--			WHERE SchId=@SchId AND SlabId=@SlabId
--			AND PrdId=@PrdId  AND (SchemeAmount)>0 AND IsSelected = 1 AND SchType=0)
--
--			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
--			WHERE SchId=@SchId AND SlabId=@SlabId  AND SchType=1
--			AND PrdId=@PrdId AND IsSelected = 1 AND (SchemeAmount+SchemeDiscount)>0 AND
--			PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
--			WHERE SchId=@SchId AND SlabId=@SlabId
--			AND PrdId=@PrdId  AND (SchemeAmount)>0 AND IsSelected = 1 AND SchType=1)
--		END
--
--		UPDATE BillAppliedSchemeHd Set SchemeAmount= C.FlatAmt
--		FROM @TempPrdGross A
--		INNER JOIN BillAppliedSchemeHd B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId
--		INNER JOIN @SchFlatAmt C ON A.SchId=C.SchId AND B.SlabId=C.SlabId
--		WHERE (B.SchemeAmount)>0 AND B.PrdId=@PrdId  AND B.SchType=0
--		AND B.PrdBatId IN
--		(SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd WHERE SchId=@SchId AND SlabId=@SlabId
--		AND PrdId=@PrdId AND  IsSelected = 1 AND (SchemeAmount)>0 AND SchType=0 )
--
--		UPDATE BillAppliedSchemeHd Set SchemeAmount= C.FlatAmt
--		FROM @TempPrdGross A
--		INNER JOIN BillAppliedSchemeHd B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId
--		INNER JOIN @SchFlatAmt C ON A.SchId=C.SchId AND B.SlabId=C.SlabId
--		WHERE B.SchemeAmount>0 AND B.PrdId=@PrdId  AND B.SchType=1
--		AND B.PrdBatId IN
--		(SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd WHERE SchId=@SchId AND SlabId=@SlabId
--		AND PrdId=@PrdId AND  IsSelected = 1 AND SchemeAmount>0 AND SchType=1 )
--		
--	FETCH NEXT FROM CurMoreBatch INTO @SchId,@SlabId,@PrdId,@PrdCnt,@PrdBatCnt
--	END
--	CLOSE CurMoreBatch
--	DEALLOCATE CurMoreBatch
	--->Till Here


	IF EXISTS (SELECT Status FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 )
	BEGIN
		SELECT @RefCode = Condition FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1
		INSERT INTO @PDSchID (PrdId,PrdBatId,PDSchId,PDSlabId)
		SELECT SP.PrdId,SP.PrdBatId,BAS.SchId AS PDSchId,MIN(BAS.SlabId) AS PDSlabId
		FROM @TempPrdGross SP
		INNER JOIN BillAppliedSchemeHd BAS ON SP.SchId=BAS.SchId AND SchemeDiscount>0
		INNER JOIN (SELECT DISTINCT SP1.PrdId,SP1.PrdBatId,MIN(BAS1.SchId) AS MinSchId
		FROM BillAppliedSchemeHd BAS1,@TempPrdGross SP1
		WHERE SP1.SchId=BAS1.SchId
		AND SchemeDiscount >0 AND BAS1.UsrId = @Pi_Usrid AND BAS1.TransId = @Pi_TransId
		GROUP BY SP1.PrdId,SP1.PrdBatId) AS A ON A.MinSchId=BAS.SchId AND A.PrdId=SP.PrdId
		AND A.PrdBatId=SP.PrdBatId AND BAS.UsrId = @Pi_Usrid AND BAS.TransId = @Pi_TransId
		GROUP BY SP.PrdId,SP.PrdBatId,BAS.SchId
		IF @Pi_TransId=2
		BEGIN
			DECLARE @DiscPer TABLE
			(
				PrdId  INT,
				PrdBatId INT,
				DiscPer  NUMERIC(18,6),
				GrossAmount NUMERIC(18,6),
				RowId  INT
			)
			INSERT INTO @DiscPer
			SELECT SP1.PrdId,SP1.PrdBatId,ISNULL(SUM(BAS1.SchemeDiscount),0),SP1.GrossAmount,SP1.RowId
			FROM BillAppliedSchemeHd BAS1 LEFT OUTER JOIN @TempPrdGross SP1
			ON SP1.SchId=BAS1.SchId AND SP1.PrdId=BAS1.PrdId AND SP1.PrdBatId=BAS1.PrdBatId WHERE IsSelected=1 AND
			SchemeDiscount>0 AND BAS1.UsrId = @Pi_Usrid AND BAS1.TransId = @Pi_TransId
			GROUP BY SP1.PrdId,SP1.PrdBatId,SP1.RowId,SP1.GrossAmount
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			--    (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			--SchemeAmount As SchemeAmount,
			CASE 
				WHEN QPS=1 THEN
					(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
				ELSE  
					SchemeAmount 
				END  
			As SchemeAmount,
			C.GrossAmount - (C.GrossAmount / (1  +
			(
			(
				CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
					WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
						CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) --Second Case Start
							WHEN 1 THEN  
								D.PrdBatDetailValue  
							ELSE 0 
						END     --Second Case End
					ELSE 0 
				END) + SchemeDiscount)/100))      --First Case END
			As SchemeDiscount,0 As FreeQty,
			@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount
			FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
			A.SchId = B.SchId INNER JOIN @TempPrdGross C ON A.Schid = C.SchId
			AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId and B.SchId = C.SchId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid	 		
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON C.PrdId= PD.PrdId AND
			(CASE PD.PrdBatId WHEN 0 THEN C.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			AND PD.PDSchId=A.SchId
			WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND (A.SchemeAmount + A.SchemeDiscount) > 0
			SELECT  A.RowId,A.PrdId,A.PrdBatId,D.PrdBatDetailValue,
			C.GrossAmount - (C.GrossAmount / (1  +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(F.SchId AS NVARCHAR(10))+'-'+CAST(F.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			 D.PrdBatDetailValue  END     --Second Case End
			ELSE 0 END) + DiscPer)/100)) AS SchAmt,F.SchId,F.SlabId
			INTO #TempFinal
			FROM @DiscPer A
			INNER JOIN @TempPrdGross C ON  A.PrdId = C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId AND D.PrdbatId=A.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON A.PrdId= PD.PrdId AND PD.PDSchId=C.SchId AND
			(CASE PD.PrdBatId WHEN 0 THEN A.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			INNER JOIN BillAppliedSchemeHd F ON F.SchId=PD.PDSCHID AND A.PrdId=F.PrdId AND A.PrdBatId=F.PrdBatId
			
			SELECT A.RowId,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,A.DiscPer,
			--(A.DiscPer+isnull(PrdbatDetailValue,0))/SUM(A.DiscPer+isnull(PrdbatDetailValue,0))
			(A.DiscPer+isnull(PrdbatDetailValue,0))
			as DISC,
			isnull(SUM(A.DiscPer+PrdbatDetailValue),SUM(A.DiscPer)) AS DiscSUM,ISNULL(B.SchAmt,0) AS SchAmt,
			CASE  WHEN (ISNULL(PrdbatDetailValue,0)>0 AND A.DiscPer > 0 )THEN 1
			  WHEN (ISNULL(PrdbatDetailValue,0)=0 AND A.DiscPer > 0) THEN 2
			  ELSE 3 END as Status
			INTO #TempSch1
			FROM ApportionSchemeDetails A LEFT OUTER JOIN #TempFinal B ON
			A.RowId =B.RowId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId
			AND A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.DiscPer > 0
			GROUP BY A.RowId,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,A.DiscPer,B.PrdbatDetailValue,B.SchAmt
			UPDATE #TempSch1 SET SchAmt=B.SchAmt
			FROM #TempFinal B
			WHERE  #TempSch1.RowId=B.RowId AND #TempSch1.PrdId=B.PrdId AND #TempSch1.PrdBatId=B.PrdBatId
			SELECT A.RowId,A.PrdId,A.PrdBatId,ISNULL(SUM(Disc),0) AS SUMDisc
			INTO #TempSch2
			FROM #TempSch1 A
			GROUP BY A.RowId,A.PrdId,A.PrdBatId
			UPDATE #TempSch1 SET DiscSUM=ISNULL((Disc/NULLIF(SUMDisc,0)),0)*SchAmt
			FROM #TempSch2 B
			WHERE #TempSch1.RowId=B.RowId AND #TempSch1.PrdId=B.PrdId AND #TempSch1.PrdBatId=B.PrdBatId
			UPDATE ApportionSchemeDetails SET SchemeDiscount=DiscSUM
			FROM #TempSch1 B,ApportionSchemeDetails A
			WHERE A.RowId=B.RowId AND A.PrdId = B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId AND
			A.SlabId= B.SlabId AND B.Status<3
		END
		ELSE
		BEGIN
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount,
			C.GrossAmount - (C.GrossAmount /(1 +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			D.PrdBatDetailValue  ELSE 0 END     --Second Case End
			ELSE 0 END) + SchemeDiscount)/100))       --First Case END
			As SchemeDiscount,0 As FreeQty,
			@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
			FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
			A.SchId = B.SchId AND (A.SchemeAmount + A.SchemeDiscount) > 0
			INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId AND
			A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid	 	
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON C.PrdId= PD.PrdId AND
			(CASE PD.PrdBatId WHEN 0 THEN C.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		END
	END
	ELSE
	BEGIN
		---->For Scheme on Another Product QPS
--		SELECT * FROM BillAppliedSchemeHd
--		SELECT * FROM @TempSchGross
--		SELECT * FROM @TempPrdGross
		IF EXISTS(SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		BEGIN
			SELECT DISTINCT TP.SchId,BA.SlabId,TP.PrdId,TP.PrdBatId,TP.RowId,TP.GrossAmount 
			INTO TPQ FROM BillAppliedSchemeHd BA
			INNER JOIN SchemeMaster SM ON BA.SchId=SM.SchId AND Sm.QPS=1 AND SM.QPSReset=1
			INNER JOIN @TempPrdGross TP ON TP.SchId=BA.SchId
			SELECT DISTINCT TG.SchId,BA.SlabId,TG.GrossAmount 
			INTO TGQ FROM BillAppliedSchemeHd BA
			INNER JOIN SchemeMaster SM ON BA.SchId=SM.SchId AND Sm.QPS=1 AND SM.QPSReset=1
			INNER JOIN @TempSchGross TG ON TG.SchId=BA.SchId
			
			SELECT A.SchId,A.MaxSlabId,SS.PurQty
			INTO SchMaxSlab FROM
			(SELECT SM.SchId,MAX(SS.SlabId) AS MaxSlabId
			FROM SchemeMaster SM,SchemeSlabs SS
			WHERE SM.SchId=SS.SchId AND SM.QPSReset=1 
			GROUP BY SM.SchId) A,
			SchemeSlabs SS
			WHERE A.SchId=SS.SchId AND A.MaxSlabId=SS.SlabId 
	--		SELECT * FROM TG
	--		SELECT * FROM TP
	--
	--		SELECT * FROM TGQ
	--		--SELECT * FROM SchMaxSlab 
	--		SELECT * FROM TPQ
	--		SELECT * FROM BillAppliedSchemeHd
			DECLARE @MSSchId AS INT
			DECLARE @MaxSlabId AS INT
			DECLARE @MSPurQty AS NUMERIC(38,6)
			DECLARE Cur_QPSSlabs CURSOR FOR 
			SELECT SchId,MaxSlabId,PurQty
			FROM SchMaxSlab
			OPEN Cur_QPSSlabs
			FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId,@MSPurQty
			WHILE @@FETCH_STATUS=0
			BEGIN		
				UPDATE TGQ SET GrossAmount=@MSPurQty 
				WHERE SchId=@MSSchId AND SlabId=@MaxSlabId
				UPDATE TGQ SET GrossAmount=GrossAmount-@MSPurQty 
				WHERE SchId=@MSSchId AND SlabId<@MaxSlabId
				FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId,@MSPurQty
			END
			CLOSE Cur_QPSSlabs
			DEALLOCATE Cur_QPSSlabs
			UPDATE T SET T.GrossAmount=(T.GrossAmount/TG.GrossAmount)*TGQ.GrossAmount
			FROM TPQ T,TG,TGQ
			WHERE T.SchId=TG.SchId AND TG.SchId=TGQ.SchId AND TGQ.SlabId=T.SlabId 	
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
			SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount
			,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
			@Pi_TransId AS TransId,@Pi_UsrId AS UsrId,SchemeDiscount,A.SchType
			FROM BillAppliedSchemeHd A INNER JOIN TGQ B ON
			A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
			INNER JOIN TPQ C ON A.Schid = C.SchId and B.SchId = C.SchId AND A.SlabId=B.SlabId AND B.SlabId=C.SlabId
			--AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
			WHERE A.UsrId = @Pi_UsrId AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)	
			AND SM.SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
			AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
			GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		END

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT DISTINCT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId		
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid and SM.QPS=1 	  		
		INNER JOIN SchemeAnotherPrdDt SOP ON SM.SchId=SOP.SchId AND A.SchId=SOP.SchId AND A.SlabId=SOP.SlabId
		AND A.PrdId=SOP.PrdId AND SOP.Prdid=C.PrdId 
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1 
		AND SM.SchId IN (SELECT SchId FROM SchemeAnotherPrdHd)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)

--		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
--		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
--		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
--		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
--		Case WHEN QPS=1 THEN
--		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
--		ELSE  SchemeAmount END  As SchemeAmount
--		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
--		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
--		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
--		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
--		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
--		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
--		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
--		AND SM.CombiSch=0
--		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
--		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
--		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
--		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
--		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
		ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
		AND SM.CombiSch=0
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)


		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
		AND SM.CombiSch=1
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		---->
	END
	INSERT INTO @FreeQtyDt (FreePrdid,FreePrdBatId,FreeQty)
	--SELECT FreePrdId,FreePrdBatId,Sum(FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
	SELECT FreePrdId,FreePrdBatId,Sum(DISTINCT FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY FreePrdId,FreePrdBatId
	INSERT INTO @FreeQtyRow (RowId,PrdId,PrdBatId)
	SELECT MIN(A.RowId) as RowId,A.Prdid,A.PrdBatId FROM BilledPrdHdForScheme A
	INNER JOIN BillAppliedSchemeHd B ON A.PrdId = B.PrdId AND
	A.PrdBatid = B.PrdBatId
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND
	B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY A.Prdid,A.PrdBatId
	UPDATE ApportionSchemeDetails SET FreeQty = A.FreeQty FROM
	@FreeQtyDt A INNER JOIN @FreeQtyRow B ON
	A.FreePrdId  = B.PrdId
	WHERE ApportionSchemeDetails.RowId = B.RowId
	AND ApportionSchemeDetails.UsrId = @Pi_UsrId AND ApportionSchemeDetails.TransId = @Pi_TransId

	--->Added By Nanda on 20/09/2010
	SELECT * INTO #TempApp FROM ApportionSchemeDetails	
	DELETE FROM ApportionSchemeDetails
	INSERT INTO ApportionSchemeDetails
	SELECT DISTINCT * FROM #TempApp
	--->Till Here
	UPDATE ApportionSchemeDetails SET SchemeAmount=SchemeAmount+SchAmt,SchemeDiscount=SchemeDiscount+SchDisc
	FROM 
	(SELECT SchId,SUM(SchemeAmount) SchAmt,SUM(SchemeDiscount) SchDisc FROM ApportionSchemeDetails
	WHERE RowId=10000 GROUP BY SchId) A,
	(SELECT SchId,MIN(RowId) RowId FROM ApportionSchemeDetails
	GROUP BY SchId) B
	WHERE ApportionSchemeDetails.SchId =  A.SchId AND A.SchId=B.SchId 
	AND ApportionSchemeDetails.RowId=B.RowId  
	DELETE FROM ApportionSchemeDetails WHERE RowId=10000
	INSERT INTO @RtrQPSIds
	SELECT DISTINCT RtrId,SchId FROM BilledPrdHdForQPSScheme WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	
	INSERT INTO @QPSGivenDisc
	SELECT A.SchId,SUM(A.DiscountPerAmount) FROM 
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount
	FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails WHERE SchemeAmount=0) A,SchemeMaster SM ,SalesInvoice SI,
	@RtrQPSIds RQPS
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
	AND SISl.SlabId<=A.SlabId) A
	GROUP BY A.SchId
	INSERT INTO @QPSNowAvailable
	SELECT A.SchId,SUM(SchemeDiscount)-B.Amount FROM ApportionSchemeDetails A,@QPSGivenDisc B
	WHERE A.SchId=B.SchId
	GROUP BY A.SchId,B.Amount
	SELECT * FROM @QPSNowAvailable
	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if not exists (select * from hotfixlog where fixid = 343)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(343,'D','2010-10-23',getdate(),1,'Core Stocky Service Pack 343')