--[Stocky HotFix Version]=397
DELETE FROM Versioncontrol WHERE Hotfixid='397'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('397','2.0.0.5','D','2011-12-29','2011-12-29','2011-12-29',convert(varchar(11),getdate()),'JNJ-Major: Product Release Dec CR')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 397' ,'397'
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE [Name]='Proc_GR_SchemeListing')
DROP PROCEDURE Proc_GR_SchemeListing
GO
--EXEC Proc_GR_SchemeListing 'Scheme Listing','2011/09/15','2011/12/30','','','','','',''
CREATE PROCEDURE Proc_GR_SchemeListing
(
		@Pi_RptName		NVARCHAR(100),
		@Pi_FromDate	DATETIME,
		@Pi_ToDate		DATETIME,
		@Pi_Filter1		NVARCHAR(100),
		@Pi_Filter2		NVARCHAR(100),
		@Pi_Filter3		NVARCHAR(100),
		@Pi_Filter4		NVARCHAR(100),
		@Pi_Filter5		NVARCHAR(100),
		@Pi_Filter6		NVARCHAR(100)
)
AS 
/*********************************
* PROCEDURE		: Proc_GR_SchemeListing
* PURPOSE		: To Show Scheme Details in Dynamic Reports 
* CREATED BY	: Shyam
* CREATED DATE	: 
* NOTE			: 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 03/01/2011	Nanda		 Added Scheme Points Column
*********************************/
BEGIN
	SET @Pi_FILTER1='%'+ISNULL(@Pi_FILTER1,'')+'%'        
	SET @Pi_FILTER2='%'+ISNULL(@Pi_FILTER2,'')+'%'        
	SET @Pi_FILTER3='%'+ISNULL(@Pi_FILTER3,'')+'%'        
	SET @Pi_FILTER4='%'+ISNULL(@Pi_FILTER4,'')+'%'        
	SET @Pi_FILTER5='%'+ISNULL(@Pi_FILTER5,'')+'%'  
	SET @Pi_FILTER6='%'+ISNULL(@Pi_FILTER5,'')+'%'      
	SELECT SchCode [Scheme Code],SCHDSC [Scheme Desc],CMPSchCode [Company Scheme Code],SchValidFrom [Scheme Valid From],SchValidTill [Scheme Valid Till],
	CASE SchStatus WHEN 1 THEN 'Active' ELSE 'Inactive' END [Status],
	CASE Claimable WHEN 1 THEN 'Yes' ELSE 'No' END [Claimable],
	Budget
	INTO #Scheme FROM SchemeMaster 
	WHERE SchValidFrom BETWEEN @Pi_FromDate AND @Pi_ToDate 
	OR SchValidTill BETWEEN @Pi_FromDate AND @Pi_ToDate
	SELECT *,CAST(0 AS NUMERIC(18,2)) AS Utilized,CAST(0 AS NUMERIC(18,2)) AS Balance 
	INTO #SchFinal 
	FROM #Scheme WHERE [Scheme Code] LIKE @Pi_FILTER1 AND [Scheme Desc] LIKE @Pi_FILTER2 
	SELECT SchId INTO #Filter FROM SchemeMaster 
	WHERE SchCode IN (SELECT [Scheme Code] FROM #SchFinal)
	---------------------------POPULATING THE Scheme Utilized------------------------------------------------------
	SELECT SchId,SUM(Amt)Amt, 0 AS Points INTO #Schutilised FROM (
	 SELECT A.SchId,(ISNULL(SUM(CAST(FlatAmount AS NUMERIC(18,2)) - CAST(ReturnFlatAmount AS NUMERIC(18,2))),0) + 
     ISNULL(SUM(CAST(DiscountPerAmount AS NUMERIC(18,2)) - CAST(ReturnDiscountPerAmount AS NUMERIC(18,2))),0)) Amt
	 FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
 	 WHERE DlvSts <> 3 AND A.Schid IN (SELECT SchId FROM #Filter) GROUP BY A.SchId 
     UNION ALL 
	 SELECT A.SchId,SUM(CrnoteAmount)Amt from SalesInvoiceQPSSchemeAdj A inner join Salesinvoice SI on A.Salid=SI.Salid
	 WHERE SI.DlvSts in(4,5) AND A.Schid IN (SELECT SchId FROM #Filter) GROUP BY A.SchId ) A GROUP BY A.Schid
	UNION ALL 
	SELECT SchId, ISNULL(SUM((FreeQty - ReturnFreeQty) * D.PrdBatDetailValue),0.000) A, 0 AS Points
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
			ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY SchId
	UNION ALL 
	SELECT SchId, ISNULL(SUM((GiftQty - ReturnGiftQty) * D.PrdBatDetailValue),0) , 0 AS Points
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
			ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY SchId
	UNION ALL 
	SELECT SchId, ISNULL(SUM(AdjAmt),0.0000), 0 AS Points FROM SalesInvoiceWindowDisplay A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		WHERE  DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY SchId
	UNION ALL 
	SELECT TransId, ISNULL(SUM(Amount),0.0000), 0 AS Points FROM ChequeDisbursalMaster A 
		INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo 
		WHERE TransType = 1 AND TransId IN (SELECT SchId FROM #Filter) GROUP BY TransId
	--->Added By Nanda on 03/01/2011
	UNION ALL
	SELECT SchId,0 AS Amt,0 AS Points 	
		FROM SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY SchId
	--->Till Here
	SELECT SchCode,SUM(Amt) Amount 
	INTO #SchComp FROM #Schutilised a,SchemeMaster b 
	WHERE a.SchId=b.SchId GROUP BY SchCode
	----------------------------------------------------------------------------------------------------------------------
	---------------------------POPULATING THE Scheme Utilized------------------------------------------------------
	SELECT B.RtrId,B.SalId,SchId,A.PrdId,A.PrdBatId,PrdUnitMRP MRP,(ISNULL(SUM(CAST(FlatAmount AS NUMERIC(18,2)) - 
	CAST(ReturnFlatAmount AS NUMERIC(18,2))),0.000000000) + ISNULL(SUM(CAST(DiscountPerAmount AS NUMERIC(18,2)) - 
	CAST(ReturnDiscountPerAmount AS NUMERIC(18,2))),0.000000000)) Amt,0 AS Points  
	INTO #SchUtilizedDetail
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.SlNo
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY B.RtrId,b.SalId,SchId,A.PrdId,A.PrdBatId,PrdUnitMRP
	UNION ALL 
	SELECT B.RtrId,B.SalId,SchId,FreePrdId,FreePrdBatId,0, ISNULL(SUM((FreeQty - ReturnFreeQty) * D.PrdBatDetailValue),0.0000) A,0 AS Points  
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
			ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY B.RtrId,b.SalId,SchId,FreePrdId,FreePrdBatId
	UNION ALL 
	SELECT B.RtrId,B.SalId,SchId,GIFTPrdId,GIFTPrdBatId,0, ISNULL(SUM((GiftQty - ReturnGiftQty) * D.PrdBatDetailValue),0.0000),0 AS Points   
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
			ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY B.RtrId,b.SalId,SchId,GIFTPrdId,GIFTPrdBatId
	UNION ALL
	SELECT B.RtrId,B.SalId,SchId,0,0,0, ISNULL(SUM(AdjAmt),0.000),0 AS Points   FROM SalesInvoiceWindowDisplay A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		WHERE  DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY B.RtrId,b.SalId,SchId
	--->Added By Nanda on 03/01/2011
	UNION ALL 
	SELECT B.RtrId,B.SalId,SchId,PrdId,PrdBatId,0,0 AS Amt,ISNULL(SUM(Points-ReturnPoints),0) AS Points  
		FROM SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoice B ON A.SalId = B.SalId		
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY B.RtrId,b.SalId,SchId,PrdId,PrdBatId
	--->Till Here
	SELECT SchCode [Scheme Code],sCHDSC [Scheme Description],CASE Download WHEN 1 THEN CmpSchCode WHEN 0 THEN CASE WHEN Len(Ltrim(Rtrim(CmpSchCode)))=0
	THEN '' ELSE CmpSchCode+ '(*)' END END 
  AS  [Company SchemeCode],Hierarchy3cap [Retailer Hierarchy 1],
	Hierarchy2Cap [Retailer Hierarchy 2],Hierarchy1cap [Retailer Hierarchy 3], c.RtrCode [Retailer Code],RtrName [Retailer Name],Salinvno [Sales Invoice No.],
	CONVERT(VARCHAR(10),SalinvDate,121) [Sales Invoice Date],PrdcCode [Company Prd. Code],PrdName [Product Name],
	PrdDCode [Dist. Prd. Code],MRP,SUM(CAST(Amt AS NUMERIC(18,6))) [Scheme Amount],SUM(CAST(Points AS NUMERIC(18,0))) AS [Points]
	INTO #SchComp2 
	FROM #SchUtilizedDetail a,SchemeMaster b,Retailer C,SalesInvoice D,Product e ,Tbl_Gr_Build_Rh f
	WHERE 
	a.SchId=b.SchId  
	AND D.SalId=A.SalId 
	AND C.RtrId=A.RtrId
	and a.PrdId = e.PrdId
	and f.RtrId=d.RtrId and a.PrdId>0
	GROUP BY  Download,SchCode ,sCHDSC ,CmpSchCode,Hierarchy1cap ,
	Hierarchy2Cap ,Hierarchy3cap , c.RtrCode ,RtrName ,Salinvno,
	CONVERT(VARCHAR(10),SalinvDate,121) ,PrdcCode ,PrdName ,PrdDCode ,MRP
	HAVING SUM(CAST(Amt AS NUMERIC(18,6)))+SUM(CAST(Points AS NUMERIC(18,0)))>0
	UNION ALL
	SELECT SchCode [Scheme Code],sCHDSC [Scheme Description],CASE Download WHEN 1 THEN CmpSchCode WHEN 0 THEN CASE WHEN Len(Ltrim(Rtrim(CmpSchCode)))=0
	THEN '' ELSE CmpSchCode+ '(*)' END END AS  [Company SchemeCode] ,Hierarchy3cap [Retailer Hierarchy 1],
	Hierarchy2Cap [Retailer Hierarchy 2],Hierarchy1cap [Retailer Hierarchy 3], c.RtrCode [Retailer Code],RtrName [Retailer Name],Salinvno [Sales Invoice No.],
	CONVERT(VARCHAR(10),SalinvDate,121) [Sales Invoice Date],'','Window Display','' ,0,SUM(Amt) [Scheme Amount],0 AS [Points]
	FROM #SchUtilizedDetail a,SchemeMaster b,Retailer C,SalesInvoice D,Tbl_Gr_Build_Rh f
	WHERE 
	a.SchId=b.SchId  
	AND D.SalId=A.SalId 
	AND C.RtrId=A.RtrId
	and f.RtrId=d.RtrId and a.PrdId=0 AND Amt>0
	GROUP BY  SchCode ,sCHDSC ,CmpSchCode,Hierarchy1cap ,Download,
	Hierarchy2Cap ,Hierarchy3cap , c.RtrCode ,RtrName ,Salinvno,
	CONVERT(VARCHAR(10),SalinvDate,121) 
	----------------------------------------------------------------------------------------------------------------------
	UPDATE #SchFinal SET Utilized=Amount
	FROM #SchFinal,#SchComp WHERE [Scheme Code]=SchCode --AND Budget<>0
	UPDATE #SchFinal SET Balance=Budget-Utilized 
	WHERE Budget<>0
	SELECT 'Scheme Listing',* FROM #SchFinal	
	SELECT 'Detail Listing',* FROM #SchComp2
END
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='U' AND [Name]='RptCurrentStockWithUom')
DROP TABLE RptCurrentStockWithUom 
GO
CREATE TABLE RptCurrentStockWithUom
	(
	[LCNID] [int] NULL,
	[LCNNAME] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PRDID] [int] NULL,
	[PrdCcode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PRDDCODE] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PRDNAME] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PRDBATID] [int] NULL,
	[PRDBATCODE] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MRP] [numeric](36, 6) NULL,
	[SELLINGRATE] [numeric](36, 6) NULL,
	[LISTPRICE] [numeric](36, 6) NULL,
	[SalMRP] [numeric](36, 6) NULL,
	[SalSelRate] [numeric](36, 6) NULL,
	[SalListPrc] [numeric](36, 6) NULL,
	[UNMRP] [numeric](36, 6) NULL,
	[UNSelRate] [numeric](36, 6) NULL,
	[UNListPrc] [numeric](36, 6) NULL,
	[TOTMRP] [numeric](36, 6) NULL,
	[TOTSelRate] [numeric](36, 6) NULL,
	[TOTListPrc] [numeric](36, 6) NULL,
	[STOCKONHAND] [int] NULL,
	[UOMID] [int] NULL,
	[UOMCODE] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CONVERSIONFACTOR] [int] NULL,
	[STOCKINGTYPE] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ORDERID] [int] NULL,
	[UOMCONVERTEDQTY] [int] NULL,
	[PrdStatus] [int] NULL,
	[Status] [int] NULL,
	[CmpId] [int] NULL,
	[PrdCtgValMainId] [int] NULL,
	[CmpPrdCtgId] [int] NULL,
	[PrdCtgValLinkCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	) ON [PRIMARY]

GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_CurrentStockReportUOMBASED')
DROP PROCEDURE Proc_CurrentStockReportUOMBASED 
GO
-- EXEC Proc_CurrentStockReportUOMBASED 5,1
CREATE PROCEDURE Proc_CurrentStockReportUOMBASED    
/************************************************************
* VIEW	: Proc_CurrentStockReportUOMBASED
* PURPOSE	: To get the Current Stock of the Products with Batch details (With Out Tax)
* CREATED BY	: MURUGAN.R
* CREATED DATE	: 01/09/2009
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
(
	@Pi_RptId AS INT,
	@Pi_UsrId AS INT
)
AS
BEGIN
	CREATE TABLE #RptCurrentStockWithUomTemp
	(
		LCNID INT,
		LCNNAME VARCHAR(100),
		PRDID INT,
		PrdCcode VARCHAR(100),
		PRDDCODE VARCHAR(100),
		PRDNAME VARCHAR(150),
		PRDBATID INT,
		PRDBATCODE VARCHAR(150),
		MRP NUMERIC(36,6),
		SELLINGRATE NUMERIC(36,6),
		LISTPRICE NUMERIC(36,6),
		[SalMRP] NUMERIC(36,6),
		[SalSelRate] NUMERIC(36,6),
		[SalListPrc] NUMERIC(36,6),
		[UNMRP] NUMERIC(36,6),
		[UNSelRate] NUMERIC(36,6),
		[UNListPrc] NUMERIC(36,6),
		[TOTMRP] NUMERIC(36,6),
		[TOTSelRate] NUMERIC(36,6),
		[TOTListPrc] NUMERIC(36,6),
		STOCKONHAND INT,
		UOMID INT,
		UOMCODE VARCHAR(50),
		CONVERSIONFACTOR INT,
		STOCKINGTYPE VARCHAR(50),
		ORDERID INT,
		UOMCONVERTEDQTY INT,
		PrdStatus INT,
		Status INT,
		CmpId INT, 
		PrdCtgValMainId INT,
		CmpPrdCtgId INT,
		PrdCtgValLinkCode VarChar(100)
	)
	DECLARE @SupZeroStock AS INT
	DECLARE @DispBatch AS INT
	DECLARE @CmpId AS INT
	DECLARE @LcnId AS INT
	DECLARE @PrdStatus AS INT
	DECLARE @PrdBatStatus AS INT
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	SET @DispBatch = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
	SET @PrdBatStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))
	
	PRINT 'start'
	--SET @DispBatch=2
	PRINT @SupZeroStock
	PRINT @CmpId
	PRINT @LcnId
	PRINT @PrdStatus
	PRINT @PrdBatStatus
	PRINT @DispBatch
	PRINT 'End'
	TRUNCATE TABLE RptCurrentStockWithUom
	IF (@DispBatch=1)
	BEGIN
		INSERT INTO #RptCurrentStockWithUomTemp
		(LCNID,LCNNAME,PRDID,PrdCcode,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
		[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
		,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
		,CmpPrdCtgId,PrdCtgValLinkCode)
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP)  AS [SalMRP],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate))  AS [SalSelRate],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate))  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Saleable' as StockingType,
			1 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid	
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
			Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
			Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
			Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
			Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
		GROUP BY  PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
		PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status	 			
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			0   AS [SalMRP],
			0  AS [SalSelRate],
			0 AS [SalListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP)   AS [UNMRP],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate))  AS [UNSelRate],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate)) AS [UNListPrc],
			0   AS [TOTMRP],
			0  AS [TOTSelRate],
			0 AS [TOTListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Unsaleable' as StockingType,
			2 as OrderId,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode 
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 
		GROUP BY  PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
			PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status		
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			0  AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0 AS [TOTSelRate],
			0 AS [TOTListPrc],	
			SUM((PrdBatLcnFre-PrdBatLcnResFre)) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Offer' as StockingType,
			3 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 	
		GROUP BY  PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
			PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status	
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			0  AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ))   AS [TOTMRP],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate)))  AS [TOTSelRate],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate) )) AS [TOTListPrc],
			SUM(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
			(PrdBatLcnFre-PrdBatLcnResFre))) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Total StockOnHand' as StockingType,
			4 as OrderId,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode 
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 
			GROUP BY  PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
				PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status	
	END	
	ELSE IF @DispBatch=2
	BEGIN
			INSERT INTO #RptCurrentStockWithUomTemp
			(LCNID,LCNNAME,PRDID,PrdCcode,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
			[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
			,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
			,CmpPrdCtgId,PrdCtgValLinkCode)
			SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP)  AS [SalMRP],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate))  AS [SalSelRate],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate))  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Saleable' as StockingType,
			1 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 	
					
			GROUP BY PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			0 AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP )  AS [UNMRP],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate))  AS [UNSelRate],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate)) AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'UnSaleable' as StockingType,
			2 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))	
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 			
			GROUP BY PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			0 AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnFre-PrdBatLcnResFre)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Offer' as StockingType,
			3 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 				
			GROUP BY PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			0 AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ) )  AS [TOTMRP],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate)))  AS [TOTSelRate],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate) )) AS [TOTListPrc],
			SUM(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
			(PrdBatLcnFre-PrdBatLcnResFre))) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Total StockOnHand' as StockingType,
			4 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 	
			GROUP BY PrdBatLcn.PrdId,Prd.PrdCcode,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR	
	
	END
--
--		SELECT * FROM #RptCurrentStockWithUomTemp
--	
--return	
		IF @SupZeroStock=1
		BEGIN
			INSERT INTO RptCurrentStockWithUom
			(LCNID,LCNNAME,PRDID,PrdCcode,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
			[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
			,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
			,CmpPrdCtgId,PrdCtgValLinkCode) SELECT * FROM #RptCurrentStockWithUomTemp WHERE STOCKONHAND>0
		END
		ELSE
		BEGIN
			INSERT INTO RptCurrentStockWithUom
			(LCNID,LCNNAME,PRDID,PrdCcode,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
			[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
			,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
			,CmpPrdCtgId,PrdCtgValLinkCode) SELECT * FROM #RptCurrentStockWithUomTemp WHERE STOCKONHAND>=0
		END
		
		
		Select Prdid,Prdbatid,Lcnid,[SalMRP],[SalSelRate],[SalListPrc]
		INTO #RptCurrentStockWithUom FROM RptCurrentStockWithUom WHERE ORDERID=1
		Update RPT1 SET RPT1.[SalMRP]=RPT.[SalMRP],RPT1.[SalSelRate]=RPT.[SalSelRate],
		RPT1.[SalListPrc]=RPT.[SalListPrc] FROM RptCurrentStockWithUom RPT1 INNER JOIN
		#RptCurrentStockWithUom RPT ON RPT1.Prdid=Rpt.Prdid
		and rpt1.Prdbatid=rpt.prdbatid and rpt1.lcnid=rpt.lcnid
		Select Prdid,Prdbatid,Lcnid,[UNMRP],[UNSelRate],[UNListPrc]
		INTO #RptCurrentStockWithUom1 FROM RptCurrentStockWithUom WHERE ORDERID=2
		Update RPT1 SET RPT1.[UNMRP]=RPT.[UNMRP],RPT1.[UNSelRate]=RPT.[UNSelRate],
		RPT1.[UNListPrc]=RPT.[UNListPrc] FROM RptCurrentStockWithUom RPT1 INNER JOIN
		#RptCurrentStockWithUom1 RPT ON RPT1.Prdid=Rpt.Prdid
		and rpt1.Prdbatid=rpt.prdbatid and rpt1.lcnid=rpt.lcnid
		Select Prdid,Prdbatid,Lcnid,[TOTMRP],[TOTSelRate],[TOTListPrc]
		INTO #RptCurrentStockWithUom4 FROM RptCurrentStockWithUom WHERE ORDERID=4
		Update RPT1 SET RPT1.[TOTMRP]=RPT.[TOTMRP],RPT1.[TOTSelRate]=RPT.[TOTSelRate],
		RPT1.[TOTListPrc]=RPT.[TOTListPrc] FROM RptCurrentStockWithUom RPT1 INNER JOIN
		#RptCurrentStockWithUom4 RPT ON RPT1.Prdid=Rpt.Prdid
		and rpt1.Prdbatid=rpt.prdbatid and rpt1.lcnid=rpt.lcnid
	
		---FIND UOM QTY
		DECLARE @Prdid AS INT
		DECLARE @Prdbatid AS INT
		DECLARE @OrderId AS INT
		DECLARE @LcnId1 AS INT
		DECLARE @Prdid1 AS INT
		DECLARE @Prdbatid1 AS INT
		DECLARE @CONVERSIONFACTOR AS INT
		DECLARE @StockOnHand AS INT
		DECLARE @UOMID AS INT
		DECLARE @Converted as INT
		DECLARE @Remainder as INT
			DECLARE CUR_UOM CURSOR
			FOR 
				SELECT DISTINCT P.PrdId,RT.Prdbatid,OrderID,StockOnHand
				FROM Product P (NOLOCK),RptCurrentStockWithUom RT (NOLOCK) WHERE P.Prdid=RT.Prdid 
				Order By P.Prdid,OrderId 
			OPEN CUR_UOM
			FETCH NEXT FROM CUR_UOM INTO @Prdid,@Prdbatid,@OrderId,@StockOnHand
			WHILE @@FETCH_STATUS=0
			BEGIN
					SET	@Converted=0
					SET @Remainder=0				
					DECLARE CUR_UOMCONVERT CURSOR
					FOR 
					SELECT Prdid,Prdbatid,UOMID,CONVERSIONFACTOR FROM RptCurrentStockWithUom (NOLOCK) WHERE PRDID=@Prdid and Prdbatid=@Prdbatid  and OrderId=@OrderId  and StockOnhand>0  and CONVERSIONFACTOR>0  Order by CONVERSIONFACTOR DESC
					OPEN CUR_UOMCONVERT
					FETCH NEXT FROM CUR_UOMCONVERT INTO  @Prdid1,@Prdbatid1,@UOMID,@CONVERSIONFACTOR
					WHILE @@FETCH_STATUS=0
					BEGIN
						IF @StockOnHand>= @CONVERSIONFACTOR
						BEGIN
							SET	@Converted=CAST(@StockOnHand/@CONVERSIONFACTOR as INT)
							SET @Remainder=CAST(@StockOnHand%@CONVERSIONFACTOR AS INT)
							SET @StockOnHand=@Remainder						
							UPDATE RptCurrentStockWithUom SET UOMCONVERTEDQTY=Isnull(@Converted,0)  WHERE PRDID=@Prdid1 and Prdbatid=@Prdbatid1 and Uomid=@UOMID and OrderId=@OrderId 
						END					
						
					FETCH NEXT FROM CUR_UOMCONVERT INTO @Prdid1,@Prdbatid1,@UOMID,@CONVERSIONFACTOR
					END	
					CLOSE CUR_UOMCONVERT
					DEALLOCATE CUR_UOMCONVERT
					SET @StockOnHand=0
			FETCH NEXT FROM CUR_UOM INTO @Prdid,@Prdbatid,@OrderId,@StockOnHand
			END	
			CLOSE CUR_UOM
			DEALLOCATE CUR_UOM
	--	SELECT * FROM RptCurrentStockWithUom
		--TILL HERE
END  
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_RptCurrentStockUOMBASED')
DROP PROCEDURE Proc_RptCurrentStockUOMBASED
GO
--EXEC Proc_RptCurrentStockUOMBASED 5,2,0,'Dabur1',0,0,1,0
--EXEC Proc_RptCurrentStockUOMBASED 5,1,0,'JNJ396',0,0,1,0
CREATE PROCEDURE Proc_RptCurrentStockUOMBASED
	(
		@Pi_RptId  INT,
		@Pi_UsrId  INT,
		@Pi_SnapId  INT,
		@Pi_DbName  nvarchar(50),
		@Pi_SnapRequired INT,
		@Pi_GetFromSnap  INT,
		@Pi_CurrencyId  INT,
		@Po_Errno  INT OUTPUT
	)
AS
/*********************************
* PROCEDURE : Proc_RptCurrentStockUOMBASED
* PURPOSE : To get the Current Stock details for Report
* CREATED : MURUGAN.R
* CREATED DATE : 01/09/2009
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
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
	--Filter Variable
	DECLARE @CmpId          AS Int
	DECLARE @LcnId          AS Int
	DECLARE @CmpPrdCtgId  AS Int
	DECLARE @PrdCtgMainId  AS Int
	DECLARE @StockValue      AS Int
	DECLARE @DispBatch  AS Int
	DECLARE @PrdStatus       AS Int
	DECLARE @PrdBatId        AS Int
	DECLARE @PrdBatStatus       AS Int
	DECLARE @SupTaxGroupId      AS Int
	DECLARE @RtrTaxFroupId      AS Int
	DECLARE @fPrdCatPrdId       AS Int
	DECLARE @StockType       AS Int
	DECLARE @fPrdId        AS Int
	DECLARE @sStockType       AS NVARCHAR(20)
	--Till Here
	--Assgin Value for the Filter Variable
	
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @StockValue = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))
	SET @DispBatch = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
	SET @PrdBatStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))
	SET @PrdBatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
	SET @SupTaxGroupId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,18,@Pi_UsrId))
	SET @RtrTaxFroupId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,19,@Pi_UsrId))
	SET @StockType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))
	--Till Here
	--If Product Category Filter is available
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	--Till Here
	EXEC Proc_CurrentStockReportUOMBASED @Pi_RptId,@Pi_UsrId
	IF @StockType=1
	BEGIN
		SET @sStockType='Saleable'
	END
	ELSE IF @StockType=2
	BEGIN
		SET @sStockType='UnSaleable'
	END
	ELSE IF @StockType=3
	BEGIN
		SET @sStockType='Offer'
	END
	Create TABLE #RptCurrentStockUOMBASED
	(
		PrdId    INT,
		PrdCcode  NVARCHAR(100),
		PrdDcode  NVARCHAR(100),
		PrdName   NVARCHAR(200),
		PrdBatId              INT,
		PrdBatCode   NVARCHAR(100),
		MRP                NUMERIC (38,6),
		DisplayRate         NUMERIC (38,6),
		[StockValue Saleable]       NUMERIC (38,6),
		[StockValue UnSaleable]      NUMERIC (38,6),
		[Total StockValue]         NUMERIC (38,6),
		UOMCONVERTEDQTY INT,
		ORDERID INT,
		StockingType Varchar(50),
		UOMID INT,UOMCODE VARCHAR(50)	,	
		StockType	INT
		
	)
	
	
	SET @TblName = '#RptCurrentStockUOMBASED'
	SET @TblStruct = ' PrdId      INT,
	PrdCcode  NVARCHAR(100),
	PrdDcode    NVARCHAR(100),
	PrdName     NVARCHAR(200),
	PrdBatId           INT,
	PrdBatCode     NVARCHAR(100),
	MRP             NUMERIC (38,6),
	DisplayRate    NUMERIC (38,6),
	[StockValue Saleable]       NUMERIC (38,6),
	[StockValue UnSaleable]      NUMERIC (38,6),
	[Total StockValue]         NUMERIC (38,6),
	UOMCONVERTEDQTY INT,
	ORDERID INT,
	StockingType Varchar(50),
	UOMID INT,UOMCODE VARCHAR(50),
	StockType	INT'	
	SET @TblFields = 'PrdId,PrdCcode,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
	[StockValue Saleable] ,[StockValue UnSaleable] ,[Total StockValue],UOMCONVERTEDQTY ,ORDERID,StockingType,UOMID,UOMCODE,[StockType]'
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
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data
	BEGIN
			IF @DispBatch=2
			BEGIN
				INSERT INTO #RptCurrentStockUOMBASED (PrdId,PrdCcode,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				[StockValue Saleable] ,[StockValue UnSaleable] ,[Total StockValue],UOMCONVERTEDQTY ,ORDERID,StockingType,UOMID,UOMCODE ,StockType)
				SELECT PrdId,PrdCcode,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SELLINGRATE,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(LISTPRICE,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,				
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UNSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UNListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UNMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TOTSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TOTListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TOTMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,
				UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE,@StockType
				FROM RptCurrentStockWithUom
				WHERE
--				(CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
--				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
--				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
--				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
--				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
--				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
--				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
--				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
--				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
--				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 				
				GROUP BY PrdId,PrdCcode,PrdDcode,PrdName,PrdBatId,PrdBatCode,
					MRP,ListPrice,SELLINGRATE,UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE
			END
			ELSE
			BEGIN
				INSERT INTO #RptCurrentStockUOMBASED (PrdId,PrdCcode,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				[StockValue Saleable] ,[StockValue UnSaleable] ,[Total StockValue],UOMCONVERTEDQTY ,ORDERID,StockingType,UOMID,UOMCODE,StockType )
				SELECT PrdId,PrdCcode,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SELLINGRATE,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(LISTPRICE,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,				
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UNSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UNListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UNMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TOTSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TOTListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TOTMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,
					UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE,@StockType
				FROM RptCurrentStockWithUom
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 				
				GROUP BY PrdId,PrdCcode,PrdDcode,PrdName,PrdBatId,PrdBatCode,
					MRP,ListPrice,SELLINGRATE,UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE
			END
	IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptCurrentStockUOMBASED ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+' WHERE (CmpId=(CASE '+CAST(@CmpId AS NVARCHAR(10))+' WHEN 0 THEN CmpId ELSE 0 END ) OR
			CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',4,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (LcnId=(CASE '+CAST(@LcnId AS NVARCHAR(10))+' WHEN 0 THEN LcnId ELSE 0 END ) OR
			LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',22,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdId = (CASE '+CAST(@fPrdCatPrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
			PrdId IN (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',26,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdId = (CASE'+CAST(@fPrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
			PrdId in (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',5,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdStatus=(CASE '+CAST(@PrdStatus AS NVARCHAR(10))+' WHEN 0 THEN PrdStatus ELSE 0 END ) OR
			PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',24,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (Status=(CASE '+CAST(@PrdBatStatus AS NVARCHAR(10))+' WHEN 0 THEN Status ELSE 0 END ) OR
			Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',25,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate'
			EXEC (@SSQL)
			--UPDATE #RptCurrentStockUOMBASED SET DispBatch=@DispBatch
			--PRINT 'Retrived Data From Purged Table'
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCurrentStockUOMBASED'
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
			SET @SSQL = 'INSERT INTO #RptCurrentStockUOMBASED ' +
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


--			IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
--			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCurrentStock_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE [RptCurrentStock_Excel]
				SELECT * INTO [RptCurrentStock_Excel] FROM #RptCurrentStockUOMBASED 
			--END 
		DELETE FROM RptExcelHeaders WHERE RptId=5
		DECLARE @COLUMN AS Varchar(80)
		DECLARE @C_SSQL AS Varchar(8000)
		DECLARE @iCnt AS Int 
		SET @iCnt=1
			DECLARE Cur_Col CURSOR FOR  
			SELECT SC.[Name] FROM SysColumns SC,SysObjects So WHERE SC.Id=SO.Id AND SO.[Name]='RptCurrentStock_Excel'
			OPEN Cur_Col
			FETCH NEXT FROM Cur_Col INTO @COLUMN
			WHILE @@FETCH_STATUS = 0
			BEGIN
			SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
			SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
			SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
			EXEC (@C_SSQL)
			SET @iCnt=@iCnt+1
			FETCH NEXT FROM Cur_Col INTO @COLUMN
			END
			CLOSE Cur_Col
			DEALLOCATE Cur_Col
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno IN (1,5,12,13,15,17) 

		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStockUOMBASED
		SELECT * FROM #RptCurrentStockUOMBASED 

		--	IF @StockType=0
		--	BEGIN
		--SELECT * FROM #RptCurrentStockUOMBASED 
		--	END
		--	ELSE
		--	BEGIN
		--		SELECT * FROM #RptCurrentStockUOMBASED WHERE StockingType=@sStockType
		--	END
END	
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_RptCurrentStock')
DROP PROCEDURE Proc_RptCurrentStock
GO
--Exec [Proc_RptCurrentStock] 5,1,0,'JNJ396',0,0,1,0
CREATE PROCEDURE Proc_RptCurrentStock
(
	@Pi_RptId  INT,
	@Pi_UsrId  INT,
	@Pi_SnapId  INT,
	@Pi_DbName  nvarchar(50),
	@Pi_SnapRequired INT,
	@Pi_GetFromSnap  INT,
	@Pi_CurrencyId  INT,
	@Po_Errno  INT OUTPUT
)
AS
/*********************************
* PROCEDURE : Proc_RptCurrentStock
* PURPOSE : To get the Current Stock details for Report
* CREATED : Nandakumar R.G
* CREATED DATE : 01/08/2007
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
24/07/2009	MarySubashini.S		To add the Tax Validation
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
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
	--Filter Variable
	DECLARE @CmpId          AS Int
	DECLARE @LcnId          AS Int
	DECLARE @CmpPrdCtgId  AS Int
	DECLARE @PrdCtgMainId  AS Int
	DECLARE @StockValue      AS Int
	DECLARE @DispBatch  AS Int
	DECLARE @PrdStatus       AS Int
	DECLARE @PrdBatId        AS Int
	DECLARE @PrdBatStatus       AS Int
	DECLARE @SupTaxGroupId      AS Int
	DECLARE @RtrTaxFroupId      AS Int
	DECLARE @fPrdCatPrdId       AS Int
	DECLARE @fPrdId        AS Int
	DECLARE @SupZeroStock	AS INT
	DECLARE @StockType	AS INT
	DECLARE @RptDispType	AS INT
	--Till Here
	--Assgin Value for the Filter Variable
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @StockValue = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))
	SET @DispBatch = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
	SET @PrdBatStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))
	SET @PrdBatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
	SET @SupTaxGroupId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,18,@Pi_UsrId))
	SET @RtrTaxFroupId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,19,@Pi_UsrId))
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	SET @StockType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))
	SET @RptDispType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,221,@Pi_UsrId))
	IF @DispBatch = 1 
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	--Till Here
	--If Product Category Filter is available
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	--Till Here
	DELETE FROM TaxForReport WHERE UsrId=@Pi_UsrId AND RptId=@Pi_RptId
	IF @SupTaxGroupId<>0 OR @RtrTaxFroupId<>0
	BEGIN
		EXEC Proc_ReportTaxCalculation @SupTaxGroupId,@RtrTaxFroupId,1,20,5,@Pi_UsrId,@Pi_RptId
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
	Create TABLE #RptCurrentStock
	(
		PrdId    INT,
		PrdDcode  NVARCHAR(100),
		PrdName   NVARCHAR(200),
		PrdBatId              INT,
		PrdBatCode   NVARCHAR(100),
		MRP                NUMERIC (38,6),
		DisplayRate         NUMERIC (38,6),
		Saleable              INT,
		SaleableWgt		NUMERIC (38,6),
		Unsaleable   INT,
		UnsaleableWgt		NUMERIC (38,6),
		Offer                 INT,
		OfferWgt		NUMERIC (38,6),
		DisplaySalRate       NUMERIC (38,6),
		DisplayUnSalRate      NUMERIC (38,6),
		DisplayTotRate        NUMERIC (38,6),
		DispBatch             INT,
		RtrTaxGroup           INT,
		SupTaxGroup           INT,
		StockType			  INT
		
	)
	SET @TblName = 'RptCurrentStock'
	SET @TblStruct = '  PrdId      INT,
						PrdDcode    NVARCHAR(100),
						PrdName     NVARCHAR(200),
						PrdBatId       INT,
						PrdBatCode     NVARCHAR(100),
						MRP            NUMERIC (38,6),
						DisplayRate    NUMERIC (38,6),
						Saleable       INT,
						SaleableWgt		NUMERIC (38,6),
						Unsaleable		INT,
						UnsaleableWgt	NUMERIC (38,6),
						Offer           INT,
						OfferWgt		NUMERIC (38,6),
						DisplaySalRate    NUMERIC (38,6),
						DisplayUnSalRate   NUMERIC (38,6),
						DisplayTotRate     NUMERIC (38,6),
						DispBatch          INT,
						RtrTaxGroup        INT,
						SupTaxGroup        INT,
						StockType		   INT'
	SET @TblFields = 'PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
	Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType'
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
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data
	BEGIN
		IF @SupTaxGroupId<>0 OR @RtrTaxFroupId<>0
		BEGIN
			IF @DispBatch=2
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReport
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) AND
				UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
			ELSE
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReport
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE -1 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))) AND
				UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
		END
		ELSE
		BEGIN
			IF @DispBatch=2
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReportNTax
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				--AND UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
			ELSE
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReportNTax
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE -1 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				--AND UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
		END
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptCurrentStock ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+' WHERE (CmpId=(CASE '+CAST(@CmpId AS NVARCHAR(10))+' WHEN 0 THEN CmpId ELSE 0 END ) OR
			CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',4,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (LcnId=(CASE '+CAST(@LcnId AS NVARCHAR(10))+' WHEN 0 THEN LcnId ELSE 0 END ) OR
			LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',22,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdId = (CASE '+CAST(@fPrdCatPrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
			PrdId IN (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',26,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdId = (CASE'+CAST(@fPrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
			PrdId in (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',5,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdStatus=(CASE '+CAST(@PrdStatus AS NVARCHAR(10))+' WHEN 0 THEN PrdStatus ELSE 0 END ) OR
			PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',24,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (Status=(CASE '+CAST(@PrdBatStatus AS NVARCHAR(10))+' WHEN 0 THEN Status ELSE 0 END ) OR
			Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',25,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate'
			EXEC (@SSQL)
			UPDATE #RptCurrentStock SET DispBatch=@DispBatch
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCurrentStock'
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
			SET @SSQL = 'INSERT INTO #RptCurrentStock ' +
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
	
	IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND  GridFlag=1 AND UsrId=@Pi_UsrId)
	BEGIN
		SELECT a.PrdId,a.PrdDcode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.MRP,a.DisplayRate,a.Saleable,
		CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Saleable AS INT)>nullif(ConverisonFactor2,0) Then CAST(Saleable AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END  As Uom1,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
		(CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN Case When CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
		(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
		CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
		(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END as Uom4,
		a.Unsaleable,a.Offer,a.DisplaySalRate,a.DisplayUnSalRate,a.DisplayTotRate,a.DispBatch,a.RtrTaxGroup,a.SupTaxGroup,a.StockType
		INTO #RptColDetails
		FROM #RptCurrentStock A, View_ProdUOMDetails B WHERE a.prdid=b.prdid
		DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
		INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,Rptid,Usrid)
		SELECT PrdDcode,PrdName,PrdBatCode,MRP,DisplayRate,Saleable,Uom1,Uom2,Uom3,Uom4,
		Unsaleable,Offer,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,@Pi_RptId,@Pi_UsrId
		FROM #RptColDetails
	END
	--SELECT @RptDispType
	SET @RptDispType=ISNULL(@RptDispType,1)
	IF @RptDispType=1
	BEGIN
		--TRUNCATE TABLE RptCurrentStock_Excel
		IF @SupZeroStock=1
		BEGIN
			SELECT * FROM #RptCurrentStock
			WHERE Saleable+Unsaleable+Offer <> 0
----			IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND Flag=1 AND UsrId=@Pi_UsrId)
----			BEGIN
----				INSERT INTO RptCurrentStock_Excel
----				SELECT * FROM #RptCurrentStock
----				WHERE (Saleable+UnSaleable+Offer)<>0
----			END
			IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCurrentStock_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE RptCurrentStock_Excel
				SELECT * INTO RptCurrentStock_Excel FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			END 
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			PRINT 'Data Executed'
		END
		ELSE
		BEGIN
			SELECT * FROM #RptCurrentStock
----			IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND Flag=1 AND UsrId=@Pi_UsrId)
----			BEGIN
----				INSERT INTO RptCurrentStock_Excel
----				SELECT * FROM #RptCurrentStock
----			END
			IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCurrentStock_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE RptCurrentStock_Excel
				SELECT * INTO RptCurrentStock_Excel FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			END 
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock 
			PRINT 'Data Executed'
		END
	END
	ELSE
	BEGIN		
		IF @SupZeroStock=1
		BEGIN
			SELECT a.PrdId,a.PrdDcode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.MRP,a.DisplayRate,a.Saleable,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Saleable AS INT)>nullif(ConverisonFactor2,0) Then CAST(Saleable AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END  As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			(CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN Case When CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((nullif(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
			CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END as Uom4,
			a.Unsaleable,a.Offer,a.DisplaySalRate,a.DisplayUnSalRate,a.DisplayTotRate,a.DispBatch,a.RtrTaxGroup,a.SupTaxGroup,a.StockType
			FROM #RptCurrentStock A, View_ProdUOMDetails B WHERE a.prdid=b.prdid
			AND (a.Saleable + a.Unsaleable + a.Offer) <> 0
		
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			PRINT 'Data Executed'
		END
		ELSE
		BEGIN
			SELECT a.PrdId,a.PrdDcode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.MRP,a.DisplayRate,a.Saleable,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Saleable AS INT)>nullif(ConverisonFactor2,0) Then CAST(Saleable AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END  As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			(CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN Case When CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((nullif(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
			CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END as Uom4,
			a.Unsaleable,a.Offer,a.DisplaySalRate,a.DisplayUnSalRate,a.DisplayTotRate,a.DispBatch,a.RtrTaxGroup,a.SupTaxGroup,a.StockType
			FROM #RptCurrentStock A, View_ProdUOMDetails B WHERE a.prdid=b.prdid
			
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock
			PRINT 'Data Executed'
		END
	END

		DELETE FROM RptExcelHeaders WHERE RptId=5
		DECLARE @COLUMN AS Varchar(80)
		DECLARE @C_SSQL AS Varchar(8000)
		DECLARE @iCnt AS Int 
		SET @iCnt=1
			DECLARE Cur_Col CURSOR FOR  
			SELECT SC.[Name] FROM SysColumns SC,SysObjects So WHERE SC.Id=SO.Id AND SO.[Name]='RptCurrentStock_Excel'
			OPEN Cur_Col
			FETCH NEXT FROM Cur_Col INTO @COLUMN
			WHILE @@FETCH_STATUS = 0
			BEGIN
			SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
			SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
			SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
			EXEC (@C_SSQL)
			SET @iCnt=@iCnt+1
			FETCH NEXT FROM Cur_Col INTO @COLUMN
			END
			CLOSE Cur_Col
			DEALLOCATE Cur_Col
		  UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno IN (1)
	RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype = 'P' And Name ='Proc_GR_EffectiveCoverageAnalysis')
DROP PROCEDURE Proc_GR_EffectiveCoverageAnalysis
GO
CREATE PROCEDURE Proc_GR_EffectiveCoverageAnalysis
(
	@Pi_RptName		NVARCHAR(100),
	@Pi_FromDate	DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_Filter1		NVARCHAR(100),
	@Pi_Filter2		NVARCHAR(100),
	@Pi_Filter3		NVARCHAR(100),
	@Pi_Filter4		NVARCHAR(100),
	@Pi_Filter5		NVARCHAR(100),
	@Pi_Filter6		NVARCHAR(100)
)
AS 
BEGIN
-- EXEC [Proc_GR_EffectiveCoverageAnalysis] 'Billwise Productwise Sales','2011-12-12','2011-12-12','','','','','',''
		SET @Pi_FILTER1='%'+ISNULL(@Pi_FILTER1,'')+'%'        
		SET @Pi_FILTER2='%'+ISNULL(@Pi_FILTER2,'')+'%'        
		SET @Pi_FILTER3='%'+ISNULL(@Pi_FILTER3,'')+'%'        
		SET @Pi_FILTER4='%'+ISNULL(@Pi_FILTER4,'')+'%'        
		SET @Pi_FILTER5='%'+ISNULL(@Pi_FILTER5,'')+'%'  
		SET @Pi_FILTER6='%'+ISNULL(@Pi_FILTER6,'')+'%'      
SELECT 
		Salesman.SMCode AS [Salesman Code], Salesman.SMName AS [Salesman Name], 
		RouteMaster.RMCode AS [Route Code], RouteMaster.RMName AS [Route Name], 
        TBL_GR_BUILD_RH.HIERARCHY3CAP AS [Retailer Hierarchy 1], 
        TBL_GR_BUILD_RH.HIERARCHY2CAP AS [Retailer Hierarchy 2], 
		TBL_GR_BUILD_RH.HIERARCHY1CAP AS [Retailer Hierarchy 3], 
		Retailer.RtrCode AS [Retailer Code] ,
		Retailer.RtrNAme as [Retailer Name]         INTO #COV 
FROM         SalesmanMarket INNER JOIN
                      Salesman ON SalesmanMarket.SMId = Salesman.SMId INNER JOIN
                      RouteMaster ON SalesmanMarket.RMId = RouteMaster.RMId INNER JOIN
                      Retailer INNER JOIN
                      RetailerMarket ON Retailer.RtrId = RetailerMarket.RtrId ON SalesmanMarket.RMId = RetailerMarket.RMId INNER JOIN
                      TBL_GR_BUILD_RH ON Retailer.RtrId = TBL_GR_BUILD_RH.RTRID
where rtrstatus=1 and smname like @pi_filter1 and rmname like @pi_Filter5 and rtrname like @pi_Filter4
SELECT [SALESMAN CODE],COUNT(DISTINCT [RETAILER CODE]) RTRCOUNT INTO #SALRETCOUNT FROM #COV
GROUP BY [SALESMAN CODE]
SELECT [Route Code],COUNT(DISTINCT [RETAILER CODE]) RTRCOUNT INTO #ROTRETCOUNT FROM #COV
GROUP BY [Route Code]
SELECT COUNT(DISTINCT [RETAILER CODE]) CNT INTO #TOTALCNT FROM #COV
	
	SELECT a.* INTO #SALINV 
	FROM SALESINVOICE A,ROUTEMASTER B, SALESMAN C, RETAILER D  ,TBL_GR_BUILD_RH E
	WHERE SALINVDATE BETWEEN @PI_fROMDATE AND @PI_TODATE AND A.RMID=B.RMID 
		  AND B.RMNAME LIKE @PI_FILTER5 and E.RTRID=A.RTRID AND
			DLVSTS in (4,5) and
			C.SMID=A.SMID AND C.SMNAME LIKE @PI_FILTER1 AND A.SALINVNO LIKE @PI_FILTER3 
			AND A.RTRID=D.RTRID AND D.RTRNAME LIKE @PI_FILTER4 AND E.HASHPRODUCTS LIKE @PI_FILTER2
    SELECT A.* INTO #SALESINVOICEPRODUCT FROM SALESINVOICEPRODUCT A,TBL_GR_BUILD_PH C, #SALINV D
	WHERE A.SALID=D.SALID AND A.PRDID=C.PRDID AND 	HASHPRODUCTS LIKE @PI_FILTER6
	--DELETE FROM #SALINV WHERE SALID NOT IN (SELECT DISTINCT SALID FROM #SALESINVOICEPRODUCT)
---- FOR PRODUCT
SELECT     'Product Level',Product.PrdDCode[Dist. Prod Code], Product.PrdCCode[Co. Prd Code], 
			Product.PrdName [Prd Name.],(SELECT CNT FROM #TOTALCNT) [Active Retailers],
			count(DISTINCT RTRID)[Total Retailers Billed], ((SELECT CNT FROM #TOTALCNT)-(SELECT Count(DISTINCT RTRId) FROM #SALINV WHERE SALINVDATE BETWEEN @PI_fROMDATE AND @PI_TODATE))[Number of retailers not Billed],
			COUNT(DISTINCT #salinv.SalInvNo) [Total No. Invoices], 
            sum(#Salesinvoiceproduct.PrdNetAmount) [Net Amount]
FROM         #salinv  INNER JOIN
                      #Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
                      Product ON #Salesinvoiceproduct.PrdId = Product.PrdId 
GROUP BY Product.PrdDCode, Product.PrdCCode, Product.PrdName
------- FOR SALESMAN
SELECT     'Salesman Level',Salesman.SMName [Salesman Name],RTRCOUNT [Active Retailers],
			COUNT(DISTINCT RTRID)[Total Retailers Billed],(RTRCOUNT-COUNT(DISTINCT RTRID)) [Number of retailers not Billed],
			count(distinct #salinv.SalInvNo) [Total No. Invoices] , 
			count(Product.PrdDCode) [Total Lines Sold],
			Cast(count(Product.PrdDCode) as Numeric(18,2)) / Cast(count(distinct #salinv.SalInvNo) as Numeric(18,2)) AS [Lines Per Invoice],
			Sum(#Salesinvoiceproduct.PrdNetAmount) [Net Amount]
FROM         #salinv INNER JOIN
                      #Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
                      Product ON #Salesinvoiceproduct.PrdId = Product.PrdId INNER JOIN
                      Salesman ON #salinv.SMId = Salesman.SMId INNER JOIN
					  #SALRETCOUNT ON SALESMAN.SMCODE=#SALRETCOUNT.[SALESMAN CODE]
group by Salesman.SMName,RTRCOUNT
------ FOR ROUTE
SELECT      'Route Level',RouteMaster.RMName [Route Name],RTRCOUNT [Active Retailers],
			COUNT(DISTINCT RTRID)[Total Retailers Billed],(RTRCOUNT-COUNT(DISTINCT RTRID)) [Number of retailers not Billed],
		    count(distinct #salinv.SalInvNo) [Total No. Invoices] , 
			count(Product.PrdDCode) [Total Lines Sold],
			Cast(count(Product.PrdDCode) as Numeric(18,2))/Cast(count(distinct #salinv.SalInvNo) as Numeric(18,2)) AS [Lines Per Invoice],
			sum(#Salesinvoiceproduct.PrdNetAmount) [Net Amount]
FROM         #salinv INNER JOIN
                      #Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
                      Product ON #Salesinvoiceproduct.PrdId = Product.PrdId INNER JOIN 
                      RouteMaster ON #salinv.RMId = RouteMaster.RMId INNER JOIN
					  #ROTRETCOUNT ON ROUTEMASTER.RMCODE=#ROTRETCOUNT.[ROUTE CODE]
group by RMName,RTRCOUNT
---- RETAILER LEVEL
SELECT     'Retailer Level',RtrCode [Retailer Code],RtrName [Retailer Name], 
			count(distinct #salinv.SalInvNo) [Total No. Invoices] , count(Product.PrdDCode) [Total Lines Sold],
			Cast(count(Product.PrdDCode) as Numeric(18,2))/Cast(count(distinct #salinv.SalInvNo) as Numeric(18,2)) AS [Lines Per Invoice],
			sum(#Salesinvoiceproduct.PrdNetAmount) [Net Amount]
FROM         #salinv INNER JOIN
                      #Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
                      Product ON #Salesinvoiceproduct.PrdId = Product.PrdId INNER JOIN
                      Retailer ON #salinv.rtrid = Retailer.Rtrid
group by Rtrcode,Rtrname
end
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE [Name]='Proc_GR_BillWISESales')
DROP PROCEDURE Proc_GR_BillWISESales
GO
CREATE PROCEDURE Proc_GR_BillWISESales
(
	@Pi_RptName		NVARCHAR(100),
	@Pi_FromDate	DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_Filter1		NVARCHAR(100),
	@Pi_Filter2		NVARCHAR(100),
	@Pi_Filter3		NVARCHAR(100),
	@Pi_Filter4		NVARCHAR(100),
	@Pi_Filter5		NVARCHAR(100),
	@Pi_Filter6		NVARCHAR(100)
)
AS 
BEGIN
		SELECT 0 flag ,CAST('' AS VARCHAR(20)) AS dlvsts INTO #TEMP 
		TRUNCATE TABLE #TEMP
		INSERT INTO #TEMP SELECT 1,'Saved'
		INSERT INTO #TEMP SELECT 2,'Vehicle Allocated'
		INSERT INTO #TEMP SELECT 3,'Cancelled'
		INSERT INTO #TEMP SELECT 4,'Delivered'
		INSERT INTO #TEMP SELECT 5,'Fully Settled'
--EXEC Proc_GR_BillWISESales 'Bill Wise Retailer Sales','2011-12-12','2011-12-12','','','','','','can'
		SET @Pi_FILTER1='%'+ISNULL(@Pi_FILTER1,'')+'%'        
		SET @Pi_FILTER2='%'+ISNULL(@Pi_FILTER2,'')+'%'        
		SET @Pi_FILTER3='%'+ISNULL(@Pi_FILTER3,'')+'%'        
		SET @Pi_FILTER4='%'+ISNULL(@Pi_FILTER4,'')+'%'        
		SET @Pi_FILTER5='%'+ISNULL(@Pi_FILTER5,'')+'%'  
		SET @Pi_FILTER6='%'+ISNULL(@Pi_FILTER6,'')+'%'
	SELECT a.*,HIERARCHY1CAP,HIERARCHY2CAP,HIERARCHY3CAP 
INTO #SALINV
 FROM SALESINVOICE A,ROUTEMASTER B, SALESMAN C, RETAILER D  ,TBL_GR_BUILD_RH E
	WHERE SALINVDATE BETWEEN @PI_fROMDATE AND @PI_TODATE AND A.RMID=B.RMID AND B.RMNAME LIKE @PI_FILTER5 and E.RTRID=A.RTRID AND
    DLVSTS in (select flag from #temp where dlvsts like @pi_filter6) and
    C.SMID=A.SMID AND C.SMNAME LIKE @PI_FILTER1 AND A.SALINVNO LIKE @PI_FILTER3 AND A.RTRID=D.RTRID AND D.RTRNAME LIKE @PI_FILTER4 AND E.HASHPRODUCTS LIKE @PI_FILTER2
SELECT     'Billwise ',#SALINV.SalInvNo AS [Bill Number], CONVERT(VARCHAR(10),#SALINV.SalInvDate,121) AS [Bill Date], 
					  CASE BillType WHEN 1 THEN 'Order Booking'  WHEN 2 THEN 'Ready Stock' WHEN 3 THEN 'Van Sales' END AS [Bill Type],
					  CASE BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END AS [Bill Mode],
					  CASE #SALINV.DlvSts  when 1 then 'Saved' when 2 then 'Vehicle Allocated' when 3 then 'Cancelled' when 4 then 'Delivered' when 5 then 'Fully Settled' end AS [Delivery Status], 
					  Salesman.SMName AS Salesman,RouteMaster.RMName [Route],#SALINV.HIERARCHY3CAP [Retailer Hierarchy 1],#SALINV.HIERARCHY2CAP [Retailer Hierarchy 2],#SALINV.HIERARCHY1CAP [Retailer Hierarchy 3],Retailer.RtrCode [Retailer Code], Retailer.RtrName AS [Retailer Name], 
                      #SALINV.SalGrossAmount AS [Gross Amount], #SALINV.SalSchDiscAmount AS [Scheme Disc], #SALINV.MarketRetAmount AS [Sales Return], 
                      #SALINV.ReplacementDiffAmount AS Replacement, #SALINV.SalDBDiscAmount AS [Distributor Discount], #SALINV.SalCDAmount AS [Cash Discount],#SALINV.WINDOWDISPLAYAMOUNT [Window Display], 
                      #SALINV.SalTaxAmount AS [Tax Amount], #SALINV.DBAdjAmount AS [Debit Adjustment], #SALINV.CRAdjAmount AS [Credit Adjustment], 
                      #SALINV.SalNetAmt AS [Net Amount]
FROM         #SALINV  INNER JOIN
                      Retailer ON #SALINV.RtrId = Retailer.RtrId INNER JOIN
                      Salesman ON #SALINV.SMId = Salesman.SMId INNER JOIN
                      RouteMaster ON #SALINV.RMId = RouteMaster.RMId INNER JOIN
                      TBL_GR_BUILD_RH ON Retailer.RtrId = TBL_GR_BUILD_RH.RTRID 
						
UNION
SELECT     ' Billwise','Totals ' AS [Bill Number],'', 
					  '',
					  '',
					  '', 
					  '','','','','','','',
                      sum(#SALINV.SalGrossAmount) AS [Gross Amount],SUM( #SALINV.SalSchDiscAmount) AS [Scheme Disc], SUM(#SALINV.MarketRetAmount) AS [Sales Return], 
                      SUM(#SALINV.ReplacementDiffAmount) AS Replacement,SUM( #SALINV.SalDBDiscAmount) AS [Distributor Discount], SUM(#SALINV.SalCDAmount) AS [Cash Discount],sum(#salinv.WindowDisplayAmount),
                      SUM(#SALINV.SalTaxAmount) AS [Tax Amount],SUM( #SALINV.DBAdjAmount) AS [Debit Adjustment],SUM( #SALINV.CRAdjAmount) AS [Credit Adjustment], 
                     SUM( #SALINV.SalNetAmt) AS [Net Amount]
FROM         #SALINV  INNER JOIN
                      Retailer ON #SALINV.RtrId = Retailer.RtrId INNER JOIN
                      Salesman ON #SALINV.SMId = Salesman.SMId INNER JOIN
                      RouteMaster ON #SALINV.RMId = RouteMaster.RMId INNER JOIN
                      TBL_GR_BUILD_RH ON Retailer.RtrId = TBL_GR_BUILD_RH.RTRID
END
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_GR_BillPrdSales')
DROP PROCEDURE Proc_GR_BillPrdSales
GO
CREATE PROCEDURE Proc_GR_BillPrdSales
(
	@Pi_RptName		NVARCHAR(100),
	@Pi_FromDate	DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_Filter1		NVARCHAR(100),
	@Pi_Filter2		NVARCHAR(100),
	@Pi_Filter3		NVARCHAR(100),
	@Pi_Filter4		NVARCHAR(100),
	@Pi_Filter5		NVARCHAR(100),
	@Pi_Filter6		NVARCHAR(100)
)
AS 
BEGIN
--EXEC Proc_GR_BillPrdSales 'Billwise Productwise Sales','2011-01-01','2011-03-22','ARUN KUMAR','IN C&B : Instant Tea - Retail','','','Old II',''
--EXEC Proc_GR_BillPrdSales 'Billwise Productwise Sales','2011-12-12','2011-12-12','','','','','',''
		SET @Pi_FILTER1='%'+ISNULL(@Pi_FILTER1,'')+'%'        
		SET @Pi_FILTER2='%'+ISNULL(@Pi_FILTER2,'')+'%'        
		SET @Pi_FILTER3='%'+ISNULL(@Pi_FILTER3,'')+'%'        
		SET @Pi_FILTER4='%'+ISNULL(@Pi_FILTER4,'')+'%'        
		SET @Pi_FILTER5='%'+ISNULL(@Pi_FILTER5,'')+'%'  
		SET @Pi_FILTER6='%'+ISNULL(@Pi_FILTER6,'')+'%'    
	SELECT a.*,HIERARCHY3CAP L1,HIERARCHY2CAP L2,HIERARCHY1CAP L3 INTO #SALINV FROM SALESINVOICE A,ROUTEMASTER B, SALESMAN C, RETAILER D ,TBL_GR_BUILD_RH E
	WHERE SALINVDATE BETWEEN @PI_fROMDATE AND @PI_TODATE AND A.RMID=B.RMID AND B.RMNAME LIKE @PI_FILTER5 and
    C.SMID=A.SMID AND C.SMNAME LIKE @PI_FILTER1 AND A.SALINVNO LIKE @PI_FILTER3 AND A.RTRID=D.RTRID AND D.RTRNAME LIKE @PI_FILTER4 AND E.RTRID=D.RTRID AND E.HASHPRODUCTS LIKE @PI_FILTER6
    SELECT A.*,C.Brand_Caption INTO #SALESINVOICEPRODUCT FROM SALESINVOICEPRODUCT A,TBL_GR_BUILD_PH C, #SALINV D
	WHERE A.SALID=D.SALID AND A.PRDID=C.PRDID AND 	HASHPRODUCTS LIKE @PI_FILTER2 
	
	    
	SELECT				'Detail ' SheetCaption,Salesman.SMName AS Salesman,RM.RMName [Route],
						 L1 [Retailer Hierarchy 1],
						L2 [Retailer Hieararchy 2],						 
						L3 [Retailer Hierarchy 3],
						 Retailer.RtrCode AS [Retailer Code],
						 Retailer.RtrName AS [Retailer Name],
						 Retailer.RtrAdd1 AS [Address 1],
						 #SALINV.SalInvNo AS [Sales Invoice Number],
						 CONVERT(VARCHAR(10),#SALINV.SalInvDate,121) AS [Sales Invoice Date],
						 CONVERT(VARCHAR(10),#SALINV.SalDlvDate,121) as [Actual Delivery Date],
						 CASE #SALINV.DlvSts  when 1 then 'Saved' 
											  when 2 then 'Vehicle Allocated' 
											  when 3 then 'Cancelled' 
											  when 4 then 'Delivered' 
											  when 5 then 'Fully Settled' 
						 end AS [Delivery Status], 
						 Product.PrdcCode as [Company Product Code],
                         #SALESINVOICEPRODUCT.Brand_Caption,
						 Product.PrdDCode AS [Dist. Product Code],
						 Product.PrdName AS [Product Name], 
						 'Batch '+ProductBatch.CmpBatCode AS Batch, 
						 #SALESINVOICEPRODUCT.PrdUnitMRP AS MRP, 
						 #SALESINVOICEPRODUCT.PrdUnitSelRate AS [Selling Rate],
						 CAST(#SALESINVOICEPRODUCT.BaseQty AS INT) AS [Quantity Billed],
						 #SALESINVOICEPRODUCT.PrdGrossAmount AS [Gross Amount], 
						 #SALESINVOICEPRODUCT.SplDiscAmount AS [Special Discount],
						 #SALESINVOICEPRODUCT.PrdSplDiscAmount AS [Product Special Discount], 
						 #SALESINVOICEPRODUCT.PrdSchDiscAmount AS [Product Scheme Discount],
						 #SALESINVOICEPRODUCT.PrdDBDiscAmount AS [Distributor Discount], 
						 #SALESINVOICEPRODUCT.PrdCDAmount AS [Cash Discount],
						 #SALESINVOICEPRODUCT.PrdTaxAmount AS [Tax Amount], 
						 #SALESINVOICEPRODUCT.PrdNetAmount AS [Net Amount]
	INTO #DETAIL FROM	  ProductBatch INNER JOIN
						  Product ON ProductBatch.PrdId = Product.PrdId
						  INNER JOIN #SALESINVOICEPRODUCT ON ProductBatch.PrdId = #SALESINVOICEPRODUCT.PrdId 
						  AND ProductBatch.PrdBatId = #SALESINVOICEPRODUCT.PrdBatId
						  AND Product.PrdId = #SALESINVOICEPRODUCT.PrdId
						  INNER JOIN #SALINV
						  INNER JOIN Salesman ON #SALINV.SMId = Salesman.SMId ON #SALESINVOICEPRODUCT.SalId = #SALINV.SalId
						  INNER JOIN Retailer ON #SALINV.RtrId = Retailer.RtrId
						  INNER JOIN RouteMaster RM ON #SALINV.RmId=RM.RmId
	INSERT INTO #DETAIL SELECT ' Detail','Totals','','','','','','','','','','','','','','','','',0,0,isnull(sum([Quantity Billed]),0),isnull(SUM([Gross Amount]),0),isnull(SUM([Special Discount]),0),
						isnull(SUM([Product Special Discount]),0),isnull(Sum([Product Scheme Discount]),0),isnull(Sum([Distributor Discount]),0),isnull(Sum([Cash Discount]),0),isnull(Sum([Tax Amount]),0),
						isnull(Sum([Net Amount]),0)
	FROM #DETAIL
	SELECT * FROM #DETAIL ORDER BY SHEETCAPTION
	DELETE FROM #DETAIL WHERE SHEETCAPTION=' Detail'
	
	SELECT     			'Datewise-Productwise ' SheetCaption,	
						[Sales Invoice Date], 
						[Delivery Status], 
						[Company Product Code],
                        Brand_Caption,
						[Dist. Product Code],
						[Product Name], 
						Batch, 
						MRP, 
						[Selling Rate],
						SUM([Quantity Billed]) [Quantity Billed],
						SUM([Gross Amount]) [Gross Amount],
						SUM([Special Discount]) [Special Discount],
						SUM([Product Special Discount]) [Product Special Discount],
						SUM([Product Scheme Discount]) [Product Scheme Discount],
						SUM([Distributor Discount]) [Distributor Discount],
						SUM([Cash Discount]) [Cash Discount],
						SUM([Tax Amount]) [Tax Amount],
						SUM([Net Amount]) [Net Amount]
	INTO #DETAIL2		FROM #DETAIL
	GROUP BY			[Sales Invoice Date], 
						[Delivery Status], 
						[Company Product Code],
                        Brand_Caption,
						[Dist. Product Code],
						[Product Name], 
						Batch, 
						MRP, 
						[Selling Rate]
	INSERT INTO #DETAIL2 SELECT ' Datewise-Productwise','Totals','','','','','','',0,0,isnull(sum([Quantity Billed]),0),isnull(SUM([Gross Amount]),0),isnull(SUM([Special Discount]),0),
						isnull(SUM([Product Special Discount]),0),isnull(Sum([Product Scheme Discount]),0),isnull(Sum([Distributor Discount]),0),isnull(Sum([Cash Discount]),0),isnull(Sum([Tax Amount]),0),
						isnull(Sum([Net Amount]),0)
	FROM #DETAIL2
	SELECT				* FROM #DETAIL2 ORDER BY SHEETCAPTION
	
	SELECT     			'Product Summary ' SheetCaption,	
						[Delivery Status],
						[Company Product Code],
                        Brand_Caption,
						[Dist. Product Code],
						[Product Name], 
						Batch, 
						MRP, 
						[Selling Rate],
						SUM([Quantity Billed]) [Quantity Billed],
						SUM([Gross Amount]) [Gross Amount],
						SUM([Special Discount]) [Special Discount],
						SUM([Product Special Discount]) [Product Special Discount],
						SUM([Product Scheme Discount]) [Product Scheme Discount],
						SUM([Distributor Discount]) [Distributor Discount],
						SUM([Cash Discount]) [Cash Discount],
						SUM([Tax Amount]) [Tax Amount],
						SUM([Net Amount]) [Net Amount]
						FROM #DETAIL
	GROUP BY			
						[Delivery Status],
						[Company Product Code],
                        Brand_Caption,
						[Dist. Product Code],
						[Product Name], 
						Batch, 
						MRP, 
						[Selling Rate]
	UNION
	SELECT     			' Product Summary' SheetCaption,	
						' Totals',
						'',
						'',
						'', 
						'', 
                        '',
						0, 
						0,
						SUM([Quantity Billed]) [Quantity Billed],
						SUM([Gross Amount]) [Gross Amount],
						SUM([Special Discount]) [Special Discount],
						SUM([Product Special Discount]) [Product Special Discount],
						SUM([Product Scheme Discount]) [Product Scheme Discount],
						SUM([Distributor Discount]) [Distributor Discount],
						SUM([Cash Discount]) [Cash Discount],
						SUM([Tax Amount]) [Tax Amount],
						SUM([Net Amount]) [Net Amount]
						FROM #DETAIL 	ORDER BY SHEETCAPTION
END
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE Xtype='U' AND [Name]='RptBillWisePrdWiseTaxBreakup')
DROP TABLE RptBillWisePrdWiseTaxBreakup
GO
CREATE TABLE RptBillWisePrdWiseTaxBreakup
	(
	[SlNo] [int] NULL,
	[SalInvDate] [datetime] NULL,
	[SalinvNo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Salid] [int] NULL,
	[RMId] [int] NULL,
	[RMName] [varchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Rtrid] [int] NULL,
	[RtrCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Lcnid] [int] NULL,
	[Cmpid] [int] NULL,
	[PrdCtgValMainId] [int] NULL,
	[CmpPrdCtgId] [int] NULL,
	[Prdid] [int] NULL,
	[Prdccode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Prdbatid] [int] NULL,
	[PrdBatCode] [varchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Rate] [numeric](36, 4) NULL,
	[SalesQty] [int] NULL,
	[FreeQty] [int] NULL,
	[TotQty] [int] NULL,
	[GrossAmt] [numeric](36, 4) NULL,
	[SchemeAmt] [numeric](36, 4) NULL,
	[SplDiscount] [numeric](36, 4) NULL,
	[CashDiscount] [numeric](36, 4) NULL,
	[TotalDiscount] [numeric](36, 4) NULL,
	[TaxPer] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TaxAmount] [numeric](36, 4) NULL,
	[TotalTax] [numeric](36, 4) NULL,
	[NetAmount] [numeric](36, 4) NULL,
	[DiscBreakup] [int] NULL,
	[QtyBreakup] [int] NULL,
	[TaxBreakup] [int] NULL,
	[Usrid] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE Xtype='U' AND [Name]='RptWithOutTaxBreakup_Excel')
DROP TABLE RptWithOutTaxBreakup_Excel
GO
CREATE TABLE RptWithOutTaxBreakup_Excel
	(
	[Bill Date] [datetime] NULL,
	[Bill No] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Route Name] [varchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Retailer Code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Retailer Name] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Code] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Name] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Batch Code] [varchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Selling Rate] [numeric](36, 4) NULL,
	[Sales Qty] [int] NULL,
	[Offer Qty] [int] NULL,
	[Total Qty] [int] NULL,
	[Gross Amt] [numeric](36, 4) NULL,
	[Scheme Amt] [numeric](36, 4) NULL,
	[SplDiscount] [numeric](36, 4) NULL,
	[Cash Discount] [numeric](36, 4) NULL,
	[Total Discount] [numeric](36, 4) NULL,
	[Total Tax Amount] [numeric](36, 4) NULL,
	[NetAmount] [numeric](36, 4) NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE Xtype='U' AND [Name]='RptBillWisePrdWise')
DROP TABLE RptBillWisePrdWise
GO
CREATE TABLE RptBillWisePrdWise
	(
	[SlNo] [int] NULL,
	[SalInvDate] [datetime] NULL,
	[SalinvNo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Salid] [int] NULL,
	[RmId] [int] NULL,
	[RmName] [varchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Rtrid] [int] NULL,
	[RtrCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Lcnid] [int] NULL,
	[Cmpid] [int] NULL,
	[PrdCtgValMainId] [int] NULL,
	[CmpPrdCtgId] [int] NULL,
	[Prdid] [int] NULL,
	[Prdccode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Prdbatid] [int] NULL,
	[PrdBatCode] [varchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Rate] [numeric](36, 4) NULL,
	[SalesQty] [int] NULL,
	[FreeQty] [int] NULL,
	[TotQty] [int] NULL,
	[GrossAmt] [numeric](36, 4) NULL,
	[SchemeAmt] [numeric](36, 4) NULL,
	[SplDiscount] [numeric](36, 4) NULL,
	[CashDiscount] [numeric](36, 4) NULL,
	[TotalDiscount] [numeric](36, 4) NULL,
	[TaxPerc] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TaxAmount] [numeric](38, 4) NULL,
	[TotalTax] [numeric](36, 4) NULL,
	[NetAmount] [numeric](36, 4) NULL,
	[DiscBreakup] [int] NULL,
	[QtyBreakup] [int] NULL,
	[TaxBreakup] [int] NULL,
	[Usrid] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptBillWisePrdWise')
DROP PROCEDURE Proc_RptBillWisePrdWise
GO
-- EXEC Proc_RptBillWisePrdWise 183,1
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
        SET @TaxBreakup=2
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
			INSERT INTO RptBillWisePrdWiseTaxBreakup
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
IF EXISTS (SELECT [Name] FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptBillWisePrdWiseOutPut')
DROP PROCEDURE Proc_RptBillWisePrdWiseOutPut
GO
-- exec [Proc_RptBillWisePrdWiseOutPut] 183,1,0,'Henkel',0,0,1
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
EXEC Proc_RptBillWisePrdWise @Pi_RptId,@Pi_UsrId
SET @TaxBreakup=2	
SELECT DISTINCT @DiscBreakup=DiscBreakup FROM RptBillWisePrdWise WHERE UsrId=@Pi_UsrId
SELECT DISTINCT @QtyBreakup=QtyBreakup FROM RptBillWisePrdWise WHERE UsrId=@Pi_UsrId
INSERT INTO #RptWithOutTaxBreakup (SalInvDate,SalinvNo,RouteName,RtrCode,RtrName,Prdccode,
		 PrdName,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,
		 SplDiscount,CashDiscount,TotalDiscount,TotalTax,NetAmount,DiscBreakup,QtyBreakup,TaxBreakup)
	SELECT SalInvDate,SalinvNo,RmName,RtrCode,RtrName,Prdccode,
		PrdName,PrdBatCode, dbo.Fn_ConvertCurrency(Rate,@Pi_CurrencyId),SalesQty,FreeQty,TotQty,
		dbo.Fn_ConvertCurrency(GrossAmt,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(SchemeAmt,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(SplDiscount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CashDiscount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(TotalDiscount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(TotalTax,@Pi_CurrencyId),
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
INSERT INTO RptWithOutTaxBreakup_Excel([Bill Date],[Bill No],[Route Name],[Retailer Code],[Retailer Name],[Product Code],[Product Name],
				[Batch Code],[Selling Rate],[Sales Qty],[Offer Qty],[Total Qty],[Gross Amt],[Scheme Amt],[SplDiscount],
				[Cash Discount],[Total Discount],[Total Tax Amount],[NetAmount ])
SELECT SalInvDate,SalinvNo,RouteName,RtrCode,RtrName,Prdccode,
		 PrdName,PrdBatCode,Rate,SalesQty,FreeQty,TotQty,GrossAmt,SchemeAmt,
		 SplDiscount,CashDiscount,TotalDiscount,TotalTax,NetAmount from #RptWithOutTaxBreakup
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
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND Name='Proc_GR_CrossTabJCWise')
DROP PROCEDURE Proc_GR_CrossTabJCWise
GO
-- EXEC Proc_GR_CrossTabJCWise 'Retailer Buying Trend-JCWise Report','2011-11-01','2011-11-30','','','','','',''          
	CREATE PROCEDURE Proc_GR_CrossTabJCWise                  
	(                  
	@Pi_RptName  NVARCHAR(100),                  
	@Pi_FromDate DATETIME,                  
	@Pi_ToDate  DATETIME,                  
	@Pi_Filter1  NVARCHAR(100),               
	@Pi_Filter2  NVARCHAR(100),                  
	@Pi_Filter3  NVARCHAR(100),                  
	@Pi_Filter4  NVARCHAR(100),                  
	@Pi_Filter5  NVARCHAR(100),                  
	@Pi_Filter6  NVARCHAR(100)                  
	)                  
	AS                   
	/*******************************************************************************                  
	* PROCEDURE     :Proc_GR_CrossTabJCWise              
	* PURPOSE       :To Get JCWISE(Month) Details - Dynamic report purpose               
	* CREATED BY    :Jayakumar.E                  
	* CREATED DATE  :06/05/2011                   
	---------------------------------------------------------------------------------                  
	* {date}       {developer}  {brief modification description}                  
	*********************************************************************************/                  
	BEGIN                  
	DECLARE @PHLEVEL VARCHAR(7500)                  
	DECLARE @SQL_STR1 VARCHAR(8000)                  
	DECLARE @SQL_STR2 VARCHAR(8000)                  
	DECLARE @CAPHLEVEL VARCHAR(8000)                  
	     
	DECLARE @SName    Varchar(100)                  
	DECLARE @RName    Varchar(100)                  
	DECLARE @RetName  Varchar(100)                  
	DECLARE @RtrId   INT                  
	DECLARE @RetCode  Varchar(100)                  
	DECLARE @MonthId     INT                  
	DECLARE @YearId      INT                   
	DECLARE @Qty      INT                  
	DECLARE @GAmt     Numeric(38,6)                  
	DECLARE @NetAmt     Numeric(38,6)                  
	DECLARE @Monthname   varchar(8000)                  
	DECLARE @sStrql varchar(8000)                  
	DECLARE @Cnt as INT                  
	DECLARE @MntCnt as INT                  
	         
	SET @Pi_FILTER1='%'+ISNULL(@Pi_FILTER1,'')+'%'                          
	SET @Pi_FILTER2='%'+ISNULL(@Pi_FILTER2,'')+'%'                          
	SET @Pi_FILTER3='%'+ISNULL(@Pi_FILTER3,'')+'%'                          
	SET @Pi_FILTER4='%'+ISNULL(@Pi_FILTER4,'')+'%'                          
	SET @Pi_FILTER5='%'+ISNULL(@Pi_FILTER5,'')+'%'                    
	SET @Pi_FILTER6='%'+ISNULL(@Pi_FILTER6,'')+'%'                    
	          
	      
	-------------------FILTER OUT THE REQUIRED RECORDS HERE                  
	SELECT a.* INTO #SALINV FROM SALESINVOICE A,ROUTEMASTER B, SALESMAN C, RETAILER D  ,TBL_GR_BUILD_RH E                  
	WHERE  salinvdate between @pi_fromdate and @pi_todate                   
	AND A.RMID=B.RMID AND B.RMNAME LIKE @PI_FILTER5 and E.RTRID=A.RTRID                    
	and DLVSTS in (4,5) and C.SMID=A.SMID AND C.SMNAME LIKE @PI_FILTER1  AND A.RTRID=D.RTRID                   
	AND D.RTRNAME LIKE @PI_FILTER4 AND E.HASHPRODUCTS LIKE @PI_FILTER2                    
	     
	SELECT A.* INTO #SALESINVOICEPRODUCT FROM SALESINVOICEPRODUCT A,TBL_GR_BUILD_PH C, #SALINV D                  
	WHERE A.SALID=D.SALID AND A.PRDID=C.PRDID AND  HASHPRODUCTS LIKE @PI_FILTER6                   
	-----------------------------------------------------------------         
	SELECT   
	Jcmid,JcmJc,ColName,JCMSDT,JCMEDT INTO #JCWISE FROM         
	(Select A.JcmJc,A.Jcmid,A.JCMSDT,A.JCMEDT,  'JC'+ Cast(A.JcmJc as varchar(10)) +'-'+ Cast(B.JCMYR as varchar(10)) as ColName----,JcmSDt,JcmEdt          
	From JCMonth A INNER JOIN JCMAST B ON A.JCMID=B.JCMID Where           
	A.JcmId in ( Select Jcmid From JcMast Where JcmYr between Year(@pi_fromdate) and Year(@pi_todate) )          
	and @pi_fromdate between JcmSdt and  JcmEdt           
	or  @pi_todate between JcmSdt and  JcmEdt          
	Or  JCmSdt between @pi_fromdate and @pi_todate            
	or  JcmSdt between @pi_fromdate and @pi_todate           
	) A order by A.Jcmid,A.JcmJc           
	------------------------------------------------------------------------              
	SELECT   
	SMNAME [Salesman Name],RMNAME [Route Name] ,RH.HIERARCHY3CAP [Retailer Hierarchy 1] ,  
	RH.HIERARCHY2CAP [Retailer Hierarchy 2],RH.HIERARCHY1CAP [Retailer Hierarchy 3],RET.RTRCODE [Retailer Code],  
	RET.RTRNAME [Retailer Name],'' [No OF Bills],'' [No OF Lines],CAST(0 AS INT) AS  [Total Quantity],CAST(0 AS NUMERIC(18,6)) AS  [Gross Amount],  
	CAST(0 AS NUMERIC(18,6)) AS [Net Amount]                
	INTO #OVERALL                  
	FROM                   
	#JCWISE,#SALINV SI,#SALESINVOICEPRODUCT SP,RETAILER RET,SALESMAN SM,ROUTEMASTER RM,                  
	TBL_GR_BUILD_RH RH,TBL_GR_BUILD_PH PH                  
	WHERE                 
	salinvdate BETWEEN JCMSDT AND JCMEDT AND DLVSTS in (4,5) AND                 
	SI.SALID=SP.SALID AND SI.RTRID=RET.RTRID AND SI.RTRID=RH.RTRID                   
	AND PH.PRDID=SP.PRDID AND SM.SMID=SI.SMID AND RM.RMID=SI.RMID ----------------and si.rtrid  = 28                  
	GROUP BY SMNAME,RMNAME,RET.RTRCODE,RET.RTRNAME,RH.HIERARCHY2CAP,RH.HIERARCHY1CAP,RH.HIERARCHY3CAP               
	---------------------------------------------------------------------------------------------           
	 
	DECLARE @C_SSQL  varchar(8000)                  
	DECLARE @Column  Varchar(100)                  
	DECLARE @YearCnt  INT                  
	DECLARE @monthCnt INT                  
	DECLARE @COLNAME VARCHAR(8000)                
	DECLARE  @sColumnName Varchar(8000)                  
	DECLARE  @sColumnNameTable Varchar(8000)                  
	DECLARE  @sColumnNameSum   Varchar(8000)                  
	DECLARE @iCnt INT                  
	Set @iCnt = 0                  
	Set @sColumnName = ''                  
	Set @sColumnNameTable = ''                  
	DECLARE @JCMJC INT                
	DECLARE @JCMYR INT           
	DECLARE @JCMID INT           
	    
	     
	DECLARE Column_Cur CURSOR FOR                  
	SELECT   
	jcmJc,Jcmid,COLNAME --RIGHT(COLNAME,10)                  
	FROM #JCWISE   
	Order By Jcmid asc,jcmJc --LEFT(COLNAME,4)--RIGHT(COLNAME,10)                
	OPEN Column_Cur                   
	FETCH NEXT FROM Column_Cur INTO @JCMJC, @JCMID,@Column                
	WHILE @@FETCH_STATUS = 0                  
	BEGIN                  
	print @column                
	SET @C_SSQL='ALTER TABLE #OverAll  ADD ['+ @Column +'] NUMERIC(38,6) NOT NULL DEFAULT 0 WITH VALUES'                  
	EXEC (@C_SSQL)                  
		If @sColumnName = ''                  
		BEgin                  
			SET @sColumnName =  '['+@Column+']'                  
			SET @sColumnNameTable = '['+@Column+']' + ' NUMERIC(38,6)'                  
			SET @sColumnNameSum = 'Sum(' + '['+@Column+']' + ') ' + '['+@Column+']'                   
		END                  
	SET @iCnt=@iCnt+1                  
	FETCH NEXT FROM Column_Cur INTO  @JCMJC, @JCMID,@Column                
	END                  
	CLOSE Column_Cur                  
	DEALLOCATE Column_Cur                  
	     
	     
	DECLARE @FielName1 as Varchar(50)                
	DECLARE @Fromdate as DATETIME                
	DECLARE @Todate as DATETIME                
	DECLARE @SSQL as Varchar(8000)                
	    
	DECLARE Cur_LastYear CURSOR                
	FOR SELECT ColName,JcmSdt,JcmEdt FROM #JCWISE  Order By JcmJc              
	OPEN Cur_LastYear                
	FETCH NEXT FROM Cur_LastYear INTO @FielName1,@Fromdate,@Todate                
	WHILE @@FETCH_STATUS=0                
	BEGIN          
	SELECT SM.SMNAME,SI.RtrId,R.RTRCODE,RM.RMNAME,CAST(SUM(SIP.BASEQTY) AS INT)QTY,SUM(SIP.PRDGROSSAMOUNT)GAMT,SUM(SIP.PRDNETAMOUNT) NETAMT        
	INTO #TempCurYearSales                 
	FROM #SALESINVOICEPRODUCT SIP                
	INNER JOIN SalesInvoice SI  ON SI.Salid=SIP.Salid     
	INNER JOIN Salesman SM on SM.SmId=SI.SmId    
	INNER JOIN RouteMaster RM  ON RM.RMID=SI.RMID    
	INNER JOIN Retailer R ON R.RTRID=SI.RTRID                
	WHERE  SI.Salinvdate Between @Fromdate and  @Todate AND SI.DLVSTS in (4,5)                  
	GROUP BY SI.RtrId,SM.SMNAME,RM.RMNAME,R.RTRCODE                
	SET @ssql ='Update RJ SET ['+ @FielName1 +']=T.NETAMT FROM #OVERALL RJ  INNER JOIN #TempCurYearSales T'+         
	' ON [Retailer Code]=T.RTRCODE AND [Salesman Name]=T.SMNAME AND [Route Name]=T.RMNAME '      
	EXEC(@SSQL)                
	DROP TABLE #TempCurYearSales                
	FETCH NEXT FROM Cur_LastYear INTO  @FielName1,@Fromdate,@Todate                
	END                
	CLOSE Cur_LastYear                
	DEALLOCATE Cur_LastYear                
	     
	UPDATE A SET [Net Amount]=B.NETAMT,[Gross Amount]=B.GAMT,[Total Quantity]=B.QTY FROM #OVERALL A INNER JOIN                 
	(      
	SELECT SM.SMNAME,R.RTRCODE,RM.RMNAME,CAST(SUM(SIP.BASEQTY) AS INT)QTY,SUM(SIP.PRDGROSSAMOUNT)GAMT,SUM(SIP.PRDNETAMOUNT) NETAMT                  
	FROM #SALESINVOICEPRODUCT SIP                
	INNER JOIN SalesInvoice SI  ON SI.Salid=SIP.Salid       
	INNER JOIN Salesman SM on SM.SmId=SI.SmId    
	INNER JOIN RouteMaster RM  ON RM.RMID=SI.RMID    
	INNER JOIN Retailer R ON R.RTRID=SI.RTRID          
	WHERE  SI.Salinvdate Between @pi_fromdate and  @pi_Todate AND SI.DLVSTS in (4,5)                  
	GROUP BY SM.SMNAME,R.RTRCODE,RM.RMNAME  
	)B ON [Retailer Code]=B.RTRCODE  AND [Salesman Name]=B.SMNAME  AND [Route Name]=B.RMNAME 

	UPDATE OL SET  [No OF Bills]=NoofBills,[No OF Lines]=NoOfLines FROM #OVERALL OL INNER JOIN
		( SELECT R.RtrCode,RM.RMName,SM.SMName,IsNull(Count(DISTINCT SIP.SalId),0) NoofBills,IsNull(Count(DISTINCT SIP.PrdId),0) NoOfLines FROM SalesInvoice SI
		INNER JOIN SalesInvoiceProduct SIP ON SIP.SalId=SI.SalId 
		INNER JOIN Retailer R ON R.RtrId=SI.RtrId 
		INNER JOIN RouteMaster RM ON RM.RMid=SI.RMId
		INNER JOIN SalesMan SM ON Sm.SMid=SI.SmId 
		WHERE SI.SalInvDate BETWEEN @pi_fromdate and  @pi_Todate AND SI.DLVSTS in (4,5) GROUP BY R.RtrCode,RM.RMName,SM.SMName
		) X ON 
		[Retailer Code]=X.RtrCode  AND [Salesman Name]=X.SMName  AND [Route Name]=X.RMName 
	
	Select  'Retailer Buying Trend-JCWise Report',* from #OverAll    
