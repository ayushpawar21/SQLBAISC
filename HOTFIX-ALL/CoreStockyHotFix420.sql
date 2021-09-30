--[Stocky HotFix Version]=420
DELETE FROM Versioncontrol WHERE Hotfixid='420'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('420','3.1.0.1','D','2014-12-22','2014-12-22','2014-12-22',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
/*
    CR RELEASE DETAILS :
    
    1. Product Code Unification
    2. Product Batch Tax Group Automatically Update
    3. To Display Credit & Debit Details to Purchase Receipt
    4. Closing Stock Report Tax Details
    5. Fill Rates Report Value Fill Filter Added
    6. Bill Wise Market Return Report - New Report
    7. Bill Wise Sales Report Multiple Bill Selection - Parle Reports
    8. Retailer Wise Bill Wise Tax Report - Discounts,BillNo Added
*/
--PARLE CR Purchase Receipt CreditNote DebitNote
IF NOT EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'U' AND Name = 'PurchaseReceiptCreditDebit')
BEGIN
CREATE TABLE PurchaseReceiptCreditDebit
(
  CmpInvNo    NVARCHAR(200),
  RefNumber   NVARCHAR(200),
  CreditAmt   NUMERIC(38,6),
  DebitAmount NUMERIC(38,6)
)
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND name = 'Proc_Validate_PurchaseReceiptCrDbAdjustments')
DROP PROCEDURE Proc_Validate_PurchaseReceiptCrDbAdjustments
GO
/*
BEGIN TRANSACTION
Exec Proc_Validate_PurchaseReceiptCrDbAdjustments 0
SELECT * FROM ErrorLog
SELECT * FROM PurchaseReceiptCreditDebit (NOLOCK)
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_Validate_PurchaseReceiptCrDbAdjustments]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Validate_PurchaseReceiptCrDbAdjustments
* PURPOSE		: To Insert and Update records in the Table PurchaseReceiptCrDbAdjustments
* CREATED		: Nandakumar R.G
* CREATED DATE	: 10/11/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Tabname 	AS     	NVARCHAR(100)
	DECLARE @DestTabname 	AS 	NVARCHAR(100)
	DECLARE @Fldname 	AS     	NVARCHAR(100)
	
	DECLARE @CmpInvNo	AS 	NVARCHAR(100)	
	DECLARE @AdjType	AS 	NVARCHAR(100)
	DECLARE @CmpRefNo	AS 	NVARCHAR(100)
	DECLARE @RefNo	AS 	NVARCHAR(100)
	DECLARE @Amt		AS 	NVARCHAR(100)	
	
	SET @Po_ErrNo=0
	
	SET @DestTabname='ETLTempPurchaseReceiptCrDbAdjustments'
	SET @Fldname='CmpInvNo'
	SET @Tabname = 'ETL_Prk_PurchaseReceiptCrDbAdjustments'
	
	DECLARE Cur_PurchaseReceiptCrDbAdj CURSOR
	FOR SELECT DISTINCT ISNULL([Company Invoice No],''),ISNULL([Adjustment Type],''),ISNULL([Ref No],''),ISNULL([Amount],0)
	FROM ETL_Prk_PurchaseReceiptCrDbAdjustments WHERE Amount>0
	OPEN Cur_PurchaseReceiptCrDbAdj

	FETCH NEXT FROM Cur_PurchaseReceiptCrDbAdj INTO @CmpInvNo,@AdjType,@CmpRefNo,@Amt

	WHILE @@FETCH_STATUS=0
	BEGIN
		
		SET @Po_ErrNo=0

		IF NOT EXISTS(SELECT * FROM ETLTempPurchaseReceipt WITH (NOLOCK) WHERE CmpInvNo=@CmpInvNo)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Invoice No',
			'Company Invoice No:'+@CmpInvNo+' is not available')  
         	
			SET @Po_ErrNo=1
		END				

		IF @Po_ErrNo=0
		BEGIN
			IF NOT ISNUMERIC(@Amt)=1
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Amount',
				'Amount:'+@Amt+' should be in numeric in Company Invoice No:'+@CmpInvNo) 

				SET @Po_ErrNo=1
			END			
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@AdjType)))='CREDIT'
			BEGIN
				SELECT @RefNo=ISNULL(CrNoteNumber,'') FROM CreditNoteSupplier WHERE UPPER(LTRIM(RTRIM(PostedRefNo)))=UPPER(LTRIM(RTRIM(@CmpRefNo)))
			END
			ELSE
			BEGIN
				SELECT @RefNo=ISNULL(DbNoteNumber,'') FROM DebitNoteSupplier WHERE UPPER(LTRIM(RTRIM(PostedRefNo)))=UPPER(LTRIM(RTRIM(@CmpRefNo)))
			END
		END

		IF @RefNo IS NULL
		BEGIN
			SET @RefNo=''
		END
		
		IF @RefNo=''
		BEGIN
			SET @Po_ErrNo=1			
		END

		IF @Po_ErrNo=0
		BEGIN
			INSERT INTO ETLTempPurchaseReceiptCrDbAdjustments(CmpInvNo,AdjType,CrDbNo,Amount) 
			SELECT @CmpInvNo,(CASE @AdjType WHEN 'Credit' THEN 1 ELSE 2 END),@RefNo,@Amt
		END
			
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_PurchaseReceiptCrDbAdj
			DEALLOCATE Cur_PurchaseReceiptCrDbAdj
			RETURN
		END

		FETCH NEXT FROM Cur_PurchaseReceiptCrDbAdj INTO @CmpInvNo,@AdjType,@CmpRefNo,@Amt

	END
	CLOSE Cur_PurchaseReceiptCrDbAdj
	DEALLOCATE Cur_PurchaseReceiptCrDbAdj
	
	--IF @Po_ErrNo=0
	--BEGIN
		DELETE FROM PurchaseReceiptCreditDebit WHERE CmpInvNo IN
		(SELECT DISTINCT CmpInvNo FROM ETLTempPurchaseReceiptCrDbAdjustments (NOLOCK) WHERE DownloadStatus = 0) 

		INSERT INTO PurchaseReceiptCreditDebit (CmpInvNo,RefNumber,CreditAmt,DebitAmount)
		SELECT DISTINCT CmpInvNo,CrDbNo,(CASE AdjType WHEN 1 THEN ISNULL(Amount,0) ELSE 0 END) AS CreditAmt,
		(CASE AdjType WHEN 2 THEN ISNULL(Amount,0) ELSE 0 END) AS DebitAmt FROM ETLTempPurchaseReceiptCrDbAdjustments (NOLOCK)
		WHERE DownloadStatus = 0
    --END 

	IF @Po_ErrNo=0
	BEGIN
		TRUNCATE TABLE ETL_Prk_PurchaseReceiptCrDbAdjustments
	END

	SET @Po_ErrNo=0

	RETURN	
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND name = 'Proc_ValidateTaxMapping')
DROP PROCEDURE Proc_ValidateTaxMapping
GO
--EXEC Proc_ValidateTaxMapping 0
CREATE PROCEDURE Proc_ValidateTaxMapping
(
	@Po_ErrNo INT OUTPUT
)
AS
/*************************************************************************************************
* PROCEDURE  : Proc_ValidateTaxMapping
* PURPOSE    : To Update the Taxgroup Code Product and Product Batch
* CREATED    : Sathishkumar Veeramani 2014/11/26
***************************************************************************************************
*
**************************************************************************************************/
BEGIN
SET NOCOUNT ON
	SET @Po_ErrNo=0
	DELETE FROM Etl_Prk_TaxMapping WHERE DownloadFlag = 'Y'
	
	CREATE TABLE #ToAvoidTaxGroup
	(
	  PrdCCode     NVARCHAR (200),
	  TaxGrpCode   NVARCHAR (200)
	)
	
	--Product Code Validation
	INSERT INTO #ToAvoidTaxGroup (PrdCCode,TaxGrpCode)
	SELECT DISTINCT PrdCode,TaxGroupCode FROM Etl_Prk_TaxMapping A (NOLOCK) 
	WHERE NOT EXISTS (SELECT DISTINCT PrdCCode FROM Product B (NOLOCK) WHERE A.PrdCode = B.PrdCCode)
	AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'Product','PrdCCode','Product Code Not Available-'+PrdCode FROM Etl_Prk_TaxMapping A (NOLOCK) 
	WHERE NOT EXISTS (SELECT DISTINCT PrdCCode FROM Product B (NOLOCK) WHERE A.PrdCode = B.PrdCCode)
	AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidTaxGroup (PrdCCode,TaxGrpCode)
	SELECT DISTINCT PrdCode,TaxGroupCode FROM Etl_Prk_TaxMapping (NOLOCK) WHERE LTRIM(RTRIM(ISNULL(PrdCode,''))) = ''
	AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'Product','PrdCCode','Product Code Should not be Empty or Null'+PrdCode
	FROM Etl_Prk_TaxMapping (NOLOCK) WHERE LTRIM(RTRIM(ISNULL(PrdCode,''))) = '' AND DownloadFlag = 'D'
	
	--Tax Group Code Validation
	INSERT INTO #ToAvoidTaxGroup (PrdCCode,TaxGrpCode)
	SELECT DISTINCT PrdCode,TaxGroupCode FROM Etl_Prk_TaxMapping A (NOLOCK) 
	WHERE NOT EXISTS (SELECT DISTINCT PrdGroup FROM TaxGroupSetting B (NOLOCK) WHERE A.TaxGroupCode = B.PrdGroup AND TaxGroup = 2)
	AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'TaxGroupSetting','PrdGroup','Product Tax Group Code Not Available-'+TaxGroupCode FROM Etl_Prk_TaxMapping A (NOLOCK) 
	WHERE NOT EXISTS (SELECT DISTINCT PrdGroup FROM TaxGroupSetting B (NOLOCK) WHERE A.TaxGroupCode = B.PrdGroup AND TaxGroup = 2)
	AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidTaxGroup (PrdCCode,TaxGrpCode)
	SELECT DISTINCT PrdCode,TaxGroupCode FROM Etl_Prk_TaxMapping (NOLOCK) WHERE LTRIM(RTRIM(ISNULL(TaxGroupCode,''))) = ''
	AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'TaxGroupSetting','PrdGroup','Product Tax Group Code Should not be Empty or Null'+TaxGroupCode
	FROM Etl_Prk_TaxMapping (NOLOCK) WHERE LTRIM(RTRIM(ISNULL(TaxGroupCode,''))) = '' AND DownloadFlag = 'D'
	
	--Duplcate Check Multiple Tax Group Code in Single Product
	INSERT INTO #ToAvoidTaxGroup (PrdCCode,TaxGrpCode)
	SELECT DISTINCT A.PrdCode,TaxGroupCode FROM Etl_Prk_TaxMapping A (NOLOCK) INNER JOIN 
	(SELECT DISTINCT PrdCode,COUNT(TaxGroupCode) AS Counts FROM Etl_Prk_TaxMapping A (NOLOCK) WHERE
	NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup B WHERE A.PrdCode = B.PrdCCode AND A.TaxGroupCode = B.TaxGrpCode) 
	GROUP BY PrdCode HAVING COUNT(TaxGroupCode) > 1) B ON A.PrdCode = B.PrdCode
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'Etl_Prk_TaxMapping','PrdCode','Same Product Should not Allow Multiple TaxGroup Code-'+A.PrdCode
	FROM Etl_Prk_TaxMapping A (NOLOCK) INNER JOIN (SELECT DISTINCT PrdCode,COUNT(TaxGroupCode) AS Counts FROM Etl_Prk_TaxMapping A (NOLOCK)
	WHERE NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup B WHERE A.PrdCode = B.PrdCCode AND A.TaxGroupCode = B.TaxGrpCode) 
	GROUP BY PrdCode HAVING COUNT(TaxGroupCode) > 1) B ON A.PrdCode = B.PrdCode	 	
	
	--Product Tax Group Code Updated
	UPDATE A SET A.TaxGroupId  = C.TaxGroupId FROM Product A (NOLOCK) 
	INNER JOIN Etl_Prk_TaxMapping B (NOLOCK) ON A.PrdCCode = B.PrdCode
	INNER JOIN TaxGroupSetting C (NOLOCK) ON B.TaxGroupCode = C.PrdGroup
	WHERE C.TaxGroup = 2 AND DownloadFlag = 'D' AND MapStatus = 1 AND
	NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup D WHERE B.PrdCode = D.PrdCCode AND B.TaxGroupCode = D.TaxGrpCode)

	SELECT DISTINCT PrdId,UomGroupId,C.TaxGroupId INTO #ProductHierarchyTax FROM Product A (NOLOCK) 
	INNER JOIN Etl_Prk_TaxMapping B (NOLOCK) ON A.PrdCCode = B.PrdCode
	INNER JOIN TaxGroupSetting C (NOLOCK) ON B.TaxGroupCode = C.PrdGroup
	WHERE C.TaxGroup = 2 AND DownloadFlag = 'D' AND MapStatus = 1 AND
	NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup D WHERE B.PrdCode = D.PrdCCode AND B.TaxGroupCode = D.TaxGrpCode)
	
	UPDATE A SET A.TaxGroupId = B.TaxGroupId FROM Product A (NOLOCK) 
	INNER JOIN #ProductHierarchyTax B ON A.UomGroupId = B.UomGroupId
	WHERE NOT EXISTS (SELECT DISTINCT PrdId FROM #ProductHierarchyTax C WHERE A.PrdId = C.PrdId)
	
	--Product Batch Tax Group Code Updated
	UPDATE PB SET PB.TaxGroupId  = C.TaxGroupId FROM ProductBatch PB (NOLOCK)
	INNER JOIN Product A (NOLOCK) ON PB.PrdId = A.PrdId 
	INNER JOIN Etl_Prk_TaxMapping B (NOLOCK) ON A.PrdCCode = B.PrdCode
	INNER JOIN TaxGroupSetting C (NOLOCK) ON B.TaxGroupCode = C.PrdGroup
	WHERE C.TaxGroup = 2 AND DownloadFlag = 'D' AND MapStatus = 1 AND
	NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup D WHERE B.PrdCode = D.PrdCCode AND B.TaxGroupCode = D.TaxGrpCode)
	
	UPDATE A SET A.TaxGroupId = B.TaxGroupId FROM ProductBatch A (NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId
	INNER JOIN #ProductHierarchyTax C ON B.UomGroupId = C.UomGroupId
	WHERE NOT EXISTS (SELECT DISTINCT PrdId FROM #ProductHierarchyTax D WHERE B.PrdId = D.PrdId)
	
	--Download Flag Change
	UPDATE A SET A.DownloadFlag = 'Y' FROM Etl_Prk_TaxMapping A (NOLOCK) 
	INNER JOIN TaxGroupSetting B (NOLOCK) ON A.TaxGroupCode = B.PrdGroup 
	INNER JOIN Product C (NOLOCK) ON A.PrdCode = C.PrdCCode AND B.TaxGroupId = C.TaxGroupId 
	WHERE TaxGroup = 2 AND DownloadFlag = 'D'
	
RETURN
END
GO
DELETE FROM RptGroup WHERE RptId = 284
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',284,'BillWiseMarketReturnReport','Bill Wise Market Return Report',1
GO
DELETE FROM RptHeader WHERE RptId = 284
INSERT INTO RptHeader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'BillWiseMarketReturnReport','Bill Wise Market Return Report',284,'Bill Wise Market Return Report',
'Proc_RptBillwiseMarketReturnReport','RptBillWiseMarketReturnReport','RptBillWiseMarketReturnReport.rpt',''
GO
DELETE FROM RptGridView WHERE RptId = 284
INSERT INTO RptGridView (RptId,RptName,CrystalView,GridView,ExcelView,PDFView)
SELECT 284,'RptBillWiseMarketReturnReport.rpt',1,0,1,0
GO
DELETE FROM RptDetails WHERE RptId = 284
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (284,1,'FromDate',-1,NULL,'','From Date*',NULL,1,NULL,10,0,1,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (284,2,'ToDate',-1,NULL,'','To Date*',NULL,1,NULL,11,0,1,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (284,3,'Company',-1,NULL,'CmpId,CmpCode,CmpName','Company...',NULL,1,NULL,4,1,0,'Press F4/Double Click to Select Company',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (284,4,'Salesman',-1,NULL,'SMId,SMCode,SMName','Salesman...',NULL,1,NULL,1,0,0,'Press F4/Double Click to Select Salesman',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (284,5,'RouteMaster',-1,NULL,'RMId,RMCode,RMName','Route...',NULL,1,NULL,2,0,0,'Press F4/Double Click to Select Route',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (284,6,'Retailer',-1,NULL,'RtrId,RtrCode,RtrName','Retailer...',NULL,1,NULL,3,0,0,'Press F4/Double Click to select Retailer',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (284,7,'SalesInvoice',-1,NULL,'SalId,SalInvRef,SalInvNo','Bill No...',NULL,1,NULL,14,0,0,'Press F4/Double Click to select Bill No',0)
GO
DELETE FROM RptFormula WHERE RptId = 284
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,1,'CapFromDate','From Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,2,'CapToDate','To Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,3,'CapCompany','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,4,'CapSalesMan','SalesMan',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,5,'CapRoute','Route',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,6,'CapRetailer','Retailer',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,7,'ValFromDate','From Date',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,8,'ValToDate','To Date',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,9,'ValCompany','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,10,'ValSalesMan','SalesMan',1,1)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,11,'ValRoute','Route',1,2)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,12,'ValRetailer','Retailer',1,3)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,13,'BillNo','Bill Number',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,14,'Hd_PrdName','Product Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,15,'Hd_Quantity','Quantity',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,16,'Hd_RtrName','Retailer Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,17,'Hd_RtrCode','Retailer Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,18,'Hd_TaxAmt','Tax Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,19,'Hd_SplDisc','SplDisc Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,20,'Hd_SchDisc','SchDisc Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,21,'Hd_CDDisc','CDDisc Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,22,'Hd_DBDisc','DBDisc Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,23,'Hd_NetAmt','Net Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,24,'Cap Page','Page',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,25,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,26,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,27,'Disp_BillNumber','BillNumber',1,14)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (284,28,'GrandTotal','Grand Total',1,0)
GO
DELETE FROM RptExcelHeaders WHERE RptId = 284
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
SELECT 284,1,'SalId','SalId',0,1 UNION
SELECT 284,2,'SalInvNo','Bill Number',1,1 UNION
SELECT 284,3,'RtrCode','Retailer Code',1,1 UNION
SELECT 284,4,'RtrName','Retailer Name',1,1 UNION
SELECT 284,5,'PrdName','Product Name',1,1 UNION
SELECT 284,6,'Quantity','Quantity',1,1 UNION
SELECT 284,7,'TaxAmt','Tax Amount',1,1 UNION
SELECT 284,8,'SplDiscAmt','SplDisc Amount',1,1 UNION
SELECT 284,9,'SchDiscAmt','SchDisc Amount',1,1 UNION
SELECT 284,10,'CDDiscAmt','CDDisc Amount',1,1 UNION
SELECT 284,11,'DBDiscAmt','DBDisc Amount',1,1 UNION
SELECT 284,12,'NetAmount','Net Amount',1,1 UNION
SELECT 284,13,'UsrId','UsrId',0,1
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND Name = 'Proc_RptBillwiseMarketReturnReport')
DROP PROCEDURE Proc_RptBillwiseMarketReturnReport
GO
--EXEC Proc_RptBillwiseMarketReturnReport 284,1,0,'PARLE',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptBillwiseMarketReturnReport]
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFROMSnap		INT,
	@Pi_CurrencyId		INT
)
AS
SET NOCOUNT ON
BEGIN
/*****************************************************************************************************
* PROCEDURE  : Proc_RptBillwiseMarketReturnReport
* PURPOSE	 : Billwise Market Return Report
* NOTES:
* CREATED	 : Sathishkumar Veeramani 14/11/2014
------------------------------------------------------------------------------------------------------
* DATE			AUTHOR				DESCRIPTION
******************************************************************************************************/
DECLARE @FromDate	  AS 	DATETIME
DECLARE @ToDate		  AS	DATETIME
DECLARE @CmpId   	  AS	INT
DECLARE @RtrId   	  AS	INT
DECLARE @SMId   	  AS	INT
DECLARE @RMId   	  AS	INT
DECLARE @EXLFlag      AS    INT
DECLARE @SalId        AS    BIGINT
DECLARE @ErrNo        AS    INT
--Till Here
SET @ErrNo = 0
--Assgin Value for the Filter Variable
SELECT @FromDate = dSELECTed FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
SELECT @ToDate = dSELECTed FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))

---Till Here
CREATE TABLE #RptBillWiseMarketReturnReport
(	
    [SalId]             NUMERIC(18,0),
	[SalInvNo] 		    NVARCHAR(100),
	[RtrCode]			NVARCHAR(100),
	[RtrName]		    NVARCHAR(100),
	[PrdName]		    NVARCHAR(100),
	[Quantity]	        NUMERIC(18,0),
	[TaxAmt]		    NUMERIC(38,6),
	[SplDiscAmt]		NUMERIC(38,6),
	[SchDiscAmt]		NUMERIC(38,6),
	[CDDiscAmt]		    NUMERIC(38,6),
	[DBDiscAmt]		    NUMERIC(38,6),
	[NetAmount]		    NUMERIC(38,6),
	[UsrId]		        INT
)

	INSERT INTO #RptBillWiseMarketReturnReport ([SalId],[SalInvNo],[RtrCode],[RtrName],[PrdName],[Quantity],[TaxAmt],[SplDiscAmt],
				[SchDiscAmt],[CDDiscAmt],[DBDiscAmt],[NetAmount],[UsrId])
	SELECT A.SalId,C.SalInvNo,D.RtrCode,D.RtrName,E.PrdName,ISNULL(SUM(BaseQty),0) AS [Quantity],ISNULL(SUM(PrdTaxAmt),0) AS [TaxAmt],
	ISNULL(SUM(PrdSplDisAmt),0) AS [SplDiscAmt],ISNULL(SUM(PrdSchDisAmt),0) AS [SchDiscAmt],ISNULL(SUM(PrdCDDisAmt),0) AS [CDDiscAmt],
	ISNULL(SUM(PrdDBDisAmt),0) AS [DBDiscAmt],ISNULL(SUM(PrdNetAmt),0) AS [NetAmount],@Pi_UsrId
	FROM ReturnHeader A (NOLOCK) INNER JOIN ReturnProduct B (NOLOCK) ON A.ReturnId = B.ReturnId
	INNER JOIN SalesInvoice C (NOLOCK) ON A.SalId = C.SalId
	INNER JOIN Retailer D (NOLOCK) ON A.RtrId = D.RtrId
	INNER JOIN Product E (NOLOCK) ON B.PrdId = E.PrdId
	WHERE 
       (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
			  A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						
		AND (A.RMId=(CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
				A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							
		AND (A.SMId=(CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
				 A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		AND (E.CmpId=(CASE @CmpId WHEN 0 THEN E.CmpId ELSE 0 END) OR
				 E.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))			
		AND (A.SalId = (CASE @SalId WHEN 0 THEN A.SalId ELSE 0 END) OR
					A.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))) 
		AND A.[ReturnDate] BETWEEN @FromDate AND @ToDate AND 
		A.[ReturnType] = 1 AND A.[Status] = 0
   GROUP BY A.SalId,C.SalInvNo,D.RtrCode,D.RtrName,E.PrdName		
	
--Check for Report Data
	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) AS RecCount,@ErrNo,@Pi_UsrId FROM #RptBillWiseMarketReturnReport
-- Till Here
	SELECT * FROM #RptBillWiseMarketReturnReport ORDER BY SalId
	
RETURN
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'U' AND Name = 'ClosingStockProductTaxPercent')
DROP TABLE ClosingStockProductTaxPercent
GO
CREATE TABLE [dbo].[ClosingStockProductTaxPercent](
	[PrdId]         [INT] NULL,
	[TaxPercentage] [NUMERIC](18,5) NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND Name = 'Proc_ClosingStockTaxCalCulation')
DROP PROCEDURE Proc_ClosingStockTaxCalCulation
GO
/*
  BEGIN TRANSACTION
  EXEC Proc_ClosingStockTaxCalCulation
  SELECT * FROM ClosingStockProductTaxPercent (NOLOCK)
  ROLLBACK TRANSACTION
*/  
CREATE PROCEDURE [dbo].[Proc_ClosingStockTaxCalCulation]
AS
BEGIN
		DECLARE @TaxSettingDet TABLE       
		(      
			TaxSlab    INT,      
			ColNo      INT,      
			SlNo       INT,      
			BillSeqId  INT,      
			TaxSeqId   INT,      
			ColType    INT,       
			ColId      INT,      
			ColVal     NUMERIC(38,2),
			PrdId      NUMERIC(18,0)      
		) 
		
		DECLARE @PurSeqId AS INT
		DECLARE @BillSeqId AS INT
		DECLARE @RtrTaxGrp AS INT		 
		DECLARE @TaxSlab  INT  
		DECLARE @MRP INT    
		DECLARE @TaxableAmount  NUMERIC(28,10)      
		DECLARE @ParTaxableAmount NUMERIC(28,10)      
		DECLARE @TaxPer   NUMERIC(38,2)     
		DECLARE @TaxPercentage   NUMERIC(38,5)   
		DECLARE @TaxId   INT
  
		--To Take the Batch TaxGroup Id      
		--SELECT @PrdBatTaxGrp = TaxGroupId FROM Product A (NOLOCK) INNER JOIN TempClosingStock B (NOLOCK) ON A.PrdId = B.PrdId
		SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster (NOLOCK)
		SELECT @RtrTaxGrp=MIN(DISTINCT RtrId) FROM TaxSettingMaster (NOLOCK)
		
		INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,PrdId)      
		SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal,C.PrdId      
		FROM TaxSettingMaster A (NOLOCK) INNER JOIN	TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
		AND B.BillSeqId=@BillSeqId AND Coltype IN(1,3) 
		INNER JOIN 
		(SELECT DISTINCT A.PrdId,TaxGroupId FROM Product A (NOLOCK) INNER JOIN TempClosingStock B (NOLOCK) ON A.PrdId = B.PrdId) C 
		ON A.PrdId = C.TaxGroupId  WHERE A.RtrId = @RtrTaxGrp     
		AND A.TaxSeqId IN (SELECT ISNULL(MAX(TaxSeqId),0) FROM TaxSettingMaster 
		WHERE RtrId = @RtrTaxGrp AND PrdId = C.TaxGroupId)  

		TRUNCATE TABLE ClosingStockProductTaxPercent   
		      
		--To Get the Tax Percentage for the selected slab      
		SELECT PrdId,ColVal AS TaxPerc,TaxSlab INTO #TaxPercentage FROM @TaxSettingDet 
		WHERE ColType = 1 AND ColId = 0 AND ColVal > 0
		
		--Addtional Tax
		SELECT DISTINCT A.PrdId,A.TaxSlab,B.TaxPerc,CAST(1*(B.TaxPerc/100) AS NUMERIC(28,10)) AS TaxAmount
		INTO #ClosingStockAddTax FROM @TaxSettingDet A INNER JOIN #TaxPercentage B ON A.TaxSlab = B.TaxSlab 
		AND A.PrdId = B.PrdId WHERE ColType = 3 AND ColVal > 0 	
		
		SELECT DISTINCT A.PrdId,A.TaxSlab,B.TaxPerc,CAST(1*(B.TaxPerc/100) AS NUMERIC(28,10)) AS TaxAmount
		INTO #ClosingStockTax FROM @TaxSettingDet A INNER JOIN #TaxPercentage B ON A.TaxSlab = B.TaxSlab AND A.PrdId = B.PrdId
		WHERE ColVal > 0 AND NOT EXISTS (SELECT PrdId FROM #ClosingStockAddTax C WHERE A.PrdId = C.PrdId 
		AND A.TaxSlab = C.TaxSlab)
		
		INSERT INTO #ClosingStockTax (PrdId,TaxSlab,TaxPerc,TaxAmount)
		SELECT DISTINCT A.PrdId,A.TaxSlab,A.TaxPerc,CAST((B.TaxAmount * A.TaxAmount) AS NUMERIC(28,10)) AS TaxAmount
		FROM #ClosingStockAddTax A INNER JOIN #ClosingStockTax B ON A.PrdId = B.PrdId
		
		INSERT INTO ClosingStockProductTaxPercent(PrdId,TaxPercentage)
		SELECT DISTINCT PrdId,ISNULL(SUM(TaxAmount)*100,0) FROM #ClosingStockTax (NOLOCK) GROUP BY PrdId
		
