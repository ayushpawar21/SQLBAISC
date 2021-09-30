--[Stocky HotFix Version]=393
Delete from Versioncontrol where Hotfixid='393'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('393','2.0.0.5','D','2011-10-20','2011-10-20','2011-10-20',convert(varchar(11),getdate()),'Major: Product Release')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 393' ,'393'
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'Proc_ProductForPO')
DROP PROCEDURE Proc_ProductForPO
GO
CREATE PROCEDURE [dbo].[Proc_ProductForPO]
(
	@Pi_CmpId INT,
	@Pi_SpmId INT,
	@Pi_LinkCode	NVARCHAR(1000),
	@Pi_HierMust INT,
	@Pi_ReduceStkInHand	INT,
    @Pi_BaseUom INT
)
AS
/*********************************
* PROCEDURE : Proc_ProductForPO
* PURPOSE : To get the Product details for Purchase Order
* CREATED : Nandakumar R.G
* CREATED DATE : 29/08/2009
* MODIFIED
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN

	TRUNCATE TABLE ProductOrd

	IF exists (SELECT * from dbo.sysobjects where id = object_id(N'[ProductOrdWithoutBatch]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [ProductOrdWithoutBatch]
	IF exists (SELECT * from dbo.sysobjects where id = object_id(N'[PrdBatRate]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [PrdBatRate]	
	IF exists (SELECT * from dbo.sysobjects where id = object_id(N'[ProductStock]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [ProductStock]

	IF @Pi_HierMust=1
	BEGIN
		SELECT PrdId,PrdCCode,PrdName,UomId,UomDescription,SysQty, 
		UomId2,UomDescription2,OrderQty INTO ProductOrdWithoutBatch FROM 
		(
			SELECT DISTINCT C.PrdSeqDtId, P.PrdId,P.PrdCCode,P.PrdName,0 AS UomId,'  ' UomDescription,0 as SysQty, 
			U.UomId UomId2,U.UomDescription UomDescription2,0 as OrderQty FROM Product P, UomMaster U , 
			UomGroup UG,ProductSequence B WITH (NOLOCK), 
			ProductSeqDetails C WITH (NOLOCK),ProductcategoryValue PCV WHERE P.UomGroupId = UG.UomGroupId  AND 
			UG.UomId = U.UomId AND CmpId=@Pi_CmpId AND SpmId=(CASE @Pi_SpmId WHEN 0 THEN SpmId ELSE @Pi_SpmId END) AND B.TransactionId = 26 
			AND P.PrdStatus=1 AND P.PrdType<>3 AND B.PrdSeqId = C.PrdSeqId AND P.PrdId = C.PrdId AND 
			PCV.PrdCtgValMainId=P.PrdCtgValMainId AND PCV.PrdCtgValLinkCode LIKE @Pi_LinkCode+'%'
			Union 
			SELECT DISTINCT 100000 AS PrdSeqDtId,P.PrdId,P.PrdCCode,P.PrdName,0 AS UomId,'  ' UomDescription,0 SysQty,
			U.UomId UomId2,U.UomDescription UomDescription2,0 as OrderQty 
			FROM Product P, UomMaster U , UomGroup UG,ProductcategoryValue PCV WHERE P.UomGroupId = UG.UomGroupId  
			AND UG.UomId = U.UomId AND CmpId=@Pi_CmpId AND SpmId=(CASE @Pi_SpmId WHEN 0 THEN SpmId ELSE @Pi_SpmId END) AND PrdStatus = 1 AND P.PrdType<>3 AND PrdId NOT IN 
			(SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=26 AND B.PrdSeqId=C.PrdSeqId) AND 
			PCV.PrdCtgValMainId=P.PrdCtgValMainId AND PCV.PrdCtgValLinkCode LIKE @Pi_LinkCode+'%'
		) A
		ORDER BY PrdSeqDtId
	END
	ELSE
	BEGIN
		SELECT PrdId,PrdCCode,PrdName,UomId,UomDescription,SysQty, 
		UomId2,UomDescription2,OrderQty INTO ProductOrdWithoutBatch FROM 
		(
			SELECT DISTINCT C.PrdSeqDtId, P.PrdId,P.PrdCCode,P.PrdName,0 UomId,'  ' UomDescription,0 as SysQty,  
			U.UomId UomId2,U.UomDescription UomDescription2,0 as OrderQty FROM Product P, UomMaster U , UomGroup UG,ProductSequence B WITH (NOLOCK),  
			ProductSeqDetails C WITH (NOLOCK) WHERE P.UomGroupId = UG.UomGroupId  AND UG.UomId = U.UomId AND  CmpId = @Pi_CmpId AND B.TransactionId = 26  
			AND P.PrdStatus=1 AND P.PrdType<>3 AND B.PrdSeqId = C.PrdSeqId AND P.PrdId = C.PrdId  
			Union  
			SELECT DISTINCT 100000 AS PrdSeqDtId,P.PrdId,P.PrdCCode,P.PrdName,0 UomId,'  ' UomDescription,0 SysQty,U.UomId UomId2,U.UomDescription UomDescription2,
			0 as OrderQty  FROM Product P, UomMaster U , UomGroup UG WHERE P.UomGroupId = UG.UomGroupId  AND UG.UomId = U.UomId AND  CmpId = @Pi_CmpId AND PrdStatus = 1 
			AND P.PrdType<>3 AND PrdId NOT IN  ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=26 AND 
			B.PrdSeqId=C.PrdSeqId)
		) A
		ORDER BY PrdSeqDtId		
	END

	CREATE TABLE PrdBatRate
	(
		PrdId		INT,
		PrdBatId	INT,
		PriceId		INT,
		Rate		NUMERIC(38,6)	
	)

	INSERT INTO PrdBatRate(PrdId,PrdBatId,PriceId,Rate)
	SELECT PO.PrdId,ISNULL(MAX(PB.PrdBatId),0) AS PrdBatId,0 AS PriceId,0.000000 AS Rate	
	FROM ProductOrdWithoutBatch PO
	LEFT OUTER JOIN ProductBatch PB ON PO.PrdId=PB.PrdId 	
	GROUP BY PO.PrdId
	ORDER BY PO.PrdId

	ALTER TABLE PrdBatRate
	ALTER COLUMN Rate NUMERIC(38,6)
	
	UPDATE PrdBatRate SET PrdBatRate.Rate= PBD.PrdBatDetailValue,PrdBatRate.PriceId= PBD.PriceId
	FROM ProductBatchDetails PBD,BatchCreation BC 
	WHERE PrdBatRate.PrdBatId=PBD.PrdbatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND
	BC.ListPrice=1 AND BC.BatchSeqId=PBD.BatchSeqId

	INSERT INTO ProductOrd(PrdId,PrdcCode,PrdName,UomId,UomDescription,SysQty,UomId2,UomDescription2,[Order Qty],
	PrdBatId,PrdBatCode,PriceId,PurRate,Amount)
	SELECT PO.PrdId,PO.PrdCCode,PO.PrdName,PO.UomId,PO.UomDescription,PO.SysQty,PO.UomId2,PO.UomDescription2,PO.OrderQty,
	ISNULL(PR.PrdBatId,0),ISNULL(PB.PrdBatCode,''),ISNULL(PR.PriceId,0),ISNULL(PR.Rate,0),0
	FROM ProductOrdWithoutBatch PO
	LEFT OUTER JOIN PrdBatRate PR ON PO.PrdId=PR.PrdId
	LEFT OUTER JOIN ProductBatch PB ON PB.PrdBatId=PR.PrdBatId 
	ORDER BY PO.PrdId,PO.PrdCCode,PB.PrdBatCode

	IF @Pi_ReduceStkInHand=1 
	BEGIN
		SELECT PrdId,SUM((PrdbatLcnSih-PrdbatLcnResSih)) AS StkAvl
		INTO ProductStock
		FROM ProductBatchLocation
		GROUP BY PrdId
		
		UPDATE ProductOrd SET ProductOrd.[Order Qty]=ProductOrd.[Order Qty]-PS.StkAvl,
		ProductOrd.SysQty=ProductOrd.SysQty-PS.StkAvl
		FROM ProductStock PS WHERE ProductOrd.PrdId=PS.PrdId
	END

	UPDATE ProductOrd SET [Order Qty]=0 WHERE [Order Qty]<0
	UPDATE ProductOrd SET SysQty=0 WHERE SysQty<0
	
	UPDATE ProductOrd SET Amount=[Order Qty]*PurRate	
END
GO
DELETE FROM HotSearchEditorHd WHERE FormId=540
INSERT INTO HotSearchEditorHd VALUES 
(540,'Billing','OrderNo','select',
'SELECT OrderNo,OrderDate,RtrName,RtrShipId,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipPinNo,RtrShipPhoneNo,DocRefNo FROM (SELECT A.OrderNo,A.OrderDate,B.RtrName,A.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,RS.RtrShipPinNo,RS.RtrShipPhoneNo,DocRefNo FROM OrderBooking A INNER JOIN Retailer B ON A.RtrId=B.RtrId INNER JOIN RetailerShipAdd RS ON RS.RtrShipId = A.RtrShipId     AND A.Rtrid = vTParam and A.SMId = vFParam AND A.RMId = vSParam AND Status =0 AND OrderNo IN (SELECT DISTINCT B.OrderNo FROM OrderBookingProducts B)) A')
GO
DELETE FROM HotSearchEditorHd WHERE FormId=541
INSERT INTO HotSearchEditorHd VALUES 
(541,'Billing','OrderBill','select',
'SELECT OrderNo,OrderDate,RtrName,RtrId,RMId,RMName,SMId,SMName,SMMktCredit,SMCreditDays,SMCreditAmountAlert,SMCreditDaysAlert,  RtrShipId,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipPinNo,RtrShipPhoneNo,DocRefNo  FROM (SELECT A.OrderNo,A.OrderDate,B.RtrName,A.RtrId,A.RMId,C.RMName,A.SMId,D.SMName,SMMktCredit,SMCreditDays,SMCreditAmountAlert,  SMCreditDaysAlert,A.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,RS.RtrShipPinNo,RS.RtrShipPhoneNo,A.DocRefNo  FROM OrderBooking A INNER JOIN Retailer B ON A.RtrId = B.Rtrid    INNER JOIN RouteMaster C ON A.RMId = C.RMId INNER JOIN Salesman D ON A.SMId = D.SMId    INNER JOIN RetailerShipAdd RS ON RS.RtrShipId = A.RtrShipId WHERE A.Status =0    AND A.OrderNo IN (SELECT DISTINCT OrderNo FROM OrderBookingProducts)) A')
GO
Delete From RptDetails where Rptid = 54
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	54,	1,	'FromDate',	-1,'','',			'From Date*',	'',	1,	'',	10,	0,	0,	'Enter From Date',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(	54,	2,	'ToDate',	-1,'','',		'To Date*',	'',	1,	'',	11,	0,	0,	'Enter To Date',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(54,	3,	'Company',	-1,'',		'CmpId,CmpCode,CmpName',	'Company*...',	'',	1,	'',	4,	1,	0,	'Press F4/Double Click to Select Company',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(54,	4,	'Salesman',	-1,'',		'SMId,SMCode,SMName',	'Salesman...',	'',	1,	'',	1,	0,	0,	'Press F4/Double Click to select Salesman',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(54,	5,	'RouteMaster',	-1,'',		'RMId,RMCode,RMName',	'Route...',	'',	1,	'',	2,	0,	0,	'Press F4/Double Click to select Route',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(54,	6,	'Retailer',	-1,'',		'RtrId,RtrCode,RtrName',	'Retailer...',	'',	1,	'',	3,	0,	0,	'Press F4/Double Click to select Retailer',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(54,	7,	'RetailerCategoryLevel',	3,	'CmpId',	'CtgLevelId,CtgLevelName,CtgLevelName',	'Category Level...',	'Company',	1,	'CmpId',	29,	1,	0,	'Press F4/Double Click to select Category Level',	1)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(54,	8,	'RetailerCategory',	7,	'CtgLevelID',	'CtgMainId,CtgCode,CtgName',	'Category Level Value...',	'RetailerCategoryLevel',	1,	'CtgLevelId',	30,	1,	0,	'Press F4/Double Click to select Category Level Value',	1)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(54,	9,	'RetailerValueClass',	8,	'CtgMainID',	'RtrClassID,ValueClassCode,ValueClassName',	'Value Classification...',	'RetailerCategory',	1,	'CtgMainId',	31,	1,	0,	'Press F4/Double Click to select Value Classification',	0)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(54,	10,	'ProductCategoryLevel',	5,	'CmpId',	'CmpPrdCtgId,CmpPrdCtgName,LevelName',	'Product Hierarchy Level...',	'Company',	1,	'CmpId',	16,	1,	0,	'Press F4/Double Click to select Product Hierarchy Level',	1)
Insert Into RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(54,	11,	'ProductCategoryValue',	10,	'CmpPrdCtgId',	'PrdCtgValMainId,PrdCtgValCode,PrdCtgValName',	'Product Hierarchy Level Value...',	'ProductCategoryLevel',	1,	'CmpPrdCtgId',	21,	0,	0,	'Press F4/Double Click to select Product Hierarchy Level Value',	0)
GO
DELETE FROM RptFormula WHERE RptId=54
INSERT INTO RptFormula SELECT 54,1,'Disp_FromDate','From Date',1,0
INSERT INTO RptFormula SELECT 54,2,'Fill_FromDate','FromDate',1,10
INSERT INTO RptFormula SELECT 54,3,'Disp_ToDate','To Date',1,0
INSERT INTO RptFormula SELECT 54,4,'Fill_ToDate','ToDate',1,11
INSERT INTO RptFormula SELECT 54,5,'Disp_Company','Company',1,0
INSERT INTO RptFormula SELECT 54,6,'Fill_Company','Company',1,4
INSERT INTO RptFormula SELECT 54,7,'Disp_Salesman','Salesman',1,0
INSERT INTO RptFormula SELECT 54,8,'Fill_Salesman','Salesman',1,1
INSERT INTO RptFormula SELECT 54,9,'Disp_Route','Route',1,0
INSERT INTO RptFormula SELECT 54,10,'Fill_Route','Route',1,2
INSERT INTO RptFormula SELECT 54,11,'Disp_RetailerCategoryLevel','Category Level',1,0
INSERT INTO RptFormula SELECT 54,12,'Fill_CategoryLevel','ProductCategoryLevel',1,29
INSERT INTO RptFormula SELECT 54,13,'Disp_RetailerCategory','Category Level Value',1,0
INSERT INTO RptFormula SELECT 54,14,'Fill_CategoryValue','ProductCategoryLevelValue',1,30
INSERT INTO RptFormula SELECT 54,15,'Disp_RetailerValueClass','Value Classification',1,0
INSERT INTO RptFormula SELECT 54,16,'Fill_RetailerValueClass','Value Classification',1,31
INSERT INTO RptFormula SELECT 54,17,'Disp_ProductCategoryLevel','Product Hierarchy Level',1,0
INSERT INTO RptFormula SELECT 54,18,'Fill_ProductCategoryLevel','ProductCategoryLevel',1,16
INSERT INTO RptFormula SELECT 54,19,'Disp_ProductCategoryValue','Product Hierarchy Level Value',1,0
INSERT INTO RptFormula SELECT 54,20,'Fill_ProductCategoryValue','ProductCategoryLevelValue',1,21
INSERT INTO RptFormula SELECT 54,21,'Disp_OutletCategory','Outlet Category',1,0
INSERT INTO RptFormula SELECT 54,22,'Disp_OutletClass','Outlet Class',1,0
INSERT INTO RptFormula SELECT 54,23,'Disp_NoofBillcuts','No.Of Bill Cuts',1,0
INSERT INTO RptFormula SELECT 54,24,'Disp_TLSD','TLSD',1,0
INSERT INTO RptFormula SELECT 54,25,'Disp_Value','Gross Value',1,0
INSERT INTO RptFormula SELECT 54,26,'Cap Page','Page',1,0
INSERT INTO RptFormula SELECT 54,27,'Cap User Name','User Name',1,0
INSERT INTO RptFormula SELECT 54,28,'Cap Print Date','Date',1,0
INSERT INTO RptFormula SELECT 54,29,'Total','Grand Total',1,0
INSERT INTO RptFormula SELECT 54,30,'Retailer','Retailer',1,0
INSERT INTO RptFormula SELECT 54,31,'Disp_Retailer','Retailer',1,3
GO
DELETE FROM RptExcelheaders WHERE RptId=54
INSERT INTO RptExcelheaders SELECT 54,1,'SMId','SMId',0,1
INSERT INTO RptExcelheaders SELECT 54,2,'SMName','Salesman',1,1
INSERT INTO RptExcelheaders SELECT 54,3,'RMId','RMId',0,1
INSERT INTO RptExcelheaders SELECT 54,4,'RMName','Route',1,1
INSERT INTO RptExcelheaders SELECT 54,5,'RtrId','RtrId',0,1
INSERT INTO RptExcelheaders SELECT 54,6,'RtrName','Retailer',1,1
INSERT INTO RptExcelheaders SELECT 54,7,'OutletCategory','Outlet Category',1,1
INSERT INTO RptExcelheaders SELECT 54,8,'OutletClass','Outlet Class',1,1
INSERT INTO RptExcelheaders SELECT 54,9,'TotalBillCuts','No of Bill Cuts',1,1
INSERT INTO RptExcelheaders SELECT 54,10,'TLSD','TLSD',1,1
INSERT INTO RptExcelheaders SELECT 54,11,'Value','Gross Value',1,1
GO
UPDATE counters SET Zpad=6 WHERE TabName='ReturnHeader' and FldName='ReturnCode' 
UPDATE BillSeriesDtValue SET Zpad=6
UPDATE counters SET Zpad=6 WHERE TabName='PurchaseReturn' and FldName='PurRetRefNo' 
UPDATE PurInvSeriesPrefix SET Zpad=6
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME ='Proc_RptCollectionReport')
DROP PROCEDURE Proc_RptCollectionReport
GO
--EXEC Proc_RptCollectionReport 4,2,0,'Deploy',0,0,1
CREATE PROCEDURE [Proc_RptCollectionReport]
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
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE RptId=4 AND SlNo IN (2,3)
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE RptId=4 AND SlNo IN (5,6)
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE RptId=4 AND SlNo IN (24,25)
		
	END
	ELSE
	BEGIN
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE RptId=4 AND SlNo IN (2,3)
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE RptId=4 AND SlNo IN (5,6)
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE RptId=4 AND SlNo IN (24,25)
	END 
	Create TABLE #RptCollectionDetail
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
		AmtStatus 		NVARCHAR(10),
		InvRcpDate		DATETIME,
		CurPayAmount           	NUMERIC (38,6),
		CollCashAmt NUMERIC (38,6),
		CollChqAmt NUMERIC (38,6),
		CollDDAmt  NUMERIC (38,6),
		CollRTGSAmt NUMERIC (38,6),
		InvRcpNo nvarchar(50),
		Remarks  NVARCHAR(500)	
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
				InvRcpNo nvarchar(50),
				Remarks  NVARCHAR(500)'
	SET @TblFields = 'SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
			  BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
			  BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,
				CollChqAmt,CollDDAmt,CollRTGSAmt,InvRcpNo,Remarks'
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
		BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,InvRcpNo,Remarks)
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
		,dbo.Fn_ConvertCurrency(CollRTGSAmt,@Pi_CurrencyId),R.InvRcpNo,R.Remarks
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
	
	
	SELECT SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
	BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
	ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus
	FROM #RptCollectionDetail ORDER BY SalId,InvRcpDate,InvRcpNo
	DECLARE @ExcelFlag INT
	SELECT @ExcelFlag = Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @ExcelFlag = 1
	BEGIN
		IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='RptCollectionDetail_Excel')
			BEGIN 
				DROP TABLE RptCollectionDetail_Excel
				CREATE TABLE RptCollectionDetail_Excel
					(
						SalId 			BIGINT,
						SalInvNo		NVARCHAR(50),
						SalInvDate      DATETIME,
						SalInvRef 		NVARCHAR(50),
						InvRcpNo        NVARCHAR(50),
						InvRcpDate      DATETIME,
						RtrId 			INT,
						RtrCode         NVARCHAR(100),
						RtrName         NVARCHAR(150),
						BillAmount              NUMERIC (38,6),
						CurPayAmount           	NUMERIC (38,6),
						CrAdjAmount             NUMERIC (38,6),
						DbAdjAmount             NUMERIC (38,6),
						CashDiscount		NUMERIC (38,6),
						CollCashAmt NUMERIC (38,6),
						CollChqAmt NUMERIC (38,6),
						CollDDAmt  NUMERIC (38,6),
						CollRTGSAmt NUMERIC (38,6),
						CollectedAmount         NUMERIC (38,6),
						BalanceAmount           NUMERIC (38,6),						
						PayAmount           	NUMERIC (38,6),
						TotalBillAmount		NUMERIC (38,6),
						AmtStatus 		NVARCHAR(10),
                        CollectionDate  DATETIME,
                        CollectedBy     NVARCHAR(150),
						Remarks         NVARCHAR(500)
					)
			END 
		INSERT INTO RptCollectionDetail_Excel(SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
				BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
				CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,CollectedAmount,BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,CollectionDate,Remarks)
		SELECT  SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
				BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
				ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,
				ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,
				CollectedAmount,BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,Remarks
		FROM	#RptCollectionDetail 
	    ORDER BY SalId,InvRcpDate,InvRcpNo
		UPDATE RPT SET RPT.[RtrCode]=R.RtrCode FROM RptCollectionDetail_Excel RPT,Retailer R WHERE RPT.[RtrId]=R.RtrID
		UPDATE RPT SET RPT.CollectedBy=S.SMNAME FROM RptCollectionDetail_Excel RPT,Receipt R,Salesman S WHERE RPT.InvRcpNo=R.InvRcpNo AND R.CollectedById=S.SMId AND R.CollectedMode=1
		UPDATE RPT SET RPT.CollectedBy=S.DlvBoyName FROM RptCollectionDetail_Excel RPT,Receipt R,DeliveryBoy S WHERE RPT.InvRcpNo=R.InvRcpNo AND R.CollectedById=S.DlvBoyId AND R.CollectedMode=2
		--Add the Grand Total in Excel Reports--
--		SET @sSql='INSERT INTO RptCollectionDetail_Excel (SalId,RtrName,CrAdjAmount,DbAdjAmount,CashDiscount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt)
--					SELECT 99999,''Total'',sum(CrAdjAmount),sum(DbAdjAmount),sum(CashDiscount),sum(CollCashAmt),sum(CollChqAmt),sum(CollDDAmt),sum(CollRTGSAmt) FROM #RptCollectionDetail'
--		PRINT @sSql
--		EXEC (@sSql)
		--Till here--
	END
RETURN
END
GO
DELETE FROM RptExcelHeaders where RptId=4
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
SELECT 4,1,'SalId','SalId',0,1 UNION ALL
SELECT 4,2,'SalInvNo','Bill Number',1,1 UNION ALL
SELECT 4,3,'SalInvDate','Bill Date',1,1 UNION ALL
SELECT 4,4,'SalInvRef','SalInvRef',0,1  UNION ALL
SELECT 4,5,'InvRcpNo','Receipt No',1,1  UNION ALL
SELECT 4,6,'InvRcpDate','Collection Date',1,1  UNION ALL
SELECT 4,7,'RtrId','Rtrid',0,1  UNION ALL
SELECT 4,8,'RtrCode','Retailer Code',0,1 UNION ALL
SELECT 4,9,'RtrName','Retailer',1,1  UNION ALL
SELECT 4,10,'BillAmount','Bill Amount',1,1  UNION ALL
SELECT 4,11,'CurPayAmount','Paid Amount',1,1  UNION ALL
SELECT 4,12,'CrAdjAmount','Cr.Adj.Amount',1,1  UNION ALL
SELECT 4,13,'DbAdjAmount','Db.Adj.Amount',1,1  UNION ALL
SELECT 4,14,'CashDiscount','Cash Discount',1,1  UNION ALL
SELECT 4,15,'CollCashAmt','Cash Amount',1,1  UNION ALL
SELECT 4,16,'CollChqAmt','Cheque Amount',1,1  UNION ALL
SELECT 4,17,'CollDDAmt','DD Amount',1,1  UNION ALL
SELECT 4,18,'CollRTGSAmt','RTGS Amount',1,1  UNION ALL
SELECT 4,19,'CollectedAmount','Collected Amount',1,1  UNION ALL
SELECT 4,20,'BalanceAmount','Balance Amount',1,1  UNION ALL	
SELECT 4,21,'PayAmount','PayAmount',0,1  UNION ALL
SELECT 4,22,'TotalBillAmount','TotalBillAmount',0,1  UNION ALL
SELECT 4,23,'AmtStatus','AmtStatus',0,1  UNION ALL
SELECT 4,24,'CollectionDate','CollectionDate',0,1  UNION ALL
SELECT 4,25,'CollectedBy','CollectedBy',0,1 UNION ALL
SELECT 4,26,'Remarks','Remarks',0,1 
GO
DELETE FROM RptExcelHeaders where RptId=150
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
SELECT 150,1,'SalId','SalId',0,1 UNION ALL
SELECT 150,2,'SalInvDate',	'Date',1,1 UNION ALL
SELECT 150,3,'PrdId',	'PrdId',0,1 UNION ALL
SELECT 150,4,'PrdCode',	'Product Code',1,1 UNION ALL
SELECT 150,5,'PrdName',	'Product Name',1,1 UNION ALL
SELECT 150,6,	'PrdBaId',	'PrdBaId',0,1 UNION ALL
SELECT 150,7,'PrdBatCode',	'Batch',1,1 UNION ALL
SELECT 150,8,'SellingRate',	'Rate',1,1 UNION ALL
SELECT 150,9,'BaseQty',	'Sales Quantity',1,1 UNION ALL
SELECT 150,10,'FreeQty','Offer Quantity',1,1 UNION ALL
SELECT 150,11,'GrossAmount',	'Gross Amount',1,1 UNION ALL
SELECT 150,12,'SplDiscAmount',	'Spl. Disc',1,1 UNION ALL
SELECT 150,13,	'SchDiscAmount'	,'Sch Disc',1,1 UNION ALL
SELECT 150,14,	'DBDiscAmount',	'DB Disc',1,1 UNION ALL
SELECT 150,15,'CDDiscAmount',	'CD Disc',1,1 UNION ALL
SELECT 150,16,'TaxAmount',	'Tax Amt',	1,1 UNION ALL
SELECT 150,17,'NetAmount',	'Net Amount',1,1
GO
DELETE FROM RptExcelHeaders  where Rptid=3
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
SELECT 3,1,'SMId','SMId',0,1 UNION ALL
SELECT 3,2,'SMName','Salesman',1,1 UNION ALL
SELECT 3,3,'RMId','RMId',0,1 UNION ALL
SELECT 3,4,'RMName','Route',1,1 UNION ALL
SELECT 3,5,'RtrId','RtrId',0,1 UNION ALL
SELECT 3,6,'RtrCode','Retailer Code',1,1 UNION ALL
SELECT 3,7,'RtrName','Retailer',1,1 UNION ALL
SELECT 3,8,'SalId','SalId',0,1 UNION ALL
SELECT 3,9,'SalInvNo','Bill Number',1,1 UNION ALL
SELECT 3,10,'SalInvDate','Bill Date',1,1 UNION ALL
SELECT 3,11,'SalInvRef','Doc Ref No',0,1 UNION ALL
SELECT 3,14,'BalanceAmount','Balance Amount',1,1 UNION ALL
SELECT 3,15,'ArDays','AR Days',1,1 UNION ALL
SELECT 3,12,'BillAmount','Bill Amount',1,1 UNION ALL
SELECT 3,13,'CollectedAmount','Collected Amount',1,1
GO
Update RptHeader Set RptName='RptCrNoteRetailerDetails.rpt' where rptId=81
Update RptHeader Set RptName='RptDebitNoteRetailerDetails.rpt' where rptId=82 
Update RptHeader Set RptName='RptCrNoteSupplierDetails.rpt' where rptId=84 
Update RptHeader Set RptName='RptDebitNoteSupplierDetails.rpt' where rptId=85 
GO
DELETE FROM RptExcelHeaders WHERE RptId=38 and slno=10
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
SELECT 38,10,'AcName','Account Name',1,1
GO
DELETE FROM RptExcelHeaders WHERE RptId=168
INSERT INTO RptExcelHeaders
SELECT 168,1,'Bill Number','Bill Number',1,1
UNION 
SELECT 168,2,'Bill Date' ,'Bill Date',1,1 
UNION
SELECT 168,3,'Retailer Code','Retailer Code',1,1    
UNION
SELECT 168,4,'Retailer Name','Retailer Name',1,1        
UNION
SELECT 168,5,'RtrId','RtrId',0,1      
UNION
SELECT 168,6,'SMID','SMID',0,1      
UNION
SELECT 168,7,'RMId','RMId',0,1      
UNION
SELECT 168,8,'Gross Amount','Gross Amount',1,1       
UNION
SELECT 168,9,'Scheme Disc','Scheme Disc',1,1         
UNION
SELECT 168,10,'Discount','Discount',1,1           
UNION
SELECT 168,11,'Tax Amount','Tax Amount',1,1          
UNION
SELECT 168,12,'Net Amount','Net Amount',1,1    
UNION
SELECT 168,13,'Bill Adjustment','Bill Adjustment',1,1    
UNION
SELECT 168,14,'Cash Receipt','Cash Receipt',1,1   
UNION
SELECT 168,15,'Cheque Receipt','Cheque Receipt',1,1   
UNION
SELECT 168,16,'Adjustment','Adjustment',1,1         
UNION
SELECT 168,17,'Balance','Balance',1,1    
GO
IF EXISTS (Select * from Sysobjects Where xtype = 'P' And Name = 'Proc_RptOUTPUTVATSummary')
DROP PROCEDURE Proc_RptOUTPUTVATSummary
GO
--EXEC Proc_RptOUTPUTVATSummary 29,1,0,'CoreStockyTempReport',0,0,1,0
CREATE  PROCEDURE [dbo].[Proc_RptOUTPUTVATSummary]
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
DECLARE @SMId	 	AS	INT
DECLARE @RMId	 	AS	INT
DECLARE @RtrId	 	AS	INT
DECLARE @TransNo	AS	NVARCHAR(100)
DECLARE @EXLFlag	AS 	INT
DECLARE @DispNet    AS  INT
DECLARE @DispBaseTransNo    AS  INT
--select * from reportfilterdt
SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @TransNo =(SELECT TOP 1 SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,195,@Pi_UsrId))
SET @DispNet = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,264,@Pi_UsrId))
SET @DispBaseTransNo = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,273,@Pi_UsrId))
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
Create TABLE #RptOUTPUTVATSummary
(
		InvId 			BIGINT,
		RefNo	  		NVARCHAR(100),	
		BillBookNo	  	NVARCHAR(100),	
		InvDate 		DATETIME,
		BaseTransNo		NVARCHAR(100),	
		RtrId 			INT,
		RtrName			NVARCHAR(100),
		RtrTINNo 		NVARCHAR(100),
		IOTaxType 		NVARCHAR(100),
		TaxPerc 		NVARCHAR(100),
		TaxableAmount 		NUMERIC(38,6),		
		TaxFlag 		INT,
		TaxPercent 		NUMERIC(38,6)
	)
SET @TblName = 'RptOUTPUTVATSummary'
SET @TblStruct = 'InvId 		BIGINT,
		RefNo	  		NVARCHAR(100),		
		BillBookNo	  	NVARCHAR(100),
		InvDate 		DATETIME,	
		BaseTransNo		NVARCHAR(100),	
		RtrId 			INT,
		RtrName			NVARCHAR(100),
		RtrTINNo 		NVARCHAR(100),
		IOTaxType 		NVARCHAR(100),
		TaxPerc 		NVARCHAR(100),
		TaxableAmount 		NUMERIC(38,6),		
		TaxFlag 		INT,
		TaxPercent 		NUMERIC(38,6)'
			
	SET @TblFields = 'InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType,TaxPerc,TaxableAmount,TaxFlag,TaxPercent'
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
	EXEC Proc_IOTaxSummary  @Pi_UsrId
	INSERT INTO #RptOUTPUTVATSummary (InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,IOTaxType,TaxPerc,TaxableAmount,TaxFlag,TaxPercent)
		Select InvId,RefNo,InvDate,T.RtrId,R.RtrName,R.RtrTINNo,IOTaxType,TaxPerc,sum(TaxableAmount),
--		case IOTaxType when 'Sales' then TaxableAmount when 'SalesReturn' then -1 * TaxableAmount end as TaxableAmount ,
		TaxFlag,TaxPerCent From TmpRptIOTaxSummary T,Retailer R
		where T.RtrId = R.RtrId and IOTaxType in ('Sales','SalesReturn')
		AND ( T.SmId = (CASE @SmId WHEN 0 THEN T.SmId ELSE 0 END) OR
			T.SmId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		AND ( T.RmId = (CASE @RmId WHEN 0 THEN T.RmId ELSE 0 END) OR
			T.RmId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
		AND ( T.RtrId = (CASE @RtrId WHEN 0 THEN T.RtrId ELSE 0 END) OR
			T.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		
		AND  (RefNo = (CASE @TransNo WHEN '0' THEN RefNo ELSE '' END) OR
				RefNo in (SELECT SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,195,@Pi_UsrId)))
		AND
		( INVDATE between @FromDate and @ToDate and Userid = @Pi_UsrId)
		Group By InvId,RefNo,InvDate,T.RtrId,R.RtrName,R.RtrTINNo,IOTaxType,TaxPerc,TaxFlag,TaxPerCent
-- Bill book reference and Base transaction no ---
IF EXISTS (SELECT * FROM Configuration WHERE ModuleName='Discount & Tax Collection' AND ModuleId='DISTAXCOLL7' AND Status=1)
	BEGIN 
		UPDATE RPT SET RPT.BillBookNo=isnull(SI.BillBookNo,'') FROM #RptOUTPUTVATSummary RPT INNER JOIN SalesInvoice SI ON RPT.InvId=SI.SalId
		UPDATE RptFormula SET FormulaValue='Bill Book No' WHERE RptId=29 AND Slno=25 AND Formula='Disp_BillBookNo'
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE RptId=29 AND SlNo=3
	END 
ELSE
	BEGIN 
		UPDATE #RptOUTPUTVATSummary SET BillBookNo=''
		UPDATE RptFormula SET FormulaValue='' WHERE RptId=29 AND Slno=25 AND Formula='Disp_BillBookNo'
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE RptId=29 AND SlNo=3
	END 
IF @DispBaseTransNo=1 
	BEGIN 
		UPDATE RPT SET RPT.BaseTransNo=isnull(SI.SalInvNo,'') FROM #RptOUTPUTVATSummary RPT INNER JOIN ReturnHeader RH ON RPT.InvId=RH.ReturnID INNER JOIN SalesInvoice SI ON SI.SalId=RH.SalId AND RH.InvoiceType=1
		UPDATE RPT SET RPT.BaseTransNo=isnull(SI.SalInvNo,'') FROM #RptOUTPUTVATSummary RPT INNER JOIN SalesInvoiceMarketReturn RH ON RPT.InvId=RH.ReturnID INNER JOIN SalesInvoice SI ON SI.SalId=RH.SalId 
		UPDATE RptFormula SET FormulaValue='Base Trans Ref No.' WHERE RptId=29 AND Slno=26 AND Formula='Disp_BaseTransNo'
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE RptId=29 AND SlNo=5
	END 
ELSE
	BEGIN 
		UPDATE #RptOUTPUTVATSummary SET BaseTransNo=''
		UPDATE RptFormula SET FormulaValue='' WHERE RptId=29 AND Slno=26 AND Formula='Disp_BaseTransNo'
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE RptId=29 AND SlNo=5
	END 
-- End here 
--select * from rptselectionhd
	IF LEN(@PurDBName) > 0
	BEGIN
		SET @SSQL = 'INSERT INTO #RptOUTPUTVATSummary ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 	
			+ ' T.RtrId = R.RtrId and IOTaxType in (''Sales'',''SalesReturn'')'
			+ ' WHERE (T.SmId = (CASE ' + CAST(@SmId AS nVarchar(10)) + ' WHEN 0 THEN T.SmId ELSE 0 END) OR ' +
			' T.SmId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '	
			+ '(T.RmId = (CASE ' + CAST(@RmId AS nVarchar(10)) + ' WHEN 0 THEN T.RmId ELSE 0 END) OR ' +
			' T.RmId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+ '(T.RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN T.RtrId ELSE 0 END) OR ' +
			' T.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '		
			+ ' ( INVDATE Between ''' + @FromDate + ''' AND ''' + @ToDate + '''' + ' and UsrId = ' + CAST(@Pi_UsrId AS nVarChar(10)) + ') '
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptOUTPUTVATSummary'
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
		SET @SSQL = 'INSERT INTO #RptOUTPUTVATSummary' +
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
SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptOUTPUTVATSummary
--UPDATE #RptOUTPUTVATSummary SET TaxFlag=0
IF @DispNet=1
BEGIN
	INSERT INTO #RptOUTPUTVATSummary
	SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType,
	'Total Taxable Amount',SUM(TaxableAmount),0,1000.000000
	FROM #RptOUTPUTVATSummary
	WHERE TaxFlag=0
	GROUP BY InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType
	--UNION ALL
    INSERT INTO #RptOUTPUTVATSummary
	SELECT InvId,RefNo,A.BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType,
	'Net Amount',SUM(SalNetAmt),0,2000.000000
	FROM #RptOUTPUTVATSummary A INNER JOIN SalesInvoice B ON A.InvId=B.SalId AND 
	A.RefNo=B.SalInvNo And A.Rtrid = B.Rtrid WHERE TaxFlag=0 AND A.IoTaxType='Sales' AND TaxPerc = 'Total Taxable Amount'
	GROUP BY InvId,RefNo,A.BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType
	--UNION ALL
    INSERT INTO #RptOUTPUTVATSummary
	SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType,
	'Net Amount',-1*SUM(RtnNetAmt),0,2000.000000
	FROM #RptOUTPUTVATSummary A INNER JOIN ReturnHeader B ON A.InvId=B.ReturnId AND 
	A.RefNo=B.ReturnCode And A.Rtrid = B.Rtrid  WHERE TaxFlag=0 AND A.IoTaxType='SalesReturn' AND TaxPerc = 'Total Taxable Amount'
	GROUP BY InvId,RefNo,BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType
END
ELSE
BEGIN
	INSERT INTO #RptOUTPUTVATSummary
	SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType,
	'Total Taxable Amount',SUM(TaxableAmount),0,1000.000000
	FROM #RptOUTPUTVATSummary
	WHERE TaxFlag=0
	GROUP BY InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType
END
INSERT INTO #RptOUTPUTVATSummary
SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType,
'Total Tax Amount',SUM(TaxableAmount),1,1000.000000
FROM #RptOUTPUTVATSummary
WHERE TaxFlag=1
GROUP BY InvId,RefNo,BillBookNo,InvDate,BaseTransNo,RtrId,RtrName,RtrTINNo,IOTaxType
SELECT * FROM #RptOUTPUTVATSummary
SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
		--ORDER BY InvId,TaxFlag ASC
		/***************************************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @InvId BIGINT
		--DECLARE  @RtrId INT
		DECLARE	 @RefNo	NVARCHAR(100)
		DECLARE  @PurRcptRefNo NVARCHAR(50)
		DECLARE	 @TaxPerc 		NVARCHAR(100)
		DECLARE	 @TaxableAmount NUMERIC(38,6)
		DECLARE  @IOTaxType    NVARCHAR(100)
		DECLARE  @SlNo INT		
		DECLARE	 @TaxFlag      INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @TaxPercent NUMERIC(38,6)
		DECLARE  @Name   NVARCHAR(100)
		--DROP TABLE RptOUTPUTVATSummary_Excel
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptOUTPUTVATSummary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptOUTPUTVATSummary_Excel]
		DELETE FROM RptExcelHeaders Where RptId=29 AND SlNo>9
		CREATE TABLE RptOUTPUTVATSummary_Excel (InvId BIGINT,RefNo NVARCHAR(100),BillBookNo	NVARCHAR(100),InvDate DATETIME,BaseTransNo NVARCHAR(100),RtrId INT,RtrName NVARCHAR(100),RtrTINNo NVARCHAR(100),UsrId INT)
		SET @iCnt=10
		DECLARE Column_Cur CURSOR FOR
		SELECT DISTINCT(TaxPerc),TaxPercent,TaxFlag FROM #RptOUTPUTVATSummary ORDER BY TaxPercent ,TaxFlag
		OPEN Column_Cur
			   FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptOUTPUTVATSummary_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
				
					EXEC (@C_SSQL)
				SET @iCnt=@iCnt+1
					FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag
				END
		CLOSE Column_Cur
		DEALLOCATE Column_Cur
		--Insert table values
		DELETE FROM RptOUTPUTVATSummary_Excel
		INSERT INTO RptOUTPUTVATSummary_Excel(InvId,RefNo,BaseTransNo,InvDate,RtrId,RtrName,RtrTINNo,UsrId)
		SELECT DISTINCT InvId,RefNo,BaseTransNo,InvDate,RtrId,RtrName,RtrTINNo,@Pi_UsrId
				FROM #RptOUTPUTVATSummary
		--Select * from RptOUTPUTVATSummary_Excel
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT InvId,RefNo,RtrId,TaxPerc,TaxableAmount FROM #RptOUTPUTVATSummary
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @InvId,@RefNo,@RtrId,@TaxPerc,@TaxableAmount
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptOUTPUTVATSummary_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL+ ' WHERE InvId='+ CAST(@InvId AS VARCHAR(1000))
					+' AND RefNo =''' + CAST(@RefNo AS VARCHAR(1000)) +''' AND  RtrId=' + CAST(@RtrId AS VARCHAR(1000))
					+' AND UsrId='+ CAST(@Pi_UsrId AS NVARCHAR(1000))+''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @InvId,@RefNo,@RtrId,@TaxPerc,@TaxableAmount
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptOUTPUTVATSummary_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptOUTPUTVATSummary_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
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
--***********************************************B&L Integration Script********************************************--
--Select * from Tbl_UploadIntegration order by SequenceNo 
Delete From Tbl_UploadIntegration
GO
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	1,	'Purchase_Order',	'Purchase_Order',	'ETL_Prk_CS2CNPurchaseOrder',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	2,	'PO_Quantity_Split_Up',	'PO_Quantity_Split_Up',	'ETL_Prk_CS2CNPOQuantitySplitUp',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	3,	'Sample_Issue',	'Sample_Issue',	'Cs2Cn_Prk_SampleIssue',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	4,	'Retailer',	'Retailer',	'Cs2Cn_Prk_Retailer',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	5,	'Daily Sales',	'Daily_Sales',	'Cs2Cn_Prk_DailySales',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	6,	'Stock',	'Stock',	'Cs2Cn_Prk_Stock',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	7,	'Sales Return',	'Sales_Return',	'Cs2Cn_Prk_SalesReturn',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	8,	'Purchase Confirmation',	'Purchase_Confirmation',	'Cs2Cn_Prk_PurchaseConfirmation',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	9,	'Purchase Return',	'Purchase_Return',	'Cs2Cn_Prk_PurchaseReturn',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	10,	'Claims',	'Claims',	'Cs2Cn_Prk_ClaimAll',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	11,	'Scheme Utilization',	'Scheme_Utilization',	'Cs2Cn_Prk_SchemeUtilization',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	12,	'Download Tracing',	'DownloadTracing',	'Cs2Cn_Prk_DownLoadTracing',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	13,	'Upload Tracing',	'UploadTracing',	'Cs2Cn_Prk_UpLoadTracing',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	14,	'Daily Retailer Details',	'Daily_Retailer_Details',	'Cs2Cn_Prk_DailyRetailerDetails',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	15,	'Daily Product Details',	'Daily_Product_Details',	'Cs2Cn_Prk_DailyProductDetails',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	16,	'Salesman',	'Salesman',	'Cs2Cn_Prk_Salesman',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	17,	'Route',	'Route',	'Cs2Cn_Prk_Route',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	18,	'Route Coverage Plan',	'Route_Coverage_Plan',	'Cs2Cn_Prk_RouteCoveragePlan',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	19,	'Attendance Register',	'Attendance_Register',	'Cs2Cn_Prk_AttendanceRegister',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	20,	'UDC Details',	'UDC_Details',	'Cs2Cn_Prk_UDCDetails',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	21,	'Retailer Route',	'Retailer_Route',	'Cs2Cn_Prk_RetailerRoute',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	22,	'Scheme Claim Details',	'Scheme_Claim_Details',	'Cs2Cn_Prk_Claim_SchemeDetails',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	23,	'Daily Business Details',	'Daily_Business_Details',	'Cs2Cn_Prk_DailyBusinessDetails',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	24,	'DB Details',	'DB_Details',	'Cs2Cn_Prk_DBDetails',	GetDate())
--Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
--Values(	25,	'ProductWiseStock',	'ProductWiseStock',	'Cs2Cn_Prk_ProductWiseStock',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	1001,	'ReUpload Initiate',	'ReUploadInitiate',	'Cs2Cn_Prk_ReUploadInitiate',	GetDate())
Insert Into Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
Values(	1002,	'Downloaded Details',	'Downloaded_Details',	'Cs2Cn_Prk_DownloadedDetails',	GetDate())
GO

--Select * from Tbl_DownloadIntegration Order By ProcessName
Delete From Tbl_DownloadIntegration
GO
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
Values(	1,	'Hierarchy Level',	'Cn2Cs_Prk_HierarchyLevel',	'Proc_Import_HierarchyLevel',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	2,	'Hierarchy Level Value',	'Cn2Cs_Prk_HierarchyLevelValue',	'Proc_Import_HierarchyLevelValue',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	3,	'Retailer Hierarchy',	'Cn2Cs_Prk_BLRetailerCategoryLevelValue',	'Proc_ImportBLRtrCategoryLevelValue',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	4,	'Retailer Classification',	'Cn2Cs_Prk_BLRetailerValueClass',	'Proc_ImportBLRetailerValueClass',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	5,	'Prefix Master',	'Cn2Cs_Prk_PrefixMaster',	'Proc_Import_PrefixMaster',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	6,	'Retailer Approval',	'Cn2Cs_Prk_RetailerApproval',	'Proc_Import_RetailerApproval',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	7,	'Site_Code',	'ETL_Prk_CN2CSSiteCode',	'Proc_ImportSiteCode',	0,	100,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	8,	'JCCalendar',	'ETL_Prk_BLJCCalendar',	'Proc_ImportBLJCCalendar',	0,	100,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	9,	'UOM',	'Cn2Cs_Prk_BLUOM',	'Proc_ImportBLUOM',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	10,	'Tax Configuration Group Setting',	'Etl_Prk_TaxConfig_GroupSetting',	'Proc_ImportTaxMaster',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	11,	'Tax Settings',	'Etl_Prk_TaxSetting',	'Proc_ImportTaxConfigGroupSetting',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	12,	'Product Hierarchy Change',	'Cn2Cs_Prk_BLProductHiereachyChange',	'Proc_ImportBLProductHiereachyChange',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	13,	'Product',	'Cn2Cs_Prk_BLProduct',	'Proc_ImportBLProduct',	1768,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	14,	'Product Batch',	'Cn2Cs_Prk_ProductBatch',	'Proc_Import_ProductBatch',	7,	200,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	15,	'Product Tax Mapping',	'Etl_Prk_TaxMapping',	'Proc_ImportTaxGrpMapping',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	16,	'Special Rate',	'Cn2Cs_Prk_SpecialRate',	'Proc_Import_SpecialRate',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	17,	'BarCode',	'Cn2CS_Prk_BarCode',	'Proc_ImportBarCode',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	18,	'Stock_Norm',	'ETL_Prk_StockNorm',	'Proc_ImportBLStockNorm',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	19,	'Purchase_Order',	'Cn2Cs_Prk_BLPurchaseOrder',	'Proc_ImportBLPurchaseOrder',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	20,	'Payment_Status',	'ETL_Prk_ChequeBounce',	'Proc_ImportBLChequeBounce',	1179,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	21,	'Payment',	'ETL_Prk_PaymentDetails',	'Proc_ImportBLPaymentDetails',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	22,	'Account_Statement',	'ETL_Prk_ACStatment',	'Proc_ImportBLAcStatement',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	23,	'Claim_Status',	'ETL_Prk_BLClaimSettlement',	'Proc_ImportBLClaimSettlement',	0,	100,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	24,	'Scheme Header Slabs Rules',	'Etl_Prk_SchemeHD_Slabs_Rules',	'Proc_ImportSchemeHD_Slabs_Rules',	0,	100,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	25,	'Scheme Products',	'Etl_Prk_SchemeProducts_Combi',	'Proc_ImportSchemeProducts_Combi',	0,	100,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	26,	'Scheme Attributes',	'Etl_Prk_Scheme_OnAttributes',	'Proc_ImportScheme_OnAttributes',	0,	100,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	27,	'Scheme Free Products',	'Etl_Prk_Scheme_Free_Multi_Products',	'Proc_ImportScheme_Free_Multi_Products',	0,	100,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	28,	'Scheme On Another Product',	'Etl_Prk_Scheme_OnAnotherPrd',	'Proc_ImportScheme_OnAnotherPrd',	0,	100,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	29,	'Scheme Retailer Validation',	'Etl_Prk_Scheme_RetailerLevelValid',	'Proc_ImportScheme_RetailerLevelValid',	0,	100,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	30,	'Purchase',	'Cn2Cs_Prk_BLPurchaseReceipt',	'Proc_ImportBLPurchaseReceipt',	1865,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	31,	'Scheme Master Control',	'Cn2Cs_Prk_NVSchemeMasterControl',	'Proc_ImportNVSchemeMasterControl',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	32,	'Claim Norm',	'Cn2Cs_Prk_ClaimNorm',	'Proc_Import_ClaimNorm',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	33,	'Reason Master',	'Cn2Cs_Prk_ReasonMaster',	'Proc_Import_ReasonMaster',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	34,	'Bulletin Board',	'Cn2Cs_Prk_BulletinBoard',	'Proc_Import_BulletinBoard',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	35,	'ReUpload',	'Cn2Cs_Prk_ReUpload',	'Proc_Import_ReUpload',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	36,	'Configuration',	'Cn2Cs_Prk_Configuration',	'Proc_Import_Configuration',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	37,	'UDC Master',	'Cn2Cs_Prk_UDCMaster',	'Proc_Import_UDCMaster',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	38,	'UDC Details',	'Cn2Cs_Prk_UDCDetails',	'Proc_Import_UDCDetails',	3672,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	39,	'UDC Defaults',	'Cn2Cs_Prk_UDCDefaults',	'Proc_Import_UDCDefaults',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	40,	'Retailer Migration',	'Cn2Cs_Prk_RetailerMigration',	'Proc_Import_RetailerMigration',	0,	500,	GetDate())
Insert Into Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values(	41,	'Scheme Combi Criteria',	'Etl_Prk_Scheme_CombiCriteria',	'Proc_ImportBLSchemeCombiCriteria',	0,	500,	GetDate())
Insert into Tbl_Downloadintegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values( 42,    'SampleReceipt','Cn2Cs_Prk_SampleReceipt','Proc_ImportSampleReceipt',	   0,500,GETDATE())
Insert into Tbl_Downloadintegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values (43,    'Cluster Master','Cn2Cs_Prk_ClusterMaster','Proc_Import_ClusterMaster',0,100,GetDate())
Insert into Tbl_Downloadintegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values (44,    'Cluster Group','Cn2Cs_Prk_ClusterGroup','Proc_Import_ClusterGroup',0,100,GetDate())
Insert into Tbl_Downloadintegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate)
Values (45,    'Cluster Assign Approval','Cn2Cs_Prk_ClusterAssignApproval','Proc_Import_ClusterAssignApproval',0,100,GetDate())
GO
--Select * from CustomUpDownload Order By Module
Delete From CustomUpDownload
GO
Insert Into CustomUpDownload Select	1,	1,	'Purchase_Order',	'Purchase Order',	'Proc_CS2CNPurchaseOrder',	'Proc_ImportCS2CNPurchaseOrder',	'ETL_Prk_CS2CNPurchaseOrder',	'Proc_ValidateCS2CNPurchaseOrder',	'Transaction',	'Upload',	1
Insert Into CustomUpDownload Select	2,	1,	'PO_Quantity_Split_Up',	'PO Quantity Split Up',	'Proc_CS2CNPOQuantitySplitUp',	'Proc_ImportCS2CNPOQuantitySplitUp',	'ETL_Prk_CS2CNPOQuantitySplitUp',	'Proc_ValidateCS2CNPOQuantitySplitUp',	'Transaction',	'Upload',	0
Insert Into CustomUpDownload Select	3,	1,	'Sample_Issue',	'Sample Issue',	'Proc_Cs2Cn_SampleIssue',	'Proc_ImportSampleIssue',	'Cs2Cn_Prk_SampleIssue',	'Proc_ValidateSampleIssue',	'Transaction',	'Upload',	1
Insert Into CustomUpDownload Select	4,	1,	'Retailer',	'Retailer',	'Proc_Cs2Cn_Retailer',	'Proc_ImportRetailer',	'Cs2Cn_Prk_Retailer',	'Proc_CN2CSRetailer',	'Master',	'Upload',	1
Insert Into CustomUpDownload Select	5,	1,	'Daily Sales',	'Daily Sales',	'Proc_BLDailySales',	'Proc_ImportBLDailySales',	'ETL_Prk_BLDailySales',	'Proc_ValidateBLDailySales',	'Transaction',	'Upload',	1
Insert Into CustomUpDownload Select	6,	1,	'Stock',	'Stock',	'Proc_Cs2Cn_Stock',	'Proc_ImportStock',	'Cs2Cn_Prk_Stock',	'Proc_ValidateStock',	'Transaction',	'Upload',	1
Insert Into Customupdownload Select     7,      1,      'Sales Return','Sales Return','Proc_Cs2Cn_SalesReturn','Proc_ImportBLSalesReturn','Cs2Cn_Prk_SalesReturn','Proc_CN2CSBLSalesReturn','Transaction','Upload',1
Insert into customupdownload Select     8,      1,      'Purchase Confirmation','Purchase Confirmation','Proc_Cs2Cn_PurchaseConfirmation','Proc_ImportPurchaseConfirmation','Cs2Cn_Prk_PurchaseConfirmation','Proc_CN2CSBLPurchaseConfirmation','Transaction','Upload',1
Insert Into CustomUpDownload Select	9,	1,	'Purchase Return',	'Purchase Return',	'Proc_Cs2Cn_PurchaseReturn',	'Proc_ImportPurchaseReturn',	'Cs2Cn_Prk_PurchaseReturn',	'Proc_CN2CSPurchaseReturn',	'Transaction',	'Upload',	1
Insert Into CustomUpDownload Select	10,	1,	'Claims',	'Claims',	'Proc_Cs2Cn_ClaimAll',	'Proc_ImportBLClaimAll',	'Cs2Cn_Prk_ClaimAll',	'Proc_Cn2Cs_BLClaimAll',	'Transaction',	'Upload',	1
Insert into Customupdownload Select     11,     1,      'Scheme Utilization','Scheme Utilization','Proc_Cs2Cn_SchemeUtilization','Proc_Import_SchemeUtilization','Cs2Cn_Prk_SchemeUtilization','Proc_Cn2Cs_SchemeUtilization','Transaction','Upload',1
Insert Into CustomUpDownload Select	12,	1,	'Download Tracing',	'Download Tracing',	'Proc_CS2CNDownLoadTracing',	'Proc_ImportDownLoadTracing',	'ETL_PRK_CS2CNDownLoadTracing',	'Proc_Cn2CsDownLoadTracing',	'Master',	'Upload',	1
Insert Into CustomUpDownload Select	13,	1,	'Upload Tracing',	'UploadTracing',	'Proc_CS2CNUpLoadTracing',	'Proc_ImportUpLoadTracing',	'ETL_PRK_CS2CNUpLoadTracing',	'Proc_Cn2CsUpLoadTracing',	'Master',	'Upload',	1
Insert Into CustomUpDownload Select	14,	1,	'Daily Retailer Details',	'Daily Retailer Details',	'Proc_Cs2Cn_DailyRetailerDetails',	'',	'Cs2Cn_Prk_DailyRetailerDetails',	'',	'Master',	'Upload',	1
Insert Into CustomUpDownload Select	15,	1,	'Daily Product Details',	'Daily Product Details',	'Proc_Cs2Cn_DailyProductDetails',	'',	'Cs2Cn_Prk_DailyProductDetails',	'',	'Master',	'Upload',	1
Insert Into CustomUpDownload Select	16,	1,	'Salesman',	'Salesman',	'Proc_Cs2Cn_Salesman',	'Proc_Import_Salesman',	'Cs2Cn_Prk_Salesman',	'Proc_Cn2Cs_Salesman',	'Master',	'Upload',	1
Insert Into CustomUpDownload Select	17,	1,	'Route',	'Route',	'Proc_Cs2Cn_Route',	'Proc_Import_Route',	'Cs2Cn_Prk_Route',	'Proc_Cn2Cs_Route',	'Master',	'Upload',	1
Insert Into CustomUpDownload Select	18,	1,	'Route Coverage Plan',	'Route Coverage Plan',	'Proc_Cs2Cn_RouteCoveragePlan',	'Proc_Import_RouteCoveragePlan',	'Cs2Cn_Prk_RouteCoveragePlan',	'Proc_Cn2Cs_RouteCoveragePlan',	'Master',	'Upload',	1
Insert Into CustomUpDownload Select	19,	1,	'Attendance Register',	'Attendance Register',	'Proc_Cs2Cn_AttendanceRegister',	'Proc_Import_AttendanceRegister',	'Cs2Cn_Prk_AttendanceRegister',	'Proc_Cn2Cs_AttendanceRegister',	'Master',	'Upload',	1
Insert Into CustomUpDownload Select	20,	1,	'UDC Details',	'UDC Details',	'Proc_Cs2Cn_UDCDetails',	'Proc_Import_UDCDetails',	'Cs2Cn_Prk_UDCDetails',	'Proc_Cn2Cs_UDCDetails',	'Master',	'Upload',	1
Insert Into CustomUpDownload Select	21,	1,	'Retailer Route',	'Retailer Route',	'Proc_Cs2Cn_RetailerRoute',	'Proc_Import_RetailerRoute',	'Cs2Cn_Prk_RetailerRoute',	'Proc_Cn2Cs_RetailerRoute',	'Master',	'Upload',	1
Insert Into CustomUpDownload Select	22,	1,	'Scheme Claim Details',	'Scheme Claim Details',	'Proc_Cs2Cn_Dummy',	'Proc_Import_SchemeClaimDetails',	'Cs2Cn_Prk_Claim_SchemeDetails',	'Proc_Cn2Cs_SchemeClaimDetails',	'Transaction',	'Upload',	1
Insert Into CustomUpDownload Select	23,	1,	'Daily Business Details',	'Daily Business Details',	'Proc_Cs2Cn_DailyBusinessDetails',	'Proc_Import_DailyBusinessDetails',	'Cs2Cn_Prk_DailyBusinessDetails',	'Proc_Cn2Cs_DailyBusinessDetails',	'Master',	'Upload',	1
Insert Into CustomUpDownload Select	24,	1,	'DB Details',	'DB Details',	'Proc_Cs2Cn_DBDetails',	'Proc_Import_DBDetails',	'Cs2Cn_Prk_DBDetails',	'Proc_Cn2Cs_DBDetails',	'Master',	'Upload',	1
--Insert Into CustomUpDownload Select	25,	1,	'ProductWiseStock',	'ProductWiseStock',	'Proc_Cs2Cn_ProductWiseStock',	'Proc_Import_ProductWiseStock',	'Cs2Cn_Prk_ProductWiseStock',	'Proc_Cn2Cs_ProductWiseStock',	'Master',	'Upload',	1
Insert into Customupdownload Select     26,     1,      'Upload Record Check','UploadRecordCheck','Proc_Cs2Cn_UploadRecordCheck','','Cs2Cn_Prk_UploadRecordCheck','','Transaction','Upload',1
Insert Into CustomUpDownload Select	27,	1,	'ReUpload Initiate',	'ReUploadInitiate',	'Proc_Cs2Cn_ReUploadInitiate',	'',	'Cs2Cn_Prk_ReUploadInitiate',	'',	'Transaction',	'Upload',	1
Insert Into CustomUpDownload Select	28,	1,	'Hierarchy Level',	'Hieararchy Level',	'Proc_Cs2Cn_HierarchyLevel',	'Proc_Import_HierarchyLevel',	'Cn2Cs_Prk_HierarchyLevel',	'Proc_Cn2Cs_HierarchyLevel',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	29,	1,	'Hierarchy Level Value',	'Hieararchy Level Value',	'Proc_Cs2Cn_HierarchyLevelValue',	'Proc_Import_HierarchyLevelValue',	'Cn2Cs_Prk_HierarchyLevelValue',	'Proc_Cn2Cs_HierarchyLevelValue',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	30,	1,	'Retailer Hierarchy',	'Retailer Hierarchy',	'Proc_CS2CNBLRetailerCategoryLevelValue',	'Proc_ImportBLRtrCategoryLevelValue',	'Cn2Cs_Prk_BLRetailerCategoryLevelValue',	'Proc_Cn2Cs_BLRetailerCategoryLevelValue',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	31,	1,	'Retailer Classification',	'Retailer Classification',	'Proc_CS2CNBLRetailerValueClass',	'Proc_ImportBLRetailerValueClass',	'Cn2Cs_Prk_BLRetailerValueClass',	'Proc_Cn2Cs_BLRetailerValueClass',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	32,	1,	'Prefix Master',	'Prefix Master',	'Proc_Cs2Cn_PrefixMaster',	'Proc_Import_PrefixMaster',	'Cn2Cs_Prk_PrefixMaster',	'Proc_Cn2Cs_PrefixMaster',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	33,	1,	'Retailer Approval',	'Retailer Approval',	'Proc_Cs2Cn_RetailerApproval',	'Proc_Import_RetailerApproval',	'Cn2Cs_Prk_RetailerApproval',	'Proc_Cn2Cs_RetailerApproval',	'Master',	'Download',	0
Insert Into CustomUpDownload Select	34,	1,	'Site_Code',	'Site Code',	'Proc_CS2CNSiteCode',	'Proc_ImportSiteCode',	'ETL_Prk_CN2CSSiteCode',	'Proc_ValidateSiteCode',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	35,	1,	'JCCalendar',	'JCCalendar',	'Proc_CS2CNJCCalendar',	'Proc_ImportBLJCCalendar',	'ETL_Prk_BLJCCalendar',	'Proc_BLValidateJCCalendar',	'Transaction',	'Download',	1
Insert Into CustomUpDownload Select	36,	1,	'UOM',	'UOM',	'Proc_CS2CNBLUOM',	'Proc_ImportBLUOM',	'Cn2Cs_Prk_BLUOM',	'Proc_Cn2Cs_BLUOM',	'Transaction',	'Download',	1
Insert Into CustomUpDownload Select	37,	1,	'Tax Configuration Group Setting',	'Tax Configuration Group Setting',	'Proc_ValidateTaxConfig_Group',	'Proc_ImportTaxMaster',	'Etl_Prk_TaxConfig_GroupSetting',	'Proc_ValidateTaxConfig_Group',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	38,	1,	'Tax Settings',	'Tax Settings',	'Proc_CN2CS_TaxSetting',	'Proc_ImportTaxConfigGroupSetting',	'Etl_Prk_TaxSetting',	'Proc_CN2CS_TaxSetting',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	39,	1,	'Product Hierarchy Change',	'Product Hierarchy Change',	'Proc_CS2CNBLProductHierarchyChange',	'Proc_ImportBLProductHiereachyChange',	'Cn2Cs_Prk_BLProductHiereachyChange',	'Proc_Cn2Cs_BLProductHiereachyChange',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	40,	1,	'Product',	'Product',	'Proc_CS2CNBLProduct',	'Proc_ImportBLProduct',	'Cn2Cs_Prk_BLProduct',	'Proc_Cn2Cs_BLProduct',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	41,	1,	'Product Batch',	'Product Batch',	'Proc_CS2CNBLProductBatch',	'Proc_ImportBLProductBatch',	'Cn2Cs_Prk_BLProductBatch',	'Proc_Cn2Cs_BLProductBatch',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	42,	1,	'Special Rate',	'Special Rate',	'Proc_CS2CNSpecialRate',	'Proc_ImportBLSpecialRate',	'ETL_Prk_SpecialRate',	'Proc_ValidateSpecialRate',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	43,	1,	'BarCode',	'BarCode',	'Proc_ImportBarCode',	'Proc_ImportBarCode',	'Cn2CS_Prk_BarCode',	'Proc_Cn2Cs_BarCode',	'MASTER',	'Download',	1
Insert Into CustomUpDownload Select	44,	1,	'Stock_Norm',	'Stock Norm',	'Proc_CS2CNStockNorm',	'Proc_ImportBLStockNorm',	'ETL_Prk_StockNorm',	'Proc_ValidateStockNorm',	'Report',	'Download',	1
Insert Into CustomUpDownload Select	45,	1,	'Purchase_Order',	'Purchase Order',	'Proc_CS2CNBLPurchaseOrder',	'Proc_ImportBLPurchaseOrder',	'Cn2Cs_Prk_BLPurchaseOrder',	'Proc_Cn2Cs_BLPurchaseOrder',	'Transaction',	'Download',	1
Insert Into CustomUpDownload Select	46,	1,	'Payment_Status',	'Payment Status',	'Proc_CS2CNChequeBounce',	'Proc_ImportBLChequeBounce',	'ETL_Prk_ChequeBounce',	'Proc_ValidateChequeBounce',	'Transaction',	'Download',	0
Insert Into CustomUpDownload Select	47,	1,	'Payment',	'Payment',	'Proc_CS2CNPaymentDetails',	'Proc_ImportBLPaymentDetails',	'ETL_Prk_PaymentDetails',	'Proc_ValidatePaymentDetails',	'Transaction',	'Download',	0
Insert Into CustomUpDownload Select	48,	1,	'Account_Statement',	'Account Statement',	'Proc_CS2CNACStatement',	'Proc_ImportBLAcStatement',	'ETL_Prk_ACStatment',	'Proc_ValidateAcStatment',	'Report',	'Download',	1
Insert Into CustomUpDownload Select	49,	1,	'Claim_Status',	'Claim Status',	'Proc_CS2CNClaimSettlement',	'Proc_ImportBLClaimSettlement',	'ETL_Prk_BLClaimSettlement',	'Proc_BLValidateClaimSettlement',	'Transaction',	'Download',	1
Insert Into Customupdownload Select     50,	1,	'Scheme',	'Scheme Master',	'Proc_CS2CNBLSchemeMaster',	'Proc_ImportBLSchemeMaster',	'Etl_Prk_SchemeHD_Slabs_Rules',	'Proc_CN2CS_BLSchemeMaster',	'Transaction',	'Download',	1
Insert Into Customupdownload Select     51,	2,	'Scheme',	'Scheme Attributes',	'Proc_CS2CNBLSchemeAttributes',	'Proc_ImportBLSchemeAttributes',	'Etl_Prk_Scheme_OnAttributes',	'Proc_CN2CS_BLSchemeAttributes',	'Transaction',	'Download',	1
Insert Into Customupdownload Select     52,	3,	'Scheme',	'Scheme Products',	'Proc_CS2CNBLSchemeProducts',	'Proc_ImportBLSchemeProducts',	'Etl_Prk_SchemeProducts_Combi',	'Proc_CN2CS_BLSchemeProducts',	'Transaction',	'Download',	1
Insert Into Customupdownload Select     53,	4,	'Scheme',	'Scheme Slabs',	'Proc_CS2CNBLSchemeSlab',	'Proc_ImportBLSchemeSlab',	'Etl_Prk_SchemeHD_Slabs_Rules',	'Proc_CN2CS_BLSchemeSlab',	'Transaction',	'Download',	1
Insert Into Customupdownload Select     54,	5,	'Scheme',	'Scheme Rule Setting',	'Proc_CS2CNBLSchemeRulesetting',	'Proc_ImportBLSchemeRulesetting',	'Etl_Prk_SchemeHD_Slabs_Rules',	'Proc_CN2CS_BLSchemeRulesetting',	'Transaction',	'Download',	0
Insert Into Customupdownload Select     55,	6,	'Scheme',	'Scheme Free Products',	'Proc_CS2CNBLSchemeFreeProducts',	'Proc_ImportBLSchemeFreeProducts',	'Etl_Prk_Scheme_Free_Multi_Products',	'Proc_CN2CS_BLSchemeFreeProducts',	'Transaction',	'Download',	0
Insert Into Customupdownload Select     56,	7,	'Scheme',	'Scheme Combi Products',	'Proc_CS2CNBLSchemeCombiPrd',	'Proc_ImportBLSchemeCombiPrd',	'Etl_Prk_SchemeProducts_Combi',	'Proc_CN2CS_BLSchemeCombiPrd',	'Transaction',	'Download',	0
Insert Into Customupdownload Select     57,	8,	'Scheme',	'Scheme On Another Product',	'Proc_CS2CNBLSchemeOnAnotherPrd',	'Proc_ImportBLSchemeOnAnotherPrd',	'Etl_Prk_Scheme_OnAnotherPrd',	'Proc_CN2CS_BLSchemeOnAnotherPrd',	'Transaction',	'Download',	0
Insert Into CustomUpDownload Select	58,	1,	'Purchase',	'Purchase',	'Proc_CS2CNBLPurchaseReceipt',	'Proc_ImportBLPurchaseReceipt',	'Cn2Cs_Prk_BLPurchaseReceipt',	'Proc_Cn2Cs_PurchaseReceipt',	'Transaction',	'Download',	1
Insert Into CustomUpDownload Select	59,	1,	'Scheme Master Control',	'Scheme Master Control',	'Proc_CS2CNNVSchemeMasterControl',	'Proc_ImportNVSchemeMasterControl',	'Cn2Cs_Prk_NVSchemeMasterControl',	'Proc_Cn2Cs_NVSchemeMasterControl',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	60,	1,	'Claim Norm',	'Claim Norm ',	'Proc_Cs2Cn_ClaimNorm',	'Proc_Import_ClaimNorm',	'Cn2Cs_Prk_ClaimNorm',	'Proc_Cn2Cs_ClaimNorm',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	61,	1,	'Reason Master',	'Reason Master',	'Proc_Cs2Cn_ReasonMaster',	'Proc_Import_ReasonMaster',	'Cn2Cs_Prk_ReasonMaster',	'Proc_Cn2Cs_ReasonMaster',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	62,	1,	'Bulletin Board',	'BulletinBoard',	'Proc_CS2CNBulletingBoard',	'Proc_ImportBulletingBoard',	'Cn2Cs_Prk_BulletingBoard',	'Proc_Cn2Cs_IntegrationHouseKeeping',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	63,	1,	'ReUpload',	'ReUpload',	'Proc_Cs2Cn_ReUpload',	'Proc_Import_ReUpload',	'Cn2Cs_Prk_ReUpload',	'Proc_Cn2Cs_ReUpload',	'Transaction',	'Download',	1
Insert Into CustomUpDownload Select	64,	1,	'Configuration',	'Configuration',	'Proc_Cs2Cn_Configuration',	'Proc_Import_Configuration',	'Cn2Cs_Prk_Configuration',	'Proc_Cn2Cs_Configuration',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	65,	1,	'UDC Master',	'UDC Master',	'Proc_Cs2Cn_UDCMaster',	'Proc_Import_UDCMaster',	'Cn2Cs_Prk_UDCMaster',	'Proc_Cn2Cs_UDCMaster',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	66,	1,	'UDC Details',	'UDC Details',	'Proc_Cs2Cn_UDCDetailss',	'Proc_Import_UDCDetails',	'Cn2Cs_Prk_UDCDetails',	'Proc_Cn2Cs_UDCDetails',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	67,	1,	'UDC Defaults',	'UDC Defaults',	'Proc_Cs2Cn_UDCDefaults',	'Proc_Import_UDCDefaults',	'Cn2Cs_Prk_UDCDefaults',	'Proc_Cn2Cs_UDCDefaults',	'Master',	'Download',	1
Insert Into CustomUpDownload Select	68,	1,	'Retailer Migration',	'Retailer Migration',	'Proc_Cs2Cn_RetailerMigration',	'Proc_Import_RetailerMigration',	'Cn2Cs_Prk_RetailerMigration',	'Proc_Cn2Cs_RetailerMigration',	'Master',	'Download',	1
Insert Into Customupdownload Select     69,	9,	'Scheme',	'Scheme Combi Criteria',	'Proc_CS2CNBLSchemeCombiPrd',	'Proc_ImportBLSchemeCombiPrd',	'Etl_Prk_SchemeProducts_Combi',	'Proc_CN2CS_BLSchemeCombiPrd',	'Transaction',	'Download',	0
Insert into CustomUpdownload Select     70,     1,      'Sample Receipt','Sample Receipt','','Proc_ImportSampleReceipt','Cn2Cs_Prk_SampleReceipt','Proc_Cn2Cs_SampleReceipt','Transaction','Download',1
Insert Into CustomUpdownload Select     71,     1,      'Cluster Master','Cluster Master','Proc_Cs2Cn_ClusterMaster','Proc_Import_ClusterMaster','Cn2Cs_Prk_ClusterMaster','Proc_Cn2Cs_ClusterMaster','Master','Download',1
Insert Into CustomUpdownload Select     72,     1,      'Cluster Group','Cluster Group','Proc_Cs2Cn_ClusterGroup','Proc_Import_ClusterGroup','Cn2Cs_Prk_ClusterGroup','Proc_Cn2Cs_ClusterGroup','Master','Download',1
Insert Into CustomUpdownload Select     73,     1,      'Cluster Assign Approval','Cluster Assign Approval','Proc_Cs2Cn_ClusterAssignApproval','Proc_Import_ClusterAssignApproval','Cn2Cs_Prk_ClusterAssignApproval','Proc_Cn2Cs_ClusterAssignApproval','Master','Download',1
--Select * from CustomUpDownloadcount order by Module
Delete From CustomUpDownloadcount 
GO
Insert Into Customupdownloadcount Select	1,	1,	'Sample_Issue',	'Sample Issue',	'Cs2Cn_Prk_SampleIssue',	'Cs2Cn_Prk_SampleIssue',	'',	'',	'',	'Upload',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	2,	1,	'Retailer',	'Retailer',	'Cs2Cn_Prk_Retailer',	'Cs2Cn_Prk_Retailer',	'',	'',	'',	'Upload',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	3,	1,	'Daily Sales',	'Daily Sales',	'Cs2Cn_Prk_DailySales',	'Cs2Cn_Prk_DailySales',	'',	'',	'',	'Upload',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	4,	1,	'Stock',	'Stock',	'Cs2Cn_Prk_Stock',	'Cs2Cn_Prk_Stock',	'',	'',	'',	'Upload',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	5,	1,	'Sales Return',	'Sales Return',	'Cs2Cn_Prk_SalesReturn',	'Cs2Cn_Prk_SalesReturn',	'',	'',	'',	'Upload',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	6,	1,	'Purchase Confirmation',	'Purchase Confirmation',	'Cs2Cn_Prk_PurchaseConfirmation',	'Cs2Cn_Prk_PurchaseConfirmation',	'',	'',	'',	'Upload',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	7,	1,	'Purchase Return',	'Purchase Return',	'Cs2Cn_Prk_PurchaseReturn',	'Cs2Cn_Prk_PurchaseReturn',	'',	'',	'',	'Upload',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	8,	1,	'Claims',	'Claims',	'Cs2Cn_Prk_ClaimAll',	'Cs2Cn_Prk_ClaimAll',	'',	'',	'',	'Upload',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	9,	1,	'Scheme Utilization',	'Scheme Utilization',	'Cs2Cn_Prk_SchemeUtilizationDetails',	'Cs2Cn_Prk_SchemeUtilizationDetails',	'',	'',	'',	'Upload',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	10,	1,	'Download Tracing',	'Download Tracing',	'ETL_PRK_CS2CNDownLoadTracing',	'ETL_PRK_CS2CNDownLoadTracing',	'',	'',	'',	'Upload',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	11,	1,	'Upload Tracing',	'Upload Tracing',	'ETL_PRK_CS2CNUpLoadTracing',	'ETL_PRK_CS2CNUpLoadTracing',	'',	'',	'',	'Upload',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	12,	1,	'ReUpload Initiate',	'ReUpload Initiate',	'Cs2Cn_Prk_ReUploadInitiate',	'Cs2Cn_Prk_ReUploadInitiate',	'',	'',	'',	'Upload',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	13,	1,	'Hierarchy Level',	'Hierarchy Level',	'Cn2Cs_Prk_HierarchyLevel',	'Cn2Cs_Prk_HierarchyLevel',	'DownLoadFlag',	'',	'',	'Download',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	14,	1,	'Hierarchy Level Value',	'Hierarchy Level Value',	'Cn2Cs_Prk_HierarchyLevelValue',	'Cn2Cs_Prk_HierarchyLevelValue',	'DownLoadFlag',	'',	'',	'Download',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	15,	1,	'Retailer Hierarchy',	'Retailer Hierarchy',	'Cn2Cs_Prk_BLRetailerCategoryLevelValue',	'RetailerCategory',	'CtgMainId',	'',	'',	'Download',	29,	29,	29,	29,	0,	'SELECT CtgCode AS [Category Code],CtgName AS [Category Name] FROM RetailerCategory WHERE CtgMainId>OldMax'
Insert Into Customupdownloadcount Select	16,	1,	'Retailer Classification',	'Retailer Classification',	'Cn2Cs_Prk_BLRetailerValueClass',	'RetailerValueClass',	'RtrClassId',	'',	'',	'Download',	177,	104,	177,	104,	0,	'SELECT ValueClassCode AS [Class Code],ValueClassName AS [Class Name] FROM RetailerValueClass WHERE RtrClassId>OldMax'
Insert Into Customupdownloadcount Select	17,	1,	'Prefix Master',	'Prefix Master',	'Cn2Cs_Prk_PrefixMaster',	'Cn2Cs_Prk_PrefixMaster',	'DownLoadFlag',	'',	'',	'Download',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	18,	1,	'Retailer Approval',	'Retailer Approval',	'Cn2Cs_Prk_RetailerApproval',	'Cn2Cs_Prk_RetailerApproval',	'DownLoadFlag',	'',	'',	'Download',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	19,	1,	'UOM',	'UOM',	'Cn2Cs_Prk_BLUOM',	'UOMMaster',	'UOMId',	'',	'',	'Download',	5,	5,	5,	5,	0,	'SELECT UomCode AS [UOM Code],UomDescription AS [UOM Desc] FROM UOMMaster WHERE UomId>OldMax'
Insert Into Customupdownloadcount Select	20,	1,	'Tax Configuration Group Setting',	'Tax Configuration Group Setting',	'Etl_Prk_TaxConfig_GroupSetting',	'TaxConfiguration',	'TaxId',	'',	'',	'Download',	4,	4,	4,	4,	0,	'SELECT TaxCode AS [Tax Code],TaxName AS [Tax Name] FROM TaxConfiguration WHERE TaxId>OldMax'
Insert Into Customupdownloadcount Select	21,	1,	'Tax Settings',	'Tax Settings',	'Etl_Prk_TaxSetting',	'Etl_Prk_TaxSetting',	'DownLoadFlag',	'',	'',	'Download',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	22,	1,	'Product Hierarchy Change',	'Product Hierarchy Change',	'Cn2Cs_Prk_BLProductHiereachyChange',	'Cn2Cs_Prk_BLProductHiereachyChange',	'DownLoadFlag',	'',	'',	'Download',	0,	0,	0,	0,	0,	'SELECT BusinessCode AS [Business Code],CategoryCode AS [Category Code] FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag=''Y'''
Insert Into Customupdownloadcount Select	23,	1,	'Product',	'Product',	'Cn2Cs_Prk_Product',	'Product',	'PrdId',	'',	'',	'Download',	332,	332,	332,	332,	0,	'SELECT PrdCCode AS [Product Code],PrdName AS [Product Name] FROM Product WHERE PrdId>OldMax'
Insert Into Customupdownloadcount Select	24,	1,	'Product Batch',	'Product Batch',	'Cn2Cs_Prk_ProductBatch',	'ProductBatch',	'PrdBatId',	'',	'',	'Download',	6178,	5434,	6182,	5438,	4,	'SELECT PrdCCode AS [Product Code],PrdBatCode AS [Batch Code] FROM ProductBatch PB,Product P   WHERE P.PrdId=PB.PrdId AND PrdBatId>OldMax'
Insert Into Customupdownloadcount Select	25,	1,	'Special Rate',	'Special Rate',	'Cn2Cs_Prk_SpecialRate',	'Cn2Cs_Prk_SpecialRate',	'DownLoadFlag',	'',	'',	'Download',	0,	0,	0,	0,	0,	'SELECT CtgCode AS [Hierarchy],PrdCCode AS [Product Company Code] FROM Cn2Cs_Prk_SpecialRate WHERE DownLoadFlag=''Y'''
Insert Into Customupdownloadcount Select	26,	1,	'Purchase_Order',	'Purchase Order',	'Cn2Cs_Prk_BLPurchaseOrder',	'Cn2Cs_Prk_BLPurchaseOrder',	'DownLoadFlag',	'',	'PORefNo',	'Download',	0,	0,	'Y',	2,	2,	''
Insert Into CustomupdownloadCount Select 	27,	1,	'Scheme',	'Scheme Master',	'Etl_Prk_SchemeHD_Slabs_Rules',	'SchemeMaster',	'SchId',	'',	'',	'Download',	190,	190,	190,	190,	0,	'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax'
Insert Into CustomupdownloadCount Select 	28,	2,	'Scheme',	'Scheme Attributes',	'Etl_Prk_Scheme_OnAttributes',	'SchemeMaster',	'SchId',	'',	'',	'Download',	190,	190,	190,	190,	0,	'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax'
Insert Into CustomupdownloadCount Select 	29,	3,	'Scheme',	'Scheme Products',	'Etl_Prk_SchemeProducts_Combi',	'SchemeMaster',	'SchId',	'',	'',	'Download',	190,	190,	190,	190,	0,	'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax'
Insert Into CustomupdownloadCount Select 	30,	4,	'Scheme',	'Scheme Slabs',	'Etl_Prk_SchemeHD_Slabs_Rules',	'SchemeMaster',	'SchId',	'',	'',	'Download',	190,	190,	190,	190,	0,	'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax'
Insert Into CustomupdownloadCount Select 	31,	5,	'Scheme',	'Scheme Rule Setting',	'Etl_Prk_SchemeHD_Slabs_Rules',	'SchemeMaster',	'SchId',	'',	'',	'Download',	190,	190,	190,	190,	0,	'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax'
Insert Into CustomupdownloadCount Select 	32,	6,	'Scheme',	'Scheme Free Products',	'Etl_Prk_Scheme_Free_Multi_Products',	'SchemeMaster',	'SchId',	'',	'',	'Download',	190,	190,	190,	190,	0,	'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax'
Insert Into CustomupdownloadCount Select 	33,	7,	'Scheme',	'Scheme Combi Products',	'Etl_Prk_SchemeProducts_Combi',	'SchemeMaster',	'SchId',	'',	'',	'Download',	190,	190,	190,	190,	0,	'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax'
Insert Into CustomupdownloadCount Select 	34,	8,	'Scheme',	'Scheme On Another Product',	'Etl_Prk_Scheme_OnAnotherPrd',	'SchemeMaster',	'SchId',	'',	'',	'Download',	190,	190,	190,	190,	0,	'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax'
Insert Into Customupdownloadcount Select	35,	1,	'Purchase',	'Purchase',	'Cn2Cs_Prk_BLPurchaseReceipt',	'ETLTempPurchaseReceipt',	'CmpInvNo',	'',	'DownLoadStatus=0',	'Download',	0,	0,	528097726,	1,	1,	'SELECT CmpInvNo AS [Invoice No],InvDate AS [Invoice Date] FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0'
Insert Into Customupdownloadcount Select	36,	1,	'Scheme Master Control',	'Scheme Master Control',	'Cn2Cs_Prk_NVSchemeMasterControl',	'Cn2Cs_Prk_NVSchemeMasterControl',	'DownLoadFlag',	'',	'',	'Download',	0,	0,	0,	0,	0,	'SELECT CmpSchCode AS [Scheme Code],Description FROM Cn2Cs_Prk_NVSchemeMasterControl WHERE DownLoadFlag=''Y'''
Insert Into Customupdownloadcount Select	37,	1,	'Claim Norm',	'Claim Norm',	'Cn2Cs_Prk_ClaimNorm',	'Cn2Cs_Prk_ClaimNorm',	'DownLoadFlag',	'',	'',	'Download',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	38,	1,	'Reason Master',	'Reason Master',	'Cn2Cs_Prk_ReasonMaster',	'ReasonMaster',	'ReasonId',	'',	'',	'Download',	12,	12,	12,	12,	0,	'SELECT ReasonCode AS [Reason Code],Description FROM ReasonMaster WHERE ReasonId>OldMax'
Insert Into Customupdownloadcount Select	39,	1,	'Bulletin Board',	'Bulletin Board',	'Cn2Cs_Prk_BulletingBoard',	'Cn2Cs_Prk_BulletingBoard',	'DownLoadFlag',	'',	'',	'Download',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	40,	1,	'ReUpload',	'ReUpload',	'Cn2Cs_Prk_ReUpload',	'Cn2Cs_Prk_ReUpload',	'DownLoadFlag',	'',	'',	'Download',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	41,	1,	'Configuration',	'Configuration',	'Cn2Cs_Prk_Configuration',	'Cn2Cs_Prk_Configuration',	'DownLoadFlag',	'',	'',	'Download',	0,	0,	0,	0,	0,	''
Insert Into Customupdownloadcount Select	42,	1,	'UDC Master',	'UDC Master',	'Cn2Cs_Prk_UDCMaster',	'UDCMaster',	'UDCMAsterId',	'',	'',	'Download',	15,	13,	15,	13,	0,	'SELECT UH.MasterName AS [Master Name],UM.ColumnName AS [Column Name] FROM UDCMaster UM,UDCHd UH WHERE UM.MasterId=UM.MasterId AND UM.UdcMasterId>OldMax'
Insert Into CustomupdownloadCount Select 	43,	9,	'Scheme',	'Scheme Combi Criteria',	'Etl_Prk_SchemeProducts_Combi',	'SchemeMaster',	'SchId',	'',	'',	'Download',	35,	35,	35,	35,	0,	'SELECT SchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax'
Insert into Customupdownloadcount Select        45,     1,      'Cluster Master','Cluster Master','Cn2Cs_Prk_ClusterMaster','ClusterMaster','ClusterId','','','Download',	0,	0,	0,	0,	0,	'SELECT ClusterCode AS [Cluster Code],ClusterName AS [Cluster Name] FROM ClusterMaster WHERE ClusterId>OldMax'
Insert into Customupdownloadcount Select        46,     1,      'Cluster Group','Cluster Group','Cn2Cs_Prk_ClusterGroup','ClusterGroupMaster','ClsGroupId','','','Download',	0,	0,	0,	0,	0,	'SELECT ClsGroupCode AS [Cluster Group Code],ClsGroupName AS [Cluster Group Name] FROM ClusterGroupMaster WHERE ClsGroupId>OldMax'
Insert into Customupdownloadcount Select        47,     1,      'Cluster Assign Approval','Cluster Assign Approval','Cn2Cs_Prk_ClusterAssignApproval','Cn2Cs_Prk_ClusterAssignApproval','DownLoadFlag','','','Download',0,	0,	0,	0,	0,''
GO
IF EXISTS (Select * from Sysobjects Where Xtype= 'U' And Name = 'ETL_Prk_CS2CNBLRetailer')
DROP TABLE ETL_Prk_CS2CNBLRetailer
GO
CREATE TABLE [dbo].[ETL_Prk_CS2CNBLRetailer](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId] [int] NULL,
	[RtrCde] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrNm] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrChannelCde] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrGroupCde] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrClassCde] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KeyAccount] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RelationStatus] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrRegDate] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevel] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevelValue] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [tinyint] NULL,
    [Mode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
IF EXISTS (Select * from Sysobjects Where Xtype= 'P' And Name = 'Proc_CS2CN_BLPurchaseConfirmation')
DROP PROCEDURE Proc_CS2CN_BLPurchaseConfirmation
GO
CREATE PROCEDURE [dbo].[Proc_CS2CN_BLPurchaseConfirmation]
(
	@Po_ErrNo	INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE: Proc_CS2CNPurchaseConfirmation
* PURPOSE: Extract Purchase Confirmation Details from CoreStocky to Console
* NOTES:
* CREATED: JayaKumar.N 15-12-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
    SET @Po_ErrNo = 0
	BEGIN TRAN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DELETE FROM ETL_Prk_CS2CNBLPurchaseConfirmation WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where procId = 3
	INSERT INTO ETL_Prk_CS2CNBLPurchaseConfirmation
	(
		DistCode ,
		ComInvNo ,
		GrnNo ,
		GrnRcvDt ,
		ProdCode ,
		PrdBatCde ,
		GrnQtyRcv ,
		GRNDBRSHTQTY ,
		GRNDBRDMGQTY ,
		GRNDBREXCESSQTY ,
		GRNDREFUSESALE ,
		UploadFlag
	)
	SELECT
		@DistCode ,
		PR.CmpInvNo AS ComInvNo ,
		PR.PurRcptRefNo AS GrnNo,
		PR.GoodsRcvdDate AS GrnRcvDt ,
		P.PrdCCode AS ProdCode ,
		PB.CmpBatCode AS PrdBatCde ,
		PRP.RcvdGoodBaseQty AS GrnQtyRcv ,
		PRP.ShrtBaseQty AS GRNDBRSHTQTY ,
		PRP.UnSalBaseQty AS GRNDBRDMGQTY ,
		CASE PRP.RefuseSale WHEN 0 THEN ExsBaseQty ELSE 0 END AS GRNDBREXCESSQTY ,
		CASE PRP.RefuseSale WHEN 1 THEN ExsBaseQty ELSE 0 END AS GRNDREFUSESALE ,
		'N'					
	FROM
		PurchaseReceipt PR , 		
		PurchaseReceiptProduct PRP ,
		Product P ,
		ProductBatch PB
	WHERE
		PR.PurRcptId = PRP.PurRcptId AND
		PR.Status = 1 AND
		PR.CmpId = @CmpID AND
		P.PrdId = PB.PrdId AND
		P.PrdId = PRP.PrdId AND
		PB.PrdBatId = PRP.PrdBatId AND
		PR.Upload=0
		--PR.GoodsRcvdDate >= @ChkDate
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),
		ProcDate = CONVERT(nVarChar(10),GetDate(),121)
		Where procId = 3
	UPDATE PurchaseReceipt SET Upload=1 WHERE Upload=0 AND PurRcptRefNo IN (SELECT DISTINCT
		GrnNo FROM ETL_Prk_CS2CNBLPurchaseConfirmation WHERE UploadFlag = 'N')
	COMMIT TRAN
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype= 'P' And Name = 'Proc_CS2CNDownLoadTracing')
DROP PROCEDURE Proc_CS2CNDownLoadTracing
GO
CREATE PROCEDURE [dbo].[Proc_CS2CNDownLoadTracing]
(
	@Po_ErrNo INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE: Proc_CS2CNDownLoadTracing
* PURPOSE: Extract Download Tracing details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R	 30-06-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
    SET @Po_ErrNo = 0
	BEGIN TRAN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	DELETE FROM ETL_PRK_CS2CNDownLoadTracing WHERE UploadFlag = 'Y'
	SELECT @DistCode = DistributorCode FROM Distributor
	
	INSERT INTO ETL_PRK_CS2CNDownLoadTracing
	(
			[DistCode],
			[ProcessName],
			[TotRowCount],
			[Process1],
			[Process2],
			[Process3],
			[Process4],
			[Process5],
			[Process6],
			[Process7],
			[Process8],
			[Process9],
			[ProcessPatch],
			[Date],
			[UploadFlag]
	)
	SELECT @DistCode,ProcessName,TotRowCount,Process1,Process2,Process3,Process4,
			Process5,Process6,Process7,Process8,Process9,ProcessPatch,Date,'N' AS UploadFlag
			FROM CS2Console_DownLoadTracing WITH (NOLOCK)
			WHERE UploadFlag='N'
	UPDATE CS2Console_DownLoadTracing SET UploadFlag='Y' WHERE UploadFlag='N'
	
	COMMIT TRAN
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype= 'P' And Name = 'Proc_CS2CNUpLoadTracing')
DROP PROCEDURE Proc_CS2CNUpLoadTracing
GO
CREATE PROCEDURE [dbo].[Proc_CS2CNUpLoadTracing]
(
	@Po_ErrNo INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE: Proc_CS2CNUpLoadTracing
* PURPOSE: Extract Upload Tracing details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R	 30-06-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
    SET @Po_ErrNo = 0   
	BEGIN TRAN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	DELETE FROM ETL_PRK_CS2CNUpLoadTracing WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor
	
	INSERT INTO ETL_PRK_CS2CNUpLoadTracing
	(
			[DistCode],
			[ProcessName],
			[Process1],
			[Process2],
			[Process3],
			[Process4],
			[Process5],
			[ProcessPatch],
			[Date],
			[UploadFlag]
	)
	SELECT @DistCode,ProcessName,Process1,Process2,Process3,Process4,Process5,
			ProcessPatch,Date,'N' AS UploadFlag
			FROM CS2Console_UpLoadTracing WITH (NOLOCK)
			WHERE UploadFlag='N'
	UPDATE CS2Console_UpLoadTracing SET UploadFlag='Y' WHERE UploadFlag='N'
	
	COMMIT TRAN
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype= 'P' And Name = 'Proc_BLValidateJCCalendar')
DROP PROCEDURE Proc_BLValidateJCCalendar
GO
CREATE PROCEDURE [dbo].[Proc_BLValidateJCCalendar]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_BLValidateJCCalendar
* PURPOSE	: To Download the JC Calendar details
* CREATED	: MarySubashini.S
* CREATED DATE	: 07/04/2009
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
	DECLARE @Tabname  			NVARCHAR(50)
	DECLARE @JCYear				INT
	DECLARE @WeekEndDay			NVARCHAR(25)
	DECLARE @MonthId			NVARCHAR(25)
	DECLARE @MonthStartDate		DATETIME
	DECLARE @MonthEndDate		DATETIME
	DECLARE @QuarterDt			NVARCHAR(25)
	DECLARE @WeekId				NVARCHAR(25)
	DECLARE @WeekStartDate		DATETIME
	DECLARE @WeekEndDate		DATETIME
	DECLARE @DownloadFlag		NVARCHAR(1)
	DECLARE @CmpId				INT
	DECLARE @Status				INT
	DECLARE @CmpName			NVARCHAR(25)
	DECLARE @JcmId				INT
	DECLARE @JcmJc				INT
	DECLARE @WeekEndId			INT
	DECLARE @MonthNewDate		DATETIME
	DECLARE @WeekNewDate		DATETIME
	DECLARE @Count				INT
	DECLARE @Count1				INT
	DECLARE @NoDays				NUMERIC(38,0)
		SET @ErrStatus=1
		SET @Po_ErrNo=0
	SET @Tabname = 'ETL_Prk_BLJCCalendar'
		SET @NoDays=0
		DECLARE Cur_JCYear CURSOR	
	        	FOR SELECT  DISTINCT ISNULL(CAST([JCYear]AS INT),0) ,ISNULL(CAST([WeekEndDay]AS INT),0) 
							FROM ETL_Prk_BLJCCalendar WHERE DownloadFlag='D'
	    		OPEN Cur_JCYear
	    		FETCH NEXT FROM Cur_JCYear INTO @JCYear,@WeekEndDay
		    	WHILE @@FETCH_STATUS=0
		    	BEGIN
					IF ISNULL(@JCYear,'') = '' OR  @JCYear = '0'
					BEGIN
						SET @ErrDesc = 'JC Year should not be empty'
						INSERT INTO Errorlog VALUES (1,@TabName,'JC Year',@ErrDesc)
						SET @Po_ErrNo=1	
					END
					
					IF ISNUMERIC(@JCYear)=0
					BEGIN
			
						SET @Po_ErrNo=1
						SET @Taction=0
						SET @ErrDesc = 'JC Year'+ CAST (@JCYear AS NVARCHAR(100))+ ' sholud be a 4 digit number'		
						INSERT INTO Errorlog VALUES (2,@Tabname,'JC Year',@ErrDesc)
					END
					IF @JCYear < 2000
					BEGIN
			
						SET @Po_ErrNo=1
						SET @Taction=0
						SET @ErrDesc = 'Minimum Year Range is 2000'		
						INSERT INTO Errorlog VALUES (3,@Tabname,'JC Year',@ErrDesc)
					END
					IF @JCYear > 2098
					BEGIN
			
						SET @Po_ErrNo=1
						SET @Taction=0
						SET @ErrDesc = 'Maximum Year Range is 2098'		
						INSERT INTO Errorlog VALUES (4,@Tabname,'JC Year',@ErrDesc)
					END
					
					IF EXISTS (SELECT Status FROM Configuration WHERE
								ModuleName='JC Calendar' AND ModuleId='JC3')
					BEGIN
						SELECT @Status=Status FROM Configuration WHERE
								ModuleName='JC Calendar' AND ModuleId='JC3'
					END
					ELSE
					BEGIN
						SET @Status=0
					END
					IF EXISTS (SELECT CmpId  FROM Company WHERE DefaultCompany=1)
					BEGIN
						SELECT @CmpId=CmpId,@CmpName=CmpName  FROM Company WHERE DefaultCompany=1
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
						SET @Taction=0
						SET @ErrDesc = 'Default Company does not exists'		
						INSERT INTO Errorlog VALUES (5,@Tabname,'Default Company',@ErrDesc)
					END
					IF EXISTS (SELECT JcmId  FROM JCMast WHERE JcmYr=@JCYear AND CmpId=@CmpId)
					BEGIN
						SET @Po_ErrNo=1
						SET @Taction=0
						SET @ErrDesc = 'JC Year '+CAST(@JCYear AS NVARCHAR(20))+' is already set for the '+@CmpName+' Company'
						INSERT INTO Errorlog VALUES (6,@Tabname,'Default Company',@ErrDesc)
					END
					ELSE
					BEGIN
						SELECT @JcmId=dbo.Fn_GetPrimaryKeyInteger('JCMast','JCmId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
					END
 
					IF @WeekEndDay >7 OR  @WeekEndDay < 1
					BEGIN
						SET @ErrDesc = 'Week End Day does not exists'
						INSERT INTO Errorlog VALUES (7,@TabName,'Week End Day',@ErrDesc)
						SET @Po_ErrNo=1
					END
					IF @Po_ErrNo=0
					BEGIN
						INSERT INTO JCMast(JcmId,JcmYr,CmpId,WkEndDay,Availability,LastModBy,LastModDate,
								AuthId,AuthDate)
							VALUES(@JcmId,@JCYear,@CmpId,@WeekEndDay,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
			
							SET @sSql='INSERT INTO JCMast(JcmId,JcmYr,CmpId,WkEndDay,Availability,LastModBy,LastModDate,
								AuthId,AuthDate)VALUES ('+CAST(@JcmId AS NVARCHAR(100))+','+CAST(@JCYear AS VARCHAR(10))+','+CAST(@CmpId AS VARCHAR(10))+',
								'+CAST(@WeekEndDay AS NVARCHAR(100))+','+CAST(1 AS NVARCHAR(100))+','+CAST(1 AS NVARCHAR(100))+',
								'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''','+CAST(1 AS NVARCHAR(100))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
							INSERT INTO Translog(strSql1) VALUES (@sSql)
							UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'JCMast' AND Fldname = 'JcmId'
							SET @sSql='UPDATE Counters SET CurrValue =CurrValue'+'+1'+' WHERE Tabname=''JCMast'' AND Fldname=''JcmId'''
							INSERT INTO Translog(strSql1) VALUES (@sSql)				
                    END
							
-- JC Month         
SELECT @Po_ErrNo
                    IF @Po_ErrNo = 0
					Begin
						SET @Count=0
						DECLARE Cur_JCMonth CURSOR	
	        			FOR SELECT DISTINCT ISNULL(CAST([MonthId]AS INT),0) ,CONVERT(NVARCHAR(10),[MonthStartDate],121)
									,CONVERT(NVARCHAR(10),[MonthEndDate],121),ISNULL([QuarterDt],'')
									FROM ETL_Prk_BLJCCalendar WHERE [JCYear]=@JCYear --ORDER BY [MonthId]
	    				OPEN Cur_JCMonth
	    				FETCH NEXT FROM Cur_JCMonth INTO @MonthId,@MonthStartDate,@MonthEndDate,@QuarterDt
		    			WHILE @@FETCH_STATUS=0
		    			BEGIN
								
								IF @Count>0		
								BEGIN
									IF @MonthStartDate<@MonthNewDate OR @MonthStartDate=@MonthNewDate
									BEGIN
										SET @ErrDesc = 'Month date already exists in previous month'
										INSERT INTO Errorlog VALUES (8,@TabName,'Month Start date',@ErrDesc)
										SET @Po_ErrNo=1
									END
								END
								IF ISNULL(@MonthStartDate,'') = ''
								BEGIN
									SET @ErrDesc = 'Month Start date should not be empty'
									INSERT INTO Errorlog VALUES (9,@TabName,'Month Start date',@ErrDesc)
									SET @Po_ErrNo=1
								END
								IF ISNULL(@MonthEndDate,'') = ''
								BEGIN
									SET @ErrDesc = 'Month End date should not be empty'
									INSERT INTO Errorlog VALUES (10,@TabName,'Month End date',@ErrDesc)
									SET @Po_ErrNo=1
								END
								IF ISNULL(@QuarterDt,'') = ''
								BEGIN
									SET @ErrDesc = 'Quarter Detail should not be empty'
									INSERT INTO Errorlog VALUES (11,@TabName,'Quarter Detail',@ErrDesc)
									SET @Po_ErrNo=1
								END
								IF ISDATE(@MonthStartDate)=0
								BEGIN
									SET @Po_ErrNo=1		
									SET @Taction=0
									SET @ErrDesc = 'Month Start date '+ CAST(@MonthStartDate AS NVARCHAR(100))+ ' not in date format'		
									INSERT INTO Errorlog VALUES (12,@Tabname,'Month Start date',@ErrDesc)
								END
								IF ISDATE(@MonthEndDate)=0
								BEGIN
									SET @Po_ErrNo=1		
									SET @Taction=0
									SET @ErrDesc = 'Month End date '+ CAST(@MonthEndDate AS NVARCHAR(100))+ ' not in date format'		
									INSERT INTO Errorlog VALUES (13,@Tabname,'Month End date',@ErrDesc)
								END
								IF @MonthStartDate>@MonthEndDate
								BEGIN
									SET @Po_ErrNo=1		
									SET @Taction=0
									SET @ErrDesc = 'Month Start date should be less than Month end date'		
									INSERT INTO Errorlog VALUES (14,@Tabname,'Month Start/End date',@ErrDesc)
								END
								IF @QuarterDt='Q1' OR @QuarterDt='Q2' OR @QuarterDt='Q3' OR @QuarterDt='Q4'
								BEGIN
									SET @Po_ErrNo=0		
								END
								ELSE
								BEGIN
									SET @Po_ErrNo=0		
									SET @Taction=0
									SET @ErrDesc = 'Quarter Dt does not exists'		
									INSERT INTO Errorlog VALUES (15,@Tabname,'Quarter Dt',@ErrDesc)
								END
								IF YEAR(@MonthStartDate)=@JCYear OR YEAR(@MonthStartDate)=@JCYear+1
								BEGIN
									SET @Po_ErrNo=0	
								END
								ELSE
								BEGIN
									SET @Po_ErrNo=1		
									SET @Taction=0
									SET @ErrDesc = CAST(@MonthStartDate AS VARCHAR(100))+'Date Range should be within the JC Year'+CAST(@JCYear AS VARCHAR(100))+''		
									INSERT INTO Errorlog VALUES (16,@Tabname,'Date Range',@ErrDesc)
								END
								IF @Status=0
								BEGIN
									IF YEAR(@MonthStartDate)<@JCYear
									BEGIN
										SET @Po_ErrNo=1		
										SET @Taction=0
										SET @ErrDesc = 'Month Start Date Range should be within the JC Year'		
										INSERT INTO Errorlog VALUES (17,@Tabname,'Month Start Date Range',@ErrDesc)
									END
									
									IF YEAR(@MonthStartDate)<@JCYear
									BEGIN
										SET @Po_ErrNo=1		
										SET @Taction=0
										SET @ErrDesc = 'Month End Date Range should be within the JC Year'		
										INSERT INTO Errorlog VALUES (18,@Tabname,'Month End Date Range',@ErrDesc)
									END
								END
								ELSE
								BEGIN
									SET @NoDays=@NoDays+DATEDIFF(d,@MonthStartDate,@MonthEndDate)
									IF YEAR(@MonthStartDate)=@JCYear OR YEAR(@MonthStartDate)=@JCYear+1
									BEGIN
										SET @Po_ErrNo=0	
									END
									ELSE
									BEGIN
										SET @Po_ErrNo=1		
										SET @Taction=0
										SET @ErrDesc = 'Month Start Date Range should be within the JC Year'		
										INSERT INTO Errorlog VALUES (19,@Tabname,'Month Start Date Range',@ErrDesc)
									END
									
									IF YEAR(@MonthEndDate)=@JCYear  OR YEAR(@MonthEndDate)=@JCYear+1
									BEGIN
										SET @Po_ErrNo=0	
									END
									ELSE
									BEGIN
										SET @Po_ErrNo=1		
										SET @Taction=0
										SET @ErrDesc = 'Month End Date Range should be within the JC Year'		
										INSERT INTO Errorlog VALUES (20,@Tabname,'Month End Date Range',@ErrDesc)
									END
								END
								IF EXISTS (SELECT JcmJc FROM JCMonth A INNER JOIN JCMast B ON A.JcmId = B.JcmId
												WHERE @MonthStartDate BETWEEN JcmSdt AND JcmEdt AND A.JcmId <> @JcmId
												AND B.CmpId = @CmpId)
								BEGIN
									SET @Po_ErrNo=1		
									SET @Taction=0
									SET @ErrDesc = 'Date already exists in pervious JC Year'		
									INSERT INTO Errorlog VALUES (21,@Tabname,'Month Start/End date',@ErrDesc)
								END

								IF @Po_ErrNo = 0
								BEGIN
									INSERT INTO JCMonth(JcmId,JcmJc,JcmSdt,JcmEdt,QuarterDt,Availability,LastModBy,LastModDate,
											AuthId,AuthDate)
										VALUES(@JcmId,@MonthId,@MonthStartDate,@MonthEndDate,@QuarterDt,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
						
										SET @sSql='INSERT INTO JCMonth(JcmId,JcmJc,JcmSdt,JcmEdt,QuarterDt,Availability,LastModBy,LastModDate,
											AuthId,AuthDate)VALUES ('+CAST(@JcmId AS NVARCHAR(100))+','+CAST(@MonthId AS VARCHAR(10))+','''+CONVERT(NVARCHAR(10),@MonthStartDate,121)+''',
											'''+CONVERT(NVARCHAR(10),@MonthEndDate,121)+''','''+@QuarterDt+''','+CAST(1 AS NVARCHAR(100))+','+CAST(1 AS NVARCHAR(100))+',
											'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''','+CAST(1 AS NVARCHAR(100))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
										INSERT INTO Translog(strSql1) VALUES (@sSql)
								SET @Count1=0
									-- JC Week
								DECLARE Cur_JCWeek CURSOR	
	        					FOR SELECT DISTINCT ISNULL(CAST([WeekId]AS INT),0) ,CONVERT(NVARCHAR(10),[WeekStartDate],121)
											,CONVERT(NVARCHAR(10),[WeekEndDate],121)
											FROM ETL_Prk_BLJCCalendar WHERE [JCYear]=@JCYear AND MonthId=@MonthId --ORDER BY [WeekId]
	    						OPEN Cur_JCWeek
	    						FETCH NEXT FROM Cur_JCWeek INTO @WeekId,@WeekStartDate,@WeekEndDate
		    					WHILE @@FETCH_STATUS=0
		    					BEGIN
										IF @Count1>0		
										BEGIN
											IF @WeekStartDate<@WeekNewDate OR @WeekStartDate=@WeekNewDate
											BEGIN
												SET @ErrDesc = 'Week date already exists in previous Week'
												INSERT INTO Errorlog VALUES (22,@TabName,'Week Start date',@ErrDesc)
												SET @Po_ErrNo=1
											END
										END
										IF ISNULL(@WeekStartDate,'') = ''
										BEGIN
											SET @ErrDesc = 'Week Start date should not be empty'
											INSERT INTO Errorlog VALUES (23,@TabName,'Week Start date',@ErrDesc)
											SET @Po_ErrNo=1
										END
										IF ISNULL(@WeekEndDate,'') = ''
										BEGIN
											SET @ErrDesc = 'Week End date should not be empty'
											INSERT INTO Errorlog VALUES (24,@TabName,'Week End date',@ErrDesc)
											SET @Po_ErrNo=1
										END
										
										IF ISDATE(@WeekStartDate)=0
										BEGIN
											SET @Po_ErrNo=1		
											SET @Taction=0
											SET @ErrDesc = 'Week Start date '+ CAST(@WeekStartDate AS NVARCHAR(100))+ ' not in date format'		
											INSERT INTO Errorlog VALUES (25,@Tabname,'Week Start date',@ErrDesc)
										END
										IF ISDATE(@WeekEndDate)=0
										BEGIN
											SET @Po_ErrNo=1		
											SET @Taction=0
											SET @ErrDesc = 'Week End date '+ CAST(@WeekEndDate AS NVARCHAR(100))+ ' not in date format'		
											INSERT INTO Errorlog VALUES (26,@Tabname,'Month End date',@ErrDesc)
										END
										IF @WeekStartDate>@WeekEndDate
										BEGIN
											SET @Po_ErrNo=1		
											SET @Taction=0
											SET @ErrDesc = 'Week Start date should be less than Month end date'		
											INSERT INTO Errorlog VALUES (27,@Tabname,'Week Start/End date',@ErrDesc)
										END
										IF NOT EXISTS (SELECT MonthId FROM ETL_Prk_BLJCCalendar WHERE
												@WeekStartDate BETWEEN @MonthStartDate AND @MonthEndDate)
										BEGIN
											SET @Po_ErrNo=1		
											SET @Taction=0
											SET @ErrDesc = 'Week Start date should be With in the JC Month Date'		
											INSERT INTO Errorlog VALUES (28,@Tabname,'Week Start date',@ErrDesc)
										END
										IF NOT EXISTS (SELECT MonthId FROM ETL_Prk_BLJCCalendar WHERE
												@WeekStartDate BETWEEN @MonthStartDate AND @MonthEndDate AND MonthId=@MonthId)
										BEGIN
											SET @Po_ErrNo=1		
											SET @Taction=0
											SET @ErrDesc = 'Week Start date should be With in the JC Month Date'		
											INSERT INTO Errorlog VALUES (29,@Tabname,'Week Start date',@ErrDesc)
										END
										IF NOT EXISTS (SELECT MonthId FROM ETL_Prk_BLJCCalendar WHERE
												@WeekEndDate BETWEEN @MonthStartDate AND @MonthEndDate AND MonthId=@MonthId)
										BEGIN
											SET @Po_ErrNo=1		
											SET @Taction=0
											SET @ErrDesc = 'Week End date should be With in the JC Month Date'		
											INSERT INTO Errorlog VALUES (30,@Tabname,'Week End date',@ErrDesc)
										END
										IF @Po_ErrNo=0
										BEGIN
											INSERT INTO JCWeek(JcmId,JcmJc,JcwWk,JcwSdt,JcwEdt,Availability,LastModBy,LastModDate,
												AuthId,AuthDate)
											VALUES(@JcmId,@MonthId,@WeekId,@WeekStartDate,@WeekEndDate,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
							
											SET @sSql='INSERT INTO JCWeek(JcmId,JcmJc,JcwWk,JcwSdt,JcwEdt,Availability,LastModBy,LastModDate,
												AuthId,AuthDate)VALUES ('+CAST(@JcmId AS NVARCHAR(100))+','+CAST(@MonthId AS VARCHAR(10))+',
													'+CAST(@WeekId AS VARCHAR(10))+','''+CONVERT(NVARCHAR(10),@WeekStartDate,121)+''',
												'''+CONVERT(NVARCHAR(10),@WeekEndDate,121)+''','+CAST(1 AS NVARCHAR(100))+','+CAST(1 AS NVARCHAR(100))+',
												'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''','+CAST(1 AS NVARCHAR(100))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
											INSERT INTO Translog(strSql1) VALUES (@sSql)
										END
										SET @WeekNewDate=@WeekEndDate
										SET @Count1=1
									FETCH NEXT FROM Cur_JCWeek INTO  @WeekId,@WeekStartDate,@WeekEndDate
									END
								CLOSE Cur_JCWeek
								DEALLOCATE Cur_JCWeek
								END
								SET @Count=1
								SET @MonthNewDate=@MonthEndDate
							FETCH NEXT FROM Cur_JCMonth INTO  @MonthId,@MonthStartDate,@MonthEndDate,@QuarterDt
						END
						CLOSE Cur_JCMonth
						DEALLOCATE Cur_JCMonth
					END
					IF @Status=1
					BEGIN
						IF @NoDays=365  OR  @NoDays=366
						BEGIN
							SET @Po_ErrNo=0		
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1		
							SET @Taction=0
							SET @ErrDesc = 'Calendar should complete a Year'		
							INSERT INTO Errorlog VALUES (31,@Tabname,'Calendar',@ErrDesc)
						END
					END
				
			FETCH NEXT FROM Cur_JCYear INTO  @JCYear,@WeekEndDay
				--UPDATE ETL_Prk_BLJCCalendar SET DownloadFlag='Y' WHERE [JCYear]=@JCYear
		        END
		        CLOSE Cur_JCYear
		        DEALLOCATE Cur_JCYear

END
GO
IF NOT EXISTS (Select * from Sysobjects Where Xtype = 'U' And Name = 'SchToAvoid')
CREATE TABLE SchToAvoid 
(
CmpSchCode  nvarchar(100)
)
GO
--Select * from customupdownload where Module = 'Product Batch' And updownload= 'Download'
Delete from customupdownload where Module = 'Product Batch' And updownload= 'Download'
GO
Insert into customupdownload Select 41,1,'Product Batch','Product Batch','Proc_Cs2Cn_ProductBatch','Proc_Import_ProductBatch','Cn2Cs_Prk_ProductBatch','Proc_Cn2Cs_ProductBatch','Master','Download',1
--Select * from customupdownload where Module = 'Product' And updownload= 'Download'
Delete from customupdownload where Module = 'Product' And updownload= 'Download'
GO
Insert into customupdownload Select 40,1,'Product','Product','Proc_Cs2Cn_Product','Proc_Import_Product','Cn2Cs_Prk_Product','Proc_Cn2Cs_Product','Master','Download',1
--Select * from Tbl_Downloadintegration Where ProcessName = 'Product' 
Delete From Tbl_Downloadintegration Where ProcessName = 'Product' 
GO
Insert into Tbl_Downloadintegration Select 13,'Product','Cn2Cs_Prk_Product','Proc_Import_Product',1768,500,'2011-10-14 11:33:58.083'
GO
IF EXISTS ( Select * from SysObjects Where Xtype = 'P' And Name = 'Proc_Cn2Cs_ProductBatch')
DROP PROCEDURE Proc_Cn2Cs_ProductBatch
GO
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_ProductBatch]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ProductBatch
* PURPOSE		: To Insert and Update records in the Tables ProductBatch and ProductBatchDetails
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 12/04/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist 				AS 	INT
	DECLARE @PrdCCode 	        AS 	NVARCHAR(100)
	DECLARE @BatchCode			AS 	NVARCHAR(100)
	DECLARE @PriceCode			AS 	NVARCHAR(4000)		
	DECLARE @MnfDate			AS 	NVARCHAR(100)
	DECLARE @ExpDate			AS 	NVARCHAR(100)
	DECLARE	@BatchSeqCode 		AS 	NVARCHAR(100)
	DECLARE @PrdId 				AS 	INT
	DECLARE @PrdBatId 			AS 	INT
	DECLARE @PriceId 			AS 	INT
	DECLARE @TaxGroupId 		AS 	INT
	DECLARE @BatchSeqId 		AS 	INT
	DECLARE @BatchStatus		AS 	INT
	DECLARE @NoOfPrices 		AS 	INT
	DECLARE @ExistPrices 		AS 	INT
	DECLARE @DefaultPriceId 	AS 	INT
	DECLARE @ExistPriceId 		AS 	INT
	DECLARE @TransStr 			AS 	NVARCHAR(4000)
	DECLARE @ExistPrdBatMaxId	AS 	INT
	DECLARE @NewPrdBatMaxId		AS 	INT
	DECLARE @ContPrdId 			AS 	INT
	DECLARE @ContPrdBatId 		AS 	INT
	DECLARE @ContExistPrdBatId 	AS 	INT
	DECLARE @ContPriceId 		AS 	INT
	DECLARE @ContractId 		AS 	INT
	DECLARE @ContPriceCode		AS	NVARCHAR(100)
	DECLARE @ContPrdBatId1		AS	INT
	DECLARE @ContPriceId1		AS	INT
	DECLARE @OldPriceId 		AS 	INT
	DECLARE @NewPriceId			AS  INT
	DECLARE @OldLSP				AS  NUMERIC(38,6)
	DECLARE @StockInHand		AS  NUMERIC(38,0)
	DECLARE @ValDiffRefNo		AS  NVARCHAR(50)
	DECLARE @MRP				AS  NUMERIC(38,6)
	DECLARE @LSP				AS  NUMERIC(38,6)
	DECLARE @SR					AS  NUMERIC(38,6)
	DECLARE @CR					AS  NUMERIC(38,6)
	DECLARE @AR1				AS  NUMERIC(38,6)
	DECLARE @AR2				AS  NUMERIC(38,6)
	DECLARE @AR3				AS  NUMERIC(38,6)
	DECLARE @AR4				AS  NUMERIC(38,6)
	DECLARE @AR5				AS  NUMERIC(38,6)
	DECLARE @AR6				AS  NUMERIC(38,6)
	SET @Po_ErrNo=0
	SET @Exist=0
	SELECT @ExistPrdBatMaxId=ISNULL(MAX(PrdBatId),0) FROM ProductBatch
	SELECT @OldPriceId=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails		
	SELECT @BatchSeqId=BatchSeqId FROM BatchCreationMaster WHERE BatchSeqId IN
	(SELECT MAX(BatchSeqId) FROM BatchCreationMaster)
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'PrdBatToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE PrdBatToAvoid	
	END
	CREATE TABLE PrdBatToAvoid
	(
		PrdCCode NVARCHAR(200),
		PrdBatCode NVARCHAR(200)
	)
	IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch
	WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product))
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdCCode','Product :'+PrdCCode+' not available'
		FROM Cn2Cs_Prk_ProductBatch
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		--->Added By Nanda on 05/05/2010
		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)
		SELECT DISTINCT DistCode,'Product Batch',PrdBatCode,'Product',PrdCCode,'','N' FROM Cn2Cs_Prk_ProductBatch
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		--->Till Here				
	END
	IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch
	WHERE LEN(ISNULL(PrdBatCode,''))=0)
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch
		WHERE LEN(ISNULL(PrdBatCode,''))=0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdBatCode','Batch Code should not be empty for Product:'+PrdCCode
		FROM Cn2Cs_Prk_ProductBatch
		WHERE LEN(ISNULL(PrdBatCode,''))=0
	END
	DECLARE Cur_ProductBatch CURSOR
	FOR SELECT PB.PrdCCode,PrdBatCode,ManufacturingDate,ExpiryDate,MRP,ListPrice,SellingRate,ClaimRate,
	AddRate1,AddRate2,AddRate3,AddRate4,AddRate5,AddRate6
	FROM Cn2Cs_Prk_ProductBatch PB INNER JOIN Product P ON P.PrdCCode=PB.PrdCCode
	WHERE DownLoadFlag='D' AND PB.PrdCCode+'~'+PrdBatCode
	NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM PrdBatToAvoid)	
	ORDER BY PB.PrdCCode,PrdBatCode,EffectiveDate
	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdCCode,@BatchCode,@MnfDate,@ExpDate,@MRP,@LSP,@SR,@CR,@AR1,@AR2,@AR3,@AR4,@AR5,@AR6	
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Exist=0
		SET @Po_ErrNo=0
		SET @DefaultPriceId=1
		SET @BatchStatus=1
		SET @PriceCode=@BatchCode+'-'+CAST(@MRP AS NVARCHAR(25))+'-'+CAST(@LSP AS NVARCHAR(25))+'-'+
		CAST(@SR AS NVARCHAR(25))+'-'+CAST(@CR AS NVARCHAR(25))+'-'+CAST(@AR1 AS NVARCHAR(25))
		SELECT @PrdId=PrdId FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCCode
		SELECT @TaxGroupId=ISNULL(TaxGroupId,0) FROM Product WITH (NOLOCK) WHERE PrdId=@PrdId
		
		IF NOT EXISTS(SELECT * FROM ProductBatch WITH (NOLOCK) WHERE PrdBatCode=@BatchCode AND PrdId=@PrdId)
		BEGIN
			SET @Exist=0
		END
		ELSE
		BEGIN
			SET @Exist=1 				
			SELECT @PrdBatId=PrdBatId FROM ProductBatch WITH (NOLOCK) WHERE PrdBatCode=@BatchCode AND PrdId=@PrdId
			SELECT @OldLSP=ISNULL(PBD.PrdBatDetailValue,0),@ExistPriceId=PriceId FROM ProductBatchDetails PBD
			WHERE PrdBatId=@PrdBatId AND DefaultPrice=1 AND SlNo=2
		END
		
		IF @Exist=0
		BEGIN
			SELECT @PrdBatId=dbo.Fn_GetPrimaryKeyInteger('ProductBatch','PrdBatId',YEAR(GETDATE()),MONTH(GETDATE()))
			IF @PrdBatId>(SELECT ISNULL(MAX(PrdBatId),0) AS PrdBatId FROM ProductBatch)
			BEGIN
				INSERT INTO ProductBatch(PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,
				TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PrdId,@PrdBatId,@BatchCode,@BatchCode,@MnfDate,@ExpDate,@BatchStatus,@TaxGroupId,@BatchSeqId,6,
				0,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 			
				
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ProductBatch' AND FldName='PrdBatId'
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,'ETL_Prk_ProductBatch','System Date',
				'Reset the Counters/System is showing Date as :'+CAST(GETDATE() AS NVARCHAR(10))+'. Please change the System Date')
				SET @Po_ErrNo=1
				CLOSE Cur_ProductBatch
				DEALLOCATE Cur_ProductBatch
				RETURN
			END
		END	
		ELSE
		BEGIN
			UPDATE ProductBatch SET MnfDate=@MnfDate,ExpDate=@ExpDate,TaxGroupId=@TaxGroupId,Status=@BatchStatus
			WHERE PrdBatId=@PrdBatId
		END			
			
		IF @Po_ErrNo=0
		BEGIN
			SELECT @PriceId=dbo.Fn_GetPrimaryKeyInteger('ProductBatchDetails','PriceId',YEAR(GETDATE()),MONTH(GETDATE()))
			IF @PriceId>(SELECT ISNULL(MAX(PriceId),0) AS PriceId FROM ProductBatchDetails)
			BEGIN
				IF @DefaultPriceId=1
				BEGIN
					UPDATE ProductBatchDetails SET DefaultPrice=0 WHERE PrdBatId=@PrdBatId AND PriceId<>@PriceId
				END
				INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
				DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,1,@MRP,@DefaultPriceId,1,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 		
				
				INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
				DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,2,@LSP,@DefaultPriceId,1,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 		
				INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
				DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,3,@SR,@DefaultPriceId,1,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 		
				INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
				DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,4,@CR,@DefaultPriceId,1,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 		
				IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatchSeqId)>4
				BEGIN
					INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
					DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,5,@AR1,@DefaultPriceId,1,
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 
				END
				UPDATE ProductBatch SET DefaultPriceId=@PriceId WHERE PrdBatId=@PrdBatId AND PrdId=@PrdId
	
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ProductBatchDetails' AND FldName='PriceId'				
				IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreeRateForOldBatch'
				AND ModuleName='Botree Product Batch Download' AND Status=1)
				BEGIN
					IF @OldLSP-@LSP<>0 AND @Exist=1		
					BEGIN
						SELECT @StockInHand=ISNULL((PrdBatLcnSih+PrdBatLcnUih-PrdBatLcnRessih-PrdBatLcnResUih),0)
						FROM ProductBatchLocation WHERE PrdId=@PrdId AND PrdBatId=@PrdBatId			
						IF @StockInHand>0
						BEGIN
							SELECT @ValDiffRefNo = dbo.Fn_GetPrimaryKeyString('ValueDifferenceClaim','ValDiffRefNo',CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
							
							INSERT INTO ValueDifferenceClaim(ValDiffRefNo,Date,PrdId,PrdBatId,OldPriceId,NewPriceId,OldPrice,NewPrice,Qty,ValueDiff,ClaimAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
							VALUES(@ValDiffRefNo,GETDATE(),@PrdId,@PrdBatId,@ExistPriceId,@PriceId,@OldLSP,@LSP,@StockInHand,(@OldLSP-@LSP),(@StockInHand*(@OldLSP-@LSP)),1,1,GETDATE(),1,GETDATE())
							UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'ValueDifferenceClaim' AND FldName = 'ValDiffRefNo'
						END
					END
				END
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,'ETL_Prk_ProductBatch','System Date',
				'Reset the Counters/System is showing Date as :'+CAST(GETDATE() AS NVARCHAR(10))+'. Please change the System Date')
				SET @Po_ErrNo=1
				CLOSE Cur_ProductBatch
				DEALLOCATE Cur_ProductBatch
				RETURN
			END
		END
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdCCode,@BatchCode,@MnfDate,@ExpDate,@MRP,@LSP,@SR,@CR,@AR1,@AR2,@AR3,@AR4,@AR5,@AR6		
--		IF (SELECT COUNT(DISTINCT A.PriceId) AS COUNT FROM ProductBatchDetails A INNER JOIN ProductBatch B (NOLOCK) ON
--		A.PrdBatId=B.PrdBatId And B.PrdId=@PrdId WHERE A.DefaultPrice=1 AND A.PrdBatId=@PrdBatId GROUP BY A.PrdBatId	
--		HAVING COUNT(DISTINCT A.PriceId)>1)>1
--		BEGIN
--			UPDATE ProductBatchDetails SET DefaultPrice=0
--			WHERE PrdBatId=@PrdBatId AND PriceId NOT IN
--			(
--				SELECT MAX(DISTINCT PriceId) AS PriceId FROM ProductBatchDetails (NOLOCK)
--				WHERE PrdBatId=@PrdBatId AND DefaultPrice=1
--			)						
--			
--			UPDATE ProductBatch SET DefaultPriceId=B.PriceId
--			FROM ProductBatchDetails B (NOLOCK) WHERE ProductBatch.PrdBatId=B.PrdBatId AND
--			ProductBatch.PrdBatId=@PrdBatId AND B.DefaultPrice=1 AND B.SlNo=1
--		END
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch
	UPDATE ProductBatch SET ProductBatch.DefaultPriceId=PBD.PriceId,ProductBatch.BatchSeqId=PBD.BatchSeqId
	FROM ProductBatchDetails PBD WHERE ProductBatch.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1
	
	UPDATE ProductBatch SET EnableCloning=1 WHERE PrdBatId IN
	(
	 SELECT PrdBatId FROM ProductBatchDetails GROUP BY PrdBatId  HAVING(COUNT(DISTINCT PriceId)>1)
	)
	
	SELECT PrdBatId INTO #ZeroBatches FROM ProductBatchDetails
	GROUP BY PrdBatId HAVING SUM(DefaultPrice)=0
	
	SELECT B.PrdId,B.PrdBatId,MAX(PriceId) As PriceId INTO #ZeroMaxPrices
	FROM ProductBatchDetails A INNER JOIN ProductBatch B ON A.PrdBatId=B.PrdBatId
	INNER JOIN #ZeroBatches C ON A.PrdBatId=C.PrdBatId
	WHERE A.DefaultPrice=0 GROUP BY B.PrdId,B.PrdBatId
	
	UPDATE ProductBatch Set DefaultPriceId=B.PriceId FROM ProductBatch A,#ZeroMaxPrices B
	WHERE A.PrdBatId=B.PrdbatId and A.PrdId=B.PrdId
	
	UPDATE ProductBatchDetails Set DefaultPrice=1 FROM #ZeroMaxPrices A
	WHERE ProductBatchDetails.PrdbatId=A.PrdBatId AND ProductBatchDetails.PriceId=A.PriceId
	
	SET @Po_ErrNo=0	
	--->Added By Nanda on 03/12/2009 for Special Rate
	IF @ExistPrdBatMaxId>0
	BEGIN
		SELECT @NewPrdBatMaxId=ISNULL(MAX(PrdBatId),0) FROM ProductBatch
		IF @NewPrdBatMaxId>@ExistPrdBatMaxId
		BEGIN
			DECLARE Cur_NewPrdBat CURSOR
			FOR SELECT PB.PrdId,PB.PrdBatId FROM ProductBatch PB WHERE PB.PrdBatId>@ExistPrdBatMaxId
			ORDER BY PB.PrdId,PB.PrdBatId
			OPEN Cur_NewPrdBat
			FETCH NEXT FROM Cur_NewPrdBat INTO @ContPrdId,@ContPrdBatId
			WHILE @@FETCH_STATUS=0
			BEGIN			
				SET @ContExistPrdBatId=0
				SELECT @ContExistPrdBatId=ISNULL(MAX(PB.PrdBatId),0) FROM ProductBatch PB WHERE
				PB.PrdId=@ContPrdId AND PB.PrdBatId <>@ContPrdBatId AND PB.PrdBatId IN
				(SELECT CPD.PrdBatId FROM ContractPricingDetails CPD,ProductBatch PB WHERE PB.PrdId=@ContPrdId
				 AND CPD.PrdId=PB.PrdId	AND CPD.PrdBatId=PB.PrdBatId)
				SELECT @ContPriceCode=PriceCode FROM ProductBatchDetails WHERE PrdBatId <>@ContPrdBatId
				IF @ContExistPrdBatId<>0
				BEGIN
					DECLARE Cur_NewCont CURSOR
					FOR SELECT DISTINCT PrdBatId,PriceId FROM ProductBatchDetails WHERE PriceId IN
					(SELECT PriceId FROM ContractPricingDetails WHERE PrdBatId=@ContExistPrdBatId) AND
					PrdBatId=@ContExistPrdBatId AND SlNo=3 AND PrdBatDetailValue>0
					OPEN Cur_NewCont
					FETCH NEXT FROM Cur_NewCont INTO @ContPrdBatId1,@ContPriceId
					WHILE @@FETCH_STATUS=0
					BEGIN					
						SELECT @ContPriceId1=dbo.Fn_GetPrimaryKeyInteger('ProductBatchDetails','PriceId',YEAR(GETDATE()),MONTH(GETDATE()))		
						UPDATE Counters SET CurrValue=@ContPriceId1 WHERE TabName='ProductBatchDetails' AND FldName='PriceId'
						
						INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
						Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
						SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
						FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId AND DefaultPrice=1 AND SlNo=1
						
						INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
						Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
						SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
						FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId AND DefaultPrice=1 AND SlNo=2
						
						INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
						Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
						SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
						FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId1 AND PriceId=@ContPriceId AND SlNo=3
						
						INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
						Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
						SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
						FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId AND DefaultPrice=1 AND SlNo=4
						IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatchSeqId)>4
						BEGIN
							INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
							Availability,LastModBy,LastModDate,AuthId,AuthDate)
							SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
							SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
							FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId AND DefaultPrice=1 AND SlNo=5
						END
						
						INSERT INTO ContractPricingDetails(ContractId,PrdId,PrdBatId,PriceId,Discount,FlatAmtDisc,
						Availability,LastModBy,LastModDate,AuthId,AuthDate,CtgValMainId,ClaimablePercOnMRP)
						SELECT ContractId,PrdId,@ContPrdBatId,@ContPriceId1,Discount,FlatAmtDisc,
						Availability,LastModBy,GETDATE(),AuthId,GETDATE(),CtgValMainId,0
						FROM ContractPricingDetails WHERE PrdBatId=@ContPrdBatId1 AND PriceId=@ContPriceId
						FETCH NEXT FROM Cur_NewCont INTO @ContPrdBatId1,@ContPriceId
					END
					CLOSE Cur_NewCont
					DEALLOCATE Cur_NewCont
				END
				FETCH NEXT FROM Cur_NewPrdBat INTO @ContPrdId,@ContPrdBatId
			END
			CLOSE Cur_NewPrdBat
			DEALLOCATE Cur_NewPrdBat
		END
	END
	--->Till Here
	SELECT @NewPriceId=CurrValue FROM Counters (NOLOCK)	WHERE TabName='ProductBatchDetails' AND FldName='PriceId' 		
	--->Added By Nanda on 24/03/2010
	--->To Update Price
	IF @NewPriceId>@OldPriceId
	BEGIN
		IF EXISTS(SELECT * FROM Configuration(NOLOCK) WHERE ModuleId='BotreeRateForOldBatch'
		AND ModuleName='Botree Product Batch Download' AND Status=1)
		BEGIN
			EXEC Proc_DefaultPriceUpdation @ExistPrdBatMaxId,@OldPriceId,1
		END
	END
	--->Till Here
	
	--->Added By Nanda on 02/10/2009
	--->To Write Price History
	IF EXISTS(SELECT * FROM ProductBatchDetails WHERE DefaultPrice=1 AND PriceId>@OldPriceId)
	BEGIN
		EXEC Proc_DefaultPriceHistory 0,0,@OldPriceId,2,1
	END
	--->Till Here
	UPDATE Cn2Cs_Prk_ProductBatch SET DownLoadFlag='Y' 
	WHERE PrdCCode+'~'+PrdBatCode IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode
	FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
	
	RETURN	
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P'And Name = 'Proc_Cn2Cs_Product')
DROP PROCEDURE Proc_Cn2Cs_Product
GO
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_Product]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_Product
* PURPOSE		: To validate the downloaded Products 
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 03/04/2010
* NOTE			: 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpCode	nVarChar(50)
	DECLARE @SpmCode	nVarChar(50)
	DECLARE @PrdUpc		INT 	
	DECLARE @ErrStatus	INT
	TRUNCATE TABLE ETL_Prk_ProductHierarchyLevelvalue
	TRUNCATE TABLE ETL_Prk_Product
	DELETE FROM Cn2Cs_Prk_Product WHERE DownLoadFlag='Y'
	SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany = 1
	SELECT @SpmCode=S.SpmCode FROM Supplier S,Company C
	WHERE C.CmpId=S.CmpId AND S.SpmDefault = 1 AND C.DefaultCompany = 1
	--TO INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'BusinessUnit',@CmpCode,BusinessCode,BusinessName,@CmpCode
 	FROM Cn2Cs_Prk_Product
 	
 	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'StrategicBusinessUnit',BusinessCode,CategoryCode,CategoryName,@CmpCode
 	FROM Cn2Cs_Prk_Product
 	
 	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'Category',CategoryCode,FamilyCode,FamilyName,@CmpCode
 	FROM Cn2Cs_Prk_Product
	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'Brand',FamilyCode,GroupCode,GroupName,@CmpCode
 	FROM Cn2Cs_Prk_Product
	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'SubBrand',GroupCode,SubGroupCode,SubGroupName,@CmpCode
 	FROM Cn2Cs_Prk_Product
	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'Variant',SubGroupCode,BrandCode,BrandName,@CmpCode
 	FROM Cn2Cs_Prk_Product
	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'SKU_',BrandCode,AddHier1Code,AddHier1Name,@CmpCode
 	FROM Cn2Cs_Prk_Product	
	--TO INSERT INTO ETL_Prk_Product	
	INSERT INTO ETL_Prk_Product
	([Product Distributor Code],[Product Name],[Product Short Name],[Product Company Code],
	[Product Hierarchy Level Value Code],[Supplier Code],[Stock Cover Days],
	[Unit Per SKU],[Tax Group Code],[Weight],[Unit Code],[UOM Group Code],
	[Product Type],[Effective From Date],[Effective To Date],[Shelf Life],[Status],[EAN Code],[Vending])
	SELECT DISTINCT C.PrdCCode,C.PrdName,left(C.PrdName,20) AS ProductShortName,
	C.PrdCCode,C.AddHier1Code,@SpmCode,0,1,'',C.PrdWgt,ISNULL(C.ProductUnit,'Unit'),C.UOMGroupCode,
	C.ProductType,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121),0,'Active',
	C.[EANCode],C.Vending
	FROM Cn2Cs_Prk_Product C
	
	EXEC Proc_ValidateProductHierarchyLevelValue @Po_ErrNo= @ErrStatus OUTPUT
	IF @ErrStatus =0
	BEGIN			
		EXEC Proc_Validate_Product @Po_ErrNo= @ErrStatus OUTPUT
		IF @ErrStatus =0
		BEGIN	
			UPDATE A SET DownLoadFlag='Y' FROM Product P INNER JOIN Cn2Cs_Prk_Product A ON A.PrdCCode=P.PrdCCode					
		END
	END
	
	SET @Po_ErrNo= @ErrStatus
	RETURN
END
GO
Delete customupdownload where updownload = 'Upload' and module = 'Daily Sales'
GO
Insert into customupdownload Select 5,1,'Daily Sales','Daily Sales','Proc_Cs2Cn_DailySales','Proc_ImportBLDailySales','Cs2Cn_Prk_DailySales','Proc_ValidateDailySales','Transaction','Upload',1
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_CS2CN_BLRetailer')  
DROP PROCEDURE Proc_CS2CN_BLRetailer
GO
CREATE PROCEDURE [dbo].[Proc_CS2CN_BLRetailer]  
(  
 @Po_ErrNo INT OUTPUT  
)  
AS  
SET @Po_ErrNo = 0
SET NOCOUNT ON  
BEGIN  
/*********************************  
* PROCEDURE : Proc_CS2CN_BLRetailer  
* PURPOSE : Extract Retailer Details from CoreStocky to Console  
* NOTES  :  
* CREATED : Nandakumar R.G 09-01-2009  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/  
    Set @Po_ErrNo = 0  
 DECLARE @CmpID   AS INTEGER  
 DECLARE @DistCode As nVarchar(50)  
   
 DELETE FROM ETL_Prk_CS2CNBLRetailer WHERE UploadFlag = 'Y'  
 SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1   
 SELECT @DistCode = DistributorCode FROM Distributor  
  
 INSERT INTO ETL_Prk_CS2CNBLRetailer  
  (  
   DistCode ,  
   RtrId ,  
   RtrCde ,  
   RtrNm ,  
   RtrChannelCde ,  
   RtrGroupCde ,  
   RtrClassCde ,  
   Status,  
   KeyAccount,  
   RelationStatus,  
   ParentCode,  
   RtrRegDate,  
   GeoLevel,  
   GeoLevelValue,  
   Mode,  
   UploadFlag  
  )  
  SELECT  
   @DistCode ,  
   R.RtrId ,  
   R.RtrCode ,  
   R.RtrName ,  
   RC1.CtgCode ,  
   RC.CtgCode ,  
   RVC.ValueClassCode ,  
   RtrStatus,   
   CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,  
   CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,  
   (CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,  
   CONVERT(VARCHAR(10),R.RtrRegDate,121),ISNULL(GL.GeoLevelName,'') AS GeoLevelName,ISNULL(G.GeoName,'') AS GeoName,'New','N'      
  FROM    
   RetailerValueClassMap RVCM ,  
   RetailerValueClass RVC ,  
   RetailerCategory RC ,  
   RetailerCategoryLevel RCL,  
   RetailerCategory RC1,Retailer R  
   LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE  
   INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId  
   LEFT OUTER JOIN Geography G ON G.GeoMainId=R.GeoMainId   
   LEFT OUTER JOIN GeographyLevel GL ON GL.GeoLevelId=G.GeoLevelId   
  WHERE  
   R.RtrId = RVCM.RtrId AND  
   RVCM.RtrValueClassId = RVC.RtrClassId AND  
   RVC.CtgMainId=RC.CtgMainId AND  
   RCL.CtgLevelId=RC.CtgLevelId AND  
   RC.CtgLinkId = RC1.CtgMainId AND  
   RVC.CmpId = @CmpID AND  
   R.Upload = 'N'  
  UNION  
  SELECT  
   @DistCode ,  
   RCC.RtrId,  
   RCC.RtrCode,  
   RCC.RtrName ,  
   RC1.CtgCode,  
   RC.CtgCode,  
   RVC.ValueClassCode,  
   RtrStatus,  
   CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,  
   CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,  
   (CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,  
   CONVERT(VARCHAR(10),R.RtrRegDate,121),ISNULL(GL.GeoLevelName,'') AS GeoLevelName,ISNULL(G.GeoName,'') AS GeoName,'CR','N'     
  FROM  
   RetailerClassficationChange RCC  
   INNER JOIN RetailerValueClass RVC ON RVC.RtrClassId=RCC.RtrClassficationId AND UpLoadFlag=0  
   INNER JOIN RetailerCategory RC ON RC.CtgMainId=RCC.CtgMainId  
   INNER JOIN RetailerCategoryLevel RL ON RL.CtgLevelId=RCC.CtgLevelId  
   INNER JOIN RetailerCategory RC1 ON RC1.CtgMainId=RC.CtgLinkId  
   INNER JOIN Retailer R ON R.RtrId=RCC.RtrId  
   LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE  
   INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId  
   LEFT OUTER JOIN Geography G ON G.GeoMainId=R.GeoMainId   
   LEFT OUTER JOIN GeographyLevel GL ON GL.GeoLevelId=G.GeoLevelId   
  
 UPDATE Retailer SET Upload='Y' WHERE Upload='N'   
 AND RtrCode IN(SELECT RtrCde FROM ETL_Prk_CS2CNBLRetailer WHERE Mode='New')  
  
 UPDATE RetailerClassficationChange SET UploadFlag=1 WHERE UploadFlag=0  
 AND RtrCode IN (SELECT RtrCde FROM ETL_Prk_CS2CNBLRetailer WHERE Mode='CR')  
  
END  
GO
Delete from customupdownload where updownload = 'Upload' and module = 'Purchase Confirmation'
GO
Insert into customupdownload Select 8,1,'Purchase Confirmation','Purchase Confirmation','Proc_Cs2Cn_PurchaseConfirmation','Proc_ImportPurchaseConfirmation','Cs2Cn_Prk_PurchaseConfirmation','Proc_CN2CSBLPurchaseConfirmation','Transaction','Upload',1
GO  
Delete from Customupdownload Where updownload = 'Upload' and module = 'Sales Return'
GO
Insert Into Customupdownload Select 7,1,'Sales Return','Sales Return','Proc_Cs2Cn_SalesReturn','Proc_ImportBLSalesReturn','Cs2Cn_Prk_SalesReturn','Proc_CN2CSBLSalesReturn','Transaction','Upload',1
GO
Delete from Configuration  where Moduleid = 'BotreeRtrUpload'
GO
Insert into Configuration Select 'BotreeRtrUpload','BotreeRtrUpload','Daily Retailer Upload',1,'',0.00,1
GO
Delete from Configuration  where Moduleid = 'BotreePrdUpload'
GO
Insert into Configuration Select 'BotreePrdUpload','BotreeRtrUpload','Daily Product Upload',1,'',0.00,1
GO
Delete from DayEndProcess Where Procid in (13,14,15,16)  
GO
Insert into DayEndProcess Select Getdate(),13,Getdate(),'Sync Process'
Insert into DayEndProcess Select Getdate(),14,Getdate(),'Daily Retailer Upload'
Insert into DayEndProcess Select Getdate(),15,Getdate(),'Daily Product Upload'
Insert into DayEndProcess Select Getdate(),16,Getdate(),'Stock-Productwise Upload'
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And  Name = 'Proc_Cs2Cn_Claim_Scheme')
DROP PROCEDURE Proc_Cs2Cn_Claim_Scheme
GO
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_Claim_Scheme]  
AS  
SET NOCOUNT ON  
/*********************************  
* PROCEDURE : Proc_Cs2Cn_Claim_Scheme  
* PURPOSE  : Extract Scheme Claim Details from CoreStocky to Console  
* NOTES:  
* CREATED  : Mahalakshmi.A  19-08-2008  
* MODIFIED  
* DATE   AUTHOR    DESCRIPTION  
------------------------------------------------  
* 13/11/2009 Nandakumar R.G    Added WDS Claim  
*********************************/  
BEGIN  
 DECLARE @CmpID   AS INTEGER  
 DECLARE @DistCode As NVARCHAR(50)  
 DECLARE @ChkDate AS DATETIME  
 DECLARE @TransDate AS DATETIME  
 DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType IN('Scheme Claim','Window Display Claim')  
 SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1   
 SELECT @DistCode = DistributorCode FROM Distributor  
 SELECT @ChkDate = NextUpDate FROM DayEndProcess WHERE ProcId = 12  
 SELECT @TransDate=DATEADD(D,-1,GETDATE())  
 INSERT INTO Cs2Cn_Prk_ClaimAll  
 (  
  DistCode,CmpName,ClaimType,ClaimMonth,ClaimYear,ClaimRefNo,ClaimDate,ClaimFromDate,ClaimToDate,DistributorClaim,  
  DistributorRecommended,ClaimnormPerc,SuggestedClaim,TotalClaimAmt,Remarks,Description,Amount1,ProductCode,Batch,  
  Quantity1,Quantity2,Amount2,Amount3,TotalAmount,SchemeCode,BillNo,BillDate,RetailerCode,RetailerName,  
  TotalSalesInValue,PromotedSalesinValue,OID,Discount,FromStockType,ToStockType,Remark2,Remark3,PrdCode1,  
  PrdCode2,PrdName1,PrdName2,Date2,UploadFlag    
 )  
