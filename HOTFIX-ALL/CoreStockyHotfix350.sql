--[Stocky HotFix Version]=350
Delete from Versioncontrol where Hotfixid='350'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('350','2.0.0.5','D','2010-12-07','2010-12-07','2010-12-07',convert(varchar(11),getdate()),'Parle 2nd Phase;Major:-;Minor:Changes and Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 350' ,'350'
GO

--SRF-Nanda-180-001

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
EXEC Proc_QPSSchemeCrediteNoteConversion 2,'2010-10-20',0
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd WHERE TransId = 2 And UsrId = 1
--SELECT * FROM BillAppliedSchemeHd
--SELECT * FROM SalesInvoiceQPSCumulative
--SELECT * FROM SchemeMaster
SELECT * FROM CreditNoteRetailer
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
			DELETE FROM @SchemeAvailable

			INSERT INTO BilledPrdHdForScheme(RowId,RtrId,PrdId,PrdBatId,SelRate,BaseQty,GrossAmount,MRP,TransId,Usrid,ListPrice)
			VALUES(2,@RtrId,1,1,10.00,100,1000.00,12.00,2,@UsrId,7.50)

			--->Modified By Nanda on 20/10/2010
--			INSERT INTO @SchemeAvailable(SchId,SchCode,CmpSchCode,CombiSch,QPS)
--			SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
--			FROM BilledPrdHdForScheme A
--			INNER JOIN Fn_ReturnApplicableProductDtQPS() B ON A.PrdId = B.PrdId AND A.UsrId = @UsrId   AND A.TransId =  2
--			INNER JOIN SchemeMaster C ON C.SchId = B.SchId WHERE
--			C.SchValidTill < @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1

			INSERT INTO @SchemeAvailable(SchId,SchCode,CmpSchCode,CombiSch,QPS)
			SELECT DISTINCT B.SchId,C.SchCode,C.CmpSchCode,C.CombiSch,C.QPS
			FROM Fn_ReturnApplicableProductDtQPS() B 
			INNER JOIN SchemeMaster C ON C.SchId = B.SchId WHERE
			C.SchValidTill <= @Pi_TransDate AND C.ApyQpsSch = 1 AND C.SchStatus=1 AND C.QPS=1
			--->Till Here

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
						'From QPS Scheme:'+@AvlSchCode+'(Auto Conversion)')
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

--SRF-Nanda-180-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyReturnScheme]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyReturnScheme]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC [Proc_ApplyReturnScheme] 2054,2,3
SELECT * FROM UserFetchReturnScheme 
-- DELETE FROM UserFetchReturnScheme
-- SELECT * FROM SalesInvoiceSchemeLineWise WHERE SalId=11865
-- SELECT * FROM ApportionzSchemeDetails
-- SELECT * FROM BillAppliedSchemeHd WHERE TransId=3 AND usrId=2
-- DELETE FROM ApportionSchemeDetails
-- DELETE FROM BillAppliedSchemeHd
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

	IF @Config=0
	BEGIN
		DELETE FROM UserFetchReturnScheme WHERE SalId=@Pi_SalId AND Usrid=@Pi_Usrid AND TransId=@Pi_TransId

--		INSERT INTO UserFetchReturnScheme(SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,FreeQty,
--		FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId)
--		SELECT SI.SalId,RPS.PrdId,RPS.PRdBatId,SIL.SchId,SIL.SlabId,
--		((SIL.DiscountPerAmount-SIL.PrimarySchemeAmt)/SIP.BaseQty)*(RPS.RealQty),0,0,0,0,0,0,0,0,0,@Pi_Usrid,@Pi_TransId,RPS.RowId,0,0
--		FROM SalesInvoice SI,SalesInvoiceProduct SIP,
--		SalesInvoiceSchemeLineWise SIL,ReturnPrdHdForScheme RPS
--		WHERE SI.SalId=@Pi_SalId AND SI.SalId=SIP.SalId AND SIP.PrdId=SIL.PrdId AND SIP.PrdBatId=SIL.PrdBatId 
--		AND RPS.PrdId=SIP.PrdId AND RPS.PrdBatId=SIP.PrdBatId AND RPS.SalId=SI.SalId AND SIL.SalId=SIP.SalId

		INSERT INTO UserFetchReturnScheme(SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,FreeQty,
		FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId)
		SELECT SI.SalId,RPS.PrdId,RPS.PRdBatId,SIL.SchId,SIL.SlabId,
		((SIL.DiscountPerAmount-SIL.PrimarySchemeAmt)/SIP.BaseQty)*(RPS.RealQty),
		((SIL.FlatAmount-SIL.ReturnFlatAmount)/SIP.BaseQty)*(RPS.RealQty),0,0,0,0,0,0,0,0,@Pi_Usrid,@Pi_TransId,RPS.RowId,0,0
		FROM SalesInvoice SI,SalesInvoiceProduct SIP,
		SalesInvoiceSchemeLineWise SIL,ReturnPrdHdForScheme RPS
		WHERE SI.SalId=@Pi_SalId AND SI.SalId=SIP.SalId AND SIP.PrdId=SIL.PrdId AND SIP.PrdBatId=SIL.PrdBatId 
		AND RPS.PrdId=SIP.PrdId AND RPS.PrdBatId=SIP.PrdBatId AND RPS.SalId=SI.SalId AND SIL.SalId=SIP.SalId

--		--Nanda
--		SELECT '1',* FROM UserFetchReturnScheme 

		SELECT @RtrId=RtrId FROM SalesInvoice WHERE SalId=@Pi_SalId

		DECLARE SchemeFreeCur CURSOR FOR
		SELECT DISTINCT SchId,SlabId FROM SalesInvoiceSchemeDtFreePrd WHERE SalId=@Pi_SalId
		OPEN SchemeFreeCur
		FETCH NEXT FROM SchemeFreeCur INTO @SchId,@CurSlabId
		WHILE @@fetch_status= 0
		BEGIN		

			SELECT @SchType=SchType,@Combi=CombiSch FROM SchemeMaster WHERE SchId=@SchId

			INSERT INTO ReturnPrdHdForScheme
			SELECT A.Slno,@RtrId,A.Prdid,A.PrdBatId,A.PrdUnitSelRate,A.BaseQty-A.ReturnedQty,
			(A.BaseQty-A.ReturnedQty)*A.PrdUnitSelRate,@Pi_TransId,@Pi_UsrId,@Pi_SalId,0,A.PrdUnitMRP
			FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
			A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
			WHERE A.SalId=@Pi_SalId AND A.PrdId NOT IN (SELECT Distinct PrdId FROM ReturnPrdHdForScheme
			WHERE usrid = @Pi_Usrid AND TransId = @Pi_TransId AND SalId = @Pi_SalId )

			UPDATE A set BaseQty = CASE A.BaseQty WHEN 0 THEN A.RealQty ELSE (b.BaseQty-b.ReturnedQty)-A.RealQty END
			FROM ReturnPrdHdForScheme a,SalesInvoiceProduct b WHERE a.SalId = b.SalId AND
			a.PrdId = b.PrdId AND a.PrdBatId = b.PrdBatId AND b.SalId = @Pi_SalId 
			AND a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId

			DELETE FROM @ReturnPrdHdForScheme WHERE Usrid= @Pi_Usrid
			AND TransId = @Pi_TransId AND SalId=@Pi_SalId

			INSERT INTO @ReturnPrdHdForScheme
			SELECT A.* FROM ReturnPrdHdForScheme A INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
			A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
			where Usrid= @Pi_Usrid AND TransId = @Pi_TransId AND SalId=@Pi_SalId

			SET @SlabId=0
			DELETE FROM @TempBilled
			DELETE FROM @TempBilledAch
			INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT DISTINCT A.PrdId,A.PrdBatId,ISNULL(SUM(A.RealQty),0) AS SchemeOnQty,ISNULL(SUM(A.RealQty * A.SelRate),0) AS SchemeOnAmount,
				ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * A.RealQty),0)/1000
				WHEN 3 THEN ISNULL(SUM(PrdWgt * A.RealQty),0) END,0) AS SchemeOnKg,
				ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * A.RealQty),0)/1000
				WHEN 5 THEN ISNULL(SUM(PrdWgt * A.RealQty),0) END,0) AS SchemeOnLitre,@SchId
				FROM @ReturnPrdHdForScheme A  INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C ON A.PrdId = C.PrdId
				INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
				WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId
				GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId


			--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
			INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
			SELECT DISTINCT ISNULL(CASE @SchType
				WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
				WHEN 2 THEN SUM(SchemeOnAmount)
				WHEN 3 THEN (CASE A.UomId
						WHEN 2 THEN SUM(SchemeOnKg) * 1000
						WHEN 3 THEN SUM(SchemeOnKg)
						WHEN 4 THEN SUM(SchemeOnLitre) * 1000
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
				INNER JOIN @TempBilled B ON A.SchId = B.SchId
				INNER JOIN Product C ON B.PrdId = C.PrdId
				LEFT OUTER JOIN UomGroup D ON D.UomGroupId = C.UomGroupId AND D.UomId = A.UomId
				LEFT OUTER JOIN UomGroup E ON E.UomGroupId = C.UomGroupId AND E.UomId = A.UomId
				WHERE A.SlabId=@CurSlabId
				GROUP BY A.UomId,A.Slabid,A.PurQty,A.FromQty,A.UomId,A.ToQty,A.ToUomId


				--Store the Slab Free Product Details into a temp table
				INSERT INTO @TempSchSlabFree(ForEveryQty,ForEveryUomId,FreePrdId,FreeQty)
				SELECT A.ForEveryQty,A.ForEveryUomId,B.PrdId,B.FreeQty From
					SchemeSlabs A INNER JOIN SchemeSlabFrePrds B ON A.Schid = B.Schid
					AND A.SlabId = B.SlabId INNER JOIN Product C ON B.PrdId = C.PrdId
					WHERE A.Schid = @SchId And A.SlabId = CASE @SlabId WHEN 0 THEN @CurSlabId ELSE @SlabId END AND C.PrdType <> 4


				--To Get the Number of Times the Scheme should apply
				IF @PurOfEveryReq = 0
				BEGIN
					SET @NoOfTimes = 1
				END
				ELSE
				BEGIN
					SELECT @NoOfTimes = A.FrmSchAch / (CASE B.ForEveryQty WHEN 0 THEN 1 ELSE B.ForEveryQty END) FROM
						@TempBilledAch A INNER JOIN @TempSchSlabAmt B ON A.SlabId = CASE @SlabId WHEN 0 THEN @CurSlabId ELSE @SlabId END

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

--				SELECT @SlabId,@CurSlabId
				IF @SlabId=@CurSlabId
				BEGIN
					IF EXISTS (SELECT * FROM BillAppliedSchemeHd B WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid 
					AND (B.FreeToBeGiven + B.GiftToBeGiven)>0 AND B.IsSelected=1 AND SchId=@SchId AND SlabId=@CurSlabId)
					BEGIN
						SELECT @RowId=MIN(RowId)  FROM @ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId

						SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM @ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId AND RowId=@RowId

						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)

						SELECT @Pi_SalId,@SchId,@CurSlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,0 AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM	
						SalesInvoiceSchemeDtFreePrd E WHERE E.SchId=@SchId AND E.SalId=@Pi_SalId

--						--Nanda
--						SELECT '1',* FROM @FreePrdDt 
					END
				END
				ELSE IF @SlabId=0
				BEGIN
					IF EXISTS (SELECT * FROM BillAppliedSchemeHd B WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid 
							AND (B.FreeToBeGiven + B.GiftToBeGiven)>0 AND B.IsSelected=1 AND SchId=@SchId AND SlabId=@CurSlabId)
					BEGIN
						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)

						SELECT @Pi_SalId,@SchId,@CurSlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,0 AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,B.PrdId,B.PrdBatId,C.RowId FROM	BillAppliedSchemeHd B 
						INNER JOIN SalesInvoiceSchemeDtFreePrd E ON B.SchId=E.SchId AND B.SlabId=E.SlabId
						INNER JOIN @ReturnPrdHdForScheme C ON B.PrdId=C.PrdId AND B.PrdbatId=C.PrdbatId
						WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId 
						AND B.IsSelected=1 AND E.SalId=@Pi_SalId

--						--Nanda
--						SELECT '2',* FROM @FreePrdDt 
					END
					ELSE IF EXISTS (SELECT * FROM BillAppliedSchemeHd B WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid 
							AND (B.FreeToBeGiven + B.GiftToBeGiven)>0 AND B.IsSelected=1 AND SchId=@SchId AND SlabId<@CurSlabId)
					BEGIN
						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)

						SELECT @Pi_SalId,@SchId,@CurSlabId,(E.FreeQty-E.ReturnFreeQty),
						E.FreePrdId,E.FreePrdBatId,0 AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,B.PrdId,B.PrdBatId,C.RowId FROM	BillAppliedSchemeHd B 
						INNER JOIN SalesInvoiceSchemeDtFreePrd E ON  B.SchId=E.SchId 
						INNER JOIN @ReturnPrdHdForScheme C ON B.PrdId=C.PrdId AND B.PrdbatId=C.PrdbatId
						WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId 
						AND B.IsSelected=1 AND E.SalId=@Pi_SalId

--						--Nanda
--						SELECT '3',* FROM @FreePrdDt 
					END
					ELSE
					BEGIN
						SELECT @RowId=MIN(RowId)  FROM @ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId

						SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM @ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId AND RowId=@RowId

--						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
--						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
--						SELECT @Pi_SalId,@SchId,@CurSlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
--						E.FreePrdId,E.FreePrdBatId,0 AS FreePriceId,
--						0 AS GiftQty,0,0,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM	
--						SalesInvoiceSchemeDtFreePrd E WHERE E.SchId=@SchId AND E.SalId=@Pi_SalId

						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
						SELECT @Pi_SalId,@SchId,@CurSlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,E.FreePriceId AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM	
						SalesInvoiceSchemeDtFreePrd E WHERE E.SchId=@SchId AND E.SalId=@Pi_SalId

--						--Nanda
--						SELECT '4',* FROM @FreePrdDt 
					END
				END
				ELSE IF @SlabId<@CurSlabId
				BEGIN
					SELECT @RowId=MIN(RowId)  FROM @ReturnPrdHdForScheme WHERE  
					TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId

					SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM @ReturnPrdHdForScheme WHERE  
					TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId AND RowId=@RowId

					INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
					GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
					SELECT @Pi_SalId,@SchId,@CurSlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
					E.FreePrdId,E.FreePrdBatId,0 AS FreePriceId,
					0 AS GiftQty,0,0,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM	
					SalesInvoiceSchemeDtFreePrd E WHERE E.SchId=@SchId AND E.SalId=@Pi_SalId

