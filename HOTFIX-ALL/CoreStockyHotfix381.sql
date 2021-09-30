--[Stocky HotFix Version]=381
Delete from Versioncontrol where Hotfixid='381'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('381','2.0.0.5','D','2011-06-24','2011-06-24','2011-06-24',convert(varchar(11),getdate()),'Major: Product Release FOR JANDJ,HENKEL,B&L')
GO
DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 381' ,'381'
GO
DELETE FROM CustomCaptions WHERE TransId=45 AND CtrlId=119 AND SubCtrlId=1
INSERT INTO CustomCaptions
SELECT 45,119,1,'lblCombiType','Combi Type (+)','','',1,1,1,'2011-06-01',1,'2011-06-01','Combi Type (+).','','',1,1
DELETE FROM CustomCaptions WHERE TransId=45 AND CtrlId=120 AND SubCtrlId=1
INSERT INTO CustomCaptions
SELECT 45,120,1,'fxtCombiType','','Press Space bar/Double Click to Select Combi Type','',1,1,1,'2011-06-01',1,'2011-06-01','','Press Space bar/Double Click to Select Combi Type','',1,1
DELETE FROM ScreenDefaultValues WHERE TransId=45 AND CtrlId=120 
INSERT INTO ScreenDefaultValues
SELECT 45,120,0,'Normal',1,1,1,1,'2011-06-01',1,'2011-06-01','Normal'
UNION 
SELECT 45,120,1,'Fluctuating',2,1,1,1,'2011-06-01',1,'2011-06-01','Fluctuating'
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[dbo].[SchemeCombiCriteria]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[SchemeCombiCriteria]
(
	SchId				INT,
	PrdMode				INT,
	PrdCtgValMainId		INT,
	PrdId				INT,
	MinAmount			NUMERIC(18,6),
	NoofLines			INT,
	DiscPer				NUMERIC(18,2),
	FlatAmt				NUMERIC(18,6),
	Points				NUMERIC(18,0),
	CONSTRAINT [FK_SchemeMaster_SchId] FOREIGN KEY 
	([SchId]) REFERENCES [dbo].[SchemeMaster] ([SchId])
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'CombiType' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='SchemeMaster'))
BEGIN
	ALTER TABLE SchemeMaster ADD CombiType INT NOT NULL DEFAULT 0 WITH VALUES
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyCombiSchemeInBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyCombiSchemeInBill]
GO
/*
BEGIN TRANSACTION
--EXEC Proc_ApplyCombiSchemeInBill 560,122,0,1,2
--UPDATE SchemeMaster SET QPSReset=1 WHERE SchId=552
DELETE FROM BillAppliedSchemeHd
EXEC Proc_ApplyCombiSchemeInBill 558,122,0,1,2
-- DELETE FROM BillAppliedSchemeHd
-- SELECT * FROM BillAppliedSchemeHd
--EXEC Proc_ApportionSchemeAmountInLine 1,2
-- SELECT * FROM ApportionSchemeDetails
-- SELECT * FROM BillAppliedSchemeHd
-- SELECT * FROM BilledPrdHdForScheme
--DELETE FROM ApportionSchemeDetails
--DELETE FROM BillAppliedSchemeHd
-- UPDATE BillAppliedSchemeHd SET IsSelected = 1
--SELECT * FROM SchemeMaster
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
							ON A.SalId=B.SalId WHERE B.SchId=@Pi_SchId AND A.RtrId=@Pi_RtrId AND A.SalId<>@Pi_SalId)
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
				ON A.SalId=B.SalId WHERE B.SchId=@Pi_SchId AND A.RtrId=@Pi_RtrId AND A.SalId<>@Pi_SalId)
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

SELECT @TransMode,* FROM @TempBilledFinal
/*
BEGIN TRANSACTION
DELETE FROM BillAppliedSchemeHd
EXEC Proc_ApplyCombiSchemeInBill 558,122,0,1,2
-- UPDATE BillAppliedSchemeHd SET IsSelected = 1
SELECT * FROM BillAppliedSchemeHd
ROLLBACK TRANSACTION
*/



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
					IF EXISTS(SELECT A.SchId,COUNT(A.PrdCtgValMainId) AS Cnt FROM	@TempBilledFinal A
					INNER JOIN SchemeCombiCriteria B ON A.SchId=B.SchId AND A.PrdId=B.PrdId
					WHERE A.SchId=@Pi_SchId AND A.SchemeOnAmount>=B.MinAmount AND B.PrdMode<>1 GROUP BY A.SchId
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
		IF @QPS <> 0
		BEGIN
			EXEC Proc_AssignQPSCumulative @Pi_SchId,@Pi_RtrId,0,@Pi_UsrId
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
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyQPSSchemeInBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyQPSSchemeInBill]
GO
/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme(NOLOCK) WHERE SchId=527
--SELECT * FROM BillAppliedSchemeHd
DELETE FROM BillAppliedSchemeHd
EXEC Proc_ApplyQPSSchemeInBill 69,47,0,2,2
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd(NOLOCK) WHERE TransId = 2 And UsrId = 2
--SELECT * FROM BillAppliedSchemeHd (NOLOCK)
--SELECT * FROM ApportionSchemeDetails (NOLOCK)
--SELECT * FROM SalesInvoiceQPSCumulative(NOLOCK) WHERE SchId=522
--SELECT * FROM SchemeMaster
--SELECT * FROM Retailer
SELECT * FROM BillAppliedSchemeHd
--SELECT * FROM BilledPrdHdForScheme
ROLLBACK TRANSACTION
*/
CREATE        Procedure [dbo].[Proc_ApplyQPSSchemeInBill]
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
	--	SELECT '1',* FROM @TempBilled1
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
		END
--SELECT @Pi_SalId,'2',* FROM @TempBilled1
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
				AND SI.SalInvDate BETWEEN H.SchValidFrom AND  CASE @Pi_SalId WHEN 0 THEN  H.SchValidTill ELSE @BillDate END  AND H.SchId=@Pi_SchId
				Group by SIP.Prdid,SIP.Prdbatid,D.PrdUnitId
		END
--		SELECT @Pi_SalId,'3',* FROM @TempBilled1
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
					WHERE A.SalId = @Pi_SalId
					GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
			END
		--SELECT '4',* FROM @TempBilled1
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
		END
