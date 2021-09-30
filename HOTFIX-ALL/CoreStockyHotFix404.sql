--[Stocky HotFix Version]=404
DELETE FROM Versioncontrol WHERE Hotfixid='404'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('404','2.0.0.0','D','2013-09-05','2013-09-05','2013-09-05',convert(varchar(11),getdate()),'PARLE-Major: Product Release March CR')
GO
IF EXISTS (SELECT * FROM sysobjects WHERE Name = 'SyncAttempt' AND Xtype = 'U')
DROP TABLE SyncAttempt
GO
CREATE TABLE SyncAttempt(
	[IPAddress] [varchar](300) NULL,
	[Status] [int] NULL,
	[StartTime] [datetime] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE Name = 'Proc_SyncValidation' AND Xtype ='P')
DROP PROCEDURE Proc_SyncValidation
GO
CREATE PROCEDURE Proc_SyncValidation
(
@piTypeId INT,    
@piCode VARCHAR(100) = ''
)
AS
BEGIN

 Declare @Sql Varchar(Max)  
 Declare @IntRetVal Int
 IF @piTypeId = 1 -- Distributor Code, Proc_SyncValidation  piTypeId    
 Begin    
  SELECT DistributorCode FROM Distributor WHERE Distributorid=1     
 End    
 IF @piTypeId = 2 -- Upload And Download, Path Proc_SyncValidation  piTypeId    
 Begin    
  SELECT Condition FROM Configuration WHERE ModuleId In ('DATATRANSFER44') AND ModuleName='DataTransfer' Order By ModuleId     
 End     
 IF @piTypeId = 3 -- Sync Attempt Validation  Proc_SyncValidation  @piTypeId,@piCode    
 Begin    
  Set @piCode = (Select Top 1 HostName From Sys.sysprocesses where  status='RUNNABLE' Order By login_time desc)    
  IF ((SELECT Count(*) From SyncAttempt) < 1)    
   BEGIN    
    INSERT INTO SyncAttempt    
    SELECT @piCode,1,Getdate()    
    SELECT 1    
   END     
  ELSE    
   BEGIN    
    IF (SELECT Status From SyncAttempt) = 0    
     BEGIN    
      UPDATE SyncAttempt SET IPAddress = @piCode,Status = 1,StartTime = Getdate()     
      SELECT 1    
     END    
    ELSE    
     BEGIN    
      IF ((SELECT DatedIFf(hh,StartTime,Getdate()) From SyncAttempt) > 1)    
       BEGIN    
          UPDATE SyncAttempt SET IPAddress = @piCode,Status = 1,StartTime = Getdate()     
          SELECT 1    
       END    
      ELSE    
        IF ((SELECT Count(*) From SyncAttempt WHERE IPAddress = @piCode) = 1 )    
         BEGIN    
          UPDATE SyncAttempt SET Status = 1,StartTime = Getdate()     
          SELECT 1    
         END    
        ELSE    
         BEGIN    
          SELECT 0             
         END    
     END    
   END      
 END
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype in('TF','FN') And Name = 'Fn_FillBatchBasedOnExpdate')
DROP FUNCTION Fn_FillBatchBasedOnExpdate
GO
CREATE FUNCTION Fn_FillBatchBasedOnExpdate (@Pi_LcnId INT,@Pi_Prdid INT,@Pi_Date DATETIME)
RETURNS @FillBatchBasedOnExpdate TABLE
(
	PrdBatID     INT,
    PrdBatCode   NVARCHAR(50),
    MRP          NUMERIC (18,6),	
	PurchaseRate NUMERIC (18,6),
    SellRate     NUMERIC (18,6),
    StockAvail   INT,
    ShelfDay     VARCHAR (50),
    ExpiryDay    VARCHAR (50),
    PriceId      INT
)
AS
BEGIN
INSERT INTO @FillBatchBasedOnExpdate (PrdBatID,PrdBatCode,MRP,PurchaseRate,SellRate,StockAvail,ShelfDay,ExpiryDay,PriceId)
SELECT TOP 1 A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS PurchaseRate,K.PrdBatDetailValue AS SellRate,(F.PrdBatLcnSih - F.PrdBatLcnRessih) as StockAvail, 
A.MnfDate as ShelfDay,A.ExpDate as ExpiryDay,B.PriceId FROM ProductBatch A (NOLOCK) 
INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 
INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1 
INNER JOIN ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 
INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1 
INNER JOIN ProductBatchDetails K (NOLOCK) ON A.PrdBatId = K.PrdBatID AND K.DefaultPrice=1 
INNER JOIN BatchCreation H (NOLOCK) ON H.BatchSeqId = A.BatchSeqId AND K.SlNo = H.SlNo AND H.SelRte = 1 
INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId 
INNER JOIN ProductBatchLocation F (NOLOCK) ON F.PrdBatId = A.PrdBatId 
WHERE A.Status = 1 AND A.PrdId = @Pi_Prdid AND F.LcnId = @Pi_LcnId And (F.PrdBatLcnSih - F.PrdBatLcnRessih) > 0 And A.ExpDate > = @Pi_Date
ORDER BY ExpiryDay Asc
RETURN
END
GO
--NIVEA Target Default Configurations & Default Target Norms Mapping
DELETE FROM Configuration WHERE ModuleId IN ('TARGETANALYSIS1','TARGETANALYSIS2','TARGETANALYSIS4','TARGETANALYSIS9')
INSERT INTO Configuration
SELECT 'TARGETANALYSIS1','Target Analysis','Manual',1,'',0.00,1 UNION 
SELECT 'TARGETANALYSIS2','Target Analysis','Company',1,'',1.00,2 UNION 
SELECT 'TARGETANALYSIS4','Target Analysis','Target Type',1,'',2.00,4 UNION 
SELECT 'TARGETANALYSIS9','Target Analysis','Target Split',1,'',0.00,9
GO
IF EXISTS (SELECT * FROM Norms WHERE NormDescription = 'Past Three Months Sales') 
BEGIN
	DECLARE @CmpId AS INT
	DECLARE @NormId AS INT
	SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1
	SELECT @NormId = NormId FROM Norms WHERE NormDescription = 'Past Three Months Sales'
   IF EXISTS (SELECT DISTINCT A.TargetNormId FROM TargetNormMappingHD A WITH (NOLOCK),TargetNormMappingDt B WITH(NOLOCK) WHERE A.TargetNormId = B.TargetNormId)
   BEGIN
        UPDATE TargetNormMappingHD SET CmpId = @CmpId,NormId = @NormId,VariationTypeId = 0,VariationPerc = 0.00
        UPDATE TargetNormMappingDt SET NormId = @NormId,VariationTypeId = 0,VariationPerc = 0.00
        DECLARE @TargetNormId AS INT
        SELECT @TargetNormId = MAX(TargetNormId) FROM TargetNormMappingHD WITH (NOLOCK)
        INSERT INTO TargetNormMappingDt (TargetNormId,PrdId,NormId,VariationTypeId,VariationPerc,Availability,LastModBy,LastModDate,AuthId,AuthDate)
        SELECT DISTINCT @TargetNormId,PrdId,@NormId,0,0.00,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) 
        FROM Product WITH (NOLOCK) WHERE PrdId NOT IN (SELECT PrdId FROM TargetNormMappingDt WHERE TargetNormId = @TargetNormId)
   END
   ELSE
   BEGIN
		DELETE FROM TargetNormMappingDt
		DELETE FROM TargetNormMappingHD
		INSERT INTO TargetNormMappingHD (TargetNormId,CmpId,NormId,VariationTypeId,VariationPerc,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT 1,@CmpId,@NormId,0,0.00,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)
		INSERT INTO TargetNormMappingDt (TargetNormId,PrdId,NormId,VariationTypeId,VariationPerc,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT 1,PrdId,@NormId,0,0.00,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM Product WITH (NOLOCK)
		UPDATE Counters SET CurrValue = 1 WHERE Tabname = 'TargetNormMappingHD' AND FldName = 'TargetNormId'
	END
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE IN ('TF','FN') AND name = 'Fn_ReturnBudgetUtilized')
DROP FUNCTION Fn_ReturnBudgetUtilized
GO
--SELECT dbo.Fn_ReturnBudgetUtilized(1492) AS Amt
CREATE FUNCTION Fn_ReturnBudgetUtilized
(
	@Pi_SchId INT
)
RETURNS NUMERIC(38,6)
AS
/***********************************************
* FUNCTION: Fn_ReturnBudgetUtilized
* PURPOSE: Returns the Budget Utilized for the Selected Scheme
* NOTES:
* CREATED: Thrinath Kola	11-06-2007
* MODIFIED
* DATE			AUTHOR     DESCRIPTION
------------------------------------------------
* 22/04/2010	Nanda	   Added FBM Scheme	
************************************************/
BEGIN
	DECLARE @SchemeAmt 		NUMERIC(38,6)
	DECLARE @FreeValue		NUMERIC(38,6)
	DECLARE @GiftValue		NUMERIC(38,6)
	DECLARE @Points			INT
	DECLARE @RetSchemeAmt 	NUMERIC(38,6)
	DECLARE @RetFreeValue	NUMERIC(38,6)
	DECLARE @RetGiftValue	NUMERIC(38,6)
	DECLARE @RetPoints		INT
	DECLARE @WindowAmt		NUMERIC(38,6)
	DECLARE @BudgetUtilized	NUMERIC(38,6)
	DECLARE @FBMSchAmt		NUMERIC(38,6)
	DECLARE @QPSSchAmt		NUMERIC(38,6)
	SET @Points=0
	SET @RetPoints=0
	--Added by Sathishkumar Veeramani 2013/03/14
	DECLARE @ProductBatchDetails TABLE 
	(
	  PrdId NUMERIC(18,0),
	  PrdBatId NUMERIC(18,0),
	  PriceId NUMERIC(18,0),
	  PrdBatDetailValue NUMERIC(18,6)
	)	
	INSERT INTO @ProductBatchDetails (PrdId,PrdBatId,PriceId,PrdBatDetailValue) 
	SELECT DISTINCT A.PrdId,A.PrdBatId,B.PriceId,B.PrdBatDetailValue 
	FROM ProductBatch A WITH (NOLOCK),ProductBatchDetails B WITH (NOLOCK),BatchCreation C WITH (NOLOCK) 
	WHERE A.PrdBatId = B.PrdBatId AND A.BatchSeqId = C.BatchSeqId AND B.SLNo = C.SLNo AND C.ClmRte = 1
	--Till Here
	
	SELECT @SchemeAmt = (ISNULL(SUM(FlatAmount - ReturnFlatAmount),0) +
		ISNULL(SUM(DiscountPerAmount - ReturnDiscountPerAmount),0)) FROM
		(SELECT A.SalId,A.SchId,A.FlatAmount,A.ReturnFlatAmount,A.DiscountPerAmount,A.ReturnDiscountPerAmount FROM 
		SalesInvoiceSchemeLineWise A (NOLOCK)INNER JOIN SalesInvoice B (NOLOCK) ON A.SalId = B.SalId AND A.SchId = @Pi_SchId AND B.Dlvsts<> 3)A1
		INNER JOIN SchemeMaster S (NOLOCK) ON A1.SchId=S.SchId AND S.FBM=0 AND S.SchId = @Pi_SchId
	--SELECT @FreeValue = ISNULL(SUM((FreeQty - ReturnFreeQty) * D.PrdBatDetailValue),0)
	--	FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
	--	INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId
	--	INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId
	--	INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
	--	INNER JOIN SchemeMaster S ON A.SchId=S.SchId AND S.FBM=0
	--	WHERE A.SchId = @Pi_SchId AND DlvSts <> 3
	SELECT  @FreeValue =ISNULL(SUM((FreeQty - ReturnFreeQty) * C.PrdBatDetailValue),0)
		FROM 
		(SELECT A.SchId,A.FreePrdId,A.FreePrdBatId,A.FreePriceId,A.FreeQty,A.ReturnFreeQty FROM 
		SalesInvoiceSchemeDtFreePrd A (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) ON A.SalId = B.SalId WHERE A.SchId=@Pi_SchId AND B.DlvSts <> 3) A2
		INNER JOIN @ProductBatchDetails C ON A2.FreePrdId = C.PrdId AND A2.FreePrdBatId = C.PrdBatId AND A2.FreePriceId = C.PriceId
		--INNER JOIN @ProductBatchDetails D ON C.PrdBatId = D.PrdBatId AND A2.FreePriceId = D.PriceId
		--INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster S ON A2.SchId=S.SchId AND S.FBM=0 AND S.SchId = @Pi_SchId
		WHERE A2.SchId = @Pi_SchId 		
	SELECT @GiftValue = ISNULL(SUM((GiftQty - ReturnGiftQty) * C.PrdBatDetailValue),0) FROM
	    (SELECT A.SchId,A.GiftPrdId,A.GiftPrdBatId,A.GiftPriceId,A.GiftQty,A.ReturnGiftQty FROM SalesInvoiceSchemeDtFreePrd A (NOLOCK)	
         INNER JOIN SalesInvoice B (NOLOCK) ON A.SalId = B.SalId AND DlvSts <> 3 )A3
		INNER JOIN @ProductBatchDetails C ON A3.GiftPrdId = C.PrdId AND A3.GiftPrdBatId = C.PrdBatId AND A3.GiftPriceId = C.PriceId
		--INNER JOIN @ProductBatchDetails D ON C.PrdBatId = D.PrdBatId AND A3.GiftPriceId = D.PriceId
		--INNER JOIN BatchCreation E (NOLOCK)	ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
		INNER JOIN SchemeMaster S ON A3.SchId=S.SchId AND S.FBM=0 AND S.SchId = @Pi_SchId
		WHERE A3.SchId = @Pi_SchId 
--	 SELECT @Points = ISNULL(SUM(Points - ReturnPoints),0) FROM SalesInvoiceSchemeDtPoints A
-- 		INNER JOIN SalesInvoice B ON A.SalId = B.SalId WHERE SchId = @Pi_SchId
-- 		AND DlvSts <> 3
--	 SELECT @RetSchemeAmt = (ISNULL(SUM(ReturnFlatAmount),0) +
-- 		ISNULL(SUM(ReturnDiscountPerAmount),0))
-- 		FROM ReturnSchemeLineDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
-- 		WHERE SchId = @Pi_SchId AND Status = 0
--
--	 SELECT @RetFreeValue = ISNULL(SUM(ReturnFreeQty * D.PrdBatDetailValue),0)
-- 		FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
-- 		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND
-- 		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON
-- 		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
--			 ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
-- 		WHERE SchId = @Pi_SchId AND B.Status = 0
--
--	 SELECT @RetGiftValue = ISNULL(SUM(ReturnGiftQty * D.PrdBatDetailValue),0)
-- 		FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId
-- 		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND
-- 		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON
-- 		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
--			 ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1
-- 		WHERE SchId = @Pi_SchId AND B.Status = 0
--	 SELECT @RetPoints = ISNULL(SUM(ReturnPoints),0) FROM ReturnSchemePointsDt A
-- 		INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId WHERE SchId = @Pi_SchId
-- 		AND Status = 0
	SELECT @WindowAmt = ISNULL(SUM(AdjAmt),0) FROM SalesInvoiceWindowDisplay A (NOLOCK)
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		WHERE SchId = @Pi_SchId AND DlvSts <> 3
	SELECT @WindowAmt = @WindowAmt + ISNULL(SUM(Amount),0) FROM ChequeDisbursalMaster A (NOLOCK)
		INNER JOIN ChequeDisbursalDetails B (NOLOCK) ON A.ChqDisRefNo = B.ChqDisRefNo
		WHERE TransId = @Pi_SchId AND TransType = 1 
	SELECT @FBMSchAmt=ISNULL(SUM(DiscAmt),0) FROM FBMSchDetails (NOLOCK) WHERE SchId=@Pi_SchId AND TransId IN (2)
	AND SchId IN(SELECT SchId FROM SchemeMaster (NOLOCK) WHERE FBM=1)
	--->Added By Nanda on 27/10/2010
	SELECT @QPSSchAmt=ISNULL(SUM(CrNoteAmount),0) FROM SalesInvoiceQPSSchemeAdj SIQ (NOLOCK)
	INNER JOIN SalesInvoice SI (NOLOCK) ON SI.SalId=SIQ.SalId AND SI.DlvSts>3 AND SIQ.SchId=@Pi_SchId
	WHERE SIQ.SchId IN(SELECT SchId FROM SchemeMaster (NOLOCK) WHERE FBM=0)
	SET @BudgetUtilized = (@SchemeAmt + @FreeValue + @GiftValue + @Points + @WindowAmt+ @FBMSchAmt+@QPSSchAmt)
	-- 	- (@RetSchemeAmt + @RetFreeValue + @RetGiftValue + @RetPoints)
	SET @BudgetUtilized=ISNULL(@BudgetUtilized,0)
	RETURN(@BudgetUtilized)
END
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE NAME='EffectiveCoverage' AND id IN (SELECT id FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='TargetAnalysisDt'))
BEGIN
	ALTER TABLE TargetAnalysisDt ADD EffectiveCoverage INT
END
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE NAME='LinesSold' AND id IN (SELECT id FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='TargetAnalysisDt'))
BEGIN
	ALTER TABLE TargetAnalysisDt ADD LinesSold BIGINT
END
GO
IF EXISTS (SELECT * FROM SYSCOLUMNS WHERE NAME='RMId' AND id IN (SELECT id FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='TargetAnalysisDt'))
BEGIN
	ALTER TABLE TargetAnalysisDt DROP CONSTRAINT FK_TargetAnalysisDt_RMId
	ALTER TABLE TargetAnalysisDt DROP COLUMN RMId
END
GO
IF EXISTS (SELECT * FROM SYSCOLUMNS WHERE NAME='RtrId' AND id IN (SELECT id FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='TargetAnalysisDt'))
BEGIN
	ALTER TABLE TargetAnalysisDt DROP CONSTRAINT FK_TargetAnalysisDt_RtrId
	ALTER TABLE TargetAnalysisDt DROP COLUMN RtrId
END
GO
IF EXISTS (SELECT * FROM SYSCOLUMNS WHERE NAME='PrdId' AND id IN (SELECT id FROM SYSOBJECTS WHERE XTYPE='U' AND NAME ='TargetAnalysisDt'))
BEGIN
	ALTER TABLE TargetAnalysisDt DROP CONSTRAINT FK_TargetAnalysisDt_PrdId
	ALTER TABLE TargetAnalysisDt DROP COLUMN PrdId
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='TgtSMLevel' AND XTYPE='U')
DROP TABLE TgtSMLevel
GO
CREATE TABLE TgtSMLevel
(
	TargetAnalysisId int,
	[SMId] [int] NULL,
	[SugPlan] [numeric](18, 6) NULL,
	[CurMonthPlan] [numeric](16, 6) NULL,	
	EffectiveCoverage int null,
	LinesSold bigint null,	
	[WK1] [numeric](18, 6) NULL,
	[WK2] [numeric](18, 6) NULL,
	[WK3] [numeric](18, 6) NULL,
	[WK4] [numeric](18, 6) NULL,
	[WK5] [numeric](18, 6) NULL,
	[UserId] [int] NULL,
)
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE name='Proc_TargetBrandSMLevel' AND XTYPE='P')
DROP PROCEDURE Proc_TargetBrandSMLevel
GO
CREATE PROCEDURE Proc_TargetBrandSMLevel
(
	@Pi_TargetAnalysisId AS INT,
	@Pi_WeekCnt AS INT,
	@Pi_Type AS INT,
	@Pi_UserId AS INT
) 
/*********************************
* PROCEDURE	: Proc_TargetSplit
* PURPOSE	: To Calculate Target for Brand SalesMan
* CREATED	: Aravindh Deva C
* CREATED DATE	: 14.01.2013
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*********************************/
AS		
SET NOCOUNT ON
BEGIN
	
	DELETE TargetAnalysisDt WHERE TargetAnalysisId=@Pi_TargetAnalysisId
	
	INSERT INTO TargetAnalysisDt(TargetAnalysisId,PrdCtgValMainId,PrdUnitId,SmId,
	SuggestedTarget,CurMonthTarget,EffectiveCoverage,LinesSold,RtrDayOff,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT  @Pi_TargetAnalysisId,PrdCtgValMainId,PrdUnitId,SmId,
	ISNULL(SugPlan,0),ISNULL(CurMonthPlan,0),0,0,1 AS RtrDayOff,1,@Pi_UserId,GETDATE(),@Pi_UserId,GETDATE()
	FROM TgtBrand_SMLevel WHERE TargetAnalysisId=@Pi_TargetAnalysisId
	
	--DELETE FROM TgtBrand_SMLevel
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_PrdCategory' AND XTYPE='TF')
DROP FUNCTION Fn_PrdCategory
GO
CREATE FUNCTION Fn_PrdCategory(@Pi_CmpId INT)
RETURNS @PrdCtg TABLE
(
CmpPrdCtgId int,
CmpPrdCtgName nvarchar(100),
PrdCtgValMainId int,
PrdCtgValName nvarchar(100)
)
AS
BEGIN
/*********************************
* FUNCTION: Fn_PrdCategory
* PURPOSE: Returns Product Category Id and Name
* NOTES: 
* CREATED: Aravindh Deva C	12.01.2013
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 

*********************************/

INSERT INTO @PrdCtg
SELECT CmpPrdCtgId,CmpPrdCtgName,0,'ALL' FROM ProductCategoryLevel WHERE CmpPrdCtgName='BrandGroup' AND CmpId=@Pi_CmpId

RETURN
END
GO
IF NOT EXISTS(SELECT * FROM SYSCOLUMNS WHERE NAME='PlanPerRetInVal' AND ID IN(SELECT id FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='LaunchTargetMonthPlan'))
BEGIN
     ALTER TABLE LaunchTargetMonthPlan ADD PlanPerRetInVal NUMERIC(36,2)
END
GO
DELETE FROM customcaptions WHERE CtrlName IN ('MsgBox-46-1000-14','fpDist-46-18-10')
INSERT INTO customcaptions SELECT 46	,1000	,14	,'MsgBox-46-1000-14','','',
'Target already Exists for the Selected Company,JC Details,TargetType and TargetLevel',1,1,1,'2013-01-16',1,'2013-01-16','','',
'Target already Exists for the Selected Company,JC Details,TargetType and TargetLevel',1,1 UNION ALL
SELECT 46,18,10,'fpDist-46-18-10','Productivity Calls','','',1,	1,	1,	'2013-02-18' ,	1,	'2013-02-18','Productivity Calls','','',1,1
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE ID IN (SELECT id FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='LaunchTargetHd') AND NAME='RetailerCls')
BEGIN
   ALTER TABLE LaunchTargetHd ADD RetailerCls INT
