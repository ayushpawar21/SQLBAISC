--[Stocky HotFix Version]=349
Delete from Versioncontrol where Hotfixid='349'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('349','2.0.0.5','D','2010-11-21','2010-11-21','2010-11-21',convert(varchar(11),getdate()),'Parle 2nd Phase;Major:-;Minor:Changes and Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 349' ,'349'
GO

--SRF-Nanda-171-001

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClaimSettlementDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClaimSettlementDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_ClaimSettlementDetails
EXEC Proc_Cn2Cs_ClaimSettlementDetails 0
SELECT * FROM ClaimSheetDetail
SELECT * FROM ClaimSheetHd
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_ClaimSettlementDetails]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClaimSettlementDetails
* PURPOSE		: To Download the Claim Settlement details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 10/11/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @Taction  			INT
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @DebitNoteNumber	NVARCHAR(500)
	DECLARE @CrDbNoteDate		DATETIME
	DECLARE @CrDbNoteReason		NVARCHAR(500)
	DECLARE @CreditNoteNumber	NVARCHAR(500)
	DECLARE @SpmId				INT
	DECLARE @DebitNo			NVARCHAR(500)
	DECLARE @CreditNo			NVARCHAR(500)
	DECLARE @ClaimNumber		NVARCHAR(500)
	DECLARE @ClmId				INT
	DECLARE @AccCoaId			INT
	DECLARE @ClmGroupId			INT
	DECLARE @ClmGroupNumber		NVARCHAR(500)
	DECLARE @CrDbNoteAmount		NUMERIC(38,6)
	DECLARE @CmpId				INT
	DECLARE @VocNo				NVARCHAR(500)

	DECLARE @ClaimSheetNo		NVARCHAR(500)

	SET @Po_ErrNo=0

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClaimSettleToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClaimSettleToAvoid	
	END
	CREATE TABLE ClaimSettleToAvoid
	(
		ClaimSheetNo NVARCHAR(50),
		ClaimRefNo	 NVARCHAR(50),
		CreditNoteNo NVARCHAR(50)
	)
	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
	WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')='')
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','ClaimRefNo','Claim Ref No should not be empty for :'+CreditNoteNo
		FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(ClaimRefNo,'')='' OR ISNULL(ClaimSheetNo,'')=''
	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
	WHERE CreditDebitNoteAmt>0)
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE CreditDebitNoteAmt>0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Amount','Amount should not be greater than zero for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE CreditDebitNoteAmt>0
	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
	WHERE ISNULL(CreditNoteNo,'')='' OR ISNULL(DebitNoteNo,'')='')
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditNoteNo,'')='' OR ISNULL(DebitNoteNo,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Credit/Debite Note No','Credit/Debite Note No should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditNoteNo,'')='' OR ISNULL(DebitNoteNo,'')=''
	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
	WHERE ISNULL(CreditDebitNoteReason,'')='')
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditDebitNoteReason,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Reason','Reason should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditDebitNoteReason,'')=''
	END

	IF EXISTS(SELECT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails
	WHERE ISNULL(CreditDebitNoteDate,'')='')
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditDebitNoteDate,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Date','Date should not be empty for :'+ClaimRefNo
		FROM Cn2Cs_Prk_ClaimSettlementDetails
		WHERE ISNULL(CreditDebitNoteDate,'')=''
	END

	IF EXISTS(SELECT DISTINCT ClaimRefNo FROM Cn2Cs_Prk_ClaimSettlementDetails WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
	(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId))
	BEGIN
		INSERT INTO ClaimSettleToAvoid(ClaimSheetNo,ClaimRefNo,CreditNoteNo)
		SELECT ClaimSheetNo,ClaimRefNo,CreditNoteNo FROM Cn2Cs_Prk_ClaimSettlementDetails WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
		(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Claim Settlement','Date','Claim Reference Number :'+ClaimRefNo+'does not exists'
		FROM Cn2Cs_Prk_ClaimSettlementDetails WHERE ClaimSheetNo+'~'+ClaimRefNo NOT IN
		(SELECT A.ClmCode+'~'+B.RefCode FROM ClaimSheetDetail B,ClaimSheetHd A WHERE A.ClmId=B.ClmId)
	END

	DECLARE Cur_ClaimSettlement CURSOR	
	FOR SELECT  ISNULL([ClaimSheetNo],''),ISNULL([ClaimRefNo],''),ISNULL([CreditNoteNo],'0'),ISNULL([DebitNoteNo],'0'),
	CONVERT(NVARCHAR(10),[CreditDebitNoteDate],121),
	CAST(ISNULL([CreditDebitNoteAmt],0)AS NUMERIC(38,6)),
	ISNULL([CreditDebitNoteReason],'')
	FROM Cn2Cs_Prk_ClaimSettlementDetails WHERE DownloadFlag='D' AND ClaimRefNo+'~'+CreditNoteNo NOT IN
	(SELECT ClaimRefNo+'~'+CreditNoteNo FROM ClaimSettleToAvoid)	
	OPEN Cur_ClaimSettlement
	FETCH NEXT FROM Cur_ClaimSettlement INTO @ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@DebitNoteNumber,
	@CrDbNoteDate,@CrDbNoteAmount,@CrDbNoteReason
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0
		SET @ErrStatus=1

		SELECT @ClmId=B.ClmId FROM ClaimSheetDetail B INNER JOIN ClaimSheetHd A ON A.ClmId=B.ClmId
		WHERE B.RefCode=@ClaimNumber AND A.ClmCode=@ClaimSheetNo

		SELECT @ClmGroupId=ClmGrpId,@ClmGroupNumber=ClmCode,@CmpId=CmpId FROM ClaimSheetHd WHERE ClmId=@ClmId

		SELECT @AccCoaId=CoaId FROM ClaimGroupMaster WHERE ClmGrpId=@ClmGroupId
		SELECT @SpmId=SpmId FROM Supplier WHERE SpmDefault=1 AND CmpId=@CmpId

		IF @SpmId=0
		BEGIN
			SET @ErrDesc = 'Default Supplier does not exists'
			INSERT INTO Errorlog VALUES (8,'Claim Settlement','Supplier',@ErrDesc)
			SET @Po_ErrNo=1	
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF @DebitNoteNumber = '0' AND @CreditNoteNumber<> '0'
			BEGIN
				SELECT @CreditNo=dbo.Fn_GetPrimaryKeyString('CreditNoteSupplier','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
				
				INSERT INTO CreditNoteSupplier(CrNoteNumber,CrNoteDate,SpmId,CoaId,ReasonId,Amount,CrAdjAmount,Status,
				PostedFrom,TransId,PostedRefNo,CrNoteReason,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
				VALUES(@CreditNo,@CrDbNoteDate,@SpmId,@AccCoaId,9,@CrDbNoteAmount,0,1,@ClmGroupNumber,16,
				'Cmp-'+@CreditNoteNumber,@CrDbNoteReason,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'')

				UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'CreditNoteSupplier' AND Fldname = 'CrNoteNumber'

				EXEC Proc_VoucherPosting 32,1,@CreditNo,3,6,1,@CrDbNoteDate,@Po_ErrNo= @ErrStatus OUTPUT
				
				IF @ErrStatus<>1
				BEGIN
					SET @Po_ErrNo=1
					SET @ErrDesc = 'Credit Note Voucher Posting Failed for Claim Ref No:' + @ClaimNumber
					INSERT INTO Errorlog
					VALUES (9,'Claim Settlement','Credit Note Voucher Posting',@ErrDesc)
				END
				IF @Po_ErrNo=0
				BEGIN
					SELECT @VocNo=MAX(VocRefNo) FROM StdVocMaster (NOLOCK) WHERE VocType=3 AND VocSubType=6
					AND LastModDate= CONVERT(NVARCHAR(10),GETDATE(),121)

					IF DATEDIFF(D,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),CONVERT(NVARCHAR(10),GETDATE(),121))>0
					BEGIN
						EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
					END

					UPDATE ClaimSheetDetail SET ReceivedAmount=@CrDbNoteAmount,CrDbmode=2,CrDbStatus=1,CrDbNotenumber=@CreditNo,Status=1
					WHERE ClmId=@ClmId AND RefCode=@ClaimNumber

					UPDATE Cn2Cs_Prk_ClaimSettlementDetails SET DownLoadFlag='Y' WHERE [ClaimRefNo]=@ClaimNumber
				END
			END					
			ELSE IF @DebitNoteNumber <> '0' AND @CreditNoteNumber= '0'
			BEGIN
				SELECT @DebitNo=dbo.Fn_GetPrimaryKeyString('DebitNoteSupplier','DbNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))

				INSERT INTO DebitNoteSupplier(DbNoteNumber,DbNoteDate,SpmId,CoaId,ReasonId,Amount,DbAdjAmount,Status,
				PostedFrom,TransId,PostedRefNo,DbNoteReason,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
				VALUES(@DebitNo,@CrDbNoteDate,@SpmId,@AccCoaId,9,@CrDbNoteAmount,0,1,@ClmGroupNumber,33,
				'Cmp-'+@DebitNoteNumber,@CrDbNoteReason,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'')

				UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'DebitNoteSupplier' AND Fldname = 'DbNoteNumber'
			
				EXEC Proc_VoucherPosting 33,1,@DebitNo,3,7,1,@CrDbNoteDate,@Po_ErrNo= @ErrStatus OUTPUT
				
				IF @ErrStatus<>1
				BEGIN
					SET @Po_ErrNo=1
					SET @ErrDesc = 'Debit Note Voucher Posting Failed'
					INSERT INTO Errorlog VALUES (10,'Claim Settlement','Debit Note Voucher Posting',@ErrDesc)
				END
		
				IF @Po_ErrNo=0
				BEGIN
					SELECT @VocNo=MAX(VocRefNo) FROM StdVocMaster (NOLOCK) WHERE VocType=3 AND VocSubType=7
					AND LastModDate= CONVERT(NVARCHAR(10),GETDATE(),121)

					IF DATEDIFF(D,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),CONVERT(NVARCHAR(10),GETDATE(),121))>0
					BEGIN
						EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
					END

					UPDATE ClaimSheetDetail SET ReceivedAmount=@CrDbNoteAmount,RecommendedAmount=@CrDbNoteAmount,
					CrDbmode=1,CrDbStatus=1,CrDbNotenumber=@DebitNo,Status=1
					WHERE ClmId=@ClmId AND RefCode=@ClaimNumber

					UPDATE Cn2Cs_Prk_ClaimSettlementDetails SET DownLoadFlag='Y' WHERE [ClaimRefNo]=@ClaimNumber
				END
			END	
		END
		FETCH NEXT FROM Cur_ClaimSettlement INTO @ClaimSheetNo,@ClaimNumber,@CreditNoteNumber,@DebitNoteNumber,@CrDbNoteDate,@CrDbNoteAmount,@CrDbNoteReason
	END
	CLOSE Cur_ClaimSettlement
	DEALLOCATE Cur_ClaimSettlement

	SET @Po_ErrNo=0
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-171-002

DELETE FROM RptExcelHeaders WHERE RptId=53  

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('53','1','RtrBankId','RtrBankId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('53','2','RtrBnkName','Drawee Bank','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('53','3','RtrBnkBrID','RtrBnkBrID','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('53','4','RtrBnkBrName','Drawee Branch','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('53','5','DisBnkId','DisBnkId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('53','6','DisBranchId','DisBranchId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('53','7','DistributorBnkName','Drawee Bank','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('53','8','DistributorBnkBrName','Drawee Branch','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('53','9','InvInsNo','Cheque No','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('53','10','InvInsDate','Cheque Date','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('53','11','InvInsAmt','Cheque Amount','1','1')

--SRF-Nanda-171-003

--810
UPDATE HotSearchEditorHd SET RemainsltString='
SELECT PrdBatID,PrdBatCode,MRP,PurchaseRate,SellRate,PriceId,ShelfDay,ExpiryDay FROM  
(   
	SELECT A.PrdBatID,A.PrdBatCode,F.PrdBatDetailValue AS SellRate,B.PrdBatDetailValue AS MRP,
	D.PrdBatDetailValue AS PurchaseRate,B.PriceId,DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),DATEADD(Day,Prd.PrdShelfLife,A.MnfDate)) as ShelfDay,
    DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),A.ExpDate) as ExpiryDay  
	FROM  ProductBatch A (NOLOCK)   
	INNER JOIN Product Prd  (NOLOCK) ON A.PrdId = Prd.PrdId
	INNER JOIN ProductBatchDetails B  (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1   
	INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId   AND B.SlNo = C.SlNo AND C.MRP = 1   
	INNER JOIN ProductBatchDetails D  (NOLOCK)  ON A.PrdBatId = D.PrdBatID   AND D.DefaultPrice=1   
	INNER JOIN BatchCreation E (NOLOCK)    ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1   
	INNER JOIN ProductBatchDetails F (NOLOCK)  ON A.PrdBatId = F.PrdBatID AND F.DefaultPrice=1   
	INNER JOIN BatchCreation G (NOLOCK)  ON G.BatchSeqId = A.BatchSeqId   AND F.SlNo = G.SlNo  AND G.SelRte = 1   
	INNER JOIN ProductBatchLocation PBL (NOLOCK) ON A.PrdId=PBL.PrdId AND A.PrdBatId=PBL.PrdBatId AND (PBL.PrdBatLcnSih-PBL.PrdbatLcnResSih)>0   
	WHERE  A.PrdId=vFParam  AND A.Status = 1  
)   MainQry order by PrdBatId ASC'
WHERE FormId=810 


--332
UPDATE HotSearchEditorHd SET RemainsltString='
SELECT PrdBatID,PrdBatCode,MRP,PurchaseRate,SellRate,PriceId,ShelfDay,ExpiryDay FROM  
(   
	SELECT A.PrdBatID,A.PrdBatCode,F.PrdBatDetailValue AS SellRate,B.PrdBatDetailValue AS MRP,
	D.PrdBatDetailValue AS PurchaseRate,B.PriceId,DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),DATEADD(Day,Prd.PrdShelfLife,A.MnfDate)) as ShelfDay,
    DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),A.ExpDate) as ExpiryDay   
	FROM  ProductBatch A (NOLOCK)   
	INNER JOIN Product Prd  (NOLOCK) ON A.PrdId = Prd.PrdId
	INNER JOIN ProductBatchDetails B  (NOLOCK)  ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1   
	INNER JOIN BatchCreation C (NOLOCK)    ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1   
	INNER JOIN ProductBatchDetails D   (NOLOCK)  ON A.PrdBatId = D.PrdBatID   AND D.DefaultPrice=1   
	INNER JOIN BatchCreation E (NOLOCK)  ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1   
	INNER JOIN ProductBatchDetails F (NOLOCK)  ON A.PrdBatId = F.PrdBatID AND F.DefaultPrice=1   
	INNER JOIN BatchCreation G (NOLOCK)  ON   G.BatchSeqId = A.BatchSeqId AND F.SlNo = G.SlNo AND G.SelRte = 1   
	INNER JOIN ProductBatchLocation PBL (NOLOCK) ON A.PrdId=PBL.PrdId AND A.PrdBatId=PBL.PrdBatId AND (PBL.PrdBatLcnSih-PBL.PrdbatLcnResSih)>0   
	WHERE  A.PrdId=vFParam  AND A.Status = 1   AND  B.PrdBatDetailValue=vSParam  
) MainQry order by PrdBatId ASC'
WHERE FormId=332 


--SRF-Nanda-171-004

UPDATE RptDetails SET FldCaption='No of Outlets*' WHERE RptId=56 AND SlNo=3

UPDATE RptDetails SET FldCaption='B.M Product*...' WHERE RptId=6 AND SlNo=13

UPDATE RptFilter SET FilterDesc='Quarter' WHERE FilterDesc='Quater'

UPDATE RptDetails SET PnlMsg='Press F4/Double Click to select Period' WHERE RptId=63 AND SlNo=2

UPDATE RptDetails SET SlNo=1 
WHERE RptId=209 AND TblName='Company'

UPDATE RptDetails SET SlNo=2 
WHERE RptId=209 AND TblName='JCMast'

UPDATE RptDetails SET SlNo=3 
WHERE RptId=209 AND TblName='JCMonth' AND FldCaption='From JC Month*...'

UPDATE RptDetails SET SlNo=4
WHERE RptId=209 AND TblName='JCMonth' AND FldCaption='To JC Month*...'

UPDATE RptHeader SET RpCaption='Retailer Wise Sales Value Report',RptCaption='Retailer Wise Sales Value Report'
WHERE RptId=209

UPDATE RptGroup SET GrpName='Retailer Wise Sales Value Report'
WHERE RptId=209

DELETE FROM RptHeader WHERE RptId=208
DELETE FROM RptGroup WHERE RptId=208

DELETE FROM RptExcelHeaders WHERE RptId=58

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('58','1','SMId','SMId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('58','2','SMName','Salesman','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('58','3','RMId','RMId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('58','4','RMName','Route','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('58','5','RtrId','RtrId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('58','6','RtrCode','Retailer Code','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('58','7','RtrName','Retailer Name','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('58','8','SalQty','Units','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('58','9','Width','Distribution Width','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('58','10','BasedOn','BasedOn','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('58','11','RtrCount','RtrCount','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('58','12','BilledRtrCount','BilledRtrCount','0','1')

--SRF-Nanda-171-005

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnBudgetUtilized]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnBudgetUtilized]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT dbo.Fn_ReturnBudgetUtilized(507) AS Amt

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
	DECLARE @QPSSchAmt		NUMERIC(38,6)

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
	AND SchId IN(SELECT SchId FROM SchemeMaster WHERE FBM=1)

	--->Added By Nanda on 27/10/2010
	SELECT @QPSSchAmt=ISNULL(SUM(CrNoteAmount),0) FROM SalesInvoiceQPSSchemeAdj SIQ 
	INNER JOIN SalesInvoice SI ON SI.SalId=SIQ.SalId AND SI.DlvSts>3 AND SIQ.SchId=@Pi_SchId
	WHERE SIQ.SchId IN(SELECT SchId FROM SchemeMaster WHERE FBM=0)

	SET @BudgetUtilized = (@SchemeAmt + @FreeValue + @GiftValue + @Points + @WindowAmt+ @FBMSchAmt+@QPSSchAmt)
	-- 	- (@RetSchemeAmt + @RetFreeValue + @RetGiftValue + @RetPoints)

	SET @BudgetUtilized=ISNULL(@BudgetUtilized,0)

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
	DECLARE @QPSSchAmt		NUMERIC(38,6)

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
	AND SchId IN(SELECT SchId FROM SchemeMaster WHERE FBM=1)

	--->Added By Nanda on 27/10/2010
	SELECT @QPSSchAmt=ISNULL(SUM(CrNoteAmount),0) FROM SalesInvoiceQPSSchemeAdj SIQ 
	INNER JOIN SalesInvoice SI ON SI.SalId=SIQ.SalId AND SI.DlvSts>3 AND SIQ.SchId=@Pi_SchId
	WHERE SIQ.SchId IN(SELECT SchId FROM SchemeMaster WHERE FBM=0)

	SET @BudgetUtilized = (@SchemeAmt + @FreeValue + @GiftValue + @Points + @WindowAmt + @FBMSchAmt+@QPSSchAmt)

	SET @BudgetUtilized=ISNULL(@BudgetUtilized,0)

	RETURN(@BudgetUtilized)
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
	DECLARE @QPSSchAmt		NUMERIC(38,6)

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
	AND SchId IN(SELECT SchId FROM SchemeMaster WHERE FBM=1)

	--->Added By Nanda on 27/10/2010
	SELECT @QPSSchAmt=ISNULL(SUM(CrNoteAmount),0) FROM SalesInvoiceQPSSchemeAdj SIQ 
	INNER JOIN SalesInvoice SI ON SI.SalId=SIQ.SalId AND SI.DlvSts>3 AND SIQ.SchId=@Pi_SchId
	WHERE SIQ.SchId IN(SELECT SchId FROM SchemeMaster WHERE FBM=0)

	SET @BudgetUtilized = (@SchemeAmt + @FreeValue + @GiftValue + @Points + @WindowAmt)
		- (@RetSchemeAmt + @RetFreeValue + @RetGiftValue + @RetPoints)+ @FBMSchAmt+@QPSSchAmt

	SET @BudgetUtilized=ISNULL(@BudgetUtilized,0)

	RETURN(@BudgetUtilized)
END 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-171-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_ClaimAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_ClaimAll]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_ClaimAll 0
SELECT * FROM Cs2Cn_Prk_ClaimAll
ROLLBACK TRANSACTION	
*/

CREATE  PROCEDURE [dbo].[Proc_Cs2Cn_ClaimAll]
(
	@Po_ErrNo  INT OUTPUT
)
AS
BEGIN
SET NOCOUNT ON
/*********************************
* PROCEDURE	: Proc_Cs2Cn_ClaimAll
* PURPOSE	: Extract Claim sheet details from CoreStocky to Console-->Nivea
* NOTES		:
* CREATED	: Nandakumar R.G
* DATE		: 13/11/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag='Y'

	SET @Po_ErrNo  =0
	EXEC Proc_Cs2Cn_Claim_RateDiffernece
	EXEC Proc_Cs2Cn_Claim_Scheme
	EXEC Proc_Cs2Cn_Claim_Manual
	EXEC Proc_Cs2Cn_Claim_BatchTransfer
	EXEC Proc_Cs2Cn_Claim_DeliveryBoy
	EXEC Proc_Cs2Cn_Claim_PurchaseExcess
	EXEC Proc_Cs2Cn_Claim_PurchaseShortage
	EXEC Proc_Cs2Cn_Claim_ResellDamage
	EXEC Proc_Cs2Cn_Claim_ReturnToCompany
	EXEC Proc_Cs2Cn_Claim_Salesman
	EXEC Proc_Cs2Cn_Claim_SalesmanIncentive
	EXEC Proc_Cs2Cn_Claim_Salvage
	EXEC Proc_Cs2Cn_Claim_SpecialDiscount
	EXEC Proc_Cs2Cn_Claim_Transporter
	EXEC Proc_Cs2Cn_Claim_VanSubsidy
	EXEC Proc_Cs2Cn_Claim_Vat	
	EXEC Proc_Cs2Cn_Claim_StockJournal
	EXEC Proc_Cs2Cn_Claim_RateChange
	EXEC Proc_Cs2Cn_Claim_ModernTrade

	UPDATE CH SET Upload='Y' FROM ClaimSheetHd CH,ClaimSheetDetail CD
	WHERE CH.ClmId=CD.ClmId AND CD.RefCode IN (SELECT DISTINCT ClaimRefNo FROM Cs2Cn_Prk_ClaimAll) 
	AND CH.Confirm=1 AND Status=1 

	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	Where ProcId = 12

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-171-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GetProductwiseHierarchy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_GetProductwiseHierarchy]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE Procedure [dbo].[Proc_GetProductwiseHierarchy]
/************************************************************
* PROC	: Proc_GetProductwiseHierarchy
* PURPOSE	: To get the Product wise hierarchy details 
* CREATED BY	: R.Ramasundaram
* CREATED DATE	: 18/10/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
BEGIN

	DECLARE @CmpPrdCtgId 	INT
	DECLARE @CmpPrdCtgName	VARCHAR(100)
	DECLARE @LevelName	VARCHAR(100)
	DECLARE @CmpId		INT

	DECLARE @SSQL		VARCHAR(4000)
	DECLARE @SSQLC		VARCHAR(8000)
	DECLARE @sSelect	VARCHAR(8000)
	DECLARE @sFrom		VARCHAR(8000)	
	DECLARE @sWhere		VARCHAR(8000)
	DECLARE @SSQLS		VARCHAR(8000)
	DECLARE @SSQLW		VARCHAR(8000)
	DECLARE @iCnt 		INT
	DECLARE @iRowCnt 	INT
	SET @SSQL = ''
	SET @sSelect = ''
	SET @sFrom = ''
	SET @sWhere = ''
	SET @iCnt = 1

	DECLARE CSANZ_CUR CURSOR  FOR 
	SELECT CmpPrdCtgId,CmpPrdCtgName,LevelName,CmpId FROM  ProductCategoryLevel  WHERE CmpId IN (SELECT CmpId FROM Company WHERE DefaultCompany = 1)
    OPEN CSANZ_CUR
	FETCH NEXT FROM CSANZ_CUR INTO  @CmpPrdCtgId,@CmpPrdCtgName,@LevelName,@CmpId
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @iRowCnt = (SELECT Count(*) FROM ProductCategoryLevel WHERE CmpId IN (SELECT CmpId FROM Company WHERE DefaultCompany = 1))			

		IF @iCnt <= (@iRowCnt - 1) 
			SET @SSQL = @SSQL + ',[' + @CmpPrdCtgName + '] VARCHAR(100) '		

		IF (@iRowCnt - @iCnt) > 0
			SET @sSelect = @sSelect + ',PCV' + Cast( (@iRowCnt - @iCnt) AS VARCHAR(5)) + '.PrdCtgValName'  

		IF @iCnt <= (@iRowCnt - 1)	
		BEGIN	
			SET @sFrom  =  @sFrom + ',ProductCategoryValue PCV' + Cast(@iCnt AS VARCHAR(5))  
		END

		IF @iCnt <= (@iRowCnt - 2)	
		BEGIN	
			SET @sWhere =  @sWhere + ' AND PCV' + Cast(@iCnt AS VARCHAR(5)) + '.PrdCtgValLinkId = PCV' + Cast(@iCnt + 1 AS VARCHAR(5)) + '.PrdCtgValMainId'
		END	

		SET @iCnt = @iCnt + 1
		FETCH NEXT FROM CSANZ_CUR INTO  @CmpPrdCtgId,@CmpPrdCtgName,@LevelName,@CmpId
	END
	CLOSE CSANZ_CUR
	DEALLOCATE CSANZ_CUR
	
	if exists (select * from dbo.sysobjects where id = object_id(N'[ProductWiseHierarchy]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [ProductWiseHierarchy]
	
	SET @SSQLC = 'CREATE TABLE ProductWiseHierarchy (ProductId INT,ProductCCode VARCHAR(100),ProductName VARCHAR(200)'
	SET @SSQLC = @SSQLC + @SSQL + ')'
	
	EXEC( @SSQLC ) 
	SET @SSQLC = ''
	SET @SSQLS = ''
	SET @SSQLW = ''
	SET @SSQLC = @SSQLC + ' SELECT PrdId,PrdName,PrdCCode' + @sSelect
	SET @SSQLS = @SSQLS + ' FROM Product P' + @sFrom
	SET @SSQLW = @SSQLW + ' WHERE P.PrdCtgValMainId  = PCV1.PrdCtgValMainId' + @sWhere
	INSERT INTO ProductWiseHierarchy
	EXEC( @SSQLC + @SSQLS + @SSQLW )	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-171-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBankSlipReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBankSlipReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---EXEC Proc_RptBankSlipReport 53,1,0,'CoreStocky18072008',0,0,1
CREATE      PROC [dbo].[Proc_RptBankSlipReport]
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/************************************************************
* VIEW	: Proc_RptBankSlipReport
* PURPOSE	: To get the Cheque Collection For Particular Date Period
* CREATED BY	: Mahalakshmi.A
* CREATED DATE	: 6/12/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
BEGIN
	SET NOCOUNT ON
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @sSql		AS 	nVarChar(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	---Filter Variables
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @BnkId 		AS	INT
	DECLARE @BnkBrId	AS	INT
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @BnkId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,70,@Pi_UsrId))
	SET @BnkBrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,71,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	CREATE TABLE #RptBankSlipReport
	(
				RtrBankId	BIGINT,
				RtrBnkName	NVARCHAR(50),
				RtrBnkBrID	BIGINT,
				RtrBnkBrName  NVARCHAR(50),
				DisBnkId INT,
				DisBranchId INT,
				DistributorBnkName NVARCHAR(50),
				DistributorBnkBrName NVARCHAR(50),
				InvInsNo NVARCHAR(25),
				InvInsDate DATETIME,
				InvInsAmt NUMERIC(38,6)
		
	)
	SET @TblName = 'RptBankSlipReport'
	SET @TblStruct =' RtrBankId	BIGINT,
				RtrBnkName	NVARCHAR(50),
				RtrBnkBrID	BIGINT,
				RtrBnkBrName  NVARCHAR(50),
				DisBnkId INT,
				DisBranchId INT,
				DistributorBnkName NVARCHAR(50),
				DistributorBnkBrName NVARCHAR(50),
				InvInsNo NVARCHAR(25),
				InvInsDate DATETIME,
				InvInsAmt NUMERIC(38,6)'
	SET @TblFields = 'RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvInsAmt'
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
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		
			INSERT INTO #RptBankSlipReport (RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvInsAmt)
				SELECT RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,
				CAST(InvInsNo AS NVARCHAR(25)),InvInsDate,SalInvAmt
				FROM View_BankSlip			
				WHERE 	(DisBnkId = (CASE @BnkId WHEN 0 THEN DisBnkId ELSE 0 END) OR
						DisBnkId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,70,@Pi_UsrId)))
					AND
					(DisBranchId = (CASE @BnkBrId WHEN 0 THEN DisBranchId ELSE 0 END) OR
						DisBranchId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,71,@Pi_UsrId)))
					AND InvInsDate BETWEEN @FromDate AND @ToDate
				
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptBankSlipReport' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 
				+ 'WHERE (DisBnkId = (CASE ' + CAST(@BnkId AS nVarchar(10)) + ' WHEN 0 THEN DisBnkId ELSE 0 END) OR '
				+ 'DisBnkId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',70,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (DisBranchId = (CASE ' + CAST(@BnkBrId AS nVarchar(10)) + ' WHEN 0 THEN DisBranchId ELSE 0 END) OR '
				+ 'DisBranchId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',71,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND InvInsDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
			EXEC (@SSQL)
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptBankSlipReport'
		
				EXEC (@SSQL)
				PRINT 'Saved Data Into SnapShot Table'
			   END
		   END
	END
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		   BEGIN
			SET @SSQL = 'INSERT INTO #RptBankSlipReport ' +
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
			PRINT 'DataBase or Table not Found'
		   END
	END
	--Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptBankSlipReport
	-- Till Here

	--->Added By Nanda on 16/11/2010
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptBankSlip_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptBankSlip_Excel
		SELECT * INTO RptBankSlip_Excel FROM #RptBankSlipReport
	END 
	--->Till Here

	SELECT * FROM #RptBankSlipReport
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-171-009

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptStoreSchemeDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptStoreSchemeDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
SELECT  * FROM RPTStoreSchemeDetails ORDER By SchId,ReferNo
EXEC Proc_RptStoreSchemeDetails 15,2
*/

CREATE     PROCEDURE [dbo].[Proc_RptStoreSchemeDetails]
(	
	@Pi_RptId		INT,
	@Pi_UsrId		INT
)
AS
/*********************************
* PROCEDURE: Proc_RptStoreSchemeDetails
* PURPOSE: General Procedure To Get the Scheme Details into Scheme Temp Table
* NOTES:
* CREATED: Thrinath Kola	30-07-2007
* MODIFIED
* DATE			AUTHOR     DESCRIPTION
------------------------------------------------
* 15/11/2010	Nanda	   Free and Gift Value changes for Sales Return	
*********************************/
SET NOCOUNT ON
BEGIN
	--Filter Variable
	DECLARE @FromDate	AS 	DateTime
	DECLARE @ToDate		AS	DateTime
	DECLARE @fSchId		AS	Int
	DECLARE @fSMId		AS	Int
	DECLARE @fRMId		AS	Int
	DECLARE @CtgLevelId AS    INT
	DECLARE @CtgMainId  AS    INT
	DECLARE @RtrClassId AS    INT
	DECLARE @fRtrId		AS	Int
	--Till Here

	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @fSchId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))
	SET @fSMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @fRMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @CtgLevelId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @CtgMainId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @RtrClassId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @fRtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	--Till Here

	--select * from RPTStoreSchemeDetails
	DELETE FROM RPTStoreSchemeDetails WHERE UserId = @Pi_UsrId

	--Values For Scheme Amount From SalesInvoice
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,B.PrdId,B.PrdBatId,ISNULL(SUM(B.FlatAmount),0) As FlatAmount,
		ISNULL(SUM(B.DisCountPerAmount),0) as DiscountPer,
		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,
		ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		I.PrdName,J.PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		1 as LineType,SalInvDate
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeLineWise B ON A.SalId = B.SalId
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId INNER JOIN ROUTEMASTER E ON A.DlvRMId = E.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId LEFT OUTER JOIN Vehicle G ON A.VehicleId = G.VehicleId
		LEFT OUTER JOIN DeliveryBoy H ON A.DlvBoyId = H.DlvBoyId INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	GROUP BY B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,A.VehicleId,A.DlvBoyId,
		B.PrdId,B.PrdBatId,Budget,K.SMName,D.RMName,E.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,G.VehicleRegNo,H.DlvBoyName,
		I.PrdName,J.PrdBatCode,SalInvDate
	
	--->Added By Nanda on 06/04/2010-For QPS Scheem Amount-Credit Conversion
	--Values For Scheme Amount From SalesInvoice-QPS Convesrion-Qty Based
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId AS SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,0 AS PrdId,0 AS PrdBatId,ISNULL(SUM(B.CrNoteAmount),0) As FlatAmount,
		0 as DiscountPer,
		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		1,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,
		ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		'' AS PrdName,'' AS PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		1 as LineType,SalInvDate
	FROM SalesInvoice A INNER JOIN SalesInvoiceQPSSchemeAdj B ON A.SalId = B.SalId AND B.Mode=1
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId INNER JOIN ROUTEMASTER E ON A.DlvRMId = E.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId LEFT OUTER JOIN Vehicle G ON A.VehicleId = G.VehicleId
		LEFT OUTER JOIN DeliveryBoy H ON A.DlvBoyId = H.DlvBoyId 
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	GROUP BY B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,A.VehicleId,A.DlvBoyId,
		Budget,K.SMName,D.RMName,E.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,G.VehicleRegNo,H.DlvBoyName,SalInvDate

	--Values For Scheme Amount From SalesInvoice-QPS Convesrion-Date Based
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId AS SlabId,'' AS SalInvNo,0 AS SMId,0 AS RMId,0 AS DlvRMId,0 AS CtgLevelId,0 AS CtgMainId,0 AS RtrValueClassId,
		0 AS RtrId,4,0 AS VehicleId,0 AS DlvBoyId,0 AS PrdId,0 AS PrdBatId,ISNULL(SUM(B.CrNoteAmount),0) As FlatAmount,
		0 as DiscountPer,0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		1,'' AS SMName,'' AS RMName,'' AS DlvRMName,'' AS CtgLevelName,'' AS CtgName,'' AS ValueClassName,'' AS RtrName,'' AS VehicleRegNo,
		'' AS DlvBoyName,'' AS PrdName,'' AS PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		1 as LineType,B.LastModDate
	FROM SalesInvoiceQPSSchemeAdj B 
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND B.Mode=2
	WHERE B.LastModDate Between @FromDate AND @ToDate 
	GROUP BY B.SchId,B.SlabId,Budget,B.LastModDate
	--->Till Here

	--Values For Points From SalesInvoice
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,B.PrdId,B.PrdBatId,0 As FlatAmount,0 as DiscountPer,
		Points AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,
		ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		I.PrdName,J.PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		1 as LineType,SalInvDate
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId = B.SalId
		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId INNER JOIN ROUTEMASTER E ON A.DlvRMId = E.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId LEFT OUTER JOIN Vehicle G ON A.VehicleId = G.VehicleId
		LEFT OUTER JOIN DeliveryBoy H ON A.DlvBoyId = H.DlvBoyId INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN SalesInvoiceSchemeDtPoints L ON A.SalId = L.SalId AND C.SchId = L.SchId
		AND B.SlabId = L.SlabId
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3

	--Values For Free Product From SalesInvoice
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,
		FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,B.PrdId,B.PrdBatId,0 As FlatAmount,0 as DiscountPer,
		0 AS Points,L.FreePrdId As FreePrdId,L.FreePrdBatId AS FreePrdBatId,L.FreeQty as FreeQty,
		(L.FreeQty * O.PrdBatDetailValue) as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,
		ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		I.PrdName,J.PrdBatCode,M.PrdName as FreePrdName,N.PrdBatCode as FreeBatchName,
		'-' as GiftPrdName,'' as GiftBatchName,1 as LineType,SalInvDate
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId = B.SalId
		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId INNER JOIN ROUTEMASTER E ON A.DlvRMId = E.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId LEFT OUTER JOIN Vehicle G ON A.VehicleId = G.VehicleId
		LEFT OUTER JOIN DeliveryBoy H ON A.DlvBoyId = H.DlvBoyId INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN dbo.SalesInvoiceSchemeDtFreePrd L ON A.SalId = L.SalId AND C.SchId = L.SchId
		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.FreePrdId = M.PrdId
		INNER JOIN ProductBatch N ON L.FreePrdBatId = N.PrdBatId
		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.FreePriceId
	INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo
	AND P.ClmRte = 1
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3

	--Values For Gift Product From SalesInvoice
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,
		FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,B.PrdId,B.PrdBatId,0 As FlatAmount,0 as DiscountPer,
		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,
		L.GiftPrdId as GiftPrdId,L.GiftPrdBatId As GiftPrdBatId,L.GiftQty as GiftQty,
		(L.GiftQty * O.PrdBatDetailValue) as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),
		1 as Selected,@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,
		ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		I.PrdName,J.PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,
		M.PrdName as GiftPrdName,N.PrdBatCode as GiftBatchName,1 as LineType,SalInvDate
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId = B.SalId
		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId INNER JOIN ROUTEMASTER E ON A.DlvRMId = E.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId LEFT OUTER JOIN Vehicle G ON A.VehicleId = G.VehicleId
		LEFT OUTER JOIN DeliveryBoy H ON A.DlvBoyId = H.DlvBoyId INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN dbo.SalesInvoiceSchemeDtFreePrd L ON A.SalId = L.SalId AND C.SchId = L.SchId
		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.GiftPrdId = M.PrdId
		INNER JOIN ProductBatch N ON L.GiftPrdBatId = N.PrdBatId
		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.GiftPriceId
	INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo
	AND P.ClmRte = 1
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3

	--rathi
	--Values For Scheme Amount From Return
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,0 as DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.Status,0 AS VehicleId,
		0 AS DlvBoyId,B.PrdId,B.PrdBatId,-1 * ISNULL(SUM(B.ReturnFlatAmount),0) As FlatAmount,
		-1 * ISNULL(SUM(B.ReturnDiscountPerAmount),0) as DiscountPer,
		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,'' as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,'' AS VehicleRegNo,'' AS DlvBoyName,
		I.PrdName,J.PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		2 as LineType,ReturnDate
	FROM ReturnHeader A INNER JOIN ReturnSchemeLineDt B ON A.ReturnId = B.ReturnId
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId  INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Status =0
	GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.Status,
		B.PrdId,B.PrdBatId,Budget,K.SMName,D.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,I.PrdName,J.PrdBatCode,ReturnDate

	--Values For Points From Return
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,0 as DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.Status,0 AS VehicleId,
		0 AS DlvBoyId,B.PrdId,B.PrdBatId,0 As FlatAmount,0 as DiscountPer,
		-1 * ISNULL(SUM(ReturnPoints),0) AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,'' as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,'' AS VehicleRegNo,''AS DlvBoyName,
		I.PrdName,J.PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		2 as LineType,ReturnDate
	FROM ReturnHeader A INNER JOIN ReturnProduct A1 ON A.ReturnId = A1.ReturnId
		INNER JOIN SalesInvoiceSchemeDtBilled B ON A1.SalId IN (0,B.SalId) AND A1.PrdId = B.PrdId
		AND A1.PrdBatId = B.PrdBatId
		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN ReturnSchemePointsDt L ON A.ReturnId = L.ReturnId AND C.SchId = L.SchId
		AND B.SlabId = L.SlabId
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Status =0
	GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.Status,B.PrdId,B.PrdBatId,
		Budget,K.SMName,D.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,I.PrdName,J.PrdBatCode,ReturnDate

	--Values For Free Product From Return
--	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
--		PrdID,PrdBatId,FlatAmount,DiscountPer,
--		Points,FreePrdId,FreePrdBatId,FreeQty,
--		FreeValue,GiftPrdId,GiftPrdBatId,
--		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
--		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
--		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
--	SELECT B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,0 as DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.Status,0 AS VehicleId,
--		0 AS DlvBoyId,B.PrdId,B.PrdBatId,0 As FlatAmount,0 as DiscountPer,
--		0 AS Points,L.FreePrdId As FreePrdId,L.FreePrdBatId AS FreePrdBatId,(-1 * ISNULL(SUM(L.ReturnFreeQty),0)) as FreeQty,
--		(-1 * (ISNULL(SUM(L.ReturnFreeQty),0) * O.PrdBatDetailValue)) as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
--		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),1 as Selected,
--		@Pi_UsrId,K.SMName,D.RMName,'' as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,'' AS VehicleRegNo,
--		'' AS DlvBoyName,I.PrdName,J.PrdBatCode,M.PrdName as FreePrdName,N.PrdBatCode as FreeBatchName,
--		'-' as GiftPrdName,'' as GiftBatchName,2 as LineType,ReturnDate
--	FROM ReturnHeader A INNER JOIN ReturnProduct A1 ON A.ReturnId = A1.ReturnId
--		INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId IN (0,B.SalId) AND A1.PrdId = B.PrdId
--		AND A1.PrdBatId = B.PrdBatId
--		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
--			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)
--		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
--		INNER JOIN RouteMaster D ON A.RMId = D.RMId
--		INNER JOIN Retailer F ON A.RtrId = F.RtrId INNER JOIN Product I ON B.PrdID = I.PrdId
--		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
--		INNER JOIN ReturnSchemeFreePrdDt L ON A.ReturnId = L.ReturnId AND C.SchId = L.SchId
--		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.FreePrdId = M.PrdId
--		INNER JOIN ProductBatch N ON L.FreePrdBatId = N.PrdBatId
--		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.FreePriceId
--	INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo
--	AND P.ClmRte = 1
--		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
--		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
--		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
--		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
--	WHERE ReturnDate Between @FromDate AND @ToDate  AND
--		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
--		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
--		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
--		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
--		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
--		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
--		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
--		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
--		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
--		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
--		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
--		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
--		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
--		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
--		A.Status =0
--	GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,
--		 A.RtrId,A.Status,B.PrdId,B.PrdBatId,L.FreePrdId,L.FreePrdBatId,O.PrdBatDetailValue,Budget,
--		 K.SMName,D.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,I.PrdName,
--		 J.PrdBatCode,M.PrdName,N.PrdBatCode,ReturnDate
		
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,
		FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT RSF.SchId,RSF.SlabId,RH.ReturnCode,S.SMId,RM.RMId,0 AS DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,RH.RtrId,RH.Status,0 AS VehicleId,
		0 AS DlvBoyId,0 AS PrdId,0 AS PrdBatId,0 AS FlatAmount,0 AS DiscountPer,
		0 AS Points,RSF.FreePrdId,RSF.FreePrdBatId,(-1 * ISNULL(SUM(RSF.ReturnFreeQty),0)) AS FreeQty,
		(-1 * (ISNULL(SUM(RSF.ReturnFreeQty),0) * PBD.PrdBatDetailValue)) AS FreeValue,0 AS GiftPrdId,0 AS GiftPrdBatId,
		0 AS GiftQty,0 AS GiftValue,SM.Budget AS SchemeBudget,dbo.Fn_ReturnBudgetUtilized(RSF.SchId),1 AS Selected,
		2,S.SMName,RM.RMName,'' AS DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,R.RtrName,'' AS VehicleRegNo,
		'' AS DlvBoyName,P.PrdName,PB.PrdBatCode,P.PrdName AS FreePrdName,PB.PrdBatCode AS FreeBatchName,
		'-' AS GiftPrdName,'' AS GiftBatchName,2 AS LineType,ReturnDate
	FROM ReturnHeader RH 
		INNER JOIN ReturnSchemeFreePrdDt RSF ON  RH.ReturnId = RSF.ReturnId 
		INNER JOIN SchemeMaster SM ON  SM.SchId = RSF.SchId 
		INNER JOIN SalesMan S ON  S.SMId = RH.SMId
		INNER JOIN RouteMaster RM ON  RM.RMId = RH.RMId
		INNER JOIN Retailer R ON  R.RtrId = RH.RtrId 
		INNER JOIN RetailerValueClassMap RVCM ON  RVCM.RtrId=R.RtrId
		INNER JOIN RetailerValueClass RVC ON  RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC ON  RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL ON  RCL.CtgLevelId=RC.CtgLevelId 
		INNER JOIN Product P ON RSF.FreePrdId = P.PrdId
		INNER JOIN ProductBatch PB ON RSF.FreePrdBatId = PB.PrdBatId AND SM.CmpId=RCL.CmpId
		INNER JOIN ProductBatchDetails PBD (NOLOCK) ON  PB.PrdBatId = PBD.PrdBatID AND PBD.PriceId=RSF.FreePriceId
		INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId = PBD.BatchSeqId AND PBD.SlNo = BC.SlNo AND BC.ClmRte = 1
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(RH.SMId = (CASE @fSMId WHEN 0 THEN RH.SMId Else 0 END) OR
		RH.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(RH.RMId = (CASE @fRMId WHEN 0 THEN RH.RMId Else 0 END) OR
		RH.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(RH.RtrID = (CASE @fRtrId WHEN 0 THEN RH.RtrID Else 0 END) OR
		RH.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(SM.SchId = (CASE @fSchId WHEN 0 THEN SM.SchId Else 0 END) OR
		SM.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		RH.Status =0
	GROUP BY RSF.SchId,RSF.SlabId,RH.ReturnCode,S.SMId,RM.RMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,RH.RtrId,RH.Status,
		RSF.FreePrdId,RSF.FreePrdBatId,PBD.PrdBatDetailValue,SM.Budget,S.SMName,RM.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,R.RtrName,
		P.PrdName,PB.PrdBatCode,P.PrdName,PB.PrdBatCode,ReturnDate

	--Values For Gift Product From Return
--	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
--		PrdID,PrdBatId,FlatAmount,DiscountPer,
--		Points,FreePrdId,FreePrdBatId,FreeQty,
--		FreeValue,GiftPrdId,GiftPrdBatId,
--		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
--		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
--		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
--	SELECT B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,0 as DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.Status,0 AS VehicleId,
--		0 AS DlvBoyId,B.PrdId,B.PrdBatId,0 As FlatAmount,0 as DiscountPer,
--		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,
--		L.GiftPrdId as GiftPrdId,L.GiftPrdBatId As GiftPrdBatId,(-1 * ISNULL(SUM(L.ReturnGiftQty),0)) as GiftQty,
--		(-1 * ISNULL(SUM(L.ReturnGiftQty),0) * O.PrdBatDetailValue) as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),
--		1 as Selected,@Pi_UsrId,K.SMName,D.RMName,'' as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,
--		'' AS VehicleRegNo,'' AS DlvBoyName,
--		I.PrdName,J.PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,
--		M.PrdName as GiftPrdName,N.PrdBatCode as GiftBatchName,2 as LineType,ReturnDate
--	FROM ReturnHeader A INNER JOIN ReturnProduct A1 ON A.ReturnId = A1.ReturnId
--		INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId IN (0,B.SalId) AND A1.PrdId = B.PrdId
--		AND A1.PrdBatId = B.PrdBatId
--		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
--			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId)
--		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
--		INNER JOIN RouteMaster D ON A.RMId = D.RMId
--		INNER JOIN Retailer F ON A.RtrId = F.RtrId INNER JOIN Product I ON B.PrdID = I.PrdId
--		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
--		INNER JOIN dbo.ReturnSchemeFreePrdDt L ON A.ReturnId = L.ReturnId AND C.SchId = L.SchId
--		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.GiftPrdId = M.PrdId
--		INNER JOIN ProductBatch N ON L.GiftPrdBatId = N.PrdBatId
--		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.GiftPriceId
--	INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo
--	AND P.ClmRte = 1
--		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
--		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
--		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
--		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
--	WHERE ReturnDate Between @FromDate AND @ToDate  AND
--		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
--		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
--		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
--		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
--		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
--		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
--		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
--		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
--		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
--		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
--		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
--		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
--		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
--		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
--		A.Status =0
--	GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,
--		 A.RtrId,A.Status,B.PrdId,B.PrdBatId,L.GiftPrdId,L.GiftPrdBatId,O.PrdBatDetailValue,Budget,
--		 K.SMName,D.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,I.PrdName,
--		 J.PrdBatCode,M.PrdName,N.PrdBatCode,ReturnDate

	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,
		FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT RSF.SchId,RSF.SlabId,RH.ReturnCode,S.SMId,RM.RMId,0 AS DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,RH.RtrId,RH.Status,0 AS VehicleId,
		0 AS DlvBoyId,0 AS PrdId,0 AS PrdBatId,0 AS FlatAmount,0 AS DiscountPer,
		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,
		RSF.GiftPrdId,RSF.GiftPrdBatId,(-1 * ISNULL(SUM(RSF.ReturnGiftQty),0)) as GiftQty,
		(-1 * ISNULL(SUM(RSF.ReturnGiftQty),0) * PBD.PrdBatDetailValue) as GiftValue,SM.Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(RSF.SchId),
		1 as Selected,@Pi_UsrId,S.SMName,RM.RMName,'' as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,R.RtrName,
		'' AS VehicleRegNo,'' AS DlvBoyName,
		P.PrdName,PB.PrdBatCode,'-' AS FreePrdName,'' AS FreeBatchName,
		P.PrdName AS GiftPrdName,PB.PrdBatCode AS GiftBatchName,2 AS LineType,ReturnDate
	FROM ReturnHeader RH 
		INNER JOIN ReturnSchemeFreePrdDt RSF ON  RH.ReturnId = RSF.ReturnId 
		INNER JOIN SchemeMaster SM ON  SM.SchId = RSF.SchId 
		INNER JOIN SalesMan S ON  S.SMId = RH.SMId
		INNER JOIN RouteMaster RM ON  RM.RMId = RH.RMId
		INNER JOIN Retailer R ON  R.RtrId = RH.RtrId 
		INNER JOIN RetailerValueClassMap RVCM ON  RVCM.RtrId=R.RtrId
		INNER JOIN RetailerValueClass RVC ON  RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC ON  RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL ON  RCL.CtgLevelId=RC.CtgLevelId 
		INNER JOIN Product P ON RSF.GiftPrdId = P.PrdId
		INNER JOIN ProductBatch PB ON RSF.GiftPrdBatId = PB.PrdBatId AND SM.CmpId=RCL.CmpId
		INNER JOIN ProductBatchDetails PBD (NOLOCK) ON  PB.PrdBatId = PBD.PrdBatID AND PBD.PriceId=RSF.GiftPriceId
		INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId = PBD.BatchSeqId AND PBD.SlNo = BC.SlNo AND BC.ClmRte = 1
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(RH.SMId = (CASE @fSMId WHEN 0 THEN RH.SMId Else 0 END) OR
		RH.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(RH.RMId = (CASE @fRMId WHEN 0 THEN RH.RMId Else 0 END) OR
		RH.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(RH.RtrID = (CASE @fRtrId WHEN 0 THEN RH.RtrID Else 0 END) OR
		RH.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(SM.SchId = (CASE @fSchId WHEN 0 THEN SM.SchId Else 0 END) OR
		SM.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		RH.Status =0
	GROUP BY RSF.SchId,RSF.SlabId,RH.ReturnCode,S.SMId,RM.RMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,RH.RtrId,RH.Status,
		RSF.GiftPrdId,RSF.GiftPrdBatId,PBD.PrdBatDetailValue,SM.Budget,S.SMName,RM.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,R.RtrName,
		P.PrdName,PB.PrdBatCode,P.PrdName,PB.PrdBatCode,ReturnDate

	--Values For UnSelected Scheme From SalesInvoice
	INSERT INTO RPTStoreSchemeDetails (SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,DlvSts,VehicleId,DlvBoyId,
		PrdID,PrdBatId,FlatAmount,DiscountPer,
		Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,
		GiftQty,GiftValue,SchemeBudget,BudgetUtilized,Selected,
		UserId,SMName,RMName,DlvRMName,CtgLevelName,CtgName,ValueClassName,RtrName,VehicleName,DeliveryBoyName,
		PrdName,BatchName,FreePrdName,FreeBatchName,GiftPrdName,GiftBatchName,LineType,ReferDate)
	SELECT B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,0 as PrdId,0 as PrdBatId,0 As FlatAmount,0 as DiscountPer,
		0 AS Points,0 As FreePrdId,0 AS FreePrdBatId,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(B.SchId),2 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,
		ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		'' As PrdName,'' as PrdBatCode,'-' as FreePrdName,'' as FreeBatchName,'-' as GiftPrdName,'' as GiftBatchName,
		3 as LineType,SalInvDate
	FROM SalesInvoice A INNER JOIN SalesInvoiceUnSelectedScheme B ON A.SalId = B.SalId
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId INNER JOIN ROUTEMASTER E ON A.DlvRMId = E.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId LEFT OUTER JOIN Vehicle G ON A.VehicleId = G.VehicleId
		LEFT OUTER JOIN DeliveryBoy H ON A.DlvBoyId = H.DlvBoyId
		INNER JOIN RetailerValueClassMap RVCM on RVCM.Rtrid=F.RtrId
		INNER JOIN RetailerValueClass RVC on RVCM.RtrValueClassId =RVC.RtrClassId
		INNER JOIN RetailerCategory RC on RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL on RCL.CtgLevelId=RC.CtgLevelId AND C.CmpId=RCL.CmpId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(A.SMId = (CASE @fSMId WHEN 0 THEN A.SMId Else 0 END) OR
		A.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
		(A.RMId = (CASE @fRMId WHEN 0 THEN A.RMId Else 0 END) OR
		A.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
		(RCL.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId Else 0 END) OR
		RCL.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
		(RC.CtgMainId = (CASE @CtgMainId WHEN 0 THEN RC.CtgMainId Else 0 END) OR
		RC.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
		(RVC.RtrClassId = (CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId Else 0 END) OR
		RVC.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
		(A.RtrID = (CASE @fRtrId WHEN 0 THEN A.RtrID Else 0 END) OR
		A.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.dlvsts >3
	GROUP BY B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,A.VehicleId,A.DlvBoyId,
		Budget,K.SMName,D.RMName,E.RMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,G.VehicleRegNo,H.DlvBoyName,SalInvDate
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-171-010

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_SchemeUtilization]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_SchemeUtilization]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

--SELECT * FROM RtpSchemeWithOutPrimary ORDER BY ReferNo,SchId WHERE SchId IN (3,4)
--EXEC Proc_SchemeUtilization 152,1
CREATE PROCEDURE [dbo].[Proc_SchemeUtilization]
(	
	@Pi_RptId		INT,
	@Pi_UsrId		INT
)
AS
SET NOCOUNT ON
BEGIN
/**************************************************************************************************
* PROCEDURE: Proc_SchemeUtilization
* PURPOSE: General Procedure To Get the Scheme Utilization Without Primary Scheme
* NOTES:
* CREATED: Boopathy.P On 05/08/2008
* MODIFIED
* DATE			AUTHOR			DESCRIPTION
----------------------------------------------------------------------------------------------------
*27/10/2009		Thiruvengadam	Changes in Scheme Calculation based on Claim Rate for Free Product
****************************************************************************************************/
DECLARE @FromDate	AS 	DateTime
DECLARE @ToDate		AS	DateTime
DECLARE @SchId		AS	Int
DECLARE @SMId		AS	Int
DECLARE @RMId		AS	Int
DECLARE @RtrId		AS	Int
--Till Here
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SchId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))
	SET @SMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	DELETE FROM RtpSchemeWithOutPrimary WHERE UserId=@Pi_UsrId AND RptId=@Pi_RptId
	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT B.SchId,B.SlabId,A.SalInvNo,LEFT(A.SalInvNo,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
		B.PrdId,I.PrdName,B.PrdBatId,J.PrdBatCode,0 AS BaseQty,ISNULL(SUM(B.FlatAmount),0) As FlatAmount,
		(CASE B.PrimarySchemeAmt
		WHEN 0 THEN ISNULL(SUM(B.DisCountPerAmount),0) ELSE
		(ISNULL(SUM(B.DisCountPerAmount),0)-B.PrimarySchemeAmt) END )as DiscountPer,
		B.PrimarySchemeAmt AS PrmSchAmt,0 AS Points,0 As FreePrdId,
		'-' as FreePrdName,0 AS FreePrdBatId,'' as FreeBatchName,0 as FreeQty,0 as FreeValue,0 as GiftPrdId,
		'-' as GiftPrdName,0 As GiftPrdBatId,'' as GiftBatchName,0 as GiftQty,0 as GiftValue,
		Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(B.SchId),1 as Selected,
		1 as LineType,SalInvDate,@Pi_RptId,@Pi_UsrId,1
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeLineWise B ON A.SalId = B.SalId
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId
		INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId
		INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	GROUP BY B.SchId,B.SlabId,A.SalInvNo,A.SMId,A.RMId,A.RtrId,B.PrdId,B.PrdBatId,Budget,K.SMName,
		 D.RMName,F.RtrName,I.PrdName,J.PrdBatCode,SalInvDate,B.PrimarySchemeAmt
	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT B.SchId,B.SlabId,A.SalInvNo,LEFT(A.SalInvNo,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
		B.PrdId,I.PrdName,B.PrdBatId,J.PrdBatCode,0 AS BaseQty,0 As FlatAmount,0 as DiscountPer,0 AS PrmSchAmt,0 AS Points,
		L.FreePrdId As FreePrdId,M.PrdName as FreePrdName,L.FreePrdBatId AS FreePrdBatId,
		N.PrdBatCode as FreeBatchName,L.FreeQty as FreeQty,
		(L.FreeQty * O.PrdBatDetailValue) as FreeValue,0 as GiftPrdId,'-' as GiftPrdName,0 As GiftPrdBatId,
		'' as GiftBatchName,0 as GiftQty,0 as GiftValue,
		Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(B.SchId),1 as Selected,
		1 as LineType,SalInvDate,@Pi_RptId,@Pi_UsrId,2
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId = B.SalId
		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
		B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId) AND
		B.PrdBatId= (SELECT Top 1 PrdBatId FROM SalesInvoiceSchemeDtBilled B2 WHERE
		B.SalId = B2.SalId AND B.SchId = B2.SchID AND B.SlabId = B2.SlabId AND
		B2.PrdId=
		 (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
		B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId))
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId
		INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId
		INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN dbo.SalesInvoiceSchemeDtFreePrd L ON A.SalId = L.SalId AND C.SchId = L.SchId
		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.FreePrdId = M.PrdId
		INNER JOIN ProductBatch N ON L.FreePrdBatId = N.PrdBatId
		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.FreePriceId
		INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo
		AND P.ClmRte=1--P.SelRte = 1
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT B.SchId,B.SlabId,A.SalInvNo,LEFT(A.SalInvNo,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
		B.PrdId,I.PrdName,B.PrdBatId,J.PrdBatCode,0 AS BaseQty,0 As FlatAmount,0 as DiscountPer,0 AS PrmSchAmt,0 AS Points,
		0 As FreePrdId,'-' as FreePrdName,0 AS FreePrdBatId,'' as FreeBatchName,0 as FreeQty,0 as FreeValue,
		L.GiftPrdId as GiftPrdId,M.PrdName as GiftPrdName,L.GiftPrdBatId As GiftPrdBatId,N.PrdBatCode as GiftBatchName,
		L.GiftQty as GiftQty,(L.GiftQty * O.PrdBatDetailValue) as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(B.SchId),
		1 as Selected,1 as LineType,SalInvDate,@Pi_RptId,@Pi_UsrId,3
	FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId = B.SalId
		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId) AND
		B.PrdBatId= (SELECT Top 1 PrdBatId FROM SalesInvoiceSchemeDtBilled B2 WHERE
		B.SalId = B2.SalId AND B.SchId = B2.SchID AND B.SlabId = B2.SlabId AND
		B2.PrdId=
		 (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
		B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId))
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId
		INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		INNER JOIN dbo.SalesInvoiceSchemeDtFreePrd L ON A.SalId = L.SalId AND C.SchId = L.SchId
		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.GiftPrdId = M.PrdId
		INNER JOIN ProductBatch N ON L.GiftPrdBatId = N.PrdBatId
		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.GiftPriceId
		INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo AND P.ClmRte=1--P.SelRte = 1
	WHERE SalInvDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Dlvsts >3
	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT B.SchId,B.SlabId,A.ReturnCode,LEFT(A.ReturnCode,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
		B.PrdId,I.PrdName,B.PrdBatId,J.PrdBatCode,0 AS BaseQty,-1 * ISNULL(SUM(B.ReturnFlatAmount),0) As FlatAmount,
		(CASE A.ReturnMode WHEN 2 THEN
			(	CASE B.PrimarySchAmt WHEN 0 THEN -1 * ISNULL(SUM(B.ReturnDiscountPerAmount),0)
				ELSE -1 * (
					CASE ISNULL(SUM(B.ReturnDiscountPerAmount),0) WHEN 0 THEN 0
					ELSE ISNULL(SUM(B.ReturnDiscountPerAmount),0)-B.PrimarySchAmt END)
			END)
		ELSE -1 *ISNULL(SUM(B.ReturnDiscountPerAmount),0) END )AS DiscountPer,B.PrimarySchAmt AS PrmSchAmt,
		0 AS Points,0 As FreePrdId,'-' as FreePrdName,0 AS FreePrdBatId,'' as FreeBatchName,
		0 as FreeQty,0 as FreeValue,0 as GiftPrdId,'-' as GiftPrdName,0 As GiftPrdBatId,'' as GiftBatchName,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(B.SchId),1 as Selected,		
		2 as LineType,ReturnDate,@Pi_RptId,@Pi_UsrId,1
	FROM ReturnHeader A INNER JOIN ReturnSchemeLineDt B ON A.ReturnId = B.ReturnId
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId  INNER JOIN Product I ON B.PrdID = I.PrdId
		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
		--INNER JOIN SalesInvoiceSchemeLineWise SSL ON SSL.SalId=A.SalId AND SSL.SlabId=B.SlabId
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Status =0
	GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,A.RtrId,B.PrimarySchAmt,
		B.PrdId,B.PrdBatId,Budget,K.SMName,D.RMName,F.RtrName,I.PrdName,J.PrdBatCode,ReturnDate,A.ReturnMode
		--,SSL.PrimarySchemeAmt
	
--	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
--		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
--		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
--		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
--	SELECT B.SchId,B.SlabId,A.ReturnCode,LEFT(A.ReturnCode,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
--		B.PrdId,I.PrdName,B.PrdBatId,J.PrdBatCode,0 AS BaseQty,0 As FlatAmount,0 as DiscountPer,0 AS PrmSchAmt,
--		0 AS Points,L.FreePrdId As FreePrdId,M.PrdName as FreePrdName,L.FreePrdBatId AS FreePrdBatId,
--		N.PrdBatCode as FreeBatchName,(-1 * ISNULL(SUM(L.ReturnFreeQty),0)) as FreeQty,
--		(-1 * (ISNULL(SUM(L.ReturnFreeQty),0) * O.PrdBatDetailValue)) as FreeValue,
--		0 as GiftPrdId,'-' as GiftPrdName,0 As GiftPrdBatId,'' as GiftBatchName,
--		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(B.SchId),1 as Selected,
--		2 as LineType,ReturnDate,@Pi_RptId,@Pi_UsrId,2	
--	FROM ReturnHeader A INNER JOIN ReturnProduct A1 ON A.ReturnId = A1.ReturnId
--		INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId IN (0,B.SalId) AND A1.PrdId = B.PrdId
--		AND A1.PrdBatId = B.PrdBatId
--		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
--			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId) AND
--		B.PrdBatId= (SELECT Top 1 PrdBatId FROM SalesInvoiceSchemeDtBilled B2 WHERE
--		B.SalId = B2.SalId AND B.SchId = B2.SchID AND B.SlabId = B2.SlabId AND
--		B2.PrdId=
--		 (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
--		B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId))
--		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
--		INNER JOIN RouteMaster D ON A.RMId = D.RMId
--		INNER JOIN Retailer F ON A.RtrId = F.RtrId INNER JOIN Product I ON B.PrdID = I.PrdId
--		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
--		INNER JOIN ReturnSchemeFreePrdDt L ON A.ReturnId = L.ReturnId AND C.SchId = L.SchId AND B.Salid=L.SalId
--		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.FreePrdId = M.PrdId
--		INNER JOIN ProductBatch N ON L.FreePrdBatId = N.PrdBatId
--		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.FreePriceId
--		INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo AND P.ClmRte=1--P.SelRte = 1
--	WHERE ReturnDate Between @FromDate AND @ToDate  AND
--		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
--		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
--		A.Status =0
--		GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,
--			 A.RtrId,B.PrdId,B.PrdBatId,L.FreePrdId,L.FreePrdBatId,O.PrdBatDetailValue,Budget,
--			 K.SMName,D.RMName,F.RtrName,I.PrdName,
--			 J.PrdBatCode,M.PrdName,N.PrdBatCode,ReturnDate


	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT L.SchId,L.SlabId,A.ReturnCode,LEFT(A.ReturnCode,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
		M.PrdId,M.PrdName,N.PrdBatId,N.PrdBatCode,0 AS BaseQty,0 As FlatAmount,0 as DiscountPer,0 AS PrmSchAmt,
		0 AS Points,L.FreePrdId As FreePrdId,M.PrdName as FreePrdName,L.FreePrdBatId AS FreePrdBatId,
		N.PrdBatCode as FreeBatchName,(-1 * ISNULL(SUM(L.ReturnFreeQty),0)) as FreeQty,
		(-1 * (ISNULL(SUM(L.ReturnFreeQty),0) * O.PrdBatDetailValue)) as FreeValue,
		0 as GiftPrdId,'-' as GiftPrdName,0 As GiftPrdBatId,'' as GiftBatchName,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(L.SchId),1 as Selected,
		2 as LineType,ReturnDate,@Pi_RptId,@Pi_UsrId,2	
	FROM ReturnHeader A 		
		INNER JOIN ReturnSchemeFreePrdDt L ON A.ReturnId = L.ReturnId 
		INNER JOIN SchemeMaster C ON L.SchId = C.SchId
		INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId 		
		INNER JOIN Product M ON L.FreePrdId = M.PrdId
		INNER JOIN ProductBatch N ON L.FreePrdBatId = N.PrdBatId
		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.FreePriceId
		INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo AND P.ClmRte=1
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Status =0
	GROUP BY L.SchId,L.SlabId,A.ReturnCode,A.SMId,A.RMId,
		 A.RtrId,L.FreePrdId,L.FreePrdBatId,O.PrdBatDetailValue,Budget,M.PrdId,N.PrdBatId,
		 K.SMName,D.RMName,F.RtrName,M.PrdName,N.PrdBatCode,ReturnDate

--	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
--		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
--		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
--		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
--	SELECT B.SchId,B.SlabId,A.ReturnCode,LEFT(A.ReturnCode,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
--		B.PrdId,I.PrdName,B.PrdBatId,J.PrdBatCode,0 AS BaseQty,0 As FlatAmount,0 as DiscountPer,0 AS PrmSchAmt,
--		0 AS Points,0 As FreePrdId,'-' as FreePrdName,0 AS FreePrdBatId,'' as FreeBatchName,
--		0 as FreeQty,0 as FreeValue,L.GiftPrdId as GiftPrdId,M.PrdName as GiftPrdName,
--		L.GiftPrdBatId As GiftPrdBatId,N.PrdBatCode as GiftBatchName,(-1 * ISNULL(SUM(L.ReturnGiftQty),0))
--		as GiftQty,(-1 * ISNULL(SUM(L.ReturnGiftQty),0) * O.PrdBatDetailValue) as GiftValue,
--		Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(B.SchId),1 as Selected,
--		2 as LineType,ReturnDate,@Pi_RptId,@Pi_UsrId,3
--	FROM ReturnHeader A INNER JOIN ReturnProduct A1 ON A.ReturnId = A1.ReturnId
--		INNER JOIN SalesInvoiceSchemeDtBilled B ON A.SalId IN (0,B.SalId) AND A1.PrdId = B.PrdId
--		AND A1.PrdBatId = B.PrdBatId
--		AND B.PrdId = (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
--			B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId) AND
--		B.PrdBatId= (SELECT Top 1 PrdBatId FROM SalesInvoiceSchemeDtBilled B2 WHERE
--		B.SalId = B2.SalId AND B.SchId = B2.SchID AND B.SlabId = B2.SlabId AND
--		B2.PrdId=
--		 (Select TOP 1 PrdId FROM SalesInvoiceSchemeDtBilled B1 WHERE
--		B.SalId = B1.SalId AND B.SchId = B1.SchID AND B.SlabId = B1.SlabId))
--		INNER JOIN SchemeMaster C ON B.SchId = C.SchId INNER JOIN SalesMan K ON A.SMId = K.SMId
--		INNER JOIN RouteMaster D ON A.RMId = D.RMId
--		INNER JOIN Retailer F ON A.RtrId = F.RtrId INNER JOIN Product I ON B.PrdID = I.PrdId
--		INNER JOIN ProductBatch J ON B.PrdBatId = J.PrdBatId AND I.PrdID = J.PrdId
--		INNER JOIN dbo.ReturnSchemeFreePrdDt L ON A.ReturnId = L.ReturnId AND C.SchId = L.SchId AND B.Salid=L.SalId
--		AND L.SlabId= B.SlabId INNER JOIN Product M ON L.GiftPrdId = M.PrdId
--		INNER JOIN ProductBatch N ON L.GiftPrdBatId = N.PrdBatId
--		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.GiftPriceId
--		INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo AND P.ClmRte=1--P.SelRte = 1
--	WHERE ReturnDate Between @FromDate AND @ToDate  AND
--		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
--		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
--		A.Status =0
--	GROUP BY B.SchId,B.SlabId,A.ReturnCode,A.SMId,A.RMId,
--		 A.RtrId,B.PrdId,B.PrdBatId,L.GiftPrdId,L.GiftPrdBatId,O.PrdBatDetailValue,Budget,
--		 K.SMName,D.RMName,F.RtrName,I.PrdName,J.PrdBatCode,M.PrdName,N.PrdBatCode,ReturnDate

	INSERT INTO RtpSchemeWithOutPrimary (SchId,SlabId,ReferNo,RefText,SMId,SMName,RMId,RMName,RtrId,RtrName,PrdId,PrdName,PrdBatId,
		BatchName,BaseQty,FlatAmount,DiscountPer,PrmSchAmt,Points,FreePrdId,FreePrdName,FreePrdBatId,FreeBatchName,
		FreeQty,FreeValue,GiftPrdId,GiftPrdName,GiftPrdBatId,GiftBatchName,GiftQty,GiftValue,
		SchemeBudget,BudgetUtilized,Selected,LineType,ReferDate,RptId,UserId,Type)
	SELECT L.SchId,L.SlabId,A.ReturnCode,LEFT(A.ReturnCode,3),A.SMId,K.SMName,A.RMId,D.RMName,A.RtrId,F.RtrName,
		M.PrdId,M.PrdName,N.PrdBatId,N.PrdBatCode,0 AS BaseQty,0 As FlatAmount,0 as DiscountPer,0 AS PrmSchAmt,
		0 AS Points,0 As FreePrdId,'-' as FreePrdName,0 AS FreePrdBatId,'' as FreeBatchName,
		0 as FreeQty,0 as FreeValue,L.GiftPrdId as GiftPrdId,M.PrdName as GiftPrdName,
		L.GiftPrdBatId As GiftPrdBatId,N.PrdBatCode as GiftBatchName,(-1 * ISNULL(SUM(L.ReturnGiftQty),0))
		as GiftQty,(-1 * ISNULL(SUM(L.ReturnGiftQty),0) * O.PrdBatDetailValue) as GiftValue,
		Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilizedWithOutPrimary(L.SchId),1 as Selected,
		2 as LineType,ReturnDate,@Pi_RptId,@Pi_UsrId,3
	FROM ReturnHeader A 		
		INNER JOIN ReturnSchemeFreePrdDt L ON A.ReturnId = L.ReturnId 
		INNER JOIN SchemeMaster C ON L.SchId = C.SchId
		INNER JOIN SalesMan K ON A.SMId = K.SMId
		INNER JOIN RouteMaster D ON A.RMId = D.RMId
		INNER JOIN Retailer F ON A.RtrId = F.RtrId 		
		INNER JOIN Product M ON L.GiftPrdId = M.PrdId
		INNER JOIN ProductBatch N ON L.GiftPrdBatId = N.PrdBatId
		INNER JOIN ProductBatchDetails O (NOLOCK) ON N.PrdBatId = O.PrdBatID AND O.PriceId=L.GiftPriceId
		INNER JOIN BatchCreation P (NOLOCK) ON P.BatchSeqId = N.BatchSeqId AND O.SlNo = P.SlNo AND P.ClmRte=1
	WHERE ReturnDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @SchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		A.Status =0
	GROUP BY L.SchId,L.SlabId,A.ReturnCode,A.SMId,A.RMId,
		 A.RtrId,L.GiftPrdId,L.GiftPrdBatId,O.PrdBatDetailValue,Budget,M.PrdId,N.PrdBatId,
		 K.SMName,D.RMName,F.RtrName,M.PrdName,N.PrdBatCode,ReturnDate
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-171-011

DELETE FROM RptExcelHeaders WHERE RptId=20

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','1','Reference Number','Reference Number','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','2','Stock Management Date','Date','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','3','Location Id','Location Id','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','4','Location Name','Location','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','5','Company Id','Company Id','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','6','Product Code','Product Code','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','7','Product Name','Product Name','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','8','Product Batch Code','Batch Code','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','9','Stock Mangement Id','Stock Mangement Id','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','10','Stock Mangement Description','Type','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','11','Qty','Qty','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','12','Uom1','Cases','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','13','Uom2','Boxes','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','14','Uom3','Strips','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','15','Uom4','Pieces','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','16','Rate','Rate','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('20','17','Amount','Amount','1','1')

--SRF-Nanda-171-012

DELETE FROM Configuration WHERE ModuleId LIKE 'BotreeERPCCode'

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('BotreeERPCCode','BotreeERPCCode','Display ERP Product in HotSearch',1,'',0,1)

--SRF-Nanda-171-013

DELETE FROM CustomCaptions WHERE TransID=5 AND CtrlName='HotSch-5-2000-103' AND CtrlID=2000 AND SubCtrlId=103
 
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
VALUES(5,2000,103,'HotSch-5-2000-103','Invoice Product Code','','',	1,1,1,GETDATE(),1,GETDATE(),'Invoice Product Code','','',1,1)


--529
UPDATE HotSearchEditorHd SET RemainsltString='
SELECT PrdSeqDtId,PrdId,PrdCcode,PrdDCode,PrdName,ERPPrdCode 
FROM 
(
	SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode
	FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK),Product A WITH (NOLOCK)
	LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode   
	WHERE B.TransactionId=vSParam AND A.PrdStatus=1 AND A.PrdType<> 3 AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId  AND A.CmpId = vFParam 
	Union 
	SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,A.PrdDCode,A.PrdName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode 
	FROM  Product A WITH (NOLOCK) 
	LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode
	WHERE PrdStatus = 1 AND A.PrdType <>3 AND A.PrdId NOT IN 
	( 
		SELECT PrdId FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK) 
		WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId
	) AND A.CmpId = vFParam 
) a ORDER BY PrdSeqDtId'
WHERE FormId=529

--530
UPDATE HotSearchEditorHd SET RemainsltString='
SELECT PrdSeqDtId,PrdId,PrdCcode,PrdDCode,PrdName,ERPPrdCode 
FROM 
(
	SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode 
	FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK),Product A WITH (NOLOCK)  
	LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode
	WHERE B.TransactionId=vSParam AND A.PrdStatus=1 AND A.PrdType<> 3 AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId  AND A.CmpId = vFParam 
	Union 
	SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,A.PrdDCode,A.PrdName,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode 
	FROM  Product A WITH (NOLOCK) 
	LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode
	WHERE PrdStatus = 1 AND A.PrdType <>3 AND A.PrdId NOT IN 
	( 
		SELECT PrdId FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK) 
		WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId
	) AND A.CmpId = vFParam 
) a ORDER BY PrdSeqDtId'
WHERE FormId=530

--756
UPDATE HotSearchEditorHd SET RemainsltString='
SELECT PrdSeqDtId,PrdId,PrdCcode,PrdDCode,PrdName,MRP,ERPPrdCode  
FROM 
(
	SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode   
	FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),
	ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK) 
	LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode
	WHERE B.TransactionId=vSParam AND A.PrdStatus=1 AND A.PrdType<> 3 AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId 
	AND A.CmpId = vFParam  and PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND PBD.BatchSeqId=BC.BatchSeqId 
	AND A.PrdId = PB.PrdId    
	Union    
	SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,A.PrdDCode, A.PrdName,PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode    
	FROM ProductBatch PB WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)    
	LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode
	WHERE PrdStatus = 1 AND A.PrdId = PB.PrdId  and PB.PrdBatId=PBD.PrdBatId   AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND    
	PBD.BatchSeqId=BC.BatchSeqId AND A.PrdType <>3 AND A.PrdId NOT IN 
	( 
		SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=vSParam   
		AND B.PrdSeqId=C.PrdSeqId
	)  AND A.CmpId = vFParam 
) a    ORDER BY PrdSeqDtId'
WHERE FormId=756

--757
UPDATE HotSearchEditorHd SET RemainsltString='
SELECT PrdSeqDtId,PrdId,PrdCcode,PrdDCode,PrdName,MRP,ERPPrdCode  
FROM 
( 
	SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode      
	FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),
	ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)    
	LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode
	WHERE B.TransactionId=vSParam AND A.PrdStatus=1 AND A.PrdType<> 3    AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId  AND A.CmpId = vFParam    
	and PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId   AND A.PrdId = PB.PrdId    
	Union    
	SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,A.PrdDCode,A.PrdName,PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'''') AS ERPPrdCode       
	FROM ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)    
	LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode
	WHERE PrdStatus = 1 AND A.PrdId = PB.PrdId  and PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  
	PBD.BatchSeqId=BC.BatchSeqId AND A.PrdType <>3 AND A.PrdId NOT IN 
	( 
		SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK) 
		WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId
	) AND A.CmpId = vFParam 
) a  ORDER BY PrdSeqDtId'
WHERE FormId=757

DELETE FROM HotSearchEditorDt WHERE FormId=529

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(1,529,'Product with Company Code','Sequence No','PrdSeqDtId',1000,0,'HotSch-5-2000-1',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(2,529,'Product with Company Code','Product Code','PrdCcode',1000,0,'HotSch-5-2000-17',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(3,529,'Product with Company Code','Product Name','PrdName',1500,0,'HotSch-5-2000-18',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(4,529,'Product with Company Code','Invoice Product Code','ERPPrdCode',1000,0,'HotSch-5-2000-103',5)


DELETE FROM HotSearchEditorDt WHERE FormId=530

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(1,530,'Product with Distributor Code','Sequence No','PrdSeqDtId',1000,0,'HotSch-5-2000-23',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(2,530,'Product with Distributor Code','Product Code','PrdDCode',1000,0,'HotSch-5-2000-24',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(3,530,'Product with Distributor Code','Product Name','PrdName',1500,0,'HotSch-5-2000-25',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(4,530,'Product with Distributor Code','Invoice Product Code','ERPPrdCode',1000,0,'HotSch-5-2000-103',5)


DELETE FROM HotSearchEditorDt WHERE FormId=756

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(1,756,'Display MRP Product with Company Code','Sequence No','PrdSeqDtId',1000,0,'HotSch-5-2000-95',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(2,756,'Display MRP Product with Company Code','Product Code','PrdCcode',1000,0,'HotSch-5-2000-96',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(3,756,'Display MRP Product with Company Code','Product Name','PrdName',1000,0,'HotSch-5-2000-97',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(4,756,'Display MRP Product with Company Code','MRP','MRP',500,0,'HotSch-5-2000-98',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(5,756,'Display MRP Product with Company Code','Invoice Product Code','ERPPrdCode',1000,0,'HotSch-5-2000-103',5)


DELETE FROM HotSearchEditorDt WHERE FormId=757

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(1,757,'Display MRP Product with Distributor Code','Sequence No','PrdSeqDtId',1000,0,'HotSch-5-2000-99',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(2,757,'Display MRP Product with Distributor Code','Product Code','PrdDCode',1000,0,'HotSch-5-2000-100',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(3,757,'Display MRP Product with Distributor Code','Product Name','PrdName',1000,0,'HotSch-5-2000-101',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(4,757,'Display MRP Product with Distributor Code','MRP','MRP',500,0,'HotSch-5-2000-102',5)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
VALUES(5,757,'Display MRP Product with Distributor Code','Invoice Product Code','ERPPrdCode',1000,0,'HotSch-5-2000-103',5)


--SRF-Nanda-171-014

if not exists (Select Id,name from Syscolumns where name = 'CmpSchCode' and id in (Select id from 
	Sysobjects where name ='TempSchemeClaimDetails'))
begin
	ALTER TABLE [dbo].[TempSchemeClaimDetails]
	ADD [CmpSchCode] NVARCHAR(100) NULL 
END
GO

--SRF-Nanda-171-015

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ReturnSchemeClaims]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ReturnSchemeClaims]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_ReturnSchemeClaims 17,0,1,'2009-05-01','2009-05-31',1,16

CREATE Procedure [dbo].[Proc_ReturnSchemeClaims]
(
	@Pi_ClmGroupId 		INT,
	@Pi_ClmId		INT,
	@Pi_CmpId		INT,
	@Pi_FromDate		DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_ReturnSchemeClaims
* PURPOSE	: To Return Scheme Claims
* CREATED	: Thrinath
* CREATED DATE	: 04/12/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
Begin
DECLARE @SchMst Table
(
	SchId 	INT,
	SchCode	nVarchar(100),
	SchDesc	nVarChar(100)
)

DECLARE @SchemeDetails TABLE
(
	SalInvNo		nVarChar(100),
	SchId			INT,
	SchCode			nVarchar(100),
	SchDesc			nVarChar(100),
	SlabId			INT,
	DiscountAmt		Numeric(38,6),
	FreeAmt			Numeric(38,6),
	GiftAmt			Numeric(38,6),
	Type			INT
)

DECLARE @SchemePrd 	TABLE
(
	SalInvNo		nVarChar(100),
	SchId			INT,
	SlabId			INT, 
	PrdId			INT,
	PrdBatId		INT,
	Combi			nVarChar(100)
)

DECLARE @PriScheme	TABLE
(
	SalInvNo		nVarChar(100),
	SchId			INT,
	SlabId			INT, 
	PrdId			INT,
	PrdBatId		INT,
	PriAmt			Numeric(38,6)
)

DECLARE @Claimable	Numeric(38,6)
DECLARE @RefCode	nVarChar(100)

	SELECT @Claimable = Claimable FROM ClaimNormDefinition 
		WHERE CmpID=@Pi_CmpId AND ClmGrpId=@Pi_ClmGroupId

	SET @Claimable = ISNULL(@Claimable,0)

	INSERT INTO @SchMst(SchId,SchCode,SchDesc) 
	SELECT SchId,SchCode,SchDsc
 		FROM SchemeMaster WHERE CmpId = @Pi_CmpId AND
		Claimable = 1 AND ClmRefId = @Pi_ClmGroupId

	IF EXISTS (SELECT Status FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 )
	BEGIN
		SELECT @RefCode = Condition FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 

		INSERT INTO @SchemePrd (SalInvNo,SchId,SlabId,PrdId,PrdBatId,Combi)
		SELECT B.SalInvno,MIN(A.SchId),E.SlabId,A.PrdId,A.PrdBatId,
			CAST(MIN(A.SchId) as nVarChar(15)) + ' - ' + CAST(E.SlabId as nVarChar(15))
			FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			INNER JOIN (SELECT Y.SalInvno,X.SchId,X.PrdId,X.PrdBatId,MIN(SlabId) as SlabId 
				FROM SalesInvoiceSchemeLineWise X 
				INNER JOIN SalesInvoice Y ON X.SalId = Y.SalId 
				INNER JOIN @SchMst Z ON X.SchId = Z.SchId
				WHERE Y.DlvSts in (4,5) AND X.SchClmId in (0,@Pi_ClmId)
				AND Y.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
				GROUP BY Y.SalInvno,X.SchId,X.PrdId,X.PrdBatId) AS E ON
			E.SalInvNo = B.SalInvNo AND E.PrdId = A.PrdId AND E.PrdBatId = A.PrdBatId
			AND E.SchId = A.SchId
			WHERE B.DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId)
			AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.SalInvno,E.SlabId,A.PrdId,A.PrdBatId		

		INSERT INTO  @PriScheme	(SalInvNo,SchId,SlabId,PrdId,PrdBatId,PriAmt)
		SELECT DISTINCT B.SalInvNo,B.SchId,B.SlabId,B.PrdId,B.PrdBatId,
			C.PrdGrossAmount - (C.PrdGrossAmount /(1 +(D.PrdBatDetailValue)/100)) 		
		FROM @SchemePrd B INNER JOIN SalesInvoice A ON A.SalInvNo collate database_default= B.SalInvno collate database_default
			INNER JOIN SalesInvoiceProduct C ON A.SalId = C.SalId
			AND B.PrdId = C.PrdId AND B.PrdBatId = C.PrdBatId
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId 
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
	   		AND E.Slno = D.Slno AND E.RefCode = @RefCode

		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.SalInvno,A.SchId,A.SlabId,ISNULL(SUM(FlatAmount),0) +  ISNULL(SUM(DiscountPerAmount),0),
			0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,1
			FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId)
			AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc

		UPDATE @SchemeDetails SET DiscountAmt = DiscountAmt - (B.PriAmt) FROM 
			@SchemeDetails A INNER JOIN (SELECT SalInvno,SchId,SlabId,SUM(PriAmt) as PriAmt
				FROM @PriScheme GROUP BY SalInvno,SchId,SlabId) B ON
			A.SalInvNo collate database_default= B.SalInvNo collate database_default AND A.SchId = B.SchId AND
			A.SlabId = B.SlabId 

	END
	ELSE
	BEGIN
		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.SalInvno,A.SchId,A.SlabId,ISNULL(SUM(FlatAmount),0) +  ISNULL(SUM(DiscountPerAmount),0),
			0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,1
			FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId)
			AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc
	END
	
	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.SalInvno,A.SchId,A.SlabId,0 as DiscountAmt,ISNULL(SUM(FreeQty * D.PrdBatDetailValue),0),
		0 as GiftAmt,SchCode,SchDesc,1
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId)
		AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc


	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.SalInvno,A.SchId,A.SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(GiftQty * D.PrdBatDetailValue),0),SchCode,SchDesc,1
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId)
		AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc

	IF EXISTS (SELECT Status FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 )
	BEGIN
		SELECT @RefCode = Condition FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 

		DELETE FROM @SchemePrd
		DELETE FROM @PriScheme

		INSERT INTO @SchemePrd (SalInvNo,SchId,SlabId,PrdId,PrdBatId,Combi)
		SELECT B.ReturnCode,MIN(A.SchId),E.SlabId,A.PrdId,A.PrdBatId,
			CAST(MIN(A.SchId) as nVarChar(15)) + ' - ' + CAST(E.SlabId as nVarChar(15))
			FROM ReturnSchemeLineDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId  
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			INNER JOIN (SELECT Y.ReturnCode,X.SchId,X.PrdId,X.PrdBatId,MIN(SlabId) as SlabId 
				FROM ReturnSchemeLineDt X 
				INNER JOIN ReturnHeader Y ON X.ReturnId = Y.ReturnId 
				INNER JOIN @SchMst Z ON X.SchId = Z.SchId
				WHERE Y.Status = 0 AND X.SchClmId in (0,@Pi_ClmId)
				AND Y.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
				GROUP BY Y.ReturnCode,X.SchId,X.PrdId,X.PrdBatId) AS E ON
			E.ReturnCode = B.ReturnCode AND E.PrdId = A.PrdId AND E.PrdBatId = A.PrdBatId
			AND E.SchId = A.SchId
			WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId)
			AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.ReturnCode,E.SlabId,A.PrdId,A.PrdBatId		


		INSERT INTO  @PriScheme	(SalInvNo,SchId,SlabId,PrdId,PrdBatId,PriAmt)
		SELECT DISTINCT B.SalInvNo,B.SchId,B.SlabId,B.PrdId,B.PrdBatId,
			C.PrdActualGross - (C.PrdActualGross /(1 +(D.PrdBatDetailValue)/100)) 		
		FROM @SchemePrd B INNER JOIN ReturnHeader A ON A.ReturnCode collate database_default= B.SalInvno collate database_default
			INNER JOIN ReturnProduct C ON A.ReturnId = C.ReturnId 
			AND B.PrdId = C.PrdId AND B.PrdBatId = C.PrdBatId
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId 
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
	   		AND E.Slno = D.Slno AND E.RefCode = @RefCode

		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.ReturnCode,A.SchId,A.SlabId,((ISNULL(SUM(ReturnFlatAmount),0) + 
			ISNULL(SUM(ReturnDiscountPerAmount),0)))*(-1),0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,1
			FROM ReturnSchemeLineDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId)
			AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc

		UPDATE @SchemeDetails SET DiscountAmt = DiscountAmt - (B.PriAmt) FROM 
			@SchemeDetails A INNER JOIN (SELECT SalInvno,SchId,SlabId,SUM(PriAmt) as PriAmt
				FROM @PriScheme GROUP BY SalInvno,SchId,SlabId) B ON
			A.SalInvNo collate database_default= B.SalInvNo collate database_default AND A.SchId = B.SchId AND
			A.SlabId = B.SlabId 

	END
	ELSE
	BEGIN
		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.ReturnCode,A.SchId,A.SlabId,((ISNULL(SUM(ReturnFlatAmount),0) + 
			ISNULL(SUM(ReturnDiscountPerAmount),0)))*(-1),0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,1
			FROM ReturnSchemeLineDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId)
			AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc
	END
			--select DiscountAmt from @SchemeDetails	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.ReturnCode,A.SchId,A.SlabId,0 as DiscountAmt,
		ISNULL(SUM(ReturnFreeQty * D.PrdBatDetailValue),0)*(-1),0 as GiftAmt,SchCode,SchDesc,1
		FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId)
		AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc
	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.ReturnCode,A.SchId,A.SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(ReturnGiftQty * D.PrdBatDetailValue),0)*(-1),SchCode,SchDesc,1
		FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId)
		AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc
	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.SalInvno,A.SchId,1 as SlabId,ISNULL(SUM(AdjAmt),0),0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,2
		FROM SalesInvoiceWindowDisplay A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId)
		AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.SalInvno,A.SchId,SchCode,SchDesc
	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.ChqDisRefNo,A.TransId,1 as SlaId,ISNULL(SUM(Amount),0),
		0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,3 
		FROM ChequeDisbursalMaster A 
		INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo 
		INNER JOIN @SchMst S ON A.TransId = S.SchId
		WHERE TransType = 1 AND A.ChqDisDate Between @Pi_FromDate AND @Pi_ToDate
		AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY B.ChqDisRefNo,A.TransId,SchCode,SchDesc

-- FOR Point Based Schemes
	DELETE FROM @SchMst
	INSERT INTO @SchMst(SchId,SchCode,SchDesc) 
	SELECT PntRedSchId,PntRedSchCode,[Description]
 		FROM PointRedemptionMaster WHERE CmpId = @Pi_CmpId AND
		Claimable = 1 AND ClmRefId = @Pi_ClmGroupId

	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT A.PntRedRefNo,PntRedSchId,SlabId,ISNULL(SUM(CrAmt),0),0 as FreeAmt,0 As GiftAmt,
		SchCode,SchDesc,4
		FROM PntRetSchemeHD A INNER JOIN PntRetSchemeDt B
		ON A.PntRedRefNo = B.PntRedRefNo
		INNER JOIN @SchMst S ON A.PntRedSchId = S.SchId
		WHERE A.Status = 1 AND A.TransDate Between @Pi_FromDate AND @Pi_ToDate
		AND CrAmt>0 AND B.SchClmId in (0,@Pi_ClmId)
	GROUP BY A.PntRedRefNo,PntRedSchId,SlabId,SchCode,SchDesc

	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT A.PntRedRefNo,PntRedSchId,SlabId,0 as DiscountAmt,ISNULL(SUM(Qty * D.PrdBatDetailValue),0),
		0 as GiftAmt,SchCode,SchDesc,4
		FROM PntRetSchemeDt A INNER JOIN PntRetSchemeHD B ON A.PntRedRefNo = B.PntRedRefNo
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON B.PntRedSchId = S.SchId
		WHERE B.Status = 1 AND B.TransDate Between @Pi_FromDate AND @Pi_ToDate
		AND CrAmt=0 AND A.Type=1 AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY A.PntRedRefNo,PntRedSchId,SlabId,SchCode,SchDesc

	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT A.PntRedRefNo,PntRedSchId,SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(Qty * D.PrdBatDetailValue),0) as GiftAmt,SchCode,SchDesc,4
		FROM PntRetSchemeDt A INNER JOIN PntRetSchemeHD B ON A.PntRedRefNo = B.PntRedRefNo
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON B.PntRedSchId = S.SchId
		WHERE B.Status = 1 AND B.TransDate Between @Pi_FromDate AND @Pi_ToDate
		AND CrAmt=0 AND A.Type=2 AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY A.PntRedRefNo,PntRedSchId,SlabId,SchCode,SchDesc

--For Coupon Scheme
	DELETE FROM @SchMst
	INSERT INTO @SchMst(SchId,SchCode,SchDesc) 
	SELECT B.CouponDenomId,B.CouponDenomRefNo,A.CouponDefDescription
 		FROM CouponDefinitionHd A INNER JOIN CouponDenomHd B ON
		A.CouponDefId = B.CouponDefId WHERE A.CmpId = @Pi_CmpId AND 
		A.CouponDefClaimable = 1 AND A.CouponDefClaimGroupID = @Pi_ClmGroupId

	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT A.CpnRedCode,A.CouponDenomId,B.SlabId,ISNULL(SUM(CrAmt),0),0 as FreeAmt,0 As GiftAmt,
		SchCode,SchDesc,5
		FROM CouponRedHd A INNER JOIN CouponRedOtherDt B
		ON A.CpnRefId = B.CpnRefId
		INNER JOIN @SchMst S ON A.CouponDenomId = S.SchId
		WHERE A.Status = 1 AND A.CpnRedDate Between @Pi_FromDate AND @Pi_ToDate
		AND CrAmt>0 AND B.SchClmId in (0,@Pi_ClmId)
	GROUP BY A.CpnRedCode,A.CouponDenomId,B.SlabId,SchCode,SchDesc

	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.CpnRedCode,B.CouponDenomId,A.SlabId,0 as DiscountAmt,ISNULL(SUM(Qty * D.PrdBatDetailValue),0),
		0 as GiftAmt,SchCode,SchDesc,5
		FROM CouponRedProducts A INNER JOIN CouponRedHd B ON A.CpnRefId = B.CpnRefId
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON B.CouponDenomId = S.SchId
		INNER JOIN Product P ON P.PrdId = A.PrdId AND P.PrdId = C.PrdId AND PrdType <> 4
		WHERE B.Status = 1 AND B.CpnRedDate Between @Pi_FromDate AND @Pi_ToDate
		AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY B.CpnRedCode,B.CouponDenomId,A.SlabId,SchCode,SchDesc

	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.CpnRedCode,B.CouponDenomId,A.SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(Qty * D.PrdBatDetailValue),0) as GiftAmt,SchCode,SchDesc,5
		FROM CouponRedProducts A INNER JOIN CouponRedHd B ON A.CpnRefId = B.CpnRefId
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON B.CouponDenomId = S.SchId
		INNER JOIN Product P ON P.PrdId = A.PrdId AND P.PrdId = C.PrdId AND PrdType =4
		WHERE B.Status = 1 AND B.CpnRedDate Between @Pi_FromDate AND @Pi_ToDate
		AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY B.CpnRedCode,B.CouponDenomId,A.SlabId,SchCode,SchDesc

	DELETE FROM TempSchemeClaimDetails WHERE Usrid = @Pi_UsrId AND TransID = @Pi_TransId

--	INSERT INTO TempSchemeClaimDetails (SalInvNo,SchId,SchCode,SchDesc,SlabId,Selected,DiscountAmt,
--		FreeAmt,GiftAmt,TotSpent,Claimable,ClaimableAmt,RecomAmount,RecAmount,DBCRSelection,
--		StatusDesc,Type,Usrid,TransID)
--	SELECT SalInvNo,SchId,SchCode,SchDesc,SlabId,0 as Selected,
--		Convert(Numeric(38,2),Sum(DiscountAmt)) ,
--		Convert(Numeric(38,2),sum(FreeAmt)) ,
--		Convert(Numeric(38,2),Sum(GiftAmt)), 
--		Convert(Numeric(38,2),Sum((DiscountAmt + FreeAmt + GiftAmt))) ,
--		ISNULL(@Claimable,0) , 0.00 , 0 , 0  , 0 ,'Cancelled', Type, @Pi_UsrId,@Pi_TransId
--		FROM @SchemeDetails
--	GROUP BY SalInvNo,SchId,SchCode,SchDesc,SlabId,Type

	INSERT INTO TempSchemeClaimDetails (SalInvNo,SchId,SchCode,CmpSchCode,SchDesc,SlabId,Selected,DiscountAmt,
		FreeAmt,GiftAmt,TotSpent,Claimable,ClaimableAmt,RecomAmount,RecAmount,DBCRSelection,
		StatusDesc,Type,Usrid,TransID)
	SELECT SD.SalInvNo,SD.SchId,SD.SchCode,SM.CmpSchCode,SD.SchDesc,SD.SlabId,0 as Selected,
		Convert(Numeric(38,2),Sum(DiscountAmt)) ,
		Convert(Numeric(38,2),sum(FreeAmt)) ,
		Convert(Numeric(38,2),Sum(GiftAmt)), 
		Convert(Numeric(38,2),Sum((DiscountAmt + FreeAmt + GiftAmt))) ,
		ISNULL(@Claimable,0) , 0.00 , 0 , 0  , 0 ,'Cancelled', Type, @Pi_UsrId,@Pi_TransId
		FROM @SchemeDetails SD,SchemeMaster SM
	WHERE SD.SchId=SM.SchId 
	GROUP BY SD.SalInvNo,SD.SchId,SD.SchCode,SM.CmpSchCode,SD.SchDesc,SD.SlabId,Type	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-171-016

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptClaimReportAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptClaimReportAll]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Proc_RptClaimReportAll]
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT
)
AS
SET NOCOUNT ON
BEGIN
	DELETE FROM RptClaimReportAll WHERE UsrId = @Pi_UsrId

	INSERT INTO RptClaimReportAll (CmpId,RefNo,ClaimDate,ClaimId,ClaimCode,ClaimDesc,ClaimGrpId,ClaimGrpName,
	TotalSpent,ClaimPercentage,ClaimAmount,RecommendedAmount,ReceivedAmount,PendingAmount,Status,UsrId,StatusId)
	SELECT CM.CmpId,CD.RefCode,CM.ClmDate,CM.ClmId,CM.ClmCode,CM.ClmDesc,CM.ClmGrpId,CG.ClmGrpName,CD.TotalSpent,CD.ClmPercentage,
	CD.ClmAmount,CD.RecommendedAmount,CD.ReceivedAmount,CD.RecommendedAmount - CD.ReceivedAmount PendingAmount,
	Case CD.Status When 1 Then 'Pending' When 2 Then 'Settled' When 3 Then 'Rejected' When 4 Then 'Cancelled' End Status,
	@Pi_UsrId,CD.Status AS StatusId
	FROM ClaimSheetHD CM
	LEFT OUTER JOIN ClaimSheetDetail CD ON CM.ClmId = CD.ClmId
	LEFT OUTER JOIN ClaimGroupMaster CG ON CM.ClmGrpId = CG.ClmGrpId
	WHERE CM.[Confirm] = 1 AND CG.ClmGrpId<17 OR CG.ClmGrpId>10000

	UNION 

	SELECT CM.CmpId,(CASE LEN(ISNULL(SM.CmpSchCode,'')) WHEN 0 THEN SM.SchDsc ELSE ISNULL(SM.CmpSchCode,'')+' - '+SM.CmpSchCode END) AS RefCode,CM.ClmDate,CM.ClmId,CM.ClmCode,CM.ClmDesc,CM.ClmGrpId,CG.ClmGrpName,CD.TotalSpent,CD.ClmPercentage,
	CD.ClmAmount,CD.RecommendedAmount,CD.ReceivedAmount,CD.RecommendedAmount - CD.ReceivedAmount PendingAmount,
	Case CD.Status When 1 Then 'Pending' When 2 Then 'Settled' When 3 Then 'Rejected' When 4 Then 'Cancelled' End Status,
	@Pi_UsrId,CD.Status AS StatusId
	FROM ClaimSheetHD CM
	LEFT OUTER JOIN ClaimSheetDetail CD ON CM.ClmId = CD.ClmId
	LEFT OUTER JOIN ClaimGroupMaster CG ON CM.ClmGrpId = CG.ClmGrpId
	INNER JOIN SchemeMaster SM ON CD.RefCode=SM.SchCode
	WHERE CM.[Confirm] = 1 AND CG.ClmGrpId BETWEEN 17 AND 10000

END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-171-017

DELETE FROM AutoBackupConfiguration WHERE ModuleId IN ('AUTOBACKUP2','AUTOBACKUP3')

INSERT INTO AutoBackupConfiguration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES('AUTOBACKUP2','AutomaticBackup','Take Backup/Extract Log while Logging on to the application',0,'',0.00,GETDATE(),2)

INSERT INTO AutoBackupConfiguration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,BackupDate,SeqNo) 
VALUES('AUTOBACKUP3','AutomaticBackup','Take Backup/Extract Log while Logging out of the application',1,'',0.00,GETDATE(),3)

--SRF-Nanda-171-018

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_CollectionValues]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_CollectionValues]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_CollectionValues 2

CREATE PROCEDURE [dbo].[Proc_CollectionValues]
(
  	@Pi_TypeId INT
)
/**********************************************************************************
* PROCEDURE		: Proc_CollectionValues
* PURPOSE		: To Display the Collection details
* CREATED		: MarySubashini.S
* CREATED DATE	: 01/06/2007
* NOTE			: General SP for Returning the Collection details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-----------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}
* 01-09-2009	Thiruvengadam.L		CR changes
* 08-12-2009	Thiruvengadam.L		Cheque and DD are displayed in single column	
************************************************************************************/
AS
BEGIN	
SET NOCOUNT ON

	DECLARE @SalId AS BIGINT
	DECLARE @InvRcpDate AS DATETIME
	DECLARE @CrAdjAmount AS NUMERIC (38, 6)
	DECLARE @DbAdjAmount AS NUMERIC (38, 6)
	DECLARE @SalNetAmt AS NUMERIC (38, 6)
	DECLARE @CollectedAmount AS NUMERIC (38, 6)
	DECLARE @Count AS INT 
	DECLARE @Prevamount AS NUMERIC (38, 6)
	DECLARE @CurPrevamount AS NUMERIC (38, 6)
	DECLARE @PrevSalId AS BIGINT
	DELETE FROM RptCollectionValue	
	
	INSERT INTO RptCollectionValue (SalId ,SalInvDate,SalInvNo,SalInvRef,
				SMId ,SMName,InvRcpDate,RtrId ,
				RtrName ,RMId ,RMName ,DlvRMId ,
				DelRMName ,BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
				CollectedAmount,PayAmount,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,InvRcpNo)
	SELECT SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,
	 InvRcpDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,
	 SalNetAmt AS BillAmount,
	 SUM(CrAdjAmount) AS CrAdjAmount,SUM(DbAdjAmount) AS DbAdjAmount,
	 SUM(CashDiscount) AS CashDiscount,
	 SUM(CollectedAmount) AS CollectedAmount,
	 SUM(PayAmount) AS PayAmount, SUM(PayAmount) AS CurPayAmount,
	 SUM(CollCashAmt) AS CollCashAmt,SUM(CollChqAmt) AS CollChqAmt,SUM(CollDDAmt) AS CollDDAmt,SUM(CollRTGSAmt) AS CollRTGSAmt,InvRcpNo
	FROM(
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
		SUM(RI.SalInvAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId 
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (1) --AND RI.InvInsSta NOT IN(4,@Pi_TypeId)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo
		UNION
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				SUM(RI.DebitAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (1) AND RE.RcpType=1 
			GROUP BY 
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
		    SUM(RI.SalInvAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId 
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (3) AND RI.InvInsSta NOT IN(4,@Pi_TypeId)
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo

		UNION 
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,SUM(RI.DebitAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (3) AND RI.InvInsSta NOT IN(4,@Pi_TypeId)
					AND RE.RcpType=1
			GROUP BY 
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo

	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    SUM(RI.SalInvAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId 
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (4) 
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo

		UNION 
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,SUM(RI.DebitAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (4) AND RE.RcpType=1
			GROUP BY 
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    0 AS CollDDAmt,SUM(RI.SalInvAmt) AS  CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		    Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId 
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
			AND RI.InvRcpMode IN (8) 
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo

		UNION 
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,SUM(RI.DebitAmt)AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,SUM(RI.DebitAmt) AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (8) AND RE.RcpType=1
			GROUP BY 
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			SUM(RI.SalInvAmt) AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		        Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId 
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=5 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo

		UNION 
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				SUM(RI.DebitAmt) AS CrAdjAmount,
				0 AS DbAdjAmount,0 AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (5) AND RE.RcpType=1
			GROUP BY 
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo
	UNION 
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			SUM(RI.SalInvAmt) AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		        Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId 
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=6 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpMode,RI.InvRcpNo
	UNION 
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,SUM(RI.SalInvAmt) AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  	FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		        Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			SalesInvoice SI WITH (NOLOCK)
	  	WHERE SI.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId 
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo AND RI.InvRcpMode=2 AND RI.CancelStatus=1
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpNo

		UNION 
		SELECT 0 AS SalId,SI.DbNoteDate,SI.DbNoteNumber,'' AS SalInvRef,0 AS SMId,'' AS SMName,
				RE.InvRcpDate,SI.RtrId,R.RtrName,0 AS RMId,'' AS RMName,0 AS DlvRMId,''  AS DelRMName,
				0 AS CrAdjAmount,
				0 AS DbAdjAmount,SUM(RI.DebitAmt) AS CashDiscount,
				SI.Amount,0 AS CollectedAmount,0 AS PayAmount,
				0 AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
	  		FROM	
					DebitInvoice RI WITH (NOLOCK),
					Receipt RE WITH (NOLOCK),
					Retailer R WITH (NOLOCK),
					DebitNoteRetailer SI WITH (NOLOCK)
	  		WHERE	
					SI.RtrId=R.RtrId AND RI.DbNoteNumber=SI.DbNoteNumber  AND RE.InvRcpNo=RI.InvRcpNo AND RI.CancelStatus=1
					AND RI.InvRcpMode IN (2) AND RE.RcpType=1
			GROUP BY 
				 SI.DbNoteDate,SI.DbNoteNumber,RE.InvRcpDate,SI.RtrId,R.RtrName,SI.AMount,RI.InvRcpNo

--->Commented By Nanda to Remove On Account(Need to check thoroughly on Exccess Collections)
--	UNION
--		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
--			RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,
--			RMD.RMName as DelRMName,0 AS CrAdjAmount,0 AS DbAdjAmount,
--			0 AS CashDiscount,0 AS SalNetAmt,
--			ISNULL(ROA.Amount,0) AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
--			0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo
--		FROM ReceiptInvoice RI WITH (NOLOCK),
--			Receipt RE WITH (NOLOCK),
--			Retailer R WITH (NOLOCK),
--		        Salesman SM WITH (NOLOCK),
--			RouteMaster RM WITH (NOLOCK),
--			RouteMaster RMD WITH (NOLOCK),
--			RetailerOnAccount ROA WITH (NOLOCK), 
--			SalesInvoice SI WITH (NOLOCK)
--		WHERE ROA.RtrId=R.RtrId AND SI.SMId=SM.SMId
--		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId 
--			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo
--			AND ROA.LastModDate=RE.InvRcpDate
--			AND ROA.TransactionType=0 AND ROA.OnAccType=0 AND ROA.RtrId=SI.RtrId
--		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
--		 RE.InvRcpDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
--		 ROA.Amount,RI.InvRcpNo
--->Till Here
			) A
	GROUP BY SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,
	 	InvRcpDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,SalNetAmt,InvRcpNo 
	IF NOT EXISTS (SELECT SalId FROM RptCollectionValue WHERE SalId<>0)
	BEGIN
		UPDATE RptCollectionValue SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalId,A.InvRcpDate,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue A
			LEFT OUTER JOIN RptCollectionValue B ON A.SalId=B.SalId AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalId,A.InvRcpDate) A WHERE A.SalId=RptCollectionValue.SalId
			AND A.InvRcpDate=RptCollectionValue.InvRcpDate AND BillAmount>0
	END
	ELSE
	BEGIN
		UPDATE RptCollectionValue SET PayAmount=A.PayAmount
			FROM (
			SELECT A.SalInvNo,A.InvRcpDate,ISNULL(SUM(B.CollectedAmount+B.CashDiscount+B.CrAdjAmount-B.DbAdjAmount),0) AS PayAmount
			FROM RptCollectionValue A
			LEFT OUTER JOIN RptCollectionValue B ON A.SalInvNo=B.SalInvNo AND B.InvRcpDate<=A.InvRcpDate
			AND  ISNULL(A.BillAmount,0)>0 AND ISNULL(B.BillAmount,0)>0
			GROUP BY A.SalInvNo,A.InvRcpDate) A WHERE A.SalInvNo=RptCollectionValue.SalInvNo
			AND A.InvRcpDate=RptCollectionValue.InvRcpDate AND BillAmount>0
	END
	
--	UPDATE RptCollectionValue SET CurPayAmount=ABS(CollectedAmount+CashDiscount+CrAdjAmount-DbAdjAmount-PayAmount) WHERE BillAmount>0
	UPDATE RptCollectionValue SET CurPayAmount=ABS(CollCashAmt+CollChqAmt+CollDDAmt+CollRTGSAmt+CashDiscount+CrAdjAmount-DbAdjAmount) WHERE BillAmount>0

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-171-019

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_Scheme]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_Scheme]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM DayEndProcess	WHERE ProcId = 12
--UPDATE DayEndProcess SET NextUpDate='2009-12-28' WHERE ProcId = 12
--DELETE FROM  Cs2Cn_Prk_ClaimAll
EXEC Proc_Cs2Cn_Claim_Scheme
SELECT * FROM Cs2Cn_Prk_ClaimAll
ROLLBACK TRANSACTION
*/
CREATE       PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Scheme]
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE	: Proc_Cs2Cn_Claim_Scheme
* PURPOSE		: Extract Scheme Claim Details from CoreStocky to Console
* NOTES:
* CREATED		: Mahalakshmi.A  19-08-2008
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
------------------------------------------------
* 13/11/2009 Nandakumar R.G    Added WDS Claim
*********************************/
BEGIN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As NVARCHAR(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType IN('Scheme Claim','Window Display Claim')

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())
	INSERT INTO Cs2Cn_Prk_ClaimAll
	(
		DistCode,CmpName,ClaimType,ClaimMonth,ClaimYear,ClaimRefNo,ClaimDate,ClaimFromDate,ClaimToDate,DistributorClaim,
		DistributorRecommended,ClaimnormPerc,SuggestedClaim,TotalClaimAmt,Remarks,Description,Amount1,ProductCode,Batch,
		Quantity1,Quantity2,Amount2,Amount3,TotalAmount,SchemeCode,BillNo,BillDate,RetailerCode,RetailerName,
		TotalSalesInValue,PromotedSalesinValue,OID,Discount,FromStockType,ToStockType,Remark2,Remark3,PrdCode1,
		PrdCode2,PrdName1,PrdName2,Date2,UploadFlag		
	)
	SELECT 	@DistCode,CM.CmpName,'Scheme Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,CH.FromDate,CH.ToDate,
	(SELECT  dbo.Fn_ReturnBudgetUtilized (SM.SchId))AS DistAmount,CD.RecommendedAmount,CD.ClmPercentage,CD.ClmAmount,CD.RecommendedAmount AS TotAmt,
	'',SM.SchDsc,(CASE SM.SchType WHEN 2 THEN SL.PurQty ELSE 0 END) AS SchemeOnAmt,ISNULL(P.PrdDCode,'') AS PrdDCode,
	ISNULL(P.PrdName,'') AS PrdName,(CASE SM.SchType WHEN 1 THEN CAST(SL.PurQty AS INT) ELSE 0 END) AS SchemeOnQty,
	ISNULL(SF.FreeQty,0) As SchemeQty,CD.FreePrdVal+GiftPrdVal as FGQtyValue,Cd.Discount AS SchemeAmt,
	(CD.FreePrdVal+GiftPrdVal+CD.Discount)AS Amount,SM.CmpSchCode,'',GETDATE(),'','',0,0,0,0,'','','','','','','','',GETDATE(),'N'
	FROM SchemeMaster SM
	INNER JOIN SchemeSlabs SL ON SM.SchId=SL.SchId
	INNER JOIN ClaimSheetDetail CD ON CD.RefCode=SM.SchCode
	INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16
	INNER JOIN Company CM ON CM.CmpId=CH.CmpId	
	LEFT OUTER JOIN SchemeSlabFrePrds SF ON SM.SchId=SF.SchId
	LEFT OUTER JOIN Product P ON SF.PrdId=P.PrdId
	WHERE CH.Confirm=1 AND CH.Upload='N'

	UNION	
	--SELECT 	@DistCode,CM.CmpName,'Window Display Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,
	SELECT 	@DistCode,CM.CmpName,'Scheme Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,	
	CH.FromDate,CH.ToDate,
	(SELECT  dbo.Fn_ReturnBudgetUtilized (SM.SchId))AS DistAmount,CD.RecommendedAmount,CD.ClmPercentage,SUM(CD.ClmAmount),SUM(CD.RecommendedAmount) AS TotAmt,
	'',SM.SchDsc,0 AS SchemeOnAmt,'WDS' AS PrdDCode,'Window Display Claim' AS PrdName,0 AS SchemeOnQty,
	0 As SchemeQty,AdjAmt,SUM(Cd.Discount) AS SchemeAmt,
	SUM(CD.Discount)AS Amount,SM.CmpSchCode,'',GETDATE(),R.RtrCode,R.RtrName,0,0,0,0,'','','','','','','','',GETDATE(),'N'
	FROM SchemeMaster SM
	INNER JOIN ClaimSheetDetail CD ON CD.RefCode=SM.SchCode
	INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16
	INNER JOIN Company CM ON CM.CmpId=CH.CmpId
	INNER JOIN SalesInvoiceWindowDisplay SIW ON SIW.SchId=SM.SchId AND CH.ClmId=SIW.SchClmId
	INNER JOIN SalesInvoice SI ON SI.SalId=SIW.SalId 	
	INNER JOIN Retailer R ON SI.RtrId=R.RtrId 	
	WHERE CH.Confirm=1 AND SM.SchType=4 AND CH.Upload='N'
	GROUP BY CM.CmpName,CH.ClmDate,CH.ClmCode,SM.CmpSchCode,CH.ClmDate,CH.FromDate,CH.ToDate,
	SM.SchId,CD.RecommendedAmount,CD.ClmPercentage,SM.SchDsc,AdjAmt,
	R.RtrCode,R.RtrName

	--->Added By Nanda on 13/10/2010 for Claim Details
	DELETE FROM Cs2Cn_Prk_Claim_SchemeDetails WHERE UploadFlag='Y'

	INSERT INTO Cs2Cn_Prk_Claim_SchemeDetails(DistCode,ClaimRefNo,CmpSchCode,SlabId,SalInvNo,PrdCCode,BilledQty,ClaimAmount,UploadFlag)
	SELECT DISTINCT @DistCode,CH.ClmCode,SM.CmpSchCode,SISL.SlabId,SI.SalInvNo,P.PrdCCode,SUM(SIP.BaseQty),SUM(SISL.FlatAmount+SISL.DiscountPerAmount),'N'
	FROM ClaimSheetHd CH,ClaimSheetDetail CD,SalesInvoiceSchemeLinewise SISL,SchemeMaster SM,
	SalesInvoice SI,Product P,SalesInvoiceProduct SIP
	WHERE CH.ClmId=CD.ClmId AND CH.Upload='N' AND CD.RefCode=SM.SchCode AND
	SISL.SchClmId=CD.ClmId AND SISL.SchId=SM.SchId AND SISL.SalId=Si.SalId AND SISl.PrdId=P.PrdId
	AND SISL.RowId =SIP.SlNo AND SISL.SalId=SIP.SalId AND SI.SalId = SIP.SalId 
	GROUP BY CH.ClmCode,SM.CmpSchCode,SISL.SlabId,SI.SalInvNo,P.PrdCCode
	HAVING SUM(SISL.FlatAmount+SISL.DiscountPerAmount)>0

	UNION

	SELECT DISTINCT @DistCode,CH.ClmCode,SM.CmpSchCode,SISF.SlabId,SI.SalInvNo,'Free Product' AS PrdCCode,
	0 AS BaseQty,SUM(SISF.FreeQty*PBD.PrdBatDetailValue),'N'
	FROM ClaimSheetHd CH,ClaimSheetDetail CD,SalesInvoiceSchemeDtFreePrd SISF,SchemeMaster SM,
	SalesInvoice SI,ProductBatchDetails PBD,BatchCreation BC
	WHERE CH.ClmId=CD.ClmId AND CH.Upload='N' AND CD.RefCode=SM.SchCode AND CD.SelectMode=1 AND
	SISF.SchClmId=CD.ClmId AND SISF.SchId=SM.SchId AND SISF.SalId=Si.SalId 
	AND SISF.FreePrdBatId =PBD.PrdBatId AND SISf.FreePriceId=PBD.PriceId AND PBD.SlNo=BC.SlNo AND BC.ClmRte=1 AND
	PBD.BatchSeqId=BC.BatchSeqId
	GROUP BY CH.ClmCode,SM.CmpSchCode,SISF.SlabId,SI.SalInvNo
	
	UNION

	SELECT DISTINCT @DistCode,CH.ClmCode,SM.CmpSchCode,0 AS SlabId,SI.SalInvNo,'Window Display' AS PrdCCode,
	0 AS BaseQty,SUM(SIW.AdjAmt),'N'
	FROM ClaimSheetHd CH,ClaimSheetDetail CD,SalesInvoiceWindowDisplay SIW,SchemeMaster SM,
	SalesInvoice SI
	WHERE CH.ClmId=CD.ClmId AND CH.Upload='N' AND CD.RefCode=SM.SchCode AND CD.SelectMode=1 AND
	SIW.SchClmId=CD.ClmId AND SIW.SchId=SM.SchId AND SIW.SalId=Si.SalId 	
	GROUP BY CH.ClmCode,SM.CmpSchCode,SI.SalInvNo
	--->Till Here

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-171-020

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptDistributionWidth]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptDistributionWidth]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC Proc_RptDistributionWidth 58,2,0,'TEST',0,0,1,0
--SELECT * FROM RptTempDistWidth
CREATE             PROCEDURE [dbo].[Proc_RptDistributionWidth]
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT,
	@Po_Errno		INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_RptDistributionWidth
* PURPOSE	: To get the distribution width
* CREATED	: Nandakumar R.G
* CREATED DATE	: 14/12/2007
* MODIFIED	:
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @sSql		AS 	nVarChar(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	--Filter Variable
	DECLARE @CmpId	        	AS	Int
	DECLARE @SMId		        AS	Int
	DECLARE @RMId		        AS	Int
	DECLARE @CtgLevelId		AS	Int
	DECLARE @CtgMainId		AS	Int
	DECLARE @ValueClassId		AS	Int
	DECLARE @fPrdCatPrdId      	AS	Int
	DECLARE @fPrdId  	    	AS	Int
	DECLARE @BasedOn  	    	AS	Int
	DECLARE @FromDate  	    	AS	DateTime
	DECLARE @ToDate  	    	AS	DateTime
	DECLARE @RtrCount		AS	NUMERIC(38,2)
	DECLARE @BilledRtrCount		AS	NUMERIC(38,2)
	--Till Here
	--Assgin Value for the Filter Variable
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @SMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @CtgLevelId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @CtgMainId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @ValueClassId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @BasedOn = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,75,@Pi_UsrId))
	
	--If Product Category Filter is available
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	--Till Here
	
	DELETE FROM RptTempDistWidth WHERE UserId=@Pi_UsrId
	EXEC Proc_RptTempDistributionWidth @FromDate,@ToDate,@Pi_UsrId
	
	Create TABLE #RptDistributionWidth
	(
		SMId		INT,
		SMName		NVARCHAR(50),
		RMId		INT,
		RMName		NVARCHAR(50),
		RtrId		INT,
		RtrCode		NVARCHAR(50),
		RtrName		NVARCHAR(50),
		SalQty 		NUMERIC(38,0),
		Width		NUMERIC(38,2),
		BasedOn		INT,
		RtrCount	NUMERIC(38,2),
		BilledRtrCount	NUMERIC(38,2)
	)
	
	SET @TblName = 'RptDistributionWidth'
	SET @TblStruct = 'SMId		INT,
			 SMName		NVARCHAR(50),
			 RMId		INT,
			 RMName		NVARCHAR(50),
			 RtrId		INT,
			 RtrCode	NVARCHAR(50),
			 RtrName	NVARCHAR(50),
			 SalQty		NUMERIC(38,0),
			 Width		NUMERIC(38,2),
			 BasedOn	INT,
			 RtrCount	NUMERIC(38,2),
			 BilledRtrCount	NUMERIC(38,2)'
	
	SET @TblFields = 'SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName,SalQty,Width,BasedOn,RtrCount,BilledRtrCount'
	
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
	IF @Pi_GetFromSnap <> 1		--To Generate For New Report Data
	BEGIN
		INSERT INTO #RptDistributionWidth (SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName,SalQty,
		Width,BasedOn,RtrCount,BilledRtrCount)
		SELECT RDW.SMId,SMName,RDW.RMId,RMName,RDW.RtrId,RtrCode,RtrName,SUM(SalQty),0 AS Width,@BasedOn,0,0
		FROM RptTempDistWidth RDW,SalesMan SM,RouteMaster RM,Retailer R
		WHERE RDW.SMid=SM.SMId AND RDW.RMId=RM.RMId AND RDW.RtrId=R.RtrId AND
		(RDW.CmpId=  (CASE @CmpId WHEN 0 THEN RDW.CmpId ELSE 0 END ) OR
		RDW.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	
		AND   (RDW.SMId=  (CASE @SMId WHEN 0 THEN RDW.SMId ELSE 0 END ) OR
		RDW.SMId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		AND   (RDW.RMId=  (CASE @RMId WHEN 0 THEN RDW.RMId ELSE 0 END ) OR
		RDW.RMId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
	
		AND   (CtgLevelId=  (CASE @CtgLevelId WHEN 0 THEN CtgLevelId ELSE 0 END ) OR
		CtgLevelId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
	
		AND   (CtgMainId=  (CASE @CtgMainId WHEN 0 THEN CtgMainId ELSE 0 END ) OR
		CtgMainId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
	
		AND   (RtrClassId=  (CASE @ValueClassId WHEN 0 THEN RtrClassId ELSE 0 END ) OR
		RtrClassId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
	
		AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
			PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
	
		AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
			PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		AND UserId=@Pi_UsrId
	
		GROUP BY RDW.SMId,SMName,RDW.RMId,RMName,RDW.RtrId,RtrCode,RtrName
	
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptDistributionWidth (' + @TblFields + ')' +
			' SELECT SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName,SUM(SalQty),0 AS Width,'+
			CAST(@BasedOn AS NVARCHAR(10))+',0,0 FROM ['  + @PurDBName + '].dbo.' + @TblName
	
			+'WHERE (CmpId=  (CASE'+CAST(@CmpId AS NVARCHAR(10))+' WHEN 0 THEN CmpId ELSE 0 END ) OR
			CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+
			',4,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))	
		
			AND   (SMId=  (CASE'+CAST(@SMId AS NVARCHAR(10))+' WHEN 0 THEN SMId ELSE 0 END ) OR
			SMId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+
			',1,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))		
		
			AND   (RMId=  (CASE'+CAST(@RMId AS NVARCHAR(10))+' WHEN 0 THEN RMId ELSE 0 END ) OR
			RMId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+
			',2,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
		
			AND   (CtgLevelId=  (CASE'+CAST(@CtgLevelId AS NVARCHAR(10))+' WHEN 0 THEN CtgLevelId ELSE 0 END ) OR
			CtgLevelId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+
			',29,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
		
			AND   (CtgMainId=  (CASE'+CAST(@CtgLevelId AS NVARCHAR(10))+' WHEN 0 THEN CtgMainId ELSE 0 END ) OR
			CtgMainId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+
			',30,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
		
			AND   (RtrValueClassId=  (CASE'+CAST(@ValueClassId AS NVARCHAR(10))+' WHEN 0 THEN RtrValueClassId ELSE 0 END ) OR
			RtrValueClassId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+
			',31,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
		
			AND   (PrdId = (CASE'+CAST(@fPrdCatPrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+
			',26,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
		
			AND   (PrdId = (CASE'+CAST(@fPrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+
			',5,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
		
			GROUP BY SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName'
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptDistributionWidth'
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		   END
	END
	ELSE IF @Pi_GetFromSnap = 1 	--To Retrieve Data From Snap Data
	BEGIN
		PRINT @Pi_DbName
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		   BEGIN
			SET @SSQL = 'INSERT INTO #RptDistributionWidth ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
				' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
				' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
				' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))
			PRINT @SSQL
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
	SELECT @RtrCount=COUNT(DISTINCT RtrId) FROM RetailerMarket
	WHERE RMId IN (SELECT DISTINCT RMId FROM #RptDistributionWidth)
	SELECT @BilledRtrCount=COUNT(*) FROM #RptDistributionWidth
	UPDATE #RptDistributionWidth SET RtrCount=@RtrCount,BilledRtrCount=@BilledRtrCount
	
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptDistributionWidth

	SELECT * FROM #RptDistributionWidth

	--->Added By Nanda on 18/11/2010
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptDistributionWidth_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptDistributionWidth_Excel]
		SELECT SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName,SalQty,Width,BasedOn,RtrCount,BilledRtrCount
		INTO RptDistributionWidth_Excel FROM #RptDistributionWidth

		UPDATE A SET A.Width=(A.SalQty/B.SumQty)*100
		FROM RptDistributionWidth_Excel A,
		(
			SELECT SUM(SalQty) AS SumQty FROM RptDistributionWidth_Excel 
		)B
    END	
	--->Till Here

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-171-021

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptRetailerWiseVatTax]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptRetailerWiseVatTax]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
-- EXEC [Proc_RptRetailerWiseVatTax] 26,1,0,'Nestle060809',0,0,1  

CREATE PROCEDURE [dbo].[Proc_RptRetailerWiseVatTax]  
(  
 @Pi_RptId  INT,  
 @Pi_UsrId  INT,  
 @Pi_SnapId  INT,  
 @Pi_DbName  NVARCHAR(50),  
 @Pi_SnapRequired INT,  
 @Pi_GetFromSnap  INT,  
 @Pi_CurrencyId  INT  
-- @Po_Errno  INT OUTPUT  
)  
AS  
SET NOCOUNT ON  
/*******************************************************************************************************  
* PROCEDURE: Proc_RptRetailerWiseVatTax  
* PURPOSE: General Procedure  
* NOTES:  
* CREATED: MarySubashini.S 07-08-2007  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
--------------------------------------------------------------------------------------------------------  
**********************************************************************************************************/  
BEGIN 
	DECLARE @NewSnapId  AS INT  
	DECLARE @DBNAME  AS  nvarchar(50)  
	DECLARE @TblName  AS nvarchar(500)  
	DECLARE @TblStruct  AS nVarchar(4000)  
	DECLARE @TblFields  AS nVarchar(4000)  
	DECLARE @sSql  AS  nVarChar(4000)  
	DECLARE @ErrNo   AS INT  
	DECLARE @PurDBName AS nVarChar(50)  
	DECLARE @FromDate  AS DATETIME  
	DECLARE @ToDate   AS DATETIME  
	DECLARE @CmpId   AS INT  
	DECLARE @SMId   AS INT  
	DECLARE @RMId   AS INT  
	DECLARE @TypeId   AS INT  
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))  
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))  
	SET @TypeId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,196,@Pi_UsrId))  
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
	--If Product Category Filter is available  
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  
	--Till Here  

	Create TABLE #RptRetailerWiseVatTax  
	(  
		CmpId   INT,  
		SMId   INT,  
		RMId   INT,  
		RtrId   INT,  
		RtrName   NVARCHAR(100),  
		TINNumber  NVARCHAR(50),  
		PrdId   INT,  
		PrdName   NVARCHAR(200),  
		Quantity                INT,  
		GrossAmount  NUMERIC (38,6),  
		INTax   NUMERIC(38,6),  
		OutTax   NUMERIC(38,6),  
		INTaxableAmount  NUMERIC (38,6),  
		INTaxAmount  NUMERIC (38,6),  
		OutTaxableAmount NUMERIC (38,6),  
		OutTaxAmount  NUMERIC (38,6),  
		TaxType   INT  
	)  
	SET @TblName = 'RptRetailerWiseVatTax'  
	SET @TblStruct = ' CmpId   INT,  
						SMId   INT,  
						RMId   INT,  
						RtrId   INT,  
						RtrName   NVARCHAR(100),  
						TINNumber  NVARCHAR(50),  
						PrdId   INT,  
						PrdName   NVARCHAR(200),  
						Quantity                INT,  
						GrossAmount  NUMERIC (38,6),  
						INTax   NUMERIC(38,6),  
						OutTax   NUMERIC(38,6),  
						INTaxableAmount  NUMERIC (38,6),  
						INTaxAmount  NUMERIC (38,6),  
						OutTaxableAmount NUMERIC (38,6),  
						OutTaxAmount  NUMERIC (38,6),  
						TaxType   INT'  
	SET @TblFields = 'CmpId,SMId,RMId,RtrId,RtrName,TINNumber,PrdId,PrdName,Quantity,GrossAmount,  
	INTax,OutTax,INTaxableAmount,INTaxAmount,OutTaxableAmount,OutTaxAmount,TaxType'  
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

	--SET @Po_Errno = 0  
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
		EXEC Proc_RetailerWiseVatTax @Pi_UsrId  
		IF @TypeId=1  
		BEGIN  
			INSERT INTO #RptRetailerWiseVatTax (CmpId,SMId,RMId,RtrId,RtrName,  
			TINNumber,PrdId,PrdName,Quantity,GrossAmount,  
			INTax,OutTax,INTaxableAmount,INTaxAmount,OutTaxableAmount,OutTaxAmount,TaxType)  

			SELECT  CmpId,SMId,RMId,RtrId,RtrName,TINNumber,PrdId,PrdName,SUM(Quantity)AS Quantity,  
			dbo.Fn_ConvertCurrency(SUM(GrossAmount),@Pi_CurrencyId),INTax,OutTax,  
			dbo.Fn_ConvertCurrency(SUM(INTaxableAmount),@Pi_CurrencyId),dbo.Fn_ConvertCurrency(Sum(INTaxAmount),@Pi_CurrencyId),  
			dbo.Fn_ConvertCurrency(SUM(OutTaxableAmount),@Pi_CurrencyId),dbo.Fn_ConvertCurrency(Sum(OutTaxAmount),@Pi_CurrencyId),  
			ISNULL(@TypeId,1)  
			FROM TmpRetailerWiseVatTax  
			WHERE  (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR  
			CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))        AND  
			(SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
			SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
			AND  
			(RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
			RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
			AND InvDate BETWEEN @FromDate AND @ToDate  
			AND IOTaxType='Sales'  
			Group By CmpId,SMId,RMId,RtrId,RtrName,  
			TINNumber,PrdId,PrdName,INTax,OutTax  
		END  
		ELSE  
		BEGIN  
			INSERT INTO #RptRetailerWiseVatTax (CmpId,SMId,RMId,RtrId,RtrName,  
			TINNumber,PrdId,PrdName,Quantity,GrossAmount,  
			INTax,OutTax,INTaxableAmount,INTaxAmount,OutTaxableAmount,OutTaxAmount,TaxType)  

			SELECT  CmpId,SMId,RMId,RtrId,RtrName,TINNumber,PrdId,PrdName,SUM(Quantity)AS Quantity,  
			dbo.Fn_ConvertCurrency(SUM(GrossAmount),@Pi_CurrencyId),INTax,OutTax,  
			dbo.Fn_ConvertCurrency(SUM(INTaxableAmount),@Pi_CurrencyId),dbo.Fn_ConvertCurrency(Sum(INTaxAmount),@Pi_CurrencyId),  
			dbo.Fn_ConvertCurrency(SUM(OutTaxableAmount),@Pi_CurrencyId),dbo.Fn_ConvertCurrency(Sum(OutTaxAmount),@Pi_CurrencyId),  
			ISNULL(@TypeId,1)  
			FROM TmpRetailerWiseVatTax  
			WHERE  (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR  
			CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))        AND  
			(SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
			SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
			AND  
			(RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
			RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
			AND InvDate BETWEEN @FromDate AND @ToDate  
			AND IOTaxType='Purchase'  
			Group By CmpId,SMId,RMId,RtrId,RtrName,  
			TINNumber,PrdId,PrdName,INTax,OutTax  
		END
		IF LEN(@PurDBName) > 0  
		BEGIN  
			SET @SSQL = 'INSERT INTO #RptRetailerWiseVatTax ' +  
			'(' + @TblFields + ')' +  
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName  
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +  
			' CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ ' SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR ' +  
			' SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND '  
			+ 'AND RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR ' +  
			'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '  
			+ 'AND InvDate BETWEEN @FromDate AND @ToDate'  
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptRetailerWiseVatTax'  
			EXEC (@SSQL)  
			PRINT 'Saved Data Into SnapShot Table'  
		END  
	END  
	ELSE    --To Retrieve Data From Snap Data  
	BEGIN  
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,  
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT  
		PRINT @ErrNo  
		IF @ErrNo = 0  
		BEGIN  
			SET @SSQL = 'INSERT INTO #RptRetailerWiseVatTax ' +  
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
			--  SET @Po_Errno = 1  
			PRINT 'DataBase or Table not Found'  
			RETURN  
		END  
	END  

	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId  
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptRetailerWiseVatTax  
	SELECT CmpId,SMId,RMId,RtrId,RtrName,TINNumber,A.PrdId,PrdName,Quantity,  
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(A.Quantity AS INT)>=nullif(ConverisonFactor2,0) Then CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,  
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,  
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(A.Quantity AS INT)-((CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity 
	AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then  
	(CAST(A.Quantity AS INT)-((CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,  
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN  
	CASE  
	WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN  
	Case When  
	CAST(A.Quantity AS INT)-(((CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+  
	(((CAST(A.Quantity AS INT)-((CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)
	),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then  
	CAST(A.Quantity AS INT)-(((CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0
	)),0))*nullif(ConverisonFactor3,0))+  
	(((CAST(A.Quantity AS INT)-((CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)
	),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END  
	ELSE  
	CASE  
	WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN  
	Case  
	When CAST(Sum(A.Quantity) AS INT)>nullif(ConverisonFactor2,0) Then  
	CAST(Sum(A.Quantity) AS INT)%nullif(ConverisonFactor2,0)  
	Else CAST(Sum(A.Quantity) AS INT) End  
	WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN  
	Case  
	When CAST(Sum(A.Quantity) AS INT)>nullif(ConverisonFactor3,0) Then  
	CAST(Sum(A.Quantity) AS INT)%nullif(ConverisonFactor3,0)  
	Else CAST(Sum(A.Quantity) AS INT) End     
	ELSE CAST(Sum(A.Quantity) AS INT) END  
	END as Uom4,  
	GrossAmount,INTax,OutTax,INTaxableAmount,INTaxAmount,OutTaxableAmount,OutTaxAmount,TaxType INTO #RptColDetails  
	FROM #RptRetailerWiseVatTax A, View_ProdUOMDetails B WHERE a.prdid=b.prdid  
	GROUP BY CmpId,SMId,RMId,RtrId,RtrName,TINNumber,A.PrdId,PrdName,Quantity,GrossAmount,INTax,OutTax,INTaxableAmount,INTaxAmount,OutTaxableAmount,OutTaxAmount,TaxType,ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,ConversionFactor1  
	DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId  
	INSERT INTO RptColValues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,Rptid,Usrid)  
	SELECT RtrName,TINNumber,PrdName,Quantity,Uom1,Uom2,Uom3,Uom4,OutTax,INTaxableAmount,INTaxAmount,OutTaxableAmount,OutTaxAmount,@Pi_RptId,@Pi_UsrId  
	FROM #RptColDetails  

	SELECT CmpId,SMId,RMId,RtrId,RtrName,TINNumber,A.PrdId,PrdName,Quantity,    
	CASE WHEN ConverisonFactor2>0 THEN Case When CAST(A.Quantity AS INT)>=nullif(ConverisonFactor2,0) Then CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,  
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,  
	CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(A.Quantity AS INT)-((CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity 
	AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then  
	(CAST(A.Quantity AS INT)-((CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),
	0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,  
	CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN  
	CASE  
	WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN  
	Case When  
	CAST(A.Quantity AS INT)-(((CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+  
	(((CAST(A.Quantity AS INT)-((CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)
	),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then  
	CAST(A.Quantity AS INT)-(((CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0
	)),0))*nullif(ConverisonFactor3,0))+  
	(((CAST(A.Quantity AS INT)-((CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.Quantity AS INT)-(CAST(A.Quantity AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)
	),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END  
	ELSE  
	CASE  
	WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN  
	Case  
	When CAST(Sum(A.Quantity) AS INT)>nullif(ConverisonFactor2,0) Then  
	CAST(Sum(A.Quantity) AS INT)%nullif(ConverisonFactor2,0)  
	Else CAST(Sum(A.Quantity) AS INT) End  
	WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN  
	Case  
	When CAST(Sum(A.Quantity) AS INT)>nullif(ConverisonFactor3,0) Then  
	CAST(Sum(A.Quantity) AS INT)%nullif(ConverisonFactor3,0)  
	Else CAST(Sum(A.Quantity) AS INT) End     
	ELSE CAST(Sum(A.Quantity) AS INT) END  
	END as Uom4,  
	GrossAmount,INTax,OutTax,INTaxableAmount,INTaxAmount,OutTaxableAmount,OutTaxAmount,TaxType  
	FROM #RptRetailerWiseVatTax A, View_ProdUOMDetails B WHERE a.prdid=b.prdid  
	GROUP BY CmpId,SMId,RMId,RtrId,RtrName,TINNumber,A.PrdId,PrdName,Quantity,GrossAmount,INTax,OutTax,INTaxableAmount,INTaxAmount,OutTaxableAmount,OutTaxAmount,TaxType,ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,ConversionFactor1  
	-- End Here 

	--SELECT CmpId,SMId,RMId,RtrId,RtrName,TINNumber,PrdId,PrdName,Quantity,GrossAmount,INTax,OutTax,INTaxableAmount,INTaxAmount,OutTaxableAmount,OutTaxAmount,TaxType
	--	FROM #RptRetailerWiseVatTax
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptRetailerWiseVatTax_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptRetailerWiseVatTax_Excel]
		SELECT CmpId,SMId,RMId,RtrId,RtrName,TINNumber,PrdId,PrdName,Quantity,GrossAmount,INTax,OutTax,INTaxableAmount,INTaxAmount,OutTaxableAmount,OutTaxAmount,TaxType INTO RptRetailerWiseVatTax_Excel FROM #RptRetailerWiseVatTax
	END	

	RETURN  
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-171-022

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_ClaimAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_ClaimAll]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
TRUNCATE TABLE Cs2Cn_Prk_ClaimAll
TRUNCATE TABLE Cs2Cn_Prk_Claim_SchemeDetails
EXEC Proc_Cs2Cn_ClaimAll 0
SELECT * FROM Cs2Cn_Prk_ClaimAll
SELECT * FROM Cs2Cn_Prk_Claim_SchemeDetails
SELECT * FROM ClaimSheetHd
ROLLBACK TRANSACTION	
*/

CREATE  PROCEDURE [dbo].[Proc_Cs2Cn_ClaimAll]
(
	@Po_ErrNo  INT OUTPUT
)
AS
BEGIN
SET NOCOUNT ON
/*********************************
* PROCEDURE	: Proc_Cs2Cn_ClaimAll
* PURPOSE	: Extract Claim sheet details from CoreStocky to Console-->Nivea
* NOTES		:
* CREATED	: Nandakumar R.G
* DATE		: 13/11/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag='Y'

	SET @Po_ErrNo  =0
	EXEC Proc_Cs2Cn_Claim_RateDiffernece
	EXEC Proc_Cs2Cn_Claim_Scheme
	EXEC Proc_Cs2Cn_Claim_Manual
	EXEC Proc_Cs2Cn_Claim_BatchTransfer
	EXEC Proc_Cs2Cn_Claim_DeliveryBoy
	EXEC Proc_Cs2Cn_Claim_PurchaseExcess
	EXEC Proc_Cs2Cn_Claim_PurchaseShortage
	EXEC Proc_Cs2Cn_Claim_ResellDamage
	EXEC Proc_Cs2Cn_Claim_ReturnToCompany
	EXEC Proc_Cs2Cn_Claim_Salesman
	EXEC Proc_Cs2Cn_Claim_SalesmanIncentive
	EXEC Proc_Cs2Cn_Claim_Salvage
	EXEC Proc_Cs2Cn_Claim_SpecialDiscount
	EXEC Proc_Cs2Cn_Claim_Transporter
	EXEC Proc_Cs2Cn_Claim_VanSubsidy
	EXEC Proc_Cs2Cn_Claim_Vat	
	EXEC Proc_Cs2Cn_Claim_StockJournal
	EXEC Proc_Cs2Cn_Claim_RateChange
	EXEC Proc_Cs2Cn_Claim_ModernTrade

	UPDATE CH SET Upload='Y' FROM ClaimSheetHd CH,ClaimSheetDetail CD
	WHERE CH.ClmId=CD.ClmId AND CD.RefCode IN (SELECT DISTINCT ClaimRefNo FROM Cs2Cn_Prk_ClaimAll) 
	AND CH.Confirm=1 AND Status=1

	UPDATE CH SET Upload='Y' FROM ClaimSheetHd CH
	WHERE CH.ClmCode IN (SELECT DISTINCT ClaimRefNo FROM Cs2Cn_Prk_ClaimAll WHERE ClaimType='Scheme Claim') 
	AND CH.Confirm=1
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	Where ProcId = 12

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-171-023

UPDATE Configuration SET Status=0 WHERE ModuleId='SALESRTN18'
UPDATE Configuration SET Status=1 WHERE ModuleId='SALESRTN19'

--SRF-Nanda-171-024

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeProducts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeProducts]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeProducts 0
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeProducts]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeProducts
* PURPOSE: To Insert and Update Scheme Products
* CREATED: Boopathy.P on 05/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode 	AS VARCHAR(50)
	DECLARE @Type  		AS VARCHAR(50)
	DECLARE @PrdCode 	AS VARCHAR(50)
	DECLARE @PrdBatCode 	AS VARCHAR(50)
	DECLARE @CmpId  	AS VARCHAR(50)
	DECLARE @TypeId  	AS VARCHAR(50)
	DECLARE @PrdId  	AS VARCHAR(50)
	DECLARE @PrdBatId 	AS VARCHAR(50)
	DECLARE @SchLevelId 	AS VARCHAR(50)
	DECLARE @BatchLvl 	AS VARCHAR(50)
	DECLARE @UDCId  	AS VARCHAR(50)
	DECLARE @CombiSch 	AS VARCHAR(50)
	DECLARE @ChkCount 	AS INT
	DECLARE @ErrDesc  	AS VARCHAR(1000)
	DECLARE @TabName  	AS VARCHAR(50)
	DECLARE @GetKey   	AS VARCHAR(50)
	DECLARE @Taction  	AS INT
	DECLARE @SelLvl   	AS VARCHAR(50)
	DECLARE @SelMode	AS VARCHAR(50)
	DECLARE @ConFig   	AS INT
	DECLARE @sSQL     	AS VARCHAR(4000)
	DECLARE @MaxSchLevelId 	AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @SLevel		AS INT

	--->Added By Nanda on 09/11/2010
	DECLARE @MaxSchId	AS INT
	DECLARE @FBMSchCode AS NVARCHAR(100)
	DECLARE @FBMSchId	AS INT
	DECLARE @FBMDate	AS DATETIME
	SELECT @MaxSchId=ISNULL(MAX(SchId),0) FROM SchemeProducts
	--->Till Here
	
	SET @TabName = 'Etl_Prk_SchemeProducts_Combi'
	SET @Po_ErrNo =0
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	DECLARE Cur_SchemePrds CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],ISNULL(SchLevel,'') AS [Type],
	ISNULL([PrdCode],'') AS [Code],ISNULL([PrdBatCode],'') AS [Batch Code] 
	FROM Etl_Prk_SchemeProducts_Combi WHERE SlabValue = 0 AND SlabId=0  
	AND CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code]
	OPEN Cur_SchemePrds
	FETCH NEXT FROM Cur_SchemePrds INTO @SchCode,@Type,@PrdCode,@PrdBatCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo =0
		SET @Taction = 2
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@Type))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@PrdCode))= ''
		BEGIN
			SET @ErrDesc = 'Product Code should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF NOT EXISTS(SELECT DISTINCT PRDID FROM PRODUCT)
		BEGIN
			SET @ErrDesc = 'No Product(s) found in Product Master'
			INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF NOT EXISTS(SELECT DISTINCT Prdbatid FROM PRODUCTBATCH)
		BEGIN
			SET @ErrDesc = 'No Batch found in Batch Master'
			INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
-- 		ELSE IF UPPER(LTRIM(RTRIM(@Type)))='PRODUCT' AND UPPER(LTRIM(RTRIM(@Type)))='UDC'
-- 		BEGIN
-- 			SET @ErrDesc = 'Type should be (PRODUCT OR UDC)'
-- 			INSERT INTO Errorlog VALUES (1,@TabName,'Type',@ErrDesc)
-- 			SET @Taction = 0
-- 			SET @Po_ErrNo =1
-- 		END
		SELECT @Type= SchemeLevelMode FROM Etl_Prk_SchemeHD_Slabs_Rules 
		WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
		IF @Po_ErrNo=0
		BEGIN
			IF @ConFig<>1
			BEGIN
				IF NOT EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @ErrDesc = 'Company Scheme Code not found'
					INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId,@BatchLvl=BatchLevel,@SelMode=SchemeLvlMode
					FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId,@BatchLvl=BatchLevel,@SelMode=SchemeLvlMode
						FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @UDCId=A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
						ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
						AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
					BEGIN
						IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode)))
						BEGIN
							SET @ErrDesc = 'Company Scheme Code not found'
							INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
							B.CmpCode=A.CmpCode WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
							SELECT @SchLevelId=CmpPrdCtgId FROM Etl_Prk_SchemeHD_Slabs_Rules A 
							INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
							INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
							AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
						END
					END
					ELSE
					BEGIN
						SELECT @CmpId=CmpId FROM ETL_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode))
	
						SELECT @SchLevelId=SchLevelId,@BatchLvl=BatchLevel,@SelMode=SchemeLvlMode
						FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END	END
			END
			IF UPPER(LTRIM(RTRIM(@Type)))='PRODUCT' OR UPPER(LTRIM(RTRIM(@Type)))='SKU' OR UPPER(LTRIM(RTRIM(@Type)))='MATERIAL'
			BEGIN
				SELECT @MaxSchLevelId=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				IF @MaxSchLevelId=@SchLevelId
				BEGIN
					IF NOT EXISTS(SELECT PrdId FROM Product WHERE CmpId=@CmpId
					AND PrdCCode=LTRIM(RTRIM(@PrdCode)))
					BEGIN
						IF @ConFig<>1
						BEGIN
							SET @ErrDesc = 'Product Code Not Found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (11,@TabName,'Product Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SET @PrdId= 0 --LTRIM(RTRIM(@PrdCode))
						END
					END
					ELSE
					BEGIN
						SELECT @PrdId=PrdId FROM Product WHERE CmpId=@CmpId
						AND PrdCCode=LTRIM(RTRIM(@PrdCode))
						SET @UDCId=0
						IF @BatchLvl=1
						BEGIN
							IF LTRIM(RTRIM(@PrdBatCode))= ''
							BEGIN
								SET @ErrDesc = 'Batch Code should not be blank for Product Code:'+ @PrdCode+' in Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'Batch Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1  					
							END
							IF NOT EXISTS(SELECT PrdBatId FROM ProductBatch WHERE PrdId=@PrdId AND
									PrdBatCode=LTRIM(RTRIM(@PrdBatCode)))
							BEGIN
								IF @ConFig<>1
								BEGIN
									SET @ErrDesc = 'Batch Code Not Found for Product Code:'+ @PrdCode+' in Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (11,@TabName,'Batch Code',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SET @PrdBatId=LTRIM(RTRIM(@PrdBatCode))
								END
							END
							ELSE
							BEGIN
								SELECT @PrdBatId=PrdBatId FROM ProductBatch WHERE PrdId=@PrdId AND
								PrdBatCode=LTRIM(RTRIM(@PrdBatCode))
							END
						END
						ELSE
						BEGIN
							SET @PrdBatId=0
						END
					END
				END
				ELSE  -- For Product Category Value
				BEGIN
					IF NOT EXISTS(SELECT A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
					ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
					AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId)
					BEGIN
						IF @ConFig<>1
						BEGIN
							SET @ErrDesc = 'Product Category Level Not Found for Product Code:'+ @PrdCode+' in Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (11,@TabName,'Product Category',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @UDCId=A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
								ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
								AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId
							SET @PrdId=0
							SET @PrdBatId=0
						END
					END
					ELSE
					BEGIN
						SELECT @UDCId=A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
						ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
						AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId
						SET @PrdId=0
						SET @PrdBatId=0
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@Type)))='UDC'
			BEGIN
				IF NOT EXISTS(SELECT DISTINCT A.UDCUniqueId FROM UdcDetails A INNER JOIN UdcMaster B
				ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
				INNER JOIN Product P ON A.MasterRecordId=P.PrdId AND P.CmpId=@CmpId
				WHERE A.UdcMasterId=@SchLevelId)
				BEGIN
					IF @ConFig<>1
					BEGIN
						SET @ErrDesc = 'UDC Not Found for Product Code:'+ @PrdCode+' in Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (11,@TabName,'UDC',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SET @UDCId=0
						SET @PrdId=0
						SET @PrdBatId=0
					END
				END
				ELSE
				BEGIN
					SELECT DISTINCT @UDCId=A.UDCUniqueId FROM UdcDetails A INNER JOIN UdcMaster B
					ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
					INNER JOIN Product P ON A.MasterRecordId=P.PrdId AND P.CmpId=@CmpId
					Where A.UdcMasterId=@SchLevelId
					SET @PrdId=0
					SET @PrdBatId=0
				END
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
			SELECT @ChkCount=COUNT(*) FROM TempDepCheck
			IF @ChkCount > 0
			BEGIN
				SET @Taction = 0
			END
			ELSE
			BEGIN
				IF @ConFig=1
				BEGIN
					SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
					IF @SchLevelId<@SLevel
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
							IF @SLevel=@SchLevelId
							BEGIN
								DELETE FROM SCHEMEPRODUCTS WHERE PrdId=@PrdId AND PrdBatId= @PrdBatId AND
							     	SchId=@GetKey
							     	SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdId=' + CAST(@PrdId AS VARCHAR(50)) +
							     	' AND PrdBatId=' + CAST(@PrdBatId AS VARCHAR(50)) + ' AND SchId=' + CAST(@GetKey AS VARCHAR(50))
							END
							ELSE
							BEGIN
								DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=@UDCId AND
								SchId=@GetKey
								SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=' + CAST(@UDCId AS VARCHAR(50)) +
								' AND SchId=' + CAST(@GetKey AS VARCHAR(10))
							END
							
							INSERT INTO Translog(strSql1) Values (@sSQL)
							INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
							LastModBy,LastModDate,AuthId,AuthDate,RowId) VALUES(@GetKey,ISNULL(@UDCId,0),
							@PrdId ,@PrdBatId,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),1)
							
							SET @sSQL ='INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
							LastModBy,LastModDate,AuthId,AuthDate,RowId) VALUES('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
							CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
							',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',1)'
							INSERT INTO Translog(strSql1) Values (@sSQL)
						END
						ELSE
						BEGIN
							INSERT INTO Etl_Prk_SchemeProduct_Temp(CmpSchCode,PrdCtgValMainId,PrdId,PrdCode,PrdBatId,UpLoadFlag)
							VALUES(LTRIM(RTRIM(@SchCode)),@UDCId,@PrdId,LTRIM(RTRIM(@PrdCode)),@PrdBatId,'N')
							SET @sSQL ='INSERT INTO Etl_Prk_SchemeProduct_Temp(CmpSchCode,PrdCtgValMainId,PrdId,PrdCode,PrdBatId,UpLoadFlag)
							VALUES('+ CAST(@SchCode AS VARCHAR(50)) + ',' +
							CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdCode AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
							 ',''N'''')'
							INSERT INTO Translog(strSql1) Values (@sSQL)
							SET @Po_ErrNo=0
						END
					END
					ELSE
					BEGIN
						IF @SLevel=@SchLevelId
						BEGIN
							DELETE FROM Etl_Prk_SchemeProduct_Temp WHERE PrdId=CAST(@PrdId AS VARCHAR(50)) AND PrdBatId= CAST(@PrdBatId AS VARCHAR(50)) AND
						     	CmpSchCode=@GetKey AND UpLoadFlag='N'
						END
						ELSE
						BEGIN
							DELETE FROM Etl_Prk_SchemeProduct_Temp WHERE PrdCtgValMainId=CAST(@UDCId  AS VARCHAR(50)) AND
							CmpSchCode=@GetKey AND UpLoadFlag='N'
						END
						INSERT INTO Translog(strSql1) Values (@sSQL)
						INSERT INTO Etl_Prk_SchemeProduct_Temp(CmpSchCode,PrdCtgValMainId,PrdId,PrdCode,PrdBatId,UpLoadFlag)
						VALUES(LTRIM(RTRIM(@SchCode)),@UDCId,@PrdId,LTRIM(RTRIM(@PrdCode)),@PrdBatId,'N')
						SET @sSQL ='INSERT INTO Etl_Prk_SchemeProduct_Temp(CmpSchCode,PrdCtgValMainId,PrdId,PrdCode,PrdBatId,UpLoadFlag)
						VALUES('+ CAST(@SchCode AS VARCHAR(50)) + ',' +
						CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdCode AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
						 ',''N'''')'
						INSERT INTO Translog(strSql1) Values (@sSQL)
						SET @Po_ErrNo=0
						
					END		
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@Type)))='UDC'
					BEGIN
						DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=@UDCId AND
						SchId=@GetKey
-- 						SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=' + CAST(@UDCId AS VARCHAR(10)) +
-- 						' AND SchId=' + CAST(@GetKey AS VARCHAR(10))
-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
						INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
						LastModBy,LastModDate,AuthId,AuthDate,RowId) VALUES(@GetKey,ISNULL(@UDCId,0),
						@PrdId,@PrdBatId,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),1)
-- 						SET @sSQL ='INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
-- 						LastModBy,LastModDate,AuthId,AuthDate) VALUES('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
-- 						CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
-- 						',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
					ELSE IF UPPER(LTRIM(RTRIM(@Type)))='PRODUCT' OR UPPER(LTRIM(RTRIM(@Type)))='SKU' OR UPPER(LTRIM(RTRIM(@Type)))='MATERIAL'
					BEGIN
						IF @MaxSchLevelId=@SchLevelId
						BEGIN
						     DELETE FROM SCHEMEPRODUCTS WHERE PrdId=@PrdId AND PrdBatId= @PrdBatId AND
						     SchId=@GetKey
-- 						     SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdId=' + CAST(@PrdId AS VARCHAR(50)) +
-- 						     ' AND PrdBatId=' + CAST(@PrdBatId AS VARCHAR(50)) + ' AND SchId=' + CAST(@GetKey AS VARCHAR(50))
						END
						ELSE
						BEGIN
						     DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=@UDCId AND
						     SchId=@GetKey
-- 						     SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=' + CAST(@UDCId AS VARCHAR(50)) +
-- 						     ' AND SchId=' + CAST(@GetKey AS VARCHAR(10))
						END
						INSERT INTO Translog(strSql1) Values (@sSQL)
						INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
						LastModBy,LastModDate,AuthId,AuthDate,RowId) VALUES(@GetKey,ISNULL(@UDCId,0),
						@PrdId,@PrdBatId,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),1)
-- 						SET @sSQL ='INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
-- 						LastModBy,LastModDate,AuthId,AuthDate) VALUES('+ CAST(ISNULL(@GetKey,0) AS VARCHAR(10)) + ',' +
-- 						CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
-- 						',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
	    				END
				END
			END
		END
		FETCH NEXT FROM Cur_SchemePrds INTO @SchCode,@Type,@PrdCode,@PrdBatCode
	END
	CLOSE Cur_SchemePrds
	DEALLOCATE Cur_SchemePrds

	--->Added By Nanda on 09/11/2010
	IF EXISTS(SELECT SP.* FROM SchemeProducts SP,SchemeMaster SM WHERE SM.FBM=1 AND SP.SchId=SM.SchId AND SP.SchId>@MaxSchId)
	BEGIN
		DECLARE Cur_FBMSch CURSOR
		FOR SELECT DISTINCT SM.SchCode,SM.SchId FROM SchemeProducts SP,SchemeMaster SM WHERE SM.FBM=1 AND SP.SchId=SM.SchId AND SP.SchId>@MaxSchId		
		OPEN Cur_FBMSch
		FETCH NEXT FROM Cur_FBMSch INTO @FBMSchCode,@FBMSchId
		WHILE @@FETCH_STATUS=0
		BEGIN					
			SELECT @FBMDate=CONVERT(VARCHAR(10),GETDATE(),121)
			--SELECT 'Nanda02',45,@FBMSchCode,@FBMSchId,@FBMDate,1,0
			EXEC Proc_FBMTrack 45,@FBMSchCode,@FBMSchId,@FBMDate,1,0		
			FETCH NEXT FROM Cur_FBMSch INTO @FBMSchCode,@FBMSchId
		END
		CLOSE Cur_FBMSch
		DEALLOCATE Cur_FBMSch
	END
	--->Till Here
	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if not exists (select * from hotfixlog where fixid = 349)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(349,'D','2010-11-21',getdate(),1,'Core Stocky Service Pack 349')