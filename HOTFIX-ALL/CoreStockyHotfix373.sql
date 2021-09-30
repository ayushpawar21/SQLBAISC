--[Stocky HotFix Version]=373
Delete from Versioncontrol where Hotfixid='373'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('373','2.0.0.5','D','2011-04-11','2011-04-11','2011-04-11',convert(varchar(11),getdate()),'Parle;Major:-Bug Fixing and Changes;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 373' ,'373'
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TempClosingStock]') AND type in (N'U'))
DROP TABLE [dbo].[TempClosingStock]
GO
CREATE TABLE [dbo].[TempClosingStock](
	[CmpId] [int] NOT NULL,
	[PrdId] [int] NOT NULL,
	[LcnId] [int] NOT NULL,
	[PrdName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Sellingrate] [numeric](38, 6) NOT NULL,
	[ListPrice] [numeric](38, 6) NOT NULL,
	[MRP] [numeric](38, 6) NOT NULL,
	[Cases] [int] NOT NULL,
	[BoxStrip] [int] NOT NULL,
	[Pieces] [int] NOT NULL,
	[BaseQty] [numeric](38, 0) NOT NULL,
	[PrdStatus] [int] NOT NULL,
	[BatStatus] [int] NOT NULL,
	[UsrId] [int] NOT NULL,
	[CloPurRte] [numeric](38, 6) NOT NULL,
	[CloSelRte] [numeric](38, 6) NOT NULL,
	[UomId1] [tinyint] NOT NULL DEFAULT ((0)),
	[UomId2] [tinyint] NOT NULL DEFAULT ((0)),
	[UomId3] [tinyint] NOT NULL DEFAULT ((0)),
	[ConversionFactor1] [int] NOT NULL DEFAULT ((0)),
	[ConversionFactor2] [int] NOT NULL DEFAULT ((0)),
	[ConversionFactor3] [int] NOT NULL DEFAULT ((0)),
	[PrdUnitId] [tinyint] NOT NULL DEFAULT ((0))
) ON [PRIMARY]
GO
--SRF-Nanda-230-001-From Kalai

if not exists (Select Id,name from Syscolumns where name = 'Remarks' and id in (Select id from 
	Sysobjects where name ='ReceiptInvoice'))
begin
	ALTER TABLE [dbo].[ReceiptInvoice]
	ADD [Remarks] NVarchar(500)
END
GO

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

INSERT INTO CustomCaptions VALUES (9,31,25,'DgCommon-9-31-25','Debit No','','',1,1,1,'2008-03-19',1,'2008-03-19','Debit No','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,26,'DgCommon-9-31-26','Debit Amt','','',1,1,1,'2008-03-19',1,'2008-03-19','Debit Amt','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,27,'DgCommon-9-31-27','Adj Amt','','',1,1,1,'2008-03-19',1,'2008-03-19','Adj Amt','','',1,1)

DELETE  FROM Configuration WHERE ModuleName LIKE 'Collection Register%' AND ModuleId IN ('COLL13','COLL14','COLL15')
INSERT INTO Configuration VALUES ('COLL13','Collection Register','Display Remarks Column in Collection Register Screen',0,'',0.00,13)
INSERT INTO Configuration VALUES ('COLL14','Collection Register','ExcessCollection',	1,	0,	NULL,	15)
INSERT INTO Configuration VALUES ('COLL15','Collection Register','Perform Account Posting for Cheques',0,'',NULL,15)


--SRF-Nanda-230-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GetStockLedgerSummaryDatewise]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_GetStockLedgerSummaryDatewise]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Exec Proc_GetStockLedgerSummaryDatewise '2006/02/19','2009/04/19',1,0,0
--Select * From TempStockLedSummary where userid=1 and prdid in (3,20) and lcnid=8 and
--Select * From TempStockLedSummaryTotal
--SELECT * FROM StockLedger

CREATE	PROCEDURE [dbo].[Proc_GetStockLedgerSummaryDatewise]
(
	@Pi_FromDate 		DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_UserId		INT,
	@SupTaxGroupId		INT,
	@RtrTaxFroupId		INT,
	@Pi_OfferStock		INT
)
AS
/*********************************
* PROCEDURE	: Proc_GetStockLedgerSummaryDatewise
* PURPOSE	: To Get Stock Ledger Detail
* CREATED	: Nandakumar R.G
* CREATED DATE	: 15/02/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	TRUNCATE TABLE TempStockLedSummaryTotal
	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
		DELETE FROM TaxForReport WHERE UsrId=@Pi_UserId AND RptId=100
		EXEC Proc_ReportTaxCalculation @SupTaxGroupId,@RtrTaxFroupId,1,20,5,@Pi_UserId,100
	END
	
	DECLARE @ProdDetail TABLE
		(
			lcnid	INT,
			PrdBatId INT,
			TransDate DATETIME
		)
	DELETE FROM @ProdDetail
--	INSERT INTO @ProdDetail
--		(
--			lcnid,PrdBatId,TransDate
--		)
--	
--	SELECT a.lcnid,a.PrdBatID,a.TransDate FROM
--	(
--		select lcnid,prdbatid,max(TransDate) as TransDate  FROM StockLedger Stk (nolock)
--			WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate
--		Group by lcnid,prdbatid
--	) a LEFT OUTER JOIN
--	(
--		select distinct lcnid,prdbatid,max(TransDate) as TransDate FROM StockLedger Stk (nolock)
--			WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
--		Group by lcnid,prdbatid
--	) b
--	on a.lcnid = b.lcnid and a.prdbatid = b.prdbatid
--	where b.lcnid is null and b.prdbatid is null
			

	INSERT INTO @ProdDetail  
	(  
		LcnId,PrdBatId,TransDate  
	)  
	SELECT LcnId,PrdBatId,MAX(TransDate) FROM StockLedger(nolock)  
	WHERE TransDate <@Pi_FromDate AND CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) NOT IN
	(SELECT CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) 
	FROM StockLedger WHERE TransDAte BETWEEN @Pi_FromDate AND @Pi_ToDate)
	GROUP BY LcnId,PrdBatId

	DELETE FROM TempStockLedSummary WHERE UserId=@Pi_UserId
	
	--      Stocks for the given date---------
	IF @Pi_OfferStock=1
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT Sl.TransDate AS TransDate,Sl.LcnId AS LcnId,
		Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,
		(Sl.SalOpenStock+Sl.UnSalOpenStock+Sl.OfferOpenStock) AS Opening,
		(Sl.SalPurchase+Sl.UnsalPurchase+Sl.OfferPurchase) AS Purchase,
		(Sl.SalSales+Sl.UnSalSales+Sl.OfferSales) AS Sales,
		(-Sl.SalPurReturn-Sl.UnsalPurReturn-Sl.OfferPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.OfferStockIn-
		Sl.SalStockOut-Sl.UnSalStockOut-Sl.OfferStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.OfferSalesReturn+
		Sl.SalStkJurIn+Sl.UnSalStkJurIn+Sl.OfferStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut-Sl.OfferStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn+Sl.OfferBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut-Sl.OfferBatTfrOut+
		Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn+Sl.OfferLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-Sl.OfferLcnTfrOut-
		Sl.SalReplacement-Sl.OfferReplacement+Sl.DamageIn-Sl.DamageOut) AS Adjustments,
		(Sl.SalClsStock+Sl.UnSalClsStock+Sl.OfferClsStock) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)
		WHERE Sl.PrdId = Prd.PrdId AND
		Sl.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND
		PrdBat.PrdBatId = Sl.PrdBatId AND
		Lcn.LcnId = Sl.LcnId AND
		Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
		ORDER BY Sl.TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	END
	ELSE
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT Sl.TransDate AS TransDate,Sl.LcnId AS LcnId,
		Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,
		(Sl.SalOpenStock+Sl.UnSalOpenStock) AS Opening,
		(Sl.SalPurchase+Sl.UnsalPurchase) AS Purchase,
		(Sl.SalSales+Sl.UnSalSales) AS Sales,
		(-Sl.SalPurReturn-Sl.UnsalPurReturn+Sl.SalStockIn+Sl.UnSalStockIn-
		Sl.SalStockOut-Sl.UnSalStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+
		Sl.SalStkJurIn+Sl.UnSalStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut+
		Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-
		Sl.SalReplacement+Sl.DamageIn-Sl.DamageOut) AS Adjustments,
		(Sl.SalClsStock+Sl.UnSalClsStock) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)
		WHERE Sl.PrdId = Prd.PrdId AND
		Sl.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND
		PrdBat.PrdBatId = Sl.PrdBatId AND
		Lcn.LcnId = Sl.LcnId AND
		Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
		ORDER BY Sl.TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	END	
	--      Stocks for those not included in the given date---------
	IF @Pi_OfferStock=1
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT @Pi_FromDate AS TransDate,ISNULL(Sl.LcnId,0) AS LcnId,
		IsNull(Lcn.LcnName,'')AS LcnName,ISNULL(Sl.PrdId,Prd.PrdId)AS PrdId,ISNULL(Prd.PrdDCode,'') AS PrdDCode,
		ISNULL(Prd.PrdName,'') AS PrdName,ISNULL(Sl.PrdBatId,0) AS PrdBatId,
		ISNULL(PrdBat.PrdBatCode,'') AS PrdBatCode,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)
		LEFT OUTER JOIN Location Lcn (NOLOCK) ON Sl.LcnId=Lcn.LcnId
		WHERE
		Sl.PrdBatId=PrdDet.PrdBatId AND Sl.TransDate=PrdDet.TransDate	
		AND Sl.lcnid = PrdDet.lcnid
		AND Sl.TransDate< @Pi_FromDate
		AND Sl.PrdId=Prd.PrdId And Sl.PrdBatId=PrdBat.PrdBatId AND Prd.PrdId=PrdBat.PrdId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
	END
	ELSE
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT @Pi_FromDate AS TransDate,ISNULL(Sl.LcnId,0) AS LcnId,
		IsNull(Lcn.LcnName,'')AS LcnName,ISNULL(Sl.PrdId,Prd.PrdId)AS PrdId,ISNULL(Prd.PrdDCode,'') AS PrdDCode,
		ISNULL(Prd.PrdName,'') AS PrdName,ISNULL(Sl.PrdBatId,0) AS PrdBatId,
		ISNULL(PrdBat.PrdBatCode,'') AS PrdBatCode,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)
		LEFT OUTER JOIN Location Lcn (NOLOCK) ON Sl.LcnId=Lcn.LcnId
		WHERE
		Sl.PrdBatId=PrdDet.PrdBatId AND Sl.TransDate=PrdDet.TransDate	
		AND Sl.lcnid = PrdDet.lcnid
		AND Sl.TransDate< @Pi_FromDate
		AND Sl.PrdId=Prd.PrdId And Sl.PrdBatId=PrdBat.PrdBatId AND Prd.PrdId=PrdBat.PrdId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
	END
	--      Stocks for those not included in the stockLedger---------
	INSERT INTO TempStockLedSummary
	(
	TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
	Purchase,Sales,Adjustment,Closing,
	PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
	PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
	BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
	)			
	SELECT @Pi_FromDate AS TransDate,Lcn.LcnId,
	Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode,
	0 AS Opening,0 AS Sales,0 AS Purchase,0 AS Adjustments,0 AS Closing,
	0,0,0,0,0,0,0,0,0,0,0,0,
	PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
	FROM
	ProductBatch PrdBat (NOLOCK),ProductCategoryValue PCV (NOLOCK),Product Prd (NOLOCK)
	CROSS JOIN Location Lcn (NOLOCK)
	WHERE
		PrdBat.PrdBatId IN
		(
		SELECT PrdBatId FROM (
		SELECT DISTINCT A.PrdBatId,B.PrdBatId AS NewPrdBatId FROM
		ProductBatch A (nolock) LEFT OUTER JOIN StockLedger B (nolock)
		ON A.Prdid =B.Prdid) a
		WHERE ISNULL(NewPrdBatId,0) = 0
	)
	AND PrdBat.PrdId=Prd.PrdId
	AND Prd.PrdCtgVAlMainId=PCV.PrdCtgValMainId
	GROUP BY Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId,Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,
	Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,PrdBat.BatchSeqId
	ORDER BY TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	UPDATE TempStockLedSummary SET TotalStock=(Opening+Purchase+Sales+Adjustment+Closing)
	
--	UPDATE TempStockLedSummary SET TempStockLedSummary.PurchaseRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummary,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummary.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND TempStockLedSummary.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummary.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.ListPrice=1
--	
--	UPDATE TempStockLedSummary SET TempStockLedSummary.SellingRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummary,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummary.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND TempStockLedSummary.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummary.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.SelRte=1
	UPDATE TRSS SET TRSS.SellingRate=DPH.SellingRate,TRSS.PurchaseRate=DPH.PurchaseRate
	FROM TempStockLedSummary TRSS,DefaultPriceHistory DPH
	WHERE TRSS.PrdId=DPH.PrdId AND TRSS.PrdBatId=DPH.PrdBatId 
	AND TransDate BETWEEN DPH.FromDate AND (CASE DPH.ToDate WHEN '1900-01-01' THEN GETDATE() ELSE DPH.ToDate END)
	
	UPDATE TempStockLedSummary SET OpnPurRte=Opening * PurchaseRate,PurPurRte=Purchase * PurchaseRate,
	SalPurRte=Sales * PurchaseRate,AdjPurRte=Adjustment * PurchaseRate,CloPurRte=Closing * PurchaseRate,
	OpnSelRte=Opening * SellingRate,PurSelRte=Purchase * SellingRate,SalSelRte=Sales * SellingRate,
	AdjSelRte=Adjustment * SellingRate,CloSelRte=Closing * SellingRate
	
	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
		UPDATE TSL SET OpnPurRte=OpnPurRte+(Opening*ISNULL(Tax.PurchaseTaxAmount,0)),
		PurPurRte=PurPurRte+(Purchase*ISNULL(Tax.PurchaseTaxAmount,0)),
		SalPurRte=SalPurRte+(Sales*ISNULL(Tax.PurchaseTaxAmount,0)),
		AdjPurRte=AdjPurRte+(Adjustment*ISNULL(Tax.PurchaseTaxAmount,0)),
		CloPurRte=CloPurRte+(Closing*ISNULL(Tax.PurchaseTaxAmount,0)),
		OpnSelRte=OpnSelRte+(Opening*ISNULL(Tax.SellingTaxAmount,0)),
		PurSelRte=PurSelRte+(Purchase*ISNULL(Tax.SellingTaxAmount,0)),
		SalSelRte=SalSelRte+(Sales*ISNULL(Tax.SellingTaxAmount,0)),
		AdjSelRte=AdjSelRte+(Adjustment*ISNULL(Tax.SellingTaxAmount,0)),
		CloSelRte=CloSelRte+(Closing*ISNULL(Tax.SellingTaxAmount,0))
		FROM TempStockLedSummary TSL LEFT OUTER JOIN TaxForReport Tax
		ON Tax.PrdId=TSL.PrdId AND Tax.PrdBatId=TSL.PrdBatId AND TSL.UserId= Tax.UsrId AND Tax.RptId=100
	END
--	SELECT * FROM TempStockLedSummary ORDER BY PrdId,PrdBatId,LcnId,TransDate
	
	SELECT MIN(TransDate) AS MinTransDate,MAX(TransDate) AS MaxTransDate,
	PrdId,PrdBatId,LcnId
	INTO #TempDates
	FROM TempStockLedSummary WHERE UserId=@Pi_UserId	
	GROUP BY PrdId,PrdBatId,LcnId
	ORDER BY PrdId,PrdBatId,LcnId
		
	
	INSERT INTO TempStockLedSummaryTotal(PrdId,PrdBatId,LcnId,Opening,Purchase,Sales,Adjustment,Closing,
	PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,PurSelRte,SalSelRte,
	AdjSelRte,CloSelRte,BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock)
	SELECT T.PrdId,T.PrdBatId,T.LcnId,T.Opening,T.Purchase,T.Sales,T.Adjustment,T.Closing,
	T.PurchaseRate,T.OpnPurRte,T.PurPurRte,T.SalPurRte,T.AdjPurRte,T.CloPurRte,T.SellingRate,
	T.OpnSelRte,T.PurSelRte,T.SalSelRte,T.AdjSelRte,T.CloSelRte,T.BatchSeqId,T.PrdCtgValLinkCode,
	T.CmpId,T.Status,T.UserId,T.TotalStock
	FROM TempStockLedSummary T,#TempDates TD
	WHERE T.PrdId=TD.PrdId AND T.PrdBatId=TD.PrdBatId AND T.LcnId=TD.LcnId
	AND T.TransDate=TD.MinTransDate AND T.UserId=@Pi_UserId
	
	SELECT T.PrdId,T.PrdBatId,T.LcnId,SUM(T.Purchase) AS TotPur,SUM(T.Sales) AS TotSal,
	SUM(T.Adjustment) AS TotAdj
	INTO #TemDetails
	FROM TempStockLedSummary T,#TempDates TD
	WHERE T.PrdId=TD.PrdId AND T.PrdBatId=TD.PrdBatId AND T.LcnId=TD.LcnId
	AND T.TransDate BETWEEN TD.MinTransDate AND TD.MaxTransDate AND T.UserId=@Pi_UserId
	GROUP BY T.PrdId,T.PrdBatId,T.LcnId
	UPDATE TempStockLedSummaryTotal SET Purchase=TotPur,Sales=TotSal,
	Adjustment=TotAdj
	FROM #TemDetails T
	WHERE T.PrdId=TempStockLedSummaryTotal.PrdId AND T.PrdBatId=TempStockLedSummaryTotal.PrdBatId AND
	T.LcnId=TempStockLedSummaryTotal.LcnId
	UPDATE TempStockLedSummaryTotal SET Closing=Opening+Purchase-Sales+Adjustment
--	UPDATE TempStockLedSummaryTotal SET TempStockLedSummaryTotal.PurchaseRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummaryTotal,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummaryTotal.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND TempStockLedSummaryTotal.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummaryTotal.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.ListPrice=1
--	
--	UPDATE TempStockLedSummaryTotal SET TempStockLedSummaryTotal.SellingRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummaryTotal,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummaryTotal.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND TempStockLedSummaryTotal.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummaryTotal.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.SelRte=1
--	UPDATE TRSS SET TRSS.SellingRate=DPH.SellingRate,TRSS.PurchaseRate=DPH.PurchaseRate
--	FROM TempStockLedSummaryTotal TRSS,DefaultPriceHistory DPH
--	WHERE TRSS.PrdId=DPH.PrdId AND TRSS.PrdBatId=DPH.PrdBatId 
--	AND TransDate BETWEEN DPH.FromDate AND (CASE DPH.ToDate WHEN '1900-01-01' THEN GETDATE() ELSE DPH.ToDate END)
	UPDATE TempStockLedSummaryTotal SET OpnPurRte=Opening * PurchaseRate,PurPurRte=Purchase * PurchaseRate,
	SalPurRte=Sales * PurchaseRate,AdjPurRte=Adjustment * PurchaseRate,CloPurRte=Closing * PurchaseRate,
	OpnSelRte=Opening * SellingRate,PurSelRte=Purchase * SellingRate,SalSelRte=Sales * SellingRate,
	AdjSelRte=Adjustment * SellingRate,CloSelRte=Closing * SellingRate
	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
		UPDATE TSLT SET OpnPurRte=OpnPurRte+(Opening*ISNULL(Tax.PurchaseTaxAmount,0)),
		PurPurRte=PurPurRte+(Purchase*ISNULL(Tax.PurchaseTaxAmount,0)),
		SalPurRte=SalPurRte+(Sales*ISNULL(Tax.PurchaseTaxAmount,0)),
		AdjPurRte=AdjPurRte+(Adjustment*ISNULL(Tax.PurchaseTaxAmount,0)),
		CloPurRte=CloPurRte+(Closing*ISNULL(Tax.PurchaseTaxAmount,0)),
		OpnSelRte=OpnSelRte+(Opening*ISNULL(Tax.SellingTaxAmount,0)),
		PurSelRte=PurSelRte+(Purchase*ISNULL(Tax.SellingTaxAmount,0)),
		SalSelRte=SalSelRte+(Sales*ISNULL(Tax.SellingTaxAmount,0)),
		AdjSelRte=AdjSelRte+(Adjustment*ISNULL(Tax.SellingTaxAmount,0)),
		CloSelRte=CloSelRte+(Closing*ISNULL(Tax.SellingTaxAmount,0))
		FROM TempStockLedSummaryTotal TSLT LEFT OUTER JOIN TaxForReport Tax ON 
		Tax.PrdId=TSLT.PrdId AND Tax.PrdBatId=TSLT.PrdBatId AND
		TSLT.UserId= Tax.UsrId AND Tax.RptId=100
	END	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-230-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GetStockNSalesDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_GetStockNSalesDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM StockLedger  
--SELECT * FROM Product   
--Exec Proc_GetStockNSalesDetails '2011/04/05','2011/04/05',2  
--SELECT * FROM TempRptStockNSales WHERE PrdId=242  

CREATE PROCEDURE [dbo].[Proc_GetStockNSalesDetails]  
(  
	@Pi_FromDate   DATETIME,  
	@Pi_ToDate  DATETIME,  
	@Pi_UserId  INT  
)  
AS  
/*********************************  
* PROCEDURE		: Proc_GetStockLedgerSummaryPrdwise  
* PURPOSE		: To Get Stock Ledger Detail  
* CREATED		: Nandakumar R.G  
* CREATED DATE	: 12/02/2007  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*********************************/  
SET NOCOUNT ON  
BEGIN  
	DECLARE @Count BIGINT  
	DELETE FROM TempRptStockNSales WHERE UserId=@Pi_UserId  
	DECLARE @OpenClose TABLE  
	(  
		TransDate DATETIME,  
		PrdId INT,  
		PrdBatId INT,  
		LcnId INT,  
		SalOpenStock NUMERIC(38,0),  
		UnSalOpenStock NUMERIC(38,0),  
		OfferOpenStock NUMERIC(38,0),  
		SalClsStock NUMERIC(38,0),  
		UnSalClsStock NUMERIC(38,0),  
		OfferClsStock NUMERIC(38,0)  
	)  
	DECLARE @TempDate TABLE  
	(  
		TransDate DATETIME,  
		PrdId INT,  
		PrdBatId INT,  
		LcnId INT  
	)  
	INSERT INTO @TempDate  
	(  
		TransDate,  
		PrdId,  
		PrdBatId,  
		LcnId  
	)  
	SELECT MAX(Sl.TransDate),Sl.PrdId,Sl.PrdBatId,Sl.LcnId  
	FROM Stockledger Sl WHERE  
	TransDate<=@Pi_ToDate  
	GROUP BY PrdId,PrdBatid,LcnId  
	--SELECT * FROM @TempDate  
	INSERT INTO @OpenClose  
	(  
		TransDate ,  
		PrdId ,  
		PrdBatId ,  
		LcnId ,  
		SalOpenStock ,  
		UnSalOpenStock ,  
		OfferOpenStock ,  
		SalClsStock ,  
		UnSalClsStock,  
		OfferClsStock  
	)  
	SELECT Stk.TransDate,Stk.LcnId,Stk.PrdId,Stk.PrdBatId,  
	Stk.SalOpenStock,Stk.UnSalOpenStock,Stk.OfferOpenStock,  
	Stk.SalClsStock,Stk.UnSalClsStock,Stk.OfferClsStock  
	From StockLedger Stk,@TempDate Dte  
	WHERE Stk.TransDate=Dte.TransDate AND Stk.PrdId=Dte.PrdId AND Stk.PrdBatId=Dte.PrdBatId AND Stk.LcnId=Dte.LcnId  

	-------Up to this to take max transdate with Closing Date--------  
	DECLARE @ProdDetail TABLE  
	(  
		LcnId INT,  
		PrdBatId INT,  
		TransDate DATETIME  
	)  
	DELETE FROM @ProdDetail  