END
GO
UPDATE HotSearchEditorHd SET RemainsltString='SELECT A.RMId,A.RMCode,A.RMName FROM RouteMaster A INNER JOIN SalesmanMarket B ON A.RMId=B.RMId WHERE A.RMSRouteType=1 AND B.SMId IN (SELECT iCountId FROM Fn_ReturnRptFilters(vFParam,1,vSParam)) ORDER BY RMName' where formid=498
UPDATE HotSearchEditorHd SET RemainsltString='SELECT SLaunchNo,LaunchRefNo,CmpId,CmpName,JcmId,FromJc,ToJc,CmpPrdCtgId, CmpPrdCtgName,PrdCtgValMainId,PrdCtgValName,RetailerCat,LaunchValue,Status,DisplayMode,Display,RetailerCls  FROM(Select Distinct SLaunchNo,LaunchRefNo,B.CmpId,B.CmpName,D.JcmId,A.FromJc,A.ToJc,A.CmpPrdCtgId, CmpPrdCtgName,A.PrdCtgValMainId,PrdCtgValName,RetailerCat,LaunchValue,A.Status,  CASE Display WHEN 1 THEN ''SUMMARY'' ELSE ''DETAILS'' END as DisplayMode,Display,RetailerCls  From LaunchTargetHd A INNER JOIN COMPANY B ON A.CmpId = B.CmpId INNER JOIN JCMonth D ON  D.JcmJc >= A.FromJc And D.JcmJc <= A.ToJc And D.JcmId = A.JcmId INNER JOIN ProductCategoryLevel E ON  E.CmpPrdCtgId  = A.CmpPrdCtgId And A.CmpId = E.CmpId INNER JOIN ProductCategoryValue F  ON F.PrdCtgValMainId = A.PrdCtgValMainId And F.CmpPrdCtgId = E.CmpPrdCtgId )A' where formid=493
GO
DELETE FROM HotSearchEditorHd WHERE FormId=10054
INSERT INTO HotSearchEditorHd SELECT 10054,'Launch Product Target','SalesMan','Select','SELECT RMId, RMCode, RMName FROM RouteMaster WHERE RMSRouteType=1 ORDER BY RMName'
GO
DELETE FROM CustomCaptions WHERE CtrlName='MsgBox-46-1000-1'
INSERT INTO CustomCaptions SELECT 46,1000,1,'MsgBox-46-1000-1','','','No target details to save',1,1,1,'2013-01-21',1,'2013-01-21','','','No target details to save',1,1
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TempLaunchMonthPlan')
DROP TABLE TempLaunchMonthPlan
GO
CREATE TABLE TempLaunchMonthPlan
(
	[SLaunchNo] [int] NOT NULL,
	[LaunchRowId] [int] NOT NULL,
	[PrdId] [int] NOT NULL,
	[LaunchMonthId] [int] NOT NULL,
	[PlanNoOfRet] [int] NOT NULL,
	[ActNoOfRet] [int] NOT NULL,
	[PlanPerRetInVol] [numeric](18, 2) NOT NULL,
	[PlanPerRetInVal] [numeric](36, 2) NOT NULL,  --Newly Added
	[ActualVol] [numeric](18, 2) NOT NULL,
	[ActualVal] [numeric](18, 2) NOT NULL,   
	[PlanNoOfRetSplit] [float] NULL,
	[UsrId] [int] NOT NULL
)
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='LaunchType')
BEGIN
CREATE TABLE LaunchType
(
	SLaunchNo		BIGINt		NOT NULL,
	RtrCls			INT			NOT NULL,
	RtrCtg			INT			NOT NULL,
	Value			INT			NOT NULL
)
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_LaunchProductApportion')
DROP PROCEDURE Proc_LaunchProductApportion
GO
--EXEC Proc_LaunchProductApportion 13
CREATE PROCEDURE Proc_LaunchProductApportion
(
	@Pi_RefNo 		INT
)
/************************************************************
* PRODEDURE	: Proc_LaunchProductApportion
* PURPOSE	: To Apportion the Launch Product details
* CREATED BY	: Thrinath
* CREATED DATE	: 22/01/2008
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*   {date}    {developer}    {brief modification description}
* 2013-03-05  Alpgonse J     Aportion value calculation changed	CCRSTNIV0011 & CCRSTNIV0012
*************************************************************/
AS
BEGIN
	--DECLARE @TempVal TABLE
	--(
	--	TotCnt		INT,
	--	PrdId		INT,
	--	PlanNoOfRet	INT,
	--	ValueClassName	nVarChar(100)
	--)
	
	--DECLARE @TempSubVal TABLE
	--(
	--	SubCnt		INT,
	--	PrdId		INT,
	--	PlanNoOfRet	INT,
	--	ValueClassName	nVarChar(100),
	--	smid		INT,
	--	rmid		INT,
	--	ctgmainid	INT,
	--	rtrclassid	INT,
	--	PlanSplit	FLOAT
	--)

	--INSERT INTO @TempVal (TotCnt,PrdId,PlanNoOfRet,ValueClassName)
	--SELECT SUM(A.NoOfRet) as TotCnt,B.PrdId,PlanNoOfRet,ValueClassName
	--	FROM LaunchTargetDt a INNER JOIN LaunchTargetMonthPlan b
	--	ON A.LaunchRowId = B.LaunchRowId 
	--	INNER JOIN RetailerValueClass c ON A.RtrClassId = c.RtrClassId
	--	WHERE a.slaunchno = @Pi_RefNo AND LaunchMonthId IN (SELECT MAX(LaunchMonthId)
	--		FROM LaunchTargetMonthPlan WHERE slaunchno = @Pi_RefNo) 
	--GROUP BY B.PrdId,PlanNoOfRet,ValueClassName
	
	--INSERT INTO @TempSubVal(SubCnt,PrdId,PlanNoOfRet,ValueClassName,smid,rmid,ctgmainid,
	--	rtrclassid,PlanSplit)
	--SELECT SUM(A.NoOfRet) as SubCnt,B.PrdId,PlanNoOfRet,ValueClassName,smid,rmid,
	--	a.ctgmainid,a.rtrclassid,0 as PlanSplit
	--	FROM LaunchTargetDt a INNER JOIN LaunchTargetMonthPlan b
	--	ON A.LaunchRowId = B.LaunchRowId 
	--	INNER JOIN RetailerValueClass c ON A.RtrClassId = c.RtrClassId
	--	WHERE a.slaunchno = @Pi_RefNo AND LaunchMonthId IN (SELECT MAX(LaunchMonthId)
	--		FROM LaunchTargetMonthPlan WHERE slaunchno = @Pi_RefNo) 
	--GROUP BY B.PrdId,PlanNoOfRet,ValueClassName,smid,rmid,a.ctgmainid,a.rtrclassid

	--UPDATE @TempSubVal SET PlanSplit = (CAST(A.PlanNoOfRet AS FLOAT) / CAST(A.TotCnt AS FLOAT))
	--	* CAST(B.SubCnt AS FLOAT) FROM @TempVal A INNER JOIN @TempSubVal B
	--	ON A.PrdID = B.PrdId AND A.ValueClassName = B.ValueClassName

	--UPDATE LaunchTargetMonthPlan SET PlanNoOfRetSplit = C.PlanSplit FROM
	--	LaunchTargetDt a INNER JOIN LaunchTargetMonthPlan b
	--	ON A.LaunchRowId = B.LaunchRowId AND a.slaunchno = @Pi_RefNo 
	--	INNER JOIN @TempSubVal C ON C.PrdId = B.PrdId AND C.SMId = A.SMId
	--	AND C.RMId = A.RMId AND C.CtgMainId = A.CtgMainId AND
	--	C.RtrClassId = A.RtrClassId

	--SELECT * FROM LaunchTargetMonthPlan WHERE PrdID= 108
	
	--Added By Alphonse J on 2013-03-05
	-----------******************---------------------
	CREATE TABLE #Temp
	(
		ValueClassName			NVARCHAR(50),
		CtgMainId				BIGINT,
		NoOfRet					BIGINT,
		PrdId					BIGINT,
		LaunchMonthId			INT,
		PlanNoOfRetSplit		FLOAT,
		LaunchRowId				INT
	)
	
	INSERT INTO #Temp 
	select A.ValueClassName,A.CtgMainId,A.NoOfRet,b.prdid,b.LaunchMonthId ,B.PlanNoOfRetSplit,b.LaunchRowId from TempLaunchProduct A inner join  TempLaunchMonthPlan B 
	on A.SLaunchNo=B.SLaunchNo and a.LaunchRowId=b.LaunchRowId 
	
	IF EXISTS (SELECT * FROM LaunchType WHERE SLaunchNo=@Pi_RefNo AND RtrCls=1 AND RtrCtg=1)
		BEGIN
			select a.ValueClassName,a.CtgMainId,b.PrdId,sum(distinct b.PlanNoOfRet) PlanNoOfRet,b.LaunchMonthId INTO #Plan from TempLaunchProduct A inner join  TempLaunchMonthPlan B 
			on A.SLaunchNo=B.SLaunchNo and a.LaunchRowId=b.LaunchRowId 	group by a.ValueClassName,b.PrdId,LaunchMonthId,a.CtgMainId
			
			select ValueClassName,CtgMainId,SUM(NoOfRet) TotalNoOfRet INTO #Total from TempLaunchProduct GROUP BY ValueClassName,CtgMainId
			
			UPDATE A SET A.PlanNoOfRetSplit=(CAST(B.PlanNoOfRet AS FLOAT)/CAST(C.TotalNoOfRet AS FLOAT))*CAST(A.NoOfRet AS FLOAT) FROM #Temp A INNER JOIN #Plan B ON A.ValueClassName=B.ValueClassName AND A.CtgMainId=B.CtgMainId AND A.LaunchMonthId=B.LaunchMonthId AND A.PrdId=B.PrdId 
			INNER JOIN #Total C ON A.ValueClassName=C.ValueClassName AND A.CtgMainId=C.CtgMainId 
		END		
	ELSE IF EXISTS (SELECT * FROM LaunchType WHERE SLaunchNo=@Pi_RefNo AND RtrCls=1)
		BEGIN
			select a.ValueClassName,b.PrdId,sum(distinct b.PlanNoOfRet) PlanNoOfRet,b.LaunchMonthId INTO #Plan1 from TempLaunchProduct A inner join  TempLaunchMonthPlan B 
			on A.SLaunchNo=B.SLaunchNo and a.LaunchRowId=b.LaunchRowId 	group by a.ValueClassName,b.PrdId,LaunchMonthId
			
			select ValueClassName,SUM(NoOfRet) TotalNoOfRet INTO #Total1 from TempLaunchProduct GROUP BY ValueClassName
			
			UPDATE A SET A.PlanNoOfRetSplit=(CAST(B.PlanNoOfRet AS FLOAT)/CAST(C.TotalNoOfRet AS FLOAT))*CAST(A.NoOfRet AS FLOAT) FROM #Temp A INNER JOIN #Plan1 B ON A.ValueClassName=B.ValueClassName AND A.LaunchMonthId=B.LaunchMonthId AND A.PrdId=B.PrdId 
			INNER JOIN #Total1 C ON A.ValueClassName=C.ValueClassName
		END
	ELSE IF EXISTS(SELECT * FROM LaunchType WHERE SLaunchNo=@Pi_RefNo AND RtrCls=0 AND RtrCtg=0)
		BEGIN
			select b.PrdId,(b.PlanNoOfRet) PlanNoOfRet,b.LaunchMonthId INTO #Plan2 from TempLaunchProduct A inner join  TempLaunchMonthPlan B 
			on A.SLaunchNo=B.SLaunchNo and a.LaunchRowId=b.LaunchRowId 	group by b.PrdId,LaunchMonthId,b.PlanNoOfRet
			
			select SUM(NoOfRet) TotalNoOfRet INTO #Total2 from TempLaunchProduct 
			
			UPDATE A SET A.PlanNoOfRetSplit=(CAST(B.PlanNoOfRet AS FLOAT)/CAST(C.TotalNoOfRet AS FLOAT))*CAST(A.NoOfRet AS FLOAT) FROM #Temp A INNER JOIN #Plan2 B ON A.LaunchMonthId=B.LaunchMonthId AND A.PrdId=B.PrdId 
			CROSS JOIN #Total2 C 
		END
	ELSE IF EXISTS (SELECT * FROM LaunchType WHERE SLaunchNo=@Pi_RefNo AND RtrCtg=1)
		BEGIN
			select A.CtgMainId,b.PrdId,sum(distinct b.PlanNoOfRet) PlanNoOfRet,b.LaunchMonthId INTO #Plan3 from TempLaunchProduct A inner join  TempLaunchMonthPlan B 
			on A.SLaunchNo=B.SLaunchNo and a.LaunchRowId=b.LaunchRowId 	group by A.CtgMainId,b.PrdId,LaunchMonthId
			
			select CtgMainId,SUM(NoOfRet) TotalNoOfRet INTO #Total3 from TempLaunchProduct GROUP BY CtgMainId
			
			UPDATE A SET A.PlanNoOfRetSplit=(CAST(B.PlanNoOfRet AS FLOAT)/CAST(C.TotalNoOfRet AS FLOAT))*CAST(A.NoOfRet AS FLOAT) FROM #Temp A INNER JOIN #Plan3 B ON A.CtgMainId=B.CtgMainId AND A.LaunchMonthId=B.LaunchMonthId AND A.PrdId=B.PrdId 
			INNER JOIN #Total3 C ON A.CtgMainId=C.CtgMainId
		END
	
	UPDATE A SET A.PlanNoOfRetSplit=B.PlanNoOfRetSplit FROM LaunchTargetMonthPlan A INNER JOIN #Temp B ON B.LaunchRowId=A.LaunchRowId 
	WHERE A.SLaunchNo=@Pi_RefNo
	
	-----------******************---------------------
	--Till here
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_LaunchProduct')
DROP PROCEDURE Proc_LaunchProduct
GO
--  EXEC Proc_LaunchProduct 1,1,1,'704','31',49,1
--  SELECT * FROM TempLaunchProduct
--  SELECT * FROM TempLaunchMonthPlan
CREATE PROCEDURE Proc_LaunchProduct
(
	@Pi_CmpId 		INT,
	@Pi_SJcmJc		INT,
	@Pi_EJcmJc		INT,
	@Pi_PrdId		nVarChar(MAX),
	@Pi_RefNo 		INT,
	@Pi_RptId		INT,
	@Pi_UsrId 		INT
)
/************************************************************
* PRODEDURE	: Proc_LaunchProduct
* PURPOSE	: To get the Launch Product details
* CREATED BY	: Jisha Mathew
* CREATED DATE	: 03/12/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*   {date}     {developer}  {brief modification description}
* 2013-03-06   Alphonse J   JCMID validation addded
*************************************************************/
AS
BEGIN
	DECLARE @sSql as nVarchar(MAX)
	DECLARE @Cnt As Int
	DECLARE @SMId 	AS	INT
	DECLARE @RMId	AS	INT
	DECLARE @MonthId AS	INT
	DECLARe @Status	 As INT
	
	SET @Status=0
	
	DECLARE @TempMonth TABLE
	(		
		JcmJc	Int,
		JcmSdt	Datetime,
		JcmEdt	Datetime
	)	
	DECLARE @TempVal TABLE
	(
		SMId	INT,
		RMId	INT,
		CtgMainId	INT,
		RtrClassId	INT,
		PrdId 		INT,
		JcmJc 		INT,
		ActNoOfRet	INT,
		Volume		Numeric (38,2),
		Value		Numeric (38,2)
	)
	
	--Added by Alphonse J on 2013-03-06
	IF EXISTS ((SELECT JcmId FROM LaunchTargetHd WHERE SLaunchNo=@Pi_RefNo))
		BEGIN
			Insert Into @TempMonth Select JcmJc,JcmSdt,JcmEdt From JCMast JC ,JCMonth JM Where JC.JcmId = JM.JcmId
			And JcmJc Between @Pi_SJcmJc And @Pi_EJcmJc AND 
			JM.JcmId IN (SELECT JcmId FROM LaunchTargetHd WHERE SLaunchNo=@Pi_RefNo) 
		END
	ELSE
		BEGIN
			Insert Into @TempMonth Select JcmJc,JcmSdt,JcmEdt From JCMast JC ,JCMonth JM Where JC.JcmId = JM.JcmId
			And JcmJc Between @Pi_SJcmJc And @Pi_EJcmJc  
		END
	
	SELECT @Status= Status  from LaunchTargetHd WHERE SLaunchNo=@Pi_RefNo
	--Till here	
		
	CREATE Table #TempPrdId
	(
		PrdId Int
	)
	--Modified by Alphonse J on 2013-03-01
	--Set @sSql = 'Insert Into #TempPrdId Select PrdCtgValMainId from Product Where PrdCtgValMainId IN (' + Cast(@Pi_PrdId as nVarchar(MAX)) + ')'
	Set @sSql = 'Insert Into #TempPrdId SELECT DISTINCT B.PrdCtgValMainId AS PrdId FROM ProductCategoryValue A INNER JOIN ProductCategoryValue B ON B.PrdCtgValLinkCode LIKE CAST(A.PrdCtgValLinkCode AS NVARCHAR(1000)) + ''%'' WHERE A.PrdCtgValMainId IN(' + Cast(@Pi_PrdId as nVarchar(MAX)) + ')'
	exec (@ssql)
	
	--Added By Alphonse J on 2013-03-07
	CREATE Table #TempCtgIdMap
	(
		Parent	INT,
		Child	INT
	)
	Set @sSql = 'INSERT INTO #TempCtgIdMap SELECT DISTINCT A.PrdCtgValMainId,B.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryValue B ON B.PrdCtgValLinkCode LIKE CAST(A.PrdCtgValLinkCode AS NVARCHAR(1000)) + ''%'' WHERE  A.PrdCtgValMainId<>B.PrdCtgValMainId AND A.PrdCtgValMainId IN('+ Cast(@Pi_PrdId as nVarchar(MAX)) + ')'
	exec (@ssql)
	--Till here 
	
	CREATE Table #TempCtgId
	(
		CtgId Int
	)
	Set @sSql = 'Insert Into #TempCtgId SELECT DISTINCT PrdCtgValMainId AS CtgId FROM ProductCategoryValue WHERE PrdCtgValMainId IN (' + Cast(@Pi_PrdId as nVarchar(MAX)) + ')'
	exec (@ssql)
	
	Truncate Table TempLaunchProduct
	Delete From TempLaunchMonthPlan Where UsrId = @Pi_UsrId
	IF exists (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
		SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	else
		SET @SMId = 0
	IF Exists (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
		SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	Else
		SET @RMId = 0
		
	IF @Pi_RefNo = 0
	BEGIN
		SET IDENTITY_INSERT TempLaunchProduct OFF
		INSERT INTO TempLaunchProduct(SLaunchNo,SMId,SMName,RMId,RMName,CtgMainId,CtgName,RtrClassId,ValueClassName,NoOfRet,UsrId)
		Select DISTINCT 0 AS SLaunchNo,S.SMId,S.SMName,R.RMId,R.RMName,RC.CtgMainId,CtgName,
		RtrClassId,ValueClassName,Count(DISTINCT RVCM.RtrId) AS NoOfRet,@Pi_UsrId AS UsrId
		From SalesMan S
		INNER JOIN SalesmanMarket SM ON S.SMId = SM.SMId
		INNER JOIN RouteMaster R ON SM.RMId = R.RMId
		INNER JOIN RetailerMarket RM ON RM.RMId = R.RMId AND RM.RMId = SM.RMId
		INNER JOIN Retailer Ret ON Ret.RtrId = RM.RtrId
		INNER JOIN RetailerValueClassMap RVCM ON Ret.RtrId = RVCM.RtrId AND RM.RtrId = RVCM.RtrId
		INNER JOIN RetailerValueClass RVC ON RVC.RtrClassId = RVCM.RtrValueClassId
		INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
		Where (RVC.CmpId = (Case @Pi_CmpId When 0 Then RVC.CmpId Else @Pi_CmpId END) OR RVC.CmpId = 0)
		AND (R.RMId=(CASE @RMId WHEN 0 THEN R.RMId ELSE 0 END) OR
				R.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))								
		AND (S.SMId=(CASE @SMId WHEN 0 THEN S.SMId ELSE 0 END) OR
				S.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))		
		Group BY S.SMId,S.SMName,R.RMId,R.RMName,RC.CtgMainId,CtgName,RtrClassId,ValueClassName
		INSERT INTO TempLaunchMonthPlan(SLaunchNo,LaunchRowId,PrdId,LaunchMonthId,PlanNoOfRet,
			ActNoOfRet,PlanPerRetInVol,PlanPerRetInVal,ActualVol,ActualVal,UsrId,PlanNoOfRetSplit)
		Select DISTINCT 0 AS SLaunchNo,L.LaunchRowId,P.PrdCtgValMainId,TM.JcmJc AS LaunchMonthId,
			0 AS PlanNoOfRet,0 AS ActNoOfRet,0 AS PlanPerRetInVol,0 AS PlanPerRetInVal,0 AS ActualVol,
			0 AS ActualVal,@Pi_UsrId AS UsrId,0 as PlanNoOfRetSplit
		From TempLaunchProduct L
		CROSS JOIN #TempCtgId TP
		INNER JOIN ProductCategoryValue P ON TP.CtgId = P.PrdCtgValMainId 
		CROSS JOIN @TempMonth TM	
	
	END
	ELSE IF @Pi_RefNo <> 0 
		BEGIN
			SET IDENTITY_INSERT TempLaunchProduct ON
			INSERT INTO TempLaunchProduct(SLaunchNo,LaunchRowId,SMId,SMName,RMId,RMName,CtgMainId,CtgName,RtrClassId,ValueClassName,NoOfRet,UsrId)
			Select LT.SLaunchNo AS SLaunchNo,LD.LaunchRowId,S.SMId,S.SMName,R.RMId,R.RMName,RC.CtgMainId,CtgName,
			RVC.RtrClassId,ValueClassName,LD.NoOfRet AS NoOfRet,@Pi_UsrId AS UsrId
			From LaunchTargetHd LT
			INNER JOIN LaunchTargetDt LD ON LT.SLaunchNo = LD.SLaunchNo
			INNER JOIN Salesman S ON S.SMId = LD.SMId
			INNER JOIN RouteMaster R ON LD.RMId = R.RMId
			INNER JOIN RetailerValueClass RVC ON RVC.RtrClassId = LD.RtrClassId
			INNER JOIN RetailerCategory RC ON RC.CtgMainId = LD.CtgMainId AND RC.CtgMainId = RVC.CtgMainId
			Where (LT.CmpId = (Case @Pi_CmpId When 0 Then LT.CmpId Else @Pi_CmpId END) OR LT.CmpId = 0)
			AND (R.RMId=(CASE @RMId WHEN 0 THEN R.RMId ELSE 0 END) OR
					R.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))								
			AND (S.SMId=(CASE @SMId WHEN 0 THEN S.SMId ELSE 0 END) OR
					S.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))	
			AND LT.SLaunchNo = @Pi_RefNo
			Group BY S.SMId,S.SMName,R.RMId,R.RMName,RC.CtgMainId,CtgName,RVC.RtrClassId,ValueClassName,
			LT.SLaunchNo,LD.NoOfRet,LD.LaunchRowId			
			INSERT INTO TempLaunchMonthPlan(SLaunchNo,LaunchRowId,PrdId,LaunchMonthId,PlanNoOfRet,
				ActNoOfRet,PlanPerRetInVol,PlanPerRetInVal,ActualVol,ActualVal,UsrId,PlanNoOfRetSplit)
			Select LT.SLaunchNo,LD.LaunchRowId,LM.PrdId,LM.LaunchMonthId,ISNULL(SUM(LM.PlanNoOfRet),0),
				ISNULL(SUM(LM.ActNoOfRet),0),ISNULL(SUM(LM.PlanPerRetInVol),0),ISNULL(SUM(LM.PlanPerRetInVal),0),
				LM.ActualVol,LM.ActualVal,@Pi_UsrId AS UsrId,PlanNoOfRetSplit
			From LaunchTargetHd LT
			INNER JOIN LaunchTargetDt LD ON LT.SLaunchNo = LD.SLaunchNo
			INNER JOIN LaunchTargetMonthPlan LM ON  LT.SLaunchNo = LM.SLaunchNo AND LM.SLaunchNo = LD.SLaunchNo
				AND LD.LaunchRowId = LM.LaunchRowId
			WHERE LT.SLaunchNo = @Pi_RefNo
			GROUP BY LT.SLaunchNo,LD.LaunchRowId,LM.PrdId,LM.LaunchMonthId,
				LM.ActualVol,LM.ActualVal,PlanNoOfRetSplit
			
		END
 	IF @Pi_RefNo <> 0 AND @Status=0
 	BEGIN

		Insert Into @TempVal(SMId,RMId,CtgMainId,RtrClassId,PrdId,JcmJc,ActNoOfRet,Volume,Value)
		SELECT SMId,RMId,CtgMainId,RtrClassId,PrdId,JcmJc,SUM(ActNoOfRet) ActNoOfRet,SUM(Volume) Volume,SUM(Value) Value FROM 
		(Select SI.SMId,SI.RMId,RVC.CtgMainId AS CtgMainId,RVC.RtrClassId AS RtrClassId,P.PrdCtgValMainId PrdId,TM.JcmJc,
		COUNT(Distinct SI.RtrId) AS ActNoOfRet,SUM(SIP.BaseQty) AS Volume,SUM(SIP.PrdGrossAmount) AS Value
		From SalesInvoice SI
		INNER JOIN SalesInvoiceProduct SIP ON SI.SalId = SIP.SalId
		--INNER JOIN Retailer R ON R.RtrId = SI.RtrId
		INNER JOIN RetailerValueClassMap RVCM ON  SI.RtrId = RVCM.RtrId -- AND R.RtrId = RVCM.RtrId
		INNER JOIN RetailerValueClass RVC ON RVC.RtrClassId = RVCM.RtrValueClassId
		INNER JOIN Product P ON SIP.PrdID = P.PrdID AND RVC.CmpId = P.CmpId --AND P.CmpId = @Pi_CmpId
		INNER JOIN #TempPrdId TP ON TP.PrdId = P.PrdCtgValMainId 
		INNER JOIN @TempMonth TM  ON SI.SalInvDate Between TM.JcmSdt AND TM.JcmEdt
		Where  SI.DlvSts In (4,5)
		AND (RVC.CmpId = (Case @Pi_CmpId When 0 Then RVC.CmpId Else @Pi_CmpId END) OR RVC.CmpId = 0)
		AND (SI.RMId=(CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
				SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))								
		AND (SI.SMId=(CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
				SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))	
		Group BY SI.SMId,SI.RMId,RVC.CtgMainId,RVC.RtrClassId,P.PrdCtgValMainId,TM.JcmJc
		UNION ALL
		SELECT  RH.SMId,RH.RMId,RVC1.CtgMainId,RVC1.RtrClassId,P1.PrdCtgValMainId PrdId,TM1.JcmJc, 
		        COUNT(Z.ReturnID)*-1 ActNoOfRet,SUM(RP.BaseQty)*-1 Volume,SUM(RP.PrdGrossAmt)*-1 Value
		FROM	   ReturnHeader					RH
		INNER JOIN ReturnProduct				RP		ON RH.ReturnID=RP.ReturnID 
		INNER JOIN RetailerValueClassMap		RVCM1	ON RH.RtrId=RVCM1.RtrId 
		INNER JOIN RetailerValueClass			RVC1	ON RVC1.RtrClassId=RVCM1.RtrValueClassId 
		INNER JOIN Product						P1		ON P1.PrdId=RP.PrdId AND RVC1.CmpId=P1.CmpId  
		INNER JOIN #TempPrdId					TP1		ON TP1.PrdID=P1.PrdCtgValMainId 
		INNER JOIN @TempMonth					TM1		ON RH.ReturnDate BETWEEN TM1.JcmSdt AND TM1.JcmEdt
		LEFT OUTER JOIN (SELECT A.ReturnID  from ReturnHeader A INNER JOIN SalesInvoice B on A.SalId=B.SalId INNER JOIN SalesInvoiceProduct C 
						ON B.SalId=C.SalId INNER JOIN ReturnProduct R ON A.ReturnID=R.ReturnID GROUP BY A.ReturnID HAVING SUM(c.BaseQty)=SUM(r.BaseQty))Z ON Z.ReturnID=RH.ReturnID 
		WHERE RH.Status=0
		AND (RVC1.CmpId = (Case @Pi_CmpId When 0 Then RVC1.CmpId Else @Pi_CmpId END) OR RVC1.CmpId = 0)
		AND (RH.RMId=(CASE @RMId WHEN 0 THEN RH.RMId ELSE 0 END) OR
				RH.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))								
		AND (RH.SMId=(CASE @SMId WHEN 0 THEN RH.SMId ELSE 0 END) OR
				RH.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		GROUP BY RH.SMId,RH.RMId,RVC1.CtgMainId,RVC1.RtrClassId,P1.PrdCtgValMainId,TM1.JcmJc) X GROUP BY SMId,RMId,CtgMainId,RtrClassId,PrdId,JcmJc
		
		--Select SI.SMId,SI.RMId,RVC.CtgMainId AS CtgMainId,RVC.RtrClassId AS RtrClassId,SIP.PrdId,TM.JcmJc,
		--COUNT(Distinct SI.RtrId) AS ActNoOfRet,SUM(SIP.BaseQty) AS Volume,SUM(SIP.PrdGrossAmount) AS Value
		--From SalesInvoice SI
		--INNER JOIN SalesInvoiceProduct SIP ON SI.SalId = SIP.SalId
		----INNER JOIN Retailer R ON R.RtrId = SI.RtrId
		--INNER JOIN RetailerValueClassMap RVCM ON  SI.RtrId = RVCM.RtrId -- AND R.RtrId = RVCM.RtrId
		--INNER JOIN RetailerValueClass RVC ON RVC.RtrClassId = RVCM.RtrValueClassId
		--INNER JOIN #TempPrdId TP ON TP.PrdId = SIP.PrdId
		--INNER JOIN Product P ON SIP.PrdID = P.PrdID AND RVC.CmpId = P.CmpId --AND P.CmpId = @Pi_CmpId
		--INNER JOIN @TempMonth TM  ON SI.SalInvDate Between TM.JcmSdt AND TM.JcmEdt
		--Where  SI.DlvSts In (4,5)
		--AND (RVC.CmpId = (Case @Pi_CmpId When 0 Then RVC.CmpId Else @Pi_CmpId END) OR RVC.CmpId = 0)
		--AND (SI.RMId=(CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
		--		SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))								
		--AND (SI.SMId=(CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
		--		SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))	
		--Group BY SI.SMId,SI.RMId,RVC.CtgMainId,RVC.RtrClassId,SIP.PrdId,TM.JcmJc
	--Select * From @TempVal
	
		UPDATE B SET B.PrdId=A.Parent FROM #TempCtgIdMap A INNER JOIN @TempVal B ON A.Child=B.PrdId

		UPDATE TempLaunchMonthPlan Set ActNoOfRet = A.ActNoOfRet,
						ActualVol = A.Volume,
						ActualVal = A.Value
		From @TempVal A,TempLaunchMonthPlan B,TempLaunchProduct C
		Where A.SMId = C.SMId And A.RMId = C.RMId And A.CtgMainId = C.CtgMainId And A.RtrClassId = C.RtrClassId
		And A.PrdId = B.PrdId And A.JcmJc = B.LaunchMonthId And B.SLaunchNo = C.SLaunchNo And B.LaunchRowId = C.LaunchRowId AND B.UsrId=@Pi_UsrId 
		
		--Added By Alphonse J on 2013-02-28 CCRSTNIV0012
		--UPDATE A SET A.PrdId=B.PrdCtgValMainId FROM TempLaunchMonthPlan A INNER JOIN Product B ON A.PrdId=B.PrdId WHERE A.UsrId=@Pi_UsrId 
		
		--Till here
	--select * from TempLaunchMonthPlan
 	END