END
GO
DELETE FROM RptFormula WHERE RptId = 254
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,1,'Disp_ToDate','As On Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,2,'Fill_ToDate','As On Date',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,3,'Disp_Company','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,4,'Fill_Company','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,5,'Disp_Location','Location',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,6,'Fill_Location','Location',1,22)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,7,'Disp_ProductCategoryLevel','Product Hierarchy Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,8,'Fill_ProductCategoryLevel','ProductCategoryLevel',1,16)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,9,'Disp_ProductCategoryValue','Product Hierarchy Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,10,'Fill_ProductCategoryValue','ProductCategoryLevelValue',1,21)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,11,'Disp_Product','Product',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,12,'Fill_Product','Product',1,5)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,13,'Disp_Batch','Stock Value as per',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,14,'Fill_Batch','Stock Value as per',1,209)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,15,'Disp_ProductStatus','Product Status',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,16,'Fill_ProductStatus','Product Status',1,210)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,17,'Disp_BatchStatus','Batch Status',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,18,'Fill_BatchStatus','Batch Status',1,211)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,19,'Disp_ProductDes','Product Description',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,20,'Disp_BatchT','Batch',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,21,'Disp_MRP','MRP',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,22,'Disp_RATE','Display Rate',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,23,'BOXES','BOXES',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,24,'Disp_StockValues','Gross Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,25,'PKTS','PKTS',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,26,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,27,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,28,'Disp_SupZeroStock','Suppress Zero Stock',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,29,'Fill_SupZeroStock','Suppress Zero Stock',1,44)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,30,'Product Name','Product Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,30,'Disp_Total','Grand Total',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,31,'ProductCode','Product Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,32,'Disp_StockType','Stock Type',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,33,'Fill_StockType','Stock Type',1,291)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,34,'DispTaxPer','Tax %',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,35,'DispTaxAmt','Tax Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (254,36,'DispNetAmt','StockValue NetAmt',1,0)
GO
DELETE FROM RptExcelHeaders WHERE RptId = 254
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,1,'PrdId','PrdId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,2,'PrdDCode','Product Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,3,'PrdName','Product Description',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,4,'MRP','MRP',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,5,'RATE','RATE',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,6,'BOXES','BOXES',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,7,'PKTS','PKTS',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,8,'TaxPerc','Tax %',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,9,'StockValue','Stock Value',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,10,'TaxAmount','Tax Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (254,11,'NetAmount','StockValue NetAmount',1,1)
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND Name = 'Proc_RptClosingStockReportParle')
DROP PROCEDURE Proc_RptClosingStockReportParle
GO
--EXEC Proc_RptClosingStockReportParle 254,1,0,'',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptClosingStockReportParle]
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
* VIEW	: Proc_RptClosingStockReport
* PURPOSE	: To get the Closing Stock Details
* CREATED BY	: Mahalakshmi.A
* CREATED DATE	: 17/09/2008
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
	
	--Filter Variables
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @CmpId 		AS	INT
	DECLARE @LcnId 		AS	INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @DispValue	AS	INT
	DECLARE @PrdStatus	AS	INT
	DECLARE @BatchStatus	AS	INT
	DECLARE @SupZeroStock   AS INT
	DECLARE @PrdUnit	AS INT
	----Till Here
	--Assgin Value for the Filter Variable
--	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @DispValue = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,209,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,210,@Pi_UsrId))
	SET @BatchStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,211,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)	
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	--Product UOM Details
    SELECT DISTINCT Prdid,U.ConversionFactor 
	Into #PrdUomBox
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	Inner Join UomMaster UM On U.UomId=Um.UomId
	Where Um.UomCode='BX'
		
	SELECT DISTINCT Prdid,U.ConversionFactor
	Into #PrdUomPack
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	Inner Join UomMaster UM On U.UomId=Um.UomId
	Where  P.PrdId Not In (Select PrdId From #PrdUomBox) And U.BaseUom='Y'
	
	Create Table #PrdUomAll
	(
		PrdId Int,
		ConversionFactor Int
	)
	Insert Into #PrdUomAll
	Select Distinct PrdId,ConversionFactor From #PrdUomBox
	Union All
	Select Distinct PrdId,ConversionFactor From #PrdUomPack
	SELECT Prdid,
			Case PrdUnitId 
			When 2 Then (PrdWgt/1000)/1000
			When 3 Then PrdWgt/1000 END AS PrdWgt
			Into #PrdWeight  From Product
 --Till Here			
	CREATE TABLE #RptClosingStock
	(
				PrdId		INT,
				PrdDCode     NVARCHAR(200),
				PrdName		NVARCHAR(200),
				MRP		    NUMERIC(38,6),
				RATE        NUMERIC(38,6),
				Qty		    INT,
				TaxPerc     NUMERIC(18,2),
				StockValue	NUMERIC(38,6),
				TaxAmount   NUMERIC(38,6),
				NetAmount   NUMERIC(38,6)				
	)
	SET @TblName = 'RptClosingStock'
	SET @TblStruct = 'PrdId		INT,
	            PrdDCode     NVARCHAR(200),
				PrdName		NVARCHAR(100),
				MRP		    NUMERIC(38,6),
				RATE        NUMERIC(38,6),
				Qty		    INT,
				TaxPerc     NUMERIC(38,6),
				StockValue	NUMERIC(38,6),
				TaxAmount   NUMERIC(38,6),
				NetAmount   NUMERIC(38,6)'
	SET @TblFields = 'PrdId,PrdDCode,PrdName,MRP,RATE,Qty,TaxPerc,StockValue,TaxAmount,NetAmount'
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
	
	EXEC Proc_ClosingStock @Pi_RptID,@Pi_UsrId,@ToDate
	--Added By Sathishkumar Veeramani 2014/11/17 Tax Settings Details
	EXEC Proc_ClosingStockTaxCalCulation
	--Till Here

	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		INSERT INTO #RptClosingStock (PrdId,PrdDCode,PrdName,MRP,RATE,Qty,TaxPerc,StockValue,TaxAmount,NetAmount)
		SELECT DISTINCT T.PrdId,P.PrdDCode,T.PrdName,MRP,CASE @DispValue WHEN 1 THEN T.Sellingrate ELSE ListPrice END,
		SUM(BaseQty),TaxPercentage,SUM((CASE @DispValue WHEN 1 THEN (BaseQty * SellingRate) ELSE (BaseQty*ListPrice) END)) As StockValue,
		SUM((CASE @DispValue WHEN 1 THEN ((BaseQty * SellingRate)*(TaxPercentage/100)) ELSE ((BaseQty*ListPrice)*(TaxPercentage/100)) END)) AS TaxAmount,
		SUM((CASE @DispValue WHEN 1 THEN (BaseQty * SellingRate) + ((BaseQty * SellingRate)*(TaxPercentage/100)) 
		ELSE (BaseQty*ListPrice)+((BaseQty*ListPrice)*(TaxPercentage/100)) END)) As NetAmount
		FROM TempClosingStock T WITH (NOLOCK) INNER JOIN Product P WITH (NOLOCK) ON T.PrdId = P.PrdId
		INNER JOIN ClosingStockProductTaxPercent TS WITH (NOLOCK) ON T.PrdId = TS.PrdId 		
		WHERE (T.CmpId = (CASE @CmpId WHEN 0 THEN T.CmpId ELSE 0 END) OR
		T.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))				
		AND
		(T.LcnId = (CASE @LcnId WHEN 0 THEN T.LcnId ELSE 0 END) OR
			T.LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
		AND
		(T.PrdStatus = (CASE @PrdStatus WHEN 0 THEN T.PrdStatus ELSE -1 END) OR
			T.PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,210,@Pi_UsrId)))
		AND
		(T.BatStatus = (CASE @BatchStatus WHEN 0 THEN T.BatStatus ELSE -1 END) OR
			T.BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,211,@Pi_UsrId)))
		AND
		(T.PrdId = (CASE @PrdCatId WHEN 0 THEN T.PrdId Else 0 END) OR
			T.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND
		(T.PrdId = (CASE @PrdId WHEN 0 THEN T.PrdId Else 0 END) OR
			T.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		AND UsrId=@Pi_UsrId 
		GROUP BY T.PrdId,T.PrdName,MRP,SellingRate,ListPrice,P.PrdDCode,TaxPercentage ORDER BY P.PrdDCode
				IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptClosingStock ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ 'WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
				+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (LcnId = (CASE ' + CAST(@LcnId AS nVarchar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR '
				+ 'LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',22,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN PrdId ELSE 0 END) OR '
				+ 'PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND(PrdId=(CASE @PrdId WHEN 0 THEN PrdId ELSE 0 END) OR'
				+ 'PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdStatus = (CASE ' + CAST(@PrdStatus AS nVarchar(10)) + ' WHEN 0 THEN PrdStatus ELSE -1 END) OR '
				+ 'PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',210,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (BatStatus = (CASE ' + CAST(@BatchStatus AS nVarchar(10)) + ' WHEN 0 THEN BatStatus ELSE -1 END) OR '
				+ 'BatStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',211,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				--+ 'AND TransDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptClosingStock'
				
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
			SET @SSQL = 'INSERT INTO #RptClosingStock ' +
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
	
	
	IF @SupZeroStock=1 
	BEGIN
		--Check for Report Data
		Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock WHERE Qty <> 0
		-- Till Here
	
		SELECT A.PrdId,PrdDCode,PrdName,MRP,MAX(RATE) AS RATE,
		CASE WHEN SUM(Qty)<MAX(ConversionFactor) Then 0 Else SUM(Qty)/MAX(ConversionFactor) End  As BOXES,
		CASE WHEN SUM(Qty)<MAX(ConversionFactor) Then SUM(Qty) Else SUM(Qty)%MAX(ConversionFactor) End  As PKTS,
		TaxPerc,SUM(StockValue) AS StockValue,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount 
		FROM #RptClosingStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId 
	    GROUP BY A.PrdId,PrdName,MRP,PrdDCode,TaxPerc Having SUM(Qty) <> 0 Order By PrdDCode
	    
	    IF EXISTS (SELECT * FROM Sysobjects Where XTYPE = 'U' And name = 'RptClosingStockReportParle_Excel')
		DROP TABLE RptClosingStockReportParle_Excel
		SELECT A.PrdId,PrdDCode,PrdName,MRP,MAX(RATE) AS RATE,
		Case When SUM(Qty)<MAX(ConversionFactor) Then 0 Else SUM(Qty)/MAX(ConversionFactor) End  As BOXES,
		Case When SUM(Qty)<MAX(ConversionFactor) Then SUM(Qty) Else SUM(Qty)%MAX(ConversionFactor) End  As PKTS,
		TaxPerc,SUM(StockValue) AS StockValue,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount
	    INTO RptClosingStockReportParle_Excel FROM #RptClosingStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId 
	    Group By A.PrdId,PrdName,MRP,PrdDCode,TaxPerc Having SUM(Qty) <> 0 Order By PrdDCode
	
	END
	ELSE
	BEGIN
	
		--Check for Report Data
		Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock
		-- Till Here
    
		SELECT A.PrdId,PrdDCode,PrdName,MRP,MAX(RATE) AS RATE,
		Case When SUM(Qty)<MAX(ConversionFactor) Then 0 Else SUM(Qty)/MAX(ConversionFactor) End  As BOXES,
		Case When SUM(Qty)<MAX(ConversionFactor) Then SUM(Qty) Else SUM(Qty)%MAX(ConversionFactor) End  As PKTS,
		TaxPerc,SUM(StockValue) AS StockValue,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount
		FROM #RptClosingStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId 
	    GROUP BY A.PrdId,PrdName,MRP,PrdDCode,TaxPerc ORDER BY PrdDCode
	    IF EXISTS (SELECT * FROM Sysobjects Where XTYPE = 'U' And name = 'RptClosingStockReportParle_Excel')
		DROP TABLE RptClosingStockReportParle_Excel
		SELECT A.PrdId,PrdDCode,PrdName,MRP,MAX(RATE) AS RATE,
		Case When SUM(Qty)<MAX(ConversionFactor) Then 0 Else SUM(Qty)/MAX(ConversionFactor) End  As BOXES,
		Case When SUM(Qty)<MAX(ConversionFactor) Then SUM(Qty) Else SUM(Qty)%MAX(ConversionFactor) End  As PKTS,
		TaxPerc,SUM(StockValue) AS StockValue,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount
	    INTO RptClosingStockReportParle_Excel FROM #RptClosingStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId 
	    GROUP BY A.PrdId,PrdName,MRP,PrdDCode,TaxPerc Order By PrdDCode
	END
	RETURN
END
GO
--Parle Bill Wise Sales Report Report
DELETE FROM RptGroup WHERE RptId = 285
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',285,'BillWiseSalesReportParle','BillWise Sales Report',1
GO
DELETE FROM RptHeader WHERE RptId = 285
INSERT INTO RptHeader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'BillWiseSalesReportParle','BillWise Sales Report',285,'BillWise Sales Report',
'Proc_RptBillWiseSalesReportParle','RptBillWiseSalesReportParle','RptBillWiseSalesReportParle.rpt',''
GO
DELETE FROM RptGridView WHERE RptId = 285
INSERT INTO RptGridView (RptId,RptName,CrystalView,GridView,ExcelView,PDFView)
SELECT 285,'RptBillWiseSalesReportParle.rpt',1,0,1,0
GO
DELETE FROM RptDetails WHERE RptId = 285
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,1,'FromDate',-1,NULL,'','From Date*',NULL,1,NULL,10,0,1,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,2,'ToDate',-1,NULL,'','To Date*',NULL,1,NULL,11,0,0,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,3,'SalesInvoice',-1,NULL,'SalId,SalInvRef,SalInvNo','Bill No...',NULL,1,NULL,14,0,0,'Press F4/Double Click to select Bill No',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,4,'SalesMan',-1,NULL,'SMId,SMCode,SMName','SalesMan...',NULL,1,NULL,1,0,0,'Press F4/Double Click to select Salesman',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,5,'RouteMaster',-1,NULL,'RMId,RMCode,RMName','Route...',NULL,1,NULL,2,0,0,'Press F4/Double Click to select Route',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,6,'Company',-1,NULL,'CmpId,CmpCode,CmpName','Company...',NULL,1,NULL,4,1,0,'Press F4/Double Click to select Company',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,7,'RetailerCategoryLevel',6,'CmpId','CtgLevelId,CtgLevelName,CtgLevelName','Category Level...','Company',1,'CmpId',29,1,0,'Press F4/Double Click to Category Level',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,8,'RetailerCategory',7,'CtgLevelId','CtgMainId,CtgName,CtgName','Category Level Value...','RetailerCategoryLevel',1,'CtgLevelId',30,1,0,'Press F4/Double Click to Category Level Value',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,9,'RetailerValueClass',8,'CtgMainId','RtrClassId,ValueClassName,ValueClassName','Value Classification...','RetailerCategory',1,'CtgMainId',31,1,0,'Press F4/Double Click to select Value Classification',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,10,'Retailer',-1,NULL,'RtrId,RtrCode,RtrName','Retailer Group...',NULL,1,NULL,215,0,0,'Press F4/Double Click to select Retailer Group',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,11,'Retailer',-1,NULL,'RtrId,RtrCode,RtrName','Retailer...',NULL,1,NULL,3,0,0,'Press F4/Double Click to select Retailer',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,12,'Location',-1,NULL,'LcnId,LcnCode,LcnName','Location...',NULL,1,NULL,22,0,0,'Press F4/Double Click to select Location',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,13,'RptFilter',-2,NULL,'FilterId,FilterDesc,FilterDesc','Bill Type...',NULL,1,NULL,17,0,0,'Press F4/Double Click to select Bill Mode',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,14,'RptFilter',-2,NULL,'FilterId,FilterDesc,FilterDesc','Bill Mode...',NULL,1,NULL,33,0,0,'Press F4/Double Click to select Bill Mode',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,15,'RptFilter',-2,'','FilterId,FilterDesc,FilterDesc','Bill Status...','',1,'',192,1,0,'Press F4/Double Click to select Bill Status',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (285,16,'RptFilter',-2,'','FilterId,FilterDesc,FilterDesc','Display Cancelled Bill Value*...','',1,'',193,1,1,'Press F4/Double Click to select Display Cancelled Bill Values',0)
GO
DELETE FROM RptFilter WHERE RptId = 285
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (285,33,2,'Credit')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (285,33,1,'Cash')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (285,17,3,'Van Sales')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (285,17,1,'Order Booking')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (285,17,2,'Ready Stock')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (285,192,1,'Pending')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (285,192,2,'Vehicle Allocation')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (285,192,3,'Cancelled')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (285,192,4,'Delivered')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (285,192,5,'Settled')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (285,193,1,'NO')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (285,193,2,'YES')
GO
DELETE FROM RptFormula WHERE RptId = 285
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,1,'Hd_DistName','TATA Traders',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,2,'PHBillDate','Bill Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,3,'PHBillMode','Bill Mode',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,4,'PHBillNo','Bill Number',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,5,'PHBillType','Bill Type',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,6,'PHCrAdjment','Cr.Adj',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,7,'PHDbAdjment','Db.Adj',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,8,'PHDiscount','Disc',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,9,'PHGrossAmt','Gross Amt',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,10,'PHNetAmt','Net Amt',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,11,'PHReplacement','Rep. Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,12,'PHRtrName','Retailer Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,13,'PHSalesRtn','Sales Return',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,14,'PHSchemeDisc','Sch Disc',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,15,'PHTaxAmt','Tax Amt',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,16,'ValBillMode','Bill Mode',1,33)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,17,'ValBillType','Bill Type',1,17)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,18,'ValFromBillNo','Bill No',1,14)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,19,'ValFromDate','From Date',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,20,'ValRetailer','Retailer',1,3)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,21,'ValRoute','Route',1,2)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,22,'ValSalesman','Salesman',1,1)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,23,'ValToDate','To Date',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,24,'CapBillMode','Bill Mode',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,25,'CapBillType','Bill Type',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,26,'CapFromBillNo','Bill No',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,27,'CapFromDate','From Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,28,'CapRetailer','Retailer',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,29,'CapRoute','Route',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,30,'CapSalesman','Salesman',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,31,'CapToDate','To Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,32,'Cap Page','Page',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,33,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,34,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,35,'Total','Total',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,36,'CatLevel','Category Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,37,'CatVal','Category Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,38,'ValClass','Value Classification',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,39,'Disp_CategoryLevel','CategoryLevel',1,29)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,40,'Disp_CategoryLevelValue','CategoryLevelValue',1,30)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,41,'Disp_ValueClassification','ValueClassification',1,31)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,42,'CapBillStatus','Bill Status',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,43,'CapCancelValue','Display Cancelled Bill Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,44,'ValBillStaus','',1,192)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,45,'ValCancelValue','',1,193)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,46,'Cap_RetailerGroup','Retailer Group',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,47,'Disp_RetailerGroup','Retailer Group',1,215)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,48,'Cap_Company','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,49,'Disp_Company','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,50,'Cap_Location','Location',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (285,51,'Disp_Location','Location',1,22)
GO
DELETE FROM RptExcelHeaders WHERE RptId = 285
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,1,'Bill Number','Bill Number',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,2,'Bill Type','Bill Type',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,3,'Bill Mode','Bill Mode',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,4,'Bill Date','Bill Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,5,'Retailer Code','Retailer Code',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,6,'Retailer Name','Retailer Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,7,'Gross Amount','Gross Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,8,'Scheme Disc','Scheme Disc',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,9,'Sales Return','Sales Return',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,10,'Replacement','Replacement',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,11,'Discount','Discount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,12,'Tax Amount','Tax Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,13,'Credit Adjustment','Credit Adjustment',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,14,'Debit Adjustment','Debit Adjustment',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,15,'WindowDisplay Amount','WindowDisplay Amount',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,16,'Net Amount','Net Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (285,17,'DlvStatus','DlvStatus',0,1)
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCk) WHERE Xtype = 'U' AND Name = 'RptBillWiseSalesReportParle_Excel')  
DROP TABLE RptBillWiseSalesReportParle_Excel
GO
CREATE TABLE RptBillWiseSalesReportParle_Excel  
(  
[Bill Number]         NVARCHAR(50),  
[Bill Type]           NVARCHAR(25),  
[Bill Mode]           NVARCHAR(25),  
[Bill Date]           DATETIME,  
[Retailer Code]       NVARCHAR(50),  
[Retailer Name]       NVARCHAR(150),  
[Gross Amount]        NUMERIC (38,6),  
[Scheme Disc]         NUMERIC (38,6),  
[Sales Return]        NUMERIC (38,6),  
[Replacement]         NUMERIC (38,6),  
[Discount]            NUMERIC (38,6),  
[Tax Amount]          NUMERIC (38,6),  
[WindowDisplayAmount] NUMERIC (38,6),  
[Credit Adjustmant]   NUMERIC (38,6),  
[Debit Adjustment]    NUMERIC (38,6),  
[Net Amount]          NUMERIC (38,6),  
[DlvStatus]           INT  
)
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND Name = 'Proc_RptBillWiseSalesReportParle')
DROP PROCEDURE Proc_RptBillWiseSalesReportParle
GO
---EXEC Proc_RptBillWiseSalesReportParle 285,1,0,'PARLE',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptBillWiseSalesReportParle]  
(  
 @Pi_RptId  INT,  
 @Pi_UsrId  INT,  
 @Pi_SnapId  INT,  
 @Pi_DbName  nvarchar(50),  
 @Pi_SnapRequired INT,  
 @Pi_GetFromSnap  INT,  
 @Pi_CurrencyId  INT  
)  
AS  
/****************************************************************************  
* PROCEDURE  : Proc_RptBillWiseSalesReportParle  
* PURPOSE    : To Generate Sales Bill Wise  
* CREATED BY : Boopathy.P  
* CREATED ON : 30/07/2007  
* MODIFICATION  
*****************************************************************************  
* DATE        AUTHOR      DESCRIPTION  
07/12/2007  MURUGAN.R     Adding Retailer Category  
01-07-2014  Jai Ganesh R  Order By Billdate, Bll Number added in the Final Output
*****************************************************************************/  
SET NOCOUNT ON  
BEGIN  
DECLARE @NewSnapId  AS INT  
DECLARE @DBNAME  AS  nvarchar(50)  
DECLARE @TblName  AS nvarchar(500)  
DECLARE @TblStruct  AS nVarchar(4000)  
DECLARE @TblFields  AS nVarchar(4000)  
DECLARE @sSql  AS  nVarChar(4000)  
DECLARE @ErrNo   AS INT  
DECLARE @PurDBName AS nVarChar(50)  
--Filter Variable  
DECLARE @FromDate AS DATETIME  
DECLARE @ToDate   AS DATETIME  
DECLARE @FromBillNo AS  BIGINT  
DECLARE @TOBillNo   AS  BIGINT  
DECLARE @CmpId      AS  INT  
DECLARE @LcnId      AS  INT  
DECLARE @SMId   AS INT  
DECLARE @RMId   AS INT  
DECLARE @RtrId   AS INT  
DECLARE @BillType    AS INT  
DECLARE @BillMode    AS INT  
DECLARE @CtgLevelId AS  INT  
DECLARE @RtrClassId AS  INT  
DECLARE @CtgMainId  AS  INT  
DECLARE @BillStatus AS INT  
DECLARE @CancelValue AS INT 
DECLARE @SalId AS BIGINT 
--Till Here  
--Assgin Value for the Filter Variable  
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))  
SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))  
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))  
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))  
SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))  
SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
SET @LcnId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  
SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) 
SET @BillType =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,17,@Pi_UsrId))  
SET @BillMode =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,33,@Pi_UsrId))  
SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))  
SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))  
SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))  
SET @BillStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,192,@Pi_UsrId))  
SET @CancelValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,193,@Pi_UsrId))  
--Till Here  
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
--Till Here  
CREATE TABLE #RptBillWiseSalesReportParle  
(  
  [Bill Number]         NVARCHAR(50),  
  [Bill Type]           NVARCHAR(25),  
  [Bill Mode]           NVARCHAR(25),  
  [Bill Date]           DATETIME,  
  [Retailer Name]       NVARCHAR(50),  
  [Gross Amount]        NUMERIC (38,6),  
  [Scheme Disc]         NUMERIC (38,6),  
  [Sales Return]        NUMERIC (38,6),  
  [Replacement]         NUMERIC (38,6),  
  [Discount]            NUMERIC (38,6),  
  [Tax Amount]          NUMERIC (38,6),  
  [Credit Adjustmant]   NUMERIC (38,6),  
  [Debit Adjustment]    NUMERIC (38,6),  
  [Net Amount]          NUMERIC (38,6),  
  [DlvStatus]           INT  
)  
SET @TblName = 'RptBillWiseSalesReportParle'  
SET @TblStruct = '     
  [Bill Number]         NVARCHAR(50),  
  [Bill Type]           NVARCHAR(25),  
  [Bill Mode]           NVARCHAR(25),  
  [Bill Date]           DATETIME,  
  [Retailer Name]       NVARCHAR(50),  
  [Gross Amount]        NUMERIC (38,6),  
  [Scheme Disc]         NUMERIC (38,6),  
  [Sales Return]        NUMERIC (38,6),  
  [Replacement]         NUMERIC (38,6),  
  [Discount]            NUMERIC (38,6),  
  [Tax Amount]          NUMERIC (38,6),  
  [Credit Adjustmant]   NUMERIC (38,6),  
  [Debit Adjustment]    NUMERIC (38,6),  
  [Net Amount]          NUMERIC (38,6),  
  [DlvStatus]           INT'  
