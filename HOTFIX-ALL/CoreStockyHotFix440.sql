--[Stocky HotFix Version]=440
DELETE FROM Versioncontrol WHERE Hotfixid='440'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('440','3.1.0.17','D','2019-05-02','2019-05-02','2019-05-02',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Jan 2019')
GO
/*
ILCRSTPAR3143	-->	Month end Issue (Only Exe)
CRCRSTPAR0039	--> Trade Scheme calculation Based on Cap Amount
ILCRSTPAR3405	--> Billtemplate Invoice No Lenght Increase
ILCRSTPAR3516	--> manual claim one month date range validation included from CS.
ILCRSTPAR4010   --> while select bilss delivery or undelivery bills Default bill print validation included in CS. (Only Exe)
ILCRSTPAR4044	--> product default price new column added,Quick sync process sync status validation included
CRCRSTPAR0042   --> In Report Grand Total values added report wise. (ILCRSTPAR4201)
---Scrpit Updater Scrpits
Fn_ValidateClaimMonthEndDate,Cs2Cn_Prk_GSTInvoiceNumberCorrection,
Proc_Cs2Cn_GSTInvoiceNumberCorrection,GSTSalesInvoiceNoCorrection,Proc_GSTInvoiceNumberCorrection,
Proc_RptClaimTopSheet,Proc_Cs2Cn_SalesReturn,Proc_ValidateDayEndProcess,Proc_Cn2Cs_RetailerMigration,
Proc_Export_CS2WS_PricingPlan,Proc_Export_CS2WS_Customer,Proc_Export_CS2WS_ProductGroup,
Proc_Export_CS2WS_RouteTarget,Fn_ReturnManualClmDesc,CS2CN_RetailerReupload_New,Cs2Cn_Prk_DistributorCodeSwapConfirm_Track,
Proc_Cs2Cn_DistributorCodeSwapConfirm,Proc_ProductWiseSalesOnlyParle,
Proc_Cn2Cs_Product,Proc_Export_CS2WS_RouteSetupV1,Proc_Cn2Cs_PurchaseReceipt,Proc_RptCmpWisePurchase,
Proc_Export_CS2WS_CreditDetails,Proc_Import_SchemeCategoryDetails,Proc_Cn2Cs_BLSchemeAttributes,
Fn_SFAProductToSend,Proc_Cs2Cn_Retailer_RetailerUpload,Proc_Cs2Cn_DebitNoteTopSheet2,
Proc_Cs2Cn_DebitNoteTopSheet4,Proc_Cn2Cs_SchemeCategoryDetails,Proc_RptSchemeUtilization_Parle,
Proc_ValidateCSTimer
*/
--CRCRSTPAR0039	(Trade Scheme calculation Based on Cap Amount)
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='NoOfMonth' AND ID=OBJECT_ID('SchemeMaster'))
BEGIN
ALTER TABLE SchemeMaster ADD NoOfMonth TINYINT DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='Growth_Factor' AND ID=OBJECT_ID('SchemeMaster'))
BEGIN
ALTER TABLE SchemeMaster ADD Growth_Factor NUMERIC(18,2) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='Add_Growth_Factor' AND ID=OBJECT_ID('SchemeMaster'))
BEGIN
ALTER TABLE SchemeMaster ADD Add_Growth_Factor NUMERIC(18,2) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='Validate_Cap' AND ID=OBJECT_ID('SchemeMaster'))
BEGIN
ALTER TABLE SchemeMaster ADD Validate_Cap TINYINT DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='Cap_Amount' AND ID=OBJECT_ID('SchemeMaster'))
BEGIN
ALTER TABLE SchemeMaster ADD Cap_Amount NUMERIC(18,2) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='NoOfMonth' AND ID=OBJECT_ID('ETL_Prk_SchemeMaster_Temp'))
BEGIN
ALTER TABLE ETL_Prk_SchemeMaster_Temp ADD NoOfMonth TINYINT DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='Growth_Factor' AND ID=OBJECT_ID('ETL_Prk_SchemeMaster_Temp'))
BEGIN
ALTER TABLE ETL_Prk_SchemeMaster_Temp ADD Growth_Factor NUMERIC(18,2) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='Add_Growth_Factor' AND ID=OBJECT_ID('ETL_Prk_SchemeMaster_Temp'))
BEGIN
ALTER TABLE ETL_Prk_SchemeMaster_Temp ADD Add_Growth_Factor NUMERIC(18,2) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='Validate_Cap' AND ID=OBJECT_ID('ETL_Prk_SchemeMaster_Temp'))
BEGIN
ALTER TABLE ETL_Prk_SchemeMaster_Temp ADD Validate_Cap Varchar(10)
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='Cap_Amount' AND ID=OBJECT_ID('ETL_Prk_SchemeMaster_Temp'))
BEGIN
ALTER TABLE ETL_Prk_SchemeMaster_Temp ADD Cap_Amount NUMERIC(18,2) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='NoOfMonth' AND ID=OBJECT_ID('Etl_Prk_SchemeHD_Slabs_Rules'))
BEGIN
ALTER TABLE Etl_Prk_SchemeHD_Slabs_Rules ADD NoOfMonth TINYINT DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='Growth_Factor' AND ID=OBJECT_ID('Etl_Prk_SchemeHD_Slabs_Rules'))
BEGIN
ALTER TABLE Etl_Prk_SchemeHD_Slabs_Rules ADD Growth_Factor NUMERIC(18,2) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='Add_Growth_Factor' AND ID=OBJECT_ID('Etl_Prk_SchemeHD_Slabs_Rules'))
BEGIN
ALTER TABLE Etl_Prk_SchemeHD_Slabs_Rules ADD Add_Growth_Factor NUMERIC(18,2) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='Validate_Cap' AND ID=OBJECT_ID('Etl_Prk_SchemeHD_Slabs_Rules'))
BEGIN
ALTER TABLE Etl_Prk_SchemeHD_Slabs_Rules ADD Validate_Cap Varchar(10)
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSCOLUMNS WHERE  name='Cap_Amount' AND ID=OBJECT_ID('Etl_Prk_SchemeHD_Slabs_Rules'))
BEGIN
ALTER TABLE Etl_Prk_SchemeHD_Slabs_Rules ADD Cap_Amount NUMERIC(18,2) DEFAULT 0 WITH VALUES
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='TF' AND NAME='Fn_RetrunPurchaseSchemeTarget')
DROP FUNCTION Fn_RetrunPurchaseSchemeTarget
GO
CREATE FUNCTION [Fn_RetrunPurchaseSchemeTarget](@Pi_Schid AS INT,@Pi_Salid AS BIGINT,@Pi_TransId AS INT,@Pi_UsrId AS INT,@Pi_EditMode AS TINYINT)
RETURNS @SchemeTarget TABLE
(
 SchemeExists TINYINT,
 Targetvalue NUMERIC(23,6),
 Applicable TINYINT
 )
/*************************************************************************************
* FUNCTION: Fn_RetrunPurchaseSchemeTarget
* PURPOSE: Return Cap amount balance
* NOTES:
* CREATED: Mary
* MODIFIED
* DATE      AUTHOR		USER STORY ID	[CR/BUG]	DESCRIPTION
----------------------------------------------------------------------------------------
* 11/04/2019 MARY	CRCRSTPAR0039		CR			Return Cap amount balance	
*************************************************************************************/
AS
BEGIN
	DECLARE @TargetValue AS Numeric(38,6)
	DECLARE @TargetValueUtilized AS Numeric(38,6)
	DECLARE @FromDate DATETIME
	DECLARE @ToDate DATETIME
	DECLARE @SalesValue NUMERIC(24,6)
	DECLARE @ReturnValue NUMERIC(24,6)
	DECLARE @Growth_Factor NUMERIC(18,2)
	DECLARE @Add_Growth_Factor NUMERIC(18,2)
	DECLARE @NoofMonth TINYINT
	DECLARE @SchemeOnAmount AS NUMERIC(18,6)
	DECLARE @CapAmount AS NUMERIC(18,6)

	DECLARE @FreeScheme TABLE 
	(
		SchId  INT
	)
	INSERT INTO @FreeScheme 
	SELECT SchId FROM SchemeSlabFrePrds  WHERE SchId=@Pi_Schid UNION 
	SELECT SchId  FROM SchemeSlabMultiFrePrds   WHERE SchId=@Pi_Schid

	SET @TargetValue=0
	
	----IF @Pi_EditMode<=1 --AND @Pi_TransId=2 
	----BEGIN
	----	SET @Pi_Salid=0
	----END

	/* ONLY DISCOUNT SCHEME AND FREE SCHEME /QPS Combi flexi scheme not applicable cap amount validation
	 mail date 09/04/2019 to Saravana Kumar
	*/ 
	IF NOT EXISTS (SELECT 'X' FROM @FreeScheme)
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM SchemeMaster A (NOLOCK) 
		INNER JOIN SchemeCategorydetails B (NOLOCK) ON A.cmpschcode=B.Cmpschcode
		INNER JOIN SchemeSlabs C (NOLOCK) ON A.Schid=C.Schid
		WHERE A.schId=@Pi_Schid AND B.Schcategory_type IN ('Trade Scheme') and Validate_Cap=1 
		AND QPS=0 and Combisch=0 and Flexisch=0 and C.DiscPer>0 )
		BEGIN
			INSERT INTO @SchemeTarget(SchemeExists,Targetvalue,Applicable)
			SELECT 0,0,0
			RETURN
		END
	END 
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM SchemeMaster A (NOLOCK) 
		INNER JOIN SchemeCategorydetails B (NOLOCK) ON A.cmpschcode=B.Cmpschcode
		INNER JOIN SchemeSlabs C (NOLOCK) ON A.Schid=C.Schid
		WHERE A.schId=@Pi_Schid AND B.Schcategory_type IN ('Trade Scheme') and Validate_Cap=1 
		AND QPS=0 AND Combisch=0 and Flexisch=0)
		BEGIN
			INSERT INTO @SchemeTarget(SchemeExists,Targetvalue,Applicable)
			SELECT 0,0,0
			RETURN
		END
	END  

	SELECT @ToDate=DATEADD(DAY,-1,SchValidFrom),
	@FromDate=DATEADD(MONTH,-1*NoOfMonth ,schValidFrom),
	@Growth_Factor=ISNULL(Growth_Factor,0),@Add_Growth_Factor=ISNULL(Add_Growth_Factor,0)
	,@NoofMonth=ISNULL(NoOfMonth,0),
	@CapAmount=ISNULL(Cap_Amount,0)
	FROM SchemeMaster A (NOLOCK) INNER JOIN SchemeCategorydetails (NOLOCK) B ON A.cmpschcode=B.Cmpschcode
	WHERE A.schId=@Pi_Schid AND Schcategory_type IN ('Trade Scheme') and Validate_Cap=1
	AND QPS=0 and Combisch=0 and Flexisch=0

	IF (@NoofMonth<=0 OR @CapAmount<=0)
	BEGIN
		INSERT INTO @SchemeTarget(SchemeExists,Targetvalue,Applicable)
		SELECT 1,ISNULL(@TargetValue,0),0
		RETURN
	END

	DECLARE @SchemeProduct TABLE
	(
		SchID INT,
		Prdid INT,
		PrdbatId INT,
		PrdCtgValMainId INT
	)

	DECLARE @SchemePurchaseValue TABLE
	(
		CtgCount INT,
		PrdNetAmount NUMERIC(36,6)
	)

	DECLARE @TempBilledAmount TABLE
	(
		SchemeOnAmount NUMERIC(18,6),
		SchemeOnAmtWithTax NUMERIC(18,6)
	)

	INSERT INTO @SchemeProduct(SchId,Prdid,PrdbatId,PrdCtgValMainId)
	SELECT DISTINCT @Pi_Schid,B.Prdid,0 as PrdbatId,C.PrdCtgValMainId  
	FROM SchemeMaster A  (NOLOCK)
	INNER JOIN SchemeProducts B (NOLOCK) ON A.SchId = B.SchId  
	INNER JOIN Product C (NOLOCK) On B.Prdid = C.PrdId  
	WHERE B.PrdId <> 0 AND A.SchId=@Pi_Schid
	UNION
	SELECT DISTINCT @Pi_Schid,E.Prdid,0 as PrdbatId,B.PrdCtgValMainId 
	FROM SchemeMaster A (NOLOCK)
	INNER JOIN SchemeProducts B (NOLOCK) ON A.Schid = B.Schid
	INNER JOIN ProductCategoryValue C (NOLOCK) ON 
	B.PrdCtgValMainId = C.PrdCtgValMainId 
	INNER JOIN ProductCategoryValue D (NOLOCK) ON
	D.PrdCtgValLinkCode LIKE CAST(c.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
	INNER JOIN Product E (NOLOCK) ON
	D.PrdCtgValMainId = E.PrdCtgValMainId 
	INNER JOIN ProductBatch F (NOLOCK) ON
	F.PrdId = E.Prdid
	WHERE A.Schid = @Pi_Schid

	IF NOT EXISTS (SELECT 'X' FROM @FreeScheme)
	BEGIN
		SELECT @SalesValue=SUM(ISNULL((D.DiscountPerAmount*100)/NULLIF(DiscPer,0),0)) 
		FROM SalesInvoice A (NOLOCK)
		INNER JOIN SalesInvoiceSchemeLineWise D (NOLOCK) ON A.SalId=D.SalId
		WHERE D.SchId=@Pi_Schid and DlvSts<>3 and D.SalId<>@Pi_Salid
		and (DiscountPerAmount)>0
		
		--- Consider only saleable stock
		SELECT @ReturnValue=SUM(ISNULL((c.ReturnDiscountPerAmount*100)/NULLIF(D.DiscPer,0),0)) 
		FROM ReturnHeader A (NOLOCK) 
		INNER JOIN ReturnProduct B (NOLOCK) ON A.ReturnId=B.ReturnId
		INNER JOIN ReturnSchemeLineDt C(NOLOCK) ON A.ReturnId=C.ReturnId and C.ReturnId=B.ReturnId 
		AND B.Prdid=C.PrdId and B.PrdbatId=C.PrdbatId AND B.Slno=C.rowId
		INNER JOIN StockType E (NOLOCK) ON E.StockTypeId=B.StockTypeId
		INNER JOIN SchemeSlabs D (NOLOCK) ON D.Schid=C.schid and D.SlabId=C.SlabId 
		WHERE C.Schid=@Pi_Schid and A.Status=0 and (C.ReturnDiscountPerAmount)>0
		AND E.SystemStockType=1
	END
	ELSE
	BEGIN
		SELECT @SalesValue=SUM(ISNULL(F.PrdGrossAmountAftEdit,0)) 
		FROM SalesInvoice A (NOLOCK)
		INNER JOIN SalesInvoiceProduct F (NOLOCK) ON A.SalId=F.SalId
		INNER JOIN SalesInvoiceSchemeDtBilled  D (NOLOCK) ON F.SalId=D.SalId AND F.PrdId=D.PrdId 
		WHERE D.SchId=@Pi_Schid and DlvSts<>3 AND D.SalId<>@Pi_Salid
		
		
		SELECT @ReturnValue=SUM(ISNULL(B.PrdGrossAmt,0))  
		FROM ReturnHeader A (NOLOCK) 
		INNER JOIN ReturnProduct B (NOLOCK) ON A.ReturnId=B.ReturnId
		INNER JOIN (SELECT DISTINCT ReturnId,SchId FROM ReturnSchemeFreePrdDt (NOLOCK) WHERE SchId=@Pi_Schid)C  
						ON B.ReturnId=C.ReturnId  
		INNER JOIN StockType E (NOLOCK) ON E.StockTypeId=B.StockTypeId
		INNER JOIN @SchemeProduct D ON D.Schid=C.Schid AND D.PrdId=B.PrdId 
		WHERE C.Schid=@Pi_Schid AND A.Status=0  AND E.SystemStockType=1
		 
	END 

	SET @TargetValue=(ISNULL(@CapAmount,0)+ISNULL(@ReturnValue,0)) -ISNULL(@SalesValue,0)
	
	INSERT INTO @SchemeTarget(SchemeExists,Targetvalue,Applicable)
	SELECT 1,ROUND(ISNULL(@TargetValue,0),0),CASE WHEN ROUND(ISNULL(@TargetValue,0),0)<=0.25 THEN 0 ELSE 1 END

RETURN
END
GO
IF EXISTS(SELECT 'X' FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cn2Cs_BLSchemeMaster')
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
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*************************************************  
* [DATE]      [DEVELOPER]      [USER_STORY_ID]   [CR/BUG]  [DESCRIPTION]  
* 03
03-01-2018  Lakshman. M      ICRSTPAR7277        BUG      Scheme description “amp;”  (special character)Script validation added from CS.  
18-06-2018	Karthick.KJ		 CRCRSTPAR0007		 CR		  Claim Apply with/Without Tax
11-04-2019	MARY			 CRCRSTPAR0039		 CR		  new Columns added  NoOfMonth,Growth_Factor,Add_Growth_Factor,Validate_Cap,Cap_Amount		
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
	DECLARE @ApplyTaxForClaim   AS VARCHAR(50)
	DECLARE @ApplyTax			AS INT
	DECLARE @NoOfMonth AS TINYINT --CRCRSTPAR0039
	DECLARE @Growth_Factor AS NUMERIC(18,2)
	DECLARE @Add_Growth_Factor AS NUMERIC(18,2)
	DECLARE @Cap_Amount AS NUMERIC(18,2)
	DECLARE @Validate_Cap AS VARCHAR(10)
	DECLARE @Validate_Cap_Id AS TINYINT
	
	
	SET @TabName = 'Etl_Prk_SchemeHD_Slabs_Rules'
	SET @Po_ErrNo =0
	SET @AdjustSchId=0
	SET @iCnt=0
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	DECLARE @DistCode AS  NVARCHAR(50)
	SELECT @DistCode=ISNULL(DistributorCode,'') FROM Distributor
	---------------------------------- added by Lakshman M on 03/01/2018 PMS ID: ICRSTPAR7277-----------
	Declare @Lvar Int  
	Declare @MaxId Int
	Declare @SqlStr Varchar(8000)  
	Declare @Process Varchar(100)  
	Declare @colcount Int  
	Declare @Col Varchar(5000)
 	Create Table #SPLTBL (Id Int Identity(1,1),CId int,CName Varchar(200),CType Varchar(100))
	Insert into #SPLTBL
	Select A.column_id as CId,A.Name,C.name As CType From Sys.columns A (Nolock),Sys.objects B (Nolock),Sys.types C (Nolock) 
	where A.object_id = B.object_id and B.name = 'Etl_Prk_SchemeHD_Slabs_Rules'
	And A.system_type_id = C.system_type_id And C.name='nvarchar' and A.column_id= 3
	Order by A.column_id 
	Declare @CName Varchar(100)
	Set @Lvar = 1
	Set @CName = ''
	Select @MaxId = IsNull(Count(CId),0) From #SPLTBL
	While @Lvar <= @MaxId
	Begin
		Select @CName = CName From #SPLTBL Where Id = @Lvar
		Set @SqlStr = ''
		Set @SqlStr = @SqlStr + ' Update Etl_Prk_SchemeHD_Slabs_Rules  Set '+ @CName + ' = REPLACE(' + @CName + ','' amp;'',''&'')'
		exec (@SqlStr)
		Set @SqlStr = ''
		Set @SqlStr = @SqlStr + ' Update Etl_Prk_SchemeHD_Slabs_Rules  Set '+ @CName + ' = REPLACE(' + @CName + ','' lt;'',''<'')'
		exec (@SqlStr)
		Set @SqlStr = ''
		Set @SqlStr = @SqlStr + ' Update Etl_Prk_SchemeHD_Slabs_Rules  Set '+ @CName + ' = REPLACE(' + @CName + ','' gt;'',''>'')'
		exec (@SqlStr)
		Set @Lvar = @Lvar + 1
	End
 ---------------------------------- Till here -------------------
	
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
	--ISNULL(BudgetAllocationNo,'') AS BudgetAllocationNo,
	ISNULL(CircularNo,'') AS BudgetAllocationNo,
	ISNULL(SchBasedOn,'') AS SchemeBasedOn,
	ISNULL(FBM,'No') AS FBM,
	ISNULL(SettlementType,'ALL') AS SettlementType,
	ISNULL([AllowUncheck],'NO') AS AllowUncheck,
	ISNULL([CombiType],'NORMAL') AS [CombiType],
	ISNULL(SchApplyOn,'SELLINGRATE') AS SchApplyOn,
	ISNULL(ApplyTaxForClaim,'YES') AS ApplyTaxForClaim,
	ISNULL(NoOfMonth,0) AS NoOfMonth, --CRCRSTPAR0039
	ISNULL(Growth_Factor,0) AS Growth_Factor,
	ISNULL(Add_Growth_Factor,0) AS Add_Growth_Factor,
	ISNULL(Validate_Cap,'NO') AS 	Validate_Cap,
	ISNULL(Cap_Amount,0) AS 	Cap_Amount
	FROM Etl_Prk_SchemeHD_Slabs_Rules (NOLOCK)
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'			 
	ORDER BY [Company Scheme Code]
	OPEN Cur_SchMaster
	FETCH NEXT FROM Cur_SchMaster INTO @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
	, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
	, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch,
	@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM,@SettlementType,@AllowUnCheck,@CombiType,@SchApplyOn,@ApplyTaxForClaim,
	@NoOfMonth,@Growth_Factor,@Add_Growth_Factor,@Validate_Cap,@Cap_Amount --CRCRSTPAR0039
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
		--CRCRSTPAR0007
		IF (UPPER(LTRIM(RTRIM(@ApplyTaxForClaim)))<> 'YES' AND UPPER(LTRIM(RTRIM(@ApplyTaxForClaim)))<> 'NO')
		BEGIN
			SET @ErrDesc = 'ApplyTaxForClaim) should be (YES OR NO) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (70,@TabName,'ApplyTaxForClaim',@ErrDesc)
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
			
			IF UPPER(LTRIM(RTRIM(@ApplyTaxForClaim)))= 'YES'
			BEGIN
				SET @ApplyTax=1
			END	
			ELSE IF UPPER(LTRIM(RTRIM(@ApplyTaxForClaim)))= 'NO'
			BEGIN
				SET @ApplyTax=0		
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
		
		
		IF UPPER(LTRIM(RTRIM(ISNULL(@Validate_Cap,'NO'))))= 'YES'
		BEGIN
			SET @Validate_Cap_Id=1
		END	
		ELSE IF UPPER(LTRIM(RTRIM(ISNULL(@Validate_Cap,'NO'))))= 'NO'
		BEGIN
			SET @Validate_Cap_Id=0		
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
					Budget=@SchBudget,/*,SchStatus=@StatusId*/ 
					Validate_Cap=@Validate_Cap_Id,Cap_Amount=@Cap_Amount
					WHERE SchId=@GetKey --Modified by Muthuvel for DCONSPAR0470
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
					SchemeLvlMode=@SelMode,/*,SchStatus=@StatusId*/ 
					Validate_Cap=@Validate_Cap_Id,Cap_Amount=@Cap_Amount
					WHERE SchId=@GetKey --Modified by Muthuvel for DCONSPAR0470
					
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
								BudgetAllocationNo,AllowPrdSelc,ExcludeDM,SchBasedOn,Download,FBM,
								SettlementType,ApplyClaim,CombiType,ApplyTaxForClaim,
								NoOfMonth,Growth_Factor,Add_Growth_Factor,Validate_Cap,Cap_Amount)
								VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
								LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
								@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
								@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
								@ApplySchId,@SettleSchId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,
								CONVERT(VARCHAR(10),GETDATE(),121),@EditSchId,@SelMode,1,@SchApplyOnId,0,
								@BudgetAllocationNo,0,0,@SchBasedOnId,1,@FBMId,@SettlementTypeId,@AllowUnCheckId,@CombiTypeId,@ApplyTax,
								@NoOfMonth,@Growth_Factor,@Add_Growth_Factor,@Validate_Cap_Id,@Cap_Amount)
				
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
								PurofEvery,ApyQPSSch,SetWindowDisp,EditScheme,SchemeLvlMode,UpLoadFlag,BudgetAllocationNo,SchBasedOn,Download,
								NoOfMonth,Growth_Factor,Add_Growth_Factor,Validate_Cap,Cap_Amount) VALUES
								(LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
								@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
								@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
								@ApplySchId,@SettleSchId,@EditSchId,@SelMode,'N',@BudgetAllocationNo,@SchBasedOnId,1,
								@NoOfMonth,@Growth_Factor,@Add_Growth_Factor,@Validate_Cap,@Cap_Amount)
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
							PurofEvery,ApyQPSSch,SetWindowDisp,EditScheme,SchemeLvlMode,UpLoadFlag,BudgetAllocationNo,SchBasedOn,Download,
							NoOfMonth,Growth_Factor,Add_Growth_Factor,Validate_Cap,Cap_Amount) VALUES
							(LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
							@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
							@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
							@ApplySchId,@SettleSchId,@EditSchId,@SelMode,'N',@BudgetAllocationNo,@SchBasedOnId,1,
							@NoOfMonth,@Growth_Factor,@Add_Growth_Factor,@Validate_Cap,@Cap_Amount)
						END							
				END
				ELSE
				BEGIN
					INSERT INTO SchemeMaster(SchId,SchCode,SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
					CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
					ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
					PurofEvery,ApyQPSSch,SetWindowDisp,Availability,LastModBy,LastModDate,AuthId,
					AuthDate,EditScheme,SchemeLvlMode,MasterType,ApplyOnMRPSelRte,ApplyOnTax,BudgetAllocationNo,
					AllowPrdSelc,ExcludeDM,SchBasedOn,Download,FBM,SettlementType,ApplyClaim,CombiType,ApplyTaxForClaim,
					NoOfMonth,Growth_Factor,Add_Growth_Factor,Validate_Cap,Cap_Amount)
					VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
					LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
					@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
					@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
					@ApplySchId,@SettleSchId,1,1,convert(varchar(10),getdate(),121),1,
					convert(varchar(10),getdate(),121),@EditSchId,@SelMode,1,@SchApplyOnId,0,@BudgetAllocationNo,0,0,
					@SchBasedOnId,1,@FBMId,@SettlementTypeId,@AllowUnCheckId,@CombiTypeId,@ApplyTax,
					@NoOfMonth,@Growth_Factor,@Add_Growth_Factor,@Validate_Cap_Id,@Cap_Amount)
	
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
		@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM,@SettlementType,@AllowUnCheck,@CombiType,@SchApplyOn,@ApplyTaxForClaim,
		@NoOfMonth,@Growth_Factor,@Add_Growth_Factor,@Validate_Cap,@Cap_Amount
	END
	CLOSE Cur_SchMaster
	DEALLOCATE Cur_SchMaster
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ApportionSchemeAmountInLine')
DROP PROCEDURE Proc_ApportionSchemeAmountInLine
GO
/*
BEGIN TRANSACTION
DELETE A FROM ApportionSchemeDetails A (NOLOCK)
EXEC Proc_ApportionSchemeAmountInLine 1,2,77,2
SELECT * FROM ApportionSchemeDetails (NOLOCK)
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_ApportionSchemeAmountInLine
(
	@Pi_UsrId   INT,
	@Pi_TransId  INT,
	@Pi_Salid  BIGINT=0,
	@Pi_EditMode TINYINT =0,
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
* {date}       {developer}        USER STORYID		[CR/BUG]	{brief modification description}
* 28/04/2009    Nandakumar R.G									Modified for Discount Calculation on MRP with Tax
* 10/04/2010    Nandakumar R.G									Modified for QPS Scheme
* 04-08-2011    Boopathy.P										Update the Discount percentage for Flexi Scheme 
* 05-08-2011    Boopathy.P										Previous Adjusted Value will not reduce for Flexi QPS Based Scheme
* 09-08-2011    Boopathy.P										Bug No:23402
* 11-4-2019		Mary			 CRCRSTPAR0039		CR			Trade Scheme calculation Based on Cap Amount, Two Input parameter Added	 @Pi_Salid,@Pi_EditMode		
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
	--Trade scheme CRCRSTPAR0039
	CREATE TABLE #PurchaseTarget
	(
		Schid INT,
		TargetValue Numeric(18,6)
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
					---CRCRSTPAR0039
					INSERT INTO #PurchaseTarget(Schid,TargetValue)
					SELECT @SchId,Targetvalue FROM  DBO.Fn_RetrunPurchaseSchemeTarget(@SchId,@Pi_Salid,@Pi_TransId,@Pi_Usrid,@Pi_EditMode) WHERE SchemeExists=1 AND Applicable=1
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
	
	----Trade Scheme Calculation change (NO QPS,COMBI,Range --Only Discount scheme)CRCRSTPAR0039
	/***
		Example: Take ( Purchase value for scheme product minus Utilized Billed scheme product value)
		If Billed scheme product higer than purchase value than take purchase value
		Scheme Slab: Purchase 10 QTY 2%
		Scheme BRAND: FLAVOR LEVEL
		
		Purchase Value:
		Product A 300
		Product B 400
		SUM(700)
		
		Billed Product	| Actual Scheme Discount | Purchas Value	| new scheme value
		Product A 300		300*2%=6				(6/20)*14=4.2		4.2
		Product B 700		700*2%=14 				(14/20)*14=9.8		9.8
		SUM(1000)
		SUM(700-1000)<=0 THEN 700 is Overall gross 700*2%=14 should get apply
	*/
	
	SELECT Schid,DiscPer,SUM(schemeDiscount) as TotalSchemeDiscount 
	INTO #TradeSchemeDisper
	FROM ApportionSchemeDetails (NOLOCK) WHERE  TransID = @Pi_TransId AND UsrId = @Pi_Usrid
	AND DiscPer>0
	GROUP BY Schid,DiscPer	
	
	SELECT A.Schid,(CASE WHEN ABS(TargetValue)-GrossAmount<=0 THEN   GrossAmount-ABS(ABS(TargetValue)-GrossAmount)
	ELSE GrossAmount END) *(DiscPer/100) AS DiscountAmt,TotalSchemeDiscount,
	(CASE WHEN ABS(TargetValue)-GrossAmount<=0 THEN   GrossAmount-ABS(ABS(TargetValue)-GrossAmount)
	ELSE GrossAmount END) as ActualGross	
	INTO #TradeSchemeValue
	FROM #PurchaseTarget A INNER JOIN @TempSchGross B ON A.Schid=B.Schid
	INNER JOIN #TradeSchemeDisper C ON A.Schid=C.SchId and B.schid=C.Schid
	WHERE ABS(TargetValue)-GrossAmount<=0
	
		
	UPDATE  A SET A.SchemeDiscount=(A.SchemeDiscount/B.TotalSchemeDiscount)* DiscountAmt 
	FROM ApportionSchemeDetails A (NOLOCK) INNER JOIN #TradeSchemeValue B ON A.schid=B.schid
	WHERE  TransID = @Pi_TransId AND UsrId = @Pi_Usrid and SchemeDiscount>0
	---Till Here CRCRSTPAR0039

	
END
GO
IF EXISTS (SELECT * FROM Sysobjects Where name='Fn_ReturnTradeSchemeIDS' and XTYPE IN ('TF','FN'))
DROP FUNCTION Fn_ReturnTradeSchemeIDS
GO
--SELECT * FROM DBO.[Fn_ReturnTradeSchemeIDS] (1) 
CREATE FUNCTION  [dbo].[Fn_ReturnTradeSchemeIDS](@UsrId AS INT ,@IsSelect AS INT,@TransId AS INT,@SalId AS BIGINT)
RETURNS @Table table 
(
	SchId			INT,
	SchBudget		NUMERIC(38,6),
	BudgetUtilized	NUMERIC(38,6)
)
AS 
/*************************************************************************************************************
* PROCEDURE	: Fn_ReturnTradeSchemeIDS
* PURPOSE	: To Return Trade Schemes
* CREATED	: MarySubashini.S 
* CREATED DATE	: 12-04-2019 CR:CRCRSTPAR0039
* MODIFIED
* DATE			AUTHOR				USERSTORYID            CR/BZ       DESCRIPTION
---------------------------------------------------------------------------------------------------------------------------
*11.01.2019		MarySubashini.S		CRCRSTPAR0039            CR			Scheme Cap Values 	
**************************************************************************************************************************/
BEGIN

		INSERT INTO @Table(SchId,SchBudget,BudgetUtilized )
		SELECT DISTINCT A.SchId,A.SchBudget,A.BudgetUtilized FROM BillAppliedSchemeHd  A  (NOLOCK)
		INNER JOIN SchemeMaster B  (NOLOCK) ON A.SchId=B.SchId 
		INNER JOIN  SchemeCategorydetails C (NOLOCK) ON B.CmpSchCode =C.CmpSchcode 
		WHERE 	A.TransId =  @TransId  AND A.UsrId=@UsrId  AND A.IsSelected =@IsSelect
		AND  C.Schcategory_type IN ('Trade Scheme') 
		
 RETURN 
END
GO
--ILCRSTPAR3405	(Billtemplate Invoice No Lenght Increase)
IF EXISTS (SELECT * FROM Configuration (NOLOCK) WHERE Moduleid='RET12')
BEGIN
	IF EXISTS (SELECT * FROM Taxgroupsetting Where TaxGroupName='Retailer Intra')
	BEGIN 
	 DECLARE @TaxGroupid  INT
	 SELECT  @TaxGroupid = ISNULL(TaxGroupid,0) FROM TaxGroupSetting WHERE TaxGroupName IN (SELECT ISNULL(Condition,'')  FROM Configuration A WHERE ModuleId ='RET12')
	 UPDATE A SET configvalue =@TaxGroupid FROM Configuration A WHERE ModuleId ='RET12'
	END
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='RptBillTemplate_CrDbAdjustment' AND XTYPE ='U')
DROP TABLE RptBillTemplate_CrDbAdjustment
GO
CREATE TABLE [dbo].[RptBillTemplate_CrDbAdjustment](
	[SalId] [int] NULL,
	[SalInvNo] [nvarchar](100) NULL,
	[NoteNumber] [nvarchar](100) NULL,
	[Amount] [numeric](18, 0) NULL,
	[PreviousAmount] [numeric](18, 0) NULL,
	[CrDbRemarks] [nvarchar](100) NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO
--ILCRSTPAR3516	(manual claim one month date range validation included from CS.)
IF EXISTS (select * FROM SYSOBJECTS WHERE NAME ='Fn_MonthEnddatefilter' and XType ='TF')
DROP Function Fn_MonthEnddatefilter
GO
CREATE FUNCTION DBO.Fn_MonthEnddatefilter (@Pi_CurDate AS DATETIME)
Returns @manualclaimstdtenddt table
	(
		fromdate	DATETIME ,
		EndDate		DATETIME,
		JCMJC		INT 
	)
AS
BEGIN
  	INSERT INTO @manualclaimstdtenddt
	SELECT @Pi_CurDate,convert(varchar(10),dateadd(ms,-3,dateadd(mm,0,dateadd(mm,datediff(mm,0,@Pi_CurDate)+1,0))),121),MONTH(@Pi_CurDate)
RETURN
END
GO
--ILCRSTPAR4044	(product default price new column added)
IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' 
AND B.name='PrdtDefaultPricevalue')      
BEGIN
	ALTER TABLE RptBillTemplateFinal ADD PrdtDefaultPricevalue NUMERIC (18,2) DEFAULT 0 WITH VALUES       
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_RptBillTemplateFinal' AND TYPE ='P')
DROP PROCEDURE Proc_RptBillTemplateFinal
GO
-- EXEC PROC_RptBillTemplateFinal 16,2,0,'BILLPrintissue03012018',0,0,1,'RPTBT_VIEW_FINAL1_BILLTEMPLATE'           
CREATE PROCEDURE Proc_RptBillTemplateFinal
(      
 @Pi_RptId  INT,      
 @Pi_UsrId  INT,      
 @Pi_SnapId  INT,      
 @Pi_DbName  NVARCHAR(50),      
 @Pi_SnapRequired INT,      
 @Pi_GetFromSnap  INT,      
 @Pi_CurrencyId  INT,      
 @Pi_BTTblName    NVARCHAR(50)      
)      
AS      
/***************************************************************************************************      
* PROCEDURE : Proc_RptBillTemplateFinal      
* PURPOSE : General Procedure      
* NOTES  :        
* CREATED :      
* MODIFIED      
* DATE       AUTHOR     DESCRIPTION      
----------------------------------------------------------------------------------------------------      
* 01.10.2009  Panneer      Added Tax summary Report Part(UserId Condition)      
* 10/07/2015  PRAVEENRAJ BHASKARAN     Added Grammge For Parle  
* DATE       AUTHOR     CR/BZ	USER STORY ID           DESCRIPTION                         
***************************************************************************************************
  10-01-2018  LAKSHMAN	   BZ     ICRSTPAR7339             Bill Print Allot ment Issue
  11-04-2019  Lakshman M   SR     ILCRSTPAR4044            product default price new column added
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
 DECLARE @NewSnapId  AS INT      
 DECLARE @DBNAME  AS  nvarchar(50)      
 DECLARE @TblName  AS nvarchar(500)      
 DECLARE @TblStruct  AS nVarchar(4000)      
 DECLARE @TblFields  AS nVarchar(4000)      
 DECLARE @sSql  AS  nVarChar(4000)      
 DECLARE @ErrNo   AS INT      
 DECLARE @PurDBName AS nVarChar(50)      
 Declare @Sub_Val  AS TINYINT      
 DECLARE @FromDate AS DATETIME      
 DECLARE @ToDate   AS DATETIME      
 DECLARE @FromBillNo  AS   BIGINT      
 DECLARE @TOBillNo    AS   BIGINT      
 DECLARE @SMId   AS INT      
 DECLARE @RMId   AS INT      
 DECLARE @RtrId   AS INT      
 DECLARE @vFieldName    AS nvarchar(255)      
 DECLARE @vFieldType AS nvarchar(10)      
 DECLARE @vFieldLength as nvarchar(10)      
 DECLARE @FieldList as      nvarchar(4000)      
 DECLARE @FieldTypeList as varchar(8000)      
 DECLARE @FieldTypeList2 as varchar(8000)      
 DECLARE @DeliveredBill  AS INT      
 DECLARE @SSQL1 AS NVARCHAR(4000)      
 DECLARE @FieldList1 as      nvarchar(4000)      
 --For B&L Bill Print Configurtion      
 SELECT @DeliveredBill=Status FROM  Configuration WHERE ModuleName='Discount & Tax Collection' AND ModuleId='DISTAXCOLL5'      
 IF @DeliveredBill=1      
 BEGIN        
  DELETE FROM RptBillToPrint WHERE [Bill Number] IN(      
  SELECT SalInvNo FROM SalesInvoice WHERE DlvSts NOT IN(4,5))      
 END      
 --Till Here      
 --Added By Murugan 04/09/2009      
 --print @Pi_BTTblName      
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
  if len(@FieldTypeList) > 3060      
  begin      
   Set @FieldTypeList2 = @FieldTypeList      
   Set @FieldTypeList = ''      
  end      
  --->Added By Nanda on 12/03/2010      
  IF LEN(@FieldList)>3060      
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
   Set @FieldList = @FieldList + '[' + @vFieldName + '] , '      
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
  EXEC('CREATE TABLE RptBillTemplateFinal      
  (' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500),'+ @UomFieldList +')')      
 END      
 ELSE      
 BEGIN      
  EXEC('CREATE TABLE RptBillTemplateFinal      
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
 IF @Pi_GetFromSnap = 0  --To Generate For New Report Data      
 BEGIN      
  DELETE FROM RptBillTemplateFinal Where UsrId = @Pi_UsrId      
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
 ELSE    --To Retrieve Data From Snap Data      
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
-- EXEC Proc_BillPrintingTax @Pi_UsrId      
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
  IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='GSTTIN')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD GSTTIN VARCHAR(50) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='PAN Number')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD [Pan Number] VARCHAR(50) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Retailer Type')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD [Retailer Type] VARCHAR(50) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='Composite')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD Composite VARCHAR(50) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='RelatedParty')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD RelatedParty VARCHAR(50) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='State Name')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD [State Name] VARCHAR(50) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='State Code')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD [State Code] VARCHAR(10) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='StateTinNo')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD [StateTinNo] VARCHAR(10) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='HSNCode')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD HSNCode VARCHAR(100) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='HSNDescription')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD HSNDescription VARCHAR(100) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='DistributorGstTin')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD DistributorGstTin VARCHAR(50) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='DistributorStateName')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD DistributorStateName VARCHAR(50) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Distributor Type')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD [Distributor Type] VARCHAR(50) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='AadharNo')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD AadharNo VARCHAR(50) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='DistributorStateCode')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD DistributorStateCode VARCHAR(10) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='DistributorStateTinNo')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD DistributorStateTinNo VARCHAR(10) DEFAULT '' WITH VALUES      
 END        
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Dist Food Lic No')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD [Dist Food Lic No] VARCHAR(50) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Dist Drug Lic no')      
 BEGIN      
  ALTER TABLE RptBillTemplateFinal ADD [Dist Drug Lic no] VARCHAR(50) DEFAULT '' WITH VALUES      
 END      
 IF NOT EXISTS(SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='SalesInvoice NetAmount Actual')      
 BEGIN      
  ALTER  TABLE RptBillTemplateFinal ADD [SalesInvoice NetAmount Actual] Numeric(18,2)      
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
-- Select @Sub_Val = TaxDt  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))      
-- If @Sub_Val = 1      
-- Begin      
        DELETE FROM RptBillTemplate_Tax WHERE UsrId = @Pi_UsrId          
  Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)      
  SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId      
  FROM SalesInvoiceProductTax SI , TaxConfiguration T,SalesInvoice S,RptBillToPrint B      
  WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId      
  GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc HAVING SUM(TaxableAmount) > 0 --Muthuvel      
-- End      
 ------------------------------ Other      
 --Select @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))      
 --If @Sub_Val = 1      
 --Begin      
  Delete From RptBillTemplate_Other Where UsrId = @Pi_UsrId      
  Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)      
  SELECT SI.SalId,S.SalInvNo,      
  SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,      
  Adjamt Amount,@Pi_UsrId      
  FROM SalInvOtherAdj SI,PurSalAccConfig P,SalesInvoice S,RptBillToPrint B      
  WHERE P.TransactionId = 2      
  and SI.AccDescId = P.AccDescId      
  and SI.SalId = S.SalId      
  and S.SalInvNo = B.[Bill Number]      
 --End      
 ---------------------------------------Replacement      
 --Select @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))      
 --If @Sub_Val = 1      
 --Begin      
  Delete From RptBillTemplate_Replacement Where UsrId = @Pi_UsrId      
  Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)      
  SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId      
  FROM ReplacementHd H, ReplacementOut D, Product P, ProductBatch PB,SalesInvoice SI,RptBillToPrint B      
  WHERE H.SalId <> 0      
  and H.RepRefNo = D.RepRefNo      
  and D.PrdId = P.PrdId      
  and D.PrdBatId = PB.PrdBatId      
  and H.SalId = SI.SalId      
  and SI.SalInvNo = B.[Bill Number]      
 --End      
 ----------------------------------Credit Debit Adjus      
 --Select @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))      
 --If @Sub_Val = 1      
 --Begin      
     Delete From RptBillTemplate_CrDbAdjustment Where UsrId = @Pi_UsrId      
  Insert into RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,UsrId)      
  Select A.SalId,S.SalInvNo,CrNoteNumber,A.CrAdjAmount,@Pi_UsrId      
  from SalInvCrNoteAdj A,SalesInvoice S,RptBillToPrint B      
  Where A.SalId = s.SalId      
  and S.SalInvNo = B.[Bill Number]      
  Union All      
  Select A.SalId,S.SalInvNo,DbNoteNumber,A.DbAdjAmount,@Pi_UsrId      
  from SalInvDbNoteAdj A,SalesInvoice S,RptBillToPrint B      
  Where A.SalId = s.SalId      
  and S.SalInvNo = B.[Bill Number]      
 --End      
 ---------------------------------------Market Return      
-- Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))      
-- If @Sub_Val = 1      
-- Begin      
  Delete from RptBillTemplate_MarketReturn where UsrId = @Pi_UsrId      
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
-- End      
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
 --INSERT INTO RptBillTemplate_PrdUOMDetails(SalId,SalInvNo,TotPrdVolume,TotPrdKG,TotPrdLtrs,TotPrdUnits,      
 --TotPrdDrums,TotPrdCartons,TotPrdBuckets,TotPrdPieces,TotPrdBags,UsrId)       
 --SELECT SalId,SalInvNo,SUM(TotPrdVolume) AS TotPrdVolume,SUM(TotPrdKG) AS TotPrdKG,SUM(TotPrdLtrs) AS TotPrdLtrs,SUM(TotPrdUnits) AS TotPrdUnits,      
 --SUM(TotPrdDrums) AS TotPrdDrums,SUM(TotPrdCartons) AS TotPrdCartons,SUM(TotPrdBuckets) AS TotPrdBuckets,SUM(TotPrdPieces) AS TotPrdPieces,SUM(TotPrdBags) AS TotPrdBags,@Pi_UsrId      
 --FROM      
 --(      
 -- SELECT DISTINCT SI.SalId,SI.SalInvNo,SIP.PrdId,SIP.BaseQty*dbo.Fn_ReturnProductVolumeInLtrs(SIP.PrdId) AS TotPrdVolume,      
 -- SIP.BaseQty*P.PrdUpSKU * (CASE P.PrdUnitId WHEN 2 THEN .001 WHEN 3 THEN 1 ELSE 0 END) AS TotPrdKG,      
 -- SIP.BaseQty * P.PrdWgt * (CASE P.PrdUnitId WHEN 4 THEN .001 WHEN 5 THEN 1 ELSE 0 END) AS TotPrdLtrs,      
 -- SIP.BaseQty*(CASE P.PrdUnitId WHEN 1 THEN 0 ELSE 0 END) AS TotPrdUnits,      
 -- (CASE ISNULL(UMP1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP1.UOM1Qty,0) END)+      
 -- (CASE ISNULL(UMP2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP2.UOM2Qty,0) END) AS TotPrdPieces,      
 -- (CASE ISNULL(UMBU1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU1.UOM1Qty,0) END)+      
 -- (CASE ISNULL(UMBU2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU2.UOM2Qty,0) END) AS TotPrdBuckets,      
 -- (CASE ISNULL(UMBA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA1.UOM1Qty,0) END)+      
 -- (CASE ISNULL(UMBA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA2.UOM2Qty,0) END) AS TotPrdBags,      
 -- (CASE ISNULL(UMDR1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR1.UOM1Qty,0) END)+      
 -- (CASE ISNULL(UMDR2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR2.UOM2Qty,0) END) AS TotPrdDrums,      
 -- (CASE ISNULL(UMCA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA1.UOM1Qty,0) END)+      
 -- (CASE ISNULL(UMCA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA2.UOM2Qty,0) END)+       
 -- CEILING((CASE ISNULL(UMCN1.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN1.UOM1Qty,0) AS NUMERIC(38,6))/CAST(UGC1.ConvFact AS NUMERIC(38,6)) END))+      
 -- CEILING((CASE ISNULL(UMCN2.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN2.UOM2Qty,0) AS NUMERIC(38,6))/CAST(UGC2.ConvFact AS NUMERIC(38,6)) END)) AS TotPrdCartons      
 -- FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId      
 -- INNER JOIN RptBillToPrint Rpt ON SI.SalInvNo = Rpt.[Bill Number] AND Rpt.UsrId=@Pi_UsrId      
 -- INNER JOIN Product P ON SIP.PrdID=P.PrdID      
 -- INNER JOIN ProductBatch PB ON SIP.PrdBatID=PB.PrdBatID AND P.PrdID=PB.PrdId      
 -- LEFT OUTER JOIN SalesInvoiceProduct SIPP1 ON SI.SalId=SIPP1.SalId AND SIP.PrdID=SIPP1.PrdID AND SIP.PrdBatID=SIPP1.PrdBatID      
 -- LEFT OUTER JOIN SalesInvoiceProduct SIPP2 ON SI.SalId=SIPP2.SalId AND SIP.PrdID=SIPP2.PrdID AND SIP.PrdBatID=SIPP2.PrdBatID      
 -- LEFT OUTER JOIN SalesInvoiceProduct SIPBU1 ON SI.SalId=SIPBU1.SalId AND SIP.PrdID=SIPBU1.PrdID AND SIP.PrdBatID=SIPBU1.PrdBatID      
 -- LEFT OUTER JOIN SalesInvoiceProduct SIPBU2 ON SI.SalId=SIPBU2.SalId AND SIP.PrdID=SIPBU2.PrdID AND SIP.PrdBatID=SIPBU2.PrdBatID        
 -- LEFT OUTER JOIN SalesInvoiceProduct SIPBA1 ON SI.SalId=SIPBA1.SalId AND SIP.PrdID=SIPBA1.PrdID AND SIP.PrdBatID=SIPBA1.PrdBatID      
 -- LEFT OUTER JOIN SalesInvoiceProduct SIPBA2 ON SI.SalId=SIPBA2.SalId AND SIP.PrdID=SIPBA2.PrdID AND SIP.PrdBatID=SIPBA2.PrdBatID      
 -- LEFT OUTER JOIN SalesInvoiceProduct SIPDR1 ON SI.SalId=SIPDR1.SalId AND SIP.PrdID=SIPDR1.PrdID AND SIP.PrdBatID=SIPDR1.PrdBatID      
 -- LEFT OUTER JOIN SalesInvoiceProduct SIPDR2 ON SI.SalId=SIPDR2.SalId AND SIP.PrdID=SIPDR2.PrdID AND SIP.PrdBatID=SIPDR2.PrdBatID      
 -- LEFT OUTER JOIN SalesInvoiceProduct SIPCA1 ON SI.SalId=SIPCA1.SalId AND SIP.PrdID=SIPCA1.PrdID AND SIP.PrdBatID=SIPCA1.PrdBatID      
 -- LEFT OUTER JOIN SalesInvoiceProduct SIPCA2 ON SI.SalId=SIPCA2.SalId AND SIP.PrdID=SIPCA2.PrdID AND SIP.PrdBatID=SIPCA2.PrdBatID      
 -- LEFT OUTER JOIN SalesInvoiceProduct SIPCN1 ON SI.SalId=SIPCN1.SalId AND SIP.PrdID=SIPCN1.PrdID AND SIP.PrdBatID=SIPCN1.PrdBatID      
 -- LEFT OUTER JOIN SalesInvoiceProduct SIPCN2 ON SI.SalId=SIPCN2.SalId AND SIP.PrdID=SIPCN2.PrdID AND SIP.PrdBatID=SIPCN2.PrdBatID      
 -- LEFT OUTER JOIN UOMMaster UMP1 ON UMP1.UOMId=SIPP1.UOM1Id AND UMP1.UOMDescription='PIECES'      
 -- LEFT OUTER JOIN UOMMaster UMP2 ON UMP1.UOMId=SIPP2.UOM2Id AND UMP2.UOMDescription='PIECES'      
 -- LEFT OUTER JOIN UOMMaster UMBU1 ON UMBU1.UOMId=SIPBU1.UOM1Id AND UMBU1.UOMDescription='BUCKETS'       
 -- LEFT OUTER JOIN UOMMaster UMBU2 ON UMBU1.UOMId=SIPBU2.UOM2Id AND UMBU2.UOMDescription='BUCKETS'      
 -- LEFT OUTER JOIN UOMMaster UMBA1 ON UMBA1.UOMId=SIPBA1.UOM1Id AND UMBA1.UOMDescription='BAGS'       
 -- LEFT OUTER JOIN UOMMaster UMBA2 ON UMBA1.UOMId=SIPBA2.UOM2Id AND UMBA2.UOMDescription='BAGS'      
 -- LEFT OUTER JOIN UOMMaster UMDR1 ON UMDR1.UOMId=SIPDR1.UOM1Id AND UMDR1.UOMDescription='DRUMS'       
 -- LEFT OUTER JOIN UOMMaster UMDR2 ON UMDR1.UOMId=SIPDR2.UOM2Id AND UMDR2.UOMDescription='DRUMS'      
 -- LEFT OUTER JOIN UOMMaster UMCA1 ON UMCA1.UOMId=SIPCA1.UOM1Id AND UMCA1.UOMDescription='CARTONS'       
 -- LEFT OUTER JOIN UOMMaster UMCA2 ON UMCA1.UOMId=SIPCA2.UOM2Id AND UMCA2.UOMDescription='CARTONS'      
 -- LEFT OUTER JOIN UOMMaster UMCN1 ON UMCN1.UOMId=SIPCN1.UOM1Id AND UMCN1.UOMDescription='CANS'       
 -- LEFT OUTER JOIN UOMMaster UMCN2 ON UMCN1.UOMId=SIPCN2.UOM2Id AND UMCN2.UOMDescription='CANS'      
 -- LEFT OUTER JOIN (      
 -- SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG      
 -- WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN (       
 -- SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )      
 -- GROUP BY P.PrdID) UGC1 ON SIPCN1.PrdId=UGC1.PrdID      
 -- LEFT OUTER JOIN (      
 -- SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG      
 -- WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN (       
 -- SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )      
 -- GROUP BY P.PrdID) UGC2 ON SIPCN2.PrdId=UGC2.PrdID      
 --) A      
 --GROUP BY SalId,SalInvNo      
 --->Till Here      
 --Added By Sathishkumar Veeramani 2012/12/13      
 IF NOT EXISTS (SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')AND name = 'Payment Mode')      
 BEGIN      
      ALTER TABLE RptBillTemplateFinal ADD [Payment Mode] NVARCHAR(20)      
 END      
 IF Exists(SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')AND name = 'Payment Mode')          
 BEGIN          
  SET @SSQL1='UPDATE A SET A.[Payment Mode] = Z.[Payment Mode] FROM RptBillTemplateFinal A INNER JOIN       
     (SELECT SalId,(CASE RtrPayMode WHEN 1 THEN ''Cash'' ELSE ''Cheque'' END) AS [Payment Mode] FROM SalesInvoice WITH (NOLOCK)) Z ON A.Salid = Z.SalId       
     AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))             
  EXEC (@SSQL1)          
 END      
 --Till Here      
 --->Added By Nanda on 23/03/2010-For Grouping the details based on product for nondrug products      
 IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreeBillPrinting01' AND ModuleName='Botree Bill Printing' AND Status=1)      
 BEGIN      
  IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplateFinal_Group]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)      
  DROP TABLE [RptBillTemplateFinal_Group]      
  SELECT * INTO RptBillTemplateFinal_Group FROM RptBillTemplateFinal  WHERE [Visibility]=1
  Select * from RptBillTemplateFinal_Group     
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
   [UsrId],[Visibility],[Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd]      
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
  [UsrId],[Visibility],[Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd]      
  FROM RptBillTemplateFinal_Group,Product P      
  WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType<>5   AND  [Visibility]=1  
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
  [UsrId],[Visibility],[AmtInWrd] ,
  [Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd] ---------------- Group by columns Added by Lakshman M  on 09/01/2018    
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
  [UsrId],[Visibility],[Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd]      
  FROM RptBillTemplateFinal_Group,Product P      
  WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5   AND  [Visibility]=1   
 END       
 --->Till Here      
  IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDisc')      
  BEGIN      
   ALTER TABLE RptBillTemplateFinal ADD InvDisc NUMERIC (18,2) DEFAULT 0 WITH VALUES       
  END      
  IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDiscPer')      
  BEGIN      
   ALTER TABLE RptBillTemplateFinal ADD InvDiscPer NUMERIC (18,2) DEFAULT 0 WITH VALUES       
  END
  IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='SalesmanPhoneNo')      
  BEGIN      
   ALTER TABLE RptBillTemplateFinal ADD SalesmanPhoneNo NVARCHAR(100)
  END        
  IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='Grammage')      
  BEGIN      
   ALTER TABLE RptBillTemplateFinal ADD Grammage NUMERIC (38,2) DEFAULT 0 WITH VALUES       
  END      
  IF Exists(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDisc')          
  BEGIN          
   SET @SSQL1='UPDATE A SET A.InvDisc=B.SalInvLvlDisc FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK)       
      ON A.[Sales Invoice Number]=B.SalInvNo AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))             
   EXEC (@SSQL1)          
  END       
  IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDiscPer')          
  BEGIN        
   SET @SSQL1='UPDATE A SET A.InvDiscPer=B.SalInvLvlDiscPer FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK)       
      ON A.[Sales Invoice Number]=B.SalInvNo AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))             
   EXEC (@SSQL1)      
  END      
  IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='SalesmanPhoneNo')          
  BEGIN        
   SET @SSQL1='UPDATE A SET A.SalesmanPhoneNo=ISNULL(B.SMPhoneNumber,'''') FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesMan B (NOLOCK)       
      ON A.[SalesMan Code]=B.SMCode AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))             
   EXEC (@SSQL1)          
  END      
--- Added by Rajesh ICRSTPAR3196      
  IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='bx')          
  BEGIN        
   SET @SSQL1='UPDATE A SET A.bx=bx+box FROM RptBillTemplateFinal A (NOLOCK) WHERE A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))      
   EXEC (@SSQL1)          
  END      
  IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='PBG')          
  BEGIN        
   SET @SSQL1='UPDATE A SET A.PB=PB+PBG FROM RptBillTemplateFinal A (NOLOCK) WHERE A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))             
   EXEC (@SSQL1)          
  END      
  IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='TIN')          
  BEGIN        
   SET @SSQL1='UPDATE A SET A.Tn=TN+TIN FROM RptBillTemplateFinal A (NOLOCK) WHERE A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))        
   EXEC (@SSQL1)          
  END      
  IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='TIF')          
  BEGIN        
   SET @SSQL1='UPDATE A SET A.TIF=TIF+TBX FROM RptBillTemplateFinal A (NOLOCK) WHERE A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))        
   EXEC (@SSQL1)          
  END      
--Till here      
-------------------GST Changes(Mohanakrishna A.B) begins here      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Dist Food Lic No')      
 BEGIN      
  SET @SSQL1='UPDATE B SET B.[Dist Food Lic No]=R.DrugLicNo2       
  FROM RptBillTemplateFinal B INNER JOIN DISTRIBUTOR R ON B.[Distributor Code]=R.DistributorCode'      
  EXEC (@SSQL1)      
 END      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Dist Drug Lic no')      
 BEGIN      
  SET @SSQL1='UPDATE B SET B.[Dist Drug Lic no]=R.DrugLicNo1       
  FROM RptBillTemplateFinal B INNER JOIN DISTRIBUTOR R ON B.[Distributor Code]=R.DistributorCode'      
  EXEC (@SSQL1)       
 END      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='GSTTIN')      
 BEGIN      
  SET @SSQL1='UPDATE A SET A.[GSTTIN]=B.GSTTinNo FROM RptBillTemplateFinal A       
  INNER JOIN RetailerShipAdd B ON A.[Retailer ShipId]=B.RtrShipId INNER JOIN StateMaster C ON C.StateId=B.StateId'      
  EXEC (@SSQL1)      
 END      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='PAN Number')      
 BEGIN      
  SET @SSQL1='UPDATE B SET B.[Pan Number]=R.[ColumnValue]       
  FROM RptBillTemplateFinal B INNER JOIN (      
  SELECT R.RtrId,R.rtrcode,U.ColumnValue FROM UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      
  INNER JOIN retailer R on R.RtrId=U.MasterRecordId  WHERE US.MasterId=2   AND ColumnName=''PAN Number'' ) R ON B.[Retailer Code]=R.[rtrcode]'      
  EXEC (@SSQL1)      
 END      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Retailer Type')      
 BEGIN      
  SET @SSQL1='UPDATE B SET B.[Retailer Type]=R.[ColumnValue] FROM RptBillTemplateFinal B       
  INNER JOIN (SELECT R.RtrId,R.rtrcode,U.ColumnValue FROM UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      
  INNER JOIN Retailer R on R.RtrId=U.MasterRecordId  WHERE US.MasterId=2   AND ColumnName=''Retailer Type'' ) R ON B.[Retailer Code]=R.[rtrcode]'      
  EXEC (@SSQL1)      
 END      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='RelatedParty')      
 BEGIN      
  SET @SSQL1='UPDATE B SET B.[RelatedParty]=R.[ColumnValue] FROM RptBillTemplateFinal B       
  INNER JOIN (SELECT R.RtrId,R.rtrcode,U.ColumnValue FROM UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      
  INNER JOIN Retailer R on R.RtrId=U.MasterRecordId  WHERE US.MasterId=2   AND ColumnName=''Related Party'' ) R ON B.[Retailer Code]=R.[rtrcode]'      
  EXEC (@SSQL1)      
 END      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='State Name')      
 BEGIN      
  SET @SSQL1='UPDATE A SET A.[State Name]=C.StateName FROM RptBillTemplateFinal A       
  INNER JOIN RetailerShipAdd B ON A.[Retailer ShipId]=B.RtrShipId INNER JOIN StateMaster C ON C.StateId=B.StateId'      
  EXEC (@SSQL1)      
 END      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='State Code')      
 BEGIN      
  SET @SSQL1='UPDATE A SET A.[State Code]=C.StateCode FROM RptBillTemplateFinal A       
  INNER JOIN RetailerShipAdd B ON A.[Retailer ShipId]=B.RtrShipId INNER JOIN StateMaster C ON C.StateId=B.StateId'      
  EXEC (@SSQL1)      
 END      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='StateTinNo')      
 BEGIN      
  SET @SSQL1='UPDATE A SET A.[StateTinNo]=C.TinFirst2Digit FROM RptBillTemplateFinal A       
  INNER JOIN RetailerShipAdd B ON A.[Retailer ShipId]=B.RtrShipId INNER JOIN StateMaster C ON C.StateId=B.StateId'      
  EXEC (@SSQL1)       
 END      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='HSNCode')      
 BEGIN      
  SET @SSQL1='UPDATE B SET B.[HSNCode]=R.[ColumnValue] FROM RptBillTemplateFinal B       
  INNER JOIN (select R.prdid,R.prdccode,U.ColumnValue from UdcDetails u inner JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      
  INNER JOIN product  R on R.prdid=U.MasterRecordId  where US.MasterId=1   and ColumnName=''HSN Code'' ) R ON B.[Product Code]=R.[prdccode]'      
  EXEC (@SSQL1)      
 END      
   IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND b.name='HSNDescription')      
 BEGIN      
  SET @SSQL1='UPDATE B SET B.[HSNDescription]=R.[ColumnValue] FROM RptBillTemplateFinal B       
  INNER JOIN (SELECT R.prdid,R.prdccode,U.ColumnValue FROM UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      
  INNER JOIN Product  R on R.prdid=U.MasterRecordId  WHERE US.MasterId=1   AND ColumnName=''HSN Description'' ) R ON B.[Product Code]=R.[prdccode]'      
  EXEC (@SSQL1)      
 END      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='DistributorGstTin')      
 BEGIN      
  SET @SSQL1='UPDATE B SET B.[DistributorGstTin]=R.ColumnValue  FROM RptBillTemplateFinal B INNER JOIN (      
  SELECT D.DistributorCode,u.ColumnValue from UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      
  INNER JOIN Distributor D ON D.DistributorId=u.MasterRecordId WHERE US.MasterId=16  and ColumnName=''GSTIN'') R on B.[Distributor Code]=R.DistributorCode'      
  EXEC (@SSQL1)      
 END      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='DistributorStateName')      
 BEGIN      
  SELECT StateCode,StateName,TinFirst2Digit,DistributorCode      
  INTO #DistState       
  FROM UDCHD A (NOLOCK)      
  INNER JOIN UdcMaster B (NOLOCK) ON A.MasterId=B.MasterId      
  INNER JOIN UdcDetails C (NOLOCK) ON B.MasterId=C.MasterId      
  AND B.UdcMasterId=C.UdcMasterId      
  INNER JOIN UdcDefault D (NOLOCK) ON D.MasterId=C.MasterId AND D.MasterId=B.MasterId      
  AND D.UdcMasterId=C.UdcMasterId AND D.UdcMasterId=B.UdcMasterId      
  INNER JOIN StateMaster E (NOLOCK) ON E.StateName=D.ColValue AND E.StateName=C.ColumnValue      
  INNER JOIN Distributor DB ON DB.DistributorId=C.MasterRecordId      
  WHERE MasterName='Distributor Info Master' AND ColumnName='State Name'      
  SET @SSQL1='UPDATE B SET B.[DistributorStateName]=R.StateName,DistributorStateCode=R.StateCode,       
  DistributorStateTinNo=R.TinFirst2Digit FROM RptBillTemplateFinal B INNER JOIN #DistState R ON B.[Distributor Code]=R.DistributorCode'       
  EXEC (@SSQL1)      
  DROP TABLE #DistState      
 END      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='Distributor Type')      
 BEGIN      
  SET @SSQL1='UPDATE B SET B.[Distributor Type]=R.ColumnValue  FROM RptBillTemplateFinal B INNER JOIN (      
  SELECT D.DistributorCode,u.ColumnValue from UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      
  INNER JOIN Distributor D ON D.DistributorId=u.MasterRecordId where US.MasterId=16  AND ColumnName=''Distributor Type'') R on B.[Distributor Code]=R.DistributorCode'      
  EXEC (@SSQL1)      
 END      
 IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='AadharNo')      
 BEGIN      
  SET @SSQL1='UPDATE B SET B.[AadharNo]=R.ColumnValue  FROM RptBillTemplateFinal B INNER JOIN (      
  SELECT D.DistributorCode,u.ColumnValue from UdcDetails u INNER JOIN UdcMaster US ON u.UdcMasterId=US.UdcMasterId      
  INNER JOIN Distributor D ON D.DistributorId=u.MasterRecordId where US.MasterId=16  AND ColumnName=''Aadhar No'') R on B.[Distributor Code]=R.DistributorCode'      
  EXEC (@SSQL1)      
 END      
 -------------------GST Changes(Mohanakrishna) Ends here      
  IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='Grammage')          
  BEGIN       
     --SET @SSQL1=' UPDATE RPT SET RPT.Grammage=X.Grammage FROM RptBillTemplateFinal RPT (NOLOCK)       
     --    INNER JOIN (      
     --     SELECT SP.[Sales Invoice Number],P.PRDID,P.PrdCCode,P.PrdDCode,U.PrdUnitCode,ISNULL(      
     --     CASE U.PRDUNITID WHEN 2 THEN ISNULL(SUM(PrdWgt * SP.[Base Qty]),0)/1000      
     --     WHEN 3 THEN ISNULL(SUM(PrdWgt * SP.[Base Qty]),0) END,0) AS Grammage      
     --     FROM RptBillTemplateFinal SP (NOLOCK)      
     --     INNER JOIN Product P (NOLOCK) ON P.PrdCCode=SP.[Product Code]      
     --     INNER JOIN PRODUCTUNIT U (NOLOCK) ON P.PrdUnitId=U.PrdUnitId      
     --     WHERE SP.USRID=      
     --     GROUP BY P.PRDID,P.PrdCCode,P.PrdDCode,U.PrdUnitCode,U.PRDUNITID,SP.[Sales Invoice Number]      
     --    ) X ON X.PrdCCode=RPT.[PRODUCT CODE] AND X.[Sales Invoice Number]=RPT.[Sales Invoice Number] WHERE RPT.UsrId='+CAST(@Pi_UsrId AS VARCHAR(10))+''
	                
     SET @SSQL1=' UPDATE RPT SET RPT.Grammage=X.Grammage FROM RptBillTemplateFinal RPT (NOLOCK)       
         INNER JOIN (      
          SELECT SP.[Sales Invoice Number],P.PRDID,P.PrdCCode,P.PrdDCode,P.PrdWgt Grammage      
          FROM RptBillTemplateFinal SP (NOLOCK)      
          INNER JOIN Product P (NOLOCK) ON P.PrdCCode=SP.[Product Code]      
          WHERE SP.USRID='+CAST(@Pi_UsrId AS VARCHAR(10))+'      
         ) X ON X.PrdCCode=RPT.[PRODUCT CODE] AND X.[Sales Invoice Number]=RPT.[Sales Invoice Number] WHERE RPT.UsrId='+CAST(@Pi_UsrId AS VARCHAR(10))+''               
     EXEC (@SSQL1)          
  END      
  IF EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.ID=B.id WHERE A.name='RptBillTemplateFinal' AND B.name='[SalesInvoice NetAmount Actual]')      
  BEGIN      
   SET @SSQL1='UPDATE A SET A.[SalesInvoice NetAmount Actual]=B.OrgNetAmount       
    FROM RptBillTemplateFinal A INNER JOIN SalesInvoice B (NOLOCK) ON A.Salid=B.SalId'      
   EXEC (@SSQL1)       
  END
 IF EXISTS (SELECT A.SalId FROM SalInvoiceDeliveryChallan A INNER JOIN SalesInvoice B ON A.SalId=B.SalId INNER JOIN RptBillToPrint C ON C.[Bill Number]=SalInvNo)      
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
	 --------------- Added by lakshman M Dated ON 11-04-2019 PMS ID: ILCRSTPAR4044 
	  UPDATE D SET D.PrdtDefaultPricevalue  = Round(cast(PBD.PrdBatDetailValue As Numeric(18,2)),2)
	  FROM SalesInvoice S (NOLOCK)        
	  INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId  
	  INNER JOIn Product P ON P.Prdid =SP.Prdid       
	  INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId     
	  INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1     
	  INNER JOIN rptbilltemplatefinal D ON D.Salid = S.SalId AND SP.SalId = D.Salid AND D.[Distributor Product Code] =P.Prdccode   
	  WHERE PBD.SLNo =3
	  ------------ Till here ------------
 RETURN      
END
GO
--ILCRSTPAR4044	--> Quick sync process sync status validation included
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='Tbl_UploadIntegration_QS' AND XTYPE ='U')
DROP TABLE Tbl_UploadIntegration_QS
GO
CREATE TABLE Tbl_UploadIntegration_QS (
	[SequenceNo] [int] NULL,
	[ProcessName] [varchar](100) NULL,
	[FolderName] [varchar](200) NULL,
	[PrkTableName] [varchar](200) NULL,
	[CreatedDate] [datetime] NULL
)
GO
IF EXISTS(SELECT * FROM TBL_Uploadintegration where ProcessName ='Retailer')
BEGIN
DELETE FROM TBL_Uploadintegration where ProcessName ='Retailer'
END
GO
IF NOT EXISTS(SELECT * FROM Tbl_UploadIntegration_QS WHERE PROCESSNAME ='Retailer')
BEGIN
DELETE FROM Tbl_UploadIntegration_QS WHERE PROCESSNAME ='Retailer'
INSERT INTO Tbl_UploadIntegration_QS
SELECT 1,'Retailer','Retailer','Cs2Cn_Prk_Retailer',GETDATE()
END
GO
IF NOT EXISTS(SELECT * from Configuration where ModuleName='DataTransfer' AND ModuleId = 'DATATRANSFER47')
BEGIN
DELETE FROM Configuration where ModuleName='DataTransfer' AND ModuleId = 'DATATRANSFER47'
INSERT INTO Configuration
SELECT 'DATATRANSFER47','DataTransfer','Auto Sync after Login Every                          Hours / Mins',1,'',1.00,47
END
GO
IF EXISTS(SELECT * FROM  SYSOBJECTS WHERE NAME ='Fn_Returnsyncstatus' AND TYPE ='FN')
DROP FUNCTION Fn_Returnsyncstatus
GO
CREATE FUNCTION Fn_Returnsyncstatus()
RETURNS INT
AS
/***********************************************************************************************
DATE			AUTHOR			CR/BZ		USER STORY ID		DESCRIPTION 
************************************************************************************************
11-04-2019		Lakshman M		 SR		 	ILCRSTPAR4044		Quick sync process sync status validation included .
*************************************************************************************************/
BEGIN
	DECLARE @Exists INT
	DECLARE @ConfigValue Numeric(18,2)
	DECLARE @Status tinyint
	SET @Exists=0
	SET @Status = 0
	
	IF EXISTS (
	SELECT * FROM MandatoryDeployment WHERE HFixID = (SELECT MAX(HFixID) FROM MandatoryDeployment) 
	AND MantatoryStatus = 1 AND FileDownloaded = 1 AND DeploymentSatus = 0)
	BEGIN
		RETURN(@Exists)	
	END 
	
	IF EXISTS(SELECT * from Configuration where ModuleName='DataTransfer' AND ModuleId = 'DATATRANSFER47')
	BEGIN
		SELECT @Status = Status from Configuration where ModuleName='DataTransfer' AND ModuleId = 'DATATRANSFER47'
		SELECT @ConfigValue = ConfigValue * 60 from Configuration where ModuleName='DataTransfer' AND ModuleId = 'DATATRANSFER47'
	END
	ELSE
	BEGIN
		RETURN(@Exists)	
	END
	
	IF @Status = 1 AND ISNULL(@ConfigValue,0.00) > 0.00
	BEGIN
		IF EXISTS (SELECT * FROM SyncStatus  WHERE DATEDIFF(minute,DwnEndTime,GETDATE()) > @ConfigValue)
		BEGIN
			SET @Exists=1
		END
	END
RETURN(@Exists)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='CustomUpDownloadCount_QS' AND TYPE ='U')
BEGIN
CREATE TABLE CustomUpDownloadCount_QS (
	[SlNo] [int] NOT NULL,
	[SeqNo] [int] NOT NULL,
	[Module] [nvarchar](100) NOT NULL,
	[Screen] [nvarchar](100) NOT NULL,
	[ParkTable] [nvarchar](100) NOT NULL,
	[MainTable] [nvarchar](100) NOT NULL,
	[KeyField1] [nvarchar](100) NOT NULL,
	[KeyField2] [nvarchar](100) NOT NULL,
	[KeyField3] [nvarchar](100) NOT NULL,
	[UpDownload] [nvarchar](100) NOT NULL,
	[OldMax] [nvarchar](100) NOT NULL,
	[OldCount] [int] NOT NULL,
	[NewMax] [nvarchar](100) NOT NULL,
	[NewCount] [int] NOT NULL,
	[DownloadedCount] [int] NOT NULL,
	[SelectQuery] [nvarchar](4000) NOT NULL
)
END
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='SyncErrorStatus' AND TYPE ='U')
BEGIN
CREATE TABLE SyncErrorStatus (
	[DistCode] [nvarchar](50) NULL,
	[ErrorStatus] [nvarchar](10) NULL,
	[SyncStartDate] [datetime] NULL,
	[SyncEndDate] [datetime] NULL,
	[ServerDate] [datetime] NULL
)
END
GO
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='Tbl_DownloadIntegration_QS' AND TYPE ='U')
CREATE TABLE Tbl_DownloadIntegration_QS (
	[SequenceNo] [int] NULL,
	[ProcessName] [varchar](100) NULL,
	[PrkTableName] [varchar](100) NULL,
	[SPName] [varchar](100) NULL,
	[TRowCount] [int] NULL,
	[SelectCount] [int] NULL,
	[CreatedDate] [datetime] NULL
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Cs2Cn_SyncRecDetUpdate_QS' AND TYPE ='P')
DROP PROCEDURE Proc_Cs2Cn_SyncRecDetUpdate_QS
GO
CREATE PROCEDURE Proc_Cs2Cn_SyncRecDetUpdate_QS  
(  
 @Po_ErrNo AS INT OUTPUT,  
    @Sever_Date AS DATETIME  
)  
AS  
/*************************************************************  
* Procedure : Proc_Cs2Cn_SyncRecDetUpdate  
* PURPOSE : To Update SyncId And Generate Record details   
* CREATED BY : Praveenraj B  
* CREATED DATE : 18/07/2012  
*************************************************************/  
BEGIN  
 DECLARE @ParkTable AS NVARCHAR(100)  
 DECLARE @ProcessName AS NVARCHAR(100)  
 DECLARE @CurrValue AS NUMERIC(38,0)  
 DECLARE @DEL_SSQL AS NVARCHAR(1000)  
 DECLARE @SSQL AS NVARCHAR(1000)  
 DECLARE @IN_SQL AS NVARCHAR(1000)  
 DECLARE @SyncId AS NUMERIC(38,0)  
 DECLARE @DistCode AS NVARCHAR(100)  
  SELECT @SyncId=MAX(SyncId) FROM Sync_Master  
  SELECT @DistCode=DistributorCode FROM Distributor   
 DECLARE Cur_ParkTable CURSOR FOR SELECT PrkTableName,ProcessName FROM Tbl_UploadIntegration_QS  ORDER BY SequenceNo   
 OPEN Cur_ParkTable  
 FETCH NEXT FROM Cur_ParkTable INTO @ParkTable,@ProcessName  
 WHILE @@FETCH_STATUS=0  
 BEGIN  
   SET @SSQL=''  
   SET @SSQL='UPDATE '+@ParkTable+' SET SyncId ='+CAST(@SyncId AS NVARCHAR(20))+',ServerDate ='''+CONVERT(VARCHAR(30),@Sever_Date,120)+''''  
   EXEC (@SSQL)  
   SET @DEL_SSQL=''  
   SET @DEL_SSQL='DELETE FROM Sync_RecordDetails WHERE ProcessName= '''+@ProcessName+''' AND SyncId= '+CAST(@SyncId AS NVARCHAR(25))  
   EXEC (@DEL_SSQL)  
   SET @IN_SQL=''  
   SET @IN_SQL='INSERT INTO Sync_RecordDetails(DistCode,SyncId,SyncDate,ProcessName,RecCount)'  
   SET @IN_SQL=@IN_SQL +' SELECT ''' +@DistCode+ ''',''' +CAST(@SyncId AS NVARCHAR(25))+''',GETDATE(),''' +@ProcessName+ ''',COUNT(Slno) FROM ' +@ParkTable  
   EXEC (@IN_SQL)  
 FETCH NEXT FROM Cur_ParkTable INTO @ParkTable,@ProcessName  
 END  
 CLOSE Cur_ParkTable  
 DEALLOCATE Cur_ParkTable  
END 
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_DownloadNotification_QS' AND TYPE ='P')
DROP PROCEDURE Proc_DownloadNotification_QS
GO
CREATE PROCEDURE Proc_DownloadNotification_QS
(  
  @Pi_UpDownload  INT,  
  @Pi_Mode  INT,  
  @Pi_SyncType INT        
)  
AS  
/*********************************  
* PROCEDURE  : Proc_DownloadNotification  
* PURPOSE  : To get the Download Notification  
* CREATED  : Nandakumar R.G  
* CREATED DATE : 25/01/2010  
* MODIFIED  
* DATE   AUTHOR    DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}  
*********************************/  
BEGIN  
SET NOCOUNT ON  
 /*  
 @Pi_UpDownload = 1 -->Download  
 @Pi_UpDownload = 2 -->Upload  
 @Pi_Mode  = 1 -->Before  
 @Pi_Mode  = 2 -->After  
 */  
 DECLARE @Str NVARCHAR(4000)  
 DECLARE @SlNo INT  
 DECLARe @Module  NVARCHAR(200)  
 DECLARE @MainTable NVARCHAR(200)  
 DECLARE @KeyField1 NVARCHAR(200)  
 DECLARE @KeyField2 NVARCHAR(200)  
 DECLARE @KeyField3 NVARCHAR(200)  
 DECLARE @DistCode NVARCHAR(100)  
 SELECT @DistCode=DistributorCode FROM Distributor  
 DELETE FROM Cs2Cn_Prk_DownloadedDetails WHERE UploadFlag='Y'  
 IF @Pi_UpDownload =1  
 BEGIN   
  UPDATE CustomUpDownloadCount SET DownloadedCount=0 WHERE UpDownload='Download' 
  DECLARE Cur_DwCount  Cursor  
  FOR SELECT DISTINCT SlNo,Module,MainTable,KeyField1,KeyField2,KeyField3 FROM CustomUpDownloadCount_QS (NOLOCK)   
  WHERE UpDownload='Download'    
  ORDER BY SlNo    
  OPEN Cur_DwCount  
  FETCH NEXT FROM Cur_DwCount INTO @SlNo,@Module,@MainTable,@KeyField1,@KeyField2,@KeyField3  
  WHILE @@FETCH_STATUS=0  
  BEGIN  
   IF @Pi_Mode=1  
   BEGIN  
    IF @KeyField1='DownloadFlag'  
    BEGIN  
     SELECT @Str='UPDATE CustomUpDownloadCount_QS SET OldMax=0,OldCount=0 WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount_QS WHERE SlNo=@SlNo   
    END  
    ELSE IF @KeyField1<>'' AND @KeyField3=''   
    BEGIN  
     SELECT @Str='UPDATE CustomUpDownloadCount_QS SET OldMax=A.OldMax,OldCount=A.OldCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS OldMax,ISNULL(COUNT('+@KeyField1+'),0) AS OldCount FROM '+@MainTable+') A  
     WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount_QS WHERE SlNo=@SlNo   
    END  
    ELSE IF @KeyField1<>'' AND @KeyField3<>''   
    BEGIN  
     SELECT @Str='UPDATE CustomUpDownloadCount_QS SET OldMax=A.OldMax ,OldCount=A.OldCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS OldMax,ISNULL(COUNT('+@KeyField1+'),0) AS OldCount FROM '+@MainTable+' WHERE '+@KeyField3+') A  
     WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount_QS WHERE SlNo=@SlNo   
    END  
   END  
   ELSE IF @Pi_Mode=2  
   BEGIN    
    IF @KeyField1='DownloadFlag'  
    BEGIN  
     IF @Module<>'Purchase Order'  
     BEGIN  
      SELECT @Str='UPDATE CustomUpDownloadCount_QS SET NewMax=A.NewMax,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT('+@KeyField1+'),0) AS NewCount FROM '+@MainTable+' WHERE DownLoadFlag=''Y'') A  
      WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount_QS WHERE SlNo=@SlNo  
     END  
     ELSE  
     BEGIN  
      SELECT @Str='UPDATE CustomUpDownloadCount_QS SET NewMax=A.NewMax,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT(DISTINCT '+@KeyField3+'),0) AS NewCount FROM '+@MainTable+' WHERE DownLoadFlag=''Y'') A  
      WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount_QS WHERE SlNo=@SlNo  
     END  
    END  
    ELSE IF @KeyField1<>'' AND @KeyField3=''   
    BEGIN  
     SELECT @Str='UPDATE CustomUpDownloadCount_QS SET NewMax=A.NewMax,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT('+@KeyField1+'),0) AS NewCount FROM '+@MainTable+') A  
     WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount_QS WHERE SlNo=@SlNo   
    END  
    ELSE IF @KeyField1<>'' AND @KeyField3<>''   
    BEGIN  
     SELECT @Str='UPDATE CustomUpDownloadCount_QS SET NewMax=A.NewMax ,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT('+@KeyField1+'),0) AS NewCount FROM '+@MainTable+' WHERE '+@KeyField3+') A  
     WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount_QS WHERE SlNo=@SlNo   
    END  
   END  
   EXEC (@Str)  
   IF @Pi_Mode=2  
   BEGIN    
    UPDATE CustomUpDownloadCount_QS SET DownloadedCount=NewCount-OldCount WHERE UpDownload='Download'  
    SET @Str=''  
    SELECT @Str=REPLACE(SelectQuery,'OldMax',OldMax) FROM CustomUpDownloadCount_QS WHERE UpDownload='Download' AND SlNo=@SlNo  
    IF @Str<>''  
    BEGIN  
     SET @Str=REPLACE(@Str,'SELECT ',' SELECT '''+@DistCode+''','''+@Module+''',')  
     IF @SlNo=218 OR @SlNo=214  
     BEGIN  
      SET @Str='INSERT INTO Cs2Cn_Prk_DownloadedDetails(DistCode,Process,Detail1,Detail2,Detail3) '+@Str  
     END  
     ELSE  
     BEGIN  
      SET @Str='INSERT INTO Cs2Cn_Prk_DownloadedDetails(DistCode,Process,Detail1,Detail2)'+@Str  
     END  
     print @SlNo  
     print @Str  
     EXEC (@Str)  
     UPDATE Cs2Cn_Prk_DownloadedDetails SET DownLoadedDate=GETDATE(),UploadFlag='N' WHERE UploadFlag IS NULL  
     UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail1=''  WHERE Detail1  IS NULL  
     UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail2=''  WHERE Detail2  IS NULL  
     UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail3=''  WHERE Detail3  IS NULL  
     UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail4=''  WHERE Detail4  IS NULL  
     UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail5=''  WHERE Detail5  IS NULL  
     UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail6=''  WHERE Detail6  IS NULL  
     UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail7=''  WHERE Detail7  IS NULL  
     UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail8=''  WHERE Detail8  IS NULL  
     UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail9=''  WHERE Detail9  IS NULL  
     UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail10='' WHERE Detail10 IS NULL  
    END  
   END  
   FETCH NEXT FROM Cur_DwCount INTO @SlNo,@Module,@MainTable,@KeyField1,@KeyField2,@KeyField3  
  END  
  CLOSE Cur_DwCount  
  DEALLOCATE Cur_DwCount  
 END  
END
GO
--CRCRSTPAR0042(In Report Grand Total values added report wise.)
IF EXISTS(SELECT * from RPTGRIDVIEW WHERE RPTID = 291 AND EXCELVIEW =1)
BEGIN
UPDATE A SET EXCELVIEW =0,PDFView =1 FROM RPTGRIDVIEW A WHERE RPTID = 291 AND EXCELVIEW =1
END
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel1')      
DROP TABLE RptDebitNoteTopSheet_Excel1
GO
CREATE TABLE RptDebitNoteTopSheet_Excel1      
(      
	[Scheme Description] VARCHAR(100),      
	[From] VARCHAR(10),      
	[To] VARCHAR(10),      
	[Circular No] VARCHAR(100),      
	[Date] NVARCHAR(10),      
	[Scheme Budget] NUMERIC(18,6),      
	[Sec Sales Qty] BIGINT,      
	[Sec Sales Value] NUMERIC(18,6),      
	[%Lib on Sec Sales] NUMERIC(18,6),      
	[Claim Amount] NUMERIC(18,6)      
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel2')    
DROP TABLE RptDebitNoteTopSheet_Excel2
GO
CREATE TABLE RptDebitNoteTopSheet_Excel2      
(      
	[Name Of the Category] NVARCHAR(200),      
	[From] VARCHAR(10),      
	[TO] VARCHAR(10),      
	[Circular No] VARCHAR(50),      
	[Monthly Target] NUMERIC(38,6),      
	[Last 2 Mont Avg Sal] NUMERIC(18,6),      
	[Current Month] NUMERIC(18,6),      
	[No of Incent Outlets] NUMERIC(18,0),      
	[Total Discount Amount] NUMERIC(38,6)      
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel3') 
DROP TABLE RptDebitNoteTopSheet_Excel3
GO
CREATE TABLE RptDebitNoteTopSheet_Excel3    
(    
	 [Name Of the Category] NVARCHAR(200),    
	 [From] VARCHAR(12),    
	 [TO] VARCHAR(12),    
	 [Total Normal Amount] NUMERIC(18,2),    
	 [Total Normal Sec Sales AS Per TOT] NUMERIC(18,2),  ------------ column name Altered by lakshman M Dated On 30-04-2019 PMS ID: ILCRSTPAR4224
	 [TOT Diff claims] NUMERIC(18,2)     
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel4')     
DROP TABLE RptDebitNoteTopSheet_Excel4
GO
CREATE TABLE RptDebitNoteTopSheet_Excel4      
(      
	[Scheme Description] NVARCHAR(200),      
	[From] DATETIME,      
	[TO] DATETIME,      
	[Circular No] NVARCHAR(100),      
	[Scheme Budget] NUMERIC(18,2),      
	[Sec Sales Value] NUMERIC(18,2),      
	[%Lib on Sec Sales] NUMERIC(18,2),      
	[Claim Amount] NUMERIC(18,2)      
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='RptDebitNoteTopSheet_Excel_GrandTotal' AND TYPE ='U')
DROP TABLE RptDebitNoteTopSheet_Excel_GrandTotal
GO
CREATE TABLE RptDebitNoteTopSheet_Excel_GrandTotal
(
	[Scheme Description] [nvarchar](200) NULL,
	[From] [nvarchar](100),
	[TO] [nvarchar](100),
	[Circular No] [nvarchar](100) NULL,
	[Column1] [nvarchar](200) NULL,
	[Column2] [nvarchar](200) NULL,
	[Column3] [nvarchar](200) NULL,
	[Column4] [nvarchar](200) NULL,
	[Column5] [nvarchar](200) NULL,
	[Column6] [nvarchar](200) NULL 
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_RptDebitNoteTopSheet'AND TYPE ='P')
DROP PROCEDURE Proc_RptDebitNoteTopSheet
GO
/*
BEGIN TRAN
EXEC Proc_RptDebitNoteTopSheet 291,2,0,'',0,0,1    
SELECT * FROM RptDebitNoteTopSheet_Excel1    
SELECT * FROM RptDebitNoteTopSheet_Excel2 
SELECT * FROM RptDebitNoteTopSheet_Excel3 
SELECT * FROM RptDebitNoteTopSheet_Excel4
SELECT * FROM RptDebitNoteTopSheet_Excel_GrandTotal
ROLLBACK TRAN    
*/    
CREATE PROCEDURE Proc_RptDebitNoteTopSheet
(    
 @Pi_RptId   INT,    
 @Pi_UsrId   INT,    
 @Pi_SnapId   INT,    
 @Pi_DbName   NVARCHAR(50),    
 @Pi_SnapRequired INT,@Pi_GetFromSnap  INT,    
 @Pi_CurrencyId  INT    
)    
AS    
/************************************************************************************************************************************    
* PROCEDURE : Proc_RptDebitNoteTopSheet    
* PURPOSE : To Return the Scheme Utilization Details    
* CREATED : Aravindh Deva C    
* CREATED DATE : 27 05 2016    
* NOTE  : Parle SP for Debit Note Top Sheet    
* MODIFIED     
*************************************************************************************************************************************    
* DATE       AUTHOR   CR/BZ USER STORY ID           DESCRIPTION                             
*************************************************************************************************************************************    
10-10-2017  Mohana.S		CR		CCRSTPAR0172        Included Circular Date and scheme Budget     
04-12-2017  Mohana			BZ		ICRSTPAR6760		Added New Function for calculating Scheme utilized for selected month    
07-12-2017  Mary.S			BZ		ICRSTPAR6933		Excel Sheet row Witdth change        
13-12-2017  Mohana.S		CR		ICRSTPAR6933		Changed Sampling Amount as Zero (default)       
09-01-2018  Lakshman M		BZ      ICRSTPAR7284        LCTR Formula validation changed.(special price not consider in LCTR Value).    
26-03-2018  Mohana S		CR		CCRSTPAR0187		TOT Diff Claims Report Created.     
08-05-2018  Mohana S		SR      ILCRSTPAR0500       included Removed Scheme Products.     
09-05-2018  Mohana S		BZ		ILCRSTPAR0506       chaged the target data selection    
10-05-2018  Mohana S		BZ      ILCRSTPAR0546		Sales return issue fix in Trade schemes    
08-06-2018  Muthulakshmi.V  BZ      ILCRSTPAR0909       Scheme valid date checking condition changed    
25-07-2018  Lakshman M		BZ		ILCRSTPAR1496       Scheme code valdiation included from CS.    
30-08-2018  Amuthakumar P	BZ		ILCRSTPAR1917		Changed Sampling Amount from Sample Issue ( FreeIssueDt)    
19-09-2018  Amuthakumar P	BZ		CRCRSTAPAR0023		Debit note Top Sheet not Consider un-salable Sales return / Manual Claim Report Inserted    
09-10-2018  Mohana P		BZ		ILCRSTPAR2313       TAX CALCULATION CHANGED AS PER CLIENT REQUEST    
12-10-2018  Mohana P		BZ		ILCRSTPAR2343       TAX CALCULATION CHANGED AS PER CLIENT REQUEST    
16-10-2018  Mohana P		BZ		ILCRSTPAR2343       Incorprated LIVE Changes in UAT (AS per Awanish discussion, LIVE REport is correct. So we have changed based on live)    
07-12-2018  Lakshman M      BZ      ILCRSTPAR2760       As per Client request manual claim valdaition included.    
19-12-2018  Vasantharaj R   SR      ILCRSTPAR2868       As per Client request [All the report must be generate based on Date range selection.]     
12-03-2019  Lakshman M		SR      CRCRSTPAR0037       As per Client request scheme category type validation included from CS.    
15-03-2019  Lakshman M		SR		ILCRSTPAR3767       As per Client request scheme category non trade scheme Sec sales qty and sec sales values validation included from CS.     
17-04-2019  Lakshman M		CR		CRCRSTPAR0042       In Report Grand Total values added report wise.
25-04-2019  lakshman M      SR      ILCRSTPAR4201       IN Report GRAND Total validation included.
30-04-2019  Lakshman M      SR      ILCRSTPAR4224       column name altered for this report
************************************************************************************************************************************/         
BEGIN    
 SET NOCOUNT ON    
     
 DECLARE @FromDate   AS DATETIME    
 DECLARE @ToDate    AS DATETIME    
 SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)    
 SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)    
      
 --Report 1    
 DECLARE @CityName AS NVARCHAR(100)    
 DECLARE @DistributorCode AS NVARCHAR(40)    
 DECLARE @DistributorName AS NVARCHAR(100)    
 DECLARE @DBMonth As INT    
     
 EXEC Proc_SchUtilization_Report @FromDate,@ToDate    
     
 SELECT @DistributorCode = DistributorCode, @DistributorName = DistributorName,    
 @CityName = G.GeoName    
 FROM Distributor D (NOLOCK),    
 Geography G (NOLOCK) WHERE D.GeoMainId = G.GeoMainId    
     
 --Added By Mohana     
     
 --SELECT @DBMonth = COUNT(*) FROM ACMaster  A INNER JOIN ACPeriod B ON A.AcmId=B.AcmId WHERE AcmYr = YEAR (GETDATE()) AND AcmSdt < =@ToDate    
 SELECT @DBMonth = CASE MONTH (@ToDate)     
  WHEN 4 THEN 1    
  WHEN 5 THEN 2    
  WHEN 6 THEN 3    
  WHEN 7 THEN 4    
  WHEN 8 THEN 5    
  WHEN 9 THEN 6    
  WHEN 10 THEN 7    
  WHEN 11 THEN 8    
  WHEN 12 THEN 9    
  WHEN 1 THEN 10    
  WHEN 2 THEN 11    
  WHEN 3 THEN 12    
 END     
 --Report 1    
      
 --Report 2    
 DECLARE @slno AS INT    
     
 DECLARE @SamplingAmount AS NUMERIC(18,2)    
 SELECT @slno = SlNo FROM BatchCreation WHERE FieldDesc = 'Selling Price'    
     
 --- Change by Amuthakumar P ILCRSTPAR1917    
 SELECT @SamplingAmount = ISNULL(SUM(D.TotalAmt),0)    
 FROM FreeIssueHd J (NOLOCK),    
 FreeIssueDt D (NOLOCK),    
 ProductBatchDetails P (NOLOCK)    
 WHERE J.IssueId = D.IssueId     
 AND P.PrdBatId = D.PrdBatId AND P.PriceId = D.PriceId     
 AND P.SLNo = 3 AND J.IssueDate BETWEEN @FromDate AND @ToDate    
 --Report 2    
     
 --- Till Here ILCRSTPAR1917    
     
 --Report 3    
 EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate    
     
 SELECT * INTO #ParleOutputTaxPercentage FROM ParleOutputTaxPercentage (NOLOCK)     
     
 -------------------- Added by Lakshman M On 07/11/2017 PMS_ICRSTPAR6575-------------------    
  -------------- Scheme code validation added by LAkshman M Dated By On 25/07/2018 PMS ID:ILCRSTPAR1496 ------------    
  SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,        
  B.DefaultPriceId ActualPriceId,SP.SlNo,sp.PrdTaxAmount,PrdUnitSelRate,PrdBatDetailValue,CAST(0 AS Int) AS Schid        
  INTO #BillingDetails        
  FROM SalesInvoice S (NOLOCK)        
  INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId        
  INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId     
  INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1      
  --INNER JOIN Debitnote_Scheme D ON D.Salid = S.SalId AND SP.SalId = D.Salid AND D.Prdid =SP.PrdID AND D.linetype = 1    
  WHERE S.SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3 and PBD.SLNo =3    
      
  SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,        
  B.DefaultPriceId,SP.SlNo,SP.PrdEditSelRte,sp.PrdTaxAmt as prdtaxamount,PrdUnitSelRte as  PrdUnitSelRate,PrdBatDetailValue,CAST(0 AS Int) AS Schid        
  INTO #ReturnDetails        
  FROM ReturnHeader S (NOLOCK)        
  INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID        
  INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId        
  INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1    
  and StockTypeId IN (SELECT StockTypeId FROM STOCKTYPE WHERE SystemStockType = 1)     
 --INNER JOIN Debitnote_Scheme D ON D.Salid = S.ReturnID AND SP.ReturnID = D.Salid  AND D.linetype = 2    
  WHERE S.ReturnDate BETWEEN  @FromDate AND @ToDate AND S.[Status] = 0 and PBD.SLNo =3    
        
  SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,CAST (0 AS NUMERIC(18,6)) AS ActualSellRate,prdtaxamount,    
PrdBatDetailValue as PrdUnitSelRate,Schid,       
  CAST (0 AS NUMERIC(18,6)) AS LCTR    
  INTO #DebitSalesDetails        
  FROM         
  (        
  SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,prdtaxamount,PrdBatDetailValue,Schid  FROM #BillingDetails       
  UNION ALL        
  SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,DefaultPriceId ,SlNo,prdtaxamount,PrdBatDetailValue,Schid  FROM #ReturnDetails        
  ) Consolidated     
 ------------------ Till Here ----------------------    
  UPDATE M SET M.ActualSellRate = round(D.PrdBatDetailValue,2)        
  FROM #DebitSalesDetails M (NOLOCK),        
  ProductBatchDetails D (NOLOCK)         
  WHERE M.ActualPriceId = D.PriceId AND D.SLNo = 3     
     
 ---------------- commented by Lakshman M on 07/11/2017 ---------------      
 --UPDATE R SET R.LCTR = R.BaseQty * (R.ActualSellRate+(R.ActualSellRate*(T.TaxPerc/100)))    
 --FROM #DebitSalesDetails R (NOLOCK),    
 --#ParleOutputTaxPercentage T (NOLOCK)    
 --WHERE R.SalId = T.Salid AND R.Slno = T.PrdSlno AND T.TransId = R.TransType    
  -----------------------    
  UPDATE R SET R.LCTR = ROUND(((R.BaseQty *(R.PrdUnitSelRate))+(R.BaseQty*R.PrdUnitSelRate)*(T.TaxPerc/100)),2)          
  FROM #DebitSalesDetails R (NOLOCK),        
  #ParleOutputTaxPercentage T (NOLOCK)    
  WHERE R.SalId = T.Salid AND R.Slno = T.PrdSlno AND T.TransId = R.TransType      
     
 CREATE TABLE #ApplicableProduct    
 (    
  SchId  INT,    
  PrdId   INT    
 )    
     
 INSERT INTO #ApplicableProduct(SchId,PrdId)    
 SELECT DISTINCT A.SchId,B.Prdid    
  FROM SchemeMaster A    
  INNER JOIN SchemeProducts B ON A.Schid = B.Schid    
  INNER JOIN Product C On B.Prdid = C.PrdId    
  WHERE A.SchemeLvlMode = 0 AND B.PrdId <> 0    
 UNION ALL    
 SELECT DISTINCT A.SchId,E.Prdid    
  FROM SchemeMaster A    
  INNER JOIN SchemeProducts B ON A.Schid = B.Schid    
  INNER JOIN ProductCategoryValue C ON     
  B.PrdCtgValMainId = C.PrdCtgValMainId     
  INNER JOIN ProductCategoryValue D ON    
  D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'    
  INNER JOIN Product E On    
  D.PrdCtgValMainId = E.PrdCtgValMainId     
  INNER JOIN ProductBatch F On    
  F.PrdId = E.Prdid    
  WHERE A.SchemeLvlMode = 0 AND B.PrdCtgValMainId <> 0    
 UNION ALL    
 SELECT DISTINCT S.SchId,B.MasterRecordId    
  FROM SchemeProducts A     
  INNER JOIN UdcDetails B on B.UDCUniqueId =A.PrdCtgValMainId     
  INNER JOIN SchemeMaster S ON A.SchId = S.SchId    
  WHERE S.SchemeLvlMode = 1    
      
  --added by mohana ILCRSTPAR0500     
 INSERT INTO #ApplicableProduct(SchId,PrdId)    
 SELECT Schid ,PrdId FROM SchemeMasterControlHistory A INNER JOIN SchemeMaster B ON A.CmpSchCode = B.CmpSchCode    
 INNER JOIN Product C ON c.PrdCCode = A.FromValue    
 WHERE ChangeType='Remove'   AND B.SchId in (SELECT SchId FROM SchemeProducts Where PrdCtgValMainId = 0 )    
     
 INSERT INTO #ApplicableProduct(SchId,PrdId)      
 SELECT DISTINCT A.SchId,E.Prdid    
 FROM SchemeMaster A    
 INNER JOIN SchemeMasterControlHistory B ON A.CmpSchCode = B.CmpSchCode    
 INNER JOIN ProductCategoryValue C ON     
 B.FromValue = C.PrdCtgValCode    
 INNER JOIN ProductCategoryValue D ON    
 D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'    
 INNER JOIN Product E On    
 D.PrdCtgValMainId = E.PrdCtgValMainId     
 INNER JOIN ProductBatch F On    
 F.PrdId = E.Prdid    
 WHERE A.SchemeLvlMode = 0  AND A.SchId in (SELECT SchId FROM SchemeProducts Where PrdId = 0 )    
 AND ChangeType='Remove'      
      
 CREATE TABLE #ApplicableScheme    
 (    
  SchId   INT,    
  SchDsc   NVARCHAR(100),    
  SchValidFrom DATETIME,    
  SchValidTill DATETIME,     
  Budget   NUMERIC(18,2),    
  BudgetAllocationNo VARCHAR(100),    
  PrdId   INT    
 )    
     
 INSERT INTO #ApplicableScheme (SchId,SchDsc,SchValidFrom,SchValidTill,Budget,BudgetAllocationNo,PrdId)       
 SELECT DISTINCT A.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,S.Budget,S.BudgetAllocationNo, A.PrdId    
 FROM #ApplicableProduct A (NOLOCK),    
 SchemeMaster S (NOLOCK)    
 WHERE A.SchId = S.SchId AND A.SchId  IN (SELECT SCHID FROM Debitnote_Scheme)     
 AND S.Claimable = 1    
     
 --Added CircularNo and date By Mohana    
 --SELECT S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,    
 --SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,    
 --CAST(0 AS NUMERIC(18,6)) Amount    
 --INTO #SchemeDebit    
 --FROM #ApplicableScheme S (NOLOCK),    
 --#DebitSalesDetails B (NOLOCK) ,    
 --SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode     
 --WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId AND S.SchId in (SELECT DISTINCT  SCHID FROM DEbitnote_Scheme)     
 --GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate    
 --ORDER BY S.SchId    
 --SchemeCirculardetails    
       
 SELECT S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,    
 SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,    
 CAST(0 AS NUMERIC(18,6)) Amount    
 INTO #SchemeDebit1    
 FROM #ApplicableScheme S (NOLOCK),    
 #DebitSalesDetails B (NOLOCK) ,    
 SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana    
 WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=1 AND    
 --PMS NO:ILCRSTPAR0909    
 --S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 --AND S.SchValidTill  BETWEEN @FromDate AND @ToDate    
 --(S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 --or S.SchValidTill  BETWEEN @FromDate AND @ToDate)    
 (B.Transdate BETWEEN @FromDate AND @ToDate    
 OR B.TransDate BETWEEN @FromDate AND @ToDate)----PMS NO:ILCRSTPAR1309 Till Here    
 AND SM.cmpschcode in (select Cmpschcode from SchemeCategorydetails where Schcategory_type IN ('Trade Scheme'))    
 GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,Transdate    
 ORDER BY S.SchId    
 ---------------------- Added By lakshman  Dated On 16-03-2019 PMS ID: ILCRSTPAR3767    
 --INSERT INTO #SchemeDebit1     
 --SELECT DISTINCT APS.Schid,APS.SchDsc,APS.SchValidFrom,APS.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,    
 --SUM(SP.BaseQty) [SecSalesQty],CAST(SUM(SP.PrdActualNetAmount) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,CAST(0 AS NUMERIC(18,6)) Amount    
 --from SalesInvoice S     
 --inner join SalesInvoiceproduct SP ON S.salid =sp.salid     
 --inner join SalesInvoiceSchemeLineWise SIL ON SIL.salid=s.salid and SIL.salid =SP.salid AND SIL.prdid =sp.prdid and sil.prdbatid =sp.PrdBatId     
 --inner join #DebitSalesDetails DS ON DS.salid =S.salid AND DS.salid =SP.salid AND DS.salid =SIl.salid and DS.prdid =SP.prdid and DS.prdbatid = SP.prdbatid AND DS.prdid =SP.prdid and DS.prdbatid =SIl.prdbatid      
 --inner join #ApplicableScheme APS ON APS.schid = SIL.schid AND APS.prdid =DS.prdid AND APS.Prdid =SIL.Prdid     
 --inner join SchemeMaster SM ON SM.schid =SIL.Schid AND SM.Schid =APS.Schid     
 --LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana    
 --WHERE APS.PrdId = DS.PrdId AND APS.SchId=SM.SchId  and Transtype=1 AND    
 ----PMS NO:ILCRSTPAR0909    
 ----S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 ----AND S.SchValidTill  BETWEEN @FromDate AND @ToDate    
 ----(S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 ----or S.SchValidTill  BETWEEN @FromDate AND @ToDate)    
 --(DS.Transdate BETWEEN @FromDate AND @ToDate    
 --OR DS.TransDate BETWEEN @FromDate AND @ToDate)----PMS NO:ILCRSTPAR1309 Till Here    
 --AND SM.cmpschcode in (select Cmpschcode from SchemeCategorydetails where Schcategory_type not IN ('Trade Scheme'))    
 --GROUP BY APS.SchId,APS.SchDsc,APS.SchValidFrom,APS.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate    
 --ORDER BY APS.SchId    

INSERT INTO #SchemeDebit1     
SELECT APS.Schid,APS.SchDsc,APS.SchValidFrom,APS.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,    
 SUM(SP.BaseQty) [SecSalesQty],Round(CAST((sum(SP.BaseQty*PrdBatDetailValue)+ (sum(SP.BaseQty*PrdBatDetailValue)*(T.TaxPerc/100))) AS Numeric(18,2)),2)  AS  [SecSalesVal],    
 CAST(0 AS NUMERIC(18,6)) Liab,CAST(0 AS NUMERIC(18,6)) Amount    
 from SalesInvoice S     
 inner join SalesInvoiceproduct SP ON S.salid =sp.salid     
 inner join SalesInvoiceSchemeLineWise SIL ON SIL.salid=s.salid and SIL.salid =SP.salid AND SIL.prdid =sp.prdid and sil.prdbatid =sp.PrdBatId     
 inner join #DebitSalesDetails DS ON DS.salid =S.salid AND DS.salid =SP.salid AND DS.salid =SIl.salid and DS.prdid =SP.prdid and DS.prdbatid = SP.prdbatid AND DS.prdid =SP.prdid and DS.prdbatid =SIl.prdbatid      
 inner join #ApplicableScheme APS ON APS.schid = SIL.schid AND APS.prdid =DS.prdid AND APS.Prdid =SIL.Prdid     
 inner join SchemeMaster SM ON SM.schid =SIL.Schid AND SM.Schid =APS.Schid     
 inner join #ParleOutputTaxPercentage T ON T.salid =DS.salid and S.salid =T.salid and SP.Salid =T.salid AND SP.Salid =SIL.Salid and DS.slno =T.PrdSlno and T.TransId = DS.TransType     
 LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana    
 inner join ProductBatchDetails D on D.prdbatid=SIL.prdbatid and D.prdbatid=Sp.prdbatid and D.SlNo=3 and DefaultPrice=1    
 WHERE APS.PrdId = DS.PrdId AND APS.SchId=SM.SchId  and Transtype=1 AND    
 --PMS NO:ILCRSTPAR0909    
 --S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 --AND S.SchValidTill  BETWEEN @FromDate AND @ToDate    
 --(S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 --or S.SchValidTill  BETWEEN @FromDate AND @ToDate)    
 (DS.Transdate BETWEEN @FromDate AND @ToDate    
 OR DS.TransDate BETWEEN @FromDate AND @ToDate)----PMS NO:ILCRSTPAR1309 Till Here    
 AND SM.cmpschcode in (select Cmpschcode from SchemeCategorydetails where Schcategory_type NOT IN ('Trade Scheme'))    
 GROUP BY APS.SchId,APS.SchDsc,APS.SchValidFrom,APS.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,SP.BaseQty,PrdBatDetailValue,T.TaxPerc    
 ORDER BY APS.SchId    
     
 ---------------- Till here -----------------    
 INSERT INTO #SchemeDebit1    
 SELECT S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,    
 SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,    
 CAST(0 AS NUMERIC(18,6)) Amount    
 FROM #ApplicableScheme S (NOLOCK),    
 #DebitSalesDetails B (NOLOCK) ,    
 SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana    
 WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=2 AND     
 --PMSNo:ILCRSTPAR0909    
 --S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 --AND S.SchValidTill  BETWEEN @FromDate AND @ToDate    
 --(S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 --or S.SchValidTill  BETWEEN @FromDate AND @ToDate)    
 (B.Transdate BETWEEN @FromDate AND @ToDate    
 OR  B.Transdate  BETWEEN @FromDate AND @ToDate)    
 AND SM.cmpschcode in (select Cmpschcode from SchemeCategorydetails where Schcategory_type  IN ('Trade Scheme'))    
 GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,Transdate     
 ORDER BY S.SchId    
 ----------------- Added By lakshman M ON Dated ON 15-03-2019  PMS ID: ILCRSTPAR3767    
 INSERT INTO #SchemeDebit1    
 SELECT  APS.Schid,APS.SchDsc,APS.SchValidFrom,APS.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,    
 SUM(SP.BaseQty) [SecSalesQty],Round(cast((sum(SP.BaseQty*PrdBatDetailValue)+ (sum(SP.BaseQty*PrdBatDetailValue)*(T.TaxPerc/100))) AS Numeric(18,6)),2) AS  [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,CAST(0 AS NUMERIC(18,6)) Amount    
 from Returnheader S     
 inner join Returnproduct SP ON S.Returnid =sp.Returnid     
 inner join ReturnSchemeLineDt SIL ON SIL.Returnid=s.Returnid and SIL.Returnid =SP.Returnid AND SIL.prdid =sp.prdid and sil.prdbatid =sp.PrdBatId     
 inner join #DebitSalesDetails DS ON DS.salid =S.Returnid AND DS.salid =SP.Returnid AND DS.salid =SIl.Returnid and DS.prdid =SP.prdid and DS.prdbatid = SP.prdbatid AND DS.prdid =SP.prdid and DS.prdbatid =SIl.prdbatid      
 inner join #ApplicableScheme APS ON APS.schid = SIL.schid AND APS.prdid =DS.prdid AND APS.Prdid =SIL.Prdid     
 inner join SchemeMaster SM ON SM.schid =SIL.Schid AND SM.Schid =APS.Schid     
 inner join #ParleOutputTaxPercentage T ON T.salid =DS.salid and S.Returnid =T.salid and SP.Salid =T.salid AND SP.Salid =SIL.Returnid     
 and DS.slno =T.PrdSlno and T.TransId = DS.TransType     
 LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana     
 inner join ProductBatchDetails D on D.prdbatid=SIL.prdbatid and D.prdbatid=Sp.prdbatid and D.SlNo=3 and DefaultPrice=1    
 WHERE APS.PrdId = DS.PrdId AND APS.SchId=SM.SchId  and Transtype=2 AND    
 --PMS NO:ILCRSTPAR0909    
 --S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 --AND S.SchValidTill  BETWEEN @FromDate AND @ToDate    
 --(S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 --or S.SchValidTill  BETWEEN @FromDate AND @ToDate)    
 (DS.Transdate BETWEEN @FromDate AND @ToDate    
 OR DS.TransDate BETWEEN @FromDate AND @ToDate)----PMS NO:ILCRSTPAR1309 Till Here    
 AND SM.cmpschcode in (select Cmpschcode from SchemeCategorydetails where Schcategory_type not IN ('Trade Scheme'))    
 GROUP BY APS.SchId,APS.SchDsc,APS.SchValidFrom,APS.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,SP.BaseQty,PrdBatDetailValue,T.TaxPerc    
 ORDER BY APS.SchId    
 ----------------- Till here ----------------    
     
 DELETE FROM #SchemeDebit1 WHERE SchId NOT IN (SELECT Schid FROM Debitnote_Scheme WHERE Linetype=1)          
     
 INSERT INTO #SchemeDebit1    
 SELECT  S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,    
 SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,    
 CAST(0 AS NUMERIC(18,6)) Amount    
 FROM #ApplicableScheme S (NOLOCK),    
 #DebitSalesDetails B (NOLOCK) ,    
 SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana    
 ,Debitnote_Scheme D       
 WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=2      
 AND S.Schid = D.Schid AND B.Prdid =D.Prdid AND B.Salid =D.Salid     
 AND S.SchId NOT IN (SELECT schid FROM #SchemeDebit1)    
 GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate    
 ORDER BY S.SchId    
  --- added on 12-MAr-2019    
  --INSERT INTO #SchemeDebit1     
  --SELECT  S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,    
  --SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,    
  --CAST(0 AS NUMERIC(18,6)) Amount    
  --FROM #ApplicableScheme S (NOLOCK),    
  --#DebitSalesDetails B (NOLOCK) ,    
  --SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana    
  --,Debitnote_Scheme D       
  --WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=2      
  --AND S.Schid = D.Schid AND B.Prdid =D.Prdid AND B.Salid =D.Salid     
  --AND S.SchId NOT IN (SELECT schid FROM #SchemeDebit1)    
  --AND SM.cmpschcode in (select Cmpschcode from SchemeCategorydetails where Schcategory_type IN ('Trade Scheme'))    
  --GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate    
  --ORDER BY S.SchId    
  --INSERT INTO #SchemeDebit1     
  --SELECT  S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,    
  --SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,    
  --CAST(0 AS NUMERIC(18,6)) Amount    
  --FROM #ApplicableScheme S (NOLOCK),    
  --#DebitSalesDetails B (NOLOCK) ,    
  --SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana    
  --,Debitnote_Scheme D       
  --WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=2      
  --AND S.Schid = D.Schid AND B.Prdid =D.Prdid AND B.Salid =D.Salid     
  --AND S.SchId NOT IN (SELECT schid FROM #SchemeDebit1)    
  --AND SM.cmpschcode in (select Cmpschcode from SchemeCategorydetails where Schcategory_type NOT IN ('Trade Scheme'))    
  --GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate    
  --ORDER BY S.SchId    
  -- end here 12-Mar-2019    
 SELECT  A.SchId,A.SchDsc,A.SchValidFrom,A.SchValidTill,SchemeBudget,CircularNo, CircularDate,    
 SUM(SecSalesQty) SecSalesQty,CAST(SUM(SecSalesVal) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,    
 CAST(0 AS NUMERIC(18,6)) Amount    
 INTO #SchemeDebit     
 from #SchemeDebit1 A    
 INNER JOIN SCHEMEMASTER B ON A.schid=B.schid and B.cmpschcode in (select Cmpschcode from SchemeCategorydetails where Schcategory_type IN ('Trade Scheme') )    
 GROUP BY A.SchId,A.SchDsc,a.SchValidFrom,a.SchValidTill,SchemeBudget,CircularNo, CircularDate    
 INSERT  INTO #SchemeDebit    
 SELECT  A.SchId,A.SchDsc,A.SchValidFrom,A.SchValidTill,SchemeBudget,CircularNo, CircularDate,    
 SUM(SecSalesQty) SecSalesQty,CAST(SUM(SecSalesVal) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,    
 CAST(0 AS NUMERIC(18,6)) Amount    
 from #SchemeDebit1 A    
 INNER JOIN SCHEMEMASTER B ON A.schid=B.schid and B.cmpschcode in (select Cmpschcode from SchemeCategorydetails where Schcategory_type NOT IN ('Trade Scheme') )    
 GROUP BY A.SchId,A.SchDsc,a.SchValidFrom,a.SchValidTill,SchemeBudget,CircularNo, CircularDate    
     
   --ILCRSTPAR2868    
         
 SELECT DISTINCT TaxPerc,B.SalId,B.PrdId  INTO #TaxPerc FROM SalesInvoiceProduct B     
 INNER JOIN ParleOutputTaxPercentage P ON P.SalId = B.SalId and  B.SlNo = P.PrdSlno AND TRANSID = 1     
 --Till Here     
      
 SELECT Schid,SUM(Schamt) SchAmt ,Sum(taxamt) TaxAmt INTO #SchFinal FROM     
  (    
  SELECT A.SchId,SUM(A.schamt) SchAmt, (SUM(A.schamt)*(TaxPerc/100)) TaxAmt     
   FROM (    
  --ILCRSTPAR2868    
  --SELECT Schid ,a.PRDID,TaxPerc,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt FROM Debitnote_Scheme A     
  --INNER JOIN SalesInvoiceProduct B ON A.Salid = b.SalId AND a.Prdid = b.PrdId      
  --INNER JOIN ParleOutputTaxPercentage P ON P.SalId = B.SalId AND A.Salid = P.SalId AND B.SlNo = P.PrdSlno AND TRANSID = 1 AND Linetype = 1    
  --GROUP BY  A.PRDID,A.SchId,TaxPerc    
  SELECT  Schid ,a.PRDID,TaxPerc,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt FROM Debitnote_Scheme A     
  INNER JOIN #TaxPerc B ON A.Salid = b.SalId AND a.Prdid = b.PrdId AND Linetype = 1     
  GROUP BY  A.PRDID,A.SchId,TaxPerc    
  --Till Here    
  )A    
  GROUP BY A.SchId,TaxPerc    
  )B Group by  sCHID     
  insert into #SchFinal    
  SELECT Schid,SUM(Schamt) SchAmt ,Sum(taxamt) TaxAmt FROM     
  (    
  SELECT A.SchId,SUM(A.schamt) SchAmt, (SUM(A.schamt)*(TaxPerc/100)) TaxAmt        
  FROM (    
  SELECT Schid ,a.PRDID,TaxPerc,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt FROM Debitnote_Scheme A INNER JOIN RETURNPRODUCT B ON A.Salid = b.ReturnID AND a.Prdid = b.PrdId     
  INNER JOIN ParleOutputTaxPercentage P ON P.SalId = B.ReturnID AND A.Salid = P.SalId AND B.SlNo = P.PrdSlno AND TRANSID = 2 AND a.Linetype =2    
  and StockTypeId IN (SELECT StockTypeId FROM STOCKTYPE WHERE SystemStockType = 1)      
  GROUP BY  A.PRDID,A.SchId,TaxPerc    
  )A    
  GROUP BY A.SchId,TaxPerc    
  )B Group by  sCHID     
       
 UPDATE SD SET SD.Amount = CASE S.ApplyTaxForClaim WHEN 0 THEN schamt ELSE  (SchAmt+TaxAmt) END    
 FROM #SchemeDebit SD (NOLOCK) INNER JOIN (SELECT Schid,SUM(SchAmt) SchAmt ,Sum(Taxamt) TaxAmt FROM  #SchFinal GROUP BY Schid) D  ON SD.Schid = D.Schid --CHANGED FOR CLAIMAMT MISMATCH    
 INNER JOIN SchemeMaster S ON S.SchId = D.SCHID AND S.SchId = SD.SCHID     
     
 UPDATE SD SET SD.Liab = CAST(( SD.Amount / SD.[SecSalesVal]) AS NUMERIC(18,6))    
 FROM #SchemeDebit SD (NOLOCK)    
 WHERE SD.[SecSalesVal] <> 0    
     
 --Report 3    
     
 --Report 4    
 DECLARE @TargetNo AS INT    
     
 DECLARE @InsFromDate AS DATETIME     
 DECLARE @InsToDate  AS DATETIME    
 DECLARE @Year AS INT     
 DECLARE @Month  AS INT    
 DECLARE @MonthName as Nvarchar(100)    
 --Changed by Mohana ILCRSTPAR0506     
 SELECT   TOP 1 @TargetNo = InsId,@Month=TargetMonth,@Year=TargetYear,    
 @InsFromDate = CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01',    
 @InsToDate = DATEADD(DD,-1,DATEADD(MM,1,CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01'))     
 FROM InsTargetHD H (NOLOCK)     
 INNER JOIN  JCMonth A  ON H.TargetMonth = A.JcmJc    
 INNER JOIN    JCMast b on a.JcmId = b.JcmId AND H.TargetYear =  B.JcmYr    
 WHERE A.JcmEdt  BETWEEN @FromDate AND @ToDate AND H.[Status] = 1     
 ORDER BY InsId DESC    
     
 SELECT @MonthName=MonthName FROM MonthDt (NOLOCK) WHERE MonthId=@Month    
 UPDATE InsTargetHD SET TargetMonth=EffFromMonthId WHERE TargetMonth=0    
     
 --EXEC Proc_LoadingInstitutionsTarget @TargetNo,@Pi_UsrId    
 EXEC Proc_LoadingInstitutionsTarget @Year,@Month,@MonthName,@Pi_UsrId    
     
 SELECT CtgMainId,CtgName,@InsFromDate FromDate,@InsToDate ToDate,SUM([Target]) [Target],SUM(ClmAmount) DiscAmount,    
 CAST(0 AS NUMERIC(18,6)) L2MSales,CAST(0 AS NUMERIC(18,6)) CurMSales,CAST(0 AS NUMERIC(18,0)) Outlet    
 INTO #Institutions    
 FROM InsTargetDetailsTrans (NOLOCK) WHERE CtgName <>''    
 --WHERE UserId = @Pi_UsrId AND SlNo <> 0 and SlNo<>9999    
 GROUP BY CtgMainId,CtgName    
     
 SELECT DISTINCT R.RtrId,RC.CtgMainId    
 INTO #FilterRetailer    
 FROM Retailer R (NOLOCK),    
 RetailerValueClassMap RVCM (NOLOCK),    
 RetailerValueClass RVC (NOLOCK),    
 RetailerCategory RC (NOLOCK),    
 RetailerCategoryLevel RCL (NOLOCK)    
 WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId    
 AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId    
 AND EXISTS (SELECT '' FROM #Institutions I (NOLOCK) WHERE I.CtgMainId = RC.CtgMainId)    
     
 SELECT S.CtgMainId,CAST(SUM(S.Sales) AS NUMERIC(18,2)) Sales    
 INTO #CurrentSales    
 FROM     
 (    
 SELECT R.CtgMainId,SUM(S.SalGrossAmount) Sales FROM SalesInvoice S (NOLOCK),    
 #FilterRetailer R    
 WHERE S.SalInvDate BETWEEN @InsFromDate AND @InsToDate AND S.DlvSts > 3    
 AND S.RtrId = R.RtrId    
 GROUP BY R.CtgMainId    
 UNION ALL    
 SELECT F.CtgMainId,-1 * SUM(R.RtnGrossAmt) FROM ReturnHeader R (NOLOCK),    
 #FilterRetailer F    
 WHERE R.ReturnDate BETWEEN @InsFromDate AND @InsToDate AND R.Status = 0    
 AND F.RtrId = R.RtrId    
 GROUP BY F.CtgMainId    
 ) AS S GROUP BY S.CtgMainId    
 SELECT R.CtgMainId,COUNT(DISTINCT S.RtrId) Outlet    
 INTO #NoOfOutlet    
 FROM SalesInvoice S (NOLOCK),    
 #FilterRetailer R    
 WHERE S.SalInvDate BETWEEN @InsFromDate AND @InsToDate AND S.DlvSts > 3    
 AND S.RtrId = R.RtrId    
 GROUP BY R.CtgMainId     
     
 --Last Two Month Sales    
 SELECT @InsToDate = DATEADD (D,-1,@InsFromDate)     
 SELECT @InsFromDate = DATEADD (MONTH,-2,@InsFromDate)     
     
 SELECT S.CtgMainId,CAST(SUM(S.Sales) AS NUMERIC(18,2)) Sales    
 INTO #L2MSales    
 FROM     
 (    
 SELECT R.CtgMainId,SUM(S.SalGrossAmount) Sales FROM SalesInvoice S (NOLOCK),    
 #FilterRetailer R    
 WHERE S.SalInvDate BETWEEN @InsFromDate AND @InsToDate AND S.DlvSts > 3    
 AND S.RtrId = R.RtrId    
 GROUP BY R.CtgMainId    
 UNION ALL    
 SELECT F.CtgMainId,-1 * SUM(R.RtnGrossAmt) FROM ReturnHeader R (NOLOCK),    
 #FilterRetailer F    
 WHERE R.ReturnDate BETWEEN @InsFromDate AND @InsToDate AND R.Status = 0    
 AND F.RtrId = R.RtrId    
 GROUP BY F.CtgMainId    
 ) AS S GROUP BY S.CtgMainId    
     
 UPDATE I SET I.CurMSales = C.Sales    
 FROM #Institutions I (NOLOCK),    
 #CurrentSales C (NOLOCK)    
 WHERE I.CtgMainId = C.CtgMainId    
 UPDATE I SET I.L2MSales = C.Sales / 2    
 FROM #Institutions I (NOLOCK),    
 #L2MSales C (NOLOCK)    
 WHERE I.CtgMainId = C.CtgMainId    
 UPDATE I SET I.Outlet = C.Outlet    
 FROM #Institutions I (NOLOCK),    
 #NoOfOutlet C (NOLOCK)    
 WHERE I.CtgMainId = C.CtgMainId    
 --Report 4    
 --Nagarajan on 28.Aug.2017    
     
 IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel1')    
 BEGIN    
  DROP TABLE RptDebitNoteTopSheet_Excel1     
 END     
     
 CREATE TABLE RptDebitNoteTopSheet_Excel1    
 (    
 [Scheme Description] VARCHAR(100),    
 [From] VARCHAR(10),    
 [To] VARCHAR(10),    
 [Circular No] VARCHAR(100),    
 [Date] NVARCHAR(10),    
 [Scheme Budget] NUMERIC(18,6),    
 [Sec Sales Qty] BIGINT,    
 [Sec Sales Value] NUMERIC(18,6),    
 [% Lib on Sec Sales] NUMERIC(18,6),    
 [Claim Amount] NUMERIC(18,6)    
 )       
 UPDATE #SchemeDebit SET Liab = (Amount / SecSalesVal) * 100 WHERE Liab > 0    
     
 SELECT S.SchDsc [Scheme Description],CONVERT(VARCHAR(10),S.SchValidFrom,103) [From],CONVERT(VARCHAR(10),S.SchValidTill,103) [To],ISNULL(S.CircularNo,'') [Circular No],    
  CONVERT(VARCHAR(10),S.CircularDate,103)  [Date],S.SchemeBudget [Scheme Budget],[SecSalesQty] [Sec Sales Qty],[SecSalesVal] [Sec Sales Value],CAST(Round(Liab,2) AS Numeric(18,2)) AS [% Liability on Sec Sales],    
  cast(round(Amount,2) as Numeric(18,2)) as  [Claim Amount],'A' As Dummy    
 INTO #RptDebitNoteTopSheet_Excel1    
 FROM #SchemeDebit S (NOLOCK) --WHERE Amount > 0     
 WHERE Amount <> 0 --- CRCRSTPAR0023  IF Difference of Claim Amt is Zero need not Shown --Changed as not equal to     
     
 IF (SELECT COUNT(*) FROM #RptDebitNoteTopSheet_Excel1) > 0    
 BEGIN    
  INSERT INTO #RptDebitNoteTopSheet_Excel1 ([Scheme Description],[Circular No],[Scheme Budget],[Sec Sales Qty],[Sec Sales Value],[Claim Amount],Dummy)
  SELECT 'Total' [Scheme Description], '' AS [Circular No],0 AS [Scheme Budget],    
  SUM([Sec Sales Qty]) AS [Sec Sales Qty],SUM([Sec Sales Value]) AS [Sec Sales Value],SUM([Claim Amount]) [Claim Amount],'B' Dummy    
  FROM  #RptDebitNoteTopSheet_Excel1   
 END    
     
 SELECT * INTO #Excel1 FROM #RptDebitNoteTopSheet_Excel1 ORDER BY Dummy    
     
 DECLARE @RecCount AS BIGINT    
 SELECT @RecCount = COUNT(7) FROM #RptDebitNoteTopSheet_Excel1    
     
 INSERT INTO RptDebitNoteTopSheet_Excel1    
 SELECT [Scheme Description],Cast(isnull([From],' ') As Varchar(10)) [From],Cast(isnull([To],' ') As Varchar(10)) [To],[Circular No],ISNULL([Date],' ') AS [Date] ,[Scheme Budget],    
 [Sec Sales Qty],[Sec Sales Value],[% Liability on Sec Sales] ,[Claim Amount]    
 FROM #Excel1 ORDER BY Dummy

 IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel2')    
 BEGIN    
  DROP TABLE RptDebitNoteTopSheet_Excel2     
 END      
 CREATE TABLE RptDebitNoteTopSheet_Excel2    
 (    
  [Name Of the Category] NVARCHAR(200),    
  [From] VARCHAR(10),    
  [TO] VARCHAR(10),    
  [Circular No] VARCHAR(50),    
  [Monthly Target] NUMERIC(38,6),    
  [Last 2 Mont Avg Sal] NUMERIC(18,6),    
  [Current Month] NUMERIC(18,6),    
  [No of Incent Outlets] NUMERIC(18,0),    
  [Total Discount Amount] NUMERIC(38,6)    
 )    
     
 SELECT CtgName [Name Of the Category],convert(varchar(10),FromDate,103) [From],convert(varchar(10),ToDate,103) [To],'' [Circular No],[Target] [Monthly Target],    
 L2MSales [Last 2 Months Avg Sales],CurMSales [Current Month],Outlet [No of Incentive Outlets],DiscAmount [Total Discount Amount],'A' Dummy    
 INTO #RptDebitNoteTopSheet_Excel2    
 FROM #Institutions (NOLOCK) 
    
 IF (SELECT COUNT(*) FROM #RptDebitNoteTopSheet_Excel2) > 0    
 BEGIN    
 ----------------- modified by lakshman M on 04/10/2017----------------        
  --INSERT INTO #RptDebitNoteTopSheet_Excel2        
  --SELECT 'Total' As [Name Of the Category],'' As [From],'' As [To],0 As [Circular No],0 As [Monthly Target],        
  --0 As [Last 2 Months Avg Sales],0 As [Current Month],0 As [No of Incentive Outlets],sum([Total Discount Amount]) [Total Discount Amount],'B' Dummy        
  --FROM #RptDebitNoteTopSheet_Excel2     
        
  Update A set [Name Of the Category]= null ,[From]=null,[To]=null,[Monthly Target]=null,[Last 2 Months Avg Sales]=null      
  ,[Current Month]=null,[No of Incentive Outlets]=null, [Total Discount Amount]=null,[Circular No]='' from #RptDebitNoteTopSheet_Excel2 A where Dummy ='B'      
    -------------------- Till here -----------------------------     
 END    
     
 SELECT * INTO #Excel2 FROM #RptDebitNoteTopSheet_Excel2 ORDER BY Dummy    
     
 INSERT INTO RptDebitNoteTopSheet_Excel2    
 SELECT [Name Of the Category],[From],[To],[Circular No],[Monthly Target],    
 [Last 2 Months Avg Sales],[Current Month],[No of Incentive Outlets],[Total Discount Amount]    
 FROM #Excel2  
 
 --------------- added by lakshman M Dated ON 20-08-2019 PMS ID: CRCRSTPAR0042  -------------------
 IF(SELECT COUNT(*) FROM RptDebitNoteTopSheet_Excel2) > 0
 BEGIN
 INSERT INTO RptDebitNoteTopSheet_Excel2  
  SELECT 'Total' AS [Name Of the Category],' '[From],' '[To],' ' AS [Circular No],SUM([Monthly Target]) AS [Monthly Target],    
 SUM([Last 2 Months Avg Sales]) AS [Last 2 Months Avg Sales],SUM([Current Month]) AS [Current Month],SUM([No of Incentive Outlets])  AS [No of Incentive Outlets],SUM([Total Discount Amount]) AS [Total Discount Amount]
 FROM #Excel2
 END
 ---------------- Till Here ----------------------
    
 ----------------------------------------------------TOT CLAIM Added By Mohana-------------------------------------------------------------------    
 DECLARE @RecCount1 INT    
 SELECT @RecCount1  = COUNT(*) FROM RptDebitNoteTopSheet_Excel2    
     
 CREATE Table #TotClaimFinal     
 (    
 CtgName  NVARCHAR(100),    
 Fromdate DATETIME,    
 Todate DATETIME,    
 NrmlRate NUMERIC (18,2),    
 SecSalesTot NUMERIC (18,2),    
 DiffClaims NUMERIC (18,2)     
 )    
 SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,CASE SP.SplPriceId WHEN 0 THEN 0 ELSE SP.Priceid END As  Priceid,       
 B.DefaultPriceId ActualPriceId,SP.SlNo,sp.PrdTaxAmount,PrdUnitSelRate,PrdBatDetailValue       
 INTO #BillingDetails1        
 FROM SalesInvoice S (NOLOCK)        
 INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId        
 INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId     
 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1       
 WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3 and PBD.SLNo =3    
     
 SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,CASE SP.SplPriceId WHEN 0 THEN 0 ELSE SP.Priceid END As  Priceid,      
 B.DefaultPriceId ActualPriceId,SP.SlNo,SP.PrdEditSelRte,sp.PrdTaxAmt as prdtaxamount,PrdUnitSelRte as  PrdUnitSelRate,PrdBatDetailValue      
 INTO #ReturnDetails1        
 FROM ReturnHeader S (NOLOCK)        
 INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND StockTypeid in (select stocktypeid from  stocktype where systemstocktype =1)       
 INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId        
 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1    
 WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.[Status] = 0 and PBD.SLNo =3    
 SELECT DISTINCT R.RtrId,RC.CtgMainId,RC.CtgName    
 INTO #Retailer    
 FROM Retailer R (NOLOCK),    
 RetailerValueClassMap RVCM (NOLOCK),    
 RetailerValueClass RVC (NOLOCK),    
 RetailerCategory RC (NOLOCK),    
 RetailerCategoryLevel RCL (NOLOCK)    
 WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId    
 AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId    
     
 SELECT tranid,Refid,Rtrid,CtgName,RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,SelRate,CAST(0 AS NUMERIC(18,2)) Nrmlrate,CAST(0 AS NUMERIC(18,2)) SplRate,CAST(0 AS NUMERIC(18,2)) Diff,Slno    
 INTO #TotClaim FROM(    
 SELECT 1 tranid,Salid Refid,A.Rtrid,CtgName,Salinvdate RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,PrdbatDetailvalue SelRate,Slno FROM #BillingDetails1 A  INNER JOIN #Retailer B ON A.Rtrid = B.Rtrid     
 UNION     
 SELECT 2 Transid,ReturnID Refid,A.Rtrid,CtgName,ReturnDate RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,PrdbatDetailvalue SelRate,Slno FROM #ReturnDetails1  A  INNER JOIN #Retailer B ON A.Rtrid = B.Rtrid     
 )A    
 SELECT DISTINCT Priceid,PrdBatDetailValue SplSelRate  INTO #ExistingSpecialPrice FROM    
 (    
 SELECT D.PriceId,D.PrdBatDetailValue     
 FROM #TotClaim M (NOLOCK),    
 ProductBatchDetails D (NOLOCK)     
 WHERE M.PriceId = D.PriceId AND D.SLNo = 3    
 AND PriceCode LIKE '%-Spl Rate-%'       
 UNION     
 SELECT D.PriceId,D.PrdBatDetailValue     
 FROM #TotClaim M (NOLOCK),    
 ProductBatchDetails D (NOLOCK)     
 WHERE M.PriceId = D.PriceId AND D.SLNo = 3    
 AND PriceCode LIKE '%SplRate%'      
 )A    
     
  UPDATE A SET A.SplRate = (BaseQty*((B.SplselRate)+(B.SplselRate*(p.TaxPerc/100)))) FROM  #TotClaim A INNER JOIN #ExistingSpecialPrice B    
  ON A.Priceid = B.Priceid     
  INNER JOIN  ParleOutputtaxPercentage P ON A.Refid = p.salid and A.slno = p.prdslno AND A.Tranid=P.Transid    
  WHERE A.Priceid <>0    
     
     
  UPDATE A SET A.SplRate = (BaseQty*(( SelRate)+(SelRate*(P.TaxPerc/100)))) FROM  #TotClaim A     
   INNER JOIN  #ParleOutputtaxPercentage P ON A.Refid = p.salid and a.slno = p.prdslno AND A.Tranid=P.Transid    
  WHERE A.Priceid =0    
     
  UPDATE A SET A.NrmlRate = (BaseQty*(( SelRate)+(SelRate*(P.TaxPerc/100)))) FROM  #TotClaim A     
  INNER JOIN  #ParleOutputtaxPercentage P ON A.Refid = p.salid and a.slno = p.prdslno AND A.Tranid=P.Transid    
      
  UPDATE A SET A.Diff = (NrmlRate-SplRate) FROM  #TotClaim A      
      
  INSERT INTO #TotClaimFinal(CtgName,NrmlRate,SecSalesTot,DiffClaims)    
  SELECT CtgName,SUM(NrmlRate),SUM(SplRate),SUM(Diff) FROM #TotClaim    
  GROUP BY Ctgname     
      
  UPDATE A SET Fromdate = B.Frmdt ,Todate = B.todt FROM #TotClaimFinal A  INNER JOIN (SELECT Ctgname,MIn(RefDate) Frmdt,Max(RefDate) todt FROM #TotClaim GROUP BY CtgName) B ON A.CtgName = B.Ctgname    
      
 IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel3')    
 BEGIN    
  DROP TABLE RptDebitNoteTopSheet_Excel3     
 END      
 CREATE TABLE RptDebitNoteTopSheet_Excel3    
 (    
	 [Name Of the Category] NVARCHAR(200),    
	 [From] VARCHAR(12),    
	 [TO] VARCHAR(12),    
	 [Total Normal Amount] NUMERIC(18,2),    
     [Total Normal Sec Sales AS Per TOT] NUMERIC(18,2),    ------------ column name altered by lakshman M Dated On 30-04-2019 PMS ID: ILCRSTPAR4224
     [TOT Diff claims] NUMERIC(18,2)     
 )    
      
  INSERT INTO RptDebitNoteTopSheet_Excel3    
  SELECT * FROM #TotClaimFinal    
  WHERE DiffClaims > 0 --- CRCRSTPAR0023  IF Difference of Claim Amt is Zero need not Shown    
  
  ----------- added by lakshman M Dated ON 20-08-2019 PMS ID: CRCRSTPAR0042 
  IF( SELECT COUNT(*) FROM RptDebitNoteTopSheet_Excel3)> 0
  BEGIN
  INSERT INTO RptDebitNoteTopSheet_Excel3 
  SELECT 'Total' AS CtgName,' ' AS Fromdate,' ' AS Todate ,SUM(NrmlRate) AS NrmlRate, SUM(SecSalesTot) AS SecSalesTot ,sum(DiffClaims) AS DiffClaims from #TotClaimFinal WHERE DiffClaims > 0
  --UPDATE A SET [From] =' ' ,[TO] =' '  from RptDebitNoteTopSheet_Excel3 A WHERE [TOT Diff claims] > 0 AND [Name Of the Category] ='Total'
  END

 SET @RecCount = @RecCount + 1    
     
 SET @RecCount1 = @RecCount1 +@RecCount + 1    
      
 -- Till here    
     
 ----------------------------------------MANUAL CLAIM Added By Amuthakumar CRCRSTAPAR0023 ---------------------------------------------    
     
---------------- Added By Lakshman M Dated ON 07-12-2018 PMS ID: ILCRSTPAR2760 -----------     
 --SELECT MCD.DESCRIPTION,MCM.MacDate As [From], MCM.MacDate AS [To],MCM.MacRefNo,ProposedLibPercent,TotalSales,ActualLibPercent,ClaimAmt    
 --INTO #TotManualClaim    
 --FROM ManualClaimMaster MCM INNER JOIN ManualClaimDetails MCD ON MCM.MacRefNo = MCD.MacRefNo    
 --WHERE MacDate BETWEEN @FromDate AND @ToDate ------- commented by lakshman M on dated on 07-12-2018    
 SELECT MCD.DESCRIPTION,A.MacDate As [From], A.MacDate AS [To],MCD.CircularNo,ProposedLibPercent,TotalSales,ActualLibPercent,ClaimAmt    
 INTO #TotManualClaim from ManualClaimMaster A     
 INNER JOIN ManualClaimDetails MCD ON A.MacRefNo = MCD.MacRefNo    
 INNER JOIN  JCMonth B ON A.Jcmid = B.Jcmid AND A.FromJcmJcid = B.JcmJc AND A.ToJcmJcId = B.JcmJc     
 WHERE Jcmsdt  between @FromDate   AND @ToDate AND JcmEdt between @FromDate   AND @ToDate    
 ----------------- Till Here -------------    
 IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel4')    
 BEGIN    
  DROP TABLE RptDebitNoteTopSheet_Excel4     
 END      
 CREATE TABLE RptDebitNoteTopSheet_Excel4    
 (    
  [Scheme Description] NVARCHAR(200),    
  [From] DATETIME,    
  [TO] DATETIME,    
  [Circular No] NVARCHAR(100),    
  [Scheme Budget] NUMERIC(18,2),    
  [Sec Sales Value] NUMERIC(18,2),    
  [% Lib on Sec Sales] NUMERIC(18,2),    
  [Claim Amount] NUMERIC(18,2)    
 )    
       
  INSERT INTO RptDebitNoteTopSheet_Excel4    
  SELECT * FROM #TotManualClaim
  ----------- added by lakshman M Dated ON 20-08-2019 PMS ID: CRCRSTPAR0042 
  IF (SELECT count(*) FROM RptDebitNoteTopSheet_Excel4) >0
  BEGIN
  INSERT INTO RptDebitNoteTopSheet_Excel4 ([Scheme Description],[Sec Sales Value],[Claim Amount])
  SELECT 'Total' AS [Scheme Description],ISNULL(SUM(TotalSales),0) AS [Sec Sales Value],ISNULL(SUM(ClaimAmt),0) AS [Claim Amount] 
  FROM #TotManualClaim
  END 
      
 DECLARE @RecCount2 INT  
 DECLARE @RecCountAct2 INT    
 SELECT @RecCount2  = COUNT(*) FROM RptDebitNoteTopSheet_Excel3    
 
   
 set @RecCount1 = @RecCount1+1    
 SET @RecCount2 = @RecCount2 + @RecCount1 + 1    
        
 -- Till Here CRCRSTAPAR0023    
 -------------- Added by lakshmn M Dated ON 25-04-2019 PMS ID: ILCRSTPAR4201  --------------
truncate table RptDebitNoteTopSheet_Excel_GrandTotal

INSERT INTO RptDebitNoteTopSheet_Excel_GrandTotal 
--SELECT 'GRAND TOTAL','','','',0,0,SUM([Claim Amount]) [Claim Amount],SUM([TOT Diff claims]) [TOT Diff claims],SUM([Total disc Amount]) [Total disc Amount],SUM([claim amount1]) [claim amount1]
SELECT 'GRAND TOTAL','','','','','','','','',SUM([Claim Amount]) +SUM([TOT Diff claims]) +SUM([Total discount Amount]) +SUM([claim amount1]) [claim amount1]
FROM (
SELECT 0 [Claim Amount],0 [TOT Diff claims],0 [Total discount Amount],[claim amount] [claim amount1] FROM RptDebitNoteTopSheet_Excel1  WHERE [Scheme Description] ='Total'
UNION ALL 
SELECT 0,0, [Total discount Amount],0 FROM RptDebitNoteTopSheet_Excel2 WHERE [Name Of the Category] ='Total'
UNION ALL 
SELECT 0,[TOT Diff claims],0,0 FROM RptDebitNoteTopSheet_Excel3 WHERE [Name Of the Category] = 'Total'
UNION ALL 
SELECT  [Claim Amount],0,0,0 FROM RptDebitNoteTopSheet_Excel4 WHERE [SCHEMe description] ='Total'
)A

 
 DECLARE @RecCount3 INT    
 SELECT @RecCount3  = COUNT(*) FROM RptDebitNoteTopSheet_Excel4

   
 SELECT @RecCount3  = @RecCount2+ @RecCount3  + 1  
 ---------- till here ------------------
-- select @RecCount3,@RecCount2,@RecCount1

 TRUNCATE TABLE RptExcelDebitNote      
       
 INSERT INTO RptExcelDebitNote(Row,Col,MergeCells,Value)    
 SELECT 1,1,'A1:J1','PARLE - DEBIT NOTE / CREDIT NOTE'    
 UNION ALL    
 SELECT 2,1,'A2:J2',''   --ICRSTPAR6933 (Row Number Changed OlRowNo+1)    
 UNION ALL    
 SELECT 3,1,'A3:H3','Name of the Town : ' + ISNULL(@CityName,'')    
 UNION ALL    
 SELECT 3,9,'I3:J3','Passed by SO / SE :'    
 UNION ALL    
 SELECT 4,1,'A4:F4','Name of the Wholesaler : ' + ISNULL(@DistributorName,'')    
 UNION ALL    
 SELECT 4,7,'G4:H4','Debit Note No :' + CONVERT(NVARCHAR(10),@DBMonth)    
 UNION ALL    
 SELECT 4,9,'I4:J4','Verified by ASM :'    
 UNION ALL    
 SELECT 5,1,'A5:F5','Wholesaler Code : ' + ISNULL(@DistributorCode,'')    
 UNION ALL    
 SELECT 5,7,'G5:H5','Credit Note No :'    
 UNION ALL    
 SELECT 5,9,'I5:J5','Authorized by DSM :'    
 UNION ALL    
 SELECT 6,1,'A6:F6','Name of the Division :'    
 UNION ALL    
 SELECT 6,7,'G6:H6','Credit Note Date :'    
 UNION ALL    
 SELECT 6,9,'I6:J6','Value of Approved credit note :'    
 UNION ALL    
 SELECT 7,1,'A7:J7',''    
 UNION ALL     
 SELECT 8,1,'A8:J8','1.SAMPLING'    
 UNION ALL    
 SELECT 9,1,'A9:E9','DSM Sanction Letter Date '    
 UNION ALL    
 SELECT 9,6,'F9:J9','Sampling Amount : ' + CAST(@SamplingAmount AS VARCHAR(30))    
 UNION ALL    
 SELECT 10,1,'A10:D10','Product Sampled during the period  '    
 UNION ALL    
 SELECT 10,5,'E10:G10','From : ' + CONVERT(VARCHAR(11),@FromDate,105)    
 UNION ALL    
 SELECT 10,8,'H10:J10','To : ' + CONVERT(VARCHAR(11),@ToDate,105)    
 UNION ALL    
 SELECT 11,1,'A11:J11',''     
 UNION ALL    
 SELECT 12,1,'A12:J12','2.TRADE SCHEME'     
 UNION ALL    
 SELECT 13,C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel1'    
 UNION ALL    
 SELECT 14,1,'A14','1R'     
 UNION ALL    
 SELECT 14 + @RecCount + 1,1,'A' + CAST(14 + @RecCount + 1 AS VARCHAR(10)) + ':J' + CAST(14 + @RecCount + 1 AS VARCHAR(10)) ,'3.INSTITUTIONAL SALES'     
 UNION ALL    
 SELECT 14 + @RecCount + 2,C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel2'    
 UNION ALL    
 SELECT 14 + @RecCount + 3,1,'A' + CAST(14 + @RecCount + 3 AS VARCHAR(10)),'2R'    
 UNION ALL    
 SELECT 14 + @RecCount,1,'A' + CAST(14 + @RecCount AS VARCHAR(10)) + ':' + 'J' + CAST(14 + @RecCount AS VARCHAR(10)),''     
 UNION ALL--Added By Mohana    
 SELECT 15,1,'A15','1R'    
 UNION ALL    
 SELECT 15 + @RecCount1 + 2,1,'A' + CAST(15 + @RecCount1 + 2 AS VARCHAR(10)) + ':J' + CAST(15 + @RecCount1 + 2 AS VARCHAR(10)) ,'4.TOT DIFF CLAIMS'     
 UNION ALL    
  SELECT 15 + @RecCount1 + 4,C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel3'    
  UNION ALL    
  SELECT 15 + @RecCount1 + 6,1,'A' + CAST(15 + @RecCount1 + 6 AS VARCHAR(10)),'3R'    
 UNION ALL    
 SELECT 15 + @RecCount1+5,1,'A' + CAST(15 + @RecCount1+5 AS VARCHAR(10)) + ':' + 'J' + CAST(15 + @RecCount1+5 AS VARCHAR(10)),''     
 UNION ALL--Till Here    
 --Added By Amuthakumar  CRCRSTAPAR0023    
 SELECT 16,1,'A14','1R'    
 UNION ALL    
 SELECT 16 + @RecCount2 + 9,1,'A' + CAST(16 + @RecCount2 + 9 AS VARCHAR(10)) + ':J' + CAST(16 + @RecCount2 + 9 AS VARCHAR(10)) ,'5.MANUAL CLAIM'     
 UNION ALL    
  SELECT 16 + @RecCount2 + 11,C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel4'    
  UNION ALL    
  SELECT 16 + @RecCount2 + 13,1,'A' + CAST(16 + @RecCount2 + 13 AS VARCHAR(10)),'4R'    
 UNION ALL    
 SELECT 16 + @RecCount2 + 12,1,'A' + CAST(16 + @RecCount2+12 AS VARCHAR(10)) + ':' + 'J' + CAST(16 + @RecCount2+12 AS VARCHAR(10)),''   
 UNION ALL        
  SELECT 17 + @RecCount3 + 15,1,'A' + CAST(16 + @RecCount3 + 13 AS VARCHAR(10)),'5R' -------------- Added by lakshmn M Dated ON 25-04-2019 PMS ID: ILCRSTPAR4201  --------------
 -- UNION ALL
 --SELECT 17 + '@RecCount3 + 15, C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel_GrandTotal'      
 UNION ALL--Till Here  CRCRSTAPAR0023    
 SELECT 0,10,'B15','ColumnWidth'      
 UNION ALL    
 SELECT 0,10,'C14','ColumnWidth'     
 UNION ALL    
 SELECT 1,1,'-4108','HorizontalAlignment'    
 UNION ALL    
 SELECT 2,25,'2:6','RowHeight' --ICRSTPAR6933    

 RETURN     
END
GO
-----Scrpit Updater Scrpits
IF NOT EXISTS(SELECT * FROM customupdownload WHERE module ='SchemeCategoryDetails' AND updownload ='download')
BEGIN
	DELETE FROM customupdownload where module ='SchemeCategoryDetails' AND  updownload ='download'
	INSERT INTO customupdownload
	SELECT 274,1,'SchemeCategoryDetails','SchemeCategoryDetails','','Proc_Import_SchemeCategoryDetails','Cn2Cs_Prk_SchemeCategorydetails','Proc_Cn2Cs_SchemeCategoryDetails','Master','Download',1
END
GO
IF NOT EXISTS(SELECT * FROM tbl_downloadintegration WHERE processname ='SchemeCategoryDetails')
BEGIN
DELETE FROM tbl_downloadintegration WHERE processname ='SchemeCategoryDetails'
INSERT INTO tbl_downloadintegration
SELECT 82,'SchemeCategoryDetails','Cn2Cs_Prk_SchemeCategorydetails','Proc_Import_SchemeCategoryDetails',0,500,getdate()
END
GO
IF NOT EXISTS(select * from sysobjects where name ='Cn2Cs_Prk_SchemeCategorydetails' and XTYPE ='U')
CREATE TABLE Cn2Cs_Prk_SchemeCategorydetails(
	[DistCode] [nvarchar](50) NULL,
	[CmpSchcode] [nvarchar](50) NULL,
	[Schcategory_type] [nvarchar](50) NULL,
	[DownLoadFlag] [nvarchar](10) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF NOT EXISTS(select * from sysobjects where name ='SchemeCategorydetails' and XTYPE ='U')
CREATE TABLE SchemeCategorydetails(
	[CmpSchcode] [nvarchar](50) NULL,
	[Schcategory_type] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF NOT  EXISTS (SELECT * FROM sys.objects WHERE NAME ='CS2Console_Consolidated_Trace' AND type in ('U'))
CREATE TABLE CS2Console_Consolidated_Trace (
	[SlNo] [numeric](38, 0) NULL,
	[DistCode] [varchar](100) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ProcessName] [varchar](200) NULL,
	[ProcessDate] [datetime] NULL,
	[Column1] [varchar](200) NULL,
	[Column2] [varchar](200) NULL,
	[Column3] [varchar](200) NULL,
	[Column4] [varchar](200) NULL,
	[Column5] [varchar](200) NULL,
	[Column6] [varchar](200) NULL,
	[Column7] [varchar](200) NULL,
	[Column8] [varchar](200) NULL,
	[Column9] [varchar](200) NULL,
	[Column10] [varchar](200) NULL,
	[Column11] [varchar](200) NULL,
	[Column12] [varchar](200) NULL,
	[Column13] [varchar](200) NULL,
	[Column14] [varchar](200) NULL,
	[Column15] [varchar](200) NULL,
	[Column16] [varchar](200) NULL,
	[Column17] [varchar](200) NULL,
	[Column18] [varchar](200) NULL,
	[Column19] [varchar](200) NULL,
	[Column20] [varchar](200) NULL,
	[Column21] [varchar](200) NULL,
	[Column22] [varchar](200) NULL,
	[Column23] [varchar](200) NULL,
	[Column24] [varchar](200) NULL,
	[Column25] [varchar](200) NULL,
	[Column26] [varchar](200) NULL,
	[Column27] [varchar](200) NULL,
	[Column28] [varchar](200) NULL,
	[Column29] [varchar](200) NULL,
	[Column30] [varchar](200) NULL,
	[Column31] [varchar](200) NULL,
	[Column32] [varchar](200) NULL,
	[Column33] [varchar](200) NULL,
	[Column34] [varchar](200) NULL,
	[Column35] [varchar](200) NULL,
	[Column36] [varchar](200) NULL,
	[Column37] [varchar](200) NULL,
	[Column38] [varchar](200) NULL,
	[Column39] [varchar](200) NULL,
	[Column40] [varchar](200) NULL,
	[Column41] [varchar](200) NULL,
	[Column42] [varchar](200) NULL,
	[Column43] [varchar](200) NULL,
	[Column44] [varchar](200) NULL,
	[Column45] [varchar](200) NULL,
	[Column46] [varchar](200) NULL,
	[Column47] [varchar](200) NULL,
	[Column48] [varchar](200) NULL,
	[Column49] [varchar](200) NULL,
	[Column50] [varchar](200) NULL,
	[Column51] [varchar](200) NULL,
	[Column52] [varchar](200) NULL,
	[Column53] [varchar](200) NULL,
	[Column54] [varchar](200) NULL,
	[Column55] [varchar](200) NULL,
	[Column56] [varchar](200) NULL,
	[Column57] [varchar](200) NULL,
	[Column58] [varchar](200) NULL,
	[Column59] [varchar](200) NULL,
	[Column60] [varchar](200) NULL,
	[Column61] [varchar](200) NULL,
	[Column62] [varchar](200) NULL,
	[Column63] [varchar](200) NULL,
	[Column64] [varchar](200) NULL,
	[Column65] [varchar](200) NULL,
	[Column66] [varchar](200) NULL,
	[Column67] [varchar](200) NULL,
	[Column68] [varchar](200) NULL,
	[Column69] [varchar](200) NULL,
	[Column70] [varchar](200) NULL,
	[Column71] [varchar](200) NULL,
	[Column72] [varchar](200) NULL,
	[Column73] [varchar](200) NULL,
	[Column74] [varchar](200) NULL,
	[Column75] [varchar](200) NULL,
	[Column76] [varchar](200) NULL,
	[Column77] [varchar](200) NULL,
	[Column78] [varchar](200) NULL,
	[Column79] [varchar](200) NULL,
	[Column80] [varchar](200) NULL,
	[Column81] [varchar](200) NULL,
	[Column82] [varchar](200) NULL,
	[Column83] [varchar](200) NULL,
	[Column84] [varchar](200) NULL,
	[Column85] [varchar](200) NULL,
	[Column86] [varchar](200) NULL,
	[Column87] [varchar](200) NULL,
	[Column88] [varchar](200) NULL,
	[Column89] [varchar](200) NULL,
	[Column90] [varchar](200) NULL,
	[Column91] [varchar](200) NULL,
	[Column92] [varchar](200) NULL,
	[Column93] [varchar](200) NULL,
	[Column94] [varchar](200) NULL,
	[Column95] [varchar](200) NULL,
	[Column96] [varchar](200) NULL,
	[Column97] [varchar](200) NULL,
	[Column98] [varchar](200) NULL,
	[Column99] [varchar](200) NULL,
	[Column100] [varchar](200) NULL,
	[Remarks1] [varchar](500) NULL,
	[Remarks2] [varchar](500) NULL,
	[UploadFlag] [varchar](1) NULL,
	[Uploadeddate] [datetime] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_PopulateToBeUploaded]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Proc_PopulateToBeUploaded]
GO
--Exec Proc_PopulateToBeUploaded 0
CREATE PROCEDURE [dbo].[Proc_PopulateToBeUploaded]
(
@Po_ErrNo INT OUTPUT
)
As
Begin
	BEGIN TRY        
	SET XACT_ABORT ON        
	BEGIN TRANSACTION  
	declare @SqlStr varchar(8000)
	declare @Process varchar(100)
	declare @colcount int
	declare @Col varchar(5000)
	declare @Tablename varchar(100)
	declare @Sequenceno int
	declare @Lvar int
	declare @MaxId int
	Declare @DistCode Varchar(100)
	Declare @SyncId Int
	SET @Po_ErrNo=0
	-- *** upload integration table to be replaced....
	Create table #Process(ProcessName varchar(100),PrkTableName varchar(100), id int identity(1,1) )
	insert into #Process(ProcessName , PrkTableName) select ProcessName , PrkTableName from Tbl_UploadIntegration order by Sequenceno
	Select @DistCode = DistributorCode From Distributor 
	Select @SyncId = Max(SyncId) From Sync_Master
	--Delete From CS2Console_Consolidated Where UploadFlag = 'Y'
	--Delete A From CS2Console_Consolidated  A (Nolock) , SyncStatus B 
	--Where A.DistCode = B.DistCode And A.UploadFlag = 'Y' And A.SyncId = B.SyncId And B.SyncStatus <> 0
		----- Added by Anand S on 10.09.2012 -- for handling the DB Restoration - SyncId Mismatch....
		--Declare @SyncSts int
		--Declare @ZCnt int
		--Select @SyncSts = ISNULL(SyncStatus,0) from SyncStatus (nolock)
		--select @ZCnt = Count(*) from CS2Console_Consolidated(nolock) where UploadFlag = 'N' and
		--SyncId = (select isnull(SyncId,0)  from SyncStatus (nolock) )
		--if (@SyncSts = 0 and @ZCnt = 0)
		--begin
		--Update CS2Console_Consolidated set UploadFlag = 'N' where 	SyncId = (select isnull(SyncId,0)  from SyncStatus (nolock) )
		--end
		--- Till Here
		
		------------> Added by Lakshman M on 09-03-2018 PMS ID: ICRSTPAR7919 <--------------
		INSERT  INTO CS2Console_Consolidated_Trace
		SELECT *,GETDATE() FROM CS2Console_Consolidated (NOLOCK) WHERE UploadFlag='Y' and ProcessName IN  ('Daily_Sales')
		DELETE FROM CS2Console_Consolidated_Trace WHERE CONVERT(VARCHAR(10),ProcessDate,121) < CONVERT(VARCHAR(10),DATEADD(MM,-1,GETDATE()),121)
		------------> Till here <---------------------
		
		Delete A From CS2Console_Consolidated A (nolock) Where SyncId <> (Select ISNULL(MAX(SyncId),0) From SyncStatus)
		--Delete A From CS2Console_Consolidated A (nolock) Where SyncId < (Select ISNULL(MAX(SyncId),0) From SyncStatus) AND UploadFlag='Y'
		Delete A From CS2Console_Consolidated A (nolock) Where SyncId = (Select ISNULL(MAX(SyncId),0) From SyncStatus WHERE SyncStatus=1) AND UploadFlag='Y' 
		IF ((Select Count(*) From CS2Console_Consolidated (nolock)) = 0)
		Begin
			Truncate Table CS2Console_Consolidated
		End
	set @Lvar = 1
	select @MaxId = Max(id) from #Process
	while @Lvar <= @MaxId
	begin
		select @Tablename = PrkTableName , @Process = ProcessName from #Process where id  = @Lvar
		select @colcount = Max(Column_ID) from sys.columns where object_id = (select object_id from sys.objects where name = @Tablename)
		set @SqlStr = ''
		set @SqlStr = @SqlStr + ' Insert into CS2Console_Consolidated '
		set @Col = ''
		select @Col = @Col + name + ',' from sys.columns 
		where object_id = ( select object_id from sys.objects where name = 'CS2Console_Consolidated')
		and column_id  between 2 and @colcount + 5 Order by column_id 
		set @SqlStr = @SqlStr + '(' + left(@Col,len(@Col)-1)  + ',UploadFlag)'
		
		set @Col = ''
		--select @Col = @Col + name + ',' from sys.columns 
		select @Col = @Col + (Case when (name = 'UploadedDate' Or name = 'ServerDate') Then  'CONVERT(VARCHAR(19),[' + name + '],121)' else 'REPLACE(['+name + '],'''''''','''')'  end)+ ',' from sys.columns 
		where Object_Id = ( select Object_Id from sys.objects where name = @Tablename)
		and column_id  <= @colcount Order by column_id 
		set @SqlStr = @SqlStr + 'Select '''+ CONVERT(Varchar(50),@DistCode) + ''','+ CONVERT(Varchar(50),@SyncId) + ',''' + @Process + ''' ,getdate(), '
		set @SqlStr = @SqlStr + ' ' + left(@Col,len(@Col)-1)  + ',''N'' from ' + @Tablename + '(nolock) where UploadFlag = ''N''  And SyncId Is Not Null  Order By SlNo '
		--Print(@SqlStr)
		exec (@SqlStr)
		set @SqlStr = ''
		set @SqlStr = @SqlStr + ' Update B Set B.UploadFlag = ''Y'' From CS2Console_Consolidated A (Nolock),  ' + @Tablename  + ' B (nolock) '
		set @SqlStr = @SqlStr + ' Where A.DistCode = B.DistCode and a.SyncId = b.SyncId and A.ProcessName = ''' + @Process + '''  And A.SyncId Is Not Null '
		exec (@SqlStr)
		--Print(@SqlStr)
		set @SqlStr = ''
		
	set @Lvar = @Lvar + 1
	END
		Update SyncStatus Set SyncFlag = 'Y' Where DistCode=@DistCode And SyncId = @SyncId
		Create Table #SPLTBL (Id INT Identity(1,1),CId INT,CName VARCHAR(200),CType VARCHAR(100))
		INSERT INTO #SPLTBL
		SELECT A.column_id AS CId,A.Name,C.name AS CType FROM Sys.columns A,Sys.objects B,Sys.types C 
		WHERE A.object_id = B.object_id and B.name = 'CS2Console_Consolidated'
		And A.system_type_id = C.system_type_id And C.name='VARCHAR'
		Order by A.column_id 
		DECLARE @CName VARCHAR(100)
		SET @Lvar = 1
		SET @CName = ''
		SELECT @MaxId = IsNull(Count(CId),0) FROM #SPLTBL
		While @Lvar <= @MaxId
		Begin
			SELECT @CName = CName FROM #SPLTBL WHERE Id = @Lvar
			SET @SqlStr = ''
			SET @SqlStr = @SqlStr + ' UPDATE CS2Console_Consolidated  SET '+ @CName + ' = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(' + @CName + ','''''''',''''),''"'',''''),''&'',''''),''<'',''''),''>'','''') '
			Print (@SqlStr)
			exec (@SqlStr)
			
			SET @SqlStr = ''
			SET @SqlStr = @SqlStr + ' UPDATE CS2Console_Consolidated  SET '+ @CName + ' = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(' + @CName + ',''\r'',''''),''\n'',''''),''\f'',''''),''\p'',''''),''\t'',''''),''\s'','''') '
			Print (@SqlStr)
			exec (@SqlStr)
					
			SET @Lvar = @Lvar + 1
		End
	COMMIT TRANSACTION        
	 END TRY        
 BEGIN CATCH        
  ROLLBACK TRANSACTION        
  INSERT INTO Sync_ErrorLog VALUES ('Proc_PopulateToBeUploaded', ERROR_MESSAGE(), GETDATE())        
 END CATCH        
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Fn_ValidateClaimMonthEndDate' AND xtype='FN')
DROP FUNCTION Fn_ValidateClaimMonthEndDate
GO
--SELECT DBO.Fn_ValidateClaimMonthEndDate('2018-09-01','2018-08-01','2018-08-30',1,1)
CREATE FUNCTION [dbo].[Fn_ValidateClaimMonthEndDate](@ServerDate AS DATETIME,@FromDate AS DATETIME,@ToDate AS DATETIME,
@ClmGrpId	BIGINT,@iMode AS INT)
RETURNS VARCHAR(500)
AS
/************************************************
* FUNCTION  : Fn_ValidateClaimMonthEndDate
* PURPOSE    : Return To Validate the Claim Top sheet Generation 
* CREATED BY : S.Moorthi
* CREATED ON : 21/06/2018
* MODIFICATION 
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  21/06/2018   S.Moorthi    CR         CRCRSTPAR0010   enable Month End process and the same should be 
													   called automatically on 06th of every month.
*************************************************/    
BEGIN
	DECLARE @ValidateMsg AS VARCHAR(500)
	DECLARE @MonthEndDt AS DATETIME
	DECLARE @JCMONTHDT AS DATETIME
	DECLARE @JCMONTHDT1 AS DATETIME
	SET @ValidateMsg=''
	
	IF @iMode<>1
	BEGIN
		RETURN @ValidateMsg
	END

	IF EXISTS(SELECT * FROM CLAIMGROUPMASTER WHERE CLMGRPCODE IN ('CG11','CG16') and ClmGrpId=@ClmGrpId)
	BEGIN
		RETURN @ValidateMsg
	END
	
	
	IF EXISTS(SELECT * FROM JCMonthEnd)
	BEGIN
		SELECT @MonthEndDt=MAX(JcmEdt) FROM JCMonthEnd
		IF @ToDate>@MonthEndDt
		BEGIN
			SET @ValidateMsg='Month end not completed for selected claim period,Claim should be allowed to process till '+CONVERT(VARCHAR(10),@MonthEndDt,105)
		END
	end
	ELSE
	BEGIN
		SELECT @JCMONTHDT=Jcmsdt FROM JCMonth WHERE @ServerDate BETWEEN JcmSdt AND JcmEdt 
		--SELECT @JCMONTHDT1=Jcmsdt FROM JCMonth WHERE dateadd(d,-1,@JCMONTHDT) BETWEEN JcmSdt AND JcmEdt 
		SET @MonthEndDt=dateadd(d,-1,@JCMONTHDT)
		--IF @FromDate>=@JCMONTHDT1
		IF @ToDate>@MonthEndDt
		BEGIN
			SET @ValidateMsg='Month end not completed for selected claim period,Claim should be allowed to process till '+CONVERT(VARCHAR(10),dateadd(d,-1,@MonthEndDt),105)
		END
	END
	
	IF @ClmGrpId=-1
	BEGIN
		if @ValidateMsg<>''
		BEGIN
			SET @ValidateMsg='Month end not completed for selected claim period,Special Discount Claim should not be allow to Save,allowed to process till '+CONVERT(VARCHAR(10),dateadd(d,-1,@MonthEndDt),105)
		END	
	END
	
RETURN @ValidateMsg
END
GO
IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='Cs2Cn_Prk_GSTInvoiceNumberCorrection')
BEGIN
CREATE TABLE [Cs2Cn_Prk_GSTInvoiceNumberCorrection]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	TransId	INT,
	TransName Varchar(50),
	Salid BIGINT,
	SalInvno Varchar(50),
	NewSalinvno Varchar(50),
	RtrCode Varchar(50),
	CmpRtrCode Varchar(50),	
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
)
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cs2Cn_GSTInvoiceNumberCorrection')
DROP PROCEDURE Proc_Cs2Cn_GSTInvoiceNumberCorrection
GO
--EXEC Proc_Cs2Cn_GSTInvoiceNumberCorrection 0,'2017-07-01'
CREATE PROCEDURE [Proc_Cs2Cn_GSTInvoiceNumberCorrection]
(
   @Po_ErrNo INT OUTPUT,
   @ServerDate DATETIME
)
AS
/*****************************************************************************
* PROCEDURE		: Proc_Cs2Cn_BillSeriesDtGST
* PURPOSE		: To Extract BillSeries Prefix details from CoreStocky to  Console
* CREATED BY	: Raja C
* CREATED DATE	: 13/06/2017
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
********************************************************************************/
SET NOCOUNT ON
BEGIN	
    SET @Po_ErrNo=0
	DECLARE @DistCode As nVarchar(50)
	DELETE FROM Cs2Cn_Prk_GSTInvoiceNumberCorrection WHERE UploadFlag = 'Y'	
	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)
    INSERT INTO Cs2Cn_Prk_GSTInvoiceNumberCorrection
    ([DistCode],TransId,TransName,Salid,SalInvno,NewSalinvno,RtrCode,CmpRtrCode,[UploadFlag],ServerDate)
	SELECT @DistCode,TransId,TransName,Salid,SalInvno,NewSalinvno,RtrCode,CmpRtrCode,'N',@ServerDate
	FROM GSTSalesInvoiceNoCorrection WHERE UploadFlag='N'
    
   UPDATE B SET UploadFlag='Y' FROM Cs2Cn_Prk_GSTInvoiceNumberCorrection A 
   INNER JOIN GSTSalesInvoiceNoCorrection B ON A.TransId=B.TransId
   AND A.Salid=B.Salid and A.Salinvno=B.SalInvno WHERE B.UploadFlag='N'
END
GO
IF NOT EXISTS(SELECT 'X' FROM SYSOBJECTS WHERE XTYPE='U' AND name='GSTSalesInvoiceNoCorrection')
BEGIN
	CREATE TABLE GSTSalesInvoiceNoCorrection
	(
		TransId	INT,
		TransName Varchar(50),
		Salid BIGINT,
		SalInvno Varchar(50),
		NewSalinvno Varchar(50),
		RtrCode Varchar(50),
		CmpRtrCode Varchar(50),
		UploadFlag Varchar(1),
		UploadFlag2 Varchar(1)
	)	
END
GO
IF EXISTS(SELECT 'X' FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_GSTInvoiceNumberCorrection')
DROP PROCEDURE Proc_GSTInvoiceNumberCorrection
GO
CREATE PROCEDURE Proc_GSTInvoiceNumberCorrection
AS
SET NOCOUNT ON  
BEGIN 
	BEGIN TRY
		BEGIN TRAN
			IF EXISTS(SELECT * FROM UpdaterLog WHERE FixId=2137)
			BEGIN
				IF EXISTS(SELECT 'X' FROM GSTConfiguration WHERE ActivationStatus=1 and AcknowledgeStatus=1 and ConsoleAckStatus=1)
				BEGIN
					IF EXISTS(SELECT 'X' FROM ManualConfiguration WHERE ModuleId='BILL_EDIT2' and Status=1)
					BEGIN
							DECLARE @ConfigValue AS INT
							DECLARE @Distcode AS  VARCHAR(100)
							DECLARE @CurrYear AS NUMERIC(36,0)
							DECLARE @SeriesID AS INT				
							DECLARE @SeriesMasterId AS INT
							DECLARE @PreFix AS VARCHAR(20)	
							DECLARE @ZPad AS INT
							DECLARE @CurrValue AS NUMERIC(36,0)

							DECLARE @TableName VARCHAR(100)
							DECLARE @SeriesValue AS  VARCHAR(100)				
							DECLARE @Len AS  INT
							
							
							--SELECT @ConfigValue=CAST(ISNULL(ConfigValue,0) AS INT) FROM ManualConfiguration WHERE ModuleId='BILL_EDIT2' and Status=1
							SET @Distcode=''
							--IF @ConfigValue>0
							--BEGIN
							--	SELECT @Distcode=REPLICATE('0',@ConfigValue-LEN(RIGHT(DistributorCode,@ConfigValue)))+RIGHT(DistributorCode,@ConfigValue) 
							--	FROM Distributor
							--END
							
							SELECT @CurrYear=CurYear FROM Counters (NOLOCK)	
					
						IF EXISTS(SELECT 'X' FROM SalesInvoice S where VatGST='GST' and LEN(Salinvno)>16) 
						BEGIN
					
						
							

							SELECT @SeriesID=SeriesID ,@SeriesMasterId=SeriesMasterId 
							FROM BillSeriesHD (Nolock) where SeriesID = (SELECT ISNULL(MAX(SeriesID),1) 
							FROM BillSeriesHD (Nolock)) Order By SequenceId
							
							SELECT @PreFix=A.Prefix,@ZPad=A.Zpad 
							FROM BillSeriesdtValue A (NOLOCK)  
							INNER JOIN BillSeriesdt B (NOLOCK) ON A.SeriesDtId = B.SeriesDtId Where B.SeriesId = @SeriesID 
							And B.SeriesValue = 0 GROUP BY A.Prefix,A.Currvalue,A.Zpad 
							
							
							INSERT INTO GSTSalesInvoiceNoCorrection(TransId,TransName,Salid,SalInvno,NewSalinvno,RtrCode,CmpRtrCode,UploadFlag,UploadFlag2)
							SELECT 2,'Billing',Salid,SalInvNo, @PreFix+@Distcode+CAST(SUBSTRING(CAST(@CurrYear as Varchar(10)),3,LEN(@CurrYear)) AS Varchar(10))+REPLICATE('0',CASE WHEN LEN(ROW_NUMBER() OVER(Order by Salid))>@ZPad THEN (@ZPad+1)-LEN(ROW_NUMBER() OVER(Order by SALID)) ELSE (@ZPad)-LEN(ROW_NUMBER() OVER(Order by SALID))END)+CAST(ROW_NUMBER() OVER(Order by Salid) as Varchar(10)),
							RtrCode,CmpRtrCode,'N','N'
							FROM SalesInvoice S  (NOLOCK) INNER JOIN Retailer R ON R.RtrId=S.RtrId
							WHERE VatGST='GST' and LEN(Salinvno)>16  ORDER BY Salid 				
									
							IF NOT EXISTS(SELECT * FROM GSTSalesInvoiceNoCorrection (NOLOCK) WHERE LEN(ISNULL(NewSalinvno,'')) NOT Between 12 and 16)
							BEGIN
								
								
								
								UPDATE A SET A.Remarks='Posted From Billing '+NewSalinvno+' Dated '+ CONVERT(Varchar(10),VocDate,121)
								FROM StdVocMaster A INNER JOIN SalesInvoice B ON B.SalInvNo=LTRIM(RTRIM(SUBSTRING(A.Remarks,21,CHARINDEX(' Dated',A.Remarks)-21)))
								INNER JOIN GSTSalesInvoiceNoCorrection C ON C.SalInvno=B.SalInvNo and C.Salid=B.SalId and
								C.Salinvno=LTRIM(RTRIM(SUBSTRING(A.Remarks,21,CHARINDEX(' Dated',A.Remarks)-21)))
								WHERE A.Remarks like 'Posted from Billing%' and B.VatGst='GST' and C.TransId=2
								
								UPDATE  B SET B.SalInvNo=A.NewSalinvno 
								FROM GSTSalesInvoiceNoCorrection A INNER JOIN SalesInvoice B ON A.Salid=B.Salid and A.SalInvno=B.SalInvno
								WHERE LEN(ISNULL(NewSalinvno,''))<16 and A.TransId=2
								
								
							END					
						END
						--Return
						IF EXISTS(SELECT 'X' FROM ReturnHeader (NOLOCK) WHERE LEN(ReturnCode)>16 and VatGst='GST' and GSTTag NOT IN('DTGST'))
						BEGIN
								
								SELECT @PreFix=Prefix,@ZPad=Zpad  
								FROM Counters WHERE TabName='ReturnHeader' and FldName='ReturnCode'
								
								INSERT INTO GSTSalesInvoiceNoCorrection(TransId,TransName,Salid,SalInvno,NewSalinvno,RtrCode,CmpRtrCode,UploadFlag,UploadFlag2)
								SELECT 3,'Return',ReturnID,ReturnCode, @PreFix+@Distcode+CAST(SUBSTRING(CAST(@CurrYear as Varchar(10)),3,LEN(@CurrYear)) AS Varchar(10))+REPLICATE('0',CASE WHEN LEN(ROW_NUMBER() OVER(Order by Returnid))>@ZPad THEN (@ZPad+1)-LEN(ROW_NUMBER() OVER(Order by Returnid)) ELSE (@ZPad)-LEN(ROW_NUMBER() OVER(Order by Returnid))END)+CAST(ROW_NUMBER() OVER(Order by Returnid) as Varchar(10)),
								RtrCode,CmpRtrCode,'N','N'
								FROM ReturnHeader S  (NOLOCK) INNER JOIN Retailer R ON R.RtrId=S.RtrId
								WHERE VatGST='GST' and LEN(ReturnCode)>16 and  GSTTag NOT IN('DTGST') ORDER BY Returnid 
								
								
								
								UPDATE A SET A.Remarks='Posted From SalesReturn '+NewSalinvno+' Dated '+ CONVERT(Varchar(10),VocDate,121)
								FROM StdVocMaster A INNER JOIN ReturnHeader B ON B.ReturnCode=LTRIM(RTRIM(SUBSTRING(A.Remarks,25,CHARINDEX(' Dated',A.Remarks)-25)))
								INNER JOIN GSTSalesInvoiceNoCorrection C ON C.SalInvno=B.ReturnCode and C.Salid=B.ReturnId and
								C.Salinvno=LTRIM(RTRIM(SUBSTRING(A.Remarks,25,CHARINDEX(' Dated',A.Remarks)-25)))
								WHERE A.Remarks like 'Posted From SalesReturn%' and B.VatGst='GST' and C.TransId=3
																
								UPDATE  A SET A.PostedFrom=B.NewSalinvno 
								FROM CreditNoteRetailer A 
								INNER JOIN GSTSalesInvoiceNoCorrection B ON A.PostedFrom=B.Salinvno
								INNER JOIN ReturnHeader C ON C.ReturnCode=A.PostedFrom and C.ReturnCode=B.SalInvno and C.ReturnID=B.Salid
								WHERE B.TransId=3
								
								UPDATE  B SET B.ReturnCode=A.NewSalinvno 
								FROM GSTSalesInvoiceNoCorrection A INNER JOIN ReturnHeader B ON A.Salid=B.ReturnID and A.SalInvno=B.ReturnCode
								WHERE LEN(ISNULL(NewSalinvno,''))<16 and A.TransId=3 and  GSTTag NOT IN('DTGST')
								
								
										
						END
						
						IF EXISTS(SELECT 'X' FROM ReturnHeader (NOLOCK) WHERE LEN(ReturnCode)>16 and VatGst='GST' and GSTTag IN('DTGST'))
						BEGIN
								
								SELECT @PreFix=Prefix,@ZPad=Zpad  
								FROM Counters WHERE TabName='ReturnGSTR1' and FldName='ReturnCode'
								
								INSERT INTO GSTSalesInvoiceNoCorrection(TransId,TransName,Salid,SalInvno,NewSalinvno,RtrCode,CmpRtrCode,UploadFlag,UploadFlag2)
								SELECT 3,'Return',ReturnID,ReturnCode, @PreFix+@Distcode+CAST(SUBSTRING(CAST(@CurrYear as Varchar(10)),3,LEN(@CurrYear)) AS Varchar(10))+REPLICATE('0',CASE WHEN LEN(ROW_NUMBER() OVER(Order by Returnid))>@ZPad THEN (@ZPad+1)-LEN(ROW_NUMBER() OVER(Order by Returnid)) ELSE (@ZPad)-LEN(ROW_NUMBER() OVER(Order by Returnid))END)+CAST(ROW_NUMBER() OVER(Order by Returnid) as Varchar(10)),
								RtrCode,CmpRtrCode,'N','N'
								FROM ReturnHeader S  (NOLOCK) INNER JOIN Retailer R ON R.RtrId=S.RtrId
								WHERE VatGST='GST' and LEN(ReturnCode)>16  and GSTTag IN('DTGST') ORDER BY Returnid 
								
									
								
								UPDATE A SET A.Remarks='Posted From SalesReturn '+NewSalinvno+' Dated '+ CONVERT(Varchar(10),VocDate,121)
								FROM StdVocMaster A INNER JOIN ReturnHeader B ON B.ReturnCode=LTRIM(RTRIM(SUBSTRING(A.Remarks,25,CHARINDEX(' Dated',A.Remarks)-25)))
								INNER JOIN GSTSalesInvoiceNoCorrection C ON C.SalInvno=B.ReturnCode and C.Salid=B.ReturnId and
								C.Salinvno=LTRIM(RTRIM(SUBSTRING(A.Remarks,25,CHARINDEX(' Dated',A.Remarks)-25)))
								WHERE A.Remarks like 'Posted From SalesReturn%' and B.VatGst='GST' and C.TransId=3
								
													
								
								UPDATE  A SET A.PostedFrom=B.NewSalinvno 
								FROM CreditNoteRetailer A 
								INNER JOIN GSTSalesInvoiceNoCorrection B ON A.PostedFrom=B.Salinvno
								INNER JOIN ReturnHeader C ON C.ReturnCode=A.PostedFrom and C.ReturnCode=B.SalInvno and C.ReturnID=B.Salid
								WHERE B.TransId=3
								
								UPDATE  B SET B.ReturnCode=A.NewSalinvno 
								FROM GSTSalesInvoiceNoCorrection A INNER JOIN ReturnHeader B ON A.Salid=B.ReturnID and A.SalInvno=B.ReturnCode
								WHERE LEN(ISNULL(NewSalinvno,''))<16 and A.TransId=3 and  GSTTag  IN('DTGST')
							
								
								
								
										
						END
						--Credit Note
						IF EXISTS(SELECT * FROM CreditNoteRetailer WHERE LEN(CrNoteNumber)>16 and CrNoteDate>='2017-07-01')
						BEGIN
								SELECT @PreFix=Prefix,@ZPad=Zpad  
								FROM Counters WHERE TabName='CreditNoteRetailer' and FldName='CrNoteNumber'
								
								INSERT INTO GSTSalesInvoiceNoCorrection(TransId,TransName,Salid,SalInvno,NewSalinvno,RtrCode,CmpRtrCode,UploadFlag,UploadFlag2)
								SELECT 18,'CreditNoteRetailer',0 as ReturnID,CrNoteNumber, 
								@PreFix+@Distcode+CAST(SUBSTRING(CAST(@CurrYear as Varchar(10)),3,LEN(@CurrYear)) AS Varchar(10))+REPLICATE('0',CASE WHEN LEN(ROW_NUMBER() OVER(Order by CrNoteNumber))>@ZPad THEN (@ZPad+1)-LEN(ROW_NUMBER() OVER(Order by CrNoteNumber)) ELSE (@ZPad)-LEN(ROW_NUMBER() OVER(Order by CrNoteNumber))END)+CAST(ROW_NUMBER() OVER(Order by CrNoteNumber) as Varchar(10)),
								RtrCode,CmpRtrCode,'N','N'
								FROM CreditNoteRetailer S  (NOLOCK) INNER JOIN Retailer R ON R.RtrId=S.RtrId
								WHERE CrNoteDate>='2017-07-01' and LEN(CrNoteNumber)>16  ORDER BY CrNoteNumber 
														
								ALTER TABLE SalInvCrNoteAdj NOCHECK CONSTRAINT FK_SalInvCrNoteAdj_CrNoteNo


								UPDATE S  SET s.PostedFrom=B.NewSalinvno, s.PostedRefNo=B.NewSalinvno
								FROM GSTSalesInvoiceNoCorrection B 
								INNER JOIN CreditNoteRetailer S  (NOLOCK)  ON   S.CrNoteNumber=B.SalInvno 
								INNER JOIN Retailer R ON R.RtrId=S.RtrId and R.RtrCode=B.RtrCode
								WHERE s.TransId=18 AND b.TransId=18

								
								UPDATE A  SET A.CrNoteNumber=B.NewSalinvno FROM SalInvCrNoteAdj A 
								INNER JOIN GSTSalesInvoiceNoCorrection B ON A.CrNoteNumber=B.SalInvno
								INNER JOIN CreditNoteRetailer S  (NOLOCK)  ON   A.CrNoteNumber=S.CrNoteNumber and S.CrNoteNumber=B.SalInvno 
								INNER JOIN Retailer R ON R.RtrId=S.RtrId and  A.RtrId=R.RtrId
								and R.RtrCode=B.RtrCode
								WHERE B.TransId=18
								
								UPDATE A SET A.Remarks='Posted From Credit Note Retailer '+NewSalinvno+' Dated '+ CONVERT(Varchar(10),VocDate,121)
								FROM StdVocMaster A INNER JOIN CreditNoteRetailer B ON B.CrNoteNumber=LTRIM(RTRIM(SUBSTRING(A.Remarks,34,CHARINDEX(' Dated',A.Remarks)-34)))
								INNER JOIN GSTSalesInvoiceNoCorrection C ON C.SalInvno=B.CrNoteNumber and
								C.Salinvno=LTRIM(RTRIM(SUBSTRING(A.Remarks,34,CHARINDEX(' Dated',A.Remarks)-34)))
								WHERE A.Remarks like 'Posted From Credit Note Retailer%'  and C.TransId=18
								
								UPDATE S  SET CrNoteNumber=B.NewSalinvno 
								FROM GSTSalesInvoiceNoCorrection B 
								INNER JOIN CreditNoteRetailer S  (NOLOCK)  ON   S.CrNoteNumber=B.SalInvno 
								INNER JOIN Retailer R ON R.RtrId=S.RtrId and R.RtrCode=B.RtrCode
								WHERE B.TransId=18
								
									
							
								
								ALTER TABLE SalInvCrNoteAdj WITH CHECK CHECK CONSTRAINT FK_SalInvCrNoteAdj_CrNoteNo

						
							
						END
					END
				END	
			END	
			
			--SELECT * FROM SalesInvoice (NOLOCK) WHERE VatGst='GST' order by salinvno
			--SELECT * FROM ReturnHeader (NOLOCK) WHERE VatGst='GST'
			--SELECT * FROM CreditNoteRetailer (NOLOCK) WHERE CrNoteDate >='2017-07-01'
			--SELECT * from SalInvCrNoteAdj (NOLOCK)
			--SELECT * from GSTSalesInvoiceNoCorrection (NOLOCK)
			--Select * from Stdvocmaster where 
			
			COMMIT TRAN
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRAN
	END CATCH		
END
GO
IF EXISTS (select *from sysobjects where name ='Proc_RptClaimTopSheet' and xtype ='P')
DROP PROCEDURE Proc_RptClaimTopSheet
GO
-- EXEC Proc_RptClaimTopSheet 107,2,0,'',0,0,1,''
CREATE PROCEDURE Proc_RptClaimTopSheet
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
/************************************************
* PROCEDURE  : Proc_RptClaimTopSheet
* PURPOSE    : To Generate  Claim Top Sheet Report 
* CREATED BY : Boopathy.P
* CREATED ON : 19/03/2008  
* MODIFICATION 
*************************************************   
* DATE       AUTHOR      DESCRIPTION    
--------------------------------------------------------------------------------------------------------------------
* Date			  Author	   CR/BZ	 UserStoryId		    Description 
* 03-05-2018	 lakshman M      BZ	     ILCRSTPAR0448	        Claim wise Rpt name & Date range filter validation added in Core stocky
* 07-05-2018	 lakshman M      BZ	     ILCRSTPAR0478	        Claim wise scheme code,schem valid Date and tax amount validation added in Core stocky
* 27-06-2018     Deepak K		 BZ      ILCRSTPAR1185			Special Discount Claim RefCode validation added 
* 20-11-2018     lakshman M      BZ      ILCRSTPAR2606          Claim top sheet report tax amount validation missing in CS. 
* 04-11-2018     Lakshman M      SR      ILCRSTPAR2722          As per Awanish request claim top sheet report two New column added      
**********************************************************************************************************************/      
BEGIN
SET NOCOUNT ON
	DECLARE @NewSnapId 			AS	INT
	DECLARE @DBNAME				AS 	nvarchar(50)
	DECLARE @TblName 			AS	nvarchar(500)
	DECLARE @TblStruct 			AS	nVarchar(4000)
	DECLARE @TblFields 			AS	nVarchar(4000)
	DECLARE @sSql				AS 	nVarChar(4000)
	DECLARE @ErrNo	 			AS	INT
	DECLARE @PurDBName			AS	nVarChar(50)
	--Filter Variable
	DECLARE @CmpId				AS	INT
	DECLARE @FromDate			AS 	DATETIME
	DECLARE @ToDate				AS 	DATETIME
	DECLARE @ClmGrpId			AS	INT
	DECLARE @ClmSts				AS	INT
	DECLARE @ClmConfSts			AS	INT
	DECLARE @ClmCode			AS	INT
--Till Here
--Assgin Value for the Filter Variable
	SET @CmpId = 		(SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @FromDate =		(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate =		(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @ClmGrpId = 	(SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,42,@Pi_UsrId))
	SET @ClmSts = 		(SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,124,@Pi_UsrId))
	SET @ClmConfSts = 	(SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,125,@Pi_UsrId))
	SET @ClmCode = 		(SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,41,@Pi_UsrId))
	
	PRINT @CmpId
	PRINT @FromDate
	PRINT @ToDate
	PRINT @ClmGrpId
	PRINT @ClmSts
	PRINT @ClmConfSts
	PRINT @ClmCode
	---------- Added by lakshman M on 07/05/2018 PMS ID: ILCRSTPAR0478  new columns added in CS (Schcode,SchFrmDate,SchToDate,TaxAmount)----------------
	Create TABLE #RptClaimTopSheet
	(
			ClmCode			 NVARCHAR(50),
			ClmDesc		 	 NVARCHAR(50),
			ClmDate			 DATETIME,
			Schcode			 NVARCHAR(50),
			SchDesc			 NVARCHAR(100),
			SchFrmDate		 NVARCHAR(50),
			SchToDate		 NVARCHAR(50),	
			DiscountVal		 NUMERIC(38,6),
			FreePrdVal		 NUMERIC(38,6),
			GiftPrdVal		 NUMERIC(38,6),
			TotalSpend		 NUMERIC(38,6),
			TaxAmount		 NUMERIC(38,6),
			ClmPercentage	 NUMERIC(38,2),
			ClmAmount		 NUMERIC(38,6),
			RecommendedAmt	 NUMERIC(38,6),
			ReceivedAmt		 NUMERIC(38,6),
			CrDbNote		 NVARCHAR(50),
			Status			 NVARCHAR(50),
			ConfirmSts		 NVARCHAR(50),
			ClmType			 INT,
			ClmGrpId		 INT
	)
	SET @TblName = 'RptClaimTopSheet'
	SET @TblStruct ='ClmCode		 NVARCHAR(50),
			ClmDesc		 	 NVARCHAR(50),
			ClmDate			 DATETIME,
			Schcode			 NVARCHAR(50),
			SchDesc			 NVARCHAR(100),
			SchFrmDate		 NVARCHAR(50),
			SchToDate		 NVARCHAR(50),
			DiscountVal		 NUMERIC(38,6),
			FreePrdVal		 NUMERIC(38,6),
			GiftPrdVal		 NUMERIC(38,6),
			TotalSpend		 NUMERIC(38,6),
			TaxAmount		 NUMERIC(38,6),
			ClmPercentage	 NUMERIC(38,2),
			ClmAmount		 NUMERIC(38,6),
			RecommendedAmt	 NUMERIC(38,6),
			ReceivedAmt		 NUMERIC(38,6),
			CrDbNote		 NVARCHAR(50),
			Status			 NVARCHAR(50),
			ConfirmSts		 NVARCHAR(50),
			ClmType			 INT,
			ClmGrpId		 INT'
	
	SET @TblFields = 'ClmCode,ClmDesc,ClmDate,Schcode,SchDesc,SchFrmDate,SchToDate,DiscountVal,FreePrdVal,GiftPrdVal,TotalSpend,TaxAmount,
			ClmPercentage,ClmAmount,RecommendedAmt,ReceivedAmt,CrDbNote,Status,ConfirmSts,ClmType,ClmGrpId'
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
	
		INSERT INTO #RptClaimTopSheet (ClmCode,ClmDesc,ClmDate,Schcode,SchDesc,SchFrmDate,SchToDate,DiscountVal,FreePrdVal,GiftPrdVal,TotalSpend,TaxAmount,
		ClmPercentage,ClmAmount,RecommendedAmt,ReceivedAmt,CrDbNote,Status,ConfirmSts,ClmType,ClmGrpId)
		SELECT A.ClmCode,A.ClmDesc,CONVERT(NVARCHAR(10),A.ClmDate,121) AS ClmDate,Schcode,C.SchDsc,CONVERT(NVARCHAR(10),SchValidFrom,121) AS SchValidFrom,CONVERT(NVARCHAR(10),SchValidTill,121)AS SchValidTill,B.Discount,B.FreePrdVal,
		SalesValue,B.TotalSpent,
		ISNULL(B.GSTTax,0) AS [GSTTax], 
		--CASE WHEN SalesValue > 0 Then SalesValue WHEN GSTTax  > 0 Then GSTTax WHEN GSTTax  < 0 Then GSTTax END AS [GSTTax],  -- commented By Lakshman M Dated ON 2018-11-20 PMS ID:ILCRSTPAR2606
		B.Liability,B.ClmAmount,B.RecommendedAmount,B.ReceivedAmount,
		CASE B.CrDbMode WHEN 1 THEN 'Debit Note' WHEN 2 THEN 'Credit Note' ELSE 'Claim' END AS CrDbNote,
		CASE B.Status WHEN 1 THEN 'Pending' WHEN 2 THEN 'Settled' WHEN 3 THEN 'Cancelled' END AS Status,
		CASE A.Confirm WHEN 1 THEN 'Confirmed' WHEN 2 THEN 'Not confirmed' END AS ConfirmSts,A.ClmType,A.ClmGrpId 
		FROM ClaimSheetHD A INNER JOIN ClaimSheetDetail B ON A.ClmId=B.ClmId
		--INNER JOIN schememaster C ON C.SchCode =B.RefCode /*Commented By Deepak */
		LEFT OUTER JOIN schememaster C ON C.SchCode =B.RefCode /*Added by Deepak K ILCRSTPAR1185*/
		WHERE (A.CmpId=(CASE @CmpId WHEN 0 THEN A.CmpId ELSE @CmpId END)OR
			A.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
	        AND (A.ClmGrpId=(CASE @ClmGrpId WHEN 0 THEN A.ClmGrpId ELSE @ClmGrpId END) OR
			A.ClmGrpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,42,@Pi_UsrId))) 
	        AND (B.Status = (CASE @ClmSts WHEN 0 THEN B.Status ELSE @ClmSts END) OR
			B.Status in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,124,@Pi_UsrId))) 
			AND (A.Confirm = (CASE @ClmConfSts WHEN 0 THEN A.Confirm ELSE 0 END) OR
			A.Confirm in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,125,@Pi_UsrId))) 
			AND (A.ClmId = (CASE @ClmCode WHEN 0 THEN A.ClmId ELSE @ClmCode END)OR
			A.ClmId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,41,@Pi_UsrId))) 
	        AND A.ClmDate BETWEEN @FromDate AND @ToDate
	---------- Till Here ----------------
	   	IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptClaimTopSheet ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ 'WHERE
				        (A.CmpId=(CASE @CmpId WHEN 0 THEN A.CmpId ELSE @CmpId END) 
				        AND A.ClmGrpId=(CASE @ClmGrpId WHEN 0 THEN A.ClmGrpId ELSE @ClmGrpId END) 
				        AND B.Status = (CASE @ClmSts WHEN 0 THEN B.Status ELSE @ClmSts END) 
					AND A.Confirm = (CASE @ClmConfSts WHEN 0 THEN A.Confirm ELSE @ClmConfSts END)
					AND A.ClmId = (CASE @ClmCode WHEN 0 THEN A.ClmId ELSE @ClmCode END) 			
				        AND A.ClmDate BETWEEN @FromDate AND @ToDate)'
			EXEC (@SSQL)
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptClaimTopSheet'
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
			SET @SSQL = 'INSERT INTO #RptClaimTopSheet ' +
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
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptClaimTopSheet
	-------------- Added by lakshman M On 03-05-2018 PMS ID: ILCRSTPAR0448---------------
	DECLARE @Rptname	AS	Varchar(100)
	DECLARE @ClmGroupname	AS	Varchar(100)
	Declare @frmDate As datetime
	Declare @TillDate As datetime 
	
	SET @Rptname ='' 
	SET @ClmGroupname =''
	SET @frmDate = ''
	SET @TillDate =''
	UPDATE RptHeader SET RpCaption='Claim Top Sheet Details Report' WHERE RPTID = @Pi_RptId
	
	SELECT @Rptname=RpCaption  FROM RptHeader WHERE RptId=@Pi_RptId
	SELECT @ClmGroupname=ClmGrpName,@frmDate=B.FromDate,@TillDate =B.todate FROM ClaimGroupMaster A inner join ClaimSheetHd B ON A.ClmGrpId =B.ClmGrpId
	INNER JOIN #RptClaimTopSheet C ON C.ClmGrpId =B.ClmGrpId WHERE C.ClmCode in(select ClmCode from #RptClaimTopSheet)
	SET @frmDate = ''
	SET @TillDate =''
	SELECT @frmDate=A.FromDate,@TillDate =A.ToDate from ClaimSheetHd A where A.ClmCode in(select ClmCode from #RptClaimTopSheet)
	
	SELECT @ClmGroupname=ClmGrpName FROM #RptClaimTopSheet A  
	INNER JOIN ClaimGroupMaster B ON A.ClmGrpId =B.ClmGrpId
	
	UPDATE RptHeader SET RpCaption=@ClmGroupname + ' - ' +  @Rptname +' For ' + CONVERT(varchar(10),@frmDate,105) +' - ' + CONVERT(varchar(10),@TillDate,105) WHERE RPTID = @Pi_RptId
	--UPDATE RptHeader SET RpCaption=@ClmGroupname + ' - ' +  @Rptname  WHERE RPTID = @Pi_RptId
	--select @ClmGroupname + ' - ' +  @Rptname + 'For' + CONVERT(varchar(10),@frmDate,121) +' - ' + CONVERT(varchar(10),@TillDate,121) from RptHeader WHERE RPTID = @Pi_RptId
	ALTER TABLE #RptClaimTopSheet drop column ClmGrpId
	------------ Till here -----------
	SELECT * FROM #RptClaimTopSheet
	------------- temp -------
IF NOT EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='rptheader_BK' AND XTYPE ='U')
BEGIN
	CREATE TABLE [dbo].[rptheader_BK](
		[rptid] [nvarchar](100) NULL,
		[RpCaption] [nvarchar](100) NULL
	) ON [PRIMARY]
END
DELETE FROM rptheader_BK
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('1','Sales Value Report - Bill Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('100','Purcahse Excess Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('101','Rate Difference Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('102','Special Discount Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('103','Van Subsidy Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('104','Purchase Ageing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('105','Manual Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('106','Salesman Incentive Claim Detail Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('107','Claim Top Sheet Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('108','Retailer Cheque Inventory Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('109','Supplier Cheque and DD Inventory Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('11','Input Output Tax Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('110','Purchase Order Product Norm Mapping Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('111','Purchase Invoice Series Settings Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('112','Stock Journal Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('113','Resell Damage Goods Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('114','Accounts Calendar Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('115','Cheque Payment Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('116','Counters')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('118','Opening Balance Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('119','Order Booking Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('12','Replacement Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('120','Product Sequencing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('121','Purchase Order Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('122','Purchase Payment Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('123','Purchase Return Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('124','Retailer Sequencing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('126','Standard Voucher Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('127','Stock Management Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('128','Transaction Sequencing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('129','Van Load Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('13','Item Price List')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('130','Van Unload Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('131','Return To Company Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('132','Return To Company Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('133','Batch Transfer Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('136','Retailer Stock Norm Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('137','Contract Pricing Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('138','KIT Product Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('139','Product Sales Bundle Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('14','Retailer Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('140','Focus Brand Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('141','Van Load Guide Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('142','Batch Creation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('143','Target Norm Mapping Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('144','Hot Search Editor Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('145','Bill Series Settings Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('146','Salesman Incentive Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('147','Purchase Sales Account')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('148','Purchase Return Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('149','Purchase Payment Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('15','Scheme Utilization')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('150','Datewise Productwise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('151','Stock Ledger Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('152','Scheme Utilization Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('153','ClosingStockReport')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('155','SalesmanAnanlysisReport')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('156','Focus SKU Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('157','Distributor Account Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('159','Sample Issue Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('165','Pending Bills Report-Shipping Address wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('168','Billwise Collection Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('169','DRCP New')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('17','Loading Sheet - Bill Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('171','Retailer Wise Value Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('18','Loading Sheet - Item Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('182','Ageing Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('183','BillWise ProductWise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('19','Loading Sheet - Collection Format')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('2','Product Wise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('20','Stock Adjustment Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('201','Fund Management Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('202','Price Difference Claim Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('203','Bench Marking Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('204','Discount Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('205','ASR Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('206','Retailer Master Detail Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('207','PSR Efficiency Datewise Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('21','Salvage Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('210','RetailerWise Productwise Sales Value and Volume Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('211','Effective Coverage Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('212','Outletwise Retailing')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('213','Modern Trade Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('214','MarketwiseRetailing')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('215','Retailer Wise Scheme Utilization Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('216','Netsales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('217','Retailer Accounts Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('219','Hierarchywise Stock and Sales Report - Volume Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('22','Location Transfer Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('220','Retailer and Product Wise Sales Volume')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('221','AksoNobalCurrentStock')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('222','Party Account Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('223','Sales Return Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('224','Retailer wise Bill wise Net Tax Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('225','Stock Ledger Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('228','JNJ Effective Coverage Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('229','Bill Wise Scheme Utilization')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('23','Company Wise Purchase Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('230','Sales UOM Based Current Stock Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('231','Retailer Category and Classification Shift')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('232','Sales Vat Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('233','UnLoadingSheetReport')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('234','DSR wise Report - Target Analysis')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('235','Launch Product Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('236','DSR wise BGR wise Report - Target Anlaysis')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('237','Brand wise Report - Target Anlaysis')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('238','Inter Stock Foresight')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('239','IDT Management Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('24','Product Purchase Report ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('240','Logistic Material Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('241','BillWise ProductWise Loading Sheet')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('242','Sub Stockist Claim Details')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('243','Business Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('244','Salesman Productivity Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('245','Stock and Sales Report - Volume Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('246','Scheme Utilization Report Parle')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('247','Product Wise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('248','Day End Collection Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('249','Current Stock Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('25','Product Wise VAT Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('250','Vat Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('251','Loading Sheet Item-Wise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('252','Effective Coverage Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('253','Monthly Vat Summary Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('254','ClosingStockReportParle')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('255','Supplier Accounts Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('256','Vat Computation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('257','LoadingSheetProductWiseUOMWise')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('258','UnLoading Sheet Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('26','Retailer - Supplier Wise VAT Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('27','Retailer Wise Bill Wise VAT Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('276','UPVAT XXIV Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('277','Guj govt VAT report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('278','Guj govt VAT report 201A')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('279','Supplier Wise VAT Purchase')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('28','Input VAT Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('280','RetailerWise VAT Sales')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('281','Day Wise Collection Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('282','Monthly Stock Statement')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('284','Bill Wise Market Return Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('285','BillWise Sales Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('286','Parle Claim Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('287','Scheme Utilization Details Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('288','Trade Promotion Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('289','Target Setting Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('29','Output VAT Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('290','Scheme Stock Reconciliation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('291','Debit Note Top Sheet')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('3','Pending Bills Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('30','Retailer Outstanding Report ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('32','Tax Summary Report ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('33','Claim Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('35','Profit And Loss Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('36','Trial Balance Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('37','Balance Sheet Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('38','Accounts Ledger-Day Book')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('39','Accounts Ledger-BANK BOOK')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('4','Collection Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('40','Accounts Ledger-CASH BOOK')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('401','Product Wise Output Tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('402','Product Wise Input Tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('404','Output Sale Tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('405','Input Tax Summary')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('406','ServiceInvoice Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('407','Product wise Input output tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('41','Product Track Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('411','FORM GSTR-3B')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('413','GSTR TRANS2')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('414','FORM GSTR1-B2B')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('415','FORM GSTR1-B2CL')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('416','FORM GSTR1-B2CS')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('417','FORM GSTR1-CNDR')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('418','FORM GSTR1-CDNUR')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('419','FORM GSTR1-HSN')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('42','Route Coverage Plan Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('420','FORM GSTR1-DOCS')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('421','FORM GSTR1-Exempt')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('422','HSN Code wise output tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('423','HSN Code wise Input tax')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('424','GSTR1 Extract')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('425','FORM GSTR2-B2B')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('426','FORM GSTR2-B2BUR')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('427','FORM GSTR2-HSNSUM')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('428','FORM GSTR2-NILRATE')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('429','FORM GSTR2-CDN')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('43','Rsp Sales Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('430','FORM GSTR2-SUMMARY')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('431','GSTR2-Extract')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('432','E Way Bill Template')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('44','Rsp Sales Trend Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('45','Sub Stockist Jc Closing Review Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('5','Current Stock Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('50','Dead Outlet Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('51','RPS Drive Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('52','Sales Analysis Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('53','Bank Slip Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('54','TLSD Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('55','DRCP Deviation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('56','Top Outlet Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('57','Window Display Contest Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('58','Distribution Width Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('59','Critical Sales Parameter Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('6','Stock and Sales Report - Volume Wise ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('60','Quantity Fill Ratio')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('61','Credit Evaluation Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('62','Outlet Class Shift Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('63','Purchase Sales Trend')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('64','Company Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('65','Location Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('66','Distributor Info Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('67','Stock Management Type Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('68','Transporter Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('69','Supplier Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('7','Stock and Sales Report - Value Wise ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('70','Udc Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('71','Vehicle Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('72','Vehicle Category Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('73','Bank Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('74','Bank Branch Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('75','Stock Type Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('76','User Key Mapping Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('77','User Maintenance Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('78','Tax Configuration Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('79','Tax Group Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('8','GRN Listing ')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('80','User Profile Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('81','Credit Note Retailer Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('82','Retailer Debit Note Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('83','Retailer Shipping Address Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('84','Supplier Credit Note Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('85','Supplier Debit Note Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('86','Vehicle SubSidy Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('87','Salesman Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('88','Route Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('89','Delivery Boy Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('9','Sales Return Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('90','Village Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('91','Claim Group Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('92','Claim Norm Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('93','Potential Classification Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('94','Value Classification Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('95','JC Calendar Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('96','Salesman Salary And DA Claim Details Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('97','Delivery Boy Salary And DA Claim Details Master  Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('98','Transporter Claim Master Report')
INSERT INTO rptheader_BK([rptid],[RpCaption]) VALUES ('99','Purcahse Shortage Claim Master Report')

UPDATE A set A.RpCaption  =B.rpcaption from rptheader_BK B INNER JOIN rptheader A ON A.Rptid =B.Rptid AND A.Rptid <> 107

RETURN
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Cs2Cn_SalesReturn]') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Cs2Cn_SalesReturn
GO
--BEGIN tran
--delete from Cs2Cn_Prk_SalesReturn
--EXEC Proc_Cs2Cn_SalesReturn 0,'2018-12-21'
--select * from Cs2Cn_Prk_SalesReturn where SRNRefNo ='PGST1800460'
--ROLLBACK tran
CREATE PROCEDURE Proc_Cs2Cn_SalesReturn 
(  
 @Po_ErrNo INT OUTPUT,
 @ServerDate DATETIME  
)  
AS
--EXEC Proc_Cs2Cn_SalesReturn 0   
/*********************************  
* PROCEDURE  : Proc_Cs2Cn_SalesReturn  
* PURPOSE  : To Extract Sales Return Details from CoreStocky to upload to Console  
* CREATED BY : Nandakumar R.G  
* CREATED DATE : 21/03/2010  
* NOTE   :  
* MODIFIED  
***************************************************************************************************  
* DATE         AUTHOR         CR/BZ    USER STORY ID           DESCRIPTION                           
***************************************************************************************************  
21-12-2018   Lakshman M        SR      ILCRSTPAR2905        AS per client request LCTR Formula validation changed special price not consider Now default price only considered in LCTR Value. 
*********************************/  
SET NOCOUNT ON  
BEGIN  
 DECLARE @CmpId    AS INT  
 DECLARE @DistCode  As nVarchar(50)  
 DECLARE @DefCmpAlone AS INT  
 SET @Po_ErrNo=0 

DECLARE @FromDate DATETIME  
DECLARE @ToDate DATETIME  
SELECT @FromDate = MIN(TransDate),@ToDate = MAX(TransDate) FROM UploadingReportTransaction S (NOLOCK)
EXEC Proc_SchUtilization_Report @FromDate,@ToDate
EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate  

SELECT * INTO #ParleOutputTaxPercentage  FROM ParleOutputTaxPercentage (NOLOCK) 
DECLARE @SlNo AS INT  
SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'
	
 SELECT @DefCmpAlone=ISNULL(Status,0) FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'  
 DELETE FROM Cs2Cn_Prk_SalesReturn WHERE UploadFlag = 'Y'  
 SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1   
 SELECT @DistCode = DistributorCode FROM Distributor  

 INSERT INTO [Cs2Cn_Prk_SalesReturn]  
 (  
  DistCode  ,  
  SRNRefNo  ,  
  SRNRefType  ,  
  SRNDate   ,  
  SRNMode   ,  
  SRNType   ,   
  SRNGrossAmt  ,  
  SRNSplDiscAmt ,   
  SRNSchDiscAmt ,  
  SRNCashDiscAmt ,  
  SRNDBDiscAmt ,  
  SRNTaxAmt  ,  
  SRNRoundOffAmt ,
  SRNInvDiscount,  
  SRNNetAmt  ,  
  SalesmanName ,  
  SalesRouteName ,  
  RtrId   ,  
  RtrCode   ,  
  RtrName   ,  
  PrdSalInvNo  ,  
  PrdLcnId  ,  
  PrdLcnCode  ,  
  PrdCode   ,  
  PrdBatCde  ,  
  PrdSalQty  ,  
  PrdUnSalQty  ,  
  PrdOfferQty  ,  
  PrdSelRate  ,  
  PrdGrossAmt  ,  
  PrdSplDiscAmt ,  
  PrdSchDiscAmt ,  
  PrdCashDiscAmt ,  
  PrdDBDiscAmt ,  
  PrdTaxAmt  ,  
  PrdNetAmt  ,  
  UploadFlag,
  RtrUniqueCode  
 )  
 SELECT  
  @DistCode ,  
  A.ReturnCode ,  
  (CASE ReturnType WHEN 1 THEN 'Market Return' ELSE 'Sales Return' END),  
  A.ReturnDate ,  
  (CASE A.ReturnMode WHEN 0 THEN '' WHEN 1 THEN 'Full' ELSE 'Partial' END),  
  (CASE A.InvoiceType WHEN 1 THEN 'Single Invoice' ELSE 'Multi Invoice' END),  
  A.RtnGrossAmt,A.RtnSplDisAmt,A.RtnSchDisAmt,A.RtnCashDisAmt,A.RtnDBDisAmt,  
  A.RtnTaxAmt,A.RtnRoundOffAmt,A.RtnInvLvlDisc,A.RtnNetAmt,  
  SM.SMName,C.RMName,A.RtrId,R.CmpRtrCode,R.RtrName,  
  ISNULL(G.SalInvno,B.SalCode) AS SalInvNo,  
  L.LcnId,L.LcnCode,    
  D.PrdCCode,F.CmpBatCode,  
  (CASE ST.SystemStockType WHEN 1 THEN BaseQty ELSE 0 END)AS SalQty,  
  (CASE ST.SystemStockType WHEN 2 THEN BaseQty ELSE 0 END)AS UnSalQty,  
  (CASE ST.SystemStockType WHEN 3 THEN BaseQty ELSE 0 END)AS OfferQty,  
  B.PrdEditSelRte ,  
  B.PrdGrossAmt,B.PrdSplDisAmt,B.PrdSchDisAmt,B.PrdCDDisAmt,B.PrdDBDisAmt,  
  B.PrdTaxAmt,B.PrdNetAmt,  
  'N' AS UploadFlag,ISNULL(R.RtrUniqueCode,'')  
  FROM ReturnHeader A INNER JOIN ReturnProduct B ON A.ReturnId = B.ReturnId  
  INNER JOIN RouteMaster C ON A.RMID = C.RMID  
  INNER JOIN Product D ON B.PrdId = D.PrdId  
  INNER JOIN Company E ON D.CmpId = E.CmpId  
  INNER JOIN ProductBatch F ON B.PrdBatId = F.PrdBatId  
  INNER JOIN Retailer R ON R.RtrId=A.RtrId  
  LEFT OUTER JOIN SalesInvoice G ON B.SalId = G.SalId  
  INNER JOIN Salesman SM ON A.SMId=SM.SMId  
  INNER JOIN StockType ST ON B.StockTypeId=ST.StockTypeId  
  INNER JOIN Location L ON L.LcnId=ST.LcnId  
  WHERE A.Status = 0 AND E.CmpId = (CASE @DefCmpAlone WHEN 1 THEN @CmpId ELSE E.CmpId END)  
  AND A.Upload=0 
 -------------- Added By LAkshman M dated ON 21-12-2018 PMS ID: ILCRSTPAR2905
 UPDATE PRK SET PRK.LCTRAmount=ISNULL(LCTRAmt,0)
 FROM Cs2Cn_Prk_SalesReturn PRK (NOLOCK)
 INNER JOIN 
 (
	SELECT R.ReturnId,R.ReturnCode,P.PrdCCode,PB.CmpBatCode,
	--(SUM(RP.BaseQty)*RP.PrdEditSelRte)+(SUM(RP.BaseQty)*RP.PrdEditSelRte)*(RPT.TaxPerc/100) AS LCTRAmt,
	ROUND(((Rp.BaseQty *(PBD.PrdBatDetailValue))+(Rp.BaseQty*PBD.PrdBatDetailValue)*(T.TaxPerc/100)),2) AS LCTRAmt,
	SUM(RPT.TaxableAmt) AS TaxableAmt,RPT.TaxPerc  
	FROM ReturnHeader R (NOLOCK)
	INNER JOIN ReturnProduct RP (NOLOCK) ON R.RETURNID=RP.RETURNID
	INNER JOIN ReturnProductTax RPT (NOLOCK) ON R.RETURNID=RPT.RETURNID AND RP.RETURNID=RPT.RETURNID AND RP.SlNO=RPT.PrdSlNo
	INNER JOIN Product P (NOLOCK) ON P.PrdId=RP.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON P.PrdId=PB.PrdId AND PB.PrdId=RP.PrdId AND RP.PrdBatId=PB.PrdBatId
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =PB.PrdBatId and DefaultPrice =1 AND PBD.SLNo =3
	INNER JOIN Cs2Cn_Prk_SalesReturn Prk (NOLOCK) ON Prk.PrdCode=P.PrdCCode AND Prk.PrdBatCde=PB.CmpBatCode
	INNER JOIN #ParleOutputTaxPercentage T (NOLOCK) ON R.SalId = T.Salid AND Rp.Slno = T.PrdSlno
	GROUP BY R.ReturnId,R.ReturnCode,P.PrdCCode,PB.CmpBatCode,RPT.TaxPerc,RP.PrdEditSelRte,Rp.BaseQty,PBD.PrdBatDetailValue,T.TaxPerc
	HAVING (SUM(RPT.TaxableAmt))>0
 ) Z ON Z.ReturnCode=PRK.SRNRefNo AND Z.PrdCCode=PRK.PrdCode AND Z.CmpBatCode=PRK.PrdBatCde
 ------------ Till here  ---------------
 UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),  
 ProcDate = CONVERT(nVarChar(10),GetDate(),121)  
 Where ProcId = 4  
 
 UPDATE ReturnHeader SET Upload=1 WHERE Upload=0 AND ReturnCode IN (SELECT DISTINCT  
 SRNRefNo FROM Cs2Cn_Prk_SalesReturn WHERE UploadFlag = 'N') AND Status=0   
 
 UPDATE Cs2Cn_Prk_SalesReturn SET ServerDate=@ServerDate
 
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_ValidateDayEndProcess' AND XTYPE ='P')
DROP PROCEDURE Proc_ValidateDayEndProcess
GO
---EXEC Proc_ValidateDayEndProcess '2012-02-07'
--SELECT * FROM DayEndValidation
CREATE PROCEDURE Proc_ValidateDayEndProcess
(
	@Pi_Fromdate AS DATETIME
)
AS
BEGIN
/*********************************
* PROCEDURE: Proc_ValidateDayEndProcess
* PURPOSE: To Validate the Day end
* NOTES: 
* CREATED:Murugan.R
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
* 17-07-2013 Praveenraj B for adding master user access validation for GCPL
------------------------------------------------*/
--DayEnd Type 1 --Find Jc Mont exists
--DayEnd Type 2 --Pending Day End
DECLARE @MonthEnd AS TINYINT
DECLARE @Pi_JcFromdate AS DATETIME
DECLARE @Pi_JcTodate AS DATETIME
DECLARE @CheckPendingTransaction AS TINYINT
DELETE FROM DayEndValidation
SET @MonthEnd=0
SET @CheckPendingTransaction=0
----------- Added By lakshman M Dated ON 07/01/2018 PMS ID: ILCRSTPAR3026 -------------
IF NOT EXISTS(SELECT * FROM stockledger)
BEGIN
	Return
END
----------- Till here -----------
IF NOT EXISTS(SELECT J.JcmId,JcmJc,JcmYr,JcmSdt,JcmEdt FROM JcMast J INNER JOIN Jcmonth Jc ON J.JcmId=Jc.JcmId INNER JOIN Company C On C.CmpId=J.CmpId
WHERE CONVERT(DATETIME,CONVERT(VARCHAR(10),@Pi_Fromdate,121),121) BETWEEN JcmSdt and JcmEdt And DefaultCompany=1)
BEGIN
	INSERT INTO DayEndValidation(DayEndType,DayEndStartDate,Status)
	SELECT 1,CONVERT(DATETIME,CONVERT(VARCHAR(10),@Pi_Fromdate,121),121),1
END	

SELECT  MIN(DayEndStartDate) as  DayEndStartDate 
INTO #DayEndExists
FROM DayEndDates WHERE DayEndStartDate<CONVERT(DATETIME,CONVERT(VARCHAR(10),@Pi_Fromdate,121),121)
AND Status=0

IF EXISTS(SELECT  * FROM #DayEndExists WHERE DayEndStartDate IS NOT NULL)
BEGIN
	INSERT INTO DayEndValidation(DayEndType,DayEndStartDate,Status)
	SELECT 2, MIN(DayEndStartDate) ,1 FROM DayEndDates WHERE DayEndStartDate<CONVERT(DATETIME,CONVERT(VARCHAR(10),@Pi_Fromdate,121),121)
	AND Status=0
END

IF EXISTS(SELECT TOP 1 JcmSdt,JcmEdt from JcmonthEnd WHERE Status=0 ORDER BY JcmSdt)
BEGIN
	SELECT TOP 1 JcmSdt,JcmEdt INTO #JCEND FROM JcmonthEnd WHERE Status=0 ORDER BY JcmSdt
	SELECT @Pi_JcFromdate=JcmSdt,@Pi_JcTodate=JcmEdt FROM #JCEND 
	IF NOT EXISTS(SELECT * from Dayenddates WHERE DayEndstartdate BETWEEN @Pi_JcFromdate and @Pi_JcTodate and Status=0)
	BEGIN
		INSERT INTO DayEndValidation(DayEndType,DayEndStartDate,Status)
		SELECT 3,JcmEdt ,1 FROM #JCEND 		
	END

END
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='PROC_CN2CS_RETAILERMIGRATION' AND XTYPE ='P')
DROP PROCEDURE Proc_Cn2Cs_RetailerMigration
GO
/*
Begin transaction
delete from ErrorLog
select * from RetailerMasterMigration
exec Proc_Cn2Cs_RetailerMigration 0
select * from RetailerMasterMigration
select * from ErrorLog
rollback transaction
*/  
CREATE PROCEDURE Proc_Cn2Cs_RetailerMigration
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_RetailerMigration 0
* PURPOSE		: Retailer to be Migrated from One DB to Other DB
* CREATED		: Sathishkumar Veeramani
* CREATED DATE	: 06/06/2014
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* DATE       AUTHOR     CR/BZ	USER STORY ID           DESCRIPTION                         
***************************************************************************************************
17-01-2018  lakshman M   BZ     ICRSTPAR7316          Retailer Tin No & Retailer Phone Number null values validation removed in Core stocky.
03-02-2018  lakshman M   BZ     ICRSTPAR7619          RtrPhone Number & RtrTinNumber Null values allowed in RetailerMasterMigartion Table
28-12-2018  Lakshman M   SR     ILCRSTPAR2934         As per client request Retailer default taxgroup validation included in core stocky.
***************************************************************************************************/
SET NOCOUNT ON
BEGIN
SET @Po_ErrNo=0
DECLARE @CmpId AS NUMERIC(18,0)
DECLARE @SmId AS NUMERIC(18,0)
DECLARE @RmId AS NUMERIC(18,0)
DECLARE @DlvRmId AS NUMERIC(18,0)
DECLARE @UdcMasterId AS NUMERIC(18,0)
DECLARE @DistCode AS NVARCHAR(200)
DECLARE @Taxgroupid AS INT

DELETE FROM Cn2Cs_Prk_RetailerMigration WHERE DownLoadFlag = 'Y'
SELECT @DistCode = DistributorCode FROM Distributor WITH(NOLOCK)
SELECT @CmpId = CmpId FROM Company (NOLOCK) WHERE DefaultCompany = 1
	
	CREATE TABLE #ToAvoidRetailerMigration
	(
	  SalesmanCode   NVARCHAR(200),
	  SalRouteCode   NVARCHAR(200),
	  DlvRouteCode   NVARCHAR(200), 
	  RetailerCode   NVARCHAR(200),
	  GeoLevel       NVARCHAR(200),
	  GeoCode        NVARCHAR(200)
	)
	
	--Route Geography Level Validation
	INSERT INTO #ToAvoidRetailerMigration(SalRouteCode,DlvRouteCode,GeoLevel)
	SELECT DISTINCT SalRouteCode,DlvRouteCode,RouteGeoLevel FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE RouteGeoLevel NOT IN 
	(SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'GeographyLevel','GeoLevelName','Route Geography Level Not Available-'+RouteGeoLevel FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE RouteGeoLevel NOT IN (SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	
	--Route Geography Value Validation
	INSERT INTO #ToAvoidRetailerMigration(SalRouteCode,DlvRouteCode,GeoCode)
	SELECT DISTINCT SalRouteCode,DlvRouteCode,RouteGeoCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE RouteGeoCode NOT IN 
	(SELECT GeoCode FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Geography','GeoCode','Route Geography Not Available-'+RouteGeoCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE RouteGeoCode NOT IN (SELECT GeoCode FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRetailerMigration(SalRouteCode,DlvRouteCode,GeoCode)
	SELECT DISTINCT SalRouteCode,DlvRouteCode,RouteGeoCode FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE NOT EXISTS 
	(SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId
	WHERE A.RouteGeoLevel = B.GeoLevelName AND A.RouteGeoCode = C.GeoCode)
	 
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Geography','GeoCode','Route Geography Wrongly Mapped-'+RouteGeoLevel+'-'+RouteGeoCode	
	FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE NOT EXISTS (SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) 
	INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId WHERE A.RouteGeoLevel = B.GeoLevelName AND A.RouteGeoCode = C.GeoCode)
	
	--Salesman Details Validation
	INSERT INTO #ToAvoidRetailerMigration(SalesmanCode)
	SELECT DISTINCT SalesManCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE SalesManName IN 
	(SELECT SmName FROM Salesman WITH(NOLOCK)) AND DownloadFlag = 'D'
	
	--INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--SELECT DISTINCT 1,'Salesman','Salesman Name','Salesman Name Already Availabe-'+SalesManName 
	--FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE SalesManName IN (SELECT SmName FROM Salesman WITH(NOLOCK)) AND DownloadFlag = 'D'
	
	--Sales Route Details Validation
	INSERT INTO #ToAvoidRetailerMigration(SalRouteCode)
	SELECT DISTINCT SalRouteCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE SalRouteName IN 
	(SELECT RMName FROM RouteMaster WITH(NOLOCK) WHERE RMSRouteType = 1) AND DownloadFlag = 'D'
	
	--INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--SELECT DISTINCT 1,'RouteMaster','Route Name','Sales Route Name Already Availabe-'+SalRouteName FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	--WHERE SalRouteName IN (SELECT RMName FROM RouteMaster WITH(NOLOCK) WHERE RMSRouteType = 1) AND DownloadFlag = 'D'
	
	--Delivery Route Details Validation
	INSERT INTO #ToAvoidRetailerMigration(DlvRouteCode)
	SELECT DISTINCT DlvRouteCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DlvRouteName IN 
	(SELECT RMName FROM RouteMaster WITH(NOLOCK) WHERE RMSRouteType = 2) AND DownloadFlag = 'D'
	
	--INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--SELECT DISTINCT 1,'RouteMaster','Route Name','Delivery Route Name Already Availabe-'+DlvRouteName FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	--WHERE DlvRouteName IN (SELECT RMName FROM RouteMaster WITH(NOLOCK) WHERE RMSRouteType = 2) AND DownloadFlag = 'D'
	
	--Retailer Details Validation
	--Retailer UNIQUE Code
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE EXISTS(
	SELECT * FROM RETAILER B WHERE A.RtrUniqueCode=B.RtrUniqueCode) AND DownloadFlag = 'D'
--	(RtrCode IS NULL OR RtrCode = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrUniqueCode','Duplicate Retailer Unique Code Not Allow-'+RtrUniqueCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE EXISTS(
	SELECT * FROM RETAILER B WHERE A.RtrUniqueCode=B.RtrUniqueCode) AND DownloadFlag = 'D'
	
	
	--Retailer UNIQUE Code
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (RtrUniqueCode IS NULL OR RtrUniqueCode = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrUniqueCode','Retailer Unique Code Should Not be Empty-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (RtrUniqueCode IS NULL OR RtrUniqueCode = '') AND DownloadFlag = 'D'
		
	----Duplicate Retailer Phone No & Tin No.
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	EXISTS(SELECT RTRID FROM RETAILER B(NOLOCK) WHERE A.RtrPhoneNo=B.RtrPhoneNo) AND DownloadFlag = 'D'
	And ISNULL(A.RTRPHONENO,'') <> ''
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrPhoneNo','Duplicate Phone Number Not allow-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	EXISTS(SELECT RTRID FROM RETAILER B(NOLOCK) WHERE A.RtrPhoneNo=B.RtrPhoneNo) AND DownloadFlag = 'D'
	AND ISNULL(A.RTRPHONENO,'') <> ''
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	EXISTS(SELECT RTRID FROM RETAILER B(NOLOCK) WHERE A.RtrTinNumber=B.RtrTINNo) AND DownloadFlag = 'D'
	AND ISNULL(A.RtrTinNumber,'') <> ''
	----------------- Retailer Tin No validation commented by lakshman M on 17/01/2018 PMS ID: ICRSTPAR7316 --------------------
	--INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--SELECT DISTINCT 1,'Retailer','RtrTinNumber','Duplicate Tin Number Not allow-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	--EXISTS(SELECT RTRID FROM RETAILER B(NOLOCK) WHERE A.RtrTinNumber=B.RtrTINNo) AND DownloadFlag = 'D'
	--AND ISNULL(A.RtrTinNumber,'') <> ''
	
	--INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	--SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE LEN(RtrTinNumber) NOT BETWEEN 8 AND 12 AND DownloadFlag = 'D'
	--INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--SELECT DISTINCT 1,'Retailer','RtrTinNumber','Tin Number length Should be between 8 to 12-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	--LEN(RtrTinNumber) NOT BETWEEN 8 AND 12 AND DownloadFlag = 'D'
	
	--INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	--SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE LEN(RtrPhoneNo) NOT BETWEEN 8 AND 10 AND DownloadFlag = 'D'
	--INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--SELECT DISTINCT 1,'Retailer','RtrPhoneNo','Phone Number length Should be between 8 to 10-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE 
	--LEN(RtrPhoneNo) NOT BETWEEN 8 AND 10 AND DownloadFlag = 'D'
---------------------- Till Here ---------------------
	--Retailer Code
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (RtrCode IS NULL OR RtrCode = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrCode','Retailer Code Should Not be Empty-'+RtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (RtrCode IS NULL OR RtrCode = '') AND DownloadFlag = 'D'
	
	--Company Retailer Code
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (CmpRtrCode IS NULL OR CmpRtrCode = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrCode','Company Retailer Code Should Not be Empty-'+CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (CmpRtrCode IS NULL OR CmpRtrCode = '') AND DownloadFlag = 'D'
	
	--Retailer Name
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (RtrName IS NULL OR RtrName = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrCode','Retailer Name Should Not be Empty-'+RtrName FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (RtrName IS NULL OR RtrName = '') AND DownloadFlag = 'D'
	
	--Retailer Address
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE (RtrAddress1 IS NULL OR RtrAddress1 = '') AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrCode','Retailer Address1 Should Not be Empty-'+RtrAddress1 FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE (RtrAddress1 IS NULL OR RtrAddress1 = '') AND DownloadFlag = 'D'
	
	--Retailer Geography Level Validation
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE RetailerGeoLevel NOT IN 
	(SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'GeographyLevel','GeoLevelName','Retailer Geography Level Not Available-'+RetailerGeoLevel FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE RetailerGeoLevel NOT IN (SELECT GeoLevelName FROM GeographyLevel (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM (SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT RetailerGeoLevel) AS RetailerGeoLevel 
	FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' GROUP BY CmpRtrCode HAVING COUNT(DISTINCT RetailerGeoLevel) > 1)Qry
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'GeographyLevel','GeoLevelName','Retailer Geography Level Should be Same-'+CmpRtrCode FROM (
	SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT RetailerGeoLevel) AS Counts FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D'
	GROUP BY CmpRtrCode HAVING COUNT(DISTINCT RetailerGeoLevel) > 1)Qry
	
	--Retailer Geography Value Validation
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE RetailerGeoCode NOT IN 
	(SELECT GeoName FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Geography','GeoCode','Retailer Geography Not Available-'+RetailerGeoCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) 
	WHERE RetailerGeoCode NOT IN (SELECT GeoName FROM Geography (NOLOCK)) AND DownloadFlag = 'D'
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM (SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT RetailerGeoCode) AS RetailerGeoCode 
	FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' GROUP BY CmpRtrCode HAVING COUNT(DISTINCT RetailerGeoCode) > 1)Qry
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'GeographyLevel','GeoLevelName','Retailer Geography Should be Same-'+CmpRtrCode FROM (
	SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT RetailerGeoCode) AS RetailerGeoCode FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' 
	GROUP BY CmpRtrCode HAVING COUNT(DISTINCT RetailerGeoCode) > 1)Qry
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE NOT EXISTS 
	(SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId
	WHERE A.RetailerGeoLevel = B.GeoLevelName AND A.RetailerGeoCode = C.GeoName)
	 
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Geography','GeoCode','Retailer Geography Wrongly Mapped-'+RetailerGeoLevel+'-'+RetailerGeoCode 
	FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE NOT EXISTS (SELECT DISTINCT GeoLevelName,GeoCode FROM GeographyLevel B (NOLOCK) 
	INNER JOIN Geography C (NOLOCK) ON B.GeoLevelId = C.GeoLevelId WHERE A.RetailerGeoLevel = B.GeoLevelName AND A.RetailerGeoCode = C.GeoName)
	
	--Retailer Multiple Delivery Route
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
	SELECT DISTINCT CmpRtrCode FROM (
	SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT DlvRouteCode) AS Counts FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D'
	GROUP BY CmpRtrCode	HAVING COUNT(DISTINCT DlvRouteCode) >1) Qry
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Route','RMcode','Retailer Delivery Route Should be Same-'+CmpRtrCode FROM (
	SELECT DISTINCT CmpRtrCode,COUNT(DISTINCT DlvRouteCode) AS Counts FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' 
	GROUP BY CmpRtrCode	HAVING COUNT(DISTINCT DlvRouteCode) >1) Qry	
	
	--Retailer Category Value Class	Validation
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)
    SELECT CmpRtrCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE DownLoadFlag = 'D' AND NOT EXISTS (
    SELECT DISTINCT C.CtgCode,D.CtgCode,E.ValueClassCode FROM RetailerCategoryLevel B WITH(NOLOCK)
    INNER JOIN RetailerCategory C WITH(NOLOCK) ON B.CtgLevelId = C.CtgLevelId 
    INNER JOIN RetailerCategory D WITH(NOLOCK) ON C.CtgMainId = D.CtgLinkId 
    INNER JOIN RetailerValueClass E WITH(NOLOCK) ON D.CtgMainId = E.CtgMainId WHERE A.RtrChannelCode = C.CtgCode AND
    A.RtrGroupCode = D.CtgCode AND A.RtrClassCode = E.ValueClassCode)
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'RetailerValueClass','ValueClassCode','Retailer Category and Value Class Not Available-'+
	RtrChannelCode+'-'+RtrGroupCode+'-'+RtrClassCode FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) WHERE DownLoadFlag = 'D' AND NOT EXISTS (
    SELECT DISTINCT C.CtgCode,D.CtgCode,E.ValueClassCode FROM RetailerCategoryLevel B WITH(NOLOCK)
    INNER JOIN RetailerCategory C WITH(NOLOCK) ON B.CtgLevelId = C.CtgLevelId 
    INNER JOIN RetailerCategory D WITH(NOLOCK) ON C.CtgMainId = D.CtgLinkId 
    INNER JOIN RetailerValueClass E WITH(NOLOCK) ON D.CtgMainId = E.CtgMainId WHERE A.RtrChannelCode = C.CtgCode AND
    A.RtrGroupCode = D.CtgCode AND A.RtrClassCode = E.ValueClassCode)
    -- Phone & Tin Number Dublicate Validation
	--IF EXISTS (SELECT '*' FROM Configuration WHERE ModuleId = 'GENCONFIG30' AND ModuleName = 'General Configuration' AND Status = 1)
	--BEGIN
	--	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)		
	--	SELECT DISTINCT CmpRtrCode from Cn2Cs_Prk_RetailerMigration (NOLOCK) WHERE isnull(RtrPhoneNo,'') = ''
		
	--	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	--	SELECT DISTINCT 1,'Retailer','RtrPhoneNo','Retailer Phone Number Should be Mandatory-'+ RtrCode 
	--	FROM Cn2Cs_Prk_RetailerMigration  (NOLOCK)	where isnull(RtrPhoneNo,'') = ''		
		
	--END
    	
	SELECT DISTINCT RtrPhoneNo,COUNT(RtrPhoneNo) AS Counts INTO #RtrPhoneNo FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' 
	group BY RtrPhoneNo HAVING COUNT(RtrPhoneNo) >1	
	
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)		
	SELECT DISTINCT CmpRtrCode from Cn2Cs_Prk_RetailerMigration A (NOLOCK) 
	INNER JOIN #RtrPhoneNo B (NOLOCK) ON A.RtrPhoneNo = B.RtrPhoneNo
	where isnull(A.RtrPhoneNo,'') <> ''
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrPhoneNo','Retailer Phone Number Should be Unique-'+ A.RtrCode 
	FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) INNER JOIN #RtrPhoneNo B (NOLOCK) ON A.RtrPhoneNo = B.RtrPhoneNo	
	where isnull(A.RtrPhoneNo,'') <> ''
	--Tin Number Validation
	SELECT DISTINCT RtrTinNumber,COUNT(RtrTinNumber) AS Counts INTO #RtrTinNumber FROM Cn2Cs_Prk_RetailerMigration WITH(NOLOCK) WHERE DownloadFlag = 'D' 
	group BY RtrTinNumber HAVING COUNT(RtrTinNumber) >1
	INSERT INTO #ToAvoidRetailerMigration(RetailerCode)		
	SELECT DISTINCT CmpRtrCode from Cn2Cs_Prk_RetailerMigration A (NOLOCK) 
	INNER JOIN #RtrTinNumber B (NOLOCK) ON A.RtrTinNumber = B.RtrTinNumber
	WHERE isnull(A.RtrTinNumber,'') <> '' 
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)	
	SELECT DISTINCT 1,'Retailer','RtrTinNumber','Retailer Tin Number Should be Unique-'+ A.RtrCode 
	FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) INNER JOIN #RtrTinNumber B (NOLOCK) ON A.RtrTinNumber = B.RtrTinNumber
	WHERE isnull(A.RtrTinNumber,'') <> '' 
     	
	--To Insert the Salesman Details
	SELECT @SmId = ISNULL(MAX(SMId),0) FROM Salesman (NOLOCK)
	
	INSERT INTO SalesmanMasterMigration (SMDCode,SMNCode,SMName,Upload,DownloadedDate)
	SELECT DISTINCT SalesmanCode,'SM0'+CAST((DENSE_RANK ()OVER (ORDER BY SalesManName)+@SmId) AS NVARCHAR(200))+'-'+@DistCode AS SMCode,
	SalesManName,0 AS Upload,CONVERT(NVARCHAR(10),GETDATE(),121)
	FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE DownLoadFlag = 'D' AND NOT EXISTS 
	(SELECT ISNULL(SalesmanCode,'') FROM #ToAvoidRetailerMigration B WHERE A.SalesmanCode = ISNULL(B.SalesmanCode,''))
	
	INSERT INTO Salesman (SMId,SMCode,SMName,SMPhoneNumber,SMEmailID,SMOtherDetails,SMDailyAllowance,SMMonthlySalary,SMMktCredit,SMCreditDays,CmpId,
    SalesForceMainId,Status,SMCreditAmountAlert,SMCreditDaysAlert,UpLoad,Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
	SELECT DISTINCT (DENSE_RANK ()OVER (ORDER BY SalesManName)+@SmId) AS SmId,
	'SM0'+CAST((DENSE_RANK ()OVER (ORDER BY SalesManName)+@SmId) AS NVARCHAR(200))+'-'+@DistCode AS SMCode,SalesManName,0 AS SMPhoneNumer,
	'' AS SMEmailID,'' AS SMOtherDetails,0.00 AS SMDailyAllowance,0.00 AS SMMonthlySalary,0.00 AS SMMktCredit,0 AS SMCreditDays,0 AS CmpId,
	0 AS SalesForceMainId,1 AS [Status],0 AS SMCreditAmountAlert,0 AS SMCreditDaysAlert,'N' AS UpLoad,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,
	CONVERT(NVARCHAR(10),GETDATE(),121),0 FROM Cn2Cs_Prk_RetailerMigration A (NOLOCK) WHERE DownLoadFlag = 'D' AND NOT EXISTS 
	(SELECT ISNULL(SalesmanCode,'') FROM #ToAvoidRetailerMigration B WHERE A.SalesmanCode = ISNULL(B.SalesmanCode,''))
	
	SELECT @SmId = ISNULL(MAX(SMId),0) FROM Salesman (NOLOCK)	
	UPDATE Counters SET CurrValue = @SmId WHERE TabName = 'Salesman' AND FldName = 'SMId'
	
	--To Insert the Sales Route Details 
	SELECT @RmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	SELECT @DlvRmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	
	INSERT INTO RouteMasterMigration (RMSalDCode,RMSalNCode,RMSalName,RMDlvDCode,RMDlvNCode,RMDlvName,Upload,DownloadedDate)
	SELECT DISTINCT SalRouteCode,'SR0'+CAST((DENSE_RANK ()OVER (ORDER BY SalRouteName)+@RmId) AS NVARCHAR(200))+'-'+@DistCode AS RMCode,SalRouteName,
	DlvRouteCode,'DR0'+CAST((DENSE_RANK ()OVER (ORDER BY DlvRouteName)+@DlvRmId) AS NVARCHAR(200))+'-'+@DistCode AS RMCode,
	DlvRouteName,0 AS Upload,CONVERT(NVARCHAR(10),GETDATE(),121)
	FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) INNER JOIN Geography B WITH(NOLOCK) ON A.RouteGeoCode = B.GeoCode 
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ISNULL(SalRouteCode,'') FROM #ToAvoidRetailerMigration C 
	WHERE A.SalRouteCode = ISNULL(C.SalRouteCode,'') AND A.DlvRouteCode = ISNULL(C.DlvRouteCode,'')) 
	
	INSERT INTO RouteMaster (RMId,RMCode,RMName,CmpId,RMDistance,RMPopulation,GeoMainId,RMVanRoute,RMSRouteType,RMLocalUpcountry,RMMon,RMTue,
    RMWed,RMThu,RMFri,RMSat,RMSun,RMstatus,UpLoad,Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
	SELECT DISTINCT (DENSE_RANK ()OVER (ORDER BY SalRouteName)+@RmId) AS RmId,
	'SR0'+CAST((DENSE_RANK ()OVER (ORDER BY SalRouteName)+@RmId) AS NVARCHAR(200))+'-'+@DistCode AS RMCode,SalRouteName,@CmpId,0.00 AS RMDistance,
	0.00 AS RMPopulation,GeoMainId,1 AS RMVanRoute,1 AS RMSRouteType,1 AS RMLocalUpcountry,0 AS RMMon,0 AS RMTue,0 AS RMWed,0 AS RMThu,0 AS RMFri,
	0 AS RMSat,0 AS RMSun,1 AS RMstatus,'N' AS UpLoad,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0   
	FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) INNER JOIN Geography B WITH(NOLOCK) ON A.RouteGeoCode = B.GeoCode 
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ISNULL(SalRouteCode,'') FROM #ToAvoidRetailerMigration C WHERE A.SalRouteCode = ISNULL(C.SalRouteCode,''))
	
	--To Insert the Delivery Route Details
	SELECT @RmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	
	INSERT INTO RouteMaster (RMId,RMCode,RMName,CmpId,RMDistance,RMPopulation,GeoMainId,RMVanRoute,RMSRouteType,RMLocalUpcountry,RMMon,RMTue,
    RMWed,RMThu,RMFri,RMSat,RMSun,RMstatus,UpLoad,Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
	SELECT DISTINCT (DENSE_RANK ()OVER (ORDER BY DlvRouteName)+@RmId) AS RmId,
	'DR0'+CAST((DENSE_RANK ()OVER (ORDER BY DlvRouteName)+@DlvRmId) AS NVARCHAR(200))+'-'+@DistCode AS RMCode,DlvRouteName,@CmpId,0.00 AS RMDistance,
	0.00 AS RMPopulation,GeoMainId,1 AS RMVanRoute,2 AS RMSRouteType,1 AS RMLocalUpcountry,0 AS RMMon,0 AS RMTue,0 AS RMWed,0 AS RMThu,0 AS RMFri,
	0 AS RMSat,0 AS RMSun,1 AS RMstatus,'N' AS UpLoad,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0   
	FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) INNER JOIN Geography B WITH(NOLOCK) ON A.RouteGeoCode = B.GeoCode 
	WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ISNULL(DlvRouteCode,'') FROM #ToAvoidRetailerMigration C WHERE A.DlvRouteCode = ISNULL(C.DlvRouteCode,''))
	
	SELECT @RmId = ISNULL(MAX(RMId),0) FROM RouteMaster (NOLOCK)
	UPDATE Counters SET CurrValue = @RmId WHERE TabName = 'RouteMaster' AND FldName = 'RMId'
	
	--Salesman Market Value Added
	INSERT INTO SalesmanMarket (SMId,RMId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT DISTINCT SMId,RmId,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) 
	INNER JOIN RouteMaster B WITH(NOLOCK) ON A.SalRouteName = B.RMName 
	INNER JOIN Salesman C WITH(NOLOCK) ON A.SalesmanName = C.SMName WHERE B.RMSRouteType = 1 AND NOT EXISTS
	(SELECT SMId,RMId FROM SalesmanMarket D WITH(NOLOCK) WHERE C.SMId = D.SMId AND B.RMId = D.RMId)	
	
	
	--To Insert the Retailer Details
    SELECT DISTINCT SalesManName,RtrCode,CmpRtrCode,RtrName,RtrAddress1,RtrAddress2,RtrAddress3,RtrPincode,B.CtgMainId AS CtgLevelId,
    B.CtgCode AS CtgLevelCode,B.CtgName AS CtgLevelName,C.CtgMainId,C.CtgCode,C.CtgName,D.RtrClassId,D.ValueClassCode,D.ValueClassName,
    SalRouteName,DlvRouteName,[Status],RetailerGeoLevel,RetailerGeoCode,RtrPhoneNo,RtrTinNumber,RtrTaxGroupCode,ISNULL(E.RtrUniqueCode,'')  AS RtrUniqueCode
    INTO #RetailerMigrationDetails FROM RetailerCategoryLevel A WITH(NOLOCK) 
    INNER JOIN RetailerCategory B WITH(NOLOCK) ON A.CtgLevelId = B.CtgLevelId
    INNER JOIN RetailerCategory C WITH(NOLOCK) ON B.CtgMainId = C.CtgLinkId  
    INNER JOIN RetailerValueClass D WITH(NOLOCK) ON C.CtgMainId = D.CtgMainId 
    INNER JOIN Cn2Cs_Prk_RetailerMigration E WITH(NOLOCK) ON B.CtgCode = E.RtrChannelCode AND C.CtgCode = E.RtrGroupCode AND DownLoadFlag = 'D'
    AND D.ValueClassCode = E.RtrClassCode WHERE CmpRtrCode NOT IN (SELECT ISNULL(RetailerCode,'') FROM #ToAvoidRetailerMigration)
	INSERT INTO RetailerMasterMigration (SMName,RtrCode,CmpRtrCode,RtrName,RtrAddress1,RtrAddress2,RtrAddress3,RtrPincode,RtrCtgLevelId,RtrChannelCode,
	RtrCtgMainId,RtrGroupCode,RtrValClassId,RtrClassCode,RtrGeoLevelId,RtrGeoLvelName,RtrGeoId,RtrGeoName,RtrSalRMId,RtrSalRoute,RtrDlvRMId,RtrDlvRoute,
	RtrStatus,Upload,DownloadedDate,RtrPhoneNo,RtrTinNumber,RtrTaxGroupId,RtrUniqueCode)
	SELECT DISTINCT SalesManName,RtrCode,CmpRtrCode,RtrName,RtrAddress1,ISNULL(RtrAddress2,0) AS RtrAddress2,ISNULL(RtrAddress3,0) as RtrAddress3,RtrPincode,CtgLevelId,CtgLevelName,
	CtgMainId,CtgName,RtrClassId,ValueClassName,B.GeoLevelId,RetailerGeoLevel,C.GeoMainId,GeoName,D.RmId,SalRouteName,E.RmId,DlvRouteName,
	[Status],0 AS Upload,CONVERT(NVARCHAR(10),GETDATE(),121),ISNULL(RtrPhoneNo,0) AS RtrPhoneNo,ISNULL(RtrTinNumber,0) AS RtrTinNumber,---------- Null Values validation added in CS Pms id: ICRSTPAR7619
	ISNULL(TaxGroupId,0)AS RtrTaxGroupId,A.RtrUniqueCode
	FROM #RetailerMigrationDetails A (NOLOCK) 
	INNER JOIN GeographyLevel B WITH(NOLOCK) ON A.RetailerGeoLevel = B.GeoLevelName
	INNER JOIN Geography C WITH(NOLOCK) ON A.RetailerGeoCode = C.Geoname AND B.GeoLevelId = C.GeoLevelId
	INNER JOIN RouteMaster D WITH(NOLOCK) ON A.SalRouteName = D.RMName AND D.RMSRouteType = 1
	INNER JOIN RouteMaster E WITH(NOLOCK) ON A.DlvRouteName = E.RMName AND E.RMSRouteType = 2
	LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON A.RtrTaxGroupCode = TGS.RtrGroup AND TGS.TaxGroup = 1
	WHERE CmpRtrCode NOT IN (SELECT DISTINCT CmpRtrCode FROM RetailerMasterMigration (NOLOCK))
			
	UPDATE A SET A.Upload = 1 FROM SalesmanMasterMigration A WITH(NOLOCK) INNER JOIN Salesman B WITH (NOLOCK) ON A.SMName = B.SMName 
	
	UPDATE A SET A.Upload = 1 FROM RouteMasterMigration A WITH(NOLOCK) 
	INNER JOIN RouteMaster B WITH (NOLOCK) ON A.RMSalName = B.RMName AND B.RMSRouteType = 1
	INNER JOIN RouteMaster C WITH (NOLOCK) ON A.RMDlvName = C.RMName AND C.RMSRouteType = 2

	UPDATE A SET DownloadFlag = 'Y' FROM Cn2Cs_Prk_RetailerMigration A WITH(NOLOCK) 
	INNER JOIN RetailerMasterMigration B WITH(NOLOCK) ON A.CmpRtrCode = B.CmpRtrCode

	--------------- Added  by Lakshman M Dated ON 28-12-2018 PMS ID:ILCRSTPAR2934 Default taxgroup validation added.
	SELECT  @Taxgroupid = Taxgroupid from TaxGroupSetting where RtrGroup ='RTRINTRA'
	UPDATE A set Rtrtaxgroupid =@Taxgroupid FROM RetailerMasterMigration A WHERE Rtrtaxgroupid = 0
	------------- Till here ------------
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='Fn_SFAProductToSend' AND XTYPE ='TF')
DROP FUNCTION Fn_SFAProductToSend
GO
--SELECT * FROM Fn_SFAProductToSend()
CREATE FUNCTION Fn_SFAProductToSend()
RETURNS @SFAProduct TABLE
(
	PrdId	BIGINT
)
AS
/*******************************************************************************************
* PROCEDURE		: Fn_SFAProductToSend
* PURPOSE		: To Export Product details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 26/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
********************************************************************************************/
BEGIN
DECLARE @Pi_FrmDate AS DATETIME
	DECLARE @Pi_ToDate AS DATETIME
	SET @Pi_FrmDate=DATEADD(MONTH,-6,CONVERT(VARCHAR(10),GETDATE(),121))
	SET @Pi_ToDate=CONVERT(VARCHAR(10),GETDATE(),121)
	INSERT INTO @SFAProduct(PrdId)
	--SELECT DISTINCT PrdId FROM  Product A WITH (NOLOCK) WHERE PrdStatus = 1
	--UNION
	SELECT A.PrdId FROM PRODUCT A(NOLOCK)
	INNER JOIN SalesInvoiceProduct B (NOLOCK) ON A.PrdId=B.PrdId 
	INNER JOIN SalesInvoice C (NOLOCK) ON B.SalId=C.SalId 
	WHERE A.PrdStatus=1 AND C.SalInvDate between @Pi_FrmDate and @Pi_ToDate AND C.DlvSts in (4,5)
	UNION
	SELECT A.PrdId FROM PRODUCT A(NOLOCK)
	INNER JOIN SalesInvoiceSchemeDtFreePrd B (NOLOCK) ON A.PrdId=B.FreePrdId 
	INNER JOIN SalesInvoice C (NOLOCK) ON B.SalId=C.SalId
	WHERE A.PrdStatus=1 AND C.SalInvDate between @Pi_FrmDate and @Pi_ToDate AND C.DlvSts in (4,5)	
	UNION
	SELECT A.PrdId FROM PRODUCT A(NOLOCK)
	INNER JOIN ReturnProduct B (NOLOCK) ON A.PrdId=B.PrdId 
	INNER JOIN ReturnHeader C (NOLOCK) ON B.ReturnID=C.ReturnID 
	WHERE A.PrdStatus=1 AND C.ReturnDate between @Pi_FrmDate and @Pi_ToDate AND C.[Status] =0
	UNION
	SELECT A.PrdId FROM PRODUCT A(NOLOCK)
	INNER JOIN ReturnSchemeFreePrdDt B (NOLOCK) ON A.PrdId=B.FreePrdId 
	INNER JOIN ReturnHeader C (NOLOCK) ON B.ReturnID=C.ReturnID 
	WHERE A.PrdStatus=1 AND C.ReturnDate between @Pi_FrmDate and @Pi_ToDate AND C.[Status] =0
	UNION
	SELECT A.PrdId FROM PRODUCT A(NOLOCK)
	INNER JOIN PurchaseReceiptProduct B (NOLOCK) ON A.PrdId=B.PrdId 
	INNER JOIN PurchaseReceipt C (NOLOCK) ON B.PurRcptId=C.PurRcptId 
	WHERE A.PrdStatus=1 AND C.GoodsRcvdDate between @Pi_FrmDate and @Pi_ToDate AND C.[Status] =1
	UNION
	SELECT A.PrdId FROM PRODUCT A(NOLOCK)
	INNER JOIN ProductBatchLocation B (NOLOCK) ON A.PrdId=B.PrdId 
	WHERE A.PrdStatus=1 AND ISNULL(PrdBatLcnSih-PrdBatLcnRessih+PrdBatLcnUih-PrdBatLcnResUih+PrdBatLcnFre-PrdBatLcnResFre,0) >= 0

RETURN
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_PricingPlan' and xtype='P')
DROP PROCEDURE Proc_Export_CS2WS_PricingPlan
GO
--EXEC Proc_Export_CS2WS_PricingPlan '1'
CREATE PROCEDURE Proc_Export_CS2WS_PricingPlan
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_PricingPlan
* PURPOSE		: To Export Product Price details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 07/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
  29/11/2018   S.Moorthi    SR         ILCRSTPAR2692   0 price moved to SFA Application from Sehyog .
********************************************************************************************/
BEGIN
DECLARE @DistCode NVARCHAR(40)
DECLARE @Prdid AS int
DECLARE @Prdbatid AS int
	
	DELETE FROM Export_CS2WS_PricingPlan 
	
	SELECT @DistCode = DistributorCode FROM Distributor
	
	CREATE TABLE #Export_CS2WS_PricingPlan
	(
			PrdID				[Bigint],
			TenantCode			[nvarchar](12) COLLATE DATABASE_DEFAULT,
			PricingCode			[nvarchar](12)COLLATE DATABASE_DEFAULT,
			PricingDescription	[nvarchar](12)COLLATE DATABASE_DEFAULT,
			StartDate			[Datetime],
			EndDate				[Datetime],
			ItemCode			[nvarchar](50)COLLATE DATABASE_DEFAULT,
			UnitsOfMeasure		[nvarchar](20)COLLATE DATABASE_DEFAULT,	
			DebitPrice			[Float],
			CreditPrice			[Float],
			DamagePrice			[Float],
			PriceId				[BIGINT]
	)
	
	SELECT R.RtrId,R.CmpRtrCode,RC.CtgCode as GroupCode,RC.CtgMainId AS GroupId,
	RC1.CtgCode AS ChannelCode,RC1.CtgMainId AS ChannelId into #temp1 FROM Retailer R (NOLOCK)
	INNER JOIN RetailerValueClassMap RVCM (NOLOCK) ON R.RtrId=RVCM.RtrId 
	INNER JOIN RetailerValueClass RVC (NOLOCK) ON RVC.RtrClassId=RVCM.RtrValueClassId 
	INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CtgMainId=RVC.CtgMainId
	INNER JOIN RetailerCategory RC1 (NOLOCK) ON RC1.CtgMainId=RC.CtgLinkId 
	
	
	
	SELECT PBL.PrdId,PBL.PrdBatId INTO #TempPriceDt FROM Product A (NOLOCK) 
	INNER JOIN Fn_SFAProductToSend() B ON A.PrdId=B.PrdId
	INNER JOIN ProductBatchLocation PBL (NOLOCK) ON A.PrdId=PBL.PrdId and PBL.PrdId=B.PrdId
	WHERE PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih>0
	GROUP BY PBL.PrdId,PBL.PrdBatId

	INSERT INTO #Export_CS2WS_PricingPlan(Prdid,TenantCode,PricingCode,PricingDescription,StartDate,EndDate,
	ItemCode,UnitsOfMeasure,DebitPrice,CreditPrice,DamagePrice,PriceId)
	SELECT P.PrdId,@DistCode,R.CmpRtrCode,R.CmpRtrCode,A.ValidFromDate,A.ValidTillDate,  
	P.PrdCCode,UM.UomCode,0,0,0,MAX(B.PriceId) as PriceId
	FROM ContractPricingMaster A (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId=R.RtrId  
	INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId=B.ContractId 
	INNER JOIN #TempPriceDt TP ON TP.PrdId=B.PrdId AND TP.PrdBatID=B.PrdBatId 
	INNER JOIN Product P (NOLOCK) ON B.PrdId=P.PrdId AND TP.PrdId=P.PrdId 
	INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND  B.PrdId=FP.PrdId AND TP.PrdId=FP.PrdId 
	INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId AND UG.BaseUom='Y'
	INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId
	INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1 
	WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN  A.ValidFromDate AND A.ValidTillDate 
	AND A.[Status]=1 AND A.RtrId<>0
	GROUP BY P.PrdId,R.CmpRtrCode,R.CmpRtrCode,A.ValidFromDate,A.ValidTillDate,  
	P.PrdCCode,UM.UomCode
	
	SELECT DISTINCT PricingCode into #PricingCode from #Export_CS2WS_PricingPlan
	
	INSERT INTO #Export_CS2WS_PricingPlan(Prdid,TenantCode,PricingCode,PricingDescription,StartDate,EndDate,
	ItemCode,UnitsOfMeasure,DebitPrice,CreditPrice,DamagePrice,PriceId)
	SELECT P.PrdId,@DistCode,T.CmpRtrCode,T.CmpRtrCode,A.ValidFromDate,A.ValidTillDate,  
	P.PrdCCode,UM.UomCode,0,0,0,MAX(b.PriceId) as PriceId
	FROM ContractPricingMaster A (NOLOCK)
	INNER JOIN RetailerCategory R (NOLOCK) ON A.CtgMainId=R.CtgMainId  
	inner JOIN #temp1 T (NOLOCK) ON (T.ChannelId=R.CtgMainId OR T.GroupId=R.CtgMainId)
	inner join #PricingCode E (NOLOCK) ON E.PricingCode=T.CmpRtrCode	
	INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId=B.ContractId 
	INNER JOIN #TempPriceDt TP ON TP.PrdId=B.PrdId AND TP.PrdBatID=B.PrdBatId
	INNER JOIN Product P (NOLOCK) ON B.PrdId=P.PrdId  AND TP.PrdId=P.PrdId 
	INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND  B.PrdId=FP.PrdId AND TP.PrdId=FP.PrdId 
	INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId AND UG.BaseUom='Y'
	INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId
	INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1 
	WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN  A.ValidFromDate AND A.ValidTillDate 
	AND A.[Status]=1 AND A.CtgMainId<>0 AND 
	NOT EXISTS(SELECT * FROM #Export_CS2WS_PricingPlan EB INNER JOIN Product P (nolock) ON P.PrdCCode=EB.ItemCode 
	WHERE EB.PricingCode=T.CmpRtrCode AND EB.Prdid=P.PrdId AND EB.Prdid=FP.PrdId AND EB.Prdid=B.PrdId 
	AND EB.PricingCode=E.PricingCode)
	GROUP BY P.PrdId,T.CmpRtrCode,T.CmpRtrCode,A.ValidFromDate,A.ValidTillDate,  
	P.PrdCCode,UM.UomCode
	
	INSERT INTO #Export_CS2WS_PricingPlan(Prdid,TenantCode,PricingCode,PricingDescription,StartDate,EndDate,
	ItemCode,UnitsOfMeasure,DebitPrice,CreditPrice,DamagePrice,PriceId)
	SELECT P.PrdId,@DistCode,R.CtgCode,R.CtgCode,A.ValidFromDate,A.ValidTillDate,  
	P.PrdCCode,UM.UomCode,0,0,0,MAX(PriceId) As PriceId
	FROM ContractPricingMaster A (NOLOCK)
	INNER JOIN RetailerCategory R (NOLOCK) ON A.CtgMainId=R.CtgMainId  
	INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId=B.ContractId 
	INNER JOIN #TempPriceDt TP ON TP.PrdId=B.PrdId AND TP.PrdBatID=B.PrdBatId
	INNER JOIN Product P (NOLOCK) ON B.PrdId=P.PrdId   AND TP.PrdId=P.PrdId 
	INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND  B.PrdId=FP.PrdId AND TP.PrdId=FP.PrdId 
	INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId AND UG.BaseUom='Y'
	INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId
	INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1 
	WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN  A.ValidFromDate AND A.ValidTillDate 
	AND A.[Status]=1 AND A.CtgMainId<>0
	GROUP BY P.PrdId,R.CtgCode,R.CtgCode,A.ValidFromDate,A.ValidTillDate,  
	P.PrdCCode,UM.UomCode
	
	
	--SELECT A.PrdID,Max(PB.PrdBatId) AS PrdBatId	INTO #TempProductBatch FROM #Export_CS2WS_PricingPlan A 
	--INNER JOIN ProductBatch PB (NOLOCK) ON A.PrdID=PB.PRDID
	--WHERE  PrdBatCode <> 'Sample Batch' GROUP BY A.PrdID

	--SELECT DISTINCT P.PrdID,PB.PrdBatId,B1.PrdBatDetailValue as SellRate 
	--INTO #TempPriceDt
	--FROM Product P (NOLOCK)
	--INNER JOIN ProductBatch PB(NOLOCK) ON P.PrdID = PB.PrdID	
	--INNER JOIN #TempProductBatch PB1(NOLOCK) ON P.PrdID = PB1.PrdID AND PB.PrdBatId=PB1.PrdBatId AND PB.PrdID = PB1.PrdID
	--INNER JOIN ProductBatchDetails B1 (NOLOCK) ON PB.PrdBatId = B1.PrdBatID AND B1.DefaultPrice=1
	--INNER JOIN BatchCreation C1 (NOLOCK) ON C1.BatchSeqId = PB.BatchSeqId AND B1.SlNo = C1.SlNo AND C1.SelRte = 1 
	--ORDER BY P.PrdId
	
	
	UPDATE PP SET PP.DebitPrice=B1.PrdBatDetailValue,PP.CreditPrice=B1.PrdBatDetailValue,PP.DamagePrice=B1.PrdBatDetailValue
	FROM Product P (NOLOCK)
	INNER JOIN #Export_CS2WS_PricingPlan PP ON P.PrdId=PP.PrdID 
	INNER JOIN ProductBatchDetails B1 (NOLOCK) ON B1.PriceId=PP.PriceId
	INNER JOIN BatchCreation C1 (NOLOCK) ON C1.BatchSeqId = B1.BatchSeqId AND B1.SlNo = C1.SlNo AND C1.SelRte = 1 
	
	--As discussed Mr. Awanish to remove duplicate based on Max start date
	SELECT PricingCode,ItemCode INTO #TempDuplicate FROM #Export_CS2WS_PricingPlan 
	GROUP BY PricingCode,ItemCode HAVING COUNT(ItemCode)>1

	SELECT A.PricingCode,A.ItemCode,MAX(A.StartDate) AS StartDate INTO #TempMaxStartDate FROM #Export_CS2WS_PricingPlan A 
	INNER JOIN #TempDuplicate B ON A.PricingCode=B.PricingCode AND A.ItemCode=B.ItemCode 
	GROUP BY A.PricingCode,A.ItemCode
	
	DELETE A FROM #Export_CS2WS_PricingPlan A (NOLOCK)
	INNER JOIN #TempMaxStartDate B ON A.ItemCode=B.ItemCode AND A.PricingCode=B.PricingCode 
	WHERE NOT EXISTS(SELECT * FROM #TempMaxStartDate M WHERE M.PricingCode=A.PricingCode AND M.ItemCode=A.ItemCode AND 
	M.StartDate=A.StartDate)
		
	--UPDATE A SET A.DebitPrice=B.SellRate,A.CreditPrice=B.SellRate,A.DamagePrice=B.SellRate 
	--FROM #Export_CS2WS_PricingPlan A 
	--INNER JOIN #TempPriceDt B ON A.PrdID=B.PrdId and A.PricingCode=
	
	INSERT INTO Export_CS2WS_PricingPlan(TenantCode,PricingCode,PricingDescription,StartDate,EndDate,
	ItemCode,UnitsOfMeasure,DebitPrice,CreditPrice,DamagePrice,UploadFlag)
	SELECT TenantCode,PricingCode,PricingDescription,StartDate,EndDate,ItemCode,UnitsOfMeasure,
	DebitPrice,CreditPrice,DamagePrice,'N' UploadFlag FROM #Export_CS2WS_PricingPlan ORDER BY ItemCode
	
	SELECT  Distinct
			TenantCode,
			PricingCode,
			PricingDescription,
			--CONVERT(VARCHAR(10),StartDate,103) AS StartDate,
			--CONVERT(VARCHAR(10),EndDate,103) AS EndDate,
			ItemCode,
			UnitsOfMeasure,
			DebitPrice,
			CreditPrice,
			DamagePrice
		FROM Export_CS2WS_PricingPlan WITH (NOLOCK) 
	
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Proc_Export_CS2WS_Customer]') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_Export_CS2WS_Customer
GO
/*
BEGIN TRAN
DELETE FROM WSMasterExportUploadTrack
DELETE FROM Export_CS2WS_Customer
Exec Proc_Export_CS2WS_Customer '1'
select * from Export_CS2WS_Customer 
--select * from WSMasterExportUploadTrack
ROLLBACK TRAN
*/
CREATE PROCEDURE [dbo].[Proc_Export_CS2WS_Customer]
(
   @SalRpCode varchar(100)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_Customer 
* PURPOSE		: To Export Customer details to the PDA Intermediate Database
* CREATED		: AMUTHA KUMAR P
* CREATED DATE	: 16-08-2018
* MODIFIED		: 
* DATE			AUTHOR				USERSTORYID			CR/BZ      DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
* 16/08/2018   Amuthakumar P        CRCRSTAPAR0016        CR     To Export Customer details
* 29/11/2018   S.Moorthi    SR         ILCRSTPAR2692   0 price moved to SFA Application from Sehyog .
*********************************************************************************************************************/
BEGIN

	IF NOT EXISTS(SELECT * FROM Retailer WHERE RtrCode='Dummy')
	BEGIN
		DELETE FROM ETL_Prk_Retailer
		DELETE FROM ETL_Prk_RetailerShippingAddress
		DELETE FROM ETL_Prk_RetailerRoute
		DELETE FROM ETL_Prk_RetailerValueClassMap

		INSERT INTO ETL_Prk_Retailer([Retailer Code],[Retailer Name],[Address1],[Address2],[Address3],[Pin Code],[Phone No],[EmailId],[Key Account],[Coverage Mode],[Registration Date],[Day Off],[Status],[Taxable],[Tax Type],[TIN Number],[CST Number],[Tax Group],[Credit Bills],[Credit Limit],[Credit Days],[Cash Discount Percentage],[Cash Discount Condition],[Cash Discount Limit Value],[License Number],[License Number Expiry Date],[Drug License Number],[Drug License Number Expiry Date],[Pesticide License Number],
		[Pesticide License Number Expiry Date],[Geography Hierarchy Value],[Delivery Route Code],[Village Code],[Residence Phone No],[Office Phone No],[Deposit Amount],[Potential Class Code],[Retailer Type],[Retailer Frequency],[Credit Days Alert],[Credit Bills Alert],[Credit Limit Alert]) 
		VALUES ('Dummy','Dummy','Dummy','','','0','1201301401','','NO','Order Booking',CONVERT(varchar(10),GETDATE(),121),'Sunday','Active','Yes','NON VAT','','','RTRINTRA','0','0.00','0','0.00','>=','0.00','',NULL,'',NULL,'',NULL,'','',NULL,'','','0.00',NULL,'Retailer','Weekly','None','None','None')

		UPDATE ETL_Prk_Retailer SET [Delivery Route Code]=(
		SELECT TOP 1 RMCode FROM RouteMaster WHERE RMSRouteType=2 Order by RMId DESC)
		UPDATE ETL_Prk_Retailer SET [Geography Hierarchy Value]=(
		SELECT TOP 1 GeoCode FROM Geography Order by GeoMainId DESC)

		INSERT INTO ETL_Prk_RetailerShippingAddress([Retailer Code],[Address1],[Address2],[Address3],[Retailer Shipping Pin Code],[Retailer Shipping Phone No],[Default Shipping Address])
		VALUES ('Dummy','Dummy','0','0','0','0','YES')
		
		INSERT INTO ETL_Prk_RetailerRoute([Retailer Code],[Route Code],[Selection Type])
		SELECT TOP 1 'Dummy',RMCode,'ADD' FROM RouteMaster WHERE RMSRouteType=1 
		AND RMId IN (SELECT MAX(RMID) AS RMID FROM SalesmanMarket GROUP BY SMId)
		
		INSERT INTO ETL_Prk_RetailerValueClassMap([Retailer Code],[Value Class Code],[Category Level Value],[Selection Type])
		SELECT TOP 1 'Dummy',A.ValueClassCode,B.CtgCode,'ADD' FROM RetailerValueClass A (NOLOCK)
		INNER JOIN RetailerCategory B (NOLOCK) ON A.CtgMainId=B.CtgMainId 
		ORDER BY RtrClassId DESC
		EXEC Proc_ValidateRetailerMaster 0
		
		IF EXISTS(SELECT * FROM Retailer WHERE RtrCode='Dummy')
		BEGIN
			EXEC Proc_ValidateRetailerValueClassMap 0
			EXEC Proc_ValidateRetailerRoute 0
			EXEC Proc_ValidateRetailerShippingAddress 0 
		END
		
		IF EXISTS(SELECT * FROM Retailer WHERE RtrCode='Dummy' AND ISNULL(CmpRtrCode,'')<>'Dummy')
		BEGIN
			UPDATE Retailer SET CmpRtrCode='Dummy' WHERE RtrCode='Dummy'
			UPDATE CompanyCounters SET CurrValue = CurrValue-1 WHERE Tabname =  'Retailer' AND Fldname = 'CmpRtrCode'
		END  
	END

	DECLARE @Smid AS int
	DECLARE @Sql AS varchar(3000)
	DECLARE @Date AS datetime
	DECLARE @Week AS int
	DECLARE @WCal AS int
	DECLARE @StartDate AS datetime
	DECLARE @EndDate AS datetime
	SELECT @StartDate=JcmSdt FROM JCMonth WHERE CONVERT(varchar(10),getdate(),121) BETWEEN JcmSdt AND JcmEdt
	SELECT @EndDate = JcmEdt FROM JCMonth WHERE CONVERT(varchar(10),getdate(),121) BETWEEN JcmSdt AND JcmEdt
	SELECT @Week=jcwwk FROM JCWeek WHERE CONVERT(varchar(10),getdate(),121) BETWEEN JcwSdt AND JcwEdt
	
	SELECT @date=CONVERT(varchar(10),getdate(),121)
	DELETE FROM Export_CS2WS_Customer WHERE UploadFlag='Y'
	
	IF EXISTS (SELECT * FROM sysobjects WHERE NAME='TempRetailer' and xtype='U')
	BEGIN
		DROP TABLE TempRetailer
	END
IF EXISTS (SELECT count(DISTINCT jcwwk) FROM JCWeek WHERE JcmJc=month(getdate()) HAVING count(DISTINCT jcwwk)=6)
 BEGIN
	IF @Week=1 	BEGIN SET @WCal=6 END 
	IF @Week=2	BEGIN SET @WCal=5 END 
	IF @Week=3	BEGIN SET @WCal=4 END 
	IF @Week=4	BEGIN SET @WCal=3 END
	IF @Week=5	BEGIN SET @WCal=2 END
	IF @Week=6	BEGIN SET @WCal=1 END
 END 
IF EXISTS (SELECT count(DISTINCT jcwwk) FROM JCWeek WHERE JcmJc=month(getdate()) HAVING count(DISTINCT jcwwk)=5)
 BEGIN
	IF @Week=1 	BEGIN SET @WCal=5 END 
	IF @Week=2	BEGIN SET @WCal=4 END 
	IF @Week=3	BEGIN SET @WCal=3 END 
	IF @Week=4	BEGIN SET @WCal=2 END
	IF @Week=5	BEGIN SET @WCal=1 END
 END 
IF EXISTS (SELECT count(DISTINCT jcwwk) FROM JCWeek WHERE JcmJc=month(getdate()) HAVING count(DISTINCT jcwwk)=4)
BEGIN 
	IF @Week=1	BEGIN SET @WCal=4 END 
	IF @Week=2	BEGIN SET @WCal=3 END 
	IF @Week=3	BEGIN SET @WCal=2 END 
	IF @Week=4	BEGIN SET @WCal=1 END 
END 

SET @Sql ='SELECT distinct  DistributorCode,R.RtrID,R.CmpRtrCode,R.RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,GeoName,GeoName as State,RtrPinNo,Left(RtrPhoneNo,30)RtrPhoneNo,RtrEmailId,RtrContactPerson,
	RtrRemark1,RC1.CtgCode AS ChannelCode,RC.CtgCode as GroupCode,ValueClassCode,RtrStatus AS CustomerStatus,1 As SalesMode,1 AS PaymentType,CAST('''' AS VARCHAR(100)) AS CustomerPricingKey,0 RmId,RtrCrLimit,0 AS TotalBalanceDue,
	1 as IsTaxable, 0 as TaxId,0 as SurveyKey,RtrDOB as DateofBirth, RtrTinNo as RtrTinNO INTO TempRetailer
	FROM Retailer R 
	INNER JOIN Geography G ON R.GeoMainId = G.GeoMainId
	INNER JOIN RetailerValueClassMap RVM ON R.RtrID = RVM.RtrID 
	INNER JOIN RetailerValueClass RV ON RVM.RtrValueClassId = RV.RtrClassId
	INNER JOIN RetailerCategory RC ON RC.CtgMainId = RV.CtgMainId 
	INNER JOIN RetailerCategory RC1 (NOLOCK) ON RC1.CtgMainId=RC.CtgLinkId 
	CROSS JOIN Distributor D WHERE RtrStatus in(1)'
	EXEC (@Sql)

--SET @Sql ='SELECT DistributorCode,R.RtrID,R.CmpRtrCode,R.RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,GeoName,GeoName as State,RtrPinNo,Left(RtrPhoneNo,30)RtrPhoneNo,RtrEmailId,RtrContactPerson,
--	RtrRemark1,CtgCode,ValueClassCode,RtrStatus AS CustomerStatus,1 As SalesMode,1 AS PaymentType,0 AS CustomerPricingKey,RM.RmId,RtrCrLimit,0 AS TotalBalanceDue,
--	1 as IsTaxable, 0 as TaxId,0 as SurveyKey,RtrDOB as DateofBirth, RtrTinNo as RtrTinNO INTO TempRetailer
--	FROM Retailer R 
--	INNER JOIN Geography G ON R.GeoMainId = G.GeoMainId
--	INNER JOIN RetailerValueClassMap RVM ON R.RtrID = RVM.RtrID 
--	INNER JOIN RetailerValueClass RV ON RVM.RtrValueClassId = RV.RtrClassId
--	INNER JOIN RetailerCategory RC ON RC.CtgMainId = RV.CtgMainId 
--	INNER JOIN RetailerMarket RM ON RM.RtrId=R.RtrId
--	INNER JOIN SalesmanMarket SM ON sm.RMId=RM.RMId
--	CROSS JOIN Distributor D WHERE RtrStatus in(1) AND
--	sm.SMId in('+ CAST(@SalRpCode AS VARCHAR(100)) +')'
--	EXEC (@Sql)
		
	SELECT DISTINCT B.ColumnName,A.ColumnValue,MasterRecordId INTO #TEMPUDCROUTE1
	FROM UdcDetails A,UdcMaster B, UdcHD C WHERE  A.UdcMasterId=B.UdcMasterId
	AND A.MasterId=B.MasterId AND ColumnName='State Name' AND MasterName='Retailer Master'
	
		
	UPDATE T SET [State]=R.ColumnValue FROM TempRetailer T INNER JOIN #TEMPUDCROUTE1 R ON T.rtrid=R.MasterRecordId 
	
	SELECT R.RtrId,R.CmpRtrCode,RC.CtgCode as GroupCode,RC.CtgMainId AS GroupId,
	RC1.CtgCode AS ChannelCode,RC1.CtgMainId AS ChannelId into #temp1 FROM Retailer R (NOLOCK)
	INNER JOIN RetailerValueClassMap RVCM (NOLOCK) ON R.RtrId=RVCM.RtrId 
	INNER JOIN RetailerValueClass RVC (NOLOCK) ON RVC.RtrClassId=RVCM.RtrValueClassId 
	INNER JOIN RetailerCategory RC (NOLOCK) ON RC.CtgMainId=RVC.CtgMainId
	INNER JOIN RetailerCategory RC1 (NOLOCK) ON RC1.CtgMainId=RC.CtgLinkId 
	
	
	
	CREATE TABLE #PricingKey
	(
		CustomerCode	VARCHAR(100),
		CtgCode			VARCHAR(100)
	)
	
		
	SELECT PBL.PrdId,PBL.PrdBatId INTO #TempPriceDt FROM Product A (NOLOCK) 
	INNER JOIN Fn_SFAProductToSend() B ON A.PrdId=B.PrdId
	INNER JOIN ProductBatchLocation PBL (NOLOCK) ON A.PrdId=PBL.PrdId and PBL.PrdId=B.PrdId
	WHERE PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih>0
	GROUP BY PBL.PrdId,PBL.PrdBatId
	
	INSERT INTO #PricingKey(CustomerCode,CtgCode)
	SELECT DISTINCT R.CmpRtrCode,R.CmpRtrCode AS CmpRtrCode1 FROM ContractPricingMaster A (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId=R.RtrId  
	INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId=B.ContractId 
	INNER JOIN #TempPriceDt TP ON TP.PrdId=B.PrdId AND TP.PrdBatID=B.PrdBatId
	INNER JOIN Product P (NOLOCK) ON B.PrdId=P.PrdId AND TP.PrdId=P.PrdId 
	INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND  B.PrdId=FP.PrdId AND TP.PrdId=FP.PrdId 
	INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId AND UG.BaseUom='Y'
	INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId
	INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1 
	WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN  A.ValidFromDate AND A.ValidTillDate 
	AND A.[Status]=1 AND A.RtrId<>0

	
	UPDATE A SET A.CustomerPricingKey=B.CustomerCode FROM TempRetailer A INNER JOIN #PricingKey B ON A.CmpRtrCode=B.CustomerCode
	
	delete from #PricingKey
	
	INSERT INTO #PricingKey(CustomerCode,CtgCode)
	SELECT DISTINCT T.CmpRtrCode,R.CtgCode
	FROM ContractPricingMaster A (NOLOCK)
	INNER JOIN RetailerCategory R (NOLOCK) ON A.CtgMainId=R.CtgMainId  
	inner JOIN #temp1 T (NOLOCK) ON (T.ChannelId=R.CtgMainId OR T.GroupId=R.CtgMainId)
	INNER JOIN ContractPricingDetails B (NOLOCK) ON A.ContractId=B.ContractId 
	INNER JOIN #TempPriceDt TP ON TP.PrdId=B.PrdId AND TP.PrdBatID=B.PrdBatId
	INNER JOIN Product P (NOLOCK) ON B.PrdId=P.PrdId  AND TP.PrdId=P.PrdId 
	INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND  B.PrdId=FP.PrdId AND TP.PrdId=FP.PrdId 
	INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId AND UG.BaseUom='Y'
	INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId
	INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1 
	WHERE CONVERT(VARCHAR(10),GETDATE(),121) BETWEEN  A.ValidFromDate AND A.ValidTillDate 
	AND A.[Status]=1 AND A.CtgMainId<>0
	
	UPDATE A SET A.CustomerPricingKey=B.CtgCode FROM TempRetailer A INNER JOIN #PricingKey B ON A.CmpRtrCode=B.CustomerCode
	WHERE ISNULL(CustomerPricingKey,'')=''
	
	INSERT INTO Export_CS2WS_Customer(TenantCode,LocationCode,CustomerCode,CustomerName,Address1,Address2,Address3,Address4,City,State,Zip,Phone,Fax,Email,ContactPerson,
	Notes,CategoryCode1,CategoryCode2,CategoryCode3,CustomerStatus,SalesMode,PaymentType,CustomerPricingKey,TotalCreditLimit,TotalBalanceDue,
	IsTaxable,TaxID,HierarchyCode,TerritoryHierarchy,SurveyKey,DateofBirth,IDNumber,TINNumber,UploadFlag)
	SELECT DISTINCT  DistributorCode,DistributorCode,CmpRtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,'' as Address4,GeoName,State,RtrPinNo,RtrPhoneNo,'' as Fax,RtrEmailId,RtrContactPerson,
	RtrRemark1,ChannelCode,GroupCode,ValueClassCode,CustomerStatus,SalesMode,PaymentType,ISNULL(CustomerPricingKey,''),RtrCrLimit,TotalBalanceDue,IsTaxable,TaxID,GroupCode,'',SurveyKey,DateofBirth,'',RtrTinNo,
	'N' AS UploadFlag FROM TempRetailer R 
	WHERE NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = R.CmpRtrCode AND R.CustomerPricingKey=M.Reference2 AND M.ProcessName='Customer') 
	
	INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
	SELECT 'Customer',CustomerCode,CustomerName,GETDATE(),0,LocationCode,CustomerPricingKey,CategoryCode2,0 FROM Export_CS2WS_Customer WHERE UploadFlag='N'
	 
	
	UPDATE R SET R.WSUpload='Y' FROM WSMasterExportUploadTrack A (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.MasterCode=R.CmpRtrCode
	WHERE ISNULL(R.WSUpload,'N')='N' AND ProcessName='Customer'
		
	SELECT	DISTINCT 
			TenantCode,
			LocationCode,
			CustomerCode,
			CustomerName,
			Address1,
			Address2,
			Address3,
			Address4,
			City,
			State,
			Zip,
			Phone,
			Fax,
			Email,
			ContactPerson,
			Notes,
			CategoryCode1,
			CategoryCode2,
			CategoryCode3,
			CustomerStatus,
			SalesMode,
			PaymentType,
			CustomerPricingKey,
			TotalCreditLimit,
			TotalBalanceDue,
			IsTaxable,
			TaxID,
			HierarchyCode,
			TerritoryHierarchy,
			SurveyKey,
			DateofBirth,
			IDNumber,
			TINNumber 
	FROM Export_CS2WS_Customer WITH (NOLOCK)
	
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_Export_CS2WS_ProductGroup' AND xtype='P')  
DROP PROCEDURE Proc_Export_CS2WS_ProductGroup
GO
--exec Proc_Export_CS2WS_ProductGroup '1'  
CREATE PROCEDURE Proc_Export_CS2WS_ProductGroup  
(  
 @SalRpCode varchar(50)  
)  
AS  
/*******************************************************************************************  
* PROCEDURE  : Proc_Export_CS2WS_ProductGroup  
* PURPOSE  : To Export Scheme Header details to the PDA Intermediate Database  
* CREATED  : S.Moorthi  
* CREATED DATE : 10/08/2018  
* MODIFIED  :  
* DATE      AUTHOR     DESCRIPTION  
*****************************************************************************************************  
* DATE         AUTHOR       CR/BZ    USER STORY ID   DESCRIPTION                           
*****************************************************************************************************  
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product  
  30/10/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product  
********************************************************************************************/  
BEGIN  
 DELETE FROM Export_CS2WS_ProductGroup WHERE UploadFlag='Y'  
 DECLARE @DistCode AS NVARCHAR(100)  
 SELECT @DistCode=DistributorCode FROM Distributor (NOLOCK)  
   
		--EXEC [PROC_GR_BUILD_PH]  
   
		SELECT DISTINCT A.SchId,E.Prdid INTO #SchemeProducts FROM SchemeMaster A    
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid    
		INNER JOIN ProductCategoryValue C ON     
		B.PrdCtgValMainId = C.PrdCtgValMainId     
		INNER JOIN ProductCategoryValue D ON    
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'    
		INNER JOIN Product E On    
		D.PrdCtgValMainId = E.PrdCtgValMainId     
		WHERE A.Schid In (Select Distinct Schid From SchemeMaster WHERE  SchemeLvlMode=0)  
		AND CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1   
		AND SchType<>4  and A.schid not in (select schid from SchemeSlabFrePrds)  

		INSERT INTO Export_CS2WS_ProductGroup(TenantCode,PromotionCode,GroupType,ProductHierarchyCode,  
		ItemCode,UnitsOfMeasure,Quantity,UploadFlag)  
		SELECT DISTINCT  @DistCode,CmpSchCode,GroupType,'' ProductHierarchyCode,PrdCCode,  
		UomGroupDescription,0,'N' AS UploadFlag FROM    
		(SELECt S.SchID,CmpSchCode,'Q' AS GroupType,  
		P.PrdId,P.PrdCCode,PurQty,UG.UomId,UM.UomCode AS UomGroupDescription   
		FROM SchemeMaster S(NOLOCK) INNER JOIN SchemeSlabs SS(NOLOCK) ON S.SchId = SS.SchID   
		INNER JOIN SchemeProducts SP(NOLOCK) ON S.SchID = SP.SchID AND SS.SchId = SP.SchID   
		INNER JOIN Product P(NOLOCK) ON SP.PrdId = P.PrdID  
		INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND SP.PrdId=FP.PrdId   
		LEFT OUTER JOIN UOMGroup UG(NOLOCK) ON P.UomGroupId = UG.UomGroupId and UG.UomID =SS.UomID
		LEFT OUTER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId
		--INNER JOIN UOMGroup UG(NOLOCK) ON P.UomGroupId = UG.UomGroupId AND UG.BaseUom='Y'   
		--INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId   
		INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1   
		WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1 AND SchType<>4   
		and NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack WS(NOLOCK)   
		WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)  
		UNION ALL  
		SELECt S.SchID,CmpSchCode,'A' AS GroupType,  
		P.PrdId,P.PrdCCode,PurQty,UG.UomId,UM.UomCode AS UomGroupDescription   
		FROM SchemeMaster S (NOLOCK)INNER JOIN SchemeSlabs SS ON S.SchId = SS.SchID   
		INNER JOIN SchemeProducts SP(NOLOCK) ON S.SchID = SP.SchID AND SS.SchId = SP.SchID   
		INNER JOIN Product P (NOLOCK)ON SP.PrdId = P.PrdID  
		INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND SP.PrdId=FP.PrdId   
		LEFT OUTER JOIN UOMGroup UG(NOLOCK) ON P.UomGroupId = UG.UomGroupId and UG.UomID =SS.UomID
		--UG.UomID =CASE WHEN SS.UomID=0 THEN UG.UomID ELSE SS.UomID END AND
		--UG.BASEUOM=CASE WHEN SS.UomID=0 THEN 'Y' ELSE UG.BASEUOM END 
		LEFT OUTER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId   
		INNER JOIN TaxGroupSetting TG (NOLOCK)ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1   
		WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1   
		AND SchType<>4  and s.schid not in (select schid from SchemeSlabFrePrds)  
		and NOT EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK)   
		WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)  
		UNION ALL  
		SELECT DISTINCT S.SchID,CmpSchCode,'Q' AS GroupType,PR.PrdId,Pr.PrdCCode,PurQty,UG.UomId,UM.UomCode AS UomGroupDescription  
		FROM SchemeMaster S(NOLOCK) INNER JOIN SchemeSlabs SS (NOLOCK)ON S.SchId = SS.SchID   
		INNER JOIN #SchemeProducts SP(NOLOCK) ON S.SchID = SP.SchID AND SS.SchId = SP.SchID   
		INNER JOIN Product Pr(NOLOCK) ON Pr.PrdId = SP.PrdID  
		INNER JOIN Fn_SFAProductToSend() FP ON Pr.PrdId=FP.PrdId AND SP.PrdId=FP.PrdId   
		LEFT OUTER JOIN UOMGroup UG(NOLOCK) ON Pr.UomGroupId = UG.UomGroupId and UG.UomID =SS.UomID
		LEFT OUTER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId     
		--INNER JOIN UOMGroup UG(NOLOCK) ON PR.UomGroupId = UG.UomGroupId and UG.BaseUom='Y'  
		--INNER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId   
		INNER JOIN TaxGroupSetting TG ON Pr.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1   
		WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1 AND SchType<>4 --AND sf.Publish=1  
		and NOT EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK)   
		WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)  
		UNION ALL  
		SELECT DISTINCT S.SchID,CmpSchCode,'A' AS GroupType,PR.PrdId,Pr.PrdCCode,PurQty,UG.UomId,UM.UomCode AS UomGroupDescription   
		FROM SchemeMaster S(NOLOCK) INNER JOIN SchemeSlabs SS(NOLOCK) ON S.SchId = SS.SchID   
		INNER JOIN #SchemeProducts SP ON S.SchID = SP.SchID AND SS.SchId = SP.SchID   
		INNER JOIN Product Pr(NOLOCK) ON Pr.PrdId = SP.PrdID  
		INNER JOIN Fn_SFAProductToSend() FP ON Pr.PrdId=FP.PrdId AND SP.PrdId=FP.PrdId   
		LEFT OUTER JOIN UOMGroup UG(NOLOCK) ON Pr.UomGroupId = UG.UomGroupId and UG.UomID =SS.UomID
		--UG.UomID =CASE WHEN SS.UomID=0 THEN UG.UomID ELSE SS.UomID END AND
		--UG.BASEUOM=CASE WHEN SS.UomID=0 THEN 'Y' ELSE UG.BASEUOM END 
		LEFT OUTER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId     
		INNER JOIN TaxGroupSetting TG ON Pr.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1   
		WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1   
		AND SchType<>4  and s.schid not in (select schid from SchemeSlabFrePrds)  
		and NOT EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK)   
		WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)  
		UNION ALL   
		SELECT S.SchID,CmpSchCode,'A' AS GroupType,P.PrdId,P.PrdCCode,0,UG.UomId,UM.UomCode AS UomGroupDescription  
		FROM SchemeMaster S(NOLOCK)  
		INNER JOIN SchemeSlabs SS(NOLOCK) ON S.SchId = SS.SchID   
		INNER JOIN SchemeSlabFrePrds SP ON S.SchID = SP.SchID AND SS.SchId = SP.SchID AND SS.SlabId = SP.SlabId  
		INNER JOIN Product P(NOLOCK) ON SP.PrdId = P.PrdID   
		INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND SP.PrdId=fp.PrdId   
		LEFT OUTER JOIN UOMGroup UG(NOLOCK) ON P.UomGroupId = UG.UomGroupId and UG.UomID =SS.UomID
		--UG.UomID =CASE WHEN SS.UomID=0 THEN UG.UomID ELSE SS.UomID END AND
		--UG.BASEUOM=CASE WHEN SS.UomID=0 THEN 'Y' ELSE UG.BASEUOM END 
		LEFT OUTER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId     
		INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1   
		WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1 AND SchType<>4  
		and NOT EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK)   
		WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)  
		UNION ALL  
		SELECT S.SchID,CmpSchCode,'A' AS GroupType,P.PrdId,P.PrdCCode,0,UG.UomId,UM.UomCode AS UomGroupDescription  
		FROM SchemeMaster S(NOLOCK)  
		INNER JOIN SchemeSlabs SS(NOLOCK) ON S.SchId = SS.SchID   
		INNER JOIN SchemeSlabMultiFrePrds SP ON S.SchID = SP.SchID AND SS.SchId = SP.SchID AND SS.SlabId = SP.SlabId  
		INNER JOIN Product P(NOLOCK) ON SP.PrdId = P.PrdID   
		INNER JOIN Fn_SFAProductToSend() FP ON P.PrdId=FP.PrdId AND SP.PrdId=fp.PrdId   
		LEFT OUTER JOIN UOMGroup UG(NOLOCK) ON P.UomGroupId = UG.UomGroupId and UG.UomID =SS.UomID
		--UG.UomID =CASE WHEN SS.UomID=0 THEN UG.UomID ELSE SS.UomID END AND
		--UG.BASEUOM=CASE WHEN SS.UomID=0 THEN 'Y' ELSE UG.BASEUOM END 
		LEFT OUTER JOIN UomMaster UM (NOLOCK) ON UM.UomId=UG.UomId     
		INNER JOIN TaxGroupSetting TG ON P.TaxGroupId = TG.TaxGroupId AND PrdStatus = 1   
		WHERE CONVERT (Varchar(10),getdate(),121) between schvalidfrom and schvalidtill AND SchStatus = 1 AND SchType<>4  
		and NOT EXISTS(SELECT DISTINCT ProcessName,MasterCode FROM WSMasterExportUploadTrack WS(NOLOCK)   
		WHERE WS.ProcessName='Promotion Definition' AND WS.MasterCode=S.CmpSchCode)  
		) A  
 
		UPDATE A SET A.UnitsOfMeasure=UM.UOMCODE from Export_CS2WS_ProductGroup A (nolock) 
		INNER JOIN Product P (NOLOCK) ON P.PrdCCode=A.ItemCode 
		INNER JOIN UomGroup UG ON UG.UomGroupId=P.UomGroupId AND UG.BaseUom='Y'
		INNER JOIN UomMaster UM ON UM.UomId=UG.UomId 
		WHERE UnitsOfMeasure IS NULL
 
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Export_CS2WS_RouteTarget' AND Xtype ='P')
DROP Procedure Proc_Export_CS2WS_RouteTarget
GO
/*
begin tran
exec Proc_Export_CS2WS_RouteTarget ' 1, 2, 4'
select * from Export_CS2WS_RouteTarget
rollback tran
*/
CREATE PROCEDURE Proc_Export_CS2WS_RouteTarget
(
	@SalRpCode varchar(50)
)
AS
/****************************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_RouteTarget
* PURPOSE		: To Export Route Target details to the PDA Intermediate Database
* CREATED		: Amuthakumar P
* CREATED DATE	: 21/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR          CR/BZ    USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  21/08/2018   Amuthakumar P    CR      CRCRSTPAR0017   SFA-Upload-Download Integration --Route Target
  08/01/2019   Lakshman M       SR      ILCRSTPAR3071   SFA upload for targetmonth column balnk space removed. 
  11/01/2019   lakshman M       SR      ILCRSTPAR3112   Default route target data uploaded as per given salesman wise.
  28/01/2019   lakshman M       SR      ILCRSTPAR3240   Default route target data uploaded as 0 now we changed as per client request considered current month and year.
*****************************************************************************************************/
BEGIN
SET NOCOUNT ON
DECLARE @DistCode AS NVARCHAR(50)
DECLARE @CurrMonth INTEGER
DECLARE @CurrYear INTEGER
DECLARE @Smcode AS NVARCHAR(50)
		
SELECT @CurrMonth=MONTH(GETDATE())
SELECT @CurrYear=YEAR(GETDATE())
SELECT @DistCode = DistributorCode FROM Distributor (NOLOCK)
SELECT pListId Slno,pListValue Smid INTO #SMLIST1 from DBo.fn_getList(@SalRpCode)

Declare @smid as int

   IF @DistCode <> ''
    BEGIN
		DELETE A FROM Export_CS2WS_RouteTarget A (NOLOCK)
						
		SELECT Distinct TenantCode,LocationCode,SMID,RouteCode,SalesmanCode,TargetMonth,TargetYear,TargetName,[Target],
		0.00 as TillDateTarget,0.00 as TargetAchieved  INTO #TEMP1
		FROM
		(SELECT DISTINCT Distributorcode AS TenantCode,Distributorcode AS LocationCode,SM.SMID,SM.SMCode AS RouteCode,
		SM.SMCode AS SalesmanCode, TargetMonth,TargetYear,'SALES' AS TargetName,D.AvgSal,D.[Target],H.Insid
		FROM InsTargetHD H (NOLOCK) INNER JOIN InsTargetDetails D (NOLOCK) ON H.InsId = D.InsId
		INNER JOIN Retailer R ON D.RtrId = R.RtrId
		INNER JOIN RetailerMarket RMM ON RMM.RtrId =R.RTRID
		INNER JOIN RouteMaster RM ON RMM.RMId=RM.RMID
		INNER JOIN SalesmanMarket SMM ON SMM.RMId=RMM.RMID
		INNER JOIN Salesman SM ON SMM.SMId=SM.SMID
		CROSS JOIN Distributor 
		WHERE H.EffFromMonthId = @CurrMonth and H.TargetYear=@CurrYear AND H.Status =1
		) A
		
		INSERT INTO Export_CS2WS_RouteTarget(TenantCode,LocationCode,RouteCode,SalesmanCode,TargetMonth,TargetName,
		MonthTarget,TillDateTarget,TargetAchieved,Threshold1,UploadFlag) 
		SELECT TenantCode,LocationCode,RouteCode,SalesmanCode,(Rtrim(ltrim(CAST(TargetMonth AS CHAR(2))))+'/'+CAST(TargetYear AS CHAR(4))) ,
		TargetName,ISNULL(SUM([Target]),0),
		0.00 as TillDateTarget,0.00 as TargetAchieved,0 AS Threshold1,'N' As UploadFlag 
		FROM #TEMP1 A INNER JOIN #SMLIST1 B ON A.SMID = B.Smid 
		GROUP BY TenantCode,LocationCode,RouteCode,SalesmanCode,TargetMonth,TargetYear,TargetName
		
		UPDATE Export_CS2WS_RouteTarget SET Threshold1 = 100
				
	END
	---------- Added By Lakshman M Dated ON 11/01/2019 PMS ID: ILCRSTPAR3112   ----------
			IF NOT EXISTS (SELECT * FROM Export_CS2WS_RouteTarget)
			BEGIN
				DECLARE Cur_salesman cursor
				for SELECT distinct A.Smid,smcode FROM #SMLIST1 A inner join salesman B On A.smid =b.smid 
				open Cur_salesman 
				fetch next FROM Cur_salesman INTO @smid,@smcode
				while @@FETCH_STATUS = 0
				BEGIN	
					
					INSERT INTO Export_CS2WS_RouteTarget
					SELECT @DistCode,@DistCode,@Smcode AS RouteCode,@Smcode AS Salsemancode,(Rtrim(ltrim(CAST(month(getdate()) AS CHAR(2))))+'/'+CAST(year(getdate()) AS CHAR(4))),'SALES',0.00,0.00,0.00,0,'N'  --- Added by lakshman M Dated On "28012019" PMS ID: ILCRSTPAR3240 

				FETCH NEXT FROM Cur_salesman INTO  @smid,@smcode
				END
				CLOSE  Cur_salesman
				DEALLOCATE  Cur_salesman
			END
	--------------- Till Here --------------------
		
	SELECT   Distinct
				TenantCode		,
				LocationCode	,
				RouteCode		,
				SalesmanCode	,
				TargetMonth		,
				TargetName		,
				MonthTarget		, 
				TillDateTarget	,
				TargetAchieved	,
				Threshold1		
	FROM Export_CS2WS_RouteTarget WITH (NOLOCK) 
END
GO
IF EXISTS(SELECT *FROM SYSOBJECTS WHERE name ='Fn_ReturnManualClmDesc' and xtype ='TF')
DROP Function dbo.Fn_ReturnManualClmDesc
GO
-- select * from manualclaimdescription  
--SELECT * FROM Fn_ReturnManualClmDesc('2018-09-01','2018-09-30','2018-09-03')  
CREATE FUNCTION Fn_ReturnManualClmDesc(@FromDate AS DATETIME,@ToDate AS DATETIME,@ClmDate AS DATETIME)  
RETURNS @ReturnManualDesc TABLE  
(  
 RefId  INT,  
 ManualClmDesc VARCHAR(200)  
   
)   
AS  
/************************************************************************************************************************************  
* PROCEDURE  : Fn_ReturnManualClmDesc  
* PURPOSE  : To Validate the description in Manual Claim   
* CREATED BY : S.MOORTHI  
* CREATED DATE : 22/06/2018  
* MODIFIED  
* DATE        AUTHOR   CR/BZ USER STORY ID  DESCRIPTION           
-----------------------------------------------------------------------------------------------------------------------------------------        
 22/06/2018  S.Moorthi   CR  CRCRSTPAR0014       Load description master in description and attachment option in Manual Claim  
 03/10/2018  Amuthakumar P  CR  CRCRSTPAR0029       Manual claim description with the status of activation   
 ***************************************************************************************************************************************/   
BEGIN  
DECLARE @TempData AS TABLE  
(  
 RefID    INT,  
 ManualClmDesc  VARCHAR(500),  
 EffectiveFromDate DATETIME  
)  
 INSERT INTO @TempData (RefID,ManualClmDesc,EffectiveFromDate)  
 SELECT RefID,ManualClmDesc, EffectiveFromDate fROM ManualClaimDescription WHERE EffectiveFromDate<=@ClmDate AND ActiveStatus=0  
   
   
 INSERT INTO @ReturnManualDesc(RefId,ManualClmDesc)  
 SELECT DISTINCT RefId,ManualClmDesc FROM ManualClaimDescription N(NOLOCK)   
 WHERE @FromDate BETWEEN ValidFromDate and ValidToDate OR @ToDate BETWEEN ValidFromDate and ValidToDate  
 or ValidFromDate BETWEEN @FromDate and @ToDate or ValidToDate BETWEEN @FromDate and @ToDate  
 AND NOT EXISTS(SELECT * FROM @TempData M WHERE M.RefID=N.RefID)  
    
 --SELECT DISTINCT RefId,ManualClmDesc FROM ManualClaimDescription(NOLOCK)   
 --WHERE (@FromDate BETWEEN ValidFromDate and EffectiveFromDate OR @ToDate BETWEEN ValidFromDate and EffectiveFromDate  
 --OR ValidFromDate BETWEEN @FromDate and @ToDate or EffectiveFromDate BETWEEN @FromDate and @ToDate)  
 -- added by Amuthakumar CRCRSTPAR0029  
RETURN  
END
GO
IF NOT EXISTS(SELECT * FROM sysobjects WHERE Name = 'CS2CN_RetailerReupload_New' And xtype = 'U' )  
CREATE TABLE CS2CN_RetailerReupload_New (
	[SlNo] int identity (1,1),
	[DistCode] [nvarchar](100) NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) NULL,
	[RtrName] [nvarchar](100) NULL,
	[CmpRtrCode] [nvarchar](100) NULL,
	[RtrCategoryCode] [nvarchar](100) NULL,
	[ClassCode] [nvarchar](100) NULL,
	[KeyAccount] [nvarchar](100) NULL,
	[RtrRegDate] [datetime] NULL,
	[RelationStatus] [nvarchar](100) NULL,
	[ParentCode] [nvarchar](100) NULL,
	[GeoLevel] [nvarchar](100) NULL,
	[GeoLevelValue] [nvarchar](100) NULL,
	[Status] [int] NULL,
	[Mode] [nvarchar](100) NULL,
	[RtrAddress1] [nvarchar](100) NULL,
	[RtrAddress2] [nvarchar](100) NULL,
	[RtrAddress3] [nvarchar](100) NULL,
	[RtrPINCode] [nvarchar](20) NULL,
	[VillageId] [int] NULL,
	[VillageCode] [nvarchar](100) NULL,
	[VillageName] [nvarchar](100) NULL,	
	[DrugLNo] [nvarchar](50) NULL,
	[RtrFrequency] [nvarchar](100) NULL,
	[RtrPhoneNo] [nvarchar](50) NULL,
	[RtrTINNumber] [nvarchar](50) NULL,
	[Approved] [nvarchar](100) NULL,	
	[ApprovalRemarks] [nvarchar](400) NULL,
	[UniqueRtrCode] [varchar](50) NULL,
	[RtrType] [varchar](100) NULL,
	[RtrTaxGroupCode] [nvarchar](400) NULL,
	[RtrCrLimit] [numeric](18, 2) NULL,
	[RtrCrDays] [int] NULL,
	[StateName] [nvarchar](100) NULL,
	[GSTTIN] [nvarchar](100) NULL,
	[PanNumber] [nvarchar](100) NULL,
	[RetailerType] [nvarchar](100) NULL,
	[Composite] [nvarchar](100) NULL,
	[RelatedParty] [nvarchar](100) NULL,
	[UploadFlag] [nvarchar](5) NULL,
	[SyncId] [numeric](18, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Cs2Cn_Prk_DistributorCodeSwapConfirm_Track' AND Xtype ='U')
CREATE TABLE [dbo].[Cs2Cn_Prk_DistributorCodeSwapConfirm_Track]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[NewDistcode] [varchar](50) NULL,
	[OldDistcode] [varchar](50) NULL,
	[UploadFlag] [nvarchar](10) NULL,
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Cs2Cn_DistributorCodeSwapConfirm')
DROP Procedure Proc_Cs2Cn_DistributorCodeSwapConfirm
GO
/*
begin tran
EXEC Proc_Cs2Cn_GSTInvoiceNumberCorrection 0,'2017-07-01'
select * from Cs2Cn_Prk_DistributorCodeSwapConfirm
select * from Cs2Cn_Prk_DistributorCodeSwapConfirm_track
rollback tran
*/
CREATE PROCEDURE Proc_Cs2Cn_DistributorCodeSwapConfirm
(  
   @Po_ErrNo INT OUTPUT,  
   @ServerDate DATETIME  
)  
AS  
/*****************************************************************************  
* PROCEDURE  : Proc_Cs2Cn_DistributorCodeSwapConfirm  
* PURPOSE  : To upload distributor swaping details  
* CREATED BY : Murugan.R  
* CREATED DATE : 22/12/2017  
* NOTE   :  
* MODIFIED  
* DATE   AUTHOR     CR/BUG   USER STORY ID DESCRIPTION  
------------------------------------------------  
* {date}  {developer}         {brief modification description}  
* 22/12/2017 Murugan.R CR    CCRSTPAR0173      
* DATE       AUTHOR			CR/BZ	USER STORY ID           DESCRIPTION                         
**************************************************************************************
25-01-2019  lakshman M		BZ		ILCRSTPAR3226          Reported issue due to Distributor Swapping Process are uploading in every sync . Hence it is getting uploaded to console.

********************************************************************************/  
SET NOCOUNT ON  
BEGIN   
 SET @Po_ErrNo=0  
 DECLARE @DistCode As nVarchar(50)  
 ---------- Added By lakhman M Dated ON 25/012019 PMS ID: ILCRSTPAR3226 --------------
 INSERT INTO Cs2Cn_Prk_DistributorCodeSwapConfirm_Track 
(DistCode,NewDistcode,OldDistcode,UploadFlag,Syncid,ServerDate)
 SELECT [DistCode],NewDistcode,OldDistcode,UploadFlag ,SyncId ,ServerDate 
 FROM Cs2Cn_Prk_DistributorCodeSwapConfirm
	 
 DELETE FROM Cs2Cn_Prk_DistributorCodeSwapConfirm WHERE UploadFlag = 'Y'  
 SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)  
 	 
 IF NOT EXISTS(SELECT *FROM Cs2Cn_Prk_DistributorCodeSwapConfirm_Track where DistCode =@DistCode)
 BEGIN
	 INSERT INTO Cs2Cn_Prk_DistributorCodeSwapConfirm  
	 ([DistCode],NewDistcode,OldDistcode,[UploadFlag],ServerDate)  
	 SELECT @DistCode,DistributorCode,ActualDistributorCode,'N',@ServerDate  
	 FROM Distributor (NOLOCK) WHERE DistributorCode<>ActualDistributorCode   
	 AND DistributorCode NOT IN(Select DistCode from Cs2Cn_Prk_DistributorCodeSwapConfirm_Track)
 END
	------------------ Till Here ---------------
END
GO
IF EXISTS (SELECT * FROM sys.objects WHERE Name = 'Proc_ProductWiseSalesOnlyParle' AND type in ('P'))
DROP PROCEDURE Proc_ProductWiseSalesOnlyParle
GO
--EXEC Proc_ProductWiseSalesOnlyParle 238,1 --select * from RptProductWise  
--SELECT * FROM RptProductWise (NOLOCK)  
CREATE PROCEDURE Proc_ProductWiseSalesOnlyParle
(  
@Pi_RptId   INT,  
@Pi_UsrId   INT  
)  
/************************************************************  
* PROC   : Proc_ProductWiseSalesOnly  
* PURPOSE  : To get the Product details  
* CREATED BY : MarySubashini.S  
* CREATED DATE : 18/02/2010  
* NOTE   :  
* MODIFIED  :  
* DATE        AUTHOR   DESCRIPTION  
14-09-2009   Mahalakshmi.A     BugFixing for BugNo : 20625  
------------------------------------------------  
* {date}      {developer}             {brief modification description}  
  2014/01/02  Sathishkumar Veeramani  Script Optimization   
  * DATE       AUTHOR     CR/BZ	USER STORY ID           DESCRIPTION                         
***************************************************************************************************
31-01-2019  lakshman M   BZ     ILCRSTPAR3247         Sales Product batch and pice id validation icluded from core stocky.
***************************************************************************************************/
AS  
BEGIN  
 DECLARE @FromDate AS DATETIME  
 DECLARE @ToDate   AS DATETIME  
 SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
 SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
 DELETE FROM RptProductWise WHERE RptId= @Pi_RptId And UsrId IN(0,@Pi_UsrId)  
   
 --Added by Sathishkumar Veeramani 2014/01/02  
 --Product Batch Details  
  
  
 --SELECT DISTINCT A.PrdId,CmpId,A.PrdCtgValMainId,CmpPrdCtgId,PrdDCode,PrdName,B.PrdBatId,PrdBatCode,PBD1.PrdBatDetailValue AS PrdUnitMRP,  
 --PBD2.PrdBatDetailValue AS PrdUnitSelRate,PrdWgt, INTO #LoadProductBatchDetails   
 --FROM Product A WITH(NOLOCK)  
 --INNER JOIN ProductCategoryValue PC WITH(NOLOCK) ON A.PrdCtgValMainId = PC.PrdCtgValMainId   
 --INNER JOIN ProductBatch B WITH(NOLOCK) ON A.PrdId = B.PrdId  
 --INNER JOIN ProductBatchDetails PBD1 WITH(NOLOCK) ON B.PrdBatId = PBD1.PrdBatId --AND PBD1.DefaultPrice = 1  
 --INNER JOIN BatchCreation BC1 WITH(NOLOCK) ON B.BatchSeqId = BC1.BatchSeqId AND PBD1.SLNo = BC1.SlNo AND BC1.MRP = 1  
 --INNER JOIN ProductBatchDetails PBD2 WITH(NOLOCK) ON B.PrdBatId = PBD2.PrdBatId --AND PBD2.DefaultPrice = 1  
 --INNER JOIN BatchCreation BC2 WITH(NOLOCK) ON B.BatchSeqId = BC2.BatchSeqId AND PBD2.SLNo = BC2.SlNo AND BC2.SelRte = 1
 
  
  
SELECT DISTINCT A.PrdId,CmpId,A.PrdCtgValMainId,CmpPrdCtgId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,SUM(PrdUnitMRP) PrdUnitMRP,  
SUM(PrdUnitSelRate) PrdUnitSelRate,PrdWgt,PriceId 
 INTO #LoadProductBatchDetails  
 FROM(
 SELECT  DISTINCT A.PrdId,CmpId,A.PrdCtgValMainId,CmpPrdCtgId,PrdDCode,PrdName,B.PrdBatId,PrdBatCode,PBD1.PrdBatDetailValue AS PrdUnitMRP,  
 0 AS PrdUnitSelRate,PrdWgt,PBD1.PriceId  FROM Product A WITH(NOLOCK)  
 INNER JOIN ProductCategoryValue PC WITH(NOLOCK) ON A.PrdCtgValMainId = PC.PrdCtgValMainId   
 INNER JOIN ProductBatch B WITH(NOLOCK) ON A.PrdId = B.PrdId  
 INNER JOIN ProductBatchDetails PBD1 WITH(NOLOCK) ON B.PrdBatId = PBD1.PrdBatId --AND PBD1.DefaultPrice = 1  
 INNER JOIN BatchCreation BC1 WITH(NOLOCK) ON B.BatchSeqId = BC1.BatchSeqId AND PBD1.SLNo = BC1.SlNo AND BC1.MRP = 1  
 UNION ALL
SELECT  DISTINCT A.PrdId,CmpId,A.PrdCtgValMainId,CmpPrdCtgId,PrdDCode,PrdName,B.PrdBatId,PrdBatCode,0 AS PrdUnitMRP,  
 PBD1.PrdBatDetailValue AS PrdUnitSelRate,PrdWgt,PBD1.PriceId  FROM Product A WITH(NOLOCK)  
INNER JOIN ProductCategoryValue PC WITH(NOLOCK) ON A.PrdCtgValMainId = PC.PrdCtgValMainId   
INNER JOIN ProductBatch B WITH(NOLOCK) ON A.PrdId = B.PrdId  
INNER JOIN ProductBatchDetails PBD1 WITH(NOLOCK) ON B.PrdBatId = PBD1.PrdBatId --AND PBD1.DefaultPrice = 1  
INNER JOIN BatchCreation BC1 WITH(NOLOCK) ON B.BatchSeqId = BC1.BatchSeqId AND PBD1.SLNo = BC1.SlNo AND BC1.SelRte = 1 
)A group by A.PrdId,CmpId,A.PrdCtgValMainId,CmpPrdCtgId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,PrdWgt,PriceId 
   
 INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,  
 CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,  
 FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,  
  SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)  
  SELECT DISTINCT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,A.CmpId,SI.LcnId,PrdCtgValMainId,CmpPrdCtgId,  
  SIP.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,  
  SIP.SalManFreeQty AS FreeQty,0 AS RepQty,0 AS ReturnQty,SIP.BaseQty AS SalesQty,SIP.PrdGrossAmount,SIP.PrdTaxAmount,0 AS ReturnGrossValue,DlvSts--@  
   ,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,PrdNetAmount,((PrdWgt*SIP.BaseQty)/1000),((PrdWgt*SIP.SalManFreeQty)/1000),0,0,  
  ISNULL(SUM(SIP.SplDiscAmount + SIP.PrdSplDiscAmount+SIP.PrdSchDiscAmount+SIP.PrdDBDiscAmount+SIP.PrdCDAmount),0) As Schemevalue  
  FROM SalesInvoice SI WITH (NOLOCK) INNER JOIN SalesInvoiceProduct SIP WITH (NOLOCK) ON SI.SalId = SIP.SalId  
  INNER JOIN #LoadProductBatchDetails A WITH(NOLOCK) ON SIP.PrdId = A.PrdId AND SIP.PrdBatId = A.PrdBatId
  AND SIP.PriceId =A. PriceId 
  --Product P WITH (NOLOCK),  
  --ProductBatch PB WITH (NOLOCK),  
  --ProductCategoryValue PC WITH (NOLOCK),  
  --BatchCreation BC WITH (NOLOCK),  
  --BatchCreation BCS WITH (NOLOCK),  
  --ProductBatchDetails PBD WITH (NOLOCK),  
  --ProductBatchDetails PSD WITH (NOLOCK)  
  --WHERE SIP.SalId=SI.SalId AND P.PrdId=SIP.PrdId   
  --AND PB.PrdId=P.PrdId  
  --AND PB.PrdBatId=SIP.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId  
  --AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo  
  --AND BC.BatchSeqId=PB.BatchSeqId  AND BC.SelRte=1  
  --AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo  
  --AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1  
  --AND PBD.DefaultPrice=1  
  --AND PSD.DefaultPrice=1  
  AND SI.SalInvDate BETWEEN @FromDate AND @ToDate  
  GROUP BY SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,A.CmpId,SI.LcnId,PrdCtgValMainId,CmpPrdCtgId,  
  SIP.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,SIP.SalManFreeQty,   
  SIP.BaseQty,SIP.PrdGrossAmount,SIP.PrdTaxAmount,Dlvsts,SIP.BaseQty,PrdWgt,SIP.SalManFreeQty,PrdNetAmount  
    
    
 INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,  
 CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,  
 FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,  
  SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)  
  SELECT DISTINCT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,A.CmpId,SI.LcnId,PrdCtgValMainId,CmpPrdCtgId,  
  A.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,SSF.FreeQty AS FreeQty,0 AS RepQty,  
  0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossAmount,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts---@  
  ,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,((PrdWgt*SSF.FreeQty)/1000),0,0,  
  0 As Schemevalue  
  FROM SalesInvoice SI WITH (NOLOCK) INNER JOIN SalesInvoiceSchemeDtFreePrd SSF WITH (NOLOCK) ON SI.SalId = SSF.SalId  
  INNER JOIN #LoadProductBatchDetails A WITH(NOLOCK) ON SSF.FreePrdId = A.PrdId AND SSF.FreePrdBatId = A.PrdBatId    
  AND A.priceid = ssf.FreePriceId
  --Product P WITH (NOLOCK),  
  --ProductBatch PB WITH (NOLOCK),  
  --ProductCategoryValue PC WITH (NOLOCK),  
  --BatchCreation BC WITH (NOLOCK),  
  --BatchCreation BCS WITH (NOLOCK),  
  --ProductBatchDetails PBD WITH (NOLOCK),  
  --ProductBatchDetails PSD WITH (NOLOCK)  
  --WHERE SSF.SalId=SI.SalId AND P.PrdId=SSF.FreePrdId  
  --AND PB.PrdId=P.PrdId  
  --AND PB.PrdBatId=SSF.FreePrdBatId  
  --AND P.PrdCtgValMainId=PC.PrdCtgValMainId  
  --AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo  
  --AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1  
  --AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo  
  --AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1  
  --AND PBD.DefaultPrice=1  
  --AND PSD.DefaultPrice=1  
  AND SI.SalInvDate BETWEEN @FromDate AND @ToDate  
    
 INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,  
 CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,  
 FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,  
  SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)  
  SELECT DISTINCT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,A.CmpId,SI.LcnId,PrdCtgValMainId,CmpPrdCtgId,  
  A.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,SSF.GiftQty AS FreeQty,0 AS RepQty,  
  0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossAmount,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@  
  ,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,((PrdWgt*SSF.GiftQty)/1000),0,0,0  
  FROM SalesInvoice SI WITH (NOLOCK) INNER JOIN SalesInvoiceSchemeDtFreePrd SSF WITH (NOLOCK) ON SI.SalId = SSF.SalId  
  INNER JOIN #LoadProductBatchDetails A WITH(NOLOCK) ON SSF.GiftPrdId = A.PrdId AND SSF.GiftPrdBatId = A.PrdBatId    
  --Product P WITH (NOLOCK),  
  --ProductBatch PB WITH (NOLOCK),  
  --ProductCategoryValue PC WITH (NOLOCK),  
  --BatchCreation BC WITH (NOLOCK),  
  --BatchCreation BCS WITH (NOLOCK),  
  --ProductBatchDetails PBD WITH (NOLOCK),  
  --ProductBatchDetails PSD WITH (NOLOCK)  
  --WHERE SSF.SalId=SI.SalId  AND P.PrdId=SSF.GiftPrdId AND PB.PrdId=P.PrdId  
  --AND PB.PrdBatId=SSF.GiftPrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId  
  --AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo  
  --AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1  
  --AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo  
  --AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1  
  --AND PBD.DefaultPrice=1  
  --AND PSD.DefaultPrice=1  
  AND SI.SalInvDate BETWEEN @FromDate AND @ToDate  
 --Replacement Quantity  
 INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,  
 CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,  
 FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,  
  SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)  
  SELECT DISTINCT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,  
  A.CmpId,SI.LcnId,PrdCtgValMainId,CmpPrdCtgId,A.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,  
  0 AS FreeQty,REO.RepQty,0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@  
  ,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,((PrdWgt*REO.RepQty)/1000),0,0  
  FROM SalesInvoice SI WITH (NOLOCK) INNER JOIN ReplacementHd RE WITH (NOLOCK) ON SI.SalId = RE.SalId    
  INNER JOIN ReplacementOut REO WITH (NOLOCK) ON RE.RepRefNo = REO.RepRefNo    
  INNER JOIN #LoadProductBatchDetails A WITH(NOLOCK) ON REO.PrdId = A.PrdId AND REO.PrdBatId = A.PrdBatId    
  WHERE REO.CNRRefNo <>'RetReplacement'  
  --Product P WITH (NOLOCK),  
  --ProductBatch PB WITH (NOLOCK),  
  --ProductCategoryValue PC WITH (NOLOCK),  
  --BatchCreation BC WITH (NOLOCK),  
  --BatchCreation BCS WITH (NOLOCK),  
  --ProductBatchDetails PBD WITH (NOLOCK),  
  --ProductBatchDetails PSD WITH (NOLOCK)  
  --WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId  
  --AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId  
  --AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo <>'RetReplacement'  
  --AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo  
  --AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1  
  --AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo  
  --AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1  
  --AND PBD.DefaultPrice=1  
  --AND PSD.DefaultPrice=1  
  AND SI.SalInvDate BETWEEN @FromDate AND @ToDate  
 --Replacement Quantity  
 INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,  
 CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,  
 FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,  
  SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)  
  SELECT DISTINCT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,A.CmpId,SI.LcnId,PrdCtgValMainId,CmpPrdCtgId,  
  A.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,0 AS FreeQty,  
  0 AS RepQty,REO.RtnQty,0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,REO.RtnAmount AS ReturnGrossValue,SI.DlvSts--@  
  ,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,0,((PrdWgt*REO.RtnQty)/1000),0  
  FROM SalesInvoice SI WITH (NOLOCK) INNER JOIN ReplacementHd RE WITH (NOLOCK) ON SI.SalId = RE.SalId   
  INNER JOIN ReplacementIn REO WITH (NOLOCK) ON RE.RepRefNo = REO.RepRefNo    
  INNER JOIN #LoadProductBatchDetails A WITH(NOLOCK) ON REO.PrdId = A.PrdId AND REO.PrdBatId = A.PrdBatId    
  WHERE REO.CNRRefNo ='RetReplacement'  
  --Product P WITH (NOLOCK),  
  --ProductBatch PB WITH (NOLOCK),  
  --ProductCategoryValue PC WITH (NOLOCK),  
  --BatchCreation BC WITH (NOLOCK),  
  --BatchCreation BCS WITH (NOLOCK),  
  --ProductBatchDetails PBD WITH (NOLOCK),  
  --ProductBatchDetails PSD WITH (NOLOCK)  
  --WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId  
  --AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId  
  --AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo ='RetReplacement'  
  --AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo  
  --AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1  
  --AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo  
  --AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1  
  --AND PBD.DefaultPrice=1  
  --AND PSD.DefaultPrice=1  
  AND SI.SalInvDate BETWEEN @FromDate AND @ToDate  
 INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,  
 CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,  
 FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,  
  SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)  
  SELECT DISTINCT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,  
  A.CmpId,SI.LcnId,PrdCtgValMainId,CmpPrdCtgId,A.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,0 AS FreeQty,  
  REO.RepQty,0 AS ReturnQty,0 AS SalesQty,REO.RepAmount AS SalesGrossValue,REO.Tax AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@  
  ,@Pi_RptId AS RptID ,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,((PrdWgt*REO.RepQty)/1000),0,0  
  FROM SalesInvoice SI WITH (NOLOCK) INNER JOIN ReplacementHd RE WITH (NOLOCK) ON SI.SalId = RE.SalId  
  INNER JOIN ReplacementOut REO WITH (NOLOCK) ON RE.RepRefNo = REO.RepRefNo    
  INNER JOIN #LoadProductBatchDetails A WITH(NOLOCK) ON REO.PrdId = A.PrdId AND REO.PrdBatId = A.PrdBatId    
  WHERE REO.CNRRefNo ='RetReplacement'  
  --Product P WITH (NOLOCK),  
  --ProductBatch PB WITH (NOLOCK),  
  --ProductCategoryValue PC WITH (NOLOCK),  
  --BatchCreation BC WITH (NOLOCK),  
  --BatchCreation BCS WITH (NOLOCK),  
  --ProductBatchDetails PBD WITH (NOLOCK),  
  --ProductBatchDetails PSD WITH (NOLOCK)  
  --WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId  
  --AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId  
  --AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo ='RetReplacement'  
  --AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo  
  --AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1  
  --AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo  
  --AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1  
  --AND PBD.DefaultPrice=1  
  --AND PSD.DefaultPrice=1  
  AND SI.SalInvDate BETWEEN @FromDate AND @ToDate  
 --Return Quantity  
 INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,  
 CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,  
 FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,  
  SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SchemeValue)  
  SELECT DISTINCT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,A.CmpId,SI.LcnId,PrdCtgValMainId,CmpPrdCtgId,  
  A.PrdId,PrdDCode,PrdName,A.PrdBatId,PrdBatCode,A.PrdUnitMRP,A.PrdUnitSelRate,0 AS FreeQty,0 AS RepQty,RP.BaseQty AS ReturnQty,  
  0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,RP.PrdGrossAmt,SI.DlvSts--@  
  ,@Pi_RptId AS RptId,@Pi_UsrId AS UsrId,-1*PrdNetAmt,0,0,0,((PrdWgt*RP.BaseQty)/1000),0  
  FROM SalesInvoice SI WITH (NOLOCK) INNER JOIN ReturnHeader RH WITH (NOLOCK) ON SI.SalId = RH.SalId  
  INNER JOIN ReturnProduct RP WITH (NOLOCK) ON RH.ReturnId = RP.ReturnId 
  INNER JOIN #LoadProductBatchDetails A WITH(NOLOCK) ON RP.PrdId = A.PrdId AND RP.PrdBatId = A.PrdBatId AND RP.Priceid =A.Priceid  
  --Product P WITH (NOLOCK),  
  --ProductBatch PB WITH (NOLOCK),  
  --ProductCategoryValue PC WITH (NOLOCK),  
  --BatchCreation BC WITH (NOLOCK),  
  --BatchCreation BCS WITH (NOLOCK),  
  --ProductBatchDetails PBD WITH (NOLOCK),  
  --ProductBatchDetails PSD WITH (NOLOCK),    
  --WHERE SI.SalId=RH.SalId  AND RH.ReturnId=RP.ReturnId AND P.PrdId=RP.PrdId  
  --AND PB.PrdId=P.PrdId AND PB.PrdBatId=RP.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId  
  --AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo  
  --AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1  
  --AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo  
  --AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1 AND PBD.DefaultPrice=1 AND PSD.DefaultPrice=1  
  AND SI.SalInvDate BETWEEN @FromDate AND @ToDate  
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Cn2Cs_Product' AND XTYPE ='P')
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
*************************************************************************************************************************************
* DATE       AUTHOR			CR/BZ	USER STORY ID           DESCRIPTION                         
*************************************************************************************************************************************
18-01-2019  lakshman M      BZ      ILCRSTPAR3134          while downloading data date Latest Product created date  only considered in core stocky.  
************************************************************************************************************************************/    
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
 C.PrdCCode,C.GroupCode,''SpmCode,0,1,'',C.PrdWgt,ISNULL(C.ProductUnit,'Unit'),C.UOMGroupCode,  
 C.ProductType,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121),0,C.ProductStatus,  
 C.[EANCode],C.Vending
 FROM Cn2Cs_Prk_Product C  where createddate IN(select distinct MAX(createddate) FROM Cn2Cs_Prk_Product GROUP BY prdccode) --- Added by Lakshman M  Dated ON 18/01/2019 PMS ID: ILCRSTPAR3134

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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Export_CS2WS_RouteSetupV1' AND XTYPE='P')
DROP PROC Proc_Export_CS2WS_RouteSetupV1
GO
CREATE PROCEDURE Proc_Export_CS2WS_RouteSetupV1
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_RouteSetupV1
* PURPOSE		: To Export RouteSetupV1 details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 16/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
  12/02/2018   Gayathri.S	BZ		   ILCRSTPAR3422   To consider Distcode+Salesmancode value if Deviceserialnumber is not available.		
********************************************************************************************/
BEGIN

	SELECT pListId Slno,pListValue Smid INTO #SMLIST1 from DBo.fn_getList(@SalRpCode)

	DECLARE @DistCode AS varchar(200)
	DELETE FROM Export_CS2WS_RouteSetupV1 WHERE UploadFlag='Y'
	SELECT @DistCode=DistributorCode FROM Distributor (NOLOCK)
	
	INSERT INTO Export_CS2WS_RouteSetupV1(TenantCode,LocationCode,RouteCode,RouteName,
	VehicleCode,HHTDeviceSerialNumber,SalesmanCode,IsActive,WarehouseCode,JourneyPlanCode,
	AuthorizedItemCode,RouteType,DefaultCashCustomer,UploadFlag)
	SELECT @DistCode,@DistCode,SMCode,SMName,SMCode VehicleCode,
	HHTDeviceSerialNumber HHTDeviceSerialNumber,SMCode,A.[Status],'MG',SMCode,@DistCode,4,'Dummy','N' 
	FROM SalesMan A (NOLOCK)
	INNER JOIN #SMLIST1 B ON A.SMId=B.Smid  
	WHERE NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = A.SMCode AND Reference1=A.HHTDeviceSerialNumber
	AND A.Status=M.Status AND M.ProcessName='RouteDivisionsList') 
	--INNER JOIN SalesmanMarket B (NOLOCK) ON A.SMId=B.SMId 
	--INNER JOIN RouteMaster RM (NOLOCK) ON RM.RMId=B.RMId
	
	DELETE A FROM WSMasterExportUploadTrack A WHERE EXISTS(SELECT * FROM Export_CS2WS_RouteSetupV1 M 
	WHERE A.MasterCode = M.SalesmanCode and M.UploadFlag='N') AND A.ProcessName='RouteDivisionsList'

	EXEC Proc_Export_CS2WS_RouteDivisionsList @SalRpCode
	
	INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
	SELECT 'RouteDivisionsList',RouteCode,LocationCode,GETDATE(),A.IsActive,HHTDeviceSerialNumber,'','',0 FROM Export_CS2WS_RouteSetupV1 A 
	WHERE UploadFlag='N'  
	
	/* Commented and Added for ILCRSTPAR3422 */
	--UPDATE Export_CS2WS_RouteSetupV1 SET HHTDeviceSerialNumber='12345' WHERE ISNULL(HHTDeviceSerialNumber,'')=''
	UPDATE Export_CS2WS_RouteSetupV1 SET HHTDeviceSerialNumber= REPLACE(TenantCode + SalesmanCode,'-','') WHERE ISNULL(HHTDeviceSerialNumber,'')=''
	/* Till Here for ILCRSTPAR3422 */

	SELECT DISTINCT TenantCode,
		LocationCode,
		RouteCode,
		RouteName,
		VehicleCode,
		HHTDeviceSerialNumber,
		SalesmanCode,
		IsActive,
		WarehouseCode,
		JourneyPlanCode,
		AuthorizedItemCode,
		RouteType,
		DefaultCashCustomer
		FROM Export_CS2WS_RouteSetupV1 (NOLOCK)
		
	SELECT DISTINCT TenantCode,
		LocationCode,
		RouteCode,
		Divisioncode
		FROM Export_CS2WS_RouteDivisionsList (NOLOCK)

END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE  Name ='Proc_Cn2Cs_PurchaseReceipt' AND Xtype ='P')
DROP PROCEDURE Proc_Cn2Cs_PurchaseReceipt
GO
/*    
BEGIN TRANSACTION    
EXEC Proc_Cn2Cs_PurchaseReceipt 0 
select *from ETLTempPurchaseReceipt --WHERE DownLoadStatus=0
select *from etltemppurchasereceiptproduct where cmpinvno in(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=0)
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
* DATE       AUTHOR     CR/BZ	USER STORY ID           DESCRIPTION                         
***************************************************************************************************
29-09-2018  Lakshman M	 SR     ILCRSTPAR2251         Purchase backup date validation included from CS As per request 5 days configuration .
04-10-2018  lakshman M   BZ     ILCRSTPAR2285         purchase downloaded status validation added from CS.
28-01-2019  Lakshman M	 SR     ILCRSTPAR3256         Purchase backup date validation increased from CS As per request 10 days configuration .
05-03-2019  Lakshman M	 SR     ILCRSTPAR3638         Purchase backup date validation decreased from CS As per request 7 days only configuration.
***************************************************************************************************/  
SET NOCOUNT ON    
BEGIN    
 -- For Clearing the Prking/Temp Table -----     
 ---------------->  Added by Lakshman M on 29/09/2018  <-------------------
 DECLARE @FROMDATE AS Datetime
 DECLARE @TodayDt AS datetime
 SELECT @FROMDATE = cast(DATEADD(DAY, -7, GETDATE()) AS DATETIME)
 SELECT @FROMDATE=CONVERT(VARCHAR(11), @FROMDATE, 121)
 SELECT @TodayDt= CAST(convert(varchar,getdate()) AS DATETIME)
 SELECT @TodayDt= CONVERT(VARCHAR(11), @TodayDt, 121)
 SELECT * INTO #ETLTempPurchaseReceipt_temp FROM ETLTempPurchaseReceipt WHERE InvDate between CONVERT(VARCHAR(11), @FROMDATE, 121) and CONVERT(VARCHAR(11), @TodayDt, 121)
 UPDATE A SET A.downloadstatus = 0 FROM ETLTempPurchaseReceipt A INNER JOIN #ETLTempPurchaseReceipt_temp B ON A.CmpInvNo =B.CmpInvNo
  
 UPDATE A SET A.downloadstatus = 1 from ETLTempPurchaseReceipt A where CmpInvNo in(select CmpInvNo from PurchaseReceipt)   ---> added By Lakshman M PMS ID: ILCRSTPAR2285 

 SELECT * INTO #ETLTempPurchaseReceipt_temp1 FROM ETLTempPurchaseReceipt WHERE InvDate < CONVERT(VARCHAR(11),@FROMDATE, 121)
 Delete A from ETLTempPurchaseReceipt A INNER JOIN #ETLTempPurchaseReceipt_temp1 B ON A.CmpInvNo =B.CmpInvNo  
 Delete A from ETLTempPurchaseReceiptproduct A INNER JOIN #ETLTempPurchaseReceipt_temp1 B ON A.CmpInvNo =B.CmpInvNo 
---------------->  Till Here  <----------------------
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
 DECLARE @ErrStatus INT    
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
 IF EXISTS (SELECT DISTINCT CompInvNo,SupplierCode FROM Cn2Cs_Prk_BLPurchaseReceipt  
 WHERE UPPER(ISNULL(TaxType,'VAT')) NOT IN ('VAT','GST'))  
 BEGIN  
  INSERT INTO InvToAvoid (CmpInvNo)  
  SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE UPPER(ISNULL(TaxType,'VAT')) NOT IN ('VAT','GST')  
  INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)  
  SELECT DISTINCT 1,'Purchase Receipt','Tax Type','Purchase Tax Type should be VAT or GST '+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt  
  WHERE UPPER(ISNULL(TaxType,'VAT')) NOT IN ('VAT','GST')  
 END  
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
 [Invoice Date],[Transporter Code],[NetPayable Amount],[TaxType])  
 SELECT DISTINCT C.CmpCode,SupplierCode,P.CompInvNo,'',P.CompInvDate,@TransporterCode,P.NetValue,  
 P.TaxType  
 FROM Company C,Cn2Cs_Prk_BLPurchaseReceipt P  
 WHERE  C.DefaultCompany=1 AND DownLoadFlag='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)  
 UPDATE A SET [TaxType]='VAT' FROM ETL_Prk_PurchaseReceipt A (NOLOCK)   
 INNER JOIN Cn2Cs_Prk_BLPurchaseReceipt B (NOLOCK) ON B.CompInvNo=A.[Company Invoice No]   
 AND A.[Supplier Code]=B.SupplierCode WHERE ISNULL(A.TaxType,'')=''  
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
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_RptCmpWisePurchase' AND XTYPE='P')
DROP PROC Proc_RptCmpWisePurchase
GO
--EXEC Proc_RptCmpWisePurchase 23,1,0,'CoreStocky',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptCmpWisePurchase]
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
	--@Po_Errno		INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_RptCmpWisePurchase
* PURPOSE		: Company wise Purchase Report
* CREATED		: 
* CREATED DATE	: 
* MODIFIED
-------------------------------------------------------------------------------------------------------
* [DATE]      [DEVELOPER]         [USER_STORY_ID]   [CR/BUG]  [DESCRIPTION]
* Date            Name              PMS NO            CR/BUG      Remarks
-------------------------------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}
* 28.02.2013	Aravindh Deva C		Parle-GR005-CR002 Tin Number required in Company wise Purchase Report
* 2013-05-10    Alphonse J          Other charge addition deduction Modified ICRSTPAR0033
* 2019-03-06    Deepak Philip       ILCRSTPAR3657      BUG     Script has been modified to take the claim free products as “FREE” and Slno validation removed in gross.
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
DECLARE @FromDate	AS	DATETIME
DECLARE @ToDate		AS	DATETIME
DECLARE @CmpId	 	AS	INT
DECLARE @PurRcptID 	AS	INT
DECLARE @EXLFlag	AS	INT
--select * from reportfilterdt
SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @PurRcptID = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,197,@Pi_UsrId))
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
Create TABLE #RptCmpWisePurchase
(
		CmpId 				INT,
		CmpName  			NVARCHAR(50),		
		PurRcptId 			BIGINT,
		PurRcptRefNo 		NVARCHAR(50),
		InvDate 			DATETIME,
		GrossAmount 		NUMERIC(38,6),
		SlNo 				INT,
		RefCode 			NVARCHAR(25),
		FieldDesc 			NVARCHAR(100),
		LineBaseQtyAmount 	NUMERIC(38,6),
		LessScheme 			NUMERIC(38,6),
		OtherChgAddition	NUMERIC(38,6),	
		OtherChgDeduction	NUMERIC(38,6),		
		NetAmount 			NUMERIC(38,6),
		CmpInvNo			NVARCHAR(25),
		CmpInvDate 			DATETIME
	)
SET @TblName = 'RptCmpWisePurchase'
SET @TblStruct = '
		CmpId 				INT,
		CmpName  			NVARCHAR(50),		
		PurRcptId 			BIGINT,
		PurRcptRefNo 		NVARCHAR(50),
		InvDate 			DATETIME,
		GrossAmount 		NUMERIC(38,6),
		SlNo 				INT,
		RefCode 			NVARCHAR(25),
		FieldDesc 			NVARCHAR(100),
		LineBaseQtyAmount 	NUMERIC(38,6),
		LessScheme 			NUMERIC(38,6),
		OtherChgAddition	NUMERIC(38,6),	
		OtherChgDeduction	NUMERIC(38,6),	
		NetAmount 			NUMERIC(38,6),
		CmpInvNo			NVARCHAR(25),
		CmpInvDate 			DATETIME'
			
SET @TblFields = 'CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
		 ,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo,CmpInvDate'
/*		 
--Parle-GR005-CR002
	SELECT S.SpmId [SpmId],S.SpmName [SpmName],ISNULL(D.ColumnValue,'') [SpmTINNo]
	INTO #SupplierTIN
	FROM UdcMaster M (NOLOCK)
	INNER JOIN UdcDetails D (NOLOCK) ON M.UdcMasterId=D.UdcMasterId AND M.MasterId=D.MasterId 
	AND M.ColumnName='TIN Number' AND M.MasterId IN (SELECT DISTINCT MasterId FROM UdcHD (NOLOCK) WHERE MasterName='Supplier Master')
	RIGHT OUTER JOIN Supplier S ON S.SpmId=D.MasterRecordId	
--Parle-GR005-CR002	
*/	 
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
--SET @Po_Errno = 0
IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
BEGIN
--	EXEC Proc_GRNListing @Pi_UsrId
	SELECT PurRcptId,PurRcptRefNo,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpInvNo,InvDate,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,
		   ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,Slno,RefCode,FieldDesc ,LineBaseQtyAmount,
		   PrdNetAmount,status,GoodsRcvdDate,LessScheme,OtherChgAddition,OtherChgDeduction,TotalAddition,TotalDeduction,GrossAmount,NetPayable,
		   DifferenceAmount,PaidAmount,NetAmount,CmpId,CmpName,UsrId
	INTO #TempGrnListing FROM 
		(
			Select PR.PurRcptId,PurRcptRefNo,PRP.PrdId,PrdDCode,PrdName,PRP.PrdBatId,PrdBatCode,CmpInvNo,InvDate,InvBaseQty,RcvdGoodBaseQty,UnSalBaseQty,
			ShrtBaseQty,ExsBaseQty,RefuseSale,PrdUnitLSP,PrdGrossAmount,Slno,PRL.RefCode,FieldDesc ,LineBaseQtyAmount,
			PrdNetAmount,PR.status,GoodsRcvdDate,LessScheme,
			--Modified By Alphonse J on 2013-05-10 ICRSTPAR0033
			--CASE PRC.Effect WHEN 0 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgAddition,
			--CASE PRC.Effect WHEN 1 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgDeduction,
			ISNULL(PRC.Amount,0) AS OtherChgAddition,
			ISNULL(PRC1.Amount,0) AS OtherChgDeduction,
			TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,@Pi_UsrId AS UsrId,PR.CmpId,CmpName
			FROM PurchaseReceipt PR
			INNER JOIN PurchaseReceiptProduct PRP ON PR.PurRcptId = PRP.PurRcptId
			INNER JOIN PurchasereceiptLineAmount PRL ON PR.PurRcptId = PRL.PurRcptId
			and PRL.PrdSlNo = PRP.PrdSlNo
			INNER JOIN PurchaseSequenceMaster PS ON PR.PurSeqId = PS.PurSeqId
			INNER JOIN PurchaseSequenceDetail PD ON PD.PurSeqId = PS.PurSeqId and PRL.RefCode = PD.RefCode
			INNER JOIN Company C ON C.CmpId = PR.CmpId
			INNER JOIN Supplier S ON S.SpmId = PR.SpmId
			INNER JOIN Transporter T ON T.TransporterId = PR.TransporterId
			INNER JOIN Location L ON L.LcnId = PR.LcnId
			INNER JOIN Product P ON P.PrdId = PRP.PrdId
			INNER JOIN ProductBatch  PB ON PB.PrdId = PRP.PrdId  and PB.PrdBatId = PRP.PrdBatId
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC ON PR.PurRcptId = PRC.PurRcptId AND PRC.Effect=0
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC1 ON PR.PurRcptId = PRC1.PurRcptId AND PRC1.Effect=1
			WHERE PR.Status=1 AND PR.GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND
			( C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
						C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
					AND ( PR.PurRcptId = (CASE @PurRcptID WHEN 0 THEN PR.PurRcptId ELSE 0 END) OR
						PR.PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,197,@Pi_UsrId)))
					and PRP.PrdSlNo > 0 
			UNION ALL
			Select PR.PurRcptId,PurRcptRefNo,
			0 as PrdId,'' as PrdDCode,'' as PrdName,0 as PrdBatId,'' as PrdBatCode,Pr.CmpInvNo,InvDate,0 as InvBaseQty,0 as RcvdGoodBaseQty,
			0 as UnSalBaseQty,0 as ShrtBaseQty,0 as ExsBaseQty,0 AS RefuseSale,0 as PrdUnitLSP,
			0 as PrdGrossAmount,0 as Slno,'' as RefCode,'Free' as FieldDesc ,0 as LineBaseQtyAmount,--ILCRSTPAR3657
			0 as PrdNetAmount,PR.status,GoodsRcvdDate,
			LessScheme,
			--CASE PRC.Effect WHEN 0 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgAddition,
			--CASE PRC.Effect WHEN 1 THEN ISNULL(PRC.Amount,0) ELSE 0 END AS OtherChgDeduction,
			ISNULL(PRC.Amount,0) AS OtherChgAddition,
			ISNULL(PRC1.Amount,0) AS OtherChgDeduction,
			TotalAddition,TotalDeduction,GrossAmount,NetPayable,DifferenceAmount,PaidAmount,NetAmount,@Pi_UsrId AS UsrId,PR.CmpId,CmpName
			from purchasereceipt PR
			Inner join purchasereceiptclaimScheme PRCS on PRCS.PurRcptId = PR.PurRcptId
			INNER JOIN Company C ON C.CmpId = PR.CmpId
			INNER JOIN Supplier S ON S.SpmId = PR.SpmId
			INNER JOIN Transporter T ON T.TransporterId = PR.TransporterId
			INNER JOIN Location L ON L.LcnId = PR.LcnId
			INNER JOIN StockType ST ON ST.StockTypeId = PRCS.StockTypeId
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC ON PR.PurRcptId = PRC.PurRcptId AND PRC.Effect=0
			LEFT OUTER JOIN PurchaseReceiptOtherCharges PRC1 ON PR.PurRcptId = PRC1.PurRcptId AND PRC1.Effect=1
			LEFT OUTER JOIN Product P ON P.PrdId = PRCS.PrdId
			LEFT OUTER JOIN ProductBatch  PB ON PB.PrdId =PRCS.PrdId  and PB.PrdBatId = PRCS.PrdBatId
			WHERE PR.Status=1 AND PR.GoodsRcvdDate BETWEEN @FromDate AND @ToDate AND
			( C.CmpId = (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END) OR
						C.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
					AND ( PR.PurRcptId = (CASE @PurRcptID WHEN 0 THEN PR.PurRcptId ELSE 0 END) OR
						PR.PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,197,@Pi_UsrId)))
		) AS A
		
		
		
		
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
		 ,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo,CmpInvDate)
		SELECT DISTINCT CmpId,CmpName,PurRcptId,PurRcptRefno,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,
		dbo.Fn_ConvertCurrency(sum(LineBaseQtyAmount),@Pi_CurrencyId) as LineBaseQtyAmount,
		dbo.Fn_ConvertCurrency(LessScheme,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(OtherChgAddition,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(OtherChgDeduction,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(NetAmount,@Pi_CurrencyId),CmpInvNo,CmpInvdate
		From ( SELECT  cmpid,cmpname,purrcptid,purrcptrefno,GoodsRcvdDate AS InvDate,GrossAmount,slno,
		RefCode,FieldDesc,LineBaseQtyAmount,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo, InvDate AS CmpInvDate,UsrId	
		FROM #TempGrnListing) x
		Group by
		cmpid,cmpname,purrcptid,purrcptrefno,InvDate, GrossAmount,slno,RefCode,FieldDesc,
		LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpInvNo,CmpInvDate,usrid	
	
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select DISTINCT Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,(Select max(SLNO) + 1 From PurchaseSequenceDetail) as SlNo,'AAA' as RefCode,'Net Amt.' as FieldDesc,
	NetAmount as LineBaseQtyAmount,LessScheme,0,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select MAX(slno) AS SLNO From #RptCmpWisePurchase)
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-1 as SlNo,'BBB' as RefCode,'Other Charges Addition' as FieldDesc,
	OtherChgAddition as LineBaseQtyAmount,LessScheme,OtherChgAddition,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO From #RptCmpWisePurchase)
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select DISTINCT Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-2 as SlNo,'CCC' as RefCode,'Scheme Disc.' as FieldDesc,
	LessScheme as LineBaseQtyAmount,LessScheme,0,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO From #RptCmpWisePurchase)
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select DISTINCT Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-3 as SlNo,'DDD' as RefCode,'Gross Amount' as FieldDesc,
	GrossAmount  as LineBaseQtyAmount,LessScheme,0,0,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase --Where  Slno in (Select min(slno) AS SLNO  From #RptCmpWisePurchase)--ILCRSTPAR3657
	INSERT INTO #RptCmpWisePurchase (CmpId,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,SlNo,RefCode,FieldDesc,LineBaseQtyAmount
	,LessScheme,OtherChgAddition,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate)
	Select Cmpid,CmpName,PurRcptId,PurRcptRefNo,InvDate,GrossAmount,-1.5 as SlNo,'EEE' as RefCode,'Other Charges Dedection' as FieldDesc,
	OtherChgDeduction as LineBaseQtyAmount,LessScheme,0,OtherChgDeduction,NetAmount,CmpinvNo,CmpInvdate
	From #RptCmpWisePurchase Where  Slno in (Select min(slno) AS SLNO From #RptCmpWisePurchase WHERE OtherChgDeduction>0)-- AND OtherChgDeduction>0
	

	
	
	IF LEN(@PurDBName) > 0
	BEGIN
		SET @SSQL = 'INSERT INTO #RptCmpWisePurchase ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +
			' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+' (PurRcptId = (CASE ' + CAST(@PurRcptID AS nVarchar(10)) + ' WHEN 0 THEN PurRcptId ELSE 0 END) OR ' +
			' PurRcptId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',197,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
			+ ' ( INVDATE Between ''' + @FromDate + ''' AND ''' + @ToDate + '''' + ' and UsrId = ' + CAST(@Pi_UsrId AS nVarChar(10)) + ') and (Slno > 0)  '
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCmpWisePurchase'
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
		SET @SSQL = 'INSERT INTO #RptCmpWisePurchase ' +
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
		--SET @Po_Errno = 1
		PRINT 'DataBase or Table not Found'
		RETURN
	   END
END
DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCmpWisePurchase
	--Parle-GR005-CR002
	--select * from #RptCmpWisePurchase
	SELECT Rpt.*,RP.SpmId [SpmId],S.SpmName [SpmName],ISNULL(S.SpmTinNo,'') [SpmTINNo] 
	INTO #RptCmpWisePurchaseWtSpmTINNo
	FROM #RptCmpWisePurchase Rpt 
	INNER JOIN PurchaseReceipt RP (nolock) ON RPT.PurRcptId=RP.PurRcptId
	INNER JOIN Supplier S ON RP.SpmId=S.SpmId
	SELECT * FROM #RptCmpWisePurchaseWtSpmTINNo
	--Parle-GR005-CR002
	
	SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
		--EXEC Proc_RptCmpWisePurchase 23,1,0,'CoreStocky',0,0,1
		/******************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @Values NUMERIC(38,6)
		DECLARE  @Desc VARCHAR(80)
		DECLARE  @InvDate DATETIME	
		DECLARE  @cCmpId INT
		DECLARE  @cPurRcptId INT
		DECLARE  @CmpInvNo NVARCHAR(100)	
		DECLARE  @SlNo INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @Name NVARCHAR(100)
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCmpWisePurchase_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptCmpWisePurchase_Excel]
		DELETE FROM RptExcelHeaders Where RptId=23 AND SlNo>11--Parle-GR005-CR002 -- SlNo>8
		CREATE TABLE RptCmpWisePurchase_Excel (CmpId BIGINT,CmpName NVARCHAR(100),
		SpmId	INT,SpmName VARCHAR(50),SpmTinNo NVARCHAR(50),--Parle-GR005-CR002
		PurRcptId BIGINT,PurRcptRefNo NVARCHAR(100),InvDate DATETIME,
						 		CmpInvNo NVARCHAR(100),CmpInvDate DateTime,UsrId INT)
		SET @iCnt=12--Parle-GR005-CR002 --SET @iCnt=9
		DECLARE Crosstab_Cur CURSOR FOR
		SELECT DISTINCT(Fielddesc),SlNo FROM #RptCmpWisePurchase ORDER BY SLNo
		OPEN Crosstab_Cur
			   FETCH NEXT FROM Crosstab_Cur INTO @Column,@SlNo
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptCmpWisePurchase_Excel ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
					FETCH NEXT FROM Crosstab_Cur INTO @Column,@SLNo
				END
		CLOSE Crosstab_Cur
		DEALLOCATE Crosstab_Cur
		--Insert table values
		DELETE FROM RptCmpWisePurchase_Excel
		INSERT INTO RptCmpWisePurchase_Excel (CmpId ,CmpName ,SpmId,SpmName,SpmTinNo,PurRcptId ,PurRcptRefNo ,InvDate ,CmpInvNo ,CmpInvDate ,UsrId)
		SELECT DISTINCT CmpId ,CmpName ,SpmId,SpmName,SpmTinNo,PurRcptId ,PurRcptRefNo ,InvDate ,CmpInvNo ,CmpInvDate,@Pi_UsrId
				--FROM #RptCmpWisePurchase
				FROM #RptCmpWisePurchaseWtSpmTINNo ORDER BY CmpId,SpmId--Parle-GR005-CR002
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT  CmpId,PurRcptId,InvDate,CmpInvNo,FieldDesc,LineBaseQtyAmount FROM #RptCmpWisePurchase
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @cCmpId,@cPurRcptId,@InvDate,@CmpInvNo,@Desc,@Values
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptCmpWisePurchase_Excel SET ['+ @Desc +']= '+ CAST(ISNULL(@Values,0) AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE CmpId='+ CAST(@cCmpId AS VARCHAR(1000)) + ' AND PurRcptId=' + CAST(@cPurRcptId AS VARCHAR(1000)) + '
					AND InvDate=''' + CAST(@InvDate AS VARCHAR(1000))+''' AND CmpInvNo=''' + CAST(@CmpInvNo As VARCHAR(1000)) + ''' AND UsrId=' + CAST(@Pi_UsrId AS VARCHAR(10))+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @cCmpId,@cPurRcptId,@InvDate,@CmpInvNo,@Desc,@Values
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptCmpWisePurchase_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptCmpWisePurchase_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/******************************************************************************************************/
	END
RETURN
END--Aravindh Till Here
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Export_CS2WS_CreditDetails' AND Type ='P')
DROP PROCEDURE Proc_Export_CS2WS_CreditDetails
GO
-- exec Proc_Export_CS2WS_CreditDetails '2'
CREATE PROCEDURE Proc_Export_CS2WS_CreditDetails
(
	@SalRpCode varchar(50)
)
AS
/*******************************************************************************************
* PROCEDURE		: Proc_Export_CS2WS_CreditDetails
* PURPOSE		: To Export Authorized Product details to the PDA Intermediate Database
* CREATED		: S.Moorthi
* CREATED DATE	: 07/08/2018
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
*****************************************************************************************************
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  04/08/2018   S.Moorthi    CR         CRCRSTPAR0017   SFA-Upload-Download Integration --Product
  02/-02/2019  Lakshman M   SR         ILCRSTPAR3332   Retailer credit limit validation included
********************************************************************************************/
BEGIN
	DECLARE @Smid AS int 
	DECLARE @Sql AS varchar(1000)
	
	DELETE FROM Export_CS2WS_CreditDetails WHERE UploadFlag='Y'
	
	IF EXISTS (SELECT * FROM sysobjects WHERE NAME='TempCrRetailer' and xtype='U')
	BEGIN
		DROP TABLE TempCrRetailer
	END
	SET @Sql=' SELECT DistributorCode,R.RtrID,CmpRtrCode as RtrCode,RtrCrBills,0 As RtrOutstndAmt,RtrCrLimit,RtrCrDays INTO TempCrRetailer
	FROM Retailer R 
	INNER JOIN RetailerMarket RM ON RM.RtrId = R.RtrId
	INNER JOIN SalesmanMarket SM ON SM.RMId=RM.RMId
	INNER JOIN RetailerValueClassMap RVM ON R.RtrID = RVM.RtrID 
	INNER JOIN RetailerValueClass RV ON RVM.RtrValueClassId = RV.RtrClassId
	CROSS JOIN	Distributor
	WHERE sm.SMId in ('+ CAST(@SalRpCode AS VARCHAR(100)) +')'
		
	EXEC (@Sql)
	
	SELECT RtrID,SUM(SalNetAmt-SalPayAmt) AS SalNetAmt INTO #TempSalInvAmt FROM SalesInvoice GROUP BY RtrID ORDER BY RtrID
	
	UPDATE TempCrRetailer SET RtrOutstndAmt = SalNetAmt FROM TempCrRetailer A,#TempSalInvAmt B
	WHERE A.RtrID = B.RtrID
	
	
	INSERT INTO Export_CS2WS_CreditDetails(TenantCode,LocationCode,DivisionCode,CustomerCode,CreditLimit,
	CustomerBalanceDue,TotalNumberofInvoices,TotalDaysofInvoices,Blocked,UploadFlag)
	SELECT DistributorCode,DistributorCode AS LocationCode,'DD' AS DivisionCode,RtrCode AS CustomerCode,RtrCrLimit AS CreditLimit,
	RtrOutstndAmt AS CustomerBalanceDue,999 AS TotalNumberofInvoices,999 AS TotalDaysofInvoices,0 AS Blocked,
	'N' AS UploadFlag FROM TempCrRetailer S 
	WHERE NOT EXISTS(SELECT * FROM WSMasterExportUploadTrack M WHERE M.MasterCode = S.RtrCode AND ISNULL(M.MasterName,'')=S.DistributorCode 
	AND ISNULL(M.Ref4Value,0)= S.RtrOutstndAmt AND M.ProcessName='Credit Details') 
	
	DELETE B FROM WSMasterExportUploadTrack B WHERE EXISTS(SELECT * FROM Export_CS2WS_CreditDetails M 
	WHERE B.MasterCode=M.CustomerCode AND ISNULL(B.MasterName,'')=M.LocationCode 
	AND ISNULL(B.Ref4Value,0)<> M.CustomerBalanceDue and M.UploadFlag='N')
	AND B.ProcessName='Credit Details' 
	
	INSERT INTO WSMasterExportUploadTrack(ProcessName,MasterCode,MasterName,ExportTime,Status,Reference1,Reference2,Reference3,Ref4Value)
	SELECT 'Credit Details',CustomerCode,LocationCode,GETDATE(),0,'','','',CustomerBalanceDue FROM Export_CS2WS_CreditDetails WHERE UploadFlag='N' 
	
	UPDATE A set CreditLimit ='9999999' FROM Export_CS2WS_CreditDetails A where CreditLimit ='0.00' ---> Added By lakshman M Dated ON 02/02/2019 PMS ID:ILCRSTPAR3332
	SELECT DISTINCT 
		TenantCode,
		LocationCode,
		DivisionCode,
		CustomerCode,
		CreditLimit,
		CustomerBalanceDue,
		TotalNumberofInvoices,
		TotalDaysofInvoices,
		Blocked
	FROM Export_CS2WS_CreditDetails WITH (NOLOCK) 
	
END
GO
IF EXISTS(SELECT *FROM SYSOBJECTS WHERE NAME ='Proc_Import_SchemeCategoryDetails' AND XTYPE ='P')
DROP PROCEDURE Proc_Import_SchemeCategoryDetails
GO
CREATE PROCEDURE Proc_Import_SchemeCategoryDetails
(
	@Pi_Records TEXT
)
AS
/*************************************************************************************************
* PROCEDURE		: Proc_Import_SchemeCategoryDetails
* PURPOSE		: To Insert records from xml file in the Table Proc_Cn2Cs_SchemeCategoryDetails
* CREATED		: lakshman M
* CREATED DATE	: 11-03-2018
* MODIFIED
* DATE       AUTHOR     CR/BZ		USER STORY ID           DESCRIPTION                         
***************************************************************************************************
11-03-2019  Lakshman M	 CR			CRCRSTPAR0037 			scheme category type validation included from CS. 
****************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Cn2Cs_Prk_SchemeCategorydetails
	(
		DistCode   ,
		CmpSchcode ,
		Schcategory_type ,
		DownLoadFlag,
		CreatedDate
	)
	SELECT DistCode,
	    CmpSchcode,
		Schcategory_type,
		ISNULL(DownLoadFlag,'D'),
		GETDATE()
	FROM OPENXML (@hdoc,'/Root/Console2CS_SchemeCircularDetails',1)
	WITH
	(
		DistCode			NVARCHAR(50) ,
		CmpSchcode			NVARCHAR(50) ,
		Schcategory_type	NVARCHAR(50) ,
		DownLoadFlag		NVARCHAR(10) 
	) XMLObj
	EXEC sp_xml_removedocument @hDoc
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Cn2Cs_BLSchemeAttributes' AND XTYPE ='P')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeAttributes
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeAttributes 0
--SELECT * FROM ErrorLog
SELECT * FROM SchemeRetAttr WHERE SchId=50 AND AttrType=6
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_BLSchemeAttributes
(
@Po_ErrNo INT OUTPUT
)
AS
/**************************************************************************************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeAttributes
* PURPOSE: To Insert and Update Scheme Attributes
* CREATED: Boopathy.P on 02/01/2009
***************************************************************************************************
* 12.09.2011  Panner AttrType Checking (Product or SKU)

**************************************************************************************************
* DATE         AUTHOR          CR/BZ    USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
 11/01/2019   lakshman M       BR      ILCRSTPAR3079   Reatiler category main id wronly mapped
*****************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode 	AS VARCHAR(50)
	DECLARE @AttrType 	AS VARCHAR(50)
	DECLARE @AttrCode 	AS VARCHAR(50)
	DECLARE @AttrTypeId 	AS INT
	DECLARE @AttrId  	AS INT
	DECLARE @CmpId  	AS INT
	DECLARE @SchLevelId 	AS INT
	DECLARE @SelMode 	AS INT
	DECLARE @ChkCount 	AS INT
	DECLARE @ErrDesc  	AS VARCHAR(1000)
	DECLARE @TabName  	AS VARCHAR(50)
	DECLARE @GetKey  	AS VARCHAR(50)
	DECLARE @Taction  	AS INT
	DECLARE @sSQL   	AS VARCHAR(4000)
	DECLARE @ConFig		AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @CombiId	AS INT
	DECLARE @SLevel		AS INT
	DECLARE @iCnt		AS INT
	DECLARE @DepChk		AS INT
	DECLARE @MasterRecordID AS INT
	DECLARE @AttrName 	AS VARCHAR(100)
	SET @DepChk=0
	SET @TabName = 'Etl_Prk_Scheme_OnAttributes'
	SET @Po_ErrNo =0
	SET @iCnt=0
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	
	DELETE FROM Etl_Prk_SchemeAttribute_Temp
	DECLARE  @Temp_CtgAttrDt TABLE
	(
		SchId		INT,
		CtgMainId	INT
	)
	DECLARE  @Temp_CtgAttrDt_Temp TABLE
	(
		SchId		NVARCHAR(50),
		CtgMainId	INT
	)
	DECLARE  @Temp_ValAttrDt TABLE
	(
		SchId		INT,
		ValClass	VARCHAR(400)
	)
	
	DECLARE  @Temp_ValAttrDt_Temp TABLE
	(
		SchId		NVARCHAR(50),
		ValClass	VARCHAR(400)
	)
	DECLARE  @Temp_KeyAttrDt TABLE
	(
		SchId		INT,
		RtrId		INT
	)
	DECLARE Cur_SchemeAttr CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],ISNULL([AttrType],'') AS [Attribute Type],
	ISNULL([AttrName],'') AS [Attribute Master Code] FROM Etl_Prk_Scheme_OnAttributes 
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D' 
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code], [Attribute Type]
	OPEN Cur_SchemeAttr
	FETCH NEXT FROM Cur_SchemeAttr INTO @SchCode,@AttrType,@AttrCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @iCnt=@iCnt+1
		SET @Taction = 2
		SET @Po_ErrNo =0
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@AttrType))<>''
		BEGIN
			IF LTRIM(RTRIM(@AttrCode))=''
			BEGIN
				SET @ErrDesc = 'Attribute Code should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Attribute Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		ELSE IF LTRIM(RTRIM(@AttrCode))<>''
		BEGIN
			IF LTRIM(RTRIM(@AttrType))=''
			BEGIN
				SET @ErrDesc = 'Attribute Type should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Attribute Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @ConFig<>1
			BEGIN
				IF NOT EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
					
				END
				ELSE
				BEGIN
					SET @DepChk=1
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SelMode=SchemeLvlMode,@CombiId=CombiSch FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END	
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @DepChk=1
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SelMode=SchemeLvlMode,@CombiId=CombiSch FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
					CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
					BEGIN	
						IF NOT EXISTS(SELECT [CmpSchCode] FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE
						[CmpSchCode]=LTRIM(RTRIM(@SchCode)))
						BEGIN
							SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode+ ' in table Etl_Prk_SchemeHD_Slabs_Rules  '
							INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
							B.CmpCode=A.[CmpCode] WHERE [CmpSchCode]=LTRIM(RTRIM(@SchCode))
							SELECT @SchLevelId=C.CmpPrdCtgId,
								@SelMode=(CASE A.SchemeLevelMode
								WHEN 'PRODUCT' THEN 0 ELSE 1 END),@CombiId=(CASE A.CombiSch
								WHEN 'NO' THEN 0 ELSE 1 END)
							FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
							INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
							AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
						END
					END
					ELSE
					BEGIN
						SET @DepChk=2
						SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM ETL_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
	
						SELECT @SelMode=SchemeLvlMode,@CombiId=CombiSch FROM ETL_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
	
						SELECT @SchLevelId=SchLevelId FROM ETL_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					END	
				END
			END
			IF UPPER(LTRIM(RTRIM(@AttrType)))= 'SALESMAN'
				BEGIN
				SET @AttrTypeId=1
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT SMID FROM SALESMAN WITH (NOLOCK) WHERE
						SMCODE=LTRIM(RTRIM(@AttrCode)) AND STATUS = 1)
					BEGIN
						SET @ErrDesc = 'Salesman Code:'+ @AttrCode+ ' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'SalesMan',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=SMID FROM SALESMAN WITH (NOLOCK) WHERE
						SMCODE=LTRIM(RTRIM(@AttrCode)) AND STATUS = 1
					END
				END
			END
			--->Added By Nanda on 28/07/2010
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'CLUSTER'
				BEGIN
				SET @AttrTypeId=21
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT ClusterId FROM ClusterMaster WITH (NOLOCK) WHERE
						ClusterCode=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Cluster Code:'+ @AttrCode+ ' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Cluster',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=ClusterId FROM ClusterMaster WITH (NOLOCK) WHERE
						ClusterCode=LTRIM(RTRIM(@AttrCode))
					END
				END
			END
			--->Till Here
			
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'ROUTE'
			BEGIN
				SET @AttrTypeId=2
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT RMID FROM RouteMaster WITH (NOLOCK) WHERE
						RMCODE=LTRIM(RTRIM(@AttrCode)) AND RMStatus = 1)
					BEGIN
						SET @ErrDesc = 'Route Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Route',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=RMID FROM RouteMaster WITH (NOLOCK) WHERE
						RMCODE=LTRIM(RTRIM(@AttrCode)) AND RMStatus = 1
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'VILLAGE'
			BEGIN
				SET @AttrTypeId=3
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT VillageId FROM RouteVillage WITH (NOLOCK) WHERE
						VILLAGECODE=LTRIM(RTRIM(@AttrCode)) AND VillageStatus = 1)
					BEGIN
						SET @ErrDesc = 'Route Village Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'RouteVillage',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=VillageId FROM RouteVillage WITH (NOLOCK) WHERE
						VILLAGECODE=LTRIM(RTRIM(@AttrCode)) AND VillageStatus = 1
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'CATEGORY LEVEL'
			BEGIN
				SET @AttrTypeId=4
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT CtgLevelId FROM RetailerCategoryLevel WITH (NOLOCK) WHERE
						CtgLevelName=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Category Level:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Category Level',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=CtgLevelId FROM RetailerCategoryLevel WITH (NOLOCK) WHERE
						CtgLevelName=LTRIM(RTRIM(@AttrCode))
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'CATEGORY LEVEL VALUE'
			BEGIN
				SET @AttrTypeId=5
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT CtgMainId FROM RetailerCategory WITH (NOLOCK) WHERE
					CtgCOde=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Category Level Value not found''' + LTRIM(RTRIM(@SchCode)) + ''''
						INSERT INTO Errorlog VALUES (1,@TabName,'Category Level Value',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=CtgMainId FROM RetailerCategory WITH (NOLOCK) WHERE
						CtgCOde=LTRIM(RTRIM(@AttrCode))
						--->Modified By Nanda on 24/08/2009
						IF @DepChk=1
						BEGIN
							INSERT INTO @Temp_CtgAttrDt SELECT @GetKey,@AttrId
						END
						ELSE
						BEGIN
							INSERT INTO @Temp_CtgAttrDt_Temp SELECT @GetKey,@AttrId
						END
						--Till Here
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'VALUECLASS'
			BEGIN
				SET @AttrTypeId=6
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT RtrClassId FROM RETAILERVALUECLASS WITH (NOLOCK) WHERE
						ValueClassCode=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Value Class Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Value Class',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=RtrClassId FROM RETAILERVALUECLASS WITH (NOLOCK) WHERE
						ValueClassCode=LTRIM(RTRIM(@AttrCode))
						--->Modified By Nanda on 24/08/2009
						IF @DepChk=1
						BEGIN
							INSERT INTO @Temp_ValAttrDt SELECT @GetKey,@AttrCode
						END
						ELSE
						BEGIN
							INSERT INTO @Temp_ValAttrDt_Temp SELECT @GetKey,@AttrCode
						END
						--Till Here
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'POTENTIALCLASS'
			BEGIN
				SET @AttrTypeId=7
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT RtrClassId FROM RETAILERPOTENTIALCLASS WITH (NOLOCK) WHERE
						PotentialClassCode=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Potential Class Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Potential Class',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=RtrClassId FROM RETAILERPOTENTIALCLASS WITH (NOLOCK) WHERE
						PotentialClassCode=LTRIM(RTRIM(@AttrCode))
					END
				END
			END
			ELSE IF ((UPPER(LTRIM(RTRIM(@AttrType)))= 'KEYGROUP') OR (UPPER(LTRIM(RTRIM(@AttrType)))= 'RETAILER'))
			BEGIN
				SET @AttrTypeId=8
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN	
					IF (UPPER(LTRIM(RTRIM(@AttrType)))= 'KEYGROUP')
					BEGIN
						IF NOT EXISTS(SELECT GrpId FROM KeyGroupMaster WITH (NOLOCK) WHERE
								GrpCode = @AttrCode)
						BEGIN
							SET @ErrDesc = 'Key Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'Key Group',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @AttrName = GrpName FROM KeyGroupMaster WITH (NOLOCK) WHERE GrpCode = LTRIM(RTRIM(@AttrCode))
							DECLARE Cur_KeyGrp CURSOR FOR 
							SELECT ISNULL(MasterRecordID,0) AS [MasterRecordID] FROM UdcDetails A INNER JOIN UdcMaster B
							ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
							INNER JOIN RETAILER R ON A.MasterRecordId=R.RtrId INNER JOIN KeyGroupMaster K 
							ON K.GrpName=A.ColumnValue Where A.ColumnValue=@AttrName AND C.MAsterID = 2
							OPEN Cur_KeyGrp
							FETCH NEXT FROM Cur_KeyGrp INTO @MasterRecordID
							WHILE @@FETCH_STATUS=0
							BEGIN
								INSERT INTO @Temp_KeyAttrDt SELECT @GetKey,@MasterRecordID
							FETCH NEXT FROM Cur_KeyGrp INTO @MasterRecordID
							END
							CLOSE Cur_KeyGrp
							DEALLOCATE Cur_KeyGrp
						END
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'RETAILER'
					BEGIN
						IF NOT EXISTS (SELECT RtrId FROM Retailer WITH (NOLOCK) WHERE CmpRtrCode = LTRIM(RTRIM(@AttrCode)))
						BEGIN
							SET @ErrDesc = 'Retailer Code:'+ @AttrCode + ' not found for Scheme Code:'+ @SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @AttrId = RtrId FROM Retailer WITH (NOLOCK) WHERE CmpRtrCode = LTRIM(RTRIM(@AttrCode))
						END
					END
				END
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@AttrType))) = 'SKU' OR UPPER(LTRIM(RTRIM(@AttrType)))= 'PRODUCT')
			BEGIN
				SET @AttrTypeId=9
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF @SelMode=0
					BEGIN
						SET @AttrId=1
					END
					ELSE IF @SelMode=1
					BEGIN
						IF NOT EXISTS(SELECT DISTINCT A.UDCUniqueId FROM UdcDetails A INNER JOIN UdcMaster B
							ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
							INNER JOIN Product P ON A.MasterRecordId=P.PrdId AND P.CmpId=@CmpId
							Where A.UdcMasterId=@SchLevelId)
						BEGIN
							SET @AttrId=@AttrCode
						END
						ELSE
						BEGIN
							SELECT DISTINCT @AttrId=A.UDCUniqueId FROM UdcDetails A INNER JOIN UdcMaster B
							ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
							INNER JOIN Product P ON A.MasterRecordId=P.PrdId AND P.CmpId=@CmpId
							Where A.UdcMasterId=@SchLevelId
						END
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL TYPE'
			BEGIN
				SET @AttrTypeId=10
				IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'VAN SALES' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'READY STOCK'
					AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ORDER BOOKING'
				BEGIN
					SET @ErrDesc = 'BILL TYPE SHOULD BE(VAN SALES OR READY STOCK OR ORDER BOOKING) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (1,@TabName,'Bill Type',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='VAN SALES'
				BEGIN
					SET @AttrId=3
				END
				ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='READY STOCK'
				BEGIN
					SET @AttrId=2
				END
				ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ORDER BOOKING'
				BEGIN
					SET @AttrId=1
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL MODE'
			BEGIN
				SET @AttrTypeId=11
				IF UPPER(LTRIM(RTRIM(@AttrCode)))='ALL'
				BEGIN
					SET @AttrId=1
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'CASH' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'CREDIT'
					BEGIN
						SET @ErrDesc = 'BILL MODE SHOULD BE(CASH OR CREDIT) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Bill Mode',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='CASH'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='CREDIT'
					BEGIN
						SET @AttrId=2
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'RETAILER TYPE'
			BEGIN
				SET @AttrTypeId=12
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'KEY OUTLET' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'NON-KEY OUTLET'
					BEGIN
						SET @ErrDesc = 'RETAIER TYPE SHOULD BE(KEY OUTLET OR NON-KEY OUTLET) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'RETAILER TYPE',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='KEY OUTLET'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='NON-KEY OUTLET'
					BEGIN
						SET @AttrId=2
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'CLASS TYPE'
			BEGIN
				SET @AttrTypeId=13
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'VALUE CLASSIFICATION' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POTENTIAL CLASSIFICATION'
					BEGIN
						SET @ErrDesc = 'CLASS TYPE SHOULD BE(VALUE CLASSIFICATION OR POTENTIAL CLASSIFICATION) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'CLASS TYPE',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='VALUE CLASSIFICATION'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POTENTIAL CLASSIFICATION'
					BEGIN
						SET @AttrId=2
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'ROAD CONDITION'
			BEGIN
				SET @AttrTypeId=14
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'GOOD' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ABOVE AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'AVERAGE' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'BELOW AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POOR'
					BEGIN
						SET @ErrDesc = 'ROAD CONDITION SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'ROAD CONDITION',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='GOOD'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ABOVE AVERAGE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='AVERAGE'
					BEGIN
						SET @AttrId=3
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='BELOW AVERAGE'
					BEGIN
						SET @AttrId=4
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POOR'
					BEGIN
						SET @AttrId=5
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'INCOME LEVEL'
			BEGIN
				SET @AttrTypeId=15
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'GOOD' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ABOVE AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'AVERAGE' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'BELOW AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POOR'
					BEGIN
						SET @ErrDesc = 'INCOME LEVEL SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'INCOME LEVEL',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='GOOD'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ABOVE AVERAGE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='AVERAGE'					
					BEGIN
						SET @AttrId=3
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='BELOW AVERAGE'
					BEGIN
						SET @AttrId=4
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POOR'
					BEGIN
						SET @AttrId=5
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'ACCEPTABILITY'
			BEGIN
				SET @AttrTypeId=16
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'GOOD' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ABOVE AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'AVERAGE' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'BELOW AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POOR'
					BEGIN
						SET @ErrDesc = 'ACCEPTABILITY SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'ACCEPTABILITY',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='GOOD'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ABOVE AVERAGE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='AVERAGE'
					BEGIN
						SET @AttrId=3
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='BELOW AVERAGE'
					BEGIN
						SET @AttrId=4
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POOR'
					BEGIN
						SET @AttrId=5
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'AWARENESS'
			BEGIN
				SET @AttrTypeId=17
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'GOOD' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ABOVE AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'AVERAGE' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'BELOW AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POOR'
					BEGIN
						SET @ErrDesc = 'AWARENESS SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'AWARENESS',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='GOOD'
					BEGIN
						SET @AttrId=1
					END 					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ABOVE AVERAGE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='AVERAGE'
					BEGIN
						SET @AttrId=3
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='BELOW AVERAGE'
					BEGIN
						SET @AttrId=4
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POOR'
					BEGIN
						SET @AttrId=5
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'ROUTE TYPE'
			BEGIN
				SET @AttrTypeId=18
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'SALES ROUTE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'DELIVERY ROUTE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'MERCHANDISING ROUTE'
					BEGIN
						SET @ErrDesc = 'ROUTE TYPE SHOULD BE(SALES ROUTE OR DELIVERY ROUTE OR MERCHANDISING ROUTE) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'ROUTE TYPE',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='SALES ROUTE'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='DELIVERY ROUTE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='MERCHANDISING ROUTE'
					BEGIN
						SET @AttrId=3
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'LOCALUPCOUNTRY'
			BEGIN
				SET @AttrTypeId=19
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'LOCAL ROUTE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'UPCOUNTRY ROUTE'
					BEGIN
						SET @ErrDesc = 'LOCAL/UPCOUNTRY SHOULD BE(LOCAL ROUTE OR UPCOUNTRY ROUTE) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'LOCALUPCOUNTRY',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='LOCAL ROUTE'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='UPCOUNTRY ROUTE'
					BEGIN
						SET @AttrId=2
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'VAN/NON VAN ROUTE'
			BEGIN
				SET @AttrTypeId=20
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'VAN ROUTE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'NON VAN ROUTE'
					BEGIN
						SET @ErrDesc = 'VAN/NON VAN ROUTE SHOULD BE(VAN ROUTE OR NON VAN ROUTE) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'NON VAN ROUTE',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='VAN ROUTE'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='NON VAN ROUTE'
					BEGIN
						SET @AttrId=2
					END
				END
			END
		END
		IF @Po_ErrNo =1
		BEGIN
			IF @DepChk=1
			BEGIN
				EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
				SELECT @ChkCount=COUNT(*) FROM TempDepCheck
				IF @ChkCount > 0
				BEGIN
					SET @Taction = 0
				END
			END
		END
		ELSE
		BEGIN
			IF @ConFig=1
			BEGIN
				SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				IF @SchLevelId <@SLevel
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
			
						IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL MODE' OR UPPER(LTRIM(RTRIM(@AttrType)))='BILL TYPE' OR UPPER(LTRIM(RTRIM(@AttrType)))='CATEGORY LEVEL VALUE'
						BEGIN
							DELETE FROM SchemeRetAttr WHERE SchId=ISNULL(@GetKey,0) AND AttrType=@AttrTypeId
							AND AttrId=@AttrId
			
							SET @sSQL='DELETE FROM SchemeRetAttr WHERE SchId='+ CAST(@GetKey AS VARCHAR(10)) +
							' AND AttrType=' + CAST(@AttrTypeId AS VARCHAR(10)) + ' AND AttrId=' + CAST(@AttrId AS VARCHAR(10))
						END
						ELSE
						BEGIN
							DELETE FROM SchemeRetAttr WHERE SchId=ISNULL(@GetKey,0) AND AttrType=@AttrTypeId AND AttrId=@AttrId
			
							SET @sSQL='DELETE FROM SchemeRetAttr WHERE SchId='+ CAST(@GetKey AS VARCHAR(10)) +
							' AND AttrType=' + CAST(@AttrTypeId AS VARCHAR(10))
						END
						
						INSERT INTO Translog(strSql1) Values (@sSQL)
						INSERT INTO SchemeRetAttr(SchId,AttrType,AttrId,Availability,LastModBy,LastModDate,
						AuthId,AuthDate) VALUES(ISNULL(@GetKey,0),@AttrTypeId,@AttrId,1,1,convert(varchar(10),getdate(),121),
						1,convert(varchar(10),getdate(),121))
		
						SET @sSQL='INSERT INTO SchemeRetAttr(SchId,AttrType,AttrId,Availability,LastModBy,LastModDate,
						AuthId,AuthDate) VALUES(' + CAST(@GetKey AS VARCHAR(10)) + ',' + CAST(@AttrTypeId AS VARCHAR(10)) +
						',' + CAST(@AttrId AS VARCHAR(10)) + ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
						INSERT INTO Translog(strSql1) Values (@sSQL)
				
					END					
					ELSE
					BEGIN	
						INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag)
						VALUES (LTRIM(RTRIM(@SchCode)),@AttrTypeId,@AttrId,'N')
						SET @sSQL='INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag
						) VALUES(' + CAST(@SchCode AS VARCHAR(50)) + ',' + CAST(@AttrTypeId AS VARCHAR(10)) + ',''N'''')'
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
			
				END
				ELSE
				BEGIN	
					--Nanda
					--SELECT LTRIM(RTRIM(@SchCode)),@AttrTypeId,@AttrId
					INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag)
						VALUES (LTRIM(RTRIM(@SchCode)),@AttrTypeId,@AttrId,'N')
					SET @sSQL='INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag
					) VALUES(' + CAST(@SchCode AS VARCHAR(50)) + ',' + CAST(@AttrTypeId AS VARCHAR(10)) + ',''N'''')'
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--Nanda
					--SELECT * FROM Etl_Prk_SchemeAttribute_Temp					
				END					
			END
			ELSE
			BEGIN
				IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL MODE' OR UPPER(LTRIM(RTRIM(@AttrType)))='BILL TYPE' OR  UPPER(LTRIM(RTRIM(@AttrType)))='CATEGORY LEVEL VALUE'
				BEGIN
					DELETE FROM SchemeRetAttr WHERE SchId=ISNULL(@GetKey,0) AND AttrType=@AttrTypeId
					AND AttrId=@AttrId
	
					SET @sSQL='DELETE FROM SchemeRetAttr WHERE SchId='+ CAST(@GetKey AS VARCHAR(10)) +
					' AND AttrType=' + CAST(@AttrTypeId AS VARCHAR(10)) + ' AND AttrId=' + CAST(@AttrId AS VARCHAR(10))
				END
				ELSE
				BEGIN
					DELETE FROM SchemeRetAttr WHERE SchId=ISNULL(@GetKey,0) AND AttrType=@AttrTypeId
	
					SET @sSQL='DELETE FROM SchemeRetAttr WHERE SchId='+ CAST(@GetKey AS VARCHAR(10)) +
					' AND AttrType=' + CAST(@AttrTypeId AS VARCHAR(10))
				END
	
				INSERT INTO Translog(strSql1) Values (@sSQL)
				INSERT INTO SchemeRetAttr(SchId,AttrType,AttrId,Availability,LastModBy,LastModDate,
				AuthId,AuthDate) VALUES(ISNULL(@GetKey,0),@AttrTypeId,@AttrId,1,1,convert(varchar(10),getdate(),121),
				1,convert(varchar(10),getdate(),121))
	
				SET @sSQL='INSERT INTO SchemeRetAttr(SchId,AttrType,AttrId,Availability,LastModBy,LastModDate,
				AuthId,AuthDate) VALUES(' + CAST(@GetKey AS VARCHAR(10)) + ',' + CAST(@AttrTypeId AS VARCHAR(10)) +
				',' + CAST(@AttrId AS VARCHAR(10)) + ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
				INSERT INTO Translog(strSql1) Values (@sSQL)
			END			
		END
	FETCH NEXT FROM Cur_SchemeAttr INTO @SchCode,@AttrType,@AttrCode
	END
	CLOSE Cur_SchemeAttr
	DEALLOCATE Cur_SchemeAttr
	--SELECT * FROM SchemeRetAttr WHERE SchId=10
	IF EXISTS (SELECT * FROM Etl_Prk_Scheme_OnAttributes)
	BEGIN
		-->Modified By Nanda on 30/11/2009  
		IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SchAttrToAvoid') 
		AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
		BEGIN
			DROP TABLE SchAttrToAvoid	
		END
		CREATE TABLE SchAttrToAvoid
		(
			SchId INT
		)
		INSERT INTO SchAttrToAvoid
		SELECT SchId FROM SchemeRetAttr WHERE AttrId=0 AND AttrType=6
		DELETE FROM SchemeRetAttr WHERE AttrType=6 AND SchId IN  (SELECT DISTINCT SchId FROM @Temp_CtgAttrDt)
		AND SchId NOT IN (SELECT SchId FROM SchAttrToAvoid)
--		INSERT INTO SchemeRetAttr
--		SELECT DISTINCT B.SchId,6,A.RtrClassId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) 
--		FROM RETAILERVALUECLASS A 
--		INNER JOIN @Temp_CtgAttrDt B ON A.CtgMainId=B.CtgMainId 
--		INNER JOIN @Temp_ValAttrDt C ON A.ValueClassCode = C.ValClass AND B.SchId=C.SchId
--		AND B.SchId NOT IN (SELECT SchId FROM SchAttrToAvoid)

		INSERT INTO SchemeRetAttr
		SELECT DISTINCT C.SchId,6,A.RtrValueClassId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) FROM 
		(SELECT DISTINCT RVC.ValueClassCode,RVCM.RtrValueClassId,RC.CtgMainId,RC.CtgLinkId,RCL.CtgLevelId,
		R.RtrKeyAcc,R.VillageId,RC.CtgLinkCode
		FROM Retailer R INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId 
		INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
		INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId) A
		INNER JOIN @Temp_ValAttrDt C ON A.ValueClassCode = C.ValClass 
		INNER JOIN @Temp_CtgAttrDt B ON A.CtgMainId=B.CtgMainId  ----------- PMS ID: ILCRSTPAR3079
		AND C.SchId NOT IN (SELECT SchId FROM SchAttrToAvoid)
		-->Till Here
		
		DELETE FROM Etl_Prk_SchemeAttribute_Temp WHERE AttrType=6 AND CmpSchCode IN  (SELECT DISTINCT SchId FROM @Temp_CtgAttrDt_Temp)
		INSERT INTO Etl_Prk_SchemeAttribute_Temp
		SELECT DISTINCT B.SchId,6,A.RtrClassId,'N'
		FROM RETAILERVALUECLASS A INNER JOIN @Temp_CtgAttrDt_Temp B
		ON A.CtgMainId=B.CtgMainId INNER JOIN @Temp_ValAttrDt_Temp C ON
		A.ValueClassCode = C.ValClass AND B.SchId=C.SchId
		IF EXISTS (SELECT * FROM @Temp_KeyAttrDt)
		BEGIN
			DELETE FROM SchemeRetAttr WHERE AttrType=8 AND SchId IN (SELECT DISTINCT SchId FROM @Temp_KeyAttrDt)
			INSERT INTO SchemeRetAttr
			SELECT DISTINCT SchID,8,RtrId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121)
			FROM @Temp_KeyAttrDt
		END
		IF EXISTS (SELECT * FROM @Temp_KeyAttrDt)
		BEGIN
			DELETE FROM Etl_Prk_SchemeAttribute_Temp WHERE AttrType=8 AND CmpSchCode IN  (SELECT DISTINCT SchId FROM @Temp_KeyAttrDt)
			INSERT INTO Etl_Prk_SchemeAttribute_Temp
			SELECT DISTINCT SchID,8,RtrId,'N' FROM @Temp_KeyAttrDt
		END
	END
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_Cs2Cn_Retailer_RetailerUpload' AND TYPE='P')
DROP PROCEDURE Proc_Cs2Cn_Retailer_RetailerUpload
GO
/*
BEGIN TRAN
--SELECT 'Approval Track Before upload',* from RetailerApprovalStatus
DELETE FROM CS2CN_RetailerReupload_New
EXEC Proc_Cs2Cn_Retailer_RetailerUpload 0,'2019-06-08'
select * from  CS2CN_RetailerReupload_New
--SELECT 'Approval Track After upload',* FROM RetailerApprovalStatus
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Cs2Cn_Retailer_RetailerUpload
(
	@Po_ErrNo	INT OUTPUT,
	@ServerDate DATETIME
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE	: Proc_Cs2Cn_Retailer 0,'2016-11-11'
* PURPOSE	: Extract Retailer Details from CoreStocky to Console
* NOTES		:
* CREATED	: Nandakumar R.G 09-01-2009
* MODIFIED	:
* DATE         AUTHOR       CR/BZ	   USER STORY ID   DESCRIPTION                         
*****************************************************************************************************
  10/05/2018   S.Moorthi     CR        CRCRSTPAR0001   Retailer Approval process - Manual
*********************************/
DECLARE @CmpID 		AS INTEGER
DECLARE @DistCode	As nVarchar(50)
	
SET @Po_ErrNo=0

RETURN

DELETE FROM CS2CN_RetailerReupload_New WHERE UploadFlag = 'Y'
IF (SELECT DATEDIFF(MONTH,PROCDate,GETDATE()) FROM DayendProcess WHERE ProcDesc ='Retailer_NP')>0
BEGIN

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO CS2CN_RetailerReupload_New
	(
		DistCode ,
		RtrId ,
		RtrCode ,
		CmpRtrCode,
		RtrName ,
		RtrAddress1,
		RtrAddress2,
		RtrAddress3,
		RtrPINCode,
		RtrCategoryCode ,
		ClassCode ,
		Status,
		KeyAccount,
		RelationStatus,
		ParentCode,
		RtrRegDate,
		GeoLevel,
		GeoLevelValue,
		VillageId,
		VillageCode,
		VillageName,
		Mode,
        DrugLNo,
        RtrFrequency,
        RtrPhoneNo,
        RtrTINNumber,
        RtrTaxGroupCode,
        RtrCrLimit,
        RtrCrDays,
        Approved,
        RtrType,
		UploadFlag,
		UniqueRtrCode,
		ApprovalRemarks	
	)
	SELECT
		@DistCode ,
		R.RtrId ,
		R.RtrCode ,
		R.CmpRtrCode ,
		R.RtrName ,
		R.RtrAdd1 ,
		R.RtrAdd2 ,
		R.RtrAdd3 ,
		R.RtrPinNo ,
		'' CtgCode ,
		'' ValueClassCode ,
		RtrStatus,	
		CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,
		CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,
		(CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','New',R.RtrDrugLicNo,
		CASE RtrFrequency WHEN 0 THEN 'WEEKLY' WHEN 1 THEN 'BI-WEEKLY' WHEN 2 THEN 'FORT NIGHTLY' when 3 then 'MONTHLY' when 4 then 'DAILY' END AS RtrFrequency,
		ISNULL(RtrPhoneNo,''),ISNULL(RtrTINNo,''),ISNULL(TGS.RtrGroup,''),R.RtrCrLimit,
        R.RtrCrDays,(CASE ISNULL(R.Approved,0) WHEN 0 THEN 'PENDING' WHEN 1 THEN 'APPROVED' ELSE 'REJECTED' END) AS Approved,
        (CASE R.RtrType WHEN 1 THEN 'Retailer' WHEN 2 THEN 'Sub Stockist' WHEN 3 THEN 'Hub' WHEN 4 THEN 'Spoke' ELSE 'Distributor' END) AS RtrType,
        'N'	,RtrUniqueCode,''				
	FROM		
		Retailer R
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
		LEFT OUTER JOIN TaxGroupSetting TGS (NOLOCK) ON R.TaxGroupId = TGS.TaxGroupId AND TGS.TaxGroup = 1
	
		
	UPDATE ETL SET ETL.[RtrCategoryCode]=RVC.GroupCode,ETL.ClassCode=RVC.ValueClassCode
	FROM CS2CN_RetailerReupload_New ETL,
	(
		SELECT R.RtrId,RC1.CtgCode AS ChannelCode,RC.CtgCode  AS GroupCode ,RVC.ValueClassCode
		FROM
		RetailerValueClassMap RVCM ,
		RetailerValueClass RVC	,
		RetailerCategory RC ,
		RetailerCategoryLevel RCL,
		RetailerCategory RC1,
		Retailer R  		
	WHERE
		R.Rtrid = RVCM.RtrId
		AND	RVCM.RtrValueClassId = RVC.RtrClassId
		AND	RVC.CtgMainId=RC.CtgMainId
		AND	RCL.CtgLevelId=RC.CtgLevelId
		AND	RC.CtgLinkId = RC1.CtgMainId
	) AS RVC
	WHERE ETL.RtrId=RVC.RtrId
	
	UPDATE ETL SET ETL.GeoLevel=Geo.GeoLevelName,ETL.GeoLevelValue=Geo.GeoName
	FROM CS2CN_RetailerReupload_New ETL,
	(
		SELECT R.RtrId,ISNULL(GL.GeoLevelName,'City') AS GeoLevelName,
		ISNULL(G.GeoName,'') AS GeoName
		FROM			
		Retailer R  		
		LEFT OUTER JOIN Geography G ON R.GeoMainId=G.GeoMainId
		LEFT OUTER JOIN GeographyLevel GL ON GL.GeoLevelId=G.GeoLevelId
	) AS Geo
	WHERE ETL.RtrId=Geo.RtrId	
	
	UPDATE ETL SET ETL.VillageId=V.VillageId,ETL.VillageCode=V.VillageCode,ETL.VillageName=V.VillageName
	FROM CS2CN_RetailerReupload_New ETL,
	(
		SELECT R.RtrId,R.VillageId,V.VillageCode,V.VillageName
		FROM			
		Retailer R  		
		INNER JOIN RouteVillage V ON R.VillageId=V.VillageId
	) V
	WHERE ETL.RtrId=V.RtrId	
	
	--Added By MohanaKrishna A.B For GST
	Update CS2CN_RetailerReupload_New SET StateName='' where StateName is Null
	Update CS2CN_RetailerReupload_New SET GSTTIN ='' where GSTTIN is Null
	Update CS2CN_RetailerReupload_New SET PanNumber ='' where PanNumber is Null
	Update CS2CN_RetailerReupload_New SET RetailerType ='' where RetailerType is Null
	Update CS2CN_RetailerReupload_New SET Composite ='' where Composite is Null
	Update CS2CN_RetailerReupload_New SET RelatedParty ='' where RelatedParty is Null
	----
	
	--Added By Mohana For GST
	SELECT C.MasterRecordId,B.ColumnName,ISNULL(C.ColumnValue,'') ColumnValue INTO #RtrUDC FROM UdcHD A INNER JOIN UdcMaster B ON A.MasterId=B.MasterId AND A.MasterName='Retailer Master'
	INNER JOIN UdcDetails C ON A.MasterId= C.MasterId AND B.UdcMasterId=C.UdcMasterId --AND masterrecordid =445
	INNER JOIN Retailer R ON R.RtrId =C.MasterRecordId AND B.ColumnName IN ('State name','GSTIN','PAN Number','Retailer Type','Related Party','Composition')
	UPDATE A SET StateName =ISNULL(C.ColumnValue,'') FROM CS2CN_RetailerReupload_New A INNER JOIN Retailer B ON A.RtrCode=B.RtrCode
	INNER JOIN #RtrUDC C ON B.RtrId = C.MasterRecordid AND ColumnName ='State Name'
	UPDATE A SET GSTTIN = ISNULL(C.ColumnValue,'')  FROM CS2CN_RetailerReupload_New A INNER JOIN Retailer B ON A.RtrCode=B.RtrCode
	INNER JOIN #RtrUDC C ON B.RtrId = C.MasterRecordid AND ColumnName ='GSTIN'
	UPDATE A SET PanNumber = ISNULL(C.ColumnValue,'')  FROM CS2CN_RetailerReupload_New A INNER JOIN Retailer B ON A.RtrCode=B.RtrCode
	INNER JOIN #RtrUDC C ON B.RtrId = C.MasterRecordid AND ColumnName ='PAN Number'
	UPDATE A SET RetailerType = ISNULL(C.ColumnValue,'') FROM CS2CN_RetailerReupload_New A INNER JOIN Retailer B ON A.RtrCode=B.RtrCode
	INNER JOIN #RtrUDC C ON B.RtrId = C.MasterRecordid AND ColumnName ='Retailer Type'
	UPDATE A SET RelatedParty = ISNULL(C.ColumnValue,'')  FROM CS2CN_RetailerReupload_New A INNER JOIN Retailer B ON A.RtrCode=B.RtrCode
	INNER JOIN #RtrUDC C ON B.RtrId = C.MasterRecordid AND ColumnName ='Related Party'
	UPDATE A SET Composite = ISNULL(C.ColumnValue,'')  FROM CS2CN_RetailerReupload_New A INNER JOIN Retailer B ON A.RtrCode=B.RtrCode
	INNER JOIN #RtrUDC C ON B.RtrId = C.MasterRecordid AND ColumnName ='Composition'
	--Till Here
	
	--Added By S.Moorthi	
	SELECT R.RtrId,RC1.CtgCode AS ChannelCode,RC.CtgCode  AS GroupCode,RVC.ValueClassCode 
	INTO #TempCategory	
			FROM
			RetailerValueClass RVC	,
			RetailerCategory RC ,
			RetailerCategoryLevel RCL,
			RetailerCategory RC1,		
			RetailerApprovalStatus R
		WHERE			
			R.RtrClassId = RVC.RtrClassId
			AND	RVC.CtgMainId=RC.CtgMainId
			AND	RCL.CtgLevelId=RC.CtgLevelId
			AND	RC.CtgLinkId = RC1.CtgMainId
			AND ISNULL(R.RtrClassId,0)<>0
			AND R.Upload=0
			
	UPDATE ETL SET ETL.RtrCategoryCode=RVC.GroupCode,ETL.ClassCode=RVC.ValueClassCode
	FROM CS2CN_RetailerReupload_New ETL (NOLOCK) 
	INNER JOIN RetailerApprovalStatus RAS (NOLOCK) ON ETL.RtrId=RAS.RtrId 
	INNER JOIN #TempCategory RVC ON RVC.RtrId=ETL.RtrId and RVC.RtrId=RAS.RtrId
	WHERE ETL.UploadFlag='N' AND RAS.Upload=0
	
	UPDATE ETL SET ETL.GeoLevel=Geo.GeoLevelName,ETL.GeoLevelValue=Geo.GeoName
	FROM CS2CN_RetailerReupload_New ETL,
	(
		SELECT R.RtrId,ISNULL(GL.GeoLevelName,'City') AS GeoLevelName,
		ISNULL(G.GeoName,'') AS GeoName
		FROM			
		Retailer R  	
		INNER JOIN RetailerApprovalStatus RAS (NOLOCK) ON R.RtrId=RAS.RtrId 	
		LEFT OUTER JOIN Geography G ON R.GeoMainId=G.GeoMainId
		LEFT OUTER JOIN GeographyLevel GL ON GL.GeoLevelId=G.GeoLevelId
		WHERE ISNULL(RAS.Geoid,0)<>0  AND RAS.Upload=0
	) AS Geo
	WHERE ETL.RtrId=Geo.RtrId
	UPDATE CS2CN_RetailerReupload_New SET Mode = 'CR' WHERE ISNULL(Approved,'PENDING') IN ('APPROVED') AND Mode = 'New' AND UploadFlag='N'
	UPDATE CS2CN_RetailerReupload_New SET Mode = 'New' WHERE ISNULL(Approved,'PENDING') IN ('PENDING','REJECTED') AND UploadFlag='N'
	--Till Here

	UPDATE CS2CN_RetailerReupload_New SET ServerDate=@ServerDate
	UPDATE DayEndProcess SET NextUpDate = GETDATE(),ProcDate = GETDATE() WHERE ProcDesc = 'Retailer_NP'
	END
	IF NOT EXISTS (SELECT * FROM DayendProcess WHERE ProcDesc ='Retailer_NP')
	BEGIN
		INSERT INTO DayendProcess
		SELECT DATEADD(MONTH,-1,GETDATE()),19,GETDATE(),'Retailer_NP'
	END
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Cs2Cn_DebitNoteTopSheet2' AND TYPE ='P')
DROP PROCEDURE Proc_Cs2Cn_DebitNoteTopSheet2
GO
/*      
Begin transaction              
EXEC Proc_Cs2Cn_DebitNoteTopSheet2 0,'2019-03-29'      
select *from Cs2Cn_Prk_DebitNoteTopSheet2 -- where cmpschcode ='SCH18547'    
--select *from cs2console_consolidated where column3 ='SCH13813' and processname like '%debitnote%'    
Rollback Transaction   
*/      
CREATE PROCEDURE Proc_Cs2Cn_DebitNoteTopSheet2     
(      
 @Po_ErrNo INT OUTPUT,      
 @ServerDate DATETIME      
)      
AS      
/*********************************      
* PROCEDURE  : Proc_Cs2Cn_DebitNoteTopSheet2       
* PURPOSE  : To Extract LMISDetails      
* CREATED BY : Aravindh Deva C      
* CREATED DATE : 03.06.2016      
* NOTE   :       
------------------------------------------------      
* {date} {developer}  {brief modification description}      
*************************************************      
* [DATE]      [DEVELOPER]      [USER_STORY_ID]   [CR/BUG]       [DESCRIPTION]      
* 26-12-2017  S.MOORTHI  CR      ICRSTPAR7182                 Date Wise Data Upload(TransDate)    
* 18-12-2017  Lakshman. M        ICRSTPAR7106        BUG      Scheme id validation missing.Script validation added from CS.    
* 13-07-2018  Lakshman M         ILCRSTPAR1254       BZ       Report caluculation included for upload process debit note top sheet2 from CS.    
* 25/07/2018  Lakshman M         ILCRSTPAR1496       BZ       scheme code valdiation included from CS.   
* 29-03-2019  Lakshman M         ILCRSTPAR3860       BZ       upload process scheme wsie and transaction wsie scheme utilization amount validation included. 
*************************************************/      
SET NOCOUNT ON      
BEGIN      
  SET @Po_ErrNo=0      
  DECLARE @DistCode As NVARCHAR(50)      
  DELETE FROM Cs2Cn_Prk_DebitNoteTopSheet2 WHERE UploadFlag = 'Y'      
   IF NOT EXISTS (SELECT * FROM UploadingReportTransaction (NOLOCK))      
   BEGIN      
    RETURN      
   END      
      
  SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)       
  DECLARE @FromDate DATETIME      
  DECLARE @ToDate DATETIME      
  --ICRSTPAR7182    
 --SELECT @FromDate = MIN(SchValidFrom),@ToDate = MAX(SchValidTill) FROM SchemeMaster S (NOLOCK)    
 --WHERE EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate BETWEEN S.SchValidFrom AND S.SchValidTill)    
     
  SELECT @FromDate = MIN(TransDate),@ToDate = MAX(TransDate) FROM UploadingReportTransaction S (NOLOCK)    
 --ICRSTPAR7182 till here      
     
 EXEC Proc_SchUtilization_Report @FromDate , @ToDate  
  EXEC Proc_ReturnSalesProductTaxPercentage @FromDate , @ToDate     
  SELECT * INTO #ParleOutputTaxPercentage  FROM ParleOutputTaxPercentage (NOLOCK)   
     
  DECLARE @SlNo AS INT      
  SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'     
 ------------------ added by Lakshman M dated on 13/07/2018 Pms ID: ILCRSTPAR1254 ------------    
 --------------------- Added By Lakshman M Dated on 25/07/2018 PMS ID: ILCRSTPAR1496 ---------------    
 
  SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,        
  B.DefaultPriceId ActualPriceId,SP.SlNo,sp.PrdTaxAmount,PrdUnitSelRate,PrdBatDetailValue,D.Schid        
  INTO #BillingDetails        
  FROM SalesInvoice S (NOLOCK)        
  INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId        
  INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId     
  INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1     
  INNER JOIN Debitnote_Scheme D ON D.Salid = S.SalId AND SP.SalId = D.Salid AND D.Prdid =SP.PrdID AND D.linetype = 1    
  WHERE S.SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3 and PBD.SLNo =3    
           
  SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,        
  B.DefaultPriceId,SP.SlNo,SP.PrdEditSelRte,sp.PrdTaxAmt as prdtaxamount,PrdUnitSelRte as  PrdUnitSelRate,PrdBatDetailValue,D.Schid        
  INTO #ReturnDetails        
  FROM ReturnHeader S (NOLOCK)        
  INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID        
  INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId        
  INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1    
  INNER JOIN Debitnote_Scheme D ON D.Salid = S.ReturnID AND SP.ReturnID = D.Salid  AND D.linetype = 2    
  WHERE S.ReturnDate BETWEEN  @FromDate AND @ToDate AND S.[Status] = 0 and PBD.SLNo =3    
         
  SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,CAST (0 AS NUMERIC(18,6)) AS ActualSellRate,prdtaxamount,    
  PrdBatDetailValue as PrdUnitSelRate ,Schid ,    
  CAST (0 AS NUMERIC(18,6)) AS LCTR      
  INTO #DebitSalesDetails        
  FROM         
  (        
  SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,prdtaxamount,PrdBatDetailValue , schid FROM #BillingDetails       
  UNION ALL        
  SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,DefaultPriceId ,SlNo,prdtaxamount,PrdBatDetailValue, schid  FROM #ReturnDetails        
  ) Consolidated     
 ------------------------- Till Here ----------------    
  UPDATE M SET M.ActualSellRate = round(D.PrdBatDetailValue,2)        
  FROM #DebitSalesDetails M (NOLOCK),        
  ProductBatchDetails D (NOLOCK)         
  WHERE M.ActualPriceId = D.PriceId AND D.SLNo = 3     
  UPDATE R SET R.LCTR = ROUND(((R.BaseQty *(R.PrdUnitSelRate))+(R.BaseQty*R.PrdUnitSelRate)*(T.TaxPerc/100)),2)          
  FROM #DebitSalesDetails R (NOLOCK),        
  #ParleOutputTaxPercentage T (NOLOCK)    
  WHERE R.SalId = T.Salid AND R.Slno = T.PrdSlno AND T.TransId = R.TransType      
      
  --------------------- Till Here ----------------        
  CREATE TABLE #ApplicableProduct      
  (      
   SchId  INT,      
   PrdId   INT      
  )    
   ----------------- added by lakshman M on 21-12-2017 sales invoice scheme added --------------      
 INSERT INTO #ApplicableProduct(SchId,PrdId)    
 SELECT DISTINCT A.SchId,B.Prdid    
  FROM SchemeMaster A    
  INNER JOIN SchemeProducts B ON A.Schid = B.Schid    
  INNER JOIN Product C On B.Prdid = C.PrdId    
  WHERE A.SchemeLvlMode = 0 AND B.PrdId <> 0    
 UNION ALL    
 SELECT DISTINCT A.SchId,E.Prdid    
  FROM SchemeMaster A    
  INNER JOIN SchemeProducts B ON A.Schid = B.Schid    
  INNER JOIN ProductCategoryValue C ON     
  B.PrdCtgValMainId = C.PrdCtgValMainId     
  INNER JOIN ProductCategoryValue D ON    
  D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'    
  INNER JOIN Product E On    
  D.PrdCtgValMainId = E.PrdCtgValMainId     
  INNER JOIN ProductBatch F On    
  F.PrdId = E.Prdid    
  WHERE A.SchemeLvlMode = 0 AND B.PrdCtgValMainId <> 0    
 UNION ALL    
 SELECT DISTINCT S.SchId,B.MasterRecordId    
  FROM SchemeProducts A     
  INNER JOIN UdcDetails B on B.UDCUniqueId =A.PrdCtgValMainId     
  INNER JOIN SchemeMaster S ON A.SchId = S.SchId    
  WHERE S.SchemeLvlMode = 1    
      
  --added by mohana ILCRSTPAR0500     
 INSERT INTO #ApplicableProduct(SchId,PrdId)    
 SELECT Schid ,PrdId FROM SchemeMasterControlHistory A INNER JOIN SchemeMaster B ON A.CmpSchCode = B.CmpSchCode    
 INNER JOIN Product C ON c.PrdCCode = A.FromValue    
 WHERE ChangeType='Remove'   AND B.SchId in (SELECT SchId FROM SchemeProducts Where PrdCtgValMainId = 0)    
     
 INSERT INTO #ApplicableProduct(SchId,PrdId)      
 SELECT DISTINCT A.SchId,E.Prdid    
 FROM SchemeMaster A    
 INNER JOIN SchemeMasterControlHistory B ON A.CmpSchCode = B.CmpSchCode    
 INNER JOIN ProductCategoryValue C ON     
 B.FromValue = C.PrdCtgValCode    
 INNER JOIN ProductCategoryValue D ON    
 D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'    
 INNER JOIN Product E On    
 D.PrdCtgValMainId = E.PrdCtgValMainId     
 INNER JOIN ProductBatch F On    
 F.PrdId = E.Prdid    
 WHERE A.SchemeLvlMode = 0  AND A.SchId in (SELECT SchId FROM SchemeProducts Where PrdId = 0 )    
 AND ChangeType='Remove'      
 --------------- Tille Here --------------    
  CREATE TABLE #ApplicableScheme      
  (      
   SchId   INT,      
   CmpSchCode  NVARCHAR(100),      
   SchValidFrom DATETIME,       SchValidTill DATETIME,       
   Budget   NUMERIC(18,2),      
   BudgetAllocationNo VARCHAR(100),      
   PrdId INT      
  )    
 ------------- added by M. Lakshman dated on 18-12-2017 ----- Scheme id validation ----------       
 INSERT INTO #ApplicableScheme (SchId,CmpSchCode,SchValidFrom,SchValidTill,Budget,BudgetAllocationNo,PrdId)       
 SELECT DISTINCT A.SchId,S.cmpschcode,S.SchValidFrom,S.SchValidTill,S.Budget,S.BudgetAllocationNo, A.PrdId    
 FROM #ApplicableProduct A (NOLOCK),    
 SchemeMaster S (NOLOCK)    
 WHERE A.SchId = S.SchId AND A.SchId  IN (SELECT SCHID FROM Debitnote_Scheme)     
 AND S.Claimable = 1    
  
  
  SELECT  S.SchId,B.transdate,B.TransType,SM.CmpSchCode,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,    
 SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,    
 CAST(0 AS NUMERIC(18,6)) Amount    
 INTO #SchemeDebit1    
 FROM #ApplicableScheme S (NOLOCK),    
 #DebitSalesDetails B (NOLOCK) ,Debitnote_Scheme D ,    
 SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana    
 WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=1 AND  B.Schid = D.Schid  AND SM.Schid = D.Schid AND    
 d.sCHID = s.sCHID and s.PRDID = D.PRDID AND b.PrdId = D.PRDID  and b.sALID = d.sALID AND Linetype = 1 AND     
 --PMS NO:ILCRSTPAR0909    
 --S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 --AND S.SchValidTill  BETWEEN @FromDate AND @ToDate    
 --(S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 --or S.SchValidTill  BETWEEN @FromDate AND @ToDate)    
 (B.Transdate BETWEEN @FromDate AND @ToDate    
 or B.Transdate  BETWEEN @FromDate AND @ToDate)    
 GROUP BY S.SchId,SM.cmpschcode,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,B.transdate,B.TransType    
 ORDER BY S.SchId    
 INSERT INTO #SchemeDebit1    
 SELECT  S.SchId,B.transdate,B.TransType ,SM.Cmpschcode,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,    
 SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,    
 CAST(0 AS NUMERIC(18,6)) Amount    
 FROM #ApplicableScheme S (NOLOCK),    
 #DebitSalesDetails B (NOLOCK) ,Debitnote_Scheme D,    
 SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana    
 WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=2 AND  B.Schid = D.Schid  AND SM.Schid = D.Schid AND   Linetype = 2 AND    
 d.sCHID = s.sCHID and s.PRDID = D.PRDID AND b.PrdId = D.PRDID  and b.sALID = d.sALID AND  S.SchId =B.SchId AND B.SchId =SM.SchId and     
 --PMSNo:ILCRSTPAR0909    
 --S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 --AND S.SchValidTill  BETWEEN @FromDate AND @ToDate    
 --(S.SchValidFrom BETWEEN @FromDate AND @ToDate    
 --or S.SchValidTill  BETWEEN @FromDate AND @ToDate)    
 (B.Transdate BETWEEN @FromDate AND @ToDate    
 or B.Transdate  BETWEEN @FromDate AND @ToDate)    
 GROUP BY S.SchId,SM.cmpschcode,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,B.transdate,B.TransType    
 ORDER BY S.SchId    
  INSERT INTO #SchemeDebit1    
 SELECT  S.SchId,B.transdate,B.TransType ,SM.CmpSchCode,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo, CircularDate,    
 SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,    
 CAST(0 AS NUMERIC(18,6)) Amount    
 FROM #ApplicableScheme S (NOLOCK),    
 #DebitSalesDetails B (NOLOCK) ,    
 SchemeMaster SM LEFT Outer JOIN SchemeCirculardetails SC ON SM.CmpSchCode=SC.CmpSchcode-- added By Mohana    
 ,Debitnote_Scheme D       
 WHERE S.PrdId = B.PrdId AND S.SchId=SM.SchId  and Transtype=2      
 AND S.Schid = D.Schid AND B.Prdid =D.Prdid AND B.Salid =D.Salid     
 AND S.SchId NOT IN (SELECT schid FROM #SchemeDebit1) AND Linetype = 2    
 GROUP BY S.SchId,SM.CmpSchCode,S.SchValidFrom,S.SchValidTill,SC.SchemeBudget,CircularNo,CircularDate,B.transdate,B.TransType    
 ORDER BY S.SchId    
 SELECT  SchId,transdate,CmpSchCode,SchValidFrom,SchValidTill,SchemeBudget,CircularNo, CircularDate,    
 SUM(SecSalesQty) SecSalesQty,CAST(SUM(SecSalesVal) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,6)) Liab,    
 CAST(0 AS NUMERIC(18,6)) Amount,CASE TransType WHEN 1 THEN 'Sales' WHEN 2 THEN 'Sales Return' END TransType    
 INTO #SchemeDebit from #SchemeDebit1      
 GROUP BY SchId,CmpSchCode,SchValidFrom,SchValidTill,SchemeBudget,CircularNo, CircularDate,transdate,TransType    
  ----------------- Till here --------------     
  --SELECT S.SchId,B.TransDate,S.CmpSchCode,S.SchValidFrom,S.SchValidTill,S.Budget,S.BudgetAllocationNo,      
  --SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,6)) [SecSalesVal],CAST(0 AS NUMERIC(18,2)) Liab,      
  --CAST(0 AS NUMERIC(18,2)) Amount , CASE TransType WHEN 1 THEN 'Sales' WHEN 2 THEN 'Sales Return' END TransType    
  --INTO #SchemeDebit      
  --FROM #ApplicableScheme S (NOLOCK),    
  --#DebitSalesDetails B (NOLOCK)       
  --WHERE S.PrdId = B.PrdId AND B.TransDate BETWEEN S.SchValidFrom AND S.SchValidTill      
  --GROUP BY S.SchId,S.CmpSchCode,S.SchValidFrom,S.SchValidTill,Budget,BudgetAllocationNo,B.TransDate,TransType    
  --ORDER BY S.SchId    
  --Commented and Added by Mohana ICRSTPAR6760    
  --UPDATE SD SET SD.Amount = DBO.Fn_ReturnBudgetUtilized(SD.SchId)      
  --FROM #SchemeDebit SD (NOLOCK)    
     
 ---- UPDATE SD SET SD.Amount = DBO.Fn_ReturnBudgetUtilized_scheme(SD.SchId,@FromDate,@ToDate)       
 ---- FROM #SchemeDebit SD (NOLOCK)      
 ---- UPDATE SD SET SD.Liab = CAST(( SD.Amount / SD.[SecSalesVal]) AS NUMERIC(18,2))      
 ---- FROM #SchemeDebit SD (NOLOCK)      
 ---- WHERE SD.[SecSalesVal] <> 0    
 ---- UPDATE SD SET SD.Liab = CAST(( SD.Amount / SD.[SecSalesVal]) AS NUMERIC(18,6))    
 ----FROM #SchemeDebit SD (NOLOCK)    
 ----WHERE SD.[SecSalesVal] <> 0 ---------  
 -------------------  Added by lakshman M dated on 29-03-2019 PMS ID: ILCRSTPAR3860 ----
  SELECT DISTINCT TaxPerc,B.SalId,B.PrdId  INTO #TaxPerc FROM SalesInvoiceProduct B   
  INNER JOIN ParleOutputTaxPercentage P ON P.SalId = B.SalId and  B.SlNo = P.PrdSlno AND TRANSID = 1   
  --Till Here   
    
	
  SELECT salid,Schid,SUM(Schamt) SchAmt ,Sum(taxamt) TaxAmt INTO #SchFinal 
  FROM   
  (  
  SELECT salid,A.SchId,SUM(A.schamt) SchAmt, (SUM(A.schamt)*(TaxPerc/100)) TaxAmt   
   FROM (  
  --ILCRSTPAR2868  
  --SELECT Schid ,a.PRDID,TaxPerc,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt FROM Debitnote_Scheme A   
  --INNER JOIN SalesInvoiceProduct B ON A.Salid = b.SalId AND a.Prdid = b.PrdId    
  --INNER JOIN ParleOutputTaxPercentage P ON P.SalId = B.SalId AND A.Salid = P.SalId AND B.SlNo = P.PrdSlno AND TRANSID = 1 AND Linetype = 1  
  --GROUP BY  A.PRDID,A.SchId,TaxPerc  
  SELECT  A.salid,Schid ,a.PRDID,TaxPerc,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt FROM Debitnote_Scheme A   
  INNER JOIN #TaxPerc B ON A.Salid = b.SalId AND a.Prdid = b.PrdId AND Linetype = 1 -- where   schid = 1983    
  GROUP BY  A.PRDID,A.SchId,TaxPerc,A.salid 
  --Till Here  
  )A  
  GROUP BY A.SchId,TaxPerc,salid  
  )B Group by  sCHID,salid   
  
  insert into #SchFinal  
  SELECT salid,Schid,SUM(Schamt) SchAmt ,Sum(taxamt) TaxAmt FROM   
  (  
  SELECT A.salid,A.SchId,SUM(A.schamt) SchAmt, (SUM(A.schamt)*(TaxPerc/100)) TaxAmt      
  FROM (  
  SELECT A.salid,Schid ,a.PRDID,TaxPerc,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt   
  FROM Debitnote_Scheme A INNER JOIN RETURNPRODUCT B ON A.Salid = b.ReturnID AND a.Prdid = b.PrdId   
  INNER JOIN ParleOutputTaxPercentage P ON P.SalId = B.ReturnID AND A.Salid = P.SalId AND B.SlNo = P.PrdSlno AND TRANSID = 2 AND a.Linetype =2  
  and StockTypeId IN (SELECT StockTypeId FROM STOCKTYPE WHERE SystemStockType = 1) 
  GROUP BY  A.PRDID,A.SchId,TaxPerc,A.salid  
  )A  
  GROUP BY A.SchId,TaxPerc,salid 
  )B Group by  sCHID,salid   
   
 
	SELECT DISTINCT  SALINVDATE,SD.SCHID,CASE S.APPLYTAXFORCLAIM WHEN 0 THEN SCHAMT ELSE  (SCHAMT+TAXAMT) END AS SCHAMT INTO #SCHTAXFINAL
	FROM #SCHEMEDEBIT SD (NOLOCK) INNER JOIN (SELECT DISTINCT SALINVDATE ,SCHID,SUM(SCHAMT) SCHAMT ,SUM(TAXAMT) TAXAMT FROM  #SCHFINAL A INNER JOIN SALESINVOICE S ON A.SALID =S.SALID  
	GROUP BY SCHID,SALINVDATE) D  ON SD.SCHID = D.SCHID --CHANGED FOR CLAIMAMTMISMATCH  
	INNER JOIN SCHEMEMASTER S ON S.SCHID = D.SCHID AND S.SCHID = SD.SCHID AND SD.TRANSDATE=D.SALINVDATE --WHERE  SD.SCHID = 1983 
	
	SELECT DISTINCT  Returndate,SD.SCHID,CASE S.APPLYTAXFORCLAIM WHEN 0 THEN SCHAMT ELSE  (SCHAMT+TAXAMT) END AS SCHAMT INTO #SCHTAXFINAL1
	FROM #SCHEMEDEBIT SD (NOLOCK) INNER JOIN (SELECT DISTINCT Returndate ,SCHID,SUM(SCHAMT) SCHAMT ,SUM(TAXAMT) TAXAMT FROM  #SCHFINAL A
	 INNER JOIN ReturnHeader 
	 S ON A.SALID =S.ReturnID ANd a.SchAmt <0   
	GROUP BY SCHID,Returndate) D  ON SD.SCHID = D.SCHID --CHANGED FOR CLAIMAMTMISMATCH  
	INNER JOIN SCHEMEMASTER S ON S.SCHID = D.SCHID AND S.SCHID = SD.SCHID AND SD.TRANSDATE=D.Returndate --WHERE  SD.SCHID = 1983 
   
	UPDATE SD SET SD.AMOUNT = D.SCHAMT
	FROM #SCHEMEDEBIT SD (NOLOCK) INNER JOIN #SCHTAXFINAL D  ON SD.SCHID = D.SCHID --CHANGED FOR CLAIMAMT MISMATCH  
	INNER JOIN SCHEMEMASTER S ON S.SCHID = D.SCHID AND S.SCHID = SD.SCHID  
	AND D.SALINVDATE=SD.TRANSDATE
	
	
	UPDATE SD SET SD.AMOUNT = D.SCHAMT
	FROM #SCHEMEDEBIT SD (NOLOCK) INNER JOIN #SCHTAXFINAL1 D  ON SD.SCHID = D.SCHID --CHANGED FOR CLAIMAMT MISMATCH  
	INNER JOIN SCHEMEMASTER S ON S.SCHID = D.SCHID AND S.SCHID = SD.SCHID  
	AND D.ReturnDate=SD.TRANSDATE
	
	------------------------ till here PMS ID: ILCRSTPAR3860 ---------------
	  
 --UPDATE SD SET SD.Amount = schamt    
 --FROM #SchemeDebit SD (NOLOCK) INNER JOIN (SELECT Schid ,Salinvdate ,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt    
 --FROM Debitnote_Scheme where Linetype = 1  group by Schid,Salinvdate )D  ON SD.Schid = D.Schid AND SD.TransDate =D.Salinvdate    
 --ANd transType = 'Sales'    
     
 --UPDATE SD SET SD.Amount = schamt    
 --FROM #SchemeDebit SD (NOLOCK) INNER JOIN (SELECT Schid ,Salinvdate ,SUM (FlatAmount+DiscountPer+FreeValue+GiftValue)schamt    
 --FROM Debitnote_Scheme where Linetype = 2  group by Schid,Salinvdate)D  ON SD.Schid = D.Schid AND SD.TransDate =D.Salinvdate    
 --ANd transType = 'Sales Return'  
     
 UPDATE SD SET SD.Liab = CAST(( SD.Amount / SD.[SecSalesVal]) AS NUMERIC(18,6))    
 FROM #SchemeDebit SD (NOLOCK)    
 WHERE SD.[SecSalesVal] <> 0    

  INSERT INTO Cs2Cn_Prk_DebitNoteTopSheet2 (DistCode,CmpSchCode,SecSalesQty,SecSalesVal,Liab,Amount,      
  UploadFlag,SyncId,ServerDate,TransDate,TransType)      
  SELECT @DistCode,CmpSchCode,[SecSalesQty],[SecSalesVal],Liab,Amount,'N' UploadFlag,NULL,@ServerDate,TransDate,TransType    
  FROM #SchemeDebit    
 --ICRSTPAR7182    
 UPDATE A SET UPLOAD=1 FROM DebitNoteTopSheet2Track A(NOLOCK) WHERE Upload=0 and TransDate=@FromDate    
 --ICRSTPAR7182    
 RETURN         
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name ='Proc_Cs2Cn_DebitNoteTopSheet4' AND TYPE ='P')
DROP PROCEDURE Proc_Cs2Cn_DebitNoteTopSheet4
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_DebitNoteTopSheet4 0,'2018-07-26'
select * from Cs2Cn_Prk_DebitNoteTopSheet4 order by slno
Rollback Transaction 
*/
CREATE PROCEDURE Proc_Cs2Cn_DebitNoteTopSheet4
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DebitNoteTopSheet4
* PURPOSE		: To Extract TOT CLAIMS
* CREATED BY	: MOHANA S
* CREATED DATE	: 03-05-2018
* PMS 			: CCRSTPAR0187
* MODIFIED	
*************************************************      
* [DATE]        [DEVELOPER]        [USER_STORY_ID]     [CR/BUG]       [DESCRIPTION]    
* 29-03-2019    Lakshman M         ILCRSTPAR3860       BZ         upload process scheme wsie and transaction wsie scheme utilization amount validation included. 
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @DistCode As NVARCHAR(50) 
	DECLARE @FromDate DATETIME      
	DECLARE @ToDate DATETIME
	
	SELECT @FromDate = MIN(SalInvDate),@ToDate = MAX(SalInvDate) FROM Cs2Cn_Prk_DailySales S (NOLOCK)    
 --ICRSTPAR7182 till here      
      
  EXEC Proc_ReturnSalesProductTaxPercentage @FromDate , @ToDate     
  SELECT * INTO #ParleOutputTaxPercentage  FROM ParleOutputTaxPercentage (NOLOCK)
  
	SET @Po_ErrNo=0
	
	--DECLARE @DistCode As NVARCHAR(50)
	DELETE FROM Cs2Cn_Prk_DebitNoteTopSheet4 WHERE UploadFlag = 'Y'
	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	
	
	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,CASE SP.SplPriceId WHEN 0 THEN 0 ELSE SP.Priceid END As  Priceid,   
	B.DefaultPriceId ActualPriceId,SP.SlNo,sp.PrdTaxAmount,PrdUnitSelRate,PrdBatDetailValue    
	INTO #BillingDetails1    
	FROM SalesInvoice S (NOLOCK)    
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId    
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId 
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1		 
	WHERE SalInvNo in(SELECT DISTINCT salinvno FROM Cs2Cn_Prk_DailySales) AND S.DlvSts > 3 and PBD.SLNo =3
	
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,CASE SP.SplPriceId WHEN 0 THEN 0 ELSE SP.Priceid END As  Priceid,  
	B.DefaultPriceId ActualPriceId,SP.SlNo,SP.PrdEditSelRte,sp.PrdTaxAmt as prdtaxamount,PrdUnitSelRte as  PrdUnitSelRate,PrdBatDetailValue  
	INTO #ReturnDetails1    
	FROM ReturnHeader S (NOLOCK)    
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID AND StockTypeid in (select stocktypeid from  stocktype where systemstocktype =1)   
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId    
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId =B.PrdBatId and DefaultPrice =1
	WHERE ReturnCode IN (SELECT SrNRefNO from Cs2Cn_Prk_Salesreturn) AND S.[Status] = 0 and PBD.SLNo =3
	
	 SELECT DISTINCT R.RtrId,RC.CtgMainId,RC.CtgName  
	 INTO #Retailer  
	 FROM Retailer R (NOLOCK),  
	 RetailerValueClassMap RVCM (NOLOCK),  
	 RetailerValueClass RVC (NOLOCK),  
	 RetailerCategory RC (NOLOCK),  
	 RetailerCategoryLevel RCL (NOLOCK)  
	 WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId  
	 AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId 
	

	 SELECT tranid,Refid,Rtrid,CtgName,RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,SelRate,CAST(0 AS NUMERIC(18,2)) Nrmlrate,CAST(0 AS NUMERIC(18,2)) SplRate,CAST(0 AS NUMERIC(18,2)) Diff,Slno  
	 INTO #TotClaim FROM(  
	 SELECT 1 tranid,Salid Refid,A.Rtrid,CtgName,Salinvdate RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,PrdbatDetailvalue SelRate,Slno FROM #BillingDetails1 A  INNER JOIN #Retailer B ON A.Rtrid = B.Rtrid   
	 UNION   
	 SELECT 2 Transid,ReturnID Refid,A.Rtrid,CtgName,ReturnDate RefDate,Prdid,Prdbatid,BaseQty,Priceid,ActualPriceid,PrdbatDetailvalue SelRate,Slno FROM #ReturnDetails1  A  INNER JOIN #Retailer B ON A.Rtrid = B.Rtrid   
	 )A  
	
	SELECT DISTINCT Priceid,PrdBatDetailValue SplSelRate  INTO #ExistingSpecialPrice FROM
	(
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #TotClaim M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%-Spl Rate-%'   
	UNION 
	SELECT D.PriceId,D.PrdBatDetailValue 
	FROM #TotClaim M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = 3
	AND PriceCode LIKE '%SplRate%'  
	)A   
	----------------------- Added by lakshman M Dated on 29-03-2019 PMS ID: ILCRSTPAR3860 -----------------
  
	-- UPDATE A SET A.SplRate = (BaseQty*B.SplselRate) FROM  #TotClaim A INNER JOIN #ExistingSpecialPrice B ON A.Priceid = B.Priceid WHERE A.Priceid <>0
	
	-- UPDATE A SET A.SplRate = (BaseQty*SelRate) FROM  #TotClaim A WHERE A.Priceid =0
	
	-- UPDATE A SET A.NrmlRate = (BaseQty*SelRate) FROM #TotClaim A  

	--UPDATE A SET A.Diff = (NrmlRate-SplRate) FROM  #TotClaim A  
	 --UPDATE A SET A.SplRate = (BaseQty*B.SplselRate) FROM  #TotClaim A INNER JOIN #ExistingSpecialPrice B ON A.Priceid = B.Priceid WHERE A.Priceid <>0
	 
	 UPDATE A SET A.SplRate = (BaseQty*((B.SplselRate)+(B.SplselRate*(p.TaxPerc/100)))) FROM  #TotClaim A INNER JOIN #ExistingSpecialPrice B  
	 ON A.Priceid = B.Priceid INNER JOIN  ParleOutputtaxPercentage P ON A.Refid = p.salid and A.slno = p.prdslno AND A.Tranid=P.Transid  WHERE A.Priceid <>0  

	 UPDATE A SET A.SplRate = (BaseQty*(( SelRate)+(SelRate*(P.TaxPerc/100)))) FROM  #TotClaim A   
	 INNER JOIN  #ParleOutputtaxPercentage P ON A.Refid = p.salid and a.slno = p.prdslno AND A.Tranid=P.Transid  
	 WHERE A.Priceid =0  
	
	 UPDATE A SET A.NrmlRate = (BaseQty*(( SelRate)+(SelRate*(P.TaxPerc/100)))) FROM  #TotClaim A   
	 INNER JOIN  #ParleOutputtaxPercentage P ON A.Refid = p.salid and a.slno = p.prdslno AND A.Tranid=P.Transid  
    
	 UPDATE A SET A.Diff = (NrmlRate-SplRate) FROM  #TotClaim A  
	 ----------------- Till here -------------------
	INSERT INTO Cs2Cn_Prk_DebitNoteTopSheet4
	SELECT @DistCode,CmpRtrCode,CTGNAME,SalInvNo,SalInvDate,PrdCCode,NRMLRATE ,SPLRATE,DIFF,'N',NULL,@ServerDate FROM
	(
	SELECT R.CmpRtrCode,CTGNAME,B.SalInvNo,B.SalInvDate,P.PrdCCode,SUM(NRMLRATE)NRMLRATE ,SUM(SPLRATE)SPLRATE, SUM(DIFF)  DIFF
	FROM #TotClaim A INNER JOIN SALESINVOICE B ON A.REFID =B.SALID
	INNER JOIN RETAILER R ON A.RTRID = R.RTRID AND B.RTRID =  R.RtrId
	INNER JOIN Product P ON A.PRDID = P.PRDID 
	WHERE Tranid = 1
	GROUP BY R.CmpRtrCode,CTGNAME,B.SalInvNo,B.SalInvDate,P.PrdCCode
	UNION ALL
	SELECT R.CmpRtrCode,CTGNAME,B.RETURNCODE,B.RETURNDATE,P.PrdCCode,SUM(NRMLRATE)NRMLRATE ,SUM(SPLRATE)SPLRATE, SUM(DIFF)  DIFF
	FROM #TotClaim A INNER JOIN ReturnHeader B ON A.REFID =B.RETURNID
	INNER JOIN RETAILER R ON A.RTRID = R.RTRID AND B.RTRID =  R.RtrId
	INNER JOIN Product P ON A.PRDID = P.PRDID 
	WHERE Tranid = 2
	GROUP BY R.CmpRtrCode,CTGNAME,B.RETURNDATE,B.RETURNCODE,P.PrdCCode
	)A
	
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_Cn2Cs_SchemeCategoryDetails' AND TYPE ='P')
DROP PROCEDURE Proc_Cn2Cs_SchemeCategoryDetails
GO
/*
BEGIN TRAN
delete from errorlog
EXEC Proc_Cn2Cs_SchemeCategoryDetails 0
SELECT * FROM ERRoRLOG
SELECT * FROM Cn2Cs_Prk_SchemeCategorydetails 
--SELECT * FROM Schememaster 
ROLLBACK TRAN
*/
CREATE PROCEDURE Proc_Cn2Cs_SchemeCategoryDetails
(
	@Po_ErrNo INT OUTPUT
)
AS
/************************************************************************************************
* PROCEDURE		: Proc_Cn2Cs_SchemeCategoryDetails
* PURPOSE		: To validate the downloaded Scheme Category details from Console
* CREATED		: Lakshman M
* CREATED DATE	: 11-03-2019
* MODIFIED
* DATE       AUTHOR     CR/BZ	USER STORY ID           DESCRIPTION                         
***************************************************************************************************
 11-03-2019  Lakshman M	 CR		CRCRSTPAR0037 			scheme category type validation included from CS.
 24-04-2015  lakshmman M BZ     ILCRSTPAR4149           Duplicate records validation missing for scheme category process in core stocky. 
***************************************************************************************************/
SET NOCOUNT ON
BEGIN
	SET @Po_ErrNo=0
	
	CREATE TABLE #AvoidScheme
	(
		CMpSchcode NVARCHAR(50)
	)

	SELECT CmpSchcode,MAX(Createddate)  Mxdate into  #Duplicate  from Cn2Cs_Prk_SchemeCategorydetails
	GROUP BY  CmpSchcode

	SELECT C.*into #Cn2Cs_Prk_SchemeCategorydetails  from Cn2Cs_Prk_SchemeCategorydetails  C  inner  join  #Duplicate D on C.CmpSchcode=D.CmpSchcode and D.Mxdate=C.CreatedDate
	DELETE FROM  Cn2Cs_Prk_SchemeCategorydetails

	INSERT INTO Cn2Cs_Prk_SchemeCategorydetails
	SELECT * FROM #Cn2Cs_Prk_SchemeCategorydetails
			
	DELETE FROM Cn2Cs_Prk_SchemeCategorydetails WHERE DownLoadFlag='Y'
	
	IF NOT EXISTS(SELECT 'X' FROM Cn2Cs_Prk_SchemeCategorydetails (NOLOCK) WHERE DownLoadFlag='D')
	BEGIN
		RETURN
	END
	 
	INSERT INTO #AvoidScheme
	SELECT CMpSchcode FROM Cn2Cs_Prk_SchemeCategorydetails WHERE CMpSchcode NOT IN (SELECT CmpSchCode FROM SchemeMaster)
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT 1,'Cn2Cs_Prk_SchemeCategorydetails',CmpSchcode,'Scheme Not Available in SchemeMaster' FROM Cn2Cs_Prk_SchemeCircularDetails WHERE CMpSchcode NOT IN (SELECT CmpSchCode FROM SchemeMaster)
	 
	INSERT INTO #AvoidScheme
	SELECT  CmpSchCode as CmpSchcode FROM Cn2Cs_Prk_SchemeCategorydetails
	GROUP BY CmpSchCode HAVING COUNT(CmpSchCode)>1
	
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT 1,'Cn2Cs_Prk_SchemeCategorydetails',CmpSchCode,'Duplicate Cmpschcode Available -'+CmpSchCode  FROM Cn2Cs_Prk_SchemeCategorydetails
	GROUP BY CmpSchCode HAVING COUNT(CmpSchCode)>1

	SELECT 1,'Cn2Cs_Prk_SchemeCategorydetails',CmpSchCode,'Duplicate Cmpschcode Available -'+CmpSchCode  FROM Cn2Cs_Prk_SchemeCategorydetails
	GROUP BY CmpSchCode HAVING COUNT(CmpSchCode)>1
	

	SELECT 1,'Cn2Cs_Prk_SchemeCategorydetails',CmpSchCode,'Duplicate Cmpschcode Available -'+CmpSchCode  FROM Cn2Cs_Prk_SchemeCategorydetails
	GROUP BY CmpSchCode HAVING COUNT(CmpSchCode)>1

	DELETE A FROM SchemeCategorydetails A INNER join Cn2Cs_Prk_SchemeCategorydetails B ON A.cmpschcode =B.cmpschcode
	
	INSERT INTO SchemeCategorydetails
	SELECT CmpSchCode,Schcategory_type,GETDATE() FROM Cn2Cs_Prk_SchemeCategorydetails WHERE CMpSchcode NOT IN (SELECT CmpSchcode FROM #AvoidScheme)
	
	UPDATE Cn2Cs_Prk_SchemeCategorydetails SET DownloadFlag ='Y' WHERE CmpSchcode IN (SELECT CmpSchCode FROM SchemeCategorydetails) 
	RETURN
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptSchemeUtilization_Parle' AND TYPE='P')
DROP PROCEDURE Proc_RptSchemeUtilization_Parle
GO
/*
BEGIN TRAN
EXEC Proc_RptSchemeUtilization_Parle 246,1,0,'',0,0,1
ROLLBACK TRAN
*/
CREATE PROCEDURE [dbo].[Proc_RptSchemeUtilization_Parle]
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
*Modified by Praveenraj B For Parle Scheme Utilization Report On 25/01/2012
***************************************************************************************************
* DATE       AUTHOR			CR/BZ	USER STORY ID           DESCRIPTION                         
***************************************************************************************************
12-10-2017  Mohana.S		CR      CCRSTPAR0175          Showing Slab Details Instead of Slab id 
08-12-2017  Mary.S			BZ      ICRSTPAR6933          Showing Slab wise Budget utilized Details   
12-12-2017  Mohana.S		BZ      ICRSTPAR6933          Showing Slab wise Details (all columns) 
19-12-2018  Vasantharaj R   SR      ILCRSTPAR2868         As per Client request [All the report must be generate based on Date range selection.] 
08/02/2018  Deepak Philip   BUG     ILCRSTPAR3364          validation added to take correct tax amount for same products/different batches and schid mapping added.
23/04/2018  Deepak k        BUG     ILCRSTPAR4112          validation added to take correct tax amount for same products/different batches and slabid mapping added.
***************************************************************************************************/  
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
		Slabid INT,
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
	
	SELECT DISTINCT Prdid,U.ConversionFactor 
	Into #PrdUomBox
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	Inner Join UomMaster UM On U.UomId=Um.UomId
	--Where Um.UomCode='BX'--Commented and added by Rajesh ICRSTPAR3196
	Where Um.UomCode IN('BX','BOX')
		
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
	
CREATE TABLE #RptStoreSchemeDetails
(
	[SchId] [int] NULL,
	[SlabId] [int] NULL,
	[ReferNo] [nvarchar](100) COLLATE DATABASE_DEFAULT  NULL,
	[SMId] [int] NULL,
	[RMId] [int] NULL,
	[DlvRMId] [int] NULL,
	[RtrId] [int] NULL,
	[DlvSts] [int] NULL,
	[VehicleId] [int] NULL,
	[DlvBoyId] [int] NULL,
	[PrdID] [int] NULL,
	[PrdBatId] [int] NULL,
	[FlatAmount] [numeric](38, 6) NULL,
	[DiscountPer] [numeric](38, 6) NULL,
	[Points] [int] NULL,
	[FreePrdId] [int] NULL,
	[FreePrdBatId] [int] NULL,
	[FreeQty] [int] NULL,
	[FreeValue] [numeric](38, 6) NULL,
	[GiftPrdId] [int] NULL,
	[GiftPrdBatId] [int] NULL,
	[GiftQty] [int] NULL,
	[GiftValue] [numeric](38, 6) NULL,
	[SchemeBudget] [numeric](38, 6) NULL,
	[BudgetUtilized] [numeric](38, 6) NULL,
	[Selected] [tinyint] NULL,
	[UserId] [int] NULL,
	[SMName] [nvarchar](200)  COLLATE DATABASE_DEFAULT NULL,
	[RMName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[DlvRMName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[RtrName] [nvarchar](200)  COLLATE DATABASE_DEFAULT  NULL,
	[VehicleName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[DeliveryBoyName] [nvarchar](200)COLLATE DATABASE_DEFAULT   NULL,
	[PrdName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[BatchName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[FreePrdName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[FreeBatchName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[GiftPrdName] [nvarchar](200)COLLATE DATABASE_DEFAULT   NULL,
	[GiftBatchName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[LineType] [int] NULL,
	[ReferDate] [datetime] NULL,
	[CtgLevelId] [int] NULL,
	[CtgLevelName] [nvarchar](200)COLLATE DATABASE_DEFAULT  NULL,
	[CtgMainId] [int] NULL,
	[CtgName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[RtrClassId] [int] NULL,
	[ValueClassName] [nvarchar](200) COLLATE DATABASE_DEFAULT  NULL,
	[BaseQty] [Int],
	[BaseQtyBox] [Int],
	[BaseQtyPack] [Int],
	TAX NUMERIC(38,6)
) ON [PRIMARY]
	
	Create TABLE #RptSchemeUtilizationDet_Parle
	(
		SchId		Int,
		SchCode		nVarChar(100),
		SchDesc		nVarChar(500),
		SlabId		nVarChar(50),
		SchemeBudget	Numeric(38,6),
		BudgetUtilized	Numeric(38,6),
		NoOfRetailer	Int,
		NoOfBills	Int,
		UnselectedCnt	Int,
		FlatAmount	Numeric(38,6),
		DiscountPer	Numeric(38,6),
		Points		Int,
		FreePrdName	nVarchar(200),
		FreeQty		Int,
		[BaseQty] [Int],
		BaseQtyBox	Int,
		BaseQtyPack Int,
		FreeValue	Numeric(38,6),
		GiftPrdName	nVarchar(200),
		GiftQty		Int,
		GiftValue	Numeric(38,6),
		[CircularNo] [Nvarchar](50),
		Tax NUMERIC(38,6)
	)
	SET @TblName = '#RptSchemeUtilizationDet_Parle'
	
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
				[BaseQty] [Int],
				BaseQtyBox	Int,
				BaseQtyPack Int,
				FreeValue	Numeric(38,6),
				GiftPrdName	nVarchar(50),
				GiftQty		Int,
				GiftValue	Numeric(38,6)'
	SET @TblFields = 'SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,FlatAmount,DiscountPer,Points,FreePrdName,FreeQty,BaseQty,BaseQtyBox,BaseQtyPack,FreeValue,
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
		EXEC Proc_RptStoreSchemeDetailsSlab @Pi_RptId,@Pi_UsrId --ICRSTPAR6933
	
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
		
			CREATE TABLE #SalesSchemeDetailsTax	
			(
			SalInvNo		nVarChar(100),
			SchId			INT,
			SlabId			INT, 
			PrdId			INT,
			PrdBatId		INT,
			SlNo            INT,
			GSTTax          Numeric(38,6)
			)
			CREATE TABLE #ReturnSchemeDetailsTax	
			(
			SalInvNo		nVarChar(100),
			SchId			INT,
			SlabId			INT, 
			PrdId			INT,
			PrdBatId		INT,
			SlNo            INT,
			GSTTax          Numeric(38,6)
			)
			INSERT INTO #SalesSchemeDetailsTax (SalInvNo,SchId,SlabId,PrdId,PrdBatId,SlNo ,GSTTax  )
			SELECT B.SalInvno,A.SchId,A.SlabId,A.PrdId,A.PrdBatId,A.Rowid,
			SUM((FlatAmount + DiscountPerAmount)*(C.TaxPerc/100)) ---Gopi at 27/06/2017
			FROM SalesInvoiceSchemeLineWise A(NOLOCK) INNER JOIN SalesInvoice B (NOLOCK)ON A.SalId = B.SalId 
			INNER JOIN SalesInvoiceProductTax C(NOLOCK) ON C.SalId=A.SalId AND C.SalId=B.SalId
			AND C.PrdSlNo=A.RowId
			WHERE DlvSts in (4,5)  AND C.TaxPerc>0.00
			AND B.SalInvDate Between @FromDate AND @tODate
			GROUP BY B.SalInvno,A.SchId,A.SlabId,A.PrdId,A.PrdBatId,A.RowId
	
			INSERT INTO #ReturnSchemeDetailsTax(SalInvNo,SchId,SlabId,PrdId,PrdBatId,SlNo,GSTTax)
			SELECT B.ReturnCode,A.SchId,A.SlabId,A.Prdid,A.Prdbatid,A.RowId,
			Sum((ReturnFlatAmount + ReturnDiscountPerAmount)*(C.TaxPerc/100))*-1
			FROM ReturnSchemeLineDt A (NOLOCK) INNER JOIN ReturnHeader B(NOLOCK) ON A.ReturnId = B.ReturnId 
			INNER JOIN ReturnProductTax C(NOLOCK) ON C.ReturnId=A.ReturnID AND C.ReturnId=B.ReturnID
			AND C.PrdSlno=A.RowId
			WHERE B.Status = 0 AND C.TaxPerc>0.00
			AND B.ReturnDate Between   @FromDate AND @tODate
			GROUP BY B.ReturnCode,A.SchId,A.SlabId,A.Prdid,A.Prdbatid,A.RowId
		
			
		Insert Into #RptStoreSchemeDetails(SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,RtrId,DlvSts,VehicleId,DlvBoyId,PrdID,PrdBatId,FlatAmount,DiscountPer,
										   Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,GiftQty,GiftValue,SchemeBudget,BudgetUtilized,
										   Selected,UserId,SMName,RMName,DlvRMName,RtrName,VehicleName,DeliveryBoyName,PrdName,BatchName,FreePrdName,FreeBatchName
										   ,GiftPrdName,GiftBatchName,LineType,ReferDate,CtgLevelId,CtgLevelName,CtgMainId,CtgName,RtrClassId,ValueClassName,BaseQty,BaseQtyBox,BaseQtyPack) 
		Select SchId,SlabId,ReferNo,SMId,RMId,DlvRMId,RtrId,DlvSts,VehicleId,DlvBoyId,PrdID,PrdBatId,FlatAmount,DiscountPer,
										   Points,FreePrdId,FreePrdBatId,FreeQty,FreeValue,GiftPrdId,GiftPrdBatId,GiftQty,GiftValue,SchemeBudget,BudgetUtilized,
										   Selected,UserId,SMName,RMName,DlvRMName,RtrName,VehicleName,DeliveryBoyName,PrdName,BatchName,FreePrdName,FreeBatchName
										   ,GiftPrdName,GiftBatchName,LineType,ReferDate,CtgLevelId,CtgLevelName,CtgMainId,CtgName,RtrClassId,ValueClassName,0,0,0
										  From RPTStoreSchemeDetails Where Userid = @Pi_UsrId AND BudgetUtilized>0
		
		
		--Commented by Deepak Philip ILCRSTPAR3364
		--UPDATE A SET Tax = B.GSTTax FROM #RptStoreSchemeDetails A INNER JOIN #SalesSchemeDetailsTax B ON A.SchId = B.SchId AND A.ReferNo = B.SalInvNo AND B.PrdId=A.Prdid 
		--AND B.PrdBatId = A.PrdBatid AND A.LineType = 1
		--UPDATE A SET Tax = B.GSTTax FROM #RptStoreSchemeDetails A INNER JOIN #returnSchemeDetailsTax B ON A.SchId = B.SchId AND A.ReferNo = B.SalInvNo AND B.PrdId=A.Prdid 
		--AND B.PrdBatId = A.PrdBatid AND A.LineType = 2	
		
		--Commented and Added BY Deepak K PMS NO ILCRSTPAR4112
		
		----added by Deepak Philip  ILCRSTPAR3364
		--UPDATE A SET Tax = B.GSTTax FROM #RptStoreSchemeDetails A INNER JOIN (SELECT  Schid,SAlinvno,Prdid,Prdbatid,SUM(GstTax) GstTax 	FRom  #SalesSchemeDetailsTax GROUP BY Schid,SAlinvno,Prdid,Prdbatid) B ON A.SchId = B.SchId AND A.ReferNo = B.SalInvNo AND B.PrdId=A.Prdid 
		--AND B.PrdBatId = A.PrdBatid AND A.LineType = 1
		--UPDATE A SET Tax = B.GSTTax FROM #RptStoreSchemeDetails A INNER JOIN (SELECT  Schid,SAlinvno,Prdid,Prdbatid,SUM(GstTax) GstTax FRom #returnSchemeDetailsTax GROUP BY Schid,SAlinvno,Prdid,Prdbatid) B ON A.SchId = B.SchId AND A.ReferNo = B.SalInvNo AND B.PrdId=A.Prdid 
		--AND B.PrdBatId = A.PrdBatid AND A.LineType = 2		
		--till here
		
		
		UPDATE A SET Tax = B.GSTTax FROM #RptStoreSchemeDetails A INNER JOIN (SELECT  Schid,SAlinvno,Prdid,Prdbatid,slabid,SUM(GstTax) GstTax 	FRom  #SalesSchemeDetailsTax GROUP BY Schid,SAlinvno,Prdid,Prdbatid,slabid) B ON A.SchId = B.SchId AND A.ReferNo = B.SalInvNo AND B.PrdId=A.Prdid 
		AND B.PrdBatId = A.PrdBatid AND A.LineType = 1
		UPDATE A SET Tax = B.GSTTax FROM #RptStoreSchemeDetails A INNER JOIN (SELECT  Schid,SAlinvno,Prdid,Prdbatid,slabid,SUM(GstTax) GstTax FRom #returnSchemeDetailsTax GROUP BY Schid,SAlinvno,Prdid,Prdbatid,slabid) B ON A.SchId = B.SchId AND A.ReferNo = B.SalInvNo AND B.PrdId=A.Prdid 
		AND B.PrdBatId = A.PrdBatid AND A.LineType = 2	
		--Till Here
		--Select Distinct ReferNo,BaseQty,PrdId,PrdBatId Into #RptScheme From #RptStoreSchemeDetails Where LineType<>3 And Userid = @Pi_UsrId
		--Changed By Mohana
		Update X Set X.BaseQty=Sp.BaseQty --Case When FreeValue=0 Then Sp.BaseQty Else 0 End
			From SalesInvoice S
					Inner Join (SELECT A.SalId,slabid,a.PrdId,a.PrdBatId,SUM(BaseQty) AS BaseQty FROM SalesInvoiceProduct A INNER JOIN SalesInvoiceSchemeLineWise B ON 
					A.salid =b.salid and B.Prdid=A.Prdid AND A.prdbatid =B.prdbatid 
					GROUP BY A.SalId,slabid,a.PrdId,a.PrdBatId,slabid) SP On S.SalId=SP.SalId					 
					Inner Join  #RptStoreSchemeDetails X On X.ReferNo=S.SalInvNo And X.PrdID=SP.PrdId And X.PrdBatId=SP.PrdBatId and sp.slabid=x.slabid
					Inner join  #PrdUomAll PU On PU.PrdId=X.PrdID
				 Where X.LineType<>3 
		
		--SELECT * FROM #RptStoreSchemeDetails Inner join  #PrdUomAll PU On PU.PrdId=#RptStoreSchemeDetails.PrdID
		--Changed By Mohana
		
		SELECT DISTINCT A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.PrdID,SUM(Discountper) Discountper,ISNULL(Sum(BaseQty),0) as BaseQty,
		Case When Isnull(Sum(BaseQty),0)<MAX(ConversionFactor) Then 0 Else Isnull(Sum(BaseQty),0)/MAX(ConversionFactor) End As BaseQtyBox,
		Case When Isnull(Sum(BaseQty),0)<MAX(ConversionFactor) Then Isnull(Sum(BaseQty),0) Else Isnull(Sum(BaseQty),0)%MAX(ConversionFactor) End As BaseQtyPack
		INTO #ProductUOM
		FROM SchemeMaster A INNER JOIN #RPTStoreSchemeDetails B On A.SchId= B.SchId
		AND B.Userid = @Pi_UsrId
		Inner Join #PrdUomAll PU On PU.PrdId=B.PrdID
		WHERE ReferDate Between @FromDate AND @ToDate  AND
		B.LineType <> 3 AND BudgetUtilized>0
		GROUP BY A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.PrdID
		 
							   
		INSERT INTO #RptSchemeUtilizationDet_Parle(SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
			NoOfBills,UnselectedCnt,FlatAmount,DiscountPer,Points,FreePrdName,FreeQty,BaseQty,BaseQtyBox,BaseQtyPack,FreeValue,
			GiftPrdName,GiftQty,GiftValue,CircularNo,Tax)
		SELECT DISTINCT A.SchId,A.SchCode,A.SchDsc,B.SlabId,B.SchemeBudget,B.BudgetUtilized,Count(Distinct B.RtrId),
			Count(Distinct B.ReferNo),0 as UnSelectedCnt,dbo.Fn_ConvertCurrency(ISNULL(SUM(FlatAmount),0),@Pi_CurrencyId) as FlatAmount,
			CASE FreePrdId WHEN 0 THEN dbo.Fn_ConvertCurrency(ISNULL(SUM(B.DiscountPer),0),@Pi_CurrencyId) ELSE '0.00' END as DiscountPer,
			ISNULL(SUM(Points),0) as Points,CASE ISNULL(SUM(FreeQty),0) WHEN 0 THEN '' ELSE FreePrdName END AS FreePrdName,
			CASE FreePrdName WHEN '' THEN 0 ELSE ISNULL(SUM(FreeQty),0)  END as FreeQty,0 as BaseQty,
			 0 as BaseQtyBox,
			0 as BaseQtyPack,
			ISNULL(SUM(FreeValue),0) as FreeValue,
			CASE ISNULL(SUM(GiftValue),0) WHEN 0 THEN '' ELSE GiftPrdName END AS GiftPrdName,ISNULL(SUM(GiftQty),0) as FreeQty,
			ISNULL(SUM(GiftValue),0) as GiftValue,isnull(BudgetAllocationNo,''),CASE A.ApplyTaxForClaim WHEN 1 THEN SUM(tax) ELSE 0 END AS Tax
		FROM SchemeMaster A INNER JOIN #RPTStoreSchemeDetails B On A.SchId= B.SchId
			AND B.Userid = @Pi_UsrId
		--Inner Join #ProductUOM PU On PU.PrdId=B.PrdID and A.SchId=PU.schid --Added by Deepak Philip ILCRSTPAR3364
		Inner Join #ProductUOM PU On PU.PrdId=B.PrdID and A.SchId=PU.schid and PU.slabid=B.slabid-- Added By Deepak K 
		WHERE ReferDate Between @FromDate AND @ToDate  AND 
			(B.SMId = (CASE @fSMId WHEN 0 THEN B.SMId Else 0 END) OR
			B.SMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) AND
			(B.RMId = (CASE @fRMId WHEN 0 THEN B.RMId Else 0 END) OR
			B.RMId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) AND
			(B.CtgLevelId = (CASE @TempCtgLevelId WHEN 0 THEN B.CtgLevelId Else 0 END) OR
			B.CtgLevelId in (@TempCtgLevelId)) AND
			(B.CtgMainId = (CASE @CtgMainId WHEN 0 THEN B.CtgMainId Else 0 END) OR
			B.CtgMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))) AND
			(B.RtrClassId = (CASE @RtrClassId WHEN 0 THEN B.RtrClassId Else 0 END) OR
			B.RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))) AND
			(B.RtrID = (CASE @fRtrId WHEN 0 THEN B.RtrID Else 0 END) OR
			B.RtrID in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
			(A.SchId = (CASE @fSchId WHEN 0 THEN A.SchId Else 0 END) OR
			A.SchId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))) AND
			B.LineType <> 3 AND BudgetUtilized>0
		GROUP BY A.SchId,B.SlabId,A.SchCode,A.SchDsc,B.SchemeBudget,B.BudgetUtilized,FreePrdId,
			FreePrdName,GiftPrdName,BudgetAllocationNo,ApplyTaxForClaim--,B.PrdID 
		
	
		
		UPDATE A SET Discountper=b.Discountper, BaseQty=B.BaseQty,BaseQtyBox=B.BaseQtyBox,BaseQtyPack=B.BaseQtyPack FROM #RptSchemeUtilizationDet_Parle A INNER JOIN 
		(SELECT SchId,SlabId,SUM(Discountper) Discountper,SUM(BaseQty) BaseQty,SUM(BaseQtyBox) BaseQtyBox,SUM(BaseQtyPack) BaseQtyPack FROM #ProductUOM
		GROUP BY SchId,Slabid
		) B ON A.SchId=B.SchId
		AND A.SlabId=B.SlabId
	 
				
			
		UPDATE A SET A.DiscountPer= (CASE FreePrdName WHEN '' THEN CAST(B.FlatAmt AS NUMERIC(18,2)) ELSE '0.00' END) FROM #RptSchemeUtilizationDet_Parle A INNER JOIN 
		(SELECT SchId,SlabId,SUM(FlatAmount)+SUM(DiscountPer) AS FlatAmt FROM #RptSchemeUtilizationDet_Parle GROUP BY SchId,SlabId) B
		ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		
		SELECT SchId,SlabId,ReferNo,RtrId INTO #TempBilledDt FROM RptStoreSchemeDetails WHERE LineType <> 3
		
		
		--UPDATE A SET NoOfBills = BillCnt FROM #RptSchemeUtilizationDet_Parle A INNER JOIN 
		--(SELECT SchId,SlabId,COUNT(DISTINCT ReferNo) AS BillCnt FROM
		--#TempBilledDt GROUP By SchId,SlabId) B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		
		--UPDATE A SET NoOfRetailer = RtrCnt FROM #RptSchemeUtilizationDet_Parle A INNER JOIN 
		--(SELECT SchId,SlabId,COUNT(DISTINCT RtrId) AS RtrCnt FROM
		--#TempBilledDt GROUP By SchId,SlabId) B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
				
		DELETE FROM #RptSchemeUtilizationDet_Parle WHERE (BaseQtyBox+BaseQtyPack+FreeQty+GiftQty)<=0
		
		DELETE FROM @TempData
	
		INSERT INTO @TempData(SchId,Slabid,RtrCnt,BillCnt)
		SELECT SchId,B.Slabid, Count(Distinct B.RtrId),Count(Distinct ReferNo)
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
			B.LineType = 1
		GROUP BY B.SchId,B.Slabid
		
		UPDATE #RptSchemeUtilizationDet_Parle SET NoOfRetailer = NoOfRetailer,
			NoOfBills = BillCnt FROM @TempData B WHERE B.SchId = #RptSchemeUtilizationDet_Parle.SchId AND B.Slabid = #RptSchemeUtilizationDet_Parle.SlabId
	
		DELETE FROM @TempData
	
		INSERT INTO @TempData(SchId,Slabid,RtrCnt,BillCnt)
		SELECT SchId,B.Slabid,  Count(Distinct B.RtrId),Count(Distinct ReferNo)
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
			AND CAST(B.SchId AS VARCHAR(10))+'~'+CAST(B.SlabId AS VARCHAR(10))+'~'+CAST(B.RtrId AS VARCHAR(10)) NOT IN 
			(Select DISTINCT CAST(SchId AS VARCHAR(10))+'~'+CAST(SlabId AS VARCHAR(10))+'~'+CAST(RtrId AS VARCHAR(10)) FROM #TempBilledDt)
			GROUP BY B.SchId,B.Slabid
			
		UPDATE #RptSchemeUtilizationDet_Parle SET UnselectedCnt = RtrCnt
			FROM @TempData B WHERE B.SchId = #RptSchemeUtilizationDet_Parle.SchId AND B.Slabid = #RptSchemeUtilizationDet_Parle.SlabId
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptSchemeUtilizationDet_Parle ' +
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSchemeUtilizationDet_Parle'
				
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
			SET @SSQL = 'INSERT INTO #RptSchemeUtilizationDet_Parle ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSchemeUtilizationDet_Parle
	-- Till Here
	--UPDATE A SET BaseQty = B.BaseQty FROM #RptSchemeUtilizationDet_Parle A INNER JOIN
	--(SELECT C.SchId,(SUM(B.BaseQty)-SUM(ReturnedQty)) AS BaseQty FROM Salesinvoice A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
	--INNER JOIN 
	--(SELECT DISTINCT ReferNo,B.PrdId,A.SchId,SlabId FROM RptStoreSchemeDetails A INNER JOIN Fn_ReturnSchemeProductWithScheme() B ON 
	--A.SchId=B.SchId)C ON A.SalInvNo=C.ReferNo AND B.PrdId=C.PrdId GROUP BY C.SchId,slabid) B ON A.SchId=B.SchId 
	
	UPDATE A SET FreeQty = (CASE FreePrdName WHEN '' THEN 0 ELSE B.FreeQty END) FROM #RptSchemeUtilizationDet_Parle A INNER JOIN
	(SELECT C.SchId,(SUM(B.FreeQty)- SUM(ReturnFreeQty)) AS FreeQty FROM Salesinvoice A INNER JOIN SalesInvoiceSchemeDtFreePrd B ON A.SalId=B.SalId
	INNER JOIN 
	(SELECT DISTINCT ReferNo,A.FreePrdId,A.SchId FROM RptStoreSchemeDetails A INNER JOIN Fn_ReturnSchemeProductWithScheme() B ON 
	A.SchId=B.SchId AND A.FreePrdId > 0)C ON A.salInvNo=C.ReferNo GROUP BY C.SchId) B ON A.SchId=B.SchId
	
	--UPDATE A SET NoOfBills = B.BillCnt FROM #RptSchemeUtilizationDet_Parle A INNER JOIN
	--(SELECT SchId,SUM(BillCnt) As BillCnt FROM 
	--(SELECT  CASE LineType WHEN 1 THEN COUNT(DISTINCT ReferNo) ELSE COUNT(DISTINCT ReferNo) *-1 END 
	--AS BillCnt,A.SchId,LineType FROM RptStoreSchemeDetails A INNER JOIN Fn_ReturnSchemeProductWithScheme() B ON 
	--A.SchId=B.SchId AND A.FreePrdId<>0 GROUP BY A.SchId,LineType) A GROUp By SchId) B ON A.SchId=B.SchId
	UPDATE RPT SET RPT.SchCode=S.CmpSchCode FROM #RptSchemeUtilizationDet_Parle RPT INNER JOIN SchemeMaster S ON RPT.SchId=S.SchId 
	UPDATE #RptSchemeUtilizationDet_Parle SET DiscountPer = DiscountPer+Tax 
	
	
--Added By Mohana	
	SELECT A.SchId ,B.SlabId, CASE B.PurQty WHEN 0 THEN CONVERT (NVARCHAR(20),B.FromQty) + '-' + CONVERT(NVARCHAR(20),B.ToQty)
	ELSE  CONVERT (NVARCHAR(20),B.PurQty) + '-' + CONVERT(NVARCHAR(20),B.ToQty)END Slabdet INTO #SlabDet FROM SchemeMaster A INNER JOIN SchemeSlabs B ON A.SchId = B.SchId
	INNER JOIN #RptSchemeUtilizationDet_Parle R on R.schid=a.schid  and R.schid=b.SchId and R.slabid=b.SlabId 
	UPDATE A SET SlabId = Slabdet FROM #RptSchemeUtilizationDet_Parle A INNER JOIN #SlabDet B ON A.SchId =B.Schid AND A.SlabId = B.slabid
--Till here
    --SELECT DISTINCT SchId,SchCode,SchDesc,CircularNo,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,NoOfBills AS NoOfBills ,
	SELECT DISTINCT SchId,SchCode,SchDesc,CircularNo,SlabId,SchemeBudget,DiscountPer AS BudgetUtilized,NoOfRetailer,NoOfBills AS NoOfBills ,--ILCRSTPAR2868 
	UnselectedCnt,(BaseQtyBox) AS BaseQtyBox,(BaseQtyPack) AS BaseQtyPack,
	DiscountPer,(CASE FreeQty WHEN 0 THEN '-' ELSE FreePrdName END) AS FreePrdName,FreeQty,
    (CASE FreeQty WHEN 0 THEN '0.00' ELSE FreeValue END) AS FreeValue,FlatAmount,Points,(BaseQty) AS BaseQty,
	GiftPrdName,GiftQty,GiftValue
	FROM #RptSchemeUtilizationDet_Parle 
	
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
	BEGIN
	IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'RptSchemeUtilizationDet_Parle_Excel') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptSchemeUtilizationDet_Parle_Excel
		    --SELECT DISTINCT SchId,SchCode,SchDesc,CircularNo,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,NoOfBills AS NoOfBills ,
			SELECT DISTINCT SchId,SchCode,SchDesc,CircularNo,SlabId,SchemeBudget,DiscountPer AS BudgetUtilized,NoOfRetailer,NoOfBills AS NoOfBills ,--ILCRSTPAR2868 
			UnselectedCnt,(BaseQtyBox) AS BaseQtyBox,(BaseQtyPack) AS BaseQtyPack,
			DiscountPer,(CASE FreeQty WHEN 0 THEN '-' ELSE FreePrdName END) AS FreePrdName,FreeQty,
			(CASE FreeQty WHEN 0 THEN '0.00' ELSE FreeValue END) AS FreeValue,FlatAmount,Points,(BaseQty) AS BaseQty,
			GiftPrdName,GiftQty,GiftValue
			INTO RptSchemeUtilizationDet_Parle_Excel FROM #RptSchemeUtilizationDet_Parle Order By SchId
	END 
RETURN
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME ='Proc_ValidateCSTimer' AND XTYPE ='P')
DROP PROCEDURE Proc_ValidateCSTimer
GO
/*
begin tran
 exec Proc_ValidateCSTimer '2019-04-24',1000,206
 SELECT * FROM CSTimer (NOLOCK)
rollback tran
*/
CREATE PROCEDURE Proc_ValidateCSTimer
(
@gServerDate DATETIME,
@iMode INT,
@TransId	INT
)
AS
/********************************************************************************************************************************************************************************
* PROCEDURE		: Proc_ValidateCSTimer
* PURPOSE		: To Validate the Server Date Details
* CREATED BY	: S.MOORTHI
* CREATED DATE	: 06/11/2018
* MODIFIED
* DATE        AUTHOR			CR/BZ	USER STORY ID		DESCRIPTION         
-----------------------------------------------------------------------      
 06-11-2018  S.Moorthi			CR		CRCRSTPAR0034       currently month end is happening on 6th day of month, this is happening based on system date. Is internet connection not available. 
															Need to get console server date through sync and validate user to perform month end process
 06-11-2018  S.Moorthi			CR		CRCRSTPAR0036       Back Date transaction should be allowed
 06-12-2018  M Lakshman         SR      ILCRSTPAR2752       In core stocky Proc_ValidateCSTimer fresh DB using that time stock ledger no records available. 
															Now validation added script level changes has been done.
 13-12-2018  M Lakshman         SR      ILCRSTPAR2927       As per client request Future date transaction will allow only 5 days validation included in core stocky.	
 12-04-2018  M Lakshman         SR      ILCRSTPAR3870       As per client request Future date validation included allow only 5 days. 								
********************************************************************************************************************************************************************************/ 
BEGIN
SET NOCOUNT ON
	DECLARE @CSDate AS DATETIME
	DECLARE @LocalDate AS DATETIME
	
	DECLARE @BackDateAllow AS DATETIME
	declare @TimInterval  AS NUMERIC(8,0)
	DECLARE @CSDateDD INT
	DECLARE @BackDateDays AS INT
	DECLARE @MonthEndDate AS DATETIME
	DECLARE @MaxTransDate AS DATETIME
	DECLARE @ValidateMsg AS VARCHAR(200)
	DECLARE @MonthEndDt AS DATETIME
	DECLARE @JCMONTHDT AS DATETIME
	DECLARE @ActMonthEndDt AS DATETIME
	DECLARE @MonthEndConfigDays AS INT
	DECLARE @csdateNew AS datetime
	DECLARE @csServerNew AS datetime
	
	IF NOT EXISTS(SELECT * FROM CSTimer (NOLOCK))
	BEGIN
		SELECT '' ValidMsg
		RETURN 
	END
	
	IF NOT EXISTS(SELECT * FROM StockLedger (NOLOCK))
	BEGIN
		SELECT '' ValidMsg
		RETURN 
	END
	SELECT @CSDate = CONVERT(VARCHAR(10),CSDate,121),@LocalDate = GETDATE() FROM CSTimer (NOLOCK)
	
	SELECT @MaxTransDate=ISNULL(MAX(TransDate),GETDATE()) FROM StockLedger (NOLOCK)

	-- SELECT  @csdateNew  = CSdate+4  from CSTimer (NOLOCK)
	---------- Added by lakshman M Dated ON 12-04-2018 PMS ID: ILCRSTPAR3870 --------------
	SELECT @CSDATENEW = convert(varchar(10),getdate(),121)
	SELECT  @csServerNew = @gServerDate + 4

	IF @csServerNew < @csdateNew
	BEGIN
		--IF @csdateNew <= @gServerDate
		--BEGIN	
			IF NOT EXISTS(SELECT * FROM CSTimer (NOLOCK) WHERE convert(varchar(10),CSDate,121) Between CONVERT(VARCHAR(10),@csdateNew,121) AND CONVERT (VARCHAR(10),@gServerDate,121) )
			BEGIN
				SELECT 'Please Change the System Date future date transaction will allow for only 5 days' ValidMsg
				RETURN 
			END
		--END
	END 
	------------------------- Till here --------------------------------------
	IF @MaxTransDate>@CSDate
	BEGIN
		SET @CSDate=@MaxTransDate		
		UPDATE CSTimer SET CSDate=@MaxTransDate
	END
	
	IF @iMode=1000 AND @TransId=206
	BEGIN
		IF @gServerDate>@CSDate
		BEGIN
			SET @CSDate=@gServerDate

			INSERT INTO CSTimerHistory(SyncId,ServerDate,CSDate,LocalDate,Upload)  
			SELECT SyncId,@gServerDate,@gServerDate,GETDATE(),Upload FROM CSTimer T (NOLOCK) 
			
			UPDATE CSTimer SET CSDate=@CSDate,ServerDate=@gServerDate,LocalDate=GETDATE()
		END
	END
	
	--select @BackDateDays,@CSDate
	IF EXISTS(SELECT * FROM CONFIGURATION WHERE MODULENAME='Month End Process' AND MODULEID='DAYMONTHEND1' AND CONFIGVALUE>0)
	BEGIN
		IF @iMode=0 AND @TransId=206
		BEGIN
			IF EXISTS(SELECT * fROM MANUALCONFIGURATION WHERE Moduleid='MonthEndServerDate' and status=1)
			BEGIN 
				goto xy
			END
		END
		
		SELECT @MonthEndConfigDays= ConfigValue FROM CONFIGURATION WHERE MODULENAME='Month End Process' AND MODULEID='DAYMONTHEND1'
		SET @ActMonthEndDt = dateadd(d,@MonthEndConfigDays,@gServerDate)
	
		SELECT @JCMONTHDT=Jcmsdt FROM JCMonth(NOLOCK) WHERE @CSDate BETWEEN JcmSdt AND JcmEdt 
		SET @MonthEndDt=dateadd(d,@MonthEndConfigDays,@JCMONTHDT)
	
		IF NOT EXISTS(SELECT * FROM JCMonthEnd (NOLOCK)	WHERE JcmEdt=DATEADD(D,-1,@JCMONTHDT) AND Status = 1)
		BEGIN
			IF @CSDate >= @MonthEndDt
			BEGIN
				IF @CSDate <> @gServerDate
					BEGIN
						SELECT 'Please change the System date with '+ CONVERT(NVARCHAR(20),@CSDate,103)+' and do Month End for '+DATENAME(M,DATEADD(D,-1,@JCMONTHDT))+' - '+CAST(YEAR(DATEADD(D,-1,@JCMONTHDT)) AS NVARCHAR(10)) as ValidMsg
						RETURN
						--SET @ValidateMsg='System Date does not match with Server Date. Please correct the system date and restart Sehyog to proceed.'
					END
			END
		END
	END
	xy:
	
	--select @BackDateAllow,@gServerDate
	IF EXISTS(SELECT * FROM ManualConfiguration(NOLOCK) WHERE ModuleId='CSTimer2' AND STATUS=1)
	BEGIN
		SELECT @BackDateDays = ISNULL(ConfigValue,0) FROM ManualConfiguration(NOLOCK) WHERE ModuleId='CSTimer2'
		SET @BackDateAllow=CONVERT(VARCHAR(10),DATEADD(D,-@BackDateDays+1,@CSDate),121)
		IF @BackDateAllow>@gServerDate
		BEGIN
			SELECT 'Back Date should be allow till '+ CONVERT(NVARCHAR(20),@BackDateAllow,103)+', Please Change the System Date and re-open Sehyog to continue ' ValidMsg
			--SELECT 'Back Date should be allow till '+ CONVERT(NVARCHAR(20),@BackDateAllow,103)+', Please Change System Date to '+ CONVERT(NVARCHAR(20),@CSDate,103)+' and re-open Sehyog to continue ' ValidMsg
			RETURN
		END
	END
	
	
	--Back Date Transaction Not Allowed, Please Change System Date to 
	--IF @CSDate>@gServerDate
	--BEGIN
	--	SELECT 	'Please change System date to '+ CONVERT(NVARCHAR(20),@CSDate,103)+' and re-open Sehyog to continue ' ValidMsg
	--	RETURN
	--END
	
	SELECT '' ValidMsg
	
RETURN 
END
GO
UPDATE UtilityProcess SET VersionId = '3.1.0.17' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.17',440
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 440)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(440,'D','2019-05-02',GETDATE(),1,'Core Stocky Service Pack 440')
GO