--		SELECT '5',* FROM @TempBilled1
--		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
--		SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
--			-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
--			-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
--			FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
--			GROUP BY PrdId,PrdBatId
--		SELECT * FROM @TempBilled1
	END
	--SELECT '6',* FROM @TempBilled1
	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
		ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
		GROUP BY PrdId,PrdBatId,SchId
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
	--SELECT * FROM @TempBilled
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
--		SELECT @SlabId
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
--		SELECT 'New ',* FROM #TemAppQPSSchemes
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemes B WHERE A.SlabId=B.SlabId)
	END
	--->Till Here
	--->Added By Nanda on 23/03/2011
	SELECT @SchType
	IF @SchType = 2 AND @QPSReset=1	
	BEGIN
		CREATE TABLE  #TemAppQPSSchemesAmt
		(
			SchId		INT,
			SlabId		INT,
			NoOfTime	INT
		)
		
		DECLARE @NewNoOfTimesAmt AS INT
		DECLARE @NewSlabIdAmt AS INT
		DECLARE @NewTotalValueAmt AS NUMERIC(38,6)
		SET @NewTotalValueAmt=@TotalValue
		SET @NewSlabIdAmt=@SlabId
		WHILE @NewTotalValueAmt>0 AND @NewSlabIdAmt>0
		BEGIN
			SELECT @NewNoOfTimesAmt=FLOOR(@NewTotalValueAmt/(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabIdAmt AND SchId=@Pi_SchId
			IF @NewNoOfTimesAmt>0
			BEGIN
				SELECT @NewTotalValueAmt=@NewTotalValueAmt-(@NewNoOfTimesAmt*(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabIdAmt AND SchId=@Pi_SchId
				INSERT INTO #TemAppQPSSchemesAmt
				SELECT @Pi_SchId,@NewSlabIdAmt,@NewNoOfTimesAmt
			END
			SET @NewSlabIdAmt=@NewSlabIdAmt-1
		END
		SELECT 'New ',* FROM #TemAppQPSSchemesAmt
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemesAmt B WHERE A.SlabId=B.SlabId)
	END
	--->Till Here
	--->Added By Nanda on 04/05/2011
	IF @SchType = 1 AND @QPSReset=1	
	BEGIN
		CREATE TABLE  #TemAppQPSSchemesQty
		(
			SchId		INT,
			SlabId		INT,
			NoOfTime	INT
		)
		
		DECLARE @NewNoOfTimesQty AS INT
		DECLARE @NewSlabIdAmtQty AS INT
		DECLARE @NewTotalValueQty AS NUMERIC(38,6)
		SET @NewTotalValueQty=@TotalValue
		SET @NewSlabIdAmtQty=@SlabId
		WHILE @NewTotalValueQty>0 AND @NewSlabIdAmtQty>0
		BEGIN
			SELECT @NewNoOfTimesQty=FLOOR(@NewTotalValueQty/(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabIdAmtQty AND SchId=@Pi_SchId
			IF @NewNoOfTimesQty>0
			BEGIN
				SELECT @NewTotalValueQty=@NewTotalValueQty-(@NewNoOfTimesQty*(PurQty+FRomQty)) FROM SchemeSlabs WHERE SlabId=@NewSlabIdAmtQty AND SchId=@Pi_SchId
				INSERT INTO #TemAppQPSSchemesQty
				SELECT @Pi_SchId,@NewSlabIdAmtQty,@NewNoOfTimesQty
			END
			SET @NewSlabIdAmtQty=@NewSlabIdAmtQty-1
		END
		SELECT 'New ',* FROM #TemAppQPSSchemesQty
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemesQty B WHERE A.SlabId=B.SlabId)
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
--				SELECT @SlabAssginValue
				WHILE @SlabAssginValue > CAST(0 AS NUMERIC(38,6))
				BEGIN
					SET @AssignQty  = 0
					SET @AssignAmount = 0
					SET @AssignKG = 0
					SET @AssignLitre = 0
--					SELECT @SlabAssginValue
--					SELECT @FrmSchAchRem
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
	--->Added By Nanda on 23/03/2011
	IF @SchType = 2 AND @QPSReset=1
	--IF @QPSReset=1
	BEGIN
		SELECT DISTINCT * INTO #TempBillAppliedAmt FROM @BillAppliedSchemeHd
		DELETE FROM @BillAppliedSchemeHd
		INSERT INTO @BillAppliedSchemeHd
		SELECT * FROM #TempBillAppliedAmt
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemesAmt B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
		INNER JOIN SchemeSlabs C ON A.SchId=C.SchId AND C.SlabId=B.SlabId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId
	END
	--->Till Here
	--->Added By Nanda on 23/03/2011
	IF @SchType = 1 AND @QPSReset=1
	--IF @QPSReset=1
	BEGIN
		SELECT DISTINCT * INTO #TempBillAppliedQty FROM @BillAppliedSchemeHd
		DELETE FROM @BillAppliedSchemeHd
		INSERT INTO @BillAppliedSchemeHd
		SELECT * FROM #TempBillAppliedQty
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemesQty B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
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
	IF @FlexiSch=0
	BEGIN
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
			(SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BilledPrdHdForScheme WHERE UsrId=@Pi_UsrId AND TransID=@Pi_TransId)		
			
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
	
	SELECT DISTINCT * INTO #Temp_BillAppliedSchemeHd FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TRansId=@Pi_TransId AND SchId=@Pi_SchId
	DELETE FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TRansId=@Pi_TransId AND SchId=@Pi_SchId
	INSERT INTO BillAppliedSchemeHd
	SELECT * FROM #Temp_BillAppliedSchemeHd 
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplySchemeInBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplySchemeInBill]
GO
/*
BEGIN TRANSACTION
--EXEC Proc_ApplySchemeInBill 25,2,152,4,2
-- SELECT * FROM dbo.ApportionSchemeDetails
-- SELECT * FROM Retailer WHERE RtrName Like 'PAN%'
EXEC Proc_ApplySchemeInBill 516,2,2137,2,3
SELECT * FROM BillAppliedSchemeHd
-- DELETE FROM BillAppliedSchemeHd
-- SELECT * FROM BilledPrdHdForScheme(NOLOCK)
ROLLBACK TRANSACTION
*/
CREATE          Procedure [dbo].[Proc_ApplySchemeInBill]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT	
)
AS
/*********************************
* PROCEDURE		: Proc_ApplySchemeInBill
* PURPOSE		: To Apply the Scheme and Get the Scheme Details for the Selected Scheme
* CREATED		: Thrinath
* CREATED DATE	: 17/04/2007
* NOTE			: General SP for Returning the Scheme Details for the Selected Scheme
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
	DECLARE @RangeScheme		INT
	DECLARE @ProRata		INT
	DECLARE @Qps			INT
	DECLARE @QpsReset		INT
	DECLARE @PurOfEveryReq		INT
	DECLARE @SchemeBudget		NUMERIC(38,6)
	DECLARE @SlabId			INT
	DECLARE @NoOfTimes		NUMERIC(38,6)
	DECLARE @GrossAmount		NUMERIC(38,6)
	DECLARE @BudgetUtilized		NUMERIC(38,6)
	DECLARE @BillDate 		DATETIME
	DECLARE @FrmValidDate		DateTime
	DECLARE @ToValidDate		DateTime
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
	SELECT @SchCode = SchCode,@SchType = SchType,@BatchLevel = BatchLevel,@FlexiSch = FlexiSch,
		@FlexiSchType = FlexiSchType,@CombiScheme = CombiSch,@RangeScheme = Range,@ProRata = ProRata,
		@Qps = QPS,@QpsReset = QPSReset,@SchemeBudget = Budget,
		@PurOfEveryReq = PurofEvery
	FROM SchemeMaster WHERE SchId = @Pi_SchId AND MasterType=1
	IF @Pi_TransId=3 OR @Pi_TransId=25
	BEGIN
		INSERT INTO BilledPrdHdForScheme (RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,
		TransId,Usrid,ListPrice)
		SELECT A.Slno,@Pi_RtrId,A.Prdid,A.PrdBatId,0,A.BaseQty-A.ReturnedQty,0,0,@Pi_TransId,@Pi_UsrId,0
		FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
		A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
		INNER JOIN Product C ON A.PrdId = C.PrdId
		INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
		WHERE A.SalId=@Pi_SalId AND  A.PrdId NOT IN (
		SELECT PrdId FROM BilledPrdHdForScheme WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId)
	END
--	SELECT 'N3',* FROM BilledPrdHdForScheme
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
	--
	--SELECT * FROM @TempBilled
	--SELECT * FROM @TempBilledAch
	SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
	INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId
	WHERE
	A.FrmSchAch >= B.FromQty AND
	A.ToSchAch <= (CASE B.ToQty WHEN 0 THEN A.ToSchAch ELSE B.ToQty END)
	ORDER BY A.SlabId DESC) As SlabId
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
		SELECT @NoOfTimes = A.FrmSchAch / (CASE B.ForEveryQty WHEN 0 THEN 1 ELSE B.ForEveryQty END) FROM
			@TempBilledAch A INNER JOIN @TempSchSlabAmt B ON A.SlabId = @SlabId
--		SELECT A.FrmSchAch,B.ForEveryQty  FROM
--			@TempBilledAch A INNER JOIN @TempSchSlabAmt B ON A.SlabId = @SlabId
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
	--To Store the Gross amount for the Scheme billed Product
	SELECT @GrossAmount = ISNULL(SUM(SchemeOnAmount),0) FROM @TempBilled
--	SELECT 'N1',* FROM @TempBilled
--	SELECT 'N2',* FROM @TempSchSlabAmt
	--To Calculate the Scheme Flat Amount and Discount Percentage
	--Scheme Discount for Flat amount = ((FlatAmt * (LineLevel Gross / Total Gross) * 100)/100) * number of times
	--Scheme Discount for Disc Perc   = (LineLevel Gross * Disc Percentage) / 100
	INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
		FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
		BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
	SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,
		SchemeDiscount AS SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
		FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,
		IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,0
		FROM
		(
			SELECT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
			@SlabId as SlabId,PrdId,PrdBatId,
			(CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END) As Contri,
			((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
			As SchemeAmount, DiscPer AS SchemeDiscount,(Points *@NoOfTimes) as Points,
			FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,0 as FreePrdId,0 as FreePrdBatId,
			0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,
			0 as IsSelected,@SchemeBudget as SchBudget,0 as BudgetUtilized,@Pi_TransId As TransId,
			@Pi_UsrId as UsrId FROM @TempBilled , @TempSchSlabAmt
			WHERE (FlatAmt + DiscPer + FlxDisc + FlxValueDisc + FlxFreePrd + FlxGiftPrd + Points + FlxPoints) >=0
		) AS B
		GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,
		FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,
		NoOfTimes,IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
	--SELECT * FROM @TempBilled
	--To Calculate the Free Qty to be given
	INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
		FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
		BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
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
		0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,MAX(PrdId) AS PrdId,MAX(PrdBatId) AS PrdBatId,0
		FROM @TempBilled , @TempSchSlabFree
		GROUP BY FreePrdId,FreeQty,ForEveryQty
	--SELECT * FROM @TempSchSlabFree
	--To Calculate the Gift Qty to be given
	INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
		Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
		FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
		BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
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
		END
		as GiftToBeGiven,@NoOfTimes as NoOfTimes,0 as IsSelected,
		@SchemeBudget as SchBudget,0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,MAX(PrdId) AS PrdId,MAX(PrdBatId) AS PrdBatId,0
		FROM @TempBilled , @TempSchSlabGift
		GROUP BY GiftPrdId,GiftQty,ForEveryQty
		IF @Pi_TransId=3 OR @Pi_TransId=25
		BEGIN
			UPDATE A Set A.FreePrdBatId=B.PrdBatId FROM BillAppliedSchemeHd A INNER JOIN
			(SELECT B.PrdId,ISNULL(MAX(A.PrdbatId),0) AS PrdBatId FROM ProductBatchLocation A INNER JOIN
			ProductBatch B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
			WHERE (A.PrdBatLcnSih+A.PrdBatLcnUih+A.PrdBatLcnFre)>0 GROUP BY B.PrdId) B ON A.FreePrdId=B.PrdId
			AND A.FreeToBeGiven>0
			UPDATE A Set A.GiftPrdBatId=B.PrdBatId FROM BillAppliedSchemeHd A INNER JOIN
			(SELECT B.PrdId,ISNULL(MAX(A.PrdbatId),0) AS PrdBatId FROM ProductBatchLocation A INNER JOIN
			ProductBatch B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
			WHERE (A.PrdBatLcnSih+A.PrdBatLcnUih+A.PrdBatLcnFre)>0 GROUP BY B.PrdId) B ON A.GiftPrdId=B.PrdId
			AND A.GiftToBeGiven>0
		END
	IF EXISTS (SELECT * FROM SchemeRtrLevelValidation WHERE Schid = @Pi_SchId AND RtrId = @Pi_RtrId)
	BEGIN
		IF Exists (SELECT * FROM SalesInvoice WHERE SalId = @Pi_SalId)
			SELECT @BillDate = SalInvDate FROM SalesInvoice WHERE SalId = @Pi_SalId
		ELSE
			SET @BillDate = CONVERT(VARCHAR(10),GETDATE(),121)
		SELECT @FrmValidDate = FromDate,@ToValidDate = ToDate,@SchemeBudget = BudgetAllocated
			FROM SchemeRtrLevelValidation WHERE @BillDate Between FromDate and ToDate
			AND Schid = @Pi_SchId AND RtrId = @Pi_RtrId
		SELECT @BudgetUtilized = dbo.Fn_ReturnBudgetUtilizedForRtr(@Pi_SchId,@Pi_RtrId,@FrmValidDate,@ToValidDate)
	END
	ELSE
	BEGIN
		SELECT @BudgetUtilized = dbo.Fn_ReturnBudgetUtilized(@Pi_SchId)
	END
	--SELECT A.PrdBatId FROM StockLedger A LEFT OUTER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
	--	AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
	--	AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId
	--	AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0
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
	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
	EXEC Proc_ApplyDiscountScheme @Pi_SchId,@Pi_UsrId,@Pi_TransId
	UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
		SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
		TransId = @Pi_TransId AND Usrid = @Pi_UsrId
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApportionSchemeAmountInLine]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApportionSchemeAmountInLine]
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
	@Pi_UsrId   	INT,
	@Pi_TransId  	INT,
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
--	SELECT * FROM @TempPrdGross
--	SELECT * FROM BilledPrdHdForQPSScheme
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
		--(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (CAST(CAST(C.GrossAmount AS NUMERIC(30,10))/CAST(B.GrossAmount AS NUMERIC(30,10)) AS NUMERIC(38,6))) * 100 END) As Contri,
		CASE WHEN QPS=1 THEN
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		--(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
		--ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
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
		WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
		AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
		AND SISl.SlabId<=A.SlabId) A	
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
--(SELECT A.SchId,SUM(A.ReturnDiscountPerAmount+A.ReturnFlatAmount) AS Amount FROM 
--(SELECT DISTINCT SISL.ReturnId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.ReturnDiscountPerAmount,SISL.ReturnFlatAmount
--	FROM ReturnSchemeLineDt SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
--	WHERE SchemeAmount=0
--	) A,SchemeMaster SM ,ReturnHeader SI,@RtrQPSIds RQPS
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
--	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.ReturnId=SISL.ReturnId AND SI.Status=0
--	AND SISl.SlabId<=A.SlabId) A	
--	GROUP BY A.SchId) S
--	WHERE A.SchId=S.SchId 	
--	SELECT 'N3',* FROM @QPSGivenDisc
	--->Added By Nanda on 04/03/2011 for Flexi Sch
	DELETE FROM @QPSGivenDisc WHERE SchId IN (SELECT SchId FROM SchemeMaster WHERE FlexiSch=1)
	INSERT INTO @QPSNowAvailable
	SELECT A.SchId,SUM(SchemeDiscount)-ISNULL(B.Amount,0) 
	FROM ApportionSchemeDetails A
	INNER JOIN SchemeMaster	SM ON A.SchId=SM.SchId AND SM.QPS=1 AND A.TransId=@Pi_TransID AND A.UsrId=@Pi_UsrId
	LEFT OUTER JOIN @QPSGivenDisc B ON A.SchId=B.SchId 
	GROUP BY A.SchId,B.Amount 
--	SELECT * FROM @QPSNowAvailable
--	SELECT * FROM ApportionSchemeDetails	
--	SELECT * FROM BillQPSSchemeAdj
	UPDATE A SET A.Contri=100*(B.QPSGrossAmount/CASE C.QPSGrossAmount WHEN 0 THEN 1 ELSE C.QPSGrossAmount END)	
	FROM ApportionSchemeDetails A,@TempPrdGross B,@TempSchGross C,SchemeMaster SM
	WHERE A.TRansId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.RowId=B.RowId AND	
	A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatID AND A.SchId=B.SchId AND B.SchId=C.SchId AND SM.SchId=A.SchId AND SM.QPS=1 AND SM.ApyQPSSch=2
	
	UPDATE A SET A.Contri=100*(B.GrossAmount/CASE C.GrossAmount WHEN 0 THEN 1 ELSE C.GrossAmount END)	
	FROM ApportionSchemeDetails A,@TempPrdGross B,@TempSchGross C,SchemeMaster SM
	WHERE A.TRansId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.RowId=B.RowId AND 
	A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatID AND A.SchId=B.SchId AND B.SchId=C.SchId AND SM.SchId=A.SchId AND SM.QPS=1 AND SM.ApyQPSSch=1
--	SELECT * FROM @QPSNowAvailable
	--->For non Converted QPS Scheme
	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId NOT IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId )	
	AND ApportionSchemeDetails.TransId=@Pi_TransID AND ApportionSchemeDetails.UsrId=@Pi_UsrId


	UPDATE ApportionSchemeDetails SET SchemeDiscount=0
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId AND AdjAmount>=0)	
	AND ApportionSchemeDetails.TransId=@Pi_TransID AND ApportionSchemeDetails.UsrId=@Pi_UsrId
	UPDATE ASD SET SchemeAmount=Contri*AdjAmount/100,SchemeDiscount=(CASE SM.CombiSch+SM.QPS WHEN 2 THEN 0 ELSE SchemeDiscount END)
	FROM ApportionSchemeDetails ASD,BillQPSSchemeAdj A,SchemeMaster SM 
	WHERE ASD.SchId=A.SchId AND SM.SchId=A.SchId
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
if not exists (select * from dbo.sysobjects where id = object_id(N'[BarCodeHd]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[BarCodeHd]
	(
		[BarCodeId] [int] NOT NULL,
		[BarCode] [varchar](200) NULL,
		[PrdCode] [varchar](200) NULL,
		[ConvFact] [int] NULL,
	) ON [PRIMARY]
end
if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PK_BarCodeHd_BarCodeId]') and OBJECTPROPERTY(id, N'IsPrimaryKey') = 1)
begin
	ALTER TABLE [dbo].[BarCodeHd] WITH NOCHECK ADD 
		CONSTRAINT [PK_BarCodeHd_BarCodeId] PRIMARY KEY  CLUSTERED 
		(
			[BarCodeId]
		)  ON [PRIMARY] 
end
GO
if not exists (select * from dbo.sysobjects where id = object_id(N'[TransactionWiseBarCodeDt]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[TransactionWiseBarCodeDt]
	(
		[TransId] [int] NULL,
		[TransRefId] [int] NULL,
		[TransRefCode] [varchar](200) NULL,
		[BarCodeId] [int] NULL,
		[PrdId] [int] NULL,
		[PrdbatId] [int] NULL,
		[Qty] [int] NULL,
		[ColFlag] [int] NULL
	) ON [PRIMARY]
end
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[BLCmpBatCode]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [BLCmpBatCode]
CREATE TABLE [dbo].[BLCmpBatCode]
(
	[CmpBatCode] [nvarchar](100) NULL
) ON [PRIMARY]
GO
if not exists (select * from dbo.sysobjects where id = object_id(N'[PrdOrderQty]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[PrdOrderQty]
	(
		[PrdId] [int] NOT NULL,
		[UOMId] [int] NOT NULL,
		[VariationId] [int] NOT NULL,
		[NormId] [int] NOT NULL,
		[BaseQty] [numeric](38, 0) NULL,
		[Qty] [numeric](12, 2) NOT NULL,
		[Mode] [varchar](4) NOT NULL
	) ON [PRIMARY]
end
GO
if not exists (select * from dbo.sysobjects where id = object_id(N'[PurchaseReceiptProductMapping]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[PurchaseReceiptProductMapping]
	(
		[CompInvNo] [nvarchar](25) NOT NULL,
		[CompInvDate] [datetime] NOT NULL,
		[SpmCode] [nvarchar](50) NOT NULL,
		[PrdId] [int] NOT NULL,
		[PrdCCode] [nvarchar](50) NOT NULL,
		[PrdName] [nvarchar](200) NOT NULL,
		[PrdMapCode] [nvarchar](50) NOT NULL,
		[PrdMapName] [nvarchar](200) NOT NULL,
		[UOMCode] [nvarchar](25) NOT NULL,
		[Qty] [int] NOT NULL,
		[Rate] [numeric](38, 6) NOT NULL,
		[GrossAmount] [numeric](38, 6) NOT NULL,
		[DiscAmount] [numeric](38, 6) NOT NULL,
		[TaxAmount] [numeric](38, 6) NOT NULL,
		[NetAmount] [numeric](38, 6) NOT NULL,
		[FreeSchemeFlag] [nvarchar](5) NOT NULL,
		[Availability] [tinyint] NOT NULL,
		[LastModBy] [tinyint] NOT NULL,
		[LastModDate] [datetime] NOT NULL,
		[AuthId] [tinyint] NOT NULL,
		[AuthDate] [datetime] NOT NULL,
		[SLNo] [int] NULL
	) ON [PRIMARY]
end
GO
if not exists (Select Id,name from Syscolumns where name = 'Status' and id in (Select id from 
	Sysobjects where name ='ReplacementHd'))
begin
	ALTER TABLE [dbo].[ReplacementHd]
	ADD [Status] INT NOT NULL DEFAULT 1 WITH VALUES
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[RptGRNListing_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptGRNListing_Excel]
GO

CREATE TABLE [dbo].[RptGRNListing_Excel]
(
	[PurRcptId] [bigint] NULL,
	[PurRcptRefNo] [nvarchar](50) NULL,
	[CmpInvNo] [nvarchar](1000) NULL,
	[InvDate] [datetime] NULL,
	[PrdId] [int] NULL,
	[PrdDCode] [nvarchar](20) NULL,
	[PrdName] [nvarchar](50) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [nvarchar](50) NULL,
	[InvBaseQty] [int] NULL,
	[RcvdGoodBaseQty] [int] NULL,
	[Uom1] [int] NULL,
	[Uom2] [int] NULL,
	[Uom3] [int] NULL,
	[Uom4] [int] NULL,
	[UnSalBaseQty] [int] NULL,
	[ShrtBaseQty] [int] NULL,
	[ExsBaseQty] [int] NULL,
	[RefuseSale] [tinyint] NULL,
	[PrdUnitLSP] [numeric](38, 6) NULL,
	[PrdGrossAmount] [numeric](38, 6) NULL,
	[UsrId] [int] NULL,
	[Disc] [numeric](38, 6) NULL,
	[Tax] [numeric](38, 6) NULL,
	[Net Amt.] [numeric](38, 6) NULL
) ON [PRIMARY]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[RptPRNPurchaseReturnTemplate]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptPRNPurchaseReturnTemplate]
GO
CREATE TABLE [dbo].[RptPRNPurchaseReturnTemplate]
(
	[Company] [nvarchar](50) NULL,
	[Company Invoice Date] [datetime] NULL,
	[Company Invoice Number] [nvarchar](50) NULL,
	[Date] [datetime] NULL,
	[Discount] [numeric](38, 6) NULL,
	[GRN Date] [datetime] NULL,
	[GRN Number] [nvarchar](50) NULL,
	[Gross Amount] [numeric](38, 6) NULL,
	[LSP] [numeric](38, 6) NULL,
	[MRP] [numeric](38, 6) NULL,
	[Net Amount] [numeric](38, 6) NULL,
	[Product Batch] [nvarchar](100) NULL,
	[Product Company Code] [nvarchar](50) NULL,
	[Product Company Name] [nvarchar](100) NULL,
	[Product Short Code] [nvarchar](50) NULL,
	[Product Short Name] [nvarchar](100) NULL,
	[Pur Quantity Salable] [int] NULL,
	[Pur Quantity Un Salable] [int] NULL,
	[PurRetId] [bigint] NULL,
	[Rate] [numeric](38, 6) NULL,
	[Reason] [nvarchar](50) NULL,
	[Ref Number] [nvarchar](50) NULL,
	[Return Mode] [nvarchar](50) NULL,
	[Return Quantity Salable] [int] NULL,
	[Return Quantity un Salable] [int] NULL,
	[Supplier] [nvarchar](50) NULL,
	[Tax Amount] [numeric](38, 6) NULL,
	[Tax percentage] [numeric](38, 6) NULL,
	[Total Discount Amount] [numeric](38, 6) NULL,
	[Total Gross Amount] [numeric](38, 6) NULL,
	[Total Net Amount] [numeric](38, 6) NULL,
	[Total Tax Amount] [numeric](38, 6) NULL,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL
) ON [PRIMARY]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[RptSISampleTemplate]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptSISampleTemplate]
GO
CREATE TABLE [dbo].[RptSISampleTemplate]
(
	[Bill Ref Number] [nvarchar](50) NULL,
	[Company Sample Scheme Code] [nvarchar](50) NULL,
	[Date] [datetime] NULL,
	[Doc Ref Number] [nvarchar](50) NULL,
	[Due Date for Return] [datetime] NULL,
	[Eligible Qty] [numeric](38, 6) NULL,
	[Eligible Qty UOM] [nvarchar](50) NULL,
	[Issue Qty] [numeric](38, 6) NULL,
	[Issue Qty UOM] [nvarchar](50) NULL,
	[Issued Qty] [numeric](38, 6) NULL,
	[Issued Qty UOM] [nvarchar](50) NULL,
	[IssueId] [int] NULL,
	[Ref Number] [nvarchar](50) NULL,
	[Retailer] [nvarchar](50) NULL,
	[Route] [nvarchar](50) NULL,
	[Salesman] [nvarchar](50) NULL,
	[Sample Product Batch] [nvarchar](100) NULL,
	[Sample Product Company Code] [nvarchar](50) NULL,
	[Sample Product Company Name] [nvarchar](50) NULL,
	[Sample Product Short Name] [nvarchar](50) NULL,
	[Sample Scheme Code] [nvarchar](50) NULL,
	[To be Returned  - Value] [numeric](38, 6) NULL,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL
) ON [PRIMARY]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[RptSRNSalesReturnTemplate]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptSRNSalesReturnTemplate]
GO

CREATE TABLE [dbo].[RptSRNSalesReturnTemplate]
(
	[Distributor Code] [nvarchar](20) NULL,
	[Distributor Name] [nvarchar](50) NULL,
	[Distributor Address1] [nvarchar](50) NULL,
	[Distributor Address2] [nvarchar](50) NULL,
	[Distributor Address3] [nvarchar](50) NULL,
	[PinCode] [int] NULL,
	[PhoneNo] [nvarchar](50) NULL,
	[Tax Type] [tinyint] NULL,
	[TIN Number] [nvarchar](50) NULL,
	[Deposit Amount] [numeric](38, 2) NULL,
	[CST Number] [nvarchar](50) NULL,
	[LST Number] [nvarchar](50) NULL,
	[Licence Number] [nvarchar](50) NULL,
	[Drug Licence Number 1] [nvarchar](50) NULL,
	[Drug1 Expiry Date] [datetime] NULL,
	[Drug Licence Number 2] [nvarchar](50) NULL,
	[Drug2 Expiry Date] [datetime] NULL,
	[Pesticide Licence Number] [nvarchar](50) NULL,
	[Pesticide Expiry Date] [datetime] NULL,
	[SalId] [int] NULL,
	[Invoice Number] [nvarchar](50) NULL,
	[Invoice Date] [datetime] NULL,
	[ReturnId] [int] NULL,
	[Sales Return Number] [nvarchar](50) NULL,
	[Sales Return Date] [datetime] NULL,
	[Sales Man] [nvarchar](50) NULL,
	[Route] [nvarchar](50) NULL,
	[Retailer Code] [nvarchar](50) NULL,
	[Retailer Name] [nvarchar](50) NULL,
	[Retailer Phone Number] [nvarchar](50) NULL,
	[Retailer CST Number] [nvarchar](50) NULL,
	[Retailer Drug Lic  Number] [nvarchar](50) NULL,
	[Retailer Lic Number] [nvarchar](50) NULL,
	[Retailer Tin Number] [nvarchar](50) NULL,
	[Retailer Address] [nvarchar](50) NULL,
	[Product Company Code] [nvarchar](20) NULL,
	[Product Company Name] [nvarchar](50) NULL,
	[Product Short Code] [nvarchar](100) NULL,
	[Product Short Name] [nvarchar](100) NULL,
	[Stock Type] [nvarchar](100) NULL,
	[Return Quantity] [numeric](18, 0) NULL,
	[Selling Rate] [numeric](18, 6) NULL,
	[Gross Amount] [numeric](18, 6) NULL,
	[Special Discount] [numeric](18, 6) NULL,
	[Scheme Discount] [numeric](18, 6) NULL,
	[Distributor Discount] [numeric](18, 6) NULL,
	[Cash Discount] [numeric](18, 6) NULL,
	[Tax Percentage] [numeric](18, 6) NULL,
	[Tax Amount Line Level] [numeric](18, 6) NULL,
	[Line level Net Amount] [numeric](18, 6) NULL,
	[Reason] [nvarchar](100) NULL,
	[Type] [nvarchar](50) NULL,
	[Mode] [nvarchar](50) NULL,
	[Total Gross Amount] [numeric](18, 6) NULL,
	[Total Special Discount] [numeric](18, 6) NULL,
	[Total Scheme Discount] [numeric](18, 6) NULL,
	[Total Distributor Discount] [numeric](18, 6) NULL,
	[Total Cash Discount] [numeric](18, 6) NULL,
	[Total Tax Amount] [numeric](18, 6) NULL,
	[Total Net Amount] [numeric](18, 6) NULL,
	[Total Discount] [numeric](18, 6) NULL,
	[RtrId] [int] NULL,
	[RMID] [int] NULL,
	[SMID] [int] NULL,
	[Credit Note/Replacement Reference No] [nvarchar](50) NULL,
	[Credit Note Reference No] [nvarchar](50) NULL,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL
) ON [PRIMARY]
GO
if not exists (select * from dbo.sysobjects where id = object_id(N'[SalInvHDAmt]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[SalInvHDAmt]
	(
		[SalId] [bigint] NULL,
		[RefCode] [nvarchar](25) NOT NULL,
		[FieldDesc] [nvarchar](100) NOT NULL,
		[BaseQtyAmount] [numeric](18, 6) NULL
	) ON [PRIMARY]
end
GO
if not exists (select * from dbo.sysobjects where id = object_id(N'[SalInvLineAmt]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[SalInvLineAmt]
	(
		[SalId] [bigint] NULL,
		[PrdSlNo] [int] NULL,
		[RefCode] [nvarchar](25) NOT NULL,
		[FieldDesc] [nvarchar](100) NOT NULL,
		[LineUnitAmount] [numeric](18, 6) NULL,
		[LineBaseQtyAmount] [numeric](18, 6) NULL,
		[LineUom1Amount] [numeric](18, 6) NULL,
		[LineUnitPerc] [numeric](10, 6) NULL,
		[LineBaseQtyPerc] [numeric](10, 6) NULL,
		[LineUom1Perc] [numeric](10, 6) NULL,
		[LineEffectAmount] [numeric](18, 6) NULL
	) ON [PRIMARY]
end
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[TempRtrAccStatement]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [TempRtrAccStatement]
GO

CREATE TABLE [dbo].[TempRtrAccStatement]
(
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NULL,
	[AType] [varchar](20) NULL,
	[InvoiceNo] [nvarchar](50) NULL,
	[RefNo] [nvarchar](100) NULL,
	[Opng] [numeric](38, 6) NULL,
	[Debit] [numeric](38, 6) NULL,
	[Credit] [numeric](38, 6) NULL,
	[Balance] [numeric](38, 6) NULL,
	[CBalance] [numeric](38, 6) NULL,
	[RtrAdd1] [nvarchar](50) NULL,
	[RtrAdd2] [nvarchar](50) NULL,
	[RtrAdd3] [nvarchar](50) NULL,
	[RtrPinNo] [int] NULL,
	[RtrTinNo] [nvarchar](50) NULL
) ON [PRIMARY]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_BarCode]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_BarCode]
GO
CREATE TABLE [dbo].[Cn2Cs_Prk_BarCode]
(
	[DistCode] [nvarchar](20) NULL,
	[PrdCCode] [nvarchar](50) NULL,
	[BarCode] [nvarchar](50) NULL,
	[ConvFactor] [int] NULL,
	[DownLoadFlag] [nvarchar](5) NULL
) ON [PRIMARY]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_DailySales_Undelivered]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_DailySales_Undelivered]
GO
CREATE TABLE [dbo].[Cs2Cn_Prk_DailySales_Undelivered]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50) NULL,
	[SalInvNo] [nvarchar](50) NULL,
	[SalInvDate] [datetime] NULL,
	[SalInvAmt] [numeric](38, 6) NULL,
	[SalTaxAmt] [numeric](38, 6) NULL,
	[SalSchAmt] [numeric](38, 6) NULL,
	[SalDisAmt] [numeric](38, 6) NULL,
	[SalSplDis] [numeric](38, 6) NULL,
	[SalRetAmt] [numeric](38, 6) NULL,
	[SalVisAmt] [numeric](38, 6) NULL,
	[SalNetAmt] [numeric](38, 6) NULL,
	[SalDistDis] [numeric](38, 6) NULL,
	[SalTotDedn] [numeric](38, 6) NULL,
	[SalRoundOffAmt] [numeric](38, 6) NULL,
	[Salesman] [nvarchar](100) NULL,
	[Route] [nvarchar](100) NULL,
	[RtrId] [int] NULL,
	[RtrName] [nvarchar](100) NULL,
	[BillMode] [nvarchar](100) NULL,
	[DlvBoyName] [nvarchar](100) NULL,
	[VechName] [nvarchar](100) NULL,
	[SalDlvDate] [datetime] NULL,
	[DbAdjAmt] [numeric](38, 6) NULL,
	[CrAdjAmt] [numeric](38, 6) NULL,
	[OnAccountAmt] [numeric](38, 6) NULL,
	[SalReplaceAmt] [numeric](38, 6) NULL,
	[DeliveryRoute] [nvarchar](100) NULL,
	[PrdCode] [nvarchar](50) NULL,
	[PrdBatCde] [nvarchar](50) NULL,
	[SalInvQty] [int] NULL,
	[SelRateBeforTax] [numeric](38, 6) NULL,
	[SelRateAfterTax] [numeric](38, 6) NULL,
	[SalInvFree] [int] NULL,
	[SalInvTax] [numeric](38, 6) NULL,
	[SalInvSch] [numeric](38, 6) NULL,
	[SalInvDist] [numeric](38, 6) NULL,
	[SalCshDis] [numeric](38, 6) NULL,
	[PrdNetAmt] [numeric](38, 6) NULL,
	[SalInvCashDisc] [numeric](38, 6) NULL,
	[BillStatus] [nvarchar](50) NULL,
	[UploadedDate] [datetime] NULL,
	[UploadFlag] [nvarchar](10) NULL
) ON [PRIMARY]
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_GetBarCodeDt]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_GetBarCodeDt]
GO
-- SELECT * FROM dbo.Fn_GetBarCodeDt('1111')
CREATE  FUNCTION [dbo].[Fn_GetBarCodeDt] 
(
	@Pi_Code AS VARCHAR(100)
)
RETURNS @BarCodeDt TABLE
	(
		BarCodeId	INT ,
		PrdId		INT ,
		PrdCode		VARCHAR(100) ,
		PrdName		VARCHAR(200) ,
		PrdbatId	INT ,
		PrdBatCode	VARCHAR(100) ,
		ConvFact	INT 
	)
AS
/*********************************
* FUNCTION: Fn_GetBarCodeDt
* PURPOSE: Return Bar Code Details
* NOTES:
* CREATED: Boopathy.P 0n 16/09/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
	INSERT INTO @BarCodeDt
	SELECT A.BarCodeId,A.PrdId,A.PrdCode,A.PrdName,C.PrdbatId,B.PrdBatCode,A.ConvFact FROM 
    (SELECT A.BarCodeId,B.PrdId,A.PrdCode,B.PrdName,A.ConvFact FROM BarCodeHd A INNER JOIN Product B 
	ON A.PrdCode=B.PrdCCode   WHERE A.BarCode=@Pi_Code) A INNER JOIN ProductBatch B ON A.PrdId=B.PrdId
	 INNER JOIN (SELECT MAX(A.PrdBatId) AS PrdbatId FROM Productbatch A INNER JOIN 
	(SELECT B.PrdId FROM BarCodeHd A INNER JOIN Product B ON A.PrdCode=B.PrdCCode
	WHERE A.BarCode=@Pi_Code) B ON A.PrdId=B.PrdId) C ON B.PrdbatId=C.PrdbatId
RETURN 
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_GetBatchDtWithStock]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_GetBatchDtWithStock]
GO
-- SELECT * FROM dbo.Fn_GetBatchDtWithStock(73,10362,1)
CREATE  FUNCTION [dbo].[Fn_GetBatchDtWithStock] 
(
	@Pi_PrdId AS INT,
	@Pi_PrdBatId AS INT,
	@Pi_LcnId AS INT
)
RETURNS @BatchDetails TABLE
	(
		PrdBatID		INT ,
		PrdBatCode		VARCHAR(100) ,
		MRP				NUMERIC(18,6) ,
		PurchaseRate	NUMERIC(18,6) ,
		SellRate		NUMERIC(18,6) ,
		StockAvail		INT ,
		PriceId			INT 
	)
AS
/*********************************
* FUNCTION: Fn_GetBarCodeDt
* PURPOSE: Return Bar Code Details
* NOTES:
* CREATED: Boopathy.P 0n 16/09/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
		INSERT INTO @BatchDetails
		SELECT A.PrdBatID,A.PrdBatCode,B.PrdBatDetailValue AS MRP, D.PrdBatDetailValue AS PurchaseRate,
		K.PrdBatDetailValue AS SellRate,0 as StockAvail,B.PriceId FROM ProductBatch A (NOLOCK) 
		INNER JOIN ProductBatchDetails B (NOLOCK) ON A.PrdBatId = B.PrdBatID AND B.DefaultPrice=1 INNER JOIN 
		BatchCreation C (NOLOCK) ON C.BatchSeqId = A.BatchSeqId AND B.SlNo = C.SlNo AND C.MRP = 1 INNER JOIN 
		ProductBatchDetails D (NOLOCK) ON A.PrdBatId = D.PrdBatID AND D.DefaultPrice=1 INNER JOIN 
		BatchCreation E (NOLOCK) ON E.BatchSeqId = A.BatchSeqId AND D.SlNo = E.SlNo AND E.ListPrice = 1 
		INNER JOIN ProductBatchDetails K (NOLOCK) ON A.PrdBatId = K.PrdBatID AND K.DefaultPrice=1 
		INNER JOIN BatchCreation H (NOLOCK) ON H.BatchSeqId = A.BatchSeqId AND K.SlNo = H.SlNo AND H.SelRte = 1 
		INNER JOIN Product G (NOLOCK) ON G.PrdId = A.PrdId 
--		INNER JOIN ProductBatchLocation F (NOLOCK) ON F.PrdBatId = A.PrdBatId 
		WHERE A.Status = 1 AND A.PrdId=@Pi_PrdId  Order By A.PrdBatId DESC 
		--AND A.PrdbatId= @Pi_PrdBatId  --And (F.PrdBatLcnSih - F.PrdBatLcnRessih) > 0 AND F.LcnId = @Pi_LcnId
RETURN 
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_AutoBatchTransfer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_AutoBatchTransfer]
GO
/*
BEGIN TRANSACTION
TRUNCATE TABLE ErrorLog
SELECT * FROM ErrorLog
----SELECT PBL.LcnId,PBL.PrdBatId,(PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) AS SalStock,(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih) AS UnSalStock,
----		(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre) AS OfferStock
----		FROM ProductBatchLocation PBL WHERE PBL.PrdBatId>23999
----SELECT PBL.LcnId,PBL.PrdBatId,(PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) AS SalStock,(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih) AS UnSalStock,
----		(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre) AS OfferStock
----		FROM ProductBatchLocation PBL WHERE PBL.PrdBatId<23999
EXEC Proc_AutoBatchTransfer 33113,0
--SELECT PBL.LcnId,PBL.PrdBatId,(PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) AS SalStock,(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih) AS UnSalStock,
--		(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre) AS OfferStock
--		FROM ProductBatchLocation PBL WHERE PBL.PrdBatId>23999
--SELECT PBL.LcnId,PBL.PrdBatId,(PBL.PrdBatLcnSih-PBL.PrdBatLcnRessih) AS SalStock,(PBL.PrdBatLcnUih-PBL.PrdBatLcnResUih) AS UnSalStock,
--		(PBL.PrdBatLcnFre-PBL.PrdBatLcnResFre) AS OfferStock
--		FROM ProductBatchLocation PBL WHERE PBL.PrdBatId<23999
--SELECT * FROM StockLedger WHERE TransDate='2010-02-10'
--SELECT * FROM StockLedger WHERE PrdbatId>23999
--SELECT * FROM ProductBatchLocation WHERE PrdbatId>23999
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE     PROCEDURE [dbo].[Proc_AutoBatchTransfer]
(
	@Pi_OldMaxPrdBatId	INT,
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
	
	SET @DestTabname='ProductBatch'
	SET @Fldname='PrdBatId'
	SET @Tabname = 'ETL_Prk_ProductBatch'
	SET @Exist=0
	
	DECLARE Cur_ProductBatch CURSOR
	FOR SELECT PrdId,PrdBatId,PrdBatCode FROM ProductBatch
	WHERE PrdBatId >@Pi_OldMaxPrdBatId ORDER BY PrdId,PrdBatId,PrdBatCode
	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId,@BatchCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		--SELECT 'Nanda'
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
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdId,@PrdBatId,@BatchCode
	END
	CLOSE Cur_ProductBatch
	DEALLOCATE Cur_ProductBatch
	RETURN	
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_BLDailySales_Undelivered]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_BLDailySales_Undelivered]
GO
/*
BEGIN TRANSACTION
EXEC Proc_BLDailySales_Undelivered 0
SELECT * FROM Cs2Cn_Prk_DailySales_Undelivered ORDER BY SlNo
ROLLBACK TRANSACTION
*/
CREATE     PROCEDURE [dbo].[Proc_BLDailySales_Undelivered]
(
	@Po_ErrNo INT OUTPUT
)
AS
SET NOCOUNT ON
/*********************************
* PROCEDURE		: Proc_BLDailySales_Undelivered
* PURPOSE		: To Extract Undelivered Bill Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 20/01/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
	DECLARE @CmpId 		AS INTEGER
	DECLARE @DistCode	As nVarchar(50)
	DECLARE @ChkDate	AS DATETIME
	DELETE FROM Cs2Cn_Prk_DailySales_Undelivered WHERE UploadFlag = 'Y'
	SELECT @CmpID = CmpId FROM Company WHERE DefaultCompany = 1	
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where procId = 1
	SET @Po_ErrNo=0 
	INSERT INTO Cs2Cn_Prk_DailySales_Undelivered 
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
		Route		,
		RtrId		,
		RtrName		,
		BillMode	,
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
	A.TotalDeduction,A.SalRoundOffAmt,B.SMName,C.RMName,A.RtrId ,A.BillMode,D.DlvBoyName,
	E.VehicleRegNo,A.SalDlvDate,A.DBAdjAmount,A.CRAdjAmount,OnAccountAmount,
	ReplacementDiffAmount,F.RMName,H.PrdCCode,I.CmpBatCode,G.PrdUnitSelRate,A.SalSplDiscAmount,R.RtrName
	UNION ALL
	SELECT 	@DistCode,A.SalInvNo ,A.SalInvDate ,A.SalGrossAmount ,A.SalTaxAmount,
	A.SalSchDiscAmount,A.SalCDAmount,A.SalSplDiscAmount,A.MarketRetAmount ,
	A.WindowDisplayAmount,A.SalNetAmt,A.SalDBDiscAmount ,A.TotalDeduction ,
	A.SalRoundOffAmt ,B.SMName ,C.RMName ,A.RtrId ,R.RtrName ,
	(CASE A.BillMode WHEN 1 THEN 'Cash' ELSE 'Credit' END) AS BillMode,
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
	A.TotalDeduction,A.SalRoundOffAmt,B.SMName,C.RMName,A.RtrId ,A.BillMode,D.DlvBoyName,
	E.VehicleRegNo,A.SalDlvDate,A.DBAdjAmount,A.CRAdjAmount,OnAccountAmount,
	ReplacementDiffAmount,F.RMName,H.PrdCCode,I.CmpBatCode,G.PrdUnitSelRate,A.SalSplDiscAmount,R.RtrName
	UPDATE SalesInvoice SET Upload=1 WHERE Upload=0 AND SalInvNo IN (SELECT DISTINCT
	SalInvNo FROM Cs2Cn_Prk_DailySales_Undelivered WHERE BillStatus='Cancelled') AND Dlvsts=3
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BarCode]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BarCode]
GO
-- EXEC Proc_Cn2Cs_BarCode 0
-- SELECT * FROM ErrorLog
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_BarCode]
(
	@Po_ErrNo INT OUTPUT
)
AS
/**************************************************************************************************
* PROCEDURE: Proc_Cn2Cs_BarCode
* PURPOSE: To Insert and Update records Of Barcode
* CREATED: Boopathy.P on 20/09/2010
* DATE         AUTHOR       DESCRIPTION
****************************************************************************************************
**************************************************************************************************/
SET NOCOUNT ON
BEGIN
	
	DECLARE @ErrDesc	AS VARCHAR(1000)
	DECLARE @TabName	AS VARCHAR(200)
	DECLARE @GetKey		AS INT
	DECLARE @Taction	AS INT
	DECLARE @sSQL		AS VARCHAR(4000)
	DECLARE @iCnt		AS INT
	DECLARE @BarCode	AS VARCHAR(200)
	DECLARE @PrdCode	AS VARCHAR(200)
	DECLARE @ConvFact	AS INT
	DECLARE @BarCodeId	AS INT
	DECLARE @PrdId		AS INT
	SET @TabName = 'Cn2CS_Prk_BarCode'
	SET @Po_ErrNo =0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'PrdToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE PrdToAvoid	
	END
	CREATE TABLE PrdToAvoid
	(
		PrdCode		NVARCHAR(50)
	)
	
	INSERT INTO PrdToAvoid
	SELECT PrdCCode FROM Cn2CS_Prk_BarCode WHERE PrdCCode NOT IN (SELECT PrdCCode from PRODUCT) AND DownloadFlag='D'
	INSERT INTO Errorlog 
	SELECT 1,@TabName,'Product Code', PrdCode + ' does not exixts' FROM PrdToAvoid
	DECLARE Cur_SchMaster CURSOR
	FOR SELECT BarCode,PrdCCode,ConvFactor FROM Cn2CS_Prk_BarCode WHERE DownloadFlag='D' 
			AND PrdCCode NOT IN (SELECT PrdCode FROM PrdToAvoid) 
	OPEN Cur_SchMaster
	FETCH NEXT FROM Cur_SchMaster INTO @BarCode,@PrdCode,@ConvFact
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Po_ErrNo =0
		SET @Taction = 2
		
		IF LTRIM(RTRIM(@BarCode))= ''
		BEGIN
			SET @ErrDesc = 'BarCode should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'BarCode',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@PrdCode))= ''
		BEGIN
			SET @ErrDesc = 'Product Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@ConvFact))= '' OR CAST(LTRIM(RTRIM(@ConvFact)) AS INT) <=0
		BEGIN
			SET @ErrDesc = 'Convertion Factor should be greater than Zero :' + LTRIM(RTRIM(@PrdCode))
			INSERT INTO Errorlog VALUES (1,@TabName,'Convertion Factor',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		IF @Po_ErrNo=0
		BEGIN
			SELECT @PrdId=PrdId FROM Product WHERE PrdCCode=@PrdCode
			IF EXISTS (SELECT * FROM BarCodeHd WHERE BarCode=LTRIM(RTRIM(@BarCode)) AND PrdCode=LTRIM(RTRIM(@PrdCode))) 
			BEGIN
				SELECT @BarCodeId=BarCodeId FROM BarCodeHd WHERE BarCode=LTRIM(RTRIM(@BarCode)) AND PrdCode=LTRIM(RTRIM(@PrdCode))
				SET @Taction = 1
			END
			ELSE
			BEGIN
				SELECT @BarCodeId=ISNULL(MAX(BarCodeId),0)+1 FROM BarCodeHd
				SET @Taction = 2
			END
			IF @Taction = 1
			BEGIN
				UPDATE BarCodeHd Set ConvFact=@ConvFact WHERE BarCode=LTRIM(RTRIM(@BarCode)) AND PrdCode=LTRIM(RTRIM(@PrdCode))
			END
			ELSE
			BEGIN
				INSERT INTO BarCodeHd
				SELECT @BarCodeId,LTRIM(RTRIM(@BarCode)),LTRIM(RTRIM(@PrdCode)),@ConvFact
			END
		END
		FETCH NEXT FROM Cur_SchMaster INTO  @BarCode,@PrdCode,@ConvFact
	END
	CLOSE Cur_SchMaster
	DEALLOCATE Cur_SchMaster
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ImportBarCode]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ImportBarCode]
GO
CREATE  PROCEDURE [dbo].[Proc_ImportBarCode]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportBarCode
* PURPOSE	: To Insert and Update records  from xml file in the Table BarCodeHd
* CREATED	: Boopathy
* CREATED DATE	: 20/09/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records	
	
	DELETE FROM Cn2CS_Prk_BarCode WHERE DownloadFlag='Y'
	INSERT INTO Cn2CS_Prk_BarCode
			SELECT  [DistCode] ,[PrdCCode],[BarCode],[ConvFactor],'D'
			FROM 	OPENXML (@hdoc,'/Root/Console2CS_BarCode ',1)
			WITH (
				[DistCode]	 VARCHAR(200),
				[PrdCCode]	 VARCHAR(200),
				[BarCode]	 VARCHAR(200),
				[ConvFactor]	 INT
		
			     ) XMLObj
EXECUTE sp_xml_removedocument @hDoc
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptHierarchyWiseSalesReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptHierarchyWiseSalesReport]
GO
--EXEC Proc_RptHierarchyWiseSalesReport 218,1,0,'BNLB',0,0,1
CREATE PROCEDURE [dbo].[Proc_RptHierarchyWiseSalesReport]
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
/**********************************************************************************************
* PROCEDURE  : Proc_RptHierarchyWiseSalesReport
* PURPOSE    : To Generate Hierarchy Wise Sales Report
* CREATED BY : R.Vasantharaj 
* CREATED ON : 27.01.2011 
* MODIFICATION:
************************************************************************************************/
SET NOCOUNT ON
BEGIN
DECLARE @NewSnapId 	AS	INT
DECLARE @DBNAME		AS 	nvarchar(50)
DECLARE @TblName 	AS	nvarchar(500)
DECLARE @TblStruct 	AS	nVarchar(4000)
DECLARE @TblFields 	AS	nVarchar(4000)
DECLARE @sSql		AS 	nVarChar(4000)
DECLARE @ErrNo	 	AS	INT
DECLARE @PurDBName	AS	nVarChar(100)
--Filter Variable
DECLARE @FromDate	 AS	DATETIME
DECLARE @ToDate	 	 AS	DATETIME
DECLARE @CmpId       AS  INT
DECLARE @SMId 		 AS	INT
DECLARE @RMId	 	 AS	INT
DECLARE @RtrId	 	 AS	INT
DECLARE @CtgLevelId	 AS	INT
DECLARE @RtrClassId	 AS	INT
DECLARE @CtgMainId 	 AS	INT
DECLARE @PDC	     AS	INT
DECLARE @PrdCatId	 AS	INT
DECLARE @PrdId		 AS	INT
DECLARE @HirMainId	 AS INT
DECLARE @CtgValue    AS INT
DECLARE	@EXLFlag	 AS	INT
DECLARE @CancelValue AS	INT
--Till Here
--EXEC Proc_ReturnRptProduct 218,1
EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
EXEC Proc_GetProductwiseHierarchy
--Assgin Value for the Filter Variable
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @HirMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
SET @CtgValue=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
SET @CancelValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,193,@Pi_UsrId))
SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
--Till Here
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
--Till Here'
CREATE TABLE #RptHirerarchyWiseSales
		(
	    [Salesman Name] NVARCHAR(100),
		[Product/Band]  NVARCHAR(4000),
		[FreeQty]       INT,
		[Saleable Qty]  INT,
		[Gross Amt]     NUMERIC(18, 2),
		[Selling Rate]  NUMERIC(18, 2)
		)
