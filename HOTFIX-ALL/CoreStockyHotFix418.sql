--[Stocky HotFix Version]=418
DELETE FROM Versioncontrol WHERE Hotfixid='418'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('418','3.1.0.0','D','2014-09-16','2014-09-16','2014-09-16',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
/*
*******************************************************************************************
CR DETAILS :
1. Bulk Batch Transfer 

ISSUES DETAILS :
1.  Stock Issue Fixed
*******************************************************************************************         
*/
IF EXISTS(SELECT * FROM sysobjects WHERE name = 'Proc_UpdateProductBatchLocation' AND xtype='P')  
DROP PROCEDURE Proc_UpdateProductBatchLocation
GO
--exec Proc_UpdateProductBatchLocation 1,2,1,2282,5,'2006-02-15',150,1,0
CREATE Procedure Proc_UpdateProductBatchLocation
(
	@Pi_ColId 		INT,
	@Pi_Type		INT,
	@Pi_PrdId		INT,
	@Pi_PrdBatId		INT,
	@Pi_LcnId		INT,
	@Pi_TranDate		DateTime,
	@Pi_TranQty		Numeric(38,0),
	@Pi_UsrId		INT,
	@Pi_ErrNo		INT	OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UpdateProductBatchLocation
* PURPOSE	: To Update ProductBatchLocation 
* CREATED	: Thrinath
* CREATED DATE	: 05/01/2007
* NOTE		: General SP for Updating ProductBatchLocation
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
	
*********************************/ 
SET NOCOUNT ON
Begin
	Declare @sSql as VARCHAR(2500)
	Declare @FldName as VARCHAR(100)
	Declare @StkChkFldName as VARCHAR(100)
	Declare @ErrNo as INT
	DECLARE @LastTranDate 	DATETIME
	IF EXISTS (SELECT PrdId FROM Product Where PrdId = @Pi_PrdId and PrdType = 3)
	BEGIN
		--IF Product is a KIT Item Return True
		Set @Pi_ErrNo = 0
		RETURN
	END
	BEGIN TRY --Code added by Muthuvel for Inventory check
		IF NOT EXISTS (SELECT PrdId FROM ProductBatchLocation Where PrdId = @Pi_PrdId
			and PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId)
		BEGIN
			INSERT INTO ProductBatchLocation
			(
				LcnId,PrdId,PrdBatId,PrdBatLcnSih,PrdBatLcnUih,PrdBatLcnfre,
				PrdBatLcnResSih,PrdBatLcnResUih,PrdBatLcnResFre,
				Availability,LastModBy,LastModDate,AuthId,AuthDate
			) VALUES
			(
				@Pi_LcnId,@Pi_PrdId,@Pi_PrdBatId,0,0,0,
				0,0,0,
				1,@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate
			)
		END
		Select @FldName = CASE @Pi_ColId WHEN 1 THEN 'PrdBatLcnSih'
			WHEN 2 THEN 'PrdBatLcnUih'
			WHEN 3 THEN 'PrdBatLcnfre'
			WHEN 4 THEN 'PrdBatLcnResSih'
			WHEN 5 THEN 'PrdBatLcnResUih'
			WHEN 6 THEN 'PrdBatLcnResFre' END
		Select @StkChkFldName = CASE @Pi_ColId - 3 WHEN 1 THEN 'PrdBatLcnSih'
			WHEN 2 THEN 'PrdBatLcnUih'
			WHEN 3 THEN 'PrdBatLcnfre' END
		SET @Pi_ErrNo = 0
		IF @Pi_Type = 2 
		BEGIN
			Create Table #CheckStock 
			(	
				PrdId int
			)
			
			SET @sSql = ' Insert Into #CheckStock (Prdid) '
			SET @sSql = @sSql + 'Select Prdid From ProductBatchLocation Where'
			SET @sSql = @sSql + ' PrdId = ' + CAST(@Pi_PrdId as VARCHAR(10))
			SET @sSql = @sSql + ' AND PrdBatId = ' + CAST(@Pi_PrdBatId as VARCHAR(10))
			SET @sSql = @sSql + ' AND LcnId = ' + CAST(@Pi_LcnId as VARCHAR(10))
			SET @sSql = @sSql + ' AND '  + @FldName + ' < ' + CAST(@Pi_TranQty as VARCHAR(10))
			
			Exec (@sSql)
			IF Exists(Select * From #CheckStock)
			BEGIN
				SET @Pi_ErrNo = 1
			END
		
			DROP TABLE #CheckStock 
		END
		IF @Pi_Type = 1 AND @Pi_ColId > 3
		BEGIN
			Create Table #CheckStock1 
			(	
				prdid int
			)
			
			SET @sSql = ' Insert Into #CheckStock1 (Prdid) '
			SET @sSql = @sSql + 'Select Prdid From ProductBatchLocation Where'
			SET @sSql = @sSql + ' PrdId = ' + CAST(@Pi_PrdId as VARCHAR(10))
			SET @sSql = @sSql + ' AND PrdBatId = ' + CAST(@Pi_PrdBatId as VARCHAR(10))
			SET @sSql = @sSql + ' AND LcnId = ' + CAST(@Pi_LcnId as VARCHAR(10))
			SET @sSql = @sSql + ' AND ' + @StkChkFldName + ' < ' + @FldName + ' + ' 
			SET @sSql = @sSql + CAST(@Pi_TranQty as VARCHAR(10))
		
			Exec (@sSql)
			IF Exists(Select * From #CheckStock1)
			BEGIN
				SET @Pi_ErrNo = 1
			END
		
			DROP TABLE #CheckStock1 
		END
		IF @Pi_ErrNo = 0
		BEGIN
			SET @sSql = 'Update ProductBatchLocation Set ' + @FldName + ' = ' + @FldName + ' + '
			SET @sSql = @sSql + CASE @Pi_Type WHEN 2 Then '-1' Else '1' End + '* ' 
			SET @sSql = @sSql + CAST(@Pi_TranQty as VARCHAR(10)) 
			SET @sSql = @sSql + ', LastModDate = ''' + CONVERT(VARCHAR(10),GetDate(),121) + ''''
			SET @sSql = @sSql + ', AuthDate = ''' + CONVERT(VARCHAR(10),GetDate(),121) + ''''
			SET @sSql = @sSql + ', LastModBy = ' + CAST(@Pi_UsrId as VARCHAR(10))
			SET @sSql = @sSql + ', AuthId = ' + CAST(@Pi_UsrId as VARCHAR(10)) + ' Where'
			SET @sSql = @sSql + ' PrdId = ' + CAST(@Pi_PrdId as VARCHAR(10))
			SET @sSql = @sSql + ' AND PrdBatId = ' + CAST(@Pi_PrdBatId as VARCHAR(10))
			SET @sSql = @sSql + ' AND LcnId = ' + CAST(@Pi_LcnId as VARCHAR(10))
		
			Exec (@sSql)
		End
	/*Code added by Muthuvel for Inventory check begins here*/		
	END TRY
	BEGIN CATCH
		SET @Pi_ErrNo = 1
	END CATCH	
	/*Code added by Muthuvel for Inventory check ends here*/	
--print @Pi_ErrNo
RETURN
END
GO
IF EXISTS(SELECT * FROM sysobjects WHERE name = 'Proc_UpdateStockLedger' AND xtype='P')  
DROP PROCEDURE Proc_UpdateStockLedger
GO
--EXEC Proc_UpdateStockLedger 7,1,1519,5299,1,'2014-08-20',8,2,0
CREATE Procedure Proc_UpdateStockLedger
(
	@Pi_ColId   INT,
	@Pi_Type  INT,
	@Pi_PrdId  INT,
	@Pi_PrdBatId  INT,
	@Pi_LcnId  INT,
	@Pi_TranDate  DateTime,
	@Pi_TranQty  Numeric(38,0),
	@Pi_UsrId  INT,
	@Pi_ErrNo  INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_UpdateStockLedger
* PURPOSE	: To Update StockLedger
* CREATED	: Thrinath
* CREATED DATE	: 05/01/2007
* NOTE		: General SP for Updating StockLedger
* MODIFIED BY : Boopathy On 23/03/2009 For Updating the Con
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	Declare @sSql as VARCHAR(2500)
	Declare @FldName as VARCHAR(100)
	Declare @ErrNo as INT
	DECLARE @LastTranDate  DATETIME
	DECLARE @OldValue	AS NUMERIC(38,6)
	DECLARE @MaxDate AS DATETIME
	DECLARE @CurVal	 AS NUMERIC(38,6)
	IF EXISTS (SELECT PrdId FROM Product Where PrdId = @Pi_PrdId and PrdType = 3)
	BEGIN
		--IF Product is a KIT Item Return True
		Set @Pi_ErrNo = 0
		RETURN
	END
	BEGIN TRY --Code added by Muthuvel for Inventory check
		SELECT @OldValue=SUM(((B.SalPurchase+B.UnsalPurchase)-(B.SalSales+B.UnSalSales)+
				(-B.SalPurReturn-B.UnsalPurReturn+B.SalStockIn+B.UnSalStockIn-
				B.SalStockOut-B.UnSalStockOut+B.SalSalesReturn+B.UnSalSalesReturn+
				B.SalStkJurIn+B.UnSalStkJurIn-B.SalStkJurOut-B.UnSalStkJurOut+
				B.SalBatTfrIn+B.UnSalBatTfrIn-B.SalBatTfrOut-B.UnSalBatTfrOut+
				B.SalLcnTfrIn+B.UnSalLcnTfrIn-B.SalLcnTfrOut-B.UnSalLcnTfrOut+
				B.SalReplacement+B.DamageIn-B.DamageOut)) * PrdBatDetailValue) --AS StkValue
				FROM ProductBatchDetails A, StockLedger B,BatchCreation C 
				WHERE A.PrdBatId=B.PrdbatId AND A.DefaultPrice=1
				AND A.BatchSeqId=C.BatchSeqId AND C.ListPrice=1 AND A.SlNo=C.SlNo
				AND B.TransDate=@Pi_TranDate AND B.PrdId=@Pi_PrdId AND B.PrdBatId=@Pi_PrdBatId
				AND B.LcnId=@Pi_LcnId
		SET @OldValue =ISNULL(@OldValue,0)
		IF NOT EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
		and PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
		and TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121))
		BEGIN
			INSERT INTO StockLedger
			(
			TransDate,LcnId,PrdId,PrdBatId,SalOpenStock,UnSalOpenStock,
			OfferOpenStock,SalPurchase,UnsalPurchase,OfferPurchase,
			SalPurReturn,UnsalPurReturn,OfferPurReturn,
			SalSales,UnSalSales,OfferSales,SalStockIn,UnSalStockIn,
			OfferStockIn,SalStockOut,UnSalStockOut,OfferStockOut,DamageIn,
			DamageOut,SalSalesReturn,UnSalSalesReturn,OfferSalesReturn,
			SalStkJurIn,UnSalStkJurIn,OfferStkJurIn,SalStkJurOut,
			UnSalStkJurOut,OfferStkJurOut,SalBatTfrIn,UnSalBatTfrIn,
			OfferBatTfrIn,SalBatTfrOut,UnSalBatTfrOut,OfferBatTfrOut,
			SalLcnTfrIn,UnSalLcnTfrIn,OfferLcnTfrIn,SalLcnTfrOut,
			UnSalLcnTfrOut,OfferLcnTfrOut,SalReplacement,OfferReplacement,
			SalClsStock,UnSalClsStock,OfferClsStock,Availability,
			LastModBy,LastModDate,AuthId,AuthDate
			) VALUES
			(
			@Pi_TranDate,@Pi_LcnId,@Pi_PrdId,@Pi_PrdBatId,0,0,
			0,0,0,0,
			0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,1,
			@Pi_UsrId,@Pi_TranDate,@Pi_UsrId,@Pi_TranDate
			)
		 END
		 EXEC Proc_UpdateOpeningStock @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,@Pi_UsrId,@ErrNo
		 IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 2)
		 BEGIN
			UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 2
		 END
		
		 IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 11)
		 BEGIN
			UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 11
		 END
		 IF @Pi_ColId BETWEEN 7 AND 9
		 BEGIN
			IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 1)
			BEGIN
				UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 1
			END
		 END
		 IF @Pi_ColId BETWEEN 1 AND 3
		 BEGIN
			IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 3)
			BEGIN
				UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 3
			END
		 END
		 IF @Pi_ColId BETWEEN 18 AND 20
		 BEGIN
			IF EXISTS (SELECT * FROM DayEndProcess WHERE NextUpDate > @Pi_TranDate AND ProcId = 4)
			BEGIN
				UPDATE DayEndProcess SET NextUpDate = @Pi_TranDate WHERE ProcId = 4
			END
		 END
		 Select @FldName = CASE @Pi_ColId
			  WHEN 1 THEN 'SalPurchase'
			  WHEN 2 THEN 'UnsalPurchase'
			  WHEN 3 THEN 'OfferPurchase'
			  WHEN 4 THEN 'SalPurReturn'
			  WHEN 5 THEN 'UnsalPurReturn'
			  WHEN 6 THEN 'OfferPurReturn'
			  WHEN 7 THEN 'SalSales'
			  WHEN 8 THEN 'UnSalSales'
			  WHEN 9 THEN 'OfferSales'
			  WHEN 10 THEN 'SalStockIn'
			  WHEN 11 THEN 'UnSalStockIn'
			  WHEN 12 THEN 'OfferStockIn'
			  WHEN 13 THEN 'SalStockOut'
			  WHEN 14 THEN 'UnSalStockOut'
			  WHEN 15 THEN 'OfferStockOut'
			  WHEN 16 THEN 'DamageIn'
			  WHEN 17 THEN 'DamageOut'
			  WHEN 18 THEN 'SalSalesReturn'
			  WHEN 19 THEN 'UnSalSalesReturn'
			  WHEN 20 THEN 'OfferSalesReturn'
			  WHEN 21 THEN 'SalStkJurIn'
			  WHEN 22 THEN 'UnSalStkJurIn'
			  WHEN 23 THEN 'OfferStkJurIn'
			  WHEN 24 THEN 'SalStkJurOut'
			  WHEN 25 THEN 'UnSalStkJurOut'
			  WHEN 26 THEN 'OfferStkJurOut'
			  WHEN 27 THEN 'SalBatTfrIn'
			  WHEN 28 THEN 'UnSalBatTfrIn'
			  WHEN 29 THEN 'OfferBatTfrIn'
			  WHEN 30 THEN 'SalBatTfrOut'
			  WHEN 31 THEN 'UnSalBatTfrOut'
			  WHEN 32 THEN 'OfferBatTfrOut'
			  WHEN 33 THEN 'SalLcnTfrIn'
			  WHEN 34 THEN 'UnSalLcnTfrIn'
			  WHEN 35 THEN 'OfferLcnTfrIn'
			  WHEN 36 THEN 'SalLcnTfrOut'
			  WHEN 37 THEN 'UnSalLcnTfrOut'
			  WHEN 38 THEN 'OfferLcnTfrOut'
			  WHEN 39 THEN 'SalReplacement'
			  WHEN 40 THEN 'OfferReplacement' END
		 SET @Pi_ErrNo = 0
		 IF (@Pi_ColId = 4  OR @Pi_ColId = 7  OR @Pi_ColId = 13
			 OR @Pi_ColId = 24 OR @Pi_ColId = 30 OR @Pi_ColId = 36 OR @Pi_ColId = 39) AND @Pi_Type = 1
		 BEGIN
			  IF EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
			   AND PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
			   AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
			   AND (SalOpenStock    +
					SalPurchase     +
					SalStockIn    +
					SalSalesReturn   +
					SalStkJurIn   +
					SalBatTfrIn   +
					SalLcnTfrIn   -
					SalPurReturn   -
					SalSales     -
					SalStockOut  -	
					SalStkJurOut   -
					SalBatTfrOut   -
					SalLcnTfrOut   -
					SalReplacement) < @Pi_TranQty)
				  BEGIN
					   SET @Pi_ErrNo = 1
				  END
		 END
		 IF (@Pi_ColId = 5 OR @Pi_ColId = 8 OR @Pi_ColId = 14 OR @Pi_ColId = 17
			 OR @Pi_ColId = 25 OR @Pi_ColId = 31 OR @Pi_ColId = 37) AND @Pi_Type = 1
		 BEGIN
			  IF EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
			   AND PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
			   AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
			   AND (UnSalOpenStock    +
					UnSalPurchase   +
					UnSalStockIn    +
					DamageIn      +
					UnSalSalesReturn  +
					UnSalStkJurIn    +
					UnSalBatTfrIn   +
					UnSalLcnTfrIn    -
					UnsalPurReturn  -
					UnSalSales   -
					UnSalStockOut   -
					DamageOut    -
					UnSalStkJurOut   -
					UnSalBatTfrOut   -
					UnSalLcnTfrOut) < @Pi_TranQty)
				  BEGIN
					   SET @Pi_ErrNo = 1
				  END
		 END
		 IF (@Pi_ColId = 6 OR @Pi_ColId = 9 OR @Pi_ColId = 15 OR @Pi_ColId = 26
			  OR @Pi_ColId = 32 OR @Pi_ColId = 38 OR @Pi_ColId = 40) AND @Pi_Type = 1
		 BEGIN
			  IF EXISTS (SELECT PrdId FROM StockLedger Where PrdId = @Pi_PrdId
			   AND PrdBatId = @Pi_PrdBatId and LcnId = @Pi_LcnId
			   AND TransDate = CONVERT(VARCHAR(10),@Pi_TranDate,121)
			   AND (OfferOpenStock    +
					OfferPurchase    +
					OfferStockIn     +
					OfferSalesReturn   +
					OfferStkJurIn   +
					OfferBatTfrIn   +
					OfferLcnTfrIn   -
					OfferPurReturn   -
					OfferSales      -
					OfferStockOut   -
					OfferStkJurOut   -
					OfferBatTfrOut   -
					OfferLcnTfrOut   -
					OfferReplacement) < @Pi_TranQty)
				  BEGIN
					   SET @Pi_ErrNo = 1
				  END
		 END
		 IF @Pi_ErrNo = 0
		 BEGIN
			  SET @sSql = 'Update StockLedger Set ' + @FldName + ' = ' + @FldName + ' + '
			  SET @sSql = @sSql + CASE @Pi_Type WHEN 2 Then '-1' Else '1' End + '* '
			  SET @sSql = @sSql + CAST(@Pi_TranQty as VARCHAR(10))
			  SET @sSql = @sSql + ', LastModDate = ''' + CONVERT(VARCHAR(10),GetDate(),121) + ''''
			  SET @sSql = @sSql + ', AuthDate = ''' + CONVERT(VARCHAR(10),GetDate(),121) + ''''
			  SET @sSql = @sSql + ', LastModBy = ' + CAST(@Pi_UsrId as VARCHAR(10))
			  SET @sSql = @sSql + ', AuthId = ' + CAST(@Pi_UsrId as VARCHAR(10)) + ' Where'
			  SET @sSql = @sSql + ' PrdId = ' + CAST(@Pi_PrdId as VARCHAR(10))
			  SET @sSql = @sSql + ' AND PrdBatId = ' + CAST(@Pi_PrdBatId as VARCHAR(10))
			  SET @sSql = @sSql + ' AND LcnId = ' + CAST(@Pi_LcnId as VARCHAR(10))
			  SET @sSql = @sSql + ' AND TransDate = ''' + CONVERT(VARCHAR(10),@Pi_TranDate,121) + ''''
			  Exec (@sSql)
		
			  EXEC Proc_UpdateClosingStock @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,@Pi_UsrId,@Pi_ClsErrNo = @ErrNo OutPut
			  IF @Pi_ErrNo = 0 AND @ErrNo = 1
			  BEGIN
				   Set @Pi_ErrNo = 1
			  END
			  Select @LastTranDate = ISNULL(MAX(TransDate),CONVERT(VARCHAR(10),'1981-05-30',121)) from
			   StockLedger where PrdId=@Pi_PrdId and PrdBatId=@Pi_PrdBatId
			   and LcnId=@Pi_LcnId and TransDate > @Pi_TranDate
			  IF @LastTranDate <> '1981-05-30'
			  BEGIN
				   SELECT @Pi_TranDate = DATEADD(DAY,1,@Pi_TranDate)
				   WHILE @Pi_TranDate <= @LastTranDate
				   BEGIN
						EXEC Proc_UpdateOpeningStock @Pi_PrdId,@Pi_PrdBatId,@Pi_LcnId,@Pi_TranDate,@Pi_UsrId,@Pi_OpnErrNo = @ErrNo OutPut
						SELECT @Pi_TranDate = DATEADD(DAY,1,@Pi_TranDate)
						IF @Pi_ErrNo = 0 AND @ErrNo = 1
						BEGIN
							 Set @Pi_ErrNo = 1
						END
				   END
			  END
	 			IF EXISTS (SELECT TransDate FROM ConsolidateStockLedger WHERE 
							TransDate=@Pi_TranDate)
				BEGIN
							SELECT @CurVal=SUM(((B.SalPurchase+B.UnsalPurchase)-(B.SalSales+B.UnSalSales)+
							(-B.SalPurReturn-B.UnsalPurReturn+B.SalStockIn+B.UnSalStockIn-
							B.SalStockOut-B.UnSalStockOut+B.SalSalesReturn+B.UnSalSalesReturn+
							B.SalStkJurIn+B.UnSalStkJurIn-B.SalStkJurOut-B.UnSalStkJurOut+
							B.SalBatTfrIn+B.UnSalBatTfrIn-B.SalBatTfrOut-B.UnSalBatTfrOut+
							B.SalLcnTfrIn+B.UnSalLcnTfrIn-B.SalLcnTfrOut-B.UnSalLcnTfrOut+
							B.SalReplacement+B.DamageIn-B.DamageOut)) * PrdBatDetailValue) --AS StkValue
							FROM ProductBatchDetails A, StockLedger B,BatchCreation C 
							WHERE A.PrdBatId=B.PrdbatId AND A.DefaultPrice=1
							AND A.BatchSeqId=C.BatchSeqId AND C.ListPrice=1 AND A.SlNo=C.SlNo
							AND B.TransDate=@Pi_TranDate AND B.PrdId=@Pi_PrdId AND B.PrdBatId=@Pi_PrdBatId
							AND B.LcnId=@Pi_LcnId
							UPDATE ConsolidateStockLedger SET StockValue=  StockValue + ABS(@OldValue) - ABS(@CurVal) ---(@CurStkVal*-1)
							WHERE TransDate=@Pi_TranDate
				
							UPDATE ConsolidateStockLedger SET StockValue=  StockValue + ABS(@OldValue)  - ABS(@CurVal) --(@CurStkVal*-1)
							WHERE TransDate>@Pi_TranDate
				END
				ELSE
				BEGIN
					INSERT INTO ConsolidateStockLedger
						SELECT @Pi_TranDate,ISNULL((@Pi_TranQty * PrdBatDetailValue),0) AS StkValue
						FROM ProductBatchDetails A, StockLedger B,BatchCreation C 
						WHERE A.PrdBatId=B.PrdbatId AND A.DefaultPrice=1
						AND A.BatchSeqId=C.BatchSeqId AND C.ListPrice=1 AND A.SlNo=C.SlNo
						AND B.TransDate=@Pi_TranDate AND B.PrdId=@Pi_PrdId AND B.PrdBatId=@Pi_PrdBatId
						AND B.LcnId=@Pi_LcnId
						SELECT @CurVal=StockValue FROM ConsolidateStockLedger WHERE TransDate=@Pi_TranDate
						SELECT @MaxDate=MAX(TransDate) FROM ConsolidateStockLedger WHERE TransDate<@Pi_TranDate
						UPDATE ConsolidateStockLedger SET StockValue=  @CurVal + (SELECT StockValue FROM
						ConsolidateStockLedger WHERE TransDate=@MaxDate) WHERE TransDate=@Pi_TranDate
				END
		END

	/*Code added by Muthuvel for Inventory check begins here*/
	END TRY
	BEGIN CATCH
		SET @Pi_ErrNo = 1
	END CATCH
	/*Code added by Muthuvel for Inventory check ends here*/
	IF @Pi_ErrNo = 0
	BEGIN
		IF NOT EXISTS(SELECT * FROM StockLedgerDateCheck WHERE LastTransDate>=@Pi_TranDate)
		BEGIN
			TRUNCATE TABLE StockLedgerDateCheck 
			INSERT INTO StockLedgerDateCheck(LastColId,LastTransDate)
			VALUES(@Pi_ColId,@Pi_TranDate)
		END	
	END
	RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_RptDayEndCollection' AND XTYPE='P')
DROP  PROCEDURE Proc_RptDayEndCollection
GO
--EXEC Proc_RptDayEndCollection 248,2,0,'RECOVERY',0,0,1
CREATE PROCEDURE Proc_RptDayEndCollection
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
		DECLARE @ErrNo	 	AS	INT
	DECLARE @FromDate	   AS	DATETIME
	DECLARE @ToDate	 	   AS	DATETIME
	DECLARE @VehicleId     AS  INT
	DECLARE @VehicleAllocId AS	INT
	DECLARE @SMId	 	AS	INT
	DECLARE @DlvRouteId	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @TotBillAmount	AS	NUMERIC(38,6)
	
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	SET @VehicleId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId))
	SET @VehicleAllocId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId))
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @DlvRouteId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	Create TABLE #RptCollectionDetail
	(
		vehNo				varchar(100),
		SalId 				BIGINT,
		SalInvNo			NVARCHAR(50),
		SalInvDate			DATETIME,
		SalInvRef 			NVARCHAR(50),
		RtrId 				INT,
		RtrName				NVARCHAR(50),
		BillAmount			NUMERIC (38,6),
		CrAdjAmount			NUMERIC (38,6),
		DbAdjAmount			NUMERIC (38,6),
		CashDiscount		NUMERIC (38,6),
		CollectedAmount		NUMERIC (38,6),
		BalanceAmount		NUMERIC (38,6),
		PayAmount			NUMERIC (38,6),
		TotalBillAmount		NUMERIC (38,6),
		--AmtStatus 			NVARCHAR(10),
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
		[AdjustedAmt]		NUMERIC (38,6),
		InvRcpNo			nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Remarks				VARCHAR(1000)
	)
	EXEC Proc_CollectionValues_Parle @FromDate,@ToDate
		
		INSERT INTO #RptCollectionDetail (vehNo,SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		BillAmount,CrAdjAmount,DbAdjAmount,CashDiscount,CollectedAmount,
		BalanceAmount,PayAmount,TotalBillAmount,InvRcpDate,CurPayAmount,CollCashAmt,CollChqAmt,CollDDAmt,CollRTGSAmt,AdjustedAmt
		,InvRcpNo,Remarks)
		SELECT VehicleCode,SalId,SalInvNo,SalInvDate,SalInvRef,RtrId,RtrName,
		dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CashDiscount,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollectedAmount,@Pi_CurrencyId),
		ABS(dbo.Fn_ConvertCurrency(BillAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId))
		AS BalanceAmount,dbo.Fn_ConvertCurrency(PayAmount,@Pi_CurrencyId),0 AS TotalBillAmount,
		R.InvRcpDate,dbo.Fn_ConvertCurrency(CurPayAmount,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollCashAmt,@Pi_CurrencyId),
		dbo.Fn_ConvertCurrency(CollChqAmt,@Pi_CurrencyId),dbo.Fn_ConvertCurrency(CollDDAmt,@Pi_CurrencyId)
		,dbo.Fn_ConvertCurrency(CollRTGSAmt,@Pi_CurrencyId),
		ABS(dbo.Fn_ConvertCurrency(CrAdjAmount,@Pi_CurrencyId)-dbo.Fn_ConvertCurrency(DbAdjAmount,@Pi_CurrencyId))
		,R.InvRcpNo,R.Remarks
		FROM RptCollectionValue_Parle R
		INNER JOIN VehicleAllocationDetails VD on VD.SaleInvNo=R.SalInvNo
		INNER JOIN VehicleAllocationMaster VM on VM.AllotmentNumber=VD.AllotmentNumber
		INNER JOIN VEhicle V on V.VehicleId=VM.VehicleId
		WHERE 
		(V.VehicleId = (CASE @VehicleId WHEN 0 THEN V.VehicleId ELSE 0 END) OR
					V.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
		
		AND (AllotmentId = (CASE @VehicleAllocId WHEN 0 THEN AllotmentId ELSE 0 END) OR
					AllotmentId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
		AND 
		(SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
		SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))) 
		AND 
		(DlvRMId=(CASE @DlvRouteId WHEN 0 THEN DlvRMId ELSE 0 END) OR
		DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
		AND 
		(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
		RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
		
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
	
	SELECT vehno,SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
	BillAmount,CurPayAmount,CrAdjAmount,DbAdjAmount,CashDiscount,
	ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,
	CashBill,Chequebill,DDBill,RTGSBill,AdjustedAmt,[TotalBills] FROM #RptCollectionDetail ORDER BY SalId,InvRcpDate,InvRcpNo
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptDayEndCollection_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptDayEndCollection_Excel
		SELECT vehno,SalId,SalInvNo,SalInvDate,SalInvRef,InvRcpNo,InvRcpDate,RtrId,RtrName,
		BillAmount,CurPayAmount,AdjustedAmt,CashDiscount,CrAdjAmount,DbAdjAmount,
		ISNULL(CollCashAmt,0) AS CollCashAmt,ISNULL(CollChqAmt,0) AS CollChqAmt,ISNULL(CollDDAmt,0) AS CollDDAmt,ISNULL(CollRTGSAmt,0) AS CollRTGSAmt,
		BalanceAmount,CollectedAmount,TotalBillAmount,PayAmount,
		CashBill,Chequebill,DDBill,RTGSBill,[TotalBills] into RptDayEndCollection_Excel FROM #RptCollectionDetail 
		ORDER BY vehno,InvRcpDate		
	END
RETURN
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RptProductWise]') AND type in (N'U'))
DROP TABLE [RptProductWise]
GO
CREATE TABLE RptProductWise
(
	[SalId] [int] NULL,
	[SalInvDate] [datetime] NULL,
	[RtrId] [int] NULL,
	[SMId] [int] NULL,
	[RMId] [int] NULL,
	[CmpId] [int] NULL,
	[LcnId] [int] NULL,
	[PrdCtgValMainId] [int] NULL,
	[CmpPrdCtgId] [int] NULL,
	[PrdId] [int] NULL,
	[PrdDCode] [varchar](100) NULL,
	[PrdName] [varchar](200) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [varchar](50) NULL,
	[PrdUnitMRP] [numeric](38, 6) NULL,
	[PrdUnitSelRate] [numeric](38, 6) NULL,
	[FreeQty] [int] NULL,
	[RepQty] [int] NULL,
	[ReturnQty] [int] NULL,
	[SalesQty] [int] NULL,
	[SalesGrossValue] [numeric](38, 6) NULL,
	[TaxAmount] [numeric](38, 6) NULL,
	[ReturnGrossValue] [numeric](38, 6) NULL,
	[NetAmount] [numeric](38, 6) NULL,
	[DlvSts] [int] NULL,
	[RptId] [int] NULL,
	[UsrId] [int] NULL,
	[SalesPrdWeight] [numeric](38, 6) NULL,
	[FreePrdWeight] [numeric](38, 6) NULL,
	[RepPrdWeight] [numeric](38, 6) NULL,
	[RetPrdWeight] [numeric](38, 6) NULL,
	[SchemeValue] [numeric](38, 6) NULL,
	[SalesReturn] [numeric](38, 6) NULL,
	[MarketReturn] [numeric](38, 6) NULL
) ON [PRIMARY]
GO
DELETE FROM RptExcelHeaders WHERE RptId =2
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,1,'PrdId','PrdId',0,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,2,'PrdDCode','Product Code',1,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,3,'PrdName','Product Name',1,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,4,'PrdBatId','PrdBatId',0,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,5,'PrdBatCode','Batch Code',1,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,6,'MrpRate','MRP',1,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,7,'SellingRate','Selling Rate',1,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,8,'SalesQty','Sales Qty',1,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,9,'SalesPrdWeight','Sales Qty in volume',0,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,10,'Uom1','Cases',0,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,11,'Uom2','Boxes',0,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,12,'Uom3','Strips',0,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,13,'Uom4','Pieces',0,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,14,'FreeQty','Free Qty',1,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,15,'FreePrdWeight','Free Qty in volume',0,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,16,'ReplaceQty','Replace Qty',1,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,17,'RepPrdWeight','Replacement Qty in volume',0,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,18,'ReturnQty','Return Qty',1,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,19,'RetPrdWeight','Return Qty in volume',0,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,20,'SalesValue','Gross Amount',1,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,21,'SalesReturn','Sales Return',1,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,22,'MarketReturn','Market Return',1,1)
GO
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (2,23,'NetAmount','Net Amount',1,1)
GO
DELETE FROM RptFormula WHERE Rptid=2
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,1,'ProductCode','Product Code',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,2,'ProductName','Product Name',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,3,'BatchNo','Batch Code',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,4,'MRP','MRP',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,5,'SellingRate','Selling Rate',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,6,'SalesQuantity','Sales Qty',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,7,'FreeQuantity','Free Qty',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,8,'ReplacementQuantity','Rep. Qty',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,9,'SalesValue','Gross Amt',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,10,'FromDate','From Date',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,11,'ToDate','To Date',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,12,'Company','Company',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,13,'Salesman','Salesman',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,14,'Route','Route',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,15,'Retailer','Retailer',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,16,'ProductCategoryLevel','Product Hierarchy Level',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,17,'ProductCategoryValue','Product Hierarchy Level Value',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,18,'BillNumber','Bill Number',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,19,'Total','Grand Total ',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,20,'Disp_FromDate','FromDate',1,10)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,21,'Disp_ToDate','ToDate',1,11)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,22,'Disp_Company','Company',1,4)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,23,'Disp_Salesman','Salesman',1,1)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,24,'Disp_Route','Route',1,2)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,25,'Disp_Retailer','Retailer',1,3)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,26,'Disp_ProductCategoryLevel','ProductCategoryLevel',1,16)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,27,'Disp_ProductCategoryValue','ProductCategoryLevelValue',1,21)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,28,'Disp_BillNumber','BillNumber',1,14)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,29,'Cap Page','Page',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,30,'Cap User Name','User Name',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,31,'Cap Print Date','Date',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,32,'Cap_Product','Product',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,33,'Disp_Product','Product',1,5)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,34,'Disp_Cancelled','Display Cancelled Bill Value',1,193)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,35,'Fill_Cancelled','Display Cancelled Product Value',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,36,'Cap_RetailerGroup','Retailer Group',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,37,'Disp_RetailerGroup','Retailer Group',1,215)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,38,'Cap_Location','Location',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,39,'Disp_Location','Location',1,22)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,40,'Cap_Batch','Batch',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,41,'Disp_Batch','Batch',1,7)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,42,'ReturnQuantity','Ret.Qty',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,43,'SalesReturn','SalesRet.',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,44,'NetAmount','Net Amount',1,0)
GO
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (2,45,'MarketReturn','MarketRet.',1,0)
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name ='Proc_ProductWiseSalesOnly' AND xtype='P') 
DROP PROCEDURE [Proc_ProductWiseSalesOnly]
GO
--EXEC Proc_ProductWiseSalesOnly 2,1
--SELECT * FROM RptProductWise (NOLOCK)
CREATE PROCEDURE Proc_ProductWiseSalesOnly
(
	@Pi_RptId   INT,
	@Pi_UsrId   INT
)
/************************************************************
* PROC			: Proc_ProductWiseSalesOnly
* PURPOSE		: To get the Product details
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 18/02/2010
* NOTE			:
* MODIFIED		:
* DATE        AUTHOR   DESCRIPTION
14-09-2009   Mahalakshmi.A     BugFixing for BugNo : 20625
------------------------------------------------
* {date}		{developer}		{brief modification description}
* 18/11/2013	Jisha Mathew	Bug No : 29578
* 22/08/2014    Selvichitra		Added SalesReturn and MarketReturn Column
****************************************************************************/
AS
BEGIN
	DECLARE @FromDate AS DATETIME
	DECLARE @ToDate   AS DATETIME
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	
	DELETE FROM RptProductWise WHERE RptId= @Pi_RptId And UsrId IN(0,@Pi_UsrId)
	
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
		CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
		FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SalesReturn,MarketReturn)
	SELECT  SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		SIP.PrdId, P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SIP.SalManFreeQty AS FreeQty,0 AS RepQty,0 AS ReturnQty,
		SIP.BaseQty AS SalesQty,SIP.PrdGrossAmount,SIP.PrdTaxAmount,0 AS ReturnGrossValue,DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,PrdNetAmount,((P.PrdWgt*SIP.BaseQty)/1000),
		((P.PrdWgt*SIP.SalManFreeQty)/1000),0,0,0,0
	FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceProduct SIP WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
	WHERE SIP.SalId=SI.SalId AND P.PrdId=SIP.PrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SIP.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId  AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
		
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
		CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
		FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SalesReturn,MarketReturn)
	SELECT  SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SSF.FreeQty AS FreeQty,0 AS RepQty,
		0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossAmount,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts---@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,((P.PrdWgt*SSF.FreeQty)/1000),0,0,0,0
	FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceSchemeDtFreePrd SSF WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
	WHERE SSF.SalId=SI.SalId  AND P.PrdId=SSF.FreePrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SSF.FreePrdBatId
		AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
		
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
		CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
		FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SalesReturn,MarketReturn)
	SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		SSF.GiftQty AS FreeQty,0 AS RepQty,
		0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossAmount,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,((P.PrdWgt*SSF.GiftQty)/1000),0,0,0,0
	FROM SalesInvoice SI WITH (NOLOCK),SalesInvoiceSchemeDtFreePrd SSF WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
	WHERE SSF.SalId=SI.SalId AND P.PrdId=SSF.GiftPrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=SSF.GiftPrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Replacement Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
		CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
		FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SalesReturn,MarketReturn)
	SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		REO.RepQty,0 AS ReturnQty,0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,((P.PrdWgt*REO.RepQty)/1000),0,0,0
	FROM SalesInvoice SI WITH (NOLOCK),ReplacementOut REO WITH (NOLOCK),
		ReplacementHd RE WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
	WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo <>'RetReplacement'
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
	--Replacement Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
		CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
		FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SalesReturn,MarketReturn)
	SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		0 AS RepQty,REO.RtnQty,0 AS SalesQty,0 AS SalesGrossValue,0 AS TaxAmount,REO.RtnAmount AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,0,((P.PrdWgt*REO.RtnQty)/1000),0,0
	FROM SalesInvoice SI WITH (NOLOCK),ReplacementIn REO WITH (NOLOCK),
		ReplacementHd RE WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
		WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo ='RetReplacement'
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
		
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
		CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
		FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SalesReturn,MarketReturn)
	SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,
		P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,0 AS FreeQty,
		REO.RepQty,0 AS ReturnQty,0 AS SalesQty,REO.RepAmount AS SalesGrossValue,REO.Tax AS TaxAmount,0 AS ReturnGrossValue,SI.DlvSts--@
		,@Pi_RptId AS RptID ,@Pi_UsrId AS UsrId,0 AS NetAmount,0,0,((P.PrdWgt*REO.RepQty)/1000),0,0,0
	FROM SalesInvoice SI WITH (NOLOCK),ReplacementOut REO WITH (NOLOCK),
		ReplacementHd RE WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK)
	WHERE RE.SalId=SI.SalId  AND P.PrdId=REO.PrdId AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=REO.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND RE.RepRefNo=REO.RepRefNo AND REO.CNRRefNo ='RetReplacement'
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate
		
	--Return Quantity
	INSERT INTO RptProductWise (SalId,SalInvDate,RtrId,SMId,RMId,CmpId,LcnId,PrdCtgValMainId,
		CmpPrdCtgId,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PrdUnitMRP,PrdUnitSelRate,
		FreeQty ,RepQty ,ReturnQty,SalesQty,SalesGrossValue,TaxAmount,ReturnGrossValue,DlvSts,RptId,UsrId,NetAmount,
		SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SalesReturn,MarketReturn)
	SELECT SI.SalId,SI.SalInvDate,SI.RtrId,SI.SMId,SI.RMId,P.CmpId,SI.LcnId,P.PrdCtgValMainId,PC.CmpPrdCtgId,
		P.PrdId, P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,
		PSD.PrdBatDetailValue AS PrdUnitMRP,
		PBD.PrdBatDetailValue AS PrdUnitSelRate,
		0 AS FreeQty,0 AS RepQty,RP.BaseQty AS ReturnQty,
		0 AS SalesQty,0 AS SalesGrossValue,/*-1 * (RP.PrdGrossAmt) AS SalesGrossValue,*/
		0 AS TaxAmount,RP.PrdGrossAmt,SI.DlvSts--@
		,@Pi_RptId AS RptId,@Pi_UsrId AS UsrId,-1*PrdNetAmt,0,0,0,((P.PrdWgt*RP.BaseQty)/1000),RP.PrdGrossAmt,SI.MarketRetAmount
	FROM SalesInvoice SI WITH (NOLOCK),
		Product P WITH (NOLOCK),
		ProductBatch PB WITH (NOLOCK),
		ProductCategoryValue PC WITH (NOLOCK),
		BatchCreation BC WITH (NOLOCK),
		BatchCreation BCS WITH (NOLOCK),
		ProductBatchDetails PBD WITH (NOLOCK),
		ProductBatchDetails PSD WITH (NOLOCK),
		ReturnHeader RH WITH (NOLOCK),
		ReturnProduct RP WITH (NOLOCK)
	WHERE SI.SalId=RH.SalId AND RH.ReturnId=RP.ReturnId AND P.PrdId=RP.PrdId
		AND PB.PrdId=P.PrdId
		AND PB.PrdBatId=RP.PrdBatId AND P.PrdCtgValMainId=PC.PrdCtgValMainId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.SlNo =BC.SlNo
		AND BC.BatchSeqId=PB.BatchSeqId AND BC.SelRte=1
		AND PB.PrdBatId=PSD.PrdBatId AND PSD.SlNo =BCS.SlNo
		AND BCS.BatchSeqId=PB.BatchSeqId AND BCS.MRP=1
		AND PBD.PriceId=PB.DefaultPriceId
		AND PSD.PriceId=PB.DefaultPriceId
		AND SI.SalInvDate BETWEEN @FromDate AND @ToDate

END
--Till Here Amul Changes
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name ='Proc_RptProductWiseSales' AND xtype='P')  
DROP PROCEDURE [Proc_RptProductWiseSales]
GO
--EXEC Proc_RptProductWiseSales 2,1,0,'Parle_New',0,0,1
CREATE PROCEDURE Proc_RptProductWiseSales
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
/********************************************************************
* VIEW	: Proc_RptProductWiseSales
* PURPOSE	: To get the Product details 
* CREATED BY	: MarySubashini.S
* CREATED DATE	: 18/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
----------------------------------------------------------------------
* {date}		{developer}		{brief modification description}
* 24-11-2009	Thiruvengadam	Added new SP Proc_LSProductWiseSales
* 22-08-2014    Selvichitra		Added Salesreturn amd Marketreturn column
*****************************************************************************/
BEGIN

SET NOCOUNT ON

	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	NVARCHAR(50)
	DECLARE @TblName 	AS	NVARCHAR(500)
	DECLARE @TblStruct 	AS	NVARCHAR(4000)
	DECLARE @TblFields 	AS	NVARCHAR(4000)
	DECLARE @sSql		AS 	NVARCHAR(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	NVARCHAR(50)
	
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @CmpId 		AS	INT
	DECLARE @LcnId 		AS	INT
	DECLARE @SMId 		AS	INT
	DECLARE @RMId 		AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdBatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @SalId	 	AS	BIGINT
	DECLARE @CancelValue	AS	INT
	DECLARE @BillStatus	AS	INT
	DECLARE @GridFlag AS INT

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @PrdBatId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	SET @CancelValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,193,@Pi_UsrId))
	SET @BillStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,192,@Pi_UsrId))
	
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))

	Create TABLE #RptProductWiseDetail
	(
				PrdId 			BIGINT,
				PrdDcode		NVARCHAR(50),
				PrdName			NVARCHAR(100),
				PrdBatId 		INT,
				PrdBatCode              NVARCHAR(50),
				MrpRate           	NUMERIC (38,6),
				SellingRate  		NUMERIC (38,6),
				SalesQty      	 	INT,
				FreeQty  		INT,
				ReplaceQty		INT,
				ReturnQty       INT,
				SalesValue		NUMERIC (38,6),	
				[SalesPrdWeight] NUMERIC(38,6),
				[FreePrdWeight] NUMERIC(38,6),
				[RepPrdWeight] NUMERIC(38,6),
				[RetPrdWeight] NUMERIC(38,6),
				[SalesReturn] NUMERIC(38,6),
				[MarketReturn] NUMERIC(38,6),
				[NetAmount] NUMERIC(38,6)
	)

	SET @TblName = 'RptProductWiseDetail'
	
	SET @TblStruct = '	PrdId 			BIGINT,
				PrdDcode		NVARCHAR(50),
				PrdName			NVARCHAR(100),
				PrdBatId 		INT,
				PrdBatCode      NVARCHAR(50),
				MrpRate         NUMERIC (38,6),
				SellingRate  	NUMERIC (38,6),
				SalesQty      	INT,
				FreeQty  		INT,
				ReplaceQty		INT,
				ReturnQty       INT,
				SalesValue		NUMERIC (38,6),
				[SalesPrdWeight] NUMERIC(38,6),
				[FreePrdWeight] NUMERIC(38,6),
				[RepPrdWeight] NUMERIC(38,6),
				[RetPrdWeight] NUMERIC(38,6),
				[SalesReturn] NUMERIC(38,6),
				[MarketReturn] NUMERIC(38,6),
				[NetAmount] NUMERIC(38,6)'
	
	SET @TblFields = 'PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
			  MrpRate,SellingRate,SalesQty,FreeQty,
			  ReplaceQty,ReturnQty,SalesValue,SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,Salesreturn,MarketReturn,NetAmount'
			  
	
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
		EXEC Proc_ProductWiseSalesOnly @Pi_RptId,@Pi_UsrId
		IF @CancelValue=2 
		BEGIN
			INSERT INTO #RptProductWiseDetail (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
					MrpRate,SellingRate,SalesQty,FreeQty,ReplaceQty,ReturnQty,SalesValue,
					SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SalesReturn,MarketReturn,NetAmount)
			SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(PrdUnitMrp,@Pi_CurrencyId),
				dbo.Fn_ConvertCurrency(PrdUnitSelRate,@Pi_CurrencyId),SUM(SalesQty),SUM(FreeQty),
				SUM(RepQty)AS ReplaceQty,SUM(ReturnQty)AS ReturnQty,dbo.Fn_ConvertCurrency(SUM(SalesGrossValue),@Pi_CurrencyId),
				SUM(SalesPrdWeight),SUM(FreePrdWeight),SUM(RepPrdWeight),SUM(RetPrdWeight),SUM(SalesReturn),SUM(MarketReturn),SUM(SalesGrossValue-SalesReturn-MarketReturn) AS NetAmount
			FROM RptProductWise 
			WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
				AND (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
					CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			
				AND 
				(LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
					LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))

				AND 
				(SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
					SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND 
				(RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
					RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) 
				AND
				(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR
					RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				AND
			
				(PrdId = (CASE @PrdCatId WHEN 0 THEN PrdId Else 0 END) OR
					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
				AND 
				(PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR
					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND 
				(PrdBatId = (CASE @PrdBatId WHEN 0 THEN PrdBatId Else 0 END) OR
					PrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				AND
				(SalId = (CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
					SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))) 
				AND SalInvDate BETWEEN @FromDate AND @ToDate
			GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMrp,PrdUnitSelRate--,
				--SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight
		END
		ELSE IF @CancelValue=1
		BEGIN
			INSERT INTO #RptProductWiseDetail (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
					MrpRate,SellingRate,SalesQty,FreeQty,ReplaceQty,ReturnQty,SalesValue,
					SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight,SalesReturn,MarketReturn,NetAmount)
			SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(PrdUnitMrp,@Pi_CurrencyId),
				dbo.Fn_ConvertCurrency(PrdUnitSelRate,@Pi_CurrencyId),SUM(SalesQty),SUM(FreeQty),
				SUM(RepQty)AS ReplaceQty,SUM(ReturnQty)AS ReturnQty,dbo.Fn_ConvertCurrency(SUM(SalesGrossValue),@Pi_CurrencyId),
				SUM(SalesPrdWeight),SUM(FreePrdWeight),SUM(RepPrdWeight),SUM(RetPrdWeight),SUM(SalesReturn),SUM(MarketReturn),SUM(SalesGrossValue-SalesReturn-MarketReturn) AS NetAmount
			FROM RptProductWise 
			WHERE RptId=@Pi_RptId AND UsrId=@Pi_UsrId
				AND (CmpId = (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END) OR
				CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				AND 
					(LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR
					LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND 
				(SMId = (CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR
				SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				AND 
				(RMId = (CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR
				RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))) 
				AND
				(RtrId = (CASE @RtrId WHEN 0 THEN RtrId ELSE 0 END) OR	
				RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				AND
			
				(PrdId = (CASE @PrdCatId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
				AND 
				(PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR
				PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))

				AND 
				(PrdBatId = (CASE @PrdBatId WHEN 0 THEN PrdBatId Else 0 END) OR
				PrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				AND
				(SalId = (CASE @SalId WHEN 0 THEN SalId ELSE 0 END) OR
				SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))) 

				AND (DlvSts=(CASE @BillStatus WHEN 0 THEN DlvSts ELSE 0 END) OR
					DlvSts NOT IN(3))

				AND SalInvDate BETWEEN @FromDate AND @ToDate
			GROUP BY PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,PrdUnitMrp,PrdUnitSelRate--,
			--SalesPrdWeight,FreePrdWeight,RepPrdWeight,RetPrdWeight
		END	
	
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptProductWiseDetail ' + 
				'(' + @TblFields + ')' + 
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName 
				+ ' WHERE RptId=' + CAST(@Pi_RptId AS nVarchar(10)) + ' AND UsrId=' + CAST(@Pi_UsrId AS nVarchar(10)) + '' 
				+ 'AND 	(CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
				+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (LcnId = (CASE ' + CAST(@LcnId AS nVarchar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR ' 
				+ 'LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',22,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR ' 
				+ 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '
				+ 'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '
				+ 'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
				+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR '
				+ 'PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdBatId = (CASE ' + CAST(@PrdBatId AS nVarchar(10)) + ' WHEN 0 THEN PrdBatId Else 0 END) OR '
				+ 'PrdBatId in (SELECT iCountid from Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',7,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (SalId = (CASE ' + CAST(@SalId AS nVarchar(10)) + ' WHEN 0 THEN SalId ELSE 0 END) OR '
				+ 'SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + 
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',14,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND SalInvDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
			EXEC (@SSQL)
			Print @SSQL
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptProductWiseDetail'
				
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
			SET @SSQL = 'INSERT INTO #RptProductWiseDetail ' + 
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptProductWiseDetail
	WHERE (SalesQty>0 OR FreeQty>0 OR ReplaceQty>0)
	SELECT * FROM #RptProductWiseDetail
	-- Till Here		
	SELECT @GridFlag=GridFlag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @GridFlag=1
	BEGIN
			--	SELECT * FROM #RptProductWiseDetail   
			-- Added on 20-Jun-2009
			SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MrpRate,A.SellingRate,A.SalesQty,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(A.SalesQty AS INT)>=nullif(ConverisonFactor2,0) Then CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			(CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/Isnull(ConverisonFactor2,0)*Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
			CASE 
				WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
					Case When 
							CAST(A.SalesQty AS INT)-(((CAST(A.SalesQty AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
			CAST(A.SalesQty AS INT)-(((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
			ELSE
				CASE 
					WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
						Case
							When CAST(Sum(A.SalesQty) AS INT)>=Isnull(ConverisonFactor2,0) Then
								CAST(Sum(A.SalesQty) AS INT)%nullif(ConverisonFactor2,0)
							Else CAST(Sum(A.SalesQty) AS INT) End
					WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
						Case
							When CAST(Sum(A.SalesQty) AS INT)>=Isnull(ConverisonFactor3,0) Then
								CAST(Sum(A.SalesQty) AS INT)%nullif(ConverisonFactor3,0)
							Else CAST(Sum(A.SalesQty) AS INT) End			
				ELSE CAST(Sum(A.SalesQty) AS INT) END
			END as Uom4,
			--Case When CAST(A.SalesQty AS INT)>nullif(ConverisonFactor2,0) Then CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End As Uom1,
			--Case When (CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End as Uom2,
			--Case When (CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			--(CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End as Uom3,
			--Case When CAST(A.SalesQty AS INT)-(((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			--(((CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
			--CAST(A.SalesQty AS INT)-(((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			--(((CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End as Uom4,
			A.FreeQty,A.ReplaceQty,A.SalesValue
			FROM #RptProductWiseDetail A, View_ProdUOMDetails B WHERE a.prdid=b.prdid 
			GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MrpRate,A.SellingRate,A.SalesQty,
			ConverisonFactor2,ConverisonFactor3,ConverisonFactor4,ConversionFactor1,A.FreeQty,A.ReplaceQty,A.SalesValue

			--- Added on 26-Jun-2009
			SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MrpRate,A.SellingRate,A.SalesQty,
			Case When CAST(A.SalesQty AS INT)>nullif(ConverisonFactor2,0) Then CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0) Else 0 End As Uom1,
			Case When (CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End as Uom2,
			Case When (CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			(CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End as Uom3,
			Case When CAST(A.SalesQty AS INT)-(((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
			CAST(A.SalesQty AS INT)-(((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(A.SalesQty AS INT)-((CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(A.SalesQty AS INT)-(CAST(A.SalesQty AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End as Uom4,
			A.FreeQty,A.ReplaceQty,A.SalesValue INTO #RptProductWiseDetailGrid
			FROM #RptProductWiseDetail A, View_ProdUOMDetails B WHERE a.prdid=b.prdid 

			DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId  
			INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,Rptid,Usrid)  
			SELECT PrdDcode,PrdName,PrdBatCode,MrpRate,SellingRate,SalesQty,Uom1,Uom2,Uom3,Uom4,FreeQty,ReplaceQty,SalesValue,@Pi_RptId,@Pi_UsrId  
			FROM #RptProductWiseDetailGrid  
			--- End here on 26-Jun-2009
			-- End Here
	END
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptProductWiseDetail_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptProductWiseDetail_Excel
		SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MrpRate,
				SellingRate,SalesQty,SalesPrdWeight,0 AS UOM1,0 AS UOM2,0 AS UOM3,0 AS UOM4,
				FreeQty,FreePrdWeight,ReplaceQty,RepPrdWeight,ReturnQty,RetPrdWeight,SalesValue,Salesreturn,MarketReturn,
				(SalesValue-(Salesreturn+MarketReturn)) AS NetAmount INTO RptProductWiseDetail_Excel FROM #RptProductWiseDetail
	END 
	
RETURN
END
GO
--Bulk Batch Transfer
DELETE FROM MenuDef WHERE MenuId = 'mInv12'
INSERT INTO MenuDef (SrlNo,MenuId,MenuName,ParentId,Caption,MenuStatus,FormName,DefaultCaption)
SELECT 198,'mInv12','mnuBatchTransferNew','mInv','Bulk Batch Transfer',0,'FrmBatchTransferNew','Bulk Batch Transfer'
GO
DELETE FROM ProfileDt WHERE MenuId = 'mInv12'
INSERT INTO ProfileDt (PrfId,MenuId,BtnIndex,BtnDescription,BtnStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
SELECT DISTINCT PrfId,'mInv12',0,'New',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD (NOLOCK) UNION
SELECT DISTINCT PrfId,'mInv12',1,'Edit',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD (NOLOCK) UNION
SELECT DISTINCT PrfId,'mInv12',2,'Save',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD (NOLOCK) UNION
SELECT DISTINCT PrfId,'mInv12',3,'Delete',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD (NOLOCK) UNION
SELECT DISTINCT PrfId,'mInv12',6,'Print',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD (NOLOCK) UNION
SELECT DISTINCT PrfId,'mInv12',7,'Save & Confirm',1,1,1,GETDATE(),1,GETDATE() FROM ProfileHD (NOLOCK)
GO
IF NOT EXISTS (SELECT * FROM COUNTERS WHERE TABNAME ='BatchTransferHD')
BEGIN
	INSERT INTO COUNTERS 
	SELECT 'BatchTransferHD','BatRefNo','BAT',5,1,0,'Batch Transfer',1,2014,1,1,GETDATE(),1,GETDATE()
END
GO
DELETE FROM HotSearchEditorHD WHERE FormId=10169
INSERT INTO HotSearchEditorHD
SELECT 10169,'Batch Transfer','ReferenceNumber','select','SELECT BatRefNo,Status FROM BatchTransferHD (NOLOCK) WHERE Availability=1'
GO
DELETE FROM CustomCaptions WHERE TransId=14 and CtrlId=28
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (14,28,1,'DgCommon-14-28-1','Press F4/Double Click to Select Product','','',1,1,1,'2014-09-05',1,'2014-09-05','Press F4/Double Click to Select Product','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (14,28,2,'DgCommon-14-28-2','Press F4/Double Click to Select Product','','',1,1,1,'2014-09-05',1,'2014-09-05','Press F4/Double Click to Select Product','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (14,28,3,'DgCommon-14-28-3','Stock Type','','',1,1,1,'2014-09-05',1,'2014-09-05','Stock Type','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (14,28,4,'DgCommon-14-28-4','Press F4/Double Click to Select From Batch','','',1,1,1,'2014-09-05',1,'2014-09-05','Press F4/Double Click to Select From Batch','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (14,28,5,'DgCommon-14-28-5','Press F4/Double Click to Select To Batch','','',1,1,1,'2014-09-05',1,'2014-09-05','Press F4/Double Click to Select To Batch','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (14,28,6,'DgCommon-14-28-6','Available Quantity(Read Only)','','',1,1,1,'2014-09-05',1,'2014-09-05','Available Quantity(Read Only)','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (14,28,7,'DgCommon-14-28-7','Enter Transfer Quantity','','',1,1,1,'2014-09-05',1,'2014-09-05','Enter Transfer Quantity','','',1,1)
GO
DELETE FROM HotSearchEditorDt WHERE FormId=10169
INSERT INTO HotSearchEditorDt
SELECT 1,10169,'ReferenceNumber','Reference Number','BatRefNo',4500,0,'HotSch-14-2000-1',14
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='BatchTransferHD' AND XTYPE='U')
CREATE TABLE BatchTransferHD
(
	[BatRefNo] [nvarchar](25) NOT NULL,
	[BatTrfDate] [datetime] NOT NULL,
	[CmpId] [int] NOT NULL,
	[LcnId] [int] NOT NULL,
	[CmpPrdCtgId] [int] NULL,
	[PrdCtgValMainId] [int] NULL,
	[ReasonId] [int] NOT NULL,
	[DocRefNo] [nvarchar](25) NULL,
	[Remarks] [nvarchar](250) NULL,
	[Status] [tinyint] NULL,
	[Availability] [tinyint] NULL,
	[LastModBy] [tinyint] NULL,
	[LastModDate] [datetime] NULL,
	[AuthId] [tinyint] NULL,
	[AuthDate] [datetime] NULL,
 CONSTRAINT [PK_BatRefNo] PRIMARY KEY CLUSTERED 
(
	[BatRefNo] ASC
))
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='BatchTransferDT' AND XTYPE='U')
CREATE TABLE BatchTransferDT
(
	[BatRefNo] [nvarchar](25) NOT NULL,
	[PrdId] [int] NOT NULL,
	[StockType] [int] NOT NULL,
	[FrmBatId] [int] NOT NULL,
	[ToBatId] [int] NOT NULL,
	[AvailableQty] [bigint] NOT NULL,
	[TransferQty] [bigint] NOT NULL,
	[FromPriceId] [bigint] NULL,
	[ToPriceId] [bigint] NULL,
	[Availability] [tinyint] NULL,
	[LastModBy] [tinyint] NULL,
	[LastModDate] [datetime] NULL,
	[AuthId] [tinyint] NULL,
	[AuthDate] [datetime] NULL
)
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS  WHERE NAME='FK_BatRefNo' AND XTYPE='F' )
BEGIN
	ALTER TABLE [dbo].[BatchTransferDT]  WITH CHECK ADD  CONSTRAINT [FK_BatRefNo] FOREIGN KEY([BatRefNo])
	REFERENCES [dbo].[BatchTransferHD] ([BatRefNo])
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Tbl_LatestBatchProduct' AND XTYPE='U')
DROP TABLE Tbl_LatestBatchProduct
GO
CREATE TABLE Tbl_LatestBatchProduct
(
	[PrdId] [int] NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [nvarchar](100) NULL,
	[MRP] [numeric](18, 6) NULL,
	[PurchaseRate] [numeric](18, 6) NULL,
	[SellingRate] [numeric](18, 6) NULL,
	[DefaultPriceId] [int] NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Tbl_FillAllProduct' AND XTYPE='U')
DROP TABLE Tbl_FillAllProduct
GO
CREATE TABLE Tbl_FillAllProduct
(
	[PrdId] [int] NULL,
	[PrdDCode] [nvarchar](100) NULL,
	[PrdCCode] [nvarchar](100) NULL,
	[PrdName] [nvarchar](200) NULL,
	[PrdShrtName] [nvarchar](200) NULL,
	[SPMId] [int] NULL,
	[PrdBatId] [int] NULL,
	[StockAvailable] [int] NULL,
	[PrdBatCode] [nvarchar](100) NULL,
	[MRP] [numeric](18, 6) NULL,
	[PurchaseRate] [numeric](18, 6) NULL,
	[SellingRate] [numeric](18, 6) NULL,
	[StockTypeId] [int] NULL,
	[StockType] [nvarchar](50) NULL,
	[DefaultPriceId] [int] NULL
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='PROC_AutoFillProduct' AND XTYPE='P')
DROP PROCEDURE PROC_AutoFillProduct
GO
--EXEC PROC_AutoFillProduct 1,1,1
CREATE PROCEDURE PROC_AutoFillProduct
(
	@pCmpID INT,
	@pLcnID INT,
	@pPrdCtgID As INT
)	
AS
BEGIN
/*****************************************************************************
* PROCEDURE: PROC_AutoFillProduct
* PURPOSE: To automatically Fill Products While Batch Transfer CR CCRSTLOR0017
* NOTES:
* CREATED: Jisha Mathew 15-07-2013
* MODIFIED
* DATE			     AUTHOR			             DESCRIPTION
-----------------------------------------------------------------------------
* 2013-11-21    SATHISHKUMAR VEERAMANI       Unsalable,Offer Stocks are Included
******************************************************************************/
	TRUNCATE TABLE Tbl_FillAllProduct
	TRUNCATE TABLE Tbl_LatestBatchProduct
	--IF @pPrdCtgID = 0 SET @pPrdCtgID = NULL
	
	SELECT P.PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,SPMId INTO #ProductHD
	FROM ProductCategoryValue PCV1 
	INNER JOIN ProductCategoryValue PCV2 ON PCV2.PrdCtgValLinkCode LIKE (CAST(PCV1.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%') 
	INNER JOIN Product P ON P.PrdCtgValMainId = PCV2.PrdCtgValMainId AND P.PrdStatus=1 
		AND P.PrdType<>3 AND PCV1.PrdCtgValMainId=CASE @pPrdCtgID WHEN 0 THEN P.PrdCtgValMainId ELSE @pPrdCtgID END
	INNER JOIN ProductBatch PB ON P.PrdId = PB.PrdId AND PB.Status=1 
	INNER JOIN ProductBatchLocation PBL ON P.PrdId = PBL.PrdId AND PBL.LcnId = @pLcnID 
	GROUP BY P.PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,SPMId HAVING COUNT(PB.PrdBatId)>1
	
	SELECT PB.PrdID,PB.PrdBatId INTO #ProductDT	FROM ProductBatch PB (NOLOCK)
	INNER JOIN ProductBatchLocation PBL (NOLOCK) ON PB.PrdID = PBL.PrdID AND PB.PrdBatID = PBL.PrdBatId
	WHERE PBL.LcnId = @pLcnID AND PB.Status = 1 
	GROUP BY PB.PrdID,PB.PrdBatId,PBL.PrdBatLcnSih,PBL.PrdBatLcnRessih,PBL.PrdBatLcnUih,PBL.PrdBatLcnResUih,PBL.PrdBatLcnFre,PBL.PrdBatLcnResFre
	HAVING ((ISNULL(PBL.PrdBatLcnSih,0)- ISNULL(PBL.PrdBatLcnRessih,0))+(ISNULL(PBL.PrdBatLcnUih,0)- ISNULL(PBL.PrdBatLcnResUih,0))+
	(ISNULL(PBL.PrdBatLcnFre,0)- ISNULL(PBL.PrdBatLcnResFre,0))) > 0 ORDER BY PB.PrdID
	
	----ProductBatchDetails	
    SELECT P.PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,SPMId,MS.PrdBatId,PrdBatCode,MRP,PurchaseRate,SellingRate,DefaultPriceId INTO #PrdBatDetails FROM(
	SELECT PB.PrdID,PB.PrdBatId,PrdBatCode,PD1.PrdBatDetailValue AS MRP,
	PD2.PrdBatDetailValue AS PurchaseRate,PD3.PrdBatDetailValue AS SellingRate,PB.DefaultPriceId
	FROM ProductBatch PB (NOLOCK),ProductBatchLocation PBL (NOLOCK),ProductbatchDetails PD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),  
	ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)
	WHERE PB.PrdBatId = PBL.PrdBatId AND PBL.LcnId = @pLcnID AND PB.Status = 1 AND PB.PrdBatId=PD1.PrdBatId   
	AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1    
	AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1 AND PD2.SlNo =BC2.SlNo    
	AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1 AND PB.PrdBatId=PD3.PrdBatId 
	AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId 
	AND BC3.SelRte=1) MS
	INNER JOIN #ProductHD P WITH (NOLOCK) ON MS.PrdId = P.PrdId
	INNER JOIN (SELECT DISTINCT PrdID,PrdBatId As PrdBatID FROM #ProductDT) PD ON MS.PrdId = PD.PrdID AND P.PrdId = PD.PrdID 
		AND MS.PrdBatId = PD.PrdBatID
	ORDER BY P.PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName
	
	--Added by Sathishkumar Veeramani 2013/11/21
	INSERT INTO Tbl_FillAllProduct(PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,SPMId,PrdBatId,StockAvailable,PrdBatCode,
	MRP,PurchaseRate,SellingRate,StockTypeId,Stocktype,DefaultPriceId)
	SELECT DISTINCT PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,SPMId,PrdBatId,StockAvailable,PrdBatCode,MRP,
	PurchaseRate,SellingRate,StockTypeId,Stocktype,DefaultPriceId FROM(
	--Saleable Stock
    SELECT A.PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,SPMId,A.PrdBatId,ISNULL(SUM(PrdBatLcnSih),0)- ISNULL(SUM(PrdBatLcnRessih),0) AS StockAvailable,
    PrdBatCode,MRP,PurchaseRate,SellingRate,StockTypeId,UserStockType AS StockType,DefaultPriceId FROM #PrdBatDetails A WITH (NOLOCK) 
    INNER JOIN ProductBatchLocation B WITH (NOLOCK) ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatID
    INNER JOIN StockType C WITH (NOLOCK) ON B.LcnId = C.LcnId AND SystemStockType = 1 WHERE B.LcnId = @pLcnID
    GROUP BY A.PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,SPMId,A.PrdBatId,PrdBatCode,MRP,PurchaseRate,SellingRate,StockTypeId,UserStockType,DefaultPriceId 
    HAVING ISNULL(SUM(PrdBatLcnSih),0)- ISNULL(SUM(PrdBatLcnRessih),0) > 0
    --Unsalable Stock
    UNION
    SELECT A.PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,SPMId,A.PrdBatId,ISNULL(SUM(PrdBatLcnUih),0)- ISNULL(SUM(PrdBatLcnResUih),0) AS StockAvailable,
    PrdBatCode,MRP,PurchaseRate,SellingRate,StockTypeId,UserStockType AS StockType,DefaultPriceId FROM #PrdBatDetails A WITH (NOLOCK) 
    INNER JOIN ProductBatchLocation B WITH (NOLOCK) ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatID
    INNER JOIN StockType C WITH (NOLOCK) ON B.LcnId = C.LcnId AND SystemStockType = 2 WHERE B.LcnId = @pLcnID 
    GROUP BY A.PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,SPMId,A.PrdBatId,PrdBatCode,MRP,PurchaseRate,SellingRate,StockTypeId,UserStockType,DefaultPriceId 
    HAVING ISNULL(SUM(PrdBatLcnUih),0)- ISNULL(SUM(PrdBatLcnResUih),0) > 0 
    --Offer Stock 
    UNION
    SELECT A.PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,SPMId,A.PrdBatId,ISNULL(SUM(PrdBatLcnFre),0)- ISNULL(SUM(PrdBatLcnResFre),0) AS StockAvailable,
    PrdBatCode,MRP,PurchaseRate,SellingRate,StockTypeId,UserStockType AS StockType,DefaultPriceId FROM #PrdBatDetails A WITH (NOLOCK) 
    INNER JOIN ProductBatchLocation B WITH (NOLOCK) ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatID
    INNER JOIN StockType C WITH (NOLOCK) ON B.LcnId = C.LcnId AND SystemStockType = 3 WHERE B.LcnId = @pLcnID 
    GROUP BY A.PrdId,PrdDCode,PrdCCode,PrdName,PrdShrtName,SPMId,A.PrdBatId,PrdBatCode,MRP,PurchaseRate,SellingRate,StockTypeId,UserStockType,DefaultPriceId 
    HAVING ISNULL(SUM(PrdBatLcnFre),0)- ISNULL(SUM(PrdBatLcnResFre),0) > 0 
    ) A ORDER BY PrdID,PrdBatId,PrdBatCode
    --Till Here
    
	--INSERT INTO Tbl_LatestBatchProduct(PrdId,PrdBatId,PrdBatCode,MRP,PurchaseRate,SellingRate,DefaultPriceId)
	--SELECT DISTINCT T.PrdID,PD.PrdBatId,T.PrdBatCode,T.MRP,T.PurchaseRate,T.SellingRate,T.DefaultPriceId FROM
	--(SELECT PrdID,PrdBatId,PrdBatCode,MRP,PurchaseRate,SellingRate,DefaultPriceId 
	--FROM #PrdBatDetails WITH(NOLOCK)) T
	--INNER JOIN Tbl_FillAllProduct P WITH (NOLOCK) ON T.PrdId = P.PrdId
	--INNER JOIN (SELECT A.PrdID,MAX(A.PrdBatId) As PrdBatID FROM ProductBatch A LEFT OUTER JOIN ProductBatchLocation B
	--	ON A.PrdID = B.PrdID AND A.PrdBatID = B.PrdbatId AND B.LcnId = @pLcnID WHERE A.Status=1 GROUP BY A.PrdID) PD ON PD.PrdId = T.PrdId AND PD.PrdId = P.PrdID 
	--AND PD.PrdBatId = T.PrdbatId 
	--ORDER BY T.PrdID,PD.PrdBatId,T.PrdBatCode
	
	INSERT INTO Tbl_LatestBatchProduct(PrdId,PrdBatId,PrdBatCode,MRP,PurchaseRate,SellingRate,DefaultPriceId)
	SELECT DISTINCT T.PrdID,PD.PrdBatId,T.PrdBatCode,T.MRP,T.PurchaseRate,T.SellingRate,T.DefaultPriceId FROM
	(SELECT PB.PrdID,PB.PrdBatId,PrdBatCode,PD1.PrdBatDetailValue AS MRP,
	PD2.PrdBatDetailValue AS PurchaseRate,PD3.PrdBatDetailValue AS SellingRate,PB.DefaultPriceId
	FROM ProductBatch PB,ProductbatchDetails PD1 WITH (NOLOCK),BatchCreation BC1 WITH (NOLOCK),  
	ProductbatchDetails PD2 WITH (NOLOCK),BatchCreation BC2 WITH (NOLOCK),ProductbatchDetails PD3 WITH (NOLOCK),BatchCreation BC3 WITH (NOLOCK)
	WHERE PB.Status = 1 AND PB.PrdBatId=PD1.PrdBatId   
	AND PD1.DefaultPrice=1  AND PD1.SlNo =BC1.SlNo AND BC1.BatchSeqId=PB.BatchSeqId AND BC1.MRP=1    
	AND PB.PrdBatId=PD2.PrdBatId AND PD2.DefaultPrice=1 AND PD2.SlNo =BC2.SlNo    
	AND BC2.BatchSeqId=PB.BatchSeqId AND BC2.ListPrice=1 AND PB.PrdBatId=PD3.PrdBatId 
	AND PD3.DefaultPrice=1  AND PD3.SlNo =BC3.SlNo AND BC3.BatchSeqId=PB.BatchSeqId 
	AND BC3.SelRte=1) T
	INNER JOIN Tbl_FillAllProduct P WITH (NOLOCK) ON T.PrdId = P.PrdId
	INNER JOIN (SELECT A.PrdID,MAX(A.PrdBatId) As PrdBatID FROM ProductBatch A LEFT OUTER JOIN ProductBatchLocation B
		ON A.PrdID = B.PrdID AND A.PrdBatID = B.PrdbatId AND B.LcnId = @pLcnID WHERE A.Status=1 GROUP BY A.PrdID) PD ON PD.PrdId = T.PrdId AND PD.PrdId = P.PrdID 
	AND PD.PrdBatId = T.PrdbatId 
	ORDER BY T.PrdID,PD.PrdBatId,T.PrdBatCode
	
	SELECT * FROM Tbl_FillAllProduct WITH (NOLOCK) 
	SELECT * FROM Tbl_LatestBatchProduct WITH (NOLOCK)
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_RptLoadSheetItemWiseParle' AND XTYPE='P')
DROP  PROCEDURE Proc_RptLoadSheetItemWiseParle
GO
--EXEC Proc_RptLoadSheetItemWiseParle 251,1,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptLoadSheetItemWiseParle
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
* MODIFIED	:
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
Modified by Praveenraj B For Parle LoadingSheet CR On 27/01/2012
* 02/07/2013	Jisha Mathew	PARLECS/0613/008	
* 11/11/2013	Jisha Mathew	Bug No:30616
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
	--Added by Sathishkumar Veeramani 2013/04/25
	DECLARE @Prdid AS INT
	DECLARE @PrdCode AS Varchar(50)
	DECLARE @PrdBatchCode AS Varchar(50)
	DECLARE @UOMSalId AS INT
	DECLARE @BaseQty AS INT
	DECLARE @FUOMID AS INT
	DECLARE @FCONVERSIONFACTOR AS INT
	DECLARE @StockOnHand AS INT
	DECLARE @Converted AS INT
	DECLARE @Remainder AS INT
	DECLARE @COLUOM AS VARCHAR(50)
	DECLARE @Sql AS VARCHAR(5000)
	DECLARE @SlNo AS INT
	--Till Here
	--Jisha
	DECLARE @TotConverted AS INT
	DECLARE @TotRemainder AS INT	
	DECLARE @TotalQty as INT	
	--
	
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
    DECLARE @OtherCharges AS NUMERIC(18,2)   
	--DECLARE @BillNoDisp   AS INT
	--DECLARE @DispOrderby AS INT
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
	SET @ToBillNo =(SELECT  MAX(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) 
	--SET @DispOrderby=(SELECT TOP 1 iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,275,@Pi_UsrId))
	--Till Here
	--DECLARE @RPTBasedON AS INT
	--SET @RPTBasedON =0
	--SELECT @RPTBasedON = iCountId FROM Fn_ReturnRptFilters(@Pi_RptId,257,@Pi_UsrId) 
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)	
	
	CREATE TABLE #RptLoadSheetItemWiseParle1
	(
			[SalId]				  INT,
			[BillNo]			  NVARCHAR (100),
			[PrdId]        	      INT,
			[PrdBatId]			  INT,
			[Product Code]        NVARCHAR (100),
			[Product Description] NVARCHAR(150),
            [PrdCtgValMainId]	  INT, 
			[CmpPrdCtgId]		  INT,
			[Batch Number]        NVARCHAR(50),
			[MRP]				  NUMERIC (38,6) ,
			[Selling Rate]		  NUMERIC (38,6) ,
			[Billed Qty]          NUMERIC (38,0),
			[Free Qty]            NUMERIC (38,0),
			[Return Qty]          NUMERIC (38,0),
			[Replacement Qty]     NUMERIC (38,0),
			[Total Qty]           NUMERIC (38,0),
			[PrdWeight]			  NUMERIC (38,4),
			[PrdSchemeDisc]		  NUMERIC (38,2),
			[GrossAmount]		  NUMERIC (38,2),
			[TaxAmount]			  NUMERIC (38,2),
			[NetAmount]			  NUMERIC (38,2),
			[TotalBills]		  NUMERIC (38,0),
			[TotalDiscount]		  NUMERIC (38,2),
			[OtherAmt]			  NUMERIC (38,2),
			[AddReduce]			  NUMERIC (38,2),
			[Damage]              NUMERIC (38,2),
			[BX]                  NUMERIC (38,0),
			[PB]                  NUMERIC (38,0),
			[JAR]				  NUMERIC (38,0),
			[PKT]                 NUMERIC (38,0),
			[CN]				  NUMERIC (38,0),
			[GB]                  NUMERIC (38,0),
			[ROL]                 NUMERIC (38,0),
			[TOR]                 NUMERIC (38,0),
			[CTN]			      NUMERIC (38,0),
			[TIN]			      NUMERIC (38,0),
			[CAR]			      NUMERIC (38,0),
			[PC]			      NUMERIC (38,0),
			[TotalQtyBX]          NUMERIC (38,0),
			[TotalQtyPB]          NUMERIC (38,0),
			[TotalQtyPKT]         NUMERIC (38,0),
			[TotalQtyJAR]         NUMERIC (38,0),
			[TotalQtyCN]		  NUMERIC (38,0),
			[TotalQtyGB]          NUMERIC (38,0),
			[TotalQtyROL]         NUMERIC (38,0),
			[TotalQtyTOR]         NUMERIC (38,0),
			[TotalQtyCTN]         NUMERIC (38,0),
			[TotalQtyTIN]         NUMERIC (38,0),
			[TotalQtyCAR]         NUMERIC (38,0),
			[TotalQtyPC]         NUMERIC (38,0),			
	)
	
	--IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	--BEGIN
		IF @FromBillNo <> 0 Or @ToBillNo <> 0
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle1([SalId],[BillNo],[PrdId],[PrdBatId],[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
				[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
				[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[CTN],[TIN],[CAR],[PC],
				[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR],[TotalQtyCTN],
				[TotalQtyTIN],[TotalQtyCAR],[TotalQtyPC])--select * from RtrLoadSheetItemWise
	
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,
			[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),[GrossAmount],[TaxAmount],
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+Sum(PrdCDAmount)),0) AS [TotalDiscount],
			Isnull((Sum([TaxAmount])+Sum(PrdSplDiscAmount)+Sum(PrdSchDiscAmount)+Sum(PrdDBDiscAmount)+ Sum(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM RtrLoadSheetItemWise RI
			LEFT OUTER JOIN SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId
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
			 AND RI.SalId Between @FromBillNo and @ToBillNo
----	
-- AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR 
--			    RI.SalId in (Select Selvalue from ReportfilterDt Where Rptid = @Pi_RptId and Usrid =@Pi_UsrId))
	
	GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],
	NetAmount,[GrossAmount],[TaxAmount],PrdCtgValMainId,CmpPrdCtgId
		END 
		ELSE
		BEGIN
			INSERT INTO #RptLoadSheetItemWiseParle1([SalId],BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],
					[Selling Rate],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],[PrdWeight],PrdSchemeDisc,[GrossAmount],
					[TaxAmount],[NetAmount],[TotalDiscount],[OtherAmt],[AddReduce],[Damage],[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[CTN],[TIN],[CAR],[PC],
					[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR],
					[TotalQtyCTN],[TotalQtyTIN],[TotalQtyCAR],[TotalQtyPC])
			
			SELECT RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdCtgValMainId,CmpPrdCtgId,PrdBatCode,[MRP],CAST([SellingRate] AS NUMERIC(36,2)),
			BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,[PrdWeight],Isnull(SUM(PrdSchDiscAmount),0),GrossAmount,TaxAmount,
			dbo.Fn_ConvertCurrency([NetAmount],@Pi_CurrencyId),Isnull((SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [TotalDiscount],
			ISNULL((SUM([TaxAmount])+SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) As [OtherAmt],0,0,0,0,0,0,0,0,0,0,0,
			0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM RtrLoadSheetItemWise RI --select * from RtrLoadSheetItemWise
			LEFT OUTER JOIN SalesInvoiceProduct SP On SP.PrdId=RI.PrdId And SP.PrdBatId=RI.PrdBatId And RI.SalId=SP.SalId
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
					RI.SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )
		 AND [SalInvDate] BETWEEN @FromDate AND @ToDate
		
			GROUP BY RI.[SalId],SalInvNo,RI.PrdId,RI.PrdBatId,PrdDCode,PrdNAme,PrdBatCode,[MRP],[SellingRate],BillQty,FreeQty,ReturnQty,RepalcementQty,TotalQty,NetAmount,
			GrossAmount,TaxAmount,[PrdWeight],PrdCtgValMainId,CmpPrdCtgId
			ORDER BY PrdDCode
			
			  
		END 	
	
		UPDATE #RptLoadSheetItemWiseParle1 SET TotalBills=(SELECT Count(DISTINCT SalId) FROM #RptLoadSheetItemWiseParle1)
-----Added By Sathishkumar Veeramani OtherCharges
			   ---Changed By Jisha for Bug No:30616
               --SELECT @OtherCharges = SUM(OtherCharges) From SalesInvoice WHERE  SalInvDate Between @FromDate and @ToDate AND DlvSts = 2
               SELECT @OtherCharges = ISNULL((SUM(B.TaxAmount)+SUM(PrdSplDiscAmount)+SUM(PrdSchDiscAmount)+SUM(PrdDBDiscAmount)+SUM(PrdCDAmount)),0) 
               FROM SalesInvoice A WITH (NOLOCK),RtrLoadSheetItemWise B WITH (NOLOCK)
               LEFt OUTER JOIN SalesInvoiceProduct C WITH (NOLOCK) ON B.SalId = C.SalId 
				AND B.PrdId=C.PrdId And B.PrdBatId=C.PrdBatId
               WHERE A.SalId = B.SalId AND B.SalInvDate Between @FromDate and @ToDate AND DlvSts = 2 AND UsrID = @Pi_UsrId AND RptId = @Pi_RptId
               AND              
			(B.VehicleId = (CASE @VehicleId WHEN 0 THEN B.VehicleId ELSE 0 END) OR
							B.VehicleId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,36,@Pi_UsrId)) )
			
			 AND (Allotmentnumber = (CASE @VehicleAllocId WHEN 0 THEN Allotmentnumber ELSE 0 END) OR
							Allotmentnumber in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,37,@Pi_UsrId)) )
			
			 AND (B.SMId=(CASE @SMId WHEN 0 THEN B.SMId ELSE 0 END) OR
							B.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
			
			 AND (B.DlvRMId=(CASE @DlvRouteId WHEN 0 THEN B.DlvRMId ELSE 0 END) OR
							B.DlvRMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,35,@Pi_UsrId)) )
			
			 AND (B.RtrId = (CASE @RtrId WHEN 0 THEN B.RtrId ELSE 0 END) OR
							B.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)) )
			AND (@SalId = (CASE @SalId WHEN 0 THEN @SalId ELSE 0 END) OR
					B.SalId in (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)) )
							
		
               UPDATE #RptLoadSheetItemWiseParle1 SET AddReduce = @OtherCharges 
-------Added By Sathishkumar Veeramani Damage Goods Amount---------	
		 UPDATE R SET R.[Damage] = B.PrdNetAmt FROM #RptLoadSheetItemWiseParle1 R INNER JOIN
		(SELECT RH.SalId,SUM(RP.PrdNetAmt) AS PrdNetAmt,RP.PrdId,RP.PrdBatId FROM ReturnHeader RH,ReturnProduct RP 
		 WHERE RH.ReturnID  = RP.ReturnID AND RH.ReturnType = 1 GROUP BY RH.SalId,RP.PrdId,RP.PrdBatId)B
		 ON R.SalId = B.SalId AND R.PrdId = B.PrdId 
		AND R.PrdBatId = B.PrdBatId
		
		Update #RptLoadSheetItemWiseParle1 Set [Batch Number] = '',PrdBatId = 0 --Code Added by Muthuvelsamy R for DCRSTPAR0510
------Till Here--------------------		
----Added By Jisha On 02/07/2013 for PARLECS/0613/008 
SELECT 0 AS [SalId],'' AS BillNo,PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],
[Batch Number] AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],SUM([Billed Qty]) as [Billed Qty],SUM([Free Qty]) as [Free Qty],SUM([Return Qty]) as [Return Qty],
SUM([Replacement Qty]) AS [Replacement Qty],SUM([Total Qty]) AS [Total Qty],SUM(PrdWeight) AS PrdWeight,SUM(PrdSchemeDisc) AS PrdSchemeDisc,
SUM(GrossAmount) AS GrossAmount,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NetAmount,TotalBills,SUM(TotalDiscount) AS TotalDiscount,
SUM(OtherAmt) AS OtherAmt,SUM(DISTINCT AddReduce) AS Addreduce,SUM([Damage])AS [Damage],0 AS[BX],0 AS [PB],0 AS [JAR],0 AS [PKT],0 AS [CN],
0 AS [GB],0 AS [ROL],0 AS [TOR],0 AS [CTN],0 AS [TIN],0 AS [CAR],0 AS [PC],
0 AS TotalQtyBX,0 AS TotalQtyPB,0 AS TotalQtyPKT,0 AS TotalQtyJAR,0 AS [TotalQtyCN],0 AS [TotalQtyGB],0 AS [TotalQtyROL],0 AS [TotalQtyTOR],
0 AS [TotalQtyCTN],0 AS [TotalQtyTIN],0 AS [TotalQtyCAR],0 AS [TotalQtyPC]
INTO #RptLoadSheetItemWiseParle FROM #RptLoadSheetItemWiseParle1
GROUP BY PrdId,PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],[Batch Number],[MRP],TotalBills
-----

--Added by Sathishkumar Veeramani 2013/04/25		
	DECLARE CUR_UOMQTY CURSOR 
	FOR
		SELECT P.PrdId,Rpt.[Product Code],[Batch Number],SUM([Billed Qty]) AS [Billed Qty],SUM([Total Qty]) AS [Total Qty] FROM #RptLoadSheetItemWiseParle Rpt WITH (NOLOCK)
		INNER JOIN Product P WITH (NOLOCK) ON  Rpt.PrdId=P.PrdId GROUP BY P.PrdId,Rpt.[Product Code],[Batch Number]		
	OPEN CUR_UOMQTY
	FETCH NEXT FROM CUR_UOMQTY INTO @PrdId,@PrdCode,@PrdBatchCode,@BaseQty,@TotalQty
	WHILE @@FETCH_STATUS=0
	BEGIN	
			SET	@Converted=0
			SET @Remainder=0			
			SET	@TotConverted=0
			SET @TotRemainder=0				
			DECLARE CUR_UOMGROUP CURSOR
			FOR 
			SELECT DISTINCT UOMID,CONVERSIONFACTOR FROM (
			SELECT A.UOMID,CONVERSIONFACTOR FROM UOMMASTER A WITH (NOLOCK) 
			INNER JOIN UOMGROUP B WITH (NOLOCK) ON A.UomId = B.UomId INNER JOIN PRODUCT C WITH (NOLOCK)
			ON C.UOMGROUPID=B.UOMGROUPID WHERE PRDID=@PrdId AND A.UOMCODE IN ('BX','GB','CN','PB','JAR','TOR','PKT','ROL','CTN','TIN','PC','CAR')) UOM ORDER BY CONVERSIONFACTOR DESC 
			OPEN CUR_UOMGROUP
			FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR
			WHILE @@FETCH_STATUS=0
			BEGIN	
					SELECT @COLUOM=UOMCODE FROM UomMaster WITH (NOLOCK) WHERE UOMID=@FUOMID
					IF @BaseQty >= @FCONVERSIONFACTOR
					BEGIN
						SET	@Converted=CAST(@BaseQty/@FCONVERSIONFACTOR as INT)
						SET @Remainder=CAST(@BaseQty%@FCONVERSIONFACTOR AS INT)
						SET @BaseQty=@Remainder							
						
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle  SET [' + @COLUOM +']='+ CAST(ISNULL(@Converted,0) AS VARCHAR(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END	
					ELSE 	
					BEGIN
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [' + @COLUOM +']='+ CAST(0 AS VARCHAR(10)) +' WHERE [Product Code] ='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END
					----Added By Jisha On 02/07/2013 for PARLECS/0613/008 
					IF @TotalQty >= @FCONVERSIONFACTOR
					BEGIN						
						SET	@TotConverted=CAST(@TotalQty/@FCONVERSIONFACTOR as INT)
						SET @TotRemainder=CAST(@TotalQty%@FCONVERSIONFACTOR AS INT)
						SET @TotalQty=@TotRemainder								
	
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [TotalQty' + @COLUOM + ']= '+ CAST(ISNULL(@TotConverted,0) AS VARCHAR(25)) +' WHERE [Product Code]='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END	
					ELSE 	
					BEGIN
						SET @Sql='UPDATE #RptLoadSheetItemWiseParle SET [TotalQty' + @COLUOM +']='+ Cast(0 AS VARCHAR(10)) +' WHERE [Product Code] ='+''''+@PrdCode+''''+' and [Batch Number]='+ ''''+@PrdBatchCode+'''' 
						EXEC(@Sql)
					END					
					--					
			FETCH NEXT FROM CUR_UOMGROUP INTO @FUOMID,@FCONVERSIONFACTOR
			END	
			CLOSE CUR_UOMGROUP
			DEALLOCATE CUR_UOMGROUP
			SET @BaseQty=0
			SET @TotalQty=0
	FETCH NEXT FROM CUR_UOMQTY INTO @Prdid,@PrdCode,@PrdBatchCode,@BaseQty,@TotalQty
	END	
	CLOSE CUR_UOMQTY
	DEALLOCATE CUR_UOMQTY
------SELECT [PrdId],[PrdBatId],[Product Code],[Product Description],[Billed Qty],[Free Qty],[Return Qty],[Replacement Qty],[Total Qty],
------[BX],[PB],[JAR],[PKT],[CN],[GB],[ROL],[TOR],[TotalQtyBX],[TotalQtyPB],[TotalQtyPKT],[TotalQtyJAR],[TotalQtyCN],[TotalQtyGB],[TotalQtyROL],[TotalQtyTOR]
------FROM #RptLoadSheetItemWiseParle
	---Commented By Jisha on 02/07/2013 for PARLECS/0613/008
	----UPDATE A SET A.TotalQtyBX = Z.TotalBox,A.TotalQtyPB = Z.TotalPouch,A.TotalQtyPKT = Z.TotalPacks FROM #RptLoadSheetItemWiseParle A WITH (NOLOCK)
	----INNER JOIN (SELECT PrdID,PrdBatId,SUM(BX) AS TotalBox,SUM(PB)+SUM(JAR) AS TotalPouch,SUM(PKT) AS TotalPacks 
	----FROM #RptLoadSheetItemWiseParle WITH (NOLOCK)GROUP BY PrdID,PrdBatId) Z
	----ON A.PrdId = Z.PrdId AND A.PrdBatId = Z.PrdBatId
--Till Here
	--Check for Report Data
    SELECT 0 AS [SalId],'' AS BillNo,PrdId,0 AS PrdBatId,[Product Code],[Product Description],[PrdCtgValMainId],[CmpPrdCtgId],
    0 AS [Batch Number],[MRP],MAX([Selling Rate]) AS [Selling Rate],([BX]+[GB]) AS BilledQtyBox,(([PB])+([JAR]+[CN]+[TOR]+[TIN]+[CAR])) AS BilledQtyPouch,
    ([PKT]+[ROL]+[CTN]+[PC]) AS BilledQtyPack,SUM([Total Qty]) AS [Total Qty],SUM(TotalQtyBX+TotalQtyGB) AS TotalQtyBOX,
    SUM(TotalQtyPB+TotalQtyJAR+TotalQtyCN+TotalQtyTOR+TotalQtyTIN+TotalQtyCAR) AS TotalQtyPouch,SUM(TotalQtyPKT+TotalQtyROL+TotalQtyCTN+TotalQtyPC) AS TotalQtyPack,
	SUM([Free Qty]) As [Free Qty],SUM([Return Qty])As [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM([PrdWeight]) AS [PrdWeight],
	SUM([Billed Qty]) AS [Billed Qty],SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) As PrdSchemeDisc,
	SUM(TaxAmount) AS TaxAmount,SUM(NETAMOUNT) as NETAMOUNT,TotalBills,SUM([TotalDiscount]) AS [TotalDiscount],
	SUM([OtherAmt]) AS [OtherAmt],SUM([AddReduce]) As [AddReduce],SUM([Damage])AS [Damage] INTO #Result
	FROM #RptLoadSheetItemWiseParle GROUP BY PrdId,[Product Code],[Product Description],[MRP],TotalBills,[PrdCtgValMainId],[CmpPrdCtgId],
	[BX],[PB],[JAR],[PKT],[GB],[CN],[TOR],[ROL],[TIN],[CAR],[CTN],[PC]
	ORDER BY [Product Description]
	
	
					
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #Result
	SELECT [SalId],BillNo,PrdId,0 AS PrdBatId,[Product Code],[Product Description],0 AS PrdCtgValMainId,0 AS CmpPrdCtgId,0 AS [Batch Number],
	 MRP,MAX([Selling Rate]) AS [Selling Rate],
	 SUM(BilledQtyBox) AS BilledQtyBox,SUM(BilledQtyPouch) AS BilledQtyPouch,SUM(BilledQtyPack)As BilledQtyPack,SUM([Total Qty]) AS [Total Qty],
	 SUM(TotalQtyBox) AS TotalQtyBox,SUM(TotalQtyPouch) AS TotalQtyPouch,SUM(TotalQtyPack) AS TotalQtyPack,SUM([Free Qty]) AS [Free Qty],
	 SUM([Return Qty]) AS [Return Qty],SUM([Replacement Qty]) AS [Replacement Qty],SUM(PrdWeight) AS PrdWeight,SUM([Billed Qty]) AS [Billed Qty],
	 SUM(GrossAmount) AS GrossAmount,SUM(PrdSchemeDisc) AS PrdSchemeDisc,SUM(TaxAmount) AS TaxAmount,SUM(NetAmount) AS NETAMOUNT,TotalBills,
	 SUM(TotalDiscount) AS TotalDiscount,SUM(OtherAmt) AS OtherAmt,SUM(AddReduce) AS AddReduce,SUM([Damage]) AS [Damage] 
	 INTO #TempLoadingSheet FROM #Result GROUP BY [SalId],BillNo,PrdId,[Product Code],[PRoduct Description],MRP,TotalBills
	 ORDER BY [Product Code]
	 SELECT * FROM #TempLoadingSheet
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
	BEGIN
		IF EXISTS (Select [Name] From SysObjects Where [Name]='RptLoadSheetItemWiseParle_Excel' And XTYPE='U')
		Drop Table RptLoadSheetItemWiseParle_Excel
	    SELECT * INTO RptLoadSheetItemWiseParle_Excel FROM #TempLoadingSheet ORDER BY [Product Code]
	END 
END
GO
IF NOT EXISTS (SELECT FIXID FROM UpdaterLog WHERE FixId = '2053')
BEGIN
     INSERT INTO UpdaterLog (FixId,ReleaseOn,UpdateDate)
     SELECT '2053','2014-07-11',GETDATE()
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE XTYPE IN ('TF','FN') AND name = 'Fn_ReturnDlvConfigStatus')
DROP FUNCTION Fn_ReturnDlvConfigStatus
GO
--SELECT DBO.Fn_ReturnDlvConfigStatus () Holiday
CREATE FUNCTION [dbo].[Fn_ReturnDlvConfigStatus] ()
RETURNS INT
AS
/*********************************
* FUNCTION		: Fn_ReturnDlvConfigStatus
* PURPOSE		: To Return Pending Delivery Days For Auto Delivery Process
* CREATED		: Praveenraj B 
* CREATED DATE	: 10/01/2014
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*********************************/
BEGIN
		DECLARE @PendingDays INT
		DECLARE @Count AS INT
		SELECT @PendingDays=ISNULL(Condition,0) FROM Configuration WHERE ModuleName='Day End Process' AND ModuleId='DAYENDPROCESS4' AND Status=1
		--DECLARE @WKENDDAY AS VARCHAR(10)
		--DECLARE @FROMDATE AS DATETIME
		--DECLARE @TODATE AS DATETIME
		--SELECT @TODATE=CONVERT(VARCHAR(10),GETDATE(),121)
		--SELECT @FROMDATE=MAX(SALINVDATE) FROM SalesInvoice WHERE DlvSts>3
		--SELECT @WKENDDAY=UPPER(CASE WkEndDay WHEN 1 THEN 'Sunday'    
  --            WHEN 2 THEN 'Monday'    
  --            WHEN 3 THEN 'Tuesday'    
  --            WHEN 4 THEN 'Wednesday'    
  --            WHEN 5 THEN 'Thursday'    
  --            WHEN 6 THEN 'Friday'    
  --            WHEN 7 THEN 'Saturday' END) FROM JCMast WHERE JcmYr=YEAR(GETDATE())
		SET @Count=0	
		--IF EXISTS (
		--SELECT day_name,1 + DATEDIFF(wk, @FROMDATE, @TODATE) -CASE WHEN DATEPART(weekday, @FROMDATE) > day_number THEN 1 ELSE 0 END - 
		--CASE WHEN DATEPART(weekday, @TODATE)   < day_number THEN 1 ELSE 0 END AS DDD FROM (
		--SELECT 1 AS day_number, 'Monday' AS day_name UNION ALL
		--SELECT 2 AS day_number, 'Tuesday' AS day_name UNION ALL
		--SELECT 3 AS day_number, 'Wednesday' AS day_name UNION ALL
		--SELECT 4 AS day_number, 'Thursday' AS day_name UNION ALL
		--SELECT 5 AS day_number, 'Friday' AS day_name UNION ALL
		--SELECT 6 AS day_number, 'Saturday' AS day_name UNION ALL
		--SELECT 7 AS day_number, 'Sunday' AS day_name ) A WHERE UPPER(day_name)=UPPER(@WKENDDAY)
		--AND (1 + DATEDIFF(wk, @FROMDATE, @TODATE) -CASE WHEN DATEPART(weekday, @FROMDATE) > day_number THEN 1 ELSE 0 END - 
		--CASE WHEN DATEPART(weekday, @TODATE)   < day_number THEN 1 ELSE 0 END)>=1 )
		--BEGIN
		--			SELECT @Count=1 + DATEDIFF(wk, @FROMDATE, @TODATE) -CASE WHEN DATEPART(weekday, @FROMDATE) > day_number THEN 1 ELSE 0 END - 
		--			CASE WHEN DATEPART(weekday, @TODATE)   < day_number THEN 1 ELSE 0 END  FROM (
		--			SELECT 1 AS day_number, 'Monday' AS day_name UNION ALL
		--			SELECT 2 AS day_number, 'Tuesday' AS day_name UNION ALL
		--			SELECT 3 AS day_number, 'Wednesday' AS day_name UNION ALL
		--			SELECT 4 AS day_number, 'Thursday' AS day_name UNION ALL
		--			SELECT 5 AS day_number, 'Friday' AS day_name UNION ALL
		--			SELECT 6 AS day_number, 'Saturday' AS day_name UNION ALL
		--			SELECT 7 AS day_number, 'Sunday' AS day_name ) A WHERE UPPER(day_name)=UPPER(@WKENDDAY)
		--			AND (1 + DATEDIFF(wk, @FROMDATE, @TODATE) -CASE WHEN DATEPART(weekday, @FROMDATE) > day_number THEN 1 ELSE 0 END - 
		--			CASE WHEN DATEPART(weekday, @TODATE)   < day_number THEN 1 ELSE 0 END)>=1
		--END
	RETURN(@Count)
END
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 388
INSERT INTO HotSearchEditorHd(FormId,FormName,ControlName,SltString,RemainsltString)
SELECT 388,'Bulk Batch Transfer','ProductHierarchyLevelValue','Select',
'SELECT PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,PrdCtgValLinkCode 
FROM ProductCategoryValue WITH (NOLOCK)where CmpPrdCtgId = vFParam 
ORDER BY PrdCtgValMainId'
GO
DELETE FROM CustomCaptions WHERE TransId = 14 AND CtrlId = 2000 AND SubCtrlId IN (12,13,14,15,16,17,18,19,20,21,22,23,24,
25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41)
INSERT INTO CustomCaptions
SELECT 14,2000,12,'HotSch-14-2000-12','MRP','','',1,1,1,GETDATE(),1,GETDATE(),'MRP','','',1,1 UNION
SELECT 14,2000,13,'HotSch-14-2000-13','Purchase Rate','','',1,1,1,GETDATE(),1,GETDATE(),'Purchase Rate','','',1,1 UNION
SELECT 14,2000,14,'HotSch-14-2000-14','SellingRate','','',1,1,1,GETDATE(),1,GETDATE(),'SellingRate','','',1,1 UNION
SELECT 14,2000,15,'HotSch-14-2000-15','StockAvailable','','',1,1,1,GETDATE(),1,GETDATE(),'StockAvailable','','',1,1 UNION
SELECT 14,2000,16,'HotSch-14-2000-16','Batch Code','','',1,1,1,GETDATE(),1,GETDATE(),'Batch Code','','',1,1 UNION
SELECT 14,2000,17,'HotSch-14-2000-17','MRP','','',1,1,1,GETDATE(),1,GETDATE(),'MRP','','',1,1 UNION
SELECT 14,2000,18,'HotSch-14-2000-18','Purchase Rate','','',1,1,1,GETDATE(),1,GETDATE(),'Purchase Rate','','',1,1 UNION
SELECT 14,2000,19,'HotSch-14-2000-19','SellingRate','','',1,1,1,GETDATE(),1,GETDATE(),'SellingRate','','',1,1 UNION
SELECT 14,2000,20,'HotSch-14-2000-20','StockAvailable','','',1,1,1,GETDATE(),1,GETDATE(),'StockAvailable','','',1,1 UNION
SELECT 14,2000,21,'HotSch-14-2000-21','Batch Code','','',1,1,1,GETDATE(),1,GETDATE(),'Batch Code','','',1,1 UNION
SELECT 14,2000,22,'HotSch-14-2000-22','MRP','','',1,1,1,GETDATE(),1,GETDATE(),'MRP','','',1,1 UNION
SELECT 14,2000,23,'HotSch-14-2000-23','Purchase Rate','','',1,1,1,GETDATE(),1,GETDATE(),'Purchase Rate','','',1,1 UNION
SELECT 14,2000,24,'HotSch-14-2000-24','SellingRate','','',1,1,1,GETDATE(),1,GETDATE(),'SellingRate','','',1,1 UNION
SELECT 14,2000,25,'HotSch-14-2000-25','StockAvailable','','',1,1,1,GETDATE(),1,GETDATE(),'StockAvailable','','',1,1 UNION
SELECT 14,2000,26,'HotSch-14-2000-26','Batch Code','','',1,1,1,GETDATE(),1,GETDATE(),'Batch Code','','',1,1 UNION
SELECT 14,2000,27,'HotSch-14-2000-27','MRP','','',1,1,1,GETDATE(),1,GETDATE(),'MRP','','',1,1 UNION
SELECT 14,2000,28,'HotSch-14-2000-28','Purchase Rate','','',1,1,1,GETDATE(),1,GETDATE(),'Purchase Rate','','',1,1 UNION
SELECT 14,2000,29,'HotSch-14-2000-29','SellingRate','','',1,1,1,GETDATE(),1,GETDATE(),'SellingRate','','',1,1 UNION
SELECT 14,2000,30,'HotSch-14-2000-30','StockAvailable','','',1,1,1,GETDATE(),1,GETDATE(),'StockAvailable','','',1,1 UNION
SELECT 14,2000,31,'HotSch-14-2000-31','Batch Code','','',1,1,1,GETDATE(),1,GETDATE(),'Batch Code','','',1,1 UNION
SELECT 14,2000,32,'HotSch-14-2000-32','MRP','','',1,1,1,GETDATE(),1,GETDATE(),'MRP','','',1,1 UNION
SELECT 14,2000,33,'HotSch-14-2000-33','Purchase Rate','','',1,1,1,GETDATE(),1,GETDATE(),'Purchase Rate','','',1,1 UNION
SELECT 14,2000,34,'HotSch-14-2000-34','SellingRate','','',1,1,1,GETDATE(),1,GETDATE(),'SellingRate','','',1,1 UNION
SELECT 14,2000,35,'HotSch-14-2000-35','StockAvailable','','',1,1,1,GETDATE(),1,GETDATE(),'StockAvailable','','',1,1 UNION
SELECT 14,2000,36,'HotSch-14-2000-36','Batch Code','','',1,1,1,GETDATE(),1,GETDATE(),'Batch Code','','',1,1 UNION
SELECT 14,2000,37,'HotSch-14-2000-37','MRP','','',1,1,1,GETDATE(),1,GETDATE(),'MRP','','',1,1 UNION
SELECT 14,2000,38,'HotSch-14-2000-38','Purchase Rate','','',1,1,1,GETDATE(),1,GETDATE(),'Purchase Rate','','',1,1 UNION
SELECT 14,2000,39,'HotSch-14-2000-39','SellingRate','','',1,1,1,GETDATE(),1,GETDATE(),'SellingRate','','',1,1 UNION
SELECT 14,2000,40,'HotSch-14-2000-40','StockAvailable','','',1,1,1,GETDATE(),1,GETDATE(),'StockAvailable','','',1,1 UNION
SELECT 14,2000,41,'HotSch-14-2000-41','Batch Code','','',1,1,1,GETDATE(),1,GETDATE(),'Batch Code','','',1,1
GO
DELETE FROM CUSTOMCAPTIONS WHERE TRANSID=14 AND SUBCTRLID IN(44,45,46,47)
INSERT INTO CUSTOMCAPTIONS([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (14,2000,44,'HotSch-14-2000-44','Level Name','','',1,1,1,'2013-11-26',1,'2013-11-26','Level Name','','',1,1)
INSERT INTO CUSTOMCAPTIONS([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (14,2000,45,'HotSch-14-2000-45','Hierarchy Level','','',1,1,1,'2013-11-26',1,'2013-11-26','Hierarchy Level','','',1,1)
INSERT INTO CUSTOMCAPTIONS([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (14,2000,46,'HotSch-14-2000-46','Hierarchy Code','','',1,1,1,'2009-09-01',1,'2009-09-01','Hierarchy Code','','',1,1)
INSERT INTO CUSTOMCAPTIONS([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) 
VALUES (14,2000,47,'HotSch-14-2000-47','Hierarchy Name','','',1,1,1,'2009-09-01',1,'2009-09-01','Hierarchy Name','','',1,1)
GO
DELETE FROM CustomCaptions WHERE TransId = 2 AND CtrlId = 1000 AND SubCtrlId = 275
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,
LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,[Enabled])
SELECT 2,1000,275,'MsgBox-2-1000-275','','','Order Already Billed',1,1,1,GETDATE(),1,GETDATE(),'','','Order Already Billed',1,1
GO
DELETE FROM CustomCaptions WHERE TransId = 14 AND CtrlId =1000 AND SubCtrlId IN (23,24)
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,
LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,[Enabled])
SELECT 14,1000,23,'MsgBox-14-1000-23','','','Duplicate Rows not Allowed',1,1,1,GETDATE(),1,GETDATE(),'','','Duplicate Rows not Allowed',1,1 UNION
SELECT 14,1000,24,'MsgBox-14-1000-24','','','Not enough stock - save faild in stock posting',1,1,1,GETDATE(),1,GETDATE(),'','',
'Not enough stock - save faild in stock posting',1,1
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'Proc_ReturnRptRetailerCategory' AND xtype ='P')
DROP PROCEDURE Proc_ReturnRptRetailerCategory
GO
CREATE  PROCEDURE Proc_ReturnRptRetailerCategory  
(  
	@Pi_RptId   Int,  
	@Pi_UsrId   Int  
)  
AS
/*********************************  
* PROCEDURE     : Proc_ReturnRptRetailerCategory  
* PURPOSE       : General Procedure Which will Save the Retailer Category Main Id for the Selected Category  
* CREATED       : Jai Ganesh R  
* CREATED DATE  : 14/07/2014
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------  
*  
*********************************/  
BEGIN   
	
		DELETE FROM ReportFilterDt Where RptId= @Pi_RptId And UsrId = @Pi_UsrId And SelId = 50
		DECLARE @RetCatId INT
		SET @RetCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))

		INSERT INTO ReportFilterDt 
		SELECT DISTINCT @Pi_RptId,50,B.CtgMainId,'',@Pi_UsrId,'','',GETDATE()   
		FROM RetailerCategory A(NOLOCK),RetailerCategory B(NOLOCK)
		WHERE (A.CtgMainId =  (CASE @RetCatId WHEN 0 THEN A.CtgMainId ELSE 0 END) OR
		A.CtgMainId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)) )
		AND B.CtgLinkCode LIKE CAST(A.CtgLinkCode + '%' As VARCHAR(100))
		 
END
GO
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'Proc_RptECAnalysisReportParle' AND xtype='P')
DROP PROCEDURE Proc_RptECAnalysisReportParle
GO
/*
BEGIN TRANSACTION
EXEC Proc_RptECAnalysisReportParle 252,1,0,'Dabur1',0,0,3   
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_RptECAnalysisReportParle
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
/**********************************************************************************  
* PROCEDURE  : Proc_RptECAnalysisReport  
* PURPOSE  : To Generate Effective Coverage Analysis Report  
* CREATED  : Thiruvengadam.L  
* CREATED DATE : 10/09/2009  
* MODIFIED  
* DATE      AUTHOR     DESCRIPTION  
------------------------------------------------------------------------------------  
* {date}  {developer}   {brief modification description}  
* 30.09.2009    Thiruvengadam  Bug No:20729  
* 11.03.2010    Panneer        Added Excel Table  
* 14.07.2014    Jai Ganesh R   Retailer Hierarchy Filter Issue Fixed
**********************************************************************************/  
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
   
 DECLARE @RtId  AS  INT  
 DECLARE @FromDate AS DATETIME  
 DECLARE @ToDate  AS DATETIME  
 DECLARE @SMId   AS INT  
 DECLARE @RMId   AS INT  
 DECLARE @RtrId   AS INT  
 DECLARE @BasedOn AS  INT  
 DECLARE @CmpId  AS INT  
 DECLARE @RtrCtgLvl AS INT  
 DECLARE @RtrCtgLvlVal AS INT  
 DECLARE @RtrValClass AS INT  
 DECLARE @RtrGroup  AS INT  
 DECLARE @PrdHieLvl  AS INT  
 DECLARE @PrdHieLvlVal AS INT  
 DECLARE @PrdId   AS INT  
 DECLARE @PrdCatId  AS INT
 DECLARE @RetCatId  AS INT
 
 SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
 SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
 SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
 SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))  
 SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))  

 SET @RtrCtgLvl = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))  
 SET @RtrCtgLvlVal = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))  
 SET @RtrValClass = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))  
 
 SET @RtrGroup = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,215,@Pi_UsrId))   
 SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))  
 
 
 SET @PrdHieLvl = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))  
 SET @PrdHieLvlVal = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))  
 SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
 SET @BasedOn = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,246,@Pi_UsrId))  
 SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
 PRINT @BasedOn  
 EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  
 SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))  
 SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
 
 EXEC Proc_ReturnRptRetailerCategory @Pi_RptId,@Pi_UsrId  
 SET @RetCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,50,@Pi_UsrId))  
 
 SELECT DISTINCT Prdid,U.ConversionFactor   
 Into #PrdUomBox  
 FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid  
 Inner Join UomMaster UM On U.UomId=Um.UomId  
 Where Um.UomCode='BX'  
    
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
 SELECT Prdid,  
   Case PrdUnitId   
   When 2 Then (PrdWgt/1000)/1000  
   When 3 Then PrdWgt/1000 END AS PrdWgt  
   Into #PrdWeight  From Product  
 CREATE TABLE #AnalysisReportRoute  
 (  
  RMId INT,  
  RMName NVarchar(100),  
  TotalOutlet INT,  
 )  
 INSERT INTO #AnalysisReportRoute (RMId,RMName,TotalOutlet)  
 SELECT Distinct C.RMId,C.RmName,Count(A.RtrId) FROM Retailer A,RetailerMarket B,RouteMaster C   
 WHERE A.RtrId = B.RtrId AND B.RmId = C.RmId And A.RtrStatus = 1   
 GROUP BY C.RmId,C.RmName Order By C.RMName  
 CREATE TABLE #AnalysisReportSales  
 (  
  RMId INT,  
  RMName NVarchar(100),  
  TotalBilled INT,  
 )  
 IF @BasedOn = 1 OR @BasedOn = 3  
 BEGIN  
  UPDATE RptExcelHeaders Set DisplayFlag = 0 Where RptId = 243 And SlNo in (3,4)   
 END  
 IF @BasedOn = 2  
 BEGIN    
  UPDATE RptExcelHeaders Set DisplayFlag = 1 Where RptId = 243 And Slno in (3,4)  
 END   
 Create TABLE #RptECAnalysis  
 (  
         PrdId               INT,  
   Code   NVARCHAR(200),  
   Name         NVARCHAR(200),    
   TotalOutlets   INT,  
   TotalOutletBilled   INT,  
   SalableQty          INT,  
   SalesValue       NUMERIC(38,6),    
   EC        INT,  
   TLS        INT,  
   BasedOn             INT   
 )  
 SET @TblName = 'RptECAnalysis'  
   
 SET @TblStruct = 'RouteCode    NVARCHAR(200),  
       RouteName             NVARCHAR(200),    
       TotalOutlets       INT,  
       TotalOutletBilled     INT,  
       SalableQty            INT,     
       EC        INT,  
       TLS        INT'  
      
 SET @TblFields = 'RouteCode,RouteName,TotalOutlets,TotalOutletBilled,SalableQty,EC,TLS'  
   
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
 IF @Pi_GetFromSnap = 0  
 BEGIN   
     IF @BasedOn = 1  
     BEGIN  
		   INSERT INTO #RptECAnalysis(PrdId,Code,Name,TotalOutlets,TotalOutletBilled,SalableQty,SalesValue,EC,TLS,BasedOn)  
		   SELECT P.PrdId,P.PrdDCode as Code,P.PrdName AS Name,'','',SUM(SIP.BaseQty) AS Unit,SUM(SIP.PrdGrossAmount) AS SalesValue,Count(Distinct(SI.RtrId)) AS EC,COUNT(SIP.Prdid) AS TLS,@BasedOn   
		   FROM Product P (NOLOCK),ProductBatch PB(NOLOCK),SalesInvoice SI(NOLOCK),SalesInvoiceProduct SIP(NOLOCK),Company C(NOLOCK),Salesman S(NOLOCK),RouteMaster RM(NOLOCK),
		   Retailer R(NOLOCK),
		   --RetailerCategorylevel RCL,
		   RetailerValueClassMap RVCM(NOLOCK),
		   RetailerValueClass RVC(NOLOCK),
		   RetailerCategory RC(NOLOCK),  
		   
		   --RetailerCategorylevel RCV,
		   ProductCategoryLevel PCL(NOLOCK),
		   ProductCategoryValue PCV(NOLOCK)
		   WHERE 
		   SIP.PrdId=P.PrdId AND SIP.PrdBatId=PB.PrdBatId AND PB.PrdId=P.PrdId AND SIP.SalId=SI.SalId AND SI.RtrId=R.RtrId AND 
		   --RCV.CtgLevelId=RC.CtgLevelId  
		   SI.SalInvDate BETWEEN @FromDate AND @ToDate AND P.CmpId=C.CmpId AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId  AND 
		   SI.SMId=S.SMId AND SI.RMId=RM.RMId AND 
		   RVCM.RtrId=SI.RtrId AND
		   RVCM.RtrValueClassId=RVC.RtrClassId AND
		   RVC.CtgMainId=RC.CtgMainId  AND 
		   --AND RC.CtgLevelId=RCL.CtgLevelId    
		   PCV.PrdCtgValMainId=P.PrdCtgValMainId AND SI.DlvSts NOT IN (1,3) --Added by Thiru on 30.09.2009 for Bug No:20729  
		     
		   AND (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR  
		   P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
		   AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR  
		   SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
		   AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR  
		   SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
		   AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR  
		   SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
		   
		   --AND (RCV.CtgLevelId = (CASE @RtrCtgLvl WHEN 0 THEN RCV.CtgLevelId ELSE 0 END) OR  
		   --RCV.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
		   
		   AND (RC.CtgMainId = (CASE @RetCatId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
		   RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,50,@Pi_UsrId)))  
		   
		   AND (RVC.RtrClassId = (CASE @RtrValClass WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
		   RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
		   
		   AND (P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR  
			 P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))  
		     
		   AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR  
			  P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
		   GROUP BY P.PrdDCode,P.PrdName,P.PrdId  
		   
   
    END    
    ELSE IF @BasedOn = 2  
    BEGIN   
           INSERT INTO #RptECAnalysis(PrdId,Code,Name,TotalOutlets,TotalOutletBilled,SalableQty,SalesValue,EC,TLS,BasedOn)  
		   SELECT P.Prdid,RM.RMCode as Code,RM.RMName AS Name,'','',SUM(SIP.BaseQty),SUM(SIP.PrdGrossAmount) AS SalesValue,  
		   SI.rtrid AS EC,Count(SI.rmid) AS TLS,@BasedOn 
		   FROM Product P(NOLOCK),ProductBatch PB(NOLOCK),SalesInvoice SI(NOLOCK),  
		   SalesInvoiceProduct SIP(NOLOCK),Company C(NOLOCK),Salesman S(NOLOCK),RouteMaster RM(NOLOCK),
		   
		   Retailer R(NOLOCK),
		   RetailerValueClassMap RVCM(NOLOCK),
		   RetailerValueClass RVC(NOLOCK),
		   RetailerCategory RC(NOLOCK),  
		   --RetailerCategorylevel RCL,
		   --RetailerCategorylevel RCV,
		   
		   ProductCategoryValue PCV(NOLOCK),ProductCategoryLevel PCL(NOLOCK)
		   WHERE 
		   
		   SIP.PrdId=P.PrdId AND SIP.PrdBatId=PB.PrdBatId AND PB.PrdId=P.PrdId  AND 
		   SIP.SalId=SI.SalId AND SI.RtrId=R.RtrId AND 
		   RVCM.RtrId=SI.RtrId AND 
		   RVCM.RtrValueClassId=RVC.RtrClassId  AND
		   RVC.CtgMainId=RC.CtgMainId  AND 
		   --RCV.CtgLevelId=RC.CtgLevelId  
		   SI.SalInvDate BETWEEN @FromDate AND @ToDate AND P.CmpId=C.CmpId AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId  
		   AND SI.SMId=S.SMId AND SI.RMId=RM.RMId AND 
		   
		   
		   --RVC.CtgMainId=RC.CtgMainId  AND 
		   --RC.CtgLevelId=RCL.CtgLevelId AND 
		   
		   PCV.PrdCtgValMainId=P.PrdCtgValMainId AND SI.DlvSts NOT IN (1,3) --Added by Thiru on 30.09.2009 for Bug No:20729  
		   
		   AND (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR  
		   P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
		   AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR  
		   SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
		   AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR  
		   SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
		   AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR  
		   SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
		   --AND (RCV.CtgLevelId = (CASE @RtrCtgLvl WHEN 0 THEN RCV.CtgLevelId ELSE 0 END) OR  
		   --RCV.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
		   AND (RC.CtgMainId = (CASE @RetCatId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
		   RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,50,@Pi_UsrId))) 
		    
		   AND (RVC.RtrClassId = (CASE @RtrValClass WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
		   RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
		   AND (P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR  
		   P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))  
		     
		   AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR  
		   P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
		   GROUP BY RM.RMCode,RM.RMName,P.Prdid,SI.rtrid  
     END  
     ELSE IF @BasedOn = 3  
     BEGIN  
			INSERT INTO #RptECAnalysis(PrdId,Code,Name,TotalOutlets,TotalOutletBilled,SalableQty,SalesValue,EC,TLS,BasedOn)  
			SELECT P.PrdId,R.RtrCode As Code,R.RtrName AS Name,'','',SUM(SIP.BaseQty),SUM(SIP.PrdGrossAmount) AS SalesValue, SI.SalId AS EC,Count(SI.RtrId) AS TLS,@BasedOn  
			FROM Product P (Nolock) ,ProductBatch PB (Nolock),SalesInvoice SI (Nolock),  
			SalesInvoiceProduct SIP (Nolock),Company C (Nolock),Salesman S (Nolock),  
			Retailer R (Nolock),    
			RouteMaster RM (Nolock),  
			RetailerValueClassMap RVCM(NOLOCK),  
			RetailerValueClass RVC (Nolock),
			RetailerCategory RC(NOLOCK),
		    
			--RetailerCategorylevel RCV (Nolock),  
			--RetailerCategorylevel RCL,
		    
			ProductCategoryValue PCV (Nolock),    
			ProductCategoryLevel PCL (Nolock) 
		     
			 WHERE SIP.PrdId=P.PrdId AND SIP.PrdBatId=PB.PrdBatId  
			AND PB.PrdId=P.PrdId AND SIP.SalId=SI.SalId AND SI.RtrId=R.RtrId AND 
			--RCV.CtgLevelId=RC.CtgLevelId  
			SI.SalInvDate BETWEEN @FromDate AND @ToDate  
			AND P.CmpId=C.CmpId AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId  
			AND SI.SMId=S.SMId AND SI.RMId=RM.RMId AND 
			RVCM.RtrId=SI.RtrId AND
			RVCM.RtrValueClassId=RVC.RtrClassId  AND 
			RVC.CtgMainId=RC.CtgMainId AND   
		    
			--AND RC.CtgLevelId=RCL.CtgLevelId      
			PCV.PrdCtgValMainId=P.PrdCtgValMainId  
			AND SI.DlvSts NOT IN (1,3) --Added by Thiru on 30.09.2009 for Bug No:20729  
			AND (P.CmpId = (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR  
			  P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
			AND (SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR  
			  SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
			AND (SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR  
			  SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
			AND (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR  
			  SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
			--AND (RCV.CtgLevelId = (CASE @RtrCtgLvl WHEN 0 THEN RCV.CtgLevelId ELSE 0 END) OR  
			--  RCV.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
			AND (RC.CtgMainId = (CASE @RetCatId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
			  RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,50,@Pi_UsrId)))  
		    
			AND (RVC.RtrClassId = (CASE @RtrValClass WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
			  RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
			AND (P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR  
			  P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))     
			AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR  
			   P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
		   GROUP BY  
			R.RtrCode,R.RtrName,P.PrdId,SI.SalId           
       END      
  IF LEN(@PurDBName) > 0  
  BEGIN  
   SET @SSQL = 'INSERT INTO #RptECAnalysis ' +  
    '(' + @TblFields + ')' +  
    ' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName  
    + 'AND  CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '  
    + 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '  
    + 'AND SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR '  
    + 'SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'  
    + 'AND RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '  
    + 'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '  
    + 'AND RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR '  
    + 'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '  
    + 'AND CtgLevelId = (CASE ' + CAST(@RtrCtgLvl AS nVarchar(10)) + ' WHEN 0 THEN CtgLevelId ELSE 0 END) OR '  
    + 'CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',29,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '  
    + 'AND CtgMainId = (CASE ' + CAST(@RtrCtgLvlVal AS nVarchar(10)) + ' WHEN 0 THEN CtgMainId ELSE 0 END) OR '  
    + 'CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',30,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')) '  
    + 'AND RtrClassId = (CASE ' + CAST(@RtrValClass AS nVarchar(10)) + ' WHEN 0 THEN RtrClassId Else 0 END) OR '  
    + 'RtrClassId in (SELECT iCountid from Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',31,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'+  
    + 'AND P.PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN P.PrdId Else 0 END) OR '  
    + 'P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'  
    + 'AND P.PrdId = (CASE ' + CAST(@PrdId AS nVarchar(10)) + ' WHEN 0 THEN P.PrdId Else 0 END) OR '  
    + 'P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' +  
    + CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))'  
    +' Salinvdate BETWEEN ''' + Convert(Varchar(10),@FromDate,121) + ''' AND ''' + Convert(Varchar(10),@ToDate,121) + ''''  
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
    ' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptECAnalysis'  
     
   EXEC (@SSQL)  
   PRINT 'Saved Data Into SnapShot Table'  
  END  
 END  
 ELSE    --To Retrieve Data From Snap Data  
 BEGIN  
  EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,  
   @Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT  
  PRINT @ErrNo  
  IF @ErrNo = 0  
  BEGIN  
   SET @SSQL = 'INSERT INTO #RptECAnalysis ' +  
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
 DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
 INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
 SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptECAnalysis  
      SELECT DISTINCT A.Prdid,Code,Name,TotalOutlets,TotalOutletBilled,  
      Case When SUM(SalableQty) < MAX(ConversionFactor) Then 0 Else SUM(SalableQty) / MAX(ConversionFactor) End  As SaleableBOX,  
      Case When SUM(SalableQty) < MAX(ConversionFactor) Then SUM(SalableQty) Else SUM(SalableQty) % MAX(ConversionFactor) End As SaleablePKT,  
      SUM(SalesValue)AS SalesValue,EC,TLS,BasedOn INTO #EffectiveRoute FROM #RptECAnalysis A,#PrdUomAll B WHERE A.PrdId = B.PrdId    
      GROUP BY A.Prdid,Code,Name,TotalOutlets,TotalOutletBilled,EC,TLS,BasedOn HAVING SUM(SalableQty) <> 0 ORDER BY Name  
    IF @BasedOn = 1  
    BEGIN  
       SELECT DISTINCT Code,Name,TotalOutlets,TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) As SaleablePKT,SUM(SalesValue) As SalesValue,  
    EC,TLS,BasedOn FROM #EffectiveRoute GROUP BY Code,Name,TotalOutlets,TotalOutletBilled,BasedOn,EC,TLS Order By Name  
          IF EXISTS (Select * From Sysobjects Where XTYPE = 'U' And name = 'RptECAnalysisReportParle_Excel')  
       DROP TABLE RptECAnalysisReportParle_Excel  
    SELECT DISTINCT Code,Name,TotalOutlets,TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) As SaleablePKT,SUM(SalesValue) As SalesValue,  
    EC,TLS,BasedOn INTO RptECAnalysisReportParle_Excel FROM #EffectiveRoute GROUP BY Code,Name,TotalOutlets,TotalOutletBilled,BasedOn,EC,TLS Order By Code     
 END   
 ELSE        
 IF @BasedOn = 2  
 BEGIN   
      SELECT DISTINCT Code,Name,B.TotalOutlet AS TotalOutlets,Count(Distinct (EC))As TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) AS SaleablePKT,SUM(SalesValue) AS SalesValue,  
      Count(Distinct (EC)) AS EC,SUM(TLS) AS TLS,BasedOn from #EffectiveRoute A,#AnalysisReportRoute B   
      WHERE A.Name = B.RMName   
      GROUP BY Code,Name,B.TotalOutlet,BasedOn ORDER BY Code     
         IF EXISTS (Select * From Sysobjects Where XTYPE = 'U' And name = 'RptECAnalysisReportParle_Excel')  
      DROP TABLE RptECAnalysisReportParle_Excel  
      SELECT DISTINCT Code,Name,B.TotalOutlet AS TotalOutlets,Count(Distinct (EC)) As TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) AS SaleablePKT,SUM(SalesValue) AS SalesValue,  
      Count(Distinct (EC)) AS EC,SUM(TLS) AS TLS,BasedOn INTO RptECAnalysisReportParle_Excel FROM #EffectiveRoute A,#AnalysisReportRoute B   
      WHERE A.Name = B.RMName GROUP BY Code,Name,B.TotalOutlet,BasedOn ORDER BY Code  
     
 END  
 ELSE   
 BEGIN  
       SELECT DISTINCT Code,Name,TotalOutlets,TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) As SaleablePKT,SUM(SalesValue) As SalesValue,  
    Count(Distinct(EC)) AS EC,SUM(TLS) AS TLS,BasedOn FROM #EffectiveRoute GROUP BY Code,Name,TotalOutlets,TotalOutletBilled,BasedOn Order By Name  
          IF EXISTS (Select * From Sysobjects Where XTYPE = 'U' And name = 'RptECAnalysisReportParle_Excel')  
       DROP TABLE RptECAnalysisReportParle_Excel  
    SELECT DISTINCT Code,Name,TotalOutlets,TotalOutletBilled,SUM(SaleableBOX) AS SaleableBOX,SUM(SaleablePKT) As SaleablePKT,SUM(SalesValue) As SalesValue,  
    Count(Distinct(EC)) AS EC,SUM(TLS) AS TLS,BasedOn INTO RptECAnalysisReportParle_Excel FROM #EffectiveRoute GROUP BY Code,Name,TotalOutlets,TotalOutletBilled,BasedOn Order By Code     
 END  
        
   RETURN  
END
GO
IF EXISTS (SELECT Name FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_SyncValidation')
DROP PROCEDURE Proc_SyncValidation
GO
--EXEC Proc_SyncValidation 0,'',0,0,0,'','',''
CREATE PROCEDURE Proc_SyncValidation
(    
@piTypeId Int,    
@piCode Varchar(100) = '', -- IP Address in Sync Attempt, DistCode in SyncStatus,    
@piVal1 Numeric(18)=0, -- SubTypeId in SyncStatus,    
@piVal2 Numeric(18)=0, -- SyncId in SyncStatus,    
@piVal3 Numeric(18)=0, -- RecCnt in SyncStatus,    
@piVal4 Varchar(100)='',    
@piVal5 Varchar(100)='',    
@piVal6 Varchar(100)=''    
)    
As    
Begin    
 Declare @Sql Varchar(Max)  
 Declare @IntRetVal Int
 IF @piTypeId = 1 -- Distributor Code, Proc_SyncValidation  piTypeId    
 Begin    
  SELECT DistributorCode FROM Distributor WHERE Distributorid=1     
 End    
 IF @piTypeId = 2 -- Upload And Download, Path Proc_SyncValidation  piTypeId    
 Begin    
  SELECT * FROM Configuration WHERE ModuleId In ('DATATRANSFER44','DATATRANSFER45') AND ModuleName='DataTransfer' Order By ModuleId     
 End     
 IF @piTypeId = 3 -- Sync Attempt Validation  Proc_SyncValidation  @piTypeId,@piCode    
 Begin    
  Declare @RetTemp Int
  SET @RetTemp = 1
  IF Not Exists (Select * From SyncStatus (Nolock) Where Syncid = (Select MAX(Syncid) From Sync_Master (Nolock)))
  Begin
	IF Not Exists (Select * From SyncStatus (Nolock) Where SyncStatus = 1 And Syncid = (Select MAX(Syncid) -1 From Sync_Master (Nolock)))
	Begin
		SET @RetTemp = 0		
	End
  End
  IF (@RetTemp = 0)
  Begin
	Select 0
	RETURN
  End
  Set @piCode = (Select Top 1 HostName From Sys.sysprocesses where  status='RUNNABLE' Order By login_time desc)    
  IF ((SELECT Count(*) From SyncAttempt) < 1)    
   BEGIN    
    INSERT INTO SyncAttempt    
    SELECT @piCode,1,Getdate()    
    SELECT 1    
   END     
  ELSE    
   BEGIN    
    IF (SELECT Status From SyncAttempt) = 0    
     BEGIN    
      UPDATE SyncAttempt SET IPAddress = @piCode,Status = 1,StartTime = Getdate()     
      SELECT 1    
     END    
    ELSE    
     BEGIN    
      IF ((SELECT DatedIFf(hh,StartTime,Getdate()) From SyncAttempt) > 1)    
       BEGIN    
          UPDATE SyncAttempt SET IPAddress = @piCode,Status = 1,StartTime = Getdate()     
          SELECT 1    
       END    
      ELSE    
        IF ((SELECT Count(*) From SyncAttempt WHERE IPAddress = @piCode) = 1 )    
         BEGIN    
          UPDATE SyncAttempt SET Status = 1,StartTime = Getdate()     
          SELECT 1    
         END    
        ELSE    
         BEGIN    
          SELECT 0             
         END    
     END    
   END      
 End    
 IF @piTypeId = 4 -- Remove from Redownloadrequest,  Proc_SyncValidation   @piTypeId    
 Begin    
  TRUNCATE TABLE ReDownLoadRequest    
 End    
 IF @piTypeId = 5 -- Sync Process Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
   IF @piVal1 = 1     
   Begin    
    SELECT * FROM Customupdownloadstatus Status WHERE SyncProcess='SyncProcess0' ORDER BY SyncProcess    
   End    
   IF @piVal1 = 2     
   Begin    
    SELECT * FROM Customupdownloadstatus Status WHERE SyncProcess<>'SyncProcess0' ORDER BY SyncProcess    
   End    
 End    
 IF @piTypeId = 6 -- Sync Process Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1     
   Begin    
    SELECT DISTINCT SlNo,SlNo AS SeqNo,Module AS Process,TranType AS [Transaction Type],UpDownload AS [Exchange Type], 0 AS Count     
    FROM Customupdownload ORDER BY SlNo     
   End    
  IF @piVal1 = 2     
   Begin    
    SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM  Customupdownload  WHERE UpDownload='Upload'    
   End    
  IF @piVal1 = 3    
   Begin    
    SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM  Customupdownload  WHERE UpDownload='Download'    
   End    
 End    
 IF @piTypeId = 7 -- Sync Status Validation,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2,@piVal3    
 Begin    
  IF Exists(Select * from SyncStatus Where DistCode = @piCode and SyncId = @piVal2)        
   Begin        
    IF @piVal1 = 1        
       Begin        
      Update SyncStatus Set DPStartTime = Getdate(),DPEndTime = Getdate(),SyncFlag='N' where DistCode = @piCode and SyncId = @piVal2       
       End        
    Else IF @piVal1 = 2        
     Begin        
      Update SyncStatus Set DPEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End    
    IF @piVal1 = 3        
     Begin        
      Update SyncStatus Set UpStartTime = Getdate(),UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 4        
     Begin        
      Update SyncStatus Set UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 5        
     Begin        
      Update SyncStatus Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End        
    Else IF @piVal1 = 6        
     Begin        
      Update SyncStatus Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 7    
     Begin        
      IF @piVal3 = 1    
       Begin    
        Update SyncStatus Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2       
        Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal2         
       End    
     End       
   End        
  Else        
   Begin        
    Delete From SyncStatus Where DistCode = @piCode and SyncStatus = 1  
    IF Not Exists (Select * From  SyncStatus (Nolock))
    Begin  
		Insert into SyncStatus Select @piCode,@piVal2,Getdate(),Getdate(),Getdate(),Getdate(),Getdate(),Getdate(),0,'N'
    End        
    IF @piVal1 = 1        
       Begin        
      Update SyncStatus Set DPStartTime = Getdate(),DPEndTime = Getdate(),SyncFlag='N' where DistCode = @piCode and SyncId = @piVal2       
       End        
    Else IF @piVal1 = 2        
     Begin        
      Update SyncStatus Set DPEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End    
    IF @piVal1 = 3        
     Begin        
      Update SyncStatus Set UpStartTime = Getdate(),UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 4        
     Begin        
      Update SyncStatus Set UpEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 5        
     Begin        
      Update SyncStatus Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2      
     End        
    Else IF @piVal1 = 6        
     Begin        
      Update SyncStatus Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2       
     End        
    Else IF @piVal1 = 7    
     Begin        
      IF @piVal3 = 1    
       Begin    
        Update SyncStatus Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2       
        Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal2         
       End    
     End       
   End      
 End    
 IF @piTypeId = 8 -- Select Current SyncId,  Proc_SyncValidation   @piTypeId    
 Begin    
  Select IsNull(MAX(SyncId),0) From SyncStatus    
 End     
 IF @piTypeId = 9 -- Select Syncstatus for this SyncId,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin    
  Select IsNull(Max(SyncStatus),0) From SyncStatus where DistCode = @piCode And syncid = @piVal1 And SyncStatus = 1    
 End      
 IF @piTypeId = 10 -- DB Restoration Concept,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1    
   Begin    
    Select Count(*) From DefendRestore    
   End     
  IF @piVal1 = 2    
   Begin    
    update DefendRestore Set DbStatus = 1,ReqId = 1,CCLockStatus = 1    
   End       
  IF @piVal1 = 3    
   Begin    
    Insert into DefendRestore (AccessCode,LastModDate,DbStatus,ReqId,CCLockStatus)
    Values('',GETDATE(),1,1,1)    
   End     
 End       
 IF @piTypeId = 11 -- AAD & Configuration Validation,  Proc_SyncValidation   @piTypeId,'',@piVal1    
 Begin    
  IF @piVal1 = 1    
  Begin    
   SELECT * FROM Configuration WHERE ModuleId='BotreeSyncCheck'    
  End     
  IF @piVal1 = 2    
  Begin    
   SELECT * FROM Configuration WHERE ModuleId LIKE 'BotreeSyncErrLog'    
  End       
  IF @piVal1 = 3    
  Begin    
   Select IsNull(Max(FixID),0) from Hotfixlog (NOLOCK)    
  End       
 End       
 IF @piTypeId = 12 -- System Date is less than the Last Transaction Date Validation,  Proc_SyncValidation   @piTypeId    
 Begin    
  SELECT ISNULL(MAX(TransDate),GETDATE()-1) AS TransDate FROM StockLedger    
 End     
 IF @piTypeId = 13 -- DayEnd Process Updation,  Proc_SyncValidation   @piTypeId,@piCode    
 Begin    
  UPDATE DayEndProcess SET NextUpDate=@piCode WHERE ProcId=13    
 End     
 IF @piTypeId = 14 -- Update Sync Attempt Status ,  Proc_SyncValidation   @piTypeId,@piCode    
 Begin    
  Select @piCode =  HostName From Sys.sysprocesses where  status='RUNNABLE'    
  Update SyncAttempt Set Status=0 where IPAddress = @piCode    
 End      
 IF @piTypeId = 15 -- Latest SyncId from Sync_Master ,  Proc_SyncValidation   @piTypeId    
 Begin    
  Select ISNull(Max(SyncId),0) From Sync_Master    
 End     
 IF @piTypeId = 16 -- Update the Flag as Y for all lesser than the latest Serial No ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
	 IF ((Select ISNULL(Min(SlNo),0) From CS2Console_Consolidated (Nolock) Where DistCode = @piCode And SyncId = @piVal1 And SlNo <= @piVal2 And UploadFlag='N') > 0)        
	  Begin        
	   Update CS2Console_Consolidated Set UploadFlag='N' Where DistCode = @piCode and SyncId = @piVal1 And SlNo >=   
	   (Select ISNULL(Min(SlNo),0) From CS2Console_Consolidated (Nolock) Where DistCode = @piCode And SyncId = @piVal1 And SlNo <= @piVal2 And UploadFlag='N')         
	  End        
	  Else        
	  Begin        
	   Update CS2Console_Consolidated Set UploadFlag='Y' Where DistCode = @piCode and SyncId = @piVal1 And SlNo <= @piVal2 
	   Update CS2Console_Consolidated Set UploadFlag='N' Where DistCode = @piCode and SyncId = @piVal1 And SlNo > @piVal2    
	  End 
 End      
 IF @piTypeId = 17 -- Record Count ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
  IF @piVal1 = 1     
  Begin    
   Select Count(*) From CS2Console_Consolidated where DistCode = @piCode and syncid =@piVal2 and UploadFlag = 'N'    
  End    
  IF @piVal1 = 2     
  Begin    
   Select Count(Distinct Slno) From CS2Console_Consolidated where DistCode = @piCode and syncid =@piVal2     
  End       
  IF @piVal1 = 3     
  Begin    
   Select IsNull(Count(*),0) From SyncStatus (Nolock) Where DistCode = @piCode And SyncId = @piVal2 And SyncFlag = 'Y'     
  End    
 End      
 IF @piTypeId = 18 -- Datapreperation Process and Split each 1000 rows for xml file ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin    
  IF @piVal1 = 1     
  Begin    
   SELECT * FROM  CustomUpDownload  WHERE SlNo=@piVal2  AND UpDownload='Upload' ORDER BY UpDownLoad,SlNo,SeqNo    
  End    
  IF @piVal1 = 2     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UploadFlag=''N'''    
   Exec (@Sql)    
  End       
  IF @piVal1 = 3    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MIN(SlNo),0) AS SlNo FROM  ' + Convert(Varchar(100),@piCode) + ' WHERE UploadFlag=''N'''    
   Exec (@Sql)    
  End        
  IF @piVal1 = 4    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT * FROM  ' + Convert(Varchar(100),@piCode) + ' WHERE  SlNo= ' + Convert(Varchar(100),@piVal2) + '  ORDER BY UpDownLoad,SlNo,SeqNo '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 5    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM   ' + Convert(Varchar(100),@piCode) + '  '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 6    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' DELETE  FROM   ' + Convert(Varchar(100),@piCode) + ' WHERE Downloadflag = ''D'' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 7    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) FROM   ' + Convert(Varchar(100),@piCode) + ' WHERE DownloadFlag = ''D'' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 8    
  Begin    
   Set @Sql = ''    
  Set @Sql = @Sql + ' SELECT TRowCount FROM Tbl_DownloadIntegration_Process WHERE PrkTableName =''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End      
  IF @piVal1 = 9    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Update Tbl_DownloadIntegration_Process Set TRowCount = 0  WHERE ProcessName=''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 10    
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Update Tbl_DownloadIntegration_Process Set TRowCount = ' + Convert(Varchar(100),@piVal2) + ' where ProcessName=''' + Convert(Varchar(100),@piCode) + ''' '    
   Exec (@Sql)    
  End       
  IF @piVal1 = 11     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MAX(SlNo),0) AS Cnt FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'''    
   Exec (@Sql)    
  End       
  IF @piVal1 = 12     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT ISNULL(MIN(SlNo),0) AS SlNo FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'''    
   Exec (@Sql)    
  End      
  IF @piVal1 = 13     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(*) AS Count FROM ' + Convert(Varchar(100),@piCode) + ' WHERE SyncId =' + Convert(Varchar(100),@piVal2) + ' And UploadFlag=''N'' '    
   Exec (@Sql)    
  End      
  IF @piVal1 = 14     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(DISTINCT SlNo) AS UploadCount FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UpDownload=''Upload'' '    
   Exec (@Sql)    
  End         
  IF @piVal1 = 15     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' SELECT COUNT(DISTINCT SlNo) AS DownloadCount FROM ' + Convert(Varchar(100),@piCode) + ' WHERE UpDownload=''Download'' '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 16     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Select DistCode +''-eertoB-''+ CONVERT(Varchar(10),SyncID)  From SyncStatus (nolock) Where DistCode =''' + Convert(Varchar(100),@piCode) + ''' And  SyncStatus = 0 '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 17     
  Begin    
   Set @Sql = ''    
   Set @Sql = @Sql + ' Select DistCode +''-eertoB-''+ CONVERT(Varchar(10),SyncID)  From SyncStatus_Download (nolock) Where DistCode =''' + Convert(Varchar(100),@piCode) + ''' And  SyncStatus = 0 '    
   Exec (@Sql)    
  End     
  IF @piVal1 = 18
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' SELECT * FROM ' + Convert(Varchar(100),@piCode) + ' As DU WHERE UploadFlag=''N'' AND SlNo BETWEEN  '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' ORDER BY SlNo  FOR XML AUTO '
		Select @Sql
	End	
  IF @piVal1 = 19
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''X'' WHERE UploadFlag=''N'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	
  IF @piVal1 = 20
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''Y'' WHERE UploadFlag=''X'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	
  IF @piVal1 = 21
	Begin
		Set @Sql = ''
		Set @Sql = @Sql + ' UPDATE ' + Convert(Varchar(100),@piCode) + ' SET UploadFlag=''N'' WHERE UploadFlag=''X'' AND SlNo BETWEEN '
		Set @Sql = @Sql + '  ' + Convert(Varchar(100),@piVal2) + ' And ' + Convert(Varchar(100),@piVal3) + ' '
		Exec (@Sql)
	End	  
 End      
 IF @piTypeId = 19 -- View Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin    
  SELECT * FROM ErrorLog WITH (NOLOCK)    
 End    
 IF @piTypeId = 20 -- Remove Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin     
  DELETE FROM ErrorLog     
 End     
 IF @piTypeId = 21 -- Download Notification Details Error Log Details ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM  CustomUpDownloadCount WHERE UpDownload='Download' ORDER BY SlNo    
 End     
 IF @piTypeId = 22 -- Download Details to xml file ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Cs2Cn_Prk_DownloadedDetails WHERE UploadFlag='N'    
 End     
 IF @piTypeId = 23 -- Download Integration Details  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_DownloadIntegration_Process ORDER BY SequenceNo    
 End     
 IF @piTypeId = 24 -- Reset TRow Count  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  UPDATE Tbl_DownloadIntegration_Process SET TRowCount=0    
 End      
 IF @piTypeId = 25 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT PrkTableName,SPName FROM Tbl_DownloadIntegration_Process WHERE ProcessName = @piCode    
 End      
 IF @piTypeId = 26 -- Upload Consolidated Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_UploadIntegration_Process ORDER BY SequenceNo    
 End      
 IF @piTypeId = 27 -- Download Details   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT DISTINCT Module,DownloadedCount FROM CustomUpDownloadCount WHERE UpDownload='Download' AND DownloadedCount>0    
 End      
 IF @piTypeId = 28 -- ReDownload Request   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Configuration WHERE ModuleId='BotreeReDownload'    
 End     
 IF @piTypeId = 29 -- ReDownload Request   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM ReDownLoadRequest    
 End     
 IF @piTypeId = 30 -- Showboard    ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Configuration WHERE ModuleId='BotreeBBOardOnSync' AND Status=1    
 End     
 IF @piTypeId = 31 -- Update sync status if disconnect    ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin     
  IF Not Exists (Select * From CS2Console_Consolidated (nolock) Where DistCode = @piCode And Syncid = @piVal1 And UploadFlag='N')    
  Begin    
   Update Syncstatus Set Syncstatus = 1 Where DistCode = @piCode And Syncid = @piVal1    
   Select IsNull(Max(SyncStatus),0) From SyncStatus (nolock) Where DistCode = @piCode And Syncid = @piVal1    
  End    
 End     
 IF @piTypeId = 32 -- Update sync status if disconnect,Proc_SyncValidation @piTypeId,@piCode,@piVal1    
 Begin     
  Declare @RETVAL Varchar(Max)    
  Set @RETVAL = ''    
  IF EXISTS (Select * From Chk_MainSalesIMEIUploadCnt (NOLOCK))    
  Begin      
  Select @RETVAL = Cast(COALESCE(@RETVAL + ', ', '') + Convert(Varchar(40),MainTblBillNo) as ntext) From Chk_MainSalesIMEIUploadCnt       
  Select @RETVAL    
  End    
 End    
 IF @piTypeId = 33 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
   Select 'Request given for approval so please approve from Central Help Desk.'      
 End      
 IF @piTypeId = 34 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
   Select IsNull(LTrim(RTrim(CmpCode)),'') From Company (Nolock) Where DefaultCompany = 1      
 End      
 IF @piTypeId = 35 -- Select Download Sync status  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1    
 Begin       
  Select IsNull(SyncStatus,0) from Syncstatus_Download (nolock) Where Distcode = @picode and Syncid = @pival1    
 End      
 IF @piTypeId = 36 -- Select Max(Syncid) in Download Sync Status  ,  Proc_SyncValidation   @piTypeId      
 Begin       
  Select IsNull(Max(SyncId),0) From SyncStatus_Download (Nolock)    
 End      
 IF @piTypeId = 37 -- Select Max(SlNo) in Console2CS_Consolidated  ,  Proc_SyncValidation   @piTypeId      
 Begin       
  Select IsNull(Max(SlNo),0) From Console2CS_Consolidated (Nolock) Where Distcode = @picode and Syncid = @pival1    
 End       
 IF @piTypeId = 38 -- Syncstatus  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2    
 Begin       
 Declare @RetState Int    
 IF Exists (Select * From SyncStatus (Nolock) where DistCode = @piCode And syncid = @piVal1 And SyncStatus = 1)    
  Begin    
	If (Select Count(1) from SyncStatus_Download_Archieve (Nolock) Where SyncId > 0) > 0
	 Begin
		IF Exists (Select * From SyncStatus_Download (Nolock) where DistCode = @piCode And syncid = @piVal2 And SyncStatus = 1)    
		 Begin    
		  Set @RetState = 1 -- Upload and Download Completed Successfully        
		 End    
		Else    
		 Begin    
		  Set @RetState = 2 -- Upload Completed, Download Incomplete     
		 End    
	 End
	Else
	 Begin
		Set @RetState = 1 -- Upload and Download Completed Successfully 
	 End
  End    
  Else    
  Begin    
  	If (Select Count(1) from SyncStatus_Download_Archieve (Nolock) Where SyncId > 0) > 0
	 Begin
  		IF Exists (Select * From SyncStatus_Download (Nolock) where DistCode = @piCode And syncid = @piVal2 And SyncStatus = 1)    
		 Begin    
		  Set @RetState = 3 -- Upload Incomplete, Download Completed Successfully          
		 End    
		Else    
		 Begin    
		  Set @RetState = 4 -- Upload and Download Incomplete!!!           
		 End    
	 End
	Else
	 Begin
		Set @RetState = 3 -- Upload Incomplete, Download Completed Successfully 
	 End
  End    
  Select @RetState    
 End       
 IF @piTypeId = 39 -- Update Download Sync Status  ,  Proc_SyncValidation   @piTypeId,@piCode,@piVal1,@piVal2,@piVal3      
 Begin       
 -------    
  IF Exists(Select * from SyncStatus_Download Where DistCode = @piCode and SyncId = @piVal2)                
   Begin                
    IF @piVal1 = 1                
    Begin              
     IF Exists(Select * From Console2CS_Consolidated (Nolock) Where DistCode = @piCode and SyncId = @piVal2)        
     Begin        
     Delete A From Console2CS_Consolidated A (Nolock)  Where DistCode = @piCode and SyncId = @piVal2        
     End 
    Update SyncStatus_Download Set SyncStatus=0,SyncFlag=0 Where DistCode = @piCode and SyncId = @piVal2   -- Added to Parameter S       
    Update SyncStatus_Download Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2              
    End                
    IF @piVal1 = 2                
     Begin                
    Update SyncStatus_Download Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2               
     End            
    IF @piVal1 = 3                
     Begin                
     IF (@piVal3 = (Select COUNT(Distinct SlNo) From Console2CS_Consolidated (nolock) Where DistCode = @piCode and SyncId = @piVal2 And DownloadFlag='N'))          
      Begin          
    Update SyncStatus_Download Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2             
      End         
     Else      
      Begin          
    Delete A From Console2CS_Consolidated A (Nolock)  Where DistCode = @piCode and SyncId = @piVal2             
      End        
     End             
   End                
  Else                
   Begin                
    Insert into SyncStatus_Download_Archieve  Select *,Getdate() from SyncStatus_Download Where DistCode = @piCode           
    Delete From SyncStatus_Download Where DistCode = @piCode               
    Insert into SyncStatus_Download Select @piCode,@piVal2,Getdate(),Getdate(),0,0                
    Insert into SyncStatus_Download_Archieve Select @piCode,@piVal2,Getdate(),Getdate(),0,0,GETDATE()                 
    IF @piVal1 = 1                
    Begin                
    Update SyncStatus_Download Set DwnStartTime = Getdate(),DwnEndTime = Getdate() where DistCode = @piCode  and SyncId = @piVal2              
    End                
    IF @piVal1 = 2                
     Begin                
    Update SyncStatus_Download Set DwnEndTime = Getdate() where DistCode = @piCode and SyncId = @piVal2               
     End            
    IF @piVal1 = 3                
     Begin                
     IF (@piVal3 = (Select COUNT(Distinct SlNo) From Console2CS_Consolidated (nolock) Where DistCode = @piCode and SyncId = @piVal2 And DownloadFlag='N'))          
      Begin          
    Update SyncStatus_Download Set SyncStatus = 1 where DistCode = @piCode and SyncId = @piVal2             
      End         
     Else      
      Begin          
    Delete A From Console2CS_Consolidated A (Nolock) Where DistCode = @piCode and SyncId = @piVal2             
      End         
     End             
   End      
 ------    
 END      
  IF @piTypeId = 40 -- Download Integration Details  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT * FROM Tbl_Customdownloadintegration ORDER BY SequenceNo    
 End     
 IF @piTypeId = 41 -- Reset TRow Count  ,  Proc_SyncValidation   @piTypeId    
 Begin     
  UPDATE Tbl_Customdownloadintegration SET TRowCount=0    
 End 
 IF @piTypeId = 42 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT PrkTableName,SPName FROM Tbl_Downloadintegration WHERE ProcessName = @piCode    
 End 
 IF @piTypeId = 43 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  SELECT TRowCount FROM Tbl_Customdownloadintegration WHERE PrkTableName = @piCode    
 End 
 IF @piTypeId = 44 -- Download Process   ,  Proc_SyncValidation   @piTypeId    
 Begin     
  Update Tbl_Customdownloadintegration Set TRowCount = @piVal1 WHERE ProcessName = @piCode    
 End 
 IF @piTypeId = 45 -- Update DB Restore request status  ,  Proc_SyncValidation   @piTypeId  
 Begin   
	Set @IntRetVal = 0  
	IF @piVal1 = 1
	Begin
		If Exists (Select * From sys.Objects where TYPE='U' and name ='UtilityProcess')  
		 Begin  
		  IF Exists (Select * from UtilityProcess where ProcId = 3)  
		  Begin  
		   IF ((Select Convert(Varchar(100),VersionId) from UtilityProcess where ProcId = 3) <> @piCode)  
		   Begin  
			Set @IntRetVal = 1      
		   End     
		  End  
		 End  
	End   
	IF @piVal1 = 2
	Begin
		If Not Exists (Select * From AppTitle (Nolock) Where  SynVersion = @piCode)  
		 Begin  
			Set @IntRetVal = 1
		 End
	End
	Select @IntRetVal 
 End  	
 IF @piTypeId = 46 -- Data Purge  ,  Proc_SyncValidation   @piTypeId  
 Begin  
	Set @IntRetVal = 1
	IF EXISTS (Select * From Sys.objects Where name = 'DataPurgeDetails' and TYPE='U')
	Begin
		IF EXISTS (SELECT * FROM DataPurgeDetails WHERE [Status] = 1)
		Begin
			Set @IntRetVal = 0
		End
	End
	Select @IntRetVal	
 End
 IF @piTypeId = 47 -- Update In Active Distributor  ,  Proc_SyncValidation   @piTypeId  
 Begin  
	Set @IntRetVal = 1
	--IF Exists (Select * From Sys.objects Where name = 'Distributor' and TYPE='U')
	--Begin
	--	Update Distributor Set DistStatus = 0 Where DistributorCode = @piCode
	--End
 END
----------Additional Validation----------    
------------------------------------------    
END
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'Proc_GetStockLedgerSummaryDatewise') AND type in (N'P', N'PC'))
DROP PROCEDURE Proc_GetStockLedgerSummaryDatewise
GO
--Exec Proc_GetStockLedgerSummaryDatewise '2006/02/19','2009/04/19',1,0,0
--Select * From TempStockLedSummary where userid=1 and prdid in (3,20) and lcnid=8 and
--Select * From TempStockLedSummaryTotal
--SELECT * FROM StockLedger
CREATE	PROCEDURE Proc_GetStockLedgerSummaryDatewise
(
	@Pi_FromDate 		DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_UserId		INT,
	@SupTaxGroupId		INT,
	@RtrTaxFroupId		INT,
	@Pi_OfferStock		INT
)
AS
/*********************************
* PROCEDURE	: Proc_GetStockLedgerSummaryDatewise
* PURPOSE	: To Get Stock Ledger Detail
* CREATED	: Nandakumar R.G
* CREATED DATE	: 15/02/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}			{brief modification description}
* 23/07/2014	Muthuvelsamy R		PMS Id - ICRSTPAR0233(Batch details missing in 'inventory console' and 'stock & sales report')
*********************************/
SET NOCOUNT ON
BEGIN
	
	TRUNCATE TABLE TempStockLedSummaryTotal
	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
		DELETE FROM TaxForReport WHERE UsrId=@Pi_UserId AND RptId=100
		EXEC Proc_ReportTaxCalculation @SupTaxGroupId,@RtrTaxFroupId,1,20,5,@Pi_UserId,100
	END
	
	DECLARE @ProdDetail TABLE
		(
			lcnid	INT,
			PrdBatId INT,
			TransDate DATETIME
		)
	DELETE FROM @ProdDetail
--	INSERT INTO @ProdDetail
--		(
--			lcnid,PrdBatId,TransDate
--		)
--	
--	SELECT a.lcnid,a.PrdBatID,a.TransDate FROM
--	(
--		select lcnid,prdbatid,max(TransDate) as TransDate  FROM StockLedger Stk (nolock)
--			WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate
--		Group by lcnid,prdbatid
--	) a LEFT OUTER JOIN
--	(
--		select distinct lcnid,prdbatid,max(TransDate) as TransDate FROM StockLedger Stk (nolock)
--			WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
--		Group by lcnid,prdbatid
--	) b
--	on a.lcnid = b.lcnid and a.prdbatid = b.prdbatid
--	where b.lcnid is null and b.prdbatid is null
			
	INSERT INTO @ProdDetail  
	(  
		LcnId,PrdBatId,TransDate  
	)  
	SELECT LcnId,PrdBatId,MAX(TransDate) FROM StockLedger(nolock)  
	/*Code Modified by Muthuvelsamy R for PMS Id ICRSTPAR0233 begins*/
	--WHERE TransDate <@Pi_FromDate AND CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) NOT IN
	--(SELECT CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) 
	WHERE TransDate <@Pi_FromDate AND CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) NOT IN
	(SELECT CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) 	
	/*Code Modified by Muthuvelsamy R for PMS Id ICRSTPAR0233 ends*/
	FROM StockLedger WHERE TransDAte BETWEEN @Pi_FromDate AND @Pi_ToDate)
	GROUP BY LcnId,PrdBatId
	DELETE FROM TempStockLedSummary WHERE UserId=@Pi_UserId
	
	--      Stocks for the given date---------
	IF @Pi_OfferStock=1
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT Sl.TransDate AS TransDate,Sl.LcnId AS LcnId,
		Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,
		(Sl.SalOpenStock+Sl.UnSalOpenStock+Sl.OfferOpenStock) AS Opening,
		(Sl.SalPurchase+Sl.UnsalPurchase+Sl.OfferPurchase) AS Purchase,
		(Sl.SalSales+Sl.UnSalSales+Sl.OfferSales) AS Sales,
		(-Sl.SalPurReturn-Sl.UnsalPurReturn-Sl.OfferPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.OfferStockIn-
		Sl.SalStockOut-Sl.UnSalStockOut-Sl.OfferStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.OfferSalesReturn+
		Sl.SalStkJurIn+Sl.UnSalStkJurIn+Sl.OfferStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut-Sl.OfferStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn+Sl.OfferBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut-Sl.OfferBatTfrOut+
		Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn+Sl.OfferLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-Sl.OfferLcnTfrOut-
		Sl.SalReplacement-Sl.OfferReplacement+Sl.DamageIn-Sl.DamageOut) AS Adjustments,
		(Sl.SalClsStock+Sl.UnSalClsStock+Sl.OfferClsStock) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)
		WHERE Sl.PrdId = Prd.PrdId AND
		Sl.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND
		PrdBat.PrdBatId = Sl.PrdBatId AND
		Lcn.LcnId = Sl.LcnId AND
		Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
		ORDER BY Sl.TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	END
	ELSE
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT Sl.TransDate AS TransDate,Sl.LcnId AS LcnId,
		Lcn.LcnName,Sl.PrdId,Prd.PrdDCode,Prd.PrdName,Sl.PrdBatId,PrdBat.PrdBatCode,
		(Sl.SalOpenStock+Sl.UnSalOpenStock) AS Opening,
		(Sl.SalPurchase+Sl.UnsalPurchase) AS Purchase,
		(Sl.SalSales+Sl.UnSalSales) AS Sales,
		(-Sl.SalPurReturn-Sl.UnsalPurReturn+Sl.SalStockIn+Sl.UnSalStockIn-
		Sl.SalStockOut-Sl.UnSalStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+
		Sl.SalStkJurIn+Sl.UnSalStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut+
		Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-
		Sl.SalReplacement+Sl.DamageIn-Sl.DamageOut) AS Adjustments,
		(Sl.SalClsStock+Sl.UnSalClsStock) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),StockLedger Sl (NOLOCK),Location Lcn (NOLOCK)
		WHERE Sl.PrdId = Prd.PrdId AND
		Sl.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate AND
		PrdBat.PrdBatId = Sl.PrdBatId AND
		Lcn.LcnId = Sl.LcnId AND
		Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
		ORDER BY Sl.TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	END	
	--      Stocks for those not included in the given date---------
	IF @Pi_OfferStock=1
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT @Pi_FromDate AS TransDate,ISNULL(Sl.LcnId,0) AS LcnId,
		IsNull(Lcn.LcnName,'')AS LcnName,ISNULL(Sl.PrdId,Prd.PrdId)AS PrdId,ISNULL(Prd.PrdDCode,'') AS PrdDCode,
		ISNULL(Prd.PrdName,'') AS PrdName,ISNULL(Sl.PrdBatId,0) AS PrdBatId,
		ISNULL(PrdBat.PrdBatCode,'') AS PrdBatCode,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)
		LEFT OUTER JOIN Location Lcn (NOLOCK) ON Sl.LcnId=Lcn.LcnId
		WHERE
		Sl.PrdBatId=PrdDet.PrdBatId AND Sl.TransDate=PrdDet.TransDate	
		AND Sl.lcnid = PrdDet.lcnid
		AND Sl.TransDate< @Pi_FromDate
		AND Sl.PrdId=Prd.PrdId And Sl.PrdBatId=PrdBat.PrdBatId AND Prd.PrdId=PrdBat.PrdId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
	END
	ELSE
	BEGIN
		INSERT INTO TempStockLedSummary
		(
		TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
		Purchase,Sales,Adjustment,Closing,
		PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
		PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
		BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
		)			
		SELECT @Pi_FromDate AS TransDate,ISNULL(Sl.LcnId,0) AS LcnId,
		IsNull(Lcn.LcnName,'')AS LcnName,ISNULL(Sl.PrdId,Prd.PrdId)AS PrdId,ISNULL(Prd.PrdDCode,'') AS PrdDCode,
		ISNULL(Prd.PrdName,'') AS PrdName,ISNULL(Sl.PrdBatId,0) AS PrdBatId,
		ISNULL(PrdBat.PrdBatCode,'') AS PrdBatCode,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) AS Closing,
		0,0,0,0,0,0,0,0,0,0,0,0,
		PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
		FROM
		Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),@ProdDetail PrdDet,StockLedger Sl (NOLOCK)
		LEFT OUTER JOIN Location Lcn (NOLOCK) ON Sl.LcnId=Lcn.LcnId
		WHERE
		Sl.PrdBatId=PrdDet.PrdBatId AND Sl.TransDate=PrdDet.TransDate	
		AND Sl.lcnid = PrdDet.lcnid
		AND Sl.TransDate< @Pi_FromDate
		AND Sl.PrdId=Prd.PrdId And Sl.PrdBatId=PrdBat.PrdBatId AND Prd.PrdId=PrdBat.PrdId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
	END
	--      Stocks for those not included in the stockLedger---------
	INSERT INTO TempStockLedSummary
	(
	TransDate,LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Opening,
	Purchase,Sales,Adjustment,Closing,
	PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,
	PurSelRte,SalSelRte,AdjSelRte,CloSelRte,
	BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock
	)			
	SELECT @Pi_FromDate AS TransDate,Lcn.LcnId,
	Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode,
	0 AS Opening,0 AS Sales,0 AS Purchase,0 AS Adjustments,0 AS Closing,
	0,0,0,0,0,0,0,0,0,0,0,0,
	PrdBat.BatchSeqId,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,@Pi_UserId,0
	FROM
	ProductBatch PrdBat (NOLOCK),ProductCategoryValue PCV (NOLOCK),Product Prd (NOLOCK)
	CROSS JOIN Location Lcn (NOLOCK)
	WHERE
		PrdBat.PrdBatId IN
		(
		SELECT PrdBatId FROM (
		SELECT DISTINCT A.PrdBatId,B.PrdBatId AS NewPrdBatId FROM
		ProductBatch A (nolock) LEFT OUTER JOIN StockLedger B (nolock)
		ON A.Prdid =B.Prdid) a
		WHERE ISNULL(NewPrdBatId,0) = 0
	)
	AND PrdBat.PrdId=Prd.PrdId
	AND Prd.PrdCtgVAlMainId=PCV.PrdCtgValMainId
	GROUP BY Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId,Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,
	Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,PrdBat.BatchSeqId
	ORDER BY TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId
	UPDATE TempStockLedSummary SET TotalStock=(Opening+Purchase+Sales+Adjustment+Closing)
	
--	UPDATE TempStockLedSummary SET TempStockLedSummary.PurchaseRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummary,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummary.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND TempStockLedSummary.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummary.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.ListPrice=1
--	
--	UPDATE TempStockLedSummary SET TempStockLedSummary.SellingRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummary,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummary.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND TempStockLedSummary.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummary.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummary.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.SelRte=1
	UPDATE TRSS SET TRSS.SellingRate=DPH.SellingRate,TRSS.PurchaseRate=DPH.PurchaseRate
	FROM TempStockLedSummary TRSS,DefaultPriceHistory DPH
	WHERE TRSS.PrdId=DPH.PrdId AND TRSS.PrdBatId=DPH.PrdBatId 
	AND TransDate BETWEEN DPH.FromDate AND (CASE DPH.ToDate WHEN '1900-01-01' THEN GETDATE() ELSE DPH.ToDate END)
	
	UPDATE TempStockLedSummary SET OpnPurRte=Opening * PurchaseRate,PurPurRte=Purchase * PurchaseRate,
	SalPurRte=Sales * PurchaseRate,AdjPurRte=Adjustment * PurchaseRate,CloPurRte=Closing * PurchaseRate,
	OpnSelRte=Opening * SellingRate,PurSelRte=Purchase * SellingRate,SalSelRte=Sales * SellingRate,
	AdjSelRte=Adjustment * SellingRate,CloSelRte=Closing * SellingRate
	
	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
		UPDATE TSL SET OpnPurRte=OpnPurRte+(Opening*ISNULL(Tax.PurchaseTaxAmount,0)),
		PurPurRte=PurPurRte+(Purchase*ISNULL(Tax.PurchaseTaxAmount,0)),
		SalPurRte=SalPurRte+(Sales*ISNULL(Tax.PurchaseTaxAmount,0)),
		AdjPurRte=AdjPurRte+(Adjustment*ISNULL(Tax.PurchaseTaxAmount,0)),
		CloPurRte=CloPurRte+(Closing*ISNULL(Tax.PurchaseTaxAmount,0)),
		OpnSelRte=OpnSelRte+(Opening*ISNULL(Tax.SellingTaxAmount,0)),
		PurSelRte=PurSelRte+(Purchase*ISNULL(Tax.SellingTaxAmount,0)),
		SalSelRte=SalSelRte+(Sales*ISNULL(Tax.SellingTaxAmount,0)),
		AdjSelRte=AdjSelRte+(Adjustment*ISNULL(Tax.SellingTaxAmount,0)),
		CloSelRte=CloSelRte+(Closing*ISNULL(Tax.SellingTaxAmount,0))
		FROM TempStockLedSummary TSL LEFT OUTER JOIN TaxForReport Tax
		ON Tax.PrdId=TSL.PrdId AND Tax.PrdBatId=TSL.PrdBatId AND TSL.UserId= Tax.UsrId AND Tax.RptId=100
	END
--	SELECT * FROM TempStockLedSummary ORDER BY PrdId,PrdBatId,LcnId,TransDate
	
	SELECT MIN(TransDate) AS MinTransDate,MAX(TransDate) AS MaxTransDate,
	PrdId,PrdBatId,LcnId
	INTO #TempDates
	FROM TempStockLedSummary WHERE UserId=@Pi_UserId	
	GROUP BY PrdId,PrdBatId,LcnId
	ORDER BY PrdId,PrdBatId,LcnId
		
	
	INSERT INTO TempStockLedSummaryTotal(PrdId,PrdBatId,LcnId,Opening,Purchase,Sales,Adjustment,Closing,
	PurchaseRate,OpnPurRte,PurPurRte,SalPurRte,AdjPurRte,CloPurRte,SellingRate,OpnSelRte,PurSelRte,SalSelRte,
	AdjSelRte,CloSelRte,BatchSeqId,PrdCtgValLinkCode,CmpId,Status,UserId,TotalStock)
	SELECT T.PrdId,T.PrdBatId,T.LcnId,T.Opening,T.Purchase,T.Sales,T.Adjustment,T.Closing,
	T.PurchaseRate,T.OpnPurRte,T.PurPurRte,T.SalPurRte,T.AdjPurRte,T.CloPurRte,T.SellingRate,
	T.OpnSelRte,T.PurSelRte,T.SalSelRte,T.AdjSelRte,T.CloSelRte,T.BatchSeqId,T.PrdCtgValLinkCode,
	T.CmpId,T.Status,T.UserId,T.TotalStock
	FROM TempStockLedSummary T,#TempDates TD
	WHERE T.PrdId=TD.PrdId AND T.PrdBatId=TD.PrdBatId AND T.LcnId=TD.LcnId
	AND T.TransDate=TD.MinTransDate AND T.UserId=@Pi_UserId
	
	SELECT T.PrdId,T.PrdBatId,T.LcnId,SUM(T.Purchase) AS TotPur,SUM(T.Sales) AS TotSal,
	SUM(T.Adjustment) AS TotAdj
	INTO #TemDetails
	FROM TempStockLedSummary T,#TempDates TD
	WHERE T.PrdId=TD.PrdId AND T.PrdBatId=TD.PrdBatId AND T.LcnId=TD.LcnId
	AND T.TransDate BETWEEN TD.MinTransDate AND TD.MaxTransDate AND T.UserId=@Pi_UserId
	GROUP BY T.PrdId,T.PrdBatId,T.LcnId
	UPDATE TempStockLedSummaryTotal SET Purchase=TotPur,Sales=TotSal,
	Adjustment=TotAdj
	FROM #TemDetails T
	WHERE T.PrdId=TempStockLedSummaryTotal.PrdId AND T.PrdBatId=TempStockLedSummaryTotal.PrdBatId AND
	T.LcnId=TempStockLedSummaryTotal.LcnId
	UPDATE TempStockLedSummaryTotal SET Closing=Opening+Purchase-Sales+Adjustment
--	UPDATE TempStockLedSummaryTotal SET TempStockLedSummaryTotal.PurchaseRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummaryTotal,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummaryTotal.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND TempStockLedSummaryTotal.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummaryTotal.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.ListPrice=1
--	
--	UPDATE TempStockLedSummaryTotal SET TempStockLedSummaryTotal.SellingRate=PrdBatDet.PrdBatDetailValue
--	FROM TempStockLedSummaryTotal,ProductBatchDetails PrdBatDet,ProductBatch PrdBat,BatchCreation BatCr,Product Prd
--	WHERE TempStockLedSummaryTotal.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo
--	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
--	AND BatCr.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND TempStockLedSummaryTotal.PrdId=PrdBat.PrdId
--	AND PrdBat.BatchSeqId=TempStockLedSummaryTotal.BatchSeqId
--	AND PrdBat.PrdId=TempStockLedSummaryTotal.PrdID
--	AND PrdBat.PrdId=Prd.PrdID
--	AND BatCr.SelRte=1
--	UPDATE TRSS SET TRSS.SellingRate=DPH.SellingRate,TRSS.PurchaseRate=DPH.PurchaseRate
--	FROM TempStockLedSummaryTotal TRSS,DefaultPriceHistory DPH
--	WHERE TRSS.PrdId=DPH.PrdId AND TRSS.PrdBatId=DPH.PrdBatId 
--	AND TransDate BETWEEN DPH.FromDate AND (CASE DPH.ToDate WHEN '1900-01-01' THEN GETDATE() ELSE DPH.ToDate END)
	UPDATE TempStockLedSummaryTotal SET OpnPurRte=Opening * PurchaseRate,PurPurRte=Purchase * PurchaseRate,
	SalPurRte=Sales * PurchaseRate,AdjPurRte=Adjustment * PurchaseRate,CloPurRte=Closing * PurchaseRate,
	OpnSelRte=Opening * SellingRate,PurSelRte=Purchase * SellingRate,SalSelRte=Sales * SellingRate,
	AdjSelRte=Adjustment * SellingRate,CloSelRte=Closing * SellingRate
	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
		UPDATE TSLT SET OpnPurRte=OpnPurRte+(Opening*ISNULL(Tax.PurchaseTaxAmount,0)),
		PurPurRte=PurPurRte+(Purchase*ISNULL(Tax.PurchaseTaxAmount,0)),
		SalPurRte=SalPurRte+(Sales*ISNULL(Tax.PurchaseTaxAmount,0)),
		AdjPurRte=AdjPurRte+(Adjustment*ISNULL(Tax.PurchaseTaxAmount,0)),
		CloPurRte=CloPurRte+(Closing*ISNULL(Tax.PurchaseTaxAmount,0)),
		OpnSelRte=OpnSelRte+(Opening*ISNULL(Tax.SellingTaxAmount,0)),
		PurSelRte=PurSelRte+(Purchase*ISNULL(Tax.SellingTaxAmount,0)),
		SalSelRte=SalSelRte+(Sales*ISNULL(Tax.SellingTaxAmount,0)),
		AdjSelRte=AdjSelRte+(Adjustment*ISNULL(Tax.SellingTaxAmount,0)),
		CloSelRte=CloSelRte+(Closing*ISNULL(Tax.SellingTaxAmount,0))
		FROM TempStockLedSummaryTotal TSLT LEFT OUTER JOIN TaxForReport Tax ON 
		Tax.PrdId=TSLT.PrdId AND Tax.PrdBatId=TSLT.PrdBatId AND
		TSLT.UserId= Tax.UsrId AND Tax.RptId=100
	END	
END
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.0',418
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 418)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(418,'D','2014-09-16',GETDATE(),1,'Core Stocky Service Pack 418')