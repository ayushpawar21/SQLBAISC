--[Stocky HotFix Version]=428
DELETE FROM Versioncontrol WHERE Hotfixid='428'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('428','3.1.0.5','D','2016-08-29','2016-08-29','2016-08-29',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Aug CR')
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' and NAME='Proc_CN2CS_ProductCodeUnification')
DROP PROCEDURE Proc_CN2CS_ProductCodeUnification
GO
/*
  BEGIN TRANSACTION
  EXEC Proc_CN2CS_ProductCodeUnification 0
  SELECT * FROM Errorlog (NOLOCK)
  select * from ProductBatch (Nolock) where PrdId IN(3003,3004,3005)
  select * from ProductBatchDetails A (Nolock) INNER JOIN  ProductBatch B (Nolock) ON A.PrdBatId = B.PrdBatId where PrdId IN(3003,3004,3005)
  select * from ProductBatchLocation (Nolock) where PrdId IN(3003,3004,3005)
  SELECT * FROM CN2CS_Prk_ProductCodeUnification (NOLOCK) 
  ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_CN2CS_ProductCodeUnification
(
       @Po_ErrNo INT OUTPUT
)
AS
/*****************************************************************************
* PROCEDURE      : Proc_CN2CS_ProductCodeUnification
* PURPOSE        : To Mapped the Sub Products to Main Products
* CREATED BY     : Sathishkumar Veeramani 18-11-2014
* MODIFIED       :
* DATE      AUTHOR     DESCRIPTION
* {DATE} {DEVELOPER}  {BRIEF MODIFICATION DESCRIPTION}
*******************************************************************************/
SET NOCOUNT ON
BEGIN
SET @Po_ErrNo = 0
DECLARE @ToPrdId     AS NUMERIC(18,0)
DECLARE @PrdId       AS NUMERIC(18,0)
DECLARE @PrdBatId    AS NUMERIC(18,0)
DECLARE @ToPrdBatId  AS NUMERIC(18,0)
DECLARE @LcnId       AS BIGINT
DECLARE @SalTotQty   AS NUMERIC(18,0)
DECLARE @UnSalTotQty AS NUMERIC(18,0)
DECLARE @OfferTotQty AS NUMERIC(18,0)
DECLARE @SalQty      AS NUMERIC(18,0)
DECLARE @UnSalQty    AS NUMERIC(18,0)
DECLARE @OfferQty    AS NUMERIC(18,0)
DECLARE @InvDate     AS DATETIME

DECLARE @LcnIdCheck AS INT
DECLARE @Pi_ErrNo AS TINYINT
DECLARE @Pi_PrdbatLcn AS TINYINT
DECLARE @Pi_StkLedger AS TINYINT
DECLARE @MaxNo as INT
DECLARE @MinNo as INT
DECLARE @CurrValue AS BIGINT
DECLARE @StkKeyNumber AS VARCHAR(50)
DECLARE @iDecPoint AS INT
DECLARE @iRate AS Numeric(18,6)
DECLARE @UomId AS INT
DECLARE @SalPriceId AS BIGINT
DECLARE @StockTypeId AS INT

DECLARE @iReduceRate AS Numeric(18,6)
DECLARE @ReduceSalPriceId AS BIGINT
DECLARE @ReduceUomId AS INT

DELETE FROM CN2CS_Prk_ProductCodeUnification WHERE DownLoadFlag = 'Y'

	CREATE TABLE #ToAvoidProducts
	(
	  ProductCode NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
	  MapProductCode NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS
	)
	
	CREATE TABLE #Location
	(
		Slno INT IDENTITY (1,1),
		LcnId INT
	)	
	
	
	BEGIN TRY
			--Product Validations
			INSERT INTO #ToAvoidProducts (ProductCode,MapProductCode)
			SELECT DISTINCT ProductCode,MapProductCode FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
			WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.ProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
			
			INSERT INTO Errorlog (SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Product','PrdCCode',ProductCode+'-Product Or ProductBatch Not Available' 
			FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
			WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.ProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
			
			INSERT INTO #ToAvoidProducts (ProductCode,MapProductCode)
			SELECT DISTINCT ProductCode,MapProductCode FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
			WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.MapProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
			
			INSERT INTO Errorlog (SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Product','PrdCCode',MapProductCode+'-Product Code Not Available' 
			FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
			WHERE NOT EXISTS (SELECT PrdCCode FROM Product B (NOLOCK) WHERE A.MapProductCode = B.PrdCCode) AND DownLoadFlag = 'D'
			
			--Main Product Code Unique Validation
			INSERT INTO #ToAvoidProducts (ProductCode,MapProductCode)
			SELECT DISTINCT ProductCode,A.MapProductCode FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) INNER JOIN
			(SELECT COUNT(DISTINCT ProductCode) AS Counts,MapProductCode FROM CN2CS_Prk_ProductCodeUnification (NOLOCK)
			GROUP BY MapProductCode HAVING COUNT(DISTINCT ProductCode) > 1)B ON A.MapProductCode = B.MapProductCode
			WHERE DownLoadFlag = 'D'
			
			INSERT INTO Errorlog (SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'CN2CS_Prk_ProductCodeUnification','ProductCode',ProductCode+'-Mapped More than One Products' 
			 FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) INNER JOIN
			(SELECT COUNT(DISTINCT ProductCode) AS Counts,MapProductCode FROM CN2CS_Prk_ProductCodeUnification (NOLOCK)
			GROUP BY MapProductCode HAVING COUNT(DISTINCT ProductCode) > 1)B ON A.MapProductCode = B.MapProductCode
			WHERE DownLoadFlag = 'D'
			
			--Unification Product Batch Creation
			--Parent Product & Child Product 
			SELECT DISTINCT B.PrdId AS PPrdId,B.TaxGroupId,C.PrdId AS CPrdId 
			INTO #ProductCodeUnification 
			FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK)
			INNER JOIN Product B (NOLOCK) ON A.ProductCode = B.PrdCCode
			INNER JOIN Product C (NOLOCK) ON A.MapProductCode = C.PrdCCode
			WHERE NOT EXISTS (SELECT DISTINCT ProductCode,MapProductCode FROM #ToAvoidProducts D WHERE A.ProductCode = D.ProductCode 
			AND A.MapProductCode = D.MapProductCode) 
			AND NOT EXISTS (SELECT DISTINCT PrdId FROM ProductBatch E (NOLOCK) WHERE B.PrdId = E.PrdId)
			AND DownLoadFlag = 'D' ORDER BY PPrdId,CPrdId ASC
			
			--Child Product Latest Batch
			SELECT DISTINCT PPrdId,TaxGroupId,MAX(CPrdBatId) AS CPrdBatId INTO #ProductBatch FROM (
			SELECT DISTINCT PPrdId,TaxGroupId,CPrdId,CPrdBatId FROM #ProductCodeUnification A INNER JOIN
			(SELECT PrdId,MAX(PrdBatId) AS CPrdBatId FROM ProductBatch (NOLOCK) GROUP BY PrdId)B ON A.CPrdId = B.PrdId)Qry
			GROUP BY PPrdId,TaxGroupId
			
			--Child Product Latest Batch Details
			SELECT PPrdId,TaxGroupId,CPrdBatId,CPriceId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue
			INTO #ProductBatchDetails 
			FROM #ProductBatch A INNER JOIN
			(
		    
				SELECT DISTINCT PrdBatId,MAX(PriceId) AS CPriceId FROM ProductBatchDetails (NOLOCK)  WHERE DefaultPrice=1 
				GROUP BY PrdBatId
		   
			)B ON A.CPrdBatId = B.PrdBatId
			INNER JOIN ProductBatchDetails C (NOLOCK) ON A.CPrdBatId = C.PrdBatId AND B.PrdBatId = C.PrdBatId AND B.CPriceId = C.PriceId
		   
		 
		    
			DECLARE @UPrdBatId AS NUMERIC(18,0)
			DECLARE @UPriceId  AS NUMERIC(18,0)
			SELECT @UPrdBatId = ISNULL(MAX(PrdBatId),0) FROM ProductBatch (NOLOCK)
			SELECT @UPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
		    
			SELECT DISTINCT A.PPrdId,(DENSE_RANK()OVER (ORDER BY PPrdId ASC)+@UPrdBatId) AS PPrdBatId,A.TaxGroupId,PrdBatCode,
			CmpBatCode,MnfDate,ExpDate,BatchSeqId,DecPoints,EnableCloning,CPrdBatId INTO #ParentProductBatch 
			FROM #ProductBatch A INNER JOIN ProductBatch B (NOLOCK) ON A.CPrdBatId = B.PrdBatId 

			SELECT DISTINCT A.PPrdId,PPrdBatId,(DENSE_RANK()OVER(ORDER BY A.PPrdId,PPrdBatId ASC)+@UPriceId) AS PPriceId,
			PriceCode,B.BatchSeqId,SLNo,PrdBatDetailValue INTO #ParentProductBatchDetails 
			FROM #ParentProductBatch A INNER JOIN #ProductBatchDetails B ON A.PPrdId = B.PPrdId AND A.CPrdBatId = B.CPrdBatId
			
					
		    BEGIN TRANSACTION
						--To Insert Product Batch & ProductBatchDetails
						INSERT INTO ProductBatch(PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,[Status],TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,
						EnableCloning,Availability,LastModBy,LastModDate,AuthId,AuthDate) 
						SELECT DISTINCT A.PPrdId,A.PPrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,1 AS [Status],TaxGroupId,A.BatchSeqId,DecPoints,
						PPriceId,EnableCloning,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) 
						FROM #ParentProductBatch A INNER JOIN #ParentProductBatchDetails B ON A.PPrdId = B.PPrdId AND A.PPrdBatId = B.PPrdBatId
						ORDER BY A.PPrdId,A.PPrdBatId,PPriceId
						
						INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,Availability,
						LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
						SELECT PPriceId,PPrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,
						CONVERT(NVARCHAR(10),GETDATE(),121),0 
						FROM #ParentProductBatchDetails ORDER BY PPriceId,PPrdBatId
					    
						--Current Stock Reports
						IF EXISTS (SELECT DISTINCT PPriceId FROM #ParentProductBatchDetails)
						BEGIN
							EXEC Proc_DefaultPriceHistory 0,0,@UPriceId,2,1
						END	
						--Till Here

						SELECT @UPrdBatId = ISNULL(MAX(PrdBatId),0) FROM ProductBatch (NOLOCK)
						UPDATE Counters SET CurrValue = @UPrdBatId WHERE TabName = 'ProductBatch' AND FldName = 'PrdBatId'
						SELECT @UPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
						UPDATE Counters SET CurrValue = @UPriceId WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'
						
						--Mapped Products Stock Posting
						SELECT DISTINCT D.PrdId AS ToPrdId,A.PrdId,PrdBatId,LcnId,(PrdBatLcnSih-PrdBatLcnRessih) AS SalStock,
						(PrdBatLcnUih-PrdBatLcnResUih) AS UnSalStock,(PrdBatLcnFre-PrdBatLcnResFre) AS OfferStock INTO #ProductBatchLocation
						FROM ProductBatchLocation A (NOLOCK) INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId
						INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
						INNER JOIN Product D (NOLOCK) ON C.ProductCode = D.PrdCCode 
						WHERE (PrdBatLcnSih-PrdBatLcnRessih)+(PrdBatLcnUih-PrdBatLcnResUih)+(PrdBatLcnFre-PrdBatLcnResFre) > 0 AND DownLoadFlag = 'D' AND
						NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts TA WHERE C.ProductCode = TA.ProductCode AND C.MapProductCode = TA.MapProductCode)
						    	
						SELECT DISTINCT ToPrdId,ToPrdBatId INTO #ParentProductLatestBatch FROM #ProductBatchLocation A INNER JOIN
						(SELECT DISTINCT PrdId,MAX(PrdBatId) AS ToPrdBatId FROM ProductBatch (NOLOCK) GROUP BY PrdId)B ON A.ToPrdId = B.PrdId
						ORDER BY ToPrdId
						
						SELECT DISTINCT A.ToPrdId,ToPrdBatId,PrdId,PrdBatId,LcnId,SalStock,UnSalStock,OfferStock INTO #ManualStockPosting
						FROM #ProductBatchLocation A INNER JOIN #ParentProductLatestBatch B ON A.ToPrdId = B.ToPrdId
						ORDER BY A.ToPrdId,ToPrdBatId,PrdId,PrdBatId
						
						
						
						INSERT INTO #Location(LcnId)
						SELECT DISTINCT  LcnId FROM #ManualStockPosting WHERE ISNULL(LcnId,0)>0
						
					
						
						SET @Pi_ErrNo=0
						SET @Pi_PrdbatLcn=0
						SET @Pi_StkLedger=0
						SET @LcnIdCheck=0
						SET @MinNo=1
								
								
								SELECT @MaxNo= Max(Slno) FROM  #Location
								
								WHILE @MinNo<=@MaxNo
								BEGIN
										
											
											SELECT @LcnIdCheck=LcnId FROM #Location WHERE Slno=@MinNo
											
											SET @StkKeyNumber=''
											SELECT @CurrValue= Currvalue+1 FROM Counters (NOLOCK) WHERE TabName='StockManagement' AND FldName='StkMngRefNo'

											SELECT @StkKeyNumber=PreFix+CAST(SUBSTRING(CAST(CurYear as Varchar(10)),3,LEN(CurYear)) AS Varchar(10))+REPLICATE('0',CASE WHEN LEN(@CurrValue)>ZPad THEN (ZPad+1)-LEN(@CurrValue) ELSE (ZPad)-LEN(@CurrValue)END)+CAST(@CurrValue as Varchar(10)) 			
											FROM Counters (NOLOCK) WHERE TabName='StockManagement' AND FldName='StkMngRefNo'
											
											SET @iDecPoint=2
											SELECT @iDecPoint=ConfigValue FROM Configuration WHERE Description='Calculation Decimal Digit Value' AND ModuleName='General Configuration'
											
											UPDATE  Counters SET CurrValue= CurrValue+1 WHERE TabName='StockManagement' AND FldName='StkMngRefNo'
											
											IF (@LcnIdCheck<=0 OR LEN(LTRIM(RTRIM(@StkKeyNumber)))<=0)
											BEGIN
												SET @Po_ErrNo=1												
												RETURN
												
											END
										
											IF (@LcnIdCheck>0 and LEN(LTRIM(RTRIM(@StkKeyNumber)))>0 )
											BEGIN						
												
												INSERT INTO StockManagement(StkMngRefNo,StkMngDate,LcnId,StkMgmtTypeId,RtrId,SpmId,DocRefNo,Remarks,DecPoints,
												OpenBal,Status,Availability,LastModBy,LastModDate,AuthId,AuthDate,ConfigValue,XMLUpload)				
												SELECT @StkKeyNumber,CONVERT(DATETIME,CONVERT(NVARCHAR(10),GETDATE(),121),121),@LcnIdCheck,0,0,0,'','Product Code Unification ',@iDecPoint,
												0,1,1,1,CONVERT(DATETIME,CONVERT(NVARCHAR(10),GETDATE(),121),121),1,CONVERT(DATETIME,CONVERT(NVARCHAR(10),GETDATE(),121),121),1,0
												
												
												DECLARE CUR_STOCKADJIN CURSOR
												FOR SELECT DISTINCT ToPrdId,ToPrdBatId,LcnId,PrdId,PrdBatId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalTotStock,
												SUM(UnSalStock) AS UnSalTotStock,SUM(OfferStock) AS OfferTotStock FROM #ManualStockPosting WITH (NOLOCK)
												WHERE  LcnId=@LcnIdCheck
												GROUP BY ToPrdId,ToPrdBatId,LcnId,PrdId,PrdBatId ORDER BY ToPrdId,ToPrdBatId
												OPEN CUR_STOCKADJIN		
												FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@PrdId,@PrdBatId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
												WHILE @@FETCH_STATUS = 0
												BEGIN	
												
														SET @SalPriceId=0
														SET @iRate=0.00
														SET @UomId=0
														SET @StockTypeId=0
														
														SET @iReduceRate=0.00
														SET @ReduceSalPriceId=0
														SET @ReduceUomId=0
														
														SELECT @SalPriceId=ISNULL(PriceId,0),@iRate=PrdBatDetailValue 
														FROM Product A INNER JOIN Productbatch PB (NOLOCK) ON A.Prdid=PB.Prdid
														INNER JOIN BatchCreation B (NOLOCK) ON PB.BatchSeqId=B.BatchSeqId 
														INNER JOIN Productbatchdetails PBD (NOLOCK) ON PBD.PrdbatId= PB.Prdbatid and PBD.Slno=B.Slno
														WHERE PB.PrdbatId= @ToPrdBatId and   DefaultPrice=1 and  ListPrice=1  and A.PrdId=@ToPrdId
														
														SELECT @UomId=UomId FROM Uomgroup U (NOLOCK) INNER JOIN Product P (NOLOCK) ON U.UomgroupId=P.UomGroupId
														WHERE Prdid=@ToPrdId and BaseUom='Y' 
														
														
														SELECT @ReduceSalPriceId=ISNULL(PriceId,0),@iReduceRate=PrdBatDetailValue 
														FROM Product A INNER JOIN Productbatch PB (NOLOCK) ON A.Prdid=PB.Prdid
														INNER JOIN BatchCreation B (NOLOCK) ON PB.BatchSeqId=B.BatchSeqId 
														INNER JOIN Productbatchdetails PBD (NOLOCK) ON PBD.PrdbatId= PB.Prdbatid and PBD.Slno=B.Slno
														WHERE PB.PrdbatId= @PrdBatId and   DefaultPrice=1 and  ListPrice=1
														and A.PrdId=@PrdId

														SELECT @ReduceUomId=UomId FROM Uomgroup U (NOLOCK) INNER JOIN Product P (NOLOCK) ON U.UomgroupId=P.UomGroupId
														WHERE Prdid=@PrdId and BaseUom='Y' 
												
														IF @SalTotQty > 0 
														BEGIN
															SELECT @StockTypeId=StockTypeId from StockType with (nolock) where LcnId=@LcnId and SystemStockType=1
																
															INSERT INTO StockManagementproduct(							
															StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
															UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
															AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
															SELECT @StkKeyNumber,@ToPrdId,@ToPrdBatId,@StockTypeId,	@UomId,@SalTotQty,0,0,@SalTotQty,
															@iRate,@iRate*@SalTotQty,0,@SalPriceId,1,111,@InvDate,1,@InvDate,0.00,1
															
															SET @Pi_ErrNo=0
															SET @Pi_PrdbatLcn=0	
															SET @Pi_StkLedger=0					
															--SALEABLE STOCK IN									
															EXEC Proc_UpdateStockLedger 10,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
															EXEC Proc_UpdateProductBatchLocation 1,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT		
															
															
															IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
															BEGIN												
																SET @Po_ErrNo=1
																CLOSE CUR_STOCKADJIN
																DEALLOCATE CUR_STOCKADJIN
																ROLLBACK TRANSACTION
																RETURN
															END
															
															--SALEABLE STOCK OUT																													
															INSERT INTO StockManagementproduct(							
															StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
															UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
															AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
															SELECT @StkKeyNumber,@PrdId,@PrdBatId,@StockTypeId,	@ReduceUomId,@SalTotQty,0,0,@SalTotQty,
															@iReduceRate,@iReduceRate*@SalTotQty,0,@ReduceSalPriceId,1,111,@InvDate,1,@InvDate,0.00,2
															
													
															
															SET @Pi_ErrNo=0
															SET @Pi_PrdbatLcn=0	
															SET @Pi_StkLedger=0	
															
															EXEC Proc_UpdateStockLedger 13,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
															EXEC Proc_UpdateProductBatchLocation 1,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT	
															
															IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
															BEGIN
																								
																SET @Po_ErrNo=1
																CLOSE CUR_STOCKADJIN
																DEALLOCATE CUR_STOCKADJIN
																ROLLBACK TRANSACTION
																RETURN
															END
															--TILL HERE
															
														END
														IF @UnSalTotQty > 0
														BEGIN
														
														
															SELECT @StockTypeId=StockTypeId from StockType with (nolock) where LcnId=@LcnId and SystemStockType=2
																
															INSERT INTO StockManagementproduct(							
															StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
															UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
															AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
															SELECT @StkKeyNumber,@ToPrdId,@ToPrdBatId,@StockTypeId,	@UomId,@UnSalTotQty,0,0,@UnSalTotQty,
															@iRate,@iRate*@UnSalTotQty,0,@SalPriceId,1,111,@InvDate,1,@InvDate,0.00,1
															
															
															SET @Pi_ErrNo=0
															SET @Pi_PrdbatLcn=0	
															SET @Pi_StkLedger=0	
														   --UNSALEABLE STOCK IN									
															EXEC Proc_UpdateStockLedger 11,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
															EXEC Proc_UpdateProductBatchLocation 2,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT
															
															IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
															BEGIN
																
																SET @Po_ErrNo=1
																CLOSE CUR_STOCKADJIN
																DEALLOCATE CUR_STOCKADJIN
																ROLLBACK TRANSACTION
																RETURN
															END
																
															--UNSALEABLE STOCK OUT
															INSERT INTO StockManagementproduct(							
															StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
															UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
															AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
															SELECT @StkKeyNumber,@PrdId,@PrdBatId,@StockTypeId,	@ReduceUomId,@UnSalTotQty,0,0,@UnSalTotQty,
															@iReduceRate,@iReduceRate*@UnSalTotQty,0,@ReduceSalPriceId,1,111,@InvDate,1,@InvDate,0.00,2
															
																														
															SET @Pi_ErrNo=0
															SET @Pi_PrdbatLcn=0	
															SET @Pi_StkLedger=0	
															
															EXEC Proc_UpdateStockLedger 14,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
															EXEC Proc_UpdateProductBatchLocation 2,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT
															
															IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
															BEGIN
																
																SET @Po_ErrNo=1
																CLOSE CUR_STOCKADJIN
																DEALLOCATE CUR_STOCKADJIN
																ROLLBACK TRANSACTION
																RETURN
															END
															
															--Till HERE		
																
														END
														IF @OfferTotQty > 0 
														BEGIN
															
															SELECT @StockTypeId=StockTypeId from StockType with (nolock) where LcnId=@LcnId and SystemStockType=3
																
															INSERT INTO StockManagementproduct(							
															StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
															UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
															AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
															SELECT @StkKeyNumber,@ToPrdId,@ToPrdBatId,@StockTypeId,	@UomId,@OfferTotQty,0,0,@OfferTotQty,
															0.00,0.00,0,@SalPriceId,1,111,@InvDate,1,@InvDate,0.00,1
															
														
															--OFFER STOCK IN
															SET @Pi_ErrNo=0
															SET @Pi_PrdbatLcn=0	
															SET @Pi_StkLedger=0
																								
															EXEC Proc_UpdateStockLedger 12,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
															EXEC Proc_UpdateProductBatchLocation 3,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT
															IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
															BEGIN
																
																SET @Po_ErrNo=1
																CLOSE CUR_STOCKADJIN
																DEALLOCATE CUR_STOCKADJIN
																ROLLBACK TRANSACTION
																RETURN
															END
															
															--OFFER STOCK OUT
															
															INSERT INTO StockManagementproduct(							
															StkMngRefNo,PrdId,PrdBatId,	StockTypeId,UOMId1,Qty1,
															UOMId2,Qty2,TotalQty,Rate,Amount,ReasonId,PriceId,Availability,LastModBy,LastModDate,
															AuthId,AuthDate,TaxAmt,StkMgmtTypeId)								
															SELECT @StkKeyNumber,@PrdId,@PrdBatId,@StockTypeId,	@ReduceUomId,@OfferTotQty,0,0,@OfferTotQty,
															0.00,0.00,0,0,1,111,@InvDate,1,@InvDate,0.00,2
															
															
															
															SET @Pi_ErrNo=0
															SET @Pi_PrdbatLcn=0	
															SET @Pi_StkLedger=0
															
															EXEC Proc_UpdateStockLedger 15,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferTotQty,1,@Pi_ErrNo=@Pi_PrdbatLcn OUTPUT
															EXEC Proc_UpdateProductBatchLocation 3,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferTotQty,1,@Pi_ErrNo=@Pi_StkLedger OUTPUT
															
															IF (@Pi_PrdbatLcn<>0 OR @Pi_StkLedger<>0)
															BEGIN
																
																SET @Po_ErrNo=1
																CLOSE CUR_STOCKADJIN
																DEALLOCATE CUR_STOCKADJIN
																ROLLBACK TRANSACTION
																RETURN
															END
															
														END
														
														--SELECT 'X',* from ProductBatchLocation (NOLOCK) where PrdId=@ToPrdId and prdbatId=@ToPrdBatId and LcnId=@LcnId
														--SELECT 'Y',* from ProductBatchLocation (NOLOCK) where PrdId=@PrdId and prdbatId=@PrdBatId and LcnId=@LcnId
														--SELECT 'X',* from StockLedger (NOLOCK) where PrdId=@ToPrdId and prdbatId=@ToPrdBatId and LcnId=@LcnId and TransDate=@InvDate
														--SELECT 'Y',* from StockLedger (NOLOCK) where PrdId=@PrdId and prdbatId=@PrdBatId and LcnId=@LcnId and TransDate=@InvDate
																
												FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@PrdId,@PrdBatId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
												END
												CLOSE CUR_STOCKADJIN
												DEALLOCATE CUR_STOCKADJIN
												--Till Here
												
												
												
											END	
											
											
									SET @MinNo=@MinNo+1	
								END					
															
								
								
				
						
						---COMMENTED BY Murugan.R 05/07/2016,Reason Stock adjustment Transaction details not capture in previous version 427	
						--Main Product Stock Posting IN
						--DECLARE CUR_STOCKADJIN CURSOR
						--FOR SELECT DISTINCT ToPrdId,ToPrdBatId,LcnId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalTotStock,
						--SUM(UnSalStock) AS UnSalTotStock,SUM(OfferStock) AS OfferTotStock FROM #ManualStockPosting WITH (NOLOCK) 
						--GROUP BY ToPrdId,ToPrdBatId,LcnId ORDER BY ToPrdId,ToPrdBatId
						--OPEN CUR_STOCKADJIN		
						--FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
						--WHILE @@FETCH_STATUS = 0
						--BEGIN	
						--        IF @SalTotQty > 0
						--        BEGIN
						--            --SALEABLE STOCK IN									
						--			EXEC Proc_UpdateStockLedger 10,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,0
						--			EXEC Proc_UpdateProductBatchLocation 1,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,0		
						--		END
						--		IF @UnSalTotQty > 0
						--		BEGIN
						--		   --UNSALEABLE STOCK IN									
						--			EXEC Proc_UpdateStockLedger 11,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,0
						--			EXEC Proc_UpdateProductBatchLocation 2,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,0
						--		END
						--		IF @OfferTotQty > 0
						--		BEGIN
						--		    --OFFER STOCK IN									
						--			EXEC Proc_UpdateStockLedger 12,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,0
						--			EXEC Proc_UpdateProductBatchLocation 3,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,0
						--		END
										
						--FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
						--END
						--CLOSE CUR_STOCKADJIN
						--DEALLOCATE CUR_STOCKADJIN
						----Till Here
						
						----Mapped Product Stock Posting OUT
						--DECLARE CUR_STOCKADJOUT CURSOR
						--FOR SELECT DISTINCT PrdId,PrdBatId,LcnId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalStock,
						--SUM(UnSalStock) AS UnSalStock,SUM(OfferStock) AS OfferStock FROM #ManualStockPosting WITH (NOLOCK) 
						--GROUP BY PrdId,PrdBatId,LcnId ORDER BY PrdId,PrdBatId
						--OPEN CUR_STOCKADJOUT		
						--FETCH NEXT FROM CUR_STOCKADJOUT INTO @PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,@UnSalQty,@OfferQty
						--WHILE @@FETCH_STATUS = 0
						--BEGIN	
						--        IF @SalQty > 0
						--        BEGIN
						--			--SALEABLE STOCK OUT
						--			EXEC Proc_UpdateStockLedger 13,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,1,0
						--			EXEC Proc_UpdateProductBatchLocation 1,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,1,0				
						--		END
						--		IF @UnSalQty > 0
						--		BEGIN
						--			--UNSALEABLE STOCK OUT
						--			EXEC Proc_UpdateStockLedger 14,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalQty,1,0
						--			EXEC Proc_UpdateProductBatchLocation 2,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalQty,1,0
						--		END
						--		IF @OfferQty > 0
						--		BEGIN
						--			--OFFER STOCK OUT
						--			EXEC Proc_UpdateStockLedger 15,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferQty,1,0
						--			EXEC Proc_UpdateProductBatchLocation 3,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferQty,1,0
						--		END
										
						--FETCH NEXT FROM CUR_STOCKADJOUT INTO @PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,@UnSalQty,@OfferQty
						--END
						--CLOSE CUR_STOCKADJOUT
						--DEALLOCATE CUR_STOCKADJOUT	
						--Till Here
						---Till here Murugan.R
						
						SELECT DISTINCT A.PrdId,(SUM(PrdBatLcnSih)-SUM(PrdBatLcnRessih)) AS SalStock,(SUM(PrdBatLcnUih)-SUM(PrdBatLcnResUih)) AS UnSalStock,
						(SUM(PrdBatLcnFre)-SUM(PrdBatLcnResFre)) AS OfferStock INTO #FinalStockAvailable 
						FROM ProductBatchLocation A (NOLOCK) 
						INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId 
						INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
						WHERE NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts TA WHERE C.ProductCode = TA.ProductCode AND C.MapProductCode = TA.MapProductCode)
						GROUP BY A.PrdId
						HAVING (SUM(PrdBatLcnSih)-SUM(PrdBatLcnRessih))+(SUM(PrdBatLcnUih)-SUM(PrdBatLcnResUih))+(SUM(PrdBatLcnFre)-SUM(PrdBatLcnResFre)) > 0
						
						--Mapped Products and Product Batches are Inactivate Validation
						UPDATE A SET A.PrdCtgValMainId = C.PrdCtgValMainId FROM Product A (NOLOCK) 
						INNER JOIN CN2CS_Prk_ProductCodeUnification B (NOLOCK) ON A.PrdCCode = B.MapProductCode
						INNER JOIN Product C (NOLOCK) ON B.ProductCode = C.PrdCCode
						WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts C (NOLOCK)
						WHERE B.ProductCode = C.ProductCode AND B.MapProductCode = C.MapProductCode)
						AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable D WHERE A.PrdId = D.PrdId)
						
						UPDATE A SET A.[Status] = 0 FROM ProductBatch A (NOLOCK) INNER JOIN 
						(SELECT PrdId FROM Product B (NOLOCK) INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
						WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts D (NOLOCK)
						WHERE C.ProductCode = D.ProductCode AND C.MapProductCode = D.MapProductCode)) B ON A.PrdId = B.PrdId
						AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable E WHERE A.PrdId = E.PrdId) 
						
						UPDATE A SET A.[PrdStatus] = 0 FROM Product A (NOLOCK) INNER JOIN CN2CS_Prk_ProductCodeUnification B (NOLOCK) ON A.PrdCCode = B.MapProductCode
						WHERE DownLoadFlag = 'D' AND NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts C (NOLOCK)
						WHERE B.ProductCode = C.ProductCode AND B.MapProductCode = C.MapProductCode)
						AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable D WHERE A.PrdId = D.PrdId) 
						--Till Here
						
						--Moorthi Start Here
						DECLARE @RefNo AS INT
						SELECT @RefNo=ISNULL(MAX(RefNo),0)+1 FROM ProductUnification_Track (NOLOCK)
						
						INSERT INTO ProductUnification_Track(RefNo,ProductCode,ProductName,MapProductCode,CreatedDate)
						SELECT @RefNo,A.ProductCode,A.ProductName,A.MapProductCode,GETDATE() FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
						INNER JOIN Product B (NOLOCK) ON A.MapProductCode = B.PrdCCode WHERE B.[PrdStatus] = 0 AND A.DownLoadFlag = 'D'
						AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable C WHERE B.PrdId = C.PrdId) AND
						NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts D (NOLOCK) WHERE A.ProductCode = D.ProductCode 
						AND A.MapProductCode = D.MapProductCode)	
						--Till Here	
						
						UPDATE A SET A.DownloadFlag = 'Y' FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK) 
						INNER JOIN Product B (NOLOCK) ON A.MapProductCode = B.PrdCCode WHERE B.[PrdStatus] = 0 AND A.DownLoadFlag = 'D'
						AND NOT EXISTS (SELECT PrdId FROM #FinalStockAvailable C WHERE B.PrdId = C.PrdId) AND
						NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts D (NOLOCK) WHERE A.ProductCode = D.ProductCode 
						AND A.MapProductCode = D.MapProductCode)
						

										
						COMMIT TRANSACTION	
						
	END TRY
	BEGIN CATCH
		SET @Po_ErrNo=1
		--select ERROR_MESSAGE()
		CLOSE CUR_STOCKADJIN
		DEALLOCATE CUR_STOCKADJIN		
		ROLLBACK TRAN	
	END CATCH    
	RETURN
