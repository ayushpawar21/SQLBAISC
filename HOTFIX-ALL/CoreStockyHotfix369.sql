--[Stocky HotFix Version]=369
Delete from Versioncontrol where Hotfixid='369'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('369','2.0.0.5','D','2011-03-31','2011-03-31','2011-03-31',convert(varchar(11),getdate()),'Parle;Major:-Akso Nobel and Henkel CRs;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 369' ,'369'
GO

--SRF-Nanda-222-001

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ComputeTaxForSupplier]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ComputeTaxForSupplier]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[Proc_ComputeTaxForSupplier]
(  
 @Pi_RowId  INT,  
 @Pi_CalledFrom  INT,    
 @Pi_UserId  INT  
)  
AS  
/*********************************  
* PROCEDURE : Proc_ComputeTaxForSupplier  
* PURPOSE : To Calculate the Tax (For Selling Rate Recalculation)  
* CREATED : Nandakumar R.G  
* CREATED DATE : 22/03/2007  
* MODIFIED   
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
* {date} {developer}  {brief modification description}        
@Pi_CalledFrom  2  For Sales  
*********************************/   
SET NOCOUNT ON  
BEGIN  
DECLARE @PrdBatTaxGrp   INT  
DECLARE @RtrTaxGrp   INT  
DECLARE @TaxSlab  INT  
DECLARE @SellingRate  NUMERIC(28,10)  
DECLARE @PurchaseRate  NUMERIC(28,10)  
DECLARE @TaxableAmount  NUMERIC(28,10)  
DECLARE @ParTaxableAmount NUMERIC(28,10)  
DECLARE @TaxPer   NUMERIC(38,6)  
DECLARE @TaxId   INT  
DECLARE @TaxSetting TABLE   
(  
 TaxSlab   INT,  
 ColNo   INT,  
 SlNo   INT,  
 BillSeqId  INT,  
 TaxSeqId  INT,  
 ColType   INT,   
 ColId   INT,  
 ColVal   NUMERIC(38,6)  
)  
 --To Take the Batch TaxGroup Id  
 SELECT @PrdBatTaxGrp = TaxGroupId FROM ProductBatch A (NOLOCK) INNER JOIN  
  BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID  
  AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom  
 --To Take the Batch Selling Rate  
 SELECT @SellingRate = 100  
 --To Take the Supplier TaxGroup Id  
SELECT @RtrTaxGrp = TaxGroupId FROM Supplier A (NOLOCK) INNER JOIN
BilledPrdHdForTax B (NOLOCK) On A.SpmId = B.RtrId
AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId
AND B.TransId = @Pi_CalledFrom
 --Store the Tax Setting for the Corresponding Retailer and Batch  
 INSERT INTO @TaxSetting (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)  
 SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal  
  FROM TaxSettingMaster A (NOLOCK) INNER JOIN  
  TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId  
  INNER JOIN BilledPrdHdForTax C (NOLOCK) ON C.BillSeqId = B.BillSeqId  
  WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp AND C.UsrId = @Pi_UserId  
  AND C.RowId = @Pi_RowId AND C.TransId = @Pi_CalledFrom  
  AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE  
   RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp)  
