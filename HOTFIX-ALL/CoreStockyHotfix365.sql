--[Stocky HotFix Version]=365
Delete from Versioncontrol where Hotfixid='365'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('365','2.0.0.5','D','2011-03-19','2011-03-19','2011-03-19',convert(varchar(11),getdate()),'Parle;Major:-Akso Nobel and Henkel CRs;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 365' ,'365'
GO

--SRF-Nanda-213-001

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptCurrentStockAN]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptCurrentStockAN]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

--EXEC [Proc_RptCurrentStockAN] 221,2,0,'PARLEFRESHDB',0,0,1,0

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

	INSERT INTO #RPTCURRENTSTOCKAN
	SELECT DISTINCT G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
	F.PrdId,F.PrdCCode,F.PrdName,F.LcnId,F.LcnName,F.SystemStockType,F.UserStockType,BaseQty,PrdUnitId,PrdOnUnit,PrdOnKg,
	PrdOnLitre,SumValue
		FROM ProductCategoryValue C
		INNER JOIN 
			(Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
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
	BEGIN 
		SELECT * FROM #RPTCURRENTSTOCKAN 
	END

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-213-002

IF NOT EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='Temp_SalesReturnSubReport')
BEGIN
	CREATE TABLE Temp_SalesReturnSubReport
	(
		LvlId		INT,
		LvlCode		VARCHAR(200),
		LvlName		VARCHAR(200),
		BaseQty		NUMERIC(18,0),
		Tone		NUMERIC(18,6),
		Amount		NUMERIC(18,6)
	)
END
GO

--SRF-Nanda-213-003

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_AkzoProductTrackDetails')
DROP PROCEDURE Proc_AkzoProductTrackDetails
GO 

----  exec [Proc_ProductTrackDetails] 5,'2010-09-15','2010-09-15'

