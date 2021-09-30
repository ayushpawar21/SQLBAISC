--[Stocky HotFix Version]=416
DELETE FROM Versioncontrol WHERE Hotfixid='416'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('416','3.1.0.0','D','2014-07-17','2014-07-17','2014-07-17',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
IF EXISTS (SELECT * FROM Sys.objects WHERE name='Proc_GetStockNSalesDetails' AND TYPE='P')
DROP PROCEDURE Proc_GetStockNSalesDetails
GO
--SELECT * FROM StockLedger  
--SELECT * FROM Product   
--Exec Proc_GetStockNSalesDetails '2011/04/05','2011/04/05',2  
--SELECT * FROM TempRptStockNSales WHERE PrdId=242  
CREATE PROCEDURE Proc_GetStockNSalesDetails 
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
* 01-07-2013	Mohana S		Stockledger query has  been optimized and using hash table. PMS NO:ICRSTPAR0194
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
 
	SELECT * INTO #STOCKLEDGER FROM STOCKLEDGER (NOLOCK) WHERE TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate	--ICRSTPAR0194

	INSERT INTO @ProdDetail  
	(  
		LcnId,PrdBatId,TransDate  
	)  
	SELECT LcnId,PrdBatId,MAX(TransDate) FROM StockLedger A(nolock) WHERE TransDate <@Pi_FromDate AND NOT EXISTS 
	(SELECT 'X' FROM #StockLedger WHERE LcnId = A.LcnId AND  PrdId = A.PrdId AND PrdBatId = A.PrdBatId)
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
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME ='Proc_GetStockNSalesDetailsWithOffer' AND XTYPE='P')
DROP PROCEDURE Proc_GetStockNSalesDetailsWithOffer
GO
--SELECT * FROM StockLedger
--Exec Proc_GetStockNSalesDetails '2008/05/28','2006/05/28',1
--SELECT * FROM TempRptStockNSales WHERE PrdId=2
CREATE PROCEDURE Proc_GetStockNSalesDetailsWithOffer
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
* {date}		 {developer}	 {brief modification description}
* 01-07-2013	Mohana S		Stockledger query has  been optimized and using hash table. PMS NO:ICRSTPAR0194
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
	
	SELECT * INTO #STOCKLEDGER FROM STOCKLEDGER (NOLOCK) WHERE TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate	--ICRSTPAR0194

	INSERT INTO @ProdDetail  
	(  
		LcnId,PrdBatId,TransDate  
	)  
	SELECT LcnId,PrdBatId,MAX(TransDate) FROM StockLedger A(nolock) WHERE TransDate <@Pi_FromDate AND NOT EXISTS 
	(SELECT 'X' FROM #StockLedger WHERE LcnId = A.LcnId AND  PrdId = A.PrdId AND PrdBatId = A.PrdBatId)
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
--Praveen CR
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptGridView')
DROP TABLE RptGridView
GO
CREATE TABLE RptGridView
(
  RptId NUMERIC(18,0),
  RptName NVARCHAR(200),
  CrystalView TINYINT,
  GridView TINYINT,
  ExcelView TINYINT,
  PDFView  TINYINT
)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_TruncateTempTable')
DROP PROCEDURE Proc_TruncateTempTable
GO
CREATE PROCEDURE Proc_TruncateTempTable
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
    ('RptDetails','RptGroup','RptFilter','RptHeader','RptSelectionHd','RptFormula','RptGridView',
     'Rpt_Udc_Details','Rpt_Udc_Group','Rpt_Udc_Filter','Rpt_Udc_Header','Rpt_Udc_SelectionHd','Rpt_Udc_Formula','RptExcelHeaders')
    
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
UPDATE RptGridView SET PDFView=1 WHERE RPTID IN (277,278,279,280)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnRptPDFView')
DROP FUNCTION Fn_ReturnRptPDFView
GO
--SELECT DBO.Fn_ReturnRptPDFView(1) PDF
CREATE FUNCTION Fn_ReturnRptPDFView (@Pi_RptId INT)
RETURNS TINYINT
AS
/************************************************************
* PROCEDURE	: Fn_ReturnRptPDFView
* PURPOSE	: To Return PDF Reports
* CREATED BY	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 01-07-2014
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
BEGIN
		DECLARE @PDFRPT TINYINT
		SET @PDFRPT=0
		IF EXISTS (SELECT TOP 1 * FROM RptGridView WHERE RptId=@Pi_RptId AND PDFView=1)
		BEGIN
			SET @PDFRPT=1
		END
RETURN @PDFRPT
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND name='Fn_ReturnRptFiltersValue')
DROP FUNCTION Fn_ReturnRptFiltersValue
GO
CREATE FUNCTION [dbo].[Fn_ReturnRptFiltersValue]
(
	@iRptid INT,
	@iSelid INT,
	@iUsrId INT
)
RETURNS nVarChar(1000)
AS
/*********************************
* FUNCTION: Fn_ReturnRptFiltersValue
* PURPOSE: Returns the Filters Value For the Selected Report and Selection Id
* NOTES: 
* CREATED: Thrinath Kola	31-07-2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 
*********************************/
BEGIN
	DECLARE @iCnt 		AS	INT
	DECLARE @SCnt 		AS      NVARCHAR(1000)
	DECLARE	@ReturnValue	AS	nVarchar(1000)
	DECLARE @iRtr 		AS	INT
	SELECT @iCnt = Count(*) FROM ReportFilterDt WHERE Rptid= @iRptid AND
	SelId = @iSelid AND usrid = @iUsrId
	IF @iCnt > 1
	BEGIN
		IF @iSelid=3 AND ( @iRptid=1 OR @iRptid=2 OR @iRptid=3 OR @iRptid=4 OR @iRptid=9 OR @iRptid=17 OR @iRptid=18
		OR @iRptid=19 OR @iRptid=30 OR @iRptid=12 ) 
		BEGIN
			SELECT @iRtr=SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND
			SelId = 215 AND Usrid = @iUsrId
			IF @iRtr>0 
			BEGIN
				SELECT @iRtr=COUNT(*) FROM ReportFilterDt WHERE Rptid= @iRptid AND
				SelId = @iSelid AND Usrid = @iUsrId AND SelValue  IN
				(SELECT SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND
				SelId = 215 AND Usrid = @iUsrId
				)
				IF @iRtr>0  
				BEGIN
					SET @ReturnValue = 'ALL'
				END
				ELSE
				BEGIN
					SET @ReturnValue = 'Multiple'
				END 
			END
			ELSE
			BEGIN
				SET @ReturnValue = 'Multiple'
			END
		END
		--Praveenraj B For Parle Salesman Multiple Selection
		 Else if @iCnt>1 And @iSelid=1   
		 Begin  
		 Set @ReturnValue=''
		  Select  @ReturnValue=@ReturnValue+SMName+',' From Salesman Where SMId In (SELECT Top 4 SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND    
			SelId =1 AND Usrid = @iUsrId  )   
			SET @ReturnValue=LEFT(@ReturnValue,LEN(@ReturnValue)-1)
		 End
		 
   --Till Here
   -->Added By Mohana For Parle Multiple Route Selection
--		Else if @iCnt>1 And @iSelid IN (2,35) AND @iRptid IN (3,242)
-->Added By Aravindh Deva C For Parle Multiple Route Selection for the reports 17,18,19
		ELSE IF @iCnt>1 And @iSelid IN (2,35) AND @iRptid IN (3,242,17,18,19)		
		 BEGIN  
		 SET @ReturnValue=''
		  SELECT  @ReturnValue=@ReturnValue+RMname+',' From RouteMaster  Where rmid In (SELECT Top 5 SelValue FROM ReportFilterDt WHERE Rptid=@iRptid AND    
			SelId IN (2,35) AND Usrid = @iUsrId  )
			SET @ReturnValue=LEFT(@ReturnValue,LEN(@ReturnValue)-1)   
		 END
	-->Till Here   
		ELSE
		BEGIN
			SET @ReturnValue = 'Multiple'
		END 
	END
	ELSE
	BEGIN
		--->Added By Nanda on 25/03/2011-->(Same Selection Id is used for Collection Report-Show Based on with Suppress Zero Stock)
		IF @iSelid=44 AND (@iRptid<>4)
		BEGIN
			SELECT @ReturnValue = ISNULL(FilterDesc,'') FROM RptFilter WHERE FilterId IN 
			( 
				SELECT SelValue FROM ReportFilterDt WHERE RptId=@iRptid AND SelId=@iSelid AND usrid = @iUsrId
			)
			AND RptId=@iRptid AND SelcId=@iSelid		
		END
		ELSE IF @iSelid=289 OR @iSelid=290 -- Moorthi For Nivea Filter (Delivered,Undelivered,Cancelled Bills)
		BEGIN
			SELECT @ReturnValue = ISNULL(FilterDesc,'') FROM RptFilter WHERE FilterId IN 
			( 
				SELECT SelValue FROM ReportFilterDt WHERE RptId=@iRptid AND SelId=@iSelid AND usrid = @iUsrId
			)
			AND RptId=@iRptid AND SelcId=@iSelid		
		END
		ELSE IF @iRptid=277 AND @iSelid=314
		 BEGIN
			Set @ReturnValue=''
			SELECT  @ReturnValue=R.FilterDesc FROM ReportFilterDt RD
			INNER JOIN RptFilter R ON RD.RptId=R.RptId AND RD.SelId=R.SelcId AND RD.SelValue=R.FilterId
			WHERE RD.Rptid= @iRptid AND R.SelcId = @iSelid AND RD.UsrId = @iUsrId
		 END
		--->Till Here
		ELSE
		BEGIN
			If @iSelid <> 10 AND @iSelid <> 11  And @iSelid <>66 and @iSelid<>64 AND @iSelid <> 13 AND @iSelid <> 20 
			AND @iSelid <> 102 AND @iSelid <> 103 AND @iSelid <> 105  AND @iSelid <> 108 AND @iSelid <> 115 AND @iSelid <> 117 AND 
			@iSelid <> 119 AND @iSelid <> 126  AND @iSelid <> 139 AND @iSelid <> 140 AND @iSelid <> 152 AND @iSelid <> 157 AND @iSelid <> 158 AND @iSelid <> 161 
			AND @iSelid <> 163 AND @iSelid <> 165 AND @iSelid <> 171  AND @iSelid <> 173 AND @iSelid <> 174 AND @iSelid <> 180 AND @iSelid <> 181
			AND @iSelid <> 195 AND @iSelid <> 199 AND @iSelid <> 201 AND @iSelid <> 278 AND @iSelid <> 275
			BEGIN			
				SELECT @iCnt = SelValue From ReportFilterDt Where Rptid= @iRptid AND
				SelId = @iSelid AND usrid = @iUsrId			
				
				IF @iCnt = 0
				BEGIN
					IF @iSelid=53 and (@iRptid=43 Or @iRptid=44)
					BEGIN
						IF Not Exists(SELECT * FROM ReportFilterDt WHERE Rptid In(43,44) and Selid=54)
						BEGIN
							SELECT @iCnt = SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND
							SelId = 55 AND usrid = @iUsrId
							SELECT @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,@iUsrId)
						END
						ELSE
						BEGIN
							SELECT @iCnt = SelValue From ReportFilterDt Where Rptid= @iRptid AND
							SelId = 54 AND usrid = @iUsrId
							SELECT @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,@iUsrId)
						END
					END
					ELSE 
					BEGIN
						SET @ReturnValue = 'ALL'
					END
				END
				ELSE
				BEGIN
					If @iSelid=232 
					BEGIN
						Select @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,@iUsrId)
					END
					ELSE
					BEGIN
						Select @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,2)
					END
			   END
			END
			ELSE
			BEGIN	
				If @iSelid=10 or @iSelid=11	or @iSelid=20 or @iSelid=13 or @iSelid=139 or @iSelid=140
				BEGIN
					SELECT @ReturnValue = Convert(nVarChar(10),FilterDate,121) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId
				End
				If  @iSelid=66 
				BEGIN
					SELECT @ReturnValue = Cast(SelValue as VarChar(20)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End
				If  @iSelid=64
					BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(20)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				If  @iSelid=115 
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				If  @iSelid=152 
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End			
				If  @iSelid=157 or @iSelid=158
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				If  @iSelid=161
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End
				If  @iSelid=199
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				IF @iSelid=102 OR @iSelid=103 OR @iSelid=105 OR  @iSelid=108 OR @iSelid = 117 OR @iSelid = 119 OR @iSelid = 126 OR @iSelid = 159 OR @iSelid = 163  OR @iSelid = 165 OR @iSelid = 180 OR @iSelid = 181
				OR @iSelid = 173 OR @iSelid = 174 OR @iSelid=195 OR @iSelid=201 OR @iSelid = 171 OR @iSelid = 278 OR @iSelid = 275
				BEGIN
					SELECT @SCnt = NULLIF(ISNULL(SelDate,'0'),SelDate) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId
					IF @SCnt='0' 
					BEGIN
						Set @ReturnValue = 'ALL'
					END 
					ELSE
					BEGIN
						SELECT @ReturnValue = Cast(SelDate as VarChar(20)) From ReportFilterDt Where Rptid= @iRptid AND
						SelId = @iSelid AND usrid = @iUsrId	
					END
				END			
			END	
		END			
	END
	RETURN(@ReturnValue)
END
GO
DELETE FROM RptSelectionHd WHERE SelcId=314
INSERT INTO RptSelectionHd (SelcId,SelcName,TblName,Condition)
SELECT 314,'Sel_RptType_TaxRpt','RptType',1
GO
DELETE FROM RptGroup WHERE RptId=276
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',276,'UPVATXXIVReport','UPVATXXIVReport',1
GO
DELETE FROM RptHeader WHERE RptId=276
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'UPVATXXIVReport','UPVAT XXIV Report',276,'UPVATXXIVReport','PROC_SalesTax_UPVAT','Rpt_SalesTax_UPVAT','RptSalesTaxUPVAT.rpt',''
GO
DELETE FROM RptDetails WHERE RptId=276
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (276,1,'FromDate',-1,'','','From Date*','',1,'',10,0,0,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (276,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (276,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,0,'Press F4/Double Click to Select Company',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (276,4,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Display O/P For*...','',1,'',314,1,1,'Press F4/Double Click to Select Display O/P For',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (276,5,'Supplier',-1,'','SpmId,SpmCode,SpmName','Supplier...','',1,'',9,1,0,'Press F4/Double Click to Select Supplier',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (276,6,'PurchaseReceipt',-1,'','PurRcptId,CmpInvNo,PurRcptRefNo','Transaction Reference No...','',1,'',194,0,0,'Press F4/Double Click to Select Company Transaction Reference No',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (276,7,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Retailer TaxType...','',1,'',200,1,0,'Press F4/Double Click to Select Retailer TaxType For Sales',0)
GO
DELETE FROM RptFilter WHERE RptId=276 AND SelcID=200
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (276,200,0,'ALL')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (276,200,1,'VAT')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (276,200,2,'NON VAT')
GO
DELETE FROM RptFilter WHERE RptId=276 AND SelcId = 314
INSERT INTO RptFilter (RptId,SelcId,FilterId,FilterDesc)
SELECT 276,314,1,'Sale in Own Account'
--UNION
--SELECT 276,314,2,'Sale in Commission Account'
UNION
SELECT 276,314,3,'Purchase in Own Account'
GO
DELETE FROM RptFormula WHERE RptId=276
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 276,1,'Disp_FromDate','FromDate',1,0
UNION
SELECT 276,2,'Print_FromDate','FromDate',1,10
UNION
SELECT 276,3,'Disp_ToDate','ToDate',1,0
UNION
SELECT 276,4,'Print_ToDate','ToDate',1,11
UNION
SELECT 276,5,'Disp_Company','Company',1,0
UNION
SELECT 276,6,'Print_Company','Company',1,4
UNION
SELECT 276,7,'Disp_Supplier','Supplier',1,0
UNION
SELECT 276,8,'Print_Supplier','Supplier',1,9
UNION
SELECT 276,9,'Disp_RefNo','RefNo',1,0
UNION
SELECT 276,10,'Print_RefNo','RefNo',1,194
UNION
SELECT 276,11,'Disp_Output','Output',1,0
UNION
SELECT 276,12,'Print_Output','Output',1,314
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='PROC_SalesTax_UPVAT')
DROP PROCEDURE PROC_SalesTax_UPVAT
GO
--EXEC PROC_SalesTax_UPVAT 276,2,0,'PARLE',0,0,1
CREATE PROCEDURE PROC_SalesTax_UPVAT
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
		--SELECT 'Purchase in Own Account' RptHeader,D.DistributorName,@Year AssesmentYear,@ACENDDATE TaxPeriodEnds,D.DistributorAdd1,D.DistributorAdd2,
		--D.DistributorAdd3,D.TinNo,S.SpmId,S.SpmName,S.SpmTinNo,P.PurRcptId,P.PurRcptRefNo,P.GoodsRcvdDate,'' NameOfCommodity,'' CodeOfCommodity,
		--SUM(PR.InvBaseQty) Quantity,SUM(PRT.TaxableAmount) TaxableAmount,PRT.TaxPerc,SUM(PRT.TaxAmount) TaxAmount,0 SAT,0 SATAmt,SUM(PR.PrdNetAmount) TotalAmt,0,1
		--FROM #PurchaseReceipt P (NOLOCK)
		--INNER JOIN #PurchaseReceiptProduct PR (NOLOCK) ON P.PurRcptId=PR.PurRcptId
		--INNER JOIN #PurchaseReceiptProductTax PRT (NOLOCK)  ON P.PurRcptId=PRT.PurRcptId AND PR.PurRcptId=PRT.PurRcptId AND PR.PrdSlNo=PRT.PrdSlNo
		--INNER JOIN Supplier S (NOLOCK) ON S.SpmId=P.SpmId
		--CROSS JOIN Distributor D (NOLOCK)
		--GROUP BY D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3,D.TinNo,S.SpmId,S.SpmName,
		--S.SpmTinNo,P.PurRcptId,P.PurRcptRefNo,P.GoodsRcvdDate,TaxPerc
	END
	--ELSE
	--BEGIN
	--	INSERT INTO #Rpt_SalesTax_UPVAT (RptHeader,NameOfPurchaseDealer,AssesmentYear,TaxPeriodEnds,NameOfPurchaseDealerAdd1,
	--									NameOfPurchaseDealerAdd2,NameOfPurchaseDealerAdd3,NameOfPurchaseDealerTinNo,RtrId,NameOfPurchaseDealerDt,
	--									TinNo,SalId,TaxInvoiceNo,TaxInvoiceDate,NameOfCommodity,CodeOfCommodity,Quantity,TaxableAmt,Tax,TaxAmt,SAT,
	--									SATValue,TOTALAmt,RptId,UsrId)
	--	SELECT 'Sale in Commission Account' RptHeader,D.DistributorName,@Year AssesmentYear,@ACENDDATE TaxPeriodEnds,D.DistributorAdd1,D.DistributorAdd2,
	--	D.DistributorAdd3,D.TinNo,0 RtrId,'' RtrName,0 RtrTinNo,0 SalId,'' SalInvNo,'' SalInvDate,'' NameOfCommodity,'' CodeOfCommodity,
	--	0 Quantity,0 TaxableAmount,0 TaxPerc,0 TaxAmount,0 SAT,0 SATAmt,0 TotalAmt,0,1
	--	FROM Distributor D (NOLOCK)
	--END
	

	
	
	DELETE FROM RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM #Rpt_SalesTax_UPVAT
	SELECT * FROM #Rpt_SalesTax_UPVAT ORDER BY SlNo
	
	IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='Rpt_SalesTax_UPVAT_SubRpt')
	DROP TABLE Rpt_SalesTax_UPVAT_SubRpt
	CREATE TABLE Rpt_SalesTax_UPVAT_SubRpt
		(
			SlNo						NUMERIC(38,0) IDENTITY (1,1),
			TaxName						VARCHAR(25),
			TaxableAmt					NUMERIC(38,6),
			Tax							NUMERIC(18,2),
			TaxAmt						NUMERIC(38,6),
			TOTALAmt					NUMERIC(38,6)
		)
	INSERT INTO Rpt_SalesTax_UPVAT_SubRpt(TaxName,TaxableAmt,Tax,TaxAmt,TOTALAmt)
	SELECT 'TAX TOTAL '+ CAST(SAT AS VARCHAR(10)),0 TaxableAmt,SAT,SUM(SATValue) TaxAmt,
								0 ToTALAmt FROM #Rpt_SalesTax_UPVAT
	GROUP BY SAT
	
	INSERT INTO Rpt_SalesTax_UPVAT_SubRpt(TaxName,TaxableAmt,Tax,TaxAmt,TOTALAmt)
	SELECT 'TAX TOTAL '+ CAST(Tax AS VARCHAR(10)),SUM(TaxableAmt) TaxableAmt,Tax,SUM(TaxAmt) TaxAmt,
								SUM(TOTALAmt) ToTALAmt FROM #Rpt_SalesTax_UPVAT
	GROUP BY Tax
	
	DELETE FROM Rpt_SalesTax_UPVAT_SubRpt WHERE TaxableAmt<=0 AND TaxAmt<=0
	RETURN
END
GO
DELETE FROM RptGroup WHERE RptId=277
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',277,'GUJVAT201Report','GUJVAT201Report',1
GO
DELETE FROM RptHeader WHERE RptId=277
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'GUJVAT201Report','Guj govt VAT report',277,'Guj govt VAT report','Proc_RptGujVAT201A','RptGujVAT201A','RptGujVAT201A.rpt',''
GO
DELETE FROM RptDetails WHERE RptId=277
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (277,1,'FromDate',-1,'','','From Date*','',1,'',10,0,0,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (277,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (277,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,0,'Press F4/Double Click to Select Company',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (277,4,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Display O/P For*...','',1,'',314,1,1,'Press F4/Double Click to Select Display O/P For',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (277,5,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Retailer TaxType...','',1,'',200,1,0,'Press F4/Double Click to Select Retailer TaxType For sales',0)
GO
DELETE FROM RptFilter WHERE RptId=277 AND SelcID=200
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (277,200,0,'ALL')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (277,200,1,'VAT')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (277,200,2,'NON VAT')
GO
DELETE FROM RptFilter WHERE RptId=277 AND SelcId = 314
INSERT INTO RptFilter (RptId,SelcId,FilterId,FilterDesc)
SELECT 277,314,1,'Sales'
UNION
SELECT 277,314,2,'Purchase'
GO
DELETE FROM RptFormula WHERE RptId=277
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 277,1,'Disp_FromDate','FromDate',1,0
UNION
SELECT 277,2,'Print_FromDate','FromDate',1,10
UNION
SELECT 277,3,'Disp_ToDate','ToDate',1,0
UNION
SELECT 277,4,'Print_ToDate','ToDate',1,11
UNION
SELECT 277,5,'Disp_Company','Company',1,0
UNION
SELECT 277,6,'Print_Company','Company',1,4
UNION
SELECT 277,7,'Disp_Output','Output',1,0
UNION
SELECT 277,8,'Print_Output','Output',1,314
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptGujVAT201A')
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
			WHERE T.TaxableAmount>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode)))='ADDVAT'
		
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
			WHERE PRT.TaxableAmount>0 AND LTRIM(RTRIM(UPPER(TC.TaxCode)))='ADDVAT'
			
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND name='ClosingStock_FORVAT203B')
DROP TABLE ClosingStock_FORVAT203B
GO
CREATE TABLE ClosingStock_FORVAT203B
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[StkMonth] [nvarchar](50) NULL,
	[StkYear] [int] NULL,
	[PrdCode] [nvarchar](100) NULL,
	[PrdName] [nvarchar](100) NULL,
	[PrdBatchCode] [nvarchar](100) NULL,
	[MRP] [numeric](36, 6) NULL,
	[CLP] [numeric](36, 6) NULL,
	[OpeningSales] [numeric](36, 0) NULL,
	[OpeningUnSaleable] [numeric](36, 0) NULL,
	[OpenignOffer] [numeric](36, 0) NULL,
	[PurchaseSales] [numeric](36, 0) NULL,
	[PurchaseUnSaleable] [numeric](36, 0) NULL,
	[PurchaseOffer] [numeric](36, 0) NULL,
	[InvoiceSales] [numeric](36, 0) NULL,
	[InvoiceUnSaleable] [numeric](36, 0) NULL,
	[InvoiceOffer] [numeric](36, 0) NULL,
	[SalPurReturn] [numeric](18, 0) NULL,
	[UnsalPurReturn] [numeric](18, 0) NULL,
	[OfferPurReturn] [numeric](18, 0) NULL,
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
	[ClosingSales] [numeric](36, 0) NULL,
	[ClosingUnSaleable] [numeric](36, 0) NULL,
	[ClosingOffer] [numeric](36, 0) NULL,
	[SecondarySales] [numeric](36, 6) NULL,
	[LastInvoiceNumber] [varchar](50) NULL,
	[LastInvoiceDate] [datetime] NULL,
	[StockInTrans] [numeric](36, 0) NULL,
	[UploadFlag] [nvarchar](1) NULL,
	[SamplePurchase] [numeric](18, 0) NULL,
	[SampleSales] [numeric](18, 0) NULL,
	[SampleFreeSales] [numeric](18, 0) NULL,
	[SampleSalesReturn] [numeric](18, 0) NULL,
	UsrId	[Int]
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_ClosingStock_FORVAT203B')
DROP PROCEDURE Proc_ClosingStock_FORVAT203B
GO
--EXEC Proc_ClosingStock_FORVAT203B '2014-06-01','2014-06-26',2
--SELECT * FROM ClosingStock_FORVAT203B WHERE PrdCode='BSFCCA5L1'
CREATE PROCEDURE Proc_ClosingStock_FORVAT203B
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate   DATETIME,
	@Pi_UsrId	 INT
)
AS
/*********************************
* PROCEDURE	: Proc_ClosingStock_FORVAT203B
* PURPOSE	: To Get Stock Ledger Detail
* CREATED	: Murugan.R
* CREATED DATE	: 17/09/2013
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
    

	DELETE A FROM ClosingStock_FORVAT203B A (NOLOCK) WHERE UsrId=@Pi_UsrId
		CREATE TABLE #ClosingStock_FORVAT203B
		(
			Transdate Datetime,
			[PrdId] [int] NULL,
			[PrdCode] [nvarchar](100)  COLLATE DATABASE_DEFAULT,
			[PrdName] [nvarchar](100)  COLLATE DATABASE_DEFAULT,
			[PrdBatId] [int] NULL,
			[PrdBatchCode] [nvarchar](100)  COLLATE DATABASE_DEFAULT,
			[MRP] Numeric(36,6),
			[CLP] Numeric (36,6),
			OpeningSales Numeric(36,0),
			OpeningUnSaleable Numeric(36,0),
			OpenignOffer Numeric(36,0),
			PurchaseSales	Numeric(36,0),
			PurchaseUnSaleable Numeric(36,0),
			PurchaseOffer Numeric(36,0),
			InvoiceSales Numeric(36,0),
			InvoiceUnSaleable Numeric(36,0),
			InvoiceOffer Numeric(36,0),
			[SalPurReturn] [numeric](18, 0) NULL,
			[UnsalPurReturn] [numeric](18, 0) NULL,
			[OfferPurReturn] [numeric](18, 0) NULL,
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
			ClosingSales Numeric(36,0),
			ClosingUnSaleable Numeric(36,0),
			ClosingOffer Numeric(36,0),
			SecondarySales  Numeric(36,6),
			LastInvoiceNumber Varchar(50),
			LastInvoiceDate Datetime,
			StockInTrans Numeric(36,0),
			/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 begins*/
			SamplePurchase	[numeric](18, 0) NULL,
			SampleSales		[numeric](18, 0) NULL,
			SampleFreeSales	[numeric](18, 0) NULL,
			SampleSalesReturn	[numeric](18, 0) NULL
			/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 ends*/
		)
	
	
		SELECT Prdid,Prdbatid,LcnId,Max(Transdate) as TransDate INTO #Stock1 FROM STOCKLEDGER
		WHERE TransDate < @Pi_FromDate
		GROUP BY Prdid,Prdbatid,LcnId

		SELECT Prdid,Prdbatid,LcnId,Max(Transdate) as TransDate INTO #Stock2 FROM STOCKLEDGER
		WHERE TransDate <= @Pi_ToDate
		GROUP BY Prdid,Prdbatid,LcnId
	
		
		SELECT Transdate,Prdid,Prdbatid,
		SUM(SalesOpening) as SalesOpening,SUM(UnSaleableOpening) as UnSaleableOpening,SUM(OfferOpening) as OfferOpening,
		SUM(SalPurchase) as SalPurchase,SUM(UnsalPurchase) as UnsalPurchase,SUM(OfferPurchase) as OfferPurchase,
		SUM(SalSales) as SalSales, SUM(UnSalSales) as UnSalSales , SUM(OfferSales) as OfferSales,
		SUM([SalPurReturn]) as [SalPurReturn] ,SUM([UnsalPurReturn]) as [UnsalPurReturn] ,SUM([OfferPurReturn] ) as [OfferPurReturn],
		SUM([SalStockIn] ) as [SalStockIn],SUM([UnSalStockIn] ) as [UnSalStockIn],SUM([OfferStockIn] ) as [OfferStockIn],
		SUM([SalStockOut] ) as [SalStockOut],SUM([UnSalStockOut] ) as [UnSalStockOut],SUM([OfferStockOut] ) as [OfferStockOut],
		SUM([DamageIn] ) as [DamageIn],SUM([DamageOut] ) as [DamageOut],
		SUM([SalSalesReturn] ) as [SalSalesReturn],SUM([UnSalSalesReturn] ) as [UnSalSalesReturn],SUM([OfferSalesReturn] ) as [OfferSalesReturn],
		SUM([SalStkJurIn] ) as [SalStkJurIn],SUM([UnSalStkJurIn] ) as [UnSalStkJurIn],SUM([OfferStkJurIn] ) as [OfferStkJurIn],
		SUM([SalStkJurOut] ) as [SalStkJurOut],SUM([UnSalStkJurOut] ) as [UnSalStkJurOut],SUM([OfferStkJurOut] ) as [OfferStkJurOut],
		SUM([SalBatTfrIn] ) as [SalBatTfrIn],SUM([UnSalBatTfrIn] ) as [UnSalBatTfrIn],SUM([OfferBatTfrIn] ) as [OfferBatTfrIn],
		SUM([SalBatTfrOut] ) as [SalBatTfrOut],SUM([UnSalBatTfrOut] ) as [UnSalBatTfrOut],SUM([OfferBatTfrOut] ) as [OfferBatTfrOut],
		SUM([SalLcnTfrIn] ) as [SalLcnTfrIn],SUM([UnSalLcnTfrIn] ) as [UnSalLcnTfrIn],SUM([OfferLcnTfrIn] ) as [OfferLcnTfrIn],
		SUM([SalLcnTfrOut] ) as [SalLcnTfrOut],SUM([UnSalLcnTfrOut] ) as [UnSalLcnTfrOut],SUM([OfferLcnTfrOut] ) as [OfferLcnTfrOut],
		SUM([SalReplacement] ) as [SalReplacement],SUM([OfferReplacement] ) as [OfferReplacement],
		SUM(SalClsStock) as SalClsStock,SUM(UnSalClsStock) as UnSalClsStock,
		SUM(OfferClsStock) as OfferClsStock,0 as MRP,0 as CLP,
		/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 begins*/
		SUM(SamplePurchase) AS SamplePurchase,SUM(SampleSales) AS SampleSales,SUM(SampleFreeSales) AS SampleFreeSales,SUM(SampleSalesReturn) AS SampleSalesReturn
		/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 ends*/
		INTO #StockSummary 
		FROM(
			SELECT @Pi_ToDate  as TransDate,
			ST.PrdId,St.Prdbatid,SUM(SalClsStock) as SalesOpening,SUM(UnSalClsStock) as UnSaleableOpening,
			SUM(OfferClsStock) as OfferOpening,0 as SalPurchase,0 as UnsalPurchase,0 as  OfferPurchase,
			0 as SalSales,0 as UnSalSales ,0 as OfferSales,
			0 as [SalPurReturn] ,
			0 as [UnsalPurReturn] ,
			0 as [OfferPurReturn] ,
			0 as [SalStockIn] ,
			0 as [UnSalStockIn] ,
			0 as [OfferStockIn] ,
			0 as [SalStockOut] ,
			0 as [UnSalStockOut] ,
			0 as [OfferStockOut] ,
			0 as [DamageIn] ,
			0 as [DamageOut] ,
			0 as [SalSalesReturn] ,
			0 as [UnSalSalesReturn] ,
			0 as [OfferSalesReturn] ,
			0 as [SalStkJurIn] ,
			0 as [UnSalStkJurIn] ,
			0 as [OfferStkJurIn] ,
			0 as [SalStkJurOut] ,
			0 as [UnSalStkJurOut] ,
			0 as [OfferStkJurOut] ,
			0 as [SalBatTfrIn] ,
			0 as [UnSalBatTfrIn] ,
			0 as [OfferBatTfrIn] ,
			0 as [SalBatTfrOut] ,
			0 as [UnSalBatTfrOut] ,
			0 as [OfferBatTfrOut] ,
			0 as [SalLcnTfrIn] ,
			0 as [UnSalLcnTfrIn] ,
			0 as [OfferLcnTfrIn] ,
			0 as [SalLcnTfrOut] ,
			0 as [UnSalLcnTfrOut] ,
			0 as [OfferLcnTfrOut] ,
			0 as [SalReplacement] ,
			0 as [OfferReplacement] ,		
			0 as SalClsStock,0 as UnSalClsStock,0 as OfferClsStock,
			/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 begins*/
			0 as SamplePurchase,0 as  SampleSales,0 as  SampleFreeSales,0 as SampleSalesReturn
			/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 ends*/
			FROM STOCKLEDGER ST
			INNER JOIN #Stock1 X ON X.Prdid=ST.Prdid and X.Prdbatid=ST.Prdbatid
			and X.Lcnid=ST.LcnId and X.Transdate=ST.Transdate		
			GROUP BY ST.PrdId,St.Prdbatid
					
			UNION ALL	
				
			SELECT @Pi_ToDate as TransDate,
			ST.PrdId,ST.Prdbatid,0 as SalesOpening,0 as UnSaleableOpening,0 as OfferOpening,
			0 as SalPurchase,0 as UnsalPurchase,0 as  OfferPurchase,
			0 as SalSales,0 as UnSalSales ,0 as OfferSales,
			0 as [SalPurReturn] ,
			0 as [UnsalPurReturn] ,
			0 as [OfferPurReturn] ,
			0 as [SalStockIn] ,
			0 as [UnSalStockIn] ,
			0 as [OfferStockIn] ,
			0 as [SalStockOut] ,
			0 as [UnSalStockOut] ,
			0 as [OfferStockOut] ,
			0 as [DamageIn] ,
			0 as [DamageOut] ,
			0 as [SalSalesReturn] ,
			0 as [UnSalSalesReturn] ,
			0 as [OfferSalesReturn] ,
			0 as [SalStkJurIn] ,
			0 as [UnSalStkJurIn] ,
			0 as [OfferStkJurIn] ,
			0 as [SalStkJurOut] ,
			0 as [UnSalStkJurOut] ,
			0 as [OfferStkJurOut] ,
			0 as [SalBatTfrIn] ,
			0 as [UnSalBatTfrIn] ,
			0 as [OfferBatTfrIn] ,
			0 as [SalBatTfrOut] ,
			0 as [UnSalBatTfrOut] ,
			0 as [OfferBatTfrOut] ,
			0 as [SalLcnTfrIn] ,
			0 as [UnSalLcnTfrIn] ,
			0 as [OfferLcnTfrIn] ,
			0 as [SalLcnTfrOut] ,
			0 as [UnSalLcnTfrOut] ,
			0 as [OfferLcnTfrOut] ,
			0 as [SalReplacement] ,
			0 as [OfferReplacement] ,
			--0 as Adjustments,
			SUM(SalClsStock) as SalClsStock,SUM(UnSalClsStock) as UnSalClsStock,
			SUM(OfferClsStock) as OfferClsStock,
			/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 begins*/
			0 as SamplePurchase,0 as  SampleSales,0 as  SampleFreeSales,0 as SampleSalesReturn
			/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 ends*/		
			FROM STOCKLEDGER ST
			INNER JOIN  #Stock2 X ON X.Prdid=ST.Prdid and X.Prdbatid=ST.Prdbatid
			and X.Lcnid=ST.LcnId and X.Transdate=ST.Transdate
			GROUP BY ST.PrdId,St.Prdbatid
			
			UNION ALL
			
			SELECT @Pi_ToDate as TransDate,Sl.PrdId,Sl.PrdBatId,
			0 as SalesOpening,0 as UnSaleableOpening,0 as OfferOpening,
			SUM(Sl.SalPurchase) as SalPurchase,SUM(Sl.UnsalPurchase) as UnsalPurchase,SUM(Sl.OfferPurchase) as OfferPurchase,
			SUM(Sl.SalSales) as SalSales,SUM(Sl.UnSalSales) as UnSalSales,SUM(Sl.OfferSales) as OfferSales,		
			SUM([SalPurReturn]) ,
			SUM([UnsalPurReturn]) ,
			SUM([OfferPurReturn] ),
			SUM([SalStockIn] ),
			SUM([UnSalStockIn] ),
			SUM([OfferStockIn] ),
			SUM([SalStockOut] ),
			SUM([UnSalStockOut] ),
			SUM([OfferStockOut] ),
			SUM([DamageIn] ),
			SUM([DamageOut] ),
			SUM([SalSalesReturn] ),
			SUM([UnSalSalesReturn] ),
			SUM([OfferSalesReturn] ),
			SUM([SalStkJurIn] ),
			SUM([UnSalStkJurIn] ),
			SUM([OfferStkJurIn] ),
			SUM([SalStkJurOut] ),
			SUM([UnSalStkJurOut] ),
			SUM([OfferStkJurOut] ),
			SUM([SalBatTfrIn] ),
			SUM([UnSalBatTfrIn] ),
			SUM([OfferBatTfrIn] ),
			SUM([SalBatTfrOut] ),
			SUM([UnSalBatTfrOut] ),
			SUM([OfferBatTfrOut] ),
			SUM([SalLcnTfrIn] ),
			SUM([UnSalLcnTfrIn] ),
			SUM([OfferLcnTfrIn] ),
			SUM([SalLcnTfrOut] ),
			SUM([UnSalLcnTfrOut] ),
			SUM([OfferLcnTfrOut] ),
			SUM([SalReplacement] ),
			SUM([OfferReplacement] ),	
			0 as SalClsStock,0 as UnSalClsStock,0 as OfferClsStock,
			/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 begins*/
			0 as SamplePurchase,0 as  SampleSales,0 as  SampleFreeSales,0 as SampleSalesReturn
			/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 ends*/
				
			--SUM((-Sl.SalPurReturn-Sl.UnsalPurReturn-Sl.OfferPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.OfferStockIn-
			--Sl.SalStockOut-Sl.UnSalStockOut-Sl.OfferStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.OfferSalesReturn+
			--Sl.SalStkJurIn+Sl.UnSalStkJurIn+Sl.OfferStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut-Sl.OfferStkJurOut+
			--Sl.SalBatTfrIn+Sl.UnSalBatTfrIn+Sl.OfferBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut-Sl.OfferBatTfrOut+
			--Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn+Sl.OfferLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-Sl.OfferLcnTfrOut-
			--Sl.SalReplacement-Sl.OfferReplacement+Sl.DamageIn-Sl.DamageOut)) AS Adjustments,
			--0 as SalClsStock,0 as UnSalClsStock,0 as OfferClsStock
			FROM StockLedger Sl WHERE Sl.TransDate BETWEEN @Pi_FromDate AND  @Pi_ToDate	
			GROUP BY Sl.PrdId,Sl.PrdBatId
			
		
			)X GROUP BY  Transdate,Prdid,Prdbatid
	
			DELETE FROM #ClosingStock_FORVAT203B
	--      Stocks for the given date---------
			INSERT INTO #ClosingStock_FORVAT203B
			(
				Transdate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatchCode,
				MRP,CLP,OpeningSales,OpeningUnSaleable,OpenignOffer,
				PurchaseSales,PurchaseUnSaleable,PurchaseOffer,
				InvoiceSales,InvoiceUnSaleable,InvoiceOffer,
				[SalPurReturn] ,[UnsalPurReturn] ,[OfferPurReturn] ,
				[SalStockIn] ,[UnSalStockIn] ,[OfferStockIn] ,
				[SalStockOut] ,	[UnSalStockOut] ,[OfferStockOut] ,
				[DamageIn] ,[DamageOut] ,
				[SalSalesReturn] ,[UnSalSalesReturn] ,[OfferSalesReturn] ,
				[SalStkJurIn] ,	[UnSalStkJurIn] ,[OfferStkJurIn] ,
				[SalStkJurOut] ,[UnSalStkJurOut] ,[OfferStkJurOut] ,
				[SalBatTfrIn] ,	[UnSalBatTfrIn] ,[OfferBatTfrIn] ,
				[SalBatTfrOut] ,[UnSalBatTfrOut] ,[OfferBatTfrOut] ,
				[SalLcnTfrIn] ,	[UnSalLcnTfrIn] ,[OfferLcnTfrIn] ,
				[SalLcnTfrOut] ,[UnSalLcnTfrOut] ,[OfferLcnTfrOut] ,
				[SalReplacement] ,[OfferReplacement] ,ClosingSales,ClosingUnSaleable,
				ClosingOffer,SecondarySales,
				LastInvoiceNumber,LastInvoiceDate,StockInTrans,
				/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 begins*/
				SamplePurchase,SampleSales,SampleFreeSales,SampleSalesReturn
				/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 ends*/					
			)
						
			SELECT Transdate,P.PrdId,PrdcCode,PrdName,pb.PrdBatId,PrdBatCode,
				MRP,CLP,SalesOpening,UnSaleableOpening,OfferOpening,
				SalPurchase,UnsalPurchase,OfferPurchase,
				SalSales,UnSalSales,OfferSales,[SalPurReturn] ,[UnsalPurReturn] ,[OfferPurReturn] ,
				[SalStockIn] ,[UnSalStockIn] ,[OfferStockIn] ,
				[SalStockOut] ,	[UnSalStockOut] ,[OfferStockOut] ,
				[DamageIn] ,[DamageOut] ,
				[SalSalesReturn] ,[UnSalSalesReturn] ,[OfferSalesReturn] ,
				[SalStkJurIn] ,	[UnSalStkJurIn] ,[OfferStkJurIn] ,
				[SalStkJurOut] ,[UnSalStkJurOut] ,[OfferStkJurOut] ,
				[SalBatTfrIn] ,	[UnSalBatTfrIn] ,[OfferBatTfrIn] ,
				[SalBatTfrOut] ,[UnSalBatTfrOut] ,[OfferBatTfrOut] ,
				[SalLcnTfrIn] ,	[UnSalLcnTfrIn] ,[OfferLcnTfrIn] ,
				[SalLcnTfrOut] ,[UnSalLcnTfrOut] ,[OfferLcnTfrOut] ,
				[SalReplacement] ,[OfferReplacement],
				SalClsStock,UnSalClsStock,OfferClsStock,0 as SecondarySales,'' as LastInvoiceNumber,
				Getdate() as LastInvoiceDate,0 as StockInTrans,
				/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 begins*/
				SamplePurchase,SampleSales,SampleFreeSales,SampleSalesReturn
				/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 ends*/					
			FROM #StockSummary S INNER JOIN Product P ON S.Prdid=P.PrdId
			INNER JOIN ProductBatch PB ON P.PrdId=PB.PrdId and S.PrdBatId=PB.PrdBatId
		
			INSERT INTO ClosingStock_FORVAT203B(StkMonth,StkYear,
				PrdCode,PrdName,PrdBatchCode,MRP,CLP,OpeningSales,OpeningUnSaleable,
				OpenignOffer,PurchaseSales,PurchaseUnSaleable,PurchaseOffer,InvoiceSales,
				InvoiceUnSaleable,InvoiceOffer,[SalPurReturn] ,[UnsalPurReturn] ,[OfferPurReturn] ,
				[SalStockIn] ,[UnSalStockIn] ,[OfferStockIn] ,
				[SalStockOut] ,	[UnSalStockOut] ,[OfferStockOut] ,
				[DamageIn] ,[DamageOut] ,
				[SalSalesReturn] ,[UnSalSalesReturn] ,[OfferSalesReturn] ,
				[SalStkJurIn] ,	[UnSalStkJurIn] ,[OfferStkJurIn] ,
				[SalStkJurOut] ,[UnSalStkJurOut] ,[OfferStkJurOut] ,
				[SalBatTfrIn] ,	[UnSalBatTfrIn] ,[OfferBatTfrIn] ,
				[SalBatTfrOut] ,[UnSalBatTfrOut] ,[OfferBatTfrOut] ,
				[SalLcnTfrIn] ,	[UnSalLcnTfrIn] ,[OfferLcnTfrIn] ,
				[SalLcnTfrOut] ,[UnSalLcnTfrOut] ,[OfferLcnTfrOut] ,
				[SalReplacement] ,[OfferReplacement],ClosingSales,ClosingUnSaleable,
				ClosingOffer,SecondarySales,LastInvoiceNumber,LastInvoiceDate,StockInTrans,UploadFlag,
				/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 begins*/
				SamplePurchase,SampleSales,SampleFreeSales,SampleSalesReturn,UsrId)
				/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 ends*/
			SELECT 0 StkMonth,0 StkYear,
				PrdCode,PrdName,PrdBatchCode,MRP,CLP,OpeningSales,OpeningUnSaleable,
				OpenignOffer,PurchaseSales,PurchaseUnSaleable,PurchaseOffer,InvoiceSales,
				InvoiceUnSaleable,InvoiceOffer,[SalPurReturn] ,[UnsalPurReturn] ,[OfferPurReturn] ,
				[SalStockIn] ,[UnSalStockIn] ,[OfferStockIn] ,
				[SalStockOut] ,	[UnSalStockOut] ,[OfferStockOut] ,
				[DamageIn] ,[DamageOut] ,
				[SalSalesReturn] ,[UnSalSalesReturn] ,[OfferSalesReturn] ,
				[SalStkJurIn] ,	[UnSalStkJurIn] ,[OfferStkJurIn] ,
				[SalStkJurOut] ,[UnSalStkJurOut] ,[OfferStkJurOut] ,
				[SalBatTfrIn] ,	[UnSalBatTfrIn] ,[OfferBatTfrIn] ,
				[SalBatTfrOut] ,[UnSalBatTfrOut] ,[OfferBatTfrOut] ,
				[SalLcnTfrIn] ,	[UnSalLcnTfrIn] ,[OfferLcnTfrIn] ,
				[SalLcnTfrOut] ,[UnSalLcnTfrOut] ,[OfferLcnTfrOut] ,
				[SalReplacement] ,[OfferReplacement],ClosingSales,ClosingUnSaleable,
				ClosingOffer,SecondarySales,LastInvoiceNumber,LastInvoiceDate,StockInTrans,'N' as UploadFlag,
				/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 begins*/
				SamplePurchase,SampleSales,SampleFreeSales,SampleSalesReturn,@Pi_UsrId
				/*Code Addd by Muthuvelsamy R for CR No CRCRSTLPPD0013 ends*/
			FROM #ClosingStock_FORVAT203B 
			WHERE (OpeningSales+OpeningUnSaleable+OpenignOffer+PurchaseSales+PurchaseUnSaleable+PurchaseOffer+InvoiceSales+
					InvoiceUnSaleable+InvoiceOffer+[SalPurReturn]+[UnsalPurReturn]+[OfferPurReturn] +
					[SalStockIn] +[UnSalStockIn] +[OfferStockIn] +
					[SalStockOut] +	[UnSalStockOut]+[OfferStockOut] +
					[DamageIn]+[DamageOut] +
					[SalSalesReturn] +[UnSalSalesReturn] +[OfferSalesReturn]+
					[SalStkJurIn] +	[UnSalStkJurIn] +[OfferStkJurIn]+
					[SalStkJurOut] +[UnSalStkJurOut] +[OfferStkJurOut] +
					[SalBatTfrIn] +	[UnSalBatTfrIn] +[OfferBatTfrIn] +
					[SalBatTfrOut] +[UnSalBatTfrOut] +[OfferBatTfrOut] +
					[SalLcnTfrIn] +	[UnSalLcnTfrIn] +[OfferLcnTfrIn] +
					[SalLcnTfrOut] +[UnSalLcnTfrOut] +[OfferLcnTfrOut] +
				[SalReplacement] +[OfferReplacement]+ClosingSales+ClosingUnSaleable+ClosingOffer+StockInTrans)>0

	RETURN