END     
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='U' AND [Name]='Cs2Cn_DBDetailsUpload')
DROP TABLE Cs2Cn_DBDetailsUpload
CREATE TABLE Cs2Cn_DBDetailsUpload
(
[SlNo] Int IDENTITY(1,1),
[Distributor Code] Varchar(25),
[Ip Address] Varchar(25),
[Machine Name] Varchar(25),
[DB Id] Int,
[DB Name] Varchar(25),
[DBCreatedDate]Datetime,
[DBRestoredDate] DateTime,
[DbresoredId] Int,
[DBFileName] Varchar(100),
[DB Size] Varchar(25),
[UploadFlag] Varchar(1)
)
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='sp_get_ip_address')
DROP PROCEDURE sp_get_ip_address
GO
Create Procedure sp_get_ip_address (@ip varchar(40) out)
as
begin
Declare @ipLine varchar(200)
Declare @pos int
set nocount on
          set @ip = NULL
          Create table #temp (ipLine varchar(200))
          Insert #temp exec master..xp_cmdshell 'ipconfig'
          select @ipLine = ipLine
          from #temp
          where upper (ipLine) like '%IP ADDRESS%'
          if (isnull (@ipLine,'***') != '***')
          begin 
                set @pos = CharIndex (':',@ipLine,1);
                set @ip = rtrim(ltrim(substring (@ipLine , 
               @pos + 1 ,
                len (@ipLine) - @pos)))
           end 
drop table #temp
set nocount off
end 
go
If Exists (Select [Name] From SysObjects Where Xtype='P' And [Name]='sp_get_ip_address')
Drop Procedure sp_get_ip_address
GO
Create Procedure sp_get_ip_address (@ip varchar(40) out)
as
begin
Declare @ipLine varchar(200)
Declare @pos int
set nocount on
          set @ip = NULL
          Create table #temp (ipLine varchar(200))
          Insert #temp exec master..xp_cmdshell 'ipconfig'
          select @ipLine = ipLine
          from #temp
          where upper (ipLine) like '%IP ADDRESS%'
          if (isnull (@ipLine,'***') != '***')
          begin 
                set @pos = CharIndex (':',@ipLine,1);
                set @ip = rtrim(ltrim(substring (@ipLine , 
               @pos + 1 ,
                len (@ipLine) - @pos)))
           end 