SELECT * FROm @TaxSetting
 --Delete the OLD Details From the BilledPrdDtCalculatedTax For the Row and User  
 DELETE FROM BilledPrdDtCalculatedTax WHERE RowId = @Pi_RowId AND UsrId = @Pi_UserId   
  AND TransId = @Pi_CalledFrom  
  --Cursor For Taking Each Slab and Calculate Tax  
 DECLARE  CurTax CURSOR FOR  
 SELECT DISTINCT TaxSlab FROM @TaxSetting  
  OPEN CurTax    
  FETCH NEXT FROM CurTax INTO @TaxSlab  
 WHILE @@FETCH_STATUS = 0    
 BEGIN  
  SET @TaxableAmount = 0  
  --To Filter the Records Which Has Tax Percentage (>=0)  
  IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1  
   AND ColId = 0 and ColVal >= 0)  
  BEGIN  
   --To Get the Tax Percentage for the selected slab  
   SELECT @TaxPer = ColVal FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1  
    AND ColId = 0  
   --To Get the TaxId for the selected slab  
   SELECT @TaxId = Cast(ColVal as INT) FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1  
    AND ColId > 0  
   --SELECT @TaxableAmount = 100  
	--To add MRP to Taxable Amount if MRP Is Selected for the Slab
	IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 2
	AND ColId = 1 and ColVal > 0)
	SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @SellingRate
	--To add Selling Rate to Taxable Amount if Selling Rate Is Selected for the Slab
	IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 2
	AND ColId = 2 and ColVal > 0)
	SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @SellingRate
	--To add Purchase Rate to Taxable Amount if Purchase Rate Is Selected for the Slab
	IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 2
	AND ColId = 3 and ColVal > 0)
	SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @SellingRate
   --To Get the Parent Taxable Amount for the Tax Slab  
   SELECT @ParTaxableAmount =  ISNULL(SUM(TaxAmount),0) FROM BilledPrdDtCalculatedTax A  
   INNER JOIN @TaxSetting B ON A.TaxId = B.ColVal AND A.RowId = @Pi_RowId  
   AND A.UsrId = @Pi_UserId AND B.ColType = 3 AND B.TaxSlab = @TaxSlab  
   AND A.TransId = @Pi_CalledFrom  
   Set @TaxableAmount = @TaxableAmount + @ParTaxableAmount  
   PRINT @TaxableAmount
   --Insert the New Tax Amounts  
	IF @Pi_CalledFrom=21 
		BEGIN 
			IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='SALVAGE26' AND Status=1 AND ConfigValue='5.00')
				BEGIN 
					INSERT INTO BilledPrdDtCalculatedTax (RowId,PrdId,PrdBatId,TaxId,TaxSlabId,TaxPercentage,  
						TaxableAmount,TaxAmount,Usrid,TransId)  
							SELECT @Pi_RowId,B.PrdId,B.PrdBatId,@TaxId,@TaxSlab,0.00,  
							 @TaxableAmount,0.00,  
							 @Pi_UserId,@Pi_CalledFrom FROM BilledPrdHdForTax B (NOLOCK) WHERE   
							 B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom  
				END 
			ELSE
				BEGIN 
					INSERT INTO BilledPrdDtCalculatedTax (RowId,PrdId,PrdBatId,TaxId,TaxSlabId,TaxPercentage,  
						 TaxableAmount,TaxAmount,Usrid,TransId)  
						       SELECT @Pi_RowId,B.PrdId,B.PrdBatId,@TaxId,@TaxSlab,@TaxPer,  
								 @TaxableAmount,cast(@TaxableAmount * (@TaxPer / 100 ) AS NUMERIC(28,10)),  
								 @Pi_UserId,@Pi_CalledFrom FROM BilledPrdHdForTax B (NOLOCK) WHERE   
								 B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom  
				END 
		END 
   ELSE 
		BEGIN 
			INSERT INTO BilledPrdDtCalculatedTax (RowId,PrdId,PrdBatId,TaxId,TaxSlabId,TaxPercentage,  
			 TaxableAmount,TaxAmount,Usrid,TransId)  
			SELECT @Pi_RowId,B.PrdId,B.PrdBatId,@TaxId,@TaxSlab,@TaxPer,  
			 @TaxableAmount,cast(@TaxableAmount * (@TaxPer / 100 ) AS NUMERIC(28,10)),  
			 @Pi_UserId,@Pi_CalledFrom FROM BilledPrdHdForTax B (NOLOCK) WHERE   
			 B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom  
		END 
  END  
  FETCH NEXT FROM CurTax INTO @TaxSlab  
 END    
 CLOSE CurTax    
 DEALLOCATE CurTax    
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-222-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ComputeTaxLSPReCalculate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ComputeTaxLSPReCalculate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Proc_ComputeTaxLSPReCalculate]
(
	@Pi_RowId		INT,
	@Pi_CalledFrom		INT,		
	@Pi_UserId		INT,
	@Pi_Mode		INT='0',
	@Pi_LSP			NUMERIC(38,6)='0.00'
)
AS
/*********************************
* PROCEDURE	: Proc_ComputeTax
* PURPOSE	: To Calculate the Line Level Tax
* CREATED	: Thrinath
* CREATED DATE	: 22/03/2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
	
@Pi_CalledFrom  2 	For Sales
@Pi_CalledFrom  3 	For Sales Return 
@Pi_CalledFrom  5 	For Purchase
@Pi_CalledFrom  7 	For Purchase Return
@Pi_CalledFrom  20	For Replacement
@Pi_CalledFrom  23 	For Market Return 
@Pi_CalledFrom  24	For Return And Replacement
@Pi_CalledFrom  25	For Sales Panel
*********************************/ 
SET NOCOUNT ON
BEGIN	
DECLARE @PrdBatTaxGrp 		INT
DECLARE @RtrTaxGrp 		INT
DECLARE @TaxSlab		INT
DECLARE @MRP			NUMERIC(28,10)
DECLARE @SellingRate		NUMERIC(28,10)
DECLARE @PurchaseRate		NUMERIC(28,10)
DECLARE @TaxableAmount		NUMERIC(28,10)
DECLARE @ParTaxableAmount	NUMERIC(28,10)
DECLARE @TaxPer			NUMERIC(38,6)
DECLARE @TaxId			INT
DECLARE	@ApplyOn INT
DECLARE @TaxSetting TABLE 
(
	TaxSlab			INT,
	ColNo			INT,
	SlNo			INT,
	BillSeqId		INT,
	TaxSeqId		INT,
	ColType			INT,	
	ColId			INT,
	ColVal			NUMERIC(38,6)
)
	--To Take the Batch TaxGroup Id
	SELECT @PrdBatTaxGrp = TaxGroupId FROM ProductBatch A (NOLOCK) INNER JOIN
		BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID
		AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom
	--To Take the Batch MRP
	SELECT @MRP = ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN
		BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID
		AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom
		INNER JOIN ProductBatchDetails C (NOLOCK)
		ON A.PrdBatId = C.PrdBatID AND C.PriceId = B.PriceId
		INNER JOIN BatchCreation D (NOLOCK)
		ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo
		AND D.MRP = 1 
	--To Take the Batch Selling Rate
	IF @Pi_CalledFrom = 2 OR @Pi_CalledFrom = 25 OR @Pi_CalledFrom = 3 OR @Pi_CalledFrom = 23
	BEGIN
		SELECT @SellingRate = ColValue FROM BilledPrddtForTax WHERE TransId = @Pi_CalledFrom 
			AND UsrId = @Pi_UserId AND RowId = @Pi_RowId AND ColId = -2
	END
	ELSE
	BEGIN
		SELECT @SellingRate = ISNULL((C.PrdBatDetailValue * BaseQty),0) FROM ProductBatch A (NOLOCK) INNER JOIN
			BilledPrdHdForTax B (NOLOCK) On A.PrdId = B.PrdId AND A.PrdBatID = B.PrdBatID
			AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom
			INNER JOIN ProductBatchDetails C (NOLOCK)
			ON A.PrdBatId = C.PrdBatID AND C.PriceId = B.PriceId
			INNER JOIN BatchCreation D (NOLOCK)
			ON D.BatchSeqId = A.BatchSeqId AND D.SlNo = C.SlNo
			AND D.SelRte = 1
	END
	--To Take the Batch List Price
	
		SELECT @PurchaseRate =ISNULL((@Pi_LSP*BaseQty),0) FROM 
				BilledPrdHdForTax WHERE RowId = @Pi_RowId AND UsrId = @Pi_UserId 
					AND TransId = @Pi_CalledFrom
	IF (@Pi_CalledFrom = 2 OR @Pi_CalledFrom = 3 OR @Pi_CalledFrom = 20 OR @Pi_CalledFrom = 23 OR 
		@Pi_CalledFrom = 24 OR @Pi_CalledFrom = 25)
	BEGIN
		--To Take the Retailer TaxGroup Id
		SELECT @RtrTaxGrp = TaxGroupId FROM Retailer A (NOLOCK) INNER JOIN
			BilledPrdHdForTax B (NOLOCK) On A.RtrId = B.RtrId
			AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId 
			AND B.TransId = @Pi_CalledFrom
	END
	
	
	IF (@Pi_CalledFrom = 5 OR @Pi_CalledFrom = 7)
	BEGIN
		--To Take the Supplier TaxGroup Id
		SELECT @RtrTaxGrp = TaxGroupId FROM Supplier A (NOLOCK) INNER JOIN
			BilledPrdHdForTax B (NOLOCK) On A.SpmId = B.RtrId
			AND B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId
			AND B.TransId = @Pi_CalledFrom
	END
	
	--Store the Tax Setting for the Corresponding Retailer and Batch
	INSERT INTO @TaxSetting (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)
	SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal
		FROM TaxSettingMaster A (NOLOCK) INNER JOIN
		TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId
		INNER JOIN BilledPrdHdForTax C (NOLOCK) ON C.BillSeqId = B.BillSeqId
		WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp AND C.UsrId = @Pi_UserId
		AND C.RowId = @Pi_RowId AND C.TransId = @Pi_CalledFrom
		AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE
			RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp)
	--Delete the OLD Details From the BilledPrdDtCalculatedTax For the Row and User
	DELETE FROM BilledPrdDtCalculatedTax WHERE RowId = @Pi_RowId AND UsrId = @Pi_UserId 
		AND TransId = @Pi_CalledFrom
		--Cursor For Taking Each Slab and Calculate Tax
	DECLARE  CurTax CURSOR FOR
	SELECT DISTINCT TaxSlab FROM @TaxSetting
		OPEN CurTax  
		FETCH NEXT FROM CurTax INTO @TaxSlab
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		SET @TaxableAmount = 0
		--To Filter the Records Which Has Tax Percentage (>=0)
		IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1
			AND ColId = 0 and ColVal >= 0)
		BEGIN
			--To Get the Tax Percentage for the selected slab
			SELECT @TaxPer = ColVal FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1
				AND ColId = 0
			
			--To Get the TaxId for the selected slab
			SELECT @TaxId = Cast(ColVal as INT) FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 1
				AND ColId > 0
			
			--To Get the Adjustable amount from Other Columns
			SELECT @TaxableAmount = ISNULL(SUM(ColValue),0) FROM 
				(SELECT CASE B.ColVal WHEN 1 THEN A.ColValue WHEN 2 THEN -1 * A.ColValue END 
					AS ColValue FROM BilledPrdDtForTax A INNER JOIN @TaxSetting B
					ON A.ColId = B.ColId AND A.RowId =  @Pi_RowId AND A.UsrId = @Pi_UserId 
					AND A.TransId = @Pi_CalledFrom
					WHERE TaxSlab = @TaxSlab AND B.ColType = 2 and B.ColId>3
					And B.ColVal >0) as C
			SET @ApplyOn=0
			--To add MRP to Taxable Amount if MRP Is Selected for the Slab
			IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 2
					AND ColId = 1 and ColVal > 0)	
			BEGIN
						SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @MRP
				SET @ApplyOn=1 
			END
			--To add Selling Rate to Taxable Amount if Selling Rate Is Selected for the Slab
			IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 2
					AND ColId = 2 and ColVal > 0)	
				SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @SellingRate
			--To add Purchase Rate to Taxable Amount if Purchase Rate Is Selected for the Slab
			IF EXISTS (SELECT * FROM @TaxSetting WHERE TaxSlab = @TaxSlab AND ColType = 2
					AND ColId = 3 and ColVal > 0)	
				SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @PurchaseRate
			--To Get the Parent Taxable Amount for the Tax Slab
			SELECT @ParTaxableAmount =  ISNULL(SUM(TaxAmount),0) FROM BilledPrdDtCalculatedTax A
			INNER JOIN @TaxSetting B ON A.TaxId = B.ColVal AND A.RowId = @Pi_RowId
			AND A.UsrId = @Pi_UserId AND B.ColType = 3 AND B.TaxSlab = @TaxSlab
			AND A.TransId = @Pi_CalledFrom
			Set @TaxableAmount = @TaxableAmount + @ParTaxableAmount
			--Insert the New Tax Amounts
			INSERT INTO BilledPrdDtCalculatedTax (RowId,PrdId,PrdBatId,TaxId,TaxSlabId,TaxPercentage,
					TaxableAmount,TaxAmount,Usrid,TransId)
				SELECT @Pi_RowId,B.PrdId,B.PrdBatId,@TaxId,@TaxSlab,@TaxPer,
				@TaxableAmount, CASE @ApplyOn 
					WHEN 0 THEN	cast(@TaxableAmount * (@TaxPer / 100 ) AS NUMERIC(38,6))
					WHEN 1 THEN cast(@TaxableAmount * (@TaxPer / (100 +@TaxPer)) AS NUMERIC(38,6)) END,      
					@Pi_UserId,@Pi_CalledFrom FROM BilledPrdHdForTax B (NOLOCK) WHERE 
					B.RowId = @Pi_RowId AND B.UsrId = @Pi_UserId AND B.TransId = @Pi_CalledFrom
		END
		FETCH NEXT FROM CurTax INTO @TaxSlab
	END  
	CLOSE CurTax  
	DEALLOCATE CurTax 
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-222-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RetailerAccountStment]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RetailerAccountStment]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].[Proc_RetailerAccountStment] 
(
	@Pi_FromDate DATETIME,
	@Pi_ToDate DATETIME,
	@Pi_RtrId INT
)
AS
/*********************************
* PROCEDURE	: Proc_RetailerAccountStment
* PURPOSE	: To Return the Retailer wise bill details
* CREATED	: MarySubashini.S
* CREATED DATE	: 23-06-2010
* NOTE		: General SP Returning the Retailer wise Account details 
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}		{brief modification description}
* 14-OCT-2010	Jayakumar N		Reference with SLR is not taken from CreditNoteRetailer	
* 20-OCT-2010	Jayakumar N		Changes done after discussion made with kanagaraj regarding CreditNote & DebitNote posting	
*********************************/
SET NOCOUNT ON
BEGIN
	-- AND PostedFrom NOT LIKE @SLRHD AND PostedFrom NOT LIKE @RTNHD AND PostedFrom IS NULL

	DECLARE @SLRHD AS NVARCHAR(50)
	DECLARE @RTNHD AS NVARCHAR(50)
	SELECT @SLRHD=Prefix FROM Counters WHERE TabName='ReturnHeader' and FldName = 'ReturnCode'
	SET @SLRHD=@SLRHD + '%'
	SELECT @RTNHD=Prefix FROM Counters WHERE TabName='ReplacementHd' and FldName = 'RepRefNo'
	SET @RTNHD=@RTNHD + '%'
	DECLARE @TempRetailerAccountStatement TABLE
		(
			[SlNo] [int] NULL,
			[RtrId] [int] NULL,
			[CoaId] [int] NULL,
			[RtrName] [nvarchar](100) NULL,
			[RtrAddress] [nvarchar](600) NULL,
			[RtrTINNo] [nvarchar](50) NULL,
			[InvDate] [datetime] NULL,
			[DocumentNo] [nvarchar](100) NULL,
			[Details] [nvarchar](400) NULL,
			[RefNo] [nvarchar](100) NULL,
			[DbAmount] [numeric](38, 6) NULL,
			[CrAmount] [numeric](38, 6) NULL,
			[BalanceAmount] [numeric](38, 6) NULL
		)
	INSERT INTO @TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
	SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				SI.SalInvDate,SI.SalInvNo,'Sales','',
				(SI.SalNetAmt + SI.OnAccountAmount + SI.MarketRetAmount + SI.CrAdjAmount-SI.ReplacementDiffAmount - SI.DBAdjAmount),0,0
			FROM SalesInvoice SI (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
			WHERE SI.DlvSts  IN (4,5) AND SI.SalInvDate <@Pi_FromDate  AND SI.RtrId=@Pi_RtrId
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.ReturnDate,RH.ReturnCode,'Sales Return',ISNULL(SI.SalInvNo,''),0,
					(CASE RH.RtnRoundOff WHEN 1 THEN (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)+RH.RtnRoundOffAmt) 
					ELSE (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)) END ),0
				FROM ReturnHeader RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnId=RH.ReturnId
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.Status=0 AND RH.ReturnType=2 AND RH.ReturnDate<@Pi_FromDate AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.ReturnDate,RH.ReturnCode,
				SI.SalInvNo,RH.RtnRoundOff,RH.RtnRoundOffAmt
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.ReturnDate,RH.ReturnCode,'Market Return',ISNULL(SI.SalInvNo,''),0,
					(CASE RH.RtnRoundOff WHEN 1 THEN (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)+RH.RtnRoundOffAmt) 
					ELSE (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)) END ),0
				FROM ReturnHeader RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnId=RH.ReturnId
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.Status=0 AND RH.ReturnType=1 AND RH.ReturnDate<@Pi_FromDate AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.ReturnDate,RH.ReturnCode,
				SI.SalInvNo,RH.RtnRoundOff,RH.RtnRoundOffAmt
