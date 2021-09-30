--[Stocky HotFix Version]=423
DELETE FROM Versioncontrol WHERE Hotfixid='423'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('423','3.1.0.3','D','2015-07-20','2015-07-20','2015-07-20',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
/*
    CR RELEASE DETAILS :    
	1. CCRSTPAR0097 -  Inactive bulletin board from console to be download in CS and should not be displayed. 
	   Only 10 days bulletin board to be displayed.
	2. CCRSTPAR0098-  Bill Design – Gramm age component to be incorporated in bill print template.
	3. CCRSTPAR0099-  Billing Hot search window display as per the attached order with product net weight
	4. CCRSTPAR0105-  Claim Top sheet to have additional 2 column to capture the Sales values with tax and Liability percentage of Parle. 
       To be checked with product team for
	5. CCRSTPAR0103-  Retailer Migration with sales man and route details
*/
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
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND Name = 'Proc_ClosingStockTaxCalCulation')
DROP PROCEDURE Proc_ClosingStockTaxCalCulation
GO
/*
  BEGIN TRANSACTION
  EXEC Proc_ClosingStockTaxCalCulation
  SELECT * FROM ClosingStockProductTaxPercent (NOLOCK)
  ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_ClosingStockTaxCalCulation]
AS
BEGIN
		DECLARE @TaxSettingDet TABLE       
		(      
			TaxSlab    INT,      
			ColNo      INT,      
			SlNo       INT,      
			BillSeqId  INT,      
			TaxSeqId   INT,      
			ColType    INT,       
			ColId      INT,      
			ColVal     NUMERIC(38,2),
			PrdId      NUMERIC(18,0)      
		) 
		
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
		--SELECT @PrdBatTaxGrp = TaxGroupId FROM Product A (NOLOCK) INNER JOIN TempClosingStock B (NOLOCK) ON A.PrdId = B.PrdId
		SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster (NOLOCK)
		SELECT @RtrTaxGrp = MAX(DISTINCT RtrId) FROM TaxSettingMaster A (NOLOCK) 
		INNER JOIN TaxGroupSetting B (NOLOCK) ON A.RtrId = B.TaxGroupId WHERE B.TaxGroup = 1
		
		INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,PrdId)      
		SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal,C.PrdId      
		FROM TaxSettingMaster A (NOLOCK) INNER JOIN	TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
		AND B.BillSeqId=@BillSeqId AND Coltype IN(1,3) 
		INNER JOIN 
		(SELECT DISTINCT A.PrdId,TaxGroupId FROM Product A (NOLOCK) INNER JOIN TempClosingStock B (NOLOCK) ON A.PrdId = B.PrdId) C 
		ON A.PrdId = C.TaxGroupId  WHERE A.RtrId = @RtrTaxGrp     
		AND A.TaxSeqId IN (SELECT ISNULL(MAX(TaxSeqId),0) FROM TaxSettingMaster 
		WHERE RtrId = @RtrTaxGrp AND PrdId = C.TaxGroupId)  
		TRUNCATE TABLE ClosingStockProductTaxPercent   
		      
		--To Get the Tax Percentage for the selected slab      
		SELECT PrdId,ColVal AS TaxPerc,TaxSlab INTO #TaxPercentage FROM @TaxSettingDet 
		WHERE ColType = 1 AND ColId = 0 AND ColVal > 0
		
		--Addtional Tax
		SELECT DISTINCT A.PrdId,A.TaxSlab,B.TaxPerc,CAST(1*(B.TaxPerc/100) AS NUMERIC(28,10)) AS TaxAmount
		INTO #ClosingStockAddTax FROM @TaxSettingDet A INNER JOIN #TaxPercentage B ON A.TaxSlab = B.TaxSlab 
		AND A.PrdId = B.PrdId WHERE ColType = 3 AND ColVal > 0 	
		
		SELECT DISTINCT A.PrdId,A.TaxSlab,B.TaxPerc,CAST(1*(B.TaxPerc/100) AS NUMERIC(28,10)) AS TaxAmount
		INTO #ClosingStockTax FROM @TaxSettingDet A INNER JOIN #TaxPercentage B ON A.TaxSlab = B.TaxSlab AND A.PrdId = B.PrdId
		WHERE ColVal > 0 AND NOT EXISTS (SELECT PrdId FROM #ClosingStockAddTax C WHERE A.PrdId = C.PrdId 
		AND A.TaxSlab = C.TaxSlab)
		
		INSERT INTO #ClosingStockTax (PrdId,TaxSlab,TaxPerc,TaxAmount)
		SELECT DISTINCT A.PrdId,A.TaxSlab,A.TaxPerc,CAST((B.TaxAmount * A.TaxAmount) AS NUMERIC(28,10)) AS TaxAmount
		FROM #ClosingStockAddTax A INNER JOIN #ClosingStockTax B ON A.PrdId = B.PrdId
		
		INSERT INTO ClosingStockProductTaxPercent(PrdId,TaxPercentage)
		SELECT DISTINCT PrdId,ISNULL(SUM(TaxAmount)*100,0) FROM #ClosingStockTax (NOLOCK) GROUP BY PrdId
		
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptCurrentStockParle')
DROP PROCEDURE Proc_RptCurrentStockParle
GO
--Exec Proc_RptCurrentStockParle 249,1,0,'PARLE',0,0,1,0
CREATE PROCEDURE [dbo].[Proc_RptCurrentStockParle]
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
		--Till Here
	--If Product Category Filter is available
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	--Till Here
	SELECT DISTINCT Prdid,U.ConversionFactor 
	Into #PrdUomBox
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	Inner Join UomMaster UM On U.UomId=Um.UomId
	Where Um.UomCode='BX'

	INSERT Into #PrdUomBox		
	SELECT DISTINCT Prdid,U.ConversionFactor
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	INNER JOIN UomMaster UM On U.UomId=Um.UomId
	Where  P.PrdId Not In (Select PrdId From #PrdUomBox) AND U.ConversionFactor > 1
			
	SELECT DISTINCT Prdid,U.ConversionFactor
	Into #PrdUomPack
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	Inner Join UomMaster UM On U.UomId=Um.UomId
	Where  P.PrdId Not In (Select PrdId From #PrdUomBox) And U.BaseUom='Y'
	
	Create Table #PrdUomAll
	(
		PrdId Int,
		ConversionFactor Int
	)
	Insert Into #PrdUomAll
	Select Distinct PrdId,ConversionFactor From #PrdUomBox
	Union All
	Select Distinct PrdId,ConversionFactor From #PrdUomPack
	SELECT Prdid,
			Case PrdUnitId 
			When 2 Then (PrdWgt/1000)/1000
			When 3 Then PrdWgt/1000 END AS PrdWgt
			Into #PrdWeight  From Product
			
			--select 'A',* from #PrdWeight
			
	Create TABLE #RptCurrentStock
	(
		PrdId            INT,
		PrdDcode         NVARCHAR(100),
		PrdName      NVARCHAR(200),
		PrdBatId         INT,
		PrdBatCode       NVARCHAR(100),
		MRP              NUMERIC (38,6),
		DisplayRate      NUMERIC (38,6),
		Saleable         INT,
		SaleableWgt	     NUMERIC (38,6),
		Unsaleable       INT,
		UnsaleableWgt	 NUMERIC (38,6),
		Offer            INT,
		OfferWgt		 NUMERIC (38,6),
		DisplaySalRate   NUMERIC (38,6),
		DisplayUnSalRate NUMERIC (38,6),
		DisplayTotRate   NUMERIC (38,6),
		StockType	     INT
		
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
						SaleableWgt	    NUMERIC (38,6),
						Unsaleable		INT,
						UnsaleableWgt	 NUMERIC (38,6),
						Offer           INT,
						OfferWgt		 NUMERIC (38,6),
						DisplaySalRate    NUMERIC (38,6),
						DisplayUnSalRate   NUMERIC (38,6),
						DisplayTotRate     NUMERIC (38,6),
						StockType		   INT'
	SET @TblFields = 'PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
	Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,StockType'
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
	     INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,StockType)
								SELECT VC.PrdId,PrdDcode,PrdName,0,0,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,1) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,(SUM(Saleable)* P.PrdWgt),
				SUM(Unsaleable) AS Unsaleable,(SUM(Unsaleable)* P.PrdWgt),
				SUM(Offer) AS Offer,(SUM(Offer)* P.PrdWgt),
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@StockType
				FROM dbo.View_CurrentStockReportParle VC LEFT OUTER JOIN #PrdWeight P ON VC.PrdId = P.PrdId 
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (VC.PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN VC.PrdId Else 0 END) OR
				VC.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (VC.PrdId = (CASE @fPrdId WHEN 0 THEN VC.PrdId Else 0 END) OR
				VC.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE -1 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))) 
				--AND	UsrId = @Pi_UsrId
				GROUP BY VC.PrdId,PrdDcode,PrdName,MRP,ListPrice,SelRate,P.PrdWgt Order By PrdDcode
				
				--UPDATE #RptCurrentStock 
				
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
	IF @SupZeroStock = 1
		BEGIN
        SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,MAX(A.DisplayRate) AS DisplayRate,
        Case When SUM(Saleable)<MAX(ConversionFactor) Then 0 Else SUM(Saleable)/MAX(ConversionFactor) End  As SaleableBOX,
		Case When SUM(Saleable)<MAX(ConversionFactor) Then SUM(Saleable) Else SUM(Saleable)%MAX(ConversionFactor) End  As SaleablePKT,
		Case When SUM(UnSaleable)<MAX(ConversionFactor) Then 0 Else SUM(UnSaleable)/MAX(ConversionFactor) End  As UnSaleableBOX,
		Case When SUM(UnSaleable)<MAX(ConversionFactor) Then SUM(UnSaleable) Else SUM(UnSaleable)%MAX(ConversionFactor) End  As UnSaleablePKT,
		Case When SUM(Offer)<MAX(ConversionFactor) Then 0 Else SUM(Offer)/MAX(ConversionFactor) End  As OfferBOX,
		Case When SUM(Offer)<MAX(ConversionFactor) Then SUM(Offer) Else SUM(Offer)%MAX(ConversionFactor) End As OfferPKT,
        SUM(A.DisplaySalRate) AS DisplaySalRate,SUM(A.DisplayUnSalRate) AS DisplayUnSalRate,SUM(A.DisplayTotRate) AS DisplayTotRate,A.StockType 
		FROM #RptCurrentStock A,#PrdUomAll B WHERE A.Prdid = B.Prdid 
	    GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,A.StockType Having SUM(A.Saleable + A.UnSaleable + A.Offer)<>0 Order By A.PrdDcode
			IF EXISTS(SELECT * FROM Sysobjects WHERE Name = 'RptCurrentStockReportParle_Excel' And XTYPE = 'U')
	        DROP TABLE RptCurrentStockReportParle_Excel
			SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,MAX(A.DisplayRate) AS DisplayRate,
			Case When SUM(Saleable)<MAX(ConversionFactor) Then 0 Else SUM(Saleable)/MAX(ConversionFactor) End  As SaleableBOX,
			Case When SUM(Saleable)<MAX(ConversionFactor) Then SUM(Saleable) Else SUM(Saleable)%MAX(ConversionFactor) End  As SaleablePKT,
			Case When SUM(UnSaleable)<MAX(ConversionFactor) Then 0 Else SUM(UnSaleable)/MAX(ConversionFactor) End  As UnSaleableBOX,
			Case When SUM(UnSaleable)<MAX(ConversionFactor) Then SUM(UnSaleable) Else SUM(UnSaleable)%MAX(ConversionFactor) End  As UnSaleablePKT,
			Case When SUM(Offer)<MAX(ConversionFactor) Then 0 Else SUM(Offer)/MAX(ConversionFactor) End  As OfferBOX,
			Case When SUM(Offer)<MAX(ConversionFactor) Then SUM(Offer) Else SUM(Offer)%MAX(ConversionFactor) End As OfferPKT,
			SUM(A.DisplaySalRate) AS DisplaySalRate,SUM(A.DisplayUnSalRate) AS DisplayUnSalRate,SUM(A.DisplayTotRate) AS DisplayTotRate,A.StockType 
			INTO RptCurrentStockReportParle_Excel FROM #RptCurrentStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId
			GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,A.StockType Having SUM(A.Saleable + A.UnSaleable + A.Offer)<>0 Order By A.PrdDcode
		    DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
		END
		ELSE
		BEGIN
			SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,MAX(A.DisplayRate) AS DisplayRate,
			Case When SUM(Saleable)<MAX(ConversionFactor) Then 0 Else SUM(Saleable)/MAX(ConversionFactor) End  As SaleableBOX,
			Case When SUM(Saleable)<MAX(ConversionFactor) Then SUM(Saleable) Else SUM(Saleable)%MAX(ConversionFactor) End  As SaleablePKT,
			Case When SUM(UnSaleable)<MAX(ConversionFactor) Then 0 Else SUM(UnSaleable)/MAX(ConversionFactor) End  As UnSaleableBOX,
			Case When SUM(UnSaleable)<MAX(ConversionFactor) Then SUM(UnSaleable) Else SUM(UnSaleable)%MAX(ConversionFactor) End  As UnSaleablePKT,
			Case When SUM(Offer)<MAX(ConversionFactor) Then 0 Else SUM(Offer)/MAX(ConversionFactor) End  As OfferBOX,
			Case When SUM(Offer)<MAX(ConversionFactor) Then SUM(Offer) Else SUM(Offer)%MAX(ConversionFactor) End As OfferPKT,
            SUM(A.DisplaySalRate) AS DisplaySalRate,SUM(A.DisplayUnSalRate) AS DisplayUnSalRate,SUM(A.DisplayTotRate) AS DisplayTotRate,A.StockType 
			FROM #RptCurrentStock A,#PrdUomAll B WHERE A.Prdid = B.Prdid 
            GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,A.StockType Order By A.PrdDcode
				IF EXISTS(SELECT * FROM Sysobjects WHERE Name = 'RptCurrentStockReportParle_Excel' And XTYPE = 'U')
				DROP TABLE RptCurrentStockReportParle_Excel
				SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,MAX(A.DisplayRate) AS DisplayRate,
				Case When SUM(Saleable)<MAX(ConversionFactor) Then 0 Else SUM(Saleable)/MAX(ConversionFactor) End  As SaleableBOX,
				Case When SUM(Saleable)<MAX(ConversionFactor) Then SUM(Saleable) Else SUM(Saleable)%MAX(ConversionFactor) End  As SaleablePKT,
				Case When SUM(UnSaleable)<MAX(ConversionFactor) Then 0 Else SUM(UnSaleable)/MAX(ConversionFactor) End  As UnSaleableBOX,
				Case When SUM(UnSaleable)<MAX(ConversionFactor) Then SUM(UnSaleable) Else SUM(UnSaleable)%MAX(ConversionFactor) End  As UnSaleablePKT,
				Case When SUM(Offer)<MAX(ConversionFactor) Then 0 Else SUM(Offer)/MAX(ConversionFactor) End  As OfferBOX,
				Case When SUM(Offer)<MAX(ConversionFactor) Then SUM(Offer) Else SUM(Offer)%MAX(ConversionFactor) End As OfferPKT,
				SUM(A.DisplaySalRate) AS DisplaySalRate,SUM(A.DisplayUnSalRate) AS DisplayUnSalRate,SUM(A.DisplayTotRate) AS DisplayTotRate,A.StockType 
				INTO RptCurrentStockReportParle_Excel FROM #RptCurrentStock A,#PrdUomAll B WHERE A.Prdid = B.Prdid 
				GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,A.StockType Order By A.PrdDcode
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock
			
		END
		RETURN
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
	  ProductCode NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
	  MapProductCode NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_UpdateStockLedger' AND TYPE='P')
DROP PROCEDURE Proc_UpdateStockLedger
GO
/*
BEGIN TRAN
EXEC Proc_UpdateStockLedger 7,1,5078,35664,1,'2015-03-27',1,1,0
ROLLBACK TRAN
*/
CREATE Procedure Proc_UpdateStockLedger
(
	@Pi_ColId   INT,
	@Pi_Type  INT,
	@Pi_PrdId  INT,
	@Pi_PrdBatId  INT,
	@Pi_LcnId  INT,
	@Pi_TranDate  DateTime,
	@Pi_TranQty  Numeric(38,0),
	@Pi_UsrId  INT,
	@Pi_ErrNo  INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UpdateStockLedger
* PURPOSE	: To Update StockLedger
* CREATED	: Thrinath
* CREATED DATE	: 05/01/2007
* NOTE		: General SP for Updating StockLedger
* MODIFIED BY : Boopathy On 23/03/2009 For Updating the Con
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	Declare @sSql as VARCHAR(2500)
	Declare @FldName as VARCHAR(100)
	Declare @ErrNo as INT
	DECLARE @LastTranDate  DATETIME
	DECLARE @OldValue	AS NUMERIC(38,6)
	DECLARE @MaxDate AS DATETIME
	DECLARE @CurVal	 AS NUMERIC(38,6)
	IF EXISTS (SELECT PrdId FROM Product Where PrdId = @Pi_PrdId and PrdType = 3)
	BEGIN
		--IF Product is a KIT Item Return True
		Set @Pi_ErrNo = 0
		RETURN
	END
	BEGIN TRY --Code added by Muthuvel for Inventory check
		SELECT @OldValue=SUM(((B.SalPurchase+B.UnsalPurchase)-(B.SalSales+B.UnSalSales)+
				(-B.SalPurReturn-B.UnsalPurReturn+B.SalStockIn+B.UnSalStockIn-
				B.SalStockOut-B.UnSalStockOut+B.SalSalesReturn+B.UnSalSalesReturn+
				B.SalStkJurIn+B.UnSalStkJurIn-B.SalStkJurOut-B.UnSalStkJurOut+
				B.SalBatTfrIn+B.UnSalBatTfrIn-B.SalBatTfrOut-B.UnSalBatTfrOut+
				B.SalLcnTfrIn+B.UnSalLcnTfrIn-B.SalLcnTfrOut-B.UnSalLcnTfrOut+
				B.SalReplacement+B.DamageIn-B.DamageOut)) * PrdBatDetailValue) --AS StkValue
				FROM ProductBatchDetails A, StockLedger B,BatchCreation C 
				WHERE A.PrdBatId=B.PrdbatId AND A.DefaultPrice=1
				AND A.BatchSeqId=C.BatchSeqId AND C.ListPrice=1 AND A.SlNo=C.SlNo
				AND B.TransDate=@Pi_TranDate AND B.PrdId=@Pi_PrdId AND B.PrdBatId=@Pi_PrdBatId
				AND B.LcnId=@Pi_LcnId
		SET @OldValue =ISNULL(@OldValue,0)
		IF NOT EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
		and PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
		and TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121))
		BEGIN
			INSERT INTO StockLedger
			(
			TransDate,LcnId,PrdId,PrdBatId,SalOpenStock,UnSalOpenStock,
			OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,
			SalPurReturn,UnsalPurReturn,OfferPurReturn,
			SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,
			OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,
			DamageOut,SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,
			SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,
			UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,
			OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,
			SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,
			UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,
			SalClsStock,UnSalClsStock,OfferClsStock,Availability,
			LastModBy,LastModDate,AuthId,AuthDate
			) VALUES
			(
			@Pi_TranDate,@Pi_LcnId,@Pi_PrdId,@Pi_PrdBatId,0,0,
			0,0,0,0,
			0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,1,
			@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate
			)
		 END
		 EXEC Proc_UpdateOpeningStock @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,@Pi_UsrId,@ErrNo
		 IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 2)
		 BEGIN
			UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 2
		 END
		
		 IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 11)
		 BEGIN
			UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 11
		 END
		 IF @Pi_ColId BETWEEN 7 AND 9
		 BEGIN
			IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 1)
			BEGIN
				UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 1
			END
		 END
		 IF @Pi_ColId BETWEEN 1 AND 3
		 BEGIN
			IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 3)
			BEGIN
				UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 3
			END
		 END
		 IF @Pi_ColId BETWEEN 18 AND 20
		 BEGIN
			IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 4)
			BEGIN
				UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 4
			END
		 END
		 Select @FldName = CASE @Pi_ColId
			  WHEN 1 THEN 'SalPurchase'
			  WHEN 2 THEN 'UnsalPurchase'
			  WHEN 3 THEN 'OfferPurchase'
			  WHEN 4 THEN 'SalPurReturn'
			  WHEN 5 THEN 'UnsalPurReturn'
			  WHEN 6 THEN 'OfferPurReturn'
			  WHEN 7 THEN 'SalSales'
			  WHEN 8 THEN 'UnSalSales'
			  WHEN 9 THEN 'OfferSales'
			  WHEN 10 THEN 'SalStockIn'
			  WHEN 11 THEN 'UnSalStockIn'
			  WHEN 12 THEN 'OfferStockIn'
			  WHEN 13 THEN 'SalStockOut'
			  WHEN 14 THEN 'UnSalStockOut'
			  WHEN 15 THEN 'OfferStockOut'
			  WHEN 16 THEN 'DamageIn'
			  WHEN 17 THEN 'DamageOut'
			  WHEN 18 THEN 'SalSalesReturn'
			  WHEN 19 THEN 'UnSalSalesReturn'
			  WHEN 20 THEN 'OfferSalesReturn'
			  WHEN 21 THEN 'SalStkJurIn'
			  WHEN 22 THEN 'UnSalStkJurIn'
			  WHEN 23 THEN 'OfferStkJurIn'
			  WHEN 24 THEN 'SalStkJurOut'
			  WHEN 25 THEN 'UnSalStkJurOut'
			  WHEN 26 THEN 'OfferStkJurOut'
			  WHEN 27 THEN 'SalBatTfrIn'
			  WHEN 28 THEN 'UnSalBatTfrIn'
			  WHEN 29 THEN 'OfferBatTfrIn'
			  WHEN 30 THEN 'SalBatTfrOut'
			  WHEN 31 THEN 'UnSalBatTfrOut'
			  WHEN 32 THEN 'OfferBatTfrOut'
			  WHEN 33 THEN 'SalLcnTfrIn'
			  WHEN 34 THEN 'UnSalLcnTfrIn'
			  WHEN 35 THEN 'OfferLcnTfrIn'
			  WHEN 36 THEN 'SalLcnTfrOut'
			  WHEN 37 THEN 'UnSalLcnTfrOut'
			  WHEN 38 THEN 'OfferLcnTfrOut'
			  WHEN 39 THEN 'SalReplacement'
			  WHEN 40 THEN 'OfferReplacement' END
		 SET @Pi_ErrNo = 0
		 IF (@Pi_ColId = 4  OR @Pi_ColId = 7  OR @Pi_ColId = 13
			 OR @Pi_ColId = 24 OR @Pi_ColId = 30 OR @Pi_ColId = 36 OR @Pi_ColId = 39) AND @Pi_Type = 1
		 BEGIN
			  IF EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
			   AND PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
			   AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
			   AND (SalOpenStock    +
					SalPurchase     +
					SalStockIn    +
					SalSalesReturn   +
					SalStkJurIn   +
					SalBatTfrIn   +
					SalLcnTfrIn   -
					SalPurReturn   -
					SalSales     -
					SalStockOut  -	
					SalStkJurOut   -
					SalBatTfrOut   -
					SalLcnTfrOut   -
					SalReplacement) < @Pi_TranQty)
				  BEGIN
					   SET @Pi_ErrNo = 1
				  END
		 END
		 IF (@Pi_ColId = 5 OR @Pi_ColId = 8 OR @Pi_ColId = 14 OR @Pi_ColId = 17
			 OR @Pi_ColId = 25 OR @Pi_ColId = 31 OR @Pi_ColId = 37) AND @Pi_Type = 1
		 BEGIN
			  IF EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
			   AND PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
			   AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
			   AND (UnSalOpenStock    +
					UnSalPurchase   +
					UnSalStockIn    +
					DamageIn      +
					UnSalSalesReturn  +
					UnSalStkJurIn    +
					UnSalBatTfrIn   +
					UnSalLcnTfrIn    -
					UnsalPurReturn  -
					UnSalSales   -
					UnSalStockOut   -
					DamageOut    -
					UnSalStkJurOut   -
					UnSalBatTfrOut   -
					UnSalLcnTfrOut) < @Pi_TranQty)
				  BEGIN
					   SET @Pi_ErrNo = 1
				  END
		 END
		 IF (@Pi_ColId = 6 OR @Pi_ColId = 9 OR @Pi_ColId = 15 OR @Pi_ColId = 26
			  OR @Pi_ColId = 32 OR @Pi_ColId = 38 OR @Pi_ColId = 40) AND @Pi_Type = 1
		 BEGIN
			  IF EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
			   AND PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
			   AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
			   AND (OfferOpenStock    +
					OfferPurchase    +
					OfferStockIn     +
					OfferSalesReturn   +
					OfferStkJurIn   +
					OfferBatTfrIn   +
					OfferLcnTfrIn   -
					OfferPurReturn   -
					OfferSales      -
					OfferStockOut   -
					OfferStkJurOut   -
					OfferBatTfrOut   -
					OfferLcnTfrOut   -
					OfferReplacement) < @Pi_TranQty)
				  BEGIN
					   SET @Pi_ErrNo = 1
				  END
		 END
		 IF @Pi_ErrNo = 0
		 BEGIN
			  SET @sSql = 'Update StockLedger Set ' + @FldName + ' = ' + @FldName + ' + '
			  SET @sSql = @sSql + CASE @Pi_Type WHEN 2 Then '-1' Else '1' End + '* '
			  SET @sSql = @sSql + CAST(@Pi_TranQty as VARCHAR(10))
			  SET @sSql = @sSql + ', LastModDate = ''' + CONVERT(VARCHAR(10),GetDate(),121) + ''''
			  SET @sSql = @sSql + ', AuthDate = ''' + CONVERT(VARCHAR(10),GetDate(),121) + ''''
			  SET @sSql = @sSql + ', LastModBy = ' + CAST(@Pi_UsrId as VARCHAR(10))
			  SET @sSql = @sSql + ', AuthId = ' + CAST(@Pi_UsrId as VARCHAR(10)) + ' Where'
			  SET @sSql = @sSql + ' PrdId = ' + CAST(@Pi_PrdId as VARCHAR(10))
			  SET @sSql = @sSql + ' AND PrdBatId = ' + CAST(@Pi_PrdBatId as VARCHAR(10))
			  SET @sSql = @sSql + ' AND LcnId = ' + CAST(@Pi_LcnId as VARCHAR(10))
			  SET @sSql = @sSql + ' AND TransDate = ''' + CONVERT(VARCHAR(10),@Pi_TranDate,121) + ''''
			  Exec (@sSql)
		
			  EXEC Proc_UpdateClosingStock @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,@Pi_UsrId,@Pi_ClsErrNo = @ErrNo OutPut
			  IF @Pi_ErrNo = 0 AND @ErrNo = 1
			  BEGIN
				   Set @Pi_ErrNo = 1
			  END
			  Select @LastTranDate = ISNULL(MAX(TransDate),CONVERT(VARCHAR(10),'1981-05-30',121)) from
			   StockLedger where PrdId=@Pi_PrdId and PrdBatId=@Pi_PrdBatId
			   and LcnId=@Pi_LcnId and TransDate > @Pi_TranDate
			  IF @LastTranDate <> '1981-05-30'
			  BEGIN
				   SELECT @Pi_TranDate = DATEADD(DAY,1,@Pi_TranDate)
				   WHILE @Pi_TranDate <= @LastTranDate
				   BEGIN
						EXEC Proc_UpdateOpeningStock @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,@Pi_UsrId,@Pi_OpnErrNo = @ErrNo OutPut
						SELECT @Pi_TranDate = DATEADD(DAY,1,@Pi_TranDate)
						IF @Pi_ErrNo = 0 AND @ErrNo = 1
						BEGIN
							 Set @Pi_ErrNo = 1
						END
				   END
			  END
	 			IF EXISTS (SELECT TransDate FROM ConsolidateStockLedger WHERE 
							TransDate=@Pi_TranDate)
				BEGIN
							SELECT @CurVal=SUM(((B.SalPurchase+B.UnsalPurchase)-(B.SalSales+B.UnSalSales)+
							(-B.SalPurReturn-B.UnsalPurReturn+B.SalStockIn+B.UnSalStockIn-
							B.SalStockOut-B.UnSalStockOut+B.SalSalesReturn+B.UnSalSalesReturn+
							B.SalStkJurIn+B.UnSalStkJurIn-B.SalStkJurOut-B.UnSalStkJurOut+
							B.SalBatTfrIn+B.UnSalBatTfrIn-B.SalBatTfrOut-B.UnSalBatTfrOut+
							B.SalLcnTfrIn+B.UnSalLcnTfrIn-B.SalLcnTfrOut-B.UnSalLcnTfrOut+
							B.SalReplacement+B.DamageIn-B.DamageOut)) * PrdBatDetailValue) --AS StkValue
							FROM ProductBatchDetails A, StockLedger B,BatchCreation C 
							WHERE A.PrdBatId=B.PrdbatId AND A.DefaultPrice=1
							AND A.BatchSeqId=C.BatchSeqId AND C.ListPrice=1 AND A.SlNo=C.SlNo
							AND B.TransDate=@Pi_TranDate AND B.PrdId=@Pi_PrdId AND B.PrdBatId=@Pi_PrdBatId
							AND B.LcnId=@Pi_LcnId
							UPDATE ConsolidateStockLedger SET StockValue=  StockValue + ABS(@OldValue) - ABS(@CurVal) ---(@CurStkVal*-1)
							WHERE TransDate=@Pi_TranDate
				
							UPDATE ConsolidateStockLedger SET StockValue=  StockValue + ABS(@OldValue)  - ABS(@CurVal) --(@CurStkVal*-1)
							WHERE TransDate>@Pi_TranDate
				END
				ELSE
				BEGIN
					INSERT INTO ConsolidateStockLedger
						SELECT @Pi_TranDate,ISNULL((@Pi_TranQty * PrdBatDetailValue),0) AS StkValue
						FROM ProductBatchDetails A, StockLedger B,BatchCreation C 
						WHERE A.PrdBatId=B.PrdbatId AND A.DefaultPrice=1
						AND A.BatchSeqId=C.BatchSeqId AND C.ListPrice=1 AND A.SlNo=C.SlNo
						AND B.TransDate=@Pi_TranDate AND B.PrdId=@Pi_PrdId AND B.PrdBatId=@Pi_PrdBatId
						AND B.LcnId=@Pi_LcnId
						SELECT @CurVal=StockValue FROM ConsolidateStockLedger WHERE TransDate=@Pi_TranDate
						SELECT @MaxDate=MAX(TransDate) FROM ConsolidateStockLedger WHERE TransDate<@Pi_TranDate
						UPDATE ConsolidateStockLedger SET StockValue=  @CurVal + (SELECT DISTINCT StockValue FROM
						ConsolidateStockLedger WHERE TransDate=@MaxDate) WHERE TransDate=@Pi_TranDate
				END
		END
	/*Code added by Muthuvel for Inventory check begins here*/
	END TRY
	BEGIN CATCH
		SET @Pi_ErrNo = 1
	END CATCH
	/*Code added by Muthuvel for Inventory check ends here*/
	IF @Pi_ErrNo = 0
	BEGIN
		IF NOT EXISTS(SELECT * FROM StockLedgerDateCheck WHERE LastTransDate>=@Pi_TranDate)
		BEGIN
			TRUNCATE TABLE StockLedgerDateCheck 
			INSERT INTO StockLedgerDateCheck(LastColId,LastTransDate)
			VALUES(@Pi_ColId,@Pi_TranDate)
		END	
	END
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
	
	SELECT DISTINCT A.PrdId,A.PrdBatId,MAX(A.PriceId) AS PriceId INTO #ExistinPriceCloning 
	FROM @ExistingSellingPriceDetails A 
	INNER JOIN @ExistingListPriceDetails B ON A.PrdId = B.PrdId
	AND A.PrdBatId = B.PrdBatId AND A.PriceId = B.PriceId GROUP BY A.PrdId,A.PrdBatId
	
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
    
	SELECT DISTINCT CAST(DENSE_RANK() OVER (ORDER BY MAX(PrdBatId),MRP,ListPrice,SellingRate,ClaimRate) AS NUMERIC(18,0))+@BatchPriceId AS PriceId,
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
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'U' AND Name = 'TempSpecialRateDiscountProduct')
DROP TABLE TempSpecialRateDiscountProduct
GO
CREATE TABLE [dbo].[TempSpecialRateDiscountProduct](
	[SlNo] [BIGINT] IDENTITY(1,1) NOT NULL,
	[CtgLevelName] [NVARCHAR](100) NULL,
	[CtgCode] [NVARCHAR](100) NULL,
	[RtrCode] [NVARCHAR](100) NULL,
	[PrdCCode] [NVARCHAR](100) NULL,
	[PrdBatCode] [NVARCHAR](100) NULL,
	[DiscPer] [NUMERIC](18, 2) NULL,
	[SpecialSellingRate] [NUMERIC](38, 6) NULL,
	[EffectiveFromDate] [DATETIME] NULL,
	[EffectiveToDate] [DATETIME] NULL,
	[CreatedDate] [DATETIME] NULL,
	[ApplyOn] [TINYINT] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE XTYPE = 'P' AND name = 'Proc_CalculateSpecialDiscountAftRate')
DROP PROCEDURE Proc_CalculateSpecialDiscountAftRate
GO
--EXEC Proc_CalculateSpecialDiscountAftRate
CREATE PROCEDURE [dbo].[Proc_CalculateSpecialDiscountAftRate]
AS  
BEGIN
     --Added by SAthishkumar Veeramani 2015/04/01
	 DECLARE @SplDiscountToAvoid TABLE
	 (
	   RetCategoryLevel       NVARCHAR(100),
	   RetCatLevelValue       NVARCHAR(100),
	   PrdCategoryLevel       NVARCHAR(100),
	   PrdCategoryLevelValue  NVARCHAR(100)
	 )    
     INSERT INTO @SplDiscountToAvoid (RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue)
     SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE (ApplyOn = '' OR ApplyOn IS NULL)
     
     INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	 SELECT DISTINCT 1,'Cn2Cs_Prk_SpecialDiscount','Apply On','Apply On Should Not be Empty or Null-'+PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE (ApplyOn = '' OR ApplyOn IS NULL)
     
     INSERT INTO @SplDiscountToAvoid (RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue)
     SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) NOT IN ('MRP','SELLINGRATE','PURCHASERATE')
     
     INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	 SELECT DISTINCT 1,'Cn2Cs_Prk_SpecialDiscount','Apply On','Apply On Should Not be in MRP Or SELLINGRATE Or PURCHASERATE-'+PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) NOT IN ('MRP','SELLINGRATE','PURCHASERATE')
     --Till Here
	 
	 EXEC Proc_GR_Build_PH  
	 TRUNCATE TABLE TempSpecialRateDiscountProduct
	 DELETE FROM Cn2Cs_Prk_SpecialDiscount where DownLoadFlag='Y'   
	 INSERT INTO TempSpecialRateDiscountProduct (CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,DiscPer,SpecialSellingRate,EffectiveFromDate,
     EffectiveToDate,CreatedDate,ApplyOn)
	 SELECT DISTINCT A.RetCategoryLevel,A.RetCatLevelValue,'ALL',ProductCode,PrdBatCode,DiscPer,
	 PrdBatDetailValue-(PrdBatDetailValue*(DiscPer/100)) SplRate,EffFromDate,EffToDate,CreatedDate,ApplyOn FROM (  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.COMPANY_Code  
	 WHERE CP.PrdCategoryLevel='COMPANY' and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue) 
	 UNION   
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.Category_Code  
	 WHERE CP.PrdCategoryLevel='Category'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue) 
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.Brand_Code  
	 WHERE CP.PrdCategoryLevel='Brand'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue) 
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.PriceSlot_Code  
	 WHERE CP.PrdCategoryLevel='PriceSlot'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue)  
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.Flavor_Code  
	 WHERE CP.PrdCategoryLevel='Flavor'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue)
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.ProductCode  
	 WHERE CP.PrdCategoryLevel='Product'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue)
	 UNION
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.ProductCode  
	 WHERE CP.DownloadFlag='D' AND NOT EXISTS (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue 
	 FROM @SplDiscountToAvoid SA WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue 
	 AND CP.PrdCategoryLevel = SA.PrdCategoryLevel AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue))A  
	 INNER JOIN Product P (NOLOCK) ON P.PrdId=A.PrdId and A.ProductCode=P.PrdCCode  
	 INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=P.PrdId  
	 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId=PB.PrdBatId  
	 INNER JOIN BatchCreation BC (NOLOCK) ON BC.SlNo=PBD.SLNo AND BC.SlNo = A.ApplyOn
	 --INNER JOIN Configuration C (NOLOCK) ON BC.SlNo = ISNULL(CAST(C.ConfigValue AS INT),0)
	 WHERE PBD.DefaultPrice=1 --AND C.ModuleId = 'SPLDISC'
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
	  PrdCCode     NVARCHAR (200) COLLATE SQL_Latin1_General_CP1_CI_AS,
	  TaxGrpCode   NVARCHAR (200) COLLATE SQL_Latin1_General_CP1_CI_AS
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
	(SELECT DISTINCT PrdCode,COUNT(DISTINCT TaxGroupCode) AS Counts FROM Etl_Prk_TaxMapping A (NOLOCK) WHERE
	NOT EXISTS (SELECT PrdCCode,TaxGrpCode FROM #ToAvoidTaxGroup B WHERE A.PrdCode = B.PrdCCode AND A.TaxGroupCode = B.TaxGrpCode) 
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
IF EXISTS(SELECT * FROM Sysobjects where name='Proc_RptLoadSheetItemWiseParle' and Xtype='P')
DROP PROCEDURE Proc_RptLoadSheetItemWiseParle
GO
--EXEC Proc_RptLoadSheetItemWiseParle 251,1,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptLoadSheetItemWiseParle    
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
* CREATED BY : Gunasekaran    
* CREATED DATE : 18/07/2007    
* NOTE  :    
* MODIFIED :    
* DATE      AUTHOR     DESCRIPTION    
------------------------------------------------    
* {date} {developer}  {brief modification description}    
Modified by Praveenraj B For Parle LoadingSheet CR On 27/01/2012    
* 02/07/2013 Jisha Mathew PARLECS/0613/008     
* 11/11/2013 Jisha Mathew Bug No:30616    
*************************************************************/    
SET NOCOUNT ON    
BEGIN    
 DECLARE @NewSnapId  AS INT    
 DECLARE @DBNAME  AS  nvarchar(50)    
 DECLARE @TblName  AS nvarchar(500)    
 DECLARE @TblStruct  AS nVarchar(4000)    
 DECLARE @TblFields  AS nVarchar(4000)    
 DECLARE @sSql  AS  nVarChar(4000)    
 DECLARE @ErrNo   AS INT    
 DECLARE @PurDBName AS nVarChar(50)    
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
 DECLARE @FromDate    AS DATETIME    
 DECLARE @ToDate      AS DATETIME    
 DECLARE @VehicleId     AS  INT    
 DECLARE @VehicleAllocId AS INT    
 DECLARE @SMId   AS INT    
 DECLARE @DlvRouteId AS INT    
 DECLARE @RtrId   AS INT    
 DECLARE @UOMId   AS INT    
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
   [SalId]      INT,    
   [BillNo]     NVARCHAR (100),    
   [PrdId]               INT,    
   [PrdBatId]     INT,    
   [Product Code]        NVARCHAR (100),    
   [Product Description] NVARCHAR(150),    
  [PrdCtgValMainId]   INT,     
   [CmpPrdCtgId]    INT,    
   [Batch Number]        NVARCHAR(50),    
   [MRP]      NUMERIC (38,6) ,    
   [Selling Rate]    NUMERIC (38,6) ,    
   [Billed Qty]          NUMERIC (38,0),    
   [Free Qty]            NUMERIC (38,0),    
   [Return Qty]          NUMERIC (38,0),    
   [Replacement Qty]     NUMERIC (38,0),    
   [Total Qty]           NUMERIC (38,0),    
   [PrdWeight]     NUMERIC (38,4),    
   [PrdSchemeDisc]    NUMERIC (38,2),    
   [GrossAmount]    NUMERIC (38,2),    
   [TaxAmount]     NUMERIC (38,2),    
   [NetAmount]     NUMERIC (38,2),    
   [TotalBills]    NUMERIC (38,0),    
   [TotalDiscount]    NUMERIC (38,2),    
   [OtherAmt]     NUMERIC (38,2),    
   [AddReduce]     NUMERIC (38,2),    
   [Damage]              NUMERIC (38,2),    
   [BX]                  NUMERIC (38,0),    
   [PB]                  NUMERIC (38,0),    
   [JAR]      NUMERIC (38,0),    
   [PKT]                 NUMERIC (38,0),    
   [CN]      NUMERIC (38,0),    
   [GB]                  NUMERIC (38,0),    
   [ROL]                 NUMERIC (38,0),    
   [TOR]                 NUMERIC (38,0),    
   [CTN]         NUMERIC (38,0),    
   [TN]         NUMERIC (38,0),    
   [CAR]         NUMERIC (38,0),    
   [PC]         NUMERIC (38,0),    
   [TotalQtyBX]          NUMERIC (38,0),    
   [TotalQtyPB]          NUMERIC (38,0),    
   [TotalQtyPKT]         NUMERIC (38,0),    
   [TotalQtyJAR]         NUMERIC (38,0),    
   [TotalQtyCN]    NUMERIC (38,0),    
   [TotalQtyGB]          NUMERIC (38,0),    
   [TotalQtyROL]         NUMERIC (38,0),    
   [TotalQtyTOR]         NUMERIC (38,0),    
   [TotalQtyCTN]         NUMERIC (38,0),    
   [TotalQtyTN]         NUMERIC (38,0),    
   [TotalQtyCAR]         NUMERIC (38,0),    
   [TotalQtyPC]         NUMERIC (38,0),       
 )    
     
 --IF @Pi_GetFromSnap = 0  --To Generate For New Report Data    
 --BEGIN    
  IF @FromBillNo <> 0 Or @ToBillNo <> 0    
  BEGIN    
   INSERT INTO #RptLoadSheetItemWiseParle1([SalId],[BillNo],[PrdId],[PrdBatId],[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],    
    [Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],    
    [TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[CTN],[TN],[CAR],[PC],    
    [TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR],[TotalQtyCTN],    
    [TotalQtyTN],[TotalQtyCAR],[TotalQtyPC])--select * from RtrLoadSheetItemWise    
     
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
--       RI.SalId in (Select Selvalue from ReportfilterDt Where Rptid = @Pi_RptId and Usrid =@Pi_UsrId))    
     
 GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],    
 NetAmount,[GrossAmount],[TaxAmount],PrdCtgValMainId,CmpPrdCtgId    
  END     
  ELSE    
  BEGIN    
   INSERT INTO #RptLoadSheetItemWiseParle1([SalId],BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],    
     [Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],    
     [TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[CTN],[TN],[CAR],[PC],    
     [TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR],    
     [TotalQtyCTN],[TotalQtyTN],[TotalQtyCAR],[TotalQtyPC])    
       
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
0 AS [GB],0 AS [ROL],0 AS [TOR],0 AS [CTN],0 AS [TN],0 AS [CAR],0 AS [PC],    
0 AS TotalQtyBX,0 AS TotalQtyPB,0 AS TotalQtyPKT,0 AS TotalQtyJAR,0 AS [TotalQtyCN],0 AS [TotalQtyGB],0 AS [TotalQtyROL],0 AS [TotalQtyTOR],    
0 AS [TotalQtyCTN],0 AS [TotalQtyTN],0 AS [TotalQtyCAR],0 AS [TotalQtyPC]    
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
   SET @Converted=0    
   SET @Remainder=0       
   SET @TotConverted=0    
   SET @TotRemainder=0        
   DECLARE CUR_UOMGROUP CURSOR    
   FOR     
   SELECT DISTINCT UOMID,CONVERSIONFACTOR FROM (    
   SELECT A.UOMID,CONVERSIONFACTOR FROM UOMMASTER A WITH (NOLOCK)     
   INNER JOIN UOMGROUP B WITH (NOLOCK) ON A.UomId = B.UomId INNER JOIN PRODUCT C WITH (NOLOCK)    
   ON C.UOMGROUPID=B.UOMGROUPID WHERE PRDID=@PrdId AND A.UOMCODE IN ('BX','GB','CN','PB','JAR','TOR','PKT','ROL','CTN','TN','PC','CAR')) UOM ORDER BY CONVERSIONFACTOR DESC     
   OPEN CUR_UOMGROUP    
   FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR    
   WHILE @@FETCH_STATUS=0    
   BEGIN     
     SELECT @COLUOM=UOMCODE FROM UomMaster WITH (NOLOCK) WHERE UOMID=@FUOMID    
     IF @BaseQty >= @FCONVERSIONFACTOR    
     BEGIN    
      SET @Converted=CAST(@BaseQty/@FCONVERSIONFACTOR as INT)    
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
      SET @TotConverted=CAST(@TotalQty/@FCONVERSIONFACTOR as INT)    
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
    0 AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],([BX]+[GB]) AS BilledQtyBox,(([PB])+([JAR]+[CN]+[TOR]+[TN]+[CAR])) AS BilledQtyPouch,    
    ([PKT]+[ROL]+[CTN]+[PC]) AS BilledQtyPack,SUM([Total Qty]) AS [Total Qty],SUM(TotalQtyBX+TotalQtyGB) AS TotalQtyBOX,    
    SUM(TotalQtyPB+TotalQtyJAR+TotalQtyCN+TotalQtyTOR+TotalQtyTN+TotalQtyCAR) AS TotalQtyPouch,SUM(TotalQtyPKT+TotalQtyROL+TotalQtyCTN+TotalQtyPC) AS TotalQtyPack,    
 SUM([Free Qty]) As [Free Qty],SUM([Return Qty])As [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM([PrdWeight]) AS [PrdWeight],    
 SUM([Billed Qty]) AS [Billed Qty],SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) As PrdSchemeDisc,    
 SUM(TaxAmount) AS TaxAmount,SUM(NETAMOUNT) as NETAMOUNT,TotalBills,SUM([TotalDiscount]) AS [TotalDiscount],    
 SUM([OtherAmt]) AS [OtherAmt],SUM([AddReduce]) As [AddReduce],SUM([Damage])AS [Damage] INTO #Result    
 FROM #RptLoadSheetItemWiseParle GROUP BY PrdId,[Product Code],[Product Description],[MRP],TotalBills,[PrdCtgValMainId],[CmpPrdCtgId],    
 [BX],[PB],[JAR],[PKT],[GB],[CN],[TOR],[ROL],[TN],[CAR],[CTN],[PC]    
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
     select * from RptLoadSheetItemWiseParle_Excel  
 END     
END
GO
IF EXISTS (SELECT * FROM Sysobjects where name='Fn_ReturnBilledProductDt'  and Xtype in ('TF','F'))
DROP FUNCTION Fn_ReturnBilledProductDt
GO
CREATE FUNCTION Fn_ReturnBilledProductDt(@Pi_SchId INT,@Pi_SlabId INT,@Pi_SchType INT,@Pi_UserId INT,@Pi_TransId INT)  
RETURNS @BilledProduct TABLE  
 (  
  PrdDcode  nVarChar(100),  
  PrdBatCode  nVarChar(100),  
  SchemeOnQty Numeric(38,0),  
  SchemeOnAmount Numeric(38,2),  
  SchemeOnKg Numeric(38,2),  
  SchemeOnLitre Numeric(38,2),  
  PrdId  Int,  
  PrdBatId Int  
 )  
AS  
BEGIN  
/*********************************  
* FUNCTION: Fn_ReturnBilledProduct  
* PURPOSE: Returns the Billed Product Details for the Selected Scheme  
* NOTES:  
* CREATED: Thrinath Kola 24-04-2007  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/  
IF @Pi_SchType=0 OR @Pi_SchType=5  
BEGIN  
 INSERT INTO @BilledProduct (PrdDcode,PrdBatCode,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,PrdId,PrdBatId)  
 SELECT c.PrdDcode,E.PrdBatCode,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,  
  ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000  
  WHEN 3 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnKg,  
  ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000  
  WHEN 5 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnLitre,  
  C.PrdId,A.PrdBatId  
  FROM BilledPrdHdForScheme A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON  
  A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End  
  INNER JOIN Product C ON A.PrdId = C.PrdId  
  INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId  
  INNER JOIN ProductBatch E ON E.PrdId = C.PrdId AND E.PrdBatId = A.PrdBatId  
  WHERE A.Usrid = @Pi_UserId AND A.TransId = @Pi_TransId  
  GROUP BY C.PrdDcode,E.PrdBatCode,D.PrdUnitId,C.PrdId,A.PrdBatId  
END  
ELSE IF @Pi_SchType=1   
BEGIN  
 INSERT INTO @BilledProduct (PrdDcode,PrdBatCode,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,PrdId,PrdBatId)  
 SELECT c.PrdDcode,E.PrdBatCode,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,  
  ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000  
  WHEN 3 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnKg,  
  ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000  
  WHEN 5 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnLitre,  
  C.PrdId,A.PrdBatId  
  FROM BilledPrdHdForScheme A (NOLOCK) INNER JOIN Fn_ReturnSchemeAnotherProduct(@Pi_SchId,@Pi_SlabId) B ON  
  A.PrdId = B.PrdId --AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End  
  INNER JOIN Product C ON A.PrdId = C.PrdId  
  INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId  
  INNER JOIN ProductBatch E ON E.PrdId = C.PrdId AND E.PrdBatId = A.PrdBatId  
  WHERE A.Usrid = @Pi_UserId AND A.TransId = @Pi_TransId  
  GROUP BY C.PrdDcode,E.PrdBatCode,D.PrdUnitId,C.PrdId,A.PrdBatId  
END  
RETURN  
END
GO
IF EXISTS(SELECT * FROM Sysobjects where name='Proc_Cn2Cs_PurchaseReceipt' and Xtype='P')
DROP PROCEDURE Proc_Cn2Cs_PurchaseReceipt
GO
/*  
BEGIN TRANSACTION  
EXEC Proc_Cn2Cs_PurchaseReceipt 0  
ROLLBACK TRANSACTION  
*/
CREATE PROCEDURE Proc_Cn2Cs_PurchaseReceipt  
(  
 @Po_ErrNo INT OUTPUT  
)  
AS  
/***********************************************************  
* PROCEDURE : Proc_Cn2Cs_PurchaseReceipt  
* PURPOSE : To Insert the records FROM Console into Temp Tables  
* SCREEN : Console Integration-PurchaseReceipt  
* CREATED BY: Nandakumar R.G On 03-05-2010  
* MODIFIED :  
* DATE      AUTHOR     DESCRIPTION  
14/08/2013 Murugan.R Logistic Material Management  
* {date} {developer}  {brief modIFication description}  
*************************************************************/  
SET NOCOUNT ON  
BEGIN  
 -- For Clearing the Prking/Temp Table -----   
 DELETE FROM ETLTempPurchaseReceiptOtherCharges WHERE CmpInvNo in  
 (SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)  
 DELETE FROM ETLTempPurchaseReceiptClaimScheme WHERE CmpInvNo in  
 (SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)   
 DELETE FROM ETLTempPurchaseReceiptPrdLineDt WHERE CmpInvNo in  
 (SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)  
 DELETE FROM ETLTempPurchaseReceiptProduct WHERE CmpInvNo in  
 (SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)  
    DELETE FROM ETLTempPurchaseReceiptOtherCharges WHERE CmpInvNo in  
 (SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)   
 DELETE FROM Etl_LogisticMaterialStock WHERE InvoiceNumber IN   
 (SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)  
 DELETE FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1  
 DELETE FROM ETLTempPurchaseReceiptCrDbAdjustments WHERE CmpInvNo   
 IN (SELECT CmpInvNo FROM PurchaseReceipt WHERE Status = 1) AND DownloadStatus = 1  
 TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt  
 TRUNCATE TABLE ETL_Prk_PurchaseReceiptClaim  
 TRUNCATE TABLE ETL_Prk_PurchaseReceipt  
    TRUNCATE TABLE ETLTempPurchaseReceiptPrdLineDt  
    TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt  
    TRUNCATE TABLE ETL_Prk_PurchaseReceiptOtherCharges  
    TRUNCATE TABLE ETL_Prk_PurchaseReceiptCrDbAdjustments  
 --------------------------------------  
 DECLARE @ErrStatus   INT  
 DECLARE @BatchNo   NVARCHAR(200)  
 DECLARE @ProductCode  NVARCHAR(100)  
 DECLARE @ListPrice   NUMERIC(38,6)  
 DECLARE @FreeSchemeFlag  NVARCHAR(5)  
 DECLARE @CompInvNo   NVARCHAR(25)  
 DECLARE @UOMCode   NVARCHAR(25)  
 DECLARE @Qty    INT  
 DECLARE @PurchaseDiscount NUMERIC(38,6)  
 DECLARE @VATTaxValue  NUMERIC(38,6)  
 DECLARE @SchemeRefrNo  NVARCHAR(25)  
 DECLARE @SupplierCode  NVARCHAR(30)  
 DECLARE @TransporterCode NVARCHAR(30)  
 DECLARE @POUOM    INT  
 DECLARE @RowId    INT  
 DECLARE @LineLvlAmt   NUMERIC(38,6)  
 DECLARE @QtyInKg   NUMERIC(38,6)  
 DECLARE @ExistCompInvNo  NVARCHAR(25)  
 DECLARE @FreightCharges  NUMERIC(38,6)  
 SET @RowId=1  
   
 --->Added By Nanda on 17/09/2009  
 IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'InvToAvoid')  
 AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)  
 BEGIN  
  DROP TABLE InvToAvoid   
 END  
 CREATE TABLE InvToAvoid  
 (  
  CmpInvNo NVARCHAR(50)  
 )  
 IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
 WHERE CompInvNo IN (SELECT CmpInvNo FROM PurchaseReceipt))  
 BEGIN  
  INSERT INTO InvToAvoid(CmpInvNo)  
  SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE CompInvNo IN (SELECT CmpInvNo FROM PurchaseReceipt)  
  INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
  SELECT DISTINCT 1,'Purchase Receipt','CmpInvNo','Company Invoice No:'+CompInvNo+' already Available' FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE CompInvNo IN (SELECT CmpInvNo FROM PurchaseReceipt)  
 END  
 IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
 WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt))  
 BEGIN  
  INSERT INTO InvToAvoid(CmpInvNo)  
  SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt)  
  INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
  SELECT DISTINCT 1,'Purchase Receipt','CmpInvNo','Company Invoice No:'+CompInvNo+' already downloaded and ready for invoicing' FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt)  
 END  
 IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
 WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product))  
 BEGIN  
  INSERT INTO InvToAvoid(CmpInvNo)  
  SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product)  
  INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
  SELECT DISTINCT 1,'Purchase Receipt','Product','Product:'+ProductCode+' Not Available for Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product)  
  --->Added By Nanda on 05/05/2010  
  INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)  
  SELECT DISTINCT DistCode,'Purchase',CompInvNo,'Product',ProductCode,'','N' FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE ProductCode NOT IN (SELECT PrdCCode FROM Product)  
  --->Till Here      
 END  
 IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
 WHERE ProductCode+'~'+BatchNo  
 NOT IN  
 (SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId))  
 BEGIN  
  INSERT INTO InvToAvoid(CmpInvNo)  
  SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE ProductCode+'~'+BatchNo  
  NOT IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)  
    
  INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
  SELECT DISTINCT 1,'Purchase Receipt','Product Batch','Product Batch:'+BatchNo+'Not Available for Product:'+ProductCode+' in Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE ProductCode+'~'+BatchNo  
  NOT IN  
  (SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)  
  --->Added By Nanda on 05/05/2010  
  INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)  
  SELECT DISTINCT DistCode,'Purchase',CompInvNo,'Product Batch',ProductCode,BatchNo,'N' FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE ProductCode+'~'+BatchNo  
  NOT IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)  
  --->Till Here  
 END  
 --Supplier Credit Note Validations   
 IF EXISTS(SELECT DISTINCT [CompInvNo] FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN  
 (SELECT DISTINCT PostedRefNo FROM CreditNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Credit')  
 BEGIN  
  INSERT INTO InvToAvoid(CmpInvNo)  
        SELECT DISTINCT [CompInvNo] FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN  
    (SELECT DISTINCT PostedRefNo FROM CreditNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Credit'  
  INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
  SELECT DISTINCT 1,'CreditNoteSupplier','PostedRefNo','Supplier Credit Note Not Available'+[CompInvNo]  
  FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN   
  (SELECT DISTINCT PostedRefNo FROM CreditNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Credit'    
 END  
 --Supplier Debit Note Validations   
 IF EXISTS(SELECT DISTINCT [CompInvNo] FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN  
 (SELECT DISTINCT PostedRefNo FROM DebitNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Debit')  
 BEGIN  
  INSERT INTO InvToAvoid(CmpInvNo)  
        SELECT DISTINCT [CompInvNo] FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN  
    (SELECT DISTINCT PostedRefNo FROM DebitNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Debit'  
  INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
  SELECT DISTINCT 1,'DebitNoteSupplier','PostedRefNo','Supplier Debit Note Not Available'+[CompInvNo]  
  FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN   
  (SELECT DISTINCT PostedRefNo FROM DebitNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Debit'    
 END  
 IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
 WHERE CompInvDate>GETDATE())   
 BEGIN  
  INSERT INTO InvToAvoid(CmpInvNo)  
  SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE CompInvDate>GETDATE()  
    
  INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
  SELECT DISTINCT 1,'Purchase Receipt','Invoice Date','Invoice Date:'+CAST(CompInvDate AS NVARCHAR(10))+' is greater than current date in Invoice:'+CompInvNo   
  FROM Cn2Cs_Prk_BLPurchaseReceipt WITH (NOLOCK) WHERE CompInvDate>GETDATE()  
 END  
 --Commented and Added By Mohana.S PMS NO: DCRSTKAL0012  
 --IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
 --WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK)))   
 --BEGIN  
 -- INSERT INTO InvToAvoid(CmpInvNo)  
 -- SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
 -- WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))  
    
 -- INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
 -- SELECT DISTINCT 1,'Purchase Receipt','Invoice UOM','UOM:'+UOMCode+' is not available for Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
 -- WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))  
 --END  
 IF EXISTS (SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE PRODUCTCODE+'~'+UomCode NOT IN (SELECT PrdCCode+'~'+UomCode    
 FROM UomGroup UG INNER JOIN UomMaster UM ON UG.UomId =UM.UomId INNER JOIN Product P ON P.UomGroupId = UG.UomGroupId))  
 BEGIN  
   INSERT INTO InvToAvoid(CmpInvNo)  
   SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE PRODUCTCODE+'~'+UomCode NOT IN (SELECT PrdCCode+'~'+UomCode    
   FROM UomGroup UG INNER JOIN UomMaster UM ON UG.UomId =UM.UomId INNER JOIN Product P ON P.UomGroupId = UG.UomGroupId)  
     
   INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
   SELECT DISTINCT 1,'Purchase Receipt',PRODUCTCODE+'Product UOM','UOMCode:'+UOMCode+' is not available for Invoice:'+CompInvNo   
   FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE PRODUCTCODE+'~'+UomCode  NOT IN (SELECT PrdCCode+'~'+UomCode    
   FROM UomGroup UG INNER JOIN UomMaster UM ON UG.UomId =UM.UomId INNER JOIN Product P ON P.UomGroupId = UG.UomGroupId)  
 END   
 IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
 WHERE SupplierCode NOT IN (SELECT SpmCode FROM Supplier WITH (NOLOCK)))   
 BEGIN  
  INSERT INTO InvToAvoid(CmpInvNo)  
  SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE SupplierCode NOT IN (SELECT SpmCode FROM Supplier WITH (NOLOCK))  
    
  INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)  
  SELECT DISTINCT 1,'Purchase Receipt','Invoice Supplier','Supplier:'+SupplierCode+' is not available for Invoice:'+CompInvNo  
  FROM Cn2Cs_Prk_BLPurchaseReceipt WITH (NOLOCK) WHERE SupplierCode NOT IN (SELECT SpmCode FROM Supplier WITH (NOLOCK))  
 END   
 --->Till Here  
 -- Eliminated Duplicate records insertion on 02/03/2015
 SET @ExistCompInvNo=0  
 DECLARE Cur_Purchase CURSOR  
 FOR  
 SELECT DISTINCT ProductCode,BatchNo,ListPriceNSP,  
 FreeSchemeFlag,CompInvNo,UOMCode,PurQty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,CashDiscRs,0 AS BundleDeal,  
 ISNULL(FreightCharges,0) AS FreightCharges  
 FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE [DownLoadFlag]='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)  
 ORDER BY CompInvNo,ProductCode,BatchNo,ListPriceNSP,  
 FreeSchemeFlag,UOMCode,PurQty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,CashDiscRs,FreightCharges  
 OPEN Cur_Purchase  
 FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,  
 @FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,  
 @PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@QtyInKg,@RowId,@FreightCharges   
 WHILE @@FETCH_STATUS = 0  
 BEGIN  
--  IF @ExistCompInvNo<>@CompInvNo  
--  BEGIN  
--   SET @ExistCompInvNo=@CompInvNo  
--   SET @RowId=2  
--  END  
  --To insert into ETL_Prk_PurchaseReceiptPrdDt  
  IF(@FreeSchemeFlag='0')  
  BEGIN  
   INSERT INTO  ETL_Prk_PurchaseReceiptPrdDt([Company Invoice No],[RowId],[Product Code],[Batch Code],  
   [PO UOM],[PO Qty],[UOM],[Invoice Qty],[Purchase Rate],[Gross],[Discount In Amount],[Tax In Amount],[Net Amount],FreightCharges)  
   VALUES(@CompInvNo,@RowId,@ProductCode,@BatchNo,'',0,@UOMCode,@Qty,@ListPrice,@LineLvlAmt,  
   @PurchaseDiscount,@VATTaxValue,(@ListPrice-@PurchaseDiscount+@VATTaxValue)* @Qty,@FreightCharges)  
   INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])  
   VALUES(@CompInvNo,@RowId,'C',@PurchaseDiscount)  
   INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])  
   VALUES(@CompInvNo,@RowId,'D',@VATTaxValue)  
--   INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])  
--   VALUES(@CompInvNo,@RowId,'E',@QtyInKg)  
  END  
  --To insert into ETL_Prk_PurchaseReceiptClaim  
  IF(@FreeSchemeFlag='1')  
  BEGIN  
   INSERT INTO ETL_Prk_PurchaseReceiptClaim([Company Invoice No],[Type],[Ref No],[Product Code],  
   [Batch Code],[Qty],[Stock Type],[Amount],FreightAmt)  
   VALUES(@CompInvNo,'Offer',@SchemeRefrNo,@ProductCode,@BatchNo,@Qty,'Offer',0,@FreightCharges)  
  END  
--  SET @RowId=@RowId+1  
  FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,  
  @FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,  
  @PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@QtyInKg,@RowId,@FreightCharges  
 END  
 CLOSE Cur_Purchase  
 DEALLOCATE Cur_Purchase  
 --To insert into ETL_Prk_PurchaseReceipt  
 SELECT @TransporterCode=TransporterCode FROM Transporter  
 WHERE TransporterId IN(SELECT MIN(TransporterId) FROM Transporter WITH(NOLOCK))  
   
 IF @TransporterCode=''  
 BEGIN  
  INSERT INTO Errorlog VALUES (1,'Purchase Download','Transporter','Transporter not available')  
 END  
   
 INSERT INTO ETL_Prk_PurchaseReceipt([Company Code],[Supplier Code],[Company Invoice No],[PO Number],  
 [Invoice Date],[Transporter Code],[NetPayable Amount])  
 SELECT DISTINCT C.CmpCode,SupplierCode,P.CompInvNo,'',P.CompInvDate,@TransporterCode,P.NetValue  
 FROM Company C,Cn2Cs_Prk_BLPurchaseReceipt P  
 WHERE  C.DefaultCompany=1 AND DownLoadFlag='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)  
   
 --Added By Sathishkumar Veeramani 2013/08/13  
 --INSERT INTO ETL_Prk_PurchaseReceiptOtherCharges ([Company Invoice No],[OC Description],Amount)  
 --SELECT DISTINCT CompInvNo,'Cash Discounts' AS [OC Description],CashDiscRs FROM Cn2Cs_Prk_BLPurchaseReceipt WITH (NOLOCK)  
 --WHERE CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid) AND DownLoadFlag='D'  
   
 --Added by Sathishkumar Veeramani 2013/11/22  
 INSERT INTO ETL_Prk_PurchaseReceiptCrDbAdjustments([Company Invoice No],[Adjustment Type],[Ref No],[Amount])  
 SELECT DISTINCT CompInvNo,AdjType,RefNo,Amount FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WITH (NOLOCK)  
 WHERE CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid) AND DownLoadFlag='D'  
 EXEC Proc_Validate_PurchaseReceipt @Po_ErrNo= @ErrStatus OUTPUT  
 IF @ErrStatus =0  
 BEGIN  
  EXEC Proc_Validate_PurchaseReceiptProduct @Po_ErrNo= @ErrStatus OUTPUT  
  IF @ErrStatus =0  
  BEGIN  
   EXEC Proc_Validate_PurchaseReceiptLineDt @Po_ErrNo= @ErrStatus OUTPUT  
   IF @ErrStatus =0  
   BEGIN  
    EXEC Proc_Validate_PurchaseReceiptClaimScheme @Po_ErrNo= @ErrStatus OUTPUT  
    IF @ErrStatus =0  
    BEGIN  
       EXEC Proc_Validate_PurchaseReceiptOtherCharges @Po_ErrNo= @ErrStatus OUTPUT  
       IF @ErrStatus =0  
       BEGIN  
           EXEC Proc_Validate_PurchaseReceiptCrDbAdjustments @Po_ErrNo= @ErrStatus OUTPUT  
           IF @ErrStatus =0  
           BEGIN  
            SET @ErrStatus=@ErrStatus  
        END      
       END      
    END  
   END  
  END  
 END  
 --Proc_Validate_PurchaseReceiptCrDbAdjustments  
 --->Added By Nanda on 17/09/2009  
 DELETE FROM ETLTempPurchaseReceipt WHERE CmpInvNo NOT IN  
 (SELECT DISTINCT CmpInvNo FROM ETLTempPurchaseReceiptProduct)  
 UPDATE Cn2Cs_Prk_BLPurchaseReceipt SET DownLoadFlag='Y'  
 WHERE CompInvNo IN (SELECT DISTINCT CmpInvNo FROM EtlTempPurchaseReceipt)  
 --->Till Here  
 SET @Po_ErrNo= @ErrStatus  
 RETURN  
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_AutoBatchTransfer_Parle' AND XTYPE='P')
DROP PROCEDURE Proc_AutoBatchTransfer_Parle
GO
CREATE PROCEDURE Proc_AutoBatchTransfer_Parle
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_AutoBatchTransfer
* PURPOSE		: To do Batch Transfer automatically while downloading New Batch for Existing Product
* CREATED		: Nandakumar R.G
* CREATED DATE	: 06/02/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist 				AS 	INT
	DECLARE @Trans				AS 	INT
	DECLARE @Tabname 			AS  NVARCHAR(100)
	DECLARE @DestTabname 		AS 	NVARCHAR(100)
	DECLARE @Fldname 			AS  NVARCHAR(100)
	
	DECLARE @PrdDCode 	        AS 	NVARCHAR(100)
	DECLARE @BatchCode			AS 	NVARCHAR(100)
	DECLARE @CmpBatchCode		AS 	NVARCHAR(100)	
	DECLARE @PriceCode			AS 	NVARCHAR(4000)		
	DECLARE @MnfDate			AS 	NVARCHAR(100)
	DECLARE @ExpDate			AS 	NVARCHAR(100)
	DECLARE @TaxGroupCode		AS 	NVARCHAR(100)
	DECLARE @Status				AS 	NVARCHAR(100)
	DECLARE	@BatchSeqCode 		AS 	NVARCHAR(100)
	DECLARE @RefCode           	AS 	NVARCHAR(100)
	DECLARE @PriceValue         AS 	NVARCHAR(100)	
	DECLARE @DefaultPrice       AS 	NVARCHAR(100)	  	
	DECLARE @ExistPrdDCode		AS 	NVARCHAR(100)  	
	DECLARE @ExistBatchCode		AS 	NVARCHAR(100)
	DECLARE @ExistPriceCode		AS 	NVARCHAR(100)  	
	
	DECLARE @PrdId 				AS 	INT
	DECLARE @PrdBatId 			AS 	INT
	DECLARE @PriceId 			AS 	INT
	DECLARE @TaxGroupId 		AS 	INT
	DECLARE @BatchSeqId 		AS 	INT
	DECLARE @BatchStatus		AS 	INT
	DECLARE @SlNo	 			AS 	INT
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
	DECLARE @ContPriceCode		AS NVARCHAR(100)
	DECLARE @ContPrdBatId1		AS INT
	DECLARE @ContPriceId1		AS INT
	DECLARE @BatchTransfer		AS INT
	DECLARE @SalStock			AS INT
	DECLARE @UnSalStock			AS INT
	DECLARE @OfferStock			AS INT
	DECLARE @FromPrdBatId		AS INT
	DECLARE @FromPrdBatCode		AS NVARCHAR(200)
	DECLARE @ToPrdBatId			AS INT
	DECLARE @LcnId				AS INT
	DECLARE @Po_StkPosting		AS INT
	DECLARE @TransDate			AS DATETIME
	SET @BatchTransfer=0
	SELECT @TransDate=CONVERT(NVARCHAR(10),GETDATE(),121)
	---->Needs to be changed
	SELECT @BatchTransfer=Status FROM Configuration WHERE ModuleId='GENConfig000001'
	SET @Po_ErrNo=0
	SET @Exist=0
	SET @ExistPrdDCode=''	
	SET @ExistBatchCode=''
	SET @ExistPriceCode=''
	
	SET @Exist=0
	
	DECLARE Cur_ProductBatch CURSOR
	FOR 
	SELECT PrdId,MAX(PrdBatId) PrdBatId FROM ProductBatch GROUP BY PrdId
	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId
	WHILE @@FETCH_STATUS=0
	BEGIN
		--SELECT @PrdId,@PrdBatId,@BatchCode
		DECLARE Cur_BatchTransfer CURSOR
		FOR SELECT PBL.LcnId,PBL.PrdBatId,(PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) AS SalStock,(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih) AS UnSalStock,
		(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre) AS OfferStock
		FROM ProductBatchLocation PBL WHERE PBL.PrdId=@PrdId AND PBL.PrdBatId<>@PrdBatId
		AND ((PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih)+(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih)+(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre))>0
		OPEN Cur_BatchTransfer
		FETCH NEXT FROM Cur_BatchTransfer INTO @LcnId,@FromPrdBatId,@SalStock,@UnSalStock,@Offerstock
		WHILE @@FETCH_STATUS=0
		BEGIN
			--SELECT @PrdId,@PrdBatId,@LcnId,@FromPrdBatId,@SalStock,@UnSalStock,@Offerstock
			
			SET @Po_ErrNo=0
			
			IF @SalStock>0
			BEGIN
				Exec Proc_UpdateProductBatchLocation 1,2,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				IF @Po_StkPosting=0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 1,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					IF @Po_StkPosting=0
					BEGIN	
						Exec Proc_UpdateStockLedger 30,1,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
						IF @Po_StkPosting=0
						BEGIN
							Exec Proc_UpdateStockLedger 27,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@SalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
							IF @Po_StkPosting<>0
							BEGIN
								SET @Po_ErrNo=1
							END													
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					SET @Po_ErrNo=1
				END
			END
			
			IF @UnSalStock>0
			BEGIN
				Exec Proc_UpdateProductBatchLocation 2,2,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				IF @Po_StkPosting=0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 2,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					IF @Po_StkPosting=0
					BEGIN	
						Exec Proc_UpdateStockLedger 31,1,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
						IF @Po_StkPosting=0
						BEGIN
							Exec Proc_UpdateStockLedger 28,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@UnSalStock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
							IF @Po_StkPosting<>0
							BEGIN
								SET @Po_ErrNo=1
							END						
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					SET @Po_ErrNo=1
				END
			END
				
			IF @Offerstock>0
			BEGIN
				Exec Proc_UpdateProductBatchLocation 3,2,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
				IF @Po_StkPosting=0
				BEGIN
					Exec Proc_UpdateProductBatchLocation 3,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
					IF @Po_StkPosting=0
					BEGIN	
						Exec Proc_UpdateStockLedger 32,1,@PrdId,@FromPrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
						IF @Po_StkPosting=0
						BEGIN
							Exec Proc_UpdateStockLedger 29,1,@PrdId,@PrdBatId,@LcnId,@TransDate,@Offerstock,1,@Pi_ErrNo = @Po_StkPosting OUTPUT
							IF @Po_StkPosting<>0
							BEGIN
								SET @Po_ErrNo=1
							END						
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
					END
				END
				ELSE
				BEGIN
					SET @Po_ErrNo=1
				END
			END
			IF @Po_ErrNo>0
			BEGIN
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				VALUES(@FromPrdBatId,'','Error','Error')
			END
			FETCH NEXT FROM Cur_BatchTransfer INTO @LcnId,@FromPrdBatId,@SalStock,@UnSalStock,@Offerstock
		END
		CLOSE Cur_BatchTransfer
		DEALLOCATE Cur_BatchTransfer
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch
	RETURN	
END
GO
IF NOT EXISTS (SELECT A.Name FROM Syscolumns A (NOLOCK) INNER JOIN Sysobjects B (NOLOCK) ON A.Id = b.Id AND B.xtype = 'U'
AND B.name = 'Etl_Prk_SchemeHD_Slabs_Rules' AND A.name = 'SchApplyOn')
BEGIN
   ALTER TABLE Etl_Prk_SchemeHD_Slabs_Rules ADD SchApplyOn VARCHAR(100) DEFAULT '' WITH VALUES
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLSchemeMaster' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeMaster
GO
/*
BEGIN TRANSACTION
update schememaster set schstatus = 0 where cmpschcode = 'SCH00007'
EXEC Proc_Cn2Cs_BLSchemeMaster 0
select *from schememaster where cmpschcode = 'SCH00007'
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_BLSchemeMaster
(
	@Po_ErrNo INT OUTPUT
)
AS
/**************************************************************************************************
* PROCEDURE	: Proc_Cn2Cs_BLSchemeMaster
* PURPOSE	: To Insert and Update records Of Scheme Master
* CREATED	: Boopathy.P on 31/12/2008
* DATE         AUTHOR       DESCRIPTION
****************************************************************************************************
* 25.08.2009   Panneer		Added BudgetAllocationNo in SchemeMaster Table
* 20.10.2009   Thiru		Added SchBasedOn in SchemeMaster Table		
* 22/04/2010   Nanda 		Added FBM
* 28/12/2010   Nanda 		Added Settlement Type
**************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode 		AS NVARCHAR(100)
	DECLARE @SchDesc 		AS NVARCHAR(200)
	DECLARE @CmpCode 		AS NVARCHAR(50)
	DECLARE @ClmAble 		AS NVARCHAR(50)
	DECLARE @ClmAmtOn 		AS NVARCHAR(50)
	DECLARE @ClmGrpCode		AS NVARCHAR(50)
	DECLARE @SelnOn			AS NVARCHAR(50)
	DECLARE @SelLvl			AS NVARCHAR(50)
	DECLARE @SchType		AS NVARCHAR(50)
	DECLARE @BatLvl			AS NVARCHAR(50)
	DECLARE @FlxSch			AS NVARCHAR(50)
	DECLARE @FlxCond		AS NVARCHAR(50)
	DECLARE @CombiSch		AS NVARCHAR(50)
	DECLARE @Range			AS NVARCHAR(50)
	DECLARE @ProRata		AS NVARCHAR(50)
	DECLARE @Qps			AS NVARCHAR(50)
	DECLARE @QpsReset		AS NVARCHAR(50)
	DECLARE @ApyQpsOn		AS NVARCHAR(50)
	DECLARE @ForEvery		AS NVARCHAR(50)
	DECLARE @SchStartDate	AS NVARCHAR(50)
	DECLARE @SchEndDate		AS NVARCHAR(50)
	DECLARE @SchBudget		AS NVARCHAR(50)
	DECLARE @EditSch		AS NVARCHAR(50)
	DECLARE @AdjDisSch		AS NVARCHAR(50)
	DECLARE @SetDisMode		AS NVARCHAR(50)
	DECLARE @SchStatus		AS NVARCHAR(50)
	DECLARE @SchBasedOn		AS NVARCHAR(50)
	DECLARE @StatusId		AS INT
	DECLARE @CmpId			AS INT
	DECLARE @ClmGrpId		AS INT
	DECLARE @CmpPrdCtgId	AS INT
	DECLARE @ClmableId		AS INT
	DECLARE @ClmAmtOnId		AS INT
	DECLARE @SelMode		AS INT
	DECLARE @SchTypeId		AS INT
	DECLARE @BatId			AS INT
	DECLARE @FlexiId		AS INT
	DECLARE @FlexiConId		AS INT
	DECLARE @CombiId		AS INT
	DECLARE @RangeId		AS INT
	DECLARE @ProRateId		AS INT
	DECLARE @QPSId			AS INT
	DECLARE @QPSResetId		AS INT
	DECLARE @AdjustSchId	AS INT
	DECLARE @ApplySchId		AS INT
	DECLARE @ForEveryId		AS INT
	DECLARE @SettleSchId	AS INT
	DECLARE @EditSchId		AS INT
	DECLARE @ChkCount		AS INT		
	DECLARE @ConFig			AS INT
	DECLARE @CmpCnt			AS INT
	DECLARE @EtlCnt			AS INT
	DECLARE @SLevel			AS INT
	DECLARE @SchBasedOnId	AS INT
	DECLARE @ErrDesc		AS NVARCHAR(1000)
	DECLARE @TabName		AS NVARCHAR(50)
	DECLARE @GetKey			AS INT
	DECLARE @GetKeyStr		AS NVARCHAR(200)
	DECLARE @Taction		AS INT
	DECLARE @sSQL			AS VARCHAR(4000)
	DECLARE @iCnt			AS INT
	DECLARE @BudgetAllocationNo	AS NVARCHAR(100)
	DECLARE @FBM				AS NVARCHAR(10)
	DECLARE @FBMId				AS INT
	DECLARE @SettlementType		AS NVARCHAR(10)
	DECLARE @SettlementTypeId	AS INT
	DECLARE @FBMDate			AS DATETIME
	DECLARE @AllowUnCheck		AS NVARCHAR(10)
	DECLARE @AllowUnCheckId		AS INT
	DECLARE @CombiType			AS NVARCHAR(50)
	DECLARE @CombiTypeId		AS INT
	DECLARE @SchApplyOn			AS VARCHAR(100)
	DECLARE @SchApplyOnId		AS INT
	SET @TabName = 'Etl_Prk_SchemeHD_Slabs_Rules'
	SET @Po_ErrNo =0
	SET @AdjustSchId=0
	SET @iCnt=0
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	DECLARE @DistCode AS  NVARCHAR(50)
	SELECT @DistCode=ISNULL(DistributorCode,'') FROM Distributor
	--->Added By Nanda on 17/09/2009
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SchToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE SchToAvoid	
	END
	CREATE TABLE SchToAvoid
	(
		CmpSchCode NVARCHAR(50)
	)
	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi
	WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product'))
	BEGIN
		INSERT INTO SchToAvoid(CmpSchCode)
		SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi
		WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product')
		AND PrdCode<>'ALL'
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','CmpSchCode','Product :'+PrdCode+' not Available for Scheme:'+CmpSchCode FROM Etl_Prk_SchemeProducts_Combi
		WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product')
		AND PrdCode<>'ALL'
		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)		
		SELECT @DistCode,'Scheme',CmpSchCode,'Product',PrdCode,'','N'
		FROM Etl_Prk_SchemeProducts_Combi
		WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND 
		CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product')
		AND PrdCode<>'ALL'
	END
	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes))
	BEGIN
		INSERT INTO SchToAvoid(CmpSchCode)
		SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','Attributes','Attributes not Available for Scheme:'+CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes)
	END
	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi))
	BEGIN
		INSERT INTO SchToAvoid(CmpSchCode)
		SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','Products','Scheme Products not Available for Scheme:'+CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi)
	END
	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules))
	BEGIN
		INSERT INTO SchToAvoid(CmpSchCode)
		SELECT CmpSchCode FROM Etl_Prk_Scheme_OnAttributes
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','Header','Header not Available for Scheme:'+CmpSchCode FROM Etl_Prk_Scheme_OnAttributes
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules)
	END
	--->Till Here
	DECLARE Cur_SchMaster CURSOR
	FOR SELECT DISTINCT
	ISNULL([CmpSchCode],'') AS [Company Scheme Code],
	ISNULL([SchDsc],'') AS [Scheme Description],
	ISNULL([CmpCode],'') AS [Company Code],
	ISNULL([Claimable],'') AS [Claimable],
	ISNULL([ClmAmton],'') AS [Claim Amount On],
	ISNULL([ClmGroupCode],'') AS [Claim Group Code],
	ISNULL([SchemeLevelMode],'') AS [Selection On],
	ISNULL([SchLevel],'') AS [Selection Level Value],
	ISNULL([SchType],'') AS [Scheme Type],
	ISNULL([BatchLevel],'') AS [Batch Level],
	ISNULL([FlexiSch],'') AS [Flexi Scheme],
	ISNULL([FlexiSchType],'') AS [Flexi Conditional],
	ISNULL([CombiSch],'') AS [Combi Scheme],
	ISNULL([Range],'') AS [Range],
	ISNULL([ProRata],'') AS [Pro - Rata],
	ISNULL([Qps],'NO') AS [Qps],
	ISNULL([QPSReset],'') AS [Qps Reset],
	ISNULL([ApyQPSSch],'') AS [Qps Based On],
	ISNULL([PurofEvery],'') AS [Allow For Every],
	ISNULL([SchValidFrom],'') AS [Scheme Start Date],
	ISNULL([SchValidTill],'') AS [Scheme End Date],
	ISNULL([Budget],'') AS [Scheme Budget],
	ISNULL([EditScheme],'') AS [Allow Editing Scheme],
	ISNULL([AdjWinDispOnlyOnce],'0') AS [Adjust Display Once],
	ISNULL([SetWindowDisp],'') AS [Settle Display Through],
	ISNULL(SchStatus,'') AS SchStatus,
	ISNULL(BudgetAllocationNo,'') AS BudgetAllocationNo,
	ISNULL(SchBasedOn,'') AS SchemeBasedOn,
	ISNULL(FBM,'No') AS FBM,
	ISNULL(SettlementType,'ALL') AS SettlementType,
	ISNULL([AllowUncheck],'NO') AS AllowUncheck,
	ISNULL([CombiType],'NORMAL') AS [CombiType],
	ISNULL(SchApplyOn,'SELLINGRATE') AS SchApplyOn
	FROM Etl_Prk_SchemeHD_Slabs_Rules (NOLOCK)
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'			 
	ORDER BY [Company Scheme Code]
	OPEN Cur_SchMaster
	FETCH NEXT FROM Cur_SchMaster INTO @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
	, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
	, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch,
	@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM,@SettlementType,@AllowUnCheck,@CombiType,@SchApplyOn	
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @CombiTypeId=0	
		SET @SchBasedOn='RETAILER'
		SET @Po_ErrNo =0		
		SET @Taction = 2
		SET @iCnt=@iCnt+1
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchDesc))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Description should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (2,@TabName,'Scheme Description',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@CmpCode))= ''
		BEGIN
			SET @ErrDesc = 'Company should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (3,@TabName,'Company',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ClmAble))= ''
		BEGIN
			SET @ErrDesc = 'Claimable should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (4,@TabName,'Claimable',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ClmAmtOn))= ''
		BEGIN
			SET @ErrDesc = 'Claim Amount On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (5,@TabName,'Claim Amount On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SelnOn))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level Type should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (6,@TabName,'Scheme Level Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SelLvl))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (7,@TabName,'Scheme Level',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchType))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Type should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (8,@TabName,'Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@BatLvl))= ''
		BEGIN
			SET @ErrDesc = 'Batch Level should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (9,@TabName,'Batch Level',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@FlxSch))= ''
		BEGIN
			SET @ErrDesc = 'Flexi Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (10,@TabName,'Flexi Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@FlxCond))= ''
		BEGIN
			SET @ErrDesc = 'Flexi Scheme Type should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (11,@TabName,'Flexi Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@CombiSch))= ''
		BEGIN
			SET @ErrDesc = 'Combi Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (12,@TabName,'Combi Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@Range))= ''
		BEGIN
			SET @ErrDesc = 'Range should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (13,@TabName,'Range Based Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ProRata))= ''
		BEGIN
			SET @ErrDesc = 'Pro-Rata should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (14,@TabName,'Pro-Rata',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@Qps))= ''
		BEGIN
			SET @ErrDesc = 'QPS Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (15,@TabName,'QPS Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@QpsReset))= ''
		BEGIN
			SET @ErrDesc = 'QPS Reset should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (16,@TabName,'QPS Reset',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ApyQpsOn))= ''
		BEGIN
			SET @ErrDesc = 'Apply QPS Scheme Based On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (17,@TabName,'Apply QPS Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchStartDate))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Start Date should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (19,@TabName,'Start Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LEN(LTRIM(RTRIM(@SchStartDate)))<10
		BEGIN
			SET @ErrDesc = 'Scheme Start Date is not Date Format for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (20,@TabName,'Scheme Start Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF ISDATE(LTRIM(RTRIM(@SchStartDate))) = 0
		BEGIN
			SET @ErrDesc = 'Invalid Scheme Start Date for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (21,@TabName,'Scheme Start Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchEndDate))= ''
		BEGIN
			SET @ErrDesc = 'Scheme End Date should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (23,@TabName,'End Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LEN(LTRIM(RTRIM(@SchEndDate)))<10
		BEGIN
			SET @ErrDesc = 'Scheme End Date is not in Date Format for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (24,@TabName,'Scheme End Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF ISDATE(LTRIM(RTRIM(@SchEndDate))) = 0
		BEGIN
			SET @ErrDesc = 'Invalid Scheme End Date for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (25,@TabName,'Scheme End Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@EditSch))= ''
		BEGIN
			SET @ErrDesc = 'Allow Editing Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (28,@TabName,'Editing Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SetDisMode))= ''
		BEGIN
			SET @ErrDesc = 'Settle Window Display Scheme should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (30,@TabName,'Settle Window Display Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SelnOn))= ''
		BEGIN
			SET @ErrDesc = 'Selection On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (31,@TabName,'Selction On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchStatus))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Status should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (32,@TabName,'Scheme Status',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchBasedOn))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Based On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (70,@TabName,'SchemeBasedOn',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@CombiType))= ''
		BEGIN
			SET @ErrDesc = 'CombiType should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (70,@TabName,'CombiType',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchApplyOn))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Apply On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (72,@TabName,'CombiType',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END 
		IF ((UPPER(LTRIM(RTRIM(@CombiType)))<> 'NORMAL') AND (UPPER(LTRIM(RTRIM(@CombiType)))<> 'FLUCTUATING'))
		BEGIN
			SET @ErrDesc = 'CombiType should be (NORMAL OR FLUCTUATING) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (71,@TabName,'CombiType',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@SchApplyOn)))<> 'SELLINGRATE') AND (UPPER(LTRIM(RTRIM(@SchApplyOn)))<> 'MRP') 
		AND (UPPER(LTRIM(RTRIM(@SchApplyOn)))<> 'PURCHASERATE'))
		BEGIN
			SET @ErrDesc = 'Scheme Apply On should be (SELLINGRATE OR MRP OR PURCHASERATE) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (72,@TabName,'CombiType',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@SchBasedOn)))<> 'RETAILER') AND (UPPER(LTRIM(RTRIM(@SchBasedOn)))<> 'KEY GROUP'))
		BEGIN
			SET @ErrDesc = 'Scheme Based On should be (RETAILER OR KEY GROUP) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (71,@TabName,'SchemeBasedOn',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@SelnOn)))<> 'UDC') AND (UPPER(LTRIM(RTRIM(@SelnOn)))<> 'PRODUCT'))
		BEGIN
			SET @ErrDesc = 'Selection On should be (UDC OR PRODUCT) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (33,@TabName,'Selction On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@ClmAble)))<> 'YES') AND (UPPER(LTRIM(RTRIM(@ClmAble)))<> 'NO'))
		BEGIN
			SET @ErrDesc = 'Claimable should be (YES OR NO) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (34,@TabName,'Claimable',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@SchStatus)))<> 'ACTIVE') AND (UPPER(LTRIM(RTRIM(@SchStatus)))<> 'INACTIVE'))
		BEGIN
			SET @ErrDesc = 'Scheme Stauts should be (ACTIVE OR INACTIVE) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (35,@TabName,'Scheme Stauts',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF (UPPER(LTRIM(RTRIM(@ClmAble)))= 'YES')
		BEGIN
			IF LTRIM(RTRIM(@ClmGrpCode))= ''
			BEGIN
				SET @ErrDesc = 'Claim Group Code should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (36,@TabName,'Claim Group Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF (UPPER(LTRIM(RTRIM(@ClmAmtOn)))<> 'PURCHASE RATE' AND UPPER(LTRIM(RTRIM(@ClmAmtOn)))<> 'SELLING RATE')
		BEGIN
			SET @ErrDesc = 'Claimable Amount should be (PURCHASE RATE OR SELLING RATE) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (37,@TabName,'Claimable Amount',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF (UPPER(LTRIM(RTRIM(@SchType)))<>'WINDOW DISPLAY' AND UPPER(LTRIM(RTRIM(@SchType)))<>'AMOUNT'
		   AND UPPER(LTRIM(RTRIM(@SchType)))<>'WEIGHT' AND UPPER(LTRIM(RTRIM(@SchType)))<>'QUANTITY')
		BEGIN
			SET @ErrDesc = 'Scheme Type should be (WINDOW DISPLAY OR AMOUNT OR WEIGHT OR QUANTITY) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (38,@TabName,'Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF (UPPER(LTRIM(RTRIM(@SchType)))='WINDOW DISPLAY')
		BEGIN
			IF (UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' AND UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO' AND UPPER(LTRIM(RTRIM(@BatLvl)))<> 'ALL')
			BEGIN
				SET @ErrDesc = 'Batch Level should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (39,@TabName,'Batch Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme should be (NO) for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (40,@TabName,'Flexi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxCond)))<> 'UNCONDITIONAL')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme Type should be (UNCONDITIONAL) for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (41,@TabName,'Flexi Scheme Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@CombiSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Combi Scheme should be (NO) for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (42,@TabName,'Combi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Range)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Range should be (NO) for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (43,@TabName,'Range',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@ProRata)))<> 'YES' AND UPPER(LTRIM(RTRIM(@ProRata)))<> 'NO'
			   AND UPPER(LTRIM(RTRIM(@ProRata)))<> 'ACTUAL')
			BEGIN
				SET @ErrDesc = 'Pro-Rata should be (YES OR NO OR ACTUAL) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (44,@TabName,'Pro-Rata',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Qps)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS should be (NO) for WINDOW DISPLAY SCHEME for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (45,@TabName,'QPS Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@QpsReset)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS Reset should be (NO)for WINDOW DISPLAY SCHEME in Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (46,@TabName,'QPS Reset',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LTRIM(RTRIM(@AdjDisSch))= ''
			BEGIN
				SET @ErrDesc = 'Adjust Window Display Scheme Only Once should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (47,@TabName,'Adjust Window Display Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@SetDisMode)))<> 'CASH' AND UPPER(LTRIM(RTRIM(@SetDisMode)))<> 'CHEQUE')
			BEGIN
				SET @ErrDesc = 'Settle Window Display Should be (CASH OR CHEQUE) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (48,@TabName,'SETTLE WINDOW DISPLAY',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'DATE')
			BEGIN
				SET @ErrDesc = 'Apply QPS Scheme Should be (DATE) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (50,@TabName,'Apply QPS Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		ELSE IF (UPPER(LTRIM(RTRIM(@SchType)))='AMOUNT' AND UPPER(LTRIM(RTRIM(@SchType)))='WEIGHT'
			AND UPPER(LTRIM(RTRIM(@SchType)))='QUANTITY')
		BEGIN
			IF UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' OR UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO' OR UPPER(LTRIM(RTRIM(@BatLvl)))<> 'ALL'
			BEGIN
				SET @ErrDesc = 'Batch Level should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (51,@TabName,'Batch Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxSch)))<> 'YES' AND UPPER(LTRIM(RTRIM(@FlxSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (52,@TabName,'Flexi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxCond)))<> 'UNCONDITIONAL' AND UPPER(LTRIM(RTRIM(@FlxCond)))<> 'CONDITIONAL')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme Type should be (UNCONDITIONAL OR CONDITIONAL) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (53,@TabName,'Flexi Scheme Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxSch)))= 'NO')
			BEGIN
				IF (UPPER(LTRIM(RTRIM(@FlxCond)))= 'CONDITIONAL')
				BEGIN
					SET @ErrDesc = 'Flexi Scheme Type should be UNCONDITIONAL When Flexi Scheme is YES for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (54,@TabName,'Flexi Scheme Type',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@CombiSch)))<> 'YES' AND UPPER(LTRIM(RTRIM(@CombiSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Combi Scheme should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (55,@TabName,'Combi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Range)))<> 'YES' AND UPPER(LTRIM(RTRIM(@Range)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Range should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (56,@TabName,'Range',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@ProRata)))<> 'YES' AND UPPER(LTRIM(RTRIM(@ProRata)))<> 'NO'
			   OR UPPER(LTRIM(RTRIM(@ProRata)))<> 'ACTUAL')
			BEGIN
				SET @ErrDesc = 'Pro-Rata should be (YES OR NO OR ACTUAL) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (57,@TabName,'Pro-Rata',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@CombiSch)))<> 'YES')
			BEGIN
				IF (UPPER(LTRIM(RTRIM(@Range)))<> 'NO')
				BEGIN
					SET @ErrDesc = 'IF COMBI SCHEME is YES, Then RANGE should be (NO) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (58,@TabName,'Range',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF (UPPER(LTRIM(RTRIM(@ProRata)))<> 'NO')
				BEGIN
					SET @ErrDesc = 'IF COMBI SCHEME is YES, Then PRO-RATA should be (NO) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (59,@TabName,'Pro-Rata',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Qps)))<> 'YES' AND UPPER(LTRIM(RTRIM(@Qps)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (60,@TabName,'QPS Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@QpsReset)))<> 'YES' AND UPPER(LTRIM(RTRIM(@QpsReset)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS Reset should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (61,@TabName,'QPS Reset',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF UPPER(LTRIM(RTRIM(@Qps)))= 'NO'
			BEGIN
				IF UPPER(LTRIM(RTRIM(@QpsReset)))= 'YES'
				BEGIN
					SET @ErrDesc = 'IF QPS SCHEME is NO, Then QPS Reset should be (NO) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (62,@TabName,'QPS Reset',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'DATE'
				BEGIN
					SET @ErrDesc = 'IF QPS SCHEME is NO,Apply QPS Scheme Should be (DATE) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (63,@TabName,'Apply QPS Scheme',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@Qps)))= 'YES'
			BEGIN
				IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'DATE' AND UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'QUANTITY'
				BEGIN
					SET @ErrDesc = 'Apply QPS Scheme Should be (DATE OR QUANTITY) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (64,@TabName,'Apply QPS Scheme',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@SetDisMode)))<> 'CASH'
			BEGIN
				SET @ErrDesc = 'Settle Window Display Should be (CASH) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (65,@TabName,'SETTLE WINDOW DISPLAY',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@AllowUnCheck)))<> 'YES' AND UPPER(LTRIM(RTRIM(@AllowUnCheck)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Allow uncheck claimable should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (52,@TabName,'Allow Uncheck',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF NOT EXISTS(SELECT CmpId FROM Company WHERE CmpCode=LTRIM(RTRIM(@CmpCode)))
			BEGIN
				SET @ErrDesc = 'Company Not Found for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (66,@TabName,'Company',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE
			BEGIN
				SELECT @CmpId=CmpId FROM Company WHERE CmpCode=LTRIM(RTRIM(@CmpCode))
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			SET @GetKey=0
			SET @GetKeyStr=''
			IF NOT EXISTS(SELECT SchId FROM SchemeMaster SM WHERE CMPID=@CmpId AND SM.CmpSchCode=LTRIM(RTRIM(@SchCode)))
			BEGIN
				SELECT @GetKey= dbo.Fn_GetPrimaryKeyInteger('SchemeMaster','SchId',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
				SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('SchemeMaster','SchCode',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))				
				SET @Taction = 2
			END
			ELSE
			BEGIN
				SELECT @GetKey=SchId,@GetKeyStr=SchCode FROM SchemeMaster WHERE CMPID=@CmpId AND CmpSchCode=LTRIM(RTRIM(@SchCode))
				SET @Taction = 1
			END
		END
		IF @GetKey=0	
		BEGIN
			SET @ErrDesc = 'Scheme Id should be greater than zero Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (67,@TabName,'Scheme Id',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF LEN(LTRIM(RTRIM(@GetKeyStr )))=''
		BEGIN
			SET @ErrDesc = 'Scheme Code should be greater than zero Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (67,@TabName,'Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF @Taction = 2
		BEGIN 
			IF @GetKey<=(SELECT ISNULL(MAX(SchId),0) AS SchId FROM SchemeMaster)
			BEGIN
				SET @ErrDesc = 'Reset the counters/Check the system date'
				INSERT INTO Errorlog VALUES (67,@TabName,'SchId',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@SchBasedOn)))= 'RETAILER'
				SET @SchBasedOnId=1
			ELSE IF UPPER(LTRIM(RTRIM(@SchBasedOn)))= 'KEY GROUP'
				SET @SchBasedOnId=2
		END 
		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@ClmAble)))='YES'
			BEGIN
				IF NOT EXISTS(SELECT ClmGrpId FROM ClaimGroupMaster WHERE ClmGrpCode=LTRIM(RTRIM(@ClmGrpCode)))
				BEGIN
					SET @ErrDesc = 'Claim Group Not Found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (67,@TabName,'Claim Group',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @ClmGrpId=ClmGrpId FROM ClaimGroupMaster WHERE ClmGrpCode=LTRIM(RTRIM(@ClmGrpCode))
				END
			END
			ELSE
			BEGIN
				SET @ClmGrpId=0
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@SelnOn)))='PRODUCT' OR UPPER(LTRIM(RTRIM(@SelnOn)))='SKU' OR UPPER(LTRIM(RTRIM(@SelnOn)))='MATERIAL'
			BEGIN
				IF NOT EXISTS(SELECT CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
					AND CmpPrdCtgName=UPPER(LTRIM(RTRIM(@SelLvl))) AND LevelName <> 'Level1')
				BEGIN
					SET @ErrDesc = 'Product Category Level Not Found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (68,@TabName,'Product Category',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
					AND CmpPrdCtgName=LTRIM(RTRIM(@SelLvl)) AND LevelName <> 'Level1'
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@SelnOn)))='UDC'
			BEGIN
				IF NOT EXISTS(SELECT DISTINCT A.UdcMasterId FROM UdcMaster A
					INNER JOIN UdcHD B ON A.MasterId=B.MasterId WHERE B.MasterId=1 AND A.COLUMNNAME=LTRIM(RTRIM(@SelLvl)))
				BEGIN
					SET @ErrDesc = 'Product Category Level Not Found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (69,@TabName,'Product Category',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @CmpPrdCtgId=A.UdcMasterId FROM UdcMaster A INNER JOIN UdcHD B ON
					A.MasterId=B.MasterId WHERE B.MasterId=1 AND A.COLUMNNAME=LTRIM(RTRIM(@SelLvl))
				END
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@SchStatus)))= 'ACTIVE'
				SET @StatusId=1
			ELSE IF UPPER(LTRIM(RTRIM(@SchStatus)))= 'INACTIVE'
				SET @StatusId=0
			IF UPPER(LTRIM(RTRIM(@ClmAble)))= 'YES'
				SET @ClmableId=1
			ELSE IF UPPER(LTRIM(RTRIM(@ClmAble)))= 'NO'
				SET @ClmableId=0
			
			IF UPPER(LTRIM(RTRIM(@ClmAmtOn)))= 'PURCHASE RATE'
				SET @ClmAmtOnId=1
			ELSE IF UPPER(LTRIM(RTRIM(@ClmAmtOn)))= 'SELLING RATE'
				SET @ClmAmtOnId=2
			
			IF UPPER(LTRIM(RTRIM(@SelnOn)))= 'UDC'
				SET @SelMode=1
			ELSE IF UPPER(LTRIM(RTRIM(@SelnOn)))= 'PRODUCT'
				SET @SelMode=0
			
			IF UPPER(LTRIM(RTRIM(@SchType)))='WINDOW DISPLAY'
				SET @SchTypeId=4
			ELSE IF UPPER(LTRIM(RTRIM(@SchType)))='AMOUNT'
				SET @SchTypeId=2
			ELSE IF UPPER(LTRIM(RTRIM(@SchType)))='WEIGHT'
				SET @SchTypeId=3
			ELSE IF UPPER(LTRIM(RTRIM(@SchType)))='QUANTITY'
				SET @SchTypeId=1
			
			IF UPPER(LTRIM(RTRIM(@BatLvl)))= 'YES'
				SET @BatId=1
			ELSE IF UPPER(LTRIM(RTRIM(@BatLvl)))= 'NO' OR UPPER(LTRIM(RTRIM(@BatLvl)))= 'ALL'
				SET @BatId=0
			
			
			IF UPPER(LTRIM(RTRIM(@FlxSch)))= 'YES'
				SET @FlexiId=1
			ELSE IF UPPER(LTRIM(RTRIM(@FlxSch)))= 'NO'
				SET @FlexiId=0
			
			IF UPPER(LTRIM(RTRIM(@FlxCond)))= 'UNCONDITIONAL'
				SET @FlexiConId=2
			ELSE IF UPPER(LTRIM(RTRIM(@FlxCond)))= 'CONDITIONAL'
				SET @FlexiConId=1
			ELSE
				SET @FlexiConId=2
			
			IF UPPER(LTRIM(RTRIM(@CombiSch)))= 'YES'				
				SET @CombiId=1
			ELSE IF UPPER(LTRIM(RTRIM(@CombiSch)))= 'NO'
				SET @CombiId=0
			IF UPPER(LTRIM(RTRIM(@CombiType)))= 'FLUCTUATING'
				SET @CombiTypeId=1
			ELSE IF UPPER(LTRIM(RTRIM(@Range)))= 'NORMAL'
				SET @CombiTypeId=0
			
			IF UPPER(LTRIM(RTRIM(@SchApplyOn)))= 'MRP'				
				SET @SchApplyOnId=1
			ELSE IF UPPER(LTRIM(RTRIM(@SchApplyOn)))= 'SELLINGRATE'
				SET @SchApplyOnId=2
			ELSE IF UPPER(LTRIM(RTRIM(@SchApplyOn)))= 'PURCHASERATE'
				SET @SchApplyOnId=3
				
			
			IF UPPER(LTRIM(RTRIM(@Range)))= 'YES'
				SET @RangeId=1
			ELSE IF UPPER(LTRIM(RTRIM(@Range)))= 'NO'
				SET @RangeId=0
			
			IF UPPER(LTRIM(RTRIM(@ProRata)))= 'YES'
				SET @ProRateId=1
			ELSE IF UPPER(LTRIM(RTRIM(@ProRata)))= 'NO'
				SET @ProRateId=0
			ELSE IF UPPER(LTRIM(RTRIM(@ProRata)))= 'ACTUAL'
				SET @ProRateId=2
			
			IF UPPER(LTRIM(RTRIM(@Qps)))= 'YES'
				SET @QPSId=1
			ELSE IF UPPER(LTRIM(RTRIM(@Qps)))= 'NO'
				SET @QPSId=0
			
			IF UPPER(LTRIM(RTRIM(@ForEvery)))= 'YES'
				SET @ForEveryId=1
			ELSE IF UPPER(LTRIM(RTRIM(@ForEvery)))= 'NO'
				SET @ForEveryId=0
			IF UPPER(LTRIM(RTRIM(@EditSch)))= 'YES'
				SET @EditSchId=0
			ELSE IF UPPER(LTRIM(RTRIM(@EditSch)))= 'NO'
				SET @EditSchId=0
			IF UPPER(LTRIM(RTRIM(@QpsReset)))= 'YES'
				SET @QPSResetId=1
			ELSE IF UPPER(LTRIM(RTRIM(@QpsReset)))= 'NO'
				SET @QPSResetId=0
			IF LTRIM(RTRIM(@SchBudget))= ''
			BEGIN
				SET @SchBudget=0
			END
			IF @SchTypeId=4
			BEGIN
				IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))= 'DATE'
					SET @ApplySchId=1
				IF UPPER(LTRIM(RTRIM(@SetDisMode)))= 'CASH'
					SET @SettleSchId=1
				ELSE IF UPPER(LTRIM(RTRIM(@SetDisMode)))= 'CHEQUE'
					SET @SettleSchId=2
				IF LTRIM(RTRIM(@AdjDisSch))= 'NO'
					SET @AdjustSchId=0
				ELSE IF LTRIM(RTRIM(@AdjDisSch))= 'YES'
					SET @AdjustSchId=1
			END
			ELSE
			BEGIN
				IF @QPSId=1
				BEGIN
					IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))= 'DATE'
						SET @ApplySchId=1
					ELSE IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))='QUANTITY'
						SET @ApplySchId=2
					SET @SettleSchId=1
				END
				ELSE
				BEGIN
					SET @SettleSchId=1
					SET @ApplySchId=1
				END
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF @FBM='Yes'
			BEGIN
				SET @FBMId=1
				SET @SchBudget=0
			END
			ELSE
			BEGIN
				SET @FBMId=0
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF @SettlementType='Value'
			BEGIN
				SET @SettlementTypeId=1				
			END
			ELSE IF @SettlementType='Product'
			BEGIN
				SET @SettlementTypeId=2
			END
			ELSE 
			BEGIN
				SET @SettlementTypeId=0
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@AllowUnCheck)))= 'YES'
			BEGIN
				SET @AllowUnCheckId=1
			END
			ELSE
			BEGIN
				SET @AllowUnCheckId=0
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF @Taction=1
			BEGIN
				EXEC Proc_DependencyCheck 'SchemeMaster',@GetKey
				SELECT @ChkCount=COUNT(*) FROM TempDepCheck
				IF @ChkCount > 0
				BEGIN
					UPDATE SCHEMEMASTER SET SchValidTill=LTRIM(RTRIM(@SchEndDate)),
					--Budget=@SchBudget,SchStatus=@StatusId WHERE SchId=@GetKey
					Budget=@SchBudget/*,SchStatus=@StatusId*/ WHERE SchId=@GetKey --Modified by Muthuvel for DCONSPAR0470
				END
				ELSE
				BEGIN
					DELETE FROM SchemeProducts WHERE SchId=@GetKey
					DELETE FROM SchemeRetAttr WHERE SchId=@GetKey
					DELETE FROM SchemeSlabCombiPrds WHERE SchId=@GetKey
					DELETE FROM SchemeSlabFrePrds WHERE SchId=@GetKey
					DELETE FROM SchemeSlabMultiFrePrds WHERE SchId=@GetKey
					DELETE FROM dbo.SchemeRtrLevelValidation WHERE SchId=@GetKey
					DELETE FROM dbo.SchemeRuleSettings WHERE SchId=@GetKey
					DELETE FROM dbo.SchemeAnotherPrdDt WHERE SchId=@GetKey
					DELETE FROM dbo.SchemeAnotherPrdHd WHERE SchId=@GetKey
					DELETE FROM SchemeSlabs WHERE SchId=@GetKey
					
					UPDATE SCHEMEMASTER SET SchDsc=LTRIM(RTRIM(@SchDesc)),CmpId=@CmpId,
					Claimable=@ClmableId,ClmAmton=@ClmAmtOnId,ClmRefId=@ClmGrpId,
					SchLevelId=@CmpPrdCtgId,SchType=@SchTypeId,BatchLevel=@BatId,
					FlexiSch=@FlexiId,FlexiSchType=@FlexiConId,CombiSch=@CombiId,
					Range=@RangeId,ProRata=@ProRateId,QPS=@QPSId,QPSReset=@QPSResetId,
					SchValidFrom=LTRIM(RTRIM(@SchStartDate)),SchValidTill=LTRIM(RTRIM(@SchEndDate)),
					Budget=@SchBudget,ApyQPSSch=@ApplySchId,SetWindowDisp=@SettleSchId,
					--SchemeLvlMode=@SelMode,SchStatus=@StatusId WHERE SchId=@GetKey
					SchemeLvlMode=@SelMode/*,SchStatus=@StatusId*/ WHERE SchId=@GetKey --Modified by Muthuvel for DCONSPAR0470
					INSERT INTO SchemeRuleSettings(SchId,SchConfig,SchRules,NoofBills,FromDate,ToDate,MarketVisit,ApplySchBasedOn,
					EnableRtrLvl,AllowSaving,AllowSelection,Availability,LastModBy,LastModDate,AuthId,AuthDate,CalScheme,NoOfRtr,RtrCount)
					Select SchId,0,-1,-1,NULL,NULL,-1,-1,0,0,0,1,1,LastModDate,1,LastModDate,1,0,0 from schememaster (NOLOCK) where Claimable=1
					and SchId Not In(Select SchId from SchemeRuleSettings (NOLOCK))
				END
			END
			ELSE IF @Taction=2
			BEGIN
				IF @ConFig=1
				BEGIN
					SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
					IF @CmpPrdCtgId<@SLevel
					BEGIN
						SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
						WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='NO'
						AND A.SlabId=0 AND A.SlabValue=0
	
						SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
						WHERE A.[PrdCode] IN (SELECT b.PrdCtgValCode FROM ProductCategoryValue B) AND
						A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='NO'
						AND A.SlabId=0 AND A.SlabValue=0
					END
					ELSE
					BEGIN
						SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
						WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='YES'
						AND A.SlabId=0 AND A.SlabValue=0
						SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
						WHERE A.[PrdCode] IN (SELECT PrdCCode FROM Product)
						AND  A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) --AND UPPER(A.[SchLevel])='YES'
						AND A.SlabId=0 AND A.SlabValue=0
					END
						IF @EtlCnt=@CmpCnt
						BEGIN
							SELECT @EtlCnt=COUNT([PrdCode]) FROM Etl_Prk_Scheme_Free_Multi_Products A (NOLOCK)
							WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode))
	
							SELECT @CmpCnt=COUNT([PrdCode]) FROM Etl_Prk_Scheme_Free_Multi_Products A (NOLOCK)
							INNER JOIN Product B ON A.[PrdCode]=b.PrdCCode
							WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode))
							IF @EtlCnt=@CmpCnt
							BEGIN	
								INSERT INTO SchemeMaster(SchId,SchCode,SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
								CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
								ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
								PurofEvery,ApyQPSSch,SetWindowDisp,Availability,LastModBy,LastModDate,AuthId,
								AuthDate,EditScheme,SchemeLvlMode,MasterType,ApplyOnMRPSelRte,ApplyOnTax,
								BudgetAllocationNo,AllowPrdSelc,ExcludeDM,SchBasedOn,Download,FBM,SettlementType,ApplyClaim,CombiType)
								VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
								LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
								@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
								@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
								@ApplySchId,@SettleSchId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,
								CONVERT(VARCHAR(10),GETDATE(),121),@EditSchId,@SelMode,1,@SchApplyOnId,0,
								@BudgetAllocationNo,0,0,@SchBasedOnId,1,@FBMId,@SettlementTypeId,@AllowUnCheckId,@CombiTypeId)
				
								UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchId'
								UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchCode'
								IF @FBMId=1
								BEGIN
									SET @GetKeyStr=LTRIM(RTRIM(@GetKeyStr))
									SELECT @FBMDate=CONVERT(VARCHAR(10),GETDATE(),121)
									EXEC Proc_FBMTrack 45,@GetKeyStr,@GetKey,@FBMDate,1,0
								END
							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeRuleSettings_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM Etl_Prk_SchemeRtrLevelValidation_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM Etl_Prk_SchemeAnotherPrdHd_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM Etl_Prk_SchemeAnotherPrdDt_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeAttribute_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeProduct_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeSlabCombiPrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeSlabFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeSlabMultiFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeSlabs_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								DELETE FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
								
								INSERT INTO ETL_Prk_SchemeMaster_Temp(SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
								CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
								ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
								PurofEvery,ApyQPSSch,SetWindowDisp,EditScheme,SchemeLvlMode,UpLoadFlag,BudgetAllocationNo,SchBasedOn,Download) VALUES
								(LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
								@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
								@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
								@ApplySchId,@SettleSchId,@EditSchId,@SelMode,'N',@BudgetAllocationNo,@SchBasedOnId,1)
							END
						END
						ELSE
						BEGIN
							DELETE FROM Etl_Prk_SchemeRuleSettings_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM Etl_Prk_SchemeRtrLevelValidation_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM Etl_Prk_SchemeAnotherPrdHd_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM Etl_Prk_SchemeAnotherPrdDt_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeAttribute_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeProduct_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeSlabCombiPrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeSlabFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeSlabMultiFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeSlabs_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							DELETE FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
							
							INSERT INTO ETL_Prk_SchemeMaster_Temp(SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
							CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
							ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
							PurofEvery,ApyQPSSch,SetWindowDisp,EditScheme,SchemeLvlMode,UpLoadFlag,BudgetAllocationNo,SchBasedOn,Download) VALUES
							(LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
							@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
							@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
							@ApplySchId,@SettleSchId,@EditSchId,@SelMode,'N',@BudgetAllocationNo,@SchBasedOnId,1)
						END							
				END
				ELSE
				BEGIN
					INSERT INTO SchemeMaster(SchId,SchCode,SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
					CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
					ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
					PurofEvery,ApyQPSSch,SetWindowDisp,Availability,LastModBy,LastModDate,AuthId,
					AuthDate,EditScheme,SchemeLvlMode,MasterType,ApplyOnMRPSelRte,ApplyOnTax,BudgetAllocationNo,
					AllowPrdSelc,ExcludeDM,SchBasedOn,Download,FBM,SettlementType,ApplyClaim,CombiType)
					VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
					LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
					@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
					@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
					@ApplySchId,@SettleSchId,1,1,convert(varchar(10),getdate(),121),1,
					convert(varchar(10),getdate(),121),@EditSchId,@SelMode,1,@SchApplyOnId,0,@BudgetAllocationNo,0,0,
					@SchBasedOnId,1,@FBMId,@SettlementTypeId,@AllowUnCheckId,@CombiTypeId)
	
					UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchId'
					UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchCode'
					INSERT INTO SchemeRuleSettings(SchId,SchConfig,SchRules,NoofBills,FromDate,ToDate,MarketVisit,ApplySchBasedOn,
					EnableRtrLvl,AllowSaving,AllowSelection,Availability,LastModBy,LastModDate,AuthId,AuthDate,CalScheme,NoOfRtr,RtrCount)
					Select SchId,0,-1,-1,NULL,NULL,-1,-1,0,0,0,1,1,LastModDate,1,LastModDate,1,0,0 from schememaster (NOLOCK) where Claimable=1
					AND SchId Not In(Select SchId from SchemeRuleSettings (NOLOCK))
					IF @FBMId=1
					BEGIN
						SET @GetKeyStr=LTRIM(RTRIM(@GetKeyStr))
						SELECT @FBMDate=CONVERT(VARCHAR(10),GETDATE(),121)
						EXEC Proc_FBMTrack 45,@GetKeyStr,@GetKey,@FBMDate,1,0
					END
				END
			END
		END
		FETCH NEXT FROM Cur_SchMaster INTO  @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
		, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
		, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch,
		@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM,@SettlementType,@AllowUnCheck,@CombiType,@SchApplyOn
	END
	CLOSE Cur_SchMaster
	DEALLOCATE Cur_SchMaster
END
GO
DELETE FROM CustomUpdownload WHERE Updownload = 'Download' AND Module = 'Scheme Flag Change'
INSERT INTO CustomUpDownload(SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
SELECT 245,1,'Scheme Flag Change','Scheme Flag Change','Proc_CN2CS_BLSchemeFlagChange','','Etl_Prk_SchemeHD_Slabs_Rules',
'Proc_CN2CS_BLSchemeFlagChange','Master','Download',1
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_CN2CS_BLSchemeFlagChange' AND XTYPE='P')
DROP PROCEDURE Proc_CN2CS_BLSchemeFlagChange
GO
--EXEC Proc_CN2CS_BLSchemeFlagChange 0
CREATE PROCEDURE [dbo].[Proc_CN2CS_BLSchemeFlagChange]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_CN2CS_BLSchemeFlagChange
* PURPOSE: To Update Scheme related parking tables
* CREATED: Boopathy.P on 12-07-2012
*********************************/
SET NOCOUNT ON
BEGIN
	SET @Po_ErrNo=0
	
	SELECT DISTINCT SM.CmpSchCode INTO #Temp FROM SchemeMaster SM(NOLOCK),SchemeRetAttr SA(NOLOCK),
	SchemeProducts SP(NOLOCK),Etl_Prk_SchemeHD_Slabs_Rules Prk (NOLOCK)
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId AND SM.CmpSchCode = Prk.CmpSchCode
	
	DELETE FROM #Temp WHERE CmpSchCode IN (SELECT CmpSchCode FROM SchToAvoid (NOLOCK))
	
	UPDATE Etl_Prk_SchemeHD_Slabs_Rules SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT CmpSchCode FROM #Temp)
	
	UPDATE Etl_Prk_Scheme_OnAttributes SET DownloadFlag='Y' WHERE CmpSchCode IN  (SELECT DISTINCT CmpSchCode FROM #Temp)
	
	UPDATE Etl_Prk_Scheme_Free_Multi_Products SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT CmpSchCode FROM #Temp)
	
	UPDATE Etl_Prk_Scheme_OnAnotherPrd SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT CmpSchCode FROM #Temp)
	
	UPDATE Etl_Prk_Scheme_RetailerLevelValid SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT CmpSchCode FROM #Temp)
	
	UPDATE Etl_Prk_SchemeProducts_Combi SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT CmpSchCode FROM #Temp)
	
	UPDATE Etl_Prk_Scheme_OnAnotherPrd SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT CmpSchCode FROM #Temp)
	
	UPDATE Etl_Prk_Scheme_CombiCriteria SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT CmpSchCode FROM #Temp)

END
GO
IF EXISTS(SELECT Name FROM SYSOBJECTS WHERE NAME='Proc_ApplyQPSSchemeInBill' AND XTYPE='P')
DROP PROCEDURE Proc_ApplyQPSSchemeInBill
GO
/*
	BEGIN TRANSACTION
	DELETE A FROM BilledPrdHdForQPSScheme A (NOLOCK)
	EXEC Proc_ApplyQPSSchemeInBill 18,1681,0,2,2
	SELECT * FROM BilledPrdHdForQPSScheme (NOLOCK)
	ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_ApplyQPSSchemeInBill]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT,
	@Pi_Mode		INT =0	
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
* {date}		{developer}		{brief modification description}
* 27-07-2011	Boopathy.P		Sales Return is not reduced for Data based QPS Scheme (Commented fetching data from table SalesInvoiceQPSCumulative)
* 02-08-2011    Boopathy.P		QPS DATE BASED ISSUE FROM J&J Site (Older schemes are getting apply)
* 08-08-2011    Boopathy.P      Bug Ref no : 23364
* 16-11-2011    Boopathy.P        Add table to track the invoice details for QPS Datebased Scheme
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
		MRP                 NUMERIC(18,6),
		SchemeOnQty 		NUMERIC(38,0),
		SchemeOnAmount		NUMERIC(38,6),
		SchemeOnKG		NUMERIC(38,6),
		SchemeOnLitre		NUMERIC(38,6),
		SchId 			INT
	)
	DECLARE @TempBilled1 TABLE
	(
		PrdId			    INT,
		PrdBatId		    INT,
		MRP                 NUMERIC(18,6),
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
	DECLARE @Config		AS	INT
	SET @Config=0
	
	SELECT @Config=Status FROM Configuration WHERE ModuleId='BILLQPS3'
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
		INSERT INTO @TempBilled1(PrdId,PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
		SELECT A.PrdId,A.PrdBatId,MRP,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,
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
			GROUP BY A.PrdId,A.PrdBatId,MRP,D.PrdUnitId
	END
	
	IF @QPS <> 0
	BEGIN
		--From all the Bills
		--To Add the Cumulative Qty
		IF @QPSBasedOn=2
		BEGIN
			IF @Pi_Mode=1
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,MRP,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,PrdUnitMRP AS MRP,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId,PrdUnitMRP
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,PrdUnitMRP AS MRP,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId,PrdUnitMRP
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,PrdUnitMRP AS MRP,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId,PrdUnitMRP
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId,MRP
			END
			ELSE IF @Pi_Mode=2
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,MRP,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,PrdUnitMRP AS MRP,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId,PrdUnitMRP
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,PrdUnitMRP AS MRP,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId,PrdUnitMRP
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,PrdUnitMRP AS MRP,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							AND  A.SalId <(CASE @Pi_SalId WHEN 0 THEN  A.SAlId ELSE @Pi_SalId END) 
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId,PrdUnitMRP
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId,MRP
			END
			ELSE
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,MRP,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,PrdUnitMRP AS MRP,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId,PrdUnitMRP
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,PrdUnitMRP AS MRP,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId,PrdUnitMRP
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,PrdUnitMRP AS MRP,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
							ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
							FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
							A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
							INNER JOIN Product C ON A.PrdId = C.PrdId
							INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
							INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
							INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
										(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
										AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
							,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
							E.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId,PrdUnitMRP
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId,MRP
			END
		END
		ELSE
		BEGIN
			-- Commented by Boopathy 27-07-2011 (Sales Return is not reduced for Data based QPS Scheme)
			INSERT INTO @TempBilled1(PrdId,PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
				SELECT PrdId,PrdBatId,MRP,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
				(	SELECT A.SalId,A.PrdId,A.PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(SELECT A.SalId,A.PrdId,A.PrdBatId,PrdUnitMRP AS MRP,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
						ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
						ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
						ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId AS SchId
						FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
						INNER JOIN Product C ON A.PrdId = C.PrdId
						INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
						INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
						,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
						E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill AND H.SchId=@Pi_SchId
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId,PrdUnitMRP
					) AS A 
					INNER JOIN 
					(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
						ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
					) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
				UNION
					SELECT A.SalId,A.PrdId,A.PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,PrdUnitMRP AS MRP,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
						ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
						ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
						ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
						FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
						INNER JOIN Product C ON A.PrdId = C.PrdId
						INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
						INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
						,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
						E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill   AND H.SchId=@Pi_SchId
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId,PrdUnitMRP
					) AS A 
					INNER JOIN 
					(
						SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
						WHERE A.SchId=@Pi_SchId
					) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
				UNION
					SELECT A.SalId,A.PrdId,A.PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,PrdUnitMRP AS MRP,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
						ISNULL(SUM((A.BaseQty-A.ReturnedQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
						ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnKg,
						ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0)/1000
						WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty-A.ReturnedQty)),0) END,0) AS SchemeOnLitre,@Pi_SchId As SchId
						FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
						INNER JOIN Product C ON A.PrdId = C.PrdId
						INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
						INNER JOIN SalesInvoice E ON A.SalId=E.SalId AND E.DlvSts<>3
						INNER JOIN (SELECT A.SalId FROM SalesInvoice A WHERE  NOT EXISTS 
									(SELECT SalId FROM SalesInvoiceSchemeDtBilled B WHERE A.SalId=B.SalId AND B.SchId=@Pi_SchId) 
									AND DlvSts<>3 AND RtrId=@Pi_RtrId)G ON A.SalId=G.SalId
						,SchemeMaster H WHERE E.RtrId=@Pi_RtrId AND 
						E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill  AND H.SchId=@Pi_SchId
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId,PrdUnitMRP
						
					) AS A 
				)AS A GROUP BY PrdId,PrdBatId,SchId,MRP
		END
	
		IF @Pi_Mode=0
		BEGIN
			--To Subtract Non Deliverbill
			INSERT INTO @TempBilled1(PrdId,PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				Select SIP.Prdid,SIP.Prdbatid,PrdUnitMRP AS MRP,
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
				INNER JOIN ProductUnit D (NOLOCK) ON C.PrdUnitId = D.PrdUnitId,SchemeMaster H
				WHERE Dlvsts in(1,2) and Rtrid=@Pi_RtrId and SI.Salid <>@Pi_SalId
				and SI.Salid Not in(Select Salid from SalesInvoiceSchemeQPSGiven (NOLOCK) where Salid<>@Pi_SalId and  schid=@Pi_SchId)
				AND SI.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
				Group by SIP.Prdid,SIP.Prdbatid,D.PrdUnitId,PrdUnitMRP
		END
		IF @Pi_Mode<>2
		BEGIN
			IF @Pi_SalId<>0
			BEGIN
				--To Subtract the Billed Qty in Edit Mode
				INSERT INTO @TempBilled1(PrdId,PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
				SELECT A.PrdId,A.PrdBatId,PrdUnitMRP AS MRP,-1 * ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,
					-1 * ISNULL(SUM(A.BaseQty * A.PrdUnitSelRate),0) AS SchemeOnAmount,
					-1 * ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnKg,
					-1 * ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnLitre,@Pi_SchId
					FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C ON A.PrdId = C.PrdId
					INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
					WHERE A.SalId = @Pi_SalId AND A.SalId NOT IN (SELECT SalId FROM SalesInvoice WHERE DlvSts>3)
					GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId,PrdUnitMRP
			
			END
			IF @QPSBasedOn=1 
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				SELECT A.PrdId,A.PrdBatId,ISNULL(PrdUnitMRP,0) AS MRP,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
					-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
					-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
					FROM SalesInvoiceQPSRedeemed A (NOLOCK) LEFT OUTER JOIN SalesInvoiceProduct B (NOLOCK)
					ON A.SalId = B.SalId AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
					WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId					
					AND A.SalId <> @Pi_SalId GROUP BY A.PrdId,A.PrdBatId,PrdUnitMRP
			END
		END
	END
	INSERT INTO @TempBilled(PrdId,PrdBatId,MRP,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,MRP,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
		ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
		GROUP BY PrdId,PrdBatId,SchId,MRP
		
	DELETE FROM @TempBilled WHERE (SchemeOnQty+SchemeOnAmount+SchemeOnKG+SchemeOnLitre)<=0		
	--->Added By Nanda on 26/11/2010
	IF @QPSBasedOn<>1 AND @FlexiSch=1
	BEGIN
		DELETE FROM @TempBilled WHERE SchemeOnQty+SchemeOnAmount+SchemeOnKG<=0	
	END
	ELSE
	BEGIN
		DELETE FROM @TempBilled WHERE SchemeOnQty+SchemeOnAmount+SchemeOnKG=0	
	END
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
	END
	SELECT @TotalValue = ISNULL(SUM(FrmSchAch),0) FROM @TempBilledAch WHERE SlabId =1
	
	--->Added By Boo and Nanda on 29/11/2010
	IF @SchType = 3 AND @QPSReset=1
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
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemes B WHERE A.SlabId=B.SlabId)
	END
	--->Till Here
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
				FlatAmt * @NoOfTimes
--				((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
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
	BEGIN
		SELECT DISTINCT * INTO #TempBillApplied FROM @BillAppliedSchemeHd
		DELETE FROM @BillAppliedSchemeHd
		INSERT INTO @BillAppliedSchemeHd
		SELECT * FROM #TempBillApplied
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemes B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		INNER JOIN SchemeSlabs C ON A.SchId=C.SchId AND C.SlabId=B.SlabId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
	END
	--->Till Here
	INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
		FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
		BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
	SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,SUM(SchemeDiscount) AS SchemeDiscount,
		SUM(Points) AS Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,(FreePrdId) as FreePrdId ,
		FreePrdBatId,SUM(FreeToBeGiven) As FreeToBeGiven,GiftPrdId,GiftPrdBatId,SUM(GiftToBeGiven) As GiftToBeGiven,SUM(NoOfTimes) AS NoOfTimes,
		IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,MAX(PrdBatId),0 FROM @BillAppliedSchemeHd
		GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,FlxDisc,FlxValueDisc,FlxFreePrd,
		FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,GiftPrdId,GiftPrdBatId,IsSelected,
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
	SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
	AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId
	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
	EXEC Proc_ApplyDiscountScheme @Pi_SchId,@Pi_UsrId,@Pi_TransId
	UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
	SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
	TransId = @Pi_TransId AND Usrid = @Pi_UsrId
	IF @FlexiSch=0
	BEGIN
		INSERT INTO @QPSGivenFlat
		SELECT SchId,SUM(FlatAmount)
		FROM
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount-ReturnFlatAmount,0) AS FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
		(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId ) A,
		SalesInvoice SI
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND FlexiSch=0 AND A.SchemeDiscount=0 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
		) A
		WHERE SchId=@Pi_SchId
		GROUP BY A.SchId	
		
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
	END
	DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
	INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
	SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat
	--->Added By Nanda on 21/02/2011
	UPDATE A SET SchemeAmount=B.SchemeAmount
	FROM BillAppliedSchemeHd A,
	(
		SELECT SchId,SlabId,MAX(SchemeAmount) AS SchemeAmount FROM BillAppliedSchemeHd
		WHERE TransID=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId
		GROUP BY SchId,SlabId 
	) B
	WHERE A.SchId=B.SchId AND A.SlabId=B.SlabId AND TransID=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SchId=@Pi_SchId
	--->Till Here
	UPDATE BillAppliedSchemeHd SET SchemeAmount= CAST(SchemeAmount-Amount AS NUMERIC(38,4))
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
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
	SELECT DISTINCT SchId,SlabId FROM BillAppliedSchemeHd 
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
			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-@AmtToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs
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
		FROM BilledPrdHdForScheme BP WHERE BP.TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND BP.RtrId=@Pi_RtrId --AND BP.SchId=@Pi_SchId
		INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
		SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
		FROM @TempBilled TB	
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
	-- Added By Boopathy.P on 08-08-2011 for Bug Ref no : 23364
	UPDATE B SET B.PrdBatId=A.PrdBatId FROM BillAppliedSchemeHd B INNER JOIN 
	(SELECT SchId,SlabId,PrdId,Max(PrdbatId) AS PrdBatId,TransId,UsrId FROM @BillAppliedSchemeHd WHERE 
	(FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd > 0) AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	AND SchId=@Pi_SchId GROUP BY SchId,SlabId,PrdId,TransId,UsrId) AS A ON A.SchId=B.SchId
	AND A.SlabId=B.SlabId AND A.PrdId=B.PrdId AND A.TransId=B.TransId AND A.UsrId=B.UsrId 
	WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_UsrId AND B.SchId=@Pi_SchId
	DELETE FROM BillAppliedSchemeHd WHERE SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd=0
	IF EXISTS (SELECT * FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId = @Pi_SchId)
	BEGIN
		IF @Config=1 AND @Pi_Mode=2
		BEGIN
				DELETE FROM SalesInvoiceQpsDatebasedTrack WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND SchId = @Pi_SchId AND RtrId=@Pi_RtrId AND Upload=0
				INSERT INTO SalesInvoiceQpsDatebasedTrack
				SELECT 1,A.SalId,A.SalInvNo,A.RtrId,A.RtrCode,A.RtrName,A.SchId,A.SchCode,A.SchDesc,
				A.PrdId,A.PrdCCode,A.PrdBatId,A.PrdBatCode,SchemeOnQty,
				SchemeOnAmount,SchemeOnKg,SchemeOnLitre,@Pi_UsrId,@Pi_TransId,0 FROM 
				(
					SELECT A.SalId,E.SalInvNo,@Pi_RtrId AS RtrId,F.RtrCode,F.RtrName,@Pi_SchId AS SchId,CmpSchCode AS SchCode,SchDsc AS SchDesc,
					A.PrdId,C.PrdCCode,A.PrdBatId,D1.PrdBatCode,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,
					ISNULL(SUM((A.BaseQty) * A.PrdUnitSelRate),0) AS SchemeOnAmount,
					ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty)),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty)),0) END,0) AS SchemeOnKg,
					ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty)),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty)),0) END,0) AS SchemeOnLitre
					FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C (NOLOCK)  ON A.PrdId = C.PrdId
					INNER JOIN ProductUnit D (NOLOCK)  ON C.PrdUnitId = D.PrdUnitId
					INNER JOIN ProductBatch D1 (NOLOCK) ON C.PrdId=D1.PrdId AND A.PrdBatId=D1.PrdBatId
					INNER JOIN SalesInvoice E (NOLOCK)  ON A.SalId=E.SalId AND E.DlvSts>3
					INNER JOIN Retailer F (NOLOCK)  ON F.RtrId=E.RtrId
					,SchemeMaster H (NOLOCK)  WHERE E.RtrId=@Pi_RtrId AND 
					E.SalInvDate BETWEEN H.SchValidFrom AND H.SchValidTill AND H.SchId=@Pi_SchId
					GROUP BY A.SalId,E.SalInvNo,F.RtrCode,F.RtrName,A.PrdId,A.PrdBatId,D.PrdUnitId,C.PrdCCode,CmpSchCode,SchDsc,D1.PrdBatCode
				) AS A 
				UNION 
				SELECT 2,A.ReturnId,A.ReturnCode,A.RtrId,A.RtrCode,A.RtrName,A.SchId,A.SchCode,A.SchDesc,
				A.PrdId,A.PrdCCode,A.PrdBatId,A.PrdBatCode,SchemeOnQty,
				SchemeOnAmount,SchemeOnKg,SchemeOnLitre,@Pi_UsrId,@Pi_TransId,0 FROM 
				(
					SELECT A.ReturnId,E.ReturnCode,@Pi_RtrId AS RtrId,F.RtrCode,F.RtrName,@Pi_SchId AS SchId,CmpSchCode AS SchCode,SchDsc AS SchDesc,
					A.PrdId,C.PrdCCode,A.PrdBatId,D1.PrdBatCode,ISNULL(SUM(A.BaseQty),0)*-1 AS SchemeOnQty,
					ISNULL(SUM((A.BaseQty) * A.PrdUnitSelRte),0)*-1 AS SchemeOnAmount,
					ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * (A.BaseQty)),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * (A.BaseQty)),0) END,0)*-1 AS SchemeOnKg,
					ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * (A.BaseQty)),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * (A.BaseQty)),0) END,0)*-1 AS SchemeOnLitre
					FROM ReturnProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C (NOLOCK)  ON A.PrdId = C.PrdId
					INNER JOIN ProductUnit D (NOLOCK)  ON C.PrdUnitId = D.PrdUnitId
					INNER JOIN ProductBatch D1 (NOLOCK) ON C.PrdId=D1.PrdId AND A.PrdBatId=D1.PrdBatId
					INNER JOIN ReturnHeader E (NOLOCK)  ON A.ReturnId=E.ReturnId AND E.Status=0
					INNER JOIN Retailer F (NOLOCK)  ON F.RtrId=E.RtrId
					,SchemeMaster H (NOLOCK)  WHERE E.RtrId=@Pi_RtrId AND E.SalId>0 AND 
					E.ReturnDate BETWEEN H.SchValidFrom AND H.SchValidTill AND H.SchId=@Pi_SchId
					GROUP BY A.ReturnId,E.ReturnCode,F.RtrCode,F.RtrName,A.PrdId,A.PrdBatId,D.PrdUnitId,C.PrdCCode,CmpSchCode,SchDsc,D1.PrdBatCode
				) AS A 	
		END
	END
	--->Till Here
END
GO
IF EXISTS(SELECT Name FROM SYSOBJECTS WHERE NAME='Proc_ApportionSchemeAmountInLine' AND XTYPE='P')
DROP PROCEDURE Proc_ApportionSchemeAmountInLine
GO
/*
BEGIN TRANSACTION
DELETE A FROM ApportionSchemeDetails A (NOLOCK)
EXEC Proc_ApportionSchemeAmountInLine 2,2
SELECT * FROM ApportionSchemeDetails (NOLOCK)
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_ApportionSchemeAmountInLine]
(
	@Pi_UsrId   INT,
	@Pi_TransId  INT,
	@Pi_Mode	INT =0
)
AS
/*********************************
* PROCEDURE		: Proc_ApportionSchemeAmountInLine
* PURPOSE		: To Apportion the Scheme amount line wise
* CREATED		: Thrinath
* CREATED DATE	: 25/04/2007
* NOTE			: General SP for Returning Scheme amount line wise
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}       {developer}        {brief modification description}
* 28/04/2009    Nandakumar R.G    Modified for Discount Calculation on MRP with Tax
* 10/04/2010    Nandakumar R.G    Modified for QPS Scheme
* 04-08-2011    Boopathy.P        Update the Discount percentage for Flexi Scheme 
* 05-08-2011    Boopathy.P		  Previous Adjusted Value will not reduce for Flexi QPS Based Scheme
* 09-08-2011    Boopathy.P		  Bug No:23402
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchId   INT
	DECLARE @SlabId  INT
	DECLARE @RefCode nVarChar(10)
	DECLARE @RtrId  INT
	DECLARE @PrdCnt  INT
	DECLARE @PrdBatCnt INT
	DECLARE @PrdId  INT
	DECLARE @MRP  INT
	DECLARE @WithTax INT
	DECLARE @BillSeqId  INT
	DECLARE @QPS  INT
	DECLARE @QPSDateQty  INT
	DECLARE @Combi  INT
	DECLARE @RtrQPSId  INT
	DECLARE @TempSchGross TABLE
	(
		SchId   INT,
		GrossAmount  NUMERIC(38,6),
		QPSGrossAmount  NUMERIC(38,6)
	)
	DECLARE @TempPrdGross TABLE
	(
		SchId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6),
		QPSGrossAmount  NUMERIC(38,6)
	)
	DECLARE @FreeQtyDt TABLE
	(
		FreePrdid  INT,
		FreePrdBatId  INT,
		FreeQty   INT,
		SchId INT
	)
	DECLARE @FreeQtyRow TABLE
	(
		RowId   INT,
		PrdId   INT,
		PrdBatId  INT
	)
	DECLARE @PDSchID TABLE
	(
		PrdId   INT,
		PrdBatId  INT,
		PDSchId   INT,
		PDSlabId  INT
	)
	DECLARE @SchFlatAmt TABLE
	(
		SchId  INT,
		SlabId  INT,
		FlatAmt  NUMERIC(18,6),
		DiscPer  NUMERIC(18,6),
		SchType  INT
	)
	DECLARE @MoreBatch TABLE
	(
		SchId  INT,
		SlabId  INT,
		PrdId  INT,
		PrdCnt  INT,
		PrdBatCnt INT,
		SchType  INT
	)
	DECLARE @QPSGivenDisc TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @QPSGivenFlat TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @RtrQPSIds TABLE
	(
		RtrId   INT,		
		SchId   INT
	)
	DECLARE @QPSNowAvailable TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)	
	
    -- Added by Boopathy for QPS Quantitiy based checking
	DELETE FROM BillQPSSchemeAdj WHERE CrNoteAmount<=0 
	UPDATE SalesInvoiceQPSSchemeAdj SET AdjAmount=0 WHERE CrNoteAmount=0 AND AdjAmount>=0 	
	DELETE FROM ApportionSchemeDetails WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	-- End here 
	SELECT @RtrQPSId=RtrId FROM BilledPrdHdForQPSScheme WHERE TransId= @Pi_TransId AND UsrId=@Pi_UsrId
	if exists (select * from dbo.sysobjects where id = object_id(N'TP') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TP
	if exists (select * from dbo.sysobjects where id = object_id(N'TG') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TG
	if exists (select * from dbo.sysobjects where id = object_id(N'TPQ') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TPQ
	if exists (select * from dbo.sysobjects where id = object_id(N'TGQ') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table TGQ
	if exists (select * from dbo.sysobjects where id = object_id(N'SchMaxSlab') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table SchMaxSlab
	SET @RtrId = (SELECT TOP 1 RtrId FROM BilledPrdHdForScheme WHERE TransID = @Pi_TransId
	AND UsrId = @Pi_Usrid)
	DECLARE  CurSchid CURSOR FOR
	SELECT DISTINCT Schid,SlabId FROM BillAppliedSchemeHd WHERE IsSelected = 1
	AND TransID = @Pi_TransId AND UsrId = @Pi_Usrid
	OPEN CurSchid
	FETCH NEXT FROM CurSchid INTO @SchId,@SlabId
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SELECT @QPS =QPS,@Combi=CombiSch,@QPSDateQty=ApyQPSSch	FROM SchemeMaster WHERE Schid=@SchId	
		SELECT @MRP=ApplyOnMRPSelRte,@WithTax=ApplyOnTax FROM SchemeMaster WHERE --MasterType=2 AND
		SchId=@SchId
		
		IF NOT EXISTS(SELECT * FROM @TempSchGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 
			BEGIN
				IF EXISTS(SELECT * FROM SchemeAnotherPrdDt WHERE SchId=@SchId AND SlabId=@SlabId)
				BEGIN
					INSERT INTO @TempSchGross (SchId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN SchemeAnotherPrdDt C ON A.PrdId=C.PrdId AND C.SchId=@SchId AND C.SlabId=@SlabId
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
				ELSE
				BEGIN 
					INSERT INTO @TempSchGross (SchId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId					
				END
			END
			IF  @QPS<>0 
			BEGIN
				INSERT INTO @TempSchGross (SchId,GrossAmount,QPSGrossAmount)
				SELECT @SchId,
				CASE @MRP
				WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
				WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
				WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
				as GrossAmount,0 FROM BilledPrdHdForQPSScheme A
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND QPSPrd=1
				AND A.SchId=@SchId
			END	
		END
		IF NOT EXISTS(SELECT * FROM @TempPrdGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 
			BEGIN			
				
				IF EXISTS(SELECT * FROM Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId))
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END 
				ELSE
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount,QPSGrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount,0 FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF @QPS<>0 
			BEGIN
				IF @Combi=1 
				BEGIN
					INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
					TransId,Usrid,PrdId,PrdBatId,SchType)
					SELECT DISTINCT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
					TransId,Usrid,PrdId,PrdBatId,SchType FROM 
					(SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,
					TransId,Usrid,SchType FROM BillApplieDSchemeHd WHERE SchId=@SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId) A
					CROSS JOIN 
					(
						SELECT A.PrdId,A.PrdBatId FROM BilledPrdHdForQPSScheme A (NOLOCK) 
						INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON A.RowId=10000 AND 
						A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End		
						AND CAST(A.PrdId AS NVARCHAR(10))+'~'+CAST(A.PrdBatId AS NVARCHAR(10)) 
						NOT IN (SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillApplieDSchemeHd WHERE SchId=@SchId
						AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId
					)
					)B
					WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
					NOT IN (SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
					FROM BillAppliedSchemeHd WHERE SchId=@SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId)
				END
				INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount,QPSGrossAmount)
				SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
				CASE @MRP
				WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
				WHEN 2 THEN A.GrossAmount
				WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
				AS GrossAmount,0 FROM BilledPrdHdForQPSScheme A
				LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=1
				UNION ALL
				SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
				CASE @MRP
				WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
				WHEN 2 THEN A.GrossAmount
				WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
				AS GrossAmount,0 FROM BilledPrdHdForQPSScheme A
				INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId
				IF @QPSDateQty=2 
				BEGIN
					UPDATE TPGS SET TPGS.RowId=BP.RowId
					FROM @TempPrdGross TPGS,BilledPrdHdForQPSScheme BP
					WHERE TPGS.PrdId=BP.PrdId AND TPGS.PrdBatId=BP.PrdBatId AND UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND BP.RowId<>10000
					AND TPGS.SchId=BP.SchId
					UPDATE C SET C.GrossAmount=C.GrossAmount+A.OtherGross
					FROM @TempPrdGross C,
					(SELECT SchId,SUM(GrossAmount) AS OtherGross FROM @TempPrdGross WHERE RowId=10000
					GROUP BY SchID) A,
					(SELECT SchId,ISNULL(MIN(RowId),2)  AS RowId FROM @TempPrdGross WHERE RowId<>10000 
					GROUP BY SchId) B
					WHERE A.SchId=B.SchId AND B.SchId=C.SchId AND B.RowId=C.RowId
					DELETE FROM @TempPrdGross WHERE RowId=10000
				END
				ELSE
				BEGIN
					UPDATE TPGS SET TPGS.RowId=BP.RowId
					FROM @TempPrdGross  TPGS,
					(
						SELECT SchId,ISNULL(MIN(RowId),2) RowId FROM BilledPrdHdForQPSScheme
						WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
						GROUP BY SchId
					) AS BP
					WHERE TPGS.SchId=BP.SchId 
				END	
			END
		END
		INSERT INTO @MoreBatch SELECT SchId,SlabId,PrdId,COUNT(DISTINCT PrdId),
		COUNT(DISTINCT PrdBatId),SchType FROM BillAppliedSchemeHd
		WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId GROUP BY SchId,SlabId,PrdId,SchType
		HAVING COUNT(DISTINCT PrdBatId)> 1
		IF EXISTS (SELECT * FROM @MoreBatch WHERE SchId=@SchId AND SlabId=@SlabId)
		BEGIN
			INSERT INTO @SchFlatAmt
			SELECT SchId,SlabId,FlatAmt,DiscPer,0 FROM SchemeSlabs
			WHERE SchId=@SchId AND SlabId=@SlabId
			INSERT INTO @SchFlatAmt
			SELECT SchId,SlabId,FlatAmt,DiscPer,1 FROM SchemeAnotherPrdDt
			WHERE SchId=@SchId AND SlabId=@SlabId
		END
	FETCH NEXT FROM CurSchid INTO @SchId,@SlabId
	END
	CLOSE CurSchid
	DEALLOCATE CurSchid
	----->
		
	SELECT DISTINCT * INTO TG FROM @TempSchGross
	SELECT DISTINCT * INTO TP FROM @TempPrdGross
	DELETE FROM @TempPrdGross
	
	INSERT INTO @TempPrdGross
	SELECT * FROM TP 
	
	
	---->For Scheme on Another Product QPS	
	UPDATE TPG SET TPG.GrossAmount=(TPG.GrossAmount/TSG.BilledGross)*TSG1.GrossAmount
	FROM @TempPrdGross TPG,(SELECT SchId,SUM(GrossAmount) AS BilledGross FROM @TempPrdGross GROUP BY SchId) TSG,
	@TempSchGross TSG1,SchemeMaster SM ,SchemeAnotherPrdHd SMA
	WHERE TPG.SchId=TSG.SchId AND TSG.SchId=TSG1.SchId AND SM.SchId=TPG.SchId AND SM.SchId=SMA.SchId
	UPDATE T1 SET QPSGrossAmount=A.GrossAmount
	FROM @TempPrdGross T1,BilledPrdHdForQPSScheme A
	WHERE T1.RowId=A.RowID AND T1.PrdId=A.PrdId AND T1.PrdBatId=A.PrdBatId AND A.TransId=@Pi_TransID AND A.UsrId=@Pi_UsrId
	AND A.QPSPrd=0 AND A.SchId=T1.SchId 
	UPDATE S1 SET S1.QPSGrossAmount=A.QPSGross	
	FROM @TempSchGross S1,(SELECT SchId,SUM(QPSGrossAmount) AS QPSGross FROM @TempPrdGross GROUP BY SchId) AS A
	WHERE A.SchId=S1.SchId
	
	IF EXISTS (SELECT Status FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 )
	BEGIN
		SELECT @RefCode = Condition FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1
		INSERT INTO @PDSchID (PrdId,PrdBatId,PDSchId,PDSlabId)
		SELECT SP.PrdId,SP.PrdBatId,BAS.SchId AS PDSchId,MIN(BAS.SlabId) AS PDSlabId
		FROM @TempPrdGross SP
		INNER JOIN BillAppliedSchemeHd BAS ON SP.SchId=BAS.SchId AND SchemeDiscount>0
		INNER JOIN (SELECT DISTINCT SP1.PrdId,SP1.PrdBatId,MIN(BAS1.SchId) AS MinSchId
		FROM BillAppliedSchemeHd BAS1,@TempPrdGross SP1
		WHERE SP1.SchId=BAS1.SchId
		AND SchemeDiscount >0 AND BAS1.UsrId = @Pi_Usrid AND BAS1.TransId = @Pi_TransId
		GROUP BY SP1.PrdId,SP1.PrdBatId) AS A ON A.MinSchId=BAS.SchId AND A.PrdId=SP.PrdId
		AND A.PrdBatId=SP.PrdBatId AND BAS.UsrId = @Pi_Usrid AND BAS.TransId = @Pi_TransId
		GROUP BY SP.PrdId,SP.PrdBatId,BAS.SchId
		IF @Pi_TransId=2
		BEGIN
			DECLARE @DiscPer TABLE
			(
				PrdId  INT,
				PrdBatId INT,
				DiscPer  NUMERIC(18,6),
				GrossAmount NUMERIC(18,6),
				RowId  INT
			)
			INSERT INTO @DiscPer
			SELECT SP1.PrdId,SP1.PrdBatId,ISNULL(SUM(BAS1.SchemeDiscount),0),SP1.GrossAmount,SP1.RowId
			FROM BillAppliedSchemeHd BAS1 LEFT OUTER JOIN @TempPrdGross SP1
			ON SP1.SchId=BAS1.SchId AND SP1.PrdId=BAS1.PrdId AND SP1.PrdBatId=BAS1.PrdBatId WHERE IsSelected=1 AND
			SchemeDiscount>0 AND BAS1.UsrId = @Pi_Usrid AND BAS1.TransId = @Pi_TransId
			GROUP BY SP1.PrdId,SP1.PrdBatId,SP1.RowId,SP1.GrossAmount
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			CASE 
				WHEN QPS=1 THEN
					(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
				ELSE  
					SchemeAmount 
				END  
			As SchemeAmount,
			C.GrossAmount - (C.GrossAmount / (1  +
			(
			(
				CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
					WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
						CASE dbo.Fn_ReturnPrimarySchRetCateGOry(@RtrId,@Pi_TransId) --Second Case Start
							WHEN 1 THEN  
								D.PrdBatDetailValue  
							ELSE 0 
						END     --Second Case End
					ELSE 0 
				END) + SchemeDiscount)/100))      --First Case END
			As SchemeDiscount,0 As FreeQty,
			@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount
			FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
			A.SchId = B.SchId INNER JOIN @TempPrdGross C ON A.Schid = C.SchId
			AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId and B.SchId = C.SchId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid	 		
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON C.PrdId= PD.PrdId AND
			(CASE PD.PrdBatId WHEN 0 THEN C.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			AND PD.PDSchId=A.SchId
			WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND (A.SchemeAmount + A.SchemeDiscount) > 0
			SELECT  A.RowId,A.PrdId,A.PrdBatId,D.PrdBatDetailValue,
			C.GrossAmount - (C.GrossAmount / (1  +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(F.SchId AS NVARCHAR(10))+'-'+CAST(F.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCateGOry(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			 D.PrdBatDetailValue  END     --Second Case End
			ELSE 0 END) + DiscPer)/100)) AS SchAmt,F.SchId,F.SlabId
			INTO #TempFinal
			FROM @DiscPer A
			INNER JOIN @TempPrdGross C ON  A.PrdId = C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId AND D.PrdbatId=A.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON A.PrdId= PD.PrdId AND PD.PDSchId=C.SchId AND
			(CASE PD.PrdBatId WHEN 0 THEN A.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			INNER JOIN BillAppliedSchemeHd F ON F.SchId=PD.PDSCHID AND A.PrdId=F.PrdId AND A.PrdBatId=F.PrdBatId
			
			SELECT A.RowId,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,A.DiscPer,
			(A.DiscPer+isnull(PrdbatDetailValue,0))
			as DISC,
			isnull(SUM(A.DiscPer+PrdbatDetailValue),SUM(A.DiscPer)) AS DiscSUM,ISNULL(B.SchAmt,0) AS SchAmt,
			CASE  WHEN (ISNULL(PrdbatDetailValue,0)>0 AND A.DiscPer > 0 )THEN 1
			  WHEN (ISNULL(PrdbatDetailValue,0)=0 AND A.DiscPer > 0) THEN 2
			  ELSE 3 END as Status
			INTO #TempSch1
			FROM ApportionSchemeDetails A LEFT OUTER JOIN #TempFinal B ON
			A.RowId =B.RowId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId
			AND A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.DiscPer > 0 AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
			GROUP BY A.RowId,A.PrdId,A.PrdBatId,A.SchId,A.SlabId,A.DiscPer,B.PrdbatDetailValue,B.SchAmt
			UPDATE #TempSch1 SET SchAmt=B.SchAmt
			FROM #TempFinal B
			WHERE  #TempSch1.RowId=B.RowId AND #TempSch1.PrdId=B.PrdId AND #TempSch1.PrdBatId=B.PrdBatId
			SELECT A.RowId,A.PrdId,A.PrdBatId,ISNULL(SUM(Disc),0) AS SUMDisc
			INTO #TempSch2
			FROM #TempSch1 A
			GROUP BY A.RowId,A.PrdId,A.PrdBatId
			UPDATE #TempSch1 SET DiscSUM=ISNULL((Disc/NULLIF(SUMDisc,0)),0)*SchAmt
			FROM #TempSch2 B
			WHERE #TempSch1.RowId=B.RowId AND #TempSch1.PrdId=B.PrdId AND #TempSch1.PrdBatId=B.PrdBatId
			UPDATE ApportionSchemeDetails SET SchemeDiscount=DiscSUM
			FROM #TempSch1 B,ApportionSchemeDetails A
			WHERE A.RowId=B.RowId AND A.PrdId = B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId AND
			A.SlabId= B.SlabId AND B.Status<3  AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
		END
		ELSE
		BEGIN
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount,
			C.GrossAmount - (C.GrossAmount /(1 +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCateGOry(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			D.PrdBatDetailValue  ELSE 0 END     --Second Case End
			ELSE 0 END) + SchemeDiscount)/100))       --First Case END
			As SchemeDiscount,0 As FreeQty,
			@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
			FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
			A.SchId = B.SchId AND (A.SchemeAmount + A.SchemeDiscount) > 0
			INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId AND
			A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid	 	
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
			AND E.Slno = D.Slno AND E.RefCode = @RefCode
			LEFT OUTER JOIN @PDSchID PD ON C.PrdId= PD.PrdId AND
			(CASE PD.PrdBatId WHEN 0 THEN C.PrdBatId ELSE PD.PrdBatId END)=C.PrdBatId
			WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		END
	END
	ELSE
	BEGIN
		---->For Scheme on Another Product QPS
		IF EXISTS(SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		BEGIN
			SELECT DISTINCT TP.SchId,BA.SlabId,TP.PrdId,TP.PrdBatId,TP.RowId,TP.GrossAmount 
			INTO TPQ FROM BillAppliedSchemeHd BA
			INNER JOIN SchemeMaster SM ON BA.SchId=SM.SchId AND Sm.QPS=1 AND SM.QPSReset=1
			INNER JOIN @TempPrdGross TP ON TP.SchId=BA.SchId
			SELECT DISTINCT TG.SchId,BA.SlabId,TG.GrossAmount 
			INTO TGQ FROM BillAppliedSchemeHd BA
			INNER JOIN SchemeMaster SM ON BA.SchId=SM.SchId AND Sm.QPS=1 AND SM.QPSReset=1
			INNER JOIN @TempSchGross TG ON TG.SchId=BA.SchId
			
			SELECT A.SchId,A.MaxSlabId,SS.PurQty
			INTO SchMaxSlab FROM
			(SELECT SM.SchId,MAX(SS.SlabId) AS MaxSlabId
			FROM SchemeMaster SM,SchemeSlabs SS
			WHERE SM.SchId=SS.SchId AND SM.QPSReset=1 
			GROUP BY SM.SchId) A,
			SchemeSlabs SS
			WHERE A.SchId=SS.SchId AND A.MaxSlabId=SS.SlabId 
			DECLARE @MSSchId AS INT
			DECLARE @MaxSlabId AS INT
			DECLARE @MSPurQty AS NUMERIC(38,6)
			DECLARE Cur_QPSSlabs CURSOR FOR 
			SELECT SchId,MaxSlabId,PurQty
			FROM SchMaxSlab
			OPEN Cur_QPSSlabs
			FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId,@MSPurQty
			WHILE @@FETCH_STATUS=0
			BEGIN		
				UPDATE TGQ SET GrossAmount=@MSPurQty 
				WHERE SchId=@MSSchId AND SlabId=@MaxSlabId
				UPDATE TGQ SET GrossAmount=GrossAmount-@MSPurQty 
				WHERE SchId=@MSSchId AND SlabId<@MaxSlabId
				FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId,@MSPurQty
			END
			CLOSE Cur_QPSSlabs
			DEALLOCATE Cur_QPSSlabs
			UPDATE T SET T.GrossAmount=(T.GrossAmount/TG.GrossAmount)*TGQ.GrossAmount
			FROM TPQ T,TG,TGQ
			WHERE T.SchId=TG.SchId AND TG.SchId=TGQ.SchId AND TGQ.SlabId=T.SlabId 	
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
			SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount
			,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
			@Pi_TransId AS TransId,@Pi_UsrId AS UsrId,SchemeDiscount,A.SchType
			FROM BillAppliedSchemeHd A 
			INNER JOIN TGQ B ON	A.SchId = B.SchId AND A.SlabId=B.SlabId
			INNER JOIN TPQ C ON A.Schid = C.SchId and B.SchId = C.SchId  AND B.SlabId=C.SlabId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid AND QPS=1 AND QPSReset=1	
			WHERE A.UsrId = @Pi_UsrId AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)	
			AND SM.SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
			GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		END
		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT DISTINCT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId		
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid and SM.QPS=1 	  		
		INNER JOIN SchemeAnotherPrdDt SOP ON SM.SchId=SOP.SchId AND A.SchId=SOP.SchId AND A.SlabId=SOP.SlabId
		AND A.PrdId=SOP.PrdId AND SOP.Prdid=C.PrdId 
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1 
		AND SM.SchId IN (SELECT SchId FROM SchemeAnotherPrdHd)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (CAST(CAST(C.GrossAmount AS NUMERIC(30,10))/CAST(B.GrossAmount AS NUMERIC(30,10)) AS NUMERIC(38,6))) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (CAST(CAST(C.GrossAmount AS NUMERIC(30,10))/CAST(B.GrossAmount AS NUMERIC(30,10)) AS NUMERIC(38,6))) * 100 END))/100 
		ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid 
		AND SM.CombiSch=0
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN  (QPS=1 AND CombiSch=0) OR (QPS=0 AND CombiSch=1) THEN
		SchemeAmount 
		ELSE  (
				CASE   WHEN SM.FlexiSch=1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
					   WHEN SM.CombiSch=1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100  
				ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid 
		AND SM.CombiSch=1
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
	END
	--Added by Boopathy.P  on 04-08-2011 
	IF EXISTS(SELECT * FROM SalesinvoiceTrackFlexiScheme WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId)
	BEGIN
		UPDATE A SET A.DiscPer=B.DiscPer FROM ApportionSchemeDetails A INNER JOIN SalesinvoiceTrackFlexiScheme B
		ON A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.UsrId=B.UsrId AND A.TransId=B.TransId
		WHERE A.UsrId=@Pi_UsrId AND A.TransID=@Pi_TransId
	END
	
	INSERT INTO @FreeQtyDt (FreePrdid,FreePrdBatId,FreeQty,SchId)
	SELECT DISTINCT FreePrdId,FreePrdBatId,SUM(DISTINCT FreeToBeGiven) As FreeQty,SchId from BillAppliedSchemeHd A
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1 
	GROUP BY FreePrdId,FreePrdBatId,SchId
	INSERT INTO @FreeQtyRow (RowId,PrdId,PrdBatId)
	SELECT MIN(A.RowId) as RowId,A.Prdid,MAX(A.PrdBatId) FROM BilledPrdHdForScheme A
	INNER JOIN BillAppliedSchemeHd B ON A.PrdId = B.PrdId AND
	A.PrdBatid = B.PrdBatId
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND
	B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY A.Prdid
	UPDATE ApportionSchemeDetails SET FreeQty = A.FreeQty FROM
	@FreeQtyDt A INNER JOIN @FreeQtyRow B ON
	A.FreePrdId  = B.PrdId
	WHERE ApportionSchemeDetails.RowId = B.RowId AND  ApportionSchemeDetails.PrdId = B.PrdId 
	AND A.SchId=ApportionSchemeDetails.SchId 
	AND ApportionSchemeDetails.UsrId = @Pi_UsrId AND ApportionSchemeDetails.TransId = @Pi_TransId
	AND CAST(ApportionSchemeDetails.SchId AS NVARCHAR(10))+'~'+CAST(ApportionSchemeDetails.SlabId AS NVARCHAR(10)) 
	IN (
	SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10)) 
	FROM BillAppliedSchemeHd A WHERE FreeToBeGiven>0 
	)
	--->Added the SchId+SlabId Concatenation By Nanda on 15/12/2010 in the above statement
	--->Added By Nanda on 20/09/2010
	SELECT * INTO #TempApp FROM ApportionSchemeDetails	
	DELETE FROM ApportionSchemeDetails
	INSERT INTO ApportionSchemeDetails
	SELECT DISTINCT * FROM #TempApp
	--->Till Here
	SELECT DISTINCT * FROM #TempApp
	UPDATE ApportionSchemeDetails SET SchemeAmount=0 WHERE DiscPer>0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId
	UPDATE ApportionSchemeDetails SET SchemeAmount=SchemeAmount+SchAmt,SchemeDiscount=SchemeDiscount+SchDisc
	FROM 
	(SELECT SchId,SUM(SchemeAmount) SchAmt,SUM(SchemeDiscount) SchDisc FROM ApportionSchemeDetails
	WHERE RowId=10000 GROUP BY SchId) A,
	(SELECT SchId,MIN(RowId) RowId FROM ApportionSchemeDetails WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId
	GROUP BY SchId) B
	WHERE ApportionSchemeDetails.SchId =  A.SchId AND A.SchId=B.SchId 
	AND ApportionSchemeDetails.RowId=B.RowId AND ApportionSchemeDetails.TransId=@Pi_TransId AND ApportionSchemeDetails.UsrId=@Pi_UsrId  
	DELETE FROM ApportionSchemeDetails WHERE RowId=10000
	INSERT INTO @RtrQPSIds
	SELECT DISTINCT RtrId,SchId FROM BilledPrdHdForQPSScheme WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	IF @Pi_Mode=0
	BEGIN
		INSERT INTO @QPSGivenDisc
		SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,
		SISL.DiscountPerAmount-SISL.ReturnDiscountPerAmount AS DiscountPerAmount,SISL.FlatAmount-SISL.ReturnFlatAmount AS FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
		WHERE DiscPer>0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId
		) A,SchemeMaster SM ,SalesInvoice SI,@RtrQPSIds RQPS
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
		) A	
		GROUP BY A.SchId
		UNION  -- Added by Boopathy.P on 09-08-2011 for Bug No:23402
		SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,
		SISL.DiscountPerAmount-SISL.ReturnDiscountPerAmount AS DiscountPerAmount,SISL.FlatAmount-SISL.ReturnFlatAmount AS FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
		WHERE DiscPer>0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId
		) A,SchemeMaster SM ,SalesInvoice SI,@RtrQPSIds RQPS
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND (SM.FlexiSch=1 AND SM.FlexiSchType=1 AND SM.QPS=1) 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
		) A	
		GROUP BY A.SchId
		UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
		FROM @QPSGivenDisc A,
		(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,@RtrQPSIds QPS,SalesInvoice SI
		WHERE B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.RtrId=QPS.RtrId AND QPS.SchId=B.SchId
		GROUP BY B.SchId) C
		WHERE A.SchId=C.SchId
		INSERT INTO @QPSGivenDisc
		SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
		WHERE B.RtrId IN(SELECT RtrID FROM @RtrQPSIds) AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenDisc)
		AND B.SchId IN(SELECT DISTINCT SchId FROM ApportionSchemeDetails WHERE SchemeAmount=0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId)
		AND SI.SalId=B.SalId AND SI.DlvSts>3
		GROUP BY B.SchId
	END
	ELSE IF @Pi_Mode=1
	BEGIN
		INSERT INTO @QPSGivenDisc
		SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount,SISL.FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL INNER JOIN
		(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
		WHERE SchemeAmount=0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId
		) A ON A.SchId=SISL.SchId AND A.SlabId=SISL.SlabId  INNER JOIN SchemeMaster SM 
		ON A.SchId=SM.SchId AND SM.QPS=1 AND SM.FlexiSch=0 
		INNER JOIN SalesInvoice SI ON SISL.SalId=SI.SalId AND Si.DlvSts>3
		INNER JOIN @RtrQPSIds RQPS ON RQPS.RtrId=Si.RtrId AND SI.RtrId=@RtrId
		WHERE SISL.SalId <> (SELECT SalId FROM Temp_InvoiceDetail)
		AND SISL.SalId <(SELECT SalId FROM Temp_InvoiceDetail)
		AND SI.SalInvdate BETWEEN SM.SchValidFrom AND (SELECT SalInvDate FROM Temp_InvoiceDetail)
		) A	GROUP BY A.SchId
		UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
		FROM @QPSGivenDisc A,
		(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,@RtrQPSIds QPS,SalesInvoice SI,
		SchemeMAster SM	
		WHERE B.SchId=SM.SchId AND SM.QPS=1 AND SM.FlexiSch=0 AND 
		B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.RtrId=QPS.RtrId AND QPS.SchId=B.SchId
		AND B.SalId <> (SELECT SalId FROM Temp_InvoiceDetail)
		AND SI.SalInvdate BETWEEN SM.SchValidFrom AND (SELECT SalInvDate FROM Temp_InvoiceDetail)
		AND B.SalId <(SELECT SalId FROM Temp_InvoiceDetail)
		GROUP BY B.SchId) C
		WHERE A.SchId=C.SchId
		INSERT INTO @QPSGivenDisc
		SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI,
		SchemeMAster SM	
		WHERE B.SchId=SM.SchId AND SM.QPS=1 AND SM.FlexiSch=0 AND 
		B.RtrId IN(SELECT RtrID FROM @RtrQPSIds) AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenDisc)
		AND B.SchId IN(SELECT DISTINCT SchId FROM ApportionSchemeDetails WHERE SchemeAmount=0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId)
		AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.SalInvdate BETWEEN SM.SchValidFrom AND (SELECT SalInvDate FROM Temp_InvoiceDetail)
		AND B.SalId <(SELECT SalId FROM Temp_InvoiceDetail)
		GROUP BY B.SchId
	END
	ELSE 
	BEGIN
		INSERT INTO @QPSGivenDisc
		SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
		(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount,SISL.FlatAmount
		FROM SalesInvoiceSchemeLineWise SISL INNER JOIN
		(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
		WHERE SchemeAmount=0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId
		) A ON A.SchId=SISL.SchId AND A.SlabId=SISL.SlabId  INNER JOIN SchemeMaster SM 
		ON A.SchId=SM.SchId AND SM.QPS=1 AND SM.FlexiSch=0 
		INNER JOIN SalesInvoice SI ON SISL.SalId=SI.SalId AND Si.DlvSts>3
		INNER JOIN @RtrQPSIds RQPS ON RQPS.RtrId=Si.RtrId AND SI.RtrId=@RtrId
		WHERE SISL.SalId <> (SELECT SalId FROM Temp_InvoiceDetail)
		) A	GROUP BY A.SchId
		UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
		FROM @QPSGivenDisc A,
		(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,@RtrQPSIds QPS,SalesInvoice SI
		WHERE B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.RtrId=QPS.RtrId AND QPS.SchId=B.SchId
		GROUP BY B.SchId) C
		WHERE A.SchId=C.SchId
		INSERT INTO @QPSGivenDisc
		SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
		WHERE B.RtrId IN(SELECT RtrID FROM @RtrQPSIds) AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenDisc)
		AND B.SchId IN(SELECT DISTINCT SchId FROM ApportionSchemeDetails WHERE SchemeAmount=0 AND TransId=@Pi_TransID AND UsrId=@Pi_UsrId)
		AND SI.SalId=B.SalId AND SI.DlvSts>3
		GROUP BY B.SchId
	END	
	
	--->Added By Nanda on 04/03/2011 for Flexi Sch
	DELETE FROM @QPSGivenDisc WHERE SchId IN (SELECT SchId FROM SchemeMaster WHERE FlexiSch=1 AND FlexiSchType=2)
	INSERT INTO @QPSNowAvailable
	SELECT A.SchId,SUM(SchemeDiscount)-ISNULL(B.Amount,0) 
	FROM ApportionSchemeDetails A
	INNER JOIN SchemeMaster	SM ON A.SchId=SM.SchId AND SM.QPS=1 AND A.TransId=@Pi_TransID AND A.UsrId=@Pi_UsrId
	LEFT OUTER JOIN @QPSGivenDisc B ON A.SchId=B.SchId 
	GROUP BY A.SchId,B.Amount 
	UPDATE A SET A.Contri=100*(B.QPSGrossAmount/CASE C.QPSGrossAmount WHEN 0 THEN 1 ELSE C.QPSGrossAmount END)	
	FROM ApportionSchemeDetails A,@TempPrdGross B,@TempSchGross C,SchemeMaster SM
	WHERE A.TRansId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.RowId=B.RowId AND 
	A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatID AND A.SchId=B.SchId AND B.SchId=C.SchId AND SM.SchId=A.SchId AND SM.QPS=1 AND SM.ApyQPSSch=2
	
	UPDATE A SET A.Contri=100*(B.GrossAmount/CASE C.GrossAmount WHEN 0 THEN 1 ELSE C.GrossAmount END)	
	FROM ApportionSchemeDetails A,@TempPrdGross B,@TempSchGross C,SchemeMaster SM
	WHERE A.TRansId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.RowId=B.RowId AND 
	A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatID AND A.SchId=B.SchId AND B.SchId=C.SchId AND SM.SchId=A.SchId AND SM.QPS=1 AND SM.ApyQPSSch=1
	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId NOT IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId )	
	AND ApportionSchemeDetails.TransId=@Pi_TransID AND ApportionSchemeDetails.UsrId=@Pi_UsrId
	UPDATE ApportionSchemeDetails SET SchemeDiscount=0
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId )	
	AND ApportionSchemeDetails.TransId=@Pi_TransID AND ApportionSchemeDetails.UsrId=@Pi_UsrId
	-->Till Here
	UPDATE ASD SET SchemeAmount=Contri*AdjAmount/100,SchemeDiscount=(CASE SM.CombiSch+SM.QPS WHEN 2 THEN 0 ELSE SchemeDiscount END)
	FROM ApportionSchemeDetails ASD,BillQPSSchemeAdj A,SchemeMaster SM 
	WHERE ASD.SchId=A.SchId AND SM.SchId=A.SchId AND ASD.SlabId=A.SlabId
	AND ASD.UsrId=A.UserId AND ASD.TransId=A.TransId
	UPDATE ASD SET SchemeAmount=SchemeAmount*SC.Contri
	FROM ApportionSchemeDetails ASD,
	(SELECT A.RowId,A.PrdId,A.PrdBatId,(A.GrossAmount/B.GrossAmount) AS Contri FROM BilledPrdHdForScheme A,
	(SELECT PrdId,PrdBatId,SUM(GrossAmount) AS GrossAmount FROM BilledPrdHdForScheme WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId
	GROUP BY PrdId,PrdBatId
	HAVING COUNT(*)>1) B
	WHERE A.PrdID=B.PrdID AND A.PrdBatId=B.PrdBatId) SC
	WHERE ASD.RowId=SC.RowId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId IN 
	(SELECT SchId FROM SchemeMAster WHERE QPS=0 AND CombiSch=0 AND FlexiSch=0)
END
GO
IF EXISTS (SELECT Name FROM sysobjects (NOLOCK) WHERE XTYPE IN ('TF','FN') AND Name = 'Fn_ReturnQPSSchemeMRPAmount')
DROP FUNCTION Fn_ReturnQPSSchemeMRPAmount
GO
--SELECT DISTINCT * FROM Dbo.Fn_ReturnQPSSchemeMRPAmount(17,2,1)
CREATE FUNCTION [dbo].[Fn_ReturnQPSSchemeMRPAmount] (@Pi_SchId BIGINT,@Pi_TransId BIGINT,@Pi_UsrId BIGINT)
RETURNS @ReturnQPSSchemeMRPAmount TABLE
(
	QPSGross     NUMERIC(18,6),
    CrNoteAmount NUMERIC(18,6)
)
AS
BEGIN
/***************************************************************
* FUNCTION   : Fn_ReturnQPSSchemeMRPAmount
* PURPOSE    : Returns the OPS Amount Based Apply on
* NOTES      : 
* CREATED    : Sathishkumar Veeramani 2015/06/22
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
----------------------------------------------------------------
*
****************************************************************/
	INSERT INTO @ReturnQPSSchemeMRPAmount (QPSGross,CrNoteAmount)
	SELECT (CASE ApplyOnMRPSelRte WHEN 1 THEN ISNULL(SUM(BaseQty*MRP),0) ELSE ISNULL(SUM(GrossAmount),0) END) AS QPSGross,
	ISNULL(B.CrNoteAmount,0) AS CrNoteAmount
	FROM BilledPrdHdForQPSScheme A (NOLOCK)
	INNER JOIN SchemeMaster SM (NOLOCK) ON A.SchId = SM.SchId 
	LEFT OUTER JOIN (SELECT SchId,RtrId,ISNULL(SUM(CrNoteAmount),0) AS CrNoteAmount 
	FROM SalesInvoiceQPSSchemeAdj  (NOLOCK) WHERE SchId = @Pi_SchId GROUP BY SchId,RtrId) B ON 
	A.RtrId=B.RtrId AND A.SchId=B.SchId WHERE QPSPrd=1 AND UsrId=@Pi_UsrId AND TransId=@Pi_TransId 
	AND A.SchId=@Pi_SchId GROUP BY ApplyOnMRPSelRte,B.CrNoteAmount
RETURN
END
GO
IF EXISTS(SELECT Name FROM SYSOBJECTS WHERE NAME='Proc_QPSSchemeCrediteNoteConversion' AND XTYPE='P')
DROP PROCEDURE Proc_QPSSchemeCrediteNoteConversion
GO
/*
BEGIN TRANSACTION
EXEC Proc_QPSSchemeCrediteNoteConversion 2,'2015-06-24',0
SELECT * FROM SchQPSConvDetails 
SELECT * FROM SalesInvoiceQpsDatebasedTrack
SELECT * FROM CreditNoteRetailer WHERE RtrId = 42
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_QPSSchemeCrediteNoteConversion]
(
	@Pi_TransId		INT,
	@Pi_TransDate	DATETIME,
	@Po_ErrNo		INT	OUTPUT
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
* 16-11-2011    Boopathy.P        Add table to track the invoice details for QPS Datebased Scheme	
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
	DECLARE @SchemeAvailable TABLE
	(
		SchId			INT,
		SchCode			NVARCHAR(200),
		CmpSchCode		NVARCHAR(200),
		CombiSch		INT,
		QPS				INT		
	)
	DECLARE @Condition	INT
	DECLARE @Mode		INT
	SELECT @SchCoaId=CoaId FROM COAMaster WHERE Accode='4220001'	
	SET @LcnId=0
	SELECT @LcnId=LcnId FROM Location WHERE DefaultLocation=1
	IF @LcnId=0
	BEGIN
		SELECT @LcnId=LcnId FROM Location WHERE LcnId IN (SELECT MIN(LcnId) FROM Location)
	END	
	IF NOT EXISTS (SELECT * FROM Configuration WHERE ModuleName='Billing QPS Scheme' AND ModuleId IN ('BILLQPS3') AND Status=1)
	BEGIN
		SELECT @Condition=Condition FROM Configuration WHERE ModuleId IN ('DAYENDPROCESS4')
		SET @Pi_TransDate = DATEADD(D,(@Condition)*-1,@Pi_TransDate)
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT * FROM Configuration WHERE ModuleName='Billing QPS Scheme' AND ModuleId IN ('BILLQPS3') 
					AND Status=1)
		BEGIN
			SELECT @Mode=Condition FROM Configuration WHERE ModuleName='Billing QPS Scheme' AND ModuleId IN ('BILLQPS3')
			IF @Mode=0
			BEGIN
				SELECT @Condition=ConfigValue FROM Configuration WHERE ModuleName='Billing QPS Scheme' 
				AND ModuleId IN ('BILLQPS3') AND Status=1
				SET @Pi_TransDate = DATEADD(D,(@Condition)*-1,@Pi_TransDate)
			END
			ELSE
			BEGIN
				SELECT @Condition=Condition FROM Configuration WHERE ModuleId IN ('DAYENDPROCESS4')
				SET @Pi_TransDate = DATEADD(D,(@Condition)*-1,@Pi_TransDate)
			END
		END
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
		DELETE FROM BilledPrdHdForScheme 
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
		IF EXISTS (SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
			FROM Fn_ReturnApplicableProductDtQPS() B 
			INNER JOIN SchemeMaster C WITH(NoLock) ON C.SchId = B.SchId WHERE
			C.SchValidTill < @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1 
			AND C.SchId NOT IN (SELECT DISTINCT SchId FROM SchQPSConvDetails WITH(NoLock)))
		BEGIN 
			DECLARE Cur_Retailer CURSOR	
			FOR SELECT distinct R.RtrId,R.RtrCode,R.CmpRtrCode,R.RtrName FROM Retailer  R WITH(NoLock) 
				INNER JOIN SalesInvoiceQPSCumulative B WITH(NoLock)ON B.RtrId = R.RtrId
				INNER JOIN SchemeMaster C WITH(NoLock) ON C.SchId = B.SchId  AND C.SchValidTill < @Pi_TransDate 
				AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1 AND C.SchId NOT IN (SELECT DISTINCT SchId FROM SchQPSConvDetails WITH(NoLock))
			OPEN Cur_Retailer
			FETCH NEXT FROM Cur_Retailer INTO @RtrId,@RtrCode,@CmpRtrCode,@RtrName
			WHILE @@FETCH_STATUS=0
			BEGIN
				TRUNCATE TABLE BilledPrdHdForScheme      
				DELETE FROM @SchemeAvailable
				INSERT INTO BilledPrdHdForScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice)
				VALUES(2,@RtrId,1,1,10.00,100,1000.00,12.00,2,@UsrId,7.50)
				INSERT INTO @SchemeAvailable(SchId,SchCode,CmpSchCode,CombiSch,QPS)
				SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
				FROM Fn_ReturnApplicableProductDtQPS() B 
				INNER JOIN SchemeMaster C WITH(NoLock) ON C.SchId = B.SchId WHERE
				C.SchValidTill < @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1 
				AND C.SchId NOT IN (SELECT SchId FROM TempSalesInvoiceQPSRedeemed WITH(NoLock) WHERE SalId=-1000) 
				AND C.SchId NOT IN (SELECT SchId FROM SchQPSConvDetails WITH(NoLock))
				
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
				
				TRUNCATE TABLE BillAppliedSchemeHd 
				TRUNCATE TABLE ApportionSchemeDetails 
				TRUNCATE TABLE BilledPrdRedeemedForQPS 
				TRUNCATE TABLE BilledPrdHdForQPSScheme
				--->Applying QPS Scheme
				DECLARE Cur_Scheme CURSOR	
				FOR SELECT DISTINCT SchId,SchCode,CmpSchCode,CombiSch,QPS FROM @SchemeAvailable
				OPEN Cur_Scheme 
				FETCH NEXT FROM Cur_Scheme INTO @SchId,@SchCode,@CmpSchCode,@CombiSch,@QPS
				WHILE @@FETCH_STATUS=0
				BEGIN
									
					SET @SchApplicable=0
					EXEC Proc_ReturnSchemeApplicable @SMId,@RMId,@RtrId,1,1,@SchId,@Po_Applicable= @SchApplicable OUTPUT
					IF @SchApplicable =1
					BEGIN
						IF @CombiSch=1
						BEGIN
							EXEC Proc_ApplyCombiSchemeInBill @SchId,@RtrId,0,@UsrId,2,2		
						END
						ELSE
						BEGIN
							EXEC Proc_ApplyQPSSchemeInBill @SchId,@RtrId,0,@UsrId,2,2		
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
					FOR SELECT SchId,SchCode,CmpSchCode,SUM(SchemeAmount),SUM(SchemeDiscount),SchDesc 
						FROM #AppliedSchemeDetails	GROUP BY SchId,SchCode,CmpSchCode,SchDesc
					OPEN Cur_SchFree
					FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSchCode,@AvlCmpSchCode,@AvlSchAmt,@AvlSchDiscPerc,@AvlSchDesc
					WHILE @@FETCH_STATUS=0
					BEGIN				
						SET @SchAmtToConvert=0
						SELECT @SchApplicableAmt=(CASE ApplyOnMRPSelRte WHEN 1 THEN ISNULL(SUM((BaseQty*MRP)),0) ELSE ISNULL(SUM(GrossAmount),0) END) 
						FROM BilledPrdHdForQPSScheme A (NOLOCK)
						INNER JOIN SchemeMaster SM (NOLOCK) ON A.SchId = SM.SchId WHERE QPSPrd=1 AND UsrId=@UsrId
						AND TransId=2 AND A.SchId=@AvlSchId AND RtrId=@RtrId GROUP BY ApplyOnMRPSelRte
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
		END 
		DELETE FROM BilledPrdHdForScheme WHERE UsrId=@UsrId
		DELETE FROM SalesInvoiceProduct WHERE SalId=-1000
		DELETE FROM SalesInvoice WHERE SalId=-1000	
	END
	INSERT INTO SchQPSConvDetails(SchId,CmpSchCode,ConvDate)
	SELECT DISTINCT C.SchId,C.CmpSchCode,GETDATE() FROM SchemeMaster C 
	INNER JOIN SalesInvoiceQPSCumulative B ON C.SchId = B.SchId 
	INNER JOIN @SchemeAvailable A ON A.SchId=C.SchId
	WHERE C.SchValidTill < @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1
END
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.2',423
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE FixId = 423)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(423,'D','2015-06-24',GETDATE(),1,'Core Stocky Service Pack 423')