END
GO
UPDATE CustomCaptions SET Caption='Launch Product Target' where transid=58 and CtrlId=1 and SubCtrlId=1
GO
--aravindh
DELETE FROM CUSTOMCAPTIONS where CTRLNAME in ('PnlMsg-46-1000-45','PnlMsg-46-1000-46')
INSERT INTO CUSTOMCAPTIONS
SELECT 46,100038,45,'PnlMsg-46-1000-45','','Calculating Please Wait.....','',1,1,1,'2013-01-18',1,'2013-01-18','','Calculating Please Wait.....','',1,1
UNION
SELECT 46,100039,46,'PnlMsg-46-1000-46','','Please Wait.....','',1,1,1,'2013-01-18',1,'2013-01-18','','Please Wait.....','',1,1
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_TargetTotalNew')
DROP PROCEDURE Proc_TargetTotalNew
GO
CREATE PROC Proc_TargetTotalNew
AS
/*********************************
* PROCEDURE	: Proc_TargetTotalNew
* PURPOSE	: To create total rows on Target details
* CREATED	: Nandakumar R.G
* CREATED DATE	: 10/04/2008
* NOTE		: SP to create total rows for Target Analysis 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}      {developer}  {brief modification description}
*********************************/
BEGIN
	CREATE TABLE #TargetDetails
	(
		[PrdCtgValMainId]int,
		[prdctgvalname]nvarchar(150),
		[PrdUnitId]int,
		[prdunitname]nvarchar(100),
		[SmId]int,
		[smname]nvarchar(150),
		[RMId]int,
		[Rmname]nvarchar(150),
		[RtrId]int,
		[Rtrname]nvarchar(150),
		[SalId] int,
		[PrdId]int,
		[Prdname]nvarchar(250),
		[SugVolume]numeric(38, 6),
		[sugValue]numeric(38, 6),
		[SugTonnage]numeric(38, 6),
		[UsrId]int,
		[RtrDayOff]tinyint,
		[TotRow] int
	)

	INSERT INTO #TargetDetails
	SELECT * FROM TargetDetails

	INSERT INTO TargetDetails
	SELECT PrdCtgValMainId,PrdCtgValName,PrdUnitId,PrdUnitName,0,'',0,'',0,'',0,0,'',SUM(SugVolume) AS SugVolume,SUM(SugValue) AS SugValue,
	SUM(SugTonnage) AS SugTonnage,MAX(UsrId),MAX(RtrDayOff),5
	FROM #TargetDetails GROUP BY PrdCtgValMainId,PrdCtgValName,PrdUnitId,PrdUnitName
	
	INSERT INTO TargetDetails
	SELECT PrdCtgValMainId,PrdCtgValName,PrdUnitId,PrdUnitName,SMId,'Total-'+SMName,100000,'',0,'',0,0,'',SUM(SugVolume) AS SugVolume,SUM(SugValue) AS SugValue,
	SUM(SugTonnage) AS SugTonnage,MAX(UsrId),MAX(RtrDayOff),4
	FROM #TargetDetails GROUP BY PrdCtgValMainId,PrdCtgValName,PrdUnitId,PrdUnitName,SMId,SMName
	
	INSERT INTO TargetDetails
	SELECT PrdCtgValMainId,PrdCtgValName,PrdUnitId,PrdUnitName,SMId,SMName,RMId,'Total-'+RMName,100000,'',0,0,'',SUM(SugVolume) AS SugVolume,SUM(SugValue) AS SugValue,
	SUM(SugTonnage) AS SugTonnage,MAX(UsrId),MAX(RtrDayOff),3
	FROM #TargetDetails GROUP BY PrdCtgValMainId,PrdCtgValName,PrdUnitId,PrdUnitName,SMId,SMName,RMId,RMName
	
	INSERT INTO TargetDetails
	SELECT PrdCtgValMainId,PrdCtgValName,PrdUnitId,PrdUnitName,SMId,SMName,RMId,RMName,RtrId,'Total-'+RtrName,0,100000,'',SUM(SugVolume) AS SugVolume,SUM(SugValue) AS SugValue,
	SUM(SugTonnage) AS SugTonnage,MAX(UsrId),MAX(RtrDayOff),2
	FROM #TargetDetails GROUP BY PrdCtgValMainId,PrdCtgValName,PrdUnitId,PrdUnitName,SMId,SMName,RMId,RMName,RtrId,RtrName
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME ='Proc_TargetAnalysis' AND XTYPE='P')
DROP PROCEDURE Proc_TargetAnalysis
GO
--Exec Proc_TargetAnalysis 1,4,2,'2013-02-01','2013-02-28','2013-02-03',2,0,1
CREATE PROCEDURE Proc_TargetAnalysis
(
	@PCmpId INT, 
	@PJcmId INT,
	@PJcmJc INT,
	@PJcSdt DATETIME,
	@PJcEdt DATETIME,
	@PToday DATETIME,
	@PCmpPrdCtgId INT,
	@PPrdCtgValMainId INT,
	@PUsrId AS INT
)
/************************************************
* PROCEDURE	: Proc_TargetAnalysis
* PURPOSE	: To Calculate Target
* CREATED	: R.S. Anuradha
* CREATED DATE	: 21/05/2007
* NOTE		: SP for Target Analysis
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}      {developer}		{brief modification description}
* 12/12/2007  Nanda				Retailer Day Off Integration
* 27/02/2008  Nanda				Performance tuning 	
* 23/01/2013  Aravindh Deva C	Sales Return Considered for Suggested Plan
**************************************************/
AS		
SET NOCOUNT ON
BEGIN
	DECLARE @FromDt AS DATETIME
	DECLARE @ToDt AS DATETIME
	DECLARE @NormId AS INT
	DECLARE @DefDays AS INT
	DECLARE @DefPeriod AS NVARCHAR(100)
	
	--IF @PPrdCtgValMainId = 0
	--SET @PPrdCtgValMainId = NULL
	
	CREATE TABLE #SaleProduct
	(
	SalId INT,
	SMId INT,
	RMId INT,
	RtrId INT,
	PrdId INT,
	SalQty NUMERIC(18,0),
	PrdGrossAmount  NUMERIC(18,6)
	)
	CREATE TABLE #ReturnProduct
	(
	SalId INT,
	SMId INT,
	RMId INT,
	RtrId INT,
	PrdId INT,
	RtnQty NUMERIC(18,0),
	ReturnGross  NUMERIC(18,6)
	)
	
	DECLARE @TgtProduct TABLE
	(
	    PrdCtgValMainId INT,
	    Prdid INT,
	    PrdUnitId INT,
	    PrdWgt NUMERIC (38,4),
		PrdName NVARCHAR(200),
		PrdUnitName NVARCHAR(200)
	)
	
	DECLARE @EmptyTarget TABLE
	(
	    PrdCtgValMainId INT,
		PrdCtgValName NVARCHAR(200), 
	    PrdUnitId INT,
		PrdUnitName	NVARCHAR(200),
	    SMId INT,
		SMName	NVARCHAR(200),
	    RMId INT,
		RMName	NVARCHAR(200),
	    RtrId INT,
		RtrName	NVARCHAR(200),
	    PrdId INT,
		PrdName	NVARCHAR(200),
	    NormId INT,
	    SugVolume NUMERIC (38,6),
	    SugValue NUMERIC (38,6),
	    SugTonnage NUMERIC (38,6),
		PrdWgt NUMERIC (38,4),
	    UsrId INT
	)
	EXEC Proc_GR_Build_PH
	TRUNCATE TABLE TargetDet --WHERE UsrId = @PUsrId
	TRUNCATE TABLE TargetDetails --WHERE UsrId = @PUsrId
	IF @PPrdCtgValMainId=0
	BEGIN
		INSERT INTO @TgtProduct (PrdCtgValMainId,Prdid,PrdUnitId,PrdWgt,PrdName,PrdUnitName)
		--SELECT DISTINCT c.PrdCtgValMainId,E.Prdid,pu.prdunitid,e.prdwgt,E.PrdName,PU.PrdUnitName  FROM
		--ProductCategoryValue C  INNER JOIN ProductCategoryValue D ON
		--D.PrdCtgValLinkCode LIKE CAST(c.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		--AND c.cmpprdctgid = @PCmpPrdCtgId
		--INNER JOIN Product E ON D.PrdCtgValMainId = E.PrdCtgValMainId	
		--INNER JOIN productunit pu ON e.prdunitid = pu.prdunitid	
		--WHERE e.cmpid = @PCmpId AND E.PrdStatus=1
		SELECT DISTINCT D.PrdCtgValMainId,A.PrdId,B.PrdUnitId,PrdWgt,PrdName,PrdUnitName FROM
		TBL_GR_BUILD_PH A WITH (NOLOCK) 
		INNER JOIN PRODUCT B WITH (NOLOCK) ON A.PrdId = B.PrdId 
		INNER JOIN ProductUnit C WITH (NOLOCK) ON B.PrdUnitId = C.PrdUnitId 
		INNER JOIN ProductCategoryValue D WITH (NOLOCK) ON A.Category_Code = D.PrdCtgValCode		
		WHERE B.CmpId = @PCmpId AND B.PrdStatus = 1
	END
	--ELSE
	--BEGIN
	--	INSERT INTO @TgtProduct (PrdCtgValMainId,Prdid,PrdUnitId,PrdWgt,PrdName,PrdUnitName)
	--	SELECT DISTINCT c.PrdCtgValMainId,E.Prdid,pu.prdunitid,e.prdwgt,E.PrdName,PU.PrdUnitName  FROM
	--	ProductCategoryValue C  INNER JOIN ProductCategoryValue D ON
	--	D.PrdCtgValLinkCode LIKE CAST(c.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
	--	AND c.cmpprdctgid = @PCmpPrdCtgId
	--	INNER JOIN Product E ON D.PrdCtgValMainId = E.PrdCtgValMainId	
	--	INNER JOIN productunit pu ON e.prdunitid = pu.prdunitid	
	--	WHERE c.prdctgvallinkcode in (SELECT PrdCtgValLinkCode  FROM ProductCategoryValue
	--	WHERE PrdCtgValMainId = ISNULL(@PPrdCtgValMainId,PrdCtgValMainId))
	--	AND e.cmpid = @PCmpId AND E.PrdStatus=1
	--END 
	DECLARE Norms_cursor CURSOR
	--FOR  (SELECT NormId FROM Norms WHERE Normsfor = 'Target')
	FOR (SELECT DISTINCT TD.NormId FROM TargetNormMappingDt TD INNER JOIN TargetNormMappingHd TH ON TD.TargetNormId=TH.TargetNormId
	WHERE TH.CmpId=@PCmpId)
	OPEN Norms_cursor
	
	FETCH NEXT FROM Norms_cursor INTO @NormId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @NormId =22
		BEGIN
			SET @FromDt = (SELECT jcmsdt FROM jcmonth WHERE jcmid IN
			(SELECT jcmid FROM jcmast WHERE jcmyr  IN
			(SELECT jcmyr-1 FROM jcmast WHERE jcmid = @PJcmId AND CmpId = @PcmpId)
			AND CmpId = @PcmpId) AND jcmjc =@PJcmJc)
			SET @ToDt = (SELECT jcmEdt FROM jcmonth WHERE jcmid IN
			(SELECT jcmid FROM jcmast WHERE jcmyr  IN (SELECT jcmyr-1 FROM jcmast WHERE
			jcmid = @PJcmId AND CmpId = @PcmpId) AND CmpId = @PcmpId ) AND jcmjc =@PJcmJc)
		END
		IF @NormId = 23
		BEGIN
		
			SET @FromDt = (SELECT TOP 1 b.jcmsdt FROM
			(SELECT TOP 1 a.jcmsdt FROM       	
			(SELECT jcmSdt FROM JcMonth WHERE
			jcmid IN (SELECT jcmid FROM jcmast WHERE cmpid = @PCmpId ))
			a WHERE a.jcmsdt   < @PJcSdt   ORDER BY  a.jcmsdt DESC)
			b ORDER BY b.jcmsdt ASC )                                     	
	
			SET @ToDt =(SELECT TOP 1 a.jcmEdt FROM       	
			(SELECT jcmEdt FROM JcMonth WHERE
			jcmid IN (SELECT jcmid FROM jcmast WHERE cmpid = @PCmpId ))
			a WHERE a.jcmEdt   < @PJcEdt   ORDER BY  a.jcmEdt DESC)
		
		END
		IF @NormId = 24
		BEGIN
			SET @FromDt = (SELECT TOP 1 b.jcmsdt FROM
			(SELECT TOP 3 a.jcmsdt FROM       	
			(SELECT jcmSdt FROM JcMonth WHERE
			jcmid IN (SELECT jcmid FROM jcmast WHERE cmpid = @PCmpId ))
			a WHERE a.jcmsdt   < @PJcSdt   ORDER BY  a.jcmsdt DESC)
			b ORDER BY b.jcmsdt ASC )
	
			SET @ToDt = (SELECT TOP 1 a.jcmEdt FROM       	
			(SELECT jcmEdt FROM JcMonth WHERE
			jcmid IN (SELECT jcmid FROM jcmast WHERE cmpid = @PCmpId ))
			a WHERE a.jcmEdt   < @PJcEdt   ORDER BY  a.jcmEdt DESC)
			
		END
		IF @NormId = 25
		BEGIN		
			SET  @DefPeriod = (SELECT LTRIM(RTRIM(Condition)) FROM configuration WHERE
			Moduleid = 'TARGETANALYSIS7' AND ModuleName = 'Target Analysis')			
			SET @FromDt = CONVERT(DATETIME,CONVERT(VARCHAR(10),SUBSTRING(@DefPeriod,1,10), 121),103)
			SET @ToDt =   CONVERT(DATETIME,CONVERT(VARCHAR(10),SUBSTRING(@DefPeriod,12,10), 121),103)	
		END
		IF @NormId = 26
		BEGIN
			SET @DefDays = (SELECT -1 * ConfigValue AS ConfigValue FROM configuration
			WHERE Moduleid = 'TARGETANALYSIS8' AND ModuleName = 'Target Analysis')
			SET @FromDt = CAST(DATEADD(d,@DefDays,@PToday) AS DATETIME)
			SET @ToDt = CAST(DATEADD(d,-1,@PToday) AS DATETIME)
		
		END		
		DELETE FROM #SaleProduct
		DELETE FROM #ReturnProduct
		
---Sales Product & Free Product Details	
		INSERT INTO #SaleProduct
        SELECT SalId,SMId,RMId,RtrId,PrdId,SUM(SalQty)[SalQty],SUM(PrdGrossAmount)[PrdGrossAmount]  FROM (
		SELECT S.SalId,S.SMId,S.RMId,S.RtrId,SP.PrdId,ISNULL(SUM(SP.BaseQty),0) AS SalQty,
		ISNULL(SUM(SP.PrdGrossAmount),0) AS [PrdGrossAmount] 
		FROM SalesInvoice S WITH (NOLOCK)
		INNER JOIN SalesInvoiceProduct SP WITH (NOLOCK) ON S.SalId=SP.SalId
		WHERE S.SalInvDate BETWEEN  @FromDt AND @toDt
		AND S.DlvSts IN (4,5)		
		GROUP BY S.SalId,S.SMId,S.RMId,S.RtrId,SP.PrdId
		UNION ALL		
		SELECT S.SalId,S.SMId,S.RMId,S.RtrId,SFP.FreePrdId AS [PrdId],ISNULL(SUM(SFP.FreeQty),0) AS SalQty,0 AS PrdGrossAmount
		FROM SalesInvoice S WITH (NOLOCK)
		INNER JOIN SalesInvoiceSchemeDtFreePrd SFP WITH (NOLOCK) ON S.SalId=SFP.SalId
		WHERE S.SalInvDate BETWEEN @FromDt AND @toDt
		AND S.DlvSts IN (4,5)		
		GROUP BY S.SalId,S.SMId,S.RMId,S.RtrId,SFP.FreePrdId)A GROUP BY SalId,SMId,RMId,RtrId,PrdId
--Till Here
		
--Return Product & Return Free Product Details		
		INSERT INTO #ReturnProduct
		SELECT SalId,SMId,RMId,RtrId,PrdId,SUM(RtnQty)[RtnQty],SUM(ReturnGross)[ReturnGross] FROM (
		SELECT RH.SalId,RH.SMId,RH.RMId,RH.RtrId,RHP.PrdId,-1* ISNULL(SUM(RHP.BaseQty),0) RtnQty,
		-1* ISNULL(SUM(RHP.PrdGrossAmt),0)[ReturnGross] 
		FROM ReturnHeader RH WITH (NOLOCK)
		INNER JOIN ReturnProduct RHP WITH (NOLOCK)ON RH.ReturnID=RHP.ReturnID
		WHERE RH.ReturnDate BETWEEN  @FromDt AND @toDt AND RH.[Status] = 0
		GROUP BY RH.SalId,RH.SMId,RH.RMId,RH.RtrId,RHP.PrdId		
		UNION ALL
		SELECT R.SalId,R.SMId,R.RMId,R.RtrId,RFP.FreePrdId AS PrdId,-1* ISNULL(SUM(RFP.ReturnFreeQty),0)RtnQty,0 AS ReturnGross
		FROM ReturnHeader R WITH (NOLOCK)
		INNER JOIN ReturnSchemeFreePrdDt RFP WITH (NOLOCK)ON R.ReturnID=RFP.ReturnID
		WHERE R.ReturnDate BETWEEN @FromDt AND @toDt AND R.[Status] = 0
		GROUP BY R.SalId,R.SMId,R.RMId,R.RtrId,RFP.FreePrdId) B GROUP BY SalId,SMId,RMId,RtrId,PrdId
--Till Here
		INSERT INTO TargetDetails(PrdCtgValMainId,PrdCtgValName,prdunitid,Prdunitname,
		smid,smname,rmid,rmname,rtrid,rtrname,SalId,
		prdid,prdname, sugVolume,sugValue,sugTonnage,RtrDayOff,UsrId,TotRow)
		SELECT DISTINCT PrdCtgValMainId,PrdCtgValName,PrdUnitId,PrdUnitName,
				SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,PrdId,PrdName,
		CASE Variationtypeid
		WHEN 0 THEN ROUND(Volume,0)
		WHEN 1 THEN ROUND(Volume + volume * VariationPerc/100,0)
		WHEN  2 THEN ROUND(Volume - volume * VariationPerc/100,0)
		END AS Sugvolume,
		
		CASE Variationtypeid
		WHEN 0 THEN ROUND(Value,2)
		WHEN 1 THEN ROUND(Value + value * VariationPerc/100,2)
		WHEN 2 THEN ROUND(Value - value * VariationPerc/100,2)
		END AS Sugvalue,
		
		CASE Variationtypeid
		WHEN 0 THEN ROUND(Tonnage,2)
		WHEN 1 THEN ROUND(Tonnage + Tonnage * VariationPerc/100,2)
		WHEN 2 THEN ROUND(Tonnage - Tonnage * VariationPerc/100,2)
		END AS SugTonnage,0,@PUsrId AS UsrId,0
		FROM
		(			
			SELECT DISTINCT TP.PrdCtgValMainId,PC.PrdCtgValName,TP.PrdUnitId,TP.PrdUnitName,S.SMId,S.SMName,RM.RMId,RM.RMName,R.RtrId,R.RtrName,sip.SalId,
			TD.PrdId,TP.PrdName,0 AS RtrDayOff,
			TD.NormId,TD.VariationTypeId,TD.VariationPerc,
		    CAST((ISNULL(SUM(SalQty),0)+ISNULL(SUM(RtnQty),0)) AS NUMERIC(36,8)) AS Volume,
			(ISNULL(SUM(PrdGrossAmount),0)+ ISNULL(SUM(ReturnGross),0)) AS Value,
			CASE tp.PrdUnitId
			WHEN 1 THEN ((ISNULL(SUM(SalQty),0)+ ISNULL(SUM(RtnQty),0))* PrdWgt)
			WHEN 2 THEN ((ISNULL(SUM(SalQty),0)+ ISNULL(SUM(RtnQty),0)) * PrdWgt/1000)
			WHEN 3 THEN ((ISNULL(SUM(SalQty),0)+ ISNULL(SUM(RtnQty),0))* PrdWgt)
			WHEN 4 THEN ((ISNULL(SUM(SalQty),0)+ ISNULL(SUM(RtnQty),0)) * PrdWgt/1000)
			WHEN 5 THEN ((ISNULL(SUM(SalQty),0)+ ISNULL(SUM(RtnQty),0))* PrdWgt) END AS Tonnage			
			FROM #SaleProduct SIP WITH (NOLOCK)
			INNER JOIN @TgtProduct TP ON  SIP.PrdId = TP.PrdId
			INNER JOIN TargetnormmappingDt TD  WITH (NOLOCK) ON TP.PrdId = TD.PrdId
			INNER JOIN TargetnormmappingHd TH WITH (NOLOCK) ON TH.TargetNormId = TD.TargetNormId	
			INNER JOIN Salesman S ON SIP.SMId = S.SMId			
			INNER JOIN Routemaster RM ON RM.RMId = SIP.RMId
			INNER JOIN Retailer R ON SIP.RtrId = R.RtrId
			INNER JOIN ProductCategoryValue PC WITH (NOLOCK)ON PC.PrdCtgValMainId=TP.PrdCtgValMainId
			LEFT OUTER JOIN #ReturnProduct RP WITH (NOLOCK) ON SIP.SalId = RP.SalId AND SIP.PrdId = RP.PrdId AND SIP.RtrId = RP.RtrId 
			AND RP.RMId=SIP.RMId AND TP.PrdId=RP.PrdId and TD.PrdId=RP.PrdId 
			WHERE  TH.CmpId =  @PCmpId
			AND TD.Normid = @NormId 
			GROUP BY TP.PrdCtgValMainId,TP.PrdUnitId,TP.PrdUnitName,S.SMId,S.SMName,TP.PrdName,TD.PrdId,RM.RMName,R.RtrName,RM.RMId,R.RtrId,
			PC.PrdCtgValName,TD.NormId,TD.VariationTypeId,TD.VariationPerc,PrdWgt,sip.SalId
		) a
	FETCH NEXT FROM Norms_cursor INTO @NormId
	END
		
	CLOSE Norms_cursor
	DEALLOCATE Norms_cursor
	EXEC Proc_TargetTotalNew		
END
GO
UPDATE CustomCaptions SET MsgBox='Save & Confirmed Successfully' WHERE CtrlName='MsgBox-58-1000-5'
GO
IF NOT EXISTS(SELECT NAME FROM SYSCOLUMNS WHERE name='AutoSptUp' AND id=(SELECT ID FROM SYSOBJECTS WHERE name='TargetAnalysisHd' AND XTYPE='U'))
BEGIN
	ALTER TABLE TargetAnalysisHd ADD AutoSptUp TINYINT DEFAULT 1
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE NAME='TargetDetails' AND XTYPE='U')
DROP TABLE TargetDetails
GO
CREATE TABLE TargetDetails(
	[PrdCtgValMainId] [int] NULL,
	[prdctgvalname] [nvarchar](150) NULL,
	[PrdUnitId] [int] NULL,
	[prdunitname] [nvarchar](100) NULL,
	[SmId] [int] NULL,
	[smname] [nvarchar](150) NULL,
	[RMId] [int] NULL,
	[Rmname] [nvarchar](150) NULL,
	[RtrId] [int] NULL,
	[Rtrname] [nvarchar](150) NULL,
	SalId int null,
	[PrdId] [int] NULL,
	[Prdname] [nvarchar](250) NULL,
	[SugVolume] [numeric](38, 6) NULL,
	[sugValue] [numeric](38, 6) NULL,
	[SugTonnage] [numeric](38, 6) NULL,
	[UsrId] [int] NULL,
	[RtrDayOff] [tinyint] NOT NULL,
	[TotRow] [int] NULL
)
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE Name = 'TgtBrandLevel' AND Xtype = 'U')
BEGIN
CREATE TABLE TgtBrandLevel
(
	TargetAnalysisId int null,
	[PrdCtgValMainId] [int] NULL,
	[PrdUnitId] [int] NULL,
	[CurMonthPlan] [numeric](18, 6) NULL,
	[SugPlan] [numeric](18, 6) NULL,
	[WK1] [numeric](18, 6) NULL,
	[WK2] [numeric](18, 6) NULL,
	[WK3] [numeric](18, 6) NULL,
	[WK4] [numeric](18, 6) NULL,
	[WK5] [numeric](18, 6) NULL,
	[WK6] [numeric](18, 6) NULL,
	[WK7] [numeric](18, 6) NULL,
	[WK8] [numeric](18, 6) NULL,
	[WK9] [numeric](18, 6) NULL,
	[WK10] [numeric](18, 6) NULL,
	[WK11] [numeric](18, 6) NULL,
	[WK12] [numeric](18, 6) NULL,
	[WK13] [numeric](18, 6) NULL,
	[WK14] [numeric](18, 6) NULL,
	[WK15] [numeric](18, 6) NULL,
	[WK16] [numeric](18, 6) NULL,
	[WK17] [numeric](18, 6) NULL,
	[WK18] [numeric](18, 6) NULL,
	[WK19] [numeric](18, 6) NULL,
	[WK20] [numeric](18, 6) NULL,
	[WK21] [numeric](18, 6) NULL,
	[WK22] [numeric](18, 6) NULL,
	[WK23] [numeric](18, 6) NULL,
	[WK24] [numeric](18, 6) NULL,
	[WK25] [numeric](18, 6) NULL,
	[WK26] [numeric](18, 6) NULL,
	[WK27] [numeric](18, 6) NULL,
	[WK28] [numeric](18, 6) NULL,
	[WK29] [numeric](18, 6) NULL,
	[WK30] [numeric](18, 6) NULL,
	[WK31] [numeric](18, 6) NULL,
	[UserId] [int] NULL,
)
END
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE Name = 'TgtBrand_SMLevel' AND Xtype = 'U')
BEGIN
CREATE TABLE TgtBrand_SMLevel
(
	TargetAnalysisId int null,
	[PrdCtgValMainId] [int] NULL,
	[PrdUnitId] [int] NULL,
	[SMId] [int] NULL,	
	[CurMonthPlan] [numeric](18, 6) NULL,
	[SugPlan] [numeric](18, 6) NULL,
	[WK1] [numeric](18, 6) NULL,
	[WK2] [numeric](18, 6) NULL,
	[WK3] [numeric](18, 6) NULL,
	[WK4] [numeric](18, 6) NULL,
	[WK5] [numeric](18, 6) NULL,
	[WK6] [numeric](18, 6) NULL,
	[WK7] [numeric](18, 6) NULL,
	[WK8] [numeric](18, 6) NULL,
	[WK9] [numeric](18, 6) NULL,
	[WK10] [numeric](18, 6) NULL,
	[WK11] [numeric](18, 6) NULL,
	[WK12] [numeric](18, 6) NULL,
	[WK13] [numeric](18, 6) NULL,
	[WK14] [numeric](18, 6) NULL,
	[WK15] [numeric](18, 6) NULL,
	[WK16] [numeric](18, 6) NULL,
	[WK17] [numeric](18, 6) NULL,
	[WK18] [numeric](18, 6) NULL,
	[WK19] [numeric](18, 6) NULL,
	[WK20] [numeric](18, 6) NULL,
	[WK21] [numeric](18, 6) NULL,
	[WK22] [numeric](18, 6) NULL,
	[WK23] [numeric](18, 6) NULL,
	[WK24] [numeric](18, 6) NULL,
	[WK25] [numeric](18, 6) NULL,
	[WK26] [numeric](18, 6) NULL,
	[WK27] [numeric](18, 6) NULL,
	[WK28] [numeric](18, 6) NULL,
	[WK29] [numeric](18, 6) NULL,
	[WK30] [numeric](18, 6) NULL,
	[WK31] [numeric](18, 6) NULL,
	[UserId] [int] NULL,
)
END
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE Name = 'TgtSMLevel' AND Xtype = 'U')
BEGIN
CREATE TABLE TgtSMLevel
(
	TargetAnalysisId int null,
	[SMId] [int] NULL,	
	[CurMonthPlan] [numeric](18, 6) NULL,
	[SugPlan] [numeric](18, 6) NULL,
	[WK1] [numeric](18, 6) NULL,
	[WK2] [numeric](18, 6) NULL,
	[WK3] [numeric](18, 6) NULL,
	[WK4] [numeric](18, 6) NULL,
	[WK5] [numeric](18, 6) NULL,
	[WK6] [numeric](18, 6) NULL,
	[WK7] [numeric](18, 6) NULL,
	[WK8] [numeric](18, 6) NULL,
	[WK9] [numeric](18, 6) NULL,
	[WK10] [numeric](18, 6) NULL,
	[WK11] [numeric](18, 6) NULL,
	[WK12] [numeric](18, 6) NULL,
	[WK13] [numeric](18, 6) NULL,
	[WK14] [numeric](18, 6) NULL,
	[WK15] [numeric](18, 6) NULL,
	[WK16] [numeric](18, 6) NULL,
	[WK17] [numeric](18, 6) NULL,
	[WK18] [numeric](18, 6) NULL,
	[WK19] [numeric](18, 6) NULL,
	[WK20] [numeric](18, 6) NULL,
	[WK21] [numeric](18, 6) NULL,
	[WK22] [numeric](18, 6) NULL,
	[WK23] [numeric](18, 6) NULL,
	[WK24] [numeric](18, 6) NULL,
	[WK25] [numeric](18, 6) NULL,
	[WK26] [numeric](18, 6) NULL,
	[WK27] [numeric](18, 6) NULL,
	[WK28] [numeric](18, 6) NULL,
	[WK29] [numeric](18, 6) NULL,
	[WK30] [numeric](18, 6) NULL,
	[WK31] [numeric](18, 6) NULL,
	[UserId] [int] NULL,
)
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE name='Proc_FillingNonAutoSptUpRecords' AND XTYPE='P')
DROP PROCEDURE Proc_FillingNonAutoSptUpRecords
GO
--EXEC Proc_FillingNonAutoSptUpRecords 5,0,4
CREATE PROCEDURE [dbo].[Proc_FillingNonAutoSptUpRecords]
(
	@Pi_TargetAnalysisId AS INT,
	@Pi_Level AS INT,
	@Pi_WeekCnt AS INT
) 
/*********************************
* PROCEDURE	: Proc_FillingNonAutoSptUpRecords
* PURPOSE	: To Fill Non AutoSptUp Records
* CREATED	: Aravindh Deva C
* CREATED DATE	: 14.01.2013
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*********************************/
AS		
SET NOCOUNT ON
BEGIN
DECLARE @sWks NVARCHAR(500)
DECLARE @sSUMwks NVARCHAR(1000)
DECLARE @sSQL NVARCHAR(4000)
DECLARE @iCnt INT