--					--Nanda
--					SELECT '5',* FROM @FreePrdDt 
				END
			FETCH NEXT FROM SchemeFreeCur INTO @schid,@CurSlabId
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
				SELECT DISTINCT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 
							WHERE SchId NOT IN (SELECT SchId FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
--				--Nanda
--				SELECT * FROM UserFetchReturnScheme 
			END
			ELSE
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT DISTINCT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 	
--				--Nanda
--				SELECT * FROM UserFetchReturnScheme 
			END
			UPDATE A Set FreeQty=B.FreeQty ,FreePrdId=B.FreePrdId ,FreePrdBatId=B.FreePrdBatId,
					GiftQty=B.GiftQty ,GiftPrdId=B.GiftPrdId,GiftPrdBatId=B.GiftPrdBatId,
					FreePriceId=B.FreePriceId ,GiftPriceId=B.GiftPriceId FROM UserFetchReturnScheme A
					INNER JOIN @FreePrdDt B ON A.SalId=B.SalId AND A.SchId=B.SchId AND A.SlabId=B.SlabId --AND A.RowId=B.RowId
					AND A.PrdId=B.PrdId AND A.PrdbatId=B.PrdBatId 
					WHERE A.SalId=@Pi_SalId AND A.TransId=@Pi_TransId AND A.UsrId=@Pi_Usrid

			DELETE FROM UserFetchReturnScheme WHERE DiscAmt+FlatAmt+Points+FreeQty+GiftQty=0

		END	
--		SELECT * FROM UserFetchReturnScheme
	END
	ELSE IF @Config=1
	BEGIN
		INSERT INTO @t1 (SalId,SchId,PrdId,PrdbatId,FlatAmt,DiscPer,Points,NoofTimes)
		SELECT B.SalId,b.SchId,B.PrdId,B.PrdBatId,(b.FlatAmount-b.ReturnFlatAmount)as FlatAmt,
		((b.DiscountPerAmount)-ReturnDiscountPerAmount)  as DiscPer, 0 as Points,0
		FROM  SalesInvoiceSchemeLineWise b INNER JOIN ReturnPrdHdForScheme a ON
		a.PrdId = b.PrdId AND a.PrdBatId = b.PrdBatId
		WHERE b.SalId = @Pi_SalId AND a.UsrId = @Pi_Usrid AND a.TransId = @Pi_TransId
		GROUP BY B.SalId,b.SchId,B.PrdId,B.PrdBatId,b.FlatAmount,b.ReturnFlatAmount,
		b.DiscountPerAmount,ReturnDiscountPerAmount

		INSERT INTO @t1 (SalId,SchId,PrdId,PrdBatId,FlatAmt,DiscPer,Points,NoofTimes)
		SELECT b.SalId,a.SchId,C.PrdId,C.PrdBatId,0,0,(-1 * a.Points),0 AS NoOfTimes
		FROM ReturnPrdHdForScheme C,BillAppliedSchemeHd a Inner Join SalesInvoiceSchemeHd b on a.SchId=b.SchId
		WHERE  a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND C.SalId=b.SalId AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		AND b.SalId = @Pi_SalId AND (((-1 * a.FreeToBeGiven)<>0) OR ((-1 * a.GiftToBeGiven)<>0)) AND a.IsSelected=1

		INSERT INTO @t1 (SalId,SchId,PrdId,PrdBatId,FlatAmt,DiscPer,Points,NoofTimes)
		SELECT SalId,SchId,PrdId,PrdBatId,0 as FlatAmt,0 as DiscPer,(Points - ReturnPoints) as Points,0 
		FROM SalesInvoiceSchemeDtPoints WHERE SalId = @Pi_SalId

		SELECT SalId,SchId,PrdId,PrdBatId,SUM(FlatAmt) as FlatAmt,SUM(DiscPer) as DiscPer,SUM(Points) as Points,
		MAX(NoofTimes) as NoofTimes INTO #t2
		FROM @t1 GROUP BY SalId,SchId,PrdId,PrdBatId


		UPDATE A set BaseQty = (b.BaseQty-b.ReturnedQty)-A.RealQty
		FROM ReturnPrdHdForScheme a,SalesInvoiceProduct b WHERE a.SalId = b.SalId AND
		a.PrdId = b.PrdId AND a.PrdBatId = b.PrdBatId AND b.SalId = @Pi_SalId 
		AND a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId

		INSERT INTO @ReturnPrdHdForScheme
		SELECT * FROM ReturnPrdHdForScheme where Usrid= @Pi_Usrid
		AND TransId = @Pi_TransId AND SalId=@Pi_SalId

		Declare SchemeCur Cursor for
		SELECT distinct a.SchId,C.CombiSch,C.QPS FROM #t2 a INNER JOIN SchemeMaster C ON C.SchId = a.SchId
		open SchemeCur
		fetch next FROM SchemeCur into @SchId,@CombiSch,@QPS 
		while @@fetch_status= 0
		begin

			SELECT @SchType = SchType,@PurOfEveryReq = PurofEvery,@ProRata=ProRata FROM SchemeMaster 
			WHERE SchId = @SchId 

			DELETE FROM @TempBilled
			DELETE FROM @TempBilledAch
			SET @SlabId=0


			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,
				ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
				WHEN 3 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnKg,
				ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
				WHEN 5 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnLitre,@SchId
				FROM @ReturnPrdHdForScheme A INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
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
					FROM SchemeSlabs WHERE Schid = @SchId And SlabId = @SlabId


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


			DELETE FROM @tempsch1	
			SELECT @DiscPer = (SELECT ROUND(ISNULL(SUM(b.DiscPer),0),5) FROM #t2 b WHERE
	    		b.SalId = @Pi_SalId AND b.SchId = @SchId AND b.DiscPer<>0) --AND b.SlabId = @SlabId)
			
			SELECT @FlatAmt = (SELECT ROUND(ISNULL(SUM(b.FlatAmt),0),5) FROM #t2 b WHERE
	    		b.SalId = @Pi_SalId AND b.SchId = @SchId AND b.FlatAmt<>0) --AND b.SlabId = @SlabId )
			
    		SELECT @Points = (SELECT ISNULL(Sum(b.Points),0) FROM #t2 b WHERE
    			b.SalId = @Pi_SalId AND b.SchId = @SchId AND b.Points<>0) --AND b.SlabId = @SlabId)

			IF @SlabId=0 
			BEGIN

				INSERT INTO @TempSch1 (SalId,RowId,PrdId,PrdBatId,BaseQty,Selrate,Grossvalue,Schid,Slabid,
	    			Discper,Flatamt,Points,NoofTimes)

	   			SELECT DISTINCT a.SalId,a.RowId,ISNULL(C.PrdId,a.PrdId),ISNULL(A.PrdBatId,C.PrdBatId)
				,F.BaseQty,a.SelRate,A.SelRate*(F.BaseQty),B.SchId,
				E.SlabId,CASE E.FlxDisc WHEN 0 THEN E.SchemeDiscount ELSE B.Discper END,
				ISNULL(E.SchemeAmount,B.FlatAmt),E.Points,b.NoofTimes
				FROM @ReturnPrdHdForScheme a
				LEFT OUTER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END
				LEFT OUTER JOIN #t2 b ON A.SalId=B.SalId AND A.PrdId=B.PrdId AND A.PrdbatId=B.PrdBatId
				LEFT OUTER JOIN SchemeMaster d ON B.SchId=D.SchId
				LEFT OUTER JOIN BillAppliedSchemeHd E ON A.PrdId=E.PrdId and A.PrdBatId=E.PrdBatId AND D.SchId=E.SchId 
				AND A.TransId=E.TransId AND A.UsrId=E.UsrId AND E.IsSelected=1 
				INNER JOIN SalesInvoiceProduct F ON A.PrdId=F.PrdId AND A.PrdBatId=F.PrdBatId AND F.SalId=@Pi_SalId
				WHERE a.Usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND (ISNULL(E.SchemeAmount,B.FlatAmt)+(CASE E.FlxDisc WHEN 0 THEN E.SchemeDiscount ELSE B.Discper END)
				+b.Points)>0 AND E.SchId=@SchId 
			END
			ELSE
			BEGIN

				INSERT INTO @TempSch1 (SalId,RowId,PrdId,PrdBatId,BaseQty,Selrate,Grossvalue,Schid,Slabid,
	    			Discper,Flatamt,Points,NoofTimes)

	   			SELECT DISTINCT a.SalId,a.RowId,ISNULL(C.PrdId,a.PrdId),ISNULL(a.PrdBatId,C.PrdBatId)
				,ISNULL(a1.RealQty,0),ISNULL(a1.SelRate,G.PrdUom1SelRate),ISNULL(a1.BaseQty,0)*ISNULL(a1.SelRate,G.PrdUom1SelRate)
				,@SchId,D.SlabId,CASE E.FlxDisc WHEN 0 THEN D.DiscPer ELSE D.FlxDisc END,D.FlatAmt,
				ISNULL(D.Points,0),@NoOfTimes FROM SalesInvoiceSchemeLineWise A LEFT OUTER JOIN @ReturnPrdHdForScheme a1
				ON A.PrdId=a1.PrdId AND a.PrdBatId=a1.PrdbatId AND A.SalId=a1.SalId and
				a1.Usrid = @Pi_Usrid AND a1.TransId = @Pi_TransId 
				INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END
				LEFT OUTER JOIN SchemeSlabs d ON D.SchId=@SchId AND D.SlabId=@SlabId
				LEFT OUTER JOIN BillAppliedSchemeHd E ON A.PrdId=E.PrdId and A.PrdBatId=E.PrdBatId AND D.SchId=E.SchId 
				AND A1.TransId=E.TransId AND A1.UsrId=E.UsrId AND E.IsSelected=1 AND E.SchId=@SchId 
				INNER JOIN SalesInvoiceProduct G ON A.PrdId=G.PrdId AND A.PrdBatId=G.PrdBatId AND G.SalId=a.SalId
				WHERE a.SalId= @Pi_SalId
			END



			SELECT @Cnt1=COUNT(*) FROM ReturnPrdHdForScheme WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId
			SELECT @Cnt2=COUNT(*) FROM ReturnPrdHdForScheme WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND BaseQty-RealQty=0

			UPDATE ReturnPrdHdForScheme SET BaseQty=RealQty WHERE BaseQty=0 AND TransId=@Pi_TransId AND UsrId=@Pi_UsrId
			UPDATE @TempSch1 SET GrossValue=BaseQty*SelRate WHERE GrossValue=0 --AND Flatamt=0

			DELETE FROM @SchGross
			INSERT INTO @SchGross
			SELECT A.SchId,SUM(B.RealQty *B.Selrate) AS Amt FROM #t2 A INNER JOIN 
			ReturnPrdHdForScheme B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
			AND A.SalId=B.SalId 
			INNER JOIN SalesInvoiceProduct C ON B.SalId=C.SalId AND A.PrdId=C.PrdId
			AND A.PrdBatId=C.PrdBatId WHERE A.SalId=@Pi_SalId AND B.TransId= @Pi_TransId
			AND B.UsrId=@Pi_Usrid AND A.SchId=@SchId AND C.PrdSchDiscAmount>0 GROUP BY A.SchId

			
			SELECT @SumValue = (SELECT Sum(Grossvalue) FROM @TempSch1 WHERE SalId = @Pi_SalId AND SchId = @SchId)
			IF @DiscPer >0
			BEGIN
				IF @SlabId>0
				BEGIN
						IF EXISTS(SELECT * FROM @TempSch1)
						BEGIN
							IF @Cnt1=@Cnt2
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,((A.Grossvalue*A.Discper)/100) as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A INNER JOIN #t2 B ON A.SalId=B.SalId AND A.SchId=B.SchId
								AND A.PrdbatId=B.PrdbatId AND A.PrdId=B.PrdId
								LEFT OUTER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 

							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,(((C.DiscountPerAmount)-C.ReturnDiscountPerAmount)) -((A.Grossvalue*A.Discper)/100) as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A INNER JOIN #t2 B ON A.SalId=B.SalId AND A.SchId=B.SchId
								AND A.PrdbatId=B.PrdbatId AND A.PrdId=B.PrdId
								LEFT OUTER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
						END
						ELSE
						BEGIN
							insert into @TempSch2(SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
							SchemeDiscount,Points,Contri,NoofTimes)
							SELECT B.SalId,B.Slno,B.PrdId,B.PrdBatId,C.SchId,C.SlabId,0 AS SchemeAmount 
							,ABS(((C.DiscountPerAmount)-C.ReturnDiscountPerAmount)) AS SchemeDiscount,0 AS Points,
							100 as Contri,1 FROM 
							SalesInvoiceProduct B LEFT OUTER JOIN dbo.SalesInvoiceSchemeLineWise C ON
							B.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
							INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) D ON B.PrdId=D.PrdId 
							AND B.PrdBatId = CASE D.PrdBatId WHEN 0 THEN B.PrdBatId ELSE D.PrdBatId End
							WHERE B.SalId = @Pi_SalId AND C.SchId = @SchId 
						END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT A.* FROM SalesInvoiceSchemeLineWise A INNER JOIN @TempSch1 B ON A.SchId=B.SchId AND 
					A.SalId=B.SalId AND A.SlabId=B.SlabId WHERE A.SalId=@Pi_SalId AND A.SchId=@SchId )
					BEGIN
						INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
						SchemeDiscount,Points,Contri,NoofTimes)
						SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
						0 as SchemeAmount,(((C.DiscountPerAmount)-C.ReturnDiscountPerAmount)) as SchemeDiscount,
						0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
						FROM @TempSch1 A INNER JOIN #t2 B ON A.SalId=B.SalId AND A.SchId=B.SchId
						AND A.PrdbatId=B.PrdbatId AND A.PrdId=B.PrdId
						LEFT OUTER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
						WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
					END
					ELSE IF EXISTS(SELECT * FROM @TempSch1)
					BEGIN
						SELECT @TempSlabId=SlabId FROM @TempSch1 WHERE SchId=@SchId
						SELECT @SlabId=Min(SlabId) FROM SchemeSlabs WHERE SchId=@SchId
						UPDATE @TempSch1 SET SlabId=@SlabId WHERE SchId=@SchId
						UPDATE A SET DiscPer= CASE  WHEN B.FlxDisc>0 THEN B.FlxDisc ELSE  B.DiscPer END 
						FROM @TempSch1 A INNER JOIN SchemeSlabs B
						ON A.SchId=B.SchId AND A.SlabId=B.SlabId WHERE B.SchId=@SchId
						AND B.SlabId=@SlabId 				

						INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
						SchemeDiscount,Points,Contri,NoofTimes)
						SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
						0 as SchemeAmount,(((C.DiscountPerAmount)-C.ReturnDiscountPerAmount))-((A.Grossvalue*A.Discper)/100)+ C.PrimarySchemeAmt/A.BaseQty as SchemeDiscount,
						0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
						FROM @TempSch1 A INNER JOIN #t2 B ON A.SalId=B.SalId AND A.SchId=B.SchId
						AND A.PrdbatId=B.PrdbatId AND A.PrdId=B.PrdId
						LEFT OUTER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
						WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId  

					END
					ELSE
					BEGIN
						INSERT INTO @TempSch2(SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
						SchemeDiscount,Points,Contri,NoofTimes)
						SELECT B.SalId,B.Slno,B.PrdId,B.PrdBatId,C.SchId,C.SlabId,0 AS SchemeAmount 
						,ABS(((C.DiscountPerAmount)-C.ReturnDiscountPerAmount)) AS SchemeDiscount,0 AS Points,
						100 as Contri,1 FROM 
						SalesInvoiceProduct B LEFT OUTER JOIN dbo.SalesInvoiceSchemeLineWise C ON
						B.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
						INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) D ON B.PrdId=D.PrdId 
						AND B.PrdBatId = CASE D.PrdBatId WHEN 0 THEN B.PrdBatId ELSE D.PrdBatId End
						WHERE B.SalId = @Pi_SalId AND C.SchId = @SchId 
					END
				END
			END

			SELECT @SumValue = (SELECT Sum(Grossvalue) FROM @TempSch1 WHERE SalId = @Pi_SalId AND SchId = @SchId)-- AND SlabId = @SlabId)			
			if @Flatamt > 0
			BEGIN
				IF @SlabId>0
				BEGIN
					IF EXISTS(SELECT * FROM @TempSch1 )
					BEGIN
						IF @Cnt1=@Cnt2
						BEGIN
							INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
							SchemeDiscount,Points,Contri,NoofTimes)
							SELECT Distinct C.SalId,C.RowId,C.PrdId,C.PrdBatId,C.Schid,@SlabId,
							(CAST(ISNULL(A.FlatAmt*(ISNUll(A.BaseQty,0)*ISNULL(A.Selrate,0)/F.Amt),0)*ISNULL(@NoOfTimes,0) AS NUMERIC(38,6))) as SchemeAmount,0 as SchemeDiscount,
							0 as Points,@NoOfTimes as Contri,@NoOfTimes
							FROM SalesInvoiceSchemeLineWise C LEFT OUTER JOIN @TempSch1 A  ON A.SalId=C.SalId 
							And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId 
							INNER JOIN @SchGross F ON C.SchId=F.SchId
							WHERE C.SalId = @Pi_SalId AND C.SchId = @SchId
						END
						ELSE
						BEGIN
							IF EXISTS(SELECT * FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@SchId AND SlabId=@SlabId)
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct C.SalId,C.RowId,C.PrdId,C.PrdBatId,C.Schid,@SlabId,
								0 as SchemeAmount,0 as SchemeDiscount,
								0 as Points,@NoOfTimes as Contri,@NoOfTimes
								FROM SalesInvoiceSchemeLineWise C LEFT OUTER JOIN @TempSch1 A  ON A.SalId=C.SalId 
								And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId 
								INNER JOIN @SchGross F ON C.SchId=F.SchId
								WHERE C.SalId = @Pi_SalId AND C.SchId = @SchId
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct C.SalId,C.RowId,C.PrdId,C.PrdBatId,C.Schid,@SlabId,
								((C.FlatAmount)-C.ReturnFlatAmount)-(CAST(ISNULL(A.FlatAmt*(ISNUll(A.BaseQty,0)*ISNULL(A.Selrate,0)/F.Amt),0)*ISNULL(@NoOfTimes,0) AS NUMERIC(38,6))) as SchemeAmount,0 as SchemeDiscount,
								0 as Points,@NoOfTimes as Contri,@NoOfTimes
								FROM SalesInvoiceSchemeLineWise C LEFT OUTER JOIN @TempSch1 A  ON A.SalId=C.SalId 
								And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId 
								INNER JOIN @SchGross F ON C.SchId=F.SchId
								WHERE C.SalId = @Pi_SalId AND C.SchId = @SchId
							END
						END

						DELETE FROM @TempSch2 WHERE SchemeAmount=0 AND SchemeDiscount=0 AND Points=0
					END
					ELSE
					BEGIN
						insert into @TempSch2(SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
						SchemeDiscount,Points,Contri,NoofTimes)
						SELECT B.SalId,B.Slno,B.PrdId,B.PrdBatId,C.SchId,C.SlabId,
						ABS(((C.FlatAmount)-C.ReturnFlatAmount)) AS SchemeAmount 
						,0 AS SchemeDiscount,0 AS Points,
						100 as Contri,1 FROM 
						SalesInvoiceProduct B INNER JOIN dbo.SalesInvoiceSchemeLineWise C ON
						B.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
						INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) D ON B.PrdId=D.PrdId 
						AND B.PrdBatId = CASE D.PrdBatId WHEN 0 THEN B.PrdBatId ELSE D.PrdBatId End
						WHERE B.SalId = @Pi_SalId AND C.SchId = @SchId 


						DELETE FROM @TempSch2 WHERE SchemeAmount=0 AND SchemeDiscount=0 AND Points=0
		
					END
				END
				ELSE
				BEGIN

					IF EXISTS(SELECT A.* FROM SalesInvoiceSchemeLineWise A INNER JOIN @TempSch1 B ON A.SchId=B.SchId AND 
					A.SalId=B.SalId AND A.SlabId=B.SlabId WHERE A.SalId=@Pi_SalId AND A.SchId=@SchId )
					BEGIN
						insert into @TempSch2(SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
						SchemeDiscount,Points,Contri,NoofTimes)
						SELECT B.SalId,B.Slno,B.PrdId,B.PrdBatId,C.SchId,C.SlabId,
						ABS(((C.FlatAmount)-C.ReturnFlatAmount)) AS SchemeAmount 
						,0 AS SchemeDiscount,0 AS Points,
						100 as Contri,1 FROM 
						SalesInvoiceProduct B INNER JOIN dbo.SalesInvoiceSchemeLineWise C ON
						B.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
						INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) D ON B.PrdId=D.PrdId 
						AND B.PrdBatId = CASE D.PrdBatId WHEN 0 THEN B.PrdBatId ELSE D.PrdBatId End
						WHERE B.SalId = @Pi_SalId AND C.SchId = @SchId 
					END
					ELSE IF @SlabId=0
					BEGIN
						INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
						SchemeDiscount,Points,Contri,NoofTimes)
						SELECT Distinct C.SalId,C.RowId,C.PrdId,C.PrdBatId,C.Schid,C.SlabId,
						 (C.FlatAmount-C.ReturnFlatAmount) as SchemeAmount,0 as SchemeDiscount,
						0 as Points,@NoOfTimes as Contri,@NoOfTimes
						FROM SalesInvoiceSchemeLineWise C LEFT OUTER JOIN @TempSch1 A  ON A.SalId=C.SalId 
						And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId 
						INNER JOIN @SchGross F ON C.SchId=F.SchId
						WHERE C.SalId = @Pi_SalId AND C.SchId = @SchId

						
					END	
					ELSE IF EXISTS(SELECT * FROM @TempSch1)
					BEGIN
						SELECT @TempSlabId=SlabId FROM @TempSch1 WHERE SchId=@SchId
						SELECT @SlabId=Min(SlabId) FROM SchemeSlabs WHERE SchId=@SchId
						UPDATE @TempSch1 SET SlabId=@SlabId WHERE SchId=@SchId

						UPDATE A SET Flatamt= CASE  WHEN B.FlxValueDisc>0 THEN B.FlxValueDisc ELSE  B.FlatAmt END 
						FROM @TempSch1 A INNER JOIN SchemeSlabs B
						ON A.SchId=B.SchId AND A.SlabId=B.SlabId WHERE B.SchId=@SchId
						AND B.SlabId=@SlabId 

						--To Get the Number of Times the Scheme should apply
						IF @PurOfEveryReq = 0
						BEGIN
							SET @NoOfTimes = 1
						END
						ELSE
						BEGIN
							SELECT @NoOfTimes = SUM(CAST(C.SchemeOnQty AS NUMERIC(18,6)))/CAST(A.ForEveryQty AS NUMERIC(18,6)) FROM SchemeSlabs A INNER JOIN @TempSch1 B
							ON A.SchId=B.SchId AND A.SlabId=B.SlabId INNER JOIN @TempBilled C ON A.SchId=B.SchId
							WHERE A.SchId=@SchId AND A.SlabId=@SlabId GROUP BY A.ForEveryQty 

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

						INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
						SchemeDiscount,Points,Contri,NoofTimes)
						SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
						((C.FlatAmount)-C.ReturnFlatAmount)-A.FlatAmt*@NoOfTimes as SchemeAmount,0 as SchemeDiscount,
						0 as Points,@NoOfTimes as Contri,A.NoofTimes
						FROM @TempSch1 A INNER JOIN #t2 B ON A.SalId=B.SalId AND A.SchId=B.SchId
						AND A.PrdbatId=B.PrdbatId AND A.PrdId=B.PrdId
						LEFT OUTER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
						WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
					END
				
					DELETE FROM @TempSch2 WHERE SchemeAmount=0 AND SchemeDiscount=0 AND Points=0

				END
			END

			if @Points > 0
			BEGIN
				SELECT @SumValue = (SELECT Sum(Grossvalue) FROM @TempSch1 WHERE SalId = @Pi_SalId AND SchId = @SchId )
				IF @SlabId>0
				BEGIN
					IF EXISTS(SELECT * FROM @TempSch1)
					BEGIN
						IF @Cnt1=@Cnt2
						BEGIN
							INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
							SchemeDiscount,Points,Contri,NoofTimes)
							SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
							0 as SchemeAmount,0 as SchemeDiscount,
							SUM(A.Points) as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
							FROM @TempSch1 A INNER JOIN #t2 B ON A.SalId=B.SalId AND A.SchId=B.SchId
							AND A.PrdbatId=B.PrdbatId AND A.PrdId=B.PrdId
							LEFT OUTER JOIN dbo.SalesInvoiceSchemeDtPoints C ON
							A.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
							WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							GROUP BY  A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,A.Grossvalue,A.NoofTimes
						END
						ELSE
						BEGIN
							INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
							SchemeDiscount,Points,Contri,NoofTimes)
							SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
							0 as SchemeAmount,0 as SchemeDiscount,
							(C.Points-C.ReturnPoints)-SUM(A.Points) as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
							FROM @TempSch1 A INNER JOIN #t2 B ON A.SalId=B.SalId AND A.SchId=B.SchId
							AND A.PrdbatId=B.PrdbatId AND A.PrdId=B.PrdId
							LEFT OUTER JOIN dbo.SalesInvoiceSchemeDtPoints C ON
							A.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
							WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							GROUP BY  A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,A.Grossvalue,A.NoofTimes,C.Points,C.ReturnPoints
						END
					END
					ELSE
					BEGIN
						insert into @TempSch2(SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
						SchemeDiscount,Points,Contri,NoofTimes)
						SELECT B.SalId,B.Slno,B.PrdId,B.PrdBatId,C.SchId,C.SlabId,
						0 AS SchemeAmount,0 AS SchemeDiscount,ABS(C.Points-C.ReturnPoints) AS Points,
						100 as Contri,1 FROM 
						SalesInvoiceProduct B INNER JOIN dbo.SalesInvoiceSchemeDtPoints C ON
						B.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
						INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) D ON B.PrdId=D.PrdId 
						AND B.PrdBatId = CASE D.PrdBatId WHEN 0 THEN B.PrdBatId ELSE D.PrdBatId End
						WHERE B.SalId = @Pi_SalId AND C.SchId = @SchId 
					END
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT * FROM @TempSch1)
					BEGIN
						SELECT @TempSlabId=SlabId FROM @TempSch1 WHERE SchId=@SchId
						SELECT @SlabId=Min(SlabId) FROM SchemeSlabs WHERE SchId=@SchId
						UPDATE @TempSch1 SET SlabId=@SlabId WHERE SchId=@SchId
						UPDATE A SET Points= CASE  WHEN B.FlxPoints>0 THEN B.FlxPoints ELSE  B.Points END 
						FROM @TempSch1 A INNER JOIN SchemeSlabs B
						ON A.SchId=B.SchId AND A.SlabId=B.SlabId WHERE B.SchId=@SchId
						AND B.SlabId=@SlabId 

						--To Get the Number of Times the Scheme should apply
						IF @PurOfEveryReq = 0
						BEGIN
							SET @NoOfTimes = 1
						END
						ELSE
						BEGIN
							SELECT @NoOfTimes = SUM(CAST(C.SchemeOnQty AS NUMERIC(18,6)))/CAST(A.ForEveryQty AS NUMERIC(18,6)) FROM SchemeSlabs A INNER JOIN @TempSch1 B
							ON A.SchId=B.SchId AND A.SlabId=B.SlabId INNER JOIN @TempBilled C ON A.SchId=B.SchId
							WHERE A.SchId=@SchId AND A.SlabId=@SlabId GROUP BY A.ForEveryQty 

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

						INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
						SchemeDiscount,Points,Contri,NoofTimes)
						SELECT DISTINCT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
						0 as SchemeAmount,0 as SchemeDiscount,
						(C.Points-C.ReturnPoints)-SUM(A.Points) as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
						FROM @TempSch1 A INNER JOIN #t2 B ON A.SalId=B.SalId AND A.SchId=B.SchId
						AND A.PrdbatId=B.PrdbatId AND A.PrdId=B.PrdId
						LEFT OUTER JOIN dbo.SalesInvoiceSchemeDtPoints C ON
						A.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
						WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
						GROUP BY  A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,A.Grossvalue,A.NoofTimes,C.Points,C.ReturnPoints
					END
					ELSE
					BEGIN
						INSERT INTO @TempSch2(SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
						SchemeDiscount,Points,Contri,NoofTimes)
						SELECT B.SalId,B.Slno,B.PrdId,B.PrdBatId,C.SchId,C.SlabId,
						0 AS SchemeAmount,0 AS SchemeDiscount,ABS(C.Points-C.ReturnPoints) AS Points,
						100 AS Contri,1 FROM 
						SalesInvoiceProduct B INNER JOIN dbo.SalesInvoiceSchemeDtPoints C ON
						B.SalId=C.SalId And B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
						INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) D ON B.PrdId=D.PrdId 
						AND B.PrdBatId = CASE D.PrdBatId WHEN 0 THEN B.PrdBatId ELSE D.PrdBatId End
						WHERE B.SalId = @Pi_SalId AND C.SchId = @SchId
					END
				END
			END
				
			FETCH NEXT FROM SchemeCur INTO @schid ,@CombiSch,@QPS
		END
		CLOSE SchemeCur
		DEALLOCATE SchemeCur

		SELECT SalId,SchId,SlabId,SUM(CAST(SchemeAmount AS NUMERIC(18,2))) AS SchAmt,SUM(SchemeDiscount) AS SchDisc,
		SUM(Points) AS SchPoints INTO #Test1 FROM @TempSch2
		GROUP BY SalId,SchId,SlabId 

		DELETE A FROM  @TempSch2 A INNER JOIN #Test1 B ON A.SalId=B.SalId AND A.SchId=B.SchId
		AND A.SlabId=B.SlabId WHERE B.SchAmt=0 AND B.SchDisc=0 AND B.SchPoints=0


		INSERT INTO UserFetchReturnScheme(SalId,RowId,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,FreeQty,
		FreePrdId,FreePrdBatId,FreePriceId,GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,NoofTimes,Usrid,TransId)
		SELECT a.SalId,a.RowId,a.PrdId,a.PrdBatId,b.SchId,b.SlabId,b.SchemeDiscount,b.SchemeAmount,
			b.Points,0,0,0,0,0,0,0,0,b.NoofTimes,@Pi_Usrid,@Pi_TransId
		FROM @ReturnPrdHdForScheme a INNER JOIN @TempSch2 b ON
		a.SalId=b.SalId AND a.PrdId = b.PrdId AND a.PrdBatId=b.PrdBatId --AND a.RowId=B.RowId
		WHERE a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId = @Pi_SalId
		ORDER BY a.RowId

		DECLARE SchUpdateCur CURSOR FOR
		SELECT DISTINCT SalId,SchId,SlabId FROM UserFetchReturnScheme
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
		SELECT DISTINCT * INTO #UserFetchReturnScheme FROM UserFetchReturnScheme
		DELETE FROM UserFetchReturnScheme
		INSERT INTO UserFetchReturnScheme SELECT  * FROM #UserFetchReturnScheme

		IF EXISTS (SELECT * FROM BillAppliedSchemeHd B WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid 
					AND (B.FreeToBeGiven + B.GiftToBeGiven+B.FlxFreePrd+B.FlxGiftPrd)>0 AND B.IsSelected=1)
		BEGIN
			DECLARE SchemeFreeCur CURSOR FOR
			SELECT DISTINCT a.SchId FROM BillAppliedSchemeHd a WHERE a.TransId=@Pi_TransId AND a.UsrId=@Pi_Usrid 
			AND (a.FreeToBeGiven + a.GiftToBeGiven+a.FlxFreePrd+a.FlxGiftPrd)>0 AND a.IsSelected=1
			OPEN SchemeFreeCur
			FETCH NEXT FROM SchemeFreeCur INTO @SchId
			WHILE @@fetch_status= 0
			BEGIN		

				SET @SlabId=0
				DELETE FROM @TempBilled
				DELETE FROM @TempBilledAch
				INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
				SELECT DISTINCT A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,
					ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnKg,
					ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnLitre,@SchId
					FROM @ReturnPrdHdForScheme A INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
					A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C ON A.PrdId = C.PrdId
					INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
					WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId
					GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId


				--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
				INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
				SELECT DISTINCT ISNULL(CASE @SchType
					WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
					WHEN 2 THEN SUM(SchemeOnAmount)
					WHEN 3 THEN (CASE A.UomId
							WHEN 2 THEN SUM(SchemeOnKg) * 1000
							WHEN 3 THEN SUM(SchemeOnKg)
							WHEN 4 THEN SUM(SchemeOnLitre) * 1000
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

--					SELECT @SlabId
					IF @SlabId>0
					BEGIN
						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)

						SELECT @Pi_SalId,@SchId,@SlabId,(E.FreeQty-E.ReturnFreeQty)-B.FreeToBeGiven AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,0 AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,
						B.PrdId,B.PrdBatId,C.RowId FROM	BillAppliedSchemeHd B 
						INNER JOIN BilledPrdHdForScheme C ON B.PrdId=C.PrdId AND C.PrdBatId=B.PrdBatId AND
						B.TransId=C.TransId AND B.UsrId=C.UsrId
						LEFT OUTER JOIN SalesInvoiceSchemeDtFreePrd E ON  B.SchId=E.SchId
						WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId
						AND B.IsSelected=1 AND E.SalId=@Pi_SalId
					END
					ELSE IF @SlabId=0
					BEGIN
						IF EXISTS (SELECT * FROM BillAppliedSchemeHd B WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid 
								AND (B.FreeToBeGiven + B.GiftToBeGiven+B.FlxFreePrd+B.FlxGiftPrd)>0 AND B.IsSelected=1 AND SchId=@SchId AND SlabId=@CurSlabId)
						BEGIN
							INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
							GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)

							SELECT @Pi_SalId,@SchId,B.SlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
							E.FreePrdId,E.FreePrdBatId,0 AS FreePriceId,
							0 AS GiftQty,0,0,0 AS GiftPriceId,B.PrdId,B.PrdBatId,C.RowId FROM	BillAppliedSchemeHd B 
							INNER JOIN SalesInvoiceSchemeDtFreePrd E ON B.SchId=E.SchId AND B.SlabId=E.SlabId
							INNER JOIN @ReturnPrdHdForScheme C ON B.PrdId=C.PrdId AND B.PrdbatId=C.PrdbatId
							WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId 
							AND B.IsSelected=1 AND E.SalId=@Pi_SalId

						END
						ELSE
						BEGIN
							SELECT @RowId=MIN(RowId)  FROM @ReturnPrdHdForScheme WHERE  
							TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId

							SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM @ReturnPrdHdForScheme WHERE  
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
		END
		ELSE
		BEGIN
			INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
			GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
			SELECT A.SalId,A.SchId,SlabId,FreeQty,FreePrdId,A.FreePrdBatId,A.FreePriceId,A.GiftQty,
			A.GiftPrdId,A.GiftPrdBatId,A.GiftPriceId,B.PrdId,B.PrdBatId,B.SlNo FROM
			(SELECT A.SalId,A.SchId,ISNULL(C.SlabId,A.SlabId) AS SlabId,ABS(ISNULL(C.FreeToBeGiven-(A.FreeQty-A.ReturnFreeQty) ,(A.FreeQty-A.ReturnFreeQty)))as FreeQty,
			ISNULL(C.FreePrdId,A.FreePrdId) AS FreePrdId,ISNULL(C.FreePrdBatId,A.FreePrdBatId) AS FreePrdBatId,
			CASE ISNULL(C.FreeToBeGiven ,(A.FreeQty-A.ReturnFreeQty))
			WHEN 0 THEN 0 ELSE A.FreePriceId END AS FreePriceId,
			ISNULL(C.GiftToBeGiven-(A.GiftQty-A.ReturnGiftQty),(A.GiftQty-A.ReturnGiftQty)) as GiftQty,
			isnull(C.GiftPrdId,A.GiftPrdId) AS GiftPrdId,ISNULL(C.GiftPrdBatId,A.GiftPrdBatId) AS GiftPrdBatId,
			CASE ISNULL(C.GiftToBeGiven,(A.GiftQty-A.ReturnGiftQty)) WHEN 0 THEN 0 ELSE A.GiftPriceId END AS GiftPriceId
			FROM SalesInvoiceSchemeDtFreePrd A LEFT OUTER JOIN BillAppliedSchemeHd C ON 
			A.SchId=C.SchId AND C.IsSelected=1 AND C.TransId=@Pi_TransId AND C.UsrId=@Pi_Usrid 
			WHERE A.SalId = @Pi_SalId) A LEFT OUTER JOIN SalesInvoiceProduct B ON 
			A.SalId=B.SalId  INNER JOIN BilledPrdHdForScheme C ON B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
			WHERE C.TransId=@Pi_TransId AND C.UsrId=@Pi_Usrid
		END

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
				
