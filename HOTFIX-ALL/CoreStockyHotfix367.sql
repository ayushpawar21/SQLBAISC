--[Stocky HotFix Version]=367
Delete from Versioncontrol where Hotfixid='367'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('367','2.0.0.5','D','2011-03-25','2011-03-25','2011-03-25',convert(varchar(11),getdate()),'Parle;Major:-Akso Nobel and Henkel CRs;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 367' ,'367'
GO

--SRF-Nanda-218-001

Update RPTDetails SET Mandatory = 1,FldCaption = 'Suppress Zero Stock*...'  Where RptId  = 221  and SlNo = 8

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PurchaseOrderExtractExcel]') AND type in (N'U'))
DROP TABLE [PurchaseOrderExtractExcel]
GO
CREATE TABLE [PurchaseOrderExtractExcel](
	[DistCode] [nvarchar](150) NULL,
	[DistName] [nvarchar](150) NULL,
	[Transaction]  [nvarchar](150) NULL,
	[PODate] [datetime] NULL,
	[PONumber] [nvarchar](150) NULL,
	[ProductCode] [nvarchar](550) NULL,
	[ProductName] [nvarchar](550) NULL,
	[SysGenUomid] [int] NULL,
	[SystemOrderQty] [int] NULL,
	[SystemOrderUOM] [nvarchar](50) NULL,
	[OrdUomId] [int] NULL,
	[FinalORDERQty] [int] NULL,
	[FinalOrderUOM] [nvarchar](50) NULL,
	[FinalOrderQtyBaseUOM] [nvarchar](50) NULL
) ON [PRIMARY]
GO
DELETE FROM RptAKSOExcelHeaders WHERE Rptid=501
INSERT INTO RptAKSOExcelHeaders VALUES (501,1,'DistCode','Dist Code',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,2,'DistName','Dist Name ',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,3,'Transaction','Transaction Name ',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,4,'PODate','Purchase Order Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,5,'PONumber','Purchase Order No',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,6,'ProductCode','Product Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,7,'ProductName','Product Name',	1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,8,'SysGenUomid','SysGenUomid',0,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,9,'SystemOrderQty','System Order Qty',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,10,'SystemOrderUOM','System Order UOM',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,11,'OrdUomId','OrdUomId',0,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,12,'FinalORDERQty','Final Order Qty',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,13,'FinalOrderUOM','Final Order UOM',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,14,'FinalOrderQtyBaseUOM','Final OrderQty Base UOM ',1,	1)

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_AN_PurchaseOrder')
DROP PROCEDURE  Proc_AN_PurchaseOrder
GO
-- EXEC Proc_AN_PurchaseOrder '2010-02-22','2011-03-25'
CREATE PROCEDURE Proc_AN_PurchaseOrder
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
SET NoCOunt On
BEGIN
	DELETE FROM PurchaseOrderExtractExcel
	INSERT INTO PurchaseOrderExtractExcel (
	PONumber,PODate,ProductCode,ProductName,SysGenUomid,SystemOrderQty,OrdUomId,FinalORDERQty)
	
	SELECT DISTINCT A.PurOrderRefNo,A.PurOrderDate,C.PrdCCode,C.PrdName,B.SysGenUomid,B.SysGenQty,B.OrdUomId,B.OrdQty
		FROM PurchaseOrderMaster A
		INNER JOIN PurchaseOrderDetails B ON A.PurOrderRefNo=B.PurOrderRefNo
        INNER JOIN Product C ON B.PrdID=C.PrdID
		INNER JOIN Company D ON A.CmpId=D.CmpId
		LEFT OUTER JOIN Supplier E ON E.SpmID=A.SpmID
	WHERE PurOrderDate BETWEEN @Pi_FromDate AND @Pi_ToDate
   
	Update PurchaseOrderExtractExcel SET [Transaction] = 'Purchase Order'
	UPDATE PurchaseOrderExtractExcel SET DistCode=(SELECT DistributorCode FROM Distributor)
	UPDATE PurchaseOrderExtractExcel SET DistName=(SELECT DistributorName FROM Distributor)
	UPDATE PO SET PO.SystemOrderUOM=UO.UOMDescription FROM PurchaseOrderExtractExcel PO INNER JOIN UomMaster UO ON PO.SysGenUomid=UO.UomId
	UPDATE PurchaseOrderExtractExcel SET FinalOrderUOM=UO.UOMDescription FROM PurchaseOrderExtractExcel PO INNER JOIN UomMaster UO ON PO.OrdUomId=UO.UomId

	UPDATE PurchaseOrderExtractExcel SET FinalOrderQtyBaseUOM=UG.ConversionFactor*FinalORDERQty
	FROM PurchaseOrderExtractExcel PO INNER JOIN Product C ON Po.ProductCode=C.PrdCCode
	INNER JOIN UomGroup UG ON C.UomGroupId=UG.UomGroupId AND UG.BaseUom='Y'
END 
GO 

--SRF-Nanda-218-002

IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_RptCurrentStockAN' AND Xtype='P')
DROP procedure [Proc_RptCurrentStockAN] 
GO
-- EXEC [Proc_RptCurrentStockAN] 221,2,0,'PARLEFRESHDB',0,0,1,0
CREATE PROC [dbo].[Proc_RptCurrentStockAN]
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
BEGIN
-- =============================================
-- Author:		R.Vasantharaj
-- Create date: 17/03/2011
-- Description:	Current Stock Report
-- =============================================
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
	DECLARE @PrdCatId  AS Int
	DECLARE @PrdBatId        AS Int
	DECLARE @CtgValue      AS Int
	DECLARE @PrdCatValId      AS Int
	DECLARE @DisplayLevel       AS Int
	DECLARE @PrdId        AS Int
	DECLARE @SupZeroStock	AS INT
	DECLARE @StockType	AS INT
	            
	--Till Here
	--Assgin Value for the Filter Variable
    SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @StockType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))
    SET @CtgValue=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
    SET @PrdCatValId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
    SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @DisplayLevel = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,260,@Pi_UsrId))
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
    --SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(221,260,2)
    EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
    
	CREATE TABLE #RPTCURRENTSTOCKAN
	(
		[CmpPrdCtgId]						INT,
		[Product Hierarchy Level Value]     NVARCHAR(200),
		[PrdCtgValMainId]					INT,
		[PrdCtgValCode]						NVARCHAR(300),
		[Description]						NVARCHAR(300),
		[PrdId]								INT,
		[Product Code]						NVARCHAR(200),
		[Product Name]						NVARCHAR(300),
		[LcnId]								INT,
		[Location Name]						NVARCHAR(300),
		[SystemStockType]					TINYINT,
		[Stock Type]						NVARCHAR(100),
		[Quantity Packs]					INT,
		[PrdUnitId]							INT,
		[Quantity In Volume(Unit)]			NUMERIC(18,2),
		[Quantity In Volume(KG)]            NUMERIC(18,2),
		[Quantity In Volume(Litre)]         NUMERIC(18,2),
		[Value]								NUMERIC(18,2)
	)
	SET @TblName = 'RPTCURRENTSTOCK'
	SET @TblStruct = '  [CmpPrdCtgId]						INT,
						[Product Hierarchy Level Value]     NVARCHAR(200),
						[PrdCtgValMainId]					INT,
						[PrdCtgValCode]						NVARCHAR(300),
						[Description]						NVARCHAR(300),
						[PrdId]								INT,
						[Product Code]						NVARCHAR(200),
						[Product Name]						NVARCHAR(300),
						[LcnId]								INT,
						[Location Name]						NVARCHAR(300),
						[SystemStockType]					TINYINT,
						[Stock Type]						NVARCHAR(100),
						[Quantity Packs]					INT,
						[PrdUnitId]							INT,
						[Quantity In Volume(Unit)]			NUMERIC(18,2),
						[Quantity In Volume(KG)]            NUMERIC(18,2),
						[Quantity In Volume(Litre)]         NUMERIC(18,2),
						[Value]								NUMERIC(18,2)'
	SET @TblFields = '[CmpPrdCtgId],[Product Hierarchy Level Value],[PrdCtgValMainId],[PrdCtgValCode],[Description],[PrdId],[Product Code],
					  [Product Name],[LcnId],[Location Name],[SystemStockType],[Stock Type],[Quantity Packs],[PrdUnitId],
					  [Quantity In Volume(Unit)],[Quantity In Volume(KG)],[Quantity In Volume(Litre)],[Value]'
