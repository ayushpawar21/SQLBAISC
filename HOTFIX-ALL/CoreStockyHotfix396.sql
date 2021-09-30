--[Stocky HotFix Version]=396
Delete from Versioncontrol where Hotfixid='396'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('396','2.0.0.5','D','2011-11-22','2011-11-22','2011-11-22',convert(varchar(11),getdate()),'Major: Product Release Nov CR')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 396' ,'396'
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='SalesInvoiceQpsDatebasedTrack')
CREATE TABLE [dbo].SalesInvoiceQpsDatebasedTrack
(
		ProcessId			INT,
		TransRefId			BIGINT,
		TransRefCode		Varchar(100),
		RtrId				BIGINT,
		RtrCode				VARCHAR(100),	
		Rtrname				VARCHAR(200),	
		Schid				BIGINT,
		SchCode				VARCHAR(50),
		SchDesc				VARCHAR(200),
		PrdId				BIGINT,	
		PrdCCode			VARCHAR(50),
		PrdBatId			BIGINT,
		PrdBatCode			VARCHAR(100),
		SchemeOnQty			BIGINT,
		SchemeOnAmount		Numeric(32,4),
		SchemeOnKG			NUMERIC(38,6),
		SchemeOnLitre		NUMERIC(38,6),
		UsrId				INT,
		TransId				INT,
		Upload				INT
	
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='CS2CN_QPSDataBasedCrNoteTrack')
CREATE TABLE [dbo].CS2CN_QPSDataBasedCrNoteTrack
(
		Slno				NUMERIC(38,0) IDENTITY (1,1),
		DistCode			VARCHAR(100),
		TransName			VARCHAR(50),
		TransRefId			BIGINT,
		TransRefCode		Varchar(100),
		RtrId				BIGINT,
		RtrCode				VARCHAR(100),	
		Rtrname				VARCHAR(200),	
		Schid				BIGINT,
		SchCode				VARCHAR(50),
		SchDesc				VARCHAR(200),
		PrdId				BIGINT,	
		PrdCCode			VARCHAR(50),
		PrdBatId			BIGINT,
		PrdBatCode			VARCHAR(100),
		SchemeOnQty			BIGINT,
		SchemeOnAmount		Numeric(32,4),
		SchemeOnKG			NUMERIC(38,6),
		SchemeOnLitre		NUMERIC(38,6),
		UploadDate			DATETIME,
		UploadFlag			VARCHAR(1)
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='CS2CN_QPSDataBasedCrNoteTrack_Archive')
CREATE TABLE [dbo].CS2CN_QPSDataBasedCrNoteTrack_Archive
(
		Slno				NUMERIC(38,0),
		DistCode			VARCHAR(100),
		TransName			VARCHAR(50),
		TransRefId			BIGINT,
		TransRefCode		Varchar(100),
		RtrId				BIGINT,
		RtrCode				VARCHAR(100),	
		Rtrname				VARCHAR(200),	
		Schid				BIGINT,
		SchCode				VARCHAR(50),
		SchDesc				VARCHAR(200),
		PrdId				BIGINT,	
		PrdCCode			VARCHAR(50),
		PrdBatId			BIGINT,
		PrdBatCode			VARCHAR(100),
		SchemeOnQty			BIGINT,
		SchemeOnAmount		Numeric(32,4),
		SchemeOnKG			NUMERIC(38,6),
		SchemeOnLitre		NUMERIC(38,6),
		UploadDate			DATETIME,
		UploadFlag			VARCHAR(1),
		UploadedDate			DATETIME
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_ApplyQPSSchemeInBill')
DROP PROCEDURE Proc_ApplyQPSSchemeInBill
GO
/*
	BEGIN TRANSACTION
	DELETE FROM BillAppliedSchemeHd
	EXEC Proc_ApplyQPSSchemeInBill 144,1338,0,1,2,2
	SELECT * FROM SalesInvoiceQpsDatebasedTrack
	ROLLBACK TRANSACTION
*/
CREATE Procedure [dbo].[Proc_ApplyQPSSchemeInBill]
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
	END
	
	IF @QPS <> 0
	BEGIN
		--From all the Bills
		--To Add the Cumulative Qty
		IF @QPSBasedOn=2
		BEGIN
			IF @Pi_Mode=1
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
			ELSE IF @Pi_Mode=2
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
			ELSE
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
		END
		ELSE
		BEGIN
			-- Commented by Boopathy 27-07-2011 (Sales Return is not reduced for Data based QPS Scheme)
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
				SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
				(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
					) AS A 
					INNER JOIN 
					(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
						ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
					) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
				UNION
					SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
					) AS A 
					INNER JOIN 
					(
						SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
						WHERE A.SchId=@Pi_SchId
					) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
				UNION
					SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
						GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						
					) AS A 
				)AS A GROUP BY PrdId,PrdBatId,SchId
		END

	
		IF @Pi_Mode=0
		BEGIN
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
				INNER JOIN ProductUnit D (NOLOCK) ON C.PrdUnitId = D.PrdUnitId,SchemeMaster H
				WHERE Dlvsts in(1,2) and Rtrid=@Pi_RtrId and SI.Salid <>@Pi_SalId
				and SI.Salid Not in(Select Salid from SalesInvoiceSchemeQPSGiven (NOLOCK) where Salid<>@Pi_SalId and  schid=@Pi_SchId)
				AND SI.SalInvDate BETWEEN H.SchValidFrom AND CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
				Group by SIP.Prdid,SIP.Prdbatid,D.PrdUnitId
		END
		IF @Pi_Mode<>2
		BEGIN
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
					WHERE A.SalId = @Pi_SalId AND A.SalId NOT IN (SELECT SalId FROM SalesInvoice WHERE DlvSts>3)
					GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
			
			END
			IF @QPSBasedOn=1 
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
					-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
					-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
					FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
					AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
			END
		END
	END
	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
		ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
		GROUP BY PrdId,PrdBatId,SchId
		
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
		From BilledPrdHdForScheme BP WHERE BP.TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND BP.RtrId=@Pi_RtrId --AND BP.SchId=@Pi_SchId
		INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
		SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
		From @TempBilled TB 		
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
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_ApplyCombiSchemeInBill')
DROP PROCEDURE Proc_ApplyCombiSchemeInBill
GO
/*
BEGIN TRANSACTION
EXEC Proc_ApplyCombiSchemeInBill 37,3,0,1,2
ROLLBACK TRANSACTION
*/
CREATE Procedure [dbo].[Proc_ApplyCombiSchemeInBill]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT,
	@Pi_Mode		INT=0		
)
AS
/*********************************
* PROCEDURE	: Proc_ApplyCombiSchemeInBill
* PURPOSE	: To Apply the Combi Scheme and Get the Scheme Details for the Selected Scheme
* CREATED	: Thrinath
* CREATED DATE	: 17/04/2007
* NOTE		: General SP for Returning the Scheme Details for the Selected Combi Scheme
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}		  {brief modification description}
* 10/04/2010    Nandakumar R.G    Modified for QPS Scheme	
* 02-08-2011    Boopathy.P		  QPS DATE BASED ISSUE FROM J&J Site (Older schemes are getting apply)
* 11-08-2011    Boopathy.P        A Product with different Batch Issue
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
	DECLARE @QpsReset		INT
	DECLARE @QpsResetAvail		INT
	DECLARE @PurOfEveryReq		INT
	DECLARE @SchemeBudget		NUMERIC(38,6)
	DECLARE @SlabId			INT
	DECLARE @NoOfTimes		NUMERIC(38,6)
	DECLARE @GrossAmount		NUMERIC(38,6)
	DECLARE @SchemeLvlMode		INT
	DECLARE @PrdId			INT
	DECLARE @PrdBatId		INT
	DECLARE @PrdCtgValMainId	INT
	DECLARE @FrmSchAch		NUMERIC(38,6)
	DECLARE @FrmUomAch		INT
	DECLARE @FromQty		NUMERIC(38,6)
	DECLARE @UomId			INT
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
	DECLARE @SchValidTill	DATETIME
	DECLARE @SchValidFrom	DATETIME
	DECLARE @QPSBasedOn		INT
	DECLARE @CombiType			INT
	DECLARE @NoofLines			INT
	DECLARE @TransMode			INT
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
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @TempBilledCombiAch TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @TempBilledQpsReset TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
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
		PrdbatId		INT
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
		NoOfTimes	numeric(38,6),
		IsSelected	tinyint,
		SchBudget	numeric(32,6),
		BudgetUtilized	numeric(32,6),
		TransId		tinyint,
		Usrid		int,
		PrdId		int,
		PrdBatId	int,
		SchType		int
	)
	DECLARE @QPSGivenFlat TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	DECLARE @TempBilledFinal TABLE
	(
		PrdMode			INT,
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId	INT,
		SchemeOnQty		NUMERIC(18,0),
		SchemeOnAmount	NUMERIC(18,6),
		SchemeOnKG		NUMERIC(18,6),
		SchemeOnLitre	NUMERIC(18,6),
		SchId			BIGINT,
		MinAmount		NUMERIC(18,6),
		DiscPer			NUMERIC(18,2),
		FlatAmt			NUMERIC(18,6),
		Points			NUMERIC(18,0)
	)
	DECLARE @QPSGivenFlatAmt AS NUMERIC(38,6)
	DECLARE @Config		AS	INT
	SET @Config=0
	
	SELECT @Config=Status FROM Configuration WHERE ModuleId='BILLQPS3'


	SELECT @SchCode = SchCode,@SchType = SchType,@BatchLevel = BatchLevel,@FlexiSch = FlexiSch,
		@FlexiSchType = FlexiSchType,@CombiScheme = CombiSch,@SchLevelId = SchLevelId,@ProRata = ProRata,
		@Qps = QPS,@QpsReset = QPSReset,@QPSBasedOn=ApyQPSSch,@SchemeBudget = Budget,@PurOfEveryReq = PurofEvery,
		@SchemeLvlMode = SchemeLvlMode,@CombiType=CombiType,@SchValidTill=SchValidTill,@SchValidFrom=SchValidFrom
	FROM SchemeMaster WHERE SchId = @Pi_SchId AND MasterType=1
	IF @CombiType=1
	BEGIN
		SET @TransMode=-1
		-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
		INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
		SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,
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
			SELECT @SchLevelId = SUBSTRING(LevelName,6,LEN(LevelName)) from ProductCategoryLevel
			WHERE CmpPrdCtgId = @SchLevelId
			
			INSERT INTO @TempHier (PrdId,PrdBatId,PrdCtgValMainId)
			SELECT DISTINCT D.PrdId,E.PrdBatId,C.PrdCtgValMainId FROM ProductCategoryValue C
			INNER JOIN ( Select LEFT(PrdCtgValLinkCode,@SchLevelId*5) as PrdCtgValLinkCode,A.Prdid from Product A
			INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId
			INNER JOIN @TempBilled F ON A.PrdId = F.PrdId) AS D ON
			D.PrdCtgValLinkCode = C.PrdCtgValLinkCode INNER JOIN ProductBatch E
			ON D.PrdId = E.PrdId
			SELECT @NoofLines=NoofLines FROM SchemeCombiCriteria WHERE SchId=@Pi_SchId
			IF @Pi_SalId<>0
			BEGIN
				IF NOT EXISTS (SELECT A.SalId FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeLineWise B
							ON A.SalId=B.SalId WHERE B.SchId=@Pi_SchId AND A.RtrId=@Pi_RtrId AND A.SalId<>@Pi_SalId AND A.DlvSts>3)
				BEGIN
					SET @TransMode=0
					IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 1 AS PrdMode,0,0,A.PrdCtgValMainId,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdCtgValMainId=C.PrdCtgValMainId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode=1 GROUP BY A.PrdCtgValMainId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					ELSE
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 2 AS PrdMode,A.PrdId,A.PrdBatId,0,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdId=C.PrdId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode<>1 GROUP BY A.PrdId,A.PrdBatId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					
				END
				ELSE
				BEGIN
					SET @TransMode=1
					IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 1 AS PrdMode,0,0,A.PrdCtgValMainId,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdCtgValMainId=C.PrdCtgValMainId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode=1 GROUP BY A.PrdCtgValMainId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					ELSE
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 2 AS PrdMode,A.PrdId,A.PrdBatId,0,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdId=C.PrdId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode<>1 GROUP BY A.PrdId,A.PrdBatId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END					
				END
			END
			ELSE
			BEGIN
				IF NOT EXISTS (SELECT A.SalId FROM SalesInvoice A INNER JOIN SalesInvoiceSchemeLineWise B
				ON A.SalId=B.SalId WHERE B.SchId=@Pi_SchId AND A.RtrId=@Pi_RtrId AND A.SalId<>@Pi_SalId  AND A.DlvSts>3)
				BEGIN
					SET @TransMode=0
					IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 1 AS PrdMode,0,0,A.PrdCtgValMainId,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdCtgValMainId=C.PrdCtgValMainId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode=1 GROUP BY A.PrdCtgValMainId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					ELSE
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 2 AS PrdMode,A.PrdId,A.PrdBatId,0,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdId=C.PrdId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode<>1 GROUP BY A.PrdId,A.PrdBatId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
				END
				ELSE
				BEGIN
					SET @TransMode=1
					IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 1 AS PrdMode,0,0,A.PrdCtgValMainId,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdCtgValMainId=C.PrdCtgValMainId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode=1 GROUP BY A.PrdCtgValMainId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END
					ELSE
					BEGIN
						INSERT INTO @TempBilledFinal(PrdMode,PrdId,PrdBatId,PrdCtgValMainId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,
													SchId,MinAmount,DiscPer,FlatAmt,Points)
						SELECT 2 AS PrdMode,A.PrdId,A.PrdBatId,0,SUM(SchemeOnQty) AS SchemeOnQty,
						SUM(SchemeOnAmount) AS SchemeOnAmount,SUM(SchemeOnKG) AS SchemeOnKG,SUM(SchemeOnLitre) AS SchemeOnLitre,
						B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points FROM @TempHier A INNER JOIN @TempBilled B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
						INNER JOIN SchemeCombiCriteria C ON B.SchId=C.SchId AND A.PrdId=C.PrdId
						WHERE B.SchId=@Pi_SchId AND C.PrdMode<>1 GROUP BY A.PrdId,A.PrdBatId,B.SchId,C.MinAmount,C.DiscPer,C.FlatAmt,C.Points
					END	
				END
			END
			IF @TransMode=1
			BEGIN
				IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
				BEGIN
					INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
					Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
					FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
					BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
					SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
						1 as SlabId,0 as SchAmount,A.DiscPer as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
						0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,0,0 as FreePrdBatId,
						0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
						0 as GiftToBeGiven,1 as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
						0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,B.PrdId,B.PrdBatId,0
						FROM @TempBilledFinal A INNER JOIN @TempHier B ON A.PrdCtgValMainId=B.PrdCtgValMainId
						INNER JOIN BilledPrdHdForScheme C (NOLOCK) ON B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
						INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) D ON C.PrdId = D.PrdId AND 
						C.PrdBatId = CASE D.PrdBatId WHEN 0 THEN C.PrdBatId ELSE D.PrdBatId End
						WHERE C.Usrid = @Pi_UsrId AND C.TransId = @Pi_TransId
				END
				ELSE
				BEGIN
					INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
					Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
					FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
					BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
					SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
						1 as SlabId,0 as SchAmount,A.DiscPer as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
						0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,0,0 as FreePrdBatId,
						0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
						0 as GiftToBeGiven,1 as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
						0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,A.PrdId,A.PrdBatId,0
						FROM @TempBilledFinal A INNER JOIN @TempHier B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdbatId
				END
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT * FROM SchemeCombiCriteria WHERE PrdMode=1 AND SchId=@Pi_SchId)
				BEGIN
					IF EXISTS(SELECT A.SchId,COUNT(A.PrdCtgValMainId) AS Cnt FROM	@TempBilledFinal A
					INNER JOIN SchemeCombiCriteria B ON A.SchId=B.SchId AND A.PrdCtgValMainId=B.PrdCtgValMainId
					WHERE A.SchId=@Pi_SchId AND A.SchemeOnAmount>=B.MinAmount AND B.PrdMode=1 GROUP BY A.SchId
					HAVING COUNT(A.PrdCtgValMainId)>=@NoofLines)
					BEGIN
						INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
						Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
						FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
						BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
						SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
							1 as SlabId,0 as SchAmount,A.DiscPer as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
							0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,0,0 as FreePrdBatId,
							0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
							0 as GiftToBeGiven,1 as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
							0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,B.PrdId,B.PrdBatId,0
							FROM @TempBilledFinal A INNER JOIN @TempHier B ON A.PrdCtgValMainId=B.PrdCtgValMainId
							INNER JOIN BilledPrdHdForScheme C (NOLOCK) ON B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
							INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) D ON C.PrdId = D.PrdId AND 
							C.PrdBatId = CASE D.PrdBatId WHEN 0 THEN C.PrdBatId ELSE D.PrdBatId End
							WHERE C.Usrid = @Pi_UsrId AND C.TransId = @Pi_TransId
					END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT A.SchId,COUNT(A.PrdId) AS Cnt FROM	@TempBilledFinal A
					INNER JOIN SchemeCombiCriteria B ON A.SchId=B.SchId AND A.PrdId=B.PrdId
					WHERE A.SchId=@Pi_SchId AND A.SchemeOnAmount>=B.MinAmount AND B.PrdMode<>1 GROUP BY A.SchId
					HAVING COUNT(A.PrdId)>=@NoofLines)
					BEGIN
						INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
						Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
						FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
						BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
						SELECT DISTINCT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
							1 as SlabId,0 as SchAmount,A.DiscPer as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
							0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,0,0 as FreePrdBatId,
							0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
							0 as GiftToBeGiven,1 as NoOfTimes,0 as IsSelected,@SchemeBudget as SchBudget,
							0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,A.PrdId,A.PrdBatId,0
							FROM @TempBilledFinal A INNER JOIN @TempHier B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					END
				END
			END
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT * FROM SalesInvoice WHERE SalId = @Pi_SalId)
		BEGIN
			SELECT @BillDate = SalInvDate FROM SalesInvoice WHERE SalId = @Pi_SalId
		END
		ELSE
		BEGIN
			SET @BillDate = CONVERT(VARCHAR(10),GETDATE(),121)
		END
		IF EXISTS(SELECT * FROM SchemeMaster WHERE SchId = @Pi_SchId AND SchValidTill >= @BillDate)
		BEGIN
			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,
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
		END
		IF @QPS <> 0
		BEGIN
		--		--To Add the Cumulative Qty
			IF @QPSBasedOn=2
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
			ELSE
			BEGIN -- Added by Boopathy on 02-08-2011 for QPS DATE BASED ISSUE FROM J&J Site (Older schemes are getting apply)
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)	
					SELECT PrdId,PrdBatId,SUM(SchemeOnQty),SUM(SchemeOnAmount),SUM(SchemeOnKg),SUM(SchemeOnLitre),SchId FROM 
					(	SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
							(SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(	SELECT A.SalId,A.SchId,PrdId,PrdBatId FROM SalesInvoiceSchemeDtBilled A INNER JOIN SchemeMaster B 
							ON A.SchId=B.SchId WHERE A.SchId=@Pi_SchId
						) B	ON  A.SalId =B.SalId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
						) AS A 
						INNER JOIN 
						(
							SELECT A.SalId,A.SchId FROM SalesInvoiceUnSelectedScheme A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
							WHERE A.SchId=@Pi_SchId
						) B ON A.SalId=B.SalId AND A.SchId=@Pi_SchId
					UNION
						SELECT A.SalId,A.PrdId,A.PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,A.SchId FROM 
						(	SELECT A.SalId,A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty-A.ReturnedQty),0) AS SchemeOnQty,
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
							GROUP BY A.SalId,A.PrdId,A.PrdBatId,D.PrdUnitId
							
						) AS A 
					)AS A GROUP BY PrdId,PrdBatId,SchId
			END
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
				IF @QPSBasedOn=1 OR (@QPSBasedOn<>1 AND @FlexiSch=1)
				BEGIN
					INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
					SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
						-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
						-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
						FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
						AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
				END
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				SELECT PrdId,PrdBatId,ISNULL(SUM(SumQty),0) AS SchemeOnQty,
					ISNULL(SUM(SumValue),0) AS SchemeOnAmount,ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
					ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
					FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
					GROUP BY PrdId,PrdBatId
		END
		INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
		ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
		GROUP BY PrdId,PrdBatId,SchId
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
		INSERT INTO @TempBilledAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
		SELECT F.PrdId,F.PrdBatId,F.PrdCtgValMainId,ISNULL(CASE @SchType
			WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
			WHEN 2 THEN SUM(SchemeOnAmount)
			WHEN 3 THEN (CASE A.UomId
					WHEN 2 THEN SUM(SchemeOnKg)* 1000
					WHEN 3 THEN SUM(SchemeOnKg)
					WHEN 4 THEN SUM(SchemeOnLitre) * 1000
					WHEN 5 THEN SUM(SchemeOnLitre)	END)
				END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
			A.Slabid,F.SlabValue as FromQty,A.UomId
			FROM SchemeSlabs A
			INNER JOIN SchemeSlabCombiPrds F ON A.SchId = F.SchId AND F.SchId = @Pi_SchId
			AND A.SlabId = F.SlabId
			INNER JOIN @TempBilled B ON A.SchId = B.SchId AND A.SchId = @Pi_SchId
			INNER JOIN Product C ON B.PrdId = C.PrdId
			INNER JOIN @TempHier G ON G.PrdId = CASE F.PrdId WHEN 0 THEN G.PrdId ELSE F.PrdId END
			AND G.PrdBatId = CASE F.PrdBatId WHEN 0 THEN G.PrdBatId ELSE F.PrdBatId END
			AND G.PrdCtgValMainId = CASE F.PrdCtgValMainId WHEN 0 THEN G.PrdCtgValMainId ELSE F.PrdCtgValMainId END
			AND B.PrdId = G.PrdId AND B.PrdBatId = G.PrdBatId
			LEFT OUTER JOIN UomGroup D ON D.UomGroupId = C.UomGroupId AND D.UomId = A.UomId
			GROUP BY F.PrdId,F.PrdBatId,F.PrdCtgValMainId,A.UomId,A.Slabid,A.PurQty,F.SlabValue,A.UomId
		SET @QpsResetAvail = 0
		IF @QpsReset <> 0
		BEGIN
			INSERT INTO @TempBilledQpsReset(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT A.* FROM @TempBilledAch A
				INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
				AND A.PrdCtgValMainId = B.PrdCtgValMainId
			
			--Select the Applicable Slab for the Scheme
			SELECT @SlabId = ISNULL(MAX(A.SlabId),0)  FROM
				(SELECT COUNT(SlabId) AS CntAch,SlabId FROM @TempBilledQpsReset GROUP BY SlabId) AS A
				INNER JOIN
				(SELECT COUNT(SlabId) AS CntSch,SlabId FROM SchemeSlabCombiPrds WHERE SchId = @Pi_SchId
				GROUP BY SlabId) AS B ON A.SlabId = B.SlabId AND A.CntAch = B.CntSch
			SET @QpsResetAvail = 1
		END
		IF @QpsResetAvail = 1
		BEGIN
			INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,B.SlabValue,A.FrmUomAch,@SlabId,B.SlabValue,A.FrmUomAch
				FROM @TempBilledAch A INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				AND B.SlabId = @SlabId WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId
				AND A.PrdBatId = B.PrdBatId AND A.PrdCtgValMainId = B.PrdCtgValMainId
				AND B.SchId = @Pi_SchId
		END
		ELSE
		BEGIN
			INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT A.* FROM @TempBilledAch A INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
				AND A.PrdCtgValMainId = B.PrdCtgValMainId AND B.SchId = @Pi_SchId
		END

		WHILE (SELECT ISNULL(SUM(FrmSchAch),0) FROM @TempBilledCombiAch) > 0
		BEGIN
			DELETE FROM @TempRedeem
			--Select the Applicable Slab for the Scheme
			SELECT @SlabId = ISNULL(MAX(A.SlabId),0)  FROM
				(SELECT COUNT(SlabId) AS CntAch,SlabId FROM @TempBilledCombiAch GROUP BY SlabId) AS A
				INNER JOIN
				(SELECT COUNT(SlabId) AS CntSch,SlabId FROM SchemeSlabCombiPrds WHERE SchId = @Pi_SchId
				GROUP BY SlabId) AS B ON A.SlabId = B.SlabId AND A.CntAch = B.CntSch
			
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
--			SELECT @NoOfTimes = ISNULL(MIN(NoOfTimes),1) FROM
--				(SELECT ROUND((FrmSchAch / (CASE FromQty WHEN 0 THEN 1 ELSE FROMQTY END)),0) AS NoOfTimes
--				FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId) AS A
			IF @QPS=0 AND @CombiScheme=1
			BEGIN
				IF @PurOfEveryReq=0
				BEGIN
					SET @NoOfTimes=1
				END
				ELSE
				BEGIN
					SELECT @NoOfTimes = ISNULL(MIN(NoOfTimes),1) FROM
					(SELECT ROUND((SUM(FrmSchAch) / (CASE SUM(FromQty) WHEN 0 THEN 1 ELSE SUM(FromQty) END)),0) AS NoOfTimes
					FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId) AS A
				END
			END
			ELSE
			BEGIN
				SELECT @NoOfTimes = ISNULL(MIN(NoOfTimes),1) FROM
					(SELECT ROUND((FrmSchAch / (CASE FromQty WHEN 0 THEN 1 ELSE FROMQTY END)),0) AS NoOfTimes
					FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId) AS A
			END
			IF @SchType = 1
			BEGIN
				DECLARE Cur_Qty Cursor For
					SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
						FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
						ORDER BY FrmSchAch Desc
				OPEN Cur_Qty
				FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
					@FrmUomAch,@FromQty,@UomId
				WHILE @@FETCH_STATUS =0
				BEGIN
					IF @PrdCtgValMainId > 0
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
								WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
								AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE
								A.PrdBatId END AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0
								THEN B.PrdCtgValMainId ELSE A.PrdCtgValMainId END AND
								B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
								AND A.SlabId = @SlabId AND B.PrdCtgValMainId = @PrdCtgValMainId
								ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SELECT @AssignQty = @FrmSchAchRem * ConversionFactor FROM
								Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
								AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					ELSE
					IF (@PrdId > 0 AND @PrdBatId = 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,
								@TempBilled C WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId
								ELSE A.PrdId END AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN
								B.PrdBatId ELSE A.PrdBatId END AND B.PrdCtgValMainId = CASE
								A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE
								A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND
								B.PrdBatId = C.PrdBatId AND A.SlabId = @SlabId AND
								B.PrdId = @PrdId ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SELECT @AssignQty = @FrmSchAchRem * ConversionFactor FROM
								Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
								AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END	
					ELSE
					IF (@PrdId > 0 AND @PrdBatId > 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
							WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
							AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
							AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId
							ELSE A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
							AND A.SlabId = @SlabId AND B.PrdId = @PrdId AND B.PrdBatId = @PrdBatId
							ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SELECT @AssignQty = @FrmSchAchRem * ConversionFactor FROM
								Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
								AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
						@FrmUomAch,@FromQty,@UomId
				END
				CLOSE Cur_Qty
				DEALLOCATE Cur_Qty
			END
			IF @SchType = 2
			BEGIN
				DECLARE Cur_Qty Cursor For
					SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
						FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
						ORDER BY FrmSchAch Desc
				OPEN Cur_Qty
				FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
					@FrmUomAch,@FromQty,@UomId
				WHILE @@FETCH_STATUS =0
				BEGIN
					IF @PrdCtgValMainId > 0
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
								WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
								AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE
								A.PrdBatId END AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0
								THEN B.PrdCtgValMainId ELSE A.PrdCtgValMainId END AND
								B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
								AND A.SlabId = @SlabId AND B.PrdCtgValMainId = @PrdCtgValMainId
								ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignAmount = @FrmSchAchRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					ELSE
					IF (@PrdId > 0 AND @PrdBatId = 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,
								@TempBilled C WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId
								ELSE A.PrdId END AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN
								B.PrdBatId ELSE A.PrdBatId END AND B.PrdCtgValMainId = CASE
								A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE
								A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND
								B.PrdBatId = C.PrdBatId AND A.SlabId = @SlabId AND
								B.PrdId = @PrdId ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignAmount = @FrmSchAchRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END	
					ELSE
					IF (@PrdId > 0 AND @PrdBatId > 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
							WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
							AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
							AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId
							ELSE A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
							AND A.SlabId = @SlabId AND B.PrdId = @PrdId AND B.PrdBatId = @PrdBatId
							ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignAmount = @FrmSchAchRem
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
						@FrmUomAch,@FromQty,@UomId
				END
				CLOSE Cur_Qty
				DEALLOCATE Cur_Qty
			END
			IF @SchType = 3
			BEGIN
				DECLARE Cur_Qty Cursor For
					SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
						FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
						ORDER BY FrmSchAch Desc
				OPEN Cur_Qty
				FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
					@FrmUomAch,@FromQty,@UomId
				WHILE @@FETCH_STATUS =0
				BEGIN
					IF @PrdCtgValMainId > 0
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
								WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
								AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE
								A.PrdBatId END AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0
								THEN B.PrdCtgValMainId ELSE A.PrdCtgValMainId END AND
								B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
								AND A.SlabId = @SlabId AND B.PrdCtgValMainId = @PrdCtgValMainId
								ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
									(@FrmSchAchRem / 1000) WHEN 3 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
			
								SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
									(@FrmSchAchRem / 1000) WHEN 5 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
								SET @AssignQty = (SELECT CASE PrdUnitId
									WHEN 2 THEN
										(@AssignKG /(CASE PrdWgt WHEN 0 THEN 1 ELSE
											PrdWgt END / 1000))
									WHEN 3 THEN
										(@AssignKG/(CASE PrdWgt WHEN 0 THEN 1 ELSE PrdWgt END))
									WHEN 4 THEN
										(@AssignLitre /(CASE PrdWgt WHEN 0 THEN 1 ELSE
											PrdWgt END / 1000))
									WHEN 5 THEN								(@AssignLitre/(CASE PrdWgt WHEN 0 THEN 1
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					ELSE
					IF (@PrdId > 0 AND @PrdBatId = 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
								FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,
								@TempBilled C WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId
								ELSE A.PrdId END AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN
								B.PrdBatId ELSE A.PrdBatId END AND B.PrdCtgValMainId = CASE
								A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE
								A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND
								B.PrdBatId = C.PrdBatId AND A.SlabId = @SlabId AND
								B.PrdId = @PrdId ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,					
						@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
									(@FrmSchAchRem / 1000) WHEN 3 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
			
								SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
									(@FrmSchAchRem / 1000) WHEN 5 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
							
						END
						CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END	
					ELSE
					IF (@PrdId > 0 AND @PrdBatId > 0)
					BEGIN
						DECLARE Cur_Redeem Cursor For
							SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
							WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
							AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
							AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId
							ELSE A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
							AND A.SlabId = @SlabId AND B.PrdId = @PrdId AND B.PrdBatId = @PrdBatId
							ORDER BY FrmSchAch Desc
						OPEN Cur_Redeem
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
							@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
						WHILE @@FETCH_STATUS =0
						BEGIN
							WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
							BEGIN
								SET @AssignQty  = 0
								SET @AssignAmount = 0
								SET @AssignKG = 0
								SET @AssignLitre = 0
								SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
									(@FrmSchAchRem / 1000) WHEN 3 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
			
								SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
									(@FrmSchAchRem / 1000) WHEN 5 THEN
									(@FrmSchAchRem) ELSE
									0 END FROM Product WHERE PrdId = @PrdIdRem)
								SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
							END
							FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
							@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
							@UomIdRem
						END				CLOSE Cur_Redeem
						DEALLOCATE Cur_Redeem
					END
					FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
						@FrmUomAch,@FromQty,@UomId
				END
				CLOSE Cur_Qty
				DEALLOCATE Cur_Qty
			END
			--To Store the Gross amount for the Scheme billed Product
			SELECT @GrossAmount = ISNULL(SUM(SchemeOnAmount),0) FROM @TempRedeem
			INSERT INTO BilledPrdRedeemedForQPS (RtrId,SchId,PrdId,PrdBatId,SumQty,SumValue,SumInKG,
				SumInLitre,UserId,TransId)
			SELECT @Pi_RtrId,@Pi_SchId,PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,
				SchemeOnLitre,@Pi_UsrId,@Pi_TransId FROM @TempRedeem
			--->Added By Nanda on 29/10/2010
			IF EXISTS(SELECT * FROM @TempSchSlabAmt WHERE DiscPer=0)
			BEGIN
				INSERT INTO @QPSGivenFlat
				SELECT SchId,SUM(FlatAmount)
				FROM
				(
					SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount,0)-ISNULL(ReturnFlatAmount,0) AS FlatAmount
					FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM,SalesInvoice SI
					WHERE SM.QPS=1 AND FlexiSch=0 
					AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3			
				) A
				GROUP BY A.SchId	
			END
			UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
			FROM @QPSGivenFlat A,
			(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
			WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND SI.SalId=B.SalId AND SI.DlvSts>3
			GROUP BY B.SchId) C
			WHERE A.SchId=C.SchId 
			IF @FlexiSch=0
			BEGIN
				INSERT INTO @QPSGivenFlat
				SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
				WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenFlat)
				AND B.SchId IN (SELECT DISTINCT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId AND SchemeDiscount=0)
				AND SI.SalId=B.SalId AND SI.DlvSts>3
				GROUP BY B.SchId
			END
			SELECT @QPSGivenFlatAmt=ISNULL(SUM(Amount),0) FROM @QPSGivenFlat WHERE SchId=@Pi_SchId
			DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
			INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
			SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat
			--->Till Here
			--To Calculate the Scheme Flat Amount and Discount Percentage
			--Scheme Discount for Flat amount = ((FlatAmt * (LineLevel Gross / Total Gross) * 100)/100) * number of times
			--Scheme Discount for Disc Perc   = (LineLevel Gross * Disc Percentage) / 100
			
			IF @QPS=0
			BEGIN
				INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
					Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
					FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
					BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
				SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,
					SchemeDiscount AS SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,
					IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
					FROM
					(
						SELECT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
						@SlabId as SlabId,PrdId,PrdBatId,
						(CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END) As Contri,
						((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
						As SchemeAmount,DiscPer AS SchemeDiscount,(Points *@NoOfTimes) as Points,
						FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,0 as FreePrdId,0 as FreePrdBatId,
						0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,
						0 as IsSelected,@SchemeBudget as SchBudget,0 as BudgetUtilized,@Pi_TransId As TransId,
						@Pi_UsrId as UsrId FROM @TempRedeem , @TempSchSlabAmt
						WHERE (FlatAmt + DiscPer + FlxDisc + FlxValueDisc + FlxFreePrd + FlxGiftPrd + Points) >=0
					) AS B
					GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeDiscount,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,
					GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
			END
			ELSE
			BEGIN
				UPDATE @TempSchSlabAmt SET FlatAmt=FlatAmt-@QPSGivenFlatAmt
				INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
					Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
					FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
					BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
				SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,
					SchemeDiscount AS SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
					FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,
					IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
					FROM
					(
						SELECT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
						@SlabId as SlabId,PrdId,PrdBatId,
						(CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END) As Contri,
						((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
						As SchemeAmount,DiscPer AS SchemeDiscount,(Points *@NoOfTimes) as Points,
						FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,0 as FreePrdId,0 as FreePrdBatId,
						0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,
						0 as IsSelected,@SchemeBudget as SchBudget,0 as BudgetUtilized,@Pi_TransId As TransId,
						@Pi_UsrId as UsrId FROM @TempRedeem , @TempSchSlabAmt
						WHERE (FlatAmt + DiscPer + FlxDisc + FlxValueDisc + FlxFreePrd + FlxGiftPrd + Points) >=0
					) AS B
					GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeDiscount,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,
					GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
			END
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
			UPDATE @TempBilledQPSReset Set FrmSchach = A.FrmSchAch - B.FrmSchAch
				FROM @TempBilledQPSReset A INNER JOIN @TempBilledCombiAch B
				ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId AND
				A.PrdCtgValMainId = B.PrdCtgValMainId
			DELETE FROM @TempBilledCombiAch
			INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT A.* FROM @TempBilledQPSReset A
				INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
				AND A.PrdCtgValMainId = B.PrdCtgValMainId  AND B.SchId = @Pi_SchId
			SELECT @SlabId = ISNULL(MAX(A.SlabId),0)  FROM
				(SELECT COUNT(SlabId) AS CntAch,SlabId FROM @TempBilledCombiAch GROUP BY SlabId) AS A
				INNER JOIN
				(SELECT COUNT(SlabId) AS CntSch,SlabId FROM SchemeSlabCombiPrds WHERE SchId = @Pi_SchId
				GROUP BY SlabId) AS B ON A.SlabId = B.SlabId AND A.CntAch = B.CntSch
			DELETE FROM @TempBilledCombiAch
			INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
			SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,B.SlabValue,A.FrmUomAch,@SlabId,B.SlabValue,A.FrmUomAch
				FROM @TempBilledAch A INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
				AND B.SlabId = @SlabId WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId
				AND A.PrdBatId = B.PrdBatId AND A.PrdCtgValMainId = B.PrdCtgValMainId
				AND B.SchId = @Pi_SchId
			
			DELETE FROM @TempSchSlabAmt
			DELETE FROM @TempSchSlabFree
		END
		INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
			Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
			FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
			BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
		SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount),SUM(SchemeDiscount),
			SUM(Points),FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
			FreePrdBatId,SUM(FreeToBeGiven),GiftPrdId,GiftPrdBatId,SUM(GiftToBeGiven),SUM(NoOfTimes),
			IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,0 FROM @BillAppliedSchemeHd
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
				WHERE SchCode=@SchCode AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 )
				UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
				PrdId IN (SELECT PrdId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId) AND
				PrdBatId IN (SELECT PrdBatId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
				AND SchemeAmount =0
			END
		END
		DECLARE @TotalGross		AS	NUMERIC(18,6)
		IF @QPS=0 AND @CombiScheme=1
		BEGIN
			IF EXISTS (SELECT * FROM SchemeSlabCombiPrds WHERE PrdId>0 AND SchId=@Pi_SchId)
			BEGIN
				DELETE FROM @BillAppliedSchemeHd
				DECLARE @PrdWiseSch TABLE
				(
					SchId			INT,
					PrdCtgValMainId	INT,
					PrdId			INT,
					PrdbatId		INT
				)
				DECLARE @PrdWiseSchTemp TABLE
				(
					SchId			INT,
					PrdId			INT,
					PrdbatId		INT
				)
				INSERT INTO @PrdWiseSch
				SELECT DISTINCT A.SchId,B.PrdCtgValMainId,A.PrdId,A.PrdBatId FROM BillAppliedSchemeHd A INNER JOIN @TempHier B ON A.PrdId=B.PrdId 
				AND A.PrdbatId=B.PrdBatId WHERE A.SchId=@Pi_SchId AND A.TransId= @Pi_TransId AND Usrid = @Pi_UsrId
				INSERT INTO @PrdWiseSchTemp
				SELECT DISTINCT A.SchId,B.PrdId,B.PrdBatId FROM @PrdWiseSch A,BilledPrdHdForScheme B (NOLOCK) 
				INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) C ON
				B.PrdId = C.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE B.PrdBatId End
				WHERE B.TransId = @Pi_TransId AND B.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
				DELETE FROM @PrdWiseSchTemp
				WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) IN
				(SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillAppliedSchemeHd
				WHERE TransId = @Pi_TransId AND Usrid = @Pi_UsrId AND SchId=@Pi_SchId)
				SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
				AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId
				IF EXISTS (SELECT * FROM SchemeSlabs WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND (FlatAmt+FlxValueDisc)>0)
				BEGIN
					INSERT INTO BillAppliedSchemeHd
					SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.Points,
					A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
					A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
					A.BudgetUtilized,A.TransId,A.Usrid,A.PrdId,B.PrdBatId,A.SchType FROM BillAppliedSchemeHd A
					INNER JOIN @PrdWiseSchTemp B ON A.SchId=B.SchId AND A.PrdId=B.PrdId
					WHERE A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId
					SELECT @TotalGross=SUM(B.GrossAmount) FROM BillAppliedSchemeHd A
					INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId
					UPDATE A SET SchemeAmount=  (((SELECT (FlatAmt+FlxValueDisc) FROM SchemeSlabs WHERE 
												SchId=@Pi_SchId AND SlabId=@SlabId)*( B.GrossAmount/@TotalGross)))*@NoOfTimes
					FROM BillAppliedSchemeHd A	INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId 
				END
				ELSE IF EXISTS (SELECT * FROM SchemeSlabs WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND (DiscPer+FlxDisc)>0)
				BEGIN
					INSERT INTO BillAppliedSchemeHd
					SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.Points,
					A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
					A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
					A.BudgetUtilized,A.TransId,A.Usrid,A.PrdId,B.PrdBatId,A.SchType FROM BillAppliedSchemeHd A
					INNER JOIN @PrdWiseSchTemp B ON A.SchId=B.SchId AND A.PrdId=B.PrdId
					WHERE A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId
					UPDATE A SET SchemeDiscount=  (((SELECT (DiscPer+FlxDisc) FROM SchemeSlabs WHERE 
												SchId=@Pi_SchId AND SlabId=@SlabId)))*@NoOfTimes
					FROM BillAppliedSchemeHd A	INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId 
				END
			END
			ELSE
			BEGIN
				DELETE FROM BillAppliedSchemeHd WHERE PrdId=0
				DELETE FROM @BillAppliedSchemeHd
				DECLARE @BrandWiseSch TABLE
				(
					SchId			INT,
					PrdCtgValMainId	INT,
					PrdId			INT,
					PrdbatId		INT
				)
				DECLARE @BrandWiseSchTemp TABLE
				(
					SchId			INT,
					PrdId			INT,
					PrdbatId		INT
				)
				INSERT INTO @BrandWiseSch
				SELECT DISTINCT A.SchId,B.PrdCtgValMainId,A.PrdId,A.PrdBatId FROM BillAppliedSchemeHd A INNER JOIN @TempHier B ON A.PrdId=B.PrdId 
				AND A.PrdbatId=B.PrdBatId WHERE A.SchId=@Pi_SchId AND A.TransId= @Pi_TransId AND Usrid = @Pi_UsrId
				INSERT INTO @BrandWiseSchTemp
				SELECT DISTINCT A.SchId,B.PrdId,B.PrdBatId FROM @BrandWiseSch A,BilledPrdHdForScheme B (NOLOCK) 
				INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) C ON
				B.PrdId = C.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE B.PrdBatId End
				WHERE B.TransId = @Pi_TransId AND B.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
				DELETE FROM @BrandWiseSchTemp
				WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) IN
				(SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillAppliedSchemeHd
				WHERE TransId = @Pi_TransId AND Usrid = @Pi_UsrId AND SchId=@Pi_SchId)
				SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
				AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId
				IF EXISTS (SELECT * FROM SchemeSlabs WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND (FlatAmt+FlxValueDisc)>0)
				BEGIN
				INSERT INTO BillAppliedSchemeHd
					SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.Points,
					A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
					A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
					A.BudgetUtilized,A.TransId,A.Usrid,B.PrdId,B.PrdBatId,A.SchType FROM
					(SELECT DISTINCT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,0 AS SchemeAmount,A.SchemeDiscount,A.Points,
					A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
					A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
					A.BudgetUtilized,A.TransId,A.Usrid,0 AS PrdId,0 AS PrdBatId,A.SchType FROM BillAppliedSchemeHd A
					WHERE A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId) A
					INNER JOIN @BrandWiseSchTemp B ON A.SchId=B.SchId
					
					SELECT @TotalGross=SUM(B.GrossAmount) FROM BillAppliedSchemeHd A
					INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId
					UPDATE A SET SchemeAmount=  (((SELECT (FlatAmt+FlxValueDisc) FROM SchemeSlabs WHERE 
												SchId=@Pi_SchId AND SlabId=@SlabId)*( B.GrossAmount/@TotalGross)))*@NoOfTimes
					FROM BillAppliedSchemeHd A	INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId 
				END
				ELSE IF EXISTS (SELECT * FROM SchemeSlabs WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND (DiscPer+FlxDisc)>0)
				BEGIN
					INSERT INTO BillAppliedSchemeHd
						SELECT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.Points,
						A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
						A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
						A.BudgetUtilized,A.TransId,A.Usrid,B.PrdId,B.PrdBatId,A.SchType FROM
						(SELECT DISTINCT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,0 AS SchemeAmount,A.SchemeDiscount,A.Points,
						A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FlxPoints,A.FreePrdId,A.FreePrdBatId,
						A.FreeToBeGiven,A.GiftPrdId,A.GiftPrdBatId,A.GiftToBeGiven,A.NoOfTimes,A.IsSelected,A.SchBudget,
						A.BudgetUtilized,A.TransId,A.Usrid,0 AS PrdId,0 AS PrdBatId,A.SchType FROM BillAppliedSchemeHd A
						WHERE A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId AND A.SchId=@Pi_SchId) A
						INNER JOIN @BrandWiseSchTemp B ON A.SchId=B.SchId
					UPDATE A SET SchemeDiscount=  (((SELECT (DiscPer+FlxDisc) FROM SchemeSlabs WHERE 
												SchId=@Pi_SchId AND SlabId=@SlabId)))*@NoOfTimes
					FROM BillAppliedSchemeHd A	INNER JOIN  BilledPrdHdForScheme B (NOLOCK) ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
					AND A.TransId=B.TransId	AND A.UsrId=B.UsrId AND A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId
					WHERE 	A.TransId = @Pi_TransId AND A.Usrid = @Pi_UsrId 
				END
			END
		END
		SELECT DISTINCT * INTO #BillAppliedSchemeHd FROM BillAppliedSchemeHd WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId
		DELETE FROM BillAppliedSchemeHd WHERE Usrid = @Pi_UsrId AND TransId = @Pi_TransId
		INSERT INTO BillAppliedSchemeHd
		SELECT * FROM #BillAppliedSchemeHd
		SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
		AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId
		EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
		UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
		SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
		TransId = @Pi_TransId AND Usrid = @Pi_UsrId
		--Added By Murugan
		IF @QPS<>0
		BEGIN
			DELETE FROM BilledPrdHdForQPSScheme WHERE Transid=@Pi_TransId and Usrid=@Pi_UsrId AND SchId=@Pi_SchId
			INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT RowId,@Pi_RtrId,BP.PrdId,BP.Prdbatid,SelRate,BaseQty,BaseQty*SelRate AS SchemeOnAmount,MRP,@Pi_TransId,@Pi_UsrId,ListPrice,0,@Pi_SchId
			From BilledPrdHdForScheme BP WHERE BP.TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND BP.RtrId=@Pi_RtrId --AND BP.SchId=@Pi_SchId
			INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
			From @TempBilled TB 	
		END
		--Till Here

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
	END
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_QPSSchemeCrediteNoteConversion')
DROP PROCEDURE Proc_QPSSchemeCrediteNoteConversion
GO
/*
BEGIN TRANSACTION
EXEC Proc_QPSSchemeCrediteNoteConversion 2,'2011-11-20',0
SELECT * FROM SchQPSConvDetails 
SELECT * FROM SalesInvoiceQpsDatebasedTrack
SELECT * FROM CreditNoteRetailer
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_QPSSchemeCrediteNoteConversion]
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
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_CS2CN_QPSDataBasedCrNoteTrack')
DROP PROCEDURE Proc_CS2CN_QPSDataBasedCrNoteTrack
GO
/*
BEGIN TRANSACTION
EXEC Proc_CS2CN_QPSDataBasedCrNoteTrack 0
SELECT * FROM CS2CN_QPSDataBasedCrNoteTrack
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_CS2CN_QPSDataBasedCrNoteTrack]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_CS2CN_QPSDataBasedCrNoteTrack
* PURPOSE		: To Extract Invoice wise details QPS Data Based Scheme
* CREATED BY	: Boopathy.P
* CREATED DATE	: 2011-11-16
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
	DELETE FROM CS2CN_QPSDataBasedCrNoteTrack WHERE UploadFlag = 'Y'

	SELECT @DistCode = DistributorCode FROM Distributor	

	INSERT INTO CS2CN_QPSDataBasedCrNoteTrack
	(
		DistCode,
		TransName,
		TransRefId,
		TransRefCode,
		RtrId,
		RtrCode,
		Rtrname,
		Schid,
		SchCode,
		SchDesc,
		PrdId,
		PrdCCode,
		PrdBatId,
		PrdBatCode,
		SchemeOnQty,
		SchemeOnAmount,
		SchemeOnKG,
		SchemeOnLitre,
		UploadDate,
		UploadFlag
	)
	SELECT 	@DistCode,CASE ProcessId WHEN 1 THEN 'SALES' WHEN 2 THEN 'RETURN' END,
			TransRefId,TransRefCode,RtrId,RtrCode,Rtrname,Schid,SchCode,SchDesc,PrdId,PrdCCode,PrdBatId,PrdBatCode,
			SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,GETDATE(),'N' FROM SalesInvoiceQpsDatebasedTrack WHERE Upload=0

	UPDATE SalesInvoiceQpsDatebasedTrack SET Upload=1 WHERE Upload=0 AND TransRefCode IN (SELECT DISTINCT
	TransRefCode FROM CS2CN_QPSDataBasedCrNoteTrack WHERE Upload=0 AND TransName='SALES')  AND ProcessId=1

	UPDATE SalesInvoiceQpsDatebasedTrack SET Upload=1 WHERE Upload=0 AND TransRefCode IN (SELECT DISTINCT
	TransRefCode FROM CS2CN_QPSDataBasedCrNoteTrack WHERE Upload=0 AND TransName='RETURN')  AND ProcessId=2

END
GO
DELETE FROM Configuration WHERE ModuleId='SCHCON17' AND ModuleName='Scheme Master'
GO
INSERT INTO Configuration 
SELECT 'SCHCON17','Scheme Master','Set the default value in the claimable field as NO',0,0,0.00,17
GO
DELETE FROM Configuration WHERE ModuleId='SCHCON18' AND ModuleName='Scheme Master'
GO
INSERT INTO Configuration 
SELECT 'SCHCON18','Scheme Master','Restrict user from editing the default value in the claimable field',0,0,0.00,18
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='TranSactionWsSerailNo' AND Xtype='U')
CREATE TABLE TranSactionWsSerailNo
(
	[SerialNo] [int] NOT NULL,
	[Transid] [int] NOT NULL,
	[Salid] [int] NOT NULL,
	[InvoiceNo] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AuthId] [tinyint] NOT NULL,
	[AuthDate] [datetime] NOT NULL,
	[UploadFlag] varchar(1) NOT NULL
) 
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='SerialCounter' AND Xtype='U')
DROP TABLE SerialCounter
GO
CREATE TABLE SerialCounter(
	[TabName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FldName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CurrValue] [int] NULL,
	[Availability] [int] NOT NULL,
	[LastModBy] [int] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [int] NOT NULL,
	[AuthDate] [datetime] NOT NULL
)
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Fn_GenerateSerailNo' AND xtype='FN')
DROP FUNCTION Fn_GenerateSerailNo
GO
CREATE FUNCTION Fn_GenerateSerailNo(@Tabname varchar(100),@FldName varchar(50))
RETURNS int
AS
BEGIN
/*********************************
* FUNCTION: Fn_GenerateSerailNo
* PURPOSE: Returns the Year upto 2099
* NOTES:
* CREATED: Boopathy.P 31/10/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
DECLARE @SerialNo AS int 
IF EXISTS (SELECT * FROM SerialCounter WHERE TabName=@Tabname AND FldName=@FldName)
     BEGIN
		SET @SerialNo =(SELECT CurrValue  FROM SerialCounter WHERE TabName=@Tabname AND FldName=@FldName)
     END 

RETURN(@SerialNo)
END
GO
IF Not EXists (Select * from SerialCounter WHERE tabname='SalesInvoice')
Begin
	INSERT INTO SerialCounter
	SELECT 'SalesInvoice','Salid',0,1,1,getdate(),1,getdate()
End
GO
DELETE FROM tbl_Generic_Reports WHERE  rptid=13
INSERT INTO tbl_Generic_Reports VALUES
(13,'Credit Note Adjustment Report','Proc_GR_CrditNoteAdj','Credit Note Adjustment Report','Not Available')
GO
DELETE FROM TBL_GENERIC_REPORTS_FILTERS WHERE RptId=13
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 13,1,'Salesman','Proc_GR_CrditNoteAdj_Values','Credit Note Adjustment Report'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 13,2,'Route','Proc_GR_CrditNoteAdj_Values','Credit Note Adjustment Report'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 13,3,'Retailer','Proc_GR_CrditNoteAdj_Values','Credit Note Adjustment Report'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 13,4,'CreditNoteRetailer','Proc_GR_CrditNoteAdj_Values','Credit Note Adjustment Report'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 13,5,'Not Applicable','Proc_GR_CrditNoteAdj_Values','Credit Note Adjustment Report'
INSERT INTO TBL_GENERIC_REPORTS_FILTERS SELECT 13,6,'Not Applicable','Proc_GR_CrditNoteAdj_Values','Credit Note Adjustment Report'
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_GR_CrditNoteAdj_Values' AND xtype='P')
DROP PROCEDURE Proc_GR_CrditNoteAdj_Values
GO
CREATE PROCEDURE Proc_GR_CrditNoteAdj_Values
(
	@FILTERCAPTION  NVARCHAR(100),
	@TEXTLIKE  NVARCHAR(100)
)
AS
BEGIN
	SET @TEXTLIKE='%'+ISNULL(@TEXTLIKE,'')+'%'
	PRINT @filtercaption
	IF @FILTERCAPTION='Salesman' 
	BEGIN
		SELECT DISTINCT SMName as Filtervalues FROM Salesman WHERE SMName LIKE @textlike
	END 
	IF @FILTERCAPTION='Route' 
	BEGIN
		SELECT DISTINCT RMName as Filtervalues FROM Routemaster WHERE RMName LIKE @textlike
	END 
	IF @FILTERCAPTION='Retailer' 
	BEGIN
		SELECT DISTINCT RtrName as Filtervalues FROM Retailer WHERE RtrName LIKE @textlike
	END 
	IF @FILTERCAPTION='CreditNoteRetailer' 
	BEGIN
		SELECT DISTINCT CrNoteNumber as Filtervalues FROM CreditNoteRetailer WHERE CrNoteNumber LIKE @textlike	
	END 
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE XType='P' AND [Name]='Proc_GR_CrditNoteAdj')
DROP PROCEDURE Proc_GR_CrditNoteAdj
GO
--EXEC Proc_GR_CrditNoteAdj 'CreditNoteAdjustmentReport','2011-12-01','2011-12-08','','','','','',''
CREATE PROCEDURE Proc_GR_CrditNoteAdj
(    
  @Pi_RptName  NVARCHAR(100),    
  @Pi_FromDate DATETIME,    
  @Pi_ToDate   DATETIME,    
  @Pi_Filter1  NVARCHAR(100),    
  @Pi_Filter2  NVARCHAR(100),    
  @Pi_Filter3  NVARCHAR(100),    
  @Pi_Filter4  NVARCHAR(100),    
  @Pi_Filter5  NVARCHAR(100),    
  @Pi_Filter6  NVARCHAR(100)    
)    
AS     
BEGIN    
  SET @Pi_FILTER1='%'+ISNULL(@Pi_FILTER1,'')+'%'            
  SET @Pi_FILTER2='%'+ISNULL(@Pi_FILTER2,'')+'%'            
  SET @Pi_FILTER3='%'+ISNULL(@Pi_FILTER3,'')+'%'            
  SET @Pi_FILTER4='%'+ISNULL(@Pi_FILTER4,'')+'%'            
  SET @Pi_FILTER5='%'+ISNULL(@Pi_FILTER5,'')+'%'      
  SET @Pi_FILTER6='%'+ISNULL(@Pi_FILTER6,'')+'%'  

CREATE TABLE #RPTCrditnoteretailer
(
	ReportHeader Varchar(100),
	CrNoteNumber varchar(100),
	CrNoteDate datetime,
	Amount numeric(18,6),
	Remarks nvarchar(500),
	SMName nvarchar(100),
	RMName nvarchar(100),
	RtrCode nvarchar(100),
	RtrName nvarchar(100),
	SalInvNo varchar(50),
	SalInvDate datetime,
	AdjAmount numeric(18,6),
	AdjDate datetime
)

INSERT INTO #RPTCrditnoteretailer
 
SELECT  'CreditNoteAdjustmentReport',CrNoteNumber,CrNoteDate,Amount,Remarks,SMName,RMName,RtrCode,RtrName,SalInvNo,SalInvDate,sum(AdjAmount),LastModDate FROM 
(
SELECT CR.CrNoteNumber,CR.CrNoteDate,CR.Amount,CR.Remarks,SMName,RMName,RtrCode,RtrName,SalInvNo,SalInvDate,AdjAmount,CA.LastModDate
FROM CreditNoteRetailer CR 
	INNER JOIN CRDBNoteAdjustment CA ON CR.CrNoteNumber=CA.NoteNo 
	INNER JOIN SalesInvoice SI ON SI.SalId=CA.SalId
	INNER JOIN Salesman S ON S.SMId = SI.SMId
	INNER JOIN RouteMaster RM ON RM.RMId=SI.RMId
	INNER JOIN Retailer R ON R.RtrId=SI.RtrId AND R.RtrId=CA.RtrId 
WHERE CR.CrNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
    AND SI.Dlvsts <> 3  
	AND S.SMName LIKE @Pi_FILTER1
	AND RM.RMName LIKE @Pi_FILTER2
	AND R.RtrName LIKE @Pi_FILTER3
	AND Cr.CrNoteNumber LIKE @Pi_FILTER4
UNION ALL
SELECT CR.CrNoteNumber,CR.CrNoteDate,CR.Amount,CR.Remarks,SMName,RMName,RtrCode,RtrName,SalInvNo,SalInvDate,CA.CrAdjAmount,CA.LastModDate
FROM CreditNoteRetailer CR 
		INNER JOIN SalInvCrNoteAdj CA ON CR.CrNoteNumber=CA.CrNoteNumber 
		INNER JOIN SalesInvoice SI ON SI.SalId=CA.SalId
		INNER JOIN Salesman S ON S.SMId = SI.SMId
		INNER JOIN RouteMaster RM ON RM.RMId=SI.RMId
		INNER JOIN Retailer R ON R.RtrId=SI.RtrId AND R.RtrId=CA.RtrId 
WHERE CR.CrNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate   
        AND SI.Dlvsts <> 3
		AND S.SMName LIKE @Pi_FILTER1
		AND RM.RMName LIKE @Pi_FILTER2
		AND R.RtrName LIKE @Pi_FILTER3
		AND Cr.CrNoteNumber LIKE @Pi_FILTER4
)A GROUP BY  CrNoteNumber,CrNoteDate,Amount,Remarks,SMName,RMName,RtrCode,RtrName,SalInvNo,SalInvDate,LastModDate
SELECT * FROM #RPTCrditnoteretailer
END
GO
IF NOT EXISTS (SELECT [Name] FROM SysObjects WHERE XType='U' AND [Name]='Cs2Cn_Prk_OrderBooking')
CREATE TABLE Cs2Cn_Prk_OrderBooking
	(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrderNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrderDate] [datetime] NULL,
	[OrdDlvDate] [datetime] NULL,
	[AllowBackOrder] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrdType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrdPriority] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrdDocRef] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Remarks] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RoundOffAmt] [numeric](38, 6) NULL,
	[OrdTotalAmt] [numeric](38, 6) NULL,
	[SalesmanCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalesmanName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalesRouteCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalesRouteName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdBatCde] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdQty] [int] NULL,
	[PrdBilledQty] [int] NULL,
	[PrdSelRate] [numeric](38, 6) NULL,
	[PrdGrossAmt] [numeric](38, 6) NULL,
	[RecordDate] [datetime] NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) 
GO


IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_Cs2Cn_OrderBooking')
DROP PROCEDURE Proc_Cs2Cn_OrderBooking
GO
/*
BEGIN TRANSACTION
DELETE FROM Cs2Cn_Prk_OrderBooking
UPDATE OrderBooking SET Upload=0
EXEC Proc_Cs2Cn_OrderBooking 0
SELECT * FROM Cs2Cn_Prk_OrderBooking
SELECT * FROM OrderBooking 
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_OrderBooking]
(
	@Po_ErrNo INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
		DECLARE @CmpId 			AS INT
		DECLARE @DistCode	As nVarchar(50)
		DECLARE @DefCmpAlone	AS INT
		SET @Po_ErrNo=0
		DELETE FROM Cs2Cn_Prk_OrderBooking WHERE UploadFlag = 'Y'
		SELECT @DefCmpAlone=Status FROM Configuration WHERE ModuleId='BotreeUpload01' AND ModuleName='Botree Upload'
		SELECT @DistCode = DistributorCode FROM Distributor	
		SELECT @CmpId = CmpId FROM Company WHERE DefaultCompany = 1	
		INSERT INTO Cs2Cn_Prk_OrderBooking
		(
			DistCode		,
			OrderNo			,
			OrderDate		,
			OrdDlvDate		,
			AllowBackOrder	,
			OrdType			,
			OrdPriority		,
			OrdDocRef		,
			Remarks			,
			RoundOffAmt		,
			OrdTotalAmt		,
			SalesmanCode	,
			SalesmanName	,
			SalesRouteCode	,
			SalesRouteName	,
			RtrId			,
			RtrCode			,
			RtrName			,
			PrdCode			,
			PrdBatCde		,
			PrdQty			,
			PrdBilledQty	,
			PrdSelRate		,
			PrdGrossAmt		,
			RecordDate		,
			UploadFlag		
		)
		SELECT @DistCode,OB.OrderNo,OB.OrderDate,OB.DeliveryDate,(CASE OB.AllowBackOrder WHEN 1 THEN 'Yes' ELSE 'No' END) AS AllowBackOrder,
		(CASE OB.OrdType WHEN 0 THEN 'Phone' WHEN 1 THEN 'In Person' ELSE 'Internet' END) AS OrdType,
		(CASE OB.Priority WHEN 0 THEN 'Normal' WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' ELSE 'High' END) AS Priority,
		OB.DocRefNo,OB.Remarks,OB.RndOffValue,OB.TotalAmount,SM.SMCode,SM.SMName,RM.RMCode,RM.RMName,R.RtrId,R.RtrCode,R.RtrName,
		P.PrdCCode,PB.PrdBatCode,OBP.TotalQty,OBP.BilledQty,OBP.Rate,OBP.GrossAmount,GETDATE(),'N'
		FROM OrderBooking OB
		INNER JOIN OrderBookingProducts OBP ON OB.OrderNo=OBP.OrderNo AND OB.Upload=0 
		INNER JOIN Product P ON OBP.PrdId=P.PrdId
		INNER JOIN ProductBatch PB ON OBP.PrdBatId=PB.PrdBatId AND P.PrdId=PB.PrdId
		INNER JOIN SalesMan SM ON OB.SMId=SM.SMId
		INNER JOIN RouteMaster RM ON OB.RMId=RM.RMId
		INNER JOIN Retailer R ON OB.RtrId=R.RtrId
		UPDATE OrderBooking SET Upload=1 WHERE Upload=0 AND OrderNo IN (SELECT DISTINCT
		OrderNo FROM Cs2Cn_Prk_OrderBooking WHERE UploadFlag = 'N')
END
GO
IF NOT EXISTS (SELECT [Name] FROM SysObjects WHERE XType='U' AND [Name]='Cs2Cn_Prk_DailySalesUpload')
CREATE TABLE Cs2Cn_Prk_DailySalesUpload
(
	SlNo numeric(38, 0) IDENTITY(1,1),
	DistCode nvarchar(50),
	SalInvNo nvarchar(50),
	SalInvDate datetime ,
	SalInvAmt numeric(38, 6) ,
	SalTaxAmt numeric(38, 6) ,
	SalSchAmt numeric(38, 6) ,
	SalDisAmt numeric(38, 6) ,
	SalSplDis numeric(38, 6) ,
	SalRetAmt numeric(38, 6) ,
	SalVisAmt numeric(38, 6) ,
	SalNetAmt numeric(38, 6) ,
	SalDistDis numeric(38, 6) ,
	SalTotDedn numeric(38, 6) ,
	SalRoundOffAmt numeric(38, 6) ,
	Salesman nvarchar(100) ,
	Route nvarchar(100) ,
	RtrId int ,
	RtrName nvarchar(100), 
	BillMode nvarchar(100) ,
	BillType nvarchar(100),
	DlvBoyName nvarchar(100) ,
	VechName nvarchar(100) ,
	SalDlvDate datetime ,
	DbAdjAmt numeric(38, 6) ,
	CrAdjAmt numeric(38, 6) ,
	OnAccountAmt numeric(38, 6) ,
	SalReplaceAmt numeric(38, 6) ,
	DeliveryRoute nvarchar(100) ,
	PrdCode nvarchar(50) ,
	PrdBatCde nvarchar(50), 
	SalInvQty int ,
	SelRateBeforTax numeric(38, 6) ,
	SelRateAfterTax numeric(38, 6) ,
	SalInvFree int ,
	SalInvTax numeric(38, 6) ,
	SalInvSch numeric(38, 6) ,
	SalInvDist numeric(38, 6) ,
	SalCshDis numeric(38, 6) ,
	PrdNetAmt numeric(38, 6) ,
	SalInvCashDisc numeric(38, 6) ,
	BillStatus nvarchar(50) ,
	UploadedDate datetime ,
	UploadFlag nvarchar(10) 
) 
GO
IF EXISTS (SELECT [Name] FROM SysObjects WHERE XType='P' AND [Name]='Proc_Cs2Cn_DailySalesUpload')
DROP PROCEDURE Proc_Cs2Cn_DailySalesUpload
GO
CREATE PROCEDURE Proc_Cs2Cn_DailySalesUpload
(
	@Po_ErrNo INT OUTPUT
)
AS
BEGIN
	DECLARE @CmpId 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DELETE FROM Cs2Cn_Prk_DailySales WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where procId = 1
	SET @Po_ErrNo=0 
	INSERT INTO Cs2Cn_Prk_DailySalesUpload 
	(
		DistCode	,
		SalInvNo	,
		SalInvDate	,
		SalInvAmt	,
		SalTaxAmt	,
		SalSchAmt	,
		SalDisAmt	,
		SalSplDis	,
		SalRetAmt	,
		SalVisAmt	,
		SalNetAmt	,
		SalDistDis	,
		SalTotDedn	,
		SalRoundOffAmt	,
		Salesman	,
		[Route]		,
		RtrId		,
		RtrName		,
		BillMode	,
		BillType	,
		DlvBoyName	,
		VechName	,
		SalDlvDate	,
		DbAdjAmt	,	
		CrAdjAmt	,
		OnAccountAmt	,	
		SalReplaceAmt	,
		DeliveryRoute	,
		PrdCode		,
		PrdBatCde	,
		SalInvQty	,
		SelRateBeforTax	,
		SelRateAfterTax	,
		SalInvFree	,
		SalInvTax	,
		SalInvSch	,
		SalInvDist	,
		SalCshDis	,
		PrdNetAmt	,
		SalInvCashDisc	,
		BillStatus	,
		UploadedDate ,
		UploadFlag		 
	)
	SELECT 	@DistCode,A.SalInvNo ,A.SalInvDate ,A.SalGrossAmount ,A.SalTaxAmount,
	A.SalSchDiscAmount,A.SalCDAmount,A.SalSplDiscAmount,A.MarketRetAmount ,
	A.WindowDisplayAmount,A.SalNetAmt,A.SalDBDiscAmount ,A.TotalDeduction ,
	A.SalRoundOffAmt ,B.SMName ,C.RMName ,A.RtrId ,R.RtrName ,
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,
	(CASE A.BillType  WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END ) AS BillType, 
	ISNULL(D.DlvBoyName,''),ISNULL(E.VehicleRegNo,'') AS VehicleName ,
	A.SalDlvDate ,A.DBAdjAmount ,A.CRAdjAmount ,A.OnAccountAmount ,A.ReplacementDiffAmount ,
	F.RMName ,H.PrdCCode ,I.CmpBatCode ,SUM(G.BaseQty) AS SalInvQty ,G.PrdUnitSelRate ,
	G.PrdUnitSelRate ,SUM(G.SalManFreeQty) AS SalInvFree ,	SUM(G.PrdTaxAmount) AS SalInvTax ,
	SUM(G.PrdSchDiscAmount) AS SalInvSch ,	SUM(G.PrdDBDiscAmount) AS SalInvDist ,
	SUM(G.PrdCDAmount) AS SalCshDis ,	SUM(G.PrdNetAmount) AS PrdNetAmount ,
	(A.SalDBDiscAmount) AS SalInvCshDisc ,	'Pending' AS BillStatus,GETDATE() AS UploadedDate,
	'N' AS UploadFlag
	FROM SalesInvoice A  (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId = R.RtrId 
	INNER JOIN SalesMan B (NOLOCK) ON A.SMID = B.SmID 
	INNER JOIN RouteMaster C (NOLOCK) ON A.RMID = C.RMID 
	LEFT OUTER JOIN DeliveryBoy D  (NOLOCK) ON A.DlvBoyId = D.DlvBoyId 
	LEFT OUTER JOIN Vehicle E (NOLOCK) ON E.VehicleId = A. VehicleId 
	INNER JOIN RouteMaster F (NOLOCK) ON A.DlvRMID = F.RMID 
	INNER JOIN SalesInvoiceProduct G (NOLOCK) ON A.SalId = G.SalId 
	INNER JOIN Product H (NOLOCK) ON G.PrdId = H.PrdId 
	INNER JOIN ProductBatch I (NOLOCK) ON G.PrdBatID = I.PrdBatId 			
	WHERE A.Dlvsts <3	
	GROUP BY A.SalInvNo,A.SalInvDate,A.SalGrossAmount,A.SalTaxAmount,A.SalSchDiscAmount,A.SalCDAmount,
	A.MarketRetAmount,A.WindowDisplayAmount ,A.SalNetAmt,A.SalDBDiscAmount,
	A.TotalDeduction,A.SalRoundOffAmt,B.SMName,C.RMName,A.RtrId ,A.BillMode,BillType,D.DlvBoyName,
	E.VehicleRegNo,A.SalDlvDate,A.DBAdjAmount,A.CRAdjAmount,OnAccountAmount,
	ReplacementDiffAmount,F.RMName,H.PrdCCode,I.CmpBatCode,G.PrdUnitSelRate,A.SalSplDiscAmount,R.RtrName
	UNION ALL
	SELECT 	@DistCode,A.SalInvNo ,A.SalInvDate ,A.SalGrossAmount ,A.SalTaxAmount,
	A.SalSchDiscAmount,A.SalCDAmount,A.SalSplDiscAmount,A.MarketRetAmount ,
	A.WindowDisplayAmount,A.SalNetAmt,A.SalDBDiscAmount ,A.TotalDeduction ,
	A.SalRoundOffAmt ,B.SMName ,C.RMName ,A.RtrId ,R.RtrName ,
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,
	(CASE A.BillType  WHEN 1 THEN 'Order Booking' WHEN 2 THEN 'Ready Stock' ELSE 'Van Sales' END ) AS BillType,
	ISNULL(D.DlvBoyName,'') ,ISNULL(E.VehicleRegNo,'') AS VehicleName ,
	A.SalDlvDate ,A.DBAdjAmount ,A.CRAdjAmount ,A.OnAccountAmount ,A.ReplacementDiffAmount ,
	F.RMName ,H.PrdCCode ,I.CmpBatCode ,SUM(G.BaseQty) AS SalInvQty ,G.PrdUnitSelRate ,
	G.PrdUnitSelRate ,SUM(G.SalManFreeQty) AS SalInvFree ,	SUM(G.PrdTaxAmount) AS SalInvTax ,
	SUM(G.PrdSchDiscAmount) AS SalInvSch ,	SUM(G.PrdDBDiscAmount) AS SalInvDist ,
	SUM(G.PrdCDAmount) AS SalCshDis ,	SUM(G.PrdNetAmount) AS PrdNetAmount ,
	(A.SalDBDiscAmount) AS SalInvCshDisc ,	'Cancelled' AS BillStatus,GETDATE() AS UploadedDate,
	'N' AS UploadFlag
	FROM SalesInvoice A  (NOLOCK)
	INNER JOIN Retailer R (NOLOCK) ON A.RtrId = R.RtrId 
	INNER JOIN SalesMan B (NOLOCK) ON A.SMID = B.SmID 
	INNER JOIN RouteMaster C (NOLOCK) ON A.RMID = C.RMID 
	LEFT OUTER JOIN DeliveryBoy D  (NOLOCK) ON A.DlvBoyId = D.DlvBoyId 
	LEFT OUTER JOIN Vehicle E (NOLOCK) ON E.VehicleId = A. VehicleId 
	INNER JOIN RouteMaster F (NOLOCK) ON A.DlvRMID = F.RMID 
	INNER JOIN SalesInvoiceProduct G (NOLOCK) ON A.SalId = G.SalId 
	INNER JOIN Product H (NOLOCK) ON G.PrdId = H.PrdId 
	INNER JOIN ProductBatch I (NOLOCK) ON G.PrdBatID = I.PrdBatId 			
	WHERE A.Dlvsts =3 AND A.Upload=0	
	GROUP BY A.SalInvNo,A.SalInvDate,A.SalGrossAmount,A.SalTaxAmount,A.SalSchDiscAmount,A.SalCDAmount,
	A.MarketRetAmount,A.WindowDisplayAmount ,A.SalNetAmt,A.SalDBDiscAmount,
	A.TotalDeduction,A.SalRoundOffAmt,B.SMName,C.RMName,A.RtrId ,A.BillMode,BillType,D.DlvBoyName,
	E.VehicleRegNo,A.SalDlvDate,A.DBAdjAmount,A.CRAdjAmount,OnAccountAmount,
	ReplacementDiffAmount,F.RMName,H.PrdCCode,I.CmpBatCode,G.PrdUnitSelRate,A.SalSplDiscAmount,R.RtrName
	UPDATE SalesInvoice SET Upload=1 WHERE Upload=0 AND SalInvNo IN (SELECT DISTINCT
	SalInvNo FROM Cs2Cn_Prk_DailySalesUpload WHERE BillStatus='Cancelled') AND Dlvsts=3
END
GO
DELETE FROM Configuration WHERE ModuleName='Purchase Order' AND ModuleId='PO37'
GO
INSERT INTO Configuration 
SELECT 'PO37','Purchase Order','Allow user to reduce quantity upto % from suggested order quantity',0,0,0.00,37
GO
DELETE FROM Configuration WHERE ModuleName='Purchase Order' AND ModuleId='PO38'
GO
INSERT INTO Configuration 
SELECT 'PO38','Purchase Order','Display Purchase Order Status',0,0,0.00,38
GO
Delete from HotSearchEditorHd where formid = 557
GO
Insert into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values(557,'Billing','Direct Retailer Based on Name','Select',	
'SELECT RtrId,RtrName,RtrCode,RtrSeqDtId,RtrCovMode,RtrCashDiscPerc,RtrCashdiscCond,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,
RtrCrLimit,RtrCrDays,RtrLicExpiryDate,RtrAdd1,RtrAdd2,RtrAdd3,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,
RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT D.RtrId,D.RtrName,D.RtrCode,100000 as RtrSeqDtId,D.RtrCovMode,D.RtrCashDiscPerc,D.RtrCashdiscCond,D.RtrCashDiscAmt,D.RtrTaxType,D.RMId 
AS DelvRMId,D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) 
AS RtrLicExpiryDate,D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,   
ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert   FROM Retailer D (NOLOCK) Where D.RtrStatus = 1 ) a ORDER BY RtrSeqDtId')
GO
Delete From HotSearchEditorDt Where Formid = 557
GO
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (1,557,'Direct Retailer Based on Name','Retailer Name','RtrName',3250,0,'HotSch-2-2000-38',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (2,557,'Direct Retailer Based on Name','Retailer Code','RtrCode',1250,0,'HotSch-2-2000-37',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (3,557,'Direct Retailer Based on Name','Retailer Address1','RtrAdd1',3250,0,'HotSch-2-2000-184',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (4,557,'Direct Retailer Based on Name','Retailer Address2','RtrAdd2',3250,0,'HotSch-2-2000-185',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (5,557,'Direct Retailer Based on Name','Retailer Address3','RtrAdd3',3250,0,'HotSch-2-2000-186',2)
GO
--Order Booking Address 
Delete from HotsearchEditorHD where Formid = 668
GO
Insert into HotsearchEditorHD (FormId,FormName,ControlName,SltString,RemainsltString)
Values (668,'Order Booking','Retailer','select',
'SELECT RtrSeqDtId,RtrId,RtrName,RtrCode,RtrAdd1,RtrAdd2,RtrAdd3,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT B.RtrSeqDtId,C.RtrId,C.RtrCode,
C.RtrName,C.RtrAdd1,C.RtrAdd2,C.RtrAdd3,C.RtrCrDaysAlert,C.RtrCrBillsAlert,C.RtrCrLimitAlert FROM RetailerSequence A (NOLOCK) INNER JOIN RetailerSeqDetails B(NOLOCK) 
ON A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on C.RtrId = B.RtrId Where C.RtrStatus = 1 And A.SMId = vFParam And A.RMId = vSParam And TransactionType=vTParam    
Union   SELECT 100000 as RtrSeqDtId,D.RtrId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCrDaysAlert,D.RtrCrBillsAlert,  D.RtrCrLimitAlert FROM Retailer D (NOLOCK) 
INNER JOIN RetailerMarket E (NOLOCK) ON   D.RtrId = E.RtrId Where D.RtrStatus = 1 And E.RMId = vSParam And D.Rtrid Not In (SELECT C.RtrId   FROM RetailerSequence A (NOLOCK) 
INNER JOIN RetailerSeqDetails B (NOLOCK) ON   A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on C.RtrId = B.RtrId   Where C.RtrStatus = 1 And A.SMId = vFParam 
And A.RMId = vSParam And TransactionType= vTParam)) a  ORDER BY RtrSeqDtId')
GO
Delete from HotsearchEditorDt where Formid = 668
GO
Insert into HotsearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values(1,668,'Retailer','Sequence Id','RtrSeqDtId',1000,0,'HotSch-1-2000-31',1)
Insert into HotsearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values(2,668,'Retailer','Retailer Name','RtrName',1750,0,'HotSch-1-2000-32',1)
Insert into HotsearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values(3,668,'Retailer','Retailer Code','RtrCode',1750,0,'HotSch-1-2000-33',1)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values(4,668,'Retailer','Retailer Address1','RtrAdd1',1750,0,'HotSch-1-2000-187',1)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values(5,668,'Retailer','Retailer Address2','RtrAdd2',1750,0,'HotSch-1-2000-188',1)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values(6,668,'Retailer','Retailer Address3','RtrAdd3',1750,0,'HotSch-1-2000-189',1)
GO
Delete from Customcaptions Where CtrlName in ('HotSch-1-2000-187','HotSch-1-2000-188','HotSch-1-2000-189') And Transid = 1
Go
Insert into Customcaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values (1,2000,187,'HotSch-1-2000-187','RetailerAddress1','','',1,1,1,GetDate(),1,GetDate(),'RetailerAddress1','','',1,1)
Insert into Customcaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values (1,2000,188,'HotSch-1-2000-188','RetailerAddress2','','',1,1,1,GetDate(),1,GetDate(),'RetailerAddress2','','',1,1)
Insert into Customcaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values (1,2000,189,'HotSch-1-2000-189','RetailerAddress3','','',1,1,1,GetDate(),1,GetDate(),'RetailerAddress3','','',1,1)
GO
----Order Booking Direct Retailer Selection
Delete from HotsearchEditorHD Where Formid = 10050
GO
Insert into HotsearchEditorHD Select 10050,'Order Booking','DirectRetailer','select','SELECT RtrSeqDtId,RtrId,RtrName,RtrCode,RtrAdd1,RtrAdd2,RtrAdd3,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT B.RtrSeqDtId,C.RtrId,C.RtrCode,  C.RtrName,C.RtrAdd1,C.RtrAdd2,C.RtrAdd3,C.RtrCrDaysAlert,C.RtrCrBillsAlert,C.RtrCrLimitAlert FROM RetailerSequence A (NOLOCK) INNER JOIN RetailerSeqDetails B(NOLOCK)   ON A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on C.RtrId = B.RtrId Where C.RtrStatus = 1 Union   SELECT 100000 as RtrSeqDtId,D.RtrId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCrDaysAlert,D.RtrCrBillsAlert,  D.RtrCrLimitAlert FROM Retailer D (NOLOCK)   INNER JOIN RetailerMarket E (NOLOCK) ON   D.RtrId = E.RtrId Where D.RtrStatus = 1 And D.Rtrid Not In (SELECT C.RtrId   FROM RetailerSequence A (NOLOCK)   INNER JOIN RetailerSeqDetails B (NOLOCK) ON   A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on C.RtrId = B.RtrId   Where C.RtrStatus = 1)) a  ORDER BY RtrSeqDtId'
GO
Delete from HotsearchEditorDt where Formid = 10050
GO
Insert into HotsearchEditorDt Select 1,10050,'DirectRetailer','Sequence Id','RtrSeqDtId',1000,0,'HotSch-1-2000-31',1
Insert into HotsearchEditorDt Select 2,10050,'DirectRetailer','Retailer Name','RtrName',1750,0,'HotSch-1-2000-32',1
Insert into HotsearchEditorDt Select 3,10050,'DirectRetailer','Retailer Code','RtrCode',1750,0,'HotSch-1-2000-33',1
Insert into HotsearchEditorDt Select 4,10050,'DirectRetailer','Retailer Address1','RtrAdd1',1750,0,'HotSch-1-2000-187',1
Insert into HotsearchEditorDt Select 5,10050,'DirectRetailer','Retailer Address2','RtrAdd2',1750,0,'HotSch-1-2000-188',1
Insert into HotsearchEditorDt Select 6,10050,'DirectRetailer','Retailer Address3','RtrAdd3',1750,0,'HotSch-1-2000-189',1
GO
-----*****************BNL Retailer Upload Process DrugLcnNo*************************---------
IF EXISTS (Select * From Sysobjects Where Xtype = 'U' And Name = 'Cs2Cn_Prk_Retailer')
DROP TABLE Cs2Cn_Prk_Retailer
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_Retailer](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CmpRtrCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrAddress1] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrAddress2] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrAddress3] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrPINCode] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrChannelCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrGroupCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrClassCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KeyAccount] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RelationStatus] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrRegDate] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevel] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevelValue] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  --Retailer
	[VillageId] [int] NULL,
	[VillageCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VillageName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [tinyint] NULL,
	[Mode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DrugLNo] [Nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'U' And Name = 'Cs2Cn_Prk_Retailer_Archive')
DROP TABLE Cs2Cn_Prk_Retailer_Archive
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_Retailer_Archive]
(
	[SlNo] [numeric](38, 0) NOT NULL,
	[DistCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CmpRtrCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrAddress1] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrAddress2] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrAddress3] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrPINCode] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrChannelCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrGroupCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrClassCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KeyAccount] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RelationStatus] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrRegDate] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevel] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevelValue] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VillageId] [int] NULL,
	[VillageCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VillageName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [tinyint] NULL,
	[Mode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DrugLNo] [Nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadedDate] [datetime] NULL
) ON [PRIMARY]
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'Proc_Cs2Cn_Retailer')
DROP PROCEDURE Proc_Cs2Cn_Retailer
GO
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_Retailer]
(
	@Po_ErrNo	INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE	: Proc_CS2CN_BLRetailer
* PURPOSE	: Extract Retailer Details from CoreStocky to Console
* NOTES		:
* CREATED	: Nandakumar R.G 09-01-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_Retailer WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_Retailer
	(
		DistCode ,
		RtrId ,
		RtrCode ,
		CmpRtrCode ,
		RtrName ,
		RtrAddress1,
		RtrAddress2,
		RtrAddress3,
		RtrPINCode,
		RtrChannelCode ,
		RtrGroupCode ,
		RtrClassCode ,
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
		UploadFlag
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
		'' CtgCode ,
		'' ValueClassCode ,
		RtrStatus,	
		CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,
		CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,
		(CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','New',R.RtrDrugLicNo,'N'				
	FROM		
		Retailer R
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
	WHERE			
		R.Upload = 'N'
	UNION
	SELECT
		@DistCode ,
		RCC.RtrId,
		RCC.RtrCode,
		R.CmpRtrCode,
		RCC.RtrName ,
		R.RtrAdd1 ,
		R.RtrAdd2 ,
		R.RtrAdd3 ,
		R.RtrPinNo ,
		'' CtgCode,
		'' CtgCode,
		'' ValueClassCode,
		RtrStatus,
		CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,
		CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,
		(CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,
		CONVERT(VARCHAR(10),R.RtrRegDate,121),'' AS GeoLevelName,'' AS GeoName,0,'','','CR',R.RtrDrugLicNo,'N'			
	FROM
		RetailerClassficationChange RCC			
		INNER JOIN Retailer R ON R.RtrId=RCC.RtrId
		LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE
		INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId
	WHERE 	
		UpLoadFlag=0
	UPDATE ETL SET ETL.RtrChannelCode=RVC.ChannelCode,ETL.RtrGroupCode=RVC.GroupCode,ETL.RtrClassCode=RVC.ValueClassCode
	FROM Cs2Cn_Prk_Retailer ETL,
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
	FROM Cs2Cn_Prk_Retailer ETL,
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
	FROM Cs2Cn_Prk_Retailer ETL,
	(
		SELECT R.RtrId,R.VillageId,V.VillageCode,V.VillageName
		FROM			
		Retailer R  		
		INNER JOIN RouteVillage V ON R.VillageId=V.VillageId
	) V
	WHERE ETL.RtrId=V.RtrId	
	UPDATE Retailer SET Upload='Y' WHERE Upload='N'
	AND CmpRtrCode IN(SELECT CmpRtrCode FROM Cs2Cn_Prk_Retailer WHERE Mode='New')
	UPDATE RetailerClassficationChange SET UpLoadFlag=1 WHERE UpLoadFlag=0
	AND RtrCode IN(SELECT RtrCode FROM Cs2Cn_Prk_Retailer WHERE Mode='CR')
END
GO
--SalesReturn Direct Retailer Selection
Delete From HotsearchEditorHD  Where Formid = 10049
Insert into HotsearchEditorHD Select 10049,'Sales Return','Retailer Selection','select','Select Rtrid,RtrCode,RtrName From Retailer R'
GO
Delete From HotsearchEditorDt Where Formid = 10049 and HotSearchName in ('HotSch-3-2000-7','HotSch-3-2000-8')
Insert into HotsearchEditorDt Select 1,10049,'Retailer Selection','Code','RtrCode',2000,0,'HotSch-3-2000-7',3
Insert into HotsearchEditorDt Select 2,10049,'Retailer Selection','Name','RtrName',2500,0,'HotSch-3-2000-8',3
GO
---**********************BNL CR Norm Download***************************---------------------
IF EXISTS (Select * from Sysobjects Where Xtype = 'U' And Name = 'ETL_Prk_StockNorm')
DROP TABLE ETL_Prk_StockNorm
GO
CREATE TABLE [dbo].[ETL_Prk_StockNorm](
    [Distributor Code] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Hierarchy Level Code] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Hierarchy Level Value Code] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Company Code] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Absolute Stock Norm] [numeric](38, 0) NULL,
    [Minimum Order quantity] [numeric](38, 0) NULL,
	[Effective From Date] [datetime] NULL,
	[DownLoadFlag] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'MOQ' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='StockNorm'))
BEGIN
	ALTER TABLE StockNorm ADD [MOQ] [numeric](38, 0) NULL DEFAULT 0 WITH VALUES
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_ValidateStockNorm')
DROP PROCEDURE Proc_ValidateStockNorm
GO
CREATE PROCEDURE [dbo].[Proc_ValidateStockNorm]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValidateStockNorm
* PURPOSE	: To Insert and Update records in the Table Stock Norm
* CREATED	: Nandakumar R.G
* CREATED DATE	: 21/11/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Tabname 	AS     	NVARCHAR(100)
	DECLARE @DestTabname 	AS 	NVARCHAR(100)
	DECLARE @Fldname 	AS     	NVARCHAR(100)
	DECLARE @DistCode As        NVARCHAR(100)
	DECLARE @PrdHierLevelCode 	AS  NVARCHAR(100)
	DECLARE @PrdHierLevelValueCode 	AS  NVARCHAR(100)
	DECLARE @MaxLevelCode 	AS  NVARCHAR(100)
	
	DECLARE @PrdCCode	AS 	NVARCHAR(100)
	DECLARE @AbsStkNorm	AS 	NUMERIC(38,0)
    DECLARE @MinimumQty AS NUMERIC(38,0)
	DECLARE @EffDate	AS 	NVARCHAR(12)	
	DECLARE @CmpPrdCtgId 	AS 	INT
	DECLARE @PrdCtgMainId 	AS 	INT
	DECLARE @PrdId 		AS 	INT
	DECLARE @StockNormId	AS 	INT
	DECLARE @TransStr 	AS 	NVARCHAR(4000)
	DECLARE @Exist	AS 	INT
 
	SET @Po_ErrNo=0
	SELECT @DistCode = DistributorCode FROM Distributor
	SET @DestTabname='StockNorm'
	SET @Fldname='StockNormId'
	SET @Tabname = 'ETL_Prk_StockNorm'
		
	DECLARE Cur_StockNorm CURSOR
	FOR SELECT ISNULL([Distributor Code],''),ISNULL([Product Hierarchy Level Code],''),ISNULL([Product Hierarchy Level Value Code],''),
	ISNULL([Product Company Code],''),ISNULL([Absolute Stock Norm],0),ISNULL([Minimum Order quantity],0),
	CONVERT(NVARCHAR(10),[Effective From Date],121)
	FROM ETL_Prk_StockNorm
	WHERE DownloadFlag='D'
	OPEN Cur_StockNorm	
	FETCH NEXT FROM Cur_StockNorm INTO @DistCode,@PrdHierLevelCode,@PrdHierLevelValueCode,
	@PrdCCode,@AbsStkNorm,@MinimumQty,@EffDate
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF NOT EXISTS(SELECT * FROM ProductCategoryLevel WITH (NOLOCK) WHERE CmpPrdCtgName=@PrdHierLevelCode)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@Tabname,'Product Hierarchy Level Code',
			'Product Hierachy Level :'+@PrdHierLevelCode+' is not available')
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN			
			SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WITH (NOLOCK)
			WHERE CmpPrdCtgName=@PrdHierLevelCode
		END
		SELECT @MaxLevelCode=CmpPrdCtgName FROM ProductCategoryLevel 		
		WHERE CmpPrdCtgId IN (SELECT MAX(CmpPrdCtgId) FROM ProductCategoryLevel)
		IF @Po_ErrNo=0
		BEGIN			
			IF @MaxLevelCode=@PrdHierLevelCode
			BEGIN
				IF NOT EXISTS(SELECT * FROM Product WITH (NOLOCK)
				WHERE PrdCCode=@PrdCCode)
				BEGIN
					INSERT INTO Errorlog VALUES (1,@Tabname,'Product',
					'Product:'+@PrdCCode+' is not available')
					SET @Po_ErrNo=1
				END
				ELSE
				BEGIN
					SELECT @PrdId=ISNULL(PrdId,0) FROM Product WITH (NOLOCK)
					WHERE PrdCCode=@PrdCCode
					SET @PrdCtgMainId=0
				END
			END
			ELSE
			BEGIN
				IF @Po_ErrNo=0
				BEGIN
					IF NOT EXISTS(SELECT * FROM ProductCategoryValue WITH (NOLOCK)
					WHERE PrdCtgValCode=@PrdHierLevelValueCode)
					BEGIN
						INSERT INTO Errorlog VALUES (1,@Tabname,'Product Category Level Value',
						'Product Category Level Value:'+@PrdHierLevelValueCode+' is not available')
						SET @Po_ErrNo=1
					END
					ELSE
					BEGIN
						SELECT @PrdCtgMainId=ISNULL(PrdCtgValMainId,0) FROM ProductCategoryValue WITH (NOLOCK)
						WHERE PrdCtgValCode=@PrdHierLevelValueCode
						SET @PrdId=0
					END
				END
			END
		END	
		IF @Po_ErrNo=0
		BEGIN
			IF @AbsStkNorm<=0
			BEGIN
				INSERT INTO Errorlog VALUES (1,@Tabname,'Absolute Stock Norm',
				'Qty should be greater than zero')
				SET @Po_ErrNo=1
			END
		END	
        IF @Po_ErrNo=0
		BEGIN
			IF @MinimumQty<=0
			BEGIN
				INSERT INTO Errorlog VALUES (1,@Tabname,'Minimum Order Qty',
				'Qty should be greater than zero')
				SET @Po_ErrNo=1
			END
		END	
		IF @Po_ErrNo=0
		BEGIN
			IF ISDATE(@EffDate)<=0
			BEGIN
				INSERT INTO Errorlog VALUES (1,@Tabname,'Effective From Date',
				'Effective From Date should be a valid date')
				SET @Po_ErrNo=1
			END
		END	

		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM StockNorm WHERE CmpPrdCtgId=@CmpPrdCtgId AND
			PrdCtgValMainId=@PrdCtgMainId AND PrdId=@PrdId AND EffectiveFromDate=@EffDate)
			BEGIN
				SET @Exist=0
				SELECT @StockNormId=dbo.Fn_GetPrimaryKeyInteger(@DestTabname,@FldName,
				CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			END
			ELSE
			BEGIN
				SET @Exist=1
				SELECT @StockNormId=StockNormId FROM StockNorm WHERE CmpPrdCtgId=@CmpPrdCtgId AND
				PrdCtgValMainId=@PrdCtgMainId AND PrdId=@PrdId AND EffectiveFromDate=@EffDate
			END
		END

		IF @Po_ErrNo=0
		BEGIN	
			IF @Exist=0
			BEGIN		
				INSERT INTO StockNorm(StockNormId,CmpPrdCtgId,PrdCtgValMainId,PrdId,AbsStkNorm,MOQ,EffectiveFromDate,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES	(@StockNormId,@CmpPrdCtgId,@PrdCtgMainId,@PrdId,@AbsStkNorm,@MinimumQty,@EffDate,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 			
					
				SET @TransStr='INSERT INTO StockNorm(StockNormId,CmpPrdCtgId,PrdCtgValMainId,PrdId,AbsStkNorm,MOQ,EffectiveFromDate)
				VALUES ('+CAST(@StockNormId AS NVARCHAR(10))+','+CAST(@CmpPrdCtgId AS NVARCHAR(10))+','+
				CAST(@PrdCtgMainId AS NVARCHAR(10))+','+CAST(@PrdId AS NVARCHAR(10))+','+
				CAST(@AbsStkNorm AS NVARCHAR(10))+','+CAST(@MinimumQty AS NVARCHAR(10))+','+CAST(@EffDate AS NVARCHAR(10))+','+
				'1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
		
				UPDATE Counters SET CurrValue=@StockNormId WHERE TabName=@DestTabname AND FldName=@FldName
				SET @TransStr='UPDATE Counters SET CurrValue='+
				CAST(@StockNormId AS NVARCHAR(10))+' WHERE TabName='''+@DestTabname+''' AND FldName='''+@FldName+''''
		
				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
			END
			ELSE
			BEGIN
				UPDATE StockNorm SET AbsStkNorm = @AbsStkNorm WHERE StockNormId=@StockNormId
                UPDATE StockNorm SET MOQ = @MinimumQty WHERE StockNormId=@StockNormId

				SET @TransStr='UPDATE StockNorm SET AbsStkNorm ='+CAST(@AbsStkNorm AS NVARCHAR(10))+
				'WHERE StockNormId='+CAST(@StockNormId AS NVARCHAR(10))+''
                
                 SET @TransStr='UPDATE StockNorm SET MOQ ='+CAST(@MinimumQty AS NVARCHAR(10))+
				'WHERE StockNormId='+CAST(@StockNormId AS NVARCHAR(10))+''

				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)			
			END
		END
		
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_StockNorm
			DEALLOCATE Cur_StockNorm
			RETURN
		END		
			
		FETCH NEXT FROM Cur_StockNorm INTO @DistCode,@PrdHierLevelCode,@PrdHierLevelValueCode,
		@PrdCCode,@AbsStkNorm,@MinimumQty,@EffDate
	END
	CLOSE Cur_StockNorm
	DEALLOCATE Cur_StockNorm
	RETURN
END
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'Proc_ImportBLStockNorm')
DROP PROCEDURE Proc_ImportBLStockNorm
GO
CREATE  PROCEDURE [dbo].[Proc_ImportBLStockNorm]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportBLStockNorm
* PURPOSE	: To Insert and Update records  from xml file in the Table Company
* CREATED	: MarySubashini.S 
* CREATED DATE	: 09/01/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}

*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER

	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
    	--TRUNCATE TABLE ETL_Prk_StockNorm
    
	INSERT INTO ETL_Prk_StockNorm
		SELECT  [Distcode],[LevelCode],[BrandCode],[SKUCode],[StockNorm],[MOQ],[EffFromDate],[DownLoadFlag]
		FROM 	OPENXML (@hdoc,'/Root/Console2CS_StockNorm',1)
		WITH (
			         [Distcode]     VARCHAR(50) ,
                     [LevelCode] 	VARCHAR(50) ,
	                 [BrandCode] 	VARCHAR(100) ,
	                 [SKUCode]	    VARCHAR(100),
	                 [StockNorm]	INT,
                     [MOQ]          INT,
	                 [EffFromDate]	DATETIME,
	                 [DownLoadFlag]	VARCHAR(1) 	
		     ) XMLObj

	SELECT * FROM ETL_Prk_StockNorm
	
	EXECUTE sp_xml_removedocument @hDoc
END
GO
DELETE FROM RptExcelHeaders WHERE RptId=232
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(232,	1,	'InvId',	'InvId',	0,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(232,	2,	'RefNo',	'Bill No',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(232,	3,	'InvDate',	'Bill Date',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(232,	4,	'RtrId',	'RtrId',	0,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(232,	5,	'RtrName',	'Retailer Name',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(232,	6,	'RtrTINNo',	'RtrTINNo',	1,	1)
INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
VALUES(232,	7,	'UsrId',	'UsrId',	0,	1)
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptSalesVatReport')
DROP PROCEDURE Proc_RptSalesVatReport
GO
CREATE PROCEDURE [dbo].[Proc_RptSalesVatReport]
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
/*******************************************************************************************************
* VIEW	: Proc_RptSalesVatReport
* PURPOSE	: To get sales tax Details
* CREATED BY	: Karthick.K.J
* CREATED DATE	: 25/05/2011
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------------------------------
* {date} {developer}  {brief modification description}	
********************************************************************************************************/
BEGIN
	SET NOCOUNT ON
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @CmpId 		AS	INT
	DECLARE @InvoiceType AS  INT 
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @InvoiceType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,274,@Pi_UsrId))
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
		EXEC Proc_SalesTaxSummary @FromDate,@ToDate,@Pi_UsrId,@InvoiceType,@CmpId
		INSERT INTO TempRptSalestaxsumamry 
		  SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId,
			   'Cash Discount',(cashDiscount),IOTaxType,4 TaxFlag,0 TaxPercent,0 TaxId,7,UserId 
		 FROM TempRptSalestaxsumamry   
		 GROUP BY InvId,RefNo,InvDate,RtrId,RtrName,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId, 
		 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId,RtrTINNo
		 UNION ALL  
		 SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId,
			   'Visibility Amount',(visibilityAmount),IOTaxType,5 TaxFlag,0 TaxPercent,0 TaxId,8,UserId 
		 FROM TempRptSalestaxsumamry   
		 GROUP BY InvId,RefNo,InvDate,RtrId,RtrName,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId, 
		 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId,RtrTINNo
	UNION ALL
		 SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId,
			   'Net Amount',(NetAmount),IOTaxType,6 TaxFlag,0 TaxPercent,0 TaxId,9,UserId 
		 FROM TempRptSalestaxsumamry   
		 GROUP BY InvId,RefNo,InvDate,RtrId,RtrName,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId, 
		 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId,RtrTINNo
	END 
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM TempRptSalestaxsumamry  
  DECLARE  @InvId BIGINT  
  DECLARE  @RefNo NVARCHAR(100)  
  DECLARE  @PurRcptRefNo NVARCHAR(50)  
  DECLARE  @TaxPerc   NVARCHAR(100)  
  DECLARE  @TaxableAmount NUMERIC(38,6)  
  DECLARE  @IOTaxType    NVARCHAR(100)  
  DECLARE  @SlNo INT    
  DECLARE  @TaxFlag      INT  
  DECLARE  @Column VARCHAR(80)  
  DECLARE  @C_SSQL VARCHAR(4000)  
  DECLARE  @iCnt INT  
  DECLARE  @TaxPercent NUMERIC(38,6)  
  DECLARE  @Name   NVARCHAR(100)  
  DECLARE  @RtrId INT  
  DECLARE  @ColNo INT  
  --DROP TABLE [RptSalesVatDetails_Excel]  
  IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSalesVatDetails_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
  DROP TABLE RptSalesVatDetails_Excel  
  DELETE FROM RptExcelHeaders Where RptId=232 AND SlNo>7  
  CREATE TABLE RptSalesVatDetails_Excel (
				InvId BIGINT,RefNo NVARCHAR(100),InvDate DATETIME,
				RtrId INT,RtrName NVARCHAR(100),RtrTINNo NVARCHAR(100),UsrId INT)  
  SET @iCnt=8  

	DELETE FROM RptExcelHeaders WHERE RptId=232
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	1,	'InvId',	'InvId',	0,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	2,	'RefNo',	'Bill No',	1,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	3,	'InvDate',	'Bill Date',	1,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	4,	'RtrId',	'RtrId',	0,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	5,	'RtrName',	'Retailer Name',	1,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	6,	'RtrTINNo',	'RtrTINNo',	1,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	7,	'UsrId',	'UsrId',	0,	1)

	 IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'TempRptSalestaxsumamry1') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
	 DROP TABLE TempRptSalestaxsumamry1  
		CREATE TABLE TempRptSalestaxsumamry1 (
				TaxPerc VARCHAR(100),TaxPercent NUMERIC(38,2),
				TaxFlag INT)  
	INSERT INTO TempRptSalestaxsumamry1
	SELECT DISTINCT TaxPerc,TaxPercent,TaxFlag FROM TempRptSalestaxsumamry 

	SELECT DISTINCT TaxPerc,TaxPercent,TaxFlag INTO #TempRptSalestaxsumamry FROM TempRptSalestaxsumamry  --ORDER BY ColNo,TaxFlag,TaxPercent

  DECLARE Column_Cur CURSOR FOR  
  SELECT  TaxPerc,TaxPercent,TaxFlag FROM #TempRptSalestaxsumamry  ORDER BY  TaxFlag,TaxPercent
  OPEN Column_Cur  
      FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='ALTER TABLE RptSalesVatDetails_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'  
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
  DELETE FROM RptSalesVatDetails_Excel  
  INSERT INTO RptSalesVatDetails_Excel(InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,UsrId)  
  SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,@Pi_UsrId  
    FROM TempRptSalestaxsumamry  
  --Select * from [RptSalesVatDetails_Excel]  
  DECLARE Values_Cur CURSOR FOR  
  SELECT DISTINCT InvId,RefNo,RtrId,TaxPerc,TaxableAmount FROM TempRptSalestaxsumamry  
  OPEN Values_Cur  
      FETCH NEXT FROM Values_Cur INTO @InvId,@RefNo,@RtrId,@TaxPerc,@TaxableAmount  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='UPDATE RptSalesVatDetails_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))  
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
  SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptSalesVatDetails_Excel]')  
  OPEN NullCursor_Cur  
      FETCH NEXT FROM NullCursor_Cur INTO @Name  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='UPDATE RptSalesVatDetails_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))  
     SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''  
     EXEC (@C_SSQL)  
     PRINT @C_SSQL  
     FETCH NEXT FROM NullCursor_Cur INTO @Name  
    END  
  CLOSE NullCursor_Cur  
  DEALLOCATE NullCursor_Cur  