--	INSERT INTO @ProdDetail  
--	(  
--		LcnId,PrdBatId,TransDate  
--	)  
--	SELECT Stk.LcnId,Stk.PrdBatId,MAX(Stk.TransDate) FROM StockLedger Stk (nolock)  
--	WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate AND  
--	Stk.PrdBatId NOT IN 
--	(  
--		SELECT Stk.PrdBatId FROM StockLedger Stk (nolock)  
--		WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate  
--		GROUP BY Stk.PrdBatId  
--	)  
--	GROUP BY Stk.LcnId,Stk.PrdId,Stk.PrdBatId HAVING MAX(Stk.TransDate)<@Pi_FromDate  
--	UNION  
--	SELECT Stk.LcnId,Stk.PrdBatId,MAX(Stk.TransDate) FROM StockLedger Stk (nolock),  
--	(  
--		SELECT STK.LcnId,Stk.PrdBatId,  
--		CAST(Stk.LcnId AS NVARCHAR(1000))+'-'+ CAST(Stk.PrdBatId AS NVARCHAR(10)) AS Col  
--		FROM StockLedger Stk (nolock)  
--		WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate  
--		GROUP BY Stk.PrdBatId,STK.LcnId  
--	) AS A  
--	WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate  
--	AND A.Col <>CAST(Stk.LcnId AS NVARCHAR(10))+'-'+CAST(Stk.PrdBatId AS NVARCHAR(10))  
--	GROUP BY Stk.LcnId,Stk.PrdId,Stk.PrdBatId HAVING MAX(Stk.TransDate)>=@Pi_FromDate  


	INSERT INTO @ProdDetail  
	(  
		LcnId,PrdBatId,TransDate  
	)  
	SELECT LcnId,PrdBatId,MAX(TransDate) FROM StockLedger(nolock)  
	WHERE TransDate <@Pi_FromDate AND CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) NOT IN
	(SELECT CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) FROM StockLedger WHERE TransDAte BETWEEN @Pi_FromDate AND @Pi_ToDate)
	GROUP BY LcnId,PrdBatId

	--DELETE FROM TempStockLedDet  
	--      Stocks for the given date---------  
	--select * from TempStockLedSummary  
	INSERT INTO TempRptStockNSales  
	(  
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,  
		Opening,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,Closing,  
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjInPurRte,AdjOutPurRte,PurRetPurRte,SalRetPurRte,  
		CloPurRte,SellingRate,OpnSelRte,PurSelRte,SalSelRte,AdjInSelRte,AdjOutSelRte,  
		PurRetSelRte,SalRetSelRte,CloSelRte,MRP,  
		OpnMRPRte,PurMRPRte,SalMRPRte,AdjInMRPRte,AdjOutMRPRte,  
		PurRetMRPRte,SalRetMRPRte,CloMRPRte,  
		BatchSeqId,PrdCtgValLinkCode,CmpId,PrdStatus,BatStatus,UserId,TotalStock  
	)   
	SELECT @Pi_FromDate AS TransDate,Sl.LcnId AS LcnId,  
	Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,  
	-- (SUM(Sl.SalOpenStock)+SUM(Sl.UnSalOpenStock)) AS Opening,  
	0 AS Opening,  
	(SUM(Sl.SalPurchase)+SUM(Sl.UnsalPurchase))AS Purchase ,  
	(SUM(Sl.SalSales)+SUM(Sl.UnSalSales))AS Sales,  
	(SUM(Sl.SalStockIn)+SUM(Sl.UnSalStockIn)+SUM(Sl.DamageIn)+SUM(Sl.SalStkJurIn)  
	+SUM(Sl.UnSalStkJurIn)+SUM(Sl.SalBatTfrIn)+SUM(Sl.UnSalBatTfrIn)+  
	SUM(Sl.SalLcnTfrIn)+SUM(Sl.UnSalLcnTfrIn)) AS AdjustmentIn,  
	(SUM(Sl.SalStockOut)+SUM(Sl.UnSalStockOut)+SUM(Sl.DamageOut)+SUM(Sl.SalStkJurOut)  
	+SUM(Sl.UnSalStkJurOut)+SUM(Sl.SalBatTfrOut)+SUM(Sl.UnSalBatTfrOut)  
	+SUM(Sl.SalLcnTfrOut)+SUM(Sl.UnSalLcnTfrOut)  
	+SUM(Sl.SalReplacement)) AS AdjustmentOut,  
	(SUM(Sl.SalPurReturn)+SUM(Sl.UnSalPurReturn)) as PurchaseReturn,  
	(SUM(Sl.SalSalesReturn)+SUM(Sl.UnSalSalesReturn)) as SalesReturn,   
	(SUM(Sl.SalClsStock)+SUM(Sl.UnSalClsStock)) AS Closing,  
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  
	PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,@Pi_UserId,0  
	FROM  
	Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)  
	WHERE Sl.PrdId = Prd.PrdId AND  
	Sl.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  
	PrdBat.PrdBatId = Sl.PrdBatId AND  
	Lcn.LcnId = Sl.LcnId AND   
	Prd.PrdCtgValMainId=PCV.PrdCtgValMainId  
	GROUP BY Sl.LcnId,Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,PrdBat.BatchSeqId  
	--ORDER BY Sl.TransDate,Sl.PrdId,Sl.PrdBatId,Lcn.LcnId  
	ORDER BY Sl.PrdId,Sl.PrdBatId,Sl.LcnId

	UPDATE TempRptStockNSales  SET Closing=(OpCl.SalClsStock+OpCl.UnSalClsStock+OpCl.OfferClsStock)  
	FROM @OpenClose OpCl  
	WHERE TempRptStockNSales.PrdId=OpCl.PrdId AND TempRptStockNSales.PrdBatId=OpCl.PrdBatId AND TempRptStockNSales.LcnId=OpCl.LcnId  

	--- To get Opening Stock---------  
	DELETE FROM  @TempDate  
	DELETE FROM  @OpenClose  
	INSERT INTO @TempDate  
	(  
		TransDate,  
		PrdId,  
		PrdBatId,  
		LcnId  
	)  
	SELECT MAX(Sl.TransDate),Sl.PrdId,Sl.PrdBatId,Sl.LcnId  
	FROM Stockledger Sl   
	WHERE TransDate<=@Pi_FromDate  
	GROUP BY PrdId,PrdBatid,LcnId  
	SET @Count=0   
	SELECT @Count=COUNT(*) FROM @TempDate  
	IF @Count=0  
	BEGIN  
	INSERT INTO @TempDate  
	(  
		TransDate,  
		PrdId,  
		PrdBatId,  
		LcnId  
	)  
	SELECT MIN(Sl.TransDate),Sl.PrdId,Sl.PrdBatId,Sl.LcnId  
	FROM Stockledger Sl   
	WHERE TransDate<=@Pi_ToDate  
	GROUP BY PrdId,PrdBatid,LcnId  
	END  
	INSERT INTO @OpenClose  
	(  
		TransDate ,  
		PrdId ,  
		PrdBatId ,  
		LcnId ,  
		SalOpenStock ,  
		UnSalOpenStock ,  
		OfferOpenStock ,  
		SalClsStock ,  
		UnSalClsStock,  
		OfferClsStock  
	)  
	SELECT Stk.TransDate,Stk.PrdId,Stk.PrdBatId,Stk.LcnId,  
	Stk.SalOpenStock,Stk.UnSalOpenStock,Stk.OfferOpenStock,  
	Stk.SalClsStock,Stk.UnSalClsStock,Stk.OfferClsStock  
	FROM StockLedger Stk,@TempDate Dte  
	WHERE Stk.TransDate=Dte.TransDate AND Stk.PrdId=Dte.PrdId AND Stk.PrdBatId=Dte.PrdBatId AND Stk.LcnId=Dte.LcnId  
	UPDATE TempRptStockNSales  SET Opening=(OpCl.SalOpenStock+OpCl.UnSalOpenStock+OpCl.OfferOpenStock)  
	FROM @OpenClose OpCl  
	WHERE TempRptStockNSales.PrdId=OpCl.PrdId AND TempRptStockNSales.PrdBatId=OpCl.PrdBatId AND TempRptStockNSales.LcnId=OpCl.LcnId  
	-- Till here------------------  