END
GO
DELETE FROM RptGroup WHERE RptId=278
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',278,'GUJVAT201CReport','GUJVAT201CReport',1
GO
DELETE FROM RptHeader WHERE RptId=278
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'GUJVAT201CReport','Guj govt VAT report 201A',278,'Guj govt VAT report 201C','Proc_RptGujVAT201C','RptGujVAT201C','RptGujVAT201C.rpt',''
GO
DELETE FROM RptDetails WHERE RptId=278
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
SELECT  278,1,'FromDate',-1,'','','From Date*','',1,'',10,'','','Enter From Date',0
UNION
SELECT  278,2,'ToDate',-1,'','','To Date*','',1,'',11,'','','Enter To Date',0
UNION
SELECT  278,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,'','Press F4/Double Click to Select Company',0
UNION
SELECT  278,4,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Stock Value as per*...','',1,'',23,1,1,'Press F4/Double Click to Select Stock Value as per',0
GO
DELETE FROM RptFilter WHERE RptId=278
INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
SELECT 278,23,1,'Selling Rate'
UNION
SELECT 278,23,2,'List Price'
UNION
SELECT 278,23,3,'MRP'
GO
DELETE FROM RptFormula WHERE RptId=278
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 278,1,'Disp_FromDate','FromDate',1,0
UNION
SELECT 278,2,'Print_FromDate','FromDate',1,10
UNION
SELECT 278,3,'Disp_ToDate','ToDate',1,0
UNION
SELECT 278,4,'Print_ToDate','ToDate',1,11
UNION
SELECT 278,5,'Disp_Company','Company',1,0
UNION
SELECT 278,6,'Print_Company','Company',1,4
UNION
SELECT 278,7,'Disp_Output','Output',1,0
UNION
SELECT 278,8,'Print_Output','Output',1,314
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_RptGujVAT201C')
DROP PROCEDURE Proc_RptGujVAT201C
GO
--EXEC Proc_RptGujVAT201C 278,2,0,'PARLE',0,0,1
CREATE PROCEDURE Proc_RptGujVAT201C
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
* PROCEDURE	: Proc_RptGujVAT201C
* PURPOSE	: To get the report for tax details as Stock Wise
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
		DECLARE @StkValue	TINYINT
		
		SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
		SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
		SET @CmpId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		--SET @Type=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,314,@Pi_UsrId))
		SET @StkValue=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))
		SELECT @StkValue=CASE @StkValue WHEN 1 THEN 3 WHEN 2 THEN 2 WHEN 3 THEN 1 END

		--SET @FromDate='2014-06-01'
		--SET @ToDate='2014-06-26'
			CREATE TABLE #RptGujVAT201A
			(
				PrdCategory		VARCHAR(100),
				OpeningQty		NUMERIC(18,0),
				PurchaseQty		NUMERIC(18,0),
				SalesQty		NUMERIC(18,0),
				ClosingQty		NUMERIC(18,0),
				ClosingValue	NUMERIC(38,6)
			)
			CREATE TABLE #StockDetails
			(
				SlNo			NUMERIC(18,0) IDENTITY (1,1),
				PrdId			BIGINT,
				TaxGroupId		INT,
				TaxPerc			NUMERIC(18,2),
				Rate			NUMERIC(38,6),
				PrdCategory		VARCHAR(100),
				OpeningQty		NUMERIC(18,0),
				PurchaseQty		NUMERIC(18,0),
				SalesQty		NUMERIC(18,0),
				ClosingQty		NUMERIC(18,0),
				ClosingValue	NUMERIC(38,6)
			)
		
		TRUNCATE TABLE ClosingStock_FORVAT203B
		EXEC Proc_ClosingStock_FORVAT203B @FromDate,@ToDate,@Pi_UsrId
		EXEC Proc_GR_Build_PH
		
		SELECT PBP.* INTO #ProductBatchDetails 
		FROM ProductBatchDetails PBP INNER JOIN BatchCreation BC ON BC.BatchSeqId=PBP.BatchSeqId AND BC.SlNo=PBP.SLNo
		WHERE BC.Slno=@StkValue AND DefaultPrice=1

		INSERT INTO #StockDetails
		SELECT P.PrdId,P.TaxGroupId,0 TaxPerc,PBD.PrdBatDetailValue,CT.Category_Caption PrdCategory,Rpt.OpeningSales,Rpt.PurchaseSales-Rpt.SalPurReturn,
		Rpt.InvoiceSales-Rpt.SalSalesReturn,Rpt.ClosingSales,ClosingSales*PBD.PrdBatDetailValue
		FROM ClosingStock_FORVAT203B Rpt 
		INNER JOIN Product P ON P.PrdCCode=Rpt.PrdCode
		INNER JOIN ProductBatch PB ON PB.PrdId=P.PrdId
		INNER JOIN TBL_GR_BUILD_PH CT ON P.PrdId=CT.PRDID
		INNER JOIN #ProductBatchDetails PBD ON PBD.PrdBatId=PB.PrdBatId
		WHERE Rpt.UsrId=@Pi_UsrId

		DECLARE @Cnt INT
		DECLARE @Rec INT
		DECLARE @PrdId	BIGINT
		DECLARE @TaxGroupId INT
		DECLARE @TaxPerc TABLE (PrdId BIGINT,TAXPerc NUMERIC(18,2))
		SELECT @Cnt=ISNULL(COUNT(PrdId),0) FROM #StockDetails (NOLOCK)
		SET @Rec=1
		WHILE @Cnt>=@Rec
		BEGIN
				
				SELECT @PrdId=PrdId,@TaxGroupId=TaxGroupId FROM #StockDetails (NOLOCK) WHERE SlNo=@Rec 
				INSERT INTO @TaxPerc(PrdId,TAXPerc)
				SELECT @PrdId,TSD.ColVal FROM TaxSettingDetail TSD (NOLOCK)
				INNER JOIN TaxConfiguration T (NOLOCK)ON T.TaxId=TSD.RowId
				WHERE TSD.TaxSeqId in (  SELECT Max(TaxSeqid) FROM TaxSettingMaster (NOLOCK) WHERE PrdId = @TaxGroupId and RtrId = 1 ) 
				and TSD.ColType=1 and TSD.ColId = 0 AND UPPER(LTRIM(RTRIM(T.TaxCode)))='VAT'
				SET @Rec=@Rec+1
		END
		
		UPDATE Rpt SET Rpt.TaxPerc=T.TAXPerc FROM #StockDetails Rpt INNER JOIN @TaxPerc T ON T.PrdId=Rpt.PrdId
				
		INSERT INTO #RptGujVAT201A	
		SELECT PrdCategory+'-'+CAST(TaxPerc AS VARCHAR(5)),SUM(OpeningQty),SUM(PurchaseQty),SUM(SalesQty),SUM(ClosingQty),SUM(ClosingValue) 
		FROM #StockDetails Rpt
		GROUP BY PrdCategory,TaxPerc
		
		DELETE FROM RptDataCount WHERE RptId=@Pi_RptId AND UserId=@Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,COUNT(*),0,@Pi_UsrId FROM #RptGujVAT201A
		SELECT * FROM #RptGujVAT201A