END
GO
IF EXISTS (SELECT * FROM SysObjects WHERE name='View_CurrentStockReport' AND XTYPE='V')
DROP VIEW View_CurrentStockReport
GO
CREATE VIEW View_CurrentStockReport
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
SELECT LcnId,LcnName,PrdId,PrdDCode,Prdccode,PrdName,PrdBatId,PrdBatCode,sum(MRP)MRP,sum(SelRate)SelRate,sum(ListPrice)ListPrice,
	Saleable,SaleableWgt ,Unsaleable,UnsaleableWgt ,Offer,OfferWgt ,Total,sum(SalMRP)SalMRP,sum(UnSalMRP)UnSalMRP,sum(TotMRP)TotMRP,sum(SalSelRate)SalSelRate,
	sum(UnSalSelRate)UnSalSelRate,sum(TotSelRate)TotSelRate,sum(SalListPrice)SalListPrice,sum(UnSalListPrice)UnSalListPrice,
	sum(TotListPrice)TotListPrice,PrdStatus,Status,CmpId,PrdCtgValMainId,CmpPrdCtgId,PrdCtgValLinkCode
FROM (
SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,Prd.PrdCCode as PrdCCode,
		Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,PBDM.PrdBatDetailValue AS MRP,
		0 AS SelRate,
		0 AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
		(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
		(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
		(PrdBatLcnSih-PrdBatLcnResSih)* PBDM.PrdBatDetailValue  AS SalMRP,
		(PrdBatLcnUih-PrdBatLcnResUih)* PBDM.PrdBatDetailValue  AS UnSalMRP,
		(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* PBDM.PrdBatDetailValue ) AS TotMRP,
		0 AS SalSelRate,
		0 AS UnSalSelRate,
		0 AS TotSelRate,
		0 AS SalListPrice,
		0 AS UnSalListPrice,
		0 AS TotListPrice,
		Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode--,TxRpt.UsrId
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		 ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
		 ProductBatchDetails PBDM (NOLOCK),BatchCreation BCM (NOLOCK),
		 ProductBatchTaxPercent TxRpt (NOLOCK),
		 ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId AND PrdBat.BatchSeqId=BCM.BatchSeqId
		AND BCM.MRP=1 AND BCM.SlNo=PBDM.SLNo AND PBDM.PrdBatId=PrdBat.PrdBatId  
		AND TxRpt.PrdBatId=PrdBat.PrdBatId  AND TxRpt.PrdId=Prd.PrdId 
		AND PrdBat.DefaultPriceId=PBDM.PriceId   
UNION ALL 
	SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,Prd.PrdCCode as PrdCCode,
		Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,0 AS MRP,
		PBDR.PrdBatDetailValue+((PBDR.PrdBatDetailValue*TxRpt.TaxPercentage)/100) AS SelRate,
		0 AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
		(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
		(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
		0 AS SalMRP,
		0 AS UnSalMRP,
		0 AS TotMRP,
		(PrdBatLcnSih-PrdBatLcnResSih)* (PBDR.PrdBatDetailValue+((PBDR.PrdBatDetailValue*TxRpt.TaxPercentage)/100))  AS SalSelRate,
		(PrdBatLcnUih-PrdBatLcnResUih)* (PBDR.PrdBatDetailValue+((PBDR.PrdBatDetailValue*TxRpt.TaxPercentage)/100))  AS UnSalSelRate,
		(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (PBDR.PrdBatDetailValue+((PBDR.PrdBatDetailValue*TxRpt.TaxPercentage)/100)) ) AS TotSelRate,
		0 AS SalListPrice,
		0 AS UnSalListPrice,
		0 AS TotListPrice,
		Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode--,TxRpt.UsrId
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
		ProductBatchDetails PBDR (NOLOCK),BatchCreation BCR (NOLOCK),
		ProductBatchTaxPercent TxRpt (NOLOCK),
		ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
		AND PrdBat.BatchSeqId=BCR.BatchSeqId
		AND BCR.SelRte=1 AND BCR.SlNo=PBDR.SLNo AND PBDR.PrdBatId=PrdBat.PrdBatId
		AND TxRpt.PrdBatId=PrdBat.PrdBatId  AND TxRpt.PrdId=Prd.PrdId
		AND PrdBat.DefaultPriceId=PBDR.PriceId 
UNION ALL 
	SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,Prd.PrdCCode as PrdCCode,
		Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,0 AS MRP,
		0 AS SelRate,
		PBDL.PrdBatDetailValue+((PBDL.PrdBatDetailValue*TxRpt.TaxPercentage)/100) AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
		(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
		(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
		0 AS SalMRP,
		0 AS UnSalMRP,
		0 AS TotMRP,
		0 AS SalSelRate,
		0 AS UnSalSelRate,
		0 AS TotSelRate,
		(PrdBatLcnSih-PrdBatLcnResSih)* (PBDL.PrdBatDetailValue+((PBDL.PrdBatDetailValue*TxRpt.TaxPercentage)/100))  AS SalListPrice,
		(PrdBatLcnUih-PrdBatLcnResUih)* (PBDL.PrdBatDetailValue+((PBDL.PrdBatDetailValue*TxRpt.TaxPercentage)/100))  AS UnSalListPrice,
		(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (PBDL.PrdBatDetailValue+((PBDL.PrdBatDetailValue*TxRpt.TaxPercentage)/100)) ) AS TotListPrice,
		Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode 
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
		ProductBatchDetails PBDL (NOLOCK),BatchCreation BCL (NOLOCK),
		ProductBatchTaxPercent TxRpt (NOLOCK),
		ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId  
		AND PrdBat.BatchSeqId=BCL.BatchSeqId
		AND BCL.ListPrice=1 AND BCL.SlNo=PBDL.SLNo AND PBDL.PrdBatId=PrdBat.PrdBatId
		AND TxRpt.PrdBatId=PrdBat.PrdBatId  AND TxRpt.PrdId=Prd.PrdId 
		AND PrdBat.DefaultPriceId=PBDL.PriceId
)A GROUP BY LcnId,LcnName,PrdId,PrdDCode,PrdCCode ,PrdName,PrdBatId,PrdBatCode,Saleable,SaleableWgt ,Unsaleable,UnsaleableWgt ,Offer,OfferWgt,Total,
			CmpId,PrdCtgValMainId,CmpPrdCtgId,PrdCtgValLinkCode,PrdStatus,Status
GO
IF EXISTS (SELECT * FROM SysObjects WHERE name='View_CurrentStockReportNTax' AND XTYPE='V')
DROP VIEW View_CurrentStockReportNTax
GO
CREATE    VIEW View_CurrentStockReportNTax
/************************************************************
* VIEW	: View_CurrentStockReportNTax
* PURPOSE	: To get the Current Stock of the Products with Batch details (With Out Tax)
* CREATED BY	:  Karthick	
* CREATED DATE	:  2011-05-11
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
SELECT LcnId,LcnName,PrdId,PrdDCode,Prdccode,PrdName,PrdBatId,PrdBatCode,sum(MRP)MRP,sum(SelRate)SelRate,sum(ListPrice)ListPrice,
	Saleable,SaleableWgt ,Unsaleable,UnsaleableWgt ,Offer,OfferWgt ,Total,sum(SalMRP)SalMRP,sum(UnSalMRP)UnSalMRP,sum(TotMRP)TotMRP,sum(SalSelRate)SalSelRate,
	sum(UnSalSelRate)UnSalSelRate,sum(TotSelRate)TotSelRate,sum(SalListPrice)SalListPrice,sum(UnSalListPrice)UnSalListPrice,
	sum(TotListPrice)TotListPrice,PrdStatus,Status,CmpId,PrdCtgValMainId,CmpPrdCtgId,PrdCtgValLinkCode
FROM (
SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,Prd.PrdCCode as PrdCCode,
		Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,PBDM.PrdBatDetailValue AS MRP,
		0 AS SelRate,
		0 AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
		(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
		(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
		(PrdBatLcnSih-PrdBatLcnResSih)* PBDM.PrdBatDetailValue  AS SalMRP,
		(PrdBatLcnUih-PrdBatLcnResUih)* PBDM.PrdBatDetailValue  AS UnSalMRP,
		(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* PBDM.PrdBatDetailValue ) AS TotMRP,
		0 AS SalSelRate,
		0 AS UnSalSelRate,
		0 AS TotSelRate,
		0 AS SalListPrice,
		0 AS UnSalListPrice,
		0 AS TotListPrice,
		Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		 ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
		 ProductBatchDetails PBDM (NOLOCK),BatchCreation BCM (NOLOCK),
		 ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
		 AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId AND PrdBat.BatchSeqId=BCM.BatchSeqId
		 AND BCM.MRP=1 AND BCM.SlNo=PBDM.SLNo AND PBDM.PrdBatId=PrdBat.PrdBatId 
		 AND PrdBat.DefaultPriceId=PBDM.PriceId 
UNION ALL 
	SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,Prd.PrdCCode as PrdCCode,
		Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,0 AS MRP,
		PBDR.PrdBatDetailValue AS SelRate,
		0 AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
		(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
		((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
		(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
		0  AS SalMRP,
		0  AS UnSalMRP,
		0 AS TotMRP,
		(PrdBatLcnSih-PrdBatLcnResSih)* (PBDR.PrdBatDetailValue)  AS SalSelRate,
		(PrdBatLcnUih-PrdBatLcnResUih)* (PBDR.PrdBatDetailValue)  AS UnSalSelRate,
		(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (PBDR.PrdBatDetailValue) ) AS TotSelRate,
		0 AS SalListPrice,
		0 AS UnSalListPrice,
		0 AS TotListPrice,
		Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
	FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		 ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
		 ProductBatchDetails PBDR (NOLOCK),BatchCreation BCR (NOLOCK),
		 ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
		AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
		AND PrdBat.BatchSeqId=BCR.BatchSeqId
		AND BCR.SelRte=1 AND BCR.SlNo=PBDR.SLNo AND PBDR.PrdBatId=PrdBat.PrdBatId
		AND PrdBat.DefaultPriceId=PBDR.PriceId  
UNION ALL
	SELECT DISTINCT  PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode as PrdDCode,Prd.PrdCCode as PrdCCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,0 AS MRP,
			0 AS SelRate,
			PBDL.PrdBatDetailValue AS ListPrice,
		(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(((PrdBatLcnSih-PrdBatLcnResSih)*Prd.PrdWgt)/1000) AS SaleableWgt,
		(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,(((PrdBatLcnUih-PrdBatLcnResUih)*Prd.PrdWgt)/1000) AS UnsaleableWgt,
		(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,(((PrdBatLcnFre-PrdBatLcnResFre)*Prd.PrdWgt)/1000) AS OfferWgt,
			((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
			(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
			0 AS SalMRP,
			0 AS UnSalMRP,
			0 AS TotMRP,
			0 AS SalSelRate,
			0 AS UnSalSelRate,
			0 AS TotSelRate,
			(PrdBatLcnSih-PrdBatLcnResSih)* (PBDL.PrdBatDetailValue)  AS SalListPrice,
			(PrdBatLcnUih-PrdBatLcnResUih)* (PBDL.PrdBatDetailValue)  AS UnSalListPrice,
			(((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih))* (PBDL.PrdBatDetailValue) ) AS TotListPrice,
			Prd.PrdStatus,PrdBat.Status,Prd.CmpId, Prd.PrdCtgValMainId,PCV.CmpPrdCtgId,PCV.PrdCtgValLinkCode
		FROM Product Prd (NOLOCK),ProductCategoryLevel PCL (NOLOCK),
		  	 ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),
			 ProductBatchDetails PBDL (NOLOCK),BatchCreation BCL (NOLOCK),
			 ProductBatchLocation PrdBatLcn (NOLOCK) CROSS JOIN Location Lcn (NOLOCK)
	    WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId AND PCV.CmpPrdCtgId=PCL.CmpPrdCtgId 
			AND PrdBat.BatchSeqId=BCL.BatchSeqId
			AND BCL.ListPrice=1 AND BCL.SlNo=PBDL.SLNo AND PBDL.PrdBatId=PrdBat.PrdBatId
			AND PrdBat.DefaultPriceId=PBDL.PriceId
)A GROUP BY LcnId,LcnName,PrdId,PrdDCode,PrdCCode ,PrdName,PrdBatId,PrdBatCode,Saleable,SaleableWgt ,Unsaleable,UnsaleableWgt ,Offer,OfferWgt,Total,
			CmpId,PrdCtgValMainId,CmpPrdCtgId,PrdCtgValLinkCode,PrdStatus,Status
GO
IF EXISTS (SELECT * FROM Sys.objects WHERE NAME='Proc_RptCurrentStock' AND TYPE='P')
DROP PROCEDURE Proc_RptCurrentStock
GO
--Exec [Proc_RptCurrentStock] 5,1,0,'Parle1',0,0,1,0
CREATE PROCEDURE Proc_RptCurrentStock
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
* PROCEDURE : Proc_RptCurrentStock
* PURPOSE : To get the Current Stock details for Report
* CREATED : Nandakumar R.G
* CREATED DATE : 01/08/2007
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
24/07/2009	MarySubashini.S		To add the Tax Validation
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
	DECLARE @fPrdId        AS Int
	DECLARE @SupZeroStock	AS INT
	DECLARE @StockType	AS INT
	DECLARE @RptDispType	AS INT
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
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	SET @StockType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,240,@Pi_UsrId))
	SET @RptDispType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,221,@Pi_UsrId))
	IF @DispBatch = 1 
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	--Till Here
	--If Product Category Filter is available
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	--Till Here
	DELETE FROM TaxForReport WHERE UsrId=@Pi_UsrId AND RptId=@Pi_RptId
	IF @SupTaxGroupId<>0 OR @RtrTaxFroupId<>0
	BEGIN
		EXEC Proc_ReportTaxCalculation @SupTaxGroupId,@RtrTaxFroupId,1,20,5,@Pi_UsrId,@Pi_RptId
	END
	if exists (select * from dbo.sysobjects where id = object_id(N'[UOMIdWise]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [UOMIdWise]
	CREATE TABLE [UOMIdWise] 
	(
		SlNo	INT IDENTITY(1,1),
		UOMId	INT
	) 
	INSERT INTO UOMIdWise(UOMId)
	SELECT UOMId FROM UOMMaster ORDER BY UOMId		
	Create TABLE #RptCurrentStock
	(
		PrdId    INT,
		PrdDcode  NVARCHAR(100),
		PrdCCode  NVARCHAR(100),
		PrdName   NVARCHAR(200),
		PrdBatId              INT,
		PrdBatCode   NVARCHAR(100),
		MRP                NUMERIC (38,6),
		DisplayRate         NUMERIC (38,6),
		Saleable              INT,
		SaleableWgt		NUMERIC (38,6),
		Unsaleable   INT,
		UnsaleableWgt		NUMERIC (38,6),
		Offer                 INT,
		OfferWgt		NUMERIC (38,6),
		DisplaySalRate       NUMERIC (38,6),
		DisplayUnSalRate      NUMERIC (38,6),
		DisplayTotRate        NUMERIC (38,6),
		DispBatch             INT,
		RtrTaxGroup           INT,
		SupTaxGroup           INT,
		StockType			  INT
		
	)
	SET @TblName = 'RptCurrentStock'
	SET @TblStruct = '  PrdId      INT,
						PrdDcode    NVARCHAR(100),
						PrdCCode  NVARCHAR(100),
						PrdName     NVARCHAR(200),
						PrdBatId       INT,
						PrdBatCode     NVARCHAR(100),
						MRP            NUMERIC (38,6),
						DisplayRate    NUMERIC (38,6),
						Saleable       INT,
						SaleableWgt		NUMERIC (38,6),
						Unsaleable		INT,
						UnsaleableWgt	NUMERIC (38,6),
						Offer           INT,
						OfferWgt		NUMERIC (38,6),
						DisplaySalRate    NUMERIC (38,6),
						DisplayUnSalRate   NUMERIC (38,6),
						DisplayTotRate     NUMERIC (38,6),
						DispBatch          INT,
						RtrTaxGroup        INT,
						SupTaxGroup        INT,
						StockType		   INT'
	SET @TblFields = 'PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
	Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType'
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
		IF @SupTaxGroupId<>0 OR @RtrTaxFroupId<>0
		BEGIN
			IF @DispBatch=2
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReport
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
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))-- AND
				--UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
			ELSE
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReport
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
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE -1 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))-- AND
				--UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
		END
		ELSE
		BEGIN
			IF @DispBatch=2
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReportNTax
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
				--AND UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
			ELSE
			BEGIN
				INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,DispBatch,RtrTaxGroup,SupTaxGroup,StockType)
				SELECT PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,SUM(SaleableWgt) AS SaleableWgt,
				SUM(Unsaleable) AS Unsaleable,SUM(UnsaleableWgt) AS UnsaleableWgt,
				SUM(Offer) AS Offer,SUM(OfferWgt) AS OfferWgt,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@DispBatch,
				@RtrTaxFroupId,@SupTaxGroupId,@StockType
				FROM dbo.View_CurrentStockReportNTax
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
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE -1 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))
				--AND UsrId=@Pi_UsrId
				GROUP BY PrdId,PrdDcode,PrdCCode,PrdName,PrdBatId,PrdBatCode,MRP,ListPrice,SelRate
			END
		END
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptCurrentStock ' +
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
			UPDATE #RptCurrentStock SET DispBatch=@DispBatch
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptCurrentStock'
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
			SET @SSQL = 'INSERT INTO #RptCurrentStock ' +
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
	
	IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND  GridFlag=1 AND UsrId=@Pi_UsrId)
	BEGIN
		SELECT a.PrdId,a.PrdDcode,a.PrdCCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.MRP,a.DisplayRate,a.Saleable,
		CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Saleable AS INT)>nullif(ConverisonFactor2,0) Then CAST(Saleable AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END  As Uom1,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
		(CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN Case When CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
		(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
		CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
		(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END as Uom4,
		a.Unsaleable,a.Offer,a.DisplaySalRate,a.DisplayUnSalRate,a.DisplayTotRate,a.DispBatch,a.RtrTaxGroup,a.SupTaxGroup,a.StockType
		INTO #RptColDetails
		FROM #RptCurrentStock A, View_ProdUOMDetails B WHERE a.prdid=b.prdid
		DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
		INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,Rptid,Usrid)
		SELECT PrdDcode,PrdName,PrdBatCode,MRP,DisplayRate,Saleable,Uom1,Uom2,Uom3,Uom4,
		Unsaleable,Offer,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,@Pi_RptId,@Pi_UsrId
		FROM #RptColDetails
	END
	--SELECT @RptDispType
	SET @RptDispType=ISNULL(@RptDispType,1)
	IF @RptDispType=1
	BEGIN
		--TRUNCATE TABLE RptCurrentStock_Excel
		IF @SupZeroStock=1
		BEGIN
			SELECT * FROM #RptCurrentStock
			WHERE Saleable+Unsaleable+Offer <> 0
----			IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND Flag=1 AND UsrId=@Pi_UsrId)
----			BEGIN
----				INSERT INTO RptCurrentStock_Excel
----				SELECT * FROM #RptCurrentStock
----				WHERE (Saleable+UnSaleable+Offer)<>0
----			END
			IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCurrentStock_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE RptCurrentStock_Excel
				SELECT * INTO RptCurrentStock_Excel FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			END 
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			PRINT 'Data Executed'
		END
		ELSE
		BEGIN
			SELECT * FROM #RptCurrentStock
----			IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND Flag=1 AND UsrId=@Pi_UsrId)
----			BEGIN
----				INSERT INTO RptCurrentStock_Excel
----				SELECT * FROM #RptCurrentStock
----			END
			IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
			BEGIN
				IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptCurrentStock_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
				DROP TABLE RptCurrentStock_Excel
				SELECT * INTO RptCurrentStock_Excel FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			END 
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock 
			PRINT 'Data Executed'
		END
	END
	ELSE
	BEGIN		
		IF @SupZeroStock=1
		BEGIN
			SELECT a.PrdId,a.PrdDcode,a.PrdCCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.MRP,a.DisplayRate,a.Saleable,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Saleable AS INT)>nullif(ConverisonFactor2,0) Then CAST(Saleable AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END  As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			(CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN Case When CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((nullif(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
			CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END as Uom4,
			a.Unsaleable,a.Offer,a.DisplaySalRate,a.DisplayUnSalRate,a.DisplayTotRate,a.DispBatch,a.RtrTaxGroup,a.SupTaxGroup,a.StockType
			FROM #RptCurrentStock A, View_ProdUOMDetails B WHERE a.prdid=b.prdid
			AND (a.Saleable + a.Unsaleable + a.Offer) <> 0
		
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
			PRINT 'Data Executed'
		END
		ELSE
		BEGIN
			SELECT a.PrdId,a.PrdDcode,a.PrdCCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.MRP,a.DisplayRate,a.Saleable,
			CASE WHEN ConverisonFactor2>0 THEN Case When CAST(Saleable AS INT)>nullif(ConverisonFactor2,0) Then CAST(Saleable AS INT)/nullif(ConverisonFactor2,0) Else 0 End ELSE 0 END  As Uom1,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When (CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case When (CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
			(CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
			CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN Case When CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((nullif(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=nullif(ConversionFactor1,0) Then
			CAST(Saleable AS INT)-(((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
			(((CAST(Saleable AS INT)-((CAST(Saleable AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Saleable AS INT)-(CAST(Saleable AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/nullif(ConversionFactor1,0) Else 0 End ELSE 0 END as Uom4,
			a.Unsaleable,a.Offer,a.DisplaySalRate,a.DisplayUnSalRate,a.DisplayTotRate,a.DispBatch,a.RtrTaxGroup,a.SupTaxGroup,a.StockType
			FROM #RptCurrentStock A, View_ProdUOMDetails B WHERE a.prdid=b.prdid
			
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock
			PRINT 'Data Executed'
		END
	END
		DELETE FROM RptExcelHeaders WHERE RptId=5
		DECLARE @COLUMN AS Varchar(80)
		DECLARE @C_SSQL AS Varchar(8000)
		DECLARE @iCnt AS Int 
		SET @iCnt=1
			DECLARE Cur_Col CURSOR FOR  
			SELECT SC.[Name] FROM SysColumns SC,SysObjects So WHERE SC.Id=SO.Id AND SO.[Name]='RptCurrentStock_Excel'
			OPEN Cur_Col
			FETCH NEXT FROM Cur_Col INTO @COLUMN
			WHILE @@FETCH_STATUS = 0
			BEGIN
			SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
			SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
			SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
			EXEC (@C_SSQL)
			SET @iCnt=@iCnt+1
			FETCH NEXT FROM Cur_Col INTO @COLUMN
			END
			CLOSE Cur_Col
			DEALLOCATE Cur_Col
		  UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE Slno IN (1)
	RETURN
END
GO
UPDATE A SET SCHSTATUS=0 FROM SCHEMEMASTER A (NOLOCK) WHERE SCHSTATUS=1 AND SchValidFrom<='2016-08-29'
GO
--Till Here
UPDATE UtilityProcess SET VersionId = '3.1.0.5' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.5',427
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE FixId = 428)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(428,'D','2016-08-29',GETDATE(),1,'Core Stocky Service Pack 428')