--	SELECT * FROM @ProdDetail WHERE PrdBatID IN (SELECT PrdBatId FROM ProductBatch WHERE PrdID=1)

	--      Stocks for those not included in the given date---------  
	INSERT INTO TempRptStockNSales  
	(  
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,  
		Purchase,Sales,AdjustmentIn,AdjustmentOut,SalesReturn,PurchaseReturn,Closing,  
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjInPurRte,AdjOutPurRte,SalRetPurRte,PurRetPurRte,CloPurRte,  
		SellingRate,OpnSelRte,PurSelRte,SalSelRte,AdjInSelRte,AdjOutSelRte,SalRetSelRte,PurRetSelRte,CloSelRte,  
		MRP,OpnMRPRte,PurMRPRte,SalMRPRte,AdjInMRPRte,AdjOutMRPRte,SalRetMRPRte,PurRetMRPRte,CloMRPRte,  
		BatchSeqId,PrdCtgValLinkCode,CmpId,PrdStatus,BatStatus,UserId,TotalStock  
	)     
	SELECT PrdDet.TransDate AS TransDate,ISNULL(Sl.LcnId,0) AS LcnId,  
	IsNull(Lcn.LcnName,'')AS LcnName,ISNULL(Sl.PrdId,Prd.PrdId)AS PrdId,ISNULL(Prd.PrdDCode,'') AS PrdDCode,  
	ISNULL(Prd.PrdName,'') AS PrdName,ISNULL(Sl.PrdBatId,0) AS PrdBatId,  
	ISNULL(PrdBat.PrdBatCode,'') AS PrdBatCode,  
	(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS Opening,  
	0 AS Purchase,0 AS Sales,0 AS AdjustmentIn,0 as AdjustmentOut,  
	0 as SalesReturn,0 as PurchaseReturn,  
	(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS Closing,  
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  
	PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,@Pi_UserId,0  
	FROM  
	Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)  
	LEFT OUTER JOIN Location Lcn (NOLOCK) ON Sl.LcnId=Lcn.LcnId   
	WHERE  
	Sl.PrdBatId=PrdDet.PrdBatId AND Sl.TransDate=PrdDet.TransDate   
	AND Sl.TransDate< @Pi_FromDate  
	AND Sl.PrdId=Prd.PrdId And Sl.PrdBatId=PrdBat.PrdBatId AND Prd.PrdId=PrdBat.PrdId  
	AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PrdDet.LcnId=Sl.LcnId  

	--      Stocks for those not included in the stockLedger---------  
	INSERT INTO TempRptStockNSales  
	(  
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,  
		Purchase,Sales,Adjustmentin,AdjustmentOut,SalesReturn,PurchaseReturn,Closing,  
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjInPurRte,AdjOutPurRte,SalRetPurRte,PurRetPurRte,CloPurRte,  
		SellingRate,OpnSelRte,PurSelRte,SalSelRte,AdjInSelRte,AdjOutSelRte,SalRetSelRte,PurRetSelRte,CloSelRte,  
		MRP,OpnMRPRte,PurMRPRte,SalMRPRte,AdjInMRPRte,AdjOutMRPRte,SalRetMRPRte,PurRetMRPRte,CloMRPRte,  
		BatchSeqId,PrdCtgValLinkCode,CmpId,PrdStatus,BatStatus,UserId,TotalStock  
	)     
	SELECT @Pi_FromDate AS TransDate,Lcn.LcnId,  
	Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,Prd.PrdName,PrdBat.PrdBatId,  
	PrdBat.PrdBatCode,0 AS Opening,0 AS Purchase,0 AS Sales,0 AS AdjustmentIn,0 as AdjustmentOut,  
	0 AS PurchaseReturn,0 AS SalesReturn,0 AS Closing,  
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  
	PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,@Pi_UserId,0  
	FROM  
	ProductBatch PrdBat (NOLOCK),ProductCategoryValue PCV (NOLOCK),Product Prd (NOLOCK)  
	CROSS JOIN Location Lcn (NOLOCK)  
	WHERE  
	PrdBat.PrdBatId IN  
	(  
		SELECT PrdBatId FROM 
		(  
			SELECT DISTINCT A.PrdBatId,B.PrdBatId AS NewPrdBatId FROM  
			ProductBatch A (NOLOCK) LEFT OUTER JOIN StockLedger B (NOLOCK)  
			ON A.PrdId =B.PrdId
		) a  
		WHERE ISNULL(NewPrdBatId,0) = 0  
	)  
	AND PrdBat.PrdId=Prd.PrdId  
	AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId  
	GROUP BY Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId,Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,  
	Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,PrdBat.BatchSeqId  
	ORDER BY TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId  

	UPDATE TempRptStockNSales SET Closing=(Opening+Purchase-Sales+AdjustmentIn-AdjustmentOut+SalesReturn-PurchaseReturn)  

	UPDATE TempRptStockNSales SET TotalStock=Closing  

	UPDATE TempRptStockNSales SET TempRptStockNSales.PurchaseRate=PrdBatDet.PrdBatDetailValue  
	FROM TempRptStockNSales,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,  
	BatchCreation BatCr,Product Prd  
	WHERE TempRptStockNSales.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo  
	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId  
	AND BatCr.BatchSeqId=TempRptStockNSales.BatchSeqId  
	AND TempRptStockNSales.PrdId=PrdBat.PrdId  
	AND PrdBat.BatchSeqId=TempRptStockNSales.BatchSeqId  
	AND PrdBat.PrdId=TempRptStockNSales.PrdID  
	AND PrdBat.PrdId=Prd.PrdID  
	AND BatCr.ListPrice=1  

	UPDATE TempRptStockNSales SET TempRptStockNSales.SellingRate=PrdBatDet.PrdBatDetailValue  
	FROM TempRptStockNSales,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,  
	BatchCreation BatCr,Product Prd  
	WHERE TempRptStockNSales.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo  
	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId  
	AND BatCr.BatchSeqId=TempRptStockNSales.BatchSeqId  
	AND TempRptStockNSales.PrdId=PrdBat.PrdId  
	AND PrdBat.BatchSeqId=TempRptStockNSales.BatchSeqId  
	AND PrdBat.PrdId=TempRptStockNSales.PrdID  
	AND PrdBat.PrdId=Prd.PrdID  
	AND BatCr.SelRte=1  

	UPDATE TempRptStockNSales SET TempRptStockNSales.MRP=PrdBatDet.PrdBatDetailValue  
	FROM TempRptStockNSales,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,  
	BatchCreation BatCr,Product Prd  
	WHERE TempRptStockNSales.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo  
	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId  
	AND BatCr.BatchSeqId=TempRptStockNSales.BatchSeqId  
	AND TempRptStockNSales.PrdId=PrdBat.PrdId  
	AND PrdBat.BatchSeqId=TempRptStockNSales.BatchSeqId  
	AND PrdBat.PrdId=TempRptStockNSales.PrdID  
	AND PrdBat.PrdId=Prd.PrdID  
	AND BatCr.MRP=1  

	UPDATE TempRptStockNSales  
	SET OpnPurRte=Opening * (PurchaseRate+  ISNULL(PurchaseTaxAmount,0)) ,PurPurRte=Purchase * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),  
	SalPurRte=Sales * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),AdjInPurRte=AdjustmentIn * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),  
	AdjOutPurRte=AdjustmentOut * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),  
	SalRetPurRte=SalesReturn * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),PurRetPurRte=PurchaseReturn * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),  
	CloPurRte=Closing * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),  
	OpnSelRte=Opening * (SellingRate+ISNULL(SellingTaxAmount,0)),PurSelRte=Purchase * (SellingRate+ISNULL(SellingTaxAmount,0)),  
	SalSelRte=Sales * (SellingRate+ISNULL(SellingTaxAmount,0)),  
	AdjInSelRte=AdjustmentIn * (SellingRate+ISNULL(SellingTaxAmount,0)),AdjOutSelRte=AdjustmentOut * (SellingRate+ISNULL(SellingTaxAmount,0)),  
	SalRetSelRte=SalesReturn * (SellingRate+ISNULL(SellingTaxAmount,0)),PurRetSelRte=PurchaseReturn * (SellingRate+ISNULL(SellingTaxAmount,0))  
	,CloSelRte=Closing * (SellingRate+ISNULL(SellingTaxAmount,0)),  
	OpnMRPRte=Opening * MRP,PurMRPRte=Purchase * MRP,SalMRPRte=Sales * MRP,  
	AdjInMRPRte=AdjustmentIn * MRP,AdjOutMRPRte=AdjustmentOut * MRP,  
	SalRetMRPRte=SalesReturn * MRP,PurRetMRPRte=PurchaseReturn * MRP  
	,CloMRPRte=Closing * MRP  
	From  TempRptStockNSales TRS LEFT OUTER JOIN TaxForReport Tax ON TRS.PrdId = Tax.PrdId and TRS.PrdBatid = Tax.PrdBatid and  
	TRS.UserId = Tax.UsrId AND Tax.RptId=7  

END  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-230-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GetStockNSalesDetailsWithOffer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_GetStockNSalesDetailsWithOffer]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--SELECT * FROM StockLedger
--Exec Proc_GetStockNSalesDetails '2008/05/28','2006/05/28',1
--SELECT * FROM TempRptStockNSales WHERE PrdId=2

CREATE      PROCEDURE [dbo].[Proc_GetStockNSalesDetailsWithOffer]
(
	@Pi_FromDate 		DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_UserId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_GetStockLedgerSummaryPrdwise
* PURPOSE	: To Get Stock Ledger Detail
* CREATED	: Nandakumar R.G
* CREATED DATE	: 24/07/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	DECLARE @Count BIGINT
	DELETE FROM TempRptStockNSales WHERE UserId=@Pi_UserId
	DECLARE @OpenClose TABLE
	(
		TransDate DATETIME,
		PrdId INT,
		PrdBatId INT,
		LcnId INT,
		SalOpenStock NUMERIC(38,0),
		UnSalOpenStock NUMERIC(38,0),
		OfferOpenStock NUMERIC(38,0),
		SalClsStock NUMERIC(38,0),
		UnSalClsStock NUMERIC(38,0),
		OfferClsStock NUMERIC(38,0)
	)
	
	DECLARE @TempDate TABLE
	(
		TransDate DATETIME,
		PrdId INT,
		PrdBatId INT,
		LcnId INT
	)
	
	INSERT INTO @TempDate
	(
		TransDate,
		PrdId,
		PrdBatId,
		LcnId
	)
	SELECT MAX(Sl.TransDate),Sl.PrdId,Sl.PrdBatId,Sl.LcnId
	FROM Stockledger Sl WHERE
	TransDate<=@Pi_ToDate
	GROUP BY PrdId,PrdBatid,LcnId
	
	--SELECT * FROM @TempDate
	
	
	INSERT INTO @OpenClose
	(
		TransDate ,
		PrdId ,
		PrdBatId ,
		LcnId ,
		SalOpenStock ,
		UnSalOpenStock ,
		OfferOpenStock ,
		SalClsStock ,
		UnSalClsStock,
		OfferClsStock
	)
	SELECT Stk.TransDate,Stk.LcnId,Stk.PrdId,Stk.PrdBatId,
	Stk.SalOpenStock,Stk.UnSalOpenStock,Stk.OfferOpenStock,
	Stk.SalClsStock,Stk.UnSalClsStock,Stk.OfferClsStock
	From StockLedger Stk,@TempDate Dte
	WHERE Stk.TransDate=Dte.TransDate AND Stk.PrdId=Dte.PrdId AND Stk.PrdBatId=Dte.PrdBatId AND Stk.LcnId=Dte.LcnId
-------Up to this to take max transdate with Closing Date--------
	
	
	DECLARE @ProdDetail TABLE
	(
		LcnId INT,
		PrdBatId INT,
		TransDate DATETIME
	)
	DELETE FROM @ProdDetail
--	INSERT INTO @ProdDetail
--	(
--		LcnId,PrdBatId,TransDate
--	)
--	
--	SELECT Stk.LcnId,Stk.PrdBatId,MAX(Stk.TransDate) FROM StockLedger Stk (nolock)
--	WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate AND
--	Stk.PrdBatId NOT IN (
--	SELECT Stk.PrdBatId FROM StockLedger Stk (nolock)
--	WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
--	GROUP BY Stk.PrdBatId
--	)
--	GROUP BY Stk.LcnId,Stk.PrdId,Stk.PrdBatId HAVING MAX(Stk.TransDate)<@Pi_FromDate
--	UNION
--	SELECT Stk.LcnId,Stk.PrdBatId,MAX(Stk.TransDate) FROM StockLedger Stk (nolock),
--	(
--		SELECT STK.LcnId,Stk.PrdBatId,
--		CAST(Stk.LcnId AS NVARCHAR(1000))+'-'+ CAST(Stk.PrdBatId AS NVARCHAR(10)) AS Col
--		FROM StockLedger Stk (nolock)
--		WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
--		GROUP BY Stk.PrdBatId,STK.LcnId
--	) AS A
--	WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate
--	AND A.Col <>CAST(Stk.LcnId AS NVARCHAR(10))+'-'+CAST(Stk.PrdBatId AS NVARCHAR(10))
--	GROUP BY Stk.LcnId,Stk.PrdId,Stk.PrdBatId HAVING MAX(Stk.TransDate)>=@Pi_FromDate

	
	INSERT INTO @ProdDetail  
	(  
		LcnId,PrdBatId,TransDate  
	)  
	SELECT LcnId,PrdBatId,MAX(TransDate) FROM StockLedger(nolock)  
	WHERE TransDate <@Pi_FromDate AND CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) NOT IN
	(SELECT CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) FROM StockLedger WHERE TransDAte BETWEEN @Pi_FromDate AND @Pi_ToDate)
	GROUP BY LcnId,PrdBatId
			
	--DELETE FROM TempStockLedDet
	
	--      Stocks for the given date---------
	--select * from TempStockLedSummary
	INSERT INTO TempRptStockNSales
	(
	TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,
	Opening,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,Closing,
	PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjInPurRte,AdjOutPurRte,PurRetPurRte,SalRetPurRte,
	CloPurRte,SellingRate,OpnSelRte,PurSelRte,SalSelRte,AdjInSelRte,AdjOutSelRte,
	PurRetSelRte,SalRetSelRte,CloSelRte,MRP,
	OpnMRPRte,PurMRPRte,SalMRPRte,AdjInMRPRte,AdjOutMRPRte,
	PurRetMRPRte,SalRetMRPRte,CloMRPRte,
	BatchSeqId,PrdCtgValLinkCode,CmpId,PrdStatus,BatStatus,UserId,TotalStock
	)	
	
	SELECT @Pi_FromDate AS TransDate,Sl.LcnId AS LcnId,
	Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,
