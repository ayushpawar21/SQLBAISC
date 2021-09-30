--[Stocky HotFix Version]=421
DELETE FROM Versioncontrol WHERE Hotfixid='421'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('421','3.1.0.2','D','2015-03-20','2015-03-20','2015-03-20',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
/*
    CR RELEASE DETAILS :
    1. Product Unification Purchase Receipt Download
    2. Special Discount Download
    3. Batch Cloning
    4. MIS Details Upload
    5. Billing Net Rate Editable
*/
IF NOT EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'ProductUnification_Track' AND xtype='U')
BEGIN
CREATE TABLE ProductUnification_Track(
	[RefNo] [INT] NULL,
	[ProductCode] [VARCHAR](400) NULL,
	[ProductName] [VARCHAR](400) NULL,
	[MapProductCode] [VARCHAR](400) NULL,
	[CreatedDate] [DATETIME] NULL	
) ON [PRIMARY]
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_CN2CS_ProductCodeUnification' AND xtype='P')
DROP PROCEDURE Proc_CN2CS_ProductCodeUnification
GO
/*
   BEGIN TRANSACTION
  EXEC Proc_CN2CS_ProductCodeUnification 0
  SELECT * FROM Errorlog (NOLOCK)
  select * from ProductBatch (Nolock) where PrdId in (473,799,971)
  select * from ProductBatchDetails A (Nolock) INNER JOIN  ProductBatch B (Nolock) ON A.PrdBatId = B.PrdBatId where PrdId in (473,799,971)
  select * from ProductBatchLocation (Nolock) where PrdId in (473,799,971)
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
	--Parent Product & Child Product 
	SELECT DISTINCT B.PrdId AS PPrdId,B.TaxGroupId,C.PrdId AS CPrdId INTO #ProductCodeUnification 
	FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK)
	INNER JOIN Product B (NOLOCK) ON A.ProductCode = B.PrdCCode
	INNER JOIN Product C (NOLOCK) ON A.MapProductCode = C.PrdCCode
	WHERE NOT EXISTS (SELECT DISTINCT ProductCode,MapProductCode FROM #ToAvoidProducts D WHERE A.ProductCode = D.ProductCode 
	AND A.MapProductCode = D.MapProductCode) AND NOT EXISTS (SELECT DISTINCT PrdId FROM ProductBatch E (NOLOCK) WHERE B.PrdId = E.PrdId)
	AND DownLoadFlag = 'D' ORDER BY PPrdId,CPrdId ASC
	
	--Child Product Latest Batch
	SELECT DISTINCT PPrdId,TaxGroupId,MAX(CPrdBatId) AS CPrdBatId INTO #ProductBatch FROM (
	SELECT DISTINCT PPrdId,TaxGroupId,CPrdId,CPrdBatId FROM #ProductCodeUnification A INNER JOIN
	(SELECT PrdId,MAX(PrdBatId) AS CPrdBatId FROM ProductBatch (NOLOCK) GROUP BY PrdId)B ON A.CPrdId = B.PrdId)Qry
	GROUP BY PPrdId,TaxGroupId
	
	--Child Product Latest Batch Details
    SELECT PPrdId,TaxGroupId,CPrdBatId,CPriceId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue
    INTO #ProductBatchDetails FROM #ProductBatch A INNER JOIN
    (SELECT DISTINCT PrdBatId,MAX(PriceId) AS CPriceId FROM ProductBatchDetails (NOLOCK) GROUP BY PrdBatId)B ON A.CPrdBatId = B.PrdBatId
    INNER JOIN ProductBatchDetails C (NOLOCK) ON A.CPrdBatId = C.PrdBatId AND B.PrdBatId = C.PrdBatId AND B.CPriceId = C.PriceId
    
    DECLARE @UPrdBatId AS NUMERIC(18,0)
	DECLARE @UPriceId  AS NUMERIC(18,0)
	SELECT @UPrdBatId = ISNULL(MAX(PrdBatId),0) FROM ProductBatch (NOLOCK)
	SELECT @UPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
    
    SELECT DISTINCT A.PPrdId,(DENSE_RANK()OVER (ORDER BY PPrdId ASC)+@UPrdBatId) AS PPrdBatId,A.TaxGroupId,PrdBatCode,
    CmpBatCode,MnfDate,ExpDate,BatchSeqId,DecPoints,EnableCloning,CPrdBatId INTO #ParentProductBatch 
    FROM #ProductBatch A INNER JOIN ProductBatch B (NOLOCK) ON A.CPrdBatId = B.PrdBatId 

    SELECT DISTINCT A.PPrdId,PPrdBatId,(DENSE_RANK()OVER(ORDER BY A.PPrdId,PPrdBatId ASC)+@UPriceId) AS PPriceId,
    PriceCode,B.BatchSeqId,SLNo,PrdBatDetailValue INTO #ParentProductBatchDetails 
    FROM #ParentProductBatch A INNER JOIN #ProductBatchDetails B ON A.PPrdId = B.PPrdId AND A.CPrdBatId = B.CPrdBatId
    
    --To Insert Product Batch & ProductBatchDetails
    INSERT INTO ProductBatch(PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,[Status],TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,
    EnableCloning,Availability,LastModBy,LastModDate,AuthId,AuthDate) 
	SELECT DISTINCT A.PPrdId,A.PPrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,1 AS [Status],TaxGroupId,A.BatchSeqId,DecPoints,
	PPriceId,EnableCloning,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) 
	FROM #ParentProductBatch A INNER JOIN #ParentProductBatchDetails B ON A.PPrdId = B.PPrdId AND A.PPrdBatId = B.PPrdBatId
	ORDER BY A.PPrdId,A.PPrdBatId,PPriceId
	
	INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,Availability,
    LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
    SELECT PPriceId,PPrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,
    CONVERT(NVARCHAR(10),GETDATE(),121),0 FROM #ParentProductBatchDetails ORDER BY PPriceId,PPrdBatId
    
    --Current Stock Reports
    IF EXISTS (SELECT DISTINCT PPriceId FROM #ParentProductBatchDetails)
    BEGIN
        EXEC Proc_DefaultPriceHistory 0,0,@UPriceId,2,1
    END	
	--Till Here

	SELECT @UPrdBatId = ISNULL(MAX(PrdBatId),0) FROM ProductBatch (NOLOCK)
	UPDATE Counters SET CurrValue = @UPrdBatId WHERE TabName = 'ProductBatch' AND FldName = 'PrdBatId'
	SELECT @UPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
    UPDATE Counters SET CurrValue = @UPriceId WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'
	
	--Mapped Products Stock Posting
	SELECT DISTINCT D.PrdId AS ToPrdId,A.PrdId,PrdBatId,LcnId,(PrdBatLcnSih-PrdBatLcnRessih) AS SalStock,
	(PrdBatLcnUih-PrdBatLcnResUih) AS UnSalStock,(PrdBatLcnFre-PrdBatLcnResFre) AS OfferStock INTO #ProductBatchLocation
	FROM ProductBatchLocation A (NOLOCK) INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId
	INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
	INNER JOIN Product D (NOLOCK) ON C.ProductCode = D.PrdCCode 
	WHERE (PrdBatLcnSih-PrdBatLcnRessih)+(PrdBatLcnUih-PrdBatLcnResUih)+(PrdBatLcnFre-PrdBatLcnResFre) > 0 AND DownLoadFlag = 'D' AND
	NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts TA WHERE C.ProductCode = TA.ProductCode AND C.MapProductCode = TA.MapProductCode)
	    	
	SELECT DISTINCT ToPrdId,ToPrdBatId INTO #ParentProductLatestBatch FROM #ProductBatchLocation A INNER JOIN
	(SELECT DISTINCT PrdId,MAX(PrdBatId) AS ToPrdBatId FROM ProductBatch (NOLOCK) GROUP BY PrdId)B ON A.ToPrdId = B.PrdId
	ORDER BY ToPrdId
	
	SELECT DISTINCT A.ToPrdId,ToPrdBatId,PrdId,PrdBatId,LcnId,SalStock,UnSalStock,OfferStock INTO #ManualStockPosting
	FROM #ProductBatchLocation A INNER JOIN #ParentProductLatestBatch B ON A.ToPrdId = B.ToPrdId
	ORDER BY A.ToPrdId,ToPrdBatId,PrdId,PrdBatId
		
	--Main Product Stock Posting IN
	DECLARE CUR_STOCKADJIN CURSOR
	FOR SELECT DISTINCT ToPrdId,ToPrdBatId,LcnId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalTotStock,
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
	FOR SELECT DISTINCT PrdId,PrdBatId,LcnId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalStock,
	SUM(UnSalStock) AS UnSalStock,SUM(OfferStock) AS OfferStock FROM #ManualStockPosting WITH (NOLOCK) 
	GROUP BY PrdId,PrdBatId,LcnId ORDER BY PrdId,PrdBatId
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
	
	--Moorthi Start Here
	DECLARE @RefNo AS INT
	SELECT @RefNo=ISNULL(MAX(RefNo),0)+1 FROM ProductUnification_Track (NOLOCK)
	
	INSERT INTO ProductUnification_Track(RefNo,ProductCode,ProductName,MapProductCode,CreatedDate)
	SELECT @RefNo,A.ProductCode,A.ProductName,A.MapProductCode,GETDATE() FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.MapProductCode = B.PrdCCode WHERE B.[PrdStatus] = 0 AND A.DownLoadFlag = 'D'
	AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable C WHERE B.PrdId = C.PrdId) AND
	NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts D (NOLOCK) WHERE A.ProductCode = D.ProductCode 
	AND A.MapProductCode = D.MapProductCode)	
	--Till Here	
	
	UPDATE A SET A.DownloadFlag = 'Y' FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.MapProductCode = B.PrdCCode WHERE B.[PrdStatus] = 0 AND A.DownLoadFlag = 'D'
	AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable C WHERE B.PrdId = C.PrdId) AND
	NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts D (NOLOCK) WHERE A.ProductCode = D.ProductCode 
	AND A.MapProductCode = D.MapProductCode)	
	    
	RETURN
END
GO
DELETE FROM CustomUpDownload WHERE MODULE='Purchase With Location Code'
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) 
SELECT 243,1,'Purchase With Location Code','Purchase With Location Code','Proc_CN2CS_PurchaseWithLocationCode','Proc_Import_PurchaseWithLocationCode','CN2CS_Prk_PurchaseWithLocationCode','Proc_CN2CS_PurchaseWithLocationCode','Transaction','Download',1
GO
DELETE FROM Tbl_DownloadINTegration WHERE ProcessName='Purchase With Location Code'
INSERT INTO Tbl_DownloadINTegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) 
SELECT 52,'Purchase With Location Code','CN2CS_Prk_PurchaseWithLocationCode','Proc_Import_PurchaseWithLocationCode',0,500,CONVERT(VARCHAR(10),GETDATE(),121)
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME = 'CN2CS_Prk_PurchaseWithLocationCode' AND xtype='U')
BEGIN
CREATE TABLE CN2CS_Prk_PurchaseWithLocationCode
(
	[DistCode] [VARCHAR](50) NULL,
	[CompInvNo] [VARCHAR](25) NULL,
	[CompInvDate] [DATETIME] NULL,
	[NetValue] [NUMERIC](18, 2) NULL,
	[TotalTax] [NUMERIC](18, 2) NULL,
	[LessDiscount] [NUMERIC](18, 2) NULL,
	[LessSchemeAmount] [NUMERIC](18, 2) NULL,
	[SupplierCode] [VARCHAR](50) NULL,
	[CompanyName] [VARCHAR](100) NULL,
	[TransporterName] [VARCHAR](50) NULL,
	[LRNO] [VARCHAR](15) NULL,
	[LRDate] [DATETIME] NULL,
	[WayBillNo] [VARCHAR](50) NULL,
	[ProductCode] [VARCHAR](100) NULL,
	[ProductName] [VARCHAR](300) NULL,
	[ConsoleProductCode]	[VARCHAR](100),
	[UOMCode] [VARCHAR](25) NULL,
	[PurQty] [INT] NULL,
	[CashDiscRs] [NUMERIC](18, 2) NULL,
	[CashDiscPer] [NUMERIC](18, 2) NULL,
	[LineLevelAmount] [NUMERIC](18, 2) NULL,
	[BatchNo] [VARCHAR](50) NULL,
	[ManufactureDate] [DATETIME] NULL,
	[ExpiryDate] [DATETIME] NULL,
	[MRP] [NUMERIC](18, 2) NULL,
	[ListPriceNSP] [NUMERIC](18, 2) NULL,
	[PurchaseTaxValue] [NUMERIC](18, 2) NULL,
	[PurchaseDiscount] [NUMERIC](18, 2) NULL,
	[PurchaseRate] [NUMERIC](18, 2) NULL,
	[SellingRate] [NUMERIC](18, 2) NULL,
	[SellingRateAfterTAX] [NUMERIC](18, 2) NULL,
	[SellingRateAfterVAT] [NUMERIC](18, 2) NULL,
	[FreightCharges] [NUMERIC](18, 2) NULL,
	[VatBatch] [INT] NULL,
	[VATTaxValue] [NUMERIC](18, 2) NULL,
	[Status] [INT] NULL,
	[FreeSchemeFlag] [VARCHAR](5) NULL,
	[SchemeRefrNo] [VARCHAR](25) NULL,
	[BundleDeal] [VARCHAR](50) NULL,
	[CreatedDate] [DATETIME] NULL,
	[DownloadFlag] [VARCHAR](1) NULL
)
END
GO
IF NOT EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'ETL_SAPPurchaseDetails' AND xtype='U')
BEGIN
CREATE TABLE ETL_SAPPurchaseDetails(
	[CmpInvNo] [VARCHAR](25) NULL,
	[CmpInvDate] [DATETIME] NULL,
	[SupplierCode] [VARCHAR](50) NULL,
	[SAPPrdCode] [VARCHAR](100) NULL,
	[SAPPrdName] [VARCHAR](300) NULL,
	[PrdId] [INT] NULL,	
	[BatchNo] [VARCHAR](100) NULL,
	[POUOMId] [INT] NULL,
	[UOMCode] [VARCHAR](50) NULL,
	[POQty] [INT] NULL,
	[PurchaseRate] [NUMERIC](18, 2) NULL,
	[Gross]  [NUMERIC](18, 2) NULL,
	[DiscountAmount] [numeric](18, 2) NULL,
	[TaxAmount] [numeric](18, 2) NULL,
	[NetAmount] [numeric](18, 2) NULL,
	[FreightCharges] [numeric](18, 2) NULL,	
	[TotalTax] [NUMERIC](18, 2) NULL,
	[NetValue] [NUMERIC](18, 2) NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME = 'SAPPurchaseReceiptDetails' AND xtype='U')
BEGIN
CREATE TABLE SAPPurchaseReceiptDetails(
	[PurRcptId]  [BIGINT]NULL,
	[CmpInvNo] [VARCHAR](25) NULL,
	[CmpInvDate] [DATETIME] NULL,
	[SupplierCode] [VARCHAR](50) NULL,
	[SAPPrdCode] [VARCHAR](100) NULL,
	[SAPPrdName] [VARCHAR](300) NULL,
	[PrdId] [INT] NULL,	
	[BatchNo] [VARCHAR](100) NULL,
	[POUOMId] [INT] NULL,
	[UOMCode] [VARCHAR](50) NULL,
	[POQty] [INT] NULL,
	[PurchaseRate] [NUMERIC](18, 2) NULL,
	[Gross]  [NUMERIC](18, 2) NULL,
	[DiscountAmount] [numeric](18, 2) NULL,
	[TaxAmount] [numeric](18, 2) NULL,
	[NetAmount] [numeric](18, 2) NULL,
	[FreightCharges] [numeric](18, 2) NULL,	
	[TotalTax] [NUMERIC](18, 2) NULL,
	[NetValue] [NUMERIC](18, 2) NULL,
	[Availability] [int] NULL,
	[AuthDate] [DATETIME] NULL,
	[AuthId] [INT] NULL,
	[LastModDate] [DATETIME] NULL,
	[LastModBy] [INT] NULL
) ON [PRIMARY]
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_CN2CS_PurchaseWithLocationCode' AND xtype='P')
DROP PROCEDURE Proc_CN2CS_PurchaseWithLocationCode
GO
/*
BEGIN TRANSACTION
EXEC Proc_CN2CS_PurchaseWithLocationCode 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_CN2CS_PurchaseWithLocationCode
(
	@Po_ErrNo INT OUTPUT
)
AS
/***********************************************************
* PROCEDURE	: Proc_CN2CS_PurchaseWithLocationCode
* PURPOSE	: To Insert the records FROM Console into Tables
* SCREEN	: Console Integration-PurchaseReceipt
* CREATED BY: S.Moorthi
* MODIFIED	: 23/12/2014
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*************************************************************/
SET NOCOUNT ON
BEGIN
	
	--------------------------------------
	DECLARE @ErrStatus			INT
	DECLARE @PrdBatCode			NVARCHAR(200)
	DECLARE @ProductCode		NVARCHAR(100)
	DECLARE @SAPProductName		NVARCHAR(300)
	DECLARE @ListPrice			NUMERIC(38,6)
	DECLARE @FreeSchemeFlag		NVARCHAR(5)
	DECLARE @CompInvNo			NVARCHAR(25)
	DECLARE @UOMCode			NVARCHAR(25)
	DECLARE @Qty				INT
	DECLARE @PurchaseDiscount	NUMERIC(38,6)
	DECLARE @VATTaxValue		NUMERIC(38,6)
	DECLARE @SchemeRefrNo		NVARCHAR(25)
	DECLARE @SupplierCode		NVARCHAR(30)
	DECLARE @TransporterCode	NVARCHAR(30)
	DECLARE @POUOM				INT
	DECLARE @RowId				INT
	DECLARE @LineLvlAmt			NUMERIC(38,6)
	DECLARE @QtyInKg			NUMERIC(38,6)
	DECLARE @ExistCompInvNo		NVARCHAR(25)
	DECLARE @FreightCharges		NUMERIC(38,6)
	DECLARE @NetValue		NUMERIC(38,6)
	DECLARE @TotalTax		NUMERIC(38,6)	
	DECLARE @PrdId			AS  INT  
	DECLARE @PrdBatId		AS  INT  
	DECLARE @CompInvDate		AS  DATETIME
	DECLARE @InvUOMId	AS  INT 
	DECLARE @ConsoleProductCode	NVARCHAR(200)
	DECLARE @BatchNo	NVARCHAR(200) 
	
	DELETE FROM CN2CS_Prk_PurchaseWithLocationCode WHERE DownLoadFlag='Y'
	
	DELETE FROM ETL_SAPPurchaseDetails WHERE CmpInvNo in
	(SELECT DISTINCT CmpInvNo FROM SAPPurchaseReceiptDetails)
	
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'InvToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE InvToAvoid	
	END
	CREATE TABLE InvToAvoid
	(
		CmpInvNo NVARCHAR(50)
	)
	
	IF EXISTS(SELECT DISTINCT CompInvNo FROM CN2CS_Prk_PurchaseWithLocationCode
	WHERE CompInvNo IN (SELECT CmpInvNo FROM PurchaseReceipt))
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM CN2CS_Prk_PurchaseWithLocationCode
		WHERE CompInvNo IN (SELECT CmpInvNo FROM PurchaseReceipt)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt With Location Code','CmpInvNo','Company Invoice No:'+CompInvNo+' Already Available in Purchase Receipt' FROM CN2CS_Prk_PurchaseWithLocationCode
		WHERE CompInvNo IN (SELECT CmpInvNo FROM PurchaseReceipt)
	END
	
	IF EXISTS(SELECT DISTINCT CompInvNo FROM CN2CS_Prk_PurchaseWithLocationCode
	WHERE CompInvNo IN (SELECT CmpInvNo FROM ETL_SAPPurchaseDetails))
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM CN2CS_Prk_PurchaseWithLocationCode
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETL_SAPPurchaseDetails)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt With Location Code','CmpInvNo','Company Invoice No:'+CompInvNo+' Already Available in Purchase Receipt With Location Code' FROM CN2CS_Prk_PurchaseWithLocationCode
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETL_SAPPurchaseDetails)
	END
	
	IF EXISTS(SELECT DISTINCT CompInvNo FROM CN2CS_Prk_PurchaseWithLocationCode
	WHERE CompInvNo NOT IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt))
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM CN2CS_Prk_PurchaseWithLocationCode
		WHERE CompInvNo NOT IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt With Location Code','CmpInvNo','Company Invoice No:'+CompInvNo+' already downloaded and ready for invoicing' FROM CN2CS_Prk_PurchaseWithLocationCode
		WHERE CompInvNo NOT IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt)
	END
	
	IF EXISTS(SELECT DISTINCT CompInvNo FROM CN2CS_Prk_PurchaseWithLocationCode A(NOLOCK) 
	INNER JOIN Product B(NOLOCK) ON A.ConsoleProductCode=B.PrdCCode 
	WHERE NOT EXISTS(SELECT PrdId FROM ETLTempPurchaseReceiptProduct C(NOLOCK) WHERE B.PrdId=C.PrdId))
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM CN2CS_Prk_PurchaseWithLocationCode A(NOLOCK) 
		INNER JOIN Product B(NOLOCK) ON A.ConsoleProductCode=B.PrdCCode 
		WHERE NOT EXISTS(SELECT PrdId FROM ETLTempPurchaseReceiptProduct C(NOLOCK) WHERE B.PrdId=C.PrdId)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt With Location Code','PurchaseReceiptWithLocationCode','Product:'+ConsoleProductCode+' Not Available for Invoice:'+CompInvNo FROM CN2CS_Prk_PurchaseWithLocationCode A(NOLOCK) 
		INNER JOIN Product B(NOLOCK) ON A.ConsoleProductCode=B.PrdCCode 
		WHERE NOT EXISTS(SELECT PrdId FROM ETLTempPurchaseReceiptProduct C(NOLOCK) WHERE B.PrdId=C.PrdId)
	END
	
	--IF EXISTS(SELECT DISTINCT CompInvNo FROM CN2CS_Prk_PurchaseWithLocationCode
	--WHERE ConsoleProductCode+'~'+BatchNo
	--NOT IN
	--(SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId))
	--BEGIN
	--	INSERT INTO InvToAvoid(CmpInvNo)
	--	SELECT DISTINCT CompInvNo FROM CN2CS_Prk_PurchaseWithLocationCode
	--	WHERE ConSoleProductCode+'~'+BatchNo
	--	NOT IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
		
	--	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	--	SELECT DISTINCT 1,'Purchase Receipt','Product Batch','Product Batch:'+BatchNo+'Not Available for Product:'+ConsoleProductCode+' in Invoice:'+CompInvNo FROM CN2CS_Prk_PurchaseWithLocationCode
	--	WHERE ConsoleProductCode+'~'+BatchNo
	--	NOT IN
	--	(SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)		
	--END
	
	DECLARE Cur_Purchase CURSOR
	FOR
	SELECT CompInvNo,CompInvDate,SupplierCode,ProductCode,ProductName,ConsoleProductCode,BatchNo,UOMCode,PurQty,ListPriceNSP,
	LineLevelAmount,PurchaseDiscount,VATTaxValue,ISNULL(FreightCharges,0) AS FreightCharges,TotalTax,NetValue
	FROM CN2CS_Prk_PurchaseWithLocationCode WHERE [DownLoadFlag]='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
	ORDER BY  CompInvNo,CompInvDate,SupplierCode,ProductCode,ProductName,ConsoleProductCode,BatchNo,UOMCode,PurQty,ListPriceNSP,
	LineLevelAmount,PurchaseDiscount,VATTaxValue,FreightCharges,TotalTax,NetValue
	OPEN Cur_Purchase
	FETCH NEXT FROM Cur_Purchase INTO @CompInvNo,@CompInvDate,@SupplierCode,@ProductCode,@SAPProductName,@ConsoleProductCode,@BatchNo,@UOMCode,@Qty,
	@ListPrice,@LineLvlAmt,@PurchaseDiscount,@VATTaxValue,@FreightCharges,@TotalTax,@NetValue		
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @PrdId =0
		SET @PrdBatId=0
		SET @InvUOMId=0
		SET @Po_ErrNo=0 		
			
		SELECT @PrdId=PrdId FROM Product WITH (NOLOCK) WHERE PrdCCode=@ConsoleProductCode  		
		--SELECT @PrdBatId=PrdBatId FROM ProductBatch WITH (NOLOCK) WHERE PrdBatCode=@PrdBatCode AND PrdId=@PrdId  
		SELECT @InvUOMId=UOMId FROM UOMMaster WITH (NOLOCK) WHERE UOMCode=@UOMCode 
		
			INSERT INTO  ETL_SAPPurchaseDetails
				(					
					CmpInvNo,
					CmpInvDate,
					SupplierCode,
					SAPPrdCode,
					SAPPrdName,
					PrdId,
					BatchNo,
					POUOMId,
					UOMCode,
					POQty,
					PurchaseRate,
					Gross,
					DiscountAmount,
					TaxAmount,
					NetAmount,
					FreightCharges,
					TotalTax,
					NetValue
				)	
				SELECT 				   
					   @CompInvNo,
					   @CompInvDate,
					   @SupplierCode,
					   @ProductCode,
					   @SAPProductName,
					   @PrdId,
					   @BatchNo,
					   @InvUOMId,
					   @UOMCode,
					   @Qty,
					   @ListPrice,
					   @LineLvlAmt,
					   @PurchaseDiscount,
					   @VATTaxValue,
					   (@ListPrice-@PurchaseDiscount+@VATTaxValue)* @Qty,
					   @FreightCharges,
					   @TotalTax,
					   @NetValue				   
				   
		FETCH NEXT FROM Cur_Purchase INTO @CompInvNo,@CompInvDate,@SupplierCode,@ProductCode,@SAPProductName,@ConsoleProductCode,
		@BatchNo,@UOMCode,@Qty,@ListPrice,@LineLvlAmt,@PurchaseDiscount,@VATTaxValue,@FreightCharges,@TotalTax,@NetValue
	END
	CLOSE Cur_Purchase
	DEALLOCATE Cur_Purchase
	
	
	UPDATE CN2CS_Prk_PurchaseWithLocationCode SET DownLoadFlag='Y'
	WHERE CompInvNo IN (SELECT DISTINCT CmpInvNo FROM ETL_SAPPurchaseDetails)
	
	SET @Po_ErrNo= @ErrStatus
	RETURN
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Import_PurchaseWithLocationCode' AND xtype='P')
DROP PROCEDURE Proc_Import_PurchaseWithLocationCode
GO
CREATE PROCEDURE Proc_Import_PurchaseWithLocationCode
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_PurchaseWithLocationCode
* PURPOSE		: To Insert and Update records  from xml file in the Table Purchase Receipt With Location Code
* CREATED		: S.Moorthi
* CREATED DATE	: 23/12/2014
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	INSERT INTO CN2CS_Prk_PurchaseWithLocationCode([DistCode],[CompInvNo],[CompInvDate],[NetValue],[TotalTax],[LessDiscount],[LessSchemeAmount],
	[SupplierCode],[CompanyName],[TransporterName],[LRNO],[LRDate],[ProductCode],[ProductName],[ConsoleProductCode],[UOMCode],
	[PurQty],[CashDiscRs],[CashDiscPer],[LineLevelAmount],[BatchNo],[ManufactureDate],[ExpiryDate],
	[MRP],[ListPriceNSP],[PurchaseTaxValue],[PurchaseDiscount],[PurchaseRate],[SellingRate],
	[SellingRateAfterTAX],[SellingRateAfterVAT],[FreightCharges],[VatBatch],[VATTaxValue],[Status],[FreeSchemeFlag],
	[SchemeRefrNo],[WayBillNo],[BundleDeal],[DownloadFlag],[CreatedDate])
	SELECT  [DistCode],[CompInvNo],[CompInvDate],[NetValue],[TotalTax],[LessDiscount],[LessSchemeAmount],
	[SupplierCode],[CompanyName],[TransporterName],[LRNO],[LRDate],[ProductCode],[ProductName],[ConsoleProductCode],[UOMCode],
	[PurQty],[CashDiscRs],[CashDiscPer],[LineLevelAmount],[BatchNo],[ManufactureDate],[ExpiryDate],
	[MRP],[ListPriceNSP],[PurchaseTaxValue],[PurchaseDiscount],[PurchaseRate],[SellingRate],
	[SellingRateAfterTAX],[SellingRateAfterVAT],[FreightCharges],[VatBatch],[VATTaxValue],[Status],[FreeSchemeFlag],
	[SchemeRefrNo],[WayBillNo],[BundleDeal],DownloadFlag,[CreatedDate]
	FROM 	OPENXML (@hdoc,'/Root/Console2CS_PurchaseWithLocationCode',1)
	WITH 
	(
		[DistCode]				NVARCHAR(50) ,
		[CompInvNo] 	  		NVARCHAR(25) ,
		[CompInvDate] 			DATETIME ,
		[NetValue]   			NUMERIC(18,2) ,
		[TotalTax] 	  			NUMERIC(18,2) ,
		[LessDiscount] 			NUMERIC(18,2) ,
		[LessSchemeAmount]		NUMERIC(18,2) ,
		[SupplierCode] 			NVARCHAR(50) ,
		[CompanyName]			NVARCHAR(100) ,
		[TransporterName] 		NVARCHAR(50) ,
		[LRNO]   				NVARCHAR(15) ,
		[LRDate] 	  			DATETIME ,		
		[ProductCode] 			NVARCHAR(100) ,
		[ProductName] 			NVARCHAR(300) ,		
		[ConsoleProductCode]	NVARCHAR(100),
		[UOMCode] 				NVARCHAR(25) ,
		[PurQty]  	 			INT ,
		[CashDiscRs]   			NUMERIC(18,2) ,
		[CashDiscPer]   		NUMERIC(18,2) ,
		[LineLevelAmount] 		NUMERIC(18,2) ,
		[BatchNo] 				NVARCHAR(50) ,
		[ManufactureDate]		DATETIME ,
		[ExpiryDate] 	  		DATETIME ,
		[MRP] 					NUMERIC(18,2) ,
		[ListPriceNSP]   		NUMERIC(18,2) ,
		[PurchaseTaxValue] 		NUMERIC(18,2) ,
		[PurchaseDiscount] 		NUMERIC(18,2) ,
		[PurchaseRate]   		NUMERIC(18,2) ,
		[SellingRate]   		NUMERIC(18,2) ,
		[SellingRateAfterTAX]	NUMERIC(18,2) ,
		[SellingRateAfterVAT]	NUMERIC(18,2) ,
		[FreightCharges]		NUMERIC(18,2) ,
		[VatBatch] 	  			INT ,
		[VATTaxValue] 			NUMERIC(18,2) ,
		[Status]   				INT ,
		[FreeSchemeFlag] 		NVARCHAR(5) ,
		[SchemeRefrNo] 			NVARCHAR(25) ,
		[WayBillNo]   			NVARCHAR(50) ,
		[BundleDeal] 	  		NVARCHAR(50) ,
		[DownloadFlag] 			NVARCHAR(1),
		[CreatedDate]			DATETIME		
	) XMLObj
	SELECT * FROM Cn2Cs_Prk_BLPurchaseReceipt
	EXECUTE sp_xml_removedocument @hDoc
END
GO
DELETE FROM CUSTOMCAPTIONS WHERE TransId=279
INSERT INTO CUSTOMCAPTIONS([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
SELECT 279,1,1,'lblCmpInvNo','Company Inv No. :','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Company Inv No. :','','',1,1
UNION
SELECT 279,2,1,'lblInvDate','Invoice Date','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Invoice Date','','',1,1
UNION
SELECT 279,3,1,'lblTotalNet','Total Net Amount','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Total Net Amount','','',1,1
UNION
SELECT 279,4,1,'CoreHeaderTool','Purchase Receipt With Location Code','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Purchase Receipt With Location Code','','',1,1
UNION
SELECT 279,4,2,'CoreHeaderTool','Stocky','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Stocky','','',1,1
UNION
SELECT 279,5,2,'DgCommon-279-5-2','Product Code','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Product Code','','',1,1
UNION
SELECT 279,5,3,'DgCommon-279-5-3','Product Name','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Product Name','','',1,1
UNION
SELECT 279,5,4,'DgCommon-279-5-4','Comp. Product Code','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Comp. Product Code','','',1,1
UNION
SELECT 279,5,5,'DgCommon-279-5-5','Comp. Product Name','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Comp. Product Code','','',1,1
UNION
SELECT 279,5,6,'DgCommon-279-5-6','Batch Code','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Batch Code','','',1,1
UNION
SELECT 279,5,7,'DgCommon-279-5-7','UOM Code','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'UOM Code','','',1,1
UNION
SELECT 279,5,8,'DgCommon-279-5-8','Qty','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Qty','','',1,1
UNION
SELECT 279,5,9,'DgCommon-279-5-9','Rate','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Rate','','',1,1
UNION
SELECT 279,5,10,'DgCommon-279-5-10','Gross Amt','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Gross Amt','','',1,1
UNION
SELECT 279,5,11,'DgCommon-279-5-11','Disc Amt','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Disc Amt','','',1,1
UNION
SELECT 279,5,12,'DgCommon-279-5-12','Tax Amt','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Tax Amt','','',1,1
UNION
SELECT 279,5,13,'DgCommon-279-5-13','Net Amount','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'Net Amount','','',1,1
UNION
SELECT 279,6,0,'btnOperation','&OK','','',1,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121),'&OK','','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=5 AND CtrlId=39
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
SELECT 5,39,1,'fxtCmpInvNo','CmpInvNo','Press F6 to Download Invoice,F7 to display SAP Invoice Details','',1,1,1,'2009-09-06',1,'2009-09-06','Column Value','Press F6 to Download Invoice,F7 to display SAP Invoice Details','',1,1
GO
DELETE FROM CustomCaptions WHERE TransId=5 AND CtrlId=2000 AND SubCtrlId=105
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
SELECT 5,2000,105,'PnlMsg-5-1000-105','','Press F7 to Display SAP Invoice Details','',1,1,1,'2009-09-06',1,'2009-09-06','Column Value','Press F7 to Display SAP Invoice Details','',1,1
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='FN_GetPurchaseReceiptWithLoc' AND xtype IN ('TF','FN'))
DROP FUNCTION FN_GetPurchaseReceiptWithLoc
GO
CREATE FUNCTION FN_GetPurchaseReceiptWithLoc(@CmpInvNo as varchar(100))        
RETURNS @pTempTbl TABLE         
 (  
	SlNo  int,  
	CmpInvNo VARCHAR(100),
	PrdId int,	
	PrdCCode VARCHAR(100),
	PrdName VARCHAR(200),
	SAPPrdCode VARCHAR(100),
	SAPPrdName VARCHAR(300),
	BatchCode VARCHAR(100),
	UomCode VARCHAR(50),
	Qty INT,
	Rate NUMERIC(18,3),
	GrossAmt NUMERIC(18,3),
	DiscAmt NUMERIC(18,3),
	TaxAmt NUMERIC(18,3),
	NetAmt NUMERIC(18,3),
	NetValue NUMERIC(18,3)
 )        
AS         
 BEGIN    
 
     
	IF EXISTS(SELECT DISTINCT CmpInvNo FROM SAPPurchaseReceiptDetails(NOLOCK) WHERE CmpInvNo=@CmpInvNo)
	BEGIN
		 INSERT INTO @pTempTbl
		 SELECT 
				1 as SlNo,	
				CmpInvNo,
				A.PrdId,				
				PrdCCode,		
				B.PrdName,
				SAPPrdCode,
				SAPPrdName,	
				BatchNo,
				UOMCode,
				POQty,
				PurchaseRate,
				Gross,
				DiscountAmount,
				TaxAmount,
				NetAmount,
				NetValue
				FROM SAPPurchaseReceiptDetails A (NOLOCK) 
				INNER JOIN Product B(NOLOCK) ON A.PrdId=B.PrdId
				--INNER JOIN ProductBatch C(NOLOCK) ON A.PrdId=C.PrdId and A.PrdBatId=C.PrdBatId 
				WHERE A.CmpInvNo=@CmpInvNo
	END
	ELSE
	BEGIN
		INSERT INTO @pTempTbl
		 SELECT 
				2 as SlNo,	
				CmpInvNo,
				A.PrdId,					
				PrdCCode,		
				B.PrdName,
				SAPPrdCode,		
				SAPPrdName,
				BatchNo,
				UOMCode,
				POQty,
				PurchaseRate,
				Gross,
				DiscountAmount,
				TaxAmount,
				NetAmount,
				NetValue
				FROM ETL_SAPPurchaseDetails A (NOLOCK) 
				INNER JOIN Product B(NOLOCK) ON A.PrdId=B.PrdId
				--INNER JOIN ProductBatch C(NOLOCK) ON A.PrdId=C.PrdId and A.PrdBatId=C.PrdBatId 
				WHERE A.CmpInvNo=@CmpInvNo
	END
    
      
 RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_Cs2Cn_Stock' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_Stock
GO
/*
BEGIN TRANSACTION
SELECT * FROM DayEndProcess
UPDATE DayEndProcess Set NextUpDate = '2008-12-01' Where procId = 11
DELETE FROM Cs2Cn_Prk_Stock
SELECT * FROM ETL_PrkCS2CNStkInventory WHERE [PRODUCTCODE]='701016' ORDER BY salInvDate
EXEC Proc_Cs2Cn_Stock 0,'2015-01-05'
SELECT * FROM StockLedger WHERE TransDate>='2008/12/01'
SELECT * FROM Cs2Cn_Prk_Stock
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_Stock
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_CS2CNStkInventoryNew
* PURPOSE		: To Extract Stock Ledger Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 19/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpId 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @DefCmpAlone	AS INT
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_Stock WHERE UploadFlag = 'Y'
	SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DefCmpAlone=ISNULL(Status,0) FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where ProcId = 11
	INSERT INTO Cs2Cn_Prk_Stock(DistCode,TransDate,LcnId,LcnCode,PrdId,PrdCode,PrdBatId,PrdBatCode,SalOpenStock,UnSalOpenStock,
	OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,SalSales,UnSalSales,OfferSales,
	SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,SalSalesReturn,UnSalSalesReturn,
	OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,
	OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,
	OfferLcnTfrOut,SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,UploadFlag)
	SELECT @DistCode,TransDate,SL.LcnId,L.LcnCode,SL.PrdId,P.PrdCCode,SL.PrdBatId,PB.CmpBatCode,SalOpenStock,UnSalOpenStock,OfferOpenStock,SalPurchase,
	UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,SalSales,UnSalSales,OfferSales,
	SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,DamageOut,
	SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,
	UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,
	OfferBatTfrOut,SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,
	SalReplacement,OfferReplacement,SalClsStock,UnSalClsStock,OfferClsStock,'N'
	FROM StockLedger SL (NOLOCK),Product P (NOLOCK),ProductBatch PB (NOLOCK),Location L (NOLOCK)
	WHERE SL.PrdId=P.PrdId AND SL.PrdBatId=PB.PrdBatId AND P.PrdId=PB.PrdId
	AND P.CmpId=(CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE P.CmpId END)
	/*Code Commented by Muthuvelsamy R for the ICRSTHUT0188 begins here*/	
	AND SL.LcnId=L.LcnId AND Sl.TransDate>=@ChkDate	--AND (SalPurchase+UnsalPurchase+OfferPurchase+SalPurReturn+UnsalPurReturn+
	--OfferPurReturn+SalSales+UnSalSales+OfferSales+SalStockIn+UnSalStockIn+OfferStockIn+SalStockOut+UnSalStockOut+OfferStockOut+
	--DamageIn+DamageOut+SalSalesReturn+UnSalSalesReturn+OfferSalesReturn+SalStkJurIn+UnSalStkJurIn+OfferStkJurIn+SalStkJurOut+
	--UnSalStkJurOut+OfferStkJurOut+SalBatTfrIn+UnSalBatTfrIn+OfferBatTfrIn+SalBatTfrOut+UnSalBatTfrOut+OfferBatTfrOut+SalLcnTfrIn+
	--UnSalLcnTfrIn+OfferLcnTfrIn+SalLcnTfrOut+UnSalLcnTfrOut+OfferLcnTfrOut+SalReplacement+OfferReplacement+
	--SalOpenStock+UnSalOpenStock+OfferOpenStock+SalClsStock+UnSalClsStock+offerClsStock)>0
	/*Code Commented by Muthuvelsamy R for the ICRSTHUT0188 ends here*/		
	
	---SalOpenStock,UnSalOpenStock,OfferOpenStock,SalClsStock,UnSalClsStock,offerClsStock
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GETDATE(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	WHERE ProcId = 11
	UPDATE Cs2Cn_Prk_Stock SET ServerDate=@ServerDate
END
GO
--PARLE Special Discount
DECLARE @ConfigValue AS INT
SELECT @ConfigValue = SlNo FROM BatchCreation (NOLOCK) WHERE SelRte = 1
DELETE FROM Configuration WHERE ModuleId = 'SPLDISC'
INSERT INTO Configuration (ModuleId,ModuleName,[Description],[Status],Condition,ConfigValue,SeqNo)
SELECT 'SPLDISC','SpecialDiscount','Apply Discount Percentage on',1,'',@ConfigValue,1
GO
DELETE FROM Tbl_DownloadINTegration WHERE ProcessName='SpecialDiscount'
INSERT INTO Tbl_DownloadINTegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate]) 
SELECT 53,'SpecialDiscount','Cn2Cs_Prk_SpecialDiscount','Proc_Import_SpecialDiscount',0,500,GETDATE()
GO
DELETE FROM CustomUpDownload WHERE MODULE='SpecialDiscount'
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],
[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) 
SELECT 244,1,'SpecialDiscount','SpecialDiscount','Proc_Cn2Cs_SpecialDiscount','Proc_Import_SpecialDiscount',
'Cn2Cs_Prk_SpecialDiscount','Proc_Cn2Cs_SpecialDiscount','Master','Download',1
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'U' AND name = 'Cn2Cs_Prk_SpecialDiscount')
DROP TABLE Cn2Cs_Prk_SpecialDiscount
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_SpecialDiscount]
(
	[DistCode] [nvarchar](100) NULL,
	[RetCategoryLevel] [nvarchar](100) NULL,
	[RetCatLevelValue] [nvarchar](100) NULL,
	[PrdCategoryLevel] [nvarchar](100) NULL,
	[PrdCategoryLevelValue] [nvarchar](100) NULL,
	[DiscPer] [numeric](18, 2) NULL,
	[EffFromDate] [datetime] NULL,
	[EffToDate] [datetime] NULL,
	[DownLoadFlag] [nvarchar](1) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND name = 'Proc_Import_SpecialDiscount')
DROP PROCEDURE Proc_Import_SpecialDiscount
GO
--Exec Proc_Import_SpecialDiscount '<Root></Root>'
CREATE PROCEDURE Proc_Import_SpecialDiscount
(
	@Pi_Records NTEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_SpecialDiscount
* PURPOSE		: To Insert records from xml file in the Table Cn2Cs_Prk_SpecialDiscount
* CREATED BY	: Muthukrishnan.G.P
* CREATED DATE	: 31-12-2012
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Cn2Cs_Prk_SpecialDiscount(DistCode,RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue
	                                      ,DiscPer,EffFromDate,EffToDate,DownLoadFlag,CreatedDate)
	SELECT [DistCode],[RetCatLvl],[RetCatVal],[PrdCatLvl],[PrdCatVal],[DiscPer],
		   [EffFromDate],[EffToDate],[DownLoadFlag],[CreatedDate]
	FROM OPENXML (@hdoc,'/Root/Console2CS_SpecialDiscount',1)
	WITH
	(
	[DistCode]     NVARCHAR(100),
	[RetCatLvl]    NVARCHAR(100),
	[RetCatVal]    NVARCHAR(100),
	[RtrCode]      NVARCHAR(100),
	[PrdCatLvl]    NVARCHAR(100),
	[PrdCatVal]    NVARCHAR(100),
	[DiscPer]      NUMERIC(18,6),
	[EffFromDate]  DATETIME,
	[EffToDate]    DATETIME,
	[DownLoadFlag] NVARCHAR(1),
	[CreatedDate]  DATETIME
	) XMLObj
	EXEC sp_xml_removedocument @hDoc
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'U' AND name = 'TempSpecialRateDiscountProduct')
DROP TABLE TempSpecialRateDiscountProduct
GO
CREATE TABLE [dbo].[TempSpecialRateDiscountProduct](
	[SlNo] [bigint] IDENTITY(1,1) NOT NULL,
	[CtgLevelName] [nvarchar](100) NULL,
	[CtgCode] [nvarchar](100) NULL,
	[RtrCode] [nvarchar](100) NULL,
	[PrdCCode] [nvarchar](100) NULL,
	[PrdBatCode] [nvarchar](100) NULL,
	[DiscPer] [numeric](18, 2) NULL,
	[SpecialSellingRate] [numeric](38, 6) NULL,
	[EffectiveFromDate] [datetime] NULL,
	[EffectiveToDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT CmpPrdCtgName FROM ProductCategoryLevel (NOLOCK) WHERE CmpPrdCtgName = 'Flavor' AND LevelName = 'Level5')
BEGIN
    UPDATE ProductCategoryLevel SET CmpPrdCtgName='Brand' WHERE  LevelName='Level3'
    UPDATE ProductCategoryLevel SET CmpPrdCtgName='PriceSlot' WHERE  LevelName='Level4'
    UPDATE ProductCategoryLevel SET CmpPrdCtgName='Flavor' WHERE  LevelName='Level5'
    
	DELETE A FROM ProductCategoryValue A (NOLOCK) WHERE PrdCtgValCode <> 'PRL'
	DECLARE @PrdCtgValMainId AS NUMERIC(18,0)
	SELECT @PrdCtgValMainId = ISNULL(MAX(PrdCtgValMainId),0) FROM ProductCategoryValue (NOLOCK)
	UPDATE Counters SET CurrValue = @PrdCtgValMainId WHERE TabName = 'ProductCategoryValue' AND FldName = 'PrdCtgValMainId'
	TRUNCATE TABLE Cn2Cs_Prk_Product
	TRUNCATE TABLE Etl_Prk_TaxConfig_GroupSetting
	TRUNCATE TABLE Etl_Prk_TaxSetting
	TRUNCATE TABLE Etl_Prk_TaxMapping
END
GO
EXEC Proc_GR_Build_PH
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_ExportPDA_Product' AND XTYPE ='P')
DROP PROCEDURE PROC_ExportPDA_Product
GO
--EXEC PROC_ExportPDA_Product  
CREATE PROCEDURE PROC_ExportPDA_Product
AS
BEGIN
DECLARE @FromDate DATETIME
DECLARE @ToDate  DATETIME
DECLARE @DistCode nVarchar(50)
DECLARE @Smcode Nvarchar(50)
CREATE TABLE #tempproduct(Prdid INT)
	EXEC Proc_GR_Build_PH
	
	SELECT @FromDate=dateadd(MM,-3,getdate())
	SELECT @ToDate=CONVERT(VARCHAR(10),getdate(),121)
	SELECT @DistCode=DistributorCode  from Distributor
	SET @Smcode=(SELECT DISTINCT SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid)
	
	INSERT INTO #tempproduct
	SELECT DISTINCT PrdId FROM SalesInvoice SI inner join SalesInvoiceProduct SIP on SI.SalId=SIP.SalId
	WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) 
	
	INSERT INTO #tempproduct	
	SELECT DISTINCT PrdId FROM PurchaseReceipt G inner join PurchaseReceiptProduct GP on G.PurRcptId=GP.PurRcptId where G.InvDate
	BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) 
	
	INSERT INTO #tempproduct	
	SELECT DISTINCT PrdId FROM stockledger where TransDate
	BETWEEN CONVERT(VARCHAR(10),@FromDate,121) AND CONVERT(VARCHAR(10),@ToDate,121) 
	
	DELETE FROM Cos2Mob_Product-- WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_Product (DistCode,SrpCde,PrdId,PrdName, PrdShrtNm,PrdCCode,SpmId,PrdWgt,PrdUnitId,UomGroupId,TaxGroupId,PrdType,CmpId,PrdCtgValMainId,FocusBrand,
	                             FrqBilledPrd,CategoryID,CAtegoryCode,CategoryName,Brandid,BtrandCode,BrandName,UploadFlag,DefaultUomid)
	SELECT DISTINCT @DistCode,@Smcode,P.PrdId,PrdName,PrdShrtName,PrdCCode,SpmId,PrdWgt,PrdUnitId,p.UomGroupId,TaxGroupId,PrdType,CmpId,PrdCtgValMainId,0,0,
	T.PriceSlot_Id,T.PriceSlot_Code,T.PriceSlot_Caption,T.Flavor_Id,T.Flavor_Code,T.Flavor_Caption,'N' AS UploadFlag,U.UomId
	FROM Product P INNER JOIN  TBL_GR_BUILD_PH T on T.PrdId=p.PrdId inner join #tempproduct tp on p.PrdId=tp.Prdid and t.PRDID=tp.Prdid
	INNER JOIN UOMGROUP U ON U.UomGroupId=P.UomGroupId AND BASEUOM='Y'
	WHERE PrdStatus=1
	
	SELECT  DISTINCT A.PRDID,count(A.prdid)AS SOLD,C.PrdName,C.PrdCCode INTO #SRI
	FROM SalesInvoiceproduct A
	INNER JOIN SalesInvoice B ON a.SalId=B.SalId
	INNER JOIN Product C ON a.prdid=C.prdid
    WHERE b.SalInvDate BETWEEN dateadd(month, -3, getdate()) AND CONVERT(VARCHAR(10),GETDATE(),121)
	GROUP BY a.prdid,c.PrdName,C.PrdCCode 
	
    UPDATE Cos2Mob_Product SET FrqBilledPrd=1 WHERE prdid IN (SELECT TOP 10 prdid FROM  #SRI GROUP BY prdid,PrdName,SOLD ORDER BY SOLD DESC)
	
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE NAME='PROC_ExportPDA_SchemeProductDetails' AND XTYPE='P' )
DROP PROCEDURE PROC_ExportPDA_SchemeProductDetails
GO
--Exec PROC_ExportPDA_SchemeProductDetails 'DS01'
CREATE PROCEDURE PROC_ExportPDA_SchemeProductDetails
AS
BEGIN
	DELETE FROM Cos2Mob_SchemeProductDetails -- Where UploadFlag='Y'
	
	INSERT INTO Cos2Mob_SchemeProductDetails(DistCode,SrpCde,CmpschCode,SchDsc,Prdcode,Prdname,UploadFlag)
	SELECT DistributorCode,SMCODE,CmpSchCode,SchDsc,PrdCCode,PrdName,'N' as UploadFlag FROM 
		(
		SELECT CmpSchCode,SchDsc,PrdCCode,PrdName FROM SchemeMaster SM 
			INNER JOIN SchemeProducts SP ON SM.SchId=SP.SchId 
			INNER JOIN ProductCategoryValue PC ON PC.PrdCtgValMainId=SP.PrdCtgValMainId
			INNER JOIN TBL_GR_BUILD_PH T ON PC.PrdCtgValMainId=CASE PC.CmpPrdCtgId WHEN 2 THEN Category_Id
																	WHEN 3 THEN Brand_Id
																	WHEN 4 THEN PriceSlot_Id
																	WHEN 5 THEN Flavor_Id									
																	END 			
			INNER JOIN Product P ON P.PrdId=T.PrdId  
		WHERE SchStatus=1  AND CONVERT(varchar(10),getdate(),121)  BETWEEN SchValidFrom AND SchValidtill	
	  UNION ALL
  		SELECT CmpSchCode,SchDsc,PrdCCode,PrdName FROM SchemeMaster SM 
			INNER JOIN SchemeProducts SP ON SM.SchId=SP.SchId 
			INNER JOIN Product P ON P.PrdId=SP.PrdId
		WHERE SchStatus=1 AND CONVERT(varchar(10),getdate(),121)  BETWEEN SchValidFrom AND SchValidtill
        )A
		CROSS JOIN (SELECT DISTINCT SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) S
		CROSS JOIN Distributor
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE NAME='Proc_ExportPDA_SchemeNarration' AND XTYPE='P' )
DROP PROCEDURE Proc_ExportPDA_SchemeNarration
GO
--Exec Proc_ExportPDA_SchemeNarration 
--SELECT * FROM Cos2Mob_SchemeNarration
CREATE PROCEDURE Proc_ExportPDA_SchemeNarration
AS
DECLARE @Schid AS int
DECLARE @CtgMainId AS int
DECLARE @CtgLevelId AS int 
DECLARE @RtrClassid AS int 
DECLARE @Slabid AS int
DECLARE @Str AS varchar(500)
DECLARE @EveryQty AS numeric(18,4)
DECLARE @DisCper AS numeric(18,4)
DECLARE @Flatamt AS numeric(18,4)
DECLARE @FreeQty AS int 
DECLARE @Count AS int
DECLARE @ForEveryUomId as int
DECLARE @schtype as int
DECLARE @FromQty as int
DECLARE @ToQty AS INT
BEGIN

DELETE FROM Cos2Mob_SchemeNarration-- Where UploadFlag='Y'
DECLARE Cur_SchemeMater CURSOR
FOR SELECT Schid,schtype FROM SchemeMaster WHERE SchStatus=1 AND Claimable=1 AND CONVERT(varchar(10),getdate(),121)  
          BETWEEN SchValidFrom AND SchValidtill
OPEN Cur_SchemeMater
FETCH next FROM Cur_SchemeMater INTO @Schid,@schtype
WHILE @@FETCH_status=0
BEGIN 
	DECLARE Cur_SchemeNarration CURSOR
	FOR SELECT DISTINCT ss.SlabId,PurQty,DiscPer,FlatAmt,SF.FreeQty,CASE ForEveryUomId WHEN 0 THEN UOMID ELSE ForEveryUomId END,FromQty,ToQty
	FROM SchemeSlabs SS LEFT  OUTER  JOIN SchemeSlabFrePrds SF
		ON SF.SchId = SS.SchId AND SF.SlabId = SS.SlabId WHERE SS.SchId=@Schid
	SET @Count=0
	OPEN Cur_SchemeNarration
	FETCH next FROM Cur_SchemeNarration INTO @Slabid,@EveryQty,@DisCper,@Flatamt,@FreeQty,@ForEveryUomId,@FromQty,@ToQty
	WHILE @@FETCH_status=0
	BEGIN 
		
	IF @Count=0
		BEGIN 
		   IF @EveryQty =0.00
			   BEGIN
					SET @Str='Scheme Applicable-For Purchase Between '+ Cast(@FromQty AS varchar(15)) + 'To ' + Cast(@ToQty AS varchar(15)) +
					CASE @schtype when 1 then (SELECT UOMCODE FROM UomMaster WHERE UOMId=@ForEveryUomId)
						WHEN 2 THEN ' RS'
						WHEN 3 THEN (SELECT PrdUnitCode FROM ProductUnit WHERE PrdUnitId=@ForEveryUomId)
					 END
				print @Str
				END
		   ELSE
			   BEGIN
					SET @Str='Scheme Applicable-For Purchase of Every  '+ Cast(@EveryQty AS varchar(15)) + 
					CASE @schtype when 1 then (SELECT UOMCODE FROM UomMaster WHERE UOMId=@ForEveryUomId)
						WHEN 2 THEN ' RS'
						WHEN 3 THEN (SELECT PrdUnitCode FROM ProductUnit WHERE PrdUnitId=@ForEveryUomId)
						END				
			   END	

			 IF @DisCper>0.00
			  BEGIN   
					SET @Str=@Str +' '+ Cast(@DisCper AS varchar(15)) +''+ '%' +'  Discount'
			  END 	 
			 IF @Flatamt>0.00
			  BEGIN
					SET @Str=@Str + ' '+ Cast(@Flatamt AS varchar(15)) +''+ 'FlatAmount' +''
			  END 
			 IF @FreeQty>0.00
			  BEGIN
					SET @Str=@Str + ' '+ Cast(@FreeQty AS varchar(15)) +' Quantity Free'
			  END 
			END
	ELSE
		 BEGIN 

		   IF @EveryQty=0.00 
			   BEGIN
					SET @Str=@Str + 'And For Purchase Between '+ Cast(@FromQty AS varchar(15)) + 'To ' + Cast(@ToQty AS varchar(15)) +
					CASE @schtype when 1 then (SELECT UOMCODE FROM UomMaster WHERE UOMId=@ForEveryUomId)
						WHEN 2 THEN ' RS'
						WHEN 3 THEN (SELECT PrdUnitCode FROM ProductUnit WHERE PrdUnitId=@ForEveryUomId)
					 END
				END
		   ELSE
			   BEGIN
			SET @Str=@Str +' And For Purchase of Every  '+ Cast(@EveryQty AS varchar(15)) + 
				CASE @schtype WHEN 1 THEN (SELECT UOMCODE FROM UomMaster WHERE UOMId=@ForEveryUomId)
							  WHEN 2 THEN ' RS'
					          WHEN 3 THEN (SELECT PrdUnitCode FROM ProductUnit WHERE PrdUnitId=@ForEveryUomId)
					END			   
			END	

		 IF @DisCper>0.00
			  BEGIN   
					SET @Str=@Str +' '+ Cast(@DisCper AS varchar(15)) +''+ '%' +'  Discount'
			  END 	 
			 IF @Flatamt>0.00
			  BEGIN
					SET @Str=@Str + ' '+ Cast(@Flatamt AS varchar(15)) +''+ 'FlatAmount' +''
			  END 
			 IF @FreeQty>0.00
			  BEGIN
					SET @Str=@Str + ' '+ Cast(@FreeQty AS varchar(15)) +' Quantity Free'
			  END 
		END 
	SET @Count=1
	FETCH next FROM Cur_SchemeNarration INTO @Slabid,@EveryQty,@DisCper,@Flatamt,@FreeQty,@ForEveryUomId,@FromQty,@ToQty
	END 
	CLOSE Cur_SchemeNarration
	DEALLOCATE Cur_SchemeNarration
	
	INSERT INTO Cos2Mob_SchemeNarration (DistCode,SrpCde,Channel,SubType,CmpSchCode,Schdesc,Narration,UploadFlag,ChannelCode,RtrClassId)
		SELECT DistributorCode,SMCODE,RC.CtgName,RVC.ValueClassName,CmpSchCode,SchDsc, cast(@Str AS varchar(500)),'N' AS UploadFlag,RC.CtgCode,RVC.RtrClassId
		FROM SchemeMaster S INNER JOIN SchemeRetAttr SR ON S.SchId=SR.SchId
		INNER JOIN RetailerValueClass RVC ON RVC.RtrClassId=CASE SR.AttrId WHEN 0 THEN RVC.RtrClassId ELSE SR.AttrId END 
		AND SR.AttrType=6
		INNER JOIN RetailerCategory RC ON RC.CtgMainId=RVC.CtgMainId  
		CROSS JOIN (SELECT DISTINCT SMCODE FROM Salesman S INNER JOIN Sales_upload SU on S.SMId=SU.smid) SM
		CROSS JOIN Distributor
		WHERE   S.SchId=@Schid
		
FETCH next FROM Cur_SchemeMater INTO @Schid,@schtype
END 
CLOSE Cur_SchemeMater
DEALLOCATE Cur_SchemeMater
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='PROC_ExportPDA_SalesRepresentative' AND xtype='P')
DROP PROCEDURE PROC_ExportPDA_SalesRepresentative
GO
--EXEC PROC_ExportPDA_SalesRepresentative 2
CREATE PROCEDURE [dbo].[PROC_ExportPDA_SalesRepresentative]
AS
BEGIN
	DELETE FROM Cos2Mob_SalesRepresentative --WHERE UploadFlag='Y'
	INSERT INTO Cos2Mob_SalesRepresentative (DistCode,SrpId,SrpCde,SrpNm,UploadFlag,ImeiNo,SMPassword)
	SELECT DistriButorCode,SMID,SMCode,SMName,'N' AS UploadFlag,'','' FROM SalesMan CROSS JOIN Distributor 
	
	WHERE SMId IN (SELECT SMId FROM Sales_upload) and Status=1
	

	UPDATE C SET ImeiNo=A.IMEINo FROM Cos2Mob_SalesRepresentative C INNER JOIN
	(SELECT SMId,UD.ColumnValue 'IMEINo' FROM UdcMaster UM 
	INNER JOIN UdcDetails UD ON UM.MasterId=UD.MasterId AND UM.UDCMASTERID=UD.UdcMasterId AND UM.ColumnName IN('IMEI No')
	INNER JOIN salesman R ON R.SMId=UD.MASTERRECORDID 
	WHERE UM.MasterId=4 )A ON C.SrpId=A.SMId

	UPDATE C SET SMPassword= LOWER(SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('MD5',  A.Password)), 3, 32)) FROM Cos2Mob_SalesRepresentative C INNER JOIN
	(SELECT SMId,UD.ColumnValue 'Password' FROM UdcMaster UM 
	INNER JOIN UdcDetails UD ON UM.MasterId=UD.MasterId AND UM.UDCMASTERID=UD.UdcMasterId AND UM.ColumnName IN('Password')
	INNER JOIN salesman R ON R.SMId=UD.MASTERRECORDID 
	WHERE UM.MasterId=4 )A ON C.SrpId=A.SMId
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='TBL_INTEGRATIONPATH' AND XTYPE ='U')
DROP TABLE TBL_INTEGRATIONPATH
GO
CREATE TABLE TBL_INTEGRATIONPATH
(
	[INTEGRATION_PATH] [varchar](400) NULL,
	[INTEGRATION_TYPE] [varchar](100) NULL
)
GO
INSERT INTO TBL_INTEGRATIONPATH
SELECT 'http://220.226.206.19//ParlePDAIntegration/ExportToPDA.asmx','ExportPath'
UNION
SELECT 'http://220.226.206.19//ParlePDAIntegration/ImportToPDA.asmx','ImportPath'
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND name = 'Proc_CalculateSpecialDiscountAftRate')
DROP PROCEDURE Proc_CalculateSpecialDiscountAftRate
GO
--EXEC Proc_CalculateSpecialDiscountAftRate
CREATE PROCEDURE Proc_CalculateSpecialDiscountAftRate
AS  
BEGIN  
	 EXEC Proc_GR_Build_PH  
	 TRUNCATE TABLE TempSpecialRateDiscountProduct
	 DELETE FROM Cn2Cs_Prk_SpecialDiscount where DownLoadFlag='Y'   
	 INSERT INTO TempSpecialRateDiscountProduct (CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,DiscPer,SpecialSellingRate,EffectiveFromDate,
     EffectiveToDate,CreatedDate)
	 SELECT DISTINCT A.RetCategoryLevel,A.RetCatLevelValue,'ALL',ProductCode,PrdBatCode,DiscPer,PrdBatDetailValue-(PrdBatDetailValue*(DiscPer/100)) SplRate,EffFromDate,EffToDate,CreatedDate from (  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,EffToDate,CreatedDate 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.COMPANY_Code  
	 WHERE CP.PrdCategoryLevel='COMPANY' and CP.DownloadFlag='D'  
	 UNION   
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,EffToDate,CreatedDate 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.Category_Code  
	 WHERE CP.PrdCategoryLevel='Category'and CP.DownloadFlag='D'  
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,EffToDate,CreatedDate 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.Brand_Code  
	 WHERE CP.PrdCategoryLevel='Brand'and CP.DownloadFlag='D'  
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,EffToDate,CreatedDate 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.PriceSlot_Code  
	 WHERE CP.PrdCategoryLevel='PriceSlot'and CP.DownloadFlag='D'  
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,EffToDate,CreatedDate 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.Flavor_Code  
	 WHERE CP.PrdCategoryLevel='Flavor'and CP.DownloadFlag='D'
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,EffToDate,CreatedDate 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.ProductCode  
	 WHERE CP.PrdCategoryLevel='Product'and CP.DownloadFlag='D'
	 UNION
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,EffToDate,CreatedDate 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.ProductCode  
	 WHERE CP.DownloadFlag='D')A  
	 INNER JOIN Product P (NOLOCK) ON P.PrdId=A.PrdId and A.ProductCode=P.PrdCCode  
	 INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=P.PrdId  
	 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId=PB.PrdBatId  
	 INNER JOIN BatchCreation BC (NOLOCK) ON BC.SlNo=PBD.SLNo
	 INNER JOIN Configuration C (NOLOCK) ON BC.SlNo = ISNULL(CAST(C.ConfigValue AS INT),0)
	 WHERE PBD.DefaultPrice=1 AND C.ModuleId = 'SPLDISC'
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND name = 'Proc_SellingTaxCalCulation')
DROP PROCEDURE Proc_SellingTaxCalCulation
GO
--Exec Proc_SellingTaxCalCulation 528,1654
CREATE PROCEDURE [dbo].[Proc_SellingTaxCalCulation]
(
	@Prdid AS INT,
	@Prdbatid AS INT
	
)
AS
BEGIN
		DECLARE @TaxSettingDet TABLE       
		(      
		TaxSlab   INT,      
		ColNo   INT,      
		SlNo   INT,      
		BillSeqId  INT,      
		TaxSeqId  INT,      
		ColType   INT,       
		ColId   INT,      
		ColVal   NUMERIC(38,2)      
		) 
		DECLARE @PrdBatTaxGrp AS INT
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
		SELECT @PrdBatTaxGrp = TaxGroupId FROM ProductBatch A (NOLOCK) WHERE Prdid=@Prdid and  Prdbatid=@Prdbatid
		SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster (NOLOCK)
		Select @RtrTaxGrp=MIN(Distinct RtriD) FROM TaxSettingMaster (NOLOCK)
		INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)      
		SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal      
		FROM TaxSettingMaster A (NOLOCK) INNER JOIN      
		TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
		AND B.BillSeqId=@BillSeqId  and Coltype IN(1,3)    
		WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp     
		AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE      
		RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp)  
	
		SET @MRP=1
		TRUNCATE TABLE TempProductTax
		DECLARE  CurTax CURSOR FOR      
			SELECT DISTINCT TaxSlab FROM @TaxSettingDet      
		OPEN CurTax        
		FETCH NEXT FROM CurTax INTO @TaxSlab      
		WHILE @@FETCH_STATUS = 0        
		BEGIN      
		SET @TaxableAmount = 0      
		--To Filter the Records Which Has Tax Percentage (>=0)      
		IF EXISTS (SELECT * FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId = 0 and ColVal >= 0)      
		BEGIN      
		--To Get the Tax Percentage for the selected slab      
		SELECT @TaxPer = ColVal FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId = 0      
		--To Get the TaxId for the selected slab      
		SELECT @TaxId = Cast(ColVal as INT) FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId > 0      
		SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @MRP 
		--To Get the Parent Taxable Amount for the Tax Slab      
		SELECT @ParTaxableAmount =  ISNULL(SUM(TaxAmount),0) FROM TempProductTax A      
		INNER JOIN @TaxSettingDet B ON A.TaxId = B.ColVal and  
		B.ColType = 3 AND B.TaxSlab = @TaxSlab 
		If @ParTaxableAmount>0
		BEGIN
			Set @TaxableAmount=@ParTaxableAmount
		END 
		ELSE
		BEGIN
			Set @TaxableAmount = @TaxableAmount
		END    
		--PRINT @ParTaxableAmount
		--PRINT @TaxableAmount      
		INSERT INTO TempProductTax (PrdId,PrdBatId,TaxId,TaxSlabId,TaxPercentage,      
		TaxAmount)      
		SELECT @Prdid,@Prdbatid,@TaxId,@TaxSlab,@TaxPer,      
		cast(@TaxableAmount*(@TaxPer / 100 ) AS NUMERIC(28,10))      
		END      
		FETCH NEXT FROM CurTax INTO @TaxSlab      
		END        
		CLOSE CurTax        
		DEALLOCATE CurTax      
		SELECT @TaxPercentage=Cast(ISNULL(SUM(TaxAmount)*100,0) as Numeric(18,5))
		FROM TempProductTax WHERE Prdid=@Prdid and Prdbatid=@Prdbatid
		--PRINT @TaxPercentage
		IF EXISTS(SELECT * FROM ProductBatchTaxPercent WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
		BEGIN			
			UPDATE ProductBatchTaxPercent  SET TaxPercentage=@TaxPercentage
			WHERE Prdid=@Prdid and Prdbatid=@Prdbatid
		END	
		ELSE
		BEGIN			
			INSERT INTO ProductBatchTaxPercent(Prdid,Prdbatid,TaxPercentage)
			SELECT @Prdid,@Prdbatid,@TaxPercentage
		END
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND name = 'Proc_Cn2Cs_SpecialDiscount')
DROP PROCEDURE Proc_Cn2Cs_SpecialDiscount
GO
--EXEC Proc_Cn2Cs_SpecialDiscount 0
CREATE PROCEDURE Proc_Cn2Cs_SpecialDiscount
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_SpecialDiscount
* PURPOSE		: To insert SpecialRateDetails in Productbatchdetails table
* CREATED		:  Muthukrishnan.G.P
* CREATED DATE	:  31-12-2012
* MODIFIED      :   
* DATE AUTHOR   : DESCRIPTION
------------------------------------------------
* {date}		{developer}		{brief modification description}
* 2013-03-01	Vijendra Kumar	CR(PM)-CCRSTPVM0001
*********************************/
SET NOCOUNT ON
BEGIN
	
	DECLARE @RtrHierLevelCode 		AS  NVARCHAR(100)
	DECLARE @RtrHierLevelValueCode 	AS  NVARCHAR(100)
	DECLARE @RtrCode				AS 	NVARCHAR(100)
	
	DECLARE @PrdCCode				AS 	NVARCHAR(100)
	DECLARE @PrdBatCode				AS 	NVARCHAR(100)
	DECLARE @PrdBatCodeAll			AS 	NVARCHAR(100)
	DECLARE @PriceCode				AS 	NVARCHAR(4000)
	DECLARE @Disperc                AS 	NUMERIC(38,6)
	DECLARE @SplRate				AS 	NUMERIC(38,6)
	DECLARE @PrdCtgValMainId		AS	INT
	DECLARE @CtgLevelId				AS 	INT
	DECLARE @CtgMainId				AS 	INT
	DECLARE @RtrId 					AS 	INT
	DECLARE @PrdId 					AS 	INT
	DECLARE @PrdBatId				AS 	INT
	DECLARE @PriceId				AS 	INT
	DECLARE @ContractReq			AS 	INT
	DECLARE @SRReCalc				AS 	INT
	DECLARE @ReCalculatedSR			AS 	NUMERIC(38,6)
	DECLARE @EffFromDate			AS 	DATETIME
	DECLARE @EffToDate				AS 	DATETIME
	DECLARE @CreatedDate			AS 	DATETIME
	
	DECLARE @MulTaxGrp				AS 	INT
	DECLARE @TaxGroupId				AS	INT
	DECLARE @MulRtrId				AS	INT
	DECLARE @MulTaxGroupId			AS 	INT
	DECLARE @DownldSplRate			AS 	NUMERIC(38,6)
	DECLARE @ContHistExist			AS	INT
	DECLARE @ContractPriceIds		AS	NVARCHAR(1000)
	DECLARE @RefPriceId				AS	INT
	DECLARE @CmpId					AS	INT
	DECLARE @CmpPrdCtgId			AS	INT
	DECLARE @RefRtrId				AS	INT
	DECLARE @ErrStatus				AS	INT
	DECLARE @RtrTaxGrp AS INT
	SET @Po_ErrNo=0
	SET @ErrStatus=0
	SET @RtrTaxGrp=0
	
	EXEC Proc_CalculateSpecialDiscountAftRate
	
    SET @ContractReq=1
	SET @SRReCalc=2
	
    TRUNCATE TABLE ETL_Prk_BLContractPricing	

	CREATE TABLE #SpecialRateToAvoid
	(
		Slno				BIGINT,
		RtrHierLevel		NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		RtrHierValue		NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		RtrCode				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		PrdCCode			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		PrdBatCode			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		EffectiveFromDate	DATETIME
	)
	
		
		SELECT DISTINCT CtgCode INTO #RetailerCategory FROM RetailerCategory RC 
		INNER JOIN RetailerValueClass RVC ON  RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerValueClassMap RCM ON RCM.RtrValueClassId=RVC.RtrClassId
		
		---Retailer Class Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT T.SlNo,CtgLevelName,T.CtgCode,RtrCode,PrdCCode,PrdBatCode,T.EffectiveFromDate
		FROM TempSpecialRateDiscountProduct T
		WHERE NOT EXISTS(SELECT CtgCode FROM #RetailerCategory R WHERE R.CtgCode=T.CtgCode)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer','Retailer Not Attached to Category:'+RtrHierLevel+' Not Available' FROM #SpecialRateToAvoid
		
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno
		
		--Product Batch Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT 1,RetCategoryLevel,RetCatLevelValue,'ALL',PrdCategoryLevelValue,'ALL',EffFromDate 
		FROM Cn2Cs_Prk_SpecialDiscount A (NOLOCK) WHERE DownLoadFlag = 'D' AND PrdCategoryLevel = 'Product'
		AND NOT EXISTS (SELECT DISTINCT PrdCCode FROM Product B (NOLOCK) 
		INNER JOIN ProductBatch C (NOLOCK) ON B.PrdId = C.PrdId WHERE A.PrdCategoryLevelValue = B.PrdCCode)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product','Product & ProductBatch','Product or Product Batch Not Available-'+PrdCategoryLevelValue
		FROM Cn2Cs_Prk_SpecialDiscount A (NOLOCK) WHERE DownLoadFlag = 'D' AND PrdCategoryLevel = 'Product'
		AND NOT EXISTS (SELECT DISTINCT PrdCCode FROM Product B (NOLOCK) 
		INNER JOIN ProductBatch C (NOLOCK) ON B.PrdId = C.PrdId WHERE A.PrdCategoryLevelValue = B.PrdCCode)
		--Till Here		

		---Retailer Category Level Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT SlNo,CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate
		FROM TempSpecialRateDiscountProduct
		WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer Category Level','Retailer Category Level:'+CtgLevelName+' Not Available' FROM TempSpecialRateDiscountProduct
		WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel)
		
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno
		----

		---Retailer Category Code Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT SlNo,CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate
		FROM TempSpecialRateDiscountProduct
		WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer Category Level Value','Retailer Category Level Value:'+CtgCode+' Not Available' FROM TempSpecialRateDiscountProduct
		WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory)
		
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno
		---

		--Eeffective From Date Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT SlNo,CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate
		FROM TempSpecialRateDiscountProduct
		WHERE EffectiveFromDate>GETDATE()
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Effective From Date','Effective Date :'+CAST(EffectiveFromDate AS NVARCHAR(12))+' is greater ' 
		FROM TempSpecialRateDiscountProduct
		WHERE EffectiveFromDate>GETDATE()

		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno
		-- 
		IF NOT EXISTS(SELECT * FROM TempSpecialRateDiscountProduct)
		BEGIN
			RETURN
		END
		
		SELECT @CmpId=ISNULL(CmpId,0) FROM Company C WHERE DefaultCompany=1
		Select @RtrTaxGrp=MIN(Distinct RtriD) FROM TaxSettingMaster (NOLOCK)
		
		SELECT DISTINCT ISNULL(Prk.CtgLevelName,'') as RtrHierLevelCode,ISNULL(Prk.CtgCode,'') as RtrHierLevelValueCode,
		RtrCode,ISNULL(Prk.PrdCCode,'') as PrdCCode,ISNULL(Prk.PrdBatCode,'') as PrdBatCodeAll,
		ISNULL(DiscPer,0) as Disperc,ISNULL(SpecialSellingRate,0) as SplRate,
		ISNULL(Prk.EffectiveFromDate,GETDATE()) as EffFromDate,ISNULL(Prk.EffectiveToDate,'2013-12-31') as EffToDate,
		ISNULL(CreatedDate,GETDATE()) as CreatedDate,ISNULL(P.PrdId,0) AS PrdId,
		ISNULL(RCL.CtgLevelId,0) AS CtgLevelId,ISNULL(RC.CtgMainId,0) AS CtgMainId,
		Prdbatid,PCV.PrdCtgValMainId,CmpPrdCtgId
		INTO #SplPriceDetails
		FROM TempSpecialRateDiscountProduct Prk 
		INNER JOIN Product P ON Prk.PrdCCode=P.PrdCCode 
		INNER JOIN Productbatch PB ON PB.prdid=P.Prdid and PB.PrdBatCode=Prk.PrdBatCode
		INNER JOIN ProductCategoryValue PCV ON P.PrdCtgValMainId=PCV.PrdCtgValMainId
		INNER JOIN RetailerCategoryLevel RCL ON Prk.CtgLevelName=RCL.CtgLevelName 
		INNER JOIN RetailerCategory RC ON Prk.CtgCode=RC.CtgCode	
		WHERE  Prk.EffectiveFromDate<=GETDATE()	
	
		---Tax Calculation
		DECLARE @PrdIdTax as BIGINT
		DECLARE @PrdbatIdTax AS BIGINT
		DECLARE Cur_Tax CURSOR
		FOR 
		SELECT DISTINCT PrdId,PrdbatId FROM #SplPriceDetails		
		OPEN Cur_Tax	
		FETCH NEXT FROM Cur_Tax INTO @PrdIdTax,@PrdbatIdTax
		WHILE @@FETCH_STATUS=0
		BEGIN	
				EXEC Proc_SellingTaxCalCulation @PrdIdTax,@PrdbatIdTax
		FETCH NEXT FROM Cur_Tax INTO @PrdIdTax,@PrdbatIdTax		
		END		
		CLOSE Cur_Tax
		DEALLOCATE Cur_Tax	
	
		DECLARE @MaxPriceId as BIGINT
		SELECT @MaxPriceId=ISNULL(MAX(PriceId),0) from ProductBatchDetails
	
		SELECT A.*,CAST(SplRate*100/(100+TaxPercentage) AS NUMERIC(38,6)) AS NewSellRate
		,@MaxPriceId+ROW_NUMBER() OVER(Order by A.PrdId,A.PrdBatId,CtgLevelId,CtgMainId,PrdCtgValMainId,CmpPrdCtgId)
		as NewPriceId
		INTO #PriceMaster
		FROM #SplPriceDetails A INNER JOIN ProductBatchTaxPercent B ON A.PrdId=B.PrdId
		AND A.PrdBatId=b.PrdBatId
	
		SELECT PrdbatId,MAX(PriceId) as PriceId 
		INTO #ProductbatchDetails 
		FROM ProductBatchDetails GROUP BY PrdbatId
	
		INSERT INTO ProductBatchDetails(
		PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
		Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
		SELECT DISTINCT 
		NewPriceId,A.PrdBatId,PrdBatCode+'-Spl Rate-'+CAST(NewSellRate AS NVARCHAR(100))
						+CAST(GETDATE() AS NVARCHAR(20)) ,
		
		D.BatchSeqId,D.SlNo,
				(CASE BC.SelRte WHEN 1 THEN NewSellRate ELSE D.PrdBatDetailValue END) AS SelRte,
				0,1,1,1,GETDATE(),1,GETDATE(),0 
		FROM #PriceMaster A 
		INNER JOIN #ProductbatchDetails B ON A.PrdBatId=B.PrdBatId
		INNER JOIN ProductBatchDetails D ON D.PrdBatId=A.PrdBatId and D.PrdBatId=B.PrdBatId and D.PriceId=B.PriceId
		INNER JOIN BatchCreation BC ON BC.BatchSeqId=D.BatchSeqId AND D.SlNo=BC.SlNo
		INNER JOIN ProductBatch C ON C.PrdBatId=A.PrdBatId and C.PrdBatId=B.PrdBatId and C.PrdId=A.PRdId
		and D.PrdBatId=C.PrdBatId
		ORder by NewPriceId,A.PrdBatId,D.SlNo

		
		UPDATE Counters SET CurrValue=(SELECT ISNULL(Max(PriceId),0) FROM ProductBatchDetails) WHERE TabName='ProductBatchDetails' AND FldName='PriceId'
		UPDATE A SET EnableCloning=1 FROM ProductBatch A
		INNER JOIN #PriceMaster B ON B.Prdbatid=A.PrdbatId
		
		--Contract Price Praking Table insert
		INSERT INTO Cn2Cs_Prk_ContractPricing(CmpId,CtgLevelId,CtgMainId,RtrClassId,CmpPrdCtgId,PrdCtgValMainId,
		RtrId,PrdId,PrdBatId,PriceId,DiscountPerc,FlatAmount,EffectiveDate,ToDate,CreatedDate,RtrTaxGroupId)
		SELECT DISTINCT @CmpId,CtgLevelId,CtgMainId,0,0,0,CASE WHEN RtrCode='ALL' THEN '0' ELSE ISNULL(RtrCode,'') END,
		Prdid,Prdbatid,NewPriceId,0,0,EffFromDate,EffToDate,CreatedDate,@RtrTaxGrp
		FROM #PriceMaster
		
		---Special Rate Screen Table Insert and Update
		INSERT INTO SpecialRateAftDownLoad(RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode,
		SplSelRate,FromDate,CreatedDate,DownloadedDate,ContractPriceIds,DiscountPerc)		
		SELECT DISTINCT RtrHierLevelCode,RtrHierLevelValueCode,RtrCode,PrdCCode,PrdBatCodeAll,
		SplRate,EffFromDate,CreatedDate,GETDATE(),'-'+CAST(NewPriceId AS NVARCHAR(10))+'-',Disperc 
		FROM #PriceMaster A
		WHERE NOT EXISTS(		
			SELECT RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode, FromDate 
			FROM 
			SpecialRateAftDownLoad B WHERE B.RtrCtgCode=A.RtrHierLevelCode
			and B.RtrCtgValueCode=A.RtrHierLevelValueCode and B.RtrCode= A.RtrCode
			And B.PrdCCode=A.PrdCCode and B.PrdBatCCode=A.PrdBatCodeAll
			and FromDate<=EffFromDate and B.SplSelRate=A.SplRate
						)
		
		UPDATE B  SET SplSelRate=SplRate,ContractPriceIds='-'+CAST(NewPriceId AS NVARCHAR(10))+'-',DiscountPerc=Disperc
		FROM #PriceMaster A INNER JOIN SpecialRateAftDownLoad B ON 
		B.RtrCtgCode=A.RtrHierLevelCode
		and B.RtrCtgValueCode=A.RtrHierLevelValueCode and B.RtrCode= A.RtrCode
		And B.PrdCCode=A.PrdCCode and B.PrdBatCCode=A.PrdBatCodeAll
		WHERE  FromDate<=EffFromDate
		---
	
	
		EXEC Proc_Validate_ContractPricing @Po_ErrNo=@ErrStatus
		SET @Po_ErrNo=@ErrStatus
	
		--IF @Po_ErrNo=0
		--BEGIN	
			UPDATE A SET A.DownLoadFlag='Y' FROM Cn2Cs_Prk_SpecialDiscount A (NOLOCK) 
			INNER JOIN SpecialRateAftDownload B (NOLOCK) ON A.PrdCategoryLevelValue = B.PrdCCode 
			AND A.RetCategoryLevel = B.RtrCtgCode AND A.RetCatLevelValue = B.RtrCtgValueCode
		--END
		RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_Cn2Cs_ProductBatch' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_ProductBatch
GO
/* 
   BEGIN TRANSACTION
   EXEC Proc_Cn2Cs_ProductBatch 0
   SELECT * FROM Productbatch WITH(NOLOCK) WHERE PrdBatId = 29809
   SELECT * FROM Productbatchdetails WITH(NOLOCK) WHERE PrdBatId = 29809
   SELECT * FROM ProductBatch (NOLOCK) WHERE PrdId = 1741
   SELECT * FROM Errorlog WITH(NOLOCK)
   ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_ProductBatch
(
       @Po_ErrNo INT OUTPUT
)
AS
/***************************************************************************************************
* PROCEDURE		: Proc_Cn2Cs_ProductBatch
* PURPOSE		: To Insert and Update records in the Tables ProductBatch and ProductBatchDetails
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 12/04/2010
* MODIFIED      : Sathishkumar Veeramani
* PURPOSE		: New Product Batch - Special Rate Created
* MODIFIED DATE : 13/09/2012
* MODIFIED      : Murugan.R
* PURPOSE		: Batch Optimization  and Akzonabal Price change
* MODIFIED DATE : 13/09/2012
* DATE      AUTHOR     DESCRIPTION
-----------------------------------------------------------------------------------------------------
* {date} {developer}  {brief modification description}
*****************************************************************************************************/
SET NOCOUNT ON
BEGIN
	SET @Po_ErrNo =0
	IF NOT EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK) WHERE DownLoadFlag='D') RETURN
	
	--Product batch configuration  For Aznoble Client
	IF EXISTS(SELECT Status FROM Configuration where ModuleId='GENCONFIG33' and Status=1)
		BEGIN
			DELETE FROM ProductBatchEeffectiveDate WHERE UpdateFlag='Y'
			
			INSERT INTO ProductBatchEeffectiveDate(PrdCCode,PrdBatCode,ManufacturingDate,ExpiryDate,
			EffectiveDate,MRP,ListPrice,SellingRate,ClaimRate,AddRate1,AddRate2,
			AddRate3,AddRate4,AddRate5,AddRate6,UpdateFlag)			 
			SELECT PrdCCode,PrdBatCode,ManufacturingDate,ExpiryDate,EffectiveDate,
			MRP,ListPrice,SellingRate,ClaimRate,AddRate1,AddRate2,AddRate3,
			AddRate4,AddRate5,AddRate6,'N' 
			FROM Cn2Cs_Prk_ProductBatch WHERE DownLoadFlag='D' AND EffectiveDate>CONVERT(DATETIME ,CONVERT(VARCHAR(10),GETDATE(),121),121)
			ORDER BY ManufacturingDate ASC --Muthuvel
					
			DELETE FROM Cn2Cs_Prk_ProductBatch  WHERE DownLoadFlag='D' AND EffectiveDate>CONVERT(DATETIME ,CONVERT(VARCHAR(10),GETDATE(),121),121)
			--Product Batch and Price Insert For Aznoble Client
			EXEC Proc_ValidateBatchLDEeffectiveDate
			
			RETURN

		END
	
	IF EXISTS (SELECT * FROM SysObjects WHERE Name = 'PrdBatToAvoid' AND XTYPE = 'U')
	BEGIN
		DROP TABLE PrdBatToAvoid	
	END
	CREATE TABLE PrdBatToAvoid
	(
		PrdCCode NVARCHAR(200),
		PrdBatCode NVARCHAR(200)
	)
	DECLARE @ExistingBatchDetails	TABLE
	(
		PrdId		NUMERIC(18,0),
		PrdCCode	VARCHAR(100),
		PrdBatCode	VARCHAR(100),
		PriceCode	VARCHAR(500),
		OldLSP		NUMERIC(18,0),
		PrdBatId	NUMERIC(18,0),
		PriceId		NUMERIC(18,0)
	)
	DECLARE @ProductBatchWithCounter TABLE
	(
		Slno			NUMERIC(18,0) IDENTITY(1,1),
		TransNo			NUMERIC(18,0),
		PrdId			NUMERIC(18,0),
		PrdCCode		VARCHAR(100),
		PrdBatCode		VARCHAR(100),
		MnfDate			DATETIME,
		ExpDate			DATETIME		
	)	
	DECLARE @ProductBatchPriceWithCounter TABLE
	(
		Slno			NUMERIC(18,0) IDENTITY(1,1),
		TransNo			NUMERIC(18,0),
		PrdId			NUMERIC(18,0),
		PrdBatId		NUMERIC(18,0),
		PriceCode		NVARCHAR(1000),
		MRP				NUMERIC(18,6),
		ListPrice		NUMERIC(18,6),
		SellingRate		NUMERIC(18,6),
		ClaimRate		NUMERIC(18,6),
		AddRate1		NUMERIC(18,6)
	)
	DECLARE @ContractPrice TABLE
	(
	   PrdId NUMERIC(18,0),
	   PrdBatId NUMERIC(18,0)
	)
	
	DECLARE @ContractBatchPrice TABLE
    (
	   ContractId       NUMERIC(18,0),
	   CtgMainId        NUMERIC(18,0),
	   PrdId            NUMERIC(18,0),
	   PrdBatId         NUMERIC(18,0),
	   PriceId          NUMERIC(18,0),
	   PriceCode        NVARCHAR(500)
    )
    DECLARE @ProductBatchDetails TABLE
	(
	   PrdId                NUMERIC(18,0),
	   PrdBatId      NUMERIC(18,0),
	   PriceId              NUMERIC(18,0),
	   PriceCode            NVARCHAR(500),
	   NewBatchId           NUMERIC(18,0),
	   Slno                 INT,
	   PrdBatDetailValue    NUMERIC(36,4),
	   NewPriceId           NUMERIC(18,0)
	)
	--Added By Sathishkumar Veeramani 2015/01/08
	DECLARE @ExistingSellingPriceDetails TABLE
	(
	    PrdId        NUMERIC(18,0),
	    PrdBatId     NUMERIC(18,0),
	    PriceId      NUMERIC(18,0)
	)
	DECLARE @ExistingListPriceDetails TABLE
	(
	    PrdId        NUMERIC(18,0),
	    PrdBatId     NUMERIC(18,0),
	    PriceId      NUMERIC(18,0)
	)
	--Till Here  
	
	DECLARE @BatSeqId			AS	INT
	DECLARE @ValDiffRefNo		AS	VARCHAR(100)
	DECLARE @ExistPrdBatMaxId	AS 	INT
	DECLARE @NewPrdBatMaxId		AS 	INT	
	DECLARE @ContPriceId		AS 	NUMERIC(18,0)
	DECLARE @OldPriceIdExt 		AS 	NUMERIC(18,0)
	DECLARE @OldPriceId 		AS 	NUMERIC(18,0)
	DECLARE @NewPriceId			AS  INT
	DECLARE @ContPrdId          AS  INT
    DECLARE @ContPrdBatId       AS  INT
    DECLARE @ContPriceId1       AS  INT
    DECLARE @PriceId            AS  INT 
    DECLARE @PriceBatch         AS  INT
    DECLARE @BatchTransfer		AS	INT
	DECLARE @Po_BatchTransfer	AS	INT
	
	SELECT @OldPriceId=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails WITH (NOLOCK)		
	SELECT @BatSeqId=MAX(BatchSeqId) FROM BatchCreationMaster WITH (NOLOCK)
	SELECT @ExistPrdBatMaxId=ISNULL(MAX(PrdBatId),0) FROM ProductBatch WITH (NOLOCK)
	SET @Po_ErrNo =0
	IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)
	WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)) AND DownLoadFlag='D')
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)) AND DownLoadFlag='D'
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdCCode','Product :'+PrdCCode+' not available'
		FROM Cn2Cs_Prk_ProductBatch	WITH (NOLOCK) WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)) 
		AND DownLoadFlag='D'
		
		--->Added By Nanda on 05/05/2010
		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)
		SELECT DISTINCT DistCode,'Product Batch',PrdBatCode,'Product',PrdCCode,'','N' FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK) 
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)) AND DownLoadFlag='D'
		--->Till Here				
	END
	IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)
	WHERE LEN(ISNULL(PrdBatCode,''))=0  AND DownLoadFlag='D')
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)
		WHERE LEN(ISNULL(PrdBatCode,''))=0 AND DownLoadFlag='D'
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdBatCode','Batch Code should not be empty for Product:'+PrdCCode
		FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)
		WHERE LEN(ISNULL(PrdBatCode,''))=0 AND DownLoadFlag='D'
	END
		
	INSERT INTO @ExistingBatchDetails (PrdId,PrdCCode,PrdBatCode,PriceCode,OldLSP,PrdBatId,PriceId)
	SELECT DISTINCT B.PrdId,B.PrdCCode,A.PrdBatCode,A.PrdBatCode+'-'+CAST(MRP AS NVARCHAR(25))+'-'+CAST(ListPrice AS NVARCHAR(25))+'-'+
	CAST(SellingRate AS NVARCHAR(25))+'-'+CAST(ClaimRate AS NVARCHAR(25))+'-'+CAST(AddRate1 AS NVARCHAR(25)) AS PriceCode,
	ISNULL(D.PrdBatDetailValue,0) AS OldLSP,C.PrdBatId,D.PrdBatId FROM Cn2Cs_Prk_ProductBatch A (NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.PrdCCode=B.PrdCCode
	INNER JOIN ProductBatch C (NOLOCK)ON A.PrdBatCode=C.PrdBatCode AND B.PrdId=C.PrdId
	INNER JOIN ProductBatchDetails D (NOLOCK) ON  D.PrdBatId=C.PrdBatId AND D.DefaultPrice=1 AND D.SlNo=2
	WHERE A.PrdBatCode NOT IN (SELECT PrdBatCode FROM PrdBatToAvoid) AND DownLoadFlag='D'
	
	--Added By Sathishkumar Veeramani 2015/01/08
	--Selling Rate Validation
	INSERT INTO @ExistingSellingPriceDetails (PrdId,PrdBatId,PriceId)
	SELECT DISTINCT PrdId,B.PrdBatId,C.PriceId FROM Cn2Cs_Prk_ProductBatch A (NOLOCK) 
	INNER JOIN @ExistingBatchDetails B ON A.PrdCCode = B.PrdCCode AND A.PrdBatCode = B.PrdBatCode
	INNER JOIN ProductBatchDetails C (NOLOCK) ON B.PrdBatId = C.PrdBatId AND A.SellingRate = C.PrdBatDetailValue
	WHERE C.SLNo = 3
	
	--List Price Validation
	INSERT INTO @ExistingListPriceDetails (PrdId,PrdBatId,PriceId)
	SELECT DISTINCT PrdId,B.PrdBatId,C.PriceId FROM Cn2Cs_Prk_ProductBatch A (NOLOCK) 
	INNER JOIN @ExistingBatchDetails B ON A.PrdCCode = B.PrdCCode AND A.PrdBatCode = B.PrdBatCode
	INNER JOIN ProductBatchDetails C (NOLOCK) ON B.PrdBatId = C.PrdBatId AND A.ListPrice = C.PrdBatDetailValue
	WHERE C.SLNo = 2
	
	SELECT DISTINCT A.PrdId,A.PrdBatId,A.PriceId INTO #ExistinPriceCloning FROM @ExistingSellingPriceDetails A 
	INNER JOIN @ExistingListPriceDetails B ON A.PrdId = B.PrdId
	AND A.PrdBatId = B.PrdBatId AND A.PriceId = B.PriceId
	
	IF EXISTS (SELECT DISTINCT PrdId,PrdBatId,PriceId FROM #ExistinPriceCloning)
	BEGIN
	    UPDATE A SET A.DefaultPrice = 0 FROM ProductBatchDetails A (NOLOCK) 
	    INNER JOIN #ExistinPriceCloning B ON A.PrdBatId = B.PrdBatId
	    
	    UPDATE A SET A.DefaultPrice = 1 FROM ProductBatchDetails A (NOLOCK)
	    INNER JOIN #ExistinPriceCloning B ON A.PrdBatId = B.PrdBatId AND A.PriceId = B.PriceId
	    
	    UPDATE A SET A.DefaultPriceId = B.PriceId FROM ProductBatch A (NOLOCK) 
	    INNER JOIN #ExistinPriceCloning B ON A.PrdBatId = B.PrdBatId	    
	END
	--Till Here
	
	--Added By Sathishkumar Veeramani 2015/01/08
	--Batch Cloning Details
    DECLARE @BatchPriceId AS NUMERIC(18,0)
    SELECT @BatchPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
    
	SELECT DISTINCT CAST(DENSE_RANK() OVER (ORDER BY MAX(PrdBatId)) AS NUMERIC(18,0))+@BatchPriceId AS PriceId,
	MAX(PrdBatId) AS PrdBatId,A.PrdBatCode+'-'+CAST(MRP AS NVARCHAR(25))+'-'+CAST(ListPrice AS NVARCHAR(25))+'-'+CAST(SellingRate AS NVARCHAR(25))+'-'+
	CAST(ClaimRate AS NVARCHAR(25))+'-'+CAST(AddRate1 AS NVARCHAR(25)) AS PriceCode,MRP,ListPrice,
	SellingRate,ClaimRate,AddRate1 INTO #BatchCloningDetails FROM Cn2Cs_Prk_ProductBatch A (NOLOCK)
	INNER JOIN Product B (NOLOCK) ON A.PrdCCode = B.PrdCCode 
	INNER JOIN ProductBatch C (NOLOCK) ON B.PrdId = C.PrdId AND A.PrdBatCode = C.PrdBatCode WHERE DownloadFlag = 'D'
	AND NOT EXISTS (SELECT DISTINCT PrdId,PrdBatId FROM #ExistinPriceCloning D WHERE C.PrdId = D.PrdId AND C.PrdBatId = D.PrdBatId) 
	GROUP BY A.PrdBatCode,MRP,ListPrice,SellingRate,ClaimRate,AddRate1
	
	IF EXISTS (SELECT DISTINCT PrdBatId FROM #BatchCloningDetails)
	BEGIN
	    UPDATE A SET DefaultPrice = 0 FROM ProductBatchDetails A WITH(NOLOCK) 
		INNER JOIN #BatchCloningDetails B ON A.PrdBatId = B.PrdBatId
			    
		INSERT INTO ProductBatchDetails (PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
		Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
		SELECT DISTINCT PriceId,PrdBatId,PriceCode,1,SlNo,Rate,1,1,1,1,GETDATE(),1,GETDATE(),0 FROM(
		SELECT DISTINCT PriceId,PrdBatId,PriceCode,1 AS SlNo,MRP AS Rate FROM #BatchCloningDetails UNION
		SELECT DISTINCT PriceId,PrdBatId,PriceCode,2 AS SlNo,ListPrice AS Rate FROM #BatchCloningDetails UNION
		SELECT DISTINCT PriceId,PrdBatId,PriceCode,3 AS SlNo,SellingRate AS Rate FROM #BatchCloningDetails UNION
		SELECT DISTINCT PriceId,PrdBatId,PriceCode,4 AS SlNo,ClaimRate AS Rate FROM #BatchCloningDetails)Qry ORDER BY PrdBatId

		SELECT @BatchPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
		UPDATE Counters SET CurrValue = @BatchPriceId WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'
		
        UPDATE A SET DefaultPriceId = B.PriceId FROM ProductBatch A WITH(NOLOCK) 
		INNER JOIN #BatchCloningDetails B ON A.PrdBatId = B.PrdBatId
    END
	--Till Here
		
	IF EXISTS (SELECT * FROM @ExistingBatchDetails)
	BEGIN
		UPDATE A SET MnfDate=C.ManufacturingDate,ExpDate=ExpiryDate
		FROM ProductBatch A (NOLOCK) INNER JOIN @ExistingBatchDetails B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
		INNER JOIN Cn2Cs_Prk_ProductBatch C (NOLOCK) ON A.PrdBatCode=C.PrdBatCode  AND B.PrdCCode=C.PrdCCode
		WHERE C.DownLoadFlag='D'
	
		UPDATE Cn2Cs_Prk_ProductBatch SET DownLoadFlag='Y' 
		WHERE PrdCCode+'~'+PrdBatCode IN (SELECT PrdCCode+'~'+PrdBatCode FROM @ExistingBatchDetails) AND DownLoadFlag='D' 
	END
	
	DECLARE @Count1	NUMERIC(18,0)
	DECLARE @Count2	NUMERIC(18,0)
	SELECT @Count1=COUNT(*) FROM Cn2Cs_Prk_ProductBatch
	SELECT @Count2=COUNT(*) FROM @ExistingBatchDetails
	IF @Count1<>@Count2
		BEGIN
	--IF NOT EXISTS (SELECT * FROM @ExistingBatchDetails)
	--BEGIN
	---New ProductBatch		
		INSERT INTO @ProductBatchWithCounter
		SELECT DISTINCT (SELECT CurrValue FROM Counters (NOLOCK) WHERE TabName='ProductBatch' AND FldName='PrdBatId'),
		B.PrdId,A.PrdCCode,A.PrdBatCode,ManufacturingDate,ExpiryDate FROM Cn2Cs_Prk_ProductBatch A (NOLOCK) 
		INNER JOIN Product B (NOLOCK) ON A.PrdCCode=B.PrdCCode WHERE NOT EXISTS (SELECT PrdBatCode FROM ProductBatch C (NOLOCK) 
		WHERE C.PrdBatCode=A.PrdBatCode AND B.PrdId=C.PrdId)AND 
		A.PrdCCode+'~'+A.PrdBatCode NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM PrdBatToAvoid) AND A.DownLoadFlag='D'
		ORDER BY ManufacturingDate ASC --Muthuvel
		
			
		UPDATE @ProductBatchWithCounter SET TransNo=TransNo+Slno
	--Existing ProductBatch 
			INSERT INTO @ProductBatchWithCounter
			SELECT DISTINCT C.PrdBatId,B.PrdId,A.PrdCCode,A.PrdBatCode,
			ManufacturingDate,ExpiryDate FROM Cn2Cs_Prk_ProductBatch A (NOLOCK) INNER JOIN Product B (NOLOCK) ON A.PrdCCode=B.PrdCCode
			INNER JOIN ProductBatch C ON B.PrdId = C.PrdId AND C.PrdBatCode = A.PrdBatCode WHERE 
			NOT EXISTS (SELECT PrdBatId FROM ProductBatchDetails D(NOLOCK) WHERE D.PrdBatId = C.PrdBatId AND D.PriceId = C.DefaultPriceId)	
			AND  A.PrdCCode+'~'+A.PrdBatCode NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM PrdBatToAvoid) AND A.DownLoadFlag='D'
			AND  A.PrdCCode+'~'+A.PrdBatCode NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM @ProductBatchWithCounter)
	
	 --Product Batch   
		INSERT INTO ProductBatch(PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,
		TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT A.PrdId,TransNo,PrdBatCode,PrdBatCode,MnfDate,ExpDate,1,B.TaxGroupId,@BatSeqId,
		6,0,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchWithCounter A 
		INNER JOIN Product B ON A.PrdId=B.PrdId WHERE NOT EXISTS (SELECT PrdBatCode FROM ProductBatch C WHERE A.PrdId = C.PrdId 
		AND A.PrdBatCode = C.PrdBatCode)
    --END 
		END
	IF EXISTS (SELECT * FROM @ProductBatchWithCounter) 
	BEGIN
		UPDATE Counters SET CurrValue = (SELECT MAX(PrdBatId) FROM ProductBatch) WHERE TabName = 'ProductBatch' AND FldName = 'prdbatid'
	
		INSERT INTO @ProductBatchPriceWithCounter
		SELECT DISTINCT (SELECT CurrValue FROM Counters (NOLOCK) WHERE TabName='ProductBatchDetails' AND FldName='PriceId'),A.PrdId,A.TransNo,
		A.PrdBatCode+'-'+CAST(MRP AS NVARCHAR(25))+'-'+CAST(ListPrice AS NVARCHAR(25))+'-'+
		CAST(SellingRate AS NVARCHAR(25))+'-'+CAST(ClaimRate AS NVARCHAR(25))+'-'+CAST(AddRate1 AS NVARCHAR(25)),MRP,ListPrice,
		SellingRate,ClaimRate,AddRate1 FROM @ProductBatchWithCounter A INNER JOIN Cn2Cs_Prk_ProductBatch B WITH (NOLOCK)
		ON A.PrdCCode=B.PrdCCode AND A.PrdBatCode=B.PrdBatCode WHERE B.DownLoadFlag='D'
		
		UPDATE @ProductBatchPriceWithCounter SET TransNo=TransNo+Slno
				
		UPDATE A SET A.DefaultPrice=0 FROM ProductBatchDetails A WITH (NOLOCK),@ProductBatchPriceWithCounter B  
	    WHERE A.PrdBatId = B.PrdBatId
		
	END			
	
	IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatSeqId)=4
	BEGIN
		INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
		DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,1,MRP,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,2,ListPrice,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,3,SellingRate,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,4,ClaimRate,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
	END
	ELSE IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatSeqId)=5
	BEGIN
		INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
		DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,1,MRP,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,2,ListPrice,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,3,SellingRate,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,4,ClaimRate,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,5,AddRate1,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
	END	
	UPDATE A SET DefaultPriceId=C.TransNo FROM ProductBatch A INNER JOIN @ProductBatchPriceWithCounter C ON C.PrdBatId=A.PrdBatId AND A.PrdId=C.PrdId	
	
	IF EXISTS(SELECT * FROM @ProductBatchPriceWithCounter) 
	BEGIN
		UPDATE Counters SET CurrValue = (SELECT MAX(PriceId) FROM ProductBatchDetails) 	WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'	
	END
	
	--Batch Cloning Price Details
	
	IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreeRateForOldBatch' AND ModuleName='Botree Product Batch Download' AND Status=1)
	BEGIN
		IF EXISTS(SELECT * FROM @ProductBatchPriceWithCounter A INNER JOIN @ExistingBatchDetails B ON A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId
		WHERE (B.OldLSP-A.ListPrice)<>0 AND Slno=2)
		BEGIN
			SELECT @ValDiffRefNo = dbo.Fn_GetPrimaryKeyString('ValueDifferenceClaim','ValDiffRefNo',CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			
			INSERT INTO ValueDifferenceClaim(ValDiffRefNo,Date,PrdId,PrdBatId,OldPriceId,NewPriceId,OldPrice,NewPrice,Qty,
			ValueDiff,ClaimAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			
			SELECT @ValDiffRefNo,GETDATE(),A.PrdId,A.PrdBatID,B.PriceId,C.TransNo,B.OldLsp,C.ListPrice,
			ISNULL(SUM(A.PrdBatLcnSih+A.PrdBatLcnUih-A.PrdBatLcnRessih-A.PrdBatLcnResUih),0),B.OldLsp-C.ListPrice,
			ISNULL(SUM(A.PrdBatLcnSih+A.PrdBatLcnUih-A.PrdBatLcnRessih-A.PrdBatLcnResUih),0)*(B.OldLsp-C.ListPrice),
			1,1,GETDATE(),1,GETDATE() FROM ProductBatchLocation A INNER JOIN @ExistingBatchDetails B ON A.PrdId=B.PrdId AND A.PrdBatID=B.PrdBatId 
			INNER JOIN @ProductBatchPriceWithCounter C ON A.PrdBatId=C.PrdBatId AND A.PrdId=C.PrdId
			WHERE C.Slno=2	GROUP BY A.PrdId,A.PrdBatID,B.PriceId,C.TransNo,B.OldLsp,C.ListPrice
			
			UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'ValueDifferenceClaim' AND FldName = 'ValDiffRefNo'
		END
	END
	UPDATE ProductBatch SET ProductBatch.DefaultPriceId=PBD.PriceId,ProductBatch.BatchSeqId=PBD.BatchSeqId
	FROM ProductBatchDetails PBD WITH (NOLOCK) WHERE ProductBatch.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1
	
	UPDATE ProductBatch SET EnableCloning=1 WHERE PrdBatId IN
	(
	 SELECT PrdBatId FROM ProductBatchDetails WITH (NOLOCK) GROUP BY PrdBatId  HAVING(COUNT(DISTINCT PriceId)>1)
	)
	
	SELECT PrdBatId INTO #ZeroBatches FROM ProductBatchDetails WITH (NOLOCK)
	GROUP BY PrdBatId HAVING SUM(DefaultPrice)=0
	
	SELECT B.PrdId,B.PrdBatId,MAX(PriceId) As PriceId INTO #ZeroMaxPrices
	FROM ProductBatchDetails A INNER JOIN ProductBatch B ON A.PrdBatId=B.PrdBatId
	INNER JOIN #ZeroBatches C ON A.PrdBatId=C.PrdBatId
	WHERE A.DefaultPrice=0 AND NOT EXISTS
	(SELECT DISTINCT PriceId FROM #BatchCloningDetails D WHERE A.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId)
	AND NOT EXISTS (SELECT DISTINCT PriceId FROM #ExistinPriceCloning E WHERE A.PrdBatId = E.PrdBatId AND A.PriceId = E.PriceId)
	GROUP BY B.PrdId,B.PrdBatId 
	
	
	UPDATE ProductBatch Set DefaultPriceId=B.PriceId FROM ProductBatch A,#ZeroMaxPrices B
	WHERE A.PrdBatId=B.PrdbatId and A.PrdId=B.PrdId 
	
	UPDATE ProductBatchDetails Set DefaultPrice=1 FROM #ZeroMaxPrices A
	WHERE ProductBatchDetails.PrdbatId=A.PrdBatId AND ProductBatchDetails.PriceId=A.PriceId
	
	SET @Po_ErrNo=0
	SELECT @OldPriceIdExt=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails
	IF @ExistPrdBatMaxId>0
	BEGIN
		SELECT @NewPrdBatMaxId=ISNULL(MAX(PrdBatId),0) FROM ProductBatch
		IF @NewPrdBatMaxId>@ExistPrdBatMaxId
		BEGIN
		    
		    --Existing Contract Pricing Percentage Updated to New Batch Download
     	    SELECT DISTINCT RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,MAX(CreatedDate) AS CreatedDate INTO #SpecialRateCreatedDate
		    FROM SpecialRateAftDownload WITH(NOLOCK) GROUP BY RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode ORDER BY PrdCCode
		       
			SELECT DISTINCT C.PrdId,E.PrdBatId,TransNo AS PriceId,A.RtrCtgCode,A.RtrCtgValueCode,A.RtrCode,A.PrdCCode,
			D.PrdBatCode,DiscountPerc,(MRP-(MRP*(DiscountPerc/100))) AS SplRate INTO #SpecialRateDetails 
			FROM SpecialRateAftDownload A WITH(NOLOCK)
			INNER JOIN #SpecialRateCreatedDate B ON A.RtrCtgCode = B.RtrCtgCode AND A.RtrCtgValueCode = B.RtrCtgValueCode 
			AND A.RtrCode = B.RtrCode AND A.PrdCCode = B.PrdCCode AND A.CreatedDate = B.CreatedDate
			INNER JOIN Product C WITH(NOLOCK) ON A.PrdCCode = C.PrdCCode			
			INNER JOIN ProductBatch D WITH(NOLOCK) ON C.PrdId = D.PrdId
			INNER JOIN @ProductBatchPriceWithCounter E ON C.PrdId = E.PrdId AND D.PrdBatId = E.PrdBatId
			ORDER BY A.PrdCCode			
	
			SELECT DISTINCT MAX(E.ContractId) AS ContractId,A.PrdId,A.PrdBatId,A.PriceId,B.CtgLevelId,C.CtgMainId,SplRate,RtrCtgValueCode 
			INTO #SpecialContractDetails FROM #SpecialRateDetails A WITH(NOLOCK) 
			INNER JOIN RetailerCategoryLevel B WITH(NOLOCK) ON A.RtrCtgCode = B.CtgLevelName 
			INNER JOIN RetailerCategory C WITH(NOLOCK) ON A.RtrCtgValueCode = C.CtgCode AND B.CtgLevelId = C.CtgLevelId
			INNER JOIN ContractPricingMaster D WITH(NOLOCK) ON B.CtgLevelId = D.CtgLevelId AND C.CtgMainId = D.CtgMainId 
			INNER JOIN ContractPricingDetails E WITH(NOLOCK) ON D.ContractId = E.ContractId AND A.PrdId = E.PrdId 
			GROUP BY A.PrdId,A.PrdBatId,A.PriceId,B.CtgLevelId,C.CtgMainId,SplRate,RtrCtgValueCode
			
			---Tax Calculation
			DECLARE @PrdIdTax as BIGINT
			DECLARE @PrdbatIdTax AS BIGINT
			DECLARE Cur_Tax CURSOR
			FOR 
			SELECT DISTINCT PrdId,PrdbatId FROM #SpecialContractDetails		
			OPEN Cur_Tax	
			FETCH NEXT FROM Cur_Tax INTO @PrdIdTax,@PrdbatIdTax
			WHILE @@FETCH_STATUS=0
			BEGIN	
					EXEC Proc_SellingTaxCalCulation @PrdIdTax,@PrdbatIdTax
			FETCH NEXT FROM Cur_Tax INTO @PrdIdTax,@PrdbatIdTax		
			END		
			CLOSE Cur_Tax
			DEALLOCATE Cur_Tax	
			
			SELECT DISTINCT A.PrdId,A.PrdBatId,PriceId,RtrCtgValueCode,DENSE_RANK ()OVER (ORDER BY A.PriceId,A.PrdbatId,RtrCtgValueCode)+ @OldPriceIdExt AS NewPriceId,
			CAST(SplRate*100/(100+TaxPercentage) AS NUMERIC(38,6)) AS NewSelRate INTO #SplProductBatchDetails
			FROM #SpecialContractDetails A WITH(NOLOCK) INNER JOIN ProductBatchTaxPercent B WITH(NOLOCK) ON A.PrdId = B.PrdId
			AND A.PrdBatId = B.PrdBatId ORDER BY A.PrdId,A.PrdBatId,PriceId,RtrCtgValueCode
			
			
			--Product Batch Details Value Added			
			INSERT INTO ProductBatchDetails (PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
            Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)            
            SELECT DISTINCT NewPriceId,A.PrdBatId,PriceCode+'SplRate'+CONVERT(NVARCHAR(200),NewSelRate)+CONVERT(NVARCHAR(10),GETDATE(),121),
            A.BatchSeqId,A.SLNo,(CASE SelRte WHEN 1 THEN NewSelRate ELSE PrdBatDetailValue END),0,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,
            CONVERT(NVARCHAR(10),GETDATE(),121),0
            FROM ProductBatchDetails A WITH(NOLOCK) 
            INNER JOIN #SplProductBatchDetails B ON A.PrdBatId = B.PrdBatId AND A.PriceId = B.PriceId
            INNER JOIN ProductBatch C WITH(NOLOCK) ON A.PrdBatId = C.PrdBatId
            INNER JOIN BatchCreation D WITH(NOLOCK) ON C.BatchSeqId = D.BatchSeqId AND A.SLNo = D.SlNo ORDER BY A.PrdBatId,NewPriceId 
            UPDATE Counters SET CurrValue =(SELECT MAX(PriceId) FROM ProductBatchDetails) WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'
            	
            --Contract Pricing Details Added
            INSERT INTO ContractPricingDetails (ContractId,PrdId,PrdBatId,PriceId,Discount,FlatAmtDisc,Availability,LastModBy,LastModDate,AuthId,
            AuthDate,CtgValMainId,ClaimablePercOnMRP)            
            SELECT DISTINCT ContractId,A.PrdId,A.PrdBatId,B.NewPriceId,0,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0,0
            FROM #SpecialContractDetails A INNER JOIN #SplProductBatchDetails B ON A.PrdId = B.PrdID AND A.PrdBatId = B.PrdBatId AND A.RtrCtgValueCode=B.RtrCtgValueCode
            WHERE NOT EXISTS (SELECT ContractId FROM ContractPricingDetails C WITH(NOLOCK) WHERE A.ContractId = C.ContractId 
            AND A.PrdId = C.PrdID AND A.PrdBatId = C.PrdBatId) ORDER BY ContractId,A.PrdId,A.PrdBatId,B.NewPriceId
            
            --Special Rate Updated
            INSERT INTO SpecialRateAftDownload (RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode,SplSelRate,FromDate,CreatedDate,DownloadedDate,
            ContractPriceIds,DiscountPerc,SplrateId)
            SELECT DISTINCT RtrCtgCode,A.RtrCtgValueCode,A.RtrCode,A.PrdCCode,A.PrdBatCode,A.SplRate,CONVERT(NVARCHAR(10),GETDATE(),121),GETDATE(),GETDATE(),
            '-'+CONVERT(NVARCHAR(50),NewPriceId)+'-',DiscountPerc,0
            FROM #SpecialRateDetails A INNER JOIN #SplProductBatchDetails B ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId 
            and A.RtrCtgValueCode=B.RtrCtgValueCode
            ORDER BY PrdCCode,PrdBatCode
            			
			--SELECT PrdId,PrdBatId,TransNo, FROM @ProductBatchPriceWithCounter INNER JOIN 
			
    		--SELECT A.PrdId,MAX(A.PrdBatId) AS PrdBatId INTO #ContractPrice FROM ProductBatch A (NOLOCK),@ProductBatchWithCounter B
			--WHERE  A.PrdId = B.PrdId AND A.PrdBatId < @ExistPrdBatMaxId AND EXISTS
			--(SELECT CPD.PrdBatId FROM ContractPricingDetails CPD (NOLOCK)
			--INNER JOIN ProductBatch PB1 (NOLOCK) ON CPD.PrdId=PB1.PrdId AND CPD.PrdBatId=PB1.PrdBatId AND A.PrdBatId=CPD.PrdBatId
			--AND CPD.PrdID IN (SELECT DISTINCT PrdId FROM @ProductBatchWithCounter))GROUP BY A.PrdId 
			
		--	INSERT INTO @ContractPrice (PrdId,PrdBatId)
		--	SELECT A.PrdId,MAX(A.PrdBatId) AS PrdBatId FROM ProductBatch A (NOLOCK),
		--	ContractPricingDetails B (NOLOCK),@ProductBatchWithCounter C
  --          WHERE A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId AND A.PrdId = C.Prdid AND B.PrdId = C.Prdid 
  --          GROUP BY A.PrdId ORDER BY A.PrdId
			        
		--	IF EXISTS(SELECT * FROM @ContractPrice)
		--	BEGIN
						
		--		SELECT DISTINCT PrdbatId,PriceId,Max(PriceCode) as PriceCode INTO #ProductBatchDetails 
		--		FROM ProductBatchDetails
		--		GROUP BY PrdbatId,PriceId
		--		INSERT INTO @ContractBatchPrice (ContractId,CtgMainId,PrdId,PrdBatId,PriceId,PriceCode) 
		--		SELECT Max(C.ContractId) as ContractId,D.CtgMainId,E.PrdId,E.PrdBatId,C.PriceId AS PriceId,
		--		--CAST('' AS NVARCHAR(4000)) AS PriceCode
		--		PriceCode
		--		FROM  ContractPricingMaster D (NOLOCK) 
		--		INNER JOIN  ContractPricingDetails C (NOLOCK)   ON C.ContractId = D.ContractId
		--		INNER JOIN  #ProductBatchDetails A (NOLOCK) ON A.PrdBatId = C.PrdBatId AND A.PriceId = C.PriceId
		--		INNER JOIN @ContractPrice E  ON E.PrdBatId = C.PrdBatId AND E.PrdId = C.PrdId 
		--		GROUP BY D.CtgMainId,E.PrdId,E.PrdBatId,C.PriceId ,PriceCode
			
		--	    --INSERT INTO @ContractBatchPrice (ContractId,CtgMainId,PrdId,PrdBatId,PriceId,PriceCode)
		--	    --SELECT DISTINCT MAX(D.ContractId) AS ContractId,D.CtgMainId,E.PrdId,E.PrdBatId,C.PriceId AS PriceId,
		--	    --CAST('' AS NVARCHAR(4000)) AS PriceCode FROM ProductBatchDetails A (NOLOCK),
		--	    --ContractPricingDetails C (NOLOCK),ContractPricingMaster D (NOLOCK),@ContractPrice E 
		--	    --WHERE A.PrdBatId = C.PrdBatId AND A.PriceId = C.PriceId AND C.ContractId = D.ContractId AND E.PrdId = C.PrdId 
		--	    --AND E.PrdBatId = C.PrdBatId GROUP BY D.CtgMainId,E.PrdId,E.PrdBatId,C.PriceId    
			
		--	    --UPDATE A SET A.PriceCode = D.PriceCode FROM @ContractBatchPrice A,ContractPricingDetails B WITH(NOLOCK),
		--	    --ContractPricingMaster C WITH(NOLOCK),ProductBatchDetails D WITH(NOLOCK) WHERE A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId 
		--	    --AND A.CtgMainId = C.CtgMainId AND D.PrdBatId = A.PrdBatId AND A.ContractId = C.ContractId AND B.ContractId = C.ContractId 
		--	    --UPDATE A SET A.PriceCode = D.PriceCode
		--	    --FROM @ContractBatchPrice A 
		--	    --INNER JOIN ContractPricingDetails B WITH(NOLOCK) ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId 
		--	    --INNER JOIN ContractPricingMaster C WITH(NOLOCK) ON   A.CtgMainId = C.CtgMainId  AND A.ContractId = C.ContractId AND B.ContractId = C.ContractId and A.ContractId=B.ContractId
		--	    --INNER JOIN #ProductBatchDetails D WITH(NOLOCK) ON D.PrdBatId = A.PrdBatId 
			    
		--	    --select 'Botree',* from @ProductBatchPriceWithCounter
		--	    --select 'Software',* from @ContractBatchPrice
		--		SELECT DISTINCT SlNo INTO #BatchCreation FROM BatchCreation A (NOLOCK)
		--		INNER JOIN (SELECT MAX(BatchseqId)  as BatchseqId FROM BatchCreationMaster (NOLOCK))X
		--		ON A.BatchSeqId=X.BatchSeqId
			
		--	    INSERT INTO @ProductBatchDetails (PrdId,PrdBatId,PriceId,PriceCode,NewBatchId,Slno,PrdBatDetailValue,NewPriceId) 
		--		SELECT DISTINCT A.PrdId,A.PrdBatId,A.PriceId,A.PriceCode,B.PrdBatId AS NewBatchId,PBD.Slno,PrdBatDetailValue,
		--		DENSE_RANK ()OVER (ORDER BY A.PriceId,A.PrdbatId,B.PrdBatId)+ @OldPriceId AS NewPriceId 
		--		FROM @ContractBatchPrice A INNER JOIN @ProductBatchPriceWithCounter B 
		--		ON A.PrdId = B.PrdId
		--		INNER JOIN ProductBatchDetails PBD WITH(NOLOCK) ON PBD.PrdBatId=A.PrdBatId and PBD.PriceId=A.PriceId 
		--		INNER JOIN #BatchCreation C WITH(NOLOCK) ON C.SlNo=PBD.Slno
		--		ORDER BY A.PrdId,A.PrdBatId,A.PriceId,B.PrdBatId
															            
		--		IF(SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatSeqId)=4
		--		BEGIN
		--			INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,
		--		    PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		--			SELECT DISTINCT NewPriceId,NewBatchId,PriceCode,@BatSeqId,SlNo,PrdBatDetailValue,0,1,
		--			1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) 
		--			FROM @ProductBatchDetails
					
		--			UPDATE A SET A.PrdBatDetailValue = B.MRP FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 1
					
		--			UPDATE A SET A.PrdBatDetailValue = B.ListPrice FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 2
					
		--			UPDATE A SET A.PrdBatDetailValue = B.ClaimRate FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 4 
		--		END
		--		ELSE IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatSeqId)=5
		--		BEGIN
		--			INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,
		--			PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		--			SELECT DISTINCT NewPriceId,NewBatchId,PriceCode,@BatSeqId,SlNo,PrdBatDetailValue,0,1,
		--			1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) 
  --                  FROM @ProductBatchDetails
  --                  UPDATE A SET A.PrdBatDetailValue = B.MRP FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 1
					
		--			UPDATE A SET A.PrdBatDetailValue = B.ListPrice FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 2
					
		--			UPDATE A SET A.PrdBatDetailValue = B.ClaimRate FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 4
					
		--			UPDATE A SET A.PrdBatDetailValue = B.AddRate1 FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 5
					
		--		END	
				
		--		    IF EXISTS (SELECT * FROM @ProductBatchDetails)
		--		    BEGIN
		--				INSERT INTO ContractPricingDetails(ContractId,PrdId,PrdBatId,PriceId,Discount,FlatAmtDisc,
		--				Availability,LastModBy,LastModDate,AuthId,AuthDate,CtgValMainId)
		--				SELECT DISTINCT ContractId,A.PrdId,NewBatchId,NewPriceId,Discount,FlatAmtDisc,
		--				Availability,LastModBy,GETDATE(),AuthId,GETDATE(),CtgValMainId
		--				FROM ContractPricingDetails	A,@ProductBatchDetails B WHERE A.PrdId = B.PrdId 
		--				AND A.PrdBatId = B.PrdBatId	AND A.PriceId = B.PriceId
		--			END	
						--UPDATE Counters SET CurrValue = (SELECT MAX(PriceId) FROM ProductBatchDetails) 
						--WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'				 
		--	END
		END
	END
	
	SELECT @NewPriceId=CurrValue FROM Counters (NOLOCK)	WHERE TabName='ProductBatchDetails' AND FldName='PriceId' 		
	IF @NewPriceId>@OldPriceId
	BEGIN
		IF EXISTS(SELECT * FROM Configuration(NOLOCK) WHERE ModuleId='BotreeRateForOldBatch'
		AND ModuleName='Botree Product Batch Download' AND Status=1)
		BEGIN
			EXEC Proc_DefaultPriceUpdation @ExistPrdBatMaxId,@OldPriceId,1
		END
	END
	IF EXISTS(SELECT * FROM ProductBatchDetails WHERE PriceId>=@OldPriceId)
	BEGIN
		EXEC Proc_DefaultPriceHistory 0,0,@NewPriceId,2,1
	END
	---MOORTHI  START
	IF @ExistPrdBatMaxId>0
	BEGIN		
		SET @BatchTransfer=0
		SELECT @BatchTransfer=Status FROM Configuration WHERE ModuleId='BotreeAutoBatchTransfer'
		IF @BatchTransfer=1
		BEGIN
			EXEC Proc_AutoBatchTransfer @ExistPrdBatMaxId,@Po_ErrNo = @Po_BatchTransfer OUTPUT
			IF @Po_BatchTransfer=1
			BEGIN
				INSERT INTO Errorlog VALUES (1,'Cn2Cs_Prk_BLProductBatch','Product Batch-Auto Batch Transfer',
				'Auto Batch Transfer is not done properly')           	
				SET @Po_ErrNo=1				
			END
		END
	END	
	--END
	
	UPDATE Cn2Cs_Prk_ProductBatch SET DownLoadFlag='Y' 
	WHERE PrdCCode+'~'+PrdBatCode IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode
	FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
	
	RETURN		
END
GO
IF EXISTS (SELECT * FROm Sysobjects WHERE Name = 'Proc_Console2CS_ConsolidatedDownload' AND XType = 'P')
DROP PROCEDURE Proc_Console2CS_ConsolidatedDownload
GO
CREATE PROCEDURE Proc_Console2CS_ConsolidatedDownload 
As  
Begin  
BEGIN TRY    
SET XACT_ABORT ON    
BEGIN TRANSACTION
Declare @Lvar Int  
Declare @MaxId Int  
Declare @SqlStr Varchar(8000)  
Declare @Process Varchar(100)  
Declare @colcount Int  
Declare @Col Varchar(5000)  
Declare @Tablename Varchar(100)  
Declare @Sequenceno Int  
 Create Table #Col (ColId int)  
 CREATE TABLE #Console2CS_Consolidated  
 (  
  [SlNo] [numeric](38, 0) NULL, [DistCode] [VARCHAR](200) COLLATE Database_Default NULL, [SyncId] [numeric](38, 0) NULL,  
  [ProcessName] [VARCHAR](200) COLLATE Database_Default NULL, [ProcessDate] [datetime] NULL, 
[Column1] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column2] [VARCHAR](200) COLLATE Database_Default NULL, [Column3] [VARCHAR](200) COLLATE Database_Default NULL, [Column4] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column5] [VARCHAR](200) COLLATE Database_Default NULL, [Column6] [VARCHAR](200) COLLATE Database_Default NULL, [Column7] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column8] [VARCHAR](200) COLLATE Database_Default NULL, [Column9] [VARCHAR](200) COLLATE Database_Default NULL, [Column10] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column11] [VARCHAR](200) COLLATE Database_Default NULL, [Column12] [VARCHAR](200) COLLATE Database_Default NULL, [Column13] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column14] [VARCHAR](200) COLLATE Database_Default NULL, [Column15] [VARCHAR](200) COLLATE Database_Default NULL, [Column16] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column17] [VARCHAR](200) COLLATE Database_Default NULL, [Column18] [VARCHAR](200) COLLATE Database_Default NULL, [Column19] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column20] [VARCHAR](200) COLLATE Database_Default NULL, [Column21] [VARCHAR](200) COLLATE Database_Default NULL, [Column22] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column23] [VARCHAR](200) COLLATE Database_Default NULL, [Column24] [VARCHAR](200) COLLATE Database_Default NULL, [Column25] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column26] [VARCHAR](200) COLLATE Database_Default NULL, [Column27] [VARCHAR](200) COLLATE Database_Default NULL, [Column28] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column29] [VARCHAR](200) COLLATE Database_Default NULL, [Column30] [VARCHAR](200) COLLATE Database_Default NULL, [Column31] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column32] [VARCHAR](200) COLLATE Database_Default NULL, [Column33] [VARCHAR](200) COLLATE Database_Default NULL, [Column34] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column35] [VARCHAR](200) COLLATE Database_Default NULL, [Column36] [VARCHAR](200) COLLATE Database_Default NULL, [Column37] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column38] [VARCHAR](200) COLLATE Database_Default NULL, [Column39] [VARCHAR](200) COLLATE Database_Default NULL, [Column40] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column41] [VARCHAR](200) COLLATE Database_Default NULL, [Column42] [VARCHAR](200) COLLATE Database_Default NULL, [Column43] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column44] [VARCHAR](200) COLLATE Database_Default NULL, [Column45] [VARCHAR](200) COLLATE Database_Default NULL, [Column46] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column47] [VARCHAR](200) COLLATE Database_Default NULL, [Column48] [VARCHAR](200) COLLATE Database_Default NULL, [Column49] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column50] [VARCHAR](200) COLLATE Database_Default NULL, [Column51] [VARCHAR](200) COLLATE Database_Default NULL, [Column52] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column53] [VARCHAR](200) COLLATE Database_Default NULL, [Column54] [VARCHAR](200) COLLATE Database_Default NULL, [Column55] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column56] [VARCHAR](200) COLLATE Database_Default NULL, [Column57] [VARCHAR](200) COLLATE Database_Default NULL, [Column58] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column59] [VARCHAR](200) COLLATE Database_Default NULL, [Column60] [VARCHAR](200) COLLATE Database_Default NULL, [Column61] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column62] [VARCHAR](200) COLLATE Database_Default NULL, [Column63] [VARCHAR](200) COLLATE Database_Default NULL, [Column64] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column65] [VARCHAR](200) COLLATE Database_Default NULL, [Column66] [VARCHAR](200) COLLATE Database_Default NULL, [Column67] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column68] [VARCHAR](200) COLLATE Database_Default NULL, [Column69] [VARCHAR](200) COLLATE Database_Default NULL, [Column70] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column71] [VARCHAR](200) COLLATE Database_Default NULL, [Column72] [VARCHAR](200) COLLATE Database_Default NULL, [Column73] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column74] [VARCHAR](200) COLLATE Database_Default NULL, [Column75] [VARCHAR](200) COLLATE Database_Default NULL, [Column76] [VARCHAR](200) COLLATE Database_Default NULL,   
  [Column77] [VARCHAR](200) COLLATE Database_Default NULL, [Column78] [VARCHAR](200) COLLATE Database_Default NULL, [Column79] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column80] [VARCHAR](200) COLLATE Database_Default NULL, [Column81] [VARCHAR](200) COLLATE Database_Default NULL, [Column82] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column83] [VARCHAR](200) COLLATE Database_Default NULL, [Column84] [VARCHAR](200) COLLATE Database_Default NULL, [Column85] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column86] [VARCHAR](200) COLLATE Database_Default NULL, [Column87] [VARCHAR](200) COLLATE Database_Default NULL, [Column88] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column89] [VARCHAR](200) COLLATE Database_Default NULL, [Column90] [VARCHAR](200) COLLATE Database_Default NULL, [Column91] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column92] [VARCHAR](200) COLLATE Database_Default NULL, [Column93] [VARCHAR](200) COLLATE Database_Default NULL, [Column94] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column95] [VARCHAR](200) COLLATE Database_Default NULL, [Column96] [VARCHAR](200) COLLATE Database_Default NULL, [Column97] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Column98] [VARCHAR](200) COLLATE Database_Default NULL, [Column99] [VARCHAR](200) COLLATE Database_Default NULL, [Column100] [VARCHAR](200) COLLATE Database_Default NULL,  
  [Remarks1] [VARCHAR](200) COLLATE Database_Default NULL, [Remarks2] [VARCHAR](200) COLLATE Database_Default NULL, [DownloadFlag] [VARCHAR](1) COLLATE Database_Default NULL,  
  DWNStatus INT
 )   
 Delete A From Console2CS_Consolidated A (Nolock) Where DownloadFlag='Y'  
 Insert Into #Console2CS_Consolidated  
 Select *,0 as DWNStatus from Console2CS_Consolidated (Nolock) Where DownloadFlag In ('D','N')
   Update A Set A.DWNStatus = 1  
   From  
    #Console2CS_Consolidated A (NOLOCK),  
    (  
     SELECT   
     DistCode,SyncId   
     FROM   
     SyncStatus_Download (NOLOCK)  
     WHERE       
     SyncStatus = 1 AND SyncId > 0  
     UNION  
     SELECT   
     DistCode,SyncId  
     FROM   
     SyncStatus_Download_Archieve (NOLOCK)  
     WHERE  
     SyncStatus = 1 AND SyncId > 0  
    ) B  
   Where   
    A.DistCode = B.DistCode AND   
    A.SyncId = B.SyncId   
 Delete A From #Console2CS_Consolidated A (Nolock) Where DWNStatus = 0 
 Create Table #Process(ProcessName Varchar(100),PrkTableName Varchar(100), id Int Identity(1,1) )  
 Insert Into #Process(ProcessName , PrkTableName)   
 Select Distinct A.ProcessName , A.PrkTableName From Tbl_DownloadIntegration A,#Console2CS_Consolidated B   
 Where A.ProcessName = B.ProcessName And A.SequenceNo not in(100000) --Order By Sequenceno  
  Set @Lvar = 1  
  Select @MaxId = Max(id) From #Process  
  While @Lvar <= @MaxId  
   Begin  
    Select @Tablename = PrkTableName , @Process = ProcessName From #Process Where id  = @Lvar  
    Select @colcount = Count(Column_ID) From sys.columns Where object_id = (select object_id From sys.objects Where name = @Tablename)  
    Set @SqlStr = ''  
    Set @SqlStr = @SqlStr + ' Insert Into ' + @Tablename + ' '  
    Set @Col = ''  
    select @Col = @Col + '[' +name + '],' From sys.columns   
    where object_id = ( select object_id From sys.objects Where name = @Tablename) Order by Column_Id  
    Truncate Table #Col      
    Insert Into #Col     
    Select  a.column_id + 5 As ColId  
    From sys.columns a,sys.types b where a.user_type_id = b.user_type_id  
    and a.object_id = ( Select object_id From sys.objects Where name = @Tablename)  
    and b.name = 'datetime' --and a.name <> 'CreatedDate'  
    Set @SqlStr = @SqlStr + '(' + left(@Col,len(@Col)-1)  + ') '  
    Set @Col = ''  
    Select @Col = @Col + (Case when column_id In (Select ColId From #Col) then 'Convert(Datetime,'+name + ',121)' else name end) + ','   
    From sys.columns Where object_id = ( Select object_id From sys.objects Where name = 'Console2CS_Consolidated ')  
    and column_id  between 6 and 5 + @colcount 
    Order by column_id
    Set @SqlStr = @SqlStr + ' Select '+ left(@Col,len(@Col)-1)  + ' From #Console2CS_Consolidated (nolock) '  
    Set @SqlStr = @SqlStr + ' Where ProcessName = '''+ @Process +''' And DWNStatus = 1 '      
--    Print (@SqlStr) 
    Exec (@SqlStr)  
    Set @Lvar = @Lvar + 1  
   End  
   Update A Set A.DownloadFlag = 'Y'   
   From   
    Console2CS_Consolidated A (nolock),  
    #Console2CS_Consolidated B (nolock)  
   Where   
    A.DistCode= B.DistCode And   
    A.SyncId = B.SyncId And   
    B.DWNStatus = 1  
   Update A Set A.SyncFlag = 1  
   From   
    Syncstatus_Download A (nolock),  
    #Console2CS_Consolidated B (nolock)  
   Where   
    A.DistCode= B.DistCode And   
    A.SyncId = B.SyncId And   
    B.DWNStatus = 1  
COMMIT TRANSACTION    
 END TRY    
 BEGIN CATCH    
  ROLLBACK TRANSACTION    
  INSERT INTO XML2CSPT_ErrorLog VALUES ('Proc_Console2CS_ConsolidatedDownload', ERROR_MESSAGE(), GETDATE())    
 END CATCH    
END
GO
DELETE FROM Tbl_UploadIntegration WHERE ProcessName = 'MIS Details'
INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate)
SELECT 1003,'MIS Details','MIS_Details','Cs2Cn_Prk_MISDetails',GETDATE()
GO
DELETE FROM CustomUpDownload WHERE Module = 'MIS Details' AND UpDownload = 'Upload'
INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile)
SELECT 130,1,'MIS Details','MIS Details','Proc_CS2CN_MISDetails','','Cs2Cn_Prk_MISDetails','','Transaction','Upload',1
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Cs2Cn_Prk_MISDetails' AND XTYPE='U')
DROP TABLE Cs2Cn_Prk_MISDetails
GO
CREATE TABLE Cs2Cn_Prk_MISDetails
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[Ord_Date] [datetime] NULL,
	[Total_Orders] [numeric](18, 0) NULL,
	[Total_Bills] [numeric](18, 0) NULL,
	[Tot_Reg_Retailer] [numeric](18, 0) NULL,
	[MTD_RetOrder_Count] [numeric](18, 0) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL,
	[Total_Ret_Billed] [numeric](18, 0) NULL,
	[TotBilled_Ret_Last7Days] [numeric](18, 0) NULL,
	[TotBilled_Ret_Last30Days] [numeric](18, 0) NULL
)
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='MIS_UPDATE' AND XTYPE='U')
CREATE TABLE MIS_UPDATE
 (
	 UPDATED INT,
	 UpdatedDate datetime,
	 UploadedDate datetime
 )
GO
IF NOT EXISTS (SELECT * FROM MIS_UPDATE)
BEGIN
	INSERT INTO MIS_UPDATE
	SELECT 0,GETDATE(),GETDATE()
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME = 'Proc_CS2CN_MISDetails' AND XTYPE= 'P')
DROP PROCEDURE Proc_CS2CN_MISDetails
GO
/*
Begin transaction
delete from Cs2Cn_Prk_MISDetails
--select * from mis_update
--update mis_update set uploadeddate ='2014-11-01'
EXEC Proc_CS2CN_MISDetails 0,'2014-02-04'
select * from Cs2Cn_Prk_MISDetails order by slno
Rollback Transaction
*/
CREATE PROCEDURE Proc_CS2CN_MISDetails
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_CS2CN_MISDetails 
* PURPOSE		: To Extract LMISDetails
* CREATED BY	: KARTHICK
* CREATED DATE	: 2014-02-04
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @StartOfMonth  DATETIME
	DECLARE @DAY AS INT
	--DECLARE @DAYCNT AS INT
	DECLARE @CURDATE AS DATETIME 
	DECLARE @CmpId 			AS INT
	DECLARE @DistCode	    As NVARCHAR(50)
	DECLARE @UploadedDate   AS DATETIME
	DECLARE @FromDate       AS DATETIME
	--DECLARE @DayStart AS  INT
	DECLARE @DateDiff AS INT
	
	DELETE FROM Cs2Cn_Prk_MISDetails WHERE UploadFlag = 'Y'
	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)
	
	SET @Po_ErrNo=0
	--SELECT @DAYCNT=DATEPART(DAYOFYEAR, GETDATE())
	--SELECT @DayStart=DATEPART(DAYOFYEAR,UploadedDate) FROM MIS_UPDATE
	
IF EXISTS (SELECT * FROM MIS_UPDATE(NOLOCK) WHERE UPDATED=0)
	BEGIN
	    UPDATE MIS_UPDATE SET UPDATED=1,UploadedDate=GETDATE()
	    SELECT @StartOfMonth=UploadedDate-1 FROM MIS_UPDATE(NOLOCK)
	    SELECT @DateDiff = DATEDIFF (DD,@StartOfMonth,CONVERT(VARCHAR(10),GETDATE(),121))
	    SET @DateDiff  = ISNULL(@DateDiff,0) 
		--SET @StartOfMonth='2014-02-02'
		--SELECT @DayStart=DATEPART(DAYOFYEAR,'2014-02-02')
		
		SET @DAY=1
		--WHILE 	(@DayStart<=@DAYCNT)
		WHILE(@DateDiff>0)
		BEGIN
			SELECT @CURDATE=CONVERT(VARCHAR(10),DATEADD(DD, @DAY , @StartOfMonth ) ,121)
			SET @DAY=@DAY+1	
			--SET @DayStart=@DayStart+1
			SELECT @FromDate= CONVERT(VARCHAR(10),DATEADD (dd,-15,@CURDATE),121) 
			IF @CURDATE<=CONVERT(VARCHAR(10),GETDATE(),121)
			 BEGIN
				INSERT INTO Cs2Cn_Prk_MISDetails(DistCode,Ord_Date,Total_Orders,Total_Bills,Tot_Reg_Retailer,MTD_RetOrder_Count,UploadFlag,ServerDate,Total_Ret_Billed)
				SELECT @DistCode,CONVERT(VARCHAR(10),@CURDATE,121),0,COUNT(Distinct Rtrid)Rtrid,(SELECT COUNT(RTRID)RTRCNT FROM Retailer (NOLOCK) WHERE RtrStatus=1),0,'N',@ServerDate,0  
				FROM SalesInvoice  
				WHERE SalInvDate=CONVERT(VARCHAR(10),@CURDATE,121) and OrderKeyNo NOT IN (SELECT orderno FROM OrderBooking(NOLOCK)) AND DlvSts <>3
				
				UPDATE 	Cs2Cn_Prk_MISDetails SET Total_Orders=(SELECT COUNT(DISTINCT RtrId) FROM SalesInvoice(NOLOCK) 
				WHERE SalInvDate =CONVERT(VARCHAR(10),@CURDATE,121) and OrderKeyNo in (SELECT orderno from OrderBooking(NOLOCK)) AND DlvSts <>3 )
				WHERE Ord_Date=@CURDATE
				
				UPDATE 	Cs2Cn_Prk_MISDetails SET Total_Ret_Billed= (SELECT COUNT(DISTINCT RTRID) FROM
				(SELECT DISTINCT RTRID FROM SALESINVOICE(NOLOCK) WHERE SalInvDate=CONVERT(VARCHAR(10),@CURDATE,121) AND DlvSts <>3)A) 
				WHERE Ord_Date=@CURDATE
				
				UPDATE 	Cs2Cn_Prk_MISDetails SET MTD_RetOrder_Count= (SELECT COUNT(DISTINCT RTRID) FROM
				(SELECT DISTINCT RTRID FROM SALESINVOICE(NOLOCK) WHERE SalInvDate BETWEEN @FromDate AND CONVERT(VARCHAR(10),@CURDATE,121) AND DlvSts <>3)A) 
				WHERE Ord_Date=@CURDATE
				--
				UPDATE 	Cs2Cn_Prk_MISDetails SET TotBilled_Ret_Last7Days= (SELECT COUNT(DISTINCT RTRID) FROM
				(SELECT DISTINCT RTRID FROM SALESINVOICE(NOLOCK) WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),DATEADD (dd,-7,@CURDATE),121)  AND CONVERT(VARCHAR(10),@CURDATE,121) AND DlvSts <>3)A)
				 WHERE Ord_Date=@CURDATE
				
				UPDATE 	Cs2Cn_Prk_MISDetails SET TotBilled_Ret_Last30Days= (SELECT COUNT(DISTINCT RTRID) FROM
				(SELECT DISTINCT RTRID FROM SALESINVOICE(NOLOCK) WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),DATEADD (dd,-30,@CURDATE),121)  AND CONVERT(VARCHAR(10),@CURDATE,121) AND DlvSts <>3)A)
				 WHERE Ord_Date=@CURDATE
				
				--
				SET @DateDiff = @DateDiff -1 
		   END				
		END
		UPDATE MIS_UPDATE SET UPDATED=1,UploadedDate=GETDATE()
	END
ELSE
	BEGIN
	  SELECT @StartOfMonth=UploadedDate-1 FROM MIS_UPDATE(NOLOCK)
	  SELECT @DateDiff = DATEDIFF (DD,@StartOfMonth,CONVERT(VARCHAR(10),GETDATE(),121))
	  SET @DateDiff  = ISNULL(@DateDiff,0) 
	  SET @DAY=1
		--WHILE 	(@DayStart<=@DAYCNT) 
		WHILE(@DateDiff>0)
		  BEGIN
			SELECT @CURDATE=CONVERT(VARCHAR(10),DATEADD(DD, @DAY , @StartOfMonth ) ,121)
			SET @DAY=@DAY+1	
			--SET @DayStart=@DayStart+1
			
			IF @CURDATE<=CONVERT(VARCHAR(10),GETDATE(),121)
			 BEGIN			 						 
				SELECT @FromDate= CONVERT(VARCHAR(10),DATEADD (dd,-15,@CURDATE),121)
								
				INSERT INTO Cs2Cn_Prk_MISDetails(DistCode,Ord_Date,Total_Orders,Total_Bills,Tot_Reg_Retailer,MTD_RetOrder_Count,UploadFlag,ServerDate,Total_Ret_Billed)
				SELECT @DistCode,CONVERT(VARCHAR(10),@CURDATE,121),0,COUNT(Distinct Rtrid)Rtrid,(SELECT COUNT(RTRID)RTRCNT FROM Retailer (NOLOCK) WHERE RtrStatus=1),0,'N',@ServerDate,0  
				FROM SalesInvoice(NOLOCK)  
				WHERE SalInvDate=CONVERT(VARCHAR(10),@CURDATE,121) and OrderKeyNo NOT IN (SELECT orderno FROM OrderBooking(NOLOCK)) AND DlvSts <>3
				
				UPDATE 	Cs2Cn_Prk_MISDetails SET Total_Orders=(SELECT COUNT(Distinct RtrId) FROM SalesInvoice(NOLOCK) 
						WHERE SalInvDate =CONVERT(VARCHAR(10),@CURDATE,121) AND OrderKeyNo IN (SELECT orderno FROM OrderBooking(NOLOCK)) AND DlvSts <>3)
				WHERE  Ord_Date =  CONVERT(VARCHAR(10),@CURDATE,121) -- Added	
				
				UPDATE 	Cs2Cn_Prk_MISDetails SET Total_Ret_Billed= (SELECT COUNT(DISTINCT RTRID) FROM
				(SELECT DISTINCT RTRID FROM SALESINVOICE(NOLOCK) WHERE SalInvDate=CONVERT(VARCHAR(10),@CURDATE,121) AND DlvSts <>3)A)
				WHERE  Ord_Date =  CONVERT(VARCHAR(10),@CURDATE,121) -- Added
										
				UPDATE 	Cs2Cn_Prk_MISDetails SET MTD_RetOrder_Count= (SELECT COUNT(DISTINCT RTRID) FROM
				(SELECT DISTINCT RTRID FROM SALESINVOICE(NOLOCK) WHERE SalInvDate BETWEEN @FromDate AND CONVERT(VARCHAR(10),@CURDATE,121) AND DlvSts <>3)A)
				WHERE  Ord_Date =  CONVERT(VARCHAR(10),@CURDATE,121) -- Added
										
				UPDATE 	Cs2Cn_Prk_MISDetails SET TotBilled_Ret_Last7Days= (SELECT COUNT(DISTINCT RTRID) FROM
				(SELECT DISTINCT RTRID FROM SALESINVOICE(NOLOCK) WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),DATEADD (dd,-7,@CURDATE),121) AND CONVERT(VARCHAR(10),@CURDATE,121) AND DlvSts <>3)A)
				WHERE  Ord_Date =  CONVERT(VARCHAR(10),@CURDATE,121) -- Added
				
				UPDATE 	Cs2Cn_Prk_MISDetails SET TotBilled_Ret_Last30Days= (SELECT COUNT(DISTINCT RTRID) FROM
				(SELECT DISTINCT RTRID FROM SALESINVOICE(NOLOCK) WHERE SalInvDate BETWEEN CONVERT(VARCHAR(10),DATEADD (dd,-30,@CURDATE),121) AND CONVERT(VARCHAR(10),@CURDATE,121) AND DlvSts <>3)A)
				WHERE  Ord_Date =  CONVERT(VARCHAR(10),@CURDATE,121) -- Added
				
				UPDATE MIS_UPDATE SET UPDATED=1,UploadedDate=GETDATE()
			    
			    SET @DateDiff = @DateDiff -1 
			END 
	  END	
   END	
END
GO
IF EXISTS (SELECT Name FROM Sysobjects WHERE Xtype = 'P' AND Name = 'Proc_Cn2Cs_TaxSetting')
DROP PROCEDURE Proc_Cn2Cs_TaxSetting
GO
/*
BEGIN TRANSACTION
EXEC Proc_CN2CS_TaxSetting 0
SELECT * FROM ErrorLog
select * from Etl_Prk_TaxSetting (Nolock)
--SELECT * FROM TaxSettingMaster
--SELECT * FROM TaxSettingDetail
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_TaxSetting 
(
	@Po_ErrNo INT OUTPUT
)
AS
/*************************************************************************************************************
* PROCEDURE	: Proc_CN2CS_TaxSetting
* PURPOSE	: To Store TaxGroup Setting records  from xml file in the Table TaxGroupSetting
* CREATED	: Mahalakshmi.A
* CREATED DATE	: 20/08/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------------------------------------
* {date}		{developer}		{brief modification description}
* 07/09/2009    Nandakumar R.G  Change the validations for Tax on Tax and other basic validations
* 09.09.2009    Panneer			Update the Download Flag in Parking Table
* 19/08/2010    Nandakumar R.G  Discount Validation Changes
* 28/04/2011    Nandakumar R.G  Discount Validation Changes
**************************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TaxGroupCode	 AS NVARCHAR(200)
	DECLARE @Type			 AS NVARCHAR(200)
	DECLARE @PrdTaxGroupCode AS NVARCHAR(200)
	DECLARE @TaxCode		 AS NVARCHAR(200)
	DECLARE @Percentage	     AS NUMERIC(38,6)
	DECLARE @ApplyOn		 AS NVARCHAR(100)
	DECLARE @Discount		 AS NVARCHAR(100)
	DECLARE @Tabname		 AS NVARCHAR(100)
	DECLARE @ErrDesc		 AS NVARCHAR(1000)
	DECLARE @sSql			 AS NVARCHAR(4000)
	DECLARE @ErrStatus		 AS INT
	DECLARE @Taction		 AS INT
	DECLARE @TaxSeqId	 AS INT
	DECLARE @RtrId		 AS INT
	DECLARE @PrdId		 AS INT
	DECLARE @BillSeqId	 AS INT
	DECLARE @Slno		 AS INT
	DECLARE @ColNo		 AS INT
	DECLARE @iCntColNo	 AS INT
	DECLARE @iColType	 AS INT
	DECLARE @ColValue	 AS INT
	DECLARE @RowId		 AS INT
	DECLARE @TaxId		 AS INT
	DECLARE @iApplyOn	 AS INT
	DECLARE @iDiscount	 AS INT
	DECLARE @DColNo		 AS INT
	DECLARE @FieldDesc	 AS NVARCHAR(100)
	DECLARE @SColNo		 AS INT
	DECLARE @ColId		 AS INT
	DECLARE @SlNo1		 AS INT
	DECLARE @SlNo2		 AS INT
	DECLARE @BillSeqId_Temp	AS	INT
	DECLARE @EffetOnTax		AS	INT
	DECLARE @SchDiscount		 AS NVARCHAR(100)
	DECLARE @DBDiscount		 AS NVARCHAR(100)
	DECLARE @CDDiscount		 AS NVARCHAR(100)
	DECLARE @FreightCharge   AS NVARCHAR(100)
	/*
		SET @iColType=1   For TaxPercentage Value Column
		SET @iColType=2	  For MRP,SellingRate,PurchaseRate , Bill Column Sequence Value and Purchase Column Sequence
		SET @iColType=3   For Tax Configuration TaxCode Column Value
		SET @ColValue=0	  For "NONE"
		SET @ColValue=1   For "ADD"
		SET @ColValue=2   For "REDUCE"		
	*/
	
	SET @Tabname = 'Etl_Prk_TaxSetting'
	SET @Po_ErrNo=0
	SET @iCntColNo=0
	DECLARE @TblColNo TABLE
	(
		ColNo			INT IDENTITY(0,1) NOT NULL,
		SlNo1			INT,
		SlNo2			INT,
		FieldDesc		NVARCHAR(50)
	)
	DECLARE @T1 TABLE
	(
		SlNo			INT,
		FieldDesc		NVARCHAR(50)
	)
	DELETE FROM Etl_Prk_TaxSetting WHERE DownLoadFlag='Y'
	DECLARE Cur_TaxSettingMaster CURSOR		--TaxSettingMaster Cursor
	FOR SELECT DISTINCT ISNULL(TaxGroupCode,''),ISNULL(Type,''),ISNULL(PrdTaxGroupCode,'')
	FROM Etl_Prk_TaxSetting WHERE DownloadFlag='D'
	OPEN Cur_TaxSettingMaster
	
	FETCH NEXT FROM Cur_TaxSettingMaster INTO @TaxGroupCode,@Type,@PrdTaxGroupCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		--Check the Empty Values for TaxSetting Master
		SET @iCntColNo=6
		IF @TaxGroupCode=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Tax Group Code: ' + @TaxGroupCode + ' should not be Empty'
			INSERT INTO Errorlog VALUES (1,@Tabname,'Tax Group code',@ErrDesc)
		END
		IF @Type=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Type ' + @Type + ' should not be Empty'
			INSERT INTO Errorlog VALUES (1,@Tabname,'Type',@ErrDesc)
		END
		IF @PrdTaxGroupCode=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Product Tax Group Code ' + @PrdTaxGroupCode + ' should not be Empty'
			INSERT INTO Errorlog VALUES (1,@Tabname,'Type',@ErrDesc)
		END
		--Till Here
		IF NOT EXISTS  (SELECT * FROM TaxgroupSetting WHERE RtrGroup = @TaxGroupCode) --Get the Retailer/Supplier TaxGroupId's
		BEGIN
			SET @Po_ErrNo=1
			SET @ErrDesc = 'TaxGroupCode ' + @TaxGroupCode + ' is not available' 		
			INSERT INTO Errorlog VALUES (2,@Tabname,'Tax Group Code',@ErrDesc)
		END
		ELSE
		BEGIN
			SELECT @RtrId=TaxGroupId FROM TaxGroupSetting WHERE RtrGroup= @TaxGroupCode
		END
		IF NOT EXISTS  (SELECT * FROM TaxgroupSetting WHERE PrdGroup = @PrdTaxGroupCode) --Get the Product TaxGroupId's
		BEGIN
			SET @Po_ErrNo=1
			SET @ErrDesc = 'Product TaxGroupCode ' + @PrdTaxGroupCode + ' is not available' 		
			INSERT INTO Errorlog VALUES (2,@Tabname,'Product Tax Group Code',@ErrDesc)
		END
		ELSE
		BEGIN
			SELECT @PrdId=TaxGroupId FROM TaxGroupSetting WHERE PrdGroup= @PrdTaxGroupCode
		END
		
		DELETE FROM @T1
		IF UPPER(@Type)='RETAILER'
		BEGIN
			SELECT DISTINCT @BillSeqId=BillSeqId FROM BillSequenceDetail (NOLOCK)
			WHERE SlNo >= 4 and SlNo < (SELECT Slno From BillSequenceDetail WHERE RefCode='H' and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)) and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)
			SELECT @iCntColNo=@iCntColNo+COUNT(BillSeqId) FROM BillSequenceDetail (NOLOCK)
			WHERE SlNo >= 4 and SlNo < (SELECT Slno From BillSequenceDetail WHERE RefCode='H' and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)) and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)
			
			INSERT INTO @T1(SlNo,FieldDesc)
			SELECT Slno,FieldDesc
			FROM BillSequenceDetail (NOLOCK)
			WHERE SlNo >= 4 and SlNo <
			(SELECT Slno From BillSequenceDetail WHERE RefCode='H' and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)) Order By SlNo
		END
		ELSE IF UPPER(@Type)='SUPPLIER'
		BEGIN
			SELECT DISTINCT @BillSeqId=PurSeqId FROM PurchaseSequenceDetail (NOLOCK)
			WHERE SlNo >= 3 and SlNo <
			(SELECT Slno From PurchaseSequenceDetail WHERE RefCode='D' and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster))  and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster)
			
			SELECT @iCntColNo=@iCntColNo+COUNT(PurSeqId) FROM PurchaseSequenceDetail (NOLOCK)
			WHERE SlNo >= 3 and SlNo <
			(SELECT Slno From PurchaseSequenceDetail WHERE RefCode='D' and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster))  and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster)
			INSERT INTO @T1(SlNo,FieldDesc)
			SELECT Slno,FieldDesc FROM PurchaseSequenceDetail (NOLOCK)
			WHERE SlNo >= 3 and SlNo <
			(SELECT Slno From PurchaseSequenceDetail WHERE RefCode='D' and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster))
			and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster) Order By SlNo
		END
		SELECT @iCntColNo=@iCntColNo+(COUNT(TaxId)) FROM TaxConfiguration
		SELECT @TaxSeqId= dbo.Fn_GetPrimaryKeyInteger('TaxSettingMaster','TaxSeqId',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
		IF  @Po_ErrNo=0
		BEGIN	
			INSERT INTO TaxSettingMaster(TaxSeqId,RtrId,PrdId,SequenceDate,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@TaxSeqId,@RtrId,@PrdID,CONVERT(NVARCHAR(11),GETDATE(),121),1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
			SET @sSql= 'INSERT INTO TaxSettingMaster(TaxSeqId,RtrId,PrdId,SequenceDate,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@TaxSeqId AS NVARCHAR(100)) + ',' + CAST(@RtrId AS NVARCHAR(100)) +','+ CAST(@PrdId AS NVARCHAR(100))+ ','''
						+ CONVERT(NVARCHAR(11),GETDATE(),121)+''',1,1,''' + CONVERT(NVARCHAR(11),GETDATE(),121)+''',1,'''+ CONVERT(NVARCHAR(11),GETDATE(),121)+ ''')'
						
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			UPDATE Counters SET Currvalue = Currvalue + 1  WHERE	Tabname = 'TaxSettingMaster' AND Fldname = 'TaxSeqId'
			
			SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSettingMaster'' AND Fldname = ''TaxSeqId'''
			
			INSERT INTO Translog(strSql1) Values (@sSQL)
		END
		
		DECLARE @TaxSettingTable TABLE
		(
			TaxId			INT,
			TaxGrpCode		NVARCHAR(200),
			Type			NVARCHAR(200),
			TaxPrdGrpCode	NVARCHAR(200),
			TaxCode			NVARCHAR(200),
			Percentage		NUMERIC(38,6),
			Applyon			NVARCHAR(200),
			Discount		NVARCHAR(200),
			SchDiscount		NVARCHAR(200),
			DBDiscount		NVARCHAR(200),
			CDDiscount		NVARCHAR(200),
			FreightCharge   NVARCHAR(200)
		)
		DELETE FROM @TaxSettingTable
		INSERT INTO @TaxSettingTable (TaxId,TaxGrpCode,Type,TaxPrdGrpCode,TaxCode,Percentage,Applyon,Discount,
		SchDiscount,DBDiscount,CDDiscount,FreightCharge)
		SELECT DISTINCT TC.TaxId, ISNULL(ETL1.TaxGroupCode,''),ISNULL(ETL1.Type,''),
		ISNULL(ETL1.PrdTaxGroupCode,''),ISNULL(TC.TaxCode,''),ISNULL(ETL1.Percentage,0),
		ISNULL(ETL1.ApplyOn,'None'),ISNULL(ETL1.Discount,'None'),ISNULL(ETL1.SchDiscount,'None'),
		ISNULL(ETL1.DBDiscount,'None'),ISNULL(ETL1.CDDiscount,'None'),ISNULL(ETL1.FreightCharge,'None') 
		FROM
		(SELECT ISNULL(ETL.TaxGroupCode,'') AS TaxGroupCode,ISNULL(ETL.Type,'') AS Type,ISNULL(ETL.TaxCode,'') AS TaxCode,
		ISNULL(ETL.PrdTaxGroupCode,'') AS PrdTaxGroupCode,ISNULL(ETL.Percentage,0) AS Percentage,ISNULL(ETL.ApplyOn,'') AS ApplyOn,
		ISNULL(ETL.Discount,'') AS Discount,ISNULL(ETL.SchDiscount,'') AS SchDiscount,ISNULL(ETL.DBDiscount,'') AS DBDiscount,
		ISNULL(ETL.CDDiscount,'') AS CDDiscount,ISNULL(ETL.FreightCharge,'') AS FreightCharge
		FROM Etl_Prk_TaxSetting ETL
		WHERE DownloadFlag='D' AND TaxGroupCode=@TaxGroupCode AND PrdTaxGroupCode=@PrdTaxGroupCode) ETL1
		RIGHT OUTER JOIN TaxConfiguration TC ON TC.TaxCode=ETL1.TaxCode
		SET @RowId=0
		DECLARE Cur_TaxSettingDetail CURSOR		--TaxSettingDetail Cursor
		FOR SELECT TaxGrpCode,Type,TaxPrdGrpCode,TaxCode,Percentage,Applyon,Discount,SchDiscount,DBDiscount,CDDiscount,FreightCharge
		FROM @TaxSettingTable Order By TaxId
		OPEN Cur_TaxSettingDetail
		FETCH NEXT FROM Cur_TaxSettingDetail INTO @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount,
		@SchDiscount,@DBDiscount,@CDDiscount,@FreightCharge
		WHILE @@FETCH_STATUS=0
		BEGIN
			SET @RowId=@RowId+1
			--Nanda
			--SELECT @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount
			
			IF @TaxCode=''	--Check Empty Values For TaxSetting Details
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Tax Code' + @TaxCode + ' should not be Empty'
				INSERT INTO Errorlog VALUES (1,@Tabname,'Tax Code',@ErrDesc)
			END
			
			IF @Percentage<0
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Percentage' + CAST(@Percentage AS NVARCHAR(20)) + ' should not be Empty'
				INSERT INTO Errorlog VALUES (1,@Tabname,'Percentage',@ErrDesc)
			END
			IF @Applyon=''
			BEGIN
				SET @iApplyOn=0
			END
			ELSE IF UPPER(@ApplyOn)='SELLINGRATE' OR UPPER(@ApplyOn)='MRP' OR UPPER(@ApplyOn)='PURCHASERATE'
			BEGIN
				SET @iApplyOn=1
			END
			ELSE
			BEGIN
				SET @iApplyOn=2
			END
			IF @Discount='ADD'
			BEGIN
				SET @iDiscount=1
			END
			ELSE IF UPPER(@Discount)='REDUCE'
			BEGIN
				SET @iDiscount=2
			END
			ELSE
			BEGIN
				SET @iDiscount=0
			END		
			--Till Here
			IF NOT EXISTS  (SELECT * FROM TaxConfiguration WHERE TaxCode = @TaxCode )
			BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Tax Code: ' + @TaxCode + ' is not available' 		
				INSERT INTO Errorlog VALUES (1,@Tabname,'Tax Code',@ErrDesc)
			END
			ELSE
			BEGIN
				SELECT @TaxId=TaxId FROM TaxConfiguration WHERE TaxCode=@TaxCode	
			END
			DELETE FROM @TblColNo
			INSERT INTO @TblColNo(SlNo1,SlNo2,FieldDesc)
			SELECT 1,1,'TaxID' AS FieldDesc
			UNION
			SELECT 2,1,'Tax Name' AS FieldDesc
			UNION
			SELECT 3,1,'Tax%' AS FieldDesc
			UNION
			SELECT 4,1,'MRP' AS FieldDesc
			UNION
			SELECT 5,1,'SELLING RATE' AS FieldDesc
			UNION
			SELECT 6,1,'PURCHASE RATE' AS FieldDesc
			UNION
			SELECT 7,Slno,FieldDesc FROM @T1
			UNION
			SELECT 8,TaxId,TaxName FROM TaxConfiguration
			
			SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
			
			INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
			ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@RowId,1,@SlNo,@BillSeqId,@TaxSeqId,1,@TaxId,@TaxId,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
			
			SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
				+ CAST(@RowId AS NVARCHAR(100)) + ',1,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
				+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',1,' + CAST(@TaxId AS NVARCHAR(100)) + ',' +CAST(@TaxId AS NVARCHAR(100)) + ',1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
			SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
			INSERT INTO Translog(strSql1) Values (@sSQL)
			SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
			INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
			ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@RowId,3,@SlNo,@BillSeqId,@TaxSeqId,1,0,@Percentage,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					
			SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
				+ CAST(@RowId AS NVARCHAR(100)) + ',3,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
				+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',1,0,' +CAST(@Percentage AS NVARCHAR(100)) + ',1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
										
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			
			UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
			SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
			INSERT INTO Translog(strSql1) Values (@sSQL)
			SET @sColNo=4
			
			--------TaxSetting1-->Price Settings---------------------
			DECLARE Cur_TaxSetting1 CURSOR		--Column Wise Details Inserts row Wise Cursor
			FOR SELECT ColNo,FieldDesc FROM @TblColNo WHERE SlNo1>3 AND SlNo1<7
			OPEN Cur_TaxSetting1
			FETCH NEXT FROM Cur_TaxSetting1 INTO @DColNo,@FieldDesc
			WHILE @@FETCH_STATUS=0
			BEGIN
				IF @sColNo=4 AND UPPER(@ApplyOn)='MRP'
				BEGIN
					--SET MRP as 1 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,1,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,1,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					--SET Sellling Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Purchase Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE IF @sColNo=5 AND UPPER(@ApplyOn)='SELLINGRATE'	
				BEGIN
					--SET MRP AS Value as 0
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',4,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
		
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
		
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Selling Rate Value as 1
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,1,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',5,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,1,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
		
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
	
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Purchase Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE IF @sColNo=6 AND UPPER(@ApplyOn)='PURCHASERATE'	
				BEGIN
					--SET MRP AS Value as 0
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',4,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
		
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
		
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Sellling Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Purchase Rate as 1						
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,1,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,1,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
	
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE IF EXISTS(SELECT TaxCode FROM TaxConfiguration WHERE TaxCode=@ApplyOn) OR UPPER(@ApplyOn)='NONE'
				BEGIN					
					IF @sColNo=4
					BEGIN
						--SET MRP as 0 Value
						SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
						
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
							+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
							+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
						INSERT INTO Translog(strSql1) VALUES (@sSql)
						UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
						SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					END
					ELSE IF @sColNo=5
					BEGIN
						--SET Sellling Rate as 0 Value
						SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
							+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
							+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
						
						INSERT INTO Translog(strSql1) VALUES (@sSql)
						UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
						SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
					ELSE IF @sColNo=6
					BEGIN
						--SET Purchase Rate as 0 Value
						SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
							+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
							+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
												
						INSERT INTO Translog(strSql1) VALUES (@sSql)
						UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
						SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
				END	
--				--Nanda
--				SELECT * FROM TaxSettingDetail WHERE TaxSeqId=@TaxSeqId AND RowId=@RowId
				SET @sColNo=@sColNo+1
	
				FETCH NEXT FROM Cur_TaxSetting1 INTO @DColNo,@FieldDesc
			END
			CLOSE Cur_TaxSetting1
			DEALLOCATE Cur_TaxSetting1
			-----TaxSetting1--------------------------------
			----------------TaxSetting2-->Bill/Purchase Column Sequnce Settings---------------------
			SET @sColNo=7
			SET @ColId=4
			--Nanda
			--SELECT ColNo,SlNo1,FieldDesc FROM @TblColNo WHERE SlNo1=7
			DECLARE Cur_TaxSetting2 CURSOR		--Column Wise Details Inserts row Wise Cursor
			FOR
				SELECT ColNo,SlNo1,FieldDesc,SlNo2  FROM @TblColNo WHERE SlNo1=7
			OPEN Cur_TaxSetting2
			FETCH NEXT FROM Cur_TaxSetting2 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			WHILE @@FETCH_STATUS=0
			BEGIN
				
				SET @EffetOnTax=0
				IF UPPER(@Type)='RETAILER'
				BEGIN
					SELECT @BillSeqId_Temp=MAX(BillSeqId) FROM dbo.BillSequenceMaster
					SELECT @EffetOnTax=EffectInNetAmount FROM dbo.BillSequenceDetail WHERE BillSeqId=@BillSeqId_Temp 
					AND SlNo=@SlNo2
					--->Added By Nanda on 28/04/2011										
					IF @FieldDesc='Spl. Disc' 
					BEGIN
						IF UPPER(@Discount)='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@Discount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					ELSE IF @FieldDesc='Sch Disc' 
					BEGIN
						IF UPPER(@SchDiscount)='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@SchDiscount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					ELSE IF @FieldDesc='DB Disc' 
					BEGIN
						IF UPPER(@DBDiscount)='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@DBDiscount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					ELSE IF @FieldDesc='CD Disc'
					BEGIN
						IF UPPER(@CDDiscount)='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@CDDiscount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					ELSE
					BEGIN
						IF UPPER(@Discount)='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@Discount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					--->Till Here
				END
				ELSE IF UPPER(@Type)='SUPPLIER'
				BEGIN
					SELECT @BillSeqId_Temp=MAX(PurSeqId) FROM dbo.PurchaseSequenceMaster
					SELECT @EffetOnTax=EffectInNetAmount FROM dbo.PurchaseSequenceDetail WHERE PurSeqId=@BillSeqId_Temp 
					AND SlNo=@SlNo2
					
					IF UPPER(@FieldDesc)='FREIGHTCHARGES' 
					BEGIN
						IF UPPER(@FreightCharge)='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@FreightCharge)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
				     END
				     ELSE IF UPPER(@FieldDesc) = 'DISC'
					 BEGIN
					    IF UPPER(@Discount)='ADD'
					    BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@Discount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END
					 END
					 ELSE
					 BEGIN
					     SET @iDiscount=0
					 END
				END			        		 
									
				IF @iApplyOn=2
				BEGIN
					SET @EffetOnTax=0
				END				
				SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
				INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
				ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				--VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,2,@ColId,@EffetOnTax,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
				VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,2,@ColId,@iDiscount,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,'+ CAST(@ColId AS NVARCHAR(100))+ ',' +CAST(@EffetOnTax AS NVARCHAR(100))+',1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
										
				
				INSERT INTO Translog(strSql1) VALUES (@sSql)
				
				UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
				SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
		
				INSERT INTO Translog(strSql1) Values (@sSQL)					
				SET @sColNo=@sColNo+1
				SET @ColId=@ColId+1
				FETCH NEXT FROM Cur_TaxSetting2 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			END
			CLOSE Cur_TaxSetting2
			DEALLOCATE Cur_TaxSetting2
			------TaxSetting2-----------------------
			-------TaxSetting3-->Tax On Tax Settings-----------------------
			SET @sColNo=@sColNo
			SET @ColId=1
			
			DECLARE Cur_TaxSetting3 CURSOR		--Column Wise Details Inserts row Wise Cursor
			FOR SELECT ColNo,SlNo1,FieldDesc,SlNo2 FROM @TblColNo WHERE SlNo1=8 AND SlNo2<>@TaxId
			OPEN Cur_TaxSetting3
			FETCH NEXT FROM Cur_TaxSetting3 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			WHILE @@FETCH_STATUS=0
			BEGIN
				SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
				IF @iApplyOn<>2
				BEGIN
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,3,@TaxId,0,1,1,
					CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT * FROM TaxConfiguration WHERE TaxCode=@Applyon AND TaxId=@SlNo2)
					BEGIN
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,3,@TaxId,@SlNo2,1,1,
						CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @iApplyOn=1
					END
					ELSE
					BEGIN
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,3,@TaxId,0,1,1,
						CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					END
				END
				SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',3,'+ CAST(@TaxId AS NVARCHAR(100))+ ',0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
										
				
				INSERT INTO Translog(strSql1) VALUES (@sSql)
				UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
				SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
	
				INSERT INTO Translog(strSql1) Values (@sSQL)
				SET @ColId=@ColId+1
				FETCH NEXT FROM Cur_TaxSetting3 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			END
			CLOSE Cur_TaxSetting3
			DEALLOCATE Cur_TaxSetting3
			UPDATE Etl_Prk_TaxSetting  SET DownloadFlag = 'Y'
			WHERE TaxGroupCode = @TaxGroupCode AND TaxCode = @TaxCode AND Percentage = @Percentage
			AND Type = @Type AND PrdTaxGroupCode = @PrdTaxGroupCode
			FETCH NEXT FROM Cur_TaxSettingDetail INTO @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount,
			@SchDiscount,@DBDiscount,@CDDiscount,@FreightCharge
		END
		CLOSE Cur_TaxSettingDetail
		DEALLOCATE Cur_TaxSettingDetail
		FETCH NEXT FROM Cur_TaxSettingMaster INTO @TaxGroupCode,@Type,@PrdTaxGroupCode
	END
	CLOSE Cur_TaxSettingMaster
	DEALLOCATE Cur_TaxSettingMaster	
	UPDATE TaxSettingDetail SET ColVal=0 WHERE ColId=1 AND ColType=2 AND CAST(TaxSeqId AS NVARCHAR(10))+'~'+CAST(RowId AS NVARCHAR(10))
	NOT IN (SELECT CAST(TaxSeqId AS NVARCHAR(10))+'~'+CAST(RowId AS NVARCHAR(10)) FROM TaxSettingDetail WHERE ColType=1 AND ColId IN(SELECT TaxId FROM TaxConfiguration WHERE TaxCode='VAT'))
	AND  CAST(TaxSeqId AS NVARCHAR(10))+'~'+CAST(RowId AS NVARCHAR(10)) IN (
	SELECT CAST(TaxSeqId AS NVARCHAR(10))+'~'+CAST(RowId AS NVARCHAR(10)) FROM TaxSettingDetail WHERE ColType=1 AND ColId=0 AND ColVal=0)
	
	--Retailer Latest Tax Group Updation
	IF NOT EXISTS (SELECT DISTINCT [Type],COUNT(DISTINCT TaxGroupCode) FROM Etl_Prk_TaxSetting (NOLOCK) WHERE [Type] = 'Retailer' 
	GROUP BY [Type] HAVING COUNT(DISTINCT TaxGroupCode)>1)
	BEGIN
		DECLARE @RtrTaxGroupId AS NUMERIC(18,0)
		SET @RtrTaxGroupId = 0
		SELECT @RtrTaxGroupId = B.TaxGroupId FROM Etl_Prk_TaxSetting A (NOLOCK) 
		INNER JOIN TaxGroupSetting B (NOLOCK) ON A.TaxGroupCode = B.RtrGroup WHERE B.TaxGroup = 1
		IF @RtrTaxGroupId <> 0
		BEGIN 	
		   UPDATE Retailer SET TaxGroupId = @RtrTaxGroupId
		END
	END
	--Till Here
	--Supplier Latest Tax Group Updation
	IF NOT EXISTS (SELECT DISTINCT [Type],COUNT(DISTINCT TaxGroupCode) FROM Etl_Prk_TaxSetting (NOLOCK) WHERE [Type] = 'Supplier' 
	GROUP BY [Type] HAVING COUNT(DISTINCT TaxGroupCode)>1)
	BEGIN
		DECLARE @SupTaxGroupId AS NUMERIC(18,0)
		SET @SupTaxGroupId = 0
		SELECT @SupTaxGroupId = B.TaxGroupId FROM Etl_Prk_TaxSetting A (NOLOCK) 
		INNER JOIN TaxGroupSetting B (NOLOCK) ON A.TaxGroupCode = B.RtrGroup WHERE B.TaxGroup = 3
		IF @SupTaxGroupId <> 0
		BEGIN 	
		   UPDATE Supplier SET TaxGroupId = @SupTaxGroupId
		END
	END
	--Till Here
	
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
	(SELECT DISTINCT PrdCode,COUNT(DISTINCT TaxGroupCode) AS Counts FROM Etl_Prk_TaxMapping A (NOLOCK) 
	WHERE NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup B WHERE A.PrdCode = B.PrdCCode AND A.TaxGroupCode = B.TaxGrpCode) 
	GROUP BY PrdCode HAVING COUNT(DISTINCT TaxGroupCode) > 1) B ON A.PrdCode = B.PrdCode
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'Etl_Prk_TaxMapping','PrdCode','Same Product Should not Allow Multiple TaxGroup Code-'+A.PrdCode
	FROM Etl_Prk_TaxMapping A (NOLOCK) INNER JOIN (SELECT DISTINCT PrdCode,COUNT(DISTINCT TaxGroupCode) AS Counts 
	FROM Etl_Prk_TaxMapping A (NOLOCK) WHERE NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup B 
	WHERE A.PrdCode = B.PrdCCode AND A.TaxGroupCode = B.TaxGrpCode) GROUP BY PrdCode 
	HAVING COUNT(DISTINCT TaxGroupCode) > 1) B ON A.PrdCode = B.PrdCode	 	
	
	--Product Tax Group Code Updated
	UPDATE A SET A.TaxGroupId  = C.TaxGroupId FROM Product A (NOLOCK) 
	INNER JOIN Etl_Prk_TaxMapping B (NOLOCK) ON A.PrdCCode = B.PrdCode
	INNER JOIN TaxGroupSetting C (NOLOCK) ON B.TaxGroupCode = C.PrdGroup
	WHERE C.TaxGroup = 2 AND DownloadFlag = 'D' AND MapStatus = 1 AND
	NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup D WHERE B.PrdCode = D.PrdCCode AND B.TaxGroupCode = D.TaxGrpCode)	
	
	--Product Batch Tax Group Code Updated
	UPDATE PB SET PB.TaxGroupId  = C.TaxGroupId FROM ProductBatch PB (NOLOCK)
	INNER JOIN Product A (NOLOCK) ON PB.PrdId = A.PrdId 
	INNER JOIN Etl_Prk_TaxMapping B (NOLOCK) ON A.PrdCCode = B.PrdCode
	INNER JOIN TaxGroupSetting C (NOLOCK) ON B.TaxGroupCode = C.PrdGroup
	WHERE C.TaxGroup = 2 AND DownloadFlag = 'D' AND MapStatus = 1 AND
	NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup D WHERE B.PrdCode = D.PrdCCode AND B.TaxGroupCode = D.TaxGrpCode)
	
	--Download Flag Change
	UPDATE A SET A.DownloadFlag = 'Y' FROM Etl_Prk_TaxMapping A (NOLOCK) 
	INNER JOIN TaxGroupSetting B (NOLOCK) ON A.TaxGroupCode = B.PrdGroup 
	INNER JOIN Product C (NOLOCK) ON A.PrdCode = C.PrdCCode AND B.TaxGroupId = C.TaxGroupId 
	WHERE TaxGroup = 2 AND DownloadFlag = 'D'
	
RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND NAME='Fn_ReturnInvConStkDt')
DROP FUNCTION Fn_ReturnInvConStkDt
GO
--SELECT dBO.Fn_ReturnInvConStkDt(1)
CREATE FUNCTION Fn_ReturnInvConStkDt(@USRID INT)
RETURNS VARCHAR(MAX)
AS
/*********************************
* FUNCTION: Fn_ReturnInvConStkDt
* PURPOSE: Returns Current Stock Without Batch Wise Details
* NOTES: 
* CREATED: PRAVEENRAJ BHASKARAN 27/01/2015
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
*********************************/
BEGIN
	DECLARE @SSQL VARCHAR(MAX)
	--SET @SSQL='SELECT LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Saleable,UnSaleable,'
	--SET @SSQL= @SSQL + ' Offer, Total,PurchaseRate,SalPurRte,UnSalPurRte,OffPurRte,TotPurRte,SellingRate,SalSelRte,'
	--SET @SSQL= @SSQL + ' UnSalSelRte, OffSelRte , TotSelRte, Status, CmpId, PrdCtgValLinkCode, BatchSeqId, UserId '
	--SET @SSQL= @SSQL + ' FROM TempCurStk WHERE UserId=' + CAST (@USRID  AS VARCHAR(10)) + ' ORDER BY LcnId,PrdId,PrdBatId'	
	SET @SSQL='SELECT LcnId,LcnName,PrdId,PrdDCode,PrdName,0 PrdBatId,'''' PrdBatCode,SUM(Saleable) Saleable,SUM(UnSaleable) UnSaleable, SUM(Offer) Offer, '
	SET @SSQL= @SSQL + ' SUM(Total) Total,0 PurchaseRate,SUM(SalPurRte) SalPurRte,SUM(UnSalPurRte) UnSalPurRte,SUM(OffPurRte) OffPurRte,SUM(TotPurRte) TotPurRte,'
	SET @SSQL= @SSQL + ' 0 SellingRate,SUM(SalSelRte) SalSelRte,SUM(UnSalSelRte) UnSalSelRte,SUM(OffSelRte) OffSelRte,SUM(TotSelRte) TotSelRte, Status, '
	SET @SSQL= @SSQL + ' CmpId,MAX(PrdCtgValLinkCode) PrdCtgValLinkCode, MAX(BatchSeqId) BatchSeqId, UserId FROM ('
	SET @SSQL= @SSQL + ' SELECT LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Saleable,UnSaleable, Offer, '
	SET @SSQL= @SSQL + ' Total,PurchaseRate,SalPurRte,UnSalPurRte,OffPurRte,TotPurRte,SellingRate,SalSelRte, UnSalSelRte, OffSelRte , TotSelRte, Status, '
	SET @SSQL= @SSQL + ' CmpId, PrdCtgValLinkCode, BatchSeqId, UserId  FROM TempCurStk WHERE UserId=' + CAST (@USRID  AS VARCHAR(10)) + ' ) X'
	SET @SSQL= @SSQL + ' GROUP BY LcnId,LcnName,PrdId,PrdDCode,PrdName,Status,CmpId,UserId ORDER BY LcnId,PrdId'
	RETURN @SSQL
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND NAME='Fn_ReturnInventoryStockSummaryDatewise')
DROP FUNCTION Fn_ReturnInventoryStockSummaryDatewise
GO
--SELECT dBO.Fn_ReturnInventoryStockSummaryDatewise(1,1,0)
CREATE FUNCTION Fn_ReturnInventoryStockSummaryDatewise(@USRID INT,@Summary INT,@DateWise INT)
RETURNS VARCHAR(MAX)
AS
/*********************************
* FUNCTION: Fn_ReturnInventoryStockSummaryDatewise
* PURPOSE: Returns Stock Ledger Without Batch Wise Details
* NOTES: 
* CREATED: PRAVEENRAJ BHASKARAN 27/01/2015
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
*********************************/
BEGIN
		DECLARE @SSQL VARCHAR(MAX)
		SET @SSQL=''
		IF @Summary=1
		BEGIN
			IF @DateWise=1
			BEGIN
				SET @SSQL='SELECT TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,Purchase,'
				SET @SSQL= @SSQL + ' Sales,Adjustment,Closing,PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,'
				SET @SSQL= @SSQL + ' OpnSelRte,PurSelRte,SalSelRte,AdjSelRte,CloSelRte,BatchSeqId,PrdCtgValLinkCode,CmpId,Status,'
				SET @SSQL= @SSQL + ' UserId,TotalStock FROM('
				SET @SSQL= @SSQL + ' SELECT MAX(TransDate) TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,0 PrdBatId,'''' PrdBatCode, '
				SET @SSQL= @SSQL + ' SUM(Opening) Opening,SUM(Purchase) Purchase,SUM(Sales) Sales, SUM(Adjustment) Adjustment,'
				SET @SSQL= @SSQL + ' SUM(Closing) Closing,0 PurchaseRate, SUM(OpnPurRte) OpnPurRte,SUM(PurPurRte) PurPurRte,'
				SET @SSQL= @SSQL + ' SUM(SalPurRte) SalPurRte, SUM(AdjPurRte) AdjPurRte,SUM(CloPurRte) CloPurRte,0 SellingRate, '
				SET @SSQL= @SSQL + ' SUM(OpnSelRte) OpnSelRte,SUM(PurSelRte) PurSelRte,SUM(SalSelRte) SalSelRte, '
				SET @SSQL= @SSQL + ' SUM(AdjSelRte) AdjSelRte,SUM(CloSelRte) CloSelRte,MAX(BatchSeqId) BatchSeqId,' 
				SET @SSQL= @SSQL + ' MAX(PrdCtgValLinkCode) PrdCtgValLinkCode,CmpId,Status,UserId,SUM(TotalStock) TotalStock '
				SET @SSQL= @SSQL + ' FROM TempStockLedSummary  WHERE UserId='+ CAST(@USRID  AS VARCHAR(10)) + ''
				SET @SSQL= @SSQL + ' GROUP BY LcnId,LcnName,PrdId,PrdDCode,PrdName,CmpId,Status,UserId'
				SET @SSQL= @SSQL + ' ) X ORDER BY TransDate,PrdId,PrdBatId,LcnId'
			END
			ELSE
			BEGIN
				SET @SSQL='SELECT TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,Purchase,'
				SET @SSQL= @SSQL + ' Sales,Adjustment,Closing,PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,'
				SET @SSQL= @SSQL + ' OpnSelRte,PurSelRte,SalSelRte,AdjSelRte,CloSelRte,BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock FROM ('
				SET @SSQL= @SSQL + ' SELECT MAX(TransDate) TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,0 PrdBatId,'''' PrdBatCode,'
				SET @SSQL= @SSQL + ' SUM(Opening) Opening,SUM(Purchase) Purchase,SUM(Sales) Sales,SUM(Adjustment) Adjustment,'
				SET @SSQL= @SSQL + ' SUM(Closing) Closing,0 PurchaseRate,SUM(OpnPurRte) OpnPurRte,SUM(PurPurRte) PurPurRte,'
				SET @SSQL= @SSQL + ' SUM(SalPurRte) SalPurRte,SUM(AdjPurRte) AdjPurRte,SUM(CloPurRte) CloPurRte,0 SellingRate,'
				SET @SSQL= @SSQL + ' SUM(OpnSelRte) OpnSelRte,SUM(PurSelRte) PurSelRte,SUM(SalSelRte) SalSelRte,'
				SET @SSQL= @SSQL + ' SUM(AdjSelRte) AdjSelRte,SUM(CloSelRte) CloSelRte,MAX(BatchSeqId) BatchSeqId,'
				SET @SSQL= @SSQL + ' MAX(PrdCtgValLinkCode) PrdCtgValLinkCode,CmpId,Status,UserId,SUM(TotalStock) TotalStock'
				SET @SSQL= @SSQL + ' FROM TempStockLedSummary WHERE UserId='+ CAST(@USRID  AS VARCHAR(10)) + ''
				SET @SSQL= @SSQL + ' GROUP BY LcnId,LcnName,PrdId,PrdDCode,PrdName,CmpId,Status,UserId ) X'
				SET @SSQL= @SSQL + ' ORDER BY PrdId,PrdBatId,LcnId,TransDate'
			END		
		END
		ELSE
		BEGIN
			IF @DateWise=1
			BEGIN
				SET @SSQL='SELECT TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,SalOpenStock,UnSalOpenStock,'
				SET @SSQL= @SSQL + ' OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,'
				SET @SSQL= @SSQL + ' SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,'
				SET @SSQL= @SSQL + ' SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,UnSalStkJurOut,'
				SET @SSQL= @SSQL + ' OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,SalLcnTfrIn,'
				SET @SSQL= @SSQL + ' UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,'
				SET @SSQL= @SSQL + ' DamageIn,DamageOut,SalClsStock,UnSalClsStock,OfferClsStock,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock FROM ('
				SET @SSQL= @SSQL + ' SELECT MAX(TransDate) TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,0 PrdBatId,'''' PrdBatCode,'
				SET @SSQL= @SSQL + ' SUM(SalOpenStock) SalOpenStock,SUM(UnSalOpenStock) UnSalOpenStock,SUM(OfferOpenStock) OfferOpenStock,'
				SET @SSQL= @SSQL + ' SUM(SalPurchase) SalPurchase,SUM(UnsalPurchase) UnsalPurchase, SUM(OfferPurchase) OfferPurchase,'
				SET @SSQL= @SSQL + ' SUM(SalPurReturn) SalPurReturn,SUM(UnsalPurReturn) UnsalPurReturn,SUM(OfferPurReturn) OfferPurReturn,'
				SET @SSQL= @SSQL + ' SUM(SalSales) SalSales,SUM(UnSalSales) UnSalSales,SUM(OfferSales) OfferSales,'
				SET @SSQL= @SSQL + ' SUM(SalStockIn) SalStockIn,SUM(UnSalStockIn) UnSalStockIn,SUM(OfferStockIn) OfferStockIn,'
				SET @SSQL= @SSQL + ' SUM(SalStockOut) SalStockOut,SUM(UnSalStockOut) UnSalStockOut,SUM(OfferStockOut) OfferStockOut,'
				SET @SSQL= @SSQL + ' SUM(SalSalesReturn) SalSalesReturn,SUM(UnSalSalesReturn) UnSalSalesReturn,SUM(OfferSalesReturn) OfferSalesReturn,'
				SET @SSQL= @SSQL + ' SUM(SalStkJurIn) SalStkJurIn,SUM(UnSalStkJurIn) UnSalStkJurIn,SUM(OfferStkJurIn) OfferStkJurIn,'
				SET @SSQL= @SSQL + ' SUM(SalStkJurOut) SalStkJurOut,SUM(UnSalStkJurOut) UnSalStkJurOut,SUM(OfferStkJurOut) OfferStkJurOut,'
				SET @SSQL= @SSQL + ' SUM(SalBatTfrIn) SalBatTfrIn,SUM(UnSalBatTfrIn) UnSalBatTfrIn,SUM(OfferBatTfrIn) OfferBatTfrIn,'
				SET @SSQL= @SSQL + ' SUM(SalBatTfrOut) SalBatTfrOut,SUM(UnSalBatTfrOut) UnSalBatTfrOut,SUM(OfferBatTfrOut) OfferBatTfrOut,'
				SET @SSQL= @SSQL + ' SUM(SalLcnTfrIn) SalLcnTfrIn,SUM(UnSalLcnTfrIn) UnSalLcnTfrIn,SUM(OfferLcnTfrIn) OfferLcnTfrIn,'
				SET @SSQL= @SSQL + ' SUM(SalLcnTfrOut) SalLcnTfrOut,SUM(UnSalLcnTfrOut) UnSalLcnTfrOut,SUM(OfferLcnTfrOut) OfferLcnTfrOut,'
				SET @SSQL= @SSQL + ' SUM(SalReplacement) SalReplacement,SUM(OfferReplacement) OfferReplacement,SUM(DamageIn) DamageIn,'
				SET @SSQL= @SSQL + ' SUM(DamageOut) DamageOut,SUM(SalClsStock) SalClsStock,SUM(UnSalClsStock) UnSalClsStock,'
				SET @SSQL= @SSQL + ' SUM(OfferClsStock) OfferClsStock,MAX(PrdCtgValLinkCode) PrdCtgValLinkCode,CmpId,Status,UserId,'
				SET @SSQL= @SSQL + ' SUM(TotalStock) TotalStock'
				SET @SSQL= @SSQL + ' FROM TempStockLedDet WHERE UserId='+ CAST(@USRID  AS VARCHAR(10)) + ''
				SET @SSQL= @SSQL + ' GROUP BY LcnId,LcnName,PrdId,PrdDCode,PrdName,CmpId,Status,UserId ) X  ORDER BY TransDate,PrdId,PrdBatId,LcnId'
			END
			ELSE
			BEGIN
				SET @SSQL='SELECT TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,SalOpenStock,UnSalOpenStock,'
				SET @SSQL= @SSQL + ' OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,SalPurReturn,UnsalPurReturn,OfferPurReturn,'
				SET @SSQL= @SSQL + ' SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,'
				SET @SSQL= @SSQL + ' SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,UnSalStkJurOut,'
				SET @SSQL= @SSQL + ' OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,SalLcnTfrIn,'
				SET @SSQL= @SSQL + ' UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,'
				SET @SSQL= @SSQL + ' DamageIn,DamageOut,SalClsStock,UnSalClsStock,OfferClsStock,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock FROM ('
				SET @SSQL= @SSQL + ' SELECT MAX(TransDate) TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,0 PrdBatId,'''' PrdBatCode,'
				SET @SSQL= @SSQL + ' SUM(SalOpenStock) SalOpenStock,SUM(UnSalOpenStock) UnSalOpenStock,SUM(OfferOpenStock) OfferOpenStock,'
				SET @SSQL= @SSQL + ' SUM(SalPurchase) SalPurchase,SUM(UnsalPurchase) UnsalPurchase, SUM(OfferPurchase) OfferPurchase,'
				SET @SSQL= @SSQL + ' SUM(SalPurReturn) SalPurReturn,SUM(UnsalPurReturn) UnsalPurReturn,SUM(OfferPurReturn) OfferPurReturn,'
				SET @SSQL= @SSQL + ' SUM(SalSales) SalSales,SUM(UnSalSales) UnSalSales,SUM(OfferSales) OfferSales,'
				SET @SSQL= @SSQL + ' SUM(SalStockIn) SalStockIn,SUM(UnSalStockIn) UnSalStockIn,SUM(OfferStockIn) OfferStockIn,'
				SET @SSQL= @SSQL + ' SUM(SalStockOut) SalStockOut,SUM(UnSalStockOut) UnSalStockOut,SUM(OfferStockOut) OfferStockOut,'
				SET @SSQL= @SSQL + ' SUM(SalSalesReturn) SalSalesReturn,SUM(UnSalSalesReturn) UnSalSalesReturn,SUM(OfferSalesReturn) OfferSalesReturn,'
				SET @SSQL= @SSQL + ' SUM(SalStkJurIn) SalStkJurIn,SUM(UnSalStkJurIn) UnSalStkJurIn,SUM(OfferStkJurIn) OfferStkJurIn,'
				SET @SSQL= @SSQL + ' SUM(SalStkJurOut) SalStkJurOut,SUM(UnSalStkJurOut) UnSalStkJurOut,SUM(OfferStkJurOut) OfferStkJurOut,'
				SET @SSQL= @SSQL + ' SUM(SalBatTfrIn) SalBatTfrIn,SUM(UnSalBatTfrIn) UnSalBatTfrIn,SUM(OfferBatTfrIn) OfferBatTfrIn,'
				SET @SSQL= @SSQL + ' SUM(SalBatTfrOut) SalBatTfrOut,SUM(UnSalBatTfrOut) UnSalBatTfrOut,SUM(OfferBatTfrOut) OfferBatTfrOut,'
				SET @SSQL= @SSQL + ' SUM(SalLcnTfrIn) SalLcnTfrIn,SUM(UnSalLcnTfrIn) UnSalLcnTfrIn,SUM(OfferLcnTfrIn) OfferLcnTfrIn,'
				SET @SSQL= @SSQL + ' SUM(SalLcnTfrOut) SalLcnTfrOut,SUM(UnSalLcnTfrOut) UnSalLcnTfrOut,SUM(OfferLcnTfrOut) OfferLcnTfrOut,'
				SET @SSQL= @SSQL + ' SUM(SalReplacement) SalReplacement,SUM(OfferReplacement) OfferReplacement,SUM(DamageIn) DamageIn,'
				SET @SSQL= @SSQL + ' SUM(DamageOut) DamageOut,SUM(SalClsStock) SalClsStock,SUM(UnSalClsStock) UnSalClsStock,'
				SET @SSQL= @SSQL + ' SUM(OfferClsStock) OfferClsStock,MAX(PrdCtgValLinkCode) PrdCtgValLinkCode,CmpId,Status,UserId,'
				SET @SSQL= @SSQL + ' SUM(TotalStock) TotalStock'
				SET @SSQL= @SSQL + ' FROM TempStockLedDet WHERE UserId='+ CAST(@USRID  AS VARCHAR(10)) + ''
				SET @SSQL= @SSQL + ' GROUP BY LcnId,LcnName,PrdId,PrdDCode,PrdName,CmpId,Status,UserId ) X  ORDER BY PrdId,PrdBatId,LcnId,TransDate'
			END
		END
	RETURN	@SSQL
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_Cn2Cs_Product' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_Product
GO
/*
Begin transaction
EXEC Proc_Cn2Cs_Product 0
SELECT * FROM ProductCategoryValue(NOLOCK)
Rollback transaction
*/
CREATE PROCEDURE Proc_Cn2Cs_Product
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
	IF NOT EXISTS (SELECT CmpCode FROM Company WHERE DefaultCompany = 1)
	BEGIN
		INSERT INTO Errorlog VALUES (1,'Company','Company Code','DefaultCompany Not available')
		Return
	END
	IF NOT EXISTS (SELECT S.SpmCode FROM Supplier S,Company C
	WHERE C.CmpId=S.CmpId AND S.SpmDefault = 1 AND C.DefaultCompany = 1)
	BEGIN
		INSERT INTO Errorlog VALUES (1,'Supplier','Supplier Code','DefaultSupplier Not available')
		Return
	END		
	 
 SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany = 1 
 SELECT @SpmCode=ISNULL(S.SpmCode,0) FROM Supplier S,Company C  
 WHERE C.CmpId=S.CmpId AND S.SpmDefault = 1 AND C.DefaultCompany = 1  
 --TO INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
--SELECT * FROM ETL_Prk_ProductHierarchyLevelvalue
--select * from productcategorylevel
  INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Category',@CmpCode,BusinessCode,BusinessName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
  INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Brand',BusinessCode,CategoryCode,CategoryName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
  INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'PriceSlot',CategoryCode,FamilyCode,FamilyName,@CmpCode
  FROM Cn2Cs_Prk_Product
 INSERT INTO ETL_Prk_ProductHierarchyLevelvalue  
  ([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],  
  [Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])  
  SELECT DISTINCT 'Flavor',FamilyCode,GroupCode,GroupName,@CmpCode  
  FROM Cn2Cs_Prk_Product  
 INSERT INTO ETL_Prk_Product  
 ([Product Distributor Code],[Product Name],[Product Short Name],[Product Company Code],  
 [Product Hierarchy Level Value Code],[Supplier Code],[Stock Cover Days],  
 [Unit Per SKU],[Tax Group Code],[Weight],[Unit Code],[UOM Group Code],  
 [Product Type],[Effective From Date],[Effective To Date],[Shelf Life],[Status],[EAN Code],[Vending])  
 SELECT DISTINCT C.PrdCCode,C.PrdName,left(C.PrdName,20) AS ProductShortName,  
 C.PrdCCode,C.GroupCode,@SpmCode,0,1,'',C.PrdWgt,ISNULL(C.ProductUnit,'Unit'),C.UOMGroupCode,  
 C.ProductType,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121),0,C.ProductStatus,  
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
DELETE FROM Configuration Where ModuleId IN ('BILLRTEDIT2','BILLRTEDIT30','BILLRTEDIT31','BILLRTEDIT5','BILLRTEDIT16','GENCONFIG21')
INSERT INTO Configuration (ModuleId,ModuleName,[Description],[Status],Condition,ConfigValue,SeqNo)
SELECT 'BILLRTEDIT2','BillConfig_RateEdit','Allow Editing of Selling Rate in the billing screen',1,'',0.00,2 UNION
SELECT 'BILLRTEDIT16','BillConfig_RateEdit','Allow both addition and reduction',1,'',0.00,3 UNION
SELECT 'BILLRTEDIT30','BillConfig_RateEdit','Recalculate Selling rate based on edited Net Rate',1,'',0.00,30 UNION
SELECT 'BILLRTEDIT31','BillConfig_RateEdit','Recalculate Selling rate based on edited Net Rate',1,'',0.00,31 UNION
SELECT 'BILLRTEDIT5','BillConfig_RateEdit','Allow both addition and reduction',1,'',0.00,3 UNION
SELECT 'GENCONFIG21','General Configuration','Display MRP in Product Hot Search Screen',1,'Billing',0.00,21
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE XTYPE IN ('FN','TF') AND Name  = 'Fn_SpecialRateAftDownloadDetails')
DROP FUNCTION Fn_SpecialRateAftDownloadDetails
GO
--SELECT DISTINCT * FROM Dbo.Fn_SpecialRateAftDownloadDetails(0,'0')
CREATE FUNCTION [dbo].[Fn_SpecialRateAftDownloadDetails](@Pi_CurrentRate AS INT,@Pi_RtrCategory AS NVARCHAR(200),
@Pi_RtrCategoryValue AS NVARCHAR(200),@Pi_PrdCCode AS NVARCHAR(200)) 
RETURNS @SpecialRateAftDownloadDetails TABLE
(
  CtgLevelId       NUMERIC(18,0),
  CtgMainId        NUMERIC(18,0),
  RtrCtgCode       NVARCHAR(200),
  RtrCtgValueCode  NVARCHAR(200),
  RtrId            NUMERIC(18,0),
  RtrCode          NVARCHAR(200),
  PrdId            NUMERIC(18,0),
  PrdCCode         NVARCHAR(200),
  PrdName          NVARCHAR(200),
  Chk              NVARCHAR(200),
  SellingRate      NUMERIC(18,6),
  SplSelRate       NUMERIC(18,6),
  PDRate           NUMERIC(18,6),
  DiscountPerc     NUMERIC(18,6),
  FromDate         DATETIME,
  DownloadedDate   NVARCHAR(200)
)
/****************************************************	
* FUNCTION: Fn_SpecialRateAftDownloadDetails
* PURPOSE : Special Rate Download Details
* NOTES:
* CREATED : Sathishkumar Veeramani ON 29-01-2015
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
----------------------------------------------------
****************************************************/
AS
BEGIN
	IF @Pi_CurrentRate = 0
	BEGIN
	    INSERT INTO @SpecialRateAftDownloadDetails (CtgLevelId,CtgMainId,RtrCtgCode,RtrCtgValueCode,RtrId,RtrCode,PrdId,PrdCCode,PrdName,
        Chk,SellingRate,SplSelRate,PDRate,DiscountPerc,FromDate,DownloadedDate)
        SELECT DISTINCT RC.CtgLevelId,RC.CtgMainId,SRAD.RtrCtgCode,SRAD.RtrCtgValueCode,0 RtrId,SRAD.RtrCode,0 PrdId,SRAD.PrdCCode,P.PrdName,'' Chk,
		PrdBatDetailValue AS SellingRate,CAST(SRAD.SplSelRate AS NUMERIC(38,6)) SplSelRate,ISNULL(PD.Rate,0) AS PDRate,
		ISNULL(SRAD.DiscountPerc,0) AS DiscountPerc,SRAD.FromDate,SRAD.DownloadedDate 
		FROM (SELECT DISTINCT RtrCode,RtrCtgCode,PrdCCode,RtrCtgValueCode,CAST(SplSelRate AS NUMERIC(38,6)) SplSelRate,CONVERT(VARCHAR(10),
		DownloadedDate,103) DownloadedDate,FromDate,DiscountPerc FROM SpecialRateAftDownload (NOLOCK)) SRAD
		INNER JOIN Product P (NOLOCK) ON SRAD.PrdCCode=P.PrdCCode
		INNER JOIN ProductCategoryValue PCV (NOLOCK) ON P.PrdCtgvalMainId=PCV.PrdCtgValMainId
		INNER JOIN RetailerCategory RC (NOLOCK) 
		ON RC.CtgCode= (CASE ISNULL(SRAD.RtrCtgValueCode,'ALL') WHEN 'ALL' THEN RC.CtgCode ELSE SRAD.RtrCtgValueCode END)
		LEFT OUTER JOIN PriceDifference PD (NOLOCK) ON P.PrdId=PD.PrdId AND RC.CtgMainId=PD.CtgMainId
		INNER JOIN (SELECT P.PRDID,MAX(PB.PRDBATID)PRDBATID,PrdBatDetailValue  
		FROM Product P (NOLOCK) INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId =P.PrdId 
		INNER JOIN Productbatchdetails PBD (NOLOCK) ON PBD.PrdbatId=PB.PrdbatId 
		WHERE PBD.DefaultPrice=1 AND SLNo=3 GROUP BY P.PrdId,PrdBatDetailValue)C ON P.PrdId = C.PrdId
		WHERE PCV.PrdCtgValLinkCode LIKE '0%' AND RC.CtgLinkCode LIKE '0%' 
		AND SRAD.RtrCtgCode = (CASE ISNULL(@Pi_RtrCategory,'ALL') WHEN 'ALL' THEN SRAD.RtrCtgCode 
		WHEN ISNULL(@Pi_RtrCategory,'') THEN SRAD.RtrCtgCode ELSE @Pi_RtrCategory END)
		AND RC.CtgName = (CASE ISNULL(@Pi_RtrCategoryValue,'ALL') WHEN 'ALL' THEN RC.CtgName 
		WHEN '' THEN RC.CtgName ELSE @Pi_RtrCategoryValue END)
		AND SRAD.PrdCCode = (CASE @Pi_PrdCCode WHEN '0' THEN SRAD.PrdCCode ELSE @Pi_PrdCCode END)
		ORDER BY SRAD.RtrCtgValueCode,SRAD.RtrCode,SRAD.PrdCCode,P.PrdName
	END
    ELSE
    BEGIN
        INSERT INTO @SpecialRateAftDownloadDetails (CtgLevelId,CtgMainId,RtrCtgCode,RtrCtgValueCode,RtrId,RtrCode,PrdId,PrdCCode,PrdName,
        Chk,SellingRate,SplSelRate,PDRate,DiscountPerc,FromDate,DownloadedDate)
        SELECT DISTINCT 0 CtgLevelId,0 CtgMainId,SRAD.RtrCtgCode RtrCtgCode,SRAD.RtrCtgValueCode,0 RtrId,SRAD.RtrCode,0 PrdId,SRAD.PrdCCode,P.PrdName,'' Chk,
		PrdBatDetailValue AS SellingRate,CAST(SRAD.SplSelRate AS NUMERIC(38,6)) SplSelRate,ISNULL(PD.rate,0) AS PDRate,
		ISNULL(SRAD.DiscountPerc,0) AS DiscountPerc,SRAD.FromDate,SRAD.DownloadedDate 
		FROM (
		SELECT DISTINCT RtrCode,RtrCtgCode,PrdCCode,RtrCtgValueCode,CAST(SplSelRate AS NUMERIC(38,6)) SplSelRate,DownloadedDate DownloadedDate,
		FromDate,DiscountPerc FROM SpecialRateAftDownload (NOLOCK)) SRAD 
		INNER JOIN Product P (NOLOCK) ON SRAD.PrdCCode=P.PrdCCode
		INNER JOIN ProductCategoryValue PCV (NOLOCK) ON P.PrdCtgvalMainId=PCV.PrdCtgValMainId
		INNER JOIN RetailerCategory RC (NOLOCK) ON SRAD.RtrCtgValueCode = RC.CtgCode
		LEFT OUTER JOIN PriceDifference PD (NOLOCK) ON P.PrdId = PD.PrdId AND RC.CtgMainId = PD.CtgMainId
		INNER JOIN 
		(SELECT SRAD.RtrCtgCode,SRAD.RtrCtgValueCode,RC.CtgName,SRAD.RtrCode,SRAD.PrdCCode,P.PrdName,MAX(SRAD.FromDate) AS FromDate,
		ISNULL(DiscountPerc,0) AS DiscountPerc,MAX(SRAD.DownloadedDate) AS DownloadedDate 
		FROM SpecialRateAftDownload SRAD (NOLOCK) 
		INNER JOIN Product P (NOLOCK) ON SRAD.PrdCCode=P.PrdCCode
		INNER JOIN ProductCategoryValue PCV (NOLOCK) ON P.PrdCtgvalMainId=PCV.PrdCtgValMainId
		INNER JOIN RetailerCategory RC (NOLOCK) ON SRAD.RtrCtgValueCode = RC.CtgCode
		WHERE PCV.PrdCtgValLinkCode LIKE '0%' AND RC.CtgLinkCode LIKE '0%' 
		GROUP BY SRAD.RtrCtgCode,SRAD.RtrCtgValueCode,RC.CtgName,SRAD.RtrCode,SRAD.PrdCCode,P.PrdName,DiscountPerc)A 
		ON SRAD.RtrCtgValueCode=A.RtrCtgValueCode AND SRAD.RtrCode=A.RtrCode AND SRAD.PrdCCode=A.PrdCCode AND SRAD.DownloadedDate=A.DownloadedDate  
		AND P.PrdName=A.PrdName AND RC.CtgName=A.CtgName
		INNER JOIN 
		(SELECT P.PRDID,MAX(PB.PRDBATID)PRDBATID,PrdBatDetailValue  FROM Product P (NOLOCK)
		INNER JOIN ProductBatch PB (NOLOCK) ON pb.PrdId =p.PrdId INNER JOIN Productbatchdetails PBD (NOLOCK)ON PBD.prdbatid=pb.prdbatid 
		WHERE PBD.DefaultPrice=1 AND SLNo=3  GROUP BY P.PrdId,PrdBatDetailValue)C ON P.PrdId = C.PrdId
		WHERE PCV.PrdCtgValLinkCode LIKE '0%' AND RC.CtgLinkCode LIKE '0%'
		AND SRAD.RtrCtgCode = (CASE ISNULL(@Pi_RtrCategory,'ALL') WHEN 'ALL' THEN SRAD.RtrCtgCode 
		WHEN ISNULL(@Pi_RtrCategory,'') THEN SRAD.RtrCtgCode ELSE @Pi_RtrCategory END)
		AND RC.CtgName = (CASE ISNULL(@Pi_RtrCategoryValue,'ALL') WHEN 'ALL' THEN RC.CtgName 
		WHEN '' THEN RC.CtgName ELSE @Pi_RtrCategoryValue END)
		AND SRAD.PrdCCode = (CASE @Pi_PrdCCode WHEN '0' THEN SRAD.PrdCCode ELSE @Pi_PrdCCode END)  
		ORDER BY SRAD.RtrCtgValueCode,SRAD.RtrCode,SRAD.PrdCCode,P.PrdName,
		SRAD.FromDate,SRAD.DownloadedDate,SRAD.SplSelRate,PrdBatDetailValue        
	END         
RETURN
END
GO
DELETE FROM CustomCaptions WHERE TransId = 252 AND CtrlId = 17 AND SubCtrlId IN (9,10)
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,
LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,[Enabled])
SELECT 252,17,9,'DgCommon-252-17-9','Discount % On SellingRate','To Enter Discount % On SellingRate','',1,1,1,
GETDATE(),1,GETDATE(),'Discount % On SellingRate','To Enter Discount % On SellingRate','',1,1 UNION
SELECT 252,17,10,'DgCommon-252-17-10','Actual SellingRate','To Enter Actual SellingRate','',1,1,1,
GETDATE(),1,GETDATE(),'Actual SellingRate','To Enter Actual SellingRate','',1,1
GO
DELETE FROM Configuration WHERE ModuleId IN ('BILLRTEDIT6','BILLRTEDIT10','BILLRTEDIT17','BILLRTEDIT18','BILLRTEDIT20',
'BILLRTEDIT21','BILLRTEDIT22','BILLRTEDIT24')
INSERT INTO Configuration (ModuleId,ModuleName,[Description],[Status],Condition,ConfigValue,SeqNo)
SELECT 'BILLRTEDIT6','BillConfig_RateEdit','Make reason as mandatory if the user is reducing the Rate',0,'',0.00,6 UNION
SELECT 'BILLRTEDIT10','BillConfig_RateEdit','Make reason as mandatory if the user is adding the Rate',0,'',0.00,6 UNION
SELECT 'BILLRTEDIT24','BillConfig_RateEdit','Treat the difference amount in Rate Difference Claim',1,'',0.00,2 UNION
SELECT 'BILLRTEDIT17','BillConfig_RateEdit','Make reason as mandatory if the user is reducing the Rate',0,'',0.00,6 UNION
SELECT 'BILLRTEDIT18','BillConfig_RateEdit','Raise Claims Based on Reasons Attached',0,'',0.00,18 UNION
SELECT 'BILLRTEDIT20','BillConfig_RateEdit','Add the difference amount to Rate Difference Claim',1,'',0.00,22 UNION
SELECT 'BILLRTEDIT21','BillConfig_RateEdit','Make reason as mandatory if the user is adding the Rate',0,'',0.00,21 UNION
SELECT 'BILLRTEDIT22','BillConfig_RateEdit','Raise Claims Based on Reasons Attached',0,'',0.00,22
GO
DELETE FROM AutoBackupConfiguration WHERE ModuleId = 'AUTOBACKUP4'
INSERT INTO AutoBackupConfiguration (ModuleId,ModuleName,[Description],[Status],Condition,ConfigValue,BackupDate,SeqNo)
SELECT 'AUTOBACKUP4','AutomaticBackup','Take Compulsary Backup',0,'',0,CONVERT(NVARCHAR(10),GETDATE(),121),4
GO
DELETE FROM ProfileDt WHERE MenuId = 'mPrd78'
INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT DISTINCT PrfId,'mPrd78',0,'Display',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD (NOLOCK) UNION
SELECT DISTINCT PrfId,'mPrd78',1,'Cancel',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD (NOLOCK) UNION
SELECT DISTINCT PrfId,'mPrd78',2,'Exit',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM ProfileHD (NOLOCK)
GO
IF EXISTS (SELECT * FROM Sys.objects WHERE name='Proc_DashboardSummary' AND TYPE='P')
DROP PROCEDURE Proc_DashboardSummary
GO
--EXEC Proc_DashboardSummary
--SELECT * FROM DashBoardHD
--SELECT * FROM DashBoardBusinessPendingDT
--SELECT * FROM DashBoardSchemeDT
--SELECT * FROM DashBoardInventoryDT
CREATE PROCEDURE Proc_DashboardSummary
AS
/*********************************************************************************
* PROCEDURE	: Proc_DashboardSummary
* PURPOSE	: Dash Board Summary
* CREATED	: Jisha Mathew
* CREATED DATE	: 01/06/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------*/
SET NOCOUNT ON
BEGIN
	DECLARE @SchId INT
	DECLARE @Budget NUMERIC(38,3)
	DECLARE @CurrDate DATETIME
	DECLARE @YTDSales NUMERIC(38,3)
	DECLARE @MTDSales NUMERIC(38,3)
	DECLARE @PendingCollection NUMERIC(38,3)
	DECLARE @PenCollBillCnt INT
	DECLARE @TotSchemesCntforMonth INT
	DECLARE @TotSchemeBudget NUMERIC(38,3)
	DECLARE @TotSchemeUtilization NUMERIC(38,3)
	DECLARE @UtilPercenatge NUMERIC(38,3)
	DECLARE @TotSkuCnt INT
	DECLARE @TotActiveSkuCnt INT
	DECLARE @TotSkuCntWithStock INT
	DECLARE @StockValue NUMERIC(38,3)
	DECLARE @Utilization NUMERIC(38,3)
	DECLARE @Balance NUMERIC(38,3)
	DECLARE @UtilPercenatgeDT NUMERIC(38,3)
	SET  @YTDSales = 0.0
	SET  @MTDSales = 0.0
	SET  @PendingCollection = 0.0
	SET  @StockValue = 0.0
	SET  @PenCollBillCnt = 0
	TRUNCATE TABLE DashBoardHD
	TRUNCATE TABLE DashBoardBusinessPendingDT
	TRUNCATE TABLE  DashBoardSchemeDT
	TRUNCATE TABLE DashBoardInventoryDT
	/* Business Summary Details */
		/* YTD Sales Calculation */
		DECLARE @FDate DATETIME
		DECLARE @TDate DATETIME
		DECLARE @FrstYear INTEGER
		DECLARE @FrstMonth INTEGER
		SET @TDate = CONVERT(VARCHAR(10),GETDATE(),121)
		SET @FrstYear =  YEAR(GETDATE())
		SET @FDate =CAST(@FrstYear AS VARCHAR(5)) +  '-01-01'
----		SET @FDate = (SELECT TOP 1 JcmSdt FROM JCMast A,JCMonth B
----		WHERE A.JcmId = B.JcmId AND JcmYr = @FrstYear ORDER BY JcmSdt) 
		SELECT @YTDSales = ISNULL(SUM(SalGrossAmount),0) FROM SalesInvoice
		WHERE SalInvDate BETWEEN @FDate  AND @TDate  AND DlvSts <> 3 --AND YEAR(SalInvDate) = @FrstYear
		/* MTD Sales Calculation */
		DECLARE @MFDate DATETIME
		DECLARE @MTDate DATETIME
		DECLARE @MFrstYear INTEGER
		DECLARE @MFrstMonth INTEGER
		SET @MTDate = CONVERT(VARCHAR(10),GETDATE(),121)
		SET @MFrstYear  =YEAR(GETDATE())
		SET @MFrstMonth =MONTH(GETDATE())
		SET @MFDate = CAST(@MFrstYear AS VARCHAR(5)) +  '-' + Cast(@MFrstMonth AS VARCHAR(5)) + '-01'
		SELECT @MTDSales = Isnull(SUM(SalGrossAmount),0) FROM SalesInvoice
		WHERE SalInvDate BETWEEN @MFDate AND @MTDate AND DlvSts <> 3  --AND Month(SalInvDate) = @MFrstMonth
		INSERT INTO DashBoardHD (YTDSales,MTDSales,PendingCollBillCnt,PendingCollectionAmt,TotSchemesCntforMonth,TotSchemeBudget,
		TotSchemeUtilization,UtilPercenatge,TotSkuCnt,TotActiveSkuCnt,TotSkuCntWithStock,StockValue)
		SELECT @YTDSales,@MTDSales,0,0.00,0,0.00,0.00,0.00,0,0,0,0.00
		
		INSERT INTO DashBoardBusinessPendingDT (SMId,SMCode,SMName,BillsCnt,LinesCut,UndeliveredBillsCnt,
		CancellededBillsCnt,SalesValue,ReturnValue,YTD,MTD,PendingBillsCnt,PendingAmount)
		SELECT B.SMId,SMCode,SMName,COUNT(DISTINCT A.SalId) AS BillCnt,COUNT(DISTINCT PrdID) AS LinesCut,0,0,
		0,0.00,1,0,0,0.00
		FROM SalesInvoice A,SalesMan B,SalesInvoiceProduct C
		WHERE A.SmId = B.SmId AND SalInvDate BETWEEN @FDate AND @TDate AND DlvSts <> 3 AND A.SalId = C.SalId
		GROUP BY B.SMId,SMCode,SMName ORDER BY B.SmId
		UPDATE DashBoardBusinessPendingDT SET SalesValue=A.SalesValue FROM (
		SELECT B.SMId,ISNULL(SUM(SalGrossAmount),0) AS SalesValue
		FROM SalesInvoice A,SalesMan B
		WHERE A.SmId = B.SmId AND SalInvDate BETWEEN @FDate AND @TDate AND DlvSts <> 3 
		GROUP BY B.SMId) A WHERE DashBoardBusinessPendingDT.SMId=A.SMId AND DashBoardBusinessPendingDT.YTD=1
		INSERT INTO DashBoardBusinessPendingDT (SMId,SMCode,SMName,BillsCnt,LinesCut,UndeliveredBillsCnt,
		CancellededBillsCnt,SalesValue,ReturnValue,YTD,MTD,PendingBillsCnt,PendingAmount)
		SELECT B.SMId,SMCode,SMName,COUNT(DISTINCT A.SalId) AS BillCnt,COUNT(DISTINCT PrdID) AS LinesCut,0,0,
		0,0.00,0,1,0,0.00
		FROM SalesInvoice A,SalesMan B,SalesInvoiceProduct C
		WHERE A.SmId = B.SmId AND SalInvDate BETWEEN @MFDate AND @MTDate AND DlvSts <> 3 AND A.SalId = C.SalId
		GROUP BY B.SMId,SMCode,SMName ORDER BY B.SmId
		
		UPDATE DashBoardBusinessPendingDT SET SalesValue=A.SalesValue FROM (
		SELECT B.SMId,ISNULL(SUM(SalGrossAmount),0) AS SalesValue
		FROM SalesInvoice A,SalesMan B
		WHERE A.SmId = B.SmId AND SalInvDate BETWEEN @MFDate AND @MTDate AND DlvSts <> 3 
		GROUP BY B.SMId) A WHERE DashBoardBusinessPendingDT.SMId=A.SMId AND DashBoardBusinessPendingDT.MTD=1
		SELECT COUNT(SalId) AS UDBillsCnt,SmID INTO #TempYTDUDBills FROM SalesInvoice 
		WHERE SalInvDate BETWEEN @FDate AND @TDate AND DlvSts IN (1,2) GROUP BY SmId ORDER BY SmId
		SELECT COUNT(SalId) AS UDBillsCnt,SmID INTO #TempMTDUDBills FROM SalesInvoice 
		WHERE SalInvDate BETWEEN @MFDate AND @MTDate AND DlvSts IN (1,2) GROUP BY SmId ORDER BY SmId
		UPDATE DashBoardBusinessPendingDT SET UndeliveredBillsCnt = UDBillsCnt FROM DashBoardBusinessPendingDT A,
		#TempYTDUDBills B WHERE A.SmID = B.SmID AND YTD = 1
		UPDATE DashBoardBusinessPendingDT SET UndeliveredBillsCnt = UDBillsCnt FROM DashBoardBusinessPendingDT A,
		#TempMTDUDBills B WHERE A.SmID = B.SmID AND MTD = 1
		SELECT COUNT(SalId) AS CancelBillsCnt,SmID INTO #TempYTDCancelBills FROM SalesInvoice 
		WHERE SalInvDate BETWEEN @FDate AND @TDate AND DlvSts IN (3) GROUP BY SmId ORDER BY SmId
		SELECT COUNT(SalId) AS CancelBillsCnt,SmID INTO #TempMTDCancelBills FROM SalesInvoice 
		WHERE SalInvDate BETWEEN @MFDate AND @MTDate AND DlvSts IN (3) GROUP BY SmId ORDER BY SmId
		UPDATE DashBoardBusinessPendingDT SET CancellededBillsCnt = CancelBillsCnt FROM DashBoardBusinessPendingDT A,
		#TempYTDCancelBills B WHERE A.SmID = B.SmID AND YTD = 1
		UPDATE DashBoardBusinessPendingDT SET CancellededBillsCnt = CancelBillsCnt FROM DashBoardBusinessPendingDT A,
		#TempMTDCancelBills B WHERE A.SmID = B.SmID AND MTD = 1
		SELECT ISNULL(SUM(RtnGrossAmt),0) AS ReturnValue,SmId INTO #TempYTDReturn FROM ReturnHeader 
		WHERE ReturnDate BETWEEN @FDate AND @TDate GROUP BY SmId ORDER BY SmId
		SELECT ISNULL(SUM(RtnGrossAmt),0) AS ReturnValue,SmId INTO #TempMTDReturn FROM ReturnHeader 
		WHERE ReturnDate BETWEEN @MFDate AND @MTDate GROUP BY SmId ORDER BY SmId
		UPDATE DashBoardBusinessPendingDT SET ReturnValue = B.ReturnValue FROM DashBoardBusinessPendingDT A,
		#TempYTDReturn B WHERE A.SmID = B.SmID AND YTD = 1
		UPDATE DashBoardBusinessPendingDT SET ReturnValue = B.ReturnValue FROM DashBoardBusinessPendingDT A,
		#TempMTDReturn B WHERE A.SmID = B.SmID AND MTD = 1
	/* Pending Bills Details */
		SELECT @PenCollBillCnt = Count(*) FROM SalesInvoice WHERE DlvSts = 4
		SELECT @PendingCollection = Isnull(SUM(SalNetAmt - SalPayAmt),0) FROM SalesInvoice WHERE DlvSts IN (4,5)
--		INSERT INTO DashBoardHD (DashBoardNo,YTDSales,MTDSales,PendingCollBillCnt,PendingCollectionAmt,TotSchemesCntforMonth,TotSchemeBudget,
--		TotSchemeUtilization,UtilPercenatge,TotSkuCnt,TotActiveSkuCnt,TotSkuCntWithStock,StockValue)
--		SELECT 2,0.00,0.00,@PenCollBillCnt,@PendingCollection,0,0.00,0.00,0.00,0,0,0,0.00
		UPDATE DashBoardHD SET PendingCollBillCnt = @PenCollBillCnt,PendingCollectionAmt = @PendingCollection
		SELECT COUNT(SalId) AS PendingBillCnt,Isnull(SUM(SalNetAmt - SalPayAmt),0) AS PendingAmount,SmID 
		INTO #TempPending FROM SalesInvoice WHERE DlvSts IN (4) GROUP BY SmId ORDER BY SmId
		UPDATE DashBoardBusinessPendingDT SET PendingBillsCnt = PendingBillCnt--,PendingAmount = B.PendingAmount
		FROM DashBoardBusinessPendingDT A,#TempPending B WHERE A.SmID = B.SmID AND YTD = 1
		SELECT COUNT(SalId) AS PendingBillCnt,Isnull(SUM(SalNetAmt - SalPayAmt),0) AS PendingAmount,SmID 
		INTO #TempPendingAmt FROM SalesInvoice WHERE DlvSts IN (4,5) GROUP BY SmId ORDER BY SmId
		UPDATE DashBoardBusinessPendingDT SET PendingAmount = B.PendingAmount
		FROM DashBoardBusinessPendingDT A,#TempPendingAmt B WHERE A.SmID = B.SmID AND YTD = 1
	/* Scheme Utilization Details */
		SET @CurrDate = CONVERT(Varchar(10),GetDate(),121)
		SELECT @TotSchemesCntforMonth = Count(*) FROM SchemeMaster 
		WHERE @CurrDate BETWEEN SchValidFrom AND SchValidTill AND SchStatus = 1
		SELECT @TotSchemeBudget = ISNULL(SUM(Budget),0) FROM SchemeMaster 
		WHERE @CurrDate BETWEEN SchValidFrom AND SchValidTill AND SchStatus = 1
		SELECT @TotSchemeUtilization = ISNULL(dbo.Fn_ReturnBudgetUtilizedForDashBoard(@CurrDate),0)
		SET @UtilPercenatge = (SELECT CASE @TotSchemeBudget WHEN 0 THEN 0 ELSE ISNULL(((@TotSchemeUtilization / @TotSchemeBudget) * 100),0) END)
--		INSERT INTO DashBoardHD (DashBoardNo,YTDSales,MTDSales,PendingCollBillCnt,PendingCollectionAmt,TotSchemesCntforMonth,TotSchemeBudget,
--		TotSchemeUtilization,UtilPercenatge,TotSkuCnt,TotActiveSkuCnt,TotSkuCntWithStock,StockValue)
--		SELECT 3,0.00,0.00,0,0.00,@TotSchemesCntforMonth,@TotSchemeBudget,@TotSchemeUtilization,@UtilPercenatge,0,0,0,0.00
		UPDATE DashBoardHD SET TotSchemesCntforMonth = @TotSchemesCntforMonth,TotSchemeBudget = @TotSchemeBudget,
		TotSchemeUtilization = @TotSchemeUtilization,UtilPercenatge = @UtilPercenatge
		INSERT INTO DashBoardSchemeDT (SchId,SchCode,SchDsc,Budget,Utilization,Balance,UtilPercenatgeDT)
		SELECT SchId,SchCode,SchDsc,Budget,0.00,0.00,0.00 FROM SchemeMaster 
		WHERE @CurrDate BETWEEN SchValidFrom AND SchValidTill AND SchStatus = 1
		DECLARE Cur_SchId Cursor For
		SELECT DISTINCT SchID,Budget FROM DashBoardSchemeDT ORDER By SchId
		OPEN Cur_SchId	
		FETCH NEXT FROM Cur_SchId INTO @SchId,@Budget
		WHILE @@FETCH_STATUS =0
		BEGIN
			SET @Utilization = 0.00
			SELECT @Utilization = ISNULL(dbo.Fn_ReturnBudgetUtilized(@SchId),0)
			SELECT @Balance = ISNULL((@Budget - @Utilization),0) 
			SET @UtilPercenatgeDT = (SELECT CASE @Budget WHEN 0 THEN 0 ELSE ISNULL(((@Utilization / @Budget) * 100),0) END)
			
			UPDATE DashBoardSchemeDT SET Utilization = @Utilization,Balance = @Balance,UtilPercenatgeDT = @UtilPercenatgeDT
			WHERE SchId = @SchId
			FETCH NEXT FROM Cur_SchId INTO @SchId,@Budget
		END
		CLOSE Cur_SchId
		DEALLOCATE Cur_SchId
	/*  Inventory Details */
	
		SELECT @TotSkuCnt = COUNT(*) FROM Product
		SELECT @TotActiveSkuCnt = COUNT(*) FROM Product WHERE PrdStatus = 1
		SELECT @TotSkuCntWithStock= COUNT(DISTINCT A.PrdId) FROM Product A (NOLOCK) INNER JOIN
		(SELECT (SUM(PrdBatLcnSih)+SUM(PrdBatLcnUih)+SUM(PrdBatLcnFre))-
		(SUM(PrdBatLcnRessih)+SUM(PrdBatLcnResUih)+SUM(PrdBatLcnResFre)) AS Stock,PrdId FROM 
			ProductBatchLocation (NOLOCK) GROUP BY PrdId HAVING (SUM(PrdBatLcnSih)+SUM(PrdBatLcnUih)+SUM(PrdBatLcnFre))-
			(SUM(PrdBatLcnRessih)+SUM(PrdBatLcnResUih)+SUM(PrdBatLcnResFre))>0) B ON A.PrdId = B.PrdId
		WHERE A.PrdStatus = 1
		
		--Stock Details
		SELECT A.PrdId,A.PrdBatId,A.LcnId,A.TransDate,SUM(SalClsStock) AS SalClsStock 
		INTO #TmpStockValue FROM StockLedger A (NOLOCK) 
		INNER JOIN (SELECT PrdId,PrdBatId,LcnId,MAX(TransDate) AS TransDate FROM StockLedger (NOLOCK) GROUP BY PrdId,PrdBatId,LcnId)B
		ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId AND A.LcnId = B.LcnId AND A.TransDate = B.TransDate
		GROUP BY A.PrdId,A.PrdBatId,A.LcnId,A.TransDate
		
		--Product Batch Price Details
		SELECT DISTINCT A.PrdId,A.PrdBatId,C.MRP,C.PurRate,C.SelRate INTO #ProductBatchDetails FROM ProductBatch A (NOLOCK)
		INNER JOIN (SELECT DISTINCT PrdBatId,MAX(PriceId) AS PriceId FROM ProductBatchDetails (NOLOCK) GROUP BY PrdBatId)B ON A.PrdBatId = B.PrdBatId 
		INNER JOIN (
		SELECT DISTINCT PrdBatId,PriceId,SUM(MRP) AS MRP,SUM(PurRate) AS PurRate,SUM(SelRate) AS SelRate FROM(
		SELECT DISTINCT PrdBatId,PriceId,PrdBatDetailValue AS MRP,0 AS PurRate,0 AS SelRate FROM ProductBatchDetails B (NOLOCK) WHERE SLNo = 1 UNION
		SELECT DISTINCT PrdBatId,PriceId,0 AS MRP,PrdBatDetailValue AS PurRate,0 AS SelRate FROM ProductBatchDetails B (NOLOCK) WHERE SLNo = 2 UNION
		SELECT DISTINCT PrdBatId,PriceId,0 AS MRP,0 AS PurRate,PrdBatDetailValue AS SelRate FROM ProductBatchDetails B (NOLOCK) WHERE SLNo = 3)Qry
		GROUP BY PrdBatId,PriceId) C ON A.PrdBatId = C.PrdBatId AND B.PrdBatId = C.PrdBatId AND B.PriceId = C.PriceId
		ORDER BY A.PrdId,A.PrdBatId
		--Till Here
		 
		SELECT @StockValue = ISNULL(SUM(StockValue),0) FROM (
		SELECT A.PrdId,A.PrdBatId,(SUM(SalClsStock)*SelRate) AS StockValue FROM #TmpStockValue A 
		INNER JOIN #ProductBatchDetails B ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId GROUP BY A.PrdId,A.PrdBatId,SelRate)Qry
		
		UPDATE DashBoardHD SET TotSkuCnt = @TotSkuCnt,TotActiveSkuCnt = @TotActiveSkuCnt,
		TotSkuCntWithStock = @TotSkuCntWithStock,StockValue = @StockValue		
			
		INSERT INTO DashBoardInventoryDT(StockValueSelRte,StockValuePurRte,StockValueMRP)
		SELECT DISTINCT SUM(StockValueSelRte) AS StockValueSelRte,SUM(StockValuePurRte) AS StockValuePurRte,SUM(StockValueMRP) AS StockValueMRP
		FROM (SELECT DISTINCT A.PrdId,A.PrdBatId,ISNULL((SUM(SalClsStock)*SelRate),0) StockValueSelRte,
		ISNULL((SUM(SalClsStock)*PurRate),0) StockValuePurRte,ISNULL((SUM(SalClsStock)*MRP),0) StockValueMRP FROM #TmpStockValue A 
		INNER JOIN #ProductBatchDetails B (NOLOCK) ON A.PrdId = B.PrdId GROUP BY A.PrdId,A.PrdBatId,SelRate,PurRate,MRP)Qry	
END
GO
--Tax Settings Cash Discounts Column Value Change to None
DECLARE @ColId AS BIGINT
SELECT @ColId = SlNo FROM BillSequenceDetail (NOLOCK) WHERE FieldDesc = 'CD Disc'
IF EXISTS (SELECT DISTINCT TaxSeqId FROM TaxSettingDetail (NOLOCK))
BEGIN
	UPDATE A SET ColVal = 0 FROM TaxSettingDetail A (NOLOCK) 
	INNER JOIN (SELECT DISTINCT TaxSeqId FROM TaxSettingMaster A (NOLOCK)
	INNER JOIN TaxGroupSetting B (NOLOCK) ON A.RtrId = B.TaxGroupId
	WHERE B.TaxGroup = 1)B ON A.TaxSeqId = B.TaxSeqId WHERE A.ColId = @ColId AND A.ColType <> 1
END
GO
DELETE FROM Configuration Where ModuleId = 'GENCONFIG21'
INSERT INTO Configuration 
SELECT 'GENCONFIG21','General Configuration','Display MRP in Product Hot Search Screen',1,'Billing',0.00,21
GO
DELETE FROM Configuration where moduleid in('BILLRTEDIT2','BILLRTEDIT30','BILLRTEDIT31','BILLRTEDIT5','BILLRTEDIT16','BILLRTEDIT14',
'BILLRTEDIT32','BILLRTEDIT17','BILLRTEDIT15')
INSERT INTO Configuration 
SELECT 'BILLRTEDIT2','BillConfig_RateEdit','Allow Editing of Net Rate in the billing screen',1,'',0.00,21UNION
SELECT 'BILLRTEDIT5','BillConfig_RateEdit','Allow both addition and reduction',0,'',0.00,3 UNION
SELECT 'BILLRTEDIT14','BillConfig_RateEdit','Allow the user to reduce the amount of Net Rate',1,'',0.00,1UNION
SELECT 'BILLRTEDIT15','BillConfig_RateEdit','Allow the user to add the amount of Net Rate',0,'',0.00,2 UNION
SELECT 'BILLRTEDIT16','BillConfig_RateEdit','Allow both addition and reduction',1,'',0.00,3 UNION
SELECT 'BILLRTEDIT17','BillConfig_RateEdit','Make reason as mandatory if the user is reducing the rate',0,'',0.00,1 UNION
SELECT 'BILLRTEDIT30','BillConfig_RateEdit','Recalculate Selling rate based on edited Net Rate',0,'',0.00,30 UNION
SELECT 'BILLRTEDIT31','BillConfig_RateEdit','Recalculate Selling rate based on edited Net Rate',1,'',0.00,31 UNION
SELECT 'BILLRTEDIT32','BillConfig_RateEdit','Recalculate Tax Alone based on edited Net Rate',1,'',0.00,32
GO
DELETE FROM HOTSEARCHEDITORHD WHERE FORMID IN(53,54,55,56,57,58,70,111,135,138,193,196,325,326,327,328,329,330,331,332,333,
679,683,684,748,749,750,751,752,753,754,755,756,757,758,759,760,761,762,763,764,765,766,767,768,769,770,771,782,791,792,793,
794,796,797,798,799,800,801,802,803,805,806,807,808,809,810,811,818,10077,10078,10079,10080,10090)
INSERT INTO HOTSEARCHEDITORHD
SELECT  53,'Batch Transfer','FromBatchSaleable','select','SELECT PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,StockAvailable,DefaultPriceId  FROM (SELECT PB.PrdBatId,PrdBatCode,PD1.PrdBatDetailValue AS MRP,  PD2.PrdBatDetailValue AS PurchaseRate,PD3.PrdBatDetailValue AS SellingRate ,  ISNULL(PBL.PrdBatLcnSih,0) - ISNULL(PBL.PrdBatLcnRessih,0) AS StockAvailable,PB.DefaultPriceId     FROM ProductBatch PB,ProductBatchLocation PBL (NOLOCK)  ,  ProductbatchDetails PD1 WITH (NOLOCK),  BatchCreation BC1 WITH (NOLOCK),  ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),    ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)  WHERE PB.PrdBatId = PBL.PrdBatId   AND PBL.LcnId = vFParam   AND PBL.PrdId = vSParam  AND PB.Status = 1 AND PB.PrdBatId=PD1.PrdBatId   AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1    AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1  AND PD2.SlNo =BC2.SlNo    AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId    AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId    AND BC3.SelRte=1  UNION ALL  SELECT PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP,    PD2.PrdBatDetailValue AS PurchaseRate,  PD3.PrdBatDetailValue AS SellingRate,   0  AS [StockAvailable],  PB.DefaultPriceId  FROM ProductBatch PB,   ProductbatchDetails PD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),    ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),    ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)    WHERE PB.PrdBatId NOT IN (SELECT PrdBatId   FROM ProductBatchLocation    WHERE LcnId = vFParam and PrdId = vSParam) AND PrdId = vSParam  and Status = 1   AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo  AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1    AND PD2.SlNo =BC2.SlNo  AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1    AND PB.PrdBatId=PD3.PrdBatId  AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo   AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1) MainSql' UNION
SELECT  54,'Batch Transfer','FromBatchUnSaleable','select','SELECT PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,StockAvailable,DefaultPriceId FROM (SELECT   PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP,  PD2.PrdBatDetailValue AS PurchaseRate,    PD3.PrdBatDetailValue AS SellingRate,    (ISNULL(PBL.PrdBatLcnUih,0) - ISNULL(PBL.PrdBatLcnResUih,0) ) AS [StockAvailable] ,  PB.DefaultPriceId     FROM ProductBatch PB,ProductBatchLocation PBL (NOLOCK)  ,    ProductbatchDetails PD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),    ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),    ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)    WHERE PB.PrdBatId = PBL.PrdBatId AND PBL.LcnId = vFParam   AND PBL.PrdId = vSParam    AND PB.Status = 1 AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo   AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1    AND PD2.SlNo =BC2.SlNo  AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId    AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId  AND BC3.SelRte=1    UNION ALL    SELECT PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP,  PD2.PrdBatDetailValue AS PurchaseRate,    PD3.PrdBatDetailValue AS SellingRate,  0  AS [StockAvailable],  PB.DefaultPriceId  FROM ProductBatch PB,    ProductbatchDetails PD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),  ProductbatchDetails PD2 WITH (NOLOCK),  BatchCreation BC2 WITH (NOLOCK),  ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)    WHERE PB.PrdBatId NOT IN (SELECT PrdBatId   FROM ProductBatchLocation  WHERE LcnId = vFParam and PrdId = vSParam)   AND PrdId = vSParam  and Status = 1 AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo   AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1    AND PD2.SlNo =BC2.SlNo  AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId    AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1) MainSql'UNION
SELECT  55,'Batch Transfer','FromBatchFree','select','SELECT PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,StockAvailable,DefaultPriceId FROM (SELECT PB.PrdBatId,  PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP, PD2.PrdBatDetailValue AS PurchaseRate,    PD3.PrdBatDetailValue AS SellingRate,    (ISNULL(PBL.PrdBatLcnFre,0) - ISNULL(PBL.PrdBatLcnResFre,0)) AS [StockAvailable],PB.DefaultPriceId FROM ProductBatch PB,  ProductBatchLocation PBL (NOLOCK)  ,  ProductbatchDetails PD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),    ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),  ProductbatchDetails PD3 WITH (NOLOCK),  BatchCreation BC3 WITH (NOLOCK)  WHERE PB.PrdBatId = PBL.PrdBatId AND PBL.LcnId = vFParam     AND PBL.PrdId = vSParam   AND PB.Status = 1 AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1    AND PD1.SlNo =BC1.SlNo AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId   AND PD2.DefaultPrice=1  AND PD2.SlNo =BC2.SlNo AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1    AND PB.PrdBatId=PD3.PrdBatId AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId   AND BC3.SelRte=1    UNION ALL       SELECT PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP,   PD2.PrdBatDetailValue AS PurchaseRate,  PD3.PrdBatDetailValue AS SellingRate, 0  AS [StockAvailable],  PB.DefaultPriceId  FROM ProductBatch PB,  ProductbatchDetails PD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),    ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),  ProductbatchDetails PD3 WITH (NOLOCK),  BatchCreation BC3 WITH (NOLOCK)     WHERE PB.PrdBatId NOT IN (SELECT PrdBatId   FROM ProductBatchLocation     WHERE LcnId = vFParam and PrdId = vSParam) AND PrdId = vSParam     and Status = 1 AND PB.PrdBatId=PD1.PrdBatId   AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1    AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1  AND PD2.SlNo =BC2.SlNo AND BC2.BatchSeqId=PB.BatchSeqId   AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo   AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1) MainSql'UNION
SELECT  56,'Batch Transfer','ToBatchSaleable','select','SELECT PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,StockAvailable,DefaultPriceId FROM (SELECT PB.PrdBatId,PB.PrdBatCode,  PD1.PrdBatDetailValue AS MRP, PD2.PrdBatDetailValue AS PurchaseRate,PD3.PrdBatDetailValue AS SellingRate,      (ISNULL(PBL.PrdBatLcnSih,0) - ISNULL(PBL.PrdBatLcnRessih,0) )AS [StockAvailable] ,  PB.DefaultPriceId      FROM ProductBatch PB,ProductBatchLocation PBL (NOLOCK),ProductbatchDetails PD1 WITH (NOLOCK),  BatchCreation BC1  WITH (NOLOCK),    ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),  ProductbatchDetails PD3  WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)    WHERE PB.PrdBatId = PBL.PrdBatId   AND PBL.LcnId = vFParam  AND PBL.PrdId = vSParam     AND PBL.PrdBatId <> vTParam AND PB.Status = 1     AND PB.PrdBatId=PD1.PrdBatId    AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo AND BC1.BatchSeqId=PB.BatchSeqId   AND BC1.MRP=1    AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1  AND PD2.SlNo =BC2.SlNo   AND BC2.BatchSeqId=PB.BatchSeqId    AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId AND PD3.DefaultPrice=1    AND PD3.SlNo =BC3.SlNo  AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1    UNION ALL   SELECT PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP, PD2.PrdBatDetailValue AS PurchaseRate,  PD3.PrdBatDetailValue AS SellingRate,  0  as [StockAvailable],PB.DefaultPriceId  FROM ProductBatch PB,ProductbatchDetails PD1 WITH (NOLOCK),    BatchCreation BC1 WITH (NOLOCK),ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),ProductbatchDetails PD3 WITH (NOLOCK),  BatchCreation BC3 WITH (NOLOCK) WHERE PB.PrdBatId  NOT IN   (SELECT PrdBatId FROM ProductBAtchLocation   WHERE LcnId = vFParam AND PrdId = vSParam)    AND PrdId = vSParam AND Status = 1  AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1    AND PD1.SlNo =BC1.SlNo    AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1      AND PD2.SlNo =BC2.SlNo AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId      AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1) MainSql'UNION
SELECT  57,'Batch Transfer','ToBatchUnSaleable','select','SELECT PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,StockAvailable,DefaultPriceId FROM (SELECT PB.PrdBatId,  PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP, PD2.PrdBatDetailValue AS PurchaseRate,    PD3.PrdBatDetailValue AS SellingRate,    (ISNULL(PBL.PrdBatLcnUih,0) - ISNULL(PBL.PrdBatLcnResUih,0) ) AS [StockAvailable] ,  PB.DefaultPriceId       FROM ProductBatch PB,ProductBatchLocation PBL (NOLOCK),  ProductbatchDetails PD1 WITH (NOLOCK),  BatchCreation BC1 WITH (NOLOCK),  ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),    ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)  WHERE PB.PrdBatId = PBL.PrdBatId   AND PBL.LcnId = vFParam   AND PBL.PrdId = vSParam   AND PBL.PrdBatId <> vTParam AND PB.Status = 1     AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo AND BC1.BatchSeqId=PB.BatchSeqId   AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1  AND PD2.SlNo =BC2.SlNo   AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId AND PD3.DefaultPrice=1    AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1  UNION ALL SELECT PB.PrdBatId,  PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP, PD2.PrdBatDetailValue AS PurchaseRate,    PD3.PrdBatDetailValue AS SellingRate, 0  as [StockAvailable],PB.DefaultPriceId  FROM ProductBatch PB   ,    ProductbatchDetails PD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),  ProductbatchDetails PD2 WITH (NOLOCK),  BatchCreation BC2 WITH (NOLOCK),  ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)    WHERE PB.PrdBatId NOT IN   (SELECT PrdBatId FROM ProductBAtchLocation WHERE LcnId = vFParam AND PrdId = vSParam)     AND PrdId = vSParam AND Status = 1  AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo   AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1    AND PD2.SlNo =BC2.SlNo AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId   AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1) MainSql'UNION
SELECT  58,'Batch Transfer','ToBatchFree','select','SELECT PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,StockAvailable,DefaultPriceId FROM (SELECT PB.PrdBatId,  PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP, PD2.PrdBatDetailValue AS PurchaseRate,    PD3.PrdBatDetailValue AS SellingRate,(ISNULL(PBL.PrdBatLcnFre,0) - ISNULL(PBL.PrdBatLcnResFre,0) ) AS [StockAvailable] ,   PB.DefaultPriceId     FROM ProductBatch PB,ProductBatchLocation PBL (NOLOCK),  ProductbatchDetails PD1 WITH (NOLOCK),  BatchCreation BC1 WITH (NOLOCK),  ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),    ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)  WHERE PB.PrdBatId = PBL.PrdBatId   AND PBL.LcnId = vFParam   AND PBL.PrdId = vSParam   AND PBL.PrdBatId <> vTParam AND PB.Status = 1     AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo AND BC1.BatchSeqId=PB.BatchSeqId   AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1  AND PD2.SlNo =BC2.SlNo   AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId AND PD3.DefaultPrice=1    AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1  UNION ALL SELECT PB.PrdBatId,PB.PrdBatCode,  PD1.PrdBatDetailValue AS MRP, PD2.PrdBatDetailValue AS PurchaseRate,  PD3.PrdBatDetailValue AS SellingRate,  0 as [StockAvailable],PB.DefaultPriceId    FROM ProductBatch PB   ,  ProductbatchDetails PD1 WITH (NOLOCK),  BatchCreation BC1 WITH (NOLOCK),  ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),    ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)  WHERE PB.PrdBatId NOT IN   (SELECT PrdBatId FROM ProductBAtchLocation WHERE LcnId = vFParam AND PrdId = vSParam)   AND PrdId = vSParam   AND Status = 1  AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo   AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1    AND PD2.SlNo =BC2.SlNo AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId   AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1) MainSql'UNION
SELECT  70,'Location Transfer','PrdBatCode','select','SELECT ExpDate,PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,PrdName,MnfDate    FROM (SELECT PB.ExpDate,PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP,    PD2.PrdBatDetailValue AS PurchaseRate, PD3.PrdBatDetailValue AS SellingRate,    B.PrdName,PB.MnfDate  FROM ProductBatch PB,Product B ,    ProductbatchDetails PD1 WITH (NOLOCK),  BatchCreation BC1 WITH (NOLOCK),    ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),    ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)    WHERE PB.PrdId=B.PrdId  AND PB.Status=1 AND PB.PrdId= vFParam AND PD1.PrdBatDetailValue=vTParam AND PB.PrdbatId IN     (SELECT PrdBatId  FROM ProductBatchLocation WITH(NOLOCK)    WHERE   ((ISNULL(PrdBatLcnSih,0)-ISNULL(PrdBatLcnResSih,0)) + (ISNULL(PrdBatLcnUih,0)-ISNULL(PrdBatLcnResUih,0))    +(ISNULL(PrdBatLcnFre,0)-ISNULL(PrdBatLcnResFre,0)) ) > 0  AND LcnId = vSParam)    AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo   AND BC1.BatchSeqId=PB.BatchSeqId  AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId   AND PD2.DefaultPrice=1  AND PD2.SlNo =BC2.SlNo  AND BC2.BatchSeqId=PB.BatchSeqId   AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId AND PD3.DefaultPrice=1    AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1)   MainSql'UNION
SELECT  111,'Stock Management','Batch','select','SELECT PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,ExpDate,PrdName,MnfDate    FROM (SELECT PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP, PD2.PrdBatDetailValue AS PurchaseRate,    PD3.PrdBatDetailValue AS SellingRate,PB.ExpDate,B.PrdName,PB.MnfDate FROM ProductBatch PB WITH (NOLOCK),    Product B WITH (NOLOCK) ,  ProductbatchDetails PD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),    ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),  ProductbatchDetails PD3 WITH (NOLOCK),    BatchCreation BC3 WITH (NOLOCK)  WHERE B.PrdStatus = 1 AND PB.Status = 1     AND PB.PrdId=B.PrdId  AND PB.PrdId= vFParam AND  PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1    AND PD1.SlNo =BC1.SlNo  AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId   AND PD2.DefaultPrice=1  AND PD2.SlNo =BC2.SlNo AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1    AND PB.PrdBatId=PD3.PrdBatId  AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId   AND BC3.SelRte=1 AND PD1.PrdBatDetailValue=vSParam) MainSql  ORDER BY PrdBatId ASC'UNION
SELECT  135,'Return to Company','BatchNo','select','SELECT ExpDate,PrdBatId,CAST(MRP AS NUMERIC(18,2))MRP,SellingRate,PrdBatCode,PurchaseRate,  PrdName,MnfDate FROM  (SELECT PB.ExpDate,PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP,   PD2.PrdBatDetailValue AS PurchaseRate,  PD3.PrdBatDetailValue AS SellingRate,B.PrdName,PB.MnfDate   FROM ProductBatch PB WITH (NOLOCK),Product B WITH (NOLOCK),  ProductbatchDetails PD1 WITH (NOLOCK),  BatchCreation BC1 WITH (NOLOCK),  ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),    ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)    WHERE PB.PrdId=B.PrdId AND PB.PrdId=vFParam     AND PB.PrdBatId IN (SELECT PrdBatId FROM ProductBatchLocation WITH (NOLOCK)    WHERE PrdId =vFParam AND LcnId=vSParam AND (PrdBatLcnUih - PrdBatLcnResUih) > 0)   AND PB.Status=1 AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo   AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1    AND PD2.SlNo =BC2.SlNo AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1    AND PB.PrdBatId=PD3.PrdBatId AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo   AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1 AND PD1.PrdBatDetailValue=vTParam) MainSql'UNION
SELECT  138,'Stock Journal','PrdBatch','select','SELECT PrdId,PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,    PurchaseRate,SellingRate,DefaultPriceId FROM     (SELECT PB.PrdId, PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP,      PD2.PrdBatDetailValue AS PurchaseRate,  PD3.PrdBatDetailValue AS SellingRate,PB.DefaultPriceId      FROM Product P,ProductBatch PB (NOLOCK),  ProductbatchDetails PD1 WITH (NOLOCK),      BatchCreation BC1 WITH (NOLOCK),  ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),      ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)      WHERE P.prdId=PB.PrdId AND PB.PrdId=vFParam AND PB.Status=1    AND PB.PrdBatId=PD1.PrdBatId   AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo    AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1    AND PB.PrdBatId=PD2.PrdBatId    AND PD2.DefaultPrice=1  AND PD2.SlNo =BC2.SlNo AND BC2.BatchSeqId=PB.BatchSeqId      AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId AND PD3.DefaultPrice=1      AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1   AND PD1.PrdBatDetailValue=vSParam) MainSql'UNION
SELECT  193,'Market Return','Batch No','SELECT','SELECT PrdBatId,PrdbatCode,StockType,BaseQty,PreRtnQty,CAST(PrdUnitMRP AS NUMERIC(18,2))PrdUnitMRP ,PrdUnitSelRate,PurchaseRate,  PrdUom1EditedSelRate,PrdGrossAmount,PrdGrossAmountAftEdit,PrdNetRateDiffAmount,PriceId,SplPriceId FROM   (SELECT DISTINCT P.PrdBatId,P.PrdbatCode,''Saleable'' AS StockType,  (S.BaseQty - ISNULL(S.ReturnedQty,0)) AS BaseQty,  ISNULL(S.ReturnedQty,0) AS PreRtnQty,  S.PrdUnitMRP AS PrdUnitMRP,S.PrdUnitSelRate AS PrdUnitSelRate, F.PrdBatDetailValue AS PurchaseRate,  CAST(S.PrdUom1EditedSelRate/Uom1ConvFact AS NUMERIC(18,6)) AS PrdUom1EditedSelRate,S.PrdGrossAmount,  S.PrdGrossAmountAftEdit,(S.PrdRateDiffAmount/S.BaseQty) AS PrdNetRateDiffAmount,S.PriceId,S.SplPriceId   FROM SalesInvoiceProduct S (NOLOCK),ProductBatch P (NOLOCK)  INNER JOIN ProductBatchDetails F (NOLOCK) ON P.PrdBatId = F.PrdBatID AND F.DefaultPrice=1    INNER JOIN BatchCreation G (NOLOCK) ON G.BatchSeqId = P.BatchSeqId AND F.SlNo = G.SlNo  AND  G.ListPrice = 1   WHERE P.Status=1 AND P.PrdBatId =S.PrdBatId   AND   (S.BaseQty - ISNULL(S.ReturnedQty,0)) > 0 AND S.SalId = vFParam AND  S.PrdId=vSParam      AND S.Slno = vTParam    UNION ALL   SELECT DISTINCT  P.PrdBatId, P.PrdbatCode,''Offer'' AS  StockType,    (S.SalManFreeQty - isnull(S.ReturnedManFreeQty,0)) AS BaseQty,  ISNULL(S.ReturnedManFreeQty,0) AS PreRtnQty,  S.PrdUnitMRP AS PrdUnitMRP,S.PrdUnitSelRate  AS PrdUnitSelRate, F.PrdBatDetailValue AS PurchaseRate,   CAST(S.PrdUom1EditedSelRate/Uom1ConvFact AS NUMERIC(18,6)) AS PrdUom1EditedSelRate,S.PrdGrossAmount,S.PrdGrossAmountAftEdit,  S.PrdRateDiffAmount AS PrdNetRateDiffAmount,S.PriceId,0  AS SplPriceId   FROM SalesInvoiceProduct S (NOLOCK),ProductBatch P (NOLOCK)  INNER JOIN ProductBatchDetails F (NOLOCK) ON P.PrdBatId = F.PrdBatID AND F.DefaultPrice=1    INNER JOIN BatchCreation G (NOLOCK) ON G.BatchSeqId = P.BatchSeqId AND F.SlNo = G.SlNo  AND  G.ListPrice = 1   WHERE P.Status=1  AND P.PrdBatId =S.PrdBatId AND  S.SalId = vFParam AND S.PrdId=vSParam  AND S.SalManFreeQty > 0 AND S.Slno = vTParam) AS A 'UNION
SELECT  196,'Market Return','Batch No','select','SELECT PrdBatID,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,SellRate,PurchaseRate,PriceId,SplPriceId FROM      (SELECT A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue as MRP,D.PrdBatDetailValue as SellRate,A.DefaultPriceId as PriceId,  F.PrdBatDetailValue AS PurchaseRate,  0 as SplPriceId     from ProductBatch A (NOLOCK)     INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID       AND B.DefaultPrice=1   INNER JOIN BatchCreation C (NOLOCK)   ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo   AND  C.MRP = 1       INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID    AND D.DefaultPrice=1    INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId   AND D.SlNo = E.SlNo   AND  E.SelRte = 1   INNER JOIN ProductBatchDetails F (NOLOCK) ON A.PrdBatId = F.PrdBatID AND F.DefaultPrice=1    INNER JOIN BatchCreation G (NOLOCK) ON G.BatchSeqId = A.BatchSeqId AND F.SlNo = G.SlNo  AND  G.ListPrice = 1  WHERE A.PrdId=vFParam AND B.PrdBatDetailValue=vSParam) MainSql'UNION
SELECT  325,'Resell Damage Goods','Batch','select','SELECT PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,  PrdBatDetailValue,ExpDate,PriceId    FROM (SELECT PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP,    PD2.PrdBatDetailValue AS PurchaseRate,PD3.PrdBatDetailValue,    PB.ExpDate,PD1.PriceId  FROM ProductBatch PB WITH (NOLOCK) ,    ProductbatchDetails PD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),    ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),    ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK),    ProductBatchLocation PBL WITH (NOLOCK)    WHERE  PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1    AND  PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1 AND    PB.PrdBatId=PD3.PrdBatId  AND PD3.DefaultPrice=1    AND PB.PrdId=vFParam AND PB.Status=1    AND PD1.SlNo =BC1.SlNo    AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.Mrp=1   AND PD2.SlNo =BC2.SlNo    AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1   AND PD3.SlNo =BC3.SlNo    AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1   AND PBL.LcnId =vSParam    AND PBL.PrdId = PB.PrdId AND PBL.PrdBatId = PB.PrdBatId AND PD1.PrdBatDetailValue = vTParam  AND ((PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih))>0) MainQry'UNION
SELECT  326,'Order Booking','Batch','SELECT','SELECT PrdBatID,MnfDate,PrdBatCode,ExpDate,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,    SellRate,DefaultPriceId FROM (SELECT A.PrdBatID,A.MnfDate,A.PrdBatCode,A.ExpDate,    B.PrdBatDetailValue as MRP,D.PrdBatDetailValue AS PurchaseRate,F.PrdBatDetailValue AS SellRate,    A.DefaultPriceId FROM ProductBatch A (NOLOCK) INNER JOIN ProductBatchDetails B (NOLOCK)    ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 INNER JOIN BatchCreation C (NOLOCK)    ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1    INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID    AND D.DefaultPrice=1 INNER JOIN BatchCreation E (NOLOCK)    ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1    INNER JOIN ProductBatchDetails F (NOLOCK) ON A.PrdBatId = F.PrdBatID    AND F.DefaultPrice=1 INNER JOIN BatchCreation H (NOLOCK)    ON H.BatchSeqId = A.BatchSeqId AND F.SlNo = H.SlNo AND H.SelRte = 1    INNER JOIN Product G (NOLOCK) ON G.Prdid = A.PrdId    WHERE A.Status = 1 AND A.PrdId=vFParam AND  B.PrdBatDetailValue=vSParam) MainQry    ORDER BY PrdBatId ASC'UNION
SELECT  327,'Purchase Receipt','Batch','SELECT','SELECT PrdBatID,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,PriceId   FROM (SELECT A.PrdBatID,A.PrdBatCode,  B.PrdBatDetailValue AS MRP,  D.PrdBatDetailValue AS PurchaseRate, F.PrdBatDetailValue AS SellingRate,  B.PriceId  FROM  ProductBatch A (NOLOCK)   INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID    AND B.DefaultPrice=1  INNER JOIN BatchCreation C (NOLOCK)   ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo  AND C.MRP = 1    INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID    AND D.DefaultPrice=1  INNER JOIN BatchCreation E (NOLOCK)   ON E.BatchSeqId = A.BatchSeqId  AND D.SlNo = E.SlNo   AND E.ListPrice = 1    INNER JOIN ProductBatchDetails F (NOLOCK) ON A.PrdBatId = F.PrdBatID    AND F.DefaultPrice=1   INNER JOIN BatchCreation G (NOLOCK)   ON G.BatchSeqId = A.BatchSeqId  AND F.SlNo = G.SlNo AND G.SelRte = 1    WHERE  A.PrdId=vFParam  AND A.Status = 1 AND B.PrdBatDetailValue=vSParam)  MainQry ORDER BY PrdBatId ASC'UNION
SELECT  328,'Purchase Return','Batch','SELECT','SELECT PrdBatID,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,PriceId FROM    (SELECT A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP,D.PrdBatDetailValue AS PurchaseRate,  F.PrdBatDetailValue AS SellingRate,B.PriceId   FROM  ProductBatch A (NOLOCK)   INNER JOIN  ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1    INNER JOIN BatchCreation C (NOLOCK)  ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo  AND C.MRP = 1      INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1     INNER JOIN BatchCreation E (NOLOCK)  ON E.BatchSeqId = A.BatchSeqId  AND D.SlNo = E.SlNo AND E.SelRte = 1      INNER JOIN ProductBatchDetails F (NOLOCK) ON A.PrdBatId = F.PrdBatID    AND F.DefaultPrice=1     INNER JOIN BatchCreation G (NOLOCK) ON G.BatchSeqId = A.BatchSeqId AND F.SlNo = G.SlNo AND G.ListPrice = 1      WHERE  A.PrdId=vFParam AND A.Status = 1 AND B.PrdBatDetailValue=vSParam  AND A.PrdBatId IN (SELECT PrdBatId FROM ProductBatchLocation WHERE LcnId=vTParam AND PrdId=vFParam AND      ((PrdBatLcnSih+PrdBatLcnUih)-(PrdBatLcnRessih+PrdBatLcnResUih))>0)  ) MainQry ORDER BY PrdBatId ASC'UNION
SELECT  329,'Return And Replacement','Return Batch','select','SELECT PrdBatId,CAST(MRP AS NUMERIC(18,2))MRP,PrdBatCode,SellingRate,    PurchaseRate,DefaultPriceId  FROM   (SELECT PB.PrdBatId,PB.PrdBatCode,PBD1.PrdBatDetailValue AS MRP,  PBD2.PrdBatDetailValue AS PurchaseRate,    PBD3.PrdBatDetailValue AS SellingRate,PB.DefaultPriceId    FROM ProductBatch PB WITH (NOLOCK),    ProductBatchDetails PBD1 WITH (NOLOCK),    BatchCreation BC1 WITH (NOLOCK)   ,   ProductBatchDetails PBD2 WITH (NOLOCK),    BatchCreation BC2 WITH (NOLOCK)   ,   ProductBatchDetails PBD3 WITH (NOLOCK),    BatchCreation BC3 WITH (NOLOCK)    Where PB.PrdBatId = PBD1.PrdBatId   And BC1.BatchSeqId = PB.BatchSeqId  AND PBD1.SlNo=BC1.SlNo AND BC1.MRP=1    AND PBD1.DefaultPrice=1  AND  PB.PrdBatId = PBD2.PrdBatId And BC2.BatchSeqId = PB.BatchSeqId    AND PBD2.SlNo=BC2.SlNo  AND BC2.ListPrice=1 AND PBD2.DefaultPrice=1    AND  PB.PrdBatId = PBD3.PrdBatId And BC3.BatchSeqId = PB.BatchSeqId    AND PBD3.SlNo=BC3.SlNo AND BC3.SelRte=1 AND PBD3.DefaultPrice=1    AND PB.PrdId =vFParam AND PBD1.PrdBatDetailValue=vSParam) MainQry'UNION
SELECT  330,'Return And Replacement','Replacement Batch','select','SELECT PrdBatId,PrdBatCode,SellingRate,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,DefaultPriceId FROM(SELECT PB.PrdBatId,PB.PrdBatCode,PBD1.PrdBatDetailValue AS MRP,  PBD2.PrdBatDetailValue AS PurchaseRate,PBD3.PrdBatDetailValue AS SellingRate,PB.DefaultPriceId FROM ProductBatch PB WITH (NOLOCK),   ProductBatchDetails PBD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),ProductBatchDetails PBD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),   ProductBatchDetails PBD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK),ProductBatchLocation PBL WITH(NOLOCK)  WHERE PB.PrdBatId = PBD1.PrdBatId And BC1.BatchSeqId = PB.BatchSeqId AND PB.PrdBatID = PBL.PrdBatID AND PBD1.SlNo=BC1.SlNo AND BC1.MRP=1   AND PBD1.DefaultPrice=1 AND PB.PrdBatId = PBD2.PrdBatId AND BC2.BatchSeqId = PB.BatchSeqId AND PBD2.SlNo=BC2.SlNo   AND BC2.ListPrice=1 AND PBD2.DefaultPrice=1 AND PB.PrdBatId = PBD3.PrdBatId And BC3.BatchSeqId = PB.BatchSeqId AND PBD3.SlNo=BC3.SlNo   AND BC3.SelRte=1  AND PBD3.DefaultPrice=1 AND (PrdBatLcnSih - PrdBatLcnRessih) > 0 AND PB.PrdId = vFParam   AND PB.Status=1 AND PBD1.PrdBatDetailValue= vSParam) MainQry'UNION
SELECT  331,'Sample Receipt','Batch','SELECT','SELECT PrdBatID,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,  SellingRate,PriceId FROM (SELECT A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP,D.PrdBatDetailValue AS PurchaseRate,  F.PrdBatDetailValue AS SellingRate,B.PriceId FROM  ProductBatch A (NOLOCK) INNER JOIN ProductBatchDetails B (NOLOCK)  ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1   INNER JOIN BatchCreation C (NOLOCK)ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1  INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1   INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1  INNER JOIN ProductBatchDetails F (NOLOCK) ON A.PrdBatId = F.PrdBatID AND F.DefaultPrice=1   INNER JOIN BatchCreation G (NOLOCK) ON G.BatchSeqId = A.BatchSeqId AND F.SlNo = G.SlNo AND G.SelRte = 1  WHERE  A.PrdId=vFParam  AND A.Status = 1 ) MainQry order by PrdBatId ASC'UNION
SELECT  332,'Billing','Batch','select','SELECT PrdBatID,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellRate,PriceId,ShelfDay,ExpiryDay FROM  (   SELECT A.PrdBatID,A.PrdBatCode,F.PrdBatDetailValue AS SellRate,B.PrdBatDetailValue AS MRP,   D.PrdBatDetailValue AS PurchaseRate,B.PriceId,DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),DATEADD(Day,Prd.PrdShelfLife,A.MnfDate)) as ShelfDay,  DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),A.ExpDate) as ExpiryDay   FROM  ProductBatch A (NOLOCK)   INNER JOIN Product Prd  (NOLOCK) ON A.PrdId = Prd.PrdId   INNER JOIN ProductBatchDetails B  (NOLOCK)  ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1   INNER JOIN BatchCreation C (NOLOCK)    ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1   INNER JOIN ProductBatchDetails D   (NOLOCK)  ON A.PrdBatId = D.PrdBatID   AND D.DefaultPrice=1   INNER JOIN BatchCreation E (NOLOCK)  ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1   INNER JOIN ProductBatchDetails F (NOLOCK)  ON A.PrdBatId = F.PrdBatID AND F.DefaultPrice=1   INNER JOIN BatchCreation G (NOLOCK)  ON   G.BatchSeqId = A.BatchSeqId AND F.SlNo = G.SlNo AND G.SelRte = 1   INNER JOIN ProductBatchLocation PBL (NOLOCK) ON A.PrdId=PBL.PrdId AND A.PrdBatId=PBL.PrdBatId AND (PBL.PrdBatLcnSih-PBL.PrdbatLcnResSih)>0   WHERE  A.PrdId=vFParam  AND A.Status = 1   AND  B.PrdBatDetailValue=vSParam  ) MainQry order by PrdBatId ASC'UNION
SELECT  333,'Salvage','Batch','select','SELECT ExpDate,PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,PrdName,MnfDate   FROM (SELECT PB.ExpDate,  PB.PrdBatId,PB.PrdBatCode,PBD1.PrdBatDetailValue AS MRP,  PBD2.PrdBatDetailValue AS PurchaseRate,  PBD3.PrdBatDetailValue AS SellingRate,  B.PrdName,PB.MnfDate   FROM ProductBatch PB WITH (NOLOCK),  Product B WITH (NOLOCK),      ProductBatchDetails PBD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),    ProductBatchDetails PBD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),  ProductBatchDetails PBD3 WITH (NOLOCK),  BatchCreation BC3 WITH (NOLOCK)      WHERE PB.PrdId=B.PrdId AND PB.PrdId=vFParam AND PB.Status=1 AND PBD1.PrdBatDetailValue=vTParam   AND  PB.PrdBatId IN   (SELECT PrdBatId FROM Dbo.Fn_ReturnUnsaleableQty( vFParam,0,vSParam,3)  WHERE (Qty)>0)   AND PB.PrdBatId = PBD1.PrdBatId  And BC1.BatchSeqId = PB.BatchSeqId  AND PBD1.SlNo=BC1.SlNo     AND BC1.MRP=1 AND PBD1.DefaultPrice=1 AND  PB.PrdBatId = PBD2.PrdBatId     And BC2.BatchSeqId = PB.BatchSeqId  AND PBD2.SlNo=BC2.SlNo AND BC2.ListPrice=1    AND PBD2.DefaultPrice=1 AND  PB.PrdBatId = PBD3.PrdBatId And BC3.BatchSeqId = PB.BatchSeqId    AND PBD3.SlNo=BC3.SlNo AND BC3.SelRte=1 AND PBD3.DefaultPrice=1) MainQry'UNION
SELECT  679,'SampleMaintenance','SampleReceiptBatchCode','select','SELECT PrdBatID,PrdBatCode,  CAST(MRP AS NUMERIC(18,2))MRP,SellingRate,PriceId FROM (SELECT A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue as MRP,  D.PrdBatDetailValue as SellingRate,B.PriceId FROM ProductBatch A (NOLOCK) INNER JOIN   ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 INNER JOIN   BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1   INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1   INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo   AND E.ListPrice = 1 WHERE A.PrdId=vFParam AND A.Status = 1) MainSql ORDER BY PrdBatId ASC'UNION
SELECT  683,'Sales Return','WithReference Batch Selection','select','SELECT PrdBatId,PrdbatCode,    StockType,BaseQty,PreRtnQty,CAST(PrdUnitMRP AS NUMERIC(18,2))PrdUnitMRP ,PrdUnitSelRate,PrdUom1EditedSelRate,  PrdGrossAmount,  PrdGrossAmountAftEdit,PrdNetRateDiffAmount,PriceId,SplPriceId   FROM   (Select Distinct P.PrdBatId,  P.PrdbatCode,''Saleable'' as StockType,      (S.BaseQty - isnull(S.ReturnedQty,0)) as BaseQty,  isnull(S.ReturnedQty,0) as  PreRtnQty,    S.PrdUnitMRP,S.PrdUnitSelRate,    CAST(S.PrdUom1EditedSelRate/Uom1ConvFact AS NUMERIC(18,6))  as PrdUom1EditedSelRate,    S.PrdGrossAmount,  S.PrdGrossAmountAftEdit,(S.PrdRateDiffAmount/S.BaseQty)  as PrdNetRateDiffAmount,    S.PriceId,S.SplPriceId  from ProductBatch P (NOLOCK),  SalesInvoiceProduct S  (NOLOCK)    where P.Status=1 and P.PrdBatId =S.PrdBatId and  (S.BaseQty - isnull(S.ReturnedQty,0)) >0    and S.SalId = vFParam and  S.PrdId=vSParam  And S.Slno = vTParam AND S.PrdUnitMRP=vFOParam     Union All    Select Distinct P.PrdBatId, P.PrdbatCode,    ''Offer'' as  StockType,    (S.SalManFreeQty - isnull(S.ReturnedManFreeQty,0))  as BaseQty,    isnull(S.ReturnedManFreeQty,0) as PreRtnQty,S.PrdUnitMRP,S.PrdUnitSelRate,    CAST(S.PrdUom1EditedSelRate/Uom1ConvFact AS NUMERIC(18,6)) as PrdUom1EditedSelRate,    S.PrdGrossAmount,S.PrdGrossAmountAftEdit,S.PrdRateDiffAmount as PrdNetRateDiffAmount,    S.PriceId,0  as SplPriceId  from ProductBatch P (NOLOCK),SalesInvoiceProduct S (NOLOCK)    where P.Status=1 and  P.PrdBatId =S.PrdBatId And  S.SalId = vFParam and  S.PrdId=vSParam    and  S.SalManFreeQty > 0  And S.Slno = vTParam  AND S.PrdUnitMRP=vFOParam) MainSql'UNION
SELECT  684,'Sales Return','WithOutReference Batch Selection','select','SELECT PrdBatID,  PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,SellRate,PriceId,SplPriceId   FROM   (Select A.PrdBatID,A.PrdBatCode,  B.PrdBatDetailValue as MRP,   D.PrdBatDetailValue as SellRate,A.DefaultPriceId as PriceId,  0 as SplPriceId     from ProductBatch A (NOLOCK)  INNER JOIN ProductBatchDetails B (NOLOCK)   ON A.PrdBatId = B.PrdBatID  AND B.DefaultPrice=1   INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId    AND B.SlNo = C.SlNo   AND   C.MRP = 1   INNER JOIN ProductBatchDetails D (NOLOCK)   ON A.PrdBatId = D.PrdBatID  AND D.DefaultPrice=1  INNER JOIN BatchCreation E (NOLOCK)   ON E.BatchSeqId = A.BatchSeqId  AND D.SlNo = E.SlNo   AND   E.SelRte = 1 WHERE A.PrdId=vFParam AND B.PrdBatDetailValue= vSParam)   MainSql'UNION
SELECT  748,'Order Booking','Display MRP Product without Company','select','SELECT PrdId,PrdDcode,PrdCcode,  PrdName,PrdShrtName,UomGroupId,PrdSeqDtId,CAST(MRP AS NUMERIC(18,2))MRP   FROM   (  SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,  A.UomGroupId,c.PrdSeqDtId,  PBD.PrdBatDetailValue AS MRP  FROM Product A WITH (NOLOCK),ProductSequence B WITH (NOLOCK),    ProductSeqDetails C WITH (NOLOCK), ProductBatch D,ProductBatchDetails PBD,  BatchCreation BC     WHERE B.TransactionId=  vFParam AND A.PrdStatus=1 AND B.PrdSeqId = C.PrdSeqId  AND A.PrdId = C.PrdId     AND A.PrdId=D.PrdId    AND A.PrdType IN (1,2,5,6) AND D.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1       AND PBD.SlNo=BC.SlNo AND BC.MRP=1  AND PBD.BatchSeqId = BC.BatchSeqId   UNION   SELECT A.PrdId,A.PrdDcode,A.PrdCcode,  A.PrdName,A.PrdShrtName,A.UomGroupId,100000 AS PrdSeqDtId,  PBD.PrdBatDetailValue AS MRP  FROM  Product A WITH (NOLOCK)   INNER JOIN ProductBatch D   ON A.PrdId=D.PrdId    AND D.Status=1  Inner Join ProductBatchDetails PBD    ON D.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1   INNER JOIN  BatchCreation BC ON PBD.SlNo=BC.SlNo   AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId      WHERE PrdStatus = 1 and  A.PrdId NOT IN (SELECT PrdId FROM   ProductSequence B WITH (NOLOCK),    ProductSeqDetails C WITH (NOLOCK)   WHERE B.TransactionId= vFParam   AND B.PrdSeqId=C.PrdSeqId)    AND A.PrdType IN (1,2,5,6)   ) a   ORDER BY PrdSeqDtId'UNION
SELECT  749,'Order Booking','Display MRP Product with Company','select','SELECT PrdId,PrdDcode,PrdCcode,  PrdName,PrdShrtName,UomGroupId,PrdSeqDtId,CAST(MRP AS NUMERIC(18,2))MRP   FROM   (  SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,  A.UomGroupId,c.PrdSeqDtId,  PBD.PrdBatDetailValue AS MRP   FROM Product A WITH (NOLOCK),    ProductSequence B WITH (NOLOCK),    ProductSeqDetails C WITH (NOLOCK), ProductBatch D,ProductBatchDetails PBD,  BatchCreation BC   WHERE B.TransactionId=  vFParam  AND A.PrdStatus=1   AND B.PrdSeqId = C.PrdSeqId      AND A.PrdId = C.PrdId AND A.PrdId=D.PrdId    AND A.PrdType IN (1,2,5,6) AND D.PrdBatId=PBD.PrdBatId     AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1  AND PBD.BatchSeqId = BC.BatchSeqId        UNION   SELECT A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,A.UomGroupId,100000 AS PrdSeqDtId,     PBD.PrdBatDetailValue AS MRP  FROM  Product A WITH (NOLOCK) INNER JOIN ProductBatch D   ON A.PrdId=D.PrdId      AND D.Status=1  Inner Join ProductBatchDetails PBD ON D.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1      INNER JOIN  BatchCreation BC ON PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId     WHERE PrdStatus = 1 and A.Cmpid =vSParam  and A.PrdId   NOT IN (SELECT PrdId FROM ProductSequence B WITH (NOLOCK),     ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId= vFParam AND B.PrdSeqId=C.PrdSeqId  )   AND A.PrdType IN (1,2,5,6)   ) a ORDER BY PrdSeqDtId'UNION
SELECT  750,'Kit Product Master','Display MRP Product','select','SELECT PrdDcode,PrdId,PrdName,  CmpId,CAST(MRP AS NUMERIC(18,2))MRP FROM (SELECT DISTINCT PrdDcode,p.PrdId,PrdName,CmpId,PBD.PrdBatDetailValue AS MRP   FROM Product p,productbatch pb,ProductBatchDetails PBD ,BatchCreation BC  WHERE p.prdid = pb.prdid and PrdType <> 3 and cmpId = vFParam  AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1   AND PBD.BatchSeqId=BC.BatchSeqId ) a'UNION
SELECT  751,'Salvage','Display MRP Product','select','SELECT PrdSeqDtId,PrdId,PrdDcode,PrdCcode,  PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP FROM (SELECT x.PrdSeqDtId,x.PrdId,x.PrdDcode,x.PrdCcode,x.PrdName,  x.PrdShrtName,x.MRP FROM (SELECT  c.PrdSeqDtId,A.PrdId,A.PrdDcode,A.PrdCCode,A.PrdName,A.PrdShrtName,  PBD.PrdBatDetailValue AS MRP ,Pb.Prdbatid FROM Product A  WITH (NOLOCK),ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK), ProductBatch PB WITH (NOLOCK),  ProductBatchDetails  PBD WITH (NOLOCK),  BatchCreation BC WITH (NOLOCK)  WHERE  B.TransactionId = vSParam  And A.PrdStatus = 1 And B.PrdSeqId = C.PrdSeqId  And A.Prdid = C.Prdid  AND A.PrdId = PB.PrdId  AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1  AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId  UNION  SELECT 100000 AS PrdSeqDtId,A.PrdId,  A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,Pb.Prdbatid  FROM Product A WITH (NOLOCK),  ProductBatch PB WITH (NOLOCK),ProductBatchDetails  PBD WITH (NOLOCK), BatchCreation BC WITH (NOLOCK)  WHERE PrdStatus = 1 AND A.PrdId NOT IN (SELECT PrdId FROM ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId= 21 AND B.PrdSeqId=C.PrdSeqId)  AND A.PrdId = PB.PrdId AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo  AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId) x,    Dbo.Fn_ReturnUnsaleableQty( 0,0,vFParam,2) D,  Location L WITH (NOLOCK)     WHERE  x.Prdid = D.Prdid  And L.LcnId = vFParam  And L.LcnId = D.LcnId and D.Prdbatid=X.prdbatid GROUP BY x.MRP,x.PrdId,x.PrdDcode,x.PrdName,x.PrdSeqDtId,x.PrdCcode,x.PrdShrtName  HAVING Sum(Qty) > 0) A ORDER BY PrdSeqDtId'UNION
SELECT  752,'Location Transfer','Display MRP Product','select','SELECT PrdSeqDtId,PrdId,PrdDcode,  PrdCcode,PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP FROM (SELECT DISTINCT C.PrdSeqDtId,  A.PrdId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP FROM Product A WITH (NOLOCK),  ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK),ProductBatchLocation D WITH (NOLOCK),  ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),  BatchCreation BC WITH (NOLOCK)  WHERE B.TransactionId=4 AND A.PrdStatus=1 AND A.PrdType <> 3 AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId    AND A.PrdId=D.PrdId    AND ((D.PrdBatLcnSih+D.PrdBatLcnUih+D.PrdBatLcnFre)-(D.PrdBatLcnResSih+D.PrdBatLcnResUih+D.PrdBatLcnResFre))>0      AND D.LcnId=vFParam AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1     AND  PBD.BatchSeqId=BC.BatchSeqId and A.PrdId = PB.PrdId UNION  SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,  A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP FROM Product A WITH (NOLOCK),  ProductBatchLocation D WITH (NOLOCK),    ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),    BatchCreation BC WITH (NOLOCK)  WHERE A.PrdStatus = 1 AND A.PrdType <> 3  AND A.PrdId=D.PrdId    AND ((D.PrdBatLcnSih+D.PrdBatLcnUih+D.PrdBatLcnFre)-(D.PrdBatLcnResSih+D.PrdBatLcnResUih+D.PrdBatLcnResFre))>0      AND D.LcnId=vFParam AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1     AND  PBD.BatchSeqId=BC.BatchSeqId and A.Prdid = PB.PrdId     AND A.PrdId NOT IN ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),  ProductSeqDetails C  WITH (NOLOCK)     WHERE B.TransactionId=4 AND B.PrdSeqId=C.PrdSeqId))  MainSql   ORDER BY PrdSeqDtId'UNION
SELECT  753,'Stock Journal','Display MRP Product','select','Select PrdId,PrdDCode,PrdCcode,PrdName,  PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP From (SELECT Distinct P.PrdId,PrdDCode,PrdCcode,PrdShrtName,PrdName,PBD.PrdBatDetailValue as MRP     FROM Product P with (NOLOCK),ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),  BatchCreation BC WITH (NOLOCK),ProductBatchLocation PBL WITH (NOLOCK) WHERE PrdStatus=1 and P.PrdId = PB.PrdId   and PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1   AND PBD.BatchSeqId=BC.BatchSeqId AND PBL.PrdId=P.PrdId  AND PBL.PrdBatID=PB.PrdBatId   AND PBL.PrdBatID=PBD.PrdBatId   AND ((PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) > 0 OR (PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih) > 0  OR (PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre) > 0)) a'UNION
SELECT  754,'Stock Management','Display MRP Product - Stock In','select','SELECT PrdSeqDtId,PrdId,PrdDcode,PrdCcode,  PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP FROM (SELECT C.PrdSeqDtId,A.PrdId, A.PrdDcode,A.PrdCcode,A.PrdName,  A.PrdShrtName,PBD.PrdBatDetailValue AS MRP FROM Product A WITH(NOLOCK),  ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),  BatchCreation BC WITH (NOLOCK) WHERE B.TransactionId=13 AND A.PrdStatus=1 AND PB.PrdBatId=PBD.PrdBatId    AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND PBD.BatchSeqId=BC.BatchSeqId AND A.PrdId = PB.PrdId   AND A.PrdType <> 3  AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId UNION SELECT 100000 AS PrdSeqDtId,    A.PrdId,A.PrdDcode,PrdCcode,PrdName,PrdShrtName,PBD.PrdBatDetailValue AS MRP FROM Product A WITH (NOLOCK),     ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK), BatchCreation BC WITH (NOLOCK)   WHERE PrdStatus = 1 AND PrdType <> 3 and A.PrdId NOT IN ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=13 AND B.PrdSeqId=C.PrdSeqId)   AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1    AND PBD.BatchSeqId=BC.BatchSeqId AND A.PrdId = PB.PrdId) MainSql ORDER BY PrdSeqDtId'UNION
SELECT  755,'Stock Management','Display MRP Product - Stock Out','select','SELECT PrdSeqDtId,PrdId,PrdDcode,PrdCCode,  PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP FROM (SELECT C.PrdSeqDtId,A.PrdId,A.PrdDcode,A.PrdCCode,A.PrdName,A.PrdShrtName,  PBD.PrdBatDetailValue AS MRP   FROM Product A WITH(NOLOCK),ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK),  ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),  BatchCreation BC WITH (NOLOCK)  WHERE B.TransactionId=13 AND A.PrdStatus=1 AND PB.PrdBatId=PBD.PrdBatId   AND PBD.DefaultPrice=1  AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND PBD.BatchSeqId=BC.BatchSeqId   AND A.PrdId = PB.PrdId  AND A.PrdType <> 3  AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId   UNION  SELECT 100000 AS PrdSeqDtId, A.PrdId,A.PrdDcode,A.PrdCCode,A.PrdName,A.PrdShrtName,  PBD.PrdBatDetailValue AS MRP  FROM  Product A WITH (NOLOCK), ProductBatch PB WITH (NOLOCK),   ProductBatchDetails PBD WITH (NOLOCK), BatchCreation BC WITH (NOLOCK)   WHERE PrdStatus = 1 AND PrdType <> 3   and A.PrdId NOT IN ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK)   WHERE B.TransactionId=13 AND B.PrdSeqId=C.PrdSeqId)  AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1  AND PBD.BatchSeqId=BC.BatchSeqId   AND A.PrdId = PB.PrdId) MainSql  ORDER BY PrdSeqDtId'UNION
SELECT  756,'Purchase Receipt','Display MRP Product with Company Code','select','SELECT PrdSeqDtId,PrdId,PrdCcode,PrdDCode,PrdName,CAST(MRP AS NUMERIC(18,2))MRP,ERPPrdCode,PrdShrtName FROM (SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,A.PrdShrtName,  PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'') AS ERPPrdCode FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK),  ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)      LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode WHERE B.TransactionId=vSParam AND A.PrdStatus=1 AND A.PrdType<> 3   AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId AND A.CmpId = vFParam AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND PBD.BatchSeqId=BC.BatchSeqId AND A.PrdId = PB.PrdId UNION SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,  A.PrdDCode,A.PrdName,PrdShrtName,PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'') AS ERPPrdCode FROM ProductBatch PB WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode     WHERE PrdStatus = 1 AND A.PrdId = PB.PrdId  and PB.PrdBatId=PBD.PrdBatId   AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND   PBD.BatchSeqId=BC.BatchSeqId AND A.PrdType <>3 AND A.PrdId NOT IN (SELECT PrdId FROM ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId)AND A.CmpId = vFParam)A ORDER BY PrdSeqDtId'UNION
SELECT  757,'Purchase Receipt','Display MRP Product with Distributor Code','select','SELECT PrdSeqDtId,PrdId,PrdCcode,PrdDCode,PrdName,CAST(MRP AS NUMERIC(18,2))MRP,ERPPrdCode,PrdShrtName FROM (SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdCcode,A.PrdDCode,A.PrdName,A.PrdShrtName,  PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'') AS ERPPrdCode FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK),  ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)  LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode WHERE B.TransactionId=vSParam AND A.PrdStatus=1 AND A.PrdType<> 3      AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId  AND A.CmpId = vFParam AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1     AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId  AND A.PrdId = PB.PrdId UNION   SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdCCode,A.PrdDCode,A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,ISNULL(ERP.ERPPrdCode,'') AS ERPPrdCode            FROM ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),Product A WITH (NOLOCK)         LEFT OUTER JOIN ERPPrdCCodeMapping ERP ON ERP.PrdCCode=A.PrdCCode WHERE PrdStatus = 1 AND A.PrdId = PB.PrdId  and PB.PrdBatId=PBD.PrdBatId   AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND PBD.BatchSeqId=BC.BatchSeqId AND A.PrdType <>3   AND A.PrdId NOT IN (SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK)  WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId) AND A.CmpId = vFParam)A  ORDER BY PrdSeqDtId'UNION
SELECT  758,'Purchase Return','Display MRP Product','select','SELECT PrdSeqDtId,PrdId,PrdDCode,PrdCcode,PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP     FROM   (   SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdDCode,A.PrdCcode,A.PrdName,A.PrdShrtName,  PBD.PrdBatDetailValue AS MRP     FROM Product A WITH (NOLOCK),ProductSequence B WITH (NOLOCK),      ProductSeqDetails C WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),  BatchCreation BC WITH (NOLOCK)        WHERE B.TransactionId=vSParam  AND A.PrdStatus=1 AND A.PrdType<> 3   AND B.PrdSeqId = C.PrdSeqId      AND A.PrdId = C.PrdId  AND A.CmpId = vFParam    and A.PrdId = PB.PrdId  and PB.PrdBatId=PBD.PrdBatId     AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId     AND A.PrdId IN (SELECT PrdId FROM ProductBatchLocation WHERE LcnId=vTParam AND     ((PrdBatLcnSih+PrdBatLcnUih)-(PrdBatLcnRessih+PrdBatLcnResUih))>0)     UNION        SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdDCode,A.PrdCCode,A.PrdName,A.PrdShrtName,  PBD.PrdBatDetailValue AS MRP    FROM  Product A WITH (NOLOCK),  ProductBatch PB WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),      BatchCreation BC WITH (NOLOCK)    WHERE PrdStatus = 1 and A.PrdId = PB.PrdId   and PB.PrdBatId=PBD.PrdBatId     AND PBD.DefaultPrice=1  AND PBD.SlNo=BC.SlNo   AND BC.MRP=1 AND PBD.BatchSeqId=BC.BatchSeqId   AND A.PrdType <>3      AND A.PrdId  NOT IN ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),      ProductSeqDetails C WITH (NOLOCK)    WHERE B.TransactionId=vSParam AND B.PrdSeqId=C.PrdSeqId)      AND A.CmpId = vFParam AND  A.PrdId IN (SELECT PrdId FROM ProductBatchLocUNIONation WHERE LcnId=vTParam AND     ((PrdBatLcnSih+PrdBatLcnUih)-(PrdBatLcnRessih+PrdBatLcnResUih))>0)) A ORDER BY PrdSeqDtId'UNION
SELECT  759,'Return to Company','Display MRP ProductName','select','Select DISTINCT PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP FROM (SELECT P.PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,PBD.PrdBatDetailValue AS MRP      FROM Product P,ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK)        WHERE P.PrdId in (SELECT DISTINCT prdid FROM ProductBatchLocation WITH (NOLOCK)       WHERE LcnId = vFParam  and  ((PrdBatLcnUih) - (PrdBatLcnResUih)) >0)  and PrdStatus = 1     AND PrdType <> 3 and SpmId=vSParam   and PBD.PrdBatId In  (SELECT DISTINCT PrdBatId FROM ProductBatchLocation WITH (NOLOCK)       WHERE   (PrdBatLcnUih) - (PrdBatLcnResUih) > 0)   AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1       AND PBD.SlNo=BC.SlNo AND BC.MRP=1    AND PBD.BatchSeqId=BC.BatchSeqId AND P.Prdid = PB.PrdId ) a'UNION
SELECT  760,'Van Load / Unload Screen','Display MRP Product','select','SELECT PrdSeqDtId,PrdId,PrdDcode,  PrdCcode,PrdName,PrdShrtName,UomGroupId,CAST(MRP AS NUMERIC(18,2))MRP  FROM (SELECT DISTINCT C.PrdSeqDtId,A.PrdId,A.PrdDcode,A.PrdCcode,  A.PrdName,A.PrdShrtName,A.UomGroupId,PBD.PrdBatDetailValue AS MRP FROM Product A WITH (NOLOCK),  ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK),ProductBatchLocation D WITH (NOLOCK),  ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK)    WHERE B.TransactionId=vSParam AND A.PrdId=D.PrdId   AND A.PrdId = PB.PrdId  AND A.PrdStatus=1   AND A.PrdType <> 3  AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId   AND ((D.PrdBatLcnSih+D.PrdBatLcnUih+D.PrdBatLcnFre)-(D.PrdBatLcnResSih+D.PrdBatLcnResUih + D.PrdBatLcnResFre))>0      AND D.LcnId=vFParam AND PB.PrdBatId=PBD.PrdBatId   AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1     AND  PBD.BatchSeqId=BC.BatchSeqId UNION    SELECT DISTINCT 100000 AS PrdSeqDtId,A.PrdId,A.PrdDcode,  A.PrdCcode,A.PrdName,A.PrdShrtName,A.UomGroupId,PBD.PrdBatDetailValue AS MRP FROM  Product A WITH (NOLOCK),  ProductBatchLocation D WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),  BatchCreation BC WITH (NOLOCK)    WHERE A.PrdStatus = 1  AND A.PrdType <> 3 AND A.PrdId=D.PrdId   AND ((D.PrdBatLcnSih+D.PrdBatLcnUih+D.PrdBatLcnFre)-(D.PrdBatLcnResSih+  D.PrdBatLcnResUih+D.PrdBatLcnResFre))>0   AND D.LcnId=vFParam  AND PB.PrdBatId=PBD.PrdBatId   AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1   AND  PBD.BatchSeqId=BC.BatchSeqId and A.PrdId = PB.PrdId AND A.PrdId NOT IN (SELECT PrdId FROM   ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK)  WHERE B.TransactionId=vSParam   AND B.PrdSeqId=C.PrdSeqId))A  ORDER BY PrdSeqDtId'UNION
SELECT  761,'Resell Damage Goods','Display MRP Product','select',' SELECT PrdId,PrdSeqDtId,  PrdDcode,PrdCcode,PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP FROM (SELECT DISTINCT A.PrdId,C.PrdSeqDtId,A.PrdDcode,A.PrdCcode,  A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP FROM Product A WITH (NOLOCK),ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK),ProductBatchLocation D WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),  BatchCreation BC WITH (NOLOCK)    WHERE B.TransactionId=vTParam    AND A.PrdStatus=1 AND A.PrdType<>3    AND A.CmpId=vFParam  AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId   And A.PrdId = D.PrdId  AND ((D.PrdBatLcnUih-D.PrdBatLcnResUih))>0   AND D.LcnId=vSParam  AND PB.PrdBatId=PBD.PrdBatId   AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId      AND A.PrdId = PB.PRdId    UNION    SELECT DISTINCT A.PrdId,100000 AS PrdSeqDtId,A.PrdDcode,A.PrdCcode,A.PrdName,  A.PrdShrtName,PBD.PrdBatDetailValue AS MRP   FROM  Product A WITH (NOLOCK),  ProductBatch PB WITH (NOLOCK),    ProductBatchDetails PBD WITH (NOLOCK),  BatchCreation BC WITH (NOLOCK) ,  ProductBatchLocation D WITH (NOLOCK)    WHERE A.PrdType<> 3 AND A.PrdStatus = 1   AND A.CmpId =vFParam  and PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1  and PBD.BatchSeqId=BC.BatchSeqId   and A.PrdId = PB.PrdId  AND A.PrdId = D.PrdId   AND ((D.PrdBatLcnUih - D.PrdBatLcnResUih)) > 0   AND D.LcnId=vSParam    AND A.PrdId NOT IN   ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),ProductSeqDetails C WITH (NOLOCK)   WHERE B.TransactionId=vTParam AND B.PrdSeqId=C.PrdSeqId) ) a ORDER BY PrdSeqDtId'UNION
SELECT  762,'Sales Return','WithOutReference Display MRP Product','select','SELECT PrdId,PrdDCode,PrdCcode,  PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP  FROM (SELECT Distinct P.PrdId,P.PrdDCode,P.PrdCcode,P.PrdName,P.PrdShrtName,  PBD.PrdBatDetailValue AS MRP From Product P (NOLOCK),ProductBatch PB WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK)where P.PrdStatus=1  and P.PrdType <> 3   and PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1  AND PBD.SlNo=BC.SlNo AND BC.MRP=1     AND PBD.BatchSeqId=BC.BatchSeqId and P.Prdid = PB.PrdId      AND P.CmpId = Case vFParam WHEN 0  then P.CmpId ELSE vFParam END ) MainSQl Order by PrdId'UNION
SELECT  763,'Sales Return','WithReference Display MRP Product','select','SELECT PrdId,PrdDCode,PrdName,SlNo,SalID,CAST(MRP AS NUMERIC(18,2))MRP,BatchId  FROM (Select P.PrdId,  P.PrdDCode,P.PrdName,B.SlNo,S.SalID,PBD.PrdBatDetailValue AS MRP ,PB.PrdBatId As BatchId   From Product P (NOLOCK),  SalesInvoiceProduct B (NOLOCK),  ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),  SalesInvoice S (NOLOCK) Where S.SalID=B.SalID  and B.PrdId = P.PrdId  and S.SalInvNo =''vFParam'' and PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId and P.PrdId = PB.PrdId AND B.PrdBatId = PBD.PrdBatId  and P.CmpId = Case vSParam  WHEN 0 then P.CmpId ELSE vSParam END)Mainsql'UNION
SELECT  764,'Return And Replacement','Return Display MRP Product','select','Select DISTINCT PrdId,PrdDcode,prdCcode,PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP     FROM (SELECT A.PrdId,PrdDcode,prdCcode,  PrdName,PrdShrtName,PBD.PrdBatDetailValue AS MRP     FROM Product  A WITH (NOLOCK),  ProductBatch PB WITH (NOLOCK),    ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK)       WHERE PrdType<>3 and PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1      AND PBD.SlNo=BC.SlNo  AND BC.MRP=1 AND PBD.BatchSeqId=BC.BatchSeqId      and A.PrdId = PB.PrdId) a'UNION
SELECT  765,'Return And Replacement','Replacement Display MRP Product','select','SELECT DISTINCT PrdId,PrdDcode,prdCcode,PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP FROM (SELECT DISTINCT A.PrdId,PrdDcode,prdCcode,PrdName,PrdShrtName,PBD.PrdBatDetailValue AS MRP       FROM Product A WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),  ProductBatchLocation PBL WITH (NOLOCK)         WHERE A.PrdId = PBL.PrdId AND PB.PrdBatId = PBL.PrdBatId AND PrdType<>3 AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo   AND BC.MRP=1 AND PBD.BatchSeqId=BC.BatchSeqId        AND A.PrdId = PB.PrdId)A'UNION
SELECT  766,'Market Return','Display MRP Product With BillNumber','select','SELECT PrdId,PrdDCode,PrdName,SlNo,SalID,CAST(MRP AS NUMERIC(18,2))MRP,BatchId  FROM  (Select P.PrdId,P.PrdDCode,P.PrdName,B.SlNo,S.SalID,   PBD.PrdBatDetailValue AS MRP,Pb.PrdbatId as BatchId   From Product P (NOLOCK), SalesInvoiceProduct B (NOLOCK), SalesInvoice S (NOLOCK),  ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK)  Where S.SalID=B.SalID  and B.PrdId = P.PrdId and S.SalInvNo =''vFParam''  and PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId and P.Prdid = Pb.PrdId and B.PrdbatId = PBD.PrdBatId  and P.CmpId = Case vSParam  WHEN 0 then P.CmpId ELSE vSParam END)Mainsql'UNION
SELECT  767,'Market Return','Display MRP Product Without BillNumber','select','SELECT PrdId,  PrdDCode,PrdCcode,PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP FROM   (Select DISTINCT P.PrdId,P.PrdDCode,P.PrdCcode,P.PrdName,P.PrdShrtname,PBD.PrdBatDetailValue AS MRP  From Product P (NOLOCK),ProductBatch PB WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),    BatchCreation BC WITH (NOLOCK) where P.PrdStatus=1 and P.PrdType <> 3  and P.PrdId = PB.PrdId    AND P.CmpId = Case 0 WHEN 0  then P.CmpId ELSE 0 END  AND PB.PrdBatId=PBD.PrdBatId  AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId ) MainSQl Order by PrdId'UNION
SELECT  768,'Billing','Display MRP Product Sales Bundle without Company','Select','SELECT PrdId,PrdDCode,PrdCcode,PrdName,CAST(MRP AS NUMERIC(18,2))MRP,PrdSeqDtId,PrdShrtName,PrdType FROM (SELECT DISTINCT B.PrdId,B.PrdSNo As PrdSeqDtId,  C.PrdDcode,C.PrdCcode,C.PrdName,C.PrdShrtName,PBD.PrdBatDetailValue AS MRP,C.PrdType FROM PrdSalesBundle A   WITH (NOLOCK)  INNER JOIN PrdSalesBundleProducts B WITH (NOLOCK) ON A.PRdSlsBdleId = B.PrdSlsBdleId    INNER JOIN Product C WITH (NOLOCK) ON B.PrdId = C.PrdId  INNER JOIN ProductBatchLocation D WITH (NOLOCK) ON   C.PrdStatus = 1  AND C.PrdId=D.PrdId  AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0 AND C.PrdType <> 4    AND D.LcnId=vFParam  INNER JOIN  ProductBatch E ON D.PrdBatId = E.PrdBatId    INNER JOIN  ProductBatchDetails PBD WITH (NOLOCK) ON E.PrdBatId=PBD.PrdBatId    INNER JOIN  BatchCreation BC WITH (NOLOCK) ON PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo    AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId  WHERE  A.PrdSlsBdleId IN (SELECT ISNULL(MAX(PrdSlsBdleId),0)  FROM PrdSalesBundle  WHERE SmId = vTParam AND vFOParam = (CASE RmId WHEN 0 THEN vFOParam ELSE RmId END))   AND E.Status = 1  AND E.PrdId = C.PrdId ) a ORDER BY PrdSeqDtId'UNION
SELECT  769,'Billing','Display MRP Product Sales Bundle with Company','Select','SELECT PrdId,PrdDCode,PrdCcode,PrdName,PrdSeqDtId,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP,PrdType FROM (SELECT DISTINCT B.PrdId,B.PrdSNo As PrdSeqDtId,C.PrdDcode,  C.PrdCcode,C.PrdName,C.PrdShrtName,PBD.PrdBatDetailValue AS MRP,C.PrdType FROM PrdSalesBundle A WITH (NOLOCK)   INNER JOIN PrdSalesBundleProducts B WITH (NOLOCK)   ON A.PRdSlsBdleId = B.PrdSlsBdleId    INNER JOIN Product C WITH (NOLOCK)   ON B.PrdId = C.PrdId  INNER JOIN ProductBatchLocation D WITH (NOLOCK)   ON C.PrdStatus = 1  AND C.PrdId=D.PrdId  AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0   AND C.PrdType <> 4  AND D.LcnId=vFParam  INNER JOIN  ProductBatch E ON D.PrdBatId = E.PrdBatId      INNER JOIN  ProductBatchDetails PBD WITH (NOLOCK) ON E.PrdBatId=PBD.PrdBatId      INNER JOIN  BatchCreation BC WITH (NOLOCK) ON PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo     AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId    WHERE  A.PrdSlsBdleId IN (SELECT ISNULL(MAX(PrdSlsBdleId),0)    FROM PrdSalesBundle    WHERE SmId = vTParam AND vFOParam = (CASE RmId WHEN 0 THEN vFOParam ELSE RmId END))    AND E.Status = 1  AND E.PrdId = C.PrdId AND C.CmpId = vSParam ) a ORDER BY PrdSeqDtId'UNION
SELECT  770,'Billing','Display MRP Product without Company','select','SELECT PrdId,PrdDCode,PrdCcode,PrdName,PrdShrtName,PrdSeqDtId,CAST(MRP AS NUMERIC(18,2))MRP,PrdType FROM (SELECT DISTINCT A.PrdId,C.PrdSeqDtId,A.PrdDcode,A.PrdCcode,A.PrdName,  A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,A.PrdType FROM Product A WITH (NOLOCK),   ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),    BatchCreation BC WITH (NOLOCK),  ProductBatchLocation D WITH (NOLOCK),  ProductBatch E WITH (NOLOCK)      WHERE B.TransactionId=2 AND A.PrdStatus=1 AND B.PrdSeqId = C.PrdSeqId  AND A.PrdId = C.PrdId     AND A.PrdId=D.PrdId AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0  AND PrdType <> 4 AND D.LcnId=vFParam   AND D.PrdBatId = E.PrdBatId AND  E.Status = 1 AND E.PrdId = A.PrdId    AND D.PrdBatId=PBD.PrdBatId   AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1   AND  PBD.BatchSeqId=BC.BatchSeqId      Union    SELECT DISTINCT A.PrdId,100000 AS PrdSeqDtId,A.PrdDcode,A.PrdCcode,  A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,A.PrdType    FROM  Product A WITH (NOLOCK),ProductBatchLocation D WITH (NOLOCK), ProductBatch E WITH (NOLOCK),    ProductBatchDetails PBD WITH (NOLOCK),  BatchCreation BC WITH (NOLOCK)  WHERE PrdStatus = 1  AND A.PrdId=D.PrdId   AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0   AND PrdType <> 4  AND D.LcnId=vFParam    AND    A.PrdId NOT IN ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK)      WHERE B.TransactionId=2 AND B.PrdSeqId=C.PrdSeqId)    AND D.PrdBatId = E.PrdBatId AND  E.Status = 1    AND E.PrdId = A.PrdId    and D.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo     AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId )  a ORDER BY PrdSeqDtId'UNION
SELECT  771,'Billing','Display MRP Product with Company','select','SELECT PrdId,PrdDCode,PrdCcode,PrdName,PrdSeqDtId,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP,PrdType FROM (SELECT DISTINCT A.PrdId,C.PrdSeqDtId,A.PrdDcode,A.PrdCcode,A.PrdName,  A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,A.PrdType FROM Product A WITH (NOLOCK),  ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK),ProductBatchLocation D WITH (NOLOCK),  ProductBatch E WITH (NOLOCK),     ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK)    WHERE B.TransactionId=2 AND A.PrdStatus=1   AND B.PrdSeqId = C.PrdSeqId  AND A.PrdId = C.PrdId   AND A.PrdId=D.PrdId AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0   AND PrdType <> 4  AND D.LcnId=vFParam   AND D.PrdBatId = E.PrdBatId AND  E.Status = 1 AND E.PrdId = A.PrdId   AND A.CmpId = vSParam    AND E.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1   AND PBD.BatchSeqId=BC.BatchSeqId    Union    SELECT DISTINCT A.PrdId,100000 AS PrdSeqDtId,A.PrdDcode,A.PrdCcode,  A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,A.PrdType FROM  Product A WITH (NOLOCK),  ProductBatchLocation D WITH (NOLOCK), ProductBatch E WITH (NOLOCK),ProductBatchDetails PBD WITH (NOLOCK),  BatchCreation BC WITH (NOLOCK)   WHERE PrdStatus = 1  AND A.PrdId=D.PrdId AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0   AND PrdType <> 4   AND D.LcnId=vFParam  AND  A.PrdId NOT IN ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),   ProductSeqDetails C WITH (NOLOCK)  WHERE B.TransactionId=2 AND B.PrdSeqId=C.PrdSeqId) AND D.PrdBatId = E.PrdBatId   AND  E.Status = 1  AND E.PrdId = A.PrdId AND A.CmpId = vSParam   AND E.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1   AND PBD.BatchSeqId=BC.BatchSeqId ) a ORDER BY PrdSeqDtId'UNION
SELECT  782,'SampleMaintenance','BatchWor','select','SELECT PrdBatID,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,PriceId FROM(SELECT A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP,  D.PrdBatDetailValue AS PurchaseRate,F.PrdBatDetailValue AS SellingRate,B.PriceId FROM ProductBatch A (NOLOCK)   INNER JOIN ProductBatchDetails B (NOLOCK)ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 INNER JOIN BatchCreation C (NOLOCK)  ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1 INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID   AND D.DefaultPrice=1 INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1   INNER JOIN ProductBatchDetails F(NOLOCK) ON A.PrdBatId = F.PrdBatID AND F.DefaultPrice=1 INNER JOIN BatchCreation G (NOLOCK)   ON G.BatchSeqId = A.BatchSeqId AND F.SlNo = G.SlNo AND G.SelRte = 1   INNER JOIN ProductBatchLocation PBL ON A.PrdBatId = PBL.PrdBatId WHERE A.PrdId=vFParam AND A.Status = 1 AND  ((PrdBatLcnSih-PrdBatLcnRessih)+(PrdBatLcnUih-PrdBatLcnResUih)+(PrdBatLcnFre-PrdBatLcnResFre))> 0)MainQry order by PrdBatId ASC'UNION
SELECT  791,'Billing','Display Product Sales Bundle [MRP AND Saleable Qty] with Company','select','SELECT PrdId,PrdSeqDtId,  PrdDcode,PrdCcode,PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP,SaleableQty,PrdType,BatchId FROM (SELECT DISTINCT B.PrdId,  B.PrdSNo As PrdSeqDtId,C.PrdDcode,C.PrdCcode,C.PrdName,C.PrdShrtName,PBD.PrdBatDetailValue AS MRP,  (D.PrdBatLcnSih-D.PrdBatLcnResSih) AS SaleableQty,C.PrdType,E.PrdBatId as BatchId FROM PrdSalesBundle A WITH (NOLOCK)   INNER JOIN PrdSalesBundleProducts B WITH (NOLOCK) ON A.PRdSlsBdleId = B.PrdSlsBdleId     INNER JOIN Product C WITH (NOLOCK) ON B.PrdId = C.PrdId  INNER JOIN ProductBatchLocation D WITH (NOLOCK)    ON C.PrdStatus = 1   AND C.PrdId=D.PrdId  AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0 AND C.PrdType <> 4   AND D.LcnId=vFParam  INNER JOIN  ProductBatch E ON D.PrdBatId = E.PrdBatId  INNER JOIN  ProductBatchDetails PBD   WITH (NOLOCK) ON E.PrdBatId=PBD.PrdBatId  INNER JOIN  BatchCreation BC WITH (NOLOCK) ON PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId  WHERE  A.PrdSlsBdleId   IN (SELECT ISNULL(MAX(PrdSlsBdleId),0)  FROM PrdSalesBundle   WHERE SmId = vTParam   AND vFOParam = (CASE RmId WHEN 0 THEN vFOParam ELSE RmId END))  AND E.Status = 1   AND E.PrdId = C.PrdId   AND C.CmpId = vSParam ) a ORDER BY PrdSeqDtId'UNION
SELECT  792,'Billing','Display Product Sales Bundle [MRP AND Saleable Qty] without Company','Select','SELECT PrdId,PrdSeqDtId,  PrdDcode,PrdCcode,PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP,SaleableQty,PrdType,BatchId FROM (SELECT DISTINCT B.PrdId,B.PrdSNo As PrdSeqDtId,  C.PrdDcode,C.PrdCcode,C.PrdName,C.PrdShrtName,PBD.PrdBatDetailValue AS MRP,(D.PrdBatLcnSih-D.PrdBatLcnResSih) AS SaleableQty,  C.PrdType,E.PrdBatId as BatchId FROM PrdSalesBundle A WITH (NOLOCK) INNER JOIN PrdSalesBundleProducts B WITH (NOLOCK)  ON A.PRdSlsBdleId = B.PrdSlsBdleId   INNER JOIN Product C WITH (NOLOCK) ON B.PrdId = C.PrdId    INNER JOIN ProductBatchLocation D WITH (NOLOCK)  ON C.PrdStatus = 1   AND C.PrdId=D.PrdId    AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0 AND C.PrdType <> 4 AND D.LcnId=vFParam     INNER JOIN  ProductBatch E ON D.PrdBatId = E.PrdBatId   INNER JOIN  ProductBatchDetails PBD WITH (NOLOCK)   ON E.PrdBatId=PBD.PrdBatId  INNER JOIN  BatchCreation BC WITH (NOLOCK) ON PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo  AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId  WHERE  A.PrdSlsBdleId IN (SELECT ISNULL(MAX(PrdSlsBdleId),0)    FROM PrdSalesBundle   WHERE SmId = vTParam AND vFOParam = (CASE RmId WHEN 0 THEN vFOParam ELSE RmId END))   AND E.Status = 1   AND E.PrdId = C.PrdId ) a ORDER BY PrdSeqDtId'UNION
SELECT  793,'Billing','Display Product [MRP AND Saleable Qty] with Company','select','SELECT PrdId,PrdSeqDtId,PrdDcode,  PrdCcode,PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP,SaleableQty,PrdType,BatchId  FROM (SELECT DISTINCT A.PrdId,C.PrdSeqDtId,  A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,  (D.PrdBatLcnSih-D.PrdBatLcnResSih) AS SaleableQty,A.PrdType,E.PrdBatId as BatchId FROM Product A WITH (NOLOCK),  ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK),ProductBatchLocation D WITH (NOLOCK),   ProductBatch E WITH (NOLOCK), ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK)    WHERE B.TransactionId=2 AND A.PrdStatus=1 AND B.PrdSeqId = C.PrdSeqId AND A.PrdId = C.PrdId AND A.PrdId=D.PrdId   AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0 AND PrdType <> 4 AND D.LcnId=vFParam AND D.PrdBatId = E.PrdBatId   AND  E.Status = 1 AND E.PrdId = A.PrdId AND A.CmpId = vSParam   AND E.PrdBatId=PBD.PrdBatId   AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId     Union  SELECT DISTINCT A.PrdId,100000 AS PrdSeqDtId,A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,  PBD.PrdBatDetailValue AS MRP,(D.PrdBatLcnSih-D.PrdBatLcnResSih) AS SaleableQty,A.PrdType,E.PrdBatId as BatchId   FROM  Product A WITH (NOLOCK),ProductBatchLocation D WITH (NOLOCK),ProductBatch E WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK) WHERE PrdStatus = 1   AND A.PrdId=D.PrdId AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0 AND PrdType <> 4 AND D.LcnId=vFParam   AND  A.PrdId NOT IN ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK)   WHERE B.TransactionId=2 AND B.PrdSeqId=C.PrdSeqId) AND D.PrdBatId = E.PrdBatId AND  E.Status = 1   AND E.PrdId = A.PrdId AND A.CmpId = vSParam AND E.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND PBD.BatchSeqId=BC.BatchSeqId ) a ORDER BY PrdSeqDtId'UNION
SELECT  794,'Billing','Display Product [MRP AND Saleable Qty] without Company','select','SELECT PrdId,PrdSeqDtId,  PrdDcode,PrdCcode,PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP,SaleableQty,PrdType,BatchId FROM (SELECT DISTINCT A.PrdId,C.PrdSeqDtId,  A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,  (D.PrdBatLcnSih - D.PrdBatLcnRessih) AS [SaleableQty],A.PrdType,D.PrdBatId as BatchId  FROM Product A WITH (NOLOCK),  ProductSequence B WITH (NOLOCK), ProductSeqDetails C WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK),  ProductBatchLocation D WITH (NOLOCK),  ProductBatch E WITH (NOLOCK)   WHERE B.TransactionId=2 AND A.PrdStatus=1 AND B.PrdSeqId = C.PrdSeqId   AND A.PrdId = C.PrdId AND A.PrdId=D.PrdId AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0   AND PrdType <> 4    AND D.LcnId=vFParam AND D.PrdBatId = E.PrdBatId AND  E.Status = 1 AND E.PrdId = A.PrdId   AND D.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1   AND  PBD.BatchSeqId=BC.BatchSeqId  Union SELECT DISTINCT A.PrdId,100000 AS PrdSeqDtId,A.PrdDcode,A.PrdCcode,  A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,(D.PrdBatLcnSih - D.PrdBatLcnRessih) AS SaleableQty,A.PrdType,  D.PrdBatId as BatchId  FROM  Product A WITH (NOLOCK), ProductBatchLocation D WITH (NOLOCK),   ProductBatch E WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),BatchCreation BC WITH (NOLOCK)    WHERE PrdStatus = 1  AND A.PrdId=D.PrdId AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0 AND PrdType <> 4   AND D.LcnId=vFParam  AND  A.PrdId NOT IN ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK)  WHERE B.TransactionId=2 AND B.PrdSeqId=C.PrdSeqId)   AND D.PrdBatId = E.PrdBatId AND  E.Status = 1  AND E.PrdId = A.PrdId and D.PrdBatId=PBD.PrdBatId   AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1   AND PBD.BatchSeqId=BC.BatchSeqId ) a ORDER BY PrdSeqDtId'UNION
SELECT  796,'Sales Return','WithReference Batch','select','SELECT PrdBatId,PrdbatCode,    StockType,BaseQty,PreRtnQty,CAST(PrdUnitMRP AS NUMERIC(18,2))PrdUnitMRP ,PrdUnitSelRate,PrdUom1EditedSelRate,    PrdGrossAmount,  PrdGrossAmountAftEdit,PrdNetRateDiffAmount,PriceId,SplPriceId     FROM   (Select Distinct P.PrdBatId,  P.PrdbatCode,''Saleable'' as StockType,        (S.BaseQty - isnull(S.ReturnedQty,0)) as BaseQty,  isnull(S.ReturnedQty,0) as  PreRtnQty,      S.PrdUnitMRP,S.PrdUnitSelRate,      CAST(S.PrdUom1EditedSelRate/Uom1ConvFact AS NUMERIC(18,6))  as PrdUom1EditedSelRate,      S.PrdGrossAmount,  S.PrdGrossAmountAftEdit,(S.PrdRateDiffAmount/S.BaseQty)  as PrdNetRateDiffAmount,      S.PriceId,S.SplPriceId  from ProductBatch P (NOLOCK),    SalesInvoiceProduct S  (NOLOCK)    where P.Status=1   and P.PrdBatId =S.PrdBatId   and  (S.BaseQty - isnull(S.ReturnedQty,0)) >0      and S.SalId = vFParam and  S.PrdId=vSParam    And S.Slno = vTParam    Union All      Select Distinct P.PrdBatId, P.PrdbatCode,      ''Offer'' as  StockType,      (S.SalManFreeQty - isnull(S.ReturnedManFreeQty,0))  as BaseQty,      isnull(S.ReturnedManFreeQty,0) as PreRtnQty,S.PrdUnitMRP,S.PrdUnitSelRate,      CAST(S.PrdUom1EditedSelRate/Uom1ConvFact AS NUMERIC(18,6)) as PrdUom1EditedSelRate,      S.PrdGrossAmount,S.PrdGrossAmountAftEdit,S.PrdRateDiffAmount as PrdNetRateDiffAmount,      S.PriceId,0  as SplPriceId  from ProductBatch P (NOLOCK),SalesInvoiceProduct S (NOLOCK)      where P.Status=1 and  P.PrdBatId =S.PrdBatId And  S.SalId = vFParam and  S.PrdId=vSParam      and  S.SalManFreeQty > 0  And S.Slno = vTParam) MainSql'UNION
SELECT  797,'Sales Return','WithOutReference Batch','select','SELECT PrdBatID,  PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,SellRate,PriceId,  SplPriceId  FROM   (Select A.PrdBatID,A.PrdBatCode,  B.PrdBatDetailValue as MRP,     D.PrdBatDetailValue as SellRate,A.DefaultPriceId as PriceId,  0 as SplPriceId       from ProductBatch A (NOLOCK)  INNER JOIN ProductBatchDetails B (NOLOCK)     ON A.PrdBatId = B.PrdBatID  AND B.DefaultPrice=1     INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId      AND B.SlNo = C.SlNo   AND   C.MRP = 1     INNER JOIN ProductBatchDetails D (NOLOCK)     ON A.PrdBatId = D.PrdBatID  AND D.DefaultPrice=1    INNER JOIN BatchCreation E (NOLOCK)   ON E.BatchSeqId = A.BatchSeqId    AND D.SlNo = E.SlNo   AND   E.SelRte = 1   WHERE A.PrdId=vFParam)   MainSql'UNION
SELECT  798,'Location Transfer','PrdBatCode WITHOUT MRP','select','SELECT ExpDate,PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,PrdName,MnfDate      FROM (SELECT PB.ExpDate,PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP,      PD2.PrdBatDetailValue AS PurchaseRate, PD3.PrdBatDetailValue AS SellingRate,      B.PrdName,PB.MnfDate  FROM ProductBatch PB,Product B ,      ProductbatchDetails PD1 WITH (NOLOCK),  BatchCreation BC1 WITH (NOLOCK),      ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),      ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)      WHERE PB.PrdId=B.PrdId  AND PB.Status=1   AND PB.PrdId= vFParam AND PB.PrdbatId   IN     (SELECT PrdBatId  FROM ProductBatchLocation WITH(NOLOCK)      WHERE     ((ISNULL(PrdBatLcnSih,0)-ISNULL(PrdBatLcnResSih,0)) + (ISNULL(PrdBatLcnUih,0)-ISNULL(PrdBatLcnResUih,0))    +(ISNULL(PrdBatLcnFre,0)-ISNULL(PrdBatLcnResFre,0)) ) > 0    AND LcnId = vSParam)      AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1    AND PD1.SlNo =BC1.SlNo   AND BC1.BatchSeqId=PB.BatchSeqId    AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId     AND PD2.DefaultPrice=1  AND PD2.SlNo =BC2.SlNo    AND BC2.BatchSeqId=PB.BatchSeqId   AND BC2.ListPrice=1    AND PB.PrdBatId=PD3.PrdBatId AND PD3.DefaultPrice=1      AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1)   MainSql'UNION
SELECT  799,'Order Booking','Batch Without MRP','select','SELECT PrdBatID,MnfDate,PrdBatCode,ExpDate,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,      SellRate,DefaultPriceId   FROM (SELECT A.PrdBatID,A.MnfDate,A.PrdBatCode,A.ExpDate,      B.PrdBatDetailValue as MRP,D.PrdBatDetailValue AS PurchaseRate,  F.PrdBatDetailValue AS SellRate,    A.DefaultPriceId FROM ProductBatch A (NOLOCK)   INNER JOIN ProductBatchDetails B (NOLOCK)      ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1   INNER JOIN BatchCreation C (NOLOCK)    ON C.BatchSeqId = A.BatchSeqId   AND B.SlNo = C.SlNo AND C.MRP = 1      INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID      AND D.DefaultPrice=1 INNER JOIN BatchCreation E (NOLOCK)      ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1      INNER JOIN ProductBatchDetails F (NOLOCK) ON A.PrdBatId = F.PrdBatID      AND F.DefaultPrice=1 INNER JOIN BatchCreation H (NOLOCK)      ON H.BatchSeqId = A.BatchSeqId AND F.SlNo = H.SlNo AND H.SelRte = 1      INNER JOIN Product G (NOLOCK) ON G.Prdid = A.PrdId      WHERE A.Status = 1 AND A.PrdId=vFParam) MainQry      ORDER BY PrdBatId ASC'UNION
SELECT  800,'PURCHASERECEIPT','Batch Without MRP','select','SELECT PrdBatID,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,PriceId     FROM (SELECT A.PrdBatID,A.PrdBatCode,  B.PrdBatDetailValue AS MRP,    D.PrdBatDetailValue AS PurchaseRate, F.PrdBatDetailValue AS SellingRate,    B.PriceId  FROM  ProductBatch A (NOLOCK)     INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID      AND B.DefaultPrice=1  INNER JOIN BatchCreation C (NOLOCK)     ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo  AND C.MRP = 1      INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID      AND D.DefaultPrice=1  INNER JOIN BatchCreation E (NOLOCK)     ON E.BatchSeqId = A.BatchSeqId  AND D.SlNo = E.SlNo   AND E.ListPrice = 1      INNER JOIN ProductBatchDetails F (NOLOCK) ON A.PrdBatId = F.PrdBatID      AND F.DefaultPrice=1   INNER JOIN BatchCreation G (NOLOCK)     ON G.BatchSeqId = A.BatchSeqId  AND F.SlNo = G.SlNo AND G.SelRte = 1      WHERE  A.PrdId=vFParam  AND A.Status = 1)    MainQry ORDER BY PrdBatId ASC'UNION
SELECT  801,'PURCHASERETURN','Batch Witout MRP','select','SELECT PrdBatID,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,PriceId FROM  (  SELECT A.PrdBatId,A.PrdBatCode,B.PrdBatDetailValue AS MRP,D.PrdBatDetailValue AS PurchaseRate,  F.PrdBatDetailValue AS SellingRate,B.PriceId FROM  ProductBatch A (NOLOCK)   INNER JOIN  ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1    INNER JOIN BatchCreation C (NOLOCK)ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo  AND C.MRP = 1        INNER JOIN ProductBatchDetails D (NOLOCK)ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1     INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId  AND D.SlNo = E.SlNo AND E.SelRte = 1  INNER JOIN ProductBatchDetails F (NOLOCK) ON A.PrdBatId = F.PrdBatID AND F.DefaultPrice=1     INNER JOIN BatchCreation G (NOLOCK) ON G.BatchSeqId = A.BatchSeqId AND F.SlNo = G.SlNo AND G.ListPrice = 1     WHERE  A.PrdId=vFParam AND A.Status = 1  AND A.PrdBatId IN (SELECT PrdBatId FROM ProductBatchLocation WHERE LcnId=vSParam AND PrdId=vFParam AND      ((PrdBatLcnSih+PrdBatLcnUih)-(PrdBatLcnRessih+PrdBatLcnResUih))>0)  )MainQry ORDER BY PrdBatId ASC'UNION
SELECT  802,'Salvage','Batch Without MRP','select','SELECT ExpDate,PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,  PurchaseRate,SellingRate,PrdName,MnfDate     FROM (SELECT PB.ExpDate,  PB.PrdBatId,PB.PrdBatCode,PBD1.PrdBatDetailValue AS MRP,    PBD2.PrdBatDetailValue AS PurchaseRate,  PBD3.PrdBatDetailValue AS SellingRate,    B.PrdName,PB.MnfDate   FROM ProductBatch PB WITH (NOLOCK),  Product B WITH (NOLOCK),        ProductBatchDetails PBD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),      ProductBatchDetails PBD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),    ProductBatchDetails PBD3 WITH (NOLOCK),  BatchCreation BC3 WITH (NOLOCK)        WHERE PB.PrdId=B.PrdId AND PB.PrdId=vFParam AND PB.Status=1    AND  PB.PrdBatId IN   (SELECT PrdBatId FROM Dbo.Fn_ReturnUnsaleableQty( vFParam,0,vSParam,3)  WHERE (Qty)>0)     AND PB.PrdBatId = PBD1.PrdBatId  And BC1.BatchSeqId = PB.BatchSeqId  AND PBD1.SlNo=BC1.SlNo       AND BC1.MRP=1 AND PBD1.DefaultPrice=1 AND  PB.PrdBatId = PBD2.PrdBatId       And BC2.BatchSeqId = PB.BatchSeqId  AND PBD2.SlNo=BC2.SlNo AND BC2.ListPrice=1      AND PBD2.DefaultPrice=1 AND  PB.PrdBatId = PBD3.PrdBatId And BC3.BatchSeqId = PB.BatchSeqId      AND PBD3.SlNo=BC3.SlNo AND BC3.SelRte=1 AND PBD3.DefaultPrice=1) MainQry'UNION
SELECT  803,'Stock Journal','Batch Without MRP','select','SELECT PrdId,PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,      PurchaseRate,SellingRate,DefaultPriceId FROM     (SELECT PB.PrdId, PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP,     PD2.PrdBatDetailValue AS PurchaseRate,  PD3.PrdBatDetailValue AS SellingRate,PB.DefaultPriceId      FROM Product P,ProductBatch PB (NOLOCK),  ProductbatchDetails PD1 WITH (NOLOCK),      BatchCreation BC1 WITH (NOLOCK),  ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),      ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)      WHERE P.prdId=PB.PrdId AND PB.PrdId=vFParam AND PB.Status=1      AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo      AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId      AND PD2.DefaultPrice=1  AND PD2.SlNo =BC2.SlNo AND BC2.BatchSeqId=PB.BatchSeqId      AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId AND PD3.DefaultPrice=1      AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1) MainSql'UNION
SELECT  805,'Return to Company','Batch Without MRP','select','SELECT ExpDate,PrdBatId,CAST(MRP AS NUMERIC(18,2))MRP,SellingRate,PrdBatCode,PurchaseRate,PrdName,MnfDate   FROM  (SELECT PB.ExpDate,PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP,   PD2.PrdBatDetailValue AS PurchaseRate,  PD3.PrdBatDetailValue AS SellingRate,B.PrdName,PB.MnfDate    FROM ProductBatch PB WITH (NOLOCK),Product B WITH (NOLOCK),    ProductbatchDetails PD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),    ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),    ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)    WHERE PB.PrdId=B.PrdId AND PB.PrdId=vFParam     AND PB.PrdBatId IN (SELECT PrdBatId FROM ProductBatchLocation WITH (NOLOCK)   WHERE PrdId =vFParam AND LcnId=vSParam AND (PrdBatLcnUih - PrdBatLcnResUih) > 0)     AND PB.Status=1 AND PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1    AND PD1.SlNo =BC1.SlNo AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1    AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1  AND PD2.SlNo =BC2.SlNo   AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1  AND PB.PrdBatId=PD3.PrdBatId   AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1) MainSql'UNION
SELECT  806,'Market Return','Batch Without MRP','select','SELECT PrdBatID,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,SellRate,PurchaseRate,PriceId,SplPriceId FROM        (Select A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP,D.PrdBatDetailValue as SellRate,  F.PrdBatDetailValue AS PurchaseRate,  A.DefaultPriceId AS PriceId,  0 AS SplPriceId  FROM ProductBatch A (NOLOCK)     INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1   INNER JOIN BatchCreation C (NOLOCK)   ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND  C.MRP = 1       INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1    INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo  AND  E.SelRte = 1   INNER JOIN ProductBatchDetails F (NOLOCK) ON A.PrdBatId = F.PrdBatID AND F.DefaultPrice=1    INNER JOIN BatchCreation G (NOLOCK) ON G.BatchSeqId = A.BatchSeqId AND F.SlNo = G.SlNo  AND  G.ListPrice = 1  WHERE A.PrdId=vFParam) MainSql'UNION
SELECT  807,'Resell Damage Goods','Batch Without MRP','select','SELECT PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,    PrdBatDetailValue,ExpDate,PriceId      FROM (SELECT PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP,   PD2.PrdBatDetailValue AS PurchaseRate,PD3.PrdBatDetailValue,    PB.ExpDate,PD1.PriceId  FROM ProductBatch PB WITH (NOLOCK) ,   ProductbatchDetails PD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),  ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),   ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK),   ProductBatchLocation PBL WITH (NOLOCK)   WHERE  PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1   AND  PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1 AND   PB.PrdBatId=PD3.PrdBatId  AND PD3.DefaultPrice=1    AND PB.PrdId=vFParam AND PB.Status=1    AND PD1.SlNo =BC1.SlNo   AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.Mrp=1   AND PD2.SlNo =BC2.SlNo  AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1   AND PD3.SlNo =BC3.SlNo    AND BC3.BatchSeqId=PB.BatchSeqId AND BC3.SelRte=1   AND PBL.LcnId =vSParam    AND PBL.PrdId = PB.PrdId AND PBL.PrdBatId = PB.PrdBatId   AND ((PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih))>0) MainQry'UNION
SELECT  808,'Return And Replacement','Batch Without MRP','select','SELECT DISTINCT PrdBatId,PrdBatCode,SellingRate,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,DefaultPriceId FROM(SELECT DISTINCT PB.PrdBatId,PB.PrdBatCode,PBD1.PrdBatDetailValue AS MRP,  PBD2.PrdBatDetailValue AS PurchaseRate,PBD3.PrdBatDetailValue AS SellingRate,PB.DefaultPriceId  FROM ProductBatch PB WITH (NOLOCK),  ProductBatchDetails PBD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),ProductBatchDetails PBD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),  ProductBatchDetails PBD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK),ProductBatchLocation PBL WITH (NOLOCK)   WHERE PB.PrdBatId = PBD1.PrdBatId AND BC1.BatchSeqId = PB.BatchSeqId AND PB.PrdBatId = PBL.PrdBatID AND (PrdBatLcnSih - PrdBatLcnRessih) > 0       AND PBD1.SlNo=BC1.SlNo AND BC1.MRP=1 AND PBD1.DefaultPrice=1 AND PB.PrdBatId = PBD2.PrdBatId  And BC2.BatchSeqId = PB.BatchSeqId AND PBD2.SlNo=BC2.SlNo   AND BC2.ListPrice=1 AND PBD2.DefaultPrice=1 AND PB.PrdBatId = PBD3.PrdBatId And BC3.BatchSeqId = PB.BatchSeqId AND PBD3.SlNo=BC3.SlNo   AND BC3.SelRte=1 AND PBD3.DefaultPrice=1 AND PB.PrdId =vFParam AND PB.Status=1) MainQry'UNION
SELECT  809,'Return And Replacement','Batch Without MRP','select','SELECT PrdBatId,CAST(MRP AS NUMERIC(18,2))MRP,PrdBatCode,SellingRate,PurchaseRate,DefaultPriceId  FROM     (SELECT PB.PrdBatId,PB.PrdBatCode,PBD1.PrdBatDetailValue AS MRP,    PBD2.PrdBatDetailValue AS PurchaseRate,    PBD3.PrdBatDetailValue AS SellingRate,PB.DefaultPriceId      FROM ProductBatch PB WITH (NOLOCK),    ProductBatchDetails PBD1 WITH (NOLOCK),      BatchCreation BC1 WITH (NOLOCK)   ,   ProductBatchDetails PBD2 WITH (NOLOCK),      BatchCreation BC2 WITH (NOLOCK)   ,   ProductBatchDetails PBD3 WITH (NOLOCK),      BatchCreation BC3 WITH (NOLOCK)    Where PB.PrdBatId = PBD1.PrdBatId    And BC1.BatchSeqId = PB.BatchSeqId  AND PBD1.SlNo=BC1.SlNo AND BC1.MRP=1  AND PBD1.DefaultPrice=1  AND  PB.PrdBatId = PBD2.PrdBatId And BC2.BatchSeqId = PB.BatchSeqId  AND PBD2.SlNo=BC2.SlNo  AND BC2.ListPrice=1 AND PBD2.DefaultPrice=1  AND  PB.PrdBatId = PBD3.PrdBatId And BC3.BatchSeqId = PB.BatchSeqId      AND PBD3.SlNo=BC3.SlNo AND BC3.SelRte=1 AND PBD3.DefaultPrice=1      AND PB.PrdId =vFParam)MainQry'UNION
SELECT  810,'Billing','Batch Without MRP','select','SELECT PrdBatID,CAST(MRP AS NUMERIC(18,2))MRP,PrdBatCode,PurchaseRate,SellRate,PriceId,ShelfDay,ExpiryDay   FROM( SELECT A.PrdBatID,A.PrdBatCode,F.PrdBatDetailValue AS SellRate,B.PrdBatDetailValue AS MRP,   D.PrdBatDetailValue AS PurchaseRate,B.PriceId,DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),  DATEADD(Day,Prd.PrdShelfLife,A.MnfDate)) as ShelfDay,DATEDIFF(DAY,Convert(Varchar(10),Getdate(),121),A.ExpDate) as ExpiryDay    FROM  ProductBatch A (NOLOCK)   INNER JOIN Product Prd  (NOLOCK) ON A.PrdId = Prd.PrdId     INNER JOIN ProductBatchDetails B    (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1     INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId   AND B.SlNo = C.SlNo AND C.MRP = 1     INNER JOIN ProductBatchDetails D  (NOLOCK)  ON A.PrdBatId = D.PrdBatID   AND D.DefaultPrice=1     INNER JOIN BatchCreation E (NOLOCK)    ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1     INNER JOIN ProductBatchDetails F (NOLOCK)  ON A.PrdBatId = F.PrdBatID AND F.DefaultPrice=1     INNER JOIN BatchCreation G (NOLOCK)  ON G.BatchSeqId = A.BatchSeqId   AND F.SlNo = G.SlNo  AND G.SelRte = 1    INNER JOIN ProductBatchLocation PBL (NOLOCK) ON A.PrdId=PBL.PrdId AND A.PrdBatId=PBL.PrdBatId AND (PBL.PrdBatLcnSih-PBL.PrdbatLcnResSih)>0     WHERE  A.PrdId=vFParam  AND A.Status = 1  )   MainQry order by PrdBatId ASC'UNION
SELECT  811,'Stock Management','Batch Without MRP','select','SELECT PrdBatId,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,ExpDate,PrdName,MnfDate      FROM (SELECT PB.PrdBatId,PB.PrdBatCode,PD1.PrdBatDetailValue AS MRP, PD2.PrdBatDetailValue AS PurchaseRate,      PD3.PrdBatDetailValue AS SellingRate,PB.ExpDate,B.PrdName,PB.MnfDate FROM ProductBatch PB WITH (NOLOCK),      Product B WITH (NOLOCK) ,  ProductbatchDetails PD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),      ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),  ProductbatchDetails PD3 WITH (NOLOCK),      BatchCreation BC3 WITH (NOLOCK)  WHERE B.PrdStatus = 1 AND PB.Status = 1       AND PB.PrdId=B.PrdId  AND PB.PrdId= vFParam AND  PB.PrdBatId=PD1.PrdBatId AND PD1.DefaultPrice=1      AND PD1.SlNo =BC1.SlNo  AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1  AND PB.PrdBatId=PD2.PrdBatId     AND PD2.DefaultPrice=1  AND PD2.SlNo =BC2.SlNo AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1      AND PB.PrdBatId=PD3.PrdBatId  AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId     AND BC3.SelRte=1) MainSql  ORDER BY PrdBatId ASC'UNION
SELECT  818,'SampleMaintenance','BatchWorSaleable','Select','SELECT PrdBatID,PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellingRate,PriceId FROM (SELECT A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP,  D.PrdBatDetailValue AS PurchaseRate,F.PrdBatDetailValue AS SellingRate,B.PriceId FROM  ProductBatch A (NOLOCK) INNER JOIN ProductBatchDetails B (NOLOCK)      ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 INNER JOIN BatchCreation C (NOLOCK)ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1    INNER JOIN ProductBatchDetails D (NOLOCK)ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 INNER JOIN BatchCreation E (NOLOCK)  ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1 INNER JOIN ProductBatchDetails F (NOLOCK) ON A.PrdBatId = F.PrdBatID   AND F.DefaultPrice=1 INNER JOIN BatchCreation G (NOLOCK) ON G.BatchSeqId = A.BatchSeqId AND F.SlNo = G.SlNo AND G.SelRte = 1   INNER JOIN ProductBatchLocation PBL ON PBL.PrdBatID=A.PrdBatId WHERE  A.PrdId=vFParam AND A.Status = 1   AND ((PrdBatLcnSih-PrdBatLcnRessih)+(PrdBatLcnUih-PrdBatLcnResUih)+(PrdBatLcnFre-PrdBatLcnResFre))> 0)MainQry order by PrdBatId ASC'UNION
SELECT  10077,'IDT Managemnet','Product','Select','SELECT PrdId,PrdSeqDtId,  PrdDCode,PrdCcode,PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP,PrdType FROM (SELECT DISTINCT A.PrdId,C.PrdSeqDtId,  A.PrdDcode,A.PrdCcode,A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,  A.PrdType FROM Product A WITH (NOLOCK),   ProductSequence B WITH (NOLOCK),   ProductSeqDetails C WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),      BatchCreation BC WITH (NOLOCK),  ProductBatchLocation D WITH (NOLOCK),    ProductBatch E WITH (NOLOCK)      WHERE B.TransactionId = 270 AND A.PrdStatus=1   AND B.PrdSeqId = C.PrdSeqId  AND A.PrdId = C.PrdId     AND A.PrdId=D.PrdId   AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0  AND PrdType <> 4 AND D.LcnId=vFParam     AND D.PrdBatId = E.PrdBatId AND  E.Status = 1 AND E.PrdId = A.PrdId      AND D.PrdBatId=PBD.PrdBatId   AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1     AND  PBD.BatchSeqId=BC.BatchSeqId    Union      SELECT DISTINCT A.PrdId,100000 AS PrdSeqDtId,A.PrdDcode,A.PrdCcode,    A.PrdName,A.PrdShrtName,PBD.PrdBatDetailValue AS MRP,A.PrdType      FROM  Product A WITH (NOLOCK),ProductBatchLocation D WITH (NOLOCK), ProductBatch E WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK),  BatchCreation BC WITH (NOLOCK)  WHERE PrdStatus = 1    AND A.PrdId=D.PrdId   AND (D.PrdBatLcnSih-D.PrdBatLcnResSih)>0   AND PrdType <> 4    AND D.LcnId=vFParam    AND    A.PrdId NOT IN ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),   ProductSeqDetails C WITH (NOLOCK)      WHERE B.TransactionId=270 AND B.PrdSeqId=C.PrdSeqId)      AND D.PrdBatId = E.PrdBatId AND  E.Status = 1    AND E.PrdId = A.PrdId      and D.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo       AND BC.MRP=1 AND  PBD.BatchSeqId=BC.BatchSeqId )  a ORDER BY PrdSeqDtId'UNION
SELECT  10078,'IDT Managemnet','IDT In Product','Select','SELECT distinct PrdId,PrdSeqDtId,PrdDcode,PrdCcode,  PrdName,PrdShrtName,CAST(MRP AS NUMERIC(18,2))MRP,PrdType FROM (SELECT distinct A.PrdId,C.PrdSeqDtId,A.PrdDcode,A.PrdCcode,A.PrdName,  A.PrdShrtName,PBD.PrdBatDetailValue AS MRP ,A.PrdType FROM Product A WITH(NOLOCK),    ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK),ProductBatch PB WITH (NOLOCK),    ProductBatchDetails PBD WITH (NOLOCK),  BatchCreation BC WITH (NOLOCK) WHERE B.TransactionId=270  AND A.PrdStatus=1 AND PB.PrdBatId=PBD.PrdBatId    AND PBD.DefaultPrice=1 AND PBD.SlNo=BC.SlNo AND BC.MRP=1   AND PBD.BatchSeqId=BC.BatchSeqId AND A.PrdId = PB.PrdId   AND A.PrdType <> 3  AND B.PrdSeqId = C.PrdSeqId   AND A.PrdId = C.PrdId UNION SELECT distinct A.PrdId,100000 AS PrdSeqDtId,A.PrdDcode,PrdCcode,PrdName,PrdShrtName,  PBD.PrdBatDetailValue AS MRP,A.PrdType FROM Product A WITH (NOLOCK), ProductBatch PB WITH (NOLOCK),  ProductBatchDetails PBD WITH (NOLOCK), BatchCreation BC WITH (NOLOCK)     WHERE PrdStatus = 1 AND PrdType <> 3 and A.PrdId NOT IN ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),    ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=270 AND B.PrdSeqId=C.PrdSeqId)     AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1   AND PBD.SlNo=BC.SlNo AND BC.MRP=1      AND PBD.BatchSeqId=BC.BatchSeqId AND A.PrdId = PB.PrdId) MainSql ORDER BY PrdSeqDtId'UNION
SELECT  10079,'IDT Managemnet','ProductBatch','Select','SELECT PrdBatID,PrdBatCode,  CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellRate,PriceId,AvailStock FROM   (SELECT A.PrdBatID,A.PrdBatCode,  F.PrdBatDetailValue AS SellRate, B.PrdBatDetailValue AS MRP,  D.PrdBatDetailValue AS PurchaseRate,B.PriceId,  (PBL.PrdBatLcnSih-PBL.PrdbatLcnResSih) as AvailStock  FROM  ProductBatch A (NOLOCK)     INNER JOIN ProductBatchDetails B  (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1    INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId   AND B.SlNo = C.SlNo AND C.MRP = 1   INNER JOIN ProductBatchDetails D  (NOLOCK)  ON A.PrdBatId = D.PrdBatID   AND D.DefaultPrice=1     INNER JOIN BatchCreation E (NOLOCK)    ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1      INNER JOIN ProductBatchDetails F (NOLOCK)  ON A.PrdBatId = F.PrdBatID AND F.DefaultPrice=1    INNER JOIN BatchCreation G (NOLOCK)  ON G.BatchSeqId = A.BatchSeqId   AND F.SlNo = G.SlNo  AND G.SelRte = 1    INNER JOIN ProductBatchLocation PBL (NOLOCK) ON A.PrdId=PBL.PrdId   AND A.PrdBatId=PBL.PrdBatId AND (PBL.PrdBatLcnSih-PBL.PrdbatLcnResSih)>0  WHERE  A.PrdId=vFParam  AND A.Status = 1  ) MainQry order by PrdBatId ASC'UNION
SELECT  10080,'IDT Managemnet','IDT In Product Batch','Select','SELECT PrdBatID,PrdBatCode,  CAST(MRP AS NUMERIC(18,2))MRP,PurchaseRate,SellRate,PriceId,AvailStock FROM (SELECT A.PrdBatID,A.PrdBatCode,F.PrdBatDetailValue AS SellRate,   B.PrdBatDetailValue AS MRP,  D.PrdBatDetailValue AS PurchaseRate,B.PriceId,    0 as AvailStock  FROM  ProductBatch A (NOLOCK)       INNER JOIN ProductBatchDetails B  (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1      INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId   AND B.SlNo = C.SlNo AND C.MRP = 1     INNER JOIN ProductBatchDetails D  (NOLOCK)  ON A.PrdBatId = D.PrdBatID   AND D.DefaultPrice=1       INNER JOIN BatchCreation E (NOLOCK)    ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1        INNER JOIN ProductBatchDetails F (NOLOCK)  ON A.PrdBatId = F.PrdBatID AND F.DefaultPrice=1      INNER JOIN BatchCreation G (NOLOCK)  ON G.BatchSeqId = A.BatchSeqId   AND F.SlNo = G.SlNo    AND G.SelRte = 1    WHERE  A.PrdId=vFParam  AND A.Status = 1  ) MainQry order by PrdBatId ASC'UNION
SELECT  10090,'Sales Return','WithReference WithoutBill Batch','select','SELECT PrdBatID,  PrdBatCode,CAST(MRP AS NUMERIC(18,2))MRP,SellRate,PriceId,  SplPriceId  FROM     (Select A.PrdBatID,A.PrdBatCode,  B.PrdBatDetailValue as MRP,     D.PrdBatDetailValue as SellRate,A.DefaultPriceId as PriceId,    0 as SplPriceId       from ProductBatch A (NOLOCK)  INNER JOIN ProductBatchDetails B (NOLOCK)       ON A.PrdBatId = B.PrdBatID  AND B.DefaultPrice=1     INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId        AND B.SlNo = C.SlNo   AND   C.MRP = 1     INNER JOIN ProductBatchDetails D (NOLOCK)       ON A.PrdBatId = D.PrdBatID  AND D.DefaultPrice=1      INNER JOIN BatchCreation E (NOLOCK)   ON E.BatchSeqId = A.BatchSeqId      AND D.SlNo = E.SlNo   AND   E.SelRte = 1   WHERE A.PrdId=vFParam)   MainSql'
GO
DELETE FROM Configuration WHERE ModuleId IN ('GENCONFIG3','GENCONFIG28')
INSERT INTO Configuration(ModuleId,ModuleName,[Description],[Status],Condition,ConfigValue,SeqNo) 
SELECT 'GENCONFIG3','General Configuration','Display Dash Board while opening the application',1,'',0.00,3 UNION
SELECT 'GENCONFIG28','General Configuration','Show Dash Board',1,'',0.00,28
GO
IF NOT EXISTS (SELECT FixId FROM UpdaterLog (NOLOCK) WHERE FixId = 20150317)
BEGIN
	DELETE A FROM ETLTempPurchaseReceiptOtherCharges A (NOLOCK)
	DELETE A FROM ETLTempPurchaseReceiptPrdLineDt A (NOLOCK)
	DELETE A FROM ETLTempPurchaseReceiptProduct A (NOLOCK)
	DELETE A FROM ETLTempPurchaseReceiptClaimScheme A (NOLOCK)
	DELETE A FROM ETLTempPurchaseReceiptCrDbAdjustments A (NOLOCK)
	DELETE A FROM ETLTempPurchaseReceipt A (NOLOCK)
	
	INSERT INTO UpdaterLog (FixId,ReleaseOn,UpdateDate)
	SELECT 20150317,'2015-03-17',GETDATE()
END
GO
UPDATE UtilityProcess SET VersionId = '3.1.0.2' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.2',421
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE FixId = 421)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(421,'D','2015-03-20',GETDATE(),1,'Core Stocky Service Pack 421')