select * from TempRptSalestaxsumamry
RETURN  
END 
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='P' AND [Name]='Proc_RptOUTPUTVATSummary')
DROP PROCEDURE Proc_RptOUTPUTVATSummary
--EXEC Proc_RptOUTPUTVATSummary 29,1,0,'CoreStockyTempReport',0,0,1,0
GO
CREATE  PROCEDURE [dbo].[Proc_RptOUTPUTVATSummary]
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
--select * from reportfilterdt
SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @TransNo =(SELECT TOP 1 SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,195,@Pi_UsrId))
SET @DispNet = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,264,@Pi_UsrId))
SET @DispBaseTransNo = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,273,@Pi_UsrId))
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
	INSERT INTO #RptOUTPUTVATSummary (InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,IOTaxType,TaxPerc,TaxableAmount,TaxFlag,TaxPercent)
		Select InvId,RefNo,InvDate,T.RtrId,R.RtrName,R.RtrTINNo,IOTaxType,TaxPerc,sum(TaxableAmount),
--		case IOTaxType when 'Sales' then TaxableAmount when 'SalesReturn' then -1 * TaxableAmount end as TaxableAmount ,
		TaxFlag,TaxPerCent From TmpRptIOTaxSummary T,Retailer R
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
--Prepared by Karthick.Kj on 2011-11-23 for Sales Return Report Issue
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='TempReportSalesReturnValues' AND XTYPE='U')
DROP TABLE TEMPREPORTSALESRETURNVALUES
GO
CREATE TABLE TempReportSalesReturnValues(
	[ReturnID] [bigint] NULL,
	[SRN Number] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SR Date] [datetime] NULL,
	[Salesman] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Route Name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Retialer Name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalId] [int] NULL,
	[Bill No] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdId] [int] NULL,
	[Product Code] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Description] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StockTypeId] [int] NULL,
	[Stock Type] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Quantity (Base Qty)] [numeric](38, 0) NULL,
	[Gross Amount] [numeric](38, 2) NULL,
	[FieldDesc] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LineBaseQtyAmt] [numeric](38, 2) NULL,
	[Net Amount] [numeric](38, 2) NULL,
	[CmpId] [int] NULL,
	[RtrId] [int] NULL,
	[SMId] [int] NULL,
	[RMId] [int] NULL,
	[SeqId] [int] NULL,
	[Status] [tinyint] NULL,
	[Prdbatid] int 
) 
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ReportSalesReturnValues' AND XTYPE='P')
DROP PROCEDURE Proc_ReportSalesReturnValues
GO
--EXEC Proc_ReportSalesReturnValues 9,2
--SELECT * FROM TempReportSalesReturnValues
CREATE Procedure Proc_ReportSalesReturnValues
(
	@Pi_RptId 		INT,
	@Pi_UsrId 		INT
)
/************************************************************
* VIEW	: Proc_ReportSalesReturnValues
* PURPOSE	: To get the Sales Return Values
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 18/02/2010
* NOTE		:
* MODIFIED  :
* DATE		      AUTHOR			DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
	DECLARE @FromDate AS DATETIME
	DECLARE @ToDate AS DATETIME
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(9,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	DELETE FROM TempReportSalesReturnValues
	INSERT INTO TempReportSalesReturnValues ([ReturnID],[SRN Number],[SR Date],[Salesman],[Route Name],
			[Retialer Name],[SalId],[Bill No],[PrdId],[Product Code],[Product Description],[StockTypeId],
			[Stock Type],[Quantity (Base Qty)],[Gross Amount],[FieldDesc],[LineBaseQtyAmt],[Net Amount],[CmpId],
			[RtrId],[SMId],[RMId],[SeqId],[Status],[Prdbatid])

				SELECT RH.ReturnID,RH.ReturnCode as [SRN Number],RH.ReturnDate as [SR Date],SM.SMName AS [Salesman], RM.RMName AS [Route Name],
						Rt.RtrName as [Retialer Name],ISNULL(RP.SalId,0) as SalId,
						Case ISNULL(SI.SalId,0) When ISNULL(Rp.SalId,0) then ISNULL(Si.SalInvNo,Rp.SalCode) Else ISNULL(Rp.SalCode,'-') End as [Bill No],
						RP.PrdId as PrdId,P.PrdDCode as [Product Code],P.PrdName as [Product Description],
						RP.StockTypeId as StockTypeId,St.UserStockType as [Stock Type],RP.BaseQty as [Quantity (Base Qty)],
						SUM(RP.PrdGrossAmt) as [Gross Amount],BS.FieldDesc,SUM(RL.LineBaseQtyAmt) AS LineBaseQtyAmt,SUM(RP.PrdNetAmt) as [Net Amount]
						,C.CmpId,Rt.RtrId,SM.SMId,RM.RMId,BS.Slno as  SeqId,RH.Status,RP.prdbatid
					FROM ReturnHeader RH, Retailer Rt,StockType St,BillSequenceDetail BS,
						COMPANY C, RouteMaster RM,Salesman SM,Product P, ProductBatch PB,ReturnLineAmount RL,
						ReturnProduct RP LEFT OUTER JOIN SalesInvoice SI On RP.SalId = SI.SalId
					WHERE RH.ReturnID=RP.ReturnID AND RH.RtrId = Rt.RtrId AND RH.RMId=RM.RMId
						AND RH.SMId= SM.SMId AND RP.StockTypeId= St.StockTypeId and RP.PrdId = P.PrdId
						AND RP.PrdBatId = PB.PrdBatId and RH.BillSeqId= BS.BillSeqId and RP.Slno=RL.PrdSlno
						AND RL.RefCode=BS.RefCode AND RH.ReturnID=RL.ReturnId and C.CmpId=P.CmpId
						AND RH.ReturnDate Between @FromDate and @ToDate
					GROUP BY RH.ReturnID,RH.ReturnCode,RH.ReturnDate,Rt.RtrName,RP.SalId,RP.PrdId,
						P.PrdDCode,P.PrdName,RP.StockTypeId,St.UserStockType,SI.SalId,Si.SalInvNo,
						Rp.SalCode,BS.FieldDesc,
						C.CmpId,Rt.RtrId,SM.SMId,RM.RMId,BS.Slno,RH.Status  ,RP.BaseQty,SM.SMName, RM.RMName,RP.prdbatid
				UNION ALL
					SELECT RH.ReturnID,RH.ReturnCode as [SRN Number],RH.ReturnDate as [SR Date],SM.SMName AS [Salesman], RM.RMName AS [Route Name],
						Rt.RtrName as [Retialer Name],ISNULL(RP.SalId,0) as SalId,
						Case ISNULL(SI.SalId,0) When ISNULL(Rp.SalId,0) then ISNULL(Si.SalInvNo,Rp.SalCode) Else ISNULL(Rp.SalCode,'-') End as [Bill No],
						RSF.FreePrdId as PrdId,P.PrdDCode as [Product Code],P.PrdName as [Product Description],
						RSF.FreeStockTypeId as StockTypeId,St.UserStockType as [Stock Type],RSF.ReturnFreeQty as [Quantity (Base Qty)],
						0 as [Gross Amount],BS.FieldDesc,0 as LineBaseQtyAmt,0 as [Net Amount],
						C.CmpId,Rt.RtrId,SM.SMId,RM.RMId,BS.Slno as  SeqId,RH.Status,RP.prdbatid
					FROM ReturnHeader RH, Retailer Rt,StockType St,BillSequenceDetail BS,
						COMPANY C, RouteMaster RM,Salesman SM,Product P, ProductBatch PB,SalesInvoiceSchemeHd SHD,
						ReturnSchemeFreePrdDt RSF,ReturnProduct RP LEFT OUTER JOIN SalesInvoice SI On RP.SalId = SI.SalId
					WHERE RH.ReturnID=RP.ReturnID AND RH.RtrId = Rt.RtrId AND RH.RMId=RM.RMId AND Si.SalId=SHD.SalId AND RSF.SchId=SHD.SchId
						AND RH.SMId= SM.SMId AND RSF.FreeStockTypeId= St.StockTypeId and RSF.FreePrdId = P.PrdId
						AND RSF.FreePrdBatId = PB.PrdBatId and RH.BillSeqId= BS.BillSeqId AND C.CmpId=P.CmpId
						AND RH.ReturnID=RSF.ReturnId  AND RH.ReturnID=RP.ReturnId and BS.RefCode<>'A' and BS.RefCode<>'B' and BS.RefCode<>'C'
						AND RH.ReturnDate Between @FromDate and @ToDate
					GROUP BY RH.ReturnID,RH.ReturnCode,RH.ReturnDate,Rt.RtrName,RP.SalId,
						P.PrdDCode,P.PrdName,St.UserStockType,SI.SalId,Si.SalInvNo,
						Rp.SalCode,BS.FieldDesc,RSF.FreePrdId,RSF.FreeStockTypeId,
						C.CmpId,Rt.RtrId,SM.SMId,RM.RMId,BS.Slno,RH.Status,RSF.ReturnFreeQty,SM.SMName, RM.RMName,RP.prdbatid
					HAVING SUM(RSF.ReturnFreeQty)>0
				UNION ALL
					SELECT RH.ReturnID,RH.ReturnCode as [SRN Number],RH.ReturnDate as [SR Date],SM.SMName AS [Salesman], RM.RMName AS [Route Name],
						Rt.RtrName as [Retialer Name],ISNULL(RP.SalId,0) as SalId,
						Case ISNULL(SI.SalId,0) When ISNULL(Rp.SalId,0) then ISNULL(Si.SalInvNo,Rp.SalCode) Else ISNULL(Rp.SalCode,'-') End as [Bill No],
						RSF.GiftPrdId as PrdId,P.PrdDCode as [Product Code],P.PrdName as [Product Description],
						RSF.GiftStockTypeId as StockTypeId,St.UserStockType as [Stock Type],RSF.ReturnGiftQty as [Quantity (Base Qty)],
						0 as [Gross Amount],BS.FieldDesc,0 as LineBaseQtyAmt,0 as [Net Amount],
						C.CmpId,Rt.RtrId,SM.SMId,RM.RMId,BS.Slno as  SeqId,RH.Status,RP.prdbatid
					FROM ReturnHeader RH, Retailer Rt,StockType St,BillSequenceDetail BS,
						COMPANY C, RouteMaster RM,Salesman SM,Product P, ProductBatch PB,ReturnLineAmount RL,SalesInvoiceSchemeHd SHD,
						ReturnSchemeFreePrdDt RSF,ReturnProduct RP LEFT OUTER JOIN SalesInvoice SI On RP.SalId = SI.SalId
					WHERE RH.ReturnID=RP.ReturnID AND RH.RtrId = Rt.RtrId AND RH.RMId=RM.RMId  AND Si.SalId=SHD.SalId AND RSF.SchId=SHD.SchId
						AND RH.SMId= SM.SMId AND RSF.GiftStockTypeId= St.StockTypeId and RSF.GiftPrdId = P.PrdId
						AND RSF.GiftPrdBatId = PB.PrdBatId and RH.BillSeqId= BS.BillSeqId and C.CmpId=P.CmpId
						AND RH.ReturnID=RSF.ReturnId and BS.RefCode<>'A' and BS.RefCode<>'B' and BS.RefCode<>'C'
						AND RH.ReturnDate Between @FromDate and @ToDate
					GROUP BY RH.ReturnID,RH.ReturnCode,RH.ReturnDate,Rt.RtrName,RP.SalId,
						P.PrdDCode,P.PrdName,St.UserStockType,SI.SalId,Si.SalInvNo,
						Rp.SalCode,BS.FieldDesc,RSF.GiftPrdId,RSF.GiftStockTypeId,
						C.CmpId,Rt.RtrId,SM.SMId,RM.RMId,BS.Slno,RH.Status,RSF.ReturnGiftQty,SM.SMName, RM.RMName,RP.prdbatid
					HAVING SUM(RSF.ReturnGiftQty)>0
				UNION ALL
					SELECT RH.ReturnID,RH.ReturnCode as [SRN Number],RH.ReturnDate as [SR Date],SM.SMName AS [Salesman], RM.RMName AS [Route Name],
						Rt.RtrName as [Retialer Name],ISNULL(RP.SalId,0) as SalId,
						Case ISNULL(SI.SalId,0) When ISNULL(Rp.SalId,0) then ISNULL(Si.SalInvNo,Rp.SalCode) Else ISNULL(Rp.SalCode,'-') End as [Bill No],
						RP.PrdId as PrdId,P.PrdDCode as [Product Code],P.PrdName as [Product Description],
						RP.StockTypeId as StockTypeId,St.UserStockType as [Stock Type],RP.BaseQty as [Quantity (Base Qty)],
						RP.PrdGrossAmt as [Gross Amount],'Net Amount' as FieldDesc,SUM(RP.PrdNetAmt) as LineBaseQtyAmt,
						RP.PrdNetAmt as [Net Amount]
						,C.CmpId,Rt.RtrId,SM.SMId,RM.RMId,
						(Select max(Slno) + 1 From BillSequenceDetail Where
						BillSeqId = RH.BillSeqId) as  SeqId,RH.Status,RP.prdbatid
					FROM ReturnHeader RH, Retailer Rt,StockType St,
						COMPANY C,RouteMaster RM,Salesman SM,Product P, ProductBatch PB,
						ReturnProduct RP LEFT OUTER JOIN SalesInvoice SI On RP.SalId = SI.SalId
					WHERE RH.ReturnID=RP.ReturnID AND RH.RtrId = Rt.RtrId AND RH.RMId=RM.RMId
						AND RH.SMId= SM.SMId AND RP.StockTypeId= St.StockTypeId and RP.PrdId = P.PrdId
						AND RP.PrdBatId = PB.PrdBatId
						AND C.CmpId=P.CmpId AND RH.ReturnDate Between @FromDate and @ToDate
					GROUP BY RH.ReturnID,RH.ReturnCode,RH.ReturnDate,Rt.RtrName,RP.SalId,RP.PrdId,
						P.PrdDCode,P.PrdName,RP.StockTypeId,St.UserStockType,SI.SalId,Si.SalInvNo,
						Rp.SalCode,	C.CmpId,Rt.RtrId,SM.SMId,RM.RMId,RH.BillSeqId,RH.Status,RP.PrdGrossAmt ,RP.PrdNetAmt,RP.BaseQty,SM.SMName, RM.RMName,RP.prdbatid
				UNION ALL
					SELECT RH.ReturnID,RH.ReturnCode as [SRN Number],RH.ReturnDate as [SR Date],SM.SMName AS [Salesman], RM.RMName AS [Route Name],
						Rt.RtrName as [Retialer Name],ISNULL(RP.SalId,0) as SalId,
						Case ISNULL(SI.SalId,0) When ISNULL(Rp.SalId,0) then ISNULL(Si.SalInvNo,Rp.SalCode) Else ISNULL(Rp.SalCode,'-') End as [Bill No],
						RP.PrdId as PrdId,P.PrdDCode as [Product Code],P.PrdName as [Product Description],
						RP.StockTypeId as StockTypeId,St.UserStockType as [Stock Type],RP.BaseQty as [Quantity (Base Qty)],
						RP.PrdGrossAmt as [Gross Amount],'Gross Amount' as FieldDesc,SUM(RP.PrdGrossAmt) as LineBaseQtyAmt,
						RP.PrdNetAmt as [Net Amount],C.CmpId,Rt.RtrId,SM.SMId,
						RM.RMId,0 as  SeqId,RH.Status,RP.prdbatid
					FROM ReturnHeader RH, Retailer Rt,StockType St,
						COMPANY C,RouteMaster RM,Salesman SM,Product P, ProductBatch PB,
						ReturnProduct RP LEFT OUTER JOIN SalesInvoice SI On RP.SalId = SI.SalId
					WHERE RH.ReturnID=RP.ReturnID AND RH.RtrId = Rt.RtrId AND RH.RMId=RM.RMId
						AND RH.SMId= SM.SMId AND RP.StockTypeId= St.StockTypeId and RP.PrdId = P.PrdId
						AND RP.PrdBatId = PB.PrdBatId AND C.CmpId=P.CmpId
						AND RH.ReturnDate Between @FromDate and @ToDate
					GROUP BY RH.ReturnID,RH.ReturnCode,RH.ReturnDate,Rt.RtrName,RP.SalId,RP.PrdId,
						P.PrdDCode,P.PrdName,RP.StockTypeId,St.UserStockType,SI.SalId,Si.SalInvNo,
						Rp.SalCode,C.CmpId,Rt.RtrId,SM.SMId,RM.RMId,RH.Status,RP.PrdGrossAmt ,RP.PrdNetAmt,RP.BaseQty,SM.SMName, RM.RMName,RP.prdbatid

GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_RptSalesReturn' AND XTYPE='P')
DROP PROCEDURE Proc_RptSalesReturn
GO
--EXEC Proc_RptSalesReturn 9,2,0,'VER2.5-REPORTS',0,0,1
CREATE PROCEDURE Proc_RptSalesReturn
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
	EXEC Proc_ReportSalesReturnValues @Pi_RptId,@Pi_UsrId
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		INSERT INTO #RptSalesReturn ([SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],[Bill No],
				   [Product Code],[Product Description],[Stock Type],[Quantity (Base Qty)],SeqId,[Gross Amount],FieldDesc,
			   LineBaseQtyAmt,[Net Amount],[UsrId])
SELECT [SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],
			   [Bill No],[Product Code],[Product Description], [Stock Type],sum([Quantity (Base Qty)]) qty,SeqId,
			   sum([Gross Amount]) as[Gross Amount],FieldDesc,sum(LineBaseQtyAmt),sum([Net Amount])[Net Amount],CAST(@Pi_UsrId as INT)
FROM 
(SELECT [SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],
			   [Bill No],[Product Code],[Product Description],
			   [Stock Type],[Quantity (Base Qty)],SeqId,
			   [Gross Amount],FieldDesc,LineBaseQtyAmt,[Net Amount],[prdbatid]
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
			AND Status = 0)A
GROUP BY [SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],
			   [Bill No],[Product Code],[Product Description],
			   [Stock Type],SeqId,FieldDesc

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
		select [SRN Number],[SR Date],[Salesman],[Route Name],[Retialer Name],[Bill No], [Product Code],[Product Description],[Stock Type],SUM(DISTINCT [Quantity (Base Qty)]),@Pi_UsrId,
		0 AS Uom1,0 AS Uom2,0 AS Uom3,0 AS Uom4 from (
		SELECT DISTINCT A.[SRN Number],A.[SR Date],[Salesman],[Route Name],A.[Retialer Name],A.[Bill No], A.[Product Code],A.[Product Description],A.[Stock Type],A.[Quantity (Base Qty)],
		0 AS Uom1,0 AS Uom2,0 AS Uom3,0 AS Uom4 FROM #RptSalesReturn A, View_ProdUOMDetails B WHERE a.[Product Code]=b.PrdDcode
		)A GROUP BY A.[SRN Number],A.[SR Date],A.[Salesman],A.[Route Name],A.[Retialer Name],A.[Bill No], A.[Product Code],A.[Product Description],A.[Stock Type] 

		DECLARE Values_Cur CURSOR FOR
		select distinct [SRN Number],[SR Date],[Product Code],[Bill No],[Stock Type],FieldDesc,sum(LineBaseQtyAmt) from (
		SELECT DISTINCT  [SRN Number],[SR Date],[Product Code],[Bill No],[Stock Type],FieldDesc,LineBaseQtyAmt FROM #RptSalesReturn)A
		group by [SRN Number],[SR Date],[Product Code],[Bill No],[Stock Type],FieldDesc
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
---*****Retailer Selection With Retailer Address
Delete from Customcaptions Where Transid = 2 And Ctrlid = 2000 And SubCtrlid = 184 
Go
Insert into Customcaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values (2,2000,184,'HotSch-2-2000-184','Address1','','',1,1,1,GetDate(),1,GetDate(),'Address1','','',1,1)
Delete from Customcaptions Where Transid = 2 And Ctrlid = 2000 And SubCtrlid = 185
Go
Insert into Customcaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values (2,2000,185,'HotSch-2-2000-185','Address2','','',1,1,1,GetDate(),1,GetDate(),'Address2','','',1,1)
Delete from Customcaptions Where Transid = 2 And Ctrlid = 2000 And SubCtrlid = 186
Go
Insert into Customcaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values (2,2000,186,'HotSch-2-2000-186','Address3','','',1,1,1,GetDate(),1,GetDate(),'Address3','','',1,1)
GO
---Retailer Display Based On Name
Delete From HotSearchEditorHd Where Formid = 550
GO
Insert into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values(550,'Billing','Retailer Display Based On Name','Select',
'SELECT RtrId,RtrName,RtrCode,RtrAdd1,RtrAdd2,RtrAdd3,RtrCovMode,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,
RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT C.RtrId,C.RtrName,C.RtrCode,B.RtrSeqDtId,C.RtrCovMode,C.RtrCashDiscPerc,C.RtrCashdiscCond,C.RtrCashDiscAmt,
C.RtrTaxType,C.RMId AS DelvRMId,C.RTRDayOff,C.RtrCrBills,C.RtrCrLimit,C.RtrCrDays,ISNULL(C.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,
C.RtrDrugLicNo,ISNULL(C.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,C.RtrAdd1,C.RtrAdd2,C.RtrAdd3,C.RtrPestLicNo,
ISNULL(C.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,ISNULL(C.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,
ISNULL(C.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,ISNULL(C.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary, RtrCrDaysAlert,
RtrCrBillsAlert,  RtrCrLimitAlert FROM RetailerSequence A (NOLOCK)INNER JOIN RetailerSeqDetails B (NOLOCK) ON A.RtrSeqID = B.RtrSeqId 
INNER JOIN  Retailer C (NOLOCK) on C.RtrId = B.RtrId Where C.RtrStatus = 1 And A.SMId=vFParam And A.RMId=vSParam And TransactionType=vTParam 
Union SELECT D.RtrId,D.RtrName,D.RtrCode,100000 as RtrSeqDtId,D.RtrCovMode,D.RtrCashDiscPerc,D.RtrCashdiscCond,D.RtrCashDiscAmt,D.RtrTaxType,D.RMId AS DelvRMId,
D.RTRDayOff, D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,D.RtrDrugLicNo,
ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,
Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,  ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),
GetDate(),121)) AS RtrDOB,  ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary, RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK)  
INNER JOIN RetailerMarket E (NOLOCK) ON D.RtrId = E.RtrId   Where D.RtrStatus = 1 And E.RMId = vSParam And D.Rtrid Not In (SELECT C.RtrId FROM  RetailerSequence A (NOLOCK)   
INNER JOIN RetailerSeqDetails B (NOLOCK) ON A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on  C.RtrId = B.RtrId Where C.RtrStatus = 1 And 
A.SMId=vFParam And A.RMId=vSParam And TransactionType=vTParam) ) a  ORDER BY RtrName')
GO
Delete From HotSearchEditorDt Where Formid = 550
GO
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (1,550,'Retailer Display Based On Name','Name','RtrName',3000,0,'HotSch-2-2000-155',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (2,550,'Retailer Display Based On Name','Code','RtrCode',1500,0,'HotSch-2-2000-163',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (3,550,'Retailer Display Based On Name','Address1','RtrAdd1',3250,0,'HotSch-2-2000-184',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (4,550,'Retailer Display Based On Name','Address2','RtrAdd2',3250,0,'HotSch-2-2000-185',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (5,550,'Retailer Display Based On Name','Address3','RtrAdd3',3250,0,'HotSch-2-2000-186',2)
GO
--Retailer Display Based On Code
Delete From HotSearchEditorHd Where Formid = 552
GO
Insert into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values(552,'Billing','Retailer Display Based On Code','Select',
'SELECT RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrCovMode,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,
RtrLicExpiryDate,RtrSeqDtId,RtrCovMode,RtrCashDiscPerc,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT C.RtrId,C.RtrName,C.RtrCode,B.RtrSeqDtId,C.RtrCovMode,C.RtrCashDiscPerc,C.RtrCashdiscCond,C.RtrCashDiscAmt,
C.RtrTaxType,C.RMId AS DelvRMId,C.RTRDayOff,C.RtrCrBills,C.RtrCrLimit,C.RtrCrDays,ISNULL(C.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,
C.RtrDrugLicNo,ISNULL(C.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,C.RtrAdd1,C.RtrAdd2,C.RtrAdd3,C.RtrPestLicNo,
ISNULL(C.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,ISNULL(C.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,
ISNULL(C.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,ISNULL(C.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary, RtrCrDaysAlert,
RtrCrBillsAlert,  RtrCrLimitAlert FROM RetailerSequence A (NOLOCK)INNER JOIN RetailerSeqDetails B (NOLOCK) ON A.RtrSeqID = B.RtrSeqId 
INNER JOIN  Retailer C (NOLOCK) on C.RtrId = B.RtrId Where C.RtrStatus = 1 And A.SMId=vFParam And A.RMId=vSParam And TransactionType=vTParam 
Union SELECT D.RtrId,D.RtrName,D.RtrCode,100000 as RtrSeqDtId,D.RtrCovMode,D.RtrCashDiscPerc,D.RtrCashdiscCond,D.RtrCashDiscAmt,D.RtrTaxType,D.RMId AS DelvRMId,
D.RTRDayOff, D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,D.RtrDrugLicNo,
ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,
Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,  ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),
GetDate(),121)) AS RtrDOB,  ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary, RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK)  
INNER JOIN RetailerMarket E (NOLOCK) ON D.RtrId = E.RtrId   Where D.RtrStatus = 1 And E.RMId = vSParam And D.Rtrid Not In (SELECT C.RtrId FROM  RetailerSequence A (NOLOCK)   
INNER JOIN RetailerSeqDetails B (NOLOCK) ON A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on  C.RtrId = B.RtrId Where C.RtrStatus = 1 And 
A.SMId=vFParam And A.RMId=vSParam And TransactionType=vTParam) ) a  ORDER BY RtrCode')
GO
Delete From HotSearchEditorDt Where Formid = 552
GO
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (1,552,'Retailer Display Based On Code','Code','RtrCode',1000,0,'HotSch-2-2000-157',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (2,552,'Retailer Display Based On Code','Name','RtrName',2500,0,'HotSch-2-2000-158',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (3,552,'Retailer Display Based On Code','Address1','RtrAdd1',3250,0,'HotSch-2-2000-184',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (4,552,'Retailer Display Based On Code','Address2','RtrAdd2',3250,0,'HotSch-2-2000-185',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (5,552,'Retailer Display Based On Code','Address3','RtrAdd3',3250,0,'HotSch-2-2000-186',2)
GO
----Retailer Display Based On Sequence
Delete From HotSearchEditorHd Where Formid = 551
GO
Insert into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values(551,'Billing','Retailer Display Based On Sequence','Select',
'SELECT RtrId,RtrSeqDtId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrCovMode,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,RtrTINNo,
RtrCSTNo,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT C.RtrId,B.RtrSeqDtId,C.RtrCode,C.RtrName,C.RtrAdd1,C.RtrAdd2,C.RtrAdd3,C.RtrCovMode,C.RtrTaxType,
C.RMId AS DelvRMId,C.RTRDayOff,C.RtrCrBills,C.RtrCrLimit,C.RtrCrDays,C.RtrTINNo,C.RtrCSTNo, C.RtrLicNo,ISNULL(C.RtrLicExpiryDate,Convert(Varchar(10),
GetDate(),121)) AS RtrLicExpiryDate,C.RtrDrugLicNo,ISNULL(C.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,C.RtrPestLicNo,
ISNULL(C.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,ISNULL(C.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,
ISNULL(C.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,ISNULL(C.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,
RtrCrLimitAlert FROM RetailerSequence A (NOLOCK)   INNER JOIN RetailerSeqDetails B (NOLOCK) ON A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on C.RtrId = B.RtrId  
Where C.RtrStatus = 1 And A.SMId = vFParam And A.RMId = vSParam And TransactionType=vTParam  Union   SELECT D.RtrId,100000 as RtrSeqDtId,D.RtrCode,D.RtrName,
D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCovMode,D.RtrTaxType,D.RMId AS DelvRMId,D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo, D.RtrLicNo,  
ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,   D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,  
D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,   ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,   
ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,   ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK) 
INNER JOIN   RetailerMarket E (NOLOCK) ON D.RtrId = E.RtrId Where D.RtrStatus = 1 And E.RMId = vSParam  And D.Rtrid Not In (SELECT C.RtrId FROM RetailerSequence A (NOLOCK) INNER JOIN  RetailerSeqDetails B (NOLOCK) 
ON A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on   C.RtrId = B.RtrId Where C.RtrStatus = 1 And A.SMId = vFParam And A.RMId = vSParam  And TransactionType=vTParam)) A ORDER BY RtrSeqDtId')
GO
Delete From HotSearchEditorDt Where Formid = 551
GO
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (1,551,'Retailer Display Based On Sequence','Seq No','RtrSeqDtId',500,0,'HotSch-2-2000-159',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (2,551,'Retailer Display Based On Sequence','Code','RtrCode',1000,0,'HotSch-2-2000-160',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (3,551,'Retailer Display Based On Sequence','Name','RtrName',1500,0,'HotSch-2-2000-161',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (4,551,'Retailer Display Based On Sequence','Address1','RtrAdd1',1250,0,'HotSch-2-2000-184',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (5,551,'Retailer Display Based On Sequence','Address2','RtrAdd2',1250,0,'HotSch-2-2000-185',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (6,551,'Retailer Display Based On Sequence','Address3','RtrAdd3',1250,0,'HotSch-2-2000-186',2)
GO
--Direct Retailer Based on Sequence
Delete From HotSearchEditorHd Where Formid = 556
GO
Insert into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values(556,'Billing','Direct Retailer Based on Sequence','Select',
'SELECT RtrId,RtrSeqDtId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrCovMode,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,RtrTINNo,
RtrCSTNo,RtrLicNo,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,
RtrCrLimitAlert FROM (SELECT D.RtrId,100000 as RtrSeqDtId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCovMode,D.RtrTaxType,D.RMId AS DelvRMId,
D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo, D.RtrLicNo,  ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,
D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrPestExpiryDate,
ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) 
AS RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK) Where D.RtrStatus = 1 ) a ORDER BY RtrSeqDtId')
GO
Delete From HotSearchEditorDt Where Formid = 556
GO
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (1,556,'Direct Retailer Based on Sequence','Seq No','RtrSeqDtId',750,0,'HotSch-2-2000-162',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (2,556,'Direct Retailer Based on Sequence','Code','RtrCode',2500,0,'HotSch-2-2000-163',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (3,556,'Direct Retailer Based on Sequence','Name','RtrName',2500,0,'HotSch-2-2000-164',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (4,556,'Direct Retailer Based on Sequence','Address1','RtrAdd1',3250,0,'HotSch-2-2000-184',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (5,556,'Direct Retailer Based on Sequence','Address2','RtrAdd2',3250,0,'HotSch-2-2000-185',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (6,556,'Direct Retailer Based on Sequence','Address3','RtrAdd3',3250,0,'HotSch-2-2000-186',2)
GO
---Direct Retailer Based on Name
Delete From HotSearchEditorHd Where Formid = 557
GO
Insert into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values(557,'Billing','Direct Retailer Based on Name','Select',
'SELECT RtrId,RtrName,RtrCode,RtrAdd1,RtrAdd2,RtrAdd3,RtrCovMode,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,RtrTINNo,RtrCSTNo,RtrLicNo,
RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert 
FROM (SELECT D.RtrId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCovMode,D.RtrCashDiscAmt,D.RtrTaxType,D.RMId AS DelvRMId,D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,
D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo, D.RtrLicNo,  ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,D.RtrDrugLicNo,
ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),
GetDate(),121)) AS RtrPestExpiryDate,ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,
ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK) Where D.RtrStatus = 1 ) a ORDER BY RtrName')
GO
Delete From HotSearchEditorDt Where Formid = 557
GO
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (1,557,'Direct Retailer Based on Name','Name','RtrName',1000,0,'HotSch-2-2000-167',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (2,557,'Direct Retailer Based on Name','Code','RtrCode',2500,0,'HotSch-2-2000-168',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (3,557,'Direct Retailer Based on Name','Address1','RtrAdd1',3250,0,'HotSch-2-2000-184',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (4,557,'Direct Retailer Based on Name','Address2','RtrAdd2',3250,0,'HotSch-2-2000-185',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (5,557,'Direct Retailer Based on Name','Address3','RtrAdd3',3250,0,'HotSch-2-2000-186',2)
GO
--Direct Retailer Based on Code
Delete From HotSearchEditorHd Where Formid = 558
GO
Insert into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values(558,'Billing','Direct Retailer Based on Code','Select',
'SELECT RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrCovMode,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,RtrCrBills,RtrCrLimit,RtrCrDays,RtrTINNo,RtrCSTNo,RtrLicNo,
RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert 
FROM (SELECT D.RtrId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCovMode,D.RtrCashDiscAmt,D.RtrTaxType,D.RMId AS DelvRMId,D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,
D.RtrCrDays,D.RtrTINNo,D.RtrCSTNo,D.RtrLicNo,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,D.RtrDrugLicNo,
ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo,ISNULL(D.RtrPestExpiryDate,Convert(Varchar(10),
GetDate(),121)) AS RtrPestExpiryDate,ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,
ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK) Where D.RtrStatus = 1 ) a ORDER BY RtrCode')
GO
Delete From HotSearchEditorDt Where Formid = 558
GO
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (1,558,'Direct Retailer Based on Code','Code','RtrCode',1000,0,'HotSch-2-2000-165',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (2,558,'Direct Retailer Based on Code','Name','RtrName',2500,0,'HotSch-2-2000-166',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (3,558,'Direct Retailer Based on Code','Address1','RtrAdd1',3250,0,'HotSch-2-2000-184',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (4,558,'Direct Retailer Based on Code','Address2','RtrAdd2',3250,0,'HotSch-2-2000-185',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (5,558,'Direct Retailer Based on Code','Address3','RtrAdd3',3250,0,'HotSch-2-2000-186',2)
GO
--Select Display with Route Coverage Plan Based on Retailer Sequence
Delete From HotSearchEditorHd Where Formid = 553
GO
Insert into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values(553,'Billing','Select Display with Route Coverage Plan Based on Retailer Sequence','Select',
'SELECT RtrId,RtrSeqDtId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrCovMode,RtrCashDiscPerc,RtrCashdiscCond,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,
RtrCrBills,RtrCrLimit,RtrCrDays,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT D.RtrId,100000 as RtrSeqDtId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCovMode,D.RtrCashDiscPerc,
D.RtrCashdiscCond,D.RtrCashDiscAmt,D.RtrTaxType,D.RMId AS DelvRMId,D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,   
D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo , IsNull(D.RtrPestExpiryDate,Convert(VarChar(10), GetDate(), 121)) AS RtrPestExpiryDate,   
ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,   
RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK)   INNER JOIN RetailerMarket B ON D.RtrId = B.RtrId INNER JOIN RouteCovPlanMaster C 
ON C.RMId = B.RMId   AND C.RMSRouteType=1 AND D.RtrId = CASE C.RtrId WHEN 0 THEN D.RtrId else C.RtrId END   INNER JOIN RouteCovPlanDetails E ON C.RCPMAsterId = E.RCPMasterId   
AND RCPGeneratedDates = ''vSParam'' AND RCPHolidayStatus=0 Where D.RtrStatus = 1 AND B.RMId = vFParam ) a ORDER BY RtrSeqDtId')
GO
Delete From HotSearchEditorDt Where Formid = 553
GO
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (1,553,'Select Display with Route Coverage Plan Based on Retailer Sequence','Seq No','RtrSeqDtId',750,0,'HotSch-2-2000-173',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (2,553,'Select Display with Route Coverage Plan Based on Retailer Sequence','Code','RtrCode',2500,0,'HotSch-2-2000-174',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (2,553,'Select Display with Route Coverage Plan Based on Retailer Sequence','Name','RtrName',2500,0,'HotSch-2-2000-175',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (3,553,'Select Display with Route Coverage Plan Based on Retailer Sequence','Address1','RtrAdd1',3250,0,'HotSch-2-2000-184',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (4,553,'Select Display with Route Coverage Plan Based on Retailer Sequence','Address2','RtrAdd2',3250,0,'HotSch-2-2000-185',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (5,553,'Select Display with Route Coverage Plan Based on Retailer Sequence','Address3','RtrAdd3',3250,0,'HotSch-2-2000-186',2)
GO
--Select Display with Route Coverage Plan Based on Retailer Name
Delete From HotSearchEditorHd Where Formid = 554
GO
Insert into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values(554,'Billing','Select Display with Route Coverage Plan Based on Retailer Name','Select',
'SELECT RtrId,RtrName,RtrCode,RtrAdd1,RtrAdd2,RtrAdd3,RtrTINNo,RtrCovMode,RtrCashDiscPerc,RtrCashdiscCond,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,
RtrCrBills,RtrCrLimit,RtrCrDays,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT D.RtrId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrTINNo,D.RtrCovMode,D.RtrCashDiscPerc,
D.RtrCashdiscCond,D.RtrCashDiscAmt,D.RtrTaxType,D.RMId AS DelvRMId,D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,   
D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo , IsNull(D.RtrPestExpiryDate,Convert(VarChar(10), GetDate(), 121)) AS RtrPestExpiryDate,   
ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,   
RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK)   INNER JOIN RetailerMarket B ON D.RtrId = B.RtrId INNER JOIN RouteCovPlanMaster C 
ON C.RMId = B.RMId   AND C.RMSRouteType=1 AND D.RtrId = CASE C.RtrId WHEN 0 THEN D.RtrId else C.RtrId END   INNER JOIN RouteCovPlanDetails E ON C.RCPMAsterId = E.RCPMasterId   
AND RCPGeneratedDates = ''vSParam'' AND RCPHolidayStatus=0 Where D.RtrStatus = 1 AND B.RMId = vFParam ) a ORDER BY RtrName')
GO
Delete From HotSearchEditorDt Where Formid = 554
GO
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (1,554,'Select Display with Route Coverage Plan Based on Retailer Name','Name','RtrName',3000,0,'HotSch-2-2000-169',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (2,554,'Select Display with Route Coverage Plan Based on Retailer Name','Code','RtrCode',1500,0,'HotSch-2-2000-170',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (3,554,'Select Display with Route Coverage Plan Based on Retailer Name','Address1','RtrAdd1',3250,0,'HotSch-2-2000-184',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (4,554,'Select Display with Route Coverage Plan Based on Retailer Name','Address2','RtrAdd2',3250,0,'HotSch-2-2000-185',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (5,554,'Select Display with Route Coverage Plan Based on Retailer Name','Address3','RtrAdd3',3250,0,'HotSch-2-2000-186',2)
GO
--Select Display with Route Coverage Plan Based on Retailer Code
Delete From HotSearchEditorHd Where Formid = 555
GO
Insert into HotSearchEditorHd (FormId,FormName,ControlName,SltString,RemainsltString)
Values(555,'Billing','Select Display with Route Coverage Plan Based on Retailer Code','Select',
'SELECT RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrTINNo,RtrCovMode,RtrCashDiscPerc,RtrCashdiscCond,RtrCashDiscAmt,RtrTaxType,DelvRMId,RTRDayOff,
RtrCrBills,RtrCrLimit,RtrCrDays,RtrLicExpiryDate,RtrDrugLicNo,RtrDrugExpiryDate,RtrPestLicNo,RtrPestExpiryDate,RtrRegDate,RtrDOB,RtrAnniversary,RtrCrDaysAlert,
RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT D.RtrId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrTINNo,D.RtrCovMode,D.RtrCashDiscPerc,
D.RtrCashdiscCond,D.RtrCashDiscAmt,D.RtrTaxType,D.RMId AS DelvRMId,D.RTRDayOff,D.RtrCrBills,D.RtrCrLimit,D.RtrCrDays,ISNULL(D.RtrLicExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrLicExpiryDate,   
D.RtrDrugLicNo,ISNULL(D.RtrDrugExpiryDate,Convert(Varchar(10),GetDate(),121)) AS RtrDrugExpiryDate,D.RtrPestLicNo , IsNull(D.RtrPestExpiryDate,Convert(VarChar(10), GetDate(), 121)) AS RtrPestExpiryDate,   
ISNULL(D.RtrRegDate,Convert(Varchar(10),GetDate(),121)) AS RtrRegDate,ISNULL(D.RtrDOB,Convert(Varchar(10),GetDate(),121)) AS RtrDOB,ISNULL(D.RtrAnniversary,Convert(Varchar(10),GetDate(),121)) AS RtrAnniversary,   
RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM Retailer D (NOLOCK)   INNER JOIN RetailerMarket B ON D.RtrId = B.RtrId INNER JOIN RouteCovPlanMaster C 
ON C.RMId = B.RMId   AND C.RMSRouteType=1 AND D.RtrId = CASE C.RtrId WHEN 0 THEN D.RtrId else C.RtrId END   INNER JOIN RouteCovPlanDetails E ON C.RCPMAsterId = E.RCPMasterId   
AND RCPGeneratedDates = ''vSParam'' AND RCPHolidayStatus=0 Where D.RtrStatus = 1 AND B.RMId = vFParam ) a ORDER BY RtrCode')
GO
Delete From HotSearchEditorDt Where Formid = 555
GO
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (1,555,'Select Display with Route Coverage Plan Based on Retailer Code','Code','RtrCode',3000,0,'HotSch-2-2000-171',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (2,555,'Select Display with Route Coverage Plan Based on Retailer Code','Name','RtrName',1500,0,'HotSch-2-2000-172',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (3,555,'Select Display with Route Coverage Plan Based on Retailer Code','Address1','RtrAdd1',3250,0,'HotSch-2-2000-184',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (4,555,'Select Display with Route Coverage Plan Based on Retailer Code','Address2','RtrAdd2',3250,0,'HotSch-2-2000-185',2)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values (5,555,'Select Display with Route Coverage Plan Based on Retailer Code','Address3','RtrAdd3',3250,0,'HotSch-2-2000-186',2)
GO
--Order Booking
---Order Booking Address
Delete from HotsearchEditorHD where Formname = 'Order Booking' and Formid = 668
Insert into HotsearchEditorHD (FormId,FormName,ControlName,SltString,RemainsltString)
Values (668,'Order Booking','Retailer','select',
'SELECT RtrSeqDtId,RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT B.RtrSeqDtId,C.RtrId,C.RtrCode,
C.RtrName,C.RtrAdd1,C.RtrAdd2,C.RtrAdd3,C.RtrCrDaysAlert,C.RtrCrBillsAlert,C.RtrCrLimitAlert FROM RetailerSequence A (NOLOCK) INNER JOIN RetailerSeqDetails B(NOLOCK) 
ON A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on C.RtrId = B.RtrId Where C.RtrStatus = 1 And A.SMId = vFParam And A.RMId = vSParam And TransactionType=vTParam    
Union   SELECT 100000 as RtrSeqDtId,D.RtrId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCrDaysAlert,D.RtrCrBillsAlert,  D.RtrCrLimitAlert FROM Retailer D (NOLOCK) 
INNER JOIN RetailerMarket E (NOLOCK) ON   D.RtrId = E.RtrId Where D.RtrStatus = 1 And E.RMId = vSParam And D.Rtrid Not In (SELECT C.RtrId   FROM RetailerSequence A (NOLOCK) 
INNER JOIN RetailerSeqDetails B (NOLOCK) ON   A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on C.RtrId = B.RtrId   Where C.RtrStatus = 1 And A.SMId = vFParam 
And A.RMId = vSParam And TransactionType= vTParam)) a  ORDER BY RtrSeqDtId')
GO
Delete from HotsearchEditorDt where Formid = 668
GO
Insert into HotsearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values(1,668,'Retailer','SequenceId','RtrSeqDtId',1750,0,'HotSch-1-2000-33',1)
Insert into HotsearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values(1,668,'Retailer','Retailer Code','RtrCode',1750,0,'HotSch-1-2000-31',1)
Insert into HotsearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values(2,668,'Retailer','Retailer Name','RtrName',1750,0,'HotSch-1-2000-32',1)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values(3,668,'Retailer','Retailer Address1','RtrAdd1',1750,0,'HotSch-1-2000-187',1)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values(4,668,'Retailer','Retailer Address2','RtrAdd2',1750,0,'HotSch-1-2000-188',1)
Insert into HotSearchEditorDt (Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId)
Values(5,668,'Retailer','Retailer Address3','RtrAdd3',1750,0,'HotSch-1-2000-189',1)
GO
Delete from Customcaptions Where Transid = 1 And Ctrlid = 2000 And SubCtrlid = 187 
Go
Insert into Customcaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values (1,2000,187,'HotSch-1-2000-187','RetailerAddress1','','',1,1,1,GetDate(),1,GetDate(),'RetailerAddress1','','',1,1)
Delete from Customcaptions Where Transid = 1 And Ctrlid = 2000 And SubCtrlid = 188 
GO
Insert into Customcaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values (1,2000,188,'HotSch-1-2000-188','RetailerAddress2','','',1,1,1,GetDate(),1,GetDate(),'RetailerAddress2','','',1,1)
Delete from Customcaptions Where Transid = 1 And Ctrlid = 2000 And SubCtrlid = 189 
GO
Insert into Customcaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values (1,2000,189,'HotSch-1-2000-189','RetailerAddress3','','',1,1,1,GetDate(),1,GetDate(),'RetailerAddress3','','',1,1)
GO
----Order Booking Direct Retailer Selection
Delete from HotsearchEditorHD Where Formid = 10050
GO
Insert into HotsearchEditorHD Select 10050,'Order Booking','DirectRetailer','select',
'SELECT RtrSeqDtId,RtrId,RtrCode,RtrName,RtrAdd1,RtrAdd2,RtrAdd3,RtrCrDaysAlert,RtrCrBillsAlert,RtrCrLimitAlert FROM (SELECT B.RtrSeqDtId,C.RtrId,C.RtrCode,  C.RtrName,C.RtrAdd1,C.RtrAdd2,C.RtrAdd3,C.RtrCrDaysAlert,C.RtrCrBillsAlert,C.RtrCrLimitAlert FROM RetailerSequence A (NOLOCK) INNER JOIN RetailerSeqDetails B(NOLOCK)   ON A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on C.RtrId = B.RtrId Where C.RtrStatus = 1 Union   SELECT 100000 as RtrSeqDtId,D.RtrId,D.RtrCode,D.RtrName,D.RtrAdd1,D.RtrAdd2,D.RtrAdd3,D.RtrCrDaysAlert,D.RtrCrBillsAlert,  D.RtrCrLimitAlert FROM Retailer D (NOLOCK)   INNER JOIN RetailerMarket E (NOLOCK) ON   D.RtrId = E.RtrId Where D.RtrStatus = 1 And D.Rtrid Not In (SELECT C.RtrId   FROM RetailerSequence A (NOLOCK)   INNER JOIN RetailerSeqDetails B (NOLOCK) ON   A.RtrSeqID = B.RtrSeqId INNER JOIN Retailer C (NOLOCK) on C.RtrId = B.RtrId   Where C.RtrStatus = 1)) a  ORDER BY RtrSeqDtId'
GO
Delete from HotsearchEditorDt where Formid = 10050
GO
Insert into HotsearchEditorDt Select 1,10050,'DirectRetailer','SequenceId','RtrSeqDtId',1000,0,'HotSch-1-2000-33',1
Insert into HotsearchEditorDt Select 1,10050,'DirectRetailer','Retailer Code','RtrCode',1750,0,'HotSch-1-2000-31',1
Insert into HotsearchEditorDt Select 2,10050,'DirectRetailer','Retailer Name','RtrName',1750,0,'HotSch-1-2000-32',1
Insert into HotsearchEditorDt Select 3,10050,'DirectRetailer','Retailer Address1','RtrAdd1',1750,0,'HotSch-1-2000-187',1
Insert into HotsearchEditorDt Select 4,10050,'DirectRetailer','Retailer Address2','RtrAdd2',1750,0,'HotSch-1-2000-188',1
Insert into HotsearchEditorDt Select 5,10050,'DirectRetailer','Retailer Address3','RtrAdd3',1750,0,'HotSch-1-2000-189',1
GO
Delete from Customcaptions Where Transid = 1 And Ctrlid = 2000 And SubCtrlid = 33
GO
Insert into Customcaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values (1,2000,33,'HotSch-1-2000-33','SequenceId','','',1,1,1,GetDate(),1,GetDate(),'SequenceId','','',1,1)
Delete from Customcaptions Where Transid = 1 And Ctrlid = 2000 And SubCtrlid = 31
GO
Insert into Customcaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values (1,2000,31,'HotSch-1-2000-31','Retailer Code','','',1,1,1,GetDate(),1,GetDate(),'Retailer Code','','',1,1)
GO
Delete from Customcaptions Where Transid = 1 And Ctrlid = 2000 And SubCtrlid = 32
GO
Insert into Customcaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
Values (1,2000,32,'HotSch-1-2000-32','Retailer Name','','',1,1,1,GetDate(),1,GetDate(),'Retailer Name','','',1,1)
GO

--Function for Order Booking
IF EXISTS (SELECT * FROM sysobjects WHERE Xtype in ('TF','FN') And Name = 'Fn_DirectRetailerSelection')
DROP FUNCTION Fn_DirectRetailerSelection
GO
CREATE FUNCTION [dbo].[Fn_DirectRetailerSelection](@Pi_Cmpid INT,@Pi_RtrId INT)
Returns @DirectRetailer TABLE
(
SMId Int,
SMName Varchar(50),
RMId Int,
RMName Varchar(50),
Cmpid Int,
CmpName Varchar(50)
)
AS
BEGIN
IF @Pi_Cmpid = 0
Begin
	INSERT INTO @DirectRetailer (SMId,SMName,RMId,RMName,Cmpid,CmpName)
	SELECT DISTINCT S.SMId,S.SMName,RM.RMId,RM.RMName,C.CmpId,C.CmpName From RetailerMarket RRM
	INNER JOIN RouteMaster RM ON RRM.Rmid = RM.Rmid 
	INNER JOIN SalesmanMarket SM ON RM.RMId=SM.RMId
	INNER JOIN SalesMan S ON SM.SMId=S.SmId 
	INNER JOIN Company C ON  S.CmpId = CASE S.CmpId WHEN 0 THEN S.CmpId ELSE C.CmpId END AND 
	RM.CmpId = CASE RM.CmpId WHEN 0 THEN RM.CmpId ELSE C.CmpId END  WHERE RRM.RtrId=@Pi_RtrId
    
End
ELse
Begin
	INSERT INTO @DirectRetailer (SMId,SMName,RMId,RMName,Cmpid,CmpName)
	SELECT DISTINCT S.SMId,S.SMName,RM.RMId,RM.RMName,C.CmpId,C.CmpName From RetailerMarket RRM
	INNER JOIN RouteMaster RM ON RRM.Rmid = RM.Rmid 
	INNER JOIN SalesmanMarket SM ON RM.RMId=SM.RMId
	INNER JOIN SalesMan S ON SM.SMId=S.SmId 
	INNER JOIN Company C ON  S.CmpId = CASE @Pi_Cmpid WHEN 0 THEN S.CmpId ELSE @Pi_Cmpid END AND 
	RM.CmpId = CASE @Pi_Cmpid WHEN 0 THEN RM.CmpId ELSE @Pi_Cmpid END Where C.Cmpid = @Pi_Cmpid AND RRM.Rtrid = @Pi_RtrId 
END
Return
END
GO
--Function Of SalesReturn
IF EXISTS (SELECT * FROM sysobjects WHERE Xtype in('TF','FN') And Name = 'Fn_DirectRetailerSelectionSalesReturn')
DROP FUNCTION Fn_DirectRetailerSelectionSalesReturn
GO
CREATE FUNCTION [dbo].[Fn_DirectRetailerSelectionSalesReturn](@Pi_RtrId INT)
Returns @DirectRetailer TABLE
(
SMId Int,
SMName Varchar(50),
RMId Int,
RMName Varchar(50)
)
AS
BEGIN
	INSERT INTO @DirectRetailer (SMId,SMName,RMId,RMName)
	SELECT DISTINCT S.SMId,S.SMName,RM.RMId,RM.RMName From RetailerMarket RRM
	INNER JOIN RouteMaster RM ON RRM.Rmid = RM.Rmid 
	INNER JOIN SalesmanMarket SM ON RM.RMId=SM.RMId
	INNER JOIN SalesMan S ON SM.SMId=S.SmId 
    WHERE RRM.RtrId=@Pi_RtrId
RETURN
END
GO
Delete From Configuration Where Moduleid = 'BCD14'
GO
Insert into Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) 
Values('BCD14','BillConfig_Display','Display Retailer Based On',1,'Name',1.00,14)
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_CS2Cn_DailySalesValidation' AND xtype='P')
DROP PROCEDURE Proc_CS2Cn_DailySalesValidation
GO
--exec Proc_CS2Cn_DailySalesValidation 0

CREATE PROCEDURE Proc_CS2Cn_DailySalesValidation
(  
 @Po_ErrNo INT OUTPUT  
)  
AS  
SET NOCOUNT ON  
BEGIN  
/*********************************  
* PROCEDURE: Proc_CS2Cn_DailySalesValidation  
* PURPOSE: Check Daily Sales With SchememUtilization
* NOTES:  
* CREATED: karthick 21-11-2011
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/  
DECLARE @salid AS int 
DECLARE @SalInvNo AS varchar(50)
DECLARE @Utilised AS numeric(18,2)
DECLARE @Chksalinvno AS varchar(50)
DECLARE @SalSchid AS int
DECLARE @Schid AS int 
DECLARE @SchemeCode AS varchar(50)
DECLARE @ReturnID AS int
DECLARE @ReturnCode AS varchar(50)
DECLARE @ReturnID1  AS int
DECLARE @RetSchid AS int
DECLARE @RetSchCode AS varchar(50)
DECLARE @RetAmt numeric(18,2)
DECLARE @UtiqTy AS int
DECLARE @InvoiceNio AS varchar(50)
DECLARE @CSalid AS int
	SET @Po_ErrNo=0 
DECLARE Cur_DailySales CURSOR 
FOR SELECT DISTINCT salid,C.SalInvNo FROM Cs2Cn_Prk_DailySales C INNER JOIN salesinvoice SI ON C.SalInvNo=si.SalInvNo -- WHERE si.salinvno='JJG1100002'
OPEN Cur_DailySales
FETCH next FROM Cur_DailySales INTO @salid,@SalInvNo
WHILE @@fetch_status=0
BEGIN
	DECLARE Cur_SchemeUtilized CURSOR
	FOR SELECT DISTINCT si.salid,sh.SchId,SchCode FROM Cs2Cn_Prk_DailySales C INNER JOIN salesinvoice SI ON C.SalInvNo=si.SalInvNo
		INNER JOIN SalesInvoiceSchemeHd SH ON SH.SalId=si.Salid
		INNER JOIN SchemeMaster SM ON SM.SchId = SH.SchId WHERE si.salid =@salid
	OPEN Cur_SchemeUtilized
	FETCH next FROM Cur_SchemeUtilized INTO @SalSchid,@Schid,@SchemeCode
	WHILE @@fetch_status=0
	BEGIN
		IF EXISTS (SELECT * FROM SalesInvoiceSchemeLineWise WHERE SalId=@salid AND SchId=@Schid)
		BEGIN
				SELECT @Utilised=Utilized,@Chksalinvno=SalInvNo FROM (
				SELECT (ISNULL(SUM(FlatAmount),0) + ISNULL(SUM(DiscountPerAmount),0)) As Utilized,A.SalId,SalInvNo FROM SalesInvoiceSchemeLineWise A 
					INNER JOIN SalesInvoice SI ON SI.SalId = A.SalId WHERE A.SalId=@salid AND SchId=@Schid
				 GROUP BY A.SalId,SalInvNo)	A

				IF NOT EXISTS (SELECT * FROM Cs2Cn_Prk_SchemeUtilization WHERE InvoiceNo=@Chksalinvno AND SchemeUtilizedAmt=@Utilised AND SchemeCode=@SchemeCode)
				BEGIN
					UPDATE SalesInvoice SET SchemeUpLoad=0 ,UPload=0 WHERE SalId=@salid
					UPDATE Cs2Cn_Prk_DailySales SET UploadFlag='X'  WHERE SalInvNo=@SalInvNo
				END 
		END 

		IF EXISTS (SELECT * FROM SalesInvoiceSchemeDtFreePrd WHERE SalId=@salid AND SchId=@Schid )
				BEGIN
					SELECT @Utilised=Utilized,@Chksalinvno=salinvno,@UtiqTy=SchemeUtilizedQty FROM (SELECT SUM(FreeQty) AS SchemeUtilizedQty,ISNULL(SUM(FreeQty * D.PrdBatDetailValue),0) As Utilized,A.SalId,salinvno FROM SalesInvoiceSchemeDtFreePrd A 
						  INNER JOIN SalesInvoice SI ON  SI.salid=A.salid
						  INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND A.FreePrdBatId = C.PrdBatId   
						  INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId   
						  INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1  
						  WHERE A.SalId=@salid AND A.SchId=@Schid GROUP BY A.SalId,salinvno)A

						IF NOT EXISTS (SELECT * FROM Cs2Cn_Prk_SchemeUtilization WHERE InvoiceNo=@Chksalinvno AND SchemeUtilizedAmt=@Utilised AND SchemeCode=@SchemeCode)
						BEGIN
							UPDATE SalesInvoice SET SchemeUpLoad=0 ,UPload=0 WHERE SalId=@salid
							UPDATE Cs2Cn_Prk_DailySales SET UploadFlag='X' WHERE SalInvNo=@SalInvNo
						END 
				END 

		IF EXISTS (SELECT * FROM SalesInvoiceSchemeDtFreePrd WHERE SalId=@salid AND SchId=@Schid )
			BEGIN
				 SELECT @Utilised=Utilized,@Chksalinvno=salinvno,@UtiqTy=SchemeUtilizedQty FROM  (SELECT SUM(FreeQty) AS SchemeUtilizedQty, ISNULL(SUM(GiftQty * D.PrdBatDetailValue),0) As Utilized,A.SalId,SalInvNo  FROM SalesInvoiceSchemeDtFreePrd A   
				  INNER JOIN SalesInvoice SI ON  SI.salid=A.salid
				  INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND A.GiftPrdBatId = C.PrdBatId   
				  INNER JOIN ProductBatchDetails D (NOLOCK) ON C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId   
				  INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1  
				  WHERE A.SalId=@salid AND A.SchId=@Schid GROUP BY A.salid,SalInvNo)A

						IF NOT EXISTS (SELECT * FROM Cs2Cn_Prk_SchemeUtilization WHERE InvoiceNo=@Chksalinvno AND SchemeUtilizedAmt=@Utilised AND SchemeCode=@SchemeCode)
						BEGIN
							UPDATE SalesInvoice SET SchemeUpLoad=0,UPload=0 WHERE SalId=@salid
							UPDATE Cs2Cn_Prk_DailySales SET UploadFlag='X' WHERE SalInvNo=@SalInvNo
						END 
			END 
				 
		 IF EXISTS (SELECT * FROM SalesInvoiceWindowDisplay WHERE SalId=@salid AND SchId=@Schid)
             BEGIN
				  SELECT @Utilised=Utilized,@Chksalinvno=salinvno FROM (SELECT ISNULL(SUM(AdjAmt),0) As Utilized,A.SalId,SalInvNo FROM SalesInvoiceWindowDisplay A
				  INNER JOIN SalesInvoice SI ON  SI.salid=A.salid WHERE A.SalId=@salid AND A.SchId=@Schid
				   GROUP BY A.SalId,SalInvNo)A

						IF NOT EXISTS (SELECT * FROM Cs2Cn_Prk_SchemeUtilization WHERE InvoiceNo=@Chksalinvno AND SchemeUtilizedAmt=@Utilised AND SchemeCode=@SchemeCode)
						BEGIN
							UPDATE SalesInvoice SET SchemeUpLoad=0,UPload=0 WHERE SalId=@salid
							UPDATE Cs2Cn_Prk_DailySales SET UploadFlag='X'  WHERE SalInvNo=@SalInvNo
						END 
			 END 

		IF EXISTS (SELECT *  FROM SalesInvoiceQPSSchemeAdj WHERE SalId=@salid AND SchId=@Schid)
				BEGIN
					SELECT @Utilised=Utilized,@Chksalinvno=salinvno FROM (SELECT ISNULL(SUM(A.CrNoteAmount),0) As Utilized,A.SalId,SalInvNo  
						FROM SalesInvoiceQPSSchemeAdj A INNER JOIN SalesInvoice SI ON  SI.salid=A.salid AND SchId=@Schid GROUP BY A.SalId,SalInvNo)A

						IF NOT EXISTS (SELECT * FROM Cs2Cn_Prk_SchemeUtilization WHERE InvoiceNo=@Chksalinvno AND SchemeUtilizedAmt=@Utilised AND SchemeCode=@SchemeCode)
						BEGIN
							UPDATE SalesInvoice SET SchemeUpLoad=0,UPload=0 WHERE SalId=@salid
							UPDATE SalesInvoiceQPSSchemeAdj  SET Upload=0 WHERE SalId=@salid AND SchId=@Schid
							UPDATE Cs2Cn_Prk_DailySales SET UploadFlag='X' WHERE SalInvNo=@SalInvNo

						END 
			END 

		FETCH next FROM Cur_SchemeUtilized INTO @SalSchid,@Schid,@SchemeCode
		END 
		CLOSE Cur_SchemeUtilized
		DEALLOCATE Cur_SchemeUtilized

FETCH next FROM Cur_DailySales INTO @salid,@SalInvNo
END 
CLOSE Cur_DailySales
DEALLOCATE Cur_DailySales

---check Return
	DECLARE Cur_ReturnData CURSOR 
	FOR SELECT ReturnID,RH.ReturnCode FROM Cs2Cn_Prk_SalesReturn C INNER JOIN ReturnHeader RH ON c.SRNRefNo=RH.ReturnCode
	OPEN Cur_ReturnData
	FETCH next FROM Cur_ReturnData INTO @ReturnID,@ReturnCode
	WHILE @@fetch_status=0
	BEGIN
			DECLARE Cur_ReturnSchemeData CURSOR 
			FOR SELECT DISTINCT  ReturnId,SchId,schcode FROM (SELECT ReturnId,R.SchId,SM.SchCode FROM ReturnSchemeFreePrdDt R INNER JOIN SchemeMaster SM ON SM.SchId = R.SchId 
				 WHERE ReturnId=@ReturnID
				UNION ALL SELECT ReturnId,R.SchId,SchCode FROM ReturnSchemeLineDt R INNER JOIN SchemeMaster SM ON SM.SchId = R.SchId WHERE ReturnId=@ReturnID)A
			OPEN Cur_ReturnSchemeData
			FETCH next FROM Cur_ReturnSchemeData INTO @ReturnID1,@RetSchid,@RetSchCode
			WHILE @@fetch_status=0
			BEGIN

		IF EXISTS (SELECT * FROM ReturnSchemeLineDt	WHERE ReturnID=@ReturnID AND SchId=@RetSchid)										
				BEGIN
					SELECT @RetAmt=RetAmt FROM (SELECT -1 * (ISNULL(SUM(ReturnFlatAmount),0) + ISNULL(SUM(ReturnDiscountPerAmount),0))RetAmt,ReturnID 
												 FROM ReturnSchemeLineDt WHERE  ReturnID=@ReturnID AND SchId=@RetSchid GROUP BY ReturnSchemeLineDt.ReturnID)A

					IF NOT EXISTS (SELECT * FROM Cs2Cn_Prk_SchemeUtilization WHERE SchemeCode=@RetSchCode AND InvoiceNo=@ReturnCode AND SchemeUtilizedAmt=@RetAmt)
						BEGIN
							UPDATE ReturnHeader SET UpLoad=0,SchemeUpLoad=0 WHERE ReturnID=@ReturnID
							UPDATE Cs2Cn_Prk_SalesReturn SET UploadFlag='X'	WHERE SRNRefNo=@ReturnCode
						END 
								
				END 
	
		IF EXISTS (SELECT * FROM ReturnSchemeFreePrdDt WHERE ReturnID=@ReturnID AND SchId=@RetSchid)
				BEGIN
					 SELECT @RetAmt=SchemeUtilizedQty FROM (sELECT -1 * SUM(ReturnFreeQty) as SchemeUtilizedQty,ReturnId FROM ReturnSchemeFreePrdDt
					 WHERE ReturnID=@ReturnID AND SchId=@RetSchid GROUP BY ReturnId)A

						IF NOT EXISTS (SELECT * FROM Cs2Cn_Prk_SchemeUtilization WHERE SchemeCode=@RetSchCode AND InvoiceNo=@ReturnCode AND SchemeUtilizedQty=@RetAmt)
							BEGIN
								UPDATE ReturnHeader SET UpLoad=0,SchemeUpLoad=0 WHERE ReturnID=@ReturnID
								UPDATE Cs2Cn_Prk_SalesReturn SET UploadFlag='X'	WHERE SRNRefNo=@ReturnCode
							END 
				END 

		IF EXISTS (SELECT * FROM ReturnSchemeFreePrdDt WHERE ReturnID=@ReturnID AND SchId=@RetSchid)
				BEGIN
					 SELECT @RetAmt=SchemeUtilizedQty FROM (sELECT -1 * SUM(ReturnGiftQty) as SchemeUtilizedQty,ReturnId FROM ReturnSchemeFreePrdDt
					 WHERE ReturnID=@ReturnID AND SchId=@RetSchid GROUP BY ReturnId)A

						IF NOT EXISTS (SELECT * FROM Cs2Cn_Prk_SchemeUtilization WHERE SchemeCode=@RetSchCode AND InvoiceNo=@ReturnCode AND SchemeUtilizedQty=@RetAmt)
							BEGIN
								UPDATE ReturnHeader SET UpLoad=0,SchemeUpLoad=0 WHERE ReturnID=@ReturnID
								UPDATE Cs2Cn_Prk_SalesReturn SET UploadFlag='X'	WHERE SRNRefNo=@ReturnCode
							END 
				END 
		
			FETCH next FROM Cur_ReturnSchemeData INTO @ReturnID1,@RetSchid,@RetSchCode
			END 
			CLOSE Cur_ReturnSchemeData
			DEALLOCATE Cur_ReturnSchemeData

	FETCH next FROM Cur_ReturnData INTO @ReturnID,@ReturnCode
	END 
	CLOSE Cur_ReturnData
	DEALLOCATE Cur_ReturnData


DECLARE Cur_Schemecheck CURSOR
FOR 
SELECT  InvoiceNo,SalId FROM (
SELECT DISTINCT InvoiceNo,SalId FROM Cs2Cn_Prk_SchemeUtilization C INNER JOIN salesinvoice SI ON C.InvoiceNo=si.salinvno 
UNION ALL
 SELECT DISTINCT InvoiceNo,ReturnID AS salid FROM Cs2Cn_Prk_SchemeUtilization C INNER JOIN ReturnHeader RH ON RH.ReturnCode=InvoiceNo)A
OPEN Cur_Schemecheck
FETCH next FROM Cur_Schemecheck INTO @InvoiceNio,@CSalid
WHILE @@FETCH_status=0
BEGIN

	--Check Scheme against Sales
	IF NOT EXISTS (SELECT * FROM Cs2Cn_Prk_DailySales WHERE SalInvNo=@InvoiceNio)
		BEGIN 
			UPDATE Cs2Cn_Prk_SchemeUtilization SET UploadFlag='X' WHERE InvoiceNo=@InvoiceNio
			UPDATE SalesInvoiceQPSSchemeAdj SET Upload =0 WHERE SalId=@CSalid
			UPDATE SalesInvoice SET Upload=0,SchemeUpLoad=0 WHERE SalId=@CSalid AND salinvno=@InvoiceNio
		END 

	--Check Scheme against Return
	IF EXISTS (SELECT * FROM ReturnHeader WHERE ReturnCode  =@InvoiceNio)
	BEGIN
		IF NOT EXISTS (SELECT * FROM Cs2Cn_Prk_SalesReturn WHERE SRNRefNo=@InvoiceNio)
		  BEGIN  
				UPDATE ReturnHeader SET UpLoad=0,SchemeUpLoad=0 WHERE ReturnCode=@InvoiceNio
				UPDATE Cs2Cn_Prk_SchemeUtilization SET UploadFlag='X' WHERE InvoiceNo=@InvoiceNio			
		  END 
	END 

FETCH next FROM Cur_Schemecheck INTO @InvoiceNio,@CSalid
END
CLOSE Cur_Schemecheck 
DEALLOCATE Cur_Schemecheck 
END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE NAME='RptSalavageAll_Excel' AND type in (N'U'))
DROP TABLE [dbo].[RptSalavageAll_Excel]
GO
CREATE TABLE [dbo].[RptSalavageAll_Excel](
	[Reference Number] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Salvage Date] [datetime] NULL,
	[LocationId] [int] NULL,
	[Location Name] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DocRefNo] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Code] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Name] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Product Batch Code] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Qty] [numeric](38, 0) NULL,
	[Rate] [numeric](38, 6) NULL,
	[Amount] [numeric](38, 6) NULL,
	[Amount For Claim] [numeric](38, 6) NULL,
	[StkTypeId] [int] NULL,
	[StkType] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReasonId] [int] NULL,
	[Reason] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
DELETE FROM RptExcelHeaders WHERE RptId=21
INSERT INTO RptExcelHeaders SELECT 21,1,'Reference Number','Ref. Number',1,1
INSERT INTO RptExcelHeaders SELECT 21,2,'Salvage Date','Date',1,1
INSERT INTO RptExcelHeaders SELECT 21,3,'LocationId','LocationId',0,1
INSERT INTO RptExcelHeaders SELECT 21,4,'Location Name','Location Name',1,1
INSERT INTO RptExcelHeaders SELECT 21,5,'DocRefNo','DocRefNo',0,1
INSERT INTO RptExcelHeaders SELECT 21,6,'Product Code','Product Code',1,1
INSERT INTO RptExcelHeaders SELECT 21,7,'Product Name','Product Name',1,1
INSERT INTO RptExcelHeaders SELECT 21,8,'Product Batch Code','Product Batch Code',1,1
INSERT INTO RptExcelHeaders SELECT 21,9,'Qty','Salvage Qty',1,1
INSERT INTO RptExcelHeaders SELECT 21,10,'Rate','Rate',1,1
INSERT INTO RptExcelHeaders SELECT 21,11,'Amount','Amount',1,1
INSERT INTO RptExcelHeaders SELECT 21,12,'Amount For Claim','Amount For Claim',1,1
INSERT INTO RptExcelHeaders SELECT 21,13,'StkTypeId','StkTypeId',0,1
INSERT INTO RptExcelHeaders SELECT 21,14,'StkType','StkType',1,1
INSERT INTO RptExcelHeaders SELECT 21,15,'ReasonId','ReasonId',0,1
INSERT INTO RptExcelHeaders SELECT 21,16,'Reason','Reason',1,1
INSERT INTO RptExcelHeaders SELECT 21,17,'Uom1','Cases',0,1
INSERT INTO RptExcelHeaders SELECT 21,18,'Uom2','Boxes',0,1
INSERT INTO RptExcelHeaders SELECT 21,19,'Uom3','Strips',0,1
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='CS2CN_Prk_TransactionWiseSerialNo' AND XTYPE='U')
DROP TABLE CS2CN_Prk_TransactionWiseSerialNo
GO
CREATE TABLE CS2CN_Prk_TransactionWiseSerialNo
(
	[Slno] [bigint] IDENTITY(1,1) NOT NULL,
	[DistCode] [varchar](50) NULL,
	[ProcessName] [varchar](50) NULL,
	[SerialNo] [numeric](38, 0) NULL,
	[TransRefId] [numeric](38, 0) NULL,
	[TransCode] [varchar](50) NULL,
	[AttrValue1] [varchar](50) NULL,
	[AttrValue2] [varchar](50) NULL,
	[AttrValue3] [varchar](50) NULL,
	[AttrValue4] [varchar](50) NULL,
	[AttrValue5] [varchar](50) NULL,
	[AttrValue6] [varchar](50) NULL,
	[AttrValue7] [varchar](50) NULL,
	[AttrValue8] [varchar](50) NULL,
	[AttrValue9] [varchar](50) NULL,
	[AttrValue10] [varchar](50) NULL,
	[UploadFlag] [varchar](1) NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='CS2CN_Prk_TransactionWiseSerialNo_Archive' AND XTYPE='U')
DROP TABLE CS2CN_Prk_TransactionWiseSerialNo_Archive
GO
CREATE TABLE CS2CN_Prk_TransactionWiseSerialNo_Archive
(
	[Slno] [bigint]  NULL,
	[DistCode] [varchar](50)  NULL,
	[ProcessName] [varchar](50)  NULL,
	[SerialNo] [numeric](38, 0) NULL,
	[TransRefId] [numeric](38, 0) NULL,
	[TransCode] [varchar](50)  NULL,
	[AttrValue1] [varchar](50)  NULL,
	[AttrValue2] [varchar](50)  NULL,
	[AttrValue3] [varchar](50)  NULL,
	[AttrValue4] [varchar](50)  NULL,
	[AttrValue5] [varchar](50)  NULL,
	[AttrValue6] [varchar](50)  NULL,
	[AttrValue7] [varchar](50)  NULL,
	[AttrValue8] [varchar](50)  NULL,
	[AttrValue9] [varchar](50)  NULL,
	[AttrValue10] [varchar](50)  NULL,
	[UploadFlag] [varchar](1)  NULL,
	[UploadedDate] [datetime] NULL
) 
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Cs2Cn_Prk_Dummy_Archive' AND XTYPE='U')
DROP TABLE CS2CN_PRK_DUMMY_Archive
GO
CREATE TABLE Cs2Cn_Prk_Dummy_Archive
(
Slno int,
UploadFlag varchar(1),
[UploadedDate] [datetime] 
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='CS2CN_PRK_DUMMY' AND XTYPE='U')
DROP TABLE CS2CN_PRK_DUMMY
GO
CREATE TABLE Cs2Cn_Prk_Dummy
(
Slno int,
UploadFlag varchar(1)

)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_CS2CN_TranSactionWsSerialNo' AND XTYPE='P')
DROP PROCEDURE Proc_CS2CN_TranSactionWsSerialNo
GO
--exec Proc_CS2CN_TranSactionWsSerialNo 0
CREATE PROCEDURE Proc_CS2CN_TranSactionWsSerialNo
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_CS2CN_TranSactionWsSerialNo
* PURPOSE:Export Transaction Wise Serial No
* NOTES:
* CREATED: KARTHICK.K.J
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN 
	SET @Po_ErrNo=0
	DECLARE @DistCode AS NVARCHAR(50)
	DELETE FROM CS2CN_Prk_TransactionWiseSerialNo WHERE UploadFlag = 'Y'
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO CS2CN_Prk_TransactionWiseSerialNo
	(
		DistCode,ProcessName,SerialNo,TransRefId,TransCode,AttrValue1,AttrValue2,AttrValue3,
		AttrValue4,AttrValue5,AttrValue6,AttrValue7,AttrValue8,AttrValue9,AttrValue10,UploadFlag
	)
	SELECT @DistCode,'Billing',serialNo,salid,invoiceno,'','','','','','','','','','','N' FROM TranSactionWsSerailNo
	WHERE uploadflag='N'

update TranSactionWsSerailNo set uploadflag='Y' where uploadflag='N'
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype in ('TF','FN') And Name = 'Fn_OrderSelection') 
DROP FUNCTION Fn_OrderSelection
GO
CREATE FUNCTION [dbo].[Fn_OrderSelection](@Pi_OrderNo VARCHAR(100))
Returns @OrderSelection TABLE
(
	PrdId		BIGINT,
	PrdDCode	VARCHAR(100),
	PrdName		VARCHAR(200),
	PrdBatId	BIGINT,
	PrdBatCode	VARCHAR(100),
	BaseQty		NUMERIC(38,0), 
	UOMId1		INT,
	UomCode1	VARCHAR(100),
	Qty1		NUMERIC(38,0),
	ConvFact1	NUMERIC(38,0), 
	UOMId2		INT,
	UomCode2	VARCHAR(100),
	Qty2		NUMERIC(38,0),
	ConvFact2	NUMERIC(38,0),
	PriceId		BIGINT,
	MRP			NUMERIC(38,6),
	SellRate	NUMERIC(38,6)
)
AS
BEGIN
	INSERT INTO @OrderSelection
	SELECT X.PrdId,X.PrdDCode,X.PrdName,X.PrdBatId,X.PrdBatCode,X.BaseQty,X.UOMId1,X.UomCode1,X.Qty1,X.ConvFact1,X.UOMId2,
	X.UomCode2,X.Qty2,X.ConvFact2,Y.PriceId,Y.MRP,Y.SellRate FROM 
	(
		SELECT ORB.PrdId,P.PrdDCode,P.PrdName,ORB.PrdBatId,PB.PrdBatCode,SUM(ORB.TotalQty - ISNULL(ORB.BilledQty,0)) AS BaseQty,
		ORB.UOMId1,ISNULL(UM1.UomCode,'') AS UomCode1,
		CASE AllowBackOrder WHEN 1 THEN SUM(ORB.TotalQty - ISNULL(ORB.BilledQty,0)) ELSE SUM(ORB.Qty1) END AS Qty1,ORB.ConvFact1,ORB.UOMId2,ISNULL(UM2.UomCode,'') AS UomCode2,
		CASE AllowBackOrder WHEN 0 THEN SUM(ORB.Qty2) ELSE 0 END AS Qty2,ORB.ConvFact2,ORB.PriceId 
		FROM OrderBookingProducts ORB (NOLOCK) INNER JOIN Product P (NOLOCK) ON ORB.PrdId=P.PrdId 
		INNER JOIN OrderBooking OB ON ORB.OrderNo=OB.OrderNo
		INNER JOIN  ProductBatch  PB (NOLOCK) ON ORB.PrdBatId=PB.PrdBatId AND P.PrdId = PB.PrdId 
		LEFT OUTER JOIN UOMMaster UM1 (NOLOCK) ON UM1.UOMId=ORB.UOMId1 
		LEFT OUTER JOIN UOMMaster UM2 (NOLOCK) ON UM2.UOMId=ORB.UOMId2
		WHERE ORB.OrderNo =@Pi_OrderNo   GROUP BY ORB.PrdId,P.PrdDCode,P.PrdName,ORB.PrdBatId,PB.PrdBatCode,ORB.UOMId1,
		ORB.UOMId2,UM1.UomCode,UM2.UomCode,ORB.ConvFact1,ORB.ConvFact2,AllowBackOrder,PriceId
	) X,
	(
		SELECT A.PrdId,B.PrdBatId,B.PriceId,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS SellRate 
		FROM ProductBatch A (NOLOCK) INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 
		INNER JOIN BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1 
		INNER JOIN ProductBatchDetails D (NOLOCK)  ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 
		INNER JOIN BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.SelRte = 1
	) Y
	WHERE X.PrdId=Y.PrdId AND X.PrdBatId=Y.PrdBatId AND X.PriceId=Y.PriceId AND  X.BaseQty > 0 ORDER BY X.PrdId,X.PrdBatId


RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='RptSampleIssue_Excel')
DROP TABLE RptSampleIssue_Excel
GO
CREATE TABLE [dbo].[RptSampleIssue_Excel](
	[RtrCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrShipAddress] [varchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IssueRefNo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IssueDate] [datetime] NULL,
	[BillRefNo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemeCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdDCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SKUName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MRP] [numeric](18, 6) NULL,
	[UOM] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Qty] [int] NULL,
	[Status] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Returnable] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DueDate] [datetime] NULL,
	[PrdId] [int] NULL,
	[UserId] [int] NULL
) ON [PRIMARY]
GO
IF EXISTS (SELECT * FROM SysObjects WHERE Xtype='U' AND [Name]='TempSampleIssue')
DROP TABLE TempSampleIssue
GO
CREATE TABLE [dbo].[TempSampleIssue](
	[IssueId] [int] NULL,
	[IssueRefNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CmpId] [int] NULL,
	[SMId] [int] NULL,
	[RMId] [int] NULL,
	[CtgLevelId] [int] NULL,
	[RtrClassId] [int] NULL,
	[CtgMainID] [int] NULL,
	[RtrId] [int] NULL,
	[RtrCode] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IssueDate] [datetime] NULL,
	[SalId] [int] NULL,
	[SalInvNo] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchId] [int] NULL,
	[SchCode] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SKUPrdId] [int] NULL,
	[SKUName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UomId] [int] NULL,
	[UomCode] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UomQty] [numeric](38, 0) NULL,
	[UomConvFact] [int] NULL,
	[UomBaseQty] [numeric](38, 0) NULL,
	[IssueStatus] [int] NULL,
	[DlvSts] [int] NULL,
	[DlvStsDesc] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Returnable] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DueDate] [datetime] NULL,
	[RptID] [int] NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO
Delete from  RptGroup where rptid=233
GO
Insert Into RptGroup(PId,RptId,GrpCode,GrpName) Values('DailyReports',	233,	'SampleIssueReport',	'Sample Issue Report')
GO
Delete from Rptdetails where rptid=233
GO
Insert into Rptdetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
SELECT 233,1,'FromDate',-1,'NULL','','From Date*','',1,'',10,0,0,'Enter From Date',0 UNION ALL
SELECT 233,2,'ToDate',-1,'NULL','','To Date*','',1,'',11,0,0,'Enter To Date',0 UNION ALL
SELECT 233,3,'Company',-1,'NULL','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,0,'Press F4/Double Click to select Company',0 UNION ALL
SELECT 233,4,'Salesman',-1,'NULL','SMId,SMCode,SMName','Salesman...','',1,'',1,0,0,'Press F4/Double Click to select Salesman',0 UNION ALL
SELECT 233,5,'RouteMaster',-1,'NULL','RMId,RMCode,RMName','Route...','',1,'',2,0,0,'Press F4/Double Click to select Route',0 UNION ALL
SELECT 233,6,'RetailerCategoryLevel',3,'CmpId','CtgLevelId,CtgLevelName,CtgLevelName','Retailer Category Level...','Company',1,'CmpId',29,1,0,'Press F4/Double Click to select Category Level',1 UNION ALL
SELECT 233,7,'RetailerCategory',6,'CtgLevelID','CtgMainId,CtgCode,CtgName','Retailer Category Level Value...','RetailerCategoryLevel',1,'CtgLevelId',30,1,0,'Press F4/Double Click to select Category Level Value',1 UNION ALL
SELECT 233,8,'RetailerValueClass',7,'CtgMainID','RtrClassID,ValueClassCode,ValueClassName','Retailer Value Classification...','RetailerCategory',1,'CtgMainId',31,1,0,'Press F4/Double Click to select Value Classification',1 UNION ALL
SELECT 233,9,'Retailer',-1,'NULL','RtrID,RtrCode,RtrName','Retailer...','',1,'',3,0,0,'Press F4/Double Click to select Retailer',0 UNION ALL
SELECT 233,10,'FreeIssueHd',-1,'NULL','IssueId,IssueRefNo,IssueRefNo','Sample Issue Ref No...','',1,'',220,0,0,'Press F4/Double click to select Sample Issue Ref No',0 UNION ALL
SELECT 233,11,'SalesInvoice',-1,'NULL','SalId,SalInvNo,SalInvNo','Bill Reference Number...','',1,'',34,0,0,'Press F4/Double Click to select Bill Reference Number',0 UNION ALL
--SELECT 233,12,'RptFilter',-1,'NULL','FilterId,FilterId,FilterDesc','Sample Issue Status...','',1,'',275,1,0,'Press F4/Double Click to select Sample Issue Status',0 UNION ALL
SELECT 233,12,'ProductCategoryLevel',3,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,0,'Press F4/Double Click to select Product Hierarchy Level',0 UNION ALL
SELECT 233,13,'ProductCategoryValue',13,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,0,0,'Press F4/Double Click to select Product Hierarchy Level Value',0 UNION ALL
SELECT 233,14,'Product',-1,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,0,0,'Press F4/Double Click to select Product',0 UNION ALL
--SELECT 233,16,'ReasonMaster',-1,'NULL','ReasonId,Description,Description','Reason...','',1,'',159,0,0,'Press F4/Double Click to Select Reason',0 UNION ALL
SELECT 233,15,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Based On *...','',1,'',276,1,1,'Press F4/Double Click to Select Report Based on',0
GO
delete from Rptheader where rptid=233
GO
--select * from rptheader where rptid=233
Insert Into rptheader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
Values('SampleIssueReport',	'Sample Issue Report',	233,	'Sample Issue Report',	'Proc_RptSampleIssue',	'RptSampleIssue',	'RptSampleIssue.rpt',	'NULL')
GO
delete from rptformula where rptid=233
GO
--select * from rptformula where rptid=233
DELETE FROM RptFormula WHERE RptId=233
INSERT INTO RptFormula  SELECT 233,1,'Disp_FromDate','From Date',1,0
INSERT INTO RptFormula  SELECT 233,2,'Fill_FromDate','FromDate',1,10
INSERT INTO RptFormula  SELECT 233,3,'Disp_ToDate','To Date',1,0
INSERT INTO RptFormula  SELECT 233,4,'Fill_ToDate','ToDate',1,11
INSERT INTO RptFormula  SELECT 233,5,'Disp_Company','Company',1,0
INSERT INTO RptFormula  SELECT 233,6,'Fill_Company','Company',1,4
INSERT INTO RptFormula  SELECT 233,7,'Disp_Salesman','Salesman',1,0
INSERT INTO RptFormula  SELECT 233,8,'Fill_Salesman','Salesman',1,1
INSERT INTO RptFormula  SELECT 233,9,'Disp_Route','Route',1,0
INSERT INTO RptFormula  SELECT 233,10,'Fill_Route','Route',1,2
INSERT INTO RptFormula  SELECT 233,11,'Disp_RetailerCategoryLevel','Salon Category Level',1,0
INSERT INTO RptFormula  SELECT 233,12,'Fill_CategoryLevel','ProductCategoryLevel',1,29
INSERT INTO RptFormula  SELECT 233,13,'Disp_RetailerCategory','Salon Category Level Value',1,0
INSERT INTO RptFormula  SELECT 233,14,'Fill_CategoryValue','ProductCategoryLevelValue',1,30
INSERT INTO RptFormula  SELECT 233,15,'Disp_RetailerValueClass','Salon Value Classification',1,0
INSERT INTO RptFormula  SELECT 233,16,'Fill_RetailerValueClass','Value Classification',1,31
INSERT INTO RptFormula  SELECT 233,17,'Disp_IssueRefNo','Sample Issue Ref.Number',1,0
INSERT INTO RptFormula  SELECT 233,18,'Fill_IssueRefNo','Sample Issue Ref.Number',1,216
INSERT INTO RptFormula  SELECT 233,19,'Disp_BillRefNo','Bill Reference Number',1,0
INSERT INTO RptFormula  SELECT 233,20,'Fill_BillRefNo','Bill Reference Number',1,34
INSERT INTO RptFormula  SELECT 233,21,'Disp_IssueStatus','Sample Issue Status',1,0
INSERT INTO RptFormula  SELECT 233,22,'Fill_IssueStatus','Sample Issue Status',1,275
INSERT INTO RptFormula  SELECT 233,23,'Disp_RtrCode','Salon Code',1,0
INSERT INTO RptFormula  SELECT 233,24,'Disp_RetailerName','Salon Name',1,0
INSERT INTO RptFormula  SELECT 233,25,'Disp_SampleIssueRefNo','Sample Issue Ref. Number',1,0
INSERT INTO RptFormula  SELECT 233,26,'Disp_Date','Issue Date',1,0
INSERT INTO RptFormula  SELECT 233,27,'Disp_BillNo','Bill Ref.No',1,0
INSERT INTO RptFormula  SELECT 233,28,'Disp_SampleScheme','Sample Scheme',1,0
INSERT INTO RptFormula  SELECT 233,29,'Disp_SampleSKU','Sample SKU',1,0
INSERT INTO RptFormula  SELECT 233,30,'Disp_IssueQty','Issue Quantity',1,0
INSERT INTO RptFormula  SELECT 233,31,'Disp_UOM','UOM',1,0
INSERT INTO RptFormula  SELECT 233,32,'Disp_Qty','Qty',1,0
--INSERT INTO RptFormula  SELECT 233,33,'Disp_Status','Status',1,0
INSERT INTO RptFormula  SELECT 233,33,'Disp_Returnable','Returnable',1,0
INSERT INTO RptFormula  SELECT 233,34,'Disp_DueDate','Due Date',1,0
INSERT INTO RptFormula  SELECT 233,35,'Cap Page','Page',1,0
INSERT INTO RptFormula  SELECT 233,36,'Cap User Name','User Name',1,0
INSERT INTO RptFormula  SELECT 233,37,'Cap Print Date','Date',1,0
INSERT INTO RptFormula  SELECT 233,38,'Disp_Retailer','Salon',1,0
INSERT INTO RptFormula  SELECT 233,39,'Fill_Retailer','Salon',1,3
INSERT INTO RptFormula  SELECT 233,40,'Disp_Code','Product Code',1,0
INSERT INTO RptFormula  SELECT 233,41,'Disp_MRP','MRP',1,0
--INSERT INTO RptFormula  SELECT 233,43,'Disp_Reason','Reason',1,0
INSERT INTO RptFormula  SELECT 233,42,'Disp_ProductCategoryLevel','Product Category Level',1,0
INSERT INTO RptFormula  SELECT 233,43,'Disp_ProductCategoryValue','Product Category Level Value',1,0
INSERT INTO RptFormula  SELECT 233,44,'Disp_Product','Product',1,0
INSERT INTO RptFormula  SELECT 233,45,'Fill_ProductCategoryLevel','ProductCategoryLevel',1,16
INSERT INTO RptFormula  SELECT 233,46,'Fill_ProductCategoryValue','ProductCategoryLevelValue',1,21
INSERT INTO RptFormula  SELECT 233,47,'Fill_Product','Product',1,5
INSERT INTO RptFormula  SELECT 233,48,'Disp_ReasonHd','Reason',1,0
INSERT INTO RptFormula  SELECT 233,49,'Fill_ReasonHd','Reason',1,159
INSERT INTO RptFormula  SELECT 233,50,'Disp_BasedOn','Based On',1,0
INSERT INTO RptFormula  SELECT 233,51,'Fill_BasedOn','Based On',1,276
GO
Delete From RptFilter where RptId=233
GO
--INSERT INTO RptFilter SELECT 233,275,0,'ALL'
--INSERT INTO RptFilter SELECT 233,275,1,'Pending'
--INSERT INTO RptFilter SELECT 233,275,4,'Confirmed'
--INSERT INTO RptFilter SELECT 233,275,3,'Deleted'
INSERT INTO RptFilter SELECT 233,276,1,'Distributor Code'
INSERT INTO RptFilter SELECT 233,276,2,'Company Code'
GO
Delete from RptExcelHeaders where Rptid=233
GO
INSERT INTO RptExcelHeaders SELECT 233,1,'RtrCode','Salon Code',1,1
INSERT INTO RptExcelHeaders SELECT 233,2,'RtrName','Salon Name',1,1
INSERT INTO RptExcelHeaders SELECT 233,3,'IssueRefNo','IssueRef.No',1,1
INSERT INTO RptExcelHeaders SELECT 233,4,'IssueDate','Issue Date',1,1
INSERT INTO RptExcelHeaders SELECT 233,5,'BillRefNo','Bill Ref.No',0,1
INSERT INTO RptExcelHeaders SELECT 233,6,'SchemeCode','Sample Scheme Code',0,1
INSERT INTO RptExcelHeaders SELECT 233,7,'PrdDCode','Product Code',1,1
INSERT INTO RptExcelHeaders SELECT 233,8,'SKUName','SKU Name',1,1
INSERT INTO RptExcelHeaders SELECT 233,9,'MRP','MRP',1,1
INSERT INTO RptExcelHeaders SELECT 233,10,'UOM','UOM',1,1
INSERT INTO RptExcelHeaders SELECT 233,11,'Qty','Quantity',1,1
--INSERT INTO RptExcelHeaders SELECT 233,12,'Status','Status',1,1
INSERT INTO RptExcelHeaders SELECT 233,13,'Returnable','Returnable',1,1
INSERT INTO RptExcelHeaders SELECT 233,14,'DueDate','Due Date',1,1
INSERT INTO RptExcelHeaders SELECT 233,15,'PrdId','PrdId',0,1
INSERT INTO RptExcelHeaders SELECT 233,16,'UserId','UserId',0,1
GO
IF EXISTS ( Select * from Sysobjects where Xtype = 'P' And Name = 'Proc_RptSampleIssue')
DROP PROCEDURE [Proc_RptSampleIssue] 
GO
-- EXEC [Proc_RptSampleIssue] 233,1,1,'Loreal',0,0,1
CREATE   PROCEDURE [dbo].[Proc_RptSampleIssue]
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
/*******************************************************************************************************
* VIEW		: Proc_RptSampleIssue
* PURPOSE	: To get the Sample Issue Products Details
* CREATED BY	: Mahalakshmi.A
* CREATED DATE	: 02/12/2008
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------------------------------
* {date}		{developer}  {brief modification description}	
* 16.02.2010	Panneer		 Added Product Hierarchy Filter
* 18.03.2010      Panneer		 Added Comp.Code/Dist.Code Filter
* 07.09.2010      Panneer            Added Retailer Shipping Address in Excel
********************************************************************************************************/
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
	DECLARE @SMId 		AS	INT
	DECLARE @RMId 		AS	INT
	DECLARE @RtrId 		AS	INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @CtgLevelId	AS 	INT
	DECLARE @RtrClassId	AS 	INT
	DECLARE @CtgMainId 	AS 	INT
	DECLARE @IssueRefId	AS	INT
	DECLARE @SalId		AS	INT
	DECLARE @Status		AS	INT
	DECLARE @ReasonId	AS	INT
	DECLARE @PrdTypeId	AS	INT
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
	SET @IssueRefId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,220,@Pi_UsrId))
	SET @SalId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId))
	SET @Status = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,275,@Pi_UsrId))
	--- 16.02.2010
	SET @ReasonId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,159,@Pi_UsrId))
	
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @PrdTypeId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,276,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	IF @IssueRefId=''
	SET @IssueRefId=0
	---Till Here
	Create TABLE #RptSampleIssue
	(
				RtrCode		NVARCHAR(100),
				RtrName		NVARCHAR(100),
				IssueRefNo	NVARCHAR(100),
				IssueDate	DATETIME,
				BillRefNo	NVARCHAR(100),
				SchemeCode	NVARCHAR(100),
				SKUName		NVARCHAR(100),
				UOM		NVARCHAR(100),
				Qty		NUMERIC(38,0),
				Status		NVARCHAR(100),
				Returnable	NVARCHAR(25),
				DueDate		DateTime,
				PrdId	INT,
				PrdDCode NVARCHAR(100),
				Reason  NVARCHAR(100),
				MRP NUMERIC(18,2)
	)
	SET @TblName = 'RptSampleIssue'
	SET @TblStruct = '	RtrCode		NVARCHAR(100),
				RtrName		NVARCHAR(100),
				IssueRefNo	NVARCHAR(100),
				IssueDate	DATETIME,
				BillRefNo	NVARCHAR(100),
				SchemeCode	NVARCHAR(100),
				SKUName		NVARCHAR(100),
				UOM		NVARCHAR(100),
				Qty		NUMERIC(38,0),
				Status		NVARCHAR(100),
				Returnable	NVARCHAR(25),
				DueDate		DateTime,
				PrdId	INT,
				PrdDCode NVARCHAR(100),
				Reason  NVARCHAR(100),
				MRP NUMERIC(18,2)'
	SET @TblFields = 'RtrCode,RtrName,IssueRefNo,IssueDate,BillRefNo,SchemeCode,SKUName,
					  UOM,Qty,Status,Returnable,DueDate,PrdId,PrdDCode,Reason,MRP'
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
	EXECUTE PROC_SAMPLEISSUE @PI_RPTID,@PI_USRID,@FromDate,@ToDate

	INSERT INTO #RptSampleIssue (	RtrCode,RtrName,IssueRefNo,IssueDate,BillRefNo,
									SchemeCode,SKUName,UOM,Qty,Status,Returnable,DueDate,PrdId,PrdDCode,Reason,MRP)
	SELECT DISTINCT RtrCode,RtrName,A.IssueRefNo,A.IssueDate,SalInvNo,SchCode,SKUName,UomCode,UomBaseQty,
					DlvStsDesc,Returnable,DueDate,SKUPrdId,PrdDCode,'',0.0 MRP
	FROM 
			TempSampleIssue a,FreeIssueHD b,Product P
	WHERE 	
			P.PrdId = A.SkuPrdId
			AND (A.CmpId = (CASE @CmpId WHEN 0 THEN A.CmpId ELSE 0 END) OR
							A.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			
			AND	(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE -1 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		
			AND	(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE -1 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
		
			AND	(CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN CtgLevelId ELSE 0 END) OR
							CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
		
			AND	(A.RtrId=(CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))	
		
			AND	(RtrClassId=(CASE @RtrClassId WHEN 0 THEN RtrClassId ELSE 0 END) OR
							RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
		
			AND	(CtgMainID=(CASE @CtgMainId WHEN 0 THEN ctgMainID ELSE 0 END) OR
							CtgMainID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
		
			AND	(A.SalId = (CASE @SalId WHEN 0 THEN A.SalId Else -1 END) OR
							A.SalId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId)))
		
			AND (A.IssueId = (CASE @IssueRefId WHEN 0 THEN A.IssueId Else 0 END) OR
							A.IssueId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,220,@Pi_UsrId)))
		
--			AND	(DlvSts = (CASE @Status WHEN 0 THEN DlvSts Else 0 END) OR
--							DlvSts in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,217,@Pi_UsrId)))
			
			AND A.IssueDate Between @FromDate AND @ToDate