SET @TblName = 'RptHirerarchyWiseSales'
SET @TblStruct = '
		[Salesman Name] NVARCHAR(100),
		[Product/Band]  NVARCHAR(4000),
		[FreeQty]       INT,
		[Saleable Qty]  INT,
		[Gross Amt]     NUMERIC(18, 2),
		[Selling Rate]  NUMERIC(18, 2)'
SET @TblFields = '[Salesman Name],[Product/Band],[FreeQty],[Saleable Qty],[Gross Amt],[Selling Rate]'
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
    IF @CancelValue = 2
	BEGIN
		SELECT DISTINCT Prdid, C.PrdCtgValName INTO #Tempa 
		FROM 
			ProductCategoryValue C 
			INNER JOIN ProductCategoryValue D ON
			D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode as nvarchar(4000)) + '%'
			INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
			INNER JOIN  ProductCategoryLevel PCL ON PCL.CmpPrdCtgId=C.CmpPrdCtgId 
		WHERE  PCL.CmpPrdCtgId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
			 	INSERT INTO #RptHirerarchyWiseSales([Salesman Name],[Product/Band],[FreeQty],[Saleable Qty],[Gross Amt],[Selling Rate])
				SELECT DISTINCT 				
					S.SMName AS [Salesman Name],A.PrdCtgValName AS [Product/Band],SIP.SalSchFreeQty AS [FreeQty],
                    SUM(SIP.BaseQty) AS [Saleable Qty],SUM(SIP.PrdGrossAmount) AS [Gross Amt],
                    SUM(SIP.PrdGrossAmount)/SUM(SIP.BaseQty) AS [Selling Rate] 
				FROM #Tempa A
						INNER JOIN  SalesInvoiceProduct SIP ON SIP.PrdId=A.PrdId
						INNER JOIN  SalesInvoice SI ON SI.SalId=SIP.SalId
						INNER JOIN  Salesman S ON S.SMId= SI.SMId
						INNER JOIN  RouteMaster RM ON RM.RMId=SI.RMId
						INNER JOIN  Retailer R ON R.RtrId=SI.RtrId
						INNER JOIN  RetailerValueClassMap RVCM WITH (NOLOCK)ON R.Rtrid = RVCM.RtrId 
						INNER JOIN  RetailerValueClass RVC WITH (NOLOCK) ON RVCM.RtrValueClassId = RVC.RtrClassId
							            AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
						                RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
						INNER JOIN Product P ON SIP.PrdId = P.Prdid 
				WHERE (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
									SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						 AND (SI.RMId=(CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
									SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
									
						 AND (SI.SMId=(CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
									SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				
						 AND (SI.SalInvDate Between @FromDate and @ToDate) AND SI.DlvSts NOT IN (3)
				AND 
				(SIP.PrdId = (CASE @PrdId WHEN 0 THEN SIP.PrdId Else 0 END) OR
					SIP.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
                GROUP BY S.SMName,A.PrdCtgValName,SIP.SalSchFreeQty--SIP.PrdUnitSelRate
    END
		ELSE IF @CancelValue=1
		BEGIN
            SELECT DISTINCT Prdid, C.PrdCtgValName INTO #Tempb 
		FROM 
			ProductCategoryValue C 
			INNER JOIN ProductCategoryValue D ON
			D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode as nvarchar(4000)) + '%'
			INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
			INNER JOIN  ProductCategoryLevel PCL ON PCL.CmpPrdCtgId=C.CmpPrdCtgId 
		WHERE  PCL.CmpPrdCtgId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
				INSERT INTO #RptHirerarchyWiseSales([Salesman Name],[Product/Band],[FreeQty],[Saleable Qty],[Gross Amt],[Selling Rate])
				SELECT DISTINCT 				
					S.SMName AS [Salesman Name],B.PrdCtgValName AS [Product/Band],SIP.SalSchFreeQty AS [FreeQty],
                    SUM(SIP.BaseQty) AS [Saleable Qty],SUM(SIP.PrdGrossAmount) AS [Gross Amt],
                    SUM(SIP.PrdGrossAmount)/SUM(SIP.BaseQty) AS [Selling Rate] 
				FROM #Tempb B
						INNER JOIN  SalesInvoiceProduct SIP ON SIP.PrdId=B.PrdId
						INNER JOIN  SalesInvoice SI ON SI.SalId=SIP.SalId
						INNER JOIN  Salesman S ON S.SMId= SI.SMId
						INNER JOIN  RouteMaster RM ON RM.RMId=SI.RMId
						INNER JOIN  Retailer R ON R.RtrId=SI.RtrId
						INNER JOIN  RetailerValueClassMap RVCM WITH (NOLOCK)ON R.Rtrid = RVCM.RtrId 
						INNER JOIN  RetailerValueClass RVC WITH (NOLOCK) ON RVCM.RtrValueClassId = RVC.RtrClassId
							            AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
						                RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				WHERE (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
									SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						 AND (SI.RMId=(CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
									SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
									
						 AND (SI.SMId=(CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
									SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				
						 AND (SI.SalInvDate Between @FromDate and @ToDate) AND SI.DlvSts IN(4,5)
                         AND (SIP.PrdId = (CASE @PrdId WHEN 0 THEN SIP.PrdId Else 0 END) OR
					          SIP.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
                GROUP BY S.SMName,B.PrdCtgValName,SIP.SalSchFreeQty--,SIP.PrdUnitSelRate
     END
END
    --Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId	
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptHirerarchyWiseSales
	-- Till Here
SELECT Distinct  * FROM #RptHirerarchyWiseSales 
RETURN
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptPendingOrderReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptPendingOrderReport]
GO
Create proc [dbo].[Proc_RptPendingOrderReport]
--EXEC Proc_RptPendingOrderReport 226,1,0,'BNLB',0,0,1
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
/**********************************************************************************************
* PROCEDURE  : Proc_RptPendingOrderReport
* PURPOSE    : To Generate Pending Order Report
* CREATED BY : R.Vasantharaj 
* CREATED ON : 06.04.2011 
* MODIFICATION:
************************************************************************************************/
AS
SET NOCOUNT ON 
BEGIN
DECLARE @NewSnapId 	AS	INT
DECLARE @DBNAME		AS 	nvarchar(50)
DECLARE @TblName 	AS	nvarchar(500)
DECLARE @TblStruct 	AS	nVarchar(4000)
DECLARE @TblFields 	AS	nVarchar(4000)
DECLARE @sSql		AS 	nVarChar(4000)
DECLARE @ErrNo	 	AS	INT
DECLARE @PurDBName	AS	nVarChar(100)
--Filter Variable
DECLARE @FromDate	 AS	DATETIME
DECLARE @ToDate	 	 AS	DATETIME
DECLARE @CmpId       AS  INT
DECLARE @SMId 		 AS	INT
DECLARE @RMId	 	 AS	INT
DECLARE @RtrId	 	 AS	INT
DECLARE @CtgLevelId	 AS	INT
DECLARE @RtrClassId	 AS	INT
DECLARE @CtgMainId 	 AS	INT
DECLARE @HirMainId   AS INT
DECLARE @CtgValue    AS INT
DECLARE @PrdCatId	 AS	INT
DECLARE @PrdId		 AS	INT
--Till Here
EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
EXEC Proc_GetProductwiseHierarchy
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @HirMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
SET @CtgValue=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
CREATE TABLE #RptPendingOrder
	(
		RtrId         INT,
		RetailerName  NVARCHAR(1000),
		OrderNo       NVARCHAR(100),         
		OrderDate     DATETIME,
		PrdId         INT,
		Brand         NVARCHAR(4000),               
		ProductName   NVARCHAR(4000),
		Qty           INT,
		[Value]       NUMERIC(18, 2)
	)
SET @TblName = 'RptPendingOrder'
SET @TblStruct = '
		RtrId         INT,
		RetailerName  NVARCHAR(1000),
		OrderNo       NVARCHAR(100),         
		OrderDate     DATETIME,
		PrdId         INT,
		Brand         NVARCHAR(4000),               
		ProductName   NVARCHAR(4000),
		Qty           INT,
		[Value]       NUMERIC(18, 2)'
SET @TblFields = 'RtrId,RetailerName,OrderNo,OrderDate,PrdId,Brand,ProductName,Qty,[Value]'
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
INSERT INTO #RptPendingOrder(RtrId,RetailerName,OrderNo,OrderDate,PrdId,Brand,ProductName,Qty,[Value]) 
SELECT F.RtrId,G.RtrName AS RetailerName,E.OrderNo,F.OrderDate,E.PrdId,A.PrdCtgValName AS Brand,C.PrdName AS ProductName,(E.TotalQty-E.BilledQty)AS Qty,
((E.TotalQty-E.BilledQty)* J.PrdBatDetailValue) AS Value 
FROM ProductCategoryValue A
	INNER JOIN  ProductCategoryValue B ON B.PrdCtgValLinkCode LIKE Cast(A.PrdCtgValLinkCode as nvarchar(4000)) + '%'
	INNER JOIN  Product C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
	INNER JOIN  ProductCategoryLevel D ON D.CmpPrdCtgId=A.CmpPrdCtgId
	INNER JOIN  OrderBookingProducts E WITH(NOLOCK) ON C.PrdId=E.PrdId 
	INNER JOIN  OrderBooking F WITH(NOLOCK)ON F.OrderNo=E.OrderNo
	INNER JOIN  Retailer G WITH(NOLOCK) ON F.RtrId=G.RtrId
	INNER JOIN  ProductCategoryValue H WITH(NOLOCK) ON C.PrdCtgValMainId=H.PrdCtgValMainId
	INNER JOIN  ProductBatch I WITH(NOLOCK) ON E.PrdId=I.PrdId and C.PrdId=I.PrdId and E.PrdBatId=I.PrdBatId
	INNER JOIN  ProductBatchDetails J WITH(NOLOCK) ON E.PrdBatId=J.PrdBatId and I.PrdBatId=J.PrdBatId 
	INNER JOIN  BatchCreation K WITH(NOLOCK) ON J.BatchSeqId=K.BatchSeqId and J.SlNo=K.SlNo and K.FieldDesc='Selling'
	INNER JOIN  RouteMaster L ON F.RmId=L.RmId
	INNER JOIN  Salesman M ON F.SMId=M.SMId
WHERE (G.RtrId = (CASE @RtrId WHEN 0 THEN G.RtrId ELSE 0 END) OR
					 G.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						 AND (L.RMId=(CASE @RMId WHEN 0 THEN L.RMId ELSE 0 END) OR
									L.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
									
						 AND (M.SMId=(CASE @SMId WHEN 0 THEN M.SMId ELSE 0 END) OR
									M.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				
						 AND (F.OrderDate Between @FromDate and @ToDate) 
				         
                         AND D.CmpPrdCtgId IN (SELECT iCountid FROM Fn_ReturnRptFilters(226,16,1))
    --Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId	
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptPendingOrder
	-- Till Here
SELECT Distinct  * FROM #RptPendingOrder ORDER BY OrderNo  
RETURN
END
GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptRetailerAccStatement]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptRetailerAccStatement]
GO
---EXEC Proc_RptRetailerAccStatement 216,1,0,'NV02100309',0,0,1
CREATE   PROCEDURE [dbo].[Proc_RptRetailerAccStatement]
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptRetailerAccStatement
* PURPOSE	: To get the Retailer Accounting Statements
* CREATED	: Mohamed Bahurudeen .G
* CREATED DATE	: 07/04/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON
	DECLARE @NewSnapId 		AS	INT
	DECLARE @DBNAME			AS 	NVARCHAR(50)
	DECLARE @TblName 		AS	NVARCHAR(500)
	DECLARE @TblStruct 		AS	NVARCHAR(4000)
	DECLARE @TblFields 		AS	NVARCHAR(4000)
	DECLARE @sSql			AS 	NVARCHAR(4000)
	DECLARE @ErrNo	 		AS	INT
	DECLARE @PurDBName		AS	nVarChar(50)
	DECLARE @Opng			AS	FLOAT
	DECLARE @Cnt			AS	INT
	DECLARE @Inc			AS	INT
	DECLARE @Bal			AS	FLOAT
	--Filter Variable
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @RtrId		    AS	INT
	--Till Here
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @RtrId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	--Till Here
	CREATE TABLE #RptRtrAccStatement
	(
			Id				BIGINT,
			DATE			DATETIME,
			ATYPE	 		NVARCHAR(20),
			INVOICENO 		NVARCHAR(50),
			REFNO	 		NVARCHAR(100),
			OPNG			NUMERIC (38,6),
			DEBIT			NUMERIC (38,6),
			CREDIT			NUMERIC	(38,6),
			BALANCE			NUMERIC	(38,6),
			CBALANCE		NUMERIC	(38,6),
			RTRADD1 		NVARCHAR(50),
			RTRADD2 		NVARCHAR(50),
			RTRADD3 		NVARCHAR(50),
			RTRPINNO 		NVARCHAR(50),
			RTRTINNO 		NVARCHAR(50)
	)
	SET @TblName = 'RptRtrAccStatement'
	SET @TblStruct = '	
						Id				BIGINT,
						DATE			DATETIME,
						ATYPE	 		NVARCHAR(20),
						INVOICENO 		NVARCHAR(50),
						REFNO	 		NVARCHAR(100),
						OPNG			NUMERIC (38,6),
						DEBIT			NUMERIC (38,6),
						CREDIT			NUMERIC	(38,6),
						BALANCE			NUMERIC	(38,6),
						CBALANCE		NUMERIC	(38,6),
						RTRADD1 		NVARCHAR(50),
						RTRADD2 		NVARCHAR(50),
						RTRADD3 		NVARCHAR(50),
						RTRPINNO 		NVARCHAR(50),
						RTRTINNO 		NVARCHAR(50)	'
	SET @TblFields = 'Id,DATE,ATYPE,INVOICENO,REFNO,OPNG,DEBIT,BALANCE,CBALANCE'
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
		SET @Opng = (SELECT SUM(Op.Opng) as Opng FROM (
										SELECT isnull(Sum(SalNetamt),0) as Opng FROM SalesInvoice
										WHERE
											(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
												RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
											AND SalInvDate < @FromDate AND DlvSts IN(4,5)
										UNION ALL
										SELECT (-1) * isnull(sum(isnull(RtnNetAmt,0)+isnull(RtnRoundOffAmt,0)),0) as Opng FROM ReturnHeader
										WHERE	
											(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
												RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
											AND ReturnDate < @FromDate AND Status IN(0)
										UNION ALL
										SELECT isnull(Sum(Amount),0) as Opng FROM DebitNoteRetailer
										WHERE	
											(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
												RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
											AND DbNoteDate < @FromDate AND Status IN(1)
										UNION ALL
										SELECT (-1) * isnull(Sum(Amount),0) as Opng FROM CreditNoteRetailer
										WHERE
											(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
												RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
											AND CrNoteDate < @FromDate AND Status IN(1) AND TransId<>30
										UNION ALL
										SELECT (-1) * isnull(Sum(DiffAmount),0) as Opng FROM ReplacementHD
										WHERE	
											(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
												RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
											AND RepDate < @FromDate
										
										UNION ALL
										SELECT (-1) * isnull(Sum(RI.SalInvAmt),0) as Opng FROM ReceiptInvoice RI
											INNER JOIN Receipt RE ON RE.InvRcpNo=RI.InvRcpNo
											INNER JOIN SalesInvoice SI on RI.SalId=SI.SalId
										WHERE
											(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
												RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
											AND RE.InvRcpDate < @FromDate AND InvInsSta NOT IN(4) and RI.CancelStatus IN(1)
									    ) Op)
		TRUNCATE TABLE TempRtrAccStatement
		INSERT INTO TempRtrAccStatement
		SELECT Date,Type,InvoiceNo,RefNo,Opng,Debit,Credit,0 as Balance,0 as CBalance,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrTINNo From
										(
											SELECT SalInvDate as Date,'Invoice' as Type,SalInvNo as InvoiceNo,'' as RefNo,@Opng as Opng,isnull(SalNetamt,0) as Debit,0 as Credit,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrTINNo  FROM SalesInvoice SI
												INNER JOIN Retailer Rtr on SI.RtrId=Rtr.RtrId
											WHERE
												(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
													SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
												AND (SalInvDate Between @FromDate and @ToDate) AND DlvSts IN(4,5)
											UNION ALL
											SELECT ReturnDate as Date,'Return' as Type,ReturnCode as InvoiceNo,SalInvNo as RefNo,@Opng as Opng,0 as Debit,(isnull(RtnNetAmt,0)+isnull(RtnRoundOffAmt,0)) as Credit,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrTINNo FROM ReturnHeader Rh
												INNER JOIN SalesInvoice SI on Rh.SalId=SI.SalId
												INNER JOIN Retailer Rtr on SI.RtrId=Rtr.RtrId
											WHERE
												(Rh.RtrId = (CASE @RtrId WHEN 0 THEN Rh.RtrId ELSE 0 END) OR
														Rh.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
												AND (ReturnDate Between @FromDate and @ToDate) AND Status IN(0)
											UNION ALL
											SELECT DbNoteDate as Date,'Debit Note' as Type,DbNoteNumber as InvoiceNo,PostedRefNo as RefNo,
												@Opng as Opng,isnull(Amount,0) as Debit,0 as Credit,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrTINNo 
												FROM DebitNoteRetailer Dr
												INNER JOIN Retailer Rtr on Dr.RtrId=Rtr.RtrId 
											WHERE	
												(Dr.RtrId = (CASE @RtrId WHEN 0 THEN Dr.RtrId ELSE 0 END) OR
														Dr.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
												AND (DbNoteDate Between @FromDate and @ToDate) AND Status IN(1)
											UNION ALL
											SELECT CrNoteDate as Date,'Credit Note' as Type,CrNoteNumber as InvoiceNo,PostedRefNo as RefNo,
													@Opng as Opng,0 as Debit,isnull(Amount,0) as Credit,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrTINNo 
											FROM CreditNoteRetailer Cr
												INNER JOIN Retailer Rtr on Cr.RtrId=Rtr.RtrId	
											WHERE	
												(Cr.RtrId = (CASE @RtrId WHEN 0 THEN Cr.RtrId ELSE 0 END) OR
														Cr.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
												AND (CrNoteDate Between @FromDate and @ToDate) AND Status IN(1) AND TransId<>30
											UNION ALL
											SELECT RepDate as Date,'Replacement' as Type,RepRefNo as InvoiceNo,DocRefNo as RefNo,@Opng as Opng,(CASE WHEN ((-1) * isnull(DiffAmount,0))<=0 THEN 0 ELSE ((-1) * isnull(DiffAmount,0)) END) as Debit,(CASE WHEN isnull(DiffAmount,0)<=0 THEN 0 ELSE isnull(DiffAmount,0) END) as Credit,RtrAdd1,RtrAdd2,RtrAdd3,RtrPinNo,RtrTINNo FROM ReplacementHD Rph
												INNER JOIN Retailer Rtr on Rph.RtrId=Rtr.RtrId
											WHERE
												(Rph.RtrId = (CASE @RtrId WHEN 0 THEN Rph.RtrId ELSE 0 END) OR
														Rph.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
												AND (RepDate Between @FromDate and @ToDate)
											UNION ALL
											SELECT RE.InvRcpDate as Date,'Collection' as Type,RI.InvRcpNo as InvoiceNo,Replace(RI.InvInsNo,'0','') as RefNo,55 as Opng,0 as Debit,
													isnull(SUM(RI.SalInvAmt),0) as Credit,Rtr.RtrAdd1,Rtr.RtrAdd2,Rtr.RtrAdd3,Rtr.RtrPinNo,Rtr.RtrTINNo
												FROM ReceiptInvoice RI
												INNER JOIN Receipt RE ON RE.InvRcpNo=RI.InvRcpNo
												INNER JOIN SalesInvoice SI on RI.SalId=SI.SalId
												INNER JOIN Retailer Rtr on SI.RtrId=Rtr.RtrId
											WHERE
												(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
														SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
												AND (RE.InvRcpDate Between @FromDate and @ToDate) AND InvInsSta NOT IN(4) AND RI.CancelStatus IN(1)
											GROUP BY  RE.InvRcpDate,RI.InvRcpNo,RI.InvInsNo,Rtr.RtrAdd1,Rtr.RtrAdd2,Rtr.RtrAdd3,Rtr.RtrPinNo,
													Rtr.RtrTINNo
										) S
		ORDER BY Date ASC
		SET @Cnt = (Select Count(Date) from TempRtrAccStatement)
		SET @Inc = 1
		SET @Bal = @Opng
		WHILE @Inc <= @Cnt
			BEGIN
				SET @Bal = (Select (@Bal+Debit)-Credit as Balance from TempRtrAccStatement Where Id = @Inc)
				UPDATE TempRtrAccStatement SET Balance = @Bal Where Id = @Inc
				SET @Inc = @Inc + 1
			END
		UPDATE TempRtrAccStatement SET CBalance = @Bal
		INSERT  INTO  #RptRtrAccStatement SELECT * FROM TempRtrAccStatement
		DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptRtrAccStatement
		SELECT * FROM #RptRtrAccStatement
	END
END
GO
--IF exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptSalesRegister]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
--drop procedure [dbo].[Proc_RptSalesRegister]
--GO
------ Exec Proc_RptSalesRegister 227,1,0,'yg',0,0,1
--CREATE Procedure [dbo].[Proc_RptSalesRegister]
--(
--	@Pi_RptId			INT,
--	@Pi_UsrId			INT,
--	@Pi_SnapId			INT, 
--	@Pi_DbName			Nvarchar(50),
--	@Pi_SnapRequired	INT,
--	@Pi_GetFromSnap		INT,
--	@Pi_CurrencyId		INT
--)
--As
--/***************************************************************************************************
--* PROCEDURE	: Proc_RptSalesRegister
--* PURPOSE	: Sales,SR and Replacement  transaction details
--* CREATED	: Panneer
--* CREATED DATE	: 07.04.2011
--* NOTE		: General SP For Generate Product transaction details
--* MODIFIED
--* DATE      AUTHOR     DESCRIPTION
-------------------------------------------------------------------------------------------------------
--* {date}		{developer}		{brief modification description}
--***************************************************************************************************/
--Begin
--SET Nocount On
--		DECLARE @FromDate			AS  DATETIME
--		DECLARE @ToDate				AS  DATETIME
--		DECLARE @RtrId              AS  INT
--		
--		SET @FromDate	= (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
--		SET @ToDate		= (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
--		SET @RtrId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
--		/*  CREATE TABLE STRUCTURE */
--		DECLARE @NewSnapId 		AS	INT
--		DECLARE @DBNAME			AS 	nvarchar(50)
--		DECLARE @TblName 		AS	nvarchar(500)
--		DECLARE @TblStruct 		AS	nVarchar(4000)
--		DECLARE @TblFields 		AS	nVarchar(4000)
--		DECLARE @SSQL			AS 	VarChar(8000)
--		DECLARE @ErrNo	 		AS	INT
--		DECLARE @PurDBName		AS	nVarChar(50)
--		/*  Till Here  */
--	SET @TblName = 'RptSalesRegisterReport'
--	
--	SET @TblStruct ='	SalInvNo	nVarchar(100),
--						[Type]		nVarchar(100),
--						Date		DateTime,
--						RtrCode     nVarchar(100),
--						RtrName     nVarchar(100),
--						TinNo       nVarchar(100),
--						Categoty    nVarchar(100),
--						Brand		nVarchar(100),
--						PrdId Int,
--						PrdDCode nVarchar(100),
--						PrdName  nVarchar(100),
--						BaseQty  INT,
--						PrdUnitSelRate Numeric(38,6),
--						TaxAmt      Numeric(38,6),
--						DiscAmt     Numeric(38,6),
--						PrdNetAmount Numeric(38,6),
--						TotalAmt Numeric(38,6),
--						Mode nVarchar(100) '						
--										
--	SET @TblFields =	'SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Categoty,Brand	,PrdId,			
--						 PrdDCode,PrdName,BaseQty,PrdUnitSelRate,TaxAmt,DiscAmt,PrdNetAmount,TotalAmt,Mode'
--	CREATE TABLE #RptSalesRegisterReport(	SalInvNo	nVarchar(100),[Type] nVarchar(100),	Date DateTime,
--						RtrCode     nVarchar(100),	RtrName     nVarchar(100),	TinNo       nVarchar(100),
--						Categoty    nVarchar(100),	Brand		nVarchar(100),	PrdId Int,
--						PrdDCode nVarchar(100),		PrdName  nVarchar(100),		BaseQty  INT,
--						PrdUnitSelRate Numeric(38,6),	TaxAmt      Numeric(38,6),  DiscAmt     Numeric(38,6),
--						PrdNetAmount Numeric(38,6),	TotalAmt Numeric(38,6),		Mode nVarchar(100))
--	Exec  Proc_GetProductwiseHierarchy
--			/* Purge DB */
--	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
--			/*  Snap Shot Query    */
--	IF @Pi_GetFromSnap = 1
--	BEGIN
--		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
--		SET @DBNAME = @DBNAME
--	END
--	ELSE
--	BEGIN
--		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo =3
--		SET @DBNAME = @PI_DBNAME + @DBNAME
--	END
--	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
--	BEGIN
--		Delete From #RptSalesRegisterReport
--		Insert Into #RptSalesRegisterReport(SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Categoty,Brand	,PrdId,			
--						 PrdDCode,PrdName,BaseQty,PrdUnitSelRate,TaxAmt,DiscAmt,PrdNetAmount,TotalAmt,Mode)
--		---  Sales
--		Select  SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,Sum(BaseQty) BaseQty,PrdUnitSelRate,
--				SUm(PrdTaxAmount) TaxAmt,Sum(DiscAmt) DiscAmt,Sum(PrdNetAmount) PrdNetAmount,
--				Sum(TotalAmt) TotalAmt, Mode
--		FROM (
--				Select 
--						SalInvNo,'Billing' [Type],SalinvDate Date,RtrCode,RtrName,Isnull(RtrTINNo,'') TinNo,
--						Category AS Category,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,Sum(BaseQty) BaseQty,
--						PrdUnitSelRate,Sum(PrdTaxAmount) PrdTaxAmount,
--						Sum(PrdSplDiscAmount+PrdSchDiscAmount+PrdDBDiscAmount+PrdCDAmount) DiscAmt,
--						Sum(PrdNetAmount) PrdNetAmount,SalNetAmt TotalAmt,
--						Case BillMode WHen 1  Then 'Cash' 
--									  WHen 2  Then 'Credit' End As Mode
--				From 
--						Salesinvoice A (nolock) ,Retailer B (nolock),SalesInvoiceProduct C (nolock),
--						ProductWiseHierarchy D (nolock),Product P (nolock)				
--				Where 
--						A.RtrId  = B.RtrId		AND A.SalId = C.SalId
--						AND C.PrdId =  D.ProductId  AND C.PrdId = P.PrdId 
--						AND Dlvsts in (4,5)     AND P.PrdId = D.ProductId  
--						AND SalInvDate Between @FromDate  and @ToDate 
--					    AND (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
--							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
--				Group By 
--						SalInvNo,RtrCode,RtrName,SalinvDate,RtrCode,RtrName,RtrTINNo,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,PrdUnitSelRate,SalNetAmt,Category,BillMode )  A
--		Group By 
--				SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,PrdUnitSelRate,Mode,Category
--		
--		---  SalesReturn
--		Insert Into #RptSalesRegisterReport(SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Categoty,Brand	,PrdId,			
--						 PrdDCode,PrdName,BaseQty,PrdUnitSelRate,TaxAmt,DiscAmt,PrdNetAmount,TotalAmt,Mode)
--		Select  ReturnCode,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,Sum(BaseQty) BaseQty,PrdUnitSelRte,
--				SUm(PrdTaxAmount) TaxAmt,Sum(DiscAmt),Sum(PrdNetAmount) PrdNetAmount,
--				Sum(TotalAmt) TotalAmt, Mode
--		FROM (
--				Select 
--						ReturnCode,'SRN' [Type],ReturnDate Date,RtrCode,RtrName,Isnull(RtrTINNo,'') TinNo,
--						Category AS Category,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,Sum(BaseQty) BaseQty,
--						PrdUnitSelRte,Sum(PrdTaxAmt) PrdTaxAmount,
--						Sum(PrdSplDisAmt+PrdSchDisAmt+PrdDBDisAmt+PrdCDDisAmt) DiscAmt,
--						Sum(PrdNetAmt) PrdNetAmount,RtnNetAmt TotalAmt,'Debit' Mode
--				From 
--						ReturnHeader A (nolock) ,Retailer B (nolock),ReturnProduct C (nolock),
--						ProductWiseHierarchy D (nolock),Product P (nolock)				
--				Where 
--						A.RtrId  = B.RtrId		AND A.ReturnId = C.ReturnId
--						AND C.PrdId =  D.ProductId  AND C.PrdId = P.PrdId 
--						AND P.PrdId = D.ProductId  
--						AND ReturnDate Between @FromDate  and @ToDate 
--					    AND (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
--							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
--				Group By 
--						ReturnCode,RtrCode,RtrName,ReturnDate,RtrCode,RtrName,RtrTINNo,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,PrdUnitSelRte,RtnNetAmt,Category )  A
--		Group By 
--				ReturnCode,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,PrdUnitSelRte,Mode,Category
--		---  Replacement IN
--		Insert Into #RptSalesRegisterReport(SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Categoty,Brand	,PrdId,			
--						 PrdDCode,PrdName,BaseQty,PrdUnitSelRate,TaxAmt,DiscAmt,PrdNetAmount,TotalAmt,Mode)
--		Select  RepRefNo,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,Sum(BaseQty) BaseQty,SelRte,
--				SUm(PrdTaxAmount) TaxAmt,Sum(DiscAmt),Sum(PrdNetAmount) PrdNetAmount,
--				Sum(TotalAmt) TotalAmt, Mode
--		FROM (
--				Select 
--						A.RepRefNo,'Exchange' [Type],RepDate Date,RtrCode,RtrName,Isnull(RtrTINNo,'') TinNo,
--						Category AS Category,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,Sum(RtnQty) BaseQty,
--						SelRte,Sum(Tax) PrdTaxAmount,
--						0 DiscAmt,
--						Sum(RtnAmount) PrdNetAmount,0 TotalAmt,'Debit' Mode
--				From 
--						ReplacementHd A (nolock) ,Retailer B (nolock),ReplacementIn C (nolock),
--						ProductWiseHierarchy D (nolock),Product P (nolock)				
--				Where 
--						A.RtrId  = B.RtrId		AND A.RepRefNo = C.RepRefNo
--						AND C.PrdId =  D.ProductId  AND C.PrdId = P.PrdId 
--						AND P.PrdId = D.ProductId  
--						AND RepDate Between @FromDate  and @ToDate  
--						AND (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
--							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
--				Group By 
--						A.RepRefNo,RtrCode,RtrName,RepDate,RtrCode,RtrName,RtrTINNo,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,SelRte,Category )  A
--		Group By 
--				RepRefNo,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,SelRte,Mode,Category
--			
--		---  Replacement out
--		Insert Into #RptSalesRegisterReport(SalInvNo,[Type],Date,RtrCode,RtrName,TinNo,Categoty,Brand	,PrdId,			
--						 PrdDCode,PrdName,BaseQty,PrdUnitSelRate,TaxAmt,DiscAmt,PrdNetAmount,TotalAmt,Mode)
--		Select  RepRefNo,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,Sum(BaseQty) BaseQty,SelRte,
--				SUm(PrdTaxAmount) TaxAmt,Sum(DiscAmt),Sum(PrdNetAmount) PrdNetAmount,
--				Sum(TotalAmt) TotalAmt, Mode
--		FROM (
--				Select 
--						A.RepRefNo,'Exchange' [Type],RepDate Date,RtrCode,RtrName,Isnull(RtrTINNo,'') TinNo,
--						Category AS Category,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,Sum(RepQty) BaseQty,
--						SelRte,Sum(Tax) PrdTaxAmount,
--						0 DiscAmt,
--						Sum(RepAmount) PrdNetAmount,0 TotalAmt,'Credit' Mode
--				From 
--						ReplacementHd A (nolock) ,Retailer B (nolock),ReplacementOut C (nolock),
--						ProductWiseHierarchy D (nolock),Product P (nolock)				
--				Where 
--						A.RtrId  = B.RtrId		AND A.RepRefNo = C.RepRefNo
--						AND C.PrdId =  D.ProductId  AND C.PrdId = P.PrdId 
--						AND P.PrdId = D.ProductId  
--						AND RepDate Between @FromDate  and @ToDate 
--						AND (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
--							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
--				Group By 
--						A.RepRefNo,RtrCode,RtrName,RepDate,RtrCode,RtrName,RtrTINNo,
--						Brand,C.PrdId,PrdDCode,PrdName,PrdBatId,SelRte,Category )  A
--		Group By 
--				RepRefNo,[Type],Date,RtrCode,RtrName,TinNo,Category,Brand,PrdId,
--				PrdDCode,PrdName,SelRte,Mode,Category
--		/* New Snap Shot Data Stored*/
--		IF @Pi_SnapRequired = 1
--		BEGIN
--			SELECT @NewSnapId = @Pi_SnapId
--			
--			EXEC Proc_SnapShot_Report @NewSnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
--				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
--			
--			SET @sSql = 'INSERT INTO [' + @DBNAME + '].dbo.' + @TblName +
--				'(SnapId,UserId,RptId,' + @TblFields + ')' +
--				' SELECT ' + CAST(@NewSnapId AS VARCHAR(10)) +
--				' ,' + CAST(@Pi_UsrId AS VARCHAR(10)) +
--				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ',* FROM #RptSalesRegisterReport'		
--			EXEC (@SSQL)
--			PRINT 'Saved Data Into SnapShot Table'
--		END
--	END
--	ELSE				
--	BEGIN
--		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
--								  @Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
--			IF @ErrNo = 0
--			BEGIN
--				SET @SSQL = 'INSERT INTO #RptSalesRegisterReport ' +
--					'(' + @TblFields + ')' +
--					' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
--					' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
--					' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
--					' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))	
--					EXEC (@SSQL)
--					PRINT 'Retrived Data From Snap Shot Table'
--					SELECT * FROM #RptSalesRegisterReport
--			END
--			ELSE
--			BEGIN
--				PRINT 'DataBase or Table not Found'
--				RETURN
--			END
--	END
--		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
--		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
--		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptSalesRegisterReport
--	Create table #RptSalReg(RefNo nvarchar(50),Mode nvarchar(50),PrdAmt numeric(18,6))
--	Insert Into #RptSalReg
--	Select  SalInvNo RefNo ,Mode,Sum(PrdNetAmount) PrdAmt  
--	From #RptSalesRegisterReport Where [Type] = 'Exchange'
--	Group by SalInvNo,Mode
--	Update #RptSalesRegisterReport Set TotalAmt = PrdAmt
--	From #RptSalesRegisterReport a,#RptSalReg b
--	Where salinvno = RefNo and A.mode = b.mode  AND [Type] = 'Exchange'
--	Select * from #RptSalesRegisterReport
--End
--GO
DELETE FROM CustomCaptions WHERE TransId=23 AND CtrlId=2000 AND SubCtrlId IN (37,38)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('23','2000','37','HotSch-23-2000-37','Selling Rate','','','1','1','1',CONVERT(datetime,'2010-12-16 16:38:05.140',121),'1',CONVERT(datetime,'2010-12-16 16:38:05.140',121),'Selling Rate','','','1','1')
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('23','2000','38','HotSch-23-2000-38','Purchase Rate','','','1','1','1',CONVERT(datetime,'2010-12-16 16:38:05.157',121),'1',CONVERT(datetime,'2010-12-16 16:38:05.157',121),'Purchase Rate','','','1','1')
DELETE FROM CustomCaptions WHERE TransId=24 AND CtrlId=2000 AND SubCtrlId IN (40)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('24','2000','40','HotSch-24-2000-40','Retailer','','','1','1','1',CONVERT(datetime,'2011-02-07 00:00:00.000',121),'1',CONVERT(datetime,'2011-02-07 00:00:00.000',121),'Retailer','','','1','1')
DELETE FROM CustomCaptions WHERE TransId=26 AND CtrlId=2000 AND SubCtrlId IN (39)
INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,AuthId,
AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled) 
VALUES('26','2000','39','HotSch-26-2000-39','PO Type','','','1','1','1',CONVERT(datetime,'2010-04-21 12:21:38.990',121),'1',CONVERT(datetime,'2010-04-21 12:21:38.990',121),'PO Type','','','1','1')
GO
IF EXISTS (SELECT * FROM sysobjects WHERE NAME ='Fn_ReturnSchemeCombiCriteria' AND xtype='FN')
DROP FUNCTION Fn_ReturnSchemeCombiCriteria
GO
CREATE FUNCTION Fn_ReturnSchemeCombiCriteria (@SalId INT) RETURNS INT   
AS
BEGIN
	DECLARE @RetValue as INT
	SET @RetValue=0 
	SELECT @RetValue=CombiSch
	FROM SchemeMaster A INNER JOIN SalesInvoiceSchemeLineWise B on A.SchId=B.SchId 
	INNER JOIN SalesInvoice C on C.SalId=B.SalId where C.SalId=@SalId and CombiSch=1  
	RETURN (@RetValue)
END
GO
IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'CombiType' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='Etl_Prk_SchemeHD_Slabs_Rules'))
BEGIN
	ALTER TABLE Etl_Prk_SchemeHD_Slabs_Rules ADD CombiType NVARCHAR(50) NOT NULL DEFAULT 'NORMAL' WITH VALUES
END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE XTYPE='U' AND NAME='Etl_Prk_Scheme_CombiCriteria')
DROP TABLE [dbo].[Etl_Prk_Scheme_CombiCriteria]
GO
CREATE TABLE [dbo].[Etl_Prk_Scheme_CombiCriteria](
	[DistCode]		[nvarchar](100),
	[CmpSchCode]	[nvarchar](100),
	[PrdCtgLevel]	[nvarchar](100),
	[PrdCtgCode]	[nvarchar](100),
	[MinAmount]		[nvarchar](50),
	[NoofLines]		[nvarchar](50),
	[DiscPer]		[nvarchar](50),
	[FlatAmt]		[nvarchar](50),
	[Points]		[nvarchar](50),
	[DownLoadFlag] [nvarchar](10)
) ON [PRIMARY]
GO
DECLARE @Slno		INT
DECLARE @SeqNo		INT
SET @Slno=0
SET @SeqNo=0
SELECT @Slno=Slno,@SeqNo=Max(SeqNo) FROM CustomUpDownload WHERE UpDownLoad='DOWNLOAD' AND Module='Scheme' AND Screen='Scheme On Another Product'
GROUP BY Slno
DELETE FROM CustomUpDownload WHERE UpDownLoad='DOWNLOAD' AND Module='Scheme' AND Slno=@Slno AND Screen='Scheme Combi Criteria'
INSERT INTO CustomUpDownload
SELECT @Slno,@SeqNo+1,'Scheme','Scheme Combi Criteria','Proc_CS2CNBLSchemeCombiCriteria','Proc_ImportBLSchemeCombiCriteria',
'Etl_Prk_Scheme_CombiCriteria','Proc_CN2CS_BLSchemeCombiCriteria','Transaction','Download',0
GO
DELETE FROM Tbl_DownloadIntegration WHERE SequenceNo=33
INSERT INTO Tbl_DownloadIntegration
SELECT 33,'Scheme Combi Criteria','Etl_Prk_Scheme_CombiCriteria','Proc_ImportBLSchemeCombiCriteria',0,500,GETDATE()
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ImportSchemeHD_Slabs_Rules')
DROP PROCEDURE Proc_ImportSchemeHD_Slabs_Rules
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
* 28/12/2010   Nanda        Added the Settlement Type Column 
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
	NoofBills,FromDate,ToDate,MarketVisit,ApplySchBasedOn,EnableRtrLvl,AllowSaving,AllowSelection,BudgetAllocationNo,SchBasedOn,
	FBM,DownloadFlag,SettlementType,AllowUncheck,CombiType)
	SELECT  [CmpSchCode],[SchDsc],@Company AS [CmpCode],[Claimable],[ClmAmton],@ClmGroupCode AS [ClmGroupCode],[SchLevel],[SchType],
	'NO' AS [BatchLevel],[FlexiSch],[FlexiSchType],[CombiSch],[Range],[ProRata],[QPS],[QPSReset],[ApyQPSSch],[SchValidFrom],[SchValidTill],
	[SchStatus],[Budget],[AdjWinDispOnlyOnce],[PurofEvery],[SetWindowDisp],[EditScheme],[SchemeLevelMode],[SlabId],[PurQty],[FromQty],
	[Uom],[ToQty],[ToUom],[ForEveryQty],[ForEveryUom],[DiscPer],[FlatAmt],[FlxDisc],[FlxValueDisc],[FlxFreePrd],[FlxGiftPrd],[FlxPoints],
	[Points],[MaxDiscount],[MinDiscount],[MaxValue],[MinValue],[MaxPoints],[MinPoints],[SchConfig],[SchRules],[NoofBills],[FromDate],
	[ToDate],[MarketVisit],[ApplySchBasedOn],[EnableRtrLvl],[AllowSaving],[AllowSelection],[BudgetAllocationNo],[SchBasedOn],
	[FBM],[DownloadFlag],ISNULL([SettlementType],'ALL'),ISNULL([AllowUncheck],'NO'),ISNULL(CombiType,'NORMAL')
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
		[FBM]					NVARCHAR (10),		
		[SettlementType]		NVARCHAR (10),
		[AllowUncheck]			NVARCHAR (10),
		[CombiType]				NVARCHAR (50)
	) XMLObj
	EXEC sp_xml_removedocument @hDoc
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ImportBLSchemeCombiCriteria')
DROP PROCEDURE Proc_ImportBLSchemeCombiCriteria
GO
CREATE    PROCEDURE [dbo].[Proc_ImportBLSchemeCombiCriteria]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportBLSchemeCombiCriteria
* PURPOSE	: To Insert and Update records  from xml file in the Table Scheme Combi Criteria
* CREATED	: Boopathy.P
* CREATED DATE	: 22/06/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records	
	INSERT INTO Etl_Prk_Scheme_CombiCriteria
			SELECT  DistCode,CmpSchCode,PrdCtgLevel,PrdCtgCode,MinAmount,
					NoofLines,DiscPer,FlatAmt,Points,'D'
			FROM 	OPENXML (@hdoc,'/Root/Console2CS_Scheme_CombiCriteria',1)
			WITH (
			
					[DistCode]		[nvarchar](100),
					[CmpSchCode]	[nvarchar](100),
					[PrdCtgLevel]	[nvarchar](100),
					[PrdCtgCode]	[nvarchar](100),
					[MinAmount]		[nvarchar](50),
					[NoofLines]		[nvarchar](50),
					[DiscPer]		[nvarchar](50),
					[FlatAmt]		[nvarchar](50),
					[Points]		[nvarchar](50)
		
			     ) XMLObj
EXECUTE sp_xml_removedocument @hDoc
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cn2Cs_BLSchemeMaster')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeMaster
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
	ISNULL([CombiType],'NORMAL')
	FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'			 
	ORDER BY [Company Scheme Code]
	OPEN Cur_SchMaster
	FETCH NEXT FROM Cur_SchMaster INTO @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
	, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
	, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch,
	@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM,@SettlementType,@AllowUnCheck,@CombiType	
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

		IF ((UPPER(LTRIM(RTRIM(@CombiType)))<> 'NORMAL') AND (UPPER(LTRIM(RTRIM(@CombiType)))<> 'FLUCTUATING'))
		BEGIN
			SET @ErrDesc = 'CombiType should be (NORMAL OR FLUCTUATING) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (71,@TabName,'CombiType',@ErrDesc)
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

			IF UPPER(LTRIM(RTRIM(@CombiType)))= 'Fluctuating'
				SET @CombiTypeId=1
			ELSE IF UPPER(LTRIM(RTRIM(@Range)))= 'NORMAL'
				SET @CombiTypeId=0
			
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
								AuthDate,EditScheme,SchemeLvlMode,MasterType,ApplyOnMRPSelRte,ApplyOnTax,
								BudgetAllocationNo,AllowPrdSelc,ExcludeDM,SchBasedOn,Download,FBM,SettlementType,ApplyClaim,CombiType)
								VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
								LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
								@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
								@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
								@ApplySchId,@SettleSchId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,
								CONVERT(VARCHAR(10),GETDATE(),121),@EditSchId,@SelMode,1,2,0,@BudgetAllocationNo,0,0,@SchBasedOnId,1,@FBMId,@SettlementTypeId,@AllowUnCheckId,@CombiTypeId)
				
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
					convert(varchar(10),getdate(),121),@EditSchId,@SelMode,1,2,0,@BudgetAllocationNo,0,0,@SchBasedOnId,1,@FBMId,@SettlementTypeId,@AllowUnCheckId,@CombiTypeId)
	
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
		@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM,@SettlementType,@AllowUnCheck,@CombiType
	END
	CLOSE Cur_SchMaster
	DEALLOCATE Cur_SchMaster
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cn2Cs_BLSchemeOnAnotherPrd')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeOnAnotherPrd
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
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_CN2CS_BLSchemeCombiCriteria')
DROP PROCEDURE Proc_CN2CS_BLSchemeCombiCriteria
GO
/*
BEGIN TRANSACTION
DELETE FROM ErrorLog
EXEC Proc_CN2CS_BLSchemeCombiCriteria 0
SELECT * FROM SchemeCombiCriteria WHERE SchId> 557 
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/
CREATE    PROCEDURE Proc_CN2CS_BLSchemeCombiCriteria
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_CN2CS_BLSchemeCombiCriteria
* PURPOSE: To Insert and Update Scheme combi criteria
* CREATED: Boopathy.P on 22/06/2011
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

	DECLARE @MinAmount  AS NUMERIC(18,6)
	DECLARE	@NoofLines	AS INT
	DECLARE @DiscPer	AS NUMERIC(18,2)

	SET @TabName = 'Etl_Prk_Scheme_CombiCriteria'
	SET @Po_ErrNo =0


	DECLARE Cur_CombiCriteria CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],''),ISNULL(PrdCtgLevel,''),
	ISNULL([PrdCtgCode],''),ISNULL(MinAmount,0),ISNULL(NoofLines,0),ISNULL(DiscPer,0)	
	FROM Etl_Prk_Scheme_CombiCriteria
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	OPEN Cur_CombiCriteria
	FETCH NEXT FROM Cur_CombiCriteria INTO @SchCode,@Type,@PrdCode,@MinAmount,@NoofLines,@DiscPer
	WHILE @@FETCH_STATUS=0
	BEGIN
		SELECT @SchCode,@Type,@PrdCode,@MinAmount,@NoofLines,@DiscPer
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
			SET @ErrDesc = 'Scheme Level should not be blank for Scheme Code: '+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Type',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@PrdCode))= ''
		BEGIN
			SET @ErrDesc = 'Product Code should not be blank for Scheme Code: '+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@MinAmount))= ''
		BEGIN
			SET @ErrDesc = 'Minimun should not be blank for Scheme Code: '+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Minimun Amount',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@NoofLines))= ''
		BEGIN
			SET @ErrDesc = 'No of Lines should not be blank for Scheme Code: '+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'No of Lines',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@DiscPer))= ''
		BEGIN
			SET @ErrDesc = 'Discount Percentage should not be blank for Scheme Code: '+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Discount Percentage',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF NOT EXISTS(SELECT DISTINCT PRDID FROM PRODUCT)
		BEGIN
			SET @ErrDesc = 'No Product(s) found in Product Master'
			INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@PrdCode))= ''
		BEGIN
			SET @ErrDesc = 'Product Code should not be blank for Scheme Code: '+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Product Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF CAST(LTRIM(RTRIM(@MinAmount)) AS NUMERIC(18,6))<=0
		BEGIN
			SET @ErrDesc = 'Minimun should be greater than Zero for Scheme Code: '+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Minimun Amount',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF CAST(LTRIM(RTRIM(@NoofLines)) AS NUMERIC(18,6))<=0
		BEGIN
			SET @ErrDesc = 'No of Lines should be greater than Zero for Scheme Code: '+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'No of Lines',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF CAST(LTRIM(RTRIM(@DiscPer)) AS NUMERIC(18,6))<=0
		BEGIN
			SET @ErrDesc = 'Discount Percentage should be greater than Zero for Scheme Code: '+@SchCode
			INSERT INTO Errorlog VALUES (1,@TabName,'Discount Percentage',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END

		IF @Po_ErrNo=0
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
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpPrdCtgName=LTRIM(RTRIM(@Type)))
			BEGIN
				SET @ErrDesc = 'Company Scheme Code not found'
				INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
			ELSE
			BEGIN
				SELECT @MaxSchLevelId=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				SELECT @SelLvl=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpPrdCtgName=LTRIM(RTRIM(@Type))
				IF @MaxSchLevelId=@SelLvl
				BEGIN
					IF NOT EXISTS(SELECT PrdId FROM Product WHERE CmpId=@CmpId
					AND PrdCCode=LTRIM(RTRIM(@PrdCode)))
					BEGIN
						SET @ErrDesc = 'Product Code Not Found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (11,@TabName,'Product Code',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @PrdId=PrdId FROM Product WHERE CmpId=@CmpId
						AND PrdCCode=LTRIM(RTRIM(@PrdCode))
					END
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
					ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
					AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SelLvl)
					BEGIN
						SET @ErrDesc = 'Product Category Level Not Found for Product Code:'+ @PrdCode+' in Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (11,@TabName,'Product Category',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @PrdId=A.PrdCtgValMainId FROM ProductCategoryValue A INNER JOIN ProductCategoryLevel B
						ON A.CmpPrdCtgId=B.CmpPrdCtgId WHERE CmpId=@CmpId
						AND PrdCtgValCode=LTRIM(RTRIM(@PrdCode)) AND A.CmpPrdCtgId=@SelLvl
					END
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
				IF @MaxSchLevelId=@SelLvl
				BEGIN
					DELETE FROM SchemeCombiCriteria WHERE SchID=@GetKey AND PrdId=@PrdId
					INSERT INTO SchemeCombiCriteria
					SELECT @GetKey,0,0,@PrdId,@MinAmount,@NoofLines,@DiscPer,0,0
				END
				ELSE	
				BEGIN
					DELETE FROM SchemeCombiCriteria WHERE SchID=@GetKey AND PrdCtgValMainId=@PrdId
					INSERT INTO SchemeCombiCriteria
					SELECT @GetKey,1,@PrdId,0,@MinAmount,@NoofLines,@DiscPer,0,0
				END
			END
		END
		FETCH NEXT FROM Cur_CombiCriteria INTO @SchCode,@Type,@PrdCode,@MinAmount,@NoofLines,@DiscPer
	END
	CLOSE Cur_CombiCriteria
	DEALLOCATE Cur_CombiCriteria

	UPDATE Etl_Prk_SchemeHD_Slabs_Rules SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)
	UPDATE Etl_Prk_Scheme_OnAttributes SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)
	UPDATE Etl_Prk_Scheme_Free_Multi_Products SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)
	UPDATE Etl_Prk_Scheme_OnAnotherPrd SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)
	UPDATE Etl_Prk_Scheme_RetailerLevelValid SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)
	UPDATE Etl_Prk_SchemeProducts_Combi SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)	
	UPDATE Etl_Prk_Scheme_OnAnotherPrd SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)	

	UPDATE Etl_Prk_Scheme_CombiCriteria SET DownloadFlag='Y' WHERE CmpSchCode IN (SELECT DISTINCT SM.CmpSchCode 
	FROM SchemeMaster SM,SchemeRetAttr SA,SchemeProducts SP
	WHERE SM.SchId=SA.SchId AND SA.SchId=SP.SchId AND SM.SchId=SP.SchId
	) AND
	CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid)	
END
GO
if not exists (select * from hotfixlog where fixid = 381)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(381,'D','2011-06-24',getdate(),1,'Core Stocky Service Pack 381')
GO