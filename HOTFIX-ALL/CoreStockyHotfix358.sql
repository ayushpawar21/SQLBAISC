--[Stocky HotFix Version]=358
Delete from Versioncontrol where Hotfixid='358'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('358','2.0.0.5','D','2011-01-19','2011-01-19','2011-01-19',convert(varchar(11),getdate()),'Parle;Major:QPS Reset changes and additional validations;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 358' ,'358'
GO

--SRF-Nanda-193-001

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyCombiSchemeInBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyCombiSchemeInBill]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--EXEC Proc_ApplyCombiSchemeInBill 72,3789,0,1,2
--UPDATE SchemeMaster SET QPSReset=1 WHERE SchId=552
DELETE FROM BillAppliedSchemeHd
EXEC Proc_ApplyCombiSchemeInBill 552,226,0,2,2
-- DELETE FROM BillAppliedSchemeHd
-- SELECT * FROM BillAppliedSchemeHd
--EXEC Proc_ApportionSchemeAmountInLine 1,2
-- SELECT * FROM ApportionSchemeDetails
-- SELECT * FROM BillAppliedSchemeHd
-- SELECT * FROM BilledPrdHdForScheme
--DELETE FROM ApportionSchemeDetails
--DELETE FROM BillAppliedSchemeHd
-- UPDATE BillAppliedSchemeHd SET IsSelected = 1
SELECT * FROM BilledPrdHdForQPSScheme
ROLLBACK TRANSACTION
*/

CREATE        Procedure [dbo].[Proc_ApplyCombiSchemeInBill]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT		
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

	DECLARE @QPSGivenFlat TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)

	DECLARE @QPSGivenFlatAmt AS NUMERIC(38,6)

	DECLARE @QPSGivenPoints TABLE
	(
		SchId   INT,		
		Points  NUMERIC(38,0)
	)


	SELECT @SchCode = SchCode,@SchType = SchType,@BatchLevel = BatchLevel,@FlexiSch = FlexiSch,
		@FlexiSchType = FlexiSchType,@CombiScheme = CombiSch,@SchLevelId = SchLevelId,@ProRata = ProRata,
		@Qps = QPS,@QpsReset = QPSReset,@QPSBasedOn=ApyQPSSch,@SchemeBudget = Budget,@PurOfEveryReq = PurofEvery,
		@SchemeLvlMode = SchemeLvlMode,@SchValidTill=SchValidTill,@SchValidFrom=SchValidFrom
	FROM SchemeMaster WHERE SchId = @Pi_SchId AND MasterType=1
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
--			SELECT * FROM @TempBilled1
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
	--		SELECT * FROM @TempBilled1
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
--			SELECT '11',* FROM @TempBilled1
			IF @QPSBasedOn=1 OR (@QPSBasedOn<>1 AND @FlexiSch=1)
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
					-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
					-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
					FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
					AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
			END

--			SELECT '22',* FROM @TempBilled1
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
			SELECT PrdId,PrdBatId,ISNULL(SUM(SumQty),0) AS SchemeOnQty,
				ISNULL(SUM(SumValue),0) AS SchemeOnAmount,ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
				ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
				FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
				GROUP BY PrdId,PrdBatId

--			SELECT '33',* FROM @TempBilled1
	END

	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
	SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
	ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
	GROUP BY PrdId,PrdBatId,SchId
--	SELECT 'N',* FROM @TempBilled1
--	SELECT @SchemeLvlMode
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
	--SELECT 'N',* FROM @TempHier
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
		SELECT DISTINCT A.* FROM @TempBilledAch A
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
		
		--SELECT * FROM @TempBilledCombiAch WHERE SlabId = @SlabId ORDER BY FrmSchAch DESC
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
		

		SELECT 'NoOf',* FROM @TempBilledCombiAch

		--To Get the Number of Times the Scheme should apply
		SELECT @NoOfTimes = ISNULL(MIN(NoOfTimes),1) FROM
			(SELECT FLOOR(FrmSchAch / (CASE FromQty WHEN 0 THEN 1 ELSE FROMQTY END)) AS NoOfTimes
			FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId) AS A
		
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
			SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
					FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
					ORDER BY FrmSchAch Desc
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