--	(SUM(Sl.SalOpenStock)+SUM(Sl.UnSalOpenStock)+SUM(Sl.OfferOpenStock)) AS Opening,
	0 AS Opening,
	(SUM(Sl.SalPurchase)+SUM(Sl.UnsalPurchase)+SUM(Sl.OfferPurchase))AS Purchase ,
	(SUM(Sl.SalSales)+SUM(Sl.UnSalSales)+SUM(Sl.OfferSales))AS Sales,
	(SUM(Sl.SalStockIn)+SUM(Sl.UnSalStockIn)+SUM(Sl.OfferStockIn)+
	SUM(Sl.DamageIn)+SUM(Sl.SalStkJurIn)+SUM(Sl.UnSalStkJurIn)+SUM(Sl.OfferStkJurIn)+
	SUM(Sl.SalBatTfrIn)+SUM(Sl.UnSalBatTfrIn)+SUM(Sl.OfferBatTfrIn)+
	SUM(Sl.SalLcnTfrIn)+SUM(Sl.UnSalLcnTfrIn)+SUM(Sl.OfferLcnTfrIn)) AS AdjustmentIn,
	(SUM(Sl.SalStockOut)+SUM(Sl.UnSalStockOut)+SUM(Sl.OfferStockOut)+
	SUM(Sl.DamageOut)+SUM(Sl.SalStkJurOut)+SUM(Sl.UnSalStkJurOut)+SUM(Sl.OfferStkJurOut)+
	SUM(Sl.SalBatTfrOut)+SUM(Sl.UnSalBatTfrOut)+SUM(Sl.OfferBatTfrOut)+
	SUM(Sl.SalLcnTfrOut)+SUM(Sl.UnSalLcnTfrOut)+SUM(Sl.OfferLcnTfrOut)+
	SUM(Sl.SalReplacement)+SUM(Sl.OfferReplacement)) AS AdjustmentOut,
	(SUM(Sl.SalPurReturn)+SUM(Sl.UnSalPurReturn)+SUM(Sl.OfferPurReturn)) as PurchaseReturn,
	(SUM(Sl.SalSalesReturn)+SUM(Sl.UnSalSalesReturn)+SUM(Sl.OfferSalesReturn)) as SalesReturn,	
	(SUM(Sl.SalClsStock)+SUM(Sl.UnSalClsStock)+SUM(Sl.OfferClsStock)) AS Closing,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,@Pi_UserId,0
	FROM
	Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)
	
	WHERE Sl.PrdId = Prd.PrdId AND
	Sl.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND
	PrdBat.PrdBatId = Sl.PrdBatId AND
	Lcn.LcnId = Sl.LcnId AND	
	Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
	GROUP BY Sl.LcnId,Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,PrdBat.BatchSeqId
	ORDER BY Sl.PrdId,Sl.PrdBatId,sl.LcnId
	UPDATE TempRptStockNSales  SET Closing=(OpCl.SalClsStock+OpCl.UnSalClsStock+OpCl.OfferClsStock)
	FROM @OpenClose OpCl
	WHERE TempRptStockNSales.PrdId=OpCl.PrdId AND TempRptStockNSales.PrdBatId=OpCl.PrdBatId AND TempRptStockNSales.LcnId=OpCl.LcnId
	--- To get Opening Stock---------
	DELETE FROM  @TempDate
	
	DELETE FROM  @OpenClose
	INSERT INTO @TempDate
	(
		TransDate,
		PrdId,
		PrdBatId,
		LcnId
	)
	SELECT MAX(Sl.TransDate),Sl.PrdId,Sl.PrdBatId,Sl.LcnId
	FROM Stockledger Sl WHERE
	TransDate<=@Pi_FromDate
	GROUP BY PrdId,PrdBatid,LcnId
	SET	@Count=0	
	SELECT @Count=COUNT(*) FROM @TempDate
	
	IF @Count=0
	BEGIN
		INSERT INTO @TempDate
		(
			TransDate,
			PrdId,
			PrdBatId,
			LcnId
		)
		SELECT MIN(Sl.TransDate),Sl.PrdId,Sl.PrdBatId,Sl.LcnId
		FROM Stockledger Sl WHERE
		TransDate<=@Pi_ToDate
		GROUP BY PrdId,PrdBatid,LcnId
	END
	INSERT INTO @OpenClose
	(
		TransDate ,
		PrdId ,
		PrdBatId ,
		LcnId ,
		SalOpenStock ,
		UnSalOpenStock ,
		OfferOpenStock ,
		SalClsStock ,
		UnSalClsStock,
		OfferClsStock
	)
	SELECT Stk.TransDate,Stk.PrdId,Stk.PrdBatId,Stk.LcnId,
	Stk.SalOpenStock,Stk.UnSalOpenStock,Stk.OfferOpenStock,
	Stk.SalClsStock,Stk.UnSalClsStock,Stk.OfferClsStock
	FROM StockLedger Stk,@TempDate Dte
	WHERE Stk.TransDate=Dte.TransDate AND Stk.PrdId=Dte.PrdId AND Stk.PrdBatId=Dte.PrdBatId AND Stk.LcnId=Dte.LcnId
	UPDATE TempRptStockNSales  SET Opening=(OpCl.SalOpenStock+OpCl.UnSalOpenStock+OpCl.OfferOpenStock)
	FROM @OpenClose OpCl
	WHERE TempRptStockNSales.PrdId=OpCl.PrdId AND TempRptStockNSales.PrdBatId=OpCl.PrdBatId AND TempRptStockNSales.LcnId=OpCl.LcnId
	-- Till here------------------
	--      Stocks for those not included in the given date---------
	INSERT INTO TempRptStockNSales
	(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,AdjustmentIn,AdjustmentOut,SalesReturn,PurchaseReturn,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjInPurRte,AdjOutPurRte,SalRetPurRte,PurRetPurRte,CloPurRte,
		SellingRate,OpnSelRte,PurSelRte,SalSelRte,AdjInSelRte,AdjOutSelRte,SalRetSelRte,PurRetSelRte,CloSelRte,
		MRP,OpnMRPRte,PurMRPRte,SalMRPRte,AdjInMRPRte,AdjOutMRPRte,SalRetMRPRte,PurRetMRPRte,CloMRPRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,PrdStatus,BatStatus,UserId,TotalStock
	)			
	SELECT PrdDet.TransDate AS TransDate,ISNULL(Sl.LcnId,0) AS LcnId,
	IsNull(Lcn.LcnName,'')AS LcnName,ISNULL(Sl.PrdId,Prd.PrdId)AS PrdId,ISNULL(Prd.PrdDCode,'') AS PrdDCode,
	ISNULL(Prd.PrdName,'') AS PrdName,ISNULL(Sl.PrdBatId,0) AS PrdBatId,
	ISNULL(PrdBat.PrdBatCode,'') AS PrdBatCode,
	(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) AS Opening,
	0 AS Purchase,0 AS Sales,0 AS AdjustmentIn,0 as AdjustmentOut,
	0 as SalesReturn,0 as PurchaseReturn,
	(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) AS Closing,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,@Pi_UserId,0
	FROM
	Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)
	LEFT OUTER JOIN Location Lcn (NOLOCK) ON Sl.LcnId=Lcn.LcnId	
	WHERE
	Sl.PrdBatId=PrdDet.PrdBatId AND Sl.TransDate=PrdDet.TransDate	
	AND Sl.TransDate< @Pi_FromDate
	AND Sl.PrdId=Prd.PrdId And Sl.PrdBatId=PrdBat.PrdBatId AND Prd.PrdId=PrdBat.PrdId
	AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PrdDet.LcnId=Sl.LcnId
	--      Stocks for those not included in the stockLedger---------
	INSERT INTO TempRptStockNSales
	(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustmentin,AdjustmentOut,SalesReturn,PurchaseReturn,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjInPurRte,AdjOutPurRte,SalRetPurRte,PurRetPurRte,CloPurRte,
		SellingRate,OpnSelRte,PurSelRte,SalSelRte,AdjInSelRte,AdjOutSelRte,SalRetSelRte,PurRetSelRte,CloSelRte,
		MRP,OpnMRPRte,PurMRPRte,SalMRPRte,AdjInMRPRte,AdjOutMRPRte,SalRetMRPRte,PurRetMRPRte,CloMRPRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,PrdStatus,BatStatus,UserId,TotalStock
	)			
	SELECT @Pi_FromDate AS TransDate,Lcn.LcnId,
	Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,Prd.PrdName,PrdBat.PrdBatId,
	PrdBat.PrdBatCode,0 AS Opening,0 AS Purchase,0 AS Sales,0 AS AdjustmentIn,0 as AdjustmentOut,
	0 AS PurchaseReturn,0 AS SalesReturn,0 AS Closing,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,@Pi_UserId,0
	FROM
	ProductBatch PrdBat (NOLOCK),ProductCategoryValue PCV (NOLOCK),Product Prd (NOLOCK)
	CROSS JOIN Location Lcn (NOLOCK)
	WHERE
		PrdBat.PrdBatId IN
		(
		SELECT PrdBatId FROM 
		(
			SELECT DISTINCT A.PrdBatId,B.PrdBatId AS NewPrdBatId FROM
			ProductBatch A (NOLOCK) LEFT OUTER JOIN StockLedger B (NOLOCK)
			ON A.PrdId =B.PrdId
		) a
		WHERE ISNULL(NewPrdBatId,0) = 0
	)
	AND PrdBat.PrdId=Prd.PrdId
	AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
	GROUP BY Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId,Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,
	Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode,PCV.PrdCtgValLinkCode,Prd.CmpId,Prd.PrdStatus,PrdBat.Status,PrdBat.BatchSeqId
	ORDER BY TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	UPDATE TempRptStockNSales SET Closing=(Opening+Purchase-Sales+AdjustmentIn-AdjustmentOut+SalesReturn-PurchaseReturn)
	UPDATE TempRptStockNSales SET TotalStock=Closing
	UPDATE TempRptStockNSales SET TempRptStockNSales.PurchaseRate=PrdBatDet.PrdBatDetailValue
	FROM TempRptStockNSales,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,
	BatchCreation BatCr,Product Prd
	WHERE TempRptStockNSales.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
	AND BatCr.BatchSeqId=TempRptStockNSales.BatchSeqId
	AND TempRptStockNSales.PrdId=PrdBat.PrdId
	AND PrdBat.BatchSeqId=TempRptStockNSales.BatchSeqId
	AND PrdBat.PrdId=TempRptStockNSales.PrdID
	AND PrdBat.PrdId=Prd.PrdID
	AND BatCr.ListPrice=1
	
	UPDATE TempRptStockNSales SET TempRptStockNSales.SellingRate=PrdBatDet.PrdBatDetailValue
	FROM TempRptStockNSales,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,
	BatchCreation BatCr,Product Prd
	WHERE TempRptStockNSales.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
	AND BatCr.BatchSeqId=TempRptStockNSales.BatchSeqId
	AND TempRptStockNSales.PrdId=PrdBat.PrdId
	AND PrdBat.BatchSeqId=TempRptStockNSales.BatchSeqId
	AND PrdBat.PrdId=TempRptStockNSales.PrdID
	AND PrdBat.PrdId=Prd.PrdID
	AND BatCr.SelRte=1
	UPDATE TempRptStockNSales SET TempRptStockNSales.MRP=PrdBatDet.PrdBatDetailValue
	FROM TempRptStockNSales,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,
	BatchCreation BatCr,Product Prd
	WHERE TempRptStockNSales.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
	AND BatCr.BatchSeqId=TempRptStockNSales.BatchSeqId
	AND TempRptStockNSales.PrdId=PrdBat.PrdId
	AND PrdBat.BatchSeqId=TempRptStockNSales.BatchSeqId
	AND PrdBat.PrdId=TempRptStockNSales.PrdID
	AND PrdBat.PrdId=Prd.PrdID
	AND BatCr.MRP=1
	UPDATE TRS
	SET OpnPurRte=Opening * (PurchaseRate+  ISNULL(PurchaseTaxAmount,0)) ,PurPurRte=Purchase * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),
	SalPurRte=Sales * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),AdjInPurRte=AdjustmentIn * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),
	AdjOutPurRte=AdjustmentOut * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),
	SalRetPurRte=SalesReturn * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),PurRetPurRte=PurchaseReturn * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),
	CloPurRte=Closing * (PurchaseRate+ISNULL(PurchaseTaxAmount,0)),
	OpnSelRte=Opening * (SellingRate+ISNULL(SellingTaxAmount,0)),PurSelRte=Purchase * (SellingRate+ISNULL(SellingTaxAmount,0)),
	SalSelRte=Sales * (SellingRate+ISNULL(SellingTaxAmount,0)),
	AdjInSelRte=AdjustmentIn * (SellingRate+ISNULL(SellingTaxAmount,0)),AdjOutSelRte=AdjustmentOut * (SellingRate+ISNULL(SellingTaxAmount,0)),
	SalRetSelRte=SalesReturn * (SellingRate+ISNULL(SellingTaxAmount,0)),PurRetSelRte=PurchaseReturn * (SellingRate+ISNULL(SellingTaxAmount,0))
	,CloSelRte=Closing * (SellingRate+ISNULL(SellingTaxAmount,0)),
	OpnMRPRte=Opening * MRP,PurMRPRte=Purchase * MRP,SalMRPRte=Sales * MRP,
	AdjInMRPRte=AdjustmentIn * MRP,AdjOutMRPRte=AdjustmentOut * MRP,
	SalRetMRPRte=SalesReturn * MRP,PurRetMRPRte=PurchaseReturn * MRP
	,CloMRPRte=Closing * MRP
	From  TempRptStockNSales TRS LEFT OUTER JOIN TaxForReport Tax ON TRS.PrdId = Tax.PrdId and TRS.PrdBatid = Tax.PrdBatid and
	TRS.UserId = Tax.UsrId AND Tax.RptId=7
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-230-005

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

	SELECT CM.CmpId,(CASE LEN(ISNULL(SM.CmpSchCode,'')) WHEN 0 THEN ISNULL(SM.SchCode,'')+' - '+SM.SchDsc ELSE ISNULL(SM.CmpSchCode,'')+' - '+SM.SchDsc END) AS RefCode,CM.ClmDate,CM.ClmId,CM.ClmCode,CM.ClmDesc,CM.ClmGrpId,CG.ClmGrpName,CD.TotalSpent,CD.ClmPercentage,
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