SET @sWks=''
SET @iCnt=1
	WHILE @iCnt<=@Pi_WeekCnt
	BEGIN
			SET @sWks=@sWks+'WK'+CAST(@iCnt AS NVARCHAR(2))+','
			SET @iCnt=@iCnt+1
	END
	SET @sWks=LEFT(@sWks,LEN(@sWks)-1)
	SET @sSUMwks=REPLACE(@sWks,'WK','SUM(WK')
	SET @sSUMwks=REPLACE(@sSUMwks,',','),')
	SET @sSUMwks=@sSUMwks+')'
	IF @Pi_Level=0
	BEGIN
		SET @sSQL='SELECT PrdCtgValMainId,PrdCtgValName,PrdUnitId,PrdUnitName,SuggestedTarget,CurMonthTarget,RtrDayOff,TotRow,ECO,LineSold,ProductivityCalls,'+@sWks+
		' FROM (Select Tg.PrdCtgValMainId,PrdCtgValName,Tg.PrdUnitId,PrdUnitName,SugPlan as SuggestedTarget,'+
		'ROUND(CAST(CurMonthPlan AS NUMERIC(18,6)),2) as CurMonthTarget,'+
		'1 AS RtrDayOff,0 AS TotRow,ECO,'+
		'LineSold,ProductivityCalls,'+@sWks+ 
		' From BrandTarget TG,ProductCategoryValue PCV,'+
		'ProductUnit PU Where TargetAnalysisId='+CAST(@Pi_TargetAnalysisId AS NVARCHAR(5))+' And PCV.PrdCtgValMainId=Tg.PrdCtgValMainId and tg.prdunitid=pu.prdunitid '--+
		--'group by Tg.PrdCtgValMainId,PrdCtgValName,Tg.PrdUnitId,PrdUnitName,'+@sWks 
		SET @sSQL=@sSQL+' Union '+ 
		'Select 1000000 AS PrdCtgValMainId,''Total'' AS PrdCtgValName,0 AS PrdUnitId,'''' AS PrdUnitName,sum(SugPlan) as SuggestedTarget,'+
		'ROUND(CAST(sum(CurMonthPlan)AS NUMERIC(18,6)),2) as CurMonthTarget,1 RtrDayOff,1 AS TotRow,0 AS ECO,'+
		'0 AS LineSold,0 as ProductivityCalls,'+@sSUMwks+ 
		' From BrandTarget TG,ProductCategoryValue PCV,ProductUnit PU '+
		'Where TargetAnalysisId='+CAST(@Pi_TargetAnalysisId AS NVARCHAR(5))+' And PCV.PrdCtgValMainId=Tg.PrdCtgValMainId and tg.prdunitid=pu.prdunitid) A '+
		'Order by PrdCtgValMainId'
	END
	
	ELSE IF @Pi_Level=1
	BEGIN
		SET @sSQL='SELECT PrdCtgValMainId,PrdCtgValName,PrdUnitId,PrdUnitName,SMId,SMName,SuggestedTarget,CurMonthTarget,1 AS RtrDayOff,TotRow,'
		+'ECO,LineSold,ProductivityCalls,'+@sWks+',HideRow '
		+'From (Select Tg.PrdCtgValMainId,PrdCtgValName,Tg.PrdUnitId,PrdUnitName,TG.SMId,SMName,(SugPlan) as SuggestedTarget,'
		+'(CurMonthPlan) as CurMonthTarget,'''' AS HideRow,0 AS TotRow,ECO,LineSold,ProductivityCalls,'+@sWks+ 
		' From BrandSalesmanTarget TG,ProductCategoryValue PCV,ProductUnit PU,Salesman S '+
		+'Where TargetAnalysisId ='+CAST(@Pi_TargetAnalysisId AS NVARCHAR(5))+' And PCV.PrdCtgValMainId = Tg.PrdCtgValMainId and ' +
		'Tg.prdunitid = pu.prdunitid And s.SMId = Tg.SMId '--+
		--'group by Tg.PrdCtgValMainId,PrdCtgValName,Tg.PrdUnitId,PrdUnitName ,TG.SMId,SMName,'+@sWks	
		SET @sSQL=@sSQL+' Union '+ 
		'Select TG.PrdCtgValMainId,''Total'' AS PrdCtgValName,TG.PrdUnitId,'''' AS PrdUnitName,1000000 AS SMId,'''' AS SMName,sum(SugPlan) as SuggestedTarget,'+
		'sum(CurMonthPlan) as CurMonthTarget,''Total~'' + CAST(TG.PrdCtgValMainId AS NVARCHAR(10))+''~''+ CAST(TG.PrdUnitId AS NVARCHAR(10)) AS HideRow,1 AS TotRow,0,0,0,'+@sSUMwks+
		' From BrandSalesmanTarget TG,ProductCategoryValue PCV,ProductUnit PU,Salesman S Where TargetAnalysisId ='+CAST(@Pi_TargetAnalysisId AS NVARCHAR(5))+' And PCV.PrdCtgValMainId = Tg.PrdCtgValMainId and '+
		'Tg.prdunitid = pu.prdunitid and TG.smid=S.SMId group by Tg.PrdCtgValMainId,PrdCtgValName,Tg.PrdUnitId,PrdUnitName) A ORDER BY PrdCtgValMainId,PrdUnitId,SMId'
	END	
	
	ELSE IF @Pi_Level=2
	BEGIN
		SET @sSQL='SELECT PrdCtgValMainId,PrdCtgValName,PrdUnitId,PrdUnitName,SMId,SMName,SuggestedTarget,CurMonthTarget,1 AS RtrDayOff,'+
		'TotRow,ECO,LineSold,ProductivityCalls,'+@sWks+',HideRow '+
		'From ('+
		'Select 0 PrdCtgValMainId,''Dummy'' PrdCtgValName,0 PrdUnitId,''Dummy'' PrdUnitName,TG.SMId,SMName,'+
		'(SugPlan) as SuggestedTarget, (CurMonthPlan) as CurMonthTarget,'''' AS HideRow,0 AS TotRow,ECO,'+
		'LineSold,ProductivityCalls,'+@sWks+' From SalesmanTarget TG with (nolock),Salesman S Where TargetAnalysisId ='+CAST(@Pi_TargetAnalysisId AS NVARCHAR(5))+' And s.SMId = Tg.SMId '+--group by TG.SMId,SMName '+
		'Union '+
		'Select 0 PrdCtgValMainId,''Total'' AS PrdCtgValName,0 PrdUnitId,''Total'' AS PrdUnitName,1000000 AS SMId,''Total'' AS SMName,sum(SugPlan) as SuggestedTarget,'+
		'sum(CurMonthPlan) as CurMonthTarget,''Total~'' + CAST(0 AS NVARCHAR(10))+''~''+ CAST(0 AS NVARCHAR(10)) AS HideRow,1 AS TotRow,0,0,0,'+@sSUMwks+ 
		' From SalesmanTarget TG with (nolock) Where TargetAnalysisId ='+CAST(@Pi_TargetAnalysisId AS NVARCHAR(5))+
		') A ORDER BY SMId'
	END		
	EXEC (@sSQL)
END
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE Name = 'BrandTarget' AND Xtype = 'U')
BEGIN
CREATE TABLE BrandTarget
(
	TargetAnalysisId int null,
	[PrdCtgValMainId] [int] NULL,
	[PrdUnitId] [int] NULL,
	[SugPlan] [numeric](18, 6) NULL,	
	[CurMonthPlan] [numeric](18, 6) NULL,
	[ECO] INT,
	[LineSold] INT,
	[ProductivityCalls] INT,
	[WK1] [numeric](18, 6) NULL,
	[WK2] [numeric](18, 6) NULL,
	[WK3] [numeric](18, 6) NULL,
	[WK4] [numeric](18, 6) NULL,
	[WK5] [numeric](18, 6) NULL,
	[WK6] [numeric](18, 6) NULL,
	[WK7] [numeric](18, 6) NULL,
	[WK8] [numeric](18, 6) NULL,
	[WK9] [numeric](18, 6) NULL,
	[WK10] [numeric](18, 6) NULL,
	[WK11] [numeric](18, 6) NULL,
	[WK12] [numeric](18, 6) NULL,
	[WK13] [numeric](18, 6) NULL,
	[WK14] [numeric](18, 6) NULL,
	[WK15] [numeric](18, 6) NULL,
	[WK16] [numeric](18, 6) NULL,
	[WK17] [numeric](18, 6) NULL,
	[WK18] [numeric](18, 6) NULL,
	[WK19] [numeric](18, 6) NULL,
	[WK20] [numeric](18, 6) NULL,
	[WK21] [numeric](18, 6) NULL,
	[WK22] [numeric](18, 6) NULL,
	[WK23] [numeric](18, 6) NULL,
	[WK24] [numeric](18, 6) NULL,
	[WK25] [numeric](18, 6) NULL,
	[WK26] [numeric](18, 6) NULL,
	[WK27] [numeric](18, 6) NULL,
	[WK28] [numeric](18, 6) NULL,
	[WK29] [numeric](18, 6) NULL,
	[WK30] [numeric](18, 6) NULL,
	[WK31] [numeric](18, 6) NULL,
	[UserId] [int] NULL,
)
END
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE Name = 'BrandSalesmanTarget' AND Xtype = 'U')
BEGIN
CREATE TABLE BrandSalesmanTarget
(
	TargetAnalysisId int null,
	[PrdCtgValMainId] [int] NULL,
	[PrdUnitId] [int] NULL,
	[SMId] [int] NULL,	
	[SugPlan] [numeric](18, 6) NULL,	
	[CurMonthPlan] [numeric](18, 6) NULL,
	[ECO] INT,
	[LineSold] INT,
	[ProductivityCalls] INT,
	[WK1] [numeric](18, 6) NULL,
	[WK2] [numeric](18, 6) NULL,
	[WK3] [numeric](18, 6) NULL,
	[WK4] [numeric](18, 6) NULL,
	[WK5] [numeric](18, 6) NULL,
	[WK6] [numeric](18, 6) NULL,
	[WK7] [numeric](18, 6) NULL,
	[WK8] [numeric](18, 6) NULL,
	[WK9] [numeric](18, 6) NULL,
	[WK10] [numeric](18, 6) NULL,
	[WK11] [numeric](18, 6) NULL,
	[WK12] [numeric](18, 6) NULL,
	[WK13] [numeric](18, 6) NULL,
	[WK14] [numeric](18, 6) NULL,
	[WK15] [numeric](18, 6) NULL,
	[WK16] [numeric](18, 6) NULL,
	[WK17] [numeric](18, 6) NULL,
	[WK18] [numeric](18, 6) NULL,
	[WK19] [numeric](18, 6) NULL,
	[WK20] [numeric](18, 6) NULL,
	[WK21] [numeric](18, 6) NULL,
	[WK22] [numeric](18, 6) NULL,
	[WK23] [numeric](18, 6) NULL,
	[WK24] [numeric](18, 6) NULL,
	[WK25] [numeric](18, 6) NULL,
	[WK26] [numeric](18, 6) NULL,
	[WK27] [numeric](18, 6) NULL,
	[WK28] [numeric](18, 6) NULL,
	[WK29] [numeric](18, 6) NULL,
	[WK30] [numeric](18, 6) NULL,
	[WK31] [numeric](18, 6) NULL,
	[UserId] [int] NULL,
)
END
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE Name = 'SalesmanTarget' AND Xtype = 'U')
BEGIN
CREATE TABLE SalesmanTarget
(
	TargetAnalysisId int null,
	[SMId] [int] NULL,	
	[SugPlan] [numeric](18, 6) NULL,	
	[CurMonthPlan] [numeric](18, 6) NULL,
	[ECO] INT,
	[LineSold] INT,
	[ProductivityCalls] INT,
	[WK1] [numeric](18, 6) NULL,
	[WK2] [numeric](18, 6) NULL,
	[WK3] [numeric](18, 6) NULL,
	[WK4] [numeric](18, 6) NULL,
	[WK5] [numeric](18, 6) NULL,
	[WK6] [numeric](18, 6) NULL,
	[WK7] [numeric](18, 6) NULL,
	[WK8] [numeric](18, 6) NULL,
	[WK9] [numeric](18, 6) NULL,
	[WK10] [numeric](18, 6) NULL,
	[WK11] [numeric](18, 6) NULL,
	[WK12] [numeric](18, 6) NULL,
	[WK13] [numeric](18, 6) NULL,
	[WK14] [numeric](18, 6) NULL,
	[WK15] [numeric](18, 6) NULL,
	[WK16] [numeric](18, 6) NULL,
	[WK17] [numeric](18, 6) NULL,
	[WK18] [numeric](18, 6) NULL,
	[WK19] [numeric](18, 6) NULL,
	[WK20] [numeric](18, 6) NULL,
	[WK21] [numeric](18, 6) NULL,
	[WK22] [numeric](18, 6) NULL,
	[WK23] [numeric](18, 6) NULL,
	[WK24] [numeric](18, 6) NULL,
	[WK25] [numeric](18, 6) NULL,
	[WK26] [numeric](18, 6) NULL,
	[WK27] [numeric](18, 6) NULL,
	[WK28] [numeric](18, 6) NULL,
	[WK29] [numeric](18, 6) NULL,
	[WK30] [numeric](18, 6) NULL,
	[WK31] [numeric](18, 6) NULL,
	[UserId] [int] NULL,
)
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_ChangeOfTA' AND XTYPE='P')
DROP PROC Proc_ChangeOfTA
GO
CREATE PROCEDURE Proc_ChangeOfTA
(
@TAType INT
)
AS
/************************************************
* PROCEDURE	: Proc_ChangeOfTA
* PURPOSE	: To Calculate ECO,LinesSold and ProductivityCalls(Bills Cut)
* CREATED	: Aravindh Deva C
* CREATED DATE	: 22.02.2013
* NOTE		: 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}      {developer}		{brief modification description} 	
* 27.02.2013  Aravindh Deva C	COUNT(DISTINCT(PrdId)) distinct Prd is Removed PMS No : ICRSTNIV0022
**************************************************/
SET NOCOUNT ON
BEGIN

	IF @TAType=0
	BEGIN		
		SELECT PrdCtgValMainId [BrandId],COUNT(DISTINCT(T.RtrId))[ECO],COUNT(PrdId)[LineSold],--COUNT(DISTINCT(PrdId))
		COUNT(DISTINCT(SalId))[ProductivityCalls] FROM TargetDetails T		
		WHERE T.SmId<>0 AND T.RtrId NOT IN (0,100000) AND PrdId NOT IN (0,100000) AND SalId <> 0
		GROUP BY PrdCtgValMainId
		ORDER BY PrdCtgValMainId
	END
	ELSE IF @TAType=1
	BEGIN
		SELECT PrdCtgValMainId [BrandId],T.SmId,COUNT(DISTINCT(RtrId))[ECO],COUNT(PrdId)[LineSold],--COUNT(DISTINCT(PrdId))
		COUNT(DISTINCT(SalId))[ProductivityCalls] FROM TargetDetails T
		WHERE T.SmId<>0 AND RtrId NOT IN (0,100000) AND PrdId NOT IN (0,100000) AND SalId <> 0
		GROUP BY PrdCtgValMainId,T.SmId
		ORDER BY PrdCtgValMainId,T.SmId
	END
	ELSE
	BEGIN
		SELECT T.SmId,COUNT(DISTINCT(RtrId))[ECO],COUNT(PrdId)[LineSold],--COUNT(DISTINCT(PrdId))
		COUNT(DISTINCT(SalId)) [ProductivityCalls] FROM TargetDetails T
		WHERE T.SmId<>0 AND RtrId NOT IN (0,100000) AND PrdId NOT IN (0,100000) AND SalId <> 0
		GROUP BY T.SmId
		ORDER BY T.SmId
	END		
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Fn_CheckBackDated' AND XTYPE IN ('TF','FN'))
DROP FUNCTION Fn_CheckBackDated
GO
CREATE FUNCTION Fn_CheckBackDated(@Pi_JcmId INT,@Pi_JcmJc INT,@Pi_CmpId INT,@Pi_UserId INT)
RETURNS INT
AS
BEGIN
/*********************************
* FUNCTION: Fn_CheckBackDated
* PURPOSE: to check Back Dated Transactions
* NOTES: 
* CREATED: Aravindh Deva C	22.02.2013
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 
*********************************/
DECLARE @RetValue as INT

	SELECT @RetValue = COUNT(TargetAnalysisRefno) 
	From TargetAnalysisHd 
	Where (jcmjc > (Select jcmjc from JCMonth where jcmid = @Pi_JcmId and jcmjc = @Pi_JcmJc)
	or jcmId > (Select jcmId from JCMast where jcmid = @Pi_JcmId)) and Cmpid = @Pi_CmpId and Authid = @Pi_UserId

RETURN(@RetValue)
END
GO
DELETE FROM FieldLevelAccessDt WHERE TransId=46 AND CtrlId IN (100041,100042,100043)
INSERT INTO FieldLevelAccessDt([PrfId],[TransId],[CtrlId],[AccessSts],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) VALUES (1,46,100041,1,1,1,'2013-03-01',1,'2013-03-01')
INSERT INTO FieldLevelAccessDt([PrfId],[TransId],[CtrlId],[AccessSts],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) VALUES (1,46,100042,1,1,1,'2013-03-01',1,'2013-03-01')
INSERT INTO FieldLevelAccessDt([PrfId],[TransId],[CtrlId],[AccessSts],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) VALUES (1,46,100043,1,1,1,'2013-03-01',1,'2013-03-01')
GO
DELETE FROM CustomCaptions WHERE TransId=46 AND CtrlId IN (100041,100042,100043)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (46,100041,0,'FpDist-46-6-0','Plan For Current Month','','',1,1,1,'2013-03-01',1,'2013-03-01','Plan For Current Month','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (46,100042,0,'FpSM-46-8-0','Plan For Current Month','','',1,1,1,'2013-03-01',1,'2013-03-01','Plan For Current Month','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (46,100043,0,'FpRM-46-8-0','Plan For Current Month','','',1,1,1,'2013-03-01',1,'2013-03-01','Plan For Current Month','','',1,1)
GO
IF NOT EXISTS(SELECT SS.NAME FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SS ON S.id=SS.id 
WHERE  S.xtype='U' and S.name='Users' and SS.name='HostName')
BEGIN
ALTER TABLE Users ADD  HostName Varchar(100) DEFAULT '' WITH  VALUES 
END
GO
UPDATE Users SET LoggedStatus = 2
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name='Proc_UserValidation')
DROP PROCEDURE Proc_UserValidation
GO
CREATE PROCEDURE [Proc_UserValidation]
(	
	@Pi_UserId AS INT,
	@Pi_HostName AS Varchar(100),
	@Pi_DatabaseName AS Varchar(100),
	@Pi_UserStatus AS TinyInt OUTPUT,
	@Pi_Msg AS Varchar(300) OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UserValidation
* PURPOSE	: To Validate Users
* CREATED	: Murugan.R
* CREATED DATE	: 2013/01/23
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}     
****************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @Pi_HostNameLocked as Varchar(100)
	DECLARE @Pi_UserName as Varchar(100)
	DECLARE @Pi_Error TINYINT
	SET @Pi_Error =0
	SET @Pi_UserStatus=0
	
	BEGIN TRAN
	
	UPDATE Users Set LoggedStatus=1 where UserId=@Pi_UserId
	IF NOT EXISTS(Select UserId FROM Users (NOLOCK) WHERE UserId=@Pi_UserId and HostName NOT IN(@Pi_HostName,'') and LoggedStatus=1)
	BEGIN

		Update Users Set HostName=@Pi_HostName where UserId=@Pi_UserId
		Update Users Set HostName='' where UserId NOT IN(@Pi_UserId) and HostName=@Pi_HostName
		SET @Pi_Error=0
	END
	ELSE
	BEGIN
		IF EXISTS(
				SELECT Distinct A.HostName FROM Master..Sysprocesses A 
				INNER JOIN sys.dm_Exec_Sessions B ON A.Spid=B.session_id
				INNER JOIN master..SysDatabases C ON A.dbid=C.dbid
				WHERE C.Name COLLATE SQL_Latin1_General_CP1_CI_AS =@Pi_DatabaseName AND LTRIM(RTRIM(A.HostName)) COLLATE SQL_Latin1_General_CP1_CI_AS
				IN(SELECT hostname FROM Users (NOLOCK) WHERE UserId=@Pi_UserId) and A.PROGRAM_NAME IN('Core Stocky','Visual Basic')
				and A.Spid>50 And B.Client_Interface_Name COLLATE SQL_Latin1_General_CP1_CI_AS ='OLEDB'
				)
		BEGIN
			SELECT @Pi_HostName=HostName,@Pi_UserName=UserName FROM Users (NOLOCK) WHERE UserId=@Pi_UserId
			SET @Pi_Error=1	
		END
		ELSE
		BEGIN
			Update Users Set HostName=@Pi_HostName where UserId=@Pi_UserId
			Update Users Set HostName='' where UserId NOT IN(@Pi_UserId) and HostName=@Pi_HostName
			SET @Pi_Error=0
		END
		
	END
	IF @Pi_Error=1 
	BEGIN
		SET @Pi_Msg='The User '+ UPPER(@Pi_UserName) +' already locked in the machine '+ @Pi_HostName
		ROLLBACK TRAN
		SET @Pi_UserStatus=1
	END
	ELSE
	BEGIN
		SELECT 'User logged In' 
		COMMIT TRAN
		SET @Pi_UserStatus=0
		SET @Pi_Msg=''
	END
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_PostVoucherCounterReset')
DROP PROCEDURE Proc_PostVoucherCounterReset
GO
CREATE PROCEDURE Proc_PostVoucherCounterReset
(
	@Pi_TabName		NVARCHAR(50),
	@Pi_FldName		NVARCHAR(50),
	@Pi_CurVal		NVARCHAR(100),
	@Pi_VocDate 		DATETIME,
	@Po_NewVoc		NVARCHAR(100) OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_PostVoucherCounterReset
* PURPOSE	: To do ReOrder the Back Dated Vouchers
* CREATED	: Nandakumar R.G
* CREATED DATE	: 09/03/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
		
	DECLARE @VocRefNo	NVARCHAR(50)

	DECLARE	@OldJVCount	INT
	DECLARE @Prefix		NVARCHAR(10)
	DECLARE @Year		NVARCHAR(10)
	DECLARE @zPad		INT

	DECLARe @NewCount	INT
	DECLARE @BaseCount	INT
	DECLARE @VocType	INT

	DECLARE @TempNewNo	TABLE
	(
		SlNo		INT,
		OldVocNo	NVARCHAR(50),
		NewNo		NVARCHAR(50)
	)

	--Get the Voucher Type
	IF @Pi_FldName='ContraVoc'
	BEGIN
		SET @VocType=0
	END
	ELSE IF @Pi_FldName='PaymentVoc'
	BEGIN
		SET @VocType=1
	END
	ELSE IF @Pi_FldName='ReceiptVoc'
	BEGIN
		SET @VocType=2
	END
	ELSE IF @Pi_FldName='JournalVoc'
	BEGIN
		SET @VocType=3
	END
	ELSE IF @Pi_FldName='SalesVoc'
	BEGIN
		SET @VocType=4
	END
	ELSE IF @Pi_FldName='PurchaseVoc'
	BEGIN
		SET @VocType=5
	END
	ELSE IF @Pi_FldName='MemoVoc'
	BEGIN
		SET @VocType=6
	END

	--Get the Prefix,Year,Zpad and Old Voucher Count from Counters
	SELECT @Prefix = Prefix,@Year = RIGHT(CurYear,2),@zPad = ZPad,@OldJVCount = CurrValue
	FROM Counters(NOLOCK) WHERE TabName=@Pi_TabName AND FldName=@Pi_FldName

	--Get the last voucher posted on previous date 
     SELECT  @BaseCount=MAX(ISNULL(CAST(SubString(VocRefNo,(LEN(@Prefix)+3),
	(LEN(VocRefNo) - (LEN(@Prefix)+2))) AS BIGINT),0) )
	FROM StdVocMaster (NOLOCK)
	WHERE VocType=@VocType AND VocDate < @Pi_VocDate 
--	SELECT @BaseCount = CAST(ISNULL(MAX(SubString(VocRefNo,(LEN(@Prefix)+3),
--	(LEN(VocRefNo) - (LEN(@Prefix)+2)))),0) AS INT)
--	FROM StdVocMaster (NOLOCK)
--	WHERE VocType=@VocType AND VocDate < @Pi_VocDate


	--Create a Table to store Old and New Voucher Nos
	IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[ReOrderVoucher]') AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	DROP TABLE [ReOrderVoucher]

	CREATE TABLE ReOrderVoucher
	(
		SlNo		INT IDENTITY(1,1),
		OldVocNo	NVARCHAR(50),
		OldVocDate	DATETIME,
		NewVocNo	NVARCHAR(50)
	)

	--Insert the Old and New Voucher Nos
	INSERT INTO ReOrderVoucher(OldVocNo,OldVocDate,NewVocNo)
	SELECT VocRefNo,VocDate,'' FROM StdVocMaster(NOLOCK) WHERE VocType=@VocType AND VocDate >= @Pi_VocDate
	ORDER BY VocDate,VocRefNo

	INSERT INTO @TempNewNo(SlNo,OldVocNo,NewNo)	
	SELECT SlNo,OldVocNo,@Prefix+CAST(RIGHT(ACM.AcmYr,2) AS NVARCHAR(2))+dbo.Fn_ReturnzPad(@ZPad,SlNo+@BaseCount) AS NewNo 	
	FROM ReOrderVoucher (NOLOCK),AcMaster ACM (NOLOCK),AcPeriod ACP (NOLOCK)
	WHERE ACM.AcmId=ACP.AcmId AND OldVocDate BETWEEN ACP.AcmSdt AND ACP.AcmEdt

	UPDATE ReOrderVoucher SET NewVocNo=NewNo
	FROM @TempNewNo A WHERE ReOrderVoucher.SlNo=A.SlNo AND ReOrderVoucher.OldVocNo collate database_default=A.OldVocNo collate database_default


	--Get the New Voucher No for the given input
	SELECT @Po_NewVoc=NewVocNo FROM ReOrderVoucher(NOLOCK) WHERE OldVocNo=@Pi_CurVal	

-- 	--Remove the Key Constrains
-- 	IF EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'FK_StdVocDetails_StdVocMaster' 
--         AND Xtype = 'F') BEGIN  ALTER TABLE [dbo].[StdVocDetails] DROP CONSTRAINT 
--         [FK_StdVocDetails_StdVocMaster] END
--                     
--         IF EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'PK_StdVocMaster' AND Xtype = 'PK')
--         BEGIN ALTER TABLE [dbo].[StdVocMaster] DROP CONSTRAINT [PK_StdVocMaster] END

	--Update Voucher tables with New Voucher Nos
		
	UPDATE StdVocDetails SET VocRefNo=NewVocNo
	FROM ReOrderVoucher(NOLOCK),StdVocMaster (NOLOCK) 
	WHERE StdVocDetails.VocRefNo=ReOrderVoucher.OldVocNo 
	AND StdVocDetails.VocRefNo=StdVocMaster.VocRefNo	
	AND StdVocMaster.VocType=@VocType
	
	UPDATE StdVocMaster SET VocRefNo=NewVocNo
	FROM ReOrderVoucher (NOLOCK)
	WHERE StdVocMaster.VocRefNo=ReOrderVoucher.OldVocNo AND StdVocMaster.VocType=@VocType

-- 	--Add the constarints again
-- 	IF NOT EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'PK_StdVocMaster' AND 
-- 	Xtype = 'PK') BEGIN ALTER TABLE [dbo].[StdVocMaster] ADD CONSTRAINT [PK_StdVocMaster] 
-- 	PRIMARY KEY  CLUSTERED ([VocRefno])  ON [PRIMARY] END	
-- 	                    
-- 	IF EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'FK_StdVocDetails_StdVocMaster' 
-- 	AND Xtype = 'F') BEGIN ALTER TABLE [dbo].[StdVocDetails] ADD CONSTRAINT 
-- 	[FK_StdVocDetails_StdVocMaster] FOREIGN KEY ([VocRefno]) REFERENCES [StdVocMaster] 
-- 	([VocRefno]) END 

	--Update the counters with New Value 
	SELECT @NewCount=MAX(SlNo)+@BaseCount FROM ReOrderVoucher(NOLOCK)
	UPDATE Counters SET CurrValue=@NewCount
	WHERE TabName=@Pi_TabName AND FldName=@Pi_FldName

	RETURN
END
GO
IF NOT EXISTS (SELECT * FROM SysColumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'TargetAnalysisHd') AND name = 'Upload') 
BEGIN
    ALTER TABLE TargetAnalysisHd ADD Upload INT DEFAULT 0 WITH VALUES 
END
GO
IF NOT EXISTS (SELECT * FROM SysColumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'LaunchTargetHd') AND name = 'Upload') 
BEGIN
    ALTER TABLE LaunchTargetHd ADD Upload INT DEFAULT 0 WITH VALUES
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'U' AND name = 'CS2CN_Prk_TargetDetails')
DROP TABLE CS2CN_Prk_TargetDetails
GO
CREATE TABLE CS2CN_Prk_TargetDetails
(
	 SlNo NUMERIC(18,0) IDENTITY,
	 DistCode NVARCHAR(100),
	 TargetAnalysisRefNo NVARCHAR(100),
	 JCYear  INT,
	 JCMonth NVARCHAR(50),
	 TargetType NVARCHAR(50),
	 TargetLevel NVARCHAR(50),
	 TotalTarget NUMERIC (18,2),
	 BrandName NVARCHAR(50),
	 SmCode NVARCHAR(50),
	 SMName NVARCHAR(100),
	 SugPlan  NUMERIC(18,2),
	 CurrMonthPlan NUMERIC (18,2),
	 ECO NUMERIC (18,0),
	 LineSold NUMERIC (18,0),
	 ProductivityCalls NUMERIC (18,0),
	 [Week1] NUMERIC (18,2),
	 [Week2] NUMERIC (18,2),
	 [Week3] NUMERIC (18,2),
	 [Week4] NUMERIC (18,2),
	 [Week5] NUMERIC (18,2),
	 [Week6] NUMERIC (18,2),
	 UploadFlag NVARCHAR(10)
)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'U' AND name = 'CS2CN_Prk_LaunchProduct')
DROP TABLE CS2CN_Prk_LaunchProduct
GO
CREATE TABLE CS2CN_Prk_LaunchProduct
(
	 SlNo NUMERIC(18,0) IDENTITY,
	 DistCode NVARCHAR(100),
	 LaunchRefNo NVARCHAR(100),
	 JCYear NVARCHAR(50),
	 FromJcMonth  NVARCHAR(50),
	 ToJcMonth NVARCHAR(50),
	 ProductCategory NVARCHAR(100),
	 ProductCategoryLevel NVARCHAR(100),
	 ProductCategoryValue NVARCHAR(100),
	 LaunchLevel NVARCHAR(50),
	 SalesmanCode NVARCHAR(50),
	 SalesMan NVARCHAR(100),
	 RouteCode NVARCHAR(50),
	 RouteName NVARCHAR(100),
	 RetailerCategory NVARCHAR(50),
	 RetailerValueClass NVARCHAR(50),
	 RetailerCount NUMERIC(18,0),
	 PlanNoOfRetailer NUMERIC(18,0),
	 ActualRetaierCount NUMERIC(18,0),
	 ToatlPlanVolume NUMERIC(18,2),
	 ToatlPlanValue NUMERIC(18,2),
	 ActualVolume NUMERIC(18,2),
	 ActualValue NUMERIC(18,2),
	 UploadFlag NVARCHAR(10)
)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_CS2CN_TargetAnalysis')
DROP PROCEDURE Proc_CS2CN_TargetAnalysis
GO
/*
BEGIN TRANSACTION
EXEC Proc_CS2CN_TargetAnalysis 0
SELECT * FROM CS2CN_Prk_TargetDetails WITH (NOLOCK)
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_CS2CN_TargetAnalysis
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_CS2CN_TargetAnalysis
* PURPOSE		: To Extract Target Analysis Details from CoreStocky to upload to Console
* CREATED BY	: Sathishkumar Veeramani
* CREATED DATE	: 25/03/2013
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @DistCode	As nVarchar(50)
	SET @Po_ErrNo=0
	DELETE FROM CS2CN_Prk_TargetDetails WHERE UploadFlag = 'Y'
	SELECT @DistCode = DistributorCode FROM Distributor	WITH (NOLOCK)
	INSERT INTO CS2CN_Prk_TargetDetails
	(
		DistCode,
		TargetAnalysisRefNo,
		JCYear,
		JCMonth,
		TargetType,
		TargetLevel,
		TotalTarget,
		BrandName,
		SmCode,
		SMName,
		SugPlan,
		CurrMonthPlan,
		ECO,
		LineSold,
		ProductivityCalls,
		[Week1],
		[Week2],
		[Week3],
		[Week4],
		[Week5],
		[Week6],
		UploadFlag
	)
	--Brand Level Target
	SELECT DISTINCT @DistCode,A.TargetAnalysisRefNo,JcmYr,DATENAME(MONTH,DATEADD(MONTH,A.JcmJc,0) - 1) AS [MonthName],
	(CASE A.TargetType WHEN 1 THEN 'Volume' WHEN 2 THEN 'Value' ELSE 'Tonnage' END) AS TargetType,
	'Brand' AS TargetLevel,TotalTarget,ISNULL(PrdCtgValName,'') AS BrandName,'' AS SmCode,'' AS SMName,SugPlan,B.CurMonthPlan,ECO,LineSold,ProductivityCalls,
	ISNULL(WK1,0) AS WK1,ISNULL(WK2,0) AS WK2,ISNULL(WK3,0) AS WK3,ISNULL(WK4,0) AS WK4,ISNULL(WK5,0) AS WK5,ISNULL(WK6,0) AS WK6,'N' UploadFlag
	FROM TargetAnalysisHd A WITH (NOLOCK) 
	INNER JOIN BrandTarget B WITH (NOLOCK) ON A.TargetAnalysisId = B.TargetAnalysisId
	INNER JOIN JCMast C WITH (NOLOCK) ON A.JcmId = C.JcmId 
	INNER JOIN JCMonth D WITH (NOLOCK) ON A.JcmJc = D.JcmJc AND C.JcmId = D.JcmId
	INNER JOIN ProductCategoryValue E WITH (NOLOCK) ON B.PrdCtgValMainId = E.PrdCtgValMainId
	WHERE A.[Status] = 1 AND A.Upload = 0
	--Brand SalesMan Level Targat
	UNION ALL
	SELECT DISTINCT @DistCode,A.TargetAnalysisRefNo,JcmYr,DATENAME(MONTH,DATEADD(MONTH,A.JcmJc,0) - 1) AS [MonthName],
	(CASE A.TargetType WHEN 1 THEN 'Volume' WHEN 2 THEN 'Value' ELSE 'Tonnage' END) AS TargetType,
	'Brand-SalesMan' AS TargetLevel,TotalTarget,'' AS BrandName,ISNULL(E.SmCode,'') AS SmCode,ISNULL(E.SmName,'') AS SMName,
	SugPlan,B.CurMonthPlan,ECO,LineSold,ProductivityCalls,
	ISNULL(WK1,0) AS WK1,ISNULL(WK2,0) AS WK2,ISNULL(WK3,0) AS WK3,ISNULL(WK4,0) AS WK4,ISNULL(WK5,0) AS WK5,ISNULL(WK6,0) AS WK6,'N' UploadFlag
	FROM TargetAnalysisHd A WITH (NOLOCK) 
	INNER JOIN BrandSalesmanTarget B WITH (NOLOCK) ON A.TargetAnalysisId = B.TargetAnalysisId
	INNER JOIN JCMast C WITH (NOLOCK) ON A.JcmId = C.JcmId 
	INNER JOIN JCMonth D WITH (NOLOCK) ON A.JcmJc = D.JcmJc AND C.JcmId = D.JcmId
	INNER JOIN SalesMan E WITH (NOLOCK) ON B.SmId = E.SmId
	WHERE A.[Status] = 1 AND A.Upload = 0
	--SalesMan Level Targat
	UNION ALL
	SELECT DISTINCT @DistCode,A.TargetAnalysisRefNo,JcmYr,DATENAME(MONTH,DATEADD(MONTH,A.JcmJc,0) - 1) AS [MonthName],
	(CASE A.TargetType WHEN 1 THEN 'Volume' WHEN 2 THEN 'Value' ELSE 'Tonnage' END) AS TargetType,
	'SalesMan' AS TargetLevel,TotalTarget,'' AS BrandName,ISNULL(E.SmCode,'') AS SmCode,ISNULL(E.SmName,'') AS SMName,
	SugPlan,B.CurMonthPlan,ECO,LineSold,ProductivityCalls,
	ISNULL(WK1,0) AS WK1,ISNULL(WK2,0) AS WK2,ISNULL(WK3,0) AS WK3,ISNULL(WK4,0) AS WK4,ISNULL(WK5,0) AS WK5,ISNULL(WK6,0) AS WK6,'N' UploadFlag
	FROM TargetAnalysisHd A WITH (NOLOCK) 
	INNER JOIN SalesmanTarget B WITH (NOLOCK) ON A.TargetAnalysisId = B.TargetAnalysisId
	INNER JOIN JCMast C WITH (NOLOCK) ON A.JcmId = C.JcmId 
	INNER JOIN JCMonth D WITH (NOLOCK) ON A.JcmJc = D.JcmJc AND C.JcmId = D.JcmId
	INNER JOIN SalesMan E WITH (NOLOCK) ON B.SmId = E.SmId
	WHERE A.[Status] = 1 AND A.Upload = 0

	UPDATE TargetAnalysisHd SET Upload=1 WHERE Upload=0 AND TargetAnalysisRefNo IN (SELECT DISTINCT
	TargetAnalysisRefNo FROM CS2CN_Prk_TargetDetails WHERE UploadFlag = 'N')
END
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_CS2CN_LaunchProduct')
DROP PROCEDURE Proc_CS2CN_LaunchProduct
GO
/*
BEGIN TRANSACTION
EXEC Proc_CS2CN_LaunchProduct 0
SELECT * FROM CS2CN_Prk_LaunchProduct WITH (NOLOCK)
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_CS2CN_LaunchProduct
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: CS2CN_Prk_LaunchProduct
* PURPOSE		: To Extract Launch Product Details from CoreStocky to Upload to Console
* CREATED BY	: Sathishkumar Veeramani
* CREATED DATE	: 25/03/2013
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @DistCode AS NVARCHAR(50)
	SET @Po_ErrNo=0
	DELETE FROM CS2CN_Prk_LaunchProduct WHERE UploadFlag = 'Y'
	SELECT @DistCode = DistributorCode FROM Distributor	WITH (NOLOCK)
	
    SELECT DISTINCT A.CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValName INTO #ProductCategory FROM ProductCategoryLevel A WITH (NOLOCK)
    INNER JOIN ProductCategoryValue B WITH (NOLOCK) ON A.CmpPrdCtgId = B.CmpPrdCtgId
    
    SELECT DISTINCT SLaunchNo,PrdId,PrdCtgValName,PlanNoOfRet,ActNoOfRet,PlanPerRetInVol,ActualVol,ActualVal,PlanNoOfRetSplit,PlanPerRetInVal
    INTO #LaunchTargetMonthPlan FROM LaunchTargetMonthPlan A WITH (NOLOCK)
    INNER JOIN ProductCategoryValue B WITH (NOLOCK) ON A.PrdId = B.PrdCtgValMainId
    
    SELECT DISTINCT SLaunchNo,(CASE LaunchValue WHEN 1 THEN 'Launch Target in Value' WHEN 0 THEN
    (CASE RetailerCat WHEN 1 THEN 'Retailer Category' ELSE 'Retailer Class' END) END) AS LaunchValue INTO #LaunchLevel FROM LaunchTargetHd WITH (NOLOCK)
    
    SELECT DISTINCT A.CtgMainId,CtgName,RtrClassId,ValueClassName INTO #RetailerCategoryValueClass
    FROM RetailerCategory A WITH (NOLOCK) INNER JOIN RetailerValueClass B WITH (NOLOCK) ON A.CtgMainId = B.CtgMainId
    
    SELECT DISTINCT A.SLaunchNo,A.SMID,SMCode,SMName,A.RMID,RMCode,RMName,A.CtgMainId,CtgName,A.RtrClassId,ValueClassName,NoOfRet 
    INTO #LaunchTargetDt FROM LaunchTargetDt A WITH (NOLOCK) INNER JOIN SalesMan B WITH (NOLOCK) ON A.SMId = B.SMId
    INNER JOIN RouteMaster C WITH (NOLOCK) ON A.RMId = C.RMId INNER JOIN #RetailerCategoryValueClass D WITH (NOLOCK) 
    ON A.CtgMainId = D.CtgMainId AND A.RtrClassId = D.RtrClassId

    
	INSERT INTO CS2CN_Prk_LaunchProduct
	(
		DistCode,
		LaunchRefNo,
		JCYear,
		FromJcMonth,
		ToJcMonth,
		ProductCategory,
		ProductCategoryLevel,
		ProductCategoryValue,
		LaunchLevel,
		SalesmanCode,
		SalesMan,
		RouteCode,
		RouteName,
		RetailerCategory,
		RetailerValueClass,
		RetailerCount,
		PlanNoOfRetailer,
		ActualRetaierCount,
		ToatlPlanVolume,
		ToatlPlanValue,
		ActualVolume,
		ActualValue,
		UploadFlag
	)
	--Brand Level Target
	SELECT DISTINCT @DistCode,LaunchRefNo,JcmYr,DATENAME(MONTH,E.JcmSdt) AS [FromJCmonth],DATENAME(MONTH,F.JcmEdt) AS [ToJCmonth],
	G.CmpPrdCtgName,G.PrdCtgValName,C.PrdCtgValName,H.LaunchValue,SMCode,SMName,RMCode,RMName,CtgName,ValueClassName,NoOfRet,
	PlanNoOfRet,ActNoOfRet,ROUND(ISNULL(SUM(C.PlanPerRetInVol),0),0) AS ToatlPlanVolume,ROUND(ISNULL(SUM(C.PlanPerRetInVal),0),0) AS ToatlPlanValue,
	C.ActualVol,C.ActualVal,'N'	FROM LaunchTargetHd A WITH (NOLOCK)
	INNER JOIN #LaunchTargetDt B WITH (NOLOCK) ON A.SLaunchNo = B.SLaunchNo
	INNER JOIN #LaunchTargetMonthPlan C WITH (NOLOCK) ON B.SLaunchNo = C.SLaunchNo
	INNER JOIN JCMast D WITH (NOLOCK) ON A.JcmId = D.JcmId  
	INNER JOIN JCMonth E WITH (NOLOCK) ON A.FromJc = E.JcmJc AND E.JcmId = D.JcmId
	INNER JOIN JCMonth F WITH (NOLOCK) ON A.ToJc = F.JcmJc AND F.JcmId = D.JcmId
	INNER JOIN #ProductCategory G WITH (NOLOCK) ON A.CmpPrdCtgId = G.CmpPrdCtgId AND A.PrdCtgValMainId = G.PrdCtgValMainId
	INNER JOIN #LaunchLevel H WITH (NOLOCK) ON A.SLaunchNo = H.SLaunchNo
    WHERE A.[Status] = 1 AND A.Upload = 0 GROUP BY LaunchRefNo,JcmYr,E.JcmSdt,F.JcmEdt,G.CmpPrdCtgName,G.PrdCtgValName,
    C.PrdCtgValName,H.LaunchValue,SMCode,SMName,RMCode,RMName,CtgName,ValueClassName,NoOfRet,PlanNoOfRet,ActNoOfRet,C.ActualVol,C.ActualVal    
	
	UPDATE LaunchTargetHd SET Upload=1 WHERE Upload=0 AND LaunchRefNo IN (SELECT DISTINCT
	LaunchRefNo FROM CS2CN_Prk_LaunchProduct WHERE UploadFlag = 'N')
END
GO
DELETE FROM RptSelectionHd WHERE SelcId = 291
INSERT INTO RptSelectionHd
SELECT 291,'Sel_IDTDistId','IDTManagement',0
GO
DELETE FROM RptDetails WHERE RptId = 245
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,1,'ToDate',-1,NULL,'','As On Date*',NULL,1,NULL,11,0,0,'Enter the  Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,2,'Company',-1,NULL,'CmpId,CmpCode,CmpName','Company*...',NULL,1,NULL,4,1,1,'Press F4/Double Click to select Company',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,3,'Location',-1,NULL,'LcnId,LcnCode,LcnName','Location...',NULL,1,NULL,22,1,0,'Press F4/Double Click to select Location',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,4,'ProductCategoryLevel',2,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,0,'Press F4/Double click to select Hierarchy Level',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,5,'ProductCategoryValue',4,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,0,0,'Press F4/Double Click to select Product Hierarchy Level Value',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,6,'Product',5,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,0,0,'Press F4/Double click to select Product',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,7,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Stock Value as per*...',NULL,1,NULL,209,1,1,'Press F4/Double Click to select Stock Value as per',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,8,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Product Status...',NULL,1,NULL,210,1,0,'Press F4/Double Click to select Product Status',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,9,'RptFilter',-1,NULL,'FilterId,FilterId,FilterDesc','Batch Status...',NULL,1,NULL,211,1,0,'Press F4/Double Click to select Batch Status',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,10,'RptFilter',-1,NULL,'FilterId,FilterDesc,FilterDesc','Suppress Zero Stock*...',NULL,1,NULL,44,1,1,'Press F4/Double Click to Select the Supress Zero Stock',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (245,11,'StockType',3,'LcnId','StockTypeId,UserStockType,UserStockType','Stock Type...','Location',1,'LcnId',291,1,0,'Press F4/Double Click to Select the Stock Type',0)
GO
DELETE FROM RptFormula WHERE RptId = 245
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,1,'Disp_ToDate','As On Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,2,'Fill_ToDate','As On Date',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,3,'Disp_Company','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,4,'Fill_Company','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,5,'Disp_Location','Location',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,6,'Fill_Location','Location',1,22)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,7,'Disp_ProductCategoryLevel','Product Hierarchy Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,8,'Fill_ProductCategoryLevel','ProductCategoryLevel',1,16)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,9,'Disp_ProductCategoryValue','Product Hierarchy Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,10,'Fill_ProductCategoryValue','ProductCategoryLevelValue',1,21)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,11,'Disp_Product','Product',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,12,'Fill_Product','Product',1,5)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,13,'Disp_Batch','Stock Value as per',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,14,'Fill_Batch','Stock Value as per',1,209)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,15,'Disp_ProductStatus','Product Status',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,16,'Fill_ProductStatus','Product Status',1,210)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,17,'Disp_BatchStatus','Batch Status',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,18,'Fill_BatchStatus','Batch Status',1,211)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,19,'Disp_ProductDes','Product Description',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,20,'Disp_BatchT','Batch',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,21,'Disp_MRP','MRP',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,22,'Disp_RATE','Display Rate',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,23,'BOXES','BOXES',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,24,'Disp_StockValues','Gross Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,25,'PKTS','PKTS',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,26,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,27,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,28,'Disp_SupZeroStock','Suppress Zero Stock',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,29,'Fill_SupZeroStock','Suppress Zero Stock',1,44)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,30,'Product Name','Product Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,30,'Disp_Total','Grand Total',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,31,'ProductCode','Product Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,32,'Disp_StockType','Stock Type',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (245,33,'Fill_StockType','Stock Type',1,291)
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_GetStockLedgerSummaryDatewiseParle' AND XTYPE='P')
DROP PROCEDURE Proc_GetStockLedgerSummaryDatewiseParle
GO
--Exec Proc_GetStockLedgerSummaryDatewiseParle '2013-04-26','2013-04-26',1,0,0,0
--Select * From TempStockLedSummary where userid=1 and prdid in (3,20) and lcnid=8 and
--Select * From TempStockLedSummaryTotal
--SELECT * FROM StockLedger
CREATE PROCEDURE Proc_GetStockLedgerSummaryDatewiseParle
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
DECLARE @StockType AS NUMERIC(18,0)

IF EXISTS (SELECT DISTINCT SelValue FROM ReportFilterDt WHERE RptId = 245 AND SelId = 291 AND SelValue <> 0 AND UsrId = @Pi_UserId)
BEGIN 	
	SELECT @StockType = SystemStockType FROM ReportFilterDt A WITH (NOLOCK),StockType B WITH (NOLOCK) 
	WHERE A.SelValue = B.StockTypeId AND RptId = 245 AND SelId = 291 AND UsrId = @Pi_UserId
END
ELSE
BEGIN
   SET @StockType = 0
END
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
		(CASE @StockType WHEN 1 THEN Sl.SalOpenStock WHEN 2 THEN Sl.UnSalOpenStock WHEN 3 THEN Sl.OfferOpenStock
		ELSE (Sl.SalOpenStock+Sl.UnSalOpenStock+Sl.OfferOpenStock) END) AS Opening,
		(CASE @StockType WHEN 1 THEN Sl.SalPurchase WHEN 2 THEN Sl.UnsalPurchase WHEN 3 THEN Sl.OfferPurchase
		ELSE (Sl.SalPurchase+Sl.UnsalPurchase+Sl.OfferPurchase) END) AS Purchase,
		(CASE @StockType WHEN 1 THEN Sl.SalSales WHEN 2 THEN Sl.UnSalSales WHEN 3 THEN Sl.OfferSales
		ELSE (Sl.SalSales+Sl.UnSalSales+Sl.OfferSales) END) AS Sales,
		(CASE @StockType WHEN 1 THEN (-Sl.SalPurReturn+Sl.SalStockIn-Sl.SalStockOut+Sl.SalSalesReturn+Sl.SalStkJurIn-Sl.SalStkJurOut+
		Sl.SalBatTfrIn-Sl.SalBatTfrOut+Sl.SalLcnTfrIn-Sl.SalLcnTfrOut-Sl.SalReplacement)
		WHEN 2 THEN	(-Sl.UnSalPurReturn+Sl.UnSalStockIn-Sl.UnSalStockOut+Sl.UnSalSalesReturn+Sl.UnSalStkJurIn-Sl.UnSalStkJurOut+
		Sl.UnSalBatTfrIn-Sl.UnSalBatTfrOut+Sl.UnSalLcnTfrIn-Sl.UnSalLcnTfrOut+Sl.DamageIn-Sl.DamageOut)	
		WHEN 3 THEN	(-Sl.OfferPurReturn+Sl.OfferStockIn-Sl.OfferStockOut+Sl.OfferSalesReturn+Sl.OfferStkJurIn-Sl.OfferStkJurOut+
		Sl.OfferBatTfrIn-Sl.OfferBatTfrOut+Sl.OfferLcnTfrIn-Sl.OfferLcnTfrOut-Sl.OfferReplacement)
		ELSE(-Sl.SalPurReturn-Sl.UnsalPurReturn-Sl.OfferPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.OfferStockIn-
		Sl.SalStockOut-Sl.UnSalStockOut-Sl.OfferStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.OfferSalesReturn+
		Sl.SalStkJurIn+Sl.UnSalStkJurIn+Sl.OfferStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut-Sl.OfferStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn+Sl.OfferBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut-Sl.OfferBatTfrOut+
		Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn+Sl.OfferLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-Sl.OfferLcnTfrOut-
		Sl.SalReplacement-Sl.OfferReplacement+Sl.DamageIn-Sl.DamageOut)END) AS Adjustments,
		(CASE @StockType WHEN 1 THEN Sl.SalClsStock WHEN 2 THEN Sl.UnSalClsStock WHEN 3 THEN Sl.OfferClsStock
		ELSE (Sl.SalClsStock+Sl.UnSalClsStock+Sl.OfferClsStock) END) AS Closing,
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
		(CASE @StockType WHEN 1 THEN Sl.SalOpenStock WHEN 2 THEN Sl.UnSalOpenStock WHEN 3 THEN 0
		ELSE (Sl.SalOpenStock+Sl.UnSalOpenStock) END) AS Opening,
		(CASE @StockType WHEN 1 THEN Sl.SalPurchase WHEN 2 THEN Sl.UnsalPurchase WHEN 3 THEN 0
		ELSE (Sl.SalPurchase+Sl.UnsalPurchase) END) AS Purchase,
		(CASE @StockType WHEN 1 THEN Sl.SalSales WHEN 2 THEN Sl.UnSalSales WHEN 3 THEN 0
		ELSE (Sl.SalSales+Sl.UnSalSales) END) AS Sales,
		(CASE @StockType WHEN 1 THEN (-Sl.SalPurReturn+Sl.SalStockIn-Sl.SalStockOut+Sl.SalSalesReturn+Sl.SalStkJurIn-Sl.SalStkJurOut+
		Sl.SalBatTfrIn-Sl.SalBatTfrOut+Sl.SalLcnTfrIn-Sl.SalLcnTfrOut-Sl.SalReplacement)
		WHEN 2 THEN	(-Sl.UnSalPurReturn+Sl.UnSalStockIn-Sl.UnSalStockOut+Sl.UnSalSalesReturn+Sl.UnSalStkJurIn-Sl.UnSalStkJurOut+
		Sl.UnSalBatTfrIn-Sl.UnSalBatTfrOut+Sl.UnSalLcnTfrIn-Sl.UnSalLcnTfrOut+Sl.DamageIn-Sl.DamageOut)	
		WHEN 3 THEN	0 ELSE(-Sl.SalPurReturn-Sl.UnsalPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.SalStockOut-Sl.UnSalStockOut
		+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.SalStkJurIn+Sl.UnSalStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut+Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-
		Sl.SalReplacement+Sl.DamageIn-Sl.DamageOut)END) AS Adjustments,
		(CASE @StockType WHEN 1 THEN Sl.SalClsStock WHEN 2 THEN Sl.UnSalClsStock WHEN 3 THEN 0
		ELSE (Sl.SalClsStock+Sl.UnSalClsStock) END) AS Closing,
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
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN ISNULL(Sl.OfferClsStock,0)
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) END) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN ISNULL(Sl.OfferClsStock,0)
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) END) AS Closing,
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
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN 0
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) END) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN 0
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) END) AS Closing,
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
		
	
	INSERT INTO TempStockLedSummary(PrdId,PrdBatId,LcnId,Opening,Purchase,Sales,Adjustment,Closing,
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
	UPDATE TempStockLedSummary SET Purchase=TotPur,Sales=TotSal,
	Adjustment=TotAdj
	FROM #TemDetails T
	WHERE T.PrdId=TempStockLedSummary.PrdId AND T.PrdBatId=TempStockLedSummary.PrdBatId AND
	T.LcnId=TempStockLedSummary.LcnId
	UPDATE TempStockLedSummary SET Closing=Opening+Purchase-Sales+Adjustment
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
DELETE FROM CustomCaptions WHERE TransId = 91 AND CtrlId = 45 AND SubCtrlId = 27
INSERT INTO CustomCaptions  
SELECT 91,45,27,'DGCommon-91-45-27','Product Short Name *','','',1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,
CONVERT(NVARCHAR(10),GETDATE(),121),'Product Short Name *','','',1,1
GO
DELETE FROM FieldLevelAccessDt WHERE TransId = 91 AND CtrlId = 100002
INSERT INTO FieldLevelAccessDt (PrfId,TransId,CtrlId,AccessSts,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT DISTINCT PrfId,91,'100002',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHd WITH (NOLOCK)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE = 'U' AND name = 'BotreeAddress')
DROP TABLE BotreeAddress
GO
CREATE TABLE BotreeAddress
(  
 [Address] NVARCHAR(4000),
 [Email] NVARCHAR(1000),
 [Status] INT
)
GO
DELETE FROM BotreeAddress
INSERT INTO BotreeAddress ([Address],[Email],[Status])
SELECT '                 Developed By :  Botree Software International Private Limited                                                        37, Nelson Manickam Road                                                                                         Chennai - 600029                                                                                                            +91-44-23741591                                                                                                                                                                                                                ','E-mail              :      corestockysupport@botree.co.in',0 UNION
SELECT '                 Developed By :  Botree Software International Private Limited                                                       Second Floor, WSS Towers,No.107,Harris Road,                                                                      Chennai - 600002                                                                                                            +91-44-28551591                                                                                                                                                                                                                ','E-mail              :      corestockysupport@botree.co.in',1
GO
IF NOT EXISTS (SELECT Name FROM Syscolumns WHERE ID IN (SELECT ID FROM sysobjects WHERE name = 'SpecialRateAftDownLoad' AND Xtype = 'U') 
AND Name ='ConSplSelRate')
BEGIN
    ALTER TABLE SpecialRateAftDownLoad ADD ConSplSelRate NUMERIC(18,6) DEFAULT 0 WITH VALUES
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TempProductTax')
DROP TABLE TempProductTax
GO
CREATE TABLE [TempProductTax](
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[TaxId] [int] NULL,
	[TaxSlabId] [int] NULL,
	[TaxPercentage] [numeric](5, 2) NULL,
	[TaxAmount] [numeric](18, 5) NULL
)
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='ProductBatchTaxPercent')
DROP TABLE ProductBatchTaxPercent
GO
CREATE TABLE [ProductBatchTaxPercent](
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[TaxPercentage] [numeric](18, 5) NULL
)
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XType='P' AND name='Proc_TaxCalCulation')
DROP PROCEDURE Proc_TaxCalCulation
GO
--Exec Proc_TaxCalCulation 395,4833
CREATE PROCEDURE Proc_TaxCalCulation
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
		--SELECT @RtrTaxGrp=MIN(Distinct RtriD) FROM TaxSettingMaster (NOLOCK)
		--Added By Sathishkumar Veeramani 2013/07/10
		SELECT @RtrTaxGrp=MIN(DISTINCT RtriD) FROM TaxSettingMaster (NOLOCK) WHERE PrdId = @PrdBatTaxGrp
		--Till Here
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
		    
		--Set @TaxableAmount = @TaxableAmount + @ParTaxableAmount      
		--Insert the New Tax Amounts  
		
		
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
IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='RET8' AND ModuleName='Retailer')
BEGIN
DELETE FROM Configuration WHERE ModuleId='RET8' AND ModuleName='Retailer'
INSERT INTO Configuration Values('RET8','Retailer','Always use default Geography Level as...',1,'Territory',5.00,8) 
END
GO
DELETE FROM PurchaseSequenceDetail
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,1,'A','Default','LSP','',-1,0,0,1,0,0,1,0,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,2,'B','Default','Gross Amount','',-1,0,0,1,0,0,1,0,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,4,'C','Default','Disc','',-1,0,0,1,1,2,1,250,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,5,'E','Default','FreightCharges','',-1,0,0,1,1,1,1,311,1,1,'2012-12-31',1,'2012-12-31')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,6,'F','KG','Qty in Kg','',-1,0,0,0,0,0,1,0,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,7,'G','Default','CD Disc','',-1,0,0,0,1,2,0,250,1,1,'2009-10-07',1,'2009-10-07')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,8,'D','Default','Tax','',-1,0,0,1,0,1,1,0,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,9,'H','BED','BED','',-1,0,0,0,0,1,1,0,1,1,'2009-06-20',1,'2009-06-20')
INSERT INTO PurchaseSequenceDetail([PurSeqId],[SlNo],[RefCode],[ColumnName],[FieldDesc],[Calculation],[MasterID],[BatchSeqId],[DefaultValue],[DisplayIn],[Editable],[EffectInNetAmount],[Visibility],[CoaId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate]) 
VALUES (1,10,'I','CESS','CESS','{H}*(3/100)',-1,0,0,0,0,1,1,0,1,1,'2009-06-20',1,'2009-06-20')
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE id IN(SELECT id FROM SYSOBJECTS WHERE XTYPE='U' AND name ='ETLTempPurchaseReceiptProduct') AND name='FreightCharges' )
ALTER TABLE ETLTempPurchaseReceiptProduct ADD FreightCharges NUMERIC (38,6) DEFAULT 0 WITH VALUES
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE id IN(SELECT id FROM SYSOBJECTS WHERE XTYPE='U' AND name ='ETL_Prk_PurchaseReceiptPrdDt') AND name='FreightCharges' )
ALTER TABLE ETL_Prk_PurchaseReceiptPrdDt ADD FreightCharges NUMERIC (38,6) DEFAULT 0 WITH VALUES
GO
IF NOT EXISTS (SELECT * FROM SYSCOLUMNS WHERE id IN(SELECT id FROM SYSOBJECTS WHERE XTYPE='U' AND name ='PurchaseReceiptProduct') AND name='FreightCharges' )
ALTER TABLE PurchaseReceiptProduct ADD FreightCharges NUMERIC (38,6) DEFAULT 0 WITH VALUES
GO
IF NOT EXISTS(SELECT * FROM Sysobjects So INNER JOIN Syscolumns Sc On So.id=Sc.id AND So.name='ETLTempPurchaseReceiptProduct' AND Sc.name='PrdBEDAmount')
BEGIN
ALTER TABLE ETLTempPurchaseReceiptProduct Add PrdBEDAmount NUMERIC(38,6) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM Sysobjects WHERE id IN (SELECT id FROM Syscolumns WHERE name='PrdBEDAmount') AND Name='PurchaseReceiptproduct' AND Xtype='U')
BEGIN 
	ALTER TABLE PurchaseReceiptproduct ADD PrdBEDAmount Numeric(18,6) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM Sysobjects WHERE id IN (SELECT id FROM Syscolumns WHERE name='PrdCESSAmount') AND Name='PurchaseReceiptproduct' AND Xtype='U')
BEGIN 
	ALTER TABLE PurchaseReceiptproduct ADD PrdCESSAmount Numeric(18,6) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT NAME FROM Sysobjects WHERE id IN (SELECT id FROM Syscolumns WHERE name='PurBEDAmount') AND Name='PurchaseReceipt' AND Xtype='U')
BEGIN 
	ALTER TABLE PurchaseReceipt ADD PurBEDAmount Numeric(18,6) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT * FROM Sysobjects So INNER JOIN Syscolumns Sc On So.id=Sc.id AND So.name='ETLTempPurchaseReceiptProduct' AND Sc.name='QtyInKg')
BEGIN
    ALTER TABLE ETLTempPurchaseReceiptProduct Add QtyInKg NUMERIC(38,6) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT * FROM Sysobjects So INNER JOIN Syscolumns Sc On So.id=Sc.id AND So.name='PurchaseReceiptProduct' AND Sc.name='QtyInKg')
BEGIN
    ALTER TABLE PurchaseReceiptProduct Add QtyInKg NUMERIC(38,6) DEFAULT 0 WITH VALUES
END
GO
INSERT INTO PurchaseReceiptHdAmount
SELECT DISTINCT PurRcptId,'E',0,1,3,CONVERT(NVARCHAR(10),GETDATE(),121),3,CONVERT(NVARCHAR(10),GETDATE(),121) FROM PurchaseReceiptHdAmount WITH (NOLOCK)
WHERE PurRcptId NOT IN (SELECT DISTINCT PurRcptId FROM PurchaseReceiptLineAmount WITH (NOLOCK) WHERE RefCode = 'E') UNION
SELECT DISTINCT PurRcptId,'F',0,1,3,CONVERT(NVARCHAR(10),GETDATE(),121),3,CONVERT(NVARCHAR(10),GETDATE(),121) FROM PurchaseReceiptHdAmount WITH (NOLOCK)
WHERE PurRcptId NOT IN (SELECT DISTINCT PurRcptId FROM PurchaseReceiptLineAmount WITH (NOLOCK) WHERE RefCode = 'F') UNION
SELECT DISTINCT PurRcptId,'G',0,1,3,CONVERT(NVARCHAR(10),GETDATE(),121),3,CONVERT(NVARCHAR(10),GETDATE(),121) FROM PurchaseReceiptHdAmount WITH (NOLOCK)
WHERE PurRcptId NOT IN (SELECT DISTINCT PurRcptId FROM PurchaseReceiptLineAmount WITH (NOLOCK) WHERE RefCode = 'G') UNION
SELECT DISTINCT PurRcptId,'H',0,1,3,CONVERT(NVARCHAR(10),GETDATE(),121),3,CONVERT(NVARCHAR(10),GETDATE(),121) FROM PurchaseReceiptHdAmount WITH (NOLOCK)
WHERE PurRcptId NOT IN (SELECT DISTINCT PurRcptId FROM PurchaseReceiptLineAmount WITH (NOLOCK) WHERE RefCode = 'H') UNION
SELECT DISTINCT PurRcptId,'I',0,1,3,CONVERT(NVARCHAR(10),GETDATE(),121),3,CONVERT(NVARCHAR(10),GETDATE(),121) FROM PurchaseReceiptHdAmount WITH (NOLOCK)
WHERE PurRcptId NOT IN (SELECT DISTINCT PurRcptId FROM PurchaseReceiptLineAmount WITH (NOLOCK) WHERE RefCode = 'I')
GO
INSERT INTO PurchaseReceiptLineAmount (PurRcptId,PrdSlNo,RefCode,LineDefValue,LineUnitAmount,LineBaseQtyAmount,LineUnitPerc,LineBaseQtyPerc,
LineEffectAmount,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT DISTINCT PurRcptId,PrdSlNo,'E',0,0,0,0,0,0,1,3,CONVERT(NVARCHAR(10),GETDATE(),121),3,CONVERT(NVARCHAR(10),GETDATE(),121) 
FROM PurchaseReceiptLineAmount WITH (NOLOCK)
WHERE PurRcptId NOT IN (SELECT DISTINCT PurRcptId FROM PurchaseReceiptLineAmount WITH (NOLOCK) WHERE RefCode = 'E') UNION
SELECT DISTINCT PurRcptId,PrdSlNo,'F',0,0,0,0,0,0,1,3,CONVERT(NVARCHAR(10),GETDATE(),121),3,CONVERT(NVARCHAR(10),GETDATE(),121) 
FROM PurchaseReceiptLineAmount WITH (NOLOCK)
WHERE PurRcptId NOT IN (SELECT DISTINCT PurRcptId FROM PurchaseReceiptLineAmount WITH (NOLOCK) WHERE RefCode = 'F') UNION
SELECT DISTINCT PurRcptId,PrdSlNo,'G',0,0,0,0,0,0,1,3,CONVERT(NVARCHAR(10),GETDATE(),121),3,CONVERT(NVARCHAR(10),GETDATE(),121) 
FROM PurchaseReceiptLineAmount WITH (NOLOCK)
WHERE PurRcptId NOT IN (SELECT DISTINCT PurRcptId FROM PurchaseReceiptLineAmount WITH (NOLOCK) WHERE RefCode = 'G') UNION
SELECT DISTINCT PurRcptId,PrdSlNo,'H',0,0,0,0,0,0,1,3,CONVERT(NVARCHAR(10),GETDATE(),121),3,CONVERT(NVARCHAR(10),GETDATE(),121) 
FROM PurchaseReceiptLineAmount WITH (NOLOCK)
WHERE PurRcptId NOT IN  (SELECT DISTINCT PurRcptId FROM PurchaseReceiptLineAmount WITH (NOLOCK) WHERE RefCode = 'H') UNION
SELECT DISTINCT PurRcptId,PrdSlNo,'I',0,0,0,0,0,0,1,3,CONVERT(NVARCHAR(10),GETDATE(),121),3,CONVERT(NVARCHAR(10),GETDATE(),121) 
FROM PurchaseReceiptLineAmount WITH (NOLOCK)
WHERE PurRcptId NOT IN (SELECT DISTINCT PurRcptId FROM PurchaseReceiptLineAmount WITH (NOLOCK) WHERE RefCode = 'I')
GO
DELETE FROM CustomCaptions WHERE TransId = 226 AND CtrlId = 1 AND SubCtrlId IN (1,2)
INSERT INTO Customcaptions
SELECT 226,1,1,'CoreHeaderTool','Complementary Invoice','','',1,1,1,GETDATE(),1,GETDATE(),'Complementary Invoice','','',1,1 UNION
SELECT 226,1,2,'CoreHeaderTool','Stocky','','',1,1,1,GETDATE(),1,GETDATE(),'Stocky','','',1,1
GO
DELETE FROM Menudef WHERE MenuId = 'mCus36'
INSERT INTO Menudef
SELECT 49,'mCus36','mnuSampleMgmt','mCus','Complementary Invoice',0,'frmSampleMaintenance','Complementary Invoice'
GO
DELETE FROM ProfileDt WHERE MenuId = 'mCus36'
INSERT INTO ProfileDt
SELECT DISTINCT PrfId,'mCus36',0,'New',1,1,1,'2013-05-29',1,'2013-05-29'FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mCus36',1,'Edit',1,1,1,'2013-05-29',1,'2013-05-29'FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mCus36',2,'Save',1,1,1,'2013-05-29',1,'2013-05-29'FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mCus36',6,'Print',1,1,1,'2013-05-29',1,'2013-05-29'FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mCus36',7,'Save & Confirm',1,1,1,'2013-05-29',1,'2013-05-29'FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mCus36',8,'Sample Issue Load',1,1,1,'2013-05-29',1,'2013-05-29'FROM ProfileHD WITH (NOLOCK) UNION
SELECT DISTINCT PrfId,'mCus36',9,'Sample Return Load',1,1,1,'2013-05-29',1,'2013-05-29'FROM ProfileHD WITH (NOLOCK)
GO
DELETE FROM HotSearchEditorhd WHERE FormId=888
INSERT INTO HotSearchEditorhd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (888,'Sample Receipt','Download Invoice','select','Select Distinct [CompanyInvoiceNo] CmpInvNo,InvoiceDate Date  From TempSamplePurchaseReceipt  Where [CompanyInvoiceNo] Not In ( Select CmpInvNo from SamplePurchaseReceipt) and  DownloadFlag = ''Y''  order  by [CompanyInvoiceNo]')
GO
DELETE FROM HotSearchEditorDt WHERE Formid=888
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES (1,888,'Download Invoice','Invoice No','CmpInvNo',2000,0,'HotSch-226-2000-190',226)
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId]) VALUES (2,888,'Download Invoice','Invoice Date','Date',2250,0,'HotSch-226-2000-191',226)
GO
DELETE FROM CustomCaptions WHERE TransId=226 AND CtrlName='HotSch-226-2000-190'
INSERT INTO customcaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (226,2000,190,'HotSch-226-2000-190','Invoice No','','',1,1,1,'2011-08-27',1,'2011-08-27','Company Invoice No ','','',1,1)
GO
DELETE FROM CustomCaptions WHERE TransId=226 AND CtrlName='HotSch-226-2000-191'
INSERT INTO customcaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (226,2000,191,'HotSch-226-2000-191','Invoice Date','','',1,1,1,'2011-08-27',1,'2011-08-27','Invoice Date ','','',1,1)
GO
DELETE FROM CustomCaptions WHERE TransId=226 AND CtrlName='PnlMsg-226-1000-24'
INSERT INTO customcaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (226,1000,24,'PnlMsg-226-1000-24','','No Records Found','',1,1,1,'2009-06-07',1,'2009-06-07','','No Records Found','',1,1)
GO
DELETE FROM ScreenDefaultValues WHERE TransId = 79 AND CtrlId = 164
INSERT INTO ScreenDefaultValues
SELECT 79,164,0,'PENDING',0,1,1,1,GETDATE(),1,GETDATE(),'PENDING' UNION
SELECT 79,164,1,'APPROVED',1,1,1,1,GETDATE(),1,GETDATE(),'APPROVED' UNION
SELECT 79,164,2,'REJECTED',2,1,1,1,GETDATE(),1,GETDATE(),'REJECTED'
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE XTYPE IN ('TF','FN') AND name = 'Fn_FillRetailerDetailsinRetailerMaster')
DROP FUNCTION Fn_FillRetailerDetailsinRetailerMaster
GO
CREATE FUNCTION Fn_FillRetailerDetailsinRetailerMaster(@Pi_TransId INT,@Pi_LgnId INT)
RETURNS @FillRetailerDetails TABLE
(
RtrId	INT,
RtrCode	NVARCHAR(100),
RtrName	NVARCHAR(100),
RtrAdd1	NVARCHAR(100),
RtrAdd2	NVARCHAR(100),
RtrAdd3	NVARCHAR(100),
RtrPinNo	INT,
RtrPhoneNo	NVARCHAR(100),
RtrEmailId	NVARCHAR(100),
RtrContactPerson	NVARCHAR(100),
RtrKeyAcc	NVARCHAR(100),
RtrCovMode	NVARCHAR(100),
RtrRegDate	DATETIME,
RtrDepositAmt	NUMERIC(18,2),
RtrStatus	NVARCHAR(100),
RtrTaxable	NVARCHAR(100),
RtrTaxType	NVARCHAR(100),
TaxGroupName	NVARCHAR(100),
RtrTINNo	NVARCHAR(100),
RtrCSTNo	NVARCHAR(100),
RtrDayOff	NVARCHAR(100),
RtrCrBills	INT,
RtrCrLimit	NUMERIC(18,2),
RtrCrDays	INT,
RtrCashDiscPerc	NUMERIC(18,2),
RtrCashDiscCond	VARCHAR(50),
RtrCashDiscAmt	NUMERIC(18,2),
RtrLicNo	NVARCHAR(100),
RtrLicExpiryDate	DATETIME,
RtrDrugLicNo	NVARCHAR(100),
RtrDrugExpiryDate	DATETIME,
RtrPestLicNo	NVARCHAR(100),
RtrPestExpiryDate	DATETIME,
GeoMainId	INT,
GeoName	NVARCHAR(100),
GeoLevelName	NVARCHAR(100),
RmId	INT,
RMName	NVARCHAR(100),
VillageId	INT,
VillageName	NVARCHAR(100),
RtrShipId	INT,
RtrShipAdd1	NVARCHAR(100),
RtrShipAdd2	NVARCHAR(100),
RtrShipAdd3	NVARCHAR(100),
RtrShipPinNo	INT,
RtrResPhone1	NVARCHAR(100),
RtrResPhone2	NVARCHAR(100),
RtrOffPhone1	NVARCHAR(100),
RtrOffPhone2	NVARCHAR(100),
RtrDOB	DATETIME,
RtrAnniversary	DATETIME,
RtrRemark1	NVARCHAR(100),
RtrRemark2	NVARCHAR(100),
RtrRemark3	NVARCHAR(100),
COAId	INT,
OnAccount	NUMERIC(18,2),
TaxGroupId	INT,
RtrType	NVARCHAR(100),
RtrFrequency	TINYINT,
RtrCrBillsAlert	TINYINT,
RtrCrLimitAlert	TINYINT,
RtrCrDaysAlert	TINYINT,
RtrKeyId	TINYINT,
RtrCoverageId	TINYINT,
RtrStatusId	TINYINT,
RtrDayOffId	INT,
RtrTaxableId	TINYINT,
RtrTaxTypeId	TINYINT,
RtrTypeId	TINYINT,
RtrRlStatus	NVARCHAR(100),
RlStatus	TINYINT,
CmpRtrCode	NVARCHAR(100),
Upload	NVARCHAR(10),
RtrPayment NVARCHAR(100),
RtrPaymentId INT,
RtrApproval NVARCHAR(100),
RtrApprovalId INT
)
AS
BEGIN
	INSERT INTO @FillRetailerDetails (RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrPhoneNo,RtrEmailId,RtrContactPerson,RtrKeyAcc,
    RtrCovMode,RtrRegDate,RtrDepositAmt,RtrStatus,RtrTaxable,RtrTaxType,TaxGroupName,RtrTINNo,RtrCSTNo,RtrDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,
    RtrCashDiscPerc,RtrCashDiscCond,RtrCashDiscAmt,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,GeoMainId,
    GeoName,GeoLevelName,RmId,RMName,VillageId,VillageName,RtrShipId,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipPinNo,RtrResPhone1,RtrResPhone2,
    RtrOffPhone1,RtrOffPhone2,RtrDOB,RtrAnniversary,RtrRemark1,RtrRemark2,RtrRemark3,COAId,OnAccount,TaxGroupId,RtrType,RtrFrequency,RtrCrBillsAlert,
    RtrCrLimitAlert,RtrCrDaysAlert,RtrKeyId,RtrCoverageId,RtrStatusId,RtrDayOffId,RtrTaxableId,RtrTaxTypeId,RtrTypeId,RtrRlStatus,RlStatus,
    CmpRtrCode,Upload,RtrPayment,RtrPaymentId,RtrApproval,RtrApprovalId)
    
    SELECT Rt.RtrId,Rt.RtrCode,Rt.RtrName,Rt.RtrAdd1,Rt.RtrAdd2,Rt.RtrAdd3,Rt.RtrPinNo,Rt.RtrPhoneNo,Rt.RtrEmailId,Rt.RtrContactPerson, 
	ISNULL(SD1.CtrlDesc,'') AS RtrKeyAcc, ISNULL(SD2.CtrlDesc,'') AS RtrCovMode,Rt.RtrRegDate,Rt.RtrDepositAmt,ISNULL(SD3.CtrlDesc,'') AS RtrStatus, 
	ISNULL(SD4.CtrlDesc,'') AS RtrTaxable, ISNULL(SD5.CtrlDesc,'') AS RtrTaxType,ISNULL(TG.TaxGroupName,'') AS  TaxGroupName,
	Rt.RtrTINNo,Rt.RtrCSTNo, ISNULL(SD6.CtrlDesc,'') AS RtrDayOff, Rt.RtrCrBills,Rt.RtrCrLimit,Rt.RtrCrDays, Rt.RtrCashDiscPerc,  
	(CASE Rt.RtrCashDiscCond WHEN 1 THEN '>=' WHEN 0 THEN '<=' End)As RtrCashDiscCond,Rt.RtrCashDiscAmt,
	Rt.RtrLicNo,Rt.RtrLicExpiryDate,Rt.RtrDrugLicNo,Rt.RtrDrugExpiryDate,Rt.RtrPestLicNo,Rt.RtrPestExpiryDate,
	GE.GeoMainId,GE.GeoName,Gl.GeoLevelName,Rm.RmId,Rm.RMName,Rv.VillageId,Rv.VillageName,Rs.RtrShipId,
	Rs.RtrShipAdd1,Rs.RtrShipAdd2,Rs.RtrShipAdd3,Rs.RtrShipPinNo,Rt.RtrResPhone1,Rt.RtrResPhone2,Rt.RtrOffPhone1,Rt.RtrOffPhone2,
	Rt.RtrDOB,Rt.RtrAnniversary,Rt.RtrRemark1,Rt.RtrRemark2,Rt.RtrRemark3
	,Rt.COAId ,Rt.RtrOnAcc as OnAccount,Rt.TaxGroupId,  ISNULL(SD7.CtrlDesc,'') AS RtrType, Rt.RtrFrequency , 
	Rt.RtrCrBillsAlert, Rt.RtrCrLimitAlert, Rt.RtrCrDaysAlert, Rt.RtrKeyAcc AS RtrKeyId,Rt.RtrCovMode AS RtrCoverageId,Rt.RtrStatus 
	AS RtrStatusId,Rt.RtrDayOff AS RtrDayOffId, Rt.RtrTaxable AS RtrTaxableId,Rt.RtrTaxType AS RtrTaxTypeId,Rt.RtrType AS RtrTypeId ,
	ISNULL(SD8.CtrlDesc,'') AS RtrRlStatus,ISNULL(Rt.RtrRlStatus,1) AS RlStatus,Rt.CmpRtrCode,Rt.Upload ,
	ISNULL(SD9.CtrlDesc,'') AS RtrPayment,Rt.RtrPayment AS RtrPayModeId,ISNULL(SD10.CtrlDesc,'') AS RtrApproval,Rt.Approved AS RtrApprovalId 
	FROM GeographyLevel Gl,Retailer Rt  
	LEFT OUTER JOIN Geography Ge ON GE.GeoMainId=Rt.GeoMainId  
	LEFT OUTER JOIN RouteMaster Rm ON Rm.RMId=Rt.RMId  
	LEFT OUTER JOIN RouteVillage Rv ON Rv.VillageId=Rt.VillageId  
	LEFT OUTER JOIN RetailerShipAdd Rs ON Rs.RtrShipId=Rt.RtrShipId  
	LEFT OUTER JOIN TaxGroupSetting TG ON TG.TaxGroupId=Rt.TaxGroupId  
	LEFT OUTER JOIN ScreenDefaultValues SD1 ON SD1.CtrlValue=Rt.RtrKeyAcc AND SD1.CtrlId=10 AND SD1.TransId=@Pi_TransId AND SD1.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD2 ON SD2.CtrlValue=Rt.RtrCovMode AND SD2.CtrlId=11 AND SD2.TransId=@Pi_TransId AND SD2.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD3 ON SD3.CtrlValue=Rt.RtrStatus AND SD3.CtrlId=14 AND SD3.TransId=@Pi_TransId AND SD3.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD4 ON SD4.CtrlValue=Rt.RtrTaxable AND SD4.CtrlId=18 AND SD4.TransId=@Pi_TransId AND SD4.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD5 ON SD5.CtrlValue=Rt.RtrTaxType AND SD5.CtrlId=19 AND SD5.TransId=@Pi_TransId AND SD5.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD6 ON SD6.CtrlValue=Rt.RtrDayOff AND SD6.CtrlId=13 AND SD6.TransId=@Pi_TransId AND SD6.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD7 ON SD7.CtrlValue=Rt.RtrType AND SD7.CtrlId=56 AND SD7.TransId=@Pi_TransId AND SD7.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD8 ON SD8.CtrlValue=Rt.RtrRlStatus AND SD8.CtrlId=135 AND SD8.TransId=@Pi_TransId AND SD8.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD9 ON SD9.CtrlValue=Rt.RtrPayment AND SD9.CtrlId=163 AND SD9.TransId=@Pi_TransId AND SD9.LngId=@Pi_LgnId 
	LEFT OUTER JOIN ScreenDefaultValues SD10 ON SD10.CtrlValue=Rt.Approved AND SD10.CtrlId=164 AND SD10.TransId=@Pi_TransId AND SD10.LngId=@Pi_LgnId 
	WHERE GE.GeoLevelId = Gl.GeoLevelId
RETURN
END
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 404',404
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 404)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(404,'D','2013-09-05',GETDATE(),1,'Core Stocky Service Pack 404')
GO