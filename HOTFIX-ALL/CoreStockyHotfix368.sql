--[Stocky HotFix Version]=368
Delete from Versioncontrol where Hotfixid='368'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('368','2.0.0.5','D','2011-03-29','2011-03-29','2011-03-29',convert(varchar(11),getdate()),'Parle;Major:-Akso Nobel and Henkel CRs;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 368' ,'368'
GO

--SRF-Nanda-221-001

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
EXEC Proc_ApplyCombiSchemeInBill 694,286,0,2,2
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
--			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
--			SELECT PrdId,PrdBatId,ISNULL(SUM(SumQty),0) AS SchemeOnQty,
--				ISNULL(SUM(SumValue),0) AS SchemeOnAmount,ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
--				ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
--				FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
--				GROUP BY PrdId,PrdBatId
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
			(SELECT COUNT(SlabId) AS CntAch,SlabId FROM @TempBilledQpsReset 
			 WHERE FRomQty<=FrmSchAch	
			GROUP BY SlabId) AS A
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
					@Pi_UsrId as UsrId FROM @TempRedeem,@TempSchSlabAmt
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
					@Pi_UsrId as UsrId FROM @TempRedeem,@TempSchSlabAmt
					WHERE (FlatAmt + DiscPer + FlxDisc + FlxValueDisc + FlxFreePrd + FlxGiftPrd + Points) >=0
				) AS B
				GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeDiscount,Points,FlxDisc,FlxValueDisc,
				FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,
				GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
				SELECT '@TempRedeem',* FROM @TempRedeem
				SELECT '@TempSchSlabAmt',* FROM @TempSchSlabAmt
				SELECT '@BillAppliedSchemeHd',* FROM @BillAppliedSchemeHd
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
		AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
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
			ON A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.PrdId=B.PrdId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId 
			WHERE A.SchId=@Pi_SchId AND A.SlabId=@SlabId
			AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND A.FlexiSch<>1
			AND A.PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
			WHERE SchCode=@SchCode AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
	
			UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
			PrdId IN (SELECT PrdId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId) AND
			PrdBatId IN (SELECT PrdBatId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
			AND SchemeAmount =0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
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
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount-ReturnFlatAmount,0) AS FlatAmount
	FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
	(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId = @Pi_TransId AND Usrid = @Pi_UsrId) A,
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
		(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId = @Pi_TransId AND Usrid = @Pi_UsrId) A,
		SalesInvoice SI
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3	
	) A
	WHERE SchId=@Pi_SchId
	GROUP BY A.SchId	
	--->Till Here
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
		(SELECT A.PrdId,A.PrdBatId FROM BilledPrdHdForScheme A (NOLOCK) 
		INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
		A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End		
		AND CAST(A.PrdId AS NVARCHAR(10))+'~'+CAST(A.PrdBatId AS NVARCHAR(10)) 
		NOT IN (SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BillApplieDSchemeHd WHERE SchId=@Pi_SchId
		AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId
		))B
		WHERE CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
		NOT IN (SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
		FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId AND UsrId=@Pi_UsrId AND TransID=@Pi_TransId)
	END
	--->Till Here
	--->For Scheme Amount Update
	UPDATE BillAppliedSchemeHd SET SchemeAmount=CAST(SchemeAmount-Amount AS NUMERIC(38,4))
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	--->For Scheme Points Update
	UPDATE BillAppliedSchemeHd SET BillAppliedSchemeHd.Points=CAST(BillAppliedSchemeHd.Points-A.Points AS NUMERIC(38,4))
	FROM @QPSGivenPoints A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
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
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabs
	FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenFlat WHERE SchId=@MSSchId)
			BEGIN
				SELECT @AmtToReduced=ISNULL(SUM(Amount),0) FROM @QPSGivenFlat WHERE SchId=@MSSchId