--			AND [Status] = 1
	
			AND	(A.SKUPrdId = (CASE @PrdCatId WHEN 0 THEN A.SKUPrdId Else 0 END) OR
							A.SKUPrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			AND (A.SKUPrdId = (CASE @PrdId WHEN 0 THEN A.SKUPrdId Else 0 END) OR
							A.SKUPrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
			
	SELECT DISTINCT 
		A.PrdId,PrdBatDetailValue INTO #TempMrp 
	FROM 
		#RptSampleIssue a,ProductBatch b (NoLock),ProductBatchDetails C (NoLock)
	WHERE 
		b.PrdId = A.PrdId  and C.PrdbatId = B.PrdbatId and DefaultPrice = 1
		AND SlNo in (SELECT SlNo FROM Batchcreation (NoLock) WHERE FieldDesc = 'MRP')
	UPDATE #RptSampleIssue SET MRP = PrdBatDetailValue 	FROM #RptSampleIssue a,#TempMrp b WHERE A.PrdId  = B.PrdId 
	IF @PrdTypeId = 2
	BEGIN
		Update #RptSampleIssue SET PrdDcode = PrdCcode
		From #RptSampleIssue  a,Product b
		WHere A.PrdId = B.PrdId
	END
	IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptSampleIssue ' +
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
				+ 'AND (SalId = (CASE @SalId WHEN 0 THEN SalId Else -1 END) OR '
				+ 'SalId in (SELECT iCountid from Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',34,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (IssueId = (CASE @IssueRefId WHEN 0 THEN IssueId Else 0 END) OR '
				+ 'IssueId in (SELECT iCountid from Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',216,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (DlvSts = (CASE @Status WHEN 0 THEN DlvSts Else 0 END) OR '
				+ 'DlvSts in (SELECT iCountid from Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',217,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND IssueDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSampleIssue'
				
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
			SET @SSQL = 'INSERT INTO #RptSampleIssue ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSampleIssue
	-- Till Here
	SELECT  RtrCode,RtrName,IssueRefNo,IssueDate,BillRefNo,SchemeCode,
			PrdDCode,SKUName,MRP,UOM,Qty,Status,Returnable,DueDate,Reason,PrdId 
	FROM #RptSampleIssue
--SELECT * FROM TEMPSAMPLEISSUE
-- EXEC [Proc_RptSampleIssue] 233,1,1,'Loreal',0,0,1

	DELETE FROM RptSampleIssue_Excel 
	INSERT INTO RptSampleIssue_Excel 
	SELECT DISTINCT  C.RtrCode,C.RtrName,
			RtrShipAdd1 + ' --> ' + RtrShipAdd2 + ' --> ' + RtrShipAdd3 as RtrShipAddress,
			C.IssueRefNo,C.IssueDate,BillRefNo,SchemeCode,PrdDCode,C.SKUName,
			MRP,UOM,Qty,C.Status,C.Returnable,C.DueDate,PrdId,@Pi_UsrId
	FROM TEMPSAMPLEISSUE A 
			Left Outer JOIN FreeIssueHD B ON A.IssueId = B.IssueId
			INNER JOIN #RptSampleIssue C On A.IssueRefNo = C.IssueRefNo 
										    AND C.IssueRefNo = B.IssueRefNo
			INNER JOIN Retailer D ON C.RtrCode = D.RtrCode
			LEFT OUTER JOIN RetailerShipAdd E ON D.RtrId = E.RtrId --and B.RtrShipId = E.RtrShipId		
	RETURN 
END
GO
IF EXISTS ( Select * from Sysobjects where Xtype = 'P' And Name = 'Proc_SampleIssue')
DROP PROCEDURE Proc_SampleIssue 
GO
-- EXEC Proc_SampleIssue 159,2,'2010/03/15','2010/03/17'
CREATE  PROCEDURE [dbo].[Proc_SampleIssue]
(
	@Pi_RptId		INT,
	@Pi_UserId		INT,
	@FromDate       DateTime,
	@ToDate			DateTime
)
AS
BEGIN
/****************************************************************************
* PROCEDURE: Proc_SampleIssue
* PURPOSE:Display the Sample Issue Products
* NOTES:
* CREATED: Mahalakshmi.A
* ON DATE: 02-12-2008
* MODIFIED
* DATE			AUTHOR     DESCRIPTION
-------------------------------------------------------------------------------
* 16.02.2010	Panneer	   Added Date Filter
*****************************************************************************/
SET NOCOUNT ON
	DELETE FROM TempSampleIssue 
	INSERT INTO TempSampleIssue (IssueId,IssueRefNo,CmpId,SMId,RMId,CtgLevelId,CtgMainID,RtrClassId,
								RtrId,RtrCode,RtrName,IssueDate,SalId,SalInvNo,SchId,SchCode,SKUPrdId,SKUName,
								UomId,UomCode,UomQty,UomConvFact,UomBaseQty,
								IssueStatus,DlvSts,DlvStsDesc ,Returnable,DueDate,RptID,UsrId)
	SELECT DISTINCT 
		A.IssueId,A.IssueRefNo,F.CmpId,A.SMId,A.RMId,J.CTGLEVELID,
		I.CTGMAINID,H.RtrValueClassId AS RtrClassId,
		A.RtrId,D.RtrCode,D.RtrName,A.IssueDate,
		A.SalId,C.SalInvNo,0,'',B.PrdId,F.PrdName,
		B.IssueUomId,G.UomCode,B.IssueQty,B.IssueConFact,B.IssueBaseQty,A.Status,
		ISNULL(C.DlvSts,CASE (A.Status)WHEN 0 THEN A.Status+1 WHEN 1 THEN A.Status+3 END ),
		CASE ISNULL(C.DlvSts,CASE (A.Status)WHEN 0 THEN A.Status+1 WHEN 1 THEN A.Status+3 END)
		WHEN 4 THEN 'Confirmed'
		WHEN 5 THEN 'Confirmed'
		WHEN 3 THEN 'Deleted'
		WHEN 1 THEN 'Pending' END,
		CASE B.TobeReturned WHEN 0 THEN 'NO' ELSE 'YES' END AS TobeReturned,B.DueDate,@Pi_RptID,@Pi_UserId
		FROM FreeIssueHd A WITH (NOLOCK)
		INNER JOIN FreeIssueDt B WITH (NOLOCK) ON A.IssueId= B.IssueId
		LEFT OUTER JOIN SalesInvoice C WITH (NOLOCK) ON A.SalId=C.SalId
		INNER JOIN Retailer D WITH (NOLOCK) ON A.RtrId=D.RtrId
		INNER JOIN Product F WITH(NOLOCK) ON B.PrdID=F.PrdID
		INNER JOIN UomMaster G WITH(NOLOCk) ON B.IssueUomId=G.UomId
		INNER JOIN RETAILERVALUECLASSMAP H ON H.RtrId=D.RtrId
		INNER JOIN RETAILERVALUECLASS I ON I.RtrClassId=H.RtrValueClassId
		INNER JOIN RetailerCategory J ON J.CtgMainId=I.CtgMainId
		WHERE  IssueDate Between @FromDate and @ToDate
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_RptLoadSheetItemWise')
DROP PROCEDURE Proc_RptLoadSheetItemWise
GO
CREATE PROCEDURE [dbo].[Proc_RptLoadSheetItemWise]
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
			INSERT INTO #RptLoadSheetItemWise([SalId],BillNo,PrdId,[Product Code],[Product Description],[Batch Number],[MRP],
				[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],[GrossAmount],
				[TaxAmount],[NetAmount])
	
			SELECT [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
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
	NetAmount,[GrossAmount],[TaxAmount]
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWise([SalId],BillNo,PrdId,[Product Code],[Product Description],[Batch Number],[MRP],
					[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],[GrossAmount],
					[TaxAmount],[NetAmount])
			
			SELECT [SalId],SalInvNo,PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
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
			GrossAmount,TaxAmount,[PrdWeight]
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
	SELECT LSB.[SalId],LSB.BillNo,LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],
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
	[PrdWeight],
	SUM(LSB.[Billed Qty]) AS [Billed Qty],
	LSB.GrossAmount AS GrossAmount,
	LSB.TaxAmount AS TaxAmount,
	SUM(LSB.NETAMOUNT) as NETAMOUNT,LSB.TotalBills
	FROM #RptLoadSheetItemWise LSB,Product P 
	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
	WHERE LSB.PrdId=P.PrdId
	GROUP BY LSB.SalId,LSB.BillNo,LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],UG.ConversionFactor,
	LSB.[PrdWeight],LSB.GrossAmount,LSB.TaxAmount,LSB.TotalBills
	Order by LSB.[Product Description]
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
		GROUP BY LSB.SalId,LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],LSB.[Selling Rate],UG.ConversionFactor
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
DELETE FROM CustomCaptions WHERE TransId=200 AND CtrlId=1000 and SubCtrlId=74
INSERT INTO CustomCaptions
SELECT 200,1000,74,'PnlMsg-200-1000-74','','Enter Suggested Order Quantity','',1,1,1,GetDate(),1,GetDate(),'','Enter Suggested Order Quantity','',1,1
GO
IF EXISTS (Select * From sysobjects Where Xtype = 'FN' And Name = 'Fn_ReturnProductRate')
DROP FUNCTION Fn_ReturnProductRate
GO
CREATE FUNCTION [dbo].[Fn_ReturnProductRate](@Pi_PrdId INT,@Pi_PrdBatId INT,@Pi_Mode INT)
RETURNS NUMERIC(38,6)
AS
/*********************************
* FUNCTION: Fn_ReturnProductRate
* PURPOSE: Returns the Price for Particular Product and Batch
* NOTES: 
* CREATED: BOOPATHY	22-05-2009
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 

@Pi_Mode -	1	- MRP
@Pi_Mode -	2	- Selling Rate
@Pi_Mode -	3	- List Price
@Pi_Mode -	4	- Claim Rate
@Pi_Mode -	5	- Distributor Margin
*********************************/
BEGIN
	DECLARE @RetValue AS NUMERIC(38,6)
	IF @Pi_Mode=1
	BEGIN
			SELECT @RetValue=B.PrdBatDetailValue FROM
			ProductBatch A (NOLOCK) INNER JOIN ProductBatchDetails B (NOLOCK)
			ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1
			INNER JOIN BatchCreation C (NOLOCK)
			ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo
			AND C.MRP = 1 WHERE A.PrdId=@Pi_PrdId AND A.PrdBatId=@Pi_PrdBatId
	END
	ELSE IF @Pi_Mode=2
	BEGIN
			SELECT @RetValue=B.PrdBatDetailValue FROM
			ProductBatch A (NOLOCK) INNER JOIN ProductBatchDetails B (NOLOCK)
			ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1
			INNER JOIN BatchCreation C (NOLOCK)
			ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo
			AND C.SelRte = 1 WHERE A.PrdId=@Pi_PrdId AND A.PrdBatId=@Pi_PrdBatId
	END
	ELSE IF @Pi_Mode=3
	BEGIN
			SELECT @RetValue=B.PrdBatDetailValue FROM
			ProductBatch A (NOLOCK) INNER JOIN ProductBatchDetails B (NOLOCK)
			ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1
			INNER JOIN BatchCreation C (NOLOCK)
			ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo
			AND C.ListPrice = 1 WHERE A.PrdId=@Pi_PrdId AND A.PrdBatId=@Pi_PrdBatId
	END
	ELSE IF @Pi_Mode=4
	BEGIN
			SELECT @RetValue=B.PrdBatDetailValue FROM
			ProductBatch A (NOLOCK) INNER JOIN ProductBatchDetails B (NOLOCK)
			ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1
			INNER JOIN BatchCreation C (NOLOCK)
			ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo
			AND C.ClmRte = 1 WHERE A.PrdId=@Pi_PrdId AND A.PrdBatId=@Pi_PrdBatId
	END
	ELSE IF @Pi_Mode=5
	BEGIN
			SELECT @RetValue=B.PrdBatDetailValue FROM
			ProductBatch A (NOLOCK) INNER JOIN ProductBatchDetails B (NOLOCK)
			ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1
			INNER JOIN BatchCreation C (NOLOCK)
			ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo
			AND C.SlNo = 6 WHERE A.PrdId=@Pi_PrdId AND A.PrdBatId=@Pi_PrdBatId
	END
RETURN(@RetValue)
END
GO
EXEC Proc_GR_Build_PH
GO
IF EXISTS (SELECT * FROM Sysobjects WHERE Xtype = 'P' AND Name = 'Proc_ValidatePurchaseOrder')
DROP PROCEDURE Proc_ValidatePurchaseOrder
GO
/*
BEGIN TRANSACTION
 Exec Proc_ValidatePurchaseOrder 0
Select * from Errorlog
SELECT * FROM PurchaseOrderMaster
SELECT * FROM PurchaseOrderDetails
--DELETE FROM PurchaseOrderMaster --Truncate Table PurchaseOrdermaster
--DELETE FROM PurchaseOrderDetails
ROLLBACK  TRANSACTION
  Select * from Errorlog */

CREATE PROCEDURE [dbo].[Proc_ValidatePurchaseOrder]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_ValiadatePurchaseOrder
* PURPOSE	: To Validate the Purchase Order
* CREATED	: Boopathy.P
* CREATED DATE	: 17/11/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	DECLARE @Taction  Int
	DECLARE @ErrDesc  Varchar(1000)
	DECLARE @Tabname  Varchar(50)
	DECLARE @CmpId int
	DECLARE @CmpCode Varchar(50)
	DECLARE @PONo Varchar(50)
	DECLARE @PORefNo Varchar(50)
	DECLARE @PODate Varchar(50)
	DECLARE @POExpDate Varchar(50)
	DECLARE @PrdId int
	DECLARE @PrdCode Varchar(50)
	DECLARE @UomId1 int
	DECLARE @UomCode1 Varchar(50)
	DECLARE @UomId2 int
	DECLARE @UomCode2 Varchar(50)
	DECLARE @Qty1 Varchar(50)
	DECLARE @Qty2 Varchar(50)
	DECLARE @sStr	nVarchar(4000)
	DECLARE @SpmId INT
	DECLARE @CmpPrdCtgCode Varchar(50)
	DECLARE @PrdCtgValCode Varchar(50)
	DECLARE @PrdCtgValLinkCode Varchar(50)
	DECLARE @CmpPrdCtgId INT
	DECLARE @PrdCtgValMainId INT
    DECLARE @PrdBatId	NUMERIC(38,0)
    DECLARE @PriceId	NUMERIC(38,0)
    DECLARE @PurRate	NUMERIC(38,6)
    DECLARE @Amount		NUMERIC(38,6)
	Set @Tabname = 'ETL_Prk_POMaster'
	DECLARE @AvoidePO TABLE
	(
		Slno	INT,
		PoNo	VARCHAR(100)
	)

	INSERT INTO @AvoidePO
	SELECT 1,PORefNo
	FROM ETL_Prk_PODetails WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)  

	INSERT INTO @AvoidePO
	SELECT 2,PORefNo
	FROM ETL_Prk_PODetails A INNER JOIN Product B ON A.PrdCCode=B.PrdCCode 
	WHERE B.PrdId NOT IN (SELECT PrdId FROM ProductBatch)  

	INSERT INTO ErrorLog
	SELECT 1,'ETL_Prk_POMaster','Product','Product not found '+ CAST(PoNo AS VARCHAR(100)) FROM @AvoidePO WHERE Slno=1

	INSERT INTO ErrorLog
	SELECT 1,'ETL_Prk_POMaster','ProductBatch','Product Batch not found '+ CAST(PoNo AS VARCHAR(100)) FROM @AvoidePO WHERE Slno=2

	DECLARE Cur_POMaster CURSOR
	FOR
		SELECT Distinct ISNULL([PORefNo],'') FROM ETL_Prk_POMaster WHERE PORefNo NOT IN (SELECT PoNo FROM @AvoidePO)
	OPEN Cur_POMaster
	FETCH NEXT FROM Cur_POMaster INTO @PONo
	SET @Po_ErrNo = 0
	WHILE @@FETCH_STATUS=0
	BEGIN
		DECLARE Cur_POMasterDT CURSOR
		FOR
			SELECT Distinct ISNULL([Company Code],''),ISNULL([Hierarchy Level Code],''),
			ISNULL([Hierarchy Value Code],''),ISNULL([PODate],''),
			ISNULL([POExpiryDate],'') FROM ETL_Prk_POMaster WHERE PORefNo = @PONo
		OPEN Cur_POMasterDT
		FETCH NEXT FROM Cur_POMasterDT INTO @CmpCode,@CmpPrdCtgCode,@PrdCtgValCode,@PODate,@POExpDate
		SET @Po_ErrNo = 0
		WHILE @@FETCH_STATUS=0
		BEGIN
			Set @Tabname = 'ETL_Prk_POMaster'
					IF IsNull(@CmpCode,'') =''
					BEGIN
						SET @ErrDesc = 'Company Code Should Not Be Null'
						INSERT INTO Errorlog VALUES (1,@TabName,'Company Code',@ErrDesc)
						SET @Po_ErrNo = 1
					END
					IF ISNULL(@CmpPrdCtgCode,'') =''
					BEGIN
						SET @ErrDesc = 'Product Hierarchy Level Should Not Be Empty'
						INSERT INTO Errorlog VALUES (1,@TabName,'Product Hierarchy Level Code',@ErrDesc)
						SET @Po_ErrNo = 1
					END
					IF ISNULL(@PrdCtgValCode,'') =''
					BEGIN
						SET @ErrDesc = 'Product Hierarchy Level Value Should Not Be Empty'
						INSERT INTO Errorlog VALUES (1,@TabName,'Product Hierarchy Level VAlue Code',@ErrDesc)
						SET @Po_ErrNo = 1
					END
					IF IsNull(@PODate,'') =''
					BEGIN
						SET @ErrDesc = 'Purchase Date Should Not Be Null'
						INSERT INTO Errorlog VALUES (2,@TabName,'Purchase Date',@ErrDesc)
						SET @Po_ErrNo = 1
					END
					IF IsNull(@POExpDate,'') =''
					BEGIN
						SET @ErrDesc = 'Purchase Expiry Date Should Not Be Null'
						INSERT INTO Errorlog VALUES (3,@TabName,'Purchase Expiry Date',@ErrDesc)
						SET @Po_ErrNo = 1
					END
					IF ISDATE(LTRIM(RTRIM(@PODate))) = 0
					BEGIN
						SET @ErrDesc = 'Invalid Purchase Date'
						INSERT INTO Errorlog VALUES (4,@TabName,'Purchase Date',@ErrDesc)
						SET @Po_ErrNo =1
					END
					IF ISDATE(LTRIM(RTRIM(@POExpDate))) = 0
					BEGIN
						SET @ErrDesc = 'Invalid Purchase Expiry Date'
						INSERT INTO Errorlog VALUES (5,@TabName,'Purchase Expiry Date',@ErrDesc)
						SET @Po_ErrNo =1
					END
					IF DATEDIFF(d,@PODate,@POExpDate)<=0
					BEGIN
						SET @ErrDesc = 'Purchase Expiry Date Should be greater than Purchase Date'
						INSERT INTO Errorlog VALUES (5,@TabName,'Purchase Expiry Date',@ErrDesc)
						SET @Po_ErrNo =1
					END
					-- Company Code
					IF Not exists (SELECT * FROM Company WHERE CmpCode = @CmpCode ) and IsNull(@CmpCode,'') <> ''
					BEGIN
						  SET @ErrDesc = ' Company Code ' + @CmpCode + ' not found in Master table'
						  INSERT INTO Errorlog VALUES (6,@TabName,'Company Code',@ErrDesc)           	
						  SET @Po_ErrNo = 1
					END
					ELSE IF exists (SELECT * FROM Company WHERE CmpCode = @CmpCode ) and IsNull(@CmpCode,'') <> ''
					BEGIN
						SELECT @CmpId = CmpId FROM Company WHERE CmpCode = @CmpCode
					END
					IF Not exists (SELECT * FROM ProductCategoryLevel WHERE CmpPrdCtgName = @CmpPrdCtgCode AND CmpId=@CmpId) and IsNull(@CmpPrdCtgCode,'') <> ''
					BEGIN
						  SET @ErrDesc = ' Product Hierarchy Level Code ' + @CmpCode + ' not found in Master table'
						  INSERT INTO Errorlog VALUES (6,@TabName,'Product Hierarchy Level Code',@ErrDesc)           	
						  SET @Po_ErrNo = 1
					END
					ELSE
					BEGIN
						SELECT @CmpPrdCtgId = CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpPrdCtgName = @CmpPrdCtgCode AND CmpId=@CmpId
					END
					IF Not exists (SELECT * FROM ProductCategoryValue WHERE PrdCtgValCode = @PrdCtgValCode ) and IsNull(@CmpPrdCtgCode,'') <> ''
					BEGIN
						  SET @ErrDesc = ' Product Hierarchy Level Value Code ' + @CmpCode + ' not found in Master table'
						  INSERT INTO Errorlog VALUES (6,@TabName,'Product Hierarchy Level Value Code',@ErrDesc)           	
						  SET @Po_ErrNo = 1
					END
					ELSE
					BEGIN
						SELECT @PrdCtgValMainId = PrdCtgValMainId FROM ProductCategoryValue WHERE PrdCtgValCode = @PrdCtgValCode
						SELECT @PrdCtgValLinkCode = PrdCtgValLinkCode FROM ProductCategoryValue WHERE PrdCtgValCode = @PrdCtgValCode
					END
					IF @Po_ErrNo = 0
					BEGIN	

					DECLARE Cur_PODetails CURSOR  
					FOR 
						SELECT DISTINCT ISNULL(ET.[PrdCCode],''),ISNULL([SysUomCode],''),ISNULL([SysQty],''),ISNULL([OrdUomCode],''),ISNULL([OrdQty],'')
						FROM ETL_Prk_PODetails ET  
                        INNER JOIN ETL_Prk_POMaster EM ON ET.PORefNo = EM.PORefNo
                        INNER JOIN Product P ON ET.prdccode=P.prdccode 
						INNER JOIN TBL_GR_BUILD_PH T ON T.prdid=P.prdid AND EM.[Hierarchy Value Code]=T.[Category_Code]
						WHERE Category_Id = @PrdCtgValMainId AND ET.PORefNo = @PONo AND EM.[Hierarchy Value Code]=@PrdCtgValCode
					OPEN Cur_PODetails
					FETCH NEXT FROM Cur_PODetails INTO @PrdCode,@UomCode1,@Qty1,@UomCode2,@Qty2  
					SET @Po_ErrNo = 0
					WHILE @@FETCH_STATUS=0
					BEGIN
							IF IsNull(@PrdCode,'') =''
							BEGIN
								SET @ErrDesc = 'Product Code Should Not Be Null'
								INSERT INTO Errorlog VALUES (7,@TabName,'Product Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo = 1
							END		
							ELSE IF IsNull(@UomCode1,'') =''
							BEGIN
								SET @ErrDesc = 'System Uom Code Should Not Be Null'
								INSERT INTO Errorlog VALUES (8,@TabName,'UOM Code 1',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo = 1
							END
							ELSE IF IsNull(@Qty1,'') =''
							BEGIN
								SET @ErrDesc = 'System Quantity Should Not Be Null'
								INSERT INTO Errorlog VALUES (9,@TabName,'System Quantity',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo = 1
							END
							ELSE IF IsNull(@UomCode2,'') =''
							BEGIN
								SET @ErrDesc = 'Ordered Uom Code Should Not Be Null'
								INSERT INTO Errorlog VALUES (10,@TabName,'UOM Code 2',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo = 1
							END
							ELSE IF IsNull(@Qty2,'') =''
							BEGIN
								SET @ErrDesc = 'Order Quantity Should Not Be Null'
								INSERT INTO Errorlog VALUES (11,@TabName,'Ordered Quantity',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo = 1
							END
							-- Product Code
							IF Not exists (SELECT * FROM Product WHERE PrdCCode = @PrdCode ) and IsNull(@PrdCode,'') <> ''
							BEGIN
								  SET @ErrDesc = ' Product Code ' + @PrdCode + ' not found in Master table'
								  INSERT INTO Errorlog VALUES (12,@TabName,'Product Code',@ErrDesc)           	
								  SET @Taction = 0
								  SET @Po_ErrNo = 1
							END
							ELSE IF exists (SELECT * FROM Company WHERE CmpCode = @CmpCode ) and IsNull(@CmpCode,'') <> ''
							BEGIN
								SELECT @PrdId = PrdId FROM Product WHERE PrdCCode = @PrdCode
							END
							IF NOT EXISTS(SELECT P.* FROM Product P,ProductCategoryValue PCV
							WHERE P.PrdCtgValMainId=PCV.PrdCtgValMainId AND P.PrdId=@PrdId AND PCV.PrdCtgValLinkCode LIKE @PrdCtgValLinkCode+'%')
							BEGIN
								  SET @ErrDesc = ' Product Code ' + @PrdCode + ' not under '+ @PrdCtgValCode +''
								  INSERT INTO Errorlog VALUES (12,@TabName,'Product Code',@ErrDesc)           	
								  SET @Taction = 0
								  SET @Po_ErrNo = 1
							END
							-- System Uom Code
							IF Not exists (SELECT * FROM UOMMaster WHERE UomCode = @UomCode1 ) and IsNull(@UomCode1,'') <> ''
							BEGIN
								  SET @ErrDesc = 'System UOM Code ' + @PrdCode + ' not found in Master table'
								  INSERT INTO Errorlog VALUES (12,@TabName,'System UOM Code',@ErrDesc)           	
								  SET @Taction = 0
								  SET @Po_ErrNo = 1
							END
							ELSE IF exists (SELECT * FROM UOMMaster WHERE UomCode = @UomCode1 ) and IsNull(@UomCode1,'') <> ''
							BEGIN
								SELECT @UOMId1 = UOMId FROM UOMMaster WHERE UomCode = @UomCode1
							END
							-- Ordered Uom Code
							IF Not exists (SELECT * FROM UOMMaster WHERE UomCode = @UomCode2 ) and IsNull(@UomCode2,'') <> ''
							BEGIN
								  SET @ErrDesc = 'Ordered UOM Code ' + @PrdCode + ' not found in Master table'
								  INSERT INTO Errorlog VALUES (12,@TabName,'Ordered UOM Code',@ErrDesc)           	
								  SET @Taction = 0
								  SET @Po_ErrNo = 1
							END
							ELSE IF exists (SELECT * FROM UOMMaster WHERE UomCode = @UomCode2 ) and IsNull(@UomCode2,'') <> ''
							BEGIN
								SELECT @UOMId2 = UOMId FROM UOMMaster WHERE UomCode = @UomCode2
							END
							--Check For Batch
							IF Not exists (SELECT * FROM productbatch PB inner join product P on P.prdid=PB.prdid WHERE PrdCCode = @PrdCode) 
							BEGIN
 								  SET @ErrDesc = 'product ' + @PrdCode + ' productbatch not found in Master table'
								  INSERT INTO Errorlog VALUES (12,@TabName,'Productbatch',@ErrDesc)           	
								  SET @Taction = 0
								  SET @Po_ErrNo = 1
							END
							IF @Po_ErrNo = 0
							BEGIN
								IF NOT EXISTS (SELECT * FROM PurchaseOrderMaster WHERE CmpPoNo=@PONo)
								BEGIN 
							
		
									SET @PORefNo = dbo.Fn_GetPrimaryKeyString('PurchaseOrderMaster','PurOrderRefNo',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))

									INSERT INTO PurchaseOrderMaster (PurorderRefNo,Cmpid,purOrderDate,PurOrderExpiryDate,
										FillAllPrds,GenQtyAuto,Availability,LastModBy,LastModDate,AuthId,AuthDate,PurOrderStatus,
										ConfirmSts,DownLoad,CmpPoNo,CmpPoDate,Upload,SpmId,CmpPrdCtgId,PrdCtgValMainId,SiteId)
									VALUES (@PORefNo,@CmpId,convert(varchar(10),@PODate,121),convert(varchar(10),@POExpDate,121),0,0,1,1,
										convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),0,0,1,@PONo,@PODate,0,0,0,0,0)


									Set @Tabname = 'ETL_Prk_PODetails'
								END 				
								SET @PORefNo=''
								SELECT @PORefNo=PurorderRefNo FROM PurchaseOrderMaster WHERE CmpPoNo=@PONo

								-- Check the Purchase Order 
								IF Not exists (SELECT * FROM PurchaseOrderDetails WHERE PurorderRefNo = @PORefNo AND PrdId=@PrdId)
								BEGIN	
									
									SET @PrdBatId=0
									SET @PriceId=0
									SELECT @PrdBatId=MAX(PrdBatId) FROM ProductBatch WHERE PrdId=@PrdId
									SELECT @PriceId=PriceId FROM ProductBatchDetails WHERE PrdBatId=@PrdBatId
									SELECT @PurRate =  Dbo.Fn_ReturnProductRate (@PrdId,@PrdBatId,3) --Select
									SET @Amount=(@Qty2)* @PurRate
									INSERT INTO PurchaseOrderDetails (PurorderRefNo,PrdId,SysGenUomid,SysGenQty,
											OrdUomId,OrdQty,PrdBatId,PriceId,PurRate,Amount,Availability,LastModBy,LastModDate,AuthId,AuthDate)
									VALUES (@PORefNo,@PrdId,@UOMId1,@Qty1,@UOMId2,@Qty2,@PrdBatId,@PriceId,@PurRate,@Amount,1,1,convert(varchar(10),getdate(),121),
										1,convert(varchar(10),getdate(),121))
									
								END
								ELSE IF exists (SELECT * FROM PurchaseOrderDetails WHERE PurorderRefNo = @PORefNo AND PrdId=@PrdId)
								BEGIN
									UPDATE PurchaseOrderDetails SET PrdId=@PrdId,SysGenUomid=@UOMId1,SysGenQty=@Qty1,
										OrdUomId=@UOMId2,OrdQty=@Qty2 WHERE PurorderRefNo=@PORefNo
								END
                               
							END
							
							FETCH NEXT FROM Cur_PODetails INTO @PrdCode,@UomCode1,@Qty1,@UomCode2,@Qty2
						END
						CLOSE Cur_PODetails
						DEALLOCATE Cur_PODetails
					END
		FETCH NEXT FROM Cur_POMasterdt INTO @CmpCode,@CmpPrdCtgCode,@PrdCtgValCode,@PODate,@POExpDate
		END
		CLOSE Cur_POMasterdt
		DEALLOCATE Cur_POMasterdt
		IF @Po_ErrNo = 0
		BEGIN
			UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'PurchaseOrderMaster' and fldname = 'PurOrderRefNo'
			SET @sStr = 'UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = ' + '''PurchaseOrderMaster''' + ' and fldname = ' + '''PurOrderRefNo'''
			INSERT INTO Translog(strSql1) Values (@sstr)	

			UPDATE  A SET DownloadFlag = 'Y' FROM Cn2Cs_Prk_BLPurchaseOrder A 
			INNER JOIN PurchaseOrderMaster B ON A.PORefNo = B.CmpPoNo   WHERE PORefNo=@PONo
		END

	FETCH NEXT FROM Cur_POMaster INTO @PONo
	END
	CLOSE Cur_POMaster
	DEALLOCATE Cur_POMaster
END
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'Proc_Cn2Cs_BLPurchaseOrder')
DROP PROCEDURE Proc_Cn2Cs_BLPurchaseOrder
GO
-- SELECT * FROM ETL_Prk_POMaster
-- SELECT * FROM ETL_Prk_PODetails
-- SELECT * FROM ErrorLog
-- DELETE FROM ErrorLog
-- delete from ETL_Prk_POMaster
-- delete from ETL_Prk_PODetails
-- SELECT * FROM Cn2Cs_Prk_BLPurchaseOrder
-- DELETE FROM Cn2Cs_Prk_BLPurchaseOrder
-- EXEC Proc_Cn2Cs_BLPurchaseOrder 0
CREATE PROCEDURE Proc_Cn2Cs_BLPurchaseOrder
(
@Po_ErrNo INT OUTPUT
)
AS
/***********************************************************
* PROCEDURE: Proc_Cn2Cs_BLPurchaseOrder
* PURPOSE: To Insert the records From Console into ETL_Prk_Product,
			ETL_Prk_ProductHierarchyLevelvalue
* SCREEN : Console Integration-Product Download
* CREATED: Nandakumar R.G 31-12-2008
* MODIFIED :
* DATE      AUTHOR     DESCRIPTION
* {date} {developer}  {brief modIFication description}
*************************************************************/
SET NOCOUNT ON
BEGIN
    SET @Po_ErrNo = 0
	DECLARE @CmpCode nVarChar(50)	
	DECLARE @ErrStatus INT
	SET @ErrStatus = 0
	TRUNCATE TABLE ETL_Prk_POMaster
	TRUNCATE TABLE ETL_Prk_PODetails
	SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany=1
	INSERT INTO ETL_Prk_POMaster(PORefNo,[Company Code],[Hierarchy Level Code],
	[Hierarchy Value Code],PODate,POExpiryDate,SiteCode)
	SELECT DISTINCT PORefNo,@CmpCode,LevelCode,LevelValueCode,
	CONVERT(NVARCHAR(11),DATEADD(DD,0,PODate),121),
	CONVERT(NVARCHAR(11),DATEADD(DD,1,PODate),121),SiteCode FROM Cn2Cs_Prk_BLPurchaseOrder
	INSERT INTO ETL_Prk_PODetails(PORefNo,PrdCCode,SysUomCode,SysQty,OrdUomCode,OrdQty,SiteCode)
	SELECT DISTINCT PORefNo,PrdCCode,UOMCode,Qty,UOMCode,Qty,SiteCode FROM Cn2Cs_Prk_BLPurchaseOrder 
	EXEC Proc_ValidatePurchaseOrder 0
	RETURN
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name='Proc_RptSchemeUtilizationWithOutPrimary' AND xtype='P')
DROP PROCEDURE Proc_RptSchemeUtilizationWithOutPrimary
GO
--EXEC Proc_RptSchemeUtilizationWithOutPrimary 152,1,0,'LOREAL',0,0,1
CREATE PROCEDURE Proc_RptSchemeUtilizationWithOutPrimary
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
		UPDATE RtpSchemeWithOutPrimary SET selected=0,SlabId=0

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
		CREATE TABLE #SchemeProducts1
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
			INSERT INTO #SchemeProducts1		
			SELECT @SchIId,PrdId FROM Fn_ReturnSchemeProductBatch(@SchIId)
			FETCH NEXT FROM Cur_SchPrd INTO @SchIId
		END  
		CLOSE Cur_SchPrd  
		DEALLOCATE Cur_SchPrd  

 
		SELECT DISTINCT * INTO #SchemeProducts FROM #SchemeProducts1

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
 		WHERE A.SchId = #RptSchemeUtilization.SchId AND #RptSchemeUtilization.Type in (1,2)
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


		
	DELETE FROM #RptSchemeUtilization WHERE BaseQty=0 AND SchemeBudget=0 AND BudgetUtilized=0 AND FlatAmount=0 AND DiscountPer=0 AND Points=0 AND FreeQty=0 AND FreeValue=0 AND Total=0

	SELECT SchId,SchCode,SchDesc,SlabId,SUM(BaseQty) AS BaseQty,SchemeBudget,BudgetUtilized,NoOfRetailer,
	NoOfBills,UnselectedCnt,SUM(FlatAmount) AS FlatAmount,SUM(DiscountPer) AS DiscountPer,Points,
	FreePrdName,SUM(FreeQty) AS FreeQty,SUM(FreeValue) AS FreeValue,SUM(Total) AS Total FROM #RptSchemeUtilization
	GROUP BY SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
	NoOfBills,UnselectedCnt,Points,FreePrdName
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSchemeUtilizationWithOutPrimary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptSchemeUtilizationWithOutPrimary_Excel
		SELECT SchId,SchCode,SchDesc,SlabId,SUM(BaseQty) AS BaseQty,SchemeBudget,NoOfBills,NoOfRetailer,BudgetUtilized,
		UnselectedCnt,SUM(FlatAmount) AS FlatAmount,SUM(DiscountPer) AS DiscountPer,Points,
		FreePrdName,SUM(FreeQty) AS FreeQty,SUM(FreeValue) AS FreeValue,SUM(Total) AS Total  
		INTO RptSchemeUtilizationWithOutPrimary_Excel FROM #RptSchemeUtilization 
		GROUP BY SchId,SchCode,SchDesc,SlabId,SchemeBudget,BudgetUtilized,NoOfRetailer,
		NoOfBills,UnselectedCnt,Points,FreePrdName
	END 
	RETURN
END 
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name  = 'Proc_RptCollectionReport')
DROP PROCEDURE Proc_RptCollectionReport
GO
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
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE SlNo IN (2,3,18,19) AND RptId=@Pi_RptId
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE SlNo IN (5,4) AND RptId=@Pi_RptId
	END
	ELSE
	BEGIN
		UPDATE rptExcelHeaders SET displayFlag=1 WHERE SlNo IN (2,3,18,19) AND RptId=@Pi_RptId
		UPDATE rptExcelHeaders SET displayFlag=0 WHERE SlNo IN (5,4) AND RptId=@Pi_RptId
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
		AmtStatus 			NVARCHAR(10),
		InvRcpDate			DATETIME,
		CurPayAmount        NUMERIC (38,6),
		CollCashAmt			NUMERIC (38,6),
		CollChqAmt			NUMERIC (38,6),
		CollDDAmt			NUMERIC (38,6),
		CollRTGSAmt			NUMERIC (38,6),
		[CashBill]			[numeric](38, 0) NULL,
		[ChequeBill]		[numeric](38, 0) NULL,
		[DDbill]			[numeric](38, 0) NULL,
		[RTGSBill]			[numeric](38, 0) NULL,
		[TotalBills]		[numeric](38, 0) NULL,		
		InvRcpNo			nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Remarks				VARCHAR(1000)
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
				[CashBill] [numeric](38, 0) NULL,
				[ChequeBill] [numeric](38, 0) NULL,
				[DDbill] [numeric](38, 0) NULL,
				[RTGSBill] [numeric](38, 0) NULL,
				[TotalBills]		[numeric](38, 0) NULL,
				InvRcpNo nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
				Remarks				VARCHAR(1000)'
	SET @TblFields = 'SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
			  BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
			  BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,
				CollChqAmt,CollDDAmt,CollRTGSAmt,[CashBill],[ChequeBill],[DDbill],[RTGSBill],[TotalBills],InvRcpNo,Remarks'
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
		BalanceAmount,PayAmount,TotalBillAmount,AmtStatus,InvRcpDate,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt
		,InvRcpNo,Remarks)
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
--SELECT 'ddd', BillAmount,CurPayAmount,BalanceAmount,InvRcpNo,SalInvNo,RtrId FROM #RptCollectionDetail ORDER BY SalInvNo,InvRcpNo
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
	
	UPDATE #RptCollectionDetail SET  [CashBill]=(CASE WHEN CollCashAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [ChequeBill]=(CASE WHEN CollChqAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [DDbill]=(CASE WHEN CollDDAmt<>0 THEN 1 ELSE 0 END) 
	UPDATE #RptCollectionDetail SET  [RTGSBill]=(CASE WHEN  CollRTGSAmt<>0 THEN 1 ELSE 0 END)
	UPDATE #RptCollectionDetail SET  [TotalBills]=(SELECT Count(Salid) FROM #RptCollectionDetail)
	
	SELECT SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
	BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
	ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,AmtStatus,
	CashBill,Chequebill,DDBill,RTGSBill,InvRcpNo,[TotalBills] FROM #RptCollectionDetail ORDER BY SalId,InvRcpDate,InvRcpNo

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCollectionDetail_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptCollectionDetail_Excel
		SELECT  A.SalId,A.SalInvNo,A.SalInvDate,A.InvRcpNo,A.InvRcpDate,A.RtrId,A.RtrName,
			A.BillAmount,A.CrAdjAmount,A.DbAdjAmount,A.CurPayAmount,A.CashDiscount,B.OnAccValue,
			A.CollectedAmount,A.PayAmount,A.BalanceAmount,A.AmtStatus,CollectedDate,CollectedBy,Remarks INTO RptCollectionDetail_Excel
			FROM #RptCollectionDetail A INNER JOIN 
			(SELECT SalId,SalInvNo,InvRcpNo,SUM(OnAccValue) AS OnAccValue,CollectedDate,CollectedBy FROM RptCollectionValue 
			GROUP BY SalId,SalInvNo,InvRcpNo,CollectedDate,CollectedBy) B ON A.SalId=B.SalId AND A.SalInvNo=B.SalInvNo
			AND A.InvRcpNo=B.InvRcpNo
	END
