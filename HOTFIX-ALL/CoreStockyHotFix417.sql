--[Stocky HotFix Version]=417
DELETE FROM Versioncontrol WHERE Hotfixid='417'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('417','3.1.0.0','D','2014-07-23','2014-07-23','2014-07-23',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
/*
*******************************************************************************************
1.  Standard Voucher Manual Entry Delete & Edit Option Enabeled
2.  Parle Reports - Collection Summary Report
3.  Delivery 7 Days has be Increased
4.  Collection Report & Collection format Report - Total No Of Bills Collected Field Added
5.  Loading Sheet More than One Salesman to be Display in Crystal Report
6.  Bill Print Salesman Phone Number Added
7.  Product Master Manual Creation only for Kit Products
8.  Parle Reports - Monthly Stock Report
9.  Billing New Filed Added Total Boxes & Total PKTs
10. Contract Pricing New Product Download - Discount Percentage Updated
*******************************************************************************************         
*/
--Standar Voucher 
DELETE FROM ProfileDt WHERE MenuId = 'mFin6' AND BtnIndex = 3
INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT DISTINCT PrfId,'mFin6',3,'Delete',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD (NOLOCK)
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE XTYPE IN ('FN','TF') AND name = 'Fn_ReturnVoucherCreditDebit')
DROP FUNCTION Dbo.Fn_ReturnVoucherCreditDebit
GO
--SELECT DISTINCT * FROM Fn_ReturnVoucherCreditDebit('RCP1403615') ORDER BY DebitCredit DESC
CREATE FUNCTION Dbo.Fn_ReturnVoucherCreditDebit(@Pi_VocRefNo AS NVARCHAR(100))
RETURNS @ReturnVoucherCreditDebit TABLE
(
  CoaId         BIGINT,
  DebitCredit   TINYINT,
  AcCode        NVARCHAR(200),
  AcName        NVARCHAR(100),
  Amount        NUMERIC(18,2)
)
AS
BEGIN
/************************************************
* FUNCTION : Fn_ReturnVoucherCreditDebit
* PURPOSE  : Returns Voucher Details
* NOTES    :   
* CREATED  : Sathishkumar Veeramani 2014/07/14 
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
-------------------------------------------------
* 
*************************************************/
    INSERT INTO @ReturnVoucherCreditDebit (CoaId,DebitCredit,AcCode,AcName,Amount)
	SELECT S.CoaId,S.DebitCredit,C.AcCode,C.AcName,S.Amount FROM StdVocDetails S (NOLOCK)
	INNER JOIN COAMaster C (NOLOCK)	ON  S.CoaId = C.CoaId WHERE S.VocRefNo = @Pi_VocRefNo