-- SELECT  @DistCode,CM.CmpName,'Scheme Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,CH.FromDate,CH.ToDate,  
-- (SELECT  dbo.Fn_ReturnBudgetUtilized (SM.SchId))AS DistAmount,CD.RecommendedAmount,CD.ClmPercentage,CD.ClmAmount,CD.RecommendedAmount AS TotAmt,  
-- '',SM.SchDsc,(CASE SM.SchType WHEN 2 THEN SL.PurQty ELSE 0 END) AS SchemeOnAmt,ISNULL(P.PrdDCode,'') AS PrdDCode,  
-- ISNULL(P.PrdName,'') AS PrdName,(CASE SM.SchType WHEN 1 THEN CAST(SL.PurQty AS INT) ELSE 0 END) AS SchemeOnQty,  
-- ISNULL(SF.FreeQty,0) As SchemeQty,CD.FreePrdVal+GiftPrdVal as FGQtyValue,Cd.Discount AS SchemeAmt,  
-- (CD.FreePrdVal+GiftPrdVal+CD.Discount)AS Amount,SM.CmpSchCode,'',GETDATE(),'','',0,0,0,0,'','','','','','','','',GETDATE(),'N'  
-- FROM SchemeMaster SM  
-- INNER JOIN SchemeSlabs SL ON SM.SchId=SL.SchId  
-- INNER JOIN ClaimSheetDetail CD ON CD.RefCode=SM.SchCode  
-- INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16  
-- INNER JOIN Company CM ON CM.CmpId=CH.CmpId   
-- LEFT OUTER JOIN SchemeSlabFrePrds SF ON SM.SchId=SF.SchId  
-- LEFT OUTER JOIN Product P ON SF.PrdId=P.PrdId  
-- WHERE CH.Confirm=1 AND CH.Upload='N'  
	SELECT @DistCode,CM.CmpName,'Scheme Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CD.RefCode,CH.ClmDate,CH.FromDate,CH.ToDate,  
 (SELECT  dbo.Fn_ReturnBudgetUtilized (SM.SchId))AS DistAmount,CSCA.RecommendedAmount,CD.ClmPercentage,CD.ClmAmount,CSCA.RecommendedAmount,  
 --CD.RecommendedAmount AS TotAmt,  
 '',SM.SchDsc,0,'',  
 '' AS PrdName,0,0,  
 ROUND((CD.FreePrdVal+GiftPrdVal)/CD.ClmAmount*CD.RecommendedAmount,2) AS FGQtyValue,  
 ROUND(Cd.Discount/CD.ClmAmount*CD.RecommendedAmount,2) AS SchemeAmt,  
 ROUND((CD.FreePrdVal+CD.GiftPrdVal+CD.Discount)/CD.ClmAmount*CD.RecommendedAmount,2) AS Amount,SM.CmpSchCode,'',GETDATE(),  
 '','',0,0,0,0,'','',CH.ClmCode,'','','','','',GETDATE(),'N'  
 FROM SchemeMaster SM   
 INNER JOIN ClaimSheetDetail CD ON CD.RefCode=SM.SchCode  
 INNER JOIN   
 (  
--  SELECT CD.ClmId,SUM(RecommendedAmount) AS RecommendedAmount FROM ClaimSheetDetail CD   
  SELECT Distinct CD.RefCode,SUM(RecommendedAmount) AS RecommendedAmount FROM ClaimSheetDetail CD
  INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16 AND CH.Confirm=1 AND CH.Upload='N'  
  GROUP BY CD.RefCode
 ) AS CSCA ON CSCA.RefCode= CD.RefCode
 INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16  
 INNER JOIN Company CM ON CM.CmpId=CH.CmpId --AND SM.SchType<>4   
 WHERE CH.Confirm=1 AND CH.Upload='N' AND CD.SelectMode=1 
 
