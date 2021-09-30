--[Stocky HotFix Version]=356
Delete from Versioncontrol where Hotfixid='356'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('356','2.0.0.5','D','2011-01-06','2011-01-06','2011-01-06',convert(varchar(11),getdate()),'Parle;Major:-;Minor:Changes and Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 356' ,'356'
GO

--SRF-Nanda-191-001

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyQPSSchemeInBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyQPSSchemeInBill]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme(NOLOCK) WHERE SchId=527
--SELECT * FROM BillAppliedSchemeHd
DELETE FROM BillAppliedSchemeHd
EXEC Proc_ApplyQPSSchemeInBill 545,1,0,2,2
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd(NOLOCK) WHERE TransId = 2 And UsrId = 2
SELECT * FROM BillAppliedSchemeHd (NOLOCK)
--SELECT * FROM ApportionSchemeDetails (NOLOCK)
--SELECT * FROM SalesInvoiceQPSCumulative(NOLOCK) WHERE SchId=522
--SELECT * FROM SchemeMaster
--SELECT * FROM Retailer
SELECT * FROM BillAppliedSchemeHd
ROLLBACK TRANSACTION
*/

CREATE        Procedure [dbo].[Proc_ApplyQPSSchemeInBill]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT		
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
* {date} {developer}  {brief modification description}
	
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
		SELECT '1',* FROM @TempBilled1
	END
	IF @QPS <> 0
	BEGIN
		--From all the Bills
		--To Add the Cumulative Qty
		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
		SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.SumQty),0) AS SchemeOnQty,
			ISNULL(SUM(A.SumValue),0) AS SchemeOnAmount,
			ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(SumInKG),0)
			WHEN 3 THEN ISNULL(SUM(SumInKG),0) END,0) AS SchemeOnKg,
			ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(SumInLitre),0)
			WHEN 5 THEN ISNULL(SUM(SumInLitre),0) END,0) AS SchemeOnLitre,@Pi_SchId
			FROM SalesInvoiceQPSCumulative A (NOLOCK)
			INNER JOIN Product C ON A.PrdId = C.PrdId
			INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
			WHERE A.SchId = @Pi_SchId AND A.RtrId = @Pi_RtrId
			GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
		SELECT '2',* FROM @TempBilled1
--		IF @QPSBasedOn<>1
--		BEGIN
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
--		END
		SELECT '3',* FROM @TempBilled1
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
		SELECT '4',* FROM @TempBilled1
		--NNN
		IF @QPSBasedOn=1 OR (@QPSBasedOn<>1 AND @FlexiSch=1)
		BEGIN
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
			SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
				-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
				-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
				FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
				AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
		END
		SELECT '5',* FROM @TempBilled1
		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
			-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
			-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
			FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
			GROUP BY PrdId,PrdBatId
--		SELECT * FROM @TempBilled1
	END
	SELECT '6',* FROM @TempBilled1
	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
		ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
		GROUP BY PrdId,PrdBatId,SchId

	--->Added By Nanda on 26/11/2010
	DELETE FROM @TempBilled WHERE SchemeOnQty+SchemeOnAmount+SchemeOnKG=0
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
	SELECT * FROM @TempBilled
--	SELECT 'N',@QPSReset
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
		SELECT @SlabId
	END
	SELECT @TotalValue = ISNULL(SUM(FrmSchAch),0) FROM @TempBilledAch WHERE SlabId =1
	
	--->Added By Boo and Nanda on 29/11/2010
	IF @SchType = 3 AND @QPSReset=1
	--IF @QPSReset=1
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
		SELECT 'New ',* FROM #TemAppQPSSchemes
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemes B WHERE A.SlabId=B.SlabId)
	END
	--->Till Here


--	SELECT 'N',@QPSResetAvail
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
--		SELECT 'SSSS',* FROM @TempBilledAch
		
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
				SELECT @SlabAssginValue
				WHILE @SlabAssginValue > CAST(0 AS NUMERIC(38,6))
				BEGIN
					SET @AssignQty  = 0
					SET @AssignAmount = 0
					SET @AssignKG = 0
					SET @AssignLitre = 0
					SELECT @SlabAssginValue
					SELECT @FrmSchAchRem
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
--				SELECT 'Slab',@SlabAssginValue 
--				SELECT 'Slab',* FROM BillAppliedSchemeHd
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
--					SELECT 'S1',* FROM @TempRedeem
--					SELECT 'S1',* FROM @TempBilledAch
--					SELECT 'S1',* FROM @TempBilledQPSReset
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
		
		--SELECT * FROM @TempRedeem		
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
				--((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
				FlatAmt * @NoOfTimes
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
	--IF @QPSReset=1
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
	SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount),SUM(SchemeDiscount),
		SUM(Points),FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,(FreePrdId) as FreePrdId ,
		FreePrdBatId,SUM(FreeToBeGiven),GiftPrdId,GiftPrdBatId,SUM(GiftToBeGiven),SUM(NoOfTimes),
		IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,0 FROM @BillAppliedSchemeHd
		GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,FlxDisc,FlxValueDisc,FlxFreePrd,
		FlxGiftPrd,FlxPoints,FreePrdId
		,FreePrdBatId,GiftPrdId,GiftPrdBatId,IsSelected,
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
	SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
	AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId
	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
	EXEC Proc_ApplyDiscountScheme @Pi_SchId,@Pi_UsrId,@Pi_TransId
	UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
	SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
	TransId = @Pi_TransId AND Usrid = @Pi_UsrId

	INSERT INTO @QPSGivenFlat
	SELECT SchId,SUM(FlatAmount)
	FROM
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount,0) AS FlatAmount
	FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
	(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd) A,
	SalesInvoice SI
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND FlexiSch=0 AND A.SchemeDiscount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
	AND SISl.SlabId<=A.SlabId
	) A
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

	DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
	INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
	SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat

--	SELECT 'N',* FROM @QPSGivenFlat
	UPDATE BillAppliedSchemeHd SET SchemeAmount=CAST(SchemeAmount-Amount AS NUMERIC(38,4))
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	

	--->For QPS Reset
	DECLARE @MSSchId AS INT
	DECLARE @MaxSlabId AS INT
	DECLARE @AmtToReduced AS NUMERIC(38,6)
	DECLARE Cur_QPSSlabs CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabs
	FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN
	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenFlat WHERE SchId=@MSSchId)
			BEGIN
			SELECT @AmtToReduced=SchemeAmount FROM BillAppliedSchemeHd 
			WHERE SlabId=@MaxSlabId AND SchId=@MSSchId

			UPDATE BillAppliedSchemeHd SET SchemeAmount=0
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
			END
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount+@AmtToReduced-Amount
			FROM  @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=@MSSchId 
			AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
			AND A.SchId=BillAppliedSchemeHd.SchId
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs

--	UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-Amount
--	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId	
--	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
--	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
--	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
--	AND CAST(BillAppliedSchemeHd.SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10)) IN 
--	(SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(MAX(SlabId) AS NVARCHAR(10)) FROM BillAppliedSchemeHd GROUP BY SchId)	

	DELETE FROM BillAppliedSchemeHd WHERE SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd=0

--->Commented By Nanda on 27/11/2010
--	IF @QPS<>0 AND @QPSReset<>0	
--	BEGIN
--		DELETE FROM BillAppliedSchemeHd WHERE CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
--		NOT IN (SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BilledPrdHdForQPSScheme WHERE QPSPrd=0 AND SchId=@Pi_SchId) 
--		AND SchId=@Pi_SchId AND SchId IN (
--		SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
--		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
--		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
--	END
--->Till Here

	IF @QPSReset<>0
	BEGIN
		UPDATE B SET B.NoOfTimes=A.NoOfTimes,B.SchemeAmount=A.SchemeAmount
		FROM BillAppliedSchemeHd B,(SELECT SchId,SlabId,MAX(NoOfTimes) AS NoOfTimes,MAX(SchemeAmount) AS SchemeAmount
			FROM BillAppliedSchemeHd GROUP BY SchId,SlabId) AS A
		WHERE B.SchId=A.SchId AND B.SlabId=A.SlabId AND B.SchId=@Pi_SchId
	END

	--Added By Murugan
	IF @QPS<>0
	BEGIN
		DELETE FROM BilledPrdHdForQPSScheme WHERE Transid=@Pi_TransId and Usrid=@Pi_UsrId AND SchId=@Pi_SchId
		INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
		SELECT RowId,@Pi_RtrId,BP.PrdId,BP.Prdbatid,SelRate,BaseQty,BaseQty*SelRate AS SchemeOnAmount,MRP,@Pi_TransId,@Pi_UsrId,ListPrice,0,@Pi_SchId
		From BilledPrdHdForScheme BP WHERE BP.TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND BP.RtrId=@Pi_RtrId --AND BP.SchId=@Pi_SchId

		IF @FlexiSch=0
		BEGIN
			INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
			From @TempBilled TB 		
		END
		ELSE
		BEGIN
			INSERT INTO BilledPrdHdForQPSScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice,QPSPrd,SchId)
			SELECT 10000 RowId,@Pi_RtrId,TB.PrdId,TB.Prdbatid,0 AS SelRate,SchemeOnQty,SchemeOnAmount,0 AS MRP,@Pi_TransId,@Pi_UsrId,0 AS ListPrice,1,@Pi_SchId
			From @TempBilled TB WHERE CAST(TB.PrdId AS NVARCHAR(10))+'~'+CAST(TB.PrdBatId AS NVARCHAR(10)) IN
			(SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BilledPrdHdForScheme)		
			
--			--->For QPS Flexi(Range Based Started with Slab From 1)
--			IF @RangeBase=1
--			BEGIN
--				UPDATE BP SET GrossAmount=GrossAmount+SchemeOnAmount,BaseQty=(BaseQty+SchemeOnQty)
--				FROM BilledPrdHdForQPSScheme BP, 
--				(SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
--				-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
--				-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre
--				FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
--				AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId) A
--				WHERE BP.PrdId=A.PrdId AND BP.PrdBatId=A.PrdBatId AND BP.RowId=10000
--			END
		END
	END
	--Till Here	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-191-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyReturnScheme]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyReturnScheme]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC [Proc_ApplyReturnScheme] 2,1,23