drop table #temp
set nocount off
end 
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_Cs2Cn_DBDetailsUpload')
DROP PROCEDURE Proc_Cs2Cn_DBDetailsUpload
GO
-- Exec Proc_Cs2Cn_DBDetailsUpload 0
CREATE PROCEDURE Proc_Cs2Cn_DBDetailsUpload
(
	@Po_ErrNo	INT OUTPUT
)
AS 
BEGIN
/*********************************  
* PROCEDURE: Proc_Cs2Cn_DBDetailsUpload  
* PURPOSE: Extract Database details from CoreStocky to Console  
* NOTES:  
* CREATED: Praveenraj B 
* DATE: 10-12-2011
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/
DECLARE @DistCode AS VarChar(25)
DECLARE @DbName AS VarChar(25)
DECLARE @MachineName AS VarChar(25)
DECLARE @DbSize AS VarChar(25)
DECLARE @DBid AS Int
DECLARE @DBCretaedDate AS DateTime
DECLARE @IpAddress AS VarChar(25)
DECLARE @DBResoreId AS Int 
DECLARE @DBRestoreDate AS DateTime
DECLARE @Filename AS VarChar(100)
SET Nocount ON 
	DELETE FROM Cs2Cn_DBDetailsUpload WHERE UploadFlag='Y'
	SELECT @DistCode=Distributorcode FROM Distributor
	Create TABLE  #Temp 
      (
	 SPID int not null
	 , Status varchar (255) not null
	 , Login varchar (255) not null
	 , HostName varchar (255) not null
	 , BlkBy varchar(10) not null
	 , DBName varchar (255) null
	 , Command varchar (255) not null
	 , CPUTime int not null
	 , DiskIO int not null
	 , LastBatch varchar (255) not null
	 , ProgramName varchar (255) null
	 , SPID2 int not null
	 , REQUESTID INT
	)  
	INSERT INTO #Temp EXEC sp_who2  
	SELECT @DbName=DbName,@MachineName=HostName FROM #Temp WHERE Status='RUNNABLE'

Create Table  #Temp1 
     (
	[Name] varchar (255),
	  DbSize varchar (255),
	  Owner varchar (255), 
	  DBid varchar (255), 
	  Createddate DateTime,
        Status varchar (255), 
	  [Level] varchar (255)
	 )  
INSERT INTO #Temp1 EXEC master.dbo.sp_helpdb
SELECT @DbSize=DbSize,@DbId=Dbid,@DBCretaedDate=Createddate FROM #Temp1 WHERE [Name]=@DbName
EXEC sp_get_ip_address @IpAddress Out
SELECT @Filename=Physical_Name FROM sys.master_files WHERE Database_Id=@DbId AND Physical_Name LIKE '%mdf'
SELECT @DBRestoreDate=Max(Restore_Date),@DBResoreId=max(restore_history_id) FROM msdb.dbo.restorehistory WHERE destination_database_name=@DbName
INSERT INTO Cs2Cn_DBDetailsUpload([Distributor Code],[Ip Address],[Machine Name],[DB Id],[DB Name],[DBCreatedDate],
[DBRestoredDate],[DbresoredId],[DBFileName],[DB Size],[UploadFlag])
SELECT  @DistCode,@IpAddress,@MachineName,@DBid,@DbName,@DBCretaedDate,@DBRestoreDate,@DBResoreId,@Filename,@DbSize,'N'
UPDATE Cs2Cn_DBDetailsUpload SET UploadFlag='Y' WHERE UploadFlag='N'
END 
GO
------ MsgBox For Salesman Edit
DELETE FROM CustomCaptions WHERE TransId=68 AND CtrlId=1000 AND SubCtrlId=25
INSERT INTO CustomCaptions
SELECT 68,1000,25,'Msgbox-68-1000-25','','','Cannot Edit SalesmanName Transaction Exists Do You Want To Continue',1,1,1,GetDate(),1,Getdate(),'','','Cannot Edit SalesmanName Transaction Exists Do You Want To Continue',1,1
GO
------ Configuration For Salesman Edit Option
DELETE FROM Configuration WHERE ModuleName='Salesman' AND ModuleId='SAL3'
INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'SAL3','Salesman','Restrict editing of salesman name if any transaction is performed or master mapping is done',0,'',0.00,3
GO
------ Configuration For Grouping MRP Product(Non Drug)
DELETE FROM Configuration WHERE ModuleName='Botree Bill Printing' AND ModuleId='BotreeBillPrinting01'
INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'BotreeBillPrinting01','Botree Bill Printing','Hide the batch codes and display billed quantity based on MRP for Non drug products',
0,'',0.00,1
GO
------ Configuration For Curren Stock Excel Report
DELETE FROM Configuration WHERE ModuleName='Report Configuration' AND ModuleId='RepConfig'
INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
SELECT 'RepConfig','Report Configuration','Take Current Stock report uom based excel sheet in the following path…',0,'','0.00',1
GO
IF EXISTS(Select * from Sysobjects Where Xtype = 'U' and Name = 'ETL_Prk_CS2CNBLRetailer')
DROP TABLE ETL_Prk_CS2CNBLRetailer
GO
CREATE TABLE [dbo].[ETL_Prk_CS2CNBLRetailer](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId] [int] NULL,
	[RtrCde] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrNm] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrAddress1] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrAddress2] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrAddress3] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrPINCode] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrPhoneNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrEmailId] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrContactPerson] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrCrBills] [int] NULL,
	[RtrCrLimit] [numeric](18, 2) NULL,
	[RtrCrDays] [int] NULL,
	[RtrCashDiscPerc] [numeric](18, 2) NULL,
	[RtrCategoryLevelId] [int] NULL,
	[RtrCategoryCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrChannelCde] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrGroupCde] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrClassCde] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KeyAccount] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RelationStatus] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrRegDate] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevel] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevelValue] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalesRouteCode] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalesRouteName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrShipAdd1] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrShipAdd2] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrShipAdd3] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrShipPinNo] [int] NULL,
	[RtrCovMode] [tinyint] NULL,
	[RtrResPhone1] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrResPhone2] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrOffPhone1] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrOffPhone2] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrDOB] [datetime] NOT NULL,
	[RtrAnniversary] [datetime] NOT NULL,
	[Status] [tinyint] NULL,
	[UploadFlag] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
IF EXISTS ( Select * from Sysobjects where Xtype = 'P' And Name = 'Proc_CS2CN_BLRetailer')
DROP PROCEDURE Proc_CS2CN_BLRetailer 
GO
/*  
BEGIN TRANSACTION  
EXEC Proc_CS2CN_BLRetailer 0  
SELECT * FROM ETL_Prk_CS2CNBLRetailer ORDER BY SlNo  
ROLLBACK TRANSACTION  
*/  
  
CREATE   PROCEDURE [dbo].[Proc_CS2CN_BLRetailer]  
(  
 @Po_ErrNo INT OUTPUT  
)  
AS  
SET NOCOUNT ON  
BEGIN  
/*********************************  
* PROCEDURE : Proc_CS2CN_BLRetailer  
* PURPOSE : Extract Retailer Details from CoreStocky to Console  
* NOTES  :  
* CREATED : Nandakumar R.G 09-01-2009  
* MODIFIED  
* DATE			AUTHOR				DESCRIPTION  
------------------------------------------------  
* 16.12.2011	Vijendra Kumar		Added for Details for CR
***************************************************************/  
 DECLARE @CmpID   AS INTEGER  
 DECLARE @DistCode As nVarchar(50)  
   
 DELETE FROM ETL_Prk_CS2CNBLRetailer WHERE UploadFlag = 'Y'  
 SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1   
 SELECT @DistCode = DistributorCode FROM Distributor  
  
 INSERT INTO ETL_Prk_CS2CNBLRetailer  
  (  
   DistCode ,			RtrId ,				RtrCde ,			RtrNm ,				 RtrAddress1,		RtrAddress2	,		RtrAddress3,   
   RtrPINCode,			RtrPhoneNo,			RtrEmailId,			RtrContactPerson,    RtrCrBills,		RtrCrLimit,			RtrCrDays,		
   RtrCashDiscPerc,		RtrCategoryLevelId, RtrCategoryCode,	RtrChannelCde ,      RtrGroupCde ,		RtrClassCde ,		SalesRouteCode,
   SalesRouteName,	    RtrShipAdd1,		RtrShipAdd2,		RtrShipAdd3,		 RtrShipPinNo,		RtrCovMode,			RtrResPhone1,
   RtrResPhone2,	    RtrOffPhone1,		RtrOffPhone2,		RtrDOB,				 RtrAnniversary,	Status,				KeyAccount,			
   RelationStatus,      ParentCode,			RtrRegDate,			GeoLevel,			 GeoLevelValue,     UploadFlag  
  )  
  SELECT  
   @DistCode ,  
   R.RtrId ,  
   R.RtrCode ,  
   R.RtrName ,
   ISNULL(R.RtrAdd1,'') RtrAddress1,
   ISNULL(R.RtrAdd2,'') RtrAddress2,
   ISNULL(R.RtrAdd3,'') RtrAddress3,
   ISNULL(R.RtrPinNo,'') RtrPinNo,
   ISNULL(R.RtrPhoneNo,'') RtrPhoneNo,
   ISNULL(R.RtrEmailId,'') RtrEmailId,
   ISNULL(R.RtrContactPerson,'') RtrContactPerson,
   R.RtrCrBills,R.RtrCrLimit,R.RtrCrDays,R.RtrCashDiscPerc,RC.CtgLevelId,RC1.CtgCode,  
   RC1.CtgCode ,  
   RC.CtgCode ,  
   RVC.ValueClassCode ,  
	RM.RMCode,RM.RMName,RSA.RtrShipAdd1,RSA.RtrShipAdd2,RSA.RtrShipAdd3,RSA.RtrShipPinNo,
		R.RtrResPhone1,R.RtrResPhone2,R.RtrOffPhone1,R.RtrOffPhone2,R.RtrDOB,R.RtrAnniversary,R.RtrCovMode,
   RtrStatus,   
   CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,  
   CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,  
   (CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,  
   CONVERT(VARCHAR(10),R.RtrRegDate,121),ISNULL(GL.GeoLevelName,'') AS GeoLevelName,ISNULL(G.GeoName,'') AS GeoName,'N'      
  FROM    
   RetailerValueClassMap RVCM ,  
   RetailerValueClass RVC ,  
   RetailerCategory RC ,  
   RetailerCategoryLevel RCL,
   RetailerShipAdd RSA,  
   RouteMaster RM,
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
   ISNULL(R.RtrAdd1,'') RtrAddress1,
   ISNULL(R.RtrAdd2,'') RtrAddress2,
   ISNULL(R.RtrAdd3,'') RtrAddress3,
   ISNULL(R.RtrPinNo,'') RtrPinNo,
   ISNULL(R.RtrPhoneNo,'') RtrPhoneNo,
   ISNULL(R.RtrEmailId,'') RtrEmailId,
   ISNULL(R.RtrContactPerson,'') RtrContactPerson,
   R.RtrCrBills,R.RtrCrLimit,R.RtrCrDays,R.RtrCashDiscPerc,RC.CtgLevelId,RC1.CtgCode,
   RC1.CtgCode,  
   RC.CtgCode,  
   RVC.ValueClassCode,  
   RM.RMCode,RM.RMName,RSA.RtrShipAdd1,RSA.RtrShipAdd2,RSA.RtrShipAdd3,RSA.RtrShipPinNo,
		R.RtrResPhone1,R.RtrResPhone2,R.RtrOffPhone1,R.RtrOffPhone2,R.RtrDOB,R.RtrAnniversary,R.RtrCovMode,
   RtrStatus,  
   CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,  
   CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,  
   (CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,  
   CONVERT(VARCHAR(10),R.RtrRegDate,121),ISNULL(GL.GeoLevelName,'') AS GeoLevelName,ISNULL(G.GeoName,'') AS GeoName,'N'     
  FROM  
   RouteMaster RM,RetailerClassficationChange RCC  
   INNER JOIN RetailerValueClass RVC ON RVC.RtrClassId=RCC.RtrClassficationId  
   INNER JOIN RetailerCategory RC ON RC.CtgMainId=RCC.CtgMainId  
   INNER JOIN RetailerCategoryLevel RL ON RL.CtgLevelId=RCC.CtgLevelId  
   INNER JOIN RetailerCategory RC1 ON RC1.CtgMainId=RC.CtgLinkId  
   INNER JOIN Retailer R ON R.RtrId=RCC.RtrId  
   LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE  
   INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId  
   LEFT OUTER JOIN Geography G ON G.GeoMainId=R.GeoMainId   
   LEFT OUTER JOIN GeographyLevel GL ON GL.GeoLevelId=G.GeoLevelId  
   INNER JOIN  RetailerShipAdd RSA ON RSA.RtrId=R.RtrId   
 UPDATE Retailer SET Upload='Y' WHERE Upload='N'   
 AND RtrCode IN(SELECT RtrCde FROM ETL_Prk_CS2CNBLRetailer)  
END
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'Proc_IOTaxSummary')
DROP PROCEDURE Proc_IOTaxSummary
GO
CREATE PROCEDURE [dbo].[Proc_IOTaxSummary]  
(  
 @Pi_UserId  INT  
)  
/************************************************************  
* VIEW : SP_RptIOTaxSummary  
* PURPOSE : To get the Tax Summary details  
* CREATED BY : Jisha Mathew  
* CREATED DATE : 03/08/2007  
* NOTE  :  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date}        {developer}  {brief modification description}  
* 06/02/2008   Nanda        Added Return and Replacement details  
*************************************************************/  
AS  
BEGIN  
 Delete from TmpRptIOTaxSummary where UserId in (0,@Pi_UserId)  
 --Taxable Amount for Purchase  
 Insert INTO TmpRptIOTaxSummary (InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,  
 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)  
 Select distinct PR.PurRcptId AS InvId,PR.PurRcptRefNo AS RefNo,PR.CmpInvNo AS CmpInvNo,PR.InvDate as InvDate,  
 S.SpmId As SpmId,0 AS SmId,0 AS RmId,0 AS RtrId,P.PrdId as Prdid,PRP.PrdBatId AS PrdBatId,SUM(PRP.InvBaseQty) AS InvQty,PRP.PrdLSP as PrdLSP,  
 Sum(PRP.PrdGrossAmount) AS GrossAmount,C.CmpId AS CmpId,  
 'Taxable Amount '+Cast(Left(TaxPerc,4) as Varchar(10))+'%' as TaxPerc ,Sum(TaxableAmount) as TaxableAmount,  
 'Purchase' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,PT.TaxId,@Pi_UserId AS UserId  
 From PurchaseReceipt PR WITH (NOLOCK)  --Select * from PurchaseReceipt
 INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK) ON PR.PurRcptId = PRP.PurRcptId  
 INNER JOIN PurchaseReceiptProductTax PT WITH (NOLOCK) ON PR.PurRcptId = PT.PurRcptId AND PRP.PrdSlNo = PT.PrdSlNo AND PRP.PurRcptId = PT.PurRcptId  
 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId  
 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = PRP.PrdId AND PB.PrdBatId = PRP.PrdBatId AND PB.PrdId = P.PrdId  
 INNER jOIN Supplier S WITH (NOLOCK) ON PR.SpmId = S.SpmId  
 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
 WHERE PR.Status = 1    
 Group By TaxPerc,PR.InvDate,C.CmpId,P.PrdId,PR.PurRcptId,PR.PurRcptRefNo,PR.CmpInvNo,  
 S.SpmId,PRP.PrdBatId,PRP.PrdLSP,PT.TaxId  
 Having Sum(TaxableAmount) >= 0  
 --Tax Amount for Purchase  
 Insert INTO TmpRptIOTaxSummary (InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,  
 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)  
 Select distinct PR.PurRcptId AS InvId,PR.PurRcptRefNo AS RefNo,PR.CmpInvNo AS CmpInvNo,PR.InvDate as InvDate,  
 S.SpmId As SpmId,0 AS SmId,0 AS RmId,0 AS RtrId,P.PrdId as Prdid,PRP.PrdBatId AS PrdBatId,SUM(PRP.InvBaseQty) AS InvQty,PRP.PrdLSP as PrdLSP,  
 Sum(PRP.PrdGrossAmount) AS GrossAmount,C.CmpId AS CmpId,  
 'Tax Amount '+Cast(Left(TaxPerc,4) as Varchar(10))+'%' as TaxPerc ,Sum(PT.TaxAmount) as TaxableAmount,  
 'Purchase' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,PT.TaxId,@Pi_UserId AS UserId  
 From PurchaseReceipt PR WITH (NOLOCK)  
 INNER JOIN PurchaseReceiptProduct PRP WITH (NOLOCK) ON PR.PurRcptId = PRP.PurRcptId  
 INNER JOIN PurchaseReceiptProductTax PT WITH (NOLOCK) ON PR.PurRcptId = PT.PurRcptId AND PRP.PrdSlNo = PT.PrdSlNo AND PRP.PurRcptId = PT.PurRcptId  
 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId  
 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = PRP.PrdId AND PB.PrdBatId = PRP.PrdBatId AND PB.PrdId = P.PrdId  
 INNER jOIN Supplier S WITH (NOLOCK) ON PR.SpmId = S.SpmId  
 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
 WHERE PR.Status = 1    
 Group By TaxPerc,PR.InvDate,C.CmpId,P.PrdId,PR.PurRcptId,PR.PurRcptRefNo,PR.CmpInvNo,  
  S.SpmId,PRP.PrdBatId,PRP.PrdLSP,PT.TaxId  
 Having Sum(PT.TaxAmount) >= 0  
 --Taxable Amount for Purchase Return  
 Insert INTO TmpRptIOTaxSummary (InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,  
 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)  
 Select distinct PR.PurRetId AS InvId,PR.PurRetRefNo AS RefNo,PR.CmpInvNo AS CmpInvNo,PR.PurRetDate as InvDate,  
 S.SpmId As SpmId,0 AS SmId,0 AS RmId,0 AS RtrId,P.PrdId as Prdid,PRP.PrdBatId AS PrdBatId,PRP.RetSalBaseQty AS InvQty,PRP.PrdLSP as PrdLSP,  
 -1 * Sum(PRP.PrdGrossAmount) AS GrossAmount,C.CmpId AS CmpId,  
 'Taxable Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,-1 * Sum(TaxableAmount) as TaxableAmount,  
 'PurchaseReturn' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,PT.TaxId,@Pi_UserId AS UserId  
 From PurchaseReturn PR WITH (NOLOCK) 
 INNER JOIN PurchaseReturnProduct PRP WITH (NOLOCK) ON PR.PurRetId = PRP.PurRetId  
 INNER JOIN PurchaseReturnProductTax PT WITH (NOLOCK) ON PR.PurRetId = PT.PurRetId AND PRP.PrdSlNo = PT.PrdSlNo AND PRP.PurRetId = PT.PurRetId  
 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId  
 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = PRP.PrdId AND PB.PrdBatId = PRP.PrdBatId AND PB.PrdId = P.PrdId  
 INNER jOIN Supplier S WITH (NOLOCK) ON PR.SpmId = S.SpmId  
 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
 WHERE PR.Status = 1  
 Group By TaxPerc,PR.PurRetDate,C.CmpId,P.PrdId,PR.PurRetId,PR.PurRetRefNo,PR.CmpInvNo,  
 S.SpmId,PRP.PrdBatId,PRP.RetSalBaseQty,PRP.PrdLSP,PT.TaxId  
 Having Sum(TaxableAmount) >= 0  
 --Tax Amount for Purchase Return  
 Insert INTO TmpRptIOTaxSummary (InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,  
 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)  
 Select distinct PR.PurRetId AS InvId,PR.PurRetRefNo AS RefNo,PR.CmpInvNo AS CmpInvNo,PR.PurRetDate as InvDate,  
 S.SpmId As SpmId,0 AS SmId,0 AS RmId,0 AS RtrId,P.PrdId as Prdid,PRP.PrdBatId AS PrdBatId,PRP.RetSalBaseQty AS InvQty,PRP.PrdLSP as PrdLSP,  
 -1 * Sum(PRP.PrdGrossAmount) AS GrossAmount,C.CmpId AS CmpId,  
 'Tax Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,-1 * Sum(PT.TaxAmount) as TaxableAmount,  
 'PurchaseReturn' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,PT.TaxId,@Pi_UserId AS UserId  
 From PurchaseReturn PR WITH (NOLOCK)  
 INNER JOIN PurchaseReturnProduct PRP WITH (NOLOCK) ON PR.PurRetId = PRP.PurRetId  
 INNER JOIN PurchaseReturnProductTax PT WITH (NOLOCK) ON PR.PurRetId = PT.PurRetId AND PRP.PrdSlNo = PT.PrdSlNo AND PRP.PurRetId = PT.PurRetId  
 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = PRP.PrdId  
 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = PRP.PrdId AND PB.PrdBatId = PRP.PrdBatId AND PB.PrdId = P.PrdId  
 INNER jOIN Supplier S WITH (NOLOCK) ON PR.SpmId = S.SpmId  
 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
 WHERE PR.Status = 1  
 Group By TaxPerc,PR.PurRetDate,C.CmpId,P.PrdId,PR.PurRetId,PR.PurRetRefNo,PR.CmpInvNo,  
 S.SpmId,PRP.PrdBatId,PRP.RetSalBaseQty,PRP.PrdLSP,PT.TaxId  
 Having Sum(PT.TaxAmount) >= 0  
 --Taxable Amount for Sales  
 Insert INTO TmpRptIOTaxSummary (InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,  
 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)  
 Select distinct  SI.SalId AS InvId,SI.SalInvNo AS RefNo,'' AS CmpInvNo,SI.SalInvDate as InvDate,  
 0 As SpmId,SM.SmId AS SmId,RM.RmId AS RmId,R.RtrId AS RtrId,P.PrdId as Prdid,PB.PrdBatId AS PrdBatId,SIP.BaseQty AS InvQty  
 ,SIP.PrdUnitSelRate as PrdLSP,Sum(SIP.PrdGrossAmount) AS GrossAmount,C.CmpId AS CmpId,  
 'Taxable Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,Sum(TaxableAmount) as TaxableAmount,  
 'Sales' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,SPT.TaxId,@Pi_UserId AS UserId  
 From SalesInvoice SI WITH (NOLOCK)  
 INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SI.SalId = SIP.SalId  
 INNER JOIN SalesInvoiceProductTax SPT WITH (NOLOCK) ON SPT.SalId = SIP.SalId AND SPT.SalId = SI.SalId AND SIP.SlNo=SPT.PrdSlNo  
 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = SIP.PrdId    
 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = SIP.PrdId AND PB.PrdBatId = SIP.PrdBatId AND PB.PrdId = P.PrdId  
 INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = SI.RtrId   
 INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = SI.SmId   
 INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = SI.RmId    
 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
 WHERE SI.DlvSts in (4,5)  
 Group By TaxPerc,SI.SalInvDate,C.CmpId,P.PrdId,SI.SalId,SI.SalInvNo,R.RtrId,PB.PrdBatId,  
 SIP.BaseQty,SIP.PrdUnitSelRate,SM.SmId,RM.RmId,SPT.TaxId  
 Having Sum(TaxableAmount) >= 0  
 --Tax Amount for Sales  
 Insert INTO TmpRptIOTaxSummary (InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,  
 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)  
 Select distinct  SI.SalId AS InvId,SI.SalInvNo AS RefNo,'' AS CmpInvNo,SI.SalInvDate as InvDate,  
 0 As SpmId,SM.SmId AS SmId,RM.RmId AS RmId,R.RtrId AS RtrId,P.PrdId as Prdid,PB.PrdBatId AS PrdBatId,SIP.BaseQty AS InvQty  
 ,SIP.PrdUnitSelRate as PrdLSP,Sum(SIP.PrdGrossAmount) AS GrossAmount,C.CmpId AS CmpId,  
 'Tax Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,Sum(SPT.TaxAmount) as TaxableAmount,  
 'Sales' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,SPT.TaxId,@Pi_UserId AS UserId  
 From SalesInvoice SI WITH (NOLOCK)  
 INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SI.SalId = SIP.SalId  
 INNER JOIN SalesInvoiceProductTax SPT WITH (NOLOCK) ON SPT.SalId = SIP.SalId AND SPT.SalId = SI.SalId AND SIP.SlNo=SPT.PrdSlNo  
 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = SIP.PrdId    
 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = SIP.PrdId AND PB.PrdBatId = SIP.PrdBatId AND PB.PrdId = P.PrdId  
 INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = SI.RtrId    
 INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = SI.SmId   
 INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = SI.RmId   
 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
 WHERE SI.DlvSts in (4,5)  
 Group By TaxPerc,SI.SalInvDate,C.CmpId,P.PrdId,SI.SalId,SI.SalInvNo,R.RtrId,PB.PrdBatId,  
 SIP.BaseQty,SIP.PrdUnitSelRate,SM.SmId,RM.RmId,SPT.TaxId  
 Having Sum(SPT.TaxAmount) >= 0  
 --Taxable Amount for SalesReturn  
 Insert INTO TmpRptIOTaxSummary (InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,  
 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)  
 SELECT InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,  
 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId FROM (  
  Select distinct RH.ReturnId AS InvId,RH.ReturnCode AS RefNo,'' AS CmpInvNo,Rh.ReturnDate as InvDate,  
  0 As SpmId,SM.SmId AS SmId,RM.RmId AS RmId,R.RtrId AS RtrId,P.PrdId as Prdid,PB.PrdBatId AS PrdBatId,RP.BaseQty AS InvQty,  
  RP.PrdUnitSelRte as PrdLSP,-1 * Sum(RP.PrdGrossAmt) AS GrossAmount,C.CmpId AS CmpId,  
  'Taxable Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,-1 * Sum(TaxableAmt) as TaxableAmount,  
  'SalesReturn' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,RPT.TaxId,@Pi_UserId AS UserId  
  From ReturnHeader RH WITH (NOLOCK)  
  INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1  
  INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo  
  INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = RP.PrdId    
  INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = RP.PrdId AND PB.PrdBatId = RP.PrdBatId AND PB.PrdId = P.PrdId  
  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId  
  INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = RH.SmId   
  INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = RH.RmId    
  LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
  WHERE RH.Status = 0   
  Group By TaxPerc,RH.ReturnDate,C.CmpId,P.PrdId,RH.ReturnId,RH.ReturnCode,R.RtrId,PB.PrdBatId,  
  RP.BaseQty,RP.PrdUnitSelRte,SM.SmId,RM.RmId,RPT.TaxId  
  Having Sum(TaxableAmt) >= 0  
 UNION  
  Select distinct RH.ReturnId AS InvId,RH.ReturnCode AS RefNo,'' AS CmpInvNo,Rh.ReturnDate as InvDate,  
  0 As SpmId,SM.SmId AS SmId,RM.RmId AS RmId,R.RtrId AS RtrId,P.PrdId as Prdid,PB.PrdBatId AS PrdBatId,RP.BaseQty AS InvQty,  
  RP.PrdUnitSelRte as PrdLSP,-1 * Sum(RP.PrdGrossAmt) AS GrossAmount,C.CmpId AS CmpId,  
  'Taxable Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,-1 * Sum(TaxableAmt) as TaxableAmount,  
  'SalesReturn' as IOTaxType,0 as TaxFlag,TaxPerc as TaxPercent,RPT.TaxId,@Pi_UserId AS UserId  
  From ReturnHeader RH WITH (NOLOCK)  
  INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1  
  INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo  
  INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = RP.PrdId    
  INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = RP.PrdId AND PB.PrdBatId = RP.PrdBatId AND PB.PrdId = P.PrdId  
  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId  
  INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = RH.SmId   
  INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = RH.RmId    
  LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
  WHERE RH.Status = 0   
  Group By TaxPerc,RH.ReturnDate,C.CmpId,P.PrdId,RH.ReturnId,RH.ReturnCode,R.RtrId,PB.PrdBatId,  
  RP.BaseQty,RP.PrdUnitSelRte,SM.SmId,RM.RmId,RPT.TaxId  
  Having Sum(TaxableAmt) >= 0  
 ) A  
 --Tax Amount for SalesReturn  
 Insert INTO TmpRptIOTaxSummary (InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,  
 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)  
 SELECT InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,  
 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId FROM  (  
  Select distinct RH.ReturnId AS InvId,RH.ReturnCode AS RefNo,'' AS CmpInvNo,Rh.ReturnDate as InvDate,  
  0 As SpmId,SM.SmId AS SmId,RM.RmId AS RmId,R.RtrId AS RtrId,P.PrdId as Prdid,PB.PrdBatId AS PrdBatId,RP.BaseQty AS InvQty,  
  RP.PrdUnitSelRte as PrdLSP,-1 * Sum(RP.PrdGrossAmt) AS GrossAmount,C.CmpId AS CmpId,  
  'Tax Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,-1 * Sum(RPT.TaxAmt) as TaxableAmount,  
  'SalesReturn' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,RPT.TaxId,@Pi_UserId AS UserId  
  From ReturnHeader RH WITH (NOLOCK)  
  INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1  
  INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo  
  INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = RP.PrdId    
  INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = RP.PrdId AND PB.PrdBatId = RP.PrdBatId AND PB.PrdId = P.PrdId  
  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId   
  INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = RH.SmId   
  INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = RH.RmId   
  LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
  WHERE RH.Status = 0   
  Group By TaxPerc,RH.ReturnDate,C.CmpId,P.PrdId,RH.ReturnId,RH.ReturnCode,R.RtrId,PB.PrdBatId,  
  RP.BaseQty,RP.PrdUnitSelRte,SM.SmId,RM.RmId,RPT.TaxId  
  Having Sum(RPT.TaxAmt) >= 0  
 UNION  
  Select distinct RH.ReturnId AS InvId,RH.ReturnCode AS RefNo,'' AS CmpInvNo,Rh.ReturnDate as InvDate,  
  0 As SpmId,SM.SmId AS SmId,RM.RmId AS RmId,R.RtrId AS RtrId,P.PrdId as Prdid,PB.PrdBatId AS PrdBatId,RP.BaseQty AS InvQty,  
  RP.PrdUnitSelRte as PrdLSP,-1 * Sum(RP.PrdGrossAmt) AS GrossAmount,C.CmpId AS CmpId,  
  'Tax Amount '+Cast(Left(TaxPerc,4) AS Varchar(10))+'%' as TaxPerc,-1 * Sum(RPT.TaxAmt) as TaxableAmount,  
  'SalesReturn' as IOTaxType,1 as TaxFlag,TaxPerc as TaxPercent,RPT.TaxId,@Pi_UserId AS UserId  
  From ReturnHeader RH WITH (NOLOCK)  
  INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId AND RP.LineType=1  
  INNER JOIN ReturnProductTax RPT WITH (NOLOCK) ON RPT.ReturnId = RH.ReturnId AND RPT.ReturnId = RP.ReturnId AND RP.SlNo=RPT.PrdSlNo  
  INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = RP.PrdId    
  INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = RP.PrdId AND PB.PrdBatId = RP.PrdBatId AND PB.PrdId = P.PrdId  
  INNER JOIN Retailer R WITH (NOLOCK) ON R.RtrId = RH.RtrId   
  INNER JOIN Salesman SM WITH (NOLOCK) ON SM.SmId = RH.SmId   
  INNER JOIN RouteMaster RM WITH (NOLOCK) ON RM.RmId = RH.RmId   
  LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
  WHERE RH.Status = 0   
  Group By TaxPerc,RH.ReturnDate,C.CmpId,P.PrdId,RH.ReturnId,RH.ReturnCode,R.RtrId,PB.PrdBatId,  
  RP.BaseQty,RP.PrdUnitSelRte,SM.SmId,RM.RmId,RPT.TaxId  
  Having Sum(RPT.TaxAmt) >= 0  
 ) A  
 SELECT RepRefNo   
 INTO #NotDelivered  
 FROM ReplacementHd RH (NOLOCK),SalesInvoice SI (NOLOCK)  
 WHERE RH.SalId>0 AND RH.SalId=SI.SalId AND SI.DlvSts NOT IN (4,5)   
 --Taxable Amount for Return & Replacement (Return)  
 Insert INTO TmpRptIOTaxSummary (InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,  
 Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)  
 SELECT DISTINCT 0 AS InvId,RH.RepRefNo AS RefNo,'' AS CmpInvNo,RH.RepDate AS InvDate,  
 0 AS SpmId,Rtr.SMId,Rtr.RMId,RH.RtrId,P.PrdId,PB.PrdBatId,RI.RtnQty AS InvQty,  
 RI.SelRte AS PrdLSP,-1*SUM(RI.SelRte*RI.RtnQty) AS GrossAmount,C.CmpId AS CmpId,  
 'Taxable Amount '+CAST(LEFT(TaxPerc,4) AS NVARCHAR(10))+'%' AS TaxPerc,-1*SUM(TaxableAmount) AS TaxableAmount,  
 'SalesReturn' AS IOTaxType,0 AS TaxFlag,TaxPerc AS TaxPercent,RIT.TaxId,@Pi_UserId AS UserId  
 FROM ReplacementHd RH WITH (NOLOCK)  
 INNER JOIN ReplacementIn RI WITH (NOLOCK) ON RI.RepRefNo=RH.RepRefNo AND RH.SalId=0  
 INNER JOIN ReplacementInPrdTax RIT WITH (NOLOCK) ON RI.RowId=RIT.RowId AND RH.RepRefNo=RIT.RepRefNo  
 INNER JOIN (SELECT MIN(A.SMId) AS SMId,MIN(A.RMId) AS RMId,A.RtrId  
   FROM Retailer B  
   INNER JOIN  
   (SELECT RH.RtrId,R.RMId,S.SMId  
   FROM ReplacementHd RH WITH (NOLOCK)  
   INNER JOIN RetailerMarket RM WITH (NOLOCK) ON RH.RtrId=RM.RtrId  
   INNER JOIN RouteMaster R WITH (NOLOCK) ON R.RMId=RM.RMId  
   INNER JOIN SalesmanMarket SM WITH (NOLOCK) ON SM.RMId=RM.RMId  
   INNER JOIN Salesman S WITH (NOLOCK) ON S.SMId=SM.SMId  
   ) AS A  
   ON A.RtrId=B.RtrId  
   GROUP BY A.RtrId  
      ) AS Rtr ON Rtr.RtrId=RH.RtrId  
 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = RI.PrdId    
 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = RI.PrdId AND PB.PrdBatId = RI.PrdBatId AND PB.PrdId = P.PrdId  
 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
 WHERE RH.RepRefNo NOT IN (SELECT RepRefNo FROM #NotDelivered)  
 GROUP BY RH.RepRefNo,RH.RepDate,Rtr.SMId,Rtr.RMId,RH.RtrId,P.PrdId,PB.PrdBatId,RI.RtnQty,RI.SelRte,C.CmpId,RIT.TaxPerc,RIT.TaxId  
 HAVING SUM(RIT.TaxableAmount) >= 0  
 --Tax Amount for Return & Replacement (Return)  
 INSERT INTO TmpRptIOTaxSummary (InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,  
 Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)  
 SELECT DISTINCT 0 AS InvId,RH.RepRefNo AS RefNo,'' AS CmpInvNo,RH.RepDate AS InvDate,  
 0 AS SpmId,Rtr.SMId,Rtr.RMId,RH.RtrId,P.PrdId,PB.PrdBatId,RI.RtnQty AS InvQty,  
 RI.SelRte AS PrdLSP,-1*SUM(RI.SelRte*RI.RtnQty) AS GrossAmount,C.CmpId AS CmpId,  
 'Tax Amount '+CAST(LEFT(TaxPerc,4) AS NVARCHAR(10))+'%' AS TaxPerc,-1*SUM(TaxAmount) AS TaxableAmount,  
 'SalesReturn' AS IOTaxType,1 AS TaxFlag,TaxPerc AS TaxPercent,RIT.TaxId,@Pi_UserId AS UserId  
 FROM ReplacementHd RH WITH (NOLOCK)  
 INNER JOIN ReplacementIn RI WITH (NOLOCK) ON RI.RepRefNo=RH.RepRefNo AND RH.SalId=0  
 INNER JOIN ReplacementInPrdTax RIT WITH (NOLOCK) ON RI.RowId=RIT.RowId AND RH.RepRefNo=RIT.RepRefNo  
 INNER JOIN (SELECT MIN(A.SMId) AS SMId,MIN(A.RMId) AS RMId,A.RtrId  
   FROM Retailer B  
   INNER JOIN  
   (SELECT RH.RtrId,R.RMId,S.SMId  
   FROM ReplacementHd RH WITH (NOLOCK)  
   INNER JOIN RetailerMarket RM WITH (NOLOCK) ON RH.RtrId=RM.RtrId  
   INNER JOIN RouteMaster R WITH (NOLOCK) ON R.RMId=RM.RMId  
   INNER JOIN SalesmanMarket SM WITH (NOLOCK) ON SM.RMId=RM.RMId  
   INNER JOIN Salesman S WITH (NOLOCK) ON S.SMId=SM.SMId  
   ) AS A  
   ON A.RtrId=B.RtrId  
   GROUP BY A.RtrId  
      ) AS Rtr ON Rtr.RtrId=RH.RtrId  
 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = RI.PrdId    
 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = RI.PrdId AND PB.PrdBatId = RI.PrdBatId AND PB.PrdId = P.PrdId  
 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
 WHERE RH.RepRefNo NOT IN (SELECT RepRefNo FROM #NotDelivered)  
 GROUP BY RH.RepRefNo,RH.RepDate,Rtr.SMId,Rtr.RMId,RH.RtrId,P.PrdId,PB.PrdBatId,RI.RtnQty,RI.SelRte,C.CmpId,RIT.TaxPerc,RIT.TaxId  
 HAVING SUM(RIT.TaxAmount) >= 0  
 --Taxable Amount for Return & Replacement (Replacement)  
 INSERT INTO TmpRptIOTaxSummary (InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,  
 Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)  
 SELECT DISTINCT 0 AS InvId,RH.RepRefNo AS RefNo,'' AS CmpInvNo,RH.RepDate AS InvDate,  
 0 AS SpmId,Rtr.SMId,Rtr.RMId,RH.RtrId,P.PrdId,PB.PrdBatId,RO.RepQty AS InvQty,  
 RO.SelRte AS PrdLSP,SUM(RO.SelRte*RO.RepQty) AS GrossAmount,C.CmpId AS CmpId,  
 'Taxable Amount '+CAST(LEFT(TaxPerc,4) AS NVARCHAR(10))+'%' AS TaxPerc,SUM(TaxableAmount) AS TaxableAmount,  
 'Sales' AS IOTaxType,0 AS TaxFlag,TaxPerc AS TaxPercent,ROT.TaxId,@Pi_UserId AS UserId  
 FROM ReplacementHd RH WITH (NOLOCK)  
 INNER JOIN ReplacementOut RO WITH (NOLOCK) ON RO.RepRefNo=RH.RepRefNo  
 INNER JOIN ReplacementOutPrdTax ROT WITH (NOLOCK) ON RO.RowId=ROT.RowId AND RH.RepRefNo=ROT.RepRefNo  
 INNER JOIN (SELECT MIN(A.SMId) AS SMId,MIN(A.RMId) AS RMId,A.RtrId  
   FROM Retailer B  
   INNER JOIN  
   (SELECT RH.RtrId,R.RMId,S.SMId  
   FROM ReplacementHd RH WITH (NOLOCK)  
   INNER JOIN RetailerMarket RM WITH (NOLOCK) ON RH.RtrId=RM.RtrId  
   INNER JOIN RouteMaster R WITH (NOLOCK) ON R.RMId=RM.RMId  
   INNER JOIN SalesmanMarket SM WITH (NOLOCK) ON SM.RMId=RM.RMId  
   INNER JOIN Salesman S WITH (NOLOCK) ON S.SMId=SM.SMId  
   ) AS A  
   ON A.RtrId=B.RtrId  
   GROUP BY A.RtrId  
      ) AS Rtr ON Rtr.RtrId=RH.RtrId  
 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = RO.PrdId    
 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = RO.PrdId AND PB.PrdBatId = RO.PrdBatId AND PB.PrdId = P.PrdId  
 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
 WHERE RH.RepRefNo NOT IN (SELECT RepRefNo FROM #NotDelivered)  
 GROUP BY RH.RepRefNo,RH.RepDate,Rtr.SMId,Rtr.RMId,RH.RtrId,P.PrdId,PB.PrdBatId,RO.RepQty,RO.SelRte,C.CmpId,ROT.TaxPerc,ROT.TaxId  
 HAVING SUM(ROT.TaxableAmount) >= 0  
 --Tax Amount for Return & Replacement (Replacement)  
 INSERT INTO TmpRptIOTaxSummary (InvId,RefNo,CmpInvNo,InvDate,SpmId,SmId,RmId,RtrId,  
 Prdid,PrdBatId,InvQty,PrdLSP,GrossAmount,CmpId,TaxPerc,TaxableAmount,IOTaxType,TaxFlag,TaxPercent,TaxId,UserId)  
 SELECT DISTINCT 0 AS InvId,RH.RepRefNo AS RefNo,'' AS CmpInvNo,RH.RepDate AS InvDate,  
 0 AS SpmId,Rtr.SMId,Rtr.RMId,RH.RtrId,P.PrdId,PB.PrdBatId,RO.RepQty AS InvQty,  
 RO.SelRte AS PrdLSP,SUM(RO.SelRte*RO.RepQty) AS GrossAmount,C.CmpId AS CmpId,  
 'Tax Amount '+CAST(LEFT(TaxPerc,4) AS NVARCHAR(10))+'%' AS TaxPerc,SUM(TaxAmount) AS TaxableAmount,  
 'Sales' AS IOTaxType,1 AS TaxFlag,TaxPerc AS TaxPercent,ROT.TaxId,@Pi_UserId AS UserId  
 FROM ReplacementHd RH WITH (NOLOCK)  
 INNER JOIN ReplacementOut RO WITH (NOLOCK) ON RO.RepRefNo=RH.RepRefNo  
 INNER JOIN ReplacementOutPrdTax ROT WITH (NOLOCK) ON RO.RowId=ROT.RowId AND RH.RepRefNo=ROT.RepRefNo  
 INNER JOIN (SELECT MIN(A.SMId) AS SMId,MIN(A.RMId) AS RMId,A.RtrId  
   FROM Retailer B  
   INNER JOIN  
   (SELECT RH.RtrId,R.RMId,S.SMId  
   FROM ReplacementHd RH WITH (NOLOCK)  
   INNER JOIN RetailerMarket RM WITH (NOLOCK) ON RH.RtrId=RM.RtrId  
   INNER JOIN RouteMaster R WITH (NOLOCK) ON R.RMId=RM.RMId  
   INNER JOIN SalesmanMarket SM WITH (NOLOCK) ON SM.RMId=RM.RMId  
   INNER JOIN Salesman S WITH (NOLOCK) ON S.SMId=SM.SMId  
   ) AS A  
   ON A.RtrId=B.RtrId  
   GROUP BY A.RtrId  
      ) AS Rtr ON Rtr.RtrId=RH.RtrId  
 INNER JOIN Product P WITH (NOLOCK) ON P.PrdId = RO.PrdId    
 INNER JOIN ProductBatch PB WITH (NOLOCK) ON PB.PrdId = RO.PrdId AND PB.PrdBatId = RO.PrdBatId AND PB.PrdId = P.PrdId  
 LEFT OUTER JOIN Company C ON C.CmpId = P.CmpId   
 WHERE RH.RepRefNo NOT IN (SELECT RepRefNo FROM #NotDelivered)  
 GROUP BY RH.RepRefNo,RH.RepDate,Rtr.SMId,Rtr.RMId,RH.RtrId,P.PrdId,PB.PrdBatId,RO.RepQty,RO.SelRte,C.CmpId,ROT.TaxPerc,ROT.TaxId  
 HAVING SUM(ROT.TaxAmount) >= 0  
--select * from TmpRptIOTaxSummary where InvDate='2008-02-05'  
END
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'U' And Name = 'SalesInvoiceEditableHistory')
DROP TABLE SalesInvoiceEditableHistory
GO
CREATE TABLE SalesInvoiceEditableHistory
(
	[Salid] [bigint] NULL,
	[Rtrid] [int] NULL,
	[EditCount] [int] NULL,
	[LastEditingDate] [datetime] NULL
)
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_RptPendingBillReport')
DROP PROCEDURE Proc_RptPendingBillReport
GO
--EXEC Proc_RptPendingBillReport 3,1,0,'Dabur1',0,0,1
CREATE PROCEDURE Proc_RptPendingBillReport
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
	DECLARE @Orderby AS Int
	SET @Orderby=0 
	SET @Orderby = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,276,@Pi_UsrId))
	PRINT @Orderby
	PRINT @RPTBasedON
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
--	IF @RPTBasedON=1
--		BEGIN 
--			SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays DESC
--        END 
--	
	IF @Orderby=0 AND @RPTBasedON=0 
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays,SMName 
		END 
	IF @Orderby=1 AND @RPTBasedON=0  
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays,RMName 
		END
	IF @Orderby=2 AND @RPTBasedON=0  
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays,RtrName 
		END
	IF @Orderby=3 AND @RPTBasedON=0  
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays,SalInvNo 
		END
	ELSE 
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays DESC
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
	DELETE FROM RptFilter WHERE rptid=18 AND SelcId=275
GO
	INSERT INTO RptFilter 
	SELECT 18,275,1,'DEFAULT'
	UNION ALL 
	SELECT 18,275,2,'Product Hierarchy '
GO
	DELETE FROM RptDetails WHERE rptid=18 AND SelcId=275
	INSERT INTO RptDetails
	SELECT 18,12,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Display Based ON*...','',1,'',275,1,1,'Press F4/Double Click to Select Display Based ON',0
	DELETE FROM RptSelectionHd WHERE  SelcId=275
	INSERT INTO RptSelectionHd
	SELECT 275,'Sel_ReportType','Product Hierarchy Display Report',1
	IF EXISTS (SELECT [Name] FROM SysObjects WHERE Xtype='U' AND [Name]='RtrLoadSheetItemWise')
	DROP TABLE RtrLoadSheetItemWise
GO
CREATE TABLE RtrLoadSheetItemWise
	(
	[SalId] [bigint] NULL,
	[SalInvNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvDate] [datetime] NULL,
	[DlvRMId] [int] NULL,
	[VehicleId] [int] NULL,
	[AllotmentNumber] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SMId] [int] NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdId] [int] NULL,
	[PrdDCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdCtgValMainId] [int] NULL,
	[CmpPrdCtgId] [int] NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MRP] [numeric](38, 6) NULL,
	[SellingRate] [numeric](38, 6) NULL,
	[BillQty] [numeric](38, 0) NULL,
	[FreeQty] [numeric](38, 0) NULL,
	[ReturnQty] [numeric](38, 0) NULL,
	[RepalcementQty] [numeric](38, 0) NULL,
	[TotalQty] [numeric](38, 0) NULL,
	[PrdWeight] [numeric](38, 4) NULL,
	[GrossAmount] [numeric](38, 2) NULL,
	[TaxAmount] [numeric](38, 2) NULL,
	[NetAmount] [numeric](38, 2) NULL,
	[RptId] [int] NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptItemWise')