--				--Nanda
--				SELECT * FROM UserFetchReturnScheme 
			END
			ELSE
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,
							RowId,FreePriceId,GiftPriceId)
				SELECT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
							FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
							RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 

--				--Nanda
--				SELECT * FROM UserFetchReturnScheme 							
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

--SRF-Nanda-180-003

IF NOT EXISTS(SELECT * FROM DependencyTable WHERE PrimaryTable='Product'
AND RelatedTable ='PurchaseOrderDetails')
BEGIN
	INSERT INTO DependencyTable(PrimaryTable,RelatedTable,FieldName)
	VALUES('Product','PurchaseOrderDetails','PrdId')	
END

--SRF-Nanda-180-004

UPDATE CustomCaptions SET Caption='MRP',DefaultCaption='MRP'
WHERE TransId=7 AND CtrlId=38 AND SubCtrlId=16 

--SRF-Nanda-180-005

DELETE FROM Configuration WHERE ModuleId LIKE 'BotreeVillage'

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('BotreeVillage','Botree Village','Treat Company Village Code as Village Code',1,'',0,1)

--SRF-Nanda-180-006

DELETE FROM RptGroup WHERE RptId=216

INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName)
VALUES('RspReport',216,'RDSMWorkingEfficiencyReport','RDSM Working Efficiency Report')

DELETE FROM RptHeader WHERE RptId=216

INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds) 
VALUES('RDSMWorkingEfficiencyReport','RDSM Working Efficiency Report',216,'RDSM Working Efficiency Report','Proc_RptRDSMWorkingEfficiency',
'RptRDSMWorkingEfficiency','RptRDSMWorkingEfficiency.Rpt',1)

DELETE FROM RptDetails WHERE RptId=216

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(216,1,'Company',-1,'','CmpId,CmpCode,CmpName','Company*...','',1,'',4,1,1,'Press F4/Double Click to select Company',0)

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(216,2,'JCMast',1,'CmpId','JcmId,JcmYr,JcmYr','JC Year*...','Company',1,'CmpId',12,1,1,'Press F4/Double Click to select JC year',0)

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(216,3,'JCMonth',2,'JCMId','JcmJc,JcmSdt,JcmSdt','JC Month*...','JcMast',1,'JcmId',13,1,1,'Press F4/Double Click to select JC Month',0)

INSERT INTO RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange)
VALUES(216,4,'Salesman',-1,'','SMId,SMCode,SMName','Salesman...','',1,'',1,1,0,'Press F4/Double Click to select Salesman',0)

DELETE FROM RptFormula WHERE RptId=216 

--Headers
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,1,'SMCode','Salesman Code',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,2,'SMName','Salesman Name',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,3,'DaysSchd','Days Scheduled',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,4,'DaysWorked','Days Worked',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,5,'CallsMade','Calls Made',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,6,'CallsProductive','Productive Calls',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,7,'LinesTarget','Lines Target',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,8,'LinesSold','Lines Sold',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,9,'ValueTarget','Value Target',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,10,'ValueAchieved','Value Achieved',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,11,'FB1Target','FB1 Target',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,12,'FB1Achievement','FB1 Achievement',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,13,'FB1CallsPrd','FB1 CallsPrd',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,14,'FB2Target','FB2 Target',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,15,'FB2Achievement','FB2 Achievement',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,16,'FB2CallsPrd','FB2 CallsPrd',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,17,'FB3Target','FB3 Target',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,18,'FB3Achievement','FB3 Achievement',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,19,'FB3CallsPrd','FB3 CallsPrd',1,0)

--Filters
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,20,'Fil_Company','Company',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,21,'Fil_Salesman','Salesman',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,22,'Fil_JCYear','JC Year',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,23,'Fil_JCMonth','JC Month',1,0)

--Filters Value
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,24,'FilDisp_Company','Company',1,4)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,25,'FilDisp_Salesman','Salesman',1,1)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,26,'FilDisp_JCYear','JC Year',1,12)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,27,'FilDisp_JCMonth','JC Month',1,13)