SET @TblFields = '[Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
  [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
  [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus]'  
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
IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
   BEGIN  
   
 PRINT @CtgLevelId   
 IF @FromBillNo <> 0 AND @TOBillNo <> 0  
 BEGIN  
 
  IF @CtgLevelId=1  
  BEGIN   
   IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='TempRetailerCategory')  
    BEGIN       
     DROP TABLE TempRetailerCategory  
    END   
    SELECT * INTO TempRetailerCategory FROM RetailerCategory   
     WHERE CtgLinkId IN (SELECT CtgMainId FROM RetailerCategory WHERE CtgLevelId IN (SELECT CtgLevelId FROM RetailerCategoryLevel   
      WHERE CtgLevelId=1) AND CtgMainId=(CASE @CtgMainId WHEN 0 THEN CtgMainId ELSE 0 END) OR  
       CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
    
   INSERT INTO #RptBillWiseSalesReportParle([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
    [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
    [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus])  
   SELECT [Bill Number],[Bill Type],[Bill Mode],[Bill Date],  
      [Retailer Name],[Gross Amount],[Scheme Disc]  
     ,[Sales Return], [Replacement],[Discount],[Tax Amount],[Credit Adjustment]  
     ,[Debit Adjustment],[Net Amount],[DlvSts]  
    FROM view_SalesBillWise A  
   INNER JOIN (  
   SELECT DISTINCT R.Rtrid FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK)  
   ,TempRetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL  
   WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId  
   AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId  
--   AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
--   RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
--   AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
--   RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
   AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
   RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
   AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR  
   RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
     )X On  X.Rtrid=A.RTRId    
     WHERE (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR  
       A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
     AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
       RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
    AND (LcnId=(CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
       LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
         
     AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
       SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
         
     AND ([BillTypeId] =(CASE @BillType WHEN 0 THEN [BillTypeId] ELSE 0 END) OR  
       [BillTypeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,17,@Pi_UsrId)))  
         
     AND ([BillModeId]=(CASE @BillMode WHEN 0 THEN [BillModeId] ELSE 0 END) OR  
       [BillModeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,33,@Pi_UsrId)))
        
     AND (SalId = (CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
					SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
					  
     AND (DlvSts=(CASE @BillStatus WHEN 0 THEN DlvSts ELSE @BillStatus END))   
    
     AND ([Bill Date] BETWEEN @FromDate and @ToDate)  

  END  
        ELSE  
        BEGIN   
   INSERT INTO #RptBillWiseSalesReportParle([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
    [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
    [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus])  
   SELECT [Bill Number],[Bill Type],[Bill Mode],[Bill Date],  
      [Retailer Name],[Gross Amount],[Scheme Disc]  
     ,[Sales Return], [Replacement],[Discount],[Tax Amount],[Credit Adjustment]  
     ,[Debit Adjustment],[Net Amount],[DlvSts]  
    FROM view_SalesBillWise A  
   INNER JOIN (  
   SELECT DISTINCT R.Rtrid FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK)  
   ,RetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL  
   WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId  
   AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId  
   AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
   RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
   AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
   RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
   AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
   RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
   AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR  
   RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
     )X On  X.Rtrid=A.RTRId    
     WHERE (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR  
       A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
     AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
       RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
    AND (LcnId=(CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
       LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
         
     AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
       SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
         
     AND ([BillTypeId] =(CASE @BillType WHEN 0 THEN [BillTypeId] ELSE 0 END) OR  
       [BillTypeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,17,@Pi_UsrId)))  
         
     AND ([BillModeId]=(CASE @BillMode WHEN 0 THEN [BillModeId] ELSE 0 END) OR  
       [BillModeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,33,@Pi_UsrId))) 
       
     AND (SalId = (CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
					SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
					   
     AND (DlvSts=(CASE @BillStatus WHEN 0 THEN DlvSts ELSE @BillStatus END))   
    
     AND ([Bill Date] Between @FromDate and @ToDate)  
    
  END   
 END  
 ELSE  
 BEGIN  
  IF @CtgLevelId=1  
  BEGIN   
   IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='TempRetailerCategory')  
    BEGIN       
     DROP TABLE TempRetailerCategory  
    END   
    SELECT * INTO TempRetailerCategory FROM RetailerCategory   
     WHERE CtgLinkId IN (SELECT CtgMainId FROM RetailerCategory WHERE CtgLevelId IN (SELECT CtgLevelId FROM RetailerCategoryLevel   
      WHERE CtgLevelId=1) AND CtgMainId=(CASE @CtgMainId WHEN 0 THEN CtgMainId ELSE 0 END) OR  
       CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
    
   INSERT INTO #RptBillWiseSalesReportParle([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
    [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
    [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus])  
   SELECT [Bill Number],[Bill Type],[Bill Mode],[Bill Date],  
      [Retailer Name],[Gross Amount],[Scheme Disc]  
     ,[Sales Return], [Replacement],[Discount],[Tax Amount],[Credit Adjustment]  
     ,[Debit Adjustment],[Net Amount],[DlvSts]  
     from view_SalesBillWise A  
   INNER JOIN (  
   SELECT DISTINCT R.Rtrid FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK)  
   ,TempRetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL  
   WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId  
   AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId  
--   AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
--   RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
--   AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
--   RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
   AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
   RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
   AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR  
   RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
     )X On  X.Rtrid=A.RTRId   
    
     WHERE (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR  
       A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
         
     AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
       RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
    AND (LcnId=(CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
       LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
         
     AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
       SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
         
     AND ([BillTypeId] =(CASE @BillType WHEN 0 THEN [BillTypeId] ELSE 0 END) OR  
       [BillTypeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,17,@Pi_UsrId)))  
         
     AND ([BillModeId]=(CASE @BillMode WHEN 0 THEN [BillModeId] ELSE 0 END) OR  
       [BillModeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,33,@Pi_UsrId))) 
       
     AND (SalId = (CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
					SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
										   
     AND ([DlvSts]=(CASE @BillStatus WHEN 0 THEN [DlvSts] ELSE 0 END) OR  
       [DlvSts] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,192,@Pi_UsrId)))  
    
     AND ([Bill Date] Between @FromDate and @ToDate)  
  END   
  ELSE  
  BEGIN   
   INSERT INTO #RptBillWiseSalesReportParle([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
    [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
    [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus])  
   SELECT [Bill Number],[Bill Type],[Bill Mode],[Bill Date],  
      [Retailer Name],[Gross Amount],[Scheme Disc]  
     ,[Sales Return], [Replacement],[Discount],[Tax Amount],[Credit Adjustment]  
     ,[Debit Adjustment],[Net Amount],[DlvSts]  
     from view_SalesBillWise A  
   INNER JOIN (  
   SELECT DISTINCT R.Rtrid FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK)  
   ,RetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL  
   WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId  
   AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId  
   AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
   RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
   AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
   RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
   AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
   RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
   AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR  
   RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
     )X On  X.Rtrid=A.RTRId   
    
     WHERE (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR  
       A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
         
     AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
       RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
    AND (LcnId=(CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
       LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
         
     AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
       SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
         
     AND ([BillTypeId] =(CASE @BillType WHEN 0 THEN [BillTypeId] ELSE 0 END) OR  
       [BillTypeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,17,@Pi_UsrId)))  
         
     AND ([BillModeId]=(CASE @BillMode WHEN 0 THEN [BillModeId] ELSE 0 END) OR  
       [BillModeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,33,@Pi_UsrId)))  
       
     AND (SalId = (CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
					SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
					  
     AND ([DlvSts]=(CASE @BillStatus WHEN 0 THEN [DlvSts] ELSE 0 END) OR  
       [DlvSts] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,192,@Pi_UsrId)))  
    
     AND ([Bill Date] Between @FromDate and @ToDate)  
  END    
 END  
 /*  
    
  For ProductCategory Value and Product Filter  
  R.PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN R.PrdId Else 0 END) OR  
  R.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))  
  AND R.PrdId = (CASE @fPrdId WHEN 0 THEN R.PrdId Else 0 END) OR  
  R.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
 */  
    
 IF LEN(@PurDBName) > 0  
 BEGIN  
  EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT  
    
  SET @SSQL = 'INSERT INTO ##RptBillWiseSalesReportParle ' +  
   '(' + @TblFields + ')' +  
   ' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +  
     
   'WHERE (RtrId = (CASE ' +  CAST(@RtrId AS INTEGER) + ' WHEN 0 THEN RtrId ELSE 0 END) OR  
     RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',3,' + CAST(@Pi_UsrId as INTEGER) +')))  
       
            AND (RMId=(CASE ' + CAST(@RMId AS INTEGER) + ' WHEN 0 THEN RMId ELSE 0 END) OR  
     RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',2,' + CAST(@Pi_UsrId as INTEGER) +')))  
       
            AND (SMId=(CASE '+ CAST(@SMId AS INTEGER) + 'WHEN 0 THEN SMId ELSE 0 END) OR  
     SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',1,' + CAST(@Pi_UsrId as INTEGER) + ')))  
    AND (LcnId=(CASE '+ CAST(@LcnId AS INTEGER) + 'WHEN 0 THEN LcnId ELSE 0 END) OR  
     LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',22,' + CAST(@Pi_UsrId as INTEGER) + ')))  
       
            AND ([BillTypeId] =(CASE ' + CAST(@BillType AS INTEGER) + ' WHEN 0 THEN [BillTypeId] ELSE 0 END) OR  
     [BillTypeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',17,' + CAST(@Pi_UsrId as INTEGER) +')))  
       
            AND ([BillModeId]=(CASE ' + CAST(@BillMode AS INTEGER) + 'WHEN 0 THEN [BillModeId] ELSE 0 END) OR  
     [BillModeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',33,' + CAST(@Pi_UsrId as INTEGER) + ')))  
            AND ([Bill Date] Between ' + @FromDate +' and ' + @ToDate + ')  
            AND (SalId Between ' + @FromBillNo +' and ' + @TOBillNo +')'  
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
    ' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptBillWiseSalesReportParle'  
   
   EXEC (@SSQL)  
   PRINT 'Saved Data Into SnapShot Table'  
     END  
    END  
   END  
ELSE    --To Retrieve Data From Snap Data  
   BEGIN  
 EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,  
   @Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT  
 PRINT @ErrNo  
 IF @ErrNo = 0  
    BEGIN  
  SET @SSQL = 'INSERT INTO #RptBillWiseSalesReportParle ' +  
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
SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptBillWiseSalesReportParle  
-- Till Here  
 IF (@BillStatus=3 AND  @CancelValue=1) OR (@BillStatus=0 AND  @CancelValue=1)  
 BEGIN  
  UPDATE #RptBillWiseSalesReportParle SET [Gross Amount]=0,[Scheme Disc]=0,[Sales Return]=0,[Replacement]=0,[Discount]=0,  
    [Tax Amount]=0,[Credit Adjustmant]=0,[Debit Adjustment]=0,[Net Amount]=0  
    WHERE [DlvStatus]=3  
 END  
 IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID = @Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
 BEGIN  
  IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptBillWiseSalesReportParle_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
  DROP TABLE RptBillWiseSalesReportParle_Excel  
    
  CREATE TABLE RptBillWiseSalesReportParle_Excel  
  (  
  [Bill Number]         NVARCHAR(50),  
  [Bill Type]           NVARCHAR(25),  
  [Bill Mode]           NVARCHAR(25),  
  [Bill Date]           DATETIME,  
  [Retailer Code]       NVARCHAR(50),  
  [Retailer Name]       NVARCHAR(150),  
  [Gross Amount]        NUMERIC (38,6),  
  [Scheme Disc]         NUMERIC (38,6),  
  [Sales Return]        NUMERIC (38,6),  
  [Replacement]         NUMERIC (38,6),  
  [Discount]            NUMERIC (38,6),  
  [Tax Amount]          NUMERIC (38,6),  
  [WindowDisplayAmount] NUMERIC (38,6),  
  [Credit Adjustmant]   NUMERIC (38,6),  
  [Debit Adjustment]    NUMERIC (38,6),  
  [Net Amount]          NUMERIC (38,6),  
  [DlvStatus]           INT  
  )  
    
  INSERT INTO RptBillWiseSalesReportParle_Excel ([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
  [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
  [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus])  
   SELECT  [Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
   [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
   [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus] FROM #RptBillWiseSalesReportParle  Order by [Bill Date],[Bill Number]
   UPDATE RPT SET RPT.[Retailer Code]=R.RtrCode FROM RptBillWiseSalesReportParle_Excel RPT (NOLOCK),Retailer R (NOLOCK),SalesINvoice SI (NOLOCK) 
   WHERE RPT.[Retailer Name]=R.RtrName AND SI.SalInvNo=RPT.[Bill NUmber] AND R.RtrId=SI.RtrId  

   UPDATE RPT SET RPT.[WindowDisplayAmount]=R.[WindowDisplayAmount] FROM RptBillWiseSalesReportParle_Excel RPT (NOLOCK),
   SalesInvoice R (NOLOCK) WHERE RPT.[Bill Number]=R.SalInvNo  
 END   
    DELETE FROM #RptBillWiseSalesReportParle WHERE [Gross Amount]=0 AND [Scheme Disc]=0 AND [Sales Return]=0 AND [Replacement]=0 AND [Discount]=0 AND   
    [Tax Amount]=0 AND [Credit Adjustmant]=0 AND [Debit Adjustment]=0 AND [Net Amount]=0  
 SELECT * FROM #RptBillWiseSalesReportParle  Order by [Bill Date],[Bill Number]
 RETURN  
END
GO
DELETE FROM RptFilter WHERE RptId = 60
INSERT INTO RptFilter (RptId,SelcId,FilterId,FilterDesc)
SELECT 60,73,1,'Line Fill' UNION
SELECT 60,73,2,'Quantity Fill' UNION
SELECT 60,73,3,'Value Fill'
GO
DELETE FROM RptExcelHeaders WHERE RptId = 60
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,1,'CmpId','CmpId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,2,'SMId','SMId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,3,'RMId','RMId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,4,'RtrId','RtrId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,5,'PrdId','PrdId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,6,'SMName','Salesman',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,7,'RMName','Route',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,8,'RtrCode','Retailer Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,9,'RtrName','Retailer',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,10,'PrdName','Product ',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,11,'Received','Order Received',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,12,'Serviced','Order Serviced',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,13,'Type','Type',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (60,14,'QtyFillRatio','Fill Ratio',1,1)
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND Name = 'Proc_QuantityFillRatio')
DROP PROCEDURE Proc_QuantityFillRatio
GO
CREATE PROCEDURE Proc_QuantityFillRatio
(  
	 @Pi_RptId  INT,  
	 @Pi_UserId  INT,  
	 @Pi_TypeId  INT  
)  
AS  
BEGIN  
/*********************************  
* PROCEDURE: Proc_QuantityFillRatio  
* PURPOSE: DISPLAY THE QTYFILL  
* NOTES:  
* CREATED: MAHALAKSHMI.A  
* ON DATE: 15-12-2007  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/  
SET NOCOUNT ON  
	DECLARE @FromDate AS DATETIME  
	DECLARE @ToDate   AS DATETIME  
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UserId)  
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UserId)  
	DELETE FROM TempOrderChange WHERE RptId=@Pi_RptId AND UserId=@Pi_UserId  
	IF @Pi_TypeId = 1 --LineFill  
	BEGIN  
		INSERT INTO TempOrderChange (SalId,ORDERDATE,ORDERNO,CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,  
		PRDNAME,RECEIVED,SERVICED,Type,CTGLEVELID,CTGMAINID,RtrClassId,RptId,UserId)  
		SELECT Distinct A.SalId,ORDERDATE,ORDERNO,CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,
		RTRCODE,PRDNAME,SUM(RECEIVED) AS RECEIVED,SUM(SERVICED) AS SERVICED,Type,CTGLEVELID,CTGMAINID,RtrClassId,RPTID,USERID FROM ( 
		SELECT  DISTINCT 0 AS SalId,C.ORDERDATE,C.ORDERNO,G.CMPID,C.SMID,C.RMID,C.RTRID,H.PRDID,F.SMNAME,D.RMNAME,E.RTRNAME,  
		E.RTRCODE,G.PRDNAME,0 AS RECEIVED,COUNT(DISTINCT H.PRDID) AS SERVICED,1 as Type,RG.CTGLEVELID,  
		RC.CTGMAINID,RV.RtrValueClassId AS RtrClassId,@Pi_RptId AS RptID,@Pi_UserId AS UserID 
		FROM SALESINVOICEPRODUCT A  
		INNER JOIN SALESINVOICEORDERBOOKING H ON A.SalID = H.SalId  
		LEFT OUTER JOIN  ORDERBOOKINGPRODUCTS B ON H.PRDID=B.PRDID  
		AND H.ORDERNO=B.ORDERNO   
		INNER JOIN ORDERBOOKING C ON H.ORDERNO=C.ORDERNO  
		INNER JOIN ROUTEMASTER  D ON C.RMID=D.RMID  
		INNER JOIN RETAILER E ON C.RTRID=E.RTRID  
		INNER JOIN SALESMAN F ON C.SMID=F.SMID  
		INNER JOIN RETAILERVALUECLASSMAP RV ON RV.RtrId=E.RtrId  
		INNER JOIN RETAILERVALUECLASS RC ON RC.RtrClassId=RV.RtrValueClassId  
		INNER JOIN RetailerCategory RG ON RG.CtgMainId=RC.CtgMainId  
		INNER JOIN PRODUCT G ON  H.PRDID=G.PRDID   
		--INNER JOIN PRODUCTBATCH I ON G.PRDID=I.PRDID AND A.PrdId=I.PrdId   
		--AND A.PrdBatId=I.PrdBatId --AND B.PrdID=I.PrdID AND B.PrdBatId=I.PrdBatId   
		--AND H.PrdID=I.PrdID --AND H.PrdBatId=I.PrdBatId  
		WHERE OrderDate BETWEEN @FromDate AND @ToDate    
		GROUP BY A.SalId,C.ORDERDATE,C.ORDERNO,G.CMPID,C.SMID,C.RMID,C.RTRID,H.PRDID,F.SMNAME,ISNULL(A.PrdId,0),  
		D.RMNAME,E.RTRNAME,E.RTRCODE,G.PRDNAME,RG.CTGLEVELID,RC.CTGMAINID,RV.RtrValueClassId  
		UNION 
		SELECT DISTINCT 0 AS SalId,C.ORDERDATE,C.ORDERNO,G.CMPID,C.SMID,C.RMID,C.RTRID,B.PRDID,F.SMNAME,D.RMNAME,E.RTRNAME,  
		E.RTRCODE,G.PRDNAME,COUNT(DISTINCT B.PRDID) AS RECEIVED,0 AS SERVICED,1 as Type,RG.CTGLEVELID,  
		RC.CTGMAINID,RV.RtrValueClassId AS RtrClassId,@Pi_RptId as RptID,@Pi_UserId as UserID 
		FROM  ORDERBOOKINGPRODUCTS B
		INNER JOIN ORDERBOOKING C ON B.ORDERNO=C.ORDERNO  
		INNER JOIN ROUTEMASTER  D ON C.RMID=D.RMID  
		INNER JOIN RETAILER E ON C.RTRID=E.RTRID  
		INNER JOIN SALESMAN F ON C.SMID=F.SMID  
		INNER JOIN RETAILERVALUECLASSMAP RV ON RV.RtrId=E.RtrId  
		INNER JOIN RETAILERVALUECLASS RC ON RC.RtrClassId=RV.RtrValueClassId  
		INNER JOIN RetailerCategory RG ON RG.CtgMainId=RC.CtgMainId  
		INNER JOIN PRODUCT G ON  B.PRDID=G.PRDID   
		--INNER JOIN PRODUCTBATCH I ON G.PRDID=I.PRDID 
		--AND B.PrdID=I.PrdID AND B.PrdBatId=I.PrdBatId   
		WHERE OrderDate  BETWEEN @FromDate AND @ToDate
		--AND B.ORDERNO IN (SELECT ORDERNO FROM SalesInvoiceOrderBooking)
		   GROUP BY C.ORDERDATE,C.ORDERNO,G.CMPID,C.SMID,C.RMID,C.RTRID,B.PRDID,F.SMNAME,ISNULL(b.PrdId,0), 
		D.RMNAME,E.RTRNAME,E.RTRCODE,G.PRDNAME,RG.CTGLEVELID,RC.CTGMAINID,RV.RtrValueClassId  ) A
		GROUP BY SalId,ORDERDATE,ORDERNO,CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,
		RTRCODE,PRDNAME,Type,CTGLEVELID,CTGMAINID,RtrClassId,RPTID,USERID
	END  
	IF @Pi_TypeId = 2 --QtyFill  
	BEGIN  
		INSERT INTO TempOrderChange (SalId,ORDERDATE,ORDERNO,CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,  
		PRDNAME,RECEIVED,SERVICED,[Type],CTGLEVELID,CTGMAINID,RtrClassId,RptId,UserId)  
		SELECT 0 AS SalId,C.OrderDate,C.OrderNo,P.CmpId,S.SMId,RM.RMId,R.RtrId,X.PrdId,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,
		Sum(TotalQty) RECEIVED,SUM(BilledQty) SERVICED, 2 AS [Type],CTGLEVELID,RG.CTGMAINID,RtrClassId,@Pi_RptId AS RptId,@Pi_UserId AS UserId
		FROM 
		(
		SELECT 0 AS SalId,A.OrderNo,Prdid,Prdbatid,BilledQty,TotalQty FROM  OrderBookingProducts A  
		WHERE NOT EXISTS(SELECT OrderNo,Prdid,Prdbatid FROM SALESINVOICEORDERBOOKING B
		WHERE A.OrderNo=B.OrderNo AND A.Prdid=B.Prdid)-- AND A.Prdbatid=B.Prdbatid)
		UNION ALL
		SELECT 0 AS SalId,OrderNo,Prdid,Prdbatid,BilledQty,0 AS TotalQty  
		FROM SALESINVOICEORDERBOOKING A WHERE NOT EXISTS(SELECT OrderNo,Prdid,Prdbatid FROM OrderBookingProducts B
		WHERE A.OrderNo=B.OrderNo AND A.Prdid=B.Prdid)-- AND A.Prdbatid=B.Prdbatid)
		UNION ALL
		SELECT 0 AS SalId,A.OrderNo,A.Prdid,A.Prdbatid,B.BilledQty,A.TotalQty FROM  OrderBookingProducts A  
		INNER JOIN SALESINVOICEORDERBOOKING B ON 
		A.OrderNo=B.OrderNo AND A.Prdid=B.Prdid --AND A.Prdbatid=B.Prdbatid
		) X 
		INNER JOIN OrderBooking C ON X.OrderNO=C.OrderNO
		INNER JOIN Salesman S ON S.SMId = C.SmId
		INNER JOIN RouteMaster RM ON RM.RMId=C.RmId
		INNER JOIN Retailer R ON R.RtrId=C.RtrId
		INNER JOIN Product P ON X.PrdId=P.PrdId
		--INNER JOIN ProductBatch PB ON X.PrdId=PB.PrdId AND X.PrdBatId=PB.PrdBatId
		INNER JOIN RETAILERVALUECLASSMAP RV ON RV.RtrId=R.RtrId  
		INNER JOIN RETAILERVALUECLASS RC ON RC.RtrClassId=RV.RtrValueClassId  
		INNER JOIN RetailerCategory RG ON RG.CtgMainId=RC.CtgMainId  
		WHERE C.OrderDate BETWEEN @FromDate AND @ToDate  
		GROUP BY SalId,C.OrderDate,C.OrderNo,P.CmpId,S.SMId,RM.RMId,R.RtrId,X.PrdId,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,
		CTGLEVELID,RG.CTGMAINID,RtrClassId
	END
	IF @Pi_TypeId=3 -- ADDED BY PRAVEENRAJ.B FOR Value Fill Ratio
	BEGIN
		INSERT INTO TempOrderChange (SalId,ORDERDATE,ORDERNO,CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,  
		PRDNAME,RECEIVED,SERVICED,Type,CTGLEVELID,CTGMAINID,RtrClassId,RptId,UserId)  
				SELECT X.SalId,C.OrderDate,C.OrderNo,P.CmpId,S.SMId,RM.RMId,R.RtrId,X.PrdId,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,
				IsNull(Sum(Received),0) RECEIVED,Isnull(Sum(SIP.PrdGrossAmount),0) SERVICED, 3 AS [Type],CTGLEVELID,RG.CTGMAINID,
				RtrClassId,@Pi_RptId AS RptId,@Pi_UserId AS UserId FROM 
				(
				SELECT A.OrderNo,Prdid,Prdbatid,A.GrossAmount AS Received,0 AS Serviced,0 AS SalId FROM  OrderBookingProducts A  
				WHERE NOT EXISTS(SELECT OrderNo,Prdid,Prdbatid FROM SALESINVOICEORDERBOOKING B
				WHERE A.OrderNo=B.OrderNo AND A.Prdid=B.Prdid) --AND A.Prdbatid=B.Prdbatid)
				UNION ALL
				SELECT OrderNo,Prdid,Prdbatid,0 AS Received,0 AS Serviced,A.SalId 
				FROM SALESINVOICEORDERBOOKING A WHERE NOT EXISTS(SELECT OrderNo,Prdid,Prdbatid FROM OrderBookingProducts B
				WHERE A.OrderNo=B.OrderNo AND A.Prdid=B.Prdid)-- AND A.Prdbatid=B.Prdbatid)
				UNION ALL
				SELECT A.OrderNo,A.Prdid,A.Prdbatid,A.GrossAmount AS Received,0 AS Serviced,B.SalId FROM  OrderBookingProducts A  
				INNER JOIN SALESINVOICEORDERBOOKING B ON 
				A.OrderNo=B.OrderNo AND A.Prdid=B.Prdid-- AND A.Prdbatid=B.Prdbatid
				) X 
				LEFT OUTER JOIN SalesInvoiceProduct SIP ON X.SalId=SIP.SalId AND SIp.PrdId=X.PrdId --AND SIp.PrdBatId=X.PrdBatId
				INNER JOIN OrderBooking C ON X.OrderNO=C.OrderNO
				INNER JOIN Salesman S ON S.SMId = C.SmId
				INNER JOIN RouteMaster RM ON RM.RMId=C.RmId
				INNER JOIN Retailer R ON R.RtrId=C.RtrId
				INNER JOIN Product P ON X.PrdId=P.PrdId
				--INNER JOIN ProductBatch PB ON X.PrdId=PB.PrdId AND X.PrdBatId=PB.PrdBatId
				INNER JOIN RETAILERVALUECLASSMAP RV ON RV.RtrId=R.RtrId  
				INNER JOIN RETAILERVALUECLASS RC ON RC.RtrClassId=RV.RtrValueClassId  
				INNER JOIN RetailerCategory RG ON RG.CtgMainId=RC.CtgMainId  
				WHERE C.OrderDate BETWEEN @FromDate AND @ToDate
				GROUP BY X.SalId,C.OrderDate,C.OrderNo,P.CmpId,S.SMId,RM.RMId,R.RtrId,X.PrdId,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,
				CTGLEVELID,RG.CTGMAINID,RtrClassId
	END  
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND Name = 'Proc_RptQuantityRatioReport')
DROP PROCEDURE Proc_RptQuantityRatioReport
GO
--EXEC Proc_RptQuantityRatioReport 60,1,0,'ParleBug',0,0,1  
CREATE PROCEDURE [dbo].[Proc_RptQuantityRatioReport]
(  
 @Pi_RptId  INT,  
 @Pi_UsrId  INT,  
 @Pi_SnapId  INT,  
 @Pi_DbName  nvarchar(50),  
 @Pi_SnapRequired INT,  
 @Pi_GetFromSnap  INT,  
 @Pi_CurrencyId  INT  
)  
AS  
/************************************************************  
* VIEW : Proc_RptQuantityRatioReport  
* PURPOSE : To get the Order Quantity Details  
* CREATED BY : Mahalakshmi.A  
* CREATED DATE : 17/12/2007  
* NOTE  :  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*************************************************************/  
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
 --Filter Variables  
 DECLARE @FromDate AS DATETIME  
 DECLARE @ToDate   AS DATETIME  
 DECLARE @CmpId   AS INT  
 DECLARE @SMId   AS INT  
 DECLARE @RMId   AS INT  
 DECLARE @RtrId   AS INT  
 DECLARE @PrdCatId AS INT  
 DECLARE @PrdId  AS INT  
 DECLARE @CtgLevelId AS  INT  
 DECLARE @RtrClassId AS  INT  
 DECLARE @CtgMainId  AS  INT  
 DECLARE @TypeId  AS INT  
 ----Till Here  
 --Assgin Value for the Filter Variable  
 SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
 SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
 SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))  
 SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
 SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))  
 SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))  
 SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))  
 SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))  
 SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))  
 SET @TypeId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,73,@Pi_UsrId))  
 EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  
 SET @PrdCatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))  
 SET @PrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
 SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
 EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  
 ---Till Here  
 Create TABLE #RptQuantityRatioReport  
 (  
    CMPID  INT,  
    SMID  INT,  
    RMID  INT,  
    RTRID  INT,  
    PRDID  INT,  
    SMNAME  NVARCHAR(100),  
    RMNAME  NVARCHAR(100),  
    RTRNAME  NVARCHAR(100),  
    RTRCODE  NVARCHAR(100),  
    PRDNAME  NVARCHAR(100),  
    RECEIVED Numeric(18,6),  
    SERVICED Numeric(18,6),  
    Type  INT  
 )  
 SET @TblName = 'RptQuantityRatioReport'  
 SET @TblStruct = ' CMPID  INT,  
    SMID  INT,  
    RMID  INT,  
    RTRID  INT,  
    PRDID  INT,  
    SMNAME  NVARCHAR(100),  
    RMNAME  NVARCHAR(100),  
    RTRNAME  NVARCHAR(100),  
    RTRCODE  NVARCHAR(100),  
    PRDNAME  NVARCHAR(100),  
    RECEIVED Numeric(18,6),  
    SERVICED Numeric(18,6),  
    Type  INT'  
 SET @TblFields = 'CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED,SERVICED,Type'  
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
 UPDATE RptExcelHeaders SET DisplayFlag = 1 WHERE SlNo = 10
 IF @TypeID = 1
 BEGIN
   UPDATE RptExcelHeaders SET DisplayFlag = 0 WHERE SlNo = 10
 END
    
 IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
 BEGIN  
  EXECUTE Proc_QuantityFillRatio @Pi_RptId,@Pi_UsrId,@TypeId  
  IF @TypeID=1  
  BEGIN  
   INSERT INTO #RptQuantityRatioReport (CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED,SERVICED,Type )  
   SELECT DISTINCT CMPID,SMID,RMID,RTRID,'',SMNAME,RMNAME,RTRNAME,RTRCODE,'',SUM(RECEIVED) AS RECEIVED,SUM(SERVICED)AS SERVICED,Type  
    FROM TempOrderChange   
   WHERE  (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR  
     CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
    AND  
    (SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
     SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
    AND  
    (RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
     RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
    AND  
    (CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN CtgLevelId ELSE 0 END) OR  
     CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
    AND  
    (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR  
     RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))   
    AND  
    (RtrClassId=(CASE @RtrClassId WHEN 0 THEN RtrClassId ELSE 0 END) OR  
     RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
    AND  
    (CtgMainID=(CASE @CtgMainId WHEN 0 THEN ctgMainID ELSE 0 END) OR  
     CtgMainID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
    AND   
    (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
    PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
    GROUP BY CMPID,SMID,RMID,RTRID,SMNAME,RMNAME,RTRNAME,RTRCODE,Type  
  END  
  IF @TypeID=2  
  BEGIN  
   INSERT INTO #RptQuantityRatioReport (CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED,SERVICED,Type )  
   SELECT DISTINCT CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED ,SERVICED,Type  
   FROM TempOrderChange   
   WHERE  (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR  
    CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
   AND  
   (SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
    SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
   AND  
   (RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
    RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
   AND  
   (CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN CtgLevelId ELSE 0 END) OR  
    CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
   AND  
   (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR  
    RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))   
   AND  
   (RtrClassId=(CASE @RtrClassId WHEN 0 THEN RtrClassId ELSE 0 END) OR  
    RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
   AND  
   (CtgMainID=(CASE @CtgMainId WHEN 0 THEN ctgMainID ELSE 0 END) OR  
    CtgMainID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
   AND   
   (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
   PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
   GROUP BY CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED,SERVICED,Type  
  END  
IF @TypeID=3 --Value Fill
	INSERT INTO #RptQuantityRatioReport (CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED,SERVICED,Type )  
	SELECT DISTINCT CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED ,SERVICED,Type  
	FROM TempOrderChange   
	WHERE  (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR  
    CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
   AND  
   (SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
    SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
   AND  
   (RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
    RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
   AND  
   (CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN CtgLevelId ELSE 0 END) OR  
    CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
   AND  
   (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR  
    RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))   
   AND  
   (RtrClassId=(CASE @RtrClassId WHEN 0 THEN RtrClassId ELSE 0 END) OR  
    RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
   AND  
   (CtgMainID=(CASE @CtgMainId WHEN 0 THEN ctgMainID ELSE 0 END) OR  
    CtgMainID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
   AND   
   (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
   PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
   GROUP BY CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,RECEIVED,SERVICED,Type 
  IF LEN(@PurDBName) > 0  
  BEGIN  
   EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT  
   SET @SSQL = 'INSERT INTO #RptQuantityRatioReport ' +  
    '(' + @TblFields + ')' +  
    ' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName   
    + 'WHERE BillStatus=1  AND (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '  
    + 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '  
    + 'AND (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '  
    + 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'  
    + 'AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '  
    + 'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'  
    + 'AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '  
    + 'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '  
    + 'AND(CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN CtgLevelId ELSE 0 END) OR'  
    + 'CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters('+  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',29,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'  
    + 'AND(RtrClassId=(CASE @RtrClassId WHEN 0 THEN RtrClassId ELSE 0 END) OR '  
    + 'RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters('+  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',31,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '  
    + 'AND(CtgMainID=(CASE @CtgMainId WHEN 0 THEN ctgMainID ELSE 0 END) OR '  
    + 'CtgMainID in (SELECT iCountid FROM Fn_ReturnRptFilters('+  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',30,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '  
    + 'AND (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR '  
    + 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters('+  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '  
    + 'AND OrderDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''  
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
     ' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptQuantityRatioReport'  
    EXEC (@SSQL)  
    PRINT 'Saved Data Into SnapShot Table'  
   END  
  END  
 END  
 ELSE    --To Retrieve Data From Snap Data  
 BEGIN  
  EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,  
    @Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT  
  PRINT @ErrNo  
  IF @ErrNo = 0  
  BEGIN  
   SET @SSQL = 'INSERT INTO #RptQuantityRatioReport ' +  
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
 DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId  
 INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
 SELECT @Pi_RptId,Count(*) AS RecCount,@ErrNo,@Pi_UsrId FROM #RptQuantityRatioReport  
 -- Till Here  
 --SELECT * FROM #RptQuantityRatioReport  
 --SELECT CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRCODE,RTRNAME,PRDNAME,RECEIVED,SERVICED,Type  
 --FROM #RptQuantityRatioReport  
 -- CHANGES MADE BY MOORTHI  FOR EXCEL COL FILL RATIO
 SELECT CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRCODE,RTRNAME,PRDNAME,RECEIVED,SERVICED,[Type],
 (CASE RECEIVED WHEN 0 THEN 0 ELSE ((SERVICED/RECEIVED)*100) END) AS FillRate  
 FROM #RptQuantityRatioReport 
 RETURN  
END
GO
IF EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND 
B.xtype = 'U' AND B.name = 'Cn2Cs_Prk_Product' AND A.Name = 'BusinessName')
BEGIN
    ALTER TABLE Cn2Cs_Prk_Product ALTER COLUMN BusinessName NVARCHAR(100)
END
GO
IF EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND 
B.xtype = 'U' AND B.name = 'Cn2Cs_Prk_Product' AND A.Name = 'CategoryName')
BEGIN
    ALTER TABLE Cn2Cs_Prk_Product ALTER COLUMN CategoryName NVARCHAR(100)
END
GO
IF EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND 
B.xtype = 'U' AND B.name = 'Cn2Cs_Prk_Product' AND A.Name = 'FamilyName')
BEGIN
    ALTER TABLE Cn2Cs_Prk_Product ALTER COLUMN FamilyName NVARCHAR(100)
END
GO
IF EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND 
B.xtype = 'U' AND B.name = 'Cn2Cs_Prk_Product' AND A.Name = 'GroupName')
BEGIN
    ALTER TABLE Cn2Cs_Prk_Product ALTER COLUMN GroupName NVARCHAR(100)
END
GO
IF EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND 
B.xtype = 'U' AND B.name = 'Cn2Cs_Prk_Product' AND A.Name = 'SubGroupName')
BEGIN
    ALTER TABLE Cn2Cs_Prk_Product ALTER COLUMN SubGroupName NVARCHAR(100)
END
GO
IF EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND 
B.xtype = 'U' AND B.name = 'Cn2Cs_Prk_Product' AND A.Name = 'BrandName')
BEGIN
    ALTER TABLE Cn2Cs_Prk_Product ALTER COLUMN BrandName NVARCHAR(100)
END
GO
IF EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND 
B.xtype = 'U' AND B.name = 'Cn2Cs_Prk_Product' AND A.Name = 'AddHier1Name')
BEGIN
    ALTER TABLE Cn2Cs_Prk_Product ALTER COLUMN AddHier1Name NVARCHAR(100)
END
GO
IF EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND 
B.xtype = 'U' AND B.name = 'Cn2Cs_Prk_Product' AND A.Name = 'AddHier2Name')
BEGIN
    ALTER TABLE Cn2Cs_Prk_Product ALTER COLUMN AddHier2Name NVARCHAR(100)
END
GO
IF EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND 
B.xtype = 'U' AND B.name = 'Cn2Cs_Prk_Product' AND A.Name = 'AddHier3Name')
BEGIN
    ALTER TABLE Cn2Cs_Prk_Product ALTER COLUMN AddHier3Name NVARCHAR(100)
END
GO
IF EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND 
B.xtype = 'U' AND B.name = 'Cn2Cs_Prk_Product' AND A.Name = 'AddHier4Name')
BEGIN
    ALTER TABLE Cn2Cs_Prk_Product ALTER COLUMN AddHier4Name NVARCHAR(100)
END
GO
IF EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND 
B.xtype = 'U' AND B.name = 'Cn2Cs_Prk_Product' AND A.Name = 'AddHier5Name')
BEGIN
    ALTER TABLE Cn2Cs_Prk_Product ALTER COLUMN AddHier5Name NVARCHAR(100)
END
GO
IF EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND 
B.xtype = 'U' AND B.name = 'Cn2Cs_Prk_Product' AND A.Name = 'AddHier6Name')
BEGIN
    ALTER TABLE Cn2Cs_Prk_Product ALTER COLUMN AddHier6Name NVARCHAR(100)
END
GO
IF EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.id = B.id AND 
B.xtype = 'U' AND B.name = 'ProductCategoryValue' AND A.Name = 'PrdCtgValName')
BEGIN
    ALTER TABLE ProductCategoryValue ALTER COLUMN PrdCtgValName NVARCHAR(100)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ValidateProductHierarchyLevelValue' AND XTYPE='P')
DROP PROCEDURE Proc_ValidateProductHierarchyLevelValue
GO
/*
BEGIN TRANSACTION
--SELECT * FROM ETL_Prk_ProductHierarchyLevelValue
--SELECT * FROM ProductCategoryValue
--SELECT * FROM ProductCategoryLevel
EXEC Proc_ValidateProductHierarchyLevelValue 0
SELECT * FROM ErrorLog
--SELECT * FROM ProductCategoryValue WHERE PrdCtgValCode='CA060-2828'
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_ValidateProductHierarchyLevelValue
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_ValidateProductHierarchyLevelValue
* PURPOSE		: To Insert and Update records in the Table ProductCategoryValue
* CREATED		: Nandakumar R.G
* CREATED DATE	: 17/09/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 2010/05/16	Nanda		 Link Code Change from 3 digit to 5 digit			
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist 		AS 	INT
	DECLARE @Tabname 	AS     	NVARCHAR(100)
	DECLARE @DestTabname 	AS 	NVARCHAR(100)
	DECLARE @Fldname 	AS     	NVARCHAR(100)
	
	DECLARE @PrdHierLevelCode 	AS  NVARCHAR(200)
	DECLARE @ParentHierLevelCode 	AS  NVARCHAR(200)
	DECLARE @PrdHierLevelValueCode 	AS  NVARCHAR(200)
	DECLARE @PrdHierLevelValueName 	AS  NVARCHAR(200)
	DECLARE @LevelName 	AS  	NVARCHAR(200)
	DECLARE @ParentLinkCode AS 	NVARCHAR(200)
	DECLARE @NewLinkCode 	AS 	NVARCHAR(200)
	DECLARE @CompanyCode 	AS 	NVARCHAR(200)
	
	DECLARE @Index 		AS 	INT
	DECLARE @CmpId		AS 	INT
	DECLARE @CmpPrdCtgId 	AS 	INT
	DECLARE @PrdCtgMainId 	AS 	INT
	DECLARE @PrdCtgLinkId 	AS 	INT
	DECLARE @PrdCtgLinkCode AS 	NVARCHAR(200)
	DECLARE @TransStr 	AS 	NVARCHAR(4000)
	SET @Po_ErrNo=0
	SET @Exist=0
	
	SET @DestTabname='ProductCategoryValue'
	SET @Fldname='PrdCtgValMainId'
	SET @Tabname = 'ETL_Prk_ProductHierarchyLevelValue'
	SET @Exist=0
	
	DECLARE Cur_ProductHierarchyLevelValue CURSOR
	FOR SELECT ISNULL([Product Hierarchy Level Code],''),ISNULL([Parent Hierarchy Level Value Code],''),
	ISNULL([Product Hierarchy Level Value Code],''),ISNULL([Product Hierarchy Level Value Name],'')
	,ISNULL([Company code],'')
	FROM ETL_Prk_ProductHierarchyLevelValue INNER JOIN ProductCategoryLevel ON
	CmpPrdCtgName = [Product Hierarchy Level Code] ORDER BY LevelName
	OPEN Cur_ProductHierarchyLevelValue
	FETCH NEXT FROM Cur_ProductHierarchyLevelValue INTO @PrdHierLevelCode,@ParentHierLevelCode,
	@PrdHierLevelValueCode,@PrdHierLevelValueName,@CompanyCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Exist=0
		
		IF NOT EXISTS(SELECT * FROM Company WITH (NOLOCK) WHERE CmpCode=@CompanyCode)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@Tabname,'Company',
			'Company Code:'+@CompanyCode+' is not available')
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			
		SELECT @CmpId=CmpId FROM Company WITH (NOLOCK)
			WHERE CmpCode=@CompanyCode
		END
		IF NOT EXISTS(SELECT * FROM ProductCategoryLevel WITH (NOLOCK) WHERE CmpPrdCtgName=@PrdHierLevelCode)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@Tabname,'Product Category Level',
			'Product Category Level:'+@PrdHierLevelCode+' is not available')
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			
		SELECT @CmpPrdCtgId=CmpPrdCtgId,@LevelName=LevelName FROM ProductCategoryLevel WITH (NOLOCK)
			WHERE CmpPrdCtgName=@PrdHierLevelCode AND CmpId=@CmpId
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM ProductCategoryValue WITH (NOLOCK)
			WHERE PrdCtgValCode=@ParentHierLevelCode)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@Tabname,'Parent Category Level',
				'Parent Category Level:'+@ParentHierLevelCode+' is not available')
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @PrdCtgLinkId=ISNULL(PrdCtgValMainId,0) FROM ProductCategoryValue WITH (NOLOCK)
				WHERE PrdCtgValCode=@ParentHierLevelCode
			END
		END	
	
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@PrdHierLevelValueCode))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Hierarvhy Level Value Code',
				'Product Hierarvhy Level Value Code should not be empty')
				SET @Po_ErrNo=1
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@PrdHierLevelValueName))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Hierarvhy Level Value Name',
				'Product Hierarvhy Level Value Name should not be empty')
				SET @Po_ErrNo=1
			END
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF EXISTS(SELECT * FROM ProductCategoryValue WITH (NOLOCK)
			WHERE PrdCtgValCode=@PrdHierLevelValueCode)
			BEGIN
				SET @Exist=1
			END
		
			IF @Exist=0
			BEGIN
				SELECT @PrdCtgMainId=dbo.Fn_GetPrimaryKeyInteger(@DestTabname,@FldName,
				CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			
				SELECT 	@ParentLinkCode=PrdCtgValLinkCode FROM ProductCategoryValue
				WHERE PrdCtgValMainId=@PrdCtgLinkId
	
				SELECT @NewLinkCode=ISNULL(MAX(PrdCtgValLinkCode),0)
				FROM ProductCategoryValue WHERE LEN(PrdCtgValLinkCode)=  Len(@ParentLinkCode)+5
				AND PrdCtgValLinkCode LIKE  @ParentLinkCode +'%' AND CmpPrdCtgId =@CmpPrdCtgId

				SELECT 	@PrdCtgLinkCode=dbo.Fn_ReturnNewCode(@ParentLinkCode,5,@NewLinkCode)
	
				
				IF LEN(@PrdCtgLinkCode)<>(SUBSTRING(@LevelName,6,LEN(@LevelName)))*5
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Product Hierarvhy Level Value',
					'Product Hierarvhy Level is not match with parent level for: '+@PrdHierLevelValueCode)
	
					SET @Po_ErrNo=1
				END
				
				IF @Po_ErrNo=0
				BEGIN
					INSERT INTO ProductCategoryValue
					(PrdCtgValMainId,PrdCtgValLinkId,CmpPrdCtgId,PrdCtgValLinkCode,PrdCtgValCode,PrdCtgValName,
					Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES	(@PrdCtgMainId,
					@PrdCtgLinkId,@CmpPrdCtgId,@PrdCtgLinkCode,@PrdHierLevelValueCode,@PrdHierLevelValueName,
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 			
				
	
					SET @TransStr='INSERT INTO ProductCategoryValue
					(PrdCtgValMainId,PrdCtgValLinkId,CmpPrdCtgId,PrdCtgValLinkCode,PrdCtgValCode,PrdCtgValName,
					Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES	('+
					CAST(@PrdCtgMainId AS NVARCHAR(10))+','+CAST(@PrdCtgLinkId AS NVARCHAR(10))+','+
					CAST(@CmpPrdCtgId AS NVARCHAR(10))+','''+@PrdCtgLinkCode+''','''+@PrdHierLevelValueCode+
					''','''+@PrdHierLevelValueName+''',1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+
					''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
	
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
	
					UPDATE Counters SET CurrValue=@PrdCtgMainId WHERE TabName=@DestTabname AND FldName=@FldName
					SET @PrdCtgLinkCode=''
	
					SET @TransStr='UPDATE Counters SET CurrValue='+
					CAST(@PrdCtgMainId AS NVARCHAR(10))+' WHERE TabName='''+@DestTabname+''' AND FldName='''+@FldName+''''
	
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
				END
			END	
			ELSE
			BEGIN
				UPDATE ProductCategoryValue SET PrdCtgValName=@PrdHierLevelValueName
				WHERE PrdCtgValCode=@PrdHierLevelValueCode
				SET @TransStr='UPDATE ProductCategoryValue SET PrdCtgValName='''+@PrdHierLevelValueName+
				''' WHERE PrdCtgValCode='''+@PrdHierLevelValueCode+''''
				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
			END	
		END

		FETCH NEXT FROM Cur_ProductHierarchyLevelValue INTO @PrdHierLevelCode,@ParentHierLevelCode,
		@PrdHierLevelValueCode,@PrdHierLevelValueName,@CompanyCode
	END
	CLOSE Cur_ProductHierarchyLevelValue
	DEALLOCATE Cur_ProductHierarchyLevelValue
	SET @Po_ErrNo=0
END
GO
DELETE FROM Tbl_DownloadIntegration WHERE ProcessName = 'ProductUnification'
INSERT INTO Tbl_DownloadIntegration
SELECT 51,'ProductUnification','CN2CS_Prk_ProductCodeUnification','Proc_Import_ProductCodeUnification',0,500,CONVERT(NVARCHAR(10),GETDATE(),121)
GO
DELETE FROM CustomUpDownload WHERE Module = 'ProductUnification'
INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile)
SELECT 242,1,'ProductUnification','ProductUnification','Proc_CN2CS_ProductCodeUnification','','CN2CS_Prk_ProductCodeUnification',
'Proc_CN2CS_ProductCodeUnification','Transaction','Download',1
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'U' AND Name = 'CN2CS_Prk_ProductCodeUnification')
DROP TABLE CN2CS_Prk_ProductCodeUnification
GO
CREATE TABLE CN2CS_Prk_ProductCodeUnification
(
	[DistCode]       [NVARCHAR](50) NULL,
	[ProductCode]    [NVARCHAR](200) NULL,
	[ProductName]    [NVARCHAR](200) NULL,
	[MapProductCode] [NVARCHAR](200) NULL,
	[DownLoadFlag]   [NVARCHAR](5) NULL,
	[CreatedDate]    [DATETIME] NULL
)
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND Name = 'Proc_Import_ProductCodeUnification')
DROP PROCEDURE Proc_Import_ProductCodeUnification
GO
CREATE	PROCEDURE Proc_Import_ProductCodeUnification
(
	@Pi_Records TEXT
)
AS
/************************************************************************************************
* PROCEDURE		: Proc_Import_ProductCodeUnification
* PURPOSE		: To Insert records from xml file in the Table CN2CS_Prk_ProductCodeUnification
* CREATED		: Sathishkumar Veeramani
* CREATED DATE	: 18/11/2014
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-------------------------------------------------------------------------------------------------
* {DATE} {DEVELOPER}  {BRIEF MODIFICATION DESCRIPTION}
*************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC SP_XML_PREPAREDOCUMENT @hDoc OUTPUT,@Pi_Records
	INSERT INTO CN2CS_Prk_ProductCodeUnification(DistCode,ProductCode,ProductName,MapProductCode,DownLoadFlag,CreatedDate)
	SELECT DistCode,ProductCode,ProductName,MapProductCode,DownLoadFlag,CreatedDate
	FROM OPENXML (@hdoc,'/Root/Console2CS_ProductCodeUnification',1)
	WITH
	(
		[DistCode] 			NVARCHAR(50),
		[ProductCode]		NVARCHAR(200),
		[ProductName]		NVARCHAR(200),
		[MapProductCode]	NVARCHAR(200),
		[DownLoadFlag]		NVARCHAR(10),
		[CreatedDate]       DATETIME
	) XMLObj
	EXEC sp_xml_removedocument @hDoc
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_CN2CS_ProductCodeUnification' AND xtype='P')
DROP PROCEDURE Proc_CN2CS_ProductCodeUnification
GO
/*
  BEGIN TRANSACTION
  EXEC Proc_CN2CS_ProductCodeUnification 0
  SELECT * FROM Errorlog (NOLOCK)
  SELECT * FROM ProductBatch where PrdId IN (1540,1553)
  SELECT * FROM ProductBatchDetails where PrdBatId IN (29904,29905)
  SELECT * FROM CN2CS_Prk_ProductCodeUnification (NOLOCK) 
  ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_CN2CS_ProductCodeUnification
(
       @Po_ErrNo INT OUTPUT
)
AS
/*****************************************************************************
* PROCEDURE      : Proc_CN2CS_ProductCodeUnification
* PURPOSE        : To Mapped the Sub Products to Main Products
* CREATED BY     : Sathishkumar Veeramani 18-11-2014
* MODIFIED       :
* DATE      AUTHOR     DESCRIPTION
* {DATE} {DEVELOPER}  {BRIEF MODIFICATION DESCRIPTION}
*******************************************************************************/
SET NOCOUNT ON
BEGIN
SET @Po_ErrNo = 0
DECLARE @ToPrdId     AS NUMERIC(18,0)
DECLARE @PrdId       AS NUMERIC(18,0)
DECLARE @PrdBatId    AS NUMERIC(18,0)
DECLARE @ToPrdBatId  AS NUMERIC(18,0)
DECLARE @LcnId       AS BIGINT
DECLARE @SalTotQty   AS NUMERIC(18,0)
DECLARE @UnSalTotQty AS NUMERIC(18,0)
DECLARE @OfferTotQty AS NUMERIC(18,0)
DECLARE @SalQty      AS NUMERIC(18,0)
DECLARE @UnSalQty    AS NUMERIC(18,0)
DECLARE @OfferQty    AS NUMERIC(18,0)
DECLARE @InvDate     AS DATETIME
DELETE FROM CN2CS_Prk_ProductCodeUnification WHERE DownLoadFlag = 'Y'

	CREATE TABLE #ToAvoidProducts
	(
	  ProductCode NVARCHAR(200),
	  MapProductCode NVARCHAR(200)
	)
	
	--Product Validations
	INSERT INTO #ToAvoidProducts (ProductCode,MapProductCode)
	SELECT DISTINCT ProductCode,MapProductCode FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.ProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
	
	INSERT INTO Errorlog (SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'Product','PrdCCode',ProductCode+'-Product Or ProductBatch Not Available' 
	FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.ProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
	
	INSERT INTO #ToAvoidProducts (ProductCode,MapProductCode)
	SELECT DISTINCT ProductCode,MapProductCode FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.MapProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
	
	INSERT INTO Errorlog (SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'Product','PrdCCode',MapProductCode+'-Product Code Not Available' 
	FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.MapProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
	
	--Main Product Code Unique Validation
	INSERT INTO #ToAvoidProducts (ProductCode,MapProductCode)
	SELECT DISTINCT ProductCode,A.MapProductCode FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) INNER JOIN
	(SELECT COUNT(DISTINCT ProductCode) AS Counts,MapProductCode FROM CN2CS_Prk_ProductCodeUnification (NOLOCK)
	GROUP BY MapProductCode HAVING COUNT(DISTINCT ProductCode) > 1)B ON A.MapProductCode = B.MapProductCode
	WHERE DownLoadFlag = 'D'
	
	INSERT INTO Errorlog (SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'CN2CS_Prk_ProductCodeUnification','ProductCode',ProductCode+'-Mapped More than One Products' 
     FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) INNER JOIN
	(SELECT COUNT(DISTINCT ProductCode) AS Counts,MapProductCode FROM CN2CS_Prk_ProductCodeUnification (NOLOCK)
	GROUP BY MapProductCode HAVING COUNT(DISTINCT ProductCode) > 1)B ON A.MapProductCode = B.MapProductCode
	WHERE DownLoadFlag = 'D'
	
	--Unification Product Batch Creation
	SELECT DISTINCT UPrdId AS PrdId,MAX(PrdBatId) AS PrdBatId INTO #ProductUnificationBatchCreation FROM (
	SELECT DISTINCT B.PrdId AS UPrdId,C.PrdId AS MPrdId,D.PrdBatId FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.ProductCode = B.PrdCCode
	INNER JOIN Product C (NOLOCK) ON A.MapProductCode = C.PrdCCode
	INNER JOIN ProductBatch D (NOLOCK) ON C.PrdId = D.PrdId
	WHERE NOT EXISTS (SELECT DISTINCT ProductCode,MapProductCode FROM #ToAvoidProducts E WHERE A.ProductCode = E.ProductCode 
	AND A.MapProductCode = E.MapProductCode) AND NOT EXISTS (SELECT DISTINCT PrdId FROM ProductBatch F (NOLOCK) WHERE B.PrdId = F.PrdId))Qry
	GROUP BY UPrdId
	
	SELECT PrdId,A.PrdBatId,B.PriceId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue INTO #ProductBatchDetails 
	FROM #ProductUnificationBatchCreation A 
	INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatId
	INNER JOIN (SELECT DISTINCT PrdBatId,MAX(PriceId) AS PriceId FROM ProductBatchDetails (NOLOCK) GROUP BY PrdBatId) C 
	ON A.PrdBatId = C.PrdBatId AND B.PrdBatId = C.PrdBatId AND B.PriceId = C.PriceId

	DECLARE @UPrdBatId AS NUMERIC(18,0)
	DECLARE @UPriceId  AS NUMERIC(18,0)
	SELECT @UPrdBatId = ISNULL(MAX(PrdBatId),0) FROM ProductBatch (NOLOCK)
	SELECT @UPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
	
	--To Insert Product Batch
	SELECT DISTINCT A.PrdId,(DENSE_RANK()OVER (ORDER BY A.PrdId ASC)+@UPrdBatId) AS PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,
	TaxGroupId,BatchSeqId,DecPoints,(DENSE_RANK()OVER (ORDER BY A.PrdId ASC)+@UPriceId) AS PriceId,EnableCloning,A.PrdBatId AS UPrdBatId
	INTO #ProductBatch FROM #ProductUnificationBatchCreation A INNER JOIN ProductBatch B (NOLOCK) ON A.PrdBatId = B.PrdBatId
	
	INSERT INTO ProductBatch(PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,[Status],TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,
    EnableCloning,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,1 AS [Status],TaxGroupId,BatchSeqId,DecPoints,PriceId,EnableCloning,
	1,1,GETDATE(),1,GETDATE() FROM #ProductBatch ORDER BY PrdId,PrdBatId
	
	SELECT @UPrdBatId = ISNULL(MAX(PrdBatId),0) FROM ProductBatch (NOLOCK)
	UPDATE Counters SET CurrValue = @UPrdBatId WHERE TabName = 'ProductBatch' AND FldName = 'PrdBatId'
	
	--To Insert Product Batch Details
	INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,Availability,
    LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
    SELECT B.PriceId,B.PrdBatId,PriceCode,A.BatchSeqId,SLNo,PrdBatDetailValue,1,1,1,1,GETDATE(),1,GETDATE(),0
    FROM #ProductBatchDetails A INNER JOIN #ProductBatch B ON A.PrdId = B.PrdId AND A.PrdBatId = B.UPrdBatId ORDER BY B.PrdBatId,B.PriceId,SLNo
    
    SELECT @UPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
    UPDATE Counters SET CurrValue = @UPriceId WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'
    		
	--Mapped Products Stock Posting
	SELECT DISTINCT D.PrdId AS ToPrdId,E.PrdBatId AS ToPrdBatId,A.PrdId,A.PrdBatId,LcnId,(SUM(PrdBatLcnSih)-SUM(PrdBatLcnRessih)) AS SalStock,
	(SUM(PrdBatLcnUih)-SUM(PrdBatLcnResUih)) AS UnSalStock,
	(SUM(PrdBatLcnFre)-SUM(PrdBatLcnResFre)) AS OfferStock INTO #ManualStockPosting FROM ProductBatchLocation A (NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId
	INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
	INNER JOIN Product D (NOLOCK) ON C.ProductCode = D.PrdCCode
	INNER JOIN ProductBatch E (NOLOCK) ON D.PrdId = E.PrdId
	INNER JOIN (SELECT DISTINCT PrdId,MAX(PrdBatId) AS PrdBatId FROM ProductBatch (NOLOCK) GROUP BY PrdId) F ON E.PrdId = F.PrdId AND E.PrdBatId = F.PrdBatId
	WHERE DownLoadFlag = 'D' AND 
	NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts TA WHERE C.ProductCode = TA.ProductCode AND C.MapProductCode = TA.MapProductCode)
	GROUP BY D.PrdId,E.PrdBatId,A.PrdId,A.PrdBatId,LcnId
	HAVING (SUM(PrdBatLcnSih)-SUM(PrdBatLcnRessih))+(SUM(PrdBatLcnUih)-SUM(PrdBatLcnResUih))+(SUM(PrdBatLcnFre)-SUM(PrdBatLcnResFre)) > 0
	ORDER BY D.PrdId,E.PrdBatId,A.PrdId,A.PrdBatId
		
	--Main Product Stock Posting IN
	DECLARE CUR_STOCKADJIN CURSOR
	FOR SELECT ToPrdId,ToPrdBatId,LcnId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalTotStock,
	SUM(UnSalStock) AS UnSalTotStock,SUM(OfferStock) AS OfferTotStock FROM #ManualStockPosting WITH (NOLOCK) 
	GROUP BY ToPrdId,ToPrdBatId,LcnId ORDER BY ToPrdId,ToPrdBatId
	OPEN CUR_STOCKADJIN		
	FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
	WHILE @@FETCH_STATUS = 0
	BEGIN	
	        IF @SalTotQty > 0
	        BEGIN
	            --SALEABLE STOCK IN									
				EXEC Proc_UpdateStockLedger 10,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,0
				EXEC Proc_UpdateProductBatchLocation 1,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,0		
			END
			IF @UnSalTotQty > 0
			BEGIN
			   --UNSALEABLE STOCK IN									
				EXEC Proc_UpdateStockLedger 11,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,0
				EXEC Proc_UpdateProductBatchLocation 2,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,0
			END
			IF @OfferTotQty > 0
			BEGIN
			    --OFFER STOCK IN									
				EXEC Proc_UpdateStockLedger 12,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,0
				EXEC Proc_UpdateProductBatchLocation 3,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,0
			END
					
	FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
	END
	CLOSE CUR_STOCKADJIN
	DEALLOCATE CUR_STOCKADJIN
	--Till Here
	
	--Mapped Product Stock Posting OUT
	DECLARE CUR_STOCKADJOUT CURSOR
	FOR SELECT PrdId,PrdBatId,LcnId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SalStock,UnSalStock,OfferStock 
	FROM #ManualStockPosting WITH (NOLOCK) ORDER BY PrdId,PrdBatId
	OPEN CUR_STOCKADJOUT		
	FETCH NEXT FROM CUR_STOCKADJOUT INTO @PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,@UnSalQty,@OfferQty
	WHILE @@FETCH_STATUS = 0
	BEGIN	
	        IF @SalQty > 0
	        BEGIN
				--SALEABLE STOCK OUT
				EXEC Proc_UpdateStockLedger 13,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,1,0
				EXEC Proc_UpdateProductBatchLocation 1,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,1,0				
			END
			IF @UnSalQty > 0
			BEGIN
				--UNSALEABLE STOCK OUT
				EXEC Proc_UpdateStockLedger 14,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalQty,1,0
				EXEC Proc_UpdateProductBatchLocation 2,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalQty,1,0
			END
			IF @OfferQty > 0
			BEGIN
				--OFFER STOCK OUT
				EXEC Proc_UpdateStockLedger 15,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferQty,1,0
				EXEC Proc_UpdateProductBatchLocation 3,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferQty,1,0
			END
					
	FETCH NEXT FROM CUR_STOCKADJOUT INTO @PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,@UnSalQty,@OfferQty
	END
	CLOSE CUR_STOCKADJOUT
	DEALLOCATE CUR_STOCKADJOUT	
	--Till Here
	
	SELECT DISTINCT A.PrdId,(SUM(PrdBatLcnSih)-SUM(PrdBatLcnRessih)) AS SalStock,(SUM(PrdBatLcnUih)-SUM(PrdBatLcnResUih)) AS UnSalStock,
	(SUM(PrdBatLcnFre)-SUM(PrdBatLcnResFre)) AS OfferStock INTO #FinalStockAvailable FROM ProductBatchLocation A (NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId 
	INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
	WHERE NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts TA WHERE C.ProductCode = TA.ProductCode AND C.MapProductCode = TA.MapProductCode)
	GROUP BY A.PrdId
	HAVING (SUM(PrdBatLcnSih)-SUM(PrdBatLcnRessih))+(SUM(PrdBatLcnUih)-SUM(PrdBatLcnResUih))+(SUM(PrdBatLcnFre)-SUM(PrdBatLcnResFre)) > 0
	
	--Mapped Products and Product Batches are Inactivate Validation
	UPDATE A SET A.PrdCtgValMainId = C.PrdCtgValMainId FROM Product A (NOLOCK) 
	INNER JOIN CN2CS_Prk_ProductCodeUnification B (NOLOCK) ON A.PrdCCode = B.MapProductCode
	INNER JOIN Product C (NOLOCK) ON B.ProductCode = C.PrdCCode
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts C (NOLOCK)
	WHERE B.ProductCode = C.ProductCode AND B.MapProductCode = C.MapProductCode)
	AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable D WHERE A.PrdId = D.PrdId)
	
	UPDATE A SET A.[Status] = 0 FROM ProductBatch A (NOLOCK) INNER JOIN 
	(SELECT PrdId FROM Product B (NOLOCK) INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts D (NOLOCK)
	WHERE C.ProductCode = D.ProductCode AND C.MapProductCode = D.MapProductCode)) B ON A.PrdId = B.PrdId
	AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable E WHERE A.PrdId = E.PrdId) 
	
	UPDATE A SET A.[PrdStatus] = 0 FROM Product A (NOLOCK) INNER JOIN CN2CS_Prk_ProductCodeUnification B (NOLOCK) ON A.PrdCCode = B.MapProductCode
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts C (NOLOCK)
	WHERE B.ProductCode = C.ProductCode AND B.MapProductCode = C.MapProductCode)
	AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable D WHERE A.PrdId = D.PrdId) 
	--Till Here
		
	UPDATE A SET A.DownloadFlag = 'Y' FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.MapProductCode = B.PrdCCode WHERE B.[PrdStatus] = 0 AND A.DownLoadFlag = 'D'
	AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable C WHERE B.PrdId = C.PrdId) AND
	NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts D (NOLOCK) WHERE A.ProductCode = D.ProductCode 
	AND A.MapProductCode = D.MapProductCode)	
	    
	RETURN