SELECT * FROM UserFetchReturnScheme 
-- DELETE FROM UserFetchReturnScheme
-- SELECT * FROM SalesInvoiceSchemeLineWise WHERE SalId=11865
-- SELECT * FROM ApportionSchemeDetails
-- SELECT * FROM BillAppliedSchemeHd WHERE TransId=3 AND usrId=2
-- DELETE FROM ApportionSchemeDetails
-- DELETE FROM BillAppliedSchemeHd
-- DELETE FROM ReturnPrdHdForScheme
-- SELECT * FROM ReturnPrdHdForScheme
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_ApplyReturnScheme]
(
	@Pi_SalId int,
	@Pi_Usrid as int,
	@Pi_TransId as int
)
/******************************************************************************************
* PROCEDURE	: Proc_ApplyReturnScheme
* PURPOSE	: To Apply the Return Scheme and Get the Scheme Details for the Selected Scheme
* CREATED	: Boopathy
* CREATED DATE	: 01/06/2007
* NOTE		: General SP for Returning the Scheme Details for the all type of Schemes
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-------------------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}	
* 25/07/2009	Panneerselvam.k		Solve the Divied  By Zero Error
******************************************************************************************/
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Config		INT
	SET @Config=-1
	IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='SALESRTN18' AND Status=1)
	BEGIN
		SET @Config=0 
	END
	ELSE IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='SALESRTN19' AND Status=1)
	BEGIN
		SET @Config=1
	END
	ELSE
	BEGIN
		SET @Config=-1
	END
	
	DECLARE @SchId			INT
	DECLARE @SlabId			INT
	DECLARE @PurOfEveryReq	INT
	DECLARE @NoOfTimes		NUMERIC(38,6)
	DECLARE @SchType		INT
	DECLARE @ProRata		INT
	DECLARE @RtrId			INT
	DECLARE @CurSlabId		INT
	DECLARE @PrdId			INT
	DECLARE @PrdbatId		INT
	DECLARE @RowId			INT
	DECLARE @Combi			INT
	DECLARE @SchCode		VARCHAR(100)
	DECLARE @FlexiSch		INT
	DECLARE @FlexiSchType	INT
	DECLARE @SchemeBudget	NUMERIC(18,6)
	DECLARE @SchLevelId			INT
	DECLARE @SchemeLvlMode		INT
	DECLARE @TempHier TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT
	)
	DECLARE @TempBilledAchCombi TABLE
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
	DECLARE @SchEligiable TABLE
	(
		ManType			INT,
		Cnt				INT,
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId	INT,
		FrmSchAch 		NUMERIC(38,6),
		NoOfTimes		NUMERIC(38,6),
		SchId			INT,
		SlabId			INT
	)
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
	DECLARE @TempBilledAch TABLE
	(
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
	DECLARE @TempSchSlabAmt TABLE
	(
		ForEveryQty		NUMERIC(38,6),
		ForEveryUomId		INT,
		DiscPer			NUMERIC(38,6),
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
		SchId			INT,
		SlabId			INT,
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
	DECLARE @FreePrdDt TABLE
	(
		SalId			INT,
		SchId			INT,
		SlabId			INT,
		FreeQty			INT,
		FreePrdId		INT,
		FreePrdBatId	INT,
		FreePriceId		INT,
		GiftQty			INT,
		GiftPrdId		INT,
		GiftPrdBatId	INT,
		GiftPriceId		INT,
		PrdId			INT,
		PrdBatId		INT,
		RowId			INT
		
	)
	DECLARE @ReturnPrdHdForScheme TABLE
	(
		RowId		int,
		RtrId		int,
		PrdId		int,
		PrdBatId	int,
		SelRate		numeric(18,6),
		BaseQty		int,
		GrossAmount	numeric(18,6),
		TransId		tinyint,
		Usrid		int,
		SalId		bigint,
		RealQty		int,
		MRP			numeric(18,6)
	)
	DECLARE @t1 TABLE
	(
		SalId		INT,
		SchId		INT,
		PrdId		INT,
		PrdBatId	INT,
		FlatAmt		NUMERIC(38,6),
		DiscPer		NUMERIC(38,6),
		Points		INT,
		NoofTimes	INT
	)
	DECLARE @TempSch1 Table
	(
		SalId		INT,
		RowId		INT,
		PrdId		INT,
		PrdBatId	INT,
		BaseQty		NUMERIC(38,6),
		Selrate		NUMERIC(38,6),
		Grossvalue	NUMERIC(38,6),
		Schid		INT,
		Slabid		INT,
		Discper		NUMERIC(38,6),
		Flatamt		NUMERIC(38,6),
		Points		NUMERIC(38,6),
		NoofTimes	NUMERIC(38,6)
	)
	DECLARE @TempSch2 Table
	(
		SalId			INT,
		RowId			INT,
		PrdId			INT,
		PrdBatId		INT,
		Schid			INT,
		Slabid			INT,
		SchemeAmount	NUMERIC(38,6),
		SchemeDiscount	NUMERIC(38,6),
		Points			NUMERIC(38,6),
		Contri			NUMERIC(38,6),
		NoofTimes		NUMERIC(38,6)
	)
	DECLARE @MaxSchDt TABLE
	(
		SalId		INT,
		SchId		INT,
		SlabId		INT,
		RowId		INT,
		PrdId		INT,
		PrdBatId	INT,
		SchAmt		NUMERIC(38,6)
	)
	DECLARE @SchGross TABLE
	(
		SchId	INT,
		Amt		NUMERIC(38,6)
	)
	--Apportion scheme amt prd wise
	DECLARE @DiscPer	NUMERIC(38,6)
	DECLARE @FlatAmt	NUMERIC(38,6)
	DECLARE @Points		INT
	DECLARE @SumValue	NUMERIC(38,6)
	DECLARE @FreePrd	INT
	DECLARE @GiftPrd	INT
	DECLARE @MaxPrdId	INT
	DECLARE @SalId		INT
	DECLARE @RefCode	VARCHAR(2)
	DECLARE @CombiSch	INT
	DECLARE @QPS		INT
	DECLARE @BillCnt	INT
	DECLARE @SchCnt		INT
	DECLARE @TempSlabId	INT
	DECLARE @Cnt1	AS	INT
	DECLARE @Cnt2	AS	INT
	DECLARE @FlatChk1 AS INT
	DECLARE @FlatChk2 AS INT
	DELETE FROM SalesReturnDbNoteAlert WHERE SalId=@Pi_SalId
	IF @Config=0
	BEGIN
		DELETE FROM UserFetchReturnScheme WHERE SalId=@Pi_SalId AND Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		INSERT INTO UserFetchReturnScheme(SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,FreeQty,
		FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId)
		SELECT SI.SalId,RPS.PrdId,RPS.PRdBatId,SIL.SchId,SIL.SlabId,
		((SIL.DiscountPerAmount-SIL.PrimarySchemeAmt-SIL.ReturnDiscountPerAmount)/(SIP.BaseQty-SIP.ReturnedQty))*(RPS.RealQty),
		((SIL.FlatAmount-SIL.ReturnFlatAmount)/(SIP.BaseQty-SIP.ReturnedQty))*(RPS.RealQty),0,0,0,0,0,0,0,0,@Pi_Usrid,@Pi_TransId,RPS.RowId,0,0
		FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
		INNER JOIN SalesInvoiceSchemeLineWise SIL ON SIL.SalId=SIP.SalId AND SIP.PrdId=SIL.PrdId 
		AND SIP.PrdBatId=SIL.PrdBatId AND SIP.Slno=SIL.RowId INNER JOIN
		ReturnPrdHdForScheme RPS ON RPS.PrdId=SIP.PrdId AND RPS.PrdBatId=SIP.PrdBatId AND RPS.SalId=SI.SalId AND RPS.RtrId=SI.RtrId 
		WHERE SI.SalId=@Pi_SalId AND usrid = @Pi_Usrid AND TransId = @Pi_TransId
		SELECT @RtrId=RtrId FROM SalesInvoice WHERE SalId=@Pi_SalId

		INSERT INTO ReturnPrdHdForScheme
		SELECT A.Slno,@RtrId,A.Prdid,A.PrdBatId,A.PrdUnitSelRate,A.BaseQty-A.ReturnedQty,
		(A.BaseQty-A.ReturnedQty)*A.PrdUnitSelRate,@Pi_TransId,@Pi_UsrId,@Pi_SalId,0,A.PrdUnitMRP
		FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
		A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
		WHERE A.SalId=@Pi_SalId AND A.PrdId NOT IN (SELECT Distinct PrdId FROM ReturnPrdHdForScheme
		WHERE usrid = @Pi_Usrid AND TransId = @Pi_TransId AND SalId = @Pi_SalId )

		DECLARE SchemeFreeCur CURSOR FOR
		SELECT DISTINCT SchId,SlabId FROM SalesInvoiceSchemeDtFreePrd WHERE SalId=@Pi_SalId
		OPEN SchemeFreeCur
		FETCH NEXT FROM SchemeFreeCur INTO @SchId,@CurSlabId
		WHILE @@fetch_status= 0
		BEGIN		
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery,@SchLevelId = SchLevelId,
			@SchemeLvlMode = SchemeLvlMode FROM SchemeMaster WHERE SchId=@SchId

			SELECT @RowId=MIN(RowId)  FROM ReturnPrdHdForScheme WHERE  
			TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId

			SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM ReturnPrdHdForScheme WHERE  
			TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId AND RowId=@RowId

			INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,FreeQty,
			GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
			SELECT A.SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,CEILING((FreeQty/A.BaseQty)*SUM(B.RealQty)),
			0 AS GiftQty,0 AS GiftPrdId,0 AS GiftPrdBatId,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM
			(SELECT A.SalId,A.SchId,A.SlabId,A.FreePrdId,A.FreePrdBatId,(A.FreeQty-A.ReturnFreeQty) AS FreeQty,A.FreePriceId,
			SUM((B.BaseQty-B.ReturnedQty)) AS BaseQty FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN 
			SalesInvoiceProduct B ON A.SalId=B.SalId INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) C 
			ON B.PrdId=C.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE C.PrdBatId End 
			WHERE A.SchId=@SchId AND A.SlabId=@CurSlabId AND A.SalId=@Pi_SalId
			GROUP BY A.SalId,A.SchId,A.SlabId,A.FreePrdId,A.FreePrdBatId,A.FreeQty,A.ReturnFreeQty,A.FreePriceId) AS A
			INNER JOIN ReturnPrdHdForScheme B ON A.SalId=B.SalId
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) C ON
			C.PrdId = B.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE C.PrdBatId End
			WHERE usrid = @Pi_Usrid AND TransId = @Pi_TransId AND A.SalId=@Pi_SalId
			GROUP BY A.SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,FreeQty,A.BaseQty
