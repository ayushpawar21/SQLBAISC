--[Stocky HotFix Version]=372
Delete from Versioncontrol where Hotfixid='372'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('372','2.0.0.5','D','2011-04-05','2011-04-05','2011-04-05',convert(varchar(11),getdate()),'Parle;Major:-Bug Fixing and Chnages;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 372' ,'372'
GO

--SRF-Nanda-227-001

DELETE FROM RptDetails WHERE RptId=24 AND SlNo IN (5,6,7)
INSERT INTO RptDetails VALUES (24,5,'ProductCategoryLevel',3,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,NULL,'Press F4/Double Click to select Product Hierarchy Level',1)
INSERT INTO RptDetails VALUES (24,6,'ProductCategoryValue',5,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,NULL,NULL,'Press F4/Double Click to select Product Hierarchy Level Value',0)
INSERT INTO RptDetails VALUES (24,7,'Product',6,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,0,NULL,'Press F4/Double click to select Product',0)

DELETE FROM RptExcelHeaders WHERE RptId=3 
INSERT INTO RptExcelHeaders VALUES (3,1,'SMId','SMId',0,1)
INSERT INTO RptExcelHeaders VALUES (3,2,'SMName','Salesman',1,1)
INSERT INTO RptExcelHeaders VALUES (3,3,'RMId','RMId',0,1)
INSERT INTO RptExcelHeaders VALUES (3,4,'RMName','Route',1,1)
INSERT INTO RptExcelHeaders VALUES (3,5,'RtrId','RtrId',0,1)
INSERT INTO RptExcelHeaders VALUES (3,6,'RtrCode','Retailer Code',1,1)
INSERT INTO RptExcelHeaders VALUES (3,7,'RtrName','Retailer',1,1)
INSERT INTO RptExcelHeaders VALUES (3,8,'SalId','SalId',0,1)
INSERT INTO RptExcelHeaders VALUES (3,9,'SalInvNo','Bill Number',1,1)
INSERT INTO RptExcelHeaders VALUES (3,10,'SalInvDate','Bill Date',1,1)
INSERT INTO RptExcelHeaders VALUES (3,11,'SalInvRef','Doc Ref No',0,1)
INSERT INTO RptExcelHeaders VALUES (3,12,'BillAmount','Bill Amount',1,1)
INSERT INTO RptExcelHeaders VALUES (3,13,'CollectedAmount','Collected Amount',1,1)
INSERT INTO RptExcelHeaders VALUES (3,14,'BalanceAmount','Balance Amount',1,1)
INSERT INTO RptExcelHeaders VALUES (3,15,'ArDays','AR Days',1,1)

DELETE FROM RptDetails WHERE RptId=18 
INSERT INTO RptDetails VALUES (18,1,'FromDate',-1,'','','From Date*','',1,'',10,0,0,'Enter From Date',0)
INSERT INTO RptDetails VALUES (18,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0)
INSERT INTO RptDetails VALUES (18,3,'Vehicle',-1,'','VehicleId,VehicleCode,VehicleRegNo','Vehicle...','',1,'',36,0,0,'Press F4/Double Click to Select Vehicle',0)
INSERT INTO RptDetails VALUES (18,4,'VehicleAllocationMaster',-1,'','AllotmentId,AllotmentDate,AllotmentNumber','Vehicle Allocation No...','',1,'',37,0,0,'Press F4/Double Click to Select Vehicle Allocation Number',0)
INSERT INTO RptDetails VALUES (18,5,'Salesman',-1,'','SMId,SMCode,SMName','Salesman...','',1,'',1,0,0,'Press F4/Double Click to Select Salesman',0)
INSERT INTO RptDetails VALUES (18,6,'RouteMaster',-1,'','RMId,RMCode,RMName','Delivery Route...','',1,'',35,0,0,'Press F4/Double Click to Select Delivery Route',0)
INSERT INTO RptDetails VALUES (18,7,'Retailer',-1,NULL,'RtrId,RtrCode,RtrName','Retailer Group...',NULL,1,NULL,215,NULL,NULL,'Press F4/Double Click to select Retailer Group',0)
INSERT INTO RptDetails vALUES (18,8,'Retailer',-1,NULL,'RtrId,RtrCode,RtrName','Retailer...',NULL,1,NULL,3,NULL,NULL,'Press F4/Double Click to select Retailer',0)
INSERT INTO RptDetails VALUES (18,9,'UOMMaster',-1,'','UOMId,UOMCode,UOMDescription','Display in*','',1,'',129,1,1,'Press F4/Double Click to Select UOM',0)
INSERT INTO RptDetails VALUES (18,10,'SalesInvoice',-1,NULL,'SalId,SalInvRef,SalInvNo','Bill No...',NULL,1,NULL,14,1,0,'Press F4/Double Click to select From Bill',0) 
INSERT INTO RptDetails VALUES (18,11,'RptFilter',-1,NULL,'FilterId,FilterDesc,FilterDesc','Bill No. Display on Report*...',NULL,1,NULL,257,1,1,'Press F4/Double Click to Select Bill No. Display on Report',0)

DELETE FROM RptExcelHeaders WHERE RptId=4 AND SlNo IN (24,25,26)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) VALUES (4,24,'CollectionDate','Collection Date',1,1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) VALUES (4,25,'CollectedBy','Collected By',1,1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) VALUES (4,26,'Remarks','Remarks',1,1)


DELETE  FROM CustomCaptions WHERE TransId=9 AND CtrlId=31
INSERT INTO CustomCaptions VALUES (9,31,1,'DgCommon-9-31-1','Bill No','','',1,1,1,'2008-03-19',1,'2008-03-19','Bill No','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,2,'DgCommon-9-31-2','Doc.Ref.No','','',1,1,1,'2008-03-19',1,'2008-03-19','Doc.Ref.No','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,3,'DgCommon-9-31-3','Remarks','','',1,1,1,'2008-03-19',1,'2008-03-19','Remarks','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,4,'DgCommon-9-31-4','Date','','',1,1,1,'2008-03-19',1,'2008-03-19','Date','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,6,'DgCommon-9-31-6','Retailer','','',1,1,1,'2008-03-19',1,'2008-03-19','Retailer','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,7,'DgCommon-9-31-7','Bill Amt','','',1,1,1,'2008-03-19',1,'2008-03-19','Bill Amt','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,8,'DgCommon-9-31-8','Paid Amt','','',1,1,1,'2008-03-19',1,'2008-03-19','Paid Amt','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,9,'DgCommon-9-31-9','Pending Amt','','',1,1,1,'2008-03-19',1,'2008-03-19','Pending Amt','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,10,'DgCommon-9-31-10','Cash Disc','','',1,1,1,'2008-03-19',1,'2008-03-19','Cash Disc','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,11,'DgCommon-9-31-11','Cash','','',1,1,1,'2008-03-19',1,'2008-03-19','Cash','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,12,'DgCommon-9-31-12','Chq / DD','','',1,1,1,'2008-03-19',1,'2008-03-19','Chq / DD','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,13,'DgCommon-9-31-13','Credit','','',1,1,1,'2008-03-19',1,'2008-03-19','Credit','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,14,'DgCommon-9-31-14','Debit','','',1,1,1,'2008-03-19',1,'2008-03-19','Debit','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,15,'DgCommon-9-31-15','On Acc','','',1,1,1,'2008-03-19',1,'2008-03-19','On Acc','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,16,'DgCommon-9-31-16','AR Days','','',1,1,1,'2008-03-19',1,'2008-03-19','AR Days','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,17,'DgCommon-9-31-17','Collection Amount','','',1,1,1,'2008-03-19',1,'2008-03-19','Collection Amount','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,18,'DgCommon-9-31-18','Adjustment Amount','','',1,1,1,'2008-03-19',1,'2008-03-19','Adjustment Amount','','',1,1)


DELETE FROM RptExcelHeaders WHERE RptId=58
INSERT INTO RptExcelHeaders VALUES (58,	1,	'SMId',	'SMId',	0,	1)
INSERT INTO RptExcelHeaders VALUES (58,	2,	'SMName',	'Salesman',	1,	1)
INSERT INTO RptExcelHeaders VALUES (58,	3,	'RMId',	'RMId',	0,	1)
INSERT INTO RptExcelHeaders VALUES (58,	4,	'RMName',	'Route',	1,	1)
INSERT INTO RptExcelHeaders VALUES (58,	5,	'RtrId',	'RtrId',	0,	1)
INSERT INTO RptExcelHeaders VALUES (58,	6,	'RtrCode',	'Retailer Code',	1,	1)
INSERT INTO RptExcelHeaders VALUES (58,	7,	'RtrName',	'Retailer Name',	1,	1)
INSERT INTO RptExcelHeaders VALUES (58,	8,	'SalQty',	'Units',	1,	1)
INSERT INTO RptExcelHeaders VALUES (58,	9,	'Width',	'Distribution Width',	1,	1)
INSERT INTO RptExcelHeaders VALUES (58,	10,	'BasedOn',	'BasedOn',	0,	1)
INSERT INTO RptExcelHeaders VALUES (58,	11,	'RtrCount',	'RtrCount',	0,	1)
INSERT INTO RptExcelHeaders VALUES (58,	12,	'BilledRtrCount',	'BilledRtrCount',	0,	1)


DELETE FROM RptDetails WHERE RptId=211  AND Slno IN (14,15)

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
SELECT 211,14,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Bill Status...','',1,'',263,1,'','Press F4/Double Click to select Bill Status',1

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
SELECT 211,15,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Display Based On*...','',1,'',246,1,1,'Press F4/Double Click to select Display Based on ',1

DELETE FROM RptFilter WHERE RptId=211 AND SelcId=263

INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
SELECT 211,263,1,'Pending'
UNION
SELECT 211,263,2,'Delivered'
UNION
SELECT 211,263,3,'Cancelled'

DELETE FROM RptSelectionHd WHERE SelcId=263
INSERT INTO RptSelectionHd(SelcId,SelcName,TblName,Condition)
SELECT 263,'Sel_BillSts','RptFilter',1

DELETE FROM RptFormula WHERE RptId=211 AND Slno=31 AND Formula='Disp_BillSts'
INSERT INTO RptFormula
SELECT 211,31,'Disp_BillSts','',1,263

DELETE FROM RptDetails WHERE RptId=29 AND Slno=7
INSERT INTO RptDetails
SELECT 29,7,'RptFilter',-1,'','FilterId,FilterId,FilterDesc','Display Net Amount*...','',1,'',
264,1,1,'Press F4/Double Click to Select Display Net Amount',0

DELETE FROM RptFilter WHERE RptId=29 AND SelcId=264
INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
SELECT 29,264,1,'Yes'
UNION
SELECT 29,264,2,'No'

DELETE FROM RptSelectionHd WHERE SelcId=264
INSERT INTO RptSelectionHd(SelcId,SelcName,TblName,Condition)
SELECT 264,'Sel_DispNetAmt','RptFilter',1

DELETE FROM RptFormula WHERE RptId=29 AND Slno=24 AND Formula='Disp_NetAmt'
INSERT INTO RptFormula
SELECT 29,24,'Disp_NetAmt','',1,264

IF NOT EXISTS(SELECT * FROM DayEndProcess WHERE ProcId=16)
BEGIN
	INSERT INTO DayEndProcess(ProcDate,ProcId,NextUpDate,ProcDesc)
	VALUES('2011-03-15',16,'2011-03-15','Stock-Productwise Upload')
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[RptCollectionDetail_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptCollectionDetail_Excel]
GO

CREATE TABLE dbo.[RptCollectionDetail_Excel]
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
		BalanceAmount           NUMERIC (38,6),
		CollectedAmount         NUMERIC (38,6),
		PayAmount           	NUMERIC (38,6),
		TotalBillAmount		NUMERIC (38,6),
		AmtStatus 		NVARCHAR(10),
		CollectionDate  DATETIME,
		CollectedBy     NVARCHAR(150),
		Remarks         NVARCHAR(500)    
	)ON [PRIMARY]
GO

--SRF-Nanda-227-002

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_ProductWiseStock]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_ProductWiseStock]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_ProductWiseStock]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[TransDate] [datetime] NULL,
	[LcnId] [int] NULL,
	[LcnCode] [nvarchar](100) NULL,
	[PrdId] [int] NULL,
	[PrdCode] [nvarchar](100) NULL,	
	[SalOpenStock] [numeric](18, 0) NULL,
	[UnSalOpenStock] [numeric](18, 0) NULL,
	[OfferOpenStock] [numeric](18, 0) NULL,
	[SalPurchase] [numeric](18, 0) NULL,
	[UnsalPurchase] [numeric](18, 0) NULL,
	[OfferPurchase] [numeric](18, 0) NULL,
	[SalPurReturn] [numeric](18, 0) NULL,
	[UnsalPurReturn] [numeric](18, 0) NULL,
	[OfferPurReturn] [numeric](18, 0) NULL,
	[SalSales] [numeric](18, 0) NULL,
	[UnSalSales] [numeric](18, 0) NULL,
	[OfferSales] [numeric](18, 0) NULL,
	[SalStockIn] [numeric](18, 0) NULL,
	[UnSalStockIn] [numeric](18, 0) NULL,
	[OfferStockIn] [numeric](18, 0) NULL,
	[SalStockOut] [numeric](18, 0) NULL,
	[UnSalStockOut] [numeric](18, 0) NULL,
	[OfferStockOut] [numeric](18, 0) NULL,
	[DamageIn] [numeric](18, 0) NULL,
	[DamageOut] [numeric](18, 0) NULL,
	[SalSalesReturn] [numeric](18, 0) NULL,
	[UnSalSalesReturn] [numeric](18, 0) NULL,
	[OfferSalesReturn] [numeric](18, 0) NULL,
	[SalStkJurIn] [numeric](18, 0) NULL,
	[UnSalStkJurIn] [numeric](18, 0) NULL,
	[OfferStkJurIn] [numeric](18, 0) NULL,
	[SalStkJurOut] [numeric](18, 0) NULL,
	[UnSalStkJurOut] [numeric](18, 0) NULL,
	[OfferStkJurOut] [numeric](18, 0) NULL,
	[SalBatTfrIn] [numeric](18, 0) NULL,
	[UnSalBatTfrIn] [numeric](18, 0) NULL,
	[OfferBatTfrIn] [numeric](18, 0) NULL,
	[SalBatTfrOut] [numeric](18, 0) NULL,
	[UnSalBatTfrOut] [numeric](18, 0) NULL,
	[OfferBatTfrOut] [numeric](18, 0) NULL,
	[SalLcnTfrIn] [numeric](18, 0) NULL,
	[UnSalLcnTfrIn] [numeric](18, 0) NULL,
	[OfferLcnTfrIn] [numeric](18, 0) NULL,
	[SalLcnTfrOut] [numeric](18, 0) NULL,
	[UnSalLcnTfrOut] [numeric](18, 0) NULL,
	[OfferLcnTfrOut] [numeric](18, 0) NULL,
	[SalReplacement] [numeric](18, 0) NULL,
	[OfferReplacement] [numeric](18, 0) NULL,
	[SalClsStock] [numeric](18, 0) NULL,
	[UnSalClsStock] [numeric](18, 0) NULL,
	[OfferClsStock] [numeric](18, 0) NULL,
	[UploadDate] [datetime] NULL,
	[UploadFlag] [nvarchar](10) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-227-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GetProductWiseDatewiseStock]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_GetProductWiseDatewiseStock]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Exec Proc_GetProductWiseDatewiseStock '2011/03/15','2011/03/15',2

CREATE	PROCEDURE [dbo].[Proc_GetProductWiseDatewiseStock]
(
	@Pi_FromDate 		DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_UserId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_BLGetStockLedgerSummaryDatewise
* PURPOSE	: To Get Stock Ledger Detail to Upload the data to Console
* CREATED	: Nandakumar R.G
* CREATED DATE	: 22/03/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	DECLARE @DistCode	As nVarchar(50)	

	SELECT @DistCode = DistributorCode FROM Distributor

	DECLARE @ProdDetail TABLE
	(
		LcnId	INT,
		PrdId INT,
		PrdBatId INT,
		TransDate DATETIME
	)

	DELETE FROM @ProdDetail

--	INSERT INTO @ProdDetail(LcnId,PrdId,PrdBatId,TransDate)	
--	SELECT A.LcnId,A.PrdId,A.PrdBatId,A.TransDate FROM
--	(
--		SELECT LcnId,PrdId,PrdBatId,MAX(TransDate) AS TransDate  FROM StockLedger Stk (NOLOCK)
--		WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate
--		GROUP BY LcnId,PrdId,PrdBatId
--	) A LEFT OUTER JOIN
--	(
--		SELECT DISTINCT LcnId,PrdId,PrdBatId,MAX(TransDate) AS TransDate FROM StockLedger Stk (NOLOCK)
--		WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
--		GROUP BY LcnId,PrdId,PrdBatId
--	) B
--	ON A.LcnId = B.LcnId and A.PrdId = B.PrdId
--	WHERE B.LcnId IS NULL AND B.PrdId IS NULL

	INSERT INTO @ProdDetail(LcnId,PrdId,PrdBatId,TransDate)	
	SELECT LcnId,PrdId,PrdBatId,MAX(TransDate) AS TransDate  FROM StockLedger Stk (NOLOCK)
	WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate
	GROUP BY LcnId,PrdId,PrdBatId

	SELECT DistCode,TransDate,LcnId,LcnCode,PrdId,0 AS PrdBatId,PrdCode,SalOpenStock,UnSalOpenStock,OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,
	SalPurReturn,UnsalPurReturn,OfferPurReturn,SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,
	OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,
	UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,
	OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,UploadDate,UploadFlag 
	INTO #Cs2Cn_Prk_ProductWiseStock FROM Cs2Cn_Prk_ProductWiseStock WHERE 1=2
				
	--Stocks for the given date---------
	INSERT INTO #Cs2Cn_Prk_ProductWiseStock(DistCode,TransDate,LcnId,LcnCode,PrdId,PrdBatId,PrdCode,SalOpenStock,UnSalOpenStock,OfferOpenStock,
	SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,
	SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,
	SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,
	SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,
	SalClsStock,UnSalClsStock,OfferClsStock,UploadDate,UploadFlag)	
	SELECT @DistCode,Sl.TransDate,Sl.LcnId,Lcn.LcnCode,Sl.PrdId,Sl.PrdBatId,Prd.PrdCCode,SUM(Sl.SalOpenStock),SUM(Sl.UnSalOpenStock),SUM(Sl.OfferOpenStock),
	SUM(Sl.SalPurchase),SUM(Sl.UnsalPurchase),SUM(Sl.OfferPurchase),SUM(Sl.SalPurReturn),SUM(Sl.UnsalPurReturn),SUM(Sl.OfferPurReturn),
	SUM(Sl.SalSales),SUM(Sl.UnSalSales),SUM(Sl.OfferSales),SUM(Sl.SalStockIn),SUM(Sl.UnSalStockIn),SUM(Sl.OfferStockIn),
	SUM(Sl.SalStockOut),SUM(Sl.UnSalStockOut),SUM(Sl.OfferStockOut),SUM(Sl.DamageIn),SUM(Sl.DamageOut),
	SUM(Sl.SalSalesReturn),SUM(Sl.UnSalSalesReturn),SUM(Sl.OfferSalesReturn),
	SUM(Sl.SalStkJurIn),SUM(Sl.UnSalStkJurIn),SUM(Sl.OfferStkJurIn),SUM(Sl.SalStkJurOut),SUM(Sl.UnSalStkJurOut),SUM(Sl.OfferStkJurOut),
	SUM(Sl.SalBatTfrIn),SUM(Sl.UnSalBatTfrIn),SUM(Sl.OfferBatTfrIn),SUM(Sl.SalBatTfrOut),SUM(Sl.UnSalBatTfrOut),SUM(Sl.OfferBatTfrOut),
	SUM(Sl.SalLcnTfrIn),SUM(Sl.UnSalLcnTfrIn),SUM(Sl.OfferLcnTfrIn),SUM(Sl.SalLcnTfrOut),SUM(Sl.UnSalLcnTfrOut),SUM(Sl.OfferLcnTfrOut),
	SUM(Sl.SalReplacement),SUM(Sl.OfferReplacement),SUM(Sl.SalClsStock),SUM(Sl.UnSalClsStock),SUM(Sl.OfferClsStock),GETDATE(),'N'
	FROM Product Prd (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)
	WHERE Sl.PrdId = Prd.PrdId AND
	Sl.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND Lcn.LcnId = Sl.LcnId
	GROUP BY Sl.TransDate,Sl.LcnId,Lcn.LcnCode,Sl.PrdId,Sl.PrdBatId,Prd.PrdCCode
	ORDER BY Sl.TransDate,Sl.LcnId,Lcn.LcnCode,Sl.PrdId,Sl.PrdBatId,Prd.PrdCCode
	
	--Stocks for those not included in the given date---------	
	INSERT INTO #Cs2Cn_Prk_ProductWiseStock(DistCode,TransDate,LcnId,LcnCode,PrdId,PrdBatId,PrdCode,SalOpenStock,UnSalOpenStock,OfferOpenStock,
	SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,
	SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,
	SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,
	SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,
	SalClsStock,UnSalClsStock,OfferClsStock,UploadDate,UploadFlag)	
	SELECT @DistCode,@Pi_FromDate,Sl.LcnId,Lcn.LcnCode,Sl.PrdId,Sl.PrdBatId,Prd.PrdCCode,SUM(Sl.SalClsStock),SUM(Sl.UnSalClsStock),SUM(Sl.OfferClsStock),
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,SUM(Sl.SalClsStock),SUM(Sl.UnSalClsStock),SUM(Sl.OfferClsStock),GETDATE(),'N'
	FROM Product Prd (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)
	LEFT OUTER JOIN Location Lcn (NOLOCK) ON Sl.LcnId=Lcn.LcnId
	WHERE Sl.TransDate=PrdDet.TransDate AND Sl.lcnid = PrdDet.lcnid
	AND Sl.TransDate<@Pi_FromDate AND Sl.PrdId=Prd.PrdId AND SL.PrdId=PrdDet.PrdId AND Sl.PrdBatId=PrdDet.PrdBatId
	GROUP BY Sl.TransDate,Sl.LcnId,Lcn.LcnCode,Sl.PrdId,Sl.PrdBatId,Prd.PrdCCode
	ORDER BY Sl.TransDate,Sl.LcnId,Lcn.LcnCode,Sl.PrdId,Sl.PrdBatId,Prd.PrdCCode
	
	
	--Stocks for those not included in the stockLedger---------
	INSERT INTO #Cs2Cn_Prk_ProductWiseStock(DistCode,TransDate,LcnId,LcnCode,PrdId,PrdBatId,PrdCode,SalOpenStock,UnSalOpenStock,OfferOpenStock,
	SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,
	SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,
	SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,
	SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,
	SalClsStock,UnSalClsStock,OfferClsStock,UploadDate,UploadFlag)	
	SELECT @DistCode,@Pi_FromDate,Lcn.LcnId,Lcn.LcnCode,Prd.PrdId,PrdBat.PrdBatId,Prd.PrdCCode,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,GETDATE(),'N'
	FROM Product Prd (NOLOCK)
	INNER JOIN ProductBatch PrdBat (NOLOCK) ON Prd.PrdId=PrdBat.PrdId
	CROSS JOIN Location Lcn (NOLOCK)
	WHERE CAST(Prd.PrdId AS NVARCHAR(10))+'~'+CAST(Lcn.LcnId AS NVARCHAR(10))+'~'+CAST(PrdBat.PrdBatId AS NVARCHAR(10)) NOT IN 
	(SELECT DISTINCT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdBat.PrdBatId AS NVARCHAR(10))
	FROM #Cs2Cn_Prk_ProductWiseStock WHERE TransDate=@Pi_FromDate)	
	GROUP BY Lcn.LcnId,Lcn.LcnCode,Prd.PrdId,PrdBat.PrdBatId,Prd.PrdCCode
	ORDER BY Lcn.LcnId,Lcn.LcnCode,Prd.PrdId,PrdBat.PrdBatId,Prd.PrdCCode	

	--Stocks for those not having batch---------
	INSERT INTO #Cs2Cn_Prk_ProductWiseStock(DistCode,TransDate,LcnId,LcnCode,PrdId,PrdBatId,PrdCode,SalOpenStock,UnSalOpenStock,OfferOpenStock,
	SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,
	SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,
	SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,
	SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,
	SalClsStock,UnSalClsStock,OfferClsStock,UploadDate,UploadFlag)	
	SELECT @DistCode,@Pi_FromDate,Lcn.LcnId,Lcn.LcnCode,Prd.PrdId,0,Prd.PrdCCode,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,GETDATE(),'N'
	FROM Product Prd (NOLOCK)	
	CROSS JOIN Location Lcn (NOLOCK)
	WHERE CAST(Prd.PrdId AS NVARCHAR(10))+'~'+CAST(Lcn.LcnId AS NVARCHAR(10)) NOT IN 
	(SELECT DISTINCT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10))
	FROM #Cs2Cn_Prk_ProductWiseStock WHERE TransDate=@Pi_FromDate)	
	GROUP BY Lcn.LcnId,Lcn.LcnCode,Prd.PrdId,Prd.PrdCCode
	ORDER BY Lcn.LcnId,Lcn.LcnCode,Prd.PrdId,Prd.PrdCCode

	INSERT INTO Cs2Cn_Prk_ProductWiseStock(DistCode,TransDate,LcnId,LcnCode,PrdId,PrdCode,SalOpenStock,UnSalOpenStock,OfferOpenStock,
	SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,
	SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,
	SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,
	SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,
	SalClsStock,UnSalClsStock,OfferClsStock,UploadDate,UploadFlag)	