RETURN
END
GO
if NOT exists (Select Id,name from Syscolumns where name = 'BillBookRefNo' and id in (Select id from 
	Sysobjects where name ='RptBillTemplateFinal'))
BEGIN
	ALTER TABLE RptBillTemplateFinal ADD  BillBookRefNo VARCHAR(100)
END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE name='Proc_RptBillTemplateFinal' AND xtype ='P')
DROP PROCEDURE Proc_RptBillTemplateFinal
GO
--EXEC PROC_RptBillTemplateFinal 16,1,0,'NVSPLRATE20100119',0,0,1,'RPTBT_VIEW_FINAL_BILLTEMPLATE'  
CREATE PROCEDURE [dbo].[Proc_RptBillTemplateFinal]  
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
* 01.10.2009  Panneer    Added Tax summary Report Part(UserId Condition)  
* UserId and Distinct added to avoid doubling value in Bill Print. by Boopathy and Shyam on 24-08-2011  
* Removed Userid mapping for supreports on 30-08-2011 By Boopathy.P  
*  optimize the bill print generation by Boopathy on 02-11-2011
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
 SELECT @DeliveredBill=Status FROM  Configuration  (NOLOCK) WHERE ModuleName='Discount & Tax Collection' AND ModuleId='DISTAXCOLL5'  
 IF @DeliveredBill=1  
 BEGIN    
  DELETE FROM RptBillToPrint WHERE [Bill Number] IN(  
  SELECT SalInvNo FROM SalesInvoice  (NOLOCK) WHERE DlvSts NOT IN(4,5))  AND UsrId=@Pi_UsrId  
 END  
 --Till Here  
 --Added By Murugan 04/09/2009  
 SET @FieldCount=0  
 SELECT @UomStatus=Isnull(Status,0) FROM configuration  (NOLOCK)  WHERE ModuleName='General Configuration' and ModuleId='GENCONFIG22' and SeqNo=22  
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
  FOR SELECT UOMID,UOMCODE FROM UOMMASTER  (NOLOCK)  Order BY UOMID  
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
-- if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
-- drop table [RptBillTemplateFinal]  
-- IF @UomStatus=1  
-- BEGIN   
--  Exec('CREATE TABLE RptBillTemplateFinal  
--  (' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500),'+ @UomFieldList +')')  
-- END  
-- ELSE  
-- BEGIN  
--  Exec('CREATE TABLE RptBillTemplateFinal  
--  (' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500))')  
-- END  
 DELETE FROM RptBillTemplateFinal WHERE Usrid=@Pi_UsrId  
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
  Select @DBNAME = CounterDesc  FROM CounterConfiguration With(Nolock) WHERE SlNo =3  
  SET @DBNAME = @PI_DBNAME + @DBNAME  
 END  
   
 --Nanda01  
 IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
 BEGIN  
  Delete from RptBillTemplateFinal Where UsrId = @Pi_UsrId  
  IF @UomStatus=1  
  BEGIN  
   EXEC ('INSERT INTO RptBillTemplateFinal (' + @FieldList1+@FieldList + ','+ @UomFields1 + ')' +  
   'Select  DISTINCT' + @FieldList1+@FieldList +','+ @UomFields+'  from ' + @Pi_BTTblName + ' V (NOLOCK) ,RptBillToPrint T  (NOLOCK) Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND T.UsrId='+@Pi_UsrId)  
  END  
  ELSE  
  BEGIN  
   --SELECT 'Nanda002'   
   Exec ('INSERT INTO RptBillTemplateFinal (' +@FieldList1+ @FieldList + ')' +  
   'Select  DISTINCT' + @FieldList1+ @FieldList + '  from ' + @Pi_BTTblName + ' V (NOLOCK) ,RptBillToPrint T  (NOLOCK) Where V.[Sales Invoice Number] = T.[Bill Number] AND V.UsrId=T.UsrId AND  T.UsrId='+ @Pi_UsrId)  
  END  
  IF LEN(@PurDBName) > 0  
  BEGIN  
   EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT  
     
   SET @SSQL = 'INSERT INTO RptBillTemplateFinal ' +  
    '(' + @TblFields + ')' +  
   ' SELECT DISTINCT' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName + '  (NOLOCK) Where UsrId = ' +  CAST(@Pi_UsrId AS VARCHAR(10))  
    
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
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount1')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount1]=BillPrintTaxTemp.[Tax1Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 2')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 2]=BillPrintTaxTemp.[Tax2Perc],[RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount2')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 3')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 3]=BillPrintTaxTemp.[Tax3Perc]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount3')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount3] =BillPrintTaxTemp.[Tax3Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 4')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 4]=BillPrintTaxTemp.[Tax4Perc],[RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount4')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 5')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 5]=BillPrintTaxTemp.[Tax5Perc],[RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount5')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]  
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]  
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode] AND [RptBillTemplateFinal].UsrId=BillPrintTaxTemp.UsrId AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
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
		AND [RptBillTemplateFinal].[Batch Code] =ProductBatch.[PrdBatCode] AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END  