/*
BEGIN TRANSACTION
EXEC [Proc_ApplyReturnScheme] 16565,1,3
ROLLBACK TRANSACTION
*/
			FETCH NEXT FROM SchemeFreeCur INTO @schid,@CurSlabId
		END
		CLOSE SchemeFreeCur
		DEALLOCATE SchemeFreeCur
		DELETE FROM UserFetchReturnScheme WHERE (DiscAmt+FlatAmt+Points+FreeQty+GiftQty)<=0
		IF EXISTS(SELECT * FROM @FreePrdDt)
		BEGIN
			IF EXISTS (SELECT * FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT DISTINCT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 
							WHERE SchId NOT IN (SELECT SchId FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			END
			ELSE
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT DISTINCT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 	
			END
			DELETE FROM UserFetchReturnScheme WHERE (DiscAmt+FlatAmt+Points+FreeQty+GiftQty)=0
		END	
	END
	ELSE IF @Config=1
	BEGIN
		Declare SchemeCur Cursor for
		SELECT distinct C.SchId,C.CombiSch,C.QPS FROM SalesInvoiceSchemeLineWise a 
		INNER JOIN SchemeMaster C ON C.SchId = a.SchId WHERE A.SalId=@Pi_SalId
		UNION
		SELECT distinct C.SchId,C.CombiSch,C.QPS FROM SalesInvoiceSchemeDtPoints a 
		INNER JOIN SchemeMaster C ON C.SchId = a.SchId WHERE A.SalId=@Pi_SalId
		open SchemeCur
		fetch next FROM SchemeCur into @SchId,@CombiSch,@QPS 
		while @@fetch_status= 0
		begin
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery,@SchLevelId = SchLevelId,
			@SchemeLvlMode = SchemeLvlMode FROM SchemeMaster WHERE SchId=@SchId
			DELETE FROM @TempBilled
			DELETE FROM @TempBilledAch
			DELETE FROM @TempBilledAchCombi				
			DELETE FROM @TempBilledCombiAch
			SET @SlabId=0
			UPDATE A SET A.BASEQTY=(B.BaseQty-B.ReturnedQty)-A.RealQty FROM ReturnPrdHdForScheme A INNER JOIN 
			SalesInvoiceProduct B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdbatId
			WHERE B.SalId=@Pi_SalId  AND A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BaseQty=0
			SELECT @Cnt1=COUNT(A.PrdId) FROM ReturnPrdHdForScheme A 
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
			AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId
			SELECT @Cnt2=COUNT(PrdId) FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@SchId
			SELECT -1 As Mode,PrdId,PrdBatId,SUM(B.BaseQty-B.ReturnedQty) AS BaseQty INTO #tempBilledPrd 
			FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId GROUP BY PrdId,PrdBatId
			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty),0) END AS SchemeOnQty,
				CASE E.Mode 
				WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty * A.SelRate),0) END AS SchemeOnAmount,
				ISNULL
				(
					(CASE D.PrdUnitId 
					WHEN 2 THEN 
						(CASE E.Mode 
						WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
					WHEN 3 THEN 
						(CASE E.Mode WHEN 0 THEN 0 ELSE (ISNULL(SUM(PrdWgt * A.BaseQty),0)) END) 
				 END),0)					
					AS SchemeOnKg,
				ISNULL
				(
					(CASE D.PrdUnitId 
						WHEN 4 THEN 
							(CASE E.Mode 
									WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
						WHEN 5 THEN 
							(CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0) END)
				 END),0) AS SchemeOnLitre,@SchId
				FROM ReturnPrdHdForScheme A INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C ON A.PrdId = C.PrdId
				INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
				INNER JOIN #tempBilledPrd E ON A.PrdId=E.PrdId AND A.PrdbatId=E.PrdBatId
				WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BASEQTY>0
				GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId	,E.Mode	
			UNION
				SELECT PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,SchId FROM 
				(SELECT DISTINCT E.PrdId,E.PrdBatId,ISNULL(SUM(E.BaseQty-E.ReturnedQty),0) AS SchemeOnQty,
					ISNULL(SUM(E.BaseQty * E.PrdUnitSelRate),0) AS SchemeOnAmount,
					ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnKg,
					ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnLitre,@SchId As SchId
					FROM SalesInvoiceProduct E INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON B.PrdId=E.PrdId AND E.SalId=@Pi_SalId
					AND E.PrdBatId = CASE B.PrdBatId WHEN 0 THEN E.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C ON E.PrdId = C.PrdId
					INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId 
					GROUP BY E.PrdId,E.PrdBatId,D.PrdUnitId) A WHERE NOT EXISTS (SELECT PrdId,PrdBatId FROM ReturnPrdHdForScheme B
					WHERE A.PrdId=B.Prdid AND A.PrdbatId=B.PrdBatId)
				--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
				INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
				SELECT ISNULL(CASE @SchType
					WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
				-- 	WHEN 1 THEN SUM(CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
					WHEN 2 THEN SUM(SchemeOnAmount)
					WHEN 3 THEN (CASE A.UomId
							WHEN 2 THEN SUM(SchemeOnKg) * 1000
							WHEN 3 THEN SUM(SchemeOnKg)
							WHEN 4 THEN SUM(SchemeOnLitre) * 1000
							WHEN 5 THEN SUM(SchemeOnLitre)	END)
						END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
					ISNULL(CASE @SchType
					WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
				-- 	WHEN 1 THEN SUM(CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
					WHEN 2 THEN SUM(SchemeOnAmount)
					WHEN 3 THEN (CASE A.ToUomId
							WHEN 2 THEN SUM(SchemeOnKg) * 1000
							WHEN 3 THEN SUM(SchemeOnKg)
							WHEN 4 THEN SUM(SchemeOnLitre) * 1000
							WHEN 5 THEN SUM(SchemeOnLitre)	END)
						END,0) AS ToSchAch,A.ToUomId AS ToUomAch,
					A.Slabid,(A.PurQty + A.FromQty) as FromQty,A.UomId,A.ToQty,A.ToUomId
					FROM SchemeSlabs A
					INNER JOIN @TempBilled B ON A.SchId = B.SchId
					INNER JOIN Product C ON B.PrdId = C.PrdId
					LEFT OUTER JOIN UomGroup D ON D.UomGroupId = C.UomGroupId AND D.UomId = A.UomId
					LEFT OUTER JOIN UomGroup E ON E.UomGroupId = C.UomGroupId AND E.UomId = A.UomId
					GROUP BY A.UomId,A.Slabid,A.PurQty,A.FromQty,A.UomId,A.ToQty,A.ToUomId	
					SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
						INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId
						WHERE
					A.FrmSchAch >= B.FromQty AND
					A.ToSchAch <= (CASE B.ToQty WHEN 0 THEN A.ToSchAch ELSE B.ToQty END)
						ORDER BY A.SlabId DESC) As SlabId
		
			SET @SlabId= ISNULL(@SlabId,0)
				--Store the Slab Amount Details into a temp table
				INSERT INTO @TempSchSlabAmt (ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints)
				SELECT ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints
					FROM SchemeSlabs WHERE Schid = @SchId And SlabId = @SlabId
				
				IF @SlabId> 0 
				BEGIN
					--To Get the Number of Times the Scheme should apply
					IF @PurOfEveryReq = 0
					BEGIN
						SET @NoOfTimes = 1
					END
					ELSE
					BEGIN
					
						SELECT @NoOfTimes = A.FrmSchAch / (CASE B.ForEveryQty WHEN 0 THEN 1 ELSE B.ForEveryQty END) FROM
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
				END
				ELSE
				BEGIN
					SET @NoOfTimes =1
				END
				INSERT INTO @TempSch1 (SalId,RowId,PrdId,PrdBatId,BaseQty,Selrate,Grossvalue,Schid,Slabid,
    			Discper,Flatamt,Points,NoofTimes)
	   			SELECT DISTINCT a.SalId,a.RowId,C.PrdId,a.PrdBatId,
				CASE A1.BaseQty WHEN 0 THEN A1.RealQty ELSE A1.BaseQty END,a1.SelRate,--A1.BaseQty*a1.SelRate,
				CASE A1.BaseQty WHEN 0 THEN a1.RealQty ELSE A1.BaseQty END *a1.SelRate,
				@SchId,D.SlabId,(d.DiscPer+d.FlxDisc),(d.FlatAmt-d.FlxValueDisc),
				D.Points+D.FlxPoints,@NoOfTimes FROM SalesInvoiceSchemeLineWise A 
				INNER JOIN ReturnPrdHdForScheme a1 ON A.PrdId=a1.PrdId AND a.PrdBatId=a1.PrdbatId 
				AND A.SalId=a1.SalId and a1.Usrid = @Pi_Usrid AND a1.TransId = @Pi_TransId 
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END
				INNER JOIN SchemeSlabs d ON d.SchId=A.SchId AND D.SchId=@SchId AND D.SlabId=@SlabId
				INNER JOIN SalesInvoiceProduct G ON A.PrdId=G.PrdId AND A.PrdBatId=G.PrdBatId AND G.SalId=a.SalId
				WHERE a.SalId= @Pi_SalId
				IF @SlabId>0 
				BEGIN
					SELECT @DiscPer = (SELECT ROUND(ISNULL(SUM(b.DiscountPerAmount-b.ReturnDiscountPerAmount),0),5) FROM SalesInvoiceSchemeLineWise b WHERE
						b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.DiscountPerAmount-b.ReturnDiscountPerAmount)>0)
					
					SELECT @FlatAmt = (SELECT ROUND(ISNULL(SUM(b.FlatAmount-b.ReturnFlatAmount),0),5) FROM SalesInvoiceSchemeLineWise b WHERE
						b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.FlatAmount-b.ReturnFlatAmount)>0) 
					
					SELECT @Points = (SELECT ISNULL(Sum(b.Points-b.ReturnPoints),0) FROM dbo.SalesInvoiceSchemeDtPoints b WHERE
						b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.Points-b.ReturnPoints)>0)
					SELECT @SumValue = (SELECT Sum(Grossvalue) FROM @TempSch1 WHERE SalId = @Pi_SalId AND SchId = @SchId)
	
					IF @DiscPer>0 
					BEGIN
						IF @Cnt1=@Cnt2 
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,
								((A.Grossvalue*A.Discper)/100)*@NoOfTimes as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,
								(C.DiscountPerAmount-C.ReturnDiscountPerAmount)-(((A.Grossvalue*A.Discper)/100)*@NoOfTimes) as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
						END
						ELSE
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,0 as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
							ELSE
							BEGIN
								SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
								FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								WHERE A.SalId=@Pi_SalId
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,
								CASE WHEN (C.DiscountPerAmount-C.ReturnDiscountPerAmount)-((A.Grossvalue*A.Discper)/100) <0 
								THEN (C.DiscountPerAmount-C.ReturnDiscountPerAmount)*@NoOfTimes
								ELSE (C.DiscountPerAmount-C.ReturnDiscountPerAmount)-(((A.Grossvalue*A.Discper)/100)*@NoOfTimes) END	as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
								 (SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
									((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId)B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue)>B.SchemeDiscount)
								BEGIN
									SET ROWCOUNT 1
									UPDATE A SET A.SchemeDiscount=A.SchemeDiscount+B.SchemeDiscount
									FROM @TempSch2 A
									INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
									((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId 
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId 
									WHERE (C.Grossvalue)>B.SchemeDiscount
									SET ROWCOUNT 0
								END
								ELSE
								BEGIN							
									INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
									SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
									SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount,0,0,0,@Pi_UsrId,@Pi_TransId FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
									((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
								END
							END
						END
					END
			
					IF @FlatAmt>0
					BEGIN
						SELECT @FlatChk1=SUM(B.BaseQty-B.ReturnedQty) FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId
						SELECT @FlatChk2=ISNULL(SUM(B.BaseQty),0) FROM @TempSch1 B WHERE SalId = @Pi_SalId AND SchId=@SchId
						IF @Cnt1=@Cnt2 
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
									0,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
									And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId AND A.SlabId=@SlabId
									SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat1
									FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
									DELETE FROM @TempSch2 WHERE SchemeAmount<0 
									UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
									FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
									GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
									#temp_Flat1 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
								END
								ELSE
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									(C.FlatAmount-C.ReturnFlatAmount)-((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes),
									0 as SchemeDiscount,
									0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
									And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId AND A.SlabId=@SlabId
									SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat3
									FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
									DELETE FROM @TempSch2 WHERE SchemeAmount<0 
									UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
									FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
									GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
									#temp_Flat3 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
								END
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								(C.FlatAmount-C.ReturnFlatAmount)-((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
								0 as SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
								And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat2 
								FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
								DELETE FROM @TempSch2 WHERE SchemeAmount<0 
								UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
								FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
									GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
								#temp_Flat2 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
			
							END
						END
						ELSE
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount,0 as SchemeDiscount,
									0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
									And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
								ELSE
								BEGIN
									SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
									FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
									A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									WHERE A.SalId=@Pi_SalId
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									(C.FlatAmount-C.ReturnFlatAmount)-((CAST((((B.BaseQty-B.ReturnedQty))*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
									0 AS SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
									AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
									INNER JOIN SalesInvoiceProduct B ON 
									A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND C.RowId=B.Slno
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
									IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,
									CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId 
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
									WHERE (C.Grossvalue>B.SchemeAmount))
									BEGIN
										SET ROWCOUNT 1
										UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
										FROM @TempSch2 A INNER JOIN 
										(SELECT A.SalId,A.Schid,A.SlabId,
										CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
										(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
										SchemeDiscount,Points,Contri,NoOfTimes FROM
										(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
										(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
										0 As SchemeDiscount,0 As Points,
										(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
										FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
										AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
										INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
										WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
										(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
										A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
										SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
										A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
										AND A.SchId=B.SchId And A.SlabId=B.SlabId 
										INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId 
										WHERE (C.Grossvalue>B.SchemeAmount)
										SET ROWCOUNT 0
									END
									ELSE
									BEGIN
										INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
										SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
										SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
										0, CASE WHEN A.SchemeAmount<0 THEN A.SchemeAmount*-1 ELSE A.SchemeAmount END ,0,0,@Pi_UsrId,@Pi_TransId FROM
										(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
										SchemeDiscount,Points,Contri,NoOfTimes FROM
										(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
										(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
										0 As SchemeDiscount,0 As Points,
										(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
										FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
										AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
										INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
										WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
										(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
										A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
										SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
										A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
									END
								END
							END
							ELSE
							BEGIN								
								SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
								FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								WHERE A.SalId=@Pi_SalId 
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								(C.FlatAmount-C.ReturnFlatAmount)-((CAST((((B.BaseQty-B.ReturnedQty))*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
								0 AS SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND C.RowId=B.Slno
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
								IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
								(SELECT A.SalId,A.Schid,A.SlabId,
								CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
								(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
								0 As SchemeDiscount,0 As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId 
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue>B.SchemeAmount))
								BEGIN				
									SET ROWCOUNT 1					
									UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
									FROM @TempSch2 A INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,
									CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
									WHERE (C.Grossvalue>B.SchemeAmount)
									SET ROWCOUNT 0
								END
								ELSE
								BEGIN
									INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
									SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
									SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									0, CASE WHEN A.SchemeAmount<0 THEN A.SchemeAmount*-1 ELSE A.SchemeAmount END ,0,0,@Pi_UsrId,@Pi_TransId FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
								END
							END
						END
					END
					IF @Points>0
					BEGIN
						SELECT @FlatChk1=SUM(B.BaseQty-B.ReturnedQty) FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId
						SELECT @FlatChk2=SUM(B.BaseQty) FROM @TempSch1 B WHERE SalId = @Pi_SalId AND SchId=@SchId
						IF @Cnt1=@Cnt2 
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeDtPoints WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount, 0 as SchemeDiscount,
									(CAST(((A.BaseQty*A.SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes as Points,
									((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
								ELSE
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount, 0 as SchemeDiscount,
									((C.Points-C.ReturnPoints)-(CAST(((A.BaseQty*A.SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
									((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount, 0 as SchemeDiscount,
								(C.Points-C.ReturnPoints)-((CAST((A.BaseQty*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
								((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
						END
						ELSE
						BEGIN
							IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeDtPoints WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
							BEGIN
								IF @FlatChk1=@FlatChk2
								BEGIN
									INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
									SchemeDiscount,Points,Contri,NoofTimes)
									SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
									0 as SchemeAmount, 0 as SchemeDiscount,0 as Points,
									((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
									FROM @TempSch1 A 
									INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
									AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
								END
							END
							ELSE
							BEGIN
								
								SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
								FROM SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId 
								WHERE A.SalId=@Pi_SalId 
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,0 AS SchemeDiscount,
								(C.Points-C.ReturnPoints)-((CAST((A.BaseQty*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
								((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.SchId=C.SchId
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
								IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
								(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId
								,ROUND(A.Points,0)*@NoOfTimes AS Points FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
								0 AS SchemeAmount,0 As SchemeDiscount,
								(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId) B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId 
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue)>B.Points)
								BEGIN			
									SET ROWCOUNT 1						
									UPDATE A SET A.Points=A.Points+B.Points
									FROM @TempSch2 A INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId
									,ROUND(A.Points,0)*@NoOfTimes AS Points FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									0 AS SchemeAmount,0 As SchemeDiscount,
									(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
									WHERE (C.Grossvalue>B.Points)
									SET ROWCOUNT 0
								END
								ELSE
								BEGIN
									INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
									SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
									SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									0,0,ROUND(A.Points,0)*@NoOfTimes,0,@Pi_UsrId,@Pi_TransId FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									0 AS SchemeAmount,0 As SchemeDiscount,
									(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId 
								END
							END
						END
					END
				END		
				ELSE
				BEGIN
					INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
					SchemeDiscount,Points,Contri,NoofTimes)
					SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
					(A.FlatAmount-A.ReturnFlatAmount)*@NoOfTimes as SchemeAmount,
					(A.DiscountPerAmount-A.ReturnDiscountPerAmount) *@NoOfTimes AS SchemeDiscount,0 as Points,100 as Contri,1
					FROM SalesInvoiceSchemeLineWise A WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
					UNION
					SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
					0 AS SchemeAmount,0 As SchemeDiscount,(A.Points-A.ReturnPoints)*@NoOfTimes As Points,
					100 As Contri,1 AS NoOfTimes
					FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
					AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
					WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
				
					INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
					SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
						SELECT SalId,Schid,Slabid,PrdId,PrdBatId,RowId,
						SchemeDiscount,SchemeAmount,Points,0,@Pi_UsrId,@Pi_TransId FROM
						(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
						(A.FlatAmount-A.ReturnFlatAmount)*@NoOfTimes as SchemeAmount,
						(A.DiscountPerAmount-A.ReturnDiscountPerAmount) *@NoOfTimes AS SchemeDiscount,0 as Points,100 as Contri,1 AS NoTimes 
						FROM SalesInvoiceSchemeLineWise A WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A
						WHERE NOT EXISTS (
						SELECT PrdId,PrdBatId,SalId FROM
						(SELECT A.PrdId,A.PrdBatId,A.SalId FROM ReturnPrdHdForScheme A 
						INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
						AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
						WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId) X WHERE A.SalId=X.SalId AND 
						A.PrdId=X.PrdId AND A.PrdBatId=X.PrdBatId)
						UNION
						SELECT SalId,Schid,Slabid,PrdId,PrdBatId,RowId,
						SchemeDiscount,SchemeAmount,Points*@NoOfTimes,0,@Pi_UsrId,@Pi_TransId FROM
						(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid AS SlabId,
						0 AS SchemeAmount,0 As SchemeDiscount,(A.Points-A.ReturnPoints) As Points
						FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
						AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
						WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A
						WHERE NOT EXISTS (
							SELECT PrdId,PrdBatId,SalId FROM
							(SELECT A.PrdId,A.PrdBatId,A.SalId FROM ReturnPrdHdForScheme A 
							INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
							AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
							WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId) X WHERE A.SalId=X.SalId AND 
							A.PrdId=X.PrdId AND A.PrdBatId=X.PrdBatId)
				END
			FETCH NEXT FROM SchemeCur INTO @schid ,@CombiSch,@QPS
		END
		CLOSE SchemeCur
		DEALLOCATE SchemeCur
		DELETE FROM SalesReturnDbNoteAlert WHERE (SchDiscAmt+SchFlatAmt+SchPoints)=0
		SELECT SalId,SchId,SlabId,SUM(CAST(SchemeAmount AS NUMERIC(18,6))) AS SchAmt,SUM(SchemeDiscount) AS SchDisc,
		SUM(Points) AS SchPoints INTO #Test1 FROM @TempSch2
		GROUP BY SalId,SchId,SlabId 
		DELETE A FROM  @TempSch2 A INNER JOIN #Test1 B ON A.SalId=B.SalId AND A.SchId=B.SchId
		AND A.SlabId=B.SlabId WHERE B.SchAmt=0 AND B.SchDisc=0 AND B.SchPoints=0
		INSERT INTO UserFetchReturnScheme(SalId,RowId,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,FreeQty,
		FreePrdId,FreePrdBatId,FreePriceId,GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,NoofTimes,Usrid,TransId)
		SELECT a.SalId,a.RowId,a.PrdId,a.PrdBatId,b.SchId,b.SlabId,b.SchemeDiscount,b.SchemeAmount,
			b.Points,0,0,0,0,0,0,0,0,b.NoofTimes,@Pi_Usrid,@Pi_TransId
		FROM ReturnPrdHdForScheme a INNER JOIN @TempSch2 b ON
		a.SalId=b.SalId AND a.PrdId = b.PrdId AND a.PrdBatId=b.PrdBatId --AND a.RowId=B.RowId
		WHERE a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId = @Pi_SalId
		ORDER BY a.RowId
		DECLARE SchUpdateCur CURSOR FOR
		SELECT DISTINCT SalId,SchId,SlabId FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		OPEN SchUpdateCur
		FETCH NEXT FROM SchUpdateCur INTO @SalId,@SchId,@SlabId
		WHILE @@fetch_status= 0
		BEGIN
		
		   SELECT @MaxPrdId = (SELECT MAX(a.PrdId) FROM UserFetchReturnScheme a WHERE
		   a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId=@Pi_SalId AND a.FreeQty<>0
		   AND a.SchId =@SchId AND a.SlabId = @SlabId HAVING COUNT(a.SchId) >1)
		   SELECT @PrdBatId = (SELECT DISTINCT MAX(a.PrdbatId) FROM UserFetchReturnScheme a WHERE
		   a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId=@Pi_SalId AND
		   a.PrdId=@MaxPrdId)
		   UPDATE UserFetchReturnScheme SET FreeQty = 0,GiftQty=0 FROM
		   UserFetchReturnScheme a WHERE a.SalId = @Pi_SalId AND a.Usrid = @Pi_Usrid AND a.TransId = @Pi_TransId
		   AND  a.PrdBatId <> @PrdBatId AND a.SchId = @SchId AND a.SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId = 0 AND FreePrdBatId=0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId=0 AND GiftPrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId <> 0 AND FreePrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE GiftPrdId <> 0 AND GiftPrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId <> 0 AND FreePrdBatId<>0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId=0 AND GiftPrdBatId=0 AND FreeQty=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId = 0 AND FreePrdBatId=0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId<>0 AND GiftPrdBatId<>0 AND GiftQty=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		
		   FETCH NEXT FROM SchUpdateCur INTO @SalId,@SchId,@SlabId
		END
		CLOSE SchUpdateCur
		DEALLOCATE SchUpdateCur
		SELECT @RtrId=RtrId FROM SalesInvoice WHERE SalId=@SalId
		SELECT @RefCode=ISNULL(PrimaryRefCode,'XX') FROM SalesInvoice WHERE SalId=@SalId
		IF @RefCode <> 'XX'
		BEGIN
			SELECT DISTINCT PrdId,PrdBatId,SchId AS SchId ,SlabId,RowId INTO #TmpPrdDt 
			FROM UserFetchReturnScheme WHERE DiscAmt > 0
			UPDATE UserFetchReturnScheme SET DiscAmt = CASE WHEN (DiscAmt - tmp.Prim)>0 THEN (DiscAmt - tmp.Prim) ELSE 0 END FROM
			(SELECT F.SchId,F.SlabId,B.PrdId,B.PrdBatId,B.RowID,B.GrossAmount - (B.GrossAmount /(1 +( CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@SalId)
			WHEN 1 THEN   D.PrdBatDetailValue ELSE 0 END)/100)) AS Prim FROM BilledPrdHdForScheme B INNER JOIN ProductBatchDetails D ON D.PrdBatId = B.PrdBatId  AND D.DefaultPrice=1
			INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId AND E.Slno = D.Slno AND E.RefCode = @RefCode
			INNER JOIN #TmpPrdDt F ON B.PrdId=F.PrdId AND F.PrdBatId=B.PrdBatId AND B.RowId=F.RowId
			WHERE B.usrid = @Pi_Usrid And B.transid = @Pi_TransId) tmp,UserFetchReturnScheme A
			WHERE A.usrid = @Pi_Usrid And A.transid = @Pi_TransId AND A.SchId=tmp.schId AND A.SlabId=tmp.SlabId
			AND A.PrdId=tmp.PrdId AND A.PrdBatId=tmp.PrdBatId AND A.RowId=tmp.RowId AND A.DiscAmt >0
		END
		SELECT DISTINCT * INTO #UserFetchReturnScheme FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		DELETE FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		INSERT INTO UserFetchReturnScheme SELECT  * FROM #UserFetchReturnScheme
		DECLARE SchemeFreeCur CURSOR FOR
		SELECT DISTINCT a.SchId FROM BillAppliedSchemeHd a WHERE a.TransId=@Pi_TransId AND a.UsrId=@Pi_Usrid 
		AND (a.FreeToBeGiven + a.GiftToBeGiven+a.FlxFreePrd+a.FlxGiftPrd)>0 AND a.IsSelected=1
		UNION 
		SELECT SchId FROM dbo.SalesInvoiceSchemeDtFreePrd WHERE SalId=@Pi_SalId
		OPEN SchemeFreeCur
		FETCH NEXT FROM SchemeFreeCur INTO @SchId
		WHILE @@fetch_status= 0
		BEGIN		
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery FROM SchemeMaster WHERE SchId=@SchId
			DELETE FROM @TempBilled
			DELETE FROM @TempBilledAch
			SET @SlabId=0
			UPDATE A SET A.BASEQTY=(B.BaseQty-B.ReturnedQty)-A.RealQty FROM ReturnPrdHdForScheme A INNER JOIN 
			SalesInvoiceProduct B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdbatId
			WHERE B.SalId=@Pi_SalId  AND A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BaseQty=0
			SELECT @Cnt1=COUNT(A.PrdId) FROM ReturnPrdHdForScheme A 
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
			AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId
			SELECT @Cnt2=COUNT(PrdId) FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@SchId
			SELECT -1 As Mode,PrdId,PrdBatId,SUM(B.BaseQty-B.ReturnedQty) AS BaseQty INTO #tempBilledPrd1
			FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId GROUP BY PrdId,PrdBatId
			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty),0) END AS SchemeOnQty,
				CASE E.Mode 
				WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty * A.SelRate),0) END AS SchemeOnAmount,
				ISNULL
				(
					(CASE D.PrdUnitId 
					WHEN 2 THEN 
						(CASE E.Mode 
						WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
					WHEN 3 THEN 
						(CASE E.Mode WHEN 0 THEN 0 ELSE (ISNULL(SUM(PrdWgt * A.BaseQty),0)) END) 
				 END),0)					
					AS SchemeOnKg,
				ISNULL
				(
					(CASE D.PrdUnitId 
						WHEN 4 THEN 
							(CASE E.Mode 
									WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
						WHEN 5 THEN 
							(CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0) END)
				 END),0) AS SchemeOnLitre,@SchId
				FROM ReturnPrdHdForScheme A INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C ON A.PrdId = C.PrdId
				INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
				INNER JOIN #tempBilledPrd1 E ON A.PrdId=E.PrdId AND A.PrdbatId=E.PrdBatId
				WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId 
				GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId	,E.Mode	
			UNION
				SELECT PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,SchId FROM 
				(SELECT DISTINCT E.PrdId,E.PrdBatId,ISNULL(SUM(E.BaseQty-E.ReturnedQty),0) AS SchemeOnQty,
					ISNULL(SUM(E.BaseQty * E.PrdUnitSelRate),0) AS SchemeOnAmount,
					ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnKg,
					ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnLitre,@SchId As SchId
					FROM SalesInvoiceProduct E INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON B.PrdId=E.PrdId AND E.SalId=@Pi_SalId
					AND E.PrdBatId = CASE B.PrdBatId WHEN 0 THEN E.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C ON E.PrdId = C.PrdId
					INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId 
					GROUP BY E.PrdId,E.PrdBatId,D.PrdUnitId) A WHERE NOT EXISTS (SELECT PrdId,PrdBatId FROM ReturnPrdHdForScheme B
					WHERE A.PrdId=B.Prdid AND A.PrdbatId=B.PrdBatId)
			--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
			INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
			SELECT ISNULL(CASE @SchType
				WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
			-- 	WHEN 1 THEN SUM(CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
				WHEN 2 THEN SUM(SchemeOnAmount)
				WHEN 3 THEN (CASE A.UomId
						WHEN 2 THEN SUM(SchemeOnKg) * 1000
						WHEN 3 THEN SUM(SchemeOnKg)
						WHEN 4 THEN SUM(SchemeOnLitre) * 1000
						WHEN 5 THEN SUM(SchemeOnLitre)	END)
					END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
				ISNULL(CASE @SchType
				WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
			-- 	WHEN 1 THEN SUM(CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
				WHEN 2 THEN SUM(SchemeOnAmount)
				WHEN 3 THEN (CASE A.ToUomId
						WHEN 2 THEN SUM(SchemeOnKg) * 1000
						WHEN 3 THEN SUM(SchemeOnKg)
						WHEN 4 THEN SUM(SchemeOnLitre) * 1000
						WHEN 5 THEN SUM(SchemeOnLitre)	END)
					END,0) AS ToSchAch,A.ToUomId AS ToUomAch,
				A.Slabid,(A.PurQty + A.FromQty) as FromQty,A.UomId,A.ToQty,A.ToUomId
				FROM SchemeSlabs A
				INNER JOIN @TempBilled B ON A.SchId = B.SchId
				INNER JOIN Product C ON B.PrdId = C.PrdId
				LEFT OUTER JOIN UomGroup D ON D.UomGroupId = C.UomGroupId AND D.UomId = A.UomId
				LEFT OUTER JOIN UomGroup E ON E.UomGroupId = C.UomGroupId AND E.UomId = A.UomId
				GROUP BY A.UomId,A.Slabid,A.PurQty,A.FromQty,A.UomId,A.ToQty,A.ToUomId	
				SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
					INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId
					WHERE
				A.FrmSchAch >= B.FromQty AND
				A.ToSchAch <= (CASE B.ToQty WHEN 0 THEN A.ToSchAch ELSE B.ToQty END)
					ORDER BY A.SlabId DESC) As SlabId
				SET @SlabId= ISNULL(@SlabId,0)
				--Store the Slab Amount Details into a temp table
				INSERT INTO @TempSchSlabAmt (ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints)
				SELECT ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints
					FROM SchemeSlabs WHERE Schid = @SchId And SlabId = @SlabId
				--Store the Slab Free Product Details into a temp table
				INSERT INTO @TempSchSlabFree(ForEveryQty,ForEveryUomId,FreePrdId,FreeQty)
				SELECT A.ForEveryQty,A.ForEveryUomId,B.PrdId,B.FreeQty From
					SchemeSlabs A INNER JOIN SchemeSlabFrePrds B ON A.Schid = B.Schid
					AND A.SlabId = B.SlabId INNER JOIN Product C ON B.PrdId = C.PrdId
					WHERE A.Schid = @SchId And A.SlabId = @SlabId AND C.PrdType <> 4
				--To Get the Number of Times the Scheme should apply
				IF @PurOfEveryReq = 0
				BEGIN
					SET @NoOfTimes = 1
				END
				ELSE
				BEGIN
					SELECT @NoOfTimes = A.FrmSchAch / (CASE B.ForEveryQty WHEN 0 THEN 1 ELSE B.ForEveryQty END) FROM
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
				IF @SlabId>0
				BEGIN
				DELETE FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_Usrid  AND SchId=@SchId
				INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
				Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
				FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
				BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
				SELECT DISTINCT @SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
					@SlabId as SlabId,0 as SchAmount,0 as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
					0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,FreePrdId,0 as FreePrdBatId,
					CASE @SchType 
						WHEN 1 THEN 
							CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END 
						WHEN 2 THEN 
							CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END
						WHEN 3 THEN
							CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END
					END
					 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
					0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,1 as IsSelected,@SchemeBudget as SchBudget,
					0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,MAX(PrdId) AS PrdId,MAX(PrdBatId) AS PrdBatId,0
					FROM @TempBilled , @TempSchSlabFree
					GROUP BY FreePrdId,FreeQty,ForEveryQty
					SELECT @RowId=MIN(RowId)  FROM ReturnPrdHdForScheme WHERE  
					TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId
					INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
					GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
					SELECT DISTINCT @Pi_SalId,@SchId,@SlabId,(E.FreeQty-E.ReturnFreeQty)-B.FreeToBeGiven AS FreeQty,
					E.FreePrdId,E.FreePrdBatId,E.FreePriceId AS FreePriceId,
					0 AS GiftQty,0,0,0 AS GiftPriceId,
					B.PrdId,B.PrdBatId,@RowId AS RowId FROM	BillAppliedSchemeHd B 
					INNER JOIN SalesInvoiceSchemeDtFreePrd E ON  B.SchId=E.SchId AND B.FreePrdId=E.FreePrdId
					WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId
					AND B.IsSelected=1 AND E.SalId=@Pi_SalId
				END
				ELSE IF @SlabId=0
				BEGIN
					IF EXISTS (SELECT * FROM BillAppliedSchemeHd B WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid 
							AND (B.FreeToBeGiven + B.GiftToBeGiven+B.FlxFreePrd+B.FlxGiftPrd)>0 AND B.IsSelected=1 AND SchId=@SchId )
					BEGIN
						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
						SELECT @Pi_SalId,@SchId,B.SlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,FreePriceId AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,B.PrdId,B.PrdBatId,C.RowId FROM	BillAppliedSchemeHd B 
						INNER JOIN SalesInvoiceSchemeDtFreePrd E ON B.SchId=E.SchId AND B.SlabId=E.SlabId
						INNER JOIN @ReturnPrdHdForScheme C ON B.PrdId=C.PrdId AND B.PrdbatId=C.PrdbatId
						WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId 
						AND B.IsSelected=1 AND E.SalId=@Pi_SalId
					END
					ELSE
					BEGIN
						SELECT @RowId=MIN(RowId)  FROM ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId
						SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId AND RowId=@RowId
						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
						SELECT @Pi_SalId,@SchId,E.SlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,0 AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM	
						SalesInvoiceSchemeDtFreePrd E WHERE E.SchId=@SchId AND E.SalId=@Pi_SalId
					END
				END
			FETCH NEXT FROM SchemeFreeCur INTO @schid
		END
		CLOSE SchemeFreeCur
		DEALLOCATE SchemeFreeCur	
		IF EXISTS(SELECT * FROM @FreePrdDt)
		BEGIN
			IF EXISTS (SELECT * FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 
							WHERE SchId NOT IN (SELECT SchId FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			END
			ELSE
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 						
			END
			UPDATE A Set FreeQty=B.FreeQty ,FreePrdId=B.FreePrdId ,FreePrdBatId=B.FreePrdBatId,
					GiftQty=B.GiftQty ,GiftPrdId=B.GiftPrdId,GiftPrdBatId=B.GiftPrdBatId,
					FreePriceId=B.FreePriceId ,GiftPriceId=B.GiftPriceId FROM UserFetchReturnScheme A
					INNER JOIN @FreePrdDt B ON A.SalId=B.SalId AND A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.RowId=B.RowId
					AND A.FreePrdId=B.FreePrdId
					WHERE A.SalId=@Pi_SalId
			DELETE FROM UserFetchReturnScheme WHERE DiscAmt+FlatAmt+Points+FreeQty+GiftQty=0
		END	
	END
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-191-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApportionSchemeAmountInLine]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApportionSchemeAmountInLine]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--DELETE FROM ApportionSchemeDetails 
--DELETE FROM BilledPrdHdForQPSScheme
--DELETE FROM BilledPrdHdForScheme
--DELETE FROM BillAppliedSchemeHd
--SELECT * FROM BillAppliedSchemeHd(NOLOCK)
--SELECT * FROM BillQPSSchemeAdj(NOLOCK)
DELETE FROM ApportionSchemeDetails
--SELECT * FROM BillAppliedSchemeHd(NOLOCK)
EXEC Proc_ApportionSchemeAmountInLine 2,2
SELECT * FROM ApportionSchemeDetails(NOLOCK) WHERE TransId=2
SELECT * FROM BillQPSSchemeAdj (NOLOCK)
--SELECT * FROM TP
--SELECT * FROM TG
ROLLBACK TRANSACTION
*/

CREATE   PROCEDURE [dbo].[Proc_ApportionSchemeAmountInLine]
(
	@Pi_UsrId   INT,
	@Pi_TransId  INT
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
	--NNN
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
	
	--NNN
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
			IF @QPS=0 --OR (@Combi=1 AND @QPS=1)
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
			IF  @QPS<>0 --AND @Combi=0
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
			IF @QPS=0 --OR (@Combi=1 AND @QPS=1)
			BEGIN			
				--SELECT @SchId,@MRP,@WithTax,@SlabId	
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
			IF @QPS<>0 --AND @Combi=0
			BEGIN
--				IF @QPSDateQty=2 
--				BEGIN
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
					--NNN

					IF @QPSDateQty=2 
					BEGIN
						UPDATE TPGS SET TPGS.RowId=BP.RowId
						FROM @TempPrdGross TPGS,BilledPrdHdForQPSScheme BP
						WHERE TPGS.PrdId=BP.PrdId AND TPGS.PrdBatId=BP.PrdBatId AND UsrId=@Pi_UsrId AND TransId=@Pi_TransId AND BP.RowId<>10000
						AND TPGS.SchId=BP.SchId
--						SELECT 'S',* FROM @TempPrdGross
--						UPDATE TPGS SET TPGS.RowId=BP.RowId
--						FROM @TempPrdGross  TPGS,
--						(
--							SELECT SchId,ISNULL(MIN(RowId),2) RowId FROM BilledPrdHdForQPSScheme
--							GROUP BY SchId
--						) AS BP
--						WHERE TPGS.SchId=BP.SchId
--						SELECT 'NS',SchId,SUM(GrossAmount) AS OtherGross FROM @TempPrdGross WHERE RowId=10000
--						GROUP BY SchID
						
						UPDATE C SET C.GrossAmount=C.GrossAmount+A.OtherGross
						FROM @TempPrdGross C,
						(SELECT SchId,SUM(GrossAmount) AS OtherGross FROM @TempPrdGross WHERE RowId=10000
						GROUP BY SchID) A,
						(SELECT SchId,ISNULL(MIN(RowId),2)  AS RowId FROM @TempPrdGross WHERE RowId<>10000 
						GROUP BY SchId) B
						WHERE A.SchId=B.SchId AND B.SchId=C.SchId AND B.RowId=C.RowId
						DELETE FROM @TempPrdGross WHERE RowId=10000
--						SELECT 'S',* FROM @TempPrdGross
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
						WHERE TPGS.SchId=BP.SchId --AND TPGS.PrdBatId=BP.PrdBatId
					END	
					---
--				END
--				ELSE
--				BEGIN
--					SELECT 'NNN'
--					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
--					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
--					CASE @MRP
--					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
--					WHEN 2 THEN A.GrossAmount
--					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
--					AS GrossAmount FROM BilledPrdHdForQPSScheme A
--					LEFT JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
--					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
--					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=0					
--					UNION ALL
--					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
--					CASE @MRP
--					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
--					WHEN 2 THEN A.GrossAmount
--					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
--					AS GrossAmount FROM BilledPrdHdForQPSScheme A
--					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
--					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId
--				END
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
	----->	

	--->2010/12/03
	SELECT * FROM @TempPrdGross
	SELECT * FROM BilledPrdHdForQPSScheme

	UPDATE T1 SET QPSGrossAmount=A.GrossAmount
	FROM @TempPrdGross T1,BilledPrdHdForQPSScheme A
	WHERE T1.RowId=A.RowID AND T1.PrdId=A.PrdId AND T1.PrdBatId=A.PrdBatId AND A.TransId=@Pi_TransID AND A.UsrId=@Pi_UsrId
	AND A.QPSPrd=0 AND A.SchId=T1.SchId 

	UPDATE S1 SET S1.QPSGrossAmount=A.QPSGross	
	FROM @TempSchGross S1,(SELECT SchId,SUM(QPSGrossAmount) AS QPSGross FROM @TempPrdGross GROUP BY SchId) AS A
	WHERE A.SchId=S1.SchId
	--->


	--->Commented By Nanda on 13/10/2010
--	DECLARE  CurMoreBatch CURSOR FOR
--	SELECT DISTINCT Schid,SlabId,PrdId,PrdCnt,PrdBatCnt FROM @MoreBatch
--	OPEN CurMoreBatch
--	FETCH NEXT FROM CurMoreBatch INTO @SchId,@SlabId,@PrdId,@PrdCnt,@PrdBatCnt
--	WHILE @@FETCH_STATUS = 0
--	BEGIN
--		IF EXISTS (SELECT A.PrdBatId FROM StockLedger A LEFT OUTER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId
--			AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0)
--		BEGIN
--			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
--			WHERE SchId=@SchId AND SlabId=@SlabId AND PrdId=@PrdId AND
--			PrdBatId NOT IN (
--			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
--			(SchemeAmount) > 0  AND IsSelected = 1 AND SchType=0
--
--			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
--			WHERE SchId=@SchId AND SlabId=@SlabId AND PrdId=@PrdId AND
--			PrdBatId NOT IN (
--			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
--			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
--			(SchemeAmount) > 0  AND IsSelected = 1 AND SchType=1
--		END		
--		ELSE
--		BEGIN
--			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
--			WHERE SchId=@SchId AND SlabId=@SlabId  AND SchType=0
--			AND PrdId=@PrdId AND IsSelected = 1 AND (SchemeAmount+SchemeDiscount)>0 AND
--			PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
--			WHERE SchId=@SchId AND SlabId=@SlabId
--			AND PrdId=@PrdId  AND (SchemeAmount)>0 AND IsSelected = 1 AND SchType=0)
--
--			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
--			WHERE SchId=@SchId AND SlabId=@SlabId  AND SchType=1
--			AND PrdId=@PrdId AND IsSelected = 1 AND (SchemeAmount+SchemeDiscount)>0 AND
--			PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
--			WHERE SchId=@SchId AND SlabId=@SlabId
--			AND PrdId=@PrdId  AND (SchemeAmount)>0 AND IsSelected = 1 AND SchType=1)
--		END
--
--		UPDATE BillAppliedSchemeHd Set SchemeAmount= C.FlatAmt
--		FROM @TempPrdGross A
--		INNER JOIN BillAppliedSchemeHd B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId
--		INNER JOIN @SchFlatAmt C ON A.SchId=C.SchId AND B.SlabId=C.SlabId
--		WHERE (B.SchemeAmount)>0 AND B.PrdId=@PrdId  AND B.SchType=0
--		AND B.PrdBatId IN
--		(SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd WHERE SchId=@SchId AND SlabId=@SlabId
--		AND PrdId=@PrdId AND  IsSelected = 1 AND (SchemeAmount)>0 AND SchType=0 )
--
--		UPDATE BillAppliedSchemeHd Set SchemeAmount= C.FlatAmt
--		FROM @TempPrdGross A
--		INNER JOIN BillAppliedSchemeHd B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId
--		INNER JOIN @SchFlatAmt C ON A.SchId=C.SchId AND B.SlabId=C.SlabId
--		WHERE B.SchemeAmount>0 AND B.PrdId=@PrdId  AND B.SchType=1
--		AND B.PrdBatId IN
--		(SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd WHERE SchId=@SchId AND SlabId=@SlabId
--		AND PrdId=@PrdId AND  IsSelected = 1 AND SchemeAmount>0 AND SchType=1 )
--		
--	FETCH NEXT FROM CurMoreBatch INTO @SchId,@SlabId,@PrdId,@PrdCnt,@PrdBatCnt
--	END
--	CLOSE CurMoreBatch
--	DEALLOCATE CurMoreBatch
	--->Till Here

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
			--    (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			--SchemeAmount As SchemeAmount,
			CASE 
				WHEN QPS=1 THEN
					--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
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
			--(A.DiscPer+isnull(PrdbatDetailValue,0))/SUM(A.DiscPer+isnull(PrdbatDetailValue,0))
			(A.DiscPer+isnull(PrdbatDetailValue,0))
			as DISC,
			isnull(SUM(A.DiscPer+PrdbatDetailValue),SUM(A.DiscPer)) AS DiscSUM,ISNULL(B.SchAmt,0) AS SchAmt,
			CASE  WHEN (ISNULL(PrdbatDetailValue,0)>0 AND A.DiscPer > 0 )THEN 1
			  WHEN (ISNULL(PrdbatDetailValue,0)=0 AND A.DiscPer > 0) THEN 2
			  ELSE 3 END as Status
			INTO #TempSch1
			FROM ApportionSchemeDetails A LEFT OUTER JOIN #TempFinal B ON
			A.RowId =B.RowId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId
			AND A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.DiscPer > 0
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
			A.SlabId= B.SlabId AND B.Status<3
		END
		ELSE
		BEGIN
			INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,SchemeDiscount,
			FreeQty,TransId,Usrid,DiscPer,SchType)
			SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
			(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
			Case WHEN QPS=1 THEN
			--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
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
--		SELECT * FROM BillAppliedSchemeHd
--		SELECT * FROM @TempSchGross
--		SELECT * FROM @TempPrdGross
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
	--		SELECT * FROM TG
	--		SELECT * FROM TP
	--
	--		SELECT * FROM TGQ
	--		--SELECT * FROM SchMaxSlab 
	--		SELECT * FROM TPQ
	--		SELECT * FROM BillAppliedSchemeHd
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
			--(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount
			,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
			@Pi_TransId AS TransId,@Pi_UsrId AS UsrId,SchemeDiscount,A.SchType
			FROM BillAppliedSchemeHd A INNER JOIN TGQ B ON
			A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
			INNER JOIN TPQ C ON A.Schid = C.SchId and B.SchId = C.SchId AND A.SlabId=B.SlabId AND B.SlabId=C.SlabId
			--AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
			INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
			WHERE A.UsrId = @Pi_UsrId AND A.TransId = @Pi_TransId AND IsSelected = 1
			AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)	
			AND SM.SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
			AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
			GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
		END

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT DISTINCT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
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


--		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
--		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
--		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
--		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
--		Case WHEN QPS=1 THEN
--		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
--		ELSE  SchemeAmount END  As SchemeAmount
--		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
--		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
--		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
--		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
--		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
--		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
--		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
--		AND SM.CombiSch=0
--		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
--		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
--		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
--		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
--		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		--(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
		ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
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
		Case WHEN QPS=1 THEN
		--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		SchemeAmount 
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
		ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
		AND SM.CombiSch=1
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)		
		---->
	END

	INSERT INTO @FreeQtyDt (FreePrdid,FreePrdBatId,FreeQty)
	--SELECT FreePrdId,FreePrdBatId,Sum(FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
	SELECT FreePrdId,FreePrdBatId,Sum(DISTINCT FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY FreePrdId,FreePrdBatId

	INSERT INTO @FreeQtyRow (RowId,PrdId,PrdBatId)
	SELECT MIN(A.RowId) as RowId,A.Prdid,A.PrdBatId FROM BilledPrdHdForScheme A
	INNER JOIN BillAppliedSchemeHd B ON A.PrdId = B.PrdId AND
	A.PrdBatid = B.PrdBatId
	WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND
	B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId AND IsSelected = 1
	GROUP BY A.Prdid,A.PrdBatId

	UPDATE ApportionSchemeDetails SET FreeQty = A.FreeQty FROM
	@FreeQtyDt A INNER JOIN @FreeQtyRow B ON
	A.FreePrdId  = B.PrdId
	WHERE ApportionSchemeDetails.RowId = B.RowId
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

	UPDATE ApportionSchemeDetails SET SchemeAmount=SchemeAmount+SchAmt,SchemeDiscount=SchemeDiscount+SchDisc
	FROM 
	(SELECT SchId,SUM(SchemeAmount) SchAmt,SUM(SchemeDiscount) SchDisc FROM ApportionSchemeDetails
	WHERE RowId=10000 GROUP BY SchId) A,
	(SELECT SchId,MIN(RowId) RowId FROM ApportionSchemeDetails
	GROUP BY SchId) B
	WHERE ApportionSchemeDetails.SchId =  A.SchId AND A.SchId=B.SchId 
	AND ApportionSchemeDetails.RowId=B.RowId  
	DELETE FROM ApportionSchemeDetails WHERE RowId=10000
	INSERT INTO @RtrQPSIds
	SELECT DISTINCT RtrId,SchId FROM BilledPrdHdForQPSScheme WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	
--	INSERT INTO @QPSGivenDisc
--	SELECT A.SchId,SUM(A.DiscountPerAmount) FROM 
--	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount
--	FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
--	WHERE SchemeAmount=0) A,SchemeMaster SM ,SalesInvoice SI,@RtrQPSIds RQPS
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
--	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
--	AND SISl.SlabId<=A.SlabId) A	
--	GROUP BY A.SchId

	INSERT INTO @QPSGivenDisc
	SELECT A.SchId,SUM(A.DiscountPerAmount+A.FlatAmount) FROM 
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount,SISL.FlatAmount
	FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
	WHERE SchemeAmount=0
	) A,SchemeMaster SM ,SalesInvoice SI,@RtrQPSIds RQPS
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
	AND SISl.SlabId<=A.SlabId) A	
	GROUP BY A.SchId

	--SELECT 'N1',* FROM @QPSGivenDisc

	UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
	FROM @QPSGivenDisc A,
	(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,@RtrQPSIds QPS,SalesInvoice SI
	WHERE B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.RtrId=QPS.RtrId AND QPS.SchId=B.SchId
	GROUP BY B.SchId) C
	WHERE A.SchId=C.SchId 	

	SELECT 'N2',* FROM @QPSGivenDisc

	INSERT INTO @QPSGivenDisc
	SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,@RtrQPSIds QPS,SalesInvoice SI
	WHERE B.RtrId=QPS.RtrID AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenDisc)
	AND B.SchId IN(SELECT DISTINCT SchId FROM ApportionSchemeDetails WHERE SchemeAmount=0)
	AND SI.SalId=B.SalId AND SI.DlvSts>3
	GROUP BY B.SchId	

	UPDATE A SET A.Amount=A.Amount-S.Amount
	FROM @QPSGivenDisc A,
	(SELECT A.SchId,SUM(A.ReturnDiscountPerAmount+A.ReturnFlatAmount) AS Amount FROM 
	(SELECT DISTINCT SISL.ReturnId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.ReturnDiscountPerAmount,SISL.ReturnFlatAmount
	FROM ReturnSchemeLineDt SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
	WHERE SchemeAmount=0
	) A,SchemeMaster SM ,ReturnHeader SI,@RtrQPSIds RQPS
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.ReturnId=SISL.ReturnId AND SI.Status=0
	AND SISl.SlabId<=A.SlabId) A	
	GROUP BY A.SchId) S
	WHERE A.SchId=S.SchId 	

	SELECT 'N3',* FROM @QPSGivenDisc

	INSERT INTO @QPSNowAvailable
	SELECT A.SchId,SUM(SchemeDiscount)-ISNULL(B.Amount,0) 
	FROM ApportionSchemeDetails A
	INNER JOIN SchemeMaster	SM ON A.SchId=SM.SchId AND SM.QPS=1
	LEFT OUTER JOIN @QPSGivenDisc B ON A.SchId=B.SchId 
	GROUP BY A.SchId,B.Amount 

	SELECT * FROM @QPSNowAvailable

--	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
--	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId	

	SELECT * FROM ApportionSchemeDetails	
	SELECT * FROM BillQPSSchemeAdj

	UPDATE A SET A.Contri=100*(B.QPSGrossAmount/CASE C.QPSGrossAmount WHEN 0 THEN 1 ELSE C.QPSGrossAmount END)	
	FROM ApportionSchemeDetails A,@TempPrdGross B,@TempSchGross C,SchemeMaster SM
	WHERE A.TRansId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.RowId=B.RowId AND 
	A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatID AND A.SchId=B.SchId AND B.SchId=C.SchId AND SM.SchId=A.SchId AND SM.QPS=1 AND SM.ApyQPSSch=2
	
	SELECT * FROM ApportionSchemeDetails
	SELECT * FROM @QPSNowAvailable

	--->Modified By Nanda
--	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
--	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
--	AND ApportionSchemeDetails.SchId NOT IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId)	

	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId NOT IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId AND AdjAmount>0)	

	UPDATE ApportionSchemeDetails SET SchemeDiscount=0
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId AND AdjAmount=0)	
	-->Till Here

	UPDATE ASD SET SchemeAmount=Contri*AdjAmount/100,SchemeDiscount=(CASE SM.CombiSch+SM.QPS WHEN 2 THEN 0 ELSE SchemeDiscount END)
	FROM ApportionSchemeDetails ASD,BillQPSSchemeAdj A,SchemeMaster SM 
	WHERE ASD.SchId=A.SchId AND SM.SchId=A.SchId
	AND ASD.UsrId=A.UserId AND ASD.TransId=A.TransId	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-191-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GR_SchemeListing]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_GR_SchemeListing]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_GR_SchemeListing 'Scheme Listing','2010/12/01','2010/12/31','','','','','',''

CREATE PROCEDURE [dbo].[Proc_GR_SchemeListing]
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
	SELECT SchId,(ISNULL(SUM(CAST(FlatAmount AS NUMERIC(18,2)) - CAST(ReturnFlatAmount AS NUMERIC(18,2))),0) + 
	ISNULL(SUM(CAST(DiscountPerAmount AS NUMERIC(18,2)) - CAST(ReturnDiscountPerAmount AS NUMERIC(18,2))),0)) Amt, 0 AS Points
	INTO #Schutilised
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		WHERE DlvSts <> 3 AND SchId IN (SELECT SchId FROM #Filter) GROUP BY SchId
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

	SELECT SchCode [Scheme Code],sCHDSC [Scheme Description],Hierarchy3cap [Retailer Hierarchy 1],
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
	GROUP BY  SchCode ,sCHDSC ,Hierarchy1cap ,
	Hierarchy2Cap ,Hierarchy3cap , c.RtrCode ,RtrName ,Salinvno,
	CONVERT(VARCHAR(10),SalinvDate,121) ,PrdcCode ,PrdName ,PrdDCode ,MRP
	HAVING SUM(CAST(Amt AS NUMERIC(18,6)))+SUM(CAST(Points AS NUMERIC(18,0)))>0
	UNION ALL
	SELECT SchCode [Scheme Code],sCHDSC [Scheme Description],Hierarchy3cap [Retailer Hierarchy 1],
	Hierarchy2Cap [Retailer Hierarchy 2],Hierarchy1cap [Retailer Hierarchy 3], c.RtrCode [Retailer Code],RtrName [Retailer Name],Salinvno [Sales Invoice No.],
	CONVERT(VARCHAR(10),SalinvDate,121) [Sales Invoice Date],'','Window Display','' ,0,SUM(Amt) [Scheme Amount],0 AS [Points]
	FROM #SchUtilizedDetail a,SchemeMaster b,Retailer C,SalesInvoice D,Tbl_Gr_Build_Rh f
	WHERE 
	a.SchId=b.SchId  
	AND D.SalId=A.SalId 
	AND C.RtrId=A.RtrId
	and f.RtrId=d.RtrId and a.PrdId=0 AND Amt>0
	GROUP BY  SchCode ,sCHDSC ,Hierarchy1cap ,
	Hierarchy2Cap ,Hierarchy3cap , c.RtrCode ,RtrName ,Salinvno,
	CONVERT(VARCHAR(10),SalinvDate,121) 
	----------------------------------------------------------------------------------------------------------------------

	UPDATE #SchFinal SET Utilized=Amount
	FROM #SchFinal,#SchComp WHERE [Scheme Code]=SchCode AND Budget<>0

	UPDATE #SchFinal SET Balance=Budget-Utilized 
	WHERE Budget<>0

	SELECT 'Scheme Listing',* FROM #SchFinal	
	SELECT 'Detail Listing',* FROM #SchComp2
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-191-005

DELETE FROM Configuration WHERE ModuleId IN ('SALESRTN18','SALESRTN19')

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('SALESRTN18','Sales Return','Based on Slab Applied',1,'',0.00,1)

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('SALESRTN19','Sales Return','Based on Slab Eligible',0,'',0.00,1)

--SRF-Nanda-191-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnBilledSchemeDet]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnBilledSchemeDet]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM Fn_ReturnBilledSchemeDet(13237)

CREATE     FUNCTION [dbo].[Fn_ReturnBilledSchemeDet]
(
	@Pi_SalId BIGINT
)
RETURNS @BilledSchemeDet TABLE
(
	SchId			Int,
	SchCode			nVarChar(40),
	FlexiSch		TinyInt,
	FlexiSchType		TinyInt,
	SlabId			Int,
	SchType			INT,
	SchemeAmount		Numeric(38,6),
	SchemeDiscount		Numeric(38,6),
	Points			INT,
	FlxDisc			TINYINT,
	FlxValueDisc		TINYINT,
	FlxFreePrd		TINYINT,
	FlxGiftPrd		TINYINT,
	FlxPoints		TINYINT,
	FreePrdId 		INT,
	FreePrdBatId		INT,
	FreeToBeGiven		INT,
	GiftPrdId 		INT,
	GiftPrdBatId		INT,
	GiftToBeGiven		INT,
	NoOfTimes		Numeric(38,6),
	IsSelected		TINYINT,
	SchBudget		Numeric(38,6),
	BudgetUtilized		Numeric(38,6),
	LineType		TINYINT,
	PrdId			INT,
	PrdBatId		INT
)
AS
/*********************************
* FUNCTION: Fn_ReturnBilledSchemeDet
* PURPOSE: Returns the Scheme Details for the Selected Bill Number
* NOTES:
* CREATED: Thrinath Kola	02-05-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	--For Scheme On Another Product
	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
	ISNULL(SUM(FlatAmount),0)+ISNULL(SUM(F.CrNoteAmount),0) AS SchemeAmount,ISNULL(A.DiscPer,0) AS SchemeDiscount,
		ISNULL(E.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,0 as FreePrdId,
		0 as FreePrdBatId,0 as FreeToBeGiven,0 As GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType,A.PrdId,A.PrdBatId
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		LEFT OUTER JOIN SalesInvoiceSchemeDtPoints E ON E.SalId = A.SalId
		AND A.SchId = E.SchId AND A.SlabId = E.SlabId AND A.SchType=E.SchType
		LEFT OUTER JOIN 
		(SELECT TOP 1 A.SalId,A.SchId,B.PrdId,B.PrdBatId,ISNULL(A.CrNoteAmount,0) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj A 
		INNER JOIN SalesInvoiceSchemeLineWise B ON A.SalId = B.SalId AND A.SchId=B.SchId AND ISNULL(A.CrNoteAmount,0)>0
		WHERE A.SalId=@Pi_SalId) F ON A.SalId = F.SalId AND A.SchId=F.SchId AND ISNULL(F.CrNoteAmount,0)>0 AND A.PrdId=F.PrdId AND A.PrdBatId=F.PrdBatId
		WHERE A.SalId = @Pi_SalId
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,A.DiscPer,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,Budget,B.NoOfTimes,E.Points,A.PrdId,A.PrdBatId

	--For Normal Scheme 
	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		ISNULL(SUM(FlatAmount),0) AS SchemeAmount,ISNULL(A.DiscPer,0) AS SchemeDiscount,
		ISNULL(E.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,0 as FreePrdId,
		0 as FreePrdBatId,0 as FreeToBeGiven,0 As GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType, 0 AS PrdId,0 AS PrdBatId
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		LEFT OUTER JOIN SalesInvoiceSchemeDtPoints E ON E.SalId = A.SalId
		AND A.SchId = E.SchId AND A.SlabId = E.SlabId AND A.SchType=E.SchType
		WHERE A.SalId = @Pi_SalId AND A.SchId NOT IN (SELECT SchId FROM SchemeAnotherPrdHd) AND (ISNULL(FlatAmount,0)+ISNULL(A.DiscPer,0))>0 
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,A.DiscPer,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,Budget,B.NoOfTimes,E.Points

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,0 AS SchemeAmount,0 AS SchemeDiscount,
		0 As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId as FreePrdId,
		FreePrdBatId as FreePrdBatId,ISNULL(SUM(FreeQty),0) as FreeToBeGiven,GiftPrdId As GiftPrdId,
		GiftPrdBatId as GiftPrdBatId,ISNULL(SUM(GiftQty),0) as GiftToBeGiven,B.NoOfTimes,
	1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,2 as LineType,FreePrdId,FreePrdId
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId AND FreePrdId > 0
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId,
		A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId,C.Budget,B.NoOfTimes

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,0 AS SchemeAmount,0 AS SchemeDiscount,
		0 As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId as FreePrdId,
		FreePrdBatId as FreePrdBatId,ISNULL(SUM(FreeQty),0) as FreeToBeGiven,GiftPrdId As GiftPrdId,
		GiftPrdBatId as GiftPrdBatId,ISNULL(SUM(GiftQty),0) as GiftToBeGiven,B.NoOfTimes,
	1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,3 as LineType,GiftPrdId,GiftPrdBatId
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId AND GiftPrdId > 0
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,B.SlabId,B.SchType,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId,
		A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId,C.Budget,B.NoOfTimes

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,0 AS SchType,
		ISNULL(SUM(A.FlatAmount),0) AS SchemeAmount,ISNULL(SUM(A.DiscountPerAmount),0) AS SchemeDiscount,
		ISNULL(A.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,
		A.FreePrdId as FreePrdId,0 as FreePrdBatId,ISNULL(SUM(FreeQty),0) as FreeToBeGiven,
		0 As GiftPrdId,	0 as GiftPrdBatId,0 as GiftToBeGiven,
		0 AS NoOfTimes,0 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,0 as LineType,0,0
		FROM SalesInvoiceUnSelectedScheme A
		INNER JOIN SchemeMaster C ON A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON A.SchId = D.SchId AND A.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,A.Points,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,A.FreePrdId,C.Budget

	INSERT INTO  @BilledSchemeDet(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchType,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,
		FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,LineType,PrdId,PrdBatId)
	SELECT A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,B.SchType,
		0 AS SchemeAmount,0 AS SchemeDiscount,
		ISNULL(A.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,
		0 as FreePrdId,0 as FreePrdBatId,0 as FreeToBeGiven,
		0 As GiftPrdId,	0 as GiftPrdBatId,0 as GiftToBeGiven,
		B.NoOfTimes AS NoOfTimes,1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType,0,0
		FROM SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON A.SchId = D.SchId AND A.SlabId = D.SlabId
		WHERE A.SalId = @Pi_SalId --AND A.SalId Not IN (Select SalId From SalesInvoiceSchemeLineWise
			--WHERE SalId = @Pi_SalId)
		AND A.POints>0
		GROUP BY A.SchId,C.SchCode,C.FlexiSch,C.FlexiSchType,A.SlabId,B.SchType,A.Points,
		D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,C.Budget,B.NoOfTimes

		UPDATE @BilledSchemeDet SET SchemeDiscount = DiscountPercent
			FROM SalesInvoiceSchemeFlexiDt B, @BilledSchemeDet A WHERE B.SalId = @Pi_SalId
			AND A.SchId = B.SchId AND A.SlabId = B.SlabId AND A.FreeToBeGiven = 0
			AND A.GiftToBeGiven = 0

		UPDATE @BilledSchemeDet SET FlxDisc = 0,FlxValueDisc = 0,FlxPoints = 0
			WHERE FreeToBeGiven > 0 or GiftToBeGiven > 0

		DELETE FROM @BilledSchemeDet WHERE 
		((SchemeAmount)+(SchemeDiscount)+(Points)+
		(FlxDisc)+(FlxValueDisc)+(FlxFreePrd)+(FlxGiftPrd)+(FlxPoints)+(FreePrdId)+
		(FreePrdBatId)+(FreeToBeGiven)+(GiftPrdId)+(GiftPrdBatId)+(GiftToBeGiven))=0
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-191-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClusterMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClusterMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ClusterMaster 0
SELECT * FROM Cn2Cs_Prk_ClusterMaster
SELECT * FROM errorlog
ROLLBACK TRANSACTION
*/
CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_ClusterMaster]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClusterMaster
* PURPOSE		: To validate the downloaded Cluster details from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 30/07/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TabName		NVARCHAR(100)
	DECLARE @ErrDesc		NVARCHAR(1000)
	DECLARE @ClusterCode 	NVARCHAR(50)
	DECLARE @ClusterName  	NVARCHAR(100)
	DECLARE @Remarks	  	NVARCHAR(200)
	DECLARE @Salesman		NVARCHAR(10)
	DECLARE @Retailer		NVARCHAR(10)
	DECLARE @AddMast1  		NVARCHAR(10)
	DECLARE @AddMast2  		NVARCHAR(10)
	DECLARE @AddMast3  		NVARCHAR(10)
	DECLARE @AddMast4  		NVARCHAR(10)
	DECLARE @AddMast5  		NVARCHAR(10)
	DECLARE @ClusterId  	INT
	DECLARE @Exist		 	INT
	DECLARE @Value			NUMERIC(38,6)
	DECLARE @PrdCtgLevelCode	NVARCHAR(100)
	DECLARE @CmpPrdCtgId  	INT
	SET @TabName = 'Cn2Cs_Prk_ClusterMaster'
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClsToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClsToAvoid	
	END
	CREATE TABLE ClsToAvoid
	(
		ClusterCode NVARCHAR(50)
	)
	IF EXISTS(SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
	WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))='')
	BEGIN
		INSERT INTO ClsToAvoid(ClusterCode)
		SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
		WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Master','ClusterCode','Cluster Code/Name Should not be empty' FROM Cn2Cs_Prk_ClusterMaster
		WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))=''
	END		
	IF EXISTS(SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
	WHERE PrdCtgLevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel WHERE LevelName<>'Level1') AND AddMast1='Yes')
	BEGIN
		INSERT INTO ClsToAvoid(ClusterCode)
		SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
		WHERE PrdCtgLevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel WHERE LevelName<>'Level1') AND AddMast1='Yes'
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Master','ClusterCode','Product Category Level:'+PrdCtgLevelCode+' not found' FROM Cn2Cs_Prk_ClusterMaster
		WHERE PrdCtgLevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel WHERE LevelName<>'Level1') AND AddMast1='Yes'
	END
	
	DECLARE Cur_ClusterMaster CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([ClusterCode])),''),ISNULL(LTRIM(RTRIM([ClusterName])),''),ISNULL(LTRIM(RTRIM([Remarks])),''),
	ISNULL(LTRIM(RTRIM([Salesman])),'No'),ISNULL(LTRIM(RTRIM([Retailer])),'No'),ISNULL(LTRIM(RTRIM([AddMast1])),'No'),
	ISNULL(LTRIM(RTRIM([AddMast2])),'No'),ISNULL(LTRIM(RTRIM([AddMast3])),'No'),ISNULL(LTRIM(RTRIM([AddMast4])),'No'),
	ISNULL(LTRIM(RTRIM([AddMast5])),'No'),ISNULL([Value],0),ISNULL(LTRIM(RTRIM(PrdCtgLevelCode)),'')
	FROM Cn2Cs_Prk_ClusterMaster WHERE [DownLoadFlag] ='D' AND
	ClusterCode NOT IN (SELECT ClusterCode FROM ClsToAvoid)
	OPEN Cur_ClusterMaster
	FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,
	@AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5,@Value,@PrdCtgLevelCode
	WHILE @@FETCH_STATUS=0
	BEGIN		
		SET @Po_ErrNo=0
		SET @Exist=0
		IF @AddMast1='Yes'
		BEGIN
			SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpPrdCtgName=@PrdCtgLevelCode
		END
		ELSE
		BEGIN
			SET @CmpPrdCtgId=0
		END
		IF NOT EXISTS (SELECT * FROM ClusterMaster WHERE ClusterCode=@ClusterCode)
		BEGIN			
			SET @ClusterId = dbo.Fn_GetPrimaryKeyInteger('ClusterMaster','ClusterId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			SET @Exist=0			
			IF @ClusterId<=(SELECT ISNULL(MAX(ClusterId),0) AS ClusterId FROM ClusterMaster)
			BEGIN
				SELECT @ClusterId
				SET @ErrDesc = 'Reset the counters/Check the system date'
				INSERT INTO Errorlog VALUES (67,@TabName,'ClusterId',@ErrDesc)
				SET @Po_ErrNo =1
			END
		END
		ELSE
		BEGIN
			SELECT @ClusterId=ClusterId FROM ClusterMaster WHERE ClusterCode=@ClusterCode			
			SET @Exist=1
		END		
		
		IF @Exist=1
		BEGIN
			EXEC Proc_DependencyCheck 'ClusterMaster',@ClusterId
			IF (SELECT COUNT(*) FROM TempDepCheck)>0
			BEGIN
				SET @Exist=2
			END			
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @Exist=0
			BEGIN
				INSERT INTO ClusterMaster(ClusterId,ClusterCode,ClusterName,Remarks,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,ClusterValues)			
				VALUES(@ClusterId,@ClusterCode,@ClusterName,@Remarks,1,1,1,GETDATE(),1,GETDATE(),@Value)
			
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ClusterMaster' AND FldName='ClusterId'	
				DELETE FROM ClusterDetails WHERE ClusterId=@ClusterId
				
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),0
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,79,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),0
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,91,'Product',(CASE @AddMast1 WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),@CmpPrdCtgId
			END		
			ELSE IF @Exist=1
			BEGIN
				UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks
				WHERE ClusterId=@ClusterId			
				
				DELETE FROM ClusterDetails WHERE ClusterId=@ClusterId

				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),0
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,79,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),0
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,91,'Product',(CASE @AddMast1 WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),@CmpPrdCtgId
			END
			ELSE IF @Exist=2
			BEGIN
				UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks
				WHERE ClusterId=@ClusterId			
			END
		END
		FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,
		@AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5,@Value,@PrdCtgLevelCode
	END
	CLOSE Cur_ClusterMaster
	DEALLOCATE Cur_ClusterMaster

	UPDATE Cn2Cs_Prk_ClusterMaster SET DownLoadFlag='Y' WHERE
	DownLoadFlag ='D' AND ClusterCode IN (SELECT ClusterCode FROM ClusterMaster)
	AND CLusterCode NOT IN (SELECT ClusterCode FROM ClsToAvoid)

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-191-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBenchMark]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBenchMark]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [Proc_RptBenchMark] 203,2,0,'TEST',0,0,1

CREATE                 PROCEDURE [dbo].[Proc_RptBenchMark]
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
* VIEW	: Proc_RptDRCPDeviation
* PURPOSE	: To get the Route Coverage deviation details
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 12/11/2007
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
	DECLARE @ExcelFlag AS INT
	DECLARE @FromDate AS DATETIME
	DECLARE @ToDate AS DATETIME
	DECLARE @RtrId AS INT
	DECLARE @RMId AS INT
	DECLARE @SMId AS INT
	DECLARE @CmpId AS INT
	DECLARE @CtgLevelId AS INT
	DECLARE @CtgMainId AS INT
	DECLARE @RtrClassId AS INT

	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @CtgLevelId = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
	SET @CtgMainId = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
	SET @RtrClassId = (SELECT  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	Create TABLE #RptBenchMarkSales
	(
		SMId INT,
		SMName NVARCHAR(200),
		RMId INT,
		RMName NVARCHAR(200),
		RtrId INT,
		RtrName NVARCHAR(200),
		BMPrdId INT,
		BMPrdCode NVARCHAR(200),
		BMPrdName NVARCHAR(200),
		BMPrdSalesQty INT,
		BMPrdSalesValue NUMERIc(38,2),
		AnlPrdId INT,
		AnlPrdCode NVARCHAR(200),
		AnlPrdName NVARCHAR(200),
		AnlPrdSalesQty INT,
		AnlPrdSalesValue NUMERIc(38,2)		
	)
	SET @TblName = 'RptBenchMarkSales'
	SET @TblStruct = '	SMId INT,
			SMName NVARCHAR(200),
			RMId INT,
			RMName NVARCHAR(200),
			RtrId INT,
			RtrName NVARCHAR(200),
			BMPrdId INT,
			BMPrdCode NVARCHAR(200),
			BMPrdName NVARCHAR(200),
			BMPrdSalesQty INT,
			BMPrdSalesValue NUMERIc(38,2),
			AnlPrdId INT,
			AnlPrdCode NVARCHAR(200),
			AnlPrdName NVARCHAR(200),
			AnlPrdSalesQty INT,
			AnlPrdSalesValue NUMERIc(38,2)'
	SET @TblFields = 'SMId,SMName,RMId,RMName,RtrId,RtrName,BMPrdId,BMPrdCode,
					BMPrdName,BMPrdSalesQty,BMPrdSalesValue,AnlPrdId,AnlPrdCode,AnlPrdName,
					AnlPrdSalesQty,AnlPrdSalesValue'
	IF @Pi_GetFromSnap = 1
	   BEGIN
		SELECT @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
		SET @DBNAME = @DBNAME
	   END
	ELSE
BEGIN
		SELECT @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo =3
		SET @DBNAME = @PI_DBNAME + @DBNAME
END
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	   BEGIN
		SELECT @Pi_RptId,@Pi_UsrId

		EXEC Proc_BenchMarkSales @Pi_RptId,@Pi_UsrId
		INSERT INTO #RptBenchMarkSales (SMId,SMName,RMId,RMName,RtrId,RtrName,BMPrdId,BMPrdCode,
					BMPrdName,BMPrdSalesQty,BMPrdSalesValue,AnlPrdId,AnlPrdCode,
					AnlPrdName,AnlPrdSalesQty,AnlPrdSalesValue)
				SELECT SMId,SMName,RMId,RMName,RtrId,RtrName,
						BenPrdId,BenPrdDCode,BenPrdName,BenSalesQty,BenSalesValue,
						PrdId,PrdDCode,PrdName,SalesQty,SalesValue
				FROM TempBenchMarkAnlSales
				WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
				
				
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptBenchMarkSales ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ 'WHERE (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '
				+ 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
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
					' SELECT ' + CAST(@NewSnapId AS NVARCHAR(10)) +
					' ,' + CAST(@Pi_UsrId AS NVARCHAR(10)) +
					' ,' + CAST(@Pi_RptId AS NVARCHAR(10)) + ', * FROM #RptBenchMarkSales'
		
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
			SET @SSQL = 'INSERT INTO #RptBenchMarkSales ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
				' WHERE SNAPID = ' + CAST(@Pi_SnapId AS NVARCHAR(10)) +
				' AND UserId = ' + CAST(@Pi_UsrId AS NVARCHAR(10)) +
				' AND RptId = ' + CAST(@Pi_RptId AS NVARCHAR(10))
			EXEC (@SSQL)
			PRINT 'Retrived Data From Snap Shot Table'
		   END
		ELSE
		   BEGIN
			PRINT 'DataBase or Table not Found'
		   END
END
	--Check for Report Data
	DELETE FROM RptDataCount WHERE  RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) AS RecCount,@ErrNo,@Pi_UsrId FROM #RptBenchMarkSales
	-- Till Here
	SELECT * FROM #RptBenchMarkSales


	SELECT @ExcelFlag=Flag FROM RptExcelFlag WHERE RptId= @Pi_RptId AND UsrId=@Pi_UsrId
	IF @ExcelFlag = 1
	BEGIN
		/***************************************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE @CSMId AS INT
		DECLARE  @CSMName AS NVARCHAR(200)
		DECLARE  @CRMId AS INT
		DECLARE  @CRMName AS NVARCHAR(200)
		DECLARE  @CRtrId AS INT
		DECLARE  @CRtrName AS NVARCHAR(200)
		DECLARE  @CBMPrdId AS INT
		DECLARE  @CBMPrdCode AS NVARCHAR(200)
		DECLARE  @CBMPrdName AS NVARCHAR(200)
		DECLARE  @CBMPrdSalesQty INT
		DECLARE  @CBMPrdSalesValue NUMERIC(38,2)
		DECLARE  @CAnlPrdName AS NVARCHAR(200)
		DECLARE  @CAnlPrdSalesQty AS INT
		DECLARE  @CAnlPrdSalesValue  AS NUMERIC(38,6)
		DECLARE  @CAnlSalesValue AS NVARCHAR(200)
		DECLARE  @CAnlSalesQty AS NVARCHAR(200)
		DECLARE  @SalesValue NUMERIC(38,6)
		DECLARE  @TotalValue NUMERIC(38,6)
		DECLARE  @Column1 NVARCHAR(80)
		DECLARE  @Column2 NVARCHAR(80)
		DECLARE  @Column3 NVARCHAR(80)
		DECLARE  @Column4 NVARCHAR(80)
		DECLARE  @Column5 NVARCHAR(80)
		DECLARE  @C_SSQL NVARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @Name NVARCHAR(100)
		DECLARE  @XType AS INT
		DECLARE @AnlCntId AS INT
		DECLARE @AnlColName1 AS NVARCHAR(25)
		DECLARE @AnlColName2 AS NVARCHAR(25)
		DECLARE @AnlColName3 AS NVARCHAR(25)
		DECLARE @OldCode AS NVARCHAR(100)
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptBenchMarkSales_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptBenchMarkSales_Excel]
		DELETE FROM RptExcelHeaders WHERE RptId=@Pi_RptId AND SlNo>11
		CREATE TABLE [RptBenchMarkSales_Excel] (RptId INT,UsrId INT,SMId INT,RMId INT,RtrId INT,BMPrdId INT,
			SMName NVARCHAR(100),RMName NVARCHAR(100),
			RtrName NVARCHAR(100),BMPrdCode NVARCHAR(100),BMPrdName NVARCHAR(100),
			BMPrdSalesQty INT,BMPrdSalesValue NUMERIC(38,2))
		SET @iCnt=12
		SET @AnlCntId=0
		SET @AnlColName1='Analysis Product 1'
		SET @AnlColName2='Sales Qty 1'
		SET @AnlColName3='Sales Value 1'
		DECLARE Crosstab_Cur CURSOR FOR
		SELECT DISTINCT AnlPrdName,AnlPrdCode+' Sales Qty',AnlPrdCode+' Sales Value' FROM #RptBenchMarkSales
		OPEN Crosstab_Cur
			   FETCH NEXT FROM Crosstab_Cur INTO @Column1,@Column2,@Column3
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @AnlCntId =@AnlCntId+1
					SET @AnlColName1 ='Analysis Product '+ CAST(@AnlCntId AS NVARCHAR(10))
					SET @AnlColName2 ='Sales Qty '+ CAST(@AnlCntId AS NVARCHAR(10))
					SET @AnlColName3 ='Sales Value '+ CAST(@AnlCntId AS NVARCHAR(10))
					SET @C_SSQL='ALTER TABLE [RptBenchMarkSales_Excel] ADD ['+ @AnlColName1 +'] NVARCHAR(100)'
					EXEC (@C_SSQL)
					SET @C_SSQL='ALTER TABLE [RptBenchMarkSales_Excel] ADD ['+ @AnlColName2 +'] INT'
					EXEC (@C_SSQL)
					SET @C_SSQL='ALTER TABLE [RptBenchMarkSales_Excel] ADD ['+ @AnlColName3 +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS NVARCHAR(10))+ ',' + CAST(@iCnt AS NVARCHAR(10))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@AnlColName1 AS NVARCHAR(200))+']'','''+ CAST(@AnlColName1 AS NVARCHAR(200))+''',1,1)'
					EXEC (@C_SSQL)
			
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS NVARCHAR(10))+ ',' + CAST(@iCnt AS NVARCHAR(10))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@AnlColName2 AS NVARCHAR(200))+']'','''+ CAST(@AnlColName2 AS NVARCHAR(200))+''',1,1)'
					EXEC (@C_SSQL)
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS NVARCHAR(10))+ ',' + CAST(@iCnt AS NVARCHAR(10))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@AnlColName3 AS NVARCHAR(200))+']'','''+ CAST(@AnlColName3 AS NVARCHAR(200))+''',1,1)'
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
					FETCH NEXT FROM Crosstab_Cur INTO @Column1,@Column2,@Column3
				END
		CLOSE Crosstab_Cur
		DEALLOCATE Crosstab_Cur
		--Insert table values
		DELETE FROM RptBenchMarkSales_Excel
		INSERT INTO RptBenchMarkSales_Excel (RptId,UsrId,SMId,RMId,RtrId,BMPrdId,SMName,RMName,RtrName,BMPrdCode,BMPrdName,
								BMPrdSalesQty,BMPrdSalesValue)
		SELECT DISTINCT @Pi_RptId,@Pi_UsrId,SMId,RMId,RtrId,BMPrdId,SMName,RMName,RtrName,BMPrdCode,BMPrdName,
								BMPrdSalesQty,BMPrdSalesValue FROM #RptBenchMarkSales
		SET @AnlCntId=1
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT SMId,SMName,RMId,RMName,RtrId,RtrName,BMPrdId,BMPrdCode,BMPrdName,AnlPrdName,
					SUM(AnlPrdSalesQty),SUM(AnlPrdSalesValue),A.AnlPrdCode,AnlPrdCode
					FROM #RptBenchMarkSales A GROUP BY SMId,SMName,RMId,RMName,RtrId,RtrName,BMPrdId,BMPrdCode,
					BMPrdName,AnlPrdName,AnlPrdCode ORDER BY A.AnlPrdCode
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @CSMId,@CSMName,@CRMId,@CRMName,@CRtrId,@CRtrName,@CBMPrdId,@CBMPrdCode,@CBMPrdName,
												@CAnlPrdName,@CAnlPrdSalesQty,@CAnlPrdSalesValue,@CAnlSalesQty,@CAnlSalesValue
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					
					IF @OldCode <> @CAnlSalesQty
					BEGIN
						SET @AnlCntId =@AnlCntId+1
					END
					ELSE
					BEGIN
						IF @OldCode = @CAnlSalesQty
						BEGIN
							SET @CAnlPrdName=''
						END
					END
					
					SET @AnlColName1 ='Analysis Product '+ CAST(@AnlCntId AS NVARCHAR(100))
					SET @AnlColName2 ='Sales Qty '+ CAST(@AnlCntId AS NVARCHAR(100))					
					SET @AnlColName3 ='Sales Value '+ CAST(@AnlCntId AS NVARCHAR(100))
					--SET @C_SSQL='UPDATE RptBenchMarkSales_Excel SET ['+ @CAnlPrdName +']= '''+ CAST(@CAnlPrdName AS NVARCHAR(1000))+''',
					SET @C_SSQL='UPDATE RptBenchMarkSales_Excel SET ['+ @AnlColName1 +']= '''+ CAST(@CAnlPrdName AS NVARCHAR(300))+''',
					['+ @AnlColName2 +']= '+ CAST(@CAnlPrdSalesQty AS NVARCHAR(100))+',['+ @AnlColName3 +']= '+ CAST(@CAnlPrdSalesValue AS NVARCHAR(100))+''
					SET @C_SSQL=@C_SSQL+ ' WHERE SMId =' + CAST(@CSMId AS NVARCHAR(10)) + '
					AND RMId=' + CAST(@CRMId AS NVARCHAR(10))+' AND  RtrId=' + CAST(@CRtrId As NVARCHAR(10)) + '
					AND BMPrdId =' + CAST(@CBMPrdId AS NVARCHAR(10)) + ' AND RptId =' + CAST(@Pi_RptId AS NVARCHAR(10)) + ' AND UsrId =' + CAST(@Pi_UsrId AS NVARCHAR(10)) + '  '
					--PRINT @C_SSQL
					EXEC (@C_SSQL)
					SET @OldCode=@CAnlSalesQty
					FETCH NEXT FROM Values_Cur INTO @CSMId,@CSMName,@CRMId,@CRMName,@CRtrId,@CRtrName,@CBMPrdId,@CBMPrdCode,@CBMPrdName,
												@CAnlPrdName,@CAnlPrdSalesQty,@CAnlPrdSalesValue,@CAnlSalesQty,@CAnlSalesValue
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		
		SET @iCnt=0		
		SELECT @iCnt=Count(*) FROM RptBenchMarkSales_Excel WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
		IF @iCnt <> 0
		BEGIN
			INSERT INTO RptBenchMarkSales_Excel (SMId,SMName,RMId,RMName,RtrId,RtrName,BMPrdId,BMPrdCode,BMPrdName,RptID,UsrId)
			SELECT DISTINCT 0,'',0,'',0,'',0,'','Total',RptID,UsrId FROM RptBenchMarkSales_Excel WITH (NOLOCK)
		END
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name,XType FROM dbo.sysColumns where id = object_id(N'[RptBenchMarkSales_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name,@XType
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					IF @XType=167
					BEGIN
						SET @C_SSQL='UPDATE [RptBenchMarkSales_Excel] SET ['+ @Name +']= '''''
					END
					ELSE
					BEGIN
						SET @C_SSQL='UPDATE [RptBenchMarkSales_Excel] SET ['+ @Name +']= '+ CAST(0 AS NVARCHAR(1000))
					END
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name,@XType
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		SET @TotalValue=0.00
		DECLARE TotalCursor_Cur CURSOR FOR
		SELECT Name,XType FROM dbo.sysColumns where id = object_id(N'[RptBenchMarkSales_Excel]') AND ColId>11
		OPEN TotalCursor_Cur
			   FETCH NEXT FROM TotalCursor_Cur INTO @Name,@XType
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					IF @XType<>167
					BEGIN
						SET @TotalValue=0.00
						IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[Value]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
							DROP TABLE [Value]
						IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[TotalSales]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
							DROP TABLE [TotalSales]
						SET @C_SSQL= 'SELECT ['+ CAST(@Name AS NVARCHAR(100))  + '] AS SalesValue INTO [Value] FROM RptBenchMarkSales_Excel WHERE RptId=' + CAST(@Pi_RptID AS NVARCHAR(1000)) + ' AND UsrId= ' + CAST(@Pi_UsrId AS NVARCHAR(1000)) + ''
						EXEC (@C_SSQL)
						SELECT SUM(CAST(SalesValue AS NUMERIC (38,6))) AS TotalSales INTO TotalSales FROM [Value]
						SELECT @TotalValue=TotalSales FROM TotalSales
						
						SET @C_SSQL='UPDATE RptBenchMarkSales_Excel SET ['+ CAST(@Name AS NVARCHAR(1000)) +']= '+ CAST(@TotalValue AS NVARCHAR(1000))
						SET @C_SSQL=@C_SSQL + ' WHERE BMPrdName=''Total'' AND RptId=' + CAST(@Pi_RptId AS NVARCHAR(1000)) + ' AND UsrId=' + + CAST(@Pi_UsrId AS NVARCHAR(1000)) + ''
						--PRINT @C_SSQL
						EXEC (@C_SSQL)
					END
					--PRINT @C_SSQL
					FETCH NEXT FROM TotalCursor_Cur INTO @Name,@XType
				END
		CLOSE TotalCursor_Cur
		DEALLOCATE TotalCursor_Cur
		--Cursors
		/***************************************************************************************************************************/
	END
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if not exists (select * from hotfixlog where fixid = 356)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(356,'D','2011-01-06',getdate(),1,'Core Stocky Service Pack 356')