--Footers
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,28,'Cap Page','Page',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,29,'Cap_UserName','User Name',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,30,'Cap_PrintDate','Date',1,0)

--Total
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(216,30,'Hd_Total','Total',1,0)


DELETE FROM RptExcelHeaders WHERE RptId=216

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,1,'SMId','SMId',0,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,2,'SMCode','Salesman Code',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,3,'SMName','Salesman Name',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,4,'JCMId','JCMId',0,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,5,'JCMJC','JCMJC',0,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,6,'DaysSchd','Days Scheduled',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,7,'DaysWorked','Days Worked',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,8,'CallsMade','Calls Made',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,9,'CallsProductive','Productive Calls',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,10,'LinesTarget','Lines Target',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,11,'LinesSold','Lines Sold',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,12,'ValueTarget','Value Target',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,13,'ValueAchieved','Value Achieved',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,14,'FB1Target','Target',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,15,'FB1Achievement','Achievement',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,16,'FB1CallsPrd','CallsPrd',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,17,'FB2Target','Target',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,18,'FB2Achievement','Achievement',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,19,'FB2CallsPrd','Productive Calls',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,20,'FB3Target','Target',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,21,'FB3Achievement','Achievement',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,22,'FB3CallsPrd','Productive Calls',1,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,23,'GeneratedDate','GeneratedDate',0,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,24,'RptId','RptId',0,1)

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES(216,25,'UserId','UserId',0,1)

--SRF-Nanda-180-007

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_FocusBrand]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_FocusBrand]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_FocusBrand]
(
	[DistCode] [nvarchar](50) NULL,
	[FBId] [int] NULL,	
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[SlNo] [int] NULL,
	[PrdHierLevel] [nvarchar](200) NULL,
	[PrdHierLevelValue] [nvarchar](200) NULL,
	[DownLoadFlag] [nvarchar](10) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-180-008

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_RDSMWorkingEfficiency]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_RDSMWorkingEfficiency]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_RDSMWorkingEfficiency]
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[DataYear] [int] NULL,
	[DataMonth] [int] NULL,
	[AsOnDate] [datetime] NULL,
	[SMId] [int] NULL,
	[SMCode] [nvarchar](100) NULL,
	[SMName] [nvarchar](200) NULL,
	[DaysSchd] [int] NULL,
	[DaysWorked] [int] NULL,
	[CallsMade] [int] NULL,
	[CallsProductive] [int] NULL,
	[LinesTarget] [int] NULL,
	[LinesSold] [int] NULL,
	[ValueTarget] [numeric](38, 6) NULL,
	[ValueAchieved] [numeric](38, 6) NULL,
	[FB1Target] [numeric](38, 6) NULL,
	[FB1Achievement] [numeric](38, 6) NULL,
	[FB1CallsPrd] [int] NULL,
	[FB2Target] [numeric](38, 6) NULL,
	[FB2Achievement] [numeric](38, 6) NULL,
	[FB2CallsPrd] [int] NULL,
	[FB3Target] [numeric](38, 6) NULL,
	[FB3Achievement] [numeric](38, 6) NULL,
	[FB3CallsPrd] [int] NULL,
	[GeneratedDate] [datetime] NULL,
	[UploadFlag] [nvarchar](10) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-180-009

if exists (select * from dbo.sysobjects where id = object_id(N'[Cn2Cs_Prk_PurchaseReceiptMapping]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cn2Cs_Prk_PurchaseReceiptMapping]
GO

CREATE TABLE [dbo].[Cn2Cs_Prk_PurchaseReceiptMapping]
(
	[DistCode] [nvarchar](30) NULL,
	[CompInvNo] [nvarchar](25) NULL,
	[CompInvDate] [datetime] NULL,
	[SupplierCode] [nvarchar](50) NULL,
	[PrdCCode] [nvarchar](50) NULL,
	[PrdName] [nvarchar](200) NULL,
	[PrdMapCode] [nvarchar](50) NULL,
	[PrdMapName] [nvarchar](200) NULL,
	[UOMCode] [nvarchar](25) NULL,
	[Qty] [int] NULL,
	[Rate] [numeric](38, 6) NULL,
	[GrossAmount] [numeric](38, 6) NULL,
	[DiscAmount] [numeric](38, 6) NULL,
	[TaxAmount] [numeric](38, 6) NULL,
	[NetAmount] [numeric](38, 6) NULL,
	[FreeSchemeFlag] [nvarchar](5) NULL,
	[SlNo] [int] NULL,
	[DownLoadFlag] [nvarchar](10) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-180-010

if exists (select * from dbo.sysobjects where id = object_id(N'[PurchaseReceiptMapping]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [PurchaseReceiptMapping]
GO

CREATE TABLE [dbo].[PurchaseReceiptMapping]
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
GO

--SRF-Nanda-180-011

if exists (select * from dbo.sysobjects where id = object_id(N'[RptRDSMWorkingEfficiency]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptRDSMWorkingEfficiency]
GO

CREATE TABLE [dbo].[RptRDSMWorkingEfficiency]
(
	[SMId] [int] NULL,
	[SMCode] [nvarchar](100) NULL,
	[SMName] [nvarchar](200) NULL,
	[JCMId] [int] NULL,
	[JCMJC] [int] NULL,
	[DaysSchd] [int] NULL,
	[DaysWorked] [int] NULL,
	[CallsMade] [int] NULL,
	[CallsProductive] [int] NULL,
	[LinesTarget] [int] NULL,
	[LinesSold] [int] NULL,
	[ValueTarget] [numeric](38, 6) NULL,
	[ValueAchieved] [numeric](38, 6) NULL,
	[FB1Target] [numeric](38, 6) NULL,
	[FB1Achievement] [numeric](38, 6) NULL,
	[FB1CallsPrd] [int] NULL,
	[FB2Target] [numeric](38, 6) NULL,
	[FB2Achievement] [numeric](38, 6) NULL,
	[FB2CallsPrd] [int] NULL,
	[FB3Target] [numeric](38, 6) NULL,
	[FB3Achievement] [numeric](38, 6) NULL,
	[FB3CallsPrd] [int] NULL,
	[GeneratedDate] [datetime] NULL,
	[RptId] [int] NULL,
	[UserId] [int] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-180-012

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_GetWorkingDays]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_GetWorkingDays]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT dbo.GetWorkingDays('20100301','20100331')

CREATE FUNCTION [dbo].[Fn_GetWorkingDays]  
(  
    @Pi_StartDate	DATETIME,  
    @Pi_EndDate		DATETIME  
) 
RETURNS INT  
AS  
BEGIN 
    DECLARE @Range INT 
 
    SET @Range = DATEDIFF(DAY, @Pi_StartDate, @Pi_EndDate)+1 
 
    RETURN  
    ( 
        SELECT  
        @Range / 7 * 6 + @Range % 7 -  
        ( 
            SELECT COUNT(*)  
			FROM 
            ( 
                SELECT 1 AS d 
                UNION ALL SELECT 2  
                UNION ALL SELECT 3  
                UNION ALL SELECT 4  
                UNION ALL SELECT 5  
                UNION ALL SELECT 6  
                UNION ALL SELECT 7 
            ) weekdays 
            WHERE d <= @Range % 7  
            AND DATENAME(WEEKDAY, @Pi_EndDate - d + 1)  
            IN 
            ( 
                'Sunday' 
            ) 
        ) 
    ) 
END  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-180-013

IF NOT EXISTS(SELECT * FROM Geography)
BEGIN
	DELETE FROM GeographyLevel
	UPDATE Counters SET CurrValue=0 WHERE TabNAme= 'GeographyLevel' 
	UPDATE Counters SET CurrValue=0 WHERE TabNAme= 'Geography' 
END

--SRF-Nanda-180-014

IF NOT EXISTS(SELECT * FROM DayEndProcess WHERE ProcId=14)
BEGIN
	INSERT INTO DayEndProcess(ProcDate,ProcId,NextUpDate,ProcDesc)
	VALUES(GETDATE(),14,GETDATE()-1,'RDSM Working Efficiency')
END

--SRF-Nanda-180-015

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Import_FocusBrand]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Import_FocusBrand]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Import_FocusBrand '<Root><Console2CS_FocusBrand DistCode="1342678" FBId="1" FromDate="2010-12-01T00:00:00" ToDate="2010-12-31T23:59:59" SlNo="1" PrdHierLevel="BRD            " PrdHierLevelValue="700060001" CreatedDate="2010-12-01T18:56:45.077" DownLoadFlag="N"/><Console2CS_FocusBrand DistCode="1342678" FBId="1" FromDate="2010-12-01T00:00:00" ToDate="2010-12-31T23:59:59" SlNo="2" PrdHierLevel="BRD            " PrdHierLevelValue="750251" CreatedDate="2010-12-01T18:56:45.077" DownLoadFlag="N"/><Console2CS_FocusBrand DistCode="1342678" FBId="1" FromDate="2010-12-01T00:00:00" ToDate="2010-12-31T23:59:59" SlNo="3" PrdHierLevel="BRD            " PrdHierLevelValue="750252" CreatedDate="2010-12-01T18:56:45.077" DownLoadFlag="N"/></Root>'
SELECT * FROM Cn2Cs_Prk_FocusBrand
ROLLBACK TRANSACTION
*/
CREATE	PROCEDURE [dbo].[Proc_Import_FocusBrand]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_Import_FocusBrand
* PURPOSE		: To Insert records from xml file in the Table Cn2Cs_Prk_FocusBrand
* CREATED		: Nandakumar R.G
* CREATED DATE	: 25/11/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records

	INSERT INTO Cn2Cs_Prk_FocusBrand(DistCode,FBId,FromDate,ToDate,SlNo,PrdHierLevel,PrdHierLevelValue,DownLoadFlag)
	SELECT DistCode,FBId,FromDate,ToDate,SlNo,PrdHierLevel,PrdHierLevelValue,DownLoadFlag
	FROM OPENXML (@hdoc,'/Root/Console2CS_FocusBrand',1)
	WITH 
	(
		[DistCode] 			NVARCHAR(50),
		[FBId]				INT,
		[FromDate]			DATETIME,
		[ToDate]			DATETIME,
		[SlNo]				INT,
		[PrdHierLevel]		NVARCHAR(200),
		[PrdHierLevelValue]	NVARCHAR(200),	
		[DownLoadFlag]		NVARCHAR(10)
	) XMLObj

	EXEC sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-180-016

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

	--->Added By Nanda on 09/11/2010
	DECLARE @MaxSchId	AS INT
	DECLARE @FBMSchCode AS NVARCHAR(100)
	DECLARE @FBMSchId	AS INT
	DECLARE @FBMDate	AS DATETIME
	SELECT @MaxSchId=ISNULL(MAX(SchId),0) FROM SchemeProducts
	--->Till Here
	

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

	--->Added By Nanda on 09/11/2010
	IF EXISTS(SELECT SP.* FROM SchemeProducts SP,SchemeMaster SM WHERE SM.FBM=1 AND SP.SchId=SM.SchId AND SP.SchId>@MaxSchId)
	BEGIN

		DECLARE Cur_FBMSch CURSOR
		FOR SELECT DISTINCT SM.SchCode,SM.SchId FROM SchemeProducts SP,SchemeMaster SM WHERE SM.FBM=1 AND SP.SchId=SM.SchId AND SP.SchId>@MaxSchId		
		OPEN Cur_FBMSch
		FETCH NEXT FROM Cur_FBMSch INTO @FBMSchCode,@FBMSchId
		WHILE @@FETCH_STATUS=0
		BEGIN					
			SELECT @FBMDate=CONVERT(VARCHAR(10),GETDATE(),121)
			--SELECT 'Nanda02',45,@FBMSchCode,@FBMSchId,@FBMDate,1,0
			EXEC Proc_FBMTrack 45,@FBMSchCode,@FBMSchId,@FBMDate,1,0		
			FETCH NEXT FROM Cur_FBMSch INTO @FBMSchCode,@FBMSchId
		END
		CLOSE Cur_FBMSch
		DEALLOCATE Cur_FBMSch
	END
	--->Till Here
	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-180-017

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_FocusBrand]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_FocusBrand]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_FocusBrand
--UPDATE Cn2Cs_Prk_FocusBrand SET DownLoadFlag='D'
EXEC Proc_Cn2Cs_FocusBrand 0
SELECT * FROM ErrorLog
SELECT * FROM FocusBrandHd
SELECT * FROM FocusBrandDt
ROLLBACK TRANSACTION
*/

CREATE PROCEDURE [dbo].[Proc_Cn2Cs_FocusBrand]
(
       @Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_FocusBrand
* PURPOSE		: To validate the downloaded Focus Brand Details 
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 26/11/2010
* NOTE			: 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @Exists  INT
	DECLARE @Trans  INT

	DECLARE @FBId				AS INT
	DECLARE @FromDate			AS DATETIME
	DECLARE @ToDate				AS DATETIME
	DECLARE @SlNo				AS INT
	DECLARE @PrdHierLevel		AS NVARCHAR(100)
	DECLARE @PrdHierLevelValue	AS NVARCHAR(100)

	DECLARE @CmpPrdCtgId		AS INT
	DECLARE @PrdCtgValMainId	AS INT
	DECLARE @CmpId				AS INT

	DECLARE @FocusRefNo			AS NVARCHAR(100)

	DECLARE @sStr	nVarchar(4000)
	
	SET @Po_ErrNo=0

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'FocusToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE FocusToAvoid	
	END

	CREATE TABLE FocusToAvoid
	(
		FBId	INT
	)

	IF EXISTS(SELECT DISTINCT FBId FROM Cn2Cs_Prk_FocusBrand
	WHERE PrdHierLevel NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel))
	BEGIN
		INSERT INTO FocusToAvoid(FBId)
		SELECT DISTINCT FBId FROM Cn2Cs_Prk_FocusBrand
		WHERE PrdHierLevel NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Focus Brand','Product Category Level','Product Category Level :'+PrdHierLevel+'is not available'
		FROM Cn2Cs_Prk_FocusBrand
		WHERE PrdHierLevel NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel)		
	END

	IF EXISTS(SELECT DISTINCT FBId FROM Cn2Cs_Prk_FocusBrand
	WHERE PrdHierLevelValue NOT IN (SELECT PrdCtgValCode FROM ProductCategoryValue))
	BEGIN
		INSERT INTO FocusToAvoid(FBId)
		SELECT DISTINCT FBId FROM Cn2Cs_Prk_FocusBrand
		WHERE PrdHierLevelValue NOT IN (SELECT PrdCtgValCode FROM ProductCategoryValue)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Focus Brand','Product Category Level Value','Product Category Level Value:'+PrdHierLevelValue+'is not available'
		FROM Cn2Cs_Prk_FocusBrand
		WHERE PrdHierLevelValue NOT IN (SELECT PrdCtgValCode FROM ProductCategoryValue)		
	END

	SELECT @CmpId=ISNULL(CmpId,0) FROM Company WHERE DefaultCompany=1

	DECLARE Cur_FocusBrand CURSOR
	FOR SELECT DISTINCT FBId,CONVERT(NVARCHAR(10),FromDate,121),CONVERT(NVARCHAR(10),ToDate,121),SlNo,PrdHierLevel,PrdHierLevelValue
	FROM Cn2Cs_Prk_FocusBrand WHERE DownLoadFlag='D' AND FBId NOT IN (SELECT FBId FROM FocusToAvoid) 
	ORDER BY SlNo
	OPEN Cur_FocusBrand
	FETCH NEXT FROM Cur_FocusBrand INTO @FBId,@FromDate,@ToDate,@SlNo,@PrdHierLevel,@PrdHierLevelValue
	WHILE @@FETCH_STATUS=0
	BEGIN		

		SET @Exists = 0 
		SET @Trans	= 0
		SET @PrdCtgValMainId= 0

		IF EXISTS(SELECT * FROM FocusBrandHd WHERE FromDate=@FromDate AND ToDate=@ToDate)
		BEGIN
			SET @Exists = 1
			SELECT @FocusRefNo=FocusRefNo FROM FocusBrandHd WHERE FromDate=@FromDate AND ToDate=@ToDate
		END

		IF @Exists=0
		BEGIN
			SELECT @FocusRefNo=dbo.Fn_GetPrimaryKeyString('FocusBrandHd','FocusRefNo',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpPrdCtgName=@PrdHierLevel 	

			INSERT INTO FocusBrandHd(FocusRefNo,CmpId,CmpPrdCtgId,FromDate,ToDate,Status,Period,JcmId,JcmSdtId,JcmEdtId,ModeValue,
			Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT @FocusRefNo,@CmpId,@CmpPrdCtgId,@FromDate,@ToDate,1,1,0,0,0,0,1,1,GETDATE(),1,GETDATE()

			UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='FocusBrandHd' AND FldName='FocusRefNo'
		END
		
		SELECT @PrdCtgValMainId=PrdCtgValMainId FROM ProductCategoryValue WHERE PrdCTgValCode=@PrdHierLevelValue
		IF @PrdCtgValMainId>0
		BEGIN
			DELETE FROM FocusBrandDt WHERE FocusRefNo=@FocusRefNo AND PrdCtgValMainId=@PrdCtgValMainId
			INSERT INTO FocusBrandDt(FocusRefNo,PrdCtgValMainId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT @FocusRefNo,@PrdCtgValMainId,1,1,GETDATE(),1,GETDATE()
		END
		FETCH NEXT FROM Cur_FocusBrand INTO @FBId,@FromDate,@ToDate,@SlNo,@PrdHierLevel,@PrdHierLevelValue
	END
	CLOSE Cur_FocusBrand
	DEALLOCATE Cur_FocusBrand

	UPDATE Cn2Cs_Prk_FocusBrand SET DownLoadFlag='Y' WHERE FBId NOT IN (SELECT FBId FROM FocusToAvoid)

	RETURN

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-180-018

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_HierarchyLevelValue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_HierarchyLevelValue]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_HierarchyLevelValue
TRUNCATE TABLE ETL_Prk_GeographyHierarchyLevelValue
EXEC Proc_Cn2Cs_HierarchyLevelValue 0
SELECT * FROM ETL_Prk_GeographyHierarchyLevelValue
SELECT * FROM Geography
SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/

CREATE      PROCEDURE  [dbo].[Proc_Cn2Cs_HierarchyLevelValue]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_HierarchyLevelValue
* PURPOSE		: To validate and update/insert the downloaded hierarchy data
* CREATED		: Nandakumar R.G
* CREATED DATE	: 26/03/2010
* MODIFIED		:
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus INT
	DECLARE @CmpCode   NVARCHAR(50)
	SELECT @CmpCode=CmpCode FROM Company WHERE DefaultCompany=1 	

	TRUNCATE TABLE ETL_Prk_RetailerCategoryLevelValue

	INSERT INTO ETL_Prk_RetailerCategoryLevelValue([Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Hierarchy Level Value Code],[Hierarchy Level Value Name],[Company Code])
	SELECT DISTINCT LevelName,ParentCode,HierarchyCode,HierarchyName,@CmpCode
	FROM Cn2Cs_Prk_HierarchyLevelValue WHERE DownLoadFlag='D' AND HierarchyType=4 ORDER BY LevelName

	TRUNCATE TABLE ETL_Prk_GeographyHierarchyLevelValue
	
	INSERT INTO ETL_Prk_GeographyHierarchyLevelValue([Geography Hierarchy Level Code],[Parent Hierarchy Level Value Code],
	[Geography Hierarchy Level Value Code],[Geography Hierarchy Level Value Name],[Population])
	SELECT DISTINCT LevelName,ParentCode,HierarchyCode,HierarchyName,AddInfo1
	FROM Cn2Cs_Prk_HierarchyLevelValue WHERE DownLoadFlag='D' AND HierarchyType=2 ORDER BY LevelName

	UPDATE ETL SET [Parent Hierarchy Level Value Code]='GeoFirstLevel'
	FROM ETL_Prk_GeographyHierarchyLevelValue ETL,GeographyLevel Geo
	WHERE ETL.[Geography Hierarchy Level Code]=Geo.LevelName AND ETL.[Geography Hierarchy Level Code]='Level1'

	UPDATE ETL SET [Geography Hierarchy Level Code]=GeoLevelName
	FROM ETL_Prk_GeographyHierarchyLevelValue ETL,GeographyLevel Geo
	WHERE ETL.[Geography Hierarchy Level Code]=Geo.LevelName

	EXEC Proc_ValidateRetailerCategoryLevelValue @Po_ErrNo= @ErrStatus OUTPUT
	EXEC Proc_ValidateGeographyHierarchyLevelValue @Po_ErrNo= @ErrStatus OUTPUT

	UPDATE Cn2Cs_Prk_HierarchyLevelValue SET DownLoadFlag='Y'
	WHERE HierarchyCode IN (SELECT CtgCode FROM RetailerCategory) AND HierarchyType=4

	UPDATE Cn2Cs_Prk_HierarchyLevelValue SET DownLoadFlag='Y'
	WHERE HierarchyCode IN (SELECT GeoCode FROM Geography) AND HierarchyType=2

	SET @Po_ErrNo= @ErrStatus
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-180-019

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_PurchaseReceiptMapping]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_PurchaseReceiptMapping]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_PurchaseReceiptMapping
EXEC Proc_Cn2Cs_PurchaseReceiptMapping 0
SELECT * FROM PurchaseReceiptMapping-- WHERE TabName='ReasonMaster'
ROLLBACK TRANSACTION
*/

CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_PurchaseReceiptMapping]
(
	@Po_ErrNo INT OUTPUT
)
AS
/**********************************************************
* PROCEDURE		: Proc_Cn2Cs_PurchaseReceiptMapping
* PURPOSE		: To Download the Purchase Receipt Mapping details from Console to Core Stocky
* CREATED		: Nandakumar R.G
* CREATED DATE	: 25/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
***********************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @Tabname  			NVARCHAR(50)
	DECLARE @Exists				INT

	DECLARE @ReasonId			INT
	DECLARE @DistCode			NVARCHAR(100)
	DECLARE @CompInvNo			NVARCHAR(50)
	DECLARE @CompInvDate		DATETIME
	DECLARE @SpmCode			NVARCHAR(50)
	DECLARE @PrdId				INT
	DECLARE @PrdCCode			NVARCHAR(50)
	DECLARE @PrdName			NVARCHAR(200)
	DECLARE @PrdMapCode			NVARCHAR(50)
	DECLARE @PrdMapName			NVARCHAR(200)
	DECLARE @UOMCode			NVARCHAR(50)
	DECLARE @Qty				INT
	DECLARE @Rate				NUMERIC(38,6)
	DECLARE @GrossAmt			NUMERIC(38,6)
	DECLARE @DiscAmt			NUMERIC(38,6)
	DECLARE @TaxAmt				NUMERIC(38,6)
	DECLARE @NetAmt				NUMERIC(38,6)
	DECLARE @FreeSchemeFlag		NVARCHAR(5)
	DECLARE @SlNo				INT

	SET @ErrStatus=1
	SET @Po_ErrNo=0

	SET @Tabname = 'Cn2Cs_Prk_PurchaseReceiptMapping'

	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'PRMapToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE PRMapToAvoid	
	END
	CREATE TABLE PRMapToAvoid
	(		
		CompInvNo		NVARCHAR(200)
	)

	IF EXISTS(SELECT * FROM Cn2Cs_Prk_PurchaseReceiptMapping WHERE ISNULL(CompInvNo,'')='') 
	BEGIN
		INSERT INTO PRMapToAvoid(CompInvNo)
		SELECT CompInvNo FROM Cn2Cs_Prk_PurchaseReceiptMapping WHERE ISNULL(CompInvNo,'')=''

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_PurchaseReceiptMapping','CompInvNo','Company Invoice No should not be empty'
		FROM Cn2Cs_Prk_PurchaseReceiptMapping WHERE ISNULL(CompInvNo,'')=''
	END	

	DECLARE Cur_PRMap CURSOR	
	FOR SELECT DISTINCT CompInvNo,CompInvDate,SupplierCode,PrdCCode,PrdName,PrdMapCode,PrdMapName,
	UOMCode,Qty,Rate,GrossAmount,DiscAmount,TaxAmount,NetAmount,FreeSchemeFlag,SlNo
	FROM Cn2Cs_Prk_PurchaseReceiptMapping WHERE DownloadFlag='D' AND ISNULL(CompInvNo,'')<>''
	OPEN Cur_PRMap
	FETCH NEXT FROM Cur_PRMap INTO @CompInvNo,@CompInvDate,@SpmCode,@PrdCCode,@PrdName,@PrdMapCode,@PrdMapName,
	@UOMCode,@Qty,@Rate,@GrossAmt,@DiscAmt,@TaxAmt,@TaxAmt,@FreeSchemeFlag,@SlNo
	WHILE @@FETCH_STATUS=0
	BEGIN		

		IF NOT EXISTS(SELECT * FROM PurchaseReceiptMapping WHERE CompInvNo=@CompInvNo AND PrdCCode=@PrdCCode AND PrdMapCode=@PrdMapCode)
		BEGIN			
			INSERT INTO PurchaseReceiptMapping(CompInvNo,CompInvDate,SpmCode,PrdId,PrdCCode,PrdName,PrdMapCode,PrdMapName,
			UOMCode,Qty,Rate,GrossAmount,DiscAmount,TaxAmount,NetAmount,FreeSchemeFlag,SlNo,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@CompInvNo,@CompInvDate,@SpmCode,0,@PrdCCode,@PrdName,@PrdMapCode,@PrdMapName,
			@UOMCode,@Qty,@Rate,@GrossAmt,@DiscAmt,@TaxAmt,@TaxAmt,@FreeSchemeFlag,@SlNo,1,1,GETDATE(),1,GETDATE())						
		END		

		FETCH NEXT FROM Cur_PRMap INTO @CompInvNo,@CompInvDate,@SpmCode,@PrdCCode,@PrdName,@PrdMapCode,@PrdMapName,
		@UOMCode,@Qty,@Rate,@GrossAmt,@DiscAmt,@TaxAmt,@TaxAmt,@FreeSchemeFlag,@SlNo
	END
    CLOSE Cur_PRMap
	DEALLOCATE Cur_PRMap

	UPDATE PR SET PR.PrdId=P.PrdId
	FROM PurchaseReceiptMapping PR,Product P
	WHERE PR.PrdCCode=P.PrdCCode AND PR.CompInvNo IN 
	(SELECT CompInvNo FROM Cn2Cs_Prk_PurchaseReceiptMapping)

	UPDATE Cn2Cs_Prk_PurchaseReceiptMapping SET DownloadFlag='Y' WHERE DownloadFlag='D' AND ISNULL(CompInvNo,'')<>''

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-180-020

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ReasonMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ReasonMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
BEGIN TRANSACTION
SELECT * FROM Cn2Cs_Prk_ReasonMaster
EXEC Proc_Cn2Cs_ReasonMaster 0
SELECT * FROM Counters WHERE TabName='ReasonMaster'
SELECT * FROM ReasonMaster
ROLLBACK TRANSACTION
*/
CREATE    PROCEDURE [dbo].[Proc_Cn2Cs_ReasonMaster]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ReasonMaster
* PURPOSE		: To Download the Reason details from Console to Core Stocky
* CREATED		: Nandakumar R.G
* CREATED DATE	: 09/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN

	DECLARE @ErrStatus			INT
	DECLARE @sSql				NVARCHAR(2000)
	DECLARE @ErrDesc  			NVARCHAR(1000)
	DECLARE @Tabname  			NVARCHAR(50)
	DECLARE @Exists				INT
	DECLARE @ReasonId			INT
	DECLARE @DistCode			NVARCHAR(100)
	DECLARE @ReasonCode			NVARCHAR(100)
	DECLARE @Description		NVARCHAR(100)
	DECLARE @ApplicableTo		NVARCHAR(100)
	SET @ErrStatus=1
	SET @Po_ErrNo=0
	SET @Tabname = 'Cn2Cs_Prk_ReasonMaster'
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ReasonToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ReasonToAvoid	
	END
	CREATE TABLE ReasonToAvoid
	(		
		RSMCode		NVARCHAR(200)
	)
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_ReasonMaster WHERE ISNULL(ReasonCode,'')='')
	BEGIN
		INSERT INTO ReasonToAvoid(RSMCode)
		SELECT ReasonCode FROM Cn2Cs_Prk_ReasonMaster WHERE ISNULL(ReasonCode,'')=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT 1,'Cn2Cs_Prk_ReasonMaster','Reason Code','Reason code should not be empty'
		FROM Cn2Cs_Prk_ReasonMaster WHERE ISNULL(ReasonCode,'')=''
	END	
	DECLARE Cur_Reason CURSOR	
	FOR SELECT DISTINCT ReasonCode,Description
	FROM Cn2Cs_Prk_ReasonMaster WHERE DownloadFlag='D' AND ISNULL(ReasonCode,'')<>''
	OPEN Cur_Reason
	FETCH NEXT FROM Cur_Reason INTO @ReasonCode,@Description
	WHILE @@FETCH_STATUS=0
	BEGIN		
		IF NOT EXISTS(SELECT * FROM ReasonMaster WHERE ReasonCode=@ReasonCode)
		BEGIN
			SET @ReasonId=0
			SET @ReasonId = dbo.Fn_GetPrimaryKeyInteger('ReasonMaster','ReasonId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
			IF @ReasonId>0
			BEGIN
				INSERT INTO ReasonMaster(ReasonId,ReasonCode,Description,PurchaseReceipt,SalesInvoice,VanLoad,CrNoteSupplier,CrNoteRetailer,
				DeliveryProcess,SalvageRegister,PurchaseReturn,SalesReturn,VanUnload,DbNoteSupplier,DbNoteRetailer,StkAdjustment,StkTransferScreen,
				BatchTransfer,ReceiptVoucher,ReturnToCompany,LocationTrans,Billing,ChequeBouncing,ChequeDisbursal,
				Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@ReasonId,@ReasonCode,@Description,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,GETDATE(),1,GETDATE())

				UPDATE Counters SET CurrValue=@ReasonId WHERE TabName='ReasonMaster'
			END
			ELSE
			BEGIN
				SET @ErrDesc='Check the System Date'
				INSERT INTO Errorlog VALUES (1,@TabName,'Description',@ErrDesc)
		  		SET @Po_ErrNo=1
			END
		END
		ELSE
		BEGIN
			SELECT @ReasonId=ReasonId FROM ReasonMaster WHERE ReasonCode=@ReasonCode
			UPDATE ReasonMaster SET PurchaseReceipt=0,SalesInvoice=0,VanLoad=0,CrNoteSupplier=0,CrNoteRetailer=0,
			DeliveryProcess=0,SalvageRegister=0,PurchaseReturn=0,SalesReturn=0,VanUnload=0,DbNoteSupplier=0,DbNoteRetailer=0,
			StkAdjustment=0,StkTransferScreen=0,BatchTransfer=0,ReceiptVoucher=0,ReturnToCompany=0,LocationTrans=0,
			Billing=0,ChequeBouncing=0,ChequeDisbursal=0 WHERE ReasonId=@ReasonId
		END
		
		IF @Po_ErrNo=0
		BEGIN
			DECLARE Cur_ReasonApplicable CURSOR	
			FOR SELECT DISTINCT ReasonCode,Description,ApplicableTo
			FROM Cn2Cs_Prk_ReasonMaster WHERE DownloadFlag='D' AND ReasonCode=@ReasonCode
			OPEN Cur_ReasonApplicable
			FETCH NEXT FROM Cur_ReasonApplicable INTO @ReasonCode,@Description,@ApplicableTo
			WHILE @@FETCH_STATUS=0
			BEGIN		
				SET @sSql=''
				IF @ApplicableTo='All'
				BEGIN
					SET @sSql='UPDATE ReasonMaster SET PurchaseReceipt=1,SalesInvoice=1,VanLoad=1,CrNoteSupplier=1,CrNoteRetailer=1,
					DeliveryProcess=1,SalvageRegister=1,PurchaseReturn=1,SalesReturn=1,VanUnload=1,DbNoteSupplier=1,DbNoteRetailer=1,
					StkAdjustment=1,StkTransferScreen=1,BatchTransfer=1,ReceiptVoucher=1,ReturnToCompany=1,LocationTrans=1,Billing=1,
					ChequeBouncing=1,ChequeDisbursal=1 WHERE ReasonId='+CAST(@ReasonId AS NVARCHAR(10))
				END
				ELSE
				BEGIN
					IF NOT EXISTS (SELECT Id,Name FROM SysColumns WHERE Name = @ApplicableTo AND Id IN (SELECT Id FROM
					SysObjects WHERE Name ='ReasonMaster'))
					BEGIN
						SET @sSql='UPDATE ReasonMaster SET '+@ApplicableTo+'=1 WHERE ReasonId='+CAST(@ReasonId AS NVARCHAR(10))
					END					
				END
				IF LTRIM(RTRIM(@sSql))<>''
				BEGIN
					EXEC (@sSql)
				END
				FETCH NEXT FROM Cur_ReasonApplicable INTO @ReasonCode,@Description,@ApplicableTo
			END
			CLOSE Cur_ReasonApplicable
			DEALLOCATE Cur_ReasonApplicable
		END		
		FETCH NEXT FROM Cur_Reason INTO @ReasonCode,@Description
	END
	CLOSE Cur_Reason
	DEALLOCATE Cur_Reason

	UPDATE Cn2Cs_Prk_ReasonMaster SET DownloadFlag='Y' WHERE DownloadFlag='D' AND ISNULL(ReasonCode,'')<>''

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-180-021

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RDSMWorkingEfficiency]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RDSMWorkingEfficiency]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
DELETE FROM RptRDSMWorkingEfficiency
EXEC Proc_RDSMWorkingEfficiency 216,2
SELECT * FROM RptRDSMWorkingEfficiency
ROLLBACK TRANSACTION
*/