CREATE PROCEDURE [dbo].[Proc_AkzoProductTrackDetails]
(
	 @Pi_UsrId INT,
	 @Pi_FromDate DATETIME,
	 @Pi_ToDate DATETIME
)
AS
/***************************************************************************************************
* PROCEDURE	: Proc_AkzoProductTrackDetails
* PURPOSE	: To Return the Product transaction details
* CREATED	: Panneer
* CREATED DATE	: 16.03.2011
* NOTE		: General SP For Generate Product transaction details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-----------------------------------------------------------------------------------------------------
* {date}		{developer}		{brief modification description}
***************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @PrdId	AS INT
	SET @PrdId = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(225,5,@Pi_UsrId))
	SELECT	TransDate,A.PrdId,A.PrdBatId,ISNULL(LcnId,0) AS LcnId,
			SUM(SalOpenStock) SalOpenStock,SUM(UnSalOpenStock) UnSalOpenStock,
			SUM(OfferOpenStock) OfferOpenStock INTO #OpenStk 
	FROM StockLedger A,
	(
		SELECT MAX(TransDate) AS MaxDate,PrdId,PrdBatId  FROM StockLedger WHERE TransDate <= @Pi_FromDate 
		AND PrdId=@PrdId GROUP BY PrdId,PrdBatId
	) B
	WHERE A.TransDate=B.MaxDate AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
	AND A.PrdId=@PrdId AND B.PrdId=@PrdId
	GROUP BY TransDate,A.PrdId,A.PrdBatId,LcnId
		
	SELECT TransDate,A.PrdId,A.PrdBatId,LcnId,SUM(SalClsStock) SalClsStock,SUM(UnSalClsStock) UnSalClsStock,
	SUM(OfferClsStock) OfferClsStock  INTO #CloseStk FROM StockLedger A ,
	(		SELECT MAX(TransDate) MaxDate,PrdId,PrdBatId FROM StockLedger WHERE TransDate <= @Pi_ToDate AND PrdId=@PrdId
			GROUP BY  PrdId,PrdBatId 
	) B 
	WHERE A.TransDate=B.MaxDate AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
	AND A.PrdId=@PrdId AND B.PrdId=@PrdId
	GROUP BY TransDate,A.PrdId,A.PrdBatId,LcnId

	TRUNCATE TABLE  RptProductTrack 
	INSERT INTO RptProductTrack(LevelValId,LevelValName,LevelId,LevelName,CmpId,CmpName,PrdId,
	PrdName,PrdBatId,PrdBatCode,SalQty,UnSalQty,OfferQty,TransactionType,
	TransactionNumber,TransactionDate,UsrId,SlNo,LcnId)
	--Opening Stock
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		ISNULL(O.SalOpenStock,0),ISNULL(O.UnSalOpenStock,0),
		ISNULL(O.OfferOpenStock,0),
		'Opening Stock' ,'',@Pi_FromDate ,@Pi_UsrId,1,ISNULL(O.LcnId,0)
		FROM
		PrdHirarchy PH
		LEFT OUTER JOIN #OpenStk O ON PH.PrdId = O.PrdId AND PH.PrdBatId = O.PrdBatId
		AND PH.PrdId=@PrdId
	UNION ALL
	--Stock Mng (In)		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TotalQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TotalQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TotalQty ELSE 0 END ) AS OfferStock,
		'Stock Management - Add',M.StkMngRefNo,M.StkMngDate,@Pi_UsrId,2,S.LcnId
		FROM
		StockManagement M
		INNER JOIN StockManagementProduct D ON M.StkMngRefNo = D.StkMngRefNo
--		INNER JOIN StockManagementType SMT ON SMT.StkMgmtTypeId=M.StkMgmtTypeId AND SMT.TransactionType=0
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND M.StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
		and D.StkMgmtTypeId = 1
	UNION ALL
	--Stock Mng (Out)	
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.TotalQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.TotalQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.TotalQty ELSE 0 END ) AS OfferStock,
		'Stock Management - Reduce' ,M.StkMngRefNo,M.StkMngDate,@Pi_UsrId,3,S.LcnId
		FROM
		StockManagement M
		INNER JOIN StockManagementProduct D ON M.StkMngRefNo = D.StkMngRefNo
--		INNER JOIN StockManagementType SMT ON SMT.StkMgmtTypeId=M.StkMgmtTypeId AND SMT.TransactionType=1
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND  M.StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
		and D.StkMgmtTypeId = 2
	UNION ALL
	--Lcn Trans
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.TransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.TransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.TransferQty ELSE 0 END ) AS OfferStock,
		'Location Transfer Out' ,M.LcnRefNo,M.LcnTrfDate,@Pi_UsrId,4,M.FromLcnId
		FROM
		LocationTransferMaster M
		INNER JOIN LocationTransferDetails D ON M.LcnRefNo = D.LcnRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.LcnTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Lcn Trans
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransferQty ELSE 0 END ) AS OfferStock,
		'Location Transfer In' ,M.LcnRefNo,M.LcnTrfDate,@Pi_UsrId,5,M.ToLcnId
		FROM
		LocationTransferMaster M
		INNER JOIN LocationTransferDetails D ON M.LcnRefNo = D.LcnRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.LcnTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	-- Bat Tran (In)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*T.TrfQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*T.TrfQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*T.TrfQty ELSE 0 END ) AS OfferStock,
		'Batch Transfer Out',T.BatRefNo,T.BatTrfDate,@Pi_UsrId,6,S.LcnId
		FROM
		BatchTransfer T INNER JOIN StockType S On T.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.FromBatId = PH.PrdBatId
		WHERE T.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
--	UNION ALL
----	--- Bat Trans In (New)
----	SELECT
----		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
----		PH.CmpPrdCtgName,
----		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
----		(CASE S.SystemStockType WHEN 1 THEN (-1)*T.TransferQty ELSE 0 END ) AS SalStock,
----		(CASE S.SystemStockType WHEN 2 THEN (-1)*T.TransferQty ELSE 0 END ) AS UnSalStock,
----		(CASE S.SystemStockType WHEN 3 THEN (-1)*T.TransferQty ELSE 0 END ) AS OfferStock,
----		'Batch Transfer Out',T.BatRefNo,A.BatTrfDate,@Pi_UsrId,6,S.LcnId
----		FROM
----			BatchTransferHD A 
----			INNER JOIN BatchTransferDT T ON A.BatRefNo = T.BatRefNo
----			INNER JOIN StockType S On T.StockType = S.StockTypeId
----			INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.FrmBatId = PH.PrdBatId
----		WHERE A.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	-- Bat Tran (Out)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN T.TrfQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN T.TrfQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN T.TrfQty ELSE 0 END ) AS OfferStock,
		'Batch Transfer In',T.BatRefNo,T.BatTrfDate,@Pi_UsrId,7,S.LcnId
		FROM
		BatchTransfer T INNER JOIN StockType S On T.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.ToBatId = PH.PrdBatId
		WHERE T.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
--	UNION ALL 
--	-- New Bat Tran (Out)
--	SELECT
--		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
--		PH.CmpPrdCtgName,
--		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
--		(CASE S.SystemStockType WHEN 1 THEN T.TransferQty ELSE 0 END ) AS SalStock,
--		(CASE S.SystemStockType WHEN 2 THEN T.TransferQty ELSE 0 END ) AS UnSalStock,
--		(CASE S.SystemStockType WHEN 3 THEN T.TransferQty ELSE 0 END ) AS OfferStock,
--		'Batch Transfer In',T.BatRefNo,A.BatTrfDate,@Pi_UsrId,7,S.LcnId
--		FROM
--			BatchTransferHD A 
--			INNER JOIN BatchTransferDT T ON A.BatRefNo = T.BatRefNo
--			INNER JOIN StockType S On T.StockType = S.StockTypeId
--			INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.ToBatId = PH.PrdBatId
--		WHERE A.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL 
	--Salvage
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.SalvageQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.SalvageQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.SalvageQty ELSE 0 END ) AS OfferStock,
		'Salvage' TransType ,M.SalvageRefNo,M.SalvageDate,@Pi_UsrId,8,S.LcnId
		FROM
		Salvage M
		INNER JOIN SalvageProduct D ON M.SalvageRefNo = D.SalvageRefNo
		INNER JOIN StockType S ON M.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND M.SalvageDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Stock journal (Out)		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS OfferStock,
		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
		FROM
		StockJournal M
		INNER JOIN StockJournalDt D ON M.StkJournalRefNo = D.StkJournalRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON M.PrdId = PH.PrdId AND M.PrdBatId = PH.PrdBatId
		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
--	--  SJ New Out
--	UNION ALL 
--	SELECT
--		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
--		PH.CmpPrdCtgName,
--		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
--		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS SalStock,
--		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS UnSalStock,
--		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS OfferStock,
--		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
--		FROM
--		StockJournalHD M
--		INNER JOIN StockJournalDet D ON M.StkJournalRefNo = D.StkJournalRefNo
--		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
--		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
--		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	--Stock journal(In)	
	UNION ALL	
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.StkTransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.StkTransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.StkTransferQty ELSE 0 END ) AS OfferStock,
		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
		FROM
		StockJournal M
		INNER JOIN StockJournalDt D ON M.StkJournalRefNo = D.StkJournalRefNo
		INNER JOIN StockType S ON D.TransferStkTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON M.PrdId = PH.PrdId AND M.PrdBatId = PH.PrdBatId
		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
--	--  SJ New IN
--	UNION ALL	
--	SELECT
--		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
--		PH.CmpPrdCtgName,
--		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
--		(CASE S.SystemStockType WHEN 1 THEN D.StkTransferQty ELSE 0 END ) AS SalStock,
--		(CASE S.SystemStockType WHEN 2 THEN D.StkTransferQty ELSE 0 END ) AS UnSalStock,
--		(CASE S.SystemStockType WHEN 3 THEN D.StkTransferQty ELSE 0 END ) AS OfferStock,
--		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
--		FROM
--		StockJournalHD M
--		INNER JOIN StockJournalDet D ON M.StkJournalRefNo = D.StkJournalRefNo
--		INNER JOIN StockType S ON D.TransferStkTypeId = S.StockTypeId
--		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
--		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Ret to cmp
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS OfferStock,
		'Return To Company' TransType ,
		M.RtnCmpRefNo TransNo,M.RtnCmpDate TransDate,@Pi_UsrId,11,S.LcnId
		FROM
		ReturnToCompany M
		INNER JOIN ReturnToCompanyDt D ON M.RtnCmpRefNo = D.RtnCmpRefNo
		INNER JOIN StockType S ON M.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RtnCmpDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
		AND M.Status=1
	UNION ALL
	--Ret and replacement
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.RtnQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.RtnQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.RtnQty ELSE 0 END ) AS OfferStock,
		'Return and Replacement - Return',M.RepRefNo,M.RepDate,@Pi_UsrId,12,S.LcnId
		FROM
		ReplacementHd M
		INNER JOIN ReplacementIn D ON M.RepRefNo = D.RepRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Ret and replacement(Out)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.RepQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.RepQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.RepQty ELSE 0 END ) AS OfferStock,
		'Return and Replacement - Replacement',M.RepRefNo,M.RepDate,@Pi_UsrId,13,S.LcnId
		FROM
		ReplacementHd M
		INNER JOIN ReplacementOut D ON M.RepRefNo = D.RepRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	--Resell Damage Goods
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,(-1)*D.Quantity,0,
		'Resell Damage Goods',M.ReDamRefNo,M.ReSellDate,@Pi_UsrId,14,M.LcnId
		FROM
		ReSellDamageMaster M
		INNER JOIN ReSellDamageDetails D ON M.ReDamRefNo = D.ReDamRefNo
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.ReSellDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
		AND M.Status=1
	UNION ALL
	--VanLoad&Unload
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransQty ELSE 0 END ) AS OfferStock,
		'Van Load',M.VanLoadRefNo,M.TransferDate,@Pi_UsrId,15,S.LcnId
		FROM
		VanLoadUnloadMaster M
		INNER JOIN VanLoadUnloadDetails D ON M.VanLoadRefNo = D.VanLoadRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.VanLoadUnload = 0 AND M.TransferDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL 
	--VanLoad&Unload (Unload)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransQty ELSE 0 END ) AS OfferStock,
		'Van Unload',M.VanLoadRefNo,M.TransferDate,@Pi_UsrId,16,S.LcnId
		FROM
		VanLoadUnloadMaster M
		INNER JOIN VanLoadUnloadDetails D ON M.VanLoadRefNo = D.VanLoadRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.VanLoadUnload = 1 AND M.TransferDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL
	-- Sales		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(-1)*D.BaseQty,0,0,
		'Sales',M.SalInvNo,M.SalInvDate,@Pi_UsrId,17,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN  SalesInvoiceProduct D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
		AND M.DlvSts IN (1,2,4,5) AND PH.PrdId=@PrdId
	UNION ALL
	-- Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.FreeQty,
		'Sales Free',M.SalInvNo,M.SalInvDate,@Pi_UsrId,18,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN SalesInvoiceSchemeDtFreePrd D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.FreePrdId = PH.PrdId AND D.FreePrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (1,2,4,5) AND PH.PrdId=@PrdId
	UNION ALL
	-- Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.SalManFreeQty,
		'Sales Free',M.SalInvNo,M.SalInvDate,@Pi_UsrId,19,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN  SalesInvoiceProduct D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (1,2,4,5) AND PH.PrdId=@PrdId
	UNION ALL
	-- Gift
	SELECT 		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.GiftQty,
		'Sales Gift',M.SalInvNo,M.SalInvDate,@Pi_UsrId,20,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN SalesInvoiceSchemeDtFreePrd D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.GiftPrdId = PH.PrdId AND D.GiftPrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (1,2,4,5) AND PH.PrdId=@PrdId
	UNION ALL
	--Pur (sal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		D.RcvdGoodBaseQty,0,0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,21,M.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	--Pur (unsal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,E.BaseQty,0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,22,S.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PurchaseReceiptBreakup E ON E.PurRcptId = D.PurRcptId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=1
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	--Pur (Excess)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*E.BaseQty ELSE 0 END),
		(CASE S.SystemStockType WHEN 2 THEN (-1)*E.BaseQty ELSE 0 END),0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,23,S.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PurchaseReceiptBreakup E ON E.PurRcptId = D.PurRcptId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=2
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND D.RefuseSale=1 AND PH.PrdId=@PrdId
	UNION ALL
	-- pur Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.Quantity,
		'Purchase Free',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,24,M.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptClaimScheme D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND D.TypeId=2 AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	-- Pur ret (sal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(-1)*D.RetSalBaseQty,0,0,
		'Purchase Return',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,25,M.LcnId
		FROM PurchaseReturn M INNER JOIN PurchaseReturnProduct D ON M.PurRetId = D.PurRetId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	-- Pur ret (unsal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,(-1)*E.ReturnBsQty,0,
		'Purchase Return',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,26,S.LcnId
		FROM
		PurchaseReturn M
		INNER JOIN PurchaseReturnProduct D ON M.PurRetId = D.PurRetId
		INNER JOIN PurchaseReturnBreakup E ON E.PurRetId = D.PurRetId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=1
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	-- Pur Ret Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.RetQty,
		'Purchase Return Free',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,27,M.LcnId
		FROM
		PurchaseReturn M
		INNER JOIN PurchaseReturnClaimScheme D ON M.PurRetId = D.PurRetId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND D.TypeId=2 AND M.Status=1	AND PH.PrdId=@PrdId	 
	UNION ALL
	-- Sales Ret
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE ST.SystemStockType WHEN 1 THEN D.BaseQty ELSE 0 END ) AS SalStock,
		(CASE ST.SystemStockType WHEN 2 THEN D.BaseQty ELSE 0 END ) AS UnSalStock,
		(CASE ST.SystemStockType WHEN 3 THEN D.BaseQty ELSE 0 END ) AS OfferStock,
		'Sales Return',M.ReturnCode,M.ReturnDate,@Pi_UsrId,28,ST.LcnId
		FROM ReturnHeader M
		INNER JOIN ReturnProduct D ON M.Returnid = D.ReturnId
		INNER JOIN StockType ST ON D.StockTypeId = ST.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=0 AND PH.PrdId=@PrdId
	UNION ALL
	--Sample Receipt
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.RcvdGoodBaseQty,
		'Sample Receipt',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,29,M.LcnId
		FROM
		SamplePurchaseReceipt M
		INNER JOIN SamplePurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	--Sample Issue		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.IssueBaseQty,
		'Sample Issue',M.IssueRefNo,M.IssueDate,@Pi_UsrId,30,M.LcnId
		FROM
		SampleIssueHd M
		INNER JOIN  SampleIssueDt D ON M.IssueId = D.IssueId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.IssueDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND PH.PrdId=@PrdId
	UNION ALL
	--Sample Return		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.ReturnBaseQty,
		'Sample Return',M.ReturnRefNo,M.ReturnDate,@Pi_UsrId,31,M.LcnId
		FROM
		SampleReturnHd M
		INNER JOIN  SampleReturnDt D ON M.ReturnId = D.ReturnId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1	 AND PH.PrdId=@PrdId
	--- added by Panneer
	----Sample Issue Free	
	UNION ALL
		SELECT
			PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
			PH.CmpPrdCtgName,
			PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
			0,0,(-1)*D.IssueBaseQty,
			'Sample Issue',M.IssueRefNo,M.IssueDate,@Pi_UsrId,30,M.LcnId
		FROM
			FreeIssueHd M
			INNER JOIN FreeIssueDt D ON M.IssueId = D.IssueId
			INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE
			M.IssueDate BETWEEN @Pi_FromDate AND @Pi_ToDate
			AND M.Status=1 AND PH.PrdId=@PrdId
----	UNION ALL
----	--IDT (In)		
----	SELECT
----		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
----		PH.CmpPrdCtgName,
----		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
----		D.Qty AS SalStock,
----		0 AS UnSalStock,
----		0 AS OfferStock,
----		'IDT - IN',M.IDTMngRefNo,M.IDTMngDate,@Pi_UsrId,2,M.LcnId
----		FROM
----		IDTManagement M
----		INNER JOIN IDTManagementProduct D ON M.IDTMngRefNo = D.IDTMngRefNo AND StkMgmtTypeId=1
----		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
----		WHERE M.Status=1 AND M.IDTMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
----	UNION ALL
----	--IDT  (Out)	
----	SELECT
----		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
----		PH.CmpPrdCtgName,
----		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
----		(-1)*D.Qty AS SalStock,
----		0 AS UnSalStock,
----		0 AS OfferStock,
----		'IDT -OUT ' ,M.IDTMngRefNo,M.IDTMngDate,@Pi_UsrId,3,M.LcnId
----		FROM
----		IDTManagement M
----		INNER JOIN IDTManagementProduct D ON M.IDTMngRefNo = D.IDTMngRefNo AND StkMgmtTypeId=2
----		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
----		WHERE M.Status=1 AND M.IDTMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND PH.PrdId=@PrdId
	UNION ALL --Closing Stock
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		ISNULL(C.SalClsStock,0),
		ISNULL(C.UnSalClsStock,0),ISNULL(C.OfferClsStock,0),
		'Closing Stock' ,'',@Pi_ToDate ,@Pi_UsrId,32,ISNULL(C.LcnId,0)
		FROM
		PrdHirarchy PH
		LEFT OUTER JOIN #CloseStk C ON PH.PrdId = C.PrdId AND PH.PrdBatId = C.PrdBatId AND PH.PrdId=@PrdId
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
	select * from #RptRtrPrdWiseSales 
RETURN
END
GO

--SRF-Nanda-213-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_SchemePayout]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_SchemePayout]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_SchemePayout
EXEC Proc_Cn2Cs_SchemePayout 0
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_SchemePayout]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_SchemePayout
* PURPOSE		: To Download the Scheme Payout details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 10/11/2010
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
	DECLARE @CrDbNoteDate		DATETIME
	DECLARE @DebitNo			NVARCHAR(500)
	DECLARE @CreditNo			NVARCHAR(500)
	DECLARE @CoaId				INT
	DECLARE @VocNo				NVARCHAR(500)
	DECLARE @CmpSchCode			NVARCHAR(200)
	DECLARE @CmpRtrCode			NVARCHAR(200)
	DECLARE @CrDbType			NVARCHAR(200)
	DECLARE @CrDbNoteNo			NVARCHAR(200)
	DECLARE @CrDbDate			DATETIME
	DECLARE @CrDbAmt			NUMERIC(38,6)
	DECLARE @ResField1			NVARCHAR(200)
	DECLARE @ResField2			NVARCHAR(200)
	DECLARE @ResField3			NVARCHAR(200)
	DECLARE @RtrId				INT
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SchPayToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE SchPayToAvoid	
	END
	CREATE TABLE SchPayToAvoid
	(
		CmpSchCode	 NVARCHAR(50),
		CmpRtrCode	 NVARCHAR(50)
	)
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout WHERE ISNULL(CmpSchCode,'')='')
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout
		WHERE ISNULL(CmpSchCode,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','CmpSchCode','Company Scheme Code should not be empty for :'+CmpRtrCode
		FROM Cn2Cs_Prk_SchemePayout WHERE ISNULL(CmpSchCode,'')=''
	END
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout WHERE ISNULL(CmpRtrCode,'')='')
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout
		WHERE ISNULL(CmpRtrCode,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','CmpRtrCode','Company Retailer Code should not be empty for :'+CmpSchCode
		FROM Cn2Cs_Prk_SchemePayout WHERE ISNULL(CmpRtrCode,'')=''
	END
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout WHERE CrDbAmt<0)
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout
		WHERE CrDbAmt>0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','Amount','Amount should be greater than zero for :'+CmpSchCode
		FROM Cn2Cs_Prk_SchemePayout
		WHERE CrDbAmt>0
	END
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout
	WHERE ISNULL(CrDbDate,'')='')
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout
		WHERE ISNULL(CrDbDate,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','Date','Date should not be empty for :'+CmpSchCode
		FROM Cn2Cs_Prk_SchemePayout
		WHERE ISNULL(CrDbDate,'')=''
	END	
	IF EXISTS(SELECT CmpSchCode FROM Cn2Cs_Prk_SchemePayout
	WHERE CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer))
	BEGIN
		INSERT INTO SchPayToAvoid(CmpSchCode,CmpRtrCode)
		SELECT CmpSchCode,CmpRtrCode FROM Cn2Cs_Prk_SchemePayout WHERE
		CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Payout','Retailer','Retailer:'+CmpRtrCode+' for Scheme:'+CmpSchCode
		FROM Cn2Cs_Prk_SchemePayout WHERE CmpRtrCode NOT IN (SELECT CmpRtrCode FROM Retailer)
	END
	SET @CrDbNoteDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	DECLARE Cur_SchemePayout CURSOR	
	FOR SELECT  ISNULL([CmpSchCode],''),ISNULL([CmpRtrCode],''),ISNULL([CrDbType],''),ISNULL([CrDbNoteNo],'0'),
	CONVERT(NVARCHAR(10),[CrDbDate],121),CAST(ISNULL([CrDbAmt],0)AS NUMERIC(38,6)),
	ISNULL([ResField1],''),ISNULL([ResField2],''),ISNULL([ResField3],'')
	FROM Cn2Cs_Prk_SchemePayout WHERE DownloadFlag='D' AND CmpSchCode+'~'+CmpRtrCode NOT IN
	(SELECT CmpSchCode+'~'+CmpRtrCode FROM SchPayToAvoid)	
	OPEN Cur_SchemePayout
	FETCH NEXT FROM Cur_SchemePayout INTO @CmpSchCode,@CmpRtrCode,@CrDbType,@CrDbNoteNo,@CrDbDate,@CrDbAmt,@ResField1,@ResField2,@ResField3
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo=0
		SET @ErrStatus=1
		SELECT @RtrId=RtrId FROM Retailer WHERE CmpRtrCode=@CmpRtrCode
		SELECT @CoaId=CoaId FROM ClaimGroupMaster WHERE ClmGrpId=17
		
		IF @CrDbType='Credit'
		BEGIN
			SELECT @CreditNo=dbo.Fn_GetPrimaryKeyString('CreditNoteRetailer','CrNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			
			INSERT INTO CreditNoteRetailer(CrNoteNumber,CrNoteDate,RtrId,CoaId,ReasonId,Amount,CrAdjAmount,Status,
			PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
			VALUES(@CreditNo,@CrDbNoteDate,@RtrId,@CoaId,9,@CrDbAmt,0,1,18,18,
			@CmpSchCode,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'Payout for Scheme:'+@CmpSchCode)
			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'CreditNoteRetailer' AND Fldname = 'CrNoteNumber'
			EXEC Proc_VoucherPosting 18,1,@CreditNo,3,6,1,@CrDbNoteDate,@Po_ErrNo=@ErrStatus OUTPUT
			IF @ErrStatus<>1
			BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Credit Note Voucher Posting Failed for Scheme Ref No:' + @CmpSchCode
				INSERT INTO Errorlog
				VALUES (9,'Scheme Payout','Credit Note Voucher Posting',@ErrDesc)
			END
--			IF @Po_ErrNo=0
--			BEGIN
--				SELECT @VocNo=MAX(VocRefNo) FROM StdVocMaster (NOLOCK) WHERE VocType=3 AND VocSubType=6
--				AND LastModDate= CONVERT(NVARCHAR(10),GETDATE(),121)
--
--				IF DATEDIFF(D,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),CONVERT(NVARCHAR(10),GETDATE(),121))>0
--				BEGIN
--					EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
--				END
--			END
			UPDATE Cn2Cs_Prk_SchemePayout SET DownLoadFlag='Y' WHERE CmpSchCode=@CmpSchCode AND CmpRtrCode=@CmpRtrCode
		END					
		ELSE IF @CrDbType='Debit'
		BEGIN
			SELECT @DebitNo=dbo.Fn_GetPrimaryKeyString('DebitNoteRetailer','DbNoteNumber',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			INSERT INTO DebitNoteRetailer(DbNoteNumber,DbNoteDate,RtrId,CoaId,ReasonId,Amount,DbAdjAmount,Status,
			PostedFrom,TransId,PostedRefNo,Availability,LastModBy,LastModDate,AuthId,AuthDate,Remarks)
			VALUES(@DebitNo,@CrDbNoteDate,@RtrId,@CoaId,9,@CrDbAmt,0,1,19,19,
			@CmpSchCode,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),'Payout for Scheme:'+@CmpSchCode)
			UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'DebitNoteRetailer' AND Fldname = 'DbNoteNumber'
		
			EXEC Proc_VoucherPosting 19,1,@DebitNo,3,7,1,@CrDbNoteDate,@Po_ErrNo= @ErrStatus OUTPUT
			
			IF @ErrStatus<>1
			BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Debit Note Voucher Posting Failed'
				INSERT INTO Errorlog VALUES (10,'Scheme Payout','Debit Note Voucher Posting',@ErrDesc)
			END
	
--			IF @Po_ErrNo=0
--			BEGIN
--				SELECT @VocNo=MAX(VocRefNo) FROM StdVocMaster (NOLOCK) WHERE VocType=3 AND VocSubType=7
--				AND LastModDate= CONVERT(NVARCHAR(10),GETDATE(),121)
--
--				IF DATEDIFF(D,CONVERT(NVARCHAR(10),@CrDbNoteDate,121),CONVERT(NVARCHAR(10),GETDATE(),121))>0
--				BEGIN
--					EXEC Proc_PostVoucherCounterReset 'StdVocMaster','JournalVoc',@VocNo,@CrDbNoteDate,''
--				END
--			END
			UPDATE Cn2Cs_Prk_SchemePayout SET DownLoadFlag='Y' WHERE CmpSchCode=@CmpSchCode AND CmpRtrCode=@CmpRtrCode
		END	
		FETCH NEXT FROM Cur_SchemePayout INTO @CmpSchCode,@CmpRtrCode,@CrDbType,@CrDbNoteNo,@CrDbDate,@CrDbAmt,@ResField1,@ResField2,@ResField3
	END
	CLOSE Cur_SchemePayout
	DEALLOCATE Cur_SchemePayout
	SET @Po_ErrNo=0
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-213-005

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_VoucherPostingPurchase]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_VoucherPostingPurchase]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_VoucherPostingPurchase 5,1,'GRN100000003',5,0,2,'2011-03-17',0
SELECT * FROM StdVocMaster(NOLOCK) WHERE VocRefNo='PUR1000007'
SELECT * FROM StdVocDetails(NOLOCK) WHERE VocRefNo='PUR1000007'
SELECT * FROM CoaMaster(NOLOCK) WHERE CoaId IN (247,324,329,251)
ROLLBACK TRANSACTION
*/