END
GO
DELETE FROM RptDetails WHERE RptId = 27
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (27,1,'FromDate',-1,NULL,'','From Date*',NULL,1,NULL,10,0,0,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (27,2,'Todate',-1,NULL,'','To Date*',NULL,1,NULL,11,0,0,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange])
VALUES (27,3,'Company',-1,NULL,'CmpId,CmpCode,CmpName','Company...',NULL,1,NULL,4,1,0,'Press F4/Double click to select Company',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (27,4,'SalesMan',-1,NULL,'SMId,SMCode,SMName','SalesMan...',NULL,1,NULL,1,0,0,'Press F4/Double Click to Select Salesman',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (27,5,'RouteMaster',-1,NULL,'RMId,RMCode,RMName','Route...',NULL,1,NULL,2,0,0,'Press F4/Double Click to Select Route',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (27,6,'Retailer',-1,NULL,'RtrId,RtrCode,RtrName','Retailer...',NULL,1,NULL,3,0,0,'Press F4/Double Click to Select Retailer',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (27,7,'SalesInvoice',-1,NULL,'SalId,SalInvRef,SalInvNo','Bill No...',NULL,1,NULL,14,0,0,'Press F4/Double Click to select Bill No',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (27,8,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc ','Discounts...',NULL,1,NULL,193,1,0,'Press F4/Double Click to select Discounts',0)
GO
DELETE FROM RptFilter WHERE RptId = 27 AND SelcId = 193
INSERT INTO RptFilter 
SELECT 27,193,1,'Distributor Discount' UNION
SELECT 27,193,2,'Cash Discount' UNION
SELECT 27,193,3,'Splecial Discount' UNION
SELECT 27,193,4,'Invoice Level Discount'
GO
DELETE FROM RptFormula WHERE RptId = 27
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,1,'From Date','From Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,2,'FromDate','',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,3,'To Date','To Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,4,'ToDate','',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,5,'Company','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,6,'Company Name','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,7,'SalesMan','SalesMan',1,1)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,8,'SalesMan Name','SalesMan',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,9,'Route','Route',1,2)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,10,'Route Name','Route',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,11,'TaxPercentage','TaxPercentage',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,12,'TaxableAmount','TaxableAmount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,13,'IOTaxType','IOTaxType',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,14,'TaxTag','TaxTag',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,15,'Disp_Retailer','Retailer',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,16,'Fill_Retailer','Retailer',1,3)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,17,'Fill_BillNo','Bill Number',1,14)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,18,'Cap_BillNo','Bill Numbers',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,19,'Fill_Discounts','Discounts',1,193)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,20,'Cap_Discounts','Discounts',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,21,'SchDiscount','Scheme Discounts',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,22,'Discounts','Discounts',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,23,'NetAmount','Net Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (27,24,'GrossAmount','Gross Amount',1,0)
GO
DELETE FROM RptExcelHeaders WHERE RptId = 27
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,1,'SalInvNo','Bill No',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,2,'CmpID','CmpId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,3,'RtrId','RtrId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,4,'RtrName','Retailer Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,5,'RtrTINNO','RtrTINNO',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,6,'InvDate','Date',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,7,'SchDiscount','Scheme Discount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,8,'Discounts','Discounts',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,9,'GrossAmount','Gross Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,10,'NetAmount','Net Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,11,'UsrId','UsrId',0,0)
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'U' AND Name = 'RptRetailerWiseBillWiseVATReport')
DROP TABLE RptRetailerWiseBillWiseVATReport
GO
CREATE TABLE [dbo].[RptRetailerWiseBillWiseVATReport](
	[InvId] [bigint] NULL,
	[RefNo] [nvarchar](100) NULL,
	[InvDate] [datetime] NULL,
	[SmId] [int] NULL,
	[RmId] [int] NULL,
	[RtrId] [int] NULL,
	[Prdid] [int] NULL,
	[PrdBatId] [int] NULL,
	[InvQty] [int] NULL,
	[PrdLSP] [numeric](38, 6) NULL,
	[SchDscAmount] [numeric](38, 6) NULL,
	[DBDscAmount] [numeric](38, 6) NULL,
	[CDDscAmount] [numeric](38, 6) NULL,
	[SplDscAmount] [numeric](38, 6) NULL,
	[InvLvlDscAmount] [numeric](38, 6) NULL,
	[GrossAmount] [numeric](38, 6) NULL,
	[NetAmount] [numeric](38, 6) NULL,
	[CmpId] [int] NULL,
	[TaxPerc] [nvarchar](50) NULL,
	[TaxableAmount] [numeric](38, 6) NULL,
	[IOTaxType] [nvarchar](100) NULL,
	[TaxFlag] [int] NULL,
	[TaxPercent] [numeric](38, 6) NULL,
	[TaxId] [int] NULL,
	[UserId] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND Name = 'Proc_RetailerWiseBillWiseVatReport')
DROP PROCEDURE Proc_RetailerWiseBillWiseVatReport
GO
--EXEC Proc_RetailerWiseBillWiseVatReport '2014-11-20','2014-11-20',1
CREATE PROCEDURE [dbo].[Proc_RetailerWiseBillWiseVatReport] 
( 
	@Pi_FromDate   DATETIME,
	@Pi_ToDate     DATETIME, 
	@Pi_UserId     INT  
)  
/*********************************************************************  
* VIEW         : Proc_RetailerWiseBillWiseVatReport  
* PURPOSE      : To get the Retailer Wise Bill Wise Tax Summary 
* CREATED BY   : Sathishkumar Veeramani  
* CREATED DATE : 20/11/2014  
* NOTE  :  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
----------------------------------------------------------------------  
* {date}        {developer}  {brief modification description}  
**********************************************************************/  
AS  
BEGIN  
    DELETE FROM RptRetailerWiseBillWiseVATReport where UserId IN (0,@Pi_UserId)
    
    --Sales VAT Amount
    SELECT DISTINCT SI.SalId,SI.SalInvNo,SI.SalInvDate,SI.SMId,SI.RMId,SI.RtrId,SIP.PrdId,SIP.PrdBatId,SIP.BaseQty,
    SIP.PrdUnitSelRate,ISNULL(SUM(SIP.PrdSchDiscAmount),0) AS SchDscAmount,ISNULL(SUM(SIP.PrdDBDiscAmount),0) AS DBDscAmount,
    ISNULL(SUM(SIP.PrdCDAmount),0) AS CDDscAmount,ISNULL(SUM(PrdSplDiscAmount),0) AS SplDscAmount,ISNULL(SalInvLvlDisc,0) AS InvLvlDiscAmt,
    ISNULL(SUM(SIP.PrdGrossAmount),0) AS GrossAmount,SalNetAmt,C.CmpId,SPT.TaxPerc,ISNULl(SUM(TaxableAmount),0) AS TaxableAmount,
    ISNULL(SUM(TaxAmount),0) AS TaxAmount,SPT.TaxId   
    INTO #RetailerWiseBillWiseSales FROM SalesInvoice SI (NOLOCK) 
    INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SI.SalId = SIP.SalId
    INNER JOIN SalesInvoiceProductTax SPT (NOLOCK) ON SI.SalId = SPT.SalId AND SIP.SalId = SPT.SalId AND SIP.SlNo = SPT.PrdSlNo
    INNER JOIN Product P (NOLOCK) ON SIP.PrdId = P.PrdId
    LEFT OUTER JOIN Company C (NOLOCK) ON P.CmpId = C.CmpId
    WHERE DlvSts IN (4,5) AND SI.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
    GROUP BY SI.SalId,SI.SalInvNo,SI.SalInvDate,SI.SMId,SI.RMId,SI.RtrId,SIP.PrdId,SIP.PrdBatId,SIP.BaseQty,SIP.PrdUnitSelRate,
    SalInvLvlDisc,SalNetAmt,C.CmpId,SPT.TaxPerc,SPT.TaxId 
    
    --Sales Return VAT amount
    SELECT DISTINCT RH.SalId,SI.SalInvNo,RH.ReturnDate,RH.SMId,RH.RMId,RH.RtrId,RP.PrdId,RP.PrdBatId,RP.BaseQty,
    RP.PrdUnitSelRte,ISNULL(SUM(RP.PrdSchDisAmt),0) AS SchDscAmount,ISNULL(SUM(RP.PrdDBDisAmt),0) AS DBDscAmount,
    ISNULL(SUM(RP.PrdCDDisAmt),0) AS CDDscAmount,ISNULL(SUM(PrdSplDisAmt),0) AS SplDscAmount,ISNULL(RtnInvLvlDisc,0) AS InvLvlDiscAmt,
    ISNULL(SUM(RP.PrdGrossAmt),0) AS GrossAmount,RtnNetAmt,C.CmpId,RPT.TaxPerc,ISNULl(SUM(TaxableAmt),0) AS TaxableAmount,
    ISNULL(SUM(TaxAmt),0) AS TaxAmount,RPT.TaxId   
    INTO #RetailerWiseBillWiseReturn FROM ReturnHeader RH (NOLOCK) 
    INNER JOIN ReturnProduct RP(NOLOCK) ON RH.ReturnID = RP.ReturnID
    INNER JOIN ReturnProductTax RPT (NOLOCK) ON RH.ReturnID = RPT.ReturnID AND RP.ReturnID = RPT.ReturnID AND RP.SlNo = RPT.PrdSlNo
    INNER JOIN Product P (NOLOCK) ON RP.PrdId = P.PrdId
    INNER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId = SI.SalId
    LEFT OUTER JOIN Company C (NOLOCK) ON P.CmpId = C.CmpId
    WHERE RH.[Status] = 0 AND RH.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND RH.InvoiceType = 1 AND RH.ReturnMode = 1
    GROUP BY RH.SalId,SI.SalInvNo,RH.ReturnDate,RH.SMId,RH.RMId,RH.RtrId,RP.PrdId,RP.PrdBatId,RP.BaseQty,RP.PrdUnitSelRte,
    RtnInvLvlDisc,RtnNetAmt,C.CmpId,RPT.TaxPerc,RPT.TaxId
    
    --Return and Replacement
     SELECT RepRefNo INTO #NotDelivered FROM ReplacementHd RH (NOLOCK),SalesInvoice SI (NOLOCK)  
     WHERE RH.SalId>0 AND RH.SalId=SI.SalId AND SI.DlvSts NOT IN (4,5) 
    
  
	 --TAXABLE AMOUNT FOR SALES  
	 INSERT INTO RptRetailerWiseBillWiseVATReport (InvId,RefNo,InvDate,SmId,RmId,RtrId,Prdid,PrdBatId,InvQty,PrdLSP,
	 SchDscAmount,DBDscAmount,CDDscAmount,SplDscAmount,InvLvlDscAmount,GrossAmount,NetAmount,CmpId,TaxPerc,TaxableAmount,  
	 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)
	   
	 SELECT DISTINCT  SalId AS InvId,SalInvNo AS RefNo,SalInvDate AS InvDate,SMId,RMId,RtrId,PrdId,PrdBatId,BaseQty AS InvQty  
	 ,PrdUnitSelRate AS PrdLSP,SUM(SchDscAmount) AS SchDscAmount,SUM(DBDscAmount) AS DBDscAmount,SUM(CDDscAmount) AS CDDscAmount,
	 SUM(SplDscAmount) AS SplDscAmount,InvLvlDiscAmt,SUM(GrossAmount) AS GrossAmount,SalNetAmt,CmpId,  
	 'Taxable Amount '+CAST(LEFT(TaxPerc,4) AS VARCHAR(10))+'%' AS TaxPerc,SUM(TaxableAmount) AS TaxableAmount,  
	 'Sales' AS IOTaxType,0 AS TaxFlag,TaxPerc AS TaxPercent,TaxId,@Pi_UserId AS UserId  
	 FROM #RetailerWiseBillWiseSales GROUP BY SalId,SalInvNo,SalInvDate,SMId,RMId,RtrId,PrdId,PrdBatId,BaseQty,
	 PrdUnitSelRate,InvLvlDiscAmt,SalNetAmt,CmpId,TaxPerc,TaxId HAVING SUM(TaxableAmount) >= 0
	 UNION
	 SELECT DISTINCT  SalId AS InvId,SalInvNo AS RefNo,SalInvDate AS InvDate,SMId,RMId,RtrId,PrdId,PrdBatId,BaseQty AS InvQty  
	 ,PrdUnitSelRate AS PrdLSP,SUM(SchDscAmount) AS SchDscAmount,SUM(DBDscAmount) AS DBDscAmount,SUM(CDDscAmount) AS CDDscAmount,
	 SUM(SplDscAmount) AS SplDscAmount,InvLvlDiscAmt,SUM(GrossAmount) AS GrossAmount,SalNetAmt,CmpId,  
	 'Tax Amount '+CAST(LEFT(TaxPerc,4) AS VARCHAR(10))+'%' AS TaxPerc,SUM(TaxAmount) AS TaxableAmount,  
	 'Sales' AS IOTaxType,1 AS TaxFlag,TaxPerc AS TaxPercent,TaxId,@Pi_UserId AS UserId  
	 FROM #RetailerWiseBillWiseSales GROUP BY SalId,SalInvNo,SalInvDate,SMId,RMId,RtrId,PrdId,PrdBatId,BaseQty,
	 PrdUnitSelRate,InvLvlDiscAmt,SalNetAmt,CmpId,TaxPerc,TaxId HAVING SUM(TaxAmount) >= 0  

	 --TAXABLE AMOUNT FOR SALESRETURN  
	 INSERT INTO RptRetailerWiseBillWiseVATReport (InvId,RefNo,InvDate,SmId,RmId,RtrId,Prdid,PrdBatId,InvQty,PrdLSP,
	 SchDscAmount,DBDscAmount,CDDscAmount,SplDscAmount,InvLvlDscAmount,GrossAmount,NetAmount,CmpId,TaxPerc,TaxableAmount,  
	 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)
	  
	 SELECT DISTINCT SalId AS InvId,SalInvNo AS RefNo,ReturnDate AS InvDate,  
	 SmId,RmId,RtrId,PrdId,PrdBatId,BaseQty AS InvQty,PrdUnitSelRte AS PrdLSP,
	 -1*SUM(SchDscAmount) AS SchDscAmount,-1*SUM(DBDscAmount) AS DBDscAmount,-1*SUM(CDDscAmount) AS CDDscAmount,
	 -1*SUM(SplDscAmount) AS SplDscAmount,-1*InvLvlDiscAmt,-1*SUM(GrossAmount) AS GrossAmount,-1*RtnNetAmt,CmpId,  
	 'Taxable Amount '+CAST(LEFT(TaxPerc,4) AS VARCHAR(10))+'%' AS TaxPerc,-1 * SUM(TaxableAmount) AS TaxableAmount,  
	 'SalesReturn' AS IOTaxType,0 AS TaxFlag,TaxPerc as TaxPercent,TaxId,@Pi_UserId AS UserId  
	 FROM #RetailerWiseBillWiseReturn GROUP BY SalId,SalInvNo,ReturnDate,SmId,RmId,RtrId,PrdId,PrdBatId,BaseQty,
	 PrdUnitSelRte,InvLvlDiscAmt,RtnNetAmt,CmpId,TaxPerc,TaxId HAVING SUM(TaxableAmount) >= 0 
	 UNION
	 SELECT DISTINCT SalId AS InvId,SalInvNo AS RefNo,ReturnDate AS InvDate,  
	 SmId,RmId,RtrId,PrdId,PrdBatId,BaseQty AS InvQty,PrdUnitSelRte AS PrdLSP,
	 -1*SUM(SchDscAmount) AS SchDscAmount,-1*SUM(DBDscAmount) AS DBDscAmount,-1*SUM(CDDscAmount) AS CDDscAmount,
	 -1*SUM(SplDscAmount) AS SplDscAmount,-1*InvLvlDiscAmt,-1*SUM(GrossAmount) AS GrossAmount,-1*RtnNetAmt,CmpId,  
	 'Tax Amount '+CAST(LEFT(TaxPerc,4) AS VARCHAR(10))+'%' AS TaxPerc,-1 * SUM(TaxAmount) AS TaxableAmount,  
	 'SalesReturn' AS IOTaxType,1 AS TaxFlag,TaxPerc as TaxPercent,TaxId,@Pi_UserId AS UserId  
	 FROM #RetailerWiseBillWiseReturn GROUP BY SalId,SalInvNo,ReturnDate,SmId,RmId,RtrId,PrdId,PrdBatId,BaseQty,
	 PrdUnitSelRte,InvLvlDiscAmt,RtnNetAmt,CmpId,TaxPerc,TaxId HAVING SUM(TaxAmount) >= 0 
END
GO
DELETE FROM RptExcelHeaders WHERE RptId = 27
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,1,'SalInvNo','Bill No',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,2,'CmpID','CmpId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,3,'RtrId','RtrId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,4,'RtrName','Retailer Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,5,'RtrTINNO','RtrTINNO',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,6,'InvDate','Date',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,7,'SchDiscount','Scheme Discount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,8,'Discounts','Discounts',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,9,'GrossAmount','Gross Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,10,'NetAmount','Net Amount',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (27,11,'UsrId','UsrId',0,0)
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND Name = 'Proc_RptRtrWiseBillWiseVatReport')
DROP PROCEDURE Proc_RptRtrWiseBillWiseVatReport
GO
--EXEC Proc_RptRtrWiseBillWiseVatReport 27,1,0,'Corestocky',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptRtrWiseBillWiseVatReport]
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
--	@Po_Errno		INT OUTPUT
)
AS
BEGIN
/*********************************
* PROCEDURE: Proc_RptRtrWiseBillWiseVatReport
* PURPOSE: General Procedure
* NOTES:
* CREATED: Jisha Mathew	08-08-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 05/02/2008 Nanda     Date Filter is added
*********************************/
SET NOCOUNT ON
DECLARE @NewSnapId 	AS	INT
DECLARE @DBNAME		AS 	nvarchar(50)
DECLARE @TblName 	AS	nvarchar(500)
DECLARE @TblStruct 	AS	nVarchar(4000)
DECLARE @TblFields 	AS	nVarchar(4000)
DECLARE @sSql		AS 	nVarChar(4000)
DECLARE @ErrNo	 	AS	INT
DECLARE @PurDBName	AS	nVarChar(50)
DECLARE @FromDate		AS	DATETIME
DECLARE @ToDate			AS	DATETIME
DECLARE @CmpId			AS	INT
DECLARE @SMId			AS	INT
DECLARE @RmId			AS	INT
DECLARE @RtrId			AS	INT
DECLARE @EXLFlag		AS	INT
DECLARE @Discounts      AS  INT
DECLARE @SalId          AS  BIGINT

SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RmId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
SET @Discounts =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,193,@Pi_UsrId))
SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
--If Product Category Filter is available
-- EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
-- SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
-- SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
--Till Here
CREATE TABLE #RptRtrWiseBillWiseVatReport
(	
    SalInvNo		NVARCHAR(100),
	CmpId			INT,
	UsrId			INT,
	RtrId			INT,
	RtrName			NVARCHAR(100),
	RtrTINNo		NVARCHAR(100),
	InvDate			DATETIME,
	SchDiscount     NUMERIC(38,6),
	Discounts       NUMERIC(38,6),
	GrossAmount		NUMERIC(38,6),
	TaxPerc			NVARCHAR(100),
	TaxableAmount	NUMERIC (38,6),
	TaxFlag			INT,
	TaxPercent		NUMERIC (38,6),
	NetAmount		NUMERIC(38,6)
)
SET @TblName = 'RptRtrWiseBillWiseVatReport'
SET @TblStruct = '	SalInvNo		nvarchar(100),	
			CmpId			INT,
			UsrId			INT,
			RtrId			INT,
			RtrName			nvarchar(100),
			RtrTINNo		nvarchar(100),
			InvDate			DateTime,
			SchDiscount     NUMERIC(38,6),
			Discounts       NUMERIC(38,6),
	        GrossAmount		NUMERIC(38,6),	        
			TaxPerc			nvarchar(100),
			TaxableAmount		NUMERIC (38,6),
			TaxFlag			INT,
			TaxPercent		NUMERIC (38,6),
			NetAmount		NUMERIC(38,6)'
			