--				SELECT @AmtToReduced=SchemeAmount FROM BillAppliedSchemeHd 
--				WHERE SlabId=@MaxSlabId AND SchId=@MSSchId
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
--			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount+@AmtToReduced-Amount
--			FROM  @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=@MSSchId 
--			AND BillAppliedSchemeHd.SlabId=@MaxSlabId AND A.SchId=BillAppliedSchemeHd.SchId
			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-@AmtToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND Usrid = @Pi_UsrId
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs
	
	--->For Points QPS Reset
	SET @MSSchId=0
	SET @MaxSlabId=0
	DECLARE @PointsToReduced AS NUMERIC(38,0)
	SET @PointsToReduced=0
	DECLARE Cur_QPSSlabsPoints CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabsPoints
	FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenPoints WHERE SchId=@MSSchId)
			BEGIN
				SELECT @PointsToReduced=ISNULL(SUM(Points),0) FROM @QPSGivenPoints WHERE SchId=@MSSchId
				UPDATE BillAppliedSchemeHd SET Points=Points-@PointsToReduced
				WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
				AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				
				IF EXISTS(SELECT * FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND Points<0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)		
				BEGIN
					SELECT @PointsToReduced=ABS(Points) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND Points<0
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId
					UPDATE BillAppliedSchemeHd SET Points=0
					WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId				
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				END		
				ELSE
				BEGIN
					SET @PointsToReduced=0
				END
			END
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHd SET Points=Points-@PointsToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND Usrid = @Pi_UsrId
		END
		FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabsPoints
	DEALLOCATE Cur_QPSSlabsPoints
	--->Till Here
	--->Added By Boo for Free Product Calculation For QPS without QPS Reset
	IF @QPS<>0 AND @QPSReset=0 --AND @QPSApplicapple=1
	BEGIN
		UPDATE A SET FreeToBeGiven=FreeToBeGiven-FreeQty,GiftToBeGiven=GiftToBeGiven-GiftQty FROM BillAppliedSchemeHd A INNER JOIN
		(SELECT A.SchId,A.FreePrdId,A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId,
		(SUM(A.FreeQty)-SUM(A.ReturnFreeQty)) AS FreeQty,
		(SUM(A.GiftQty)-SUM(A.ReturnGiftQty)) AS GiftQty FROM SalesInvoiceSchemeDtFreePrd A 
		INNER JOIN SalesInvoice B ON A.SalId=B.SalId 
		WHERE A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId AND B.DlvSts>3
		GROUP BY A.SchId,A.FreePrdId,A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId) B ON
		A.SchId=B.SchId AND A.FreePrdId=B.FreePrdId AND	A.GiftPrdId=B.GiftPrdId 
		WHERE A.TransId=@Pi_TransId AND A.Usrid=@Pi_UsrId
	END
	--->Till Here	
	DELETE FROM BillAppliedSchemeHd WHERE SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd=0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	IF @QPSReset<>0
	BEGIN
		UPDATE B SET B.NoOfTimes=A.NoOfTimes,B.SchemeAmount=A.SchemeAmount
		FROM BillAppliedSchemeHd B,
		(
			SELECT SchId,SlabId,MAX(NoOfTimes) AS NoOfTimes,MAX(SchemeAmount) AS SchemeAmount
			FROM BillAppliedSchemeHd WHERE Usrid = @Pi_UsrId GROUP BY SchId,SlabId
		) AS A
		WHERE B.SchId=A.SchId AND B.SlabId=A.SlabId AND B.SchId=@Pi_SchId AND B.TransId=@Pi_TransId AND B.UsrId=@Pi_UsrId 
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