RETURN
END
GO
DELETE FROM RptGroup WHERE RptId=279
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',279,'SupplierWiseVATPurchase','SupplierWise VAT Purchase',1
GO
DELETE FROM RptHeader WHERE RptId=279
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'SupplierWiseVATPurchase','Supplier Wise VAT Purchase',279,'Supplier Wise VAT Purchase','Proc_RptSupplierWiseVATPurchaseMH','RptSupplierWiseVATPurchaseMH','RptSupplierWiseVATPurchaseMH.rpt',''
GO
DELETE FROM RptDetails WHERE RptId=279
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
SELECT  279,1,'FromDate',-1,'','','From Date*','',1,'',10,'','','Enter From Date',0
UNION
SELECT  279,2,'ToDate',-1,'','','To Date*','',1,'',11,'','','Enter To Date',0
UNION
SELECT  279,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,'','Press F4/Double Click to Select Company',0
--UNION
--SELECT  279,4,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Supplier TaxType*...','',1,'',200,1,0,'Press F4/Double Click to Select Supplier TaxType',0
GO
DELETE FROM RptFilter WHERE RptId=279
INSERT INTO RptFilter (RptId,SelcId,FilterId,FilterDesc)
SELECT 279,200,0,'ALL'
UNION
SELECT 279,200,1,'VAT'
UNION
SELECT 279,200,2,'NON VAT'
GO
DELETE FROM RptFormula WHERE RptId=279
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 279,1,'Disp_FromDate','FromDate',1,0
UNION
SELECT 279,2,'Print_FromDate','FromDate',1,10
UNION
SELECT 279,3,'Disp_ToDate','ToDate',1,0
UNION
SELECT 279,4,'Print_ToDate','ToDate',1,11
UNION
SELECT 279,5,'Disp_Company','Company',1,0
UNION
SELECT 279,6,'Print_Company','Company',1,4
UNION
SELECT 279,7,'Disp_Output','Output',1,0
UNION
SELECT 279,8,'Print_Output','Output',1,200
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_RptSupplierWiseVATPurchaseMH')
DROP PROCEDURE Proc_RptSupplierWiseVATPurchaseMH
GO
--EXEC Proc_RptSupplierWiseVATPurchaseMH 279,2,0,'PARLE',0,0,1
CREATE PROCEDURE Proc_RptSupplierWiseVATPurchaseMH
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
* PROCEDURE	: Proc_RptSupplierWiseVATPurchaseMH
* PURPOSE	: To get the report for tax details
* CREATED BY	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 30-06-2014
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
SET NOCOUNT ON
BEGIN

		DECLARE @FromDate DATETIME
		DECLARE @ToDate DATETIME
		DECLARE @CmpId INT
		DECLARE @TaxType TINYINT
		
			
		SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
		SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
		SET @CmpId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		SET @TaxType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,200,@Pi_UsrId))

		CREATE TABLE #RptSupplierWiseVATPurchase
		(
			PurRcptId		BIGINT,
			CmpInvNo		VARCHAR(50),
			InvNo			VARCHAR(50),
			InvDate			DATETIME,
			SpmId			INT,
			SpmName			VARCHAR(50),
			SpmTinNo		VARCHAR(25),
			TaxPerc			NUMERIC(18,2),
			TaxableAmt		NUMERIC(38,6),
			TaxAmt			NUMERIC(38,6),
			TotalAmt		NUMERIC(38,6)
		)
		
		CREATE TABLE #RptSupplierWiseVATPurchaseMH
		(
			SpmId			INT,
			SpmName			VARCHAR(50),
			SpmTinNo		VARCHAR(25),
			TaxableAmt		NUMERIC(38,6),
			TaxAmt			NUMERIC(38,6),
			TotalAmt		NUMERIC(38,6)
		)

			SELECT P.* INTO #PurchaseReceipt FROM PurchaseReceipt P (NOLOCK) WHERE GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND Status=1

			SELECT PR.* INTO #PurchaseReceiptProduct FROM #PurchaseReceipt P (NOLOCK) 
			INNER JOIN PurchaseReceiptProduct PR (NOLOCK)  ON P.PurRcptId=PR.PurRcptId

			SELECT PRT.* INTO #PurchaseReceiptProductTax FROM #PurchaseReceipt P (NOLOCK) 
			INNER JOIN #PurchaseReceiptProduct PR (NOLOCK)  ON P.PurRcptId=PR.PurRcptId
			INNER JOIN PurchaseReceiptProductTax PRT (NOLOCK)  ON P.PurRcptId=PRT.PurRcptId AND PR.PurRcptId=PRT.PurRcptId AND PR.PrdSlNo=PRT.PrdSlNo
			WHERE PRT.TaxableAmount>0
			
			INSERT INTO #RptSupplierWiseVATPurchase(	PurRcptId,
														CmpInvNo		,
														InvNo			,
														InvDate			,
														SpmId			,
														SpmName			,
														SpmTinNo		,
														TaxPerc			,
														TaxableAmt		,
														TaxAmt			,
														TotalAmt		)
			SELECT S.PurRcptId,S.CmpInvNo,S.PurRcptRefNo,S.GoodsRcvdDate,R.SpmId,R.SpmName,R.SpmTinNo,T.TaxPerc,SUM(T.TaxableAmount),
			SUM(T.TaxAmount) ,SUM(T.TaxableAmount)+SUM(T.TaxAmount) TotalAmt
			FROM #PurchaseReceipt S (NOLOCK)
			INNER JOIN #PurchaseReceiptProduct SP (NOLOCK) ON SP.PurRcptId=S.PurRcptId
			INNER JOIN #PurchaseReceiptProductTax T (NOLOCK)  ON T.PurRcptId=SP.PurRcptId AND T.PurRcptId=S.PurRcptId AND T.PrdSlNo=SP.PrdSlNo
			INNER JOIN Supplier R (NOLOCK) ON S.SpmId=R.SpmId
			WHERE S.GoodsRcvdDate BETWEEN @FromDate AND @ToDate
			GROUP BY R.SpmId,T.TaxPerc,R.SpmName,R.SpmTinNo,S.PurRcptId,S.CmpInvNo,S.GoodsRcvdDate,S.PurRcptRefNo
			HAVING SUM(T.TaxableAmount)>0

			INSERT INTO #RptSupplierWiseVATPurchaseMH
			(
				SpmId			,
				SpmName			,
				SpmTinNo		,
				TaxableAmt		,
				TaxAmt			,
				TotalAmt		
			)
		SELECT SpmId,SpmName,SpmTinNo,SUM(TaxableAmt),SUM(TaxAmt),SUM(TotalAmt) FROM #RptSupplierWiseVATPurchase
		GROUP BY SpmId,SpmName,SpmTinNo
		DELETE FROM RptDataCount WHERE RptId=@Pi_RptId AND UserId=@Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,COUNT(*),0,@Pi_UsrId FROM #RptSupplierWiseVATPurchaseMH
		SELECT * FROM #RptSupplierWiseVATPurchaseMH ORDER BY SpmId
	RETURN