--SRF-Nanda-230-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptClosingStockReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptClosingStockReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptClosingStockReport 153,2,0,'',0,0,1

CREATE PROCEDURE [dbo].[Proc_RptClosingStockReport]
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
	
	SELECT @PrdUnit=PrdUnitId FROM ProductUnit WHERE UPPER(PrdUnitName) IN('KILO GRAM','KILOGRAM','KILO GRAMS','KILOGRAMS')
	---Till Here
	--PRINT @DispValue
	CREATE TABLE #RptClosingStock
	(
				PrdId		INT,
				PrdName		NVARCHAR(100),
				MRP		NUMERIC(38,6),
				Cases		NUMERIC(38,0),
				BoxStrip	NUMERIC(38,0),
				Piece		NUMERIC(38,0),
				StockValue	NUMERIC(38,6),
				KiloGrams   NUMERIC(38,6)				
	)
	SET @TblName = 'RptClosingStock'
	SET @TblStruct = ' PrdId		INT,
		PrdName		NVARCHAR(100),
		MRP		    NUMERIC(38,6),
		Cases		NUMERIC(38,0),
		BoxStrip	NUMERIC(38,0),
		Piece		NUMERIC(38,0),
		StockValue	NUMERIC(38,6),
		KiloGrams   NUMERIC(38,6)'
	SET @TblFields = 'PrdId,PrdName,MRP,Cases,BoxStrip,Piece,StockValue,KiloGrams'
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


	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		INSERT INTO #RptClosingStock (PrdId,PrdName,MRP,Cases,BoxStrip,Piece,StockValue,KiloGrams)
		SELECT DISTINCT T.PrdId,T.PrdName,MRP,SUM(Cases),SUM(BoxStrip),SUM(Pieces),
		--SUM((CASE @DispValue WHEN 1 THEN CloSelRte ELSE CloPurRte END)) As StockValue
		SUM((CASE @DispValue WHEN 1 THEN (BaseQty*SellingRate) ELSE (BaseQty*ListPrice) END)) As StockValue,0
		FROM TempClosingStock T
		WHERE 	(T.CmpId = (CASE @CmpId WHEN 0 THEN T.CmpId ELSE 0 END) OR
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
		GROUP BY T.PrdId,T.PrdName,MRP
		ORDER BY T.PrdId,T.PrdName,MRP
		UPDATE T SET KiloGrams=(PrdWgt*BaseQty) FROM #RptClosingStock T,Product P,ProductUnit PU,TempClosingStock TT
		WHERE P.PrdId=T.PrdId AND T.PrdId=TT.PrdId AND PU.PrdUnitId=TT.PrdUnitId AND TT.PrdUnitId=@PrdUnit
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
		SELECT *FROM #RptClosingStock WHERE ([Cases]+[Piece]+[BoxStrip])<>0
		--Check for Report Data
			Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock WHERE ([Cases]+[Piece]+[BoxStrip])<>0
		-- Till Here
	END
	ELSE
	BEGIN
		SELECT *FROM #RptClosingStock
		--Check for Report Data
			Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock 
		-- Till Here
	END
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptClosingStock_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptClosingStock_Excel
		IF @SupZeroStock=1 
		BEGIN
			SELECT * INTO RptClosingStock_Excel FROM #RptClosingStock WHERE ([Cases]+[Piece]+[BoxStrip])<>0
		END
		ELSE
		BEGIN
			SELECT * INTO RptClosingStock_Excel FROM #RptClosingStock
		END
	END 
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-230-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptStockandSalesVolume]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptStockandSalesVolume]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_RptStockandSalesVolume 6,2,0,'NES',0,0,1