RETURN
END
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 98
INSERT INTO HotSearchEditorHd
SELECT 98,'Standard Voucher','VoucherRef','select',
'SELECT DISTINCT VocType,VocDate,VocRefNo,Remarks,VocTypeId,VocSubType,AutoGen FROM 
(SELECT CtrlDesc AS VocType,VocDate,VocRefNo,Remarks,VocType AS VocTypeId,VocSubType,AutoGen 
FROM StdVocMaster (NOLOCK),ScreenDefaultValues (NOLOCK) WHERE TransId=vFParam AND CtrlId=vSParam 
AND LngId=vTParam AND CtrlValue=VocType UNION 
SELECT CtrlDesc AS VocType,VocDate,VocRefNo,Remarks,VocType AS VocTypeId,VocSubType,AutoGen 
FROM PDCStdVocMaster (NOLOCK),ScreenDefaultValues (NOLOCK) WHERE TransId=vFParam AND CtrlId=vSParam 
AND LngId=vTParam AND CtrlValue=VocType AND PostedToStdVoc=0) MainSql'
GO
DELETE FROM HotSearchEditorDt WHERE FormId = 98
INSERT INTO HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,98,'VoucherRef','Voucher Type','VocType',1500,0,'HotSch-39-2000-1',39 UNION
SELECT 2,98,'VoucherRef','Voucher Date','VocDate',1500,0,'HotSch-39-2000-2',39 UNION
SELECT 3,98,'VoucherRef','Reference No','VocRefNo',1500,0,'HotSch-39-2000-6',39 UNION
SELECT 4,98,'VoucherRef','Remarks','Remarks',1500,0,'HotSch-39-2000-35',39
GO
--PARLE CR Collection Summary Report
DELETE FROM RptGroup WHERE RptId = 281
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',281,'DayWiseCollectionSummary','Day Wise Collection Summary',1
GO
DELETE FROM RptHeader WHERE RptId = 281
INSERT INTO RptHeader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'DayWiseCollectionSummary','Day Wise Collection Summary',281,'Day Wise Collection Summary','Proc_RptCollectionSummaryReport',
'RptCollectionSummary','RptCollectionSummary.rpt',''
GO
DELETE FROM RptDetails WHERE RptId = 281
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (281,1,'FromDate',-1,NULL,'','From Date*',NULL,1,NULL,10,0,0,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (281,2,'ToDate',-1,NULL,'','To Date*',NULL,1,NULL,11,0,0,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (281,3,'Salesman',-1,NULL,'SMId,SMCode,SMName','Salesman...',NULL,1,NULL,1,0,0,'Press F4/Double Click to select Salesman',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (281,4,'RouteMaster',-1,NULL,'RMId,RMCode,RMName','Sales Route...',NULL,1,NULL,2,0,0,'Press F4/Double Click to select Sales Route',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (281,5,'RouteMaster',-1,NULL,'RMId,RMCode,RMName','Delivery Route...',NULL,1,NULL,35,0,0,'Press F4/Double Click to select Delivery Route',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (281,6,'Retailer',-1,NULL,'RtrId,RtrCode,RtrName','Retailer Group...',NULL,1,NULL,215,0,0,'Press F4/Double Click to select Retailer Group',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (281,7,'Retailer',-1,NULL,'RtrId,RtrCode,RtrName','Retailer...',NULL,1,NULL,3,0,0,'Press F4/Double Click to select Retailer',0)
GO
DELETE FROM RptFormula WHERE RptId = 281
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,1,'Disp_FromDate','FromDate',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,2,'Disp_ToDate','ToDate',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,3,'Disp_Salesman','Salesman',1,1)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,4,'Disp_Route','Sales Route',1,2)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,5,'Disp_Retailer','Retailer',1,3)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,6,'Cap Page','Page',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,7,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,8,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,9,'Cap_RetailerGroup','Retailer Group',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,10,'Disp_RetailerGroup','Retailer Group',1,215)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,11,'Delivery Route','Delivery Route',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,12,'Disp_DRoute','Delivery Route',1,35)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,13,'Cap_Show','Show Report Based On',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,14,'Disp_Show','Show Report Based On',1,44)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,15,'BillDate','Bill Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,16,'TotNoofBills','Total Number of Bills',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,17,'TotBillAmt','Total Bill Amount ',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,18,'TotCashBills','Total Cash Bills',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,19,'TotCasAmt','Total Cash Collected ',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,20,'TotChqBill','Total Cheque Bills ',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,21,'TotChqAmt','Total Cheque Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,22,'TotColedAmt','Total Collected Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,23,'TotNoofPndBills','Total Number of Pending Bills',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,24,'TotPendingAmt','Total Pending Amount ',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (281,25,'GrandTotal','Grand Total ',1,0)
GO
DELETE FROM RptExcelHeaders WHERE RptId = 281
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (281,1,'[Bill Date]','Bill Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (281,2,'[Total Number of Bills]','Total Number of Bills',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (281,3,'[Total Bill Amount]','Total Bill Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (281,4,'[Total Cash Bills]','Total Cash Bills',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (281,5,'[Total Cash Collected]','Total Cash Collected',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (281,6,'[Total Cheque Bills]','Total Cheque Bills',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (281,7,'[Total Cheque Amount]','Total Cheque Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (281,8,'[Total Collected Amount]','Total Collected Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (281,9,'[Total Number of Pending Bills]','Total Number of Pending Bills',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (281,10,'[Total Pending Amount]','Total Pending Amount',1,1)
GO
DELETE FROM RptGridView WHERE RptId = 281
INSERT INTO RptGridView (RptId,RptName,CrystalView,GridView,ExcelView,PDFView)
SELECT DISTINCT RPTID,RptName,1,0,1,0 FROM RptHeader WITH(NOLOCK) WHERE RptId = 281
GO
IF EXISTS (SELECT Name FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_RptCollectionSummaryReport')
DROP PROCEDURE Proc_RptCollectionSummaryReport
GO
--EXEC Proc_RptCollectionSummaryReport 281,1,0,'CoreStocky',0,0,1
CREATE PROCEDURE Proc_RptCollectionSummaryReport
(
	@Pi_RptId		    INT,
	@Pi_UsrId		    INT,
	@Pi_SnapId		    INT,
	@Pi_DbName		    NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/********************************************************************
* PROCEDURE	    : Proc_RptCollectionSummaryReport
* PURPOSE	    : To Generate the Collection Report Summary Details
* CREATED	    : Sathishkumar Veeramani
* CREATED DATE	: 02/07/2014
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
---------------------------------------------------------------------
* {date}		{developer}		  {brief modification description}
*********************************************************************/
BEGIN
	SET NOCOUNT ON
	DECLARE @ErrNo	 	AS	INT 
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @DlvRId		AS  INT
	DECLARE @RtrId	 	AS	INT
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @DlvRId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))

	CREATE TABLE #RptCollectionSummary
	(
		[Bill Date] 			          DATETIME,
		[Total Number of Bills]	          NUMERIC(18,0),
		[Total Bill Amount]               NUMERIC(38,6),
		[Total Cash Bills] 		          NUMERIC(18,0),
		[Total Cash Collected] 	          NUMERIC(18,6),
		[Total Cheque Bills]              NUMERIC(18,0),
		[Total Cheque Amount]             NUMERIC(38,6),
		[Total Collected Amount]          NUMERIC(38,6),
		[Total Number of Pending Bills]   NUMERIC(18,0),
		[Total Pending Amount]            NUMERIC(38,6),
		[UsrId]		                      NUMERIC(18,0)
	)
	    
	    INSERT INTO #RptCollectionSummary ([Bill Date],[Total Number of Bills],[Total Bill Amount],[Total Cash Bills],[Total Cash Collected],
	    [Total Cheque Bills],[Total Cheque Amount],[Total Collected Amount],[Total Number of Pending Bills],[Total Pending Amount],[UsrId])
		SELECT DISTINCT SI.SalInvDate,COUNT(SI.SalId) AS TotalBills,ISNULL(SUM(SalNetAmt),0) AS TotAlBillAmt,
		ISNULL(COUNT(DISTINCT CSB.SalId),0) AS CashBillCount,ISNULL(SUM(CSB.SalInvAmt),0) AS CashBillAmt,
		ISNULL(COUNT(DISTINCT CHB.SalId),0) AS CheqBillCount,ISNULL(SUM(CHB.SalInvAmt),0) AS CheqBillAmt,
		(ISNULL(SUM(CSB.SalInvAmt),0)+ISNULL(SUM(CHB.SalInvAmt),0)) AS TotCollectedAmt,0 AS TotPendingBill,
		(ISNULL(SUM(SalNetAmt),0)-(ISNULL(SUM(CSB.SalInvAmt),0)+ISNULL(SUM(CHB.SalInvAmt),0))) AS TotalPendingAmt,@Pi_UsrId
		FROM SalesInvoice SI (NOLOCK) 
		LEFT OUTER JOIN ReceiptInvoice CSB (NOLOCK) ON SI.SalId = CSB.SalId AND CSB.InvRcpMode <> 3 AND CSB.CancelStatus = 1
		LEFT OUTER JOIN ReceiptInvoice CHB (NOLOCK) ON SI.SalId = CHB.SalId AND CHB.InvRcpMode = 3 AND CHB.InvInsSta <> 4 AND CHB.CancelStatus = 1
		WHERE DlvSts > 3 AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
		AND (SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
		SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) 
		AND 
		(RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
		RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) 
		AND
		(DlvRMId=(CASE @DlvRId WHEN 0 THEN DlvRMId ELSE 0 END) OR
		DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
		AND 
		(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
		RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		GROUP BY SI.SalInvDate
		
		UPDATE A SET A.[Total Number of Pending Bills] = TotPendingBill FROM #RptCollectionSummary A INNER JOIN (
		SELECT SalInvDate,ISNULL(COUNT(DISTINCT SalId),0) AS TotPendingBill FROM SalesInvoice A (NOLOCK) 
		WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND NOT EXISTS (SELECT DISTINCT SalId FROM ReceiptInvoice C (NOLOCK) 
		WHERE A.SalId = C.SalId AND CancelStatus = 1 AND InvInsSta <> 4) GROUP BY SalInvDate) Z ON A.[Bill Date] = Z.SalInvDate
		
		--Check for Report Data
		DELETE FROM RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId

		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,COUNT(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptCollectionSummary WHERE UsrId = @Pi_UsrId
		-- Till Here
	
	    SELECT [Bill Date],[Total Number of Bills],[Total Bill Amount],[Total Cash Bills],[Total Cash Collected],[Total Cheque Bills],
		[Total Cheque Amount],[Total Collected Amount],[Total Number of Pending Bills],[Total Pending Amount] FROM #RptCollectionSummary
		WHERE UsrId = @Pi_UsrId

RETURN
END
GO
--Auto Delivery Process
DELETE FROM Configuration WHERE ModuleId IN ('DAYENDPROCESS1','DAYENDPROCESS4','DAYENDPROCESS6')
INSERT INTO Configuration (ModuleId,ModuleName,[Description],[Status],Condition,ConfigValue,SeqNo)
SELECT 'DAYENDPROCESS1','Day End Process','Allow Modification of Pending Bills up to',1,'5',0.00,1 UNION
SELECT 'DAYENDPROCESS4','Day End Process','Perform automatic delivery of pending Bills after                     day(s)',1,'5',1.00,4 UNION
SELECT 'DAYENDPROCESS6','Day End Process','Allow Automatic Delivery',1,'',0.00,6
GO
IF EXISTS (SELECT Name FROM Sysobjects WHERE Xtype = 'P' AND name = 'PROC_RptLoadSheetCollectionFormat')
DROP PROCEDURE PROC_RptLoadSheetCollectionFormat
GO
--EXEC PROC_RptLoadSheetCollectionFormat 19,1,0,'',0,0,1
CREATE PROCEDURE PROC_RptLoadSheetCollectionFormat
(
	@Pi_RptId		    INT,
	@Pi_UsrId		    INT,
	@Pi_SnapId		    INT,
	@Pi_DbName		    NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*******************************************************************************
* CREATED BY	: Gunasekaran
* CREATED DATE	: 18/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------
* {date}		{developer}  {brief modification description}
* 26.02.2010	Panneer		 Added Date,Salesman,route,retailer and Vehicle Filter(Proc_RptCollectionFormat)
*********************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @sSql		AS 	nVarChar(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	
	--Filter Variable
	DECLARE @FromDate	        AS	DATETIME
	DECLARE @ToDate	 	        AS	DATETIME
	DECLARE @VehicleId          AS  INT
	DECLARE @VehicleAllocId     AS	INT
	DECLARE @SMId	 	        AS	INT
	DECLARE @DlvRouteId	        AS	INT
	DECLARE @RtrId	 	        AS	INT
	DECLARE @ColCtnBillsCount	AS	NUMERIC(18,0)
	--Till Here
	
	--Assgin Value for the Filter Variable
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @VehicleId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))
	SET @VehicleAllocId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @DlvRouteId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))	
	--Till Here
	EXEC Proc_RptCollectionFormatLS @Pi_RptId ,@FromDate,@ToDate,@VehicleId,@VehicleAllocId,
								  @SMId,@DlvRouteId,@RtrId,@Pi_UsrId
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	--Till Here
	CREATE TABLE #RptLoadSheetCollectionFormat
	(
		[Bill Number]         NVARCHAR(50),
		[Bill Date]           DATETIME,
		[Billed Amount]       NUMERIC (38,2),  		
		[Retailer Name]       NVARCHAR(50),		
		[Outstand Amount]     NUMERIC (38,2),
		[Id]				  INT,
		[ColCtnBillsCount]    NUMERIC(18,0) 
			  		
	
	)
	SET @TblName = 'RptLoadSheetCollectionFormat'
	
	SET @TblStruct = '[Bill Number]         NVARCHAR(50),
			[Bill Date]           DATETIME,
			[Billed Amount]       NUMERIC (38,2),  		
	  		[Retailer Name]       NVARCHAR(50),		
			[Outstand Amount]     NUMERIC (38,2),
		    [Id]				  INT, 
		    [ColCtnBillsCount]    NUMERIC(18,0)'
	
	SET @TblFields = '[Bill Number],
			[Bill Date]           ,
			[Billed Amount]       ,  		
	  		[Retailer Name]       ,		
			[Outstand Amount]     ,
		    [Id]				  ,
		    [ColCtnBillsCount]    '
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
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		INSERT INTO #RptLoadSheetCollectionFormat ([Bill Number],[Bill Date],[Billed Amount],[Retailer Name],[Outstand Amount],[ColCtnBillsCount])
		SELECT SalInvNo,SalInvDate,dbo.Fn_ConvertCurrency(SalNetAmt,@Pi_CurrencyId) SalNetAmt,RtrNAme,
		dbo.Fn_ConvertCurrency(OutstandAmt,@Pi_CurrencyId) OutstandAmt,0 AS ColCtnBillsCount FROM RtrLoadSheetCollectionFormat
		WHERE (VehicleId = (CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
					VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
		
		AND (Allotmentnumber = (CASE @VehicleAllocId WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
					Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		
		AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		
		AND (DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
					DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
		
		AND (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
					
		AND [SalInvDate] Between @FromDate and @ToDate AND UsrId=@Pi_UsrId
			
	IF LEN(@PurDBName) > 0
	BEGIN
		EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
		SET @SSQL = 'INSERT INTO #RptLoadSheetCollectionFormat ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			
			 + '         WHERE (VehicleId = (CASE ' + @VehicleId + ' WHEN 0 THEN VehicleId ELSE 0 END) OR
							VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',36,' + @Pi_UsrId + ')) )
			
			 AND (Allotmentnumber = (CASE ' + @VehicleAllocId + ' WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
							Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',37,' + @Pi_UsrId + ')) )
			
			 AND (SMId=(CASE ' + @SMId + ' WHEN 0 THEN SMId ELSE 0 END) OR
							SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',1,' + @Pi_UsrId + ')))
			
			 AND (DlvRMId=(CASE ' + @DlvRouteId + ' WHEN 0 THEN DlvRMId ELSE 0 END) OR
							DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',35,' + @Pi_UsrId + ')) )
			
			 AND (RtrId = (CASE ' + @RtrId + ' WHEN 0 THEN RtrId ELSE 0 END) OR
							RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',3,' + @Pi_UsrId + ')))
							
			 AND [SalInvDate] Between ' + @FromDate + ' and ' + @ToDate
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptLoadSheetCollectionFormat'
				
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
			SET @SSQL = 'INSERT INTO #RptLoadSheetCollectionFormat ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptLoadSheetCollectionFormat
	-- Till Here
	
	--Collection Bill Count Added By Sathishkumar Veeramani 2014/07/15	 
	SELECT @ColCtnBillsCount = ISNULL(COUNT(DISTINCT SalId),0) FROM ReceiptInvoice (NOLOCK)
	WHERE CancelStatus = 1 AND InvInsSta <> 4 AND SalInvDate BETWEEN @FromDate and @ToDate
	
	UPDATE #RptLoadSheetCollectionFormat SET [ColCtnBillsCount] = @ColCtnBillsCount
	--Till Here Added By Sathishkumar Veeramani 2014/07/15	
	
	--SELECT * FROM #RptLoadSheetCollectionFormat
	SELECT [Bill Number],CONVERT(VARCHAR(8),[Bill Date],3)[Bill Date],[Retailer Name],[Billed Amount],[Outstand Amount],[ColCtnBillsCount]
	FROM #RptLoadSheetCollectionFormat
	Order BY [Bill Number],[Bill Date],[Retailer Name]
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptLoadSheetCollectionFormat_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptLoadSheetCollectionFormat_Excel
		SELECT [Bill Number],[Bill Date],[Retailer Name],[Billed Amount],[Outstand Amount],[Id] INTO RptLoadSheetCollectionFormat_Excel 
		FROM #RptLoadSheetCollectionFormat ORDER BY [Bill Number]
	END
RETURN
END
GO
--Bill Print CR Salesman Phone Number
IF EXISTS (SELECT Name FROM sysobjects WHERE Xtype = 'U' AND Name = 'RptBillTemplateFinal')
DROP TABLE RptBillTemplateFinal
GO
CREATE TABLE RptBillTemplateFinal(
	[Base Qty] [numeric](38, 2) NULL,
	[Batch Code] [nvarchar](100) NULL,
	[Batch Expiry Date] [datetime] NULL,
	[Batch Manufacturing Date] [datetime] NULL,
	[Batch MRP] [numeric](38, 2) NULL,
	[Batch Selling Rate] [numeric](38, 2) NULL,
	[Bill Date] [datetime] NULL,
	[Bill Doc Ref. Number] [nvarchar](100) NULL,
	[Bill Mode] [tinyint] NULL,
	[Bill Type] [tinyint] NULL,
	[CD Disc Base Qty Amount] [numeric](38, 2) NULL,
	[CD Disc Effect Amount] [numeric](38, 2) NULL,
	[CD Disc Header Amount] [numeric](38, 2) NULL,
	[CD Disc LineUnit Amount] [numeric](38, 2) NULL,
	[CD Disc Qty Percentage] [numeric](38, 2) NULL,
	[CD Disc Unit Percentage] [numeric](38, 2) NULL,
	[CD Disc UOM Amount] [numeric](38, 2) NULL,
	[CD Disc UOM Percentage] [numeric](38, 2) NULL,
	[Company Address1] [nvarchar](100) NULL,
	[Company Address2] [nvarchar](100) NULL,
	[Company Address3] [nvarchar](100) NULL,
	[Company Code] [nvarchar](40) NULL,
	[Company Contact Person] [nvarchar](200) NULL,
	[Company EmailId] [nvarchar](100) NULL,
	[Company Fax Number] [nvarchar](100) NULL,
	[Company Name] [nvarchar](200) NULL,
	[Company Phone Number] [nvarchar](100) NULL,
	[Contact Person] [nvarchar](100) NULL,
	[CST Number] [nvarchar](100) NULL,
	[DB Disc Base Qty Amount] [numeric](38, 2) NULL,
	[DB Disc Effect Amount] [numeric](38, 2) NULL,
	[DB Disc Header Amount] [numeric](38, 2) NULL,
	[DB Disc LineUnit Amount] [numeric](38, 2) NULL,
	[DB Disc Qty Percentage] [numeric](38, 2) NULL,
	[DB Disc Unit Percentage] [numeric](38, 2) NULL,
	[DB Disc UOM Amount] [numeric](38, 2) NULL,
	[DB Disc UOM Percentage] [numeric](38, 2) NULL,
	[DC DATE] [datetime] NULL,
	[DC NUMBER] [nvarchar](200) NULL,
	[Delivery Boy] [nvarchar](100) NULL,
	[Delivery Date] [datetime] NULL,
	[Deposit Amount] [numeric](38, 2) NULL,
	[Distributor Address1] [nvarchar](100) NULL,
	[Distributor Address2] [nvarchar](100) NULL,
	[Distributor Address3] [nvarchar](100) NULL,
	[Distributor Code] [nvarchar](40) NULL,
	[Distributor Name] [nvarchar](100) NULL,
	[Drug Batch Description] [nvarchar](100) NULL,
	[Drug Licence Number 1] [nvarchar](100) NULL,
	[Drug Licence Number 2] [nvarchar](100) NULL,
	[Drug1 Expiry Date] [datetime] NULL,
	[Drug2 Expiry Date] [datetime] NULL,
	[EAN Code] [varchar](50) NULL,
	[EmailID] [nvarchar](100) NULL,
	[Geo Level] [nvarchar](100) NULL,
	[Interim Sales] [tinyint] NULL,
	[Licence Number] [nvarchar](100) NULL,
	[Line Base Qty Amount] [numeric](38, 2) NULL,
	[Line Base Qty Percentage] [numeric](38, 2) NULL,
	[Line Effect Amount] [numeric](38, 2) NULL,
	[Line Unit Amount] [numeric](38, 2) NULL,
	[Line Unit Percentage] [numeric](38, 2) NULL,
	[Line UOM1 Amount] [numeric](38, 2) NULL,
	[Line UOM1 Percentage] [numeric](38, 2) NULL,
	[LST Number] [nvarchar](100) NULL,
	[Manual Free Qty] [int] NULL,
	[Order Date] [datetime] NULL,
	[Order Number] [nvarchar](100) NULL,
	[Pesticide Expiry Date] [datetime] NULL,
	[Pesticide Licence Number] [nvarchar](100) NULL,
	[PhoneNo] [nvarchar](100) NULL,
	[PinCode] [int] NULL,
	[Product Code] [nvarchar](100) NULL,
	[Product Name] [nvarchar](400) NULL,
	[Product Short Name] [nvarchar](200) NULL,
	[Product SL No] [int] NULL,
	[Product Type] [int] NULL,
	[Remarks] [nvarchar](400) NULL,
	[Retailer Address1] [nvarchar](200) NULL,
	[Retailer Address2] [nvarchar](200) NULL,
	[Retailer Address3] [nvarchar](200) NULL,
	[Retailer Code] [nvarchar](100) NULL,
	[Retailer ContactPerson] [nvarchar](200) NULL,
	[Retailer Coverage Mode] [tinyint] NULL,
	[Retailer Credit Bills] [int] NULL,
	[Retailer Credit Days] [int] NULL,
	[Retailer Credit Limit] [numeric](38, 2) NULL,
	[Retailer CSTNo] [nvarchar](100) NULL,
	[Retailer Deposit Amount] [numeric](38, 2) NULL,
	[Retailer Drug ExpiryDate] [datetime] NULL,
	[Retailer Drug License No] [nvarchar](100) NULL,
	[Retailer EmailId] [nvarchar](200) NULL,
	[Retailer GeoLevel] [nvarchar](100) NULL,
	[Retailer License ExpiryDate] [datetime] NULL,
	[Retailer License No] [nvarchar](100) NULL,
	[Retailer Name] [nvarchar](300) NULL,
	[Retailer OffPhone1] [nvarchar](100) NULL,
	[Retailer OffPhone2] [nvarchar](100) NULL,
	[Retailer OnAccount] [numeric](38, 2) NULL,
	[Retailer Pestcide ExpiryDate] [datetime] NULL,
	[Retailer Pestcide LicNo] [nvarchar](100) NULL,
	[Retailer PhoneNo] [nvarchar](100) NULL,
	[Retailer Pin Code] [nvarchar](100) NULL,
	[Retailer ResPhone1] [nvarchar](100) NULL,
	[Retailer ResPhone2] [nvarchar](100) NULL,
	[Retailer Ship Address1] [nvarchar](200) NULL,
	[Retailer Ship Address2] [nvarchar](200) NULL,
	[Retailer Ship Address3] [nvarchar](200) NULL,
	[Retailer ShipId] [int] NULL,
	[Retailer TaxType] [tinyint] NULL,
	[Retailer TINNo] [nvarchar](100) NULL,
	[Retailer Village] [nvarchar](200) NULL,
	[Route Code] [nvarchar](100) NULL,
	[Route Name] [nvarchar](100) NULL,
	[Sales Invoice Number] [nvarchar](100) NULL,
	[SalesInvoice ActNetRateAmount] [numeric](38, 2) NULL,
	[SalesInvoice CDPer] [numeric](38, 2) NULL,
	[SalesInvoice CRAdjAmount] [numeric](38, 2) NULL,
	[SalesInvoice DBAdjAmount] [numeric](38, 2) NULL,
	[SalesInvoice GrossAmount] [numeric](38, 2) NULL,
	[SalesInvoice Line Gross Amount] [numeric](38, 2) NULL,
	[SalesInvoice Line Net Amount] [numeric](38, 2) NULL,
	[SalesInvoice MarketRetAmount] [numeric](38, 2) NULL,
	[SalesInvoice NetAmount] [numeric](38, 2) NULL,
	[SalesInvoice NetRateDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice OnAccountAmount] [numeric](38, 2) NULL,
	[SalesInvoice OtherCharges] [numeric](38, 2) NULL,
	[SalesInvoice RateDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice ReplacementDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice RoundOffAmt] [numeric](38, 2) NULL,
	[SalesInvoice TotalAddition] [numeric](38, 2) NULL,
	[SalesInvoice TotalDeduction] [numeric](38, 2) NULL,
	[SalesInvoice WindowDisplayAmount] [numeric](38, 2) NULL,
	[SalesMan Code] [nvarchar](100) NULL,
	[SalesMan Name] [nvarchar](100) NULL,
	[SalId] [int] NULL,
	[Sch Disc Base Qty Amount] [numeric](38, 2) NULL,
	[Sch Disc Effect Amount] [numeric](38, 2) NULL,
	[Sch Disc Header Amount] [numeric](38, 2) NULL,
	[Sch Disc LineUnit Amount] [numeric](38, 2) NULL,
	[Sch Disc Qty Percentage] [numeric](38, 2) NULL,
	[Sch Disc Unit Percentage] [numeric](38, 2) NULL,
	[Sch Disc UOM Amount] [numeric](38, 2) NULL,
	[Sch Disc UOM Percentage] [numeric](38, 2) NULL,
	[Scheme Points] [numeric](38, 2) NULL,
	[Spl. Disc Base Qty Amount] [numeric](38, 2) NULL,
	[Spl. Disc Effect Amount] [numeric](38, 2) NULL,
	[Spl. Disc Header Amount] [numeric](38, 2) NULL,
	[Spl. Disc LineUnit Amount] [numeric](38, 2) NULL,
	[Spl. Disc Qty Percentage] [numeric](38, 2) NULL,
	[Spl. Disc Unit Percentage] [numeric](38, 2) NULL,
	[Spl. Disc UOM Amount] [numeric](38, 2) NULL,
	[Spl. Disc UOM Percentage] [numeric](38, 2) NULL,
	[Tax 1] [numeric](38, 2) NULL,
	[Tax 2] [numeric](38, 2) NULL,
	[Tax 3] [numeric](38, 2) NULL,
	[Tax 4] [numeric](38, 2) NULL,
	[Tax Amount1] [numeric](38, 2) NULL,
	[Tax Amount2] [numeric](38, 2) NULL,
	[Tax Amount3] [numeric](38, 2) NULL,
	[Tax Amount4] [numeric](38, 2) NULL,
	[Tax Amt Base Qty Amount] [numeric](38, 2) NULL,
	[Tax Amt Effect Amount] [numeric](38, 2) NULL,
	[Tax Amt Header Amount] [numeric](38, 2) NULL,
	[Tax Amt LineUnit Amount] [numeric](38, 2) NULL,
	[Tax Amt Qty Percentage] [numeric](38, 2) NULL,
	[Tax Amt Unit Percentage] [numeric](38, 2) NULL,
	[Tax Amt UOM Amount] [numeric](38, 2) NULL,
	[Tax Amt UOM Percentage] [numeric](38, 2) NULL,
	[Tax Type] [tinyint] NULL,
	[TIN Number] [nvarchar](100) NULL,
	[Uom 1 Desc] [nvarchar](100) NULL,
	[Uom 1 Qty] [int] NULL,
	[Uom 2 Desc] [nvarchar](100) NULL,
	[Uom 2 Qty] [int] NULL,
	[Vehicle Name] [nvarchar](100) NULL,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL,
	[Distributor Product Code] [nvarchar](100) NULL,
	[Allotment No] [nvarchar](100) NULL,
	[Bx Selling Rate] [numeric](38, 2) NULL,
	[AmtInWrd] [nvarchar](500) NULL,
	[Product Weight] [numeric](38, 6) NULL,
	[Product UPC] [numeric](38, 6) NULL,
	[Payment Mode] [nvarchar](20) NULL,
	[InvDisc] [numeric](18, 2) NULL,
	[InvDiscPer] [numeric](18, 2) NULL
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='SalesmanPhoneNo')
BEGIN
	ALTER TABLE RptBillTemplateFinal ADD SalesmanPhoneNo NUMERIC (18,0) DEFAULT 0 WITH VALUES 
END
GO
IF EXISTS (SELECT Name FROM sysobjects WHERE Xtype = 'P' AND Name = 'Proc_RptBillTemplateFinal')
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
* 01.10.2009		Panneer	   Added Tax summary Report Part(UserId Condition)
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
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDiscPer')    
		BEGIN  
			SET @SSQL1='UPDATE A SET A.SalesmanPhoneNo=ISNULL(B.SMPhoneNumber,0) FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesMan B (NOLOCK) 
						ON A.[SalesMan Code]=B.SMCode AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
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
--Kit Item Product Short Name, Company Product Code Editable
DELETE FROM CustomCaptions WHERE TransId = 91 AND CtrlId = 1000 AND SubCtrlId = 20
INSERT INTO CustomCaptions
SELECT 91,1000,20,'MsgBox-91-1000-20','','','Allowed to edit only for Kit Item products',1,1,1,GETDATE(),1,GETDATE(),'','','Allowed to edit only for Kit Item products',1,1
GO
--Monthly Statement Report
DELETE FROM RptGroup WHERE RptId = 282
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',282,'MonthlyStockStatment','Monthly Stock Statement',1
GO
DELETE FROM RptHeader WHERE RptId = 282
INSERT INTO RptHeader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'MonthlyStockStatement','Monthly Stock Statement',282,'Monthly Stock Statement','Proc_RptMonthlyStockStatement',
'RptMonthlyStockStatement','RptMonthlyStockStatement.rpt',''
GO
DELETE FROM RptDetails WHERE RptId = 282
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (282,1,'FromDate',-1,NULL,'','From Date*',NULL,1,NULL,10,0,0,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (282,2,'ToDate',-1,NULL,'','To Date*',NULL,1,NULL,11,0,0,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (282,3,'Company',-1,NULL,'CmpId,CmpCode,CmpName','Company...',NULL,1,NULL,4,1,0,'Press F4/Double Click to select Company',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (282,4,'ProductCategoryLevel',3,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,0,'Press F4/Double Click to select Product Hierarchy Level',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (282,5,'ProductCategoryValue',4,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,0,0,'Press F4/Double Click to select Product Hierarchy Level Value',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (282,6,'Product',5,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,0,0,'Press F4/Double Click to select Product',0)
GO
DELETE FROM RptFormula WHERE RptId = 282
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,1,'FromDate','From Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,2,'ToDate','To Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,3,'Company','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,4,'ProductCategoryLevel','Product Hierarchy Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,5,'ProductCategoryValue','Product Hierarchy Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,6,'Total','Grand Total ',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,7,'Disp_FromDate','FromDate',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,8,'Disp_ToDate','ToDate',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,9,'Disp_Company','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,10,'Disp_ProductCategoryLevel','ProductCategoryLevel',1,16)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,11,'Disp_ProductCategoryValue','ProductCategoryLevelValue',1,21)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,12,'Cap Page','Page',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,13,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,14,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,15,'Cap_Product','Product',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,16,'Disp_Product','Product',1,5)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,17,'ProductName','PRODUCT NAME',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,18,'PKT','PKT',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,19,'MRP','MRP',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,20,'OpeningStock','OPENING',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,21,'PurchaseStock','RECEIPT',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,22,'SalesStock','SECONDARY',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,23,'ClosingStock','CLOSING',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,24,'Case','CASE',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (282,25,'Units','UNITS',1,0)
GO
DELETE FROM RptExcelHeaders WHERE RptId = 282
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (282,1,'[Product Code]','Product Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (282,2,'[Product Name]','Product Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (282,3,'[PKT]','PKT',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (282,4,'[MRP]','MRP',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (282,5,'[OpeningStockCase]','Opening Stock Case',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (282,6,'[OpeningStockUnits]','Opening Stock Units',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (282,7,'[PurchaseStockCase]','Receipt Stock Case',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (282,8,'[PurchaseStockUnits]','Receipt Stock Units',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (282,9,'[SalesStockCase]','Secondary Stock Case',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (282,10,'[SalesStockUnits]','Secondary Stock Units',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (282,11,'[ClosingStockCase]','Closing Stock Case',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (282,12,'[ClosingStockUnits]','Closing Stock Units',1,1)
GO
DELETE FROM RptGridView WHERE RptId = 282
INSERT INTO RptGridView (RptId,RptName,CrystalView,GridView,ExcelView,PDFView)
SELECT DISTINCT RPTID,RptName,1,0,1,0 FROM RptHeader WITH(NOLOCK) WHERE RptId = 282
GO
IF EXISTS (SELECT Name FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_RptMonthlyStockStatement')
DROP PROCEDURE Proc_RptMonthlyStockStatement
GO
--EXEC Proc_RptMonthlyStockStatement 282,1,0,'CoreStocky',0,0,1
CREATE PROCEDURE Proc_RptMonthlyStockStatement
(
	@Pi_RptId		    INT,
	@Pi_UsrId		    INT,
	@Pi_SnapId		    INT,
	@Pi_DbName		    NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/********************************************************************
* PROCEDURE	    : Proc_RptMonthlyStockStatement
* PURPOSE	    : To Generate the Monthly Stock Statement Details
* CREATED	    : Sathishkumar Veeramani
* CREATED DATE	: 04/07/2014
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
---------------------------------------------------------------------
* {date}		{developer}		  {brief modification description}
*********************************************************************/
BEGIN
	SET NOCOUNT ON
	DECLARE @ErrNo	 	AS	INT 
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @CmpId 		AS	INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))

	CREATE TABLE #RptMonthlyStockStatement
	(   
	    [Product Code]                    NVARCHAR(200),
		[Product Name] 			          NVARCHAR(200),
		[PKT]	                          NUMERIC(18,0),
		[MRP]                             NUMERIC(18,2),
		[OpeningStockCase] 		          NUMERIC(18,0),
		[OpeningStockUnits] 		      NUMERIC(18,0),
		[PurchaseStockCase] 		      NUMERIC(18,0),
		[PurchaseStockUnits] 		      NUMERIC(18,0),
		[SalesStockCase] 		          NUMERIC(18,0),
		[SalesStockUnits] 		          NUMERIC(18,0),
		[ClosingStockCase] 		          NUMERIC(18,0),
		[ClosingStockUnits] 		      NUMERIC(18,0),
		[UsrId]	                          NUMERIC(18,0)
	)
	
	SELECT DISTINCT A.PrdId,PrdDCode,PrdName,PrdBatId,SUM(SalOpenStock) AS OpeningStock,(SUM(SalPurchase)-SUM(SalPurReturn)) AS PurchaseStock,
    (SUM(SalSales)-SUM(SalSalesReturn)) AS SalesStock,SUM(SalClsStock) AS SalClsStock
    INTO #SalabelStockDetails FROM StockLedger A (NOLOCK) INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId 
    WHERE TransDate BETWEEN @FromDate AND @ToDate AND
          (A.PrdId = (CASE @PrdCatId WHEN 0 THEN A.PrdId Else 0 END) OR
			  A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))) AND 
	      (A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else 0 END) OR
			  A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  GROUP BY A.PrdId,PrdBatId,PrdDCode,PrdName 
    HAVING (SUM(SalOpenStock)+(SUM(SalPurchase)-SUM(SalPurReturn))+(SUM(SalSales)-SUM(SalSalesReturn))+SUM(SalClsStock)) <> 0 
    ORDER BY A.PrdId,PrdBatId
    
    SELECT DISTINCT A.PrdId,A.PrdBatId,C.PrdBatDetailValue AS MRP INTO #ProductBatchDetails FROM #SalabelStockDetails A
    INNER JOIN ProductBatch B (NOLOCK) ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
    INNER JOIN ProductBatchDetails C (NOLOCK) ON A.PrdBatId = C.PrdBatId AND B.PrdBatId = C.PrdBatId
    INNER JOIN (SELECT DISTINCT PrdBatId,MAX(PriceId) AS PriceId FROM ProductBatchDetails D (NOLOCK) GROUP BY PrdBatId) D 
    ON C.PrdBatId = D.PrdBatId AND C.PriceId = D.PriceId
    INNER JOIN BatchCreation BC (NOLOCK) ON B.BatchSeqId = BC.BatchSeqId AND C.SlNo = BC.SlNo AND MRP = 1
    ORDER BY A.PrdId,A.PrdBatId
    
    SELECT A.PrdId,B.ConversionFactor AS PKT INTO #UomGroup FROM Product A (NOLOCK) 
    INNER JOIN UomGroup B (NOLOCK) ON A.UomGroupId = B.UomGroupId
    INNER JOIN (SELECT DISTINCT UomGroupId,MAX(ConversionFactor) AS ConversionFactor FROM UomGroup A (NOLOCK) GROUP BY UomGroupId) C
    ON B.UomGroupId = C.UomGroupId AND B.ConversionFactor = C.ConversionFactor
    INNER JOIN #SalabelStockDetails D ON A.PrdID = D.PrdId ORDER BY A.PrdId
    
    SELECT DISTINCT A.PrdId,PrdDCode,PrdName,PKT,MRP,OpeningStock,PurchaseStock,SalesStock,SalClsStock INTO #RptMonthlyStock
    FROM #SalabelStockDetails A INNER JOIN #ProductBatchDetails B ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
    INNER JOIN #UomGroup C ON A.PrdId = C.PrdId ORDER BY A.PrdId
    
    INSERT INTO #RptMonthlyStockStatement ([Product Code],[Product Name],[PKT],[MRP],[OpeningStockCase],[OpeningStockUnits],
    [PurchaseStockCase],[PurchaseStockUnits],[SalesStockCase],[SalesStockUnits],[ClosingStockCase],[ClosingStockUnits],[UsrId])
    SELECT DISTINCT PrdDCode,PrdName,PKT,MRP,CAST(CASE WHEN SUM(OpeningStock)<PKT THEN 0 ELSE SUM(OpeningStock)/PKT END AS BIGINT) AS OpeningStockCase,
    CAST(CASE WHEN SUM(OpeningStock)<PKT THEN SUM(OpeningStock) ELSE SUM(OpeningStock)%PKT END AS BIGINT )AS OpeningStockUnits,
    CAST(CASE WHEN SUM(PurchaseStock)<PKT THEN 0 ELSE SUM(PurchaseStock)/PKT END AS BIGINT) AS PurchaseStockCase,
    CAST(CASE WHEN SUM(PurchaseStock)<PKT THEN SUM(PurchaseStock) ELSE SUM(PurchaseStock)%PKT END AS BIGINT )AS PurchaseStockUnits,
    CAST(CASE WHEN SUM(SalesStock)<PKT THEN 0 ELSE SUM(SalesStock)/PKT END AS BIGINT) AS SalesStockCase,
    CAST(CASE WHEN SUM(SalesStock)<PKT THEN SUM(SalesStock) ELSE SUM(SalesStock)%PKT END AS BIGINT )AS SalesStockUnits,
    CAST(CASE WHEN SUM(SalClsStock)<PKT THEN 0 ELSE SUM(SalClsStock)/PKT END AS BIGINT) AS ClosingStockCase,
    CAST(CASE WHEN SUM(SalClsStock)<PKT THEN SUM(SalClsStock) ELSE SUM(SalClsStock)%PKT END AS BIGINT )AS ClosingStockUnits,@Pi_UsrId            
    FROM #RptMonthlyStock GROUP BY PrdDCode,PrdName,PKT,MRP
    		
	--Check for Report Data
	DELETE FROM RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId

	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,COUNT(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptMonthlyStockStatement WHERE UsrId = @Pi_UsrId
	-- Till Here
	
	SELECT DISTINCT [Product Code],[Product Name],[PKT],[MRP],[OpeningStockCase],[OpeningStockUnits],[PurchaseStockCase],[PurchaseStockUnits],
	[SalesStockCase],[SalesStockUnits],[ClosingStockCase],[ClosingStockUnits] FROM #RptMonthlyStockStatement WHERE UsrId = @Pi_UsrId
	
RETURN
END
GO
--Billing UOM Conversion Total
IF EXISTS (SELECT Name FROM Sysobjects WHERE Xtype IN ('FN','TF') AND name = 'Fn_ReturnBillingUOMWiseTotal')
DROP FUNCTION Fn_ReturnBillingUOMWiseTotal
GO
--SELECT DISTINCT * FROM Fn_ReturnBillingUOMWiseTotal (3)  
CREATE FUNCTION Fn_ReturnBillingUOMWiseTotal (@PrdId NUMERIC(18,0))  
RETURNS @ReturnBillingUOMWiseTotal TABLE  
 (  
    UomId              NUMERIC(18,0),  
    UomCode            NVARCHAR(100),
    ConversionFactor   NUMERIC(18,0)
 )  
AS  
BEGIN  
/*********************************  
* FUNCTION   : Fn_ReturnBillingUOMWiseTotal  
* PURPOSE    : Returns the Maximum Conversion Factor UOM Details 
* NOTES:  
* CREATED    : Sathishkumar Veeramani 2014/07/03  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/  
    INSERT INTO @ReturnBillingUOMWiseTotal (UomId,UomCode,ConversionFactor)  
	SELECT DISTINCT A.UomId,UomCode,B.ConversionFactor FROM UomMaster A (NOLOCK) 
	INNER JOIN UomGroup B (NOLOCK) ON A.UomId = B.UomId 
	INNER JOIN (SELECT DISTINCT UomGroupId,MAX(ConversionFactor) AS ConvQty FROM UomGroup UG (NOLOCK) GROUP BY UomGroupId) C 
	ON B.UomGroupId = C.UomGroupId AND B.ConversionFactor = C.ConvQty
	INNER JOIN Product D (NOLOCK) ON B.UomGroupId = D.UomGroupId WHERE PrdId = @PrdId
RETURN  
END
GO
IF EXISTS (SELECT Name FROM Sysobjects WHERE XTYPE = 'P' AND Name = 'Proc_Validate_Product')
DROP PROCEDURE Proc_Validate_Product
GO
--EXEC Proc_Validate_Product 0
CREATE PROCEDURE Proc_Validate_Product
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Validate_Product
* PURPOSE		: To Insert and Update records in the Table Product
* CREATED		: Nandakumar R.G
* CREATED DATE	: 17/09/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist     AS  INT
	DECLARE @Tabname    AS  NVARCHAR(100)
	DECLARE @DestTabname   AS  NVARCHAR(100)
	DECLARE @Fldname    AS  NVARCHAR(100)
	DECLARE @PrdDCode    AS NVARCHAR(100)
	DECLARE @PrdName   AS NVARCHAR(100)
	DECLARE @PrdShortName  AS NVARCHAR(100)
	DECLARE @PrdCCode   AS NVARCHAR(100)
	DECLARE @PrdCtgValCode  AS NVARCHAR(100)
	DECLARE @StkCoverDays  AS NVARCHAR(100)
	DECLARE @UnitPerSKU   AS NVARCHAR(100)
	DECLARE @TaxGroupCode  AS NVARCHAR(100)
	DECLARE @Weight    AS NVARCHAR(100)
	DECLARE @UnitCode   AS NVARCHAR(100)
	DECLARE @UOMGroupCode  AS NVARCHAR(100)
	DECLARE @PrdType   AS NVARCHAR(100)
	DECLARE @EffectiveFromDate AS NVARCHAR(100)
	DECLARE @EffectiveToDate AS NVARCHAR(100)
	DECLARE @ShelfLife   AS NVARCHAR(100)
	DECLARE @Status    AS NVARCHAR(100)
	DECLARE @Vending   AS NVARCHAR(100)
	DECLARE @PrdVending   AS INT
	DECLARE @EANCode  AS NVARCHAR(100)
	DECLARE @CmpId   AS  INT
	DECLARE @PrdId   AS  INT
	DECLARE @CmpPrdCtgId  AS  INT
	DECLARE @PrdCtgMainId  AS  INT
	DECLARE @SpmId   AS  INT
	DECLARE @PrdUnitId AS  INT
	DECLARE @TaxGroupId AS  INT
	DECLARE @UOMGroupId AS  INT
	DECLARE @PrdTypeId AS  INT
	DECLARE @PrdStatus AS  INT
	SET @Po_ErrNo=0
	SET @Exist=0
	SET @DestTabname='Product'
	SET @Fldname='PrdId'
	SET @Tabname = 'ETL_Prk_Product'
	SET @Exist=0
	SELECT @SpmId=SpmId FROM Supplier WITH (NOLOCK) WHERE SpmDefault=1
	DECLARE Cur_Product CURSOR
	FOR SELECT ISNULL([Product Distributor Code],''),ISNULL([Product Name],''),ISNULL([Product Short Name],''),ISNULL([Product Company Code],''),
	ISNULL([Product Hierarchy Level Value Code],''),ISNULL([Stock Cover Days],0),ISNULL([Unit Per SKU],1),
	ISNULL([Tax Group Code],''),ISNULL([Weight],0),[Unit Code],[UOM Group Code],[Product Type],CONVERT(NVARCHAR(12),[Effective From Date],121),
	CONVERT(NVARCHAR(12),[Effective To Date],121),ISNULL([Shelf Life],0),ISNULL([Status],'ACTIVE'),ISNULL([EAN Code],''),ISNULL([Vending],'NO')
	FROM ETL_Prk_Product
	OPEN Cur_Product
	FETCH NEXT FROM Cur_Product INTO @PrdDCode,@PrdName,@PrdShortName,@PrdCCode,@PrdCtgValCode,
	@StkCoverDays,@UnitPerSKU,@TaxGroupCode,@Weight,@UnitCode,@UOMGroupCode,@PrdType,@EffectiveFromDate,
	@EffectiveToDate,@ShelfLife,@Status,@EANCode,@Vending
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0
		SET @Exist=0
		IF NOT EXISTS(SELECT * FROM ProductCategoryValue WITH (NOLOCK) WHERE PrdCtgValCode=@PrdCtgValCode)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Category Level',
			'Product Category Level:'+@PrdCtgValCode+' is not available for the Product Code: '+@PrdDCode)
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @CmpId=PCL.CmpId FROM ProductCategoryLevel PCL WITH (NOLOCK),
			ProductCategoryValue PCV WITH (NOLOCK)
			WHERE PCV.PrdCtgValCode=@PrdCtgValCode AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId
			IF(SELECT ISNULL(PC.LevelName,'') FROM ProductCategoryValue PCV
			WITH (NOLOCK),ProductCategoryLevel PC WITH (NOLOCK)
			WHERE PCV.PrdCtgValCode=@PrdCtgValCode AND PC.CmpPrdCtgId=PCV.CmpPrdCtgId)<>
			(SELECT TOP 1 PC.LevelName FROM ProductCategoryLevel PC
			WHERE CmpId=@CmpId AND CmpPrdCtgId NOT IN (SELECT MAX(CmpPrdCtgId) FROM  ProductCategoryLevel PC WHERE CmpId=@CmpId)
			ORDER BY PC.CmpPrdCtgId DESC)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Category Level',
				'Product Category Level:'+@PrdCtgValCode+' is not last level in the hierarchy')
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @PrdCtgMainId=PrdCtgValMainId FROM ProductCategoryValue WITH (NOLOCK)
				WHERE PrdCtgValCode=@PrdCtgValCode
			END
		END
	
--		IF @Po_ErrNo=0
--		BEGIN
--			IF @TaxGroupCode<>''
--			BEGIN
--				IF NOT EXISTS(SELECT * FROM TaxGroupSetting WITH (NOLOCK)
--				WHERE PrdGroup=@TaxGroupCode)
--				BEGIN
--					INSERT INTO Errorlog VALUES (1,@TabName,'Tax Group',
--					'Tax Group:'+@TaxGroupCode+' is not available for the Product Code: '+@PrdDCode)
--					SET @Po_ErrNo=1
--				END
--				ELSE
--				BEGIN
--					SELECT @TaxGroupId=TaxGroupId FROM TaxGroupSetting WITH (NOLOCK)
--					WHERE PrdGroup=@TaxGroupCode
--				END
--			END
--			ELSE
--			BEGIN
				SET @TaxGroupId=0
--			END
--		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM UOMGroup WITH (NOLOCK) WHERE UOMGroupCode=@UOMGroupCode)
				BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'UOM Group',
				'UOM Group:'+@UOMGroupCode+' is not available for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @UOMGroupId=UOMGroupId FROM UOMGroup WITH (NOLOCK) WHERE UOMGroupCode=@UOMGroupCode
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @PrdType='Normal'
			BEGIN
				SET @PrdTypeId=1
			END
			ELSE IF @PrdType='Pesticide'
			BEGIN
				SET @PrdTypeId=2
			END
			ELSE IF @PrdType='Kit Product'
			BEGIN
				SET @PrdTypeId=3
			END
			ELSE IF @PrdType='Gift'
			BEGIN
				SET @PrdTypeId=4
			END
			ELSE IF @PrdType='Drug'
			BEGIN
				SET @PrdTypeId=5
			END
			ELSE IF @PrdType='Food'
			BEGIN
				SET @PrdTypeId=6
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Type',
				'Product Type'+@PrdType+' is not available for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @PrdTypeId=3 OR @PrdTypeId=5
			BEGIN
				IF ISDATE(@EffectiveFromDate)=1 AND ISDATE(@EffectiveToDate)=1
				BEGIN
					IF DATEDIFF(DD,@EffectiveFromDate,@EffectiveToDate)<0 OR DATEDIFF(DD,GETDATE(),@EffectiveToDate)<0
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Date',
						'Effective From Date:' + @EffectiveFromDate + 'should be less than Effective To Date:' +@EffectiveToDate +' for the Product Code: '+@PrdDCode)
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Date',
					'Effective From or To Date is wrong for the Product Code: '+@PrdDCode)
					SET @Po_ErrNo=1
				END
			END
			ELSE
			BEGIN
				IF NOT ISDATE(@EffectiveFromDate)=1
				BEGIN
					SET @EffectiveFromDate=CONVERT(NVARCHAR(10),GETDATE(),121)
				END
	
				IF NOT ISDATE(@EffectiveFromDate)=1
				BEGIN
					SET @EffectiveToDate=CONVERT(NVARCHAR(10),GETDATE(),121)
				END
			END
		END
	
		IF @PrdTypeId=3
		BEGIN
			SET @EffectiveToDate=DATEADD(yy,3,@EffectiveFromDate)
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM ProductUnit WITH (NOLOCK)
			WHERE PrdUnitCode=@UnitCode)
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Unit',
				'Product Unit'+@UnitCode+' is not available for the Product Code: '+@PrdDCode)
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @PrdUnitId=PrdUnitId FROM ProductUnit WITH (NOLOCK)
				WHERE PrdUnitCode=@UnitCode
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF UPPER(@Status)='ACTIVE' OR @Status='1'
			BEGIN
				SET @PrdStatus=1
			END
			ELSE
			BEGIN
			   SET @PrdStatus=2
			END
		END	
		IF @Po_ErrNo=0
		BEGIN
			IF UPPER(@Vending)='YES'
			BEGIN
				SET @PrdVending=1
			END
			ELSE IF UPPER(@Vending)='NO'
			BEGIN
				SET @PrdVending=0
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCCode)
			BEGIN
				SET @Exist=0
			END
			ELSE
			BEGIN
				SET @Exist=1
				SELECT @PrdId=PrdId FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCCode
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @Exist=0
			BEGIN
				SELECT @PrdId=dbo.Fn_GetPrimaryKeyInteger(@DestTabname,@FldName,
				CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
				
				IF @PrdId>(SELECT ISNULL(MAX(PrdId),0) FROM Product(NOLOCK))
				BEGIN
					INSERT INTO Product(PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,
					PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,EffectiveFrom,EffectiveTo,PrdShelfLife,PrdStatus,
					CmpId,PrdCtgValMainId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
					IMEIEnabled,IMEILength,EANCode,Vending,XmlUpload)
					VALUES(@PrdId,@PrdName,@PrdShortName,@PrdDCode,@PrdCCode,@SpmId,@StkCoverDays,@UnitPerSKU,@Weight,
					@PrdUnitId,@UOMGroupId,@TaxGroupId,@PrdTypeId,@EffectiveFromDate,@EffectiveToDate,@ShelfLife,
					@PrdStatus,@CmpId,@PrdCtgMainId,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),
					GETDATE(),121),0,0,@EANCode,ISNULL(@PrdVending,0),0)
					UPDATE Counters SET CurrValue=@PrdId WHERE TabName=@DestTabname AND FldName=@FldName
					
					--Added By Sathishkumar Veeramani 2014/07/14 ContractPricing Details Updated
					DELETE A FROM ContractPricingDetails A (NOLOCK) INNER JOIN ContractPricingMaster B (NOLOCK) ON A.ContractId = B.ContractId
					WHERE B.DisplayMode = 1 AND A.PrdId = @PrdId
					
					INSERT INTO ContractPricingDetails (ContractId,PrdId,PrdBatId,PriceId,Discount,FlatAmtDisc,Availability,
					LastModBy,LastModDate,AuthId,AuthDate,CtgValMainId,ClaimablePercOnMRP)
					SELECT DISTINCT ContractId,PrdId,0 AS PrdBatId,0 AS PriceId,Discount,FlatAmtDisc,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),
					1,CONVERT(NVARCHAR(10),GETDATE(),121),CtgValMainId,0 AS ClaimablePercOnMRP FROM (
					SELECT DISTINCT MAX(A.ContractId) AS ContractId,CtgLevelId,CtgMainId,RtrClassId,E.PrdId,Discount,
					FlatAmtDisc,B.CtgValMainId FROM ContractPricingMaster A (NOLOCK) 
					INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId = B.ContractId
					INNER JOIN ProductCategoryValue C (NOLOCK) ON A.CmpPrdCtgId = C.CmpPrdCtgId AND B.CtgValMainId = C.PrdCtgValMainId
					INNER JOIN ProductCategoryValue D (NOLOCK) ON D.PrdCtgValLinkCode LIKE C.PrdCtgValLinkCode+'%'
					INNER JOIN Product E (NOLOCK) ON D.PrdCtgValMainId = E.PrdCtgValMainId
					WHERE A.DisplayMode = 1 AND E.PrdId = @PrdId GROUP BY CtgLevelId,CtgMainId,RtrClassId,E.PrdId,Discount,FlatAmtDisc,B.CtgValMainId)Qry
					--Added By Sathishkumar Veeramani 2014/07/14 Till Here
				END
				ELSE
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'System Date',
					'System is showing Date as :'+GETDATE()+'. Please change the System Date/Reset the Counters')
					SET @Po_ErrNo=1
				END
			END
			ELSE
			BEGIN
				EXEC Proc_DependencyCheck 'Product',@PrdId
				IF (SELECT COUNT(*) FROM TempDepCheck)>0
				BEGIN
					UPDATE Product SET SpmId=@SpmId,StkCovDays=@StkCoverDays,PrdUpSKU=@UnitPerSKU,
					EffectiveFrom=@EffectiveFromDate,EffectiveTo=@EffectiveToDate,PrdShelfLife=@ShelfLife,
					PrdStatus=@PrdStatus,EanCode=@EANCode,Vending=ISNULL(@PrdVending,0),PrdCtgValMainId=@PrdCtgMainId
					WHERE PrdId=@PrdId
				END
				ELSE
				BEGIN
					UPDATE Product SET SpmId=@SpmId,StkCovDays=@StkCoverDays,PrdUpSKU=@UnitPerSKU,
					UOMGroupId=@UOMGroupId,PrdType=@PrdTypeId,
					EffectiveFrom=@EffectiveFromDate,EffectiveTo=@EffectiveToDate,
					PrdShelfLife=@ShelfLife,PrdStatus=@PrdStatus,EanCode=@EANcode,Vending=ISNULL(@PrdVending,0),PrdCtgValMainId=@PrdCtgMainId
					WHERE PrdId=@PrdId
				END
			END
		END
	
		FETCH NEXT FROM Cur_Product INTO @PrdDCode,@PrdName,@PrdShortName,@PrdCCode,@PrdCtgValCode,
		@StkCoverDays,@UnitPerSKU,@TaxGroupCode,@Weight,@UnitCode,@UOMGroupCode,@PrdType,@EffectiveFromDate,
		@EffectiveToDate,@ShelfLife,@Status,@EANCode,@Vending
	END
	CLOSE Cur_Product
	DEALLOCATE Cur_Product
	SET @Po_ErrNo=0
	RETURN
END
GO
IF EXISTS (SELECT Name FROM Sysobjects WHERE XTYPE = 'P' AND Name = 'Proc_ReturnSplDiscount')
DROP PROCEDURE Proc_ReturnSplDiscount
GO
--EXEC Proc_ReturnSplDiscount 4,3,6,'2014-03-18',0,0,0,0,0,0
CREATE PROCEDURE Proc_ReturnSplDiscount
(
	@Pi_PrdId		INT,
	@Pi_PrdBatId		INT,
	@Pi_RtrId		INT,
	@Pi_InvDate			DATETIME,
	@Po_SplDiscount		NUMERIC(38,6) 	OUTPUT,
	@Po_SplFlatAmount	NUMERIC(38,6) 	OUTPUT,
	@Po_SplPriceId		INT 		OUTPUT,
	@Po_MRP			NUMERIC(38,6) 	OUTPUT,
	@Po_SellRate		NUMERIC(38,6) 	OUTPUT,
	@Po_ClaimablePercOnMRP	NUMERIC(38,6) 	OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ReturnSplDiscount
* PURPOSE	: To Return the Special Discount for the Selected Retailer and Product
* CREATED	: Thrinath
* CREATED DATE	: 29/04/2007
* NOTE		: General SP for Returning the Special Discount for the Selected Retailer and Product
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}      {developer}       {brief modification description}
* 24/03/2009  Nandakumar R.G	Addition of Tax Group
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ContractId AS INT
	DECLARE @RtrTaxGroupId AS INT
	DECLARE @PrdCtgValMainId	AS INT
	DECLARE @DiscAlone			AS INT
	SET @ContractId = 0
	SET @Po_SplDiscount = 0
	SET @Po_SplFlatAmount = 0
	SET @Po_SplPriceId = 0
	SET @Po_MRP = 0
	SET @Po_SellRate = 0
	SET @DiscAlone=0
	SELECT @RtrTaxGroupId=TaxGroupId FROM Retailer WHERE RtrId=@Pi_RtrId
	SELECT @PrdCtgValMainId=PrdCtgValMainId FROM Product WHERE PrdId=@Pi_PrdId	
	--Return Contract Price Id if set at Retailer Level
	SELECT @ContractId = ISNULL(MAX(ContractId),0) FROM ContractPricingMaster CP WHERE RtrId = @Pi_RtrId
	AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId	
	
	--SELECT '1',@ContractId,@DiscAlone
	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM  ContractPricingMaster A (NOLOCK) INNER JOIN ContractPricingDetails B ON A.ContractId = B.ContractId
		WHERE A.ContractId=@ContractId AND PrdId=@Pi_PrdId AND 	PrdBatId=(CASE DisplayMode WHEN 0 THEN 
		(CASE AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE PrdBatId END) ELSE PrdBatId END))
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '2',@ContractId,@DiscAlone
	--Return Contract Price Id if set at Retailer Value Class Level with Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.RtrClassId = RVCM.RtrValueClassId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			--AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			AND CPD.PrdBatId=(CASE CP.DisplayMode WHEN 0 THEN (CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END) ELSE CPD.PrdBatId END) 		 
			WHERE R.RtrId =@Pi_RtrId AND CP.RtrId = 0 AND CP.RtrtaxGroupId=R.TaxGroupId
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	
	--SELECT '3',@ContractId,@DiscAlone
	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM  ContractPricingMaster A (NOLOCK) INNER JOIN ContractPricingDetails B ON A.ContractId = B.ContractId
		WHERE A.ContractId=@ContractId AND PrdId=@Pi_PrdId AND 	PrdBatId=(CASE DisplayMode WHEN 0 THEN 
		(CASE AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE PrdBatId END) ELSE PrdBatId END))
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '4',@ContractId,@DiscAlone
	--Return Contract Price Id if set at Retailer Value Class Level without Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.RtrClassId = RVCM.RtrValueClassId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			--AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			AND CPD.PrdBatId=(CASE CP.DisplayMode WHEN 0 THEN (CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END) ELSE CPD.PrdBatId END)
			WHERE R.RtrId =@Pi_RtrId AND CP.RtrId = 0
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '5',@ContractId,@DiscAlone	
	
	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM  ContractPricingMaster A (NOLOCK) INNER JOIN ContractPricingDetails B ON A.ContractId = B.ContractId
		WHERE A.ContractId=@ContractId AND PrdId=@Pi_PrdId AND 	PrdBatId=(CASE DisplayMode WHEN 0 THEN 
		(CASE AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE PrdBatId END) ELSE PrdBatId END))
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '6',@ContractId,@DiscAlone
	--Return Contract Price Id if set at Retailer Category Level Value with Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.CtgMainId = RVC.CtgMainId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			--AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			AND CPD.PrdBatId=(CASE CP.DisplayMode WHEN 0 THEN (CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END) ELSE CPD.PrdBatId END)
			WHERE R.RtrId =@Pi_RtrId AND CP.RtrId = 0 AND CP.RtrClassId = 0 AND CP.RtrtaxGroupId=R.TaxGroupId
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '7',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM  ContractPricingMaster A (NOLOCK) INNER JOIN ContractPricingDetails B ON A.ContractId = B.ContractId
		WHERE A.ContractId=@ContractId AND PrdId=@Pi_PrdId AND 	PrdBatId=(CASE DisplayMode WHEN 0 THEN 
		(CASE AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE PrdBatId END) ELSE PrdBatId END))
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '8',@ContractId,@DiscAlone
	--Return Contract Price Id if set at Retailer Category Level Value without Tax Group-Group Level
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId AND R.RtrId=@Pi_RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.CtgMainId = RVC.CtgMainId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			--AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			AND CPD.PrdBatId=(CASE CP.DisplayMode WHEN 0 THEN (CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END) ELSE CPD.PrdBatId END)
			WHERE (CP.RtrId = @Pi_RtrId OR CP.RtrId = 0) AND CP.RtrClassId = 0 AND CP.PrdCtgValMainId IN (0,@PrdCtgValMainId)
			--Retailer Categorly Level updated By Alphonse J on 2014-03-18
			IF @ContractId = 0
			BEGIN
				SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
				INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId AND R.RtrId=@Pi_RtrId
				INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
				INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
				INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
				INNER JOIN ContractPricingMaster CP ON CP.CtgMainId = RVC.CtgMainId
				AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
				INNER JOIN ProductCategoryValue PCV ON CP.PrdCtgValMainId=PCV.PrdCtgValMainId 
				INNER JOIN ProductCategoryValue PCV1 ON PCV1.PrdCtgValLinkCode LIKE PCV.PrdCtgValLinkCode+'%'
				INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
				--AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			    AND CPD.PrdBatId=(CASE CP.DisplayMode WHEN 0 THEN (CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END) ELSE CPD.PrdBatId END)
				WHERE (CP.RtrId = @Pi_RtrId OR CP.RtrId = 0) AND CP.RtrClassId = 0 AND PCV1.PrdCtgValMainId IN (@PrdCtgValMainId)
			END
		--SELECT * FROM ContractPricingMaster
	END	
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT  '9',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM  ContractPricingMaster A (NOLOCK) INNER JOIN ContractPricingDetails B ON A.ContractId = B.ContractId
		WHERE A.ContractId=@ContractId AND PrdId=@Pi_PrdId AND PrdBatId=(CASE DisplayMode WHEN 0 THEN 
		(CASE AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE PrdBatId END) ELSE PrdBatId END))
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '10',@ContractId,@DiscAlone


	--Return Contract Price Id if set at Retailer Category Level Value without Tax Group-Channel Level
	IF @ContractId = 0
	BEGIN
			SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId AND R.RtrId=@Pi_RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RCG ON RCG.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategory RCC ON RCC.CtgMainId = RCG.CtgLinkId
			INNER JOIN RetailerCategoryLevel RCL ON RCC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.CtgMainId = RCC.CtgMainId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			--AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			AND CPD.PrdBatId=(CASE CP.DisplayMode WHEN 0 THEN (CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END) ELSE CPD.PrdBatId END)
			WHERE (CP.RtrId = @Pi_RtrId OR CP.RtrId = 0) AND CP.RtrClassId = 0 AND CP.PrdCtgValMainId IN (0,@PrdCtgValMainId)

		--SELECT * FROM ContractPricingMaster
	END	
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT  '9-1',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM  ContractPricingMaster A (NOLOCK) INNER JOIN ContractPricingDetails B ON A.ContractId = B.ContractId
		WHERE A.ContractId=@ContractId AND PrdId=@Pi_PrdId AND 	PrdBatId=(CASE DisplayMode WHEN 0 THEN 
		(CASE AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE PrdBatId END) ELSE PrdBatId END))
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '10-1',@ContractId,@DiscAlone


	--Return Contract Price Id if set at Retailer Category Level with Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.CtgLevelId = RCL.CtgLevelId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			--AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			AND CPD.PrdBatId=(CASE CP.DisplayMode WHEN 0 THEN (CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END) ELSE CPD.PrdBatId END)
			WHERE R.RtrId =@Pi_RtrId AND CP.RtrId = 0 AND CP.RtrClassId = 0
			AND CP.CtgMainId = 0 AND CP.RtrtaxGroupId=R.TaxGroupId
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '11',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM  ContractPricingMaster A (NOLOCK) INNER JOIN ContractPricingDetails B ON A.ContractId = B.ContractId
		WHERE A.ContractId=@ContractId AND PrdId=@Pi_PrdId AND 	PrdBatId=(CASE DisplayMode WHEN 0 THEN 
		(CASE AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE PrdBatId END) ELSE PrdBatId END))
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '12',@ContractId,@DiscAlone

	--Return Contract Price Id if set at Retailer Category Level without Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Retailer  R
			INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId
			INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
			INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
			INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
			INNER JOIN ContractPricingMaster CP ON CP.CtgLevelId = RCL.CtgLevelId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			--AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			AND CPD.PrdBatId=(CASE CP.DisplayMode WHEN 0 THEN (CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END) ELSE CPD.PrdBatId END)
			WHERE R.RtrId =@Pi_RtrId AND CP.RtrId = 0 AND CP.RtrClassId = 0 AND CP.CtgMainId = 0
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '13',@ContractId,@DiscAlone
	
	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM  ContractPricingMaster A (NOLOCK) INNER JOIN ContractPricingDetails B ON A.ContractId = B.ContractId
		WHERE A.ContractId=@ContractId AND PrdId=@Pi_PrdId AND 	PrdBatId=(CASE DisplayMode WHEN 0 THEN 
		(CASE AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE PrdBatId END) ELSE PrdBatId END))
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '14',@ContractId,@DiscAlone

	--Return Contract Price Id if set at Company Level For all Retailer with Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Product P 
			INNER JOIN ContractPricingMaster CP ON CP.CmpId = P.CmpId 
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId 
			--AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			AND CPD.PrdBatId=(CASE CP.DisplayMode WHEN 0 THEN (CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END) ELSE CPD.PrdBatId END)
			WHERE P.PrdId =@Pi_PrdId AND CP.RtrId = 0 AND CP.RtrClassId = 0 AND CP.CtgMainId = 0
			AND CP.CtgLevelId = 0 AND CP.RtrtaxGroupId=@RtrTaxGroupId
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '15',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM  ContractPricingMaster A (NOLOCK) INNER JOIN ContractPricingDetails B ON A.ContractId = B.ContractId
		WHERE A.ContractId=@ContractId AND PrdId=@Pi_PrdId AND 	PrdBatId=(CASE DisplayMode WHEN 0 THEN 
		(CASE AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE PrdBatId END) ELSE PrdBatId END))
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	----SELECT '16',@ContractId,@DiscAlone

	--Return Contract Price Id if set at Company Level For all Retailer without Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM Product P
			INNER JOIN ContractPricingMaster CP ON CP.CmpId = P.CmpId
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId
			--AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			AND CPD.PrdBatId=(CASE CP.DisplayMode WHEN 0 THEN (CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END) ELSE CPD.PrdBatId END)
			WHERE P.PrdId =@Pi_PrdId AND CP.RtrId = 0 AND CP.RtrClassId = 0 AND CP.CtgMainId = 0
			AND CP.CtgLevelId = 0
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '17',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM  ContractPricingMaster A (NOLOCK) INNER JOIN ContractPricingDetails B ON A.ContractId = B.ContractId
		WHERE A.ContractId=@ContractId AND PrdId=@Pi_PrdId AND 	PrdBatId=(CASE DisplayMode WHEN 0 THEN 
		(CASE AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE PrdBatId END) ELSE PrdBatId END))
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END	
	--SELECT '18',@ContractId,@DiscAlone

	--Return Contract Price Id if set at Company Level For all Retailer with Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM ContractPricingMaster CP
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId
			--AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			AND CPD.PrdBatId=(CASE CP.DisplayMode WHEN 0 THEN (CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END) ELSE CPD.PrdBatId END)
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			WHERE CP.RtrId = 0 AND CP.RtrClassId = 0 AND CP.CtgMainId = 0
			AND CP.CtgLevelId = 0 AND CP.CmpId = 0 AND CP.RtrtaxGroupId=@RtrTaxGroupId
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '19',@ContractId,@DiscAlone

	IF @DiscAlone=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM  ContractPricingMaster A (NOLOCK) INNER JOIN ContractPricingDetails B ON A.ContractId = B.ContractId
		WHERE A.ContractId=@ContractId AND PrdId=@Pi_PrdId AND 	PrdBatId=(CASE DisplayMode WHEN 0 THEN 
		(CASE AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE PrdBatId END) ELSE PrdBatId END))
		BEGIN
			 SET @ContractId=0
		END
	ELSE
		IF NOT EXISTS(SELECT * FROM ContractPricingDetails WHERE ContractId=@ContractId AND
		PrdId=@Pi_PrdId)
		BEGIN
			 SET @ContractId=0
		END
	END
	--SELECT '20',@ContractId,@DiscAlone

	--Return Contract Price Id if set at Company Level For all Retailer without Tax Group
	IF @ContractId = 0
	BEGIN
		SELECT @ContractId = ISNULL(MAX(CP.ContractId),0) FROM ContractPricingMaster CP
			INNER JOIN ContractPricingDetails CPD ON CP.ContractId= CPD.ContractId AND CPD.PrdID=@Pi_PrdId
			--AND CPD.PrdBatId=(CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END)
			AND CPD.PrdBatId=(CASE CP.DisplayMode WHEN 0 THEN (CASE CP.AllowDiscount WHEN 0 THEN @Pi_PrdBatId ELSE CPD.PrdBatId END) ELSE CPD.PrdBatId END)
			AND CP.Status=1 AND @Pi_InvDate BETWEEN CP.ValidFromDate AND CP.ValidTillDate
			WHERE CP.RtrId = 0 AND CP.RtrClassId = 0 AND CP.CtgMainId = 0
			AND CP.CtgLevelId = 0 AND CP.CmpId = 0
	END
	SELECT @DiscAlone=ISNULL(AllowDiscount,0) FROM ContractPricingMaster WHERE ContractId=@ContractId
	--SELECT '21',@ContractId,@DiscAlone

	IF @ContractId = 0
	BEGIN
		SET @Po_SplDiscount = 0
		SET @Po_SplFlatAmount = 0
		SET @Po_SplPriceId = 0
		SET @Po_MRP = 0
		SET @Po_SellRate = 0
		SET @Po_ClaimablePercOnMRP = 0
	END
	ELSE
	BEGIN
		SELECT @Po_SplDiscount = Discount, @Po_SplFlatAmount = FlatAmtDisc,
		@Po_SplPriceId = PriceId, @Po_ClaimablePercOnMRP = ClaimablePercOnMRP 
		FROM ContractPricingMaster A (NOLOCK) INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId = B.ContractId
		WHERE A.ContractId = @ContractId AND PrdId =@Pi_PrdId AND PrdBatId = (CASE PrdBatId WHEN 0 THEN PrdBatId ELSE @Pi_PrdBatId END)
		--PrdBatId = (CASE @DiscAlone WHEN 0 THEN Pi_PrdBatId ELSE PrdBatId END)		

		IF EXISTS (Select PrdBatId From ProductBatchDetails WHERE PriceId = @Po_SplPriceId AND PrdBatId = @Pi_PrdBatId AND DefaultPrice=1)
		BEGIN
			SET @Po_SplPriceId = 0
			SET @Po_MRP = 0
			SET @Po_SellRate = 0
		END
		ELSE
		BEGIN
			SELECT @Po_MRP = B.PrdBatDetailValue , @Po_SellRate = D.PrdBatDetailValue
				FROM ProductBatch A (NOLOCK)
				INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID
				INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = B.BatchSeqId
				AND B.SlNo = C.SlNo AND C.MRP = 1 INNER JOIN ProductBatchDetails D (NOLOCK) ON
				A.PrdBatId = D.PrdBatID INNER JOIN BatchCreation E (NOLOCK) ON
				E.BatchSeqId = D.BatchSeqId AND D.SlNo = E.SlNo AND E.SelRte = 1
				WHERE A.Status = 1 AND A.PrdId=@Pi_PrdId AND B.PriceId = @Po_SplPriceId
				AND D.PriceID = @Po_SplPriceId AND A.PrdBatId = @Pi_PrdBatId
		END
	END    
RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='Rpt_SalesTax_UPVAT_SubRpt')
DROP TABLE Rpt_SalesTax_UPVAT_SubRpt
GO
CREATE TABLE Rpt_SalesTax_UPVAT_SubRpt
(
	SlNo						NUMERIC(38,0) IDENTITY (1,1),
	RptId						INT,
	RptHeader					VARCHAR(50),
	UsrId						INT,
	TaxName						VARCHAR(25),
	TaxableAmt					NUMERIC(38,6),
	Tax							NUMERIC(18,2),
	TaxAmt						NUMERIC(38,6),
	SatAmt						NUMERIC(38,6),
	TOTALAmt					NUMERIC(38,6)
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='PROC_SalesTax_UPVAT')
DROP PROCEDURE PROC_SalesTax_UPVAT
GO
--EXEC PROC_SalesTax_UPVAT 276,2,0,'PARLE',0,0,1
CREATE PROCEDURE [dbo].[PROC_SalesTax_UPVAT]
(
	@Pi_RptId		    INT,
	@Pi_UsrId		    INT,
	@Pi_SnapId		    INT,
	@Pi_DbName		    NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/************************************************************
* PROCEDURE	: PROC_SalesTax_UPVAT
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
	DECLARE @Year		VARCHAR(10)
	DECLARE @RptType	INT
	DECLARE @CmpId		INT
	DECLARE @SpmId		INT
	DECLARE @RtrId		INT
	DECLARE @PurReptId	BIGINT
	DECLARE @SalId		BIGINT
	DECLARE @TaxType TINYINT
	
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @CmpId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @RptType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,314,@Pi_UsrId))
	SET @TaxType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,200,@Pi_UsrId))
	IF @RptType=1
	BEGIN
		SET @RtrId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
		SET @SalId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	END
	ELSE
	BEGIN
		SET @SpmId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId))
		SET @PurReptId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId))
	END
	
	SET @Year = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	DECLARE @Tbl_TAXTYPE TABLE (TaxType TINYINT)
	
	IF @TaxType=0
	BEGIN
		INSERT INTO @Tbl_TAXTYPE (TaxType) SELECT 0 UNION SELECT 1
	END
	ELSE
	BEGIN
		INSERT INTO @Tbl_TAXTYPE (TaxType) SELECT CASE @TaxType WHEN 1 THEN 0 WHEN 2 THEN 1 END
	END
	
	SELECT @Year=CAST(B.AcmYr AS VARCHAR(5))+'-' +CAST (B.AcmYr+1 AS VARCHAR(5)) FROM ACPeriod A INNER JOIN ACMaster B ON A.AcmId=B.AcmId
	WHERE CONVERT(VARCHAR(10),@ToDate,121)  BETWEEN AcmSdt AND AcmEdt
	IF ISNULL(@YEAR,'')='' SET @YEAR=''
	IF @RptType=1
	BEGIN
		SELECT R.* INTO #Retailer FROM Retailer R WHERE EXISTS (SELECT * FROM @Tbl_TAXTYPE E WHERE E.TaxType=R.RtrTaxType)
		
		SELECT S.* INTO #SalesInvoice FROM SalesInvoice S (NOLOCK) INNER JOIN #Retailer R  ON R.RtrId=S.RtrId
		WHERE SalinvDate BETWEEN @FromDate AND @ToDate AND DlvSts>3
		AND
		(SalId=(CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
					SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
		AND
		(S.RtrId=(CASE @RtrId WHEN 0 THEN S.RtrId ELSE 0 END) OR
					S.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
					
		SELECT SP.* INTO #SalesInvoiceProduct FROM #SalesInvoice S (NOLOCK) 
		INNER JOIN SalesInvoiceProduct SP (NOLOCK)  ON S.SalId=SP.SalId
	
		SELECT T.* INTO #SalesInvoiceProductTax_Main FROM #SalesInvoice S (NOLOCK)
		INNER JOIN #SalesInvoiceProduct SP (NOLOCK) ON SP.SalId=S.SalId
		INNER JOIN SalesInvoiceProductTax T (NOLOCK)  ON T.SalId=SP.SalId AND T.SalId=S.SalId AND T.PrdSlNo=SP.SlNo
		INNER JOIN TaxConfiguration TC ON TC.TaxId=T.TaxId
		WHERE T.TaxableAmount>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode)))='VAT'
		
		SELECT T.*  INTO #SalesInvoiceProductTax_ADD FROM #SalesInvoice S (NOLOCK)
		INNER JOIN #SalesInvoiceProduct SP (NOLOCK) ON SP.SalId=S.SalId
		INNER JOIN SalesInvoiceProductTax T (NOLOCK)  ON T.SalId=SP.SalId AND T.SalId=S.SalId AND T.PrdSlNo=SP.SlNo
		INNER JOIN TaxConfiguration TC ON TC.TaxId=T.TaxId
		WHERE T.TaxableAmount>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode)))='ADDVAT'
		
		SELECT R.* INTO #ReturnHeader FROM ReturnHeader R (NOLOCK) INNER JOIN #Retailer RR ON R.RtrId=RR.RtrId
		WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND Status=0
		AND
		(R.RtrId=(CASE @RtrId WHEN 0 THEN R.RtrId ELSE 0 END) OR
					R.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		SELECT SP.* INTO #ReturnProduct FROM #ReturnHeader S (NOLOCK) 
		INNER JOIN ReturnProduct SP (NOLOCK)  ON S.ReturnID=SP.ReturnID
		WHERE
		(SP.SalId=(CASE @SalId WHEN 0 THEN SP.SalId ELSE 0 END) OR
					SP.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
		
		SELECT SPT.* INTO #ReturnProductTax_Main FROM #ReturnHeader S (NOLOCK) 
		INNER JOIN #ReturnProduct SP (NOLOCK)  ON S.ReturnID=SP.ReturnID
		INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID AND SP.ReturnID=SPT.ReturnID AND SPT.PrdSlNo=SP.SlNo
		INNER JOIN TaxConfiguration TC ON TC.TaxId=SPT.TaxId
		WHERE TaxableAmt>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode)))='VAT'
		
		SELECT SPT.* INTO #ReturnProductTax_ADD FROM #ReturnHeader S (NOLOCK) 
		INNER JOIN #ReturnProduct SP (NOLOCK)  ON S.ReturnID=SP.ReturnID
		INNER JOIN ReturnProductTax SPT (NOLOCK)  ON S.ReturnID=SPT.ReturnID AND SP.ReturnID=SPT.ReturnID AND SPT.PrdSlNo=SP.SlNo
		INNER JOIN TaxConfiguration TC ON TC.TaxId=SPT.TaxId
		WHERE TaxableAmt>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode)))='ADDVAT'
	END
	ELSE IF @RptType=3
	BEGIN
		SELECT P.* INTO #PurchaseReceipt FROM PurchaseReceipt P (NOLOCK) WHERE GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND Status=1
		AND 
		(PurRcptId =(CASE @PurReptId WHEN 0 THEN PurRcptId ELSE 0 END) OR
					PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId)))
		AND
		(SpmId =(CASE @SpmId WHEN 0 THEN SpmId ELSE 0 END) OR
					SpmId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))
							
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
		WHERE PRT.TaxableAmount>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode)))='ADDVAT'
	END
	
	CREATE TABLE #Rpt_SalesTax_UPVAT
	(
		SlNo						NUMERIC(38,0) IDENTITY (1,1),
		RptHeader					VARCHAR(50),
		NameOfPurchaseDealer		VARCHAR(50),
		AssesmentYear				VARCHAR(10),
		TaxPeriodEnds				DATETIME,
		NameOfPurchaseDealerAdd1	VARCHAR(50),
		NameOfPurchaseDealerAdd2	VARCHAR(50),
		NameOfPurchaseDealerAdd3	VARCHAR(50),
		NameOfPurchaseDealerTinNo	VARCHAR(50),
		RtrId						INT,
		NameOfPurchaseDealerDt		VARCHAR(50),
		TinNo						VARCHAR(50),
		SalId						BIGINT,
		TaxInvoiceNo				VARCHAR(50),
		TaxInvoiceDate				DATETIME,
		NameOfCommodity				VARCHAR(50),
		CodeOfCommodity				VARCHAR(50),
		Quantity					BIGINT,
		TaxableAmt					NUMERIC(38,6),
		Tax							NUMERIC(18,2),
		TaxAmt						NUMERIC(38,6),
		SAT							NUMERIC(18,2),
		SATValue					NUMERIC(38,6),
		TOTALAmt					NUMERIC(38,6),
		RptId						INT,
		UsrId						INT,
		TypeId						TINYINT
	)		
	 
	
	DECLARE @ACENDDATE DATETIME
	SELECT @ACENDDATE=ISNULL(AcmEdt,'') FROM ACPERIOD WHERE AcpId IN (
	SELECT ISNULL(MAX(AcpId),0) FROM ACPERIOD AP INNER JOIN ACMASTER AM ON AM.AcmId=AP.AcmId
	WHERE ACMYR=YEAR(@ToDate))
	
	IF @RptType=1
	BEGIN
		INSERT INTO #Rpt_SalesTax_UPVAT (RptHeader,NameOfPurchaseDealer,AssesmentYear,TaxPeriodEnds,NameOfPurchaseDealerAdd1,
										NameOfPurchaseDealerAdd2,NameOfPurchaseDealerAdd3,NameOfPurchaseDealerTinNo,RtrId,NameOfPurchaseDealerDt,
										TinNo,SalId,TaxInvoiceNo,TaxInvoiceDate,NameOfCommodity,CodeOfCommodity,Quantity,TaxableAmt,Tax,TaxAmt,SAT,
										SATValue,TOTALAmt,RptId,UsrId,TypeId)
		SELECT 'Sale in Own Account' RptHeader,D.DistributorName,@Year AssesmentYear,@ACENDDATE TaxPeriodEnds,D.DistributorAdd1,D.DistributorAdd2,
		D.DistributorAdd3,D.TinNo,R.RtrId,R.RtrName,R.RtrTinNo,S.SalId,S.SalInvNo,S.SalInvDate,'' NameOfCommodity,'' CodeOfCommodity,
		SUM(SP.BaseQty) Quantity,SUM(T.TaxableAmount) TaxableAmount,T.TaxPerc,SUM(T.TaxAmount) TaxAmount,ISNULL(AD.TaxPerc,0) SAT,SUM(ISNULL(AD.TaxAmount,0)) SATAmt,
		SUM(T.TaxableAmount)+SUM(T.TaxAmount)+SUM(ISNULL(AD.TaxAmount,0)) TotalAmt,
		@Pi_RptId,@Pi_UsrId,1	FROM #SalesInvoice S (NOLOCK)
		INNER JOIN #SalesInvoiceProduct SP (NOLOCK) ON SP.SalId=S.SalId
		INNER JOIN #SalesInvoiceProductTax_Main T (NOLOCK)  ON T.SalId=SP.SalId AND T.SalId=S.SalId AND T.PrdSlNo=SP.SlNo
		INNER JOIN Retailer R (NOLOCK) ON S.RtrId=R.RtrId
		LEFT OUTER JOIN #SalesInvoiceProductTax_ADD AD ON AD.SalId=SP.SalId AND AD.SalId=S.SalId AND AD.PrdSlNo=SP.SlNo AND AD.SalId=T.SalId
		CROSS JOIN Distributor D (NOLOCK)
		GROUP BY D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3,D.TinNo,R.RtrId,	
		R.RtrName,R.RtrTinNo,S.SalId,S.SalInvNo,S.SalInvDate,T.TaxPerc,AD.TaxPerc
		HAVING SUM(T.TaxableAmount)>0
		
		INSERT INTO #Rpt_SalesTax_UPVAT (RptHeader,NameOfPurchaseDealer,AssesmentYear,TaxPeriodEnds,NameOfPurchaseDealerAdd1,
										NameOfPurchaseDealerAdd2,NameOfPurchaseDealerAdd3,NameOfPurchaseDealerTinNo,RtrId,NameOfPurchaseDealerDt,
										TinNo,SalId,TaxInvoiceNo,TaxInvoiceDate,NameOfCommodity,CodeOfCommodity,Quantity,TaxableAmt,Tax,TaxAmt,SAT,
										SATValue,TOTALAmt,RptId,UsrId,TypeId)
		Select distinct 'Sale in Own Account' RptHeader,D.DistributorName,@Year AssesmentYear,@ACENDDATE TaxPeriodEnds,D.DistributorAdd1,D.DistributorAdd2,
		D.DistributorAdd3,D.TinNo,R.RtrId,R.RtrName,R.RtrTINNo,RH.ReturnID,RH.ReturnCode,RH.ReturnDate,'' NameOfCommodity,'' CodeOfCommodity,
		-1* SUM(RP.BaseQty) Qty,-1 * Sum(RPT.TaxableAmt) as TaxableAmount,RPT.TaxPerc,-1 *SUM(RPT.TaxAmt) TaxAmt,ISNULL(AD.TaxPerc,0) SAT,SUM(ISNULL(AD.TaxAmt,0)) SATAmt,
		-1* Sum(RPT.TaxableAmt)+SUM(RPT.TaxAmt)+SUM(ISNULL(AD.TaxAmt,0)) TotalAmt,
		@Pi_RptId,@Pi_UsrId,2	From #ReturnHeader RH WITH (NOLOCK)  
		INNER JOIN #ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1  
		INNER JOIN #ReturnProductTax_Main RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo
		LEFT OUTER JOIN #ReturnProductTax_ADD AD WITH (NOLOCK) ON AD.ReturnId = RH.ReturnId AND AD.ReturnId = RP.ReturnId AND AD.PrdSlNo=RP.Slno  AND AD.ReturnId=RPT.ReturnId 
		INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId  
		CROSS JOIN Distributor D (NOLOCK)
		WHERE RH.Status = 0   
		Group By D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3,D.TinNo,R.RtrId,R.RtrName,R.RtrTINNo,
		RH.ReturnID,RH.ReturnCode,RH.ReturnDate,RPT.TaxPerc,AD.TaxPerc
		HAVING Sum(RPT.TaxableAmt) > 0	
		
		TRUNCATE TABLE Rpt_SalesTax_UPVAT_SubRpt 
		INSERT INTO Rpt_SalesTax_UPVAT_SubRpt(RptId,RptHeader,UsrId,TaxName,TaxableAmt,Tax,TaxAmt,SatAmt,TOTALAmt)
		SELECT  @Pi_RptId,'Sale in Own Account',@Pi_UsrId,'TAX TOTAL '+ CAST(SAT AS VARCHAR(10)),0 TaxableAmt,SAT,0,SUM(SATValue) TaxAmt,
			0 ToTALAmt FROM #Rpt_SalesTax_UPVAT 
		GROUP BY SAT HAVING SUM(SATValue)>0

		INSERT INTO Rpt_SalesTax_UPVAT_SubRpt(RptId,RptHeader,UsrId,TaxName,TaxableAmt,Tax,TaxAmt,SatAmt,TOTALAmt)
		SELECT  @Pi_RptId,'Sale in Own Account',@Pi_UsrId,'TAX TOTAL '+ CAST(Tax AS VARCHAR(10)),SUM(TaxableAmt) TaxableAmt,Tax,SUM(TaxAmt) TaxAmt,0,
			SUM(TOTALAmt) ToTALAmt FROM #Rpt_SalesTax_UPVAT
		GROUP BY Tax HAVING SUM(TaxAmt)>0		
			
	END
	ELSE IF @RptType=3
	BEGIN
		INSERT INTO #Rpt_SalesTax_UPVAT (RptHeader,NameOfPurchaseDealer,AssesmentYear,TaxPeriodEnds,NameOfPurchaseDealerAdd1,
										NameOfPurchaseDealerAdd2,NameOfPurchaseDealerAdd3,NameOfPurchaseDealerTinNo,RtrId,NameOfPurchaseDealerDt,
										TinNo,SalId,TaxInvoiceNo,TaxInvoiceDate,NameOfCommodity,CodeOfCommodity,Quantity,TaxableAmt,Tax,TaxAmt,SAT,
										SATValue,TOTALAmt,RptId,UsrId,TypeId)
		SELECT DISTINCT 'Purchase in Own Account' AS RptHeader,D.DistributorName,@Year AssesmentYear,@ACENDDATE TaxPeriodEnds,D.DistributorAdd1,
		D.DistributorAdd2,D.DistributorAdd3,D.TinNo,S.SpmId,S.SpmName,S.SpmTinNo,PR.PurRcptId,PR.PurRcptRefNo,PR.GoodsRcvdDate,'' NameOfCommodity,
		'' CodeOfCommodity,SUM(PRP.INVBASEQTY),SUM(PT.TaxableAmount) AS TAXABLEAMOUNT,PT.TAXPERC,SUM(PT.TAXAMOUNT) TAXAMOUNT
		,ISNULL(AD.TaxPerc,0) SAT,SUM(ISNULL(AD.TaxAmount,0)) SATAmt,SUM(PT.TaxableAmount)+SUM(PT.TAXAMOUNT)+SUM(ISNULL(AD.TaxAmount,0)) TotalAmt,@Pi_RptId,@Pi_UsrId,1
		FROM #PurchaseReceipt PR WITH (NOLOCK)  --SELECT * FROM PURCHASERECEIPT
		INNER JOIN #PurchaseReceiptProduct PRP WITH (NOLOCK) ON PR.PURRCPTID = PRP.PURRCPTID  
		INNER JOIN #PurchaseReceiptProductTax_Main PT WITH (NOLOCK) ON PR.PURRCPTID = PT.PURRCPTID AND PRP.PRDSLNO = PT.PRDSLNO AND PRP.PURRCPTID = PT.PURRCPTID
		LEFT OUTER JOIN #PurchaseReceiptProductTax_ADD AD WITH (NOLOCK) ON PR.PURRCPTID = AD.PURRCPTID AND PRP.PRDSLNO = AD.PRDSLNO AND PRP.PURRCPTID = AD.PURRCPTID AND PT.PurRcptId=AD.PurRcptId    
		INNER JOIN SUPPLIER S WITH (NOLOCK) ON PR.SPMID = S.SPMID  
		LEFT OUTER JOIN COMPANY C ON C.CMPID = PR.CMPID
		CROSS JOIN Distributor D
		WHERE PR.STATUS = 1    
		GROUP BY PT.TaxPerc,AD.TaxPerc,PR.INVDATE,C.CMPID,PR.PURRCPTID,PR.PURRCPTREFNO,PR.CMPINVNO,D.DistributorAdd1,D.DistributorName,
		D.DistributorAdd2,D.DistributorAdd3,D.TinNo,S.SpmId,S.SpmName,S.SpmTinNo,PR.PurRcptId,PR.PurRcptRefNo,PR.GoodsRcvdDate 
		HAVING SUM(PT.TaxableAmount)> 0
				
		TRUNCATE TABLE Rpt_SalesTax_UPVAT_SubRpt 
		INSERT INTO Rpt_SalesTax_UPVAT_SubRpt(RptId,RptHeader,UsrId,TaxName,TaxableAmt,Tax,TaxAmt,SatAmt,TOTALAmt)
		SELECT  @Pi_RptId,'Purchase in Own Account',@Pi_UsrId,'TAX TOTAL '+ CAST(SAT AS VARCHAR(10)),0 TaxableAmt,SAT,0,SUM(SATValue) TaxAmt,
			0 ToTALAmt FROM #Rpt_SalesTax_UPVAT 
		GROUP BY SAT HAVING SUM(SATValue)>0

		INSERT INTO Rpt_SalesTax_UPVAT_SubRpt(RptId,RptHeader,UsrId,TaxName,TaxableAmt,Tax,TaxAmt,SatAmt,TOTALAmt)
		SELECT  @Pi_RptId,'Purchase in Own Account',@Pi_UsrId,'TAX TOTAL '+ CAST(Tax AS VARCHAR(10)),SUM(TaxableAmt) TaxableAmt,Tax,SUM(TaxAmt) TaxAmt,0,
			SUM(TOTALAmt) ToTALAmt FROM #Rpt_SalesTax_UPVAT
		GROUP BY Tax HAVING SUM(TaxAmt)>0
	END
	
	INSERT INTO #Rpt_SalesTax_UPVAT (RptHeader,NameOfPurchaseDealer,AssesmentYear,TaxPeriodEnds,NameOfPurchaseDealerAdd1,
										NameOfPurchaseDealerAdd2,NameOfPurchaseDealerAdd3,NameOfPurchaseDealerTinNo,RtrId,NameOfPurchaseDealerDt,
										TinNo,SalId,TaxInvoiceNo,TaxInvoiceDate,NameOfCommodity,CodeOfCommodity,Quantity,TaxableAmt,Tax,TaxAmt,SAT,
										SATValue,TOTALAmt,RptId,UsrId,TypeId)
	SELECT RptHeader,'' NameOfPurchaseDealer,'' AssesmentYear,'' TaxPeriodEnds,'' NameOfPurchaseDealerAdd1,
										'' NameOfPurchaseDealerAdd2,'' NameOfPurchaseDealerAdd3,'' NameOfPurchaseDealerTinNo,0 RtrId,
										TaxName NameOfPurchaseDealerDt,
										'Total' TinNo,0 SalId,'' TaxInvoiceNo,'' TaxInvoiceDate,'' NameOfCommodity,'' CodeOfCommodity,0 Quantity,
										TaxableAmt AS TaxableAmt,Tax AS Tax,TaxAmt AS TaxAmt,0 SAT,
										SatAmt SATValue,TOTALAmt,RptId,UsrId,0 TypeId FROM Rpt_SalesTax_UPVAT_SubRpt

	DELETE FROM RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM #Rpt_SalesTax_UPVAT
	SELECT * FROM #Rpt_SalesTax_UPVAT ORDER BY SlNo
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_RptLoadSheetItemWiseParle' AND XTYPE='P')
DROP  PROCEDURE Proc_RptLoadSheetItemWiseParle
GO
--EXEC Proc_RptLoadSheetItemWiseParle 251,1,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptLoadSheetItemWiseParle
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
* CREATED BY	: Gunasekaran
* CREATED DATE	: 18/07/2007
* NOTE		:
* MODIFIED	:
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
Modified by Praveenraj B For Parle LoadingSheet CR On 27/01/2012
* 02/07/2013	Jisha Mathew	PARLECS/0613/008	
* 11/11/2013	Jisha Mathew	Bug No:30616
*************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @sSql		AS 	nVarChar(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	--Added by Sathishkumar Veeramani 2013/04/25
	DECLARE @Prdid AS INT
	DECLARE @PrdCode AS Varchar(50)
	DECLARE @PrdBatchCode AS Varchar(50)
	DECLARE @UOMSalId AS INT
	DECLARE @BaseQty AS INT
	DECLARE @FUOMID AS INT
	DECLARE @FCONVERSIONFACTOR AS INT
	DECLARE @StockOnHand AS INT
	DECLARE @Converted AS INT
	DECLARE @Remainder AS INT
	DECLARE @COLUOM AS VARCHAR(50)
	DECLARE @Sql AS VARCHAR(5000)
	DECLARE @SlNo AS INT
	--Till Here
	--Jisha
	DECLARE @TotConverted AS INT
	DECLARE @TotRemainder AS INT	
	DECLARE @TotalQty as INT	
	--
	
	--Filter Variable
	DECLARE @FromDate	   AS	DATETIME
	DECLARE @ToDate	 	   AS	DATETIME
	DECLARE @VehicleId     AS  INT
	DECLARE @VehicleAllocId AS	INT
	DECLARE @SMId	 	AS	INT
	DECLARE @DlvRouteId	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @UOMId	 	AS	INT
	DECLARE @FromBillNo AS  BIGINT
	DECLARE @ToBillNo   AS  BIGINT
	DECLARE @SalId   AS     BIGINT
    DECLARE @OtherCharges AS NUMERIC(18,2)   
	--DECLARE @BillNoDisp   AS INT
	--DECLARE @DispOrderby AS INT
	--Till Here
	
	EXEC Proc_RptItemWise @Pi_RptId ,@Pi_UsrId
	
	--Assgin Value for the Filter Variable
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @VehicleId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))
	SET @VehicleAllocId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @DlvRouteId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @UOMId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,129,@Pi_UsrId))
	SET @FromBillNo =(SELECT  MIN(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @ToBillNo =(SELECT  MAX(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) 
	--SET @DispOrderby=(SELECT TOP 1 iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,275,@Pi_UsrId))
	--Till Here
	--DECLARE @RPTBasedON AS INT
	--SET @RPTBasedON =0
	--SELECT @RPTBasedON = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,257,@Pi_UsrId) 
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)	
	
	CREATE TABLE #RptLoadSheetItemWiseParle1
	(
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),
			[PrdId]        	      INT,
			[PrdBatId]			  INT,
			[Product Code]        NVARCHAR (100),
			[Product Description] NVARCHAR(150),
            [PrdCtgValMainId]	  INT, 
			[CmpPrdCtgId]		  INT,
			[Batch Number]        NVARCHAR(50),
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[PrdSchemeDisc]		  NUMERIC (38,2),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0),
			[TotalDiscount]		  NUMERIC (38,2),
			[OtherAmt]			  NUMERIC (38,2),
			[AddReduce]			  NUMERIC (38,2),
			[Damage]              NUMERIC (38,2),
			[BX]                  NUMERIC (38,0),
			[PB]                  NUMERIC (38,0),
			[JAR]				  NUMERIC (38,0),
			[PKT]                 NUMERIC (38,0),
			[CN]				  NUMERIC (38,0),
			[GB]                  NUMERIC (38,0),
			[ROL]                 NUMERIC (38,0),
			[TOR]                 NUMERIC (38,0),
			[CTN]			      NUMERIC (38,0),
			[TIN]			      NUMERIC (38,0),
			[CAR]			      NUMERIC (38,0),
			[PC]			      NUMERIC (38,0),
			[TotalQtyBX]          NUMERIC (38,0),
			[TotalQtyPB]          NUMERIC (38,0),
			[TotalQtyPKT]         NUMERIC (38,0),
			[TotalQtyJAR]         NUMERIC (38,0),
			[TotalQtyCN]		  NUMERIC (38,0),
			[TotalQtyGB]          NUMERIC (38,0),
			[TotalQtyROL]         NUMERIC (38,0),
			[TotalQtyTOR]         NUMERIC (38,0),
			[TotalQtyCTN]         NUMERIC (38,0),
			[TotalQtyTIN]         NUMERIC (38,0),
			[TotalQtyCAR]         NUMERIC (38,0),
			[TotalQtyPC]         NUMERIC (38,0),			
	)
	
	--IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	--BEGIN
		IF @FromBillNo <> 0 Or @ToBillNo <> 0
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle1([SalId],[BillNo],[PrdId],[PrdBatId],[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
				[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
				[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[CTN],[TIN],[CAR],[PC],
				[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR],[TotalQtyCTN],
				[TotalQtyTIN],[TotalQtyCAR],[TotalQtyPC])--select * from RtrLoadSheetItemWise
	
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),[GrossAmount],[TaxAmount],
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+Sum(PrdCDAmount)),0) AS [TotalDiscount],
			Isnull((Sum([TaxAmount])+Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+ Sum(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM RtrLoadSheetItemWise RI
			LEFT OUTER JOIN SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId
			WHERE
	RptId = @Pi_RptId and UsrId = @Pi_UsrId and
	(VehicleId = (CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
					VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
	
	 AND (Allotmentnumber = (CASE @VehicleAllocId WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
					Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
	
	 AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
	
	 AND (DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
					DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
	
	 AND (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
					
	 AND [SalInvDate] Between @FromDate and @ToDate
			 AND RI.SalId Between @FromBillNo and @ToBillNo
----	
-- AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR 
--			    RI.SalId in (Select Selvalue from ReportfilterDt Where Rptid = @Pi_RptId and Usrid =@Pi_UsrId))
	
	GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],
	NetAmount,[GrossAmount],[TaxAmount],PrdCtgValMainId,CmpPrdCtgId
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle1([SalId],BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
					[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
					[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[CTN],[TIN],[CAR],[PC],
					[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR],
					[TotalQtyCTN],[TotalQtyTIN],[TotalQtyCAR],[TotalQtyPC])
			
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],CAST([SellingRate] AS NUMERIC(36,2)),
			BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),GrossAmount,TaxAmount,
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [TotalDiscount],
			ISNULL((SUM([TaxAmount])+SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM RtrLoadSheetItemWise RI --select * from RtrLoadSheetItemWise
			LEFT OUTER JOIN SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId
			WHERE
			RptId = @Pi_RptId and UsrId = @Pi_UsrId and
			(VehicleId = (CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
							VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
			
			 AND (Allotmentnumber = (CASE @VehicleAllocId WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
							Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
			
			 AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
							SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			
			 AND (DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
							DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
			
			 AND (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
							RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
			AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR
					RI.SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )
		 AND [SalInvDate] BETWEEN @FromDate AND @ToDate
		
			GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,
			GrossAmount,TaxAmount,[PrdWeight],PrdCtgValMainId,CmpPrdCtgId
			ORDER BY PrdDCode
			
			  
		END 	
	
		UPDATE #RptLoadSheetItemWiseParle1 SET TotalBills=(SELECT Count(DISTINCT SalId) FROM #RptLoadSheetItemWiseParle1)
-----Added By Sathishkumar Veeramani OtherCharges
			   ---Changed By Jisha for Bug No:30616
               --SELECT @OtherCharges = SUM(OtherCharges) From SalesInvoice WHERE  SalInvDate Between @FromDate and @ToDate AND DlvSts = 2
               SELECT @OtherCharges = ISNULL((SUM(B.TaxAmount)+SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) 
               FROM SalesInvoice A WITH (NOLOCK),RtrLoadSheetItemWise B WITH (NOLOCK)
               LEFt OUTER JOIN SalesInvoiceProduct C WITH (NOLOCK) ON B.SalId = C.SalId 
				AND B.PrdId=C.PrdId And B.PrdBatId=C.PrdBatId
               WHERE A.SalId = B.SalId AND B.SalInvDate Between @FromDate and @ToDate AND DlvSts = 2 AND UsrID = @Pi_UsrId AND RptId = @Pi_RptId
               AND              
			(B.VehicleId = (CASE @VehicleId WHEN 0 THEN B.VehicleId ELSE 0 END) OR
							B.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
			
			 AND (Allotmentnumber = (CASE @VehicleAllocId WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
							Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
			
			 AND (B.SMId=(CASE @SMId WHEN 0 THEN B.SMId ELSE 0 END) OR
							B.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			
			 AND (B.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN B.DlvRMId ELSE 0 END) OR
							B.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
			
			 AND (B.RtrId = (CASE @RtrId WHEN 0 THEN B.RtrId ELSE 0 END) OR
							B.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
			AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR
					B.SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )
							
		
               UPDATE #RptLoadSheetItemWiseParle1 SET AddReduce = @OtherCharges 
-------Added By Sathishkumar Veeramani Damage Goods Amount---------	
		 UPDATE R SET R.[Damage] = B.PrdNetAmt FROM #RptLoadSheetItemWiseParle1 R INNER JOIN
		(SELECT RH.SalId,SUM(RP.PrdNetAmt) AS PrdNetAmt,RP.PrdId,RP.PrdBatId FROM ReturnHeader RH,ReturnProduct RP 
		 WHERE RH.ReturnID  = RP.ReturnID AND RH.ReturnType = 1 GROUP BY RH.SalId,RP.PrdId,RP.PrdBatId)B
		 ON R.SalId = B.SalId AND R.PrdId = B.PrdId 
		AND R.PrdBatId = B.PrdBatId
		
		Update #RptLoadSheetItemWiseParle1 Set [Batch Number] = '',PrdBatId = 0 --Code Added by Muthuvelsamy R for DCRSTPAR0510
------Till Here--------------------		
----Added By Jisha On 02/07/2013 for PARLECS/0613/008 
SELECT 0 AS [SalId],'' AS BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],
[Batch Number] AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],SUM([Billed Qty]) as [Billed Qty],SUM([Free Qty]) as [Free Qty],SUM([Return Qty]) as [Return Qty],
SUM([Replacement Qty]) AS [Replacement Qty],SUM([Total Qty]) AS [Total Qty],SUM(PrdWeight) AS PrdWeight,SUM(PrdSchemeDisc) AS PrdSchemeDisc,
SUM(GrossAmount) AS GrossAmount,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount,TotalBills,SUM(TotalDiscount) AS TotalDiscount,
SUM(OtherAmt) AS OtherAmt,SUM(DISTINCT AddReduce) AS Addreduce,SUM([Damage])AS [Damage],0 AS[BX],0 AS [PB],0 AS [JAR],0 AS [PKT],0 AS [CN],
0 AS [GB],0 AS [ROL],0 AS [TOR],0 AS [CTN],0 AS [TIN],0 AS [CAR],0 AS [PC],
0 AS TotalQtyBX,0 AS TotalQtyPB,0 AS TotalQtyPKT,0 AS TotalQtyJAR,0 AS [TotalQtyCN],0 AS [TotalQtyGB],0 AS [TotalQtyROL],0 AS [TotalQtyTOR],
0 AS [TotalQtyCTN],0 AS [TotalQtyTIN],0 AS [TotalQtyCAR],0 AS [TotalQtyPC]
INTO #RptLoadSheetItemWiseParle FROM #RptLoadSheetItemWiseParle1
GROUP BY PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],TotalBills
-----

--Added by Sathishkumar Veeramani 2013/04/25		
	DECLARE CUR_UOMQTY CURSOR 
	FOR
		SELECT P.PrdId,Rpt.[Product Code],[Batch Number],SUM([Billed Qty]) AS [Billed Qty],SUM([Total Qty]) AS [Total Qty] FROM #RptLoadSheetItemWiseParle Rpt WITH (NOLOCK)
		INNER JOIN Product P WITH (NOLOCK) ON  Rpt.PrdId=P.PrdId GROUP BY P.PrdId,Rpt.[Product Code],[Batch Number]		
	OPEN CUR_UOMQTY
	FETCH NEXT FROM CUR_UOMQTY INTO @PrdId,@PrdCode,@PrdBatchCode,@BaseQty,@TotalQty
	WHILE @@FETCH_STATUS=0
	BEGIN	
			SET	@Converted=0
			SET @Remainder=0			
			SET	@TotConverted=0
			SET @TotRemainder=0				
			DECLARE CUR_UOMGROUP CURSOR
			FOR 
			SELECT DISTINCT UOMID,CONVERSIONFACTOR FROM (
			SELECT A.UOMID,CONVERSIONFACTOR FROM UOMMASTER A WITH (NOLOCK) 
			INNER JOIN UOMGROUP B WITH (NOLOCK) ON A.UomId = B.UomId INNER JOIN PRODUCT C WITH (NOLOCK)
			ON C.UOMGROUPID=B.UOMGROUPID WHERE PRDID=@PrdId AND A.UOMCODE IN ('BX','GB','CN','PB','JAR','TOR','PKT','ROL','CTN','TIN','PC','CAR')) UOM ORDER BY CONVERSIONFACTOR DESC 
			OPEN CUR_UOMGROUP
			FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR
			WHILE @@FETCH_STATUS=0
			BEGIN	
					SELECT @COLUOM=UOMCODE FROM UomMaster WITH (NOLOCK) WHERE UOMID=@FUOMID
					IF @BaseQty >= @FCONVERSIONFACTOR
					BEGIN
						SET	@Converted=CAST(@BaseQty/@FCONVERSIONFACTOR as INT)
						SET @Remainder=CAST(@BaseQty%@FCONVERSIONFACTOR AS INT)
						SET @BaseQty=@Remainder							
						
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle  SET [' + @COLUOM +']='+ CAST(ISNULL(@Converted,0) AS VARCHAR(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END	
					ELSE 	
					BEGIN
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [' + @COLUOM +']='+ CAST(0 AS VARCHAR(10)) +' WHERE [Product Code] ='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END
					----Added By Jisha On 02/07/2013 for PARLECS/0613/008 
					IF @TotalQty >= @FCONVERSIONFACTOR
					BEGIN						
						SET	@TotConverted=CAST(@TotalQty/@FCONVERSIONFACTOR as INT)
						SET @TotRemainder=CAST(@TotalQty%@FCONVERSIONFACTOR AS INT)
						SET @TotalQty=@TotRemainder								
	
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [TotalQty' + @COLUOM + ']= '+ CAST(ISNULL(@TotConverted,0) AS VARCHAR(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END	
					ELSE 	
					BEGIN
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [TotalQty' + @COLUOM +']='+ Cast(0 AS VARCHAR(10)) +' WHERE [Product Code] ='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END					
					--					
			FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR
			END	
			CLOSE CUR_UOMGROUP
			DEALLOCATE CUR_UOMGROUP
			SET @BaseQty=0
			SET @TotalQty=0
	FETCH NEXT FROM CUR_UOMQTY INTO @Prdid,@PrdCode,@PrdBatchCode,@BaseQty,@TotalQty
	END	
	CLOSE CUR_UOMQTY
	DEALLOCATE CUR_UOMQTY
------SELECT [PrdId],[PrdBatId],[Product Code],[Product Description],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],
------[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR]
------FROM #RptLoadSheetItemWiseParle
	---Commented By Jisha on 02/07/2013 for PARLECS/0613/008
	----UPDATE A SET A.TotalQtyBX = Z.TotalBox,A.TotalQtyPB = Z.TotalPouch,A.TotalQtyPKT = Z.TotalPacks FROM #RptLoadSheetItemWiseParle A WITH (NOLOCK)
	----INNER JOIN (SELECT PrdID,PrdBatId,SUM(BX) AS TotalBox,SUM(PB)+SUM(JAR) AS TotalPouch,SUM(PKT) AS TotalPacks 
	----FROM #RptLoadSheetItemWiseParle WITH (NOLOCK)GROUP BY PrdID,PrdBatId) Z
	----ON A.PrdId = Z.PrdId AND A.PrdBatId = Z.PrdBatId
--Till Here
	--Check for Report Data
    SELECT 0 AS [SalId],'' AS BillNo,PrdId,0 AS PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],
    0 AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],([BX]+[GB]) AS BilledQtyBox,(([PB])+([JAR]+[CN]+[TOR]+[TIN]+[CAR])) AS BilledQtyPouch,
    ([PKT]+[ROL]+[CTN]+[PC]) AS BilledQtyPack,SUM([Total Qty]) AS [Total Qty],SUM(TotalQtyBX+TotalQtyGB) AS TotalQtyBOX,
    SUM(TotalQtyPB+TotalQtyJAR+TotalQtyCN+TotalQtyTOR+TotalQtyTIN+TotalQtyCAR) AS TotalQtyPouch,SUM(TotalQtyPKT+TotalQtyROL+TotalQtyCTN+TotalQtyPC) AS TotalQtyPack,
	SUM([Free Qty]) As [Free Qty],SUM([Return Qty])As [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM([PrdWeight]) AS [PrdWeight],
	SUM([Billed Qty]) AS [Billed Qty],SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) As PrdSchemeDisc,
	SUM(TaxAmount) AS TaxAmount,SUM(NETAMOUNT) as NETAMOUNT,TotalBills,SUM([TotalDiscount]) AS [TotalDiscount],
	SUM([OtherAmt]) AS [OtherAmt],SUM([AddReduce]) As [AddReduce],SUM([Damage])AS [Damage] INTO #Result
	FROM #RptLoadSheetItemWiseParle GROUP BY PrdId,[Product Code],[Product Description],[MRP],TotalBills,[PrdCtgValMainId],[CmpPrdCtgId],
	[BX],[PB],[JAR],[PKT],[GB],[CN],[TOR],[ROL],[TIN],[CAR],[CTN],[PC]
	ORDER BY [Product Description]
	
	
					
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #Result
	SELECT [SalId],BillNo,PrdId,0 AS PrdBatId,[Product Code],[Product Description],0 AS PrdCtgValMainId,0 AS CmpPrdCtgId,0 AS [Batch Number],
	 MRP,MAX([Selling Rate]) AS [Selling Rate],
	 SUM(BilledQtyBox) AS BilledQtyBox,SUM(BilledQtyPouch) AS BilledQtyPouch,SUM(BilledQtyPack)As BilledQtyPack,SUM([Total Qty]) AS [Total Qty],
	 SUM(TotalQtyBox) AS TotalQtyBox,SUM(TotalQtyPouch) AS TotalQtyPouch,SUM(TotalQtyPack) AS TotalQtyPack,SUM([Free Qty]) AS [Free Qty],
	 SUM([Return Qty]) AS [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM(PrdWeight) AS PrdWeight,SUM([Billed Qty]) AS [Billed Qty],
	 SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) AS PrdSchemeDisc,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NETAMOUNT,TotalBills,
	 SUM(TotalDiscount) AS TotalDiscount,SUM(OtherAmt) AS OtherAmt,SUM(AddReduce) AS AddReduce,SUM([Damage]) AS [Damage] 
	 INTO #TempLoadingSheet FROM #Result GROUP BY [SalId],BillNo,PrdId,[Product Code],[PRoduct Description],MRP,TotalBills
	 ORDER BY [Product Code]
	 SELECT * FROM #TempLoadingSheet
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
	BEGIN
		IF EXISTS (Select [Name] From SysObjects Where [Name]='RptLoadSheetItemWiseParle_Excel' And XTYPE='U')
		Drop Table RptLoadSheetItemWiseParle_Excel
	    SELECT * INTO RptLoadSheetItemWiseParle_Excel FROM #TempLoadingSheet ORDER BY [Product Code]
	END 
END
GO
--PARLE Remove Without Transaction Product Batch Details
DELETE FROM DayEndProcess WHERE ProcDesc = 'Remove Product Batch'
INSERT INTO DayEndProcess (ProcDate,ProcId,NextUpDate,ProcDesc)
SELECT '2014-06-01',14,'2014-06-01','Remove Product Batch'
GO
IF EXISTS(SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype IN ('FN','TF') AND Name = 'Fn_RemoveProductBatchDuplication')
DROP FUNCTION dbo.[Fn_RemoveProductBatchDuplication]
GO
--SELECT DISTINCT dbo.[Fn_RemoveProductBatchDuplication]('2014-07-23') AS RemoveBatch
CREATE FUNCTION dbo.[Fn_RemoveProductBatchDuplication] (@ServerDate AS DATETIME)    
RETURNS TINYINT    
AS    
/***********************************************************    
* FUNCTION: Fn_RemoveProductBatchDuplication    
* PURPOSE: To Remove the Without Transactions Batch Details   
* CREATED: Sathishkumar Veeramani 2014/07/23  
************************************************************/    
BEGIN    
 DECLARE @RemoveBatch AS INT
 DECLARE @DayCount AS INT
     
 SET @RemoveBatch=0
 IF EXISTS (SELECT DISTINCT CmpCode FROM Company (NOLOCK) WHERE CmpCode = 'PRL')
 BEGIN
	 IF EXISTS (SELECT ProcDesc FROM DayEndProcess (NOLOCK) WHERE ProcDesc = 'Remove Product Batch')
	 BEGIN
		 SELECT @DayCount = DATEDIFF(DAY,CONVERT(NVARCHAR(10),NextUpDate,121),CONVERT(NVARCHAR(10),@ServerDate,121)) 
		 FROM DayEndProcess (NOLOCK) WHERE ProcDesc = 'Remove Product Batch'
		 IF @DayCount >=30
		 BEGIN
			 SET @RemoveBatch = 1
		 END
	 END
 END 
 RETURN(@RemoveBatch)    
END
GO
IF NOT EXISTS(SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'U' AND Name = 'Product_Backup')
BEGIN
CREATE TABLE Product_Backup(
	[PrdId] [int] NOT NULL,
	[PrdName] [nvarchar](100) NOT NULL,
	[PrdShrtName] [nvarchar](100) NOT NULL,
	[PrdDCode] [nvarchar](50) NOT NULL,
	[PrdCCode] [nvarchar](50) NOT NULL,
	[SpmId] [int] NOT NULL,
	[StkCovDays] [numeric](18, 0) NOT NULL,
	[PrdUpSKU] [int] NOT NULL,
	[PrdWgt] [numeric](18, 4) NOT NULL,
	[PrdUnitId] [int] NOT NULL,
	[UomGroupId] [int] NOT NULL,
	[TaxGroupId] [int] NOT NULL,
	[PrdType] [int] NOT NULL,
	[EffectiveFrom] [datetime] NOT NULL,
	[EffectiveTo] [datetime] NOT NULL,
	[PrdShelfLife] [int] NOT NULL,
	[PrdStatus] [tinyint] NOT NULL,
	[CmpId] [int] NOT NULL,
	[PrdCtgValMainId] [int] NOT NULL,
	[IMEIEnabled] [int] NOT NULL,
	[IMEILength] [int] NOT NULL,
	[EANCode] [varchar](50) NULL
)
END
GO
IF NOT EXISTS(SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'U' AND Name = 'ProductBatch_BackUp')
BEGIN
CREATE TABLE ProductBatch_BackUp(
	[PrdId] [INT] NULL,
	[PrdBatId] [INT] NULL,
	[PrdBatCode] [nvarchar](50) NULL,
	[CmpBatCode] [nvarchar](50) NULL,
	[MnfDate] [datetime] NULL,
	[ExpDate] [datetime] NULL,
	[Status] [tinyint] NULL,
	[TaxGroupId] [int] NULL,
	[BatchSeqId] [int] NULL,
	[DecPoints] [int] NULL,
	[DefaultPriceId] [int] NULL,
	[EnableCloning] [tinyint] NULL,
)
END
GO
IF NOT EXISTS(SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'U' AND Name = 'ProductBatchDetails_BackUp')
BEGIN
CREATE TABLE ProductBatchDetails_BackUp(
	[PriceId] [bigint] NULL,
	[PrdBatId] [bigint] NULL,
	[PriceCode] [nvarchar](4000) NULL,
	[BatchSeqId] [int] NULL,
	[SLNo] [int] NULL,
	[PrdBatDetailValue] [numeric](18, 6) NULL,
	[DefaultPrice] [tinyint] NULL,
	[PriceStatus] [tinyint]  NULL,
) ON [PRIMARY]
END
GO
IF EXISTS(SELECT Name FROM Sysobjects (NOLOCK) WHERE Name = 'PROC_PRODUCTDELETION' AND Xtype = 'P')
DROP PROCEDURE PROC_PRODUCTDELETION
GO
--EXEC PROC_PRODUCTDELETION
CREATE PROCEDURE PROC_PRODUCTDELETION
AS
BEGIN
BEGIN TRY
BEGIN TRAN
--WithOut Transaction Product Batch Details to be Deleted 

TRUNCATE TABLE Product_Backup
TRUNCATE TABLE ProductBatch_BackUp
TRUNCATE TABLE ProductBatchDetails_BackUp
 
SELECT DISTINCT PrdId,PrdBatId  INTO #StockLedger FROM (
SELECT DISTINCT PrdId,PrdBatId  FROM StockLedger (NOLOCK) UNION 
SELECT DISTINCT PrdId,PrdBatId FROM PurchaseReceipt P (NOLOCK) INNER JOIN PurchaseReceiptProduct PP (NOLOCK) 
ON P.PurRcptId=PP.PurRcptId WHERE Status=0 UNION
SELECT DISTINCT PrdId,PrdBatId FROM ETLTempPurchaseReceiptProduct (NOLOCK) UNION
SELECT DISTINCT PrdId,PrdBatId FROM ReturnHeader R (NOLOCK) INNER JOIN ReturnProduct RP (NOLOCK) 
ON R.ReturnID = RP.ReturnID WHERE R.Status = 1 )X

SELECT DISTINCT PrdCCode INTO #SingleCode FROM Product (NOLOCK) GROUP BY PrdCCode HAVING COUNT(PrdCCode)<=1

SELECT PrdId,PrdCCode INTO #Product FROM Product A  
WHERE  NOT EXISTS(SELECT DISTINCT PrdId FROM #StockLedger B WHERE A.PrdId=B.PrdId) ORDER BY PrdId

DELETE A FROM #Product A INNER JOIN #SingleCode B ON A.PrdCCode=B.PrdCCode

SELECT MIN(PrdId) AS PrdId,PrdCCode INTO  #DuplicateProduct FROM #Product GROUP BY PrdCCode HAVING  COUNT(PrdCCode)>=1

DELETE A FROM ContractPricingDetails A (NOLOCK) INNER JOIN #DuplicateProduct B ON A.PrdId=B.PrdId
DELETE A FROM TargetNormMappingDt A (NOLOCK) INNER JOIN #DuplicateProduct B ON A.PrdId=B.PrdId
DELETE A FROM SchemeProducts A (NOLOCK) INNER JOIN #DuplicateProduct B ON A.PrdId=B.PrdId
DELETE A FROM SchemeSlabFrePrds A (NOLOCK) INNER JOIN #DuplicateProduct B ON A.PrdId=B.PrdId --Added
DELETE B FROM StockManagement A (NOLOCK) INNER JOIN StockManagementProduct B (NOLOCK) ON A.StkMngRefNo=B.StkMngRefNo
INNER JOIN #DuplicateProduct C ON B.PrdId=C.PrdId WHERE Status=0

INSERT INTO ProductBatchDetails_BackUp (PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus)
SELECT DISTINCT PriceId,A.PrdBatId,PriceCode,A.BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus 
FROM ProductBatchDetails A (NOLOCK) 
INNER JOIN ProductBatch B (NOLOCK) ON A.PrdBatId=B.PrdBatId
INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId INNER JOIN #DuplicateProduct D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
WHERE NOT EXISTS (SELECT DISTINCT PriceId FROM ProductBatchDetails_BackUp D (NOLOCK) WHERE A.PriceId = D.PriceId)

INSERT INTO ProductBatch_BackUp (PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning)
SELECT DISTINCT B.PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,B.TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning 
FROM  ProductBatch B (NOLOCK) INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId 
INNER JOIN #DuplicateProduct D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
WHERE NOT EXISTS (SELECT DISTINCT PrdBatId FROM ProductBatch_BackUp E (NOLOCK) WHERE B.PrdBatId = E.PrdBatId) 

INSERT INTO Product_Backup (PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,
EffectiveFrom,EffectiveTo,PrdShelfLife,PrdStatus,CmpId,PrdCtgValMainId,IMEIEnabled,IMEILength,EANCode)
SELECT DISTINCT C.PrdId,PrdName,PrdShrtName,PrdDCode,C.PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,
EffectiveFrom,EffectiveTo,PrdShelfLife,PrdStatus,CmpId,PrdCtgValMainId,IMEIEnabled,IMEILength,EANCode 
FROM Product C (NOLOCK) INNER JOIN #DuplicateProduct D ON D.PrdId=C.PrdId
WHERE NOT EXISTS (SELECT DISTINCT PrdId FROM Product_Backup E (NOLOCK) WHERE C.PrdId = E.PrdId) 

DELETE A FROM ProductBatchDetails A (NOLOCK) INNER JOIN ProductBatch B (NOLOCK) ON A.PrdBatId=B.PrdBatId
INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId INNER JOIN #DuplicateProduct D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
DELETE B FROM  ProductBatch B (NOLOCK) INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId 
INNER JOIN #DuplicateProduct D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
DELETE C FROM Product C (NOLOCK) INNER JOIN #DuplicateProduct D ON D.PrdId=C.PrdId

--
SELECT DISTINCT PrdCCode INTO #SingleCode1 FROM Product (NOLOCK) GROUP BY PrdCCode HAVING  COUNT(PrdCCode)<=1

SELECT PrdId,PrdCCode INTO #Product1 FROM Product A (NOLOCK) 
WHERE  NOT EXISTS(SELECT DISTINCT PrdId FROM #StockLedger B WHERE A.PrdId=B.PrdId) ORDER BY PrdId

DELETE A FROM #Product1 A INNER JOIN #SingleCode1 B ON A.PrdCCode=B.PrdCCode

SELECT MIN(PrdId) AS PrdId ,PrdCCode INTO #DuplicateProduct1 FROM #Product GROUP BY PrdCCode HAVING  COUNT(PrdCCode)>=1


DELETE A FROM ContractPricingDetails A (NOLOCK) INNER JOIN #DuplicateProduct1 B ON A.PrdId=B.PrdId
DELETE A FROM TargetNormMappingDt A (NOLOCK) INNER JOIN #DuplicateProduct1 B ON A.PrdId=B.PrdId
DELETE A FROM SchemeProducts A (NOLOCK) INNER JOIN #DuplicateProduct1 B ON A.PrdId=B.PrdId
DELETE A FROM SchemeSlabFrePrds A (NOLOCK) INNER JOIN #DuplicateProduct1 B ON A.PrdId=B.PrdId --Added
DELETE B FROM StockManagement A (NOLOCK) INNER JOIN StockManagementProduct B (NOLOCK) ON A.StkMngRefNo=B.StkMngRefNo
INNER JOIN #DuplicateProduct1 C ON B.PrdId=C.PrdId WHERE Status=0


INSERT INTO ProductBatchDetails_BackUp (PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus)
SELECT DISTINCT PriceId,A.PrdBatId,PriceCode,A.BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus 
FROM ProductBatchDetails A (NOLOCK) INNER JOIN ProductBatch B (NOLOCK) ON A.PrdBatId=B.PrdBatId
INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId INNER JOIN #DuplicateProduct1 D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
WHERE NOT EXISTS (SELECT DISTINCT PriceId FROM ProductBatchDetails_BackUp D (NOLOCK) WHERE A.PriceId = D.PriceId)

INSERT INTO ProductBatch_BackUp (PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning)
SELECT DISTINCT B.PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,B.TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning 
FROM ProductBatch B (NOLOCK) INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId 
INNER JOIN #DuplicateProduct1 D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
WHERE NOT EXISTS (SELECT DISTINCT PrdBatId FROM ProductBatch_BackUp E (NOLOCK) WHERE B.PrdBatId = E.PrdBatId) 

INSERT INTO Product_Backup (PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,
EffectiveFrom,EffectiveTo,PrdShelfLife,PrdStatus,CmpId,PrdCtgValMainId,IMEIEnabled,IMEILength,EANCode)
SELECT DISTINCT C.PrdId,PrdName,PrdShrtName,PrdDCode,C.PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,
EffectiveFrom,EffectiveTo,PrdShelfLife,PrdStatus,CmpId,PrdCtgValMainId,IMEIEnabled,IMEILength,EANCode 
FROM Product C (NOLOCK) INNER JOIN #DuplicateProduct1 D ON D.PrdId=C.PrdId
WHERE NOT EXISTS (SELECT DISTINCT PrdId FROM Product_Backup E (NOLOCK) WHERE C.PrdId = E.PrdId)

DELETE A FROM ProductBatchDetails A (NOLOCK) INNER JOIN ProductBatch B (NOLOCK) ON A.PrdBatId=B.PrdBatId
INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId INNER JOIN #DuplicateProduct1 D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
DELETE B FROM  ProductBatch B (NOLOCK) INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId 
INNER JOIN #DuplicateProduct1 D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId
DELETE C FROM Product C (NOLOCK) INNER JOIN #DuplicateProduct1 D ON D.PrdId=C.PrdId

SELECT MIN(PrdId) AS PrdId ,PrdCCode INTO #Product2 FROM product  A
WHERE EXISTS(SELECT DISTINCT PrdId FROM #StockLedger B WHERE A.PrdId=B.PrdId)
GROUP BY PrdCCode HAVING  COUNT(PrdCCode)>1

UPDATE PP SET PP.PrdCCode='Dup_'+P.PrdCCode FROM #Product2 P INNER JOIN Product PP (NOLOCK) ON P.PrdId=PP.PrdId

--BATCH DELETE
SELECT PrdId,PrdBatId,DefaultPriceId INTO #ProductBatch  FROM ProductBatch A (NOLOCK) WHERE 
NOT EXISTS(SELECT B.PrdId,B.PrdBatId FROM #StockLedger B WHERE A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId)

SELECT PrdId,MAX(PrdBatId) PrdBatId INTO #Maxbatch FROM #ProductBatch GROUP BY PrdId

DELETE P FROM #ProductBatch P INNER JOIN #Maxbatch PP ON P.PrdId=PP.PrdId AND P.PrdBatId=PP.PrdBatId

INSERT INTO ProductBatchDetails_BackUp (PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus)
SELECT DISTINCT PriceId,A.PrdBatId,PriceCode,A.BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus 
FROM ProductBatchDetails A (NOLOCK) INNER JOIN ProductBatch B ON A.PrdBatId=B.PrdBatId
INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId INNER JOIN #ProductBatch D ON D.PrdId=C.PrdId
AND B.PrdId=D.PrdId AND D.PrdBatId=B.PrdBatId AND D.PrdBatId=A.PrdBatId AND A.PriceId=D.DefaultPriceId
WHERE NOT EXISTS (SELECT DISTINCT PriceId FROM ProductBatchDetails_BackUp D (NOLOCK) WHERE A.PriceId = D.PriceId) 

INSERT INTO ProductBatch_BackUp (PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning)
SELECT DISTINCT B.PrdId,B.PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,B.TaxGroupId,BatchSeqId,DecPoints,B.DefaultPriceId,EnableCloning
FROM  ProductBatch B (NOLOCK) INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId 
INNER JOIN #ProductBatch D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId AND D.PrdBatId=B.PrdBatId
WHERE NOT EXISTS (SELECT DISTINCT PrdBatId FROM ProductBatch_BackUp E (NOLOCK) WHERE B.PrdBatId = E.PrdBatId) 

DELETE A FROM ProductBatchDetails A (NOLOCK) INNER JOIN ProductBatch B ON A.PrdBatId=B.PrdBatId
INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId INNER JOIN #ProductBatch D ON D.PrdId=C.PrdId
AND B.PrdId=D.PrdId AND D.PrdBatId=B.PrdBatId AND D.PrdBatId=A.PrdBatId AND A.PriceId=D.DefaultPriceId 

DELETE B FROM  ProductBatch B (NOLOCK) INNER JOIN Product C (NOLOCK) ON C.PrdId=B.PrdId 
INNER JOIN #ProductBatch D ON D.PrdId=C.PrdId AND B.PrdId=D.PrdId AND D.PrdBatId=B.PrdBatId 

--SELECT DISTINCT PrdCCode FROM Product (NOLOCK) GROUP BY PrdCCode HAVING  COUNT(PrdCCode)>1
--SELECT COUNT(PrdId) FROM Product (NOLOCK)

UPDATE ProductBatchDetails SET DefaultPrice = 0

UPDATE A SET A.DefaultPrice = 1 FROM ProductBatchDetails A (NOLOCK) INNER JOIN (
SELECT DISTINCT PrdBatId,MAX(PriceId) AS PriceId FROM ProductBatchDetails (NOLOCK) GROUP BY PrdBatId)B 
ON A.PrdBatId = B.PrdBatId AND A.PriceId = B.PriceId

UPDATE A SET A.DefaultPriceId = B.PriceId FROM ProductBatch A (NOLOCK) INNER JOIN (
SELECT DISTINCT PrdBatId,MAX(PriceId) AS PriceId FROM ProductBatchDetails (NOLOCK) GROUP BY PrdBatId)B 
ON A.PrdBatId = B.PrdBatId

UPDATE DayEndProcess SET ProcDate = CONVERT(NVARCHAR(10),GETDATE(),121),NextUpDate = CONVERT(NVARCHAR(10),GETDATE(),121)
WHERE ProcDesc = 'Remove Product Batch'

COMMIT TRAN
END TRY
BEGIN CATCH
	SELECT 'ERROR WHILE EXCUTE' ,ERROR_MESSAGE()
	ROLLBACK TRAN
END CATCH
END
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.0',417
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 417)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(417,'D','2014-07-23',GETDATE(),1,'Core Stocky Service Pack 417')