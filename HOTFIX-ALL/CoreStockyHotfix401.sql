--[Stocky HotFix Version]=401
DELETE FROM Versioncontrol WHERE Hotfixid='401'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('401','2.0.0.5','D','2013-03-13','2013-03-13','2013-03-13',CONVERT(VARCHAR(11),GETDATE()),'PARLE-Major: Product Release Dec CR')
GO
IF NOT EXISTS(SELECT * FROM Sysobjects So INNER JOIN Syscolumns Sc On So.id=Sc.id AND So.name='Supplier' AND Sc.name='SpmTinNo')
BEGIN
      ALTER TABLE Supplier Add SpmTinNo NVARCHAR(50)
END
GO
--------------------------
DELETE FROM CustomCaptions WHERE TransId=69 AND CtrlId=27 AND CtrlName='lblSpmTinNo'
DELETE FROM CustomCaptions WHERE TransId=69 AND CtrlId=100013 AND CtrlName='fxtSpmTinNo'
INSERT CustomCaptions
SELECT 69,27,0,'lblSpmTinNo','TIN Number*','','',1,1,1,getdate(),1,getdate(),'TIN Number*','','',1,1
UNION
SELECT 69,100013,0,'fxtSpmTinNo','TIN Number','','',	1,	1,	1,	'2013-03-07',1,'2013-03-07','TIN Number','','',1,1
DELETE FROM FieldLevelAccessDt WHERE TransId=69 AND CtrlId=100013 AND PrfId=1
INSERT INTO FieldLevelAccessDt
SELECT 1,69,100013,	1,	1,	1,'2013-03-07',1,'2013-03-07'
GO
--Parle-GR005-CR002
DELETE FROM RptFormula WHERE RptId=23
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,1,'Cap From Date','From Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,2,'From Date','From Date',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,3,'Cap To Date','To Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,4,'To Date','To Date',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,5,'Cap Company','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,6,'Company','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,7,'Cap GRN Number','GRN Number',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,8,'Cap GRN Date','GRN Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,9,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,10,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,11,'Cap Page','Page',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,12,'Disp_CmpInvNo','Company Invoice Number',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,13,'Disp_CmpInvdate','Company Invoice Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,14,'Disp_TransNo','Transaction Number',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,15,'Fill_TransNo','Transaction Number',1,197)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,16,'Disp_SpmName','Supplier Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (23,17,'Disp_SpmTinNo','Tin Number',1,0)
GO
DELETE FROM RptExcelHeaders WHERE RptId=23
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (23,1,'CmpId','CmpId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (23,2,'CmpName','Company',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (23,3,'SpmId','SpmId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (23,4,'SpmName','Supplier Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (23,5,'SpmTINNo','TIN Number',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (23,6,'PurRcptId','PurRcptId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (23,7,'PurRcptRefNo','GRN Number',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (23,8,'InvDate','GRN Date',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (23,9,'CmpInvNo','Company Invoice Number',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (23,10,'CmpInvDate','Company Invoice Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (23,11,'UsrId','UsrId',0,1)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME ='Proc_RptCmpWisePurchase')
DROP PROCEDURE Proc_RptCmpWisePurchase
GO
--EXEC Proc_RptCmpWisePurchase 23,1,0,'CoreStocky',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptCmpWisePurchase]
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
	--@Po_Errno		INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_RptCmpWisePurchase
* PURPOSE		: Company wise Purchase Report
* CREATED		: 
* CREATED DATE	: 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}			{brief modification description}
* 28.02.2013	Aravindh Deva C		Parle-GR005-CR002 Tin Number required in Company wise Purchase Report
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
DECLARE @FromDate	AS	DATETIME
DECLARE @ToDate		AS	DATETIME
DECLARE @CmpId	 	AS	INT
DECLARE @PurRcptID 	AS	INT
DECLARE @EXLFlag	AS	INT
--select * from reportfilterdt
SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @PurRcptID = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,197,@Pi_UsrId))
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
Create TABLE #RptCmpWisePurchase
(
		CmpId 				INT,
		CmpName  			NVARCHAR(50),		
		PurRcptId 			BIGINT,
		PurRcptRefNo 		NVARCHAR(50),
		InvDate 			DATETIME,
		GrossAmount 		NUMERIC(38,6),
		SlNo 				INT,
		RefCode 			NVARCHAR(25),
		FieldDesc 			NVARCHAR(100),
		LineBaseQtyAmount 	NUMERIC(38,6),
		LessScheme 			NUMERIC(38,6),
		OtherChgAddition	NUMERIC(38,6),	
		OtherChgDeduction	NUMERIC(38,6),		
		NetAmount 			NUMERIC(38,6),
		CmpInvNo			NVARCHAR(25),
		CmpInvDate 			DATETIME
	)
SET @TblName = 'RptCmpWisePurchase'
SET @TblStruct = '
		CmpId 				INT,
		CmpName  			NVARCHAR(50),		
		PurRcptId 			BIGINT,
		PurRcptRefNo 		NVARCHAR(50),
		InvDate 			DATETIME,
		GrossAmount 		NUMERIC(38,6),
		SlNo 				INT,
		RefCode 			NVARCHAR(25),
		FieldDesc 			NVARCHAR(100),
		LineBaseQtyAmount 	NUMERIC(38,6),
		LessScheme 			NUMERIC(38,6),
		OtherChgAddition	NUMERIC(38,6),	
		OtherChgDeduction	NUMERIC(38,6),	
		NetAmount 			NUMERIC(38,6),
		CmpInvNo			NVARCHAR(25),
		CmpInvDate 			DATETIME'
			
SET @TblFields = 'CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
		 ,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo,CmpInvDate'
/*		 
--Parle-GR005-CR002
	SELECT S.SpmId [SpmId],S.SpmName [SpmName],ISNULL(D.ColumnValue,'') [SpmTINNo]
	INTO #SupplierTIN
	FROM UdcMaster M (NOLOCK)
	INNER JOIN UdcDetails D (NOLOCK) ON M.UdcMasterId=D.UdcMasterId AND M.MasterId=D.MasterId 
	AND M.ColumnName='TIN Number' AND M.MasterId IN (SELECT DISTINCT MasterId FROM UdcHD (NOLOCK) WHERE MasterName='Supplier Master')
	RIGHT OUTER JOIN Supplier S ON S.SpmId=D.MasterRecordId	
--Parle-GR005-CR002	
*/	 

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
--SET @Po_Errno = 0
IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
BEGIN
--	EXEC Proc_GRNListing @Pi_UsrId
	SELECT PurRcptId,PurRcptRefNo,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpInvNo,InvDate,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,
		   ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,Slno,RefCode,FieldDesc ,LineBaseQtyAmount,
		   PrdNetAmount,status,GoodsRcvdDate,LessScheme,OtherChgAddition,OtherChgDeduction,TotalAddition,TotalDeduction,GrossAmount,NetPayable,
		   DifferenceAmount,PaidAmount,NetAmount,CmpId,CmpName,UsrId
	INTO #TempGrnListing FROM 
		(
			Select PR.PurRcptId,PurRcptRefNo,PRP.PrdId,PrdDCode,PrdName,PRP.PrdBatId,PrdBatCode,CmpInvNo,InvDate,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,
			ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,Slno,PRL.RefCode,FieldDesc ,LineBaseQtyAmount,
			PrdNetAmount,PR.status,GoodsRcvdDate,LessScheme,
			CASE PRC.Effect WHEN 0 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgAddition,
			CASE PRC.Effect WHEN 1 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgDeduction,TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,@Pi_UsrId AS UsrId,PR.CmpId,CmpName
			FROM PurchaseReceipt PR
			INNER JOIN PurchaseReceiptProduct PRP ON PR.PurRcptId = PRP.PurRcptId
			INNER JOIN PurchasereceiptLineAmount PRL ON PR.PurRcptId = PRL.PurRcptId
			and PRL.PrdSlNo = PRP.PrdSlNo
			INNER JOIN PurchaseSequenceMaster PS ON PR.PurSeqId = PS.PurSeqId
			INNER JOIN PurchaseSequenceDetail PD ON PD.PurSeqId = PS.PurSeqId and PRL.RefCode = PD.RefCode
			INNER JOIN Company C ON C.CmpId = PR.CmpId
			INNER JOIN Supplier S ON S.SpmId = PR.SpmId
			INNER JOIN Transporter T ON T.TransporterId = PR.TransporterId
			INNER JOIN Location L ON L.LcnId = PR.LcnId
			INNER JOIN Product P ON P.PrdId = PRP.PrdId
			INNER JOIN ProductBatch  PB ON PB.PrdId = PRP.PrdId  and PB.PrdBatId = PRP.PrdBatId
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC ON PR.PurRcptId = PRC.PurRcptId
			WHERE PR.Status=1 AND PR.GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND
			( C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
						C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
					AND ( PR.PurRcptId = (CASE @PurRcptID WHEN 0 THEN PR.PurRcptId ELSE 0 END) OR
						PR.PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,197,@Pi_UsrId)))
					and PRP.PrdSlNo > 0 
			UNION ALL
			Select PR.PurRcptId,PurRcptRefNo,
			0 as PrdId,'' as PrdDCode,'' as PrdName,0 as PrdBatId,'' as PrdBatCode,Pr.CmpInvNo,InvDate,0 as InvBaseQty,0 as RcvdGoodBaseQty,
			0 as UnSalBaseQty,0 as ShrtBaseQty,0 as ExsBaseQty,0 AS RefuseSale,0 as PrdUnitLSP,
			0 as PrdGrossAmount,0 as Slno,'' as RefCode,'' as FieldDesc ,0 as LineBaseQtyAmount,
			0 as PrdNetAmount,PR.status,GoodsRcvdDate,
			LessScheme,
			CASE PRC.Effect WHEN 0 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgAddition,
			CASE PRC.Effect WHEN 1 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgDeduction,TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,@Pi_UsrId AS UsrId,PR.CmpId,CmpName
			from purchasereceipt PR
			Inner join purchasereceiptclaimScheme PRCS on PRCS.PurRcptId = PR.PurRcptId
			INNER JOIN Company C ON C.CmpId = PR.CmpId
			INNER JOIN Supplier S ON S.SpmId = PR.SpmId
			INNER JOIN Transporter T ON T.TransporterId = PR.TransporterId
			INNER JOIN Location L ON L.LcnId = PR.LcnId
			INNER JOIN StockType ST ON ST.StockTypeId = PRCS.StockTypeId
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC ON PR.PurRcptId = PRC.PurRcptId
			LEFT OUTER JOIN Product P ON P.PrdId = PRCS.PrdId
			LEFT OUTER JOIN ProductBatch  PB ON PB.PrdId =PRCS.PrdId  and PB.PrdBatId = PRCS.PrdBatId
			WHERE PR.Status=1 AND PR.GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND
			( C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
						C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
					AND ( PR.PurRcptId = (CASE @PurRcptID WHEN 0 THEN PR.PurRcptId ELSE 0 END) OR
						PR.PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,197,@Pi_UsrId)))
		) AS A
		
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
		 ,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo,CmpInvDate)
		SELECT DISTINCT CmpId,CmpName,PurRcptId,PurRcptRefno,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,
		dbo.Fn_ConvertCurrency(sum(LineBaseQtyAmount),@Pi_CurrencyId) as LineBaseQtyAmount,
		dbo.Fn_ConvertCurrency(LessScheme,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(OtherChgAddition,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(OtherChgDeduction,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(NetAmount,@Pi_CurrencyId),CmpInvNo,CmpInvdate
		From ( SELECT  cmpid,cmpname,purrcptid,purrcptrefno,GoodsRcvdDate AS InvDate,GrossAmount,slno,
		RefCode,FieldDesc,LineBaseQtyAmount,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo, InvDate AS CmpInvDate,UsrId	
		FROM #TempGrnListing) x
		Group by
		cmpid,cmpname,purrcptid,purrcptrefno,InvDate, GrossAmount,slno,RefCode,FieldDesc,
		LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo,CmpInvDate,usrid	
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select DISTINCT Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,(Select max(SLNO) + 1 From PurchaseSequenceDetail) as SlNo,'AAA' as RefCode,'Net Amt.' as FieldDesc,
	NetAmount as LineBaseQtyAmount,LessScheme,0,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select MAX(slno) AS SLNO From #RptCmpWisePurchase)
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-1 as SlNo,'BBB' as RefCode,'Other Charges Addition' as FieldDesc,
	OtherChgAddition as LineBaseQtyAmount,LessScheme,OtherChgAddition,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO From #RptCmpWisePurchase)
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select DISTINCT Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-2 as SlNo,'CCC' as RefCode,'Scheme Disc.' as FieldDesc,
	LessScheme as LineBaseQtyAmount,LessScheme,0,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO From #RptCmpWisePurchase)
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select DISTINCT Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-3 as SlNo,'DDD' as RefCode,'Gross Amount' as FieldDesc,
	GrossAmount  as LineBaseQtyAmount,LessScheme,0,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO  From #RptCmpWisePurchase)
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-1.5 as SlNo,'EEE' as RefCode,'Other Charges Dedection' as FieldDesc,
	OtherChgDeduction as LineBaseQtyAmount,LessScheme,0,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO From #RptCmpWisePurchase WHERE OtherChgDeduction>0)-- AND OtherChgDeduction>0
	IF LEN(@PurDBName) > 0
	BEGIN
		SET @SSQL = 'INSERT INTO #RptCmpWisePurchase ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +
			' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+' (PurRcptId = (CASE ' + CAST(@PurRcptID AS nVarchar(10)) + ' WHEN 0 THEN PurRcptId ELSE 0 END) OR ' +
			' PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',197,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+ ' ( INVDATE Between ''' + @FromDate + ''' AND ''' + @ToDate + '''' + ' and UsrId = ' + CAST(@Pi_UsrId AS nVarChar(10)) + ') and (Slno > 0)  '
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCmpWisePurchase'
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
		SET @SSQL = 'INSERT INTO #RptCmpWisePurchase ' +
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
		--SET @Po_Errno = 1
		PRINT 'DataBase or Table not Found'
		RETURN
	   END
END
DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCmpWisePurchase

	--Parle-GR005-CR002
	--select * from #RptCmpWisePurchase
	SELECT Rpt.*,RP.SpmId [SpmId],S.SpmName [SpmName],ISNULL(S.SpmTinNo,'') [SpmTINNo] 
	INTO #RptCmpWisePurchaseWtSpmTINNo
	FROM #RptCmpWisePurchase Rpt 
	INNER JOIN PurchaseReceipt RP (nolock) ON RPT.PurRcptId=RP.PurRcptId
	INNER JOIN Supplier S ON RP.SpmId=S.SpmId

	SELECT * FROM #RptCmpWisePurchaseWtSpmTINNo
	--Parle-GR005-CR002
	
	SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
		--EXEC Proc_RptCmpWisePurchase 23,1,0,'CoreStocky',0,0,1
		/******************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @Values NUMERIC(38,6)
		DECLARE  @Desc VARCHAR(80)
		DECLARE  @InvDate DATETIME	
		DECLARE  @cCmpId INT
		DECLARE  @cPurRcptId INT
		DECLARE  @CmpInvNo NVARCHAR(100)	
		DECLARE  @SlNo INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @Name NVARCHAR(100)
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCmpWisePurchase_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptCmpWisePurchase_Excel]
		DELETE FROM RptExcelHeaders Where RptId=23 AND SlNo>11--Parle-GR005-CR002 -- SlNo>8
		CREATE TABLE RptCmpWisePurchase_Excel (CmpId BIGINT,CmpName NVARCHAR(100),
		SpmId	INT,SpmName VARCHAR(50),SpmTinNo NVARCHAR(50),--Parle-GR005-CR002
		PurRcptId BIGINT,PurRcptRefNo NVARCHAR(100),InvDate DATETIME,
						 		CmpInvNo NVARCHAR(100),CmpInvDate DateTime,UsrId INT)
		SET @iCnt=12--Parle-GR005-CR002 --SET @iCnt=9
		DECLARE Crosstab_Cur CURSOR FOR
		SELECT DISTINCT(Fielddesc),SlNo FROM #RptCmpWisePurchase ORDER BY SLNo
		OPEN Crosstab_Cur
			   FETCH NEXT FROM Crosstab_Cur INTO @Column,@SlNo
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptCmpWisePurchase_Excel ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
					FETCH NEXT FROM Crosstab_Cur INTO @Column,@SLNo
				END
		CLOSE Crosstab_Cur
		DEALLOCATE Crosstab_Cur
		--Insert table values
		DELETE FROM RptCmpWisePurchase_Excel
		INSERT INTO RptCmpWisePurchase_Excel (CmpId ,CmpName ,SpmId,SpmName,SpmTinNo,PurRcptId ,PurRcptRefNo ,InvDate ,CmpInvNo ,CmpInvDate ,UsrId)
		SELECT DISTINCT CmpId ,CmpName ,SpmId,SpmName,SpmTinNo,PurRcptId ,PurRcptRefNo ,InvDate ,CmpInvNo ,CmpInvDate,@Pi_UsrId
				--FROM #RptCmpWisePurchase
				FROM #RptCmpWisePurchaseWtSpmTINNo ORDER BY CmpId,SpmId--Parle-GR005-CR002
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT  CmpId,PurRcptId,InvDate,CmpInvNo,FieldDesc,LineBaseQtyAmount FROM #RptCmpWisePurchase
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @cCmpId,@cPurRcptId,@InvDate,@CmpInvNo,@Desc,@Values
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptCmpWisePurchase_Excel SET ['+ @Desc +']= '+ CAST(ISNULL(@Values,0) AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE CmpId='+ CAST(@cCmpId AS VARCHAR(1000)) + ' AND PurRcptId=' + CAST(@cPurRcptId AS VARCHAR(1000)) + '
					AND InvDate=''' + CAST(@InvDate AS VARCHAR(1000))+''' AND CmpInvNo=''' + CAST(@CmpInvNo As VARCHAR(1000)) + ''' AND UsrId=' + CAST(@Pi_UsrId AS VARCHAR(10))+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @cCmpId,@cPurRcptId,@InvDate,@CmpInvNo,@Desc,@Values
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptCmpWisePurchase_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptCmpWisePurchase_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
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
--Aravindh Till Here
GO
--Sathish Veera
DELETE FROM Configuration WHERE ModuleId = 'BCD9'
INSERT INTO Configuration
SELECT 'BCD9','BillConfig_Display','Set the Tab focus on UOM 1 Once the Batch is selected',1,'',0.00,9
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 156
INSERT INTO HotSearchEditorHd
SELECT 156,'Bill Series Settings','Attribute','Select',
'SELECT AttributeId,AttributeName FROM (
SELECT 1 AS AttributeId, ''Bill Mode'' AS AttributeName UNION 
SELECT 2 AS AttributeId, ''Bill Type'' AS AttributeName UNION 
SELECT 3 AS AttributeId, ''Retailer Tax Type'' AS AttributeName UNION 
SELECT 4 AS AttributeId, ''Location'' AS AttributeName UNION
SELECT 5 AS AttributeId, ''SalesMan'' AS AttributeName UNION
SELECT 6 AS AttributeId, ''Payment Mode'' AS AttributeName
) MainSql'
GO
DELETE FROM BillSeriesConfig WHERE SeriesMasterId = 6
INSERT INTO BillSeriesConfig (SeriesMasterId,SeriesValue,SeriesDesc,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT 6,1,'Cash',1,1,GETDATE(),1,GETDATE() UNION
SELECT 6,2,'Cheque',1,1,GETDATE(),1,GETDATE()
GO
IF NOT EXISTS (SELECT * FROM SysColumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND Name = 'BillSeriesHD') AND Name = 'YearConfig')
BEGIN
   ALTER TABLE BillSeriesHD ADD YearConfig TINYINT DEFAULT 1 WITH VALUES
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE IN ('FN','TF') AND name = 'Fn_ReturnGetKeyNumber')
DROP FUNCTION Fn_ReturnGetKeyNumber
GO
--SELECT DBO.Fn_ReturnGetKeyNumber('SAL',2012,100000,5,2)
CREATE FUNCTION Fn_ReturnGetKeyNumber(@PreFix AS VARCHAR(10),@CurrYear AS INT,@CurrValue AS BIGINT,@ZPad AS INT ,@TransId AS INT,@lSeriesId AS INT)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @GetKeyNumber AS VARCHAR(50)
	IF @TransId=2
	BEGIN
		IF EXISTS(SELECT * FROM Configuration WHERE ModuleId = 'BotreeRefNo' and Status=1)
		BEGIN
			SET @GetKeyNumber=@PreFix+CAST(SUBSTRING(CAST(@CurrYear as Varchar(10)),3,LEN(@CurrYear)) AS Varchar(10))+'-'+REPLICATE('0',CASE WHEN LEN(@CurrValue)>@ZPad THEN (@ZPad+1)-LEN(@CurrValue) ELSE (@ZPad)-LEN(@CurrValue)END)+CAST(@CurrValue as Varchar(10))
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT DISTINCT YearConfig FROM BillSeriesHD(NOLOCK) WHERE YearConfig=1 AND SeriesID=@lSeriesId)
			BEGIN
				SET @GetKeyNumber=@PreFix+CAST(SUBSTRING(CAST(@CurrYear as Varchar(10)),3,LEN(@CurrYear)) AS Varchar(10))+REPLICATE('0',CASE WHEN LEN(@CurrValue)>@ZPad THEN (@ZPad+1)-LEN(@CurrValue) ELSE (@ZPad)-LEN(@CurrValue)END)+CAST(@CurrValue as Varchar(10))
			END
			ELSE
			BEGIN 		
				SET @GetKeyNumber=@PreFix+REPLICATE('0',CASE WHEN LEN(@CurrValue)>@ZPad THEN (@ZPad+1)-LEN(@CurrValue) ELSE (@ZPad)-LEN(@CurrValue)END)+CAST(@CurrValue as Varchar(10))
			END
		END			
	END	
	RETURN(@GetKeyNumber)
END
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 10052
INSERT INTO HotSearchEditorHd
SELECT 10052,'Collection Register','CollectionRefNo','Select','SELECT ReceiptNo,ReceiptDate FROM PDA_ReceiptInvoice'
GO
DELETE FROM HotSearchEditorDt WHERE FormId = 10052
INSERT INTO HotSearchEditorDt
SELECT 1,10052,'CollectionRefNo','Receipt No','ReceiptNo',1500,0,'HotSch-9-2000-14',9 UNION ALL
SELECT 2,10052,'CollectionRefNo','Collected Date','ReceiptDate',1500,0,'HotSch-9-2000-15',9
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'PDA_ReceiptInvoice')
DROP TABLE PDA_ReceiptInvoice
GO
CREATE TABLE PDA_ReceiptInvoice(
	[SrpCde] [varchar](50) NULL,
	[ReceiptNo] [nvarchar](100) NULL,
	[BillNumber] [nvarchar](40) NULL,
	[ReceiptDate] [datetime] NULL,
	[InvoiceAmount] [float] NULL,
	[Balance] [float] NULL,
	[ChequeNumber] [nvarchar](16) NULL,
	[CashAmount] [float] NULL,
	[ChequeAmount] [float] NULL,
	[DiscAmount] [float] NULL,
	[BankId] [int] NULL,
	[BranchId] [int] NULL,
	[ChequeDate] [datetime] NULL,
	[InvRcpMode] [int] NULL,
	[DistBank] [int] NULL,
	[DistBankBranch] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ValidateSchemeBilledProducts')
DROP PROCEDURE Proc_ValidateSchemeBilledProducts
GO
--EXEC Proc_ValidateSchemeBilledProducts 1,178,1,0,''
CREATE PROCEDURE Proc_ValidateSchemeBilledProducts
(
	@Pi_SalId		AS BIGINT,
	@Pi_SchId		AS	INT,
	@Pi_Type		AS	INT,
	@Pi_Error		AS	INT	OUTPUT,
	@Pi_CmpSchCode	AS	VARCHAR(100) OUTPUT	
)
AS
/***************************************************************************************************
* PROCEDURE	: Proc_ValidateSchemeBilledProducts
* PURPOSE	: Validate SchemeDiscount and Free Product 
* CREATED	: Murugan.R
* CREATED DATE	:08/11/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}
* 06.10.2009	Panneerselvam.k		Added KeyGroup 	Field
***************************************************************************************************/
SET NOCOUNT ON
BEGIN	
		SET @Pi_Error=0
		SET @Pi_CmpSchCode=''
		IF @Pi_Type=1--Scheme Product Check
		BEGIN
			IF NOT EXISTS(SELECT Schid FROM SchemeMaster (NOLOCK) WHERE Schid=@Pi_SchId and QPS=1 and ApyQPSSch=1)
			BEGIN
				IF NOT EXISTS(SELECT A.Prdid,A.Prdbatid FROM SalesInvoiceProduct A (NOLOCK)
				INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				WHERE A.Salid=@Pi_SalId )
				BEGIN
					SET @Pi_Error=1
					SELECT @Pi_CmpSchCode=CmpSchCode FROM SchemeMaster (NOLOCK) WHERE Schid=@Pi_SchId
					RETURN
				END	
			END
		END
		IF 	@Pi_Type=2--Scheme Discount Amount Check
		BEGIN
			SELECT SalId,SUM(PrdSchDiscAmount-SchemeDisct) as Discount
			INTO #TempDiscount 
			FROM (
					SELECT Salid,SUM(PrdSchDiscAmount) as PrdSchDiscAmount,0 as  SchemeDisct 
					FROM SalesInvoiceProduct (NOLOCK) WHERE Salid=@Pi_SalId
					GROUP BY Salid
					UNION ALL
					SELECT Salid,0 as PrdSchDiscAmount,SUM(FlatAmount+DiscountPerAmount) as SchemeDisct 
					FROM SalesInvoiceSchemeLineWise (NOLOCK) WHERE Salid=@Pi_SalId
					GROUP BY Salid
				  )X GROUP BY Salid
			
			IF EXISTS(SELECT * FROM #TempDiscount WHERE Discount NOT BETWEEN -0.10 and 0.10)
			BEGIN
				SET @Pi_Error=1
				RETURN
			END
		END
		IF @Pi_Type=3--Return Scheme Product Check
		BEGIN
			IF NOT EXISTS(SELECT Schid FROM SchemeMaster (NOLOCK) WHERE Schid=@Pi_SchId and QPS=1 and ApyQPSSch=1)
			BEGIN
				IF NOT EXISTS(SELECT A.Prdid,A.Prdbatid FROM ReturnProduct A (NOLOCK)
				INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				WHERE A.ReturnId=@Pi_SalId)
				BEGIN
					SET @Pi_Error=1
					SELECT @Pi_CmpSchCode=CmpSchCode FROM SchemeMaster (NOLOCK) WHERE Schid=@Pi_SchId
					RETURN
				END	
			END
		END
		IF 	@Pi_Type=4--Scheme Discount Amount Check
		BEGIN
			SELECT ReturnId,SUM(PrdSchDiscAmount-SchemeDisct) as Discount
			INTO #TempReturnDiscount 
			FROM (
					SELECT ReturnId,SUM(PrdSchDisAmt) as PrdSchDiscAmount,0 as  SchemeDisct 
					FROM ReturnProduct (NOLOCK) WHERE ReturnId=@Pi_SalId
					GROUP BY ReturnId
					UNION ALL
					SELECT ReturnId,0 as PrdSchDiscAmount,SUM(ReturnFlatAmount+ReturnDiscountPerAmount) as SchemeDisct 
					FROM ReturnSchemeLineDt (NOLOCK) WHERE ReturnId=@Pi_SalId
					GROUP BY ReturnId
				  )X GROUP BY ReturnId
			
			IF EXISTS(SELECT * FROM #TempReturnDiscount WHERE Discount NOT BETWEEN -0.10 and 0.10)
			BEGIN
				SET @Pi_Error=1
				RETURN
			END
		END
END
GO
IF NOT EXISTS(SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'BillingWindowDisplay')
BEGIN
	CREATE TABLE BillingWindowDisplay
	(
	  SalId BIGINT,
	  RtrId BIGINT,
	  SchId BIGINT,
	  SchCode NVARCHAR(100),
	  SchName NVARCHAR(200),
	  AlredayAdjust NUMERIC (18,2),
	  TobeAdjust NUMERIC (18,2),
	  UsrId INT
	 )
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_AssignPrimaryScheme')
DROP PROCEDURE Proc_AssignPrimaryScheme
GO
CREATE PROCEDURE Proc_AssignPrimaryScheme  
(  
	@Pi_SalId  		INT		 
)  
AS  
/*********************************
* PROCEDURE	: Proc_AssignPrimaryScheme
* PURPOSE	: To Store the Primary Scheme Amount for the Billed Products
* CREATED	: Thrinath
* CREATED DATE	: 24/03/2008
* NOTE		: General SP Store the Primary Scheme amount in SalesInvoiceProduct
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
	
*********************************/  
SET NOCOUNT ON  
BEGIN 


DECLARE @SchemePrd 	TABLE
(
	SalInvNo		nVarChar(100),
	SchId			INT,
	SlabId			INT, 
	PrdId			INT,
	PrdBatId		INT,
	Combi			nVarChar(100)
)


--DECLARE @PriScheme	TABLE
--(
--	SalInvNo		nVarChar(100),
--	SalId			BIGINT,
--	SchId			INT,
--	SlabId			INT, 
--	PrdId			INT,
--	PrdBatId		INT,
--	PriAmt			Numeric(38,6)
--)


--INSERT INTO @SchemePrd (SalInvNo,SchId,SlabId,PrdId,PrdBatId,Combi)
--SELECT B.SalInvno,MIN(A.SchId),E.SlabId,A.PrdId,A.PrdBatId,
--	CAST(MIN(A.SchId) as nVarChar(15)) + ' - ' + CAST(E.SlabId as nVarChar(15))
--	FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
--	INNER JOIN (SELECT Y.SalInvno,X.SchId,X.PrdId,X.PrdBatId,MIN(SlabId) as SlabId 
--		FROM SalesInvoiceSchemeLineWise X 
--		INNER JOIN SalesInvoice Y ON X.SalId = Y.SalId 
--		WHERE Y.PrimaryApplicable = 1 
--		AND Y.SalId = ISNULL(NULLIF(@Pi_SalId,0),Y.SalId)
--		GROUP BY Y.SalInvno,X.SchId,X.PrdId,X.PrdBatId) AS E ON
--	E.SalInvNo = B.SalInvNo AND E.PrdId = A.PrdId AND E.PrdBatId = A.PrdBatId
--	AND E.SchId = A.SchId
--	WHERE B.PrimaryApplicable = 1 
--	AND B.SalId = ISNULL(NULLIF(@Pi_SalId,0),B.SalId)
--GROUP BY B.SalInvno,E.SlabId,A.PrdId,A.PrdBatId		

--INSERT INTO  @PriScheme	(SalInvNo,SalId,SchId,SlabId,PrdId,PrdBatId,PriAmt)
--SELECT DISTINCT B.SalInvNo,A.SalId,B.SchId,B.SlabId,B.PrdId,B.PrdBatId,
--	C.PrdGrossAmount - (C.PrdGrossAmount /(1 +(D.PrdBatDetailValue)/100)) 		
--FROM @SchemePrd B INNER JOIN SalesInvoice A ON A.SalInvNo = B.SalInvno 
--	AND A.PrimaryApplicable = 1 AND A.SalId = ISNULL(NULLIF(@Pi_SalId,0),A.SalId)
--	INNER JOIN SalesInvoiceProduct C ON A.SalId = C.SalId
--	AND B.PrdId = C.PrdId AND B.PrdBatId = C.PrdBatId
--	INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId 
--	AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
--		AND E.Slno = D.Slno AND E.RefCode = PrimaryRefCode

--UPDATE SalesInvoiceSchemeLineWise SET PrimarySchemeAmt = PriAmt
--	FROM SalesInvoiceSchemeLineWise A INNER JOIN @PriScheme B ON
--	A.SalId = B.SalId AND A.SchId = B.SchId AND A.SlabId = B.SlabId
--	AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId

--UPDATE SalesInvoiceProduct SET PrimarySchemeAmt = PriAmt
--	FROM SalesInvoiceProduct A INNER JOIN @PriScheme B ON
--	A.SalId = B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId

--UPDATE SalesInvoiceProduct SET PrimarySchemeAmt = A.PrdSchDiscAmount 
--	From salesinvoiceproduct A
--	LEFT OUTER JOIN SalesInvoiceSchemeLineWise B ON A.SalId = B.SalId
--	And A.prdid = B.prdid and A.prdbatid = B.PrdBatId
--	WHERE B.prdid is NULL AND A.SalId = ISNULL(NULLIF(@Pi_SalId,0),A.SalId)
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_ReturnPrimaryScheme')
DROP PROCEDURE Proc_ReturnPrimaryScheme
GO
-- EXEC Proc_ReturnPrimaryScheme 8
CREATE PROCEDURE Proc_ReturnPrimaryScheme
(
	@Pi_ReturnId  		INT,
	@Pi_ReturnType		INT		
)
AS
/*********************************
* PROCEDURE	: Proc_AssignPrimaryScheme
* PURPOSE	: To Store the Primary Scheme Amount for the Returned Products
* CREATED	: Boopathy.P
* CREATED DATE	: 25/03/2008
* NOTE		: General SP Store the Primary Scheme amount in Sales and Market Returned Products
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
Begin
	
DECLARE @SchemePrd 	TABLE
(
	ReturnCode		nVarChar(100),
	SchId			INT,
	SlabId			INT,
	PrdId			INT,
	PrdBatId		INT
)
--DECLARE @PriScheme	TABLE
--(
--	ReturnCode		nVarChar(100),
--	ReturnId			BIGINT,
--	SchId			INT,
--	SlabId			INT,
--	PrdId			INT,
--	PrdBatId		INT,
--	PriAmt			Numeric(38,6)
--)
--	INSERT INTO @SchemePrd (ReturnCode,SchId,SlabId,PrdId,PrdBatId)
--	SELECT A.ReturnCode,ISNULL(C.SchId,0),ISNULL(C.SlabId,0),B.PrdId,B.PrdBatId
--	FROM ReturnProduct B Inner Join ReturnHeader A On B.ReturnId=A.ReturnId AND
--		A.ReturnType=@Pi_ReturnType Left Outer Join ReturnSchemeLineDt C ON B.ReturnId=C.ReturnId
--		Inner Join SalesInvoice D ON B.SalId=D.SalId WHERE D.PrimaryApplicable=1 AND B.BillRef=1
--		AND B.ReturnId=@Pi_ReturnId
--	INSERT INTO  @PriScheme	(ReturnCode,ReturnId,SchId,SlabId,PrdId,PrdBatId,PriAmt)
	
--	SELECT DISTINCT B.ReturnCode,A.ReturnId,B.SchId,B.SlabId,B.PrdId,B.PrdBatId,
--		C.PrdGrossAmt - (C.PrdGrossAmt /(1 +(D.PrdBatDetailValue)/100)) 		
--	FROM @SchemePrd B INNER JOIN ReturnHeader A ON A.ReturnCode = B.ReturnCode
--		AND A.ReturnId = ISNULL(NULLIF(@Pi_ReturnId,0),A.ReturnId)
--		INNER JOIN ReturnProduct C ON A.ReturnId = C.ReturnId
--		AND B.PrdId = C.PrdId AND B.PrdBatId = C.PrdBatId
--		INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId
--		AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
--			AND E.Slno = D.Slno AND E.RefCode = 'C'
--	UPDATE ReturnSchemeLineDt SET PrimarySchAmt = PriAmt
--		FROM ReturnSchemeLineDt A INNER JOIN @PriScheme B ON
--		A.ReturnId = B.ReturnId AND A.SchId = B.SchId AND A.SlabId = B.SlabId
--		AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
	
--	UPDATE ReturnProduct SET PrimarySchAmt = PriAmt
--		FROM ReturnProduct A INNER JOIN @PriScheme B ON
--		A.ReturnId = B.ReturnId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
	
--	UPDATE ReturnProduct SET PrimarySchAmt = A.PrdSchDisAmt
--		From ReturnProduct A
--		LEFT OUTER JOIN ReturnSchemeLineDt B ON A.ReturnId = B.ReturnId
--		And A.prdid = B.prdid and A.prdbatid = B.PrdBatId
--		WHERE B.prdid is NULL AND A.ReturnId = ISNULL(NULLIF(@Pi_ReturnId,0),A.ReturnId)
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='FN' AND NAME='Fn_ReturnIsBackDated')
DROP FUNCTION Fn_ReturnIsBackDated
GO
CREATE FUNCTION Fn_ReturnIsBackDated
(
	@Pi_TransDate DATETIME,
	@Pi_ScreenId INT
)
RETURNS INT
AS
/*********************************
* FUNCTION: Fn_ReturnIsBackDated
* PURPOSE: Check For Back Dated Transcation
* NOTES: 
* CREATED: Thrinath Kola	29-06-2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 
@Pi_ScreenId		1		OrderBooking
@Pi_ScreenId		2		Billing
@Pi_ScreenId		3		SalesReturn
@Pi_ScreenId		4		LocationTransfer
@Pi_ScreenId		5		Purchase
@Pi_ScreenId		6		VanLoadUnload
@Pi_ScreenId		7		PurchaseReturn
@Pi_ScreenId		8		DebitMemo
@Pi_ScreenId		9		Collection
@Pi_ScreenId		10		CheuqeBounce
@Pi_ScreenId		11		ChequePayment
@Pi_ScreenId		12		CashBounce
@Pi_ScreenId		13		StockManagement
@Pi_ScreenId		14		BatchTransfer
@Pi_ScreenId		15		PaymentReversal
@Pi_ScreenId		16		ClaimSettlement
@Pi_ScreenId		17		IRA
@Pi_ScreenId		18		CreditNoteRetailer
@Pi_ScreenId		19		DebitNoteRetailer
@Pi_ScreenId		20		Replacement
@Pi_ScreenId		21		Salvage
@Pi_ScreenId		22		PaymentRegister
@Pi_ScreenId		23		MarketReturn
@Pi_ScreenId		24		ReturnandReplacement
@Pi_ScreenId		25		SalesPanel
@Pi_ScreenId		26		PurchaseOrder
@Pi_ScreenId		27		SchemeMonitor
@Pi_ScreenId		28		VehicleAllocation
@Pi_ScreenId		29		DeliveryProcess
@Pi_ScreenId		30		CreditNoteReplace
@Pi_ScreenId		31		ResellDamage
@Pi_ScreenId		32		CreditNoteSupplier
@Pi_ScreenId		33		DebitNoteSupplier
@Pi_ScreenId		34		RetailerOnAccount
@Pi_ScreenId		35		CreditDebitAdjust
@Pi_ScreenId		36		ChequeDisbursal
@Pi_ScreenId		37		ReturnToCompany
@Pi_ScreenId		38		StockJournal
@Pi_ScreenId		39		StdVoucher
*********************************/
BEGIN
	DECLARE @RetValue as INT
	SET @RetValue = 0
	--IF @Pi_ScreenId = 26
	--BEGIN
	--	SELECT @RetValue = COUNT(PurOrderRefNo) FROM PurchaseOrderMaster (NOLOCK)
	--		WHERE PurOrderDate > @Pi_TransDate
	--END
	--IF @Pi_ScreenId <> 39 AND @Pi_ScreenId <> 26
	--BEGIN
	--	SELECT @RetValue = COUNT(Availability) FROM StockLedger(NOLOCK)
	--	WHERE TransDate > @Pi_TransDate	
	--END
-- 	IF @Pi_ScreenId = 1 
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(OrderNo) FROM OrderBooking 
-- 			WHERE OrderDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 2 
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(SalId) FROM SalesInvoice 
-- 			WHERE SalInvDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 3
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(ReturnID) FROM ReturnHeader 
-- 			WHERE ReturnDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 4
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(LcnRefNo) FROM LocationTransferMaster 
-- 			WHERE LcnTrfDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 5
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(PurRcptId) FROM PurchaseReceipt 
-- 			WHERE GoodsRcvdDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 6
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(VanLoadRefNo) FROM VanLoadUnLoadMaster 
-- 			WHERE TransferDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 7
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(PurRetId) FROM PurchaseReturn 
-- 			WHERE PurRetDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 8
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 9
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(InvRcpNo) FROM Receipt 
-- 			WHERE InvRcpDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 10
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 11
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(ChequePayId) FROM ChequePayment 
-- 			WHERE LastModDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 12
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 13
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(StkMngRefNo) FROM StockManagement 
-- 			WHERE StkMngDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 14
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(BatRefNo) FROM BatchTransfer 
-- 			WHERE BatTrfDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 15
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 16
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 17
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 18
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(CrNoteNumber) FROM CreditNoteRetailer 
-- 			WHERE CrNoteDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 19
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(DbNoteNumber) FROM DebitNoteRetailer 
-- 			WHERE DbNoteDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 20
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 21
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(SalVageRefNo) FROM Salvage 
-- 			WHERE SalvageDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 22
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(PayAdvNo) FROM PurchasePayment 
-- 			WHERE PaymentDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 23
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 	
-- 	IF @Pi_ScreenId = 24
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(RepRefNo) FROM ReplacementHd 
-- 			WHERE RepDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 25
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(SalId) FROM SalesInvoice 
-- 			WHERE SalInvDate > @Pi_TransDate
-- 	END
-- 
 	--IF @Pi_ScreenId = 26
 	--BEGIN
 	--	SELECT @RetValue = COUNT(PurOrderRefNo) FROM PurchaseOrderMaster (NOLOCK)
 	--		WHERE PurOrderDate > @Pi_TransDate
 	--END
-- 
-- 	IF @Pi_ScreenId = 27
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
-- 
-- 	IF @Pi_ScreenId = 28
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(AllotmentNumber) FROM VehicleAllocationMaster 
-- 			WHERE AllotmentDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 29
-- 	BEGIN
-- 		SELECT @RetValue =COUNT(SalId) FROM SalesInvoice
-- 			WHERE SalDlvDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 30
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(CNRRefNo) FROM CreditNoteReplacementHd
-- 			WHERE CNRDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 31
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(ReDamRefNo) FROM ReSellDamageMaster 
-- 			WHERE ReSellDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 32
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(CrNoteNumber) FROM CreditNoteSupplier 
-- 			WHERE CrNoteDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 33
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(DBNoteNumber) FROM DebitNoteSupplier 
-- 			WHERE DBNoteDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 34
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(RtrAccRefNo) FROM RetailerOnAccount 
-- 			WHERE LastModDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 35
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(CRDBAdjustmentId) FROM CRDBAdjustment 
-- 			WHERE LastModDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 36
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(ChqDisRefNo) FROM ChequeDisbursalMaster 
-- 			WHERE ChqDisDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 37
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(RtnCmpRefNo) FROM ReturnToCompany 
-- 			WHERE RtnCmpDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 38
-- 	BEGIN
-- 		SELECT @RetValue = COUNT(StkJournalRefNo) FROM StockJournal 
-- 			WHERE StkJournalDate > @Pi_TransDate
-- 	END
-- 
-- 	IF @Pi_ScreenId = 39
-- 	BEGIN
-- 		SELECT @RetValue = 0
-- 	END
	RETURN(@RetValue)
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='TF' AND NAME='Fn_ValidateTransactionDate')
DROP FUNCTION Fn_ValidateTransactionDate
GO
--SELECT UserMessage FROM DBO.Fn_ValidateTransactionDate() WHERE UserMessage IS NOT NULL
CREATE FUNCTION Fn_ValidateTransactionDate()
RETURNS @TransactionDate TABLE 
( LastTransdate DATETIME,
  CurrentDate  DATETIME,
  iType			TinyInt,
  UserMessage	VARCHAR(200)
  
 )
 AS
 BEGIN 
						 
INSERT INTO @TransactionDate(LastTransdate,CurrentDate,iType,UserMessage)
	SELECT Max(Transdate),CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121),
	CASE WHEN DateDiff(DAY,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))<0
	THEN 1 ELSE 2 END ITYPE,
	CASE WHEN DateDiff(DAY,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))<0
	THEN 'Back Dated Transaction'

	WHEN DateDiff(DAY,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))>0
	AND DateDiff(DAY,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))<7

	THEN CAST (DateDiff(DAY,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate)) as Varchar(10))+
	' Day Difference From last transaction date' 
	WHEN DateDiff(WEEK,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))>0
	AND DateDiff(WEEK,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))<5	
	THEN  
	' More than ['+ CAST (DateDiff(WEEK,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate)) as Varchar(10))+'] Week Difference From last transaction date'  
	WHEN DateDiff(MONTH,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))>0
	AND DateDiff(MONTH,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))<12
	THEN  
	' More than ['+ CAST (DateDiff(MONTH,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate)) as Varchar(10))+'] Month Difference From last transaction date' 
	WHEN DateDiff(YEAR,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate))>0
	THEN  
	' More than ['+ CAST (DateDiff(YEAR,0,CONVERT(DATETIME,CONVERT(VARCHAR(10),Getdate(),121),121)-Max(Transdate)) as Varchar(10))+'] Year Difference From last transaction date'    

	END 
			 FROM Stockledger (NOLOCK)
RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE name ='PROC_CustomReportTempTable' AND TYPE='P')
DROP PROCEDURE PROC_CustomReportTempTable
GO
--EXEC PROC_CustomReportTempTable 1
CREATE PROCEDURE PROC_CustomReportTempTable
(
 @Pi_UsrId INT
)
AS
BEGIN
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptPurchaseReturnValues')
				   DELETE FROM RptPurchaseReturnValues WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptTransSequencing')
				   DELETE FROM RptTransSequencing WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptContractPricingValues')
				   DELETE FROM RptContractPricingValues WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptBillAttribute')
				   DELETE FROM RptBillAttribute WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptPurchaseReturnValuesDetail')
				   DELETE FROM RptPurchaseReturnValuesDetail WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempDatewiseProductwiseSales')
				   DELETE FROM TempDatewiseProductwiseSales WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TaxForReport')
				   DELETE FROM TaxForReport WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='BilledPrdHdForTax')
				   DELETE FROM BilledPrdHdForTax WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempRptStockNSales')
				   DELETE FROM TempRptStockNSales WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempRptStockNSales')
				   DELETE FROM TempRptStockNSales WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='BilledPrdDtCalculatedTax')
				   DELETE FROM BilledPrdDtCalculatedTax WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RtpSchemeWithOutPrimary')
				   DELETE FROM RtpSchemeWithOutPrimary WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempClosingStock')
				   DELETE FROM TempClosingStock WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempStockLedSummary')
				   DELETE FROM TempStockLedSummary WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempStockLedSummaryTotal')
				   DELETE FROM TempStockLedSummaryTotal  WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempLoadPrdUomwise')
				    DELETE FROM TempLoadPrdUomwise WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptSalesReportSubTab')
				    DELETE FROM RptSalesReportSubTab
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempAGAgeningRpt')
				    DELETE FROM TempAGAgeningRpt WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptBillWisePrdWiseTaxBreakup')
				    DELETE FROM RptBillWisePrdWiseTaxBreakup WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptBillWisePrdWise')
				    DELETE FROM RptBillWisePrdWise WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempBenchMarkSales')
				    DELETE FROM TempBenchMarkSales WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempASRJCWeekValue')
				    DELETE FROM TempASRJCWeekValue WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempFBMTrackReport')
				    DELETE FROM TempFBMTrackReport 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RPTBillDetailsRtrLevelTaxSummary')
				    DELETE FROM RPTBillDetailsRtrLevelTaxSummary 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempRptSalestaxsumamry')
				    DELETE FROM TempRptSalestaxsumamry WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempSampleIssue')
				    DELETE FROM TempSampleIssue WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RPTIDTReport')
				    DELETE FROM RPTIDTReport
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempShiftDetails')
				    DELETE FROM TempShiftDetails WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptPurAttribute')
				    DELETE FROM RptPurAttribute WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptChequePaymentDetail')
				    DELETE FROM RptChequePaymentDetail WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempBenchMarkAnlSales')
				    DELETE FROM TempBenchMarkAnlSales WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempOrderChange')
				    DELETE FROM TempOrderChange WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptCriticalSales')
				    DELETE FROM RptCriticalSales WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptTempDistWidth')
				    DELETE FROM RptTempDistWidth WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempDRCPDeviation')
				    DELETE FROM TempDRCPDeviation WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='DeadOutlet')
				    DELETE FROM DeadOutlet WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptProductTrack')
				    DELETE FROM RptProductTrack WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='FinalCoaOP')
				    DELETE FROM FinalCoaOP 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='FinalList')
				    DELETE FROM FinalList 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='FinalList1')
				    DELETE FROM FinalList1 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='CrDbt')
				    DELETE FROM CrDbt 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='OpenBalance')
				    DELETE FROM OpenBalance 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempFinalList')
				    DELETE FROM TempFinalList
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptOpeningBalance')
				    DELETE FROM RptOpeningBalance 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempBalanceLibSheetSummary')
				    DELETE FROM TempBalanceLibSheetSummary WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempBalanceSheetSummary')
				    DELETE FROM TempBalanceSheetSummary WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='StkMgmtCoaIds')
				    DELETE FROM StkMgmtCoaIds WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempBalanceAssSheetSummary')
				    DELETE FROM TempBalanceAssSheetSummary WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempStockLedSummary')
				    DELETE FROM TempStockLedSummary WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='AccountsTemplate')
				    DELETE FROM AccountsTemplate 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempRetailerCategory')
				    DELETE FROM TempRetailerCategory 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptCurrentStock')
				    DELETE FROM RptCurrentStock 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempRptStockNSales')
				    DELETE FROM TempRptStockNSales WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempGRNListing')
				    DELETE FROM TempGRNListing WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempReportSalesReturnValues')
				    DELETE FROM TempReportSalesReturnValues
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TmpRptIOTaxSummary')
				    DELETE FROM TmpRptIOTaxSummary WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptStockManagementAll')
				    DELETE FROM RptStockManagementAll WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptSalvageAll')
				    DELETE FROM RptSalvageAll WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptLocationTransferAll')
				    DELETE FROM RptLocationTransferAll WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempGrnListing')
				    DELETE FROM TempGrnListing WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TmpPrdWiseVatTax')
				    DELETE FROM TmpPrdWiseVatTax WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TmpRetailerWiseVatTax')
				    DELETE FROM TmpRetailerWiseVatTax WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TmpRptIOTaxSummary')
				    DELETE FROM TmpRptIOTaxSummary WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempRetailerOutstanding')
				    DELETE FROM TempRetailerOutstanding WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TmpRptIOTaxSummary')
				    DELETE FROM TmpRptIOTaxSummary WHERE UserId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='RptClaimReportAll')
				    DELETE FROM RptClaimReportAll WHERE UsrId = @Pi_UsrId 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='AccountsTemplate')
				    DELETE FROM AccountsTemplate 
				IF EXISTS (SELECT name FROM Sysobjects WHERE Type='U' AND name ='TempStockLedSummary')
				    DELETE FROM TempStockLedSummary WHERE UserId = @Pi_UsrId 
END
GO
IF NOT EXISTS(SELECT SS.NAME FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SS ON S.id=SS.id 
WHERE  S.xtype='U' and S.name='Users' and SS.name='HostName')
BEGIN
ALTER TABLE Users ADD  HostName Varchar(100) DEFAULT '' WITH  VALUES 
END
GO
UPDATE Users SET LoggedStatus = 2
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_UserValidation')
DROP PROCEDURE Proc_UserValidation
GO
CREATE PROCEDURE [Proc_UserValidation]
(	
	@Pi_UserId AS INT,
	@Pi_HostName AS Varchar(100),
	@Pi_DatabaseName AS Varchar(100),
	@Pi_UserStatus AS TinyInt OUTPUT,
	@Pi_Msg AS Varchar(300) OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UserValidation
* PURPOSE	: To Validate Users
* CREATED	: Murugan.R
* CREATED DATE	: 2013/01/23
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}     
****************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @Pi_HostNameLocked as Varchar(100)
	DECLARE @Pi_UserName as Varchar(100)
	DECLARE @Pi_Error TINYINT
	SET @Pi_Error =0
	SET @Pi_UserStatus=0
	
	BEGIN TRAN
	
	UPDATE Users Set LoggedStatus=1 where UserId=@Pi_UserId
	IF NOT EXISTS(Select UserId FROM Users (NOLOCK) WHERE UserId=@Pi_UserId and HostName NOT IN(@Pi_HostName,'') and LoggedStatus=1)
	BEGIN

		Update Users Set HostName=@Pi_HostName where UserId=@Pi_UserId
		Update Users Set HostName='' where UserId NOT IN(@Pi_UserId) and HostName=@Pi_HostName
		SET @Pi_Error=0
	END
	ELSE
	BEGIN
		IF EXISTS(
				SELECT Distinct A.HostName FROM Master..Sysprocesses A 
				INNER JOIN sys.dm_Exec_Sessions B ON A.Spid=B.session_id
				INNER JOIN master..SysDatabases C ON A.dbid=C.dbid
				WHERE C.Name=@Pi_DatabaseName AND LTRIM(RTRIM(A.HostName)) 
				IN(SELECT hostname FROM Users (NOLOCK) WHERE UserId=@Pi_UserId) and A.PROGRAM_NAME IN('Core Stocky','Visual Basic')
				and A.Spid>50 And B.Client_Interface_Name='OLEDB'
				)
		BEGIN
			SELECT @Pi_HostName=HostName,@Pi_UserName=UserName FROM Users (NOLOCK) WHERE UserId=@Pi_UserId
			SET @Pi_Error=1	
		END
		ELSE
		BEGIN
			Update Users Set HostName=@Pi_HostName where UserId=@Pi_UserId
			Update Users Set HostName='' where UserId NOT IN(@Pi_UserId) and HostName=@Pi_HostName
			SET @Pi_Error=0
		END
		
	END
	IF @Pi_Error=1 
	BEGIN
		SET @Pi_Msg='The User '+ UPPER(@Pi_UserName) +' already locked in the machine '+ @Pi_HostName
		ROLLBACK TRAN
		SET @Pi_UserStatus=1
	END
	ELSE
	BEGIN
		SELECT 'User logged In' 
		COMMIT TRAN
		SET @Pi_UserStatus=0
		SET @Pi_Msg=''
	END
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_PostVoucherCounterReset')
DROP PROCEDURE Proc_PostVoucherCounterReset
GO
CREATE PROCEDURE Proc_PostVoucherCounterReset
(
	@Pi_TabName		NVARCHAR(50),
	@Pi_FldName		NVARCHAR(50),
	@Pi_CurVal		NVARCHAR(100),
	@Pi_VocDate 		DATETIME,
	@Po_NewVoc		NVARCHAR(100) OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_PostVoucherCounterReset
* PURPOSE	: To do ReOrder the Back Dated Vouchers
* CREATED	: Nandakumar R.G
* CREATED DATE	: 09/03/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
		
	DECLARE @VocRefNo	NVARCHAR(50)

	DECLARE	@OldJVCount	INT
	DECLARE @Prefix		NVARCHAR(10)
	DECLARE @Year		NVARCHAR(10)
	DECLARE @zPad		INT

	DECLARe @NewCount	INT
	DECLARE @BaseCount	INT
	DECLARE @VocType	INT

	DECLARE @TempNewNo	TABLE
	(
		SlNo		INT,
		OldVocNo	NVARCHAR(50),
		NewNo		NVARCHAR(50)
	)

	--Get the Voucher Type
	IF @Pi_FldName='ContraVoc'
	BEGIN
		SET @VocType=0
	END
	ELSE IF @Pi_FldName='PaymentVoc'
	BEGIN
		SET @VocType=1
	END
	ELSE IF @Pi_FldName='ReceiptVoc'
	BEGIN
		SET @VocType=2
	END
	ELSE IF @Pi_FldName='JournalVoc'
	BEGIN
		SET @VocType=3
	END
	ELSE IF @Pi_FldName='SalesVoc'
	BEGIN
		SET @VocType=4
	END
	ELSE IF @Pi_FldName='PurchaseVoc'
	BEGIN
		SET @VocType=5
	END
	ELSE IF @Pi_FldName='MemoVoc'
	BEGIN
		SET @VocType=6
	END

	--Get the Prefix,Year,Zpad and Old Voucher Count from Counters
	SELECT @Prefix = Prefix,@Year = RIGHT(CurYear,2),@zPad = ZPad,@OldJVCount = CurrValue
	FROM Counters(NOLOCK) WHERE TabName=@Pi_TabName AND FldName=@Pi_FldName

	--Get the last voucher posted on previous date 
     SELECT  @BaseCount=MAX(ISNULL(CAST(SubString(VocRefNo,(LEN(@Prefix)+3),
	(LEN(VocRefNo) - (LEN(@Prefix)+2))) AS BIGINT),0) )
	FROM StdVocMaster (NOLOCK)
	WHERE VocType=@VocType AND VocDate < @Pi_VocDate 
--	SELECT @BaseCount = CAST(ISNULL(MAX(SubString(VocRefNo,(LEN(@Prefix)+3),
--	(LEN(VocRefNo) - (LEN(@Prefix)+2)))),0) AS INT)
--	FROM StdVocMaster (NOLOCK)
--	WHERE VocType=@VocType AND VocDate < @Pi_VocDate


	--Create a Table to store Old and New Voucher Nos
	IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[ReOrderVoucher]') AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	DROP TABLE [ReOrderVoucher]

	CREATE TABLE ReOrderVoucher
	(
		SlNo		INT IDENTITY(1,1),
		OldVocNo	NVARCHAR(50),
		OldVocDate	DATETIME,
		NewVocNo	NVARCHAR(50)
	)

	--Insert the Old and New Voucher Nos
	INSERT INTO ReOrderVoucher(OldVocNo,OldVocDate,NewVocNo)
	SELECT VocRefNo,VocDate,'' FROM StdVocMaster(NOLOCK) WHERE VocType=@VocType AND VocDate >= @Pi_VocDate
	ORDER BY VocDate,VocRefNo

	INSERT INTO @TempNewNo(SlNo,OldVocNo,NewNo)	
	SELECT SlNo,OldVocNo,@Prefix+CAST(RIGHT(ACM.AcmYr,2) AS NVARCHAR(2))+dbo.Fn_ReturnzPad(@ZPad,SlNo+@BaseCount) AS NewNo 	
	FROM ReOrderVoucher (NOLOCK),AcMaster ACM (NOLOCK),AcPeriod ACP (NOLOCK)
	WHERE ACM.AcmId=ACP.AcmId AND OldVocDate BETWEEN ACP.AcmSdt AND ACP.AcmEdt

	UPDATE ReOrderVoucher SET NewVocNo=NewNo
	FROM @TempNewNo A WHERE ReOrderVoucher.SlNo=A.SlNo AND ReOrderVoucher.OldVocNo collate database_default=A.OldVocNo collate database_default


	--Get the New Voucher No for the given input
	SELECT @Po_NewVoc=NewVocNo FROM ReOrderVoucher(NOLOCK) WHERE OldVocNo=@Pi_CurVal	

-- 	--Remove the Key Constrains
-- 	IF EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'FK_StdVocDetails_StdVocMaster' 
--         AND Xtype = 'F') BEGIN  ALTER TABLE [dbo].[StdVocDetails] DROP CONSTRAINT 
--         [FK_StdVocDetails_StdVocMaster] END
--                     
--         IF EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'PK_StdVocMaster' AND Xtype = 'PK')
--         BEGIN ALTER TABLE [dbo].[StdVocMaster] DROP CONSTRAINT [PK_StdVocMaster] END

	--Update Voucher tables with New Voucher Nos
		
	UPDATE StdVocDetails SET VocRefNo=NewVocNo
	FROM ReOrderVoucher(NOLOCK),StdVocMaster (NOLOCK) 
	WHERE StdVocDetails.VocRefNo=ReOrderVoucher.OldVocNo 
	AND StdVocDetails.VocRefNo=StdVocMaster.VocRefNo	
	AND StdVocMaster.VocType=@VocType
	
	UPDATE StdVocMaster SET VocRefNo=NewVocNo
	FROM ReOrderVoucher (NOLOCK)
	WHERE StdVocMaster.VocRefNo=ReOrderVoucher.OldVocNo AND StdVocMaster.VocType=@VocType

-- 	--Add the constarints again
-- 	IF NOT EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'PK_StdVocMaster' AND 
-- 	Xtype = 'PK') BEGIN ALTER TABLE [dbo].[StdVocMaster] ADD CONSTRAINT [PK_StdVocMaster] 
-- 	PRIMARY KEY  CLUSTERED ([VocRefno])  ON [PRIMARY] END	
-- 	                    
-- 	IF EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'FK_StdVocDetails_StdVocMaster' 
-- 	AND Xtype = 'F') BEGIN ALTER TABLE [dbo].[StdVocDetails] ADD CONSTRAINT 
-- 	[FK_StdVocDetails_StdVocMaster] FOREIGN KEY ([VocRefno]) REFERENCES [StdVocMaster] 
-- 	([VocRefno]) END 

	--Update the counters with New Value 
	SELECT @NewCount=MAX(SlNo)+@BaseCount FROM ReOrderVoucher(NOLOCK)
	UPDATE Counters SET CurrValue=@NewCount
	WHERE TabName=@Pi_TabName AND FldName=@Pi_FldName

	RETURN
END
GO
DELETE FROM Configuration WHERE ModuleId = 'DBCRNOTE5'
INSERT INTO Configuration
SELECT 'DBCRNOTE5','DebitNoteCreditNote','Not Allow Supplier Details in Account Type Hotsearch Credit Note (Supplier)',1,'',0.00,5
GO
DELETE FROM Profiledt WHERE PrfId IN (SELECT UserId FROM Users WHERE UserName LIKE 'USER%') AND MenuId = 'mStk5'
INSERT INTO Profiledt
SELECT DISTINCT PrfId,'mStk5',0,'New',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)
FROM ProfileHD WHERE PrfId IN (SELECT UserId FROM Users WHERE UserName LIKE 'USER%') UNION 
SELECT DISTINCT PrfId,'mStk5',1,'Edit',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)
FROM ProfileHD WHERE PrfId IN (SELECT UserId FROM Users WHERE UserName LIKE 'USER%') UNION 
SELECT DISTINCT PrfId,'mStk5',2,'Save',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)
FROM ProfileHD WHERE PrfId IN (SELECT UserId FROM Users WHERE UserName LIKE 'USER%') UNION 
SELECT DISTINCT PrfId,'mStk5',3,'Delete',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)
FROM ProfileHD WHERE PrfId IN (SELECT UserId FROM Users WHERE UserName LIKE 'USER%') UNION
SELECT DISTINCT PrfId,'mStk5',6,'Print',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)
FROM ProfileHD WHERE PrfId IN (SELECT UserId FROM Users WHERE UserName LIKE 'USER%') 
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')
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
	[BX] [int] NULL,
	[PB] [int] NULL,
	[PKT] [int] NULL,
	[TOR] [int] NULL,
	[CN] [int] NULL,
	[JAR] [int] NULL,
	[GB] [int] NULL,
	[ROL] [int] NULL,
	[Product Weight] [numeric](38, 6) NULL,
	[Product UPC] [numeric](38, 6) NULL,
	[Payment Mode] [NVARCHAR](20) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RptBillTemplateFinal] ADD  DEFAULT ((0)) FOR [Product Weight]
GO
ALTER TABLE [dbo].[RptBillTemplateFinal] ADD  DEFAULT ((0)) FOR [Product UPC]
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_RptBillTemplateFinal')
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
		Exec('CREATE TABLE RptBillTemplateFinal
		(' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500),'+ @UomFieldList +')')
	END
	ELSE
	BEGIN
		Exec('CREATE TABLE RptBillTemplateFinal
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
		Delete from RptBillTemplateFinal Where UsrId = @Pi_UsrId
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
		GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc
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
	INSERT INTO RptBillTemplate_PrdUOMDetails(SalId,SalInvNo,TotPrdVolume,TotPrdKG,TotPrdLtrs,TotPrdUnits,
	TotPrdDrums,TotPrdCartons,TotPrdBuckets,TotPrdPieces,TotPrdBags,UsrId)	
	SELECT SalId,SalInvNo,SUM(TotPrdVolume) AS TotPrdVolume,SUM(TotPrdKG) AS TotPrdKG,SUM(TotPrdLtrs) AS TotPrdLtrs,SUM(TotPrdUnits) AS TotPrdUnits,
	SUM(TotPrdDrums) AS TotPrdDrums,SUM(TotPrdCartons) AS TotPrdCartons,SUM(TotPrdBuckets) AS TotPrdBuckets,SUM(TotPrdPieces) AS TotPrdPieces,SUM(TotPrdBags) AS TotPrdBags,@Pi_UsrId
	FROM
	(
		SELECT DISTINCT SI.SalId,SI.SalInvNo,SIP.PrdId,SIP.BaseQty*dbo.Fn_ReturnProductVolumeInLtrs(SIP.PrdId) AS TotPrdVolume,
		SIP.BaseQty*P.PrdUpSKU * (CASE P.PrdUnitId WHEN 2 THEN .001 WHEN 3 THEN 1 ELSE 0 END) AS TotPrdKG,
		SIP.BaseQty * P.PrdWgt * (CASE P.PrdUnitId WHEN 4 THEN .001 WHEN 5 THEN 1 ELSE 0 END) AS TotPrdLtrs,
		SIP.BaseQty*(CASE P.PrdUnitId WHEN 1 THEN 0 ELSE 0 END) AS TotPrdUnits,
		(CASE ISNULL(UMP1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP1.UOM1Qty,0) END)+
		(CASE ISNULL(UMP2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP2.UOM2Qty,0) END) AS TotPrdPieces,
		(CASE ISNULL(UMBU1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU1.UOM1Qty,0) END)+
		(CASE ISNULL(UMBU2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU2.UOM2Qty,0) END) AS TotPrdBuckets,
		(CASE ISNULL(UMBA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA1.UOM1Qty,0) END)+
		(CASE ISNULL(UMBA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA2.UOM2Qty,0) END) AS TotPrdBags,
		(CASE ISNULL(UMDR1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR1.UOM1Qty,0) END)+
		(CASE ISNULL(UMDR2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR2.UOM2Qty,0) END) AS TotPrdDrums,
		(CASE ISNULL(UMCA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA1.UOM1Qty,0) END)+
		(CASE ISNULL(UMCA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA2.UOM2Qty,0) END)+ 
		CEILING((CASE ISNULL(UMCN1.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN1.UOM1Qty,0) AS NUMERIC(38,6))/CAST(UGC1.ConvFact AS NUMERIC(38,6)) END))+
		CEILING((CASE ISNULL(UMCN2.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN2.UOM2Qty,0) AS NUMERIC(38,6))/CAST(UGC2.ConvFact AS NUMERIC(38,6)) END)) AS TotPrdCartons
		FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
		INNER JOIN RptBillToPrint Rpt ON SI.SalInvNo = Rpt.[Bill Number] AND Rpt.UsrId=@Pi_UsrId
		INNER JOIN Product P ON SIP.PrdID=P.PrdID
		INNER JOIN ProductBatch PB ON SIP.PrdBatID=PB.PrdBatID AND P.PrdID=PB.PrdId
		LEFT OUTER JOIN SalesInvoiceProduct SIPP1 ON SI.SalId=SIPP1.SalId AND SIP.PrdID=SIPP1.PrdID AND SIP.PrdBatID=SIPP1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPP2 ON SI.SalId=SIPP2.SalId AND SIP.PrdID=SIPP2.PrdID AND SIP.PrdBatID=SIPP2.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPBU1 ON SI.SalId=SIPBU1.SalId AND SIP.PrdID=SIPBU1.PrdID AND SIP.PrdBatID=SIPBU1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPBU2 ON SI.SalId=SIPBU2.SalId AND SIP.PrdID=SIPBU2.PrdID AND SIP.PrdBatID=SIPBU2.PrdBatID		
		LEFT OUTER JOIN SalesInvoiceProduct SIPBA1 ON SI.SalId=SIPBA1.SalId AND SIP.PrdID=SIPBA1.PrdID AND SIP.PrdBatID=SIPBA1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPBA2 ON SI.SalId=SIPBA2.SalId AND SIP.PrdID=SIPBA2.PrdID AND SIP.PrdBatID=SIPBA2.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPDR1 ON SI.SalId=SIPDR1.SalId AND SIP.PrdID=SIPDR1.PrdID AND SIP.PrdBatID=SIPDR1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPDR2 ON SI.SalId=SIPDR2.SalId AND SIP.PrdID=SIPDR2.PrdID AND SIP.PrdBatID=SIPDR2.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPCA1 ON SI.SalId=SIPCA1.SalId AND SIP.PrdID=SIPCA1.PrdID AND SIP.PrdBatID=SIPCA1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPCA2 ON SI.SalId=SIPCA2.SalId AND SIP.PrdID=SIPCA2.PrdID AND SIP.PrdBatID=SIPCA2.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPCN1 ON SI.SalId=SIPCN1.SalId AND SIP.PrdID=SIPCN1.PrdID AND SIP.PrdBatID=SIPCN1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPCN2 ON SI.SalId=SIPCN2.SalId AND SIP.PrdID=SIPCN2.PrdID AND SIP.PrdBatID=SIPCN2.PrdBatID
		LEFT OUTER JOIN UOMMaster UMP1 ON UMP1.UOMId=SIPP1.UOM1Id AND UMP1.UOMDescription='PIECES'
		LEFT OUTER JOIN UOMMaster UMP2 ON UMP1.UOMId=SIPP2.UOM2Id AND UMP2.UOMDescription='PIECES'
		LEFT OUTER JOIN UOMMaster UMBU1 ON UMBU1.UOMId=SIPBU1.UOM1Id AND UMBU1.UOMDescription='BUCKETS' 
		LEFT OUTER JOIN UOMMaster UMBU2 ON UMBU1.UOMId=SIPBU2.UOM2Id AND UMBU2.UOMDescription='BUCKETS'
		LEFT OUTER JOIN UOMMaster UMBA1 ON UMBA1.UOMId=SIPBA1.UOM1Id AND UMBA1.UOMDescription='BAGS' 
		LEFT OUTER JOIN UOMMaster UMBA2 ON UMBA1.UOMId=SIPBA2.UOM2Id AND UMBA2.UOMDescription='BAGS'
		LEFT OUTER JOIN UOMMaster UMDR1 ON UMDR1.UOMId=SIPDR1.UOM1Id AND UMDR1.UOMDescription='DRUMS' 
		LEFT OUTER JOIN UOMMaster UMDR2 ON UMDR1.UOMId=SIPDR2.UOM2Id AND UMDR2.UOMDescription='DRUMS'
		LEFT OUTER JOIN UOMMaster UMCA1 ON UMCA1.UOMId=SIPCA1.UOM1Id AND UMCA1.UOMDescription='CARTONS' 
		LEFT OUTER JOIN UOMMaster UMCA2 ON UMCA1.UOMId=SIPCA2.UOM2Id AND UMCA2.UOMDescription='CARTONS'
		LEFT OUTER JOIN UOMMaster UMCN1 ON UMCN1.UOMId=SIPCN1.UOM1Id AND UMCN1.UOMDescription='CANS' 
		LEFT OUTER JOIN UOMMaster UMCN2 ON UMCN1.UOMId=SIPCN2.UOM2Id AND UMCN2.UOMDescription='CANS'
		LEFT OUTER JOIN (
		SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG
		WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN ( 
		SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )
		GROUP BY P.PrdID) UGC1 ON SIPCN1.PrdId=UGC1.PrdID
		LEFT OUTER JOIN (
		SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG
		WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN ( 
		SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )
		GROUP BY P.PrdID) UGC2 ON SIPCN2.PrdId=UGC2.PrdID
	) A
	GROUP BY SalId,SalInvNo
	--->Till Here
	--Added By Sathishkumar Veeramani 2012/12/13
	IF NOT EXISTS (SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')AND name = 'Payment Mode')
	BEGIN
	     ALTER TABLE RptBillTemplateFinal ADD [Payment Mode] NVARCHAR(20)
	     UPDATE A SET A.[Payment Mode] = Z.[Payment Mode] FROM RptBillTemplateFinal A INNER JOIN 
	    (SELECT SalId,(CASE RtrPayMode WHEN 1 THEN 'Cash' ELSE 'Cheque' END) AS [Payment Mode] FROM SalesInvoice WITH (NOLOCK)) Z ON A.Salid = Z.SalId 
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
DELETE FROM ScreenDefaultValues WHERE TransId = 101 AND CtrlValue IN (6,7,8) AND CtrlId = 101
INSERT INTO ScreenDefaultValues
SELECT 101,101,6,'Bill Number',6,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'Bill Number' UNION
SELECT 101,101,7,'Bill Date',7,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'Bill Date' UNION
SELECT 101,101,8,'Retailer',8,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'Retailer'
GO
DELETE FROM CustomCaptions WHERE TransId = 138 AND CtrlId = 2000 AND SubCtrlId IN (2,5,6)
INSERT INTO CustomCaptions
SELECT 138,2000,2,'HotSch-138-2000-2','Retailer','','',1,1,1,GETDATE(),1,GETDATE(),'Retailer','','',1,1 UNION
SELECT 138,2000,5,'HotSch-138-2000-5','Bill Number','','',1,1,1,GETDATE(),1,GETDATE(),'Bill Number','','',1,1 UNION
SELECT 138,2000,6,'HotSch-138-2000-6','Bill Date','','',1,1,1,GETDATE(),1,GETDATE(),'Bill Date','','',1,1
--Sathish Veera Till Hetre
GO
DELETE FROM Configuration WHERE ModuleId IN ('PURCHASERECEIPT10','RET19')
INSERT INTO Configuration
SELECT 'PURCHASERECEIPT10','Purchase Receipt','Allow saving of Purchase Receipt even if there is a rate difference',0,'',0.00,10 UNION
SELECT 'RET19','Retailer','Treat Retailer TaxGroup as Mandatory',1,'',0.00,19
GO
IF EXISTS (SELECT RtrGroup FROM TaxGroupSetting WHERE RtrGroup = 'RET GRP')
BEGIN
	DECLARE @TaxGroupId AS INT
	SELECT @TaxGroupId = TaxGroupId FROM TaxGroupSetting WHERE RtrGroup = 'RET GRP'
	DELETE FROM Configuration WHERE ModuleId = 'RET12'
	INSERT INTO Configuration 
	SELECT 'RET12','Retailer','Set the default Retailer Tax Group as... while adding a new retailer',1,'RET GRP',@TaxGroupId,12
END
GO
DELETE FROM RptExcelHeaders WHERE RptId = 4
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,1,'SalId','SalId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,2,'SalInvNo','Bill Number',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,3,'SalInvDate','Bill Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,4,'SalInvRef','SalRef Number',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,5,'InvRcpNo','Receipt Number',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,6,'InvRcpDate','Collection Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,7,'RtrId','RtrId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,8,'RtrName','Retailer Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,9,'Bill Amount','Bill Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,10,'CurPayAmount','Current PayAmount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,11,'CrAdjAmount','Cr.Adj.Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,12,'DbAdjAmount','Db.Adj.Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,13,'CashDiscount','Cash Discount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,14,'CollCashAmt','Collect CashAmt',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,15,'CollChqAmt','Collect ChqAmt',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,16,'CollDDAmt','Collect DDAmt',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,17,'CollRTGSAmt','CollRTGSAmt',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,18,'BalanceAmount','Balance Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,19,'CollectedAmount','Collected Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,20,'PayAmount','Payment Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,21,'TotalBillAmount','Total Bill Amount',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (4,22,'AmtStatus','Amount Status',0,1)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND Name = 'Proc_RptCollectionReport')
DROP PROCEDURE Proc_RptCollectionReport
GO
--EXEC Proc_RptCollectionReport 4,1,0,'CoreStocky',0,0,1
 CREATE PROCEDURE Proc_RptCollectionReport
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
	
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @DlvRId		AS  INT
	DECLARE @SColId		AS  INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SalId	 	AS	BIGINT
	DECLARE @TypeId		AS	INT
	DECLARE @TotBillAmount	AS	NUMERIC(38,6)
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @DlvRId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @TypeId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,77,@Pi_UsrId))
	SET @SColId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))	
	IF @SColId=1
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo IN (2,3) AND RptId = @Pi_UsrId
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE SlNo IN (5,6) AND RptId = @Pi_UsrId
	END
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE SlNo IN (2,3) AND RptId = @Pi_UsrId
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo IN (5,6) AND RptId = @Pi_UsrId
	END 
	CREATE TABLE #RptCollectionDetail
	(
		SalId 			BIGINT,
		SalInvNo		NVARCHAR(50),
		SalInvDate              DATETIME,
		SalInvRef 		NVARCHAR(50),
		RtrId 			INT,
		RtrName                 NVARCHAR(50),
		BillAmount              NUMERIC (38,6),
		CrAdjAmount             NUMERIC (38,6),
		DbAdjAmount             NUMERIC (38,6),
		CashDiscount		NUMERIC (38,6),
		CollectedAmount         NUMERIC (38,6),
		BalanceAmount           NUMERIC (38,6),
		PayAmount           	NUMERIC (38,6),
		TotalBillAmount		NUMERIC (38,6),
		AmtStatus 			NVARCHAR(10),
		InvRcpDate			DATETIME,
		CurPayAmount        NUMERIC (38,6),
		CollCashAmt			NUMERIC (38,6),
		CollChqAmt			NUMERIC (38,6),
		CollDDAmt			NUMERIC (38,6),
		CollRTGSAmt			NUMERIC (38,6),
		[CashBill]			[numeric](38, 0) NULL,
		[ChequeBill]		[numeric](38, 0) NULL,
		[DDbill]			[numeric](38, 0) NULL,
		[RTGSBill]			[numeric](38, 0) NULL,
		[TotalBills]		[numeric](38, 0) NULL,		
		InvRcpNo			nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
		
	)
	SET @TblName = 'RptCollectionDetail'
	SET @TblStruct = '	SalId 			BIGINT,
				SalInvNo		NVARCHAR(50),
				SalInvDate              DATETIME,
				SalInvRef 		NVARCHAR(50),
				RtrId 			INT,
				RtrName                 NVARCHAR(50),
				BillAmount              NUMERIC (38,6),
				CrAdjAmount             NUMERIC (38,6),
				DbAdjAmount             NUMERIC (38,6),
				CashDiscount		NUMERIC (38,6),
				CollectedAmount         NUMERIC (38,6),
				BalanceAmount           NUMERIC (38,6),
				PayAmount           	NUMERIC (38,6),
				TotalBillAmount		NUMERIC (38,6),
				AmtStatus 		NVARCHAR(10),
				InvRcpDate		DATETIME,
				CurPayAmount           	NUMERIC (38,6),
				CollCashAmt NUMERIC (38,6),
				CollChqAmt NUMERIC (38,6),
				CollDDAmt  NUMERIC (38,6),
				CollRTGSAmt NUMERIC (38,6),
				[CashBill] [numeric](38, 0) NULL,
				[ChequeBill] [numeric](38, 0) NULL,
				[DDbill] [numeric](38, 0) NULL,
				[RTGSBill] [numeric](38, 0) NULL,
				[TotalBills]		[numeric](38, 0) NULL,
				InvRcpNo nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
				'
	SET @TblFields = 'SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
			  BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
			  BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,
				CollChqAmt,CollDDAmt,CollRTGSAmt,[CashBill],[ChequeBill],[DDbill],[RTGSBill],[TotalBills],InvRcpNo'
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
	IF @TypeId=1 
	BEGIN
		EXEC Proc_CollectionValues 4
		
	END
	ELSE
	BEGIN	
		EXEC Proc_CollectionValues 1
	END
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN 
		INSERT INTO #RptCollectionDetail (SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
		BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt
		,InvRcpNo)
		SELECT SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CashDiscount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId),
		ABS(dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId))
		--dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)
		AS BalanceAmount,dbo.Fn_ConvertCurrency(PayAmount,@Pi_CurrencyId),0 AS TotalBillAmount,
		(	--Commented and Added by Thiru on 20/11/2009
--			CASE WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
--			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))>0 
--			THEN 'Db' 
--			WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
--			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))< 0 
--			THEN 'Cr' 
--			ELSE '' END
			CASE WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))>0 
			THEN 'Db' 
			WHEN (dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)+dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId)
			-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId))< 0 
			THEN 'Cr' 
			ELSE '' END
--Till Here
		) AS AmtStatus,
		R.InvRcpDate,dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollCashAmt,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollChqAmt,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollDDAmt,@Pi_CurrencyId)
		,dbo.Fn_ConvertCurrency(CollRTGSAmt,@Pi_CurrencyId),R.InvRcpNo
		FROM RptCollectionValue R
		WHERE (SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
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
		AND
		(SalId = (CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
		SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))) 
		AND InvRcpDate BETWEEN @FromDate AND @ToDate 
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptCollectionDetail ' + 
				'(' + @TblFields + ')' + 
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 
				+  ' WHERE (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '+
				'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR ' +
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RMId = (CASE ' + CAST(@DlvRId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR ' +
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',35,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '+
				'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (SalId = (CASE ' + CAST(@SalId AS nVarchar(10)) + ' WHEN 0 THEN SalId ELSE 0 END) OR ' +
				'SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',14,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) 
				AND INvRcpDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
	
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCollectionDetail'
				
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
			SET @SSQL = 'INSERT INTO #RptCollectionDetail ' + 
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptCollectionDetail
	-- Till Here
	
	CREATE TABLE #Tempbalance
	(
		Billamt numeric(18,4),
		CurPayAmt numeric(18,4),
		Balance numeric(18,4),
		RtrId int,
		Salesinvoice nvarchar(50),
		Receiptinvoice nvarchar(50)
	)
	DECLARE @BillAmount NUMERIC (38,6)
	DECLARE @CurPayAmount NUMERIC (38,6)
	DECLARE @BalanceAmount NUMERIC (38,6)
	DECLARE @InvRcpNo nvarchar(50)
	DECLARE @SalinvNo nvarchar(50)
	DECLARE @TempInvoiceRcpNo nvarchar(50)
	DECLARE @CurPayAmountbal NUMERIC (38,6)
	DECLARE @BalRtrId int
	DECLARE Cur_BalanceAmt CURSOR FOR
	SELECT BillAmount,CurPayAmount,BalanceAmount,InvRcpNo,SalInvNo,RtrId FROM #RptCollectionDetail ORDER BY SalInvNo,InvRcpNo
	OPEN Cur_BalanceAmt
	FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT into #Tempbalance(BillAmt,CurPayAmt,RtrId,Salesinvoice,Receiptinvoice) VALUES (@BillAmount,@CurPayAmount,@BalRtrId,@SalinvNo,@InvRcpNo)
        SELECT @CurPayAmountbal=sum(CurPayAmt) FROM #Tempbalance WHERE RtrId=@BalRtrId AND Salesinvoice=@SalinvNo --AND Receiptinvoice=@InvRcpNo
        UPDATE #RptCollectionDetail SET BalanceAmount=BillAmount-@CurPayAmountbal WHERE CurPayAmount=@CurPayAmount
		AND SalInvNo=@SalinvNo AND InvRcpNo=@InvRcpNo AND RtrId=@BalRtrId
		FETCH NEXT FROM Cur_BalanceAmt INTO @BillAmount,@CurPayAmount,@BalanceAmount,@InvRcpNo,@SalinvNo,@BalRtrId
	END
	CLOSE Cur_BalanceAmt
	DEALLOCATE Cur_BalanceAmt
	
	UPDATE #RptCollectionDetail SET  [CashBill]=(CASE WHEN CollCashAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [ChequeBill]=(CASE WHEN CollChqAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [DDbill]=(CASE WHEN BalanceAmount<>0 THEN 1 ELSE 0 END) WHERE  AmtStatus='DB'
	UPDATE #RptCollectionDetail SET  [RTGSBill]=(CASE WHEN  CollRTGSAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [TotalBills]=(SELECT Count(Salid) FROM #RptCollectionDetail)
	
	SELECT SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
	BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
	ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus,
	CashBill,Chequebill,DDBill,RTGSBill,InvRcpNo,[TotalBills] FROM #RptCollectionDetail ORDER BY SalId,InvRcpDate,InvRcpNo

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCollectionDetail_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptCollectionDetail_Excel
		SELECT  SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
			BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
			ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,
			ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus INTO RptCollectionDetail_Excel FROM #RptCollectionDetail
	END

RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'U' AND Name = 'PDA_Order_Marketreturn')
DROP TABLE PDA_Order_Marketreturn
GO
CREATE TABLE PDA_Order_Marketreturn(
	[OrdKeyNo] [varchar](50) NULL,
	[SrNo] [varchar](100) NULL,
	[RtrId] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_StockCorrection' AND XTYPE='P')
DROP PROC Proc_StockCorrection
GO
--Exec Proc_StockCorrection 0
CREATE PROCEDURE Proc_StockCorrection
(
	@Po_ErrNo INT OUTPUT
)
AS
/************************************************************
* PROCEDURE	: Proc_StockCorrection
* PURPOSE	: To update the Stock for Bill not deleiver issue
* SCREEN	: Console Integration-Product Download
* CREATED	: Nandakumar R.G On 24-04-2010
* MODIFIED	:
* DATE      AUTHOR     DESCRIPTION
-------------------------------------------------------------
* {date} {developer}  {brief modIFication description}
*************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @StockLedgerStock TABLE
	(
		PrdId INT,
		PrdBatId INT ,
		LcnId INT ,
		TransDate DATETIME,
		ClosingStock INT
	)
	DELETE FROM @StockLedgerStock
	--->For Salesable Stock
	if exists (select * from dbo.sysobjects where id = object_id(N'[PrdBatStockCorrection]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [PrdBatStockCorrection]
	SELECT SIP.LcnId,SIP.PrdId,SIP.PrdBatId,SIP.BaseQty,PBL.PrdBatLcnResSih,(SIP.BaseQty-PBL.PrdBatLcnResSih) AS QtyToUpdate
	INTO PrdBatStockCorrection
	FROM ProductBatchLocation PBL,
	(
		SELECT SI.LcnId,SIP.PrdId,SIP.PrdBatId,SUM(SIP.BaseQty) AS BaseQty FROM SalesInvoiceProduct SIP,SalesInvoice SI
		WHERE SI.DlvSts IN (1,2) AND SIP.SalId=SI.SalId
		GROUP BY SI.LcnId,SIP.PrdId,SIP.PrdBatId
	) SIP
	WHERE SIP.PrdId=PBL.PrdId AND SIP.PrdBatId=PBL.PrdBatId AND PBL.PrdBatLcnResSih<SIP.BaseQty AND SIP.Lcnid=PBL.Lcnid
	ORDER BY SIP.LcnId,SIP.PrdId,SIP.PrdBatId 
	if exists (select * from dbo.sysobjects where id = object_id(N'[PrdBatStockCorrection]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	BEGIN
		UPDATE PBL SET PBL.PrdBatLcnResSih=PBL.PrdBatLcnResSih+PBS.QtyToUpdate
		FROM ProductBatchLocation PBL,PrdBatStockCorrection PBS
		WHERE PBL.PrdId=PBS.PrdId AND PBL.PrdBatId=PBS.PrdBatId AND PBL.LcnId=PBS.LcnId
		INSERT INTO @StockLedgerStock(PrdId,PrdBatId,LcnId,TransDate,ClosingStock)
		SELECT B.PrdId,B.PrdBatId,B.LcnId,B.TransDate,ST1.SalClsStock FROM StockLedger ST1 (NOLOCK),		
		(SELECT MAX(ST.TransDate) AS TransDate,PBS.PrdId,PBS.PrdBatId,PBS.LcnId FROM StockLedger ST (NOLOCK),
		PrdBatStockCorrection PBS WHERE PBS.PrdId=ST.PrdId AND PBS.PrdBatId=ST.PrdBatId AND PBS.LcnId=ST.LcnId
		GROUP BY PBS.PrdId,PBS.PrdBatId,PBS.LcnId) B 
			WHERE B.PrdId=ST1.PrdId AND B.PrdBatId=ST1.PrdBatId AND B.LcnId=ST1.LcnId
			AND B.TransDate=ST1.TransDate
		UPDATE ProductBatchLocation SET PrdBatLcnSih=B.ClosingStock+PrdBatLcnResSih 
		FROM ProductBatchLocation A,@StockLedgerStock B 
		WHERE A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.LcnId=B.LcnId
----		UPDATE ProductBatchLocation SET PrdBatLcnSih=PrdBatLcnResSih
----		WHERE PrdBatLcnSih<PrdBatLcnResSih
		
		
	END
	
	--->For Offer(Free) Stock
	if exists (select * from dbo.sysobjects where id = object_id(N'[PrdBatStockCorrection]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [PrdBatStockCorrection]
	SELECT SIP.LcnId,SIP.FreePrdId AS PrdId,SIP.FreePrdBatId AS PrdBatId,SIP.BaseQty,PBL.PrdBatLcnResFre AS PrdBatLcnResSih,(SIP.BaseQty-PBL.PrdBatLcnResFre) AS QtyToUpdate
	INTO PrdBatStockCorrection
	FROM ProductBatchLocation PBL,
	(
		SELECT SI.LcnId,SIP.FreePrdId,SIP.FreePrdBatId,SUM(SIP.FreeQty) AS BaseQty FROM SalesInvoiceSchemeDtFreePrd SIP,SalesInvoice SI
		WHERE SI.DlvSts IN (1,2) AND SIP.SalId=SI.SalId
		GROUP BY SI.LcnId,SIP.FreePrdId,SIP.FreePrdBatId
	) SIP
	WHERE SIP.FreePrdId=PBL.PrdId AND SIP.FreePrdBatId=PBL.PrdBatId AND PBL.PrdBatLcnResFre<SIP.BaseQty AND SIP.Lcnid=PBL.Lcnid
	ORDER BY SIP.LcnId,SIP.FreePrdId,SIP.FreePrdBatId 
	if exists (select * from dbo.sysobjects where id = object_id(N'[PrdBatStockCorrection]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	BEGIN
		UPDATE PBL SET PBL.PrdBatLcnResFre=PBL.PrdBatLcnResFre+PBS.QtyToUpdate
		FROM ProductBatchLocation PBL,PrdBatStockCorrection PBS
		WHERE PBL.PrdId=PBS.PrdId AND PBL.PrdBatId=PBS.PrdBatId AND PBL.LcnId=PBS.LcnId
		DELETE FROM @StockLedgerStock
		INSERT INTO @StockLedgerStock(PrdId,PrdBatId,LcnId,TransDate,ClosingStock)
		SELECT B.PrdId,B.PrdBatId,B.LcnId,B.TransDate,ST1.OfferClsStock FROM StockLedger ST1 (NOLOCK),		
		(SELECT MAX(ST.TransDate) AS TransDate,PBS.PrdId,PBS.PrdBatId,PBS.LcnId FROM StockLedger ST (NOLOCK),
		PrdBatStockCorrection PBS WHERE PBS.PrdId=ST.PrdId AND PBS.PrdBatId=ST.PrdBatId AND PBS.LcnId=ST.LcnId
		GROUP BY PBS.PrdId,PBS.PrdBatId,PBS.LcnId) B 
			WHERE B.PrdId=ST1.PrdId AND B.PrdBatId=ST1.PrdBatId AND B.LcnId=ST1.LcnId
			AND B.TransDate=ST1.TransDate
		UPDATE ProductBatchLocation SET PrdBatLcnFre=B.ClosingStock+PrdBatLcnResFre 
		FROM ProductBatchLocation A,@StockLedgerStock B 
		WHERE A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.LcnId=B.LcnId
----		UPDATE ProductBatchLocation SET PrdBatLcnFre=PrdBatLcnResFre
----		WHERE PrdBatLcnFre<PrdBatLcnResFre
	END
--	--->For Offer(Gift) Stock
--	if exists (select * from dbo.sysobjects where id = object_id(N'[PrdBatStockCorrection]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
--	drop table [PrdBatStockCorrection]
--
--	SELECT SIP.LcnId,SIP.GiftPrdId AS PrdId,SIP.GiftPrdBatId AS PrdBatId,SIP.BaseQty,PBL.PrdBatLcnResSih,(SIP.BaseQty-PBL.PrdBatLcnResSih) AS QtyToUpdate
--	INTO PrdBatStockCorrection
--	FROM ProductBatchLocation PBL,
--	(
--		SELECT SI.LcnId,SIP.GiftPrdId,SIP.GiftPrdBatId,SUM(SIP.GiftQty) AS BaseQty FROM SalesInvoiceSchemeDtFreePrd SIP,SalesInvoice SI
--		WHERE SI.DlvSts IN (1,2) AND SIP.SalId=SI.SalId
--		GROUP BY SI.LcnId,SIP.GiftPrdId,SIP.GiftPrdBatId
--	) SIP
--	WHERE SIP.GiftPrdId=PBL.PrdId AND SIP.GiftPrdBatId=PBL.PrdBatId AND PBL.PrdBatLcnResFre<SIP.BaseQty
--	ORDER BY SIP.LcnId,SIP.GiftPrdId,SIP.GiftPrdBatId 
--
--	if exists (select * from dbo.sysobjects where id = object_id(N'[PrdBatStockCorrection]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
--	BEGIN
--		UPDATE PBL SET PBL.PrdBatLcnResFre=PBL.PrdBatLcnResFre+PBS.QtyToUpdate
--		FROM ProductBatchLocation PBL,PrdBatStockCorrection PBS
--		WHERE PBL.PrdId=PBS.PrdId AND PBL.PrdBatId=PBS.PrdBatId AND PBL.LcnId=PBS.LcnId
--
--		UPDATE ProductBatchLocation SET PrdBatLcnFre=PrdBatLcnResSih
--		WHERE PrdBatLcnFre<PrdBatLcnResFre
--	END
END
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 10053
INSERT INTO HotSearchEditorHd
SELECT '10053','Retailer Master','RetailerCode','select',
'SELECT distinct CustomerCode,CustomerName FROM PDA_NewRetailer where CustomerCode not in (select RtrCode from Retailer)'
GO
DELETE FROM HotSearchEditorDT WHERE FormId = 10053
INSERT INTO HotSearchEditorDT
SELECT 1,10053,'RetailerCode','Code','CustomerCode',1000,0,'HotSch-79-2000-23',79 UNION ALL
SELECT 2,10053,'RetailerCode','Name','CustomerName',3500,0,'HotSch-79-2000-24',79
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'PDA_NewRetailer')
DROP TABLE PDA_NewRetailer
GO
CREATE TABLE PDA_NewRetailer(
	[CustomerCode] [nvarchar](200) NULL,
	[CustomerName] [nvarchar](200) NULL,
	[Address1] [nvarchar](200) NULL,
	[Address2] [nvarchar](200) NULL,
	[Address3] [nvarchar](200) NULL,
	[City] [nvarchar](100) NULL,
	[State] [nvarchar](150) NULL,
	[Zip] [nvarchar](50) NULL,
	[Phone] [nvarchar](100) NULL,
	[Fax] [nvarchar](100) NULL,
	[Email] [nvarchar](100) NULL,
	[ContactPerson] [nvarchar](200) NULL,
	[GeoCodeX] [nvarchar](200) NULL,
	[GeoCodeY] [nvarchar](200) NULL,
	[Notes] [nvarchar](500) NULL,
	[CustomerStatus] [int] NULL,
	[CtgCode] [nvarchar](100) NULL,
	[CtgName] [nvarchar](200) NULL,
	[ValueClassCode] [nvarchar](100) NULL,
	[ValueClassName] [nvarchar](200) NULL,
	[RtrClassid] [int] NULL,
	[CtgMainid] [int] NULL,
	[CtgLinkid] [int] NULL,
	[CtgLevelId] [int] NULL,
	[CtgLinkCode] [nvarchar](100) NULL,
	[CtgLevelName] [varchar](100) NULL,
	[Cmpid] [int] NULL,
	[CmpName] [nvarchar](200) NULL
) ON [PRIMARY]
GO
DELETE FROM HotsearchEditorHD WHERE Formid = 330
INSERT INTO HotsearchEditorHD
SELECT 330,'Return And Replacement','Replacement Batch','select',
'SELECT PrdBatId,PrdBatCode,SellingRate,MRP,PurchaseRate,DefaultPriceId FROM(SELECT PB.PrdBatId,PB.PrdBatCode,PBD1.PrdBatDetailValue AS MRP,
PBD2.PrdBatDetailValue AS PurchaseRate,PBD3.PrdBatDetailValue AS SellingRate,PB.DefaultPriceId FROM ProductBatch PB WITH (NOLOCK), 
ProductBatchDetails PBD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),ProductBatchDetails PBD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK), 
ProductBatchDetails PBD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK),ProductBatchLocation PBL WITH(NOLOCK)
WHERE PB.PrdBatId = PBD1.PrdBatId And BC1.BatchSeqId = PB.BatchSeqId AND PB.PrdBatID = PBL.PrdBatID AND PBD1.SlNo=BC1.SlNo AND BC1.MRP=1 
AND PBD1.DefaultPrice=1 AND PB.PrdBatId = PBD2.PrdBatId AND BC2.BatchSeqId = PB.BatchSeqId AND PBD2.SlNo=BC2.SlNo 
AND BC2.ListPrice=1 AND PBD2.DefaultPrice=1 AND PB.PrdBatId = PBD3.PrdBatId And BC3.BatchSeqId = PB.BatchSeqId AND PBD3.SlNo=BC3.SlNo 
AND BC3.SelRte=1  AND PBD3.DefaultPrice=1 AND (PrdBatLcnSih - PrdBatLcnRessih) > 0 AND PB.PrdId = vFParam 
AND PB.Status=1 AND PBD1.PrdBatDetailValue= vSParam) MainQry'
GO
DELETE FROM HotsearchEditorHD WHERE Formid = 452
INSERT INTO HotsearchEditorHD
SELECT 452,'Return And Replacement','Replacement Product','select',
'SELECT DISTINCT A.PrdId,PrdDcode,PrdCCode,PrdName,PrdShrtName FROM Product A WITH (NOLOCK),ProductBatchLocation B WITH (NOLOCK)
WHERE PrdType<>3 AND A.PrdId = B.PrdId AND (PrdBatLcnSih - PrdBatLcnRessih) > 0'
GO
DELETE FROM HotsearchEditorHD WHERE Formid = 765
INSERT INTO HotsearchEditorHD
SELECT 765,'Return And Replacement','Replacement Display MRP Product','select',
'SELECT DISTINCT PrdId,PrdDcode,prdCcode,PrdName,PrdShrtName,MRP FROM (SELECT DISTINCT A.PrdId,PrdDcode,prdCcode,PrdName,PrdShrtName,PBD.PrdBatDetailValue AS MRP     
FROM Product A WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),
ProductBatchLocation PBL WITH (NOLOCK)       
WHERE A.PrdId = PBL.PrdId AND PB.PrdBatId = PBL.PrdBatId AND PrdType<>3 AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo 
AND BC.MRP=1 AND PBD.BatchSeqId=BC.BatchSeqId      
AND A.PrdId = PB.PrdId)A'
GO
DELETE FROM HotsearchEditorHD WHERE Formid = 808
INSERT INTO HotsearchEditorHD
SELECT 808,'Return And Replacement','Batch Without MRP','select',
'SELECT DISTINCT PrdBatId,PrdBatCode,SellingRate,MRP,PurchaseRate,DefaultPriceId FROM(SELECT DISTINCT PB.PrdBatId,PB.PrdBatCode,PBD1.PrdBatDetailValue AS MRP,
PBD2.PrdBatDetailValue AS PurchaseRate,PBD3.PrdBatDetailValue AS SellingRate,PB.DefaultPriceId  FROM ProductBatch PB WITH (NOLOCK),
ProductBatchDetails PBD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),ProductBatchDetails PBD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),
ProductBatchDetails PBD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK),ProductBatchLocation PBL WITH (NOLOCK) 
WHERE PB.PrdBatId = PBD1.PrdBatId AND BC1.BatchSeqId = PB.BatchSeqId AND PB.PrdBatId = PBL.PrdBatID AND (PrdBatLcnSih - PrdBatLcnRessih) > 0     
AND PBD1.SlNo=BC1.SlNo AND BC1.MRP=1 AND PBD1.DefaultPrice=1 AND PB.PrdBatId = PBD2.PrdBatId  And BC2.BatchSeqId = PB.BatchSeqId AND PBD2.SlNo=BC2.SlNo 
AND BC2.ListPrice=1 AND PBD2.DefaultPrice=1 AND PB.PrdBatId = PBD3.PrdBatId And BC3.BatchSeqId = PB.BatchSeqId AND PBD3.SlNo=BC3.SlNo 
AND BC3.SelRte=1 AND PBD3.DefaultPrice=1 AND PB.PrdId =vFParam AND PB.Status=1) MainQry'
GO
DELETE FROM HotsearchEditorHD WHERE FormId = 818
INSERT INTO HotsearchEditorHD
SELECT 818,'SampleMaintenance','BatchWorSaleable','Select',
'SELECT PrdBatID,PrdBatCode,MRP,PurchaseRate,SellingRate,PriceId FROM (SELECT A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP,
D.PrdBatDetailValue AS PurchaseRate,F.PrdBatDetailValue AS SellingRate,B.PriceId FROM  ProductBatch A (NOLOCK) INNER JOIN ProductBatchDetails B (NOLOCK)    
ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 INNER JOIN BatchCreation C (NOLOCK)ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1  
INNER JOIN ProductBatchDetails D (NOLOCK)ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 INNER JOIN BatchCreation E (NOLOCK)
ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1 INNER JOIN ProductBatchDetails F (NOLOCK) ON A.PrdBatId = F.PrdBatID 
AND F.DefaultPrice=1 INNER JOIN BatchCreation G (NOLOCK) ON G.BatchSeqId = A.BatchSeqId AND F.SlNo = G.SlNo AND G.SelRte = 1 
INNER JOIN ProductBatchLocation PBL ON PBL.PrdBatID=A.PrdBatId WHERE  A.PrdId=vFParam AND A.Status = 1 
AND ((PrdBatLcnSih-PrdBatLcnRessih)+(PrdBatLcnUih-PrdBatLcnResUih)+(PrdBatLcnFre-PrdBatLcnResFre))> 0)MainQry order by PrdBatId ASC'
GO
DELETE FROM HotsearchEditorHD WHERE FormId = 782
INSERT INTO HotsearchEditorHD
SELECT 782,'SampleMaintenance','BatchWor','select',
'SELECT PrdBatID,PrdBatCode,MRP,PurchaseRate,SellingRate,PriceId FROM(SELECT A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP,
D.PrdBatDetailValue AS PurchaseRate,F.PrdBatDetailValue AS SellingRate,B.PriceId FROM ProductBatch A (NOLOCK) 
INNER JOIN ProductBatchDetails B (NOLOCK)ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 INNER JOIN BatchCreation C (NOLOCK)
ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1 INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID 
AND D.DefaultPrice=1 INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1 
INNER JOIN ProductBatchDetails F(NOLOCK) ON A.PrdBatId = F.PrdBatID AND F.DefaultPrice=1 INNER JOIN BatchCreation G (NOLOCK) 
ON G.BatchSeqId = A.BatchSeqId AND F.SlNo = G.SlNo AND G.SelRte = 1 
INNER JOIN ProductBatchLocation PBL ON A.PrdBatId = PBL.PrdBatId WHERE A.PrdId=vFParam AND A.Status = 1 AND
((PrdBatLcnSih-PrdBatLcnRessih)+(PrdBatLcnUih-PrdBatLcnResUih)+(PrdBatLcnFre-PrdBatLcnResFre))> 0)MainQry order by PrdBatId ASC'
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype IN('FN','TF')AND name = 'Fn_UomDetails')
DROP FUNCTION Fn_UomDetails
GO
CREATE FUNCTION Fn_UomDetails()
RETURNS @UomDetails TABLE
(
UomId INT,
UomCode NVARCHAR(50),
ConversionFactor NUMERIC(36,0)
)
AS
BEGIN
/***********************************************************
Funcation Name   : Fn_UomDetails
Added Date       : 2012/07/24
Added By         : Sathishkumar Veeramani
************************************************************/
INSERT INTO @UomDetails (UomId,UomCode,ConversionFactor)
SELECT DISTINCT A.UomId AS UomId,A.UomCode AS UomCode,MAX(B.Conversionfactor) AS Conversionfactor
FROM UomMaster A WITH(NOLOCK),UomGroup B WITH (NOLOCK) WHERE A.UomId = B.UomId GROUP BY A.UomId,A.UomCode ORDER BY UomId

RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype IN('FN','TF')AND name = 'Fn_ReturnSlabSchemeDetails')
DROP FUNCTION Fn_ReturnSlabSchemeDetails
GO
CREATE FUNCTION Fn_ReturnSlabSchemeDetails(@Pi_SchType INT,@Pi_SchId INT)
RETURNS @ReturnSlabDetailes TABLE
(
SlabId INT,
PurQty NUMERIC(36,0),
FROMQty NUMERIC(36,0),
PurUomId INT,
PurUom NVARCHAR(50),
FrmConFact NUMERIC(36,0),
ToQty NUMERIC(36,0),
PurToUomId INT,
PurToUom NVARCHAR(50),
ToConFact NUMERIC(36,0),
ForEveryQty NUMERIC(36,0),
PurofUomId INT,
PurofUom NVARCHAR(50),
PurofConFact NUMERIC(36,0),
DiscPer NUMERIC(36,4),
FlatAmt NUMERIC(36,4),
FlxDisc TINYINT,
FlxValueDisc TINYINT,
FlxFreePrd TINYINT,
FlxGiftPrd TINYINT,
FlxPoints TINYINT,
Points NUMERIC(36,4)
)
AS
BEGIN
/***********************************************************
Funcation Name   : Fn_ReturnSlabSchemeDetails
Added Date       : 2012/07/24
Added By         : Sathishkumar Veeramani
************************************************************/
IF @Pi_SchType = 3 ---Weight based scheme type
BEGIN
        INSERT INTO @ReturnSlabDetailes (SlabId,PurQty,FROMQty,PurUomId,PurUom,ToQty,PurToUomId,PurToUom,ForEveryQty,PurofUomId,PurofUom,
        DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,Points)
        SELECT DISTINCT SlabId,PurQty,FROMQty,SS.UomId AS PurUomId,Fp.PrdUnitCode AS PurUom,ToQty,ToUomId AS PurToUomId,Tp.PrdUnitCode AS PurToUom,
        ForEveryQty,ForEveryUomId AS PurofUomId,Ep.PrdUnitCode AS PurofUom,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,Points 
        FROM SchemeSlabs SS WITH (NOLOCK),Productunit FP  WITH (NOLOCK),Productunit TP  WITH (NOLOCK),Productunit EP  WITH (NOLOCK)
        WHERE TP.Prdunitid = SS.Uomid AND EP.Prdunitid = SS.Uomid AND FP.prdunitid = SS.Uomid AND 
        SS.SchId = @Pi_SchId ORDER BY Slabid    
END
IF @Pi_SchType = 1 --Quantity based scheme type
BEGIN
		INSERT INTO @ReturnSlabDetailes
		SELECT DISTINCT SlabId,PurQty,FROMQty,PurUomId,PurUom,FrmConFact,ToQty,
		ToUomId AS PurToUomId,PurToUom,ToConFact,ForEveryQty,ForEveryUomId AS PurofUomId,
		PurofUom,PurofConFact,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,Points
		FROM SchemeSlabs Z WITH(Nolock)INNER JOIN
		(SELECT UOMId AS PurUomId,UomCode AS PurUom,MAX(ConversionFactor) AS FrmConFact FROM Fn_UomDetails()GROUP BY UOMId,UomCode)A 
		ON Z.UomId = A.PurUomId INNER JOIN
		(SELECT UOMId,UomCode AS PurToUom,MAX(ConversionFactor) AS ToConFact FROM Fn_UomDetails()GROUP BY UOMId,UomCode)B
		ON Z.UomId = B.UOMId INNER JOIN
		(SELECT UOMId,UomCode AS PurofUom,MAX(ConversionFactor) AS PurofConFact FROM Fn_UomDetails()GROUP BY UOMId,UomCode)C
		ON Z.UomId = C.UOMId WHERE Z.SchId = @Pi_SchId ORDER BY SlabId
END      
ELSE IF @Pi_SchType <> 1 AND @Pi_SchType <> 3        
BEGIN
       INSERT INTO @ReturnSlabDetailes (SlabId,PurQty,FROMQty,PurUomId,PurUom,ToQty,PurToUomId,PurToUom,ForEveryQty,PurofUomId,PurofUom,
       DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,Points)
       SELECT DISTINCT SlabId,PurQty,FROMQty,UomId AS PurUomId,'' AS PurUom,ToQty,ToUomId AS PurToUomId,'' AS PurToUom,
       ForEveryQty,forEveryUomId AS PurofUomId,'' AS PurofUom,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd, 
       FlxPoints,Points FROM SchemeSlabs SS WITH (NOLOCK) WHERE SS.SchId = @Pi_SchId ORDER BY Slabid
END
RETURN
END
GO
DELETE FROM HotSearchEditorDt WHERE FormId = 196
INSERT INTO HotsearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,196,'Batch No','Batch No','PrdbatCode',1500,0,'HotSch-23-2000-4',23)
INSERT INTO HotsearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,196,'Batch No','MRP','MRP',1000,0,'HotSch-23-2000-4',23)
INSERT INTO HotsearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (3,196,'Batch No','Selling Rate','SellRate',1000,0,'HotSch-23-2000-4',23)
INSERT INTO HotsearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (4,196,'Batch No','Purchase Rate','PurchaseRate',1000,0,'HotSch-23-2000-4',23)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE IN ('FN','TF') AND name = 'Fn_ReturnPrdBatchDetailsWithStock')
DROP FUNCTION Fn_ReturnPrdBatchDetailsWithStock
GO
-- SELECT * FROM DBO.Fn_ReturnPrdBatchDetailsWithStock(3334,1,2)
CREATE FUNCTION Fn_ReturnPrdBatchDetailsWithStock (@PrdId AS BIGINT,@LcnId	AS	INT,@OrderMode AS INT)
RETURNS @PrdBatchDetailsWithStock TABLE
	(
		PrdId		INT,
		PrdName		Varchar(150),
		PrdCCode	Varchar(50),
		PrdDCode	Varchar(50),
		PrdBatID	INT,
		BatchCode	Varchar(100),
		MRP			NUMERIC(18,6),
		LSP			NUMERIC(18,6),
		SellRate	NUMERIC(18,6),
		StockAvail	NUMERIC(18,0),
		PriceId		INT
	)
AS
BEGIN
/*********************************
* FUNCTION: Fn_ReturnPrdBatchDetailsWithStock
* PURPOSE: Returns the Product details with stock
* NOTES:
* CREATED: Boopathy.P
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
--DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),DATEADD(Day,PrdShelfLife,A.MnfDate)) as ShelfDay, DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),A.ExpDate) as ExpiryDay,
	IF @OrderMode=1
	BEGIN
		INSERT INTO @PrdBatchDetailsWithStock
		SELECT @PrdId,G.PrdName,G.PrdCCode,G.PrdDCode,A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS PurchaseRate,K.PrdBatDetailValue AS SellRate,
		(F.PrdBatLcnSih - F.PrdBatLcnRessih) as StockAvail, B.PriceId FROM ProductBatch A (NOLOCK) 
		INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 
		INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1 
		INNER JOIN ProductBatchDetails K (NOLOCK) ON A.PrdBatId = K.PrdBatID AND K.DefaultPrice=1 
		INNER JOIN BatchCreation H (NOLOCK) ON H.BatchSeqId = A.BatchSeqId AND K.SlNo = H.SlNo AND H.SelRte = 1 
		INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId 
		INNER JOIN ProductBatchLocation F (NOLOCK) ON F.PrdBatId = A.PrdBatId WHERE A.Status = 1 
		AND A.PrdId=@PrdId AND F.LcnId = @LcnId And (F.PrdBatLcnSih - F.PrdBatLcnRessih) > 0 
		AND B.PrdBatDetailValue >= D.PrdBatDetailValue ORDER BY A.PrdBatId Asc
	END
	ELSE
	BEGIN
		INSERT INTO @PrdBatchDetailsWithStock
		SELECT @PrdId,G.PrdName,G.PrdCCode,G.PrdDCode,A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS PurchaseRate,K.PrdBatDetailValue AS SellRate,
		(F.PrdBatLcnSih - F.PrdBatLcnRessih) as StockAvail, B.PriceId FROM ProductBatch A (NOLOCK) 
		INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 
		INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1 
		INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1 
		INNER JOIN ProductBatchDetails K (NOLOCK) ON A.PrdBatId = K.PrdBatID AND K.DefaultPrice=1 
		INNER JOIN BatchCreation H (NOLOCK) ON H.BatchSeqId = A.BatchSeqId AND K.SlNo = H.SlNo AND H.SelRte = 1 
		INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId 
		INNER JOIN ProductBatchLocation F (NOLOCK) ON F.PrdBatId = A.PrdBatId WHERE A.Status = 1 
		AND A.PrdId=@PrdId AND F.LcnId = @LcnId And (F.PrdBatLcnSih - F.PrdBatLcnRessih) > 0 
		AND B.PrdBatDetailValue >= D.PrdBatDetailValue ORDER BY A.PrdBatId DESC
	END
RETURN
END
GO
DELETE FROM HotSearcheditorHd WHERE FormId = 540
INSERT INTO HotSearcheditorHd (FormId,FormName,ControlName,SltString,RemainsltString) 
SELECT 540,'Billing','OrderNo','select',
'SELECT OrderNo,OrderDate,RtrName,RtrShipId,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipPinNo,RtrShipPhoneNo,PDADownloadFlag  
FROM (SELECT A.OrderNo,A.OrderDate,B.RtrName,A.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,RS.RtrShipPinNo,RS.RtrShipPhoneNo,A.PDADownloadFlag  
FROM OrderBooking A INNER JOIN Retailer B ON A.RtrId=B.RtrId INNER JOIN RetailerShipAdd RS ON RS.RtrShipId = A.RtrShipId     
AND A.Rtrid = vTParam and A.SMId = vFParam AND A.RMId = vSParam  AND Status =0 AND OrderNo IN 
(SELECT DISTINCT B.OrderNo FROM OrderBookingProducts B)) A'
GO
DELETE FROM HotSearcheditorHd WHERE FormId = 541
INSERT INTO HotSearcheditorHd (FormId,FormName,ControlName,SltString,RemainsltString)  
SELECT 541,'Billing','OrderBill','select',
'SELECT OrderNo,OrderDate,RtrName,RtrId,RMId,RMName,SMId,SMName,SMMktCredit,SMCreditDays,SMCreditAmountAlert,SMCreditDaysAlert,RtrShipId,RtrShipAdd1,
RtrShipAdd2,RtrShipAdd3,RtrShipPinNo,RtrShipPhoneNo,DocRefNo,PDADownloadFlag FROM (SELECT A.OrderNo,A.OrderDate,B.RtrName,A.RtrId,A.RMId,C.RMName,A.SMId,D.SMName,
SMMktCredit,SMCreditDays,SMCreditAmountAlert,SMCreditDaysAlert,A.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,RS.RtrShipPinNo,
RS.RtrShipPhoneNo,A.DocRefNo,A.PDADownloadFlag FROM OrderBooking A INNER JOIN Retailer B ON A.RtrId = B.Rtrid  INNER JOIN RouteMaster C ON A.RMId = C.RMId 
INNER JOIN Salesman D ON A.SMId = D.SMId  INNER JOIN RetailerShipAdd RS ON RS.RtrShipId = A.RtrShipId WHERE A.Status =0 
AND A.OrderNo IN (SELECT DISTINCT OrderNo FROM OrderBookingProducts)) A'
GO
DELETE FROM CustomCaptions WHERE TransId = 2 AND CtrlId = 2000 AND SubCtrlId = 187
INSERT INTO CustomCaptions 
SELECT 2,'2000',187,'HotSch-2-2000-187','Retailer Name','','',1,1,1,GETDATE(),1,GETDATE(),'Retailer Name','','',1,1
GO
DELETE FROM HotSearcheditorDt WHERE FormId = 540
INSERT INTO HotSearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,540,'OrderNo','Order No','OrderNo',1500,0,'HotSch-2-2000-19',2)
INSERT INTO HotSearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,540,'OrderNo','Order Date','OrderDate',1500,0,'HotSch-2-2000-40',2)
INSERT INTO HotSearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (3,540,'OrderNo','Retailer Name','RtrName',2500,0,'HotSch-2-2000-187',2)
GO
DELETE FROM HotSearcheditorDt WHERE FormId = 541
INSERT INTO HotSearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (1,541,'OrderBill','Order No','OrderNo',1500,0,'HotSch-2-2000-19',2)
INSERT INTO HotSearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (2,541,'OrderBill','Order Date','OrderDate',1500,0,'HotSch-2-2000-40',2)
INSERT INTO HotSearcheditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) 
VALUES (3,541,'OrderBill','Retailer Name','RtrName',2500,0,'HotSch-2-2000-187',2)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE IN ('FN','TF') AND name = 'Fn_ReturnOrderDetailStock')
DROP FUNCTION Fn_ReturnOrderDetailStock
GO
-- SELECT * FROM DBO.Fn_ReturnOrderDetailStock('ORD1100001')
CREATE FUNCTION Fn_ReturnOrderDetailStock(@OrderNo AS VARCHAR(200))
RETURNS @PrdBatchDetailsWithStock TABLE
	(
		PrdId		INT,
		PrdName		Varchar(150),
		PrdDCode	Varchar(50),
		TotalQty	NUMERIC(18,0),
		LcnId		INT,
		PrdBatLcnSih NUMERIC(18,0)
	)
AS
BEGIN
/*********************************
* FUNCTION: Fn_ReturnOrderDetailStock
* PURPOSE: Returns the Order Bookong Product details with stock
* NOTES:
* CREATED: Boopathy.P
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	INSERT INTO @PrdBatchDetailsWithStock 
	SELECT OBP.PrdId,P.PrdName,P.PrdDcode,OBP.TotalQty,ISNULL(PBL.LcnId,0) AS LcnId,ISNULL(SUM(PBL.PrdBatLcnSih-PBL.PrdBatLcnResSih),0) AS PrdBatLcnSih 
	FROM Product P  WITH (NOLOCK),OrderBookingProducts OBP WITH (NOLOCK)LEFT OUTER JOIN ProductBatchLocation PBL WITH (NOLOCK) ON OBP.PrdId=PBL.PrdId 
	WHERE P.PrdId=OBP.PrdId AND OBP.OrderNo=@OrderNo GROUP BY OBP.PrdId,P.PrdDcode,P.PrdName,OBP.TotalQty,PBL.LcnId
	RETURN
END
GO
DELETE FROM Configuration WHERE ModuleId = 'GENCONFIG30'
INSERT INTO Configuration
SELECT 'GENCONFIG30','General Configuration','Retailer Phone Number As Mandatory',0,'',0.00,30
GO
DELETE FROM CustomCaptions WHERE TransId = 79 AND CtrlId = 1000 AND SubCtrlId IN (10,11,12,13)
INSERT INTO CustomCaptions
SELECT 79,1000,10,'MsgBox-79-1000-10','','','Phone Number Should be in 8 Digits to 10 Digits',1,1,1,GETDATE(),1,GETDATE(),'','',
'Phone Number Should be in 10 Digits',1,1 UNION ALL
SELECT 79,1000,11,'MsgBox-79-1000-11','','','TIN Number Should be in 8 Digits to 11 Digits',1,1,1,GETDATE(),1,GETDATE(),'','',
'TIN Number Should be in 10 Digits OR More than 10 Digits',1,1 UNION ALL
SELECT 79,1000,12,'MsgBox-79-1000-12','','','Phone Number Should Not Start With 0',1,1,1,GETDATE(),1,GETDATE(),'','',
'Phone Number Should Not Start With 0',1,1 UNION ALL
SELECT 79,1000,13,'MsgBox-79-1000-13','','','TIN Number Should Not Start With 0',1,1,1,GETDATE(),1,GETDATE(),'','',
'TIN Number Should Not Start With 0',1,1
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE xtype='U' and name='TempSupplierAccountStatement')
DROP TABLE TempSupplierAccountStatement
GO
CREATE TABLE TempSupplierAccountStatement
(
	[SlNo] [int] NULL,
	[SpmId] [int] NULL,
	[CoaId] [int] NULL,
	[SpmName] [nvarchar](100) NULL,
	[SpmAddress] [nvarchar](600) NULL,
	[TINNo] [nvarchar](50) NULL,
	[RcpDate] [datetime] NULL,
	[DocumentNo] [nvarchar](100) NULL,
	[Details] [nvarchar](400) NULL,
	[RefNo] [nvarchar](100) NULL,
	[DbAmount] [numeric](38, 6) NULL,
	[CrAmount] [numeric](38, 6) NULL,
	[BalanceAmount] [numeric](38, 6) NULL
)
GO
DELETE FROM RptGroup WHERE RptId=247
INSERT INTO RptGroup
SELECT 'ParleReports','247','SupplierAccountStatement','Supplier Accounts Statement'
GO
DELETE FROM RptHeader WHERE RptId=247
INSERT INTO RptHeader
SELECT 'SupplierAccountStatement','Supplier Accounts Statement','247','Supplier Accounts Statement','Proc_RptSupplierAccountStatement','RptSupplierAccountStatement','RptSupplierAccountStatement.rpt',''	
GO
DELETE FROM RptDetails WHERE RptId=247
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (247,1,'FromDate',-1,'','','From Date*','',1,'',10,1,1,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (247,2,'ToDate',-1,'','','To Date*','',1,'',11,1,1,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (247,3,'Supplier',-1,'','SpmId,SpmCode,SpmName','Supplier*...','',1,'',9,1,1,'Press F4/Double Click to Select Supplier',0)
GO
DELETE FROM RptFormula WHERE RptId=247
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,1,'SlNo','SlNo',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,2,'RcpDate','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,3,'DocumentNo','Document No',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,4,'Particulars','Particulars',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,5,'ReferenceNo','Reference No',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,6,'DebitAmt','Debit Amt',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,7,'CreditAmt','Credit Amt',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,8,'BalanceAmt','Balance Amt',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,9,'SupplierName','Sup Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,10,'SupplierAddress','Sup Address',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,11,'TINNo','TINNo',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,12,'Period','Period',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,13,'Dis_FromDate','FromDate',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,14,'Dis_ToDate','ToDate',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,15,'Cap_UserName','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,16,'Cap_PrintDate','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,17,'Cap_To','to',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,18,'SupplierCode','Supplier Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (247,19,'PhoneNo','Ph-',1,0)
GO
DELETE FROM RptExcelHeaders WHERE RptId=247
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (247,1,'SlNo','SlNo',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (247,2,'SpmId','SpmId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (247,3,'CoaId','CoaId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (247,4,'SpmName','Sup Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (247,5,'SpmAddress','Sup Address',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (247,6,'TINNo','Sup TIN No',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (247,7,'RcpDate','Date',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (247,8,'DocumentNo','Document No',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (247,9,'Details','Particulars',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (247,10,'RefNo','Reference No',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (247,11,'DbAmount','Debit Amt',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (247,12,'CrAmount','Credit Amt',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (247,13,'BalanceAmount','Balance Amt',1,1)
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptSupplierAccountStatement')
DROP PROCEDURE Proc_RptSupplierAccountStatement
GO
--exec Proc_RptSupplierAccountStatement 247,1,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptSupplierAccountStatement
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
BEGIN
SET NOCOUNT ON
/****************************************************************************
* PROCEDURE: Proc_RptSupplierAccountStatement
* PURPOSE: Supplier Account Statement - Report
* NOTES:
* CREATED: Aravindh Deva C 
* DATE: 08.03.2013
* MODIFIED
* DATE		AUTHOR			DESCRIPTION
------------------------------------------------------------------------------

*****************************************************************************/
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate		AS	DATETIME
	DECLARE @SpmId		AS	INT
	DECLARE @ErrNo	 	AS	INT
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SpmId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId))
	
	CREATE TABLE #SupplierAccountStatement
	(
		[SlNo] [int] identity,
		[SpmId] [int] NULL,
		[CoaId] [int] NULL,
		[SpmName] [nvarchar](100) NULL,
		[SpmAddress] [nvarchar](600) NULL,
		[TINNo] [nvarchar](50) NULL,
		[RcpDate] [datetime] NULL,
		[DocumentNo] [nvarchar](100) NULL,
		[Details] [nvarchar](400) NULL,
		[RefNo] [nvarchar](100) NULL,
		[DbAmount] [numeric](38, 6) NULL,
		[CrAmount] [numeric](38, 6) NULL,
		[BalanceAmount] [numeric](38, 6) NULL
	)	
		
	TRUNCATE TABLE TempSupplierAccountStatement
	--	
	INSERT INTO TempSupplierAccountStatement (SlNo,SpmId,CoaId,SpmName,SpmAddress,TINNo,RcpDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)	
	SELECT  2,PR.SpmId,S.CoaId,S.SpmName,S.SpmAdd1+'   '+S.SpmAdd2+'   '+S.SpmAdd3,S.SpmTinNo,
				PR.InvDate,PR.CmpInvNo,'Purchase','',PR.NetAmount,0,0
			FROM PurchaseReceipt PR (NOLOCK)
				INNER JOIN Supplier S (NOLOCK) ON PR.SpmId=S.SpmId
			WHERE PR.InvDate <=@ToDate  AND PR.SpmId=CASE @SpmId WHEN 0 THEN PR.SpmId ELSE @SpmId END
	UNION ALL
	SELECT  2,PR.SpmId,S.CoaId,S.SpmName,S.SpmAdd1+'   '+S.SpmAdd2+'   '+S.SpmAdd3,S.SpmTinNo,
				PP.PaymentDate,PP.PayAdvNo,'Payment',PR.CmpInvNo,
				0,PG.PayAmount,0
			FROM PurchasePayment PP (NOLOCK)
				INNER JOIN PurchasePaymentGRN PG (NOLOCK) ON PP.PayAdvNo=PG.PayAdvNo
				INNER JOIN PurchaseReceipt PR (NOLOCK) ON PG.PurRcptId=PR.PurRcptId
				INNER JOIN Supplier S (NOLOCK) ON PR.SpmId=S.SpmId
			WHERE PP.PaymentDate <=@ToDate  AND PR.SpmId=CASE @SpmId WHEN 0 THEN PR.SpmId ELSE @SpmId END
	--		
	IF NOT EXISTS (SELECT RcpDate FROM TempSupplierAccountStatement WHERE RcpDate<@FromDate)
	BEGIN
		INSERT INTO TempSupplierAccountStatement
		SELECT DISTINCT 1,SpmId,CoaId,SpmName,SpmAddress,TINNo,@FromDate RcpDate,'' DocumentNo,'Opening Balance' Details,'' RefNo,0 DbAmount,0 CrAmount,0 BalanceAmount
		FROM TempSupplierAccountStatement		
	END

	INSERT INTO TempSupplierAccountStatement
	SELECT 1,SpmId,CoaId,SpmName,SpmAddress,TINNo,@FromDate RcpDate,'' DocumentNo,'Opening Balance' Details,'' RefNo,0 DbAmount,0 CrAmount,ISNULL(SUM(DbAmount)-SUM(CrAmount),0) BalanceAmount
	FROM TempSupplierAccountStatement
	WHERE RcpDate<@FromDate
	GROUP BY SpmId,CoaId,SpmName,SpmAddress,TINNo
	UNION ALL
	SELECT DISTINCT 3,SpmId,CoaId,SpmName,SpmAddress,TINNo,@ToDate RcpDate,'' DocumentNo,'Closing Balance' Details,'' RefNo,0 DbAmount,0 CrAmount,0 BalanceAmount
	FROM TempSupplierAccountStatement		
	----------
	DELETE FROM TempSupplierAccountStatement WHERE RcpDate NOT BETWEEN @FromDate AND @ToDate
		
	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId 
	FROM TempSupplierAccountStatement 
		/* Excel report */

			SELECT * INTO #RptSupplierAccStmtsExcel FROM  TempSupplierAccountStatement  
			
			DECLARE @LineBalAmt   Numeric(18,2)
			DECLARE @SlNo		  INT
			DECLARE @Amt		  Numeric(18,2)
			DECLARE @Details      nVarchar(100)		
			DECLARE @DocDetails   nVarchar(100)	

			DECLARE Balance_Cursor CURSOR
			FOR  	SELECT Slno,Details,
			CASE Slno WHEN 1 THEN BalanceAmount
			ELSE (DbAmount-CrAmount) END BalanceAmount,DocumentNo 
			FROM #RptSupplierAccStmtsExcel ORDER BY Slno,RcpDate			  
			OPEN Balance_Cursor		
		
			FETCH NEXT FROM Balance_Cursor INTO  @SlNo,@Details,@Amt,@DocDetails
			SET @LineBalAmt = 0
			WHILE @@FETCH_STATUS = 0
			BEGIN	 		
					 SET @LineBalAmt = @LineBalAmt + @Amt
					 Update #RptSupplierAccStmtsExcel SET BalanceAmount = Round(@LineBalAmt,3)
					 WHere SlNo = @SlNo	and Details = @Details and DocumentNo = @DocDetails
			FETCH NEXT FROM Balance_Cursor INTO   @SlNo,@Details,@Amt,@DocDetails
			END
			CLOSE Balance_Cursor
			DEALLOCATE Balance_Cursor 
		 
	INSERT INTO #SupplierAccountStatement
	SELECT SpmId,CoaId,SpmName,SpmAddress,TINNo,RcpDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount 
	FROM #RptSupplierAccStmtsExcel ORDER BY SlNo,RcpDate
	
	SELECT * FROM #SupplierAccountStatement ORDER BY SlNo,RcpDate
	
	RETURN			
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype in('TF','FN') And Name = 'Fn_FillBatchBasedOnExpdate')
DROP FUNCTION Fn_FillBatchBasedOnExpdate
GO
CREATE FUNCTION Fn_FillBatchBasedOnExpdate (@Pi_LcnId INT,@Pi_Prdid INT,@Pi_Date DATETIME)
RETURNS @FillBatchBasedOnExpdate TABLE
(
	PrdBatID     INT,
    PrdBatCode   NVARCHAR(50),
    MRP          NUMERIC (18,6),	
	PurchaseRate NUMERIC (18,6),
    SellRate     NUMERIC (18,6),
    StockAvail   INT,
    ShelfDay     VARCHAR (50),
    ExpiryDay    VARCHAR (50),
    PriceId      INT
)
AS
BEGIN
INSERT INTO @FillBatchBasedOnExpdate (PrdBatID,PrdBatCode,MRP,PurchaseRate,SellRate,StockAvail,ShelfDay,ExpiryDay,PriceId)
SELECT TOP 1 A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS PurchaseRate,K.PrdBatDetailValue AS SellRate,(F.PrdBatLcnSih - F.PrdBatLcnRessih) as StockAvail, 
A.MnfDate as ShelfDay,A.ExpDate as ExpiryDay,B.PriceId FROM ProductBatch A (NOLOCK) 
INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 
INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1 
INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 
INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1 
INNER JOIN ProductBatchDetails K (NOLOCK) ON A.PrdBatId = K.PrdBatID AND K.DefaultPrice=1 
INNER JOIN BatchCreation H (NOLOCK) ON H.BatchSeqId = A.BatchSeqId AND K.SlNo = H.SlNo AND H.SelRte = 1 
INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId 
INNER JOIN ProductBatchLocation F (NOLOCK) ON F.PrdBatId = A.PrdBatId 
WHERE A.Status = 1 AND A.PrdId = @Pi_Prdid AND F.LcnId = @Pi_LcnId And (F.PrdBatLcnSih - F.PrdBatLcnRessih) > 0 And A.ExpDate > = @Pi_Date
ORDER BY ExpiryDay Asc
RETURN
END
GO
DELETE FROM RptGroup WHERE RptId=249
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName)
SELECT 'ParleReports',249,'VatComputationReport','Vat Computation Report'
GO
DELETE FROM RptHeader WHERE rptcaption='Vat Computation Report' AND RptId=249
INSERT INTO RptHeader (GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'ParleReports','Vat Computation Report',249,'Vat Computation Report','Proc_RptVatComputation','RptVatComputation','RptVatComputation.rpt',''
GO
DELETE FROM RptFilter WHERE RptId=249
INSERT INTO RptFilter (RptId,SelcId,FilterId,FilterDesc) SELECT 249,278,0,'Sales'
INSERT INTO RptFilter (RptId,SelcId,FilterId,FilterDesc) SELECT 249,278,1,'Purchase'
GO
DELETE FROM RptDetails WHERE RptId=249
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (249,1,'FromDate',-1,'','','From Date*','',1,'',10,0,1,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (249,2,'ToDate',-1,'','','To Date*','',1,'',11,0,1,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (249,3,'ACMaster',-1,'','AcmId,AcmType,AcmYr','F A.','',1,'',149,1,1,'Press F4/Double Click to select Account Year',0)
GO
DELETE FROM RptFormula WHERE RptId=249             
INSERT INTO RptFormula SELECT 249,1,'Display_WsName','Wholesaler Name',1,0
INSERT INTO RptFormula SELECT 249,2,'Display_WsName1',DistributorName,1,0 FROM Distributor    
INSERT INTO RptFormula SELECT 249,3,'Display_WSAdd','Wholesaler Address',1,0
INSERT INTO RptFormula SELECT 249,4,'Display_WsCity','Wholesaler City',1,0
INSERT INTO RptFormula SELECT 249,5,'Display_Period','Period',1,0
INSERT INTO RptFormula SELECT 249,6,'Display_From','From',1,0
INSERT INTO RptFormula SELECT 249,7,'Display_To','To',1,0
INSERT INTO RptFormula SELECT 249,8,'From Date','From Date',1,10
INSERT INTO RptFormula SELECT 249,9,'To Date','To Date',1,11
INSERT INTO RptFormula SELECT 249,10,'Display_Tin','TIN No',1,0
INSERT INTO RptFormula SELECT 249,11,'Display_AY','Assessment Year',1,0
INSERT INTO RptFormula SELECT 249,12,'Display_Det','Details',1,0
INSERT INTO RptFormula SELECT 249,13,'Display_Sal','Sale/Purc.Amt.',1,0
INSERT INTO RptFormula SELECT 249,14,'Display_Tax','Tax',1,0
INSERT INTO RptFormula SELECT 249,15,'Display_Ret','Sale/Pur.Ret.Amount',1,0
INSERT INTO RptFormula SELECT 249,16,'Display_NetAmt','Nett Amt.',1,0
INSERT INTO RptFormula SELECT 249,17,'Display_NetTax','Nett Tax',1,0
INSERT INTO RptFormula SELECT 249,18,'Display_UName','User Name',1,0
INSERT INTO RptFormula SELECT 249,19,'Display_PDate','Print Date',1,0
GO
DELETE FROM RptExcelHeaders WHERE RptId=249
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (249,1,'[Details]','Details',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (249,2,'[Sale/Purc.Amt.]','Sale/Purc.Amt.',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (249,3,'[Tax1]','Tax',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (249,4,'[sale/Pur.Ret.Amount]','Sale/Pur.Ret.Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (249,5,'[Tax2]','Tax',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (249,6,'[NettAmt.]','NettAmt.',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (249,7,'[NettTax]','NettTax',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (249,8,'[DistName]','DistName',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (249,9,'[DistAddress]','DistAddress',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (249,10,'[DistTIN]','DistTIN',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (249,11,'[DistCity]','DistCity',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (249,12,'[AY]','AY',0,1)
GO
IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE TYPE='P' AND name='Proc_RptVatComputation')
DROP PROCEDURE Proc_RptVatComputation
GO
--Exec Proc_RptVatComputation 249,1,0,'Proc_RptVatComputation',0,0,1 
CREATE PROCEDURE Proc_RptVatComputation
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE		: Proc_RptVatComputation
* PURPOSE		: To get the VAT summary details
* CREATED		: Alphonse J
* CREATED DATE	: 08/03/2013
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
------------------------------------------------
* {date}      {developer}          {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON

	DECLARE @FromDate		AS DATETIME	
	DECLARE @ToDate			AS DATETIME	
	DECLARE @FDate			AS DATETIME	
	DECLARE @TDate			AS DATETIME
	DECLARE @InvoiceType	AS INT 	
	DECLARE @AY				AS INT
		
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @InvoiceType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,278,@Pi_UsrId))
	SET @AY=(SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,149,@Pi_UsrId))
	
	--VAT Opening Balance	
	DECLARE @VATOpening		AS NUMERIC (36,2)
	SELECT @FDate=AcmSdt FROM ACPeriod WHERE AcmId IN (SELECT AcmId FROM ACMaster WHERE AcmYr= @AY) AND AcpId IN (SELECT MIN(AcpId) FROM ACPeriod WHERE AcmId IN (SELECT AcmId FROM ACMaster WHERE AcmYr= @AY))
	SET @TDate =DATEADD(DD,-1,@FromDate)
	
	SELECT	CASE B.DebitCredit WHEN 1 THEN B.Amount ELSE 0 END AS Debit,
			CASE B.DebitCredit WHEN 2 THEN B.Amount ELSE 0 END AS Credit INTO #Balance from StdVocMaster A INNER JOIN StdVocDetails B ON A.VocRefNo=B.VocRefNo
	WHERE B.CoaId IN (SELECT InputTaxId FROM TaxConfiguration UNION ALL SELECT OutPutTaxId FROM TaxConfiguration)
	AND A.VocDate BETWEEN @FDate AND @TDate
	
	SELECT @VATOpening=ISNULL((SUM(Debit)-SUM(Credit)),0.0)FROM #Balance 

	SELECT @VATOpening=@VATOpening+ISNULL((SUM(OpeningDebit)-SUM(OpeningCredit)),0.0) from COAOpeningBalance WHERE CoaId IN (SELECT InputTaxId FROM TaxConfiguration UNION ALL SELECT OutPutTaxId FROM TaxConfiguration)

	SET @AY=@AY+1
	
	CREATE TABLE #VATSummaryOUTPUT
	(
		[Details]					NVARCHAR(250),
		[Sale/Purc.Amt.]			NVARCHAR(250),
		[Tax1]						NVARCHAR(250),
		[sale/Pur.Ret.Amount]		NVARCHAR(250),
		[Tax2]						NVARCHAR(250),
		[NettAmt.]					NVARCHAR(250),
		[NettTax]					NVARCHAR(250),
		[DistName]					NVARCHAR(250),
		[DistAddress]				NVARCHAR(2000),
		[DistTIN]					NVARCHAR(250),
		[DistCity]					NVARCHAR(1000),
		[AY]						NVARCHAR(250),
	)
	
	CREATE TABLE #InputVAT 
	(
		[Details]					NVARCHAR(250),
		[Sale/Purc.Amt.]			NUMERIC(36,2),
		[Tax1]						NUMERIC(36,2),
		[Sale/Pur.Ret.Amount]		NUMERIC(36,2),
		[Tax2]						NUMERIC(36,2),
		[NettAmt.]					NUMERIC(36,2),
		[NettTax]					NUMERIC(36,2),
		[TaxId]						INT,
		[TaxPerc]					NUMERIC(36,2)
	)
	
	CREATE TABLE #OutputVAT 
	(
		[Details]					NVARCHAR(250),
		[Sale/Purc.Amt.]			NUMERIC(36,2),
		[Tax1]						NUMERIC(36,2),
		[Sale/Pur.Ret.Amount]		NUMERIC(36,2),
		[Tax2]						NUMERIC(36,2),
		[NettAmt.]					NUMERIC(36,2),
		[NettTax]					NUMERIC(36,2),
		[TaxId]						INT,
		[TaxPerc]					NUMERIC(36,2)
	)
	
	CREATE TABLE #CST 
	(
		[Details]					NVARCHAR(250),
		[Sale/Purc.Amt.]			NUMERIC(36,2),
		[Tax1]						NUMERIC(36,2),
		[Sale/Pur.Ret.Amount]		NUMERIC(36,2),
		[Tax2]						NUMERIC(36,2),
		[NettAmt.]					NUMERIC(36,2),
		[NettTax]					NUMERIC(36,2)
	)
	
	--InputVAT 
	
	SELECT A.TaxId,A.TaxName,B.TaxPerc INTO #InputTaxPerc FROM TaxConfiguration A INNER JOIN (SELECT DISTINCT rowid,CAST(ColVal AS NUMERIC(18,1)) TaxPerc  
	FROM TaxSettingDetail WHERE ColId=0 AND TaxSeqId IN (SELECT TaxSeqId FROM TaxSettingMaster WHERE RtrId in 
	(SELECT TaxGroupId FROM Supplier))) B ON B.RowId=A.TaxId 
	
	INSERT INTO #InputVAT ([Details],[Sale/Purc.Amt.],[Tax1],[sale/Pur.Ret.Amount],[Tax2],[NettAmt.],[NettTax])
	SELECT 'VAT Opening Balance',0,0,0,0,0,@VATOpening
	INSERT INTO #InputVAT ([Details],[Sale/Purc.Amt.],[Tax1],[sale/Pur.Ret.Amount],[Tax2],[NettAmt.],[NettTax],TaxId)
	SELECT 'Input VAT (Purchases) - Local Registered',0,0,0,0,0,0,99999
	UNION ALL
	SELECT 'Input VAT on Purchase of Unregistered Goods',0,0,0,0,0,0,99999
	UNION ALL
	SELECT 'Input VAT on Purchase of Exempted Goods',0,0,0,0,0,0,99999
	UNION ALL
	SELECT 'Input VAT on Purchase from Other State',0,0,0,0,0,0,99999
	UNION ALL
	SELECT 'Input VAT on Purchase in Principal''s A/c',0,0,0,0,0,0,99999
	UNION ALL
	SELECT 'Input VAT on Any other purchase',0,0,0,0,0,0,99999
	UNION ALL
	SELECT '',0,0,0,0,0,0,99999
	
	INSERT INTO #InputVAT ([Details],[Sale/Purc.Amt.],[Tax1],[sale/Pur.Ret.Amount],[Tax2],[NettAmt.],[NettTax],[TaxId],[TaxPerc])
	SELECT '  Total '+TaxName+' -'+CAST(TaxPerc AS NVARCHAR(20))+'%',0,0,0,0,0,0,TaxId,TaxPerc FROM #InputTaxPerc
	
	INSERT INTO #InputVAT ([Details],[Sale/Purc.Amt.],[Tax1],[sale/Pur.Ret.Amount],[Tax2],[NettAmt.],[NettTax])
	SELECT '  Total',0,0,0,0,0,0  
	UNION ALL
	SELECT 'Total Input VAT =',0,0,0,0,0,0  
	
		
	UPDATE A SET A.[Sale/Purc.Amt.]=B.NetAmount,A.[Tax1]=B.TaxAmount,A.[Sale/Pur.Ret.Amount]=C.NetAmount,A.Tax2=C.TaxAmount,
	A.[NettAmt.]=(B.NetAmount-C.NetAmount),A.NettTax=(B.TaxAmount-C.TaxAmount)	FROM #InputVAT A CROSS JOIN
	(SELECT ISNULL(SUM(GrossAmount-Discount),0.00) NetAmount,ISNULL(SUM(TaxAmount),0.0) TaxAmount from PurchaseReceipt WHERE GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND Status=1 AND
	SpmId IN (SELECT DISTINCT SpmId FROM Supplier WHERE TaxGroupId>0))B CROSS JOIN
	(SELECT ISNULL(SUM(GrossAmount-Discount),0) NetAmount,ISNULL(SUM(TaxAmount),0) TaxAmount FROM PurchaseReturn WHERE PurRetDate BETWEEN @FromDate AND @ToDate AND Status=1 AND
	SpmId IN (SELECT DISTINCT SpmId FROM Supplier WHERE TaxGroupId>0))C
	WHERE A.[Details]='Input VAT (Purchases) - Local Registered'
	
	UPDATE A SET A.[Sale/Purc.Amt.]=B.AMOUNT,A.Tax1=B.TAX FROM #InputVAT A INNER JOIN 
	(SELECT B.TaxId,B.TaxPerc,SUM(B.TaxableAmount) AMOUNT,SUM(B.TaxAmount) TAX FROM PurchaseReceipt A INNER JOIN PurchaseReceiptProducttax B ON 
	A.PurRcptId=B.PurRcptId WHERE A.GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND A.Status=1 AND A.SpmId IN (SELECT DISTINCT SpmId FROM Supplier WHERE TaxGroupId>0) 
	GROUP BY B.TaxId,B.TaxPerc) B ON A.TaxId=B.TaxId AND A.TaxPerc=B.TaxPerc
	
	UPDATE A SET A.[Sale/Pur.Ret.Amount]=B.AMOUNT,A.Tax2=B.TAX FROM #InputVAT A INNER JOIN 
	(SELECT B.TaxId,B.TaxPerc,SUM(B.TaxableAmount) AMOUNT,SUM(B.TaxAmount) TAX FROM PurchaseReturn A INNER JOIN PurchaseReturnProductTax B ON 
	A.PurRetId=B.PurRetId WHERE A.PurRetDate BETWEEN @FromDate AND @ToDate AND A.Status=1 AND A.SpmId IN (SELECT DISTINCT SpmId FROM Supplier WHERE TaxGroupId>0) 
	GROUP BY B.TaxId,B.TaxPerc) B ON A.TaxId=B.TaxId AND A.TaxPerc=B.TaxPerc
	
	--Total
	UPDATE A SET A.[Sale/Purc.Amt.]=B.[Sale/Purc.Amt.],A.Tax1=B.Tax1,A.[Sale/Pur.Ret.Amount]=B.[Sale/Pur.Ret.Amount],A.Tax2=B.Tax2,
	A.[NettAmt.]=B.[NettAmt.],A.NettTax=B.NettTax  FROM #InputVAT A CROSS JOIN 
	(SELECT SUM([Sale/Purc.Amt.]) [Sale/Purc.Amt.],SUM([Tax1]) [Tax1],SUM([Sale/Pur.Ret.Amount]) [Sale/Pur.Ret.Amount],SUM([Tax2]) [Tax2],
	SUM([NettAmt.]) [NettAmt.],SUM([NettTax]) [NettTax] FROM #InputVAT WHERE TaxId=99999) B WHERE A.Details='  Total'
	--Total InputVAT
	UPDATE A SET A.NettTax= B.NettTax FROM #InputVAT A CROSS JOIN 
	(SELECT SUM(NettTax) NettTax FROM #InputVAT WHERE Details IN ('VAT Opening Balance','  Total'))B WHERE A.Details='Total Input VAT ='  

	--select * from #InputVAT 
	--InputVAT Till here
	
	--OutputVAT 
	SELECT A.TaxId,A.TaxName,B.TaxPerc INTO #OutputTaxPerc FROM TaxConfiguration A INNER JOIN (SELECT DISTINCT rowid,CAST(ColVal AS NUMERIC(18,1)) TaxPerc  
	FROM TaxSettingDetail WHERE ColId=0 AND TaxSeqId IN (SELECT TaxSeqId FROM TaxSettingMaster WHERE RtrId in (SELECT DISTINCT TaxGroupId FROM Retailer))) B ON B.RowId=A.TaxId 

	INSERT INTO #OutputVAT ([Details],[Sale/Purc.Amt.],[Tax1],[sale/Pur.Ret.Amount],[Tax2],[NettAmt.],[NettTax],TaxId)
	SELECT 'Output VAT (Sales-against TAX INVOICE)',0,0,0,0,0,0,99999
	UNION ALL
	SELECT 'Output VAT other than TAX INVOICE',0,0,0,0,0,0,99999
	UNION ALL
	SELECT 'Output VAT on Sale of exempted goods',0,0,0,0,0,0,99999
	UNION ALL
	SELECT 'Output VAT on Sale against form ''C''',0,0,0,0,0,0,99999
	UNION ALL
	SELECT 'Output VAT on Consignment sale',0,0,0,0,0,0,99999
	UNION ALL
	SELECT 'Output VAT on Any other sale',0,0,0,0,0,0,99999
	UNION ALL
	SELECT '',0,0,0,0,0,0,99999
	
	INSERT INTO #OutputVAT ([Details],[Sale/Purc.Amt.],[Tax1],[sale/Pur.Ret.Amount],[Tax2],[NettAmt.],[NettTax],TaxId,TaxPerc)
	SELECT '  Total '+TaxName+' -'+CAST(TaxPerc AS NVARCHAR(20))+'%',0,0,0,0,0,0,TaxId,TaxPerc FROM #OutputTaxPerc

	INSERT INTO #OutputVAT ([Details],[Sale/Purc.Amt.],[Tax1],[sale/Pur.Ret.Amount],[Tax2],[NettAmt.],[NettTax])
	SELECT ' Total',0,0,0,0,0,0
	UNION ALL 
	SELECT 'Total Output Tax',0,0,0,0,0,0
	
	UPDATE A SET A.[Sale/Purc.Amt.]=ISNULL(B.Amount,0.0),A.Tax1=ISNULL(B.TAX,0.0),A.[Sale/Pur.Ret.Amount]=ISNULL(C.Amount,0.0),A.Tax2=ISNULL(C.Tax,0.0) FROM #OutputVAT A CROSS JOIN 
	(SELECT SUM(A.SalGrossAmount-(TotalDeduction-(CRAdjAmount+OnAccountAmount+WindowDisplayAmount))) Amount,SUM(A.SalTaxAmount) TAX FROM SalesInvoice A INNER JOIN Retailer B ON A.RtrId=B.RtrId AND LEN(B.RtrTINNo)>2 WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts IN (4,5)) B CROSS JOIN
	(SELECT SUM(A.RtnGrossAmt-(RtnSplDisAmt+RtnSchDisAmt+RtnDBDisAmt+RtnCashDisAmt)) Amount,SUM(A.RtnTaxAmt) Tax FROM ReturnHeader A INNER JOIN Retailer B ON A.RtrId=B.RtrId AND LEN(B.RtrTINNo)>2 WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0) C
	WHERE A.Details='Output VAT (Sales-against TAX INVOICE)'
	
	UPDATE A SET A.[Sale/Purc.Amt.]=ISNULL(B.Amount,0.0),A.Tax1=ISNULL(B.TAX,0.0),A.[Sale/Pur.Ret.Amount]=ISNULL(C.Amount,0.0),A.Tax2=ISNULL(C.Tax,0.0) FROM #OutputVAT A CROSS JOIN 
	(SELECT SUM(A.SalGrossAmount-(TotalDeduction-(CRAdjAmount+OnAccountAmount+WindowDisplayAmount))) Amount,SUM(A.SalTaxAmount) TAX FROM SalesInvoice A INNER JOIN Retailer B ON A.RtrId=B.RtrId AND LEN(ISNULL(B.RtrTINNo,''))<2 WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts IN (4,5)) B CROSS JOIN
	(SELECT SUM(A.RtnGrossAmt-(RtnSplDisAmt+RtnSchDisAmt+RtnDBDisAmt+RtnCashDisAmt)) Amount,SUM(A.RtnTaxAmt) Tax FROM ReturnHeader A INNER JOIN Retailer B ON A.RtrId=B.RtrId AND LEN(ISNULL(B.RtrTINNo,''))<2 WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0) C
	WHERE A.Details='Output VAT other than TAX INVOICE'
	
	UPDATE A SET A.[Sale/Purc.Amt.]=ISNULL(B.AMOUNT,0.0),A.Tax1=ISNULL(B.TAX,0.0) FROM #OutputVAT A CROSS JOIN 
	(SELECT B.TaxId,B.TaxPerc,SUM(B.TaxableAmount) AMOUNT,SUM(B.TaxAmount) TAX FROM Salesinvoice A INNER JOIN SalesInvoiceProductTax B 
	ON A.SalId=B.SalId WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts<>3 GROUP BY B.TaxId,B.TaxPerc) B 
	WHERE A.TaxId=B.TaxId AND A.TaxPerc=B.TaxPerc
	
	UPDATE A SET A.[Sale/Pur.Ret.Amount]=ISNULL(B.AMOUNT,0.0),A.Tax2=ISNULL(B.TAX,0.0) FROM #OutputVAT A CROSS JOIN 
	(SELECT B.TaxId,B.TaxPerc,SUM(B.TaxableAmt) AMOUNT,SUM(B.TaxAmt) TAX FROM ReturnHeader A INNER JOIN ReturnProductTax B 
	ON A.ReturnID=B.ReturnID WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate GROUP BY B.TaxId,B.TaxPerc) B 
	WHERE A.TaxId=B.TaxId AND A.TaxPerc=B.TaxPerc
	--Total
	UPDATE #OutputVAT SET [NettAmt.]=[Sale/Purc.Amt.]-[Sale/Pur.Ret.Amount],NettTax=Tax1-Tax2 WHERE TaxId>0
	UPDATE A SET A.[Sale/Purc.Amt.]=B.[Sale/Purc.Amt.],A.Tax1=B.Tax1,A.[Sale/Pur.Ret.Amount]=B.[Sale/Pur.Ret.Amount],A.Tax2=B.Tax2, 
	A.[NettAmt.]=B.[NettAmt.],A.NettTax=B.NettTax FROM #OutputVAT A CROSS JOIN 
	(SELECT SUM([Sale/Purc.Amt.]) [Sale/Purc.Amt.],SUM([Tax1]) [Tax1],SUM([Sale/Pur.Ret.Amount]) [Sale/Pur.Ret.Amount],SUM([Tax2]) [Tax2],
	SUM([NettAmt.]) [NettAmt.],SUM([NettTax]) [NettTax] FROM #OutputVAT WHERE TaxId=99999) B WHERE A.Details=' Total'
	--Total OutputTAX
	UPDATE A SET A.NettTax=B.NettTax FROM #OutputVAT A CROSS JOIN #OutputVAT B WHERE A.Details='Total Output Tax' AND B.Details=' Total' 
	--select * from #OutputVAT 
	--OutputVAT till here
	
	--CST
	INSERT INTO #CST ([Details],[Sale/Purc.Amt.],[Tax1],[sale/Pur.Ret.Amount],[Tax2],[NettAmt.],[NettTax])
	SELECT 'Nett VAT =',0,0,0,0,0,0
	UNION ALL
	SELECT 'Output CST (Sales)',0,0,0,0,0,0
	UNION ALL
	SELECT ' Total',0,0,0,0,0,0
	UNION ALL
	SELECT 'CST Adjusted',0,0,0,0,0,0
	UNION ALL
	SELECT 'Nett VAT Payable/Refundable =',0,0,0,0,0,0
	UNION ALL
	SELECT 'CST Payable =',0,0,0,0,0,0
	
	UPDATE A SET A.NettTax=C.NettTax-B.NettTax FROM #CST A CROSS JOIN
	(SELECT ISNULL(NettTax,0.0) NettTax FROM #InputVAT WHERE Details='Total Input VAT =') B CROSS JOIN
	(SELECT ISNULL(NettTax,0.0) NettTax FROM #OutputVAT WHERE Details='Total Output Tax') C WHERE A.Details='Nett VAT ='
	
	UPDATE A SET A.NettTax=B.NettTax+C.NettTax FROM #CST A CROSS JOIN
	(SELECT ISNULL(NettTax,0.0) NettTax FROM #CST WHERE Details='Nett VAT =') B CROSS JOIN 
	(SELECT ISNULL(NettTax,0.0) NettTax FROM #CST WHERE Details='CST Adjusted') C WHERE A.Details='Nett VAT Payable/Refundable ='
	
	UPDATE A SET A.NettTax=B.NettTax-C.NettTax FROM #CST A CROSS JOIN
	(SELECT ISNULL(NettTax,0.0) NettTax FROM #CST WHERE Details='Output CST (Sales)') B CROSS JOIN 
	(SELECT ISNULL(NettTax,0.0) NettTax FROM #CST WHERE Details='CST Adjusted') C WHERE A.Details='CST Payable ='
	--SELECT * FROM #CST
	--CST Till here
	
	INSERT INTO #VATSummaryOUTPUT ([Details],[Sale/Purc.Amt.],[Tax1],[sale/Pur.Ret.Amount],[Tax2],[NettAmt.],[NettTax])
	SELECT [Details],	CASE [Sale/Purc.Amt.] WHEN 0 THEN '' ELSE CAST ([Sale/Purc.Amt.] AS NVARCHAR(200)) END, 
						CASE [Tax1] WHEN 0 THEN '' ELSE CAST([Tax1] AS NVARCHAR(200)) END,
						CASE [sale/Pur.Ret.Amount] WHEN 0 THEN '' ELSE CAST([sale/Pur.Ret.Amount] AS NVARCHAR(200)) END,
						CASE [Tax2] WHEN 0 THEN '' ELSE CAST([Tax2] AS NVARCHAR(200)) END,
						CASE [NettAmt.] WHEN 0 THEN '' ELSE CAST([NettAmt.] AS NVARCHAR(200)) END,
						[NettTax] 
	FROM #InputVAT WHERE Details='VAT Opening Balance'
	UNION ALL
	SELECT [Details],	CASE [Sale/Purc.Amt.] WHEN 0 THEN '' ELSE CAST ([Sale/Purc.Amt.] AS NVARCHAR(200)) END, 
						CASE [Tax1] WHEN 0 THEN '' ELSE CAST([Tax1] AS NVARCHAR(200)) END,
						CASE [sale/Pur.Ret.Amount] WHEN 0 THEN '' ELSE CAST([sale/Pur.Ret.Amount] AS NVARCHAR(200)) END,
						CASE [Tax2] WHEN 0 THEN '' ELSE CAST([Tax2] AS NVARCHAR(200)) END,
						CASE [NettAmt.] WHEN 0 THEN '' ELSE CAST([NettAmt.] AS NVARCHAR(200)) END,
						CASE [NettTax] WHEN 0 THEN '' ELSE CAST([NettTax] AS NVARCHAR(200)) END 
	FROM #InputVAT WHERE Details<>'  Total' AND Details<>'Total Input VAT =' AND Details<>'VAT Opening Balance'
	UNION ALL
	SELECT '','-----------------','-----------------','-----------------','-----------------','-----------------','-----------------'
	UNION ALL
	SELECT [Details],[Sale/Purc.Amt.],[Tax1],[sale/Pur.Ret.Amount],[Tax2],[NettAmt.],[NettTax]
	FROM #InputVAT WHERE Details='  Total' 
	UNION ALL
	SELECT '','-----------------','-----------------','-----------------','-----------------','-----------------','-----------------'
	UNION ALL
	SELECT [Details],	CASE [Sale/Purc.Amt.] WHEN 0 THEN '' ELSE CAST ([Sale/Purc.Amt.] AS NVARCHAR(200)) END, 
						CASE [Tax1] WHEN 0 THEN '' ELSE CAST([Tax1] AS NVARCHAR(200)) END,
						CASE [sale/Pur.Ret.Amount] WHEN 0 THEN '' ELSE CAST([sale/Pur.Ret.Amount] AS NVARCHAR(200)) END,
						CASE [Tax2] WHEN 0 THEN '' ELSE CAST([Tax2] AS NVARCHAR(200)) END,
						CASE [NettAmt.] WHEN 0 THEN '' ELSE CAST([NettAmt.] AS NVARCHAR(200)) END,
						[NettTax]
	FROM #InputVAT WHERE Details='Total Input VAT ='
	--Output VAT
	UNION ALL
	SELECT [Details],	CASE [Sale/Purc.Amt.] WHEN 0 THEN '' ELSE CAST ([Sale/Purc.Amt.] AS NVARCHAR(200)) END, 
						CASE [Tax1] WHEN 0 THEN '' ELSE CAST([Tax1] AS NVARCHAR(200)) END,
						CASE [sale/Pur.Ret.Amount] WHEN 0 THEN '' ELSE CAST([sale/Pur.Ret.Amount] AS NVARCHAR(200)) END,
						CASE [Tax2] WHEN 0 THEN '' ELSE CAST([Tax2] AS NVARCHAR(200)) END,
						CASE [NettAmt.] WHEN 0 THEN '' ELSE CAST([NettAmt.] AS NVARCHAR(200)) END,
						CASE [NettTax] WHEN 0 THEN '' ELSE CAST([NettTax] AS NVARCHAR(200)) END 
	FROM #OutputVAT WHERE Details<>' Total' AND Details<>'Total Output Tax'
	UNION ALL
	SELECT '','-----------------','-----------------','-----------------','-----------------','-----------------','-----------------'
	UNION ALL
	SELECT [Details],[Sale/Purc.Amt.],[Tax1],[sale/Pur.Ret.Amount],[Tax2],[NettAmt.],[NettTax]
	FROM #OutputVAT WHERE Details=' Total' 
	UNION ALL
	SELECT '','-----------------','-----------------','-----------------','-----------------','-----------------','-----------------'
	UNION ALL
	SELECT [Details],	CASE [Sale/Purc.Amt.] WHEN 0 THEN '' ELSE CAST ([Sale/Purc.Amt.] AS NVARCHAR(200)) END, 
						CASE [Tax1] WHEN 0 THEN '' ELSE CAST([Tax1] AS NVARCHAR(200)) END,
						CASE [sale/Pur.Ret.Amount] WHEN 0 THEN '' ELSE CAST([sale/Pur.Ret.Amount] AS NVARCHAR(200)) END,
						CASE [Tax2] WHEN 0 THEN '' ELSE CAST([Tax2] AS NVARCHAR(200)) END,
						CASE [NettAmt.] WHEN 0 THEN '' ELSE CAST([NettAmt.] AS NVARCHAR(200)) END,
						CAST([NettTax] AS NVARCHAR(200)) 
	FROM #OutputVAT WHERE Details IN ('Total Output Tax')
	--CST
	UNION ALL
	SELECT [Details],	CASE [Sale/Purc.Amt.] WHEN 0 THEN '' ELSE CAST ([Sale/Purc.Amt.] AS NVARCHAR(200)) END, 
						CASE [Tax1] WHEN 0 THEN '' ELSE CAST([Tax1] AS NVARCHAR(200)) END,
						CASE [sale/Pur.Ret.Amount] WHEN 0 THEN '' ELSE CAST([sale/Pur.Ret.Amount] AS NVARCHAR(200)) END,
						CASE [Tax2] WHEN 0 THEN '' ELSE CAST([Tax2] AS NVARCHAR(200)) END,
						CASE [NettAmt.] WHEN 0 THEN '' ELSE CAST([NettAmt.] AS NVARCHAR(200)) END,
						CAST([NettTax] AS NVARCHAR(200)) 
	FROM #CST WHERE Details IN ('Nett VAT =')
	UNION ALL
	SELECT [Details],	CASE [Sale/Purc.Amt.] WHEN 0 THEN '' ELSE CAST ([Sale/Purc.Amt.] AS NVARCHAR(200)) END, 
						CASE [Tax1] WHEN 0 THEN '' ELSE CAST([Tax1] AS NVARCHAR(200)) END,
						CASE [sale/Pur.Ret.Amount] WHEN 0 THEN '' ELSE CAST([sale/Pur.Ret.Amount] AS NVARCHAR(200)) END,
						CASE [Tax2] WHEN 0 THEN '' ELSE CAST([Tax2] AS NVARCHAR(200)) END,
						CASE [NettAmt.] WHEN 0 THEN '' ELSE CAST([NettAmt.] AS NVARCHAR(200)) END,
						CASE [NettTax] WHEN 0 THEN '' ELSE CAST([NettTax] AS NVARCHAR(200)) END 
	FROM #CST WHERE Details IN ('Output CST (Sales)')
	UNION ALL
	SELECT '','-----------------','-----------------','-----------------','-----------------','-----------------','-----------------'
	UNION ALL
	SELECT [Details],[Sale/Purc.Amt.],[Tax1],[sale/Pur.Ret.Amount],[Tax2],[NettAmt.],[NettTax]
	FROM #CST WHERE Details=' Total' 
	UNION ALL
	SELECT '','-----------------','-----------------','-----------------','-----------------','-----------------','-----------------'
	UNION ALL
	SELECT [Details],	CASE [Sale/Purc.Amt.] WHEN 0 THEN '' ELSE CAST ([Sale/Purc.Amt.] AS NVARCHAR(200)) END, 
						CASE [Tax1] WHEN 0 THEN '' ELSE CAST([Tax1] AS NVARCHAR(200)) END,
						CASE [sale/Pur.Ret.Amount] WHEN 0 THEN '' ELSE CAST([sale/Pur.Ret.Amount] AS NVARCHAR(200)) END,
						CASE [Tax2] WHEN 0 THEN '' ELSE CAST([Tax2] AS NVARCHAR(200)) END,
						CASE [NettAmt.] WHEN 0 THEN '' ELSE CAST([NettAmt.] AS NVARCHAR(200)) END,
						CAST([NettTax] AS NVARCHAR(200))
	FROM #CST WHERE Details IN('CST Adjusted','Nett VAT Payable/Refundable =','CST Payable =')
	
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #VATSummaryOUTPUT
	
	UPDATE A SET A.[DistName]=B.DistributorName FROM #VATSummaryOUTPUT A CROSS JOIN Distributor B
	UPDATE A SET A.[DistAddress]=B.DistributorAdd1+';'+B.DistributorAdd2+';'+B.DistributorAdd3 FROM #VATSummaryOUTPUT A CROSS JOIN Distributor B
	UPDATE A SET A.[DistTIN]=B.TINNo FROM #VATSummaryOUTPUT A CROSS JOIN Distributor B
	UPDATE A SET A.DistCity=B.GeoName FROM #VATSummaryOUTPUT A CROSS JOIN (SELECT GeoName FROM Geography WHERE GeoMainId IN (SELECT GeoMainId FROM Distributor)) B
	UPDATE #VATSummaryOUTPUT SET AY=CAST(@AY AS NVARCHAR(10))
	
	SELECT * FROM #VATSummaryOUTPUT
END
GO
DELETE FROM CustomCaptions WHERE CtrlName='MsgBox-87-1000-8' AND TransId=87 
INSERT INTO CustomCaptions
SELECT 87,1000,8,'MsgBox-87-1000-8','','','USER profile cannot be Edited',1,1,1,GETDATE(),1,GETDATE(),'','','USER profile cannot be Edited',1,1
UPDATE ProfileDt SET Btnstatus = 1 WHERE PrfId IN (SELECT PrfId FROM Users WHERE UserName = 'USER') AND MenuId = 'mStk4'
GO
DELETE FROM ProfileDt WHERE MenuId = 'mPrd4'
INSERT INTO ProfileDt
SELECT DISTINCT PrfId,'mprd4',0,'New',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD  WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mprd4',1,'Edit',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD  WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mprd4',2,'Save',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD  WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mprd4',3,'Delete',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD  WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mprd4',6,'Print',0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD  WITH (NOLOCK)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_ReturnKitStock')
DROP PROCEDURE Proc_ReturnKitStock
GO
--exec Proc_ReturnKitStock '2007-08-28',1,1,1,1
CREATE PROCEDURE Proc_ReturnKitStock  
(  
	@Pi_TransDate  		DateTime,
	@Pi_LcnId		INT,
	@Pi_CmpId		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT	
)  
AS  
/*********************************
* PROCEDURE	: Proc_ReturnKitStock
* PURPOSE	: To Return the Kit Product Stock Availability
* CREATED	: Thrinath
* CREATED DATE	: 10/08/2007
* NOTE		: General SP for Returning the Kit Product Stock Availability
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
	
*********************************/  
SET NOCOUNT ON  
Begin 

DECLARE @TotalStock TABLE
(
	LcnId		INT,
	KitPrdId	INT,
	Qty		INT,
	PrdId		INT,
	Saleable	INT,
	UnSaleable	INT,
	Offer		INT
)

DECLARE @TotalAvailStock TABLE
(
	KitPrdId	INT,
	Saleable	INT,
	UnSaleable	INT,
	Offer		INT
)

DECLARE @FinalStock TABLE
(
	KitPrdId	INT,
	Qty		INT,
	PrdId		INT,
	KitSaleable	INT,
	KitUnSaleable	INT,
	KitOffer	INT,
	RemSaleable	INT,
	RemUnSaleable	INT,
	RemOffer	INT
)

	INSERT INTO @TotalStock (LcnId,KitPrdId,Qty,PrdId,Saleable,UnSaleable,Offer)
	SELECT @Pi_LcnId AS LcnId,C.KitPrdId,C.Qty,C.PrdId,
		ISNULL(SUM((PrdBatLcnSih - PrdBatLcnRessih)),0) As Saleable,
		ISNULL(SUM((PrdBatLcnUih - PrdBatLcnResUih)),0) AS UnSaleable,
		ISNULL(SUM((PrdBatLcnFre - PrdBatLcnResFre)),0) As Offer
		FROM KitProductBatch A INNER JOIN ProductBatchLocation B ON
		A.PrdId = B.PrdId AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
		AND B.LcnId = CASE @Pi_LcnId WHEN 0 THEN B.LcnId ELSE @Pi_LcnId END
		INNER JOIN KitProduct C ON C.KitPrdId = A.KitPrdId AND A.PrdId = C.PrdId
		INNER JOIN Product D ON D.PrdId = C.KitPrdId 
		AND D.CmpId = CASE @Pi_CmpId WHEN 0 THEN D.CmpId ELSE @Pi_CmpId END
		--AND @Pi_TransDate Between D.EffectiveFrom AND D.EffectiveTo
		AND D.PrdStatus = 1 
	GROUP BY C.KitPrdId,C.Qty,C.PrdId

	INSERT INTO @TotalAvailStock (KitPrdId,Saleable,UnSaleable,Offer)
	SELECT KitPrdId,MIN(Saleable) AS Saleable,MIN(UnSaleable) AS UnSaleable,MIN(Offer) AS Offer
	FROM ( SELECT KitPrdId,
		CASE Qty WHEN 0 THEN 0 ELSE FLOOR(Saleable/Qty) END AS Saleable,
		CASE Qty WHEN 0 THEN 0 ELSE FLOOR(UnSaleable/Qty) END AS UnSaleable,
		CASE Qty WHEN 0 THEN 0 ELSE FLOOR(Offer/Qty) END AS Offer
		FROM @TotalStock) AS A
	GROUP BY KitPrdId

	INSERT INTO @FinalStock (KitPrdId,Qty,PrdId,KitSaleable,KitUnSaleable,KitOffer,
		RemSaleable,RemUnSaleable,RemOffer)
	SELECT A.KitPrdId,A.Qty,A.PrdId,B.Saleable,B.UnSaleable,B.Offer,
		A.Saleable - (B.Saleable*A.Qty),A.UnSaleable - (B.UnSaleable*A.Qty),
		A.Offer - (B.Offer*A.Qty) FROM @TotalStock A INNER JOIN @TotalAvailStock B
		ON A.KitPrdId = B.KitPrdId

	DELETE FROM KitProductStock WHERE UsrId = @Pi_UsrId AND TransId = @Pi_TransId

	INSERT INTO KitProductStock (KitPrdId,Qty,PrdId,KitSaleable,KitUnSaleable,KitOffer,
		RemSaleable,RemUnSaleable,RemOffer,UsrId,TransId)
	SELECT KitPrdId,Qty,PrdId,KitSaleable,KitUnSaleable,KitOffer,
		RemSaleable,RemUnSaleable,RemOffer,@Pi_UsrId,@Pi_TransId
	FROM @FinalStock

END
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 401' ,'401'
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 401)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(401,'D','2013-03-19',GETDATE(),1,'Core Stocky Service Pack 401')
GO