DROP PROCEDURE Proc_RptItemWise
GO
--EXEC Proc_RptItemWise 2,1
CREATE PROCEDURE Proc_RptItemWise
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
				SMId,RtrId,RtrName,PrdId,PrdDCode,PrdName,PrdCtgValMainId,CmpPrdCtgId,PrdBatId,PrdBatCode,MRP,SellingRate,
				BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,PrdWeight,GrossAmount,TaxAmount,NetAmount,RptId,UsrId)
		SELECT SalId,SalInvNo,SalInvDate,DlvRMId,VehicleId, allotmentid,
				SMId,RtrId,RtrName,
				PrdId,PrdDCode,PrdName,PrdCtgValMainId,CmpPrdCtgId,
				PrdBatId,PrdBatCode,MRP,SellingRate,
				SUM(SalesQty) BillQty,
				SUM(FreeQty) FreeQty,SUM(ReturnQty) ReturnQty,SUM(RepQty) ReplacementQty,
				SUM(SalesQty) + SUM(FreeQty) + SUM(ReturnQty) + SUM(RepQty) TotalQty,SUM(SalesPrdWeight)AS PrdWeight,SUM(SalesGrossValue) AS GrossAmount,
				SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount,
				@Pi_RptId RPtId,@Pi_UsrId USrId
		FROM (
		SELECT X.* ,V.AllotmentId FROM
		(
			SELECT P.SalId,SI.SalInvNo,P.SalInvDate,SI.DlvRMId,SI.VehicleId,
			P.SMId,P.RtrId,R.RtrName,
			P.PrdId,P.PrdDCode,P.PrdName,P.PrdCtgValMainId,P.CmpPrdCtgId,P.PrdBatId,P.PrdBatCode,P.PrdUnitMRP AS MRP,
			P.PrdUnitSelRate AS SellingRate,
			P.SalesQty,P.FreeQty,P.ReturnQty,P.RepQty,P.SalesPrdWeight,P.SalesGrossValue,P.TaxAmount,P.NetAmount
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
		SMId,RtrId,RtrName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,MRP,SellingRate,PrdCtgValMainId,CmpPrdCtgId
END
GO
Delete From RptExcelHeaders Where Rptid = 18
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	1,	'PrdId',	'PrdId',	0,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	2,	'Product Code',	'Product Code',	1,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	3,	'Product Description',	'Product Name',	1,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	4,	'Batch Number',	'Batch Code',	1,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	5,	'MRP',	'MRP',	1,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	6,	'Selling Rate',	'Selling Rate',	1,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	7,	'BillCase',	'Billed Qty in Selected UOM',	1,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	8,	'BillPiece',	'Billed Qty in Piece',	1,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	9,	'Free Qty',	'Free Qty',	1,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	10,	'Return Qty',	'Return Qty',	1,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	11,	'Replacement Qty',	'Replacement Qty',	1,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	12,	'TotalCase',	'Total Qty in Selected UOM',	1,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	13,	'TotalPiece',	'Total Qty in Piece',	1,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	14,	'Total Qty',	'Total Qty',	0,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	15,	'Billed Qty',	'Billed Qty',	0,	1)
Insert Into RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) Values (18,	16,	'NetAmount',	'Net Amount',	1,	1)
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptLoadSheetItemWise')
DROP PROCEDURE Proc_RptLoadSheetItemWise
GO
--EXEC Proc_RptLoadSheetItemWise 18,1,0,'JNJ396',0,0,1
CREATE PROCEDURE Proc_RptLoadSheetItemWise
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
	DECLARE @FromBillNo AS  BIGINT
	DECLARE @ToBillNo   AS  BIGINT
	DECLARE @SalId   AS     BIGINT
	DECLARE @BillNoDisp   AS INT
	DECLARE @DispOrderby AS INT
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
	SET @ToBillNo =(SELECT  MAX(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) 
	SET @DispOrderby=(SELECT TOP 1 iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,275,@Pi_UsrId))
	--Till Here
	DECLARE @RPTBasedON AS INT
	SET @RPTBasedON =0
	SELECT @RPTBasedON = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,257,@Pi_UsrId) 
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	
	
	--Till Here
	CREATE TABLE #RptLoadSheetItemWise
	(
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),
			[PrdId]        	      INT,
			[Product Code]        NVARCHAR (100),
			[Product Description] NVARCHAR(150),
            [PrdCtgValMainId]	  int, 
			[CmpPrdCtgId]		  int,
			[Batch Number]        NVARCHAR(50),
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,----@
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0)	
	)
	
	SET @TblName = 'RptLoadSheetItemWise'
	
	SET @TblStruct = '
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),		
			[PrdId]        	      INT,    	
			[Product Code]        VARCHAR (100),
			[Product Description] VARCHAR(200),
            [PrdCtgValMainId]	  int, 
			[CmpPrdCtgId]		  int, 
			[Batch Number]        VARCHAR(50),		
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0)'
	
	SET @TblFields = '	
			[SalId]
			[BillNo]
			[PrdId]        	      ,
			[Product Code]        ,
			[Product Description] ,
            [PrdCtgValMainId]	  ,
			[CmpPrdCtgId]		  ,
			[Batch Number],
			[MRP]				  ,
			[Selling Rate]
			[Billed Qty]          ,
			[Free Qty]            ,
			[Return Qty]          ,
			[Replacement Qty]     ,
			[Total Qty],
			[PrdWeight],
			[GrossAmount],
			[TaxAmount],[NetAmount],[TotalBills]'
	
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
		IF @FromBillNo <> 0 AND @ToBillNo <> 0
		BEGIN
			INSERT INTO #RptLoadSheetItemWise([SalId],BillNo,PrdId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
				[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],[GrossAmount],
				[TaxAmount],[NetAmount])
	
			SELECT [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],[GrossAmount],[TaxAmount],
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
					
	 AND [SalInvDate] Between @FromDate and @ToDate
--			 AND (SalId Between @FromBillNo and @ToBillNo)
--	
 AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR 
			    SalId in (Select Selvalue from ReportfilterDt Where Rptid = @Pi_RptId and Usrid =@Pi_UsrId))
	
	GROUP BY [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],
	NetAmount,[GrossAmount],[TaxAmount],PrdCtgValMainId,CmpPrdCtgId
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWise([SalId],BillNo,PrdId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
					[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],[GrossAmount],
					[TaxAmount],[NetAmount])
			
			SELECT [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],GrossAmount,TaxAmount,dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId) FROM RtrLoadSheetItemWise
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
					SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )
							
--			 AND [SalInvDate] Between @FromDate and @ToDate
			GROUP BY [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,
			GrossAmount,TaxAmount,[PrdWeight],PrdCtgValMainId,CmpPrdCtgId
		END 
		
		UPDATE #RptLoadSheetItemWise SET TotalBills=(SELECT Count(DISTINCT SalId) FROM #RptLoadSheetItemWise)
	
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
--	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
--	
--	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
--	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptLoadSheetItemWise
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
	SELECT 0 AS [SalId],'' AS BillNo,LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[PrdCtgValMainId],LSB.[CmpPrdCtgId],
    LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],
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
	Sum([PrdWeight]) AS [PrdWeight],
	SUM(LSB.[Billed Qty]) AS [Billed Qty],
	SUM(LSB.GrossAmount) AS GrossAmount,
	SUM(LSB.TaxAmount) AS TaxAmount,
	SUM(LSB.NETAMOUNT) as NETAMOUNT,LSB.TotalBills INTO #Result
	FROM #RptLoadSheetItemWise LSB,Product P 
	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
	WHERE LSB.PrdId=P.PrdId
	GROUP BY LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],UG.ConversionFactor,
	LSB.TotalBills,LSB.[PrdCtgValMainId],LSB.[CmpPrdCtgId]
	Order by LSB.[PrdCtgValMainId],LSB.[CmpPrdCtgId]
---From to
Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #Result
	IF @DispOrderby=1
	BEGIN 
	SELECT * FROM #Result ORDER BY PrdId
	END 
	ELSE
	BEGIN 
	SELECT * FROM #Result ORDER BY PrdCtgValMainId,CmpPrdCtgId
	END 