--SRF-Nanda-221-002

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
EXEC Proc_ApplyQPSSchemeInBill 6,4,0,2,2
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd(NOLOCK) WHERE TransId = 2 And UsrId = 2
--SELECT * FROM BillAppliedSchemeHd (NOLOCK)
--SELECT * FROM ApportionSchemeDetails (NOLOCK)
--SELECT * FROM SalesInvoiceQPSCumulative(NOLOCK) WHERE SchId=522
--SELECT * FROM SchemeMaster
--SELECT * FROM Retailer
--SELECT * FROM BillAppliedSchemeHd
--SELECT * FROM BilledPrdHdForScheme
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
--		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
--		SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
--			-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
--			-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
--			FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
--			GROUP BY PrdId,PrdBatId
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
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime 
		FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemes B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		INNER JOIN SchemeSlabs C ON A.SchId=C.SchId AND C.SlabId=B.SlabId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
		AND A.SchId=@Pi_SchId
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
		AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
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
			WHERE SchCode=@SchCode AND (A.FreeToBeGiven+A.GiftToBeGiven) > 0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)

			UPDATE BillAppliedSchemeHd SET FreeToBeGiven=0,GiftToBeGiven=0 WHERE SchId=@Pi_SchId AND SlabId=@SlabId AND
			PrdId IN (SELECT PrdId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId) AND
			PrdBatId IN (SELECT PrdBatId FROM @TempBillAppliedSchemeHd WHERE SchId=@Pi_SchId AND SlabId=@SlabId)
			AND SchemeAmount =0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
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
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount-ReturnFlatAmount,0) AS FlatAmount
	FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
	(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId ) A,
	SalesInvoice SI
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND FlexiSch=0 AND A.SchemeDiscount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
	AND SISl.SlabId<=A.SlabId
	) A 
	WHERE SchId=@Pi_SchId GROUP BY A.SchId	
	
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
		(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId) A,
		SalesInvoice SI
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3	
	) A  
	WHERE SchId=@Pi_SchId
	GROUP BY A.SchId	
	--->Till Here

	--->Added By Nanda on 21/02/2011
	UPDATE A SET SchemeAmount=B.SchemeAmount
	FROM BillAppliedSchemeHd A,
	(
		SELECT SchId,SlabId,MAX(SchemeAmount) AS SchemeAmount FROM BillAppliedSchemeHd
		WHERE TransID=@Pi_TransId AND UsrId=@Pi_UsrId
		GROUP BY SchId,SlabId 
	) B
	WHERE A.SchId=B.SchId AND A.SlabId=B.SlabId AND TransID=@Pi_TransId AND UsrId=@Pi_UsrId  AND A.SchId=@Pi_SchId
	--->Till Here

	--->For Scheme Amount Update
	UPDATE BillAppliedSchemeHd SET SchemeAmount=CAST(SchemeAmount-Amount AS NUMERIC(38,4))
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

	--->For Scheme Points Update
	UPDATE BillAppliedSchemeHd SET BillAppliedSchemeHd.Points=CAST(BillAppliedSchemeHd.Points-A.Points AS NUMERIC(38,4))
	FROM @QPSGivenPoints A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
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
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
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

--				SELECT @AmtToReduced=SchemeAmount FROM BillAppliedSchemeHd 
--				WHERE SlabId=@MaxSlabId AND SchId=@MSSchId

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
--			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount+@AmtToReduced-Amount
--			FROM  @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=@MSSchId 
--			AND BillAppliedSchemeHd.SlabId=@MaxSlabId AND A.SchId=BillAppliedSchemeHd.SchId

			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-@AmtToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs
	
	--->For Points QPS Reset
	SET @MSSchId=0
	SET @MaxSlabId=0
	DECLARE @PointsToReduced AS NUMERIC(38,0)
	SET @PointsToReduced=0
	DECLARE Cur_QPSSlabsPoints CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabsPoints
	FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenPoints WHERE SchId=@MSSchId)
			BEGIN
				SELECT @PointsToReduced=ISNULL(SUM(Points),0) FROM @QPSGivenPoints WHERE SchId=@MSSchId

				UPDATE BillAppliedSchemeHd SET Points=Points-@PointsToReduced
				WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
				AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				
				IF EXISTS(SELECT * FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND Points<0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId )		
				BEGIN
					SELECT @PointsToReduced=ABS(Points) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId AND Points<0
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

					UPDATE BillAppliedSchemeHd SET Points=0
					WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId				
					AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
				END		
				ELSE
				BEGIN
					SET @PointsToReduced=0
				END
			END
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHd SET Points=Points-@PointsToReduced
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId 
			AND BillAppliedSchemeHd.SchId=@Pi_SchId AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 
		END
		FETCH NEXT FROM Cur_QPSSlabsPoints INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabsPoints
	DEALLOCATE Cur_QPSSlabsPoints
	--->Till Here

	--->Added By Boo for Free Product Calculation For QPS without QPS Reset
	IF @QPS<>0 AND @QPSReset=0 --AND @QPSApplicapple=1
	BEGIN
		UPDATE A SET FreeToBeGiven=FreeToBeGiven-FreeQty,GiftToBeGiven=GiftToBeGiven-GiftQty FROM BillAppliedSchemeHd A INNER JOIN
		(SELECT A.SchId,A.FreePrdId,A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId,
		(SUM(A.FreeQty)-SUM(A.ReturnFreeQty)) AS FreeQty,
		(SUM(A.GiftQty)-SUM(A.ReturnGiftQty)) AS GiftQty FROM SalesInvoiceSchemeDtFreePrd A 
		INNER JOIN SalesInvoice B ON A.SalId=B.SalId 
		WHERE A.SchId=@Pi_SchId AND B.RtrId=@Pi_RtrId AND B.DlvSts>3
		GROUP BY A.SchId,A.FreePrdId,A.FreePrdBatId,A.GiftPrdId,A.GiftPrdBatId) B ON
		A.SchId=B.SchId AND A.FreePrdId=B.FreePrdId AND	A.GiftPrdId=B.GiftPrdId 
		WHERE A.TransId=@Pi_TransId AND A.Usrid=@Pi_UsrId
	END
	--->Till Here	

	DELETE FROM BillAppliedSchemeHd WHERE ROUND(SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd,3)=0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId 

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
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-221-003