--- End Sl No  
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
 ---------------------------------TAX (SubReport)  
 Select @Sub_Val = TaxDt  FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
  Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)  
  SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId  
  FROM SalesInvoiceProductTax SI  (NOLOCK) , TaxConfiguration T (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK)   
  WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId  
  GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc  
 End  
 ------------------------------ Other  
 Select @Sub_Val = OtherCharges FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	IF EXISTS (SELECT A.SalId FROM SalInvOtherAdj A INNER JOIN RptSELECTedBills B ON A.SalId=B.SalId WHERE B.UsrId= @Pi_UsrId)
	BEGIN
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)  
		SELECT SI.SalId,S.SalInvNo,  
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,  
		Adjamt Amount,@Pi_UsrId  
		FROM SalInvOtherAdj SI (NOLOCK) ,PurSalAccConfig P (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK)   
		WHERE P.TransactionId = 2  
		and SI.AccDescId = P.AccDescId  
		and SI.SalId = S.SalId  
		and S.SalInvNo = B.[Bill Number]  
		AND B.UsrId = @Pi_UsrId  
	END
 End  
 ---------------------------------------Replacement  
 Select @Sub_Val = Replacement FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	IF EXISTS (SELECT A.SalId FROM ReplacementHd A INNER JOIN RptSELECTedBills B ON A.SalId=B.SalId WHERE B.UsrId= @Pi_UsrId AND A.SalId>0)
	BEGIN
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)  
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId  
		FROM ReplacementHd H (NOLOCK) , ReplacementOut D (NOLOCK) , Product P (NOLOCK) , ProductBatch PB (NOLOCK) ,SalesInvoice SI (NOLOCK) ,RptBillToPrint B (NOLOCK)   
		WHERE H.SalId <> 0  
		and H.RepRefNo = D.RepRefNo  
		and D.PrdId = P.PrdId  
		and D.PrdBatId = PB.PrdBatId  
		and H.SalId = SI.SalId  
		and SI.SalInvNo = B.[Bill Number]  
		AND B.UsrId = @Pi_UsrId  
	END
 End  
 ----------------------------------Credit Debit Adjus  
 Select @Sub_Val = CrDbAdj  FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	IF EXISTS (SELECT A.SalId FROM SalInvCrNoteAdj A INNER JOIN RptSELECTedBills B ON A.SalId=B.SalId WHERE B.UsrId= @Pi_UsrId AND A.SalId>0)
	BEGIN
		Insert into RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,PreviousAmount,CrDbRemarks,UsrId)
		Select A.SalId,S.SalInvNo,A.CrNoteNumber,A.CrAdjAmount,A.AdjSofar,D.Remarks,@Pi_UsrId  
		from SalInvCrNoteAdj A (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK),   
		CreditNoteRetailer D (NOLOCK) Where A.SalId = s.SalId AND D.CrNoteNumber=A.CrNoteNumber
		AND A.RtrId=S.RtrId AND A.RtrId=D.RtrId
		and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId  
	END
	IF EXISTS (SELECT A.SalId FROM SalInvDbNoteAdj A INNER JOIN RptSELECTedBills B ON A.SalId=B.SalId WHERE B.UsrId= @Pi_UsrId AND A.SalId>0)
	BEGIN	 
		Insert into RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,PreviousAmount,CrDbRemarks,UsrId)
		Select A.SalId,S.SalInvNo,A.DbNoteNumber,A.DbAdjAmount,A.AdjSofar,D.Remarks,@Pi_UsrId
		from SalInvDbNoteAdj A (NOLOCK) ,SalesInvoice S (NOLOCK) ,RptBillToPrint B (NOLOCK),
		DebitNoteRetailer D (NOLOCK) Where A.SalId = s.SalId  AND A.DbNoteNumber = D.DbNoteNumber AND 
		A.RtrId=S.RtrId AND A.RtrId=D.RtrId	and S.SalInvNo = B.[Bill Number] AND B.UsrId = @Pi_UsrId  
	END
 End  
 ---------------------------------------Market Return  
 Select @Sub_Val = MarketRet FROM BillTemplateHD With(Nolock) WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	Insert into RptBillTemplate_MarketReturn(Type,SalId,SalInvNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,
	MRP,GrossAmount,SchemeAmount,DBDiscAmount,CDAmount,SplDiscAmount,TaxAmount,Amount,UsrId)  
	Select 'Market Return' Type ,H.SalId,S.SalInvNo,D.PrdId,P.PrdName,  
	D.PrdBatId,PB.PrdBatCode,BaseQty,D.PrdUnitSelRte,D.PrdUnitMRP,D.PrdGrossAmt,
	D.PrdSchDisAmt,D.PrdDBDisAmt,D.PrdCDDisAmt,D.PrdSplDisAmt,D.PrdTaxAmt,D.PrdNetAmt,@Pi_UsrId  
	From ReturnHeader H (NOLOCK) 
	INNER JOIN ReturnProduct D (NOLOCK) ON H.ReturnID = D.ReturnID
	INNER JOIN Product P (NOLOCK) ON D.PrdId = P.PrdId  
	INNER JOIN ProductBatch PB (NOLOCK) ON D.PrdBatId = PB.PrdBatId AND D.PrdId=PB.PrdId
	INNER JOIN SalesInvoice S (NOLOCK) ON H.SalId = S.SalId  
	INNER JOIN RptSELECTedBills E1 (NOLOCK) ON S.SalId=E1.SalId 
	Where returntype = 1  AND E1.UsrId = @Pi_UsrId  
	Union ALL  
	Select 'Market Return Free Product' Type,E1.SalId,S.SalInvNo,T.FreePrdId,P.PrdName,  
	T.FreePrdBatId,PB.PrdBatCode,T.ReturnFreeQty,0,0,0,0,0,0,0,0,0,@Pi_UsrId  
	From ReturnHeader H (NOLOCK) 
	INNER JOIN ReturnSchemeFreePrdDt T (NOLOCK) ON H.ReturnID = T.ReturnID
	INNER JOIN Product P (NOLOCK) ON T.FreePrdId = P.PrdId  
	INNER JOIN ProductBatch PB (NOLOCK) ON T.FreePrdBatId = PB.PrdBatId AND T.FreePrdId=PB.PrdId
	INNER JOIN SalesInvoice S (NOLOCK) ON H.SalId = S.SalId  
	INNER JOIN RptSELECTedBills E1 (NOLOCK) ON S.SalId=E1.SalId 
	WHERE returntype = 1 AND E1.UsrId = @Pi_UsrId  
 End  
 ------------------------------ SampleIssue  
 Select @Sub_Val = SampleIssue FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,19,len(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
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
	INNER JOIN RptSELECTedBills E1 (NOLOCK) ON C.SalId=E1.SalId 
	INNER JOIN SampleSchemeMaster D WITH(NOLOCK)ON B.SchId=D.SchId  
	INNER JOIN Product E WITH (NOLOCK) ON B.PrdID=E.PrdId  
	INNER JOIN Company F WITH (NOLOCK) ON E.CmpId=F.CmpId  
	INNER JOIN ProductBatch G WITH (NOLOCK) ON E.PrdID=G.PrdID AND B.PrdBatId=G.PrdBatId  
	INNER JOIN UOMMaster H WITH (NOLOCK) ON B.IssueUomID=H.UomID  
	WHERE E1.UsrId = @Pi_UsrId  
 End  
 --->Added By Nanda on 10/03/2010  
 ------------------------------ Scheme  
 Select @Sub_Val = [Scheme] FROM BillTemplateHD WHERE TempName=SUBSTRING(@Pi_BTTblName,19,LEN(@Pi_BTTblName)) --AND UsrId = @Pi_UsrId  
 If @Sub_Val = 1  
 Begin  
	INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,  
	PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)  
	SELECT SI.SalId,SI.SalInvNo,SISL.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'  
	WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',  
	0,'',0,0,SUM(SISL.DiscountPerAmount+SISL.FlatAmount),0,0,@Pi_UsrId  
	FROM SalesInvoice SI (NOLOCK) 
	INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
	INNER JOIN SalesInvoiceSchemeLineWise SISL (NOLOCK) ON SI.SalId=SISL.SalId
	INNER JOIN SchemeMaster SM (NOLOCK) ON  SISL.SchId=SM.SchId,RptBillToPrint RBT (NOLOCK)   
	WHERE E.UsrId = @Pi_UsrId  
	GROUP BY SI.SalId,SI.SalInvNo,SISL.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc  
	HAVING SUM(SISL.DiscountPerAmount+SISL.FlatAmount)>0  

	INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,  
	PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)  
	SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'  
	WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.FreePrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,  
	SISFP.FreePrdBatId,PB.PrdBatCode,SISFP.FreeQty,PBD.PrdBatDetailValue,SISFP.FreeQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId  
	FROM SalesInvoice SI (NOLOCK) 
	INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
	INNER JOIN SalesInvoiceSchemeDtFreePrd SISFP (NOLOCK) ON SI.SalId=SISFP.SalId
	INNER JOIN SchemeMaster SM (NOLOCK) ON SISFP.SchId=SM.SchId
	INNER JOIN Product P (NOLOCK) ON SISFP.FreePrdId=P.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON SISFP.FreePrdBatId=PB.PrdBatId 
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON  PB.PrdBatId=PBD.PrdBatId AND SISFP.FreePriceId=PBD.PriceId
	INNER JOIN BatchCreation BC (NOLOCK) ON PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1
	WHERE E.UsrId = @Pi_UsrId  