----Till Here

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptLoadSheetItemWise_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptLoadSheetItemWise_Excel
		SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],
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
		GROUP BY LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],UG.ConversionFactor
		Order by LSB.[Product Description]
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
Delete from RptGroup where Rptid = 154 And GrpCode = 'ProductwiseUOMwiseReport'
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE [Name]='View_CurrentStockReport' AND Xtype='V')
DROP VIEW View_CurrentStockReport
GO
CREATE VIEW View_CurrentStockReport
/************************************************************
* VIEW	: View_CurrentStockReport
* PURPOSE	: To get the Current Stock of the Products with Batch details
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 26/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdCCode,
	Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,
	DPH.SellingRate+TxRpt.SellingTaxAmount AS SelRate,DPH.PurchaseRate+TxRpt.PurchaseTaxAmount AS ListPrice,
	(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
	(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
	(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
	((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
	(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
	(PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP  AS SalMRP,
	(PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP  AS UnSalMRP,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ) AS TotMRP,
	(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS SalSelRate,
	(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS UnSalSelRate,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate+TxRpt.SellingTaxAmount) ) AS TotSelRate,
	(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS SalListPrice,
	(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS UnSalListPrice,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount) ) AS TotListPrice,
	Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,TxRpt.UsrId
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
	ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
	DefaultPriceHistory DPH (NOLOCK) ,
	TaxForReport TxRpt (NOLOCK),
	ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
	AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
	AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
	AND TxRpt.PrdBatId=PrdBat.PrdBatId  AND TxRpt.PrdId=Prd.PrdId AND TxRpt.Rptid=5
	--AND PBDM.DefaultPrice=1  AND PBDR.DefaultPrice=1  AND PBDL.DefaultPrice=1
	--AND PrdBat.DefaultPriceId=PBDM.PriceId  AND PrdBat.DefaultPriceId=PBDR.PriceId  AND PrdBat.DefaultPriceId=PBDL.PriceId
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE [Name]='View_CurrentStockReportNTax' AND Xtype='V')
DROP VIEW View_CurrentStockReportNTax
GO
CREATE View View_CurrentStockReportNTax
/************************************************************
* VIEW	: View_CurrentStockReportNTax
* PURPOSE	: To get the Current Stock of the Products with Batch details (With Out Tax)
* CREATED BY	: Srivatchan
* CREATED DATE	: 24/07/2009
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdCCode,
	Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,
	--DPH.SellingRate+TxRpt.SellingTaxAmount AS SelRate,
	DPH.SellingRate AS SelRate,
	--DPH.PurchaseRate+TxRpt.PurchaseTaxAmount AS ListPrice,
	DPH.PurchaseRate AS ListPrice,
	(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
	(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
	(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
	((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
	(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
	(PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP  AS SalMRP,
	(PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP  AS UnSalMRP,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ) AS TotMRP,
	--(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS SalSelRate,
	(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate)  AS SalSelRate,
	--(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS UnSalSelRate,
	(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate)  AS UnSalSelRate,
	--(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate+TxRpt.SellingTaxAmount) ) AS TotSelRate,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate) ) AS TotSelRate,
	--(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS SalListPrice,
	(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate)  AS SalListPrice,
	(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate)  AS UnSalListPrice,
	--(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS UnSalListPrice,
	--(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount) ) AS TotListPrice,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate) ) AS TotListPrice,
	Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
	ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
	DefaultPriceHistory DPH (NOLOCK) ,
	--TaxForReport TxRpt (NOLOCK),
	ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
	AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
	AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
	--AND TxRpt.PrdBatId=PrdBat.PrdBatId  AND TxRpt.PrdId=Prd.PrdId AND TxRpt.Rptid=5
	--AND PBDM.DefaultPrice=1  AND PBDR.DefaultPrice=1  AND PBDL.DefaultPrice=1
	--AND PrdBat.DefaultPriceId=PBDM.PriceId  AND PrdBat.DefaultPriceId=PBDR.PriceId  AND PrdBat.DefaultPriceId=PBDL.PriceId
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_RptCurrentStock')
DROP PROCEDURE Proc_RptCurrentStock
GO
--Exec [Proc_RptCurrentStock] 5,1,0,'JNJ396',0,0,1,0
CREATE PROCEDURE Proc_RptCurrentStock
(
	@Pi_RptId  INT,
	@Pi_UsrId  INT,
	@Pi_SnapId  INT,
	@Pi_DbName  nvarchar(50),
	@Pi_SnapRequired INT,
	@Pi_GetFromSnap  INT,
	@Pi_CurrencyId  INT,
	@Po_Errno  INT OUTPUT
)
AS
/*********************************
* PROCEDURE : Proc_RptCurrentStock
* PURPOSE : To get the Current Stock details for Report
* CREATED : Nandakumar R.G
* CREATED DATE : 01/08/2007
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
24/07/2009	MarySubashini.S		To add the Tax Validation
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
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
	--Filter Variable
	DECLARE @CmpId          AS Int
	DECLARE @LcnId          AS Int
	DECLARE @CmpPrdCtgId  AS Int
	DECLARE @PrdCtgMainId  AS Int
	DECLARE @StockValue      AS Int
	DECLARE @DispBatch  AS Int
	DECLARE @PrdStatus       AS Int
	DECLARE @PrdBatId        AS Int
	DECLARE @PrdBatStatus       AS Int
	DECLARE @SupTaxGroupId      AS Int
	DECLARE @RtrTaxFroupId      AS Int
	DECLARE @fPrdCatPrdId       AS Int
	DECLARE @fPrdId        AS Int
	DECLARE @SupZeroStock	AS INT
	DECLARE @StockType	AS INT
	DECLARE @RptDispType	AS INT
	--Till Here
	--Assgin Value for the Filter Variable
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @StockValue = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))
	SET @DispBatch = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
	SET @PrdBatStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))
	SET @PrdBatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
	SET @SupTaxGroupId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,18,@Pi_UsrId))
	SET @RtrTaxFroupId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,19,@Pi_UsrId))
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	SET @StockType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))
	SET @RptDispType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,221,@Pi_UsrId))
	IF @DispBatch = 1 
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	--Till Here
	--If Product Category Filter is available
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	--Till Here
	DELETE FROM TaxForReport WHERE UsrId=@Pi_UsrId AND RptId=@Pi_RptId
	IF @SupTaxGroupId<>0 OR @RtrTaxFroupId<>0
	BEGIN
		EXEC Proc_ReportTaxCalculation @SupTaxGroupId,@RtrTaxFroupId,1,20,5,@Pi_UsrId,@Pi_RptId
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
	Create TABLE #RptCurrentStock
	(
		PrdId    INT,
		PrdDcode  NVARCHAR(100),
		PrdCCode  NVARCHAR(100),
		PrdName   NVARCHAR(200),
		PrdBatId              INT,
		PrdBatCode   NVARCHAR(100),
		MRP                NUMERIC (38,6),
		DisplayRate         NUMERIC (38,6),
		Saleable              INT,
		SaleableWgt		NUMERIC (38,6),
		Unsaleable   INT,
		UnsaleableWgt		NUMERIC (38,6),
		Offer                 INT,
		OfferWgt		NUMERIC (38,6),
		DisplaySalRate       NUMERIC (38,6),
		DisplayUnSalRate      NUMERIC (38,6),
		DisplayTotRate        NUMERIC (38,6),
		DispBatch             INT,
		RtrTaxGroup           INT,
		SupTaxGroup           INT,
		StockType			  INT
		
	)
	SET @TblName = 'RptCurrentStock'
	SET @TblStruct = '  PrdId      INT,
						PrdDcode    NVARCHAR(100),
						PrdCCode  NVARCHAR(100),
						PrdName     NVARCHAR(200),
						PrdBatId       INT,
						PrdBatCode     NVARCHAR(100),
						MRP            NUMERIC (38,6),
						DisplayRate    NUMERIC (38,6),
						Saleable       INT,
						SaleableWgt		NUMERIC (38,6),
						Unsaleable		INT,
						UnsaleableWgt	NUMERIC (38,6),
						Offer           INT,
						OfferWgt		NUMERIC (38,6),
						DisplaySalRate    NUMERIC (38,6),
						DisplayUnSalRate   NUMERIC (38,6),
						DisplayTotRate     NUMERIC (38,6),
						DispBatch          INT,
						RtrTaxGroup        INT,
						SupTaxGroup        INT,
						StockType		   INT'
	SET @TblFields = 'PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
	Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType'
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
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data
	BEGIN
		IF @SupTaxGroupId<>0 OR @RtrTaxFroupId<>0
		BEGIN
			IF @DispBatch=2
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReport
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) AND
				UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
			ELSE
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReport
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE -1 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))) AND
				UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
		END
		ELSE
		BEGIN
			IF @DispBatch=2
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReportNTax
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				--AND UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
			ELSE
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReportNTax
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE -1 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				--AND UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
		END
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptCurrentStock ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+' WHERE (CmpId=(CASE '+CAST(@CmpId AS NVARCHAR(10))+' WHEN 0 THEN CmpId ELSE 0 END ) OR
			CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',4,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (LcnId=(CASE '+CAST(@LcnId AS NVARCHAR(10))+' WHEN 0 THEN LcnId ELSE 0 END ) OR
			LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',22,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdId = (CASE '+CAST(@fPrdCatPrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
			PrdId IN (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',26,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdId = (CASE'+CAST(@fPrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
			PrdId in (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',5,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PrdStatus=(CASE '+CAST(@PrdStatus AS NVARCHAR(10))+' WHEN 0 THEN PrdStatus ELSE 0 END ) OR
			PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',24,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (Status=(CASE '+CAST(@PrdBatStatus AS NVARCHAR(10))+' WHEN 0 THEN Status ELSE 0 END ) OR
			Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',25,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate'
			EXEC (@SSQL)
			UPDATE #RptCurrentStock SET DispBatch=@DispBatch
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCurrentStock'
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
			SET @SSQL = 'INSERT INTO #RptCurrentStock ' +
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
	
	IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND  GridFlag=1 AND UsrId=@Pi_UsrId)
	BEGIN
		SELECT a.PrdId,a.PrdDcode,a.PrdCCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.MRP,a.DisplayRate,a.Saleable,
		CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Saleable AS INT)>nullif(ConverisonFactor2,0) Then CAST(Saleable AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END  As Uom1,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
		(CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN Case When CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
		(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
		CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
		(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END as Uom4,
		a.Unsaleable,a.Offer,a.DisplaySalRate,a.DisplayUnSalRate,a.DisplayTotRate,a.DispBatch,a.RtrTaxGroup,a.SupTaxGroup,a.StockType
		INTO #RptColDetails
		FROM #RptCurrentStock A, View_ProdUOMDetails B WHERE a.prdid=b.prdid
		DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
		INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,Rptid,Usrid)
		SELECT PrdDcode,PrdName,PrdBatCode,MRP,DisplayRate,Saleable,Uom1,Uom2,Uom3,Uom4,
		Unsaleable,Offer,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,@Pi_RptId,@Pi_UsrId
		FROM #RptColDetails
	END
	--SELECT @RptDispType
	SET @RptDispType=ISNULL(@RptDispType,1)
	IF @RptDispType=1
	BEGIN
		--TRUNCATE TABLE RptCurrentStock_Excel
		IF @SupZeroStock=1
		BEGIN
			SELECT * FROM #RptCurrentStock
			WHERE Saleable+Unsaleable+Offer <> 0
----			IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND Flag=1 AND UsrId=@Pi_UsrId)
----			BEGIN
----				INSERT INTO RptCurrentStock_Excel
----				SELECT * FROM #RptCurrentStock
----				WHERE (Saleable+UnSaleable+Offer)<>0
----			END
			IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCurrentStock_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE RptCurrentStock_Excel
				SELECT * INTO RptCurrentStock_Excel FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			END 
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			PRINT 'Data Executed'
		END
		ELSE
		BEGIN
			SELECT * FROM #RptCurrentStock
----			IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND Flag=1 AND UsrId=@Pi_UsrId)
----			BEGIN
----				INSERT INTO RptCurrentStock_Excel
----				SELECT * FROM #RptCurrentStock
----			END
			IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCurrentStock_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE RptCurrentStock_Excel
				SELECT * INTO RptCurrentStock_Excel FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			END 
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock 
			PRINT 'Data Executed'
		END
	END
	ELSE
	BEGIN		
		IF @SupZeroStock=1
		BEGIN
			SELECT a.PrdId,a.PrdDcode,a.PrdCCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.MRP,a.DisplayRate,a.Saleable,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Saleable AS INT)>nullif(ConverisonFactor2,0) Then CAST(Saleable AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END  As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			(CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN Case When CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((nullif(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
			CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END as Uom4,
			a.Unsaleable,a.Offer,a.DisplaySalRate,a.DisplayUnSalRate,a.DisplayTotRate,a.DispBatch,a.RtrTaxGroup,a.SupTaxGroup,a.StockType
			FROM #RptCurrentStock A, View_ProdUOMDetails B WHERE a.prdid=b.prdid
			AND (a.Saleable + a.Unsaleable + a.Offer) <> 0
		
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			PRINT 'Data Executed'
		END
		ELSE
		BEGIN
			SELECT a.PrdId,a.PrdDcode,a.PrdCCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.MRP,a.DisplayRate,a.Saleable,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Saleable AS INT)>nullif(ConverisonFactor2,0) Then CAST(Saleable AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END  As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			(CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN Case When CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((nullif(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
			CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END as Uom4,
			a.Unsaleable,a.Offer,a.DisplaySalRate,a.DisplayUnSalRate,a.DisplayTotRate,a.DispBatch,a.RtrTaxGroup,a.SupTaxGroup,a.StockType
			FROM #RptCurrentStock A, View_ProdUOMDetails B WHERE a.prdid=b.prdid
			
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock
			PRINT 'Data Executed'
		END
	END
		DELETE FROM RptExcelHeaders WHERE RptId=5
		DECLARE @COLUMN AS Varchar(80)
		DECLARE @C_SSQL AS Varchar(8000)
		DECLARE @iCnt AS Int 
		SET @iCnt=1
			DECLARE Cur_Col CURSOR FOR  
			SELECT SC.[Name] FROM SysColumns SC,SysObjects So WHERE SC.Id=SO.Id AND SO.[Name]='RptCurrentStock_Excel'
			OPEN Cur_Col
			FETCH NEXT FROM Cur_Col INTO @COLUMN
			WHILE @@FETCH_STATUS = 0
			BEGIN
			SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
			SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
			SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
			EXEC (@C_SSQL)
			SET @iCnt=@iCnt+1
			FETCH NEXT FROM Cur_Col INTO @COLUMN
			END
			CLOSE Cur_Col
			DEALLOCATE Cur_Col
		  UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno IN (1)
	RETURN
END
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_GR_CrossTabJCWise')
DROP PROCEDURE Proc_GR_CrossTabJCWise
GO
-- EXEC Proc_GR_CrossTabJCWise 'Retailer Buying Trend-JCWise Report','2012-01-04','2012-01-04','','','','','',''          
	CREATE PROCEDURE [dbo].[Proc_GR_CrossTabJCWise]                  
	(                  
	@Pi_RptName  NVARCHAR(100),                  
	@Pi_FromDate DATETIME,                  
	@Pi_ToDate  DATETIME,                  
	@Pi_Filter1  NVARCHAR(100),               
	@Pi_Filter2  NVARCHAR(100),                  
	@Pi_Filter3  NVARCHAR(100),                  
	@Pi_Filter4  NVARCHAR(100),                  
	@Pi_Filter5  NVARCHAR(100),                  
	@Pi_Filter6  NVARCHAR(100)                  
	)                  
	AS                   
	/*******************************************************************************                  
	* PROCEDURE     :Proc_GR_CrossTabJCWise              
	* PURPOSE       :To Get JCWISE(Month) Details - Dynamic report purpose               
	* CREATED BY    :Jayakumar.E                  
	* CREATED DATE  :06/05/2011                   
	---------------------------------------------------------------------------------                  
	* {date}       {developer}  {brief modification description}                  
	*********************************************************************************/                  
	BEGIN                  
	DECLARE @PHLEVEL VARCHAR(7500)                  
	DECLARE @SQL_STR1 VARCHAR(8000)                  
	DECLARE @SQL_STR2 VARCHAR(8000)                  
	DECLARE @CAPHLEVEL VARCHAR(8000)                  
	     
	DECLARE @SName    Varchar(100)                  
	DECLARE @RName    Varchar(100)                  
	DECLARE @RetName  Varchar(100)                  
	DECLARE @RtrId   INT                  
	DECLARE @RetCode  Varchar(100)                  
	DECLARE @MonthId     INT                  
	DECLARE @YearId      INT                   
	DECLARE @Qty      INT                  
	DECLARE @GAmt     Numeric(38,6)                  
	DECLARE @NetAmt     Numeric(38,6)                  
	DECLARE @Monthname   varchar(8000)                  
	DECLARE @sStrql varchar(8000)                  
	DECLARE @Cnt as INT                  
	DECLARE @MntCnt as INT                  
	         
	SET @Pi_FILTER1='%'+ISNULL(@Pi_FILTER1,'')+'%'                          
	SET @Pi_FILTER2='%'+ISNULL(@Pi_FILTER2,'')+'%'                          
	SET @Pi_FILTER3='%'+ISNULL(@Pi_FILTER3,'')+'%'                          
	SET @Pi_FILTER4='%'+ISNULL(@Pi_FILTER4,'')+'%'                          
	SET @Pi_FILTER5='%'+ISNULL(@Pi_FILTER5,'')+'%'                    
	SET @Pi_FILTER6='%'+ISNULL(@Pi_FILTER6,'')+'%'                    
	          
	      
	-------------------FILTER OUT THE REQUIRED RECORDS HERE                  
	SELECT a.* INTO #SALINV FROM SALESINVOICE A,ROUTEMASTER B, SALESMAN C, RETAILER D  ,TBL_GR_BUILD_RH E                  
	WHERE  salinvdate between @pi_fromdate and @pi_todate                   
	AND A.RMID=B.RMID AND B.RMNAME LIKE @PI_FILTER5 and E.RTRID=A.RTRID                    
	and DLVSTS in (4,5) and C.SMID=A.SMID AND C.SMNAME LIKE @PI_FILTER1  AND A.RTRID=D.RTRID                   
	AND D.RTRNAME LIKE @PI_FILTER4 AND E.HASHPRODUCTS LIKE @PI_FILTER2                    
	     
	SELECT A.* INTO #SALESINVOICEPRODUCT FROM SALESINVOICEPRODUCT A,TBL_GR_BUILD_PH C, #SALINV D                  
	WHERE A.SALID=D.SALID AND A.PRDID=C.PRDID AND  HASHPRODUCTS LIKE @PI_FILTER6                   
	-----------------------------------------------------------------         
	SELECT   
	Jcmid,JcmJc,ColName,JCMSDT,JCMEDT INTO #JCWISE FROM         
	(Select A.JcmJc,A.Jcmid,A.JCMSDT,A.JCMEDT,  'JC'+ Cast(A.JcmJc as varchar(10)) +'-'+ Cast(B.JCMYR as varchar(10)) as ColName----,JcmSDt,JcmEdt          
	From JCMonth A INNER JOIN JCMAST B ON A.JCMID=B.JCMID Where           
	A.JcmId in ( Select Jcmid From JcMast Where JcmYr between Year(@pi_fromdate) and Year(@pi_todate) )          
	and @pi_fromdate between JcmSdt and  JcmEdt           
	or  @pi_todate between JcmSdt and  JcmEdt          
	Or  JCmSdt between @pi_fromdate and @pi_todate            
	or  JcmSdt between @pi_fromdate and @pi_todate           
	) A order by A.Jcmid,A.JcmJc           
	------------------------------------------------------------------------              
	SELECT   
	SMNAME [Salesman Name],RMNAME [Route Name] ,RH.HIERARCHY3CAP [Retailer Hierarchy 1] ,  
	RH.HIERARCHY2CAP [Retailer Hierarchy 2],RH.HIERARCHY1CAP [Retailer Hierarchy 3],RET.RTRCODE [Retailer Code],  
	RET.RTRNAME [Retailer Name],Cast(0 AS INT) [No OF Bills],Cast(0 AS INT) [No OF Lines],CAST(0 AS INT) AS  [Total Quantity],CAST(0 AS NUMERIC(18,6)) AS  [Gross Amount],  
	CAST(0 AS NUMERIC(18,6)) AS [Net Amount]                
	INTO #OVERALL                  
	FROM                   
	#JCWISE,#SALINV SI,#SALESINVOICEPRODUCT SP,RETAILER RET,SALESMAN SM,ROUTEMASTER RM,                  
	TBL_GR_BUILD_RH RH,TBL_GR_BUILD_PH PH                  
	WHERE                 
	salinvdate BETWEEN JCMSDT AND JCMEDT AND DLVSTS in (4,5) AND                 
	SI.SALID=SP.SALID AND SI.RTRID=RET.RTRID AND SI.RTRID=RH.RTRID                   
	AND PH.PRDID=SP.PRDID AND SM.SMID=SI.SMID AND RM.RMID=SI.RMID ----------------and si.rtrid  = 28                  
	GROUP BY SMNAME,RMNAME,RET.RTRCODE,RET.RTRNAME,RH.HIERARCHY2CAP,RH.HIERARCHY1CAP,RH.HIERARCHY3CAP               
	---------------------------------------------------------------------------------------------           
	 
	DECLARE @C_SSQL  varchar(8000)                  
	DECLARE @Column  Varchar(100)                  
	DECLARE @YearCnt  INT                  
	DECLARE @monthCnt INT                  
	DECLARE @COLNAME VARCHAR(8000)                
	DECLARE  @sColumnName Varchar(8000)                  
	DECLARE  @sColumnNameTable Varchar(8000)                  
	DECLARE  @sColumnNameSum   Varchar(8000)                  
	DECLARE @iCnt INT                  
	Set @iCnt = 0                  
	Set @sColumnName = ''                  
	Set @sColumnNameTable = ''                  
	DECLARE @JCMJC INT                
	DECLARE @JCMYR INT           
	DECLARE @JCMID INT           
	    
	     
	DECLARE Column_Cur CURSOR FOR                  
	SELECT   
	jcmJc,Jcmid,COLNAME --RIGHT(COLNAME,10)                  
	FROM #JCWISE   
	Order By Jcmid asc,jcmJc --LEFT(COLNAME,4)--RIGHT(COLNAME,10)                
	OPEN Column_Cur                   
	FETCH NEXT FROM Column_Cur INTO @JCMJC, @JCMID,@Column                
	WHILE @@FETCH_STATUS = 0                  
	BEGIN                  
	print @column                
	SET @C_SSQL='ALTER TABLE #OverAll  ADD ['+ @Column +'] NUMERIC(38,6) NOT NULL DEFAULT 0 WITH VALUES'                  
	EXEC (@C_SSQL)                  
		If @sColumnName = ''                  
		BEgin                  
			SET @sColumnName =  '['+@Column+']'                  
			SET @sColumnNameTable = '['+@Column+']' + ' NUMERIC(38,6)'                  
			SET @sColumnNameSum = 'Sum(' + '['+@Column+']' + ') ' + '['+@Column+']'                   
		END                  
	SET @iCnt=@iCnt+1                  
	FETCH NEXT FROM Column_Cur INTO  @JCMJC, @JCMID,@Column                
	END                  
	CLOSE Column_Cur                  
	DEALLOCATE Column_Cur                  
	     
	     
	DECLARE @FielName1 as Varchar(50)                
	DECLARE @Fromdate as DATETIME                
	DECLARE @Todate as DATETIME                
	DECLARE @SSQL as Varchar(8000)                
	    
	DECLARE Cur_LastYear CURSOR                
	FOR SELECT ColName,JcmSdt,JcmEdt FROM #JCWISE  Order By JcmJc              
	OPEN Cur_LastYear                
	FETCH NEXT FROM Cur_LastYear INTO @FielName1,@Fromdate,@Todate                
	WHILE @@FETCH_STATUS=0                
	BEGIN          
	SELECT SM.SMNAME,SI.RtrId,R.RTRCODE,RM.RMNAME,CAST(SUM(SIP.BASEQTY) AS INT)QTY,SUM(SIP.PRDGROSSAMOUNT)GAMT,SUM(SIP.PRDNETAMOUNT) NETAMT        
	INTO #TempCurYearSales                 
	FROM #SALESINVOICEPRODUCT SIP                
	INNER JOIN SalesInvoice SI  ON SI.Salid=SIP.Salid     
	INNER JOIN Salesman SM on SM.SmId=SI.SmId    
	INNER JOIN RouteMaster RM  ON RM.RMID=SI.RMID    
	INNER JOIN Retailer R ON R.RTRID=SI.RTRID                
	WHERE  SI.Salinvdate Between @Fromdate and  @Todate AND SI.DLVSTS in (4,5)                  
	GROUP BY SI.RtrId,SM.SMNAME,RM.RMNAME,R.RTRCODE                
	SET @ssql ='Update RJ SET ['+ @FielName1 +']=T.NETAMT FROM #OVERALL RJ  INNER JOIN #TempCurYearSales T'+         
	' ON [Retailer Code]=T.RTRCODE AND [Salesman Name]=T.SMNAME AND [Route Name]=T.RMNAME '      
	EXEC(@SSQL)                
	DROP TABLE #TempCurYearSales                
	FETCH NEXT FROM Cur_LastYear INTO  @FielName1,@Fromdate,@Todate                
	END                
	CLOSE Cur_LastYear                
	DEALLOCATE Cur_LastYear                
	     
	UPDATE A SET [Net Amount]=B.NETAMT,[Gross Amount]=B.GAMT,[Total Quantity]=B.QTY FROM #OVERALL A INNER JOIN                 
	(      
	SELECT SM.SMNAME,R.RTRCODE,RM.RMNAME,CAST(SUM(SIP.BASEQTY) AS INT)QTY,SUM(SIP.PRDGROSSAMOUNT)GAMT,SUM(SIP.PRDNETAMOUNT) NETAMT                  
	FROM #SALESINVOICEPRODUCT SIP                
	INNER JOIN SalesInvoice SI  ON SI.Salid=SIP.Salid       
	INNER JOIN Salesman SM on SM.SmId=SI.SmId    
	INNER JOIN RouteMaster RM  ON RM.RMID=SI.RMID    
	INNER JOIN Retailer R ON R.RTRID=SI.RTRID          
	WHERE  SI.Salinvdate Between @pi_fromdate and  @pi_Todate AND SI.DLVSTS in (4,5)                  
	GROUP BY SM.SMNAME,R.RTRCODE,RM.RMNAME  
	)B ON [Retailer Code]=B.RTRCODE  AND [Salesman Name]=B.SMNAME  AND [Route Name]=B.RMNAME 
	
UPDATE OL SET  [No OF Bills]=NoofBills,[No OF Lines]=NoOfLines FROM #OVERALL OL INNER JOIN
		( SELECT R.RtrCode,RM.RMName,SM.SMName,IsNull(Count(DISTINCT SIP.SalId),0) NoofBills,IsNull(Count(DISTINCT SIP.PrdId),0) NoOfLines FROM SalesInvoice SI
		INNER JOIN SalesInvoiceProduct SIP ON SIP.SalId=SI.SalId 
		INNER JOIN Retailer R ON R.RtrId=SI.RtrId 
		INNER JOIN RouteMaster RM ON RM.RMid=SI.RMId
		INNER JOIN SalesMan SM ON Sm.SMid=SI.SmId 
		WHERE SI.SalInvDate BETWEEN @Pi_FromDate and  @Pi_ToDate AND SI.DLVSTS in (4,5) GROUP BY R.RtrCode,RM.RMName,SM.SMName
		) X ON 
		[Retailer Code]=X.RtrCode  AND [Salesman Name]=X.SMName  AND [Route Name]=X.RMName 
	
	Select  'Retailer Buying Trend-JCWise Report' AS Header,* from #OverAll    
END     
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE [Name]='Proc_GR_EffectiveCoverageAnalysis')
DROP PROCEDURE Proc_GR_EffectiveCoverageAnalysis
GO
CREATE PROCEDURE Proc_GR_EffectiveCoverageAnalysis
(
	@Pi_RptName		NVARCHAR(100),
	@Pi_FromDate	DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_Filter1		NVARCHAR(100),
	@Pi_Filter2		NVARCHAR(100),
	@Pi_Filter3		NVARCHAR(100),
	@Pi_Filter4		NVARCHAR(100),
	@Pi_Filter5		NVARCHAR(100),
	@Pi_Filter6		NVARCHAR(100)
)
AS 
BEGIN
-- EXEC [Proc_GR_EffectiveCoverageAnalysis] 'Billwise Productwise Sales','2012-01-01','2012-01-05','','','','','',''
		SET @Pi_FILTER1='%'+ISNULL(@Pi_FILTER1,'')+'%'        
		SET @Pi_FILTER2='%'+ISNULL(@Pi_FILTER2,'')+'%'        
		SET @Pi_FILTER3='%'+ISNULL(@Pi_FILTER3,'')+'%'        
		SET @Pi_FILTER4='%'+ISNULL(@Pi_FILTER4,'')+'%'        
		SET @Pi_FILTER5='%'+ISNULL(@Pi_FILTER5,'')+'%'  
		SET @Pi_FILTER6='%'+ISNULL(@Pi_FILTER6,'')+'%'      
SELECT 
		Salesman.SMCode AS [Salesman Code], Salesman.SMName AS [Salesman Name], 
		RouteMaster.RMCode AS [Route Code], RouteMaster.RMName AS [Route Name], 
        TBL_GR_BUILD_RH.HIERARCHY3CAP AS [Retailer Hierarchy 1], 
        TBL_GR_BUILD_RH.HIERARCHY2CAP AS [Retailer Hierarchy 2], 
		TBL_GR_BUILD_RH.HIERARCHY1CAP AS [Retailer Hierarchy 3], 
		Retailer.RtrCode AS [Retailer Code] ,
		Retailer.RtrNAme as [Retailer Name]         INTO #COV 
FROM         SalesmanMarket INNER JOIN
                      Salesman ON SalesmanMarket.SMId = Salesman.SMId INNER JOIN
                      RouteMaster ON SalesmanMarket.RMId = RouteMaster.RMId INNER JOIN
                      Retailer INNER JOIN
                      RetailerMarket ON Retailer.RtrId = RetailerMarket.RtrId ON SalesmanMarket.RMId = RetailerMarket.RMId INNER JOIN
                      TBL_GR_BUILD_RH ON Retailer.RtrId = TBL_GR_BUILD_RH.RTRID
where rtrstatus=1 and smname like @pi_filter1 and rmname like @pi_Filter5 and rtrname like @pi_Filter4

SELECT [SALESMAN CODE],COUNT(DISTINCT [RETAILER CODE]) RTRCOUNT INTO #SALRETCOUNT FROM #COV
GROUP BY [SALESMAN CODE]
SELECT [Route Code],COUNT(DISTINCT [RETAILER CODE]) RTRCOUNT INTO #ROTRETCOUNT FROM #COV
GROUP BY [Route Code]
SELECT COUNT(DISTINCT [RETAILER CODE]) CNT INTO #TOTALCNT FROM #COV
	
	SELECT a.* INTO #SALINV 
	FROM SALESINVOICE A,ROUTEMASTER B, SALESMAN C, RETAILER D  ,TBL_GR_BUILD_RH E
	WHERE SALINVDATE BETWEEN @PI_fROMDATE AND @PI_TODATE AND A.RMID=B.RMID 
		  AND B.RMNAME LIKE @PI_FILTER5 and E.RTRID=A.RTRID AND
			DLVSTS in (4,5) and
			C.SMID=A.SMID AND C.SMNAME LIKE @PI_FILTER1 AND A.SALINVNO LIKE @PI_FILTER3 
			AND A.RTRID=D.RTRID AND D.RTRNAME LIKE @PI_FILTER4 AND E.HASHPRODUCTS LIKE @PI_FILTER2
    SELECT A.* INTO #SALESINVOICEPRODUCT FROM SALESINVOICEPRODUCT A,TBL_GR_BUILD_PH C, #SALINV D
	WHERE A.SALID=D.SALID AND A.PRDID=C.PRDID AND 	HASHPRODUCTS LIKE @PI_FILTER6
	DELETE FROM #SALINV WHERE SALID NOT IN (SELECT DISTINCT SALID FROM #SALESINVOICEPRODUCT)