-- UNION   
--  
-- --SELECT  @DistCode,CM.CmpName,'Window Display Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CH.ClmCode,CH.ClmDate,  
-- SELECT  @DistCode,CM.CmpName,'Scheme Claim',DATENAME(MONTH,CH.ClmDate),YEAR(CH.ClmDate),CD.RefCode,CH.ClmDate,   
-- CH.FromDate,CH.ToDate,  
-- (SELECT  dbo.Fn_ReturnBudgetUtilized (SM.SchId))AS DistAmount,CD.RecommendedAmount,CD.ClmPercentage,SUM(CD.ClmAmount),SUM(CD.RecommendedAmount) AS TotAmt,  
-- '',SM.SchDsc,0 AS SchemeOnAmt,'WDS' AS PrdDCode,'Window Display Claim' AS PrdName,0 AS SchemeOnQty,  
-- 0 As SchemeQty,AdjAmt,SUM(Cd.Discount) AS SchemeAmt,  
-- SUM(CD.Discount)AS Amount,SM.CmpSchCode,'',GETDATE(),R.RtrCode,R.RtrName,0,0,0,0,  
-- '','',CH.ClmCode,'','','','','',GETDATE(),'N'  
-- FROM SchemeMaster SM  
-- INNER JOIN ClaimSheetDetail CD ON CD.RefCode=SM.SchCode  
-- INNER JOIN ClaimSheetHd CH ON CD.ClmId=CH.ClmId AND CH.ClmGrpId>16  
-- INNER JOIN Company CM ON CM.CmpId=CH.CmpId  
-- INNER JOIN SalesInvoiceWindowDisplay SIW ON SIW.SchId=SM.SchId AND CH.ClmId=SIW.SchClmId  
-- INNER JOIN SalesInvoice SI ON SI.SalId=SIW.SalId    
-- INNER JOIN Retailer R ON SI.RtrId=R.RtrId    
-- WHERE CH.Confirm=1 AND SM.SchType=4 AND CH.Upload='N' AND CD.SelectMode=1  
-- GROUP BY CM.CmpName,CH.ClmDate,CH.ClmCode,SM.CmpSchCode,CH.ClmDate,CH.FromDate,CH.ToDate,  
-- SM.SchId,CD.RecommendedAmount,CD.ClmPercentage,SM.SchDsc,AdjAmt,R.RtrCode,R.RtrName,CD.RefCode  
 --->Added By Nanda on 13/10/2010 for Claim Details  
 DELETE FROM Cs2Cn_Prk_Claim_SchemeDetails WHERE UploadFlag='Y'  
 INSERT INTO Cs2Cn_Prk_Claim_SchemeDetails(DistCode,ClaimRefNo,CmpSchCode,SlabId,SalInvNo,PrdCCode,BilledQty,  
 ClaimAmount,SchCode,SchDesc,ClaimDate,UploadedDate,UploadFlag)  
 SELECT DISTINCT @DistCode,CH.ClmCode,SM.CmpSchCode,SISL.SlabId,SI.SalInvNo,P.PrdCCode,SUM(SIP.BaseQty),SUM(SISL.FlatAmount+SISL.DiscountPerAmount),  
 SM.SchCode,SM.SchDsc,CH.ClmDate,GETDATE(),'N'  
 FROM ClaimSheetHd CH,ClaimSheetDetail CD,SalesInvoiceSchemeLinewise SISL,SchemeMaster SM,  
 SalesInvoice SI,Product P,SalesInvoiceProduct SIP  
 WHERE CH.ClmId=CD.ClmId AND CH.Upload='N' AND CD.RefCode=SM.SchCode AND  
 SISL.SchClmId=CD.ClmId AND SISL.SchId=SM.SchId AND SISL.SalId=Si.SalId AND SISl.PrdId=P.PrdId  
 AND SISL.RowId =SIP.SlNo AND SISL.SalId=SIP.SalId AND SI.SalId = SIP.SalId   
 GROUP BY CH.ClmCode,CH.ClmDate,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISL.SlabId,SI.SalInvNo,P.PrdCCode  
 HAVING SUM(SISL.FlatAmount+SISL.DiscountPerAmount)>0  
 UNION  
 SELECT DISTINCT @DistCode,CH.ClmCode,SM.CmpSchCode,SISF.SlabId,SI.SalInvNo,'Free Product' AS PrdCCode,  
 0 AS BaseQty,ROUND(SUM(SISF.FreeQty*PBD.PrdBatDetailValue),2),SM.SchCode,SM.SchDsc,CH.ClmDate,GETDATE(),'N'  
 FROM ClaimSheetHd CH,ClaimSheetDetail CD,SalesInvoiceSchemeDtFreePrd SISF,SchemeMaster SM,  
 SalesInvoice SI,ProductBatchDetails PBD,BatchCreation BC  
 WHERE CH.ClmId=CD.ClmId AND CH.Upload='N' AND CD.RefCode=SM.SchCode AND CD.SelectMode=1 AND  
 SISF.SchClmId=CD.ClmId AND SISF.SchId=SM.SchId AND SISF.SalId=Si.SalId   
 AND SISF.FreePrdBatId =PBD.PrdBatId AND SISf.FreePriceId=PBD.PriceId AND PBD.SlNo=BC.SlNo AND BC.ClmRte=1 AND  
 PBD.BatchSeqId=BC.BatchSeqId  
 GROUP BY CH.ClmCode,CH.ClmDate,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISF.SlabId,SI.SalInvNo  
   
 UNION  
 SELECT DISTINCT @DistCode,CH.ClmCode,SM.CmpSchCode,0 AS SlabId,SI.SalInvNo,'Window Display' AS PrdCCode,  
 0 AS BaseQty,SUM(SIW.AdjAmt),SM.SchCode,SM.SchDsc,CH.ClmDate,GETDATE(),'N'  
 FROM ClaimSheetHd CH,ClaimSheetDetail CD,SalesInvoiceWindowDisplay SIW,SchemeMaster SM,  
 SalesInvoice SI  
 WHERE CH.ClmId=CD.ClmId AND CH.Upload='N' AND CD.RefCode=SM.SchCode AND CD.SelectMode=1 AND  
 SIW.SchClmId=CD.ClmId AND SIW.SchId=SM.SchId AND SIW.SalId=Si.SalId    
 GROUP BY CH.ClmCode,CH.ClmDate,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SI.SalInvNo  
 --->Till Here  
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_ValidateStockNorm')
DROP PROCEDURE Proc_ValidateStockNorm
GO
CREATE Procedure [dbo].[Proc_ValidateStockNorm]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValidateStockNorm
* PURPOSE	: To Insert and Update records in the Table Stock Norm
* CREATED	: Nandakumar R.G
* CREATED DATE	: 21/11/2008
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
	
	DECLARE @PrdHierLevelCode 	AS  NVARCHAR(100)
	DECLARE @PrdHierLevelValueCode 	AS  NVARCHAR(100)
	DECLARE @MaxLevelCode 	AS  NVARCHAR(100)
	
	DECLARE @PrdCCode	AS 	NVARCHAR(100)
	DECLARE @AbsStkNorm	AS 	NUMERIC(38,0)
	DECLARE @EffDate	AS 	NVARCHAR(12)	
	DECLARE @CmpPrdCtgId 	AS 	INT
	DECLARE @PrdCtgMainId 	AS 	INT
	DECLARE @PrdId 		AS 	INT
	DECLARE @StockNormId	AS 	INT
	DECLARE @TransStr 	AS 	NVARCHAR(4000)
	DECLARE @Exist	AS 	INT

	DECLARE @StockNormMap	TABLE
	(
		StkId									NUMERIC(38,0),
		[Product Hierarchy Level Code]			VARCHAR(250),
		[Product Hierarchy Level Value Code]	VARCHAR(500),
		[Product Company Code]					VARCHAR(250),
		EffectDate								DATETIME
	)

	SET @Po_ErrNo=0
	
	SET @DestTabname='StockNorm'
	SET @Fldname='StockNormId'
	SET @Tabname = 'ETL_Prk_StockNorm'
		
	DECLARE Cur_StockNorm CURSOR
	FOR SELECT ISNULL([Product Hierarchy Level Code],''),ISNULL([Product Hierarchy Level Value Code],''),
	ISNULL([Product Company Code],''),ISNULL([Absolute Stock Norm],0),
	CONVERT(NVARCHAR(10),[Effective From Date],121)
	FROM ETL_Prk_StockNorm
	WHERE DownloadFlag='D'
	OPEN Cur_StockNorm	
	FETCH NEXT FROM Cur_StockNorm INTO @PrdHierLevelCode,@PrdHierLevelValueCode,
	@PrdCCode,@AbsStkNorm,@EffDate
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ProductCategoryLevel WITH (NOLOCK) WHERE CmpPrdCtgName=@PrdHierLevelCode)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@Tabname,'Product Hierarchy Level Code',
			'Product Hierachy Level :'+@PrdHierLevelCode+' is not available')
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN			
			SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WITH (NOLOCK)
			WHERE CmpPrdCtgName=@PrdHierLevelCode
		END
		
	
		SELECT @MaxLevelCode=CmpPrdCtgName FROM ProductCategoryLevel 		
		WHERE CmpPrdCtgId IN (SELECT MAX(CmpPrdCtgId) FROM ProductCategoryLevel)
		IF @Po_ErrNo=0
		BEGIN			
			IF @MaxLevelCode=@PrdHierLevelCode
			BEGIN
				IF NOT EXISTS(SELECT * FROM Product WITH (NOLOCK)
				WHERE PrdCCode=@PrdCCode)
				BEGIN
					INSERT INTO Errorlog VALUES (1,@Tabname,'Product',
					'Product:'+@PrdCCode+' is not available')
					SET @Po_ErrNo=1
				END
				ELSE
				BEGIN
					SELECT @PrdId=ISNULL(PrdId,0) FROM Product WITH (NOLOCK)
					WHERE PrdCCode=@PrdCCode
					SET @PrdCtgMainId=0
				END
			END
			ELSE
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					IF NOT EXISTS(SELECT * FROM ProductCategoryValue WITH (NOLOCK)
					WHERE PrdCtgValCode=@PrdHierLevelValueCode)
					BEGIN
						INSERT INTO Errorlog VALUES (1,@Tabname,'Product Category Level Value',
						'Product Category Level Value:'+@PrdHierLevelValueCode+' is not available')
						SET @Po_ErrNo=1
					END
					ELSE
					BEGIN
						SELECT @PrdCtgMainId=ISNULL(PrdCtgValMainId,0) FROM ProductCategoryValue WITH (NOLOCK)
						WHERE PrdCtgValCode=@PrdHierLevelValueCode
						SET @PrdId=0
					END
				END
			END
		END	
		IF @Po_ErrNo=0
		BEGIN
			IF @AbsStkNorm<=0
			BEGIN
				INSERT INTO Errorlog VALUES (1,@Tabname,'Absolute Stock Norm',
				'Qty should be greater than zero')
				SET @Po_ErrNo=1
			END
		END	
		IF @Po_ErrNo=0
		BEGIN
			IF ISDATE(@EffDate)<=0
			BEGIN
				INSERT INTO Errorlog VALUES (1,@Tabname,'Effective From Date',
				'Effective From Date should be a valid date')
				SET @Po_ErrNo=1
			END
		END	

		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM StockNorm WHERE CmpPrdCtgId=@CmpPrdCtgId AND
			PrdCtgValMainId=@PrdCtgMainId AND PrdId=@PrdId AND EffectiveFromDate=@EffDate)
			BEGIN
				SET @Exist=0
				SELECT @StockNormId=dbo.Fn_GetPrimaryKeyInteger(@DestTabname,@FldName,
				CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			END
			ELSE
			BEGIN
				SET @Exist=1
				SELECT @StockNormId=StockNormId FROM StockNorm WHERE CmpPrdCtgId=@CmpPrdCtgId AND
				PrdCtgValMainId=@PrdCtgMainId AND PrdId=@PrdId AND EffectiveFromDate=@EffDate
			END
		END

		IF @Po_ErrNo=0
		BEGIN	
			IF @Exist=0
			BEGIN		
				INSERT INTO StockNorm(StockNormId,CmpPrdCtgId,PrdCtgValMainId,PrdId,AbsStkNorm,EffectiveFromDate,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES	(@StockNormId,@CmpPrdCtgId,@PrdCtgMainId,@PrdId,@AbsStkNorm,@EffDate,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 			
					
				SET @TransStr='INSERT INTO StockNorm(StockNormId,CmpPrdCtgId,PrdCtgValMainId,PrdId,AbsStkNorm,EffectiveFromDate)
				VALUES ('+CAST(@StockNormId AS NVARCHAR(10))+','+CAST(@CmpPrdCtgId AS NVARCHAR(10))+','+
				CAST(@PrdCtgMainId AS NVARCHAR(10))+','+CAST(@PrdId AS NVARCHAR(10))+','+
				CAST(@AbsStkNorm AS NVARCHAR(10))+','+CAST(@EffDate AS NVARCHAR(10))+','+
				'1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
		
				UPDATE Counters SET CurrValue=@StockNormId WHERE TabName=@DestTabname AND FldName=@FldName
				SET @TransStr='UPDATE Counters SET CurrValue='+
				CAST(@StockNormId AS NVARCHAR(10))+' WHERE TabName='''+@DestTabname+''' AND FldName='''+@FldName+''''
		
				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
			END
			ELSE
			BEGIN
				UPDATE StockNorm SET AbsStkNorm=@AbsStkNorm
				WHERE StockNormId=@StockNormId

				SET @TransStr='UPDATE StockNorm SET AbsStkNorm='+CAST(@AbsStkNorm AS NVARCHAR(10))+
				'WHERE StockNormId='+CAST(@StockNormId AS NVARCHAR(10))+''

				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)			
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			INSERT INTO @StockNormMap
			SELECT @StockNormId,@PrdHierLevelCode,@PrdHierLevelValueCode,@PrdCCode,@EffDate
		END
		
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_StockNorm
			DEALLOCATE Cur_StockNorm
			RETURN
		END		
			
		FETCH NEXT FROM Cur_StockNorm INTO @PrdHierLevelCode,@PrdHierLevelValueCode,
		@PrdCCode,@AbsStkNorm,@EffDate
	END
	CLOSE Cur_StockNorm
	DEALLOCATE Cur_StockNorm

	UPDATE A SET DownloadFlag='Y' FROM ETL_Prk_StockNorm A INNER JOIN @StockNormMap B
	ON A.[Product Hierarchy Level Code]=B.[Product Hierarchy Level Code] AND 
	A.[Product Hierarchy Level Value Code]=B.[Product Hierarchy Level Value Code] AND
	A.[Product Company Code]=B.[Product Company Code] WHERE DownloadFlag='D'
	RETURN
END
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'Proc_Cn2Cs_Product')
DROP PROCEDURE Proc_Cn2Cs_Product
GO
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_Product]  
(  
 @Po_ErrNo INT OUTPUT  
)  
AS  
/*********************************  
* PROCEDURE  : Proc_Cn2Cs_Product  
* PURPOSE  : To validate the downloaded Products   
* CREATED BY : Nandakumar R.G  
* CREATED DATE : 03/04/2010  
* NOTE   :   
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
   
*********************************/  
SET NOCOUNT ON  
BEGIN  
 DECLARE @CmpCode nVarChar(50)  
 DECLARE @SpmCode nVarChar(50)  
 DECLARE @PrdUpc  INT    
 DECLARE @ErrStatus INT  
 TRUNCATE TABLE ETL_Prk_ProductHierarchyLevelvalue  
 TRUNCATE TABLE ETL_Prk_Product  
 DELETE FROM Cn2Cs_Prk_Product WHERE DownLoadFlag='Y'  
 SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany = 1  
 SELECT @SpmCode=S.SpmCode FROM Supplier S,Company C  
 WHERE C.CmpId=S.CmpId AND S.SpmDefault = 1 AND C.DefaultCompany = 1  
 --TO INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Business',@CmpCode,BusinessCode,BusinessName,@CmpCode  
  FROM Cn2Cs_Prk_Product  

--SELECT * FROM ProductCategoryLevel
    
  INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Category',BusinessCode,CategoryCode,CategoryName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
    
  INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Family',CategoryCode,FamilyCode,FamilyName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
 INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Group',FamilyCode,GroupCode,GroupName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
 INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'SubGroup',GroupCode,SubGroupCode,SubGroupName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
 INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Brand',SubGroupCode,BrandCode,BrandName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
-- INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
--  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
--  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
--  SELECT DISTINCT 'SKU',BrandCode,AddHier1Code,AddHier1Name,@CmpCode  
--  FROM Cn2Cs_Prk_Product   
 --TO INSERT INTO ETL_Prk_Product   
 INSERT INTO ETL_Prk_Product  
 ([Product Distributor Code],[Product Name],[Product Short Name],[Product Company Code],  
 [Product Hierarchy Level Value Code],[Supplier Code],[Stock Cover Days],  
 [Unit Per SKU],[Tax Group Code],[Weight],[Unit Code],[UOM Group Code],  
 [Product Type],[Effective From Date],[Effective To Date],[Shelf Life],[Status],[EAN Code],[Vending])  
 SELECT DISTINCT C.PrdCCode,C.PrdName,left(C.PrdName,20) AS ProductShortName,  
 C.PrdCCode,C.BrandCode,@SpmCode,0,1,'',C.PrdWgt,ISNULL(C.ProductUnit,'Unit'),C.UOMGroupCode,  
 C.ProductType,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121),0,'Active',  
 C.[EANCode],C.Vending  
 FROM Cn2Cs_Prk_Product C  
   
 EXEC Proc_ValidateProductHierarchyLevelValue @Po_ErrNo= @ErrStatus OUTPUT  
 IF @ErrStatus =0  
 BEGIN     
  EXEC Proc_Validate_Product @Po_ErrNo= @ErrStatus OUTPUT  
  IF @ErrStatus =0  
  BEGIN   
   UPDATE A SET DownLoadFlag='Y' FROM Product P INNER JOIN Cn2Cs_Prk_Product A ON A.PrdCCode=P.PrdCCode       
  END  
 END  
   
 SET @Po_ErrNo= @ErrStatus  
 RETURN  
END  
GO

IF NOT EXISTS(SELECT SC.NAME FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SC ON S.ID=SC.ID AND S.NAME='OrderBooking' and SC.NAME='PDADownLoadFlag')
BEGIN
	ALTER TABLE OrderBooking ADD PDADownLoadFlag TinyInt DEFAULT 0 WITH values
END
GO
Update HotsearchEditorHd Set RemainSltstring=' 
SELECT OrderNo,OrderDate,DeliveryDate,CmpId,DocRefNo,AllowBackOrder,SmId,RmId,  RtrId,OrdType,Priority,FillAllPrd,ShipTo,RtrShipId,Remarks,RoundOff,  RndOffValue,TotalAmount,Status,Availability,LastModBy,LastModDate,  AuthId,AuthDate,RtrName,PDADownLoadFlag FROM (  
Select OrderNo,OrderDate,DeliveryDate,CmpId,DocRefNo,AllowBackOrder,A.SmId,A.RmId,  A.RtrId,OrdType,Priority,FillAllPrd,ShipTo,A.RtrShipId,Remarks,RoundOff,  RndOffValue,TotalAmount,Status,A.Availability,A.LastModBy,A.LastModDate,  A.AuthId,A.AuthDate,B.RtrName,ISNULL(PDADownLoadFlag,0) as PDADownLoadFlag
from OrderBooking A INNER JOIN Retailer B ON A.RtrId=B.RtrId ) a'
where FormId=680
GO
DELETE FROM CustomCaptions WHERE TransId=3 and CtrlId=2000 and SubCtrlId=36
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 3,2000,36,'HotSch-3-2000-36','Reference No','','',1,1,1,Getdate(),1,Getdate(),'Reference No','','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=3 and CtrlId=2000 and SubCtrlId=37
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 3,2000,37,'HotSch-3-2000-37','Retailer Code','','',1,1,1,Getdate(),1,Getdate(),'Retailer Code','','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=3 and CtrlId=2000 and SubCtrlId=38
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 3,2000,38,'HotSch-3-2000-38','Retailer Name','','',1,1,1,Getdate(),1,Getdate(),'Retailer Name','','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=3 and CtrlId=1000 and SubCtrlId=55
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,
DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 3,1000,55,'PnlMsg-3-1000-55','','Press F4/Double click to Select Down Loaded  SalesReturn','',1,1,1,Getdate(),1,Getdate(),'','Press F4/Double click to Select Down Loaded  SalesReturn','',1,1
GO

DELETE FROM HotsearchEditorHD WHERE FormId=10049
INSERT INTO HotsearchEditorHD(FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 10049,'Sales Return','DocRefNo','Select','SELECT R.RtrId,Srno,RtrCode,RtrName,SMID,SMName,RM.RMID,RMNAME FROM PDA_SalesReturn  PD (NOLOCK)  INNER JOIN Retailer R (NOLOCK) ON R.Rtrid=Pd.Rtrid INNER JOIN RetailerMarket RTM (NOLOCK) ON RTM.RMID=PD.MktId AND RTM.Rtrid=R.Rtrid INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMID=RTM.RMID and RM.RMID=PD.MktId INNER JOIN SalesMan SM (NOLOCK) ON SM.SMID=PD.SrpID WHERE PD.Status=0' 

DELETE FROM HotsearchEditorDT WHERE FormId=10049
INSERT INTO HotsearchEditorDT(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
SELECT 1,10049,'Doc Reference No','Reference No','Srno',4500,0,'HotSch-3-2000-36',3
UNION ALL
SELECT 1,10049,'Retailer Code','Retailer Code','RtrCode',4500,0,'HotSch-3-2000-37',3
UNION ALL
SELECT 1,10049,'Retailer Name','Retailer Name','RtrName',4500,0,'HotSch-3-2000-38',3
GO

IF NOT EXISTS(SELECT C.NAME FROM SYSCOLUMNS C INNER JOIN SYSOBJECTS S ON S.ID=C.ID AND C.NAME='PDAReturn' and S.NAME='ReturnHeader')
BEGIN
	ALTER TABLE ReturnHeader ADD PDAReturn TinyInt
END
GO
UPDATE ReturnHeader SET PDAReturn=0
GO
UPDATE HotsearchEditorHD SET RemainsltString='
SELECT ReturnId,ReturnCode,RtnRoundOff,RtnRoundOffAmt,PDAReturn FROM   (
Select DISTINCT RH.ReturnId,RH.ReturnCode,RH.RtnRoundOff,RH.RtnRoundOffAmt,PDAReturn  
From  ReturnHeader RH (NOLOCK)   Where RH.ReturnType = 2   
and (RH.Status = ''vFParam'' or RH.Status = ''vSParam''))MainSql' WHERE FormId=221
GO

IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='TF' AND NAME='Fn_ReturnPDAProductDt')
DROP FUNCTION Fn_ReturnPDAProductDt
GO
CREATE    FUNCTION [Fn_ReturnPDAProductDt](@SrNo as Varchar(50))
RETURNS @PDAProducts TABLE
	(
		PrdId		INT,
		PrdName		Varchar(150),
		PrdCCode	Varchar(50),
		PrdBatID	INT,
		BatchCode	Varchar(100),
		Qty			INT,
		MRP			NUMERIC(18,6),
		SellRate	NUMERIC(18,6),
		PriceId		INT,
		SplPriceId  INT,
		StockTypeId	INT
	)
AS
BEGIN
/*********************************
* FUNCTION: Fn_ReturnPDAProductDt
* PURPOSE: Returns the PDA Product details
* NOTES:
* CREATED: MURURGAN.R
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
INSERT INTO	@PDAProducts
Select F.PrdId,F.PrdName,F.PrdCCode,A.PrdBatID,CmpBatCode AS BatchCode, [SrQty],B.PrdBatDetailValue as 'MRP',D.PrdBatDetailValue as 'SellRate',A.DefaultPriceId as PriceId, 0 as SplPriceId,UsrStkTyp 
FROM ProductBatch A (NOLOCK) 
INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 
INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND   C.MRP = 1 
INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID  AND D.DefaultPrice=1 
INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.SelRte = 1 
INNER JOIN PRODUCT F (NOLOCK) ON A.PrdId=F.PrdId 
INNER JOIN PDA_SalesReturnProduct G (NOLOCK) ON G.[PrdId] = F.Prdid And G.[PrdBatId] = A.Prdbatid AND A.DefaultPriceId=G.PriceId WHERE [Srno]=@SrNo Order By F.PrdCCode


RETURN
END
GO


IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_SalesRepresentative' AND xtype ='P')
DROP PROCEDURE [Proc_Export_PDA_SalesRepresentative]
GO
--Exec Proc_Export_PDA_SalesRepresentative 'test','inter','KS'

CREATE PROCEDURE [dbo].[Proc_Export_PDA_SalesRepresentative]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.SalesRepresentative Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.SalesRepresentative(SrpId,SrpCde,SrpNm,SrpSts,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT SMId,SMCode,SMName,Status,''N'' AS UploadFlag FROM '+ (@FromDBName) +'.dbo.SalesMan WHERE Status = 1 and SMCode = ''' + @SalRpCode + ''''
	EXEC (@InsSQL)
END
GO
--FOR MARKET--
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_Market' AND xtype ='P')
DROP PROCEDURE [Proc_Export_PDA_Market]
GO
--Exec Proc_Export_PDA_Market 'Test','Intermediate','KS'
CREATE PROCEDURE [dbo].[Proc_Export_PDA_Market]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.Market Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.Market(SrpCde,MktId,MktCde,MktNm,MktDist,MktPopu,mktsts,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + @SalRpCode + ''', RM.RMId,RMCode,RMName,RMDistance,RMPopulation,RMstatus,''N'' AS UploadFlag FROM '+ (@FromDBName) +'.dbo.RouteMaster RM 
							 INNER JOIN SalesmanMarket SM ON SM.RMId = RM.RMId INNER JOIN Salesman S ON S.SMId = SM.SMId
							 WHERE S.SMCode=''' + @SalRpCode + '''  AND RMstatus=1'
	EXEC (@InsSQL)
END
GO
--FOR TABLE BANK--
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_Bank' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_Bank
GO
--Exec Proc_Export_PDA_Bank 'Test','Intermediate','KS'

CREATE PROCEDURE [dbo].[Proc_Export_PDA_Bank]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.Bank Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.Bank(SrpCde,BnkId,BnkCode,BnkName,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + @SalRpCode + ''',BnkId,BnkCode,BnkName,''N'' AS UploadFlag FROM '+ (@FromDBName) +'.dbo.Bank'
	EXEC (@InsSQL)

END
--FOR TABLE BANKBRANCH--
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_BankBranch' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_BankBranch
GO
--Exec Proc_Export_PDA_BankBranch 'Test','Inter','KS'

CREATE PROCEDURE [dbo].[Proc_Export_PDA_BankBranch]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.BankBranch Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.BankBranch(SrpCde,BnkId,BnkBrId,BnkBrCode,BnkBrName,BnkBrAdd1,BnkBrAdd2,BnkBrAdd3,BnkBrPhone,BnkBrFax,BnkBrACNo,BnkBrContact,BnkBrEmailId,BnkBrRemarks,DistBank,CoaId,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + @SalRpCode + ''',BnkId,BnkBrId,BnkBrCode,BnkBrName,BnkBrAdd1,BnkBrAdd2,BnkBrAdd3,BnkBrPhone,BnkBrFax,BnkBrACNo,BnkBrContact,BnkBrEmailId,BnkBrRemarks,DistBank,CoaId,''N'' AS UploadFlag FROM '+ (@FromDBName) +'.dbo.BankBranch'
	EXEC (@InsSQL)
END
GO
--FOR TABLE PRODUCTCATEGORY--
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_ProductCategory' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_ProductCategory
GO
--Exec Proc_Export_PDA_ProductCategory 'Test','Inter','KS'

CREATE PROCEDURE [dbo].[Proc_Export_PDA_ProductCategory]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.ProductCategory Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.ProductCategory(SrpCde,CmpPrdCtgId,CmpPrdCtgName,LevelName,CmpId,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + (@SalRpCode) + ''',CmpPrdCtgId,CmpPrdCtgName,LevelName,CmpId,''N'' AS UploadFlag FROM '+ (@FromDBName) +'.dbo.ProductCategoryLevel'
	EXEC (@InsSQL)

END
GO
--FOR TABLE PRODUCTCATEGORYVALUE--
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_ProductCategoryValue' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_ProductCategoryValue
GO
--Exec Proc_Export_PDA_ProductCategoryValue 'Test','Inter','KS'

CREATE PROCEDURE [dbo].[Proc_Export_PDA_ProductCategoryValue]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.ProductCategoryValue Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.ProductCategoryValue(SrpCde,PrdCtgValMainId,PrdCtgValLinkId,CmpPrdCtgId,PrdCtgValLinkCode,PrdCtgValCode,PrdCtgValName,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + (@SalRpCode) + ''',PrdCtgValMainId,PrdCtgValLinkId,CmpPrdCtgId,PrdCtgValLinkCode,PrdCtgValCode,PrdCtgValName,''N'' AS UploadFlag FROM '+ (@FromDBName) +'.dbo.ProductCategoryValue'
	EXEC (@InsSQL)

END
GO
--FOR PRODUCT--
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_Products' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_Products
GO
--Exec Proc_Export_PDA_Products 'QPS','Intermediate','S02'
CREATE PROCEDURE [dbo].[Proc_Export_PDA_Products]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @FromDate AS datetime
DECLARE @ToDate AS datetime

BEGIN
--	SELECT @FromDate=dateadd(MM,-6,getdate())
--	SELECT @ToDate=CONVERT(VARCHAR(10),getdate(),121)

--	SELECT DISTINCT prdid,PrdBatId INTO #Tempproduct FROM SalesInvoiceProduct SIP INNER JOIN SalesInvoice SI ON SI.SalId = SIP.SalId
--	WHERE salinvdate BETWEEN @FromDate AND @ToDate

	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.Product Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.Product(SrpCde,PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,EffectiveFrom,EffectiveTo,PrdStatus,CmpId,PrdCtgValMainId,Vending,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + (@SalRpCode) + ''',PrdId,PrdName,PrdShrtName,PrdDCode,PrdCCode,SpmId,StkCovDays,PrdUpSKU,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,EffectiveFrom,EffectiveTo,PrdStatus,CmpId,PrdCtgValMainId,Vending,''N'' AS UploadFlag
	 FROM '+ (@FromDBName) +'.dbo.Product where PrdStatus=1'
	EXEC (@InsSQL)
END
GO
--Product Batch
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Export_PDA_ProductBatch') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_PDA_ProductBatch
GO
--Exec Proc_Export_PDA_ProductBatch 'jnj','JnJIntermediate','SM01'
CREATE PROCEDURE Proc_Export_PDA_ProductBatch
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
/*********************************
* PROCEDURE: [Proc_Export_PDA_ProductBatch]
* PURPOSE: To Insert the records From Zoom into Intermediate Database
* SCREEN : PRODUCTBATCH
* CREATED: MURUGAN.R
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*********************************/
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @FromDate AS datetime
DECLARE @ToDate AS datetime

BEGIN

CREATE TABLE #Tempproductbatch (Prdid int,prdbatid int)

DECLARE @Prdid AS int
DECLARE Cur_Productbatch CURSOR
FOR SELECT prdid FROM Product WHERE PrdStatus=1
OPEN  Cur_Productbatch 
FETCH next FROM Cur_Productbatch INTO  @Prdid
WHILE @@fetch_status=0
BEGIN
 IF NOT EXISTS(SELECT prdid,prdbatid,sum(PrdBatLcnSih-PrdBatLcnRessih)Qty FROM productbatchlocation 
		       WHERE PrdId=@Prdid AND (PrdBatLcnSih-PrdBatLcnRessih)>0 GROUP BY prdid,PrdBatID)
	BEGIN  
		INSERT INTO #Tempproductbatch	
		SELECT prdid,max(PrdBatId)PrdBatId FROM ProductBatch WHERE PrdId=@Prdid GROUP BY prdid
	END  
 ELSE
    BEGIN 
		INSERT INTO #Tempproductbatch	
		SELECT prdid,min(prdbatid)prdbatid FROM productbatchlocation WHERE prdid=@Prdid 
			AND (PrdBatLcnSih-PrdBatLcnRessih)>0 GROUP BY prdid
    END 
FETCH next FROM Cur_Productbatch INTO  @Prdid
END 
CLOSE Cur_Productbatch
DEALLOCATE Cur_Productbatch

	Set @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.ProductBatch Where SrpCde = ''' + @SalRpCode + ''''
	PRINT @DelSQL
	exec (@DelSQL)
	Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.ProductBatch (SrpCde,PrdId,PrdBatId,PriceId,CmpBatCode,MnfDate,ExpDate,Status,TaxGroupId,MRP,[List Price],[Selling Price],CurStock,UploadFlag)'
	Set @InsSQL = @InsSQL +  

' SELECT ''' + @SalRpCode + ''', P.PrdId,PB.Prdbatid,DP.PriceId,CmpBatCode,MnfDate,ExpDate,Status,'+
' Pb.TaxGroupId,MRP,'+
' PurchaseRate AS ListPrice,SellingRate,sum(PrdBatLcnSih-PrdBatLcnRessih)Qty,''N'''+
' FROM '+ QuoteName(@FromDBName) + '..Product P INNER JOIN '+ QuoteName(@FromDBName) +'..ProductBatch Pb ON P.PrdId=Pb.Prdid'+
' inner join #Tempproductbatch T on PB.prdid=T.prdid and PB.prdbatid=T.prdbatid'+
' INNER JOIN '+ QuoteName(@FromDBName) + '..DefaultPriceHistory DP ON DP.PrdId=P.prdid '+
' AND DP.PrdId=PB.prdid AND DP.PrdBatId=PB.prdbatid AND DP.PrdId=T.prdid AND DP.PrdBatId=T.prdbatid AND dp.priceid=pb.defaultpriceid'+
' INNER JOIN Productbatchlocation PBL on PBL.prdid=	P.prdid and PBL.prdbatid=PB.prdbatid and PBL.prdid=PB.prdid '+
' and PBL.prdid=T.prdid and PBL.prdbatid=T.prdbatid and PBL.prdid=DP.prdid and PBL.prdbatid=DP.prdbatid '+
' GROUP BY  P.PrdId,PB.Prdbatid,DP.PriceId,CmpBatCode,MnfDate,ExpDate,Status,Pb.TaxGroupId,MRP,PurchaseRate,SellingRate'

exec (@InsSQL)
END
GO
--Retailer
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_Retailer' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_Retailer
GO
--Exec Proc_Export_PDA_Retailer 'Test','Intermediate','KS'
CREATE PROCEDURE [dbo].[Proc_Export_PDA_Retailer]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.Retailer Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)
	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.Retailer (SrpCde,RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,
	RtrPhoneNo,RtrEmailId,RtrContactPerson,RtrKeyAcc,RtrCovMode,RtrRegDate,RtrDayOff,RtrStatus,RtrTaxable,RtrTaxType,RtrTINNo,
	RtrCSTNo,RtrDepositAmt,RtrCrBills,RtrCrLimit,RtrCrDays,RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrLicNo,RtrLicExpiryDate,
	RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,GeoMainId,RMId,VillageId,RtrShipId,TaxGroupId,RtrResPhone1,
	RtrResPhone2,RtrOffPhone1,RtrOffPhone2,RtrDOB,RtrAnniversary,CoaId,RtrOnAcc,RtrType,RtrFrequency,
	CtgLevelId,CtgMainID,RtrClassId,ValueClassCode,ValueClassName,CtgLinkCode,CtgName,UploadFlag)'
	Set @InsSQL = @InsSQL +' SELECT ''' + (@SalRpCode) + ''',R.RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,RtrContactPerson,RtrKeyAcc,RtrCovMode,
	RtrRegDate,RtrDayOff,RtrStatus,RtrTaxable,RtrTaxType,RtrTINNo,RtrCSTNo,RtrDepositAmt,RtrCrBills,RtrCrLimit,RtrCrDays,
	RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,
	RtrPestExpiryDate,GeoMainId,RM.RMId,VillageId,RtrShipId,TaxGroupId,RtrResPhone1,RtrResPhone2,RtrOffPhone1,RtrOffPhone2,
	RtrDOB,RtrAnniversary,CoaId,RtrOnAcc,RtrType,RtrFrequency,CtgLevelId,I.CtgMainID,RtrClassId,ValueClassCode,ValueClassName,CtgLinkCode,CtgName,
	''N'' UploadFlag  FROM '+ (@FromDBName) +'.dbo.Retailer R WITH (NOLOCK) INNER JOIN RETAILERVALUECLASSMAP H  WITH (NOLOCK) 
	ON H.RtrId=R.RtrId  INNER JOIN RETAILERVALUECLASS I  WITH (NOLOCK) ON I.RtrClassId=H.RtrValueClassId INNER JOIN RetailerCategory J WITH (NOLOCK) ON J.CtgMainId=I.CtgMainId
	inner join RetailerMarket RM on RM.rtrid=R.Rtrid and RM.rtrid=H.rtrid INNER JOIN SalesmanMarket SM ON SM.RMId = RM.RMId INNER JOIN Salesman S ON S.SMId = SM.SMId
	where SMCode = ''' + @SalRpCode + ''' and RtrStatus=1'	
	EXEC (@InsSQL)

END
GO
--Collection
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_Collection' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_Collection
GO
--Exec Proc_Export_PDA_Collection 'Test','Inter','KS'
CREATE PROCEDURE [dbo].[Proc_Export_PDA_Collection]
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ (@ToDBName) +'.dbo.Collection Where SrpCde = ''' + @SalRpCode + ''''
	EXEC (@DelSQL)

	Set @InsSQL = 'INSERT INTO '+ (@ToDBName) +'.dbo.Collection(SrpCde,SalInvNo,SalInvDte,RtrId,SalNetAmt,UploadFlag,PaidAmount)'
	Set @InsSQL = @InsSQL +' SELECT ''' + (@SalRpCode) + ''',SalInvNo,salinvdate,Rtrid,SalNetAmt,''N'' AS UploadFlag,SalPayAmt 
			FROM '+ (@FromDBName) +'.dbo.salesinvoice WHERE DlvSts=4 AND SalInvDate > DateAdd(m, -3, getdate())'
	EXEC (@InsSQL)

END
GO
--CreditNote
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_Export_PDA_CreditNote' AND xtype ='P')
DROP PROCEDURE Proc_Export_PDA_CreditNote
GO
--Exec Proc_Export_PDA_CreditNote 'Test','Inter','KS'
CREATE PROCEDURE Proc_Export_PDA_CreditNote
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	
	Set @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.CreditNote Where SrpCde = ''' + @SalRpCode + ''''
	exec (@DelSQL)
	Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.CreditNote (SrpCde,CrNo,CrAmount,RtrId,CrAdjAmount,TranNo,Reasonid,UploadFlag)'
	Set @InsSQL = @InsSQL +  ' SELECT ''' + @SalRpCode + ''',CrNoteNumber,Amount,RtrId,CrAdjAmount,Transid,Reasonid, ''N'' AS UploadFlag FROM '+ QuoteName(@FromDBName) + '.dbo.CreditNoteRetailer WHERE (Amount-CrAdjAmount)>0'
	exec (@InsSQL)
END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Export_PDA_DebitNote') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_PDA_DebitNote
GO
--Exec Proc_Export_PDA_DebitNote 'Test','Inter','KS'
CREATE PROCEDURE Proc_Export_PDA_DebitNote
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.DebitNote Where SrpCde = ''' + @SalRpCode + ''''
	exec (@DelSQL)
	Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.DebitNote (SrpCde,DbNo,DbAmount,RtrId,DbAdjAmount,TransNo,Reasonid,UploadFlag)'
	Set @InsSQL = @InsSQL +  ' SELECT ''' + @SalRpCode + ''',DbNoteNumber,Amount,RtrId,DbAdjAmount,Transid,Reasonid,''N'' AS UploadFlag FROM '+ QuoteName(@FromDBName) + '.dbo.DebitNoteRetailer'
	exec (@InsSQL)

END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Export_PDA_ReasonMaster') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_PDA_ReasonMaster
GO
--Exec Proc_Export_PDA_ReasonMaster 'Test','Inter','KS'
CREATE PROCEDURE Proc_Export_PDA_ReasonMaster
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.ReasonMaster Where SrpCde = ''' + @SalRpCode + ''''
	exec (@DelSQL)
	Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.ReasonMaster (SrpCde,ReasonId,ReasonCode,Description,PurchaseReceipt,SalesInvoice,VanLoad,CrNoteSupplier,CrNoteRetailer,
					DeliveryProcess,SalvageRegister,PurchaseReturn,SalesReturn,VanUnload,DbNoteSupplier,DbNoteRetailer,StkAdjustment,
					StkTransferScreen,BatchTransfer,ReceiptVoucher,ReturnToCompany,LocationTrans,Billing,ChequeBouncing,ChequeDisbursal,UploadFlag)'
	Set @InsSQL = @InsSQL +  ' SELECT ''' + @SalRpCode + ''',ReasonId,ReasonCode,Description,PurchaseReceipt,SalesInvoice,VanLoad,CrNoteSupplier,CrNoteRetailer,
DeliveryProcess,SalvageRegister,PurchaseReturn,SalesReturn,VanUnload,DbNoteSupplier,DbNoteRetailer,StkAdjustment,
StkTransferScreen,BatchTransfer,ReceiptVoucher,ReturnToCompany,LocationTrans,Billing,ChequeBouncing,ChequeDisbursal, ''N'' AS UploadFlag
FROM '+ QuoteName(@FromDBName) + '.dbo.ReasonMaster'
	exec (@InsSQL)

END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Export_PDA_Distributor') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_PDA_Distributor
GO
--Exec Proc_Export_PDA_Distributor 'QPS','Intermediate','KS'
CREATE PROCEDURE Proc_Export_PDA_Distributor
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
BEGIN
	Set @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.Distributor'
	exec (@DelSQL)
	Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.Distributor (DistributorId,DistributorCode,DistributorName)'
	Set @InsSQL = @InsSQL +  ' SELECT DistributorId,DistributorCode,DistributorName
			FROM '+ QuoteName(@FromDBName) + '.dbo.Distributor'
	exec (@InsSQL)

END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='tempSalesmanMTDDashBoard' AND xtype='U')
DROP TABLE tempSalesmanMTDDashBoard
GO
CREATE TABLE  tempSalesmanMTDDashBoard 
	(
		TransType int,
		Smid int,
		Smcode nvarchar(50),
		Items	NVARCHAR(100),
		[VALUES]  numeric(18,2)
	)
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Export_PDA_SalesmanMTDDashBoard') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_PDA_SalesmanMTDDashBoard
GO
--Exec Proc_Export_PDA_SalesmanMTDDashBoard 'Loreal','InterDb','DS01'
CREATE PROCEDURE Proc_Export_PDA_SalesmanMTDDashBoard
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @SmId AS int
DECLARE @Fromdate AS datetime 
DECLARE @ToDate AS datetime 
BEGIN
	DELETE FROM tempSalesmanMTDDashBoard

	SELECT  @SmId =Smid FROM Salesman WHERE SMCode=@SalRpCode
	SELECT @Fromdate=CONVERT(VARCHAR(10),DATEADD(dd,-(DAY(GETDATE())-1),GETDATE()),121)  
	SELECT @ToDate=CONVERT(VARCHAR(10),getdate(),121)

	Set @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.SalesmanMTDDashBoard'
	exec (@DelSQL)

		INSERT INTO TempSalesmanMTDDashBoard
		SELECT 1,@SmId,@SalRpCode,'DS Productive %',0
		UNION ALL 
		SELECT 2,@SmId,@SalRpCode,'SKU per call',0
		UNION ALL 
		SELECT 3,@SmId,@SalRpCode,'Total Sales  Value',0
		UNION ALL
		SELECT 4,@SmId,@SalRpCode,'RDBN-Incentive Product',0
		UNION ALL
		SELECT 5,@SmId,@SalRpCode,'Zero Transaction Outlets',0
		UNION ALL
		SELECT 6,@SmId,@SalRpCode,'New Outlet enrolled',0

--UOM TO Convert Metric Tonne

	Select Prdid, Case PrdUnitId WHEN 2 THEN (PrdWgt/1000)/1000
								 WHEN 3 THEN PrdWgt/1000 END AS MetricTon 
	INTO #METRIC FROM Product	

SELECT a.SMID,a.RMID,MAX(RCPMASTERID) RCPMASTERID
INTO #STEP1 FROM RouteCovPlanMaster a,salesman b,routemaster c
where a.smid=b.smid and a.rmid=c.rmid and b.SMId=@SmId 
GROUP BY a.SMID,a.RMID

SELECT SMID,RMID,RCPGENERATEDDATES INTO #STEP2 FROM RouteCovPlanDetails B,#STEP1 A
WHERE A.RCPMASTERID=B.RCPMASTERID

SELECT B.RMID,COUNT(DISTINCT B.RtrId) AS ScheduledCalls INTO #STEP3 FROM Retailer A WITH (NOLOCK) 
INNER JOIN RetailerMarket B WITH (NOLOCK) ON  A.RtrId=B.RtrId 
AND A.RtrStatus=1 GROUP BY B.RMID 

SELECT SMID,B.RMID,RCPGENERATEDDATES,ScheduledCalls INTO #STEP4 FROM #STEP3 A,#STEP2 B WHERE  A.RMID=B.RMID

SELECT A.SMID,SMNAME,A.RMID,RMNAME,RCPGENERATEDDATES,SCHEDULEDCALLS into #PCALLS FROM #step4 A,SALESMAN B,ROUTEMASTER C 
WHERE A.SMID=B.SMID AND A.RMID=C.RMID and RCPGENERATEDDATES BETWEEN @FromDate and @ToDate

SELECT SMNAME [Salesman Name],RMNAme [Route Name],RCPGeneratedDates [Calendar Date],ScheduledCalls [Planned Calls] into #Calendar from #Pcalls

SELECT SMID,SMNAME,SUM(SCHEDULEDCALLS) CALLS INTO #SMPLANNEDCALLS FROM #PCALLS WHERE RCPGENERATEDDATES BETWEEN @FromDate and @ToDate GROUP BY smid,SMNAME

SELECT RMID,RMNAME,SUM(SCHEDULEDCALLS) CALLS INTO #RMPLANNEDCALLS FROM #PCALLS WHERE RCPGENERATEDDATES BETWEEN @FromDate and @ToDate GROUP BY rmid,RMNAME

SELECT
		Salesman.Smid,Salesman.SMCode AS [Salesman Code], Salesman.SMName AS [Salesman Name],
		Routemaster.rmid,RouteMaster.RMCode AS [Route Code], RouteMaster.RMName AS [Route Name],
		TBL_GR_BUILD_RH.HIERARCHY3CAP AS [Retailer Hierarchy 1],
		TBL_GR_BUILD_RH.HIERARCHY2CAP AS [Retailer Hierarchy 2],
		TBL_GR_BUILD_RH.HIERARCHY1CAP AS [Retailer Hierarchy 3],
		Retailer.RtrCode AS [Retailer Code] ,
		Retailer.RtrNAme as [Retailer Name],
		Retailer.RtrRegDate as [Registered Date]
		         INTO #COV
FROM         SalesmanMarket INNER JOIN
Salesman ON SalesmanMarket.SMId = Salesman.SMId INNER JOIN
RouteMaster ON SalesmanMarket.RMId = RouteMaster.RMId INNER JOIN
Retailer INNER JOIN
RetailerMarket ON Retailer.RtrId = RetailerMarket.RtrId ON SalesmanMarket.RMId = RetailerMarket.RMId INNER JOIN
TBL_GR_BUILD_RH ON Retailer.RtrId = TBL_GR_BUILD_RH.RTRID
where rtrstatus=1 and Salesman.SMId =@SmId

SELECT smid,[SALESMAN CODE],COUNT(DISTINCT [RETAILER CODE]) RTRCOUNT INTO #SALRETCOUNT FROM #COV
GROUP BY smid,[SALESMAN CODE]

SELECT rmid,[Route Code],COUNT(DISTINCT [RETAILER CODE]) RTRCOUNT INTO #ROTRETCOUNT FROM #COV
GROUP BY rmid,[Route Code]

SELECT COUNT(DISTINCT [RETAILER CODE]) CNT INTO #TOTALCNT FROM #COV
	
	SELECT a.* INTO #SALINV
	FROM SALESINVOICE A,ROUTEMASTER B, SALESMAN C, RETAILER D  ,TBL_GR_BUILD_RH E
	WHERE SALINVDATE BETWEEN @FromDate and @ToDate AND A.RMID=B.RMID
		    and E.RTRID=A.RTRID AND
			DLVSTS in (4,5) and
			C.SMID=A.SMID AND C.SMId=@SmId
			AND A.RTRID=D.RTRID  
SELECT A.*,C.Brand_Caption INTO #SALESINVOICEPRODUCT FROM SALESINVOICEPRODUCT A,TBL_GR_BUILD_PH C, #SALINV D
	WHERE A.SALID=D.SALID AND A.PRDID=C.PRDID  

--- EXCLUSION PRODUCTS
SELECT PRDID INTO #EXCLUSIONS FROM TBL_GR_BUILD_PH A WHERE BRAND_CODE NOT IN (SELECT BRANDCODE FROM BRANDEXCLUSION )
SELECT PRDID,BRAND_cODE,BRAND_CAPTION,COMPANY_CODE,COMPANY_cAPTION INTO #BRANDEXCLUSIONS FROM TBL_GR_BUILD_PH WHERE  BRAND_CODE IN (SELECT BRANDCODE FROM BRANDEXCLUSION)

CREATE TABLE #SALESMAN
(
	smid int,
	[Salesman Name] nvarchar(100),
	[Active Retailers] int,  
	[Total Retailers Billed] int,  	
	[Planned Calls] int,  
	[Effective Reach] int,
	[Productivity %] numeric(18,2),
	[Lines Sold (All SKU)] int,
	[SKU per Call (All SKU)] numeric(18,2),
    [Outlets Created] int,
	[RDBN (All SKU)] numeric(18,2),
)

Insert into #salesman Select smid,SMNAME,0,0,0,0,0,0,0,0,0 from Salesman WHERE SMCode=@SalRpCode

UPDATE #SALESMAN SET [Active Retailers]= RTRCOUNT  
FROM #SALESMAN A,#SALRETCOUNT B WHERE A.SMID=B.SMID  


SELECT     smid,COUNT(DISTINCT RTRID) trb into #RtrBilled FROM    #salinv INNER JOIN
#Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
Product ON #Salesinvoiceproduct.PrdId = Product.PrdId
group by smid

UPDATE #SALESMAN  SET [Total Retailers Billed]= trb  FROM #SALESMAN A,#rtrBilled B  
WHERE A.SMID=B.SMID  

UPDATE #SALESMAN SET [Outlets Created]=cnt from #salesman a,
	(SELECT smid,COUNT([Registered Date]) CNT FROM #cov WHERE [Registered Date] 
		BETWEEN @FromDate and @ToDate group by smid) B
Where a.smid=b.smid

UPDATE #SALESMAN  SET [Planned Calls]= calls  FROM #SALESMAN A,#smplannedcalls B  
WHERE A.SMID=B.SMID  

SELECT     smid,COUNT(DISTINCT RTRID) EffectiveReach
	into #effectiverch FROM    #salinv INNER JOIN
	#Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
	Product ON #Salesinvoiceproduct.PrdId = Product.PrdId
	group by smid,salinvdate

UPDATE #SALESMAN SET [Effective Reach]= efr 
FROM #SALESMAN A,(Select SMid,Sum(EffectiveReach)efr from #effectiverch group by smid) B
WHERE A.SMID=B.SMID

SELECT smid,COUNT(DISTINCT #Salesinvoiceproduct.Prdid) linessold into #linessold FROM    #salinv INNER JOIN    
#Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN    
Product ON #Salesinvoiceproduct.PrdId = Product.PrdId  group by smid,rtrid,salinvdate    

UPDATE #SALESMAN SET [Lines Sold (All SKU)]= efr FROM #SALESMAN A,(Select SMid,Sum(linessold)efr
from #linessold group by smid) B    
WHERE A.SMID=B.SMID 

SELECT     smid,sum(PrdNetAmount) red,Sum(BaseQty * MetricTon) as MTON
into #Redistribution FROM    #salinv INNER JOIN
#Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
Product ON #Salesinvoiceproduct.PrdId = Product.PrdId
INNER JOIN #METRIC MT ON Product.Prdid=MT.Prdid
group by smid

SELECT     smid,sum(PrdNetAmount) red
into #Redistributionex FROM    #salinv INNER JOIN
#Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
Product ON #Salesinvoiceproduct.PrdId = Product.PrdId INNER JOIN #EXCLUSIONS ON PRODUCT.PRDID=#EXCLUSIONS.PRDID
group by smid

UPDATE #SALESMAN SET [RDBN (All SKU)]= red FROM #SALESMAN A,#Redistribution B WHERE A.SMID=B.SMID  

UPDATE #SALESMAN SET [SKU Per Call (All SKU)]=cast ([Lines Sold (All SKU)] as numeric(18,2))/case [Effective Reach] when 0 then 1 else cast([Effective Reach] as numeric(18,2)) end
UPDATE #SALESMAN SET [Productivity %]=(cast([Effective Reach] as numeric(18,2))/case [Planned Calls] when 0 then 1.00 else cast([Planned Calls] as numeric(18,2)) end)*100
UPDATE #SALESMAN SET [Productivity %]=0 where [Planned Calls]=0

---Infant Nutrition Sales
--SELECT X.SMID,Smcode,SUM(PrdNetAmount-RetPrdNetAmt) as NetSales
--INTO #InfantNutritionSales FROM(
--	SELECT SMID,RMID,SUM(PrdNetAmount) as PrdNetAmount,0 as RetPrdNetAmt
--	FROM SalesInvoice SI
--	INNER JOIN SalesInvoiceProduct SIP On SIP.Salid=Si.Salid
--	INNER JOIN Product P ON P.PrdId=SIP.prdid
--	WHERE Salinvdate Between @Fromdate and @ToDate and Dlvsts>3
--	AND SMID=@SmId AND P.Vending=3
--	GROUP BY SMID,RMID,BillMode
--UNION ALL
--	SELECT SMID,RMID,0 as PrdNetAmount,SUM(PrdNetAmt)  as RetPrdNetAmt
--	FROM ReturnHeader SI
--	INNER JOIN ReturnProduct SIP ON SI.ReturnID=SIP.ReturnID
--	INNER JOIN Product P ON P.PrdId=SIP.prdid
--	WHERE ReturnDate Between @FromDate and @ToDate and Status=0
--	AND SMID=@SmId AND P.Vending=3
--	GROUP BY SMID,RMID
--)X INNER JOIN salesman SM ON X.smid=SM.smid GROUP BY X.SMID,Smcode

SELECT SM.SMID,Smcode,SUM(PrdNetAmount) as NetSales
	INTO #InfantNutritionSales  FROM SalesInvoice SI
	INNER JOIN SalesInvoiceProduct SIP On SIP.Salid=Si.Salid
	INNER JOIN Product P ON P.PrdId=SIP.prdid
	INNER JOIN #EXCLUSIONS E ON E.Prdid=SIP.Prdid and E.Prdid=P.Prdid
	INNER JOIN salesman SM ON SI.smid=SM.smid 
	WHERE Salinvdate Between @FromDate and @ToDate and Dlvsts>3
	AND SM.SMID=@SmId
	GROUP BY SM.SMID,Smcode

UPDATE tempSalesmanMTDDashBoard SET [VALUES]=[Productivity %] FROM tempSalesmanMTDDashBoard T INNER JOIN #SALESMAN S
ON T.smid=S.smid WHERE TransType=1

UPDATE tempSalesmanMTDDashBoard SET [VALUES]=[SKU per Call (All SKU)] FROM tempSalesmanMTDDashBoard T INNER JOIN #SALESMAN S
ON T.smid=S.smid WHERE TransType=2

UPDATE tempSalesmanMTDDashBoard SET [VALUES]=[RDBN (All SKU)] FROM tempSalesmanMTDDashBoard T INNER JOIN #SALESMAN S
ON T.smid=S.smid WHERE TransType=3

UPDATE K SET K.[VALUES]=P.NetSales FROM TempSalesmanMTDDashBoard K INNER JOIN #InfantNutritionSales P 
ON P.Smcode=K.Smcode WHERE TransType=4

UPDATE K SET K.[VALUES]=[Active Retailers]-[Total Retailers Billed] FROM TempSalesmanMTDDashBoard K INNER JOIN #SALESMAN S
ON K.smid=S.smid WHERE TransType=5

UPDATE tempSalesmanMTDDashBoard SET [VALUES]=[Outlets Created] FROM tempSalesmanMTDDashBoard T INNER JOIN #SALESMAN S
ON T.smid=S.smid WHERE TransType=6

Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.SalesmanMTDDashBoard (srpCde,Items,[VALUES])'
Set @InsSQL = @InsSQL +'select Smcode,Items,[VALUES]
		FROM '+ QuoteName(@FromDBName) + '.dbo.TempSalesmanMTDDashBoard'
exec (@InsSQL)
--SELECT *   FROM tempSalesmanMTDDashBoard
--SELECT * FROM SalesmanMTDDashBoard
END 
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_ExportImport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_ExportImport]
GO
--Exec Proc_ExportImport 'jnj','jnjinter','S3','S3',0
CREATE PROCEDURE [Proc_ExportImport]
(
	@FromDBName VARCHAR(50),
	@ToDBName VARCHAR(50),
	@SalRpCode VARCHAR(50),
	@MktCode VARCHAR(50),
	@Process INT
)
AS
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)

BEGIN
	IF @Process = 0
	BEGIN
		Exec Proc_Export_PDA_SalesRepresentative @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_Market @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_Bank @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_BankBranch @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_ProductCategory @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_ProductCategoryValue @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_Products @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_ProductBatch @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_Retailer @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_Collection @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_CreditNote @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_DebitNote @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Export_PDA_ReasonMaster @FromDBName,@ToDBName,@SalRpCode
		EXEC Proc_Export_PDA_Distributor @FromDBName,@ToDBName,@SalRpCode
		--EXEC Proc_Export_PDA_SalesmanMTDDashBoard  @FromDBName,@ToDBName,@SalRpCode
		EXEC Proc_Export_PDA_RetailerWisesales @FromDBName,@ToDBName,@SalRpCode
		
	END
	ELSE IF @Process = 1
	BEGIN
		Exec Proc_Import_PDA_OrderBooking @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Import_PDA_SalesReturn @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Import_PDA_CreditNote @FromDBName,@ToDBName,@SalRpCode
		Exec Proc_Import_PDA_DebitNote @FromDBName,@ToDBName,@SalRpCode
		
	END
END
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'PDALog') AND type in (N'U'))
DROP TABLE PDALog
GO
CREATE TABLE PDALog(
	[Sno] [int] IDENTITY(1,1) NOT NULL,
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataPoint] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_Temp_OrderBooking]') AND type in (N'U'))
DROP TABLE [PDA_Temp_OrderBooking]
GO

CREATE TABLE [PDA_Temp_OrderBooking](
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OrdKeyNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OrdDt] [datetime] NULL,
	[RtrCde]  Nvarchar(20) NOT NULL,
	[Mktid] [int] NULL,	
	[SrpId] [int] NOT NULL,
	[Rtrid]	[Int] NOT NULL,
	[UploadFlag] varchar(1) NULL)
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_Temp_OrderProduct]') AND type in (N'U'))
DROP TABLE [PDA_Temp_OrderProduct]
GO

CREATE TABLE [PDA_Temp_OrderProduct](
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OrdKeyNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrdId] [int] NOT NULL,
	[PrdBatId] [int] NOT NULL,
	[PriceId]	[Int] NOT NULL,
	[OrdQty] [int] NULL,
	[UploadFlag] varchar(1) NULL
)
GO

--SALES RETURN
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_Temp_SalesReturn]') AND type in (N'U'))
DROP TABLE [PDA_Temp_SalesReturn]
GO

CREATE TABLE [PDA_Temp_SalesReturn](
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SrNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SrDate] [datetime] NULL,
	[SalInvNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrCde]  Nvarchar(20) NULL,
	[Mktid] [int] NULL DEFAULT (0),
	[Srpid] [int] NULL DEFAULT (0),
	[ReturnMode] [INT] NOT NULL  DEFAULT (0),
	[InvoiceType] [INT] NOT NULL  DEFAULT (0),
	[RtrId]			[INT] NOT NULL DEFAULT (0),
	[UploadFlag] varchar(1) NULL
)
GO

--SALES RETURN PRODUCT
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_Temp_SalesReturnProduct]') AND type in (N'U'))
DROP TABLE [PDA_Temp_SalesReturnProduct]
GO

CREATE TABLE [PDA_Temp_SalesReturnProduct](
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SrNo]    Nvarchar(25),
	[PrdId] [int] NOT NULL,
	[PrdBatId] [int] NOT NULL,
	[PriceId]	[Int] NOT NULL,
	[SrQty] [int] NULL,
	[UsrStkTyp] [int] NOT NULL,
	[salinvno] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (0),
	[SlNo] [int] NOT NULL DEFAULT (0),
	[UploadFlag] varchar(1) NULL
) 
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_SalesReturn]') AND type in (N'U'))
DROP TABLE [PDA_SalesReturn]
GO

CREATE TABLE [PDA_SalesReturn](
	[SrNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SrDate] [datetime] NULL,
	[SalInvNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId]			[INT] NOT NULL DEFAULT (0),
	[Mktid] [int] NULL DEFAULT (0),
	[Srpid] [int] NULL DEFAULT (0),
	[ReturnMode] [INT] NOT NULL  DEFAULT (0),
	[InvoiceType] [INT] NOT NULL  DEFAULT (0),
	[Status] INT
)
GO

--SALES RETURN PRODUCT
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_SalesReturnProduct]') AND type in (N'U'))
DROP TABLE [PDA_SalesReturnProduct]
GO

CREATE TABLE [PDA_SalesReturnProduct](
    [SrNo]    Nvarchar(25),
	[PrdId] [int] NOT NULL,
	[PrdBatId] [int] NOT NULL,
	[PriceId]	[Int] NOT NULL,
	[SrQty] [int] NULL,
	[UsrStkTyp] [int] NOT NULL,
	[salinvno] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (0),
	[SlNo] [int] NOT NULL DEFAULT (0)
) 
GO


IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_Temp_CreditNote]') AND type in (N'U'))
DROP TABLE [PDA_Temp_CreditNote]
GO

CREATE TABLE [PDA_Temp_CreditNote](
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CrNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CrAmount] [numeric](18, 2) NULL,
	[RtrId] [numeric](18, 0) NOT NULL,
	[CrAdjAmount] [numeric](18, 2) NULL,
	[TranNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Reasonid] [int] NULL,
	[UploadFlag] varchar(1) NULL
)
GO

--DEBIT NOTE
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDA_Temp_DebitNote]') AND type in (N'U'))
DROP TABLE [PDA_Temp_DebitNote]
GO

CREATE TABLE [PDA_Temp_DebitNote](
	[SrpCde] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DbNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DbAmount] [numeric](18, 2) NOT NULL,
	[RtrId] [numeric](18, 0) NOT NULL,
	[DbAdjAmount] [numeric](18, 2) NULL,
	[TransNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Reasonid] [int] NULL,
	[UploadFlag] varchar(1) NULL
)
GO

--Import OrderBooking
IF EXISTS (SELECT * FROM sysobjects WHERE name ='Proc_Import_PDA_OrderBooking'  AND xtype='P')
DROP PROCEDURE [Proc_Import_PDA_OrderBooking]
GO
CREATE PROCEDURE [Proc_Import_PDA_OrderBooking]      
(      
	@FromDBName varchar(50),      
	@ToDBName varchar(50),      
	@SalRpCode varchar(50)      
)      
AS      
      
/*********************************/      
DECLARE @SQL AS nvarchar(3000)      
DECLARE @OPSQL AS nvarchar(3000)      
DECLARE @DelSQL AS varchar(1000)      
DECLARE @InsSQL AS varchar(5000)      
DECLARE @UpdSQL AS varchar(1000)      
DECLARE @UpdFlgSQL AS varchar(1000)      
DECLARE @OrdKeyNo AS VARCHAR(25)      
DECLARE @UpdOPFlgSQL AS varchar(1000)      
DECLARE @CurrVal AS INT      
DECLARE @RtrId AS INT      
DECLARE @MktId AS INT      
DECLARE @SrpId AS INT      
DECLARE @lError AS INT      
DECLARE @GetKeyStr AS Varchar(50)
DECLARE @RtrShipId AS INT
DECLARE @OrdPrdCnt AS INT
DECLARE @PdaOrdPrdCnt AS INT
DECLARE @OrderDate AS DateTime
      
BEGIN
	BEGIN TRANSACTION T1
	IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_OrderBooking]') AND type in (N'U'))
	BEGIN
		DROP TABLE PDA_Temp_OrderBooking
	END

	Set @SQL = ' SELECT SrpCde,OrdKeyNo,OrdDt,RtrCde,Mktid,SrpId,R.Rtrid,UploadFlag INTO PDA_Temp_OrderBooking '
	SET  @SQL = @SQL+ 'FROM '+ QuoteName(@ToDBName) + '.dbo.OrderBooking OB INNER JOIN Retailer R on OB.RtrCde=R.RtrCode '
	SET  @SQL = @SQL+' WHERE UploadFlag = ''N'' AND SrpCde = ''' + @SalRpCode + ''''

	EXEC(@SQL)

	SET @SrpId = (SELECT SMId FROM SalesMan Where SMCode = @SalRpCode)
	DECLARE CUR_Import Cursor For
	Select DISTINCT OrdKeyNo  From PDA_Temp_OrderBooking
	OPEN CUR_Import
	FETCH NEXT FROM CUR_Import INTO @OrdKeyNo
	While @@Fetch_Status = 0
	BEGIN
		SET @OrdPrdCnt=0
		SET @PdaOrdPrdCnt=0
		SET @lError = 0
		SET @RtrId=0
		SET @RtrShipId=0
		SET @MktId=0
		IF NOT EXISTS (SELECT DocRefNo FROM OrderBooking WHERE DocRefNo = @OrdKeyNo)
		BEGIN
			SET @RtrId = (Select RtrId FROM PDA_Temp_OrderBooking WHERE OrdKeyNo = @OrdKeyNo)
			IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrID = @RtrId AND RtrStatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@RtrId,'Retailer Does Not Exists for the Order ' + @OrdKeyNo--FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
			END

			SELECT @RtrShipId=RS.RtrShipId   
			FROM RetailerShipAdd RS (NOLOCK) INNER JOIN Retailer R (NOLOCK) ON R.Rtrid= RS.Rtrid WHERE RtrShipDefaultAdd=1  
			AND R.RtrId=@RtrId  

			SET @MktId = (Select MktId FROM PDA_Temp_OrderBooking WHERE OrdKeyNo = @OrdKeyNo)
			IF NOT EXISTS (SELECT RMID FROM RouteMaster WHERE RMID = @MktId AND RMstatus = 1)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@MktId,'Market Does Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
			END

			IF NOT EXISTS (SELECT * FROM SalesManMarket WHERE RMID = @MktId AND SMID = @SrpId)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@MktId,'Market Not Maped with the DBSR for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
			END

			IF EXISTS (SELECT NAME FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_OrderProduct]') AND type in (N'U'))
			BEGIN
				DROP TABLE PDA_Temp_OrderProduct
			END
			Set @OPSQL = 'SELECT * INTO PDA_Temp_OrderProduct FROM '+ QuoteName(@ToDBName) + '.dbo.OrderProduct WHERE UploadFlag = ''N'' AND SrpCde = ''' + @SalRpCode + ''' AND OrdKeyNo = ''' + @OrdKeyNo + ''''
			EXEC(@OPSQL)

			IF NOT EXISTS(SELECT OrdKeyNo FROM  PDA_Temp_OrderProduct WHERE OrdKeyNo=@OrdKeyNo)
			BEGIN
				SET @lError = 1
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
				SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,' Product Details Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
			END
			IF @lError=0
			BEGIN
				DECLARE @Prdid AS INT
				DECLARE @Prdbatid AS INT
				DECLARE @PriceId AS INT
				DECLARE @OrdQty AS INT
				DECLARE CUR_ImportOrderProduct CURSOR FOR
				SELECT PrdId,PrdBatId,PriceId,Sum(OrdQty) as OrdQty  From PDA_Temp_OrderProduct WHERE OrdKeyNo=@OrdKeyNo GROUP BY PrdId,PrdBatId,PriceId
				OPEN CUR_ImportOrderProduct
				FETCH NEXT FROM CUR_ImportOrderProduct INTO @Prdid,@Prdbatid,@PriceId,@OrdQty
				WHILE @@FETCH_STATUS = 0
				BEGIN
						
						IF NOT EXISTS(SELECT PrdId From Product WHERE Prdid=@Prdid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@Prdid,' Product Does Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF NOT EXISTS(SELECT PrdId,Prdbatid From ProductBatch WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@Prdbatid,' Product Batch Does Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF NOT EXISTS(SELECT Prdbatid From ProductBatchDetails WHERE Prdbatid=@Prdbatid and PriceId=@PriceId)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@PriceId,' Product Batch Price Does Not Exists for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF @OrdQty<=0
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdQty,' Ordered Qty Should be Greater than Zero for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END

						

				FETCH NEXT FROM CUR_ImportOrderProduct INTO @Prdid,@Prdbatid,@PriceId,@OrdQty
				END
				CLOSE CUR_ImportOrderProduct
				DEALLOCATE CUR_ImportOrderProduct

				SET @GetKeyStr=''  
				SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('OrderBooking','OrderNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))       
				IF LEN(LTRIM(RTRIM(@GetKeyStr)))=0  
				BEGIN  
					SET @lError = 1
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,' Ordered Key No not generated' --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
					BREAK  
				END

			IF @lError = 0
			BEGIN
				--HEDER 
					SELECT  @OrderDate= OrdDt FROM PDA_Temp_OrderBooking WHERE  OrdKeyNo=@OrdKeyNo
					INSERT INTO OrderBooking(  
					OrderNo,OrderDate,DeliveryDate,CmpId,DocRefNo,AllowBackOrder,SmId,RmId,RtrId,OrdType,  
					Priority,FillAllPrd,ShipTo,RtrShipId,Remarks,RoundOff,RndOffValue,TotalAmount,Status,  
					Availability,LastModBy,LastModDate,AuthId,AuthDate,PDADownLoadFlag)  
					SELECT @GetKeyStr,Convert(DateTime,@OrderDate,121),  
					Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
					0,@OrdKeyNo,0, @SrpId as Smid,  
					@MktId as RmId,@RtrId as RtrId,0 as OrdType,0 as Priority,0 as FillAllPrd,0 as ShipTo,  
					@RtrShipId as RtrShipId,'' as Remarks,0  as RoundOff,0 as RndOffValue,  
					0 as TotalAmount,0 as Status,1,1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
					1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),1  

				   --DETAILS  
				  INSERT INTO ORDERBOOKINGPRODUCTS(OrderNo,PrdId,PrdBatId,UOMId1,Qty1,ConvFact1,UOMId2,Qty2,  
						  ConvFact2,TotalQty,BilledQty,Rate,MRP,GrossAmount,PriceId,  
						  Availability,LastModBy,LastModDate,AuthId,AuthDate)  
				  SELECT @GetKeyStr,P.Prdid,PB.Prdbatid,UG.UomID,  
				  --Cast(QtyPUnit as Int)*Cast(numberOfPackingUnits as Int),  
				  OrdQty ,  
				  ConversionFactor,0,0,0,  
				  --Cast(QtyPUnit as Int)*Cast(numberOfPackingUnits as Int),0,  
				  OrdQty,0,  
				  PBD.PrdBatDetailValue,PBD1.PrdBatDetailValue,  
				  --PBD.PrdBatDetailValue*(Cast(QtyPUnit as Int)*Cast(numberOfPackingUnits as Int)),  
				  PBD.PrdBatDetailValue*OrdQty,  
				  PBD.PriceId,  
				  1,1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
				  1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121)  
				  FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
				  INNER JOIN (SELECT PrdId,PrdBatId,PriceId,Sum(OrdQty) as OrdQty  FROM PDA_Temp_OrderProduct WHERE OrdKeyNo=@OrdKeyNo
							 GROUP BY PrdId,PrdBatId,PriceId) PT ON PT.Prdid=P.PrdId and PT.Prdbatid=Pb.Prdbatid and Pb.PrdId=PT.Prdid	
				  INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId=PB.BatchSeqId  
				  INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD.PriceId  
					 and BC.slno=PBD.SLNo AND BC.SelRte=1  and PBD.PriceId=PT.PriceId
				  INNER JOIN BatchCreation BC1 (NOLOCK) ON BC1.BatchSeqId=PB.BatchSeqId  
				  INNER JOIN ProductBatchDetails PBD1 (NOLOCK) ON PBD1.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD1.PriceId  
					 and BC1.slno=PBD1.SLNo AND BC1.MRP=1  and PBD1.PriceId=PT.PriceId
				  INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId and BaseUom='Y'  
--				  GROUP BY  
--				  P.Prdid,PB.Prdbatid,UG.UomID,PBD.PrdBatDetailValue,  
--				  PBD1.PrdBatDetailValue,PBD.PriceId,ConversionFactor 

				  UPDATE OB SET TotalAmount=X.TotAmt FROM OrderBooking OB   
				  INNER JOIN(SELECT ISNULL(SUM(GrossAmount),0)as TotAmt,OrderNo  FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr GROUP BY OrderNo )X   
				  ON X.OrderNo=OB.OrderNo   

				SELECT SrpCde,OrdKeyNo,PrdId,PrdBatId,PriceId,--@GetKeyStr as CSOrderNo,
				SUM(OrdQty) as Qty  
				INTO #TEMPCHECK   
				FROM PDA_Temp_OrderProduct WHERE OrdKeyNo=@OrdKeyNo
				GROUP BY  
				SrpCde,OrdKeyNo,PrdId,PrdBatId,PriceId
        
					
				
				SELECT @OrdPrdCnt=ISNULL(Count(OrderNo),0) FROM ORDERBOOKINGPRODUCTS (NOLOCK) WHERE OrderNo=@GetKeyStr  
				SELECT @PdaOrdPrdCnt=ISNULL(Count(OrdKeyNo),0) FROM #TEMPCHECK (NOLOCK) WHERE OrdKeyNo=@OrdKeyNo
						IF @OrdPrdCnt=@PdaOrdPrdCnt  
						BEGIN 
							UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='OrderBooking' and FldName='OrderNo' 
				
							SET @UpdFlgSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.OrderBooking SET UploadFlag = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and UploadFlag = ''N'' AND OrdKeyNo = ''' + @OrdKeyNo + ''''
							EXEC(@UpdFlgSQL)

							SET @UpdOPFlgSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.OrderProduct SET UploadFlag = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and UploadFlag = ''N'' AND OrdKeyNo = ''' + @OrdKeyNo + ''''
							EXEC(@UpdOPFlgSQL)
						END
						ELSE
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,' Ordered Product Number of line count not match for the Order ' + @OrdKeyNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
							DELETE FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr  
							DELETE FROM ORDERBOOKING WHERE OrderNo=@GetKeyStr  
						END 
	
				
				DROP TABLE #TEMPCHECK
				END
			END
		END
		ELSE
		BEGIN
			Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'ORDERBOOKING'
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
			SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,'Order Already exists' --FROM TempOrderBooking WHERE OrdKeyNo=@OrdKeyNo
		END
		
		FETCH NEXT FROM CUR_Import INTO @OrdKeyNo
	END
	Close CUR_Import
	DeAllocate CUR_Import

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION T1
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION T1
	END
END

GO




--SalesReturn
IF EXISTS (SELECT * FROM sysobjects WHERE name ='Proc_Import_PDA_SalesReturn'  AND xtype='P')
DROP PROCEDURE [Proc_Import_PDA_SalesReturn]
GO
CREATE  PROCEDURE [Proc_Import_PDA_SalesReturn]      
(      
 @FromDBName varchar(50),      
 @ToDBName varchar(50),      
 @SalRpCode varchar(50)      
)      
AS      
DECLARE @SQL AS nvarchar(3000)      
DECLARE @OPSQL AS nvarchar(3000)      
DECLARE @DelSQL AS varchar(1000)      
DECLARE @InsSQL AS varchar(5000)      
DECLARE @UpdSQL AS varchar(1000)      
DECLARE @UpdFlgSQL AS varchar(1000)      
DECLARE @SrNo AS VARCHAR(25)      
DECLARE @UpdOPFlgSQL AS varchar(1000)      
DECLARE @CurrVal AS INT      
DECLARE @RtrId AS INT      
DECLARE @MktId AS INT      
DECLARE @SrpId AS INT      
DECLARE @lError AS INT    
DECLARE @SalInvNo AS nVarchar(50)
DECLARE @Salid AS INT  
      
BEGIN      
 BEGIN TRANSACTION T1      
 IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_SalesReturn]') AND type in (N'U'))      
 BEGIN      
  DROP TABLE PDA_Temp_SalesReturn      
 END   

 IF  EXISTS(SELECT SMId FROM SalesMan (Nolock) Where SMCode = @SalRpCode)
 BEGIN
      
		 Set @SQL = 'SELECT SrpCde,SrNo,SrDate,SalInvNo,RtrCde,Mktid,Srpid,ReturnMode,InvoiceType,R.RtrId,UploadFlag '  
		 Set @SQL =@SQL+ ' INTO PDA_Temp_SalesReturn FROM '+ QuoteName(@ToDBName) + '.dbo.SalesReturn SR INNER JOIN Retailer R ON R.RtrCode=SR.RtrCde '  
		 Set @SQL =@SQL+ ' WHERE UploadFlag = ''N'' AND SrpCde = ''' + @SalRpCode + ''''   
		 EXEC(@SQL)      
		--SELECT * From PDA_Temp_SalesReturnProduct      
		 SET @SrpId = (SELECT SMId FROM SalesMan (Nolock) Where SMCode = @SalRpCode)      
				
		 DECLARE CUR_Import Cursor For      
		 Select Distinct SrNo From PDA_Temp_SalesReturn          
		 OPEN CUR_Import      
		 FETCH NEXT FROM CUR_Import INTO @SrNo      
		 While @@Fetch_Status = 0      
		 BEGIN      
		  SET @lError = 0
		  SET @SalInvNo	=''
		  SET @RtrId=0
		  SET @MktId=0
		  SET @SalId=0			
		  IF NOT EXISTS (SELECT DocRefNo FROM ReturnHeader WHERE DocRefNo = @SrNo)      
		  BEGIN      
			   SET @RtrId = (Select RtrId FROM PDA_Temp_SalesReturn WHERE SrNo = @SrNo)       
			   IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE Rtrid = @RtrId and RtrStatus = 1)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@RtrId,'Retailer Does Not Exists for the SalesReturn No ' + @SrNo 
			   END      
		      
			   SET @MktId = (Select MktId FROM PDA_Temp_SalesReturn WHERE SrNo = @SrNo)       
			   IF NOT EXISTS (SELECT RMID FROM RouteMaster WHERE RMID = @MktId AND RMstatus = 1)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@MktId,'Market Does Not Exists for the SalesReturn No ' + @SrNo 
			   END      
		      
			   IF NOT EXISTS (SELECT RMId,SMId FROM SalesManMarket WHERE RMId = @MktId AND SMId = @SrpId)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@MktId,'Market Not Maped with the DBSR for the SalesReturn No ' + @SrNo  
			   END

			   IF NOT EXISTS (SELECT RMId,RtrId FROM RetailerMarket WHERE RMId = @MktId AND RtrId = @RtrId)      
			   BEGIN      
				SET @lError = 1      
				INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
				SELECT '' + @SalRpCode + '','SALESRETURN',@MktId,'Market Not Maped with the Retailer for the SalesReturn No ' + @SrNo  
			   END

				IF EXISTS(SELECT SalInvNo FROM PDA_Temp_SalesReturn WHERE SrNo = @SrNo and InvoiceType=1)
				BEGIN
					SELECT @SalInvNo=ISNULL(SalInvNo,'') FROM PDA_Temp_SalesReturn WHERE SrNo = @SrNo and InvoiceType=1
					IF LEN(@SalInvNo)=0 
					BEGIN
						SET @lError = 1      
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
						SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,'Reference Invoice not exist for the SalesReturn No' + @SrNo 
					END
					ELSE IF NOT EXISTS(SELECT SalId From SalesInvoice WHERE Salinvno=@SalInvNo)
					BEGIN
						SET @lError = 1      
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
						SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,'Reference  SalesInvoice not exist for the SalesReturn No' + @SrNo 
					END
				END

				IF EXISTS (SELECT NAME FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_SalesReturnProduct]') AND type in (N'U'))
				BEGIN
					DROP TABLE PDA_Temp_SalesReturnProduct
				END
				Set @OPSQL = 'SELECT * INTO PDA_Temp_SalesReturnProduct FROM '+ QuoteName(@ToDBName) + '.dbo.SalesReturnProduct WHERE UploadFlag = ''N'' AND SrpCde = ''' + @SalRpCode + ''' AND SrNo = ''' + @SrNo + ''''
				EXEC(@OPSQL)

				IF NOT EXISTS(SELECT SrNo FROM  PDA_Temp_SalesReturnProduct WHERE SrNo=@SrNo)
				BEGIN
					SET @lError = 1
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,' Product Details Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
				END


			IF @lError=0
			BEGIN
				DECLARE @Prdid AS INT
				DECLARE @Prdbatid AS INT
				DECLARE @PriceId AS INT
				DECLARE @RtnQty AS INT
				DECLARE @StockType AS INT
				DECLARE @SalinvnoRef AS nVarchar(50)
				DECLARE @UsrStkTyp AS INT
				DECLARE @Slno AS INT
				DECLARE CUR_ImportReturnProduct CURSOR FOR
				SELECT PrdId,PrdBatId,PriceId,SrQty ,UsrStkTyp,salinvno,SlNo From PDA_Temp_SalesReturnProduct WHERE SrNo=@SrNo  ORDER BY SlNo 
				OPEN CUR_ImportReturnProduct
				FETCH NEXT FROM CUR_ImportReturnProduct INTO @Prdid,@Prdbatid,@PriceId,@RtnQty,@UsrStkTyp,@SalinvnoRef,@Slno
				WHILE @@FETCH_STATUS = 0
				BEGIN
						
						IF NOT EXISTS(SELECT PrdId From Product (NOLOCK) WHERE Prdid=@Prdid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@Prdid,' Product Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF NOT EXISTS(SELECT PrdId,Prdbatid From ProductBatch WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@Prdbatid,' Product Batch Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF NOT EXISTS(SELECT Prdbatid From ProductBatchDetails WHERE Prdbatid=@Prdbatid and PriceId=@PriceId)
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@PriceId,' Product Batch Price Does Not Exists for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END
						IF @RtnQty<=0
						BEGIN
							SET @lError = 1
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,' Return Qty Should be Greater than Zero for the SalesReturn No ' + @SrNo --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						END

						

				FETCH NEXT FROM CUR_ImportReturnProduct INTO  @Prdid,@Prdbatid,@PriceId,@RtnQty,@UsrStkTyp,@SalinvnoRef,@Slno
				END
				CLOSE CUR_ImportReturnProduct
				DEALLOCATE CUR_ImportReturnProduct
		 

					IF @lError = 0       
					BEGIN
						--HEADER	   
						INSERT INTO PDA_SalesReturn (SrNo,SrDate,SalInvNo,RtrId,Mktid,Srpid,ReturnMode,InvoiceType,Status)
						SELECT SrNo,Getdate(),SalInvNo,RtrId,Mktid,@SrpId,ReturnMode,InvoiceType,0
						FROM PDA_Temp_SalesReturn WHERE SrNo=@SrNo
						--DETAILS
						INSERT INTO PDA_SalesReturnProduct(SrNo,PrdId,PrdBatId,PriceId,SrQty,UsrStkTyp,salinvno,SlNo)
						SELECT @SrNo,PrdId,PrdBatId,PriceId,SrQty ,UsrStkTyp,salinvno,SlNo From PDA_Temp_SalesReturnProduct  
						WHERE SrNo=@SrNo


						SET @UpdFlgSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.SalesReturn SET UploadFlag = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and UploadFlag = ''N'' AND SrNo = ''' + @SrNo + ''''      
						EXEC(@UpdFlgSQL)      

						SET @UpdOPFlgSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.SalesReturnProduct SET [UploadFlag] = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and [UploadFlag] = ''N'' AND SrNo = ''' + @SrNo + ''''      
						EXEC(@UpdOPFlgSQL)      


					END 
			END      
		  END      
		  ELSE      
		  BEGIN      
			   Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'SALESRETURN'      
			   INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
			   SELECT '' + @SalRpCode + '','SALESRETURN',@SrNo,'Sales Return Already exists'      
		  END       
		FETCH NEXT FROM CUR_Import INTO @SrNo      
		END      
		CLOSE CUR_Import      
		DEALLOCATE CUR_Import     
END
ELSE
BEGIN
		 INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)      
		 SELECT '' + @SalRpCode + '','SALESRETURN',@SalRpCode,'SalesMan Does not exists ' 
END 
      
 IF @@ERROR = 0      
 BEGIN      
  COMMIT TRANSACTION T1      
 END      
 ELSE      
 BEGIN      
  ROLLBACK TRANSACTION T1      
 END      
END      

GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Import_PDA_CreditNote') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Import_PDA_CreditNote
GO
--Exec Proc_Import_PDA_CreditNote 'NesFresh','NestleConsole','S001'
CREATE PROCEDURE Proc_Import_PDA_CreditNote
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
/*********************************
* PROCEDURE: [Proc_Import_PDA_CreditNote]
* PURPOSE: To Insert the records From Intermediate into CoreStocky Database
* SCREEN : CREDITNOTE
* CREATED: MURUGAN.R
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*********************************/
DECLARE @SQL AS nvarchar(3000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @UpdSQL AS varchar(1000)
DECLARE @Crno AS varchar(20)
DECLARE @Cramount AS numeric(18,2)
DECLARE @Rtrid AS numeric(18,0)
DECLARE @Cradjamt AS numeric(18,2)
DECLARE @Tranno AS varchar(20)
DECLARE @Reasonid AS int
DECLARE @CurrVal AS INT
DECLARE @lError AS INT
DECLARE @GetKeyStr AS Varchar(50)
DECLARE @CoaId AS INT
DECLARE @VocDate AS DATETIME 
BEGIN
	BEGIN TRANSACTION C1

	IF EXISTS(SELECT SMCODE FROM SalesMan WHERE SMCODE=@SalRpCode)
	BEGIN
			IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_CreditNote]') AND type in (N'U'))
			BEGIN
				DROP TABLE PDA_Temp_CreditNote
			END

			Set @SQL = 'SELECT * INTO PDA_Temp_CreditNote FROM '+ QuoteName(@ToDBName) + '.dbo.CreditNote_Import WHERE SrpCde= ''' + @SalRpCode + ''' AND [UploadFlag] =''N'''    
			EXEC(@SQL)

			DECLARE Cur_ImportCreditNote CURSOR
			FOR SELECT DISTINCT CrNo FROM PDA_Temp_CreditNote
			OPEN Cur_ImportCreditNote
			FETCH NEXT FROM Cur_ImportCreditNote INTO @Crno
			WHILE @@FETCH_STATUS=0
			BEGIN
				SET @lError = 0
				SET @RtrId=0
				SET @CoaId=0
				IF NOT EXISTS(SELECT PostedRefNo FROM CreditNoteRetailer WHERE PostedRefNo=@Crno)
				BEGIN
		 
					SELECT @RtrId =RtrId FROM PDA_Temp_CreditNote WHERE CrNo=@Crno 
					IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrID = @RtrId AND RtrStatus = 1)
					BEGIN
						SET @lError = 1
						Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'CREDITNOTE' AND [Name]=@RtrId
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
						SELECT '' + @SalRpCode + '','CREDITNOTE',@RtrId,'Retailer Does Not Exists For the CreditNote ' +@Crno
					END
					ELSE
					BEGIN
						SELECT @CoaId=CoaId FROM Retailer WHERE RtrID = @RtrId AND RtrStatus = 1
					END
					IF EXISTS(SELECT CrAmount FROM PDA_Temp_CreditNote WHERE CrNo=@Crno AND CrAmount<=0)
					BEGIN
							SET @lError = 1
							Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'CREDITNOTE' AND [Name]=@Crno
							INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
							SELECT '' + @SalRpCode + '','CREDITNOTE',@Crno,'Credit Amount should be Greater than zero for the CreditNote ' +@Crno
					END
					SET @GetKeyStr=''  
					SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('CreditNoteRetailer','CrNoteNumber',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))       
					IF LEN(LTRIM(RTRIM(@GetKeyStr)))=0  
					BEGIN  
						SET @lError = 1
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
						SELECT '' + @SalRpCode + '','CREDITNOTE',@Crno,' Credit Note Key Number not generated' --FROM PDA_Temp_OrderBooking WHERE OrdKeyNo=@OrdKeyNo
						BREAK  
					END

					

					IF @lError = 0
					BEGIN 
						INSERT INTO CreditNoteRetailer(CrNoteNumber,CrNoteDate,RtrId,CoaId,ReasonId,Amount,CrAdjAmount,Status,PostedFrom,TransId,PostedRefNo,
														Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
						SELECT @GetKeyStr,Convert(DateTime,Convert(Varchar(10),Getdate(),121),121),@RtrId,@CoaId,ReasonId,
						CrAmount,ISNULL(CrAdjAmount,0),1,
						CASE WHEN LEN(ISNULL(TranNo,'') )=0 THEN @GetKeyStr ELSE TranNo END, 
						254,@Crno,1,1,Convert(DateTime,Convert(Varchar(10),Getdate(),121),121),
						1,Convert(DateTime,Convert(Varchar(10),Getdate(),121),121),'PDA Down Credit Note'
						FROM PDA_Temp_CreditNote WHERE CrNo=@Crno
						IF EXISTS(SELECT PostedRefNo FROM CreditNoteRetailer WHERE PostedRefNo=@Crno)
						BEGIN
								UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TABNAME='CreditNoteRetailer' AND FldName='CrNoteNumber'
								---VOUCHER NOTE
								SELECT @VocDate= Convert(DateTime,Convert(Varchar(10),Getdate(),121),121)--CrNoteDate FROM CreditNoteRetailer WHERE CrNoteNumber=@GetKeyStr
								EXEC Proc_VoucherPosting 18,1,@GetKeyStr,3,6,1,@VocDate,0
								SET @UpdSQL=''
								SET @UpdSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.CreditNote_Import SET [UploadFlag] = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and [UploadFlag] = ''N'''
								EXEC(@UpdSQL)
						END
					END 
				END 
				ELSE
				BEGIN
					Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'CREDITNOTE' AND [Name]=@Crno
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','CREDITNOTE',@Crno,'Credit Already exists' FROM PDA_Temp_CreditNote WHERE CrNo=@Crno
				END	
				FETCH NEXT FROM Cur_ImportCreditNote INTO @Crno
			END
				CLOSE Cur_ImportCreditNote
				DEALLOCATE Cur_ImportCreditNote 
	END
	ELSE
	BEGIN
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','CREDITNOTE',@SalRpCode,'Sales Man Does not Exists'
	END	
	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION C1
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION C1
	END
END
GO

--Import DebitNote
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Import_PDA_DebitNote') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Import_PDA_DebitNote
GO
CREATE PROCEDURE Proc_Import_PDA_DebitNote
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
/*********************************
* PROCEDURE: [Proc_Import_PDA_DebitNote]
* PURPOSE: To Insert the records From Intermediate into CoreStocky Database
* SCREEN : DEBITNOTE
* CREATED: Murugan.R 
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*********************************/
DECLARE @SQL AS nvarchar(3000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @UpdSQL AS varchar(1000)
DECLARE @Dbno AS varchar(20)
DECLARE @Dbamount AS numeric(18,2)
DECLARE @Rtrid AS numeric(18,0)
DECLARE @Dbadjamt AS numeric(18,2)
DECLARE @Transno AS varchar(20)
DECLARE @Reasonid AS int
DECLARE @CurrVal AS INT
DECLARE @lError AS INT
DECLARE @CoaId AS INT
DECLARE @GetKeyStr AS Varchar(50)
DECLARE @VocDate AS DATETIME

BEGIN
	BEGIN TRANSACTION D1
	IF EXISTS(SELECT SMCODE FROM SalesMan WHERE SMCODE=@SalRpCode)
	BEGIN
			IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDA_Temp_DebitNote]') AND type in (N'U'))
			BEGIN
				DROP TABLE PDA_Temp_DebitNote
			END

			Set @SQL = 'SELECT * INTO PDA_Temp_DebitNote FROM '+ QuoteName(@ToDBName) + '.dbo.DebitNote_Import WHERE SrpCde= ''' + @SalRpCode +''' AND [UploadFlag] =''N'''    
			EXEC(@SQL)
			
			DECLARE Cur_ImportDebitNote CURSOR
			FOR SELECT DISTINCT DbNo FROM PDA_Temp_DebitNote
			OPEN Cur_ImportDebitNote
			FETCH NEXT FROM Cur_ImportDebitNote INTO @Dbno
			WHILE @@FETCH_STATUS=0
			BEGIN
				SET @lError = 0
				SET @RtrId=0
				SET @CoaId=0
				IF NOT EXISTS(SELECT * FROM DebitNoteRetailer WHERE PostedRefNo=@Dbno)
				BEGIN
					SET @RtrId = (Select RtrId FROM PDA_Temp_DebitNote WHERE DbNo=@Dbno) 
					IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrID = @RtrId  AND RtrStatus = 1)
					BEGIN
						SET @lError = 1
						Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'DEBITNOTE' AND [Name]=@RtrId
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
						SELECT '' + @SalRpCode + '','DEBITNOTE',@RtrId,'Retailer Does Not Exists For the DebitNote ' + @Dbno
					END
					ELSE
					BEGIN
						SELECT @CoaId=CoaId FROM  Retailer WHERE RtrID = @RtrId  AND RtrStatus = 1
					END

					IF EXISTS(SELECT DbAmount FROM PDA_Temp_DebitNote WHERE DbNo=@Dbno AND DbAmount<=0)
					BEGIN
						SET @lError = 1
						Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'DEBITNOTE' AND [Name]=@Dbno
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
						SELECT '' + @SalRpCode + '','DEBITNOTE',@Dbno,'Debit Amount should be Greater than zero for the Debit Note ' + @Dbno
					END

					SET @GetKeyStr=''  
					SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('DebitNoteRetailer','DbNoteNumber',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))     
					IF LEN(LTRIM(RTRIM(@GetKeyStr)))=0  
					BEGIN  
						SET @lError = 1
						INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
						SELECT '' + @SalRpCode + '','DEBITNOTE',@Dbno,' Debit Note Key Number Not generated' 
						BREAK  
					END

					IF @lError = 0 
					BEGIN 
					
						INSERT INTO DebitNoteRetailer(DbNoteNumber,DbNoteDate,RtrId,CoaId,ReasonId,Amount,DbAdjAmount,Status,PostedFrom,TransId,
														PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
								SELECT @GetKeyStr,Convert(DateTime,Convert(Varchar(10),Getdate(),121),121),@RtrId,@CoaId,Reasonid,
								DbAmount,ISNULL(DbAdjAmount,0),1,
								CASE WHEN LEN(ISNULL(TransNo,'') )=0 THEN @GetKeyStr ELSE TransNo END, 
								254,@Dbno,1,1,Convert(DateTime,Convert(Varchar(10),Getdate(),121),121),
								1,Convert(DateTime,Convert(Varchar(10),Getdate(),121),121),'PDA Down Debit Note'
								FROM PDA_Temp_DebitNote WHERE DbNo=@Dbno

								IF EXISTS(SELECT PostedRefNo FROM DebitNoteRetailer WHERE PostedRefNo=@Dbno)
								BEGIN
										UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TABNAME='DebitNoteRetailer' AND FldName='DbNoteNumber'
										---VOUCHER NOTE
										SELECT @VocDate= Convert(DateTime,Convert(Varchar(10),Getdate(),121),121)--CrNoteDate FROM CreditNoteRetailer WHERE CrNoteNumber=@GetKeyStr
										EXEC Proc_VoucherPosting 19,1,@GetKeyStr,3,7,1,@VocDate,0
										SET @UpdSQL=''
										SET @UpdSQL= 'UPDATE '+ QuoteName(@ToDBName) +'.dbo.DebitNote_Import SET [UploadFlag] = ''Y'' Where SrpCde = ''' + @SalRpCode + ''' and [UploadFlag] = ''N'''
										EXEC(@UpdSQL)
								END

					
						
					END 
				END
				ELSE
				BEGIN
					Delete From PDALog Where SrpCde = @SalRpCode And DataPoint = 'DEBITNOTE' AND [Name]=@Dbno
					INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
					SELECT '' + @SalRpCode + '','DEBITNOTE',@Dbno,'Debit Already exists'
				END	 
				FETCH NEXT FROM Cur_ImportDebitNote INTO @Dbno
			END
				CLOSE Cur_ImportDebitNote
				DEALLOCATE Cur_ImportDebitNote
	END
	ELSE
	BEGIN
			DELETE FROM PDALog Where SrpCde = @SalRpCode And DataPoint = 'DEBITNOTE' AND [Name]=@SalRpCode
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
			SELECT '' + @SalRpCode + '','DEBITNOTE',@SalRpCode,'Sales Man Does not Exists'
	END
	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION D1
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION D1
	END 
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='TempPDA_RtrWiseProductSales' AND xtype='U')
DROP TABLE TempPDA_RtrWiseProductSales
GO
CREATE TABLE TempPDA_RtrWiseProductSales
(
salinvno varchar(100),
Salinvdate datetime,
RtrCode nvarchar(100),
RtrName nvarchar(200),
PrdCCode nvarchar(100),
PrdName nvarchar(200),
Qty int,
InvType varchar(50)
)
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_Export_PDA_RetailerWisesales') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_PDA_RetailerWisesales
GO
--Exec Proc_Export_PDA_RetailerWisesales 'test','JnJIntermediate','01'
CREATE PROCEDURE Proc_Export_PDA_RetailerWisesales
(
	@FromDBName varchar(50),
	@ToDBName varchar(50),
	@SalRpCode varchar(50)
)
AS
/*********************************
* PROCEDURE: Proc_Export_PDA_RetailerWisesales
* PURPOSE: To Insert the records From main db into Intermediate Database
* SCREEN : RetailerWisesales
* CREATED: KARTHICK.K.J
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*********************************/
DECLARE @SQL AS varchar(1000)
DECLARE @DelSQL AS varchar(1000)
DECLARE @InsSQL AS varchar(5000)
DECLARE @UpSQL AS varchar(2000)
DECLARE @Smid AS int 

BEGIN

DELETE FROM TempPDA_RtrWiseProductSales
SET @DelSQL = 'DELETE FROM '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales Where SrpCode = ''' + @SalRpCode + ''''
EXEC (@DelSQL)

SELECT @Smid=SMID FROM Salesman WHERE SMCode=@SalRpCode


DECLARE @Rtrid AS int
DECLARE @prdid AS int 
DECLARE @Rtrcode AS varchar(100)
DECLARE @Rtrname AS varchar(200)
DECLARE @Prdccode AS varchar(100)
DECLARE @prdName AS varchar(200)
DECLARE @Baseqty AS int
DECLARE @Cnt AS int
DECLARE @SalInvDate datetime
DECLARE @salinvno varchar(100)

DECLARE Cur_RtrwiseProdut CURSOR 
FOR 
SELECT DISTINCT si.rtrid,sip.prdid FROM salesinvoice si 
INNER JOIN SalesInvoiceProduct sip ON si.SalId=sip.salid
WHERE DlvSts<>2 AND SMId=@Smid
ORDER BY si.RtrId
OPEN Cur_RtrwiseProdut
FETCH next  FROM Cur_RtrwiseProdut INTO  @Rtrid,@prdid
WHILE @@fetch_status=0
BEGIN
SET @Cnt=0

	DECLARE Cur_RtrwiseProdutSales CURSOR 
	FOR SELECT SalInvDate,salinvno,rtrcode,Rtrname,prdccode,prdName,baseqty FROM (
		SELECT TOP 3 si.salid,SalInvDate,salinvno,rtrcode,RtrName,prdccode,PrdName,sum(baseqty) baseqty
		FROM salesinvoice si 
			INNER JOIN SalesInvoiceProduct sip ON si.SalId=sip.salid
			INNER JOIN Retailer R ON R.rtrid=si.RtrId 
			INNER JOIN Product P ON P.prdid=sip.prdid
		WHERE SI.RtrId=@Rtrid AND sip.prdid=@prdid AND DlvSts<>2
		GROUP BY SalInvDate,salinvno,rtrcode,prdccode,RtrName,PrdName,si.SalId ORDER BY SalInvDate DESC,si.salid desc)A
	OPEN Cur_RtrwiseProdutSales
	FETCH next  FROM Cur_RtrwiseProdutSales INTO @SalInvDate,@salinvno,@Rtrcode,@Rtrname,@Prdccode,@prdName,@Baseqty
	WHILE @@fetch_status=0
	BEGIN
		SET @Cnt=@Cnt+1
		
		INSERT INTO TempPDA_RtrWiseProductSales
		SELECT @salinvno,@SalInvDate,@Rtrcode,@Rtrname,@Prdccode,@prdName,@Baseqty,'Invoice'+cast(@Cnt AS varchar(1))


	FETCH next  FROM Cur_RtrwiseProdutSales INTO @SalInvDate,@salinvno,@Rtrcode,@Rtrname,@Prdccode,@prdName,@Baseqty
	END 
	CLOSE Cur_RtrwiseProdutSales
	DEALLOCATE Cur_RtrwiseProdutSales


FETCH next  FROM Cur_RtrwiseProdut INTO  @Rtrid,@prdid
END 
CLOSE Cur_RtrwiseProdut
DEALLOCATE Cur_RtrwiseProdut


Set @InsSQL = 'INSERT INTO '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales(SrpCode,RtrCode,RtrName,PrdCCode,PrdName )'
Set @InsSQL = @InsSQL + 'SELECT DISTINCT ''' + @SalRpCode + ''',RtrCode,RtrName,PrdCCode,PrdName FROM '+ QuoteName(@FromDBName) + '..TempPDA_RtrWiseProductSales'
EXEC (@InsSQL)

SET @UpSQL='UPDATE '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales SET  Invoice1=Qty FROM '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales R INNER JOIN'
Set @UpSQL = @UpSQL +' '+ QuoteName(@FromDBName) + '..TempPDA_RtrWiseProductSales T ON R.RtrCode=T.RtrCode AND R.PrdCCode=T.PrdCCode WHERE InvType=''Invoice1'''
EXEC (@UpSQL)

SET @UpSQL='UPDATE '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales SET  Invoice2=Qty FROM '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales R INNER JOIN'
Set @UpSQL = @UpSQL +' '+ QuoteName(@FromDBName) + '..TempPDA_RtrWiseProductSales T ON R.RtrCode=T.RtrCode AND R.PrdCCode=T.PrdCCode WHERE InvType=''Invoice2'''
EXEC (@UpSQL)

SET @UpSQL='UPDATE '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales SET  Invoice3=Qty FROM '+ QuoteName(@ToDBName) + '.dbo.RtrWiseProductSales R INNER JOIN'
Set @UpSQL = @UpSQL +' '+ QuoteName(@FromDBName) + '..TempPDA_RtrWiseProductSales T ON R.RtrCode=T.RtrCode AND R.PrdCCode=T.PrdCCode WHERE InvType=''Invoice3'''
EXEC (@UpSQL)

END 
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_ApplyReturnScheme')
DROP PROCEDURE  Proc_ApplyReturnScheme
GO
/*
BEGIN TRANSACTION
EXEC [Proc_ApplyReturnScheme] 102,2,23
SELECT * FROM UserFetchReturnScheme 
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_ApplyReturnScheme]
(
	@Pi_SalId int,
	@Pi_Usrid as int,
	@Pi_TransId as int
)
/******************************************************************************************
* PROCEDURE	: Proc_ApplyReturnScheme
* PURPOSE	: To Apply the Return Scheme and Get the Scheme Details for the Selected Scheme
* CREATED	: Boopathy
* CREATED DATE	: 01/06/2007
* NOTE		: General SP for Returning the Scheme Details for the all type of Schemes
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-------------------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}	
* 25/07/2009	Panneerselvam.k		Solve the Divied  By Zero Error
******************************************************************************************/
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Config		INT
	SET @Config=-1
	IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='SALESRTN18' AND Status=1)
	BEGIN
		SET @Config=0 
	END
	ELSE IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='SALESRTN19' AND Status=1)
	BEGIN
		SET @Config=1
	END
	ELSE
	BEGIN
		SET @Config=-1
	END
	
	DECLARE @SchId			INT
	DECLARE @SlabId			INT
	DECLARE @PurOfEveryReq	INT
	DECLARE @NoOfTimes		NUMERIC(38,6)
	DECLARE @SchType		INT
	DECLARE @ProRata		INT
	DECLARE @RtrId			INT
	DECLARE @CurSlabId		INT
	DECLARE @PrdId			INT
	DECLARE @PrdbatId		INT
	DECLARE @RowId			INT
	DECLARE @Combi			INT
	DECLARE @SchCode		VARCHAR(100)
	DECLARE @FlexiSch		INT
	DECLARE @FlexiSchType	INT
	DECLARE @SchemeBudget	NUMERIC(18,6)
	DECLARE @SchLevelId			INT
	DECLARE @SchemeLvlMode		INT
	DECLARE @TempHier TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT
	)
	DECLARE @TempBilledAchCombi TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @SchEligiable TABLE
	(
		ManType			INT,
		Cnt				INT,
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId	INT,
		FrmSchAch 		NUMERIC(38,6),
		NoOfTimes		NUMERIC(38,6),
		SchId			INT,
		SlabId			INT
	)
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
	DECLARE @TempBilledAch TABLE
	(
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
	DECLARE @TempBilledCombiAch TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @TempSchSlabAmt TABLE
	(
		ForEveryQty		NUMERIC(38,6),
		ForEveryUomId		INT,
		DiscPer			NUMERIC(38,6),
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
		SchId			INT,
		SlabId			INT,
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
	DECLARE @FreePrdDt TABLE
	(
		SalId			INT,
		SchId			INT,
		SlabId			INT,
		FreeQty			INT,
		FreePrdId		INT,
		FreePrdBatId	INT,
		FreePriceId		INT,
		GiftQty			INT,
		GiftPrdId		INT,
		GiftPrdBatId	INT,
		GiftPriceId		INT,
		PrdId			INT,
		PrdBatId		INT,
		RowId			INT
		
	)
	DECLARE @ReturnPrdHdForScheme TABLE
	(
		RowId		int,
		RtrId		int,
		PrdId		int,
		PrdBatId	int,
		SelRate		numeric(18,6),
		BaseQty		int,
		GrossAmount	numeric(18,6),
		TransId		tinyint,
		Usrid		int,
		SalId		bigint,
		RealQty		int,
		MRP			numeric(18,6)
	)
	DECLARE @t1 TABLE
	(
		SalId		INT,
		SchId		INT,
		PrdId		INT,
		PrdBatId	INT,
		FlatAmt		NUMERIC(38,6),
		DiscPer		NUMERIC(38,6),
		Points		INT,
		NoofTimes	INT
	)
	DECLARE @TempSch1 Table
	(
		SalId		INT,
		RowId		INT,
		PrdId		INT,
		PrdBatId	INT,
		BaseQty		NUMERIC(38,6),
		Selrate		NUMERIC(38,6),
		Grossvalue	NUMERIC(38,6),
		Schid		INT,
		Slabid		INT,
		Discper		NUMERIC(38,6),
		Flatamt		NUMERIC(38,6),
		Points		NUMERIC(38,6),
		NoofTimes	NUMERIC(38,6)
	)
	DECLARE @TempSch2 Table
	(
		SalId			INT,
		RowId			INT,
		PrdId			INT,
		PrdBatId		INT,
		Schid			INT,
		Slabid			INT,
		SchemeAmount	NUMERIC(38,6),
		SchemeDiscount	NUMERIC(38,6),
		Points			NUMERIC(38,6),
		Contri			NUMERIC(38,6),
		NoofTimes		NUMERIC(38,6)
	)
	DECLARE @MaxSchDt TABLE
	(
		SalId		INT,
		SchId		INT,
		SlabId		INT,
		RowId		INT,
		PrdId		INT,
		PrdBatId	INT,
		SchAmt		NUMERIC(38,6)
	)
	DECLARE @SchGross TABLE
	(
		SchId	INT,
		Amt		NUMERIC(38,6)
	)
	--Apportion scheme amt prd wise
	DECLARE @DiscPer	NUMERIC(38,6)
	DECLARE @FlatAmt	NUMERIC(38,6)
	DECLARE @Points		INT
	DECLARE @SumValue	NUMERIC(38,6)
	DECLARE @FreePrd	INT
	DECLARE @GiftPrd	INT
	DECLARE @MaxPrdId	INT
	DECLARE @SalId		INT
	DECLARE @RefCode	VARCHAR(2)
	DECLARE @CombiSch	INT
	DECLARE @QPS		INT
	DECLARE @BillCnt	INT
	DECLARE @SchCnt		INT
	DECLARE @TempSlabId	INT
	DECLARE @Cnt1	AS	INT
	DECLARE @Cnt2	AS	INT
	DECLARE @FlatChk1 AS INT
	DECLARE @FlatChk2 AS INT
	DELETE FROM SalesReturnDbNoteAlert WHERE SalId=@Pi_SalId
	IF @Config=0
	BEGIN
		DELETE FROM UserFetchReturnScheme WHERE SalId=@Pi_SalId AND Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		INSERT INTO UserFetchReturnScheme(SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,FreeQty,
		FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId)
		SELECT SalId,PrdId,PRdBatId,SchId,SlabId,SUM(Discamt),SUM(Flatamt),SUM(Points),FreeQty,
		FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId FROM 
		(
			SELECT SI.SalId,RPS.PrdId,RPS.PRdBatId,SIL.SchId,SIL.SlabId,
			CAST(((SIL.DiscountPerAmount-SIL.PrimarySchemeAmt-SIL.ReturnDiscountPerAmount)/(SIP.BaseQty-SIP.ReturnedQty)) AS NUMERIC(18,6))*(RPS.RealQty) AS Discamt,
			CAST(((SIL.FlatAmount-SIL.ReturnFlatAmount)/(SIP.BaseQty-SIP.ReturnedQty))AS NUMERIC(18,6))*(RPS.RealQty) AS Flatamt,0 AS Points,
			0 AS FreeQty,0 AS FreePrdId,0 AS FreePrdBatId,0 AS GiftQty,0 AS GiftPrdId,0 AS GiftPrdBatId,
			0 AS NoofTimes,@Pi_Usrid AS Usrid,@Pi_TransId AS TransId,RPS.RowId,0 AS FreePriceId,0 AS GiftPriceId
			FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
			INNER JOIN SalesInvoiceSchemeLineWise SIL ON SIL.SalId=SIP.SalId AND SIP.PrdId=SIL.PrdId 
			AND SIP.PrdBatId=SIL.PrdBatId AND SIP.Slno=SIL.RowId INNER JOIN
			ReturnPrdHdForScheme RPS ON RPS.PrdId=SIP.PrdId AND RPS.PrdBatId=SIP.PrdBatId AND RPS.SalId=SI.SalId AND RPS.RtrId=SI.RtrId 
			WHERE SI.SalId=@Pi_SalId AND usrid = @Pi_Usrid AND TransId = @Pi_TransId
			UNION 
			SELECT SI.SalId,RPS.PrdId,RPS.PRdBatId,SIL.SchId,SIL.SlabId,
			0 AS Discamt,0 AS Flatamt,CAST(((SIL.Points-SIL.ReturnPoints)/(SIP.BaseQty-SIP.ReturnedQty))AS NUMERIC(18,6))*(RPS.RealQty) AS Points,
			0 AS FreeQty,0 AS FreePrdId,0 AS FreePrdBatId,0 AS GiftQty,0 AS GiftPrdId,0 AS GiftPrdBatId,
			0 AS NoofTimes,@Pi_Usrid AS Usrid,@Pi_TransId AS TransId,RPS.RowId,0 AS FreePriceId,0 AS GiftPriceId
			FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
			INNER JOIN SalesInvoiceSchemeDtPoints SIL ON SIL.SalId=SIP.SalId AND SIP.PrdId=SIL.PrdId 
			AND SIP.PrdBatId=SIL.PrdBatId INNER JOIN
			ReturnPrdHdForScheme RPS ON RPS.PrdId=SIP.PrdId AND RPS.PrdBatId=SIP.PrdBatId AND RPS.SalId=SI.SalId AND RPS.RtrId=SI.RtrId 
			WHERE SI.SalId=@Pi_SalId AND usrid = @Pi_Usrid AND TransId = @Pi_TransId
		) A 
		---Nanda
		WHERE PrdId IS NOT NULL AND A.SchId NOT IN (SELECT  DISTINCT SchID FROM SchemeMaster WHERE Qps=1 AND ApyQPSSch=1)
		GROUP BY SalId,PrdId,PRdBatId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId
		DELETE FROM UserFetchReturnScheme WHERE SchId IN (SELECT  SchId FROM SchemeMaster WHERE CombiType=1)
		
		SELECT @RtrId=RtrId FROM SalesInvoice WHERE SalId=@Pi_SalId
		DECLARE SchemeFreeCur CURSOR FOR
		SELECT DISTINCT a.SchId,a.SlabId FROM SalesInvoiceSchemeDtFreePrd a INNER JOIN SchemeMaster B On A.SchId=B.SchId
		WHERE a.SalId=@Pi_SalId AND B.CombiType=0 AND B.SchId NOT IN (SELECT  DISTINCT SchID FROM SchemeMaster WHERE Qps=1 AND ApyQPSSch=1)
		OPEN SchemeFreeCur
		FETCH NEXT FROM SchemeFreeCur INTO @SchId,@CurSlabId
		WHILE @@fetch_status= 0
		BEGIN		
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery,@SchLevelId = SchLevelId,
			@SchemeLvlMode = SchemeLvlMode FROM SchemeMaster WHERE SchId=@SchId
			SELECT @RowId=MIN(B.RowId) FROM ReturnPrdHdForScheme B  
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) C ON
			C.PrdId = B.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE C.PrdBatId End
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId
			INSERT INTO ReturnPrdHdForScheme
			SELECT A.Slno,@RtrId,A.Prdid,A.PrdBatId,A.PrdUnitSelRate,A.BaseQty-A.ReturnedQty,
			(A.BaseQty-A.ReturnedQty)*A.PrdUnitSelRate,@Pi_TransId,@Pi_UsrId,@Pi_SalId,0,A.PrdUnitMRP
			FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
			A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
			WHERE A.SalId=@Pi_SalId AND A.PrdId NOT IN (SELECT Distinct PrdId FROM ReturnPrdHdForScheme
			WHERE usrid = @Pi_Usrid AND TransId = @Pi_TransId AND SalId = @Pi_SalId )
			SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM ReturnPrdHdForScheme WHERE  
			TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId AND RowId=@RowId
			INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,FreeQty,
			GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
			SELECT A.SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,CEILING((FreeQty/A.BaseQty)*SUM(B.RealQty)),
			0 AS GiftQty,0 AS GiftPrdId,0 AS GiftPrdBatId,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM
			(SELECT A.SalId,A.SchId,A.SlabId,A.FreePrdId,A.FreePrdBatId,(A.FreeQty-A.ReturnFreeQty) AS FreeQty,A.FreePriceId,
			SUM((B.BaseQty-B.ReturnedQty)) AS BaseQty FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN 
			SalesInvoiceProduct B ON A.SalId=B.SalId INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) C 
			ON B.PrdId=C.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE C.PrdBatId End 
			WHERE A.SchId=@SchId AND A.SlabId=@CurSlabId AND A.SalId=@Pi_SalId
			GROUP BY A.SalId,A.SchId,A.SlabId,A.FreePrdId,A.FreePrdBatId,A.FreeQty,A.ReturnFreeQty,A.FreePriceId) AS A
			INNER JOIN ReturnPrdHdForScheme B ON A.SalId=B.SalId
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) C ON
			C.PrdId = B.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE C.PrdBatId End
			WHERE usrid = @Pi_Usrid AND TransId = @Pi_TransId AND A.SalId=@Pi_SalId
			GROUP BY A.SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,FreeQty,A.BaseQty
			FETCH NEXT FROM SchemeFreeCur INTO @schid,@CurSlabId
		END
		CLOSE SchemeFreeCur
		DEALLOCATE SchemeFreeCur
		DELETE FROM UserFetchReturnScheme WHERE (DiscAmt+FlatAmt+Points+FreeQty+GiftQty)<=0
		IF EXISTS(SELECT * FROM @FreePrdDt)
		BEGIN
			IF EXISTS (SELECT * FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			BEGIN
				IF NOT EXISTS (SELECT * FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId 
								AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND UsrId=@Pi_Usrid)
				BEGIN
					INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
								FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
								RowId,FreePriceId,GiftPriceId)
					SELECT DISTINCT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
								FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
								RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 
								WHERE SchId NOT IN (SELECT SchId FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
								AND PrdId IS NOT NULL
				END
				ELSE
				BEGIN
					INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
								FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
								RowId,FreePriceId,GiftPriceId)
								SELECT DISTINCT A.SalID,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,0,0,0,B.FreeQty,B.FreePrdId,B.FreePrdBatId,
								B.GiftQty,B.GiftPrdId,B.GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
								B.RowId,B.FreePriceId,B.GiftPriceId FROM UserFetchReturnScheme A INNER JOIN @FreePrdDt B
								ON A.SalId=B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId --AND A.SchId=B.SchId AND A.SlabId=B.SlabId
								WHERE A.PrdId=@PrdId  AND B.PrdBatId=@PrdBatId AND A.SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid
								AND A.PrdId IS NOT NULL
				END	
			END
			ELSE
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT DISTINCT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 	
							WHERE PrdId IS NOT NULL
			END
			DELETE FROM UserFetchReturnScheme WHERE (DiscAmt+FlatAmt+Points+FreeQty+GiftQty)=0
		END	
	END
	ELSE IF @Config=1
	BEGIN
		Declare SchemeCur Cursor for
		SELECT distinct C.SchId,C.CombiSch,C.QPS FROM SalesInvoiceSchemeLineWise a 
		INNER JOIN SchemeMaster C ON C.SchId = a.SchId WHERE A.SalId=@Pi_SalId
		UNION
		SELECT distinct C.SchId,C.CombiSch,C.QPS FROM SalesInvoiceSchemeDtPoints a 
		INNER JOIN SchemeMaster C ON C.SchId = a.SchId WHERE A.SalId=@Pi_SalId
		open SchemeCur
		fetch next FROM SchemeCur into @SchId,@CombiSch,@QPS 
		while @@fetch_status= 0
		begin
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery,@SchLevelId = SchLevelId,
			@SchemeLvlMode = SchemeLvlMode FROM SchemeMaster WHERE SchId=@SchId
			DELETE FROM @TempBilled
			DELETE FROM @TempBilledAch
			DELETE FROM @TempBilledAchCombi				
			DELETE FROM @TempBilledCombiAch
			SET @SlabId=0
			UPDATE A SET A.BASEQTY=(B.BaseQty-B.ReturnedQty)-A.RealQty FROM ReturnPrdHdForScheme A INNER JOIN 
			SalesInvoiceProduct B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdbatId
			WHERE B.SalId=@Pi_SalId  AND A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BaseQty=0
			SELECT @Cnt1=COUNT(A.PrdId) FROM ReturnPrdHdForScheme A 
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
			AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId
			SELECT @Cnt2=COUNT(PrdId) FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@SchId
			SELECT -1 As Mode,PrdId,PrdBatId,SUM(B.BaseQty-B.ReturnedQty) AS BaseQty INTO #tempBilledPrd 
			FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId GROUP BY PrdId,PrdBatId
			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty),0) END AS SchemeOnQty,
				CASE E.Mode 
				WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty * A.SelRate),0) END AS SchemeOnAmount,
				ISNULL
				(
					(CASE D.PrdUnitId 
					WHEN 2 THEN 
						(CASE E.Mode 
						WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
					WHEN 3 THEN 
						(CASE E.Mode WHEN 0 THEN 0 ELSE (ISNULL(SUM(PrdWgt * A.BaseQty),0)) END) 
				 END),0)					
					AS SchemeOnKg,
				ISNULL
				(
					(CASE D.PrdUnitId 
						WHEN 4 THEN 
							(CASE E.Mode 
									WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
						WHEN 5 THEN 
							(CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0) END)
				 END),0) AS SchemeOnLitre,@SchId
				FROM ReturnPrdHdForScheme A INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C ON A.PrdId = C.PrdId
				INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
				INNER JOIN #tempBilledPrd E ON A.PrdId=E.PrdId AND A.PrdbatId=E.PrdBatId
				WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BASEQTY>0
				GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId	,E.Mode	
			UNION
				SELECT PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,SchId FROM 
				(SELECT DISTINCT E.PrdId,E.PrdBatId,ISNULL(SUM(E.BaseQty-E.ReturnedQty),0) AS SchemeOnQty,
					ISNULL(SUM(E.BaseQty * E.PrdUnitSelRate),0) AS SchemeOnAmount,
					ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnKg,
					ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnLitre,@SchId As SchId
					FROM SalesInvoiceProduct E INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON B.PrdId=E.PrdId AND E.SalId=@Pi_SalId
					AND E.PrdBatId = CASE B.PrdBatId WHEN 0 THEN E.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C ON E.PrdId = C.PrdId
					INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId 
					GROUP BY E.PrdId,E.PrdBatId,D.PrdUnitId) A WHERE NOT EXISTS (SELECT PrdId,PrdBatId FROM ReturnPrdHdForScheme B
					WHERE A.PrdId=B.Prdid AND A.PrdbatId=B.PrdBatId)
				--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
				INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
				SELECT ISNULL(CASE @SchType
					WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
				-- 	WHEN 1 THEN SUM(CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
					WHEN 2 THEN SUM(SchemeOnAmount)
					WHEN 3 THEN (CASE A.UomId
							WHEN 2 THEN SUM(SchemeOnKg) * 1000
							WHEN 3 THEN SUM(SchemeOnKg)
							WHEN 4 THEN SUM(SchemeOnLitre) * 1000
							WHEN 5 THEN SUM(SchemeOnLitre)	END)
						END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
					ISNULL(CASE @SchType
					WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
				-- 	WHEN 1 THEN SUM(CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
					WHEN 2 THEN SUM(SchemeOnAmount)
					WHEN 3 THEN (CASE A.ToUomId
							WHEN 2 THEN SUM(SchemeOnKg) * 1000
							WHEN 3 THEN SUM(SchemeOnKg)
							WHEN 4 THEN SUM(SchemeOnLitre) * 1000
							WHEN 5 THEN SUM(SchemeOnLitre)	END)
						END,0) AS ToSchAch,A.ToUomId AS ToUomAch,
					A.Slabid,(A.PurQty + A.FromQty) as FromQty,A.UomId,A.ToQty,A.ToUomId
					FROM SchemeSlabs A
					INNER JOIN @TempBilled B ON A.SchId = B.SchId
					INNER JOIN Product C ON B.PrdId = C.PrdId
					LEFT OUTER JOIN UomGroup D ON D.UomGroupId = C.UomGroupId AND D.UomId = A.UomId
					LEFT OUTER JOIN UomGroup E ON E.UomGroupId = C.UomGroupId AND E.UomId = A.UomId
					GROUP BY A.UomId,A.Slabid,A.PurQty,A.FromQty,A.UomId,A.ToQty,A.ToUomId	
					SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
						INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId
						WHERE
					A.FrmSchAch >= B.FromQty AND
					A.ToSchAch <= (CASE B.ToQty WHEN 0 THEN A.ToSchAch ELSE B.ToQty END)
						ORDER BY A.SlabId DESC) As SlabId
		
			SET @SlabId= ISNULL(@SlabId,0)
				--Store the Slab Amount Details into a temp table
				INSERT INTO @TempSchSlabAmt (ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints)
				SELECT ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints
					FROM SchemeSlabs WHERE Schid = @SchId And SlabId = @SlabId
				
				IF @SlabId> 0 
				BEGIN
					--To Get the Number of Times the Scheme should apply
					IF @PurOfEveryReq = 0
					BEGIN
						SET @NoOfTimes = 1
					END
					ELSE
					BEGIN
					
						SELECT @NoOfTimes = A.FrmSchAch / (CASE B.ForEveryQty WHEN 0 THEN 1 ELSE B.ForEveryQty END) FROM
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
				END
				ELSE
				BEGIN
					SET @NoOfTimes =1
				END
				INSERT INTO @TempSch1 (SalId,RowId,PrdId,PrdBatId,BaseQty,Selrate,Grossvalue,Schid,Slabid,
    			Discper,Flatamt,Points,NoofTimes)
	   			SELECT DISTINCT a.SalId,a.RowId,C.PrdId,a.PrdBatId,
				CASE A1.BaseQty WHEN 0 THEN A1.RealQty ELSE A1.BaseQty END,a1.SelRate,--A1.BaseQty*a1.SelRate,
				CASE A1.BaseQty WHEN 0 THEN a1.RealQty ELSE A1.BaseQty END *a1.SelRate,
				@SchId,D.SlabId,(d.DiscPer+d.FlxDisc),(d.FlatAmt-d.FlxValueDisc),
				D.Points+D.FlxPoints,@NoOfTimes FROM SalesInvoiceSchemeLineWise A 
				INNER JOIN ReturnPrdHdForScheme a1 ON A.PrdId=a1.PrdId AND a.PrdBatId=a1.PrdbatId 
				AND A.SalId=a1.SalId and a1.Usrid = @Pi_Usrid AND a1.TransId = @Pi_TransId 
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END
				INNER JOIN SchemeSlabs d ON d.SchId=A.SchId AND D.SchId=@SchId AND D.SlabId=@SlabId
				INNER JOIN SalesInvoiceProduct G ON A.PrdId=G.PrdId AND A.PrdBatId=G.PrdBatId AND G.SalId=a.SalId
				WHERE a.SalId= @Pi_SalId
				IF @SlabId>0 
				BEGIN
					SELECT @DiscPer = (SELECT ROUND(ISNULL(SUM(b.DiscountPerAmount-b.ReturnDiscountPerAmount),0),5) FROM SalesInvoiceSchemeLineWise b WHERE
						b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.DiscountPerAmount-b.ReturnDiscountPerAmount)>0)
					
					SELECT @FlatAmt = (SELECT ROUND(ISNULL(SUM(b.FlatAmount-b.ReturnFlatAmount),0),5) FROM SalesInvoiceSchemeLineWise b WHERE
						b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.FlatAmount-b.ReturnFlatAmount)>0) 
					
					SELECT @Points = (SELECT ISNULL(Sum(b.Points-b.ReturnPoints),0) FROM dbo.SalesInvoiceSchemeDtPoints b WHERE
						b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.Points-b.ReturnPoints)>0)
					SELECT @SumValue = (SELECT Sum(Grossvalue) FROM @TempSch1 WHERE SalId = @Pi_SalId AND SchId = @SchId)
	
					IF @DiscPer>0 
					BEGIN
						IF @Cnt1=@Cnt2 
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,
								((A.Grossvalue*A.Discper)/100)*@NoOfTimes as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,
								(C.DiscountPerAmount-C.ReturnDiscountPerAmount)-(((A.Grossvalue*A.Discper)/100)*@NoOfTimes) as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
						END
						ELSE
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,0 as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
							ELSE
							BEGIN
								SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
								FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								WHERE A.SalId=@Pi_SalId
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,
								CASE WHEN (C.DiscountPerAmount-C.ReturnDiscountPerAmount)-((A.Grossvalue*A.Discper)/100) <0 
								THEN (C.DiscountPerAmount-C.ReturnDiscountPerAmount)*@NoOfTimes
								ELSE (C.DiscountPerAmount-C.ReturnDiscountPerAmount)-(((A.Grossvalue*A.Discper)/100)*@NoOfTimes) END	as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
								 (SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
									((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId)B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue)>B.SchemeDiscount)
								BEGIN
									SET ROWCOUNT 1
									UPDATE A SET A.SchemeDiscount=A.SchemeDiscount+B.SchemeDiscount
									FROM @TempSch2 A
									INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
									((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId 
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId 
									WHERE (C.Grossvalue)>B.SchemeDiscount
									SET ROWCOUNT 0
								END
								ELSE
								BEGIN							
									INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
									SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
									SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount,0,0,0,@Pi_UsrId,@Pi_TransId FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
									((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
								END
							END
						END
					END
			
					IF @FlatAmt>0
					BEGIN
						SELECT @FlatChk1=SUM(B.BaseQty-B.ReturnedQty) FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId
						SELECT @FlatChk2=ISNULL(SUM(B.BaseQty),0) FROM @TempSch1 B WHERE SalId = @Pi_SalId AND SchId=@SchId
						IF @Cnt1=@Cnt2 
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
									0,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
									And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId AND A.SlabId=@SlabId
									SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat1
									FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
									DELETE FROM @TempSch2 WHERE SchemeAmount<0 
									UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
									FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
									GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
									#temp_Flat1 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
								END
								ELSE
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									(C.FlatAmount-C.ReturnFlatAmount)-((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes),
									0 as SchemeDiscount,
									0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
									And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId AND A.SlabId=@SlabId
									SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat3
									FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
									DELETE FROM @TempSch2 WHERE SchemeAmount<0 
									UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
									FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
									GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
									#temp_Flat3 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
								END
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								(C.FlatAmount-C.ReturnFlatAmount)-((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
								0 as SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
								And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat2 
								FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
								DELETE FROM @TempSch2 WHERE SchemeAmount<0 
								UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
								FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
									GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
								#temp_Flat2 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
			
							END
						END
						ELSE
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount,0 as SchemeDiscount,
									0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
									And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
								ELSE
								BEGIN
									SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
									FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
									A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									WHERE A.SalId=@Pi_SalId
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									(C.FlatAmount-C.ReturnFlatAmount)-((CAST((((B.BaseQty-B.ReturnedQty))*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
									0 AS SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
									AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
									INNER JOIN SalesInvoiceProduct B ON 
									A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND C.RowId=B.Slno
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
									IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,
									CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId 
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
									WHERE (C.Grossvalue>B.SchemeAmount))
									BEGIN
										SET ROWCOUNT 1
										UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
										FROM @TempSch2 A INNER JOIN 
										(SELECT A.SalId,A.Schid,A.SlabId,
										CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
										(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
										SchemeDiscount,Points,Contri,NoOfTimes FROM
										(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
										(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
										0 As SchemeDiscount,0 As Points,
										(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
										FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
										AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
										INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
										WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
										(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
										A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
										SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
										A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
										AND A.SchId=B.SchId And A.SlabId=B.SlabId 
										INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId 
										WHERE (C.Grossvalue>B.SchemeAmount)
										SET ROWCOUNT 0
									END
									ELSE
									BEGIN
										INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
										SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
										SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
										0, CASE WHEN A.SchemeAmount<0 THEN A.SchemeAmount*-1 ELSE A.SchemeAmount END ,0,0,@Pi_UsrId,@Pi_TransId FROM
										(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
										SchemeDiscount,Points,Contri,NoOfTimes FROM
										(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
										(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
										0 As SchemeDiscount,0 As Points,
										(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
										FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
										AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
										INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
										WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
										(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
										A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
										SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
										A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
									END
								END
							END
							ELSE
							BEGIN								
								SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
								FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								WHERE A.SalId=@Pi_SalId 
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								(C.FlatAmount-C.ReturnFlatAmount)-((CAST((((B.BaseQty-B.ReturnedQty))*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
								0 AS SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND C.RowId=B.Slno
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
								IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
								(SELECT A.SalId,A.Schid,A.SlabId,
								CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
								(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
								0 As SchemeDiscount,0 As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId 
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue>B.SchemeAmount))
								BEGIN				
									SET ROWCOUNT 1					
									UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
									FROM @TempSch2 A INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,
									CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
									WHERE (C.Grossvalue>B.SchemeAmount)
									SET ROWCOUNT 0
								END
								ELSE
								BEGIN
									INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
									SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
									SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									0, CASE WHEN A.SchemeAmount<0 THEN A.SchemeAmount*-1 ELSE A.SchemeAmount END ,0,0,@Pi_UsrId,@Pi_TransId FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
								END
							END
						END
					END
					IF @Points>0
					BEGIN
						SELECT @FlatChk1=SUM(B.BaseQty-B.ReturnedQty) FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId
						SELECT @FlatChk2=SUM(B.BaseQty) FROM @TempSch1 B WHERE SalId = @Pi_SalId AND SchId=@SchId
						IF @Cnt1=@Cnt2 
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeDtPoints WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount, 0 as SchemeDiscount,
									(CAST(((A.BaseQty*A.SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes as Points,
									((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
								ELSE
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount, 0 as SchemeDiscount,
									((C.Points-C.ReturnPoints)-(CAST(((A.BaseQty*A.SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
									((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount, 0 as SchemeDiscount,
								(C.Points-C.ReturnPoints)-((CAST((A.BaseQty*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
								((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
						END
						ELSE
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeDtPoints WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount, 0 as SchemeDiscount,0 as Points,
									((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
									AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
							END
							ELSE
							BEGIN
								
								SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
								FROM SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId 
								WHERE A.SalId=@Pi_SalId 
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,0 AS SchemeDiscount,
								(C.Points-C.ReturnPoints)-((CAST((A.BaseQty*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
								((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.SchId=C.SchId
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
								IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
								(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId
								,ROUND(A.Points,0)*@NoOfTimes AS Points FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
								0 AS SchemeAmount,0 As SchemeDiscount,
								(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId) B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId 
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue)>B.Points)
								BEGIN			
									SET ROWCOUNT 1						
									UPDATE A SET A.Points=A.Points+B.Points
									FROM @TempSch2 A INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId
									,ROUND(A.Points,0)*@NoOfTimes AS Points FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									0 AS SchemeAmount,0 As SchemeDiscount,
									(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
									WHERE (C.Grossvalue>B.Points)
									SET ROWCOUNT 0
								END
								ELSE
								BEGIN
									INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
									SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
									SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									0,0,ROUND(A.Points,0)*@NoOfTimes,0,@Pi_UsrId,@Pi_TransId FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									0 AS SchemeAmount,0 As SchemeDiscount,
									(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId 
								END
							END
						END
					END
				END		
				ELSE
				BEGIN
					INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
					SchemeDiscount,Points,Contri,NoofTimes)
					SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
					(A.FlatAmount-A.ReturnFlatAmount)*@NoOfTimes as SchemeAmount,
					(A.DiscountPerAmount-A.ReturnDiscountPerAmount) *@NoOfTimes AS SchemeDiscount,0 as Points,100 as Contri,1
					FROM SalesInvoiceSchemeLineWise A WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
					UNION
					SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
					0 AS SchemeAmount,0 As SchemeDiscount,(A.Points-A.ReturnPoints)*@NoOfTimes As Points,
					100 As Contri,1 AS NoOfTimes
					FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
					AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
					WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
				
					INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
					SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
						SELECT SalId,Schid,Slabid,PrdId,PrdBatId,RowId,
						SchemeDiscount,SchemeAmount,Points,0,@Pi_UsrId,@Pi_TransId FROM
						(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
						(A.FlatAmount-A.ReturnFlatAmount)*@NoOfTimes as SchemeAmount,
						(A.DiscountPerAmount-A.ReturnDiscountPerAmount) *@NoOfTimes AS SchemeDiscount,0 as Points,100 as Contri,1 AS NoTimes 
						FROM SalesInvoiceSchemeLineWise A WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A
						WHERE NOT EXISTS (
						SELECT PrdId,PrdBatId,SalId FROM
						(SELECT A.PrdId,A.PrdBatId,A.SalId FROM ReturnPrdHdForScheme A 
						INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
						AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
						WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId) X WHERE A.SalId=X.SalId AND 
						A.PrdId=X.PrdId AND A.PrdBatId=X.PrdBatId)
						UNION
						SELECT SalId,Schid,Slabid,PrdId,PrdBatId,RowId,
						SchemeDiscount,SchemeAmount,Points*@NoOfTimes,0,@Pi_UsrId,@Pi_TransId FROM
						(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid AS SlabId,
						0 AS SchemeAmount,0 As SchemeDiscount,(A.Points-A.ReturnPoints) As Points
						FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
						AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
						WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A
						WHERE NOT EXISTS (
							SELECT PrdId,PrdBatId,SalId FROM
							(SELECT A.PrdId,A.PrdBatId,A.SalId FROM ReturnPrdHdForScheme A 
							INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
							AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
							WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId) X WHERE A.SalId=X.SalId AND 
							A.PrdId=X.PrdId AND A.PrdBatId=X.PrdBatId)
				END
			--Nanda
			DROP TABLE #tempBilledPrd
			FETCH NEXT FROM SchemeCur INTO @schid ,@CombiSch,@QPS
		END
		CLOSE SchemeCur
		DEALLOCATE SchemeCur
		DELETE FROM SalesReturnDbNoteAlert WHERE (SchDiscAmt+SchFlatAmt+SchPoints)=0
		SELECT SalId,SchId,SlabId,SUM(CAST(SchemeAmount AS NUMERIC(18,6))) AS SchAmt,SUM(SchemeDiscount) AS SchDisc,
		SUM(Points) AS SchPoints INTO #Test1 FROM @TempSch2
		GROUP BY SalId,SchId,SlabId 
		DELETE A FROM  @TempSch2 A INNER JOIN #Test1 B ON A.SalId=B.SalId AND A.SchId=B.SchId
		AND A.SlabId=B.SlabId WHERE B.SchAmt=0 AND B.SchDisc=0 AND B.SchPoints=0
		INSERT INTO UserFetchReturnScheme(SalId,RowId,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,FreeQty,
		FreePrdId,FreePrdBatId,FreePriceId,GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,NoofTimes,Usrid,TransId)
		SELECT a.SalId,a.RowId,a.PrdId,a.PrdBatId,b.SchId,b.SlabId,b.SchemeDiscount,b.SchemeAmount,
			b.Points,0,0,0,0,0,0,0,0,b.NoofTimes,@Pi_Usrid,@Pi_TransId
		FROM ReturnPrdHdForScheme a INNER JOIN @TempSch2 b ON
		a.SalId=b.SalId AND a.PrdId = b.PrdId AND a.PrdBatId=b.PrdBatId --AND a.RowId=B.RowId
		WHERE a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId = @Pi_SalId
		ORDER BY a.RowId
		DECLARE SchUpdateCur CURSOR FOR
		SELECT DISTINCT SalId,SchId,SlabId FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		OPEN SchUpdateCur
		FETCH NEXT FROM SchUpdateCur INTO @SalId,@SchId,@SlabId
		WHILE @@fetch_status= 0
		BEGIN
		
		   SELECT @MaxPrdId = (SELECT MAX(a.PrdId) FROM UserFetchReturnScheme a WHERE
		   a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId=@Pi_SalId AND a.FreeQty<>0
		   AND a.SchId =@SchId AND a.SlabId = @SlabId HAVING COUNT(a.SchId) >1)
		   SELECT @PrdBatId = (SELECT DISTINCT MAX(a.PrdbatId) FROM UserFetchReturnScheme a WHERE
		   a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId=@Pi_SalId AND
		   a.PrdId=@MaxPrdId)
		   UPDATE UserFetchReturnScheme SET FreeQty = 0,GiftQty=0 FROM
		   UserFetchReturnScheme a WHERE a.SalId = @Pi_SalId AND a.Usrid = @Pi_Usrid AND a.TransId = @Pi_TransId
		   AND  a.PrdBatId <> @PrdBatId AND a.SchId = @SchId AND a.SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId = 0 AND FreePrdBatId=0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId=0 AND GiftPrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId <> 0 AND FreePrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE GiftPrdId <> 0 AND GiftPrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId <> 0 AND FreePrdBatId<>0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId=0 AND GiftPrdBatId=0 AND FreeQty=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId = 0 AND FreePrdBatId=0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId<>0 AND GiftPrdBatId<>0 AND GiftQty=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		
		   FETCH NEXT FROM SchUpdateCur INTO @SalId,@SchId,@SlabId
		END
		CLOSE SchUpdateCur
		DEALLOCATE SchUpdateCur
		SELECT @RtrId=RtrId FROM SalesInvoice WHERE SalId=@SalId
		SELECT @RefCode=ISNULL(PrimaryRefCode,'XX') FROM SalesInvoice WHERE SalId=@SalId
		IF @RefCode <> 'XX'
		BEGIN
			SELECT DISTINCT PrdId,PrdBatId,SchId AS SchId ,SlabId,RowId INTO #TmpPrdDt 
			FROM UserFetchReturnScheme WHERE DiscAmt > 0
			UPDATE UserFetchReturnScheme SET DiscAmt = CASE WHEN (DiscAmt - tmp.Prim)>0 THEN (DiscAmt - tmp.Prim) ELSE 0 END FROM
			(SELECT F.SchId,F.SlabId,B.PrdId,B.PrdBatId,B.RowID,B.GrossAmount - (B.GrossAmount /(1 +( CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@SalId)
			WHEN 1 THEN   D.PrdBatDetailValue ELSE 0 END)/100)) AS Prim FROM BilledPrdHdForScheme B INNER JOIN ProductBatchDetails D ON D.PrdBatId = B.PrdBatId  AND D.DefaultPrice=1
			INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId AND E.Slno = D.Slno AND E.RefCode = @RefCode
			INNER JOIN #TmpPrdDt F ON B.PrdId=F.PrdId AND F.PrdBatId=B.PrdBatId AND B.RowId=F.RowId
			WHERE B.usrid = @Pi_Usrid And B.transid = @Pi_TransId) tmp,UserFetchReturnScheme A
			WHERE A.usrid = @Pi_Usrid And A.transid = @Pi_TransId AND A.SchId=tmp.schId AND A.SlabId=tmp.SlabId
			AND A.PrdId=tmp.PrdId AND A.PrdBatId=tmp.PrdBatId AND A.RowId=tmp.RowId AND A.DiscAmt >0
		END
		SELECT DISTINCT * INTO #UserFetchReturnScheme FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		DELETE FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		INSERT INTO UserFetchReturnScheme SELECT  * FROM #UserFetchReturnScheme
		DECLARE SchemeFreeCur CURSOR FOR
		SELECT DISTINCT a.SchId FROM BillAppliedSchemeHd a WHERE a.TransId=@Pi_TransId AND a.UsrId=@Pi_Usrid 
		AND (a.FreeToBeGiven + a.GiftToBeGiven+a.FlxFreePrd+a.FlxGiftPrd)>0 AND a.IsSelected=1
		UNION 
		SELECT SchId FROM dbo.SalesInvoiceSchemeDtFreePrd WHERE SalId=@Pi_SalId
		OPEN SchemeFreeCur
		FETCH NEXT FROM SchemeFreeCur INTO @SchId
		WHILE @@fetch_status= 0
		BEGIN		
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery FROM SchemeMaster WHERE SchId=@SchId
			DELETE FROM @TempBilled
			DELETE FROM @TempBilledAch
			SET @SlabId=0
			UPDATE A SET A.BASEQTY=(B.BaseQty-B.ReturnedQty)-A.RealQty FROM ReturnPrdHdForScheme A INNER JOIN 
			SalesInvoiceProduct B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdbatId
			WHERE B.SalId=@Pi_SalId  AND A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BaseQty=0
			SELECT @Cnt1=COUNT(A.PrdId) FROM ReturnPrdHdForScheme A 
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
			AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId
			SELECT @Cnt2=COUNT(PrdId) FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@SchId
			SELECT -1 As Mode,PrdId,PrdBatId,SUM(B.BaseQty-B.ReturnedQty) AS BaseQty INTO #tempBilledPrd1
			FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId GROUP BY PrdId,PrdBatId
			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty),0) END AS SchemeOnQty,
				CASE E.Mode 
				WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty * A.SelRate),0) END AS SchemeOnAmount,
				ISNULL
				(
					(CASE D.PrdUnitId 
					WHEN 2 THEN 
						(CASE E.Mode 
						WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
					WHEN 3 THEN 
						(CASE E.Mode WHEN 0 THEN 0 ELSE (ISNULL(SUM(PrdWgt * A.BaseQty),0)) END) 
				 END),0)					
					AS SchemeOnKg,
				ISNULL
				(
					(CASE D.PrdUnitId 
						WHEN 4 THEN 
							(CASE E.Mode 
									WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
						WHEN 5 THEN 
							(CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0) END)
				 END),0) AS SchemeOnLitre,@SchId
				FROM ReturnPrdHdForScheme A INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C ON A.PrdId = C.PrdId
				INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
				INNER JOIN #tempBilledPrd1 E ON A.PrdId=E.PrdId AND A.PrdbatId=E.PrdBatId
				WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId 
				GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId	,E.Mode	
			UNION
				SELECT PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,SchId FROM 
				(SELECT DISTINCT E.PrdId,E.PrdBatId,ISNULL(SUM(E.BaseQty-E.ReturnedQty),0) AS SchemeOnQty,
					ISNULL(SUM(E.BaseQty * E.PrdUnitSelRate),0) AS SchemeOnAmount,
					ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnKg,
					ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnLitre,@SchId As SchId
					FROM SalesInvoiceProduct E INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON B.PrdId=E.PrdId AND E.SalId=@Pi_SalId
					AND E.PrdBatId = CASE B.PrdBatId WHEN 0 THEN E.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C ON E.PrdId = C.PrdId
					INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId 
					GROUP BY E.PrdId,E.PrdBatId,D.PrdUnitId) A WHERE NOT EXISTS (SELECT PrdId,PrdBatId FROM ReturnPrdHdForScheme B
					WHERE A.PrdId=B.Prdid AND A.PrdbatId=B.PrdBatId)
			--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
			INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
			SELECT ISNULL(CASE @SchType
				WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
			-- 	WHEN 1 THEN SUM(CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
				WHEN 2 THEN SUM(SchemeOnAmount)
				WHEN 3 THEN (CASE A.UomId
						WHEN 2 THEN SUM(SchemeOnKg) * 1000
						WHEN 3 THEN SUM(SchemeOnKg)
						WHEN 4 THEN SUM(SchemeOnLitre) * 1000
						WHEN 5 THEN SUM(SchemeOnLitre)	END)
					END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
				ISNULL(CASE @SchType
				WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
			-- 	WHEN 1 THEN SUM(CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
				WHEN 2 THEN SUM(SchemeOnAmount)
				WHEN 3 THEN (CASE A.ToUomId
						WHEN 2 THEN SUM(SchemeOnKg) * 1000
						WHEN 3 THEN SUM(SchemeOnKg)
						WHEN 4 THEN SUM(SchemeOnLitre) * 1000
						WHEN 5 THEN SUM(SchemeOnLitre)	END)
					END,0) AS ToSchAch,A.ToUomId AS ToUomAch,
				A.Slabid,(A.PurQty + A.FromQty) as FromQty,A.UomId,A.ToQty,A.ToUomId
				FROM SchemeSlabs A
				INNER JOIN @TempBilled B ON A.SchId = B.SchId
				INNER JOIN Product C ON B.PrdId = C.PrdId
				LEFT OUTER JOIN UomGroup D ON D.UomGroupId = C.UomGroupId AND D.UomId = A.UomId
				LEFT OUTER JOIN UomGroup E ON E.UomGroupId = C.UomGroupId AND E.UomId = A.UomId
				GROUP BY A.UomId,A.Slabid,A.PurQty,A.FromQty,A.UomId,A.ToQty,A.ToUomId	
				SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
					INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId
					WHERE
				A.FrmSchAch >= B.FromQty AND
				A.ToSchAch <= (CASE B.ToQty WHEN 0 THEN A.ToSchAch ELSE B.ToQty END)
					ORDER BY A.SlabId DESC) As SlabId
				SET @SlabId= ISNULL(@SlabId,0)
				--Store the Slab Amount Details into a temp table
				INSERT INTO @TempSchSlabAmt (ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints)
				SELECT ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints
					FROM SchemeSlabs WHERE Schid = @SchId And SlabId = @SlabId
				--Store the Slab Free Product Details into a temp table
				INSERT INTO @TempSchSlabFree(ForEveryQty,ForEveryUomId,FreePrdId,FreeQty)
				SELECT A.ForEveryQty,A.ForEveryUomId,B.PrdId,B.FreeQty From
					SchemeSlabs A INNER JOIN SchemeSlabFrePrds B ON A.Schid = B.Schid
					AND A.SlabId = B.SlabId INNER JOIN Product C ON B.PrdId = C.PrdId
					WHERE A.Schid = @SchId And A.SlabId = @SlabId AND C.PrdType <> 4
				--To Get the Number of Times the Scheme should apply
				IF @PurOfEveryReq = 0
				BEGIN
					SET @NoOfTimes = 1
				END
				ELSE
				BEGIN
					SELECT @NoOfTimes = A.FrmSchAch / (CASE B.ForEveryQty WHEN 0 THEN 1 ELSE B.ForEveryQty END) FROM
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
				IF @SlabId>0
				BEGIN
				DELETE FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_Usrid  AND SchId=@SchId
				INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
				Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
				FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
				BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
				SELECT DISTINCT @SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
					@SlabId as SlabId,0 as SchAmount,0 as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
					0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,FreePrdId,0 as FreePrdBatId,
					CASE @SchType 
						WHEN 1 THEN 
							CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END 
						WHEN 2 THEN 
							CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END
						WHEN 3 THEN
							CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END
					END
					 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
					0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,1 as IsSelected,@SchemeBudget as SchBudget,
					0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,MAX(PrdId) AS PrdId,MAX(PrdBatId) AS PrdBatId,0
					FROM @TempBilled , @TempSchSlabFree
					GROUP BY FreePrdId,FreeQty,ForEveryQty
					SELECT @RowId=MIN(RowId)  FROM ReturnPrdHdForScheme WHERE  
					TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId
					INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
					GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
					SELECT DISTINCT @Pi_SalId,@SchId,@SlabId,(E.FreeQty-E.ReturnFreeQty)-B.FreeToBeGiven AS FreeQty,
					E.FreePrdId,E.FreePrdBatId,E.FreePriceId AS FreePriceId,
					0 AS GiftQty,0,0,0 AS GiftPriceId,
					B.PrdId,B.PrdBatId,@RowId AS RowId FROM	BillAppliedSchemeHd B 
					INNER JOIN SalesInvoiceSchemeDtFreePrd E ON  B.SchId=E.SchId AND B.FreePrdId=E.FreePrdId
					WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId
					AND B.IsSelected=1 AND E.SalId=@Pi_SalId
				END
				ELSE IF @SlabId=0
				BEGIN
					IF EXISTS (SELECT * FROM BillAppliedSchemeHd B WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid 
							AND (B.FreeToBeGiven + B.GiftToBeGiven+B.FlxFreePrd+B.FlxGiftPrd)>0 AND B.IsSelected=1 AND SchId=@SchId )
					BEGIN
						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
						SELECT @Pi_SalId,@SchId,B.SlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,FreePriceId AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,B.PrdId,B.PrdBatId,C.RowId FROM	BillAppliedSchemeHd B 
						INNER JOIN SalesInvoiceSchemeDtFreePrd E ON B.SchId=E.SchId AND B.SlabId=E.SlabId
						INNER JOIN @ReturnPrdHdForScheme C ON B.PrdId=C.PrdId AND B.PrdbatId=C.PrdbatId
						WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId 
						AND B.IsSelected=1 AND E.SalId=@Pi_SalId
					END
					ELSE
					BEGIN
						SELECT @RowId=MIN(RowId)  FROM ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId
						SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId AND RowId=@RowId
						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
						SELECT @Pi_SalId,@SchId,E.SlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,0 AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM	
						SalesInvoiceSchemeDtFreePrd E WHERE E.SchId=@SchId AND E.SalId=@Pi_SalId
					END
				END
			FETCH NEXT FROM SchemeFreeCur INTO @schid
		END
		CLOSE SchemeFreeCur
		DEALLOCATE SchemeFreeCur	
		IF EXISTS(SELECT * FROM @FreePrdDt)
		BEGIN
			IF EXISTS (SELECT * FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 
							WHERE SchId NOT IN (SELECT SchId FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			END
			ELSE
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 						
			END
			UPDATE A Set FreeQty=B.FreeQty ,FreePrdId=B.FreePrdId ,FreePrdBatId=B.FreePrdBatId,
					GiftQty=B.GiftQty ,GiftPrdId=B.GiftPrdId,GiftPrdBatId=B.GiftPrdBatId,
					FreePriceId=B.FreePriceId ,GiftPriceId=B.GiftPriceId FROM UserFetchReturnScheme A
					INNER JOIN @FreePrdDt B ON A.SalId=B.SalId AND A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.RowId=B.RowId
					AND A.FreePrdId=B.FreePrdId
					WHERE A.SalId=@Pi_SalId
			DELETE FROM UserFetchReturnScheme WHERE DiscAmt+FlatAmt+Points+FreeQty+GiftQty=0
		END	
	END
END
GO
if not exists (select * from hotfixlog where fixid = 393)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(393,'D','2011-10-20',getdate(),1,'Core Stocky Service Pack 393')
GO