CREATE  PROCEDURE [dbo].[Proc_RptStockandSalesVolume]  
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
	DECLARE @FromDate AS DATETIME  
	DECLARE @ToDate  AS DATETIME  
	DECLARE @LcnId   AS INT  
	DECLARE @PrdCatValId AS INT  
	DECLARE @PrdId  AS INT  
	DECLARE @CmpId   AS INT  
	DECLARE @DisplayBatch  AS INT  
	DECLARE @PrdStatus  AS INT  
	DECLARE @BatStatus  AS INT  
	DECLARE @PrdBatId AS INT  
	DECLARE @IncOffStk  AS INT  
	DECLARE @StockValue 	AS	INT
	DECLARE @SupzeroStock AS INT
	DECLARE @RptDispType	AS INT
	--select *  from TempRptStockNSales  
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  
	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))  
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  
	SET @DisplayBatch =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))  
	SET @PrdStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))  
	SET @BatStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))  
	SET @PrdBatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))  
	SET @IncOffStk =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,202,@Pi_UsrId))
	SET @StockValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))  
	SET @SupZeroStock =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))  
	SET @RptDispType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,221,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  

	DELETE FROM TaxForReport

	IF @IncOffStk=1  
	BEGIN  
		Exec Proc_GetStockNSalesDetailsWithOffer @FromDate,@ToDate,@Pi_UsrId  
	END  
	ELSE  
	BEGIN  
		Exec Proc_GetStockNSalesDetails @FromDate,@ToDate,@Pi_UsrId  
	END  
	IF @DisplayBatch = 1 
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	--Create TABLE #RptPendingBillsDetails  
	CREATE TABLE #RptStockandSalesVolume  
	(  
		PrdId			INT,  
		PrdDCode			NVARCHAR(20),  
		PrdName			NVARCHAR(100),  
		PrdBatId			INT,  
		PrdBatCode		NVARCHAR(50),  
		CmpId			INT,  
		CmpName			NVARCHAR(50),  
		LcnId			INT,  
		LcnName			NVARCHAR(50),   
		OpeningStock		NUMERIC(38,0),    
		Purchase			NUMERIC (38,0),  
		Sales			NUMERIC (38,0),  
		AdjustmentIn		NUMERIC (38,0),  
		AdjustmentOut    NUMERIC (38,0),  
		PurchaseReturn   NUMERIC (38,0),  
		SalesReturn		NUMERIC (38,0),    
		ClosingStock		NUMERIC (38,0),  
		DispBatch        INT  ,
		ClosingStkValue	NUMERIC (38,6)
	)  
	SELECT * INTO #RptStockandSalesVolume1 FROM #RptStockandSalesVolume  
	SET @TblName = 'RptStockandSalesVolume'  
	SET @TblStruct = 'PrdId    INT,  
					  PrdDCode			NVARCHAR(20),  
					  PrdName			NVARCHAR(100),  
					  PrdBatId			INT,  
					  PrdBatCode		NVARCHAR(50),  
					  CmpId				INT,  
					  CmpName			NVARCHAR(50),  
					  LcnId				INT,  
					  LcnName			NVARCHAR(50),   
					  OpeningStock		NUMERIC(38,0),  
					  Purchase			NUMERIC (38,0),  
					  Sales				NUMERIC (38,0),     
					  AdjustmentIn		NUMERIC (38,0),  
					  AdjustmentOut		NUMERIC (38,0),  
					  PurchaseReturn	NUMERIC (38,0),  
					  SalesReturn		NUMERIC (38,0),     
					  ClosingStock		NUMERIC (38,0),  
					  DispBatch         INT,
					  ClosingStkValue	NUMERIC (38,6)'  
	SET @TblFields = 'PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
   					  LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,  
					  PurchaseReturn,SalesReturn,ClosingStock,DispBatch,ClosingStkValue'  
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
		INSERT INTO #RptStockandSalesVolume1 (	PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,
												AdjustmentOut,PurchaseReturn,SalesReturn,
												ClosingStock,DispBatch,ClosingStkValue)  
		SELECT 
			PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,TempRptStockNSales.CmpId,CmpName,LcnId,LcnName,  
			Opening,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,Closing,@DisplayBatch,
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN CloSelRte WHEN 2 THEN CloPurRte WHEN 3 THEN CloMRPRte END,@Pi_CurrencyId)
		FROM 
			TempRptStockNSales INNER JOIN  Company  C ON C.CmpId = TempRptStockNSales.CmpId  
		WHERE 
			( TempRptStockNSales.CmpId = (CASE @CmpId WHEN 0 THEN TempRptStockNSales.CmpId ELSE 0 END) OR  
					TempRptStockNSales.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )  
			AND (LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
					LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
			AND (PrdStatus = (CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END) OR  
					PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))  
			AND (BatStatus = (CASE @BatStatus WHEN 0 THEN BatStatus ELSE 2 END) OR  
					BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))  
			AND (PrdId = (CASE @PrdCatValId WHEN 0 THEN PrdId Else 0 END) OR  
					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))  
			AND (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
			AND UserId=@Pi_UsrId  
		IF @DisplayBatch = 1  
		BEGIN  
			INSERT INTO #RptStockandSalesVolume (PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												 LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,
												 PurchaseReturn,SalesReturn,ClosingStock,DispBatch,
												 ClosingStkValue)  
			SELECT 
				PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,0,'',  			
				SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase ,SUM(Sales) AS Sales,  
				SUM(AdjustmentIn) AS AdjustmentIN,SUM(AdjustmentOut) AS AdjustmentOut,  
				SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
				SUM(ClosingStock) AS ClosingStock,@DisplayBatch,SUM(ClosingStkValue)
			FROM #RptStockandSalesVolume1   
			WHERE 
				(PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR  
						PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))      
			GROUP BY PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName  
		END  
		ELSE  
		BEGIN  
			INSERT INTO #RptStockandSalesVolume (PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,
												PurchaseReturn,SalesReturn,ClosingStock,DispBatch,ClosingStkValue)  
			SELECT 
				PrdId,PrdDCode,PrdName,0,'',CmpId,CmpName,0,'',  
				SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase ,SUM(Sales) AS Sales,  
				SUM(AdjustmentIn) AS AdjustmentIN,SUM(AdjustmentOut) AS AdjustmentOut,  
				SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
				SUM(ClosingStock) AS ClosingStock,@DisplayBatch,SUM(ClosingStkValue)
			FROM #RptStockandSalesVolume1   
			WHERE  
				(PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR  
						PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))      
			GROUP BY PrdId,PrdDCode,PrdName,CmpId,CmpName  
		END		 
		IF LEN(@PurDBName) > 0  
		BEGIN  
			SET @SSQL = 'INSERT INTO #RptStockandSalesVolume ' +  
			'(' + @TblFields + ')' +  
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName  
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +  
			' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ '( LcnId = (CASE ' + CAST(@LcnId AS nVarChar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR ' +  
			' LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',22,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ '( PrdStatus = (CASE ' + CAST(@PrdStatus AS nVarchar(10)) + ' WHEN 0 THEN PrdStatus ELSE 0 END) OR ' +  
			' PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',24,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND '  
			+ '( BatStatus = (CASE ' + CAST(@BatStatus AS nVarchar(10)) + ' WHEN 0 THEN BatStatus ELSE 0 END) OR ' +  
			' BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',25,' + CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '  
			+ '( PrdId = (CASE ' + CAST(@PrdCatValId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR ' +  
			' PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '  
			+ ' (R.PrdId = (CASE ' + CAST(@PrdId AS nVarChar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR ' +  
			' PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS  nVarchar(10)) + ',5,' +  CAST(@Pi_UsrId AS nVarchar(10)) + ' )))'  
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptStockandSalesVolume'  
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
			SET @SSQL = 'INSERT INTO #RptStockandSalesVolume ' +  
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
	IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND  GridFlag=1 AND UsrId=@Pi_UsrId)
	BEGIN
		SELECT a.PrdId,a.PrdDCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.CmpId,a.CmpName,a.LcnId,a.LcnName,
		a.OpeningStock,a.Purchase,Sales,CASE WHEN ConverisonFactor2>0 THEN Case When 
		CAST(Sales AS INT)>nullif(ConverisonFactor2,0) Then CAST(Sales AS INT)/nullif(ConverisonFactor2,0) Else 0 End 
		ELSE 0 END As Uom1,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When 
		(CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*
		nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then 
		isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*
		nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case 
		When (CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*
		nullif(ConverisonFactor2,0) + isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*
		nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*
		nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
		(CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + 
		isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/Isnull(ConverisonFactor2,0)*
		Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*
		ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
		CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
		CASE 
			WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
				Case 
				When 
					CAST(Sales AS INT)-(((CAST(Sales AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
					CAST(Sales AS INT)-(((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
				ELSE
					CASE 
						WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
					Case
						When CAST(Sum(Sales) AS INT)>Isnull(ConverisonFactor2,0) Then
							CAST(Sum(Sales) AS INT)%nullif(ConverisonFactor2,0)
						Else CAST(Sum(Sales) AS INT) End
						WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
					Case
					When CAST(Sum(Sales) AS INT)>Isnull(ConverisonFactor3,0) Then
					CAST(Sum(Sales) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(Sales) AS INT) 
				End			
			ELSE CAST(Sum(Sales) AS INT) END
		END AS Uom4,a.AdjustmentIn,a.AdjustmentOut,a.PurchaseReturn,a.SalesReturn,a.ClosingStock,a.DispBatch INTO #RptColDetails
		FROM #RptStockandSalesVolume A INNER JOIN View_ProdUOMDetails B ON a.prdid=b.prdid WHERE OpeningStock > 0 OR ClosingStock > 0  
		GROUP BY a.PrdId,a.PrdDCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.CmpId,a.CmpName,a.LcnId,a.LcnName,a.OpeningStock,a.Purchase,Sales,
		a.AdjustmentIn,a.AdjustmentOut,a.PurchaseReturn,a.SalesReturn,a.ClosingStock,a.DispBatch,
		ConversionFactor1,ConverisonFactor2,ConverisonFactor3,ConverisonFactor4
		ORDER BY A.CmpId,A.PrdId,A.PrdBatId,A.LcnId 
		DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
		INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,C16,C17,C18,Rptid,Usrid)
		SELECT 
			PrdDCode,PrdName,PrdBatCode,CmpName,LcnName,OpeningStock,Purchase,Sales,Uom1,Uom2,Uom3,Uom4,
			AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,ClosingStock,DispBatch,
			@Pi_RptId,@Pi_UsrId 
		FROM #RptColDetails
	END
	IF @SupZeroStock=1
	BEGIN 
		SELECT  * FROM #RptStockandSalesVolume
		WHERE (OpeningStock+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+ClosingStock)<>0
		IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
		BEGIN
			TRUNCATE TABLE RptStockandSalesVolume_Excel
			INSERT INTO RptStockandSalesVolume_Excel
			SELECT	PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,
					LcnId,LcnName,
					OpeningStock,0.00 as OpeningStockInVolume,
					Purchase,0.00 as PurchaseStockInVolume,
					Sales, 0.00 as SalesStockInVolume,
					AdjustmentIn,0.00 as AdjustmentInStockVolume,
					AdjustmentOut,0.00 as AdjustmentOutStockVolume,
					PurchaseReturn,0.00 As PurchaseReturnStockInVolume,
					SalesReturn,0.00 SalesReturnStockInVolume,
					ClosingStock,0.00 ClosingStockInVolume,
					DispBatch,ClosingStkValue
			FROM #RptStockandSalesVolume
			WHERE (OpeningStock+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+ClosingStock)<>0
			Update RptStockandSalesVolume_Excel SET
					OpeningStockInVolume = ((OpeningStock * PrdWgt)/1000),
					PurchaseStockInVolume = ((Purchase * PrdWgt)/1000),
					SalesStockInVolume = ((Sales * PrdWgt)/1000),
					AdjustmentInStockVolume = ((AdjustmentIn * PrdWgt)/1000),
					AdjustmentOutStockVolume = ((AdjustmentOut * PrdWgt)/1000),
					SalesReturnStockInVolume = ((SalesReturn * PrdWgt)/1000),
					ClosingStockInVolume = ((ClosingStock * PrdWgt)/1000)		
			From RptStockandSalesVolume_Excel A,Product B
			WHERE A.PrdId = B.PrdId
		END
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptStockandSalesVolume   
		WHERE (OpeningStock+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+ClosingStock)<>0
	END
	ELSE
	BEGIN
		SELECT * FROM #RptStockandSalesVolume
		IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
		BEGIN
			TRUNCATE TABLE RptStockandSalesVolume_Excel
			INSERT INTO RptStockandSalesVolume_Excel
			SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,
					LcnId,LcnName,
					OpeningStock,0.00 as OpeningStockInVolume,
					Purchase,0.00 as PurchaseStockInVolume,
					Sales, 0.00 as SalesStockInVolume,
					AdjustmentIn,0.00 as AdjustmentInStockVolume,
					AdjustmentOut,0.00 as AdjustmentOutStockVolume,
					PurchaseReturn,0.00 As PurchaseReturnStockInVolume,
					SalesReturn,0.00 SalesReturnStockInVolume,
					ClosingStock,0.00 ClosingStockInVolume,
					DispBatch,ClosingStkValue 
			FROM #RptStockandSalesVolume		
			Update RptStockandSalesVolume_Excel SET
					OpeningStockInVolume = ((OpeningStock * PrdWgt)/1000),
					PurchaseStockInVolume = ((Purchase * PrdWgt)/1000),
					SalesStockInVolume = ((Sales * PrdWgt)/1000),
					AdjustmentInStockVolume = ((AdjustmentIn * PrdWgt)/1000),
					AdjustmentOutStockVolume = ((AdjustmentOut * PrdWgt)/1000),
					SalesReturnStockInVolume = ((SalesReturn * PrdWgt)/1000),
					ClosingStockInVolume = ((ClosingStock * PrdWgt)/1000)		
			From RptStockandSalesVolume_Excel A,Product B
			WHERE A.PrdId = B.PrdId
		END
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptStockandSalesVolume   
	END
	RETURN  
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-230-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_TruncateTempTable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_TruncateTempTable]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[Proc_TruncateTempTable]
(
@Pi_ErrNo  INT OUTPUT
---@Pi_Code AS VARCHAR(20)
)
AS
/*********************************
* PROCEDURE: Proc_TruncateTempTable
* PURPOSE: To Delete the Temp Table
* CREATED: Shanmugam.p 25/04/07
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/

SET NOCOUNT ON

BEGIN
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[TEMPBACKUPCHECK]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	DROP TABLE [TEMPBACKUPCHECK]
	
    SELECT Name INTO TEMPBACKUPCHECK FROM sysobjects
    WHERE NAME LIKE '%Rpt%' AND xtype= 'U' AND NAME NOT IN 
	('RptDetails','RptGroup','RptFilter','RptHeader','RptSelectionHd','RptFormula',
	'Rpt_Udc_Details','Rpt_Udc_Group','Rpt_Udc_Filter','Rpt_Udc_Header','Rpt_Udc_SelectionHd','Rpt_Udc_Formula','RptExcelHeaders','RptAksoExcelheaders')
    
    DECLARE @Str AS VARCHAR(300)
    DECLARE @Name AS VARCHAR(50)
    
    DECLARE Cur_TemptableBackUpCheckUp CURSOR FOR
    
    SELECT Name FROM TEMPBACKUPCHECK
    OPEN Cur_TemptableBackUpCheckUp
    FETCH NEXT FROM Cur_TemptableBackUpCheckUp into @Name
    WHILE @@FETCH_STATUS=0
	BEGIN	
		SET @Str ='TRUNCATE TABLE ' + @Name
        EXEC(@Str)
        print @str
        
        FETCH NEXT FROM Cur_TemptableBackUpCheckUp into @Name
    END
    
    CLOSE Cur_TemptableBackUpCheckUp
	DEALLOCATE Cur_TemptableBackUpCheckUp
	SET @Pi_ErrNo=0
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-230-009

if not exists (Select Id,name from Syscolumns where name = 'Remarks' and id in (Select id from 
	Sysobjects where name ='ReceiptInvoice'))
begin
	ALTER TABLE [dbo].[ReceiptInvoice]
	ADD [Remarks] NVarchar(500)
END
GO

--SRF-Nanda-230-010

if not exists (Select Id,name from Syscolumns where name = 'RtnInvLvlDisc' and id in (Select id from 
	Sysobjects where name ='ReturnHeader'))
begin
	ALTER TABLE [dbo].[ReturnHeader]
	ADD [RtnInvLvlDisc] NUMERIC(38,6) NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-230-011

if not exists (Select Id,name from Syscolumns where name = 'SalInvLvlDisc' and id in (Select id from 
	Sysobjects where name ='SalesInvoice'))
begin
	ALTER TABLE [dbo].[SalesInvoice]
	ADD [SalInvLvlDisc] NUMERIC(38,6) NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-230-012

DELETE FROM ScreenDefaultValues WHERE TransId=9 AND CtrlId=2  
DELETE FROM ScreenDefaultValues WHERE TransId=16 AND CtrlId=16
DELETE FROM ScreenDefaultValues WHERE TransId=45 AND CtrlId=118

INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc) 
VALUES('9','2','0','Debit Note Date','1','1','1','1',CONVERT(datetime,'2010-10-18 21:10:51.657',121),'1',CONVERT(datetime,'2010-10-18 21:10:51.657',121),'Debit Note Date')

INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc) 
VALUES('9','2','1','Debit Note Number','2','1','1','1',CONVERT(datetime,'2010-10-18 21:10:51.657',121),'1',CONVERT(datetime,'2010-10-18 21:10:51.657',121),'Debit Note Number')

INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc) 
VALUES('9','2','2','Retailer','4','1','1','1',CONVERT(datetime,'2010-10-18 21:10:51.657',121),'1',CONVERT(datetime,'2010-10-18 21:10:51.657',121),'Retailer')

INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc) 
VALUES('16','16','0','ALL','1','1','1','1',CONVERT(datetime,'2011-03-18 16:12:32.777',121),'1',CONVERT(datetime,'2011-03-18 16:12:32.777',121),'ALL')

INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc) 
VALUES('16','16','1','Value','2','1','1','1',CONVERT(datetime,'2011-03-18 16:12:32.777',121),'1',CONVERT(datetime,'2011-03-18 16:12:32.777',121),'Value')

INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc) 
VALUES('16','16','2','Product','3','1','1','1',CONVERT(datetime,'2011-03-18 16:12:32.777',121),'1',CONVERT(datetime,'2011-03-18 16:12:32.777',121),'Product')

INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc) 
VALUES('45','118','0','ALL','1','1','1','1',CONVERT(datetime,'2011-03-18 16:12:32.777',121),'1',CONVERT(datetime,'2011-03-18 16:12:32.777',121),'ALL')

INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc) 
VALUES('45','118','1','Value','2','1','1','1',CONVERT(datetime,'2011-03-18 16:12:32.777',121),'1',CONVERT(datetime,'2011-03-18 16:12:32.777',121),'Value')

INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc) 
VALUES('45','118','2','Product','3','1','1','1',CONVERT(datetime,'2011-03-18 16:12:32.777',121),'1',CONVERT(datetime,'2011-03-18 16:12:32.777',121),'Product')

--SRF-Nanda-230-015-From Kalai

if not exists (Select Id,name from Syscolumns where name = 'Remarks' and id in (Select id from 
	Sysobjects where name ='ReceiptInvoice'))
begin
	ALTER TABLE [dbo].[ReceiptInvoice]
	ADD [Remarks] NVarchar(500)
END
GO

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

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='RptCollectionValue')
	BEGIN 
		DROP TABLE RptCollectionValue
	END 
CREATE TABLE [dbo].[RptCollectionValue](
	[SalId] [bigint] NULL,
	[SalInvDate] [datetime] NULL,
	[SalInvNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvRef] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SMId] [int] NULL,
	[SMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InvRcpDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RMId] [int] NULL,
	[RMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DlvRMId] [int] NULL,
	[DelRMName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BillAmount] [numeric](38, 6) NULL,
	[CrAdjAmount] [numeric](38, 6) NULL,
	[DbAdjAmount] [numeric](38, 6) NULL,
	[CashDiscount] [numeric](38, 6) NULL,
	[CollectedAmount] [numeric](38, 6) NULL,
	[PayAmount] [numeric](38, 6) NULL,
	[CurPayAmount] [numeric](38, 6) NULL,
	[CollCashAmt] [numeric](38, 6) NULL,
	[CollChqAmt] [numeric](38, 6) NULL,
	[CollDDAmt] [numeric](38, 6) NULL,
	[CollRTGSAmt] [numeric](38, 6) NULL,
	[InvRcpNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Remarks] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_CollectionValues]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_CollectionValues]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_CollectionValues 2
CREATE PROCEDURE [Proc_CollectionValues]
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
				CollectedAmount,PayAmount,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,InvRcpNo,Remarks)
		SELECT SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,
		 InvCollectedDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,
		 SalNetAmt AS BillAmount,
		 SUM(CrAdjAmount) AS CrAdjAmount,SUM(DbAdjAmount) AS DbAdjAmount,
		 SUM(CashDiscount) AS CashDiscount,
		 SUM(CollectedAmount) AS CollectedAmount,
		 SUM(PayAmount) AS PayAmount, SUM(PayAmount) AS CurPayAmount,
		 SUM(CollCashAmt) AS CollCashAmt,SUM(CollChqAmt) AS CollChqAmt,SUM(CollDDAmt) AS CollDDAmt,SUM(CollRTGSAmt) AS CollRTGSAmt,InvRcpNo,Remarks 
	FROM(
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
		SUM(RI.SalInvAmt)  AS CollCashAmt,0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,RI.Remarks 
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
			 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RI.Remarks 
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
		    SUM(RI.SalInvAmt) AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,RI.Remarks 
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
			 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RI.Remarks 
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    SUM(RI.SalInvAmt) AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,RI.Remarks 
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
			 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RI.Remarks 
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName AS DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,SUM(RI.SalInvAmt)AS CollectedAmount,0 AS PayAmount,
			0 AS CollCashAmt,0 AS CollChqAmt,
		    0 AS CollDDAmt,SUM(RI.SalInvAmt) AS  CollRTGSAmt,RI.InvRcpNo,RI.Remarks 
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
			 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RI.Remarks 
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			SUM(RI.SalInvAmt) AS CrAdjAmount,
			0 AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,RI.Remarks 
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
			 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,RI.InvRcpNo,RI.Remarks 
	UNION 
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			SUM(RI.SalInvAmt) AS DbAdjAmount,0 AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,RI.Remarks 
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
			 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpMode,RI.InvRcpNo,RI.Remarks 
	UNION 
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName as DelRMName,
			0 AS CrAdjAmount,
			0 AS DbAdjAmount,SUM(RI.SalInvAmt) AS CashDiscount,
			SI.SalNetAmt,0 AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,0 AS CollChqAmt,
			0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,RI.Remarks 
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
			 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
			 SI.SalNetAmt,SI.SalPayAmt,RI.InvRcpNo,RI.Remarks 
	UNION
		SELECT SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
			RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,
			RMD.RMName as DelRMName,0 AS CrAdjAmount,0 AS DbAdjAmount,
			0 AS CashDiscount,0 AS SalNetAmt,
			ISNULL(ROA.Amount,0) AS CollectedAmount,0 AS PayAmount,0 AS CollCashAmt,
			0 AS CollChqAmt,0 AS CollDDAmt,0 AS CollRTGSAmt,RI.InvRcpNo,RI.Remarks 
		FROM ReceiptInvoice RI WITH (NOLOCK),
			Receipt RE WITH (NOLOCK),
			Retailer R WITH (NOLOCK),
		        Salesman SM WITH (NOLOCK),
			RouteMaster RM WITH (NOLOCK),
			RouteMaster RMD WITH (NOLOCK),
			RetailerOnAccount ROA WITH (NOLOCK), 
			SalesInvoice SI WITH (NOLOCK)
		WHERE ROA.RtrId=R.RtrId AND SI.SMId=SM.SMId
		        AND RM.RMId=SI.RMId AND RMD.RMId=SI.DlvRMId 
			AND RI.SalId=SI.SalId  AND RE.InvRcpNo=RI.InvRcpNo
			AND ROA.LastModDate=RE.InvCollectedDate
			AND ROA.TransactionType=0 AND ROA.OnAccType=0 AND ROA.RtrId=SI.RtrId
		GROUP BY SI.SalId,SI.SalInvDate,SI.SalInvNo,SI.SalInvRef,SI.SMId,SM.SMName,
		 RE.InvCollectedDate,SI.RtrId,R.RtrName,SI.RMId,RM.RMName,SI.DlvRMId,RMD.RMName,
		 ROA.Amount,RI.InvRcpNo,RI.Remarks 
			) A
	GROUP BY SalId,SalInvDate,SalInvNo,SalInvRef,SMId,SMName,
	 	InvCollectedDate,RtrId,RtrName,RMId,RMName,DlvRMId,DelRMName,SalNetAmt,InvRcpNo,Remarks  
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


DELETE FROM RptExcelHeaders WHERE RptId=4 AND SlNo IN (24,25,26)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) VALUES (4,24,'CollectionDate','Collection Date',1,1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) VALUES (4,25,'CollectedBy','Collected By',1,1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) VALUES (4,26,'Remarks','Remarks',1,1)

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='RptCollectionDetail_Excel')
	BEGIN 
		DROP TABLE RptCollectionDetail_Excel
	END 	
GO
		
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
		AmtStatus 		NVARCHAR(10),
		CollectionDate  DATETIME,
		CollectedBy     NVARCHAR(150),
		Remarks         NVARCHAR(500)    
	)
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptCollectionReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptCollectionReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
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
						BalanceAmount           NUMERIC (38,6),
						CollectedAmount         NUMERIC (38,6),
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
				CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus,CollectionDate,Remarks)
		SELECT  SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
				BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
				ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,
				ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,
				BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,Remarks
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

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
 

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptLoadSheetItemWise]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptLoadSheetItemWise]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptLoadSheetItemWise 18,2,0,'Dabur1',0,0,1
CREATE PROCEDURE [Proc_RptLoadSheetItemWise]
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
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
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
	
	--Filter Variable
	DECLARE @FromDate	   AS	DATETIME
	DECLARE @ToDate	 	   AS	DATETIME
	DECLARE @VehicleId     AS  INT
	DECLARE @VehicleAllocId AS	INT
	DECLARE @SMId	 	AS	INT
	DECLARE @DlvRouteId	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @UOMId	 	AS	INT
	--Till Here
	DECLARE @FromBillNo AS  BIGINT
	DECLARE @TOBillNo   AS  BIGINT	


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
	--Till Here
	DECLARE @RPTBasedON AS INT
	SET @RPTBasedON =0
	SELECT @RPTBasedON = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,257,@Pi_UsrId) 
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	SET @FromBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	--SET @TOBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	
	--Till Here
	CREATE TABLE #RptLoadSheetItemWise
	(
			[SalId]               INT,
			[PrdId]        	      INT,
			[Product Code]        NVARCHAR (20),
			[Product Description] NVARCHAR(50),
			[Batch Number]        NVARCHAR(50),
			[MRP]				  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[NetAmount]			  NUMERIC (38,2)	
	)
	
	SET @TblName = 'RptLoadSheetItemWise'
	
	SET @TblStruct = '	
			[SalId]               INT,
			[PrdId]        	      INT,    	
			[Product Code]        VARCHAR (50),
			[Product Description] VARCHAR(200),
			[Batch Number]        VARCHAR(50),		
			[MRP]				  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[NetAmount]			  NUMERIC (38,2)'
	
	SET @TblFields = '	
			[SalId]
			[PrdId]        	      ,
			[Product Code]        ,
			[Product Description] ,
			[Batch Number]		  ,
			[MRP]				  ,
			[Billed Qty]          ,
			[Free Qty]            ,
			[Return Qty]          ,
			[Replacement Qty]     ,
			[Total Qty],[NetAmount]'
	
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
	INSERT INTO #RptLoadSheetItemWise([SalId],PrdId,[Product Code],[Product Description],[Batch Number],[MRP],
			[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[NetAmount])
	
	SELECT [SalId],PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
	dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId) from RtrLoadSheetItemWise
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
				
     AND (SalId = (CASE @FromBillNo WHEN 0 THEN SalId ELSE 0 END) OR
					SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )	
	 AND [SalInvDate] Between @FromDate and @ToDate
	
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
		
		SET @SSQL = 'INSERT INTO #RptLoadSheetItemWise ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			/*
				Add the Filter Clause for the Reprot
			*/
			 + '         WHERE
			 RptId = ' + @Pi_RptId + ' and UsrId = ' + @Pi_UsrId + ' and
			  (VehicleId = (CASE ' + @VehicleId + ' WHEN 0 THEN VehicleId ELSE 0 END) OR
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptLoadSheetItemWise'
	
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
		SET @SSQL = 'INSERT INTO #RptLoadSheetItemWise ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptLoadSheetItemWise
	-- Till Here
	
	--SELECT * FROM #RptLoadSheetItemWise
-- 	SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],
-- 	SUM(LSB.[Billed Qty]) AS [Billed Qty],SUM(LSB.[Free Qty]) AS [Free Qty],SUM(LSB.[Return Qty]) AS [Return Qty],
-- 	SUM(LSB.[Replacement Qty]) AS [Replacement Qty],SUM(LSB.[Total Qty]) AS [Total Qty],
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Billed Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS BillCase,
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN SUM(LSB.[Billed Qty]) WHEN 1 THEN SUM(LSB.[Billed Qty]) ELSE
-- 	CAST(SUM(LSB.[Billed Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Total Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS TotalCase,
-- 	CASE ISNULL(UG.ConversionFactor,0) 
-- 	WHEN 0 THEN SUM(LSB.[Total Qty]) WHEN 1 THEN SUM(LSB.[Total Qty]) ELSE
-- 	CAST(SUM(LSB.[Total Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS TotalPiece
-- 	FROM #RptLoadSheetItemWise LSB,Product P 
-- 	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
-- 	WHERE LSB.PrdId=P.PrdId
-- 	GROUP BY LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],UG.ConversionFactor
	SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Billed Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS BillCase,
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN SUM(LSB.[Billed Qty]) WHEN 1 THEN SUM(LSB.[Billed Qty]) ELSE
	CAST(SUM(LSB.[Billed Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
	SUM(LSB.[Free Qty]) AS [Free Qty],SUM(LSB.[Return Qty]) AS [Return Qty],
	SUM(LSB.[Replacement Qty]) AS [Replacement Qty],
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Total Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS TotalCase,
	CASE ISNULL(UG.ConversionFactor,0) 
	WHEN 0 THEN SUM(LSB.[Total Qty]) WHEN 1 THEN SUM(LSB.[Total Qty]) ELSE
	CAST(SUM(LSB.[Total Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS TotalPiece,
	SUM(LSB.[Total Qty]) AS [Total Qty],
	SUM(LSB.[Billed Qty]) AS [Billed Qty],
	SUM(NETAMOUNT) as NETAMOUNT
	FROM #RptLoadSheetItemWise LSB,Product P 
	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
	WHERE LSB.PrdId=P.PrdId
	GROUP BY LSB.[Product Description],LSB.[Product Code],LSB.PrdId,LSB.[Batch Number],LSB.[MRP],UG.ConversionFactor
	Order by LSB.[Product Description]
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptLoadSheetItemWise_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptLoadSheetItemWise_Excel
		SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Billed Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS BillCase,
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN SUM(LSB.[Billed Qty]) WHEN 1 THEN SUM(LSB.[Billed Qty]) ELSE
		CAST(SUM(LSB.[Billed Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS BillPiece,
		SUM(LSB.[Free Qty]) AS [Free Qty],SUM(LSB.[Return Qty]) AS [Return Qty],
		SUM(LSB.[Replacement Qty]) AS [Replacement Qty],
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE CAST(SUM(LSB.[Total Qty]) AS INT)/CAST(UG.ConversionFactor AS INT) END AS TotalCase,
		CASE ISNULL(UG.ConversionFactor,0) 
		WHEN 0 THEN SUM(LSB.[Total Qty]) WHEN 1 THEN SUM(LSB.[Total Qty]) ELSE
		CAST(SUM(LSB.[Total Qty]) AS INT)%CAST(UG.ConversionFactor AS INT) END AS TotalPiece,
		SUM(LSB.[Total Qty]) AS [Total Qty],
		SUM(LSB.[Billed Qty]) AS [Billed Qty],
		SUM(NETAMOUNT) as NETAMOUNT
		INTO RptLoadSheetItemWise_Excel FROM #RptLoadSheetItemWise LSB,Product P 
		LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
		WHERE LSB.PrdId=P.PrdId
		GROUP BY LSB.[Product Description],LSB.[Product Code],LSB.PrdId,LSB.[Batch Number],LSB.[MRP],UG.ConversionFactor
		ORDER BY LSB.[Product Description]
	END
	
	IF EXISTS (SELECT * FROM Sysobjects Where Xtype='U' and Name='LoadingSheetSubRpt')
    BEGIN 
		DROP TABLE LoadingSheetSubRpt
	END  
	CREATE TABLE [LoadingSheetSubRpt]
	(
		[BillNo]  NVARCHAR(4000),
		[SalesMan] NVARCHAR(4000)
	) 
	
     INSERT INTO LoadingSheetSubRpt
     SELECT DISTINCT SI.SalInvNo AS BillNo,S.SMName AS SalesMan  FROM #RptLoadSheetItemWise RLS 
     INNER JOIN SalesInvoice SI ON RLS.SalId=SI.SalId
	 INNER JOIN SalesInvoiceProduct SIP ON SIP.SalId = SI.SalId AND RLS.Prdid=SIP.PrdId
     INNER JOIN Salesman S ON S.SMId = SI.SMId
	DECLARE @UpBillNo NVARCHAR(4000)
    DECLARE @BillNo NVARCHAR(4000)
    DECLARE @BillNoCount INT 
    DECLARE @SepCom NVARCHAR(2)
    DECLARE @UpSalesMan NVARCHAR(4000)
    DECLARE @SalesMan NVARCHAR(4000)
    SET @UpBillNo=''
    SET @UpSalesMan=''
	SET @BillNoCount=0
    SET @SepCom=''
	DECLARE Cur_LoadingSheet CURSOR 
	FOR SELECT DISTINCT BillNo FROM LoadingSheetSubRpt ORDER BY BillNo
	OPEN Cur_LoadingSheet
	FETCH NEXT FROM Cur_LoadingSheet INTO @BillNo
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SepCom=''
		IF @UpBillNo<>'' 
			BEGIN 
				SET @SepCom=','
			END 
		SET @UpBillNo=@UpBillNo	+ @SepCom + @BillNo	
        SET @BillNoCount=@BillNoCount+1
        FETCH NEXT FROM Cur_LoadingSheet INTO @BillNo
	END
	UPDATE RptFormula SET FormulaValue=@BillNoCount WHERE RptId=18 AND SlNo=32
	IF @RPTBasedON=0 
		BEGIN 	
			UPDATE RptFormula SET FormulaValue=@UpBillNo    WHERE RptId=18 AND SlNo=33
			UPDATE RptFormula SET FormulaValue='Bill No(s).      :' WHERE RptId=18 AND SlNo=34
		END 
	ELSE
		IF @RPTBasedON=1 
			BEGIN 
				UPDATE RptFormula SET FormulaValue='' WHERE RptId=18 AND SlNo=33
				UPDATE RptFormula SET FormulaValue='' WHERE RptId=18 AND SlNo=34
			END 
    CLOSE Cur_LoadingSheet
	DEALLOCATE Cur_LoadingSheet
RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
 

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

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='RptPendingBillsDetails_Excel')
	BEGIN 
		DROP TABLE RptPendingBillsDetails_Excel
    END 
GO

CREATE TABLE RptPendingBillsDetails_Excel
		(
			SMId 			INT,
			SMName			NVARCHAR(50),
			RMId 			INT,
			RMName 			NVARCHAR(50),
			RtrId         	INT,
			RtrCode			NVARCHAR(100),	
			RtrName 		NVARCHAR(150),	
			SalId         	BIGINT,
			SalInvNo 		NVARCHAR(50),
			SalInvDate      DATETIME,
			SalInvRef 		NVARCHAR(50),
			BillAmount      NUMERIC (38,6),
			CollectedAmount NUMERIC (38,6),
			BalanceAmount   NUMERIC (38,6),
			ArDays			INT
		)
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptPendingBillReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptPendingBillReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptPendingBillReport 3,2,0,'Dabur1',0,0,1
CREATE PROCEDURE [Proc_RptPendingBillReport]
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
	
	DECLARE @AsOnDate	AS	DATETIME
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SalId	 	AS	BIGINT
	DECLARE @PDCTypeId	 	AS	INT
	SELECT @AsOnDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @PDCTypeId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,77,@Pi_UsrId))
	DECLARE @RPTBasedON AS INT
	SET @RPTBasedON =0
	SELECT @RPTBasedON = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,256,@Pi_UsrId) 
	
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@AsOnDate,@AsOnDate)
	Create TABLE #RptPendingBillsDetails
	(
			SMId 			INT,
			SMName			NVARCHAR(50),
			RMId 			INT,
			RMName 			NVARCHAR(50),
			RtrId         		INT,
			RtrName 		NVARCHAR(50),	
			SalId         		BIGINT,
			SalInvNo 		NVARCHAR(50),
			SalInvDate              DATETIME,
			SalInvRef 		NVARCHAR(50),
			CollectedAmount 	NUMERIC (38,6),
			BalanceAmount   	NUMERIC (38,6),
			ArDays			INT,
			BillAmount      	NUMERIC (38,6)
	)
	CREATE TABLE #TempReceiptInvoice
	(
		SalId		INT,
		InvInsSta	INT,
		InvInsAmt	NUMERIC(38,2)
	)
	
	SET @TblName = 'RptPendingBillsDetails'
	
	SET @TblStruct = '	SMId 			INT,
				SMName			NVARCHAR(50),
				RMId 			INT,
				RMName 			NVARCHAR(50),
				RtrId         		INT,
				RtrName 		NVARCHAR(50),	
				SalId         		BIGINT,
				SalInvNo 		NVARCHAR(50),
				SalInvDate              DATETIME,
				SalInvRef 		NVARCHAR(50),
				CollectedAmount 	NUMERIC (38,6),
				BalanceAmount   	NUMERIC (38,6),
				ArDays			INT,
				BillAmount      	NUMERIC (38,6)'
	
	SET @TblFields = 'SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,
			  SalInvDate,SalInvRef,CollectedAmount,
			  BalanceAmount,ArDays,BillAmount'
	IF @Pi_GetFromSnap = 1
	BEGIN
		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
		SET @DBNAME = @DBNAME
	END
	ELSE
	BEGIN
		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo = 3
		SET @DBNAME = @PI_DBNAME + @DBNAME
	END
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	 BEGIN
			IF @PDCTypeId=1 --Include PDC
			BEGIN
				SELECT  SI.SMId,S.SMName,SI.RMId,R.RMName,SI.RtrId,RE.RtrName,SI.SalId,SI.Salinvno,SI.SalinvDate,
						SI.SalInvRef,Cast(null as numeric(18,2))AS PaidAmt,
					    Cast(null as numeric(18,2))AS BalanceAmount ,DATEDIFF(Day,SI.SalInvDate,GetDate()) AS ArDays,SI.SalNetAmt
				 Into #PendingBills1
				 FROM Salesinvoice  SI WITH (NOLOCK),
					  Salesman S WITH (NOLOCK),
					  RouteMaster R WITH (NOLOCK),
					  Retailer RE  WITH (NOLOCK)
				
				 WHERE  SI.SMId = S.SMId  AND SI.RMId = R.RMId
						AND SI.RtrId = RE.RtrId  AND SI.DlvSts IN(4,5)
						AND SI.SalInvDate <= CONVERT(DATETIME,@AsOnDate,103) AND
						(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
						SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
						AND
						(SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
						SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
						AND
						(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
						SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						AND
						(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR
						SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
				UPDATE #PendingBills1
				SET PAIDAMT=isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI, RECEIPT R WHERE RI.INVRCPNO=R.INVRCPNO AND R.INVRCPDATE <=CONVERT(DATETIME,@AsOnDate,103) AND INVRCPMODE=1 and CancelStatus=1  GROUP BY SALID)A
				WHERE #PendingBills1.SALID=a.SALID
				UPDATE #PendingBills1
				SET PAIDAMT=isnull(#PendingBills1.PaidAmt,0)+isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI WHERE INVRCPMODE<>1 and InvInsSta <> 4 GROUP BY SALID)A
				WHERE #PendingBills1.SALID=a.SALID
				Update #PendingBills1
				Set BalanceAmount = SalNetAmt-Isnull(PaidAmt,0)
				
				INSERT INTO #RptPendingBillsDetails
				select * from #pendingbills1
			END
			IF @PDCTypeId<>1 --Exclude PDC
			BEGIN
				SELECT  SI.SMId,S.SMName,SI.RMId,R.RMName,SI.RtrId,RE.RtrName,SI.SalId,SI.Salinvno,SI.SalinvDate,
						SI.SalInvRef,Cast(null as numeric(18,2))AS PaidAmt,
					    Cast(null as numeric(18,2))AS BalanceAmount ,DATEDIFF(Day,SalInvDate,GetDate()) AS ArDays,SI.SalNetAmt
				 Into #PendingBills
				
				 FROM Salesinvoice  SI WITH (NOLOCK),
					  Salesman S WITH (NOLOCK),
					  RouteMaster R WITH (NOLOCK),
					  Retailer RE  WITH (NOLOCK)
				
				 WHERE  SI.SMId = S.SMId  AND SI.RMId = R.RMId
						AND SI.RtrId = RE.RtrId  AND SI.DlvSts IN (4,5)
						and SI.SalInvDate <= CONVERT(DATETIME,@AsOnDate,103) AND
						(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
						SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
						AND
						(SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
						SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
						AND
						(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
						SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						AND
						(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR
						SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
				
				UPDATE #PENDINGBILLS
				SET PAIDAMT=isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI, RECEIPT R WHERE RI.INVRCPNO=R.INVRCPNO AND R.INVRCPDATE <=CONVERT(DATETIME,@AsOnDate,103) AND INVRCPMODE=1 and CancelStatus=1  GROUP BY SALID)A
				WHERE #PENDINGBILLS.SALID=a.SALID
				UPDATE #PENDINGBILLS
				SET PAIDAMT=isnull(#PendingBills.PaidAmt,0)+isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI WHERE INVRCPMODE<>1 AND InvInsDate<=CONVERT(DATETIME,@AsOnDate,103) and InvInsSta <> 4 GROUP BY SALID)A
				WHERE #PENDINGBILLS.SALID=a.SALID
				Update #PendingBills
				Set BalanceAmount = SalNetAmt-Isnull(PaidAmt,0)
				INSERT INTO #RptPendingBillsDetails
				select * from #pendingbills
            END
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptPendingBillsDetails ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+' WHERE (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR' +
				' SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '+
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR ' +
				'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (SalId = (CASE ' + CAST(@SalId AS nVarchar(10)) + ' WHEN 0 THEN SalId ELSE 0 END) OR '+
				'SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',14,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND SalInvDate<=''' + @AsOnDate + ''''
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptPendingBillsDetails'
	
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
		SET @SSQL = 'INSERT INTO #RptPendingBillsDetails ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptPendingBillsDetails
-- Till Here
--	SELECT * FROM #RptPendingBillsDetails ORDER BY SMId,SalId,ArDays,SalInvDate
	--Added by Thiru on 13/11/2009
	DELETE FROM #RptPendingBillsDetails WHERE (BillAmount-CollectedAmount)<=0
	IF @RPTBasedON=1
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays DESC
        END 
	ELSE
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY SMName,RMName,SalInvDate,SalInvNo ASC
        END
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptPendingBillsDetails_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptPendingBillsDetails_Excel
		CREATE TABLE RptPendingBillsDetails_Excel
		(
			SMId 			INT,
			SMName			NVARCHAR(50),
			RMId 			INT,
			RMName 			NVARCHAR(50),
			RtrId         	INT,
			RtrCode			NVARCHAR(100),	
			RtrName 		NVARCHAR(150),	
			SalId         	BIGINT,
			SalInvNo 		NVARCHAR(50),
			SalInvDate      DATETIME,
			SalInvRef 		NVARCHAR(50),
			BillAmount      NUMERIC (38,6),
			CollectedAmount NUMERIC (38,6),
			BalanceAmount   NUMERIC (38,6),
			ArDays			INT
		)
		INSERT INTO RptPendingBillsDetails_Excel( SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,
			  SalInvDate,SalInvRef,BillAmount,CollectedAmount,
			  BalanceAmount,ArDays)
		  SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,
			  SalInvDate,SalInvRef,BillAmount,CollectedAmount,
			  BalanceAmount,ArDays FROM  #RptPendingBillsDetails	
	   
		UPDATE RPT SET RPT.[RtrCode]=R.RtrCode FROM RptPendingBillsDetails_Excel RPT,Retailer R WHERE RPT.[RtrName]=R.RtrName
	END
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[View_BankSlip]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[View_BankSlip]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
				
CREATE VIEW [View_BankSlip] 
AS
SELECT RI.BnkId as RtrBankId,B.BnkName as RtrBnkName,RI.BnkBrID As RtrBnkBrId,
		D.BnkBrName as RtrBnkBrname,RI.DisBnkId , RI.DisBnkBrId as DisBranchId,
		R.RtrName  As DistributorBnkName,SAI.SalInvNo as DistributorBnkBrName,
		G.AccId,G.AcNo as AccountNo,RI.InvinsNo,RI.InvInsDate,
		RI.InvDepDate ,RI.InvInsSta,RI.SalInvAmt,RI.Penalty 
		From ReceiptInvoice RI
	LEFT OUTER JOIN Bank B ON B.BnkId=RI.BnkId 
	LEFT OUTER JOIN BankBranch D ON D.BnkBrId=RI.BnkBrId 
    INNER JOIN SalesInvoice SAI ON SAI.SalId=RI.SalId
    INNER JOIN Retailer R ON R.RtrId = SAI.RtrId
	INNER JOIN Bank E ON E.BnkId=RI.DisBnkId
	INNER JOIN BnkAcNo G ON G.BNKBRID=RI.DisBnkBrId
	INNER JOIN BankBranch F ON F.BnkBrId=RI.DisBnkBrId AND F.DistBank=1
	WHERE  RI.InvRcpMode=3 AND RI.InvInsSta IN(0,1) AND RI.CancelStatus=1

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

UPDATE RptExcelHeaders SET DisplayFlag=1,DisplayName='Invoice No' WHERE RptId=53 AND SlNo=8


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBankSlipReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBankSlipReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

---EXEC Proc_RptBankSlipReport 53,2,0,'Dabur1',0,0,1
CREATE PROCEDURE [Proc_RptBankSlipReport]
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

DELETE FROM RptDetails WHERE RptId=24 AND SlNo IN (5,6,7)
INSERT INTO RptDetails VALUES (24,5,'ProductCategoryLevel',3,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,NULL,'Press F4/Double Click to select Product Hierarchy Level',1)
INSERT INTO RptDetails VALUES (24,6,'ProductCategoryValue',5,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,NULL,NULL,'Press F4/Double Click to select Product Hierarchy Level Value',0)
INSERT INTO RptDetails VALUES (24,7,'Product',6,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,0,NULL,'Press F4/Double click to select Product',0)

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptProductPurchase]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptProductPurchase]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--  exec [Proc_RptProductPurchase] 24,2,0,'Henkel',0,0,1
CREATE PROCEDURE [Proc_RptProductPurchase]
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

UPDATE RptExcelHeaders SET DisplayName='Company Scheme Code',DisplayFlag=1 WHERE RptId=15 AND SlNo=2
  
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptSchemeUtilization]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptSchemeUtilization]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

UPDATE RptExcelHeaders SET DisplayName='Company Scheme Code',DisplayFlag=1 WHERE RptId=152 AND SlNo=2

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptSchemeUtilizationWithOutPrimary]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptSchemeUtilizationWithOutPrimary]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-230-016-From Kalai

if not exists (Select Id,name from Syscolumns where name = 'RcpType' and id in (Select id from 
	Sysobjects where name ='Receipt'))
begin
	ALTER TABLE [dbo].[Receipt]
	ADD [RcpType] TINYINT NOT NULL DEFAULT 0 WITH VALUES
END
GO

UPDATE HotSearchEditorHd SET RemainsltString=' SELECT InvRcpNo,InvRcpDate,InvRcpAmt,CollectedById,CollectedMode,InvCollectedDate,RcpType FROM     (SELECT  DISTINCT RC.InvRcpNo,RC.InvRcpDate,RC.InvRcpAmt,RC.CollectedById,  RC.CollectedMode ,RC.InvCollectedDate,RC.RcpType  FROM Receipt RC WITH (NOLOCK) ,ReceiptInvoice RI WITH (NOLOCK)   WHERE RC.InvRcpNo = RI.InvRcpNo   AND RI.CancelStatus = 1  UNION   SELECT  DISTINCT RC.InvRcpNo,RC.InvRcpDate,RC.InvRcpAmt,RC.CollectedById,  RC.CollectedMode,RC.InvCollectedDate,RC.RcpType FROM Receipt RC WITH (NOLOCK) ,DebitInvoice RI WITH (NOLOCK)    WHERE RC.InvRcpNo = RI.InvRcpNo AND RI.CancelStatus = 1  )  MainQry'
where formid=646 and ControlName='ReceiptVoucher'


if not exists (Select Id,name from Syscolumns where name = 'Remarks' and id in (Select id from 
	Sysobjects where name ='ReceiptInvoice'))
begin
	ALTER TABLE [dbo].[ReceiptInvoice]
	ADD [Remarks] NVarchar(500)
END

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

INSERT INTO CustomCaptions VALUES (9,31,25,'DgCommon-9-31-25','Debit No','','',1,1,1,'2008-03-19',1,'2008-03-19','Debit No','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,26,'DgCommon-9-31-26','Debit Amt','','',1,1,1,'2008-03-19',1,'2008-03-19','Debit Amt','','',1,1)
INSERT INTO CustomCaptions VALUES (9,31,27,'DgCommon-9-31-27','Adj Amt','','',1,1,1,'2008-03-19',1,'2008-03-19','Adj Amt','','',1,1)


DELETE  FROM Configuration WHERE ModuleName LIKE 'Collection Register%' AND ModuleId IN ('COLL13','COLL14','COLL15')
INSERT INTO Configuration VALUES ('COLL13','Collection Register','Display Remarks Column in Collection Register Screen',0,'',0.00,13)
INSERT INTO Configuration VALUES ('COLL14','Collection Register','ExcessCollection',	1,	0,	NULL,	15)
INSERT INTO Configuration VALUES ('COLL15','Collection Register','Perform Account Posting for Cheques',0,'',NULL,15)




if not exists (Select Id,name from Syscolumns where name = 'RcpType' and id in (Select id from 
	Sysobjects where name ='Receipt'))
begin
	ALTER TABLE [dbo].[Receipt]
	ADD [RcpType] TINYINT NOT NULL DEFAULT 0 WITH VALUES
END
GO

UPDATE HotSearchEditorHd SET RemainsltString=' SELECT InvRcpNo,InvRcpDate,InvRcpAmt,CollectedById,CollectedMode,InvCollectedDate,RcpType FROM     (SELECT  DISTINCT RC.InvRcpNo,RC.InvRcpDate,RC.InvRcpAmt,RC.CollectedById,  RC.CollectedMode ,RC.InvCollectedDate,RC.RcpType  FROM Receipt RC WITH (NOLOCK) ,ReceiptInvoice RI WITH (NOLOCK)   WHERE RC.InvRcpNo = RI.InvRcpNo   AND RI.CancelStatus = 1  UNION   SELECT  DISTINCT RC.InvRcpNo,RC.InvRcpDate,RC.InvRcpAmt,RC.CollectedById,  RC.CollectedMode,RC.InvCollectedDate,RC.RcpType FROM Receipt RC WITH (NOLOCK) ,DebitInvoice RI WITH (NOLOCK)    WHERE RC.InvRcpNo = RI.InvRcpNo AND RI.CancelStatus = 1  )  MainQry'
where formid=646 and ControlName='ReceiptVoucher'

--SRF-Nanda-230-017-From Kalai

DELETE FROM Configuration WHERE ModuleId='PURCHASERECEIPT26'
INSERT INTO Configuration
SELECT 'PURCHASERECEIPT26','Purchase Receipt','Display MRP column in Purchase Receipt Screen',1,'',0,26

if not exists (select * from hotfixlog where fixid = 373)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(373,'D','2011-04-11',getdate(),1,'Core Stocky Service Pack 373')