--
	INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,  
	PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)  
	SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'  
	WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.GiftPrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,  
	SISFP.GiftPrdBatId,PB.PrdBatCode,SISFP.GiftQty,PBD.PrdBatDetailValue,SISFP.GiftQty*PBD.PrdBatDetailValue,0,0,@Pi_UsrId  
	FROM SalesInvoice SI (NOLOCK) 
	INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
	INNER JOIN SalesInvoiceSchemeDtFreePrd SISFP (NOLOCK) ON SI.SalId=SISFP.SalId
	INNER JOIN SchemeMaster SM (NOLOCK) ON SISFP.SchId=SM.SchId
	INNER JOIN Product P (NOLOCK) ON SISFP.GiftPrdId=P.PrdId
	INNER JOIN ProductBatch PB (NOLOCK) ON SISFP.GiftPrdBatId=PB.PrdBatId 
	INNER JOIN ProductBatchDetails PBD (NOLOCK) ON  PB.PrdBatId=PBD.PrdBatId AND SISFP.GiftPriceId=PBD.PriceId
	INNER JOIN BatchCreation BC (NOLOCK) ON PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1
	WHERE E.UsrId = @Pi_UsrId  

--
	INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,  
	PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemevalue,UsrId)  
	SELECT SI.SalId,SI.SalInvNo,SIWD.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'  
	WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',  
	0,'',0,0,SUM(SIWD.AdjAmt),0,0,@Pi_UsrId  
	FROM SalesInvoice SI (NOLOCK) 
	INNER JOIN RptSELECTedBills E (NOLOCK) ON SI.SalId=E.SalId
	INNER JOIN SalesInvoiceWindowDisplay SIWD (NOLOCK) ON SI.SalId=SIWD.SalId AND SI.RtrId=SIWD.RtrId
	INNER JOIN SchemeMaster SM (NOLOCK) ON SIWD.SchId=SM.SchId
	WHERE E.UsrId = @Pi_UsrId  
	GROUP BY SI.SalId,SI.SalInvNo,SIWD.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc  

	UPDATE RPT SET SalInvSchemevalue=A.SalInvSchemevalue  
	FROM RptBillTemplate_Scheme RPT,(SELECT SalId,SUM(SchemeValueInAmt) AS SalInvSchemevalue FROM RptBillTemplate_Scheme WHERE UsrId = @Pi_UsrId GROUP BY SalId)A  
	WHERE A.SAlId=RPT.SalId AND RPT.UsrId = @Pi_UsrId  
 End  
 --->Till Here   
 --->Added By Nanda on 23/03/2010-For Grouping the details based on product for nondrug products  
 IF EXISTS(SELECT * FROM Configuration  (NOLOCK) WHERE ModuleId='BotreeBillPrinting01' AND ModuleName='Botree Bill Printing' AND Status=1)  
 BEGIN  
  IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplateFinal_Group]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)  
  DROP TABLE [RptBillTemplateFinal_Group]  
  SELECT * INTO RptBillTemplateFinal_Group FROM RptBillTemplateFinal  (NOLOCK) WHERE UsrId = @Pi_UsrId  
  DELETE FROM RptBillTemplateFinal WHERE UsrId = @Pi_UsrId  
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
  SELECT DISTINCT  
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
  [Uom 1 Desc] AS [Uom 1 Desc],SUM([Uom 1 Qty]) AS [Uom 1 Qty],'' AS [Uom 2 Desc],0 AS [Uom 2 Qty],[Vehicle Name],  
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
  FROM RptBillTemplateFinal_Group (NOLOCK) ,Product P (NOLOCK)   
  WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType<>5 AND RptBillTemplateFinal_Group.UsrId = @Pi_UsrId  
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
  [Uom 1 Desc],   
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
  FROM RptBillTemplateFinal_Group (NOLOCK) ,Product P (NOLOCK)   
  WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5 AND RptBillTemplateFinal_Group.UsrId = @Pi_UsrId  
 END   