CREATE PROCEDURE [dbo].[Proc_RDSMWorkingEfficiency]
(
	@Pi_RptId  INT,
	@Pi_UsrId  INT
)
AS
/*********************************
* PROCEDURE		: Proc_RDSMWorkingEfficiency
* PURPOSE		: To get the Salesman Working Efficiency
* CREATED		: Nandakumar R.G
* CREATED DATE	: 24/11/2010
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON
	
	DECLARE @sSql  AS  nVarChar(4000)
	DECLARE @ErrNo   AS INT

	--Filter Variable
	DECLARE @CmpId      AS INT
	DECLARE @SMId		AS INT
	DECLARE @JcmId		AS INT
	DECLARE @JCMonth	AS INT	
	DECLARE @Days		AS INT

	DECLARE @FromDate	AS DATETIME
	DECLARE @ToDate		AS DATETIME

	DECLARE @LastFromDate	AS DATETIME
	DECLARE @LastToDate		AS DATETIME
	--Till Here

	--Assgin Value for the Filter Variable
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @JcmId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId))  
	SET @JCMonth = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,13,@Pi_UsrId))  
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))	

	CREATE TABLE #TempFoucsBrands
	(
		FBRefNo				NVARCHAR(100),
		FBId				INT IDENTITY(1,1),		
		PrdCtgValMainId		INT
	)

	CREATE TABLE #TempFoucsProducts
	(
		FBId				INT,		
		PrdCtgValMainId		INT,
		PrdId				INT
	)

	IF @JCMonth>0 AND @JcmId>0
	BEGIN
		SELECT @Days=dbo.Fn_GetWorkingDays(JcmSdt,JcmEdt)
		FROM JcMonth WHERE JcmId=@JcmId AND JcmJC=@JCMonth

		SELECT @FromDate=JcmSdt,@ToDate=JcmEdt FROM JcMonth WHERE JcmId=@JcmId AND JcmJC=@JCMonth

		IF @JCMonth>1
		BEGIN
			SELECT @LastFromDate=JcmSdt,@LastToDate=JcmEdt FROM JcMonth WHERE JcmId=@JcmId AND JcmJC=@JCMonth-1
		END
		ELSE
		BEGIN
			SELECT @LastFromDate=JcmSdt,@LastToDate=JcmEdt FROM JcMonth WHERE JcmId=@JcmId-1 AND JcmJC=12
		END
	END
	ELSE
	BEGIN
		SET @Days=0
		SET @FromDate='2000/01/01'
		SET @ToDate='2000/01/01'		

		SET @LastFromDate='2000/01/01'
		SET @LastToDate='2000/01/01'		
	END	

	INSERT INTO #TempFoucsBrands(FBRefNo,PrdCtgValMainId)
	SELECT TOP 3 FH.FocusRefNo,FB.PrdCtgValMainId
	FROM FocusBrandHd FH,FocusBrandDt FB
	WHERE FH.FocusRefNo=FB.FocusRefNo AND FH.FromDate=@FromDate AND FH.ToDate = @ToDate
	ORDER BY FB.PrdCtgValMainId
	
	INSERT INTO #TempFoucsProducts(FBId,PrdCtgValMainId,PrdId)
	SELECT B.FBId,B.PrdCtgValMainId,E.PrdId
	FROM #TempFoucsBrands B 
	INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
	INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
	INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 	

	DELETE FROM RptRDSMWorkingEfficiency WHERE RptId=@Pi_RptId AND UserId=@Pi_UsrId
 
	INSERT INTO RptRDSMWorkingEfficiency(SMId,SMCode,SMName,JCMId,JCMJC,DaysSchd,DaysWorked,CallsMade,CallsProductive,LinesTarget,LinesSold,
	ValueTarget,ValueAchieved,FB1Target,FB1Achievement,FB1CallsPrd,FB2Target,FB2Achievement,FB2CallsPrd,FB3Target,FB3Achievement,FB3CallsPrd,
	GeneratedDate,RptId,UserId) 
	SELECT SMId,SMCode,SMName,@JcmId,@JCMonth,@Days,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,GETDATE(),@Pi_RptId,@Pi_UsrId FROM Salesman
	WHERE (SMId=  (CASE @SMId WHEN 0 THEN SMId ELSE 0 END ) OR
	SMId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))

	--For Worked Days
	UPDATE A SET A.DaysWorked=B.DaysWorked
	FROM RptRDSMWorkingEfficiency A,
	(SELECT A.EmpId AS SMId,COUNT(Mode) AS DaysWorked
	FROM AttendanceRegister A,JcMonth J 
	WHERE J.JcmId=@JcmId AND J.JcmJC=@JCMonth
	AND A.TypeId=1 AND Mode=1 AND A.AttendanceDate BETWEEN JcmSdt AND JcmEdt
	GROUP BY A.EmpId
	) AS B
	WHERE A.SMId=B.SMId	

	--For Calls Made
	UPDATE A SET A.CallsMade=B.CallsMade
	FROM RptRDSMWorkingEfficiency A,
	(SELECT RCM.SMId,SUM(RCPSchCalls) AS CallsMade 
	FROM RouteCovPlanMaster RCM,RouteCovPlanDetails RCD
	WHERE RCM.RCPMasterId=RCD.RCPMasterId AND RCD.RcpGeneratedDates 
	BETWEEN @FromDate AND @ToDate
	GROUP BY RCM.SMId) AS B
	WHERE A.SMId=B.SMId 

	--For Productive Calls 
	UPDATE A SET A.CallsProductive=B.CallsPrd
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,COUNT(DISTINCT RtrId) AS CallsPrd
	FROM SalesInvoice SI WHERE DlvSts<>3 AND SalInvDate BETWEEN @FromDate AND @ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Lines Target
	UPDATE A SET A.LinesTarget=B.LinesTarget
	FROM RptRDSMWorkingEfficiency A,
	(
		SELECT SMId,SUM(LinesTarget) AS LinesTarget 
		FROM
		(
			SELECT SMId,RtrId,COUNT(DISTINCT SIP.PrdID)+COUNT(DISTINCT SIP.PrdID)*.05 AS LinesTarget
			FROM SalesInvoice SI ,SalesInvoiceProduct SIP WHERE DlvSts<>3 	
			AND SI.SalId=SIP.SalId
			AND SalInvDate BETWEEN @LastFromDate AND @LastToDate
			GROUP BY SMId,RtrId
		) AS SM 
		GROUP BY SMId
	) AS B
	WHERE A.SMId=B.SMId
	
	--For Lines Sold
	UPDATE A SET A.LinesSold=B.LinesSold
	FROM RptRDSMWorkingEfficiency A,
	(
		SELECT SMId,SUM(LinesSold) AS LinesSold
		FROM 
		(
			SELECT SMId,RtrId,COUNT(DISTINCT SIP.PrdID)AS LinesSold
			FROM SalesInvoice SI ,SalesInvoiceProduct SIP WHERE DlvSts<>3 	
			AND SI.SalId=SIP.SalId
			AND SalInvDate BETWEEN @FromDate AND @ToDate
			GROUP BY SMId,RtrId
		) AS C
		GROUP BY SMId
	) AS B
	WHERE A.SMId=B.SMId

	--For Value Target
	UPDATE A SET A.ValueTarget=B.ValueTarget
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(SalGrossAmount,0))+SUM(ISNULL(SalGrossAmount,0))*.05 AS ValueTarget
	FROM SalesInvoice SI WHERE DlvSts<>3 	
	AND SalInvDate BETWEEN @LastFromDate AND @LastToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Value Achievement
	UPDATE A SET A.ValueAchieved=B.ValueAchieved
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(SalGrossAmount,0)) AS ValueAchieved
	FROM SalesInvoice SI WHERE DlvSts<>3 	
	AND SalInvDate BETWEEN @FromDate AND @ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId	

	--For Focus Brand 1 Target
	UPDATE A SET A.FB1Target=B.FB1Target
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(PrdGrossAmount,0))+SUM(ISNULL(PrdGrossAmount,0))*.05 AS FB1Target
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=1
	AND SalInvDate BETWEEN @LastFromDate AND @LastToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 1 Achievement
	UPDATE A SET A.FB1Achievement=B.FB1Achievement
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(PrdGrossAmount,0)) AS FB1Achievement
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=1
	AND SalInvDate BETWEEN @FromDate AND @ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 1 Productive Calls
	UPDATE A SET A.FB1CallsPrd=B.FB1CallsPrd
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,COUNT(DISTINCT SI.RtrId) AS FB1CallsPrd 
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=1
	AND SalInvDate BETWEEN @FromDate AND @ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 2 Target
	UPDATE A SET A.FB2Target=B.FB2Target
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(PrdGrossAmount,0))+SUM(ISNULL(PrdGrossAmount,0))*.05 AS FB2Target
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=2
	AND SalInvDate BETWEEN @LastFromDate AND @LastToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 2 Achievement
	UPDATE A SET A.FB2Achievement=B.FB2Achievement
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(PrdGrossAmount,0)) AS FB2Achievement
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=2
	AND SalInvDate BETWEEN @FromDate AND @ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 2 Productive Calls
	UPDATE A SET A.FB2CallsPrd=B.FB2CallsPrd
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,COUNT(DISTINCT SI.RtrId) AS FB2CallsPrd 
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=2
	AND SalInvDate BETWEEN @FromDate AND @ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 3 Target
	UPDATE A SET A.FB3Target=B.FB3Target
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(PrdGrossAmount,0))+SUM(ISNULL(PrdGrossAmount,0))*.05 AS FB3Target
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=3
	AND SalInvDate BETWEEN @LastFromDate AND @LastToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 3 Achievement
	UPDATE A SET A.FB3Achievement=B.FB3Achievement
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(PrdGrossAmount,0)) AS FB3Achievement
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=3
	AND SalInvDate BETWEEN @FromDate AND @ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 3 Productive Calls
	UPDATE A SET A.FB3CallsPrd=B.FB3CallsPrd
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,COUNT(DISTINCT SI.RtrId) AS FB3CallsPrd 
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=3
	AND SalInvDate BETWEEN @FromDate AND @ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-180-022

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RDSMWorkingEfficiencyForUpload]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RDSMWorkingEfficiencyForUpload]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_RDSMWorkingEfficiencyForUpload 216,2
SELECT * FROM RptRDSMWorkingEfficiency
ROLLBACK TRANSACTION
*/