-- FOR PRODUCT
SELECT     'Product Level',Product.PrdDCode[Dist. Prod Code], Product.PrdCCode[Co. Prd Code], 
			Product.PrdName [Prd Name.],(SELECT CNT FROM #TOTALCNT) [Active Retailers],
			count(DISTINCT RTRID)[Total Retailers Billed], ((SELECT CNT FROM #TOTALCNT)-(SELECT Count(DISTINCT RTRId) FROM #SALINV WHERE SALINVDATE BETWEEN @PI_fROMDATE AND @PI_TODATE))[Number of retailers not Billed],
			COUNT(DISTINCT #salinv.SalInvNo) [Total No. Invoices], 
            sum(#Salesinvoiceproduct.PrdNetAmount) [Net Amount]
FROM         #salinv  INNER JOIN
                      #Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
                      Product ON #Salesinvoiceproduct.PrdId = Product.PrdId 
GROUP BY Product.PrdDCode, Product.PrdCCode, Product.PrdName
----- FOR SALESMAN
SELECT     'Salesman Level',Salesman.SMName [Salesman Name],ISNULL(RTRCOUNT,0) [Active Retailers],
			COUNT(DISTINCT RTRID)[Total Retailers Billed],(RTRCOUNT-COUNT(DISTINCT RTRID)) [Number of retailers not Billed],
			count(distinct #salinv.SalInvNo) [Total No. Invoices] , 
			count(Product.PrdDCode) [Total Lines Sold],
			CASE Cast(count(Product.PrdDCode) as Numeric(18,2)) WHEN 0 THEN ISNULL(Cast(count(distinct #salinv.SalInvNo) as Numeric(18,2)),0)
			ELSE cast(Cast(count(Product.PrdDCode) as Numeric(18,2)) / ISNULL(Cast(count(distinct #salinv.SalInvNo) as Numeric(18,2)),0) AS nUMERIC(18,2)) end AS [Lines Per Invoice],
			ISNULL(Sum(#Salesinvoiceproduct.PrdNetAmount),0) [Net Amount]
FROM         #salinv INNER JOIN
                      #Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
                      Product ON #Salesinvoiceproduct.PrdId = Product.PrdId 
					  RIGHT OUTER JOIN Salesman ON #salinv.SMId = Salesman.SMId 
					  RIGHT OUTER JOIN #SALRETCOUNT ON SALESMAN.SMCODE=#SALRETCOUNT.[SALESMAN CODE]
group by Salesman.SMName,RTRCOUNT
-- EXEC [Proc_GR_EffectiveCoverageAnalysis] 'Billwise Productwise Sales','2012-01-01','2012-01-05','','','','','',''
---- FOR ROUTE
SELECT      'Route Level',RouteMaster.RMName [Route Name],RTRCOUNT [Active Retailers],
			COUNT(DISTINCT RTRID)[Total Retailers Billed],(RTRCOUNT-COUNT(DISTINCT RTRID)) [Number of retailers not Billed],
		    count(distinct #salinv.SalInvNo) [Total No. Invoices] , 
			count(Product.PrdDCode) [Total Lines Sold],
			CASE Cast(count(Product.PrdDCode) as Numeric(18,2)) WHEN 0 THEN Cast(count(distinct #salinv.SalInvNo)as Numeric(18,2)) ELSE 
			Cast(count(Product.PrdDCode) as Numeric(18,2))/Cast(count(distinct #salinv.SalInvNo) as Numeric(18,2)) END AS [Lines Per Invoice],
			IsNull(sum(#Salesinvoiceproduct.PrdNetAmount),0) [Net Amount]
FROM         #salinv INNER JOIN
                      #Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId 
					  INNER JOIN Product ON #Salesinvoiceproduct.PrdId = Product.PrdId 
					  RIGHT OUTER JOIN RouteMaster ON #salinv.RMId = RouteMaster.RMId 
					  RIGHT OUTER JOIN #ROTRETCOUNT ON ROUTEMASTER.RMCODE=#ROTRETCOUNT.[ROUTE CODE]
group by RMName,RTRCOUNT
---- RETAILER LEVEL
SELECT     'Retailer Level',RtrCode [Retailer Code],RtrName [Retailer Name], 
			count(distinct #salinv.SalInvNo) [Total No. Invoices] , count(Product.PrdDCode) [Total Lines Sold],
			Cast(count(Product.PrdDCode) as Numeric(18,2))/Cast(count(distinct #salinv.SalInvNo) as Numeric(18,2)) AS [Lines Per Invoice],
			sum(#Salesinvoiceproduct.PrdNetAmount) [Net Amount]
FROM         #salinv INNER JOIN
                      #Salesinvoiceproduct ON #salinv.SalId = #Salesinvoiceproduct.SalId INNER JOIN
                      Product ON #Salesinvoiceproduct.PrdId = Product.PrdId INNER JOIN
                      Retailer ON #salinv.rtrid = Retailer.Rtrid
group by Rtrcode,Rtrname
end
GO
DELETE FROM RptSelectionHd WHERE SelcId=277
GO
INSERT INTO RptSelectionHd(SelcId,SelcName,TblName,Condition)
SELECT 277,'Sel_OrderBy','ReportOrder By Based on',1
GO
DELETE FROM RptFilter WHERE RptId=3 AND SelcId=277
GO
INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
SELECT 3,277,0,'Salesman' UNION ALL
SELECT 3,277,1,'Route' UNION ALL
SELECT 3,277,2,'Retailer' UNION ALL
SELECT 3,277,3,'BillNo'
GO
DELETE FROM RptDetails WHERE RptId=3 AND SelcId=277
GO
INSERT INTO RptDetails
SELECT 3,12,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Display Order by*...','',1,'',277,1,1,'Press F4/Double Click to select Diplay Order by',0
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_RptPendingBillReport')
DROP PROCEDURE Proc_RptPendingBillReport
GO
--EXEC Proc_RptPendingBillReport 3,1,0,'Dabur1',0,0,1
CREATE PROCEDURE Proc_RptPendingBillReport
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
	DECLARE @Orderby AS Int
	SET @Orderby=0 
	SET @Orderby = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,277,@Pi_UsrId))
	PRINT @Orderby
	PRINT @RPTBasedON
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
--	IF @RPTBasedON=1
--		BEGIN 
--			SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays DESC
--        END 
--	
	IF @Orderby=0 AND @RPTBasedON=0 
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY SMName 
		END 
	IF @Orderby=1 AND @RPTBasedON=0  
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY RMName 
		END
	IF @Orderby=2 AND @RPTBasedON=0  
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY RtrName 
		END
	IF @Orderby=3 AND @RPTBasedON=0  
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY SalInvNo 
		END
	ELSE 
		BEGIN 
			SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays DESC
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
			Cash	        NUMERIC (38,6),
			ChequeAmt	    NUMERIC (38,6),
			ChequeNo	    NUMERIC (38,6),
			CollectedAmount NUMERIC (38,6),
			BalanceAmount   NUMERIC (38,6),
			ArDays			INT
		)
		INSERT INTO RptPendingBillsDetails_Excel( SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,
			  SalInvDate,SalInvRef,BillAmount,Cash,ChequeAmt,ChequeNo,CollectedAmount,
			  BalanceAmount,ArDays)
		  SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,
			  SalInvDate,SalInvRef,BillAmount,'0.00','0.00','0.00',ISNULL(CollectedAmount,'0.00'),
			  BalanceAmount,ArDays FROM  #RptPendingBillsDetails	
	   
		UPDATE RPT SET RPT.[RtrCode]=R.RtrCode FROM RptPendingBillsDetails_Excel RPT,Retailer R WHERE RPT.[RtrName]=R.RtrName
	END
	RETURN
END
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_get_ip_address')
DROP PROCEDURE Proc_get_ip_address
GO
Create Procedure Proc_get_ip_address (@ip varchar(40) out)
as
begin
Declare @ipLine varchar(200)
Declare @pos int
set nocount on
          set @ip = NULL
          Create table #temp (ipLine varchar(200))
          Insert #temp exec master..xp_cmdshell 'ipconfig'
          select @ipLine = ipLine
          from #temp
          where upper (ipLine) like '%IP ADDRESS%'
          if (isnull (@ipLine,'***') != '***')
          begin 
                set @pos = CharIndex (':',@ipLine,1);
                set @ip = rtrim(ltrim(substring (@ipLine , 
               @pos + 1 ,
                len (@ipLine) - @pos)))
           end 
drop table #temp
set nocount off
end 
GO
-- Exec Proc_Cs2Cn_DBDetailsUpload 0
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_Cs2Cn_DBDetailsUpload')
DROP PROCEDURE Proc_Cs2Cn_DBDetailsUpload
GO
CREATE PROCEDURE Proc_Cs2Cn_DBDetailsUpload
(
	@Po_ErrNo	INT OUTPUT
)
AS 
BEGIN
/*********************************  
* PROCEDURE: Proc_Cs2Cn_DBDetailsUpload  
* PURPOSE: Extract Database details from CoreStocky to Console  
* NOTES:  
* CREATED: Praveenraj B 
* DATE: 10-12-2011
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/
DECLARE @DistCode AS VarChar(25)
DECLARE @DbName AS VarChar(25)
DECLARE @MachineName AS VarChar(25)
DECLARE @DbSize AS VarChar(25)
DECLARE @DBid AS Int
DECLARE @DBCretaedDate AS DateTime
DECLARE @IpAddress AS VarChar(25)
DECLARE @DBResoreId AS Int 
DECLARE @DBRestoreDate AS DateTime
DECLARE @Filename AS VarChar(100)
SET Nocount ON 
	DELETE FROM Cs2Cn_DBDetailsUpload WHERE UploadFlag='Y'
	SELECT @DistCode=Distributorcode FROM Distributor
	EXEC Proc_get_ip_address @IpAddress Out
	Create TABLE  #Temp 
      (
	 SPID int not null
	 , Status varchar (255) not null
	 , Login varchar (255) not null
	 , HostName varchar (255) not null
	 , BlkBy varchar(10) not null
	 , DBName varchar (255) null
	 , Command varchar (255) not null
	 , CPUTime int not null
	 , DiskIO int not null
	 , LastBatch varchar (255) not null
	 , ProgramName varchar (255) null
	 , SPID2 int not null
	 , REQUESTID INT
	)  
	INSERT INTO #Temp EXEC sp_who2  
	SELECT @DbName=DbName,@MachineName=HostName FROM #Temp WHERE Status='RUNNABLE'
Create Table  #Temp1 
     (
	[Name] varchar (255),
	  DbSize varchar (255),
	  Owner varchar (255), 
	  DBid varchar (255), 
	  Createddate DateTime,
        Status varchar (255), 
	  [Level] varchar (255)
	 )  
INSERT INTO #Temp1 EXEC master.dbo.sp_helpdb
SELECT @DbSize=DbSize,@DbId=Dbid,@DBCretaedDate=Createddate FROM #Temp1 WHERE [Name]=@DbName
SELECT @Filename=Physical_Name FROM sys.master_files WHERE Database_Id=@DbId AND Physical_Name LIKE '%mdf'
SELECT @DBRestoreDate=Max(Restore_Date),@DBResoreId=max(restore_history_id) FROM msdb.dbo.restorehistory WHERE destination_database_name=@DbName
INSERT INTO Cs2Cn_DBDetailsUpload([Distributor Code],[Ip Address],[Machine Name],[DB Id],[DB Name],[DBCreatedDate],
[DBRestoredDate],[DbresoredId],[DBFileName],[DB Size],[UploadFlag])
SELECT  @DistCode,@IpAddress,@MachineName,@DBid,@DbName,@DBCretaedDate,@DBRestoreDate,@DBResoreId,@Filename,@DbSize,'N'
UPDATE Cs2Cn_DBDetailsUpload SET UploadFlag='Y' WHERE UploadFlag='N'
END 
GO
Delete from Customcaptions Where TransId=26 And SubCtrlId=25
Insert into Customcaptions
Select 26,1000,25,'MsgBox-26-1000-25','','','The Selected PurchaseOrder is Cancelled Or Expired',1,1,1,Getdate(),1,Getdate(),
'','','The Selected PurchaseOrder is Cancelled Or Expired',1,1
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'Proc_AROutStandingReport')
DROP PROCEDURE Proc_AROutStandingReport
GO
--EXEC Proc_AROutStandingReport '2012-01-13',0,0,0,182,1   
CREATE PROCEDURE [dbo].[Proc_AROutStandingReport]  
(    
	 @OnDate	DATETIME,  
	 @SmId		INT,  
	 @RmId		INT,  
	 @RtrId		INT,  
	 @Pi_RptId  INT,  
	 @Pi_UsrId	INT   
)  
AS  
/*********************************************************** 
* PROCEDURE : Proc_AROutStandingReport  
* PURPOSE : To get the Retaileroutstanding Details  
* CREATED BY : Boopathy.P 
* CREATED DATE : 10/08/2009  
* NOTE  :  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*************************************************************/  
BEGIN  
SET NOCOUNT ON  
 	DECLARE @CreditDays	AS	INT
	DECLARE @Bucket1	AS	VARCHAR(100)
	DECLARE @Bucket2	AS	VARCHAR(100)
	DECLARE @Bucket3	AS	VARCHAR(100)
	DECLARE @Bucket4	AS	VARCHAR(100)
	DECLARE @Bucket5	AS	VARCHAR(100)
	DECLARE @Start		AS  INT
	DECLARE @End		AS  INT
	DECLARE @StartDate  AS  DATETIME
	DECLARE @EndBucket		AS  INT

	SET @CreditDays = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,232,@Pi_UsrId))
	SET @Bucket1 = (SELECT  TOP 1 SCountId FROM Fn_ReturnRptFilterString(@Pi_RptId,235,@Pi_UsrId))
	SET @Bucket2 = (SELECT  TOP 1 SCountId FROM Fn_ReturnRptFilterString(@Pi_RptId,236,@Pi_UsrId))
	SET @Bucket3 = (SELECT  TOP 1 SCountId FROM Fn_ReturnRptFilterString(@Pi_RptId,237,@Pi_UsrId))
	SET @Bucket4 = (SELECT  TOP 1 SCountId FROM Fn_ReturnRptFilterString(@Pi_RptId,238,@Pi_UsrId))
	SET @Bucket5 = (SELECT  TOP 1 SCountId FROM Fn_ReturnRptFilterString(@Pi_RptId,239,@Pi_UsrId))
	
	DELETE FROM  TempAGAgeningRpt WHERE usrid = @Pi_UsrId  AND RptId=@Pi_RptId
	IF @smId=0 AND @RmId=0  
	BEGIN  
		INSERT INTO TempAGAgeningRpt  
		SELECT  A.Rtrid ,RtrCode,RtrName,RtrCrDays,
		COUNT(SalId),0,0,0,0,0,0,RtrOnAcc ,0,0,0,0,@Pi_UsrId ,@Pi_RptId
		FROM Retailer A INNER JOIN SalesInvoice B ON A.RtrId=B.RtrId
		WHERE  (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR  
		A.RtrId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
		AND B.SalInvDate <= @OnDate and Dlvsts Not in (3,5)
		GROUP BY A.Rtrid ,RtrCode,RtrName,RtrCrDays,RtrOnAcc
	END  
	ELSE  
	BEGIN  
		INSERT INTO TempAGAgeningRpt  
		SELECT  DISTINCT r.Rtrid ,r.RtrCode,r.RtrName,RtrCrDays, 
		COUNT(SalId),0,0,0,0,0,0,RtrOnAcc AS onAccount,0,0 AS CreditAmount,0 AS Debitmount,  
		0 AS SalNetAmt,@Pi_UsrId AS usrid  ,@Pi_RptId
		FROM Retailer r, Salesman S, Retailermarket rm, Salesmanmarket sm, Routemaster Ro,
		SALESINVOICE SI	
		WHERE R.RtrId=RM.RtrId AND RM.RMId=SM.RMId AND SM.SMId=S.SMId
		AND SI.RtrId=R.RtrId and Dlvsts Not in (3,5)
		AND ( r.RtrId = (CASE @RtrId WHEN 0 THEN r.RtrId ELSE 0 END) OR  
		R.RtrId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
		AND ( s.smId = (CASE @smId WHEN 0 THEN s.smid ELSE 0 END) OR  
		s.smid IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
		AND ( ro.rmid = (CASE @RmId WHEN 0 THEN ro.rmid ELSE 0 END) OR  
		ro.rmid IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
		AND SI.SalInvDate <= @OnDate 
		GROUP BY r.Rtrid ,r.RtrCode,r.RtrName,RtrCrDays,RtrOnAcc
	END  
		UPDATE T  
		SET t.Credit = cr.creditamount  
		FROM (SELECT Rtrid, sum(Amount-Cradjamount) AS creditamount  
		FROM CreditNoteRetailer  WHERE crnotedate  <= @OnDate AND Status=1  
		GROUP BY rtrid  
		) cr,  
		TempAGAgeningRpt T WHERE Cr.RtrId =  T.rtrid  
		UPDATE T  
		SET t.debit = db.debitamount  
		FROM (SELECT Rtrid, sum(Amount-dbadjamount) AS debitamount  
		FROM DebitNoteRetailer WHERE dbnotedate <= @OnDate
		AND Status=1  
		GROUP BY rtrid  
		) db,  
		TempAGAgeningRpt T WHERE db.RtrId =  T.rtrid  --select * from TempAGAgeningRpt
	IF @smId=0 AND @RmId=0  
	BEGIN  
		UPDATE T  
		SET t.NetOtStd = s.salnetamt,  
		t.salpayamt = s.salpayamt ,T.BillOutStd=s.salnetamt-s.salpayamt
		FROM (  
		SELECT rtrid, sum(salnetamt) AS salnetamt,sum(salpayamt) AS salpayamt  
		FROM salesinvoice S  
		WHERE dlvsts Not In (3,5)  
		AND ( RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR  
		RtrId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
		AND salinvdate  <= @OnDate 
		GROUP BY rtrid  
		) s,  
		TempAGAgeningRpt T WHERE s.RtrId =  T.rtrid  
	END  
	ELSE  
	BEGIN   
		UPDATE T  
		SET t.NetOtStd = s.salnetamt,  
		t.salpayamt = s.salpayamt
		,T.BillOutStd=s.salnetamt-s.salpayamt 
		FROM (  
		SELECT rtrid, sum(salnetamt) AS salnetamt,sum(salpayamt) AS salpayamt  
		FROM salesinvoice S  
		WHERE dlvsts Not In (3,5)  
		AND ( RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR  
		RtrId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
		AND ( smId = (CASE @smId WHEN 0 THEN smid ELSE 0 END) OR  
		smid IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
		AND ( rmid = (CASE @RmId WHEN 0 THEN rmid ELSE 0 END) OR  
		rmid IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
		AND salinvdate   <= @OnDate 
		GROUP BY rtrid  
		) s,  
		TempAGAgeningRpt T WHERE s.RtrId =  T.rtrid  
	END  
				IF @RtrId = 0
				BEGIN
					SET @RtrId = NULL
				END
				IF @SmId = 0
				BEGIN
					SET @SmId = NULL
				END
				IF @RmId = 0
				BEGIN
					SET @RmId = NULL
				END
	IF @Bucket1 <> ''
	BEGIN
		SET @Start = CAST(SUBSTRING(@Bucket1,1,CHARINDEX('-',@Bucket1)-1) AS INT)
		SET @End = CAST(SUBSTRING(@Bucket1,CHARINDEX('-',@Bucket1)+1,LEN(@Bucket1)) AS INT)
		SET @End=ABS(@End-@Start)
		SET @StartDate = DATEADD(DD,-@End,@OnDate)
        PRINT @SmId
--      SELECT * FROM #TempBucket1
        SELECT RtrId,ISNULL(SUM(Salnetamt)-SUM(SalPayamt),0) AS Amt INTO #Bucket1Final
		FROM SALESINVOICE  WHERE 
		SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate ,121)AND CONVERT(VARCHAR(10),@OnDate,121)  
		AND RtrId = ISNULL(@RtrId,RtrId) AND SmId = ISNULL(@SmId,SmId) AND RmId = ISNULL(@RmId,RmId) 
		AND Dlvsts Not In(3,5) GROUP BY RtrId
		
		UPDATE TempAGAgeningRpt 
			SET Bucket1= Amt
			FROM #Bucket1Final A WHERE A.RtrId=TempAGAgeningRpt.RtrId
	END
	IF @Bucket2 <> ''
	BEGIN
	    SET @OnDate=@Startdate
		SET @Start = CAST(SUBSTRING(@Bucket2,1,CHARINDEX('-',@Bucket2)-1) AS INT)
		SET @End = CAST(SUBSTRING(@Bucket2,CHARINDEX('-',@Bucket2)+1,LEN(@Bucket2)) AS INT)
		SET @EndBucket = CAST(SUBSTRING(@Bucket2,CHARINDEX('-',@Bucket2)+1,LEN(@Bucket2)) AS INT)
		SET @End=ABS(@End-@Start)
		SET @StartDate = DATEADD(DD,-@End,@OnDate)
		IF @EndBucket = 0 
		BEGIN
		   SET @StartDate = (SELECT MIN(SalInvDate) FROM SalesInvoice WHERE RtrId = ISNULL(@RtrId,RtrId)
		                     AND SmId = ISNULL(@SmId,SmId) AND RmId = ISNULL(@RmId,RmId) AND Dlvsts <> 3)
	    END
--      SELECT * FROM #TempBucket2
	    SELECT RtrId,ISNULL(SUM(salnetamt)-SUM(SalPayamt),0) AS Amt INTO #Bucket2Final
		FROM SALESINVOICE  WHERE 
		SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate ,121)AND CONVERT(VARCHAR(10),@OnDate,121)  
		AND RtrId = ISNULL(@RtrId,RtrId) AND SmId = ISNULL(@SmId,SmId) AND RmId = ISNULL(@RmId,RmId) 
		AND	Dlvsts Not In(3,5) GROUP BY RtrId
		
		UPDATE TempAGAgeningRpt 
			SET Bucket2= Amt
			FROM #Bucket2Final A WHERE A.RtrId=TempAGAgeningRpt.RtrId
	END
	IF @Bucket3 <> ''
	BEGIN
	    SET @OnDate=@Startdate
		SET @Start = CAST(SUBSTRING(@Bucket3,1,CHARINDEX('-',@Bucket3)-1) AS INT)
		SET @End = CAST(SUBSTRING(@Bucket3,CHARINDEX('-',@Bucket3)+1,LEN(@Bucket3)) AS INT)
		SET @EndBucket = CAST(SUBSTRING(@Bucket3,CHARINDEX('-',@Bucket3)+1,LEN(@Bucket3)) AS INT)
		SET @End=ABS(@End-@Start)
		SET @StartDate = DATEADD(DD,-@End,@OnDate)
		IF @EndBucket = 0 
		BEGIN
		   SET @StartDate = (SELECT MIN(SalInvDate) FROM SalesInvoice WHERE RtrId = ISNULL(@RtrId,RtrId)
		                     AND SmId = ISNULL(@SmId,SmId) AND RmId = ISNULL(@RmId,RmId) AND Dlvsts <> 3)
	    END
--		SELECT * FROM #TempBucket3
        SELECT RtrId,ISNULL(SUM(salnetamt)-SUM(SalPayamt),0) AS Amt INTO #Bucket3Final
		FROM SALESINVOICE  WHERE 
		SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate ,121)AND CONVERT(VARCHAR(10),@OnDate,121)  
		AND RtrId = ISNULL(@RtrId,RtrId)AND SmId = ISNULL(@SmId,SmId) AND RmId = ISNULL(@RmId,RmId) 
		AND Dlvsts Not In(3,5) GROUP BY RtrId
		
		UPDATE TempAGAgeningRpt 
			SET Bucket3= Amt
			FROM #Bucket3Final A WHERE A.RtrId=TempAGAgeningRpt.RtrId
    END			
	IF @Bucket4 <> ''
	BEGIN
		SET @OnDate=@Startdate
		SET @Start = CAST(SUBSTRING(@Bucket4,1,CHARINDEX('-',@Bucket4)-1) AS INT)
		SET @End = CAST(SUBSTRING(@Bucket4,CHARINDEX('-',@Bucket4)+1,LEN(@Bucket4)) AS INT)
		SET @EndBucket = CAST(SUBSTRING(@Bucket4,CHARINDEX('-',@Bucket4)+1,LEN(@Bucket4)) AS INT)
		SET @End=ABS(@End-@Start)
		SET @StartDate = DATEADD(DD,-@End,@OnDate)
		IF @EndBucket = 0 
		BEGIN
		   SET @StartDate = (SELECT MIN(SalInvDate) FROM SalesInvoice WHERE RtrId = ISNULL(@RtrId,RtrId)
		                     AND SmId = ISNULL(@SmId,SmId) AND RmId = ISNULL(@RmId,RmId) AND Dlvsts <> 3)        
	    END
--		SELECT * FROM #TempBucket4
        SELECT RtrId,ISNULL(SUM(salnetamt)-SUM(SalPayamt),0) AS Amt INTO #Bucket4Final
		FROM SALESINVOICE  WHERE 
		SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate ,121)AND CONVERT(VARCHAR(10),@OnDate,121)  
		AND RtrId = ISNULL(@RtrId,RtrId) --AND SmId = ISNULL(@SmId,SmId) AND RmId = ISNULL(@RmId,RmId) 
		AND Dlvsts Not In(3,5) GROUP BY RtrId
		
		UPDATE TempAGAgeningRpt SET Bucket4= Amt FROM #Bucket4Final A WHERE A.RtrId=TempAGAgeningRpt.RtrId
    END			
	IF @Bucket5 <> ''
	BEGIN
		SET @OnDate=@Startdate
		SET @Start = CAST(SUBSTRING(@Bucket5,1,CHARINDEX('-',@Bucket5)-1) AS INT)
		SET @End = CAST(SUBSTRING(@Bucket5,CHARINDEX('-',@Bucket5)+1,LEN(@Bucket5)) AS INT)
		SET @EndBucket = CAST(SUBSTRING(@Bucket5,CHARINDEX('-',@Bucket5)+1,LEN(@Bucket5)) AS INT)
		SET @End=ABS(@End-@Start)
		SET @StartDate = DATEADD(DD,-@End,@OnDate)
		IF @EndBucket = 0 
		BEGIN
		  SET @StartDate = (SELECT MIN(SalInvDate) FROM SalesInvoice WHERE RtrId = ISNULL(@RtrId,RtrId)
		                    AND SmId = ISNULL(@SmId,SmId) AND RmId = ISNULL(@RmId,RmId) AND Dlvsts <> 3)
	    END
--		SELECT * FROM #TempBucket5
        SELECT RtrId,ISNULL(SUM(salnetamt)-SUM(SalPayamt),0) AS Amt INTO #Bucket5Final
		FROM SALESINVOICE  WHERE 
		SalInvDate BETWEEN CONVERT(VARCHAR(10),@StartDate ,121)AND CONVERT(VARCHAR(10),@OnDate,121)  
		AND RtrId = ISNULL(@RtrId,RtrId) AND SmId = ISNULL(@SmId,SmId) AND RmId = ISNULL(@RmId,RmId) 
		AND Dlvsts Not In(3,5) GROUP BY RtrId
		
		UPDATE TempAGAgeningRpt 
			SET Bucket5= Amt
			FROM #Bucket5Final A WHERE A.RtrId=TempAGAgeningRpt.RtrId
    END			
END  
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'Proc_RptAgeingAnalysis')
DROP PROCEDURE Proc_RptAgeingAnalysis
GO
----  EXEC Proc_RptAgeingAnalysis 182,1,0,'CoreStocky',0,0,1
CREATE PROCEDURE Proc_RptAgeingAnalysis
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
/*************************************************************  
* PROCEDURE : Proc_RptAgeingAnalysis  
* PURPOSE : To Retailer Ageing Report 
* CREATED BY : Boopathy.P 
* CREATED DATE : 14/08/2009  
* NOTE  :  
* MODIFIED  
* DATE			  AUTHOR		    DESCRIPTION  
  14-09-2009	  Mahalakshmi.A	    BugFixing for BugNo : 20623
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
	
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate		AS	DATETIME
	DECLARE @SMId	 	AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @Bucket1	AS	VARCHAR(100)
	DECLARE @Bucket2	AS	VARCHAR(100)
	DECLARE @Bucket3	AS	VARCHAR(100)
	DECLARE @Bucket4	AS	VARCHAR(100)
	DECLARE @Bucket5	AS	VARCHAR(100)
	DECLARE @Start		AS  INT
	
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @Bucket1 = (SELECT  TOP 1 ISNULL(SCountId,'') FROM Fn_ReturnRptFilterString(@Pi_RptId,235,@Pi_UsrId))
	SET @Bucket2 = (SELECT  TOP 1 ISNULL(SCountId,'') FROM Fn_ReturnRptFilterString(@Pi_RptId,236,@Pi_UsrId))
	SET @Bucket3 = (SELECT  TOP 1 ISNULL(SCountId,'') FROM Fn_ReturnRptFilterString(@Pi_RptId,237,@Pi_UsrId))
	SET @Bucket4 = (SELECT  TOP 1 ISNULL(SCountId,'') FROM Fn_ReturnRptFilterString(@Pi_RptId,238,@Pi_UsrId))
	SET @Bucket5 = (SELECT  TOP 1 ISNULL(SCountId,'') FROM Fn_ReturnRptFilterString(@Pi_RptId,239,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	IF @Bucket1<>'' AND @Bucket2='' AND @Bucket3='' AND @Bucket4='' AND @Bucket5=''
	BEGIN
		SET @Start=1
	END
	ELSE IF @Bucket1<>'' AND @Bucket2<>'' AND @Bucket3='' AND @Bucket4='' AND @Bucket5=''
	BEGIN
		SET @Start=2
	END
	ELSE IF @Bucket1<>'' AND @Bucket2<>'' AND @Bucket3<>'' AND @Bucket4='' AND @Bucket5=''
	BEGIN
		SET @Start=3
	END
	ELSE IF @Bucket1<>'' AND @Bucket2<>'' AND @Bucket3<>'' AND @Bucket4<>'' AND @Bucket5=''
	BEGIN
		SET @Start=4
	END
	ELSE IF @Bucket1<>'' AND @Bucket2<>'' AND @Bucket3<>'' AND @Bucket4<>'' AND @Bucket5<>''
	BEGIN
		SET @Start=5
	END
	
	Create TABLE #RptAgeingAnalysis
	(
			RtrId 			INT,
			RtrCode  		NVARCHAR(50),		
			RtrName 		NVARCHAR(50),
			CrDays			INT,
			NoBills			INT,
			Bucket1			NUMERIC(38,6),
			Bucket2			NUMERIC(38,6),
			Bucket3			NUMERIC(38,6),
			Bucket4			NUMERIC(38,6),
			Bucket5			NUMERIC(38,6),
			BillOutStd		NUMERIC(38,6),
			onAccount		NUMERIC(38,6),
			SalPayAmt		NUMERIC(38,6),
			Debit			NUMERIC(38,6),
			Credit			NUMERIC(38,6),
			NetOtStd		NUMERIC(38,6),
			Suppress		INT
	
	)
	SET @TblName = 'RptAgeingAnalysis'
	
	SET @TblStruct = 'RtrId 			INT,
			RtrCode  		NVARCHAR(50),		
			RtrName 		NVARCHAR(50),
			CrDays			INT,
			NoBills			INT,
			Bucket1			NUMERIC(38,6),
			Bucket2			NUMERIC(38,6),
			Bucket3			NUMERIC(38,6),
			Bucket4			NUMERIC(38,6),
			Bucket5			NUMERIC(38,6),
			BillOutStd		NUMERIC(38,6),
			onAccount		NUMERIC(38,6),
			SalPayAmt		NUMERIC(38,6),
			Debit			NUMERIC(38,6),
			Credit			NUMERIC(38,6),
			NetOtStd		NUMERIC(38,6),
			Suppress		INT'
				
	SET @TblFields = 'RtrId,RtrCode,RtrName,CrDays,NoBills,Bucket1,Bucket2,
					  Bucket3,Bucket4,Bucket5,BillOutStd,onAccount,SalPayAmt,
					  Debit,Credit,NetOtStd,Suppress'
	
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
		EXEC Proc_AROutStandingReport @FromDate,@SmId,@RmId,@RtrId,@Pi_RptId,@Pi_UsrId
		
		INSERT INTO #RptAgeingAnalysis(RtrId,RtrCode,RtrName,CrDays,NoBills,Bucket1,Bucket2,
					  Bucket3,Bucket4,Bucket5,BillOutStd,onAccount,SalPayAmt,
					  Debit,Credit,NetOtStd,Suppress)
		
		--(Debit+SalInvNetAmount) - (Credit+OnAccount)
		Select RtrId,RtrCode,RtrName,CrDays,NoBills,Bucket1,Bucket2,
					  Bucket3,Bucket4,Bucket5,BillOutStd,onAccount,SalPayAmt,
					  Debit,Credit,---((Debit+NetOtStd)-(Credit+onAccount)) AS NetOtStd,
					  0 AS NetOtStd,   @Start
		From TempAGAgeningRpt  --Select * from TempAGAgeningRpt where rtrid = 2463
		Where usrid = @Pi_UsrId AND RptId=@Pi_RptId
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptAgeingAnalysis ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptAgeingAnalysis'
			
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
			SET @SSQL = 'INSERT INTO #RptAgeingAnalysis ' +
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
			/*  Net Amount Calculated */
	Update #RptAgeingAnalysis SET  NetOtStd =  (BillOutStd + Debit ) - (onAccount + Credit)
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptAgeingAnalysis WHERE NetOtStd <> 0 AND Bucket1+Bucket2+Bucket3+Bucket4+Bucket5 <> 0
	--select * FROM #RptRetailerOutstanding WHERE NetAmount <> 0
	SELECT RtrId,RtrCode,RtrName,CrDays,Bucket1,Bucket2,Bucket3,Bucket4,Bucket5,NoBills,
			 BillOutStd,onAccount,Credit,Debit,
			 NetOtStd,Suppress,SalPayAmt 
	FROM #RptAgeingAnalysis WHERE NetOtStd <> 0 AND Bucket1+Bucket2+Bucket3+Bucket4+Bucket5 <> 0 
	ORDER BY RtrCode
	DELETE FROM RptFormula WHERE RptId=182 AND Slno BETWEEN 4 AND 8
	INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId) VALUES
	(182,4,'Bucket1',@Bucket1,1,0)
	INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId) VALUES
	(182,5,'Bucket2',@Bucket2,1,0)
	INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId) VALUES
	(182,6,'Bucket3',@Bucket3,1,0)
	INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId) VALUES
	(182,7,'Bucket4',@Bucket4,1,0)
	INSERT INTO RptFormula (RptId,SlNo,Formula,FormulaValue,LcId,SelcId) VALUES
	(182,8,'Bucket5',@Bucket5,1,0)
	IF @Bucket1<>''
	BEGIN
		UPDATE RptExcelHeaders SET DisplayName=@Bucket1,DisplayFlag=1 WHERE SlNo=5 AND RptId=@Pi_RptId
	END
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0  WHERE SlNo=5 AND RptId=@Pi_RptId
	END
	IF @Bucket2<>''
	BEGIN
		UPDATE RptExcelHeaders SET DisplayName=@Bucket2,DisplayFlag=1 WHERE SlNo=6 AND RptId=@Pi_RptId
	END
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0  WHERE SlNo=6 AND RptId=@Pi_RptId
	END
	IF @Bucket3<>''
	BEGIN
		UPDATE RptExcelHeaders SET DisplayName=@Bucket3,DisplayFlag=1 WHERE SlNo=7 AND RptId=@Pi_RptId
	END
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0  WHERE SlNo=7 AND RptId=@Pi_RptId
	END
	
	IF @Bucket4<>''
	BEGIN
		UPDATE RptExcelHeaders SET DisplayName=@Bucket4,DisplayFlag=1 WHERE SlNo=8 AND RptId=@Pi_RptId
	END
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0  WHERE SlNo=8 AND RptId=@Pi_RptId
	END
	
	IF @Bucket5<>''
	BEGIN
		UPDATE RptExcelHeaders SET DisplayName=@Bucket5,DisplayFlag=1 WHERE SlNo=9 AND RptId=@Pi_RptId
	END
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0  WHERE SlNo=9 AND RptId=@Pi_RptId
	END
	RETURN
END
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='U' AND [Name]='TempOrderChange')
DROP TABLE TempOrderChange
GO
CREATE TABLE TempOrderChange
	(
	SalId [BigInt],
	[ORDERDATE] [datetime] NULL,
	[ORDERNO] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CMPID] [int] NULL,
	[SMID] [int] NULL,
	[RMID] [int] NULL,
	[RTRID] [int] NULL,
	[PRDID] [int] NULL,
	[SMNAME] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RMNAME] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RTRNAME] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RTRCODE] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PRDNAME] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RECEIVED] [numeric](18, 2) NULL,
	[SERVICED] [numeric](18, 2) NULL,
	[Type] [int] NULL,
	[RptId] [int] NULL,
	[UserId] [int] NULL,
	[CTGLEVELID] [int] NULL,
	[CTGMAINID] [int] NULL,
	[RtrClassId] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_QuantityFillRatio')
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
		SELECT  DISTINCT 0 AS SalId,C.ORDERDATE,C.ORDERNO,G.CMPID,C.SMID,C.RMID,C.RTRID,B.PRDID,F.SMNAME,D.RMNAME,E.RTRNAME,  
		E.RTRCODE,G.PRDNAME,0 AS RECEIVED,COUNT(DISTINCT A.PRDID) AS SERVICED,1 as Type,RG.CTGLEVELID,  
		RC.CTGMAINID,RV.RtrValueClassId AS RtrClassId,@Pi_RptId AS RptID,@Pi_UserId AS UserID 
		FROM SALESINVOICEPRODUCT A  
		INNER JOIN SALESINVOICEORDERBOOKING H ON A.SalID = H.SalId  
		INNER JOIN  ORDERBOOKINGPRODUCTS B ON H.PRDID=B.PRDID  
		AND H.ORDERNO=B.ORDERNO   
		Right JOIN ORDERBOOKING C ON B.ORDERNO=C.ORDERNO  
		INNER JOIN ROUTEMASTER  D ON C.RMID=D.RMID  
		INNER JOIN RETAILER E ON C.RTRID=E.RTRID  
		INNER JOIN SALESMAN F ON C.SMID=F.SMID  
		INNER JOIN RETAILERVALUECLASSMAP RV ON RV.RtrId=E.RtrId  
		INNER JOIN RETAILERVALUECLASS RC ON RC.RtrClassId=RV.RtrValueClassId  
		INNER JOIN RetailerCategory RG ON RG.CtgMainId=RC.CtgMainId  
		INNER JOIN PRODUCT G ON  B.PRDID=G.PRDID   
		INNER JOIN PRODUCTBATCH I ON G.PRDID=I.PRDID AND A.PrdId=I.PrdId   
		AND A.PrdBatId=I.PrdBatId AND B.PrdID=I.PrdID AND B.PrdBatId=I.PrdBatId   
		AND H.PrdID=I.PrdID AND H.PrdBatId=I.PrdBatId  
		WHERE OrderDate BETWEEN @FromDate AND @ToDate    
		GROUP BY A.SalId,C.ORDERDATE,C.ORDERNO,G.CMPID,C.SMID,C.RMID,C.RTRID,B.PRDID,F.SMNAME,ISNULL(A.PrdId,0),  
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
		INNER JOIN PRODUCTBATCH I ON G.PRDID=I.PRDID 
		AND B.PrdID=I.PrdID AND B.PrdBatId=I.PrdBatId   
		WHERE OrderDate  BETWEEN @FromDate AND @ToDate
		AND B.ORDERNO IN (SELECT ORDERNO FROM SalesInvoiceOrderBooking)
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
		Sum(TotalQty) RECEIVED,Sum(BilledQty) SERVICED, 2 AS [Type],CTGLEVELID,RG.CTGMAINID,RtrClassId,@Pi_RptId AS RptId,@Pi_UserId AS UserId
		FROM 
		(
		SELECT 0 AS SalId,A.OrderNo,Prdid,Prdbatid,BilledQty,TotalQty FROM  OrderBookingProducts A  
		WHERE NOT EXISTS(SELECT OrderNo,Prdid,Prdbatid FROM SALESINVOICEORDERBOOKING B
		WHERE A.OrderNo=B.OrderNo AND A.Prdid=B.Prdid AND A.Prdbatid=B.Prdbatid)
		UNION ALL
		SELECT 0 AS SalId,OrderNo,Prdid,Prdbatid,BilledQty,0 AS TotalQty  
		FROM SALESINVOICEORDERBOOKING A WHERE NOT EXISTS(SELECT OrderNo,Prdid,Prdbatid FROM OrderBookingProducts B
		WHERE A.OrderNo=B.OrderNo AND A.Prdid=B.Prdid AND A.Prdbatid=B.Prdbatid)
		UNION ALL
		SELECT 0 AS SalId,A.OrderNo,A.Prdid,A.Prdbatid,A.BilledQty,A.TotalQty FROM  OrderBookingProducts A  
		INNER JOIN SALESINVOICEORDERBOOKING B ON 
		A.OrderNo=B.OrderNo AND A.Prdid=B.Prdid AND A.Prdbatid=B.Prdbatid
		) X 
		INNER JOIN OrderBooking C ON X.OrderNO=C.OrderNO
		INNER JOIN Salesman S ON S.SMId = C.SmId
		INNER JOIN RouteMaster RM ON RM.RMId=C.RmId
		INNER JOIN Retailer R ON R.RtrId=C.RtrId
		INNER JOIN Product P ON X.PrdId=P.PrdId
		INNER JOIN ProductBatch PB ON X.PrdId=PB.PrdId AND X.PrdBatId=PB.PrdBatId
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
				WHERE A.OrderNo=B.OrderNo AND A.Prdid=B.Prdid AND A.Prdbatid=B.Prdbatid)
				UNION ALL
				SELECT OrderNo,Prdid,Prdbatid,0 AS Received,0 AS Serviced,A.SalId 
				FROM SALESINVOICEORDERBOOKING A WHERE NOT EXISTS(SELECT OrderNo,Prdid,Prdbatid FROM OrderBookingProducts B
				WHERE A.OrderNo=B.OrderNo AND A.Prdid=B.Prdid AND A.Prdbatid=B.Prdbatid)
				UNION ALL
				SELECT A.OrderNo,A.Prdid,A.Prdbatid,A.GrossAmount AS Received,0 AS Serviced,B.SalId FROM  OrderBookingProducts A  
				INNER JOIN SALESINVOICEORDERBOOKING B ON 
				A.OrderNo=B.OrderNo AND A.Prdid=B.Prdid AND A.Prdbatid=B.Prdbatid
				) X 
				LEFT OUTER JOIN SalesInvoiceProduct SIP ON X.SalId=SIP.SalId AND SIp.PrdId=X.PrdId AND SIp.PrdBatId=X.PrdBatId
				INNER JOIN OrderBooking C ON X.OrderNO=C.OrderNO
				INNER JOIN Salesman S ON S.SMId = C.SmId
				INNER JOIN RouteMaster RM ON RM.RMId=C.RmId
				INNER JOIN Retailer R ON R.RtrId=C.RtrId
				INNER JOIN Product P ON X.PrdId=P.PrdId
				INNER JOIN ProductBatch PB ON X.PrdId=PB.PrdId AND X.PrdBatId=PB.PrdBatId
				INNER JOIN RETAILERVALUECLASSMAP RV ON RV.RtrId=R.RtrId  
				INNER JOIN RETAILERVALUECLASS RC ON RC.RtrClassId=RV.RtrValueClassId  
				INNER JOIN RetailerCategory RG ON RG.CtgMainId=RC.CtgMainId  
				WHERE C.OrderDate BETWEEN @FromDate AND @ToDate
				GROUP BY X.SalId,C.OrderDate,C.OrderNo,P.CmpId,S.SMId,RM.RMId,R.RtrId,X.PrdId,SMNAME,RMNAME,RTRNAME,RTRCODE,PRDNAME,
				CTGLEVELID,RG.CTGMAINID,RtrClassId
	END  
END  
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_RptQuantityRatioReport')
DROP PROCEDURE Proc_RptQuantityRatioReport
GO
--EXEC Proc_RptQuantityRatioReport 60,1,0,'Core',0,0,1  
CREATE PROCEDURE Proc_RptQuantityRatioReport
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
 IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
 BEGIN  
  Execute Proc_QuantityFillRatio @Pi_RptId,@Pi_UsrId,@TypeId  
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
 Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId  
 INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
 SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptQuantityRatioReport  
 -- Till Here  
 --SELECT * FROM #RptQuantityRatioReport  
 SELECT CMPID,SMID,RMID,RTRID,PRDID,SMNAME,RMNAME,RTRCODE,RTRNAME,PRDNAME,RECEIVED,SERVICED,Type  
 FROM #RptQuantityRatioReport  
 RETURN  
END
GO
IF EXISTS (Select * From SysObjects Where Name ='SalesInvoiceModificationHistory' And XTYPE = 'U')
DROP PROCEDURE SalesInvoiceModificationHistory
GO
CREATE TABLE SalesInvoiceModificationHistory
(
	[SalId] [bigint] NULL,
	[SalInvNo] [varchar](50) NULL,
	[SalInvDate] [datetime] NULL,
	[SalNetAmount] [numeric](38, 6) NULL,
	[LcnId] [int] NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[BaseQty] [int] NULL,
	[PrdUnitMRP] [numeric](38, 6) NULL,
	[PrdUnitSelRate] [numeric](38, 6) NULL,
	[PrdGrossAmount] [numeric](38, 6) NULL,
	[SplDiscAmount] [numeric](38, 6) NULL,
	[PrdSchDiscAmount] [numeric](38, 6) NULL,
	[PrdDBDiscAmount] [numeric](38, 6) NULL,
	[PrdCdAmount] [numeric](38, 6) NULL,
	[PrimarySchemeAmount] [numeric](38, 6) NULL,
	[PrdTaxAmount] [numeric](38, 6) NULL,
	[PrdNetAmount] [numeric](38, 6) NULL,
	[StockType] [int] NULL,
	[TransactionFlag] [int] NULL,
	[AllotmentId] [int] NULL,
	[VersionNo] [int] NULL,
	[DlvSts] [int] NULL,
	[ModifiedDate] [datetime] NULL,
	[VehicleStstus] [int] NULL,
	[VehicleId] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (Select * From SysObjects Where Name ='Proc_SalesInvoiceModificationHistory' And XTYPE = 'P')
DROP PROCEDURE Proc_SalesInvoiceModificationHistory
GO
CREATE PROCEDURE Proc_SalesInvoiceModificationHistory
(
	@Pi_TransId INT,
	@Pi_SalId BigInt
)
AS
/****************************************************************************************
Procedure Name  :Proc_SalesInvoiceModificationHistory
Purpose			:To Maintain the SalesInvoiceHistoryDetials
Created by		:Panneerselvam.k
Created on		:03/11/2009	
****************************************************************************************/
BEGIN
SET NOCOUNT ON
/*  Note :-
	TransId         1 :- Billing
					2 :- Vehicle Allocation
					3 :- Auto Delivery Procress
	TransactionFlag	1 :- Billing
					2 :- Free
					3 :- MarketReturn
					4 :- Replacement
*/
DECLARE @MaxVersionNo INT
DECLARE @VehicleStatus INT
DECLARE @VanDlvSts INT
SELECT @MaxVersionNo =  Isnull(VersionNo,1)  FROM SalesInvoiceModificationHistory 
											 WHERE SalId = @Pi_SalId
SET @MaxVersionNo = Isnull(@MaxVersionNo,0) + 1
			
SELECT @VehicleStatus = Dlvsts FROM SalesInvoiceModificationHistory 
											 WHERE SalId = @Pi_SalId
SELECT @VanDlvSts = Dlvsts FROM SalesInvoice WHERE SalId = @Pi_SalId
	IF @Pi_TransId = 1
	BEGIN
				/*	Sales  */
		INSERT INTO SalesInvoiceModificationHistory	
		SELECT 
				SI.SalId,SI.SalInvNo,SI.SalInvDate,SalNetAmt,SI.LcnId,
				SIP.PrdId,SIP.PrdBatId,BaseQty,PrdUnitMRP,PrdUnitSelRate,
				PrdGrossAmount,SplDiscAmount,PrdSchDiscAmount,PrdDBDiscAmount,
				PrdCDAmount,PrimarySchemeAmt,PrdTaxAmount,PrdNetAmount,
				1 StockType,1 TransactionFlag,0 AllotmentId,@MaxVersionNo VersionNo,
				DlvSts,GetDate() ModifiedDate,0 VehicleStatus,0 AS VehicleId
		FROM 
			SalesInvoice SI (NoLock),SalesInvoiceProduct SIP (NoLock)
		WHERE
			SI.SalId = SIP.SalId
			AND SI.SalId =  @Pi_SalId
				/*	Sales Manual Free and Sales Invoice Free */
		INSERT INTO SalesInvoiceModificationHistory	
		SELECT  SalId,SalInvNo,SalInvDate,SalNetAmt,LcnId,
				PrdId,PrdBatId,Sum(FreeQty) FreeQty,PrdUnitMRP,PrdUnitSelRate,
				PrdGrossAmount,SplDiscAmount,PrdSchDiscAmount,PrdDBDiscAmount,PrdCDAmount,
				PrimarySchemeAmt,PrdTaxAmount,PrdNetAmount,StockType,TransactionFlag,AllotmentId,
				VersionNo,DlvSts,ModifiedDate,VehicleStatus,VehicleId
		FROM (
				SELECT 
						SI.SalId,SI.SalInvNo,SI.SalInvDate,SalNetAmt,SI.LcnId,
						SIP.PrdId,SIP.PrdBatId,SIP.SalManFreeQty AS FreeQty,0 PrdUnitMRP, 0 PrdUnitSelRate,
						0 PrdGrossAmount,0 SplDiscAmount,0 PrdSchDiscAmount,0 PrdDBDiscAmount,
						0 PrdCDAmount,0 PrimarySchemeAmt,0 PrdTaxAmount,0 PrdNetAmount,
						3 StockType,2 TransactionFlag,0 AllotmentId,@MaxVersionNo VersionNo,
						DlvSts,GetDate()  ModifiedDate ,0 VehicleStatus,0 AS VehicleId
				FROM 
					SalesInvoice SI (NoLock),SalesInvoiceProduct SIP (NoLock)
				WHERE
					SI.SalId = SIP.SalId
					AND SI.SalId = @Pi_SalId
					AND SIP.SalManFreeQty > 0
				UNION ALL
				SELECT 
						SI.SalId,SI.SalInvNo,SI.SalInvDate,SalNetAmt,SI.LcnId,
						SIF.FreePrdId,SIF.FreePrdBatId,SIF.FreeQty AS FreeQty,0 PrdUnitMRP, 0 PrdUnitSelRate,
						0 PrdGrossAmount,0 SplDiscAmount,0 PrdSchDiscAmount,0 PrdDBDiscAmount,
						0 PrdCDAmount,0 PrimarySchemeAmt,0 PrdTaxAmount,0 PrdNetAmount,
						3 StockType,2 TransactionFlag,0 AllotmentId,@MaxVersionNo VersionNo,
						DlvSts,GetDate() ModifiedDate , 0 VehicleStatus,0 AS VehicleId
				FROM 
					SalesInvoice SI,SalesInvoiceSchemeDtFreePrd SIF
				WHERE
					SI.SalId = SIF.SalId
					AND SI.SalId = @Pi_SalId ) AS X
		GROUP BY 
				SalId,SalInvNo,SalInvDate,SalNetAmt,PrdId,PrdBatId,PrdUnitMRP,PrdUnitSelRate,LcnId,
				PrdGrossAmount,SplDiscAmount,PrdSchDiscAmount,PrdDBDiscAmount,PrdCDAmount,
				PrimarySchemeAmt,PrdTaxAmount,PrdNetAmount,StockType,TransactionFlag,AllotmentId,
				VersionNo,DlvSts,ModifiedDate,VehicleStatus,VehicleId
				/*  Market Return  */
		INSERT INTO SalesInvoiceModificationHistory	
		SELECT  SalId,SalInvNo,SalInvDate,SalNetAmt,LcnId,
				PrdId,PrdBatId,Sum(BaseQty) BaseQty,PrdUnitMRP,PrdUnitSelRte,
				PrdGrossAmt,PrdSplDisAmt,PrdSchDisAmt,PrdDBDisAmt,PrdCDDisAmt,
				PrimarySchAmt,PrdTaxAmt,PrdNetAmt,StockTypeId,TransactionFlag,AllotmentId,
				VersionNo,DlvSts,ModifiedDate,VehicleStatus,VehicleId
		FROM  (
				SELECT  
						SI.SalId,SI.SalInvNo,SI.SalInvDate,SalNetAmt,SI.LcnId,
						RP.PrdId,RP.PrdBatId ,RP.BaseQty,RP.PrdUnitMRP,RP.PrdUnitSelRte,
						RP.PrdGrossAmt,RP.PrdSplDisAmt,RP.PrdSchDisAmt,RP.PrdDBDisAmt,
						RP.PrdCDDisAmt,RP.PrimarySchAmt,RP.PrdTaxAmt,RP.PrdNetAmt,
						RP.StockTypeId,3 TransactionFlag,0 AllotmentId,
						@MaxVersionNo VersionNo,DlvSts,GetDate() ModifiedDate,0 VehicleStatus,0 AS VehicleId
				FROM 
						SalesInvoice SI (NoLock),SalesInvoiceMarketReturn SIMR (NoLock),
						ReturnHeader RH (NoLock),ReturnProduct RP (NoLock)
				WHERE
							SI.SalId = SIMR.SalId
							AND RH.ReturnID = SIMR.ReturnId
							AND RH.ReturnID = RP.ReturnID
							AND SI.SalId = @Pi_SalId
				UNION All
				SELECT   
						SI.SalId,SI.SalInvNo,SI.SalInvDate,SalNetAmt,SI.LcnId,
						RPF.FreePrdId AS PrdId,RPF.FreePrdBatId AS PrdBatId,
						RPF.ReturnFreeQty BaseQty, 
						0 PrdUnitMRP,0 PrdUnitSelRte,
						0 PrdGrossAmt,0 PrdSplDisAmt,0 PrdSchDisAmt,0 PrdDBDisAmt,
						0 PrdCDDisAmt,0 PrimarySchAmt,0 PrdTaxAmt,0 PrdNetAmt,
						RPF.FreeStockTypeId,3 TransactionFlag,0 AllotmentId,
						@MaxVersionNo VersionNo,DlvSts,GetDate() ModifiedDate,0 VehicleStatus,VehicleId
				FROM 
						SalesInvoice SI (NoLock),SalesInvoiceMarketReturn SIMR (NoLock),
						ReturnHeader RH (NoLock),ReturnSchemeFreePrdDt RPF (NoLock)
				WHERE
							SI.SalId = SIMR.SalId
							AND RH.ReturnID = SIMR.ReturnId
							AND RH.ReturnID = RPF.ReturnID
							AND SI.SalId = @Pi_SalId ) AS Y
		GROUP BY 
				SalId,SalInvNo,SalInvDate,SalNetAmt,PrdId,PrdBatId,PrdUnitMRP,PrdUnitSelRte,LcnId,
				PrdGrossAmt,PrdSplDisAmt,PrdSchDisAmt,PrdDBDisAmt,PrdCDDisAmt,
				PrimarySchAmt,PrdTaxAmt,PrdNetAmt,StockTypeId,TransactionFlag,AllotmentId,
				VersionNo,DlvSts,ModifiedDate,VehicleStatus,VehicleId
			/* Replacement Out  */
		INSERT INTO SalesInvoiceModificationHistory
		SELECT  
				SI.SalId,SI.SalInvNo,SI.SalInvDate,SalNetAmt,SI.LcnId,
				RO.PrdId,RO.PrdBatId,RO.RepQty,0 PrdUnitMRP,SelRte PrdUnitSelRte,
				RepAmount PrdGrossAmt,0 PrdSplDisAmt,0 PrdSchDisAmt,0 PrdDBDisAmt,
				0 PrdCDDisAmt,0 PrimarySchAmt,Tax PrdTaxAmt,0 PrdNetAmt,
				RO.StockTypeId,4 TransactionFlag,0 AllotmentId,
				@MaxVersionNo VersionNo,DlvSts,GetDate() ModifiedDate,0 VehicleStatus,VehicleId
		FROM 
				SalesInvoice SI (NoLock),ReplacementHd RHD (NoLock),ReplacementOut RO (NoLock)
		WHERE
					SI.SalId = RHD.SalId
					AND RHD.RepRefNo = RO.RepRefNo
					AND SI.SalId = @Pi_SalId
				/* Vehicle Status and Allotment Id */
		IF @VehicleStatus = 2 
		BEGIN
			UPDATE SalesInvoiceModificationHistory SET VehicleStstus = 1  
						WHERE VersionNo = @MaxVersionNo AND SalId = @Pi_SalId	
			UPDATE SalesInvoiceModificationHistory SET AllotmentId = B.AllotmentId,VehicleId = B.VehicleId
						FROM  SalesInvoiceModificationHistory a,VehicleAllocationMaster b,
							  VehicleAllocationDetails C
						WHERE VersionNo = @MaxVersionNo AND SalId = @Pi_SalId
							  AND A.SalInvNo = C.SaleInvNo  AND B.AllotmentNumber = C.AllotmentNumber
		END
		IF @VanDlvSts = 2 OR @VanDlvSts = 3 OR  @VanDlvSts = 4 OR  @VanDlvSts = 5
		BEGIN
			UPDATE SalesInvoiceModificationHistory SET VehicleStstus = 1  
						WHERE VersionNo = @MaxVersionNo AND SalId = @Pi_SalId	
			UPDATE SalesInvoiceModificationHistory SET AllotmentId = B.AllotmentId,VehicleId = B.VehicleId
						FROM  SalesInvoiceModificationHistory a,VehicleAllocationMaster b,
							  VehicleAllocationDetails C
						WHERE VersionNo = @MaxVersionNo AND SalId = @Pi_SalId
							  AND A.SalInvNo = C.SaleInvNo  AND B.AllotmentNumber = C.AllotmentNumber
		END
				/*  Update MRP  in  History table */
		SELECT Distinct
				SalId,C.PrdId,A.PrdBatId,A.PrdBatDetailValue  INTO #TEMPMRPDET 
		FROM 
				ProductBatchDetails A ,BatchCreation B, 
				SalesInvoiceModificationHistory C
		WHERE 
				A.BatchSeqId = B.BatchSeqId AND A.SLNo = B.SlNo
				AND FieldDesc = 'MRP' AND B.SlNo = 1
				AND A.PrdBatId = C.PrdBatId 
				AND C.SalId =  @Pi_SalId
		UPDATE SalesInvoiceModificationHistory SET PrdUnitMRP = PrdBatDetailValue
				FROM SalesInvoiceModificationHistory A,#TEMPMRPDET B
				WHERE	A.SalId = B.SalId
						AND A.PrdBatId = B.PrdBatId
						AND TransactionFlag IN(2,3,4)
						AND A.SalId =  @Pi_SalId
				/*  Update Selling Rate  in  History table */
		SELECT Distinct
				SalId,C.PrdId,A.PrdBatId,A.PrdBatDetailValue INTO #TEMPMRPDETLSP 
		FROM 
				ProductBatchDetails A ,BatchCreation B, 
				SalesInvoiceModificationHistory C
		WHERE 
				A.BatchSeqId = B.BatchSeqId AND A.SLNo = B.SlNo
				AND FieldDesc = 'Selling Rate' AND B.SlNo = 3
				AND A.PrdBatId = C.PrdBatId 
				AND C.SalId = @Pi_SalId
		UPDATE SalesInvoiceModificationHistory SET PrdUnitSelRate= PrdBatDetailValue
				FROM SalesInvoiceModificationHistory A,#TEMPMRPDETLSP B
				WHERE	A.SalId = B.SalId
						AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
						AND TransactionFlag IN(2,3,4)
						AND A.SalId = @Pi_SalId
				/* End Here */
	END
	IF @Pi_TransId = 2
	BEGIN
			SELECT 
					A.AllotmentId,A.AllotmentNumber,A.VehicleId,A.LcnId,
					B.SaleInvNo AS SalInvNo,Max(VersionNo) VersionNo INTO #TEMPVALLOC
			FROM	VehicleAllocationMaster A,
					VehicleAllocationDetails B,
					SalesInvoiceModificationHistory C
			WHERE 
					A.AllotmentNumber = B.AllotmentNumber
					AND B.SaleInvNo = C.SalInvNo
					AND A.AllotmentId = @Pi_SalId
			GROUP BY
					A.AllotmentId,A.AllotmentNumber,A.VehicleId,A.LcnId,
					B.SaleInvNo
			UPDATE	SalesInvoiceModificationHistory 
					SET VehicleStstus = 1,AllotmentId = @Pi_SalId,DlvSts = 2,
								VehicleId = B.VehicleId
					FROM	SalesInvoiceModificationHistory a,#TEMPVALLOC B
					Where	A.SalInvNo = B.SalInvNo AND B.AllotmentId = @Pi_SalId
							AND A.VersionNo = B.VersionNo
	END 
	IF @Pi_TransId = 3
	BEGIN
		DECLARE @MaxVer AS INT
		SELECT @MaxVer = Max(VersionNo) FROM SalesInvoiceModificationHistory WHERE SalId = @Pi_SalId
		UPDATE  SalesInvoiceModificationHistory 
				SET AllotmentId = b.AllotmentId,VehicleStstus = 1,VehicleId =B.VehicleId,DlvSts = 2
				FROM SalesInvoiceModificationHistory a,VehicleAllocationMaster B,
					 VehicleAllocationDetails C
				WHERE A.SalInvNo = C.SaleInvNo AND C.AllotmentNumber = B.AllotmentNumber
					  AND A.SalId = @Pi_SalId  AND VersionNo = @MaxVer
					 
	END
END
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 397)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(397,'D','2011-12-29',getdate(),1,'Core Stocky Service Pack 397')
GO