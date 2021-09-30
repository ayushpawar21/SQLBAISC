--[Stocky HotFix Version]=342
Delete from Versioncontrol where Hotfixid='342'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('342','2.0.0.5','D','2010-09-21','2010-09-21','2010-09-21',convert(varchar(11),getdate()),'HK-2nd Phase CR;Major:Scheme Download changes;Minor:Clsuter Assign changes and other bug fixings')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 342' ,'342'
GO

--SRF-Nanda-152-001

DELETE FROM SalesInvoiceQPSRedeemed
WHERE CAST(SalId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+CAST(PrdBatId AS NVARCHAR(10))
NOT IN(SELECT CAST(SalId AS NVARCHAR(10))+CAST(PrdId AS NVARCHAR(10))+CAST(PrdBatId AS NVARCHAR(10)) FROM SalesInvoiceProduct)

--SRF-Nanda-152-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyQPSSchemeInBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyQPSSchemeInBill]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme WHERE SchId=28
--SELECT * FROM BillAppliedSchemeHd
--DELETE FROM BillAppliedSchemeHd
EXEC Proc_ApplyQPSSchemeInBill 151,947,0,2,2
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd WHERE TransId = 2 And UsrId = 1
SELECT * FROM BillAppliedSchemeHd
--SELECT * FROM SalesInvoiceQPSCumulative(NOLOCK) WHERE SchId=30
--SELECT * FROM SchemeMaster
--SELECT * FROM Retailer
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
--		SELECT '1',* FROM @TempBilled1
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
--		SELECT '2',* FROM @TempBilled1
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
--		SELECT '3',* FROM @TempBilled1
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
--		SELECT '4',* FROM @TempBilled1
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
--		SELECT '5',* FROM @TempBilled1
		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SumQty),0) AS SchemeOnQty,
			ISNULL(SUM(SumValue),0) AS SchemeOnAmount,ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
			ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
			FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
			GROUP BY PrdId,PrdBatId
--		SELECT * FROM @TempBilled1
	END
--	SELECT '6',* FROM @TempBilled1
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
--	SELECT * FROM @TempBilled
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
				FlatAmt
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
					CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN ROUND((FreeQty*@NoOfTimes),0) ELSE FreeQty END
				WHEN 2 THEN
					CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN ROUND((FreeQty*@NoOfTimes),0) ELSE FreeQty END
				WHEN 3 THEN
					CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN ROUND((FreeQty*@NoOfTimes),0) ELSE FreeQty END
			END as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
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
	--SELECT * FROM BilledPrdHdForQPSScheme
	--NNN
--	SELECT * FROM BillAppliedSchemeHd
	INSERT INTO @QPSGivenFlat
	SELECT SchId,SUM(FlatAmount)
	FROM
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount,0) AS FlatAmount
	FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
	(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd) A,
	SalesInvoice SI
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeDiscount=0 AND SM.QPS=1 AND FlexiSch=0
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
	AND SISl.SlabId<=A.SlabId
	) A
	GROUP BY A.SchId
--	SELECT SISL.*
--	FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,BillAppliedSchemeHd A,SalesInvoice SI
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeDiscount=0 AND SM.QPS=1
--	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
--	--AND SISl.SlabId<=A.SlabId
--	--GROUP BY SISL.SchId
--	SELECT * FROM BillAppliedSchemeHd
--
--	SELECT 'N',* FROM @QPSGivenFlat
	UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-Amount
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	
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
--			SELECT '1111',@AmtToReduced
			UPDATE BillAppliedSchemeHd SET SchemeAmount=0
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
			END
		END
		ELSE
		BEGIN
--			SELECT '222',* FROM @QPSGivenFlat WHERE SchId=@MSSchId
--			SELECT '222',* FROM BillAppliedSchemeHd WHERE SchId=@MSSchId AND SlabId=@MaxSlabId
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
	SELECT * FROM BillAppliedSchemeHd
	DELETE FROM BillAppliedSchemeHd WHERE SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd=0
	IF @QPS<>0 AND @QPSReset<>0	
	BEGIN
		DELETE FROM BillAppliedSchemeHd WHERE CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
		NOT IN (SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BilledPrdHdForQPSScheme WHERE QPSPrd=0 AND SchId=@Pi_SchId) 
		AND SchId=@Pi_SchId AND SchId IN (
		SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
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

--SRF-Nanda-152-003

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
DELETE FROM ApportionSchemeDetails
--SELECT * FROM BillAppliedSchemeHd(NOLOCK)
EXEC Proc_ApportionSchemeAmountInLine 1,2
SELECT * FROM ApportionSchemeDetails WHERE TransId=2
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
		GrossAmount  NUMERIC(38,6)
	)
	DECLARE @TempPrdGross TABLE
	(
		SchId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6)
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
	DECLARE @TempSchGrossQPS TABLE
	(
		SchId   INT,
		SlabId   INT,
		GrossAmount  NUMERIC(38,6)
	)
	--NNN
	DECLARE @TempPrdGrossQPS TABLE
	(
		SchId   INT,
		SlabId   INT,
		PrdId   INT,
		PrdBatId  INT,
		RowId   INT,
		GrossAmount  NUMERIC(38,6)
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
			IF @QPS=0 OR (@Combi=1 AND @QPS=1)
			BEGIN
				IF EXISTS(SELECT * FROM SchemeAnotherPrdDt WHERE SchId=@SchId AND SlabId=@SlabId)
				BEGIN
					INSERT INTO @TempSchGross (SchId,GrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN SchemeAnotherPrdDt C ON A.PrdId=C.PrdId AND C.SchId=@SchId AND C.SlabId=@SlabId
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
				ELSE
				BEGIN 
					INSERT INTO @TempSchGross (SchId,GrossAmount)
					SELECT @SchId,
					CASE @MRP
					WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
					WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
					WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF  @QPS<>0 AND @Combi=0
			BEGIN
				INSERT INTO @TempSchGross (SchId,GrossAmount)
				SELECT @SchId,
				CASE @MRP
				WHEN 1 THEN SUM((CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END))
				WHEN 2 THEN ISNULL(SUM(A.GrossAmount),0)
				WHEN 3 THEN SUM((CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END)) END
				as GrossAmount FROM BilledPrdHdForQPSScheme A
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
				WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND QPSPrd=1 AND A.SchId=@SchId
			END	
		END
		IF NOT EXISTS(SELECT * FROM @TempPrdGross WHERE SchId=@SchId)
		BEGIN
			IF @QPS=0 OR (@Combi=1 AND @QPS=1)
			BEGIN			
				--SELECT @SchId,@MRP,@WithTax,@SlabId	
				IF EXISTS(SELECT * FROM Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId))
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END 
				ELSE
				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					as GrossAmount FROM BilledPrdHdForScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON
					A.PrdId = B.PrdId
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
				END
			END
			IF @QPS<>0 AND @Combi=0
			BEGIN
--				IF @QPSDateQty=2 
--				BEGIN
					INSERT INTO @TempPrdGross (SchId,PrdId,PrdBatId,RowId,GrossAmount)
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.MRP*BaseQty END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					AS GrossAmount FROM BilledPrdHdForQPSScheme A
					LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = (CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End)
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.QPSPrd=1 AND A.SchId=@SchId
					UNION ALL
					SELECT @SchId,A.PrdId,A.PrdBatId,A.RowId,
					CASE @MRP
					WHEN 1 THEN (CASE @WithTax WHEN 0 THEN A.MRP*BaseQty ELSE A.GrossAmount END)
					WHEN 2 THEN A.GrossAmount
					WHEN 3 THEN (CASE @WithTax WHEN 0 THEN A.ListPrice*BaseQty ELSE A.ListPrice*BaseQty END) END
					AS GrossAmount FROM BilledPrdHdForQPSScheme A
					INNER JOIN Fn_ReturnSchemeAnotherProduct(@SchId,@SlabId) B ON A.PrdId = B.PrdId AND A.QPSPrd=0
					WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND A.SchId=@SchId
					--NNN
					IF @QPSDateQty=2 
					BEGIN
						UPDATE TPGS SET TPGS.RowId=BP.RowId
						FROM @TempPrdGross  TPGS,BilledPrdHdForQPSScheme BP
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
--	UPDATE TPG SET TPG.GrossAmount=(TPG.GrossAmount/TSG.BilledGross)*TSG1.GrossAmount
--	FROM @TempPrdGross TPG,(SELECT SchId,SUM(GrossAmount) AS BilledGross FROM @TempPrdGross GROUP BY SchId) TSG,
--	@TempSchGross TSG1,SchemeMaster SM 
--	WHERE TPG.SchId=TSG.SchId AND TSG.SchId=TSG1.SchId AND SM.SchId=TPG.SchId
	
	UPDATE TPG SET TPG.GrossAmount=(TPG.GrossAmount/TSG.BilledGross)*TSG1.GrossAmount
	FROM @TempPrdGross TPG,(SELECT SchId,SUM(GrossAmount) AS BilledGross FROM @TempPrdGross GROUP BY SchId) TSG,
	@TempSchGross TSG1,SchemeMaster SM ,SchemeAnotherPrdHd SMA
	WHERE TPG.SchId=TSG.SchId AND TSG.SchId=TSG1.SchId AND SM.SchId=TPG.SchId AND SM.SchId=SMA.SchId
	----->	

	DECLARE  CurMoreBatch CURSOR FOR
	SELECT DISTINCT Schid,SlabId,PrdId,PrdCnt,PrdBatCnt FROM @MoreBatch
	OPEN CurMoreBatch
	FETCH NEXT FROM CurMoreBatch INTO @SchId,@SlabId,@PrdId,@PrdCnt,@PrdBatCnt
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS (SELECT A.PrdBatId FROM StockLedger A LEFT OUTER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId
			AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0)
		BEGIN
			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
			WHERE SchId=@SchId AND SlabId=@SlabId AND PrdId=@PrdId AND
			PrdBatId NOT IN (
			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
			(SchemeAmount) > 0  AND IsSelected = 1 AND SchType=0
			UPDATE BillAppliedSchemeHd Set SchemeAmount=0
			WHERE SchId=@SchId AND SlabId=@SlabId AND PrdId=@PrdId AND
			PrdBatId NOT IN (
			SELECT A.PrdBatId FROM StockLedger A INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
			AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121) AND A.PrdId=@PrdId
			AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0) AND
			(SchemeAmount) > 0  AND IsSelected = 1 AND SchType=1
		END
		--Commented By Nanda on 22/10/2009
		--  ELSE
		--  BEGIN
		--   UPDATE BillAppliedSchemeHd Set SchemeAmount=0
		--   WHERE SchId=@SchId AND SlabId=@SlabId  AND SchType=0
		--   AND PrdId=@PrdId AND IsSelected = 1 AND (SchemeAmount+SchemeDiscount)>0 AND
		--   PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
		--   WHERE SchId=@SchId AND SlabId=@SlabId
		--   AND PrdId=@PrdId  AND (SchemeAmount)>0 AND IsSelected = 1 AND SchType=0)
		--   UPDATE BillAppliedSchemeHd Set SchemeAmount=0
		--   WHERE SchId=@SchId AND SlabId=@SlabId  AND SchType=1
		--   AND PrdId=@PrdId AND IsSelected = 1 AND (SchemeAmount+SchemeDiscount)>0 AND
		--   PrdBatId NOT IN (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd
		--   WHERE SchId=@SchId AND SlabId=@SlabId
		--   AND PrdId=@PrdId  AND (SchemeAmount)>0 AND IsSelected = 1 AND SchType=1)
		--  END
		--  UPDATE BillAppliedSchemeHd Set SchemeAmount= C.FlatAmt
		--  FROM @TempPrdGross A
		--  INNER JOIN BillAppliedSchemeHd B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId
		--  INNER JOIN @SchFlatAmt C ON A.SchId=C.SchId AND B.SlabId=C.SlabId
		--  WHERE (B.SchemeAmount)>0 AND B.PrdId=@PrdId  AND B.SchType=0
		--  AND B.PrdBatId IN
		--   (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd WHERE SchId=@SchId AND SlabId=@SlabId
		--   AND PrdId=@PrdId AND  IsSelected = 1 AND (SchemeAmount)>0 AND SchType=0 )
		--
		--  UPDATE BillAppliedSchemeHd Set SchemeAmount= C.FlatAmt
		--  FROM @TempPrdGross A
		--  INNER JOIN BillAppliedSchemeHd B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.SchId=B.SchId
		--  INNER JOIN @SchFlatAmt C ON A.SchId=C.SchId AND B.SlabId=C.SlabId
		--  WHERE B.SchemeAmount>0 AND B.PrdId=@PrdId  AND B.SchType=1
		--  AND B.PrdBatId IN
		--   (SELECT MAX(PrdBatId) FROM BillAppliedSchemeHd WHERE SchId=@SchId AND SlabId=@SlabId
		--   AND PrdId=@PrdId AND  IsSelected = 1 AND SchemeAmount>0 AND SchType=1 )
		--Till Here
	FETCH NEXT FROM CurMoreBatch INTO @SchId,@SlabId,@PrdId,@PrdCnt,@PrdBatCnt
	END
	CLOSE CurMoreBatch
	DEALLOCATE CurMoreBatch
	
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
					(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
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
			(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
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
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
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
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		--AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
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
	AND ApportionSchemeDetails.UsrId = @Pi_Usrid AND
	ApportionSchemeDetails.TransId = @Pi_TransId

	--->Added By Nanda on 20/09/2010
	SELECT * INTO #TempApp FROM ApportionSchemeDetails	
	DELETE FROM ApportionSchemeDetails
	INSERT INTO ApportionSchemeDetails
	SELECT DISTINCT * FROM #TempApp
	--->Till Here

--	DELETE FROM ApportionSchemeDetails WHERE SchemeAmount=0 AND SchemeDiscount=0 and FreeQty=0
--	EXEC Proc_RDDiscount @RtrId,@Pi_TransId,@Pi_Usrid
	--SELECT * FROM ApportionSchemeDetails
--	INSERT INTO @QPSGivenFlat
--	SELECT SchId,ISNULL(SUM(FlatAmount),0) FROM SalesInvoiceSchemeLineWise 
--	WHERE SchId IN (SELECT A.SchId FROM ApportionSchemeDetails A,SchemeMaster SM 
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeDiscount=0 AND SM.QPS=1
--	AND A.SchId=SM.SchId)   
--	GROUP BY SchId
	--SELECT 'Jessey',@RtrQPSId
--	INSERT INTO @QPSGivenFlat
--	SELECT SISL.SchId,ISNULL(SUM(FlatAmount),0) 
--	FROM SalesInvoiceSchemeLineWise SISL,ApportionSchemeDetails A,SchemeMaster SM ,SalesInvoice SI
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeDiscount=0 AND SM.QPS=1
--	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@RtrQPSId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
--	AND SISl.SlabId<=A.SlabId
--	GROUP BY SISL.SchId
--
--	SELECT * FROM @QPSGivenFlat
--
--	UPDATE ApportionSchemeDetails SET SchemeAmount=SchemeAmount-Amount
--	FROM @QPSGivenFlat A WHERE ApportionSchemeDetails.SchId=A.SchId	
--	INSERT INTO @QPSGivenDisc
--	SELECT SchId,ISNULL(SUM(DiscountPerAmount),0) FROM SalesInvoiceSchemeLineWise 
--	WHERE SchId IN (SELECT A.SchId FROM ApportionSchemeDetails A,SchemeMaster SM 
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeAmount=0 AND SM.QPS=1
--	AND A.SchId=SM.SchId)   
--	GROUP BY SchId	
--	INSERT INTO @QPSGivenDisc
--	SELECT SISL.SchId,ISNULL(SUM(DiscountPerAmount),0) 
--	FROM SalesInvoiceSchemeLineWise SISL,ApportionSchemeDetails A,SchemeMaster SM ,SalesInvoice SI
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeAmount=0 AND SM.QPS=1
--	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@RtrQPSId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
--	AND SISl.SlabId<=A.SlabId
--	GROUP BY SISL.SchId
	--SELECT * FROM ApportionSchemeDetails

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
	
	--SELECT * FROM @RtrQPSIds
--	INSERT INTO @QPSGivenDisc
--	SELECT SISL.SchId,ISNULL(SUM(DiscountPerAmount),0) 
--	FROM SalesInvoiceSchemeLineWise SISL,ApportionSchemeDetails A,SchemeMaster SM ,SalesInvoice SI,
--	@RtrQPSIds RQPS
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.SchemeAmount=0 AND SM.QPS=1
--	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
--	AND SISl.SlabId<=A.SlabId
--	GROUP BY SISL.SchId
----------------	INSERT INTO @QPSGivenDisc
----------------	SELECT SISL.SchId,ISNULL(SUM(DiscountPerAmount),0) 
----------------	FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails WHERE SchemeAmount=0) A,SchemeMaster SM ,SalesInvoice SI,
----------------	@RtrQPSIds RQPS
----------------	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 --AND A.SchemeAmount=0 
----------------	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
----------------	AND SISl.SlabId<=A.SlabId
----------------	GROUP BY SISL.SchId
	--SELECT 'RQPS',* FROM @RtrQPSIds

	INSERT INTO @QPSGivenDisc
	SELECT A.SchId,SUM(A.DiscountPerAmount) FROM 
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount
	FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails WHERE SchemeAmount=0) A,SchemeMaster SM ,SalesInvoice SI,
	@RtrQPSIds RQPS
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
	AND SISl.SlabId<=A.SlabId) A
	GROUP BY A.SchId

	SELECT 'NNN',* FROM @QPSGivenDisc
	SELECT 'NNN',* FROM ApportionSchemeDetails

	INSERT INTO @QPSNowAvailable
	SELECT A.SchId,SUM(SchemeDiscount)-B.Amount FROM ApportionSchemeDetails A,@QPSGivenDisc B
	WHERE A.SchId=B.SchId
	GROUP BY A.SchId,B.Amount

	SELECT * FROM @QPSNowAvailable

--	UPDATE ApportionSchemeDetails SET SchemeDiscount=SchemeDiscount-Amount
--	FROM @QPSGivenDisc A WHERE ApportionSchemeDetails.SchId=A.SchId	

	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId

	--SELECT * FROM ApportionSchemeDetails
--	UPDATE ApportionSchemeDetails SET SchemeAmount=SchemeAmount+SchAmt,SchemeDiscount=SchemeDiscount+SchDisc
--	FROM 
--	(SELECT SchId,SUM(SchemeAmount) SchAmt,SUM(SchemeDiscount) SchDisc FROM ApportionSchemeDetails
--	WHERE RowId=10000 GROUP BY SchId) A,
--	(SELECT SchId,MIN(RowId) RowId FROM ApportionSchemeDetails
--	GROUP BY SchId) B
--	WHERE ApportionSchemeDetails.SchId =  A.SchId AND A.SchId=B.SchId 
--	AND ApportionSchemeDetails.RowId=B.RowId  
--
--	DELETE FROM ApportionSchemeDetails WHERE RowId=10000
	--SELECT * FROM ApportionSchemeDetails
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_QPSSchemeCrediteNoteConversion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_QPSSchemeCrediteNoteConversion]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM SalesInvoiceQPSRedeemed
--SELECT * FROM BillAppliedSchemeHd
--DELETE FROM BilledPrdHdForQPSScheme
EXEC Proc_QPSSchemeCrediteNoteConversion 2,'2010-08-23',0
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd WHERE TransId = 2 And UsrId = 1
--SELECT * FROM BillAppliedSchemeHd
--SELECT * FROM SalesInvoiceQPSCumulative
--SELECT * FROM SchemeMaster
--SELECT * FROM CreditNoteRetailer
--SELECT * FROM SalesInvoiceQPSRedeemed WHERE LastModDate>'2010-04-06' 
--SELECT * FROM SalesInvoiceQPSSchemeAdj 
ROLLBACK TRANSACTION
*/
CREATE        PROCEDURE [dbo].[Proc_QPSSchemeCrediteNoteConversion]
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
	
	DECLARE @SchCoaId			AS INT
	DECLARE	@CrNoteNo			AS NVARCHAR(200)
	DECLARE @ErrStatus			AS INT
	DECLARE @VocDate			AS DATETIME
	DECLARE @MinPrdId			AS INT
	DECLARE @MinPrdBatId		AS INT
	DECLARE @MinRtrId			AS INT	
	SELECT @SchCoaId=CoaId FROM COAMaster WHERE Accode='4220001'	
	SET @LcnId=0
	SELECT @LcnId=LcnId FROM Location WHERE DefaultLocation=1
	IF @LcnId=0
	BEGIN
		SELECT @LcnId=LcnId FROM Location WHERE LcnId IN (SELECT MIN(LcnId) FROM Location)
	END	
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
		DELETE FROM BilledPrdHdForScheme --WHERE UsrId=@UsrId	
		DECLARE @SchemeAvailable TABLE
		(
			SchId			INT,
			SchCode			NVARCHAR(200),
			CmpSchCode		NVARCHAR(200),
			CombiSch		INT,
			QPS				INT		
		)
		--->To insert dummy invoice and details for applying QPS scheme
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
		DECLARE Cur_Retailer CURSOR	
		FOR SELECT RtrId,RtrCode,CmpRtrCode,RtrName FROM Retailer WHERE RtrId
		IN (SELECT DISTINCT RtrId FROM SalesInvoiceQPSCumulative)
		OPEN Cur_Retailer
		FETCH NEXT FROM Cur_Retailer INTO @RtrId,@RtrCode,@CmpRtrCode,@RtrName
		WHILE @@FETCH_STATUS=0
		BEGIN	
			DELETE FROM BilledPrdHdForScheme --WHERE UsrId=@UsrId --AND RtrId=@RtrId       
		
			INSERT INTO BilledPrdHdForScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice)
			VALUES(2,@RtrId,1,1,10.00,100,1000.00,12.00,2,@UsrId,7.50)

			INSERT INTO @SchemeAvailable(SchId,SchCode,CmpSchCode,CombiSch,QPS)
			SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
			FROM BilledPrdHdForScheme A
			INNER JOIN Fn_ReturnApplicableProductDtQPS() B ON A.PrdId = B.PrdId AND A.UsrId = @UsrId   AND A.TransId =  2
			INNER JOIN SchemeMaster C ON C.SchId = B.SchId WHERE
			C.SchValidTill < @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1

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
			--DELETE FROM BilledPrdHdForScheme --WHERE Usrid = @UsrId And TransId = 2
			DELETE FROM BillAppliedSchemeHd --WHERE Usrid = @UsrId And TransId = 2
			DELETE FROM ApportionSchemeDetails --WHERE Usrid = @UsrId And TransId = 2
			DELETE FROM BilledPrdRedeemedForQPS --WHERE Userid = @UsrId And TransId = 2
			DELETE FROM BilledPrdHdForQPSScheme
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
						EXEC Proc_ApplyCombiSchemeInBill @SchId,@RtrId,0,@UsrId,2		
					END
					ELSE
					BEGIN
						EXEC Proc_ApplyQPSSchemeInBill @SchId,@RtrId,0,@UsrId,2		
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
			--->Get the scheme details
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
				SchType			INT
			)
			INSERT INTO #AppliedSchemeDetails
			SELECT DISTINCT A.SchId,A.SchCode,B.CmpSchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, SUM(A.SchemeAmount) AS SchemeAmount,
			CASE A.SchType WHEN 0 THEN A.SchemeDiscount WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,
			A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, SUM(A.FreeToBeGiven) AS FreeToBeGiven,
			B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,
			A.SchType
			FROM BillAppliedSchemeHd A
			INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE Usrid=@UsrId AND TransId = 2 AND B.QPS=1 AND B.ApyQpsSch = 1
			GROUP BY A.SchId,A.SchCode,B.CmpSchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,
			A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId,
			A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,PrdId,PrdBatId
			ORDER BY A.SchId ASC,A.SlabId ASC
			--->Convert the scheme amount as credit note and corresponding postings
			IF EXISTS(SELECT * FROM #AppliedSchemeDetails)
			BEGIN
				DECLARE Cur_SchFree CURSOR	
				FOR SELECT SchId,SchCode,CmpSchCode,SchemeAmount,SchemeDiscount FROM #AppliedSchemeDetails		
				OPEN Cur_SchFree
				FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSchCode,@AvlCmpSchCode,@AvlSchAmt,@AvlSchDiscPerc
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
						'From QPS Scheme:'+@CmpSchCode+'(Auto Conversion)')
						UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='CreditNoteRetailer' AND FldName='CrNoteNumber'
						SET @VocDate=GETDATE()
						EXEC Proc_VoucherPosting 18,1,@CrNoteNo,3,6,@UsrId,@VocDate,@Po_ErrNo=@ErrStatus OUTPUT
						IF @ErrStatus<0
						BEGIN
							SET @Po_ErrNo=1
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
					FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSchCode,@AvlCmpSchCode,@AvlSchAmt,@AvlSchDiscPerc
				END
				CLOSE Cur_SchFree
				DEALLOCATE Cur_SchFree
			END
			DROP TABLE #AppliedSchemeDetails
			FETCH NEXT FROM Cur_Retailer INTO @RtrId,@RtrCode,@CmpRtrCode,@RtrName
		END
		CLOSE Cur_Retailer
		DEALLOCATE Cur_Retailer
		DELETE FROM BilledPrdHdForScheme WHERE UsrId=@UsrId
		DELETE FROM SalesInvoiceProduct WHERE SalId=-1000
		DELETE FROM SalesInvoice WHERE SalId=-1000	
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-005

DELETE FROM Configuration WHERE ModuleId='BotreeAllowZeroTax' 
INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('BotreeAllowZeroTax','BotreeAllowZeroTax','Allow 0% Tax in Reports',1,'',0.00,1)

--SRF-Nanda-152-006

DELETE FROM Configuration WHERE ModuleId IN ('SALESRTN18','SALESRTN19')

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('SALESRTN18','Sales Return','Based on Slab Applied',1,'',0.00,1)

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('SALESRTN19','Sales Return','Based on Slab Eligiable',0,'',0.00,2)

--SRF-Nanda-152-007

DELETE FROM RptDetails WHERE RptId=18 AND SlNo IN (10,11)
INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(18,10,'SalesInvoice',-1,NULL,'SalId,SalInvRef,SalInvNo','From Bill No...',NULL,1,NULL,14,1,0,'Press F4/Double Click to select From Bill',0)
INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(18,11,'SalesInvoice',-1,NULL,'SalId,SalInvRef,SalInvNo','To Bill No...',NULL,1,NULL,15,1,0,'Press F4/Double Click to select To Bill',0)

DELETE FROM RptDetails WHERE RptId=17 AND SlNo IN (10,11)
INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(17,10,'SalesInvoice',-1,NULL,'SalId,SalInvRef,SalInvNo','From Bill No...',NULL,1,NULL,14,1,0,'Press F4/Double Click to select From Bill',0)
INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(17,11,'SalesInvoice',-1,NULL,'SalId,SalInvRef,SalInvNo','To Bill No...',NULL,1,NULL,15,1,0,'Press F4/Double Click to select To Bill',0)

DELETE FROM RptDetails WHERE RptId=154 AND SlNo IN (8,9)
INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(154,8,'SalesInvoice',-1,NULL,'SalId,SalInvRef,SalInvNo','From Bill No...',NULL,1,NULL,14,1,0,'Press F4/Double Click to select From Bill',0)
INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(154,9,'SalesInvoice',-1,NULL,'SalId,SalInvRef,SalInvNo','To Bill No...',NULL,1,NULL,15,1,0,'Press F4/Double Click to select To Bill',0)


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptLoadSheetItemWise]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptLoadSheetItemWise]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC Proc_RptLoadSheetItemWise 18,2,0,'CoreStocky',0,0,1
CREATE     PROCEDURE [dbo].[Proc_RptLoadSheetItemWise]
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
	SET @FromBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @ToBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))

	--Till Here
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	
	
	--Till Here
	CREATE TABLE #RptLoadSheetItemWise
	(
			[PrdId]        	      INT,
			[Product Code]        NVARCHAR (20),
			[Product Description] NVARCHAR(50),
			[Batch Number]        NVARCHAR(50),
			[MRP]				  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[NetAmount]			  NUMERIC (38,2)	
	)
	
	SET @TblName = 'RptLoadSheetItemWise'
	
	SET @TblStruct = '	
			[PrdId]        	      INT,    	
			[Product Code]        VARCHAR (50),
			[Product Description] VARCHAR(200),
			[Batch Number]        VARCHAR(50),		
			[MRP]				  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[NetAmount]			  NUMERIC (38,2)'
	
	SET @TblFields = '	
			[PrdId]        	      ,
			[Product Code]        ,
			[Product Description] ,
			[Batch Number]		  ,
			[MRP]				  ,
			[Billed Qty]          ,
			[Free Qty]            ,
			[Return Qty]          ,
			[Replacement Qty]     ,
			[Total Qty],[NetAmount]'
	
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
			INSERT INTO #RptLoadSheetItemWise(PrdId,[Product Code],[Product Description],[Batch Number],[MRP],
					[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[NetAmount])
			
			SELECT PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId) FROM RtrLoadSheetItemWise
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
			 AND (SalId Between @FromBillNo and @ToBillNo)
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWise(PrdId,[Product Code],[Product Description],[Batch Number],[MRP],
					[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[NetAmount])
			
			SELECT PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId) FROM RtrLoadSheetItemWise
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
		END 
	
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
	SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],
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
	FROM #RptLoadSheetItemWise LSB,Product P 
	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
	WHERE LSB.PrdId=P.PrdId
	GROUP BY LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],UG.ConversionFactor
	Order by LSB.[Product Description]
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptLoadSheetItemWise_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptLoadSheetItemWise_Excel
		SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],
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
		GROUP BY LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],UG.ConversionFactor
		ORDER BY LSB.[Product Description]
	END
RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptLoadSheetPrdwiseUomwise]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptLoadSheetPrdwiseUomwise]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC Proc_RptLoadSheetPrdwiseUomwise 154,2,0,'CoreStocky',0,0,1
CREATE          PROCEDURE [dbo].[Proc_RptLoadSheetPrdwiseUomwise]
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
* PROCEDURE	: Proc_RptLoadSheetPrdwiseUomwise
* PURPOSE	: To get the Report details for Product Details UOM wise
* CREATED	: Mahalakshmi.A
* CREATED DATE	: 20/09/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
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
	DECLARE @FromBillNo AS  BIGINT
	DECLARE @ToBillNo   AS  BIGINT
	--Till Here
	

	
	--Assgin Value for the Filter Variable
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @VehicleId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))
	SET @VehicleAllocId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @DlvRouteId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @FromBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @ToBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	--Till Here

	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	EXEC Proc_LoadPrdUomWise @Pi_RptId,@Pi_UsrId,@FromDate,@ToDate,@SMId,@VehicleId,@VehicleAllocId,@DlvRouteId,@RtrId
	
	--Till Here
	CREATE TABLE #RptPrdwiseUomwise
	(
		    	[Product Description] NVARCHAR(50),
			[Batch]		      VARCHAR(100),
	  		[MRP]     	      NUMERIC(38,6),
			[Cases]		      NUMERIC(38,0),
			[StripsBox]           NUMERIC(38,0),
			[Pieces]	      NUMERIC(38,0),
			[Free Stock]          NUMERIC (38,6),
			[Stock Value]         NUMERIC (38,6)
	)
	
	SET @TblName = 'RptPrdwiseUomwise'
	
	SET @TblStruct = '	    	
		    	[Product Description] NVARCHAR(50),
			[Batch]		      VARCHAR(100),
	  		[MRP]     	      NUMERIC(38,6),
			[Cases]		      NUMERIC(38,0),
			[StripsBox]           NUMERIC(38,0),
			[Pieces]	      NUMERIC(38,0),
			[Free Stock]          NUMERIC (38,6),
			[Stock Value]         NUMERIC (38,6)'
	
	SET @TblFields = '[Product Description],[Batch],[MRP],[Cases],[StripsBox],[Pieces],[Free Stock],[Stock Value]'
	
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
		INSERT INTO #RptPrdwiseUomwise([Product Description],[Batch],[MRP],[Cases],[StripsBox],[Pieces],[Free Stock],[Stock Value])
				
		SELECT PrdName,PrdBatCode,MRP,BillCases,BillStripsBox,BillPieces,
			   FreeQty,SUM(SellingRate) FROM TempLoadPrdUomwise
			WHERE UsrId = @Pi_UsrId
			AND (VehicleId = (CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
				VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
			AND (AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN AllotmentId ELSE 0 END) OR
				AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
			AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
				SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND (DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
				DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
			AND (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
				RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
			AND [SalInvDate] BETWEEN @FromDate AND @ToDate
			AND (SalId BETWEEN @FromBillNo AND @ToBillNo)
			AND DlvSts=2
			GROUP BY PrdName,PrdBatCode,MRP,FreeQty,BillCases,BillStripsBox,BillPieces
	END 
	ELSE
	BEGIN
		INSERT INTO #RptPrdwiseUomwise([Product Description],[Batch],[MRP],[Cases],[StripsBox],[Pieces],[Free Stock],[Stock Value])
				
		SELECT PrdName,PrdBatCode,MRP,BillCases,BillStripsBox,BillPieces,
			   FreeQty,SUM(SellingRate) FROM TempLoadPrdUomwise
			WHERE UsrId = @Pi_UsrId
			AND (VehicleId = (CASE @VehicleId WHEN 0 THEN VehicleId ELSE 0 END) OR
				VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
			AND (AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN AllotmentId ELSE 0 END) OR
				AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
			AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
				SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND (DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
				DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
			AND (RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
				RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
			AND [SalInvDate] BETWEEN @FromDate AND @ToDate
			AND DlvSts=2
			GROUP BY PrdName,PrdBatCode,MRP,FreeQty,BillCases,BillStripsBox,BillPieces
	END 
		
	IF LEN(@PurDBName) > 0
	BEGIN
		EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
		SET @SSQL = 'INSERT INTO #RptPrdwiseUomwise ' +	'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			 + 'WHERE  RptId = ' + @Pi_RptId + ' and UsrId = ' + @Pi_UsrId + ' and
			 (VehicleId = (CASE ' + @VehicleId + ' WHEN 0 THEN VehicleId ELSE 0 END) OR
				VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',36,' + @Pi_UsrId + ')) )
			 AND (AllotmentId = (CASE ' + @VehicleAllocId + ' WHEN 0 THEN AllotmentId ELSE 0 END) OR
				AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',37,' + @Pi_UsrId + ')) )
			 AND (SMId=(CASE ' + @SMId + ' WHEN 0 THEN SMId ELSE 0 END) OR
				SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',1,' + @Pi_UsrId + ')))
			 AND (DlvRMId=(CASE ' + @DlvRouteId + ' WHEN 0 THEN DlvRMId ELSE 0 END) OR
				DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',35,' + @Pi_UsrId + ')) )
			 AND (RtrId = (CASE ' + @RtrId + ' WHEN 0 THEN RtrId ELSE 0 END) OR
				RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + @Pi_RptId + ',3,' + @Pi_UsrId + ')))
 	 		 AND [SalInvDate] Between ' + @FromDate + ' and ' + @ToDate + 'AND DlvSts=2'
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptPrdwiseUomwise'
	
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
		SET @SSQL = 'INSERT INTO #RptPrdwiseUomwise ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptPrdwiseUomwise
	
	-- Till Here
	SELECT * FROM #RptPrdwiseUomwise
RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-008

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
	DECLARE Cur_ClusterMaster CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([ClusterCode])),''),ISNULL(LTRIM(RTRIM([ClusterName])),''),ISNULL(LTRIM(RTRIM([Remarks])),''),
	ISNULL(LTRIM(RTRIM([Salesman])),'No'),ISNULL(LTRIM(RTRIM([Retailer])),'No'),ISNULL(LTRIM(RTRIM([AddMast1])),'No'),
	ISNULL(LTRIM(RTRIM([AddMast2])),'No'),ISNULL(LTRIM(RTRIM([AddMast3])),'No'),ISNULL(LTRIM(RTRIM([AddMast4])),'No'),
	ISNULL(LTRIM(RTRIM([AddMast5])),'No')
	FROM Cn2Cs_Prk_ClusterMaster WHERE [DownLoadFlag] ='D' AND
	ClusterCode NOT IN (SELECT ClusterCode FROM ClsToAvoid)
	OPEN Cur_ClusterMaster
	FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,
	@AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5
	WHILE @@FETCH_STATUS=0
	BEGIN		
		SET @Po_ErrNo=0
		SET @Exist=0
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
			SELECT @ClusterId=ClusterId FROM Cluster WHERE CmpRtrCode=@ClusterName			
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
				Availability,LastModBy,LastModDate,AuthId,AuthDate)			
				VALUES(@ClusterId,@ClusterCode,@ClusterName,@Remarks,1,1,1,GETDATE(),1,GETDATE())
			
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ClusterMaster' AND FldName='ClusterId'	  
				DELETE FROM ClusterDetails WHERE ClusterId=@ClusterId
				
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE()

				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @ClusterId,79,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE() 
			END		
			ELSE IF @Exist=1
			BEGIN
				UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks
				WHERE ClusterId=@ClusterId			
				
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE()
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @ClusterId,79,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE() 
			END
			ELSE IF @Exist=2
			BEGIN
				UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks
				WHERE ClusterId=@ClusterId			
			END
		END
		FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,
		@AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5
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

--SRF-Nanda-152-009

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Validate_PurchaseReceiptClaimScheme]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Validate_PurchaseReceiptClaimScheme]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Exec Proc_Validate_PurchaseReceiptClaimScheme 0
--SELECT * FROM ETL_Prk_PurchaseReceiptClaim
--SELECT * FROM ETLTempPurchaseReceiptClaimScheme
CREATE	Procedure [dbo].[Proc_Validate_PurchaseReceiptClaimScheme]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Validate_PurchaseReceiptClaimScheme
* PURPOSE		: To Insert and Update records in the Table PurchaseReceiptClaimScheme
* CREATED		: Nandakumar R.G
* CREATED DATE	: 03/05/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist 			AS 	INT
	DECLARE @Tabname 		AS  NVARCHAR(100)
	DECLARE @DestTabname 	AS 	NVARCHAR(100)
	DECLARE @Fldname 		AS  NVARCHAR(100)
	
	DECLARE @CmpInvNo		AS 	NVARCHAR(100)
	DECLARE @Type			AS 	NVARCHAR(100)	
	DECLARE @RefCode		AS 	NVARCHAR(100)	
	DECLARE @RefDesc		AS 	NVARCHAR(100)	
	DECLARE @PrdCode		AS 	NVARCHAR(100)
	DECLARE @PrdBatCode		AS 	NVARCHAR(100)
	DECLARE @Qty			AS 	NUMERIC(38,0)
	DECLARE @StockType		AS 	NVARCHAR(100)
	DECLARE @Amt			AS 	NUMERIC(38,6)
	DECLARE @TypeId			AS 	INT
	DECLARE @RefId			AS 	INT
	DECLARE @PrdId			AS 	INT
	DECLARE @PrdBatId		AS 	INT
	DECLARE @StockTypeId	AS 	INT
			
	DECLARE @TransStr 		AS 	NVARCHAR(4000)
	SET @Po_ErrNo=0
	SET @Exist=0
	
	SET @DestTabname='ETLTempPurchaseReceiptClaimScheme'
	SET @Fldname='CmpInvNo'
	SET @Tabname = 'ETL_Prk_PurchaseReceiptClaim'
	SET @Exist=0
	
	DECLARE Cur_PurchaseReceiptClaim CURSOR
	FOR SELECT ISNULL([Company Invoice No],''),ISNULL([Type],''),ISNULL([Ref No],''),
	ISNULL([Product Code],''),ISNULL([Batch Code],''),ISNULL([Qty],0),ISNULL([Stock Type],''),
	ISNULL([Amount],0)
	FROM ETL_Prk_PurchaseReceiptClaim
	OPEN Cur_PurchaseReceiptClaim
	FETCH NEXT FROM Cur_PurchaseReceiptClaim INTO @CmpInvNo,@Type,@RefCode,@PrdCode,@PrdBatCode,
	@Qty,@StockType,@Amt
	WHILE @@FETCH_STATUS=0
	BEGIN
		
		SET @Exist=0
		SET @PrdId=0
		SET @PrdBatId=0
		SET @StockTypeId=0		
		IF NOT EXISTS(SELECT * FROM ETLTempPurchaseReceipt WITH (NOLOCK) WHERE CmpInvNo=@CmpInvNo)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Invoice No',
			'Company Invoice No:'+@CmpInvNo+' is not available')  
         	
			SET @Po_ErrNo=1
		END				
		IF @Po_ErrNo=0
		BEGIN			
			IF @Type='Claim'	
			BEGIN
				SET @TypeId=1
			END
			ELSE IF @Type='Scheme'	
			BEGIN
				SET @TypeId=2
			END
			ELSE
			BEGIN
				SET @TypeId=3
				SET @RefCode=''
			END			
		END				
		IF @Po_ErrNo=0
		BEGIN
			IF @TypeId=1 
			BEGIN
				IF NOT EXISTS(SELECT * FROM ClaimSheetHd CH,ClaimSheetDetail CD,ClaimGroupMaster CG 
				WHERE CD.Status = 1 AND CH.Confirm = 1  AND CD.Clmid = CH.ClmId 
				AND (CD.RecommendedAmount - CD.ReceivedAmount) > 0 AND CG.ClmGrpId = Ch.ClmGrpId AND CD.RefCode=@RefCode)
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Ref No',
					'Claim Group Code:'+@RefCode+' is not available in Company Invoice No:'+@CmpInvNo) 
					
					SET @Po_ErrNo=1
				END
				ELSE
				BEGIN
					SELECT @RefId=CD.ClmId,@RefDesc=CH.ClmDesc FROM ClaimSheetDetail CD WITH (NOLOCK),
					ClaimSheetHd CH WITH (NOLOCK) 
					WHERE CD.RefCode=@RefCode AND CD.ClmId=CH.ClmId
				END	
			END
			ELSE IF @TypeId=2 
			BEGIN
				IF NOT EXISTS(SELECT * FROM SchemeMaster WITH (NOLOCK) 
				WHERE SchCode=@RefCode)
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Ref No',
					'Scheme Code:'+@RefCode+' is not available in Company Invoice No:'+@CmpInvNo)           	
	
					SET @Po_ErrNo=1
				END
				ELSE
				BEGIN
					SELECT @RefId=SchId,@RefDesc=SchDsc FROM SchemeMaster WITH (NOLOCK) 
					WHERE SchCode=@RefCode
				END	
			END
			ELSE
			BEGIN
				SET @RefId=0
				SET @RefDesc='Offer'
			END
		END		
		
		SELECT @PrdId=PrdId FROM Product WITH (NOLOCK) WHERE PrdCCode=@PrdCode
		SELECT @PrdBatId=PrdBatId FROM ProductBatch WITH (NOLOCK) WHERE PrdBatCode=@PrdBatCode AND PrdId=@PrdId
		IF @PrdBatId<>0
		BEGIN
			IF (@StockType)='Saleable'
			BEGIN
				SET @StockTypeId=1
			END		
			ELSE IF (@StockType)='Offer'
			BEGIN
				SET @StockTypeId=3
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Stock Type',
				'Stock Type should be either saleable or offer for product code:'+@PrdCode+ 'in Company Invoice No:'+@CmpInvNo)  

				SET @Po_ErrNo=1
			END	
		END
		IF @Po_ErrNo=0
		BEGIN
			IF NOT CAST(@Qty AS NUMERIC(18,0))+CAST(@Amt AS NUMERIC(18,0))>0 
			BEGIN

				INSERT INTO Errorlog VALUES (1,@TabName,'Qty/Amount',
				'Either Qty or Amount for product code:'+@PrdCode+ ' should be greater than zero in Company Invoice No:'+@CmpInvNo)  

				SET @Po_ErrNo=1
			END
		END		
		IF @Po_ErrNo=0
		BEGIN
			INSERT INTO ETLTempPurchaseReceiptClaimScheme 
			(CmpInvNo,TypeId,RefCode,RefId,RefDescription,PrdId,PrdBatId,StockTypeId,Qty,Amt)
			VALUES(@CmpInvNo,@TypeId,@RefCode,@RefId,@RefDesc,@PrdId,@PrdBatId,@stockTypeId,@Qty,@Amt)
		END
			
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_PurchaseReceiptClaim
			DEALLOCATE Cur_PurchaseReceiptClaim
			RETURN
		END
		FETCH NEXT FROM Cur_PurchaseReceiptClaim INTO @CmpInvNo,@Type,@RefCode,@PrdCode,@PrdBatCode,
		@Qty,@StockType,@Amt
	END
	CLOSE Cur_PurchaseReceiptClaim
	DEALLOCATE Cur_PurchaseReceiptClaim
	IF @Po_ErrNo=0
	BEGIN
		TRUNCATE TABLE ETL_Prk_PurchaseReceiptClaim
	END
	RETURN	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-010

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RtrLoadSheetBillWise]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[RtrLoadSheetBillWise]
GO
CREATE TABLE [dbo].[RtrLoadSheetBillWise](
	[SalId] [bigint] NULL,
	[SalInvNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalInvDate] [datetime] NULL,
	[DlvRMId] [int] NULL,
	[VehicleId] [int] NULL,
	[AllotmentNumber] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SMId] [int] NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdId] [int] NULL,
	[PrdDCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrdName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BillQty] [numeric](38, 0) NULL,
	[FreeQty] [numeric](38, 0) NULL,
	[ReturnQty] [numeric](38, 0) NULL,
	[RepalcementQty] [numeric](38, 0) NULL,
	[TotalQty] [numeric](38, 0) NULL,
	[RptId] [int] NULL,
	[UsrId] [int] NULL,
	[NetAmount] [numeric](36, 2) NULL DEFAULT (0)
) ON [PRIMARY]
GO



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptLoadSheetItemWise]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptLoadSheetItemWise] 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
--EXEC Proc_RptLoadSheetItemWise 18,2,0,'CoreStocky',0,0,1
CREATE     PROCEDURE [dbo].[Proc_RptLoadSheetItemWise]
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
	SET @FromBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @ToBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	
	--Till Here
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	
	
	
	--Till Here
	CREATE TABLE #RptLoadSheetItemWise
	(
			[PrdId]        	      INT,
			[Product Code]        NVARCHAR (100),
			[Product Description] NVARCHAR(150),
			[Batch Number]        NVARCHAR(50),
			[MRP]				  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[NetAmount]			  NUMERIC (38,2)	
	)
	
	SET @TblName = 'RptLoadSheetItemWise'
	
	SET @TblStruct = '	
			[PrdId]        	      INT,    	
			[Product Code]        VARCHAR (100),
			[Product Description] VARCHAR(200),
			[Batch Number]        VARCHAR(50),		
			[MRP]				  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[NetAmount]			  NUMERIC (38,2)'
	
	SET @TblFields = '	
			[PrdId]        	      ,
			[Product Code]        ,
			[Product Description] ,
			[Batch Number],
			[MRP]				  ,
			[Billed Qty]          ,
			[Free Qty]            ,
			[Return Qty]          ,
			[Replacement Qty]     ,
			[Total Qty],[NetAmount]'
	
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
			INSERT INTO #RptLoadSheetItemWise(PrdId,[Product Code],[Product Description],[Batch Number],[MRP],
			[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[NetAmount])
	
			SELECT PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
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
			 AND (SalId Between @FromBillNo and @ToBillNo)
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWise(PrdId,[Product Code],[Product Description],[Batch Number],[MRP],
					[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[NetAmount])
			
			SELECT PrdId,PrdDCode,PrdNAme,PrdBatCode,[MRP],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId) FROM RtrLoadSheetItemWise
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
		END 
	
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
	SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],
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
	FROM #RptLoadSheetItemWise LSB,Product P 
	LEFT OUTER JOIN UOMGroup UG ON P.UOMGroupId=UG.UOMGroupId AND UG.UOMId=@UOMId
	WHERE LSB.PrdId=P.PrdId
	GROUP BY LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],UG.ConversionFactor
	Order by LSB.[Product Description]
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptLoadSheetItemWise_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptLoadSheetItemWise_Excel
		SELECT LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],
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
		GROUP BY LSB.PrdId,LSB.[Product Code],LSB.[Product Description],LSB.[Batch Number],LSB.[MRP],UG.ConversionFactor
		Order by LSB.[Product Description]
	END
RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-011

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_PurchaseReceipt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_PurchaseReceipt]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_PurchaseReceipt 0
SELECT * FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE CompInvNo='7083250423'
--SELECT MIN(TransDate) FROM StockLedger
SELECT * FROM ErrorLog
SELECT * FROM ETLTempPurchaseReceipt
SELECT * FROM ETLTempPurchaseReceiptProduct
SELECT * FROM ETLTempPurchaseReceiptPrdLineDt
SELECT * FROM ETLTempPurchaseReceiptClaimScheme
ROLLBACK TRANSACTION
*/
CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_PurchaseReceipt]
(
	@Po_ErrNo INT OUTPUT
)
AS
/***********************************************************
* PROCEDURE	: Proc_Cn2Cs_PurchaseReceipt
* PURPOSE	: To Insert the records FROM Console into Temp Tables
* SCREEN	: Console Integration-PurchaseReceipt
* CREATED BY: Nandakumar R.G On 03-05-2010
* MODIFIED	:
* DATE      AUTHOR     DESCRIPTION
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
	DELETE FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptClaim
	TRUNCATE TABLE ETL_Prk_PurchaseReceipt
	--------------------------------------

	DECLARE @ErrStatus			INT
	DECLARE @BatchNo			NVARCHAR(30)
	DECLARE @ProductCode		NVARCHAR(30)
	DECLARE @ListPrice			NUMERIC(38,6)
	DECLARE @FreeSchemeFlag		NVARCHAR(5)
	DECLARE @CompInvNo			NVARCHAR(25)
	DECLARE @UOMCode			NVARCHAR(25)
	DECLARE @Qty				INT
	DECLARE @PurchaseDiscount	NUMERIC(38,6)
	DECLARE @VATTaxValue		NUMERIC(38,6)
	DECLARE @SchemeRefrNo		NVARCHAR(25)
	DECLARE @SupplierCode		NVARCHAR(30)
	DECLARE @TransporterCode	NVARCHAR(30)
	DECLARE @POUOM				INT
	DECLARE @RowId				INT
	DECLARE @LineLvlAmt			NUMERIC(38,6)
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
	WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0))
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','CmpInvNo','Company Invoice No:'+CompInvNo+' already downloaded and ready for invoicing' FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0)
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

	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	WHERE CompInvDate>GETDATE())	
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvDate>GETDATE()
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Invoice Date','Invoice Date:'+CAST(CompInvDate AS NVARCHAR(10))+' is greater than current date in Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvDate>GETDATE()
	END

	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK)))	
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Invoice UOM','UOM:'+UOMCode+' is not available for Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))
	END		

	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE Qty <=0)	
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE Qty <=0
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Invoice Qty','Invoice Qty should be gretaer than zero for Product:'+ProductCode+
		' for Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE Qty <=0
	END		
	--->Till Here

	DECLARE Cur_Purchase CURSOR
	FOR
	SELECT DISTINCT ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,CompInvNo,UOMCode,Qty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount
	FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE [DownLoadFlag]='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
	OPEN Cur_Purchase
	FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
	@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
	@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--To insert into ETL_Prk_PurchaseReceiptPrdDt
		IF(@FreeSchemeFlag='0')
		BEGIN
			INSERT INTO  ETL_Prk_PurchaseReceiptPrdDt([Company Invoice No],[RowId],[Product Code],[Batch Code],
			[PO UOM],[PO Qty],[UOM],[Invoice Qty],[Purchase Rate],[Gross],[Discount In Amount],[Tax In Amount],[Net Amount])
			VALUES(@CompInvNo,@RowId,@ProductCode,@BatchNo,'',0,@UOMCode,@Qty,@ListPrice,@Qty*@ListPrice,
			@PurchaseDiscount,@VATTaxValue,(@ListPrice-@PurchaseDiscount+@VATTaxValue)* @Qty)
		END

		--To insert into ETL_Prk_PurchaseReceiptClaim
		IF(@FreeSchemeFlag='1')
		BEGIN
			INSERT INTO ETL_Prk_PurchaseReceiptClaim([Company Invoice No],[Type],[Ref No],[Product Code],
			[Batch Code],[Qty],[Stock Type],[Amount])
			VALUES(@CompInvNo,'Offer',@SchemeRefrNo,@ProductCode,@BatchNo,@Qty,'Offer',0)
		END

		SET @RowId=@RowId+1

		FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
		@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
		@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt
	END
	CLOSE Cur_Purchase
	DEALLOCATE Cur_Purchase

	--To insert into ETL_Prk_PurchaseReceipt
	SELECT @SupplierCode=SpmCode FROM Supplier WHERE SpmDefault=1
	SELECT @TransporterCode=TransporterCode FROM Transporter
	WHERE TransporterId IN(SELECT MIN(TransporterId) FROM Transporter)
	
	IF @TransporterCode=''
	BEGIN
		INSERT INTO Errorlog VALUES (1,'Purchase Download','Transporter',
		'Transporter not available')
	END

	INSERT INTO ETL_Prk_PurchaseReceipt([Company Code],[Supplier Code],[Company Invoice No],[PO Number],
	[Invoice Date],[Transporter Code],[NetPayable Amount])
	SELECT DISTINCT C.CmpCode,@SupplierCode,P.CompInvNo,'',P.CompInvDate,@TransporterCode,P.NetValue
	FROM Company C,Cn2Cs_Prk_BLPurchaseReceipt P
	WHERE  C.DefaultCompany=1 AND DownLoadFlag='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)

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
					SET @ErrStatus=@ErrStatus					
				END				
			END
		END
	END

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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-012

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_QPSSchemeCrediteNoteConversion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_QPSSchemeCrediteNoteConversion]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM SalesInvoiceQPSRedeemed
--SELECT * FROM BillAppliedSchemeHd
--DELETE FROM BilledPrdHdForQPSScheme
EXEC Proc_QPSSchemeCrediteNoteConversion 2,'2010-08-23',0
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd WHERE TransId = 2 And UsrId = 1
--SELECT * FROM BillAppliedSchemeHd
--SELECT * FROM SalesInvoiceQPSCumulative
--SELECT * FROM SchemeMaster
--SELECT * FROM CreditNoteRetailer
--SELECT * FROM SalesInvoiceQPSRedeemed WHERE LastModDate>'2010-04-06' 
--SELECT * FROM SalesInvoiceQPSSchemeAdj 
ROLLBACK TRANSACTION
*/
CREATE        PROCEDURE [dbo].[Proc_QPSSchemeCrediteNoteConversion]
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
	
	DECLARE @SchCoaId			AS INT
	DECLARE	@CrNoteNo			AS NVARCHAR(200)
	DECLARE @ErrStatus			AS INT
	DECLARE @VocDate			AS DATETIME
	DECLARE @MinPrdId			AS INT
	DECLARE @MinPrdBatId		AS INT
	DECLARE @MinRtrId			AS INT	
	SELECT @SchCoaId=CoaId FROM COAMaster WHERE Accode='4220001'	
	SET @LcnId=0
	SELECT @LcnId=LcnId FROM Location WHERE DefaultLocation=1
	IF @LcnId=0
	BEGIN
		SELECT @LcnId=LcnId FROM Location WHERE LcnId IN (SELECT MIN(LcnId) FROM Location)
	END	
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
		DELETE FROM BilledPrdHdForScheme --WHERE UsrId=@UsrId	
		DECLARE @SchemeAvailable TABLE
		(
			SchId			INT,
			SchCode			NVARCHAR(200),
			CmpSchCode		NVARCHAR(200),
			CombiSch		INT,
			QPS				INT		
		)
		--->To insert dummy invoice and details for applying QPS scheme
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
		DECLARE Cur_Retailer CURSOR	
		FOR SELECT RtrId,RtrCode,CmpRtrCode,RtrName FROM Retailer WHERE RtrId
		IN (SELECT DISTINCT RtrId FROM SalesInvoiceQPSCumulative)
		OPEN Cur_Retailer
		FETCH NEXT FROM Cur_Retailer INTO @RtrId,@RtrCode,@CmpRtrCode,@RtrName
		WHILE @@FETCH_STATUS=0
		BEGIN	
			DELETE FROM BilledPrdHdForScheme --WHERE UsrId=@UsrId --AND RtrId=@RtrId       
		
			INSERT INTO BilledPrdHdForScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice)
			VALUES(2,@RtrId,1,1,10.00,100,1000.00,12.00,2,@UsrId,7.50)

			INSERT INTO @SchemeAvailable(SchId,SchCode,CmpSchCode,CombiSch,QPS)
			SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
			FROM BilledPrdHdForScheme A
			INNER JOIN Fn_ReturnApplicableProductDtQPS() B ON A.PrdId = B.PrdId AND A.UsrId = @UsrId   AND A.TransId =  2
			INNER JOIN SchemeMaster C ON C.SchId = B.SchId WHERE
			C.SchValidTill < @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1

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
			--DELETE FROM BilledPrdHdForScheme --WHERE Usrid = @UsrId And TransId = 2
			DELETE FROM BillAppliedSchemeHd --WHERE Usrid = @UsrId And TransId = 2
			DELETE FROM ApportionSchemeDetails --WHERE Usrid = @UsrId And TransId = 2
			DELETE FROM BilledPrdRedeemedForQPS --WHERE Userid = @UsrId And TransId = 2
			DELETE FROM BilledPrdHdForQPSScheme
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
						EXEC Proc_ApplyCombiSchemeInBill @SchId,@RtrId,0,@UsrId,2		
					END
					ELSE
					BEGIN
						EXEC Proc_ApplyQPSSchemeInBill @SchId,@RtrId,0,@UsrId,2		
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
			--->Get the scheme details
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
				SchType			INT
			)
			INSERT INTO #AppliedSchemeDetails
			SELECT DISTINCT A.SchId,A.SchCode,B.CmpSchCode,A.FlexiSch,A.FlexiSchType,A.SlabId, SUM(A.SchemeAmount) AS SchemeAmount,
			CASE A.SchType WHEN 0 THEN A.SchemeDiscount WHEN 1 THEN SUM(A.SchemeDiscount) END AS SchemeDiscount,A.Points AS Points,
			A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId, SUM(A.FreeToBeGiven) AS FreeToBeGiven,
			B.EditScheme, A.NoOfTimes,A.Usrid,A.FlxPoints,A.GiftPrdId,A.GiftPrdBatId,SUM(A.GiftToBeGiven) AS GiftToBeGiven,
			A.SchType
			FROM BillAppliedSchemeHd A
			INNER JOIN SchemeMaster B ON A.SchId = B.SchId WHERE Usrid=@UsrId AND TransId = 2 AND B.QPS=1 AND B.ApyQpsSch = 1
			GROUP BY A.SchId,A.SchCode,B.CmpSchCode,A.FlexiSch,A.FlexiSchType,A.SlabId,A.FlxDisc,A.FlxValueDisc,A.FlxFreePrd,
			A.FlxGiftPrd,A.FreePrdId,A.FreePrdBatId,A.NoOfTimes,A.Points,A.Usrid,A.FlxPoints,A.GiftPrdId,
			A.GiftPrdBatId,B.EditScheme,A.SchType,A.SchemeDiscount,PrdId,PrdBatId
			ORDER BY A.SchId ASC,A.SlabId ASC
			--->Convert the scheme amount as credit note and corresponding postings
			IF EXISTS(SELECT * FROM #AppliedSchemeDetails)
			BEGIN
				DECLARE Cur_SchFree CURSOR	
				FOR SELECT SchId,SchCode,CmpSchCode,SchemeAmount,SchemeDiscount FROM #AppliedSchemeDetails		
				OPEN Cur_SchFree
				FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSchCode,@AvlCmpSchCode,@AvlSchAmt,@AvlSchDiscPerc
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
						'From QPS Scheme:'+@CmpSchCode+'(Auto Conversion)')
						UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='CreditNoteRetailer' AND FldName='CrNoteNumber'
						SET @VocDate=GETDATE()
						EXEC Proc_VoucherPosting 18,1,@CrNoteNo,3,6,@UsrId,@VocDate,@Po_ErrNo=@ErrStatus OUTPUT
						IF @ErrStatus<0
						BEGIN
							SET @Po_ErrNo=1
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
					FETCH NEXT FROM Cur_SchFree INTO @AvlSchId,@AvlSchCode,@AvlCmpSchCode,@AvlSchAmt,@AvlSchDiscPerc
				END
				CLOSE Cur_SchFree
				DEALLOCATE Cur_SchFree
			END
			DROP TABLE #AppliedSchemeDetails
			FETCH NEXT FROM Cur_Retailer INTO @RtrId,@RtrCode,@CmpRtrCode,@RtrName
		END
		CLOSE Cur_Retailer
		DEALLOCATE Cur_Retailer
		DELETE FROM BilledPrdHdForScheme WHERE UsrId=@UsrId
		DELETE FROM SalesInvoiceProduct WHERE SalId=-1000
		DELETE FROM SalesInvoice WHERE SalId=-1000	
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-013

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeMaster 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeMaster]
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

	DECLARE @FBM	AS NVARCHAR(10)
	DECLARE @FBMId	AS INT

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

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Master','CmpSchCode','Product :'+PrdCode+' not Available for Scheme:'+CmpSchCode FROM Etl_Prk_SchemeProducts_Combi
		WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product')

		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)		
		SELECT @DistCode,'Scheme',CmpSchCode,'Product',PrdCode,'','N'
		FROM Etl_Prk_SchemeProducts_Combi
		WHERE PrdCode NOT IN (SELECT PrdCCode FROM Product) AND 
		CmpSchCode IN (SELECT CmpSchCode FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE SchLevel='Product')
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
		SELECT DISTINCT 1,'Scheme Master','Header','Attributes not Available for Scheme:'+CmpSchCode FROM Etl_Prk_Scheme_OnAttributes
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
	ISNULL(FBM,'No') AS FBM
	FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'			 
	ORDER BY [Company Scheme Code]
	OPEN Cur_SchMaster
	FETCH NEXT FROM Cur_SchMaster INTO @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
	, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
	, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch,
	@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM	
	WHILE @@FETCH_STATUS=0
	BEGIN

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
			IF (UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' AND UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO')
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
			IF UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' OR UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO'
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
			ELSE IF UPPER(LTRIM(RTRIM(@BatLvl)))= 'NO'
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
			IF @Taction=1
			BEGIN
				EXEC Proc_DependencyCheck 'SchemeMaster',@GetKey
				SELECT @ChkCount=COUNT(*) FROM TempDepCheck
				IF @ChkCount > 0
				BEGIN
					UPDATE SCHEMEMASTER SET SchValidTill=LTRIM(RTRIM(@SchEndDate)),
					Budget=@SchBudget,SchStatus=@StatusId WHERE SchId=@GetKey
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
					SchemeLvlMode=@SelMode,SchStatus=@StatusId WHERE SchId=@GetKey

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
								AuthDate,EditScheme,SchemeLvlMode,MasterType,ApplyOnMRPSelRte,ApplyOnTax,BudgetAllocationNo,AllowPrdSelc,ExcludeDM,SchBasedOn,Download,FBM)
								VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
								LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
								@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
								@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
								@ApplySchId,@SettleSchId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,
								CONVERT(VARCHAR(10),GETDATE(),121),@EditSchId,@SelMode,1,2,0,@BudgetAllocationNo,0,0,@SchBasedOnId,1,@FBMId)
				
								UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchId'
								UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchCode'
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
					AllowPrdSelc,ExcludeDM,SchBasedOn,Download,FBM)
					VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
					LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
					@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
					@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
					@ApplySchId,@SettleSchId,1,1,convert(varchar(10),getdate(),121),1,
					convert(varchar(10),getdate(),121),@EditSchId,@SelMode,1,2,0,@BudgetAllocationNo,0,0,@SchBasedOnId,1,@FBMId)
	
					UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchId'
					UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchCode'

					INSERT INTO SchemeRuleSettings(SchId,SchConfig,SchRules,NoofBills,FromDate,ToDate,MarketVisit,ApplySchBasedOn,
					EnableRtrLvl,AllowSaving,AllowSelection,Availability,LastModBy,LastModDate,AuthId,AuthDate,CalScheme,NoOfRtr,RtrCount)
					Select SchId,0,-1,-1,NULL,NULL,-1,-1,0,0,0,1,1,LastModDate,1,LastModDate,1,0,0 from schememaster (NOLOCK) where Claimable=1
					AND SchId Not In(Select SchId from SchemeRuleSettings (NOLOCK))
				END
			END
		END

		FETCH NEXT FROM Cur_SchMaster INTO  @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
		, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
		, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch,
		@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM
	END

	CLOSE Cur_SchMaster
	DEALLOCATE Cur_SchMaster
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-014

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeAttributes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeAttributes]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeAttributes 0
--SELECT * FROM ErrorLog
SELECT * FROM SchemeRetAttr WHERE SchId=10 ORDER BY AttrType
ROLLBACK TRANSACTION
*/

CREATE   PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeAttributes]
(
@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeAttributes
* PURPOSE: To Insert and Update Scheme Attributes
* CREATED: Boopathy.P on 02/01/2009
*********************************/
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
						IF NOT EXISTS (SELECT RtrId FROM Retailer WITH (NOLOCK) WHERE RtrCode = LTRIM(RTRIM(@AttrCode)))
						BEGIN
							SET @ErrDesc = 'Retailer Code:'+ @AttrCode + ' not found for Scheme Code:'+ @SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @AttrId = RtrId FROM Retailer WITH (NOLOCK) WHERE RtrCode = LTRIM(RTRIM(@AttrCode))
						END
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'PRODUCT'
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
		INSERT INTO SchemeRetAttr
		SELECT DISTINCT B.SchId,6,A.RtrClassId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) 
		FROM RETAILERVALUECLASS A 
		INNER JOIN @Temp_CtgAttrDt B ON A.CtgMainId=B.CtgMainId 
		INNER JOIN @Temp_ValAttrDt C ON A.ValueClassCode = C.ValClass AND B.SchId=C.SchId
		AND B.SchId NOT IN (SELECT SchId FROM SchAttrToAvoid)
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-015

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeProducts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeProducts]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeProducts 0
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeProducts]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeProducts
* PURPOSE: To Insert and Update Scheme Products
* CREATED: Boopathy.P on 05/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode 	AS VARCHAR(50)
	DECLARE @Type  		AS VARCHAR(50)
	DECLARE @PrdCode 	AS VARCHAR(50)
	DECLARE @PrdBatCode 	AS VARCHAR(50)
	DECLARE @CmpId  	AS VARCHAR(50)
	DECLARE @TypeId  	AS VARCHAR(50)
	DECLARE @PrdId  	AS VARCHAR(50)
	DECLARE @PrdBatId 	AS VARCHAR(50)
	DECLARE @SchLevelId 	AS VARCHAR(50)
	DECLARE @BatchLvl 	AS VARCHAR(50)
	DECLARE @UDCId  	AS VARCHAR(50)
	DECLARE @CombiSch 	AS VARCHAR(50)
	DECLARE @ChkCount 	AS INT
	DECLARE @ErrDesc  	AS VARCHAR(1000)
	DECLARE @TabName  	AS VARCHAR(50)
	DECLARE @GetKey   	AS VARCHAR(50)
	DECLARE @Taction  	AS INT
	DECLARE @SelLvl   	AS VARCHAR(50)
	DECLARE @SelMode	AS VARCHAR(50)
	DECLARE @ConFig   	AS INT
	DECLARE @sSQL     	AS VARCHAR(4000)
	DECLARE @MaxSchLevelId 	AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @SLevel		AS INT

	SET @TabName = 'Etl_Prk_SchemeProducts_Combi'
	SET @Po_ErrNo =0

	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'

	DECLARE Cur_SchemePrds CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],ISNULL(SchLevel,'') AS [Type],
	ISNULL([PrdCode],'') AS [Code],ISNULL([PrdBatCode],'') AS [Batch Code] 
	FROM Etl_Prk_SchemeProducts_Combi WHERE SlabValue = 0 AND SlabId=0  
	AND CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code]
	OPEN Cur_SchemePrds
	FETCH NEXT FROM Cur_SchemePrds INTO @SchCode,@Type,@PrdCode,@PrdBatCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo =0
		SET @Taction = 2
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@Type))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@PrdCode))= ''
		BEGIN
			SET @ErrDesc = 'Product Code should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF NOT EXISTS(SELECT DISTINCT PRDID FROM PRODUCT)
		BEGIN
			SET @ErrDesc = 'No Product(s) found in Product Master'
			INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF NOT EXISTS(SELECT DISTINCT Prdbatid FROM PRODUCTBATCH)
		BEGIN
			SET @ErrDesc = 'No Batch found in Batch Master'
			INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END

-- 		ELSE IF UPPER(LTRIM(RTRIM(@Type)))='PRODUCT' AND UPPER(LTRIM(RTRIM(@Type)))='UDC'
-- 		BEGIN
-- 			SET @ErrDesc = 'Type should be (PRODUCT OR UDC)'
-- 			INSERT INTO Errorlog VALUES (1,@TabName,'Type',@ErrDesc)
-- 			SET @Taction = 0
-- 			SET @Po_ErrNo =1
-- 		END

		SELECT @Type= SchemeLevelMode FROM Etl_Prk_SchemeHD_Slabs_Rules 
		WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
		IF @Po_ErrNo=0
		BEGIN
			IF @ConFig<>1
			BEGIN
				IF NOT EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @ErrDesc = 'Company Scheme Code not found'
					INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId,@BatchLvl=BatchLevel,@SelMode=SchemeLvlMode
					FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId,@BatchLvl=BatchLevel,@SelMode=SchemeLvlMode
						FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @UDCId=A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
						ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
						AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
					BEGIN
						IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeProducts_Combi WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode)))
						BEGIN
							SET @ErrDesc = 'Company Scheme Code not found'
							INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
							B.CmpCode=A.CmpCode WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))

							SELECT @SchLevelId=CmpPrdCtgId FROM Etl_Prk_SchemeHD_Slabs_Rules A 
							INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
							INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
							AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
						END
					END
					ELSE
					BEGIN
						SELECT @CmpId=CmpId FROM ETL_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode))
	
						SELECT @SchLevelId=SchLevelId,@BatchLvl=BatchLevel,@SelMode=SchemeLvlMode
						FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END	END
			END
			IF UPPER(LTRIM(RTRIM(@Type)))='PRODUCT' OR UPPER(LTRIM(RTRIM(@Type)))='SKU' OR UPPER(LTRIM(RTRIM(@Type)))='MATERIAL'
			BEGIN
				SELECT @MaxSchLevelId=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				IF @MaxSchLevelId=@SchLevelId
				BEGIN
					IF NOT EXISTS(SELECT PrdId FROM Product WHERE CmpId=@CmpId
					AND PrdCCode=LTRIM(RTRIM(@PrdCode)))
					BEGIN
						IF @ConFig<>1
						BEGIN
							SET @ErrDesc = 'Product Code Not Found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (11,@TabName,'Product Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SET @PrdId= 0 --LTRIM(RTRIM(@PrdCode))
						END
					END
					ELSE
					BEGIN
						SELECT @PrdId=PrdId FROM Product WHERE CmpId=@CmpId
						AND PrdCCode=LTRIM(RTRIM(@PrdCode))
						SET @UDCId=0
						IF @BatchLvl=1
						BEGIN
							IF LTRIM(RTRIM(@PrdBatCode))= ''
							BEGIN
								SET @ErrDesc = 'Batch Code should not be blank for Product Code:'+ @PrdCode+' in Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'Batch Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1  					
							END
							IF NOT EXISTS(SELECT PrdBatId FROM ProductBatch WHERE PrdId=@PrdId AND
									PrdBatCode=LTRIM(RTRIM(@PrdBatCode)))
							BEGIN
								IF @ConFig<>1
								BEGIN
									SET @ErrDesc = 'Batch Code Not Found for Product Code:'+ @PrdCode+' in Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (11,@TabName,'Batch Code',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SET @PrdBatId=LTRIM(RTRIM(@PrdBatCode))
								END
							END
							ELSE
							BEGIN
								SELECT @PrdBatId=PrdBatId FROM ProductBatch WHERE PrdId=@PrdId AND
								PrdBatCode=LTRIM(RTRIM(@PrdBatCode))
							END
						END
						ELSE
						BEGIN
							SET @PrdBatId=0
						END
					END
				END
				ELSE  -- For Product Category Value
				BEGIN
					IF NOT EXISTS(SELECT A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
					ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
					AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId)
					BEGIN
						IF @ConFig<>1
						BEGIN
							SET @ErrDesc = 'Product Category Level Not Found for Product Code:'+ @PrdCode+' in Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (11,@TabName,'Product Category',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @UDCId=A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
								ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
								AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId
							SET @PrdId=0
							SET @PrdBatId=0
						END
					END
					ELSE
					BEGIN
						SELECT @UDCId=A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
						ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
						AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId
						SET @PrdId=0
						SET @PrdBatId=0
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@Type)))='UDC'
			BEGIN
				IF NOT EXISTS(SELECT DISTINCT A.UDCUniqueId FROM UdcDetails A INNER JOIN UdcMaster B
				ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
				INNER JOIN Product P ON A.MasterRecordId=P.PrdId AND P.CmpId=@CmpId
				WHERE A.UdcMasterId=@SchLevelId)
				BEGIN
					IF @ConFig<>1
					BEGIN
						SET @ErrDesc = 'UDC Not Found for Product Code:'+ @PrdCode+' in Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (11,@TabName,'UDC',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SET @UDCId=0
						SET @PrdId=0
						SET @PrdBatId=0
					END
				END
				ELSE
				BEGIN
					SELECT DISTINCT @UDCId=A.UDCUniqueId FROM UdcDetails A INNER JOIN UdcMaster B
					ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
					INNER JOIN Product P ON A.MasterRecordId=P.PrdId AND P.CmpId=@CmpId
					Where A.UdcMasterId=@SchLevelId
					SET @PrdId=0
					SET @PrdBatId=0
				END
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
			SELECT @ChkCount=COUNT(*) FROM TempDepCheck
			IF @ChkCount > 0
			BEGIN
				SET @Taction = 0
			END
			ELSE
			BEGIN
				IF @ConFig=1
				BEGIN

					SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId

					IF @SchLevelId<@SLevel
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
							IF @SLevel=@SchLevelId
							BEGIN
								DELETE FROM SCHEMEPRODUCTS WHERE PrdId=@PrdId AND PrdBatId= @PrdBatId AND
							     	SchId=@GetKey

							     	SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdId=' + CAST(@PrdId AS VARCHAR(50)) +
							     	' AND PrdBatId=' + CAST(@PrdBatId AS VARCHAR(50)) + ' AND SchId=' + CAST(@GetKey AS VARCHAR(50))
							END
							ELSE
							BEGIN
								DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=@UDCId AND
								SchId=@GetKey

								SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=' + CAST(@UDCId AS VARCHAR(50)) +
								' AND SchId=' + CAST(@GetKey AS VARCHAR(10))
							END
							
							INSERT INTO Translog(strSql1) Values (@sSQL)

							INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
							LastModBy,LastModDate,AuthId,AuthDate,RowId) VALUES(@GetKey,ISNULL(@UDCId,0),
							@PrdId ,@PrdBatId,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),1)
							
							SET @sSQL ='INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
							LastModBy,LastModDate,AuthId,AuthDate,RowId) VALUES('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
							CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
							',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',1)'
							INSERT INTO Translog(strSql1) Values (@sSQL)
						END
						ELSE
						BEGIN
							INSERT INTO Etl_Prk_SchemeProduct_Temp(CmpSchCode,PrdCtgValMainId,PrdId,PrdCode,PrdBatId,UpLoadFlag)
							VALUES(LTRIM(RTRIM(@SchCode)),@UDCId,@PrdId,LTRIM(RTRIM(@PrdCode)),@PrdBatId,'N')

							SET @sSQL ='INSERT INTO Etl_Prk_SchemeProduct_Temp(CmpSchCode,PrdCtgValMainId,PrdId,PrdCode,PrdBatId,UpLoadFlag)
							VALUES('+ CAST(@SchCode AS VARCHAR(50)) + ',' +
							CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdCode AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
							 ',''N'''')'
							INSERT INTO Translog(strSql1) Values (@sSQL)
							SET @Po_ErrNo=0
						END
					END
					ELSE
					BEGIN
						IF @SLevel=@SchLevelId
						BEGIN
							DELETE FROM Etl_Prk_SchemeProduct_Temp WHERE PrdId=CAST(@PrdId AS VARCHAR(50)) AND PrdBatId= CAST(@PrdBatId AS VARCHAR(50)) AND
						     	CmpSchCode=@GetKey AND UpLoadFlag='N'
						END
						ELSE
						BEGIN
							DELETE FROM Etl_Prk_SchemeProduct_Temp WHERE PrdCtgValMainId=CAST(@UDCId  AS VARCHAR(50)) AND
							CmpSchCode=@GetKey AND UpLoadFlag='N'
						END
						INSERT INTO Translog(strSql1) Values (@sSQL)

						INSERT INTO Etl_Prk_SchemeProduct_Temp(CmpSchCode,PrdCtgValMainId,PrdId,PrdCode,PrdBatId,UpLoadFlag)
						VALUES(LTRIM(RTRIM(@SchCode)),@UDCId,@PrdId,LTRIM(RTRIM(@PrdCode)),@PrdBatId,'N')

						SET @sSQL ='INSERT INTO Etl_Prk_SchemeProduct_Temp(CmpSchCode,PrdCtgValMainId,PrdId,PrdCode,PrdBatId,UpLoadFlag)
						VALUES('+ CAST(@SchCode AS VARCHAR(50)) + ',' +
						CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdCode AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
						 ',''N'''')'
						INSERT INTO Translog(strSql1) Values (@sSQL)
						SET @Po_ErrNo=0
						
					END		
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@Type)))='UDC'
					BEGIN
						DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=@UDCId AND
						SchId=@GetKey

-- 						SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=' + CAST(@UDCId AS VARCHAR(10)) +
-- 						' AND SchId=' + CAST(@GetKey AS VARCHAR(10))
-- 						INSERT INTO Translog(strSql1) Values (@sSQL)

						INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
						LastModBy,LastModDate,AuthId,AuthDate,RowId) VALUES(@GetKey,ISNULL(@UDCId,0),
						@PrdId,@PrdBatId,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),1)

-- 						SET @sSQL ='INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
-- 						LastModBy,LastModDate,AuthId,AuthDate) VALUES('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
-- 						CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
-- 						',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
					ELSE IF UPPER(LTRIM(RTRIM(@Type)))='PRODUCT' OR UPPER(LTRIM(RTRIM(@Type)))='SKU' OR UPPER(LTRIM(RTRIM(@Type)))='MATERIAL'
					BEGIN
						IF @MaxSchLevelId=@SchLevelId
						BEGIN
						     DELETE FROM SCHEMEPRODUCTS WHERE PrdId=@PrdId AND PrdBatId= @PrdBatId AND
						     SchId=@GetKey

-- 						     SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdId=' + CAST(@PrdId AS VARCHAR(50)) +
-- 						     ' AND PrdBatId=' + CAST(@PrdBatId AS VARCHAR(50)) + ' AND SchId=' + CAST(@GetKey AS VARCHAR(50))
						END
						ELSE
						BEGIN
						     DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=@UDCId AND
						     SchId=@GetKey

-- 						     SET @sSQL ='DELETE FROM SCHEMEPRODUCTS WHERE PrdCtgValMainId=' + CAST(@UDCId AS VARCHAR(50)) +
-- 						     ' AND SchId=' + CAST(@GetKey AS VARCHAR(10))
						END
						INSERT INTO Translog(strSql1) Values (@sSQL)
						INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
						LastModBy,LastModDate,AuthId,AuthDate,RowId) VALUES(@GetKey,ISNULL(@UDCId,0),
						@PrdId,@PrdBatId,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),1)

-- 						SET @sSQL ='INSERT INTO SCHEMEPRODUCTS(SchId,PrdCtgValMainId,PrdId,PrdBatId,Availability,
-- 						LastModBy,LastModDate,AuthId,AuthDate) VALUES('+ CAST(ISNULL(@GetKey,0) AS VARCHAR(10)) + ',' +
-- 						CAST(@UDCId AS VARCHAR(50)) + ',' + CAST(@PrdId AS VARCHAR(50)) + ',' + CAST(@PrdBatId AS VARCHAR(50)) +
-- 						',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
	    				END
				END
			END
		END
		FETCH NEXT FROM Cur_SchemePrds INTO @SchCode,@Type,@PrdCode,@PrdBatCode
	END

	CLOSE Cur_SchemePrds
	DEALLOCATE Cur_SchemePrds
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-016

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeSlab]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeSlab]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeSlab 0
--SELECT *  FROM Etl_Prk_SchemeHD_Slabs_Rules
--SELECT * FROM SchemeMaster
SELECT * FROM ErrorLog
SELECT DISTINCT SchId FROM dbo.SchemeSlabs
ROLLBACK TRANSACTION
*/
CREATE     PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeSlab]
(
	@Po_ErrNo INT OUTPUT	
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeSlab 1
* PURPOSE: To Insert and Update Scheme Slab Details
* CREATED: Boopathy.P on 02/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode AS VARCHAR(50)
	DECLARE @SlabCode AS INT 
	DECLARE @FromUOM AS VARCHAR(200)
	DECLARE @FromQty AS NUMERIC(18,6) 
	DECLARE @ToUOM  AS VARCHAR(200)
	DECLARE @ToQty  AS NUMERIC(18,6) 
	DECLARE @ForEveryUOM AS VARCHAR(200)
	DECLARE @ForEveryQty AS NUMERIC(18,6) 
	DECLARE @DiscPer AS NUMERIC(5,2) 
	DECLARE @FlatAmt AS NUMERIC(18,6) 
	DECLARE @Points  AS NUMERIC(18,6) 
	DECLARE @FlexiFree AS NUMERIC(18,6) 
	DECLARE @FlexiGift AS NUMERIC(18,6) 
	DECLARE @FlexiDisc AS NUMERIC(18,6) 
	DECLARE @FlexiFlat AS NUMERIC(18,6) 
	DECLARE @FlexiPoints AS INT
	DECLARE @TempRange AS NUMERIC(18,6) 
	DECLARE @CmpId  AS INT
	DECLARE @SchLevelId AS INT
	DECLARE @SchType AS INT
	DECLARE @FlexiId AS INT
	DECLARE @RangeId AS INT
	DECLARE @FlexiType AS INT
	DECLARE @CombiSch AS INT
	DECLARE @FlexiCnt AS INT
	DECLARE @FromUomId AS INT
	DECLARE @ToUomId AS INT
	DECLARE @ForEveryUomId AS INT
	DECLARE @ChkCount AS INT
	DECLARE @PurOfEvery	 AS INT
	DECLARE @ErrDesc  AS VARCHAR(1000)
	DECLARE @TabName  AS VARCHAR(50)
	DECLARE @GetKey  AS VARCHAR(50)
	DECLARE @Taction  AS INT
	DECLARE @MAXSLABID AS INT
	DECLARE @sSQL   AS VARCHAR(4000)
	DECLARE @MaxSchLevelId	AS INT
	DECLARE @CntVal	As	INT
	DECLARE @TempStr	AS Varchar(4000)
	DECLARE @TempStr1	AS Varchar(4000)
	DECLARE @SLevel		AS INT
	DECLARE @CmpPrdCtgId	AS INT
	DECLARE @MaxDisc  AS NUMERIC(18,2)
	DECLARE @MinDisc  AS NUMERIC(18,2)
	DECLARE @MaxValue  AS NUMERIC(18,2)
	DECLARE @MinValue  AS NUMERIC(18,2)
	DECLARE @MaxPoints  AS INT
	DECLARE @MinPoints  AS INT
	DECLARE @ConFig		AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @SlabNotAppl AS INT

	Create Table  #TempTbl
	(
		PrdUnitId	INT,
		PrdUnitGrpId	INT,
		PrdUnitCode	Varchar(50)
	)

	SET @TabName = 'Etl_Prk_SchemeHD_Slabs_Rules'
	SET @Po_ErrNo =0
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'

	DECLARE Cur_SchemeSlabDt CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],
	ISNULL([SlabId],0) AS [SlabId],
	ISNULL([Uom],'0') AS [From Uom],
	CASE ISNULL([FromQty],'') WHEN '' THEN 0 ELSE CAST([FromQty] AS NUMERIC(18,2)) END AS [From Qty],
	ISNULL([ToUom],'0') AS [To Uom],
	CASE ISNULL([ToQty],'') WHEN '' THEN 0 ELSE CAST([ToQty] AS NUMERIC(18,2)) END AS [To Qty],
	ISNULL([ForEveryUom],'0') AS [For Every Uom],
	CASE ISNULL([ForEveryQty],'') WHEN '' THEN 0 ELSE CAST([ForEveryQty] AS NUMERIC(18,2)) END AS [For Every Qty],
	CASE ISNULL([DiscPer],'') WHEN '' THEN 0 ELSE CAST([DiscPer] AS NUMERIC(5,2)) END AS [Disc %],
	CASE ISNULL([FlatAmt],'') WHEN '' THEN 0 ELSE CAST([FlatAmt] AS NUMERIC(18,2)) END AS [Flat Amount],
	CASE ISNULL([Points],'') WHEN '' THEN 0 ELSE CAST([Points] AS NUMERIC(18,2)) END AS [Point],
	CASE ISNULL([FlxFreePrd],'') WHEN '' THEN 0 ELSE [FlxFreePrd] END AS [Flexi Free],
	CASE ISNULL([FlxGiftPrd],'') WHEN '' THEN 0 ELSE [FlxGiftPrd] END AS [Flexi Gift],
	CASE ISNULL([FlxDisc],'') WHEN '' THEN 0 ELSE [FlxDisc] END AS [Flexi Disc],
	CASE ISNULL([FlxValueDisc],'') WHEN '' THEN 0 ELSE [FlxValueDisc] END AS [Flexi Flat],
	CASE ISNULL([FlxPoints],'') WHEN '' THEN 0 ELSE [FlxPoints] END AS [Flexi Points],
	CASE ISNULL([MaxDiscount],'') WHEN '' THEN 0 ELSE CAST([MaxDiscount] AS NUMERIC(18,2)) END AS [Max Discount],
	CASE ISNULL([MinDiscount],'') WHEN '' THEN 0 ELSE CAST([MinDiscount] AS NUMERIC(18,2)) END AS [Min Discount],
	CASE ISNULL([MaxValue],'') WHEN '' THEN 0 ELSE CAST([MaxValue] AS NUMERIC(18,2)) END AS [Max Value],
	CASE ISNULL([MinValue],'') WHEN '' THEN 0 ELSE CAST([MinValue] AS NUMERIC(18,2)) END AS [Min Value],
	CASE ISNULL([MaxPoints],'') WHEN '' THEN 0 ELSE CAST([MaxPoints] AS NUMERIC(18,2)) END AS [Max Points],
	CASE ISNULL([MinPoints],'') WHEN '' THEN 0 ELSE CAST([MinPoints] AS NUMERIC(18,2)) END AS [Min Points]
	FROM Etl_Prk_SchemeHD_Slabs_Rules 
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code],[SlabId]
	OPEN Cur_SchemeSlabDt
	FETCH NEXT FROM Cur_SchemeSlabDt INTO @SchCode,@SlabCode,@FromUOM,@FromQty,@ToUOM,@ToQty,@ForEveryUOM,
	@ForEveryQty,@DiscPer,@FlatAmt,@Points,@FlexiFree,@FlexiGift,@FlexiDisc,@FlexiFlat,@FlexiPoints,
	@MaxDisc,@MinDisc,@MaxValue,@MinValue,@MaxPoints,@MinPoints
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @CntVal=1
		SET @FromUomId=0
		SET @ToUomId=0
		SET @ForEveryUomId=0
		SET @TempStr=''
		SET @TempStr1=''

		DELETE FROM #TempTbl
		SELECT @MAXSLABID=MAX([SlabId])  FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE  [CmpSchCode]=@SchCode
		SET @Taction = 2

		SET @Po_ErrNo =0

		---->Modified By Nanda on 16/09/2009
		SET @SlabNotAppl=0
		IF (LTRIM(RTRIM(@SlabCode))= '---' OR LTRIM(RTRIM(@SlabCode))= '0')
		BEGIN						
			SET @SlabNotAppl=1
		END
		---->Till Here

		IF @SlabNotAppl=0
		BEGIN
			IF LTRIM(RTRIM(@SchCode))= ''
			BEGIN
				SET @ErrDesc = 'Company Scheme Code should not be blank'
				INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LEN(LTRIM(RTRIM(@SlabCode)))= 0
			BEGIN
				SET @ErrDesc = 'Slab Details should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Slab Details',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			IF @Po_ErrNo=0
			BEGIN
				IF @ConFig<>1
				BEGIN
					IF NOT EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
					BEGIN
						SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,@SchType=SchType,
						@RangeId=Range,@CombiSch=CombiSch,@PurOfEvery=PurofEvery,@CmpPrdCtgId=SchLevelId  FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
					BEGIN
						SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,@SchType=SchType,
						@RangeId=Range,@CombiSch=CombiSch,@PurOfEvery=PurofEvery,@CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					END
					ELSE
						IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
						BEGIN
							IF NOT EXISTS(SELECT [CmpSchCode] FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE
							[CmpSchCode]=LTRIM(RTRIM(@SchCode)))
							BEGIN
								SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode +' in table Etl_Prk_SchemeHD_Slabs_Rules '
								INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
								B.CmpCode=A.[CmpCode] WHERE [CmpSchCode]=LTRIM(RTRIM(@SchCode))
								SELECT @SchLevelId=C.CmpPrdCtgId,@FlexiId=A.FlexiSch,@CombiSch=A.CombiSch,
								@FlexiType=A.FlexiSchType,@SchType=A.SchType,@RangeId=A.Range
								FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
								INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
								AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
							END
						END
					ELSE
					BEGIN
						SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM Etl_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,
						@SchType=SchType,@RangeId=Range,@CombiSch=CombiSch,@CmpPrdCtgId=SchLevelId FROM Etl_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SET @Po_ErrNo =0
					END
				END
			END
			IF @Po_ErrNo=0
			BEGIN
				IF @FlexiId=1
				BEGIN
					SET @FlexiCnt=0
					IF LTRIM(RTRIM(@FlexiFree))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF LTRIM(RTRIM(@FlexiGift))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF LTRIM(RTRIM(@FlexiDisc))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF LTRIM(RTRIM(@FlexiFlat))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF LTRIM(RTRIM(@FlexiPoints))='0'
					BEGIN
						SET @FlexiCnt=@FlexiCnt + 1
					END
					IF @FlexiCnt=5
					BEGIN
						SET @ErrDesc = 'Select Only Flexi Items for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'FLEXI SCHEME',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
				END
				IF @RangeId=1
				BEGIN
					IF @SchType<>2
					BEGIN
						IF LTRIM(RTRIM(@FromUOM))='0'
						BEGIN
							SET @ErrDesc = 'From UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						IF LTRIM(RTRIM(@ToUOM))='0'
						BEGIN
							IF 	@MAXSLABID <> @SlabCode
							BEGIN
								SET @ErrDesc = 'To UOM Should Not Be Blank for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'RANGE SCHEME',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END    
						END
					END
					IF LTRIM(RTRIM(@FromQty))='0'
					BEGIN
						SET @ErrDesc = 'From Qty Should Not Be Blank for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'RANGE SCHEME',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					IF @MAXSLABID =@SlabCode
					BEGIN
						IF CONVERT(INT,@ToQty)>0
						BEGIN
							SET @ErrDesc = 'To Qty Should be ZERO for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'RANGE SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
				END
				IF @CombiSch=1
				BEGIN
					IF @SchType<>2
					BEGIN
						IF LTRIM(RTRIM(@FromUOM))='0'
						BEGIN
							SET @ErrDesc = 'From UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							 SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
						END
						IF LTRIM(RTRIM(@ForEveryUOM))='0'
						BEGIN
							SET @ErrDesc = 'For Every UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							 SELECT @ForEveryUOMId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM))
						END
					END
					IF LTRIM(RTRIM(@FromQty))='0'
					BEGIN
						SET @ErrDesc = 'From Qty Should Not Be Blank for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					IF @PurOfEvery=1
					BEGIN
						IF LTRIM(RTRIM(@ForEveryQty))='0'
						BEGIN
							SET @ErrDesc = 'For Every Qty Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
				END
				IF @FlexiId=0 AND @CombiSch=0 AND @RangeId=0
				BEGIN
					IF @SchType<>2
					BEGIN
						IF LTRIM(RTRIM(@FromUOM))='0'
						BEGIN
							SET @ErrDesc = 'From UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						IF LTRIM(RTRIM(@ForEveryUOM))='0'
						BEGIN
							SET @ErrDesc = 'For Every UOM Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'COMBI SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
					IF LTRIM(RTRIM(@FromQty))='0'
					BEGIN
						SET @ErrDesc = 'From Qty Should Not Be Blank for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'NORMAL SCHEME',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					IF @PurOfEvery=1
					BEGIN
						IF LTRIM(RTRIM(@ForEveryQty))='0'
						BEGIN
							SET @ErrDesc = 'For Every Qty Should Not Be Blank for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'NORMAL SCHEME',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
				END
			END
			IF @Po_ErrNo=0
			BEGIN
				SELECT @MaxSchLevelId=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				IF @SchType<>4
				BEGIN
					IF @FlexiId=0 AND @CombiSch=0 AND @RangeId=0
					BEGIN
						IF @SchType=1
						BEGIN
							IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
							BEGIN
								SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
							END
							---->Modified By Nanda on 23/08/2009
							IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
							BEGIN
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM)))
								BEGIN
									SET @ErrDesc = 'For Every Uom:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'For Every UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @ForEveryUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM))
								END
							END
							ELSE
							BEGIN
								SET @ForEveryUomId=0
							END
							--->Till Here
						END
						ELSE IF @SchType=3
						BEGIN
							IF @MaxSchLevelId=@SchLevelId
							BEGIN
								IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (1) for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
									SET @FromUomId= ISNULL(@FromUomId,0)
								END
			
								---->Modified By Nanda on 23/08/2009
								IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
								BEGIN
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
									BEGIN
										SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
										SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
									END
								END
								ELSE
								BEGIN
									SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
								END
							END
							ELSE
							BEGIN
								SET @sSQL=''
								IF @CntVal=(@MaxSchLevelId-@SchLevelId)
								BEGIN
									SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
								END
								ELSE
								BEGIN
									WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
									BEGIN
										IF @CntVal=1
										BEGIN
											SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
												  (SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
												   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
										END
			
											SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
											SET @TempStr1=@TempStr1+ ')'
										SET @CntVal=@CntVal+1	
										IF @CntVal=(@MaxSchLevelId-@SchLevelId)
										BEGIN
											IF ISNUMERIC(@GetKey)=1
											BEGIN									
												SET @sSQL=@sSQL + @TempStr +'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
												ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
											END
											ELSE
											BEGIN
												SET @sSQL=@sSQL + @TempStr +'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
												ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1
											END																
										END
										
									END	
								END
								--Test		
								--SELECT @sSQL			
								EXEC(@sSQL)
								IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (2) for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
									SET @FromUomId= ISNULL(@FromUomId,0)
								END
								IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
								BEGIN
									SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
									SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
								END
							END
						END
					END
					ELSE IF @FlexiId=1
					BEGIN
						IF @CombiSch=1
						BEGIN
							IF @SchType=1
							BEGIN
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
								END
								---->Modified By Nanda on 23/08/2009
								IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
								BEGIN
									IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM)))
									BEGIN
										SET @ErrDesc = 'For Every Uom:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'For Every UOM',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ForEveryUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM))
									END
								END
								ELSE
								BEGIN
									SET @ForEveryUomId=0
								END
								---->Till Here
							END
							ELSE IF @SchType=3
							BEGIN
								IF @MaxSchLevelId=@SchLevelId
								BEGIN
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (3) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
				
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
									BEGIN
										IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
										BEGIN
											SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
											INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
											SET @Taction = 0
											SET @Po_ErrNo =1
										END
										ELSE
										BEGIN
											SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
											SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
										END
									END
									ELSE	
									BEGIN
										SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
									END
								END
								ELSE
								BEGIN
									SET @sSQL=''
									IF @CntVal=(@MaxSchLevelId-@SchLevelId)
									BEGIN
										SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
									END
									ELSE
									BEGIN
										WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
										BEGIN
											IF @CntVal=1
											BEGIN
												SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
										  				(SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
													   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
											END
			-- 								IF @CntVal<>1
			-- 								BEGIN
												SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
												SET @TempStr1=@TempStr1+ ')'
			-- 								END
											SET @CntVal=@CntVal+1
											IF @CntVal=(@MaxSchLevelId-@SchLevelId)
											BEGIN
												IF ISNUMERIC(@GetKey)=1
												BEGIN				
												SET @sSQL=@sSQL + @TempStr +
												'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
												ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
												END
												BEGIN
													SET @sSQL=@sSQL + @TempStr +
												'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
												ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1	
												END	
											END
										END		
									END
									EXEC(@sSQL)
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (4) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
			
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
									BEGIN
										SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
										SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
									END
								END
							END
						END
						ELSE IF @RangeId=1
						BEGIN
							IF @SchType=1
							BEGIN
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
								END
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ToUOM)))
								BEGIN
									SET @ErrDesc = 'To Uom:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'To UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @ToUomId=ISNULL(UomId,0) FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ToUOM))
								END
							END
							ELSE IF @SchType=3
							BEGIN
								IF @MaxSchLevelId=@SchLevelId
								BEGIN
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (5) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN															
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
				
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM)))
									BEGIN
										SET @ErrDesc = 'To PrdUnitCode:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'To PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ToUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM))
										SET @ToUomId=ISNULL(@ToUomId,0)
									END
								END
								ELSE
								BEGIN
									SET @sSQL=''
									IF @CntVal=(@MaxSchLevelId-@SchLevelId)
									BEGIN
										SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
									END
									ELSE
									BEGIN
										WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
										BEGIN
											IF @CntVal=1
											BEGIN
												SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
										  				(SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
													   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
											END
			-- 								IF @CntVal<>1
			-- 								BEGIN
												SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
												SET @TempStr1=@TempStr1+ ')'
			-- 								END
											SET @CntVal=@CntVal+1
											IF @CntVal=(@MaxSchLevelId-@SchLevelId)
											BEGIN
												IF ISNUMERIC(@GetKey)=1
												BEGIN					
													SET @sSQL=@sSQL + @TempStr +
													'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
													ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
												END
												ELSE
												BEGIN					
													SET @sSQL=@sSQL + @TempStr +
													'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
													ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1
												END		
											END
										END	
									END
									EXEC(@sSQL)
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (6) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
			
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM)))
									BEGIN
										SET @ErrDesc = 'To PrdUnitCode:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'To PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @ToUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM))
										SET @ToUomId= ISNULL(@ToUomId,0)
									END
								END
							END
						END
						ELSE
						BEGIN
							IF @SchType=1
							BEGIN
								IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
								BEGIN
									SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
								END
							END
							ELSE IF @SchType=3
							BEGIN
								IF @MaxSchLevelId=@SchLevelId
								BEGIN
									IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (7) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0)FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
								END
								ELSE
								BEGIN
									SET @sSQL=''
									IF @CntVal=(@MaxSchLevelId-@SchLevelId)
									BEGIN
										SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
									END
									ELSE
									BEGIN
										WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
										BEGIN
											IF @CntVal=1
											BEGIN
												SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
										  				(SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
													   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
											END
											SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
											SET @TempStr1=@TempStr1+ ')'
											SET @CntVal=@CntVal+1
											IF @CntVal=(@MaxSchLevelId-@SchLevelId)
											BEGIN
												IF ISNUMERIC(@GetKey)=1
												BEGIN
													SET @sSQL=@sSQL + @TempStr +
													'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
													ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
												END
												ELSE
												BEGIN
													SET @sSQL=@sSQL + @TempStr +
													'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
													ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1
												END																						
											END
										END		
									END
									EXEC(@sSQL)
									IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
									BEGIN
										SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (8) for Scheme Code:'+@SchCode
										INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
										SET @Taction = 0
										SET @Po_ErrNo =1
									END
									ELSE
									BEGIN
										SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
										SET @FromUomId= ISNULL(@FromUomId,0)
									END
			
								END
							END
						END
					END
				ELSE IF @FlexiId=0 AND @CombiSch=0 AND @RangeId=1
				BEGIN
					IF @SchType=3
					BEGIN
						
						IF @MaxSchLevelId=@SchLevelId
						BEGIN
							IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
							BEGIN
								SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (9) for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
								SET @FromUomId= ISNULL(@FromUomId,0)
							END
			
							IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM)))
							BEGIN
								SET @ErrDesc = 'To PrdUnitCode:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'To PrdUnitCode',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @ToUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM))
								SET @ToUomId=ISNULL(@ToUomId,0)
							END
			
							--Test
							IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
							BEGIN
								IF NOT EXISTS (SELECT PrdUnitId FROM ProductUnit WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
								BEGIN
									SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM ProductUnit  WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
									SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
								END
							END
							ELSE
							BEGIN
								SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
							END
						END
						ELSE
						BEGIN
							SET @sSQL=''
							IF @CntVal=(@MaxSchLevelId-@SchLevelId)
							BEGIN
								SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit'
							END
							ELSE
							BEGIN
								WHILE @CntVal<>(@MaxSchLevelId-@SchLevelId)	
								BEGIN
									IF @CntVal=1
									BEGIN
										SET @sSQL='INSERT INTO #TempTbl SELECT PrdUnitId,PrdUnitGrpId,PrdUnitCode FROM ProductUnit WHERE PrdUnitGrpId IN
												  (SELECT PrdUnitGrpId FROM ProductUnit WHERE PrdUnitId IN(
											   SELECT DISTINCT PrdUnitId From Product WHERE PrdctgValMainId IN('
									END
									
			-- 						IF @CntVal<>1
			-- 						BEGIN
										SET @TempStr=@TempStr + 'SELECT PrdctgValMainId FROM ProductCategoryValue WHERE PrdCtgValLinkId IN('
										SET @TempStr1=@TempStr1+ ')'
			-- 						END
									SET @CntVal=@CntVal+1
									
									IF @CntVal=(@MaxSchLevelId-@SchLevelId)
									BEGIN
										IF ISNUMERIC(@GetKey)=1
										BEGIN				
										SET @sSQL=@sSQL + @TempStr +
										'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
											ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=' + CAST(@GetKey AS Varchar(10))+ ')))'+@TempStr1
										END
										ELSE
										BEGIN				
										SET @sSQL=@sSQL + @TempStr +
										'SELECT DISTINCT S.PrdCtgValMainId FROM SchemeProducts S INNER JOIN
											ProductCategoryValue P ON S.PrdCtgValMainId=P.PrdCtgValMainId Where SchId=0)))'+@TempStr1
										END
									END
								END	
							END			
							EXEC(@sSQL)
							IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM)))
							BEGIN
								SET @ErrDesc = 'From Prd Unit Code:'+@FromUOM+' not Found (10) for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @FromUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@FromUOM))
								SET @FromUomId= ISNULL(@FromUomId,0)
							END
			
							IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM)))
							BEGIN
								SET @ErrDesc = 'From Prd Unit Code:'+@ToUOM+' not Found (11) for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'From PrdUnitCode',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @ToUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ToUOM))
								SET @ToUomId= ISNULL(@FromUomId,0)
							END
							IF NOT EXISTS(SELECT * FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM)))
							BEGIN
								
								SET @ErrDesc = 'For Every Prd Unit Code:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'For Every Prd Unit Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN						SELECT @ForEveryUomId=ISNUll(PrdUnitId,0) FROM #TempTbl WHERE PrdUnitCode=LTRIM(RTRIM(@ForEveryUOM))
								SET @ForEveryUomId= ISNULL(@ForEveryUomId,0)
							END
						END
					END
					ELSE IF @SchType=1
					BEGIN
						IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM)))
						BEGIN
							SET @ErrDesc = 'From Uom:'+@FromUOM+' not Found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'From UOM',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @FromUomId=UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@FromUOM))
							SET @ToUomId= ISNULL(@ToUomId,0)
						END
						IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ToUOM)))
						BEGIN
							SET @ErrDesc = 'To Uom:'+@ToUOM+' not Found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'To UOM',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @ToUomId=ISNUll(UomId,0) FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ToUOM))
							SET @ToUomId= ISNULL(@ToUomId,0)
						END
						---->Modified By Nanda on 23/08/2009
						IF EXISTS(SELECT * FROM SchemeMaster WHERE CmpSchCode=@SchCode AND PurOfEvery=1)  
						BEGIN
							IF NOT EXISTS (SELECT UomId FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM)))
							BEGIN
								SET @ErrDesc = 'For Every Uom:'+@ForEveryUOM+' not Found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (1,@TabName,'For Every UOM',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							ELSE
							BEGIN
								SELECT @ForEveryUomId=ISNUll(UomId,0) FROm UomMaster WHERE UomCode=LTRIM(RTRIM(@ForEveryUOM))
								SET @ForEveryUomId=ISNULL(@ForEveryUomId,0)
							END
						END
						ELSE
						BEGIN
							SET @ForEveryUomId=0
						END
						--->Till Here	
					END
				END
			END
			IF @SchType<>4
			BEGIN
				IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeMaster_Temp WHERE
					CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
				END
				
				SELECT @ChkCount=COUNT(*) FROM TempDepCheck
				IF @ChkCount > 0
				BEGIN
					SET @Taction=0
				END
				ELSE
				BEGIN
					IF @CombiSch=0 AND @FlexiId=0 AND @RangeId=0
					BEGIN
		  				IF   @SchType=2
						BEGIN
							SET @ForEveryUomId=0
							SET @ToUomId=0
							SET @FromUomId=0
						END
						SET @ToUomId=0
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
									DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 							SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
									MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
									0,@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
									convert(INT,@FlexiFree),convert(INT,@FlexiGift),convert(INT,@FlexiPoints),convert(NUMERIC(18,2),@Points),1,1,convert(varchar(10),getdate(),121),
									1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
						
		-- 							SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
								ELSE
								BEGIN
									DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		--							SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		--							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		--							INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
									VALUES (@GetKey,@SlabCode,@FromQty,0,@FromUomId,
									0,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
									@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
						
		-- 							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',0,0,0,0,0,0,''N'')'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		--						SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		--						' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		--						INSERT INTO Translog(strSql1) Values (@sSQL)
								INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
								Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
								VALUES (@GetKey,@SlabCode,@FromQty,0,@FromUomId,
								0,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
								@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
					
		-- 						SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 						MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 						CAST(@SlabCode AS VARCHAR(8)) + ',' + CAST(@FromQty AS VARCHAR(8)) + ',' + CAST(0 AS VARCHAR(8)) + ',' +
		-- 						CAST(@FromUomId AS VARCHAR(8)) + ',' + CAST(0 AS VARCHAR(8)) + ',' + CAST(@ToUomId AS VARCHAR(8)) + ',' +
		-- 						CAST(@ForEveryQty AS VARCHAR(8)) + ',' + CAST(@ForEveryUomId AS VARCHAR(8)) + ',' + CAST(@DiscPer AS VARCHAR(8)) + ',' +
		-- 						CAST(@FlatAmt AS VARCHAR(8)) + ',' + CAST(@FlexiDisc AS VARCHAR(8)) + ',' + CAST(@FlexiFlat AS VARCHAR(8)) + ',' +
		-- 						CAST(@FlexiFree AS VARCHAR(8)) + ',' + CAST(@FlexiGift AS VARCHAR(8)) + ',' + CAST(@FlexiPoints AS VARCHAR(8)) + ',' + CAST(@Points AS VARCHAR(8)) +
		-- 						',0,0,0,0,0,0,''N'')'
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
								SET @Po_ErrNo =0
							END
						END
						ELSE
						BEGIN
							DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 					SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 					' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
							
							INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
							MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
							0,@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
							convert(INT,@FlexiFree),convert(INT,@FlexiGift),convert(INT,@FlexiPoints),convert(NUMERIC(18,2),@Points),1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
				
		-- 					SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 					ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 					Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 					MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 					CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 					CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 					CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 					',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
						END
					END
					ELSE IF @FlexiId=1 AND @RangeId=0 AND @CombiSch=0
					BEGIN
						IF @FlexiType=1 OR @FlexiType=2
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
										DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 								SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 								' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 								INSERT INTO Translog(strSql1) Values (@sSQL)
						
										INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
										ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
										Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
										MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
										0,convert(INT,@ToUomId),convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
										convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
										1,convert(varchar(10),getdate(),121),convert(INT,@MaxDisc),convert(INT,@MinDisc),convert(INT,@MaxValue),convert(INT,@MinValue),@MaxPoints,@MinPoints)
						
		-- -- 								SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- -- 								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- -- 								Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- -- 								MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- -- 								CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- -- 								',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''','+
		-- -- 								CAST(@MaxDisc AS VARCHAR(10))+','+CAST(@MinDisc AS VARCHAR(10))+','+CAST(@MaxValue AS VARCHAR(10))+','+CAST(@MinValue AS VARCHAR(10))+','+
		-- -- 								CAST(@MaxPoints AS VARCHAR(10))+','+CAST(@MinPoints AS VARCHAR(10))+')'
		-- -- 								INSERT INTO Translog(strSql1) Values (@sSQL)
									END
									ELSE
									BEGIN
										DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		-- 								SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 								' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 								INSERT INTO Translog(strSql1) Values (@sSQL)
										INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
										ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
										Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
										VALUES (@GetKey,@SlabCode,@FromQty,0,@FromUomId,
										0,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
										@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
		-- 					
		-- 								SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 								Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 								MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 								CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 								CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 								CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 								CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 								CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 								',0,0,0,0,0,0,''N'')'
		-- 								INSERT INTO Translog(strSql1) Values (@sSQL)
										SET @Po_ErrNo =0
									END
								END
								ELSE
								BEGIN
									DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		--							SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		--							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		--							INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
									VALUES (@GetKey,@SlabCode,@FromQty,0,@FromUomId,
									0,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
									@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
						
		-- 							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',0,0,0,0,0,0,''N'')'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
							END
							ELSE
							BEGIN
								DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 						SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 						' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
								INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
								Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
								MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
								0,convert(INT,@ToUomId),convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
								convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
								1,convert(varchar(10),getdate(),121),convert(INT,@MaxDisc),convert(INT,@MinDisc),convert(INT,@MaxValue),convert(INT,@MinValue),@MaxPoints,@MinPoints)
				
		-- 						SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 						MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 						CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 						CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 						CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 						',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''','+
		-- 						CAST(@MaxDisc AS VARCHAR(10))+','+CAST(@MinDisc AS VARCHAR(10))+','+CAST(@MaxValue AS VARCHAR(10))+','+CAST(@MinValue AS VARCHAR(10))+','+
		-- 						CAST(@MaxPoints AS VARCHAR(10))+','+CAST(@MinPoints AS VARCHAR(10))+')'
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
							END
						END
					END
					ELSE IF @CombiSch=1 AND @FlexiId=0
					BEGIN
						
						IF NOT EXISTS(SELECT SchId FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode)
						BEGIN
							DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 					SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 					' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
				
							INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
							MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),0,@FromUomId,
							0,convert(INT,@ToUomId),convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
							convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
				
		-- 					SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 					ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 					Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 					MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 					CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' +
		-- 					CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 					CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 					',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 					IF EXISTS(SELECT SchId FROM SchemeSlabCombiPrds WHERE SchId=@GetKey AND SlabId=@SlabCode)
		-- 					BEGIN
		-- 						DELETE FROM SchemeSlabCombiPrds WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 						SET @sSQL='DELETE FROM SchemeSlabCombiPrds WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 						' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 		
		-- 						INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,SlabValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		-- 						SELECT @GetKey AS SchId,@SlabCode AS SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,@FromQty AS SlabValue,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121)
		-- 						FROM SchemeProducts WHERE SchId=@GetKey
				
		-- 						SET @sSQL ='INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,SlabValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		-- 						SELECT ' + CAST(@GetKey AS VARCHAR(10)) + 'AS SchId,'+ CAST(@SlabCode AS VARCHAR(10)) + 'AS SlabId,
		-- 						PrdCtgValMainId,PrdId,PrdBatId' + CAST(@FromQty AS VARCHAR(10)) + 'AS SlabValue,1,1,
		-- 						''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + '''
		-- 						FROM SchemeProducts WHERE SchId=' + CAST(@GetKey AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 					END
						END
		-- 				ELSE
		-- 				BEGIN
		-- 					IF EXISTS(SELECT SchId FROM SchemeSlabCombiPrds WHERE SchId=@GetKey AND SlabId=@SlabCode)
		-- 					BEGIN
		-- 						DELETE FROM SchemeSlabCombiPrds WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 						SET @sSQL='DELETE FROM SchemeSlabCombiPrds WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 						' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 		
		-- 						INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,SlabValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		-- 						SELECT @GetKey AS SchId,@SlabCode AS SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,@FromQty AS SlabValue,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121)
		-- 						FROM SchemeProducts WHERE SchId=@GetKey
				
		-- 						SET @sSQL ='INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,
		-- 						PrdBatId,SlabValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		-- 						SELECT ' + CAST(@GetKey AS VARCHAR(10)) + 'AS SchId,'+ CAST(@SlabCode AS VARCHAR(10)) + 'AS SlabId,
		-- 						PrdCtgValMainId,PrdId,PrdBatId' + CAST(@FromQty AS VARCHAR(10)) + 'AS SlabValue,1,1,
		-- 						''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + '''
		-- 						FROM SchemeProducts WHERE SchId=' + CAST(@GetKey AS VARCHAR(10))
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
		-- 					END
		-- 				END
					END
					ELSE IF @RangeId=0
					BEGIN
						DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 				SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 				' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 				INSERT INTO Translog(strSql1) Values (@sSQL)
						SET @TempRange=0
			
						INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
						MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@FromQty),convert(NUMERIC(18,2),@TempRange),@FromUomId,
						0,@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
						convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
						1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
			
		-- 				SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 				ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 				Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 				MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 				CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' + CAST(@TempRange AS VARCHAR(10)) + ',' +
		-- 				CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 				CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 				CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 				CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 				',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 				INSERT INTO Translog(strSql1) Values (@sSQL)
					END
					ELSE IF (@FlexiId=1 AND @CombiSch=1) OR (@FlexiId=1 AND @RangeId=1)
					BEGIN
						---->Modified By Nanda on 23/08/2009
						IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
						BEGIN
							DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
						END
						---->Till Here
		--				SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		--				' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		--				INSERT INTO Translog(strSql1) Values (@sSQL)
						IF @RangeId=1
						BEGIN
							SET @TempRange=0
						END
						ELSE
						BEGIN
							SET @TempRange=@FromQty
						END
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
									INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
									MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@TempRange),convert(NUMERIC(18,2),@FromQty),@FromUomId,
									convert(NUMERIC(18,2),@ToQty),@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
									convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
									1,convert(varchar(10),getdate(),121),convert(INT,@MaxDisc),convert(INT,@MinDisc),convert(INT,@MaxValue),convert(INT,@MinValue),@MaxPoints,@MinPoints)
						
		-- 							SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@TempRange AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''','+
		-- 							CAST(@MaxDisc AS VARCHAR(10))+','+CAST(@MinDisc AS VARCHAR(10))+','+CAST(@MaxValue AS VARCHAR(10))+','+CAST(@MinValue AS VARCHAR(10))+','+
		-- 							CAST(@MaxPoints AS VARCHAR(10))+','+CAST(@MinPoints AS VARCHAR(10))+')'
		-- 			
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
								END
								ELSE
								BEGIN
															DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
		-- 							SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
									VALUES (@GetKey,@SlabCode,0,@FromQty,@FromUomId,
									@ToQty,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
									@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
						
		-- 							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',0,0,0,0,0,0,''N'')'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
--								SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
--								' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
--								INSERT INTO Translog(strSql1) Values (@sSQL)
								INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
								Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
								VALUES (@GetKey,@SlabCode,0,@FromQty,@FromUomId,
								@ToQty,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
								@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
					
		-- 						SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 						MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 						CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 						CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 						CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 						',0,0,0,0,0,0,''N'')'
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
								SET @Po_ErrNo =0
							END
						END
						ELSE
						BEGIN
							INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
							MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,convert(NUMERIC(18,2),@TempRange),convert(NUMERIC(18,2),@FromQty),@FromUomId,
							convert(NUMERIC(18,2),@ToQty),@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
							convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121),convert(INT,@MaxDisc),convert(INT,@MinDisc),convert(INT,@MaxValue),convert(INT,@MinValue),@MaxPoints,@MinPoints)
				
		-- 					SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 					ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 					Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 					MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 					CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(@TempRange AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 					CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 					CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 					',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''','+
		-- 					CAST(@MaxDisc AS VARCHAR(10))+','+CAST(@MinDisc AS VARCHAR(10))+','+CAST(@MaxValue AS VARCHAR(10))+','+CAST(@MinValue AS VARCHAR(10))+','+
		-- 					CAST(@MaxPoints AS VARCHAR(10))+','+CAST(@MinPoints AS VARCHAR(10))+')'
			
							INSERT INTO Translog(strSql1) Values (@sSQL)
						END
					END
					ELSE IF @FlexiId=0 AND @RangeId=1 AND @CombiSch=0
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
									DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 							SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 							' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									
									INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
									MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,0,convert(NUMERIC(18,2),@FromQty),@FromUomId,
									convert(NUMERIC(18,2),@ToQty),@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
									convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
									1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
						
		-- 							SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- -- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- -- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- -- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
								END
								ELSE
								BEGIN
									DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
									SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
									' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
									INSERT INTO Translog(strSql1) Values (@sSQL)
									INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
									ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
									Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
									VALUES (@GetKey,@SlabCode,0,@FromQty,@FromUomId,
									@ToQty,@ToUomId,@ForEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,@FlexiDisc,@FlexiFlat,
									@FlexiFree,@FlexiGift,@FlexiPoints,@Points,0,0,0,0,0,0,'NO')
						
		-- 							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 							MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 							CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 							CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 							CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 							CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 							',0,0,0,0,0,0,''N'')'
		-- 							INSERT INTO Translog(strSql1) Values (@sSQL)
									SET @Po_ErrNo =0
								END
							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=@GetKey AND SlabId=@SlabCode
								SET @sSQL='DELETE FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=' + CAST(@GetKey AS VARCHAR(10)) +
								' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
								INSERT INTO Translog(strSql1) Values (@sSQL)
							
								INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
								ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
								Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,UpLoadFlag)
								VALUES (@GetKey,CAST(@SlabCode AS INT),0,CAST(@FromQty AS INT),CAST(@FromUomId AS INT),
								CAST(@ToQty AS INT),CAST(@ToUomId AS INT),CAST(@ForEveryQty As INT),CAST(@ForEveryUomId AS INT),CAST(@DiscPer AS NUMERIC(38,6)),CAST(@FlatAmt AS NUMERIC(38,6)),CAST(@FlexiDisc AS INT),CAST(@FlexiFlat AS INT),
								CAST(@FlexiFree AS INT),CAST(@FlexiGift AS INT),CAST(@FlexiPoints AS INT),CAST(@Points AS INT),0,0,0,0,0,0,'NO')
		-- 						SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabs_Temp(CmpSchCode,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 						ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 						Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 						MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 						CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 						CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 						CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 						CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 						',0,0,0,0,0,0,''N'')'
		-- 						INSERT INTO Translog(strSql1) Values (@sSQL)
								SET @Po_ErrNo =0
							END
						END
						ELSE
						BEGIN
							DELETE FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=@SlabCode
		-- 					SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10)) +
		-- 					' AND SlabId=' + CAST(@SlabCode AS VARCHAR(10))
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
							
							INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
							ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
							Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
							MaxValue,MinValue,MaxPoints,MinPoints) VALUES (@GetKey,@SlabCode,0,convert(NUMERIC(18,2),@FromQty),@FromUomId,
							convert(NUMERIC(18,2),@ToQty),@ToUomId,convert(NUMERIC(18,2),@ForEveryQty),@ForEveryUomId,convert(NUMERIC(5,2),@DiscPer),convert(NUMERIC(18,2),@FlatAmt),convert(INT,@FlexiDisc),convert(INT,@FlexiFlat),
							convert(INT,@FlexiFree),convert(INT,@FlexiGift),@FlexiPoints,@Points,1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121),0,0,0,0,0,0)
				
		-- 					SET @sSQL ='INSERT INTO SchemeSlabs(SchId,SlabId,PurQty,FromQty,UomId,ToQty,ToUomId,ForEveryQty,
		-- 					ForEveryUomId,DiscPer,FlatAmt,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,
		-- 					Points,Availability,LastModBy,LastModDate,AuthId,AuthDate,MaxDiscount,MinDiscount,
		-- 					MaxValue,MinValue,MaxPoints,MinPoints) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
		-- 					CAST(@SlabCode AS VARCHAR(10)) + ',' + CAST(0 AS VARCHAR(10)) + ',' + CAST(@FromQty AS VARCHAR(10)) + ',' +
		-- 					CAST(@FromUomId AS VARCHAR(10)) + ',' + CAST(@ToQty AS VARCHAR(10)) + ',' + CAST(@ToUomId AS VARCHAR(10)) + ',' +
		-- 					CAST(@ForEveryQty AS VARCHAR(10)) + ',' + CAST(@ForEveryUomId AS VARCHAR(10)) + ',' + CAST(@DiscPer AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlatAmt AS VARCHAR(10)) + ',' + CAST(@FlexiDisc AS VARCHAR(10)) + ',' + CAST(@FlexiFlat AS VARCHAR(10)) + ',' +
		-- 					CAST(@FlexiFree AS VARCHAR(10)) + ',' + CAST(@FlexiGift AS VARCHAR(10)) + ',' + CAST(@FlexiPoints AS VARCHAR(10)) + ',' + CAST(@Points AS VARCHAR(10)) +
		-- 					',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''',0,0,0,0,0,0)'
		-- 					INSERT INTO Translog(strSql1) Values (@sSQL)
						END					
					END
				END
			END
		END
	END
	
	FETCH NEXT FROM Cur_SchemeSlabDt INTO  @SchCode,@SlabCode,@FromUOM,@FromQty,@ToUOM,@ToQty,@ForEveryUOM,
		@ForEveryQty,@DiscPer,@FlatAmt,@Points,@FlexiFree,@FlexiGift,@FlexiDisc,@FlexiFlat,@FlexiPoints,
		@MaxDisc,@MinDisc,@MaxValue,@MinValue,@MaxPoints,@MinPoints
	END
	CLOSE Cur_SchemeSlabDt
	DEALLOCATE Cur_SchemeSlabDt
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-017

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeRulesetting]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeRulesetting]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeRulesetting 0
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/

CREATE       PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeRulesetting]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_BLSchemeRulesetting
* PURPOSE		: To Insert and Update records in the Table Etl_Prk_SchemeRuleSettings_Temp,
				  Etl_Prk_SchemeRtrLevelValidation_Temp
* CREATED		: Nandakumar R.G
* CREATED DATE	: 06/01/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}         {developer}      {brief modification description}
* 09-Apr-2010    Jayakumar N      Change done based on "Rtr Cap" in SchConfig column in table Etl_Prk_SchemeRuleSettings.
				 Based on "Rtr Cap" value updated in respective columns NoOfRtr and RtrCount in SchemeruleSettings table
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist 		AS INT
	DECLARE @Tabname AS     NVARCHAR(100)
	DECLARE @DestTabname AS NVARCHAR(100)
	DECLARE @Fldname AS     NVARCHAR(100)

	DECLARE @CmpSchCode AS NVARCHAR(200)
	DECLARE @SchConfig AS NVARCHAR(200)
	DECLARE @SchRules AS NVARCHAR(200)
	DECLARE @NoofBills AS NVARCHAR(200)
	DECLARE @FromDate AS NVARCHAR(200)
	DECLARE @ToDate AS NVARCHAR(200)
	DECLARE @MarketVisit AS NVARCHAR(200)
	DECLARE @ApplySchBasedOn AS NVARCHAR(200)
	DECLARE @EnableRtrLvl AS NVARCHAR(200)
	DECLARE @AllowSaving AS NVARCHAR(200)
	DECLARE @AllowSelection AS NVARCHAR(200)

	DECLARE @RtrCode AS NVARCHAR(200)
	DECLARE @RtrFromDate AS NVARCHAR(200)
	DECLARE @RtrToDate AS NVARCHAR(200)
	DECLARE @BudgetAllocated AS NVARCHAR(200)
	DECLARE @Status AS NVARCHAR(200)

	DECLARE @SchId AS INT
	DECLARE @SchConfigId AS INT
	DECLARE @SchRulesId AS INT
	DECLARE @ApplySchBasedOnId AS INT
	DECLARE @EnableRtrLvlId AS INT
	DECLARE @AllowSavingId AS INT
	DECLARE @AllowSelectionId AS INT

	DECLARE @RtrId AS INT
	DECLARE @StatusId AS INT

	DECLARE @SchLevelId 	AS INT
	DECLARE @ConFig		AS INT
	DECLARE @GetKey 	AS INT
	DECLARE @GetKeyCode	AS VARCHAR(200)
	DECLARE @CmpId 		AS INT
	DECLARE @SLevel		AS INT
	DECLARE @CmpPrdCtgId	AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @SlNo 		AS INT
	DECLARE @RtrAttrCnt	AS INT
	DECLARE @RtrLvlCnt	AS INT

	DECLARE @SchWithOutPrd AS INT	
	
	SET @DestTabname='SchemeRuleSetting'
	SET @Fldname='SchConfig'
	SET @Tabname = 'Etl_Prk_SchemeRuleSettings_Temp'
	SET @Exist=0
	SET @Po_ErrNo=0

	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'

	DECLARE Cur_SchemeRules CURSOR
	FOR SELECT DISTINCT ISNULL(CmpSchCode,'') AS CmpSchCode,ISNULL(SchConfig,''),ISNULL(SchRules,''),ISNULL(NoofBills,''),ISNULL(SchValidFrom,''),ISNULL(SchValidTill,''),
	ISNULL(MarketVisit,''),ISNULL(ApplySchBasedOn,''),ISNULL(EnableRtrLvl,''),ISNULL(AllowSaving,''),ISNULL(AllowSelection,'')
	FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY CmpSchCode
	OPEN Cur_SchemeRules

	FETCH NEXT FROM Cur_SchemeRules INTO @CmpSchCode,@SchConfig,@SchRules,@NoofBills,
	@FromDate,@ToDate,@MarketVisit,@ApplySchBasedOn,@EnableRtrLvl,@AllowSaving,@AllowSelection
	WHILE @@FETCH_STATUS=0
	BEGIN		

		SET @Po_ErrNo=0

		IF LTRIM(RTRIM(@CmpSchCode))=''
		BEGIN
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',
			'Company Scheme Code should not be empty')
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @SchId=SchId,@SchLevelId=SchLevelId FROM SchemeMaster
			WHERE CmpSchCode=@CmpSchCode
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@SchConfig))='---'
			BEGIN
				CLOSE Cur_SchemeRules
				DEALLOCATE Cur_SchemeRules
				Return
			END
			IF LTRIM(RTRIM(@SchConfig))='YES'
			BEGIN
				SET @SchConfigId=1
			END
			ELSE 
			BEGIN
				SET @SchConfigId=0
			END

		END
		
		IF @SchConfigId=1 AND @Po_ErrNo=0
		BEGIN			
			IF LTRIM(RTRIM(@SchRules))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Rules',
				'Scheme Rules should not be empty for Scheme Code:'+@CmpSchCode)
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				IF LTRIM(RTRIM(@SchRules))='PRODUCT'
				BEGIN
					SET @SchRulesId=0
				END
				ELSE IF LTRIM(RTRIM(@SchRules))='BILL'
				BEGIN
					SET @SchRulesId=1
				END	
				ELSE IF LTRIM(RTRIM(@SchRules))='DATE'
				BEGIN
					SET @SchRulesId=2
				END
				ELSE IF LTRIM(RTRIM(@SchRules))='MARKET'
				BEGIN
					SET @SchRulesId=3
				END			
			END
	
			IF @Po_ErrNo=0
			BEGIN
				IF @SchRulesId=1
				BEGIN
					IF NOT ISNUMERIC(@NoofBills)=1 
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Scheme No Of Bills',
						'Scheme No Of Bills should be greater than zero for Scheme Code:'+@CmpSchCode)
						SET @Po_ErrNo=1
					END
					ELSE IF @NoofBills<=0
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Scheme No Of Bills',
						'Scheme No Of Bills should be greater than zero for Scheme Code:'+@CmpSchCode)
						SET @Po_ErrNo=1
					END	
				END
				ELSE IF @SchRulesId=2
				BEGIN
					IF @Po_ErrNo=0
					BEGIN
						IF ISDATE(@FromDate)=1 AND ISDATE(@ToDate)=1
						BEGIN
							IF DATEDIFF(DD,@FromDate,@ToDate)<0 OR @ToDate< CONVERT(NVARCHAR(10),GETDATE(),121)
							BEGIN
								INSERT INTO Errorlog VALUES (1,@TabName,'Date',
								'From Date should be less than To Date for Scheme Code:'+@CmpSchCode)           	
								SET @Po_ErrNo=1
							END
						END
						ELSE
						BEGIN
							INSERT INTO Errorlog VALUES (1,@TabName,'Date',
							'Either From Date or To Date is wrong for Scheme Code:'+@CmpSchCode)           	
							SET @Po_ErrNo=1
						END
					END	
				END
				IF @SchRulesId=3
				BEGIN
					IF ISNUMERIC(@MarketVisit)=1 
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Market Visits',
						'Scheme Market Visits should be greater than zero for Scheme Code:'+@CmpSchCode)
						SET @Po_ErrNo=1
					END
					ELSE IF @MarketVisit<=0
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Scheme No Of Bills',
						'Scheme Market Visits should be greater than zero for Scheme Code:'+@CmpSchCode)
						SET @Po_ErrNo=1
					END
				END
			END
	
			IF @Po_ErrNo=0
			BEGIN
				IF LTRIM(RTRIM(@ApplySchBasedOn))=''
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Scheme-Apply Based On',
					'Scheme-Apply Based On Rules should not be empty for Scheme Code:'+@CmpSchCode)
					SET @Po_ErrNo=1
				END
				ELSE
				BEGIN
					IF LTRIM(RTRIM(@ApplySchBasedOn))='Company'
					BEGIN
						SET @ApplySchBasedOnId=0
					END
					ELSE IF LTRIM(RTRIM(@ApplySchBasedOn))='Retailer'
					BEGIN
						SET @ApplySchBasedOnId=1
					END	
					ELSE IF LTRIM(RTRIM(@ApplySchBasedOn))='JC'
					BEGIN
						SET @ApplySchBasedOnId=2
					END
				END	
			END
		END
		ELSE
		BEGIN
			SET @SchRulesId=-1
			SET @ApplySchBasedOnId=-1		
			SET @MarketVisit=-1		

			IF UPPER(@SchConfig)<>UPPER('Rtr Cap')
			BEGIN
				SET @NoofBills=-1					
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@EnableRtrLvl))='Yes'
			BEGIN
				SET @EnableRtrLvlId=1					
			END
			ELSE
			BEGIN
				SET @EnableRtrLvlId=0
			END
		END
			
		IF @Po_ErrNo=0
		BEGIN
			IF @EnableRtrLvlId=1
			BEGIN
				IF NOT EXISTS (SELECT * FROM Etl_Prk_Scheme_RetailerLevelValid WHERE CmpSchCode=@CmpSchCode)
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Level Validation',
					'Retailer not found for Scheme Code:'+@CmpSchCode)
					SET @Po_ErrNo =1
				END
				IF LTRIM(RTRIM(@AllowSaving))='Yes'
				BEGIN
					SET @AllowSavingId=1					
				END
				ELSE
				BEGIN
					SET @AllowSavingId=0					
				END

				IF LTRIM(RTRIM(@AllowSelection))='Yes'
				BEGIN
					SET @AllowSelectionId=1					
				END
				ELSE
				BEGIN
					SET @AllowSelectionId=0					
				END

			END
			ELSE
			BEGIN
				SET @AllowSavingId=0
				SET @AllowSelectionId=0
			END
		END
		
		
		---Insert Rule
		IF @ConFig<>1
		BEGIN
			IF NOT EXISTS(SELECT SchId FROM SchemeMaster 
			WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode)))
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',
				'Company Scheme Code not found')
				SET @Exist=0
				SET @Po_ErrNo =1
			END
			ELSE
			BEGIN
				SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode))
				SELECT @CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode))
				SET @Po_ErrNo =0
				IF EXISTS(SELECT * FROM SchemeRuleSettings WHERE SchId=@GetKey)
				BEGIN
					SET @Exist=1
				END
				ELSE
				BEGIN
					SET @Exist=0
				END
			END
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT SchId FROM SchemeMaster 
			WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode)))
			BEGIN
				SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster 
				WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode))

				SELECT @CmpPrdCtgId=SchLevelId FROM SchemeMaster 
				WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode))

				IF EXISTS(SELECT * FROM SchemeRuleSettings WHERE SchId=@GetKey)
				BEGIN
					SET @Exist=1
				END
				ELSE
				BEGIN
					SET @Exist=0
				END
				SET @Po_ErrNo =0
			END
			ELSE IF EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
				CmpSchCode=LTRIM(RTRIM(@CmpSchCode)) AND UpLoadFlag='N')
			BEGIN
				SELECT @GetKeyCode=CmpSchCode,@CmpId=CmpId FROM ETL_Prk_SchemeMaster_Temp WHERE
				CmpSchCode=LTRIM(RTRIM(@CmpSchCode))

				SELECT @CmpPrdCtgId=SchLevelId
				FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode))
				IF EXISTS(SELECT * FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@CmpSchCode)))
				BEGIN
					SET @Exist=1
				END
				ELSE
				BEGIN
					SET @Exist=0
				END
			END	
		END		
		
		IF @ConFig=1
		BEGIN	
			SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
			IF @CmpPrdCtgId<@SLevel
			BEGIN
				SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
				WHERE A.[CmpSchCode]=LTRIM(RTRIM(@CmpSchCode)) --AND UPPER(A.[SchLevel])='NO'
				AND A.SlabId=0 AND A.SlabValue=0

				SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
				WHERE A.[PrdCode] IN (SELECT b.PrdCtgValCode FROM ProductCategoryValue B) AND
				A.[CmpSchCode]=LTRIM(RTRIM(@CmpSchCode)) --AND UPPER(A.[SchLevel])='NO'
				AND A.SlabId=0 AND A.SlabValue=0
			END
			ELSE
			BEGIN
				SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
				WHERE A.[CmpSchCode]=LTRIM(RTRIM(@CmpSchCode)) --AND UPPER(A.[SchLevel])='YES'
				AND A.SlabId=0 AND A.SlabValue=0

				SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
				WHERE A.[PrdCode] IN (SELECT PrdCCode FROM Product)
				AND  A.[CmpSchCode]=LTRIM(RTRIM(@CmpSchCode)) --AND UPPER(A.[SchLevel])='YES'
				AND A.SlabId=0 AND A.SlabValue=0
			END

			IF @EtlCnt=@CmpCnt
			BEGIN	
				SELECT @EtlCnt=COUNT([PrdCode]) FROM Etl_Prk_Scheme_Free_Multi_Products A (NOLOCK)
				WHERE A.[CmpSchCode]=LTRIM(RTRIM(@CmpSchCode))

				SELECT @CmpCnt=COUNT([PrdCode]) FROM Etl_Prk_Scheme_Free_Multi_Products A (NOLOCK)
				INNER JOIN Product B ON A.[PrdCode]=b.PrdCCode
				WHERE A.[CmpSchCode]=LTRIM(RTRIM(@CmpSchCode))

				IF @EtlCnt=@CmpCnt
				BEGIN
					SET @SchWithOutPrd=1
				END
				ELSE
				BEGIN
					SET @SchWithOutPrd=2
				END	
			END
			ELSE
			BEGIN
				SET @SchWithOutPrd=2
			END	
		END
		ELSE
		BEGIN
			SET @SchWithOutPrd=1		
		END
		---		
		IF @Exist=0 AND @SchWithOutPrd=1   
		BEGIN
			INSERT INTO SchemeRuleSettings(SchId,SchConfig,SchRules,NoofBills,
			FromDate,ToDate,MarketVisit,ApplySchBasedOn,EnableRtrLvl,AllowSaving,
			AllowSelection,Availability,LastModBy,LastModDate,AuthId,AuthDate,NoOfRtr,RtrCount)
			VALUES(@GetKey,@SchConfigId,@SchRulesId,
			CASE UPPER(@SchConfig) WHEN UPPER('Rtr Cap') THEN -1 ELSE @NoofBills END ,
			@FromDate,@ToDate,@MarketVisit,@ApplySchBasedOnId,
			CASE UPPER(@SchConfig) WHEN UPPER('Rtr Cap') THEN 1 ELSE @EnableRtrLvlId END,
			@AllowSavingId,@AllowSelectionId,1,1,GETDATE(),1,GETDATE(),
			CASE UPPER(@SchConfig) WHEN UPPER('Rtr Cap') THEN 1 ELSE 0 END,
			CASE UPPER(@SchConfig) WHEN UPPER('Rtr Cap') THEN @NoofBills ELSE 0 END)
		END

		IF @Exist=1 AND @SchWithOutPrd=1
		BEGIN
			UPDATE SchemeRuleSettings SET SchConfig=@SchConfigId,SchRules=@SchRulesId,
			NoofBills=@NoofBills,FromDate=@FromDate,ToDate=@ToDate,MarketVisit=@MarketVisit,
			ApplySchBasedOn=@ApplySchBasedOnId,EnableRtrLvl=@EnableRtrLvlId,AllowSaving=@AllowSavingId
			WHERE SchId=@GetKey			
		END
		IF @Exist=0 AND @SchWithOutPrd=2
		BEGIN
			INSERT INTO Etl_Prk_SchemeRuleSettings_Temp(CmpSchCode,SchConfig,SchRules,NoofBills,
			FromDate,ToDate,MarketVisit,ApplySchBasedOn,EnableRtrLvl,AllowSaving,AllowSelection)
			VALUES(@CmpSchCode,@SchConfigId,@SchRulesId,@NoofBills,@FromDate,@ToDate,
			@MarketVisit,@ApplySchBasedOnId,@EnableRtrLvlId,@AllowSavingId,
			@AllowSelectionId)
		END
		IF @Exist=1 AND @SchWithOutPrd=2
		BEGIN
			UPDATE Etl_Prk_SchemeRuleSettings_Temp SET SchConfig=@SchConfigId,
			SchRules=@SchRulesId,NoofBills=@NoofBills,FromDate=@FromDate,ToDate=@ToDate,
			MarketVisit=@MarketVisit,ApplySchBasedOn=@ApplySchBasedOnId,
			EnableRtrLvl=@EnableRtrLvlId,AllowSaving=@AllowSavingId
			WHERE CmpSchCode=@CmpSchCode			
		END

		IF @EnableRtrLvlId=1 AND @Po_ErrNo=0
		BEGIN
			DECLARE Cur_SchemeRulesRetailer CURSOR
			FOR SELECT ISNULL(RtrCode,''),ISNULL(FromDate,''),ISNULL(ToDate,''),
			ISNULL(BudgetAllocated,''),ISNULL(Status,'')
			FROM Etl_Prk_Scheme_RetailerLevelValid WHERE CmpSchCode=@CmpSchCode
	
			OPEN Cur_SchemeRulesRetailer
		
			FETCH NEXT FROM Cur_SchemeRulesRetailer INTO @RtrCode,@RtrFromDate,@RtrToDate,
			@BudgetAllocated,@Status
			WHILE @@FETCH_STATUS=0
			BEGIN
				IF LTRIM(RTRIM(@RtrCode))=''
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Code',
					'Retailer Code should not be empty for Scheme Code:'+@CmpSchCode)
					SET @Po_ErrNo=1
				END

				IF @Po_ErrNo=0
				BEGIN
					IF NOT EXISTS(SELECT * FROM Retailer WITH (NOLOCK)
					WHERE RtrCode=@RtrCode)
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Retailer',
						'Retailer : '+@RtrCode+' is not available for Scheme Code:'+@CmpSchCode)           	
						SET @Po_ErrNo=1
					END
					ELSE
					BEGIN
						SELECT @RtrId=RtrId FROM Retailer WITH (NOLOCK)
						WHERE RtrCode=@RtrCode
					END
				END		
				IF @Po_ErrNo=0
				BEGIN
					IF EXISTS(SELECT * FROM Etl_Prk_Scheme_OnAttributes WHERE 
						CmpSchCode=@CmpSchCode AND AttrType='RETAILER' AND AttrName<> 'ALL')
					BEGIN
						IF NOT EXISTS(SELECT * FROM Etl_Prk_Scheme_OnAttributes WHERE 
						CmpSchCode=@CmpSchCode AND AttrType='RETAILER' AND AttrName=@RtrCode)
						BEGIN
							INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Level Validation',
							'Retailer Mismatch for Scheme Code:'+@CmpSchCode)
							SET @Po_ErrNo =1
						END	
					END
				END
				IF @Po_ErrNo=0
				BEGIN
					IF ISDATE(@RtrFromDate)=1 AND ISDATE(@RtrToDate)=1
					BEGIN
						IF DATEDIFF(DD,@RtrFromDate,@RtrToDate)<0 OR @RtrToDate< CONVERT(NVARCHAR(10),GETDATE(),121)
						BEGIN
							INSERT INTO Errorlog VALUES (1,@TabName,'Date',
							'From Date should be less than To Date for Scheme Code:'+@CmpSchCode)           	
							SET @Po_ErrNo=1
						END
					END
					ELSE
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Date',
						'Either From Date or To Date is wrong for Scheme Code:'+@CmpSchCode)           	
						SET @Po_ErrNo=1
					END
				END
				
				IF @Po_ErrNo=0
				BEGIN
					IF (DATEDIFF(DD,@FromDate,@RtrFromDate)<0 OR DATEDIFF(DD,@RtrFromDate,@ToDate)<0)
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Date',
						'Retailer From Date should be within From and To Date for Scheme Code:'+@CmpSchCode)           	
						SET @Po_ErrNo=1
					END
					
					IF (DATEDIFF(DD,@FromDate,@RtrToDate)<0 OR DATEDIFF(DD,@RtrToDate,@ToDate)<0)
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Date',
						'Retailer To Date should be within From and To Date for Scheme Code:'+@CmpSchCode)           	
						SET @Po_ErrNo=1
					END
				END
				
				IF @Po_ErrNo=0
				BEGIN
					IF NOT ISNUMERIC(@BudgetAllocated)=1 
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Budget Allocated',
						'Budget Allocated should be numeric value for Scheme Code:'+@CmpSchCode)           	
						SET @Po_ErrNo=1
					END
					ELSE IF @BudgetAllocated<=0
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Scheme No Of Bills',
						'Budget Allocated should be greater than zero for Scheme Code:'+@CmpSchCode)
						SET @Po_ErrNo=1
					END
				END

				IF @Po_ErrNo=0
				BEGIN				
					IF LTRIM(RTRIM(@Status))=''
					BEGIN
						INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Status',
						'Retailer Status should not be empty for Scheme Code:'+@CmpSchCode)
						SET @Po_ErrNo=1
					END
					ELSE
					BEGIN
						IF LTRIM(RTRIM(@Status))='Active'
						BEGIN
							SET @StatusId=1					
						END
						ELSE
						BEGIN
							SET @StatusId=0					
						END
					END
				END	

				IF @Exist=0 AND @SchWithOutPrd=1
				BEGIN
					INSERT INTO SchemeRtrLevelValidation(SchId,RtrId,FromDate,ToDate,
					BudgetAllocated,BudgetUtilized,BudgetAvailable,Status,Slno,
					Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@GetKey,@RtrId,@RtrFromDate,@RtrToDate,
					@BudgetAllocated,0,0,@StatusId,@SlNo,1,1,GETDATE(),1,GETDATE())
				
				END
				IF @Exist=1 AND @SchWithOutPrd=1
				BEGIN
					UPDATE SchemeRtrLevelValidation SET FromDate=@FromDate,ToDate=@ToDate,
					BudgetAllocated=@BudgetAllocated,BudgetAvailable=@BudgetAllocated-BudgetUtilized,
					Status=@StatusId
					WHERE SchId=@GetKey AND RtrId=@RtrId			 
				END
				IF @Exist=0 AND @SchWithOutPrd=2
				BEGIN
					INSERT INTO Etl_Prk_SchemeRtrLevelValidation_Temp(CmpSchCode,RtrId,
					RtrCode,FromDate,ToDate,BudgetAllocated,BudgetUtilized,BudgetAvailable,
					Status,Slno)
					VALUES(@CmpSchCode,@RtrId,@RtrCode,@RtrFromDate,@RtrToDate,@BudgetAllocated,
					0,0,@Status,@Slno)
				END
				IF @Exist=1 AND @SchWithOutPrd=2
				BEGIN
					UPDATE Etl_Prk_SchemeRtrLevelValidation_Temp SET FromDate=@FromDate,
					ToDate=@ToDate,BudgetAllocated=@BudgetAllocated,Status=@Status
					WHERE CmpSchCode=@CmpSchCode AND RtrCode=@RtrCode			
				END

				FETCH NEXT FROM Cur_SchemeRulesRetailer INTO @RtrCode,@RtrFromDate,@RtrToDate,@BudgetAllocated,@Status
			END
			CLOSE Cur_SchemeRulesRetailer
			DEALLOCATE Cur_SchemeRulesRetailer
		END				
		FETCH NEXT FROM Cur_SchemeRules INTO @CmpSchCode,@SchConfig,@SchRules,@NoofBills,@FromDate,@ToDate,
		@MarketVisit,@ApplySchBasedOn,@EnableRtrLvl,@AllowSaving,@AllowSelection
	END

	CLOSE Cur_SchemeRules
	DEALLOCATE Cur_SchemeRules
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-018

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeFreeProducts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeFreeProducts]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
DELETE FROM SchemeSlabMultiFrePrds
EXEC Proc_Cn2Cs_BLSchemeFreeProducts 0
SELECT * FROM ErrorLog
SELECT * FROM SchemeSlabMultiFrePrds
ROLLBACK TRANSACTION
*/

CREATE     PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeFreeProducts]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeFreeProducts    1
* PURPOSE: To Insert and Update Scheme Slab Free/Gift Products
* CREATED: Boopathy.P on 05/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode AS VARCHAR(50)
	DECLARE @SlabCode AS VARCHAR(50)
	DECLARE @Condition AS VARCHAR(50)
	DECLARE @PrdCode AS VARCHAR(150)
	DECLARE @Qty  AS INT
	DECLARE @TypeCode AS VARCHAR(50)
	DECLARE @PrdId  AS VARCHAR(50)
	DECLARE @CondId  AS INT
	DECLARE @TypeId  AS INT
	DECLARE @CmpId  AS INT
	DECLARE @SlabId  AS INT
	DECLARE @SchLevelId AS INT
	DECLARE @EtlCnt AS INT
	DECLARE @CmpCnt AS INT
	DECLARE @SchType AS INT
	DECLARE @SLevel AS INT
	DECLARE @FlexiId AS INT
	DECLARE @SeqId	AS INT
	DECLARE @RangeId AS INT
	DECLARE @FlexiType AS INT
	DECLARE @CombiSch AS INT
	DECLARE @PrevSlabId AS INT
	DECLARE @ChkCount AS INT
	DECLARE @ErrDesc  AS VARCHAR(1000)
	DECLARE @TabName  AS VARCHAR(50)
	DECLARE @GetKey  AS NVARCHAR(200)
	DECLARE @GetKeyCode	AS	NVARCHAR(200)
	DECLARE @PrvSchCode	AS	NVARCHAR(200)
	DECLARE @Taction  AS INT
	DECLARE @Cnt  AS INT
	DECLARE @TypeCnt AS INT
	DECLARE @ConFig   	AS INT
	DECLARE @sSQL   AS VARCHAR(4000)
	SET @TabName = 'Etl_Prk_Scheme_Free_Multi_Products'
	SET @Po_ErrNo =0
	SET @PrevSlabId=0
	SET @Cnt=0

	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'

	SET @PrvSchCode=''

	DECLARE Cur_SchemeSlabFreePrds CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],
	ISNULL([SlabId],'0') AS [SlabId],
	ISNULL([OpnANDOR],'') AS [Condition],
	ISNULL([PrdCode],'') AS [Product Code],
	ISNULL([FreeQty],0) AS [Qty],
	ISNULL([Type],'') AS [Type]	
	FROM Etl_Prk_Scheme_Free_Multi_Products 
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code],[SlabId]

	OPEN Cur_SchemeSlabFreePrds
	FETCH NEXT FROM Cur_SchemeSlabFreePrds INTO @SchCode,@SlabCode,@Condition,@PrdCode,@Qty,@TypeCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo =0

		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SlabCode))= ''
		BEGIN
			SET @ErrDesc = 'Slab Details should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Slab Details',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@Condition))= ''
		BEGIN
			SET @ErrDesc = 'Condition should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Condition',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@PrdCode))= ''
		BEGIN
			SET @ErrDesc = 'Product Code should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF UPPER(LTRIM(RTRIM(@Condition)))<> 'OR' AND UPPER(LTRIM(RTRIM(@Condition)))<> 'AND'
		AND UPPER(LTRIM(RTRIM(@Condition)))<> '0'
		BEGIN
			SET @ErrDesc = 'Condition should be (OR/AND/0) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Condition',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF UPPER(LTRIM(RTRIM(@Condition)))= 'OR'
		BEGIN
			SET @CondId=1
		END
		ELSE IF UPPER(LTRIM(RTRIM(@Condition)))= 'AND'
		BEGIN
			SET @CondId=2
		END
		ELSE
		BEGIN
			SET @CondId=3
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
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,@SchType=SchType,
					@RangeId=Range,@CombiSch=CombiSch FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SET @Po_ErrNo =0
				END
	
				IF NOT EXISTS(SELECT PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode)))
				BEGIN
					SET @ErrDesc = 'Product Code:'+@PrdCode+' not found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode))
				END
				IF NOT EXISTS(SELECT SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
				BEGIN
					SET @ErrDesc = 'Slab Details not found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (1,@TabName,'Slab Details',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @SlabId=SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND
					SlabId=LTRIM(RTRIM(@SlabCode))
				END
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,@SchType=SchType,
					@RangeId=Range,@CombiSch=CombiSch FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SET @Po_ErrNo =0
				END
				ELSE IF EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
				BEGIN
					SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM ETL_Prk_SchemeMaster_Temp WHERE
					CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId,@FlexiId=FlexiSch,@FlexiType=FlexiSchType,@SchType=SchType,
					@RangeId=Range,@CombiSch=CombiSch FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END	
				ELSE
				BEGIN
					SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
					B.CmpCode=A.[CmpCode] WHERE [CmpSchCode]=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=C.CmpPrdCtgId,@CombiSch=A.CombiSch
					FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
					INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
					AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
				END
				IF EXISTS(SELECT * FROM Etl_Prk_SchemeSlabs_Temp
					WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N' AND SlabId=CAST(LTRIM(RTRIM(@SlabCode)) AS INT))
				BEGIN
					SELECT @SlabId=SlabId FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND
					UpLoadFlag='N' AND SlabId=CAST(LTRIM(RTRIM(@SlabCode)) AS INT)
				END
				ELSE IF ISNUMERIC(@GetKey)>0
				BEGIN
					IF EXISTS(SELECT SlabId FROM SchemeSlabs WHERE SchId=CAST(@GetKey AS INT) AND SlabId=CAST(LTRIM(RTRIM(@SlabCode)) AS INT))
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs WHERE SchId=CAST(@GetKey AS INT) AND
						SlabId=CAST(LTRIM(RTRIM(@SlabCode)) AS INT)
					END
				END
				IF EXISTS(SELECT PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode)))
				BEGIN
					SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode))
				END
				ELSE
				BEGIN
					SET @PrdId=LTRIM(RTRIM(@PrdCode))
				END
			END

			--->Modified By Nanda on 08/09/2010
--			SELECT @PrvSchCode,@SchCode
--			IF LTRIM(RTRIM(@PrvSchCode))=''
--			BEGIN
--				--SET @PrvSchCode=@SchCode
--				SET @SeqId=1
--			END
--			ELSE IF LTRIM(RTRIM(@PrvSchCode))=LTRIM(RTRIM(@SchCode))
--			BEGIN
--				SET @SeqId = @SeqId +1				
--			END
--			ELSE
--			BEGIN
--				SET @SeqId=1				
--			END			

			IF LTRIM(RTRIM(@PrvSchCode))=''
			BEGIN
				IF @PrevSlabId=0 
				BEGIN
					SET @PrvSchCode=LTRIM(RTRIM(@SchCode))
					SET @PrevSlabId=@SlabId
					SET @SeqId=1
				END
				ELSE IF @PrevSlabId=@SlabId
				BEGIN
					SET @PrvSchCode=LTRIM(RTRIM(@SchCode))
					SET @PrevSlabId=@SlabId
					SET @SeqId=1
				END	
			END
			ELSE IF  LTRIM(RTRIM(@PrvSchCode))=LTRIM(RTRIM(@SchCode))
			BEGIN
				IF @PrevSlabId=0 
				BEGIN
					SET @PrvSchCode=LTRIM(RTRIM(@SchCode))
					SET @PrevSlabId=@SlabId
					SET @SeqId=1
				END
				ELSE IF @PrevSlabId=@SlabId
				BEGIN
					SET @PrvSchCode=LTRIM(RTRIM(@SchCode))
					SET @PrevSlabId=@SlabId
					SET @SeqId = @SeqId + 1
				END
				ELSE
				BEGIN
					SET @SeqId = 1
				END
			END
			ELSE
			BEGIN
				SET @SeqId =1
			END
			--->Till Here

			IF @SchType <> 4
			BEGIN
				IF @FlexiId=1
				BEGIN 	
					 IF LTRIM(RTRIM(@TypeCode))=''
					 BEGIN
						 SET @ErrDesc = 'Free/Gift Should not be blank for Scheme Code:'+@SchCode
						 INSERT INTO Errorlog VALUES (1,@TabName,'Free/Gift',@ErrDesc)
						 SET @Taction = 0
						 SET @Po_ErrNo =1
					 END
					 ELSE IF UPPER(LTRIM(RTRIM(@TypeCode)))<>'FREE' AND UPPER(LTRIM(RTRIM(@TypeCode)))<>'GIFT'
					 BEGIN
						 SET @ErrDesc = 'Product Type Should Be FREE/GIFT for Scheme Code:'+@SchCode
						 INSERT INTO Errorlog VALUES (1,@TabName,'Product Type',@ErrDesc)
						 SET @Taction = 0
						 SET @Po_ErrNo =1
					 END
					 IF UPPER(LTRIM(RTRIM(@TypeCode)))='FREE'
					 BEGIN
						SET @TypeId=1
					 END
					 ELSE IF UPPER(LTRIM(RTRIM(@TypeCode)))='GIFT'
					 BEGIN
						SET @TypeId=2
					 END
		
-- 					 EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
-- 					 SELECT @ChkCount=COUNT(*) FROM TempDepCheck
-- 					 IF @ChkCount > 0
-- 					 BEGIN
					 	SET @Taction=0
		
						SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
						IF @SchLevelId<@SLevel
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
							AND  A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) ---AND UPPER(A.[SchLevel])='YES'
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
								DELETE FROM  SchemeSlabMultiFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
								AND PrdId=@PrdId AND Type=@TypeId
								
								INSERT INTO SchemeSlabMultiFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,SeqId,Availability,
								LastModBy,LastModDate,AuthId,AuthDate,Type) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,@SeqId,
								1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),@TypeId)
							END
							ELSE
							BEGIN
								DELETE FROM Etl_Prk_SchemeSlabMultiFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N'
								
								INSERT INTO Etl_Prk_SchemeSlabMultiFrePrds_Temp(CmpSchCode,SlabId,PrdId,PrdCode,
								FreeQty,OpnANDOR,SeqId,Type,UpLoadFlag) VALUES (@GetKey,@SlabId,@SeqId,LTRIM(RTRIM(@PrdCode)),
								@Qty,@CondId,0,@TypeId,'N')
							END
						END
						ELSE
						BEGIN
-- 							DELETE FROM  SchemeSlabMultiFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 							AND PrdId=@PrdId AND Type=@TypeId
							
							INSERT INTO SchemeSlabMultiFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,SeqId,Availability,
							LastModBy,LastModDate,AuthId,AuthDate,Type) VALUES(@GetKey,ISNULL(@SlabId,1),@PrdId,@Qty,@CondId,@SeqId,
							1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),@TypeId)
						END
-- 					END
				END
				ELSE
				BEGIN
					IF CONVERT(INT,LTRIM(RTRIM(@Qty)))= 0
					BEGIN
						SET @ErrDesc = 'Quantity should be > 0 for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Quantity',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					IF (@SlabId)=LTRIM(RTRIM(@SlabCode))
					BEGIN
						 IF LTRIM(RTRIM(@TypeCode))=''
						 BEGIN
							 SET @ErrDesc = 'Free/Gift Should not be blank for Scheme Code:'+@SchCode
							 INSERT INTO Errorlog VALUES (1,@TabName,'Free/Gift',@ErrDesc)
							 SET @Taction = 0
							 SET @Po_ErrNo =1
						 END
						 ELSE IF UPPER(LTRIM(RTRIM(@TypeCode)))<>'FREE' AND UPPER(LTRIM(RTRIM(@TypeCode)))<>'GIFT'
						 BEGIN
							 SET @ErrDesc = 'Product Type Should Be FREE/GIFT for Scheme Code:'+@SchCode
							 INSERT INTO Errorlog VALUES (1,@TabName,'Product Type',@ErrDesc)
							 SET @Taction = 0
							 SET @Po_ErrNo =1
						 END
	
						 IF UPPER(LTRIM(RTRIM(@TypeCode)))='FREE'
						 BEGIN
							SET @TypeId=1
						 END
						 ELSE IF UPPER(LTRIM(RTRIM(@TypeCode)))='GIFT'
						 BEGIN
							SET @TypeId=2
						 END
						SELECT @TypeCnt=ISNULL(COUNT(LTRIM(RTRIM([PrdCode]))),0) FROM Etl_Prk_Scheme_Free_Multi_Products
						WHERE [CmpSchCode]=LTRIM(RTRIM(@SchCode)) AND [SlabId]=LTRIM(RTRIM(@SlabCode))
						AND [Type]=LTRIM(RTRIM(@TypeCode))
						SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
			
						IF @SchLevelId<@SLevel
						BEGIN
							SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
							WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[SchLevel])='NO'
							AND A.SlabId=0 AND A.SlabValue=0
		
							SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
							WHERE A.[PrdCode] IN (SELECT b.PrdCtgValCode FROM ProductCategoryValue B) AND
							A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[SchLevel])='NO'
							AND A.SlabId=0 AND A.SlabValue=0
						END
						ELSE
						BEGIN
							SELECT @EtlCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
							WHERE A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[SchLevel])='YES'
							AND A.SlabId=0 AND A.SlabValue=0
	
							SELECT @CmpCnt=ISNULL(COUNT([PrdCode]),0) FROM Etl_Prk_SchemeProducts_Combi A
							WHERE A.[PrdCode] IN (SELECT PrdCCode FROM Product)
							AND  A.[CmpSchCode]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[SchLevel])='YES'
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
								IF @TypeCnt <> 0 AND @SeqId<=1
								BEGIN
-- 									DELETE FROM SchemeSlabFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 									AND  PrdId=@PrdId
									INSERT INTO SchemeSlabFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,Availability,
									LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,
									1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
								END
								ELSE IF @TypeCnt <> 0 AND @TypeCnt>1
								BEGIN
									IF @CondId=1
									BEGIN
-- 										DELETE FROM  SchemeSlabMultiFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 										AND PrdId=@PrdId AND Type=@TypeId
			
										INSERT INTO SchemeSlabMultiFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,SeqId,Availability,
										LastModBy,LastModDate,AuthId,AuthDate,Type) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,@SeqId,
										1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),@TypeId)
									END
									ELSE IF @CondId=2
									BEGIN
-- 										DELETE FROM SchemeSlabFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 										AND  PrdId=@PrdId
			
										INSERT INTO SchemeSlabFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,Availability,
										LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,
										1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
									END
								END
							END
							ELSE
							BEGIN
								IF @TypeCnt <> 0 AND @SeqId=1
								BEGIN
									DELETE FROM Etl_Prk_SchemeSlabFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
									AND UpLoadFlag='N' AND SlabId=@SlabId AND  PrdCode=LTRIM(RTRIM(@PrdCode))
									INSERT INTO Etl_Prk_SchemeSlabFrePrds_Temp(CmpSchCode,SlabId,PrdId,PrdCode,FreeQty,OpnANDOR,UpLoadFlag)
										VALUES(@GetKey,@SlabId,@PrdId,LTRIM(RTRIM(@PrdCode)),@Qty,@CondId,'N')
								END
								ELSE IF @TypeCnt <> 0 AND @TypeCnt>1
								BEGIN
									IF @CondId=1
									BEGIN
										DELETE FROM Etl_Prk_SchemeSlabMultiFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N'
										
										INSERT INTO Etl_Prk_SchemeSlabMultiFrePrds_Temp(CmpSchCode,SlabId,PrdId,PrdCode,
										FreeQty,OpnANDOR,SeqId,Type,UpLoadFlag) VALUES (@GetKey,@SlabId,0,LTRIM(RTRIM(@PrdCode)),
										@Qty,@CondId,@SeqId,@TypeId,'N')
									END
									ELSE IF @CondId=2
									BEGIN
										DELETE FROM Etl_Prk_SchemeSlabFrePrds_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
										AND UpLoadFlag='N' AND SlabId=@SlabId AND  PrdCode=LTRIM(RTRIM(@PrdCode))
										INSERT INTO Etl_Prk_SchemeSlabFrePrds_Temp(CmpSchCode,SlabId,PrdId,PrdCode,FreeQty,OpnANDOR,UpLoadFlag)
											VALUES(@GetKey,@SlabId,@PrdId,LTRIM(RTRIM(@PrdCode)),@Qty,@CondId,'N')
									END
								END
							END
						END
						ELSE
						BEGIN
							IF @TypeCnt <> 0 AND @SeqId=1
							BEGIN
-- 								DELETE FROM SchemeSlabFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 								AND  PrdId=@PrdId
								INSERT INTO SchemeSlabFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,Availability,
								LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,
								1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
							END
							ELSE IF @TypeCnt <> 0 AND @TypeCnt>1
							BEGIN
								IF @CondId=1
								BEGIN
-- 									DELETE FROM  SchemeSlabMultiFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 									AND PrdId=@PrdId AND Type=@TypeId
		
									INSERT INTO SchemeSlabMultiFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,SeqId,Availability,
									LastModBy,LastModDate,AuthId,AuthDate,Type) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,@SeqId,
									1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121),@TypeId)
								END
								ELSE IF @CondId=2
								BEGIN
-- 									DELETE FROM SchemeSlabFrePrds WHERE SchId=@GetKey AND SlabId=@SlabId
-- 									AND  PrdId=@PrdId
		
									INSERT INTO SchemeSlabFrePrds(SchId,SlabId,PrdId,FreeQty,OpnANDOR,Availability,
									LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,@PrdId,@Qty,@CondId,
									1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
								END
							END
						END
					END
				END
			END
		END	
		SET @PrevSlabId=@SlabId
		SET @PrvSchCode=@SchCode
		FETCH NEXT FROM Cur_SchemeSlabFreePrds INTO  @SchCode,@SlabCode,@Condition,@PrdCode,@Qty,@TypeCode
	END
	CLOSE Cur_SchemeSlabFreePrds
	DEALLOCATE Cur_SchemeSlabFreePrds
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-019

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeCombiPrd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeCombiPrd]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeCombiPrd 0
SELECT * FROM ErrorLog
SELECT * FROM SchemeSlabCombiPrds
ROLLBACK TRANSACTION
*/
CREATE        PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeCombiPrd]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeCombiPrd
* PURPOSE: To Insert and Update Scheme Combi Products
* CREATED: Boopathy.P on 03/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode	AS VARCHAR(200)
	DECLARE @SlabId		AS Varchar(200)
	DECLARE @Value		AS VARCHAR(50)
	DECLARE @PrdCode	AS VARCHAR(200)
	DECLARE @PrdBatCode	AS VARCHAR(200)
	DECLARE @SlabCode	AS VARCHAR(200)
	DECLARE @GetKeyCode	AS VARCHAR(200)
	DECLARE @PrdBatOpt	AS INT
	DECLARE @CombiSchId	AS INT
	DECLARE @BatchLvl	AS INT
	DECLARE @CmpId		AS INT
	DECLARE @PrdId		AS VARCHAR(200)
	DECLARE @PrdBatId	AS VARCHAR(200)	
	DECLARE @SchLevelId	AS INT
	DECLARE @PrdCtgId	AS INT
	DECLARE @CombiSch	AS INT
	DECLARE @ChkCount	AS INT
	DECLARE @ErrDesc 	AS VARCHAR(1000)
	DECLARE @TabName 	AS VARCHAR(50)
	DECLARE @GetKey 	AS INT
	DECLARE @Taction 	AS INT
	DECLARE @ConFig		AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @sSQL 		AS VARCHAR(4000)
	DECLARE @MaxSchLevelId	AS	INT
	DECLARE @SLevel		AS	INT
	DECLARE @CmpPrdCtgId	AS	INT
	DECLARE @SchLevelMode	AS	NVARCHAR(200)

	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'

	SET @TabName = 'Etl_Prk_SchemeProducts_Combi'
	SET @Po_ErrNo =0
	DECLARE Cur_SchemeCombiPrds CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],ISNULL(SlabId,'') AS [SlabId],
	ISNULL([PrdCode],'') AS [Code],ISNULL([PrdBatCode],'') AS [Batch Code],
	ISNULL([SlabValue],'') AS [Value] FROM Etl_Prk_SchemeProducts_Combi
	WHERE SlabValue > 0
	AND CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code],[SlabId]
	OPEN Cur_SchemeCombiPrds
	FETCH NEXT FROM Cur_SchemeCombiPrds INTO @SchCode,@SlabId,@PrdCode,@PrdBatCode,@Value
	WHILE @@FETCH_STATUS=0
	BEGIN

		SET @Po_ErrNo =0

		SET @Taction = 2
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END

		IF EXISTS (SELECT * FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
		BEGIN
			SELECT @SchLevelId=SchLevelId,@CombiSchId=CombiSch, 
			@BatchLvl=BatchLevel FROM SchemeMaster
			WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
		END
		ELSE IF EXISTS (SELECT * FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
		BEGIN
			SELECT @SchLevelId=SchLevelId,@CombiSchId=CombiSch,@BatchLvl=BatchLevel
			FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
		END

		IF @CombiSchId=1
		BEGIN
			IF LTRIM(RTRIM(@SlabId))= ''
			BEGIN
				SET @ErrDesc = 'Slab should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Slab',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LTRIM(RTRIM(@PrdCode))= ''
			BEGIN
				SET @ErrDesc = 'Product Code should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LTRIM(RTRIM(@Value))= ''
			BEGIN
				SET @ErrDesc = 'Slab Value should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Slab Value',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LTRIM(RTRIM(@SchLevelMode))=''
			BEGIN
				SET @ErrDesc = 'Scheme Level should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
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
						SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SET @Po_ErrNo =0
					END
		
					IF NOT EXISTS(SELECT PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode)))
					BEGIN
						SET @ErrDesc = 'Product Code:'+@PrdCode+ ' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode))
					END
					IF NOT EXISTS(SELECT SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SET @ErrDesc = 'Slab Details not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Slab Details',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND
						SlabId=LTRIM(RTRIM(@SlabCode))
					END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
					BEGIN
						SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SELECT @SchLevelId=SchLevelId,@CmpPrdCtgId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
						SET @Po_ErrNo =0
					END
					ELSE IF EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
							CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
					BEGIN
						SELECT @GetKeyCode=CmpSchCode,@CmpId=CmpId FROM ETL_Prk_SchemeMaster_Temp WHERE
						CmpSchCode=LTRIM(RTRIM(@SchCode))

						SELECT @SchLevelId=SchLevelId,@CombiSch=CombiSch,@CmpPrdCtgId=SchLevelId 
						FROM ETL_Prk_SchemeMaster_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					END	
					ELSE
					BEGIN
						SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
						B.CmpCode=A.[CmpCode] WHERE [CmpSchCode]=LTRIM(RTRIM(@SchCode))

						SELECT @SchLevelId=C.CmpPrdCtgId,@CombiSch=A.CombiSch
						FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
						INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
						AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
					END

					IF EXISTS(SELECT SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs WHERE SchId=@GetKey AND
						SlabId=LTRIM(RTRIM(@SlabCode))
					END
					ELSE IF EXISTS(SELECT SlabId FROM Etl_Prk_SchemeSlabs_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N' AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM Etl_Prk_SchemeSlabs_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND
						UpLoadFlag='N' AND SlabId=LTRIM(RTRIM(@SlabCode))
					END
				
				END
				SELECT @MaxSchLevelId=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				IF @MaxSchLevelId=@SchLevelId
				BEGIN
					IF @BatchLvl=1
					BEGIN
						IF LTRIM(RTRIM(@PrdBatCode))= ''
						BEGIN
							SET @ErrDesc = 'Batch Code should not be blank for Product Code:'+@PrdCode+ 'of Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'Batch Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
						
						IF NOT EXISTS(SELECT PrdId FROM Product WHERE CmpId=@CmpId
							AND PrdCCode=LTRIM(RTRIM(@PrdCode)))
						BEGIN
							SET @ErrDesc = 'Product Code:'+@PrdCode +' Not Found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (11,@TabName,'Product Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @PrdId=PrdId FROM Product WHERE CmpId=@CmpId
							AND PrdCCode=LTRIM(RTRIM(@PrdCode))
							SET @PrdCtgId=0
							IF @BatchLvl=1
							BEGIN
								IF NOT EXISTS(SELECT PrdBatId FROM ProductBatch WHERE PrdId=@PrdId)
								BEGIN
		
									SET @ErrDesc = 'No Batch Code Found for Product Code:'+@PrdCode+ ' in Scheme Code:'+@SchCode
									INSERT INTO Errorlog VALUES (11,@TabName,'Batch Code',@ErrDesc)
									SET @Taction = 0
									SET @Po_ErrNo =1
								END
								ELSE
								BEGIN
									SELECT @PrdBatId=PrdBatId FROM ProductBatch WHERE PrdId=@PrdId
								END
							END
							ELSE
							BEGIN
-- 								SELECT @PrdBatId=PrdBatId FROM ProductBatch WHERE PrdId=@PrdId
								SET @PrdBatId=0
							END
						END
-- 					END
				END
				ELSE
				BEGIN
					--->Modified By Nanda on 24/08/2009
					IF NOT EXISTS(SELECT A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
						ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
						AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId)
					BEGIN
						SET @ErrDesc = 'Product Category Level Not Found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (11,@TabName,'Product Category',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @PrdCtgId=A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
						ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
						AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SchLevelId
						SET @PrdId=0
						SET @PrdBatId=0
					END
					--Till Here
				END
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
			SELECT @ChkCount=COUNT(*) FROM TempDepCheck
			IF @ChkCount > 0
			BEGIN				
				SET @Taction = 0
			END
			ELSE
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

							DELETE FROM SchemeSlabCombiPrds WHERE SlabId=@SlabId AND SchId=@GetKey 
							AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND PrdCtgValMainId=@PrdCtgId
							
							SET @sSQL ='DELETE FROM SchemeSlabCombiPrds WHERE SlabId=' + CAST(@SlabId AS VARCHAR(200)) +
								   ' AND SchId=' + CAST(@GetKey AS VARCHAR(200))
			
							INSERT INTO Translog(strSql1) Values (@sSQL)
			
							INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,
								    Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,
								    @PrdCtgId,@PrdId,@PrdBatId,@Value,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
				
							SET @sSQL ='INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,
								    Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES('+ CAST(@GetKey AS VARCHAR(200)) + ',' + ',' + CAST(@SlabId AS VARCHAR(200)) + ',' +
								   CAST(@PrdCtgId AS VARCHAR(200)) + ',' + CAST(@PrdId AS VARCHAR(200)) + ',' + CAST(@PrdBatId AS VARCHAR(200)) + ',' + CAST(@Value AS VARCHAR(200)) +
								   ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
							INSERT INTO Translog(strSql1) Values (@sSQL)
						END
						ELSE
						BEGIN
							DELETE FROM Etl_Prk_SchemeSlabCombiPrds_Temp WHERE SlabId=@SlabId AND CmpSchCode=@GetKey
							AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND UpLoadFlag='N'
							
							SET @sSQL ='DELETE FROM Etl_Prk_SchemeSlabCombiPrds_Temp WHERE SlabId=' + CAST(@SlabId AS VARCHAR(200)) +
								   ' AND CmpSchCode=' + CAST(@GetKey AS VARCHAR(200)) + ' AND PrdId='+ CAST(@PrdId AS VARCHAR(200)) +
								   ' AND PrdBatId=' +  CAST(@PrdBatId AS VARCHAR(200)) + ' AND UpLoadFlag=''N'''
			
							INSERT INTO Translog(strSql1) Values (@sSQL)
			
							INSERT INTO Etl_Prk_SchemeSlabCombiPrds_Temp(CmpSchCode,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,UpLoadFlag)
							VALUES(@GetKey,@SlabId,@PrdCtgId,@PrdId,@PrdBatId,@Value,'N')
				
							SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabCombiPrds_Temp(CmpSchCode,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,UpLoadFlag)
								    VALUES('+ CAST(@GetKey AS VARCHAR(200)) + ',' + ',' + CAST(@SlabId AS VARCHAR(200)) + ',' +
								   CAST(@PrdCtgId AS VARCHAR(200)) + ',' + CAST(@PrdId AS VARCHAR(200)) + ',' + CAST(@PrdBatId AS VARCHAR(200)) + ',' + CAST(@Value AS VARCHAR(200)) +
								   ',''N'')'
							INSERT INTO Translog(strSql1) Values (@sSQL)
						END
					END
					ELSE
					BEGIN
						DELETE FROM Etl_Prk_SchemeSlabCombiPrds_Temp WHERE SlabId=@SlabId AND CmpSchCode=@GetKey
						AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND UpLoadFlag='N'
						
						SET @sSQL ='DELETE FROM Etl_Prk_SchemeSlabCombiPrds_Temp WHERE SlabId=' + CAST(@SlabId AS VARCHAR(200)) +
							   ' AND CmpSchCode=' + CAST(@GetKey AS VARCHAR(200)) + ' AND PrdId='+ CAST(@PrdId AS VARCHAR(200)) +
							   ' AND PrdBatId=' +  CAST(@PrdBatId AS VARCHAR(200)) + ' AND UpLoadFlag=''N'''
		
						INSERT INTO Translog(strSql1) Values (@sSQL)
		
						INSERT INTO Etl_Prk_SchemeSlabCombiPrds_Temp(CmpSchCode,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,UpLoadFlag)
						VALUES(@GetKey,@SlabId,@PrdCtgId,@PrdId,@PrdBatId,@Value,'N')
			
						SET @sSQL ='INSERT INTO Etl_Prk_SchemeSlabCombiPrds_Temp(CmpSchCode,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,UpLoadFlag)
							    VALUES('+ CAST(@GetKey AS VARCHAR(200)) + ',' + ',' + CAST(@SlabId AS VARCHAR(200)) + ',' +
							   CAST(@PrdCtgId AS VARCHAR(200)) + ',' + CAST(@PrdId AS VARCHAR(200)) + ',' + CAST(@PrdBatId AS VARCHAR(200)) + ',' + CAST(@Value AS VARCHAR(200)) +
							   ',''N'')'
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
				END
				ELSE
				BEGIN
					DELETE FROM SchemeSlabCombiPrds WHERE SlabId=@SlabId AND SchId=@GetKey 
					AND PrdId=@PrdId AND PrdBatId=@PrdBatId AND PrdCtgValMainId=@PrdCtgId
					
					SET @sSQL ='DELETE FROM SchemeSlabCombiPrds WHERE SlabId=' + CAST(@SlabId AS VARCHAR(200)) +
						   ' AND SchId=' + CAST(@GetKey AS VARCHAR(200))
	
					INSERT INTO Translog(strSql1) Values (@sSQL)
	
					INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,
						    Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES(@GetKey,@SlabId,
						    @PrdCtgId,@PrdId,@PrdBatId,@Value,1,1,convert(varchar(10),getdate(),121),1,convert(varchar(10),getdate(),121))
		
					SET @sSQL ='INSERT INTO SchemeSlabCombiPrds(SchId,SlabId,PrdCtgValMainId,PrdId,PrdBatId,SlabValue,
						    Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES('+ CAST(@GetKey AS VARCHAR(200)) + ',' + ',' + CAST(@SlabId AS VARCHAR(200)) + ',' +
						   CAST(@PrdCtgId AS VARCHAR(200)) + ',' + CAST(@PrdId AS VARCHAR(200)) + ',' + CAST(@PrdBatId AS VARCHAR(200)) + ',' + CAST(@Value AS VARCHAR(200)) +
						   ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
			END
		END
		FETCH NEXT FROM Cur_SchemeCombiPrds INTO @SchCode,@SlabId,@PrdCode,@PrdBatCode,@Value
	END
	CLOSE Cur_SchemeCombiPrds
	DEALLOCATE Cur_SchemeCombiPrds
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-020

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeOnAnotherPrd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeOnAnotherPrd]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeOnAnotherPrd 0
ROLLBACK TRANSACTION
*/


CREATE                    PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeOnAnotherPrd]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeOnAnotherPrd
* PURPOSE: To Insert and Update records Of Scheme On Another Products
* CREATED: Boopathy.P on 06/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrDesc AS VARCHAR(1000)
	DECLARE @TabName AS VARCHAR(50)
	DECLARE @GetKey AS INT
	DECLARE @GetKeyStr AS NVARCHAR(200)
	DECLARE @Taction AS INT
	DECLARE @sSQL AS VARCHAR(4000)
	DECLARE @iCnt		AS INT
	DECLARE @SchCode 	AS VARCHAR(100)
	DECLARE @SchCode1 	AS VARCHAR(100)
	DECLARE @CmpCode 	AS VARCHAR(50)
	DECLARE @SchLevelMode	AS VARCHAR(50)
	DECLARE @SchLevel	AS VARCHAR(50)
	DECLARE @SlabCode	AS VARCHAR(50)
	DECLARE @SlabCode1	AS VARCHAR(50)
	DECLARE @SchType	AS VARCHAR(50)
	DECLARE @Range		AS VARCHAR(50)
	DECLARE @PrdType	AS VARCHAR(50)
	DECLARE @PrdCode	AS VARCHAR(50)
	DECLARE @PurQty		AS VARCHAR(50)
	DECLARE @PurFrmQty	AS VARCHAR(50)
	DECLARE @PurUom		AS VARCHAR(50)
	DECLARE @PurToQty	AS VARCHAR(50)
	DECLARE @PurToUom	AS VARCHAR(50)
	DECLARE @PurofEveryQty	AS VARCHAR(50)
	DECLARE @PurofUom	AS VARCHAR(50)
	DECLARE @DiscPer	AS VARCHAR(50)
	DECLARE @FlatAmt	AS VARCHAR(50)
	DECLARE @Points		AS VARCHAR(50)
	DECLARE @SchWithPrd	AS INT
	DECLARE @SLevel		AS INT
	DECLARE @CmpPrdCtgId	AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @CmpId		AS INT
	DECLARE @SchTypeId	AS INT
	DECLARE @ConFig		AS INT
	DECLARE @SlabId		AS INT
	DECLARE @SlabId1	AS INT
	DECLARE @RangeId	AS INT
	DECLARE @SchLevelModeId	AS INT
	DECLARE @PrdTypeId	AS INT
	DECLARE @PrdId		AS INT
	DECLARE @PurUomId	AS INT
	DECLARE @ToUomId	AS INT
	DECLARE @ForEveryUomId	AS INT

	SET @TabName = 'Etl_Prk_Scheme_OnAnotherPrd'
	SET @Po_ErrNo =0
	SET @iCnt=0
	
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	DECLARE Cur_SchOnAnotherPrdHd CURSOR
	FOR SELECT DISTINCT ISNULL(CmpSchCode,'') AS CmpSchCode,
	ISNULL(SlabId,'') AS SlabId,
	ISNULL(SchType,'') AS SchType,
	ISNULL(SchLevel,'') AS SchLevel,
	ISNULL(SchLevelMode,'') AS SchLevelMode,
	ISNULL(Range,'') AS Range
	FROM Etl_Prk_Scheme_OnAnotherPrd
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	OPEN Cur_SchOnAnotherPrdHd
	FETCH NEXT FROM Cur_SchOnAnotherPrdHd INTO @SchCode,@SlabCode, @SchType, @SchLevel, @SchLevelMode,@Range
	WHILE @@FETCH_STATUS=0
	BEGIN

		SET @Po_ErrNo =0

		SET @Taction = 2
		SET @SchWithPrd=0
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SlabCode))= ''
		BEGIN
			SET @ErrDesc = 'Slab should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (2,@TabName,'Scheme Slab',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchType))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Type should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (3,@TabName,'Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchLevel))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (4,@TabName,'Scheme Level',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchLevelMode))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level Mode should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (5,@TabName,'Scheme Level Mode',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF ((UPPER(LTRIM(RTRIM(@SchLevelMode)))<> 'UDC') AND (UPPER(LTRIM(RTRIM(@SchLevelMode)))<> 'PRODUCT'))
		BEGIN
			SET @ErrDesc = 'Selection Mode should be (UDC OR PRODUCT) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (6,@TabName,'Selction On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF  LTRIM(RTRIM(@Range))<> ''
		BEGIN
			IF ((UPPER(LTRIM(RTRIM(@Range)))<> 'YES') AND (UPPER(LTRIM(RTRIM(@Range)))<> 'NO'))
			BEGIN
				SET @ErrDesc = 'Range Based Scheme should be (YES OR NO) for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (6,@TabName,'Range Based Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @ConFig<>1
			BEGIN
				IF NOT EXISTS(SELECT SchId FROM SchemeMaster SM WHERE SM.CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @ErrDesc = 'Company Scheme Code not available for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (7,@TabName,'Company Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SET @Taction = 1
	
					IF EXISTS(SELECT SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode))
					END
					ELSE
					BEGIN
						SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (8,@TabName,'Scheme Slab',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
				END
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					IF EXISTS(SELECT SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode))
					END
					ELSE
					BEGIN
						SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (9,@TabName,'Scheme Slab',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
				END
				ELSE
				IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeMaster_Temp WHERE
					CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (10,@TabName,'Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE
				BEGIN
					SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM Etl_Prk_SchemeMaster_Temp
					WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					IF EXISTS(SELECT SlabId FROM Etl_Prk_SchemeSlabs_Temp SM WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
					BEGIN
						SELECT @SlabId=SlabId FROM Etl_Prk_SchemeSlabs_Temp SM WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)) AND SlabId=LTRIM(RTRIM(@SlabCode))
					END
					ELSE
					BEGIN
						SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (11,@TabName,'Scheme Slab',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					
				END
			END
		END
		IF @Po_ErrNo=0 	
		BEGIN
			IF EXISTS (SELECT CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
			AND CmpPrdCtgName=LTRIM(RTRIM(@SchLevel)))
			BEGIN
				SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
				AND CmpPrdCtgName=LTRIM(RTRIM(@SchLevel))
			END
			ELSE
			BEGIN
				SET @ErrDesc = 'Scheme Level not found for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (11,@TabName,'Scheme Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@SchType))) = 'QUANTITY'
			BEGIN
				SET @SchTypeId=1
			END
			ELSE IF UPPER(LTRIM(RTRIM(@SchType))) = 'AMOUNT'
			BEGIN
				SET @SchTypeId=2
			END
			ELSE IF UPPER(LTRIM(RTRIM(@SchType))) = 'WEIGHT'
			BEGIN
				SET @SchTypeId=3
			END
			IF LTRIM(RTRIM(@Range)) <> ''
			BEGIN
				IF ((UPPER(LTRIM(RTRIM(@Range)))= 'YES'))
				BEGIN
					SET @RangeId=1
				END
				ELSE IF ((UPPER(LTRIM(RTRIM(@Range)))= 'NO'))
				BEGIN
					SET @RangeId=0
				END
			END
			ELSE
			BEGIN
				SET @RangeId=0
			END
			IF ((UPPER(LTRIM(RTRIM(@SchLevelMode)))= 'UDC'))
			BEGIN
				SET @SchLevelModeId=1
			END
			ELSE IF ((UPPER(LTRIM(RTRIM(@SchLevelMode)))= 'PRODUCT'))
			BEGIN
				SET @SchLevelModeId=0
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF EXISTS (SELECT A.SchId FROM SchemeMaster A WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode)))
			BEGIN
				IF EXISTS (SELECT A.SchId FROM SchemeAnotherPrdHd A INNER JOIN SchemeMaster B ON
				A.SchId=B.SchId WHERE B.CmpSchCode=LTRIM(RTRIM(@SchCode))
				AND A.SlabId=LTRIM(RTRIM(@SlabCode)))
				BEGIN
					SET @Taction = 2
					SET @SchWithPrd=1
				END
				ELSE
				BEGIN
					SET @Taction = 1
					SET @SchWithPrd=1
					INSERT INTO SchemeAnotherPrdHd (SchId,SlabId,SchType,SchLevel,SchLevelMode,
						    Range,ApplySch,Availability,LastModBy,LastModDate,AuthId,AuthDate) VALUES
					(@GetKey,@SlabId,@SchTypeId,@CmpPrdCtgId,@SchLevelModeId,@RangeId,0,
					 1,1,GETDATE(),1,GETDATE())
				END
			END
			ELSE IF EXISTS (SELECT A.CmpSchCode FROM Etl_Prk_SchemeMaster_Temp A WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode)) AND A.UpLoadFlag='N')
			BEGIN
				IF EXISTS (SELECT A.CmpSchCode FROM Etl_Prk_SchemeAnotherPrdHd_Temp A INNER JOIN Etl_Prk_SchemeAnotherPrdHd_Temp B ON
				A.CmpSchCode=B.CmpSchCode WHERE B.CmpSchCode=LTRIM(RTRIM(@SchCode))
				AND A.SlabId=LTRIM(RTRIM(@SlabCode)))
				BEGIN
					SET @Taction = 2
					SET @SchWithPrd=2
				END
				ELSE
				BEGIN
					SET @Taction = 1
					SET @SchWithPrd=2
					INSERT INTO Etl_Prk_SchemeAnotherPrdHd_Temp (CmpSchCode,SlabId,SchType,SchLevel,SchLevelMode,Range)						
						VALUES (@SchCode,@SlabId,@SchTypeId,@CmpPrdCtgId,@SchLevelModeId,@RangeId)
				END
			END
--SELECT DISTINCT ISNULL(CmpSchCode,'') AS CmpSchCode,
--					ISNULL(SlabId,'') AS SlabId,
--					ISNULL(Range,'') AS Range,
--					ISNULL(PrdType,'') AS PrdType,
--					ISNULL(PrdCode,'') AS PrdCode,
--					ISNULL(PurQty,'0') AS PurQty,
--					ISNULL(PurFrmQty,'0') AS PurFrmQty,
--					ISNULL(PurUom ,'0') AS PurUom,
--					ISNULL(PurToQty ,'0') AS PurToQty,
--					ISNULL(PurToUom,'0') AS PurToUom,
--					ISNULL(PurofEveryQty ,'0') AS PurofEveryQty,
--					ISNULL(PurofUom ,'0') AS PurofUom,
--					ISNULL(DiscPer,'0') AS DiscPer,
--					ISNULL(FlatAmt,'0') AS FlatAmt,
--					ISNULL(Points,'0') AS Points
--					FROM Etl_Prk_Scheme_OnAnotherPrd WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
--					AND SlabId= LTRIM(RTRIM(@SlabCode))
			DECLARE Cur_SchOnAnotherPrdDt CURSOR
			FOR SELECT DISTINCT ISNULL(CmpSchCode,'') AS CmpSchCode,
					ISNULL(SlabId,'') AS SlabId,
					ISNULL(Range,'') AS Range,
					ISNULL(PrdType,'') AS PrdType,
					ISNULL(PrdCode,'') AS PrdCode,
					ISNULL(PurQty,'0') AS PurQty,
					ISNULL(PurFrmQty,'0') AS PurFrmQty,
					ISNULL(PurUom ,'0') AS PurUom,
					ISNULL(PurToQty ,'0') AS PurToQty,
					ISNULL(PurToUom,'0') AS PurToUom,
					ISNULL(PurofEveryQty ,'0') AS PurofEveryQty,
					ISNULL(PurofUom ,'0') AS PurofUom,
					ISNULL(DiscPer,'0') AS DiscPer,
					ISNULL(FlatAmt,'0') AS FlatAmt,
					ISNULL(Points,'0') AS Points
					FROM Etl_Prk_Scheme_OnAnotherPrd WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					AND SlabId= LTRIM(RTRIM(@SlabCode))
			OPEN Cur_SchOnAnotherPrdDt
			FETCH NEXT FROM Cur_SchOnAnotherPrdDt INTO @SchCode1,@SlabCode1,@Range,@PrdType,@PrdCode,
					@PurQty,@PurFrmQty,@PurUom,@PurToQty,@PurToUom,@PurofEveryQty,@PurofUom
					,@DiscPer, @FlatAmt, @Points
			WHILE @@FETCH_STATUS=0
			BEGIN
				IF LTRIM(RTRIM(@SchCode1))= ''
				BEGIN
					SET @ErrDesc = 'Company Scheme Code should not be blank'
					INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@SlabCode1))= ''
				BEGIN
					SET @ErrDesc = 'Slab should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Scheme Slab',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@PrdType))= ''
				BEGIN
					SET @ErrDesc = 'Product Type should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Product Type',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@PrdCode))= ''
				BEGIN
					SET @ErrDesc = 'Product Code should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Product Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@PurQty))= ''
				BEGIN
					SET @ErrDesc = 'Purchase Qty should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Purchase Qty',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF LTRIM(RTRIM(@PurUom))= ''
				BEGIN
					SET @ErrDesc = 'Purchase Uom should not be blank for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Purchase Uom',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF (LTRIM(RTRIM(@DiscPer))= '0' AND LTRIM(RTRIM(@FlatAmt))= '0' AND LTRIM(RTRIM(@Points))= '0')
				BEGIN
					SET @ErrDesc = 'Disc % or Flat Amount or Points should not be Zero for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (2,@TabName,'Disc,Flat Amount and Points',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				IF @Po_ErrNo=0
				BEGIN
					IF @ConFig<>1
					BEGIN
						IF NOT EXISTS(SELECT SchId FROM SchemeMaster SM WHERE SM.CmpSchCode=LTRIM(RTRIM(@SchCode1)))
						BEGIN
							SET @ErrDesc = 'Company Scheme Code not available in Master Table for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (7,@TabName,'Company Scheme Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1))
							SET @Taction = 1
			
							IF EXISTS(SELECT SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode1)))
							BEGIN
								SELECT @SlabId1=SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode1))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (8,@TabName,'Scheme Slab',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
					END
					ELSE
					BEGIN
						IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1)))
						BEGIN
							SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1))
							IF EXISTS(SELECT SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode1)))
							BEGIN
								SELECT @SlabId1=SlabId FROM SchemeSlabs SM WHERE SchId=@GetKey AND SlabId=LTRIM(RTRIM(@SlabCode1))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (9,@TabName,'Scheme Slab',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
						ELSE
						IF NOT EXISTS(SELECT CmpSchCode FROM Etl_Prk_SchemeMaster_Temp WHERE
							CmpSchCode=LTRIM(RTRIM(@SchCode1)))
						BEGIN
							SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (10,@TabName,'Scheme Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM Etl_Prk_SchemeMaster_Temp
							WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1))
		
							IF EXISTS(SELECT SlabId FROM Etl_Prk_SchemeSlabs_Temp SM WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1)))
							BEGIN
								SELECT @SlabId1=SlabId FROM Etl_Prk_SchemeSlabs_Temp SM WHERE CmpSchCode=LTRIM(RTRIM(@SchCode1)) AND SlabId=LTRIM(RTRIM(@SlabCode1))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Scheme Slab not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Scheme Slab',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
							
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF LTRIM(RTRIM(@PurofEveryQty))<> ''
						BEGIN
							IF EXISTS (SELECT UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurofUom)))
							BEGIN
								SELECT @ForEveryUomId=UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurofUom))
								
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Purchase of every Uom not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Purchase of every Uom',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
						ELSE
						BEGIN
							SET @ForEveryUomId=0
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF UPPER(LTRIM(RTRIM(@PrdType)))= 'NO'
						BEGIN
							SET @PrdTypeId =0
						END
						ELSE IF UPPER(LTRIM(RTRIM(@PrdType)))= 'YES'
						BEGIN
							SET @PrdTypeId=1
						END
	
						IF UPPER(LTRIM(RTRIM(@PrdType)))= 'YES'
						BEGIN
							IF EXISTS (SELECT PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode)))
							BEGIN
								SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=LTRIM(RTRIM(@PrdCode))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Product Code:'+@PrdCode +' not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Product Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
						ELSE IF UPPER(LTRIM(RTRIM(@PrdType)))= 'NO'
						BEGIN
							IF EXISTS (SELECT PrdCtgValMainId FROM ProductCategoryValue WHERE PrdCtgValCode=LTRIM(RTRIM(@PrdCode)))
							BEGIN
								SELECT @PrdId=PrdCtgValMainId FROM ProductCategoryValue WHERE PrdCtgValCode=LTRIM(RTRIM(@PrdCode))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Product Category Value Code:'+@PrdCode +' not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Product Category Value Code',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF EXISTS (SELECT UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurUom)))
						BEGIN
							SELECT @PurUomId=UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurUom))
							SET @ToUomId=0
						END
						ELSE
						BEGIN
							SET @ErrDesc = 'Purchase Uom not found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (11,@TabName,'Purchase Uom',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF LTRIM(RTRIM(@Range)) <> ''
						BEGIN
							IF UPPER(LTRIM(RTRIM(@Range)))= 'YES'
							BEGIN
								SET @RangeId=1
							END
							ELSE IF UPPER(LTRIM(RTRIM(@Range)))= 'NO'
							BEGIN
								SET @RangeId=0
							END
						END
						ELSE
						BEGIN
							SET @RangeId=0
						END
	
						IF @RangeId=1
						BEGIN
							IF EXISTS (SELECT UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurToUom)))
							BEGIN
								SELECT @ToUomId=UomId FROM UomMaster WHERE UomCode=LTRIM(RTRIM(@PurToUom))
							END
							ELSE
							BEGIN
								SET @ErrDesc = 'Purchase Uom not found for Scheme Code:'+@SchCode
								INSERT INTO Errorlog VALUES (11,@TabName,'Purchase Uom',@ErrDesc)
								SET @Taction = 0
								SET @Po_ErrNo =1
							END
						END
						ELSE
						BEGIN
							SET @ToUomId=0
						END
					END
					IF @Po_ErrNo=0
					BEGIN
						IF EXISTS (SELECT A.SchId FROM SchemeMaster A WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode1)))
						BEGIN
							IF EXISTS (SELECT A.SchId FROM SchemeAnotherPrdDt A INNER JOIN SchemeMaster B ON
							A.SchId=B.SchId WHERE B.CmpSchCode=LTRIM(RTRIM(@SchCode1))
							AND A.SlabId=LTRIM(RTRIM(@SlabCode1)))
							BEGIN
								SET @Taction = 2
							END
							ELSE
							BEGIN
								SET @Taction = 1
							END
						END
						ELSE IF EXISTS (SELECT A.CmpSchCode FROM Etl_Prk_SchemeMaster_Temp A WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode1)) AND A.UpLoadFlag='N')
						BEGIN
							IF EXISTS (SELECT A.CmpSchCode FROM Etl_Prk_SchemeAnotherPrdHd_Temp A INNER JOIN Etl_Prk_SchemeMaster_Temp B ON
							A.CmpSchCode=B.CmpSchCode WHERE B.CmpSchCode=LTRIM(RTRIM(@SchCode1))
							AND A.SlabId=LTRIM(RTRIM(@SlabCode1)))
							BEGIN
								SET @Taction = 2
							END
							ELSE
							BEGIN
								SET @Taction = 1
							END
						END
					END

					IF @Taction = 1
					BEGIN
						IF @SchWithPrd =1
						BEGIN
							INSERT INTO SchemeAnotherPrdDt (SchId,SlabId,PrdType,PrdId,PurQty,PurFrmQty,PurUomId,PurToQty,
							PurToUomId,PurofEveryQty,PurofUomId,DiscPer,FlatAmt,Points,Availability,
							LastModBy,LastModDate,AuthId,AuthDate) VALUES
							(@GetKey,@SlabId1,@PrdTypeId,@PrdId,@PurQty,@PurFrmQty,@PurUomId,@PurToQty,
							@ToUomId,@PurofEveryQty,@ForEveryUomId,@DiscPer,@FlatAmt,CAST(@Points AS NUMERIC(18,0)),1,1,
							GETDATE(),1,GETDATE())
						END
						ELSE IF @SchWithPrd =2
						BEGIN
							INSERT INTO Etl_Prk_SchemeAnotherPrdDt_Temp (CmpSchCode,SlabId,PrdType,PrdId,PrdCode,PurQty,PurFrmQty,
							PurUomId,PurUomCode,PurToQty,PurToUomId,PurToUomCode,PurofEveryQty,PurofUomId,PurofUomCode,
							DiscPer,FlatAmt,Points) VALUES (
							@GetKey,@SlabId1,@PrdTypeId,@PrdId,@PrdCode,@PurQty,@PurFrmQty,@PurUomId,@PurUom,@PurToQty,
							@ToUomId,@PurToUom,@PurofEveryQty,@ForEveryUomId,@PurofUom,@DiscPer,@FlatAmt,CAST(@Points AS NUMERIC(18,0)))
						END
					END
					ELSE IF @Taction = 2
					BEGIN
						IF @SchWithPrd =1
						BEGIN
							UPDATE SchemeAnotherPrdDt Set PrdType=@PrdTypeId,PrdId=@PrdId,PurQty=@PurQty,PurFrmQty=@PurFrmQty,
							PurUomId=@PurUomId,PurToQty=@PurToQty,PurToUomId=@ToUomId,PurofEveryQty=@PurofEveryQty,
							PurofUomId=@ForEveryUomId,DiscPer=@DiscPer,FlatAmt=@FlatAmt,Points=CAST(@Points AS NUMERIC(18,0))
							WHERE SchId=@GetKey AND SlabId=@SlabId1
						END
						ELSE IF @SchWithPrd =2
						BEGIN
							UPDATE Etl_Prk_SchemeAnotherPrdDt_Temp SET PrdType=@PrdTypeId,PrdId=@PrdId,PrdCode=@PrdCode,PurQty=@PurQty,
							PurFrmQty=@PurFrmQty,PurUomId=@PurUomId,PurUomCode=@PurUom,PurToQty=@PurToQty,
							PurToUomId=@ToUomId,PurToUomCode=@PurToUom,PurofEveryQty=@PurofEveryQty,
							PurofUomId=@ForEveryUomId,PurofUomCode=PurofUomCode,DiscPer=@DiscPer,
							FlatAmt=@FlatAmt,Points=CAST(@Points AS NUMERIC(18,0))
							WHERE CmpSchCode=@SchCode1 AND SlabId=@SlabId1
						END
					END
				END
				FETCH NEXT FROM Cur_SchOnAnotherPrdDt INTO @SchCode1,@SlabCode1,@Range,@PrdType,@PrdCode,
				@PurQty,@PurFrmQty,@PurUom,@PurToQty,@PurToUom,@PurofEveryQty,@PurofUom,@DiscPer,@FlatAmt,@Points
			END

			CLOSE Cur_SchOnAnotherPrdDt
			DEALLOCATE Cur_SchOnAnotherPrdDt
		END
		FETCH NEXT FROM Cur_SchOnAnotherPrdHd INTO  @SchCode,@SlabCode,@SchType,@SchLevel,@SchLevelMode,@Range
	END

	CLOSE Cur_SchOnAnotherPrdHd
	DEALLOCATE Cur_SchOnAnotherPrdHd

	UPDATE Etl_Prk_SchemeHD_Slabs_Rules SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)

	UPDATE Etl_Prk_Scheme_OnAttributes SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)

	UPDATE Etl_Prk_Scheme_Free_Multi_Products SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)

	UPDATE Etl_Prk_Scheme_OnAnotherPrd SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)

	UPDATE Etl_Prk_Scheme_RetailerLevelValid SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)

	UPDATE Etl_Prk_SchemeProducts_Combi SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)	

	UPDATE Etl_Prk_Scheme_OnAnotherPrd SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-021

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ImportSchemeHD_Slabs_Rules]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ImportSchemeHD_Slabs_Rules]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE Procedure [dbo].[Proc_ImportSchemeHD_Slabs_Rules] 
(
@Pi_Records TEXT
)
AS
/***************************************************************************************************
* PROCEDURE		: Proc_ImportSchemeHD_Slabs_Rules
* PURPOSE		: To Insert records from xml file in the Table Etl_Prk_SchemeHD_Slabs_Rules
* CREATED		: Aarthi.R
* CREATED DATE	: 21/01/2008
* MODIFIED
* DATE         AUTHOR       DESCRIPTION
****************************************************************************************************
* 25.08.2009   Panneer      Added the BudgetAllacationNo Column in Parking Table(Etl_Prk_SchemeHD_Slabs_Rules)
* 19.10.2009   Thiru		Added the SchBasedOn column in Parking Table(Etl_Prk_SchemeHD_Slabs_Rules)	
* 22/04/2010   Nanda        Added the FBM Column 
****************************************************************************************************/
SET NOCOUNT ON
BEGIN

	DECLARE @hDoc INTEGER
	DECLARE @Company NVARCHAR(100)
	DECLARE @ClmGroupCode NVARCHAR(100)
	SELECT @Company = CmpCode FROM Company WHERE DefaultCompany = 1
	SELECT @ClmGroupCode = ClmGrpCode FROM ClaimGroupMaster WHERE ClmGrpId = 17

	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records

	INSERT INTO Etl_Prk_SchemeHD_Slabs_Rules(CmpSchCode,SchDsc,CmpCode,Claimable,ClmAmton,ClmGroupCode,SchLevel,SchType,BatchLevel,FlexiSch,
	FlexiSchType,CombiSch,Range,ProRata,QPS,QPSReset,ApyQPSSch,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,PurofEvery,
	SetWindowDisp,EditScheme,SchemeLevelMode,SlabId,PurQty,FromQty,Uom,ToQty,ToUom,ForEveryQty,ForEveryUom,DiscPer,FlatAmt,FlxDisc,
	FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,SchConfig,SchRules,
	NoofBills,FromDate,ToDate,MarketVisit,ApplySchBasedOn,EnableRtrLvl,AllowSaving,AllowSelection,BudgetAllocationNo,SchBasedOn,FBM,DownloadFlag)
	SELECT  [CmpSchCode],[SchDsc],@Company AS [CmpCode],[Claimable],[ClmAmton],@ClmGroupCode AS [ClmGroupCode],[SchLevel],[SchType],
	'NO' AS [BatchLevel],[FlexiSch],[FlexiSchType],[CombiSch],[Range],[ProRata],[QPS],[QPSReset],[ApyQPSSch],[SchValidFrom],[SchValidTill],
	[SchStatus],[Budget],[AdjWinDispOnlyOnce],[PurofEvery],[SetWindowDisp],[EditScheme],[SchemeLevelMode],[SlabId],[PurQty],[FromQty],
	[Uom],[ToQty],[ToUom],[ForEveryQty],[ForEveryUom],[DiscPer],[FlatAmt],[FlxDisc],[FlxValueDisc],[FlxFreePrd],[FlxGiftPrd],[FlxPoints],
	[Points],[MaxDiscount],[MinDiscount],[MaxValue],[MinValue],[MaxPoints],[MinPoints],[SchConfig],[SchRules],[NoofBills],[FromDate],
	[ToDate],[MarketVisit],[ApplySchBasedOn],[EnableRtrLvl],[AllowSaving],[AllowSelection],[BudgetAllocationNo],[SchBasedOn],[FBM],[DownloadFlag]
	FROM OPENXML (@hdoc,'/Root/Console2CS_Scheme_HD_Slabs_Rules ',1)
	WITH 
	(
		[CmpSchCode]			NVARCHAR(25),
		[SchDsc]				NVARCHAR(100),
		[CmpCode]				NVARCHAR(100),
		[Claimable]				NVARCHAR(10),
		[ClmAmton]				NVARCHAR(25) ,
		[ClmGroupCode]			NVARCHAR(100),
		[SchLevel]				NVARCHAR(25),
		[SchType]				NVARCHAR(20),
		[BatchLevel]			NVARCHAR(100),
		[FlexiSch]				NVARCHAR(10),
		[FlexiSchType]			NVARCHAR(15),
		[CombiSch]				NVARCHAR(10),
		[Range]					NVARCHAR(10),
		[ProRata]				NVARCHAR(10),
		[QPS]					NVARCHAR(10),
		[QPSReset]				NVARCHAR(10),
		[ApyQPSSch]				NVARCHAR(10),
		[SchValidFrom]			NVARCHAR(10),
		[SchValidTill]			NVARCHAR(10),
		[SchStatus]				NVARCHAR(10),
		[Budget]				NVARCHAR(20),
		[AdjWinDispOnlyOnce]	NVARCHAR(10),
		[PurofEvery]			NVARCHAR(10),
		[SetWindowDisp]			NVARCHAR(10),
		[EditScheme]			NVARCHAR(10),
		[SchemeLevelMode]		NVARCHAR(10),
		[SlabId]				INT ,
		[PurQty]				NUMERIC(18, 2) ,
		[FromQty]				NUMERIC(18, 2) ,
		[Uom]					NVARCHAR(10) ,
		[ToQty]					NUMERIC(18, 2) ,
		[ToUom]					NVARCHAR(10) ,
		[ForEveryQty]			NUMERIC(18, 2) ,
		[ForEveryUom]			NVARCHAR(10) ,
		[DiscPer]				NUMERIC(18, 2) ,
		[FlatAmt]				NUMERIC(18, 2) ,
		[FlxDisc]				NVARCHAR(10) ,
		[FlxValueDisc]			NVARCHAR(10) ,
		[FlxFreePrd]			NVARCHAR(10) ,
		[FlxGiftPrd]			NVARCHAR(10) ,
		[FlxPoints]				NVARCHAR(10) ,
		[Points]				NUMERIC(18, 2) ,
		[MaxDiscount]			NUMERIC(18, 2) ,
		[MinDiscount]			NUMERIC(18, 2) ,
		[MaxValue]				NUMERIC(18, 2) ,
		[MinValue]				NUMERIC(18, 2) ,
		[MaxPoints]				NUMERIC(18, 2) ,
		[MinPoints]				NUMERIC(18, 2) ,
		[SchConfig]				NVARCHAR(10) ,
		[SchRules]				NVARCHAR(10) ,
		[NoofBills]				INT ,
		[FromDate]				NVARCHAR(10) ,
		[ToDate]				NVARCHAR(10) ,
		[MarketVisit]			INT ,
		[ApplySchBasedOn]		NVARCHAR(10) ,
		[EnableRtrLvl]			NVARCHAR(10) ,
		[AllowSaving]			NVARCHAR(10) ,
		[AllowSelection]		NVARCHAR(10),
		[DownloadFlag]			NVARCHAR(1),
		[BudgetAllocationNo]	NVARCHAR (100),
		[SchBasedOn]			NVARCHAR (50),
		[FBM]					NVARCHAR (10)		
	) XMLObj

	EXEC sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-022

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ImportSchemeProducts_Combi]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ImportSchemeProducts_Combi]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Exec Proc_ImportSchemeProducts_Combi '<Root></Root>'

CREATE         Procedure [dbo].[Proc_ImportSchemeProducts_Combi]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportSchemeProducts_Combi
* PURPOSE	: To Insert records from xml file in the Table Etl_Prk_SchemeProducts_Combi
* CREATED	: Aarthi.R
* CREATED DATE	: 21/01/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	INSERT INTO Etl_Prk_SchemeProducts_Combi
	SELECT	
			[CmpSchCode],
			[SlabId] ,
			[SchLevel],
			[PrdCode] ,
			[PrdBatCode],
			[SlabValue],
			[DownloadFlag]
	FROM OPENXML (@hdoc,'/Root/Console2CS_Scheme_Products',1)
	WITH (
			
			[CmpSchCode] [varchar](25),
			[SlabId] [int] ,
			[SchLevel] [varchar](25),
			[PrdCode] [varchar](25) ,
			[PrdBatCode] [varchar](25) ,
			[SlabValue] [varchar](25),
			[DownloadFlag] [varchar](1)
	) XMLObj
	
	EXEC sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-023

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ImportScheme_OnAttributes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ImportScheme_OnAttributes]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE         Procedure [dbo].[Proc_ImportScheme_OnAttributes]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportScheme_OnAttributes
* PURPOSE	: To Insert records from xml file in the Table Etl_Prk_Scheme_OnAttributes
* CREATED	: Aarthi.R
* CREATED DATE	: 21/01/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	INSERT INTO Etl_Prk_Scheme_OnAttributes
	SELECT	
			[CmpSchCode] ,
			[AttrType] ,
			[AttrName] ,
			[DownloadFlag]
	FROM OPENXML (@hdoc,'/Root/Console2CS_Scheme_Attributes ',1)
	WITH (	
			[CmpSchCode] [varchar](25) ,
			[AttrType] [varchar](50) ,
			[AttrName] [varchar](100),
			[DownloadFlag] [varchar] (1)
	) XMLObj
	
	EXEC sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-024

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ImportScheme_Free_Multi_Products]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ImportScheme_Free_Multi_Products]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE         Procedure [dbo].[Proc_ImportScheme_Free_Multi_Products]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportScheme_Free_Multi_Products
* PURPOSE	: To Insert records from xml file in the Table Etl_Prk_Scheme_Free_Multi_Products
* CREATED	: Aarthi.R
* CREATED DATE	: 21/01/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER

	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	INSERT INTO Etl_Prk_Scheme_Free_Multi_Products
	SELECT	
			[CmpSchCode] ,
			[SlabId],
			[PrdId] ,
			[FreeQty],
			[OpnANDOR] ,
			[SeqId],
			[Type],
			[DownloadFlag]
	FROM OPENXML (@hdoc,'/Root/Console2CS_Scheme_FreeProducts',1)
	WITH (
			[CmpSchCode] [varchar](25) ,
			[SlabId] [int],
			[PrdId] [varchar](25) ,
			[FreeQty] [int],
			[OpnANDOR] [varchar](10) ,
			[SeqId] [int] ,
			[Type] [varchar](10),
			[DownloadFlag][varchar](1)
	) XMLObj

	EXEC sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-025

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ImportScheme_OnAnotherPrd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ImportScheme_OnAnotherPrd]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE          Procedure [dbo].[Proc_ImportScheme_OnAnotherPrd]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportScheme_OnAnotherPrd
* PURPOSE	: To Insert records from xml file in the Table Etl_Prk_Scheme_OnAnotherPrd
* CREATED	: Aarthi.R
* CREATED DATE	: 21/01/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	INSERT INTO Etl_Prk_Scheme_OnAnotherPrd
	SELECT	
			[CmpSchCode]  ,
			[SlabId] ,
			[SchType] ,
			[SchLevel],
			[SchLevelMode],
			[Range],
			[PrdType],
			[PrdId] ,
			[PurQty],
			[PurFrmQty],
			[PurUom],
			[PurToQty],
			[PurToUom],
			[PurofEveryQty],
			[PurofUom],
			[DiscPer],
			[FlatAmt],
			[Points],
			[DownloadFlag]
	FROM OPENXML (@hdoc,'/Root/Console2CS_Scheme_OnAnotherPrd',1)
	WITH (	
			[CmpSchCode] [varchar](25) ,
			[SlabId] [int] ,
			[SchType] [varchar](25) ,
			[SchLevel] [varchar](25),
			[SchLevelMode] [varchar](10) ,
			[Range] [varchar](10) ,
			[PrdType] [varchar] (10),
			[PrdId] [varchar](25),
			[PurQty] [numeric](18, 2),
			[PurFrmQty] [numeric](18, 2),
			[PurUom] [varchar](10) ,
			[PurToQty] [numeric](18, 2),
			[PurToUom] [varchar](10) ,
			[PurofEveryQty] [numeric](18, 2) ,
			[PurofUom] [varchar](10) ,
			[DiscPer] [numeric](18, 2),
			[FlatAmt] [numeric](18, 2),
			[Points] [numeric](18, 2),
			[DownloadFlag] [varchar] (1)
	) XMLObj

	EXEC sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-026

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ImportScheme_RetailerLevelValid]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ImportScheme_RetailerLevelValid]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE         Procedure [dbo].[Proc_ImportScheme_RetailerLevelValid]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportScheme_RetailerLevelValid
* PURPOSE	: To Insert records from xml file in the Table Etl_Prk_Scheme_RetailerLevelValid
* CREATED	: Aarthi.R
* CREATED DATE	: 21/01/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	INSERT INTO Etl_Prk_Scheme_RetailerLevelValid
	SELECT	
			[CmpSchCode] ,
			[RtrCode] ,
			[FromDate],
			[ToDate],
			[BudgetAllocated],
			[Status],
			[DownloadFlag]
	FROM OPENXML (@hdoc,'/Root/Console2Pos_Scheme_RtrValidation ',1)
	WITH (
	
			[CmpSchCode] [varchar](25) ,
			[RtrCode] [varchar](25) ,
			[FromDate] [varchar](10),
			[ToDate] [varchar](10),
			[BudgetAllocated] [numeric](18, 2) ,
			[Status] [varchar](10),
			[DownloadFlag] [varchar](1)
	) XMLObj
	
	EXEC sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-027

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_DependencyCheck]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_DependencyCheck]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_DependencyCheck 'FocusBrandHd',FBM0700003Proc_VoucherPostingDebitNote

CREATE       PROCEDURE [dbo].[Proc_DependencyCheck]
(
@Pi_TableName AS VARCHAR(30),
@Pi_Code AS VARCHAR(20)
)
AS
/*********************************
* PROCEDURE: Proc_DependencyCheck
* PURPOSE: To Delete the record
* CREATED: Deepa 19/01/06
* NOTE: General SP for all the Dependency Check
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[TempDepCheck]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	DROP TABLE [TempDepCheck]
	CREATE TABLE TempDepCheck
	(
		RecordId VARCHAR(50),
		RelatedTable Varchar(50)
	)

	DECLARE @Str AS VARCHAR(500)
	DECLARE @RelatedTable AS VARCHAR(100)
	DECLARE @FieldName AS VARCHAR(100)	
	DECLARE Cur_Dependency CURSOR FOR

	SELECT  RelatedTable,FieldName FROM DependencyTable WHERE PrimaryTable=@Pi_TableName
	OPEN Cur_Dependency
	FETCH NEXT FROM Cur_Dependency into @RelatedTable,@FieldName
	WHILE @@FETCH_STATUS=0
	BEGIN	
		SET @Str = 'INSERT INTO TempDepCheck '
		SET @Str= @Str + 'SELECT  DISTINCT '+ @FieldName
		SET @Str= @Str + ', '''+@RelatedTable+''' '
		SET @Str= @Str + ' FROM '+ @RelatedTable
		SET @Str= @Str + ' WHERE ' + @FieldName + '= ''' + CAST(@Pi_Code AS VARCHAR)
		SET @Str= @Str + ''' AND Availability = 1' 	
		EXEC(@Str)
		FETCH NEXT FROM Cur_Dependency INTO @RelatedTable,@FieldName
	END
	
	CLOSE Cur_Dependency
	DEALLOCATE Cur_Dependency
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-028-From Kalai

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_RptCurrentStockUOMBASED')
DROP PROCEDURE  Proc_RptCurrentStockUOMBASED
GO
--EXEC Proc_RptCurrentStockUOMBASED 5,2,0,'Dabur1',0,0,1,0
--EXEC Proc_RptCurrentStockUOMBASED 5,1,5,'Nestle 2.0.0.5',1,0,1,0
CREATE  PROCEDURE [Proc_RptCurrentStockUOMBASED]
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
* PROCEDURE : Proc_RptCurrentStockUOMBASED
* PURPOSE : To get the Current Stock details for Report
* CREATED : MURUGAN.R
* CREATED DATE : 01/09/2009
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
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
	DECLARE @StockType       AS Int
	DECLARE @fPrdId        AS Int
	DECLARE @sStockType       AS NVARCHAR(20)
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
	SET @StockType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))
	--Till Here
	--If Product Category Filter is available
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	--Till Here
	EXEC Proc_CurrentStockReportUOMBASED @Pi_RptId,@Pi_UsrId

	IF @StockType=1
	BEGIN
		SET @sStockType='Saleable'
	END
	ELSE IF @StockType=2
	BEGIN
		SET @sStockType='UnSaleable'
	END
	ELSE IF @StockType=3
	BEGIN
		SET @sStockType='Offer'
	END

	Create TABLE #RptCurrentStockUOMBASED
	(
		PrdId    INT,
		PrdDcode  NVARCHAR(100),
		PrdName   NVARCHAR(200),
		PrdBatId              INT,
		PrdBatCode   NVARCHAR(100),
		MRP                NUMERIC (38,6),
		DisplayRate         NUMERIC (38,6),
		[StockValue Saleable]       NUMERIC (38,6),
		[StockValue UnSaleable]      NUMERIC (38,6),
		[Total StockValue]         NUMERIC (38,6),
		UOMCONVERTEDQTY INT,
		ORDERID INT,
		StockingType Varchar(50),
		UOMID INT,UOMCODE VARCHAR(50)	,	
		StockType	INT
		
	)
	
	
	SET @TblName = '#RptCurrentStockUOMBASED'
	SET @TblStruct = ' PrdId      INT,
	PrdDcode    NVARCHAR(100),
	PrdName     NVARCHAR(200),
	PrdBatId           INT,
	PrdBatCode     NVARCHAR(100),
	MRP             NUMERIC (38,6),
	DisplayRate    NUMERIC (38,6),
	[StockValue Saleable]       NUMERIC (38,6),
	[StockValue UnSaleable]      NUMERIC (38,6),
	[Total StockValue]         NUMERIC (38,6),
	UOMCONVERTEDQTY INT,
	ORDERID INT,
	StockingType Varchar(50),
	UOMID INT,UOMCODE VARCHAR(50),
	StockType	INT'	
	SET @TblFields = 'PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
	[StockValue Saleable] ,[StockValue UnSaleable] ,[Total StockValue],UOMCONVERTEDQTY ,ORDERID,StockingType,UOMID,UOMCODE,[StockType]'
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
			IF @DispBatch=2
			BEGIN
				INSERT INTO #RptCurrentStockUOMBASED (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				[StockValue Saleable] ,[StockValue UnSaleable] ,[Total StockValue],UOMCONVERTEDQTY ,ORDERID,StockingType,UOMID,UOMCODE ,StockType)
				SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SELLINGRATE,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(LISTPRICE,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,				
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UNSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UNListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UNMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TOTSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TOTListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TOTMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,
				UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE,@StockType
				FROM RptCurrentStockWithUom
				WHERE
--				(CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
--				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
--				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
--				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
--				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
--				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
--				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
--				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
--				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
--				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 				
				GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
					MRP,ListPrice,SELLINGRATE,UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE
			END
			ELSE
			BEGIN
				INSERT INTO #RptCurrentStockUOMBASED (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				[StockValue Saleable] ,[StockValue UnSaleable] ,[Total StockValue],UOMCONVERTEDQTY ,ORDERID,StockingType,UOMID,UOMCODE,StockType )
				SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SELLINGRATE,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(LISTPRICE,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,				
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UNSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UNListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UNMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TOTSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TOTListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TOTMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,
					UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE,@StockType
				FROM RptCurrentStockWithUom
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 				
				GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
					MRP,ListPrice,SELLINGRATE,UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE
			END
	IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptCurrentStockUOMBASED ' +
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
			--UPDATE #RptCurrentStockUOMBASED SET DispBatch=@DispBatch
			--PRINT 'Retrived Data From Purged Table'
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCurrentStockUOMBASED'
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
			SET @SSQL = 'INSERT INTO #RptCurrentStockUOMBASED ' +
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
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStockUOMBASED
	
--	IF @StockType=0
--	BEGIN
		SELECT * FROM #RptCurrentStockUOMBASED 
--	END
--	ELSE
--	BEGIN
--		SELECT * FROM #RptCurrentStockUOMBASED WHERE StockingType=@sStockType
--	END
END	
GO 

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_CurrentStockReportUOMBASED')
DROP PROCEDURE  Proc_CurrentStockReportUOMBASED
GO
-- EXEC Proc_CurrentStockReportUOMBASED 5,2 
CREATE PROCEDURE [Proc_CurrentStockReportUOMBASED]    
/************************************************************
* VIEW	: Proc_CurrentStockReportUOMBASED
* PURPOSE	: To get the Current Stock of the Products with Batch details (With Out Tax)
* CREATED BY	: MURUGAN.R
* CREATED DATE	: 01/09/2009
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
(
	@Pi_RptId AS INT,
	@Pi_UsrId AS INT
)
AS
BEGIN
	CREATE TABLE #RptCurrentStockWithUomTemp
	(
		LCNID INT,
		LCNNAME VARCHAR(100),
		PRDID INT,
		PRDDCODE VARCHAR(100),
		PRDNAME VARCHAR(150),
		PRDBATID INT,
		PRDBATCODE VARCHAR(150),
		MRP NUMERIC(36,6),
		SELLINGRATE NUMERIC(36,6),
		LISTPRICE NUMERIC(36,6),
		[SalMRP] NUMERIC(36,6),
		[SalSelRate] NUMERIC(36,6),
		[SalListPrc] NUMERIC(36,6),
		[UNMRP] NUMERIC(36,6),
		[UNSelRate] NUMERIC(36,6),
		[UNListPrc] NUMERIC(36,6),
		[TOTMRP] NUMERIC(36,6),
		[TOTSelRate] NUMERIC(36,6),
		[TOTListPrc] NUMERIC(36,6),
		STOCKONHAND INT,
		UOMID INT,
		UOMCODE VARCHAR(50),
		CONVERSIONFACTOR INT,
		STOCKINGTYPE VARCHAR(50),
		ORDERID INT,
		UOMCONVERTEDQTY INT,
		PrdStatus INT,
		Status INT,
		CmpId INT, 
		PrdCtgValMainId INT,
		CmpPrdCtgId INT,
		PrdCtgValLinkCode VarChar(100)
	)

	DECLARE @SupZeroStock AS INT
	DECLARE @DispBatch AS INT
	DECLARE @CmpId AS INT
	DECLARE @LcnId AS INT
	DECLARE @PrdStatus AS INT
	DECLARE @PrdBatStatus AS INT

	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	SET @DispBatch = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
	SET @PrdBatStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))
	
	PRINT 'start'
	--SET @DispBatch=2
	PRINT @SupZeroStock
	PRINT @CmpId
	PRINT @LcnId
	PRINT @PrdStatus
	PRINT @PrdBatStatus
	PRINT @DispBatch
	PRINT 'End'


	TRUNCATE TABLE RptCurrentStockWithUom
	IF (@DispBatch=1)
	BEGIN
		INSERT INTO #RptCurrentStockWithUomTemp
		(LCNID,LCNNAME,PRDID,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
		[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
		,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
		,CmpPrdCtgId,PrdCtgValLinkCode)
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP)  AS [SalMRP],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate))  AS [SalSelRate],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate))  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Saleable' as StockingType,
			1 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid	
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
			Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
			Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
			Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
			Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
		GROUP BY  PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
		PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status	 			
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			0   AS [SalMRP],
			0  AS [SalSelRate],
			0 AS [SalListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP)   AS [UNMRP],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate))  AS [UNSelRate],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate)) AS [UNListPrc],
			0   AS [TOTMRP],
			0  AS [TOTSelRate],
			0 AS [TOTListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Unsaleable' as StockingType,
			2 as OrderId,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode 
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 
		GROUP BY  PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
			PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status		
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			0  AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0 AS [TOTSelRate],
			0 AS [TOTListPrc],	
			SUM((PrdBatLcnFre-PrdBatLcnResFre)) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Offer' as StockingType,
			3 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 	
		GROUP BY  PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
			PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status	
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			0  AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ))   AS [TOTMRP],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate)))  AS [TOTSelRate],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate) )) AS [TOTListPrc],
			SUM(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
			(PrdBatLcnFre-PrdBatLcnResFre))) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Total StockOnHand' as StockingType,
			4 as OrderId,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode 
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 
			GROUP BY  PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
				PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status	
	END	
	ELSE IF @DispBatch=2
	BEGIN
			INSERT INTO #RptCurrentStockWithUomTemp
			(LCNID,LCNNAME,PRDID,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
			[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
			,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
			,CmpPrdCtgId,PrdCtgValLinkCode)
			SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP)  AS [SalMRP],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate))  AS [SalSelRate],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate))  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Saleable' as StockingType,
			1 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 	
					
			GROUP BY PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			0 AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP )  AS [UNMRP],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate))  AS [UNSelRate],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate)) AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'UnSaleable' as StockingType,
			2 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))	
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 			
			GROUP BY PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			0 AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnFre-PrdBatLcnResFre)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Offer' as StockingType,
			3 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 				
			GROUP BY PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR

		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			0 AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ) )  AS [TOTMRP],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate)))  AS [TOTSelRate],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate) )) AS [TOTListPrc],
			SUM(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
			(PrdBatLcnFre-PrdBatLcnResFre))) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Total StockOnHand' as StockingType,
			4 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 	
			GROUP BY PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR	
	
	END
--
--		SELECT * FROM #RptCurrentStockWithUomTemp
--	
--return	
		IF @SupZeroStock=1
		BEGIN
			INSERT INTO RptCurrentStockWithUom
			(LCNID,LCNNAME,PRDID,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
			[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
			,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
			,CmpPrdCtgId,PrdCtgValLinkCode) SELECT * FROM #RptCurrentStockWithUomTemp WHERE STOCKONHAND>0
		END
		ELSE
		BEGIN
			INSERT INTO RptCurrentStockWithUom
			(LCNID,LCNNAME,PRDID,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
			[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
			,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
			,CmpPrdCtgId,PrdCtgValLinkCode) SELECT * FROM #RptCurrentStockWithUomTemp WHERE STOCKONHAND>=0
		END

		

		
		Select Prdid,Prdbatid,Lcnid,[SalMRP],[SalSelRate],[SalListPrc]
		INTO #RptCurrentStockWithUom FROM RptCurrentStockWithUom WHERE ORDERID=1

		Update RPT1 SET RPT1.[SalMRP]=RPT.[SalMRP],RPT1.[SalSelRate]=RPT.[SalSelRate],
		RPT1.[SalListPrc]=RPT.[SalListPrc] FROM RptCurrentStockWithUom RPT1 INNER JOIN
		#RptCurrentStockWithUom RPT ON RPT1.Prdid=Rpt.Prdid
		and rpt1.Prdbatid=rpt.prdbatid and rpt1.lcnid=rpt.lcnid

		Select Prdid,Prdbatid,Lcnid,[UNMRP],[UNSelRate],[UNListPrc]
		INTO #RptCurrentStockWithUom1 FROM RptCurrentStockWithUom WHERE ORDERID=2

		Update RPT1 SET RPT1.[UNMRP]=RPT.[UNMRP],RPT1.[UNSelRate]=RPT.[UNSelRate],
		RPT1.[UNListPrc]=RPT.[UNListPrc] FROM RptCurrentStockWithUom RPT1 INNER JOIN
		#RptCurrentStockWithUom1 RPT ON RPT1.Prdid=Rpt.Prdid
		and rpt1.Prdbatid=rpt.prdbatid and rpt1.lcnid=rpt.lcnid

		Select Prdid,Prdbatid,Lcnid,[TOTMRP],[TOTSelRate],[TOTListPrc]
		INTO #RptCurrentStockWithUom4 FROM RptCurrentStockWithUom WHERE ORDERID=4

		Update RPT1 SET RPT1.[TOTMRP]=RPT.[TOTMRP],RPT1.[TOTSelRate]=RPT.[TOTSelRate],
		RPT1.[TOTListPrc]=RPT.[TOTListPrc] FROM RptCurrentStockWithUom RPT1 INNER JOIN
		#RptCurrentStockWithUom4 RPT ON RPT1.Prdid=Rpt.Prdid
		and rpt1.Prdbatid=rpt.prdbatid and rpt1.lcnid=rpt.lcnid
	
		---FIND UOM QTY

		DECLARE @Prdid AS INT
		DECLARE @Prdbatid AS INT
		DECLARE @OrderId AS INT
		DECLARE @LcnId1 AS INT
		DECLARE @Prdid1 AS INT
		DECLARE @Prdbatid1 AS INT
		DECLARE @CONVERSIONFACTOR AS INT
		DECLARE @StockOnHand AS INT
		DECLARE @UOMID AS INT
		DECLARE @Converted as INT
		DECLARE @Remainder as INT

			DECLARE CUR_UOM CURSOR
			FOR 
				SELECT DISTINCT P.PrdId,RT.Prdbatid,OrderID,StockOnHand
				FROM Product P (NOLOCK),RptCurrentStockWithUom RT (NOLOCK) WHERE P.Prdid=RT.Prdid 
				Order By P.Prdid,OrderId 
			OPEN CUR_UOM
			FETCH NEXT FROM CUR_UOM INTO @Prdid,@Prdbatid,@OrderId,@StockOnHand
			WHILE @@FETCH_STATUS=0
			BEGIN
					SET	@Converted=0
					SET @Remainder=0				
					DECLARE CUR_UOMCONVERT CURSOR
					FOR 
					SELECT Prdid,Prdbatid,UOMID,CONVERSIONFACTOR FROM RptCurrentStockWithUom (NOLOCK) WHERE PRDID=@Prdid and Prdbatid=@Prdbatid  and OrderId=@OrderId  and StockOnhand>0  and CONVERSIONFACTOR>0  Order by CONVERSIONFACTOR DESC
					OPEN CUR_UOMCONVERT
					FETCH NEXT FROM CUR_UOMCONVERT INTO  @Prdid1,@Prdbatid1,@UOMID,@CONVERSIONFACTOR
					WHILE @@FETCH_STATUS=0
					BEGIN
						IF @StockOnHand>= @CONVERSIONFACTOR
						BEGIN
							SET	@Converted=CAST(@StockOnHand/@CONVERSIONFACTOR as INT)
							SET @Remainder=CAST(@StockOnHand%@CONVERSIONFACTOR AS INT)
							SET @StockOnHand=@Remainder						
							UPDATE RptCurrentStockWithUom SET UOMCONVERTEDQTY=Isnull(@Converted,0)  WHERE PRDID=@Prdid1 and Prdbatid=@Prdbatid1 and Uomid=@UOMID and OrderId=@OrderId 
						END					
						
					FETCH NEXT FROM CUR_UOMCONVERT INTO @Prdid1,@Prdbatid1,@UOMID,@CONVERSIONFACTOR
					END	
					CLOSE CUR_UOMCONVERT
					DEALLOCATE CUR_UOMCONVERT
					SET @StockOnHand=0
			FETCH NEXT FROM CUR_UOM INTO @Prdid,@Prdbatid,@OrderId,@StockOnHand
			END	
			CLOSE CUR_UOM
			DEALLOCATE CUR_UOM

	--	SELECT * FROM RptCurrentStockWithUom
		--TILL HERE
END  
GO 

--SRF-Nanda-152-029-From Kalai

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_RptCurrentStockUOMBASED')
DROP PROCEDURE  Proc_RptCurrentStockUOMBASED
GO
--EXEC Proc_RptCurrentStockUOMBASED 5,2,0,'Dabur1',0,0,1,0
--EXEC Proc_RptCurrentStockUOMBASED 5,1,5,'Nestle 2.0.0.5',1,0,1,0
CREATE  PROCEDURE [Proc_RptCurrentStockUOMBASED]
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
* PROCEDURE : Proc_RptCurrentStockUOMBASED
* PURPOSE : To get the Current Stock details for Report
* CREATED : MURUGAN.R
* CREATED DATE : 01/09/2009
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
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
	DECLARE @StockType       AS Int
	DECLARE @fPrdId        AS Int
	DECLARE @sStockType       AS NVARCHAR(20)
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
	SET @StockType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))
	--Till Here
	--If Product Category Filter is available
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	--Till Here
	EXEC Proc_CurrentStockReportUOMBASED @Pi_RptId,@Pi_UsrId

	IF @StockType=1
	BEGIN
		SET @sStockType='Saleable'
	END
	ELSE IF @StockType=2
	BEGIN
		SET @sStockType='UnSaleable'
	END
	ELSE IF @StockType=3
	BEGIN
		SET @sStockType='Offer'
	END

	Create TABLE #RptCurrentStockUOMBASED
	(
		PrdId    INT,
		PrdDcode  NVARCHAR(100),
		PrdName   NVARCHAR(200),
		PrdBatId              INT,
		PrdBatCode   NVARCHAR(100),
		MRP                NUMERIC (38,6),
		DisplayRate         NUMERIC (38,6),
		[StockValue Saleable]       NUMERIC (38,6),
		[StockValue UnSaleable]      NUMERIC (38,6),
		[Total StockValue]         NUMERIC (38,6),
		UOMCONVERTEDQTY INT,
		ORDERID INT,
		StockingType Varchar(50),
		UOMID INT,UOMCODE VARCHAR(50)	,	
		StockType	INT
		
	)
	
	
	SET @TblName = '#RptCurrentStockUOMBASED'
	SET @TblStruct = ' PrdId      INT,
	PrdDcode    NVARCHAR(100),
	PrdName     NVARCHAR(200),
	PrdBatId           INT,
	PrdBatCode     NVARCHAR(100),
	MRP             NUMERIC (38,6),
	DisplayRate    NUMERIC (38,6),
	[StockValue Saleable]       NUMERIC (38,6),
	[StockValue UnSaleable]      NUMERIC (38,6),
	[Total StockValue]         NUMERIC (38,6),
	UOMCONVERTEDQTY INT,
	ORDERID INT,
	StockingType Varchar(50),
	UOMID INT,UOMCODE VARCHAR(50),
	StockType	INT'	
	SET @TblFields = 'PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
	[StockValue Saleable] ,[StockValue UnSaleable] ,[Total StockValue],UOMCONVERTEDQTY ,ORDERID,StockingType,UOMID,UOMCODE,[StockType]'
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
			IF @DispBatch=2
			BEGIN
				INSERT INTO #RptCurrentStockUOMBASED (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				[StockValue Saleable] ,[StockValue UnSaleable] ,[Total StockValue],UOMCONVERTEDQTY ,ORDERID,StockingType,UOMID,UOMCODE ,StockType)
				SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SELLINGRATE,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(LISTPRICE,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,				
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UNSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UNListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UNMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TOTSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TOTListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TOTMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,
				UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE,@StockType
				FROM RptCurrentStockWithUom
				WHERE
--				(CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
--				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
--				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
--				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
--				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
--				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
--				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
--				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
--				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
--				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 				
				GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
					MRP,ListPrice,SELLINGRATE,UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE
			END
			ELSE
			BEGIN
				INSERT INTO #RptCurrentStockUOMBASED (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				[StockValue Saleable] ,[StockValue UnSaleable] ,[Total StockValue],UOMCONVERTEDQTY ,ORDERID,StockingType,UOMID,UOMCODE,StockType )
				SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SELLINGRATE,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(LISTPRICE,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,				
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UNSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UNListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UNMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TOTSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TOTListPrc,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TOTMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,
					UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE,@StockType
				FROM RptCurrentStockWithUom
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (PrdId = (CASE @fPrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 				
				GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
					MRP,ListPrice,SELLINGRATE,UOMCONVERTEDQTY,ORDERID,StockingType,UOMID,UOMCODE
			END
	IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptCurrentStockUOMBASED ' +
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
			--UPDATE #RptCurrentStockUOMBASED SET DispBatch=@DispBatch
			--PRINT 'Retrived Data From Purged Table'
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCurrentStockUOMBASED'
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
			SET @SSQL = 'INSERT INTO #RptCurrentStockUOMBASED ' +
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
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStockUOMBASED
	
--	IF @StockType=0
--	BEGIN
		SELECT * FROM #RptCurrentStockUOMBASED 
--	END
--	ELSE
--	BEGIN
--		SELECT * FROM #RptCurrentStockUOMBASED WHERE StockingType=@sStockType
--	END
END	
GO 

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_CurrentStockReportUOMBASED')
DROP PROCEDURE  Proc_CurrentStockReportUOMBASED
GO
-- EXEC Proc_CurrentStockReportUOMBASED 5,2 
CREATE PROCEDURE [Proc_CurrentStockReportUOMBASED]    
/************************************************************
* VIEW	: Proc_CurrentStockReportUOMBASED
* PURPOSE	: To get the Current Stock of the Products with Batch details (With Out Tax)
* CREATED BY	: MURUGAN.R
* CREATED DATE	: 01/09/2009
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
(
	@Pi_RptId AS INT,
	@Pi_UsrId AS INT
)
AS
BEGIN
	CREATE TABLE #RptCurrentStockWithUomTemp
	(
		LCNID INT,
		LCNNAME VARCHAR(100),
		PRDID INT,
		PRDDCODE VARCHAR(100),
		PRDNAME VARCHAR(150),
		PRDBATID INT,
		PRDBATCODE VARCHAR(150),
		MRP NUMERIC(36,6),
		SELLINGRATE NUMERIC(36,6),
		LISTPRICE NUMERIC(36,6),
		[SalMRP] NUMERIC(36,6),
		[SalSelRate] NUMERIC(36,6),
		[SalListPrc] NUMERIC(36,6),
		[UNMRP] NUMERIC(36,6),
		[UNSelRate] NUMERIC(36,6),
		[UNListPrc] NUMERIC(36,6),
		[TOTMRP] NUMERIC(36,6),
		[TOTSelRate] NUMERIC(36,6),
		[TOTListPrc] NUMERIC(36,6),
		STOCKONHAND INT,
		UOMID INT,
		UOMCODE VARCHAR(50),
		CONVERSIONFACTOR INT,
		STOCKINGTYPE VARCHAR(50),
		ORDERID INT,
		UOMCONVERTEDQTY INT,
		PrdStatus INT,
		Status INT,
		CmpId INT, 
		PrdCtgValMainId INT,
		CmpPrdCtgId INT,
		PrdCtgValLinkCode VarChar(100)
	)

	DECLARE @SupZeroStock AS INT
	DECLARE @DispBatch AS INT
	DECLARE @CmpId AS INT
	DECLARE @LcnId AS INT
	DECLARE @PrdStatus AS INT
	DECLARE @PrdBatStatus AS INT

	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	SET @DispBatch = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))
	SET @PrdBatStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))
	
	PRINT 'start'
	--SET @DispBatch=2
	PRINT @SupZeroStock
	PRINT @CmpId
	PRINT @LcnId
	PRINT @PrdStatus
	PRINT @PrdBatStatus
	PRINT @DispBatch
	PRINT 'End'


	TRUNCATE TABLE RptCurrentStockWithUom
	IF (@DispBatch=1)
	BEGIN
		INSERT INTO #RptCurrentStockWithUomTemp
		(LCNID,LCNNAME,PRDID,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
		[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
		,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
		,CmpPrdCtgId,PrdCtgValLinkCode)
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP)  AS [SalMRP],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate))  AS [SalSelRate],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate))  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Saleable' as StockingType,
			1 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid	
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
			Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
			Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
			Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
			Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
		GROUP BY  PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
		PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status	 			
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			0   AS [SalMRP],
			0  AS [SalSelRate],
			0 AS [SalListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP)   AS [UNMRP],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate))  AS [UNSelRate],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate)) AS [UNListPrc],
			0   AS [TOTMRP],
			0  AS [TOTSelRate],
			0 AS [TOTListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Unsaleable' as StockingType,
			2 as OrderId,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode 
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 
		GROUP BY  PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
			PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status		
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			0  AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0 AS [TOTSelRate],
			0 AS [TOTListPrc],	
			SUM((PrdBatLcnFre-PrdBatLcnResFre)) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Offer' as StockingType,
			3 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 	
		GROUP BY  PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
			PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status	
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,	
			DPH.SellingRate AS SelRate,	
			DPH.PurchaseRate AS ListPrice,
			0  AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ))   AS [TOTMRP],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate)))  AS [TOTSelRate],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate) )) AS [TOTListPrc],
			SUM(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
			(PrdBatLcnFre-PrdBatLcnResFre))) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Total StockOnHand' as StockingType,
			4 as OrderId,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode 
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 
			GROUP BY  PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR,
				PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP,DPH.SellingRate,DPH.PurchaseRate,PrdBat.Status	
	END	
	ELSE IF @DispBatch=2
	BEGIN
			INSERT INTO #RptCurrentStockWithUomTemp
			(LCNID,LCNNAME,PRDID,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
			[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
			,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
			,CmpPrdCtgId,PrdCtgValLinkCode)
			SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP)  AS [SalMRP],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate))  AS [SalSelRate],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate))  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnSih-PrdBatLcnResSih)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Saleable' as StockingType,
			1 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 	
					
			GROUP BY PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			0 AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP )  AS [UNMRP],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate))  AS [UNSelRate],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate)) AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnUih-PrdBatLcnResUih)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'UnSaleable' as StockingType,
			2 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))	
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 			
			GROUP BY PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR
		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			0 AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			0 AS [TOTMRP],
			0  AS [TOTSelRate],
			0  AS [TOTListPrc],
			SUM((PrdBatLcnFre-PrdBatLcnResFre)) AS StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Offer' as StockingType,
			3 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 				
			GROUP BY PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR

		UNION ALL
		SELECT DISTINCT  0,'',PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,0,'',0 AS MRP,	
			0 AS SelRate,	
			0 AS ListPrice,
			0 AS [SalMRP],
			0  AS [SalSelRate],
			0  AS [SalListPrc],
			0  AS [UNMRP],
			0  AS [UNSelRate],
			0 AS [UNListPrc],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ) )  AS [TOTMRP],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate)))  AS [TOTSelRate],
			SUM((((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate) )) AS [TOTListPrc],
			SUM(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
			(PrdBatLcnFre-PrdBatLcnResFre))) AS  StockOnHand,
			UOMID,UOMCODE,CONVERSIONFACTOR,
			'Total StockOnHand' as StockingType,
			4 as OrderId ,
			0 as UOMCONVERTEDQTY,
			Prd.PrdStatus,0,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
			ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			DefaultPriceHistory DPH (NOLOCK) ,
			ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
			CROSS JOIN (SELECT DISTINCT X.PRDID,X.UOMID,X.UOMCODE,ISNULL(UM.UOMGROUPID,0) as UOMGROUPID,Isnull(CONVERSIONFACTOR,0) as CONVERSIONFACTOR FROM UOMGROUP UM (NOLOCK) RIGHT OUTER JOIN (
			SELECT PRDID,UOMGROUPID,UOMID,UOMCODE FROM PRODUCT (NOLOCK) CROSS JOIN UOMMASTER (NOLOCK) )X ON UM.UOMID=X.UOMID and X.UOMGROUPID=UM.UOMGROUPID)M
		WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
			AND PRd.Prdid=M.Prdid			
			AND (Prd.CmpId=  (CASE @CmpId WHEN 0 THEN Prd.CmpId ELSE 0 END ) OR
				Prd.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			AND   (Lcn.LcnId=  (CASE @LcnId WHEN 0 THEN Lcn.LcnId ELSE 0 END ) OR
				Lcn.LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
			AND   (Prd.PrdStatus=(CASE @PrdStatus WHEN 0 THEN Prd.PrdStatus ELSE 0 END ) OR
				Prd.PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
			AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE 0 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))) 	
			GROUP BY PrdBatLcn.PrdId,Prd.PrdDCode,Prd.PrdName,Prd.PrdStatus,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,UOMID,UOMCODE,CONVERSIONFACTOR	
	
	END
--
--		SELECT * FROM #RptCurrentStockWithUomTemp
--	
--return	
		IF @SupZeroStock=1
		BEGIN
			INSERT INTO RptCurrentStockWithUom
			(LCNID,LCNNAME,PRDID,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
			[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
			,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
			,CmpPrdCtgId,PrdCtgValLinkCode) SELECT * FROM #RptCurrentStockWithUomTemp WHERE STOCKONHAND>0
		END
		ELSE
		BEGIN
			INSERT INTO RptCurrentStockWithUom
			(LCNID,LCNNAME,PRDID,PRDDCODE,PRDNAME,PRDBATID,PRDBATCODE,MRP,SELLINGRATE,LISTPRICE,[SalMRP],[SalSelRate],[SalListPrc],
			[UNMRP],[UNSelRate],[UNListPrc],[TOTMRP],[TOTSelRate],[TOTListPrc]
			,STOCKONHAND,UOMID,UOMCODE,CONVERSIONFACTOR,STOCKINGTYPE,ORDERID,UOMCONVERTEDQTY,PrdStatus,Status,CmpId,PrdCtgValMainId
			,CmpPrdCtgId,PrdCtgValLinkCode) SELECT * FROM #RptCurrentStockWithUomTemp WHERE STOCKONHAND>=0
		END

		

		
		Select Prdid,Prdbatid,Lcnid,[SalMRP],[SalSelRate],[SalListPrc]
		INTO #RptCurrentStockWithUom FROM RptCurrentStockWithUom WHERE ORDERID=1

		Update RPT1 SET RPT1.[SalMRP]=RPT.[SalMRP],RPT1.[SalSelRate]=RPT.[SalSelRate],
		RPT1.[SalListPrc]=RPT.[SalListPrc] FROM RptCurrentStockWithUom RPT1 INNER JOIN
		#RptCurrentStockWithUom RPT ON RPT1.Prdid=Rpt.Prdid
		and rpt1.Prdbatid=rpt.prdbatid and rpt1.lcnid=rpt.lcnid

		Select Prdid,Prdbatid,Lcnid,[UNMRP],[UNSelRate],[UNListPrc]
		INTO #RptCurrentStockWithUom1 FROM RptCurrentStockWithUom WHERE ORDERID=2

		Update RPT1 SET RPT1.[UNMRP]=RPT.[UNMRP],RPT1.[UNSelRate]=RPT.[UNSelRate],
		RPT1.[UNListPrc]=RPT.[UNListPrc] FROM RptCurrentStockWithUom RPT1 INNER JOIN
		#RptCurrentStockWithUom1 RPT ON RPT1.Prdid=Rpt.Prdid
		and rpt1.Prdbatid=rpt.prdbatid and rpt1.lcnid=rpt.lcnid

		Select Prdid,Prdbatid,Lcnid,[TOTMRP],[TOTSelRate],[TOTListPrc]
		INTO #RptCurrentStockWithUom4 FROM RptCurrentStockWithUom WHERE ORDERID=4

		Update RPT1 SET RPT1.[TOTMRP]=RPT.[TOTMRP],RPT1.[TOTSelRate]=RPT.[TOTSelRate],
		RPT1.[TOTListPrc]=RPT.[TOTListPrc] FROM RptCurrentStockWithUom RPT1 INNER JOIN
		#RptCurrentStockWithUom4 RPT ON RPT1.Prdid=Rpt.Prdid
		and rpt1.Prdbatid=rpt.prdbatid and rpt1.lcnid=rpt.lcnid
	
		---FIND UOM QTY

		DECLARE @Prdid AS INT
		DECLARE @Prdbatid AS INT
		DECLARE @OrderId AS INT
		DECLARE @LcnId1 AS INT
		DECLARE @Prdid1 AS INT
		DECLARE @Prdbatid1 AS INT
		DECLARE @CONVERSIONFACTOR AS INT
		DECLARE @StockOnHand AS INT
		DECLARE @UOMID AS INT
		DECLARE @Converted as INT
		DECLARE @Remainder as INT

			DECLARE CUR_UOM CURSOR
			FOR 
				SELECT DISTINCT P.PrdId,RT.Prdbatid,OrderID,StockOnHand
				FROM Product P (NOLOCK),RptCurrentStockWithUom RT (NOLOCK) WHERE P.Prdid=RT.Prdid 
				Order By P.Prdid,OrderId 
			OPEN CUR_UOM
			FETCH NEXT FROM CUR_UOM INTO @Prdid,@Prdbatid,@OrderId,@StockOnHand
			WHILE @@FETCH_STATUS=0
			BEGIN
					SET	@Converted=0
					SET @Remainder=0				
					DECLARE CUR_UOMCONVERT CURSOR
					FOR 
					SELECT Prdid,Prdbatid,UOMID,CONVERSIONFACTOR FROM RptCurrentStockWithUom (NOLOCK) WHERE PRDID=@Prdid and Prdbatid=@Prdbatid  and OrderId=@OrderId  and StockOnhand>0  and CONVERSIONFACTOR>0  Order by CONVERSIONFACTOR DESC
					OPEN CUR_UOMCONVERT
					FETCH NEXT FROM CUR_UOMCONVERT INTO  @Prdid1,@Prdbatid1,@UOMID,@CONVERSIONFACTOR
					WHILE @@FETCH_STATUS=0
					BEGIN
						IF @StockOnHand>= @CONVERSIONFACTOR
						BEGIN
							SET	@Converted=CAST(@StockOnHand/@CONVERSIONFACTOR as INT)
							SET @Remainder=CAST(@StockOnHand%@CONVERSIONFACTOR AS INT)
							SET @StockOnHand=@Remainder						
							UPDATE RptCurrentStockWithUom SET UOMCONVERTEDQTY=Isnull(@Converted,0)  WHERE PRDID=@Prdid1 and Prdbatid=@Prdbatid1 and Uomid=@UOMID and OrderId=@OrderId 
						END					
						
					FETCH NEXT FROM CUR_UOMCONVERT INTO @Prdid1,@Prdbatid1,@UOMID,@CONVERSIONFACTOR
					END	
					CLOSE CUR_UOMCONVERT
					DEALLOCATE CUR_UOMCONVERT
					SET @StockOnHand=0
			FETCH NEXT FROM CUR_UOM INTO @Prdid,@Prdbatid,@OrderId,@StockOnHand
			END	
			CLOSE CUR_UOM
			DEALLOCATE CUR_UOM

	--	SELECT * FROM RptCurrentStockWithUom
		--TILL HERE
END  
GO 

IF  EXISTS (SELECT * FROM sysobjects WHERE xtype='V' AND name='View_CurrentStockReport')
DROP VIEW [View_CurrentStockReport]
GO 
CREATE View [View_CurrentStockReport]
/************************************************************
* VIEW	: View_CurrentStockReport
* PURPOSE	: To get the Current Stock of the Products with Batch details
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 26/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode,
	Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,
	DPH.SellingRate+TxRpt.SellingTaxAmount AS SelRate,DPH.PurchaseRate+TxRpt.PurchaseTaxAmount AS ListPrice,
	(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
	(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
	(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
	((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
	(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
	(PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP  AS SalMRP,
	(PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP  AS UnSalMRP,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ) AS TotMRP,
	(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS SalSelRate,
	(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS UnSalSelRate,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate+TxRpt.SellingTaxAmount) ) AS TotSelRate,
	(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS SalListPrice,
	(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS UnSalListPrice,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount) ) AS TotListPrice,
	Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode,TxRpt.UsrId
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
	ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
	DefaultPriceHistory DPH (NOLOCK) ,
	TaxForReport TxRpt (NOLOCK),
	ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
	AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
	AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
	AND TxRpt.PrdBatId=PrdBat.PrdBatId  AND TxRpt.PrdId=Prd.PrdId AND TxRpt.Rptid=5
	--AND PBDM.DefaultPrice=1  AND PBDR.DefaultPrice=1  AND PBDL.DefaultPrice=1
	--AND PrdBat.DefaultPriceId=PBDM.PriceId  AND PrdBat.DefaultPriceId=PBDR.PriceId  AND PrdBat.DefaultPriceId=PBDL.PriceId
GO


IF  EXISTS (SELECT * FROM sysobjects WHERE xtype='V' AND name='View_CurrentStockReportNTax')
DROP VIEW [View_CurrentStockReportNTax]
GO 
CREATE View [View_CurrentStockReportNTax]
/************************************************************
* VIEW	: View_CurrentStockReportNTax
* PURPOSE	: To get the Current Stock of the Products with Batch details (With Out Tax)
* CREATED BY	: Srivatchan
* CREATED DATE	: 24/07/2009
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode,
	Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,DPH.MRP AS MRP,
	--DPH.SellingRate+TxRpt.SellingTaxAmount AS SelRate,
	DPH.SellingRate AS SelRate,
	--DPH.PurchaseRate+TxRpt.PurchaseTaxAmount AS ListPrice,
	DPH.PurchaseRate AS ListPrice,
	(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
	(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
	(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
	((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
	(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
	(PrdBatLcnSih-PrdBatLcnResSih)* DPH.MRP  AS SalMRP,
	(PrdBatLcnUih-PrdBatLcnResUih)* DPH.MRP  AS UnSalMRP,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* DPH.MRP ) AS TotMRP,
	--(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS SalSelRate,
	(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.SellingRate)  AS SalSelRate,
	--(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate+TxRpt.SellingTaxAmount)  AS UnSalSelRate,
	(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.SellingRate)  AS UnSalSelRate,
	--(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate+TxRpt.SellingTaxAmount) ) AS TotSelRate,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.SellingRate) ) AS TotSelRate,
	--(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS SalListPrice,
	(PrdBatLcnSih-PrdBatLcnResSih)* (DPH.PurchaseRate)  AS SalListPrice,
	(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate)  AS UnSalListPrice,
	--(PrdBatLcnUih-PrdBatLcnResUih)* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount)  AS UnSalListPrice,
	--(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate+TxRpt.PurchaseTaxAmount) ) AS TotListPrice,
	(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (DPH.PurchaseRate) ) AS TotListPrice,
	Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
	ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
	DefaultPriceHistory DPH (NOLOCK) ,
	--TaxForReport TxRpt (NOLOCK),
	ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
	AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
	AND DPH.prdid=prd.PrdId AND DPH.prdbatid=prdbat.PrdBatId AND CurrentDefault=1 
	--AND TxRpt.PrdBatId=PrdBat.PrdBatId  AND TxRpt.PrdId=Prd.PrdId AND TxRpt.Rptid=5
	--AND PBDM.DefaultPrice=1  AND PBDR.DefaultPrice=1  AND PBDL.DefaultPrice=1
	--AND PrdBat.DefaultPriceId=PBDM.PriceId  AND PrdBat.DefaultPriceId=PBDR.PriceId  AND PrdBat.DefaultPriceId=PBDL.PriceId
GO


IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_RptReportToBill')
DROP PROCEDURE  Proc_RptReportToBill
GO
-- EXEC Proc_RptReportToBill 2,16,0,1
CREATE PROCEDURE [Proc_RptReportToBill]
(
	@Pi_UsrId INT,
	@Pi_RptId INT,
	@Pi_Sel INT,
	@Pi_InvDC INT
)
AS
/***************************************************************************************************
* PROCEDURE: Proc_RptReportToBill
* PURPOSE: General Procedure
* NOTES:
* CREATED: Nanda	 
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
* 01.10.2009		Panneer	   Checked in Invoice Type Condition
****************************************************************************************************/


SET NOCOUNT ON
BEGIN
	--Filter Variable
	DECLARE @FromBillNo AS  BIGINT
	DECLARE @ToBillNo   AS  BIGINT
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SelBillNo  AS  BIGINT
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME

	--Assgin Value for the Filter Variable
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @FromBillNo = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @TOBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	SET @SelBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId))
	SET @FromDate =(SELECT  TOP 1 dSELECTed FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSELECTed FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))

	IF @Pi_Sel = 1
	BEGIN
		 SELECT @FromBillNo = Min(SalId) FROM SalesInvoice
		 SELECT @ToBillNo = Max(SalId) FROM SalesInvoice
        
	END

	DELETE from RptBillToPrint where [UsrId] = @Pi_UsrId

	IF @Pi_InvDC=2
	BEGIN	
		INSERT INTO  RptBillToPrint
		SELECT DISTINCT [SalInvNo],@Pi_UsrId FROM SalesInvoice
		WHERE
		 (SalId=(CASE @SelBillNo WHEN 0 THEN SalId ELSE 0 END) OR
							SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId)))
		AND
		 (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
							SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		AND
		 (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
							RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		AND
		 (DlvRMId=(CASE @RMId WHEN 0 THEN DlvRMId ELSE 0 END) OR
							DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)))
		AND (SalId BETWEEN @FromBillNo AND @ToBillNo)

		AND (SalInvDate BETWEEN @FromDate AND @ToDate)
		AND InvType=0
	END
	ELSE
	BEGIN
		--->Added By Nanda on 24/09/2009
		IF @Pi_Sel = 0
		BEGIN
			PRINT 'Start'
			DECLARE @FromId INT
			DECLARE @ToId INT
			DECLARE @StartBill AS nvarchar(100)
			DECLARE @EndBill AS nvarchar(500)

			DECLARE @FromSeq INT
			DECLARE @ToSeq INT

			SELECT @FromId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=14 
			SELECT @ToId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=15
			
			PRINT 'ID'			
			PRINT @FromId
			PRINT @ToId
			PRINT 'ID End'
			
			SELECT  @StartBill= SalInvno FROM SalesInvoice WHERE SalId=@FromId
			SELECT  @EndBill=	SalInvno FROM SalesInvoice WHERE SalId=@ToId		

			SELECT @FromSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@FromId
			SELECT @ToSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@ToId			

			INSERT INTO  RptBillToPrint		
			SELECT DISTINCT [SalInvNo],@Pi_UsrId FROM SalesInvoice
			WHERE
			 (SalId IN (SELECT SalId FROM SalInvoiceDeliveryChallan WHERE SeqNo BETWEEN @FromSeq AND @ToSeq)) OR 
			 (SalId IN (SELECT SalId FROM SalesInvoice WHERE SalInvno BETWEEN @StartBill AND @EndBill))	
			AND
			 (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
								SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND
			 (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
								RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND
			 (DlvRMId=(CASE @RMId WHEN 0 THEN DlvRMId ELSE 0 END) OR
								DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)))
			AND (SalInvDate BETWEEN @FromDate AND @ToDate)

			AND InvType=1			
		END
		ELSE--->Till Here
		BEGIN
			INSERT INTO  RptBillToPrint		
			SELECT DISTINCT [SalInvNo],@Pi_UsrId FROM SalesInvoice
			WHERE
			 (SalId=(CASE @SelBillNo WHEN 0 THEN SalId ELSE 0 END) OR
								SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,34,@Pi_UsrId)))
			AND
			 (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
								SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			AND
			 (RtrId=(CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
								RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
			AND
			 (DlvRMId=(CASE @RMId WHEN 0 THEN DlvRMId ELSE 0 END) OR
								DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)))
			AND (SalId BETWEEN @FromBillNo AND @ToBillNo)
			AND (SalInvDate BETWEEN @FromDate AND @ToDate)
			AND InvType=1
		END
	END
END
GO

--SRF-Nanda-152-030

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ProductBatch]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ProductBatch]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
SELECT COUNT(*) FROM Cn2Cs_Prk_ProductBatch(NOLOCK) WHERE DownLoadFlag='D'
SELECT COUNT(*) FROM ProductBatch(NOLOCK)
SELECT COUNT(*) FROM ProductBatchDetails(NOLOCK)
--SELECT COUNT(*) FROM ContractPricingMaster(NOLOCK)
--SELECT COUNT(*) FROM ContractPricingDetails(NOLOCK)
EXEC Proc_Cn2Cs_ProductBatch 0
SELECT COUNT(*) FROM ProductBatch(NOLOCK)
SELECT COUNT(*) FROM ProductBatchDetails(NOLOCK)
--SELECT COUNT(*) FROM ProductBatchDetails(NOLOCK)
--SELECT * FROM ProductBatchDetails(NOLOCK) WHERE PriceId>15
--SELECT COUNT(*) FROM ContractPricingMaster(NOLOCK)
--SELECT COUNT(*) FROM ContractPricingDetails(NOLOCK)
--SELECT * FROM DefaultPriceHistory
--SELECT * FROM ErrorLog
--23634-Batches in 25 Mins 10 Secs in SQL 2005
ROLLBACK TRANSACTION
*/
CREATE	PROCEDURE [dbo].[Proc_Cn2Cs_ProductBatch]
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-031

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ValidateSchemeAttributes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ValidateSchemeAttributes]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DELETE FROM ErrorLog
--SELECT * FROM ErrorLog
-- EXEC Proc_ValidateSchemeAttributes ''
CREATE PROCEDURE [dbo].[Proc_ValidateSchemeAttributes]
(
@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_ValidateSchemeAttributes
* PURPOSE: To Insert and Update Scheme Attributes
* CREATED: Boopathy.P on 18/12/2007
*********************************/
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
	SET @TabName = 'ETL_Prk_SchemeAttribute'
	SET @Po_ErrNo =0
	SET @iCnt=0

	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	
	DELETE FROM Etl_Prk_SchemeAttribute_Temp
	
	DECLARE Cur_SchemeAttr CURSOR
		FOR SELECT ISNULL([Company Scheme Code],'') AS [Company Scheme Code],ISNULL([Attribute Type],'') AS [Attribute Type],
		ISNULL([Attribute Master Code],'') AS [Attribute Master Code] FROM ETL_Prk_SchemeAttribute ORDER BY [Company Scheme Code],[Attribute Type]
	OPEN Cur_SchemeAttr
	FETCH NEXT FROM Cur_SchemeAttr INTO @SchCode,@AttrType,@AttrCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @iCnt=@iCnt+1
		SET @Taction = 2
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
				SET @ErrDesc = 'Attribute Code should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (1,@TabName,'Attribute Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		ELSE IF LTRIM(RTRIM(@AttrCode))<>''
		BEGIN
			IF LTRIM(RTRIM(@AttrType))=''
			BEGIN
				SET @ErrDesc = 'Attribute Type should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
					SET @ErrDesc = 'Company Scheme Code not found'
					INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
					
				END
				ELSE
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SelMode=SchemeLvlMode,@CombiId=CombiSch FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END	
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SelMode=SchemeLvlMode,@CombiId=CombiSch FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
					CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
					BEGIN
	
						IF NOT EXISTS(SELECT [Company Scheme Code] FROM ETL_Prk_SchemeMaster WHERE
						[Company Scheme Code]=LTRIM(RTRIM(@SchCode)))
						BEGIN
							SET @ErrDesc = 'Company Scheme Code not found'
							INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @CmpId=B.CmpId FROM ETL_Prk_SchemeMaster A INNER JOIN COMPANY B ON
							B.CmpCode=A.[Company Code] WHERE [Company Scheme Code]=LTRIM(RTRIM(@SchCode))
						END
	
					END
					ELSE
					BEGIN
	
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
						SET @ErrDesc = 'Salesman Code not found for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
						SET @ErrDesc = 'Route Code not found for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
						SET @ErrDesc = 'Route Village Code not found for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
						SET @ErrDesc = 'Category Level not found for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
						SET @ErrDesc = 'Value Class not found for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
						INSERT INTO Errorlog VALUES (1,@TabName,'Value Class',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=RtrClassId FROM RETAILERVALUECLASS WITH (NOLOCK) WHERE
						ValueClassCode=LTRIM(RTRIM(@AttrCode))
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
						SET @ErrDesc = 'Potential Class not found for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'RETAILER'
			BEGIN
				SET @AttrTypeId=8
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT RtrId FROM Retailer WITH (NOLOCK) WHERE
						RtrCode=LTRIM(RTRIM(@AttrCode)) AND RtrStatus=1)
					BEGIN
						SET @ErrDesc = 'Retailer not found for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
						INSERT INTO Errorlog VALUES (1,@TabName,'Retailer',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=RtrId FROM Retailer WITH (NOLOCK) WHERE
						RtrCode=LTRIM(RTRIM(@AttrCode)) AND RtrStatus=1
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'PRODUCT'
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
-- 							SET @ErrDesc = 'UDC Values not found'
-- 							INSERT INTO Errorlog VALUES (1,@TabName,'Product',@ErrDesc)
-- 							SET @Taction = 0
-- 							SET @Po_ErrNo =1
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
					SET @ErrDesc = 'BILL TYPE SHOULD BE(VAN SALES OR READY STOCK OR ORDER BOOKING) for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
						SET @ErrDesc = 'BILL MODE SHOULD BE(CASH OR CREDIT) for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
						SET @ErrDesc = 'RETAIER TYPE SHOULD BE(KEY OUTLET OR NON-KEY OUTLET) for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
						SET @ErrDesc = 'CLASS TYPE SHOULD BE(VALUE CLASSIFICATION OR POTENTIAL CLASSIFICATION) for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
						SET @ErrDesc = 'ROAD CONDITION SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
						SET @ErrDesc = 'INCOME LEVEL SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
						SET @ErrDesc = 'ACCEPTABILITY SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
						SET @ErrDesc = 'AWARENESS SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
						INSERT INTO Errorlog VALUES (1,@TabName,'AWARENESS',@ErrDesc)
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
						SET @ErrDesc = 'ROUTE TYPE SHOULD BE(SALES ROUTE OR DELIVERY ROUTE OR MERCHANDISING ROUTE) for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + '''' 
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
						SET @ErrDesc = 'LOCAL/UPCOUNTRY SHOULD BE(LOCAL ROUTE OR UPCOUNTRY ROUTE) for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
						SET @ErrDesc = 'VAN/NON VAN ROUTE SHOULD BE(VAN ROUTE OR NON VAN ROUTE) for Company scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
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
			EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
			SELECT @ChkCount=COUNT(*) FROM TempDepCheck
			IF @ChkCount > 0
			BEGIN
				SET @Taction = 0
			END
		END
		ELSE
		BEGIN
			IF @ConFig=1
			BEGIN
				SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				IF @SchLevelId <@SLevel
				BEGIN
					SELECT @EtlCnt=ISNULL(COUNT([Code]),0) FROM Etl_Prk_SchemeProduct A
					WHERE A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[TYPE])='PRODUCT'

-- 					SELECT @CmpCnt=COUNT([Code]) FROM Etl_Prk_SchemeProduct A
-- 					INNER JOIN ProductCategoryValue B ON A.[Code]=b.PrdCtgValCode
-- 					WHERE A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode))

					SELECT @CmpCnt=ISNULL(COUNT([Code]),0) FROM Etl_Prk_SchemeProduct A
					WHERE A.[Code] IN (SELECT b.PrdCtgValCode FROM ProductCategoryValue B) AND 
					A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[TYPE])='PRODUCT'
				END
				ELSE
				BEGIN
					SELECT @EtlCnt=ISNULL(COUNT([Code]),0) FROM Etl_Prk_SchemeProduct A
					WHERE A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[TYPE])='PRODUCT'

					SELECT @CmpCnt=ISNULL(COUNT([Code]),0) FROM Etl_Prk_SchemeProduct A
					WHERE A.[Code] IN (SELECT PrdDCode FROM Product)
					AND  A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode))AND UPPER(A.[TYPE])='PRODUCT'				
				END					
	
				IF @EtlCnt=@CmpCnt
				BEGIN
					SELECT @EtlCnt=COUNT([Product Code]) FROM Etl_Prk_SchemeSlabFreeDt A
					WHERE A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode))
	
					SELECT @CmpCnt=COUNT([Product Code]) FROM Etl_Prk_SchemeSlabFreeDt A
					INNER JOIN Product B ON A.[Product Code]=b.PrdCCode
					WHERE A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode))	

					IF @EtlCnt=@CmpCnt
					BEGIN
			
						IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL MODE' OR UPPER(LTRIM(RTRIM(@AttrType)))='BILL TYPE' OR UPPER(LTRIM(RTRIM(@AttrType)))= 'CATEGORY LEVEL VALUE'
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

						--->Added By Nanda on 09/09/2010
						IF UPPER(LTRIM(RTRIM(@AttrType)))= 'SALESMAN'
						BEGIN
							INSERT INTO Translog(strSql1) Values (@sSQL)
							INSERT INTO SchemeRetAttr(SchId,AttrType,AttrId,Availability,LastModBy,LastModDate,
							AuthId,AuthDate) VALUES(ISNULL(@GetKey,0),21,0,1,1,convert(varchar(10),getdate(),121),
							1,convert(varchar(10),getdate(),121))
						END
						--->Till Here				
					END		
					ELSE
					BEGIN	
					--	DELETE FROM Etl_Prk_SchemeAttribute_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					--	AND AttrType=@AttrTypeId
						INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag)
						VALUES (LTRIM(RTRIM(@SchCode)),@AttrTypeId,@AttrId,'N')

						--->Added By Nanda on 09/09/2010
						IF UPPER(LTRIM(RTRIM(@AttrType)))= 'SALESMAN'
						BEGIN
							INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag)
							VALUES (LTRIM(RTRIM(@SchCode)),21,0,'N')
						END
						--->Till Here				
					END
			
				END
				ELSE
				BEGIN	
					--DELETE FROM Etl_Prk_SchemeAttribute_Temp WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					--	AND AttrType=@AttrTypeId
					INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag)
					VALUES (LTRIM(RTRIM(@SchCode)),@AttrTypeId,@AttrId,'N')
			
					--->Added By Nanda on 09/09/2010
					IF UPPER(LTRIM(RTRIM(@AttrType)))= 'SALESMAN'
					BEGIN
						INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag)
						VALUES (LTRIM(RTRIM(@SchCode)),21,0,'N')
					END
					--->Till Here				
				END
					
			END
			ELSE
			BEGIN
				IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL MODE' OR UPPER(LTRIM(RTRIM(@AttrType)))='BILL TYPE' OR UPPER(LTRIM(RTRIM(@AttrType)))= 'CATEGORY LEVEL VALUE'
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
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-032

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ValidateSchemeMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ValidateSchemeMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Select *  from errorlog
-- exec [Proc_ValidateSchemeMaster] ''
CREATE                   PROCEDURE [dbo].[Proc_ValidateSchemeMaster]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_ValidateSchemeMaster
* PURPOSE: To Insert and Update records Of Scheme Master
* CREATED: Boopathy.P on 17/12/2007
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode 	AS VARCHAR(100)
	DECLARE @SchDesc 	AS VARCHAR(200)
	DECLARE @CmpCode 	AS VARCHAR(50)
	DECLARE @ClmAble 	AS VARCHAR(50)
	DECLARE @ClmAmtOn 	AS VARCHAR(50)
	DECLARE @ClmGrpCode	AS VARCHAR(50)
	DECLARE @SelnOn		AS VARCHAR(50)
	DECLARE @SelLvl		AS VARCHAR(50)
	DECLARE @SchType	AS VARCHAR(50)
	DECLARE @BatLvl		AS VARCHAR(50)
	DECLARE @FlxSch		AS VARCHAR(50)
	DECLARE @FlxCond	AS VARCHAR(50)
	DECLARE @CombiSch	AS VARCHAR(50)
	DECLARE @Range		AS VARCHAR(50)
	DECLARE @ProRata	AS VARCHAR(50)
	DECLARE @Qps		AS VARCHAR(50)
	DECLARE @QpsReset	AS VARCHAR(50)
	DECLARE @ApyQpsOn	AS VARCHAR(50)
	DECLARE @ForEvery	AS VARCHAR(50)
	DECLARE @SchStartDate	AS VARCHAR(50)
	DECLARE @SchEndDate	AS VARCHAR(50)
	DECLARE @SchBudget	AS VARCHAR(50)
	DECLARE @EditSch	AS VARCHAR(50)
	DECLARE @AdjDisSch	AS VARCHAR(50)
	DECLARE @SetDisMode	AS VARCHAR(50)
	DECLARE @CmpId		AS INT
	DECLARE @ClmGrpId	AS INT
	DECLARE @CmpPrdCtgId	AS INT
	DECLARE @ClmableId	AS INT
	DECLARE @ClmAmtOnId	AS INT
	DECLARE @SelMode	AS INT
	DECLARE @SchTypeId	AS INT
	DECLARE @BatId		AS INT
	DECLARE @FlexiId	AS INT
	DECLARE @FlexiConId	AS INT
	DECLARE @CombiId	AS INT
	DECLARE @RangeId	AS INT
	DECLARE @ProRateId	AS INT
	DECLARE @QPSId		AS INT
	DECLARE @QPSResetId	AS INT
	DECLARE @AdjustSchId	AS INT
	DECLARE @ApplySchId	AS INT
	DECLARE @ForEveryId	AS INT
	DECLARE @SettleSchId	AS INT
	DECLARE @EditSchId	AS INT
	DECLARE @ChkCount	AS INT		
	DECLARE @@EditSchId	AS INT
	DECLARE @ConFig		AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @SLevel		AS INT
	DECLARE @ErrDesc AS VARCHAR(1000)
	DECLARE @TabName AS VARCHAR(50)
	DECLARE @GetKey AS INT
	DECLARE @GetKeyStr AS NVARCHAR(200)
	DECLARE @Taction AS INT
	DECLARE @sSQL AS VARCHAR(4000)
	DECLARE @iCnt		AS INT
	SET @TabName = 'ETL_Prk_SchemeMaster'
	SET @Po_ErrNo =0
	SET @AdjustSchId=0
	SET @iCnt=0
	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	DECLARE Cur_SchMaster CURSOR
	FOR SELECT DISTINCT
			ISNULL([Company Scheme Code],'') AS [Company Scheme Code],
			ISNULL([Scheme Description],'') AS [Scheme Description],
			ISNULL([Company Code],'') AS [Company Code],
			ISNULL([Claimable],'') AS [Claimable],
			ISNULL([Claim Amount On],'') AS [Claim Amount On],
			ISNULL([Claim Group Code],'') AS [Claim Group Code],
			ISNULL([Selection On],'') AS [Selection On],
			ISNULL([Selection Level Value],'') AS [Selection Level Value],
			ISNULL([Scheme Type],'') AS [Scheme Type],
			ISNULL([Batch Level],'') AS [Batch Level],
			ISNULL([Flexi Scheme],'') AS [Flexi Scheme],
			ISNULL([Flexi Conditional],'') AS [Flexi Conditional],
			ISNULL([Combi Scheme],'') AS [Combi Scheme],
			ISNULL([Range],'') AS [Range],
			ISNULL([Pro - Rata],'') AS [Pro - Rata],
			ISNULL([Qps],'NO') AS [Qps],
			ISNULL([Qps Reset],'') AS [Qps Reset],
			ISNULL([Qps Based On],'') AS [Qps Based On],
			ISNULL([Allow For Every],'') AS [Allow For Every],
			ISNULL([Scheme Start Date],'') AS [Scheme Start Date],
			ISNULL([Scheme End Date],'') AS [Scheme End Date],
			ISNULL([Scheme Budget],'') AS [Scheme Budget],
			ISNULL([Allow Editing Scheme],'') AS [Allow Editing Scheme],
			ISNULL([Adjust Display Once],'0') AS [Adjust Display Once],
			ISNULL([Settle Display Through],'') AS [Settle Display Through]
			FROM ETL_Prk_SchemeMaster ORDER BY [Company Scheme Code]
	OPEN Cur_SchMaster
	FETCH NEXT FROM Cur_SchMaster INTO @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
	, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
	, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch, @SetDisMode	
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Taction = 2
		SET @iCnt=@iCnt+1
		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchDesc))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Description should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (2,@TabName,'Scheme Description',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@CmpCode))= ''
		BEGIN
			SET @ErrDesc = 'Company should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (3,@TabName,'Company',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ClmAble))= ''
		BEGIN
			SET @ErrDesc = 'Claimable should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (4,@TabName,'Claimable',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ClmAmtOn))= ''
		BEGIN
			SET @ErrDesc = 'Claim Amount On should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (5,@TabName,'Claim Amount On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SelnOn))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level Type should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (6,@TabName,'Scheme Level Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SelLvl))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Level should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (7,@TabName,'Scheme Level',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchType))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Type should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (8,@TabName,'Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@BatLvl))= ''
		BEGIN
			SET @ErrDesc = 'Batch Level should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (9,@TabName,'Batch Level',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@FlxSch))= ''
		BEGIN
			SET @ErrDesc = 'Flexi Scheme should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (10,@TabName,'Flexi Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@FlxCond))= ''
		BEGIN
			SET @ErrDesc = 'Flexi Scheme Type should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (11,@TabName,'Flexi Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@CombiSch))= ''
		BEGIN
			SET @ErrDesc = 'Combi Scheme should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (12,@TabName,'Combi Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@Range))= ''
		BEGIN
			SET @ErrDesc = 'Range should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (13,@TabName,'Range Based Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ProRata))= ''
		BEGIN
			SET @ErrDesc = 'Pro-Rata should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (14,@TabName,'Pro-Rata',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@Qps))= ''
		BEGIN
			SET @ErrDesc = 'QPS Scheme should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (15,@TabName,'QPS Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@QpsReset))= ''
		BEGIN
			SET @ErrDesc = 'QPS Reset should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (16,@TabName,'QPS Reset',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ApyQpsOn))= ''
		BEGIN
			SET @ErrDesc = 'Apply QPS Scheme Based On should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (17,@TabName,'Apply QPS Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SchStartDate))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Start Date should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (19,@TabName,'Start Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LEN(LTRIM(RTRIM(@SchStartDate)))<10
		BEGIN
			SET @ErrDesc = 'Scheme Start Date is not Date Format for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (20,@TabName,'Scheme Start Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF ISDATE(LTRIM(RTRIM(@SchStartDate))) = 0
		BEGIN
			SET @ErrDesc = 'Invalid Scheme Start Date for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (21,@TabName,'Scheme Start Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
-- 		ELSE IF LEN(LTRIM(RTRIM(@SchStartDate)))>10
-- 		BEGIN
-- 			SET @ErrDesc = 'Scheme Start Date is not Date Format'
-- 			INSERT INTO Errorlog VALUES (22,@TabName,'Scheme Start Date',@ErrDesc)
-- 			SET @Taction = 0
-- 			SET @Po_ErrNo =1
-- 		END
		ELSE IF LTRIM(RTRIM(@SchEndDate))= ''
		BEGIN
			SET @ErrDesc = 'Scheme End Date should not be blank for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (23,@TabName,'End Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LEN(LTRIM(RTRIM(@SchEndDate)))<10
		BEGIN
			SET @ErrDesc = 'Scheme End Date is not Date Format for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (24,@TabName,'Scheme End Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF ISDATE(LTRIM(RTRIM(@SchEndDate))) = 0
		BEGIN
			SET @ErrDesc = 'Invalid Scheme End Date for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (25,@TabName,'Scheme End Date',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
-- 		ELSE IF LEN(LTRIM(RTRIM(@SchEndDate)))>10
-- 		BEGIN
-- 			SET @ErrDesc = 'Scheme End Date is not Date Format'
-- 			INSERT INTO Errorlog VALUES (26,@TabName,'Scheme End Date',@ErrDesc)
-- 			SET @Taction = 0
-- 			SET @Po_ErrNo =1
-- 		END
		ELSE IF LTRIM(RTRIM(@EditSch))= ''
		BEGIN
			SET @ErrDesc = 'Allow Editing Scheme should not be blank for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (28,@TabName,'Editing Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SetDisMode))= ''
		BEGIN
			SET @ErrDesc = 'Settle Window Display Scheme should not be blank for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (30,@TabName,'Settle Window Display Scheme',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@SelnOn))= ''
		BEGIN
			SET @ErrDesc = 'Selection On should not be blank for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (30,@TabName,'Selction On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@SelnOn)))<> 'UDC') AND (UPPER(LTRIM(RTRIM(@SelnOn)))<> 'PRODUCT'))
		BEGIN
			SET @ErrDesc = 'Selection On should be (UDC OR PRODUCT) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (4,@TabName,'Selction On',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF ((UPPER(LTRIM(RTRIM(@ClmAble)))<> 'YES') AND (UPPER(LTRIM(RTRIM(@ClmAble)))<> 'NO'))
		BEGIN
			SET @ErrDesc = 'Claimable should be (YES OR NO) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (4,@TabName,'Claimable',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF (UPPER(LTRIM(RTRIM(@ClmAble)))= 'YES')
		BEGIN
			IF LTRIM(RTRIM(@ClmGrpCode))= ''
			BEGIN
				SET @ErrDesc = 'Claim Group Code should not be blank for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (28,@TabName,'Claim Group Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF (UPPER(LTRIM(RTRIM(@ClmAmtOn)))<> 'PURCHASE RATE' AND UPPER(LTRIM(RTRIM(@ClmAmtOn)))<> 'SELLING RATE')
		BEGIN
			SET @ErrDesc = 'Claimable Amount should be (PURCHASE RATE OR SELLING RATE) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (4,@TabName,'Claimable Amount',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		--PRINT @SchType
		IF (UPPER(LTRIM(RTRIM(@SchType)))<>'WINDOW DISPLAY' AND UPPER(LTRIM(RTRIM(@SchType)))<>'AMOUNT'
		   AND UPPER(LTRIM(RTRIM(@SchType)))<>'WEIGHT' AND UPPER(LTRIM(RTRIM(@SchType)))<>'QUANTITY')
		BEGIN
			SET @ErrDesc = 'Scheme Type should be (WINDOW DISPLAY OR AMOUNT OR WEIGHT OR QUANTITY) for Company Scheme Code '''+  LTRIM(RTRIM(@SchCode)) + ''''
			INSERT INTO Errorlog VALUES (4,@TabName,'Scheme Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF (UPPER(LTRIM(RTRIM(@SchType)))='WINDOW DISPLAY')
		BEGIN
			IF (UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' AND UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Batch Level should be (YES OR NO) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'Batch Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme should be (NO) for WINDOW DISPLAY SCHEME for Company Scheme Code '''  +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'Flexi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxCond)))<> 'UNCONDITIONAL')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme Type should be (UNCONDITIONAL) for WINDOW DISPLAY SCHEME for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'Flexi Scheme Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@CombiSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Combi Scheme should be (NO) for WINDOW DISPLAY SCHEME for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'Combi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Range)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Range should be (NO) for WINDOW DISPLAY SCHEME for Company Scheme Code '''+  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'Range',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@ProRata)))<> 'YES' AND UPPER(LTRIM(RTRIM(@ProRata)))<> 'NO'
			   AND UPPER(LTRIM(RTRIM(@ProRata)))<> 'ACTUAL')
			BEGIN
				SET @ErrDesc = 'Pro-Rata should be (YES OR NO OR ACTUAL) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'Pro-Rata',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Qps)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS should be (NO) for WINDOW DISPLAY SCHEME for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'QPS Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@QpsReset)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS Reset should be (NO)for WINDOW DISPLAY SCHEME for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'QPS Reset',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF LTRIM(RTRIM(@AdjDisSch))= ''
			BEGIN
				SET @ErrDesc = 'Adjust Window Display Scheme Only Once should not be blank for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (29,@TabName,'Adjust Window Display Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@SetDisMode)))<> 'CASH' AND UPPER(LTRIM(RTRIM(@SetDisMode)))<> 'CHEQUE')
			BEGIN
				SET @ErrDesc = 'Settle Window Display Should be (CASH OR CHEQUE) for Company Scheme Code ''' + LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (29,@TabName,'SETTLE WINDOW DISPLAY',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'DATE')
			BEGIN
				SET @ErrDesc = 'Apply QPS Scheme Should be (DATE) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (29,@TabName,'Apply QPS Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		ELSE IF (UPPER(LTRIM(RTRIM(@SchType)))='AMOUNT' AND UPPER(LTRIM(RTRIM(@SchType)))='WEIGHT'
			AND UPPER(LTRIM(RTRIM(@SchType)))='QUANTITY')
		BEGIN
			IF UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' OR UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO'
			BEGIN
				SET @ErrDesc = 'Batch Level should be (YES OR NO) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'Batch Level',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxSch)))<> 'YES' AND UPPER(LTRIM(RTRIM(@FlxSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme should be (YES OR NO) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'Flexi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxCond)))<> 'UNCONDITIONAL' AND UPPER(LTRIM(RTRIM(@FlxCond)))<> 'CONDITIONAL')
			BEGIN
				SET @ErrDesc = 'Flexi Scheme Type should be (UNCONDITIONAL OR CONDITIONAL) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'Flexi Scheme Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@FlxSch)))= 'NO')
			BEGIN
				IF (UPPER(LTRIM(RTRIM(@FlxCond)))= 'CONDITIONAL')
				BEGIN
					SET @ErrDesc = 'Flexi Scheme Type should be UNCONDITIONAL When Flexi Scheme is YES for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
					INSERT INTO Errorlog VALUES (4,@TabName,'Flexi Scheme Type',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@CombiSch)))<> 'YES' AND UPPER(LTRIM(RTRIM(@CombiSch)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Combi Scheme should be (YES OR NO) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'Combi Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Range)))<> 'YES' AND UPPER(LTRIM(RTRIM(@Range)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'Range should be (YES OR NO) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'Range',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@ProRata)))<> 'YES' AND UPPER(LTRIM(RTRIM(@ProRata)))<> 'NO'
			   OR UPPER(LTRIM(RTRIM(@ProRata)))<> 'ACTUAL')
			BEGIN
				SET @ErrDesc = 'Pro-Rata should be (YES OR NO OR ACTUAL) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'Pro-Rata',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
	
			ELSE IF (UPPER(LTRIM(RTRIM(@CombiSch)))<> 'YES')
			BEGIN
				IF (UPPER(LTRIM(RTRIM(@Range)))<> 'NO')
				BEGIN
					SET @ErrDesc = 'IF COMBI SCHEME is YES, Then RANGE should be (NO) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
					INSERT INTO Errorlog VALUES (4,@TabName,'Range',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF (UPPER(LTRIM(RTRIM(@ProRata)))<> 'NO')
				BEGIN
					SET @ErrDesc = 'IF COMBI SCHEME is YES, Then PRO-RATA should be (NO) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
					INSERT INTO Errorlog VALUES (4,@TabName,'Pro-Rata',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@Qps)))<> 'YES' AND UPPER(LTRIM(RTRIM(@Qps)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS should be (YES OR NO) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'QPS Scheme',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF (UPPER(LTRIM(RTRIM(@QpsReset)))<> 'YES' AND UPPER(LTRIM(RTRIM(@QpsReset)))<> 'NO')
			BEGIN
				SET @ErrDesc = 'QPS Reset should be (YES OR NO) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (4,@TabName,'QPS Reset',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE IF UPPER(LTRIM(RTRIM(@Qps)))= 'NO'
			BEGIN
				IF UPPER(LTRIM(RTRIM(@QpsReset)))= 'YES'
				BEGIN
					SET @ErrDesc = 'IF QPS SCHEME is NO, Then QPS Reset should be (NO) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
					INSERT INTO Errorlog VALUES (4,@TabName,'QPS Reset',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'DATE'
				BEGIN
					SET @ErrDesc = 'IF QPS SCHEME is NO then Apply QPS Scheme Should be (DATE) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
					INSERT INTO Errorlog VALUES (29,@TabName,'Apply QPS Scheme',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@Qps)))= 'YES'
			BEGIN
				IF UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'DATE' AND UPPER(LTRIM(RTRIM(@ApyQpsOn)))<> 'QUANTITY'
				BEGIN
					SET @ErrDesc = 'Apply QPS Scheme Should be (DATE OR QUANTITY) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
					INSERT INTO Errorlog VALUES (29,@TabName,'Apply QPS Scheme',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@SetDisMode)))<> 'CASH'
			BEGIN
				SET @ErrDesc = 'Settle Window Display Should be (CASH) for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (29,@TabName,'SETTLE WINDOW DISPLAY',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo = 0
		BEGIN
			IF NOT EXISTS(SELECT CmpId FROM Company WHERE CmpCode=LTRIM(RTRIM(@CmpCode)))
			BEGIN
				SET @ErrDesc = 'Company Not Found for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
				INSERT INTO Errorlog VALUES (11,@TabName,'Company',@ErrDesc)
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
			IF NOT EXISTS(SELECT SchId FROM SchemeMaster SM WHERE CMPID=@CmpId AND SM.CmpSchCode=LTRIM(RTRIM(@SchCode)))
			BEGIN
				SELECT @GetKey= dbo.Fn_GetPrimaryKeyInteger('SCHEMEMASTER','SchId',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
				SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('SCHEMEMASTER','SchCode',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))				
				SET @Taction = 2
				--PRINT @GetKey
			END
			ELSE
			BEGIN
				SELECT @GetKey=SchId,@GetKeyStr=SchCode FROM SchemeMaster WHERE CMPID=@CmpId AND CmpSchCode=LTRIM(RTRIM(@SchCode))
				SET @Taction = 1
			END
		END
		
		IF @Po_ErrNo = 0
		BEGIN
			IF UPPER(LTRIM(RTRIM(@ClmAble)))='YES'
			BEGIN
				IF NOT EXISTS(SELECT ClmGrpId FROM ClaimGroupMaster WHERE ClmGrpCode=LTRIM(RTRIM(@ClmGrpCode)))
				BEGIN
					SET @ErrDesc = 'Claim Group Not Found for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
					INSERT INTO Errorlog VALUES (11,@TabName,'Claim Group',@ErrDesc)
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
			IF UPPER(LTRIM(RTRIM(@SelnOn)))='PRODUCT'
			BEGIN
				IF NOT EXISTS(SELECT CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpId=@CmpId
					AND CmpPrdCtgName=UPPER(LTRIM(RTRIM(@SelLvl))) AND LevelName <> 'Level1')
				BEGIN
					SET @ErrDesc = 'Product Category Level Not Found for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
					INSERT INTO Errorlog VALUES (11,@TabName,'Product Category',@ErrDesc)
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
					SET @ErrDesc = 'Product Category Level Not Found for Company Scheme Code ''' +  LTRIM(RTRIM(@SchCode)) + ''''
					INSERT INTO Errorlog VALUES (11,@TabName,'Product Category',@ErrDesc)
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
			ELSE IF UPPER(LTRIM(RTRIM(@BatLvl)))= 'NO'
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
			
			IF UPPER(LTRIM(RTRIM(@CombiSch)))= 'YES'				SET @CombiId=1
			ELSE IF UPPER(LTRIM(RTRIM(@CombiSch)))= 'NO'
				SET @CombiId=0
			
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
				SET @EditSchId=1
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
			IF @Taction=1
			BEGIN
				EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
				SELECT @ChkCount=COUNT(*) FROM TempDepCheck
				IF @ChkCount > 0
				BEGIN
					UPDATE SCHEMEMASTER SET SchValidTill=LTRIM(RTRIM(@SchEndDate)),
					Budget=@SchBudget WHERE SchId=@GetKey
					SET @sSQL='UPDATE SCHEMEMASTER SET SchValidTill=' + CAST(LTRIM(RTRIM(@SchEndDate)) AS VARCHAR(10)) +
						  ',Budget=' + CAST(@SchBudget AS VARCHAR(10)) + 'WHERE SchId='+ CAST(@GetKey AS VARCHAR(10))
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE
				BEGIN
					DELETE FROM SchemeProducts WHERE SchId=@GetKey
					DELETE FROM SchemeRetAttr WHERE SchId=@GetKey
					DELETE FROM SchemeSlabCombiPrds WHERE SchId=@GetKey
					DELETE FROM SchemeSlabFrePrds WHERE SchId=@GetKey
					DELETE FROM SchemeSlabMultiFrePrds WHERE SchId=@GetKey
					DELETE FROM SchemeSlabs WHERE SchId=@GetKey
					SET @sSQL='DELETE FROM SchemeProducts WHERE SchId=' + CAST(@GetKey AS VARCHAR(10))
					INSERT INTO Translog(strSql1) Values (@sSQL)
					SET @sSQL='DELETE FROM SchemeRetAttr WHERE SchId=' + CAST(@GetKey AS VARCHAR(10))
					INSERT INTO Translog(strSql1) Values (@sSQL)
					SET @sSQL='DELETE FROM SchemeSlabCombiPrds WHERE SchId=' + CAST(@GetKey AS VARCHAR(10))
					INSERT INTO Translog(strSql1) Values (@sSQL)
					SET @sSQL='DELETE FROM SchemeSlabFrePrds WHERE SchId=' + CAST(@GetKey AS VARCHAR(10))
					INSERT INTO Translog(strSql1) Values (@sSQL)
					SET @sSQL='DELETE FROM SchemeSlabMultiFrePrds WHERE SchId=' + CAST(@GetKey AS VARCHAR(10))
					INSERT INTO Translog(strSql1) Values (@sSQL)
					SET @sSQL='DELETE FROM SchemeSlabs WHERE SchId=' + CAST(@GetKey AS VARCHAR(10))
					INSERT INTO Translog(strSql1) Values (@sSQL)
					
					UPDATE SCHEMEMASTER SET SchDsc=LTRIM(RTRIM(@SchDesc)),CmpId=@CmpId,
					Claimable=@ClmableId,ClmAmton=@ClmAmtOnId,ClmRefId=@ClmGrpId,
					SchLevelId=@CmpPrdCtgId,SchType=@SchTypeId,BatchLevel=@BatId,
					FlexiSch=@FlexiId,FlexiSchType=@FlexiConId,CombiSch=@CombiId,
					Range=@RangeId,ProRata=@ProRateId,QPS=@QPSId,QPSReset=@QPSResetId,
					SchValidFrom=LTRIM(RTRIM(@SchStartDate)),SchValidTill=LTRIM(RTRIM(@SchEndDate)),
					Budget=@SchBudget,ApyQPSSch=@ApplySchId,SetWindowDisp=@SettleSchId,
					SchemeLvlMode=@SelMode WHERE SchId=@GetKey
					SET @sSQL='UPDATE SCHEMEMASTER SET SchDsc=' + CAST(LTRIM(RTRIM(@SchDesc)) AS VARCHAR(50)) +
						  ',CmpId=' + CAST(@CmpId AS VARCHAR(10)) + ',Claimable=' + CAST(@ClmableId AS VARCHAR(10)) +
						  ',ClmAmton=' + CAST(@ClmAmtOnId AS VARCHAR(10)) + ',ClmRefId=' + CAST(@ClmGrpId AS VARCHAR(10)) +
						  ',SchLevelId=' + CAST(@CmpPrdCtgId AS VARCHAR(10)) + ',SchType=' + CAST(@SchTypeId AS VARCHAR(10)) +
						  ',BatchLevel=' + CAST(@BatId AS VARCHAR(10)) + ',FlexiSch=' + CAST(@FlexiId AS VARCHAR(10)) +
						  ',FlexiSchType=' + CAST(@FlexiConId AS VARCHAR(10)) + ',CombiSch=' + CAST(@CombiId AS VARCHAR(10)) +
						  ',Range=' + CAST(@RangeId AS VARCHAR(10)) + ',ProRata=' + CAST(@ProRateId AS VARCHAR(10)) +
						  ',QPS=' + CAST(@QPSId AS VARCHAR(10)) + ',QPSReset=' + CAST(@QPSResetId AS VARCHAR(10)) +
						  ',SchValidFrom=' + CAST(LTRIM(RTRIM(@SchStartDate)) AS VARCHAR(10)) + ',SchValidTill=' + CAST(LTRIM(RTRIM(@SchEndDate)) AS VARCHAR(10)) +
						  ',Budget='+ CAST(@SchBudget AS VARCHAR(10)) + ',ApyQPSSch='+ CAST(@ApplySchId AS VARCHAR(10)) +
						  ',SetWindowDisp=' + CAST(@SettleSchId AS VARCHAR(10)) + ',SchemeLvlMode=' + CAST(@SelMode AS VARCHAR(10)) +
						  ' WHERE SchId=' + CAST(@GetKey AS VARCHAR(10))
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
			END
			ELSE IF @Taction=2
			BEGIN
				IF @ConFig=1
				BEGIN
-- 					IF @SelMode=0
-- 					BEGIN
						SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
						IF @CmpPrdCtgId<@SLevel
						BEGIN
							SELECT @EtlCnt=ISNULL(COUNT([Code]),0) FROM Etl_Prk_SchemeProduct A
							WHERE A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[TYPE])='PRODUCT'
		
-- 							SELECT @CmpCnt=COUNT([Code]) FROM Etl_Prk_SchemeProduct A
-- 							INNER JOIN ProductCategoryValue B ON A.[Code]=b.PrdCtgValCode
-- 							WHERE A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode))
							SELECT @CmpCnt=ISNULL(COUNT([Code]),0) FROM Etl_Prk_SchemeProduct A
							WHERE A.[Code] IN (SELECT b.PrdCtgValCode FROM ProductCategoryValue B) AND
							A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[TYPE])='PRODUCT'
						END
						ELSE
						BEGIN
							SELECT @EtlCnt=ISNULL(COUNT([Code]),0) FROM Etl_Prk_SchemeProduct A
							WHERE A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[TYPE])='PRODUCT'
							SELECT @CmpCnt=ISNULL(COUNT([Code]),0) FROM Etl_Prk_SchemeProduct A
							WHERE A.[Code] IN (SELECT PrdDCode FROM Product)
							AND  A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode)) AND UPPER(A.[TYPE])='PRODUCT'
						END
							IF @EtlCnt=@CmpCnt
							BEGIN
	
								SELECT @EtlCnt=COUNT([Product Code]) FROM Etl_Prk_SchemeSlabFreeDt A (NOLOCK)
								WHERE A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode))
		
								SELECT @CmpCnt=COUNT([Product Code]) FROM Etl_Prk_SchemeSlabFreeDt A (NOLOCK)
								INNER JOIN Product B ON A.[Product Code]=b.PrdCCode
								WHERE A.[Company Scheme Code]=LTRIM(RTRIM(@SchCode))
								IF @EtlCnt=@CmpCnt
								BEGIN
									INSERT INTO SchemeMaster(SchId,SchCode,SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
									CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
									ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
									PurofEvery,ApyQPSSch,SetWindowDisp,Availability,LastModBy,LastModDate,AuthId,
									AuthDate,EditScheme,SchemeLvlMode,MasterType,ApplyOnMRPSelRte,ApplyOnTax,BudgetAllocationNo,
									AllowPrdSelc,ExcludeDM,DisApproval,SchBasedOn,Download,FBM) 
									VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
									LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
									@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
									@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),1,@SchBudget,@AdjustSchId,@ForEveryId,
									@ApplySchId,@SettleSchId,1,1,convert(varchar(10),getdate(),121),1,
									convert(varchar(10),getdate(),121),@EditSchId,@SelMode,1,2,1,'',0,0,0,1,1,0)
					
									SET @sSQL='INSERT INTO SchemeMaster(SchId,SchCode,SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
									CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
									ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
									PurofEvery,ApyQPSSch,SetWindowDisp,Availability,LastModBy,LastModDate,AuthId,
									AuthDate,EditScheme,SchemeLvlMode,MasterType,ApplyOnMRPSelRte,ApplyOnTax,BudgetAllocationNo,AllowPrdSelc,ExcludeDM) VALUES ('+ CAST(@GetKey AS VARCHAR(10)) + ',' +
									CAST(LTRIM(RTRIM(@GetKeyStr)) AS VARCHAR(50)) + ',' +  CAST(LTRIM(RTRIM(@SchDesc)) AS VARCHAR(50)) +
									',' + CAST(@CmpId AS VARCHAR(10)) + ',' +  CAST(@ClmableId AS VARCHAR(10)) + ',' +
									CAST(@ClmAmtOnId AS VARCHAR(10)) + ',' + CAST(@ClmGrpId AS VARCHAR(10)) + ',' + LTRIM(RTRIM(@SchCode))+',' +
									CAST(@CmpPrdCtgId AS VARCHAR(10)) + ',' + CAST(@SchTypeId AS VARCHAR(10)) + ',' +
									CAST(@BatId AS VARCHAR(10)) + ',' + CAST(@FlexiId AS VARCHAR(10)) + ',' +
									CAST(@FlexiConId AS VARCHAR(10)) + ',' + CAST(@CombiId AS VARCHAR(10)) + ',' +
									CAST(@RangeId AS VARCHAR(10)) + ',' + CAST(@ProRateId AS VARCHAR(10)) + ',' +
									CAST(@QPSId AS VARCHAR(10))+ ',' + CAST(@QPSResetId AS VARCHAR(10)) + ',' +
									CAST(LTRIM(RTRIM(@SchStartDate)) AS VARCHAR(10)) + ',' + CAST(LTRIM(RTRIM(@SchEndDate)) AS VARCHAR(10)) + ',1,' +
									CAST(@SchBudget AS VARCHAR(10))+ ',' + CAST(@AdjustSchId AS VARCHAR(10)) + ',' +
									CAST(@ForEveryId AS VARCHAR(10)) + ',' + CAST(@ApplySchId AS VARCHAR(10)) + ',' +
									CAST(@SettleSchId AS VARCHAR(10)) + ',1,1,''' + CONVERT(varchar(10),GETDATE(),121) + ''',1,''' +
									CONVERT(varchar(10),GETDATE(),121) + ''',' + CAST(@EditSchId AS VARCHAR(10)) + ',' + CAST(@SelMode AS VARCHAR(10)) + ',1,2,1,'''',0,0)'
									INSERT INTO Translog(strSql1) Values (@sSQL)
									UPDATE counters SET currvalue = currvalue+1  WHERE
									tabname = 'SCHEMEMASTER' and fldname = 'SchId'
									SET @sSQL='UPDATE counters SET currvalue = currvalue + 1 where tabname = ''SCHEMEMASTER''
										  and fldname = ''SchId'''
					
									INSERT INTO Translog(strSql1) Values (@sSQL)
									
									UPDATE counters SET currvalue = currvalue+1  WHERE
									tabname = 'SCHEMEMASTER' and fldname = 'SchCode'
									SET @sSQL='UPDATE counters SET currvalue = currvalue + 1 where tabname = ''SCHEMEMASTER''
										  and fldname = ''SchCode'''
									INSERT INTO Translog(strSql1) Values (@sSQL)
								END
								ELSE
								BEGIN

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
									PurofEvery,ApyQPSSch,SetWindowDisp,EditScheme,SchemeLvlMode,UpLoadFlag) VALUES
									(LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
									@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
									@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),1,@SchBudget,@AdjustSchId,@ForEveryId,
									@ApplySchId,@SettleSchId,@EditSchId,@SelMode,'N')
					
									SET @sSQL='INSERT INTO ETL_Prk_SchemeMaster_Temp(SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
									CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
									ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
									PurofEvery,ApyQPSSch,SetWindowDisp,EditScheme,SchemeLvlMode,UpLoadFlag) VALUES ('+  CAST(LTRIM(RTRIM(@SchDesc)) AS VARCHAR(50)) +
									',' + CAST(@CmpId AS VARCHAR(10)) + ',' +  CAST(@ClmableId AS VARCHAR(10)) + ',' +
									CAST(@ClmAmtOnId AS VARCHAR(10)) + ',' + CAST(@ClmGrpId AS VARCHAR(10)) + ',' + LTRIM(RTRIM(@SchCode))+',' +
									CAST(@CmpPrdCtgId AS VARCHAR(10)) + ',' + CAST(@SchTypeId AS VARCHAR(10)) + ',' +
									CAST(@BatId AS VARCHAR(10)) + ',' + CAST(@FlexiId AS VARCHAR(10)) + ',' +
									CAST(@FlexiConId AS VARCHAR(10)) + ',' + CAST(@CombiId AS VARCHAR(10)) + ',' +									CAST(@RangeId AS VARCHAR(10)) + ',' + CAST(@ProRateId AS VARCHAR(10)) + ',' +
									CAST(@QPSId AS VARCHAR(10))+ ',' + CAST(@QPSResetId AS VARCHAR(10)) + ',' +
									CAST(LTRIM(RTRIM(@SchStartDate)) AS VARCHAR(10)) + ',' + CAST(LTRIM(RTRIM(@SchEndDate)) AS VARCHAR(10)) + ',1,' +
									CAST(@SchBudget AS VARCHAR(10))+ ',' + CAST(@AdjustSchId AS VARCHAR(10)) + ',' +
									CAST(@ForEveryId AS VARCHAR(10)) + ',' + CAST(@ApplySchId AS VARCHAR(10)) + ',' +
									CAST(@SettleSchId AS VARCHAR(10)) + ',' + CAST(@EditSchId AS VARCHAR(10)) + ',' + CAST(@SelMode AS VARCHAR(10)) + ',''N'')'
									INSERT INTO Translog(strSql1) Values (@sSQL)
								END
							END
							ELSE
							BEGIN
	
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
								PurofEvery,ApyQPSSch,SetWindowDisp,EditScheme,SchemeLvlMode,UpLoadFlag) VALUES
								(LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
								@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
								@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),1,@SchBudget,@AdjustSchId,@ForEveryId,
								@ApplySchId,@SettleSchId,@EditSchId,@SelMode,'N')
				
								SET @sSQL='INSERT INTO ETL_Prk_SchemeMaster_Temp(SchDsc,CmpId,Claimable,ClmAmton,ClmRefId,
								CmpSchCode,SchLevelId,SchType,BatchLevel,FlexiSch,FlexiSchType,CombiSch,Range,
								ProRata,QPS,QPSReset,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,
								PurofEvery,ApyQPSSch,SetWindowDisp,EditScheme,SchemeLvlMode,UpLoadFlag) VALUES ('+  CAST(LTRIM(RTRIM(@SchDesc)) AS VARCHAR(50)) +
								',' + CAST(@CmpId AS VARCHAR(10)) + ',' +  CAST(@ClmableId AS VARCHAR(10)) + ',' +
								CAST(@ClmAmtOnId AS VARCHAR(10)) + ',' + CAST(@ClmGrpId AS VARCHAR(10)) + ',' + LTRIM(RTRIM(@SchCode))+',' +
								CAST(@CmpPrdCtgId AS VARCHAR(10)) + ',' + CAST(@SchTypeId AS VARCHAR(10)) + ',' +
								CAST(@BatId AS VARCHAR(10)) + ',' + CAST(@FlexiId AS VARCHAR(10)) + ',' +
								CAST(@FlexiConId AS VARCHAR(10)) + ',' + CAST(@CombiId AS VARCHAR(10)) + ',' +
								CAST(@RangeId AS VARCHAR(10)) + ',' + CAST(@ProRateId AS VARCHAR(10)) + ',' +
								CAST(@QPSId AS VARCHAR(10))+ ',' + CAST(@QPSResetId AS VARCHAR(10)) + ',' +
								CAST(LTRIM(RTRIM(@SchStartDate)) AS VARCHAR(10)) + ',' + CAST(LTRIM(RTRIM(@SchEndDate)) AS VARCHAR(10)) + ',1,' +
								CAST(@SchBudget AS VARCHAR(10))+ ',' + CAST(@AdjustSchId AS VARCHAR(10)) + ',' +
								CAST(@ForEveryId AS VARCHAR(10)) + ',' + CAST(@ApplySchId AS VARCHAR(10)) + ',' +
								CAST(@SettleSchId AS VARCHAR(10)) + ',' + CAST(@EditSchId AS VARCHAR(10)) + ',' + CAST(@SelMode AS VARCHAR(10)) + ',''N'')'
								INSERT INTO Translog(strSql1) Values (@sSQL)
							END							
				END
			END
		END
	SET @Po_ErrNo =0
		FETCH NEXT FROM Cur_SchMaster INTO  @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
		, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
		, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch, @SetDisMode	
	END
	CLOSE Cur_SchMaster
	DEALLOCATE Cur_SchMaster
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-033

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
		ISNULL(SUM(FlatAmount),0) AS SchemeAmount,ISNULL(A.DiscPer,0) AS SchemeDiscount,
		ISNULL(E.Points,0) As Points,D.FlxDisc,D.FlxValueDisc,D.FlxFreePrd,D.FlxGiftPrd,D.FlxPoints,0 as FreePrdId,
		0 as FreePrdBatId,0 as FreeToBeGiven,0 As GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,B.NoOfTimes,
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,1 as LineType,A.PrdId,A.PrdBatId
		FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceSchemeHd B
		ON A.SchId = B.SchId AND A.SlabId = B.SlabId AND B.SalId = A.SalId AND A.SchType=B.SchType
		INNER JOIN SchemeMaster C ON B.SchId = C.SchId AND A.SchId = C.SchId
		INNER JOIN SchemeSlabs D ON B.SchId = D.SchId AND B.SlabId = D.SlabId
		LEFT OUTER JOIN SalesInvoiceSchemeDtPoints E ON E.SalId = A.SalId
		AND A.SchId = E.SchId AND A.SlabId = E.SlabId AND A.SchType=E.SchType
		WHERE A.SalId = @Pi_SalId AND A.SchId IN (SELECT SchId FROM SchemeAnotherPrdHd) 
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
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,2 as LineType,0,0
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
		1 as IsSelected,Budget As SchBudget,0 as BudgetUtilized,3 as LineType,0,0
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
	RETURN
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-034

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBTBillTemplate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBTBillTemplate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_RptBTBillTemplate]
(
	@Pi_UsrId Int = 1,
	@Pi_Type INT,
	@Pi_InvDC INT
)
AS
/*********************************
* PROCEDURE		: Proc_RptBTBillTemplate
* PURPOSE		: To Get the Bill Details 
* CREATED		: Nandakumar R.G
* CREATED DATE	: 29/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @FROMBillId AS  VARCHAR(25)
	DECLARE @ToBillId   AS  VARCHAR(25)
	DECLARE @Cnt AS INT
	DECLARE @TempSalId TABLE
	(
		SalId INT
	)
	DECLARE  @RptBillTemplate Table
	(
		[Base Qty] numeric(38,0),
		[Batch Code] nvarchar(50),
		[Batch Expiry Date] datetime,
		[Batch Manufacturing Date] datetime,
		[Batch MRP] numeric(38,2),
		[Batch Selling Rate] numeric(38,2),
		[Bill Date] datetime,
		[Bill Doc Ref. Number] nvarchar(50),
		[Bill Mode] tinyint,
		[Bill Type] tinyint,
		[CD Disc Base Qty Amount] numeric(38,2),
		[CD Disc Effect Amount] numeric(38,2),
		[CD Disc Header Amount] numeric(38,2),
		[CD Disc LineUnit Amount] numeric(38,2),
		[CD Disc Qty Percentage] numeric(38,2),
		[CD Disc Unit Percentage] numeric(38,2),
		[CD Disc UOM Amount] numeric(38,2),
		[CD Disc UOM Percentage] numeric(38,2),
		[Company Address1] nvarchar(50),
		[Company Address2] nvarchar(50),
		[Company Address3] nvarchar(50),
		[Company Code] nvarchar(20),
		[Company Contact Person] nvarchar(100),
		[Company EmailId] nvarchar(50),
		[Company Fax Number] nvarchar(50),
		[Company Name] nvarchar(100),
		[Company Phone Number] nvarchar(50),
		[Contact Person] nvarchar(50),
		[CST Number] nvarchar(50),
		[DB Disc Base Qty Amount] numeric(38,2),
		[DB Disc Effect Amount] numeric(38,2),
		[DB Disc Header Amount] numeric(38,2),
		[DB Disc LineUnit Amount] numeric(38,2),
		[DB Disc Qty Percentage] numeric(38,2),
		[DB Disc Unit Percentage] numeric(38,2),
		[DB Disc UOM Amount] numeric(38,2),
		[DB Disc UOM Percentage] numeric(38,2),
		[DC DATE] DATETIME,
		[DC NUMBER] nvarchar(100),
		[Delivery Boy] nvarchar(50),
		[Delivery Date] datetime,
		[Deposit Amount] numeric(38,2),
		[Distributor Address1] nvarchar(50),
		[Distributor Address2] nvarchar(50),
		[Distributor Address3] nvarchar(50),
		[Distributor Code] nvarchar(20),
		[Distributor Name] nvarchar(50),
		[Drug Batch Description] nvarchar(50),
		[Drug Licence Number 1] nvarchar(50),
		[Drug Licence Number 2] nvarchar(50),
		[Drug1 Expiry Date] DateTime,
		[Drug2 Expiry Date] DateTime,
		[EAN Code] varchar(50),
		[EmailID] nvarchar(50),
		[Geo Level] nvarchar(50),
		[Interim Sales] tinyint,
		[Licence Number] nvarchar(50),
		[Line Base Qty Amount] numeric(38,2),
		[Line Base Qty Percentage] numeric(38,2),
		[Line Effect Amount] numeric(38,2),
		[Line Unit Amount] numeric(38,2),
		[Line Unit Percentage] numeric(38,2),
		[Line UOM1 Amount] numeric(38,2),
		[Line UOM1 Percentage] numeric(38,2),
		[LST Number] nvarchar(50),
		[Manual Free Qty] int,
		[Order Date] datetime,
		[Order Number] nvarchar(50),
		[Pesticide Expiry Date] DateTime,
		[Pesticide Licence Number] nvarchar(50),
		[PhoneNo] nvarchar(50),
		[PinCode] int,
		[Product Code] nvarchar(50),
		[Product Name] nvarchar(200),
		[Product Short Name] nvarchar(100),
		[Product SL No] Int,
		[Product Type] int,
		[Remarks] nvarchar(200),
		[Retailer Address1] nvarchar(100),
		[Retailer Address2] nvarchar(100),
		[Retailer Address3] nvarchar(100),
		[Retailer Code] nvarchar(50),
		[Retailer ContactPerson] nvarchar(100),
		[Retailer Coverage Mode] tinyint,
		[Retailer Credit Bills] int,
		[Retailer Credit Days] int,
		[Retailer Credit Limit] numeric(38,2),
		[Retailer CSTNo] nvarchar(50),
		[Retailer Deposit Amount] numeric(38,2),
		[Retailer Drug ExpiryDate] datetime,
		[Retailer Drug License No] nvarchar(50),
		[Retailer EmailId] nvarchar(100),
		[Retailer GeoLevel] nvarchar(50),
		[Retailer License ExpiryDate] datetime,
		[Retailer License No] nvarchar(50),
		[Retailer Name] nvarchar(150),
		[Retailer OffPhone1] nvarchar(50),
		[Retailer OffPhone2] nvarchar(50),
		[Retailer OnAccount] numeric(38,2),
		[Retailer Pestcide ExpiryDate] datetime,
		[Retailer Pestcide LicNo] nvarchar(50),
		[Retailer PhoneNo] nvarchar(50),
		[Retailer Pin Code] nvarchar(50),
		[Retailer ResPhone1] nvarchar(50),
		[Retailer ResPhone2] nvarchar(50),
		[Retailer Ship Address1] nvarchar(100),
		[Retailer Ship Address2] nvarchar(100),
		[Retailer Ship Address3] nvarchar(100),
		[Retailer ShipId] int,
		[Retailer TaxType] tinyint,
		[Retailer TINNo] nvarchar(50),
		[Retailer Village] nvarchar(100),
		[Route Code] nvarchar(50),
		[Route Name] nvarchar(50),
		[Sales Invoice Number] nvarchar(50),
		[SalesInvoice ActNetRateAmount] numeric(38,2),
		[SalesInvoice CDPer] numeric(9,6),
		[SalesInvoice CRAdjAmount] numeric(38,2),
		[SalesInvoice DBAdjAmount] numeric(38,2),
		[SalesInvoice GrossAmount] numeric(38,2),
		[SalesInvoice Line Gross Amount] numeric(38,2),
		[SalesInvoice Line Net Amount] numeric(38,2),
		[SalesInvoice MarketRetAmount] numeric(38,2),
		[SalesInvoice NetAmount] numeric(38,2),
		[SalesInvoice NetRateDiffAmount] numeric(38,2),
		[SalesInvoice OnAccountAmount] numeric(38,2),
		[SalesInvoice OtherCharges] numeric(38,2),
		[SalesInvoice RateDiffAmount] numeric(38,2),
		[SalesInvoice ReplacementDiffAmount] numeric(38,2),
		[SalesInvoice RoundOffAmt] numeric(38,2),
		[SalesInvoice TotalAddition] numeric(38,2),
		[SalesInvoice TotalDeduction] numeric(38,2),
		[SalesInvoice WindowDisplayAmount] numeric(38,2),
		[SalesMan Code] nvarchar(50),
		[SalesMan Name] nvarchar(50),
		[SalId] int,
		[Sch Disc Base Qty Amount] numeric(38,2),
		[Sch Disc Effect Amount] numeric(38,2),
		[Sch Disc Header Amount] numeric(38,2),
		[Sch Disc LineUnit Amount] numeric(38,2),
		[Sch Disc Qty Percentage] numeric(38,2),
		[Sch Disc Unit Percentage] numeric(38,2),
		[Sch Disc UOM Amount] numeric(38,2),
		[Sch Disc UOM Percentage] numeric(38,2),
		[Scheme Points] numeric(38,2),
		[Spl. Disc Base Qty Amount] numeric(38,2),
		[Spl. Disc Effect Amount] numeric(38,2),
		[Spl. Disc Header Amount] numeric(38,2),
		[Spl. Disc LineUnit Amount] numeric(38,2),
		[Spl. Disc Qty Percentage] numeric(38,2),
		[Spl. Disc Unit Percentage] numeric(38,2),
		[Spl. Disc UOM Amount] numeric(38,2),
		[Spl. Disc UOM Percentage] numeric(38,2),
		[Tax 1] numeric(38,2),
		[Tax 2] numeric(38,2),
		[Tax 3] numeric(38,2),
		[Tax 4] numeric(38,2),
		[Tax Amount1] numeric(38,2),
		[Tax Amount2] numeric(38,2),
		[Tax Amount3] numeric(38,2),
		[Tax Amount4] numeric(38,2),
		[Tax Amt Base Qty Amount] numeric(38,2),
		[Tax Amt Effect Amount] numeric(38,2),
		[Tax Amt Header Amount] numeric(38,2),
		[Tax Amt LineUnit Amount] numeric(38,2),
		[Tax Amt Qty Percentage] numeric(38,2),
		[Tax Amt Unit Percentage] numeric(38,2),
		[Tax Amt UOM Amount] numeric(38,2),
		[Tax Amt UOM Percentage] numeric(38,2),
		[Tax Type] tinyint,
		[TIN Number] nvarchar(50),
		[Uom 1 Desc] nvarchar(50),
		[Uom 1 Qty] int,
		[Uom 2 Desc] nvarchar(50),
		[Uom 2 Qty] int,
		[Vehicle Name] nvarchar(50),
		UsrId int,
		Visibility tinyint
	)
	IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplate]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
	DROP TABLE [RptBillTemplate]
	TRUNCATE TABLE RptSELECTedBills
	IF @Pi_Type=1
	BEGIN
		INSERT INTO @TempSalId
		SELECT SelValue FROM ReportFilterDt
		WHERE RptId = 16 AND SelId = 34
		INSERT INTO RptSELECTedBills
		SELECT SalId FROM @TempSalId
	END
	ELSE
	BEGIN
		IF @Pi_InvDC=1
		BEGIN
			DECLARE @FROMId INT
			DECLARE @ToId INT
			DECLARE @FROMSeq INT
			DECLARE @ToSeq INT
			SELECT @FROMId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=14
			SELECT @ToId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=15
			SELECT @FROMSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@FROMId
			SELECT @ToSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@ToId
			
			INSERT INTO RptSELECTedBills
			SELECT SalId FROM SalInvoiceDeliveryChallan WHERE SeqNo BETWEEN @FROMSeq AND @ToSeq
		END
		ELSE
		BEGIN
			SELECT @FROMBillId=SelValue FROM ReportFilterDt WHERE RptId = 16 AND SelId = 14
			SELECT @ToBillId=SelValue FROM ReportFilterDt WHERE RptId = 16 AND SelId = 15
			INSERT INTO RptSELECTedBills
			SELECT SalId FROM SalesINvoice(NOLOCK) WHERE SalId BETWEEN @FROMBillId AND @ToBillId
		END
	END
	IF @Pi_Type=1
	BEGIN
		INSERT INTO @RptBillTemplate
		SELECT DISTINCT BaseQty,PrdBatCode,ExpDate,MnfDate,MRP,[Selling Rate],SalInvDate,SalInvRef,BillMode,BillType,
		[CD Disc_Amount_Dt],[CD Disc_EffectAmt_Dt],[CD Disc_HD],[CD Disc_UnitAmt_Dt],[CD Disc_QtyPerc_Dt],[CD Disc_UnitPerc_Dt],[CD Disc_UomAmt_Dt],
		[CD Disc_UomPerc_Dt],Address1,Address2,Address3,CmpCode,ContactPerson,EmailId,FaxNumber,CmpName,PhoneNumber,D_ContactPerson,CSTNo,
		[DB Disc_Amount_Dt],[DB Disc_EffectAmt_Dt],[DB Disc_HD],[DB Disc_UnitAmt_Dt],[DB Disc_QtyPerc_Dt],[DB Disc_UnitPerc_Dt],[DB Disc_UomAmt_Dt],
		[DB Disc_UomPerc_Dt],DCDate,DCNo,DlvBoyName,SalDlvDate,DepositAmt,DistributorAdd1,DistributorAdd2,DistributorAdd3,DistributorCode,
		DistributorName,DrugBatchDesc,DrugLicNo1,DrugLicNo2,Drug1ExpiryDate,Drug2ExpiryDate,EANCode,D_EmailID,D_GeoLevelName,InterimSales,LicNo,
		LineBaseQtyAmount,LineBaseQtyPerc,LineEffectAmount,LineUnitamount,LineUnitPerc,LineUom1Amount,LineUom1Perc,LSTNo,SalManFreeQty,OrderDate,
		OrderKeyNo,PestExpiryDate,PestLicNo,PhoneNo,PinCode,PrdCCode,PrdName,PrdShrtName,SLNo,PrdType,Remarks,RtrAdd1,RtrAdd2,RtrAdd3,RtrCode,
		RtrContactPerson,RtrCovMode,RtrCrBills,RtrCrDays,RtrCrLimit,RtrCSTNo,RtrDepositAmt,RtrDrugExpiryDate,RtrDrugLicNo,RtrEmailId,
		GeoLevelName,RtrLicExpiryDate,RtrLicNo,RtrName,RtrOffPhone1,RtrOffPhone2,RtrOnAcc,RtrPestExpiryDate,RtrPestLicNo,RtrPhoneNo,RtrPinNo,
		RtrResPhone1,RtrResPhone2,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipId,RtrTaxType,RtrTINNo,VillageName,RMCode,RMName,SalInvNo,
		SalActNetRateAmount,SalCDPer,CRAdjAmount,DBAdjAmount,SalGrossAmount,PrdGrossAmountAftEdit,PrdNetAmount,MarketRetAmount,SalNetAmt,
		SalNetRateDiffAmount,OnAccountAmount,OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,
		WindowDisplayamount,SMCode,SMName,SalId,[Sch Disc_Amount_Dt],[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],
		[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],
		[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],
		Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],
		[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,
		Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility
		FROM
		(
			SELECT DisDt.*,RepAll.*
			FROM
			(
				SELECT D.DistributorCode,D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3, D.PinCode,D.PhoneNo,
				D.ContactPerson D_ContactPerson,D.EmailID D_EmailID,D.TaxType,D.TINNo,D.DepositAmt,GL.GeoLevelName D_GeoLevelName,
				D.CSTNo,D.LSTNo,D.LicNo,D.DrugLicNo1,D.Drug1ExpiryDate,D.DrugLicNo2,D.Drug2ExpiryDate,D.PestLicNo , D.PestExpiryDate
				FROM Distributor D WITH (NOLOCK)
				LEFT OUTER JOIN Geography G WITH (NOLOCK) ON D.GeoMainId = G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL WITH (NOLOCK) ON G.GeoLevelId = GL.GeoLevelId
			) DisDt ,
			(
				SELECT RepHD.*,RepDt.* FROM
				(
					SELECT SalesInv.* , RtrDt.*, HDAmt.* FROM
					(
						SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
						RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,
						SalRateDiffAmount,SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,
						Replacementdiffamount,TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,
						SalRoundOffAmt,V.VehicleId,V.VehicleCode,D.DlvBoyId , D.DlvBoyName FROM SalesInvoice SI WITH (NOLOCK)
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					) SalesInv
					LEFT OUTER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,
						R.RtrCrLimit,R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,
						GL.GeoLevelName,RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2 , R.RtrOffPhone1, R.RtrOffPhone2, R.RtrOnAcc FROM Retailer R WITH (NOLOCK)
						INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK) WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					LEFT OUTER JOIN
					(
						SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
						FROM SalesInvoice SI
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D') D ON SI.SalId = D.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E') E ON SI.SalId = E.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F') F ON SI.SalId = F.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G') G ON SI.SalId = G.SalId
						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H') H ON SI.SalId = H.SalId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					)HDAmt ON SalesInv.SalIdHD = HDAmt.SalId
				) RepHD
				LEFT OUTER JOIN
				(
					SELECT SalesInvPrd.*,LiAmt.*,LNUOM.*,BATPRC.MRP,BATPRC.[Selling Rate]
					FROM
					(
						SELECT SPR.*,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,
							U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,SIP.Uom2Qty,SIP.BaseQty,
							SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,BPT.Tax3Perc,
							BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
							FROM SalesInvoiceProduct SIP WITH (NOLOCK)
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId
							INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.SchId,LW.slabId,LW.PrdId, LW.PrdBatId, PO.Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								LEFT OUTER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId AND LW.SchId = PO.SchId AND
								--LW.SlabId = PO.SlabId
								LW.SlabId = PO.SlabId AND LW.PrdId=PO.PrdId AND LW.PrdBatId=PO.PrdBatId 
								WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills)
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
--							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
--							P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,'0' Uom1Qty,
--							'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
--							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
--							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
--							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
--							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,'0' Uom1Qty,
							'0' UOM2,'0' Uom2Qty,SUM(SIP.FreeQty) BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							GROUP BY SIP.SalId,SIP.FreePrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.FreePrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,SIP.FreePriceId
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax4Amount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
--							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
--							P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
--							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
--							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
--							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
--							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
--							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SUM(SIP.GiftQty) AS BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							GROUP BY SIP.SalId,SIP.GiftPrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,SIP.GiftPriceId
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt]
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
							FROM View_SalInvLineAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1
					AND SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						FROM SalesInvoiceProduct WITH (NOLOCK)
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						SELECT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
						FROM
						(
							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
							FROM ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1 )
						) MRP
						LEFT OUTER JOIN
						(
						SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
						FROM ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
						WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1 )
						) SelRtr ON MRP.PrdId = SelRtr.PrdId AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId
						AND MRP.PriceId=SelRtr.PriceId
					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  WHERE SalId IN (SELECT SalId FROM @TempSalId)
	END
	ELSE
	BEGIN
		INSERT INTO @RptBillTemplate
		SELECT DISTINCT BaseQty,PrdBatCode,ExpDate,MnfDate,MRP,[Selling Rate],SalInvDate,SalInvRef,BillMode,BillType,[CD Disc_Amount_Dt],
		[CD Disc_EffectAmt_Dt],[CD Disc_HD],[CD Disc_UnitAmt_Dt],[CD Disc_QtyPerc_Dt],[CD Disc_UnitPerc_Dt],[CD Disc_UomAmt_Dt],[CD Disc_UomPerc_Dt],
		Address1,Address2,Address3,CmpCode,ContactPerson,EmailId,FaxNumber,CmpName,PhoneNumber,D_ContactPerson,CSTNo,[DB Disc_Amount_Dt],
		[DB Disc_EffectAmt_Dt],[DB Disc_HD],[DB Disc_UnitAmt_Dt],[DB Disc_QtyPerc_Dt],[DB Disc_UnitPerc_Dt],[DB Disc_UomAmt_Dt],[DB Disc_UomPerc_Dt],
		DCDate,DCNo,DlvBoyName,SalDlvDate,DepositAmt,DistributorAdd1,DistributorAdd2,DistributorAdd3,DistributorCode,DistributorName,DrugBatchDesc,
		DrugLicNo1,DrugLicNo2,Drug1ExpiryDate,Drug2ExpiryDate,EANCode,D_EmailID,D_GeoLevelName,InterimSales,LicNo,LineBaseQtyAmount,LineBaseQtyPerc,
		LineEffectAmount,LineUnitamount,LineUnitPerc,LineUom1Amount,LineUom1Perc,LSTNo,SalManFreeQty,OrderDate,OrderKeyNo,PestExpiryDate,PestLicNo,
		PhoneNo,PinCode,PrdCCode,PrdName,PrdShrtName,SLNo,PrdType,Remarks,RtrAdd1,RtrAdd2,RtrAdd3,RtrCode,RtrContactPerson,RtrCovMode,
		RtrCrBills,RtrCrDays,RtrCrLimit,RtrCSTNo,RtrDepositAmt,RtrDrugExpiryDate,RtrDrugLicNo,RtrEmailId,GeoLevelName,RtrLicExpiryDate,RtrLicNo,
		RtrName,RtrOffPhone1,RtrOffPhone2,RtrOnAcc,RtrPestExpiryDate,RtrPestLicNo,RtrPhoneNo,RtrPinNo,RtrResPhone1,RtrResPhone2,
		RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipId,RtrTaxType,RtrTINNo,VillageName,RMCode,RMName,SalInvNo,SalActNetRateAmount,SalCDPer,
		CRAdjAmount,DBAdjAmount,SalGrossAmount,PrdGrossAmountAftEdit,PrdNetAmount,MarketRetAmount,SalNetAmt,SalNetRateDiffAmount,OnAccountAmount,
		OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,WindowDisplayamount,SMCode,SMName,SalId,
		[Sch Disc_Amount_Dt],[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],
		[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],
		[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,
		Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],
		[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility
		FROM
		(
			SELECT DisDt.*,RepAll.*
			FROM
			(
				SELECT D.DistributorCode,D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3, D.PinCode,D.PhoneNo,
				D.ContactPerson D_ContactPerson,D.EmailID D_EmailID,D.TaxType,D.TINNo,D.DepositAmt,GL.GeoLevelName D_GeoLevelName,
				D.CSTNo,D.LSTNo,D.LicNo,D.DrugLicNo1,D.Drug1ExpiryDate,D.DrugLicNo2,D.Drug2ExpiryDate,D.PestLicNo , D.PestExpiryDate
				FROM Distributor D WITH (NOLOCK)
				LEFT OUTER JOIN Geography G WITH (NOLOCK) ON D.GeoMainId = G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL WITH (NOLOCK) ON G.GeoLevelId = GL.GeoLevelId
			) DisDt ,
			(
				SELECT RepHD.*,RepDt.* FROM
				(
					SELECT SalesInv.* , RtrDt.*, HDAmt.* FROM
					(
						SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
						RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,SalRateDiffAmount,
						SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,Replacementdiffamount,
						TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,SalRoundOffAmt,V.VehicleId,V.VehicleCode,
						D.DlvBoyId,D.DlvBoyName
						FROM SalesInvoice SI WITH (NOLOCK)
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					) SalesInv
					LEFT OUTER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,R.RtrCrLimit,
						R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,GL.GeoLevelName,
						RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2,R.RtrOffPhone1,R.RtrOffPhone2,R.RtrOnAcc
						FROM Retailer R WITH (NOLOCK)
						INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK)
						WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					LEFT OUTER JOIN
					(
						SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
						FROM SalesInvoice SI
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId
						INNER JOIN
						(
							SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					)HDAmt ON SalesInv.SalIdHD = HDAmt.SalId
				) RepHD
				LEFT OUTER JOIN
				(
					SELECT SalesInvPrd.*,LiAmt.*,LNUOM.*,BATPRC.MRP,BATPRC.[Selling Rate]
					FROM
					(
						SELECT SPR.*,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,
						C.EmailId,C.ContactPerson
						FROM
						(
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,
							P.PrdName,P.PrdShrtName,P.CmpId,P.PrdType,SIP.PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,
							U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,SIP.Uom2Qty,SIP.BaseQty,
							SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,
							BPT.Tax3Perc,BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
							FROM SalesInvoiceProduct SIP WITH (NOLOCK)
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId
							INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.SchId,LW.slabId,LW.PrdId, LW.PrdBatId, PO.Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								LEFT OUTER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId
								AND LW.SchId = PO.SchId AND LW.SlabId = PO.SlabId
								WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills)
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax4Amount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt]
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='D'
						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='E'
						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='F'
						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='G'
						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
						INNER JOIN
						(
							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='H'
						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1 AND
					SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						FROM SalesInvoiceProduct WITH (NOLOCK)
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						SELECT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
						FROM
						(
							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
							FROM ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1 )
						) MRP
						LEFT OUTER JOIN
						(
							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
							FROM ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1 )
						) SelRtr ON MRP.PrdId = SelRtr.PrdId
						AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId AND MRP.PriceId=SelRtr.PriceId
					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  WHERE SalId IN (SELECT SalId FROM RptSELECTedBills)
	END
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[RptBTBillTemplate]')
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	DROP TABLE [RptBTBillTemplate]
	SELECT DISTINCT * INTO RptBTBillTemplate FROM @RptBillTemplate
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-035

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PK_SalesInvoiceSchemeDtPoints_SalId_SchId_SlabId_SchType]') and OBJECTPROPERTY(id, N'IsPrimaryKey') = 1)
ALTER TABLE [dbo].[SalesInvoiceSchemeDtPoints] DROP CONSTRAINT [PK_SalesInvoiceSchemeDtPoints_SalId_SchId_SlabId_SchType]
GO

--SRF-Nanda-152-036

if exists (select * from dbo.sysobjects where id = object_id(N'[RptPurchasePayment_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptPurchasePayment_Excel]
GO

CREATE TABLE [dbo].[RptPurchasePayment_Excel]
(
	[SlNo] [int] NULL,
	[CmpId] [int] NULL,
	[CmpName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SpmId] [int] NULL,
	[SpmName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CmpInvNo] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InvDate] [datetime] NULL,
	[GRNNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GRNDate] [datetime] NULL,
	[PayRefNo] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PayDate] [datetime] NULL,
	[InvAmt] [numeric](38, 6) NULL,
	[PaidAmt] [numeric](38, 6) NULL,
	[Mode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CrAdjAmt] [numeric](38, 6) NULL,
	[DbAdjAmt] [numeric](38, 6) NULL,
	[BalAmt] [numeric](38, 6) NULL,
	[MinPayMode] [int] NULL,
	[MaxPayMode] [int] NULL,
	[PayMode] [int] NULL,
	[MaxSlNo] [int] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-152-037

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptPurchasePayment]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptPurchasePayment]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC Proc_RptPurchasePayment 149,1,10,'CoreStocky18072008',0,0,1,0
CREATE                    PROCEDURE [dbo].[Proc_RptPurchasePayment]
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
* PROCEDURE	: Proc_RptPurPayment
* PURPOSE	: To get the Purchase Payment details for Report
* CREATED	: Nandakumar R.G
* CREATED DATE	: 09/06/2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	NVARCHAR(50)
	DECLARE @TblName 	AS	NVARCHAR(500)
	DECLARE @TblStruct 	AS	NVARCHAR(4000)
	DECLARE @TblFields 	AS	NVARCHAR(4000)
	DECLARE @TblFields1 	AS	NVARCHAR(4000)
	DECLARE @sSql		AS 	NVARCHAR(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	--Filter Variable
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @CmpId        		AS	INT
	DECLARE @SpmId        		AS	INT
	DECLARE @PayAdvNo		AS 	NVARCHAR(50)	
	DECLARE @CmpInvNo        	AS	INT
	DECLARE @ReportTypeId        	AS	INT
	DECLARE @Cnt	        	AS	INT
	--Till Here
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @SpmId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId))
	SET @CmpInvNo=(SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId))
	SET @PayAdvNo = (SElect  TOP 1 sCountid FRom Fn_ReturnRptFilterString(@Pi_RptId,171,@Pi_UsrId))
	
	--Till Here
	--SET @ReportTypeId=1
	Create TABLE #RptPurchasePayment
	(
			SlNo			INT IDENTITY(1,1),
			CmpId			INT,
			CmpName 		NVARCHAR(200),
			SpmId			INT,
			SpmName			NVARCHAR(200),
			CmpInvNo 		NVARCHAR(200),
			InvDate			DATETIME,
			GRNNo			NVARCHAR(50),
			GRNDate			DATETIME,
			PayRefNo		NVARCHAR(50),
			PayDate        	     	DATETIME,
			InvAmt		        NUMERIC(38,6),
			PaidAmt    	     	NUMERIC(38,6),
			Mode			NVARCHAR(50),
			CrAdjAmt    	     	NUMERIC(38,6),
			DbAdjAmt    	     	NUMERIC(38,6),
			BalAmt    	     	NUMERIC(38,6),
			MinPayMode		INT,
			MaxPayMode		INT,
			PayMode			INT,
			MaxSlNo			INT
	)
	SET @TblName = 'RptPurchasePayment'
	SET @TblStruct = 'SlNo			INT  IDENTITY(1,1),
			CmpId			INT,
			CmpName 		NVARCHAR(200),
			SpmId			INT,
			SpmName			NVARCHAR(200),
			CmpInvNo 		NVARCHAR(200),
			InvDate			DATETIME,
			GRNNo			NVARCHAR(50),
			GRNDate			DATETIME,
			PayRefNo		NVARCHAR(50),
			PayDate        	     	DATETIME,
			InvAmt		        NUMERIC(38,6),
			PaidAmt    	     	NUMERIC(38,6),
			Mode			NVARCHAR(50),
			CrAdjAmt    	     	NUMERIC(38,6),
			DbAdjAmt    	     	NUMERIC(38,6),
			BalAmt    	     	NUMERIC(38,6),
			MinPayMode		INT,
			MaxPayMode		INT,
			PayMode			INT,
			MaxSlNo			INT'
	SET @TblFields = 'CmpId,CmpName,SpmId,SpmName,CmpInvNo,InvDate,GRNNo,
			GRNDate,PayRefNo,PayDate,InvAmt,PaidAmt,Mode,
			CrAdjAmt,DbAdjAmt,BalAmt,MinPayMode,MaxPayMode,PayMode,MaxSlNo'
	SET @TblFields1 = 'CmpId,CmpName,SpmId,SpmName,CmpInvNo,InvDate,GRNNo,
			GRNDate,PayRefNo,PayDate,InvAmt,PaidAmt,Mode,
			CrAdjAmt,DbAdjAmt,BalAmt,MinPayMode,MaxPayMode,PayMode,MaxSlNo'
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
		CREATE TABLE #TempTotalGRN
		(SlNo INT IDENTITY(1,1),
		PayAdvNo NVARCHAR(50),
		PurRcptId	INT,
		PrevBalAmt	NUMERIC(32,6),
		PaidAmt		NUMERIC(32,6),
		BalAmt		NUMERIC(32,6)
		)
		
		INSERT INTO #TempTotalGRN
		SELECT A.PayAdvNo,A.PurRcptId,B.NetPayable,A.PayAmount,0
		FROM PurchasePaymentGRN A INNER JOIN PurchaseReceipt B ON A.PurRcptId=B.PurRcptId
		ORDER BY A.PurRcptId,A.PayAdvNo
		UPDATE #TempTotalGRN SET BalAmt=PrevBalAmt-PaidAmt
		
		SET @Cnt=0
		WHILE @Cnt<=50
		BEGIN
			SELECT * INTO #Temp1 FROM #TempTotalGRN		
			ORDER BY PurRcptId,PayAdvNo
			
			UPDATE #TempTotalGRN SET #TempTotalGRN.PrevBalAmt=A.BalAmt
			FROM #Temp1 A
			WHERE #TempTotalGRN.SlNo=A.SlNo+1 AND #TempTotalGRN.PurRcptId=A.PurRcptId
	
			UPDATE #TempTotalGRN SET BalAmt=PrevBalAmt-PaidAmt
			
			SET @Cnt=@Cnt+1
			DROP TABLE #Temp1
		END
		SELECT PayAdvNo,SUM(CrAdjAmt) AS CrAdjAmt,SUM(DbAdjAmt)  AS DbAdjAmt
		INTO #CRDBNotePayAdjustment FROM
		(SELECT CDPA.PayAdvNo,(CASE ISNULL(CDPA.AdjMode,0) WHEN 2 THEN (CDPA.AdjAmount) ELSE 0 END) AS CrAdjAmt,
			(CASE ISNULL(CDPA.AdjMode,0) WHEN 1 THEN (CDPA.AdjAmount) ELSE 0 END) AS DbAdjAmt
			FROM CRDBNotePayAdjustment CDPA INNER JOIN PurchasePayment PP ON CDPA.PayAdvNo=PP.PayAdvNo
			WHERE  (PP.PayAdvNo=  (CASE @PayAdvNo WHEN '0' THEN PP.PayAdvNo ELSE '0' END ) OR
				PP.PayAdvNo IN (SELECT sCountId FROM dbo.Fn_ReturnRptFilterString(@Pi_RptId,171,@Pi_UsrId)))) A
		GROUP BY PayAdvNo
		SELECT PayAdvNo,MIN(PurRcptId) AS MinPayMode,MAX(PurRcptId) AS MaxPayMode
		INTO #MinMaxPayMode
		FROM PurchasePaymentGRN B (NOLOCK)
		GROUP BY PayAdvNo
		INSERT INTO #RptPurchasePayment (CmpId,CmpName,SpmId,SpmName,CmpInvNo,InvDate,GRNNo,
		GRNDate,PayRefNo,PayDate,InvAmt,PaidAmt,Mode,
		CrAdjAmt,DbAdjAmt,BalAmt,MinPayMode,MaxPayMode,PayMode,MaxSlNo)
		SELECT DISTINCT C.CmpId,C.CmpName,S.SpmId,S.SpmName,PR.CmpInvNo,PR.InvDate,
		PR.PurRcptRefNo,PR.GoodsRcvdDate,PP.PayAdvNo,PP.PaymentDate,PR.NetPayable,PPG.PayAmount,'' AS Mode,
		ISNULL(CrAdjAmt,0) AS CrAdjAmt,ISNULL(DbAdjAmt,0) AS DbAdjAmt,
		TGRN.BalAmt,MMP.MinPayMode,MMP.MaxPayMode,PPG.PurRcptId,0
		FROM Company C (NOLOCK),Supplier S (NOLOCK),
		PurchasePaymentDetails PPD (NOLOCK),PurchasePayment PP (NOLOCK)
		LEFT OUTER JOIN #CRDBNotePayAdjustment CDPA (NOLOCK) ON PP.PayAdvNo=CDPA.PayAdvNo
		INNER JOIN PurchasePaymentGRN PPG (NOLOCK)ON  PP.PayAdvNo=PPG.PayAdvNo
		INNER JOIN PurchaseReceipt PR (NOLOCK) ON PPG.PurRcptId=PR.PurRcptId
		LEFT OUTER JOIN #MinMaxPayMode MMP (NOLOCK) ON PP.PayAdvNo=MMP.PayAdvNo
		LEFT OUTER JOIN #TempTotalGRN TGRN (NOLOCK) ON PP.PayAdvNo=TGRN.PayAdvNo AND PR.PurRcptId=TGRN.PurRcptId
		WHERE S.CmpId=C.CmpId AND PP.SpmId=S.SpmId AND
		PPD.PayAdvNo=PP.PayAdvNo
		AND   (C.CmpId=  (CASE @CmpId WHEN 0 THEN C.CmpId ELSE 0 END ) OR
			C.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		AND   (PP.SpmId=  (CASE @SpmId WHEN 0 THEN PP.SpmId ELSE 0 END ) OR
			PP.SpmId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))
		AND   (PP.PayAdvNo=  (CASE @PayAdvNo WHEN '0' THEN PP.PayAdvNo ELSE '0' END ) OR
			PP.PayAdvNo IN (SELECT sCountId FROM dbo.Fn_ReturnRptFilterString(@Pi_RptId,171,@Pi_UsrId)))
		AND 	(PR.PurRcptId = (CASE @CmpInvNo WHEN 0 THEN PR.PurRcptId ELSE 0 END) OR
			PR.PurRcptId IN (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,194,@Pi_UsrId)))
		AND   PP.PaymentDate BETWEEN @FromDate AND @ToDate		
		ORDER BY PP.PayAdvNo,PR.PurRcptRefNo
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptPurchasePayment' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields1 + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
		+' WHERE S.CmpId=C.CmpId AND PP.SpmId=S.SpmId AND PPG.PurRcptId=PR.PurRcptId AND
			PPD.PayAdvNo=PP.PayAdvNo AND PP.PayAdvNo=PPG.PayAdvNo
			AND   (PP.CmpId=  (CASE '+CAST(@CmpId AS NVARCHAR(10))+' WHEN 0 THEN PP.CmpId ELSE 0 END ) OR
				PP.CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',4,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PP.SpmId=  (CASE '+CAST(@SpmId AS NVARCHAR(10))+' WHEN 0 THEN PP.SpmId ELSE 0 END ) OR
				PP.SpmId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters('+CAST(@Pi_RptId AS NVARCHAR(10))+',9,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   (PP.PayAdvNo=  (CASE '+@PayAdvNo+' WHEN '''' THEN PP.PayAdvNo ELSE '''' END ) OR
				PP.PayAdvNo IN (SELECT sCountId FROM dbo.Fn_ReturnRptFilterString('+CAST(@Pi_RptId AS NVARCHAR(10))+',171,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND 	(PR.PurRcptRefNo = (CASE '+ @CmpInvNo +' WHEN '''' THEN PR.PurRcptRefNo ELSE '''' END) OR
				PR.PurRcptRefNo IN (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS NVARCHAR(10))+',194,'+CAST(@Pi_UsrId AS NVARCHAR(10))+')))
			AND   PP.PaymentDate BETWEEN '+CAST(@FromDate AS NVARCHAR(10))+' AND '+CAST(@ToDate AS NVARCHAR(10))+''
			EXEC (@SSQL)
			PRINT 'Retrived Data From Purged Table'
		END
		IF @Pi_SnapRequired = 1
		BEGIN
			SELECT @NewSnapId = @Pi_SnapId
			pRINT @DBNAME
			EXEC Proc_SnapShot_Report @NewSnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
			SET @sSql = 'INSERT INTO [' + @DBNAME + '].dbo.' + @TblName +
				'(SnapId,UserId,RptId,' + @TblFields + ')' +
				' SELECT ' + CAST(@NewSnapId AS VARCHAR(10)) +
				' ,' + CAST(@Pi_UsrId AS VARCHAR(10)) +
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', ' + @TblFields + ' FROM #RptPurchasePayment'
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
			SET @SSQL = 'INSERT INTO #RptPurchasePayment ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields1 + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
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
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptPurchasePayment
	PRINT 'Data Executed'
	
	UPDATE #RptPurchasePayment SET CrAdjAmt=0,DbAdjAmt=0
	WHERE MaxPayMode<>PayMode
	SELECT GRNNo,MAX(SlNo) AS SlNo
	INTO #TempMax
	FROM #RptPurchasePayment
	GROUP BY GRNNo
	UPDATE #RptPurchasePayment SET MaxSlNo=A.SlNo
	FROM #TempMax A WHERE #RptPurchasePayment.GRNNo=A.GRNNo 
	
	DELETE FROM RptPurchasePayment_Excel
	INSERT INTO RptPurchasePayment_Excel
	SELECT * FROM #RptPurchasePayment ORDER BY PayRefNo,GRNNo,PayMode

	SELECT * FROM #RptPurchasePayment ORDER BY PayRefNo,GRNNo,PayMode

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-152-038

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_Claim_ResellDamage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_Claim_ResellDamage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--SELECT *  FROM Cs2Cn_Prk_ClaimAll
--EXEC Proc_Cs2Cn_Claim_ResellDamage

CREATE            PROCEDURE [dbo].[Proc_Cs2Cn_Claim_ResellDamage]
AS 

SET NOCOUNT ON
BEGIN
 /*********************************
 * PROCEDURE: Proc_Cs2Cn_Claim_ResellDamage
 * PURPOSE: Extract Resell Damage Claim Details from CoreStocky to Console
 * NOTES:
 * CREATED: Mahalakshmi.A 06-08-2008
 * MODIFIED
 * DATE      AUTHOR     DESCRIPTION
 ------------------------------------------------
 *
 *********************************/
	DECLARE @CmpID 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DECLARE @TransDate	AS DATETIME

	DELETE FROM Cs2Cn_Prk_ClaimAll WHERE UploadFlag = 'Y' AND ClaimType='Resell Damage Goods Claim'

	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	WHERE ProcId = 12
	SELECT @TransDate=DATEADD(D,-1,GETDATE())


	INSERT INTO Cs2Cn_Prk_ClaimAll 
	(
		DistCode		,
		CmpName			,
		ClaimType		,
		ClaimMonth		,
		ClaimYear		,
		ClaimRefNo		,
		ClaimDate		,
		ClaimFromDate		,
		ClaimToDate		,
		DistributorClaim	,
		DistributorRecommended	,
		ClaimnormPerc		,
		SuggestedClaim		,
		TotalClaimAmt		,
		Remarks			,
		Description		,
		Amount1			,
		ProductCode		,
		Batch			,
		Quantity1		,
		Quantity2		,
		Amount2			,
		Amount3			,
		TotalAmount		,
		BillNo			,
		UploadFlag						
	)
	SELECT @DistCode,
		CmpName,
		'Resell Damage Goods Claim',
		DATENAME(MM,CS.ClmDate),
		DATEPART(YYYY,CS.ClmDate),
		CS.ClmCode,
		ClmDate,
		CS.FromDate,
		CS.ToDate,
		RM.ClaimAmt,
		RM.ClaimAmt,
		CD.ClmPercentage,
		CD.ClmAmount,
		CD.RecommendedAmount,
		'',
		R.RtrName,
		RD.SelRate,
		P.PrdCCode,
		PB.PrdBatCode,
		RD.Quantity,
		(RD.Quantity*RD.SelRate)AS ResellAmt,
		0,
		0,
		(RD.Quantity*RD.SelRate)AS TotAmt,
		RM.ReDamRefNo,
		'N'
	FROM ResellDamageMaster RM
		INNER JOIN ResellDamageDetails RD  WITH (NOLOCK) ON RD.ReDamRefNo=RM.ReDamRefNo
		INNER JOIN Product P WITH (NOLOCK) ON P.PrdId=RD.PrdID
		INNER JOIN ProductBatch PB WITh (NOLOCK) ON PB.PrdID= RD.PrdID AND PB.PrdBatId=RD.PrdBatId
		INNER JOIN ClaimSheetDetail CD WITH (NOLOCK) ON RM.ClaimRefNo=CD.RefCode
		INNER JOIN ClaimSheetHd CS WITH (NOLOCK) ON CS.ClmId=CD.ClmId AND CS.ClmGrpId= 10
		INNER JOIN Company C  WITH (NOLOCK) ON CS.CmpId=C.CmpId
		INNER JOIN Retailer R WITH (NOLOCK) ON RM.RtrID=R.RtrId
	WHERE RM.Status=1 AND CD.Status=1 AND CS.Upload='N'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if not exists (select * from hotfixlog where fixid = 342)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(342,'D','2010-09-21',getdate(),1,'Core Stocky Service Pack 342')