--	SELECT DistCode,TransDate,LcnId,LcnCode,PrdId,PrdCode,SalOpenStock,UnSalOpenStock,OfferOpenStock,
--	SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,
--	SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,
--	SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,
--	SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,
--	SalClsStock,UnSalClsStock,OfferClsStock,UploadDate,UploadFlag FROM #Cs2Cn_Prk_ProductWiseStock
--	ORDER BY TransDate,LcnId,PrdId
	SELECT DistCode,TransDate,LcnId,LcnCode,PrdId,PrdCode,
	SUM(SalOpenStock),SUM(UnSalOpenStock),SUM(OfferOpenStock),
	SUM(SalPurchase),SUM(UnsalPurchase),SUM(OfferPurchase),SUM(SalPurReturn),SUM(UnsalPurReturn),SUM(OfferPurReturn),
	SUM(SalSales),SUM(UnSalSales),SUM(OfferSales),SUM(SalStockIn),SUM(UnSalStockIn),SUM(OfferStockIn),
	SUM(SalStockOut),SUM(UnSalStockOut),SUM(OfferStockOut),SUM(DamageIn),SUM(DamageOut),
	SUM(SalSalesReturn),SUM(UnSalSalesReturn),SUM(OfferSalesReturn),
	SUM(SalStkJurIn),SUM(UnSalStkJurIn),SUM(OfferStkJurIn),SUM(SalStkJurOut),SUM(UnSalStkJurOut),SUM(OfferStkJurOut),
	SUM(SalBatTfrIn),SUM(UnSalBatTfrIn),SUM(OfferBatTfrIn),SUM(SalBatTfrOut),SUM(UnSalBatTfrOut),SUM(OfferBatTfrOut),
	SUM(SalLcnTfrIn),SUM(UnSalLcnTfrIn),SUM(OfferLcnTfrIn),SUM(SalLcnTfrOut),SUM(UnSalLcnTfrOut),SUM(OfferLcnTfrOut),
	SUM(SalReplacement),SUM(OfferReplacement),SUM(SalClsStock),SUM(UnSalClsStock),SUM(OfferClsStock),MAX(UploadDate),UploadFlag
	FROM #Cs2Cn_Prk_ProductWiseStock
	GROUP BY DistCode,TransDate,LcnId,LcnCode,PrdId,PrdCode,UploadFlag
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
--SRF-Nanda-227-004
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_ProductWiseStock]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_ProductWiseStock]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
BEGIN TRANSACTION
--SELECT * FROM DayEndProcess
--UPDATE DayEndProcess Set NextUpDate = '22/03/2011' Where procId = 16
EXEC Proc_Cs2Cn_ProductWiseStock 0
--SELECT * FROM StockLedger WHERE TransDate>='22/03/2011'
SELECT TransDate,PrdId,LcnId,COUNT(*) FROM Cs2Cn_Prk_ProductWiseStock --ORDER BY TransDate,PrdId,LcnId
GROUP BY TransDate,PrdId,LcnId-- HAVING COUNT(*)>1
ROLLBACK TRANSACTION
*/

CREATE	PROCEDURE [dbo].[Proc_Cs2Cn_ProductWiseStock]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_ProductWiseStock
* PURPOSE		: To Extract Stock Ledger Details-Productwise for CoreStocky to Console upload 
* CREATED		: Nandakumar R.G
* CREATED DATE	: 22/03/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
		
	DECLARE @ChkDate	AS DATETIME
	DECLARE @PrdId	AS	INT
	DECLARE @TransDate AS	DATETIME

	SET @Po_ErrNo=0

	DELETE FROM Cs2Cn_Prk_ProductWiseStock WHERE UploadFlag = 'Y'	

	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where ProcId = 16
	SELECT @TransDate=GETDATE()

	WHILE @ChkDate<=@TransDate
	BEGIN
		EXEC Proc_GetProductWiseDatewiseStock @ChkDate, @ChkDate,1				
		SET @ChkDate=DATEADD(D,1,@ChkDate)		
	END
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GETDATE(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	WHERE ProcId = 16

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
--SRF-Nanda-227-006
if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplate_CrDbAdjustment]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptBillTemplate_CrDbAdjustment]
GO

CREATE TABLE [dbo].[RptBillTemplate_CrDbAdjustment]
(
	[SalId] [int] NULL,
	[SalInvNo] [nvarchar](50) NULL,
	[NoteNumber] [nvarchar](25) NULL,
	[Amount] [numeric](38, 2) NULL,
	[PreviousAmount] [numeric](38, 2) NULL,
	[CrDbRemarks] [nvarchar](500) NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-227-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBillTemplateFinal]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC PROC_RptBillTemplateFinal 16,1,0,'NVSPLRATE20100119',0,0,1,'RPTBT_VIEW_FINAL_BILLTEMPLATE'

CREATE PROCEDURE [dbo].[Proc_RptBillTemplateFinal]
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
		if len(@FieldTypeList) > 3000
		begin
			Set @FieldTypeList2 = @FieldTypeList
			Set @FieldTypeList = ''
		end
		--->Added By Nanda on 12/03/2010
		IF LEN(@FieldList)>3000
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
	Select @Sub_Val = TaxDt  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)
		SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId
		FROM SalesInvoiceProductTax SI , TaxConfiguration T,SalesInvoice S,RptBillToPrint B
		WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc
	End

	------------------------------ Other
	Select @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)
		SELECT SI.SalId,S.SalInvNo,
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,
		Adjamt Amount,@Pi_UsrId
		FROM SalInvOtherAdj SI,PurSalAccConfig P,SalesInvoice S,RptBillToPrint B
		WHERE P.TransactionId = 2
		and SI.AccDescId = P.AccDescId
		and SI.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
	End

	---------------------------------------Replacement
	Select @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId
		FROM ReplacementHd H, ReplacementOut D, Product P, ProductBatch PB,SalesInvoice SI,RptBillToPrint B
		WHERE H.SalId <> 0
		and H.RepRefNo = D.RepRefNo
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = SI.SalId
		and SI.SalInvNo = B.[Bill Number]
	End

	----------------------------------Credit Debit Adjustment
	SELECT @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	IF @Sub_Val = 1
	BEGIN
		INSERT INTO RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,PreviousAmount,CrDbRemarks,UsrId)
		SELECT A.SalId,S.SalInvNo,A.CrNoteNumber,A.CrAdjAmount,A.AdjSoFar,CNR.Remarks,@Pi_UsrId
		FROM SalInvCrNoteAdj A,SalesInvoice S,RptBillToPrint B,CreditNoteRetailer CNR
		WHERE A.SalId = s.SalId and S.SalInvNo = B.[Bill Number] AND CNR.CrNoteNumber=A.CrNoteNumber
		UNION ALL
		SELECT A.SalId,S.SalInvNo,A.DbNoteNumber,A.DbAdjAmount,A.AdjSoFar,DNR.Remarks,@Pi_UsrId
		FROM SalInvDbNoteAdj A,SalesInvoice S,RptBillToPrint B,DebitNoteRetailer DNR
		WHERE A.SalId = s.SalId and S.SalInvNo = B.[Bill Number] AND DNR.DbNoteNumber=A.DbNoteNumber
	END

	---------------------------------------Market Return
	Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
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
	End

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
			[UsrId],[Visibility],[AmtInWrd]
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
		[UsrId],[Visibility],[AmtInWrd]
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
		[UsrId],[Visibility],[AmtInWrd]
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
--SRF-Nanda-227-011
UPDATE ETLMaster SET ExportFnName='Fn_ExportProductBatch',
ImportProcName='Proc_ImportProductBatch',
ParkTable='ETL_Prk_ProductBatch',ValidateProcName='Proc_ValidateProductBatch'
WHERE SlNo=13

--SRF-Nanda-227-012

DELETE FROM Configuration WHERE ModuleName='Stock Management' AND ModuleId='STKMGNT12'

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('STKMGNT12','Stock Management','Enable selection of transaction type at grid level',0,'',0.00,12)

--SRF-Nanda-227-013

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_QPSSchemeCrediteNoteConversion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_QPSSchemeCrediteNoteConversion]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM SalesInvoiceQPSRedeemed
--SELECT * FROM BillAppliedSchemeHd
--DELETE FROM BilledPrdHdForQPSScheme
EXEC Proc_QPSSchemeCrediteNoteConversion 2,'2011-03-14',0
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd WHERE TransId = 2 And UsrId = 1
--SELECT * FROM BillAppliedSchemeHd
--SELECT * FROM SalesInvoiceQPSCumulative
--SELECT * FROM SchemeMaster
--SELECT * FROM CreditNoteRetailer ORDER BY CrNoteNumber
--SELECT * FROM SalesInvoiceQPSRedeemed WHERE LastModDate>'2010-04-06' 
--SELECT * FROM SalesInvoiceQPSSchemeAdj 
ROLLBACK TRANSACTION
*/

