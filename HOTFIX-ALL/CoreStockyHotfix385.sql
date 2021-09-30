--[Stocky HotFix Version]=385
Delete from Versioncontrol where Hotfixid='385'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('385','2.0.0.5','D','2011-09-05','2011-09-05','2011-09-05',convert(varchar(11),getdate()),'Major: Product Release FOR PM,CK,B&L-Bug Fixing')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 384' ,'384'
GO
Delete from RptExcelheaders where Rptid=2 
insert into RptExcelheaders select 2,	1,	'PrdId'   ,	'PrdId',	0,	1
insert into RptExcelheaders select 2,	2,	'PrdDCode',	'Product Code',	1	,1
insert into RptExcelheaders select 2,	3,	'PrdName' ,	'Product Name',	1	,1
insert into RptExcelheaders select 2,	4,	'PrdBatId', 'PrdBatId'	,0	,1
insert into RptExcelheaders select 2,	5,	'PrdBatCode','Batch Code'	,1	,1
insert into RptExcelheaders select 2,	6,	'MrpRate'	,'MRP'	,1	,1
insert into RptExcelheaders select 2,	7,	'SellingRate','Selling Rate',	1	,1
insert into RptExcelheaders select 2,	8,	'SalesQty','Sales Qty'	,1	,1
insert into RptExcelheaders select 2,	9,	'SalesPrdWeight','Sales Qty in volume',	0	,1
insert into RptExcelheaders select 2,	10,	'Uom1','Cases'	,0	,1
insert into RptExcelheaders select 2,	11,	'Uom2','Boxes'	,0	,1
insert into RptExcelheaders select 2,	12,	'Uom3','Strips'	,0	,1
insert into RptExcelheaders select 2,	13,	'Uom4','Pieces'	,0	,1
insert into RptExcelheaders select 2,	14,	'FreeQty','Free Qty',1	,1
insert into RptExcelheaders select 2,	15,	'FreePrdWeight','Free Qty in volume',0	,1
insert into RptExcelheaders select 2,	16,	'ReplaceQty','Replace Qty',1	,1
insert into RptExcelheaders select 2,	17,	'RepPrdWeight',	'Replacement Qty in volume',0,	1
insert into RptExcelheaders select 2,	18,	'ReturnQty','Return Qty',1	,1
insert into RptExcelheaders select 2,	19,	'RetPrdWeight','Return Qty in volume',0	,1
insert into RptExcelheaders select 2,	20,	'SalesValue','Gross Amount',1,1
GO
Delete From RptExcelheaders where Rptid=17
Insert into RptExcelheaders select  17	,1	,'Bill Number',	'Bill Number',	1	,1
Insert into RptExcelheaders select  17	,2	,'Bill Date'	,'Bill Date'	,1	,1
Insert into RptExcelheaders select  17	,3	,'Retailer Name',	'Retailer Name',	1	,1
Insert into RptExcelheaders select  17	,4	,'PrdId	','PrdId'	,1	,1
Insert into RptExcelheaders select  17	,5	,'Product Code',	'Product Code'	,1	,1
Insert into RptExcelheaders select  17	,6	,'Product Description',	'Product Name'	,1	,1
Insert into RptExcelheaders select  17	,7	,'BillCase'	,'Billed Qty in Selected UOM'	,1	,1
Insert into RptExcelheaders select  17	,8	,'BillPiece'	,'Billed Qty in Pieces'	,1	,1
Insert into RptExcelheaders select  17	,9	,'Free Qty'	,'Free Qty'	,1	,1
Insert into RptExcelheaders select  17	,10	,'Return Qty'	,'Return Qty'	,1	,1
Insert into RptExcelheaders select  17	,11	,'Replacement Qty'	,'Replacement Qty'	,1	,1
Insert into RptExcelheaders select  17	,12	,'TotalCase'	,'Total Qty in Selected UOM'	,1	,1
Insert into RptExcelheaders select  17	,13	,'TotalPiece'	,'Total Qty in Piece'	,1	,1
Insert into RptExcelheaders select  17	,14	,'Total Qty'	,'Total Qty'	,0	,1
Insert into RptExcelheaders select  17	,15	,'Billed Qty'	,'Billed Qty'	,0	,1
Insert into RptExcelheaders select  17	,16	,'NetAmount'	,'Net Amount'	,1	,1
GO
Delete From RptFormula where Rptid=2
insert into Rptformula select 2,1,'ProductCode','Product Code',	1,	0
insert into Rptformula select 2,2,	'ProductName',	'Product Name',	1,	0
insert into Rptformula select 2	,3	,'BatchNo'	,'Batch Code'	,1	,0
insert into Rptformula select 2	,4	,'MRP',	'MRP',	1	,0
insert into Rptformula select 2	,5	,'SellingRate',	'Selling Rate',	1	,0
insert into Rptformula select 2	,6	,'SalesQuantity',	'Sales Qty',	1	,0
insert into Rptformula select 2	,7	,'FreeQuantity',	'Free Qty'	,1	,0
insert into Rptformula select 2	,8	,'ReplacementQuantity',	'Rep. Qty'	,1,	0
insert into Rptformula select 2	,9	,'SalesValue'	,'Gross Amt'	,1	,0
insert into Rptformula select 2	,10	,'FromDate',	'From Date',	1,	0
insert into Rptformula select 2	,11	,'ToDate'	,'To Date'	,1	,0
insert into Rptformula select 2	,12	,'Company',	'Company',	1,	0
insert into Rptformula select 2	,13	,'Salesman'	,'Salesman'	,1	,0
insert into Rptformula select 2	,14	,'Route',	'Route',	1	,0
insert into Rptformula select 2	,15	,'Retailer'	,'Retailer',	1	,0
insert into Rptformula select 2	,16	,'ProductCategoryLevel',	'Product Hierarchy Level',	1,	0
insert into Rptformula select 2 ,17	,'ProductCategoryValue'	,'Product Hierarchy Level Value',	1	,0
insert into Rptformula select 2	,18	,'BillNumber',	'Bill Number',	1,	0
insert into Rptformula select 2	,19	,'Total'	,'Grand Total	',1	,0
insert into Rptformula select 2	,20	,'Disp_FromDate',	'FromDate',	1,	10
insert into Rptformula select 2	,21	,'Disp_ToDate'	,'ToDate'	,1	,11
insert into Rptformula select 2	,22,'Disp_Company',	'Company',	1,	4
insert into Rptformula select 2	,23	,'Disp_Salesman',	'Salesman',	1	,1
insert into Rptformula select 2	,24	,'Disp_Route'	,'Route'	,1	,2
insert into Rptformula select 2	,25	,'Disp_Retailer',	'Retailer'	,1,	3
insert into Rptformula select 2	,26	,'Disp_ProductCategoryLevel',	'ProductCategoryLevel',	1,	16
insert into Rptformula select 2	,27	,'Disp_ProductCategoryValue'	,'ProductCategoryLevelValue',	1,	21
insert into Rptformula select 2	,28	,'Disp_BillNumber',	'BillNumber',	1,	14
insert into Rptformula select 2	,29	,'Cap Page'	,'Page'	,1	,0
insert into Rptformula select 2	,30	,'Cap User Name',	'User Name',	1,	0
insert into Rptformula select 2	,31	,'Cap Print Date'	,'Date'	,1	,0
insert into Rptformula select 2	,32	,'Cap_Product'	,'Product',	1,	0
insert into Rptformula select 2	,33	,'Disp_Product'	,'Product',	1	,5
insert into Rptformula select 2	,34	,'Disp_Cancelled',	'Display Cancelled Bill Value',	1	,193
insert into Rptformula select 2	,35	,'Fill_Cancelled'	,'Display Cancelled Product Value'	,1	,0
insert into Rptformula select 2	,36	,'Cap_RetailerGroup',	'Retailer Group',	1,	0
insert into Rptformula select 2	,37	,'Disp_RetailerGroup'	,'Retailer Group'	,1	,215
insert into Rptformula select 2	,38	,'Cap_Location',	'Location',	1,	0
insert into Rptformula select 2	,39	,'Disp_Location'	,'Location',	1	,22
insert into Rptformula select 2	,40	,'Cap_Batch',	'Batch',	1	,0
insert into Rptformula select 2	,41	,'Disp_Batch',	'Batch',	1,	7
insert into Rptformula select 2	,42	,'ReturnQuantity'	,'Ret.Qty'	,1,	0
GO
Delete From RptExcelheaders where Rptid=9
Insert into RptExcelheaders select 9	,1	,'SRNNumber'	,'SRNNumber'	,1,	1
Insert into RptExcelheaders select 9	,2	,'SRDate'	,'SRDate'	,1	,1
Insert into RptExcelheaders select 9	,3	,'Salesman'	,'Salesman'	,1	,1
Insert into RptExcelheaders select 9	,4	,'RouteName'	,'Route Name'	,1	,1
Insert into RptExcelheaders select 9	,5	,'RtrName'	,'Retailer Name'	,1	,1
Insert into RptExcelheaders select 9	,6	,'BillNo'	,'Bill No'	,1	,1
Insert into RptExcelheaders select 9	,7	,'PrdCode'	,'Product Code'	,1	,1
Insert into RptExcelheaders select 9	,8	,'PrdName'	,'Product Description',	1	,1
Insert into RptExcelheaders select 9	,9	,'StockType	','Stock Type'	,1	,1
Insert into RptExcelheaders select 9	,10	,'Qty'	,'Qunatity'	,1	,1
Insert into RptExcelheaders select 9	,11	,'UsrId'	,'UsrId'	,0	,1
Insert into RptExcelheaders select 9	,12	,'UOM1'	,'UOM1'	,0	,1
Insert into RptExcelheaders select 9	,13	,'UOM2'	,'UOM2'	,0	,1
Insert into RptExcelheaders select 9	,14	,'UOM3'	,'UOM3'	,0	,1
Insert into RptExcelheaders select 9	,15	,'UOM4'	,'UOM4'	,0	,1
Insert into RptExcelheaders select 9	,16	,'[Gross Amount]',	'Gross Amount'	,1	,1
Insert into RptExcelheaders select 9	,17	,'[Spl. Disc]'	,'Spl. Disc'	,1	,1
Insert into RptExcelheaders select 9	,18	,'[Sch Disc]'	,'Sch Disc'	,1	,1
Insert into RptExcelheaders select 9	,19	,'[DB Disc]'	,'DB Disc'	,1	,1
Insert into RptExcelheaders select 9	,20	,'[CD Disc]'	,'CD Disc'	,1	,1
Insert into RptExcelheaders select 9	,21	,'[Tax Amt]'	,'Tax Amt'	,1	,1
Insert into RptExcelheaders select 9	,22	,'[Net Amount]'	,'Net Amount',	1,	1
GO
Delete from RptDetails where TblName='Company' and Rptid=171
Delete from RptDetails where TblName='JCMast'  and Rptid=171  
Delete from RptDetails where TblName='JCMonth' and Rptid=171 

Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (171,1,'Company',-1,'','CmpId,CmpCode,CmpName','Company*...',NULL,1,NULL,4,1,1,'Press F4/Double Click to select Company',0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (171,2,'JCMast',-1,'','JcmId,JcmYr,JcmYr','JC Year*...','',1,NULL,12,1,1,'Press F4/Double Click to select JC Year',0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (171,3,'JCMonth',2,'JcmId','JcmJc,JcmSdt,JcmSdt','From JC Month*...','JcMast',1,'JcmId',13,1,1,'Press F4/Double Click to select From JC Month',0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values (171,4,'JCMonth',2,'JcmId','JcmJc,JcmEdt,JcmEdt','To JC Month*...','JcMast',1,'JcmId',20,1,1,'Press F4/Double Click to select To JC Month',0)
GO
delete from customcaptions where SubctrlId in(101,102) and TransId=45 and ctrlId=1000 
insert into customcaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values(45,1000,101,'Msgbox-45-1000-101','','',
'Weight Based Product does not exists.Change the Scheme Type and Proceed.....',1,1,1,getdate(),1,getdate(),'','',
'Weight Based Product does not exists.Change the Scheme Type and Proceed.....',1,1)
insert into customcaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,
LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values(45,1000,102,'Msgbox-45-1000-102','','',
'Product Codes does not exists',1,1,1,getdate(),1,getdate(),'','',
'Product Codes does not exists',1,1)
GO
if exists (select * from dbo.sysobjects where id = object_id(N'Proc_RptGRNListing') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure Proc_RptGRNListing
GO
--Exec Proc_RptGRNListing 8,1,0,'PmProduct',0,0,0,0
CREATE  PROCEDURE [dbo].[Proc_RptGRNListing]
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
DECLARE @CmpInvNo 	AS	NVARCHAR(100)
DECLARE @ExcelFlag 	AS	INT
--select * from reportfilterdt
SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @CmpInvNo = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId))
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
PRINT @CmpInvNo
--Create TABLE #RptPendingBillsDetails
Create TABLE #RptGRNListing
(
		PurRcptId 		BIGINT,
		PurRcptRefNo 		NVARCHAR(50),
		PrdId  			INT,
		PrdDCode 		NVARCHAR(100),
		PrdName 		NVARCHAR(100),
		PrdBatId 		INT,
		PrdBatCode 		NVARCHAR(50),
		InvBaseQty 		INT,
		RcvdGoodBaseQty 	INT,
		UnSalBaseQty 		INT,
		ShrtBaseQty 		INT,
		ExsBaseQty 		INT,
		RefuseSale 		TINYINT,
		PrdUnitLSP 		NUMERIC(38,6),
		PrdGrossAmount 		NUMERIC(38,6),
		SlNo 			INT,
		RefCode 		NVARCHAR(25),
		FieldDesc 		NVARCHAR(100),
		LineBaseQtyAmount 	NUMERIC(38,6),
		PrdNetAmount 		NUMERIC(38,6),
		Status 			TINYINT,
		InvDate 		DATETIME,
		LessScheme 		NUMERIC(38,6),
		OtherCharges 		NUMERIC(38,6),
		TotalAddition 		NUMERIC(38,6),
		TotalDeduction 		NUMERIC(38,6),
		GrossAmount 		NUMERIC(38,6),
		NetPayable 		NUMERIC(38,6),
		DifferenceAmount 	NUMERIC(38,6),
		PaidAmount 		NUMERIC(38,6),
		NetAmount 		NUMERIC(38,6),
		SpmId 			INT,
		SpmName  		NVARCHAR(50),
		LcnId 			INT,
		LcnName  		NVARCHAR(50),
		TransporterId 		INT,
		TransporterName  	NVARCHAR(50),
		CmpId 			INT,
		CmpName  		NVARCHAR(50),
		UsrId 			INT,
		CmpInvNo 		NVARCHAR(50)
	)
SET @TblName = 'RptGRNListing'
SET @TblStruct = 'PurRcptId 		BIGINT,
		PurRcptRefNo 		NVARCHAR(50),
		PrdId  			INT,
		PrdDCode 		NVARCHAR(100),
		PrdName 		NVARCHAR(100),
		PrdBatId 		INT,
		PrdBatCode 		NVARCHAR(50),
		InvBaseQty 		INT,
		RcvdGoodBaseQty 	INT,
		UnSalBaseQty 		INT,
		ShrtBaseQty 		INT,
		ExsBaseQty 		INT,
		RefuseSale 		TINYINT,
		PrdUnitLSP 		NUMERIC(38,6),
		PrdGrossAmount 		NUMERIC(38,6),
		SlNo 			INT,
		RefCode 		NVARCHAR(25),
		FieldDesc 		NVARCHAR(100),
		LineBaseQtyAmount 	NUMERIC(38,6),
		PrdNetAmount 		NUMERIC(38,6),
		Status 			TINYINT,
		InvDate 		DATETIME,
		LessScheme 		NUMERIC(38,6),
		OtherCharges 		NUMERIC(38,6),
		TotalAddition 		NUMERIC(38,6),
		TotalDeduction 		NUMERIC(38,6),
		GrossAmount 		NUMERIC(38,6),
		NetPayable 		NUMERIC(38,6),
		DifferenceAmount 	NUMERIC(38,6),
		PaidAmount 		NUMERIC(38,6),
		NetAmount 		NUMERIC(38,6),
		SpmId 			INT,
		SpmName  		NVARCHAR(50),
		LcnId 			INT,
		LcnName  		NVARCHAR(50),
		TransporterId 		INT,
		TransporterName  	NVARCHAR(50),
		CmpId 			INT,
		CmpName  		NVARCHAR(50),
		UsrId 			INT,
		CmpInvNo 		NVARCHAR(50)'
			
SET @TblFields = 'PurRcptId,PurRcptRefNo,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,
		ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount,
		PrdNetAmount,Status,InvDate,LessScheme,OtherCharges,TotalAddition,TotalDeduction,GrossAmount,
		NetPayable ,DifferenceAmount,PaidAmount,NetAmount,SpmId,SpmName,LcnId,LcnName,TransporterId,TransporterName,
		CmpId,CmpName,UsrId,CmpInvNo'
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
IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
BEGIN
	
	EXEC Proc_GRNListing @Pi_UsrId
	INSERT INTO #RptGRNListing (PurRcptId,
		PurRcptRefNo,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,
		ShrtBaseQty,ExsBaseQty,PrdUnitLSP,PrdGrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount,
		PrdNetAmount,Status,InvDate,LessScheme,OtherCharges,TotalAddition,TotalDeduction,GrossAmount,
		NetPayable ,DifferenceAmount,PaidAmount,NetAmount,SpmId,SpmName,LcnId,LcnName,TransporterId,TransporterName,
		CmpId,CmpName,UsrId,CmpInvNo)
		SELECT PurRcptId,
		PurRcptRefNo,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,SUM(InvBaseQty),SUM(RcvdGoodBaseQty),SUM(UnSalBaseQty),
		SUM(ShrtBaseQty),SUM(ExsBaseQty),dbo.Fn_ConvertCurrency(PrdUnitLSP,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(SUM(PrdGrossAmount),@Pi_CurrencyId)
		,SlNo,RefCode,FieldDesc,dbo.Fn_ConvertCurrency(SUM(LineBaseQtyAmount),@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(SUM(PrdNetAmount),@Pi_CurrencyId),Status,InvDate,dbo.Fn_ConvertCurrency(LessScheme,@Pi_CurrencyId)
		,dbo.Fn_ConvertCurrency(OtherCharges,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(TotalAddition,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(TotalDeduction,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(GrossAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(NetPayable,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(DifferenceAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(PaidAmount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(NetAmount,@Pi_CurrencyId),
		SpmId,SpmName,LcnId,LcnName,TransporterId,TransporterName,CmpId,CmpName,UsrId,CmpInvNo
	
		FROM TempGrnListing 
				
			WHERE ( CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
					CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND
				( PurRcptId = (CASE @CmpInvNo WHEN 0 THEN PurRcptId ELSE 0 END) OR
	 					PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId)))
				AND
				( INVDATE between @FromDate and @ToDate and Usrid = @Pi_UsrId)
				AND ( PrdId > 0 )
		GROUP BY PurRcptId,
		PurRcptRefNo,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode
		,PrdUnitLSP,SlNo,RefCode,FieldDesc,
		Status,InvDate,LessScheme,OtherCharges,TotalAddition,TotalDeduction,GrossAmount,
		NetPayable ,DifferenceAmount,PaidAmount,NetAmount,SpmId,SpmName,LcnId,LcnName,TransporterId,TransporterName,
		CmpId,CmpName,UsrId,CmpInvNo	
--select * from rptdetails
	IF LEN(@PurDBName) > 0
	BEGIN
		SET @SSQL = 'INSERT INTO #RptGRNListing ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +
			' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+ ' (PurRcptId = (CASE ' + CAST(@CmpInvNo AS nVarchar(10)) + ' WHEN 0 THEN PurRcptId ELSE 0 END) OR ' +
			' PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',194,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+ ' ( INVDATE Between ''' + @FromDate + ''' AND ''' + @ToDate + '''' + ' and UsrId = ' + CAST(@Pi_UsrId AS nVarChar(10)) + ') AND ( PrdId > 0 )'
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptGRNListing'
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
		SET @SSQL = 'INSERT INTO #RptGRNListing ' +
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
SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptGRNListing
SELECT * FROM #RptGRNListing order by purrcptid
SELECT @ExcelFlag=Flag FROM RptExcelFlag WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId

		/***************************************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @PurRcptId BIGINT
		DECLARE  @PurRcptRefNo NVARCHAR(50)
		DECLARE  @PrdId INT
		DECLARE  @PrdBatId INT
		DECLARE  @FieldDesc NVARCHAR(100)
		DECLARE	 @LineBaseQtyAmount NUMERIC(38,6)
		DECLARE  @SlNo INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @Name NVARCHAR(100)
		--DROP TABLE RptGRNListing_Excel
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptGRNListing_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptGRNListing_Excel]
		DELETE FROM RptExcelHeaders Where RptId=8 AND SlNo>22 --18
		CREATE TABLE RptGRNListing_Excel (PurRcptId BIGINT,PurRcptRefNo NVARCHAR(50),CmpInvNo NVARCHAR(1000),InvDate DATETIME ,PrdId INT,PrdDCode NVARCHAR(100),PrdName NVARCHAR(100),
--				PrdBatId INT,PrdBatCode NVARCHAR(100),InvBaseQty INT,RcvdGoodBaseQty INT,UnSalBaseQty INT,ShrtBaseQty INT,ExsBaseQty INT,RefuseSale TINYINT,
				PrdBatId INT,PrdBatCode NVARCHAR(50),InvBaseQty INT,RcvdGoodBaseQty INT,Uom1 INT,Uom2 INT,Uom3 INT,Uom4 INT,				
				UnSalBaseQty INT,ShrtBaseQty INT,ExsBaseQty INT,RefuseSale TINYINT,
				PrdUnitLSP NUMERIC(38,6),PrdGrossAmount NUMERIC(38,6),UsrId INT)
		SET @iCnt=23 --19
		DECLARE Column_Cur CURSOR FOR
		SELECT DISTINCT(FieldDesc),SlNo FROM #RptGRNListing ORDER BY SlNo
		OPEN Column_Cur
			   FETCH NEXT FROM Column_Cur INTO @Column,@SlNo
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptGRNListing_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					
					PRINT @C_SSQL
					EXEC (@C_SSQL)
				SET @iCnt=@iCnt+1
					FETCH NEXT FROM Column_Cur INTO @Column,@SlNo
				END
		CLOSE Column_Cur
		DEALLOCATE Column_Cur
		--Insert table values
		DELETE FROM RptGRNListing_Excel
		INSERT INTO RptGRNListing_Excel(PurRcptId,PurRcptRefNo,CmpInvNo,InvDate,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,ShrtBaseQty,ExsBaseQty,RefuseSale,
									PrdUnitLSP,PrdGrossAmount,UsrId)
		SELECT DISTINCT PurRcptId,PurRcptRefNo,CmpInvNo,InvDate,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,@Pi_UsrId
				FROM #RptGRNListing
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT PurRcptId,PurRcptRefNo,PrdId,PrdBatId,FieldDesc,LineBaseQtyAmount FROM #RptGRNListing
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @PurRcptId,@PurRcptRefNo,@PrdId,@PrdBatId,@FieldDesc,@LineBaseQtyAmount
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptGRNListing_Excel  SET ['+ @FieldDesc +']= '+ CAST(@LineBaseQtyAmount AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL+ ' WHERE PurRcptId=' + CAST(@PurRcptId AS VARCHAR(1000))
					+' AND PurRcptRefNo=''' + CAST(@PurRcptRefNo AS VARCHAR(1000))+''' AND  PrdId=' + CAST(@PrdId As VARCHAR(1000))
					+' AND PrdBatId=' + CAST(@PrdBatId AS VARCHAR(1000))+' AND UsrId=' + CAST(@Pi_UsrId AS Varchar(10)) +''
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @PurRcptId,@PurRcptRefNo,@PrdId,@PrdBatId,@FieldDesc,@LineBaseQtyAmount
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptGRNListing_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptGRNListing_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/***************************************************************************************************************************/
--	END

/*  ADDED BY Panneer 09.07.2009  */
UPDATE A SET Uom1 = CASE WHEN ConverisonFactor2>0 THEN Case When CAST(RcvdGoodBaseQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(RcvdGoodBaseQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END,
			 Uom2 = CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(RcvdGoodBaseQty AS INT)-(CAST(RcvdGoodBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(RcvdGoodBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END,
			 Uom3 = CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(RcvdGoodBaseQty AS INT)-((CAST(RcvdGoodBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RcvdGoodBaseQty AS INT)-(CAST(RcvdGoodBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
					      (CAST(RcvdGoodBaseQty AS INT)-((CAST(RcvdGoodBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RcvdGoodBaseQty AS INT)-(CAST(RcvdGoodBaseQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END
FROM RptGRNListing_Excel A, View_ProdUOMDetails B ,ProductBatch C
WHERE a.prdid=b.prdid AND A.Prdid = C.PrdId AND B.PrdId = C.PrdId

SELECT A.PrdId,PrdBatId,CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
					CASE 
						WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
							Case When 
									CAST(RcvdGoodBaseQty AS INT)-(((CAST(RcvdGoodBaseQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(RcvdGoodBaseQty AS INT)-(CAST(RcvdGoodBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(RcvdGoodBaseQty AS INT)-((CAST(RcvdGoodBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RcvdGoodBaseQty AS INT)-(CAST(RcvdGoodBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
					CAST(RcvdGoodBaseQty AS INT)-(((CAST(RcvdGoodBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(RcvdGoodBaseQty AS INT)-(CAST(RcvdGoodBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(RcvdGoodBaseQty AS INT)-((CAST(RcvdGoodBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(RcvdGoodBaseQty AS INT)-(CAST(RcvdGoodBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
					ELSE
						CASE 
							WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
								Case
									When CAST(Sum(RcvdGoodBaseQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
										CAST(Sum(RcvdGoodBaseQty) AS INT)%nullif(ConverisonFactor2,0)
									Else CAST(Sum(RcvdGoodBaseQty) AS INT) End
							WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
								Case
									When CAST(Sum(RcvdGoodBaseQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
										CAST(Sum(RcvdGoodBaseQty) AS INT)%nullif(ConverisonFactor3,0)
									Else CAST(Sum(RcvdGoodBaseQty) AS INT) End			
						ELSE CAST(Sum(RcvdGoodBaseQty) AS INT) END
					END  AS GRNUOM4 INTO #TEMPGRNUOM
FROM
		RptGRNListing_Excel A, View_ProdUOMDetails B 
WHERE 
		a.prdid=b.prdid
GROUP BY
		A.PrdId,ConverisonFactor4,ConverisonFactor3,ConverisonFactor2,
		RcvdGoodBaseQty,ConversionFactor1,PrdBatId

UPDATE A  SET UOM4 = GRNUOM4
FROM RptGRNListing_Excel A, #TEMPGRNUOM B WHERE a.prdid=b.prdid AND A.PrdBatId = B.PrdBatId

/*   END HERE  */

	SELECT * INTO #TempRptGRNListingSpread FROM RptGRNListing_Excel
	DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
	INSERT INTO RptColValues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,
							 C16,C17,C18,Rptid,Usrid)
	SELECT PurRcptRefNo,CmpInvNo,InvDate,PrdDCode,PrdName,
		PrdBatCode,InvBaseQty,RcvdGoodBaseQty,
		Uom1,Uom2,Uom3,Uom4,
		UnSalBaseQty,ShrtBaseQty,ExsBaseQty,RefuseSale,
		PrdUnitLSP,PrdGrossAmount,
		@Pi_RptId,@Pi_UsrId
	FROM #TempRptGRNListingSpread

RETURN
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'Proc_CS2CNPurchaseOrder') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure Proc_CS2CNPurchaseOrder
GO
--Exec Proc_CS2CNPurchaseOrder 0
CREATE        PROCEDURE [dbo].[Proc_CS2CNPurchaseOrder]  
(  
	@Po_ErrNo INT OUTPUT  
)  
AS   
SET NOCOUNT ON  
BEGIN  
/*********************************  
* PROCEDURE: Proc_CS2CNPurchaseOrder  
* PURPOSE: Extract Purchase Order details from CoreStocky to Console  
* NOTES:  
* CREATED: MarySubashini.S 08-12-2008  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/  
 DECLARE @CmpID   AS INTEGER  
 DECLARE @DistCode AS NVARCHAR(50)  
 DECLARE @ChkDate AS DATETIME  
 DELETE FROM ETL_Prk_CS2CNPurchaseOrder WHERE UploadFlag='Y'   
 SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1   
 SELECT @DistCode = DistributorCode FROM Distributor  
 SELECT @ChkDate = NextUpDate FROM DayEndProcess WHERE ProcId = 6  
 SET @Po_ErrNo=0  
 INSERT INTO ETL_Prk_CS2CNPurchaseOrder   
 (   
  [DistCode]  ,  
  [PONumber]  ,  
  [CompanyPONumber] ,  
  [PODate]  ,  
  [POConfirmDate]  ,  
  [ProductHierarchyLevel] ,  
  [ProductHierarchyValue] ,  
  [ProductCode]   ,  
  [Quantity]  ,  
  [POType]    ,  
  [POExpiryDate]   ,  
  [SiteCode] ,  
  [UploadFlag]  
 )  
 SELECT @DistCode,PM.PurOrderRefNo,  
 (CASE PM.DownLoad WHEN 1 THEN PM.CmpPoNo ELSE '' END) AS CompanyPONumber,  
 PM.PurOrderDate,PM.PurOrderDate,ISNULL(PCL1.CmpPrdCtgName,''),ISNULL(PCV1.PrdCtgValCode,''),  
 P.PrdCCode,(PD.OrdQty*UG.ConversionFactor) AS Quantity,  
 (CASE PM.DownLoad WHEN 0 THEN 'Manual' ELSE 'Automatic' END ) AS POType,  
 (CASE PM.DownLoad WHEN 0 THEN PM.PurOrderExpiryDate ELSE '' END ) AS POExpiryDate,  
 ISNULL(SCM.SiteCode,''),'N'  
 FROM PurchaseOrderDetails PD  WITH (NOLOCK)   
 LEFT OUTER JOIN PurchaseOrderMaster PM WITH (NOLOCK)  ON PM.PurOrderRefNo=PD.PurOrderRefNo  
 LEFT OUTER JOIN Product P WITH (NOLOCK)  ON P.PrdId=PD.PrdId  
 LEFT OUTER JOIN UomGroup UG WITH (NOLOCK)  ON UG.UomGroupId=P.UomGroupId AND UG.UomId=PD.OrdUomId  
 LEFT OUTER JOIN ProductCategoryValue PCV WITH (NOLOCK)  ON PCV.PrdCtgValMainId=PM.PrdCtgValMainId   
 LEFT OUTER JOIN ProductCategoryValue PCV1 WITH (NOLOCK)  ON PCV1.PrdCtgValLinkCode=LEFT(PCV.PrdCtgValLInkCode,10)   
 LEFT OUTER JOIN ProductCategoryLevel PCL1 WITH (NOLOCK)  ON PCL1.CmpPrdCtgId=PCV1.CmpPrdCtgId   
 LEFT OUTER JOIN SiteCodeMaster SCM WITH (NOLOCK) ON PM.SiteId=SCM.SiteId   
 WHERE PM.ConfirmSts=1 AND PM.Upload=0  
 UPDATE PurchaseOrderMaster SET Upload=1 WHERE Upload=0 AND ConfirmSts=1  
 AND PurOrderRefNo IN (SELECT PONumber FROM ETL_Prk_CS2CNPurchaseOrder)   
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'Proc_Cs2Cn_Claim_RateDiffernece') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure Proc_Cs2Cn_Claim_RateDiffernece
GO
--EXEC Proc_Cs2Cn_Claim_RateDiffernece  
--SELECT * FROM Cs2Cn_Prk_ClaimAll  
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_Claim_RateDiffernece]  
AS  
/*********************************  
* PROCEDURE: Proc_Cs2Cn_Claim_RateDiffernece  
* PURPOSE: Extract Rate Difference Claim Details from CoreStocky to Console  
* NOTES:  
* CREATED: MarySubashini.S  05-08-2008  
* MODIFIED  
* DATE         AUTHOR        DESCRIPTION  
------------------------------------------------  
* 17-Dec-2009  Kalaichezhian To display Product wise ratediffClaim Display  
************************************************/  
SET NOCOUNT ON  
BEGIN  
 DECLARE @CmpID   AS INTEGER  
 DECLARE @DistCode As NVARCHAR(50)  
 DECLARE @ChkDate AS DATETIME  
 DECLARE @TransDate AS DATETIME  
 DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Rate Difference Claim'  
 SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1   
 SELECT @DistCode = DistributorCode FROM Distributor  
 SELECT @ChkDate = NextUpDate FROM DayEndProcess WHERE ProcId = 12  
 SELECT @TransDate=DATEADD(D,-1,GETDATE())  
 INSERT INTO Cs2Cn_Prk_ClaimAll  
 (  
  DistCode  ,  
  CmpName   ,  
  ClaimType  ,  
  ClaimMonth  ,  
  ClaimYear  ,  
  ClaimRefNo  ,  
  ClaimDate  ,  
  ClaimFromDate  ,  
  ClaimToDate  ,  
  DistributorClaim ,  
  DistributorRecommended ,  
  ClaimnormPerc  ,  
  SuggestedClaim  ,  
  TotalClaimAmt  ,  
  Remarks   ,  
  Description  ,  
  Amount1   ,  
  ProductCode  ,  
  Batch   ,  
  Quantity1  ,  
  Quantity2  ,  
  Amount2   ,  
  Amount3   ,  
  TotalAmount  ,  
  UploadFlag,Remark2  
 )  
 SELECT  @DistCode,CM.CmpName,'Rate Difference Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),  
 RDC.RefNo,CH.ClmDate,CH.FromDate,CH.ToDate,RDC.TotSpentAmt,RDC.RecSpentAmt,CD.ClmPercentage,CD.ClmAmount,  
 CD.RecommendedAmount,SI.Remarks,SI.SalInvNo,0,P.PrdCCode,PB.PrdBatCode,SIP.BaseQty,0,  
 SIP.PrdUom1EditedSelRate,0,RDC.TotSpentAmt,'N',ClmCode  
 FROM SalesInvoice SI WITH (NOLOCK)  
 INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SIP.SalId=SI.SalId  
 INNER JOIN RateDifferenceClaim RDC WITH (NOLOCK) ON RDC.RateDiffClaimId=SIP.RateDiffClaimId  
 INNER JOIN Company CM WITH (NOLOCK)  ON CM.CmpId=RDC.CmpId  
 INNER JOIN ClaimSheetDetail CD WITH (NOLOCK)  ON CD.RefCode=RDC.RefNo  
 INNER JOIN ClaimSheetHd CH WITH (NOLOCK)  ON CH.ClmId=CD.ClmId AND CH.ClmGrpId=12  
 INNER JOIN Product P ON P.PrdId = SIP.PrdId  
 INNER JOIN ProductBatch PB ON PB.PrdId = P.PrdId AND PB.PrdBatId=SIP.PrdBatId  
 WHERE RDC.Status=1 AND CH.Upload='N' AND CD.SelectMode=1 
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'Proc_RptSchemeUtilizationWithOutPrimary') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure Proc_RptSchemeUtilizationWithOutPrimary
GO
--EXEC Proc_RptSchemeUtilizationWithOutPrimary 152,2,0,'JnJCRFinal',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptSchemeUtilizationWithOutPrimary]
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
SET NOCOUNT ON
/*********************************
* PROCEDURE: Proc_RptSchemeUtilizationWithOutPrimary
* PURPOSE: Procedure To Return the Scheme Utilization for the Selected Filters
* NOTES:
* CREATED: Boopathy	08-08-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
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
	DECLARE @FromDate	      AS 	DateTime
	DECLARE @ToDate		      AS	DateTime
	DECLARE @fSchId		      AS	Int
	DECLARE @fSMId		      AS	Int
	DECLARE @fRMId		      AS 	Int
	DECLARE @CtgLevelId      AS    INT
	DECLARE @CtgMainId  AS    INT
	DECLARE @RtrClassId       AS    INT
	DECLARE @fRtrId		      AS	INT
	DECLARE @TempData	TABLE
	(	
		SchId	Int,
		RtrCnt	Int,
		BillCnt	Int
	)
	--Till Here
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @fSchId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))
	SET @fSMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @fRMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @fRtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	--Till Here
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	Create TABLE #RptSchemeUtilization
	(
		SchId		Int,
		SchCode		nVarChar(100),
		SchDesc		nVarChar(100),
		SlabId		nVarChar(10),
		BaseQty		INT,
		SchemeBudget	Numeric(38,6),
		BudgetUtilized	Numeric(38,6),
		NoOfRetailer	Int,
		NoOfBills	Int,
		UnselectedCnt	Int,
		FlatAmount	Numeric(38,6),
		DiscountPer	Numeric(38,6),
		Points		Int,
		FreePrdName	nVarchar(50),
		FreeQty		Int,
		FreeValue	Numeric(38,6),
		Total		Numeric(38,6),
		Type		INT
	)
	SET @TblName = 'RptSchemeUtilization'
	SET @TblStruct = '	SchId		Int,
				SchCode		nVarChar(100),
				SchDesc		nVarChar(100),
				SlabId		nVarChar(10),
				BaseQty		INT,
				SchemeBudget	Numeric(38,6),
				BudgetUtilized	Numeric(38,6),
				NoOfRetailer	Int,
				NoOfBills	Int,
				UnselectedCnt	Int,
				FlatAmount	Numeric(38,6),
				DiscountPer	Numeric(38,6),
				Points		Int,
				FreePrdName	nVarchar(50),
				FreeQty		Int,
				FreeValue	Numeric(38,6),
				Total		Numeric(38,6),
				Type		INT'
	SET @TblFields = 'SchId,SchCode,SchDesc,SlabId,BaseQty,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,FlatAmount,DiscountPer,Points,FreePrdName,FreeQty,FreeValue,Total,Type'
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
		EXEC Proc_SchemeUtilization @Pi_RptId,@Pi_UsrId
		DELETE FROM RtpSchemeWithOutPrimary WHERE PrdId=0 AND Type<>4
		UPDATE RtpSchemeWithOutPrimary SET selected=0,SlabId=0

		INSERT INTO #RptSchemeUtilization(SchId,SchCode,SchDesc,SlabId,BaseQty,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,FlatAmount,DiscountPer,Points,FreePrdName,FreeQty,FreeValue,Total,Type)
		SELECT A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.BaseQty,B.SchemeBudget,ISNULL(dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId)+
		dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId),0),Count(Distinct B.RtrId),
		Count(Distinct B.ReferNo),1 as UnSelectedCnt,dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId) as FlatAmount,
		dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId) as DiscountPer,
		ISNULL(SUM(Points),0) as Points,'' AS FreePrdName,0 AS FreeQty,0 AS FreeValue,
		ISNULL(dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId)+
		dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId),0),B.Type
		FROM SchemeMaster A INNER JOIN RtpSchemeWithOutPrimary B On A.SchId= B.SchId
		AND B.Userid = @Pi_UsrId AND B.RptId=@Pi_RptId
		WHERE ReferDate Between @FromDate AND @ToDate  AND
		(A.SchId = (CASE @fSchId WHEN 0 THEN A.SchId Else 0 END) OR
		A.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		B.LineType <> 3 AND B.Userid = @Pi_UsrId AND B.Type=1
		GROUP BY A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,B.BaseQty,B.Type
		UNION 
		SELECT A.SchId,A.SchCode,A.SchDsc,B.SlabId,0,B.SchemeBudget,0,0,
		0,0 as UnSelectedCnt,0 as FlatAmount,0 as DiscountPer,
		ISNULL(SUM(Points),0) as Points,
		CASE ISNULL(SUM(FreeQty),0) WHEN 0 THEN '' ELSE FreePrdName END AS FreePrdName,
		ISNULL(SUM(FreeQty),0) as FreeQty,ISNULL(SUM(FreeValue),0) as FreeValue,
		ISNULL(SUM(FreeValue),0),B.Type
		FROM SchemeMaster A INNER JOIN RtpSchemeWithOutPrimary B On A.SchId= B.SchId
		AND B.Userid = @Pi_UsrId AND B.RptId=@Pi_RptId
		WHERE ReferDate Between @FromDate AND @ToDate  AND
		(A.SchId = (CASE @fSchId WHEN 0 THEN A.SchId Else 0 END) OR
		A.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		B.LineType <> 3 AND B.Userid = @Pi_UsrId AND B.Type=2
		GROUP BY A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,FreePrdName,B.Type
		UNION
		SELECT A.SchId,A.SchCode,A.SchDsc,B.SlabId,0,B.SchemeBudget,0,0,
		0,0 as UnSelectedCnt,0 as FlatAmount,0 as DiscountPer,
		0 as Points,CASE ISNULL(SUM(GiftValue),0) WHEN 0 THEN '' ELSE GiftPrdName END AS FreePrdName,
		ISNULL(SUM(GiftQty),0) as FreeQty,ISNULL(SUM(GiftValue),0) as FreeValue,
		ISNULL(SUM(GiftValue),0),B.Type
		FROM SchemeMaster A INNER JOIN RtpSchemeWithOutPrimary B On A.SchId= B.SchId
		AND B.Userid = @Pi_UsrId AND B.RptId=@Pi_RptId
		WHERE ReferDate Between @FromDate AND @ToDate  AND
		(A.SchId = (CASE @fSchId WHEN 0 THEN A.SchId Else 0 END) OR
		A.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		B.LineType <> 3 AND B.Userid = @Pi_UsrId AND B.Type=3
		GROUP BY A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,GiftPrdName,B.Type
		--->Added By Nanda on 09/02/2011
		UNION 
		
		SELECT A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.BaseQty,B.SchemeBudget,ISNULL(dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId)+
		dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId),0),Count(Distinct B.RtrId),
		Count(Distinct B.ReferNo),1 as UnSelectedCnt,dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId) as FlatAmount,
		dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId) as DiscountPer,
		ISNULL(SUM(Points),0) as Points,'' AS FreePrdName,0 AS FreeQty,0 AS FreeValue,
		ISNULL(dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId)+
		dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId),0),B.Type
		FROM SchemeMaster A INNER JOIN RtpSchemeWithOutPrimary B On A.SchId= B.SchId
		AND B.Userid = @Pi_UsrId AND B.RptId=@Pi_RptId
		WHERE ReferDate Between @FromDate AND @ToDate  AND
		(A.SchId = (CASE @fSchId WHEN 0 THEN A.SchId Else 0 END) OR
		A.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
		B.LineType <> 3 AND B.Userid = @Pi_UsrId AND B.Type=4
		GROUP BY A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,B.BaseQty,B.Type
		--->Till Here
		SELECT SchId, CASE LineType WHEN 1 THEN Count(Distinct B.RtrId)
		ELSE Count(Distinct B.RtrId)*-1 END AS RtrCnt ,	CASE LineType WHEN 1 THEN Count(Distinct ReferNo)
		ELSE Count(Distinct ReferNo)*-1 END AS BillCnt
		INTO #TmpCnt FROM RtpSchemeWithOutPrimary B
		WHERE ReferDate Between @FromDate AND @ToDate  AND B.Userid = @Pi_UsrId AND B.RptId=@Pi_RptId AND
		(B.SchId = (CASE @fSchId WHEN 0 THEN B.SchId Else 0 END) OR
		B.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND --B.LineType = 2 AND
		B.Userid = @Pi_UsrId AND B.RptId=@Pi_RptId
		GROUP BY B.SchId,LineType
		DELETE FROM @TempData
		INSERT INTO @TempData(SchId,RtrCnt,BillCnt)
		SELECT SchId, SUM(RtrCnt),SUM(BillCnt) FROM #TmpCnt
		WHERE (SchId = (CASE @fSchId WHEN 0 THEN SchId Else 0 END) OR
		SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) 
		GROUP BY SchId
		UPDATE #RptSchemeUtilization SET NoOfRetailer = NoOfRetailer - CASE  WHEN RtrCnt <0 THEN RtrCnt ELSE 0 END,
		NoOfBills = BillCnt FROM @TempData B WHERE B.SchId = #RptSchemeUtilization.SchId
		--->Added By Nanda on 09/02/2011
		DECLARE @SchIId INT
		CREATE TABLE #SchemeProducts
		(
			SchID	INT,
			PrdID	INT
		)
		DECLARE Cur_SchPrd CURSOR FOR
		SELECT SchId FROM #RptSchemeUtilization
		OPEN Cur_SchPrd  
		FETCH NEXT FROM Cur_SchPrd INTO @SchIId
		WHILE @@FETCH_STATUS=0  
		BEGIN  
			INSERT INTO #SchemeProducts		
			SELECT @SchIId,PrdId FROM Fn_ReturnSchemeProductBatch(@SchIId)
			FETCH NEXT FROM Cur_SchPrd INTO @SchIId
		END  
		CLOSE Cur_SchPrd  
		DEALLOCATE Cur_SchPrd  
		--->Till Here
		SELECT SchId,PrdId,SUM(BaseQty) AS BaseQty INTO #TmpFinal FROM
		(SELECT DISTINCT C.SchId,A.PrdId, A.BaseQty-ReturnedQty AS BaseQty  FROM SalesInvoice D 
		INNER JOIN SalesInvoiceProduct A ON A.SalId=D.SalId
		INNER JOIN SalesInvoiceSchemeHd C ON A.SalId=C.SalId
		INNER JOIN #SchemeProducts E ON E.SchId =C.SchId AND A.PrdId=E.PrdId
		WHERE D.Dlvsts >3 AND SalInvDate Between @FromDate AND @ToDate  AND
		(C.SchId = (CASE @fSchId WHEN 0 THEN C.SchId Else 0 END) OR
		C.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) 
		) tmp
		GROUP BY SchId,PrdId 


		SELECT SchId,SUM(BaseQty) As BaseQty INTO #TempFinal1 FROM #TmpFinal 
		GROUP BY #TmpFinal.SchId
 		UPDATE #RptSchemeUtilization SET BaseQty = A.BaseQty FROM #TempFinal1 A 
 		WHERE A.SchId = #RptSchemeUtilization.SchId AND #RptSchemeUtilization.Type=1
		UPDATE #RptSchemeUtilization SET NoOfRetailer=0 WHERE NoOfRetailer<0
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptSchemeUtilization ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +
				' WHERE ReferDate Between ''' + @FromDate + ''' AND ''' + @ToDate + '''AND '+
				' (SchId = (CASE ' + CAST(@fSchId AS nVarchar(10)) + ' WHEN 0 THEN SchId Else 0 END) OR ' +
				' SchId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',8,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSchemeUtilization'
				EXEC (@SSQL)
				PRINT 'Saved Data Into SnapShot Table'
			END
		END
	END
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptSchemeUtilization ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSchemeUtilization

	UPDATE RPT SET RPT.SchCode=S.CmpSchCode  FROM #RptSchemeUtilization RPT INNER JOIN SchemeMaster S ON RPT.SchId=S.SchId 

		
	DELETE FROM #RptSchemeUtilization WHERE BaseQty=0 AND SchemeBudget=0 AND BudgetUtilized=0 AND FlatAmount=0 AND DiscountPer=0 AND Points=0 AND FreeQty=0 AND FreeValue=0 AND Total=0
	SELECT SchId,SchCode,SchDesc,SlabId,SUM(BaseQty) AS BaseQty,SchemeBudget,BudgetUtilized,NoOfRetailer,
	NoOfBills,UnselectedCnt,SUM(FlatAmount) AS FlatAmount,SUM(DiscountPer) AS DiscountPer,Points,
	FreePrdName,SUM(FreeQty) AS FreeQty,SUM(FreeValue) AS FreeValue,SUM(Total) AS Total FROM #RptSchemeUtilization
	GROUP BY SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
	NoOfBills,UnselectedCnt,Points,FreePrdName


	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSchemeUtilizationWithOutPrimary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptSchemeUtilizationWithOutPrimary_Excel
		SELECT SchId,SchCode,SchDesc,SlabId,SUM(BaseQty) AS BaseQty,SchemeBudget,NoOfBills,NoOfRetailer,BudgetUtilized,
		UnselectedCnt,SUM(FlatAmount) AS FlatAmount,SUM(DiscountPer) AS DiscountPer,Points,
		FreePrdName,SUM(FreeQty) AS FreeQty,SUM(FreeValue) AS FreeValue,SUM(Total) AS Total  
		INTO RptSchemeUtilizationWithOutPrimary_Excel FROM #RptSchemeUtilization 
		GROUP BY SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,Points,FreePrdName
	END 
	RETURN
END 
GO
if exists (select * from dbo.sysobjects where id = object_id(N'Proc_Cs2Cn_Claim_ReturnToCompany') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure Proc_Cs2Cn_Claim_ReturnToCompany
GO
CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_Claim_ReturnToCompany]  
AS  
/*********************************  
* PROCEDURE: Proc_Cs2Cn_Claim_ReturnToCompany  
* PURPOSE: Extract ReturnToCompanyClaim sheet details from CoreStocky to Console  
* NOTES:  
* CREATED: Aarthi.R    05/08/2008  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
 *  19.05.2011  Panneer   Remarks2 -- Insert Claim Top Sheet Ref No  
*********************************/  
SET NOCOUNT ON  
BEGIN  
 DECLARE @CmpID  AS NVARCHAR(50)  
 DECLARE @DistCode AS NVARCHAR(50)  
 DECLARE @ChkDate AS DATETIME  
 DECLARE @TransDate AS DATETIME  
 DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Return To Company'  
 SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1   
 SELECT @DistCode = DistributorCode FROM Distributor  
 SELECT @ChkDate = NextUpDate FROM DayEndProcess WHERE ProcId = 12  
 SELECT @TransDate=DATEADD(D,-1,GETDATE())  
 INSERT INTO Cs2Cn_Prk_ClaimAll  
 (  
  DistCode ,  
  CmpName ,  
  ClaimType ,  
  ClaimMonth ,  
  ClaimYear ,  
  ClaimRefNo ,  
  ClaimDate ,  
  ClaimFromDate ,  
  ClaimToDate ,  
  DistributorClaim,  
  DistributorRecommended,  
  ClaimnormPerc,  
  SuggestedClaim,  
  TotalClaimAmt ,  
  Remarks ,  
  Description ,  
  Amount1 ,  
  ProductCode ,  
  Batch ,  
  Quantity1 ,  
  Quantity2 ,  
  Amount2 ,  
  Amount3 ,  
  TotalAmount ,  
  UploadFlag,  
  Remark2  
 )  
 SELECT @DistCode  AS DistCode,  
  CmpName,'Return To Company' AS ClaimType,  
  DATENAME(MM,ClmDate)AS ClaimMonth,  
  DATEPART(YYYY,ClmDate) AS  ClaimYear,  
  --ClmDate AS  ClaimYear,  
  RH.RtnCmpRefNo AS ClaimRefNo,  
  ClmDate AS ClaimDate,  
  FromDate,  
  ToDate,  
  AmtForClaim,  
  AmtForClaim,  
  ClmPercentage,  
  ClmAmount,  
  RecommendedAmount,   
  RC.Remarks,  
  Description,  
  Rate AS Amount1,  
  PrdCCode,  
  PrdBatCode AS Batch,  
  RtnQty AS Quantity1,  
  0 AS Quantity2 ,  
  0 AS Amount2,  
  0 AS Amount3,  
  Amount,  
  'N' AS UploadFlag,ClmCode  
  FROM Company C WITH (NOLOCK)  
  INNER JOIN ClaimSheetHd CM WITH (NOLOCK)  
  ON CM.CmpID=C.CmpID  
  INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON CD.ClmId=CM.ClmId AND CM.ClmGrpId= 6  
  INNER JOIN ReturnToCompanyDt RH WITH (NOLOCK) ON RH.RtnCmpRefNo=CD.RefCode  
  LEFT OUTER JOIN ReasonMaster RM WITH (NOLOCK) ON RM.ReasonId=RH.ReasonId  
  INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=RH.PrdId  
  INNER JOIN ProductBatch PB WITH(NOLOCK) ON PB.PrdBatId=RH.PrdBatId  
  INNER JOIN ReturnToCompany RC WITH(NOLOCK) ON RC.RtnCmpRefNo=RH.RtnCmpRefNo  
  WHERE RC.Status=1 AND CD.Status=1 AND CM.Confirm=1 AND CM.Upload='N' AND CD.SelectMode=1 
END  
GO
if not exists (select * from hotfixlog where fixid = 385)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(385,'D','2011-09-05',getdate(),1,'Core Stocky Service Pack 385')
GO