--		SELECT '@TempSchSlabAmt',* FROM @TempSchSlabAmt
--		DELETE FROM @QPSGivenFlat
--		--->Added By Nanda on 29/10/2010
--		IF EXISTS(SELECT * FROM @TempSchSlabAmt WHERE DiscPer=0)
--		BEGIN
--			DELETE FROM @QPSGivenFlat
--			INSERT INTO @QPSGivenFlat
--			SELECT SchId,SUM(FlatAmount)
--			FROM
--			(
--				SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount,0) AS FlatAmount
--				FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM,SalesInvoice SI
--				WHERE SM.QPS=1 AND FlexiSch=0 
--				AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3			
--			) A
--			GROUP BY A.SchId			
--		END
--
--		SELECT 'SS1',@Pi_TransId,@Pi_UsrId,@Pi_RtrId
--		SELECT 'SS1',* FROM @QPSGivenFlat
--
--		UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
--		FROM @QPSGivenFlat A,
--		(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
--		WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND SI.SalId=B.SalId AND SI.DlvSts>3
--		GROUP BY B.SchId) C
--		WHERE A.SchId=C.SchId 
--
--		INSERT INTO @QPSGivenFlat
--		SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B,SalesInvoice SI
--		WHERE B.RtrId=@Pi_RtrId AND B.SchId=@Pi_SchId AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenFlat)
--		AND B.SchId IN (SELECT DISTINCT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId AND SchemeDiscount=0)
--		AND SI.SalId=B.SalId AND SI.DlvSts>3
--		GROUP BY B.SchId
--
--		SELECT 'SS1',* FROM @QPSGivenFlat
--
--		SELECT @QPSGivenFlatAmt=ISNULL(SUM(Amount),0) FROM @QPSGivenFlat WHERE SchId=@Pi_SchId
--
--		DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
--		INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
--		SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat
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