IF @DisplayLevel=2
BEGIN
	INSERT INTO #RPTCURRENTSTOCKAN ([CmpPrdCtgId],[Product Hierarchy Level Value],[PrdCtgValMainId],[PrdCtgValCode],[Description],
									[LcnId],[Location Name],[SystemStockType],[Stock Type],[Quantity Packs],[PrdUnitId],
									[Quantity In Volume(Unit)],[Quantity In Volume(KG)],[Quantity In Volume(Litre)],[Value])
	SELECT DISTINCT G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
	/*F.PrdId,F.PrdCCode,F.PrdName,*/F.LcnId,F.LcnName,F.SystemStockType,F.UserStockType,sum(BaseQty),PrdUnitId,sum(PrdOnUnit),sum(PrdOnKg),
	sum(PrdOnLitre),sum(SumValue)
		FROM ProductCategoryValue C
		INNER JOIN(Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
				A.Prdid from Product A
		INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
			      (A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
			       A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		INNER JOIN 
	              (SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,0 AS BaseQty,
	               B.PrdUnitId,0 AS PrdOnUnit,0 AS PrdOnKg,0 AS PrdOnLitre,0 as SumValue
	               FROM ProductBatchLocation A 
		INNER JOIN Product B ON A.PrdId=B.PrdId 

		INNER JOIN Location C ON A.LcnId=C.LcnId
		INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
		INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
		WHERE B.CmpId=@CmpId AND
		(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
		A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
		(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
		E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)))) F ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 	
		INNER JOIN 
		(SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,
		CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END AS BaseQty,
		B.PrdUnitId,0 AS PrdOnUnit,
		ISNULL(CASE B.PrdUnitId WHEN 2 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
		WHEN 3 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnKg,
		ISNULL(CASE B.PrdUnitId WHEN 4 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
		WHEN 5 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnLitre,
		(CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)* G.SellingRate as SumValue
		FROM ProductBatchLocation A 
		INNER JOIN Product B ON A.PrdId=B.PrdId  
		INNER JOIN Location C ON A.LcnId=C.LcnId
		INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
		INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
		INNER JOIN DefaultPriceHistory G ON A.PrdId=G.PrdId AND G.CurrentDefault=1 AND A.PrdBatId=G.PrdbatId

		WHERE B.CmpId=@CmpId AND
		(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
		A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
		(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
		E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))) GROUP BY 
		A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,B.PrdUnitId,B.PrdWgt,G.SellingRate) F ON D.PrdId=F.PrdId 
		INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
		WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
		ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
		AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR
		C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
		(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
		G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	   GROUP BY G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
		/*F.PrdId,F.PrdCCode,F.PrdName,*/F.LcnId,F.LcnName,F.SystemStockType,F.UserStockType,PrdUnitId
END
ELSE
BEGIN
	INSERT INTO #RPTCURRENTSTOCKAN
	SELECT DISTINCT G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
	F.PrdId,F.PrdCCode,F.PrdName,F.LcnId,F.LcnName,F.SystemStockType,F.UserStockType,BaseQty,PrdUnitId,PrdOnUnit,PrdOnKg,
	PrdOnLitre,SumValue
		FROM ProductCategoryValue C
		INNER JOIN(Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
				A.Prdid from Product A
		INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
			      (A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
			      A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		INNER JOIN 
	              (SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,0 AS BaseQty,
	              B.PrdUnitId,0 AS PrdOnUnit,0 AS PrdOnKg,0 AS PrdOnLitre,0 as SumValue
	              FROM ProductBatchLocation A 
	    INNER JOIN Product B ON A.PrdId=B.PrdId 

		INNER JOIN Location C ON A.LcnId=C.LcnId
		INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
		INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
		WHERE B.CmpId=@CmpId AND
		(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
		A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
		(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
		E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)))) F ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 	
		INNER JOIN 
		(SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,
		CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END AS BaseQty,
		B.PrdUnitId,0 AS PrdOnUnit,
		ISNULL(CASE B.PrdUnitId WHEN 2 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
		WHEN 3 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnKg,
		ISNULL(CASE B.PrdUnitId WHEN 4 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
		WHEN 5 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnLitre,
		(CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)* G.SellingRate as SumValue
		FROM ProductBatchLocation A 
		INNER JOIN Product B ON A.PrdId=B.PrdId  
		INNER JOIN Location C ON A.LcnId=C.LcnId
		INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
		INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
		INNER JOIN DefaultPriceHistory G ON A.PrdId=G.PrdId AND G.CurrentDefault=1 AND A.PrdBatId=G.PrdbatId

		WHERE B.CmpId=@CmpId AND
		(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
		A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
		(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
		E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))) GROUP BY 
		A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,B.PrdUnitId,B.PrdWgt,G.SellingRate) F ON D.PrdId=F.PrdId 
		INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
		WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
		ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
		AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR
		C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
		(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
		G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))

END

--      Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId	
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RPTCURRENTSTOCKAN
--	 Till Here

IF @SupZeroStock=1
	BEGIN 
		SELECT  * FROM #RPTCURRENTSTOCKAN WHERE [Quantity Packs]<>0 
    END
	ELSE
		SELECT * FROM #RPTCURRENTSTOCKAN 

    END
GO

--SRF-Nanda-218-004

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RptProductPurchase]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RptProductPurchase]
GO
------  exec [Proc_RptProductPurchase] 24,1,0,'site',0,0,1

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

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @CmpInvNo=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

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
		INSERT INTO #RptProductPurchase(CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,PrdId,PrdDCode,PrdName,
										InvBaseQty,PrdGrossAmount,CmpInvNo)
		SELECT DISTINCT CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate, PrdId,PrdDCode,PrdName,
			dbo.Fn_ConvertCurrency(InvBaseQty,@Pi_CurrencyId) as InvBaseQty  ,
			dbo.Fn_ConvertCurrency(PrdGrossAmount,@Pi_CurrencyId) as PrdGrossAmount,CmpInvNo
		FROM (	SELECT  A.CmpId,CmpName,A.PurRcptId,PurRcptRefNo,InvDate,B.PrdId,PrdDCode,PrdName,
						SUM(B.InvBaseQty) AS InvBaseQty  , SUM(B.PrdGrossAmount) AS PrdGrossAmount,0 PrdSlNo,CmpInvNo 
				FROM 
							PurchaseReceipt A,PurchaseReceiptProduct B,Product C,Company D
				Where	
							A.PurRcptId = B.PurRcptId    AND B.PrdId =  C.PrdId	
							AND D.CmpId = A.CmPId
				AND ( A.CmpId = (CASE @CmpId WHEN 0 THEN A.CmpId  ELSE 0 END) OR
					A.CmpId  IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND
				( A.PurRcptId = (CASE @CmpInvNo WHEN 0 THEN A.PurRcptId ELSE 0 END) OR
					A.PurRcptId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId)))
		 		AND
				( INVDATE BETWEEN @FromDate AND @ToDate)  	
				AND (B.PrdId <> 0)
	
			GROUP BY  A.CmpId,CmpName,A.PurRcptId,PurRcptRefNo,InvDate,B.PrdId,PrdDCode,PrdName,CmpInvNo
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

--SRF-Nanda-218-005

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptSalesReturn]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptSalesReturn]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_RptSalesReturn 9,2,0,'PRL',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptSalesReturn]
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
/*********************************
* PROCEDURE: Proc_RptSalesReturn
* PURPOSE: Sales Return Report
* NOTES:
* CREATED: Boopathy.P	30-07-2007
* MODIFIED: Aarthi	09-09-2009
* DESCRIPTION: Added Salesman Name and Route Name fields
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @sSql		AS 	nVarChar(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	--Filter Variable
	DECLARE @FromDate	AS 	DateTime
	DECLARE @ToDate		AS	DateTime
	DECLARE @CmpId   	AS	Int
	DECLARE @RtrId   	AS	Int
	DECLARE @SMId   	AS	Int
	DECLARE @RMId   	AS	Int
	DECLARE @SalesRtn  	AS	Int
	DECLARE @ETLFlag 	AS 	INT
	DECLARE @GridFlag 	AS 	INT
	--Till Here
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @RtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @RMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @SMId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @SalesRtn = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,32,@Pi_UsrId))
	--Till Here
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	Create TABLE #RptSalesReturn
		(	
			[SRN Number] 		nVarchar(50),
			[SR Date]			DATETIME,
			[Salesman]			nVarchar(100),
			[Route Name]		nVarchar(100),
			[Retialer Name]		nVarchar(100),
			[Bill No]		    nVarchar(50),
			[Product Code]	    nVarchar(50),
			[Product Description]	nVarchar(100),
			[Stock Type]		nVarchar(50),
			[Quantity (Base Qty)]	INT,
			Uom1	INT,
			Uom2	INT,
			Uom3	INT,
			Uom4	INT,
			SeqId			INT,
			[Gross Amount]		NUMERIC(38,6),
			FieldDesc	        nVarchar(100),
			LineBaseQtyAmt	    NUMERIC(38,6),
			[Net Amount]		NUMERIC(38,6),
			[UsrId]		INT
		)
	SET @TblName = 'RptSalesReturn'
	SET @TblStruct = '	[SRN Number] 		nVarchar(50),
	           			[SR Date]			DATETIME,
					[Salesman]			nVarchar(100),
					[Route Name]		nVarchar(100),
					[Retialer Name]		nVarchar(100),
					[Bill No]		    nVarchar(50),
	           		[Product Code]	    nVarchar(50),
	   				[Product Description]	nVarchar(100),
	           		[Stock Type]		nVarchar(50),
					[Quantity (Base Qty)]	INT,
	          		 SeqId			INT,
	           		[Gross Amount]		NUMERIC(38,6),
					[FieldDesc]	        nVarchar(100),
					[LineBaseQtyAmt]	    NUMERIC(38,6),
					[Net Amount]		NUMERIC(38,6),
					[UsrId]		INT'
	SET @TblFields = '[SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],[Bill No],
				   [Product Code],[Product Description],[Stock Type],
	[Quantity (Base Qty)],SeqId,[Gross Amount],FieldDesc,
	LineBaseQtyAmt,[Net Amount],[UsrId]'
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

	if exists (select * from dbo.sysobjects where id = object_id(N'[UOMIdWise]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [UOMIdWise]
	CREATE TABLE [UOMIdWise] 
	(
		SlNo	INT IDENTITY(1,1),
		UOMId	INT
	) 
	INSERT INTO UOMIdWise(UOMId)
	SELECT UOMId FROM UOMMaster ORDER BY UOMId		


	EXEC Proc_ReportSalesReturnValues @Pi_RptId,@Pi_UsrId

	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		INSERT INTO #RptSalesReturn ([SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],[Bill No],
				   [Product Code],[Product Description],[Stock Type],[Quantity (Base Qty)],SeqId,[Gross Amount],FieldDesc,
			   LineBaseQtyAmt,[Net Amount],[UsrId])
		SELECT [SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],
			   [Bill No],[Product Code],[Product Description],
			   [Stock Type],[Quantity (Base Qty)],SeqId,
			   [Gross Amount],FieldDesc,LineBaseQtyAmt,[Net Amount],CAST(@Pi_UsrId as INT)
			   FROM TempReportSalesReturnValues
		
		WHERE (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
			  RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						
		AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
				 RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							
		AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
				 SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		AND (CmpId=(CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
				 CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			
		AND ([SR Date] Between @FromDate and @ToDate)
		AND (ReturnId=(CASE @SalesRtn WHEN 0 THEN ReturnId ELSE 0 END) OR
				 ReturnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,32,@Pi_UsrId)))
		AND Status = 0
	--AND (ReturnId =@SalesRtn)
		
	IF LEN(@PurDBName) > 0
	BEGIN
		EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
		SET @SSQL = 'INSERT INTO #RptSalesReturn ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +
			
		' WHERE (RtrId = (CASE ' + CAST(@RtrId as INTEGER) + ' WHEN 0 THEN RtrId ELSE 0 END) OR
			      RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',3,' + CAST(@Pi_UsrId as INTEGER) +')))
							
		AND (RMId=(CASE ' + CAST(@RMId as INTEGER) + ' WHEN 0 THEN RMId ELSE 0 END) OR
			      RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',2,' + CAST(@Pi_UsrId as INTEGER) + ')))
							
		AND (SMId=(CASE ' + CAST(@SMId as INTEGER) + ' WHEN 0 THEN SMId ELSE 0 END) OR
			      SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',1,' + CAST(@Pi_UsrId as INTEGER) +')))
		AND (CmpId=(CASE '+ CAST(@CmpId as INTEGER) + ' WHEN 0 THEN CmpId ELSE 0 END) OR
		CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters('+ CAST(@Pi_RptId as INTEGER) +',4,'+ CAST(@Pi_UsrId as INTEGER) +')))
			
		AND ([SR Date] Between ' + @FromDate + ' and  ' + @ToDate + ')
		AND (ReturnId=(CASE ''@SalesRtn'' WHEN 0 THEN ReturnId ELSE 0 END) OR
			      ReturnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId +',32,' + @Pi_UsrId +')))'
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', [SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],
	       [Bill No],[Product Code],[Product Description],
	       [Stock Type],[Quantity (Base Qty)],SeqId,
	       [Gross Amount],FieldDesc,LineBaseQtyAmt,[Net Amount],UsrId FROM #RptSalesReturn'
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
			SET @SSQL = 'INSERT INTO #RptSalesReturn ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSalesReturn
	-- Till Here
	SELECT * FROM #RptSalesReturn
	SELECT @GridFlag=GridFlag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	SELECT @ETLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @ETLFlag=1 OR @GridFlag=1
	BEGIN
		--EXEC Proc_RptSalesReturn 9,1,0,'CoreStocky',0,0,1
		/******************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @Values NUMERIC(38,6)
		DECLARE  @Desc VARCHAR(80)
		DECLARE  @SRNDate DATETIME
		DECLARE  @PrdCode NVARCHAR(100)
		DECLARE  @SrnNo NVARCHAR(100)
		DECLARE  @BillNo NVARCHAR(100)	
		DECLARE  @StkType NVARCHAR(100)
		DECLARE  @SeqId INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @Name NVARCHAR(100)
/*-----------------*/



		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSalesReturn_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [dbo].[RptSalesReturn_Excel]
		DELETE FROM RptExcelHeaders Where RptId=9 AND SlNo>15
		CREATE TABLE RptSalesReturn_Excel (SRNNumber NVARCHAR(100),SRDate DATETIME,SMName NVARCHAR(100),RMName NVARCHAR(100), RtrName NVARCHAR(100),
						BillNo NVARCHAR(100),PrdCode NVARCHAR(100),PrdName NVarchar(500),
				  		StockType NVARCHAR(100),Qty BIGINT,UsrId INT,Uom1 BIGINT,Uom2 BIGINT,Uom3 BIGINT,Uom4 BIGINT)
		SET @iCnt=16
		DECLARE Crosstab_Cur CURSOR FOR
		SELECT DISTINCT(Fielddesc),SeqId FROM #RptSalesReturn ORDER BY SeqId
		OPEN Crosstab_Cur
			   FETCH NEXT FROM Crosstab_Cur INTO @Column,@SeqId
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptSalesReturn_Excel ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
					FETCH NEXT FROM Crosstab_Cur INTO @Column,@SeqId
				END
		CLOSE Crosstab_Cur
		DEALLOCATE Crosstab_Cur		
	/*-------------------------*/

		DELETE FROM RptSalesReturn_Excel
		INSERT INTO RptSalesReturn_Excel (SRNNumber ,SRDate ,SMName,RMName,RtrName ,BillNo ,PrdCode ,PrdName ,StockType ,Qty  ,UsrId,Uom1,Uom2,Uom3,Uom4)
		SELECT DISTINCT A.[SRN Number],A.[SR Date],[Salesman],[Route Name],A.[Retialer Name],A.[Bill No], A.[Product Code],A.[Product Description],A.[Stock Type],SUM(DISTINCT A.[Quantity (Base Qty)]),@Pi_UsrId,
		0 AS Uom1,0 AS Uom2,0 AS Uom3,0 AS Uom4
		FROM #RptSalesReturn A, View_ProdUOMDetails B WHERE a.[Product Code]=b.PrdDcode
		GROUP BY A.[SRN Number],A.[SR Date],A.[Salesman],A.[Route Name],A.[Retialer Name],A.[Bill No], A.[Product Code],A.[Product Description],A.[Stock Type]--,ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,ConversionFactor1
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT  [SRN Number],[SR Date],[Product Code],[Bill No],[Stock Type],FieldDesc,LineBaseQtyAmt FROM #RptSalesReturn
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @SrnNo,@SRNDate,@PrdCode,@BillNo,@StkType,@Desc,@Values
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptSalesReturn_Excel SET ['+ @Desc +']= '+ CAST(ISNULL(@Values,0) AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE SRNNumber='''+ CAST(@SrnNo AS VARCHAR(1000)) + ''' AND SRDate=''' + CAST(@SRNDate AS VARCHAR(1000)) + '''
					AND PrdCode=''' + CAST(@PrdCode AS VARCHAR(1000))+''' AND  BillNo=''' + CAST(@BillNo As VARCHAR(1000)) + ''' AND StockType='''+ CAST(@StkType AS VARCHAR(100))+ ''' AND UsrId=' + CAST(@Pi_UsrId AS VARCHAR(10))+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @SrnNo,@SRNDate,@PrdCode,@BillNo,@StkType,@Desc,@Values
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptSalesReturn_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptSalesReturn_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/******************************************************************************************************/
	END
	IF @GridFlag=1
	BEGIN
		SELECT DISTINCT
			SRNNumber,SRDate,SMName,RMName,RtrName,BillNo,PrdCode,PrdName,StockType,Qty,UsrId,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Qty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(Qty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Qty AS INT)-((CAST(Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
				(CAST(Qty AS INT)-((CAST(Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
			CASE
				WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN
				Case When
					CAST(Qty AS INT)-(((CAST(Qty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(Qty AS INT)-((CAST(Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
					CAST(Qty AS INT)-(((CAST(Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(Qty AS INT)-((CAST(Qty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Qty AS INT)-(CAST(Qty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
					ELSE
						CASE
							WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
								Case
									When CAST(Sum(Qty) AS INT)>=Isnull(ConverisonFactor2,0) Then
										CAST(Sum(Qty) AS INT)%nullif(ConverisonFactor2,0)
									Else CAST(Sum(Qty) AS INT) End
							WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
								Case
									When CAST(Sum(Qty) AS INT)>=Isnull(ConverisonFactor3,0) Then
										CAST(Sum(Qty) AS INT)%nullif(ConverisonFactor3,0)
									Else CAST(Sum(Qty) AS INT) End			
						ELSE CAST(Sum(Qty) AS INT) END
				END as Uom4
						--,[Gross Amount],[Spl. Disc],[Sch Disc],[DB Disc],[CD Disc],[Tax Amt],[Net Amount]
				INTO #TEMP1234
			FROM RptSalesReturn_Excel A, View_ProdUOMDetails B WHERE PrdCode=b.PrdDcode AND UsrId  = @Pi_UsrId
			GROUP BY ConverisonFactor3,ConverisonFactor4,ConverisonFactor2,ConversionFactor1,
					 SRNNumber,SRDate,RtrName,BillNo,PrdCode,PrdName,StockType,Qty,UsrId,SMName,RMName
						--,[Gross Amount],[Spl. Disc],[Sch Disc],[DB Disc],[CD Disc],[Tax Amt],[Net Amount]
		UPDATE RptSalesReturn_Excel SET Uom1 = b.Uom1 , Uom2 = b.Uom2 , uom3 = b.uom3 , uom4 = b.uom4
		FROM RptSalesReturn_Excel a ,#TEMP1234 B
		WHERE a.SRNNumber = b.SRNNumber AND a.BillNo = b.BillNo AND a.PrdCode = B.PrdCode
	---- Added on 25-Jun-2009
		SELECT * INTO #RptSalesReturnGrid
		FROM RptSalesReturn_Excel A
		DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
		INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,c15,C16,c17,C18,C19,C20,C21,Rptid,Usrid)
		SELECT SRNNumber,SRDate,SMName,RMName,RtrName,BillNo,PrdCode,PrdName,StockType,Qty,Uom1,Uom2,Uom3,Uom4,[Gross Amount],[Spl. Disc],[Sch Disc],[DB Disc],[CD Disc],[Tax Amt],[Net Amount],@Pi_RptId,@Pi_UsrId
		FROM #RptSalesReturnGrid
		--- End here on 25-Jun-2009
		INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
		VALUES(9,@iCnt,'Uom1','Case',1,1)
		SET @iCnt=@iCnt+1
		INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
		VALUES(9,@iCnt,'Uom2','Box',1,1)
		SET @iCnt=@iCnt+1
		INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
		VALUES(9,@iCnt,'Uom3','Strips',1,1)
		SET @iCnt=@iCnt+1
		INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
		VALUES(9,@iCnt,'Uom3','Piece',1,1)
		--Till Here
	END
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-218-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptStockandSalesVolumeHierarchy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptStockandSalesVolumeHierarchy]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_RptStockandSalesVolumeHierarchy 219,2,0,'HK4',0,0,1

CREATE  PROCEDURE [dbo].[Proc_RptStockandSalesVolumeHierarchy]  
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
	DECLARE @LevelId AS INT  
	DECLARE @CmpPrdCtgId AS INT  
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

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  

	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  

	SET @CmpPrdCtgId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))  

	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))  
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  

	SET @IncOffStk =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,202,@Pi_UsrId))
	SET @StockValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))  
	SET @SupZeroStock =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))  

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  

	SELECT @LevelId=SUBSTRING(LevelName,6,LEN(LevelName)) FROM ProductCategoryLevel WHERE CmpPrdCtgId=@CmpPrdCtgId

	IF @IncOffStk=1  
	BEGIN  
		Exec Proc_GetStockNSalesDetailsWithOffer @FromDate,@ToDate,@Pi_UsrId  
	END  
	ELSE  
	BEGIN  
		Exec Proc_GetStockNSalesDetails @FromDate,@ToDate,@Pi_UsrId  
	END  

	CREATE TABLE #RptStockandSalesVolume  
	(  
		PrdCtgValMainId		INT,
		PrdCtgValLinkCode	NVARCHAR(200),  
		PrdId				INT,  
		PrdDCode			NVARCHAR(200),  
		PrdName				NVARCHAR(200),  
		PrdBatId			INT,  
		PrdBatCode			NVARCHAR(50),  
		CmpId				INT,  
		CmpName				NVARCHAR(50),  
		LcnId				INT,  
		LcnName				NVARCHAR(50),   
		OpeningStock		NUMERIC(38,0),    
		Purchase			NUMERIC (38,0),  
		Sales				NUMERIC (38,0),  
		AdjustmentIn		NUMERIC (38,0),  
		AdjustmentOut		NUMERIC (38,0),  
		PurchaseReturn		NUMERIC (38,0),  
		SalesReturn			NUMERIC (38,0),    
		ClosingStock		NUMERIC (38,0),  		
		ClosingStkValue		NUMERIC (38,6),
		PrdWeight			NUMERIC (38,6)
	)  

	CREATE TABLE #RptStockandSalesVolumeHierarchy  
	(  
		PrdCtgValMainId			INT,  
		PrdCtgValCode			NVARCHAR(200),  
		PrdCtgValName			NVARCHAR(200),  
		CmpId					INT,  
		CmpName					NVARCHAR(50),  
		LcnId					INT,  
		LcnName					NVARCHAR(50),   
		OpeningStock			NUMERIC(38,0),    
		Purchase				NUMERIC (38,0),  
		Sales					NUMERIC (38,0),  
		AdjustmentIn			NUMERIC (38,0),  
		AdjustmentOut			NUMERIC (38,0),  
		PurchaseReturn			NUMERIC (38,0),  
		SalesReturn				NUMERIC (38,0),    
		ClosingStock			NUMERIC (38,0),  
		ClosingStkValue			NUMERIC (38,6),
		PrdWeight				NUMERIC (38,6),
		PrdCtgValLinkCode		NVARCHAR(100)  
	)  

	SELECT * INTO #RptStockandSalesVolume1 FROM #RptStockandSalesVolume  

	SET @TblName = 'RptStockandSalesVolume'  
	SET @TblStruct = 'PrdId    INT,  
					  PrdDCode			NVARCHAR(200),  
					  PrdName			NVARCHAR(200),  
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
					  ClosingStkValue	NUMERIC (38,6),
					  PrdWeight	NUMERIC (38,6)'  
	SET @TblFields = 'PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
   					  LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,  
					  PurchaseReturn,SalesReturn,ClosingStock,ClosingStkValue,PrdWeight'  
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
		INSERT INTO #RptStockandSalesVolume1 (PrdCtgValMainId,PrdCtgValLinkCode,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
		LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,
		ClosingStock,ClosingStkValue,PrdWeight)
		SELECT DISTINCT PCV.PrdCtgValMainId,PCV.PrdCtgValLinkCode,T.PrdId,T.PrdDcode,T.PrdName,PrdBatId,PrdBatCode,T.CmpId,CmpName,LcnId,LcnName,  
		Opening,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,Closing,
		dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN CloSelRte WHEN 2 THEN CloPurRte WHEN 3 THEN CloMRPRte END,@Pi_CurrencyId),0			
		FROM TempRptStockNSales T INNER JOIN COmpany C ON C.CmpId=T.CmpId 
		INNER JOIN Product P ON P.PrdID=T.PrdId
		INNER JOIN ProductCategoryValue PCV ON PCV.PrdCtgValMainID=P.PrdCtgValMainID
		WHERE (T.CmpId = (CASE @CmpId WHEN 0 THEN T.CmpId ELSE 0 END) OR  
		T.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )  
		AND (LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
			LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) 									
		AND UserId=@Pi_UsrId  

		--->Added By Nanda on 25/02/2011
		UPDATE Rpt SET Rpt.PrdWeight=P.PrdWgt*(CASE P.PrdUnitId WHEN 2 THEN Rpt.ClosingStock/1000000 ELSE Rpt.ClosingStock/1000 END)
		FROM Product P,#RptStockandSalesVolume1 Rpt WHERE P.PrdId=Rpt.PrdId AND P.PrdUnitId IN (2,3)
		--->Till Here
		
		IF @SupZeroStock=0
		BEGIN
			INSERT INTO #RptStockandSalesVolumeHierarchy(PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,CmpId,CmpName,LcnId,  
			LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,
			PurchaseReturn,SalesReturn,ClosingStock,ClosingStkValue,PrdWeight,PrdCtgValLinkCode)  
			SELECT PCV.PrdCtgValMainId,PCV.PrdCtgValCode,PCV.PrdCtgValName,P.CmpId,CmpName,LcnId,LcnName,  
			SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase ,SUM(Sales) AS Sales,  
			SUM(AdjustmentIn) AS AdjustmentIN,SUM(AdjustmentOut) AS AdjustmentOut,  
			SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
			SUM(ClosingStock) AS ClosingStock,SUM(ClosingStkValue),SUM(PrdWeight),LEFT(PCV.PrdCtgValLinkCode,@LevelId*5)
			FROM #RptStockandSalesVolume1 Rpt,Product P,ProductCategoryValue PCV  
			WHERE Rpt.PrdId=P.PrdId AND PCV.PrdCtgValMainId=P.PrdCtgValMainId 			
			GROUP BY PCV.PrdCtgValMainId,PCV.PrdCtgValCode,PCV.PrdCtgValName,P.CmpId,CmpName,LcnId,LcnName,PCV.PrdCtgValLinkCode  
		END
		ELSE
		BEGIN
			INSERT INTO #RptStockandSalesVolumeHierarchy(PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,CmpId,CmpName,LcnId,  
			LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,
			PurchaseReturn,SalesReturn,ClosingStock,ClosingStkValue,PrdWeight,PrdCtgValLinkCode)  
			SELECT PCV.PrdCtgValMainId,PCV.PrdCtgValCode,PCV.PrdCtgValName,P.CmpId,CmpName,LcnId,LcnName,  
			SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase ,SUM(Sales) AS Sales,  
			SUM(AdjustmentIn) AS AdjustmentIN,SUM(AdjustmentOut) AS AdjustmentOut,  
			SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
			SUM(ClosingStock) AS ClosingStock,SUM(ClosingStkValue),SUM(PrdWeight),LEFT(PCV.PrdCtgValLinkCode,@LevelId*5)
			FROM #RptStockandSalesVolume1 Rpt,Product P,ProductCategoryValue PCV  
			WHERE Rpt.PrdId=P.PrdId AND PCV.PrdCtgValMainId=P.PrdCtgValMainId AND Rpt.ClosingStock>0			
			GROUP BY PCV.PrdCtgValMainId,PCV.PrdCtgValCode,PCV.PrdCtgValName,P.CmpId,CmpName,LcnId,LcnName,PCV.PrdCtgValLinkCode  
		END

		UPDATE Rpt SET Rpt.PrdCtgValMainId=PCV.PrdCtgValMainId,Rpt.PrdCtgValCode=PCV.PrdCtgValCode,Rpt.PrdCtgValName=PCV.PrdCtgValName
		FROM #RptStockandSalesVolumeHierarchy Rpt,ProductCategoryValue PCV
		WHERE PCV.PrdCtgValLinkCode=Rpt.PrdCtgValLinkCode
		
		SELECT PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,CmpId,CmpName,LcnId,LcnName,PrdCtgValLinkCode,
		SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase,SUM(Sales) AS Sales,SUM(AdjustmentIn) AS AdjustmentIn,
		SUM(AdjustmentOut) AS AdjustmentOut,SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
		SUM(ClosingStock) AS ClosingStock,SUM(ClosingStkValue) AS ClosingStkValue,SUM(PrdWeight) AS PrdWeight
		INTO #RptStockandSalesVolumeHierarchy1
		FROM #RptStockandSalesVolumeHierarchy
		GROUP BY PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,CmpId,CmpName,LcnId,LcnName,PrdCtgValLinkCode

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
	
	SELECT  * FROM #RptStockandSalesVolumeHierarchy1

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		TRUNCATE TABLE	RptStockandSalesVolumeHierarchy_Excel
		INSERT INTO RptStockandSalesVolumeHierarchy_Excel(PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,CmpId,CmpName,LcnId,LcnName,
		OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,ClosingStock,ClosingStkValue,PrdWeight,PrdCtgValLinkCode)
		SELECT PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,CmpId,CmpName,LcnId,LcnName,
		OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,ClosingStock,ClosingStkValue,PrdWeight,PrdCtgValLinkCode FROM #RptStockandSalesVolumeHierarchy1
	END

	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptStockandSalesVolumeHierarchy1   

	RETURN  
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-218-007

DELETE FROM RptExcelHeaders WHERE RptId=219

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,1,'PrdCtgValMainId','PrdCtgValMainId',0,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,2,'PrdCtgValCode','Hierarchy Code',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,3,'PrdCtgValName','Hierarchy Name',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,4,'CmpId','CmpId',0,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,5,'CmpName','CmpName',0,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,6,'LcnId','LcnId',0,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,7,'LcnName','LcnName',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,8,'OpeningStock','Opening Stock',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,9,'Purchase','Purchase',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,10,'Sales','Sales',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,11,'AdjustmentIn','Adjustment In',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,12,'AdjustmentOut','Adjustment Out',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,13,'PurchaseReturn','Purchase Return',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,14,'SalesReturn','Sales Return',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,15,'ClosingStock','Closing Stock',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,16,'ClosingStkValue','Closing Stock Value',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,17,'PrdWeight','Weight In Ton',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(219,18,'PrdCtgValLinkCode','PrdCtgValLinkCode',0,1)

--SRF-Nanda-218-009

DELETE FROM RptExcelHeaders Where RptId = 220
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,1,'RtrCode','Retailer Code',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,2,'RtrName','Retailer Name',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,3,'CmpPrdCtgName','Product Category Level',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,4,'PrdCtgValName','Product Category Value',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,5,'PrdCCode','Product Code',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,6,'PrdName','Product Name',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,7,'BaseQty','Sales Qty',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,8,'SalVolume','Sales Volume',1,1)
GO
INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
Values(220,9,'PrdNetAmount','Sales Value',1,1)
GO
IF NOT EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='RptRtrPrdWiseSales_Excel')
BEGIN
	CREATE TABLE RptRtrPrdWiseSales_Excel
	(
		RtrCode				VARCHAR(100),
		RtrName				VARCHAR(200),
		CmpPrdCtgName		VARCHAR(200),
		PrdCtgValName		VARCHAR(300),
		PrdCCode			VARCHAR(100),
		PrdName				VARCHAR(200),
		BaseQty				NUMERIC(18,0),
		SalVolume			NUMERIC(18,6),
		PrdNetAmount		NUMERIC(18,6)
	)
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_RptRtrPrdWiseSales')
DROP PROCEDURE Proc_RptRtrPrdWiseSales
GO 
--select * from ReportfilterDt where rptid = 90 And selid = 66
--EXEC Proc_RptRtrPrdWiseSales 220,2,0,'ASKO',0,0,1

CREATE    PROCEDURE [dbo].[Proc_RptRtrPrdWiseSales]
/************************************************************
* PROCEDURE	: Proc_RptRtrPrdWiseSales
* PURPOSE	: Retailer and Product Wise Sales Volume
* CREATED BY	: Boopathy.P
* CREATED DATE	: 14/03/2011
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
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
BEGIN
	DECLARE @NewSnapId 		AS	INT
	DECLARE @DBNAME			AS 	nvarchar(50)
	DECLARE @TblName 		AS	nvarchar(500)
	DECLARE @TblStruct 		AS	nVarchar(4000)
	DECLARE @TblFields 		AS	nVarchar(4000)
	DECLARE @SSQL			AS 	VarChar(8000)
	DECLARE @ErrNo	 		AS	INT
	DECLARE @PurDBName		AS	nVarChar(50)
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @RMId			AS	INT
	DECLARE @SMId			AS	INT
	DECLARE @RtrId 			AS 	INT
	DECLARE @CmpId 			AS 	INT
	DECLARE @PrdCatLvlId 	AS 	INT
	DECLARE @PrdCatValId 	AS 	INT
	DECLARE @PrdId 			AS 	INT
	DECLARE @Display		AS 	INT

	CREATE  TABLE #RptRtrPrdWiseSales
		(
			RtrId				INT,
			RtrCode				NVARCHAR(100),
			RtrName				NVARCHAR(200),
			CmpPrdCtgId			INT,
			CmpPrdCtgName		NVARCHAR(200),
			PrdCtgValMainId		INT,
			PrdCtgValCode		NVARCHAR(100),
			PrdCtgValName		NVARCHAR(200),
			PrdId				INT,
			PrdCCode			NVARCHAR(100),
			PrdName				NVARCHAR(200),
			BaseQty				NUMERIC(18,0),
			PrdUnitId			INT,
			PrdOnUnit			NUMERIC(18,0),
			PrdOnKg				NUMERIC(18,6),
			PrdOnLitre			NUMERIC(18,6),
			PrdNetAmount		NUMERIC(18,6),
			DispMode			INT
		)


	SET @SMId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @CmpId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @PrdCatLvlId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @Display = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,260,@Pi_UsrId))

	IF @CmpId=0
	BEGIN
		SELECT @CmpId=CmpId FROM Company WHERE DefaultCompany=1
	END
	

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	
	SET @TblName = 'RptRtrPrdWiseSales'
	
	SET @TblStruct ='		
			RtrId				INT,
			RtrCode				NVARCHAR(100),
			RtrName				NVARCHAR(200),
			CmpPrdCtgId			INT,
			CmpPrdCtgName		NVARCHAR(200),
			PrdCtgValMainId		INT,
			PrdCtgValCode		NVARCHAR(100),
			PrdCtgValName		NVARCHAR(200),
			PrdId				INT,
			PrdCCode			NVARCHAR(100),
			PrdName				NVARCHAR(200),
			PrdUnitId			INT,
			PrdOnUnit			NUMERIC(18,0),
			PrdOnKg				NUMERIC(18,6),
			PrdOnLitre			NUMERIC(18,6),
			PrdNetAmount		NUMERIC(18,6),
			DispMode			INT'					
	
	SET @TblFields = 'RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
			PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode'
			
	IF @Display=2
	BEGIN
		IF (@PrdCatLvlId=0 AND @PrdCatValId=0 AND @PrdId=0) OR 
			(@PrdCatLvlId>0 AND @PrdCatValId=0 AND @PrdId=0) OR
			(@PrdCatLvlId>0 AND @PrdCatValId>0 AND @PrdId=0)
		BEGIN
			INSERT INTO #RptRtrPrdWiseSales (RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
					PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode)
			SELECT RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				   0,'','',PrdUnitId,SUM(PrdOnUnit),SUM(PrdOnKg),SUM(PrdOnLitre),SUM(PrdNetAmount),@Display FROM 
				(
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				UNION
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,-1*F.PrdOnUnit,-1*F.PrdOnKg,-1*F.PrdOnLitre,-1*F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))) A
					GROUP BY RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				    PrdUnitId
		END
		ELSE --IF (@PrdCatLvlId>0 AND @PrdCatValId>0)
		BEGIN
			INSERT INTO #RptRtrPrdWiseSales (RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
					PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode)
			SELECT RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				   PrdId,PrdCCode,Prdname,PrdUnitId,SUM(PrdOnUnit),SUM(PrdOnKg),SUM(PrdOnLitre),SUM(PrdNetAmount),1 FROM 
				(
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE 0 END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				UNION
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,-1*F.PrdOnUnit,-1*F.PrdOnKg,-1*F.PrdOnLitre,-1*F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) ) A
					GROUP BY RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				    PrdId,PrdCCode,Prdname,PrdUnitId
		END
	END
	ELSE
	BEGIN
		INSERT INTO #RptRtrPrdWiseSales (RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
				PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode)
		SELECT RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
			   PrdId,PrdCCode,Prdname,PrdUnitId,SUM(PrdOnUnit),SUM(PrdOnKg),SUM(PrdOnLitre),SUM(PrdNetAmount),@Display FROM 
			(
			SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
			G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
			F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
				FROM ProductCategoryValue C
				INNER JOIN 
					( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
						WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
						ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
						A.Prdid from Product A
				INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
					(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
					 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				INNER JOIN 
						(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
							FROM salesInvoice A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
								D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
						ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
				INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
							FROM salesInvoice A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
								D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
							ON D.PrdId=F.PrdId 
				INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
				AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR					
				C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
				(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
				G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			UNION
			SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
			G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
			F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,-1*F.PrdOnUnit,-1*F.PrdOnKg,-1*F.PrdOnLitre,-1*F.PrdNetAmount 
				FROM ProductCategoryValue C
				INNER JOIN 
					( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
						WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
						ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
						A.Prdid from Product A
				INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
					(A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
					 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				INNER JOIN 
						(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
							FROM ReturnHeader A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
						ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
				INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
							FROM ReturnHeader A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.PrdId = (CASE @PrdId WHEN 0 THEN D.PrdId Else @PrdId END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
							ON D.PrdId=F.PrdId 
				INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
				AND ( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR					
				C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
				(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
				G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) ) A
				GROUP BY RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
			    PrdId,PrdCCode,Prdname,PrdUnitId
	END
	UPDATE #RptRtrPrdWiseSales SET BaseQty=PrdOnUnit
	UPDATE #RptRtrPrdWiseSales SET PrdOnUnit=0 WHERE PrdUnitId>1
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptRtrPrdWiseSales

	DELETE FROM RptRtrPrdWiseSales_Excel
	INSERT INTO RptRtrPrdWiseSales_Excel
	SELECT RtrCode,RtrName,CmpPrdCtgName,PrdCtgValName,PrdCCode,Prdname,BaseQty,
	PrdOnUnit+PrdOnKg+PrdOnLitre,PrdNetAmount FROM #RptRtrPrdWiseSales
	select * from #RptRtrPrdWiseSales 
RETURN
END
GO

--SRF-Nanda-218-010

DELETE FROM ExtractAksoNobal
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (1,'Purchase Order','Proc_AN_PurchaseOrder','PurchaseOrderExtractExcel','Master','Excel Extract',501)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (2,'Purchase Confirmation','Proc_AN_PurchaseConfirmation','PurchaseConfirmationExtractExcel','Master','Excel Extract',502)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (3,'Purchase Return','Proc_AN_PurchaseReturn','PurchaseReturnExtractExcel','Master','Excel Extract',503)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (4,'Sales Details','Proc_AN_SalesDetail','SalesDetailExtractExcel','Master','Excel Extract',504)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (5,'Sales Return','Proc_AN_SalesReturn','SalesReturnExtractExcel','Master','Excel Extract',505)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (6,'Stock Management','Proc_AN_StockManagement','StockManagementExtractExcel','Master','Excel Extract',506)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (7,'Stock Journal','Proc_AN_StockJournal','StockJournalExtractExcel','Master','Excel Extract',507)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (8,'Debit Notes','Proc_AN_DebitNotes','DebitNotesExtractExcel','Master','Excel Extract',508)
GO
INSERT INTO ExtractAksoNobal (SlNo,ExtractFileName,SPName,TblName,TransType,FileName,RptId) 
VALUES (9,'Credit Notes','Proc_AN_CreditNotes','CreditNotesExtractExcel','Master','Excel Extract',509)
GO
----  Purchase Order  
IF  EXISTS (SELECT * FROM sysobjects WHERE  id = OBJECT_ID(N'[PurchaseOrderExtractExcel]') AND type in (N'U'))
DROP TABLE [PurchaseOrderExtractExcel]
GO
CREATE TABLE [PurchaseOrderExtractExcel](
	[DistCode] [nvarchar](150) NULL,
	[DistName] [nvarchar](150) NULL,
	[Transaction] [nvarchar](150) NULL,
	[PODate] [datetime] NULL,
	[PONumber] [nvarchar](150) NULL,
	[ProductCode] [nvarchar](550) NULL,
	[ProductName] [nvarchar](550) NULL,
	[SysGenUomid] [int] NULL,
	[SystemOrderQty] [int] NULL,
	[SystemOrderUOM] [nvarchar](50) NULL,
	[OrdUomId] [int] NULL,
	[FinalORDERQty] [int] NULL,
	[FinalOrderUOM] [nvarchar](50) NULL,
	[FinalOrderQtyBaseUOM] [nvarchar](50) NULL,
	[Volume] [numeric](18, 6) NULL
) ON [PRIMARY]

DELETE  FROM RptAKSOExcelHeaders WHERE Rptid=501
GO
INSERT INTO RptAKSOExcelHeaders VALUES (501,1,'DistCode','Dist Code',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,2,'DistName','Dist Name ',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,3,'Transaction','Transaction Name ',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,4,'PODate','Purchase Order Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,5,'PONumber','Purchase Order No',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,6,'ProductCode','Product Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,7,'ProductName','Product Name',	1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,8,'SysGenUomid','SysGenUomid',0,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,9,'SystemOrderQty','System Order Qty',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,10,'SystemOrderUOM','System Order UOM',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,11,'OrdUomId','OrdUomId',0,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,12,'FinalORDERQty','Final Order Qty',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,13,'FinalOrderUOM','Final Order UOM',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,14,'FinalOrderQtyBaseUOM','Final OrderQty Base UOM ',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (501,15,'Volume','Volume',1,	1)
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_AN_PurchaseOrder]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_AN_PurchaseOrder]
GO
-- EXEC Proc_AN_PurchaseOrder '2010-02-22','2011-03-25'
CREATE PROCEDURE [Proc_AN_PurchaseOrder]
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
SET NoCOunt On
BEGIN
 
	DELETE FROM PurchaseOrderExtractExcel
	INSERT INTO PurchaseOrderExtractExcel (	PONumber,PODate,ProductCode,ProductName,
								SysGenUomid,SystemOrderQty,OrdUomId,FinalORDERQty,Volume)
	
	SELECT DISTINCT 
					A.PurOrderRefNo,A.PurOrderDate,C.PrdCCode,C.PrdName,B.SysGenUomid,
					B.SysGenQty,B.OrdUomId,B.OrdQty,B.OrdQty*PrdWgt
	FROM 
		PurchaseOrderMaster A
			INNER JOIN PurchaseOrderDetails B ON A.PurOrderRefNo=B.PurOrderRefNo
			INNER JOIN Product C ON B.PrdID=C.PrdID
			INNER JOIN Company D ON A.CmpId=D.CmpId
			LEFT OUTER JOIN Supplier E ON E.SpmID=A.SpmID
	WHERE 
			PurOrderDate BETWEEN @Pi_FromDate AND @Pi_ToDate
    
	Update PurchaseOrderExtractExcel SET [Transaction] = 'Purchase Order'
	UPDATE PurchaseOrderExtractExcel SET DistCode=(SELECT DistributorCode FROM Distributor)
	UPDATE PurchaseOrderExtractExcel SET DistName=(SELECT DistributorName FROM Distributor)

	UPDATE PO SET PO.SystemOrderUOM=UO.UOMDescription 
	FROM PurchaseOrderExtractExcel PO INNER JOIN UomMaster UO ON PO.SysGenUomid=UO.UomId

	UPDATE PurchaseOrderExtractExcel SET FinalOrderUOM=UO.UOMDescription 
	FROM PurchaseOrderExtractExcel PO INNER JOIN UomMaster UO ON PO.OrdUomId=UO.UomId

	UPDATE PurchaseOrderExtractExcel SET FinalOrderQtyBaseUOM=UG.ConversionFactor*FinalORDERQty
	FROM PurchaseOrderExtractExcel PO INNER JOIN Product C ON Po.ProductCode=C.PrdCCode
	INNER JOIN UomGroup UG ON C.UomGroupId=UG.UomGroupId AND UG.BaseUom='Y'
END 
GO

----  Purchase Confirmation

DELETE FROM RptAKSOExcelHeaders WHERE Rptid=502
GO
INSERT INTO RptAKSOExcelHeaders VALUES (502,1,'DistCode','Distributor Code',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,2,'DistName','Distributor Name ',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,3,'TransName','Transaction Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,4,'GRNRefNo','GRN Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,5,'GRNInvDate','GRN Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,6,'GRNCmpInvNo','Company Invoice Number',	1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,7,'GRNRcvdDate','Company Invoice Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,8,'GRNPORefNo','Purchase Order Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,9,'SupplierCode','Supplier Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,10,'SupplierName','Supplier Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,11,'TransporterCode','Transporter Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,12,'TransporterName','Transporter Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,13,'LRNo','LRNo',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,14,'LRDate','LRDate',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,15,'GRNGrossAmt','Invoice Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,16,'GRNDiscAmt','Invoice Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,17,'GRNTaxAmt','Invoice tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,18,'GRNSchAmt','Invoice Scheme Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,19,'GRNOtherChargesAmt','Net - Other Charges',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,20,'GRNHandlingChargesAmt','Handling Charges',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,21,'GRNTotDedn','Total Deduction',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,22,'GRNTotAddn','Total Addition',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,23,'GRNRoundOffAmt','Round Off Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,24,'GRNNetAmt','Invoice Net Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,25,'GRNNetPayableAmt','Net Payable Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,26,'GRNDiffAmt','Difference Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,27,'PrdSchemeFlag','Scheme Flag',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,28,'PrdCmpSchCode','Company Scheme Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,29,'PrdLcnCode','Location Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,30,'PrdLcnName','Location Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,31,'PrdCode','Product Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,32,'PrdName','Product Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,33,'PrdBatCode','Batch Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,34,'PrdInvQty','Invoice Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,35,'InvQtyVolume','Invoice Quantity Volume',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,36,'PrdRcvdQty','Received Good Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,37,'RecQtyVolume','Received Good Quantity Volume',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,38,'PrdUnSalQty','Unsalable Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,39,'PrdUnSalQtyVolume','Unsalable Quantity Volume',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,40,'PrdShortQty','Shortage Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,41,'PrdShortQtyVolume','Shortage Quantity Volume',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,42,'PrdExcessQty','Excess Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,43,'PrdExcessQtyVolume','Excess Quantity Volume',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,44,'PrdExcessRefusedQty','Excess Refused Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,45,'PrdExcessRefusedQtyVolume','Excess Refused Quantity Volume',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,46,'PrdLSP','LSP',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,47,'PrdGrossAmt','Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,48,'PrdDiscAmt','Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,49,'PrdTaxAmt','Tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,50,'PrdNetRate','Net Rate',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,51,'PrdNetAmt','Net Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,52,'PrdLineBreakUpType','Line Break Up Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,53,'PrdLineLcnCode','Line Location Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,54,'PrdLineLcnName','Line Location Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,55,'PrdLineStockType','Line Stock Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,56,'PrdLineQty','Line Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,57,'PrdLineQtyVolume','Line QuantityVolume',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,58,'PrdId','Prdid',0,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (502,59,'PrdBatId','PrdBatId',0,	1)
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PurchaseConfirmationExtractExcel]') AND type in (N'U'))
DROP TABLE [PurchaseConfirmationExtractExcel]
GO
CREATE TABLE [PurchaseConfirmationExtractExcel](
	[DistCode] [nvarchar](50) NULL,
	[DistName] [nvarchar](200) NULL,
	[TransName] [nvarchar](200) NULL,
	[GRNRefNo] [nvarchar](100) NULL,
	[GRNInvDate] [datetime] NULL,
	[GRNCmpInvNo] [nvarchar](50) NULL,
	[GRNRcvdDate] [datetime] NULL,
	[GRNPORefNo] [nvarchar](50) NULL,
	[SupplierCode] [nvarchar](100) NULL,
	[SupplierName] [nvarchar](200) NULL,
	[TransporterCode] [nvarchar](100) NULL,
	[TransporterName] [nvarchar](200) NULL,
	[LRNo] [nvarchar](100) NULL,
	[LRDate] [datetime] NULL,
	[GRNGrossAmt] [numeric](38, 6) NULL,
	[GRNDiscAmt] [numeric](38, 6) NULL,
	[GRNTaxAmt] [numeric](38, 6) NULL,
	[GRNSchAmt] [numeric](38, 6) NULL,
	[GRNOtherChargesAmt] [numeric](38, 6) NULL,
	[GRNHandlingChargesAmt] [numeric](38, 6) NULL,
	[GRNTotDedn] [numeric](38, 6) NULL,
	[GRNTotAddn] [numeric](38, 6) NULL,
	[GRNRoundOffAmt] [numeric](38, 6) NULL,
	[GRNNetAmt] [numeric](38, 6) NULL,
	[GRNNetPayableAmt] [numeric](38, 6) NULL,
	[GRNDiffAmt] [numeric](38, 6) NULL,
	[PrdSchemeFlag] [nvarchar](10) NULL,
	[PrdCmpSchCode] [nvarchar](100) NULL,
	[PrdLcnCode] [nvarchar](100) NULL,
	[PrdLcnName] [nvarchar](200) NULL,
	[PrdCode] [nvarchar](550) NULL,
	[PrdName] [nvarchar](550) NULL,
	[PrdBatCode] [nvarchar](200) NULL,
	[PrdInvQty] [int] NULL,
	[InvQtyVolume] [numeric](38, 6) NULL,
	[PrdRcvdQty] [int] NULL,
	[RecQtyVolume] [numeric](38, 6) NULL,
	[PrdUnSalQty] [int] NULL,
	[PrdUnSalQtyVolume] [numeric](38, 6) NULL,
	[PrdShortQty] [int] NULL,
	[PrdShortQtyVolume] [numeric](38, 6) NULL,
	[PrdExcessQty] [int] NULL,
	[PrdExcessQtyVolume]  [numeric](38, 6) NULL,
	[PrdExcessRefusedQty] [int] NULL,
	[PrdExcessRefusedQtyVolume][numeric](38, 6) NULL,
	[PrdLSP] [numeric](38, 6) NULL,
	[PrdGrossAmt] [numeric](38, 6) NULL,
	[PrdDiscAmt] [numeric](38, 6) NULL,
	[PrdTaxAmt] [numeric](38, 6) NULL,
	[PrdNetRate] [numeric](38, 6) NULL,
	[PrdNetAmt] [numeric](38, 6) NULL,
	[PrdLineBreakUpType] [nvarchar](100) NULL,
	[PrdLineLcnCode] [nvarchar](100) NULL,
	[PrdLineLcnName] [nvarchar](100) NULL,
	[PrdLineStockType] [nvarchar](100) NULL,
	[PrdLineQty] [int] NULL,
	[PrdLineQtyVolume] [numeric](38, 6) NULL,
	[PrdId] [INT],
	[PrdBatId] [INT] 
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_AN_PurchaseConfirmation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_AN_PurchaseConfirmation]
GO
---   Proc_AN_PurchaseConfirmation  '2011-03-01','2011-03-31'
---   select * from PurchaseConfirmationExtractExcel
CREATE   PROCEDURE [Proc_AN_PurchaseConfirmation]
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
BEGIN
	DECLARE @DistNm	As nVarchar(200)
    DECLARE @DistCode AS Nvarchar(100)
	SELECT @DistCode = DistributorCode FROM Distributor	
	SELECT @DistNm = Distributorname FROM Distributor	
    DELETE FROM PurchaseConfirmationExtractExcel
	INSERT INTO PurchaseConfirmationExtractExcel
	(
		DistCode				,
        DistName                ,
		TransName				,
		GRNRefNo				,
		GRNInvDate				,
		GRNCmpInvNo				,
		GRNRcvdDate				,
		GRNPORefNo				,
		SupplierCode			,
		SupplierName			,
		TransporterCode			,
		TransporterName			,
		LRNo					,
		LRDate					,
		GRNGrossAmt				,
		GRNDiscAmt				,
		GRNTaxAmt				,
		GRNSchAmt				,
		GRNOtherChargesAmt		,
		GRNHandlingChargesAmt	,
		GRNTotDedn				,
		GRNTotAddn				,
		GRNRoundOffAmt			,
		GRNNetAmt				,
		GRNNetPayableAmt		,
		GRNDiffAmt				,
		PrdSchemeFlag			,
		PrdCmpSchCode			,	
		PrdLcnCode				,
        PrdLcnName				,
		PrdCode					,
        PrdName					,
		PrdBatCode				,
		PrdInvQty				,
		PrdRcvdQty				,
		PrdUnSalQty				,
		PrdShortQty				,
		PrdExcessQty			,
		PrdExcessRefusedQty		,
		PrdLSP					,
		PrdGrossAmt				,
		PrdDiscAmt				,
		PrdTaxAmt				,
		PrdNetRate				,
		PrdNetAmt				,
		PrdLineBreakUpType		,
		PrdLineLcnCode			,
        PrdLineLcnName			,
		PrdLineStockType		,
		PrdLineQty				,
		PrdId					,
		PrdbatId						
	)
	SELECT
		@DistCode ,@DistNm,'Purchase Confirmation',
        PR.PurRcptRefNo AS GrnRefNo,
        PR.InvDate as GrnInvdate,
		PR.CmpInvNo AS GrnCmpinvno ,
		PR.GoodsRcvdDate AS GrnRcvdDate,
		PR.PurOrderRefNo,S.SpmCode,S.SpmName,T.TransporterCode,T.TransporterName,PR.LRNo,PR.LRDate,
		PR.GrossAmount,PR.Discount,PR.TaxAmount,PR.LessScheme,PR.OtherCharges,PR.HandlingCharges,PR.TotalDeduction,PR.TotalAddition,0,
		PR.NetAmount,PR.NetPayable,PR.DifferenceAmount,'No','',L.LcnCode,L.LcnName,
		P.PrdCCode AS ProdCode ,P.Prdname AS Prdname,PB.CmpBatCode AS PrdBatCde ,
		PRP.InvBaseQty,PRP.RcvdGoodBaseQty,UnSalBaseQty,ShrtBaseQty,
		(CASE PRP.RefuseSale WHEN 0 THEN ExsBaseQty ELSE 0 END),
		(CASE PRP.RefuseSale WHEN 1 THEN ExsBaseQty ELSE 0 END),
		PRP.PrdLSP,PRP.PrdGrossAmount,PRP.PrdDiscount,PRP.PrdTaxAmount,PRP.PrdUnitNetRate,PRP.PrdNetAmount,
		ISNULL((CASE PRB.BreakUpType WHEN 1 THEN 'UnSaleable' WHEN 2 THEN 'Excess' END),''),
		ISNULL(PRBL.LcnCode,''),ISNULL(PRBL.LcnName,''),
		ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),
		ISNULL(PRB.BaseQty,0),P.PrdId,PB.PrdBatId			
	FROM
		PurchaseReceipt PR
		INNER JOIN PurchaseReceiptProduct PRP ON PR.PurRcptId = PRP.PurRcptId AND PR.Status = 1  
		INNER JOIN Product P ON P.PrdId = PRP.PrdId AND Pr.InvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		INNER JOIN ProductBatch PB ON PB.PrdBatId=PRP.PrdBatId AND P.PrdId = PB.PrdId
		INNER JOIN Transporter T ON PR.TransporterId=T.TransporterId
		INNER JOIN Supplier S ON PR.SpmId=S.SpmId
		INNER JOIN Location L ON L.LcnId=PR.LcnId AND PR.lcnid=L.lcnid
		LEFT OUTER JOIN PurchaseReceiptBreakUp PRB ON PRP.PurRcptId=PRB.PurRcptId AND PRP.PrdSlNo=PRB.PrdSlNo
		LEFT OUTER JOIN StockType ST ON PRB.StockTypeId=ST.StockTypeId
		LEFT OUTER JOIN Location PRBL ON PRBL.LcnId=ST.LcnId
	UNION ALL
	SELECT
		@DistCode ,@DistNm,'Purchase Confirmation',
        PR.PurRcptRefNo AS GrnRefNo,
        PR.InvDate as GrnInvdate,
		PR.CmpInvNo AS GrnCmpinvno ,
		PR.GoodsRcvdDate AS GrnRcvdDate,
        PR.PurOrderRefNo,S.SpmCode,S.SpmName,T.TransporterCode,T.TransporterName,PR.LRNo,PR.LRDate,
		PR.GrossAmount,PR.Discount,PR.TaxAmount,PR.LessScheme,PR.OtherCharges,PR.HandlingCharges,PR.TotalDeduction,PR.TotalAddition,0,
		PR.NetAmount,PR.NetPayable,PR.DifferenceAmount,(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),
		ISNULL(Sch.CmpSchCode,Sch.SchCode),L.LcnCode,L.LcnName,
		P.PrdCCode AS ProdCode ,P.Prdname AS Prdname,PB.CmpBatCode AS PrdBatCde ,
		0,PRP.Quantity,0,0,0,0,
		PRP.RateForClaim,PRP.Amount,0,0,PRP.RateForClaim,PRP.Amount,
		'','','',ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),0,
		P.PrdId,PB.PrdBatId	
	FROM
		PurchaseReceipt PR
		INNER JOIN PurchaseReceiptClaimScheme PRP ON PR.PurRcptId = PRP.PurRcptId AND PR.Status = 1 
		AND PRP.TypeId=2 AND Pr.InvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		INNER JOIN Product P ON P.PrdId = PRP.PrdId
		INNER JOIN ProductBatch PB ON PB.PrdBatId=PRP.PrdBatId AND P.PrdId = PB.PrdId
		INNER JOIN Transporter T ON PR.TransporterId=T.TransporterId
		INNER JOIN Supplier S ON PR.SpmId=S.SpmId
		INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
		INNER JOIN Location L ON L.LcnId=ST.LcnId AND PR.lcnid=L.lcnid
		LEFT OUTER JOIN SchemeMaster Sch ON Sch.SchId=RefId
	UNION ALL
	SELECT
		@DistCode ,@DistNm,'Purchase Confirmation',
        PR.PurRcptRefNo AS GrnRefNo,
        PR.InvDate as GrnInvdate,
		PR.CmpInvNo AS GrnCmpinvno ,
		PR.GoodsRcvdDate AS GrnRcvdDate,
		PR.PurOrderRefNo,S.SpmCode,S.SpmName,T.TransporterCode,T.TransporterName,PR.LRNo,PR.LRDate,
		PR.GrossAmount,PR.Discount,PR.TaxAmount,PR.LessScheme,PR.OtherCharges,PR.HandlingCharges,PR.TotalDeduction,PR.TotalAddition,0,
		PR.NetAmount,PR.NetPayable,PR.DifferenceAmount,(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),
		ISNULL(CSD.RefCode,''),L.LcnCode,L.LcnName,
		P.PrdCCode AS ProdCode ,P.Prdname AS Prdname,PB.CmpBatCode AS PrdBatCde ,
		0,PRP.Quantity,0,0,0,0,
		PRP.RateForClaim,PRP.Amount,0,0,PRP.RateForClaim,PRP.Amount,
		'','','',ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),0,
		P.PrdId,PB.PrdBatId						
	FROM
		PurchaseReceipt PR
		INNER JOIN PurchaseReceiptClaimScheme PRP ON PR.PurRcptId = PRP.PurRcptId AND PR.Status = 1 
		AND PRP.TypeId=1
        AND Pr.InvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		INNER JOIN Product P ON P.PrdId = PRP.PrdId
		INNER JOIN ProductBatch PB ON PB.PrdBatId=PRP.PrdBatId AND P.PrdId = PB.PrdId
		INNER JOIN Transporter T ON PR.TransporterId=T.TransporterId
		INNER JOIN Supplier S ON PR.SpmId=S.SpmId
		INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
		INNER JOIN Location L ON L.LcnId=ST.LcnId AND PR.lcnid=L.lcnid
		INNER JOIN ClaimSheetHd CSH ON CSH.ClmId=PRP.RefId
		INNER JOIN ClaimSheetDetail CSD ON CSH.ClmId=CSD.ClmId AND PRP.SlNo=CSD.SlNo
	
	Update  PurchaseConfirmationExtractExcel Set  InvQtyVolume = 0.00,RecQtyVolume = 0.00,
			PrdUnSalQtyVolume = 0.00,PrdShortQtyVolume = 0.00,PrdExcessQtyVolume = 0.00,
			PrdExcessRefusedQtyVolume = 0.00,PrdLineQtyVolume = 0.00 
	
    Update  PurchaseConfirmationExtractExcel SET InvQtyVolume = PrdInvQty * PrdWgt,
		    RecQtyVolume = PrdRcvdQty * PrdWgt,PrdUnSalQtyVolume = PrdUnSalQty * PrdWgt,
			PrdShortQtyVolume = PrdShortQty * PrdWgt,PrdExcessQtyVolume = PrdExcessQty * PrdWgt,
			PrdExcessRefusedQtyVolume = PrdExcessRefusedQty * PrdWgt,
			PrdLineQtyVolume = PrdLineQty * PrdWgt
	From PurchaseConfirmationExtractExcel a,Product b,ProductBatch c
	Where A.PrdId = B.Prdid and A.PrdId = C.PrdId and A.PrdBatId = C.PrdBatId 
END
GO
DELETE FROM RptAKSOExcelHeaders WHERE Rptid=503
INSERT INTO RptAKSOExcelHeaders VALUES (503,1,'DistCode','Distributor Code',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,2,'DistName','Distributor Name ',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,3,'TransName','Transaction Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,4,'PRNRefNo','Return Reference Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,5,'PRNDate','Purchase Return Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,6,'SpmCode','Supplier Code',	1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,7,'SpmName','Supplier Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,8,'PRNMode','Purchase Return Mode',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,9,'PRNType','Purchase Return Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,10,'GRNNo','GRN Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,11,'GRNDate','GRN Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,12,'CmpInvNo','Company Invoice Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,13,'InvRcpdate','Company Invoice Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,14,'PRNGrossAmt','Invoice Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,15,'PRNDiscAmt','Invoice Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,16,'PRNSchAmt','Invoice Scheme Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,17,'PRNOtherChargesAmt','Net - Other Charges',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,18,'PRNTaxAmt','Invoice Tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,19,'PRNTotDedn','Total Deduction',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,20,'PRNTotAddn','Total Addition',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,21,'PRNRoundOffAmt','Round Off Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,22,'PRNNetAmt','Invoice Net Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,23,'PrdSchemeFlag','Scheme Flag',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,24,'PrdCmpSchCode','Company Scheme Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,25,'PrdLcnCode','Location Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,26,'PrdLcnName','Location Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,27,'PrdCode','Product Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,28,'PrdName','Product Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,29,'PrdBatCode','Batch Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,30,'PrdSalQty','Salable Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,31,'PrdSalQtyVolume','Salable Quantity Volume',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,32,'PrdUnSalQty','Unsalable Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,33,'PrdUnSalQty','Unsalable Quantity Volume',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,34,'PrdRate','LSP',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,35,'PrdGrossAmt','Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,36,'PrdDiscAmt','Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,37,'PrdTaxAmt','Tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,38,'PrdNetRate','Net Rate',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,39,'PrdNetAmt','Net Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,40,'Reason','Reason',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,41,'PrdLineBreakUpType','Line Breakup Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,42,'PrdLineLcnCode','Line Location Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,43,'PrdLineStockType','Line Stock Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,44,'PrdLineQty','Line Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,45,'PrdLineQtyVolume','Line Quantity Volume',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,46,'Prdid','Prdid',0,1)
INSERT INTO RptAKSOExcelHeaders VALUES (503,47,'PrdBatId','PrdBatId',0,1)
GO
 

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PurchaseReturnExtractExcel]') AND type in (N'U'))
DROP TABLE [PurchaseReturnExtractExcel]
GO
CREATE TABLE [PurchaseReturnExtractExcel](
	[DistCode] [nvarchar](50) NULL,
	[DistName] [nvarchar](200) NULL,
	[TransName] [nvarchar](200) NULL,
	[PRNRefNo] [nvarchar](100) NULL,
	[PRNDate] [datetime] NULL,
	[SpmCode] [nvarchar](100) NULL,
	[SpmName] [nvarchar](250) NULL,
	[PRNMode] [nvarchar](100) NULL,
	[PRNType] [nvarchar](100) NULL,
	[GRNNo] [nvarchar](100) NULL,
	[GRNDate] [datetime] NULL,
	[CmpInvNo] [nvarchar](100) NULL,
	[InvRcpdate] [datetime] NULL,
	[PRNGrossAmt] [numeric](38, 6) NULL,
	[PRNDiscAmt] [numeric](38, 6) NULL,
	[PRNSchAmt] [numeric](38, 6) NULL,
	[PRNOtherChargesAmt] [numeric](38, 6) NULL,
	[PRNTaxAmt] [numeric](38, 6) NULL,
	[PRNTotDedn] [numeric](38, 6) NULL,
	[PRNTotAddn] [numeric](38, 6) NULL,
	[PRNRoundOffAmt] [numeric](38, 6) NULL,
	[PRNNetAmt] [numeric](38, 6) NULL,
	[PrdSchemeFlag] [nvarchar](10) NULL,
	[PrdCmpSchCode] [nvarchar](100) NULL,
	[PrdLcnCode] [nvarchar](100) NULL,
	[PrdLcnName] [nvarchar](250) NULL,
	[PrdCode] [nvarchar](100) NULL,
	[PrdName] [nvarchar](550) NULL,
	[PrdBatCode] [nvarchar](100) NULL,
	[PrdSalQty] [int] NULL,
	[PrdSalQtyVolume] [numeric](38, 6) NULL,
	[PrdUnSalQty] [int] NULL,
	[PrdUnSalQtyVolume] [numeric](38, 6) NULL,
	[PrdRate] [numeric](38, 6) NULL,
	[PrdGrossAmt] [numeric](38, 6) NULL,
	[PrdDiscAmt] [numeric](38, 6) NULL,
	[PrdTaxAmt] [numeric](38, 6) NULL,
	[PrdNetRate] [numeric](38, 6) NULL,
	[PrdNetAmt] [numeric](38, 6) NULL,
	[Reason] [nvarchar](200) NULL,
	[PrdLineBreakUpType] [nvarchar](100) NULL,
	[PrdLineLcnCode] [nvarchar](100) NULL,
	[PrdLineStockType] [nvarchar](100) NULL,
	[PrdLineQty] [int] NULL,
	[PrdLineQtyVolume] [numeric](38, 6) NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL
) ON [PRIMARY]
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_AN_PurchaseReturn]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_AN_PurchaseReturn]
GO
---  exec  Proc_AN_PurchaseReturn '2011-03-01','2011-03-31'
---  select * from PurchaseReturnExtractExcel

CREATE     PROCEDURE [Proc_AN_PurchaseReturn]
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
BEGIN

	DECLARE @DistNm	As nVarchar(200)
    DECLARE @DistCode AS Nvarchar(100)
	SELECT @DistCode = DistributorCode FROM Distributor	
	SELECT @DistNm = Distributorname FROM Distributor	
    DELETE FROM PurchaseReturnExtractExcel
	INSERT INTO PurchaseReturnExtractExcel
	(
		DistCode			,
        DistName			,
		TransName			,
		PRNRefNo			,	
		PRNDate				,
		SpmCode				,
		SpmName				,
		PRNMode				,
		PRNType				,
		GRNNo				,
        GRNDate				,
		CmpInvNo			,
        InvRcpDate			,
		PRNGrossAmt			,
		PRNDiscAmt			,
		PRNSchAmt			,
		PRNOtherChargesAmt	,
		PRNTaxAmt			,
		PRNTotDedn			,
		PRNTotAddn			,
		PRNRoundOffAmt		,
		PRNNetAmt			,
		PrdSchemeFlag		,
		PrdCmpSchCode		,
		PrdLcnCode			,
        PrdLcnName 			,
		PrdCode				,
        PrdName				,
		PrdBatCode			,
		PrdSalQty			,
		PrdUnSalQty			,
		PrdRate				,
		PrdGrossAmt			,
		PrdDiscAmt			,
		PrdTaxAmt			,
		PrdNetRate			,
		PrdNetAmt			,
		Reason				,
		PrdLineBreakUpType	,	
		PrdLineLcnCode		,
		PrdLineStockType	,	
		PrdLineQty			,
		Prdid				,
		PrdbatId
	)
	SELECT @DistCode,@DistNm,'Purchase Return',PR.PurRetRefNo,PR.PurRetDate,S.SpmCode,S.SpmName,(CASE PR.ReturnMode WHEN 1 THEN 'Full' ELSE 'Partial' END),
	(CASE PR.ReturnType WHEN 2 THEN 'Without Reference' ELSE 'With Reference' END),
	PR.PurRcptRefNo,PRT.Invdate,PR.CmpInvNo,PRT.GoodsRcvdDate,PR.GrossAmount,PR.Discount,PR.LessScheme,PR.OtherCharges,PR.TaxAmount,PR.TotalDeduction,PR.TotalAddition,0,PR.NetAmount,
	'No','',L.LcnCode,L.LcnName,P.PrdCCode,P.PrdName,PB.PrdBatCode,PRP.RetSalBaseQty,PRP.RetUnSalBaseQty,
	PRP.PrdUnitLSP,PRP.PrdGrossAmount,PRP.PrdDiscount,PRP.PrdTaxAmount,PRP.PrdUnitNetRate,PRP.PrdNetAmount,ISNULL(R.Description,''),
	ISNULL((CASE PRB.BreakUpType WHEN 1 THEN 'UnSaleable' WHEN 2 THEN 'Excess' END),''),
	ISNULL(PRBL.LcnCode,''),
	ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),
	ISNULL(PRB.BaseQty,0),P.Prdid,PB.PrdbatId
	FROM PurchaseReturn PR(NOLOCK)
	INNER JOIN PurchaseReturnProduct PRP(NOLOCK) ON PR.PurRetId=PRP.PurRetId
	INNER JOIN Company C(NOLOCK) ON PR.CmpId=C.CmpId AND PR.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INNER JOIN Supplier S(NOLOCK) ON PR.SpmId=S.SpmId
	INNER JOIN Product P(NOLOCK) ON PRP.PrdId=P.PrdId
	INNER JOIN Location L ON L.LcnId=PR.LcnId
	INNER JOIN ProductBatch PB(NOLOCK) ON P.PrdId=PB.PrdId AND PRP.PrdBatId=PB.PrdBatId	
	LEFT OUTER JOIN ReasonMaster R(NOLOCK) ON PRP.ReasonId=R.ReasonId
	LEFT OUTER JOIN PurchaseReturnBreakUp PRB ON PRP.PurRetId=PRB.PurRetId AND PRP.PrdSlNo=PRB.PrdSlNo
	LEFT OUTER JOIN StockType ST ON PRB.StockTypeId=ST.StockTypeId
	LEFT OUTER JOIN Location PRBL ON PRBL.LcnId=ST.LcnId
    LEFT OUTER JOIN PurchaseReceipt PRT ON PRT.PurRcptId=PR.PurRcptId AND PRT.LcnId = PRBL.LcnId AND PRT.PurRcptRefNo=PR.PurRcptRefNo
	UNION ALL
	SELECT @DistCode,@DistNm,'Purchase Return',PR.PurRetRefNo,PR.PurRetDate,S.SpmCode,S.SpmName,(CASE PR.ReturnMode WHEN 1 THEN 'Full' ELSE 'Partial' END),
	(CASE PR.ReturnType WHEN 2 THEN 'Without Reference' ELSE 'With Reference' END),
	PR.PurRcptRefNo,PRT.Invdate,PR.CmpInvNo,PRT.GoodsRcvdDate,PR.GrossAmount,PR.Discount,PR.LessScheme,PR.OtherCharges,PR.TaxAmount,PR.TotalDeduction,
	PR.TotalAddition,0,PR.NetAmount,0,
	(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),ISNULL(SM.CmpSchCode,SM.SchCode),
	L.LcnCode,L.LcnName,P.PrdCCode,P.PrdName,PB.PrdBatCode,PRP.RetQty,0,
	PRP.RetValue,PRP.RetAmount,0,0,0,PRP.RetAmount,'','',
	ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),
	0,P.Prdid,PB.PrdbatId
	FROM PurchaseReturn PR(NOLOCK)
	INNER JOIN PurchaseReturnClaimScheme PRP(NOLOCK) ON PR.PurRetId=PRP.PurRetId AND PRP.TypeId=2
	INNER JOIN Company C(NOLOCK) ON PR.CmpId=C.CmpId AND PR.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INNER JOIN Supplier S(NOLOCK) ON PR.SpmId=S.SpmId
	INNER JOIN Product P(NOLOCK) ON PRP.PrdId=P.PrdId
	INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
	INNER JOIN Location L ON L.LcnId=ST.LcnId
	INNER JOIN ProductBatch PB(NOLOCK) ON P.PrdId=PB.PrdId AND PRP.PrdBatId=PB.PrdBatId		
	LEFT OUTER JOIN SchemeMaster SM(NOLOCK) ON SM.SchId=PRP.RefId
	LEFT OUTER JOIN PurchaseReceipt PRT ON PRT.PurRcptId=PR.PurRcptId  AND PRT.PurRcptRefNo=PR.PurRcptRefNo
	UNION ALL
	SELECT @DistCode,@DistNm,'Purchase Return',PR.PurRetRefNo,PR.PurRetDate,S.SpmCode,S.SpmName,(CASE PR.ReturnMode WHEN 1 THEN 'Full' ELSE 'Partial' END),
	(CASE PR.ReturnType WHEN 2 THEN 'Without Reference' ELSE 'With Reference' END),
	PR.PurRcptRefNo,PRT.Invdate,PR.CmpInvNo,PRT.GoodsRcvdDate,PR.GrossAmount,PR.Discount,PR.LessScheme,PR.OtherCharges,PR.TaxAmount,PR.TotalDeduction,
	PR.TotalAddition,0,PR.NetAmount,0,
	(CASE PRP.TypeId WHEN 2 THEN 'Scheme' ELSE 'Claim' END),ISNULL(CSD.RefCode,''),
    L.LcnCode,L.LcnName,P.PrdCCode,P.PrDName,PB.PrdBatCode,PRP.RetQty,0,
	PRP.RetValue,PRP.RetAmount,0,0,0,PRP.RetAmount,'','',
	ISNULL((CASE ST.SystemStockType WHEN 1 THEN 'Saleable' WHEN 2 THEN 'UnSaleable' WHEN 3 THEN 'Offer' END),''),
	0,P.Prdid,PB.PrdbatId
	FROM PurchaseReturn PR(NOLOCK)
	INNER JOIN PurchaseReturnClaimScheme PRP(NOLOCK) ON PR.PurRetId=PRP.PurRetId AND PRP.TypeId=1 
	INNER JOIN PurchaseReceiptClaimScheme PRPT(NOLOCK) ON PR.PurRcptId=PRPT.PurRcptId AND PRPT.TypeId=1
	INNER JOIN Company C(NOLOCK) ON PR.CmpId=C.CmpId AND PR.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INNER JOIN Supplier S(NOLOCK) ON PR.SpmId=S.SpmId
	INNER JOIN Product P(NOLOCK) ON PRP.PrdId=P.PrdId
	INNER JOIN StockType ST ON PRP.StockTypeId=ST.StockTypeId
	INNER JOIN Location L ON L.LcnId=ST.LcnId
	INNER JOIN ProductBatch PB(NOLOCK) ON P.PrdId=PB.PrdId AND PRP.PrdBatId=PB.PrdBatId		
	LEFT OUTER JOIN ClaimSheetHd CSH ON CSH.ClmId=PRP.RefId
	LEFT OUTER JOIN ClaimSheetDetail CSD ON CSH.ClmId=CSD.ClmId AND PRPT.SlNo=CSD.SlNo
    LEFT OUTER JOIN PurchaseReceipt PRT ON PRT.PurRcptId=PR.PurRcptId  AND PRT.PurRcptRefNo=PR.PurRcptRefNo

	Update  PurchaseReturnExtractExcel Set  PrdSalQtyVolume = 0.00, 
			PrdUnSalQtyVolume = 0.00,PrdlineQtyVolume = 0.00 
			 
	
    Update  PurchaseReturnExtractExcel SET PrdSalQtyVolume = PrdSalQty * PrdWgt,		     
			PrdUnSalQtyVolume = PrdUnSalQty * PrdWgt,PrdLineQtyVolume = PrdLineQty * PrdWgt
	From PurchaseReturnExtractExcel a,Product b,ProductBatch c
	Where A.PrdId = B.Prdid and A.PrdId = C.PrdId and A.PrdBatId = C.PrdBatId 
END
GO
---  sales Details
 

DELETE FROM RptAKSOExcelHeaders WHERE Rptid=504
INSERT INTO RptAKSOExcelHeaders VALUES (504,1,'DistCode','Distributor Code',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,2,'DistName','Distributor Name ',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,3,'TransName','Transaction Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,4,'Salinvno','Bill Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,5,'Salinvdate','Bill Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,6,'SalDlvDate','Delivery Date',	1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,7,'SalInvMode','Mode',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,8,'SalInvType','Bill Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,9,'SalGrossAmt','Invoice Gross Amt',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,10,'SalSplDiscAmt','Invoice Special Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,11,'SalSchDiscAmt','Scheme Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,12,'SalCashDiscAmt','Cash Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,13,'SalDBDiscAmt','Distributor Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,14,'SalTaxAmt','Tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,15,'SalWDSAmt','Window Display Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,16,'SalDbAdjAmt','Debot Note Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,17,'SalCrAdjAmt','Credit Note Adjustment Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,18,'SalOnAccountAmt','On Account Adj. Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,19,'SalMktRetAmt','Market Return Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,20,'SalReplaceAmt','Replacement Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,21,'SalOtherChargesAmt','Net - Other charges',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,22,'SalTotDedn','Total Deduction',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,23,'SalTotAddn','Total Addition',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,24,'SalRoundOffAmt','Round Off Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,25,'SalNetAmt','Net Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,26,'LcnName','Location Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,27,'SalesmanCode','Salesman Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,28,'SalesmanName','Salesman Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,29,'SalesRouteCode','Sales Route Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,30,'SalesRouteName','Sales Route Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,31,'RtrCode','Company Retailer Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,32,'RtrName','Retailer Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,33,'ProductCode','Product Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,34,'ProductName','Product Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,35,'Batchcde','Batch Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,36,'SalInvQty','Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,37,'SalInvQtyVolume','Invouce Quantity Volume',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,38,'PrdSelRateBeforeTax','Selling Rate before Tax',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,39,'PrdSelRateAfterTax','Selling Rate After Tax',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,40,'PrdfreeQty','Free Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,41,'PrdfreeQtyVolume','Free Quantity Volume',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,42,'PrdGrossamt','Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,43,'PrdSplDiscAmt','Special Discount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,44,'PrdSchDiscAmt','Scheme Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,45,'PrdCashDiscAmt','Cash Discount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,46,'PrdDBDiscAmt','Distributor Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,47,'PrdTaxAmt','Tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (504,48,'PrdNetAmt','Net Amount',1,1)
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[SalesDetailExtractExcel]') AND type in (N'U'))
DROP TABLE [SalesDetailExtractExcel]
GO
CREATE TABLE [SalesDetailExtractExcel](
	[DistCode] [nvarchar](150) NULL,
	[DistName] [nvarchar](150) NULL,
	[TransName] [nvarchar](200) NULL,
	[Salinvno] [nvarchar](150) NULL,
	[Salinvdate] [datetime] NULL,
	[SalDlvDate] [datetime] NULL,
	[SalInvMode] [nvarchar](150) NULL,
	[SalInvType] [nvarchar](200) NULL,
	[SalGrossAmt] [numeric](18, 2) NULL,
	[SalSplDiscAmt] [numeric](18, 2) NULL,
	[SalSchDiscAmt] [numeric](18, 2) NULL,
	[SalCashDiscAmt] [numeric](18, 2) NULL,
	[SalDBDiscAmt] [numeric](18, 2) NULL,
	[SalTaxAmt] [numeric](18, 2) NULL,
	[SalWDSAmt] [numeric](18, 2) NULL,
	[SalDbAdjAmt] [numeric](18, 2) NULL,
	[SalCrAdjAmt] [numeric](18, 2) NULL,
	[SalOnAccountAmt] [numeric](18, 2) NULL,
	[SalMktRetAmt] [numeric](18, 2) NULL,
	[SalReplaceAmt] [numeric](18, 2) NULL,
	[SalOtherChargesAmt] [numeric](18, 2) NULL,
	[SalTotDedn] [numeric](18, 2) NULL,
	[SalTotAddn] [numeric](18, 2) NULL,
	[SalRoundOffAmt] [numeric](18, 2) NULL,
	[SalNetAmt] [numeric](18, 2) NULL,
	[LcnName] [nvarchar](400) NULL,
	[SalesmanCode] [nvarchar](200) NULL,
	[SalesmanName] [nvarchar](400) NULL,
	[SalesRouteCode] [nvarchar](200) NULL,
	[SalesRouteName] [nvarchar](400) NULL,
	[RtrCode] [nvarchar](200) NULL,
	[RtrName] [nvarchar](400) NULL,
	[ProductCode] [nvarchar](550) NULL,
	[ProductName] [nvarchar](550) NULL,
	[Batchcde] [nvarchar](250) NULL,
	[SalInvQty] [int] NULL,
	[SalInvQtyVolume] [numeric](18, 6) NULL,
	[PrdSelRateBeforeTax] [numeric](18, 2) NULL,
	[PrdSelRateAfterTax] [numeric](18, 2) NULL,
	[PrdfreeQty] [int] NULL,
	[PrdfreeQtyVolume] [numeric](18, 6) NULL,
	[PrdGrossamt] [numeric](18, 2) NULL,
	[PrdSplDiscAmt] [numeric](18, 2) NULL,
	[PrdSchDiscAmt] [numeric](18, 2) NULL,
	[PrdCashDiscAmt] [numeric](18, 2) NULL,
	[PrdDBDiscAmt] [numeric](18, 2) NULL,
	[PrdTaxAmt] [numeric](18, 2) NULL,
	[PrdNetAmt] [numeric](18, 2) NULL
) ON [PRIMARY]
GO


IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_AN_SalesDetail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_AN_SalesDetail]
GO
---  exec  Proc_AN_SalesDetail '2011-03-01','2011-03-31'
---  select * from SalesDetailExtractExcel
CREATE PROCEDURE [Proc_AN_SalesDetail]
(
 	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
as
BEGIN
	DECLARE @DistCode	As nVarchar(50)
    DECLARE @DistNm	As nVarchar(200)
	SELECT @DistCode = DistributorCode FROM Distributor	
	SELECT @DistNm = Distributorname FROM Distributor
    DELETE FROM SalesDetailExtractExcel	
    INSERT INTO SalesDetailExtractExcel
	(
			DistCode ,
			DistName ,
            TransName ,
            Salinvno ,
            Salinvdate ,
            SalDlvDate,
            SalInvMode ,
            SalInvType ,
            SalGrossAmt ,
            SalSplDiscAmt ,
            SalSchDiscAmt ,
			SalCashDiscAmt ,
			SalDBDiscAmt ,
            SalTaxAmt ,
			SalWDSAmt,
            SalDbAdjAmt	,
			SalCrAdjAmt	,
            SalOnAccountAmt	,
			SalMktRetAmt ,
            SalReplaceAmt ,
		    SalOtherChargesAmt ,
            SalTotDedn	,
		    SalTotAddn	,
            SalRoundOffAmt ,
		    SalNetAmt ,
            LcnName ,
            SalesmanCode ,
		    SalesmanName,
            SalesRouteCode ,
			SalesRouteName ,
            RtrCode,
		    RtrName	,
            ProductCode	,
			ProductName	,
            Batchcde,
            SalInvQty ,
			SalInvQtyVolume,
            PrdSelRateBeforeTax ,
            PrdSelRateAfterTax ,
            PrdfreeQty ,
			PrdfreeQtyVolume,
            PrdGrossamt ,
            PrdSplDiscAmt ,
            PrdSchDiscAmt ,
            PrdCashDiscAmt ,
            PrdDBDiscAmt ,
            PrdTaxAmt ,
            PrdNetAmt 
	)
	 SELECT  @DistCode,@DistNm,'SalesDetail',A.SalInvNo,A.SalInvDate,A.SalDlvDate,  
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,  
	(CASE A.BillType WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END) AS BillType,  
	A.SalGrossAmount,A.SalSplDiscAmount,A.SalSchDiscAmount,A.SalCDAmount,A.SalDBDiscAmount,A.SalTaxAmount,  
	A.WindowDisplayAmount,A.DBAdjAmount,A.CRAdjAmount,A.OnAccountAmount,A.MarketRetAmount,A.ReplacementDiffAmount,  
	A.OtherCharges,A.TotalDeduction,A.TotalAddition,A.SalRoundOffAmt,A.SalNetAmt,L.LcnName,  
	B.SMCode,B.SMName,C.RMCode,C.RMName,R.CmpRtrCode,R.RtrName,  
	H.PrdCCode,H.Prdname,I.CmpBatCode,  
	G.BaseQty AS SalInvQty ,G.BaseQty*PrdWgt,
	(G.PrdGrossAmountAftEdit/G.BaseQty),G.PrdUom1EditedNetRate,
	G.SalManFreeQty AS Prdfreeqty ,G.SalManFreeQty*PrdWgt, 
	G.PrdGrossAmount,G.PrdSplDiscAmount,G.PrdSchDiscAmount,  
	G.PrdCDAmount,G.PrdDBDiscAmount,G.PrdTaxAmount,G.PrdNetAmount  
    FROM SalesInvoice A  (NOLOCK)  
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId = R.RtrId  
	INNER JOIN SalesMan B (NOLOCK) ON A.SMID = B.SmID  
	INNER JOIN RouteMaster C (NOLOCK) ON A.RMID = C.RMID  
	INNER JOIN DeliveryBoy D  (NOLOCK) ON A.DlvBoyId = D.DlvBoyId  
	LEFT OUTER JOIN Vehicle E (NOLOCK) ON E.VehicleId = A. VehicleId  
	INNER JOIN RouteMaster F (NOLOCK) ON A.DlvRMID = F.RMID  
	INNER JOIN SalesInvoiceProduct G (NOLOCK) ON A.SalId = G.SalId  
	INNER JOIN Product H (NOLOCK) ON G.PrdId = H.PrdId  
	INNER JOIN ProductBatch I (NOLOCK) ON G.PrdBatID = I.PrdBatId AND H.PrdId=I.PrdId  
	INNER JOIN Location L (NOLOCK) ON L.LcnId=A.LcnId  
	WHERE A.Dlvsts IN (4,5) and A.Salinvdate BETWEEN @Pi_FromDate AND @Pi_ToDate
END
Go

--- Sales Return

DELETE FROM RptAKSOExcelHeaders WHERE Rptid=505
INSERT INTO RptAKSOExcelHeaders VALUES (505,1,'DistCode','Distributor Code',1,	1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,2,'DistName','Distributor Name ',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,3,'TransName','Transaction Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,4,'SRNRefNo','Sales return Ref. Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,5,'SRNDate','Sales Return Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,6,'SRNRefType','With/Without Ref',	1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,7,'SRNMode','Sales Return Mode',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,8,'SRNType','Sales Return Type',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,9,'SRNGrossAmt','Invoice Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,10,'SRNCashDiscAmt','Invoice Cash Discount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,11,'SRNDBDiscAmt','Invoice DB Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,12,'SRNRoundOffAmt','Round Off Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,13,'SRNNetAmt','Invoice Net Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,14,'SalesmanCode','Salesman Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,15,'SalesmanName','Salesman Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,16,'RouteCode','Route Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,17,'SalesRouteName','Route Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,18,'RtrCode','Company Retailer Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,19,'RtrName','Retailer Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,20,'PrdSalInvNo','Bill Number',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,21,'Salinvdte','Bill Date',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,22,'PrdLcnCode','Location Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,23,'PrdLcnName','Location Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,24,'PrdCode','Product Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,25,'PrdName','Product Name',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,26,'PrdBatCde','Batch Code',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,27,'PrdSalQty','Salable Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,28,'PrdSalQtyVolume','Salable Quantity Volume',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,29,'PrdUnSalQty','Unsalable Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,30,'PrdUnSalQtyVolume','Unsalable Quantity Volume',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,31,'PrdOfferQty','Offer Quantity',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,32,'PrdOfferQtyVolume','Offer Quantity Volume',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,33,'PrdSelRate','Selling Rate',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,34,'PrdGrossAmt','Gross Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,35,'PrdSplDiscAmt','Special Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,36,'PrdSchDiscAmt','Scheme Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,37,'PrdCashDiscAmt','Cash Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,38,'PrdDBDiscAmt','DB Discount Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,39,'PrdTaxAmt','Tax Amount',1,1)
INSERT INTO RptAKSOExcelHeaders VALUES (505,40,'PrdNetAmt','Net Amount',1,1)
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[SalesReturnExtractExcel]') AND type in (N'U'))
DROP TABLE [SalesReturnExtractExcel]
GO
CREATE TABLE [SalesReturnExtractExcel](
	[DistCode] [nvarchar](50) NULL,
	[DistName] [nvarchar](200) NULL,
	[TransName] [nvarchar](200) NULL,
	[SRNRefNo] [nvarchar](50) NULL,
	[SRNDate] [datetime] NULL,
	[SRNRefType] [nvarchar](100) NULL,
	[SRNMode] [nvarchar](100) NULL,
	[SRNType] [nvarchar](100) NULL,
	[SRNGrossAmt] [numeric](38, 6) NULL,
	[SRNCashDiscAmt] [numeric](38, 6) NULL,
	[SRNDBDiscAmt] [numeric](38, 6) NULL,
	[SRNRoundOffAmt] [numeric](38, 6) NULL,
	[SRNNetAmt] [numeric](38, 6) NULL,
	[SalesmanCode] [nvarchar](100) NULL,
	[SalesmanName] [nvarchar](100) NULL,
	[RouteCode] [nvarchar](100) NULL,
	[SalesRouteName] [nvarchar](100) NULL,
	[RtrCode] [nvarchar](100) NULL,
	[RtrName] [nvarchar](100) NULL,
	[PrdSalInvNo] [nvarchar](50) NULL,
	[Salinvdte] [datetime] NULL,
	[PrdLcnCode] [nvarchar](100) NULL,
	[PrdLcnName] [nvarchar](250) NULL,
	[PrdCode] [nvarchar](250) NULL,
	[PrdName] [nvarchar](250) NULL,
	[PrdBatCde] [nvarchar](250) NULL,
	[PrdSalQty] [int] NULL,
	[PrdSalQtyVolume] [numeric](38, 6) NULL,
	[PrdUnSalQty] [int] NULL,
	[PrdUnSalQtyVolume] [numeric](38, 6) NULL,
	[PrdOfferQty] [int] NULL,
	[PrdOfferQtyVolume] [numeric](38, 6) NULL,
	[PrdSelRate] [numeric](38, 6) NULL,
	[PrdGrossAmt] [numeric](38, 6) NULL,
	[PrdSplDiscAmt] [numeric](38, 6) NULL,
	[PrdSchDiscAmt] [numeric](38, 6) NULL,
	[PrdCashDiscAmt] [numeric](38, 6) NULL,
	[PrdDBDiscAmt] [numeric](38, 6) NULL,
	[PrdTaxAmt] [numeric](38, 6) NULL,
	[PrdNetAmt] [numeric](38, 6) NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_AN_SalesReturn]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_AN_SalesReturn]
GO
--- Select * from SalesReturnExtractExcel
--- Exec Proc_AN_SalesReturn '2011-03-01','2011-03-31'
Create   PROCEDURE [Proc_AN_SalesReturn]
(
 	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
as
BEGIN
	DECLARE @DistCode	As nVarchar(50)
    DECLARE @DistNm	As nVarchar(200)
	SELECT @DistCode = DistributorCode FROM Distributor	
	SELECT @DistNm = Distributorname FROM Distributor
    DELETE FROM SalesReturnExtractExcel	
	INSERT INTO SalesReturnExtractExcel
	(
		DistCode		,
        DistName ,
        TransName ,
		SRNRefNo		,
		SRNDate			,
        SRNRefType		,
		SRNMode			,
		SRNType			,	
		SRNGrossAmt		,
		SRNCashDiscAmt	,
		SRNDBDiscAmt	,
		SRNRoundOffAmt	,
		SRNNetAmt		,
        SalesManCode    ,
		SalesmanName	,
        RouteCode       ,
		SalesRouteName	,
		RtrCode			,
		RtrName			,
		PrdSalInvNo		,
        Salinvdte       ,
		PrdLcnCode		,
        PrdLcnName      ,
		PrdCode			,
		PrdName			,
		PrdBatCde		,
		PrdSalQty		,
		PrdSalQtyVolume	,
		PrdUnSalQty		,
		PrdUnSalQtyVolume ,
		PrdOfferQty		,
		PrdOfferQtyVolume ,
		PrdSelRate		,
		PrdGrossAmt		,
		PrdSplDiscAmt	,
		PrdSchDiscAmt	,
		PrdCashDiscAmt	,
		PrdDBDiscAmt	,
		PrdTaxAmt		,
		PrdNetAmt		
	)
	SELECT
		@DistCode ,@DistNm,'Sales Return',
		A.ReturnCode ,
		A.ReturnDate ,
        'With Reference',
		(CASE A.ReturnMode WHEN 0 THEN '' WHEN 1 THEN 'Full' ELSE 'Partial' END),
		(CASE A.InvoiceType WHEN 1 THEN 'Single Invoice' ELSE 'Multi Invoice' END),
		A.RtnGrossAmt,A.RtnCashDisAmt,A.RtnDBDisAmt,
		A.RtnRoundOffAmt,A.RtnNetAmt,SM.SMCode,
		SM.SMName,C.RMCode,C.RMName,R.CmpRtrCode,R.RtrName,
		ISNULL(G.SalInvno,B.SalCode) AS SalInvNo,
        ISNULL(G.SalInvDate,A.ReturnDate) AS SalInvDte,
		L.LcnCode,L.LcnName,		
		D.PrdCCode,D.PrdName,F.CmpBatCode,
		(CASE ST.SystemStockType WHEN 1 THEN BaseQty ELSE 0 END)AS SalQty,
		(CASE ST.SystemStockType WHEN 1 THEN BaseQty*PrdWgt ELSE 0 END)AS SalQtyVolume,
		(CASE ST.SystemStockType WHEN 2 THEN BaseQty ELSE 0 END)AS UnSalQty,
		(CASE ST.SystemStockType WHEN 2 THEN BaseQty*PrdWgt ELSE 0 END)AS UnSalQtyVolume,
		(CASE ST.SystemStockType WHEN 3 THEN BaseQty ELSE 0 END)AS OfferQty,
		(CASE ST.SystemStockType WHEN 3 THEN BaseQty*PrdWgt ELSE 0 END)AS OfferQtyVolume,
		B.PrdEditSelRte ,
		B.PrdGrossAmt,B.PrdSplDisAmt,B.PrdSchDisAmt,B.PrdCDDisAmt,B.PrdDBDisAmt,
		B.PrdTaxAmt,B.PrdNetAmt
	FROM ReturnHeader A INNER JOIN ReturnProduct B ON A.ReturnId = B.ReturnId 
		AND A.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		INNER JOIN RouteMaster C ON	A.RMID = C.RMID
		INNER JOIN Product D ON B.PrdId = D.PrdId
		INNER JOIN Company E ON D.CmpId = E.CmpId
		INNER JOIN ProductBatch F ON B.PrdBatId = F.PrdBatId
		INNER JOIN Retailer R ON R.RtrId=A.RtrId
		LEFT OUTER JOIN SalesInvoice G ON B.SalId = G.SalId AND A.SalId=G.SalId AND G.RtrId = R.RtrId
		INNER JOIN Salesman SM ON A.SMId=SM.SMId
		INNER JOIN StockType ST ON B.StockTypeId=ST.StockTypeId
		INNER JOIN Location L ON L.LcnId=ST.LcnId
UPDATE SalesReturnExtractExcel SET SRNRefType='WithoutReference' WHERE PrdSalinvno=''
END
GO
---  Stock Mangement 
Delete From  RptAKSOExcelHeaders where RptId = 506
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,1,'DistCode','Distributor Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,2,'DistName','Distributor Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,3,'TransName','Transaction Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,4,'StkRefNumber','Stk Mgmt Ref. Number',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,5,'StkRefDate','Stk Mgmt Transaction Date',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,6,'LocCode','Location Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,7,'LocName','Location Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,8,'StkMngtType','Stock Management Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,9,'TransType','Transaction Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,10,'ProductCode','Product Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,11,'ProductName','Product Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,12,'BatchCode','Batch Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,13,'StockType','Stock Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,14,'Qty','Quantity',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,15,'Volume','Volume',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,16,'Rate','Rate',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,17,'Amount','Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,18,'Reason','Reason',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,19,'PrdId','PrdId',0,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(506,20,'PrdBatId','PrdBatId',0,1)
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[StockManagementExtractExcel]') AND type in (N'U'))
DROP TABLE [StockManagementExtractExcel]
GO
CREATE TABLE [StockManagementExtractExcel](
	[DistCode] [nvarchar](200) NULL,
	[DistName] [nvarchar](200) NULL,
	[TransName] [nvarchar](200) NULL,
	[StkRefNumber] [nvarchar](200) NULL,
	[StkRefDate] [datetime] NULL,
	[LocCode] [nvarchar](200) NULL,
	[LocName] [nvarchar](200) NULL,
	[StkMngtType] [nvarchar](200) NULL,
	[TransType] [nvarchar](200) NULL,
	[ProductCode] [nvarchar](200) NULL,
	[ProductName] [nvarchar](200) NULL,
	[BatchCode] [nvarchar](200) NULL,
	[StockType] [nvarchar](200) NULL,
	[Qty] [int] NULL,
	[Volume] [numeric](38, 6) NULL,
	[Rate] [numeric](38, 6) NULL,
	[Amount] [numeric](38, 6) NULL,
	[Reason] [nvarchar](200) NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_AN_StockManagement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_AN_StockManagement]
GO
---- EXEC Proc_AN_StockManagement '2011-03-01','2011-03-20'
CREATE PROCEDURE [Proc_AN_StockManagement]
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
/****************************************************************************
* PROCEDURE: Proc_AN_StockJournal
* PURPOSE: Extract Data in SM Details -- Akso Nobel 
* NOTES:
* CREATED: Panneer	16.03.2011
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
*****************************************************************************/
SET NOCOUNT ON
BEGIN
	DELETE FROM StockManagementExtractExcel
	INSERT INTO StockManagementExtractExcel ( DistCode,DistName,TransName,StkRefNumber,StkRefDate,
											  LocCode,LocName,StkMngtType,TransType,ProductCode,ProductName,
											  BatchCode,StockType,Qty,Volume,Rate,Amount,Reason,PrdId,PrdBatId )
	
	SELECT DISTINCT 
				'','','Stock Management',A.StkMngRefNo,StkMngDate,LcnCode,LcnName,
				Case OpenBal When 1 Then 'Opening Stock' Else 'Stock Management' End As StkMngtType,
				F.[Description],PrdCCode,PrdName,PrdBatCode,
				Case STockTypeId When 1 Then 'Saleable'
								 When 2 Then 'UnSaleable'
								 When 3 Then 'Offer' END AS StkMngtType,
				TotalQty,TotalQty*PrdWgt,Rate,Amount,'' AS Reason,B.PrdId,B.PrdBatId
	From 
			StockManagement   A,StockManagementProduct B ,Location C,
			Product D,ProductBatch E,StockManagementType F
	Where
			A.StkMngRefNo = B.StkMngRefNo  AND A.LcnId = C.LcnId
			AND B.PrdId = D.PrdId  AND B.PrdId = E.PrdId  AND B.PrdBatId = E.PrdBatId
			AND B.StkMgmtTypeId = F.StkMgmtTypeId	AND A.Status = 1
			AND StkMngDate Between @Pi_FromDate  and @Pi_ToDate
	Order By 
			A.StkMngRefNo

	
	Select Distinct 
		A.StkMngRefNo,A.PrdId,A.PrdBatId,A.ReasonId,[Description] INTO  #UpdateStkMngt
	From 
		StockManagementProduct A,Product B,ProductBatch C,ReasonMaster D,
		StockManagement E
	WHere 
		A.PrdId = B.PrdId  And A.PrdId = C.PrdId AND  A.PrdBatId = C.PrdBatId 
		AND A.ReasonId = D.ReasonId and A.ReasonId <> 0 
		AND A.StkMngRefNo = E.StkMngRefNo
		AND StkMngDate Between @Pi_FromDate  and @Pi_ToDate
	
	UPDATE StockManagementExtractExcel SET Reason = [Description]
	From StockManagementExtractExcel A,#UpdateStkMngt B 
	Where A.StkRefNumber = B.StkMngRefNo  AND A.PrdId = B.PrdId  
		  and A.PrdBatId = B.PrdBatId 


	UPDATE StockManagementExtractExcel SET DistCode=(SELECT DistributorCode FROM Distributor)
	UPDATE StockManagementExtractExcel SET DistName=(SELECT DistributorName FROM Distributor)

	Select * from StockManagementExtractExcel
END 
GO
----  Stock Journal

Delete From  RptAKSOExcelHeaders where RptId = 507
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,1,'DistCode','Distributor Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,2,'DistName','Distributor Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,3,'TransName','Transaction Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,4,'StkJnrRefNumber','Stk journal Ref. Number',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,5,'StkJnrRefDate','Stk Journal Transaction Date',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,6,'ProductCode','Product Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,7,'ProductName','Product Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,8,'BatchCode','Batch Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,9,'FromLocCode','From Location Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,10,'FromLocName','From Location Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,11,'FromStockType','From Stock Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,12,'ToLocCode','To Location Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,13,'ToLocName','To Location Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,14,'ToStockType','To Stock Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,15,'TransQty','Transfer Quantity',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,16,'TransQtyVolume','Transfer Quantity Volume',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,17,'BalQty','Balance Quantity',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,18,'BalQtyVolume','Balance Quantity  Volume',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,19,'Reason','Reason',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,20,'PrdId','PrdId',0,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(507,21,'PrdBatId','PrdBatId',0,1)
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[StockJournalExtractExcel]') AND type in (N'U'))
DROP TABLE [StockJournalExtractExcel]
GO
CREATE TABLE [StockJournalExtractExcel](
	[DistCode] [nvarchar](200) NULL,
	[DistName] [nvarchar](200) NULL,
	[TransName] [nvarchar](200) NULL,
	[StkJnrRefNumber] [nvarchar](200) NULL,
	[StkJnrRefDate] [datetime] NULL,
	[ProductCode] [nvarchar](200) NULL,
	[ProductName] [nvarchar](200) NULL,
	[BatchCode] [nvarchar](200) NULL,
	[FromLocCode] [nvarchar](200) NULL,
	[FromLocName] [nvarchar](200) NULL,
	[FromStockType] [nvarchar](200) NULL,
	[ToLocCode] [nvarchar](200) NULL,
	[ToLocLocName] [nvarchar](200) NULL,
	[ToStockType] [nvarchar](200) NULL,
	[TransQty] [int] NULL,
	[TransQtyVolume] [numeric](38, 6) NULL,
	[BalQty] [int] NULL,
	[BalQtyVolume] [numeric](38, 6) NULL,
	[Reason] [nvarchar](200) NULL,
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_AN_StockJournal]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_AN_StockJournal]
GO
----- EXEC Proc_AN_StockJournal '2011-03-01','2011-03-31'
CREATE PROCEDURE [Proc_AN_StockJournal]
(
	@Pi_FromDate 	DATETIME,
	@Pi_ToDate	DATETIME
)
AS
/****************************************************************************
* PROCEDURE: Proc_AN_StockJournal
* PURPOSE: Extract Data in SJ Details -- Akso Nobel 
* NOTES:
* CREATED: Panneer	16.03.2011
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
*****************************************************************************/

SET NoCount On
BEGIN
	DELETE FROM StockJournalExtractExcel
	INSERT INTO StockJournalExtractExcel ( DistCode,DistName,TransName,StkJnrRefNumber,
									StkJnrRefDate,ProductCode,ProductName,BatchCode,FromLocCode,
									FromLocName,FromStockType,ToLocCode,ToLocLocName,ToStockType,
									TransQty,TransQtyVolume,BalQty,BalQtyVolume,Reason,PrdId,PrdBatId )
	SELECT DISTINCT  
					'','','Stock Journal',A.StkJournalRefNo,A.StkJournalDate,
					PrdCCode,PrdName,PrdBatCode,E.LcnCode FromLocCode,E.LcnName FromLocName,
					Case D.SystemStockType When 1 Then 'Saleable'
									 When 2 Then 'UnSaleable' Else 'Offer' End As FromStockType,
					H.LcnCode ToLocCode,H.LcnName ToLocCode,
					Case G.SystemStockType When 1 Then 'Saleable'
									 When 2 Then 'UnSaleable' Else 'Offer' End As ToStockType,
					StkTransferQty TransferQty,StkTransferQty*PrdWgt,
					BalanceQty,BalanceQty*PrdWgt,'' AS Reason ,A.PrdId,A.PrdBatId
	From 
			StockJournal A,Product B,ProductBatch C,StockType D,
			Location E,StockJournalDt F,StockType G,Location H
	WHere 
			A.PrdId = B.PrdId AND A.PrdId = C.PrdId and A.PrdBatId  = C.PrdBatId
			AND D.StockTypeId = F.StockTypeId   AND E.LcnId = D.LcnId
			AND G.StockTypeId = F.TransferStkTypeId   AND H.LcnId = G.LcnId		
			AND A.StkJournalRefNo = F.StkJournalRefNo
			AND StkJournalDate Between 	@Pi_FromDate and  @Pi_ToDate
	Order By 
			A.StkJournalRefNo

	Select Distinct 
		A.StkJournalRefNo,E.PrdId,E.PrdBatId,A.ReasonId,[Description] INTO  #UpdateStkJurMngt
	From 
		StockJournalDt A,Product B,ProductBatch C,
		ReasonMaster D,StockJournal E
	WHere 
		E.PrdId = B.PrdId  And E.PrdId = C.PrdId AND  E.PrdBatId = C.PrdBatId 
		AND A.ReasonId = D.ReasonId and A.ReasonId <> 0 
		AND A.StkJournalRefNo = E.StkJournalRefNo
		AND StkJournalDate Between 	@Pi_FromDate and  @Pi_ToDate 
	
	UPDATE StockJournalExtractExcel SET Reason = [Description]
	From StockJournalExtractExcel A,#UpdateStkJurMngt B 
	Where A.StkJnrRefNumber = B.StkJournalRefNo  AND A.PrdId = B.PrdId  
		  and A.PrdBatId = B.PrdBatId 
 
	UPDATE StockJournalExtractExcel SET DistCode=(SELECT DistributorCode FROM Distributor)
	UPDATE StockJournalExtractExcel SET DistName=(SELECT DistributorName FROM Distributor)


	Select * from StockJournalExtractExcel
END 
GO

Delete From  RptAKSOExcelHeaders where RptId = 508
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,1,'DistCode','Distributor Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,2,'DistName','Distributor Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,3,'TransName','Transaction Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,4,'DbNoteType','Debit Note Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,5,'DbNoteNumber','Debit Note Number',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,6,'DBNoteDate','Debit Note Date',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,7,'SuppOrRetName','Supplier Or Retailer Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,8,'CreditAccount','Credit Account',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,9,'Reason','Reason',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,10,'DBAmount','Debit Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,11,'DBAdjAmount','Adjusted Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,12,'BalAmount','Balance Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,13,'Status','Status',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(508,14,'Remarks','Remarks',1,1)
GO
Delete From  RptAKSOExcelHeaders where RptId = 509
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,1,'DistCode','Distributor Code',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,2,'DistName','Distributor Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,3,'TransName','Transaction Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,4,'CRNoteType','Credit Note Type',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,5,'CRNoteNumber','Credit Note Number',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,6,'CRNoteDate','Credit Note Date',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,7,'SuppOrRetName','Supplier Or Retailer Name',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,8,'DebitAccount','Debit Account',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,9,'Reason','Reason',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,10,'CrAmount','Credit Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,11,'CRAdjAmount','Adjusted Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,12,'BalAmount','Balance Amount',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,13,'Status','Status',1,1)
GO
INSERT INTO RptAKSOExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
Values(509,14,'Remarks','Remarks',1,1)
GO
 

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RptAkzoRetAccStatement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RptAkzoRetAccStatement]
GO
----   exec  Proc_RptAkzoRetAccStatement 222,2,0,'hh',0,0,1

CREATE  Procedure [Proc_RptAkzoRetAccStatement]
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
Begin
SET NOCOUNT ON
/****************************************************************************
* PROCEDURE: Proc_RptAkzoRetAccStatement
* PURPOSE: General Procedure
* NOTES:
* CREATED: Panneer	14.03.2011
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
* 22.03.2011   Panneer    BugFixing
*****************************************************************************/

	DECLARE @FromDate			AS DATETIME
	DECLARE @ToDate				AS DATETIME
	DECLARE @NewSnapId 			AS	INT
	DECLARE @DBNAME				AS 	NVARCHAR(50)
	DECLARE @TblName 			AS	NVARCHAR(500)
	DECLARE @TblStruct 			AS	VARCHAR(8000)
	DECLARE @TblFields 			AS	VARCHAR(8000)
	DECLARE @sSql				AS 	VARCHAR(8000)
	DECLARE @ErrNo	 			AS	INT
	DECLARE @PurDBName			AS	NVARCHAR(50)

	DECLARE @SMId				AS	INT
	DECLARE @RMId				AS	INT
	DECLARE @RtrId				AS	INT

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)

	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))


	CREATE TABLE #RptAkzoRetAccStatement
	(
			[Description]       NVARCHAR(200),
			[DocRefNo]          NVARCHAR(200),
			[Date]				DATETIME,
			[Debit]				NUMERIC (38,6),
			[Credit]			NUMERIC (38,6),
			[Balance]			NUMERIC (38,6),
			[TransactionDet]    NVARCHAR(200),
			[CheqorDueDate]     DATETIME,
			[SeqNo]				INT,
			[UserId]			INT
	)

SET @TblName = 'RptAkzoRetAccStatement'
SET @TblStruct = '	[Description]       NVARCHAR(200),
					[DocRefNo]          NVARCHAR(200),
					[Date]				DATETIME,
					[Debit]				NUMERIC (38,6),
					[Credit]			NUMERIC (38,6),
					[Balance]			NUMERIC (38,6),
					[TransactionDet]    NVARCHAR(200),
					[CheqorDueDate]     DATETIME,
					[SeqNo]				INT
					[UserId]			INT'
SET @TblFields = '  [Description],[DocRefNo],[Date],[Debit],[Credit],
					[Balance],[TransactionDet],[CheqorDueDate],[SeqNo],[UserId]'

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
		Exec Proc_RetailerAccountStment @FromDate,@ToDate,@RtrId

		INSERT INTO #RptAkzoRetAccStatement ([Description],DocRefNo,Date,Debit,Credit,Balance,
											 TransactionDet,CheqorDueDate,SeqNo,UserId)
			/*	Calculate Opening Balance Details  */	
		Select  
				'Opening Balance'   [Description], '' DocRefNo, @FromDate Date,
				 0 as Debit,0 As Credit,BalanceAmount as balance,
				'' as TransactionDet,'1900-01-01' CheqorDueDate,1 SeqNo,@Pi_UsrId
		From 
				TempRetailerAccountStatement  (NoLock) 
		Where	Details = 'Opening Balance'
				
 				 
				/*	Calculate Sales Details  */ 
		UNION ALL 
		Select  
				'Invoice' [Description],SalInvNo DocRefNo,SalInvDate Date,
				DbAmount Debit,0 as Credit,0 Balance,'' as TransactionDet,
				SalDlvDate CheqorDueDate,2 SeqNo, @Pi_UsrId
		From 
				TempRetailerAccountStatement a (NoLock) ,SalesInvoice B (NoLock)
		WHere
				Details = 'Sales' and A.DocumentNo = B.SalInvNo 
		UNION ALL
		Select  
				'Total Invoice IN' [Description],'' DocRefNo,'1900-01-01' Date,
				0 Debit,0 as Credit, Isnull(SUM(DbAmount),0) Balance,'' as TransactionDet,
				'1900-01-01' CheqorDueDate,3 SeqNo,@Pi_UsrId
		From 
				TempRetailerAccountStatement a (NoLock) ,SalesInvoice B (NoLock)
		WHere
				Details = 'Sales' and A.DocumentNo = B.SalInvNo 

					/*	Calculate Cheque Details  */
		UNION ALL		
		Select  
				'Cheque Received' [Description],RI.InvRcpNo DocRefNo,InvRcpDate Date,
				0 Debit,Sum(RI.SalInvAmt)  as Credit, 0 Balance,InvInsNo as TransactionDet,
				Isnull(InvInsDate,'1900-01-01') CheqorDueDate,4 SeqNo, @Pi_UsrId
		From 
				ReceiptInvoice RI (NoLock),	TempRetailerAccountStatement T (NoLock) ,
				Receipt  R  (NoLock),		SalesInvoice SI (NoLock)
		Where
				RI.InvRcpNo = T.DocumentNo  AND  RI.InvRcpNo = R.InvRcpNo
				and Details = 'Collection'  AND InvRcpMode IN (1,2,3,4,8)
				AND T.Rtrid  = @RtrId       And RI.SalId = SI.SalId 
				And T.RtrId = SI.RtrId		AND SI.SalInvNo = T.Refno
				AND  CancelStatus = 1
		Group By
				RI.InvRcpNo,InvRcpDate,InvInsNo,InvInsDate 
		UNION ALL
		Select  
				'Total Receipt Received' [Description],'' DocRefNo,'1900-01-01' Date,
				0 Debit,0  as Credit, (-1) * Isnull(Sum(RI.SalInvAmt),0) Balance,'' as TransactionDet,
				'1900-01-01' CheqorDueDate,5 SeqNo,@Pi_UsrId
		From 
				ReceiptInvoice RI (NoLock),	TempRetailerAccountStatement T (NoLock) ,
				Receipt  R  (NoLock),		SalesInvoice SI (NoLock)
		Where
				RI.InvRcpNo = T.DocumentNo  AND  RI.InvRcpNo = R.InvRcpNo
				and Details = 'Collection'  AND InvRcpMode IN (1,2,3,4,8)
				AND T.Rtrid  = @RtrId       And RI.SalId = SI.SalId 
				And T.RtrId = SI.RtrId		AND SI.SalInvNo = T.Refno
				AND  CancelStatus = 1

				/*	Calculate Debit Note Details  */
		UNION ALL
		Select 'Debit Note - CD' AS [Description],DBNoteNumber DocRefNo,DBNoteDate Date,
				Isnull(DbAmount,0) Debit,Isnull(CRAmount,0) as Credit, 0 Balance,Isnull(Remarks,'') as TransaonDet,
				'1900-01-01' CheqorDueDate,6 SeqNo,@Pi_UsrId
		From 
				DebitNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.DBNoteNumber = T.DocumentNo	AND Details = 'Debit Note Retailer'	
		UNION ALL
		Select 'Total Debit Notes' AS [Description],'' DocRefNo,'1900-01-01' Date,
				0 Debit,0 as Credit, Isnull(Sum(DbAmount - CRAmount),0) Balance,'' as TransaonDet,
				'1900-01-01' CheqorDueDate,7 SeqNo,@Pi_UsrId
		From 
				DebitNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.DBNoteNumber = T.DocumentNo	AND Details = 'Debit Note Retailer'
				
				/*  Calculate Return  Details  */
		UNION ALL
		Select  'Credit Invoice',ReturnCode DocRefNo,ReturnDate Date,
				0 as Debit,CrAmount as Credit,0 as  Balance,Isnull(DocRefNo,'') as TransaonDet,
				'1900-01-01' CheqorDueDate,8 SeqNo,@Pi_UsrId
		From
				ReturnHeader  A (Nolock) ,TempRetailerAccountStatement T (Nolock)
		Where	
				Details = 'Sales Return' AND A.ReturnCode = T.DocumentNo
		UNION ALL
		Select  'Total Credit Invoice','' DocRefNo,'1900-01-01' Date,
				0 as Debit,0 as Credit,Isnull(Sum(CrAmount),0) * (-1) as  Balance,
				'' as TransaonDet,
				'1900-01-01' CheqorDueDate,9 SeqNo,@Pi_UsrId
		From
				ReturnHeader  A (Nolock) ,TempRetailerAccountStatement T (Nolock)
		Where	
				Details = 'Sales Return' AND A.ReturnCode = T.DocumentNo
	
 				/*  Calculate Credit Note  Details  */
		UNION ALL
		Select 'Credit Note' AS [Description],CRNoteNumber DocRefNo,CRNoteDate Date,
				Isnull(DBAmount,0) Debit,Isnull(CRAmount,0) as Credit, 0 Balance,Isnull(Remarks,'') as TransaonDet,
				'1900-01-01' CheqorDueDate,10 SeqNo,@Pi_UsrId
		From 
				CreditNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.CRNoteNumber = T.DocumentNo	AND Details = 'Credit Note Retailer'	
		UNION ALL
		Select 'Total Credit Notes' AS [Description],'' DocRefNo,'1900-01-01' Date,
				0 Debit,0 as Credit,-(1) * Isnull(Sum(CRAmount-DBAmount),0) Balance,'' as TransaonDet,
				'1900-01-01' CheqorDueDate,11 SeqNo,@Pi_UsrId
		From 
				CreditNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.CRNoteNumber = T.DocumentNo	AND Details = 'Credit Note Retailer'

					/*  Calculate Return & Replacement  Details  */
		Union ALl
		Select 
				'Return & Replacement-Replacement' AS [Description],RepRefNo DocRefNo,RepDate  Date,
				DBAmount Debit,0 Credit,0 Balance ,Isnull(DocRefNo,'') DocRefNo,
				'1900-01-01' CheqorDueDate,12 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND Details = 'Return & Replacement-Replacement'
		Union ALL
		Select 
				'Total Return & Replacement-Replacement' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit,Isnull(Sum(DBAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,13 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND  Details = 'Return & Replacement-Replacement'

					/*  Calculate Return & Replacement  Details  */
		Union ALl
		Select 
				'Return & Replacement-Return' AS [Description],RepRefNo DocRefNo,RepDate  Date,
				0 Debit,CRAmount Credit,0 Balance ,Isnull(DocRefNo,'') DocRefNo,
				'1900-01-01' CheqorDueDate,14 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND Details = 'Return & Replacement-Return'
		Union ALL
		Select 
				'Total Return & Replacement-Return' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit,(-1) * Isnull(Sum(CRAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,15 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND  Details = 'Return & Replacement-Return'

					/*  Calculate Collection-Cheque Bounce Details  */
		Union ALl
		Select 
				'Collection-Cheque Bounce' AS [Description],InvRcpNo,InvRcpDate  Date,
				DbAmount Debit,0 Credit,0 Balance ,'' DocRefNo,
				'1900-01-01' CheqorDueDate,16 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , Receipt A (Nolock)
		WHERE
				A.InvRcpNo = T.DocumentNo AND Details = 'Collection-Cheque Bounce'
		Union ALL
		Select 
				'Total Collection-Cheque Bounce' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit, Isnull(Sum(DbAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,17 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Collection-Cheque Bounce'

					/*  Calculate Collection-Cheque Bounce Details  */
		Union ALl
		Select 
				'Collection-Cash Cancellation' AS [Description],InvRcpNo,InvRcpDate  Date,
				DbAmount Debit,0 Credit,0 Balance ,'' DocRefNo,
				'1900-01-01' CheqorDueDate,18 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , Receipt A (Nolock)
		WHERE
				A.InvRcpNo = T.DocumentNo AND Details = 'Collection-Cash Cancellation'
		Union ALL
		Select 
				'Total Collection-Cash Cancellation' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit, Isnull(Sum(DbAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,19 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Collection-Cash Cancellation'

				/*  Calculate Retailer On Account Details  */
		Union ALl
		Select 
				'Retailer On Account' AS [Description],RtrAccRefNo,ChequeDate  Date,
				DbAmount Debit,0 Credit,0 Balance ,Remarks DocRefNo,
				'1900-01-01' CheqorDueDate,20 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , RetailerOnAccount A (Nolock)
		WHERE
				A.RtrAccRefNo = T.DocumentNo AND Details = 'Retailer On Account'
		Union ALL
		Select 
				'Total Retailer On Account' AS [Description],'' DocRefNo,'1900-01-01'  Date,
				0 Debit,0 Credit, (-1) * Isnull(Sum(CRAmount),0) Balance , '' DocRefNo,
				'1900-01-01' CheqorDueDate,21 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Retailer On Account'

				/*  Calculate Closing Balance Details  */
		UNION ALL
		Select  
				'Closing Balance' [Description], '' DocRefNo,@ToDate Date,
				0 as Debit,0 Credit, 0  Balance,
				'' as TransactionDet,'1900-01-01' CheqorDueDate,22 SeqNo,@Pi_UsrId
		From 
				TempRetailerAccountStatement 
		Where
				Details = 'Closing Balance'	

		DECLARE @ClBal Numeric(18,4)
		Select @ClBal = Sum(Balance)   From  #RptAkzoRetAccStatement 
		Where SeqNo in (1,3,5,7,9,11,13,15,17,19,21)
				
		Update #RptAkzoRetAccStatement Set Balance = @ClBal Where SeqNo = 22
		
	END

	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptAkzoRetAccStatement

	Delete From #RptAkzoRetAccStatement 
	WHere Balance  = 0 and SeqNo  in (3,5,7,9,11,13,15,17,19,21)
	Select * from #RptAkzoRetAccStatement Order by SeqNo,[Description]
END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RptAkzoStockLedgerReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RptAkzoStockLedgerReport]
GO
----  Exec [Proc_RptAkzoStockLedgerReport] 225,2,0,'Loreal',0,0,1
---- select *  from RptProductTrack
---- select * from users
CREATE  PROCEDURE [dbo].[Proc_RptAkzoStockLedgerReport]
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
/***************************************************************************************************
* PROCEDURE : Proc_RptAkzoStockLedgerReport
* PURPOSE   : Product transaction details
* CREATED	: Panneer
* CREATED DATE : 16.03.2011
* NOTE		: General SP For Product transaction details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
---------------------------------------------------------------------------------------------------
* {date}     {developer}  {brief modification description}
***************************************************************************************************/
BEGIN
SET NOCOUNT ON

	DECLARE @NewSnapId   AS INT
	DECLARE @DBNAME		 AS nvarchar(50)
	DECLARE @TblName	 AS nvarchar(500)
	DECLARE @TblStruct   AS nVarchar(4000)
	DECLARE @TblFields   AS nVarchar(4000)
	DECLARE @sSql		 AS nVarChar(4000)
	DECLARE @ErrNo		 AS INT
	DECLARE @PurDBName	 AS nVarChar(50)

	--Filter Variable
	DECLARE @FromDate			AS DATETIME
	DECLARE @ToDate				AS DATETIME
	DECLARE @CmpId				AS Int
	DECLARE @CmpPrdCtgId		AS Int
	DECLARE @PrdCtgMainId		AS Int
	DECLARE @PrdId				AS INT
	DECLARE @PrdCatPrdId        AS  INT
	DECLARE @LcnId				AS INT
	DECLARE @SupZeroStock		AS INT
	DECLARE @ZeroStockRecCount  AS INT
	--Till Here

	--Assgin Value for the Filter Variable
	SET @FromDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate   = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @CmpId    = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId    = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))	
	SET @PrdId    = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @SupZeroStock = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,262,@Pi_UsrId))
 
	EXEC Proc_AkzoProductTrackDetails @Pi_UsrId,@FromDate,@ToDate 

	CREATE TABLE #RptAkzoStockLedgerReport
	(
						TransactionDate		DATETIME,
						TransactionType		NVARCHAR(300),
						TransactionNumber   NVARCHAR(100),
						SalQty				NUMERIC(38,0),
						SalQtyVolume		NUMERIC(38,6),
						UnSalQty			NUMERIC(38,0),
						UnSalQtyVolume		NUMERIC(38,6),
						OfferQty   NUMERIC(38,0),
						OfferQtyVolume   NUMERIC(38,6),
						SlNo    INT,
						PrdId   INT
	)
	SET @TblName = 'RptAkzoStockLedgerReport'
	SET @TblStruct = '	TransactionDate		DATETIME,
						TransactionType		NVARCHAR(300),
						TransactionNumber   NVARCHAR(100),
						SalQty				NUMERIC(38,0),
						SalQtyVolume		NUMERIC(38,6),
						UnSalQty			NUMERIC(38,0),
						UnSalQtyVolume		NUMERIC(38,6),
						OfferQty   NUMERIC(38,0),
						OfferQtyVolume   NUMERIC(38,6),
						SlNo    INT,
						PrdId   INT'

	SET @TblFields = '	TransactionDate,TransactionType,TransactionNumber,SalQty,SalQtyVolume,
						UnSalQty,UnSalQtyVolume,OfferQty,OfferQtyVolume,SlNo,PrdId'

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
			  INSERT INTO #RptAkzoStockLedgerReport (	TransactionDate,TransactionType,TransactionNumber,
														SalQty,SalQtyVolume,UnSalQty,UnSalQtyVolume,
														OfferQty,OfferQtyVolume,SlNo,PrdId)
			  SELECT 
					TransactionDate,TransactionType,TransactionNumber,
					SUM(SalQty),SUM(SalQty * PrdWgt) SalQtyVolume,
					SUM(UnSalQty),SUM(UnSalQty * PrdWgt) UnSalQtyVolume,
					SUM(OfferQty),SUM(OfferQty * PrdWgt) OfferQtyVolume,
					SlNo,A.PrdId
			  FROM 
					RptProductTrack A, Product B
			  WHERE 
					A. PrdId = B.Prdid 
					AND (A.CmpId=  (CASE @CmpId WHEN 0 THEN A.CmpId ELSE 0 END ) OR
							A.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
										
					AND (LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
							LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) )

					 AND (A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId ELSE 0 END) OR
							A.PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) )

					AND  TransactionDate BETWEEN @FromDate AND  @ToDate AND UsrId=@Pi_UsrId

			  GROUP BY 
					TransactionDate,TransactionType,TransactionNumber,SlNo,A.PrdId
			  ORDER BY 
					TransactionDate,SlNo

		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptAkzoStockLedgerReport ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+'  WHERE (CmpId=  (CASE '+CAST(@CmpId AS NVARCHAR(10))+' WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+', 4, '+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND (LcnId = (CASE '+CAST(@LcnId AS NVARCHAR(10))+' WHEN 0 THEN LcnId ELSE 0 END) OR
				LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',22,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND   (LevelId =  (CASE '+CAST(@CmpPrdCtgId AS NVARCHAR(10))+' WHEN 0 THEN LevelId ELSE 0 END ) OR
				LevelId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',21,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND   (LevelValId = (CASE '+CAST(@PrdCtgMainId AS NVARCHAR(10))+' WHEN 0 THEN LevelValId Else 0 END) OR
				LevelValId IN (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',16,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND   (PrdId = (CASE '+CAST(@PrdId AS NVARCHAR(10))+' WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',5,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))'
				+'AND TransactionDate Between '''+CAST(@FromDate AS NVARCHAR(10))+''' and '''+ CAST(@FromDate AS NVARCHAR(10))+''''
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptAkzoStockLedgerReport'
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		END
	END
	ELSE    --To Retrieve Data From Snap Data
	BEGIN
		PRINT @Pi_DbName
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
		@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptAkzoStockLedgerReport ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
			' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
			' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
			' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))
			PRINT @SSQL
			EXEC (@SSQL)
			PRINT 'Retrived Data From Snap Shot Table'
		END
	ELSE
	BEGIN
		--  SET @Po_Errno = 1
		PRINT 'DataBase or Table not Found'
		RETURN
	END
	END

	IF @SupZeroStock = 1
	BEGIN
		DELETE FROM #RptAkzoStockLedgerReport WHERE (SalQty+UnSalQty+OfferQty)=0 AND 
		TransactionType NOT IN ('Opening Stock','Closing Stock') 
	END

	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)

	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptAkzoStockLedgerReport
	PRINT 'Data Executed'
	SELECT * FROM #RptAkzoStockLedgerReport ORDER BY TransactionDate,SlNo ASC 

	RETURN
END
GO 

--SRF-Nanda-218-011

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnRptFiltersValue]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnRptFiltersValue]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
		--->Till Here
		ELSE
		BEGIN
			If @iSelid <> 10 AND @iSelid <> 11  And @iSelid <>66 and @iSelid<>64 AND @iSelid <> 13 AND @iSelid <> 20 
			AND @iSelid <> 102 AND @iSelid <> 103 AND @iSelid <> 105  AND @iSelid <> 108 AND @iSelid <> 115 AND @iSelid <> 117 AND 
			@iSelid <> 119 AND @iSelid <> 126  AND @iSelid <> 139 AND @iSelid <> 140 AND @iSelid <> 152 AND @iSelid <> 157 AND @iSelid <> 158 AND @iSelid <> 161 
			AND @iSelid <> 163 AND @iSelid <> 165 AND @iSelid <> 171  AND @iSelid <> 173 AND @iSelid <> 174 AND @iSelid <> 180 AND @iSelid <> 181
			AND @iSelid <> 195 AND @iSelid <> 199 AND @iSelid <> 201
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
				OR @iSelid = 173 OR @iSelid = 174 OR @iSelid=195 OR @iSelid=201 OR @iSelid = 171
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-218-012

DELETE FROM HotSearchEditorHd WHERE FormId IN (10044,10043)
DELETE FROM HotSearchEditorDt WHERE FormId IN (10044,10043) 

INSERT INTO HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString) 
VALUES('10044','Purchase Order','Product without Supplier Base UOM','select',
'SELECT PrdSeqDtId,PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,UomId,UomDescription,SysQty,UomId2,UomDescription2,OrderQty   
FROM(SELECT Distinct C.PrdSeqDtId,P.PrdId,P.PrdDCode,P.PrdCCode,P.PrdName,P.PrdShrtName,U.UomId,U.UomDescription,  0 as SysQty,U.UomId UomId2,
U.UomDescription UomDescription2,  0 as OrderQty 
FROM Product P, UomMaster U ,   UomGroup UG,ProductSequence B WITH (NOLOCK),    ProductSeqDetails C WITH (NOLOCK),ProductCategoryValue PCV (NOLOCK)     
WHERE P.UomGroupId = UG.UomGroupId  and UG.UomId = U.UomId   and  CmpId = vFParam    and B.TransactionId = 26    AND P.PrdStatus=1 AND P.PrdType <> 3  AND UG.BaseUom=''Y''
AND B.PrdSeqId = C.PrdSeqId   AND P.PrdId = C.PrdId    AND P.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.PrdCtgValLinkCode LIKE ''vSParam%''     
Union      
SELECT Distinct 100000 AS PrdSeqDtId,P.PrdId,P.PrdDCode,P.PrdCCode,P.PrdName,P.PrdShrtName,U.UomId,U.UomDescription,0 as SysQty,U.UomId UomId2,  
U.UomDescription UomDescription2,0 as OrderQty    FROM Product P, UomMaster U , UomGroup UG,  ProductCategoryValue PCV (NOLOCK)   
WHERE P.UomGroupId = UG.UomGroupId  and UG.UomId = U.UomId     and  CmpId = vFParam   and PrdStatus = 1 and PrdType<> 3 AND UG.BaseUom=''Y''
and PrdId NOT IN  ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),    ProductSeqDetails C WITH (NOLOCK) WHERE B.TransactionId=26 
AND B.PrdSeqId=C.PrdSeqId)      AND P.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.PrdCtgValLinkCode LIKE ''vSParam%'') a  ORDER BY PrdSeqDtId'
)

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('1','10044','Product without Supplier','Dist Code','PrdDCode','1500','0','HotSch-26-2000-20','26')
INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('2','10044','Product without Supplier','Comp Code','PrdCCode','1500','0','HotSch-26-2000-21','26')
INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('3','10044','Product without Supplier','Name','PrdName','3000','0','HotSch-26-2000-22','26')
INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('5','10044','Product without Supplier','UOM','UomDescription','1500','0','HotSch-26-2000-34','26')
INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('4','10044','Product without Supplier','Short Name','PrdShrtName','2000','0','HotSch-26-2000-33','26')


INSERT INTO HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString) 
VALUES('10043','Purchase Order','Product with Supplier Base UOM','select',
'SELECT PrdSeqDtId,PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,UomId,UomDescription,SysQty,UomId2,UomDescription2,OrderQty   
FROM(  SELECT Distinct C.PrdSeqDtId, P.PrdId,P.PrdDCode,P.PrdCCode,P.PrdName,P.PrdShrtName,U.UomId,U.UomDescription,0 as SysQty,  
U.UomId UomId2,U.UomDescription UomDescription2,  0 as OrderQty FROM Product P, UomMaster U , UomGroup UG,  ProductSequence B WITH (NOLOCK),    
ProductSeqDetails C WITH (NOLOCK),ProductCategoryValue PCV (NOLOCK)     
WHERE P.UomGroupId = UG.UomGroupId  and UG.UomId = U.UomId   and  CmpId = vFParam and SpmId =vSParam  AND UG.BaseUom=''Y''     
and B.TransactionId = 26  AND P.PrdStatus=1 AND P.PrdType <> 3 AND B.PrdSeqId = C.PrdSeqId     
AND P.PrdId = C.PrdId  AND P.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.PrdCtgValLinkCode LIKE ''vTParam%''      
Union      
SELECT Distinct 100000 AS PrdSeqDtId,P.PrdId,P.PrdDCode,P.PrdCCode,P.PrdName,P.PrdShrtName,U.UomId,U.UomDescription,0 as SysQty,  
U.UomId UomId2,U.UomDescription UomDescription2,0 as OrderQty    FROM Product P, UomMaster U , UomGroup UG,  ProductCategoryValue PCV (NOLOCK)   
WHERE P.UomGroupId = UG.UomGroupId  and UG.UomId = U.UomId   AND UG.BaseUom=''Y'' and  CmpId = vFParam and SpmId =vSParam    and PrdStatus = 1 and PrdType<> 3 
and PrdId   NOT IN  ( SELECT PrdId FROM ProductSequence B WITH (NOLOCK),  ProductSeqDetails C WITH (NOLOCK)   
WHERE B.TransactionId=26 AND B.PrdSeqId=C.PrdSeqId)    AND P.PrdCtgValMainId=PCV.PrdCtgValMainId   
AND PCV.PrdCtgValLinkCode LIKE ''vTParam%'') a  ORDER BY PrdSeqDtId')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('1','10043','Product with Supplier','Dist Code','PrdDCode','1500','0','HotSch-26-2000-17','26')
INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('2','10043','Product with Supplier','Comp Code','PrdCCode','1500','0','HotSch-26-2000-18','26')
INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('3','10043','Product with Supplier','Name','PrdName','3000','0','HotSch-26-2000-19','26')
INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('5','10043','Product with Supplier','UOM','UomDescription','1500','0','HotSch-26-2000-32','26')
INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('4','10043','Product with Supplier','Short Name','PrdShrtName','2000','0','HotSch-26-2000-31','26')

--SRF-Nanda-218-013

IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_RptCurrentStockAN' AND Xtype='P')
DROP procedure [Proc_RptCurrentStockAN] 
GO
-- EXEC [Proc_RptCurrentStockAN] 221,2,0,'PARLEFRESHDB',0,0,1,0
CREATE PROC [dbo].[Proc_RptCurrentStockAN]
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
BEGIN
-- =============================================
-- Author:		R.Vasantharaj
-- Create date: 17/03/2011
-- Description:	Current Stock Report
-- =============================================
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
	DECLARE @PrdCatId  AS Int
	DECLARE @PrdBatId        AS Int
	DECLARE @CtgValue      AS Int
	DECLARE @PrdCatValId      AS Int
	DECLARE @DisplayLevel       AS Int
	DECLARE @PrdId        AS Int
	DECLARE @SupZeroStock	AS INT
	DECLARE @StockType	AS INT
	            
	--Till Here
	--Assgin Value for the Filter Variable
    SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @StockType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))
    SET @CtgValue=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
    SET @PrdCatValId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
    SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @DisplayLevel = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,260,@Pi_UsrId))
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
    --SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(221,260,2)
    EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
--    select @CtgValue,@PrdCatValId 
	CREATE TABLE #RPTCURRENTSTOCKAN
	(
		[CmpPrdCtgId]						INT,
		[Product Hierarchy Level Value]     NVARCHAR(200),
		[PrdCtgValMainId]					INT,
		[PrdCtgValCode]						NVARCHAR(300),
		[Description]						NVARCHAR(300),
		[PrdId]								INT,
		[Product Code]						NVARCHAR(200),
		[Product Name]						NVARCHAR(300),
		[LcnId]								INT,
		[Location Name]						NVARCHAR(300),
		[SystemStockType]					TINYINT,
		[Stock Type]						NVARCHAR(100),
		[Quantity Packs]					INT,
		[PrdUnitId]							INT,
		[Quantity In Volume(Unit)]			NUMERIC(18,2),
		[Quantity In Volume(KG)]            NUMERIC(18,2),
		[Quantity In Volume(Litre)]         NUMERIC(18,2),
		[Value]								NUMERIC(18,2)
	)
	SET @TblName = 'RPTCURRENTSTOCK'
	SET @TblStruct = '  [CmpPrdCtgId]						INT,
						[Product Hierarchy Level Value]     NVARCHAR(200),
						[PrdCtgValMainId]					INT,
						[PrdCtgValCode]						NVARCHAR(300),
						[Description]						NVARCHAR(300),
						[PrdId]								INT,
						[Product Code]						NVARCHAR(200),
						[Product Name]						NVARCHAR(300),
						[LcnId]								INT,
						[Location Name]						NVARCHAR(300),
						[SystemStockType]					TINYINT,
						[Stock Type]						NVARCHAR(100),
						[Quantity Packs]					INT,
						[PrdUnitId]							INT,
						[Quantity In Volume(Unit)]			NUMERIC(18,2),
						[Quantity In Volume(KG)]            NUMERIC(18,2),
						[Quantity In Volume(Litre)]         NUMERIC(18,2),
						[Value]								NUMERIC(18,2)'
	SET @TblFields = '[CmpPrdCtgId],[Product Hierarchy Level Value],[PrdCtgValMainId],[PrdCtgValCode],[Description],[PrdId],[Product Code],
					  [Product Name],[LcnId],[Location Name],[SystemStockType],[Stock Type],[Quantity Packs],[PrdUnitId],
					  [Quantity In Volume(Unit)],[Quantity In Volume(KG)],[Quantity In Volume(Litre)],[Value]'
IF @DisplayLevel=2
BEGIN
	INSERT INTO #RPTCURRENTSTOCKAN ([CmpPrdCtgId],[Product Hierarchy Level Value],[PrdCtgValMainId],[PrdCtgValCode],[Description],
									[LcnId],[Location Name],[SystemStockType],[Stock Type],[Quantity Packs],[PrdUnitId],
									[Quantity In Volume(Unit)],[Quantity In Volume(KG)],[Quantity In Volume(Litre)],[Value])
	SELECT DISTINCT G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
	/*F.PrdId,F.PrdCCode,F.PrdName,*/F.LcnId,F.LcnName,F.SystemStockType,F.UserStockType,sum(BaseQty),PrdUnitId,sum(PrdOnUnit),sum(PrdOnKg),
	sum(PrdOnLitre),sum(SumValue)
		FROM ProductCategoryValue C
		INNER JOIN(Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
				A.Prdid from Product A
		INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
			      (A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
			       A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		INNER JOIN 
	              (SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,0 AS BaseQty,
	               B.PrdUnitId,0 AS PrdOnUnit,0 AS PrdOnKg,0 AS PrdOnLitre,0 as SumValue
	               FROM ProductBatchLocation A 
		INNER JOIN Product B ON A.PrdId=B.PrdId 

		INNER JOIN Location C ON A.LcnId=C.LcnId
		INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
		INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
		WHERE B.CmpId=@CmpId AND
		(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
		A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
		(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
		E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)))) F ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 	
		INNER JOIN 
		(SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,
		CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END AS BaseQty,
		B.PrdUnitId,0 AS PrdOnUnit,
		ISNULL(CASE B.PrdUnitId WHEN 2 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
		WHEN 3 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnKg,
		ISNULL(CASE B.PrdUnitId WHEN 4 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
		WHEN 5 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnLitre,
		(CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)* G.SellingRate as SumValue
		FROM ProductBatchLocation A 
		INNER JOIN Product B ON A.PrdId=B.PrdId  
		INNER JOIN Location C ON A.LcnId=C.LcnId
		INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
		INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
		INNER JOIN DefaultPriceHistory G ON A.PrdId=G.PrdId AND G.CurrentDefault=1 AND A.PrdBatId=G.PrdbatId

		WHERE B.CmpId=@CmpId AND
		(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
		A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
		(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
		E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))) GROUP BY 
		A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,B.PrdUnitId,B.PrdWgt,G.SellingRate) F ON D.PrdId=F.PrdId 
		INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
		WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
		ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
		AND --( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR
--		C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
		(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
		G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	   GROUP BY G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
		/*F.PrdId,F.PrdCCode,F.PrdName,*/F.LcnId,F.LcnName,F.SystemStockType,F.UserStockType,PrdUnitId
END
ELSE
BEGIN
	INSERT INTO #RPTCURRENTSTOCKAN
	SELECT DISTINCT G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
	F.PrdId,F.PrdCCode,F.PrdName,F.LcnId,F.LcnName,F.SystemStockType,F.UserStockType,BaseQty,PrdUnitId,PrdOnUnit,PrdOnKg,
	PrdOnLitre,SumValue
		FROM ProductCategoryValue C
		INNER JOIN(Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
				A.Prdid from Product A
		INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
			      (A.PrdId = (CASE @PrdId WHEN 0 THEN A.PrdId Else @PrdId END) OR
			      A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		INNER JOIN 
	              (SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,0 AS BaseQty,
	              B.PrdUnitId,0 AS PrdOnUnit,0 AS PrdOnKg,0 AS PrdOnLitre,0 as SumValue
	              FROM ProductBatchLocation A 
	    INNER JOIN Product B ON A.PrdId=B.PrdId 

		INNER JOIN Location C ON A.LcnId=C.LcnId
		INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
		INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
		WHERE B.CmpId=@CmpId AND
		(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
		A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
		(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
		E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)))) F ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 	
		INNER JOIN 
		(SELECT A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,
		CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END AS BaseQty,
		B.PrdUnitId,0 AS PrdOnUnit,
		ISNULL(CASE B.PrdUnitId WHEN 2 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
		WHEN 3 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnKg,
		ISNULL(CASE B.PrdUnitId WHEN 4 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0)/1000
		WHEN 5 THEN ISNULL((PrdWgt * (CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)),0) END,0) AS PrdOnLitre,
		(CASE E.SystemStockType WHEN 1 THEN SUM(PrdBatLcnSih) WHEN 2 THEN SUM(PrdBatLcnUih) WHEN 3 THEN SUM(PrdBatLcnFre) END)* G.SellingRate as SumValue
		FROM ProductBatchLocation A 
		INNER JOIN Product B ON A.PrdId=B.PrdId  
		INNER JOIN Location C ON A.LcnId=C.LcnId
		INNER JOIN ProductBatch D ON A.PrdBatId=D.PrdBatId AND B.PrdId=D.PrdId
		INNER JOIN STOCKTYPE E ON C.LcnId=E.LcnId
		INNER JOIN DefaultPriceHistory G ON A.PrdId=G.PrdId AND G.CurrentDefault=1 AND A.PrdBatId=G.PrdbatId

		WHERE B.CmpId=@CmpId AND
		(A.LcnId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)) WHEN 0 THEN C.LcnId Else 0 END) OR
		A.LcnId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))) AND 
		(E.SystemStockType = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId)) WHEN 0 THEN E.SystemStockType Else 0 END) OR
		E.SystemStockType in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))) GROUP BY 
		A.PrdId,B.PrdCCode,B.PrdName,C.LcnId,C.LcnName,E.SystemStockType,E.UserStockType,B.PrdUnitId,B.PrdWgt,G.SellingRate) F ON D.PrdId=F.PrdId 
		INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
		WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
		ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
		AND --( C.PrdCtgValMainId= CASE @PrdCatValId WHEN 0 THEN C.PrdCtgValMainId ELSE @PrdCatValId END OR
--		C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
		(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
		G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))

END

--      Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId	
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RPTCURRENTSTOCKAN
--	 Till Here

IF @SupZeroStock=1
	BEGIN 
		SELECT  * FROM #RPTCURRENTSTOCKAN WHERE [Quantity Packs]<>0 
    END
	ELSE
		SELECT * FROM #RPTCURRENTSTOCKAN 

    END
GO

if not exists (select * from hotfixlog where fixid = 367)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(367,'D','2011-03-25',getdate(),1,'Core Stocky Service Pack 367')