----		UNION ALL
----			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
----					RH.RepDate,RH.RepRefNo,'Return & Replacement-Return',ISNULL(SI.SalInvNo,''),0,ROUND(SUM(RP.RtnAmount),2),0
----				FROM ReplacementHd RH (NOLOCK)
----					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
----					INNER JOIN ReplacementIn RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
----					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
----				WHERE RH.RepDate<@Pi_FromDate AND  RH.RtrId=@Pi_RtrId
----				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.RepDate,RH.RepRefNo,'Return & Replacement-Replacement',ISNULL(SI.SalInvNo,''),ROUND(SUM(RP.RepAmount),2),0,0
				FROM ReplacementHd RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReplacementOut RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.RepDate<@Pi_FromDate AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
		UNION ALL  -- Added by Jay on 21-OCT-2010
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.RepDate,RH.RepRefNo,'Return & Replacement-Return',ISNULL(SI.SalInvNo,''),0,ROUND(SUM(RP.RtnAmount),2),0
				FROM ReplacementHd RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReplacementIn RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.RepDate<@Pi_FromDate AND RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
				   -- End here
		UNION ALL
			SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.InvRcpDate,RH.InvRcpNo,'Collection',ISNULL(SI.SalInvNo,''),0,SUM(RE.SalInvAmt),0
				FROM Receipt RH (NOLOCK)
					INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
					INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
					INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
				WHERE RE.InvRcpMode IN (1,2,3,4,8) AND 
					RH.InvRcpDate<@Pi_FromDate AND SI.RtrId=@Pi_RtrId
				GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
			SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				RH.InvRcpDate,RH.InvRcpNo,'Collection-Cheque Bounce',ISNULL(SI.SalInvNo,''),(SUM(RE.SalInvAmt)+SUM(RE.Penalty)),0,0
			FROM Receipt RH (NOLOCK)
				INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
				INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
				INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
			WHERE RE.InvRcpMode IN (3) AND InvInsSta=4 AND 
				RH.InvRcpDate<@Pi_FromDate AND SI.RtrId=@Pi_RtrId
			GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
		SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.InvRcpDate,RH.InvRcpNo,'Collection-Cash Cancellation',ISNULL(SI.SalInvNo,''),SUM(RE.SalInvAmt),0,0
				FROM Receipt RH (NOLOCK)
					INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
					INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
					INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
				WHERE RE.InvRcpMode IN (1,2) AND CancelStatus=0  AND 
					RH.InvRcpDate<@Pi_FromDate AND SI.RtrId=@Pi_RtrId
				GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
		SELECT  2,DR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				DR.DbNoteDate,DR.DbNoteNumber,'Debit Note Retailer',(CASE DR.TransId WHEN 19 THEN '' ELSE DR.PostedFrom END),DR.Amount,DR.Amount,0 -- DR.Amount
			FROM DebitNoteRetailer DR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON DR.RtrId=R.RtrId AND DR.CoaId=R.CoaId
			WHERE DR.DbNoteDate<@Pi_FromDate AND DR.RtrId=@Pi_RtrId
			AND DR.PostedFrom NOT LIKE @RTNHD AND DR.PostedFrom NOT LIKE @SLRHD OR DR.PostedFrom IS NULL
			

		UNION ALL
		SELECT  2,DR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				DR.DbNoteDate,DR.DbNoteNumber,'Debit Note Retailer',(CASE DR.TransId WHEN 19 THEN '' ELSE DR.PostedFrom END),DR.Amount,0,0
			FROM DebitNoteRetailer DR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON DR.RtrId=R.RtrId AND DR.CoaId<>R.CoaId 
			WHERE DR.DbNoteDate<@Pi_FromDate AND DR.RtrId=@Pi_RtrId 
			AND DR.PostedFrom NOT LIKE @RTNHD AND DR.PostedFrom NOT LIKE @SLRHD OR DR.PostedFrom IS NULL
		UNION ALL
		SELECT  2,CR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				CR.CrNoteDate,CR.CrNoteNumber,'Credit Note Retailer',(CASE CR.TransId WHEN 18 THEN '' ELSE CR.PostedFrom END),CR.Amount,CR.Amount,0  -- CR.Amount
			FROM CreditNoteRetailer CR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON CR.RtrId=R.RtrId AND CR.CoaId=R.CoaId
			WHERE CR.CrNoteDate<@Pi_FromDate AND CR.RtrId=@Pi_RtrId 
			AND CR.PostedFrom NOT LIKE @RTNHD AND CR.PostedFrom NOT LIKE @SLRHD OR CR.PostedFrom IS NULL
		UNION ALL
		SELECT  2,CR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				CR.CrNoteDate,CR.CrNoteNumber,'Credit Note Retailer',(CASE CR.TransId WHEN 18 THEN '' ELSE CR.PostedFrom END),0,CR.Amount,0
			FROM CreditNoteRetailer CR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON CR.RtrId=R.RtrId AND CR.CoaId<>R.CoaId
			WHERE CR.CrNoteDate<@Pi_FromDate AND CR.RtrId=@Pi_RtrId 
			AND CR.PostedFrom NOT LIKE @RTNHD AND CR.PostedFrom NOT LIKE @SLRHD OR CR.PostedFrom IS NULL
		UNION ALL
		SELECT  2,ROA.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				ROA.ChequeDate,ROA.RtrAccRefNo,'Retailer On Account','',0,Amount,0
			FROM RetailerOnAccount ROA (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON ROA.RtrId=R.RtrId
			WHERE ROA.ChequeDate<@Pi_FromDate AND ROA.RtrId=@Pi_RtrId

	-- Added by Jay on 21-OCT-2010
	DELETE FROM @TempRetailerAccountStatement WHERE Rtrid<>@Pi_RtrId
	TRUNCATE TABLE TempRetailerAccountStatement
	INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
	
		SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				SI.SalInvDate,SI.SalInvNo,'Sales','',
				(SI.SalNetAmt + SI.OnAccountAmount + SI.MarketRetAmount + SI.CrAdjAmount- SI.DBAdjAmount),0,0
			FROM SalesInvoice SI (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
			WHERE SI.DlvSts  IN (4,5) AND SI.SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SI.RtrId=@Pi_RtrId
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.ReturnDate,RH.ReturnCode,'Sales Return',ISNULL(SI.SalInvNo,''),0,
					(CASE RH.RtnRoundOff WHEN 1 THEN (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)+RH.RtnRoundOffAmt) 
					ELSE (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)) END ),0
				FROM ReturnHeader RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnId=RH.ReturnId
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.Status=0 AND RH.ReturnType=2 AND RH.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate  AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.ReturnDate,RH.ReturnCode,
				SI.SalInvNo,RH.RtnRoundOff,RH.RtnRoundOffAmt
		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.ReturnDate,RH.ReturnCode,'Market Return',ISNULL(SI.SalInvNo,''),0,
					(CASE RH.RtnRoundOff WHEN 1 THEN (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)+RH.RtnRoundOffAmt) 
					ELSE (SUM(RP.PrdNetAmt)+SUM(RP.EditedNetRte)) END ),0
				FROM ReturnHeader RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReturnProduct RP (NOLOCK) ON RP.ReturnId=RH.ReturnId
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.Status=0 AND RH.ReturnType=1 AND RH.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.ReturnDate,RH.ReturnCode,
				SI.SalInvNo,RH.RtnRoundOff,RH.RtnRoundOffAmt