CREATE                 Procedure [dbo].[Proc_VoucherPostingPurchase]
(
	@Pi_TransId		Int,
	@Pi_SubTransId		Int,
	@Pi_ReferNo		nVarChar(100),
	@Pi_VocType		INT,
	@Pi_SubVocType		INT,	
	@Pi_UserId		Int,
	@Pi_VocDate		DateTime,
	@Po_PurErrNo		Int OutPut
)
AS
/*********************************
* PROCEDURE	: Proc_VoucherPostingPurchase
* PURPOSE	: General SP for posting Purchase Voucher
* CREATED	: Thrinath
* CREATED DATE	: 25/12/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @AcmId 		INT
	DECLARE @AcpId		INT
	DECLARE @CoaId		INT
	DECLARE @VocRefNo	nVarChar(100)
	DECLARE @sStr		nVarChar(4000)
	DECLARE @Amt		Numeric(25,6)
	DECLARE @DCoaId		INT
	DECLARE @CCoaId		INT
	DECLARE @DiffAmt	Numeric(25,6)
	DECLARE @sSql           VARCHAR(4000)
	SET @Po_PurErrNo = 1

	IF @Pi_TransId = 5 AND @Pi_SubTransId = 1
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END

		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END

		--For Posting Purchase Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From GRN ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
		
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'

		--For Posting Purchase Account in Details Table on Debit(Gross Amount)
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4110001')
		BEGIN
			SET @Po_PurErrNo = -2
			Return
		END
		
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4110001'
		SELECT @Amt = SUM(PrdGrossAmount) FROM PurchaseReceiptProduct
		WHERE PurRcptId IN (SELECT PurRcptId FROM
		PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo)
		

		DECLARE @Amt1 AS NUMERIC(38,6)

		SELECT @Amt1=LessScheme FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo

		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt-@Amt1,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		
		--For Posting Supplier Account in Details Table to Credit(Net Payable)
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReceipt C ON B.SpmId = C.SpmId
			WHERE C.PurRcptRefNo = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -3
			Return
		END

		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReceipt C ON B.SpmId = C.SpmId
			WHERE C.PurRcptRefNo = @Pi_ReferNo

		--->Modified By Nanda on 29/10/2010
		--SELECT @Amt = NetPayable FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
		SELECT @Amt = NetPayable+DbAdjustAmt-CrAdjustAmt FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))

		--For Posting Purchase Discount Account in Details Table to Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,D.CoaId,2,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptHdAmount B ON
				A.PurRcptId = B.PurRcptId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRcptRefNo = @Pi_ReferNo AND
				EffectInNetAmount = 2 AND B.BaseQtyAmount > 0

		--For Posting Purchase Addition Account in Details Table on Debit
		SELECT @VocRefNo AS VocRefNo,D.CoaId,1 AS DebitCredit,B.BaseQtyAmount AS Amount,1 AS Availability,
			@Pi_UserId AS LastModBy,Convert(varchar(10),Getdate(),121) AS LastModDate,
			@Pi_UserId AS AuthId,Convert(varchar(10),Getdate(),121) AS AuthDate
		INTO #PurTotAdd
		FROM PurchaseReceipt A INNER JOIN PurchaseReceiptHdAmount B ON
			A.PurRcptId = B.PurRcptId
		INNER JOIN PurchaseSequenceMaster C ON
			A.PurSeqId = C.PurSeqId
		INNER JOIN PurchaseSequenceDetail D ON
			C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
		WHERE A.PurRcptRefNo = @Pi_ReferNo AND B.RefCode <> 'D' AND
			EffectInNetAmount = 1 AND B.BaseQtyAmount > 0
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT * FROM #PurTotAdd

		--For Posting Purchase Tax Account in Details Table on Debit
		SELECT @VocRefNo AS VocRefNo,C.InputTaxId,1 AS DebitCredit,ISNULL(SUM(B.TaxAmount),0) AS Amount,1 AS Availability,
			@Pi_UserId AS LastModBy,Convert(varchar(10),Getdate(),121) AS LastModDate,@Pi_UserId AS AuthId,
			Convert(varchar(10),Getdate(),121) AS AuthDate
		INTO #PurTaxForDiff
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptProductTax B ON
				A.PurRcptId = B.PurRcptId
			INNER JOIN TaxConfiguration C ON
				B.TaxId = C.TaxId
			WHERE A.PurRcptRefNo = @Pi_ReferNo
			Group By C.InputTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0

		SELECT @DiffAmt=ISNULL((SUM(A.TotalAddition)-(SUM(B.Amount)+SUM(C.Amount))),0)
		FROM PurchaseReceipt A,#PurTaxForDiff B,#PurTotAdd C
		WHERE A.PurRcptRefNo = @Pi_ReferNo
		
		UPDATE #PurTaxForDiff SET Amount=Amount+@DiffAmt
		WHERE InputTaxId IN (SELECT MIN(InputTaxId) FROM #PurTaxForDiff)
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT * FROM #PurTaxForDiff

		--For Posting Scheme Discount in Details Table to Credit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3210002')
		BEGIN
			SET @Po_PurErrNo = -9
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3210002'
		SET @Amt = 0
		SELECT @Amt = LessScheme FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			AND LessScheme > 0
		
		IF @Amt > 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		END

		--For Posting Other Charges Add in Details Table For Debit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,B.CoaId,1,ISNULL(SUM(B.Amount),0),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptOtherCharges B ON
				A.PurRcptId = B.PurRcptId
			WHERE A.PurRcptRefNo = @Pi_ReferNo AND Effect = 0
			Group By B.CoaId
			HAVING ISNULL(SUM(B.Amount),0) > 0

		--For Posting Other Charges Reduce in Details Table To Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,B.CoaId,2,ISNULL(SUM(B.Amount),0),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptOtherCharges B ON
				A.PurRcptId = B.PurRcptId
			WHERE A.PurRcptRefNo = @Pi_ReferNo AND Effect = 1
			Group By B.CoaId
			HAVING ISNULL(SUM(B.Amount),0) > 0

		--For Posting Round Off Account reduce in Details Table to Debit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3220001')
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3220001'
		SET @Amt = 0
		SELECT @Amt = DifferenceAmount FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			AND DifferenceAmount > 0
		
		IF @Amt > 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,2,Abs(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		END

		--For Posting Round Off Account Add in Details Table to Credit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4210001')
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4210001'
		SET @Amt = 0
		SELECT @Amt = DifferenceAmount FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			AND DifferenceAmount < 0
		
		IF @Amt < 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,1,ABS(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		END

		--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END

		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	END

	IF @Pi_TransId = 7 AND @Pi_SubTransId = 1	--Purchase Return
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		--For Posting Purchase Return Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Purchase Return ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
		
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'
		--For Posting Purchase Return Account in Details Table on Debit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4110002')
		BEGIN
			SET @Po_PurErrNo = -22
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4110002'
		SELECT @Amt = GrossAmount FROM PurchaseReturn WHERE PurRetRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Supplier Account in Details Table to Credit
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReturn C ON B.SpmId = C.SpmId
			WHERE C.PurRetRefNo = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -3
			Return
		END
		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReturn C ON B.SpmId = C.SpmId
			WHERE C.PurRetRefNo = @Pi_ReferNo
		SELECT @Amt = NetAmount FROM PurchaseReturn WHERE PurRetRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Purchase Return Discount Account in Details Table to Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,D.CoaId,1,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = @Pi_ReferNo AND
				EffectInNetAmount = 2 AND B.BaseQtyAmount > 0
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',D.CoaId,1,B.BaseQtyAmount,1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			 FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + ''' AND
				EffectInNetAmount = 2 AND B.BaseQtyAmount > 0'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Purchase Return Addition Account in Details Table on Debit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,D.CoaId,2,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = @Pi_ReferNo AND B.RefCode <> 'D' AND
				EffectInNetAmount = 1 AND B.BaseQtyAmount > 0
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',D.CoaId,2,B.BaseQtyAmount,1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			 FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + ''' AND B.RefCode <> ''' + 'D' + ''' AND
				EffectInNetAmount = 1 AND B.BaseQtyAmount > 0'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Purchase Return Tax Account in Details Table on Debit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,C.InPutTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReturn A INNER JOIN PurchaseReturnProductTax B ON
				A.PurRetId = B.PurRetId
			INNER JOIN TaxConfiguration C ON
				B.TaxId = C.TaxId
			WHERE A.PurRetRefNo = @Pi_ReferNo
			Group By C.InPutTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',C.InPutTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			FROM PurchaseReturn A INNER JOIN PurchaseReturnProductTax B ON
				A.PurRetId = B.PurRetId
			INNER JOIN TaxConfiguration C ON
				B.TaxId = C.TaxId
			WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + '''
			Group By C.InPutTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Scheme Discount in Details Table to Credit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3210002')
		BEGIN
			SET @Po_PurErrNo = -9
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3210002'
		SET @Amt = 0
		SELECT @Amt = LessScheme FROM PurchaseReturn WHERE PurRetRefNo = @Pi_ReferNo
			AND LessScheme > 0
		
		IF @Amt > 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		
			SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'
			--INSERT INTO Translog(strSql1) Values (@sstr)
		END

		--For Posting Round Off Account Add in Details Table to Debit
			SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
			IF @sSql='-4'
			BEGIN
				SET @Po_PurErrNo = -4
				Return
			END
			ELSE IF @sSql='-5'
			BEGIN
				SET @Po_PurErrNo = -5
				Return
			END
			ELSE IF @sSql<>'0'
			BEGIN
				EXEC(@sSql)
			END
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	END	
	IF @Pi_TransId = 13 AND @Pi_SubTransId = 0  -- Stock Out
	BEGIN

		IF EXISTS (SELECT SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo  AND SMT.Coaid=299)	
		BEGIN	
			SELECT @Amt=SUM(Amount)+SUM(TaxAmt) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
		END
		ELSE
		BEGIN
			SELECT @Amt=SUM(Amount) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
		END
				
		
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		
		
		--For Posting StockAdjustment StockAdd Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
			(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Stock Adjustment ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
				
			
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'
		
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=1
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo )
		BEGIN
			SET @Po_PurErrNo = -26
			Return
		END
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo )
		BEGIN
			SET @Po_PurErrNo = -27
			Return
		END
		SELECT @DCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=1
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 

		SELECT @CCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2 
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo AND SMT.Coaid<>299
			
		
		--For Posting Default Sales Account details on Debit
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@DCoaid,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@DCoaid as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'

			--For Posting Default Debtor Account details on Debit

			SELECT @Amt=SUM(Amount) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
			
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CCoaid,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
			SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@CCoaid as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'

			IF EXISTS (SELECT SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo  AND SMT.Coaid=299)	
			BEGIN	

				SET @CCoaid=299

				SELECT @Amt=SUM(TaxAmt) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 

				IF @Amt > 0
				BEGIN
					INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
						LastModDate,AuthId,AuthDate) VALUES
					(@VocRefNo,@CCoaid,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
						@Pi_UserId,Convert(varchar(10),Getdate(),121))
					SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
						LastModDate,AuthId,AuthDate) VALUES
					(''' + @VocRefNo + ''',' + CAST(@CCoaid as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
						',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
						+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
						Convert(nvarchar(10),Getdate(),121) + ''')'
				END

			END



		--For Posting Round Off Account Add in Details Table to Debit
			SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
			IF @sSql='-4'
			BEGIN
				SET @Po_PurErrNo = -4
				Return
			END
			ELSE IF @sSql='-5'
			BEGIN
				SET @Po_PurErrNo = -5
				Return
			END
			ELSE IF @sSql<>'0'
			BEGIN
				EXEC(@sSql)
			END
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			RETURN
		END
	END
	IF @Pi_TransId = 13 AND @Pi_SubTransId = 1   -- Stock In
	BEGIN
		

		Select @Amt=SUM(Amount) FROM StockManagement SM
		INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
		INNER JOIN StockManagementType SMT ON SMT.StkMgmtTypeId=SMP.StkMgmtTypeId AND SMT.TransactionType=0
		WHERE SM.StkMngRefNo=@Pi_ReferNo
			
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		
		
		--For Posting StockAdjustment StockAdd Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
			(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Stock Adjustment ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
				
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'
		
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=1
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo )
		BEGIN
			SET @Po_PurErrNo = -26
			Return
		END
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo )
		BEGIN
			SET @Po_PurErrNo = -27
			Return
		END
				
		SELECT @DCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=1
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo  AND SMT.CoaId<>298

		SELECT @CCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
			
		
		--For Posting Default Purchase Account details on Debit
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@DCoaid,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
				(''' + @VocRefNo + ''',' + CAST(@DCoaid as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'


		IF EXISTS (SELECT SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId 
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo AND DebitCredit=1 AND SMT.Coaid=298)	
		BEGIN

--			Select @Amt=SUM(TaxAmt) FROM StockManagement SM
--			INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
--			WHERE SM.StkMngRefNo=@Pi_ReferNo
			SELECT @Amt=SUM(TaxAmt) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId 
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo AND DebitCredit=1

			SET @DCoaid=298

			IF @Amt >0 
			BEGIN
				INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
					LastModDate,AuthId,AuthDate) VALUES
					(@VocRefNo,@DCoaid,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
					@Pi_UserId,Convert(varchar(10),Getdate(),121))
				SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
						LastModDate,AuthId,AuthDate) VALUES
						(''' + @VocRefNo + ''',' + CAST(@DCoaid as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
						',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
						+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
						Convert(nvarchar(10),Getdate(),121) + ''')'
			END

		END


--		Select @Amt=SUM(Amount)+SUM(TaxAmt) FROM StockManagement SM
--			INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
--			WHERE SM.StkMngRefNo=@Pi_ReferNo

			SELECT @Amt=SUM(Amount)+SUM(TaxAmt) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId 
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo AND DebitCredit=1
			

		--For Posting Default Purchase Account details on Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CCoaid,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CCoaid as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'



		--For Posting Round Off Account Add in Details Table to Debit
			SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
			IF @sSql='-4'
			BEGIN
				SET @Po_PurErrNo = -4
				Return
			END
			ELSE IF @sSql='-5'
			BEGIN
				SET @Po_PurErrNo = -5
				Return
			END
			ELSE IF @sSql<>'0'
			BEGIN
				EXEC(@sSql)
			END
		
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			RETURN
		END
	END
	IF @Po_PurErrNo=1
	BEGIN
			EXEC Proc_PostStdDetails @Pi_VocDate,@VocRefNo,1
	END
	Return
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-213-006

Update RptDetails Set SingleMulti = 1 Where RptId = 2 and SlNo = 3
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RetailerAccountStment]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RetailerAccountStment]
GO

CREATE  PROCEDURE [Proc_RetailerAccountStment] 
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate DATETIME,
	@Pi_RtrId INT
)
AS
/*********************************
* PROCEDURE	: Proc_RetailerAccountStment
* PURPOSE	: To Return the Retailer wise bill details
* CREATED	: MarySubashini.S
* CREATED DATE	: 23-06-2010
* NOTE		: General SP Returning the Retailer wise Account details 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}		{brief modification description}
* 14-OCT-2010	Jayakumar N		Reference with SLR is not taken from CreditNoteRetailer	
* 20-OCT-2010	Jayakumar N		Changes done after discussion made with kanagaraj regarding CreditNote & DebitNote posting	
*********************************/
SET NOCOUNT ON
BEGIN
-- AND PostedFrom NOT LIKE @SLRHD AND PostedFrom NOT LIKE @RTNHD AND PostedFrom IS NULL
	DECLARE @SLRHD AS NVARCHAR(50)
	DECLARE @RTNHD AS NVARCHAR(50)
	SELECT @SLRHD=Prefix FROM Counters WHERE TabName='ReturnHeader' and FldName = 'ReturnCode'
	SET @SLRHD=@SLRHD + '%'
	SELECT @RTNHD=Prefix FROM Counters WHERE TabName='ReplacementHd' and FldName = 'RepRefNo'
	SET @RTNHD=@RTNHD + '%'
	DECLARE @TempRetailerAccountStatement TABLE
		(
			[SlNo] [int] NULL,
			[RtrId] [int] NULL,
			[CoaId] [int] NULL,
			[RtrName] [nvarchar](100) NULL,
			[RtrAddress] [nvarchar](600) NULL,
			[RtrTINNo] [nvarchar](50) NULL,
			[InvDate] [datetime] NULL,
			[DocumentNo] [nvarchar](100) NULL,
			[Details] [nvarchar](400) NULL,
			[RefNo] [nvarchar](100) NULL,
			[DbAmount] [numeric](38, 6) NULL,
			[CrAmount] [numeric](38, 6) NULL,
			[BalanceAmount] [numeric](38, 6) NULL
		)
	INSERT INTO @TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
	SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				SI.SalInvDate,SI.SalInvNo,'Sales','',
				(SI.SalNetAmt + SI.OnAccountAmount + SI.MarketRetAmount + SI.CrAdjAmount-SI.ReplacementDiffAmount - SI.DBAdjAmount),0,0
			FROM SalesInvoice SI (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
			WHERE SI.DlvSts  IN (4,5) AND SI.SalInvDate <@Pi_FromDate  AND SI.RtrId=@Pi_RtrId
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.ReturnDate,RH.ReturnCode,'Sales Return',ISNULL(SI.SalInvNo,''),0,
					(CASE RH.RtnRoundOff WHEN 1 THEN (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)+RH.RtnRoundOffAmt) 
					ELSE (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)) END ),0
				FROM ReturnHeader RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnId=RH.ReturnId
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.Status=0 AND RH.ReturnType=2 AND RH.ReturnDate<@Pi_FromDate AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.ReturnDate,RH.ReturnCode,
				SI.SalInvNo,RH.RtnRoundOff,RH.RtnRoundOffAmt
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.ReturnDate,RH.ReturnCode,'Market Return',ISNULL(SI.SalInvNo,''),0,
					(CASE RH.RtnRoundOff WHEN 1 THEN (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)+RH.RtnRoundOffAmt) 
					ELSE (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)) END ),0
				FROM ReturnHeader RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnId=RH.ReturnId
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.Status=0 AND RH.ReturnType=1 AND RH.ReturnDate<@Pi_FromDate AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.ReturnDate,RH.ReturnCode,
				SI.SalInvNo,RH.RtnRoundOff,RH.RtnRoundOffAmt