if exists (select * from dbo.sysobjects where id = object_id(N'[TempClosingStock]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [TempClosingStock]
GO

CREATE TABLE [dbo].[TempClosingStock]
(
	[CmpId] [int] NOT NULL,
	[PrdId] [int] NOT NULL,
	[LcnId] [int] NOT NULL,
	[PrdName] [nvarchar](100) NOT NULL,
	[Sellingrate] [numeric](38, 6) NOT NULL,
	[ListPrice] [numeric](38, 6) NOT NULL,
	[MRP] [numeric](38, 6) NOT NULL,
	[Cases] [int] NOT NULL,
	[Pieces] [int] NOT NULL,
	[BaseQty] [numeric](38, 0) NOT NULL,
	[BaseQtyWgt] [numeric](38, 2) NOT NULL,
	[PrdStatus] [int] NOT NULL,
	[BatStatus] [int] NOT NULL,
	[UsrId] [int] NOT NULL,
	[CloPurRte] [numeric](38, 6) NOT NULL,
	[CloSelRte] [numeric](38, 6) NOT NULL
) ON [PRIMARY]
GO

--SRF-Nanda-221-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptClosingStockReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptClosingStockReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptClosingStockReport 153,2,0,'HenClose',0,0,1

CREATE PROCEDURE [dbo].[Proc_RptClosingStockReport]
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
* VIEW	: Proc_RptClosingStockReport
* PURPOSE	: To get the Closing Stock Details
* CREATED BY	: Mahalakshmi.A
* CREATED DATE	: 17/09/2008
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
	DECLARE @LcnId 		AS	INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @DispValue	AS	INT
	DECLARE @PrdStatus	AS	INT
	DECLARE @BatchStatus	AS	INT
	DECLARE @SupZeroStock   AS INT
	DECLARE @PrdUnit	AS INT

	----Till Here
	--Assgin Value for the Filter Variable
--	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @DispValue = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,209,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,210,@Pi_UsrId))
	SET @BatchStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,211,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)	
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	
	SELECT @PrdUnit=PrdUnitId FROM ProductUnit WHERE UPPER(PrdUnitName) IN('KILO GRAM','KILOGRAM','KILO GRAMS','KILOGRAMS')

	---Till Here
	--PRINT @DispValue
	CREATE TABLE #RptClosingStock
	(
				PrdId		INT,
				PrdName		NVARCHAR(100),
				MRP		NUMERIC(38,6),
				Cases		NUMERIC(38,0),
				BoxStrip	NUMERIC(38,0),
				Piece		NUMERIC(38,0),
				StockValue	NUMERIC(38,6),
				KiloGrams   NUMERIC(38,6)				
	)
	SET @TblName = 'RptClosingStock'
	SET @TblStruct = ' PrdId		INT,
		PrdName		NVARCHAR(100),
		MRP		    NUMERIC(38,6),
		Cases		NUMERIC(38,0),
		BoxStrip	NUMERIC(38,0),
		Piece		NUMERIC(38,0),
		StockValue	NUMERIC(38,6),
		KiloGrams   NUMERIC(38,6)'
	SET @TblFields = 'PrdId,PrdName,MRP,Cases,BoxStrip,Piece,StockValue,KiloGrams'
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
	EXEC Proc_ClosingStock @Pi_RptID,@Pi_UsrId,@ToDate
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN

		INSERT INTO #RptClosingStock (PrdId,PrdName,MRP,Cases,BoxStrip,Piece,StockValue,KiloGrams)
		SELECT DISTINCT T.PrdId,T.PrdName,MRP,SUM(Cases),0,SUM(Pieces),
		--SUM((CASE @DispValue WHEN 1 THEN CloSelRte ELSE CloPurRte END)) As StockValue
		SUM((CASE @DispValue WHEN 1 THEN (BaseQty*SellingRate) ELSE (BaseQty*ListPrice) END)) As StockValue,0
		FROM TempClosingStock T
		WHERE 	(T.CmpId = (CASE @CmpId WHEN 0 THEN T.CmpId ELSE 0 END) OR
		T.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))				
		AND
		(T.LcnId = (CASE @LcnId WHEN 0 THEN T.LcnId ELSE 0 END) OR
			T.LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
		AND
		(T.PrdStatus = (CASE @PrdStatus WHEN 0 THEN T.PrdStatus ELSE -1 END) OR
			T.PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,210,@Pi_UsrId)))
		AND
		(T.BatStatus = (CASE @BatchStatus WHEN 0 THEN T.BatStatus ELSE -1 END) OR
			T.BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,211,@Pi_UsrId)))
		AND
		(T.PrdId = (CASE @PrdCatId WHEN 0 THEN T.PrdId Else 0 END) OR
			T.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND
		(T.PrdId = (CASE @PrdId WHEN 0 THEN T.PrdId Else 0 END) OR
			T.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		AND UsrId=@Pi_UsrId 
		GROUP BY T.PrdId,T.PrdName,MRP
		ORDER BY T.PrdId,T.PrdName,MRP

--		UPDATE T SET KiloGrams=(PrdWgt*BaseQty) FROM #RptClosingStock T,Product P,ProductUnit PU,TempClosingStock TT
--		WHERE P.PrdId=T.PrdId AND T.PrdId=TT.PrdId AND PU.PrdUnitId=TT.PrdUnitId AND TT.PrdUnitId=@PrdUnit

		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptClosingStock ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ 'WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
				+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (LcnId = (CASE ' + CAST(@LcnId AS nVarchar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR '
				+ 'LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',22,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN PrdId ELSE 0 END) OR '
				+ 'PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND(PrdId=(CASE @PrdId WHEN 0 THEN PrdId ELSE 0 END) OR'
				+ 'PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdStatus = (CASE ' + CAST(@PrdStatus AS nVarchar(10)) + ' WHEN 0 THEN PrdStatus ELSE -1 END) OR '
				+ 'PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',210,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (BatStatus = (CASE ' + CAST(@BatchStatus AS nVarchar(10)) + ' WHEN 0 THEN BatStatus ELSE -1 END) OR '
				+ 'BatStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',211,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				--+ 'AND TransDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptClosingStock'
				
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
			SET @SSQL = 'INSERT INTO #RptClosingStock ' +
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
	
	IF @SupZeroStock=1 
	BEGIN
		SELECT *FROM #RptClosingStock WHERE ([Cases]+[Piece])<>0
		--Check for Report Data
			Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock WHERE ([Cases]+[Piece])<>0
		-- Till Here
	END
	ELSE
	BEGIN
		SELECT *FROM #RptClosingStock
		--Check for Report Data
			Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock 
		-- Till Here
	END
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptClosingStock_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptClosingStock_Excel

		IF @SupZeroStock=1 
		BEGIN
			SELECT * INTO RptClosingStock_Excel FROM #RptClosingStock WHERE ([Cases]+[Piece])<>0
		END
		ELSE
		BEGIN
			SELECT * INTO RptClosingStock_Excel FROM #RptClosingStock
		END
	END 

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-221-005

DELETE FROM HotSearchEditorDt WHERE FormId=789

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('1','789','Product [Saleable Qty] without Company','Seq No','PrdSeqDtId','1500','0','HotSch-2-2000-92','2')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('2','789','Product [Saleable Qty] without Company','Dist Code','PrdDCode','1500','0','HotSch-2-2000-93','2')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('3','789','Product [Saleable Qty] without Company','Comp Code','PrdCcode','1500','0','HotSch-2-2000-94','2')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('4','789','Product [Saleable Qty] without Company','Name','PrdName','2500','0','HotSch-2-2000-95','2')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('5','789','Product [Saleable Qty] without Company','Short Name','PrdShrtName','2000','0','HotSch-2-2000-133','2')

INSERT INTO HotSearchEditorDt(Slno,FormId,FieldName,AliasName,SrchFieldNm,Colwidth,SortedType,HotSearchName,TransId) 
VALUES('6','789','Product [Saleable Qty] without Company','Saleable Qty','SaleableQty','1500','0','HotSch-2-2000-134','2')

DELETE FROM CustomCaptions WHERE TransId=2 AND CtrlId=2000 AND SubCtrlId IN (92,93,94,95,133,134)

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,
LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('2','2000','92','HotSch-2-2000-92','Seq No','','','1','1','1',CONVERT(datetime,'2009-10-09 21:28:17.813',121),'1',CONVERT(datetime,'2009-10-09 21:28:17.813',121),'Seq No','','','1','1')

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,
LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('2','2000','93','HotSch-2-2000-93','Dist Code','','','1','1','1',CONVERT(datetime,'2009-10-09 21:28:17.737',121),'1',CONVERT(datetime,'2009-10-09 21:28:17.737',121),'Dist Code','','','1','1')

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,
LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('2','2000','94','HotSch-2-2000-94','Name','','','1','1','1',CONVERT(datetime,'2009-10-09 21:28:17.753',121),'1',CONVERT(datetime,'2009-10-09 21:28:17.753',121),'Name','','','1','1')

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,
LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('2','2000','95','HotSch-2-2000-95','Comp Code','','','1','1','1',CONVERT(datetime,'2009-10-09 21:28:17.770',121),'1',CONVERT(datetime,'2009-10-09 21:28:17.770',121),'Comp Code','','','1','1')

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,
LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('2','2000','133','HotSch-2-2000-133','Short Name','','','1','1','1',CONVERT(datetime,'2009-10-09 21:28:17.783',121),'1',CONVERT(datetime,'2009-10-09 21:28:17.783',121),'Short Name','','','1','1')

INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,
LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('2','2000','134','HotSch-2-2000-134','Saleable Qty','','','1','1','1',CONVERT(datetime,'2009-10-09 21:28:17.800',121),'1',CONVERT(datetime,'2009-10-09 21:28:17.800',121),'Saleable Qty','','','1','1')

--SRF-Nanda-221-006-From Panneer

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_AkzoProductTrackDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_AkzoProductTrackDetails]
GO
----  exec [Proc_ProductTrackDetails] 5,'2010-09-15','2010-09-15'
CREATE PROCEDURE [Proc_AkzoProductTrackDetails]
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
		'Stock Journal' TransType ,M.StkJournalRefNo,M.StkJournalDate,@Pi_UsrId,10,S.LcnId
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
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RptAkzoStockLedgerReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RptAkzoStockLedgerReport]
GO
----  Exec [Proc_RptAkzoStockLedgerReport] 225,2,0,'Loreal',0,0,1
---- select *  from RptProductTrack
---- select * from users
CREATE  PROCEDURE [Proc_RptAkzoStockLedgerReport]
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
--		DELETE FROM #RptAkzoStockLedgerReport WHERE (Abs(SalQty)+ABS(UnSalQty) + ABS(OfferQty)) = 0
	SELECT * FROM #RptAkzoStockLedgerReport 
			 WHERE (SalQty+UnSalQty+OfferQty)<>0 ORDER BY SlNo
	END

	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)

	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptAkzoStockLedgerReport
	PRINT 'Data Executed'
	SELECT * FROM #RptAkzoStockLedgerReport ORDER BY TransactionDate,SlNo ASC 

	RETURN
END
GO

if not exists (select * from hotfixlog where fixid = 368)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(368,'D','2011-03-29',getdate(),1,'Core Stocky Service Pack 368')