--			UPDATE @TempSchSlabAmt SET FlatAmt=FlatAmt-@QPSGivenFlatAmt

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
					--((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
					FlatAmt * @NoOfTimes
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

	------
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

	SELECT * FROM BillAppliedSchemeHd 
	SELECT * FROM BilledPrdHdForScheme 

	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId

	UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
	SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
	TransId = @Pi_TransId AND Usrid = @Pi_UsrId

	---Added By Nanda on 18/01/2011
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

	DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
	INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
	SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat

	--->Added By Nanda for Points on 10/01/2011  
	INSERT INTO @QPSGivenPoints
	SELECT SchId,SUM(Points)
	FROM
	(
		SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(Points-ReturnPoints,0) AS Points
		FROM SalesInvoiceSchemeDtPoints SISL,SchemeMaster SM ,
		(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd) A,
		SalesInvoice SI
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3	
	) A
	WHERE SchId=@Pi_SchId
	GROUP BY A.SchId	
	--->Till Here

	--->For Scheme Amount Update
	UPDATE BillAppliedSchemeHd SET SchemeAmount=CAST(SchemeAmount-Amount AS NUMERIC(38,4))
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	

	--->For Scheme Points Update
	UPDATE BillAppliedSchemeHd SET BillAppliedSchemeHd.Points=CAST(BillAppliedSchemeHd.Points-A.Points AS NUMERIC(38,4))
	FROM @QPSGivenPoints A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
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
			AND BillAppliedSchemeHd.SlabId=@MaxSlabId AND A.SchId=BillAppliedSchemeHd.SchId
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs

	--->For Points QPS Reset
	SET @MSSchId=0
	SET @MaxSlabId=0
	DECLARE @PointsToReduced AS NUMERIC(38,0)

	DECLARE Cur_QPSSlabsPoints CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabsPoints
	FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenPoints WHERE SchId=@MSSchId)
			BEGIN
				SELECT @PointsToReduced=Points FROM BillAppliedSchemeHd 
				WHERE SlabId=@MaxSlabId AND SchId=@MSSchId

				UPDATE BillAppliedSchemeHd SET Points=0
				WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
			END
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHd SET BillAppliedSchemeHd.Points=BillAppliedSchemeHd.Points+@PointsToReduced-A.Points
			FROM  @QPSGivenPoints A WHERE BillAppliedSchemeHd.SchId=@MSSchId 
			AND BillAppliedSchemeHd.SlabId=@MaxSlabId AND A.SchId=BillAppliedSchemeHd.SchId
		END
		FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabsPoints
	DEALLOCATE Cur_QPSSlabsPoints
	--->Till Here

	DELETE FROM BillAppliedSchemeHd WHERE SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd=0

	IF @QPSReset<>0
	BEGIN
		UPDATE B SET B.NoOfTimes=A.NoOfTimes,B.SchemeAmount=A.SchemeAmount
		FROM BillAppliedSchemeHd B,(SELECT SchId,SlabId,MAX(NoOfTimes) AS NoOfTimes,MAX(SchemeAmount) AS SchemeAmount
			FROM BillAppliedSchemeHd GROUP BY SchId,SlabId) AS A
		WHERE B.SchId=A.SchId AND B.SlabId=A.SlabId AND B.SchId=@Pi_SchId
	END
	--->Till Here

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
		END
	END
	--Till Here
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-193-002

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
EXEC Proc_ApplyQPSSchemeInBill 557,127,0,2,2
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

	DECLARE @QPSGivenPoints TABLE
	(
		SchId   INT,		
		Points  NUMERIC(38,0)
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

	DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
	INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
	SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat

	--->Added By Nanda for Points on 10/01/2011  
	INSERT INTO @QPSGivenPoints
	SELECT SchId,SUM(Points)
	FROM
	(
		SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(Points-ReturnPoints,0) AS Points
		FROM SalesInvoiceSchemeDtPoints SISL,SchemeMaster SM ,
		(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd) A,
		SalesInvoice SI
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3	
	) A  
	WHERE SchId=@Pi_SchId
	GROUP BY A.SchId	
	--->Till Here

	--->For Scheme Amount Update
	UPDATE BillAppliedSchemeHd SET SchemeAmount=CAST(SchemeAmount-Amount AS NUMERIC(38,4))
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	

	--->For Scheme Points Update
	UPDATE BillAppliedSchemeHd SET BillAppliedSchemeHd.Points=CAST(BillAppliedSchemeHd.Points-A.Points AS NUMERIC(38,4))
	FROM @QPSGivenPoints A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
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
			AND BillAppliedSchemeHd.SlabId=@MaxSlabId AND A.SchId=BillAppliedSchemeHd.SchId
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs

	--->For Points QPS Reset
	SET @MSSchId=0
	SET @MaxSlabId=0
	DECLARE @PointsToReduced AS NUMERIC(38,0)

	DECLARE Cur_QPSSlabsPoints CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabsPoints
	FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenPoints WHERE SchId=@MSSchId)
			BEGIN
				SELECT @PointsToReduced=Points FROM BillAppliedSchemeHd 
				WHERE SlabId=@MaxSlabId AND SchId=@MSSchId

				UPDATE BillAppliedSchemeHd SET Points=0
				WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
			END
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHd SET BillAppliedSchemeHd.Points=BillAppliedSchemeHd.Points+@PointsToReduced-A.Points
			FROM  @QPSGivenPoints A WHERE BillAppliedSchemeHd.SchId=@MSSchId 
			AND BillAppliedSchemeHd.SlabId=@MaxSlabId AND A.SchId=BillAppliedSchemeHd.SchId
		END
		FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabsPoints
	DEALLOCATE Cur_QPSSlabsPoints
	--->Till Here

	DELETE FROM BillAppliedSchemeHd WHERE SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd=0

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

--SRF-Nanda-193-003

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
SELECT * FROM ApportionSchemeDetails WHERE TransId=2
SELECT * FROM BillQPSSchemeAdj 
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
				CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First CASE Start
					WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
						CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) --Second CASE Start
							WHEN 1 THEN  
								D.PrdBatDetailValue  
							ELSE 0 
						END     --Second CASE End
					ELSE 0 
				END) + SchemeDiscount)/100))      --First CASE END
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
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First CASE Start
			WHEN CAST(F.SchId AS NVARCHAR(10))+'-'+CAST(F.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second CASE Start
			 D.PrdBatDetailValue  END     --Second CASE End
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
			CASE WHEN QPS=1 THEN
			--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount,
			C.GrossAmount - (C.GrossAmount /(1 +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First CASE Start
			WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second CASE Start
			D.PrdBatDetailValue  ELSE 0 END     --Second CASE End
			ELSE 0 END) + SchemeDiscount)/100))       --First CASE END
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
		---->For QPS Reset Yes in the same Bill
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
			CASE WHEN QPS=1 THEN
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

		--->For Scheme On Another Product
		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT DISTINCT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		CASE WHEN QPS=1 THEN
		--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
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

		--->For Non Combi and Non Scheme On Another Product Scheme
		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		CASE WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		--(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
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
		AND SM.SchId NOT IN 
		(
			SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
			AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
			GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1
		)

		--->For Combi and Non Scheme On Another Product Scheme
		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		CASE WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		--SchemeAmount 
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
		ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON A.SchId = B.SchId 
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid 
		AND SM.CombiSch=1
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN 
		(
			SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
			AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
			GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1
		)		
		---->
	END

	INSERT INTO @FreeQtyDt (FreePrdid,FreePrdBatId,FreeQty)
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
	WHERE B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3
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
	SELECT * FROM ApportionSchemeDetails	
	SELECT * FROM BillQPSSchemeAdj

	UPDATE A SET A.Contri=100*(B.QPSGrossAmount/CASE C.QPSGrossAmount WHEN 0 THEN 1 ELSE C.QPSGrossAmount END)	
	FROM ApportionSchemeDetails A,@TempPrdGross B,@TempSchGross C,SchemeMaster SM
	WHERE A.TRansId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.RowId=B.RowId AND 
	A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatID AND A.SchId=B.SchId AND B.SchId=C.SchId AND SM.SchId=A.SchId AND SM.QPS=1
	
	SELECT * FROM @QPSNowAvailable

	--->For non Converted QPS Scheme
	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId NOT IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId AND AdjAmount>0)	

	--->For Converted QPS Scheme
	UPDATE ApportionSchemeDetails SET SchemeDiscount=0
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId AND AdjAmount=0)	

	UPDATE ASD SET SchemeAmount=Contri*AdjAmount/100,SchemeDiscount=(CASE SM.CombiSch+SM.QPS WHEN 2 THEN 0 ELSE SchemeDiscount END)
	FROM ApportionSchemeDetails ASD,BillQPSSchemeAdj A,SchemeMaster SM 
	WHERE ASD.SchId=A.SchId AND SM.SchId=A.SchId AND ASD.UsrId=A.UserId AND ASD.TransId=A.TransId	
	AND ASD.SchId NOT IN (SELECT SchId FROM ApportionSchemeDetails GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	
	UPDATE ASD SET SchemeAmount=Contri*AdjAmount/100,SchemeDiscount=(CASE SM.CombiSch+SM.QPS WHEN 2 THEN 0 ELSE SchemeDiscount END)
	FROM ApportionSchemeDetails ASD,BillQPSSchemeAdj A,SchemeMaster SM 
	WHERE ASD.SchId=A.SchId AND SM.SchId=A.SchId AND ASD.UsrId=A.UserId AND ASD.TransId=A.TransId	
	AND ASD.SchId IN (SELECT SchId FROM ApportionSchemeDetails GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	AND CAST(ASD.SchId AS NVARCHAR(10))+'~'+CAST(ASD.SlabId AS NVARCHAR(10)) IN 
	(SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(MAX(SlabId) AS NVARCHAR(10)) FROM ApportionSchemeDetails GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-193-004

if exists (select * from dbo.sysobjects where id = object_id(N'[RptStoreSchemeDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptStoreSchemeDetails]
GO

CREATE TABLE [dbo].[RptStoreSchemeDetails]
(
	[SchId] [int] NULL,
	[SlabId] [int] NULL,
	[ReferNo] [nvarchar](100) NULL,
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
	[SMName] [nvarchar](200) NULL,
	[RMName] [nvarchar](200) NULL,
	[DlvRMName] [nvarchar](200) NULL,
	[RtrName] [nvarchar](200) NULL,
	[VehicleName] [nvarchar](200) NULL,
	[DeliveryBoyName] [nvarchar](200) NULL,
	[PrdName] [nvarchar](200) NULL,
	[BatchName] [nvarchar](200) NULL,
	[FreePrdName] [nvarchar](200) NULL,
	[FreeBatchName] [nvarchar](200) NULL,
	[GiftPrdName] [nvarchar](200) NULL,
	[GiftBatchName] [nvarchar](200) NULL,
	[LineType] [int] NULL,
	[ReferDate] [datetime] NULL,
	[CtgLevelId] [int] NULL,
	[CtgLevelName] [nvarchar](200) NULL,
	[CtgMainId] [int] NULL,
	[CtgName] [nvarchar](200) NULL,
	[RtrClassId] [int] NULL,
	[ValueClassName] [nvarchar](200) NULL
) ON [PRIMARY]
GO

if not exists (select * from hotfixlog where fixid = 358)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(358,'D','2011-01-19',getdate(),1,'Core Stocky Service Pack 358')