----		UNION ALL
----			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
----					RH.RepDate,RH.RepRefNo,'Return & Replacement-Return',ISNULL(SI.SalInvNo,''),0,ROUND(SUM(RP.RtnAmount),2),0
----				FROM ReplacementHd RH (NOLOCK)
----					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
----					INNER JOIN ReplacementIn RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
----					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
----				WHERE RH.RepDate<@Pi_FromDate AND  RH.RtrId=@Pi_RtrId
----				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.RepDate,RH.RepRefNo,'Return & Replacement-Replacement',ISNULL(SI.SalInvNo,''),ROUND(SUM(RP.RepAmount),2),0,0
				FROM ReplacementHd RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReplacementOut RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.RepDate<@Pi_FromDate AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
		UNION ALL  -- Added by Jay on 21-OCT-2010
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.RepDate,RH.RepRefNo,'Return & Replacement-Return',ISNULL(SI.SalInvNo,''),0,ROUND(SUM(RP.RtnAmount),2),0
				FROM ReplacementHd RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReplacementIn RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.RepDate<@Pi_FromDate AND RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
				   -- End here
		UNION ALL
			SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.InvRcpDate,RH.InvRcpNo,'Collection',ISNULL(SI.SalInvNo,''),0,SUM(RE.SalInvAmt),0
				FROM Receipt RH (NOLOCK)
					INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
					INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
					INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
				WHERE RE.InvRcpMode IN (1,2,3,4,8) AND 
					RH.InvRcpDate<@Pi_FromDate AND SI.RtrId=@Pi_RtrId
				GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
			SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				RH.InvRcpDate,RH.InvRcpNo,'Collection-Cheque Bounce',ISNULL(SI.SalInvNo,''),(SUM(RE.SalInvAmt)+SUM(RE.Penalty)),0,0
			FROM Receipt RH (NOLOCK)
				INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
				INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
				INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
			WHERE RE.InvRcpMode IN (3) AND InvInsSta=4 AND 
				RH.InvRcpDate<@Pi_FromDate AND SI.RtrId=@Pi_RtrId
			GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
		SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.InvRcpDate,RH.InvRcpNo,'Collection-Cash Cancellation',ISNULL(SI.SalInvNo,''),SUM(RE.SalInvAmt),0,0
				FROM Receipt RH (NOLOCK)
					INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
					INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
					INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
				WHERE RE.InvRcpMode IN (1,2) AND CancelStatus=0  AND 
					RH.InvRcpDate<@Pi_FromDate AND SI.RtrId=@Pi_RtrId
				GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
		SELECT  2,DR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				DR.DbNoteDate,DR.DbNoteNumber,'Debit Note Retailer',(CASE DR.TransId WHEN 19 THEN '' ELSE DR.PostedFrom END),DR.Amount,DR.Amount,0 -- DR.Amount
			FROM DebitNoteRetailer DR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON DR.RtrId=R.RtrId AND DR.CoaId=R.CoaId
			WHERE DR.DbNoteDate<@Pi_FromDate AND DR.RtrId=@Pi_RtrId 
			AND DR.PostedFrom NOT LIKE @RTNHD AND DR.PostedFrom NOT LIKE @SLRHD OR DR.PostedFrom IS NULL
		UNION ALL
		SELECT  2,DR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				DR.DbNoteDate,DR.DbNoteNumber,'Debit Note Retailer',(CASE DR.TransId WHEN 19 THEN '' ELSE DR.PostedFrom END),DR.Amount,0,0
			FROM DebitNoteRetailer DR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON DR.RtrId=R.RtrId AND DR.CoaId<>R.CoaId
			WHERE DR.DbNoteDate<@Pi_FromDate AND DR.RtrId=@Pi_RtrId 
			AND DR.PostedFrom NOT LIKE @RTNHD AND DR.PostedFrom NOT LIKE @SLRHD OR DR.PostedFrom IS NULL
		UNION ALL
		SELECT  2,CR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				CR.CrNoteDate,CR.CrNoteNumber,'Credit Note Retailer',(CASE CR.TransId WHEN 18 THEN '' ELSE CR.PostedFrom END),CR.Amount,CR.Amount,0  -- CR.Amount
			FROM CreditNoteRetailer CR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON CR.RtrId=R.RtrId AND CR.CoaId=R.CoaId
			WHERE CR.CrNoteDate<@Pi_FromDate AND CR.RtrId=@Pi_RtrId 
			AND CR.PostedFrom NOT LIKE @RTNHD AND CR.PostedFrom NOT LIKE @SLRHD OR CR.PostedFrom IS NULL
		UNION ALL
		SELECT  2,CR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				CR.CrNoteDate,CR.CrNoteNumber,'Credit Note Retailer',(CASE CR.TransId WHEN 18 THEN '' ELSE CR.PostedFrom END),0,CR.Amount,0
			FROM CreditNoteRetailer CR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON CR.RtrId=R.RtrId AND CR.CoaId<>R.CoaId
			WHERE CR.CrNoteDate<@Pi_FromDate AND CR.RtrId=@Pi_RtrId 
			AND CR.PostedFrom NOT LIKE @RTNHD AND CR.PostedFrom NOT LIKE @SLRHD OR CR.PostedFrom IS NULL
		UNION ALL
		SELECT  2,ROA.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				ROA.ChequeDate,ROA.RtrAccRefNo,'Retailer On Account','',0,Amount,0
			FROM RetailerOnAccount ROA (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON ROA.RtrId=R.RtrId
			WHERE ROA.ChequeDate<@Pi_FromDate AND ROA.RtrId=@Pi_RtrId
-- Added by Jay on 21-OCT-2010
	DELETE FROM @TempRetailerAccountStatement WHERE Rtrid<>@Pi_RtrId
	TRUNCATE TABLE TempRetailerAccountStatement
	INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
	
		SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				SI.SalInvDate,SI.SalInvNo,'Sales','',
				(SI.SalNetAmt + SI.OnAccountAmount + SI.MarketRetAmount + SI.CrAdjAmount- SI.DBAdjAmount),0,0
			FROM SalesInvoice SI (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
			WHERE SI.DlvSts  IN (4,5) AND SI.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SI.RtrId=@Pi_RtrId
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.ReturnDate,RH.ReturnCode,'Sales Return',ISNULL(SI.SalInvNo,''),0,
					(CASE RH.RtnRoundOff WHEN 1 THEN (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)+RH.RtnRoundOffAmt) 
					ELSE (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)) END ),0
				FROM ReturnHeader RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnId=RH.ReturnId
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.Status=0 AND RH.ReturnType=2 AND RH.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate  AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.ReturnDate,RH.ReturnCode,
				SI.SalInvNo,RH.RtnRoundOff,RH.RtnRoundOffAmt
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.ReturnDate,RH.ReturnCode,'Market Return',ISNULL(SI.SalInvNo,''),0,
					(CASE RH.RtnRoundOff WHEN 1 THEN (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)+RH.RtnRoundOffAmt) 
					ELSE (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)) END ),0
				FROM ReturnHeader RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnId=RH.ReturnId
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.Status=0 AND RH.ReturnType=1 AND RH.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.ReturnDate,RH.ReturnCode,
				SI.SalInvNo,RH.RtnRoundOff,RH.RtnRoundOffAmt