CREATE PROCEDURE [dbo].[Proc_RDSMWorkingEfficiencyForUpload]
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_FromDate	DATETIME,
	@Pi_ToDate		DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_RDSMWorkingEfficiencyForUpload
* PURPOSE		: To get the Salesman Working Efficiency for Upoad
* CREATED		: Nandakumar R.G
* CREATED DATE	: 26/11/2010
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON
	
	DECLARE @sSql  AS  nVarChar(4000)
	DECLARE @ErrNo   AS INT

	--Filter Variable
	DECLARE @CmpId      AS INT
	DECLARE @JcmId		AS INT
	DECLARE @JCMonth	AS INT	
	DECLARE @Days		AS INT

	DECLARE @LastFromDate	AS DATETIME
	DECLARE @LastToDate		AS DATETIME
	--Till Here

	--Assgin Value for the Filter Variable
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @JcmId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId))  
	SET @JCMonth = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,13,@Pi_UsrId))  

	CREATE TABLE #TempFoucsBrands
	(
		FBRefNo				NVARCHAR(100),
		FBId				INT IDENTITY(1,1),		
		PrdCtgValMainId		INT
	)

	CREATE TABLE #TempFoucsProducts
	(
		FBId				INT,		
		PrdCtgValMainId		INT,
		PrdId				INT
	)	
	
	INSERT INTO #TempFoucsBrands(FBRefNo,PrdCtgValMainId)
	SELECT TOP 3 FH.FocusRefNo,FB.PrdCtgValMainId
	FROM FocusBrandHd FH,FocusBrandDt FB
	WHERE FH.FocusRefNo=FB.FocusRefNo AND FH.FromDate=@Pi_FromDate AND FH.ToDate = @Pi_ToDate
	ORDER BY FB.PrdCtgValMainId
	
	INSERT INTO #TempFoucsProducts(FBId,PrdCtgValMainId,PrdId)
	SELECT B.FBId,B.PrdCtgValMainId,E.PrdId
	FROM #TempFoucsBrands B 
	INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
	INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
	INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 	

	SELECT @JcmId=JcmId,@JCMonth=JcmJc FROM JCMonth WHERE @Pi_ToDate BETWEEN JcmSdt AND JcmEdt

	IF @JCMonth>1
	BEGIN
		SELECT @LastFromDate=JcmSdt,@LastToDate=JcmEdt FROM JcMonth WHERE JcmId=@JcmId AND JcmJC=@JCMonth-1
	END
	ELSE
	BEGIN
		SELECT @LastFromDate=JcmSdt,@LastToDate=JcmEdt FROM JcMonth WHERE JcmId=@JcmId-1 AND JcmJC=12
	END
	SELECT @Days=dbo.Fn_GetWorkingDays(@Pi_FromDate,@Pi_ToDate)

	DELETE FROM RptRDSMWorkingEfficiency WHERE RptId=@Pi_RptId AND UserId=@Pi_UsrId
 
	INSERT INTO RptRDSMWorkingEfficiency(SMId,SMCode,SMName,JCMId,JCMJC,DaysSchd,DaysWorked,CallsMade,CallsProductive,LinesTarget,LinesSold,
	ValueTarget,ValueAchieved,FB1Target,FB1Achievement,FB1CallsPrd,FB2Target,FB2Achievement,FB2CallsPrd,FB3Target,FB3Achievement,FB3CallsPrd,
	GeneratedDate,RptId,UserId) 
	SELECT SMId,SMCode,SMName,@JcmId,@JCMonth,@Days,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,GETDATE(),@Pi_RptId,@Pi_UsrId FROM Salesman
	
	--For Worked Days
	UPDATE A SET A.DaysWorked=B.DaysWorked
	FROM RptRDSMWorkingEfficiency A,
	(SELECT A.EmpId AS SMId,COUNT(Mode) AS DaysWorked
	FROM AttendanceRegister A
	WHERE A.TypeId=1 AND Mode=1 AND A.AttendanceDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	GROUP BY A.EmpId
	) AS B
	WHERE A.SMId=B.SMId	

	--For Calls Made
	UPDATE A SET A.CallsMade=B.CallsMade
	FROM RptRDSMWorkingEfficiency A,
	(SELECT RCM.SMId,SUM(RCPSchCalls) AS CallsMade 
	FROM RouteCovPlanMaster RCM,RouteCovPlanDetails RCD
	WHERE RCM.RCPMasterId=RCD.RCPMasterId AND RCD.RcpGeneratedDates 
	BETWEEN @Pi_FromDate AND @Pi_ToDate
	GROUP BY RCM.SMId) AS B
	WHERE A.SMId=B.SMId 

	--For Productive Calls 
	UPDATE A SET A.CallsProductive=B.CallsPrd
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,COUNT(DISTINCT RtrId) AS CallsPrd
	FROM SalesInvoice SI WHERE DlvSts<>3 AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Lines Target
	UPDATE A SET A.LinesTarget=B.LinesTarget
	FROM RptRDSMWorkingEfficiency A,
	(
		SELECT SMId,SUM(LinesTarget) AS LinesTarget 
		FROM
		(
			SELECT SMId,RtrId,COUNT(DISTINCT SIP.PrdID)+COUNT(DISTINCT SIP.PrdID)*.05 AS LinesTarget
			FROM SalesInvoice SI ,SalesInvoiceProduct SIP WHERE DlvSts<>3 	
			AND SI.SalId=SIP.SalId
			AND SalInvDate BETWEEN @LastFromDate AND @LastToDate
			GROUP BY SMId,RtrId
		) AS SM 
		GROUP BY SMId
	) AS B
	WHERE A.SMId=B.SMId
	
	--For Lines Sold
	UPDATE A SET A.LinesSold=B.LinesSold
	FROM RptRDSMWorkingEfficiency A,
	(
		SELECT SMId,SUM(LinesSold) AS LinesSold
		FROM 
		(
			SELECT SMId,RtrId,COUNT(DISTINCT SIP.PrdID)AS LinesSold
			FROM SalesInvoice SI ,SalesInvoiceProduct SIP WHERE DlvSts<>3 	
			AND SI.SalId=SIP.SalId
			AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
			GROUP BY SMId,RtrId
		) AS C
		GROUP BY SMId
	) AS B
	WHERE A.SMId=B.SMId

	--For Value Target
	UPDATE A SET A.ValueTarget=B.ValueTarget
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(SalGrossAmount,0))+SUM(ISNULL(SalGrossAmount,0))*.05 AS ValueTarget
	FROM SalesInvoice SI WHERE DlvSts<>3 	
	AND SalInvDate BETWEEN @LastFromDate AND @LastToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Value Achievement
	UPDATE A SET A.ValueAchieved=B.ValueAchieved
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(SalGrossAmount,0)) AS ValueAchieved
	FROM SalesInvoice SI WHERE DlvSts<>3 	
	AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId	

	--For Focus Brand 1 Target
	UPDATE A SET A.FB1Target=B.FB1Target
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(PrdGrossAmount,0))+SUM(ISNULL(PrdGrossAmount,0))*.05 AS FB1Target
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=1
	AND SalInvDate BETWEEN @LastFromDate AND @LastToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 1 Achievement
	UPDATE A SET A.FB1Achievement=B.FB1Achievement
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(PrdGrossAmount,0)) AS FB1Achievement
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=1
	AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 1 Productive Calls
	UPDATE A SET A.FB1CallsPrd=B.FB1CallsPrd
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,COUNT(DISTINCT SI.RtrId) AS FB1CallsPrd 
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=1
	AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 2 Target
	UPDATE A SET A.FB2Target=B.FB2Target
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(PrdGrossAmount,0))+SUM(ISNULL(PrdGrossAmount,0))*.05 AS FB2Target
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=2
	AND SalInvDate BETWEEN @LastFromDate AND @LastToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 2 Achievement
	UPDATE A SET A.FB2Achievement=B.FB2Achievement
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(PrdGrossAmount,0)) AS FB2Achievement
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=2
	AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 2 Productive Calls
	UPDATE A SET A.FB2CallsPrd=B.FB2CallsPrd
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,COUNT(DISTINCT SI.RtrId) AS FB2CallsPrd 
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=2
	AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 3 Target
	UPDATE A SET A.FB3Target=B.FB3Target
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(PrdGrossAmount,0))+SUM(ISNULL(PrdGrossAmount,0))*.05 AS FB3Target
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=3
	AND SalInvDate BETWEEN @LastFromDate AND @LastToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 3 Achievement
	UPDATE A SET A.FB3Achievement=B.FB3Achievement
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,SUM(ISNULL(PrdGrossAmount,0)) AS FB3Achievement
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=3
	AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	--For Focus Brand 3 Productive Calls
	UPDATE A SET A.FB3CallsPrd=B.FB3CallsPrd
	FROM RptRDSMWorkingEfficiency A,
	(SELECT SMId,COUNT(DISTINCT SI.RtrId) AS FB3CallsPrd 
	FROM SalesInvoice SI,SalesInvoiceProduct SIP,#TempFoucsProducts FP 
	WHERE DlvSts<>3 	
	AND SI.SalId=SIP.SalId AND SIP.PrdID=FP.PrdId AND FP.FBId=3
	AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	GROUP BY SMId) AS B
	WHERE A.SMId=B.SMId

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-180-023

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ReturnQPSRedeemed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ReturnQPSRedeemed]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC PROC_ReturnQPSRedeemed 128,619,296,2,3
SELECT * FROM ReturnedPrdRedeemedForQPS
ROLLBACK TRANSACTION
*/