-- UPDATE RptBillTemplateFinal SET Visibility=0 WHERE UsrId<>@Pi_UsrId  
-- SELECT * FROM RptBillTemplateFinal  
-- SELECT * FROM SalesInvoiceProduct A INNER JOIN Product  
 --->Till Here  
 IF EXISTS (SELECT A.SalId FROM SalInvoiceDeliveryChallan A  (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK)   
    ON A.SalId=B.SalId INNER JOIN RptBillToPrint C  (NOLOCK) ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId)  
 BEGIN  
  TRUNCATE TABLE RptFinalBillTemplate_DC  
  INSERT INTO RptFinalBillTemplate_DC(SalId,InvNo,DCNo,DCDate)  
  SELECT A.SalId,B.SalInvNo,A.DCNo,DCDate FROM SalInvoiceDeliveryChallan A  (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK)   
  ON A.SalId=B.SalId INNER JOIN RptBillToPrint C  (NOLOCK) ON C.[Bill Number]=SalInvNo WHERE C.UsrId = @Pi_UsrId  
 END  
 ELSE  
 BEGIN  
  TRUNCATE TABLE RptFinalBillTemplate_DC  
 END   
IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='BillBookRefNo')  
	BEGIN  
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[BillBookRefNo]=SalesInvoice.[BillBookNo]  
		FROM SalesInvoice WHERE [RptBillTemplateFinal].SalId=SalesInvoice.[SalId] 
		AND [RptBillTemplateFinal].UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))  
		EXEC (@SSQL1)  
	END 
 RETURN 
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_CutOffOverSold')
DROP PROCEDURE Proc_CutOffOverSold
GO
--EXEC Proc_CutOffOverSold 1,'2007/09/13'
CREATE         PROCEDURE [dbo].[Proc_CutOffOverSold]
(
	@Pi_UserId		INT,
	@Pi_Date 	DATETIME
)
AS
/*********************************
* PROCEDURE	: Proc_CutOffOverSold
* PURPOSE	: To Update the Order Booking Products
* CREATED	: Nandakumar R.G
* CREATED DATE	: 25/07/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
/*
Note:
For History,
Mode - 0 Addition
Mode - 1 Reduction
*/
SET NOCOUNT ON
BEGIN
	DECLARE @OrderNo AS NVARCHAR(25)
	DECLARE @PrdId AS INT
	DECLARE @BilledQty AS INT
	DECLARE @AvlQty AS INT
	DECLARE @sSql AS NVARCHAR(1000)
	
	DECLARE @MRP AS NUMERIC(38,6)
	DECLARE @SelRte AS NUMERIC(38,6)
	
	DECLARE @PrdBatId AS INT
	DECLARE @TotalQty AS INT
	
	DECLARE @NetAmount AS NUMERIC(38,6)
	
	DECLARE @HistoryQty AS INT
	DECLARE @HistoryPrdBatId AS INT
	DECLARE @UomId AS INT
	
	DECLARE @Loop AS INT
	DECLARE @DefLcnId AS INT
	
	SELECT @DefLcnId=LcnId FROM Location WHERE DefaultLocation=1
	
	IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME = 'PrdBatLcn' AND XTYPE='U')
	BEGIN
	     DROP TABLE PrdBatLcn
	END
	
	CREATE TABLE PrdBatLcn (PrdId INT,PrdBatId INT,AvlQty INT)	
	
	INSERT INTO PrdBatLcn	
	SELECT PrdId,PrdBatId,PrdBatLcnSih-PrdBatLcnResSih AS AvlQty
	FROM ProductBatchLocation WHERE LcnId=@DefLcnId ORDER BY PrdId,PrdBatId
	DECLARE Cur_CutOff CURSOR FOR 	
	SELECT OrderNo,PrdId,BilledQty FROM CutOffTempTbl WHERE UserId=@Pi_UserId
	ORDER BY OrderNo,PrdId
	SELECT * INTO #OrderBookingProducts FROM OrderBookingProducts where 1=2
	OPEN Cur_CutOff
	
	FETCH NEXT FROM Cur_CutOff
	INTO @OrderNo,@PrdId,@BilledQty
	
	WHILE @@FETCH_STATUS=0
	BEGIN
		DELETE FROM #OrderBookingProducts
		INSERT INTO #OrderBookingProducts SELECT * FROM OrderBookingProducts WHERE OrderNo = @OrderNo
		
		--History--------------
		--All Quantities are going to delete and then insertion will be based on FIFO and stock availability
		SELECT  @HistoryQty=dbo.Fn_ReturnExistQty (@PrdId,@OrderNo)
		SELECT  @HistoryPrdBatId=dbo.Fn_ReturnExistBatchId (@PrdId,@OrderNo)
					
		INSERT INTO CutOffHistory(OrderNo,PrdId,PrdBatId,DiffQty,DiffMode,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT OBP.OrderNo,OBP.PrdId,OBP.PrdBatId,OBP.TotalQty,1,1,@Pi_UserId,@Pi_Date,@Pi_UserId,@Pi_Date
	FROM OrderBookingProducts OBP WHERE OrderNo=@OrderNo AND PrdId=@PrdId
		-----------------------	
		IF @BilledQty=0
		BEGIN
			SET @sSql='UPDATE #OrderBookingProducts SET TotalQty=0,Qty1=0,Qty2=0,GrossAmount=0 WHERE PrdId='
			SET @sSql=@sSql+CAST(@PrdId AS NVARCHAR(10)) + ' AND OrderNo='''
			SET @sSql=@sSql+@OrderNo+' '''
			EXEC(@sSql)
		END
		ELSE
		BEGIN
		
		    	DELETE FROM #OrderBookingProducts WHERE OrderNo=@OrderNo AND PrdId=@PrdId
	
			SET @sSql='DECLARE Cur_CutOffBatch CURSOR FOR ' 	
			SET @sSql=@sSql+'SELECT PrdBatId,AvlQty FROM PrdBatLcn WHERE PrdId='+CAST(@PrdId AS NVARCHAR(10))
			SET @sSql=@sSql+' AND AvlQty>0 ORDER BY PrdBatId'
			EXEC (@sSql)
			
			SELECT  @UomId=dbo.Fn_ReturnUomId (@PrdId)
			
			OPEN Cur_CutOffBatch
			FETCH NEXT FROM Cur_CutOffBatch
			INTO @PrdBatId,@AvlQty
			WHILE @@FETCH_STATUS=0
			BEGIN
	                	IF @BilledQty>0
	                	BEGIN
	                		IF @BilledQty>=@AvlQty
				    	BEGIN
			                        SELECT @MRP=PBD.PrdBatDetailValue FROM ProductBatch PB,ProductBatchDetails PBD,BatchCreation BC
						WHERE PB.BatchSeqId=BC.BatchSeqId AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND
						PB.PrdBatId=@PrdBatId
							
						SELECT @SelRte=PBD.PrdBatDetailValue FROM ProductBatch PB,ProductBatchDetails PBD,BatchCreation BC
						WHERE PB.BatchSeqId=BC.BatchSeqId AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo=BC.SlNo AND BC.SelRte=1 AND
						PB.PrdBatId=@PrdBatId
							
						 SET @sSql='INSERT INTO #OrderBookingProducts(OrderNo,PrdId,PrdBatId,PriceId,UOMId1,Qty1,UOMId2,Qty2,TotalQty,Availability,
						LastModBy,LastModDate,AuthId,AuthDate,BilledQty,ConvFact1,ConvFact2,Rate,MRP,GrossAmount)
						SELECT ''' + @OrderNo + ''','+CAST (@PrdId AS NVARCHAR(10))+','+CAST(@PrdBatId AS NVARCHAR(10))+',0,'+CAST(@UomId AS NVARCHAR(10))+','+CAST(@AvlQty AS NVARCHAR(10))+
						',0,0,'+CAST(@AvlQty AS NVARCHAR(10))+',1,'+CAST(@Pi_UserId AS NVARCHAR(10))+','''+CONVERT(NVARCHAR(10),@Pi_Date,121)+''','+
						CAST(@Pi_UserId AS NVARCHAR(10))+','''+CONVERT(NVARCHAR(10),@Pi_Date,121)+''',0,1,0,'+CAST(@SelRte AS NVARCHAR(25))+','+CAST(@MRP AS NVARCHAR(25))+','+CAST(@AvlQty*@SelRte AS NVARCHAR(25))
						
						UPDATE PrdBatLcn SET AvlQty=0 WHERE PrdId=@PrdId AND PrdBatId=@PrdBatId
						
						--History--------------
						--Inserted Quantities will be recorded here
						INSERT INTO CutOffHistory(OrderNo,PrdId,PrdBatId,DiffQty,DiffMode,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@OrderNo,@PrdId,@PrdBatId,@AvlQty,0,1,@Pi_UserId,@Pi_Date,@Pi_UserId,@Pi_Date)
						-----------------------	
						SET @BilledQty=@BilledQty-@AvlQty
					END
					ELSE
					BEGIN
			 SELECT @MRP=PBD.PrdBatDetailValue FROM ProductBatch PB,ProductBatchDetails PBD,BatchCreation BC
						 WHERE PB.BatchSeqId=BC.BatchSeqId AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo=BC.SlNo AND BC.MRP=1 AND
						 PB.PrdBatId=@PrdBatId AND PBD.DefaultPrice=1
			
						 SELECT @SelRte=PBD.PrdBatDetailValue FROM ProductBatch PB,ProductBatchDetails PBD,BatchCreation BC
						 WHERE PB.BatchSeqId=BC.BatchSeqId AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo=BC.SlNo AND BC.SelRte=1 AND
						 PB.PrdBatId=@PrdBatId AND PBD.DefaultPrice=1
									
	  					 SET @sSql='INSERT INTO #OrderBookingProducts(OrderNo,PrdId,PrdBatId,PriceId,UOMId1,Qty1,UOMId2,Qty2,TotalQty,Availability,
						 LastModBy,LastModDate,AuthId,AuthDate,BilledQty,ConvFact1,ConvFact2,Rate,MRP,GrossAmount)
						 SELECT ''' + @OrderNo + ''','+CAST (@PrdId AS NVARCHAR(10))+','+CAST(@PrdBatId AS NVARCHAR(10))+',0,'+CAST(@UomId AS NVARCHAR(10))+','+CAST(@BilledQty AS NVARCHAR(10))+
						 ',0,0,'+CAST(@BilledQty AS NVARCHAR(10))+',1,'+CAST(@Pi_UserId AS NVARCHAR(10))+','''+CONVERT(NVARCHAR(10),@Pi_Date,121)+''','+
						 CAST(@Pi_UserId AS NVARCHAR(10))+','''+CONVERT(NVARCHAR(10),@Pi_Date,121)+''',0,1,0,'+CAST(@SelRte AS NVARCHAR(25))+','+CAST(@MRP AS NVARCHAR(25))+','+CAST(@BilledQty*@SelRte AS NVARCHAR(25))
	
						--History--------------
						--Inserted Quantities will be recorded here
						INSERT INTO CutOffHistory(OrderNo,PrdId,PrdBatId,DiffQty,DiffMode,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@OrderNo,@PrdId,@PrdBatId,@BilledQty,0,1,@Pi_UserId,@Pi_Date,@Pi_UserId,@Pi_Date)
						-----------------------	
						
			UPDATE PrdBatLcn SET AvlQty=AvlQty-@BilledQty WHERE PrdId=@PrdId AND PrdBatId=@PrdBatId
	
					     SET @BilledQty=0
					END
	
					EXEC (@sSql)
				END
			
				FETCH NEXT FROM Cur_CutOffBatch
				INTO @PrdBatId,@AvlQty
			END	
			
			CLOSE Cur_CutOffBatch
			DEALLOCATE Cur_CutOffBatch	
		END
		
		DELETE FROM #OrderBookingProducts WHERE TotalQty<=0
		
		DELETE FROM OrderBookingProducts WHERE OrderNo=@OrderNo
	
		INSERT INTO OrderBookingProducts SELECT * FROM #OrderBookingProducts
	
		UPDATE OrderBookingProducts SET GrossAmount=TotalQty*Rate
		
		UPDATE OrderBookingProducts SET OrderBookingProducts.PriceId=PB.DefaultPriceId
		FROM ProductBatch PB WHERE PB.PrdBatId=OrderBookingProducts.PrdBatId AND OrderBookingProducts.PriceId=0
		
		SELECT  @NetAmount=dbo.Fn_ReturnNetAmount(@OrderNo)
		
		UPDATE OrderBooking SET Upload=0,TotalAmount=@NetAmount WHERE OrderNo=@OrderNo 	
		
		FETCH NEXT FROM Cur_CutOff
		INTO @OrderNo,@PrdId,@BilledQty
	END
	CLOSE Cur_CutOff
	DEALLOCATE Cur_CutOff	
	IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME = 'PrdBatLcn' AND XTYPE='U')
	BEGIN
	     DROP TABLE PrdBatLcn
	END
	
END
GO
delete from Rptheader where rptid=233
GO
Insert Into rptheader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
Values('SampleIssueReport',	'Sample Issue Report',	233,	'Sample Issue Report',	'Proc_RptSampleIssue',	'RptSampleIssue',	'RptSampleIssue.rpt',	'NULL')
GO
delete from rptformula where rptid=233
GO
DELETE FROM RptFormula WHERE RptId=233
INSERT INTO RptFormula  SELECT 233,1,'Disp_FromDate','From Date',1,0
INSERT INTO RptFormula  SELECT 233,2,'Fill_FromDate','FromDate',1,10
INSERT INTO RptFormula  SELECT 233,3,'Disp_ToDate','To Date',1,0
INSERT INTO RptFormula  SELECT 233,4,'Fill_ToDate','ToDate',1,11
INSERT INTO RptFormula  SELECT 233,5,'Disp_Company','Company',1,0
INSERT INTO RptFormula  SELECT 233,6,'Fill_Company','Company',1,4
INSERT INTO RptFormula  SELECT 233,7,'Disp_Salesman','Salesman',1,0
INSERT INTO RptFormula  SELECT 233,8,'Fill_Salesman','Salesman',1,1
INSERT INTO RptFormula  SELECT 233,9,'Disp_Route','Route',1,0
INSERT INTO RptFormula  SELECT 233,10,'Fill_Route','Route',1,2
INSERT INTO RptFormula  SELECT 233,11,'Disp_RetailerCategoryLevel','Retailer Category Level',1,0
INSERT INTO RptFormula  SELECT 233,12,'Fill_CategoryLevel','ProductCategoryLevel',1,29
INSERT INTO RptFormula  SELECT 233,13,'Disp_RetailerCategory','Retailer Category Level Value',1,0
INSERT INTO RptFormula  SELECT 233,14,'Fill_CategoryValue','ProductCategoryLevelValue',1,30
INSERT INTO RptFormula  SELECT 233,15,'Disp_RetailerValueClass','Retailer Value Classification',1,0
INSERT INTO RptFormula  SELECT 233,16,'Fill_RetailerValueClass','Value Classification',1,31
INSERT INTO RptFormula  SELECT 233,17,'Disp_IssueRefNo','Sample Issue Ref.Number',1,0
INSERT INTO RptFormula  SELECT 233,18,'Fill_IssueRefNo','Sample Issue Ref.Number',1,216
INSERT INTO RptFormula  SELECT 233,19,'Disp_BillRefNo','Bill Reference Number',1,0
INSERT INTO RptFormula  SELECT 233,20,'Fill_BillRefNo','Bill Reference Number',1,34
INSERT INTO RptFormula  SELECT 233,21,'Disp_IssueStatus','Sample Issue Status',1,0
INSERT INTO RptFormula  SELECT 233,22,'Fill_IssueStatus','Sample Issue Status',1,275
INSERT INTO RptFormula  SELECT 233,23,'Disp_RtrCode','Retailer Code',1,0
INSERT INTO RptFormula  SELECT 233,24,'Disp_RetailerName','Retailer Name',1,0
INSERT INTO RptFormula  SELECT 233,25,'Disp_SampleIssueRefNo','Sample Issue Ref. Number',1,0
INSERT INTO RptFormula  SELECT 233,26,'Disp_Date','Issue Date',1,0
INSERT INTO RptFormula  SELECT 233,27,'Disp_BillNo','Bill Ref.No',1,0
INSERT INTO RptFormula  SELECT 233,28,'Disp_SampleScheme','Sample Scheme',1,0
INSERT INTO RptFormula  SELECT 233,29,'Disp_SampleSKU','Sample SKU',1,0
INSERT INTO RptFormula  SELECT 233,30,'Disp_IssueQty','Issue Quantity',1,0
INSERT INTO RptFormula  SELECT 233,31,'Disp_UOM','UOM',1,0
INSERT INTO RptFormula  SELECT 233,32,'Disp_Qty','Qty',1,0
INSERT INTO RptFormula  SELECT 233,33,'Disp_Status','Status',1,0
INSERT INTO RptFormula  SELECT 233,34,'Disp_Returnable','Returnable',1,0
INSERT INTO RptFormula  SELECT 233,35,'Disp_DueDate','Due Date',1,0
INSERT INTO RptFormula  SELECT 233,36,'Cap Page','Page',1,0
INSERT INTO RptFormula  SELECT 233,37,'Cap User Name','User Name',1,0
INSERT INTO RptFormula  SELECT 233,38,'Cap Print Date','Date',1,0
INSERT INTO RptFormula  SELECT 233,39,'Disp_Retailer','Salon',1,0
INSERT INTO RptFormula  SELECT 233,40,'Fill_Retailer','Salon',1,3
INSERT INTO RptFormula  SELECT 233,41,'Disp_Code','Product Code',1,0
INSERT INTO RptFormula  SELECT 233,42,'Disp_MRP','MRP',1,0
INSERT INTO RptFormula  SELECT 233,43,'Disp_Reason','Reason',1,0
INSERT INTO RptFormula  SELECT 233,44,'Disp_ProductCategoryLevel','Product Category Level',1,0
INSERT INTO RptFormula  SELECT 233,45,'Disp_ProductCategoryValue','Product Category Level Value',1,0
INSERT INTO RptFormula  SELECT 233,46,'Disp_Product','Product',1,0
INSERT INTO RptFormula  SELECT 233,47,'Fill_ProductCategoryLevel','ProductCategoryLevel',1,16
INSERT INTO RptFormula  SELECT 233,48,'Fill_ProductCategoryValue','ProductCategoryLevelValue',1,21
INSERT INTO RptFormula  SELECT 233,49,'Fill_Product','Product',1,5
INSERT INTO RptFormula  SELECT 233,50,'Disp_ReasonHd','Reason',1,0
INSERT INTO RptFormula  SELECT 233,51,'Fill_ReasonHd','Reason',1,159
INSERT INTO RptFormula  SELECT 233,52,'Disp_BasedOn','Based On',1,0
INSERT INTO RptFormula  SELECT 233,53,'Fill_BasedOn','Based On',1,276
GO
Delete From RptFilter where RptId=233
GO
INSERT INTO RptFilter SELECT 233,275,0,'ALL'
INSERT INTO RptFilter SELECT 233,275,1,'Pending'
INSERT INTO RptFilter SELECT 233,275,4,'Confirmed'
INSERT INTO RptFilter SELECT 233,275,3,'Deleted'
INSERT INTO RptFilter SELECT 233,276,1,'Distributor Code'
INSERT INTO RptFilter SELECT 233,276,2,'Company Code'
GO
Delete from RptExcelHeaders where Rptid=233
GO
INSERT INTO RptExcelHeaders SELECT 233,1,'RtrCode','Retailer Code',1,1
INSERT INTO RptExcelHeaders SELECT 233,2,'RtrName','Retailer Name',1,1
INSERT INTO RptExcelHeaders SELECT 233,3,'IssueRefNo','IssueRef.No',1,1
INSERT INTO RptExcelHeaders SELECT 233,4,'IssueDate','Issue Date',1,1
INSERT INTO RptExcelHeaders SELECT 233,5,'BillRefNo','Bill Ref.No',0,1
INSERT INTO RptExcelHeaders SELECT 233,6,'SchemeCode','Sample Scheme Code',0,1
INSERT INTO RptExcelHeaders SELECT 233,7,'PrdDCode','Product Code',1,1
INSERT INTO RptExcelHeaders SELECT 233,8,'SKUName','SKU Name',1,1
INSERT INTO RptExcelHeaders SELECT 233,9,'MRP','MRP',1,1
INSERT INTO RptExcelHeaders SELECT 233,10,'UOM','UOM',1,1
INSERT INTO RptExcelHeaders SELECT 233,11,'Qty','Quantity',1,1
INSERT INTO RptExcelHeaders SELECT 233,12,'Status','Status',1,1
INSERT INTO RptExcelHeaders SELECT 233,13,'Returnable','Returnable',1,1
INSERT INTO RptExcelHeaders SELECT 233,14,'DueDate','Due Date',1,1
INSERT INTO RptExcelHeaders SELECT 233,15,'PrdId','PrdId',0,1
INSERT INTO RptExcelHeaders SELECT 233,16,'UserId','UserId',0,1
GO
Delete from RptSelectionHd where SelcId IN (275,276)
GO
INSERT INTO RptSelectionHd
SELECT 275,'Sel_IssueStauts','RptFilter',''
UNION
SELECT 276,'Sel_DispCode','RptFilter',''
GO
Delete From RptExcelHeaders Where Rptid = 23										
Insert Into RptExcelHeaders Select 	23,	1,	'CmpId',	'CmpId',	0,	1
Insert Into RptExcelHeaders Select 	23,	2,	'CmpName',	'Company',	1,	1
Insert Into RptExcelHeaders Select 	23,	3,	'PurRcptId',	'PurRcptId',	1,	1
Insert Into RptExcelHeaders Select 	23,	4,	'PurRcptRefNo',	'GRN Number',	1,	1
Insert Into RptExcelHeaders Select 	23,	5,	'InvDate',	'GRN Date',	1,	1
Insert Into RptExcelHeaders Select 	23,	6,	'CmpInvNo',	'Company Invoice Number',	1,	1
Insert Into RptExcelHeaders Select 	23,	7,	'CmpInvDate',	'Company Invoice Date',	1,	1
Insert Into RptExcelHeaders Select 	23,	8,	'UsrId',	'UsrId',	0,	1
Insert Into RptExcelHeaders Select 	23,	9,	'[Gross Amount]',	'Gross Amount',	1,	1
Insert Into RptExcelHeaders Select 	23,	10,	'[Scheme Disc.]',	'Scheme Disc.',	1,	1
Insert Into RptExcelHeaders Select 	23,	11,	'[Other Charges Addition]',	'Other Charges Addition',	1,	1
Insert Into RptExcelHeaders Select 	23,	12,	'[Disc]',	'Disc',	1,	1
Insert Into RptExcelHeaders Select 	23,	13,	'[Tax]',	'Tax',	1,	1
Insert Into RptExcelHeaders Select 	23,	14,	'[Qty in Kg]',	'Qty in Kg',	1,	1
Insert Into RptExcelHeaders Select 	23,	15,	'[Net Amt.]',	'Net Amt.',	1,	1
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_RptDatewiseProductwiseSales')
DROP PROCEDURE Proc_RptDatewiseProductwiseSales
GO
--Exec Proc_RptDatewiseProductwiseSales 150,1,0,'',0,0,0
CREATE PROCEDURE [dbo].[Proc_RptDatewiseProductwiseSales]
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
BEGIN
SET NOCOUNT ON
/***************************************************
* PROCEDURE: Proc_RptDatewiseProductwiseSales
* PURPOSE: General Procedure
* NOTES:
* CREATED: Mahalakshmi.A	31-07-2008
* MODIFIED
* DATE          AUTHOR				DESCRIPTION
-----------------------------------------------------
* 07.08.2009    Panneerselvam.K		BugNo : 20207
*****************************************************/
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @sSql		AS 	nVarChar(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @CmpId			AS	INT
	DECLARE @LcnId			AS	INT
	DECLARE @PrdBatId		AS	INT
	DECLARE @PrdId			AS	INT
	DECLARE @CmpPrdCtgId		AS	INT
	DECLARE @CancelStatus		AS	INT
	DECLARE @ExcelFlag		AS	INT
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @PrdBatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
	SET @CancelStatus = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,193,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @CmpPrdCtgId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	CREATE     TABLE #RptDatewiseProductwiseSales
	(
		SalId				INT,
		SalInvDate			DATETIME,
		PrdId				INT,
		PrdCode				NVARCHAR(50),
		PrdName				NVARCHAR(200),
		PrdBatId			INT,
		PrdBatCode			NVARCHAR(50),
		SellingRate			NUMERIC (38,6),
		BaseQty				INT,
		FreeQty				INT,
		GrossAmount			NUMERIC (38,6),
		SplDiscAmount		NUMERIC (38,6),
		SchDiscAmount		NUMERIC (38,6),
		DBDiscAmount		NUMERIC (38,6),
		CDDiscAmount		NUMERIC (38,6),
		TaxAmount			NUMERIC (38,6),
		NetAmount			NUMERIC(38,6)		
	)
	SET @TblName = 'RptDatewiseProductwiseSales'
		SET @TblStruct = 'SalId			INT,
		SalInvDate		DATETIME,
		PrdId			INT,
		PrdCode			NVARCHAR(50),
		PrdName			NVARCHAR(200),
		PrdBatId			INT,
		PrdBatCode		NVARCHAR(50),
		SellingRate		NUMERIC (38,6),
		BaseQty			INT,
		FreeQty			INT,
		GrossAmount		NUMERIC (38,6),
		SplDiscAmount		NUMERIC (38,6),
		SchDiscAmount		NUMERIC (38,6),
		DBDiscAmount		NUMERIC (38,6),
		CDDiscAmount		NUMERIC (38,6),
		TaxAmount		NUMERIC (38,6),
		NetAmount		NUMERIC(38,6)'
	SET @TblFields = 'SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate,BaseQty,FreeQty,
					  GrossAmount,SplDiscAmount,SchDiscAmount,DBDiscAmount,CDDiscAmount,TaxAmount,NetAmount'
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
	--SET @Po_Errno = 0
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		EXEC Proc_DatewiseProductwiseSales @Pi_RptId,@FromDate,@ToDate,@CmpId,@CmpPrdCtgId,@PrdId,@LcnId,@PrdBatId,@Pi_UsrId
		
		IF @CancelStatus=1 	--'NO'
		BEGIN	
			INSERT INTO #RptDatewiseProductwiseSales (SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate,
			BaseQty,FreeQty,GrossAmount,SplDiscAmount,SchDiscAmount,DBDiscAmount,CDDiscAmount,TaxAmount,NetAmount)			
			SELECT SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate,SUM(BaseQty),SUM(FreeQty),
			SUM(GrossAmount),SUM(SplDiscAmount),SUM(SchDiscAmount),SUM(DBDiscAmount),SUM(CDDiscAmount),SUM(TaxAmount),SUM(NetAmount)
			FROM TempDatewiseProductwiseSales
			WHERE DlvSts NOT IN(3)						
			GROUP BY SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate Order by SalInvDate
		END
		ELSE
		BEGIN	
			INSERT INTO #RptDatewiseProductwiseSales (SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate,
			BaseQty,FreeQty,GrossAmount,SplDiscAmount,SchDiscAmount,DBDiscAmount,CDDiscAmount,TaxAmount,NetAmount)			
			SELECT SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate,SUM(BaseQty),SUM(FreeQty),
			SUM(GrossAmount),SUM(SplDiscAmount),SUM(SchDiscAmount),SUM(DBDiscAmount),SUM(CDDiscAmount),SUM(TaxAmount),SUM(NetAmount)
			FROM TempDatewiseProductwiseSales			
			GROUP BY SalId,SalInvDate,PrdId,PrdCode,PrdName,PrdBatId,PrdBatCode,SellingRate Order by SalInvDate
		END
		
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptDatewiseProductwiseSales ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +
				' CmpId IN (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
				+ ' PrdId = (CASE ' + CAST(@CmpPrdCtgId AS nVarchar(10)) + ' WHEN 0 THEN PrdId ELSE 0 END) OR ' +
				' PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND '
				+ 'AND PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN PrdId ELSE 0 END) OR ' +
				'PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND SalInvDate BETWEEN @FromDate AND @ToDate'
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptDatewiseProductwiseSales'
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
			SET @SSQL = 'INSERT INTO #RptDatewiseProductwiseSales ' +
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
	DELETE FROM RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptDatewiseProductwiseSales
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptDatewiseProductwiseSales_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptDatewiseProductwiseSales_Excel
		SELECT  * INTO RptDatewiseProductwiseSales_Excel FROM #RptDatewiseProductwiseSales Order by SalId
	END 
	SELECT * FROM #RptDatewiseProductwiseSales 
	RETURN
END
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'Proc_RptPendingBillReport')
DROP PROCEDURE Proc_RptPendingBillReport
GO
--EXEC Proc_RptPendingBillReport 3,2,0,'Dabur1',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptPendingBillReport]
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
            Cash            NUMERIC (38,6),
            ChequeAmt       NUMERIC (38,6),
            ChequeNo        NUMERIC (38,6),  
			CollectedAmount NUMERIC (38,6),
			BalanceAmount   NUMERIC (38,6),
			ArDays			INT
		)
		INSERT INTO RptPendingBillsDetails_Excel(SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,
			  SalInvDate,SalInvRef,BillAmount,Cash,ChequeAmt,ChequeNo,CollectedAmount,
			  BalanceAmount,ArDays)
		  SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,SalId,SalInvNo,
			  SalInvDate,SalInvRef,BillAmount,'0.00','0.00','0.00',Isnull(CollectedAmount,0),
			  BalanceAmount,ArDays FROM  #RptPendingBillsDetails	
	   
		UPDATE RPT SET RPT.[RtrCode]=R.RtrCode FROM RptPendingBillsDetails_Excel RPT,Retailer R WHERE RPT.[RtrName]=R.RtrName
	END
	RETURN
END
GO
Delete From RptExcelHeaders Where Rptid = 3						
Insert into RptExcelHeaders Select 	3,	1,	'SMId',	'SMId',	0,	1
Insert into RptExcelHeaders Select 	3,	2,	'SMName',	'Salesman',	1,	1
Insert into RptExcelHeaders Select 	3,	3,	'RMId',	'RMId',	0,	1
Insert into RptExcelHeaders Select 	3,	4,	'RMName',	'Route',	1,	1
Insert into RptExcelHeaders Select 	3,	5,	'RtrId',	'RtrId',	0,	1
Insert into RptExcelHeaders Select 	3,	6,	'RtrCode',	'Retailer Code',	1,	1
Insert into RptExcelHeaders Select 	3,	7,	'RtrName',	'Retailer',	1,	1
Insert into RptExcelHeaders Select 	3,	8,	'SalId',	'SalId',	0,	1
Insert into RptExcelHeaders Select 	3,	9,	'SalInvNo',	'Bill Number',	1,	1
Insert into RptExcelHeaders Select 	3,	10,	'SalInvDate',	'Bill Date',	1,	1
Insert into RptExcelHeaders Select 	3,	11,	'SalInvRef',	'Doc Ref No',	0,	1
Insert into RptExcelHeaders Select 	3,	12,	'BillAmount',	'Bill Amount',	1,	1
Insert into RptExcelHeaders Select 	3,	13,	'Cash',	'Cash',	1,	1
Insert into RptExcelHeaders Select 	3,	14,	'ChequeAmt',	'ChequeAmt',	1,	1
Insert into RptExcelHeaders Select 	3,	15,	'ChequeNo',	'ChequeNo',	1,	1
Insert into RptExcelHeaders Select 	3,	16,	'CollectedAmount',	'Collected Amount',	1,	1
Insert into RptExcelHeaders Select 	3,	17,	'BalanceAmount',	'Balance Amount',	1,	1
Insert into RptExcelHeaders Select 	3,	18,	'ArDays',	'AR Days',	1,	1
GO
IF EXISTS (Select * From Sysobjects Where Xtype = 'P' And Name = 'Proc_RptSalesVatReport')
DROP PROCEDURE Proc_RptSalesVatReport
GO
--Exec Proc_RptSalesVatReport 232,2,0,'',0,0,0
CREATE PROCEDURE [dbo].[Proc_RptSalesVatReport]
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
/*******************************************************************************************************
* VIEW	: Proc_RptSalesVatReport
* PURPOSE	: To get sales tax Details
* CREATED BY	: Karthick.K.J
* CREATED DATE	: 25/05/2011
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------------------------------
* {date} {developer}  {brief modification description}	
********************************************************************************************************/
BEGIN
	SET NOCOUNT ON
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @CmpId 		AS	INT
	DECLARE @InvoiceType AS  INT 
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @InvoiceType=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,274,@Pi_UsrId))
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
		EXEC Proc_SalesTaxSummary @FromDate,@ToDate,@Pi_UsrId,@InvoiceType,@CmpId
		INSERT INTO TempRptSalestaxsumamry 
		  SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId,
			   'Cash Discount',(cashDiscount),IOTaxType,4 TaxFlag,0 TaxPercent,0 TaxId,7,UserId 
		 FROM TempRptSalestaxsumamry   
		 GROUP BY InvId,RefNo,InvDate,RtrId,RtrName,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId, 
		 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId,RtrTINNo
		 UNION ALL  
		 SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId,
			   'Visibility Amount',(visibilityAmount),IOTaxType,5 TaxFlag,0 TaxPercent,0 TaxId,8,UserId 
		 FROM TempRptSalestaxsumamry   
		 GROUP BY InvId,RefNo,InvDate,RtrId,RtrName,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId, 
		 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId,RtrTINNo
	UNION ALL
		 SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId,
			   'Net Amount',(NetAmount),IOTaxType,6 TaxFlag,0 TaxPercent,0 TaxId,9,UserId 
		 FROM TempRptSalestaxsumamry   
		 GROUP BY InvId,RefNo,InvDate,RtrId,RtrName,GrossAmount,cashDiscount,visibilityAmount,NetAmount,CmpId, 
		 IOTaxType,TaxFlag,TaxPercent,TaxId,UserId,RtrTINNo
	END 
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM TempRptSalestaxsumamry  
  DECLARE  @InvId BIGINT  
  DECLARE  @RefNo NVARCHAR(100)  
  DECLARE  @PurRcptRefNo NVARCHAR(50)  
  DECLARE  @TaxPerc   NVARCHAR(100)  
  DECLARE  @TaxableAmount NUMERIC(38,6)  
  DECLARE  @IOTaxType    NVARCHAR(100)  
  DECLARE  @SlNo INT    
  DECLARE  @TaxFlag      INT  
  DECLARE  @Column VARCHAR(80)  
  DECLARE  @C_SSQL VARCHAR(4000)  
  DECLARE  @iCnt INT  
  DECLARE  @TaxPercent NUMERIC(38,6)  
  DECLARE  @Name   NVARCHAR(100)  
  DECLARE  @RtrId INT  
  DECLARE  @ColNo INT  
  --DROP TABLE [RptSalesVatDetails_Excel]  
  IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSalesVatDetails_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
  DROP TABLE RptSalesVatDetails_Excel  
  DELETE FROM RptExcelHeaders Where RptId=232 AND SlNo>7  
  CREATE TABLE RptSalesVatDetails_Excel (
				InvId BIGINT,RefNo NVARCHAR(100),InvDate DATETIME,
				RtrId INT,RtrName NVARCHAR(100),RtrTINNo NVARCHAR(100),UsrId INT)  
  SET @iCnt=8  

	DELETE FROM RptExcelHeaders WHERE RptId=232
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	1,	'InvId',	'InvId',	0,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	2,	'RefNo',	'Bill No',	1,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	3,	'InvDate',	'Bill Date',	1,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	4,	'RtrId',	'RtrId',	0,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	5,	'RtrName',	'Retailer Name',	1,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	6,	'RtrTINNo',	'RtrTINNo',	1,	1)
	INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)
	VALUES(232,	7,	'UsrId',	'UsrId',	0,	1)

	 IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'TempRptSalestaxsumamry1') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
	 DROP TABLE TempRptSalestaxsumamry1  
		CREATE TABLE TempRptSalestaxsumamry1 (
				TaxPerc VARCHAR(100),TaxPercent NUMERIC(38,2),
				TaxFlag INT)  
	INSERT INTO TempRptSalestaxsumamry1
	SELECT DISTINCT TaxPerc,TaxPercent,TaxFlag FROM TempRptSalestaxsumamry 

	SELECT DISTINCT TaxPerc,TaxPercent,TaxFlag INTO #TempRptSalestaxsumamry FROM TempRptSalestaxsumamry  --ORDER BY ColNo,TaxFlag,TaxPercent

  DECLARE Column_Cur CURSOR FOR  
  SELECT  TaxPerc,TaxPercent,TaxFlag FROM #TempRptSalestaxsumamry  ORDER BY  TaxFlag,TaxPercent DESC
  OPEN Column_Cur  
      FETCH NEXT FROM Column_Cur INTO @Column,@SlNo,@TaxFlag
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='ALTER TABLE RptSalesVatDetails_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'  
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
  DELETE FROM RptSalesVatDetails_Excel  
  INSERT INTO RptSalesVatDetails_Excel(InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,UsrId)  
  SELECT DISTINCT InvId,RefNo,InvDate,RtrId,RtrName,RtrTINNo,@Pi_UsrId  
    FROM TempRptSalestaxsumamry  
  --Select * from [RptSalesVatDetails_Excel]  
  DECLARE Values_Cur CURSOR FOR  
  SELECT DISTINCT InvId,RefNo,RtrId,TaxPerc,TaxableAmount FROM TempRptSalestaxsumamry  
  OPEN Values_Cur  
      FETCH NEXT FROM Values_Cur INTO @InvId,@RefNo,@RtrId,@TaxPerc,@TaxableAmount  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='UPDATE RptSalesVatDetails_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))  
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
  SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptSalesVatDetails_Excel]')  
  OPEN NullCursor_Cur  
      FETCH NEXT FROM NullCursor_Cur INTO @Name  
      WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @C_SSQL='UPDATE RptSalesVatDetails_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))  
     SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''  
     EXEC (@C_SSQL)  
     PRINT @C_SSQL  
     FETCH NEXT FROM NullCursor_Cur INTO @Name  
    END  
  CLOSE NullCursor_Cur  
  DEALLOCATE NullCursor_Cur  
select * from TempRptSalestaxsumamry
RETURN  
END 
GO
Delete From RptDetails Where RptId=233
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	1,	'FromDate',	-1,	NULL,	'',	'From Date*',	'',	1,	'',	10,	0,	0,	'Enter From Date',0)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	2,	'ToDate',	-1,	NULL,	'',	'To Date*',	'',	1,	'',	11,	0,	0,	'Enter To Date',	0)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	3,	'Company',	-1,	NULL,	'CmpId,CmpCode,CmpName',	'Company…',	'',	1,	'',	4,	1,	0,	'Press F4/Double Click to select Company',	0)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	4,	'Salesman',	-1,	NULL,	'SMId,SMCode,SMName',	'Salesman…',	'',	1,	'',	1,	0,	0,	'Press F4/Double Click to select Salesman',	0)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	5,	'RouteMaster',	-1,	NULL,	'RMId,RMCode,RMName',	'Route…',	'',	1,	'',	2,	0,	0,	'Press F4/Double Click to select Route',	0)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	6,	'RetailerCategoryLevel',	3,	'CmpId',	'CtgLevelId,CtgLevelName,CtgLevelName',	'Retailer Category Level…',	'Company',	1,	'CmpId',	29,	1,	0,	'Press F4/Double Click to select Category Level',	1)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	7,	'RetailerCategory',	6,	'CtgLevelID',	'CtgMainId,CtgCode,CtgName',	'Retailer Category Level Value…',	'RetailerCategoryLevel',	1,	'CtgLevelId',	30,	1,	0,	'Press F4/Double Click to select Category Level Value',	1)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	8,	'RetailerValueClass',	7,	'CtgMainID',	'RtrClassID,ValueClassCode,ValueClassName',	'Retailer Value Classification…',	'RetailerCategory',	1,	'CtgMainId',	31,	1,	0,	'Press F4/Double Click to select Value Classification',	1)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	9,	'Retailer',	-1,	NULL,	'RtrID,RtrCode,RtrName',	'Retailer…',	'',	1,	'',	3,	0,	0,	'Press F4/Double Click to select Retailer',	0)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	10,	'FreeIssueHd',	-1,	NULL,	'IssueId,IssueRefNo,IssueRefNo',	'Sample Issue Ref No…',	'',	1,	'',	220,	0,	0,	'Press F4/Double click to select Sample Issue Ref No',	0)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	11,	'SalesInvoice',	-1,	NULL,	'SalId,SalInvNo,SalInvNo',	'Bill Reference Number…',	'',	1,	'',	34,	0,	0,	'Press F4/Double Click to select Bill Reference Number',	0)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	12,	'ProductCategoryLevel',	3,	'CmpId',	'CmpPrdCtgId,CmpPrdCtgName,LevelName',	'Product Hierarchy Level…',	'Company',	1,	'CmpId',	16,	1,	0,	'Press F4/Double Click to select Product Hierarchy Level',	0)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	13,	'ProductCategoryValue',	12,	'CmpPrdCtgId',	'PrdCtgValMainId,PrdCtgValCode,PrdCtgValName',	'Product Hierarchy Level Value…',	'ProductCategoryLevel',	1,	'CmpPrdCtgId',	21,	0,	0,	'Press F4/Double Click to select Product Hierarchy Level Value',	0)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	14,	'Product',	13,	'PrdCtgValMainId',	'PrdId,PrdDCode,PrdName',	'Product…',	'ProductCategoryValue',	1,	'PrdCtgValMainId',	5,	0,	0,	'Press F4/Double Click to select Product',	0)
Insert Into RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
Values(233,	15,	'RptFilter',	-1,	'',	'FilterId,FilterDesc,FilterDesc',	'Based On *…',	'',	1,	'',	276,	1,	1,	'Press F4/Double Click to Select Report Based on',	0)
GO
IF EXISTS ( Select * from Sysobjects where Xtype = 'P' And Name = 'Proc_SampleIssue')
DROP PROCEDURE Proc_SampleIssue
GO
-- EXEC Proc_SampleIssue 159,2,'2010/03/15','2011/12/22'
CREATE  PROCEDURE [dbo].[Proc_SampleIssue]
(
	@Pi_RptId		INT,
	@Pi_UserId		INT,
	@FromDate       DateTime,
	@ToDate			DateTime
)
AS
BEGIN
/****************************************************************************
* PROCEDURE: Proc_SampleIssue
* PURPOSE:Display the Sample Issue Products
* NOTES:
* CREATED: Mahalakshmi.A
* ON DATE: 02-12-2008
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
-------------------------------------------------------------------------------
* 16.02.2010	Panneer				Added Date Filter
* 22.12.2011	VIjendra Kumar		Added for Sample Issue Rule setting
*****************************************************************************/
SET NOCOUNT ON
	DELETE FROM TempSampleIssue 
	INSERT INTO TempSampleIssue (IssueId,IssueRefNo,CmpId,SMId,RMId,CtgLevelId,CtgMainID,RtrClassId,
								RtrId,RtrCode,RtrName,IssueDate,SalId,SalInvNo,SchId,SchCode,SKUPrdId,SKUName,
								UomId,UomCode,UomQty,UomConvFact,UomBaseQty,
								IssueStatus,DlvSts,DlvStsDesc ,Returnable,DueDate,RptID,UsrId)
	SELECT DISTINCT 
		A.IssueId,A.IssueRefNo,F.CmpId,A.SMId,A.RMId,J.CTGLEVELID,
		I.CTGMAINID,H.RtrValueClassId AS RtrClassId,
		A.RtrId,D.RtrCode,D.RtrName,A.IssueDate,
		A.SalId,C.SalInvNo,0,'',B.PrdId,F.PrdName,
		B.IssueUomId,G.UomCode,B.IssueQty,B.IssueConFact,B.IssueBaseQty,A.Status,
		ISNULL(C.DlvSts,CASE (A.Status)WHEN 0 THEN A.Status+1 WHEN 1 THEN A.Status+3 END ),
		CASE ISNULL(C.DlvSts,CASE (A.Status)WHEN 0 THEN A.Status+1 WHEN 1 THEN A.Status+3 END)
		WHEN 4 THEN 'Confirmed'
		WHEN 5 THEN 'Confirmed'
		WHEN 3 THEN 'Deleted'
		WHEN 1 THEN 'Pending' END,
		CASE B.TobeReturned WHEN 0 THEN 'NO' ELSE 'YES' END AS TobeReturned,B.DueDate,@Pi_RptId,@Pi_UserId
		FROM FreeIssueHd A WITH (NOLOCK)
		INNER JOIN FreeIssueDt B WITH (NOLOCK) ON A.IssueId= B.IssueId
		LEFT OUTER JOIN SalesInvoice C WITH (NOLOCK) ON A.SalId=C.SalId
--		INNER JOIN SampleIssueHd SIH ON SIH.SalId=A.SalId
		INNER JOIN Retailer D WITH (NOLOCK) ON A.RtrId=D.RtrId
		INNER JOIN Product F WITH(NOLOCK) ON B.PrdID=F.PrdID
		INNER JOIN UomMaster G WITH(NOLOCk) ON B.IssueUomId=G.UomId
		INNER JOIN RETAILERVALUECLASSMAP H ON H.RtrId=D.RtrId
		INNER JOIN RETAILERVALUECLASS I ON I.RtrClassId=H.RtrValueClassId
		INNER JOIN RetailerCategory J ON J.CtgMainId=I.CtgMainId
		WHERE  IssueDate Between @FromDate and @ToDate

	UNION ALL
		SELECT DISTINCT 
		A.IssueId,A.IssueRefNo,F.CmpId,A.SMId,A.RMId,J.CTGLEVELID,
		I.CTGMAINID,H.RtrValueClassId AS RtrClassId,
		A.RtrId,D.RtrCode,D.RtrName,A.IssueDate,
		A.SalId,C.SalInvNo,0,'',B.PrdId,F.PrdName,
		B.IssueUomId,G.UomCode,B.IssueQty,B.IssueConFact,B.IssueBaseQty,A.Status,
		ISNULL(C.DlvSts,CASE (A.Status)WHEN 0 THEN A.Status+1 WHEN 1 THEN A.Status+3 END ),
		CASE ISNULL(C.DlvSts,CASE (A.Status)WHEN 0 THEN A.Status+1 WHEN 1 THEN A.Status+3 END)
		WHEN 4 THEN 'Confirmed'
		WHEN 5 THEN 'Confirmed'
		WHEN 3 THEN 'Deleted'
		WHEN 1 THEN 'Pending' END,
		CASE B.TobeReturned WHEN 0 THEN 'NO' ELSE 'YES' END AS TobeReturned,B.DueDate,@Pi_RptId,@Pi_UserId
		FROM SampleIssueHd A WITH (NOLOCK)
		INNER JOIN SampleIssueDt B WITH (NOLOCK) ON A.IssueId= B.IssueId
		LEFT OUTER JOIN SalesInvoice C WITH (NOLOCK) ON A.SalId=C.SalId
--		INNER JOIN SampleIssueHd SIH ON SIH.SalId=A.SalId
		INNER JOIN Retailer D WITH (NOLOCK) ON A.RtrId=D.RtrId
		INNER JOIN Product F WITH(NOLOCK) ON B.PrdID=F.PrdID
		INNER JOIN UomMaster G WITH(NOLOCk) ON B.IssueUomId=G.UomId
		INNER JOIN RETAILERVALUECLASSMAP H ON H.RtrId=D.RtrId
		INNER JOIN RETAILERVALUECLASS I ON I.RtrClassId=H.RtrValueClassId
		INNER JOIN RetailerCategory J ON J.CtgMainId=I.CtgMainId
		WHERE  IssueDate Between @FromDate and @ToDate
END
GO
if not exists (select * from hotfixlog where fixid = 396)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(396,'D','2011-11-22',getdate(),1,'Core Stocky Service Pack 396')
GO