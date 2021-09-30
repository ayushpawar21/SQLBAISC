--[Stocky HotFix Version]=392
Delete from Versioncontrol where Hotfixid='392'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('392','2.0.0.5','D','2011-10-18','2011-10-18','2011-10-18',convert(varchar(11),getdate()),'Major: Product Release')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 392' ,'392'
GO
INSERT INTO SchemeRetAttr
SELECT DISTINCT SchId,21,0,1,1,GETDATE(),1,GETDATE() FROM SchemeRetAttr WHERE SchId NOT IN 
(SELECT DISTINCT SchId FROM SchemeRetAttr WHERE AttrType=21)
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_ApplyQPSSchemeInBill')
DROP PROCEDURE  Proc_ApplyQPSSchemeInBill
GO
/*
	BEGIN TRANSACTION
	DELETE FROM BillAppliedSchemeHd
	EXEC Proc_ApplyQPSSchemeInBill 35,137,0,1,2
	SELECT * FROM BillAppliedSchemeHd
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

SELECT 'ere',* FROM BillAppliedSchemeHd
		
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
--	IF EXISTS (SELECT A.PrdBatId FROM StockLedger A LEFT OUTER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--	AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
--	AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId
--	AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0)
--	BEGIN
--		UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
--		PrdId IN (
--			SELECT A.PrdId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
--		PrdBatId NOT IN (
--			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
--		(FreeToBeGiven+GiftToBeGiven) > 0 AND FlexiSch<>1
--		AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
--	END
--	ELSE
--	BEGIN
--		INSERT INTO @MoreBatch SELECT SchId,SlabId,PrdId,COUNT(DISTINCT PrdId),
--			COUNT(DISTINCT PrdBatId) FROM BillAppliedSchemeHd
--			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId GROUP BY SchId,SlabId,PrdId
--			HAVING COUNT(DISTINCT PrdBatId)> 1
--		IF EXISTS (SELECT * FROM @MoreBatch WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
--		BEGIN
--			INSERT INTO @TempBillAppliedSchemeHd
--			SELECT A.* FROM BillAppliedSchemeHd A INNER JOIN @MoreBatch B
--			ON A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.PrdId=B.PrdId
--			WHERE A.SchId=@Pi_SchId AND A.SlabId=@SlabId
--			AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND A.FlexiSch<>1
--			AND A.PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
--			WHERE SchCode=@SchCode AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
--			UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
--			PrdId IN (SELECT PrdId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId) AND
--			PrdBatId IN (SELECT PrdBatId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
--			AND SchemeAmount =0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
--		END
--	END
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
--	AND A.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)

--DECLARE @TotalSchAmt	NUMERIC(38,6)
--	
--	SELECT @TotalSchAmt= SUM(SchemeAmount) FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND SchId=@Pi_SchId
--((@TotalSchAmt-Amount)*((SchemeAmount/@TotalSchAmt)*100)/100) --

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

--	SELECT DISTINCT * INTO #BillAppliedSchemeHd  FROM BillAppliedSchemeHd
--	WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId
----	IF @QPS=1 and @QPSReset=0
----	BEGIN
--		DELETE FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND SchId=@Pi_SchId
--		INSERT INTO BillAppliedSchemeHd
--		SELECT A.* FROM #BillAppliedSchemeHd A 
----		INNER JOIN BilledPrdHdForScheme B ON A.TransId=B.TransId AND 
----		A.UsrId=B.UsrId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
--		WHERE 
----		B.RtrId=@Pi_RtrId AND
--		A.SchId=@Pi_SchId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
--	END
	--->Till Here
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnBillSchemeDetails]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnBillSchemeDetails]
GO
CREATE  FUNCTION [dbo].[Fn_ReturnBillSchemeDetails] (@Pi_UserId AS INT,@Pi_TransId AS INT)
RETURNS @ReturnBillSchemeDetails TABLE
	(
		SchId			INT,
		SchCode			VARCHAR(50),
		FlexiSch		INT,
		FlexiSchType	INT,
		SlabId			INT,
        SchemeAmount	NUMERIC(18,6),
		SchemeDiscount	NUMERIC(18,2),
		Points			INT,
		FlxDisc			INT,
        FlxValueDisc	INT,
		FlxFreePrd		INT,
		FlxGiftPrd		INT,
		FreePrdId		INT,
		FreePrdBatId	INT,
        FreeToBeGiven	INT,
		EditScheme		INT,
		NoOfTimes		NUMERIC(18,6),
		Usrid			INT,
		FlxPoints		INT,
        GiftPrdId		INT,
		GiftPrdBatId	INT,
		GiftToBeGiven	INT,
		SchType			INT
	)
AS
/*********************************
* FUNCTION: Fn_ReturnBillSchemeDetails
* PURPOSE: Return Billed Scheme Details
* NOTES:
* CREATED: Boopathy.P 0n 14/07/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 06-08-2011 Boopathy.P Wrongly added prdbatid in Group by
*********************************/
BEGIN
		INSERT INTO @ReturnBillSchemeDetails
		SELECT DISTINCT A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND B.CombiSch=1 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount --ORDER BY A.SchId Asc,A.SlabId Asc
		UNION
		SELECT DISTINCT  A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND (B.FlexiSch+B.Range+B.QPS+B.QPSReset)=0 
		AND B.CombiSch=0 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,A.PrdId --ORDER BY A.SchId Asc,A.SlabId Asc
		UNION
		SELECT DISTINCT  A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, 
		SUM(A.SchemeAmount) AS SchemeAmount, CASE A.SchType WHEN 0 THEN A.SchemeDiscount 
		WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,A.FlxDisc,
		A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, 
		SUM(A.FreeToBeGiven) AS FreeToBeGiven,B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,
		A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,A.SchType  
		FROM BillAppliedSchemeHd A INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE 
		Usrid=@Pi_UserId AND TransId = @Pi_TransId AND B.CombiSch=0 AND (B.FlexiSch+B.Range+B.QPS+B.QPSReset) >0 GROUP BY A.SchId,A.SchCode,A.FlexiSch,A.FlexiSchType,
		A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd, A.FlxGiftPrd,A.FreePrdId,
		A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId ,
		A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,A.PrdId,A.PrdBatId ORDER BY A.SchId Asc,A.SlabId Asc