CREATE PROCEDURE [dbo].[Proc_ReturnQPSRedeemed]
(
	@Pi_SchId       INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId       INT,
	@Pi_TransId		INT
)
/*********************************
* PROCEDURE		: Proc_ReturnQPSRedeemed
* PURPOSE		: To Get the Scheme Redeemed Details for the Selected Scheme
* CREATED		: Boopathy
* CREATED DATE	: 12/06/2007
* NOTE			: General SP for Returning the Scheme Details for the all type of Schemes
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
AS
BEGIN
	DECLARE @SchApplied As Int
	DECLARE @t1 TABLE
	(
		RtrId           Int,
		SchId           Int,
		PrdId			Int,
		PrdBatId		Int,
		SumQty 			Numeric(38,6),
		SumValue 		Numeric(38,6),
		SumInKG			Numeric(38,6),
		SumInLitre		Numeric(38,6),
		UsrId            Int,
		TransId          Int 	
	)

	SET @SchApplied = (Select Count(*) FROM BILLEDPRDREDEEMEDFORQPS WHERE UserId = @Pi_UsrId AND
	TransId = @Pi_TransId AND SchId = @Pi_SchId AND RtrId =@Pi_RtrId)

	Print @SchApplied

	IF @SchApplied > 0
	BEGIN
		INSERT INTO @t1 (RtrId,SchId,PrdId,PrdBatId,SumQty,SumValue,SumInKG,SumInLitre,UsrId,TransId)
		SELECT RtrId,SchId,PrdId,PrdBatId,(SumQty) as SumQty,(SumValue) as SumValue,
		(SumInKG) as SumInKG,(SumInLitre) as SumInLitre,@Pi_UsrId as UsrId,@Pi_TransId as TransId
		FROM SALESINVOICEQPSREDEEMED WHERE SalId=@Pi_SalId AND RtrId =@Pi_RtrId AND SchId = @Pi_SchId
		INSERT INTO @t1 (RtrId,SchId,PrdId,PrdBatId,SumQty,SumValue,SumInKG,SumInLitre,UsrId,TransId)
		SELECT DISTINCT BR.RtrId,BR.SchId,BR.PrdId,BR.PrdBatId,(-1*BR.SumQty) as SumQty,(-1*BR.SumValue) as SumValue,
		(-1*BR.SumInKG) as SumInKG,(-1*BR.SumInLitre) as SumInLitre ,@Pi_UsrId as UsrId,@Pi_TransId as TransId
		FROM BILLEDPRDREDEEMEDFORQPS BR, SALESINVOICEQPSREDEEMED SR
		WHERE BR.SchId = @Pi_SchId AND BR.RtrId =@Pi_RtrId AND BR.PrdId=SR.PrdId and BR.PrdBatId = SR.PrdBatId
		AND BR.SchId=SR.SchId AND BR.RtrId = SR.RtrId AND BR.UserId = @Pi_UsrId AND BR.TransId = @Pi_TransId
	END

	IF @SchApplied = 0
	BEGIN
		INSERT INTO @t1 (RtrId,SchId,PrdId,PrdBatId,SumQty,SumValue,SumInKG,SumInLitre,UsrId,TransId)
		SELECT RtrId,SchId,PrdId,PrdBatId,(-1*SumQty) as SumQty,(-1*SumValue) as SumValue,
		(-1*SumInKG) as SumInKG,(-1*SumInLitre) as SumInLitre,@Pi_UsrId as UsrId,@Pi_TransId as TransId
		FROM SALESINVOICEQPSREDEEMED WHERE SalId=@Pi_SalId AND RtrId =@Pi_RtrId AND SchId = @Pi_SchId
	END

	SELECT RtrId,SchId,PrdId,PrdBatId,SUM(SumQty) as SumQty,SUM(SumValue) as SumValue,
	SUM(SumInKG) as SumInKG,SUM(SumInLitre) as SumInLitre,@Pi_UsrId as UsrId,@Pi_TransId as TransId INTO #T2 FROM @t1
	GROUP BY RtrId,SchId,PrdId,PrdBatId

	INSERT INTO ReturnedPrdRedeemedForQPS (RtrId,SchId,PrdId,PrdBatId,SumQty,SumValue,SumInKG,SumInLitre,UsrId,TransId)
	SELECT * FROM #T2
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-180-024

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptRDSMWorkingEfficiency]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptRDSMWorkingEfficiency]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
Exec [Proc_RptRDSMWorkingEfficiency] 216,2,0,'HKSch20100903',1,0,1,0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_RptRDSMWorkingEfficiency]
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
* PROCEDURE		: Proc_RptRDSMWorkingEfficiency
* PURPOSE		: To get the Salesman Working Efficiency
* CREATED		: Nandakumar R.G
* CREATED DATE	: 25/11/2010
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
	DECLARE @CmpId      AS INT
	DECLARE @SMId		AS INT
	DECLARE @JcmId		AS INT
	DECLARE @JCMonth	AS INT	
	DECLARE @Days		AS INT

	DECLARE @FromDate	AS DATETIME
	DECLARE @ToDate		AS DATETIME

	DECLARE @LastFromDate	AS DATETIME
	DECLARE @LastToDate		AS DATETIME
	--Till Here

	--Assgin Value for the Filter Variable
	SET @CmpId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @JcmId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId))  
	SET @JCMonth = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,13,@Pi_UsrId))  
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))	
	--Till Here
	
	CREATE TABLE #RptRDSMWorkingEfficiency
	(
		SMId			INT,
		SMCode			NVARCHAR(100),
		SMName			NVARCHAR(200),
		JCMId			INT,
		JCMJC			INT,
		DaysSchd		INT,
		DaysWorked		INT,
		CallsMade		INT,
		CallsProductive	INT,
		LinesTarget		INT,
		LinesSold		INT,
		ValueTarget		NUMERIC(38, 6) ,
		ValueAchieved	NUMERIC(38, 6) ,
		FB1Target		NUMERIC(38, 6) ,
		FB1Achievement	NUMERIC(38, 6) ,
		FB1CallsPrd		INT,
		FB2Target		NUMERIC(38, 6) ,
		FB2Achievement	NUMERIC(38, 6) ,
		FB2CallsPrd		INT,
		FB3Target		NUMERIC(38, 6) ,
		FB3Achievement	NUMERIC(38, 6) ,
		FB3CallsPrd		INT,
		GeneratedDate	DATETIME ,
		RptId			INT,
		UserId			INT 
	)

	SET @TblName = 'RptRDSMWorkingEfficiency'

	SET @TblStruct = '  SMId			INT,
						SMCode			NVARCHAR(100),
						SMName			NVARCHAR(200),
						JCMId			INT,
						JCMJC			INT,
						DaysSchd		INT,
						DaysWorked		INT,
						CallsMade		INT,
						CallsProductive	INT,
						LinesTarget		INT,
						LinesSold		INT,
						ValueTarget		NUMERIC(38, 6) ,
						ValueAchieved	NUMERIC(38, 6) ,
						FB1Target		NUMERIC(38, 6) ,
						FB1Achievement	NUMERIC(38, 6) ,
						FB1CallsPrd		INT,
						FB2Target		NUMERIC(38, 6) ,
						FB2Achievement	NUMERIC(38, 6) ,
						FB2CallsPrd		INT,
						FB3Target		NUMERIC(38, 6) ,
						FB3Achievement	NUMERIC(38, 6) ,
						FB3CallsPrd		INT,
						GeneratedDate	DATETIME'
						-- ,
						--RptId			INT,
						--UserId			INT'

	SET @TblFields = 'SMId,SMCode,SMName,JCMId,JCMJC,DaysSchd,DaysWorked,CallsMade,CallsProductive,LinesTarget,LinesSold,
	ValueTarget,ValueAchieved,FB1Target,FB1Achievement,FB1CallsPrd,FB2Target,FB2Achievement,FB2CallsPrd,
	FB3Target,FB3Achievement,FB3CallsPrd,GeneratedDate,RptId,UserId'

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

	EXEC Proc_RDSMWorkingEfficiency @Pi_RptId,@Pi_UsrId


	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data
	BEGIN
		INSERT INTO #RptRDSMWorkingEfficiency (SMId,SMCode,SMName,JCMId,JCMJC,DaysSchd,DaysWorked,CallsMade,CallsProductive,LinesTarget,LinesSold,
		ValueTarget,ValueAchieved,FB1Target,FB1Achievement,FB1CallsPrd,FB2Target,FB2Achievement,FB2CallsPrd,
		FB3Target,FB3Achievement,FB3CallsPrd,GeneratedDate,RptId,UserId)
		SELECT SMId,SMCode,SMName,JCMId,JCMJC,DaysSchd,DaysWorked,CallsMade,CallsProductive,LinesTarget,LinesSold,
		dbo.Fn_ConvertCurrency(ValueTarget,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(ValueAchieved,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(FB1Target,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(FB1Achievement,@Pi_CurrencyId),FB1CallsPrd,
		dbo.Fn_ConvertCurrency(FB2Target,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(FB2Achievement,@Pi_CurrencyId),FB2CallsPrd,
		dbo.Fn_ConvertCurrency(FB3Target,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(FB3Achievement,@Pi_CurrencyId),FB3CallsPrd,GeneratedDate,RptId,UserId
		FROM RptRDSMWorkingEfficiency
		WHERE UserId=@Pi_UsrId AND RptId=@Pi_RptId		

		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptRDSMWorkingEfficiency ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
			+' WHERE UserId='+CAST(@Pi_UsrId AS NVARCHAR(10))+' AND RptId='+CAST(@Pi_RptId AS NVARCHAR(10))+
			''
			EXEC (@SSQL)
			
			PRINT 'Retrived Data From Purged Table'
		END
		IF @Pi_SnapRequired = 1
		BEGIN
			SELECT @NewSnapId = @Pi_SnapId
			EXEC Proc_SnapShot_Report @NewSnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
			@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
			SET @sSql = 'INSERT INTO [' + @DBNAME + '].dbo.' + @TblName +
			--'(SnapId,UserId,RptId,' + @TblFields + ')' +
			'(SnapId,' + @TblFields + ')' +
			' SELECT ' + CAST(@NewSnapId AS VARCHAR(10)) +
--			' ,' + CAST(@Pi_UsrId AS VARCHAR(10)) +
--			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + 
			', * FROM #RptRDSMWorkingEfficiency'
			
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
			SET @SSQL = 'INSERT INTO #RptRDSMWorkingEfficiency ' +
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
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptRDSMWorkingEfficiency
	PRINT 'Data Executed'

	SELECT * FROM #RptRDSMWorkingEfficiency

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-180-025

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_UpdateFBMSchemeBudget]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_UpdateFBMSchemeBudget]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_UpdateFBMSchemeBudget 45,'SCH1000157',157,'2010-10-09',2,0
--SELECT * FROM FBMTrackIn WHERE PrdId=272
SELECT * FROM FBMSchDetails WHERE SchId=157
SELECT Budget,* FROM SchemeMaster WHERE SchId=157
ROLLBACK TRANSACTION
*/