SET @TblFields = 'SalInvNo,CmpId,UsrId,RtrId,RtrName,RtrTINNo,InvDate,SchDiscount,Discounts,GrossAmount,TaxPerc,TaxableAmount,TaxFlag,TaxPercent,NetAmount'
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
IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
BEGIN
--	print @SMId
	EXEC Proc_RetailerWiseBillWiseVatReport @FromDate,@ToDate,@Pi_UsrId
	INSERT INTO #RptRtrWiseBillWiseVatReport (SalInvNo,CmpId,UsrId,RtrId,RtrName,RtrTINNo,InvDate,
	SchDiscount,Discounts,GrossAmount,TaxPerc,TaxableAmount,TaxFlag,TaxPercent,NetAmount)
	
	SELECT 	Tmp.RefNo,Tmp.CmpId,UserId,R.RtrId AS RtrId,R.RtrName AS RtrName,R.RtrTINNo As RtrTINNo,InvDate,
	dbo.Fn_ConvertCurrency(SUM(SchDscAmount),@Pi_CurrencyId),
	dbo.Fn_ConvertCurrency((CASE @Discounts WHEN 0 THEN (SUM(DBDscAmount)+SUM(CDDscAmount)+SUM(SplDscAmount)+InvLvlDscAmount)
	WHEN 1 THEN SUM(DBDscAmount) WHEN 2 THEN SUM(CDDscAmount) WHEN 3 THEN SUM(SplDscAmount) ELSE InvLvlDscAmount END),@Pi_CurrencyId),
    dbo.Fn_ConvertCurrency(SUM(GrossAmount),@Pi_CurrencyId),TaxPerc, dbo.Fn_ConvertCurrency(SUM(TaxableAmount),@Pi_CurrencyId),
    TaxFlag,TaxPercent,dbo.Fn_ConvertCurrency(NetAmount,@Pi_CurrencyId)
	FROM RptRetailerWiseBillWiseVATReport Tmp
	INNER JOIN Retailer R ON  Tmp.RtrId = R.RtrId
	INNER JOIN SalesInvoice SI ON Tmp.InvId = SI.SalId
	WHERE UserId=@Pi_UsrId
		AND(Tmp.CmpId = (CASE @CmpId WHEN 0 THEN Tmp.CmpId ELSE 0 END) OR
		Tmp.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		AND (Tmp.SMId = (CASE @SMId WHEN 0 THEN Tmp.SMId ELSE 0 END) OR
		Tmp.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		AND (Tmp.RMId = (CASE @RMId WHEN 0 THEN Tmp.RMId ELSE 0 END) OR
		Tmp.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
		AND (Tmp.RtrId = (CASE @RtrId WHEN 0 THEN Tmp.RtrId ELSE 0 END) OR
		Tmp.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		AND (Tmp.InvId = (CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
		Tmp.InvId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
		AND IOTaxType in('Sales','SalesReturn')
        AND InvDate BETWEEN @FromDate AND @ToDate
    GROUP BY Tmp.RefNo,Tmp.CmpId,UserId,R.RtrId,R.RtrName,R.RtrTINNo,InvDate,TaxPerc,TaxFlag,TaxPercent,InvLvlDscAmount,NetAmount     
	IF LEN(@PurDBName) > 0
	BEGIN
		SET @SSQL = 'INSERT INTO #RptRtrWiseBillWiseVatReport ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+ ' WHERE UsrId=@Pi_UsrId (Tmp.CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN Tmp.CmpId ELSE 0 END) OR ' +
			' Tmp.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+ '( SmId = (CASE ' + CAST(@SmId AS nVarchar(10)) + ' WHEN 0 THEN SmId Else 0 END) OR ' +
			' SmId in (SELECT iCountid from Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '
			+ ' (Tmp.RmId = (CASE ' + CAST(@RmId AS nVarChar(10)) + ' WHEN 0 THEN Tmp.RmId Else 0 END) OR ' +
			' Tmp.RmId in (SELECT iCountid from Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS  nVarchar(10)) + ',2,' +  CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '
			+ ' (Tmp.RtrId = (CASE ' + CAST(@RtrId AS nVarChar(10)) + ' WHEN 0 THEN Tmp.RtrId Else 0 END) OR ' +
			' Tmp.RtrId in (SELECT iCountid from Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS  nVarchar(10)) + ',2,' +  CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '
			+ ' IOTaxType in ('' Sales '','' SaleReturn '') '+
			'AND InvDate BETWEEN '+CAST(@FromDate AS NVARCHAR(10))+' AND '+CAST(@ToDate AS NVARCHAR(10))
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptRtrWiseBillWiseVatReport'
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
		SET @SSQL = 'INSERT INTO #RptRtrWiseBillWiseVatReport ' +
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
--		SET @Po_Errno = 1
		PRINT 'DataBase or Table not Found'
		RETURN
	   END
END
    --Net Amount Display Last Column
	INSERT INTO #RptRtrWiseBillWiseVatReport (SalInvNo,CmpId,UsrId,RtrId,RtrName,RtrTINNo,InvDate,SchDiscount,Discounts,GrossAmount,
	TaxPerc,TaxableAmount,TaxFlag,TaxPercent,NetAmount)
	SELECT SalInvNo,CmpId,UsrId,RtrId,RtrName,RtrTINNo,InvDate,SchDiscount,Discounts,GrossAmount,'Net Amount',NetAmount,
	ISNULL(MAX(TaxFlag),0)+1 AS TaxFlag,100,NetAmount FROM #RptRtrWiseBillWiseVatReport GROUP BY SalInvNo,CmpId,UsrId,RtrId,RtrName,
	RtrTINNo,InvDate,SchDiscount,Discounts,GrossAmount,NetAmount

	DELETE FROM RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptRtrWiseBillWiseVatReport
	SELECT * FROM #RptRtrWiseBillWiseVatReport Order By SalInvNo

	--SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	SET @EXLFlag = 1
	IF  @EXLFlag=1
	BEGIN	
	
		/******************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @Values NUMERIC(38,6)
		DECLARE  @GrossAmt NUMERIC(38,6)
		DECLARE  @Desc VARCHAR(80)
		DECLARE  @cCmpId BIGINT
		DECLARE  @cRtrId BIGINT
		DECLARE  @SalInvNo NVARCHAR(100)
		DECLARE  @IOTaxType NVARCHAR(100)	
		DECLARE  @TaxFlag INT
		DECLARE  @TaxPercent INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE @Name as NVarchar(1000)
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptRtrWiseBillWiseVatReport_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptRtrWiseBillWiseVatReport_Excel]
		DELETE FROM RptExcelHeaders Where RptId=27 AND SlNo>11
		CREATE TABLE RptRtrWiseBillWiseVatReport_Excel 
		(SalInvNo NVARCHAR(100),CmpId BIGINT,RtrId BIGINT,RtrName NVARCHAR(100),RtrTINNO NVARCHAR(100),InvDate DATETIME,
		SchDiscount NUMERIC(38,6),Discounts NUMERIC(38,6),GrossAmount NUMERIC(38,6),NetAmount NUMERIC(38,6),UsrId INT)
		
		SET @iCnt=12
		DECLARE Crosstab_Cur CURSOR FOR
		SELECT DISTINCT(TaxPerc),TaxPercent,TaxFlag FROM #RptRtrWiseBillWiseVatReport ORDER BY TaxPercent,TaxFlag
		OPEN Crosstab_Cur
			   FETCH NEXT FROM Crosstab_Cur INTO @Column,@TaxPercent,@TaxFlag
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptRtrWiseBillWiseVatReport_Excel ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					EXEC (@C_SSQL)
					PRINT(@C_SSQL)
					SET @iCnt=@iCnt+1
					FETCH NEXT FROM Crosstab_Cur INTO @Column,@TaxPercent,@TaxFlag
				END
		CLOSE Crosstab_Cur
		DEALLOCATE Crosstab_Cur		
		
		--Insert table values
		DELETE FROM RptRtrWiseBillWiseVatReport_Excel
		INSERT INTO RptRtrWiseBillWiseVatReport_Excel (SalInvNo ,CmpId ,RtrId ,RtrName,RtrTINNO,InvDate,
		SchDiscount,Discounts,GrossAmount,NetAmount,UsrId )
		SELECT DISTINCT SalInvNo ,CmpId ,RtrId ,RtrName,RtrTINNO,InvDate,SchDiscount,Discounts,GrossAmount,NetAmount,@Pi_UsrId
				FROM #RptRtrWiseBillWiseVatReport
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT  SalInvNo,CmpId,RtrId,GrossAmount,TaxPerc,TaxableAmount FROM #RptRtrWiseBillWiseVatReport
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @SalInvNo,@cCmpId,@cRtrId,@GrossAmt,@Desc,@Values
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptRtrWiseBillWiseVatReport_Excel SET ['+ @Desc +']= '+ CAST(ISNULL(@Values,0) AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE SalInvNo='''+ CAST(@SalInvNo AS VARCHAR(1000)) + ''' AND CmpId=' + CAST(@cCmpId AS VARCHAR(1000)) + '
					AND RtrId=' + CAST(@cRtrId AS VARCHAR(1000))+'AND GrossAmount='+CAST(@GrossAmt AS VARCHAR(1000))+ ' AND UsrId=' + CAST(@Pi_UsrId AS VARCHAR(10))+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @SalInvNo,@cCmpId,@cRtrId,@GrossAmt,@Desc,@Values
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
				
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptRtrWiseBillWiseVatReport_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptRtrWiseBillWiseVatReport_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/******************************************************************************************************/
	END
RETURN
END
GO
IF EXISTS (SELECT Name FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_SyncValidation')
DROP PROCEDURE Proc_SyncValidation
GO
--EXEC Proc_SyncValidation 0,'',0,0,0,'','',''
CREATE PROCEDURE Proc_SyncValidation
(    
@piTypeId Int,    
@piCode Varchar(100) = '', -- IP Address in Sync Attempt, DistCode in SyncStatus,    
@piVal1 Numeric(18)=0, -- SubTypeId in SyncStatus,    
@piVal2 Numeric(18)=0, -- SyncId in SyncStatus,    
@piVal3 Numeric(18)=0, -- RecCnt in SyncStatus,    
@piVal4 Varchar(100)='',    
@piVal5 Varchar(100)='',    
@piVal6 Varchar(100)=''    
)    
As    
Begin    
 Declare @Sql Varchar(Max)  
 Declare @IntRetVal Int
 IF @piTypeId = 1 -- Distributor Code, Proc_SyncValidation  piTypeId    
 Begin    
  SELECT DistributorCode FROM Distributor WHERE Distributorid=1     
 End    
 IF @piTypeId = 2 -- Upload And Download, Path Proc_SyncValidation  piTypeId    
 Begin    
  SELECT * FROM Configuration WHERE ModuleId In ('DATATRANSFER44','DATATRANSFER45') AND ModuleName='DataTransfer' Order By ModuleId     
 End     
 IF @piTypeId = 3 -- Sync Attempt Validation  Proc_SyncValidation  @piTypeId,@piCode    
 Begin    
  Declare @RetTemp Int
  SET @RetTemp = 1
  IF Not Exists (Select * From SyncStatus (Nolock) Where Syncid = (Select MAX(Syncid) From Sync_Master (Nolock)))
  Begin
	IF Not Exists (Select * From SyncStatus (Nolock) Where SyncStatus = 1 And Syncid = (Select MAX(Syncid) -1 From Sync_Master (Nolock)))
	Begin
		SET @RetTemp = 0		
	End
  End
  IF (@RetTemp = 0)
  Begin
	Select 0
	RETURN
  End
  Set @piCode = (Select Top 1 HostName From Sys.sysprocesses where  status='RUNNABLE' Order By login_time desc)    
  IF ((SELECT Count(*) From SyncAttempt) < 1)    
   BEGIN    
    INSERT INTO SyncAttempt    
    SELECT @piCode,1,Getdate()    
    SELECT 1    
   END     
  ELSE    
   BEGIN    
    IF (SELECT Status From SyncAttempt) = 0    
     BEGIN    
      UPDATE SyncAttempt SET IPAddress = @piCode,Status = 1,StartTime = Getdate()     
      SELECT 1    
     END    
    ELSE    
     BEGIN    
      IF ((SELECT DatedIFf(hh,StartTime,Getdate()) From SyncAttempt) > 1)    
       BEGIN    
          UPDATE SyncAttempt SET IPAddress = @piCode,Status = 1,StartTime = Getdate()     
          SELECT 1    
       END    
      ELSE    
        IF ((SELECT Count(*) From SyncAttempt WHERE IPAddress = @piCode) = 1 )    
         BEGIN    
          UPDATE SyncAttempt SET Status = 1,StartTime = Getdate()     
          SELECT 1    
         END    
        ELSE    
         BEGIN    
          SELECT 0             
         END    
     END    
   END      
 End    
 IF @piTypeId = 4 -- Remove from Redownloadrequest,  Proc_SyncValidation   @piTypeId    
 Begin    
  TRUNCATE TABLE ReDownLoadRequest    
 End    
 IF @piTypeId = 5 -- Sync Process Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
   IF @piVal1 = 1     
   Begin    
    SELECT * FROM Customupdownloadstatus Status WHERE SyncProcess='SyncProcess0' ORDER BY SyncProcess    
   End    
   IF @piVal1 = 2     
   Begin    
    SELECT * FROM Customupdownloadstatus Status WHERE SyncProcess<>'SyncProcess0' ORDER BY SyncProcess    
   End    
 End    
 IF @piTypeId = 6 -- Sync Process Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1     
   Begin    
    SELECT DISTINCT SlNo,SlNo AS SeqNo,Module AS Process,TranType AS [Transaction Type],UpDownload AS [Exchange Type], 0 AS Count     
    FROM Customupdownload ORDER BY SlNo     
   End    
  IF @piVal1 = 2     
   Begin    
    SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM  Customupdownload  WHERE UpDownload='Upload'    
   End    
  IF @piVal1 = 3    
   Begin    
    SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM  Customupdownload  WHERE UpDownload='Download'    
   End    
 End    
 IF @piTypeId = 7 -- Sync Status Validation,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2,@piVal3    
 Begin    
  IF Exists(Select * from SyncStatus Where DistCode = @piCode and SyncId = @piVal2)        
   Begin        
    IF @piVal1 = 1        
       Begin        
      Update SyncStatus Set DPStartTime = Getdate(),DPEndTime = Getdate(),SyncFlag='N' where DistCode = @piCode and SyncId = @piVal2       
       End        
    Else IF @piVal1 = 2        
     Begin        
      Update SyncStatus Set DPEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End    
    IF @piVal1 = 3        
     Begin        
      Update SyncStatus Set UpStartTime = Getdate(),UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 4        
     Begin        
      Update SyncStatus Set UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 5        
     Begin        
      Update SyncStatus Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End        
    Else IF @piVal1 = 6        
     Begin        
      Update SyncStatus Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 7    
     Begin        
      IF @piVal3 = 1    
       Begin    
        Update SyncStatus Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2       
        Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal2         
       End    
     End       
   End        
  Else        
   Begin        
    Delete From SyncStatus Where DistCode = @piCode and SyncStatus = 1  
    IF Not Exists (Select * From  SyncStatus (Nolock))
    Begin  
		Insert into SyncStatus Select @piCode,@piVal2,Getdate(),Getdate(),Getdate(),Getdate(),Getdate(),Getdate(),0,'N'
    End        
    IF @piVal1 = 1        
       Begin        
      Update SyncStatus Set DPStartTime = Getdate(),DPEndTime = Getdate(),SyncFlag='N' where DistCode = @piCode and SyncId = @piVal2       
       End        
    Else IF @piVal1 = 2        
     Begin        
      Update SyncStatus Set DPEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End    
    IF @piVal1 = 3        
     Begin        
      Update SyncStatus Set UpStartTime = Getdate(),UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 4        
     Begin        
      Update SyncStatus Set UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 5        
     Begin        
      Update SyncStatus Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End        
    Else IF @piVal1 = 6        
     Begin        
      Update SyncStatus Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 7    
     Begin        
      IF @piVal3 = 1    
       Begin    
        Update SyncStatus Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2       
        Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal2         
       End    
     End       
   End      
 End    
 IF @piTypeId = 8 -- Select Current SyncId,  Proc_SyncValidation   @piTypeId    
 Begin    
  Select IsNull(MAX(SyncId),0) From SyncStatus    
 End     
 IF @piTypeId = 9 -- Select Syncstatus for this SyncId,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin    
  Select IsNull(Max(SyncStatus),0) From SyncStatus where DistCode = @piCode And syncid = @piVal1 And SyncStatus = 1    
 End      
 IF @piTypeId = 10 -- DB Restoration Concept,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1    
   Begin    
    Select Count(*) From DefendRestore    
   End     
  IF @piVal1 = 2    
   Begin    
    update DefendRestore Set DbStatus = 1,ReqId = 1,CCLockStatus = 1    
   End       
  IF @piVal1 = 3    
   Begin    
    Insert into DefendRestore (AccessCode,LastModDate,DbStatus,ReqId,CCLockStatus)
    Values('',GETDATE(),1,1,1)    
   End     
 End       
 IF @piTypeId = 11 -- AAD & Configuration Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1    
  Begin    
   SELECT * FROM Configuration WHERE ModuleId='BotreeSyncCheck'    
  End     
  IF @piVal1 = 2    
  Begin    
   SELECT * FROM Configuration WHERE ModuleId LIKE 'BotreeSyncErrLog'    
  End       
  IF @piVal1 = 3    
  Begin    
   Select IsNull(Max(FixID),0) from Hotfixlog (NOLOCK)    
  End       
 End       
 IF @piTypeId = 12 -- System Date is less than the Last Transaction Date Validation,  Proc_SyncValidation   @piTypeId    
 Begin    
  SELECT ISNULL(MAX(TransDate),GETDATE()-1) AS TransDate FROM StockLedger    
 End     
 IF @piTypeId = 13 -- DayEnd Process Updation,  Proc_SyncValidation   @piTypeId,@piCode    
 Begin    
  UPDATE DayEndProcess SET NextUpDate=@piCode WHERE ProcId=13    
 End     
 IF @piTypeId = 14 -- Update Sync Attempt Status ,  Proc_SyncValidation   @piTypeId,@piCode    
 Begin    
  Select @piCode =  HostName From Sys.sysprocesses where  status='RUNNABLE'    
  Update SyncAttempt Set Status=0 where IPAddress = @piCode    
 End      
 IF @piTypeId = 15 -- Latest SyncId from Sync_Master ,  Proc_SyncValidation   @piTypeId    
 Begin    
  Select ISNull(Max(SyncId),0) From Sync_Master    
 End     
 IF @piTypeId = 16 -- Update the Flag as Y for all lesser than the latest Serial No ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
	 IF ((Select ISNULL(Min(SlNo),0) From CS2Console_Consolidated (Nolock) Where DistCode = @piCode And SyncId = @piVal1 And SlNo <= @piVal2 And UploadFlag='N') > 0)        
	  Begin        
	   Update CS2Console_Consolidated Set UploadFlag='N' Where DistCode = @piCode and SyncId = @piVal1 And SlNo >=   
	   (Select ISNULL(Min(SlNo),0) From CS2Console_Consolidated (Nolock) Where DistCode = @piCode And SyncId = @piVal1 And SlNo <= @piVal2 And UploadFlag='N')         
	  End        
	  Else        
	  Begin        
	   Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal1 And SlNo <= @piVal2 
	   Update CS2Console_Consolidated Set UploadFlag='N' Where DistCode = @piCode and SyncId = @piVal1 And SlNo > @piVal2    
	  End 
 End      
 IF @piTypeId = 17 -- Record Count ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
  IF @piVal1 = 1     
  Begin    
   Select Count(*) From CS2Console_Consolidated where DistCode = @piCode and syncid =@piVal2 and UploadFlag = 'N'    
  End    
  IF @piVal1 = 2     
  Begin    
   Select Count(Distinct Slno) From CS2Console_Consolidated where DistCode = @piCode and syncid =@piVal2     
  End       
  IF @piVal1 = 3     
  Begin    
   Select IsNull(Count(*),0) From SyncStatus (Nolock) Where DistCode = @piCode And SyncId = @piVal2 And SyncFlag = 'Y'     
  End    
 End      
 IF @piTypeId = 18 -- Datapreperation Process and Split each 1000 rows for xml file ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
  IF @piVal1 = 1     
  Begin    
   SELECT * FROM  CustomUpDownload  WHERE SlNo=@piVal2  AND UpDownload='Upload' ORDER BY UpDownLoad,SlNo,SeqNo    
  End    
  IF @piVal1 = 2     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UploadFlag=''N'''    
   Exec (@Sql)    
  End       
  IF @piVal1 = 3    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MIN(SlNo),0) AS SlNo FROM  ' + Convert(Varchar(100),@piCode) + ' WHERE UploadFlag=''N'''    
   Exec (@Sql)    
  End        
  IF @piVal1 = 4    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT * FROM  ' + Convert(Varchar(100),@piCode) + ' WHERE  SlNo= ' + Convert(Varchar(100),@piVal2) + '  ORDER BY UpDownLoad,SlNo,SeqNo '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 5    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM   ' + Convert(Varchar(100),@piCode) + '  '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 6    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' DELETE  FROM   ' + Convert(Varchar(100),@piCode) + ' WHERE Downloadflag = ''D'' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 7    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) FROM   ' + Convert(Varchar(100),@piCode) + ' WHERE DownloadFlag = ''D'' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 8    
  Begin    
   Set @Sql = ''    
  Set @Sql = @Sql + ' SELECT TRowCount FROM Tbl_DownloadIntegration_Process WHERE PrkTableName =''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End      
  IF @piVal1 = 9    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Update Tbl_DownloadIntegration_Process Set TRowCount = 0  WHERE ProcessName=''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 10    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Update Tbl_DownloadIntegration_Process Set TRowCount = ' + Convert(Varchar(100),@piVal2) + ' where ProcessName=''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 11     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MAX(SlNo),0) AS Cnt FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'''    
   Exec (@Sql)    
  End       
  IF @piVal1 = 12     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MIN(SlNo),0) AS SlNo FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'''    
   Exec (@Sql)    
  End      
  IF @piVal1 = 13     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'' '    
   Exec (@Sql)    
  End      
  IF @piVal1 = 14     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UpDownload=''Upload'' '    
   Exec (@Sql)    
  End         
  IF @piVal1 = 15     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(DISTINCT SlNo) AS DownloadCount FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UpDownload=''Download'' '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 16     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Select DistCode +''-eertoB-''+ CONVERT(Varchar(10),SyncID)  From SyncStatus (nolock) Where DistCode =''' + Convert(Varchar(100),@piCode) + ''' And  SyncStatus = 0 '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 17     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Select DistCode +''-eertoB-''+ CONVERT(Varchar(10),SyncID)  From SyncStatus_Download (nolock) Where DistCode =''' + Convert(Varchar(100),@piCode) + ''' And  SyncStatus = 0 '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 18
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' SELECT * FROM ' + Convert(Varchar(100),@piCode) + ' As DU WHERE UploadFlag=''N'' AND SlNo BETWEEN  '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' ORDER BY SlNo  FOR XML AUTO '
		Select @Sql
	End	
  IF @piVal1 = 19
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''X'' WHERE UploadFlag=''N'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	
  IF @piVal1 = 20
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''Y'' WHERE UploadFlag=''X'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	
  IF @piVal1 = 21
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''N'' WHERE UploadFlag=''X'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	  
 End      
 IF @piTypeId = 19 -- View Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin    
  SELECT * FROM ErrorLog WITH (NOLOCK)    
 End    
 IF @piTypeId = 20 -- Remove Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin     
  DELETE FROM ErrorLog     
 End     
 IF @piTypeId = 21 -- Download Notification Details Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM  CustomUpDownloadCount WHERE UpDownload='Download' ORDER BY SlNo    
 End     
 IF @piTypeId = 22 -- Download Details to xml file ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Cs2Cn_Prk_DownloadedDetails WHERE UploadFlag='N'    
 End     
 IF @piTypeId = 23 -- Download Integration Details  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_DownloadIntegration_Process ORDER BY SequenceNo    
 End     
 IF @piTypeId = 24 -- Reset TRow Count  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  UPDATE Tbl_DownloadIntegration_Process SET TRowCount=0    
 End      
 IF @piTypeId = 25 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT PrkTableName,SPName FROM Tbl_DownloadIntegration_Process WHERE ProcessName = @piCode    
 End      
 IF @piTypeId = 26 -- Upload Consolidated Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_UploadIntegration_Process ORDER BY SequenceNo    
 End      
 IF @piTypeId = 27 -- Download Details   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT DISTINCT Module,DownloadedCount FROM CustomUpDownloadCount WHERE UpDownload='Download' AND DownloadedCount>0    
 End      
 IF @piTypeId = 28 -- ReDownload Request   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Configuration WHERE ModuleId='BotreeReDownload'    
 End     
 IF @piTypeId = 29 -- ReDownload Request   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM ReDownLoadRequest    
 End     
 IF @piTypeId = 30 -- Showboard    ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Configuration WHERE ModuleId='BotreeBBOardOnSync' AND Status=1    
 End     
 IF @piTypeId = 31 -- Update sync status if disconnect    ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin     
  IF Not Exists (Select * From CS2Console_Consolidated (nolock) Where DistCode = @piCode And Syncid = @piVal1 And UploadFlag='N')    
  Begin    
   Update Syncstatus Set Syncstatus = 1 Where DistCode = @piCode And Syncid = @piVal1    
   Select IsNull(Max(SyncStatus),0) From SyncStatus (nolock) Where DistCode = @piCode And Syncid = @piVal1    
  End    
 End     
 IF @piTypeId = 32 -- Update sync status if disconnect,Proc_SyncValidation @piTypeId,@piCode,@piVal1    
 Begin     
  Declare @RETVAL Varchar(Max)    
  Set @RETVAL = ''    
  IF EXISTS (Select * From Chk_MainSalesIMEIUploadCnt (NOLOCK))    
  Begin      
  Select @RETVAL = Cast(COALESCE(@RETVAL + ', ', '') + Convert(Varchar(40),MainTblBillNo) as ntext) From Chk_MainSalesIMEIUploadCnt       
  Select @RETVAL    
  End    
 End    
 IF @piTypeId = 33 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
   Select 'Request given for approval so please approve from Central Help Desk.'      
 End      
 IF @piTypeId = 34 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
   Select IsNull(LTrim(RTrim(CmpCode)),'') From Company (Nolock) Where DefaultCompany = 1      
 End      
 IF @piTypeId = 35 -- Select Download Sync status  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin       
  Select IsNull(SyncStatus,0) from Syncstatus_Download (nolock) Where Distcode = @picode and Syncid = @pival1    
 End      
 IF @piTypeId = 36 -- Select Max(Syncid) in Download Sync Status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
  Select IsNull(Max(SyncId),0) From SyncStatus_Download (Nolock)    
 End      
 IF @piTypeId = 37 -- Select Max(SlNo) in Console2CS_Consolidated  ,  Proc_SyncValidation   @piTypeId      
 Begin       
  Select IsNull(Max(SlNo),0) From Console2CS_Consolidated (Nolock) Where Distcode = @picode and Syncid = @pival1    
 End       
 IF @piTypeId = 38 -- Syncstatus  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin       
 Declare @RetState Int    
 IF Exists (Select * From SyncStatus (Nolock) where DistCode = @piCode And syncid = @piVal1 And SyncStatus = 1)    
  Begin    
	If (Select Count(1) from SyncStatus_Download_Archieve (Nolock) Where SyncId > 0) > 0
	 Begin
		IF Exists (Select * From SyncStatus_Download (Nolock) where DistCode = @piCode And syncid = @piVal2 And SyncStatus = 1)    
		 Begin    
		  Set @RetState = 1 -- Upload and Download Completed Successfully        
		 End    
		Else    
		 Begin    
		  Set @RetState = 2 -- Upload Completed, Download Incomplete     
		 End    
	 End
	Else
	 Begin
		Set @RetState = 1 -- Upload and Download Completed Successfully 
	 End
  End    
  Else    
  Begin    
  	If (Select Count(1) from SyncStatus_Download_Archieve (Nolock) Where SyncId > 0) > 0
	 Begin
  		IF Exists (Select * From SyncStatus_Download (Nolock) where DistCode = @piCode And syncid = @piVal2 And SyncStatus = 1)    
		 Begin    
		  Set @RetState = 3 -- Upload Incomplete, Download Completed Successfully          
		 End    
		Else    
		 Begin    
		  Set @RetState = 4 -- Upload and Download Incomplete!!!           
		 End    
	 End
	Else
	 Begin
		Set @RetState = 3 -- Upload Incomplete, Download Completed Successfully 
	 End
  End    
  Select @RetState    
 End       
 IF @piTypeId = 39 -- Update Download Sync Status  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2,@piVal3      
 Begin       
 -------    
  IF Exists(Select * from SyncStatus_Download Where DistCode = @piCode and SyncId = @piVal2)                
   Begin                
    IF @piVal1 = 1                
    Begin              
     IF Exists(Select * From Console2CS_Consolidated (Nolock) Where DistCode = @piCode and SyncId = @piVal2)        
     Begin        
     Delete A From Console2CS_Consolidated A (Nolock)  Where DistCode = @piCode and SyncId = @piVal2        
     End 
    Update SyncStatus_Download Set SyncStatus=0,SyncFlag=0 Where DistCode = @piCode and SyncId = @piVal2   -- Added to Parameter S       
    Update SyncStatus_Download Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2              
    End                
    IF @piVal1 = 2                
     Begin                
    Update SyncStatus_Download Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2               
     End            
    IF @piVal1 = 3                
     Begin                
     IF (@piVal3 = (Select COUNT(Distinct SlNo) From Console2CS_Consolidated (nolock) Where DistCode = @piCode and SyncId = @piVal2 And DownloadFlag='N'))          
      Begin          
    Update SyncStatus_Download Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2             
      End         
     Else      
      Begin          
    Delete A From Console2CS_Consolidated A (Nolock)  Where DistCode = @piCode and SyncId = @piVal2             
      End        
     End             
   End                
  Else                
   Begin                
    Insert into SyncStatus_Download_Archieve  Select *,Getdate() from SyncStatus_Download Where DistCode = @piCode           
    Delete From SyncStatus_Download Where DistCode = @piCode               
    Insert into SyncStatus_Download Select @piCode,@piVal2,Getdate(),Getdate(),0,0                
    Insert into SyncStatus_Download_Archieve Select @piCode,@piVal2,Getdate(),Getdate(),0,0,GETDATE()                 
    IF @piVal1 = 1                
    Begin                
    Update SyncStatus_Download Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2              
    End                
    IF @piVal1 = 2                
     Begin                
    Update SyncStatus_Download Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2               
     End            
    IF @piVal1 = 3                
     Begin                
     IF (@piVal3 = (Select COUNT(Distinct SlNo) From Console2CS_Consolidated (nolock) Where DistCode = @piCode and SyncId = @piVal2 And DownloadFlag='N'))          
      Begin          
    Update SyncStatus_Download Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2             
      End         
     Else      
      Begin          
    Delete A From Console2CS_Consolidated A (Nolock) Where DistCode = @piCode and SyncId = @piVal2             
      End         
     End             
   End      
 ------    
 END      
  IF @piTypeId = 40 -- Download Integration Details  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_Customdownloadintegration ORDER BY SequenceNo    
 End     
 IF @piTypeId = 41 -- Reset TRow Count  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  UPDATE Tbl_Customdownloadintegration SET TRowCount=0    
 End 
 IF @piTypeId = 42 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT PrkTableName,SPName FROM Tbl_Downloadintegration WHERE ProcessName = @piCode    
 End 
 IF @piTypeId = 43 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT TRowCount FROM Tbl_Customdownloadintegration WHERE PrkTableName = @piCode    
 End 
 IF @piTypeId = 44 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  Update Tbl_Customdownloadintegration Set TRowCount = @piVal1 WHERE ProcessName = @piCode    
 End 
 IF @piTypeId = 45 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId  
 Begin   
	Set @IntRetVal = 0  
	IF @piVal1 = 1
	Begin
		If Exists (Select * From sys.Objects where TYPE='U' and name ='UtilityProcess')  
		 Begin  
		  IF Exists (Select * from UtilityProcess where ProcId = 3)  
		  Begin  
		   IF ((Select Convert(Varchar(100),VersionId) from UtilityProcess where ProcId = 3) <> @piCode)  
		   Begin  
			Set @IntRetVal = 1      
		   End     
		  End  
		 End  
	End   
	IF @piVal1 = 2
	Begin
		If Not Exists (Select * From AppTitle (Nolock) Where  SynVersion = @piCode)  
		 Begin  
			Set @IntRetVal = 1
		 End
	End
	Select @IntRetVal 
 End  	
 IF @piTypeId = 46 -- Data Purge  ,  Proc_SyncValidation   @piTypeId  
 Begin  
	Set @IntRetVal = 1
	IF EXISTS (Select * From Sys.objects Where name = 'DataPurgeDetails' and TYPE='U')
	Begin
		IF EXISTS (SELECT * FROM DataPurgeDetails WHERE [Status] = 1)
		Begin
			Set @IntRetVal = 0
		End
	End
	Select @IntRetVal	
 End
 IF @piTypeId = 47 -- Update In Active Distributor  ,  Proc_SyncValidation   @piTypeId  
 Begin  
	Set @IntRetVal = 1
	--IF Exists (Select * From Sys.objects Where name = 'Distributor' and TYPE='U')
	--Begin
	--	Update Distributor Set DistStatus = 0 Where DistributorCode = @piCode
	--End
 END
----------Additional Validation----------    
------------------------------------------    
END
GO
IF EXISTS(SELECT* FROM SYSOBJECTS WHERE NAME ='Proc_RptIOTaxSummary' AND XTYPE='P')
DROP PROCEDURE Proc_RptIOTaxSummary
GO
--EXEC Proc_RptIOTaxSummary 11,1,0,'Corestocky',0,0,1,0
CREATE PROCEDURE [Proc_RptIOTaxSummary]
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
BEGIN
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_RptIOTaxSummary
* PURPOSE: General Procedure
* NOTES:
* CREATED: Jisha Mathew	30-07-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
DECLARE @NewSnapId	 	AS	INT
DECLARE @DBNAME			AS 	nvarchar(50)
DECLARE @TblName	 	AS	nvarchar(500)
DECLARE @TblStruct 		AS	nVarchar(4000)
DECLARE @TblFields	 	AS	nVarchar(4000)
DECLARE @sSql			AS 	nVarChar(4000)
DECLARE @ErrNo	 		AS	INT
DECLARE @PurDBName		AS	nVarChar(50)
DECLARE @FromDate		AS	DATETIME
DECLARE @ToDate			AS	DATETIME
DECLARE @CmpId			AS	INT
DECLARE @fPrdCatPrdId		AS	Int
DECLARE @fprdId 		AS	INT
DECLARE @EXLFlag		AS	INT
SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
--If Product Category Filter is available
EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
--Till Here
Create TABLE #RptIOTaxSummary
(
	InvDate		DateTime,
	CmpId			INT,
	Prdid			INT,
	TaxPerc			nVarchar(50),
	TaxableAmount		NUMERIC (38,6),
	IOTaxType		nVarchar(100),
	TaxFlag			INT,
	TaxPercent 		Numeric (38,6)
)
Create TABLE #RptIOTaxSummaryFinal
(
	InvDate		DateTime,
	CmpId			INT,
	Prdid			INT,
	TaxPerc			nVarchar(50),
	TaxableAmount		NUMERIC (38,6),
	IOTaxType		nVarchar(100),
	TaxFlag			INT,
	TaxPercent 		Numeric (38,6)
)
SET @TblName = 'RptIOTaxSummary'
SET @TblStruct = 'InvDate		DateTime,
		CmpId			INT,
		Prdid			INT,
		TaxPerc			nVarchar(50),
		TaxableAmount		NUMERIC (38,6),
		IOTaxType		nVarchar(100),
		TaxFlag			INT,
		TaxPercent 		Numeric (38,6)'
SET @TblFields = 'InvDate,CmpId,Prdid,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent'
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
SET @Po_Errno = 0
IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
BEGIN


	EXEC Proc_IOTaxSummary @Pi_UsrId
	
	
	IF EXISTS(Select * from TmpRptIOTaxSummary a,TaxConfiguration b where b.TaxId=a.TaxId and 
	TaxPerc ='Taxable Amount 0.00%'  and LTRIM(RTRIM(UPPER(b.TaxCode)))='ADD VAT')
	BEGIN
	
	
	INSERT INTO #RptIOTaxSummary (TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent)
	SELECT 	TaxPerc,dbo.Fn_ConvertCurrency(SUM(TaxableAmount),@Pi_CurrencyId),IOTaxType,TaxFlag,TaxPercent
	FROM TmpRptIOTaxSummary
	WHERE (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
		CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		AND (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
		PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))		
		AND (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
		PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		AND InvDate BETWEEN @FromDate AND @ToDate and TaxPerc <>'Taxable Amount 0.00%'
	Group By TaxPerc,IOTaxType,TaxFlag,TaxPercent
	
INSERT INTO #RptIOTaxSummary (TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent)
	SELECT 	distinct TaxPerc,dbo.Fn_ConvertCurrency(sum(TaxableAmount),@Pi_CurrencyId),IOTaxType,TaxFlag,TaxPercent
	FROM TmpRptIOTaxSummary a,	 TaxConfiguration TC where TC.TaxId=a.TaxId
	and (a.CmpId = (CASE @CmpId WHEN 0 THEN a.CmpId ELSE 0 END) OR
		a.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		AND (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
		PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))		
		AND (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
		PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		AND InvDate BETWEEN @FromDate AND @ToDate and TaxPerc ='Taxable Amount 0.00%'  and LTRIM(RTRIM(UPPER(TC.TaxCode)))='VAT'
	Group By TaxPerc,IOTaxType,TaxFlag,TaxPercent
	END 
	ELSE
	BEGIN
	INSERT INTO #RptIOTaxSummary (TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent)
	SELECT 	TaxPerc,dbo.Fn_ConvertCurrency(SUM(TaxableAmount),@Pi_CurrencyId),IOTaxType,TaxFlag,TaxPercent
	FROM TmpRptIOTaxSummary
	WHERE (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
		CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		AND (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
		PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))		
		AND (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
		PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		AND InvDate BETWEEN @FromDate AND @ToDate 
	Group By TaxPerc,IOTaxType,TaxFlag,TaxPercent
	
	END
	--select 
	IF LEN(@PurDBName) > 0
	BEGIN
		SET @SSQL = 'INSERT INTO #RptIOTaxSummary ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +
			' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+ '( PrdId = (CASE ' + CAST(@fPrdCatPrdId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR ' +
			' PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '
			+ ' (PrdId = (CASE ' + CAST(@fPrdId AS nVarChar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR ' +
			' PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS  nVarchar(10)) + ',5,' +  CAST(@Pi_UsrId AS nVarchar(10)) + ' )))
			AND InvDate BETWEEN @FromDate AND @ToDate
			Group By TaxPerc,IOTaxType,TaxFlag,TaxPercent'
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptIOTaxSummary'
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
		SET @SSQL = 'INSERT INTO #RptIOTaxSummary ' +
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
Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptIOTaxSummary
INSERT INTO #RptIOTaxSummaryFinal
SELECT * FROM #RptIOTaxSummary
--SELECT * FROM #RptIOTaxSummaryFinal
INSERT INTO #RptIOTaxSummary(TaxPerc,TaxableAmount,IOTaxType)
SELECT TaxPerc,SUM(Purchase+SalesReturn+Sales+PurchaseReturn+IDT) AS Total,'Total'
FROM
(
SELECT TaxPerc,IOTaxType,SUM(Purchase) AS Purchase,SUM(Sales) AS Sales,SUM(SalesReturn) AS SalesReturn,
SUM(PurchaseReturn) AS PurchaseReturn,
SUM(IDTIN - IDTOUT) as IDT
FROM
(
SELECT TaxPerc,IOTaxType,
(CASE IOTaxType WHEN 'IDT IN' THEN ABS(TaxableAmount) ELSE 0 END) AS IDTIN,
(CASE IOTaxType WHEN 'IDT OUT' THEN (ABS(TaxableAmount)) ELSE 0 END) AS IDTOUT,
(CASE IOTaxType WHEN 'Purchase' THEN ABS(TaxableAmount) ELSE 0 END) AS Purchase,
(CASE IOTaxType WHEN 'SalesReturn' THEN (-1*ABS(TaxableAmount)) ELSE 0  END) AS SalesReturn,
(CASE IOTaxType WHEN 'Sales' THEN ABS(TaxableAmount)  ELSE 0 END) AS Sales,
(CASE IOTaxType WHEN 'PurchaseReturn' THEN (-1*ABS(TaxableAmount))  ELSE 0 END) AS [PurchaseReturn]
FROM #RptIOTaxSummaryFinal
GROUP BY TaxPerc,IOTaxType,TaxableAmount
) AS B GROUP BY TaxPerc,IOTaxType
) A
GROUP BY TaxPerc
UPDATE #RptIOTaxSummary
SET #RptIOTaxSummary.TaxFlag=#RptIOTaxSummaryFinal.TaxFlag,
#RptIOTaxSummary.TaxPercent=#RptIOTaxSummaryFinal.TaxPercent
FROM #RptIOTaxSummaryFinal
WHERE #RptIOTaxSummary.TaxPerc=#RptIOTaxSummaryFinal.TaxPerc
AND #RptIOTaxSummary.IOTaxType='Total'
SELECT * FROM #RptIOTaxSummary
	SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
		--EXEC Proc_RptIOTaxSummary 11,1,0,'Corestocky',0,0,1
		/***************************************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE	 @TaxPerc 		NVARCHAR(100)
		DECLARE	 @TaxableAmount NUMERIC(38,6)
		DECLARE  @IOTaxType    NVARCHAR(100)
		DECLARE  @SlNo INT		
		DECLARE	 @TaxFlag      INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @TaxPercent Numeric (38,6)
		DECLARE  @Name    NVARCHAR(100)
		--DROP TABLE RptIOTaxSummary_Excel
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptIOTaxSummary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptIOTaxSummary_Excel]
		DELETE FROM RptExcelHeaders Where RptId=11 AND SlNo>2
		CREATE TABLE RptIOTaxSummary_Excel (IOTaxType nVarchar(100),UsrId INT)
		SET @iCnt=3
		DECLARE Column_Cur CURSOR FOR
		SELECT DISTINCT(TaxPerc),TaxPercent,TaxFlag FROM #RptIOTaxSummary ORDER BY TaxPercent ,TaxFlag
		OPEN Column_Cur
			   FETCH NEXT FROM Column_Cur INTO @Column,@TaxPercent,@TaxFlag
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptIOTaxSummary_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					PRINT @C_SSQL
					EXEC (@C_SSQL)
				SET @iCnt=@iCnt+1
					FETCH NEXT FROM Column_Cur INTO @Column,@TaxPercent,@TaxFlag
				END
		CLOSE Column_Cur
		DEALLOCATE Column_Cur
		--Insert table values
		DELETE FROM RptIOTaxSummary_Excel
		INSERT INTO RptIOTaxSummary_Excel(IOTaxType,UsrId)
		SELECT DISTINCT IOTaxType,@Pi_UsrId
				FROM #RptIOTaxSummary
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT (TaxPerc),TaxableAmount,IOTaxType FROM #RptIOTaxSummary
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @TaxPerc,@TaxableAmount,@IOTaxType--,@TaxFlag
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptIOTaxSummary_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))
					PRINT @C_SSQL
					SET @C_SSQL=@C_SSQL+ ' WHERE IOTaxType=''' + CAST(@IOTaxType AS VARCHAR(1000))
					+''''--' AND TaxFlag =' + CAST(@TaxFlag AS VARCHAR(1000)) +''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @TaxPerc,@TaxableAmount,@IOTaxType--,@TaxFlag
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptIOTaxSummary_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptIOTaxSummary_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/***************************************************************************************************************************/
	END
RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_RptBillWisePrdWise' AND XTYPE='P')
DROP  PROCEDURE Proc_RptBillWisePrdWise
GO
-- EXEC Proc_RptBillWisePrdWise 183,2
-- delete from RptBillWisePrdWise
-- delete from RptBillWisePrdWiseTaxBreakup
-- select * from RptBillWisePrdWise
-- select * from RptBillWisePrdWiseTaxBreakup
CREATE PROCEDURE Proc_RptBillWisePrdWise
(
	@Pi_RptId AS INT,
	@Pi_UsrId AS INT
)
AS 
/************************************************************  
* PROCEDURE : Proc_RptBillWisePrdWise  
* PURPOSE : To get the Product details and Bill details  
* CREATED BY : Murugan.R  
* CREATED DATE : 30/09/2009 
* NOTE  :  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*************************************************************/  
BEGIN
	
	DELETE FROM RptBillWisePrdWise WHERE Usrid=@Pi_UsrId
	DELETE FROM RptBillWisePrdWiseTaxBreakup WHERE Usrid=@Pi_UsrId
	DECLARE @FromDate AS DATETIME  
	DECLARE @ToDate   AS DATETIME  
	DECLARE @DiscBreakup as Int
	DECLARE @QtyBreakup as Int
	DECLARE @TaxBreakup as Int	
	DECLARE @CmpId      AS  INT  	
	DECLARE @CtgLevelId AS  INT  
	DECLARE @RtrClassId AS  INT  
	DECLARE @CtgMainId  AS  INT  
	DECLARE @SalId   AS BIGINT 
	DECLARE @CancelValue AS INT 
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))  
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)) 
	SET @DiscBreakup = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,242,@Pi_UsrId)) 
	SET @QtyBreakup = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) 
	SET @TaxBreakup = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,241,@Pi_UsrId)) 
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))  
	SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))  
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))  
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) 
	SET @CancelValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,243,@Pi_UsrId))  
	CREATE TABLE #RptRetailer
	(
		Rtrid Int,
		RtrCode Varchar(50),
		RtrName Varchar(100)
	)
	CREATE TABLE #RptSalesFree
	(
		SlNo INT,
		SalInvDate datetime,
		SalinvNo Varchar(50),
		Salid Int,
		RmId Int,
		RmName Varchar(75),
		Rtrid Int,
		RtrCode Varchar(50),
		RtrName VarChar(200),
		Lcnid INT,
		Cmpid INT,
		PrdCtgValMainId INT,
		CmpPrdCtgId INT,
		Prdid Int,
		Prdccode Varchar(50),
		PrdName Varchar(200),
		Prdbatid Int,
		PrdBatCode Varchar(75),
		Rate Numeric(36,4),
		SalesQty Int,
		FreeQty Int,
		TotQty Int,
		GrossAmt Numeric(36,4),
		SchemeAmt Numeric(36,4),
		SplDiscount Numeric(36,4),
		CashDiscount Numeric(36,4),
		TotalDiscount Numeric(36,4),
		TotalTax Numeric(36,4),
		NetAmount Numeric(36,4),	
		
	)

        --SET @TaxBreakup=2
		INSERT INTO #RptRetailer		
		SELECT DISTINCT R.Rtrid,RtrCode,RtrName FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK)  
			,RetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL  
		WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId  
			AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId  
			AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
			RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
			AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
			RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
			AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
			RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
			AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR  
			RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
		INSERT INTO #RptSalesFree 	
		SELECT Max(slno) as Slno,Salinvdate,SalinvNo,X.Salid,RmId,RmName,Rtrid,RtrCode,RtrName,Lcnid,Cmpid,PrdCtgValMainId,
			CmpPrdCtgId,Prdid,Prdccode,PrdName,	Prdbatid,PrdBatCode,Rate,Sum(SalesQty) as SalesQty ,sum(FreeQty)as FreeQty,
			Sum(SalesQty+FreeQty) as TotQty,Sum(GrossAmt) as GrossAmt,Sum(SchemeAmt) as SchemeAmt,sum(SplDiscount) as SplDiscount,
			sum(CashDiscount) as CashDiscount,Sum(SchemeAmt+SplDiscount+CashDiscount) as TotalDiscount,Sum(TotalTax) as TotalTax,Sum(NetAmount) as NetAmount
		FROM(
			SELECT SIP.slNo,Salinvdate,Si.SalinvNo,Si.Salid,RM.RMId,RM.RMname,R.Rtrid,RtrCode,RtrName,SI.Lcnid,P.Cmpid,P.PrdCtgValMainId,PC.CmpPrdCtgId,
				   SIP.Prdid,Prdccode,PrdName,SIP.Prdbatid,PrdBatCode,PrdBatDetailValue as Rate,
				   BaseQty as SalesQty,SalManFreeQty as FreeQty,PrdGrossAmountAftEdit as GrossAmt,
				   Sum(Isnull(FlatAmount,0)+Isnull(DiscountPerAmount,0)) as SchemeAmt,PrdSplDiscAmount as SplDiscount,PrdCdAmount as CashDiscount,
				  Isnull(PrdTaxAmount,0) as TotalTax,Isnull(PrdNetAmount,0) as NetAmount
			FROM SalesInvoice SI (NOLOCK)
			INNER JOIN SalesInvoiceProduct SIP (NOLOCK) ON SI.Salid=SIP.SalId	
			INNER JOIN Product P (NOLOCK) On P.Prdid=SIP.Prdid 
			INNER JOIN  ProductCategoryValue PC WITH (NOLOCK) ON  P.PrdCtgValMainId=PC.PrdCtgValMainId  
			INNER JOIN Productbatch PB (NOLOCK) On Pb.Prdid=P.Prdid and Pb.Prdbatid=SIP.Prdbatid
			INNER JOIN ProductBatchDetails D (NOLOCK) ON   PB.PrdBatId = D.PrdBatId AND SIP.PriceId = D.PriceId 
			INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = PB.BatchSeqId 
			AND D.SlNo = E.SlNo AND E.SelRte = 1  
			INNER JOIN RouteMaster RM ON RM.RMId=SI.RmId
			INNER JOIN #RptRetailer R ON R.Rtrid=SI.Rtrid
			LEFT OUTER JOIN SalesInvoiceSchemeLineWise SL ON SL.Salid=SIP.Salid and SL.Prdid=SIP.Prdid and SL.Prdbatid=SIP.Prdbatid
			WHERE SI.SalInvDate Between @FromDate AND @ToDate 
				AND	(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR  
					SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))  
				AND Dlvsts >=CASE WHEN @CancelValue=1 THEN 3 ELSE 4 END
								
			GROUP BY SIP.slNo,Salinvdate,Si.SalinvNo,Si.Salid,RM.RMId,RM.RMname,R.Rtrid,RtrCode,RtrName,SIP.Prdid,Prdccode,PrdName,SIP.Prdbatid,
					PrdBatCode,PrdBatDetailValue,BaseQty,SalManFreeQty,PrdGrossAmountAftEdit,PrdSplDiscAmount,
					PrdCdAmount,P.PrdCtgValMainId,PC.CmpPrdCtgId,SI.Lcnid,P.Cmpid,PrdTaxAmount,PrdNetAmount
			UNION ALL
			SELECT 0 as slno,Salinvdate,Si.SalinvNo, Sf.Salid,RM.RMId,RM.RMname,R.Rtrid,RtrCode,RtrName,SI.Lcnid,P.Cmpid,P.PrdCtgValMainId,
				PC.CmpPrdCtgId,SF.FreePrdId,Prdccode,PrdName,SF.FreePrdBatId,PrdBatCode,PrdBatDetailValue as Rate
				,0 as SalesQty,FreeQty,0 as  GrossAmt,0 as SchemeAmt,0 as SplDiscount,0 as CashDiscount,0 as TotalTax,0 as NetAmount
			FROM SalesInvoiceSchemeDtFreePrd SF 
			INNER JOIN SalesInvoice SI (NOLOCK) ON SI.salid=SF.Salid
			INNER JOIN Product P (NOLOCK) On P.Prdid=SF.FreePrdId 
			INNER JOIN  ProductCategoryValue PC WITH (NOLOCK) ON  P.PrdCtgValMainId=PC.PrdCtgValMainId  
			INNER JOIN Productbatch PB (NOLOCK) On Pb.Prdid=P.Prdid and Pb.Prdbatid=SF.FreePrdBatId
			INNER JOIN ProductBatchDetails D (NOLOCK) ON  PB.PrdBatId = D.PrdBatId and DefaultPrice=1
			INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = PB.BatchSeqId 
				AND D.SlNo = E.SlNo AND E.SelRte = 1 
			INNER JOIN RouteMaster RM ON RM.RMId=SI.RmId 
			INNER JOIN #RptRetailer R ON R.Rtrid=SI.Rtrid
			WHERE SI.SalInvDate Between @FromDate AND @ToDate
				AND	(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR  
					SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
				AND Dlvsts >=CASE WHEN @CancelValue=1 THEN 3 ELSE 4 END
		)X 
		GROUP BY X.Salid,Prdid,Prdbatid,Salinvdate,SalinvNo,RMId,RMname,Rtrid,RtrCode,RtrName,Prdccode,PrdName,PrdBatCode,Rate,
				PrdCtgValMainId,CmpPrdCtgId,Lcnid,Cmpid
		--TaxBreakUp
		IF @TaxBreakup=1
		BEGIN
			INSERT INTO RptBillWisePrdWise
			SELECT SlNo,SalInvDate,SalinvNo,Salid,RMId,RMName,Rtrid,RtrCode,RtrName,
				Lcnid,Cmpid,PrdCtgValMainId,CmpPrdCtgId,Prdid,Prdccode,PrdName,
				Prdbatid,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,SplDiscount,
				CashDiscount,TotalDiscount,TaxPerc,TaxAmount,TotalTax,Netamount,@DiscBreakup,@QtyBreakup,@TaxBreakup,@Pi_UsrId 
			FROM
				(
					SELECT SlNo,SalInvDate,SalinvNo,X.Salid,X.RMID,X.RmName,X.Rtrid,RtrCode,RtrName ,Lcnid,Cmpid,PrdCtgValMainId,CmpPrdCtgId,
							Prdid,Prdccode,PrdName,Prdbatid,PrdBatCode, Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,SplDiscount,
							CashDiscount,TotalDiscount,Cast(Left(Isnull(TaxPerc,0),4) as Varchar(10))+'%' as TaxPerc,
							Isnull(TaxAmount,0) as TaxAmount,TotalTax,Netamount
					FROM #RptSalesFree X LEFT OUTER JOIN SalesinvoiceProducttax SPT ON SPT.PrdSlNo=X.SlNo and SPT.Salid=X.SalId and TaxAmount>0
				)X	
		END
		IF @TaxBreakup=2
		BEGIN	
			--Without TaxBreakUp
			INSERT INTO RptBillWisePrdWise
			SELECT X.SlNo,SalInvDate,SalinvNo,X.Salid,X.RMID,X.RmName,X.Rtrid,RtrCode,RtrName,Lcnid,Cmpid,PrdCtgValMainId,CmpPrdCtgId,
					X.Prdid,Prdccode,PrdName,X.Prdbatid,PrdBatCode, Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,SplDiscount,
					CashDiscount,TotalDiscount,0,0,Isnull(PrdTaxAmount,0) as TotalTax,Isnull(PrdNetAmount,0) as NetAmount,
					@DiscBreakup,@QtyBreakup,@TaxBreakup,@Pi_UsrId
			 FROM #RptSalesFree X LEFT OUTER JOIN SalesInvoiceProduct SIP (NOLOCK) ON X.Salid=SIP.SalId	
					and X.Prdid=SIP.Prdid and X.prdbatid=SIP.Prdbatid and X.SlNo=Sip.Slno
		END
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'U' AND Name = 'RptWithOutTaxBreakup_Excel')
DROP TABLE [dbo].[RptWithOutTaxBreakup_Excel]
GO
CREATE TABLE [dbo].[RptWithOutTaxBreakup_Excel](
	[Bill Date] [datetime] NULL,
	[Bill No] [varchar](50) NULL,
	[Route Name] [varchar](75) NULL,
	[Retailer Code] [varchar](50) NULL,
	[Retailer Name] [varchar](200) NULL,
	[Product Code] [varchar](50) NULL,
	[Product Name] [varchar](200) NULL,
	[Batch Code] [varchar](75) NULL,
	[Selling Rate] [numeric](36, 4) NULL,
	[Sales Qty] [int] NULL,
	[Offer Qty] [int] NULL,
	[Total Qty] [int] NULL,
	[Gross Amt] [numeric](36, 4) NULL,
	[Scheme Amt] [numeric](36, 4) NULL,
	[SplDiscount] [numeric](36, 4) NULL,
	[Cash Discount] [numeric](36, 4) NULL,
	[Total Discount] [numeric](36, 4) NULL,
	[TaxPerc] [nvarchar](200) NULL,
	[TaxAmount] [numeric](36, 4) NULL,
	[Total Tax Amount] [numeric](36, 4) NULL,
	[NetAmount] [numeric](36, 4) NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_RptBillWisePrdWiseOutPut' AND XTYPE='P')
DROP  PROCEDURE Proc_RptBillWisePrdWiseOutPut
GO
-- exec [Proc_RptBillWisePrdWiseOutPut] 183,2,0,'PARLE',0,0,1
CREATE PROCEDURE Proc_RptBillWisePrdWiseOutPut
	(
		@Pi_RptId  INT,
		@Pi_UsrId  INT,
		@Pi_SnapId  INT,
		@Pi_DbName  nvarchar(50),
		@Pi_SnapRequired INT,
		@Pi_GetFromSnap  INT,
		@Pi_CurrencyId  INT
	)
	AS
/************************************************************
* PROCEDURE : [Proc_RptBillWisePrdWiseOutPut]
* PURPOSE : To get the Product details
* CREATED BY : Murugan.R
* CREATED DATE : 30/09/2009
* NOTE  :
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*************************************************************/
BEGIN
	SET NOCOUNT ON
	DECLARE @NewSnapId  AS INT
	DECLARE @DBNAME  AS  NVARCHAR(50)
	DECLARE @TblName  AS NVARCHAR(500)
	DECLARE @TblStruct  AS NVARCHAR(4000)
	DECLARE @TblFields  AS NVARCHAR(4000)
	DECLARE @sSql  AS  NVARCHAR(4000)
	DECLARE @ErrNo   AS INT
	DECLARE @PurDBName AS NVARCHAR(50)
	DECLARE @FromDate AS DATETIME
	DECLARE @ToDate   AS DATETIME
	DECLARE @CmpId   AS INT
	DECLARE @LcnId   AS INT
	DECLARE @SMId   AS INT
	DECLARE @RMId   AS INT
	DECLARE @RtrId   AS INT
	DECLARE @PrdCatId AS INT
	DECLARE @PrdBatId AS INT
	DECLARE @PrdId  AS INT
	DECLARE @SalId   AS BIGINT
	DECLARE @CancelValue AS INT
	DECLARE @BillStatus AS INT
	DECLARE @TaxBreakup AS INT	
	DECLARE @DiscBreakup AS INT
	DECLARE @QtyBreakup AS INT	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @PrdBatId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	SET @TaxBreakup = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,241,@Pi_UsrId))
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))

	CREATE TABLE #RptWithOutTaxBreakup
		(
			SalInvDate datetime,
			SalinvNo Varchar(50),
			RouteName Varchar(75),		
			RtrCode Varchar(50),
			RtrName VarChar(200),			
			Prdccode Varchar(50),
			PrdName Varchar(200),
			PrdBatCode Varchar(75),
			Rate Numeric(36,4),
			SalesQty Int,
			FreeQty Int,
			TotQty Int,
			GrossAmt Numeric(36,4),
			SchemeAmt Numeric(36,4),
			SplDiscount Numeric(36,4),
			CashDiscount Numeric(36,4),
			TotalDiscount Numeric(36,4),
			TaxPerc NVARCHAR(200),		
			TaxAmount Numeric(36,4),				
			TotalTax Numeric(36,4),
			NetAmount Numeric(36,4),		
			DiscBreakup Int,
			QtyBreakup  Int,
			TaxBreakup Int
			
		)
		IF @TaxBreakup=2
		BEGIN
			SET @TblName = 'RptBillWisePrdWiseTaxBreakup'

			SET @TblStruct = 'SalInvDate datetime,
			SalinvNo Varchar(50),	
			RouteName Varchar(75),	
			RtrCode Varchar(50),
			RtrName VarChar(200),			
			Prdccode Varchar(50),
			PrdName Varchar(200),
			PrdBatCode Varchar(75),
			Rate Numeric(36,4),
			SalesQty Int,
			FreeQty Int,
			TotQty Int,
			GrossAmt Numeric(36,4),
			SchemeAmt Numeric(36,4),
			SplDiscount Numeric(36,4),
			CashDiscount Numeric(36,4),
			TotalDiscount Numeric(36,4),
			TotalTax Numeric(36,4),
			NetAmount Numeric(36,4),		
			DiscBreakup Int,
			QtyBreakup  Int,
			TaxBreakup Int'

			SET @TblFields = 'SalInvDate,SalinvNo,RouteName,RtrCode,RtrName,Prdccode,
			 PrdName,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,
			 SplDiscount,CashDiscount,TotalDiscount,TotalTax,NetAmount,DiscBreakup,QtyBreakup,TaxBreakup'
		END
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
		
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data
	BEGIN
		EXEC Proc_RptBillWisePrdWise 183,2
		--SET @TaxBreakup=2	
		SELECT DISTINCT @DiscBreakup=DiscBreakup FROM RptBillWisePrdWise WHERE UsrId=@Pi_UsrId
		SELECT DISTINCT @QtyBreakup=QtyBreakup FROM RptBillWisePrdWise WHERE UsrId=@Pi_UsrId
		INSERT INTO #RptWithOutTaxBreakup (SalInvDate,SalinvNo,RouteName,RtrCode,RtrName,Prdccode,
				 PrdName,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,
				 SplDiscount,CashDiscount,TotalDiscount,TaxPerc,TaxAmount,TotalTax,NetAmount,DiscBreakup,QtyBreakup,TaxBreakup)
			SELECT SalInvDate,SalinvNo,RmName,RtrCode,RtrName,Prdccode,
				PrdName,PrdBatCode, dbo.Fn_ConvertCurrency(Rate,@Pi_CurrencyId),SalesQty,FreeQty,TotQty,
				dbo.Fn_ConvertCurrency(GrossAmt,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(SchemeAmt,@Pi_CurrencyId),
				dbo.Fn_ConvertCurrency(SplDiscount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CashDiscount,@Pi_CurrencyId),
				dbo.Fn_ConvertCurrency(TotalDiscount,@Pi_CurrencyId),
				TaxPerc,
				dbo.Fn_ConvertCurrency(TaxAmount,@Pi_CurrencyId),			
				dbo.Fn_ConvertCurrency(TotalTax,@Pi_CurrencyId),
				dbo.Fn_ConvertCurrency(NetAmount,@Pi_CurrencyId),DiscBreakup,QtyBreakup,TaxBreakup
		FROM RptBillWisePrdWise
		WHERE  UsrId=@Pi_UsrId
		AND  (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
		CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		AND
		(LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
		LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
		AND
		(PrdId = (CASE @PrdCatId WHEN 0 THEN PrdId Else 0 END) OR
		PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND
		(PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR
		PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		AND
		(PrdBatId = (CASE @PrdBatId WHEN 0 THEN PrdBatId Else 0 END) OR
		PrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))

		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			SET @SSQL = 'INSERT INTO #RptWithOutTaxBreakup ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+ ' WHERE UsrId=' + CAST(@Pi_UsrId AS nVarchar(10)) + ''
			+ 'AND  (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
			+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
			+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
			+ 'AND (LcnId = (CASE ' + CAST(@LcnId AS nVarchar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR '
			+ 'LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
			+ 'AND (PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
			+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
			+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
			+ 'AND (PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
			+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
			+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
			+ 'AND (PrdBatId = (CASE ' + CAST(@PrdBatId AS nVarchar(10)) + ' WHEN 0 THEN PrdBatId Else 0 END) OR '
			+ 'PrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(' +
			+ CAST(@Pi_RptId AS nVarchar(10)) + ',7,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptWithOutTaxBreakup'
				EXEC (@SSQL)
				PRINT 'Saved Data Into SnapShot Table'
			END
		END
	END
	ELSE    --To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptWithOutTaxBreakup ' +
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
	IF @TaxBreakup=1
	BEGIN	
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptWithOutTaxBreakup
	END
	IF @TaxBreakup=2
	BEGIN	
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptWithOutTaxBreakup 	
	END

	DELETE FROM RptWithOutTaxBreakup_Excel
	DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId	
		

	IF EXISTS (SELECT *	FROM RptDataCount WHERE RptId=183 and RecCount>0)
	BEGIN
	--Excel Report
		DELETE FROM RptExcelHeaders Where RptId=@Pi_RptId
		INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)	
		SELECT @Pi_RptId,ColId ,Name,Name,1,1 FROM SYSCOLUMNS S WHERE Id In (Select Id From SysObjects where Xtype='U' and Name='RptWithOutTaxBreakup_Excel')	
		IF (@DiscBreakup=2 AND @QtyBreakup=2)
		BEGIN	
			UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno IN(9,10,13,14,15)	and RptId=@Pi_RptId			
		END	
		IF (@DiscBreakup=1  AND @QtyBreakup=2)
		BEGIN		
			UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno IN(9,10) and RptId=@Pi_RptId				
		END	
		IF (@DiscBreakup=2  AND @QtyBreakup=1)
		BEGIN		
			UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno  In(13,14,15) and RptId=@Pi_RptId
		END

		IF @TaxBreakup = 1
		BEGIN		
			UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE Slno IN(18,19) and RptId=@Pi_RptId				
		END	
		IF @TaxBreakup = 2
		BEGIN		
			UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno IN(18,19) and RptId=@Pi_RptId				
		END
		
		INSERT INTO RptWithOutTaxBreakup_Excel([Bill Date],[Bill No],[Route Name],[Retailer Code],[Retailer Name],[Product Code],[Product Name],
					[Batch Code],[Selling Rate],[Sales Qty],[Offer Qty],[Total Qty],[Gross Amt],[Scheme Amt],[SplDiscount],
					[Cash Discount],[Total Discount],TaxPerc,TaxAmount,[Total Tax Amount],[NetAmount ])
		SELECT SalInvDate,SalinvNo,RouteName,RtrCode,RtrName,Prdccode,
			 PrdName,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,
			 SplDiscount,CashDiscount,TotalDiscount,TaxPerc,TaxAmount,TotalTax,NetAmount from #RptWithOutTaxBreakup
		
		SELECT * FROM RptWithOutTaxBreakup_Excel
	--End
		--Grid Report
		
		DELETE FROM SpreadDisplayColumns WHERE MasterId=@Pi_RptId
		INSERT INTO SpreadDisplayColumns
		select @Pi_RptId,
		(select count(*) from RptExcelHeaders where slno <= t.slno and DisplayFlag=1 and RptId=@Pi_RptId),
		FieldName,1,1,1,GetDate(),1,Getdate() from RptExcelHeaders t where RptId=@Pi_RptId and DisplayFlag=1
		order by slno
		
		DECLARE @ColName as Varchar(4000)
		DECLARE @ColName1 as Varchar(4000)
		DECLARE @Gsql as Varchar(8000)
		DECLARE @Colcnt as INT
		SET @ColName=''
		SET @ColName1=''
		SELECT @ColName=@ColName+'['+ColumnName +'],'  FROM SpreadDisplayColumns WHERe MasterId=@Pi_RptId
		SELECT @Colcnt=Count(*) FROM SpreadDisplayColumns S WHERE MasterId=@Pi_RptId
		SET @ColName=SUBSTRING(@ColName,1,Len(@ColName)-1)
		SELECT @ColName1=@ColName1+'['+Name +'],' FROM SYSCOLUMNS S WHERE Id In (Select Id From SysObjects where Xtype='U' and Name='RptColvalues') and ColId<=@Colcnt
		SET @ColName1=SUBSTRING(@ColName1,1,Len(@ColName1)-1)
		SET @Gsql= 'INSERT INTO RptColvalues ( '+@ColName1+',Rptid,Usrid)
		SELECT '+@ColName+ ','+
		CAST(@Pi_RptId AS nVarchar(10))+','+ CAST(@Pi_UsrId AS nVarchar(10)) +'FROM RptWithOutTaxBreakup_Excel Order By [Bill Date],[Bill No]'
		EXEC (@Gsql)
	--END Grid Report
	END
	RETURN
END
GO
IF EXISTS(SELECT* FROM SYSOBJECTS WHERE NAME ='Proc_RptGujVAT201A' AND XTYPE='P')
DROP PROCEDURE Proc_RptGujVAT201A
GO
--EXEC Proc_RptGujVAT201A 277,2,0,'PARLE',0,0,1
CREATE PROCEDURE Proc_RptGujVAT201A
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
* PROCEDURE	: Proc_RptGujVAT201A
* PURPOSE	: To get the report for tax details
* CREATED BY	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 23-06-2014
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
SET NOCOUNT ON
BEGIN
		DECLARE @FromDate	DATETIME
		DECLARE @ToDate		DATETIME
		DECLARE @CmpId		INT
		DECLARE @Type		TINYINT
		DECLARE @TaxType	TINYINT
		
		SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
		SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
		SET @CmpId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		SET @Type=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,314,@Pi_UsrId))
		SET @TaxType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,200,@Pi_UsrId))
		
		CREATE TABLE #RptGujVAT201A
		(
			SalId			BIGINT,
			SalInvNo		VARCHAR(50),
			SalInvDate		DATETIME,
			RtrId			INT,
			RtrName			VARCHAR(50),
			RtrTinNo		VARCHAR(25),
			TaxPerc			NUMERIC(18,2),
			TaxableAmt		NUMERIC(38,6),
			MainTaxAmt		NUMERIC(38,6),
			AddTaxAmt		NUMERIC(38,6),
			TotalAmt		NUMERIC(38,6)
		)
		DECLARE @Tbl_TAXTYPE TABLE (TaxType TINYINT)
		IF @TaxType=0
		BEGIN
			INSERT INTO @Tbl_TAXTYPE (TaxType) SELECT 0 UNION SELECT 1
		END
		ELSE
		BEGIN
			INSERT INTO @Tbl_TAXTYPE (TaxType) SELECT CASE @TaxType WHEN 1 THEN 0 WHEN 2 THEN 1 END
		END
	
		IF @Type=1
		BEGIN		
			SELECT R.* INTO #Retailer FROM Retailer R WHERE EXISTS (SELECT * FROM @Tbl_TAXTYPE E WHERE E.TaxType=R.RtrTaxType)
			
			SELECT S.* INTO #SalesInvoice FROM SalesInvoice  S (NOLOCK) INNER JOIN #Retailer R ON R.RtrId=S.RtrId
			WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND DlvSts>3
			
			SELECT SP.* INTO #SalesInvoiceProduct FROM #SalesInvoice S (NOLOCK) 
			INNER JOIN SalesInvoiceProduct SP ON S.SalId=SP.SalId
			
			SELECT T.* INTO #SalesInvoiceProductTax_Main FROM #SalesInvoice S (NOLOCK)
			INNER JOIN #SalesInvoiceProduct SP (NOLOCK) ON SP.SalId=S.SalId
			INNER JOIN SalesInvoiceProductTax T (NOLOCK)  ON T.SalId=SP.SalId AND T.SalId=S.SalId AND T.PrdSlNo=SP.SlNo
			INNER JOIN TaxConfiguration TC ON TC.TaxId=T.TaxId
			WHERE T.TaxableAmount>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode)))='VAT'
			
			SELECT T.*  INTO #SalesInvoiceProductTax_ADD FROM #SalesInvoice S (NOLOCK)
			INNER JOIN #SalesInvoiceProduct SP (NOLOCK) ON SP.SalId=S.SalId
			INNER JOIN SalesInvoiceProductTax T (NOLOCK)  ON T.SalId=SP.SalId AND T.SalId=S.SalId AND T.PrdSlNo=SP.SlNo
			INNER JOIN TaxConfiguration TC ON TC.TaxId=T.TaxId
			--WHERE T.TaxableAmount>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode)))='ADD VAT'
			WHERE T.TaxableAmount>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode))) <> 'VAT'
		
			--Muthuvel
			SELECT R.* INTO #ReturnHeader FROM ReturnHeader R (NOLOCK) INNER JOIN #Retailer RR ON R.RtrId=RR.RtrId
			--INNER JOIN #SalesInvoice I ON I.SalId = R.SalId AND I.SMId = R.SMId AND I.RtrId = R.RtrId
			WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND Status=0
						
			SELECT SP.* INTO #ReturnProduct FROM #ReturnHeader S (NOLOCK) INNER JOIN ReturnProduct SP (NOLOCK)  ON S.ReturnID=SP.ReturnID
			
			SELECT SPT.* INTO #ReturnProductTax_Main FROM #ReturnHeader S (NOLOCK) 
			INNER JOIN #ReturnProduct SP (NOLOCK)  ON S.ReturnID=SP.ReturnID
			INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID AND SP.ReturnID=SPT.ReturnID AND SPT.PrdSlNo=SP.SlNo
			INNER JOIN TaxConfiguration TC ON TC.TaxId=SPT.TaxId
			WHERE TaxableAmt>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode)))='VAT'
			
			SELECT SPT.* INTO #ReturnProductTax_ADD FROM #ReturnHeader S (NOLOCK) 
			INNER JOIN #ReturnProduct SP (NOLOCK)  ON S.ReturnID=SP.ReturnID
			INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID AND SP.ReturnID=SPT.ReturnID AND SPT.PrdSlNo=SP.SlNo
			INNER JOIN TaxConfiguration TC ON TC.TaxId=SPT.TaxId
			WHERE TaxableAmt>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode))) <> 'VAT'			
			--till here
			
			INSERT INTO #RptGujVAT201A (SalId,SalInvNo,SalInvDate,RtrId,RtrName,RtrTinNo,TaxPerc,TaxableAmt,MainTaxAmt,AddTaxAmt,TotalAmt)
			SELECT S.SalId,S.SalInvNo,S.SalInvDate,R.RtrId,R.RtrName,R.RtrTinNo,T.TaxPerc,SUM(T.TaxableAmount) MainTaxableAmount,
			SUM(T.TaxAmount) MainTaxAmount,ISNULL(SUM(AD.TaxAmount),0) ADDTaxAmount,SUM(T.TaxableAmount)+SUM(T.TaxAmount)+ISNULL(SUM(AD.TaxAmount),0) TotalAmt
			FROM #SalesInvoice S (NOLOCK)
			INNER JOIN #SalesInvoiceProduct SP (NOLOCK) ON SP.SalId=S.SalId
			INNER JOIN #SalesInvoiceProductTax_Main T (NOLOCK)  ON T.SalId=SP.SalId AND T.SalId=S.SalId AND T.PrdSlNo=SP.SlNo
			LEFT OUTER JOIN #SalesInvoiceProductTax_ADD AD ON AD.SalId=SP.SalId AND AD.SalId=S.SalId AND AD.PrdSlNo=SP.SlNo
			INNER JOIN Retailer R (NOLOCK) ON S.RtrId=R.RtrId
			WHERE SalInvDate BETWEEN @FromDate AND @ToDate
			GROUP BY R.RtrId,T.TaxPerc,R.RtrName,R.RtrTinNo,S.SalId,S.SalInvNo,S.SalInvDate
			HAVING SUM(T.TaxableAmount)>0
			
			--Muthuvel
			INSERT INTO #RptGujVAT201A (SalId,SalInvNo,SalInvDate,RtrId,RtrName,RtrTinNo,TaxPerc,TaxableAmt,MainTaxAmt,AddTaxAmt,TotalAmt)
			SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,R.RtrId,R.RtrName,R.RtrTinNo,T.TaxPerc,-1 *SUM(T.TaxableAmt) MainTaxableAmount,
			-SUM(T.TaxAmt) MainTaxAmt, -ISNULL(SUM(AD.TaxAmt),0) ADDTaxAmount, -SUM(T.TaxableAmt)+ -SUM(T.TaxAmt) + -ISNULL(SUM(AD.TaxAmt),0) TotalAmt
			FROM #ReturnHeader S (NOLOCK)
			INNER JOIN #ReturnProduct SP (NOLOCK) ON SP.ReturnID=S.ReturnID
			INNER JOIN #ReturnProductTax_Main T (NOLOCK)  ON T.ReturnID=SP.ReturnID AND T.ReturnID=S.ReturnID AND T.PrdSlNo=SP.SlNo
			LEFT OUTER JOIN #ReturnProductTax_ADD AD ON AD.ReturnID=SP.ReturnID AND AD.ReturnID=S.ReturnID AND AD.PrdSlNo=SP.SlNo
			INNER JOIN Retailer R (NOLOCK) ON S.RtrId=R.RtrId
			GROUP BY R.RtrId,T.TaxPerc,R.RtrName,R.RtrTinNo,S.ReturnID,S.ReturnCode,S.ReturnDate
			HAVING SUM(T.TaxableAmt)>0	
			--till here		
		END
		ELSE IF @Type=2
		BEGIN
			SELECT P.* INTO #PurchaseReceipt FROM PurchaseReceipt P (NOLOCK) WHERE GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND Status=1
			SELECT PR.* INTO #PurchaseReceiptProduct FROM #PurchaseReceipt P (NOLOCK) 
			INNER JOIN PurchaseReceiptProduct PR (NOLOCK)  ON P.PurRcptId=PR.PurRcptId
			SELECT PRT.* INTO #PurchaseReceiptProductTax_Main FROM #PurchaseReceipt P (NOLOCK) 
			INNER JOIN #PurchaseReceiptProduct PR (NOLOCK)  ON P.PurRcptId=PR.PurRcptId
			INNER JOIN PurchaseReceiptProductTax PRT (NOLOCK)  ON P.PurRcptId=PRT.PurRcptId AND PR.PurRcptId=PRT.PurRcptId AND PR.PrdSlNo=PRT.PrdSlNo
			INNER JOIN TaxConfiguration TC ON TC.TaxId=PRT.TaxId
			WHERE PRT.TaxableAmount>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode)))='VAT'
			
			SELECT PRT.* INTO #PurchaseReceiptProductTax_ADD FROM #PurchaseReceipt P (NOLOCK) 
			INNER JOIN #PurchaseReceiptProduct PR (NOLOCK)  ON P.PurRcptId=PR.PurRcptId
			INNER JOIN PurchaseReceiptProductTax PRT (NOLOCK)  ON P.PurRcptId=PRT.PurRcptId AND PR.PurRcptId=PRT.PurRcptId AND PR.PrdSlNo=PRT.PrdSlNo
			INNER JOIN TaxConfiguration TC ON TC.TaxId=PRT.TaxId
			--WHERE PRT.TaxableAmount>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode)))='ADD VAT'
			WHERE PRT.TaxableAmount>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode))) <> 'VAT'
			
			INSERT INTO #RptGujVAT201A (SalId,SalInvNo,SalInvDate,RtrId,RtrName,RtrTinNo,TaxPerc,TaxableAmt,MainTaxAmt,AddTaxAmt,TotalAmt)
			SELECT S.PurRcptId,S.CmpInvNo,S.GoodsRcvdDate,R.SpmId,R.SpmName,R.SpmTinNo,T.TaxPerc,SUM(T.TaxableAmount) MainTaxableAmount,
			SUM(T.TaxAmount) MainTaxAmount,ISNULL(SUM(AD.TaxAmount),0) ADDTaxAmount,SUM(T.TaxableAmount)+SUM(T.TaxAmount)+ISNULL(SUM(AD.TaxAmount),0) TotalAmt
			FROM #PurchaseReceipt S (NOLOCK)
			INNER JOIN #PurchaseReceiptProduct SP (NOLOCK) ON SP.PurRcptId=S.PurRcptId
			INNER JOIN #PurchaseReceiptProductTax_Main T (NOLOCK)  ON T.PurRcptId=SP.PurRcptId AND T.PurRcptId=S.PurRcptId AND T.PrdSlNo=SP.PrdSlNo
			LEFT OUTER JOIN #PurchaseReceiptProductTax_ADD AD ON AD.PurRcptId=SP.PurRcptId AND AD.PurRcptId=S.PurRcptId AND AD.PrdSlNo=SP.PrdSlNo
			INNER JOIN Supplier R (NOLOCK) ON S.SpmId=R.SpmId
			WHERE S.GoodsRcvdDate BETWEEN @FromDate AND @ToDate
			GROUP BY R.SpmId,T.TaxPerc,R.SpmName,R.SpmTinNo,S.PurRcptId,S.CmpInvNo,S.GoodsRcvdDate
			HAVING SUM(T.TaxableAmount)>0
		END
		DELETE FROM RptDataCount WHERE RptId=@Pi_RptId AND UserId=@Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,COUNT(*),0,@Pi_UsrId FROM #RptGujVAT201A
		SELECT * FROM #RptGujVAT201A ORDER BY SalId
	RETURN
END
GO
UPDATE UtilityProcess SET VersionId = '3.1.0.1' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.1',420
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 420)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(420,'D','2014-12-22',GETDATE(),1,'Core Stocky Service Pack 420')