RETURN
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_ApportionSchemeAmountInLine')
DROP PROCEDURE  Proc_ApportionSchemeAmountInLine
GO
/*
BEGIN TRANSACTION
EXEC Proc_ApportionSchemeAmountInLine 1,2,0
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
		FreeQty   INT
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
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND QPSPrd=1 AND A.SchId=@SchId
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
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=1 AND A.SchId=@SchId
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
						CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) --Second Case Start
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
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
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
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
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

	INSERT INTO @FreeQtyDt (FreePrdid,FreePrdBatId,FreeQty)
	SELECT FreePrdId,FreePrdBatId,Sum(DISTINCT FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY FreePrdId,FreePrdBatId
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
	AND ApportionSchemeDetails.UsrId = @Pi_UsrId AND ApportionSchemeDetails.TransId = @Pi_TransId
	AND CAST(ApportionSchemeDetails.SchId AS NVARCHAR(10))+'~'+CAST(ApportionSchemeDetails.SlabId AS NVARCHAR(10)) 
	IN (SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10)) FROM BillAppliedSchemeHd WHERE FreeToBeGiven>0)
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
IF EXISTS ( Select * from Sysobjects where Xtype = 'P' And Name = 'Proc_RptTLSDReport')
DROP PROCEDURE Proc_RptTLSDReport 
GO
CREATE PROCEDURE [dbo].[Proc_RptTLSDReport]
--EXEC Proc_RptTLSDReport 54,1,0,'Claimmgt',0,0,1
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
* VIEW	: Proc_RptTLSDReport
* PURPOSE	: To get the Total Line Sold During the period
* CREATED BY	: Mahalakshmi.A
* CREATED DATE	: 12/12/2007
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
	DECLARE @SMId 		AS	INT
	DECLARE @RMId 		AS	INT
    DECLARE @RtrId 		AS	INT        
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @CtgLevelId	AS 	INT
	DECLARE @RtrClassId	AS 	INT
	DECLARE @CtgMainId 	AS 	INT
----Till Here
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
    SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @PrdCatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	---Till Here
	Create TABLE #RptTLSDReport
	(
				SmId			BIGINT,
				SmName			NVARCHAR(50),
				RmId			BIGINT,
				RmName			NVARCHAR(50),
                RtrId			BIGINT,
				RtrName			NVARCHAR(50),
	      		OutletCategory	NVARCHAR(50),
	       		OutletClass		NVARCHAR(50),
				TotalBillCuts	INT,
				TLSD			INT,
				Value			NUMERIC(38,2)
	)
	SET @TblName = 'RptTLSDReport'
	SET @TblStruct = '	SmId	BIGINT,
						SmName	NVARCHAR(50),
						RmId	BIGINT,
						RmName	NVARCHAR(50),
                        RtrId			BIGINT,
				        RtrName			NVARCHAR(50),
						OutletCategory	NVARCHAR(50),
						OutletClass		NVARCHAR(50),
						TotalBillCuts	INT,
						TLSD			INT,
						Value			NUMERIC(38,2)'
	SET @TblFields = 'SmID,SmName,RmId,RmName,OutletCategory,OutletClass,TotalBillCuts,TLSD,Value'
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
		
		INSERT INTO #RptTLSDReport (SmID,SmName,RmId,RmName,RtrId,RtrName,OutletCategory,OutletClass,TotalBillCuts,TLSD,Value)
				SELECT DISTINCT SmID,SmName,RmId,RmName,RtrId,RtrName,ctgName,valueclassname,Count(DISTINCT SalId) AS BillCuts,Count(PrdId) AS TLSD,Sum(PrdGrossAmount)
					FROM View_TLSDreport
                   
				WHERE 	(CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
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
					(RtrClassId=(CASE @RtrClassId WHEN 0 THEN RtrClassId ELSE 0 END) OR
						RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
					AND
					(CtgMainID=(CASE @CtgMainId WHEN 0 THEN ctgMainID ELSE 0 END) OR
						CtgMainID in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
                    AND
				    (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
					     RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						
						AND SalInvDate BETWEEN @FromDate AND @ToDate		
					GROUP BY SmID,SmName,RmId,RmName,RtrId,RtrName,ctgName,valueclassname
				
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptTLSDReport ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ 'WHERE BillStatus=1  AND (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
				+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + 'WHEN 0 THEN UsrId ELSE 0 END ))) '
				+ 'AND (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '
				+ 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '
				+ 'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
				+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
				+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND SalInvDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptTLSDReport'
		
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
			SET @SSQL = 'INSERT INTO #RptTLSDReport ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptTLSDReport
	-- Till Here
	SELECT * FROM #RptTLSDReport
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptTLSD_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptTLSD_Excel
		SELECT * INTO RptTLSD_Excel FROM #RptTLSDReport 
	END 
RETURN
END
GO
EXEC master.dbo.sp_configure 'show advanced options', 1
RECONFIGURE
EXEC master.dbo.sp_configure 'xp_cmdshell', 1
RECONFIGURE
GO
IF EXISTS (Select * from Sysobjects Where Xtype= 'U' And Name = 'ETL_Prk_CS2CNBLRetailer')
DROP TABLE ETL_Prk_CS2CNBLRetailer
GO
CREATE TABLE [dbo].[ETL_Prk_CS2CNBLRetailer](
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId] [int] NULL,
	[RtrCde] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrNm] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrChannelCde] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrGroupCde] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrClassCde] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KeyAccount] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RelationStatus] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrRegDate] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevel] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevelValue] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [tinyint] NULL,
    [Mode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
IF EXISTS (Select * from Sysobjects Where Xtype= 'P' And Name = 'Proc_CS2CN_BLPurchaseConfirmation')
DROP PROCEDURE Proc_CS2CN_BLPurchaseConfirmation
GO
CREATE PROCEDURE [dbo].[Proc_CS2CN_BLPurchaseConfirmation]
(
	@Po_ErrNo	INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE: Proc_CS2CNPurchaseConfirmation
* PURPOSE: Extract Purchase Confirmation Details from CoreStocky to Console
* NOTES:
* CREATED: JayaKumar.N 15-12-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
    SET @Po_ErrNo = 0
	BEGIN TRAN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DELETE FROM ETL_Prk_CS2CNBLPurchaseConfirmation WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where procId = 3
	INSERT INTO ETL_Prk_CS2CNBLPurchaseConfirmation
	(
		DistCode ,
		ComInvNo ,
		GrnNo ,
		GrnRcvDt ,
		ProdCode ,
		PrdBatCde ,
		GrnQtyRcv ,
		GRNDBRSHTQTY ,
		GRNDBRDMGQTY ,
		GRNDBREXCESSQTY ,
		GRNDREFUSESALE ,
		UploadFlag
	)
	SELECT
		@DistCode ,
		PR.CmpInvNo AS ComInvNo ,
		PR.PurRcptRefNo AS GrnNo,
		PR.GoodsRcvdDate AS GrnRcvDt ,
		P.PrdCCode AS ProdCode ,
		PB.CmpBatCode AS PrdBatCde ,
		PRP.RcvdGoodBaseQty AS GrnQtyRcv ,
		PRP.ShrtBaseQty AS GRNDBRSHTQTY ,
		PRP.UnSalBaseQty AS GRNDBRDMGQTY ,
		CASE PRP.RefuseSale WHEN 0 THEN ExsBaseQty ELSE 0 END AS GRNDBREXCESSQTY ,
		CASE PRP.RefuseSale WHEN 1 THEN ExsBaseQty ELSE 0 END AS GRNDREFUSESALE ,
		'N'					
	FROM
		PurchaseReceipt PR , 		
		PurchaseReceiptProduct PRP ,
		Product P ,
		ProductBatch PB
	WHERE
		PR.PurRcptId = PRP.PurRcptId AND
		PR.Status = 1 AND
		PR.CmpId = @CmpID AND
		P.PrdId = PB.PrdId AND
		P.PrdId = PRP.PrdId AND
		PB.PrdBatId = PRP.PrdBatId AND
		PR.Upload=0
		--PR.GoodsRcvdDate >= @ChkDate
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GetDate(),121),
		ProcDate = CONVERT(nVarChar(10),GetDate(),121)
		Where procId = 3
	UPDATE PurchaseReceipt SET Upload=1 WHERE Upload=0 AND PurRcptRefNo IN (SELECT DISTINCT
		GrnNo FROM ETL_Prk_CS2CNBLPurchaseConfirmation WHERE UploadFlag = 'N')
	COMMIT TRAN
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype= 'P' And Name = 'Proc_CS2CNDownLoadTracing')
DROP PROCEDURE Proc_CS2CNDownLoadTracing
GO
CREATE PROCEDURE [dbo].[Proc_CS2CNDownLoadTracing]
(
	@Po_ErrNo INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE: Proc_CS2CNDownLoadTracing
* PURPOSE: Extract Download Tracing details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R	 30-06-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
    SET @Po_ErrNo = 0
	BEGIN TRAN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	DELETE FROM ETL_PRK_CS2CNDownLoadTracing WHERE UploadFlag = 'Y'
	SELECT @DistCode = DistributorCode FROM Distributor
	
	INSERT INTO ETL_PRK_CS2CNDownLoadTracing
	(
			[DistCode],
			[ProcessName],
			[TotRowCount],
			[Process1],
			[Process2],
			[Process3],
			[Process4],
			[Process5],
			[Process6],
			[Process7],
			[Process8],
			[Process9],
			[ProcessPatch],
			[Date],
			[UploadFlag]
	)
	SELECT @DistCode,ProcessName,TotRowCount,Process1,Process2,Process3,Process4,
			Process5,Process6,Process7,Process8,Process9,ProcessPatch,Date,'N' AS UploadFlag
			FROM CS2Console_DownLoadTracing WITH (NOLOCK)
			WHERE UploadFlag='N'
	UPDATE CS2Console_DownLoadTracing SET UploadFlag='Y' WHERE UploadFlag='N'
	
	COMMIT TRAN
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype= 'P' And Name = 'Proc_CS2CNUpLoadTracing')
DROP PROCEDURE Proc_CS2CNUpLoadTracing
GO
CREATE PROCEDURE [dbo].[Proc_CS2CNUpLoadTracing]
(
	@Po_ErrNo INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE: Proc_CS2CNUpLoadTracing
* PURPOSE: Extract Upload Tracing details from CoreStocky to Console
* NOTES:
* CREATED: Aarthi.R	 30-06-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
    SET @Po_ErrNo = 0   
	BEGIN TRAN
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	DELETE FROM ETL_PRK_CS2CNUpLoadTracing WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor
	
	INSERT INTO ETL_PRK_CS2CNUpLoadTracing
	(
			[DistCode],
			[ProcessName],
			[Process1],
			[Process2],
			[Process3],
			[Process4],
			[Process5],
			[ProcessPatch],
			[Date],
			[UploadFlag]
	)
	SELECT @DistCode,ProcessName,Process1,Process2,Process3,Process4,Process5,
			ProcessPatch,Date,'N' AS UploadFlag
			FROM CS2Console_UpLoadTracing WITH (NOLOCK)
			WHERE UploadFlag='N'
	UPDATE CS2Console_UpLoadTracing SET UploadFlag='Y' WHERE UploadFlag='N'
	
	COMMIT TRAN
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype= 'P' And Name = 'Proc_BLValidateJCCalendar')
DROP PROCEDURE Proc_BLValidateJCCalendar
GO
CREATE PROCEDURE [dbo].[Proc_BLValidateJCCalendar]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_BLValidateJCCalendar
* PURPOSE	: To Download the JC Calendar details
* CREATED	: MarySubashini.S
* CREATED DATE	: 07/04/2009
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
	DECLARE @Tabname  			NVARCHAR(50)
	DECLARE @JCYear				INT
	DECLARE @WeekEndDay			NVARCHAR(25)
	DECLARE @MonthId			NVARCHAR(25)
	DECLARE @MonthStartDate		DATETIME
	DECLARE @MonthEndDate		DATETIME
	DECLARE @QuarterDt			NVARCHAR(25)
	DECLARE @WeekId				NVARCHAR(25)
	DECLARE @WeekStartDate		DATETIME
	DECLARE @WeekEndDate		DATETIME
	DECLARE @DownloadFlag		NVARCHAR(1)
	DECLARE @CmpId				INT
	DECLARE @Status				INT
	DECLARE @CmpName			NVARCHAR(25)
	DECLARE @JcmId				INT
	DECLARE @JcmJc				INT
	DECLARE @WeekEndId			INT
	DECLARE @MonthNewDate		DATETIME
	DECLARE @WeekNewDate		DATETIME
	DECLARE @Count				INT
	DECLARE @Count1				INT
	DECLARE @NoDays				NUMERIC(38,0)
		SET @ErrStatus=1
		SET @Po_ErrNo=0
	SET @Tabname = 'ETL_Prk_BLJCCalendar'
		SET @NoDays=0
		DECLARE Cur_JCYear CURSOR	
	        	FOR SELECT  DISTINCT ISNULL(CAST([JCYear]AS INT),0) ,ISNULL(CAST([WeekEndDay]AS INT),0) 
							FROM ETL_Prk_BLJCCalendar WHERE DownloadFlag='D'
	    		OPEN Cur_JCYear
	    		FETCH NEXT FROM Cur_JCYear INTO @JCYear,@WeekEndDay
		    	WHILE @@FETCH_STATUS=0
		    	BEGIN
					IF ISNULL(@JCYear,'') = '' OR  @JCYear = '0'
					BEGIN
						SET @ErrDesc = 'JC Year should not be empty'
						INSERT INTO Errorlog VALUES (1,@TabName,'JC Year',@ErrDesc)
						SET @Po_ErrNo=1	
					END
					
					IF ISNUMERIC(@JCYear)=0
					BEGIN
			
						SET @Po_ErrNo=1
						SET @Taction=0
						SET @ErrDesc = 'JC Year'+ CAST (@JCYear AS NVARCHAR(100))+ ' sholud be a 4 digit number'		
						INSERT INTO Errorlog VALUES (2,@Tabname,'JC Year',@ErrDesc)
					END
					IF @JCYear < 2000
					BEGIN
			
						SET @Po_ErrNo=1
						SET @Taction=0
						SET @ErrDesc = 'Minimum Year Range is 2000'		
						INSERT INTO Errorlog VALUES (3,@Tabname,'JC Year',@ErrDesc)
					END
					IF @JCYear > 2098
					BEGIN
			
						SET @Po_ErrNo=1
						SET @Taction=0
						SET @ErrDesc = 'Maximum Year Range is 2098'		
						INSERT INTO Errorlog VALUES (4,@Tabname,'JC Year',@ErrDesc)
					END
					
					IF EXISTS (SELECT Status FROM Configuration WHERE
								ModuleName='JC Calendar' AND ModuleId='JC3')
					BEGIN
						SELECT @Status=Status FROM Configuration WHERE
								ModuleName='JC Calendar' AND ModuleId='JC3'
					END
					ELSE
					BEGIN
						SET @Status=0
					END
					IF EXISTS (SELECT CmpId  FROM Company WHERE DefaultCompany=1)
					BEGIN
						SELECT @CmpId=CmpId,@CmpName=CmpName  FROM Company WHERE DefaultCompany=1
					END
					ELSE
					BEGIN
						SET @Po_ErrNo=1
						SET @Taction=0
						SET @ErrDesc = 'Default Company does not exists'		
						INSERT INTO Errorlog VALUES (5,@Tabname,'Default Company',@ErrDesc)
					END
					IF EXISTS (SELECT JcmId  FROM JCMast WHERE JcmYr=@JCYear AND CmpId=@CmpId)
					BEGIN
						SET @Po_ErrNo=1
						SET @Taction=0
						SET @ErrDesc = 'JC Year '+CAST(@JCYear AS NVARCHAR(20))+' is already set for the '+@CmpName+' Company'
						INSERT INTO Errorlog VALUES (6,@Tabname,'Default Company',@ErrDesc)
					END
					ELSE
					BEGIN
						SELECT @JcmId=dbo.Fn_GetPrimaryKeyInteger('JCMast','JCmId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
					END
 
					IF @WeekEndDay >7 OR  @WeekEndDay < 1
					BEGIN
						SET @ErrDesc = 'Week End Day does not exists'
						INSERT INTO Errorlog VALUES (7,@TabName,'Week End Day',@ErrDesc)
						SET @Po_ErrNo=1
					END
					IF @Po_ErrNo=0
					BEGIN
						INSERT INTO JCMast(JcmId,JcmYr,CmpId,WkEndDay,Availability,LastModBy,LastModDate,
								AuthId,AuthDate)
							VALUES(@JcmId,@JCYear,@CmpId,@WeekEndDay,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
			
							SET @sSql='INSERT INTO JCMast(JcmId,JcmYr,CmpId,WkEndDay,Availability,LastModBy,LastModDate,
								AuthId,AuthDate)VALUES ('+CAST(@JcmId AS NVARCHAR(100))+','+CAST(@JCYear AS VARCHAR(10))+','+CAST(@CmpId AS VARCHAR(10))+',
								'+CAST(@WeekEndDay AS NVARCHAR(100))+','+CAST(1 AS NVARCHAR(100))+','+CAST(1 AS NVARCHAR(100))+',
								'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''','+CAST(1 AS NVARCHAR(100))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
							INSERT INTO Translog(strSql1) VALUES (@sSql)
							UPDATE Counters SET CurrValue = CurrValue+1 WHERE Tabname =  'JCMast' AND Fldname = 'JcmId'
							SET @sSql='UPDATE Counters SET CurrValue =CurrValue'+'+1'+' WHERE Tabname=''JCMast'' AND Fldname=''JcmId'''
							INSERT INTO Translog(strSql1) VALUES (@sSql)				
                    END
							
-- JC Month         
SELECT @Po_ErrNo
                    IF @Po_ErrNo = 0
					Begin
						SET @Count=0
						DECLARE Cur_JCMonth CURSOR	
	        			FOR SELECT DISTINCT ISNULL(CAST([MonthId]AS INT),0) ,CONVERT(NVARCHAR(10),[MonthStartDate],121)
									,CONVERT(NVARCHAR(10),[MonthEndDate],121),ISNULL([QuarterDt],'')
									FROM ETL_Prk_BLJCCalendar WHERE [JCYear]=@JCYear --ORDER BY [MonthId]
	    				OPEN Cur_JCMonth
	    				FETCH NEXT FROM Cur_JCMonth INTO @MonthId,@MonthStartDate,@MonthEndDate,@QuarterDt
		    			WHILE @@FETCH_STATUS=0
		    			BEGIN
								
								IF @Count>0		
								BEGIN
									IF @MonthStartDate<@MonthNewDate OR @MonthStartDate=@MonthNewDate
									BEGIN
										SET @ErrDesc = 'Month date already exists in previous month'
										INSERT INTO Errorlog VALUES (8,@TabName,'Month Start date',@ErrDesc)
										SET @Po_ErrNo=1
									END
								END
								IF ISNULL(@MonthStartDate,'') = ''
								BEGIN
									SET @ErrDesc = 'Month Start date should not be empty'
									INSERT INTO Errorlog VALUES (9,@TabName,'Month Start date',@ErrDesc)
									SET @Po_ErrNo=1
								END
								IF ISNULL(@MonthEndDate,'') = ''
								BEGIN
									SET @ErrDesc = 'Month End date should not be empty'
									INSERT INTO Errorlog VALUES (10,@TabName,'Month End date',@ErrDesc)
									SET @Po_ErrNo=1
								END
								IF ISNULL(@QuarterDt,'') = ''
								BEGIN
									SET @ErrDesc = 'Quarter Detail should not be empty'
									INSERT INTO Errorlog VALUES (11,@TabName,'Quarter Detail',@ErrDesc)
									SET @Po_ErrNo=1
								END
								IF ISDATE(@MonthStartDate)=0
								BEGIN
									SET @Po_ErrNo=1		
									SET @Taction=0
									SET @ErrDesc = 'Month Start date '+ CAST(@MonthStartDate AS NVARCHAR(100))+ ' not in date format'		
									INSERT INTO Errorlog VALUES (12,@Tabname,'Month Start date',@ErrDesc)
								END
								IF ISDATE(@MonthEndDate)=0
								BEGIN
									SET @Po_ErrNo=1		
									SET @Taction=0
									SET @ErrDesc = 'Month End date '+ CAST(@MonthEndDate AS NVARCHAR(100))+ ' not in date format'		
									INSERT INTO Errorlog VALUES (13,@Tabname,'Month End date',@ErrDesc)
								END
								IF @MonthStartDate>@MonthEndDate
								BEGIN
									SET @Po_ErrNo=1		
									SET @Taction=0
									SET @ErrDesc = 'Month Start date should be less than Month end date'		
									INSERT INTO Errorlog VALUES (14,@Tabname,'Month Start/End date',@ErrDesc)
								END
								IF @QuarterDt='Q1' OR @QuarterDt='Q2' OR @QuarterDt='Q3' OR @QuarterDt='Q4'
								BEGIN
									SET @Po_ErrNo=0		
								END
								ELSE
								BEGIN
									SET @Po_ErrNo=0		
									SET @Taction=0
									SET @ErrDesc = 'Quarter Dt does not exists'		
									INSERT INTO Errorlog VALUES (15,@Tabname,'Quarter Dt',@ErrDesc)
								END
								IF YEAR(@MonthStartDate)=@JCYear OR YEAR(@MonthStartDate)=@JCYear+1
								BEGIN
									SET @Po_ErrNo=0	
								END
								ELSE
								BEGIN
									SET @Po_ErrNo=1		
									SET @Taction=0
									SET @ErrDesc = CAST(@MonthStartDate AS VARCHAR(100))+'Date Range should be within the JC Year'+CAST(@JCYear AS VARCHAR(100))+''		
									INSERT INTO Errorlog VALUES (16,@Tabname,'Date Range',@ErrDesc)
								END
								IF @Status=0
								BEGIN
									IF YEAR(@MonthStartDate)<@JCYear
									BEGIN
										SET @Po_ErrNo=1		
										SET @Taction=0
										SET @ErrDesc = 'Month Start Date Range should be within the JC Year'		
										INSERT INTO Errorlog VALUES (17,@Tabname,'Month Start Date Range',@ErrDesc)
									END
									
									IF YEAR(@MonthStartDate)<@JCYear
									BEGIN
										SET @Po_ErrNo=1		
										SET @Taction=0
										SET @ErrDesc = 'Month End Date Range should be within the JC Year'		
										INSERT INTO Errorlog VALUES (18,@Tabname,'Month End Date Range',@ErrDesc)
									END
								END
								ELSE
								BEGIN
									SET @NoDays=@NoDays+DATEDIFF(d,@MonthStartDate,@MonthEndDate)
									IF YEAR(@MonthStartDate)=@JCYear OR YEAR(@MonthStartDate)=@JCYear+1
									BEGIN
										SET @Po_ErrNo=0	
									END
									ELSE
									BEGIN
										SET @Po_ErrNo=1		
										SET @Taction=0
										SET @ErrDesc = 'Month Start Date Range should be within the JC Year'		
										INSERT INTO Errorlog VALUES (19,@Tabname,'Month Start Date Range',@ErrDesc)
									END
									
									IF YEAR(@MonthEndDate)=@JCYear  OR YEAR(@MonthEndDate)=@JCYear+1
									BEGIN
										SET @Po_ErrNo=0	
									END
									ELSE
									BEGIN
										SET @Po_ErrNo=1		
										SET @Taction=0
										SET @ErrDesc = 'Month End Date Range should be within the JC Year'		
										INSERT INTO Errorlog VALUES (20,@Tabname,'Month End Date Range',@ErrDesc)
									END
								END
								IF EXISTS (SELECT JcmJc FROM JCMonth A INNER JOIN JCMast B ON A.JcmId = B.JcmId
												WHERE @MonthStartDate BETWEEN JcmSdt AND JcmEdt AND A.JcmId <> @JcmId
												AND B.CmpId = @CmpId)
								BEGIN
									SET @Po_ErrNo=1		
									SET @Taction=0
									SET @ErrDesc = 'Date already exists in pervious JC Year'		
									INSERT INTO Errorlog VALUES (21,@Tabname,'Month Start/End date',@ErrDesc)
								END

								IF @Po_ErrNo = 0
								BEGIN
									INSERT INTO JCMonth(JcmId,JcmJc,JcmSdt,JcmEdt,QuarterDt,Availability,LastModBy,LastModDate,
											AuthId,AuthDate)
										VALUES(@JcmId,@MonthId,@MonthStartDate,@MonthEndDate,@QuarterDt,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
						
										SET @sSql='INSERT INTO JCMonth(JcmId,JcmJc,JcmSdt,JcmEdt,QuarterDt,Availability,LastModBy,LastModDate,
											AuthId,AuthDate)VALUES ('+CAST(@JcmId AS NVARCHAR(100))+','+CAST(@MonthId AS VARCHAR(10))+','''+CONVERT(NVARCHAR(10),@MonthStartDate,121)+''',
											'''+CONVERT(NVARCHAR(10),@MonthEndDate,121)+''','''+@QuarterDt+''','+CAST(1 AS NVARCHAR(100))+','+CAST(1 AS NVARCHAR(100))+',
											'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''','+CAST(1 AS NVARCHAR(100))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
										INSERT INTO Translog(strSql1) VALUES (@sSql)
								SET @Count1=0
									-- JC Week
								DECLARE Cur_JCWeek CURSOR	
	        					FOR SELECT DISTINCT ISNULL(CAST([WeekId]AS INT),0) ,CONVERT(NVARCHAR(10),[WeekStartDate],121)
											,CONVERT(NVARCHAR(10),[WeekEndDate],121)
											FROM ETL_Prk_BLJCCalendar WHERE [JCYear]=@JCYear AND MonthId=@MonthId --ORDER BY [WeekId]
	    						OPEN Cur_JCWeek
	    						FETCH NEXT FROM Cur_JCWeek INTO @WeekId,@WeekStartDate,@WeekEndDate
		    					WHILE @@FETCH_STATUS=0
		    					BEGIN
										IF @Count1>0		
										BEGIN
											IF @WeekStartDate<@WeekNewDate OR @WeekStartDate=@WeekNewDate
											BEGIN
												SET @ErrDesc = 'Week date already exists in previous Week'
												INSERT INTO Errorlog VALUES (22,@TabName,'Week Start date',@ErrDesc)
												SET @Po_ErrNo=1
											END
										END
										IF ISNULL(@WeekStartDate,'') = ''
										BEGIN
											SET @ErrDesc = 'Week Start date should not be empty'
											INSERT INTO Errorlog VALUES (23,@TabName,'Week Start date',@ErrDesc)
											SET @Po_ErrNo=1
										END
										IF ISNULL(@WeekEndDate,'') = ''
										BEGIN
											SET @ErrDesc = 'Week End date should not be empty'
											INSERT INTO Errorlog VALUES (24,@TabName,'Week End date',@ErrDesc)
											SET @Po_ErrNo=1
										END
										
										IF ISDATE(@WeekStartDate)=0
										BEGIN
											SET @Po_ErrNo=1		
											SET @Taction=0
											SET @ErrDesc = 'Week Start date '+ CAST(@WeekStartDate AS NVARCHAR(100))+ ' not in date format'		
											INSERT INTO Errorlog VALUES (25,@Tabname,'Week Start date',@ErrDesc)
										END
										IF ISDATE(@WeekEndDate)=0
										BEGIN
											SET @Po_ErrNo=1		
											SET @Taction=0
											SET @ErrDesc = 'Week End date '+ CAST(@WeekEndDate AS NVARCHAR(100))+ ' not in date format'		
											INSERT INTO Errorlog VALUES (26,@Tabname,'Month End date',@ErrDesc)
										END
										IF @WeekStartDate>@WeekEndDate
										BEGIN
											SET @Po_ErrNo=1		
											SET @Taction=0
											SET @ErrDesc = 'Week Start date should be less than Month end date'		
											INSERT INTO Errorlog VALUES (27,@Tabname,'Week Start/End date',@ErrDesc)
										END
										IF NOT EXISTS (SELECT MonthId FROM ETL_Prk_BLJCCalendar WHERE
												@WeekStartDate BETWEEN @MonthStartDate AND @MonthEndDate)
										BEGIN
											SET @Po_ErrNo=1		
											SET @Taction=0
											SET @ErrDesc = 'Week Start date should be With in the JC Month Date'		
											INSERT INTO Errorlog VALUES (28,@Tabname,'Week Start date',@ErrDesc)
										END
										IF NOT EXISTS (SELECT MonthId FROM ETL_Prk_BLJCCalendar WHERE
												@WeekStartDate BETWEEN @MonthStartDate AND @MonthEndDate AND MonthId=@MonthId)
										BEGIN
											SET @Po_ErrNo=1		
											SET @Taction=0
											SET @ErrDesc = 'Week Start date should be With in the JC Month Date'		
											INSERT INTO Errorlog VALUES (29,@Tabname,'Week Start date',@ErrDesc)
										END
										IF NOT EXISTS (SELECT MonthId FROM ETL_Prk_BLJCCalendar WHERE
												@WeekEndDate BETWEEN @MonthStartDate AND @MonthEndDate AND MonthId=@MonthId)
										BEGIN
											SET @Po_ErrNo=1		
											SET @Taction=0
											SET @ErrDesc = 'Week End date should be With in the JC Month Date'		
											INSERT INTO Errorlog VALUES (30,@Tabname,'Week End date',@ErrDesc)
										END
										IF @Po_ErrNo=0
										BEGIN
											INSERT INTO JCWeek(JcmId,JcmJc,JcwWk,JcwSdt,JcwEdt,Availability,LastModBy,LastModDate,
												AuthId,AuthDate)
											VALUES(@JcmId,@MonthId,@WeekId,@WeekStartDate,@WeekEndDate,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121))
							
											SET @sSql='INSERT INTO JCWeek(JcmId,JcmJc,JcwWk,JcwSdt,JcwEdt,Availability,LastModBy,LastModDate,
												AuthId,AuthDate)VALUES ('+CAST(@JcmId AS NVARCHAR(100))+','+CAST(@MonthId AS VARCHAR(10))+',
													'+CAST(@WeekId AS VARCHAR(10))+','''+CONVERT(NVARCHAR(10),@WeekStartDate,121)+''',
												'''+CONVERT(NVARCHAR(10),@WeekEndDate,121)+''','+CAST(1 AS NVARCHAR(100))+','+CAST(1 AS NVARCHAR(100))+',
												'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''','+CAST(1 AS NVARCHAR(100))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
											INSERT INTO Translog(strSql1) VALUES (@sSql)
										END
										SET @WeekNewDate=@WeekEndDate
										SET @Count1=1
									FETCH NEXT FROM Cur_JCWeek INTO  @WeekId,@WeekStartDate,@WeekEndDate
									END
								CLOSE Cur_JCWeek
								DEALLOCATE Cur_JCWeek
								END
								SET @Count=1
								SET @MonthNewDate=@MonthEndDate
							FETCH NEXT FROM Cur_JCMonth INTO  @MonthId,@MonthStartDate,@MonthEndDate,@QuarterDt
						END
						CLOSE Cur_JCMonth
						DEALLOCATE Cur_JCMonth
					END
					IF @Status=1
					BEGIN
						IF @NoDays=365  OR  @NoDays=366
						BEGIN
							SET @Po_ErrNo=0		
						END
						ELSE
						BEGIN
							SET @Po_ErrNo=1		
							SET @Taction=0
							SET @ErrDesc = 'Calendar should complete a Year'		
							INSERT INTO Errorlog VALUES (31,@Tabname,'Calendar',@ErrDesc)
						END
					END
				
			FETCH NEXT FROM Cur_JCYear INTO  @JCYear,@WeekEndDay
				--UPDATE ETL_Prk_BLJCCalendar SET DownloadFlag='Y' WHERE [JCYear]=@JCYear
		        END
		        CLOSE Cur_JCYear
		        DEALLOCATE Cur_JCYear

END
GO
IF NOT EXISTS (Select * from Sysobjects Where Xtype = 'U' And Name = 'SchToAvoid')
CREATE TABLE SchToAvoid 
(
CmpSchCode  nvarchar(100)
)
GO
--Select * from customupdownload where Module = 'Product Batch' And updownload= 'Download'
Delete from customupdownload where Module = 'Product Batch' And updownload= 'Download'
GO
Insert into customupdownload Select 40,1,'Product Batch','Product Batch','Proc_Cs2Cn_ProductBatch','Proc_Import_ProductBatch','Cn2Cs_Prk_ProductBatch','Proc_Cn2Cs_ProductBatch','Master','Download',1
--Select * from customupdownload where Module = 'Product' And updownload= 'Download'
Delete from customupdownload where Module = 'Product' And updownload= 'Download'
GO
Insert into customupdownload Select 39,1,'Product','Product','Proc_Cs2Cn_Product','Proc_Import_Product','Cn2Cs_Prk_Product','Proc_Cn2Cs_Product','Master','Download',1
--Select * from Tbl_Downloadintegration Where ProcessName = 'Product' 
Delete From Tbl_Downloadintegration Where ProcessName = 'Product' 
GO
Insert into Tbl_Downloadintegration Select 13,'Product','Cn2Cs_Prk_Product','Proc_Import_Product',1768,500,'2011-10-14 11:33:58.083'
GO
IF EXISTS ( Select * from SysObjects Where Xtype = 'P' And Name = 'Proc_Cn2Cs_ProductBatch')
DROP PROCEDURE Proc_Cn2Cs_ProductBatch
GO
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_ProductBatch]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ProductBatch
* PURPOSE		: To Insert and Update records in the Tables ProductBatch and ProductBatchDetails
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 12/04/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist 				AS 	INT
	DECLARE @PrdCCode 	        AS 	NVARCHAR(100)
	DECLARE @BatchCode			AS 	NVARCHAR(100)
	DECLARE @PriceCode			AS 	NVARCHAR(4000)		
	DECLARE @MnfDate			AS 	NVARCHAR(100)
	DECLARE @ExpDate			AS 	NVARCHAR(100)
	DECLARE	@BatchSeqCode 		AS 	NVARCHAR(100)
	DECLARE @PrdId 				AS 	INT
	DECLARE @PrdBatId 			AS 	INT
	DECLARE @PriceId 			AS 	INT
	DECLARE @TaxGroupId 		AS 	INT
	DECLARE @BatchSeqId 		AS 	INT
	DECLARE @BatchStatus		AS 	INT
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
	DECLARE @ContPriceCode		AS	NVARCHAR(100)
	DECLARE @ContPrdBatId1		AS	INT
	DECLARE @ContPriceId1		AS	INT
	DECLARE @OldPriceId 		AS 	INT
	DECLARE @NewPriceId			AS  INT
	DECLARE @OldLSP				AS  NUMERIC(38,6)
	DECLARE @StockInHand		AS  NUMERIC(38,0)
	DECLARE @ValDiffRefNo		AS  NVARCHAR(50)
	DECLARE @MRP				AS  NUMERIC(38,6)
	DECLARE @LSP				AS  NUMERIC(38,6)
	DECLARE @SR					AS  NUMERIC(38,6)
	DECLARE @CR					AS  NUMERIC(38,6)
	DECLARE @AR1				AS  NUMERIC(38,6)
	DECLARE @AR2				AS  NUMERIC(38,6)
	DECLARE @AR3				AS  NUMERIC(38,6)
	DECLARE @AR4				AS  NUMERIC(38,6)
	DECLARE @AR5				AS  NUMERIC(38,6)
	DECLARE @AR6				AS  NUMERIC(38,6)
	SET @Po_ErrNo=0
	SET @Exist=0
	SELECT @ExistPrdBatMaxId=ISNULL(MAX(PrdBatId),0) FROM ProductBatch
	SELECT @OldPriceId=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails		
	SELECT @BatchSeqId=BatchSeqId FROM BatchCreationMaster WHERE BatchSeqId IN
	(SELECT MAX(BatchSeqId) FROM BatchCreationMaster)
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'PrdBatToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE PrdBatToAvoid	
	END
	CREATE TABLE PrdBatToAvoid
	(
		PrdCCode NVARCHAR(200),
		PrdBatCode NVARCHAR(200)
	)
	IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch
	WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product))
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdCCode','Product :'+PrdCCode+' not available'
		FROM Cn2Cs_Prk_ProductBatch
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		--->Added By Nanda on 05/05/2010
		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)
		SELECT DISTINCT DistCode,'Product Batch',PrdBatCode,'Product',PrdCCode,'','N' FROM Cn2Cs_Prk_ProductBatch
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		--->Till Here				
	END
	IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch
	WHERE LEN(ISNULL(PrdBatCode,''))=0)
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch
		WHERE LEN(ISNULL(PrdBatCode,''))=0
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdBatCode','Batch Code should not be empty for Product:'+PrdCCode
		FROM Cn2Cs_Prk_ProductBatch
		WHERE LEN(ISNULL(PrdBatCode,''))=0
	END
	DECLARE Cur_ProductBatch CURSOR
	FOR SELECT PB.PrdCCode,PrdBatCode,ManufacturingDate,ExpiryDate,MRP,ListPrice,SellingRate,ClaimRate,
	AddRate1,AddRate2,AddRate3,AddRate4,AddRate5,AddRate6
	FROM Cn2Cs_Prk_ProductBatch PB INNER JOIN Product P ON P.PrdCCode=PB.PrdCCode
	WHERE DownLoadFlag='D' AND PB.PrdCCode+'~'+PrdBatCode
	NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM PrdBatToAvoid)	
	ORDER BY PB.PrdCCode,PrdBatCode,EffectiveDate
	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdCCode,@BatchCode,@MnfDate,@ExpDate,@MRP,@LSP,@SR,@CR,@AR1,@AR2,@AR3,@AR4,@AR5,@AR6	
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Exist=0
		SET @Po_ErrNo=0
		SET @DefaultPriceId=1
		SET @BatchStatus=1
		SET @PriceCode=@BatchCode+'-'+CAST(@MRP AS NVARCHAR(25))+'-'+CAST(@LSP AS NVARCHAR(25))+'-'+
		CAST(@SR AS NVARCHAR(25))+'-'+CAST(@CR AS NVARCHAR(25))+'-'+CAST(@AR1 AS NVARCHAR(25))
		SELECT @PrdId=PrdId FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCCode
		SELECT @TaxGroupId=ISNULL(TaxGroupId,0) FROM Product WITH (NOLOCK) WHERE PrdId=@PrdId
		
		IF NOT EXISTS(SELECT * FROM ProductBatch WITH (NOLOCK) WHERE PrdBatCode=@BatchCode AND PrdId=@PrdId)
		BEGIN
			SET @Exist=0
		END
		ELSE
		BEGIN
			SET @Exist=1 				
			SELECT @PrdBatId=PrdBatId FROM ProductBatch WITH (NOLOCK) WHERE PrdBatCode=@BatchCode AND PrdId=@PrdId
			SELECT @OldLSP=ISNULL(PBD.PrdBatDetailValue,0),@ExistPriceId=PriceId FROM ProductBatchDetails PBD
			WHERE PrdBatId=@PrdBatId AND DefaultPrice=1 AND SlNo=2
		END
		
		IF @Exist=0
		BEGIN
			SELECT @PrdBatId=dbo.Fn_GetPrimaryKeyInteger('ProductBatch','PrdBatId',YEAR(GETDATE()),MONTH(GETDATE()))
			IF @PrdBatId>(SELECT ISNULL(MAX(PrdBatId),0) AS PrdBatId FROM ProductBatch)
			BEGIN
				INSERT INTO ProductBatch(PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,
				TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PrdId,@PrdBatId,@BatchCode,@BatchCode,@MnfDate,@ExpDate,@BatchStatus,@TaxGroupId,@BatchSeqId,6,
				0,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 			
				
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ProductBatch' AND FldName='PrdBatId'
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,'ETL_Prk_ProductBatch','System Date',
				'Reset the Counters/System is showing Date as :'+CAST(GETDATE() AS NVARCHAR(10))+'. Please change the System Date')
				SET @Po_ErrNo=1
				CLOSE Cur_ProductBatch
				DEALLOCATE Cur_ProductBatch
				RETURN
			END
		END	
		ELSE
		BEGIN
			UPDATE ProductBatch SET MnfDate=@MnfDate,ExpDate=@ExpDate,TaxGroupId=@TaxGroupId,Status=@BatchStatus
			WHERE PrdBatId=@PrdBatId
		END			
			
		IF @Po_ErrNo=0
		BEGIN
			SELECT @PriceId=dbo.Fn_GetPrimaryKeyInteger('ProductBatchDetails','PriceId',YEAR(GETDATE()),MONTH(GETDATE()))
			IF @PriceId>(SELECT ISNULL(MAX(PriceId),0) AS PriceId FROM ProductBatchDetails)
			BEGIN
				IF @DefaultPriceId=1
				BEGIN
					UPDATE ProductBatchDetails SET DefaultPrice=0 WHERE PrdBatId=@PrdBatId AND PriceId<>@PriceId
				END
				INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
				DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,1,@MRP,@DefaultPriceId,1,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 		
				
				INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
				DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,2,@LSP,@DefaultPriceId,1,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 		
				INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
				DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,3,@SR,@DefaultPriceId,1,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 		
				INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
				DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,4,@CR,@DefaultPriceId,1,
				1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 		
				IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatchSeqId)>4
				BEGIN
					INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
					DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@PriceId,@PrdBatId,@PriceCode,@BatchSeqId,5,@AR1,@DefaultPriceId,1,
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 
				END
				UPDATE ProductBatch SET DefaultPriceId=@PriceId WHERE PrdBatId=@PrdBatId AND PrdId=@PrdId
	
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ProductBatchDetails' AND FldName='PriceId'				
				IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreeRateForOldBatch'
				AND ModuleName='Botree Product Batch Download' AND Status=1)
				BEGIN
					IF @OldLSP-@LSP<>0 AND @Exist=1		
					BEGIN
						SELECT @StockInHand=ISNULL((PrdBatLcnSih+PrdBatLcnUih-PrdBatLcnRessih-PrdBatLcnResUih),0)
						FROM ProductBatchLocation WHERE PrdId=@PrdId AND PrdBatId=@PrdBatId			
						IF @StockInHand>0
						BEGIN
							SELECT @ValDiffRefNo = dbo.Fn_GetPrimaryKeyString('ValueDifferenceClaim','ValDiffRefNo',CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
							
							INSERT INTO ValueDifferenceClaim(ValDiffRefNo,Date,PrdId,PrdBatId,OldPriceId,NewPriceId,OldPrice,NewPrice,Qty,ValueDiff,ClaimAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
							VALUES(@ValDiffRefNo,GETDATE(),@PrdId,@PrdBatId,@ExistPriceId,@PriceId,@OldLSP,@LSP,@StockInHand,(@OldLSP-@LSP),(@StockInHand*(@OldLSP-@LSP)),1,1,GETDATE(),1,GETDATE())
							UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'ValueDifferenceClaim' AND FldName = 'ValDiffRefNo'
						END
					END
				END
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,'ETL_Prk_ProductBatch','System Date',
				'Reset the Counters/System is showing Date as :'+CAST(GETDATE() AS NVARCHAR(10))+'. Please change the System Date')
				SET @Po_ErrNo=1
				CLOSE Cur_ProductBatch
				DEALLOCATE Cur_ProductBatch
				RETURN
			END
		END
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdCCode,@BatchCode,@MnfDate,@ExpDate,@MRP,@LSP,@SR,@CR,@AR1,@AR2,@AR3,@AR4,@AR5,@AR6		
--		IF (SELECT COUNT(DISTINCT A.PriceId) AS COUNT FROM ProductBatchDetails A INNER JOIN ProductBatch B (NOLOCK) ON
--		A.PrdBatId=B.PrdBatId And B.PrdId=@PrdId WHERE A.DefaultPrice=1 AND A.PrdBatId=@PrdBatId GROUP BY A.PrdBatId	
--		HAVING COUNT(DISTINCT A.PriceId)>1)>1
--		BEGIN
--			UPDATE ProductBatchDetails SET DefaultPrice=0
--			WHERE PrdBatId=@PrdBatId AND PriceId NOT IN
--			(
--				SELECT MAX(DISTINCT PriceId) AS PriceId FROM ProductBatchDetails (NOLOCK)
--				WHERE PrdBatId=@PrdBatId AND DefaultPrice=1
--			)						
--			
--			UPDATE ProductBatch SET DefaultPriceId=B.PriceId
--			FROM ProductBatchDetails B (NOLOCK) WHERE ProductBatch.PrdBatId=B.PrdBatId AND
--			ProductBatch.PrdBatId=@PrdBatId AND B.DefaultPrice=1 AND B.SlNo=1
--		END
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch
	UPDATE ProductBatch SET ProductBatch.DefaultPriceId=PBD.PriceId,ProductBatch.BatchSeqId=PBD.BatchSeqId
	FROM ProductBatchDetails PBD WHERE ProductBatch.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1
	
	UPDATE ProductBatch SET EnableCloning=1 WHERE PrdBatId IN
	(
	 SELECT PrdBatId FROM ProductBatchDetails GROUP BY PrdBatId  HAVING(COUNT(DISTINCT PriceId)>1)
	)
	
	SELECT PrdBatId INTO #ZeroBatches FROM ProductBatchDetails
	GROUP BY PrdBatId HAVING SUM(DefaultPrice)=0
	
	SELECT B.PrdId,B.PrdBatId,MAX(PriceId) As PriceId INTO #ZeroMaxPrices
	FROM ProductBatchDetails A INNER JOIN ProductBatch B ON A.PrdBatId=B.PrdBatId
	INNER JOIN #ZeroBatches C ON A.PrdBatId=C.PrdBatId
	WHERE A.DefaultPrice=0 GROUP BY B.PrdId,B.PrdBatId
	
	UPDATE ProductBatch Set DefaultPriceId=B.PriceId FROM ProductBatch A,#ZeroMaxPrices B
	WHERE A.PrdBatId=B.PrdbatId and A.PrdId=B.PrdId
	
	UPDATE ProductBatchDetails Set DefaultPrice=1 FROM #ZeroMaxPrices A
	WHERE ProductBatchDetails.PrdbatId=A.PrdBatId AND ProductBatchDetails.PriceId=A.PriceId
	
	SET @Po_ErrNo=0	
	--->Added By Nanda on 03/12/2009 for Special Rate
	IF @ExistPrdBatMaxId>0
	BEGIN
		SELECT @NewPrdBatMaxId=ISNULL(MAX(PrdBatId),0) FROM ProductBatch
		IF @NewPrdBatMaxId>@ExistPrdBatMaxId
		BEGIN
			DECLARE Cur_NewPrdBat CURSOR
			FOR SELECT PB.PrdId,PB.PrdBatId FROM ProductBatch PB WHERE PB.PrdBatId>@ExistPrdBatMaxId
			ORDER BY PB.PrdId,PB.PrdBatId
			OPEN Cur_NewPrdBat
			FETCH NEXT FROM Cur_NewPrdBat INTO @ContPrdId,@ContPrdBatId
			WHILE @@FETCH_STATUS=0
			BEGIN			
				SET @ContExistPrdBatId=0
				SELECT @ContExistPrdBatId=ISNULL(MAX(PB.PrdBatId),0) FROM ProductBatch PB WHERE
				PB.PrdId=@ContPrdId AND PB.PrdBatId <>@ContPrdBatId AND PB.PrdBatId IN
				(SELECT CPD.PrdBatId FROM ContractPricingDetails CPD,ProductBatch PB WHERE PB.PrdId=@ContPrdId
				 AND CPD.PrdId=PB.PrdId	AND CPD.PrdBatId=PB.PrdBatId)
				SELECT @ContPriceCode=PriceCode FROM ProductBatchDetails WHERE PrdBatId <>@ContPrdBatId
				IF @ContExistPrdBatId<>0
				BEGIN
					DECLARE Cur_NewCont CURSOR
					FOR SELECT DISTINCT PrdBatId,PriceId FROM ProductBatchDetails WHERE PriceId IN
					(SELECT PriceId FROM ContractPricingDetails WHERE PrdBatId=@ContExistPrdBatId) AND
					PrdBatId=@ContExistPrdBatId AND SlNo=3 AND PrdBatDetailValue>0
					OPEN Cur_NewCont
					FETCH NEXT FROM Cur_NewCont INTO @ContPrdBatId1,@ContPriceId
					WHILE @@FETCH_STATUS=0
					BEGIN					
						SELECT @ContPriceId1=dbo.Fn_GetPrimaryKeyInteger('ProductBatchDetails','PriceId',YEAR(GETDATE()),MONTH(GETDATE()))		
						UPDATE Counters SET CurrValue=@ContPriceId1 WHERE TabName='ProductBatchDetails' AND FldName='PriceId'
						
						INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
						Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
						SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
						FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId AND DefaultPrice=1 AND SlNo=1
						
						INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
						Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
						SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
						FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId AND DefaultPrice=1 AND SlNo=2
						
						INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
						Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
						SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
						FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId1 AND PriceId=@ContPriceId AND SlNo=3
						
						INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
						Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
						SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
						FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId AND DefaultPrice=1 AND SlNo=4
						IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatchSeqId)>4
						BEGIN
							INSERT ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
							Availability,LastModBy,LastModDate,AuthId,AuthDate)
							SELECT @ContPriceId1,@ContPrdBatId,@ContPriceCode+CAST(PrdBatDetailValue AS NVARCHAR(100)),BatchSeqId,
							SLNo,PrdBatDetailValue,0,PriceStatus,Availability,LastModBy,GETDATE(),AuthId,GETDATE()
							FROM ProductBatchDetails WHERE PrdBatId=@ContPrdBatId AND DefaultPrice=1 AND SlNo=5
						END
						
						INSERT INTO ContractPricingDetails(ContractId,PrdId,PrdBatId,PriceId,Discount,FlatAmtDisc,
						Availability,LastModBy,LastModDate,AuthId,AuthDate,CtgValMainId,ClaimablePercOnMRP)
						SELECT ContractId,PrdId,@ContPrdBatId,@ContPriceId1,Discount,FlatAmtDisc,
						Availability,LastModBy,GETDATE(),AuthId,GETDATE(),CtgValMainId,0
						FROM ContractPricingDetails WHERE PrdBatId=@ContPrdBatId1 AND PriceId=@ContPriceId
						FETCH NEXT FROM Cur_NewCont INTO @ContPrdBatId1,@ContPriceId
					END
					CLOSE Cur_NewCont
					DEALLOCATE Cur_NewCont
				END
				FETCH NEXT FROM Cur_NewPrdBat INTO @ContPrdId,@ContPrdBatId
			END
			CLOSE Cur_NewPrdBat
			DEALLOCATE Cur_NewPrdBat
		END
	END
	--->Till Here
	SELECT @NewPriceId=CurrValue FROM Counters (NOLOCK)	WHERE TabName='ProductBatchDetails' AND FldName='PriceId' 		
	--->Added By Nanda on 24/03/2010
	--->To Update Price
	IF @NewPriceId>@OldPriceId
	BEGIN
		IF EXISTS(SELECT * FROM Configuration(NOLOCK) WHERE ModuleId='BotreeRateForOldBatch'
		AND ModuleName='Botree Product Batch Download' AND Status=1)
		BEGIN
			EXEC Proc_DefaultPriceUpdation @ExistPrdBatMaxId,@OldPriceId,1
		END
	END
	--->Till Here
	
	--->Added By Nanda on 02/10/2009
	--->To Write Price History
	IF EXISTS(SELECT * FROM ProductBatchDetails WHERE DefaultPrice=1 AND PriceId>@OldPriceId)
	BEGIN
		EXEC Proc_DefaultPriceHistory 0,0,@OldPriceId,2,1
	END
	--->Till Here
	UPDATE Cn2Cs_Prk_ProductBatch SET DownLoadFlag='Y' 
	WHERE PrdCCode+'~'+PrdBatCode IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode
	FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
	
	RETURN	
END
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P'And Name = 'Proc_Cn2Cs_Product')
DROP PROCEDURE Proc_Cn2Cs_Product
GO
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_Product]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_Product
* PURPOSE		: To validate the downloaded Products 
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 03/04/2010
* NOTE			: 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpCode	nVarChar(50)
	DECLARE @SpmCode	nVarChar(50)
	DECLARE @PrdUpc		INT 	
	DECLARE @ErrStatus	INT
	TRUNCATE TABLE ETL_Prk_ProductHierarchyLevelvalue
	TRUNCATE TABLE ETL_Prk_Product
	DELETE FROM Cn2Cs_Prk_Product WHERE DownLoadFlag='Y'
	SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany = 1
	SELECT @SpmCode=S.SpmCode FROM Supplier S,Company C
	WHERE C.CmpId=S.CmpId AND S.SpmDefault = 1 AND C.DefaultCompany = 1
	--TO INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'BusinessUnit',@CmpCode,BusinessCode,BusinessName,@CmpCode
 	FROM Cn2Cs_Prk_Product
 	
 	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'StrategicBusinessUnit',BusinessCode,CategoryCode,CategoryName,@CmpCode
 	FROM Cn2Cs_Prk_Product
 	
 	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'Category',CategoryCode,FamilyCode,FamilyName,@CmpCode
 	FROM Cn2Cs_Prk_Product
	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'Brand',FamilyCode,GroupCode,GroupName,@CmpCode
 	FROM Cn2Cs_Prk_Product
	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'SubBrand',GroupCode,SubGroupCode,SubGroupName,@CmpCode
 	FROM Cn2Cs_Prk_Product
	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'Variant',SubGroupCode,BrandCode,BrandName,@CmpCode
 	FROM Cn2Cs_Prk_Product
	INSERT INTO ETL_Prk_ProductHierarchyLevelvalue
 	([Product Hierarchy Level Code],[Parent Hierarchy Level Value Code],
 	[Product Hierarchy Level Value Code],[Product Hierarchy Level Value Name],[Company Code])
 	SELECT DISTINCT 'SKU_',BrandCode,AddHier1Code,AddHier1Name,@CmpCode
 	FROM Cn2Cs_Prk_Product	
	--TO INSERT INTO ETL_Prk_Product	
	INSERT INTO ETL_Prk_Product
	([Product Distributor Code],[Product Name],[Product Short Name],[Product Company Code],
	[Product Hierarchy Level Value Code],[Supplier Code],[Stock Cover Days],
	[Unit Per SKU],[Tax Group Code],[Weight],[Unit Code],[UOM Group Code],
	[Product Type],[Effective From Date],[Effective To Date],[Shelf Life],[Status],[EAN Code],[Vending])
	SELECT DISTINCT C.PrdCCode,C.PrdName,left(C.PrdName,20) AS ProductShortName,
	C.PrdCCode,C.AddHier1Code,@SpmCode,0,1,'',C.PrdWgt,ISNULL(C.ProductUnit,'Unit'),C.UOMGroupCode,
	C.ProductType,CONVERT(VARCHAR(10),GETDATE(),121),CONVERT(VARCHAR(10),GETDATE(),121),0,'Active',
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
Delete customupdownload where updownload = 'Upload' and module = 'Daily Sales'
GO
Insert into customupdownload Select 5,1,'Daily Sales','Daily Sales','Proc_Cs2Cn_DailySales','Proc_ImportBLDailySales','Cs2Cn_Prk_DailySales','Proc_ValidateDailySales','Transaction','Upload',1
GO
IF EXISTS (Select * from Sysobjects Where Xtype = 'P' And Name = 'Proc_CS2CN_BLRetailer')  
DROP PROCEDURE Proc_CS2CN_BLRetailer
GO
CREATE PROCEDURE [dbo].[Proc_CS2CN_BLRetailer]  
(  
 @Po_ErrNo INT OUTPUT  
)  
AS  
SET @Po_ErrNo = 0
SET NOCOUNT ON  
BEGIN  
/*********************************  
* PROCEDURE : Proc_CS2CN_BLRetailer  
* PURPOSE : Extract Retailer Details from CoreStocky to Console  
* NOTES  :  
* CREATED : Nandakumar R.G 09-01-2009  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/  
    Set @Po_ErrNo = 0  
 DECLARE @CmpID   AS INTEGER  
 DECLARE @DistCode As nVarchar(50)  
   
 DELETE FROM ETL_Prk_CS2CNBLRetailer WHERE UploadFlag = 'Y'  
 SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1   
 SELECT @DistCode = DistributorCode FROM Distributor  
  
 INSERT INTO ETL_Prk_CS2CNBLRetailer  
  (  
   DistCode ,  
   RtrId ,  
   RtrCde ,  
   RtrNm ,  
   RtrChannelCde ,  
   RtrGroupCde ,  
   RtrClassCde ,  
   Status,  
   KeyAccount,  
   RelationStatus,  
   ParentCode,  
   RtrRegDate,  
   GeoLevel,  
   GeoLevelValue,  
   Mode,  
   UploadFlag  
  )  
  SELECT  
   @DistCode ,  
   R.RtrId ,  
   R.RtrCode ,  
   R.RtrName ,  
   RC1.CtgCode ,  
   RC.CtgCode ,  
   RVC.ValueClassCode ,  
   RtrStatus,   
   CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,  
   CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,  
   (CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,  
   CONVERT(VARCHAR(10),R.RtrRegDate,121),ISNULL(GL.GeoLevelName,'') AS GeoLevelName,ISNULL(G.GeoName,'') AS GeoName,'New','N'      
  FROM    
   RetailerValueClassMap RVCM ,  
   RetailerValueClass RVC ,  
   RetailerCategory RC ,  
   RetailerCategoryLevel RCL,  
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
   RC1.CtgCode,  
   RC.CtgCode,  
   RVC.ValueClassCode,  
   RtrStatus,  
   CASE RtrKeyAcc WHEN 0 THEN 'NO' ELSE 'YES' END AS KeyAccount,  
   CASE RtrRlStatus WHEN 2 THEN 'PARENT' WHEN 3 THEN 'CHILD' WHEN 1 THEN 'INDEPENDENT' ELSE 'INDEPENDENT' END AS RelationStatus,  
   (CASE RtrRlStatus WHEN 3 THEN ISNULL(RET.RtrCode,'') ELSE '' END) AS ParentCode,  
   CONVERT(VARCHAR(10),R.RtrRegDate,121),ISNULL(GL.GeoLevelName,'') AS GeoLevelName,ISNULL(G.GeoName,'') AS GeoName,'CR','N'     
  FROM  
   RetailerClassficationChange RCC  
   INNER JOIN RetailerValueClass RVC ON RVC.RtrClassId=RCC.RtrClassficationId AND UpLoadFlag=0  
   INNER JOIN RetailerCategory RC ON RC.CtgMainId=RCC.CtgMainId  
   INNER JOIN RetailerCategoryLevel RL ON RL.CtgLevelId=RCC.CtgLevelId  
   INNER JOIN RetailerCategory RC1 ON RC1.CtgMainId=RC.CtgLinkId  
   INNER JOIN Retailer R ON R.RtrId=RCC.RtrId  
   LEFT OUTER JOIN (SELECT K.RtrCode,RE.RtrId,RE.RtrChildId FROM RetailerRelation RE  
   INNER JOIN Retailer K ON RE.RtrId=K.RtrId) RET ON RET.RtrChildId=R.RtrId  
   LEFT OUTER JOIN Geography G ON G.GeoMainId=R.GeoMainId   
   LEFT OUTER JOIN GeographyLevel GL ON GL.GeoLevelId=G.GeoLevelId   
  
 UPDATE Retailer SET Upload='Y' WHERE Upload='N'   
 AND RtrCode IN(SELECT RtrCde FROM ETL_Prk_CS2CNBLRetailer WHERE Mode='New')  
  
 UPDATE RetailerClassficationChange SET UploadFlag=1 WHERE UploadFlag=0  
 AND RtrCode IN (SELECT RtrCde FROM ETL_Prk_CS2CNBLRetailer WHERE Mode='CR')  
  
END
GO
Delete from customupdownload where updownload = 'Upload' and module = 'Purchase Confirmation'
GO
Insert into customupdownload Select 8,1,'Purchase Confirmation','Purchase Confirmation','Proc_Cs2Cn_PurchaseConfirmation','Proc_ImportPurchaseConfirmation','Cs2Cn_Prk_PurchaseConfirmation','Proc_CN2CSBLPurchaseConfirmation','Transaction','Upload',1
GO  
Delete from Customupdownload Where updownload = 'Upload' and module = 'Sales Return'
GO
Insert Into Customupdownload Select 7,1,'Sales Return','Sales Return','Proc_Cs2Cn_SalesReturn','Proc_ImportBLSalesReturn','Cs2Cn_Prk_SalesReturn','Proc_CN2CSBLSalesReturn','Transaction','Upload',1
GO
if not exists (select * from hotfixlog where fixid = 392)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(392,'D','2011-10-18',getdate(),1,'Core Stocky Service Pack 392')
GO