END
GO
DELETE FROM RptGroup WHERE RptId=280
INSERT INTO RptGroup (PId,RptId,GrpCode,GrpName,VISIBILITY)
SELECT 'ParleReports',280,'RetailerWiseVATSales','RetailerWise VAT Sales',1
GO
DELETE FROM RptHeader WHERE RptId=280
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'RetailerWiseVATSales','RetailerWise VAT Sales',280,'RetailerWise VAT Sales','Proc_RptRetailerWiseVATSalesMH','RptRetailerWiseVATSalesMH','RptRetailerWiseVATSalesMH.rpt',''
GO
DELETE FROM RptDetails WHERE RptId=280
INSERT INTO RptDetails (RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
SELECT  280,1,'FromDate',-1,'','','From Date*','',1,'',10,'','','Enter From Date',0
UNION
SELECT  280,2,'ToDate',-1,'','','To Date*','',1,'',11,'','','Enter To Date',0
UNION
SELECT  280,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,'','Press F4/Double Click to Select Company',0
UNION
SELECT  280,4,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Retailer TaxType*...','',1,'',200,1,0,'Press F4/Double Click to Select Supplier TaxType',0
GO
DELETE FROM RptFilter WHERE RptId=280
INSERT INTO RptFilter (RptId,SelcId,FilterId,FilterDesc)
SELECT 280,200,0,'ALL'
UNION
SELECT 280,200,1,'VAT'
UNION
SELECT 280,200,2,'NON VAT'
GO
DELETE FROM RptFormula WHERE RptId=280
INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 280,1,'Disp_FromDate','FromDate',1,0
UNION
SELECT 280,2,'Print_FromDate','FromDate',1,10
UNION
SELECT 280,3,'Disp_ToDate','ToDate',1,0
UNION
SELECT 280,4,'Print_ToDate','ToDate',1,11
UNION
SELECT 280,5,'Disp_Company','Company',1,0
UNION
SELECT 280,6,'Print_Company','Company',1,4
UNION
SELECT 280,7,'Disp_Output','Output',1,0
UNION
SELECT 280,8,'Print_Output','Output',1,200
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptRetailerWiseVATSalesMH')
DROP PROCEDURE Proc_RptRetailerWiseVATSalesMH
GO
--EXEC Proc_RptRetailerWiseVATSalesMH 280,2,0,'PARLE',0,0,1
CREATE PROCEDURE Proc_RptRetailerWiseVATSalesMH
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
* PROCEDURE	: Proc_RptSupplierWiseVATPurchaseMH
* PURPOSE	: To get the report for tax details
* CREATED BY	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 30-06-2014
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
SET NOCOUNT ON
BEGIN

		DECLARE @FromDate DATETIME
		DECLARE @ToDate DATETIME
		DECLARE @CmpId INT
		DECLARE @TaxType TINYINT
		
			
		SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
		SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
		SET @CmpId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		SET @TaxType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,200,@Pi_UsrId))
	
		DECLARE @Tbl_TAXTYPE TABLE (TaxType TINYINT)
		IF @TaxType=0
		BEGIN
			INSERT INTO @Tbl_TAXTYPE (TaxType) SELECT 0 UNION SELECT 1
		END
		ELSE
		BEGIN
			INSERT INTO @Tbl_TAXTYPE (TaxType) SELECT CASE @TaxType WHEN 1 THEN 0 WHEN 2 THEN 1 END
		END
	
		CREATE TABLE #RptRetailerWiseVATSales
		(
			SalId			BIGINT,
			SalInvNo		VARCHAR(50),
			SalInvRef		VARCHAR(50),
			SalInvDate		DATETIME,
			RtrId			INT,
			RtrCode			VARCHAR(25),
			RtrName			VARCHAR(50),
			RtrTinNo		VARCHAR(25),
			TaxPerc			NUMERIC(18,2),
			TaxableAmt		NUMERIC(38,6),
			TaxAmt			NUMERIC(38,6),
			TotalAmt		NUMERIC(38,6)
		)
		
		CREATE TABLE #RptRetailerWiseVATSalesMH
		(
			RtrId			INT,
			RtrCode			VARCHAR(25),
			RtrName			VARCHAR(50),
			RtrTinNo		VARCHAR(25),
			TaxableAmt		NUMERIC(38,6),
			TaxAmt			NUMERIC(38,6),
			TotalAmt		NUMERIC(38,6)
		)
			SELECT * INTO #SalesInvoice FROM SalesInvoice (NOLOCK) WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND DlvSts>3
			SELECT R.* INTO #Retailer FROM Retailer R WHERE EXISTS (SELECT * FROM @Tbl_TAXTYPE E WHERE E.TaxType=R.RtrTaxType)
						
			SELECT SP.* INTO #SalesInvoiceProduct FROM #SalesInvoice S (NOLOCK) 
			INNER JOIN SalesInvoiceProduct SP ON S.SalId=SP.SalId
			
			SELECT T.* INTO #SalesInvoiceProductTax FROM #SalesInvoice S (NOLOCK)
			INNER JOIN #SalesInvoiceProduct SP (NOLOCK) ON SP.SalId=S.SalId
			INNER JOIN SalesInvoiceProductTax T (NOLOCK)  ON T.SalId=SP.SalId AND T.SalId=S.SalId AND T.PrdSlNo=SP.SlNo
			WHERE T.TaxableAmount>0 
		
			INSERT INTO #RptRetailerWiseVATSales(
			SalId			,
			SalInvNo		,
			SalInvRef		,
			SalInvDate		,
			RtrId			,
			RtrCode			,
			RtrName			,
			RtrTinNo		,
			TaxPerc			,
			TaxableAmt		,
			TaxAmt			,
			TotalAmt		)
			SELECT S.SalId,S.SalInvNo,S.SalInvRef,S.SalInvDate,R.RtrId,R.RtrCode,R.RtrName,R.RtrTinNo,T.TaxPerc,SUM(T.TaxableAmount) TaxableAmount,
			SUM(T.TaxAmount) TaxAmount,SUM(T.TaxableAmount)+SUM(T.TaxAmount) TotalAmt
			FROM #SalesInvoice S (NOLOCK)
			INNER JOIN #SalesInvoiceProduct SP (NOLOCK) ON SP.SalId=S.SalId
			INNER JOIN #SalesInvoiceProductTax T (NOLOCK)  ON T.SalId=SP.SalId AND T.SalId=S.SalId AND T.PrdSlNo=SP.SlNo
			INNER JOIN #Retailer R (NOLOCK) ON S.RtrId=R.RtrId
			WHERE SalInvDate BETWEEN @FromDate AND @ToDate
			GROUP BY R.RtrId,T.TaxPerc,R.RtrName,R.RtrTinNo,S.SalId,S.SalInvNo,S.SalInvDate,S.SalInvRef,R.RtrCode
			HAVING SUM(T.TaxableAmount)>0

		INSERT INTO #RptRetailerWiseVATSalesMH(
			RtrId			,
			RtrCode			,
			RtrName			,
			RtrTinNo		,
			TaxableAmt		,
			TaxAmt			,
			TotalAmt		)
		SELECT RtrId,RtrCode,RtrName,RtrTinNo,SUM(TaxableAmt),SUM(TaxAmt),SUM(TotalAmt) FROM #RptRetailerWiseVATSales
		GROUP BY RtrId,RtrName,RtrTinNo,RtrCode
		DELETE FROM RptDataCount WHERE RptId=@Pi_RptId AND UserId=@Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,COUNT(*),0,@Pi_UsrId FROM #RptRetailerWiseVATSalesMH
		SELECT * FROM #RptRetailerWiseVATSalesMH ORDER BY RtrId
	RETURN
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptGridView')
DROP TABLE RptGridView
GO
CREATE TABLE RptGridView
(
  RptId NUMERIC(18,0),
  RptName NVARCHAR(200),
  CrystalView TINYINT,
  GridView TINYINT,
  ExcelView TINYINT,
  PDFView  TINYINT
)
GO
DELETE FROM RptGridView
INSERT INTO RptGridView (RptId,RptName,CrystalView,GridView,ExcelView,PDFView)
SELECT DISTINCT RPTID,RptName,1,0,0,0 FROM RptHeader WITH(NOLOCK)
GO
UPDATE RptGridView SET GridView = 1 WHERE RptID IN (SELECT DISTINCT MasterId FROM SpreadDisplayColumns WITH(NOLOCK))
UPDATE RptGridView SET ExcelView = 1 WHERE RptID IN (SELECT DISTINCT RptId FROM RptExcelHeaders WITH(NOLOCK))
GO
UPDATE RptGridView SET PDFView=1 WHERE RPTID IN (277,278,279,280)
GO
DELETE FROM RptDetails WHERE RptId=29
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (29,1,'FromDate',-1,'0','','From Date*','',1,'0',10,0,0,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (29,2,'ToDate',-1,'0','','To Date*','',1,'0',11,0,0,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (29,3,'Salesman',-1,'0','SMId,SMCode,SMName','Salesman...','',1,'0',1,0,0,'Press F4/Double Click to Select Salesman',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (29,4,'RouteMaster',-1,'0','RMId,RMCode,RMName','Route...','',1,'0',2,0,0,'Press F4/Double Click to Select Route',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (29,5,'Retailer',-1,'0','RtrId,RtrCode,RtrName','Retailer...','',1,'0',3,0,0,'Press F4/Double Click to Select Retailer',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (29,6,'SalesInvoice',-1,'0','SalId,SalInvNo,SalInvNo','Transaction Reference No...','',1,'',195,0,0,'Press F4/Double Click to Select Transaction Reference No',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (29,7,'RptFilter',-1,'','FilterId,FilterId,FilterDesc','Display Net Amount*...','',1,'',264,1,1,'Press F4/Double Click to Select Display Net Amount',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (29,8,'RptFilter',-1,'','FilterId,FilterId,FilterDesc','Display Base Transaction No*...','',1,'',273,1,1,'Press F4/Double Click to Select Display Base Transaction No',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (29,9,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Retailer TaxType...','',1,'',200,1,0,'Press F4/Double Click to Select Retailer TaxType',0)
GO
DELETE FROM RptFilter WHERE RptId=29 AND SelcID=200
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (29,200,0,'ALL')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (29,200,1,'VAT')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (29,200,2,'NON VAT')
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptOUTPUTVATSummary')
DROP PROCEDURE Proc_RptOUTPUTVATSummary
GO
CREATE  PROCEDURE Proc_RptOUTPUTVATSummary
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
DECLARE @TaxType TINYINT
--select * from reportfilterdt
SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @TransNo =(SELECT TOP 1 SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,195,@Pi_UsrId))
SET @DispNet = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,264,@Pi_UsrId))
SET @DispBaseTransNo = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,273,@Pi_UsrId))
SET @TaxType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,200,@Pi_UsrId))
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
	--ADDED BY PRAVEENRAJ BHASKARAN ON 10-07-2014 FOR RETAILER TAX TYPE FILTER
	DECLARE @Tbl_TAXTYPE TABLE (TaxType TINYINT)
	IF @TaxType=0
	BEGIN
		INSERT INTO @Tbl_TAXTYPE (TaxType) SELECT 0 UNION SELECT 1
	END
	ELSE
	BEGIN
		INSERT INTO @Tbl_TAXTYPE (TaxType) SELECT CASE @TaxType WHEN 1 THEN 0 WHEN 2 THEN 1 END
	END
	SELECT R.* INTO #Retailer FROM Retailer R WHERE EXISTS (SELECT * FROM @Tbl_TAXTYPE E WHERE E.TaxType=R.RtrTaxType)
	--END HERE
	INSERT INTO #RptOUTPUTVATSummary (InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,IOTaxType,TaxPerc,TaxableAmount,TaxFlag,TaxPercent)
		Select InvId,RefNo,InvDate,T.RtrId,R.RtrName,R.RtrTINNo,IOTaxType,TaxPerc,sum(TaxableAmount),
--		case IOTaxType when 'Sales' then TaxableAmount when 'SalesReturn' then -1 * TaxableAmount end as TaxableAmount ,
		TaxFlag,TaxPerCent From TmpRptIOTaxSummary T,#Retailer R
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
	'Net Amount',SUM(PrdNetAmount),0,2000.000000
	FROM #RptOUTPUTVATSummary A INNER JOIN SalesInvoice B ON 
	A.InvId=B.SalId AND A.RefNo=B.SalInvNo And A.Rtrid = B.Rtrid
	INNER JOIN SalesInvoiceProduct C ON B.SalId=C.SalId
	WHERE TaxFlag=0 AND A.IoTaxType='Sales' AND TaxPerc = 'Total Taxable Amount'
	GROUP BY InvId,RefNo,A.BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType
	--UNION ALL
    INSERT INTO #RptOUTPUTVATSummary
	SELECT InvId,RefNo,BillBookNo,InvDate,BaseTransNo,A.RtrId,RtrName,RtrTINNo,IOTaxType,
	'Net Amount',-1*SUM(PrdNetAmt),0,2000.000000
	FROM #RptOUTPUTVATSummary A INNER JOIN ReturnHeader B ON A.InvId=B.ReturnId AND 
	A.RefNo=B.ReturnCode And A.Rtrid = B.Rtrid 
	INNER JOIN ReturnProduct C ON B.ReturnId=C.ReturnId 
	WHERE TaxFlag=0 AND A.IoTaxType='SalesReturn' AND TaxPerc = 'Total Taxable Amount'
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
		INSERT INTO RptOUTPUTVATSummary_Excel(InvId,RefNo,BaseTransNo,InvDate,RtrId,RtrName,RtrTINNo,UsrId,BillBookNo)
		SELECT DISTINCT InvId,RefNo,BaseTransNo,InvDate,RtrId,RtrName,RtrTINNo,@Pi_UsrId,BillBookNo
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
IF EXISTS(SELECT Name FROM SYSOBJECTS WHERE NAME='Proc_ImpSetupDetails' AND XTYPE='P')
DROP PROCEDURE Proc_ImpSetupDetails
GO
CREATE PROCEDURE Proc_ImpSetupDetails
(  
@pRecords Text      
)     
AS     
  
--select * from Setup_Details

 
SET NOCOUNT ON  
BEGIN     
	DECLARE @hDoc INTEGER,       
		@InsertCount INTEGER  
	Declare @File_Names as Varchar(50)
	Declare @File_CrDate as datetime
	Declare @File_Path as Varchar(100)
	Declare @Status as Int
	Declare @RegRequired as int
	Declare @HotfixNo as int
	Declare @VersionNo as int
	Declare @DistCode as Varchar(50)
	Declare @DCode as Varchar(50)
	TRUNCATE TABLE SetupDetails
	EXEC sp_xml_preparedocument @hDoc OUTPUT, @pRecords 
      	SELECT 	File_Names as File_Names,
		Convert(Datetime,File_CrDate,101) as File_CrDate,
		File_Path as File_Path,
		Status as Status,
		RegRequired as RegRequired,
		HotfixNo as HotfixNo,
		VersionNo as VersionNo,
		COnVert(Datetime,File_UnZipDate,101) as File_UnZipDate,
		UploadFileSize as UploadFileSize,
		DownloadFileSize as DownloadFileSize,
		FileExtension as FileExtension,
		FileSplitStatus as FileSplitStatus
		INTO #Setup_Details   
       		FROM  OPENXML (@hdoc, '/MAST/SETUPDETAILS',1)                            
       		WITH ( 	
			File_Names Varchar(50),
			File_CrDate Varchar(10),
			File_Path Varchar(100),
			Status int,   
			RegRequired int,
			HotfixNo int,
			VersionNo Varchar(100),
			File_UnZipDate Varchar(10),
			UploadFileSize BigInt,
			DownloadFileSize Bigint,
			FileExtension  VarChar(5),
			FileSplitStatus Int
			


	    	 ) XMLGodown   
		   
		INSERT INTO SetupDetails 
		SELECT File_Names,File_CrDate,File_Path,Status,RegRequired,HotfixNo,
		VersionNo,File_UnZipDate ,UploadFileSize,DownloadFileSize,FileExtension,FileSplitStatus 
		FROM #Setup_Details
		
		UPDATE SetupDetails SET File_Path = 'C:\Program Files\Common Files\Crystal Decisions\2.0\bin' WHERE [File_Names] like 'Craxdrt%'


EXECUTE sp_xml_removedocument @hDoc 

END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_RptSupplierWiseVATPurchaseMH')
DROP PROCEDURE Proc_RptSupplierWiseVATPurchaseMH
GO
--EXEC Proc_RptSupplierWiseVATPurchaseMH 279,2,0,'PARLE',0,0,1
CREATE PROCEDURE Proc_RptSupplierWiseVATPurchaseMH
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
* PROCEDURE	: Proc_RptSupplierWiseVATPurchaseMH
* PURPOSE	: To get the report for tax details
* CREATED BY	: PRAVEENRAJ BHASKARAN
* CREATED DATE	: 30-06-2014
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
SET NOCOUNT ON
BEGIN

		DECLARE @FromDate DATETIME
		DECLARE @ToDate DATETIME
		DECLARE @CmpId INT
		DECLARE @TaxType TINYINT
		
			
		SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
		SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
		SET @CmpId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		SET @TaxType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,200,@Pi_UsrId))

		CREATE TABLE #RptSupplierWiseVATPurchase
		(
			PurRcptId		BIGINT,
			CmpInvNo		VARCHAR(50),
			InvNo			VARCHAR(50),
			InvDate			DATETIME,
			SpmId			INT,
			SpmCode			VARCHAR(25),
			SpmName			VARCHAR(50),
			SpmTinNo		VARCHAR(25),
			TaxPerc			NUMERIC(18,2),
			TaxableAmt		NUMERIC(38,6),
			TaxAmt			NUMERIC(38,6),
			TotalAmt		NUMERIC(38,6)
		)
		
		CREATE TABLE #RptSupplierWiseVATPurchaseMH
		(
			SpmId			INT,
			SpmCode			VARCHAR(25),
			SpmName			VARCHAR(50),
			SpmTinNo		VARCHAR(25),
			TaxableAmt		NUMERIC(38,6),
			TaxAmt			NUMERIC(38,6),
			TotalAmt		NUMERIC(38,6)
		)

			SELECT P.* INTO #PurchaseReceipt FROM PurchaseReceipt P (NOLOCK) WHERE GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND Status=1

			SELECT PR.* INTO #PurchaseReceiptProduct FROM #PurchaseReceipt P (NOLOCK) 
			INNER JOIN PurchaseReceiptProduct PR (NOLOCK)  ON P.PurRcptId=PR.PurRcptId

			SELECT PRT.* INTO #PurchaseReceiptProductTax FROM #PurchaseReceipt P (NOLOCK) 
			INNER JOIN #PurchaseReceiptProduct PR (NOLOCK)  ON P.PurRcptId=PR.PurRcptId
			INNER JOIN PurchaseReceiptProductTax PRT (NOLOCK)  ON P.PurRcptId=PRT.PurRcptId AND PR.PurRcptId=PRT.PurRcptId AND PR.PrdSlNo=PRT.PrdSlNo
			WHERE PRT.TaxableAmount>0
			
			INSERT INTO #RptSupplierWiseVATPurchase(	PurRcptId,
														CmpInvNo		,
														InvNo			,
														InvDate			,
														SpmId			,
														SpmCode			,
														SpmName			,
														SpmTinNo		,
														TaxPerc			,
														TaxableAmt		,
														TaxAmt			,
														TotalAmt		)
			SELECT S.PurRcptId,S.CmpInvNo,S.PurRcptRefNo,S.GoodsRcvdDate,R.SpmId,R.SpmCode,R.SpmName,R.SpmTinNo,T.TaxPerc,SUM(T.TaxableAmount),
			SUM(T.TaxAmount) ,SUM(T.TaxableAmount)+SUM(T.TaxAmount) TotalAmt
			FROM #PurchaseReceipt S (NOLOCK)
			INNER JOIN #PurchaseReceiptProduct SP (NOLOCK) ON SP.PurRcptId=S.PurRcptId
			INNER JOIN #PurchaseReceiptProductTax T (NOLOCK)  ON T.PurRcptId=SP.PurRcptId AND T.PurRcptId=S.PurRcptId AND T.PrdSlNo=SP.PrdSlNo
			INNER JOIN Supplier R (NOLOCK) ON S.SpmId=R.SpmId
			WHERE S.GoodsRcvdDate BETWEEN @FromDate AND @ToDate
			GROUP BY R.SpmId,T.TaxPerc,R.SpmName,R.SpmTinNo,S.PurRcptId,S.CmpInvNo,S.GoodsRcvdDate,S.PurRcptRefNo,R.SpmCode
			HAVING SUM(T.TaxableAmount)>0

			INSERT INTO #RptSupplierWiseVATPurchaseMH
			(
				SpmId			,
				SpmCode			,
				SpmName			,
				SpmTinNo		,
				TaxableAmt		,
				TaxAmt			,
				TotalAmt		
			)
		SELECT SpmId,SpmCode,SpmName,SpmTinNo,SUM(TaxableAmt),SUM(TaxAmt),SUM(TotalAmt) FROM #RptSupplierWiseVATPurchase
		GROUP BY SpmId,SpmName,SpmTinNo,SpmCode
		DELETE FROM RptDataCount WHERE RptId=@Pi_RptId AND UserId=@Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,COUNT(*),0,@Pi_UsrId FROM #RptSupplierWiseVATPurchaseMH
		SELECT * FROM #RptSupplierWiseVATPurchaseMH ORDER BY SpmId
	RETURN
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
--Till Here Praveen CR
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.0',416
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 416)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(416,'D','2014-07-17',GETDATE(),1,'Core Stocky Service Pack 416')