CREATE	PROCEDURE [dbo].[Proc_UpdateFBMSchemeBudget]
(
	@Pi_TransId		INT,
	@Pi_TransRefNo	NVARCHAR(50),
	@Pi_TransRefId	INT,
	@Pi_TransDate	DATETIME,
	@Pi_UserId		INT,
	@Po_ErrNo		INT		OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_UpdateFBMSchemeBudget
* PURPOSE		: To Track FBM(Free Bonus Merchandise)
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 16/04/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
	IF @Pi_TransId=2 OR @Pi_TransId=7
	BEGIN
		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackOut F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					
		UNION
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackOut G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId										

		--->Added By Nanda on 08/10/2010 For PRN 
		IF @Pi_TransId=7
		BEGIN
			UPDATE S SET S.Budget=S.Budget-A.DiscAmt		
			FROM SchemeMaster S,
			(
				SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId =@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
				GROUP BY SchId
			) A
			WHERE S.FBM=1 AND S.SchId=A.SchId
			AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill AND SchStatus=1
		END
		--->Till Here
	END
	IF @Pi_TransId=3 OR @Pi_TransId=5 OR @Pi_TransId=45
	BEGIN
		
		IF @Pi_TransId=45
		BEGIN
			DELETE FROM FBMSchDetails WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			DELETE FROM FBMSchDetails WHERE SchId=@Pi_TransRefId
			INSERT INTO FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
			Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT TransId,TransRefId,TransRefNo,FBMDate,SchId,0,PrdId,DiscAmtOut,1,1,GETDATE(),1,GETDATE()
			FROM FBMTrackIn WHERE TransId=@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
			UPDATE S SET S.Budget=A.DiscAmt
			FROM SchemeMaster S,
			(
				SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
				FROM
				(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId = @Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
				GROUP BY SchId
				) AA LEFT OUTER JOIN
				(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId IN (0)
				GROUP BY SchId
				) BB ON AA.SchId=BB.SChId			
			) A
			WHERE S.FBM=1 AND S.SchId=A.SchId 
			AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill AND SchStatus=1
		END
		ELSE
		BEGIN
			INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
			Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,F.DiscAmtOut,
			1,1,GETDATE(),1,GETDATE()
			FROM SchemeMaster A
			INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
			INNER JOIN Product C On B.Prdid = C.PrdId 
			INNER JOIN FBMTrackIn F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
			AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					
			UNION
			SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,G.DiscAmtOut,
			1,1,GETDATE(),1,GETDATE()
			FROM SchemeMaster A
			INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
			INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
			INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
			INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
			INNER JOIN ProductBatch F On F.PrdId = E.Prdid
			INNER JOIN FBMTrackIn G ON E.PrdId=G.PrdId AND TransId=@Pi_TransId 
			AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
						
			--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
			UPDATE S SET S.Budget=A.DiscAmt
			FROM SchemeMaster S,
			(
				SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
				FROM
				(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId IN (3,5,45,255) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
				GROUP BY SchId
				) AA LEFT OUTER JOIN
				(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
				WHERE TransId IN (7) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
				GROUP BY SchId
				) BB ON AA.SchId=BB.SChId			
			) A
			WHERE S.FBM=1 AND S.SchId=A.SchId 
			AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill AND SchStatus=1
		END
	END
	IF @Pi_TransId=255
	BEGIN
		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,-1*F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackOut F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					
		UNION
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,-1*G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackOut G ON B.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId										
		INSERT FBMSchDetails(TransId,TransRefId,TransRefNo,TransDate,SchId,ActualSchId,PrdId,DiscAmt,
		Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,F.FBMDate,A.SchId,F.SchId,B.PrdId,F.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN Product C On B.Prdid = C.PrdId 
		INNER JOIN FBMTrackIn F ON B.PrdId=F.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId					
		UNION
		SELECT DISTINCT @Pi_TransId,@Pi_TransRefId,@Pi_TransRefNo,G.FBMDate,A.SchId,G.SchId,B.PrdId,G.DiscAmtOut,
		1,1,GETDATE(),1,GETDATE()
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.SchId = B.SchId AND A.FBM=1
		INNER JOIN ProductCategoryValue C ON B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On F.PrdId = E.Prdid
		INNER JOIN FBMTrackIn G ON B.PrdId=G.PrdId AND TransId=@Pi_TransId 
		AND TransRefNo=@Pi_TransRefNo AND TransRefId=@Pi_TransRefId		
		--UPDATE S SET S.Budget=S.Budget+A.DiscAmt
		UPDATE S SET S.Budget=A.DiscAmt
		FROM SchemeMaster S,
		(
			SELECT AA.SchId,(AA.DiscAmt-ISNULL(BB.DiscAmt,0)) AS DiscAmt
			FROM
			(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
			WHERE TransId IN (3,5,45,255) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			GROUP BY SchId
			) AA LEFT OUTER JOIN
			(SELECT SchId,SUM(DiscAmt) AS DiscAmt FROM FBMSchDetails 
			WHERE TransId IN (7) --@Pi_TransId AND TransRefId=@Pi_TransRefId AND TransRefNo=@Pi_TransRefNo
			GROUP BY SchId
			) BB ON AA.SchId=BB.SChId			
		) A
		WHERE S.FBM=1 AND S.SchId=A.SchId 
		AND CONVERT(NVARCHAR(10),GETDATE(),121) BETWEEN SchValidFrom AND SchValidTill AND SchStatus=1
	END
	
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-180-026

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ValidateGeographyHierarchyLevelValue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ValidateGeographyHierarchyLevelValue]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
SELECT * FROM ETL_Prk_GeographyHierarchyLevelValue
Exec Proc_ValidateGeographyHierarchyLevelValue 0
SELECT * FROM Geography
ROLLBACK TRANSACTION
*/

CREATE          Procedure [dbo].[Proc_ValidateGeographyHierarchyLevelValue]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_ValidateGeographyHierarchyLevelValue
* PURPOSE		: To Insert and Update records in the Table GeographyCategoryValue
* CREATED		: Nandakumar R.G
* CREATED DATE	: 17/09/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*	{date}		{developer}		{brief modification description}
* 15/10/2010	Nandakumar R.G	Addition of Population field
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @Exist 		AS 	INT
	DECLARE @Tabname 	AS     	NVARCHAR(100)
	DECLARE @DestTabname 	AS 	NVARCHAR(100)
	DECLARE @Fldname 	AS     	NVARCHAR(100)
	
	DECLARE @GeoHierLevelCode 		AS  NVARCHAR(100)
	DECLARE @ParentHierLevelCode 	AS  NVARCHAR(100)
	DECLARE @GeoHierLevelValueCode 	AS  NVARCHAR(100)
	DECLARE @GeoHierLevelValueName 	AS  NVARCHAR(100)
	DECLARE @ParentLinkCode			AS 	NVARCHAR(100)
	DECLARE @NewLinkCode 			AS 	NVARCHAR(100)
	DECLARE @LevelName 				AS 	NVARCHAR(100)
	DECLARE @Population				AS 	NUMERIC(38,6)
	
	DECLARE @GeoLevelId 	AS 	INT
	DECLARE @GeoMainId 	AS 	INT
	DECLARE @GeoLinkId 	AS 	INT
	DECLARE @GeoLinkCode 	AS 	NVARCHAR(100)
	DECLARE @TransStr 	AS 	NVARCHAR(4000)
	SET @Po_ErrNo=0
	SET @Exist=0
	
	SET @DestTabname='Geography'
	SET @Fldname='GeoMainId'
	SET @Tabname = 'ETL_Prk_GeographyHierarchyLevelValue'
	SET @Exist=0
	
	DECLARE Cur_GeographyHierarchyLevelValue CURSOR
	FOR SELECT ISNULL([Geography Hierarchy Level Code],''),ISNULL([Parent Hierarchy Level Value Code],''),
	ISNULL([Geography Hierarchy Level Value Code],''),ISNULL([Geography Hierarchy Level Value Name],''),ISNULL([Population],0)
	FROM ETL_Prk_GeographyHierarchyLevelValue ETL,GEographyLevel GL
	WHERE ETL.[Geography Hierarchy Level Code]=GL.GeoLevelName 
	ORDER BY GL.LevelName
	OPEN Cur_GeographyHierarchyLevelValue
	FETCH NEXT FROM Cur_GeographyHierarchyLevelValue INTO @GeoHierLevelCode,@ParentHierLevelCode,
	@GeoHierLevelValueCode,@GeoHierLevelValueName,@Population
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Exist=0
		IF NOT EXISTS(SELECT * FROM GeographyLevel WITH (NOLOCK) WHERE GeoLevelName=@GeoHierLevelCode)
		BEGIN
			INSERT INTO Errorlog VALUES (1,@Tabname,'Geography Level',
			'Geography Level:'+@GeoHierLevelCode+' is not available')
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @GeoLevelId=GeoLevelId,@LevelName=LevelName FROM GeographyLevel WITH (NOLOCK)
			WHERE GeoLevelName=@GeoHierLevelCode
		END
		
		IF @Po_ErrNo=0
		BEGIN
			IF NOT EXISTS(SELECT * FROM Geography WITH (NOLOCK) WHERE GeoCode=@ParentHierLevelCode)
			AND @ParentHierLevelCode<>'GeoFirstLevel'
			BEGIN
				INSERT INTO Errorlog VALUES (1,@Tabname,'Parent Geography Level',
				'Parent Geography Level:'+@ParentHierLevelCode+' is not available')
				SET @Po_ErrNo=1
			END
			ELSE
			BEGIN
				SELECT @GeoLinkId=ISNULL(GeoMainId,0) FROM Geography WITH (NOLOCK)
				WHERE GeoCode=@ParentHierLevelCode
				SET @GeoLinkId=ISNULL(@GeoLinkId,0)
			END
		END	
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@GeoHierLevelValueCode))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Geography Hierarvhy Level Value Code',
				'Geography Hierarvhy Level Value Code should not be empty')
				SET @Po_ErrNo=1
			END
		END
	
		IF @Po_ErrNo=0
		BEGIN
			IF LTRIM(RTRIM(@GeoHierLevelValueName))=''
			BEGIN
				INSERT INTO Errorlog VALUES (1,@TabName,'Geography Hierarvhy Level Value Name',
				'Geography Hierarvhy Level Value Name should not be empty')
				SET @Po_ErrNo=1
			END
		END		
		
		IF @Po_ErrNo=0
		BEGIN
			IF EXISTS(SELECT * FROM Geography WITH (NOLOCK) WHERE GeoCode=@GeoHierLevelValueCode)
			BEGIN
				SET @Exist=1
				SELECT @GeoMainId=GeoMainId FROM Geography WITH (NOLOCK) WHERE GeoCode=@GeoHierLevelValueCode
				
			END
		
			IF @Exist=0
			BEGIN
				SELECT @GeoMainId=dbo.Fn_GetPrimaryKeyInteger(@DestTabname,@FldName,
				CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			
				IF @LevelName='Level1'			
				BEGIN
					SET @GeoLinkId=0
	
					SELECT @GeoLevelId=GeoLevelId FROM GeographyLevel WITH (NOLOCK)
					WHERE  GeoLevelName=@GeoHierLevelCode
		
					SELECT @ParentLinkCode='00'+CAST(@GeoLevelId AS NVARCHAR(100))
				END
				ELSE
				BEGIN
					SELECT 	@ParentLinkCode=GeoLinkCode FROM Geography
					WHERE GeoMainId=@GeoLinkId
				END
				SELECT @NewLinkCode=ISNULL(MAX(GeoLinkCode),0)
				FROM Geography WHERE LEN(GeoLinkCode)=  Len(@ParentLinkCode)+3
				AND GeoLinkCode LIKE  @ParentLinkCode +'%' AND GeoLevelId =@GeoLevelId
				SELECT 	@GeoLinkCode=dbo.Fn_ReturnNewCode(@ParentLinkCode,3,@NewLinkCode)
				IF LEN(@GeoLinkCode)<>(SUBSTRING(@LevelName,6,LEN(@LevelName))+1)*3
				BEGIN
					INSERT INTO Errorlog VALUES (1,@TabName,'Geography Hierarvhy Level Value',
					'Geography Hierarvhy Level is not match with parent level for: '+@GeoHierLevelValueCode)
	
					SET @Po_ErrNo=1
				END
				
				IF @Po_ErrNo=0
				BEGIN
					INSERT INTO Geography(GeoMainId,GeoLinkId,GeoLevelId,GeoLinkCode,GeoCode,GeoName,[Population],
					Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@GeoMainId,@GeoLinkId,@GeoLevelId,@GeoLinkCode,
					@GeoHierLevelValueCode,@GeoHierLevelValueName,@Population,
					1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121)) 			
				
	
					SET @TransStr='INSERT INTO Geography
					(GeoMainId,GeoLinkId,GeoLevelId,GeoLinkCode,GeoCode,GeoName,[Population],
					Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES('+CAST(@GeoMainId AS NVARCHAR(10))+','+
					CAST(@GeoLinkId AS NVARCHAR(10))+','+CAST(@GeoLevelId AS NVARCHAR(10))+','''+@GeoLinkCode+''','''
					+@GeoHierLevelValueCode+''','''+@GeoHierLevelValueName+''+CAST(@Population AS NVARCHAR(100))+
					',1,1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',1,'''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
	
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
	
					UPDATE Counters SET CurrValue=@GeoMainId WHERE TabName=@DestTabname AND FldName=@FldName
	
					SET @TransStr='UPDATE Counters SET CurrValue='+CAST(@GeoMainId AS NVARCHAR(10))+
					' WHERE TabName='''+@DestTabname+''' AND FldName='''+@FldName+''''
	
					INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
				END
			END	
			ELSE
			BEGIN
				UPDATE Geography SET GeoName=@GeoHierLevelValueName
				WHERE GeoMainId=@GeoMainId
				SET @TransStr='UPDATE Geography SET GeoName='''+@GeoHierLevelValueName+
				''' WHERE GeoMainId='+CAST(@GeoMainId AS NVARCHAR(10))
				INSERT INTO TransLog(StrSql1) VALUES(@TransStr)
			END	
		END	
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_GeographyHierarchyLevelValue
			DEALLOCATE Cur_GeographyHierarchyLevelValue
			RETURN
		END		
			
		FETCH NEXT FROM Cur_GeographyHierarchyLevelValue INTO @GeoHierLevelCode,@ParentHierLevelCode,
		@GeoHierLevelValueCode,@GeoHierLevelValueName,@Population
	END
	CLOSE Cur_GeographyHierarchyLevelValue
	DEALLOCATE Cur_GeographyHierarchyLevelValue
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-180-027

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_RDSMWorkingEfficiency]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_RDSMWorkingEfficiency]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
UPDATE DayEndProcess Set NextUpDate = '2010-11-20' Where ProcId = 14
EXEC Proc_Cs2Cn_RDSMWorkingEfficiency 0
SELECT * FROM Cs2Cn_Prk_RDSMWorkingEfficiency
ROLLBACK TRANSACTION
*/

CREATE          PROCEDURE [dbo].[Proc_Cs2Cn_RDSMWorkingEfficiency]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_RDSMWorkingEfficiency
* PURPOSE		: To Extract the Salesman Working Efficiency Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 26/11/2010
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @DistCode	As	nVarchar(50)
	DECLARE @ChkDate	AS	DATETIME
	DECLARE @PrdId		AS	INT
	DECLARE @TransDate	AS	DATETIME
	DECLARE @FromDate	AS	DATETIME

	SET @Po_ErrNo=0

	DELETE FROM Cs2Cn_Prk_RDSMWorkingEfficiency WHERE UploadFlag = 'Y'

	SELECT @DistCode = DistributorCode FROM Distributor

	SELECT @ChkDate = NextUpDate FROM DayEndProcess	Where ProcId = 14
	SELECT @TransDate=DATEADD(D,-1,GETDATE())

	WHILE @ChkDate<=@TransDate
	BEGIN
		SELECT @FromDate=dbo.Fn_GetFirstDayOfMonth(@ChkDate)

		DELETE FROM RptRDSMWorkingEfficiency WHERE RptId=1000 AND UserId=1 
		
		EXEC Proc_RDSMWorkingEfficiencyForUpload 1000,1,@FromDate,@ChkDate
		
		INSERT INTO Cs2Cn_Prk_RDSMWorkingEfficiency(DistCode,DataYear,DataMonth,AsOnDate,SMId,SMCode,SMName,DaysSchd,DaysWorked,CallsMade,CallsProductive,
		LinesTarget,LinesSold,ValueTarget,ValueAchieved,FB1Target,FB1Achievement,FB1CallsPrd,FB2Target,FB2Achievement,FB2CallsPrd,FB3Target,FB3Achievement,
		FB3CallsPrd,GeneratedDate,UploadFlag)
		SELECT @DistCode,YEAR(@ChkDate),MONTH(@ChkDate),@ChkDate,SMId,SMCode,SMName,DaysSchd,DaysWorked,CallsMade,CallsProductive,
		LinesTarget,LinesSold,ValueTarget,ValueAchieved,FB1Target,FB1Achievement,FB1CallsPrd,FB2Target,FB2Achievement,FB2CallsPrd,FB3Target,FB3Achievement,
		FB3CallsPrd,GeneratedDate,'N'
		FROM RptRDSMWorkingEfficiency WHERE UserId=1 AND RptId=1000			
				
		SET @ChkDate=DATEADD(D,1,@ChkDate)		
	END
	
	UPDATE DayEndProcess SET NextUpDate = CONVERT(nVarChar(10),GETDATE(),121),
	ProcDate = CONVERT(nVarChar(10),GetDate(),121)
	WHERE ProcId = 14
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-180-028

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ExportSchemeAttributes]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ExportSchemeAttributes]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     FUNCTION [dbo].[Fn_ExportSchemeAttributes] ()
RETURNS nVarchar(4000)
AS
/*********************************
* FUNCTION: Fn_ExportSchemeAttributes
* PURPOSE: Return Scheme Attributes query for export
* NOTES:
* CREATED: Boopathy.P 01-02-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*
*********************************/
BEGIN
	Declare @sSql nVarchar(4000)
	Set @sSql  = 'SELECT Final.* into #Temp FROM (SELECT B.CmpSchCode AS [Company Scheme Code],
				CASE A.AttrType WHEN 1 THEN ''SALESMAN'' WHEN 2 THEN ''ROUTE'' WHEN 3 THEN ''VILLAGE''
				WHEN 4 THEN ''CATEGORY LEVEL'' WHEN 5 THEN ''CATEGORY LEVEL VALUE'' WHEN 6 THEN ''VALUECLASS''
				WHEN 7 THEN ''POTENTIALCLASS'' WHEN 8 THEN ''RETAILER'' WHEN 9 THEN ''PRODUCT''
				WHEN 10 THEN ''BILL TYPE'' WHEN 11 THEN ''BILL MODE'' WHEN 12 THEN ''RETAILER TYPE''
				WHEN 13 THEN ''CLASS TYPE'' WHEN 14 THEN ''ROAD CONDITION'' WHEN 15 THEN ''INCOME LEVEL''
				WHEN 16 THEN ''ACCEPTABILITY'' WHEN 17 THEN ''AWARENESS'' WHEN 18 THEN ''ROUTE TYPE''
				WHEN 19 THEN ''LOCALUPCOUNTRY'' WHEN 20 THEN ''VAN/NON VAN ROUTE'' 
				WHEN 21 THEN ''CLUSTER'' END AS [Attribute Type],
				CASE A.AttrType
				WHEN 1 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' ELSE C.SMCode END
				WHEN 2 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' ELSE D.RMCode END
				WHEN 3 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' ELSE E.VILLAGECODE END
				WHEN 4 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' ELSE F.CtgLevelName END
				WHEN 5 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' ELSE G.CtgCode END
				WHEN 6 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' ELSE H.ValueClassCode END
				WHEN 7 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' ELSE I.PotentialClassCode END
				WHEN 8 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' ELSE J.RtrCode END
				WHEN 9 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' ELSE K.PrdDCode END
				WHEN 10 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' WHEN 1 THEN ''ORDER BOOKING''
					WHEN 2 THEN ''READY STOCK'' WHEN 3 THEN ''VAN SALES'' END
				WHEN 11 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' WHEN 1 THEN ''CASH'' WHEN 2 THEN ''CREDIT'' END
				WHEN 12 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' WHEN 1 THEN ''KEY OUTLET'' WHEN 2 THEN ''NON-KEY OUTLET'' END 	
				WHEN 13 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' WHEN 1 THEN ''VALUE CLASSIFICATION'' WHEN 2 THEN ''POTENTIAL CLASSIFICATION'' END 	
				WHEN 14 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' WHEN 1 THEN ''GOOD'' WHEN 2 THEN ''ABOVE AVERAGE''
					WHEN 3 THEN ''AVERAGE'' WHEN 4 THEN ''BELOW AVERAGE'' WHEN 5 THEN ''POOR'' END
				WHEN 15 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' WHEN 1 THEN ''GOOD'' WHEN 2 THEN ''ABOVE AVERAGE''
					WHEN 3 THEN ''AVERAGE'' WHEN 4 THEN ''BELOW AVERAGE'' WHEN 5 THEN ''POOR'' END
				WHEN 16 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' WHEN 1 THEN ''GOOD'' WHEN 2 THEN ''ABOVE AVERAGE''
					WHEN 3 THEN ''AVERAGE'' WHEN 4 THEN ''BELOW AVERAGE'' WHEN 5 THEN ''POOR'' END
				WHEN 17 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' WHEN 1 THEN ''GOOD'' WHEN 2 THEN ''ABOVE AVERAGE''
					WHEN 3 THEN ''AVERAGE'' WHEN 4 THEN ''BELOW AVERAGE'' WHEN 5 THEN ''POOR'' END
				WHEN 18 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' WHEN 1 THEN ''SALES ROUTE''
					WHEN 2 THEN ''DELIVERY ROUTE'' WHEN 3 THEN ''MERCHANDISING ROUTE'' END
				WHEN 19 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' WHEN 1 THEN ''LOCAL ROUTE''
					WHEN 2 THEN ''UPCOUNTRY ROUTE'' END
				WHEN 20 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' WHEN 1 THEN ''VAN ROUTE''
					WHEN 2 THEN ''NON VAN ROUTE'' END 
				WHEN 21 THEN CASE A.AttrId WHEN 0 THEN ''ALL'' ELSE L.ClusterCode END END
				AS [Attribute Master Code]
				FROM SchemeRetAttr A INNER JOIN SchemeMaster B ON A.SchId=B.SchId
				LEFT OUTER JOIN SalesMan C ON A.AttrId=C.SMId
				LEFT OUTER JOIN RouteMaster D ON A.AttrId=D.RMId
				LEFT OUTER JOIN RouteVillage E ON A.AttrId=E.VillageId
				LEFT OUTER JOIN RetailerCategoryLevel F ON A.AttrId=F.CtgLevelId
				LEFT OUTER JOIN RetailerCategory G ON A.AttrId=G.CtgMainId
				LEFT OUTER JOIN RetailerValueClass H ON A.AttrId=H.RtrClassId
				LEFT OUTER JOIN RetailerPotentialClass I ON A.AttrId=I.RtrClassId
				LEFT OUTER JOIN Retailer J ON A.AttrId=J.RtrId
				LEFT OUTER JOIN Product K ON A.AttrId=K.PrdId
				LEFT OUTER JOIN ClusterMaster L ON A.AttrId=L.ClusterId
			) Final
	SELECT * FROM #Temp'
	Return (@sSql)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-180-029

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ExportSchemeMaster]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ExportSchemeMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     FUNCTION [dbo].[Fn_ExportSchemeMaster] ()
RETURNS nVarchar(4000)
AS
/*********************************
* FUNCTION: Fn_ExportSchemeMaster
* PURPOSE: Return Scheme Master query for export
* NOTES:
* CREATED: Boopathy.P 31-01-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*
*********************************/
BEGIN
	Declare @sSql nVarchar(4000)
	Set @sSql  = 'SELECT Final.* into #Temp FROM (SELECT A.CmpSchCode AS [Company Scheme Code],A.SchDsc AS [Scheme Description],
				B.CmpCode AS [Company Code],CASE A.Claimable WHEN 1 THEN ''YES'' WHEN 0 THEN ''NO''
				END AS [Claimable],CASE A.ClmAmton WHEN 1 THEN ''PURCHASE RATE'' WHEN 2 THEN ''SELLING RATE''
				END AS [Claim Amount On],CASE WHEN A.ClmRefId > 0 THEN C.ClmGrpCode ELSE '''' END
				AS [Claim Group Code],CASE A.SchemeLvlMode WHEN 0 THEN ''PRODUCT'' WHEN 1 THEN ''UDC'' END
				AS [Selection On],D.CmpPrdCtgName AS [Selection Level Value],CASE A.SchType
				WHEN 1 THEN ''QUANTITY'' WHEN 2 THEN ''AMOUNT'' WHEN 3 THEN ''WEIGHT'' WHEN 4 THEN
				''WINDOW DISPLAY'' END AS [Scheme Type],CASE A.BatchLevel WHEN 1 THEN ''YES''
				WHEN 0 THEN ''NO'' END AS [Batch Level],CASE A.FlexiSch WHEN 1 THEN ''YES''
				WHEN 0 THEN ''NO'' END AS [Flexi Scheme],CASE A.FlexiSchType WHEN 2 THEN ''UNCONDITIONAL''
				WHEN 1 THEN ''CONDITIONAL'' END AS [Flexi Conditional],CASE A.CombiSch WHEN 1 THEN ''YES''
				WHEN 0 THEN ''NO'' END AS [Combi Scheme],CASE A.Range WHEN 0 THEN ''NO'' WHEN 1 THEN ''YES''
				END AS [Range],CASE A.ProRata WHEN 0 THEN ''NO'' WHEN 1 THEN ''YES'' WHEN 2 THEN ''ACTUAL''
				END AS [Pro - Rata],CASE A.Qps WHEN 0 THEN ''NO'' WHEN 1 THEN ''YES'' END AS [QPS],
				CASE A.QpsReset WHEN 0 THEN ''NO'' WHEN 1 THEN ''YES'' END AS [Qps Reset],
				CASE A.ApyQPSSch WHEN 2 THEN ''QUANTITY'' ELSE ''DATE'' END AS [Qps Based On],
				CASE A.PurofEvery WHEN 0 THEN ''NO'' WHEN 1 THEN ''YES'' END AS [Allow For Every],
				A.SchValidFrom AS [Scheme Start Date],A.SchValidTill AS [Scheme End Date],A.Budget AS [Scheme Budget],
				CASE A.EditScheme WHEN 0 THEN ''NO'' WHEN 1 THEN ''YES'' END AS [Allow Editing Scheme],
				CASE A.AdjWinDispOnlyOnce WHEN 0 THEN ''NO'' WHEN 1 THEN ''YES'' END AS [Adjust Display Once],
				CASE A.SetWindowDisp WHEN 1 THEN ''CASH'' WHEN 2 THEN ''CHEQUE'' END AS [Settle Display Through],A.BudgetAllocationNo AS [BudgetAllocationNo]
				FROM SchemeMaster A INNER JOIN Company B ON A.CmpId=B.CmpId
				LEFT OUTER JOIN ClaimGroupMaster C ON A.ClmRefId=C.ClmGrpId
				INNER JOIN ProductCategoryLevel D ON A.SchLevelId=D.CmpPrdCtgId AND A.MasterType=1) Final
				SELECT * FROM #Temp'
	Return (@sSql)
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-180-030

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ValidateSchemeMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ValidateSchemeMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_ValidateSchemeMaster 0
ROLLBACK TRANSACTION
*/

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
									convert(varchar(10),getdate(),121),@EditSchId,@SelMode,1,2,1,'',0,0,0,1,0,0)
					
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
								PurofEvery,ApyQPSSch,SetWindowDisp,EditScheme,SchemeLvlMode,UpLoadFlag,BudgetAllocationNo,SchBasedOn,Download) VALUES
								(LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
								@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
								@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),1,@SchBudget,@AdjustSchId,@ForEveryId,
								@ApplySchId,@SettleSchId,@EditSchId,@SelMode,'N','',1,0)
				
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
					--END						
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


--SRF-Nanda-180-031

EXEC Sp_Rename 'PaswordHistory','CSDetails'

if not exists (select * from hotfixlog where fixid = 350)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(350,'D','2010-12-07',getdate(),1,'Core Stocky Service Pack 350')