----		UNION ALL
----			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
----					RH.RepDate,RH.RepRefNo,'Return & Replacement-Return',ISNULL(SI.SalInvNo,''),0,ROUND(SUM(RP.RtnAmount),2),0
----				FROM ReplacementHd RH (NOLOCK)
----					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
----					INNER JOIN ReplacementIn RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
----					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
----				WHERE RH.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  RH.RtrId=@Pi_RtrId
----				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.RepDate,RH.RepRefNo,'Return & Replacement-Replacement',ISNULL(SI.SalInvNo,''),ROUND(SUM(RP.RepAmount),2),0,0
				FROM ReplacementHd RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReplacementOut RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
		UNION ALL  -- Added by Jay on 20-OCT-2010
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.RepDate,RH.RepRefNo,'Return & Replacement-Return',ISNULL(SI.SalInvNo,''),0,ROUND(SUM(RP.RtnAmount),2),0
				FROM ReplacementHd RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReplacementIn RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
				   -- End here
		UNION ALL
			SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.InvRcpDate,RH.InvRcpNo,'Collection',ISNULL(SI.SalInvNo,''),0,SUM(RE.SalInvAmt),0
				FROM Receipt RH (NOLOCK)
					INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
					INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
					INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
				WHERE RE.InvRcpMode IN (1,2,3,4,8) AND 
					RH.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SI.RtrId=@Pi_RtrId
				GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
			SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				RH.InvRcpDate,RH.InvRcpNo,'Collection-Cheque Bounce',ISNULL(SI.SalInvNo,''),(SUM(RE.SalInvAmt)+SUM(RE.Penalty)),0,0
			FROM Receipt RH (NOLOCK)
				INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
				INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
				INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
			WHERE RE.InvRcpMode IN (3) AND InvInsSta=4 AND 
				RH.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SI.RtrId=@Pi_RtrId
			GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
		SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.InvRcpDate,RH.InvRcpNo,'Collection-Cash Cancellation',ISNULL(SI.SalInvNo,''),SUM(RE.SalInvAmt),0,0
				FROM Receipt RH (NOLOCK)
					INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
					INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
					INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
				WHERE RE.InvRcpMode IN (1,2) AND CancelStatus=0  AND 
					RH.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SI.RtrId=@Pi_RtrId
				GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
		SELECT  2,DR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				DR.DbNoteDate,DR.DbNoteNumber,'Debit Note Retailer',(CASE DR.TransId WHEN 19 THEN '' ELSE DR.PostedFrom END),DR.Amount,DR.Amount,0 --DR.Amount,0
			FROM DebitNoteRetailer DR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON DR.RtrId=R.RtrId AND DR.CoaId=R.CoaId
			WHERE DR.DbNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND DR.RtrId=@Pi_RtrId --AND PostedFrom NOT LIKE @SLRHD AND PostedFrom NOT LIKE @RTNHD AND PostedFrom IS NULL
		UNION ALL
		SELECT  2,DR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				DR.DbNoteDate,DR.DbNoteNumber,'Debit Note Retailer',(CASE DR.TransId WHEN 19 THEN '' ELSE DR.PostedFrom END),DR.Amount,0,0
			FROM DebitNoteRetailer DR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON DR.RtrId=R.RtrId AND DR.CoaId<>R.CoaId
			WHERE DR.DbNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND DR.RtrId=@Pi_RtrId --AND PostedFrom NOT LIKE @SLRHD AND PostedFrom NOT LIKE @RTNHD AND PostedFrom IS NULL
		UNION ALL
		SELECT  2,CR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				CR.CrNoteDate,CR.CrNoteNumber,'Credit Note Retailer',(CASE CR.TransId WHEN 18 THEN '' ELSE CR.PostedFrom END),CR.Amount,CR.Amount,0 --CR.Amount,CR.Amount,0
			FROM CreditNoteRetailer CR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON CR.RtrId=R.RtrId AND CR.CoaId=R.CoaId
			WHERE CR.CrNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND CR.RtrId=@Pi_RtrId --AND PostedFrom NOT LIKE @RTNHD AND PostedFrom NOT LIKE @SLRHD AND PostedFrom IS NULL
		UNION ALL
		SELECT  2,CR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				CR.CrNoteDate,CR.CrNoteNumber,'Credit Note Retailer',(CASE CR.TransId WHEN 18 THEN '' ELSE CR.PostedFrom END),0,CR.Amount,0
			FROM CreditNoteRetailer CR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON CR.RtrId=R.RtrId AND CR.CoaId<>R.CoaId
			WHERE CR.CrNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND CR.RtrId=@Pi_RtrId --AND PostedFrom NOT LIKE @RTNHD AND PostedFrom NOT LIKE @SLRHD AND PostedFrom IS NULL
		UNION ALL
		SELECT  2,ROA.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				ROA.ChequeDate,ROA.RtrAccRefNo,'Retailer On Account','',0,Amount,0
			FROM RetailerOnAccount ROA (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON ROA.RtrId=R.RtrId
			WHERE ROA.ChequeDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND ROA.RtrId=@Pi_RtrId



			CREATE Table #DelRtrAccStmt(SlNo INT,RtrId Int,CoaId INT,InvDate DateTime,DocumentNo nVarchar(50),
							RefNo nVarchar(50),DBAmount Numeric(18,6),CRAmount Numeric(18,6),
							BalAmt Numeric(18,6))

			INSERT INTO #DelRtrAccStmt
			Select SlNo,RtrId,CoaId,InvDate,DocumentNo,RefNo,DBAmount,CRAmount,BalanceAmount
			From TempRetailerAccountStatement Where Details  like  'Credit Note Retailer' 
			and RefNo like @SLRHD
			Union ALL
			Select SlNo,RtrId,CoaId,InvDate,DocumentNo,RefNo,DBAmount,CRAmount,BalanceAmount
			from TempRetailerAccountStatement Where Details  like  'Credit Note Retailer' 
			and RefNo like @RTNHD
			Union ALL
			Select SlNo,RtrId,CoaId,InvDate,DocumentNo,RefNo,DBAmount,CRAmount,BalanceAmount
			from TempRetailerAccountStatement Where Details  like  'Debit Note Retailer' 
			and RefNo like @SLRHD
			Union ALL
			Select SlNo,RtrId,CoaId,InvDate,DocumentNo,RefNo,DBAmount,CRAmount,BalanceAmount
			from TempRetailerAccountStatement Where Details  like  'Debit Note Retailer' 
			and RefNo like @RTNHD

			Delete  From  @TempRetailerAccountStatement 
			Where  (SlNo in (Select SlNo From #DelRtrAccStmt)
				    ANd  RtrId in (Select RtrId From #DelRtrAccStmt)
					ANd  CoaId in (Select CoaId From #DelRtrAccStmt)
					ANd  InvDate in (Select InvDate From #DelRtrAccStmt)
					ANd  DocumentNo in (Select DocumentNo From #DelRtrAccStmt)
					ANd  RefNo in (Select RefNo From #DelRtrAccStmt)
					ANd  DBAmount in (Select DBAmount From #DelRtrAccStmt)
					ANd  CRAmount in (Select CRAmount From #DelRtrAccStmt)
					ANd  BalanceAmount in (Select BalAmt From #DelRtrAccStmt) )
 

			Delete  From  TempRetailerAccountStatement 
			Where  (SlNo in (Select SlNo From #DelRtrAccStmt)
				    ANd  RtrId in (Select RtrId From #DelRtrAccStmt)
					ANd  CoaId in (Select CoaId From #DelRtrAccStmt)
					ANd  InvDate in (Select InvDate From #DelRtrAccStmt)
					ANd  DocumentNo in (Select DocumentNo From #DelRtrAccStmt)
					ANd  RefNo in (Select RefNo From #DelRtrAccStmt)
					ANd  DBAmount in (Select DBAmount From #DelRtrAccStmt)
					ANd  CRAmount in (Select CRAmount From #DelRtrAccStmt)
					ANd  BalanceAmount in (Select BalAmt From #DelRtrAccStmt) )

	IF EXISTS (SELECT * FROM @TempRetailerAccountStatement)
	BEGIN
		INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
			SELECT 1,@Pi_RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					@Pi_FromDate,'','Opening Balance','',0,0,(SUM(Det.DbAmount)-SUM(Det.CrAmount))
			FROM @TempRetailerAccountStatement Det ,Retailer R 
			WHERE R.RtrId=Det.RtrId
			GROUP BY R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo
		INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
			SELECT  DISTINCT 3,@Pi_RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					@Pi_ToDate,'','Closing Balance','',0,0,0
				FROM Retailer R WHERE R.RtrId=@Pi_RtrId
	END 
	ELSE
	BEGIN
		INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
			SELECT DISTINCT  1,@Pi_RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					@Pi_FromDate,'','Opening Balance','',0,0,0
				FROM Retailer R WHERE R.RtrId=@Pi_RtrId
		INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
			SELECT  DISTINCT 3,@Pi_RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					@Pi_ToDate,'','Closing Balance','',0,0,0
				FROM Retailer R WHERE R.RtrId=@Pi_RtrId
	END 
-- Added by Jay on 20-OCT-2010
	INSERT INTO TempRetailerAccountStatement
	SELECT 2,B.CoaId,B.CoaId,AcName,'','',VocDate,'',AcName,NULL,Amount,0,0
	FROM StdVocMaster A INNER JOIN StdVocDetails B ON A.VocRefNo=B.VocRefNo 
	INNER JOIN CoaMaster C ON B.CoaId=C.CoaId
	AND A.VocDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
	AND A.VocType=0 AND A.VocSubType=0 AND A.AutoGen=0 AND DebitCredit=1
	UNION ALL
	SELECT 2,B.CoaId,B.CoaId,AcName,'','',VocDate,'',AcName,NULL,0,Amount,0
	FROM StdVocMaster A INNER JOIN StdVocDetails B ON A.VocRefNo=B.VocRefNo 
	INNER JOIN CoaMaster C ON B.CoaId=C.CoaId
	AND A.VocDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	AND A.VocType=0 AND A.VocSubType=0 AND A.AutoGen=0 AND DebitCredit=2
-- End here	
END
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
				0 Debit,Sum(CRAmount)  as Credit, 0 Balance,InvInsNo as TransactionDet,
				Isnull(InvInsDate,'1900-01-01') CheqorDueDate,4 SeqNo, @Pi_UsrId
		From 
				ReceiptInvoice RI (NoLock),	TempRetailerAccountStatement T (NoLock) ,
				Receipt  R  (NoLock),		SalesInvoice SI (NoLock)
		Where
				RI.InvRcpNo = T.DocumentNo  AND  RI.InvRcpNo = R.InvRcpNo
				and Details = 'Collection'  AND InvRcpMode IN (1,2,3,4,8)
				AND T.Rtrid  = @RtrId       And RI.SalId = SI.SalId 
				And T.RtrId = SI.RtrId		AND SI.SalInvNo = T.Refno
		Group By
				RI.InvRcpNo,InvRcpDate,InvInsNo,InvInsDate 
		UNION ALL
		Select  
				'Total Receipt Received' [Description],'' DocRefNo,'1900-01-01' Date,
				0 Debit,0  as Credit, (-1) * Isnull(Sum(CRAmount),0) Balance,'' as TransactionDet,
				'1900-01-01' CheqorDueDate,5 SeqNo,@Pi_UsrId
		From 
				ReceiptInvoice RI (NoLock),	TempRetailerAccountStatement T (NoLock) ,
				Receipt  R  (NoLock),		SalesInvoice SI (NoLock)
		Where
				RI.InvRcpNo = T.DocumentNo  AND  RI.InvRcpNo = R.InvRcpNo
				and Details = 'Collection'  AND InvRcpMode IN (1,2,3,4,8)
				AND T.Rtrid  = @RtrId       And RI.SalId = SI.SalId 
				And T.RtrId = SI.RtrId		AND SI.SalInvNo = T.Refno
		 

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

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_ProductTrackDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_ProductTrackDetails]
GO
-----Exec Proc_ProductTrackDetails 2,'2011-03-19','2011-03-19' 
CREATE       PROCEDURE [Proc_ProductTrackDetails]
(
	 @Pi_UsrId INT,
	 @Pi_FromDate DATETIME,
	 @Pi_ToDate DATETIME
)
AS
/*********************************
* PROCEDURE	: Proc_ProductTrackDetails
* PURPOSE	: To Return the Product transaction details
* CREATED	: MarySubashini.S
* CREATED DATE	: 01/08/2008
* NOTE		: General SP Returning the Product transaction details
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}     {developer}  {brief modification description}
* 03/02/2009 Nanda	  Added Sample management
*********************************/
SET NOCOUNT ON
BEGIN
	SELECT TransDate,PrdId,PrdBatId,ISNULL(LcnId,0) AS LcnId,SUM(SalOpenStock) SalOpenStock,
	SUM(UnSalOpenStock) UnSalOpenStock,SUM(OfferOpenStock) OfferOpenStock INTO #OpenStk FROM StockLedger
	WHERE TransDate in (SELECT MAX(TransDate) FROM StockLedger WHERE TransDate <= @Pi_FromDate)
	GROUP BY TransDate,PrdId,PrdBatId,LcnId
		
	SELECT TransDate,PrdId,PrdBatId,LcnId,SUM(SalClsStock) SalClsStock,SUM(UnSalClsStock) UnSalClsStock,
	SUM(OfferClsStock) OfferClsStock INTO #CloseStk FROM StockLedger
	WHERE TransDate in (SELECT MAX(TransDate) FROM StockLedger WHERE TransDate <= @Pi_ToDate)
	GROUP BY TransDate,PrdId,PrdBatId,LcnId
	
	DELETE FROM RptProductTrack WHERE UsrId IN(0,@Pi_UsrId)
	INSERT INTO RptProductTrack(LevelValId,LevelValName,LevelId,LevelName,CmpId,CmpName,PrdId,
	PrdName,PrdBatId,PrdBatCode,SalQty,UnSalQty,OfferQty,TransactionType,
	TransactionNumber,TransactionDate,UsrId,SlNo,LcnId)
	--Opening Stock
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		ISNULL(O.SalOpenStock,0),ISNULL(O.UnSalOpenStock,0),
		ISNULL(O.OfferOpenStock,0),
		'Opening Stock' ,'',@Pi_FromDate ,@Pi_UsrId,1,ISNULL(O.LcnId,0)
		FROM
		PrdHirarchy PH
		LEFT OUTER JOIN #OpenStk O ON PH.PrdId = O.PrdId AND PH.PrdBatId = O.PrdBatId
	UNION ALL
	--Stock Mng (In)		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TotalQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TotalQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TotalQty ELSE 0 END ) AS OfferStock,
		'Stock Management – Add',M.StkMngRefNo,M.StkMngDate,@Pi_UsrId,2,S.LcnId
		FROM
		StockManagement M
		INNER JOIN StockManagementProduct D ON M.StkMngRefNo = D.StkMngRefNo
--		INNER JOIN StockManagementType SMT ON SMT.StkMgmtTypeId=M.StkMgmtTypeId AND SMT.TransactionType=0
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND M.StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		and D.StkMgmtTypeId = 1
	UNION ALL
	--Stock Mng (Out)	
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.TotalQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.TotalQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.TotalQty ELSE 0 END ) AS OfferStock,
		'Stock Management – Reduce' ,M.StkMngRefNo,M.StkMngDate,@Pi_UsrId,3,S.LcnId
		FROM
		StockManagement M
		INNER JOIN StockManagementProduct D ON M.StkMngRefNo = D.StkMngRefNo
------		INNER JOIN StockManagementType SMT ON SMT.StkMgmtTypeId=M.StkMgmtTypeId AND SMT.TransactionType=1
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND  M.StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		and D.StkMgmtTypeId = 2
	UNION ALL
	--Lcn Trans
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.TransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.TransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.TransferQty ELSE 0 END ) AS OfferStock,
		'Location Transfer Out' ,M.LcnRefNo,M.LcnTrfDate,@Pi_UsrId,4,M.FromLcnId
		FROM
		LocationTransferMaster M
		INNER JOIN LocationTransferDetails D ON M.LcnRefNo = D.LcnRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.LcnTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Lcn Trans
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransferQty ELSE 0 END ) AS OfferStock,
		'Location Transfer In' ,M.LcnRefNo,M.LcnTrfDate,@Pi_UsrId,5,M.ToLcnId
		FROM
		LocationTransferMaster M
		INNER JOIN LocationTransferDetails D ON M.LcnRefNo = D.LcnRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.LcnTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	-- Bat Tran (In)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*T.TrfQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*T.TrfQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*T.TrfQty ELSE 0 END ) AS OfferStock,
		'Batch Transfer Out',T.BatRefNo,T.BatTrfDate,@Pi_UsrId,6,S.LcnId
		FROM
		BatchTransfer T INNER JOIN StockType S On T.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.FromBatId = PH.PrdBatId
		WHERE T.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	-- Bat Tran (Out)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN T.TrfQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN T.TrfQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN T.TrfQty ELSE 0 END ) AS OfferStock,
		'Batch Transfer In',T.BatRefNo,T.BatTrfDate,@Pi_UsrId,7,S.LcnId
		FROM
		BatchTransfer T INNER JOIN StockType S On T.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH On T.PrdId = PH.PrdId AND T.ToBatId = PH.PrdBatId
		WHERE T.BatTrfDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Salvage
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.SalvageQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.SalvageQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.SalvageQty ELSE 0 END ) AS OfferStock,
		'Salvage' TransType ,M.SalvageRefNo,M.SalvageDate,@Pi_UsrId,8,S.LcnId
		FROM
		Salvage M
		INNER JOIN SalvageProduct D ON M.SalvageRefNo = D.SalvageRefNo
		INNER JOIN StockType S ON M.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.Status=1 AND M.SalvageDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Stock journal (Out)		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.StkTransferQty ELSE 0 END ) AS OfferStock,
		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,9,S.LcnId
		FROM
		StockJournal M
		INNER JOIN StockJournalDt D ON M.StkJournalRefNo = D.StkJournalRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON M.PrdId = PH.PrdId AND M.PrdBatId = PH.PrdBatId
		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Stock journal(In)		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.StkTransferQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.StkTransferQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.StkTransferQty ELSE 0 END ) AS OfferStock,
		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,10,S.LcnId
		FROM
		StockJournal M
		INNER JOIN StockJournalDt D ON M.StkJournalRefNo = D.StkJournalRefNo
		INNER JOIN StockType S ON D.TransferStkTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON M.PrdId = PH.PrdId AND M.PrdBatId = PH.PrdBatId
		WHERE M.StkJournalDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Ret to cmp
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN CAST((-1)*D.RtnQty AS INT) ELSE 0 END ) AS OfferStock,
		'Return To Company' TransType ,
		M.RtnCmpRefNo TransNo,M.RtnCmpDate TransDate,@Pi_UsrId,11,S.LcnId
		FROM
		ReturnToCompany M
		INNER JOIN ReturnToCompanyDt D ON M.RtnCmpRefNo = D.RtnCmpRefNo
		INNER JOIN StockType S ON M.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RtnCmpDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	--Ret and replacement
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.RtnQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.RtnQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.RtnQty ELSE 0 END ) AS OfferStock,
		'Return and Replacement – Return',M.RepRefNo,M.RepDate,@Pi_UsrId,12,S.LcnId
		FROM
		ReplacementHd M
		INNER JOIN ReplacementIn D ON M.RepRefNo = D.RepRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Ret and replacement(Out)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*D.RepQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN (-1)*D.RepQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN (-1)*D.RepQty ELSE 0 END ) AS OfferStock,
		'Return and Replacement – Replacement',M.RepRefNo,M.RepDate,@Pi_UsrId,13,S.LcnId
		FROM
		ReplacementHd M
		INNER JOIN ReplacementOut D ON M.RepRefNo = D.RepRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--Resell Damage Goods
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,(-1)*D.Quantity,0,
		'Resell Damage Goods',M.ReDamRefNo,M.ReSellDate,@Pi_UsrId,14,M.LcnId
		FROM
		ReSellDamageMaster M
		INNER JOIN ReSellDamageDetails D ON M.ReDamRefNo = D.ReDamRefNo
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.ReSellDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	--VanLoad&Unload
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransQty ELSE 0 END ) AS OfferStock,
		'Van Load',M.VanLoadRefNo,M.TransferDate,@Pi_UsrId,15,S.LcnId
		FROM
		VanLoadUnloadMaster M
		INNER JOIN VanLoadUnloadDetails D ON M.VanLoadRefNo = D.VanLoadRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.VanLoadUnload = 0 AND M.TransferDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	--VanLoad&Unload (Unload)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN D.TransQty ELSE 0 END ) AS SalStock,
		(CASE S.SystemStockType WHEN 2 THEN D.TransQty ELSE 0 END ) AS UnSalStock,
		(CASE S.SystemStockType WHEN 3 THEN D.TransQty ELSE 0 END ) AS OfferStock,
		'Van Unload',M.VanLoadRefNo,M.TransferDate,@Pi_UsrId,16,S.LcnId
		FROM
		VanLoadUnloadMaster M
		INNER JOIN VanLoadUnloadDetails D ON M.VanLoadRefNo = D.VanLoadRefNo
		INNER JOIN StockType S ON D.StockTypeId = S.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.VanLoadUnload = 1 AND M.TransferDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	UNION ALL
	-- Sales		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(-1)*D.BaseQty,0,0,
		'Sales',M.SalInvNo,M.SalInvDate,@Pi_UsrId,17,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN  SalesInvoiceProduct D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (4,5)
	UNION ALL
	-- Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.FreeQty,
		'Sales Free',M.SalInvNo,M.SalInvDate,@Pi_UsrId,18,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN SalesInvoiceSchemeDtFreePrd D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.FreePrdId = PH.PrdId AND D.FreePrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (4,5)
	UNION ALL
	-- Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.SalManFreeQty,
		'Sales Free',M.SalInvNo,M.SalInvDate,@Pi_UsrId,19,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN  SalesInvoiceProduct D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (4,5)
	UNION ALL
	-- Gift
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.GiftQty,
		'Sales Gift',M.SalInvNo,M.SalInvDate,@Pi_UsrId,20,M.LcnId
		FROM
		SalesInvoice M
		INNER JOIN SalesInvoiceSchemeDtFreePrd D ON M.SalId = D.SalId
		INNER JOIN PrdHirarchy PH ON D.GiftPrdId = PH.PrdId AND D.GiftPrdBatId = PH.PrdBatId
		WHERE M.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.DlvSts IN (4,5)
	UNION ALL
	--Pur (sal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		D.RcvdGoodBaseQty,0,0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,21,M.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	--Pur (unsal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,E.BaseQty,0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,22,S.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PurchaseReceiptBreakup E ON E.PurRcptId = D.PurRcptId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=1
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	--Pur (Excess)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE S.SystemStockType WHEN 1 THEN (-1)*E.BaseQty ELSE 0 END),
		(CASE S.SystemStockType WHEN 2 THEN (-1)*E.BaseQty ELSE 0 END),0,
		'Purchase',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,23,S.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PurchaseReceiptBreakup E ON E.PurRcptId = D.PurRcptId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=2
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1 AND D.RefuseSale=1
	UNION ALL
	-- pur Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.Quantity,
		'Purchase Free',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,24,M.LcnId
		FROM
		PurchaseReceipt M
		INNER JOIN PurchaseReceiptClaimScheme D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND D.TypeId=2 AND M.Status=1
	UNION ALL
	-- Pur ret (sal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(-1)*D.RetSalBaseQty,0,0,
		'Purchase Return',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,25,M.LcnId
		FROM PurchaseReturn M INNER JOIN PurchaseReturnProduct D ON M.PurRetId = D.PurRetId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	-- Pur ret (unsal)
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,(-1)*E.ReturnBsQty,0,
		'Purchase Return',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,26,S.LcnId
		FROM
		PurchaseReturn M
		INNER JOIN PurchaseReturnProduct D ON M.PurRetId = D.PurRetId
		INNER JOIN PurchaseReturnBreakup E ON E.PurRetId = D.PurRetId
		AND D.PrdSlNo=E.PrdSlNo AND E.BreakUpType=1
		INNER JOIN StockType S ON S.StockTypeId = E.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE  M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	-- Pur Ret Free
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.RetQty,
		'Purchase Return Free',M.PurRetRefNo,M.PurRetDate,@Pi_UsrId,27,M.LcnId
		FROM
		PurchaseReturn M
		INNER JOIN PurchaseReturnClaimScheme D ON M.PurRetId = D.PurRetId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND D.TypeId=2 AND M.Status=1		
	UNION ALL
	-- Sales Ret
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		(CASE ST.SystemStockType WHEN 1 THEN D.BaseQty ELSE 0 END ) AS SalStock,
		(CASE ST.SystemStockType WHEN 2 THEN D.BaseQty ELSE 0 END ) AS UnSalStock,
		(CASE ST.SystemStockType WHEN 3 THEN D.BaseQty ELSE 0 END ) AS OfferStock,
		'Sales Return',M.ReturnCode,M.ReturnDate,@Pi_UsrId,28,ST.LcnId
		FROM ReturnHeader M
		INNER JOIN ReturnProduct D ON M.Returnid = D.ReturnId
		INNER JOIN StockType ST ON D.StockTypeId = ST.StockTypeId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=0
	UNION ALL
	--Sample Receipt
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.RcvdGoodBaseQty,
		'Sample Receipt',M.PurRcptRefNo,M.GoodsRcvdDate,@Pi_UsrId,29,M.LcnId
		FROM
		SamplePurchaseReceipt M
		INNER JOIN SamplePurchaseReceiptProduct D ON M.PurRcptId = D.PurRcptId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId AND D.PrdBatId = PH.PrdBatId
		WHERE M.GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	UNION ALL
	--Sample Issue		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,(-1)*D.IssueBaseQty,
		'Sample Issue',M.IssueRefNo,M.IssueDate,@Pi_UsrId,30,M.LcnId
		FROM
		SampleIssueHd M
		INNER JOIN  SampleIssueDt D ON M.IssueId = D.IssueId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.IssueDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1
	
	UNION ALL
	--Sample Return		
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		0,0,D.ReturnBaseQty,
		'Sample Return',M.ReturnRefNo,M.ReturnDate,@Pi_UsrId,31,M.LcnId
		FROM
		SampleReturnHd M
		INNER JOIN  SampleReturnDt D ON M.ReturnId = D.ReturnId
		INNER JOIN PrdHirarchy PH ON D.PrdId = PH.PrdId and D.PrdBatId = PH.PrdBatId
		WHERE M.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		AND M.Status=1	
	UNION ALL --Closing Stock
	SELECT
		PH.PrdCtgValMainId ,PH.PrdCtgValName ,PH.CmpPrdCtgId ,
		PH.CmpPrdCtgName,
		PH.CmpId,PH.CmpName,PH.PrdId,PH.PrdName,PH.PrdBatId,PH.PrdBatCode,
		ISNULL(C.SalClsStock,0),
		ISNULL(C.UnSalClsStock,0),ISNULL(C.OfferClsStock,0),
		'Closing Stock' ,'',@Pi_ToDate ,@Pi_UsrId,32,ISNULL(C.LcnId,0)
		FROM
		PrdHirarchy PH
		LEFT OUTER JOIN #CloseStk C ON PH.PrdId = C.PrdId AND PH.PrdBatId = C.PrdBatId
END
GO
 
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RptStockManagementAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RptStockManagementAll]

GO

CREATE Procedure [dbo].[Proc_RptStockManagementAll]
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT
)
AS
SET NOCOUNT ON
BEGIN
     Delete from RptStockManagementAll Where UsrId = @Pi_UsrId
     INSERT INTO RptStockManagementAll
     SELECT
     LT.StkMngRefNo, LT.StkMngDate, LT.LcnId, LT.LcnName, 
     P.CmpId,P.PrdDCode,P.PrdName,PB.PrdBatCode,
     LT.StkMgmtTypeId,LT.Description,LT.TotalQty,LT.Rate,LT.Amount
     ,@Pi_UsrId
     FROM
     (
    SELECT
    SM.StkMngRefNo,SM.StkMngDate,SM.LcnId,L.LcnName,SD.PrdId,SD.PrdBatId,
    SM.StkMgmtTypeId,ST.Description,SD.TotalQty,SD.Rate,SD.Amount
    FROM
    StockManagement SM
    Left Outer Join StockManagementProduct SD On SM.StkMngRefNo = SD.StkMngRefNo
    Left Outer Join StockManagementType ST On SD.StkMgmtTypeId = ST.StkMgmtTypeId
    Left Outer Join Location L On SM.LcnId = L.LcnId
     ) LT
     LEFT OUTER JOIN Product P ON LT.PrdId = P.PrdId
     LEFT OUTER JOIN ProductBatch PB ON LT.PrdBatID = PB.PrdBatId
END
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RptMastStockManagementt]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RptMastStockManagementt]
GO

--EXEC Proc_RptMastStockManagementt 127,2,0,'ClaimMgt',0,0,1,0
CREATE             PROCEDURE [Proc_RptMastStockManagementt]
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
/*********************************
* PROCEDURE	: Proc_RptMastStockManagement
* PURPOSE	: To get the Report details for Stock Management Details
* CREATED	: Boopathy.P
* CREATED DATE	: 05/06/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
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

	--Filter Variable
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate		AS	DATETIME
	DECLARE @LcnId		AS	INT
	DECLARE @TransType	AS	INT
	DECLARE @RefNo		AS 	NVARCHAR(50)
	DECLARE @ReasonId	AS	INT
	--Till Here


	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @LcnId = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @TransType = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,38,@Pi_UsrId))
	SET @RefNo = (SElect  TOP 1 sCountid FRom Fn_ReturnRptFilterString(@Pi_RptId,158,@Pi_UsrId))
	SET @ReasonId = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,159,@Pi_UsrId))
	--Till Here

	
	--Select * From AcMaster	
	--Select * From AcPeriod	

	Create TABLE #RptMastStockManagement
	(
			PrdCode 	     NVARCHAR(100),
			PrdName		     NVARCHAR(100),
			BatchCode	     NVARCHAR(100),
			StockType	     NVARCHAR(100),
			Pieces		     INT,
			Rate		     NUMERIC(38,2),
			Amount		     NUMERIC(38,2)
	)

	SET @TblName = 'RptMastStockManagement'
	SET @TblStruct = '	PrdCode 	     NVARCHAR(100),
				PrdName		     NVARCHAR(100),
				BatchCode	     NVARCHAR(100),
				StockType	     NVARCHAR(100),
				Pieces		     INT,
				Rate		     NUMERIC(38,2),
				Amount		     NUMERIC(38,2)'

	SET @TblFields = 'PrdCode,PrdName,BatchCode,StockType,Pieces,Rate,Amount'

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
		INSERT INTO #RptMastStockManagement (PrdCode,PrdName,BatchCode,StockType,Pieces,Rate,Amount)
			SELECT C.PrdCCode,C.PrdName,D.PrdBatCode,E.UserStockType,
				B.TotalQty,B.Rate,B.Amount
 			FROM StockManagementProduct B INNER JOIN StockManagement A ON A.StkMngRefNo=B.StkMngRefNo
				INNER JOIN Product C ON B.PrdId=C.PrdId
				INNER JOIN ProductBatch D ON B.PrdBatId=D.PrdBatId
				INNER JOIN StockType E ON B.StockTypeId = E.StockTypeId
				LEFT OUTER JOIN ReasonMaster G ON B.ReasonId=G.ReasonId
			WHERE 
				A.LcnId=  (CASE @LcnId WHEN 0 THEN A.LcnId ELSE @LcnId END ) AND
				B.StkMgmtTypeId=  (CASE @TransType WHEN 0 THEN b.StkMgmtTypeId ELSE @TransType END ) AND
				A.StkMngRefNo=  (CASE @RefNo WHEN '0' THEN A.StkMngRefNo ELSE @RefNo END ) AND
				B.ReasonId=  (CASE @ReasonId WHEN 0 THEN B.ReasonId ELSE @ReasonId END ) AND
				A.StkMngDate BETWEEN @FromDate AND @ToDate

		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptMastStockManagement ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				 + 'WHERE A.LcnId=  (CASE '+ CAST(@LcnId AS NVARCHAR(10))+' WHEN 0 THEN A.LcnId ELSE' + CAST(@LcnId AS NVARCHAR(10))+ 'END ) AND
				   A.StkMgmtTypeId=  (CASE '+ CAST(@TransType AS NVARCHAR(10))+' WHEN 0 THEN A.StkMgmtTypeId ELSE' + CAST(@TransType AS NVARCHAR(10))+ 'END ) AND
				   A.StkMngRefNo=  (CASE '+ CAST(@RefNo AS NVARCHAR(25))+' WHEN ''0'' THEN A.StkMngRefNo ELSE' + CAST(@RefNo AS NVARCHAR(25))+ 'END ) AND
				   B.ReasonId=  (CASE '+ CAST(@ReasonId AS NVARCHAR(10))+' WHEN 0 THEN B.ReasonId ELSE' + CAST(@ReasonId AS NVARCHAR(10))+ 'END ) AND
				   A.StkMngDate BETWEEN '+CAST(@FromDate AS NVARCHAR(10))+' AND '+CAST(@ToDate AS NVARCHAR(10))


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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptMastStockManagement'
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		   END
		END
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		IF @ErrNo = 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptMastStockManagement ' +
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
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptMastStockManagement
	PRINT 'Data Executed'
	SELECT * FROM #RptMastStockManagement ORDER BY PrdCode

	RETURN
END
go

--SRF-Nanda-213-007

DELETE FROM CustomCaptions WHERE TransId=265
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','1','1','CoreHeaderTool','Purchase Mapping','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Purchase Mapping','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','1','2','CoreHeaderTool','Stocky','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Stocky','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','2','1','lblCmpInvNo','Company Inv No','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Company Inv No','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','3','1','lblInvDate','Invoice Date','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Invoice Date','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','4','1','lblSpmId','Supplier','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Supplier','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','5','1','fxtCmpInvNo','Company Inv No','Company Inv No','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Company Inv No','Company Inv No','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','6','1','dtpInvDate','Invoice Date','Invoice Date','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Invoice Date','Invoice Date','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','7','1','fxtSpmId','Supplier','Supplier','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Supplier','Supplier','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','8','1','chkDispPrdCCode','Display Stocky Product Code','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Display Stocky Product Code','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','9','0','btnOperation','&OK','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'&OK','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','10','2','DgCommon-265-10-2','Stocky Product Code','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Stocky Product Code','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','10','3','DgCommon-265-10-3','Stocky Product Name','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Stocky Product Name','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','10','4','DgCommon-265-10-4','Invoice Product Code','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Invoice Product Code','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','10','5','DgCommon-265-10-5','Invoice Product Name','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Invoice Product Name','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','10','6','DgCommon-265-10-6','UOM Code','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'UOM Code','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','10','7','DgCommon-265-10-7','Qty','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Qty','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','10','8','DgCommon-265-10-8','Rate','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Rate','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','10','9','DgCommon-265-10-9','Gross Amt','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Gross Amt','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','10','10','DgCommon-265-10-10','Disc Amt','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Disc Amt','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','10','11','DgCommon-265-10-11','Tax Amt','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Tax Amt','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) VALUES('265','10','12','DgCommon-265-10-12','Net Amt','','','1','1','1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'1',CONVERT(datetime,'2010-10-25 17:32:20.273',121),'Net Amt','','','1','1')

--SRF-Nanda-213-008

DELETE FROM RptGroup WHERE LTRIM(RTRIM(GrpCode))='Akso Nobal Reports'
DELETE FROM RptGroup WHERE RptId IN (221,222,220,225) 
DELETE FROM RptHeader WHERE RptId IN (221,222,220,225) 

--SRF-Nanda-213-009

DELETE FROM RptFormula WHERE RptId=220 AND Slno=3
INSERT INTO RptFormula
SELECT 220,3,'Rpt_PrdCtgLevel','Product Hierarchy Level',1,0

DELETE FROM RptFormula WHERE RptId=220 AND Slno=4
INSERT INTO RptFormula
SELECT 220,4,'Rpt_PrdCtgValue','Product Hierarchy Value',1,0

if not exists (select * from hotfixlog where fixid = 365)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(365,'D','2011-03-19',getdate(),1,'Core Stocky Service Pack 365')