----		UNION ALL
----			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
----					RH.RepDate,RH.RepRefNo,'Return & Replacement-Return',ISNULL(SI.SalInvNo,''),0,ROUND(SUM(RP.RtnAmount),2),0
----				FROM ReplacementHd RH (NOLOCK)
----					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
----					INNER JOIN ReplacementIn RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
----					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
----				WHERE RH.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  RH.RtrId=@Pi_RtrId
----				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo

		UNION ALL
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.RepDate,RH.RepRefNo,'Return & Replacement-Replacement',ISNULL(SI.SalInvNo,''),ROUND(SUM(RP.RepAmount),2),0,0
				FROM ReplacementHd RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReplacementOut RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
		UNION ALL  -- Added by Jay on 20-OCT-2010
			SELECT  2,RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.RepDate,RH.RepRefNo,'Return & Replacement-Return',ISNULL(SI.SalInvNo,''),0,ROUND(SUM(RP.RtnAmount),2),0
				FROM ReplacementHd RH (NOLOCK)
					INNER JOIN Retailer R (NOLOCK) ON RH.RtrId=R.RtrId
					INNER JOIN ReplacementIn RP (NOLOCK) ON RP.RepRefNo=RH.RepRefNo
					LEFT OUTER JOIN SalesInvoice SI (NOLOCK) ON RH.SalId=SI.SalId 
				WHERE RH.RepDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND  RH.RtrId=@Pi_RtrId
				GROUP BY RH.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.RepDate,RH.RepRefNo,SI.SalInvNo
				   -- End here
		UNION ALL
			SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.InvRcpDate,RH.InvRcpNo,'Collection',ISNULL(SI.SalInvNo,''),0,SUM(RE.SalInvAmt),0
				FROM Receipt RH (NOLOCK)
					INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
					INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
					INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
				WHERE RE.InvRcpMode IN (1,2,3,4,8) AND 
					RH.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SI.RtrId=@Pi_RtrId
				GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
			SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				RH.InvRcpDate,RH.InvRcpNo,'Collection-Cheque Bounce',ISNULL(SI.SalInvNo,''),(SUM(RE.SalInvAmt)+SUM(RE.Penalty)),0,0
			FROM Receipt RH (NOLOCK)
				INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
				INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
				INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
			WHERE RE.InvRcpMode IN (3) AND InvInsSta=4 AND 
				RH.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SI.RtrId=@Pi_RtrId
			GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
		SELECT  2,SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					RH.InvRcpDate,RH.InvRcpNo,'Collection-Cash Cancellation',ISNULL(SI.SalInvNo,''),SUM(RE.SalInvAmt),0,0
				FROM Receipt RH (NOLOCK)
					INNER JOIN ReceiptInvoice RE (NOLOCK) ON RH.InvRcpNo=RE.InvRcpNo
					INNER JOIN SalesInvoice SI (NOLOCK) ON RE.SalId=SI.SalId
					INNER JOIN Retailer R (NOLOCK) ON SI.RtrId=R.RtrId
				WHERE RE.InvRcpMode IN (1,2) AND CancelStatus=0  AND 
					RH.InvRcpDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND SI.RtrId=@Pi_RtrId
				GROUP BY SI.RtrId,R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo,RH.InvRcpDate,RH.InvRcpNo,SI.SalInvNo
		UNION ALL
		SELECT  2,DR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				DR.DbNoteDate,DR.DbNoteNumber,'Debit Note Retailer',(CASE DR.TransId WHEN 19 THEN '' ELSE DR.PostedFrom END),DR.Amount,DR.Amount,0 --DR.Amount,0
			FROM DebitNoteRetailer DR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON DR.RtrId=R.RtrId AND DR.CoaId=R.CoaId  
			WHERE DR.DbNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND DR.RtrId=@Pi_RtrId --AND PostedFrom NOT LIKE @SLRHD AND PostedFrom NOT LIKE @RTNHD AND PostedFrom IS NULL
		UNION ALL
		SELECT  2,DR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				DR.DbNoteDate,DR.DbNoteNumber,'Debit Note Retailer',(CASE DR.TransId WHEN 19 THEN '' ELSE DR.PostedFrom END),DR.Amount,0,0
			FROM DebitNoteRetailer DR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON DR.RtrId=R.RtrId AND DR.CoaId<>R.CoaId  AND DR.TransId<>11
			WHERE DR.DbNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND DR.RtrId=@Pi_RtrId --AND PostedFrom NOT LIKE @SLRHD AND PostedFrom NOT LIKE @RTNHD AND PostedFrom IS NULL
		UNION ALL
		SELECT  2,CR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				CR.CrNoteDate,CR.CrNoteNumber,'Credit Note Retailer',(CASE CR.TransId WHEN 18 THEN '' ELSE CR.PostedFrom END),CR.Amount,CR.Amount,0 --CR.Amount,CR.Amount,0
			FROM CreditNoteRetailer CR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON CR.RtrId=R.RtrId AND CR.CoaId=R.CoaId
			WHERE CR.CrNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND CR.RtrId=@Pi_RtrId --AND PostedFrom NOT LIKE @RTNHD AND PostedFrom NOT LIKE @SLRHD AND PostedFrom IS NULL
		UNION ALL
		SELECT  2,CR.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				CR.CrNoteDate,CR.CrNoteNumber,'Credit Note Retailer',(CASE CR.TransId WHEN 18 THEN '' ELSE CR.PostedFrom END),0,CR.Amount,0
			FROM CreditNoteRetailer CR (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON CR.RtrId=R.RtrId AND CR.CoaId<>R.CoaId
			WHERE CR.CrNoteDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND CR.RtrId=@Pi_RtrId --AND PostedFrom NOT LIKE @RTNHD AND PostedFrom NOT LIKE @SLRHD AND PostedFrom IS NULL
		UNION ALL
		SELECT  2,ROA.RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
				ROA.ChequeDate,ROA.RtrAccRefNo,'Retailer On Account','',0,Amount,0
			FROM RetailerOnAccount ROA (NOLOCK)
				INNER JOIN Retailer R (NOLOCK) ON ROA.RtrId=R.RtrId
			WHERE ROA.ChequeDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND ROA.RtrId=@Pi_RtrId



			CREATE Table #DelRtrAccStmt(SlNo INT,RtrId Int,CoaId INT,InvDate DateTime,DocumentNo nVarchar(50),
							RefNo nVarchar(50),DBAmount Numeric(18,6),CRAmount Numeric(18,6),
							BalAmt Numeric(18,6))

			INSERT INTO #DelRtrAccStmt
			Select SlNo,RtrId,CoaId,InvDate,DocumentNo,RefNo,DBAmount,CRAmount,BalanceAmount
			From TempRetailerAccountStatement Where Details  like  'Credit Note Retailer' 
			and RefNo like @SLRHD
			Union ALL
			Select SlNo,RtrId,CoaId,InvDate,DocumentNo,RefNo,DBAmount,CRAmount,BalanceAmount
			from TempRetailerAccountStatement Where Details  like  'Credit Note Retailer' 
			and RefNo like @RTNHD
			Union ALL
			Select SlNo,RtrId,CoaId,InvDate,DocumentNo,RefNo,DBAmount,CRAmount,BalanceAmount
			from TempRetailerAccountStatement Where Details  like  'Debit Note Retailer' 
			and RefNo like @SLRHD
			Union ALL
			Select SlNo,RtrId,CoaId,InvDate,DocumentNo,RefNo,DBAmount,CRAmount,BalanceAmount
			from TempRetailerAccountStatement Where Details  like  'Debit Note Retailer' 
			and RefNo like @RTNHD

			Delete  From  @TempRetailerAccountStatement 
			Where  (SlNo in (Select SlNo From #DelRtrAccStmt)
				    ANd  RtrId in (Select RtrId From #DelRtrAccStmt)
					ANd  CoaId in (Select CoaId From #DelRtrAccStmt)
					ANd  InvDate in (Select InvDate From #DelRtrAccStmt)
					ANd  DocumentNo in (Select DocumentNo From #DelRtrAccStmt)
					ANd  RefNo in (Select RefNo From #DelRtrAccStmt)
					ANd  DBAmount in (Select DBAmount From #DelRtrAccStmt)
					ANd  CRAmount in (Select CRAmount From #DelRtrAccStmt)
					ANd  BalanceAmount in (Select BalAmt From #DelRtrAccStmt) )
 

			Delete  From  TempRetailerAccountStatement 
			Where  (SlNo in (Select SlNo From #DelRtrAccStmt)
				    ANd  RtrId in (Select RtrId From #DelRtrAccStmt)
					ANd  CoaId in (Select CoaId From #DelRtrAccStmt)
					ANd  InvDate in (Select InvDate From #DelRtrAccStmt)
					ANd  DocumentNo in (Select DocumentNo From #DelRtrAccStmt)
					ANd  RefNo in (Select RefNo From #DelRtrAccStmt)
					ANd  DBAmount in (Select DBAmount From #DelRtrAccStmt)
					ANd  CRAmount in (Select CRAmount From #DelRtrAccStmt)
					ANd  BalanceAmount in (Select BalAmt From #DelRtrAccStmt) )

	IF EXISTS (SELECT * FROM @TempRetailerAccountStatement)
	BEGIN
		INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
			SELECT 1,@Pi_RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					@Pi_FromDate,'','Opening Balance','',0,0,(SUM(Det.DbAmount)-SUM(Det.CrAmount))
			FROM @TempRetailerAccountStatement Det ,Retailer R 
			WHERE R.RtrId=Det.RtrId
			GROUP BY R.CoaId,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrTINNo
		INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
			SELECT  DISTINCT 3,@Pi_RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					@Pi_ToDate,'','Closing Balance','',0,0,0
				FROM Retailer R WHERE R.RtrId=@Pi_RtrId
	END 
	ELSE
	BEGIN
		INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
			SELECT DISTINCT  1,@Pi_RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					@Pi_FromDate,'','Opening Balance','',0,0,0
				FROM Retailer R WHERE R.RtrId=@Pi_RtrId
		INSERT INTO TempRetailerAccountStatement (SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
			SELECT  DISTINCT 3,@Pi_RtrId,R.CoaId,R.RtrName,R.RtrAdd1+'   '+R.RtrAdd2+'   '+R.RtrAdd3,R.RtrTINNo,
					@Pi_ToDate,'','Closing Balance','',0,0,0
				FROM Retailer R WHERE R.RtrId=@Pi_RtrId
	END 

	-- Added by Jay on 20-OCT-2010
	INSERT INTO TempRetailerAccountStatement
	SELECT 2,B.CoaId,B.CoaId,AcName,'','',VocDate,'',AcName,NULL,Amount,0,0
	FROM StdVocMaster A INNER JOIN StdVocDetails B ON A.VocRefNo=B.VocRefNo 
	INNER JOIN CoaMaster C ON B.CoaId=C.CoaId
	AND A.VocDate BETWEEN @Pi_FromDate AND @Pi_ToDate 
	AND A.VocType=0 AND A.VocSubType=0 AND A.AutoGen=0 AND DebitCredit=1
	UNION ALL
	SELECT 2,B.CoaId,B.CoaId,AcName,'','',VocDate,'',AcName,NULL,0,Amount,0
	FROM StdVocMaster A INNER JOIN StdVocDetails B ON A.VocRefNo=B.VocRefNo 
	INNER JOIN CoaMaster C ON B.CoaId=C.CoaId
	AND A.VocDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	AND A.VocType=0 AND A.VocSubType=0 AND A.AutoGen=0 AND DebitCredit=2
	-- End here	

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-222-004-From Boo

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RptAkzoRetAccStatement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RptAkzoRetAccStatement]
GO

----   exec  Proc_RptAkzoRetAccStatement 222,2,0,'hh',0,0,1
CREATE  Procedure [Proc_RptAkzoRetAccStatement]
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
Begin
SET NOCOUNT ON
/****************************************************************************
* PROCEDURE: Proc_RptAkzoRetAccStatement
* PURPOSE: General Procedure
* NOTES:
* CREATED: Panneer	14.03.2011
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
* 22.03.2011   Panneer    BugFixing
* 29.03.2011   
*****************************************************************************/

	DECLARE @FromDate			AS DATETIME
	DECLARE @ToDate				AS DATETIME
	DECLARE @NewSnapId 			AS	INT
	DECLARE @DBNAME				AS 	NVARCHAR(50)
	DECLARE @TblName 			AS	NVARCHAR(500)
	DECLARE @TblStruct 			AS	VARCHAR(8000)
	DECLARE @TblFields 			AS	VARCHAR(8000)
	DECLARE @sSql				AS 	VARCHAR(8000)
	DECLARE @ErrNo	 			AS	INT
	DECLARE @PurDBName			AS	NVARCHAR(50)

	DECLARE @SMId				AS	INT
	DECLARE @RMId				AS	INT
	DECLARE @RtrId				AS	INT

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)

	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))


	CREATE TABLE #RptAkzoRetAccStatement
	(
			[Description]       NVARCHAR(200),
			[DocRefNo]          NVARCHAR(200),
			[Date]				NVARCHAR(10),
			[Debit]				NUMERIC (38,6),
			[Credit]			NUMERIC (38,6),
			[Balance]			NUMERIC (38,6),
			[TransactionDet]    NVARCHAR(200),
			[CheqorDueDate]     NVARCHAR(10),
			[SeqNo]				INT,
			[UserId]			INT
	)

SET @TblName = 'RptAkzoRetAccStatement'
SET @TblStruct = '	[Description]       NVARCHAR(200),
					[DocRefNo]          NVARCHAR(200),
					[Date]				NVARCHAR(10),
					[Debit]				NUMERIC (38,6),
					[Credit]			NUMERIC (38,6),
					[Balance]			NUMERIC (38,6),
					[TransactionDet]    NVARCHAR(200),
					[CheqorDueDate]     NVARCHAR(10),
					[SeqNo]				INT
					[UserId]			INT'
SET @TblFields = '  [Description],[DocRefNo],[Date],[Debit],[Credit],
					[Balance],[TransactionDet],[CheqorDueDate],[SeqNo],[UserId]'

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
		Exec Proc_RetailerAccountStment @FromDate,@ToDate,@RtrId

		INSERT INTO #RptAkzoRetAccStatement ([Description],DocRefNo,Date,Debit,Credit,Balance,
											 TransactionDet,CheqorDueDate,SeqNo,UserId)
			/*	Calculate Opening Balance Details  */	
		Select  
				'Opening Balance'   [Description], '' DocRefNo, convert(Varchar(10),@FromDate,121) Date,
				 0 as Debit,0 As Credit,BalanceAmount as balance,
				'' as TransactionDet,'' CheqorDueDate,1 SeqNo,@Pi_UsrId
		From 
				TempRetailerAccountStatement  (NoLock) 
		Where	Details = 'Opening Balance'
				
 				 
				/*	Calculate Sales Details  */ 
		UNION ALL 
		Select  
				'Invoice' [Description],SalInvNo DocRefNo,convert(Varchar(10),SalInvDate,121)  Date,
				DbAmount Debit,0 as Credit,0 Balance,'' as TransactionDet,
				convert(Varchar(10),SalDlvDate,121) CheqorDueDate,2 SeqNo, @Pi_UsrId
		From 
				TempRetailerAccountStatement a (NoLock) ,SalesInvoice B (NoLock)
		WHere
				Details = 'Sales' and A.DocumentNo = B.SalInvNo 
		UNION ALL
		Select  
				'Total Invoice IN' [Description],'' DocRefNo,'' Date,
				0 Debit,0 as Credit, Isnull(SUM(DbAmount),0) Balance,'' as TransactionDet,
				'' CheqorDueDate,3 SeqNo,@Pi_UsrId
		From 
				TempRetailerAccountStatement a (NoLock) ,SalesInvoice B (NoLock)
		WHere
				Details = 'Sales' and A.DocumentNo = B.SalInvNo 

					/*	Calculate Cheque Details  */
		UNION ALL		
		Select  
				'Cheque Received' [Description],RI.InvRcpNo DocRefNo,convert(Varchar(10),InvRcpDate,121)  Date,
				0 Debit,Sum(RI.SalInvAmt)  as Credit, 0 Balance,InvInsNo as TransactionDet,
				convert(Varchar(10),Isnull(InvInsDate,''),121) CheqorDueDate,4 SeqNo, @Pi_UsrId
		From 
				ReceiptInvoice RI (NoLock),	TempRetailerAccountStatement T (NoLock) ,
				Receipt  R  (NoLock),		SalesInvoice SI (NoLock)
		Where
				RI.InvRcpNo = T.DocumentNo  AND  RI.InvRcpNo = R.InvRcpNo
				and Details = 'Collection'  AND InvRcpMode IN (1,2,3,4,8)
				AND T.Rtrid  = @RtrId       And RI.SalId = SI.SalId 
				And T.RtrId = SI.RtrId		AND SI.SalInvNo = T.Refno
				AND  CancelStatus = 1
		Group By
				RI.InvRcpNo,InvRcpDate,InvInsNo,InvInsDate 
		UNION ALL
		Select  
				'Total Receipt Received' [Description],'' DocRefNo,'' Date,
				0 Debit,0  as Credit, (-1) * Isnull(Sum(RI.SalInvAmt),0) Balance,'' as TransactionDet,
				'' CheqorDueDate,5 SeqNo,@Pi_UsrId
		From 
				ReceiptInvoice RI (NoLock),	TempRetailerAccountStatement T (NoLock) ,
				Receipt  R  (NoLock),		SalesInvoice SI (NoLock)
		Where
				RI.InvRcpNo = T.DocumentNo  AND  RI.InvRcpNo = R.InvRcpNo
				and Details = 'Collection'  AND InvRcpMode IN (1,2,3,4,8)
				AND T.Rtrid  = @RtrId       And RI.SalId = SI.SalId 
				And T.RtrId = SI.RtrId		AND SI.SalInvNo = T.Refno
				AND  CancelStatus = 1

				/*	Calculate Debit Note Details  */
		UNION ALL
		Select 'Debit Note - CD' AS [Description],DBNoteNumber DocRefNo,convert(Varchar(10),DBNoteDate,121)  Date,
				Isnull(DbAmount,0) Debit,Isnull(CRAmount,0) as Credit, 0 Balance,Isnull(Remarks,'') as TransaonDet,
				'' CheqorDueDate,6 SeqNo,@Pi_UsrId
		From 
				DebitNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.DBNoteNumber = T.DocumentNo	AND Details = 'Debit Note Retailer'	
		UNION ALL
		Select 'Total Debit Notes' AS [Description],'' DocRefNo,'' Date,
				0 Debit,0 as Credit, Isnull(Sum(DbAmount - CRAmount),0) Balance,'' as TransaonDet,
				'' CheqorDueDate,7 SeqNo,@Pi_UsrId
		From 
				DebitNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.DBNoteNumber = T.DocumentNo	AND Details = 'Debit Note Retailer'
				
				/*  Calculate Return  Details  */
		UNION ALL
		Select  'Credit Invoice',ReturnCode DocRefNo,convert(Varchar(10),ReturnDate,121)  Date,
				0 as Debit,CrAmount as Credit,0 as  Balance,Isnull(DocRefNo,'') as TransaonDet,
				'' CheqorDueDate,8 SeqNo,@Pi_UsrId
		From
				ReturnHeader  A (Nolock) ,TempRetailerAccountStatement T (Nolock)
		Where	
				Details = 'Sales Return' AND A.ReturnCode = T.DocumentNo
		UNION ALL
		Select  'Total Credit Invoice','' DocRefNo,'' Date,
				0 as Debit,0 as Credit,Isnull(Sum(CrAmount),0) * (-1) as  Balance,
				'' as TransaonDet,
				'' CheqorDueDate,9 SeqNo,@Pi_UsrId
		From
				ReturnHeader  A (Nolock) ,TempRetailerAccountStatement T (Nolock)
		Where	
				Details = 'Sales Return' AND A.ReturnCode = T.DocumentNo
	
 				/*  Calculate Credit Note  Details  */
		UNION ALL
		Select 'Credit Note' AS [Description],CRNoteNumber DocRefNo,convert(Varchar(10),CRNoteDate,121)  Date,
				Isnull(DBAmount,0) Debit,Isnull(CRAmount,0) as Credit, 0 Balance,Isnull(Remarks,'') as TransaonDet,
				'' CheqorDueDate,10 SeqNo,@Pi_UsrId
		From 
				CreditNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.CRNoteNumber = T.DocumentNo	AND Details = 'Credit Note Retailer'	
		UNION ALL
		Select 'Total Credit Notes' AS [Description],'' DocRefNo,'' Date,
				0 Debit,0 as Credit,-(1) * Isnull(Sum(CRAmount-DBAmount),0) Balance,'' as TransaonDet,
				'' CheqorDueDate,11 SeqNo,@Pi_UsrId
		From 
				CreditNoteRetailer A (NoLock),TempRetailerAccountStatement T  (NoLock)		
		Where 
				A.CRNoteNumber = T.DocumentNo	AND Details = 'Credit Note Retailer'

					/*  Calculate Return & Replacement  Details  */
		Union ALl
		Select 
				'Return & Replacement-Replacement' AS [Description],RepRefNo DocRefNo,convert(Varchar(10),RepDate,121)   Date,
				DBAmount Debit,0 Credit,0 Balance ,Isnull(DocRefNo,'') DocRefNo,
				'' CheqorDueDate,12 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND Details = 'Return & Replacement-Replacement'
		Union ALL
		Select 
				'Total Return & Replacement-Replacement' AS [Description],'' DocRefNo,''  Date,
				0 Debit,0 Credit,Isnull(Sum(DBAmount),0) Balance , '' DocRefNo,
				'' CheqorDueDate,13 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND  Details = 'Return & Replacement-Replacement'

					/*  Calculate Return & Replacement  Details  */
		Union ALl
		Select 
				'Return & Replacement-Return' AS [Description],RepRefNo DocRefNo,convert(Varchar(10),RepDate,121)  Date,
				0 Debit,CRAmount Credit,0 Balance ,Isnull(DocRefNo,'') DocRefNo,
				'' CheqorDueDate,14 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND Details = 'Return & Replacement-Return'
		Union ALL
		Select 
				'Total Return & Replacement-Return' AS [Description],'' DocRefNo,''  Date,
				0 Debit,0 Credit,(-1) * Isnull(Sum(CRAmount),0) Balance , '' DocRefNo,
				'' CheqorDueDate,15 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , ReplacementHd A (Nolock)
		WHERE
				A.RepRefNo = T.DocumentNo AND  Details = 'Return & Replacement-Return'

					/*  Calculate Collection-Cheque Bounce Details  */
		Union ALl
		Select 
				'Collection-Cheque Bounce' AS [Description],InvRcpNo, convert(Varchar(10),InvRcpDate,121)     Date,
				DbAmount Debit,0 Credit,0 Balance ,'' DocRefNo,
				'' CheqorDueDate,16 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , Receipt A (Nolock)
		WHERE
				A.InvRcpNo = T.DocumentNo AND Details = 'Collection-Cheque Bounce'
		Union ALL
		Select 
				'Total Collection-Cheque Bounce' AS [Description],'' DocRefNo,''  Date,
				0 Debit,0 Credit, Isnull(Sum(DbAmount),0) Balance , '' DocRefNo,
				'' CheqorDueDate,17 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Collection-Cheque Bounce'

					/*  Calculate Collection-Cheque Bounce Details  */
		Union ALl
		Select 
				'Collection-Cash Cancellation' AS [Description],InvRcpNo, convert(Varchar(10),InvRcpDate,121)  Date,
				DbAmount Debit,0 Credit,0 Balance ,'' DocRefNo,
				'' CheqorDueDate,18 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , Receipt A (Nolock)
		WHERE
				A.InvRcpNo = T.DocumentNo AND Details = 'Collection-Cash Cancellation'
		Union ALL
		Select 
				'Total Collection-Cash Cancellation' AS [Description],'' DocRefNo,''  Date,
				0 Debit,0 Credit, Isnull(Sum(DbAmount),0) Balance , '' DocRefNo,
				'' CheqorDueDate,19 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Collection-Cash Cancellation'

				/*  Calculate Retailer On Account Details  */
		Union ALl
		Select 
				'Retailer On Account' AS [Description],RtrAccRefNo,  convert(Varchar(10),ChequeDate,121)   Date,
				DbAmount Debit,0 Credit,0 Balance ,Remarks DocRefNo,
				'' CheqorDueDate,20 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) , RetailerOnAccount A (Nolock)
		WHERE
				A.RtrAccRefNo = T.DocumentNo AND Details = 'Retailer On Account'
		Union ALL
		Select 
				'Total Retailer On Account' AS [Description],'' DocRefNo,''  Date,
				0 Debit,0 Credit, (-1) * Isnull(Sum(CRAmount),0) Balance , '' DocRefNo,
				'' CheqorDueDate,21 SeqNo, @Pi_UsrId
		From 
			 	TempRetailerAccountStatement T (Nolock) 
		WHERE
				Details = 'Retailer On Account'

				/*  Calculate Closing Balance Details  */
		UNION ALL
		Select  
				'Closing Balance' [Description], '' DocRefNo,convert(Varchar(10),@ToDate,121)  Date,
				0 as Debit,0 Credit, 0  Balance,
				'' as TransactionDet,'' CheqorDueDate,22 SeqNo,@Pi_UsrId
		From 
				TempRetailerAccountStatement 
		Where
				Details = 'Closing Balance'	

		DECLARE @ClBal Numeric(18,4)
		Select @ClBal = Sum(Balance)   From  #RptAkzoRetAccStatement 
		Where SeqNo in (1,3,5,7,9,11,13,15,17,19,21)
				
		Update #RptAkzoRetAccStatement Set Balance = @ClBal Where SeqNo = 22


	END

	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptAkzoRetAccStatement

	Delete From #RptAkzoRetAccStatement 
	WHere Balance  = 0 and SeqNo  in (3,5,7,9,11,13,15,17,19,21)
	Select * from #RptAkzoRetAccStatement Order by SeqNo,[Description]
END
GO

if not exists (select * from hotfixlog where fixid = 369)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(369,'D','2011-03-31',getdate(),1,'Core Stocky Service Pack 369')