CREATE        PROCEDURE [dbo].[Proc_QPSSchemeCrediteNoteConversion]
(
	@Pi_TransId		INT,
	@Pi_TransDate	DATETIME,
	@Po_ErrNo		INT		OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_QPSSchemeCrediteNoteConversion
* PURPOSE		: To Apply the QPS Scheme and convert the Scheme amount as credit note
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 19/03/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN		
	DECLARE @RtrId				AS INT
	DECLARE @RtrCode			AS NVARCHAR(100)
	DECLARE @CmpRtrCode			AS NVARCHAR(100)
	DECLARE @RtrName			AS NVARCHAR(200)
	DECLARE @UsrId				AS INT
	DECLARE @SchApplicable		AS INT
	DECLARE @SMId				AS INT
	DECLARE @RMId				AS INT
	DECLARE	@SchId				AS INT
	DECLARE	@SchCode			AS NVARCHAR(200)
	DECLARE	@CmpSchCode			AS NVARCHAR(200)
	DECLARE	@CombiSch			AS INT
	DECLARE	@QPS				AS INT	
	DECLARE	@LcnId				AS INT	
	DECLARE	@AvlSchId			AS INT
	DECLARE	@AvlSlabId			AS INT
	DECLARE	@AvlSchCode			AS NVARCHAR(200)
	DECLARE	@AvlCmpSchCode		AS NVARCHAR(200)
	DECLARE	@AvlSchAmt			AS NUMERIC(38,6)
	DECLARE	@AvlSchDiscPerc		AS NUMERIC(38,6)
	DECLARE	@SchAmtToConvert	AS NUMERIC(38,6)
	DECLARE	@SchApplicableAmt   AS NUMERIC(38,6)
	
	DECLARE	@AvlSchDesc			AS NVARCHAR(400)
	DECLARE @SchCoaId			AS INT
	DECLARE	@CrNoteNo			AS NVARCHAR(200)
	DECLARE @ErrStatus			AS INT
	DECLARE @VocDate			AS DATETIME
	DECLARE @MinPrdId			AS INT
	DECLARE @MinPrdBatId		AS INT
	DECLARE @MinRtrId			AS INT	
	SELECT @SchCoaId=CoaId FROM COAMaster WHERE Accode='4220001'	
	SET @LcnId=0
	SELECT @LcnId=LcnId FROM Location WHERE DefaultLocation=1
	IF @LcnId=0
	BEGIN
		SELECT @LcnId=LcnId FROM Location WHERE LcnId IN (SELECT MIN(LcnId) FROM Location)
	END	

	if exists (select * from dbo.sysobjects where id = object_id(N'[TempSalesInvoiceQPSRedeemed]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [TempSalesInvoiceQPSRedeemed]
	
	SELECT * INTO TempSalesInvoiceQPSRedeemed FROM SalesInvoiceQPSRedeemed

	SET @SMId=0
	SET @RMId=0
	SET @MinPrdId=0
	SET @MinPrdBatId=0
	SELECT @SMId=ISNULL(MAX(SMId),0) FROM SalesMan
	SELECT @RMId=ISNULL(MAX(RMId),0) FROM RouteMaster
	SELECT @MinPrdId=ISNULL(MIN(PrdId),0) FROM Product
	SELECT @MinPrdBatId=ISNULL(MIN(PrdBatId),0) FROM ProductBatch
	SELECT @MinRtrId=ISNULL(MIN(RtrId),0) FROM Retailer	
	SELECT @MinPrdId=ISNULL(MIN(PrdId),0) FROM ProductBatch WHERE PrdBatId=@MinPrdBatId
	SET @Po_ErrNo=0
	SET @UsrId=10000
	IF @SMId<>0 AND @RMId<>0 AND @MinPrdId<>0 AND @MinPrdBatId<>0 AND @MinRtrId<>0
	BEGIN
		DELETE FROM BilledPrdHdForScheme --WHERE UsrId=@UsrId	
		DECLARE @SchemeAvailable TABLE
		(
			SchId			INT,
			SchCode			NVARCHAR(200),
			CmpSchCode		NVARCHAR(200),
			CombiSch		INT,
			QPS				INT		
		)
		--->To insert dummy invoice and details for applying QPS scheme		
		DELETE FROM SalesInvoiceProduct WHERE SalId=-1000
		DELETE FROM SalesInvoice WHERE SalId=-1000	

		INSERT INTO SalesInvoice (SalId,SalInvNo,SalInvDate,SalInvRef,CmpId,LcnId,BillType,BillMode,SMId,RMId,DlvRMId,RtrId,InterimSales,FillAllPrd,OrderKeyNo,
		OrderDate,BillShipTo,RtrShipId,Remarks,SalGrossAmount,SalRateDiffAmount,SalSplDiscAmount,SalSchDiscAmount,SalDBDiscAmount,SalTaxAmount,SalCDPer,
		SalCDAmount,SalCDGivenOn,RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrCDEdited,DBAdjAmount,CRAdjAmount,MarketRetAmount,OtherCharges,WindowDisplay,
		WindowDisplayAmount,OnAccount,OnAccountAmount,ReplacementDiffAmount,TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,
		SalPayAmt,SalRoundOff,SalRoundOffAmt,DlvSts,VehicleId,DlvBoyId,SalDlvDate,BillSeqId,ConfigWinDisp,DecPoints,Upload,SchemeUpLoad,SalOffRoute,
		PrimaryRefCode,PrimaryApplicable,InvType,Availability,LastModBy,LastModDate,AuthId,AuthDate,BillPurUpLoad,FundUpload)
		VALUES (-1000,'JJDummyForQPS',GETDATE(),'',0,@LcnId,1,2,@SMId,@RMId,@RMId,@MinRtrId,0,0,'',GETDATE(),1,15,'',23653.28,0,0,1182.66,0,2808.83,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,
		2808.83,1182.66,25279.44,0,25279.5,0,1,0.05,4,1,1,GETDATE(),1,1,2,1,1,0,'',0,1,1,1,GETDATE(),1,GETDATE(),1,1)
		INSERT INTO SalesInvoiceProduct(SalId,PrdId,PrdBatId,Uom1Id,Uom1ConvFact,Uom1Qty,Uom2Id,Uom2ConvFact,Uom2Qty,BaseQty,SalSchFreeQty,SalManFreeQty,
		ReasonId,PrdUnitMRP,PrdUnitSelRate,PrdUom1SelRate,PrdUom1EditedSelRate,PrdRateDiffAmount,PrdGrossAmount,PrdGrossAmountAftEdit,SplDiscAmount,
		SplDiscPercent,PrdSplDiscAmount,PrdSchDiscAmount,PrdDBDiscAmount,PrdCDAmount,PrdTaxAmount,PrdUom1NetRate,PrdUom1EditedNetRate,PrdNetRateDiffAmount,
		PrdActualNetAmount,PrdNetAmount,SlNo,DrugBatchDesc,RateDiffClaimId,DlvBoyClmId,SmIncCalcId,SmDAClaimId,VanSubsidyClmId,SplDiscClaimId,RateEditClaimReq,
		VatTaxClmId,ReturnedQty,ReturnedManFreeQty,PriceId,SplPriceId,PrimarySchemeAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate,RdClaimflag,
		KeyClaimflag)
		VALUES (-1000,@MinPrdId,@MinPrdBatId,1,1,2,0,0,0,400,0,0,0,24,17.87,3574,3574,0,7148,7148,0,0,0,357.4,0,0,848.83,3819.71,0,0,7639.43,7639.43,2,'',0,0,0,0,0,0,0,0,0,0,
		1,0,0,1,1,GETDATE(),1,GETDATE(),0,0)
		SET @SMId=0
		SET @RMId=0

		--->Retailerwise QPS conversion
		DECLARE Cur_Retailer CURSOR	
		FOR SELECT RtrId,RtrCode,CmpRtrCode,RtrName FROM Retailer WHERE RtrId
		IN (SELECT DISTINCT B.RtrId FROM SchemeMaster C INNER JOIN SalesInvoiceQPSCumulative B ON C.SchId = B.SchId 
		WHERE C.SchValidTill <= @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1)
		OPEN Cur_Retailer
		FETCH NEXT FROM Cur_Retailer INTO @RtrId,@RtrCode,@CmpRtrCode,@RtrName
		WHILE @@FETCH_STATUS=0
		BEGIN

			TRUNCATE TABLE BilledPrdHdForScheme --WHERE UsrId=@UsrId --AND RtrId=@RtrId       
			DELETE FROM @SchemeAvailable

			INSERT INTO BilledPrdHdForScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice)
			VALUES(2,@RtrId,1,1,10.00,100,1000.00,12.00,2,@UsrId,7.50)

			--->Modified By Nanda on 20/10/2010
--			INSERT INTO @SchemeAvailable(SchId,SchCode,CmpSchCode,CombiSch,QPS)
--			SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
--			FROM BilledPrdHdForScheme A
--			INNER JOIN Fn_ReturnApplicableProductDtQPS() B ON A.PrdId = B.PrdId AND A.UsrId = @UsrId   AND A.TransId =  2
--			INNER JOIN SchemeMaster C ON C.SchId = B.SchId WHERE
--			C.SchValidTill < @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1
			INSERT INTO @SchemeAvailable(SchId,SchCode,CmpSchCode,CombiSch,QPS)
			SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
			FROM Fn_ReturnApplicableProductDtQPS() B 
			INNER JOIN SchemeMaster C ON C.SchId = B.SchId WHERE
			C.SchValidTill <= @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1 
			AND C.SchId NOT IN (SELECT SchId FROM TempSalesInvoiceQPSRedeemed WHERE SalId=-1000) 
			AND C.SchId NOT IN (SELECT SchId FROM SchQPSConvDetails)
			--->Till Here

			SELECT @RMId=ISNULL(MAX(RMId),0) FROM RetailerMarket WHERE RtrId=@RtrId
			SELECT @SMId=ISNULL(MAX(SMId),0) FROM SalesmanMarket WHERE RMId=@RMId
			
			IF @RMId=0
			BEGIN
				SELECT @RMId=ISNULL(MAX(RMId),0) FROM SalesInvoice WHERE RtrId=@RtrId
			END
			IF @SMId=0
			BEGIN
				SELECT @SMId=ISNULL(MAX(SMId),0) FROM SalesInvoice WHERE RMId=@RMId AND RtrId=@RtrId
			END
			IF @SMId=0
			BEGIN
				SELECT @SMId=ISNULL(MAX(SMId),0) FROM SalesInvoice WHERE RtrId=@RtrId
			END

			UPDATE SalesInvoice SET RtrId=@RtrId,SMId=@SMId,RMId=@RMId WHERE SalId=-1000
			
			TRUNCATE TABLE BillAppliedSchemeHd --WHERE Usrid = @UsrId And TransId = 2
			TRUNCATE TABLE ApportionSchemeDetails --WHERE Usrid = @UsrId And TransId = 2
			TRUNCATE TABLE BilledPrdRedeemedForQPS --WHERE Userid = @UsrId And TransId = 2
			TRUNCATE TABLE BilledPrdHdForQPSScheme

			--->Applying QPS Scheme
			DECLARE Cur_Scheme CURSOR	
			FOR SELECT DISTINCT SchId,SchCode,CmpSchCode,CombiSch,QPS FROM @SchemeAvailable
			OPEN Cur_Scheme 
			FETCH NEXT FROM Cur_Scheme INTO @SchId,@SchCode,@CmpSchCode,@CombiSch,@QPS
			WHILE @@FETCH_STATUS=0
			BEGIN
--				SELECT '@SchId',@SchId,@SchCode,@CmpSchCode,@CombiSch,@QPS				

				SET @SchApplicable=0
				EXEC Proc_ReturnSchemeApplicable @SMId,@RMId,@RtrId,1,1,@SchId,@Po_Applicable= @SchApplicable OUTPUT
				IF @SchApplicable =1
				BEGIN
					IF @CombiSch=1
					BEGIN
						EXEC Proc_ApplyCombiSchemeInBill @SchId,@RtrId,0,@UsrId,2		
					END
					ELSE
					BEGIN
						EXEC Proc_ApplyQPSSchemeInBill @SchId,@RtrId,0,@UsrId,2		
					END
				END
				FETCH NEXT FROM Cur_Scheme INTO @SchId,@SchCode,@CmpSchCode,@CombiSch,@QPS
			END
			CLOSE Cur_Scheme
			DEALLOCATE Cur_Scheme
			--->To get the Free Products
			IF EXISTS(SELECT DISTINCT SchId,SlabId  FROM BillAppliedSchemeHd  Where TransId = 2 And UsrId = @UsrId
			AND FreeToBeGiven >0)
			BEGIN			
				DECLARE Cur_SchFree CURSOR	
				FOR SELECT DISTINCT SchId,SlabId  FROM BillAppliedSchemeHd  Where TransId = 2 And UsrId = @UsrId
				AND FreeToBeGiven >0
				OPEN Cur_SchFree
				FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSlabId
				WHILE @@FETCH_STATUS=0
				BEGIN	
					EXEC Proc_ReturnSchMultiFree @UsrId,2,@LcnId,@AvlSchId,@AvlSlabId,-1000
					FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSlabId
				END
				CLOSE Cur_SchFree
				DEALLOCATE Cur_SchFree
			END
			--->Get the scheme details
			CREATE TABLE #AppliedSchemeDetails
			(
				SchId			INT,
				SchCode			NVARCHAR(200),
				CmpSchCode		NVARCHAR(200),
				FlexiSch		INT,
				FlexiSchType	INT,
				SlabId			INT,
				SchemeAmount	NUMERIC(38,6),
				SchemeDiscount	NUMERIC(38,6),
				Points			NUMERIC(38,0),
				FlxDisc			INT,
				FlxValueDisc	NUMERIC(38,2),
				FlxFreePrd		INT,
				FlxGiftPrd		INT,
				FreePrdId		INT,
				FreePrdBatId	INT,
				FreeToBeGiven	INT,
				EditScheme		INT,
				NoOfTimes		INT,
				Usrid			INT,
				FlxPoints		NUMERIC(38,0),
				GiftPrdId		INT,
				GiftPrdBatId	INT,
				GiftToBeGiven	INT,
				SchType			INT,
				SchDesc			NVARCHAR(400)
			)
			INSERT INTO #AppliedSchemeDetails
			SELECT DISTINCT A.SchId,A.SchCode,B.CmpSchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, SUM(A.SchemeAmount) AS SchemeAmount,
			CASE A.SchType WHEN 0 THEN A.SchemeDiscount WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,
			A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, SUM(A.FreeToBeGiven) AS FreeToBeGiven,
			B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,
			A.SchType,B.SchDsc
			FROM BillAppliedSchemeHd A
			INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE Usrid=@UsrId AND TransId = 2 AND B.QPS=1 AND B.ApyQpsSch = 1
			GROUP BY A.SchId,A.SchCode,B.CmpSchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,
			A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId,
			A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,PrdId,PrdBatId,B.SchDsc
			ORDER BY A.SchId ASC,A.SlabId ASC
			--->Convert the scheme amount as credit note and corresponding postings
			IF EXISTS(SELECT * FROM #AppliedSchemeDetails)
			BEGIN
				DECLARE Cur_SchFree CURSOR	
				FOR SELECT SchId,SchCode,CmpSchCode,SchemeAmount,SchemeDiscount,SchDesc FROM #AppliedSchemeDetails		
				OPEN Cur_SchFree
				FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSchCode,@AvlCmpSchCode,@AvlSchAmt,@AvlSchDiscPerc,@AvlSchDesc
				WHILE @@FETCH_STATUS=0
				BEGIN				
					SET @SchAmtToConvert=0
					SELECT @SchApplicableAmt=SUM(GrossAmount) FROM BilledPrdHdForQPSScheme WHERE QPSPrd=1 AND UsrId=@UsrId
					AND TransId=2 AND SchId=@AvlSchId AND RtrId=@RtrId
					SET @SchAmtToConvert=@AvlSchAmt+((@SchApplicableAmt*@AvlSchDiscPerc)/100)
					IF @SchAmtToConvert>0
					BEGIN
						SELECT @CrNoteNo= dbo.Fn_GetPrimaryKeyString('CreditNoteRetailer','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
						INSERT INTO CreditNoteRetailer(CrNoteNumber,CrNoteDate,RtrId,CoaId,ReasonId,Amount,CrAdjAmount,Status,
						PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
						VALUES(@CrNoteNo,GETDATE(),@RtrId,@SchCoaId,3,@SchAmtToConvert,0,1,'',2,'',1,1,GETDATE(),1,GETDATE(),
						'From QPS Scheme:'+@AvlSchDesc+'(Auto Conversion)')

						UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='CreditNoteRetailer' AND FldName='CrNoteNumber'

						SET @VocDate=GETDATE()
						EXEC Proc_VoucherPosting 18,1,@CrNoteNo,3,6,@UsrId,@VocDate,@Po_ErrNo=@ErrStatus OUTPUT

						IF @ErrStatus<0
						BEGIN
							SET @Po_ErrNo=1

							DELETE FROM SalesInvoiceProduct WHERE SalId=-1000
							DELETE FROM SalesInvoice WHERE SalId=-1000	

							CLOSE Cur_SchFree
							DEALLOCATE Cur_SchFree

							CLOSE Cur_Retailer
							DEALLOCATE Cur_Retailer

							RETURN
						END
					
						UPDATE BillAppliedSchemeHd SET IsSelected=1 WHERE TransId=2
						EXEC Proc_AssignQPSRedeemed -1000,@UsrId,2

						--->Insert Values into SalesInvoiceQPSSchemeAdj
						INSERT INTO SalesInvoiceQPSSchemeAdj(SalId,RtrId,SchId,CmpSchCode,SchCode,SchAmount,AdjAmount,CrNoteAmount,SlabId,Mode,Upload,
						Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(-1000,@RtrId,@AvlSchId,@CmpSchCode,@CmpSchCode,@SchAmtToConvert,0,@SchAmtToConvert,1,2,0,
						1,1,CONVERT(NVARCHAR(10),GETDATE(),110),1,CONVERT(NVARCHAR(10),GETDATE(),110))
					END
					FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSchCode,@AvlCmpSchCode,@AvlSchAmt,@AvlSchDiscPerc,@AvlSchDesc
				END
				CLOSE Cur_SchFree
				DEALLOCATE Cur_SchFree
			END
			DROP TABLE #AppliedSchemeDetails
			FETCH NEXT FROM Cur_Retailer INTO @RtrId,@RtrCode,@CmpRtrCode,@RtrName
		END
		CLOSE Cur_Retailer
		DEALLOCATE Cur_Retailer
		DELETE FROM BilledPrdHdForScheme WHERE UsrId=@UsrId
		DELETE FROM SalesInvoiceProduct WHERE SalId=-1000
		DELETE FROM SalesInvoice WHERE SalId=-1000	
	END

	INSERT INTO SchQPSConvDetails(SchId,CmpSchCode,ConvDate)
	SELECT DISTINCT C.SchId,C.CmpSchCode,GETDATE() FROM SchemeMaster C INNER JOIN SalesInvoiceQPSCumulative B ON C.SchId = B.SchId 
	WHERE C.SchValidTill <= @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-227-014

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBankSlipReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBankSlipReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

---EXEC Proc_RptBankSlipReport 53,1,0,'CoreStocky',0,0,1

CREATE PROCEDURE [dbo].[Proc_RptBankSlipReport]
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
				InvInsAmt NUMERIC(38,6),
				InvDepDate DATETIME 
		
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
				InvInsAmt NUMERIC(38,6),
				InvDepDate DATETIME'
	SET @TblFields = 'RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvInsAmt,InvDepDate'
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
		
			INSERT INTO #RptBankSlipReport (RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvInsAmt,InvDepDate)
				SELECT RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,
				CAST(InvInsNo AS NVARCHAR(25)),InvInsDate,SalInvAmt,InvDepDate
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
	SELECT * FROM #RptBankSlipReport
		DECLARE @RecCount AS BIGINT 
		SET @RecCount =(SELECT count(*) FROM #RptBankSlipReport)
    	IF @RecCount > 0
			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptBankSlip_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					DROP TABLE [RptBankSlip_Excel]
					CREATE TABLE RptBankSlip_Excel (RtrBankId BIGINT,DistributorBnkName NVARCHAR(50),RtrBnkName	NVARCHAR(50),RtrBnkBrID	BIGINT,RtrBnkBrName  NVARCHAR(50),DisBnkId INT,DisBranchId INT,
						DistributorBnkBrName NVARCHAR(50),InvInsNo NVARCHAR(25),InvInsDate varchar(10),InvDepDate varchar(10),InvInsAmt NUMERIC(38,6))
                IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='TbpRptBankSlipReport')
					BEGIN 
						DROP TABLE TbpRptBankSlipReport
						SELECT * INTO TbpRptBankSlipReport FROM RptBankSlip_Excel WHERE 1=2
					END 
				 ELSE
					BEGIN 
						SELECT * INTO TbpRptBankSlipReport FROM RptBankSlip_Excel WHERE 1=2
					END 
				INSERT INTO TbpRptBankSlipReport (RtrBankId ,DistributorBnkName,InvInsAmt)
					SELECT 999999,'Total',sum(InvInsAmt) 
				FROM 
						#RptBankSlipReport
				INSERT INTO RptBankSlip_Excel (RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvDepDate,InvInsAmt)
                  SELECT RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,(CONVERT(NVARCHAR(11),InvInsDate ,103)),(CONVERT(NVARCHAR(11),InvDepDate ,103)),InvInsAmt
					FROM #RptBankSlipReport
				
				INSERT INTO RptBankSlip_Excel (RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvDepDate,InvInsAmt)
				SELECT RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvDepDate,InvInsAmt  
					FROM TbpRptBankSlipReport 
			END
		
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
--SRF-Nanda-227-015
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptCollectionReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptCollectionReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptCollectionReport 4,2,0,'dabur1',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptCollectionReport]
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
	END
	ELSE
	BEGIN
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE RptId=4 AND SlNo IN (2,3)
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE RptId=4 AND SlNo IN (5,6)
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
		InvRcpNo nvarchar(50)	
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
				InvRcpNo nvarchar(50)'
	SET @TblFields = 'SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
			  BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
			  BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,
				CollChqAmt,CollDDAmt,CollRTGSAmt,InvRcpNo'
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
		BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,InvRcpNo)
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
						BalanceAmount           NUMERIC (38,6),
						CollectedAmount         NUMERIC (38,6),
						PayAmount           	NUMERIC (38,6),
						TotalBillAmount		NUMERIC (38,6),
						AmtStatus 		NVARCHAR(10)
					)
			END 
		INSERT INTO RptCollectionDetail_Excel(SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
				BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
				CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus)
		SELECT  SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
				BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
				ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,
				ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,
				BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus
		FROM	#RptCollectionDetail 
	    ORDER BY SalId,InvRcpDate,InvRcpNo
		UPDATE RPT SET RPT.[RtrCode]=R.RtrCode FROM RptCollectionDetail_Excel RPT,Retailer R WHERE RPT.[RtrName]=R.RtrName
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
--SRF-Nanda-227-016
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptECAnalysisReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptECAnalysisReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

----EXEC Proc_RptECAnalysisReport 166,2,0,'Dabur1',0,0,1

CREATE PROCEDURE [dbo].[Proc_RptECAnalysisReport]
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
/**********************************************************************************
* PROCEDURE		: Proc_RptECAnalysisReport
* PURPOSE		: To Generate Effective Coverage Analysis Report
* CREATED		: Thiruvengadam.L
* CREATED DATE	: 10/09/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}
* 30.09.2009	Thiruvengadam		Bug No:20729
* 11.03.2010   	Panneer			Added Excel Table
**********************************************************************************/
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
	
	DECLARE @RtId		AS  INT
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate		AS	DATETIME
	DECLARE @SMId	 	AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @BasedOn	AS  INT
	DECLARE @CmpId		AS	INT
	DECLARE @RtrCtgLvl	AS	INT
	DECLARE @RtrCtgLvlVal	AS INT
	DECLARE @RtrValClass	AS INT
	DECLARE @RtrGroup		AS INT
	DECLARE @PrdHieLvl		AS INT
	DECLARE @PrdHieLvlVal	AS INT
	DECLARE @PrdId			AS INT
	DECLARE @PrdCatId		AS INT
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrCtgLvl = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @RtrCtgLvlVal = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @RtrValClass = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @RtrGroup = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,215,@Pi_UsrId))
	SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @PrdHieLvl = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdHieLvlVal = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @BasedOn = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,246,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	PRINT @BasedOn
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	Create TABLE #RptECAnalysis
	(
			Code			NVARCHAR(200),
			Name	        NVARCHAR(200),		
			Unit 		    NUMERIC(38,6),
			SalesValue 		NUMERIC(38,6),		
			EC				INT,
			TLS				INT	
	)
	SET @TblName = 'RptECAnalysis'
	
	SET @TblStruct = 'Code				NVARCHAR(200),
					  Name	            NVARCHAR(200),		
					  Unit 		        NUMERIC(38,6),
					  SalesValue 		NUMERIC(38,6),		
					  EC				INT,
					  TLS				INT'
				
	SET @TblFields = 'Code,Name,Unit,SalesValue,EC,TLS'
	
	IF @BasedOn=1 --Product
	BEGIN
		UPDATE RptExcelHeaders SET DisplayName = 'Product Code' WHERE RptId = 166 AND SlNo = 1
		UPDATE RptExcelHeaders SET DisplayName = 'Product Name' WHERE RptId = 166 AND SlNo = 2
        UPDATE RptFormula SET FormulaValue='Product Code' WHERE RptId=166 AND SlNo=31
		UPDATE RptFormula SET FormulaValue='Product Name' WHERE RptId=166 AND SlNo=32
		UPDATE RptFormula SET FormulaValue='Product' WHERE RptId=166 AND SlNo=28
	END
	ELSE IF @BasedOn=2 --Route
	BEGIN
		UPDATE RptExcelHeaders SET DisplayName = 'Route Code' WHERE RptId = 166 AND SlNo = 1
		UPDATE RptExcelHeaders SET DisplayName = 'Route Name' WHERE RptId = 166 AND SlNo = 2
		UPDATE RptExcelHeaders SET DisplayFlag = 0 WHERE RptId = 166 AND SlNo = 3
		UPDATE RptFormula SET FormulaValue='Route Code' WHERE RptId=166 AND SlNo=31
		UPDATE RptFormula SET FormulaValue='Route Name' WHERE RptId=166 AND SlNo=32
		UPDATE RptFormula SET FormulaValue='Route' WHERE RptId=166 AND SlNo=28
	END
	ELSE IF @BasedOn=3 --Retailer
	BEGIN
		UPDATE RptExcelHeaders SET DisplayName = 'Retailer Code' WHERE RptId = 166 AND SlNo = 1
		UPDATE RptExcelHeaders SET DisplayName = 'Retailer Name' WHERE RptId = 166 AND SlNo = 2
		UPDATE RptExcelHeaders SET DisplayFlag = 0 WHERE RptId = 166 AND SlNo = 3
		UPDATE RptExcelHeaders SET DisplayName = 'Total No.Of Invoices' WHERE RptId = 166 AND SlNo = 5
		UPDATE RptFormula SET FormulaValue='Retailer Code' WHERE RptId=166 AND SlNo=31
		UPDATE RptFormula SET FormulaValue='Retailer Name' WHERE RptId=166 AND SlNo=32
		UPDATE RptFormula SET FormulaValue='Retailer' WHERE RptId=166 AND SlNo=28
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
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		IF @BasedOn=1		--Product
		BEGIN
			INSERT INTO #RptECAnalysis(Code,Name,Unit,SalesValue,EC,TLS)
			SELECT P.PrdDCode as Code,P.PrdName AS Name,sum(SIP.BaseQty) AS Unit,sum(SIP.PrdGrossAmount) AS SalesValue,count(DISTINCT SI.rtrid) AS EC,count(SIP.prdid) AS TLS FROM Product P,ProductBatch PB,SalesInvoice SI,
			SalesInvoiceProduct SIP,Company C,Salesman S,RouteMaster RM,Retailer R,RetailerValueClass RVC,RetailerCategory RC,
			RetailerCategorylevel RCL,RetailerValueClassMap RVCM,ProductCategoryValue PCV,RetailerCategorylevel RCV,ProductCategoryLevel PCL
			WHERE SIP.PrdId=P.PrdId AND SIP.PrdBatId=PB.PrdBatId AND PB.PrdId=P.PrdId
			AND SIP.SalId=SI.SalId AND SI.RtrId=R.RtrId AND RCV.CtgLevelId=RC.CtgLevelId
			AND SI.SalInvDate BETWEEN @FromDate AND @ToDate AND P.CmpId=C.CmpId AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId
			AND SI.SMId=S.SMId AND SI.RMId=RM.RMId AND RVC.CtgMainId=RC.CtgMainId
			AND RC.CtgLevelId=RCL.CtgLevelId AND RVCM.RtrValueClassId=RVC.RtrClassId
			AND RVCM.RtrId=SI.RtrId AND PCV.PrdCtgValMainId=P.PrdCtgValMainId AND SI.DlvSts NOT IN (1,3) --Added by Thiru on 30.09.2009 for Bug No:20729
			
			AND (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR
			P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
			SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
			SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
			AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
			SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND (RCV.CtgLevelId = (CASE @RtrCtgLvl WHEN 0 THEN RCV.CtgLevelId ELSE 0 END) OR
			RCV.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
			AND (RC.CtgMainId = (CASE @RtrCtgLvlVal WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
			RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
			AND (RVC.RtrClassId = (CASE @RtrValClass WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
			RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
			AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
					P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
			AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			GROUP BY P.PrdDCode,P.PrdName
		END
		ELSE IF @BasedOn=2		--Route
		BEGIN
			INSERT INTO #RptECAnalysis(Code,Name,Unit,SalesValue,EC,TLS)
			SELECT RM.RMCode as Code,RM.RMName AS Name,0 AS Unit,sum(SIP.PrdGrossAmount) AS SalesValue,count(DISTINCT SI.rtrid)AS EC,count(SI.rmid) AS TLS FROM Product P,ProductBatch PB,SalesInvoice SI,
			SalesInvoiceProduct SIP,Company C,Salesman S,RouteMaster RM,Retailer R,RetailerValueClass RVC,RetailerCategory RC,
			RetailerCategorylevel RCL,RetailerValueClassMap RVCM,ProductCategoryValue PCV,RetailerCategorylevel RCV,ProductCategoryLevel PCL
			WHERE SIP.PrdId=P.PrdId AND SIP.PrdBatId=PB.PrdBatId AND PB.PrdId=P.PrdId
			AND SIP.SalId=SI.SalId AND SI.RtrId=R.RtrId AND RCV.CtgLevelId=RC.CtgLevelId
			AND SI.SalInvDate BETWEEN @FromDate AND @ToDate AND P.CmpId=C.CmpId AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId
			AND SI.SMId=S.SMId AND SI.RMId=RM.RMId AND RVC.CtgMainId=RC.CtgMainId
			AND RC.CtgLevelId=RCL.CtgLevelId AND RVCM.RtrValueClassId=RVC.RtrClassId
			AND RVCM.RtrId=SI.RtrId AND PCV.PrdCtgValMainId=P.PrdCtgValMainId AND SI.DlvSts NOT IN (1,3)	--Added by Thiru on 30.09.2009 for Bug No:20729
			AND (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR
			P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
			SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
			SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
			AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
			SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND (RCV.CtgLevelId = (CASE @RtrCtgLvl WHEN 0 THEN RCV.CtgLevelId ELSE 0 END) OR
			RCV.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
			AND (RC.CtgMainId = (CASE @RtrCtgLvlVal WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
			RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
			AND (RVC.RtrClassId = (CASE @RtrValClass WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
			RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
			AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
					P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
			AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			GROUP BY RM.RMCode,RM.RMName
		END
		ELSE IF @BasedOn=3		--Retailer
		BEGIN
			INSERT INTO #RptECAnalysis(Code,Name,Unit,SalesValue,EC,TLS)
			SELECT
				R.RtrCode as Code,R.RtrName AS Name,0 AS Unit,sum(SIP.PrdGrossAmount) AS SalesValue,
				count(DISTINCT SI.SalId) AS EC,count(SI.RtrId) AS TLS
			FROM
				Product P (Nolock) ,ProductBatch PB (Nolock),SalesInvoice SI (Nolock),
				SalesInvoiceProduct SIP (Nolock),Company C (Nolock),Salesman S (Nolock),
				Retailer R (Nolock),RetailerValueClass RVC (Nolock),RouteMaster RM (Nolock),
				RetailerCategory RC,RetailerCategorylevel RCL,RetailerValueClassMap RVCM,
				ProductCategoryValue PCV (Nolock),RetailerCategorylevel RCV (Nolock),
				ProductCategoryLevel PCL (Nolock)
			WHERE
				SIP.PrdId=P.PrdId AND SIP.PrdBatId=PB.PrdBatId
				AND PB.PrdId=P.PrdId
				AND SIP.SalId=SI.SalId AND SI.RtrId=R.RtrId AND RCV.CtgLevelId=RC.CtgLevelId
				AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
				AND P.CmpId=C.CmpId AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId
				AND SI.SMId=S.SMId AND SI.RMId=RM.RMId AND RVC.CtgMainId=RC.CtgMainId
				AND RC.CtgLevelId=RCL.CtgLevelId AND RVCM.RtrValueClassId=RVC.RtrClassId
				AND RVCM.RtrId=SI.RtrId AND PCV.PrdCtgValMainId=P.PrdCtgValMainId
				AND SI.DlvSts NOT IN (1,3)	--Added by Thiru on 30.09.2009 for Bug No:20729
				AND (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR
						P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
						SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
						SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
						SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				AND (RCV.CtgLevelId = (CASE @RtrCtgLvl WHEN 0 THEN RCV.CtgLevelId ELSE 0 END) OR
						RCV.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				AND (RC.CtgMainId = (CASE @RtrCtgLvlVal WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
						RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
				AND (RVC.RtrClassId = (CASE @RtrValClass WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
						RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))			
				AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
							P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			GROUP BY
				R.RtrCode,R.RtrName,SI.RtrId
		END
		
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptECAnalysis ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ 'AND 	CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
				+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '
				+ 'AND SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '
				+ 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'
				+ 'AND RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '
				+ 'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '
				+ 'AND RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '
				+ 'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '
				+ 'AND CtgLevelId = (CASE ' + CAST(@RtrCtgLvl AS nVarchar(10)) + ' WHEN 0 THEN CtgLevelId ELSE 0 END) OR '
				+ 'CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',29,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '
				+ 'AND CtgMainId = (CASE ' + CAST(@RtrCtgLvlVal AS nVarchar(10)) + ' WHEN 0 THEN CtgMainId ELSE 0 END) OR '
				+ 'CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',30,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '
				+ 'AND RtrClassId = (CASE ' + CAST(@RtrValClass AS nVarchar(10)) + ' WHEN 0 THEN RtrClassId Else 0 END) OR '
				+ 'RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',31,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'+
				+ 'AND P.PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN P.PrdId Else 0 END) OR '
				+ 'P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'
				+ 'AND P.PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN P.PrdId Else 0 END) OR '
				+ 'P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'
				+' Salinvdate BETWEEN ''' + Convert(Varchar(10),@FromDate,121) + ''' AND ''' + Convert(Varchar(10),@ToDate,121) + ''''
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptECAnalysis'
			
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
			SET @SSQL = 'INSERT INTO #RptECAnalysis ' +
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
			RETURN
		END
	END
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptECAnalysis
	SELECT Code,Name,Unit,SalesValue,EC,TLS	FROM #RptECAnalysis ORDER BY Code
	DECLARE @ExcelFlag INT
	SELECT @ExcelFlag = Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @ExcelFlag = 1
	BEGIN
		DELETE  FROM RptECAnalysisExcel
		INSERT  INTO RptECAnalysisExcel
		SELECT Code,Name,Unit,SalesValue,EC,TLS	FROM #RptECAnalysis ORDER BY Code
	END
	RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-227-017

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptItemWise]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptItemWise]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptItemWise 2,1

CREATE Procedure [dbo].[Proc_RptItemWise]
(
	@Pi_RptId 		INT,
	@Pi_UsrId 		INT
)
/************************************************************
* CREATED BY	: Gunasekaran
* CREATED DATE	: 18/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
BEGIN
	DECLARE @FromDate AS DATETIME  
	DECLARE @ToDate   AS DATETIME  
	EXEC Proc_ProductWiseSalesOnly @Pi_RptId,@Pi_UsrId
	DELETE FROM RtrLoadSheetItemWise WHERE RptId= @Pi_RptId And UsrId IN(0,@Pi_UsrId)
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
	INSERT INTO RtrLoadSheetItemWise(SalId,SalInvNo,SalInvDate,DlvRMId,VehicleId,AllotmentNumber,
				SMId,RtrId,RtrName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,MRP,
				BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,RptId,UsrId)
		SELECT SalId,SalInvNo,SalInvDate,DlvRMId,VehicleId, allotmentid,
				SMId,RtrId,RtrName,
				PrdId,PrdDCode,PrdName,
				PrdBatId,PrdBatCode,MRP,
				SUM(SalesQty) BillQty,
				SUM(FreeQty) FreeQty,SUM(ReturnQty) ReturnQty,SUM(RepQty) ReplacementQty,
				--SUM(SalesQty) + SUM(FreeQty) + SUM(ReturnQty) + SUM(RepQty) TotalQty,SUM(NetAmount) AS NetAmount,
				SUM(SalesQty) + SUM(FreeQty) + SUM(RepQty) TotalQty,SUM(NetAmount) AS NetAmount,
				@Pi_RptId RPtId,@Pi_UsrId USrId
		FROM (
		SELECT X.* ,V.AllotmentId FROM
		(
			SELECT P.SalId,SI.SalInvNo,P.SalInvDate,SI.DlvRMId,SI.VehicleId,
			P.SMId,P.RtrId,R.RtrName,
			P.PrdId,P.PrdDCode,P.PrdName,P.PrdBatId,P.PrdBatCode,P.PrdUnitMRP AS MRP,
			P.SalesQty,P.FreeQty,P.ReturnQty,P.RepQty,P.NetAmount
			FROM SalesInvoice SI
			LEFT OUTER JOIN RptProductWise P ON SI.SalId  = P.SalId
			LEFT OUTER JOIN Retailer R ON SI.RtrId = R.RtrId
			WHERE SI.DlvSts = 2 AND P.RptId = @Pi_RptId AND P.UsrId = @Pi_UsrId 
			AND SI.SalInvDate BETWEEN  @FromDate AND @ToDate
			) X
			LEFT OUTER JOIN
			(
				SELECT VM.AllotmentId,VM.AllotmentNumber,VM.VehicleId,SaleInvNo FROM VehicleAllocationMaster VM,
				VehicleAllocationDetails VD	WHERE VM.AllotmentNumber = VD.AllotmentNumber
			) V  ON X.VehicleId  = V.VehicleId and X.SalInvNo = V.SaleInvNo
		 ) F
		GROUP BY SalId,SalInvNo,SalInvDate,DlvRMId,VehicleId, AllotmentId,
		SMId,RtrId,RtrName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,MRP
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-227-018

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptRtrWiseBrandWiseSales]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptRtrWiseBrandWiseSales]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

----  EXEC Proc_RptRtrWiseBrandWiseSales 169,2,0,'dabur1',0,0,1

CREATE PROCEDURE [dbo].[Proc_RptRtrWiseBrandWiseSales]
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
/**********************************************************************************************
* PROCEDURE  : Proc_RptRtrWiseBrandWiseSales
* PURPOSE    : To Generate Retailer Wise Brand Wise Report
* CREATED BY : Aarthi
* CREATED ON : 16/09/2009
* MODIFICATION
************************************************************************************************
* 03.11.2009		Panneer		ExportExcel Value Mismatch
* 21.11.2009		Panneer		Gross Value MisMatch Issue
***********************************************************************************************/
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
DECLARE @FromDate	AS	DATETIME
DECLARE @ToDate	 	AS	DATETIME
DECLARE @CmpId      AS  INT
DECLARE @SMId 		AS	INT
DECLARE @RMId	 	AS	INT
DECLARE @RtrId	 	AS	INT
DECLARE @CtgLevelId	AS 	INT
DECLARE @RtrClassId	AS 	INT
DECLARE @CtgMainId 	AS 	INT
DECLARE @PDC	AS	INT
DECLARE @PrdCatId	AS	INT
DECLARE @PrdId		AS	INT
DECLARE @HirMainId	AS INT
DECLARE @CtgValue   AS INT
DECLARE	@EXLFlag	AS	INT
--Till Here
--Assgin Value for the Filter Variable
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
SET @HirMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
SET @CtgValue=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
--Till Here
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
--Till Here'
EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
EXEC Proc_GetProductwiseHierarchy
	SET @PrdCatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
CREATE TABLE #RptRtrWiseBrandWiseSales
		(
	    [Salesman Name]				NVARCHAR(100),
		[Route Name]				NVARCHAR(100),
		[Retailer Category]			NVARCHAR(100),
		[Retailer Classification]	NVARCHAR(100),
		[Retailer Code]       NVARCHAR(50),
		[Retailer Name]       NVARCHAR(100),
		[RtrId]				  INT,
		[Product Hierarchy]	  NUMERIC(18, 2),
		[Hierarchy]			  NVARCHAR(100)
)
SET @TblName = 'RptRtrWiseBrandWiseSales'
SET @TblStruct = '
		[Salesman Name]				NVARCHAR(100),
		[Route Name]				NVARCHAR(100),
		[Retailer Category]			NVARCHAR(100),
		[Retailer Classification]	NVARCHAR(100),
		[Retailer Code]       NVARCHAR(50),
		[Retailer Name]       NVARCHAR(100),
		[RtrId]				  INT,
		[Product Hierarchy]	  [numeric](18, 2),
		[Hierarchy]			  NVARCHAR(100)'
SET @TblFields = '[Salesman Name],[Route Name],
					[Retailer Category],[Retailer Classification],[Retailer Code],[Retailer Name],
					[RtrId],[Product Hierarchy],[Hierarchy]'
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
		SELECT DISTINCT Prdid, C.PrdCtgValName INTO #Tempa 
		FROM 
			ProductCategoryValue C 
			INNER JOIN ProductCategoryValue D ON
			C.PrdCtgValMainId = (CASE @HirMainId WHEN 0 THEN C.PrdCtgValMainId Else 0 END) OR
			C.PrdCtgValMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId)) AND
			D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode as nvarchar(1000)) + '%'
			INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
			LEFT OUTER JOIN ProductCategoryLevel PCL ON PCL.CmpPrdCtgId=C.CmpPrdCtgId 
		where  PCL.CmpPrdCtgId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
				INSERT INTO #RptRtrWiseBrandWiseSales([Salesman Name],[Route Name],
					[Retailer Category],[Retailer Classification],[Retailer Code],[Retailer Name],
					[RtrId],[Product Hierarchy],[Hierarchy])
				SELECT DISTINCT 				
					S.SMName AS [Salesman Name],RM.RMName AS [Route Name],
					RC.CtgName AS [Retailer Category],RVC.ValueClassName AS [Retailer Classification],
					R.RtrCode AS [Retailer Code],R.RtrName AS[Retailer Name],
					SI.[RtrId],0 AS [Product Hierarchy] ,A.PrdCtgValName AS [Hierarchy]
					FROM #Tempa A
						LEFT OUTER JOIN SalesInvoiceProduct SIP ON SIP.PrdId=A.PrdId
						LEFT OUTER JOIN SalesInvoice SI ON SI.SalId=SIP.SalId
						LEFT OUTER JOIN Salesman S ON S.SMId= SI.SMId
						LEFT OUTER JOIN RouteMaster RM ON RM.RMId=SI.RMId
						LEFT OUTER JOIN Retailer R ON R.RtrId=SI.RtrId
						LEFT OUTER JOIN RetailerValueClassMap RVCM WITH (NOLOCK)ON R.Rtrid = RVCM.RtrId 
						LEFT OUTER JOIN RetailerValueClass RVC WITH (NOLOCK) ON RVCM.RtrValueClassId = RVC.RtrClassId
						AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
						RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
							AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
						RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
						INNER JOIN RetailerCategory RC WITH (NOLOCK) ON RVC.CtgMainId=RC.CtgMainId
							AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
						RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
						INNER JOIN RetailerCategoryLevel RCL ON RCL.CtgLevelId=RC.CtgLevelId
						AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
						RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
					WHERE (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
									SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						 AND (SI.RMId=(CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
									SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
									
						 AND (SI.SMId=(CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
									SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				
						 AND (SI.SalInvDate Between @FromDate and @ToDate) AND SI.DlvSts IN(4,5)
	IF LEN(@PurDBName) > 0
	BEGIN
		EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
		SET @SSQL = 'INSERT INTO #RptRtrWiseBrandWiseSales ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +
			
			'WHERE (SI.RtrId = (CASE ' +  CAST(@RtrId AS INTEGER) + ' WHEN 0 THEN SI.RtrId ELSE 0 END) OR
					SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',3,' + CAST(@Pi_UsrId as INTEGER) +')))
								
			AND (SI.RMId=(CASE ' + CAST(@RMId AS INTEGER) + ' WHEN 0 THEN SI.RMId ELSE 0 END) OR
								SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',2,' + CAST(@Pi_UsrId as INTEGER) +')))
								
			AND (SI.SMId=(CASE '+ CAST(@SMId AS INTEGER) + 'WHEN 0 THEN SI.SMId ELSE 0 END) OR
								SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',1,' + CAST(@Pi_UsrId as INTEGER) + ')))
			AND (SI.SalInvDate Between ' + @FromDate +' and ' + @ToDate +') and SI.DlvSts IN(4,5)'
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptRtrWiseBrandWiseSales'
	
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
			SET @SSQL = 'INSERT INTO #RptRtrWiseBrandWiseSales ' +
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
SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptRtrWiseBrandWiseSales
-- Till Here
	SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
		
		/***************************************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @Salesman  NVARCHAR(100)
		DECLARE  @Route		NVARCHAR(100)
		DECLARE	 @RtrCat	NVARCHAR(100)
		DECLARE	 @RtrClass	NVARCHAR(100)
		DECLARE  @RetailerId BIGINT
		DECLARE  @RtrCode NVARCHAR(100)
		DECLARE  @RtrName NVARCHAR(100)
		DECLARE	 @Hierarchy NVARCHAR(100)
		DECLARE  @PrdHir	NUMERIC(18, 2)
		DECLARE  @SlNo INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @Name NVARCHAR(100)
		
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptRtrWiseBrandWiseSales_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptRtrWiseBrandWiseSales_Excel]
		DELETE FROM RptExcelHeaders Where RptId=169 AND SlNo>7
		CREATE TABLE RptRtrWiseBrandWiseSales_Excel ([Salesman Name]NVARCHAR(100),[Route Name]NVARCHAR(100) ,[Retailer Category] NVARCHAR(100),[Retailer Classification] NVARCHAR(100),[Retailer Code] NVARCHAR(50),[Retailer Name]NVARCHAR(100),RtrId INT)
		SET @iCnt=8
		DECLARE Column_Cur CURSOR FOR
		SELECT DISTINCT Hierarchy--,SUM([Product Hierarchy])
					FROM #RptRtrWiseBrandWiseSales-- Group BY Hierarchy
		OPEN Column_Cur
			   FETCH NEXT FROM Column_Cur INTO @Column--,@SlNo
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptRtrWiseBrandWiseSales_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					
					PRINT @C_SSQL
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
					FETCH NEXT FROM Column_Cur INTO @Column--,@SlNo
				END
		CLOSE Column_Cur
		DEALLOCATE Column_Cur
		--- Added By Panneer 03.11.2009
		--Insert table values
		DECLARE @PrdCtgValue1 nvarchar(100)
		DECLARE @CtgValueName1 nVarchar(100)
		SELECT @CtgValueName1=CmpPrdCtgName FROM ProductCategoryLevel WHERE CmpPrdCtgId=@CtgValue
		SET @sSql='
		UPDATE #RptRtrWiseBrandWiseSales SET [Product Hierarchy]= 0
		FROM (SELECT DISTINCT SI.RtrId,SIP.PrdGrossAmountAftEdit AS ProductHierarchy,PCV.PrdCtgValName 
		FROM SalesInvoiceProduct SIP,ProductWiseHierarchy P,SalesInvoice SI,ProductCategoryValue PCV,
		ProductCategoryLevel PCL,Retailer R
		WHERE SI.Salid=SIP.salid AND SIP.Prdid=P.ProductId AND (SI.SalInvDate Between ''' + cast(@FromDate AS nVarchar(11)) +''' and ''' + cast(@ToDate AS nVarchar(11)) +''') AND SI.DlvSts IN(4,5)
		AND PCV.PrdCtgValName=P.['+ @CtgValueName1 +'] AND SI.RtrId=R.RtrId) A 
		WHERE A.RtrId=#RptRtrWiseBrandWiseSales.RtrId AND A.PrdCtgValName=#RptRtrWiseBrandWiseSales.Hierarchy'
		Exec (@sSql)
		SET @sSql='
		SELECT DISTINCT SI.SalId,SI.SmId,SMName,RMName,SI.RmId,SI.RtrId,SIP.PrdId,
		SIP.PrdGrossAmountAftEdit GrossAmt ,PCV.PrdCtgValName  INTO #Temp5425
		FROM SalesInvoiceProduct SIP,ProductWiseHierarchy P,SalesInvoice SI,ProductCategoryValue PCV,
		ProductCategoryLevel PCL,Retailer R,Product Pr,SalesMan S,RouteMaster RM
		WHERE SI.Salid=SIP.salid AND SIP.Prdid=P.ProductId AND (SI.SalInvDate Between ''' + cast(@FromDate AS nVarchar(11)) +''' and ''' + cast(@ToDate AS nVarchar(11)) +''') AND SI.DlvSts IN(4,5)
		AND PCV.PrdCtgValName=P.['+ @CtgValueName1 +'] AND SI.RtrId=R.RtrId AND SIP.PrdId = Pr.PrdId
		AND S.SmId = SI.SmId and SI.RMId = RM.RMId
		SELECT SmId,SMName,RMId,RMName,RtrId,PrdCtgValName,Sum(GrossAmt) GrossAmt INTO #TFIN
		FROM #Temp5425
		GROUP BY RtrId,PrdCtgValName,SmId,RMId,SMName,RMName
		UPDATE #RptRtrWiseBrandWiseSales  SET [Product Hierarchy] = GrossAmt
		FROM #RptRtrWiseBrandWiseSales a,#TFIN b 
		WHERE A.RtrId = B.RtrId AND A.Hierarchy = B.PrdCtgValName and SMName = [Salesman Name]
		AND RMName = [Route Name]'
		Exec (@sSql)
		---- Till Here
		DELETE FROM RptRtrWiseBrandWiseSales_Excel
		INSERT INTO RptRtrWiseBrandWiseSales_Excel([Salesman Name],[Route Name],[Retailer Category],[Retailer Classification],[Retailer Code],[Retailer Name],RtrId)
		SELECT DISTINCT [Salesman Name],[Route Name],[Retailer Category],[Retailer Classification],[Retailer Code],[Retailer Name],RtrId
				FROM #RptRtrWiseBrandWiseSales
		DECLARE Values_Cur CURSOR FOR
		SELECT  [Salesman Name],[Route Name],[Retailer Category],[Retailer Classification],[Retailer Code],[Retailer Name],RtrId,[Hierarchy],SUM([Product Hierarchy]) FROM #RptRtrWiseBrandWiseSales
				group by [Salesman Name],[Route Name],[Retailer Category],[Retailer Classification],[Retailer Code],[Retailer Name],RtrId,[Hierarchy]
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @Salesman,@Route,@RtrCat,@RtrClass,@RtrCode,@RtrName,@RetailerId,@Hierarchy,@PrdHir
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptRtrWiseBrandWiseSales_Excel  SET ['+ @Hierarchy +']= '+ CAST(@PrdHir AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL+ ' WHERE RtrId=' + CAST(@RetailerId AS VARCHAR(1000))
					+' AND [Retailer Code]=''' + CAST(@RtrCode AS VARCHAR(1000))+''''
					+' AND [Retailer Category]=''' + CAST(@RtrCat AS VARCHAR(1000)) +''''
					+' AND [Salesman Name]=''' + CAST(@Salesman AS VARCHAR(1000)) +''''
					+' AND [Route Name]=''' + CAST(@Route AS VARCHAR(1000)) +''''
					+' AND [Retailer Classification]=''' + CAST(@RtrClass AS VARCHAR(1000)) +''''
					
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @Salesman,@Route,@RtrCat,@RtrClass,@RtrCode,@RtrName,@RetailerId,@Hierarchy,@PrdHir
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptRtrWiseBrandWiseSales_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptRtrWiseBrandWiseSales_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/***************************************************************************************************************************/
	END
	DECLARE @PrdCtgValue nvarchar(100)
	DECLARE @CtgValueName nVarchar(100)
--DECLARE @sSql nvarchar(4000)
	SELECT @CtgValueName=CmpPrdCtgName FROM ProductCategoryLevel WHERE CmpPrdCtgId=@CtgValue
		SET @sSql='UPDATE #RptRtrWiseBrandWiseSales SET [Product Hierarchy]= 0
		FROM (SELECT DISTINCT SI.RtrId,SIP.PrdGrossAmountAftEdit AS ProductHierarchy,PCV.PrdCtgValName 
		FROM SalesInvoiceProduct SIP,ProductWiseHierarchy P,SalesInvoice SI,ProductCategoryValue PCV,
		ProductCategoryLevel PCL,Retailer R
		WHERE SI.Salid=SIP.salid AND SIP.Prdid=P.ProductId AND (SI.SalInvDate Between ''' + cast(@FromDate AS nVarchar(11)) +''' and ''' + cast(@ToDate AS nVarchar(11)) +''') AND SI.DlvSts IN(4,5)
		AND PCV.PrdCtgValName=P.['+ @CtgValueName +'] AND SI.RtrId=R.RtrId) A 
		WHERE A.RtrId=#RptRtrWiseBrandWiseSales.RtrId AND A.PrdCtgValName=#RptRtrWiseBrandWiseSales.Hierarchy'
		Exec (@sSql)
		SET @sSql='
		SELECT DISTINCT SI.SalId,SI.SmId,SMName,RMName,SI.RmId,SI.RtrId,SIP.PrdId,
		SIP.PrdGrossAmountAftEdit GrossAmt ,PCV.PrdCtgValName  INTO #Temp5425
		FROM SalesInvoiceProduct SIP,ProductWiseHierarchy P,SalesInvoice SI,ProductCategoryValue PCV,
		ProductCategoryLevel PCL,Retailer R,Product Pr,SalesMan S,RouteMaster RM
		WHERE SI.Salid=SIP.salid AND SIP.Prdid=P.ProductId AND (SI.SalInvDate Between ''' + cast(@FromDate AS nVarchar(11)) +''' and ''' + cast(@ToDate AS nVarchar(11)) +''') AND SI.DlvSts IN(4,5)
		AND PCV.PrdCtgValName=P.['+ @CtgValueName +'] AND SI.RtrId=R.RtrId AND SIP.PrdId = Pr.PrdId
		AND S.SmId = SI.SmId and SI.RMId = RM.RMId
		SELECT SmId,SMName,RMId,RMName,RtrId,PrdCtgValName,Sum(GrossAmt) GrossAmt INTO #TFIN
		FROM #Temp5425
		GROUP BY RtrId,PrdCtgValName,SmId,RMId,SMName,RMName
		UPDATE #RptRtrWiseBrandWiseSales  SET [Product Hierarchy] = GrossAmt
		FROM #RptRtrWiseBrandWiseSales a,#TFIN b 
		WHERE A.RtrId = B.RtrId AND A.Hierarchy = B.PrdCtgValName and SMName = [Salesman Name]
		AND RMName = [Route Name]'
		Exec (@sSql)
	SELECT *  FROM #RptRtrWiseBrandWiseSales ORDER BY [Salesman Name],[Route Name],[Retailer Name]

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSalesBillWise_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE RptSalesBillWise_Excel
GO
CREATE TABLE RptSalesBillWise_Excel
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
		[DlvStatus]	      INT
		)
GO
--SRF-Nanda-227-019
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptSalesBillWise]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptSalesBillWise]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
---EXEC Proc_RptSalesBillWise 1,2,0,'Henkel',0,0,1

CREATE PROCEDURE [dbo].[Proc_RptSalesBillWise]
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
/****************************************************************************
* PROCEDURE  : Proc_RptSalesBillWise
* PURPOSE    : To Generate Sales Bill Wise
* CREATED BY : Boopathy.P
* CREATED ON : 30/07/2007
* MODIFICATION
*****************************************************************************
* DATE       	AUTHOR      DESCRIPTION
07/12/2007 	MURUGAN.R	Adding Retailer Category
*****************************************************************************/
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
DECLARE @FromDate	AS	DATETIME
DECLARE @ToDate	 	AS	DATETIME
DECLARE @FromBillNo AS  BIGINT
DECLARE @TOBillNo   AS  BIGINT
DECLARE @CmpId      AS  INT
DECLARE @LcnId      AS  INT
DECLARE @SMId 		AS	INT
DECLARE @RMId	 	AS	INT
DECLARE @RtrId	 	AS	INT
DECLARE @BillType   	AS	INT
DECLARE @BillMode   	AS	INT
DECLARE @CtgLevelId	AS 	INT
DECLARE @RtrClassId	AS 	INT
DECLARE @CtgMainId 	AS 	INT
DECLARE @BillStatus	AS	INT
DECLARE @CancelValue	AS	INT
--Till Here
--Assgin Value for the Filter Variable
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @LcnId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
SET @FromBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
SET @TOBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
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
CREATE TABLE #RptSalesBillWise
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
		[DlvStatus]	      INT
)
SET @TblName = 'RptSalesBillWise'
SET @TblStruct = '	    [Bill Number]         NVARCHAR(50),
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
		[DlvStatus]	      INT'
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
IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
   BEGIN
	
	PRINT @CtgLevelId	
	IF @FromBillNo <> 0 AND @TOBillNo <> 0
	BEGIN
         PRINT 'A'
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
		
			INSERT INTO #RptSalesBillWise([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],
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
--			AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
--			RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
--			AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
--			RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
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
			AND (DlvSts=(CASE @BillStatus WHEN 0 THEN DlvSts ELSE @BillStatus END)) 
		
				 AND ([Bill Date] Between @FromDate and @ToDate)
		
				 AND (SalId Between @FromBillNo and @TOBillNo)
		END
        ELSE
        BEGIN 
			INSERT INTO #RptSalesBillWise([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],
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
			AND (DlvSts=(CASE @BillStatus WHEN 0 THEN DlvSts ELSE @BillStatus END)) 
		
				 AND ([Bill Date] Between @FromDate and @ToDate)
		
				 AND (SalId Between @FromBillNo and @TOBillNo)
		END 
	END
	ELSE
	BEGIN
		PRINT 'B'
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
		
			INSERT INTO #RptSalesBillWise([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],
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
--			AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
--			RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
--			AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
--			RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
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
				 AND ([DlvSts]=(CASE @BillStatus WHEN 0 THEN [DlvSts] ELSE 0 END) OR
							[DlvSts] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,192,@Pi_UsrId)))
		
				 AND ([Bill Date] Between @FromDate and @ToDate)
		END 
		ELSE
		BEGIN 
			INSERT INTO #RptSalesBillWise([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],
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
		
		SET @SSQL = 'INSERT INTO #RptSalesBillWise ' +
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSalesBillWise'
	
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
		SET @SSQL = 'INSERT INTO #RptSalesBillWise ' +
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
SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSalesBillWise
-- Till Here
	IF (@BillStatus=3 AND  @CancelValue=1) OR (@BillStatus=0 AND  @CancelValue=1)
	BEGIN
		UPDATE #RptSalesBillWise SET [Gross Amount]=0,[Scheme Disc]=0,[Sales Return]=0,[Replacement]=0,[Discount]=0,
				[Tax Amount]=0,[Credit Adjustmant]=0,[Debit Adjustment]=0,[Net Amount]=0
				WHERE [DlvStatus]=3
	END
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID = @Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSalesBillWise_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptSalesBillWise_Excel
		
		CREATE TABLE RptSalesBillWise_Excel
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
		[DlvStatus]	      INT
		)
		
		INSERT INTO RptSalesBillWise_Excel ([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],
		[Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],
		[Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus])
			SELECT  [Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],
				[Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],
				[Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus] FROM #RptSalesBillWise
		UPDATE RPT SET RPT.[Retailer Code]=R.RtrCode FROM RptSalesBillWise_Excel RPT,Retailer R,SalesINvoice SI WHERE RPT.[Retailer Name]=R.RtrName
		AND SI.SalInvNo=RPT.[Bill NUmber] AND R.RtrId=SI.RtrId
       UPDATE RPT SET RPT.[WindowDisplayAmount]=R.[WindowDisplayAmount] FROM RptSalesBillWise_Excel RPT,SalesInvoice R WHERE RPT.[Bill Number]=R.SalInvNo
	END 
    DELETE FROM #RptSalesBillWise WHERE [Gross Amount]=0 AND [Scheme Disc]=0 AND [Sales Return]=0 AND [Replacement]=0 AND [Discount]=0 AND 
				[Tax Amount]=0 AND [Credit Adjustmant]=0 AND [Debit Adjustment]=0 AND [Net Amount]=0
	SELECT * FROM #RptSalesBillWise

	RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-227-020

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
CREATE PROCEDURE [dbo].[Proc_RptStoreSchemeDetails]
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
		@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,
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
		@Pi_UsrId,'' AS SMName,'' AS RMName,'' AS DlvRMName,'' AS CtgLevelName,'' AS CtgName,'' AS ValueClassName,'' AS RtrName,'' AS VehicleRegNo,
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
	SELECT DISTINCT L.SchId,L.SlabId,A.SalInvNo,A.SMId,A.RMId,A.DlvRMId,RCL.CtgLevelId,RC.CtgMainId,RVCM.RtrValueClassId,A.RtrId,A.DlvSts,ISNULL(A.VehicleId,0) AS VehicleId,
		ISNULL(A.DlvBoyId,0) AS DlvBoyId,L.FreePrdId AS PrdId,L.FreePrdBatId AS PrdBatId,0 As FlatAmount,0 as DiscountPer,
		0 AS Points,L.FreePrdId As FreePrdId,L.FreePrdBatId AS FreePrdBatId,L.FreeQty as FreeQty,
		(L.FreeQty * O.PrdBatDetailValue) as FreeValue,0 as GiftPrdId,0 As GiftPrdBatId,
		0 as GiftQty,0 as GiftValue,Budget as SchemeBudget,dbo.Fn_ReturnBudgetUtilized(L.SchId),1 as Selected,
		@Pi_UsrId,K.SMName,D.RMName,E.RMName as DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,F.RtrName,ISNULL(G.VehicleRegNo,'') AS VehicleRegNo,
		ISNULL(H.DlvBoyName,'') AS DlvBoyName,
		I.PrdName,'' AS PrdBatCode,M.PrdName as FreePrdName,N.PrdBatCode as FreeBatchName,
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
		@Pi_UsrId,S.SMName,RM.RMName,'' AS DlvRMName,RCL.CtgLevelName,RC.CtgName,RVC.ValueClassName,R.RtrName,'' AS VehicleRegNo,
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









--SRF-Nanda-227-021

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptTempDistributionWidth]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptTempDistributionWidth]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptTempDistributionWidth '2007/01/02','2008/11/02',1
--SELECT * FROM RptTempDistWidth

CREATE PROCEDURE [dbo].[Proc_RptTempDistributionWidth]
(
	@Pi_FromDate	 	DATETIME,
	@Pi_ToDate	 	DATETIME,	
	@Pi_UserId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptTempDistributionWidth
* PURPOSE	: To get the distribution
* CREATED	: Nandakumar R.G
* CREATED DATE	: 14/12/2007
* MODIFIED	:
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DELETE FROM RptTempDistWidth
	INSERT INTO RptTempDistWidth(CmpId,SMId,RMId,CtgLevelId,CtgMainId,RtrClassId,RtrId,PrdCtgValMainId,
	CmpPrdCtgId,PrdId,SalQty,UserId)
	SELECT P.CmpId,SI.SMId,SI.RMId,RC.CtgLevelId,RC.CtgMainId,RVM.RtrValueClassId,SI.RtrId,P.PrdCtgValMainId,
	PC.CmpPrdCtgId,P.PrdId,SUM(SIP.BaseQty) AS SalesQty,@Pi_UserId	
	FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceProduct SIP WITH (NOLOCK),
	Product P WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),
	ProductCategoryValue PC WITH (NOLOCK),RetailerValueClassMap RVM WITH (NOLOCK),
	RetailerValueClass RVC WITH (NOLOCK),RetailerCategory RC WITH (NOLOCK)
	WHERE SIP.SalId=SI.SalId AND P.PrdId=SIP.PrdId	AND PB.PrdId=P.PrdId
	AND PB.PrdBatId=SIP.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
	AND RVM.RtrId=SI.RtrId AND RVC.CmpId=P.CmpId AND RVC.RtrClassId=RVM.RtrValueClassId
	AND RVC.CtgMainId=RC.CtgMainId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
	AND SI.DlvSts IN (4,5) AND  SI.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	GROUP BY P.CmpId,SI.SMId,SI.RMId,RC.CtgLevelId,RC.CtgMainId,RVM.RtrValueClassId,SI.RtrId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
	PC.CmpPrdCtgId,P.PrdId	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-227-022

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_SalesReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_SalesReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC [Proc_SalesReport] 1
--Select * from RptSalesReportSubTab

CREATE PROCEDURE [dbo].[Proc_SalesReport]
(
	@Pi_TypeId INT
)
/**********************************************************************************
* PROCEDURE		: Proc_SalesReport
* PURPOSE		: To Display the Bill Details and Collection details
* CREATED		: Aarthi
* CREATED DATE	: 11/09/2009
* NOTE			: General SP for Bill Details and Collection details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
************************************************************************************/
AS
BEGIN
	if exists (select * from dbo.[RptSalesReportSubTab])
	BEGIN
		DELETE FROM [dbo].[RptSalesReportSubTab]
	END
		INSERT INTO RptSalesReportSubTab (SalId, [Bill Number], [Bill Date],
					[Retailer Code], [Retailer Name],RtrId,SMId,RMId,
					[Gross Amount] ,[Market Return] ,[Replacement],[Sch Discount],[Discount],[Tax Amount],[Net Amount],[Bill Adjustments],[CollCashAmt],[CollCheque],
					[CollCredit],[CollDebit],[CollOnAcc],[CollDisc],[CollDate],[InvRcpMode],[Adjustment])
		SELECT DISTINCT SalId, [Bill Number], [Bill Date],
				[Retailer Code], [Retailer Name],RtrId,SMId,RMId,
				[Gross Amount] ,[Market Return] ,[Replacement],[Sch Discount],[Discount],[Tax Amount],[Net Amount],[Bill Adjustments],
				   [CollCashAmt],  [CollCheque],   CollCredit,  CollDebit,   CollOnAcc, CollDisc,[CollDate],[InvRcpMode],SUM([CollDebit])-SUM([CollCredit])-SUM([CollOnAcc])-SUM([CollDisc])AS[Adjustment]
		FROM
		(
				SELECT DISTINCT SI.SalId,SI.SalInvNo as [Bill Number],SI.SalInvDate as [Bill Date],
						R.RtrCode AS [Retailer Code],R.RtrName as [Retailer Name],R.RtrId,SM.SMId,RM.RMId,
						(SI.SalGrossAmount) AS  [Gross Amount],SUM(DISTINCT SI.SalSchDiscAmount) as  [Sch Discount]
						,(SI.MarketRetAmount) as [Market Return],(SI.ReplacementDiffAmount) as [Replacement],
						((SI.SalCDAmount)+(SI.SalDBDiscAmount)+(SI.SalSplDiscAmount)) as [Discount],
						(SI.SalTaxAmount)  as [Tax Amount],(SI.DBAdjAmount)-(CRAdjAmount)-(OnAccountAmount)-(WindowDisplayAmount)-(MarketRetAmount)+(ReplacementDiffAmount)+(OtherCharges) AS [Bill Adjustments],
						(SI.SalNetAmt) AS [Net Amount],SI.DlvSts,
						 ISNULL(SUM(RI.SalInvAmt),0)  AS CollCashAmt,0 AS CollCheque,
						 0 AS CollCredit,0 AS CollDebit, 0 AS CollOnAcc, 0 AS CollDisc,'' AS CollDate,ISNULL(RI.[InvRcpMode],0) AS [InvRcpMode]
						FROM Retailer R WITH (NOLOCK),
						Salesman SM WITH (NOLOCK),RouteMaster RM WITH (NOLOCK),SalesInvoice SI WITH (NOLOCK)
						Inner JOIN BillSeriesConfig BS  WITH (NOLOCK) on (SI.BillType=BS.SeriesValue and BS.SeriesMasterId=2)
						INNER JOIN BillSeriesConfig BSF  WITH (NOLOCK) on (SI.BillMode = BSF.SeriesValue  and BSF.SeriesMasterId=1)
						LEFT OUTER JOIN ReceiptInvoice RI WITH (NOLOCK) ON RI.SalId=SI.SalId AND RI.InvRcpMode=1 AND RI.CancelStatus=1 AND RI.InvInsSta NOT IN(4)
						WHERE SI.RtrId=R.RtrId AND SI.RMId=RM.RMId AND SI.SMId=SM.SMId AND SI.DlvSts IN (1,2,4,5)
						GROUP BY SI.SalId,SI.SalInvNo,SI.SalInvDate,R.RtrName,Si.BillType,SI.BillMode,
						R.RtrId,R.RtrCode,SM.SMId,RM.RMId,BS.SeriesDesc,BSF.SeriesDesc,SI.DlvSts,SI.ReplacementDiffAmount,SI.SalGrossAmount,SI.MarketRetAmount,
						SI.SalCDAmount,SI.SalDBDiscAmount,SI.SalSplDiscAmount,SI.SalTaxAmount,SI.DBAdjAmount,CRAdjAmount,OnAccountAmount,WindowDisplayAmount
						,MarketRetAmount,ReplacementDiffAmount,OtherCharges,RI.[InvRcpMode],SI.SalNetAmt
			UNION
				SELECT DISTINCT SI.SalId,SI.SalInvNo as [Bill Number],SI.SalInvDate as [Bill Date],
					R.RtrCode AS [Retailer Code],R.RtrName as [Retailer Name],R.RtrId,SM.SMId,RM.RMId,
					(SI.SalGrossAmount) AS  [Gross Amount],SUM(SI.SalSchDiscAmount) as  [Sch Discount]
					,(SI.MarketRetAmount) as [Market Return],(SI.ReplacementDiffAmount) as [Replacement],
					((SI.SalCDAmount)+(SI.SalDBDiscAmount)+(SI.SalSplDiscAmount)) as [Discount],
					(SI.SalTaxAmount)  as [Tax Amount],(SI.DBAdjAmount)-(CRAdjAmount)-(OnAccountAmount)-(WindowDisplayAmount)-(MarketRetAmount)+(ReplacementDiffAmount)+(OtherCharges) AS [Bill Adjustments],
					(SI.SalNetAmt) AS [Net Amount],SI.DlvSts,
					0  AS CollCashAmt,ISNULL(SUM(RI.SalInvAmt),0) AS CollCheque, 0 AS CollCredit,0 AS CollDebit, 0 AS CollOnAcc, 0 AS CollDisc, ISNULL(RI.InvInsDate,'') AS InvInsDate,ISNULL(RI.[InvRcpMode],0) AS [InvRcpMode]
					FROM Retailer R WITH (NOLOCK),
					Salesman SM WITH (NOLOCK),RouteMaster RM WITH (NOLOCK),SalesInvoice SI WITH (NOLOCK)
					Inner JOIN BillSeriesConfig BS  WITH (NOLOCK) on (SI.BillType=BS.SeriesValue and BS.SeriesMasterId=2)
					INNER JOIN BillSeriesConfig BSF  WITH (NOLOCK) on (SI.BillMode = BSF.SeriesValue  and BSF.SeriesMasterId=1)
					LEFT OUTER JOIN ReceiptInvoice RI WITH (NOLOCK) ON RI.SalId=SI.SalId AND RI.InvRcpMode=3 AND RI.CancelStatus=1 AND RI.InvInsSta NOT IN(4)
					WHERE SI.RtrId=R.RtrId AND SI.RMId=RM.RMId AND SI.SMId=SM.SMId  AND SI.DlvSts IN (1,2,4,5)
					GROUP BY SI.SalId,SI.SalInvNo,SI.SalInvDate,R.RtrName,Si.BillType,SI.BillMode,
					R.RtrId,R.RtrCode,SM.SMId,RM.RMId,BS.SeriesDesc,BSF.SeriesDesc,SI.DlvSts,RI.InvInsDate,SI.ReplacementDiffAmount,SI.SalGrossAmount,SI.MarketRetAmount,
					SI.SalCDAmount,SI.SalDBDiscAmount,SI.SalSplDiscAmount,SI.SalCDAmount,SI.SalDBDiscAmount,SI.SalSplDiscAmount,SI.SalTaxAmount,SI.DBAdjAmount,
					CRAdjAmount,OnAccountAmount,WindowDisplayAmount,MarketRetAmount,ReplacementDiffAmount,OtherCharges,RI.[InvRcpMode],SI.SalNetAmt
		UNION
			SELECT DISTINCT SI.SalId,SI.SalInvNo as [Bill Number],SI.SalInvDate as [Bill Date],
				R.RtrCode AS [Retailer Code],R.RtrName as [Retailer Name],R.RtrId,SM.SMId,RM.RMId,
				(SI.SalGrossAmount) AS  [Gross Amount],SUM(SI.SalSchDiscAmount) as  [Sch Discount]
				,(SI.MarketRetAmount) as [Market Return],(SI.ReplacementDiffAmount) as [Replacement],
				((SI.SalCDAmount)+(SI.SalDBDiscAmount)+(SI.SalSplDiscAmount)) as [Discount],
				(SI.SalTaxAmount)  as [Tax Amount],(SI.DBAdjAmount)-(CRAdjAmount)-(OnAccountAmount)-(WindowDisplayAmount)-(MarketRetAmount)+(ReplacementDiffAmount)+(OtherCharges) AS [Bill Adjustments],
				(SI.SalNetAmt) AS [Net Amount],SI.DlvSts,
				0  AS CollCashAmt,0 AS CollCheque, ISNULL(SUM(RI.SalInvAmt),0) AS CollCredit,0 AS CollDebit, 0 AS CollOnAcc, 0 AS CollDisc, '' AS CollDate,ISNULL(RI.[InvRcpMode],0) AS [InvRcpMode]
				FROM Retailer R WITH (NOLOCK),
				Salesman SM WITH (NOLOCK),RouteMaster RM WITH (NOLOCK),SalesInvoice SI WITH (NOLOCK)
				Inner JOIN BillSeriesConfig BS  WITH (NOLOCK) on (SI.BillType=BS.SeriesValue and BS.SeriesMasterId=2)
				INNER JOIN BillSeriesConfig BSF  WITH (NOLOCK) on (SI.BillMode = BSF.SeriesValue  and BSF.SeriesMasterId=1)
				LEFT OUTER JOIN ReceiptInvoice RI WITH (NOLOCK) ON RI.SalId=SI.SalId AND RI.InvRcpMode=5 AND RI.CancelStatus=1 AND RI.InvInsSta NOT IN(4)
				WHERE SI.RtrId=R.RtrId AND SI.RMId=RM.RMId AND SI.SMId=SM.SMId  AND SI.DlvSts IN (1,2,4,5)
				GROUP BY SI.SalId,SI.SalInvNo,SI.SalInvDate,R.RtrName,Si.BillType,SI.BillMode,
				R.RtrId,R.RtrCode,SM.SMId,RM.RMId,BS.SeriesDesc,BSF.SeriesDesc,SI.DlvSts,RI.InvInsDate,SI.ReplacementDiffAmount,SI.SalGrossAmount,SI.MarketRetAmount,
				SI.SalCDAmount,SI.SalDBDiscAmount,SI.SalSplDiscAmount,SI.SalCDAmount,SI.SalDBDiscAmount,SI.SalSplDiscAmount,SI.SalTaxAmount,SI.DBAdjAmount,CRAdjAmount,OnAccountAmount,
				WindowDisplayAmount,MarketRetAmount,ReplacementDiffAmount,OtherCharges,RI.[InvRcpMode],SI.SalNetAmt
		UNION
			SELECT DISTINCT SI.SalId,SI.SalInvNo as [Bill Number],SI.SalInvDate as [Bill Date],
					R.RtrCode AS [Retailer Code],R.RtrName as [Retailer Name],R.RtrId,SM.SMId,RM.RMId,
					(SI.SalGrossAmount) AS  [Gross Amount],SUM(SI.SalSchDiscAmount) as  [Sch Discount]
					,(SI.MarketRetAmount) as [Market Return],(SI.ReplacementDiffAmount) as [Replacement],
					((SI.SalCDAmount)+(SI.SalDBDiscAmount)+(SI.SalSplDiscAmount)) as [Discount],
					(SI.SalTaxAmount)  as [Tax Amount],(SI.DBAdjAmount)-(CRAdjAmount)-(OnAccountAmount)-(WindowDisplayAmount)-(MarketRetAmount)+(ReplacementDiffAmount)+(OtherCharges) AS [Bill Adjustments],
					SUM(SI.SalNetAmt) AS [Net Amount],SI.DlvSts,
					0  AS CollCashAmt,0 AS CollCheque, 0 AS CollCredit,ISNULL(SUM(RI.SalInvAmt),0) AS CollDebit, 0 AS CollOnAcc, 0 AS CollDisc, ''AS CollDate,ISNULL(RI.[InvRcpMode],0) AS [InvRcpMode]
					FROM Retailer R WITH (NOLOCK),
					Salesman SM WITH (NOLOCK),RouteMaster RM WITH (NOLOCK),SalesInvoice SI WITH (NOLOCK)
					Inner JOIN BillSeriesConfig BS  WITH (NOLOCK) on (SI.BillType=BS.SeriesValue and BS.SeriesMasterId=2)
					INNER JOIN BillSeriesConfig BSF  WITH (NOLOCK) on (SI.BillMode = BSF.SeriesValue  and BSF.SeriesMasterId=1)
					LEFT OUTER JOIN ReceiptInvoice RI WITH (NOLOCK) ON RI.SalId=SI.SalId AND RI.InvRcpMode=6 AND RI.CancelStatus=1 AND RI.InvInsSta NOT IN(4)
					WHERE SI.RtrId=R.RtrId AND SI.RMId=RM.RMId AND SI.SMId=SM.SMId  AND SI.DlvSts IN (1,2,4,5)
					GROUP BY SI.SalId,SI.SalInvNo,SI.SalInvDate,R.RtrName,Si.BillType,SI.BillMode,
					R.RtrId,R.RtrCode,SM.SMId,RM.RMId,BS.SeriesDesc,BSF.SeriesDesc,SI.DlvSts,RI.InvInsDate,SI.ReplacementDiffAmount,SI.SalGrossAmount,SI.MarketRetAmount,
					SI.SalCDAmount,SI.SalDBDiscAmount,SI.SalSplDiscAmount,SI.SalCDAmount,SI.SalDBDiscAmount,SI.SalSplDiscAmount,SI.SalTaxAmount,SI.DBAdjAmount,CRAdjAmount,OnAccountAmount,
					WindowDisplayAmount,MarketRetAmount,ReplacementDiffAmount,OtherCharges,RI.[InvRcpMode]
		UNION
			SELECT DISTINCT SI.SalId,SI.SalInvNo as [Bill Number],SI.SalInvDate as [Bill Date],
				R.RtrCode AS [Retailer Code],R.RtrName as [Retailer Name],R.RtrId,SM.SMId,RM.RMId,
				(SI.SalGrossAmount) AS  [Gross Amount],SUM(SI.SalSchDiscAmount) as  [Sch Discount]
				,(SI.MarketRetAmount) as [Market Return],(SI.ReplacementDiffAmount) as [Replacement],
				((SI.SalCDAmount)+(SI.SalDBDiscAmount)+(SI.SalSplDiscAmount)) as [Discount],
				(SI.SalTaxAmount)  as [Tax Amount],(SI.DBAdjAmount)-(CRAdjAmount)-(OnAccountAmount)-(WindowDisplayAmount)-(MarketRetAmount)+(ReplacementDiffAmount)+(OtherCharges) AS [Bill Adjustments],
				(SI.SalNetAmt) AS [Net Amount],SI.DlvSts,
				0  AS CollCashAmt,0 AS CollCheque, 0 AS CollCredit,0 AS CollDebit, ISNULL(SUM(RI.SalInvAmt),0) AS CollOnAcc, 0 AS CollDisc,'' AS CollDate,ISNULL(RI.[InvRcpMode],0) AS [InvRcpMode]
				FROM Retailer R WITH (NOLOCK),
				Salesman SM WITH (NOLOCK),RouteMaster RM WITH (NOLOCK),SalesInvoice SI WITH (NOLOCK)
				Inner JOIN BillSeriesConfig BS  WITH (NOLOCK) on (SI.BillType=BS.SeriesValue and BS.SeriesMasterId=2)
				INNER JOIN BillSeriesConfig BSF  WITH (NOLOCK) on (SI.BillMode = BSF.SeriesValue  and BSF.SeriesMasterId=1)
				LEFT OUTER JOIN ReceiptInvoice RI WITH (NOLOCK) ON RI.SalId=SI.SalId AND RI.InvRcpMode=7 AND RI.CancelStatus=1 AND RI.InvInsSta NOT IN(4)
				WHERE SI.RtrId=R.RtrId AND SI.RMId=RM.RMId AND SI.SMId=SM.SMId  AND SI.DlvSts IN (1,2,4,5)
				GROUP BY SI.SalId,SI.SalInvNo,SI.SalInvDate,R.RtrName,Si.BillType,SI.BillMode,
				R.RtrId,R.RtrCode,SM.SMId,RM.RMId,BS.SeriesDesc,BSF.SeriesDesc,SI.DlvSts,RI.InvInsDate,SI.ReplacementDiffAmount,SI.SalGrossAmount,SI.MarketRetAmount,
				SI.SalCDAmount,SI.SalDBDiscAmount,SI.SalSplDiscAmount,SI.SalCDAmount,SI.SalDBDiscAmount,SI.SalSplDiscAmount,SI.SalTaxAmount,SI.DBAdjAmount,CRAdjAmount,OnAccountAmount,
				WindowDisplayAmount,MarketRetAmount,ReplacementDiffAmount,OtherCharges,RI.[InvRcpMode],SI.SalNetAmt
		UNION
				SELECT DISTINCT SI.SalId,SI.SalInvNo as [Bill Number],SI.SalInvDate as [Bill Date],
				R.RtrCode AS [Retailer Code],R.RtrName as [Retailer Name],R.RtrId,SM.SMId,RM.RMId,
				(SI.SalGrossAmount) AS  [Gross Amount],SUM(SI.SalSchDiscAmount) as  [Sch Discount]
				,(SI.MarketRetAmount) as [Market Return],(SI.ReplacementDiffAmount) as [Replacement],
				((SI.SalCDAmount)+(SI.SalDBDiscAmount)+(SI.SalSplDiscAmount)) as [Discount],
				(SI.SalTaxAmount)  as [Tax Amount],(SI.DBAdjAmount)-(CRAdjAmount)-(OnAccountAmount)-(WindowDisplayAmount)-(MarketRetAmount)+(ReplacementDiffAmount)+(OtherCharges) AS [Bill Adjustments],
				(SI.SalNetAmt) AS [Net Amount],SI.DlvSts,
				0  AS CollCashAmt,0 AS CollCheque, 0 AS CollCredit,0 AS CollDebit, 0 AS CollOnAcc, ISNULL(SUM(RI.SalInvAmt),0) AS CollDisc, ''AS CollDate,ISNULL(RI.[InvRcpMode],0) AS [InvRcpMode]
				FROM Retailer R WITH (NOLOCK),
				Salesman SM WITH (NOLOCK),RouteMaster RM WITH (NOLOCK),SalesInvoice SI WITH (NOLOCK)
				Inner JOIN BillSeriesConfig BS  WITH (NOLOCK) on (SI.BillType=BS.SeriesValue and BS.SeriesMasterId=2)
				INNER JOIN BillSeriesConfig BSF  WITH (NOLOCK) on (SI.BillMode = BSF.SeriesValue  and BSF.SeriesMasterId=1)
				LEFT OUTER JOIN ReceiptInvoice RI WITH (NOLOCK) ON RI.SalId=SI.SalId AND RI.InvRcpMode=2 AND RI.CancelStatus=1 AND RI.InvInsSta NOT IN(4)
				WHERE SI.RtrId=R.RtrId AND SI.RMId=RM.RMId AND SI.SMId=SM.SMId  AND SI.DlvSts IN (1,2,4,5)
				GROUP BY SI.SalId,SI.SalInvNo,SI.SalInvDate,R.RtrName,Si.BillType,SI.BillMode,
				R.RtrId,R.RtrCode,SM.SMId,RM.RMId,BS.SeriesDesc,BSF.SeriesDesc,SI.DlvSts,RI.InvInsDate,SI.ReplacementDiffAmount,SI.SalGrossAmount,SI.MarketRetAmount,
				SI.SalCDAmount,SI.SalDBDiscAmount,SI.SalSplDiscAmount,SI.SalCDAmount,SI.SalDBDiscAmount,SI.SalSplDiscAmount,SI.SalTaxAmount,SI.DBAdjAmount,CRAdjAmount,OnAccountAmount,
				WindowDisplayAmount,MarketRetAmount,ReplacementDiffAmount,OtherCharges,RI.[InvRcpMode],SI.SalNetAmt
		)A
		GROUP BY SalId,[Bill Number],[Bill Date],[Retailer Code],[Retailer Name],RtrId,SMId,RMId
		,[Bill Adjustments],[Replacement],[Gross Amount],[Market Return],
		   [CollCashAmt],  [CollCheque],   CollCredit,  CollDebit,   CollOnAcc, CollDisc, CollDate,[InvRcpMode],[Net Amount],[Discount],[Tax Amount],[Sch Discount]
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-227-023

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_UpdateFBMSchemeBudget]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_UpdateFBMSchemeBudget]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_UpdateFBMSchemeBudget 45,'SCH1000157',157,'2010-10-09',2,0
--SELECT * FROM FBMTrackIn WHERE PrdId=272
SELECT * FROM FBMSchDetails WHERE SchId=157
SELECT Budget,* FROM SchemeMaster WHERE SchId=157
ROLLBACK TRANSACTION
*/

CREATE	PROCEDURE [dbo].[Proc_UpdateFBMSchemeBudget]
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
		INNER JOIN FBMTrackOut G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
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
			INNER JOIN FBMTrackIn G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
			AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
						
			--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
			UPDATE S SET S.Budget=A.DiscAmt
			FROM SchemeMaster S,
			(
				SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
				FROM
				(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId IN (3,5,45,255,267) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
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
		INNER JOIN FBMTrackOut G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
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
		INNER JOIN FBMTrackIn G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		

		--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
		UPDATE S SET S.Budget=A.DiscAmt
		FROM SchemeMaster S,
		(
			SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
			FROM
			(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
			WHERE TransId IN (3,5,45,255,267) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
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
	--FBM Adjustments
	IF @Pi_TransId=267
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
		INNER JOIN FBMTrackOut G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
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
		INNER JOIN FBMTrackIn G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		

		--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
		UPDATE S SET S.Budget=A.DiscAmt
		FROM SchemeMaster S,
		(
			SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
			FROM
			(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
			WHERE TransId IN (3,5,45,255,267) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
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

--SRF-Nanda-227-024

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_UpdateRetailerClassShift]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_UpdateRetailerClassShift]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_UpdateRetailerClassShift 1
--SELECT * FROM RetailerValueClassMap
--SELECT * FROM AutoRetailerClassShift

CREATE      Proc [dbo].[Proc_UpdateRetailerClassShift]
(
	@Pi_UsrId INT
)
AS
/************************************************************
* VIEW	: [Proc_UpdateRetailerClassShift]
* PURPOSE	: To Update Retailer Class Values
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 19/04/2010
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
BEGIN
SET NOCOUNT ON
	DECLARE @NoOfMonths AS INT 
	DECLARE @CmpId AS INT 
	DECLARE @GrossorNet AS INT 
	DECLARE @Return AS INT 
	DECLARE @FromDate AS DATETIME 
	DECLARE @ToDate AS DATETIME 
	DECLARE @RtrClassId AS INT
	DECLARE @OldRtrClassId AS INT
	DECLARE @RtrId AS INT 
	DECLARE @Amount AS INT 
	DECLARE @CtgMainId AS INT 
	DECLARE @MaxAmount AS NUMERIC(38,2)
	DECLARE @MinAmount AS NUMERIC(38,2)
	DECLARE @MaxRtrClassId AS INT
	DECLARE @MinRtrClassId AS INT
	SELECT @CmpId=CmpId FROM Company WHERE DefaultCompany=1
	DECLARE @RetailerClassShift  TABLE
	(
		RtrId INT,
		SalesGrossAmount NUMERIC(38,6),
		SalesNetAmount NUMERIC(38,6),
		SalesRtnGrossAmount NUMERIC(38,6),
		SalesRtnNetAmount NUMERIC(38,6),
		RtrValueClassId INT,
		TurnOver NUMERIC(38,6),
		RtrClassId  INT ,
		CtgMainId INT ,
		CtgLevelId INT,
		NewClassId INT
	)
	DECLARE @RetailerNewClass TABLE
	(
		RtrId INT,
		Amount NUMERIC(38,6),
		CtgMainId INT
	)
	IF NOT EXISTS (SELECT *  FROM Configuration WHERE ModuleName='RetailerClassShift' AND ModuleId='RCS2' AND Status=1)
	BEGIN
		SET @NoOfMonths=-3
	END
	ELSE
	BEGIN
		SELECT @NoOfMonths=(-1)*CAST(ConfigValue AS INT) FROM Configuration WHERE ModuleName='RetailerClassShift' AND ModuleId='RCS2'
	END 
	SET @FromDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	SET @FromDate=CONVERT(NVARCHAR(10),DATEADD(M,@NoOfMonths,GETDATE()),121)
	SET @ToDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	
	IF NOT EXISTS (SELECT *  FROM Configuration WHERE ModuleName='RetailerClassShift' AND ModuleId='RCS3' AND Status=1)
	BEGIN
		SET @GrossorNet=0
	END
	ELSE
	BEGIN
		SELECT @GrossorNet=ConfigValue FROM Configuration WHERE ModuleName='RetailerClassShift' AND ModuleId='RCS3'
	END 
	IF NOT EXISTS (SELECT *  FROM Configuration WHERE ModuleName='RetailerClassShift' AND ModuleId='RCS4' AND Status=1)
	BEGIN
		SET @Return=0
	END
	ELSE
	BEGIN
		SET @Return=1
	END
	INSERT INTO @RetailerClassShift (RtrId,SalesGrossAmount,SalesNetAmount,SalesRtnGrossAmount,
		SalesRtnNetAmount,RtrValueClassId,TurnOver,RtrClassId,CtgMainId,CtgLevelId,NewClassId)
			
	SELECT RtrId,SUM(GrossAmount),SUM(NetAmount),SUM(ReturnGrossAmt),SUM(ReturnNetAmt),
		RtrValueClassId,Turnover,RtrClassId,CtgMainId,CtgLevelId,NewClassId
	FROM (
	SELECT SI.RtrId,SUM(SI.SalGrossAmount) AS GrossAmount,SUM(SI.SalNetAmt) AS NetAmount,0 AS ReturnGrossAmt,0 AS ReturnNetAmt,
		RVC.RtrValueClassId,RC.Turnover,RC.RtrClassId,
	RCC.CtgMainId,RCL.CtgLevelId,0 AS NewClassId FROM SalesInvoice SI 
	LEFT OUTER JOIN Retailer RTR ON RTR.RtrId = SI.RTRId 
	LEFT OUTER JOIN  RetailerValueClassmap RVC ON RVC.RtrId = SI.RtrId 
	INNER JOIN RetailerValueClass RC ON RVC.RtrValueClassId = RC.RtrClassId and RC.CmpId= @CmpId
	INNER JOIN RetailerCategory RCC ON RCC.CtgMainId = RC.CtgMainId
	INNER JOIN RetailerCategoryLevel RCL ON RCL.CtgLevelId = RCC.CtgLevelId and RCL.CmpId=@CmpId
	WHERE SI.OrderDate BETWEEN @FromDate AND @ToDate AND SI.DlvSts IN(4,5)
	GROUP BY SI.RtrId,RVC.RtrValueClassId,RCC.CtgMainId,RCL.CtgLevelId,RC.Turnover,RC.RtrClassId
	UNION 
	SELECT SI.RtrId,0 AS GrossAmount,0  AS NetAmount,SUM(SI.RtnGrossAmt) AS ReturnGrossAmt,SUM(SI.RtnNetAmt)AS ReturnNetAmt,
		RVC.RtrValueClassId,RC.TurnOver,RC.RtrClassId,
	RCC.CtgMainId,RCL.CtgLevelId,0 FROM ReturnHeader SI 
	LEFT OUTER JOIN Retailer RTR ON RTR.RtrId = SI.RTRId 
	LEFT OUTER JOIN  RetailerValueClassmap RVC ON RVC.RtrId = SI.RtrId 
	INNER JOIN RetailerValueClass RC ON RVC.RtrValueClassId = RC.RtrClassId and RC.CmpId= @CmpId
	INNER JOIN RetailerCategory RCC ON RCC.CtgMainId = RC.CtgMainId
	INNER JOIN RetailerCategoryLevel RCL ON RCL.CtgLevelId = RCC.CtgLevelId and RCL.CmpId=@CmpId
	WHERE SI.ReturnDate BETWEEN @FromDate AND @ToDate AND SI.ReturnType=2 AND SI.Status=0
	GROUP BY SI.RtrId,RVC.RtrValueClassId,RCC.CtgMainId,RCL.CtgLevelId,RC.Turnover,RC.RtrClassId) A
	GROUP BY  RtrId,RtrValueClassId,Turnover,RtrClassId,CtgMainId,CtgLevelId,NewClassId
	IF @GrossorNet=1 
	BEGIN
		IF @Return=1
		BEGIN 
			INSERT INTO @RetailerNewClass (RtrId,Amount,CtgMainId)
			SELECT RtrId,ABS(SalesGrossAmount-SalesRtnGrossAmount),CtgMainId FROM @RetailerClassShift 
		END 
		ELSE
		BEGIN 
			INSERT INTO @RetailerNewClass (RtrId,Amount,CtgMainId)
			SELECT RtrId,SalesGrossAmount,CtgMainId FROM @RetailerClassShift 
		END 
	END
	ELSE
	BEGIN
		IF @Return=1
		BEGIN 
			INSERT INTO @RetailerNewClass (RtrId,Amount,CtgMainId)
			SELECT RtrId,ABS(SalesNetAmount-SalesRtnNetAmount),CtgMainId FROM @RetailerClassShift 
		END 
		ELSE
		BEGIN 
			INSERT INTO @RetailerNewClass (RtrId,Amount,CtgMainId)
			SELECT RtrId,SalesNetAmount,CtgMainId FROM @RetailerClassShift 
		END 
	END 
	--SELECT RtrId,CtgMainId,Amount FROM @RetailerNewClass
	DELETE FROM AutoRetailerClassShift WHERE ShiftDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	DECLARE Cur_RetailerSlassShift CURSOR
          FOR SELECT RtrId,CtgMainId,Amount FROM @RetailerNewClass
    OPEN Cur_RetailerSlassShift
	FETCH NEXT FROM Cur_RetailerSlassShift INTO @RtrId,@CtgMainId,@Amount
	WHILE @@FETCH_STATUS=0
    BEGIN
		
----		SELECT @MaxRtrClassId=RtrClassId,@MaxAmount=TurnOver FROM RetailerValueClass WHERE CtgMainId=@CtgMainId
----			AND TurnOver IN
----		 (SELECT MIN(TurnOver) FROM RetailerValueClass WHERE  CtgMainId=@CtgMainId AND 
----			TurnOver > @Amount AND  CmpId = @CmpId) AND CmpId=@CmpId
----		
		SELECT @MinRtrClassId=RtrClassId,@MinAmount=TurnOver FROM RetailerValueClass WHERE CtgMainId=@CtgMainId
			AND TurnOver IN
		 (SELECT MAX(TurnOver) FROM RetailerValueClass WHERE  CtgMainId=@CtgMainId AND 
			TurnOver < @Amount AND  CmpId = @CmpId) AND CmpId=@CmpId
		SET @RtrClassId=@MinRtrClassId
		--IF @Amount
		
		IF @RtrClassId<>0 
		BEGIN
			IF EXISTS (SELECT RtrValueClassId FROM RetailerValueClassMap WHERE RtrId=@RtrId )
			BEGIN
				SELECT @OldRtrClassId=RtrValueClassId FROM RetailerValueClassMap WHERE RtrId=@RtrId 
				UPDATE RetailerValueClassMap SET RtrValueClassId=@RtrClassId WHERE RtrId=@RtrId
				INSERT INTO AutoRetailerClassShift (ShiftDate,RtrId,OldRtrClassId,NewRtrClassId)
				SELECT CONVERT(NVARCHAR(10),GETDATE(),121),@RtrId,@OldRtrClassId,@RtrClassId
				--DELETE FROM AutoRetailerClassShift WHERE OldRtrClassId=NewRtrClassId		

				UPDATE Retailer SET Upload='N' WHERE RtrId=@RtrId
			END
		END
    FETCH NEXT FROM Cur_RetailerSlassShift INTO  @RtrId,@CtgMainId,@Amount
    END
    CLOSE Cur_RetailerSlassShift
    DEALLOCATE Cur_RetailerSlassShift
RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-227-026

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyQPSSchemeInBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyQPSSchemeInBill]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme(NOLOCK) WHERE SchId=527
--SELECT * FROM BillAppliedSchemeHd
DELETE FROM BillAppliedSchemeHd
EXEC Proc_ApplyQPSSchemeInBill 6,4,0,2,2
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd(NOLOCK) WHERE TransId = 2 And UsrId = 2
--SELECT * FROM BillAppliedSchemeHd (NOLOCK)
--SELECT * FROM ApportionSchemeDetails (NOLOCK)
--SELECT * FROM SalesInvoiceQPSCumulative(NOLOCK) WHERE SchId=522
--SELECT * FROM SchemeMaster
--SELECT * FROM Retailer
--SELECT * FROM BillAppliedSchemeHd
--SELECT * FROM BilledPrdHdForScheme
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
	DECLARE @QPSGivenPoints TABLE
	(
		SchId   INT,		
		Points  NUMERIC(38,0)
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
		SELECT '1',* FROM @TempBilled1
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
		SELECT '2',* FROM @TempBilled1
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
		SELECT '3',* FROM @TempBilled1
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
		SELECT '4',* FROM @TempBilled1
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
		SELECT '5',* FROM @TempBilled1
--		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
--		SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
--			-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
--			-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
--			FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
--			GROUP BY PrdId,PrdBatId
--		SELECT * FROM @TempBilled1
	END
	SELECT '6',* FROM @TempBilled1
	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
		ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
		GROUP BY PrdId,PrdBatId,SchId
	--->Added By Nanda on 26/11/2010
	DELETE FROM @TempBilled WHERE SchemeOnQty+SchemeOnAmount+SchemeOnKG=0
	--->Till Here
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
	SELECT * FROM @TempBilled
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
	
	--->Added By Boo and Nanda on 29/11/2010
	IF @SchType = 3 AND @QPSReset=1
	--IF @QPSReset=1
	BEGIN
		CREATE TABLE  #TemAppQPSSchemes
		(
			SchId		INT,
			SlabId		INT,
			NoOfTime	INT
		)
		
		DECLARE @NewNoOfTimes AS INT
		DECLARE @NewSlabId AS INT
		DECLARE @NewTotalValue AS NUMERIC(38,6)
		SET @NewTotalValue=@TotalValue
		SET @NewSlabId=@SlabId
		WHILE @NewTotalValue>0 AND @NewSlabId>0
		BEGIN
			SELECT @NewNoOfTimes=FLOOR(@NewTotalValue/(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabId AND SchId=@Pi_SchId
			IF @NewNoOfTimes>0
			BEGIN
				SELECT @NewTotalValue=@NewTotalValue-(@NewNoOfTimes*(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabId AND SchId=@Pi_SchId
				INSERT INTO #TemAppQPSSchemes
				SELECT @Pi_SchId,@NewSlabId,@NewNoOfTimes
			END
			SET @NewSlabId=@NewSlabId-1
		END
		SELECT 'New ',* FROM #TemAppQPSSchemes
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemes B WHERE A.SlabId=B.SlabId)
	END
	--->Till Here

	--->Added By Nanda on 23/03/2011
	IF @SchType = 2 AND @QPSReset=1	
	BEGIN
		CREATE TABLE  #TemAppQPSSchemesAmt
		(
			SchId		INT,
			SlabId		INT,
			NoOfTime	INT
		)
		
		DECLARE @NewNoOfTimesAmt AS INT
		DECLARE @NewSlabIdAmt AS INT
		DECLARE @NewTotalValueAmt AS NUMERIC(38,6)

		SET @NewTotalValueAmt=@TotalValue
		SET @NewSlabIdAmt=@SlabId
		WHILE @NewTotalValueAmt>0 AND @NewSlabIdAmt>0
		BEGIN
			SELECT @NewNoOfTimesAmt=FLOOR(@NewTotalValueAmt/(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabIdAmt AND SchId=@Pi_SchId
			IF @NewNoOfTimesAmt>0
			BEGIN
				SELECT @NewTotalValueAmt=@NewTotalValueAmt-(@NewNoOfTimesAmt*(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabIdAmt AND SchId=@Pi_SchId
				INSERT INTO #TemAppQPSSchemesAmt
				SELECT @Pi_SchId,@NewSlabIdAmt,@NewNoOfTimesAmt
			END
			SET @NewSlabIdAmt=@NewSlabIdAmt-1
		END
		SELECT 'New ',* FROM #TemAppQPSSchemesAmt
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemesAmt B WHERE A.SlabId=B.SlabId)
	END
	--->Till Here

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
				FlatAmt * @NoOfTimes
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
					(CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END )
				WHEN 2 THEN 
					(CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END)
				WHEN 3 THEN
					(CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END)
			END
			as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
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

	--->Added By Boo and Nanda on 29/11/2010	
	IF @SchType = 3 AND @QPSReset=1
	--IF @QPSReset=1
	BEGIN
		SELECT DISTINCT * INTO #TempBillApplied FROM @BillAppliedSchemeHd
		DELETE FROM @BillAppliedSchemeHd
		INSERT INTO @BillAppliedSchemeHd
		SELECT * FROM #TempBillApplied
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime 
		FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemes B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		INNER JOIN SchemeSlabs C ON A.SchId=C.SchId AND C.SlabId=B.SlabId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
		AND A.SchId=@Pi_SchId
	END
	--->Till Here

	--->Added By Nanda on 23/03/2011
	IF @SchType = 2 AND @QPSReset=1
	--IF @QPSReset=1
	BEGIN
		SELECT DISTINCT * INTO #TempBillAppliedAmt FROM @BillAppliedSchemeHd
		DELETE FROM @BillAppliedSchemeHd
		INSERT INTO @BillAppliedSchemeHd
		SELECT * FROM #TempBillAppliedAmt
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemesAmt B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		INNER JOIN SchemeSlabs C ON A.SchId=C.SchId AND C.SlabId=B.SlabId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
	END
	--->Till Here

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
		AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
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
			WHERE SchCode=@SchCode AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)

			UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
			PrdId IN (SELECT PrdId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId) AND
			PrdBatId IN (SELECT PrdBatId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
			AND SchemeAmount =0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
	END

	SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
	AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId

	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
	EXEC Proc_ApplyDiscountScheme @Pi_SchId,@Pi_UsrId,@Pi_TransId

	UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
	SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
	TransId = @Pi_TransId AND Usrid = @Pi_UsrId

	INSERT INTO @QPSGivenFlat
	SELECT SchId,SUM(FlatAmount)
	FROM
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount-ReturnFlatAmount,0) AS FlatAmount
	FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
	(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId ) A,
	SalesInvoice SI
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND FlexiSch=0 AND A.SchemeDiscount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
	AND SISl.SlabId<=A.SlabId
	) A 
	WHERE SchId=@Pi_SchId GROUP BY A.SchId	
	
	UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
	FROM @QPSGivenFlat A,
	(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
	WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND SI.SalId=B.SalId AND SI.DlvSts>3
	GROUP BY B.SchId) C
	WHERE A.SchId=C.SchId 
	INSERT INTO @QPSGivenFlat
	SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
	WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenFlat)
	AND B.SchId IN (SELECT DISTINCT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId AND SchemeDiscount=0)
	AND SI.SalId=B.SalId AND SI.DlvSts>3
	GROUP BY B.SchId

	DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
	INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
	SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat

	--->Added By Nanda for Points on 10/01/2011  
	INSERT INTO @QPSGivenPoints
	SELECT SchId,SUM(Points)
	FROM
	(
		SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(Points-ReturnPoints,0) AS Points
		FROM SalesInvoiceSchemeDtPoints SISL,SchemeMaster SM ,
		(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId) A,
		SalesInvoice SI
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3	
	) A  
	WHERE SchId=@Pi_SchId
	GROUP BY A.SchId	
	--->Till Here

	--->Added By Nanda on 21/02/2011
	UPDATE A SET SchemeAmount=B.SchemeAmount
	FROM BillAppliedSchemeHd A,
	(
		SELECT SchId,SlabId,MAX(SchemeAmount) AS SchemeAmount FROM BillAppliedSchemeHd
		WHERE TransID=@Pi_TransId AND UsrId=@Pi_UsrId
		GROUP BY SchId,SlabId 
	) B
	WHERE A.SchId=B.SchId AND A.SlabId=B.SlabId AND TransID=@Pi_TransId AND UsrId=@Pi_UsrId  AND A.SchId=@Pi_SchId
	--->Till Here

	--->For Scheme Amount Update
	UPDATE BillAppliedSchemeHd SET SchemeAmount=CAST(SchemeAmount-Amount AS NUMERIC(38,4))
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

	--->For Scheme Points Update
	UPDATE BillAppliedSchemeHd SET BillAppliedSchemeHd.Points=CAST(BillAppliedSchemeHd.Points-A.Points AS NUMERIC(38,4))
	FROM @QPSGivenPoints A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

	--->For QPS Reset
	DECLARE @MSSchId AS INT
	DECLARE @MaxSlabId AS INT
	DECLARE @AmtToReduced AS NUMERIC(38,6)
	SET @AmtToReduced=0
	DECLARE Cur_QPSSlabs CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabs
	FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenFlat WHERE SchId=@MSSchId)
			BEGIN
				SELECT @AmtToReduced=ISNULL(SUM(Amount),0) FROM @QPSGivenFlat WHERE SchId=@MSSchId

--				SELECT @AmtToReduced=SchemeAmount FROM BillAppliedSchemeHd 
--				WHERE SlabId=@MaxSlabId AND SchId=@MSSchId

				UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-@AmtToReduced
				WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
				AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

				IF EXISTS(SELECT * FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND SchemeAmount<0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)		
				BEGIN
					
					SELECT @AmtToReduced=ABS(SchemeAmount) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND SchemeAmount<0
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

					UPDATE BillAppliedSchemeHd SET SchemeAmount=0
					WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId				
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				END		
				ELSE
				BEGIN
					SET @AmtToReduced=0
				END
			END
		END
		ELSE
		BEGIN
--			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount+@AmtToReduced-Amount
--			FROM  @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=@MSSchId 
--			AND BillAppliedSchemeHd.SlabId=@MaxSlabId AND A.SchId=BillAppliedSchemeHd.SchId

			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-@AmtToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs
	
	--->For Points QPS Reset
	SET @MSSchId=0
	SET @MaxSlabId=0
	DECLARE @PointsToReduced AS NUMERIC(38,0)
	SET @PointsToReduced=0
	DECLARE Cur_QPSSlabsPoints CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabsPoints
	FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenPoints WHERE SchId=@MSSchId)
			BEGIN
				SELECT @PointsToReduced=ISNULL(SUM(Points),0) FROM @QPSGivenPoints WHERE SchId=@MSSchId

				UPDATE BillAppliedSchemeHd SET Points=Points-@PointsToReduced
				WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
				AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				
				IF EXISTS(SELECT * FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND Points<0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId )		
				BEGIN
					SELECT @PointsToReduced=ABS(Points) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND Points<0
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

					UPDATE BillAppliedSchemeHd SET Points=0
					WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId				
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				END		
				ELSE
				BEGIN
					SET @PointsToReduced=0
				END
			END
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHd SET Points=Points-@PointsToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
		FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabsPoints
	DEALLOCATE Cur_QPSSlabsPoints
	--->Till Here

	--->Added By Boo for Free Product Calculation For QPS without QPS Reset
	IF @QPS<>0 AND @QPSReset=0 --AND @QPSApplicapple=1
	BEGIN
		UPDATE A SET FreeToBeGiven=FreeToBeGiven-FreeQty,GiftToBeGiven=GiftToBeGiven-GiftQty FROM BillAppliedSchemeHd A INNER JOIN
		(SELECT A.SchId,A.FreePrdId,A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId,
		(SUM(A.FreeQty)-SUM(A.ReturnFreeQty)) AS FreeQty,
		(SUM(A.GiftQty)-SUM(A.ReturnGiftQty)) AS GiftQty FROM SalesInvoiceSchemeDtFreePrd A 
		INNER JOIN SalesInvoice B ON A.SalId=B.SalId 
		WHERE A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId AND B.DlvSts>3
		GROUP BY A.SchId,A.FreePrdId,A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId) B ON
		A.SchId=B.SchId AND A.FreePrdId=B.FreePrdId AND	A.GiftPrdId=B.GiftPrdId 
		WHERE A.TransId=@Pi_TransId AND A.Usrid=@Pi_UsrId
	END
	--->Till Here	

	DELETE FROM BillAppliedSchemeHd WHERE ROUND(SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd,3)=0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

	IF @QPSReset<>0
	BEGIN
		UPDATE B SET B.NoOfTimes=A.NoOfTimes,B.SchemeAmount=A.SchemeAmount
		FROM BillAppliedSchemeHd B,
		(
			SELECT SchId,SlabId,MAX(NoOfTimes) AS NoOfTimes,MAX(SchemeAmount) AS SchemeAmount
			FROM BillAppliedSchemeHd GROUP BY SchId,SlabId
		) AS A
		WHERE B.SchId=A.SchId AND B.SlabId=A.SlabId AND B.SchId=@Pi_SchId AND B.TransId=@Pi_TransId AND B.UsrId=@Pi_UsrId 
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

	--->Added By Nanda on 25/01/2011
	IF @QPS=1
	BEGIN
		INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
		FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
		TransId,Usrid,PrdId,PrdBatId,SchType)
		SELECT DISTINCT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
		FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
		TransId,Usrid,PrdId,PrdBatId,SchType FROM 
		(SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
		FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
		TransId,Usrid,SchType FROM BillApplieDSchemeHd WHERE SchId=@Pi_SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId) A
		CROSS JOIN 
		(
			SELECT A.PrdId,A.PrdBatId FROM BilledPrdHdForQPSScheme A (NOLOCK) 
			INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON A.RowId=10000 AND 
			A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End		
			AND CAST(A.PrdId AS NVARCHAR(10))+'~'+CAST(A.PrdBatId AS NVARCHAR(10)) 
			NOT IN (SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillApplieDSchemeHd WHERE SchId=@Pi_SchId
			AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId
		)
		)B
		WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
		NOT IN (SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
		FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId)
	END
	--->Till Here
	
	SELECT DISTINCT * INTO #Temp_BillAppliedSchemeHd FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TRansId=@Pi_TransId AND SchId=@Pi_SchId
	DELETE FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TRansId=@Pi_TransId AND SchId=@Pi_SchId
	INSERT INTO BillAppliedSchemeHd
	SELECT * FROM #Temp_BillAppliedSchemeHd 

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-227-027

if exists (select * from dbo.sysobjects where id = object_id(N'[TempGRNListing]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [TempGRNListing]
GO

CREATE TABLE [dbo].[TempGRNListing]
(
	[PurRcptId] [bigint] NULL,
	[PurRcptRefNo] [nvarchar](50) NULL,
	[PrdId] [int] NULL,
	[PrdDCode] [nvarchar](20) NULL,
	[PrdName] [nvarchar](200) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [nvarchar](50) NULL,
	[CmpInvNo] [nvarchar](50) NULL,
	[CmpInvDate] [datetime] NULL,
	[InvBaseQty] [int] NULL,
	[RcvdGoodBaseQty] [int] NULL,
	[UnSalBaseQty] [int] NULL,
	[ShrtBaseQty] [int] NULL,
	[ExsBaseQty] [int] NULL,
	[RefuseSale] [tinyint] NULL,
	[PrdUnitLSP] [numeric](38, 6) NULL,
	[PrdGrossAmount] [numeric](38, 6) NULL,
	[Slno] [int] NULL,
	[RefCode] [nvarchar](25) NULL,
	[FieldDesc] [nvarchar](100) NULL,
	[LineBaseQtyAmount] [numeric](38, 6) NULL,
	[PrdNetAmount] [numeric](38, 6) NULL,
	[Status] [tinyint] NULL,
	[InvDate] [datetime] NULL,
	[LessScheme] [numeric](38, 6) NULL,
	[OtherCharges] [numeric](38, 6) NULL,
	[TotalAddition] [numeric](38, 6) NULL,
	[TotalDeduction] [numeric](38, 6) NULL,
	[GrossAmount] [numeric](38, 6) NULL,
	[NetPayable] [numeric](38, 6) NULL,
	[DifferenceAmount] [numeric](38, 6) NULL,
	[PaidAmount] [numeric](38, 6) NULL,
	[NetAmount] [numeric](38, 6) NULL,
	[SpmId] [int] NULL,
	[SpmName] [nvarchar](100) NULL,
	[LcnId] [int] NULL,
	[LcnName] [nvarchar](100) NULL,
	[TransporterId] [int] NULL,
	[TransporterName] [nvarchar](100) NULL,
	[CmpId] [int] NULL,
	[CmpName] [nvarchar](100) NULL,
	[PrdSlNo] [int] NULL,
	[SBreakupType] [tinyint] NULL,
	[SStockTypeId] [int] NULL,
	[SUserStockType] [nvarchar](100) NULL,
	[SUomId] [int] NULL,
	[SUomCode] [nvarchar](20) NULL,
	[SQuantity] [int] NULL,
	[SBaseQty] [numeric](38, 0) NULL,
	[EBreakupType] [tinyint] NULL,
	[EStockTypeId] [int] NULL,
	[EUserStockType] [nvarchar](50) NULL,
	[EUomId] [int] NULL,
	[EUomCode] [nvarchar](20) NULL,
	[EQuantity] [int] NULL,
	[EBaseQty] [numeric](38, 0) NULL,
	[CSRefId] [int] NULL,
	[CSRefCode] [nvarchar](20) NULL,
	[CSRefName] [nvarchar](50) NULL,
	[CSPrdId] [int] NULL,
	[CSPrdDCode] [nvarchar](20) NULL,
	[CSPrdName] [nvarchar](100) NULL,
	[CSPrdBatId] [int] NULL,
	[CSPrdBatCode] [nvarchar](50) NULL,
	[CSQuantity] [numeric](38, 0) NULL,
	[RateForClaim] [numeric](38, 6) NULL,
	[CSStockTypeId] [int] NULL,
	[CSUserStockType] [nvarchar](50) NULL,
	[CSLcnId] [int] NULL,
	[CsLcnName] [nvarchar](50) NULL,
	[CSValue] [numeric](38, 6) NULL,
	[CSAmount] [numeric](38, 6) NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBankSlipReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBankSlipReport]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

---EXEC Proc_RptBankSlipReport 53,2,0,'Dabur1',0,0,1
CREATE     PROCEDURE [dbo].[Proc_RptBankSlipReport]
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
				InvInsAmt NUMERIC(38,6),
				InvDepDate DATETIME 
		
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
				InvInsAmt NUMERIC(38,6),
				InvDepDate DATETIME'
	SET @TblFields = 'RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvInsAmt,InvDepDate'
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
		
			INSERT INTO #RptBankSlipReport (RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvInsAmt,InvDepDate)
				SELECT RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,
				CAST(InvInsNo AS NVARCHAR(25)),InvInsDate,SalInvAmt,InvDepDate
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
	SELECT * FROM #RptBankSlipReport
		DECLARE @RecCount AS BIGINT 
		SET @RecCount =(SELECT count(*) FROM #RptBankSlipReport)
    	IF @RecCount > 0
			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptBankSlip_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
					DROP TABLE [RptBankSlip_Excel]
					CREATE TABLE RptBankSlip_Excel (RtrBankId BIGINT,DistributorBnkName NVARCHAR(50),RtrBnkName	NVARCHAR(50),RtrBnkBrID	BIGINT,RtrBnkBrName  NVARCHAR(50),DisBnkId INT,DisBranchId INT,
						DistributorBnkBrName NVARCHAR(50),InvInsNo NVARCHAR(25),InvInsDate varchar(10),InvDepDate varchar(10),InvInsAmt NUMERIC(38,6))
                IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='TbpRptBankSlipReport')
					BEGIN 
						DROP TABLE TbpRptBankSlipReport
						SELECT * INTO TbpRptBankSlipReport FROM RptBankSlip_Excel WHERE 1=2
					END 
				 ELSE
					BEGIN 
						SELECT * INTO TbpRptBankSlipReport FROM RptBankSlip_Excel WHERE 1=2
					END 
				INSERT INTO TbpRptBankSlipReport (RtrBankId ,DistributorBnkName,InvInsAmt)
					SELECT 999999,'Total',sum(InvInsAmt) 
				FROM 
						#RptBankSlipReport
				INSERT INTO RptBankSlip_Excel (RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvDepDate,InvInsAmt)
                  SELECT RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,(CONVERT(NVARCHAR(11),InvInsDate ,103)),(CONVERT(NVARCHAR(11),InvDepDate ,103)),InvInsAmt
					FROM #RptBankSlipReport
				
				INSERT INTO RptBankSlip_Excel (RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvDepDate,InvInsAmt)
				SELECT RtrBankId,RtrBnkName,RtrBnkBrID,RtrBnkBrName,DisBnkId,DisBranchId,DistributorBnkName,DistributorBnkBrName,InvInsNo,InvInsDate,InvDepDate,InvInsAmt  
					FROM TbpRptBankSlipReport 
			END
		
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

PRINT '55000'

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptProductPurchase]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptProductPurchase]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

------  exec [Proc_RptProductPurchase] 24,2,0,'Henkel',0,0,1

CREATE     PROCEDURE [dbo].[Proc_RptProductPurchase]
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
	DECLARE @ToDate		AS	DATETIME
	DECLARE @CmpId	 	AS	INT
	DECLARE @CmpInvNo 	AS	INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdBatId	AS	INT
	DECLARE @PrdId		AS	INT

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @CmpInvNo=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))

	Create TABLE #RptProductPurchase
	(
			CmpId 			INT,
			CmpName  		NVARCHAR(50),		
			PurRcptId 		BIGINT,
			PurRcptRefNo 		NVARCHAR(50),
			InvDate 		DATETIME,		
			PrdId  			INT,
			PrdDCode 		NVARCHAR(100),
			PrdName 		NVARCHAR(100),
			InvBaseQty 		INT,
			PrdGrossAmount 		NUMERIC(38,6),
			CmpInvNo 		nVarchar(100)
	)
	SET @TblName = 'RptProductPurchase'
	SET @TblStruct = 'CmpId 			INT,
			CmpName  		NVARCHAR(50),		
			PurRcptId 		BIGINT,
			PurRcptRefNo 		NVARCHAR(50),
			InvDate 		DATETIME,		
			PrdId  			INT,
			PrdDCode 		NVARCHAR(100),
			PrdName 		NVARCHAR(100),
			InvBaseQty 		INT,
			PrdGrossAmount 		NUMERIC(38,6),
			CmpInvNo 		nVarchar(100)'
			
	SET @TblFields = 'CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,InvBaseQty
			 ,PrdGrossAmount,CmpInvNo'
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
	if exists (select * from dbo.sysobjects where id = object_id(N'[UOMIdWise]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [UOMIdWise]
	CREATE TABLE [UOMIdWise] 
	(
		SlNo	INT IDENTITY(1,1),
		UOMId	INT
	) 
	INSERT INTO UOMIdWise(UOMId)
	SELECT UOMId FROM UOMMaster ORDER BY UOMId	
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		EXEC Proc_GRNListing @Pi_UsrId
		INSERT INTO #RptProductPurchase(CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,InvBaseQty
		 ,PrdGrossAmount,CmpInvNo)
		SELECT DISTINCT CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate, PrdId,PrdDCode,PrdName,
			dbo.Fn_ConvertCurrency(InvBaseQty,@Pi_CurrencyId) as InvBaseQty  ,
			dbo.Fn_ConvertCurrency(PrdGrossAmount,@Pi_CurrencyId) as PrdGrossAmount,CmpInvNo
		FROM ( SELECT  CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,
			SUM(InvBaseQty) AS InvBaseQty  , SUM(PrdGrossAmount) AS PrdGrossAmount,SlNo,CmpInvNo FROM 
			TempGrnListing
			WHERE
				( CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
					CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND
				( PurRcptId = (CASE @CmpInvNo WHEN 0 THEN PurRcptId ELSE 0 END) OR
					PurRcptId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId)))
				AND
			
				(PrdId = (CASE @PrdCatId WHEN 0 THEN PrdId Else 0 END) OR
					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
				AND 
				(PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR
					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))

		 		AND
				( INVDATE BETWEEN @FromDate AND @ToDate AND Usrid = @Pi_UsrId)  	
				AND ( PrdId <> 0)
	
			GROUP BY  CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,SlNo,CmpInvNo
		) A
		ORDER BY  CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,CmpInvNo

		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptProductPurchase ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +
				' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
				+ '(PurRcptId = (CASE ' + CAST(@CmpInvNo AS nVarchar(10)) + ' WHEN 0 THEN PurRcptID ELSE 0 END) OR ' +
				' PurRcptID in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',194,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
				+ ' ( INVDATE Between ''' + @FromDate + ''' AND ''' + @ToDate + '''' + ' and UsrId = ' + CAST(@Pi_UsrId AS nVarChar(10)) + ') AND ( PrdId <> 0) ' 	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptProductPurchase'
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
			SET @SSQL = 'INSERT INTO #RptProductPurchase ' +
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
			RETURN
		END
	END
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptProductPurchase
/* Grid View Output Query  09-July-2009   */
	SELECT  a.CmpId,a.CmpName,a.CmpInvNo,a.PurRcptId,a.PurRcptRefNo,
			a.InvDate,a.PrdId,a.PrdDCode,a.PrdName,	a.InvBaseQty,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(a.InvBaseQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
					(CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
					CASE 
						WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
							Case When 
									CAST(a.InvBaseQty AS INT)-(((CAST(a.InvBaseQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
					CAST(a.InvBaseQty AS INT)-(((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
					ELSE
						CASE 
							WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
								Case
									When CAST(Sum(a.InvBaseQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
										CAST(Sum(a.InvBaseQty) AS INT)%nullif(ConverisonFactor2,0)
									Else CAST(Sum(a.InvBaseQty) AS INT) End
							WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
								Case
									When CAST(Sum(a.InvBaseQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
										CAST(Sum(a.InvBaseQty) AS INT)%nullif(ConverisonFactor3,0)
									Else CAST(Sum(a.InvBaseQty) AS INT) End			
						ELSE CAST(Sum(a.InvBaseQty) AS INT) END
					END as Uom4,
			a.PrdGrossAmount INTO #TEMPRptProductPurchaseGrid
	FROM 
			#RptProductPurchase A, View_ProdUOMDetails B 
	WHERE 
			a.prdid=b.prdid 
	Group By a.CmpId,a.CmpName,a.CmpInvNo,a.PurRcptId,a.PurRcptRefNo,ConversionFactor1,
			a.InvDate,a.PrdId,a.PrdDCode,a.PrdName,	a.InvBaseQty,a.PrdGrossAmount,ConverisonFactor2,
			ConverisonFactor3,ConverisonFactor4
	DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
	INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,Rptid,Usrid)
	SELECT CmpName,CmpInvNo,PurRcptRefNo,InvDate,PrdDCode,
	PrdName,InvBaseQty,Uom1,Uom2,Uom3,Uom4,
	PrdGrossAmount,@Pi_RptId,@Pi_UsrId FROM #TEMPRptProductPurchaseGrid
/*  End here  */
-- Added on 09-July-2009 
SELECT 
		a.CmpId,a.CmpName,a.CmpInvNo,a.PurRcptId,a.PurRcptRefNo,a.InvDate,
		a.PrdId,a.PrdDCode,a.PrdName,a.InvBaseQty,
		CASE WHEN ConverisonFactor2>0 THEN Case When CAST(a.InvBaseQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
					CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
					CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
					(CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
					CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
					CASE 
						WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
							Case When 
									CAST(a.InvBaseQty AS INT)-(((CAST(a.InvBaseQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
					CAST(a.InvBaseQty AS INT)-(((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(a.InvBaseQty AS INT)-((CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(a.InvBaseQty AS INT)-(CAST(a.InvBaseQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
					ELSE
						CASE 
							WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
								Case
									When CAST(Sum(a.InvBaseQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
										CAST(Sum(a.InvBaseQty) AS INT)%nullif(ConverisonFactor2,0)
									Else CAST(Sum(a.InvBaseQty) AS INT) End
							WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
								Case
									When CAST(Sum(a.InvBaseQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
										CAST(Sum(a.InvBaseQty) AS INT)%nullif(ConverisonFactor3,0)
									Else CAST(Sum(a.InvBaseQty) AS INT) End			
						ELSE CAST(Sum(a.InvBaseQty) AS INT) END
					END as Uom4,
				a.PrdGrossAmount
		FROM 
				#RptProductPurchase A, View_ProdUOMDetails B 
		WHERE 
				a.prdid=b.prdid 
		Group By a.CmpId,a.CmpName,a.CmpInvNo,a.PurRcptId,a.PurRcptRefNo,ConversionFactor1,
			a.InvDate,a.PrdId,a.PrdDCode,a.PrdName,	a.InvBaseQty,a.PrdGrossAmount,ConverisonFactor2,
			ConverisonFactor3,ConverisonFactor4
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
		BEGIN
			IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptProductPurchase_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
			DROP TABLE RptProductPurchase_Excel
			SELECT CmpId, CmpName,CmpInvNo,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,
				PrdName,InvBaseQty,0 AS Uom1,0 AS  Uom2,0 AS  Uom3,0 AS  Uom4,PrdGrossAmount INTO RptProductPurchase_Excel FROM #RptProductPurchase
		END 
-- End Here
RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

 PRINT '56000'
   
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_RptSchemeUtilization')
DROP PROCEDURE  Proc_RptSchemeUtilization
GO
--EXEC PROC_RptSchemeUtilization 15,2,0,'Henkel',0,0,1
CREATE PROCEDURE [Proc_RptSchemeUtilization]
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
/*********************************
* PROCEDURE: Proc_RptSchemeUtilization
* PURPOSE: Procedure To Return the Scheme Utilization for the Selected Filters
* NOTES:
* CREATED: Thrinath Kola	30-07-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
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
	DECLARE @FromDate	      AS 	DateTime
	DECLARE @ToDate		      AS	DateTime
	DECLARE @fSchId		      AS	Int
	DECLARE @fSMId		      AS	Int
	DECLARE @fRMId		      AS 	Int
	DECLARE @CtgLevelId           AS    	INT
	DECLARE @CtgMainId  	      AS    	INT
	DECLARE @RtrClassId           AS    	INT
	DECLARE @fRtrId		      AS	INT
	DECLARE @TempCtgLevelId       AS    	INT
	
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
	SET @CtgLevelId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @CtgMainId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @RtrClassId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @fRtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	--Till Here
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	Create TABLE #RptSchemeUtilizationDet
	(
		SchId		Int,
		SchCode		nVarChar(100),
		SchDesc		nVarChar(500),
		SlabId		nVarChar(10),
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
		GiftPrdName	nVarchar(50),
		GiftQty		Int,
		GiftValue	Numeric(38,6)
	)
	SET @TblName = 'RptSchemeUtilizationDet'
	
	SET @TblStruct = '	SchId		Int,
				SchCode		nVarChar(100),
				SchDesc		nVarChar(500),
				SlabId		nVarChar(10),
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
				GiftPrdName	nVarchar(50),
				GiftQty		Int,
				GiftValue	Numeric(38,6)'
	SET @TblFields = 'SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,FlatAmount,DiscountPer,Points,FreePrdName,FreeQty,FreeValue,
		GiftPrdName,GiftQty,GiftValue'
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
		EXEC PROC_RPTStoreSchemeDetails @Pi_RptId,@Pi_UsrId
	
		--Added By Nanda on 13/02/2009
--		IF @CtgLevelId=0 
--		BEGIN			
--			SELECT @TempCtgLevelId=MAX(CtgLevelId) FROM RetailerCategoryLevel
--		END
--		ELSE
--		BEGIN
			SELECT @TempCtgLevelId=iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)
--		END
		--Till Here
		INSERT INTO #RptSchemeUtilizationDet(SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
			NoOfBills,UnselectedCnt,FlatAmount,DiscountPer,Points,FreePrdName,FreeQty,FreeValue,
			GiftPrdName,GiftQty,GiftValue)
		SELECT DISTINCT A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,Count(Distinct B.RtrId),
			Count(Distinct B.ReferNo),0 as UnSelectedCnt,dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId) as FlatAmount,
			dbo.Fn_ConvertCurrency(ISNULL(SUM(DiscountPer),0),@Pi_CurrencyId) as DiscountPer,
			ISNULL(SUM(Points),0) as Points,CASE ISNULL(SUM(FreeQty),0) WHEN 0 THEN '-' ELSE FreePrdName END AS FreePrdName,
			ISNULL(SUM(FreeQty),0) as FreeQty,ISNULL(SUM(FreeValue),0) as FreeValue,
			CASE ISNULL(SUM(GiftValue),0) WHEN 0 THEN '-' ELSE GiftPrdName END AS GiftPrdName,ISNULL(SUM(GiftQty),0) as FreeQty,
			ISNULL(SUM(GiftValue),0) as GiftValue
		FROM SchemeMaster A INNER JOIN RPTStoreSchemeDetails B On A.SchId= B.SchId
			AND B.Userid = @Pi_UsrId
		WHERE ReferDate Between @FromDate AND @ToDate  AND
			(B.SMId = (CASE @fSMId WHEN 0 THEN B.SMId Else 0 END) OR
			B.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
			(B.RMId = (CASE @fRMId WHEN 0 THEN B.RMId Else 0 END) OR
			B.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
			(B.CtgLevelId = (CASE @TempCtgLevelId WHEN 0 THEN B.CtgLevelId Else 0 END) OR
			B.CtgLevelId in (@TempCtgLevelId)) AND
--			(B.CtgLevelId = (CASE @CtgMainId WHEN 0 THEN B.CtgLevelId Else 0 END) OR
--			B.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
			(B.CtgMainId = (CASE @CtgMainId WHEN 0 THEN B.CtgMainId Else 0 END) OR
			B.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
			(B.RtrClassId = (CASE @RtrClassId WHEN 0 THEN B.RtrClassId Else 0 END) OR
			B.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
			(B.RtrID = (CASE @fRtrId WHEN 0 THEN B.RtrID Else 0 END) OR
			B.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
			(A.SchId = (CASE @fSchId WHEN 0 THEN A.SchId Else 0 END) OR
			A.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
			B.LineType <> 3
		GROUP BY A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,
			FreePrdName,GiftPrdName
		--SELECT * FROM #RptSchemeUtilizationDet
		
		DELETE FROM @TempData
	
		INSERT INTO @TempData(SchId,RtrCnt,BillCnt)
		SELECT SchId, Count(Distinct B.RtrId),Count(Distinct ReferNo)
		FROM RPTStoreSchemeDetails B
		WHERE ReferDate Between @FromDate AND @ToDate  AND B.Userid = @Pi_UsrId AND
			(B.SMId = (CASE @fSMId WHEN 0 THEN B.SMId Else 0 END) OR
			B.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
			(B.RMId = (CASE @fRMId WHEN 0 THEN B.RMId Else 0 END) OR
			B.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
			(B.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN B.CtgLevelId Else 0 END) OR
			B.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
			(B.CtgMainId = (CASE @CtgMainId WHEN 0 THEN B.CtgMainId Else 0 END) OR
			B.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
			(B.RtrClassId = (CASE @RtrClassId WHEN 0 THEN B.RtrClassId Else 0 END) OR
			B.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
			(B.RtrID = (CASE @fRtrId WHEN 0 THEN B.RtrID Else 0 END) OR
			B.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
			(B.SchId = (CASE @fSchId WHEN 0 THEN B.SchId Else 0 END) OR
			B.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
			B.LineType = 2
		GROUP BY B.SchId
		UPDATE #RptSchemeUtilizationDet SET NoOfRetailer = NoOfRetailer - RtrCnt,
			NoOfBills = BillCnt FROM @TempData B WHERE B.SchId = #RptSchemeUtilizationDet.SchId
	
		DELETE FROM @TempData
	
		INSERT INTO @TempData(SchId,RtrCnt,BillCnt)
		SELECT SchId, Count(Distinct B.RtrId),Count(Distinct ReferNo)
		FROM RPTStoreSchemeDetails B
		WHERE ReferDate Between @FromDate AND @ToDate  AND B.Userid = @Pi_UsrId AND
			(B.SMId = (CASE @fSMId WHEN 0 THEN B.SMId Else 0 END) OR
			B.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
			(B.RMId = (CASE @fRMId WHEN 0 THEN B.RMId Else 0 END) OR
			B.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
			(B.CtgLevelId = (CASE @CtgLevelId WHEN 0 THEN B.CtgLevelId Else 0 END) OR
			B.CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))) AND
			(B.CtgMainId = (CASE @CtgMainId WHEN 0 THEN B.CtgMainId Else 0 END) OR
			B.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
			(B.RtrClassId = (CASE @RtrClassId WHEN 0 THEN B.RtrClassId Else 0 END) OR
			B.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
			(B.RtrID = (CASE @fRtrId WHEN 0 THEN B.RtrID Else 0 END) OR
			B.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
			(B.SchId = (CASE @fSchId WHEN 0 THEN B.SchId Else 0 END) OR
			B.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
			B.LineType = 3
		GROUP BY B.SchId
		UPDATE #RptSchemeUtilizationDet SET UnselectedCnt = RtrCnt
			FROM @TempData B WHERE B.SchId = #RptSchemeUtilizationDet.SchId
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptSchemeUtilizationDet ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +
				' WHERE ReferDate Between ''' + @FromDate + ''' AND ''' + @ToDate + '''AND '+
				' (SMId = (CASE ' + CAST(@fSMId AS nVarchar(10)) + ' WHEN 0 THEN SMId Else 0 END) OR '+
				' SMId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND' +
				' (RMId = (CASE ' + CAST(@fRMId AS nVarchar(10)) + ' WHEN 0 THEN RMId Else 0 END) OR '+
				' RMId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND' +
				' (CtgLevelId = (CASE ' + CAST(@CtgLevelId AS nVarchar(10)) + ' WHEN 0 THEN CtgLevelId Else 0 END) OR '+
				' CtgLevelId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND' +
				' (CtgMainId = (CASE ' + CAST(@CtgMainId AS nVarchar(10)) + ' WHEN 0 THEN CtgMainId Else 0 END) OR '+
				' CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND' +
				' (RtrClassId = (CASE ' + CAST(@RtrClassId AS nVarchar(10)) + ' WHEN 0 THEN RtrClassId Else 0 END) OR '+
				' RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND' +
				' (RtrID = (CASE ' + CAST(@fRtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrID Else 0 END) OR ' +
				' RtrID in (SELECT iCountid from Fn_ReturnRptFilters(' +
				CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND' +
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSchemeUtilizationDet'
				
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
			SET @SSQL = 'INSERT INTO #RptSchemeUtilizationDet ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSchemeUtilizationDet
	-- Till Here
	
	--SELECT * FROM #RptSchemeUtilizationDet
	UPDATE RPT SET RPT.SchCode=S.CmpSchCode FROM #RptSchemeUtilizationDet RPT INNER JOIN SchemeMaster S ON RPT.SchId=S.SchId 

	SELECT SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
	NoOfBills,UnselectedCnt,DiscountPer,FlatAmount,Points,FreePrdName,FreeQty,FreeValue,
	GiftPrdName,GiftQty,GiftValue
	FROM #RptSchemeUtilizationDet
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSchemeUtilization_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptSchemeUtilization_Excel
		SELECT SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
			NoOfBills,UnselectedCnt,DiscountPer,FlatAmount,Points,FreePrdName,FreeQty,FreeValue,
			GiftPrdName,GiftQty,GiftValue INTO RptSchemeUtilization_Excel FROM #RptSchemeUtilizationDet 
	END 
RETURN
END
GO
PRINT '6000' 

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_RptSchemeUtilizationWithOutPrimary')
DROP PROCEDURE  Proc_RptSchemeUtilizationWithOutPrimary
GO
--EXEC Proc_RptSchemeUtilizationWithOutPrimary 152,2,0,'',0,0,1
CREATE PROCEDURE [Proc_RptSchemeUtilizationWithOutPrimary]
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
		UPDATE RtpSchemeWithOutPrimary SET selected=0
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
		(SELECT C.SchId,A.PrdId, A.BaseQty-ReturnedQty AS BaseQty  FROM SalesInvoice D 
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

	SELECT SchId,SchCode,SchDesc,SlabId,SUM(BaseQty) AS BaseQty,SchemeBudget,BudgetUtilized,NoOfRetailer,
	NoOfBills,UnselectedCnt,SUM(FlatAmount) AS FlatAmount,SUM(DiscountPer) AS DiscountPer,Points,
	FreePrdName,SUM(FreeQty) AS FreeQty,SUM(FreeValue) AS FreeValue,SUM(Total) AS Total FROM #RptSchemeUtilization
	GROUP BY SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
	NoOfBills,UnselectedCnt,Points,FreePrdName
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSchemeUtilizationWithOutPrimary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptSchemeUtilizationWithOutPrimary_Excel
		SELECT SchId,SchCode,SchDesc,SlabId,SUM(BaseQty) AS BaseQty,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,SUM(FlatAmount) AS FlatAmount,SUM(DiscountPer) AS DiscountPer,Points,
		FreePrdName,SUM(FreeQty) AS FreeQty,SUM(FreeValue) AS FreeValue,SUM(Total) AS Total  
		INTO RptSchemeUtilizationWithOutPrimary_Excel FROM #RptSchemeUtilization 
		GROUP BY SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,Points,FreePrdName
	END 
	RETURN
END
GO
if not exists (select * from hotfixlog where fixid = 372)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(372,'D','2011-04-05',getdate(),1,'Core Stocky Service Pack 372')

