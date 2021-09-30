--[Stocky HotFix Version]=422
DELETE FROM Versioncontrol WHERE Hotfixid='422'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('422','3.1.0.2','D','2015-03-20','2015-03-20','2015-03-20',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
/*
    CR RELEASE DETAILS :
    1. Sales Return Auto Batch Fill
    2. Inventory Console
*/
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_Cn2Cs_ProductBatch' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_ProductBatch
GO
/* 
   BEGIN TRANSACTION
   EXEC Proc_Cn2Cs_ProductBatch 0
   SELECT * FROM Productbatch WITH(NOLOCK) WHERE PrdBatId = 29809
   SELECT * FROM Productbatchdetails WITH(NOLOCK) WHERE PrdBatId = 29809
   SELECT * FROM ProductBatch (NOLOCK) WHERE PrdId = 1741
   SELECT * FROM Errorlog WITH(NOLOCK)
   ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_ProductBatch
(
       @Po_ErrNo INT OUTPUT
)
AS
/***************************************************************************************************
* PROCEDURE		: Proc_Cn2Cs_ProductBatch
* PURPOSE		: To Insert and Update records in the Tables ProductBatch and ProductBatchDetails
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 12/04/2010
* MODIFIED      : Sathishkumar Veeramani
* PURPOSE		: New Product Batch - Special Rate Created
* MODIFIED DATE : 13/09/2012
* MODIFIED      : Murugan.R
* PURPOSE		: Batch Optimization  and Akzonabal Price change
* MODIFIED DATE : 13/09/2012
* DATE      AUTHOR     DESCRIPTION
-----------------------------------------------------------------------------------------------------
* {date} {developer}  {brief modification description}
*****************************************************************************************************/
SET NOCOUNT ON
BEGIN
	SET @Po_ErrNo =0
	IF NOT EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK) WHERE DownLoadFlag='D') RETURN
	
	--Product batch configuration  For Aznoble Client
	IF EXISTS(SELECT Status FROM Configuration where ModuleId='GENCONFIG33' and Status=1)
		BEGIN
			DELETE FROM ProductBatchEeffectiveDate WHERE UpdateFlag='Y'
			
			INSERT INTO ProductBatchEeffectiveDate(PrdCCode,PrdBatCode,ManufacturingDate,ExpiryDate,
			EffectiveDate,MRP,ListPrice,SellingRate,ClaimRate,AddRate1,AddRate2,
			AddRate3,AddRate4,AddRate5,AddRate6,UpdateFlag)			 
			SELECT PrdCCode,PrdBatCode,ManufacturingDate,ExpiryDate,EffectiveDate,
			MRP,ListPrice,SellingRate,ClaimRate,AddRate1,AddRate2,AddRate3,
			AddRate4,AddRate5,AddRate6,'N' 
			FROM Cn2Cs_Prk_ProductBatch WHERE DownLoadFlag='D' AND EffectiveDate>CONVERT(DATETIME ,CONVERT(VARCHAR(10),GETDATE(),121),121)
			ORDER BY ManufacturingDate ASC --Muthuvel
					
			DELETE FROM Cn2Cs_Prk_ProductBatch  WHERE DownLoadFlag='D' AND EffectiveDate>CONVERT(DATETIME ,CONVERT(VARCHAR(10),GETDATE(),121),121)
			--Product Batch and Price Insert For Aznoble Client
			EXEC Proc_ValidateBatchLDEeffectiveDate
			
			RETURN

		END
	
	IF EXISTS (SELECT * FROM SysObjects WHERE Name = 'PrdBatToAvoid' AND XTYPE = 'U')
	BEGIN
		DROP TABLE PrdBatToAvoid	
	END
	CREATE TABLE PrdBatToAvoid
	(
		PrdCCode NVARCHAR(200),
		PrdBatCode NVARCHAR(200)
	)
	DECLARE @ExistingBatchDetails	TABLE
	(
		PrdId		NUMERIC(18,0),
		PrdCCode	VARCHAR(100),
		PrdBatCode	VARCHAR(100),
		PriceCode	VARCHAR(500),
		OldLSP		NUMERIC(18,0),
		PrdBatId	NUMERIC(18,0),
		PriceId		NUMERIC(18,0)
	)
	DECLARE @ProductBatchWithCounter TABLE
	(
		Slno			NUMERIC(18,0) IDENTITY(1,1),
		TransNo			NUMERIC(18,0),
		PrdId			NUMERIC(18,0),
		PrdCCode		VARCHAR(100),
		PrdBatCode		VARCHAR(100),
		MnfDate			DATETIME,
		ExpDate			DATETIME		
	)	
	DECLARE @ProductBatchPriceWithCounter TABLE
	(
		Slno			NUMERIC(18,0) IDENTITY(1,1),
		TransNo			NUMERIC(18,0),
		PrdId			NUMERIC(18,0),
		PrdBatId		NUMERIC(18,0),
		PriceCode		NVARCHAR(1000),
		MRP				NUMERIC(18,6),
		ListPrice		NUMERIC(18,6),
		SellingRate		NUMERIC(18,6),
		ClaimRate		NUMERIC(18,6),
		AddRate1		NUMERIC(18,6)
	)
	DECLARE @ContractPrice TABLE
	(
	   PrdId NUMERIC(18,0),
	   PrdBatId NUMERIC(18,0)
	)
	
	DECLARE @ContractBatchPrice TABLE
    (
	   ContractId       NUMERIC(18,0),
	   CtgMainId        NUMERIC(18,0),
	   PrdId            NUMERIC(18,0),
	   PrdBatId         NUMERIC(18,0),
	   PriceId          NUMERIC(18,0),
	   PriceCode        NVARCHAR(500)
    )
    DECLARE @ProductBatchDetails TABLE
	(
	   PrdId                NUMERIC(18,0),
	   PrdBatId      NUMERIC(18,0),
	   PriceId              NUMERIC(18,0),
	   PriceCode            NVARCHAR(500),
	   NewBatchId           NUMERIC(18,0),
	   Slno                 INT,
	   PrdBatDetailValue    NUMERIC(36,4),
	   NewPriceId           NUMERIC(18,0)
	)
	--Added By Sathishkumar Veeramani 2015/01/08
	DECLARE @ExistingSellingPriceDetails TABLE
	(
	    PrdId        NUMERIC(18,0),
	    PrdBatId     NUMERIC(18,0),
	    PriceId      NUMERIC(18,0)
	)
	DECLARE @ExistingListPriceDetails TABLE
	(
	    PrdId        NUMERIC(18,0),
	    PrdBatId     NUMERIC(18,0),
	    PriceId      NUMERIC(18,0)
	)
	--Till Here  
	
	DECLARE @BatSeqId			AS	INT
	DECLARE @ValDiffRefNo		AS	VARCHAR(100)
	DECLARE @ExistPrdBatMaxId	AS 	INT
	DECLARE @NewPrdBatMaxId		AS 	INT	
	DECLARE @ContPriceId		AS 	NUMERIC(18,0)
	DECLARE @OldPriceIdExt 		AS 	NUMERIC(18,0)
	DECLARE @OldPriceId 		AS 	NUMERIC(18,0)
	DECLARE @NewPriceId			AS  INT
	DECLARE @ContPrdId          AS  INT
    DECLARE @ContPrdBatId       AS  INT
    DECLARE @ContPriceId1       AS  INT
    DECLARE @PriceId            AS  INT 
    DECLARE @PriceBatch         AS  INT
    DECLARE @BatchTransfer		AS	INT
	DECLARE @Po_BatchTransfer	AS	INT
	
	SELECT @OldPriceId=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails WITH (NOLOCK)		
	SELECT @BatSeqId=MAX(BatchSeqId) FROM BatchCreationMaster WITH (NOLOCK)
	SELECT @ExistPrdBatMaxId=ISNULL(MAX(PrdBatId),0) FROM ProductBatch WITH (NOLOCK)
	SET @Po_ErrNo =0
	IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)
	WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)) AND DownLoadFlag='D')
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)) AND DownLoadFlag='D'
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdCCode','Product :'+PrdCCode+' not available'
		FROM Cn2Cs_Prk_ProductBatch	WITH (NOLOCK) WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)) 
		AND DownLoadFlag='D'
		
		--->Added By Nanda on 05/05/2010
		INSERT INTO ReDownloadRequest(DistCode,Process,RefNo,Download,PrdCCode,PrdBatCode,UploadFlag)
		SELECT DISTINCT DistCode,'Product Batch',PrdBatCode,'Product',PrdCCode,'','N' FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK) 
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product WITH (NOLOCK)) AND DownLoadFlag='D'
		--->Till Here				
	END
	IF EXISTS(SELECT DISTINCT PrdCCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)
	WHERE LEN(ISNULL(PrdBatCode,''))=0  AND DownLoadFlag='D')
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT PrdCCode,PrdBatCode FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)
		WHERE LEN(ISNULL(PrdBatCode,''))=0 AND DownLoadFlag='D'
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdBatCode','Batch Code should not be empty for Product:'+PrdCCode
		FROM Cn2Cs_Prk_ProductBatch WITH (NOLOCK)
		WHERE LEN(ISNULL(PrdBatCode,''))=0 AND DownLoadFlag='D'
	END
		
	INSERT INTO @ExistingBatchDetails (PrdId,PrdCCode,PrdBatCode,PriceCode,OldLSP,PrdBatId,PriceId)
	SELECT DISTINCT B.PrdId,B.PrdCCode,A.PrdBatCode,A.PrdBatCode+'-'+CAST(MRP AS NVARCHAR(25))+'-'+CAST(ListPrice AS NVARCHAR(25))+'-'+
	CAST(SellingRate AS NVARCHAR(25))+'-'+CAST(ClaimRate AS NVARCHAR(25))+'-'+CAST(AddRate1 AS NVARCHAR(25)) AS PriceCode,
	ISNULL(D.PrdBatDetailValue,0) AS OldLSP,C.PrdBatId,D.PrdBatId FROM Cn2Cs_Prk_ProductBatch A (NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.PrdCCode=B.PrdCCode
	INNER JOIN ProductBatch C (NOLOCK)ON A.PrdBatCode=C.PrdBatCode AND B.PrdId=C.PrdId
	INNER JOIN ProductBatchDetails D (NOLOCK) ON  D.PrdBatId=C.PrdBatId AND D.DefaultPrice=1 AND D.SlNo=2
	WHERE A.PrdBatCode NOT IN (SELECT PrdBatCode FROM PrdBatToAvoid) AND DownLoadFlag='D'
	
	--Added By Sathishkumar Veeramani 2015/01/08
	--Selling Rate Validation
	INSERT INTO @ExistingSellingPriceDetails (PrdId,PrdBatId,PriceId)
	SELECT DISTINCT PrdId,B.PrdBatId,C.PriceId FROM Cn2Cs_Prk_ProductBatch A (NOLOCK) 
	INNER JOIN @ExistingBatchDetails B ON A.PrdCCode = B.PrdCCode AND A.PrdBatCode = B.PrdBatCode
	INNER JOIN ProductBatchDetails C (NOLOCK) ON B.PrdBatId = C.PrdBatId AND A.SellingRate = C.PrdBatDetailValue
	WHERE C.SLNo = 3
	
	--List Price Validation
	INSERT INTO @ExistingListPriceDetails (PrdId,PrdBatId,PriceId)
	SELECT DISTINCT PrdId,B.PrdBatId,C.PriceId FROM Cn2Cs_Prk_ProductBatch A (NOLOCK) 
	INNER JOIN @ExistingBatchDetails B ON A.PrdCCode = B.PrdCCode AND A.PrdBatCode = B.PrdBatCode
	INNER JOIN ProductBatchDetails C (NOLOCK) ON B.PrdBatId = C.PrdBatId AND A.ListPrice = C.PrdBatDetailValue
	WHERE C.SLNo = 2
	
	SELECT DISTINCT A.PrdId,A.PrdBatId,MAX(A.PriceId) AS PriceId INTO #ExistinPriceCloning 
	FROM @ExistingSellingPriceDetails A 
	INNER JOIN @ExistingListPriceDetails B ON A.PrdId = B.PrdId
	AND A.PrdBatId = B.PrdBatId AND A.PriceId = B.PriceId GROUP BY A.PrdId,A.PrdBatId
	
	IF EXISTS (SELECT DISTINCT PrdId,PrdBatId,PriceId FROM #ExistinPriceCloning)
	BEGIN
	    UPDATE A SET A.DefaultPrice = 0 FROM ProductBatchDetails A (NOLOCK) 
	    INNER JOIN #ExistinPriceCloning B ON A.PrdBatId = B.PrdBatId
	    
	    UPDATE A SET A.DefaultPrice = 1 FROM ProductBatchDetails A (NOLOCK)
	    INNER JOIN #ExistinPriceCloning B ON A.PrdBatId = B.PrdBatId AND A.PriceId = B.PriceId
	    
	    UPDATE A SET A.DefaultPriceId = B.PriceId FROM ProductBatch A (NOLOCK) 
	    INNER JOIN #ExistinPriceCloning B ON A.PrdBatId = B.PrdBatId	    
	END
	--Till Here
	
	--Added By Sathishkumar Veeramani 2015/01/08
	--Batch Cloning Details
    DECLARE @BatchPriceId AS NUMERIC(18,0)
    SELECT @BatchPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
    
	SELECT DISTINCT CAST(DENSE_RANK() OVER (ORDER BY MAX(PrdBatId),MRP,ListPrice,SellingRate,ClaimRate) AS NUMERIC(18,0))+@BatchPriceId AS PriceId,
	MAX(PrdBatId) AS PrdBatId,A.PrdBatCode+'-'+CAST(MRP AS NVARCHAR(25))+'-'+CAST(ListPrice AS NVARCHAR(25))+'-'+CAST(SellingRate AS NVARCHAR(25))+'-'+
	CAST(ClaimRate AS NVARCHAR(25))+'-'+CAST(AddRate1 AS NVARCHAR(25)) AS PriceCode,MRP,ListPrice,
	SellingRate,ClaimRate,AddRate1 INTO #BatchCloningDetails FROM Cn2Cs_Prk_ProductBatch A (NOLOCK)
	INNER JOIN Product B (NOLOCK) ON A.PrdCCode = B.PrdCCode 
	INNER JOIN ProductBatch C (NOLOCK) ON B.PrdId = C.PrdId AND A.PrdBatCode = C.PrdBatCode WHERE DownloadFlag = 'D'
	AND NOT EXISTS (SELECT DISTINCT PrdId,PrdBatId FROM #ExistinPriceCloning D WHERE C.PrdId = D.PrdId AND C.PrdBatId = D.PrdBatId) 
	GROUP BY A.PrdBatCode,MRP,ListPrice,SellingRate,ClaimRate,AddRate1
	
	IF EXISTS (SELECT DISTINCT PrdBatId FROM #BatchCloningDetails)
	BEGIN
	    UPDATE A SET DefaultPrice = 0 FROM ProductBatchDetails A WITH(NOLOCK) 
		INNER JOIN #BatchCloningDetails B ON A.PrdBatId = B.PrdBatId
			    
		INSERT INTO ProductBatchDetails (PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
		Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
		SELECT DISTINCT PriceId,PrdBatId,PriceCode,1,SlNo,Rate,1,1,1,1,GETDATE(),1,GETDATE(),0 FROM(
		SELECT DISTINCT PriceId,PrdBatId,PriceCode,1 AS SlNo,MRP AS Rate FROM #BatchCloningDetails UNION
		SELECT DISTINCT PriceId,PrdBatId,PriceCode,2 AS SlNo,ListPrice AS Rate FROM #BatchCloningDetails UNION
		SELECT DISTINCT PriceId,PrdBatId,PriceCode,3 AS SlNo,SellingRate AS Rate FROM #BatchCloningDetails UNION
		SELECT DISTINCT PriceId,PrdBatId,PriceCode,4 AS SlNo,ClaimRate AS Rate FROM #BatchCloningDetails)Qry ORDER BY PrdBatId

		SELECT @BatchPriceId = ISNULL(MAX(PriceId),0) FROM ProductBatchDetails (NOLOCK)
		UPDATE Counters SET CurrValue = @BatchPriceId WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'
		
        UPDATE A SET DefaultPriceId = B.PriceId FROM ProductBatch A WITH(NOLOCK) 
		INNER JOIN #BatchCloningDetails B ON A.PrdBatId = B.PrdBatId
    END
	--Till Here
		
	IF EXISTS (SELECT * FROM @ExistingBatchDetails)
	BEGIN
		UPDATE A SET MnfDate=C.ManufacturingDate,ExpDate=ExpiryDate
		FROM ProductBatch A (NOLOCK) INNER JOIN @ExistingBatchDetails B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
		INNER JOIN Cn2Cs_Prk_ProductBatch C (NOLOCK) ON A.PrdBatCode=C.PrdBatCode  AND B.PrdCCode=C.PrdCCode
		WHERE C.DownLoadFlag='D'
	
		UPDATE Cn2Cs_Prk_ProductBatch SET DownLoadFlag='Y' 
		WHERE PrdCCode+'~'+PrdBatCode IN (SELECT PrdCCode+'~'+PrdBatCode FROM @ExistingBatchDetails) AND DownLoadFlag='D' 
	END
	
	DECLARE @Count1	NUMERIC(18,0)
	DECLARE @Count2	NUMERIC(18,0)
	SELECT @Count1=COUNT(*) FROM Cn2Cs_Prk_ProductBatch
	SELECT @Count2=COUNT(*) FROM @ExistingBatchDetails
	IF @Count1<>@Count2
		BEGIN
	--IF NOT EXISTS (SELECT * FROM @ExistingBatchDetails)
	--BEGIN
	---New ProductBatch		
		INSERT INTO @ProductBatchWithCounter
		SELECT DISTINCT (SELECT CurrValue FROM Counters (NOLOCK) WHERE TabName='ProductBatch' AND FldName='PrdBatId'),
		B.PrdId,A.PrdCCode,A.PrdBatCode,ManufacturingDate,ExpiryDate FROM Cn2Cs_Prk_ProductBatch A (NOLOCK) 
		INNER JOIN Product B (NOLOCK) ON A.PrdCCode=B.PrdCCode WHERE NOT EXISTS (SELECT PrdBatCode FROM ProductBatch C (NOLOCK) 
		WHERE C.PrdBatCode=A.PrdBatCode AND B.PrdId=C.PrdId)AND 
		A.PrdCCode+'~'+A.PrdBatCode NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM PrdBatToAvoid) AND A.DownLoadFlag='D'
		ORDER BY ManufacturingDate ASC --Muthuvel
		
			
		UPDATE @ProductBatchWithCounter SET TransNo=TransNo+Slno
	--Existing ProductBatch 
			INSERT INTO @ProductBatchWithCounter
			SELECT DISTINCT C.PrdBatId,B.PrdId,A.PrdCCode,A.PrdBatCode,
			ManufacturingDate,ExpiryDate FROM Cn2Cs_Prk_ProductBatch A (NOLOCK) INNER JOIN Product B (NOLOCK) ON A.PrdCCode=B.PrdCCode
			INNER JOIN ProductBatch C ON B.PrdId = C.PrdId AND C.PrdBatCode = A.PrdBatCode WHERE 
			NOT EXISTS (SELECT PrdBatId FROM ProductBatchDetails D(NOLOCK) WHERE D.PrdBatId = C.PrdBatId AND D.PriceId = C.DefaultPriceId)	
			AND  A.PrdCCode+'~'+A.PrdBatCode NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM PrdBatToAvoid) AND A.DownLoadFlag='D'
			AND  A.PrdCCode+'~'+A.PrdBatCode NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM @ProductBatchWithCounter)
	
	 --Product Batch   
		INSERT INTO ProductBatch(PrdId,PrdBatId,PrdBatCode,CmpBatCode,MnfDate,ExpDate,Status,
		TaxGroupId,BatchSeqId,DecPoints,DefaultPriceId,EnableCloning,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT A.PrdId,TransNo,PrdBatCode,PrdBatCode,MnfDate,ExpDate,1,B.TaxGroupId,@BatSeqId,
		6,0,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchWithCounter A 
		INNER JOIN Product B ON A.PrdId=B.PrdId WHERE NOT EXISTS (SELECT PrdBatCode FROM ProductBatch C WHERE A.PrdId = C.PrdId 
		AND A.PrdBatCode = C.PrdBatCode)
    --END 
		END
	IF EXISTS (SELECT * FROM @ProductBatchWithCounter) 
	BEGIN
		UPDATE Counters SET CurrValue = (SELECT MAX(PrdBatId) FROM ProductBatch) WHERE TabName = 'ProductBatch' AND FldName = 'prdbatid'
	
		INSERT INTO @ProductBatchPriceWithCounter
		SELECT DISTINCT (SELECT CurrValue FROM Counters (NOLOCK) WHERE TabName='ProductBatchDetails' AND FldName='PriceId'),A.PrdId,A.TransNo,
		A.PrdBatCode+'-'+CAST(MRP AS NVARCHAR(25))+'-'+CAST(ListPrice AS NVARCHAR(25))+'-'+
		CAST(SellingRate AS NVARCHAR(25))+'-'+CAST(ClaimRate AS NVARCHAR(25))+'-'+CAST(AddRate1 AS NVARCHAR(25)),MRP,ListPrice,
		SellingRate,ClaimRate,AddRate1 FROM @ProductBatchWithCounter A INNER JOIN Cn2Cs_Prk_ProductBatch B WITH (NOLOCK)
		ON A.PrdCCode=B.PrdCCode AND A.PrdBatCode=B.PrdBatCode WHERE B.DownLoadFlag='D'
		
		UPDATE @ProductBatchPriceWithCounter SET TransNo=TransNo+Slno
				
		UPDATE A SET A.DefaultPrice=0 FROM ProductBatchDetails A WITH (NOLOCK),@ProductBatchPriceWithCounter B  
	    WHERE A.PrdBatId = B.PrdBatId
		
	END			
	
	IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatSeqId)=4
	BEGIN
		INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
		DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,1,MRP,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,2,ListPrice,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,3,SellingRate,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,4,ClaimRate,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
	END
	ELSE IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatSeqId)=5
	BEGIN
		INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
		DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,1,MRP,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,2,ListPrice,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,3,SellingRate,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,4,ClaimRate,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
		UNION
		SELECT DISTINCT TransNo,PrdBatId,PriceCode,@BatSeqId,5,AddRate1,1,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) FROM @ProductBatchPriceWithCounter
	END	
	UPDATE A SET DefaultPriceId=C.TransNo FROM ProductBatch A INNER JOIN @ProductBatchPriceWithCounter C ON C.PrdBatId=A.PrdBatId AND A.PrdId=C.PrdId	
	
	IF EXISTS(SELECT * FROM @ProductBatchPriceWithCounter) 
	BEGIN
		UPDATE Counters SET CurrValue = (SELECT MAX(PriceId) FROM ProductBatchDetails) 	WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'	
	END
	
	--Batch Cloning Price Details
	
	IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreeRateForOldBatch' AND ModuleName='Botree Product Batch Download' AND Status=1)
	BEGIN
		IF EXISTS(SELECT * FROM @ProductBatchPriceWithCounter A INNER JOIN @ExistingBatchDetails B ON A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId
		WHERE (B.OldLSP-A.ListPrice)<>0 AND Slno=2)
		BEGIN
			SELECT @ValDiffRefNo = dbo.Fn_GetPrimaryKeyString('ValueDifferenceClaim','ValDiffRefNo',CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			
			INSERT INTO ValueDifferenceClaim(ValDiffRefNo,Date,PrdId,PrdBatId,OldPriceId,NewPriceId,OldPrice,NewPrice,Qty,
			ValueDiff,ClaimAmt,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			
			SELECT @ValDiffRefNo,GETDATE(),A.PrdId,A.PrdBatID,B.PriceId,C.TransNo,B.OldLsp,C.ListPrice,
			ISNULL(SUM(A.PrdBatLcnSih+A.PrdBatLcnUih-A.PrdBatLcnRessih-A.PrdBatLcnResUih),0),B.OldLsp-C.ListPrice,
			ISNULL(SUM(A.PrdBatLcnSih+A.PrdBatLcnUih-A.PrdBatLcnRessih-A.PrdBatLcnResUih),0)*(B.OldLsp-C.ListPrice),
			1,1,GETDATE(),1,GETDATE() FROM ProductBatchLocation A INNER JOIN @ExistingBatchDetails B ON A.PrdId=B.PrdId AND A.PrdBatID=B.PrdBatId 
			INNER JOIN @ProductBatchPriceWithCounter C ON A.PrdBatId=C.PrdBatId AND A.PrdId=C.PrdId
			WHERE C.Slno=2	GROUP BY A.PrdId,A.PrdBatID,B.PriceId,C.TransNo,B.OldLsp,C.ListPrice
			
			UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'ValueDifferenceClaim' AND FldName = 'ValDiffRefNo'
		END
	END
	UPDATE ProductBatch SET ProductBatch.DefaultPriceId=PBD.PriceId,ProductBatch.BatchSeqId=PBD.BatchSeqId
	FROM ProductBatchDetails PBD WITH (NOLOCK) WHERE ProductBatch.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1
	
	UPDATE ProductBatch SET EnableCloning=1 WHERE PrdBatId IN
	(
	 SELECT PrdBatId FROM ProductBatchDetails WITH (NOLOCK) GROUP BY PrdBatId  HAVING(COUNT(DISTINCT PriceId)>1)
	)
	
	SELECT PrdBatId INTO #ZeroBatches FROM ProductBatchDetails WITH (NOLOCK)
	GROUP BY PrdBatId HAVING SUM(DefaultPrice)=0
	
	SELECT B.PrdId,B.PrdBatId,MAX(PriceId) As PriceId INTO #ZeroMaxPrices
	FROM ProductBatchDetails A INNER JOIN ProductBatch B ON A.PrdBatId=B.PrdBatId
	INNER JOIN #ZeroBatches C ON A.PrdBatId=C.PrdBatId
	WHERE A.DefaultPrice=0 AND NOT EXISTS
	(SELECT DISTINCT PriceId FROM #BatchCloningDetails D WHERE A.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId)
	AND NOT EXISTS (SELECT DISTINCT PriceId FROM #ExistinPriceCloning E WHERE A.PrdBatId = E.PrdBatId AND A.PriceId = E.PriceId)
	GROUP BY B.PrdId,B.PrdBatId 
	
	
	UPDATE ProductBatch Set DefaultPriceId=B.PriceId FROM ProductBatch A,#ZeroMaxPrices B
	WHERE A.PrdBatId=B.PrdbatId and A.PrdId=B.PrdId 
	
	UPDATE ProductBatchDetails Set DefaultPrice=1 FROM #ZeroMaxPrices A
	WHERE ProductBatchDetails.PrdbatId=A.PrdBatId AND ProductBatchDetails.PriceId=A.PriceId
	
	SET @Po_ErrNo=0
	SELECT @OldPriceIdExt=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails
	IF @ExistPrdBatMaxId>0
	BEGIN
		SELECT @NewPrdBatMaxId=ISNULL(MAX(PrdBatId),0) FROM ProductBatch
		IF @NewPrdBatMaxId>@ExistPrdBatMaxId
		BEGIN
		    
		    --Existing Contract Pricing Percentage Updated to New Batch Download
     	    SELECT DISTINCT RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,MAX(CreatedDate) AS CreatedDate INTO #SpecialRateCreatedDate
		    FROM SpecialRateAftDownload WITH(NOLOCK) GROUP BY RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode ORDER BY PrdCCode
		       
			SELECT DISTINCT C.PrdId,E.PrdBatId,TransNo AS PriceId,A.RtrCtgCode,A.RtrCtgValueCode,A.RtrCode,A.PrdCCode,
			D.PrdBatCode,DiscountPerc,(MRP-(MRP*(DiscountPerc/100))) AS SplRate INTO #SpecialRateDetails 
			FROM SpecialRateAftDownload A WITH(NOLOCK)
			INNER JOIN #SpecialRateCreatedDate B ON A.RtrCtgCode = B.RtrCtgCode AND A.RtrCtgValueCode = B.RtrCtgValueCode 
			AND A.RtrCode = B.RtrCode AND A.PrdCCode = B.PrdCCode AND A.CreatedDate = B.CreatedDate
			INNER JOIN Product C WITH(NOLOCK) ON A.PrdCCode = C.PrdCCode			
			INNER JOIN ProductBatch D WITH(NOLOCK) ON C.PrdId = D.PrdId
			INNER JOIN @ProductBatchPriceWithCounter E ON C.PrdId = E.PrdId AND D.PrdBatId = E.PrdBatId
			ORDER BY A.PrdCCode			
	
			SELECT DISTINCT MAX(E.ContractId) AS ContractId,A.PrdId,A.PrdBatId,A.PriceId,B.CtgLevelId,C.CtgMainId,SplRate,RtrCtgValueCode 
			INTO #SpecialContractDetails FROM #SpecialRateDetails A WITH(NOLOCK) 
			INNER JOIN RetailerCategoryLevel B WITH(NOLOCK) ON A.RtrCtgCode = B.CtgLevelName 
			INNER JOIN RetailerCategory C WITH(NOLOCK) ON A.RtrCtgValueCode = C.CtgCode AND B.CtgLevelId = C.CtgLevelId
			INNER JOIN ContractPricingMaster D WITH(NOLOCK) ON B.CtgLevelId = D.CtgLevelId AND C.CtgMainId = D.CtgMainId 
			INNER JOIN ContractPricingDetails E WITH(NOLOCK) ON D.ContractId = E.ContractId AND A.PrdId = E.PrdId 
			GROUP BY A.PrdId,A.PrdBatId,A.PriceId,B.CtgLevelId,C.CtgMainId,SplRate,RtrCtgValueCode
			
			---Tax Calculation
			DECLARE @PrdIdTax as BIGINT
			DECLARE @PrdbatIdTax AS BIGINT
			DECLARE Cur_Tax CURSOR
			FOR 
			SELECT DISTINCT PrdId,PrdbatId FROM #SpecialContractDetails		
			OPEN Cur_Tax	
			FETCH NEXT FROM Cur_Tax INTO @PrdIdTax,@PrdbatIdTax
			WHILE @@FETCH_STATUS=0
			BEGIN	
					EXEC Proc_SellingTaxCalCulation @PrdIdTax,@PrdbatIdTax
			FETCH NEXT FROM Cur_Tax INTO @PrdIdTax,@PrdbatIdTax		
			END		
			CLOSE Cur_Tax
			DEALLOCATE Cur_Tax	
			
			SELECT DISTINCT A.PrdId,A.PrdBatId,PriceId,RtrCtgValueCode,DENSE_RANK ()OVER (ORDER BY A.PriceId,A.PrdbatId,RtrCtgValueCode)+ @OldPriceIdExt AS NewPriceId,
			CAST(SplRate*100/(100+TaxPercentage) AS NUMERIC(38,6)) AS NewSelRate INTO #SplProductBatchDetails
			FROM #SpecialContractDetails A WITH(NOLOCK) INNER JOIN ProductBatchTaxPercent B WITH(NOLOCK) ON A.PrdId = B.PrdId
			AND A.PrdBatId = B.PrdBatId ORDER BY A.PrdId,A.PrdBatId,PriceId,RtrCtgValueCode
			
			
			--Product Batch Details Value Added			
			INSERT INTO ProductBatchDetails (PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
            Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)            
            SELECT DISTINCT NewPriceId,A.PrdBatId,PriceCode+'SplRate'+CONVERT(NVARCHAR(200),NewSelRate)+CONVERT(NVARCHAR(10),GETDATE(),121),
            A.BatchSeqId,A.SLNo,(CASE SelRte WHEN 1 THEN NewSelRate ELSE PrdBatDetailValue END),0,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,
            CONVERT(NVARCHAR(10),GETDATE(),121),0
            FROM ProductBatchDetails A WITH(NOLOCK) 
            INNER JOIN #SplProductBatchDetails B ON A.PrdBatId = B.PrdBatId AND A.PriceId = B.PriceId
            INNER JOIN ProductBatch C WITH(NOLOCK) ON A.PrdBatId = C.PrdBatId
            INNER JOIN BatchCreation D WITH(NOLOCK) ON C.BatchSeqId = D.BatchSeqId AND A.SLNo = D.SlNo ORDER BY A.PrdBatId,NewPriceId 
            UPDATE Counters SET CurrValue =(SELECT MAX(PriceId) FROM ProductBatchDetails) WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'
            	
            --Contract Pricing Details Added
            INSERT INTO ContractPricingDetails (ContractId,PrdId,PrdBatId,PriceId,Discount,FlatAmtDisc,Availability,LastModBy,LastModDate,AuthId,
            AuthDate,CtgValMainId,ClaimablePercOnMRP)            
            SELECT DISTINCT ContractId,A.PrdId,A.PrdBatId,B.NewPriceId,0,0,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121),0,0
            FROM #SpecialContractDetails A INNER JOIN #SplProductBatchDetails B ON A.PrdId = B.PrdID AND A.PrdBatId = B.PrdBatId AND A.RtrCtgValueCode=B.RtrCtgValueCode
            WHERE NOT EXISTS (SELECT ContractId FROM ContractPricingDetails C WITH(NOLOCK) WHERE A.ContractId = C.ContractId 
            AND A.PrdId = C.PrdID AND A.PrdBatId = C.PrdBatId) ORDER BY ContractId,A.PrdId,A.PrdBatId,B.NewPriceId
            
            --Special Rate Updated
            INSERT INTO SpecialRateAftDownload (RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode,SplSelRate,FromDate,CreatedDate,DownloadedDate,
            ContractPriceIds,DiscountPerc,SplrateId)
            SELECT DISTINCT RtrCtgCode,A.RtrCtgValueCode,A.RtrCode,A.PrdCCode,A.PrdBatCode,A.SplRate,CONVERT(NVARCHAR(10),GETDATE(),121),GETDATE(),GETDATE(),
            '-'+CONVERT(NVARCHAR(50),NewPriceId)+'-',DiscountPerc,0
            FROM #SpecialRateDetails A INNER JOIN #SplProductBatchDetails B ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId 
            and A.RtrCtgValueCode=B.RtrCtgValueCode
            ORDER BY PrdCCode,PrdBatCode
            			
			--SELECT PrdId,PrdBatId,TransNo, FROM @ProductBatchPriceWithCounter INNER JOIN 
			
    		--SELECT A.PrdId,MAX(A.PrdBatId) AS PrdBatId INTO #ContractPrice FROM ProductBatch A (NOLOCK),@ProductBatchWithCounter B
			--WHERE  A.PrdId = B.PrdId AND A.PrdBatId < @ExistPrdBatMaxId AND EXISTS
			--(SELECT CPD.PrdBatId FROM ContractPricingDetails CPD (NOLOCK)
			--INNER JOIN ProductBatch PB1 (NOLOCK) ON CPD.PrdId=PB1.PrdId AND CPD.PrdBatId=PB1.PrdBatId AND A.PrdBatId=CPD.PrdBatId
			--AND CPD.PrdID IN (SELECT DISTINCT PrdId FROM @ProductBatchWithCounter))GROUP BY A.PrdId 
			
		--	INSERT INTO @ContractPrice (PrdId,PrdBatId)
		--	SELECT A.PrdId,MAX(A.PrdBatId) AS PrdBatId FROM ProductBatch A (NOLOCK),
		--	ContractPricingDetails B (NOLOCK),@ProductBatchWithCounter C
  --          WHERE A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId AND A.PrdId = C.Prdid AND B.PrdId = C.Prdid 
  --          GROUP BY A.PrdId ORDER BY A.PrdId
			        
		--	IF EXISTS(SELECT * FROM @ContractPrice)
		--	BEGIN
						
		--		SELECT DISTINCT PrdbatId,PriceId,Max(PriceCode) as PriceCode INTO #ProductBatchDetails 
		--		FROM ProductBatchDetails
		--		GROUP BY PrdbatId,PriceId
		--		INSERT INTO @ContractBatchPrice (ContractId,CtgMainId,PrdId,PrdBatId,PriceId,PriceCode) 
		--		SELECT Max(C.ContractId) as ContractId,D.CtgMainId,E.PrdId,E.PrdBatId,C.PriceId AS PriceId,
		--		--CAST('' AS NVARCHAR(4000)) AS PriceCode
		--		PriceCode
		--		FROM  ContractPricingMaster D (NOLOCK) 
		--		INNER JOIN  ContractPricingDetails C (NOLOCK)   ON C.ContractId = D.ContractId
		--		INNER JOIN  #ProductBatchDetails A (NOLOCK) ON A.PrdBatId = C.PrdBatId AND A.PriceId = C.PriceId
		--		INNER JOIN @ContractPrice E  ON E.PrdBatId = C.PrdBatId AND E.PrdId = C.PrdId 
		--		GROUP BY D.CtgMainId,E.PrdId,E.PrdBatId,C.PriceId ,PriceCode
			
		--	    --INSERT INTO @ContractBatchPrice (ContractId,CtgMainId,PrdId,PrdBatId,PriceId,PriceCode)
		--	    --SELECT DISTINCT MAX(D.ContractId) AS ContractId,D.CtgMainId,E.PrdId,E.PrdBatId,C.PriceId AS PriceId,
		--	    --CAST('' AS NVARCHAR(4000)) AS PriceCode FROM ProductBatchDetails A (NOLOCK),
		--	    --ContractPricingDetails C (NOLOCK),ContractPricingMaster D (NOLOCK),@ContractPrice E 
		--	    --WHERE A.PrdBatId = C.PrdBatId AND A.PriceId = C.PriceId AND C.ContractId = D.ContractId AND E.PrdId = C.PrdId 
		--	    --AND E.PrdBatId = C.PrdBatId GROUP BY D.CtgMainId,E.PrdId,E.PrdBatId,C.PriceId    
			
		--	    --UPDATE A SET A.PriceCode = D.PriceCode FROM @ContractBatchPrice A,ContractPricingDetails B WITH(NOLOCK),
		--	    --ContractPricingMaster C WITH(NOLOCK),ProductBatchDetails D WITH(NOLOCK) WHERE A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId 
		--	    --AND A.CtgMainId = C.CtgMainId AND D.PrdBatId = A.PrdBatId AND A.ContractId = C.ContractId AND B.ContractId = C.ContractId 
		--	    --UPDATE A SET A.PriceCode = D.PriceCode
		--	    --FROM @ContractBatchPrice A 
		--	    --INNER JOIN ContractPricingDetails B WITH(NOLOCK) ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId 
		--	    --INNER JOIN ContractPricingMaster C WITH(NOLOCK) ON   A.CtgMainId = C.CtgMainId  AND A.ContractId = C.ContractId AND B.ContractId = C.ContractId and A.ContractId=B.ContractId
		--	    --INNER JOIN #ProductBatchDetails D WITH(NOLOCK) ON D.PrdBatId = A.PrdBatId 
			    
		--	    --select 'Botree',* from @ProductBatchPriceWithCounter
		--	    --select 'Software',* from @ContractBatchPrice
		--		SELECT DISTINCT SlNo INTO #BatchCreation FROM BatchCreation A (NOLOCK)
		--		INNER JOIN (SELECT MAX(BatchseqId)  as BatchseqId FROM BatchCreationMaster (NOLOCK))X
		--		ON A.BatchSeqId=X.BatchSeqId
			
		--	    INSERT INTO @ProductBatchDetails (PrdId,PrdBatId,PriceId,PriceCode,NewBatchId,Slno,PrdBatDetailValue,NewPriceId) 
		--		SELECT DISTINCT A.PrdId,A.PrdBatId,A.PriceId,A.PriceCode,B.PrdBatId AS NewBatchId,PBD.Slno,PrdBatDetailValue,
		--		DENSE_RANK ()OVER (ORDER BY A.PriceId,A.PrdbatId,B.PrdBatId)+ @OldPriceId AS NewPriceId 
		--		FROM @ContractBatchPrice A INNER JOIN @ProductBatchPriceWithCounter B 
		--		ON A.PrdId = B.PrdId
		--		INNER JOIN ProductBatchDetails PBD WITH(NOLOCK) ON PBD.PrdBatId=A.PrdBatId and PBD.PriceId=A.PriceId 
		--		INNER JOIN #BatchCreation C WITH(NOLOCK) ON C.SlNo=PBD.Slno
		--		ORDER BY A.PrdId,A.PrdBatId,A.PriceId,B.PrdBatId
															            
		--		IF(SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatSeqId)=4
		--		BEGIN
		--			INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,
		--		    PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		--			SELECT DISTINCT NewPriceId,NewBatchId,PriceCode,@BatSeqId,SlNo,PrdBatDetailValue,0,1,
		--			1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) 
		--			FROM @ProductBatchDetails
					
		--			UPDATE A SET A.PrdBatDetailValue = B.MRP FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 1
					
		--			UPDATE A SET A.PrdBatDetailValue = B.ListPrice FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 2
					
		--			UPDATE A SET A.PrdBatDetailValue = B.ClaimRate FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 4 
		--		END
		--		ELSE IF (SELECT COUNT(*) FROM BatchCreation WHERE BatchSeqId=@BatSeqId)=5
		--		BEGIN
		--			INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,
		--			PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		--			SELECT DISTINCT NewPriceId,NewBatchId,PriceCode,@BatSeqId,SlNo,PrdBatDetailValue,0,1,
		--			1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,CONVERT(NVARCHAR(10),GETDATE(),121) 
  --                  FROM @ProductBatchDetails
  --                  UPDATE A SET A.PrdBatDetailValue = B.MRP FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 1
					
		--			UPDATE A SET A.PrdBatDetailValue = B.ListPrice FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 2
					
		--			UPDATE A SET A.PrdBatDetailValue = B.ClaimRate FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 4
					
		--			UPDATE A SET A.PrdBatDetailValue = B.AddRate1 FROM ProductBatchDetails A,@ProductBatchPriceWithCounter B
		--			WHERE A.PrdBatId = B.PrdBatId AND A.Slno = 5
					
		--		END	
				
		--		    IF EXISTS (SELECT * FROM @ProductBatchDetails)
		--		    BEGIN
		--				INSERT INTO ContractPricingDetails(ContractId,PrdId,PrdBatId,PriceId,Discount,FlatAmtDisc,
		--				Availability,LastModBy,LastModDate,AuthId,AuthDate,CtgValMainId)
		--				SELECT DISTINCT ContractId,A.PrdId,NewBatchId,NewPriceId,Discount,FlatAmtDisc,
		--				Availability,LastModBy,GETDATE(),AuthId,GETDATE(),CtgValMainId
		--				FROM ContractPricingDetails	A,@ProductBatchDetails B WHERE A.PrdId = B.PrdId 
		--				AND A.PrdBatId = B.PrdBatId	AND A.PriceId = B.PriceId
		--			END	
						--UPDATE Counters SET CurrValue = (SELECT MAX(PriceId) FROM ProductBatchDetails) 
						--WHERE TabName = 'ProductBatchDetails' AND FldName = 'PriceId'				 
		--	END
		END
	END
	
	SELECT @NewPriceId=CurrValue FROM Counters (NOLOCK)	WHERE TabName='ProductBatchDetails' AND FldName='PriceId' 		
	IF @NewPriceId>@OldPriceId
	BEGIN
		IF EXISTS(SELECT * FROM Configuration(NOLOCK) WHERE ModuleId='BotreeRateForOldBatch'
		AND ModuleName='Botree Product Batch Download' AND Status=1)
		BEGIN
			EXEC Proc_DefaultPriceUpdation @ExistPrdBatMaxId,@OldPriceId,1
		END
	END
	IF EXISTS(SELECT * FROM ProductBatchDetails WHERE PriceId>=@OldPriceId)
	BEGIN
		EXEC Proc_DefaultPriceHistory 0,0,@NewPriceId,2,1
	END
	---MOORTHI  START
	IF @ExistPrdBatMaxId>0
	BEGIN		
		SET @BatchTransfer=0
		SELECT @BatchTransfer=Status FROM Configuration WHERE ModuleId='BotreeAutoBatchTransfer'
		IF @BatchTransfer=1
		BEGIN
			EXEC Proc_AutoBatchTransfer @ExistPrdBatMaxId,@Po_ErrNo = @Po_BatchTransfer OUTPUT
			IF @Po_BatchTransfer=1
			BEGIN
				INSERT INTO Errorlog VALUES (1,'Cn2Cs_Prk_BLProductBatch','Product Batch-Auto Batch Transfer',
				'Auto Batch Transfer is not done properly')           	
				SET @Po_ErrNo=1				
			END
		END
	END	
	--END
	
	UPDATE Cn2Cs_Prk_ProductBatch SET DownLoadFlag='Y' 
	WHERE PrdCCode+'~'+PrdBatCode IN (SELECT P.PrdCCode+'~'+PB.PrdBatCode
	FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
	
	RETURN		
END
GO
IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE name='Proc_CN2CS_ProductCodeUnification' AND xtype='P')
DROP PROCEDURE Proc_CN2CS_ProductCodeUnification
GO
/*
   BEGIN TRANSACTION
  EXEC Proc_CN2CS_ProductCodeUnification 0
  SELECT * FROM Errorlog (NOLOCK)
  select * from ProductBatch (Nolock) where PrdId in (473,799,971)
  select * from ProductBatchDetails A (Nolock) INNER JOIN  ProductBatch B (Nolock) ON A.PrdBatId = B.PrdBatId where PrdId in (473,799,971)
  select * from ProductBatchLocation (Nolock) where PrdId in (473,799,971)
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
DELETE FROM CN2CS_Prk_ProductCodeUnification WHERE DownLoadFlag = 'Y'

	CREATE TABLE #ToAvoidProducts
	(
	  ProductCode NVARCHAR(200),
	  MapProductCode NVARCHAR(200)
	)
	
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
	SELECT DISTINCT B.PrdId AS PPrdId,B.TaxGroupId,C.PrdId AS CPrdId INTO #ProductCodeUnification 
	FROM CN2CS_Prk_ProductCodeUnification A (NOLOCK)
	INNER JOIN Product B (NOLOCK) ON A.ProductCode = B.PrdCCode
	INNER JOIN Product C (NOLOCK) ON A.MapProductCode = C.PrdCCode
	WHERE NOT EXISTS (SELECT DISTINCT ProductCode,MapProductCode FROM #ToAvoidProducts D WHERE A.ProductCode = D.ProductCode 
	AND A.MapProductCode = D.MapProductCode) AND NOT EXISTS (SELECT DISTINCT PrdId FROM ProductBatch E (NOLOCK) WHERE B.PrdId = E.PrdId)
	AND DownLoadFlag = 'D' ORDER BY PPrdId,CPrdId ASC
	
	--Child Product Latest Batch
	SELECT DISTINCT PPrdId,TaxGroupId,MAX(CPrdBatId) AS CPrdBatId INTO #ProductBatch FROM (
	SELECT DISTINCT PPrdId,TaxGroupId,CPrdId,CPrdBatId FROM #ProductCodeUnification A INNER JOIN
	(SELECT PrdId,MAX(PrdBatId) AS CPrdBatId FROM ProductBatch (NOLOCK) GROUP BY PrdId)B ON A.CPrdId = B.PrdId)Qry
	GROUP BY PPrdId,TaxGroupId
	
	--Child Product Latest Batch Details
    SELECT PPrdId,TaxGroupId,CPrdBatId,CPriceId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue
    INTO #ProductBatchDetails FROM #ProductBatch A INNER JOIN
    (SELECT DISTINCT PrdBatId,MAX(PriceId) AS CPriceId FROM ProductBatchDetails (NOLOCK) GROUP BY PrdBatId)B ON A.CPrdBatId = B.PrdBatId
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
    CONVERT(NVARCHAR(10),GETDATE(),121),0 FROM #ParentProductBatchDetails ORDER BY PPriceId,PPrdBatId
    
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
		
	--Main Product Stock Posting IN
	DECLARE CUR_STOCKADJIN CURSOR
	FOR SELECT DISTINCT ToPrdId,ToPrdBatId,LcnId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalTotStock,
	SUM(UnSalStock) AS UnSalTotStock,SUM(OfferStock) AS OfferTotStock FROM #ManualStockPosting WITH (NOLOCK) 
	GROUP BY ToPrdId,ToPrdBatId,LcnId ORDER BY ToPrdId,ToPrdBatId
	OPEN CUR_STOCKADJIN		
	FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
	WHILE @@FETCH_STATUS = 0
	BEGIN	
	        IF @SalTotQty > 0
	        BEGIN
	            --SALEABLE STOCK IN									
				EXEC Proc_UpdateStockLedger 10,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,0
				EXEC Proc_UpdateProductBatchLocation 1,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,1,0		
			END
			IF @UnSalTotQty > 0
			BEGIN
			   --UNSALEABLE STOCK IN									
				EXEC Proc_UpdateStockLedger 11,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,0
				EXEC Proc_UpdateProductBatchLocation 2,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@UnSalTotQty,1,0
			END
			IF @OfferTotQty > 0
			BEGIN
			    --OFFER STOCK IN									
				EXEC Proc_UpdateStockLedger 12,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,0
				EXEC Proc_UpdateProductBatchLocation 3,1,@ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@OfferTotQty,1,0
			END
					
	FETCH NEXT FROM CUR_STOCKADJIN INTO @ToPrdId,@ToPrdBatId,@LcnId,@InvDate,@SalTotQty,@UnSalTotQty,@OfferTotQty
	END
	CLOSE CUR_STOCKADJIN
	DEALLOCATE CUR_STOCKADJIN
	--Till Here
	
	--Mapped Product Stock Posting OUT
	DECLARE CUR_STOCKADJOUT CURSOR
	FOR SELECT DISTINCT PrdId,PrdBatId,LcnId,CONVERT(NVARCHAR(10),GETDATE(),121) AS InvDate,SUM(SalStock) AS SalStock,
	SUM(UnSalStock) AS UnSalStock,SUM(OfferStock) AS OfferStock FROM #ManualStockPosting WITH (NOLOCK) 
	GROUP BY PrdId,PrdBatId,LcnId ORDER BY PrdId,PrdBatId
	OPEN CUR_STOCKADJOUT		
	FETCH NEXT FROM CUR_STOCKADJOUT INTO @PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,@UnSalQty,@OfferQty
	WHILE @@FETCH_STATUS = 0
	BEGIN	
	        IF @SalQty > 0
	        BEGIN
				--SALEABLE STOCK OUT
				EXEC Proc_UpdateStockLedger 13,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,1,0
				EXEC Proc_UpdateProductBatchLocation 1,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,1,0				
			END
			IF @UnSalQty > 0
			BEGIN
				--UNSALEABLE STOCK OUT
				EXEC Proc_UpdateStockLedger 14,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalQty,1,0
				EXEC Proc_UpdateProductBatchLocation 2,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@UnSalQty,1,0
			END
			IF @OfferQty > 0
			BEGIN
				--OFFER STOCK OUT
				EXEC Proc_UpdateStockLedger 15,1,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferQty,1,0
				EXEC Proc_UpdateProductBatchLocation 3,2,@PrdId,@PrdBatId,@LcnId,@InvDate,@OfferQty,1,0
			END
					
	FETCH NEXT FROM CUR_STOCKADJOUT INTO @PrdId,@PrdBatId,@LcnId,@InvDate,@SalQty,@UnSalQty,@OfferQty
	END
	CLOSE CUR_STOCKADJOUT
	DEALLOCATE CUR_STOCKADJOUT	
	--Till Here
	
	SELECT DISTINCT A.PrdId,(SUM(PrdBatLcnSih)-SUM(PrdBatLcnRessih)) AS SalStock,(SUM(PrdBatLcnUih)-SUM(PrdBatLcnResUih)) AS UnSalStock,
	(SUM(PrdBatLcnFre)-SUM(PrdBatLcnResFre)) AS OfferStock INTO #FinalStockAvailable FROM ProductBatchLocation A (NOLOCK) 
	INNER JOIN Product B (NOLOCK) ON A.PrdId = B.PrdId 
	INNER JOIN CN2CS_Prk_ProductCodeUnification C (NOLOCK) ON B.PrdCCode = C.MapProductCode
	WHERE NOT EXISTS (SELECT ProductCode,MapProductCode FROM #ToAvoidProducts TA 
	WHERE C.ProductCode = TA.ProductCode AND C.MapProductCode = TA.MapProductCode) GROUP BY A.PrdId
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
	    
	RETURN
END
GO
IF EXISTS (SELECT Name FROM Sysobjects (NOLOCK) WHERE Xtype = 'P' AND Name = 'Proc_ClosingStockTaxCalCulation')
DROP PROCEDURE Proc_ClosingStockTaxCalCulation
GO
/*
  BEGIN TRANSACTION
  EXEC Proc_ClosingStockTaxCalCulation
  SELECT * FROM ClosingStockProductTaxPercent (NOLOCK)
  ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_ClosingStockTaxCalCulation]
AS
BEGIN
		DECLARE @TaxSettingDet TABLE       
		(      
			TaxSlab    INT,      
			ColNo      INT,      
			SlNo       INT,      
			BillSeqId  INT,      
			TaxSeqId   INT,      
			ColType    INT,       
			ColId      INT,      
			ColVal     NUMERIC(38,2),
			PrdId      NUMERIC(18,0)      
		) 
		
		DECLARE @PurSeqId AS INT
		DECLARE @BillSeqId AS INT
		DECLARE @RtrTaxGrp AS INT		 
		DECLARE @TaxSlab  INT  
		DECLARE @MRP INT    
		DECLARE @TaxableAmount  NUMERIC(28,10)      
		DECLARE @ParTaxableAmount NUMERIC(28,10)      
		DECLARE @TaxPer   NUMERIC(38,2)     
		DECLARE @TaxPercentage   NUMERIC(38,5)   
		DECLARE @TaxId   INT
		
		--To Take the Batch TaxGroup Id      
		--SELECT @PrdBatTaxGrp = TaxGroupId FROM Product A (NOLOCK) INNER JOIN TempClosingStock B (NOLOCK) ON A.PrdId = B.PrdId
		SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster (NOLOCK)
		SELECT @RtrTaxGrp = MAX(DISTINCT RtrId) FROM TaxSettingMaster A (NOLOCK) 
		INNER JOIN TaxGroupSetting B (NOLOCK) ON A.RtrId = B.TaxGroupId WHERE B.TaxGroup = 1
		
		INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,PrdId)      
		SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal,C.PrdId      
		FROM TaxSettingMaster A (NOLOCK) INNER JOIN	TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
		AND B.BillSeqId=@BillSeqId AND Coltype IN(1,3) 
		INNER JOIN 
		(SELECT DISTINCT A.PrdId,TaxGroupId FROM Product A (NOLOCK) INNER JOIN TempClosingStock B (NOLOCK) ON A.PrdId = B.PrdId) C 
		ON A.PrdId = C.TaxGroupId  WHERE A.RtrId = @RtrTaxGrp     
		AND A.TaxSeqId IN (SELECT ISNULL(MAX(TaxSeqId),0) FROM TaxSettingMaster 
		WHERE RtrId = @RtrTaxGrp AND PrdId = C.TaxGroupId)  
		TRUNCATE TABLE ClosingStockProductTaxPercent   
		      
		--To Get the Tax Percentage for the selected slab      
		SELECT PrdId,ColVal AS TaxPerc,TaxSlab INTO #TaxPercentage FROM @TaxSettingDet 
		WHERE ColType = 1 AND ColId = 0 AND ColVal > 0
		
		--Addtional Tax
		SELECT DISTINCT A.PrdId,A.TaxSlab,B.TaxPerc,CAST(1*(B.TaxPerc/100) AS NUMERIC(28,10)) AS TaxAmount
		INTO #ClosingStockAddTax FROM @TaxSettingDet A INNER JOIN #TaxPercentage B ON A.TaxSlab = B.TaxSlab 
		AND A.PrdId = B.PrdId WHERE ColType = 3 AND ColVal > 0 	
		
		SELECT DISTINCT A.PrdId,A.TaxSlab,B.TaxPerc,CAST(1*(B.TaxPerc/100) AS NUMERIC(28,10)) AS TaxAmount
		INTO #ClosingStockTax FROM @TaxSettingDet A INNER JOIN #TaxPercentage B ON A.TaxSlab = B.TaxSlab AND A.PrdId = B.PrdId
		WHERE ColVal > 0 AND NOT EXISTS (SELECT PrdId FROM #ClosingStockAddTax C WHERE A.PrdId = C.PrdId 
		AND A.TaxSlab = C.TaxSlab)
		
		INSERT INTO #ClosingStockTax (PrdId,TaxSlab,TaxPerc,TaxAmount)
		SELECT DISTINCT A.PrdId,A.TaxSlab,A.TaxPerc,CAST((B.TaxAmount * A.TaxAmount) AS NUMERIC(28,10)) AS TaxAmount
		FROM #ClosingStockAddTax A INNER JOIN #ClosingStockTax B ON A.PrdId = B.PrdId
		
		INSERT INTO ClosingStockProductTaxPercent(PrdId,TaxPercentage)
		SELECT DISTINCT PrdId,ISNULL(SUM(TaxAmount)*100,0) FROM #ClosingStockTax (NOLOCK) GROUP BY PrdId
		
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_RptCurrentStockParle')
DROP PROCEDURE Proc_RptCurrentStockParle
GO
--Exec Proc_RptCurrentStockParle 249,1,0,'PARLE',0,0,1,0
CREATE PROCEDURE [dbo].[Proc_RptCurrentStockParle]
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
		--Till Here
	--If Product Category Filter is available
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @fPrdCatPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @fPrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	--Till Here
	SELECT DISTINCT Prdid,U.ConversionFactor 
	Into #PrdUomBox
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	Inner Join UomMaster UM On U.UomId=Um.UomId
	Where Um.UomCode='BX'

	INSERT Into #PrdUomBox		
	SELECT DISTINCT Prdid,U.ConversionFactor
	FROM Product P INNER JOIN UOMGROUP U ON P.UomgroupId =U.Uomgroupid
	INNER JOIN UomMaster UM On U.UomId=Um.UomId
	Where  P.PrdId Not In (Select PrdId From #PrdUomBox) AND U.ConversionFactor > 1
			
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
						
	Create TABLE #RptCurrentStock
	(
		PrdId            INT,
		PrdDcode         NVARCHAR(100),
		PrdName      NVARCHAR(200),
		PrdBatId         INT,
		PrdBatCode       NVARCHAR(100),
		MRP              NUMERIC (38,6),
		DisplayRate      NUMERIC (38,6),
		Saleable         INT,
		SaleableWgt	     NUMERIC (38,6),
		Unsaleable       INT,
		UnsaleableWgt	 NUMERIC (38,6),
		Offer            INT,
		OfferWgt		 NUMERIC (38,6),
		DisplaySalRate   NUMERIC (38,6),
		DisplayUnSalRate NUMERIC (38,6),
		DisplayTotRate   NUMERIC (38,6),
		StockType	     INT
		
	)
	SET @TblName = 'RptCurrentStock'
	SET @TblStruct = '  PrdId      INT,
						PrdDcode    NVARCHAR(100),
						PrdName     NVARCHAR(200),
						PrdBatId       INT,
						PrdBatCode     NVARCHAR(100),
						MRP            NUMERIC (38,6),
						DisplayRate    NUMERIC (38,6),
						Saleable       INT,
						SaleableWgt	    NUMERIC (38,6),
						Unsaleable		INT,
						UnsaleableWgt	 NUMERIC (38,6),
						Offer           INT,
						OfferWgt		 NUMERIC (38,6),
						DisplaySalRate    NUMERIC (38,6),
						DisplayUnSalRate   NUMERIC (38,6),
						DisplayTotRate     NUMERIC (38,6),
						StockType		   INT'
	SET @TblFields = 'PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
	Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,StockType'
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
	     INSERT INTO #RptCurrentStock (PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,MRP,DisplayRate,
				Saleable,SaleableWgt,Unsaleable,UnsaleableWgt,Offer,OfferWgt,DisplaySalRate,DisplayUnSalRate,DisplayTotRate,StockType)
								SELECT VC.PrdId,PrdDcode,PrdName,0,0,
				dbo.Fn_ConvertCurrency(MRP,@Pi_CurrencyId) AS MRP,
				(CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(ListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(MRP,1) END ) AS DisplayRate,
				SUM(Saleable) AS Saleable,(SUM(Saleable)* P.PrdWgt),
				SUM(Unsaleable) AS Unsaleable,(SUM(Unsaleable)* P.PrdWgt),
				SUM(Offer) AS Offer,(SUM(Offer)* P.PrdWgt),
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(SalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(SalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(SalMRP,@Pi_CurrencyId) END )) AS DisplaySalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(UnSalSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(UnSalListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(UnSalMRP,@Pi_CurrencyId) END )) AS DisplayUnSalRate,
				SUM((CASE @StockValue WHEN 1 THEN dbo.Fn_ConvertCurrency(TotSelRate,@Pi_CurrencyId)
				WHEN 2 THEN dbo.Fn_ConvertCurrency(TotListPrice,@Pi_CurrencyId)
				ELSE dbo.Fn_ConvertCurrency(TotMRP,@Pi_CurrencyId) END )) AS DisplayTotRate,@StockType
				FROM dbo.View_CurrentStockReportParle VC LEFT OUTER JOIN #PrdWeight P ON VC.PrdId = P.PrdId 
				WHERE (CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
				CmpId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				AND   (LcnId=  (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END ) OR
				LcnId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
				AND   (VC.PrdId = (CASE @fPrdCatPrdId WHEN 0 THEN VC.PrdId Else 0 END) OR
				VC.PrdId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
				AND   (VC.PrdId = (CASE @fPrdId WHEN 0 THEN VC.PrdId Else 0 END) OR
				VC.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				AND   (PrdStatus=(CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END ) OR
				PrdStatus IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))
				AND   (Status= (CASE @PrdBatStatus WHEN 0 THEN Status ELSE -1 END ) OR
				Status IN (SELECT iCountId-1 FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))
				AND   (PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR
				PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))) 
				--AND	UsrId = @Pi_UsrId
				GROUP BY VC.PrdId,PrdDcode,PrdName,MRP,ListPrice,SelRate,P.PrdWgt Order By PrdDcode
				
				--UPDATE #RptCurrentStock 
				
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
	IF @SupZeroStock = 1
		BEGIN
        SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,MAX(A.DisplayRate) AS DisplayRate,
        Case When SUM(Saleable)<MAX(ConversionFactor) Then 0 Else SUM(Saleable)/MAX(ConversionFactor) End  As SaleableBOX,
		Case When SUM(Saleable)<MAX(ConversionFactor) Then SUM(Saleable) Else SUM(Saleable)%MAX(ConversionFactor) End  As SaleablePKT,
		Case When SUM(UnSaleable)<MAX(ConversionFactor) Then 0 Else SUM(UnSaleable)/MAX(ConversionFactor) End  As UnSaleableBOX,
		Case When SUM(UnSaleable)<MAX(ConversionFactor) Then SUM(UnSaleable) Else SUM(UnSaleable)%MAX(ConversionFactor) End  As UnSaleablePKT,
		Case When SUM(Offer)<MAX(ConversionFactor) Then 0 Else SUM(Offer)/MAX(ConversionFactor) End  As OfferBOX,
		Case When SUM(Offer)<MAX(ConversionFactor) Then SUM(Offer) Else SUM(Offer)%MAX(ConversionFactor) End As OfferPKT,
        SUM(A.DisplaySalRate) AS DisplaySalRate,SUM(A.DisplayUnSalRate) AS DisplayUnSalRate,SUM(A.DisplayTotRate) AS DisplayTotRate,A.StockType 
		FROM #RptCurrentStock A,#PrdUomAll B WHERE A.Prdid = B.Prdid 
	    GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,A.StockType Having SUM(A.Saleable + A.UnSaleable + A.Offer)<>0 Order By A.PrdDcode
			IF EXISTS(SELECT * FROM Sysobjects WHERE Name = 'RptCurrentStockReportParle_Excel' And XTYPE = 'U')
	        DROP TABLE RptCurrentStockReportParle_Excel
			SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,MAX(A.DisplayRate) AS DisplayRate,
			Case When SUM(Saleable)<MAX(ConversionFactor) Then 0 Else SUM(Saleable)/MAX(ConversionFactor) End  As SaleableBOX,
			Case When SUM(Saleable)<MAX(ConversionFactor) Then SUM(Saleable) Else SUM(Saleable)%MAX(ConversionFactor) End  As SaleablePKT,
			Case When SUM(UnSaleable)<MAX(ConversionFactor) Then 0 Else SUM(UnSaleable)/MAX(ConversionFactor) End  As UnSaleableBOX,
			Case When SUM(UnSaleable)<MAX(ConversionFactor) Then SUM(UnSaleable) Else SUM(UnSaleable)%MAX(ConversionFactor) End  As UnSaleablePKT,
			Case When SUM(Offer)<MAX(ConversionFactor) Then 0 Else SUM(Offer)/MAX(ConversionFactor) End  As OfferBOX,
			Case When SUM(Offer)<MAX(ConversionFactor) Then SUM(Offer) Else SUM(Offer)%MAX(ConversionFactor) End As OfferPKT,
			SUM(A.DisplaySalRate) AS DisplaySalRate,SUM(A.DisplayUnSalRate) AS DisplayUnSalRate,SUM(A.DisplayTotRate) AS DisplayTotRate,A.StockType 
			INTO RptCurrentStockReportParle_Excel FROM #RptCurrentStock A,#PrdUomAll B WHERE A.PrdId = B.PrdId
			GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,A.StockType Having SUM(A.Saleable + A.UnSaleable + A.Offer)<>0 Order By A.PrdDcode
		    DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock WHERE (Saleable+UnSaleable+Offer)<>0
		END
		ELSE
		BEGIN
			SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,MAX(A.DisplayRate) AS DisplayRate,
			Case When SUM(Saleable)<MAX(ConversionFactor) Then 0 Else SUM(Saleable)/MAX(ConversionFactor) End  As SaleableBOX,
			Case When SUM(Saleable)<MAX(ConversionFactor) Then SUM(Saleable) Else SUM(Saleable)%MAX(ConversionFactor) End  As SaleablePKT,
			Case When SUM(UnSaleable)<MAX(ConversionFactor) Then 0 Else SUM(UnSaleable)/MAX(ConversionFactor) End  As UnSaleableBOX,
			Case When SUM(UnSaleable)<MAX(ConversionFactor) Then SUM(UnSaleable) Else SUM(UnSaleable)%MAX(ConversionFactor) End  As UnSaleablePKT,
			Case When SUM(Offer)<MAX(ConversionFactor) Then 0 Else SUM(Offer)/MAX(ConversionFactor) End  As OfferBOX,
			Case When SUM(Offer)<MAX(ConversionFactor) Then SUM(Offer) Else SUM(Offer)%MAX(ConversionFactor) End As OfferPKT,
            SUM(A.DisplaySalRate) AS DisplaySalRate,SUM(A.DisplayUnSalRate) AS DisplayUnSalRate,SUM(A.DisplayTotRate) AS DisplayTotRate,A.StockType 
			FROM #RptCurrentStock A,#PrdUomAll B WHERE A.Prdid = B.Prdid 
            GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,A.StockType Order By A.PrdDcode
				IF EXISTS(SELECT * FROM Sysobjects WHERE Name = 'RptCurrentStockReportParle_Excel' And XTYPE = 'U')
				DROP TABLE RptCurrentStockReportParle_Excel
				SELECT A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,MAX(A.DisplayRate) AS DisplayRate,
				Case When SUM(Saleable)<MAX(ConversionFactor) Then 0 Else SUM(Saleable)/MAX(ConversionFactor) End  As SaleableBOX,
				Case When SUM(Saleable)<MAX(ConversionFactor) Then SUM(Saleable) Else SUM(Saleable)%MAX(ConversionFactor) End  As SaleablePKT,
				Case When SUM(UnSaleable)<MAX(ConversionFactor) Then 0 Else SUM(UnSaleable)/MAX(ConversionFactor) End  As UnSaleableBOX,
				Case When SUM(UnSaleable)<MAX(ConversionFactor) Then SUM(UnSaleable) Else SUM(UnSaleable)%MAX(ConversionFactor) End  As UnSaleablePKT,
				Case When SUM(Offer)<MAX(ConversionFactor) Then 0 Else SUM(Offer)/MAX(ConversionFactor) End  As OfferBOX,
				Case When SUM(Offer)<MAX(ConversionFactor) Then SUM(Offer) Else SUM(Offer)%MAX(ConversionFactor) End As OfferPKT,
				SUM(A.DisplaySalRate) AS DisplaySalRate,SUM(A.DisplayUnSalRate) AS DisplayUnSalRate,SUM(A.DisplayTotRate) AS DisplayTotRate,A.StockType 
				INTO RptCurrentStockReportParle_Excel FROM #RptCurrentStock A,#PrdUomAll B WHERE A.Prdid = B.Prdid 
				GROUP BY A.PrdId,A.PrdDcode,A.PrdName,A.PrdBatId,A.PrdBatCode,A.MRP,A.StockType Order By A.PrdDcode
			DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptCurrentStock
			
		END
		RETURN
END
GO
DELETE FROM Configuration WHERE ModuleId = 'GENCONFIG9'
INSERT INTO Configuration (ModuleId,ModuleName,[Description],[Status],Condition,ConfigValue,SeqNo)
SELECT 'GENCONFIG9','General Configuration','Display Batch automatically when single batch is available in the attached screens',
1,'Sales Return',0.00,9
GO
UPDATE MenuDefToAvoid SET STATUS=1 WHERE  MenuId='mCus6'
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportPDA_NewRetailerOrderBooking' AND XTYPE ='U')
DROP TABLE ImportPDA_NewRetailerOrderBooking
GO
CREATE TABLE  ImportPDA_NewRetailerOrderBooking		
(
	[SrpCde] [varchar](50) NULL,
	[OrdKeyNo] [varchar](50) NULL,
	[OrdDt] [datetime] NULL,
	[RtrCde] [nvarchar](200) NULL,
	[Mktid] [int] NULL,
	[SrpId] [int] NULL,
	[Rtrid] [int] NULL,
	[Remarks] [nvarchar](500) NULL,
	[UploadFlag] [varchar](1) NULL,
	[Longitude] [varchar](50) NULL,
	[Latitude] [varchar](50) NULL
)
GO
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ImportPDA_NewRetailerOrderProduct' AND XTYPE ='U')
DROP TABLE ImportPDA_NewRetailerOrderProduct
GO
CREATE TABLE  ImportPDA_NewRetailerOrderProduct		
(
	SrpCde		VARCHAR(50),
	OrdKeyNo	VARCHAR(50),
	PrdId		INT,
	PrdBatId	INT,
	PriceId		INT,
	OrdQty		INT,
	UploadFlag	VARCHAR(1),
	Uomid       INT
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='PROC_IMPORT_NewRetailer_ORDERBOOKING' AND XTYPE='P')
DROP PROCEDURE PROC_IMPORT_NewRetailer_ORDERBOOKING
GO
--exec PROC_IMPORT_NewRetailer_ORDERBOOKING  
CREATE PROCEDURE PROC_IMPORT_NewRetailer_ORDERBOOKING
AS      
/*********************************/      
DECLARE @OrdKeyNo AS VARCHAR(25)      
DECLARE @UpdOPFlgSQL AS varchar(1000)      
DECLARE @RtrId AS INT      
DECLARE @MktId AS INT      
DECLARE @SrpId AS INT      
DECLARE @lError AS INT      
DECLARE @GetKeyStr AS Varchar(50)
DECLARE @RtrShipId AS INT
DECLARE @OrdPrdCnt AS INT
DECLARE @PdaOrdPrdCnt AS INT
DECLARE @OrderDate AS DateTime
DECLARE @SeqNo AS int 
Declare @Psql as varchar(8000)
DECLARE @LAUdcMasterId AS VARCHAR(50)
DECLARE @LOUdcMasterId AS VARCHAR(50)
DECLARE @Longitude AS VARCHAR(50)
DECLARE @Latitude AS VARCHAR(50)
DECLARE @PError AS INT
DECLARE @SalRpCode AS NVARCHAR(25)
DECLARE @RtrCode  AS NVARCHAR(50)
BEGIN
	BEGIN TRANSACTION T1
	DELETE FROM ImportPDA_NewRetailerOrderBooking WHERE UploadFlag='Y'
	DELETE FROM ImportPDA_NewRetailerOrderProduct WHERE UploadFlag='Y'
	
	DECLARE CUR_Import CURSOR FOR
	SELECT DISTINCT OrdKeyNo,SrpCde,RtrCde From ImportPDA_NewRetailerOrderBooking  
	OPEN CUR_Import
	FETCH NEXT FROM CUR_Import INTO @OrdKeyNo,@SalRpCode,@RtrCode 
	While @@Fetch_Status = 0
	BEGIN
		SET @OrdPrdCnt=0
		SET @PdaOrdPrdCnt=0
		SET @lError = 0
		SET @RtrId=0
		SET @RtrShipId=0
		SET @MktId=0
		
		SET @SrpId = (SELECT SMId FROM SalesMan WHERE SMCode = @SalRpCode)
		
		IF NOT EXISTS (SELECT DocRefNo FROM OrderBooking WHERE DocRefNo = @OrdKeyNo)
		BEGIN
			SET @RtrId = (SELECT RtrId FROM Retailer WHERE Rtrcode = @RtrCode)
			
			IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE RtrID = @RtrId AND RtrStatus = 1)
			BEGIN
				SET @lError = 1
			END
			
			SELECT @RtrShipId=RS.RtrShipId FROM RetailerShipAdd RS (NOLOCK) INNER JOIN Retailer R (NOLOCK) ON R.Rtrid= RS.Rtrid 
			WHERE RtrShipDefaultAdd=1  AND R.RtrId=@RtrId  
			
			SELECT RM.RMId FROM Retailer R INNER JOIN RetailerMarket RM ON R.RtrId=RM.RtrId	WHERE RtrCode=@RtrCode
			SET @MktId = (SELECT RM.RMId FROM Retailer R INNER JOIN RetailerMarket RM ON R.RtrId=RM.RtrId	WHERE RtrCode=@RtrCode)
			
			IF NOT EXISTS (SELECT RMID FROM RouteMaster WHERE RMID = @MktId AND RMstatus = 1)
			BEGIN
				SET @lError = 1 
			END
			
			IF NOT EXISTS (SELECT * FROM SalesManMarket WHERE RMID = @MktId AND SMID = @SrpId)
			BEGIN
				SET @lError = 1
			END
			
			IF NOT EXISTS(SELECT OrdKeyNo FROM  ImportPDA_NewRetailerOrderProduct WHERE OrdKeyNo=@OrdKeyNo)
			BEGIN
				SET @lError = 1
			END
			
			IF @lError=0
			BEGIN
				
				DECLARE @CNT AS INT
				DECLARE @Prdid AS INT
				DECLARE @Prdbatid AS INT
				DECLARE @PriceId AS INT
				DECLARE @OrdQty AS INT
		        SET @CNT=0
				DECLARE CUR_ImportOrderProduct CURSOR FOR
				SELECT DISTINCT PrdId,PrdBatId,PriceId,Sum(OrdQty) as OrdQty  From ImportPDA_NewRetailerOrderProduct WHERE OrdKeyNo=@OrdKeyNo GROUP BY PrdId,PrdBatId,PriceId
				OPEN CUR_ImportOrderProduct
				FETCH NEXT FROM CUR_ImportOrderProduct INTO @Prdid,@Prdbatid,@PriceId,@OrdQty
				WHILE @@FETCH_STATUS = 0
				BEGIN
						SET @PError = 0
						IF NOT EXISTS(SELECT PrdId From Product WHERE Prdid=@Prdid)
						BEGIN
							SET @PError = 1
						END
						
						IF NOT EXISTS(SELECT PrdId,Prdbatid From ProductBatch WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
						BEGIN
							SET @PError = 1
						END
						
						IF NOT EXISTS(SELECT Prdbatid From ProductBatchDetails WHERE Prdbatid=@Prdbatid and PriceId=@PriceId)
						BEGIN
							SET @PError = 1  
						END
						
						IF @OrdQty<=0
						BEGIN
							SET @PError = 1
						END
						
						IF @PError=0
						BEGIN
							SET @CNT=@CNT+1
						END 
						
				FETCH NEXT FROM CUR_ImportOrderProduct INTO @Prdid,@Prdbatid,@PriceId,@OrdQty
				END
				CLOSE CUR_ImportOrderProduct
				DEALLOCATE CUR_ImportOrderProduct
				
			SET @GetKeyStr=''  
			SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('OrderBooking','OrderNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))       
				IF LEN(LTRIM(RTRIM(@GetKeyStr)))=0  
				BEGIN  
					SET @lError = 1
					BREAK  
				END
				
			IF @lError = 0 AND @CNT>0
			BEGIN
				--HEDER 
					SELECT  @OrderDate= OrdDt FROM ImportPDA_NewRetailerOrderBooking WHERE  OrdKeyNo=@OrdKeyNo
					INSERT INTO OrderBooking(  
					OrderNo,OrderDate,DeliveryDate,CmpId,DocRefNo,AllowBackOrder,SmId,RmId,RtrId,OrdType,  
					Priority,FillAllPrd,ShipTo,RtrShipId,Remarks,RoundOff,RndOffValue,TotalAmount,Status,  
					Availability,LastModBy,LastModDate,AuthId,AuthDate,PDADownLoadFlag,Upload)  
					SELECT @GetKeyStr,Convert(DateTime,@OrderDate,121),  
					Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
					0,@OrdKeyNo,0, @SrpId as Smid,  
					@MktId as RmId,@RtrId as RtrId,0 as OrdType,0 as Priority,0 as FillAllPrd,0 as ShipTo,  
					@RtrShipId as RtrShipId,'' as Remarks,0  as RoundOff,0 as RndOffValue,  
					0 as TotalAmount,0 as Status,1,1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),  
					1,Convert(datetime,Convert(Varchar(10),Getdate(),121),121),1,0
					
					SELECT @Longitude=ISNULL(Longitude,0),@Latitude =ISNULL(Latitude,0) FROM ImportPDA_NewRetailerOrderBooking WHERE  OrdKeyNo=@OrdKeyNo 
					SELECT @LAUdcMasterId=UdcMasterId FROM UdcMaster WHERE ColumnName='Latitude'
                    SELECT @LOUdcMasterId=UdcMasterId FROM UdcMaster WHERE ColumnName='Longitude'
					UPDATE UdcDetails SET ColumnValue=@Latitude WHERE UdcMasterId=@LAUdcMasterId AND MasterRecordId=@RtrId
					UPDATE UdcDetails SET ColumnValue=@Longitude WHERE UdcMasterId=@LOUdcMasterId AND MasterRecordId=@RtrId
					
				 --DETAILS 
		    INSERT INTO ORDERBOOKINGPRODUCTS(OrderNo,PrdId,PrdBatId,UOMId1,Qty1,ConvFact1,UOMId2,Qty2,ConvFact2,TotalQty,BilledQty,Rate,
					                          MRP,GrossAmount,PriceId,Availability,LastModBy,LastModDate,AuthId,AuthDate)  
			SELECT @GetKeyStr ,Prdid,Prdbatid,UomID,OrdQty,ConversionFactor,0,0,0,OrdQty,0,
			SUM(Rate)Rate ,SUM(MRP)MRP,sum(GrossAmount)GrossAmount,sum(PriceId)PriceId,
			1,1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121),  
			1,CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),121),121) 
			FROM ( 
			SELECT P.Prdid,PB.Prdbatid,UG.UomID,OrdQty,ConversionFactor,  
			PBD.PrdBatDetailValue Rate,0 as Mrp,(PBD.PrdBatDetailValue*OrdQty) as GrossAmount,PBD.PriceId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN
			(SELECT I.PrdId,PrdBatId,PriceId,Sum(OrdQty*ConversionFactor) as OrdQty  FROM ImportPDA_NewRetailerOrderProduct I 
				INNER JOIN Product P ON P.PrdId=I.PRDID
				INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND I.UOMID=u.UomId WHERE OrdKeyNo=  @OrdKeyNo 
				GROUP BY i.PrdId,PrdBatId,PriceId) PT 
			ON PT.Prdid=P.PrdId and PT.Prdbatid=Pb.Prdbatid and Pb.PrdId=PT.Prdid	
			INNER JOIN BatchCreation BC (NOLOCK) ON BC.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD.PriceId  
			and BC.slno=PBD.SLNo AND BC.SelRte=1  and PBD.PriceId=PT.PriceId
			INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId and BaseUom='Y' 
		UNION ALL
			SELECT P.Prdid,PB.Prdbatid,UG.UomID,OrdQty,ConversionFactor,  
			0 Rate,PBD1.PrdBatDetailValue as Mrp,0 as GrossAmount,0 as PriceId
			FROM Product P (NOLOCK) INNER JOIN Productbatch PB (NOLOCK) ON P.Prdid=PB.PrdId  
			INNER JOIN
			(SELECT I.PrdId,PrdBatId,PriceId,Sum(OrdQty*ConversionFactor) as OrdQty  FROM ImportPDA_NewRetailerOrderProduct I 
				INNER JOIN Product P ON P.PrdId=I.PRDID
				INNER JOIN UomGroup U ON U.UomGroupId=P.UomGroupId AND I.UOMID=u.UomId WHERE OrdKeyNo=  @OrdKeyNo  
			 GROUP BY I.PrdId,PrdBatId,PriceId) PT 
			ON PT.Prdid=P.PrdId and PT.Prdbatid=Pb.Prdbatid and Pb.PrdId=PT.Prdid	
			INNER JOIN BatchCreation BC1 (NOLOCK) ON BC1.BatchSeqId=PB.BatchSeqId  
			INNER JOIN ProductBatchDetails PBD1 (NOLOCK) ON PBD1.PrdBatid=Pb.PrdBatid and PB.DefaultPriceId=PBD1.PriceId  
			and BC1.slno=PBD1.SLNo AND BC1.MRP=1  and PBD1.PriceId=PT.PriceId
			INNER JOIN UomGroup UG (NOLOCK) ON UG.UomGroupId=P.UomGroupId and BaseUom='Y')A
			GROUP BY Prdid,Prdbatid,UomID,OrdQty,ConversionFactor
			 
		  UPDATE OB SET TotalAmount=X.TotAmt FROM OrderBooking OB INNER JOIN(SELECT ISNULL(SUM(GrossAmount),0)as TotAmt,OrderNo  
		  FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr GROUP BY OrderNo )X  ON X.OrderNo=OB.OrderNo   
			  
		  SELECT DISTINCT SrpCde,OrdKeyNo,PrdId,PrdBatId  INTO #TEMPCHECK   
				FROM ImportPDA_NewRetailerOrderProduct WHERE OrdKeyNo=@OrdKeyNo
					
		SELECT @OrdPrdCnt=ISNULL(Count(PRDID),0) FROM ORDERBOOKINGPRODUCTS (NOLOCK) WHERE OrderNo=@GetKeyStr  
		SELECT @PdaOrdPrdCnt=ISNULL(Count(PRDID),0) FROM #TEMPCHECK (NOLOCK) WHERE OrdKeyNo=@OrdKeyNo
		
		IF @OrdPrdCnt=@PdaOrdPrdCnt  
		BEGIN 
			UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='OrderBooking' and FldName='OrderNo' 
			UPDATE ImportPDA_NewRetailerOrderBooking SET UploadFlag = 'Y' WHERE SrpCde =@SalRpCode and UploadFlag ='N' AND OrdKeyNo = @OrdKeyNo
			UPDATE ImportPDA_NewRetailerOrderProduct SET UploadFlag = 'Y' WHERE SrpCde =@SalRpCode and UploadFlag ='N' AND OrdKeyNo =@OrdKeyNo 
		END
		ELSE
		BEGIN
			SET @lError = 1
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
			SELECT @SalRpCode,'ORDERBOOKING',@OrdKeyNo,' Ordered Product Number of line count not match for the Order ' + @OrdKeyNo
			DELETE FROM ORDERBOOKINGPRODUCTS WHERE OrderNo=@GetKeyStr  
			DELETE FROM ORDERBOOKING WHERE OrderNo=@GetKeyStr  
		END 
			DROP TABLE #TEMPCHECK
				END
			END
		END
		ELSE
		BEGIN
			Delete From PDALog WHERE SrpCde = @SalRpCode And DataPoint = 'ORDERBOOKING'
			INSERT INTO PDALog(SrpCde,DataPoint,[Name],Description)
			SELECT '' + @SalRpCode + '','ORDERBOOKING',@OrdKeyNo,'Order Already exists'
		END
		
		FETCH NEXT FROM CUR_Import INTO @OrdKeyNo,@SalRpCode,@RtrCode 
	END
	CLOSE CUR_Import
	DEALLOCATE CUR_Import
	
	  --EXEC PROC_PDASALESMANDETAILS @SalRpCode
 	
	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION T1
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION T1
	END
END
GO
DELETE FROM customcaptions where TransId=52 and ctrlid=51 AND SubCtrlId IN(12,13)
INSERT INTO customcaptions 
SELECT 52,51,12,'sprCurStkHeader-52-51-12','BOX','','',1,1,1,GETDATE(),1,GETDATE(),'BOX','','',1,1 UNION
SELECT 52,51,13,'sprCurStkHeader-52-51-13','PKTS','','',1,1,1,GETDATE(),1,GETDATE(),'PKTS','','',1,1
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='TempCurStk' AND XTYPE='U')
DROP TABLE TempCurStk
GO
CREATE TABLE TempCurStk
(
	[LcnId] [int] NULL,
	[LcnName] [nvarchar](50) NULL,
	[PrdId] [bigint] NULL,
	[PrdDCode] [nvarchar](50) NULL,
	[PrdName] [nvarchar](100) NULL,
	[PrdBatId] [bigint] NULL,
	[PrdBatCode] [nvarchar](50) NULL,
	[Saleable] [numeric](38, 0) NULL,
	[UnSaleable] [numeric](38, 0) NULL,
	[Offer] [numeric](38, 0) NULL,
	[Total] [numeric](38, 0) NULL,
	[PurchaseRate] [numeric](38, 6) NULL,
	[SalPurRte] [numeric](38, 6) NULL,
	[UnSalPurRte] [numeric](38, 6) NULL,
	[OffPurRte] [numeric](38, 6) NULL,
	[TotPurRte] [numeric](38, 6) NULL,
	[SellingRate] [numeric](38, 6) NULL,
	[SalSelRte] [numeric](38, 6) NULL,
	[UnSalSelRte] [numeric](38, 6) NULL,
	[OffSelRte] [numeric](38, 6) NULL,
	[TotSelRte] [numeric](38, 6) NULL,
	[Status] [tinyint] NULL,
	[CmpId] [int] NULL,
	[PrdCtgValLinkCode] [nvarchar](500) NULL,
	[BatchSeqId] [int] NULL,
	[UserId] [int] NULL,
	[SalUom1] [int] NULL,
	[SalUom2] [int] NULL,
	[SalUom3] [int] NULL,
	[SalUom4] [int] NULL,
	[UnSalUom1] [int] NULL,
	[UnSalUom2] [int] NULL,
	[UnSalUom3] [int] NULL,
	[UnSalUom4] [int] NULL,
	[OffUom1] [int] NULL,
	[OffUom2] [int] NULL,
	[OffUom3] [int] NULL,
	[OffUom4] [int] NULL,
	[SalUom1PurRate] [numeric](38, 6) NULL,
	[SalUom2PurRate] [numeric](38, 6) NULL,
	[UnSalUom1PurRate] [numeric](38, 6) NULL,
	[UnSalUom2PurRate] [numeric](38, 6) NULL,
	[OffUom1PurRate] [numeric](38, 6) NULL,
	[OffUom2PurRate] [numeric](38, 6) NULL,
	[SalUom1SelRate] [numeric](38, 6) NULL,
	[SalUom2SelRate] [numeric](38, 6) NULL,
	[UnSalUom1SelRate] [numeric](38, 6) NULL,
	[UnSalUom2SelRate] [numeric](38, 6) NULL,
	[OffUom1SelRate] [numeric](38, 6) NULL,
	[OffUom2SelRate] [numeric](38, 6) NULL,
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TempCurStkTax')
DROP TABLE TempCurStkTax
GO
CREATE TABLE TempCurStkTax
(
	PrdId				INT,
	PrdBatId			INT,
	Saleable			BIGINT,
	UnSaleable			BIGINT,
	Offer				BIGINT,
	Total				BIGINT,
	PurchaseRate		NUMERIC(38,6),
	SalPurRte			NUMERIC(38,6),
	UnSalPurRte			NUMERIC(38,6),
	OffPurRte			NUMERIC(38,6),
	TotPurRte			NUMERIC(38,6),
	SellingRate			NUMERIC(38,6),
	SalSelRte			NUMERIC(38,6),
	UnSalSelRte			NUMERIC(38,6),
	OffSelRte			NUMERIC(38,6),
	TotSelRte			NUMERIC(38,6),
	SalTax				NUMERIC(38,6),
	PurTax				NUMERIC(38,6),
	SalUmo1             BIGINT,
	SalUom2             BIGINT,
	UnsalUom1           BIGINT,
	UnSalUom2           BIGINT,
	OffUom1             BIGINT,
	OffUom2             BIGINT,
	SalUom1PurRate      NUMERIC(38,6),
	SalUom2PurRate      NUMERIC(38,6),
	UnSalUom1PurRate    NUMERIC(38,6), 
	UnSalUom2PurRate    NUMERIC(38,6),
	OffUom1PurRate      NUMERIC(38,6),
	OffUom2PurRate      NUMERIC(38,6),
	SalUom1SelRate      NUMERIC(38,6),
	SalUom2SelRate      NUMERIC(38,6), 
	UnSalUom1SelRate    NUMERIC(38,6),
	UnSalUom2SelRate    NUMERIC(38,6),
	OffUom1SelRate      NUMERIC(38,6),
	OffUom2SelRate      NUMERIC(38,6)
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TempInventoryConsoleTax')
DROP TABLE TempInventoryConsoleTax
GO
CREATE TABLE TempInventoryConsoleTax
(
	SalTotal		BIGINT,
	Uom1SalTotal	BIGINT,
	Uom2SalTotal	BIGINT,
	UnSalTotal		BIGINT,
	Uom1UnSalTotal	BIGINT,
	Uom2UnSalTotal	BIGINT,
	OffTotal		BIGINT,
	Uom1OffTotal	BIGINT,
	Uom2OffTotal	BIGINT,
	SalPurRte		NUMERIC(38,6),
	Uom1SalPurRte	NUMERIC(38,6),
	Uom2SalPurRte	NUMERIC(38,6),
	UnSalPurRte		NUMERIC(38,6),
	Uom1UnSalPurRte	NUMERIC(38,6),
	Uom2UnSalPurRte	NUMERIC(38,6),
	OffPurRte		NUMERIC(38,6),
	Uom1OffPurRte	NUMERIC(38,6),
	Uom2OffPurRte	NUMERIC(38,6),
	SalSelRte		NUMERIC(38,6),
	Uom1SalSelRte	NUMERIC(38,6),
	Uom2SalSelRte	NUMERIC(38,6),
	UnSalSelRte		NUMERIC(38,6),
	Uom1UnSalSelRte	NUMERIC(38,6),
	Uom2UnSalSelRte	NUMERIC(38,6),
	OffSelRte		NUMERIC(38,6),
	Uom1OffSelRte	NUMERIC(38,6),
	Uom2OffSelRte	NUMERIC(38,6),
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_GetProductBatch'AND XTYPE='P')
DROP PROCEDURE Proc_GetProductBatch
GO
--EXEC Proc_GetProductBatch 0,1,0,0
CREATE PROCEDURE Proc_GetProductBatch
(
	@Pi_ResStk		INT,	
	@Pi_UserId		INT,
	@SupTaxGroupId		INT,
	@RtrTaxFroupId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_GetProductBatch
* PURPOSE	: To Get Product Batch
* CREATED	: Nandakumar R.G
* CREATED DATE	: 16/02/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*27.07.09  Srivatchan  Commented the Tax part as it is not relevant to Loreal
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
--Commented by Sri on 27.07.2009 for Loreal Specific
	DELETE FROM TempCurStk WHERE UserId=@Pi_UserId
	IF @Pi_ResStk=1
		BEGIN
	
			INSERT INTO TempCurStk
			(
				LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Saleable,
				UnSaleable,Offer,Total,PurchaseRate,SalPurRte,UnSalPurRte,OffPurRte,TotPurRte,SellingRate,SalSelRte,
				UnSalSelRte,OffSelRte,TotSelRte,Status,CmpId,PrdCtgValLinkCode,BatchSeqId,UserId
			)
			SELECT PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,
			(PrdBatLcnSih-PrdBatLcnResSih) AS Saleable,(PrdBatLcnUih-PrdBatLcnResUih) AS Unsaleable,
			(PrdBatLcnFre-PrdBatLcnResFre) AS Offer ,
			((PrdBatLcnSih-PrdBatLcnResSih)+(PrdBatLcnUih-PrdBatLcnResUih)+
			(PrdBatLcnFre-PrdBatLcnResFre)) AS Total ,
			0,0,0,0,0,0,0,0,0,0,
			PrdBat.Status , Prd.CmpId, PCV.PrdCtgValLinkCode,PrdBat.BatchSeqId,@Pi_UserId
			FROM Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),ProductBatchLocation PrdBatLcn (NOLOCK)
			CROSS JOIN Location Lcn (NOLOCK)
			WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
		END
	ELSE
		BEGIN
			INSERT INTO TempCurStk
			(
				LcnId,LcnName,PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,Saleable,
				UnSaleable,Offer,Total,PurchaseRate,SalPurRte,UnSalPurRte,OffPurRte,TotPurRte,SellingRate,SalSelRte,
				UnSalSelRte,OffSelRte,TotSelRte,Status,CmpId,PrdCtgValLinkCode,BatchSeqId,UserId
			)
			SELECT PrdBatLcn.LcnId,Lcn.LcnName,PrdBatLcn.PrdId,Prd.PrdDCode,
			Prd.PrdName,PrdBatLcn.PrdBatId,PrdBat.PrdBatCode,
			PrdBatLcnSih AS Saleable,PrdBatLcnUih AS Unsaleable,PrdBatLcnFre AS Offer ,
			(PrdBatLcnSih+PrdBatLcnUih+PrdBatLcnFre) AS Total ,
			0,0,0,0,0,0,0,0,0,0,
			PrdBat.Status , Prd.CmpId, PCV.PrdCtgValLinkCode,PrdBat.BatchSeqId,@Pi_UserId
			FROM Product Prd (NOLOCK),ProductCategoryValue PCV (NOLOCK),ProductBatch PrdBat (NOLOCK),ProductBatchLocation PrdBatLcn (NOLOCK)
			CROSS JOIN Location Lcn (NOLOCK)
			WHERE PrdBatLcn.PrdId = Prd.PrdId AND PrdBatLcn.PrdBatId = PrdBat.PrdBatId AND PrdBatLcn.LcnId = Lcn.LcnId
			AND Prd.PrdCtgValMainId=PCV.PrdCtgValMainId
		END
	
	UPDATE TempCurStk SET TempCurStk.PurchaseRate=PrdBatDet.PrdBatDetailValue
	FROM TempCurStk (NOLOCK),ProductBatchDetails PrdBatDet (NOLOCK),ProductBatch PrdBat (NOLOCK),BatchCreation BatCr (NOLOCK),Product Prd (NOLOCK)
	WHERE TempCurStk.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo 
	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
	AND BatCr.BatchSeqId=TempCurStk.BatchSeqId
	AND TempCurStk.PrdId=PrdBat.PrdId
	AND PrdBat.BatchSeqId=TempCurStk.BatchSeqId
	AND PrdBat.PrdId=TempCurStk.PrdID
	AND PrdBat.PrdId=Prd.PrdID
	AND BatCr.ListPrice=1
	
	UPDATE TempCurStk SET TempCurStk.SellingRate=PrdBatDet.PrdBatDetailValue
	FROM TempCurStk (NOLOCK),ProductBatchDetails PrdBatDet (NOLOCK),ProductBatch PrdBat (NOLOCK),BatchCreation BatCr (NOLOCK),Product Prd (NOLOCK)
	WHERE TempCurStk.PrdBatId=PrdBatDet.PrdBatId AND PrdBatDet.SlNo=BatCr.SlNo 
	AND PrdBat.DefaultPriceId=PrdBatDet.PriceId
	AND BatCr.BatchSeqId=TempCurStk.BatchSeqId
	AND TempCurStk.PrdId=PrdBat.PrdId
	AND PrdBat.BatchSeqId=TempCurStk.BatchSeqId
	AND PrdBat.PrdId=TempCurStk.PrdID
	AND PrdBat.PrdId=Prd.PrdID
	AND BatCr.SelRte=1
	
	UPDATE TempCurStk SET TotPurRte=Total*PurchaseRate,SalPurRte=Saleable*PurchaseRate,
	UnSalPurRte=UnSaleable*PurchaseRate,OffPurRte=Offer*PurchaseRate,TotSelRte=Total*SellingRate,
	SalSelRte=Saleable*SellingRate,UnSalSelRte=UnSaleable*SellingRate,OffSelRte=Offer*SellingRate

	UPDATE TempCurStk SET SalUom1=0,SalUom2=0,UnSalUom1=0,UnSalUom2=0,OffUom1=0,OffUom2=0,SalUom1PurRate=0,SalUom2PurRate=0,
						  UnSalUom1PurRate=0,UnSalUom2PurRate=0,OffUom1PurRate=0,OffUom2PurRate=0,SalUom1SelRate=0,
						  SalUom2SelRate=0,UnSalUom1SelRate=0,UnSalUom2SelRate=0,OffUom1SelRate=0,OffUom2SelRate=0
						
	SELECT Prdid,SUM(MinValue)MinValue,SUM(MaxValue)MaxValue INTO #StockSplit  
	FROM 
	(
		SELECT Prdid,U.ConversionFactor MinValue,0 MaxValue 	
			FROM Product P INNER JOIN UomGroup U ON P.UomGroupId=U.UomGroupId AND BaseUom='Y'
		UNION ALL
		SELECT Prdid,0 MinValue,Max(U.ConversionFactor) MaxValue 	
			FROM Product P INNER JOIN UomGroup U ON P.UomGroupId=U.UomGroupId AND BaseUom='N'
		group by Prdid
	)A GROUP BY Prdid
	
	DECLARE @Prdid AS INT
	DECLARE @MinValue AS INT
	DECLARE @MaxValue AS INT
	DECLARE @Saleable AS INT
	DECLARE @UnSaleable AS INT
	DECLARE @Offer AS INT
	DECLARE @LcnId AS INT
	DECLARE @PrdBatid AS INT
	DECLARE @PurchaseRate AS NUMERIC(18,6)
	DECLARE @SellingRate AS NUMERIC(18,6)
	
	DECLARE CUR_StockSplit CURSOR
	FOR SELECT T.Prdid,PrdBatid,LcnId,MinValue,MaxValue,Saleable,UnSaleable,Offer,PurchaseRate,SellingRate
		FROM #StockSplit S INNER JOIN TempCurStk T ON S.PRDID=T.PRDID
		WHERE TOTAL>0  
	OPEN CUR_StockSplit 
	FETCH NEXT FROM CUR_StockSplit INTO @Prdid,@PrdBatid,@LcnId,@MinValue,@MaxValue,@Saleable,@UnSaleable,@Offer,@PurchaseRate,@SellingRate
	WHILE @@FETCH_STATUS=0
	BEGIN	
		IF @Saleable>0 
		BEGIN
			IF @MaxValue>0
			BEGIN
				IF (@Saleable%@MaxValue)=0
				BEGIN
					UPDATE TempCurStk SET SalUom1=@Saleable/@MaxValue WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET SalUom1PurRate=SalUom1*@MaxValue*@PurchaseRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET SalUom2PurRate=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET SalUom1SelRate=SalUom1*@MaxValue*@SellingRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET SalUom2SelRate=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId					
					--SELECT @Saleable/@MaxValue
				END
				ELSE
				BEGIN
				--SELECT @Saleable/@MaxValue,@Saleable%@MaxValue
					UPDATE TempCurStk SET SalUom1=@Saleable/@MaxValue WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET SalUom2=@Saleable%@MaxValue WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET SalUom1PurRate=SalUom1*@MaxValue*@PurchaseRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET SalUom2PurRate=SalUom2*@PurchaseRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET SalUom1SelRate=SalUom1*@MaxValue*@SellingRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET SalUom2SelRate=SalUom2*@SellingRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId					
				END
			END
			ELSE
			BEGIN
				 UPDATE TempCurStk SET SalUom1=@Saleable/@MinValue WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET SalUom2=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET SalUom1PurRate=SalUom1*@MinValue*@PurchaseRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET SalUom2PurRate=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET SalUom1SelRate=SalUom1*@MinValue*@SellingRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET SalUom2SelRate=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId					

			END 
		END 

		IF @UnSaleable>0 
		BEGIN
			IF @MaxValue>0
			 BEGIN
				IF (@UnSaleable%@MaxValue)=0
				BEGIN
					UPDATE TempCurStk SET UnSalUom1=@UnSaleable/@MaxValue WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET UnSalUom1PurRate=UnSalUom1*@MaxValue*@PurchaseRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET UnSalUom2PurRate=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET UnSalUom1SelRate=UnSalUom1*@MaxValue*@SellingRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET UnSalUom2SelRate=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId					
				END
				ELSE
				BEGIN
					UPDATE TempCurStk SET UnSalUom1=@UnSaleable/@MaxValue WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET UnSalUom2=@UnSaleable%@MaxValue WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET UnSalUom1PurRate=UnSalUom1*@MaxValue*@PurchaseRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET UnSalUom2PurRate=UnSalUom2*@PurchaseRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET UnSalUom1SelRate=UnSalUom1*@MaxValue*@SellingRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET UnSalUom2SelRate=UnSalUom2*@SellingRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId					

				END
			 END
			ELSE
			 BEGIN
				 UPDATE TempCurStk SET UnSalUom1=@UnSaleable/@MinValue WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET UnSalUom2=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET UnSalUom1PurRate=UnSalUom1*@MinValue*@PurchaseRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET UnSalUom2PurRate=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET UnSalUom1SelRate=UnSalUom1*@MinValue*@SellingRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET UnSalUom2SelRate=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId					
			 END 
		END 		
		
		IF @Offer>0 
		BEGIN
			IF @MaxValue>0
			 BEGIN
				IF (@Offer%@MaxValue)=0
				BEGIN
					UPDATE TempCurStk SET OffUom1=@Offer/@MaxValue WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET OffUom1PurRate=OffUom1*@MaxValue*@PurchaseRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET OffUom2PurRate=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET OffUom1SelRate=OffUom1*@MaxValue*@SellingRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET OffUom2SelRate=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId					
				END
				ELSE
				BEGIN
					UPDATE TempCurStk SET OffUom1=@Offer/@MaxValue WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET OffUom2=@Offer%@MaxValue WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET OffUom1PurRate=OffUom1*@MaxValue*@PurchaseRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET OffUom2PurRate=OffUom2*@PurchaseRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET OffUom1SelRate=OffUom1*@MaxValue*@SellingRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
					UPDATE TempCurStk SET OffUom2SelRate=OffUom2*@SellingRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId					
				END
			 END
			ELSE
			 BEGIN
				 UPDATE TempCurStk SET OffUom1=@Offer/@MinValue WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET OffUom2=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET OffUom1PurRate=OffUom1*@MinValue*@PurchaseRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET OffUom2PurRate=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET OffUom1SelRate=OffUom1*@MinValue*@SellingRate WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId
				 UPDATE TempCurStk SET OffUom2SelRate=0 WHERE PRDID=@Prdid AND PrdBatid=@PrdBatid AND LCNID=@LcnId AND UserId=@Pi_UserId					
			 END 
		END 
	
	FETCH NEXT FROM CUR_StockSplit INTO @Prdid,@PrdBatid,@LcnId,@MinValue,@MaxValue,@Saleable,@UnSaleable,@Offer,@PurchaseRate,@SellingRate
	END 
	CLOSE CUR_StockSplit 
	DEALLOCATE CUR_StockSplit 
	

END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_InventoryConsoleTaxCalculation' AND XTYPE='P')
DROP PROCEDURE Proc_InventoryConsoleTaxCalculation
GO
--Exec Proc_InventoryConsoleTaxCalculation @PPurTaxGroupId,@PRtrTaxGroupId,1,20,5,@Pi_UsrId,@Pi_RptId
CREATE PROCEDURE [dbo].[Proc_InventoryConsoleTaxCalculation]
(
	@PPurTaxGroupId		BIGINT,
	@PRtrTaxGroupId		BIGINT,
	@PRowId				INT,
	@PBillTransId		INT,
	@PPurTransId		INT,
	@PUsrId				INT,
	@PRptId				INT
)
/*********************************
* PROCEDURE	: Proc_InventoryConsoleTaxCalculation
* PURPOSE	: To Calculate Tax For Inventory Console
* CREATED	: Alpgonse J
* CREATED DATE	: 2013-06-05
* NOTE		: SP for Tax Calculation for Inventory Console
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}      {developer}  {brief modification description}
	
*********************************/
AS	
DECLARE @PurSeqId AS BIGINT
DECLARE @BillSeqId AS BIGINT
DECLARE @PrdId AS BIGINT
DECLARE @PrdBatId AS BIGINT
DECLARE @PriceId AS BIGINT
DECLARE @RtrId AS BIGINT
DECLARE @SpmId AS BIGINT
DECLARE @TempVal AS NUMERIC(38,6)
SELECT @PurSeqId = MAX(PurSeqId)  FROM PurchaseSequenceMaster
SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster
SELECT TOP 1 @SpmId = SpmId FROM Supplier S, TaxGroupSetting T 	
WHERE T.TaxGroupid = S.Taxgroupid and T.TaxGroupId = @PPurTaxGroupId
SELECT TOP 1 @RtrId = Rtrid FROM Retailer R, TaxGroupSetting T 	
WHERE T.TaxGroupid = R.Taxgroupid and T.TaxGroupId = @PRtrTaxGroupId
	
SET NOCOUNT ON
BEGIN
	
	DELETE FROM ProductBatchTaxPercent 
	
	DECLARE CalTax CURSOR
	FOR (SELECT P.PrdId,PB.Prdbatid,PB.DefaultPriceId
	FROM Product P,productbatch PB,TempCurStkTax C WHERE P.PrdId = PB.PrdId AND C.PrdId=PB.PrdId AND C.PrdBatId=PB.PrdBatId)
		
	OPEN CalTax	
	FETCH NEXT FROM CalTax INTO @PrdId,@PrdBatId,@PriceId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		EXEC Proc_TaxCalCulation @PrdId,@PrdBatId
	
		FETCH NEXT FROM CalTax INTO @PrdId,@PrdBatId,@PriceId
	END
	
	
	CLOSE CalTax
	DEALLOCATE CalTax
END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_InventoryConsoleTax'AND XTYPE='P')
DROP PROCEDURE Proc_InventoryConsoleTax
GO
--  EXEC Proc_InventoryConsoleTax ' AND CmpId= 1 AND LcnId= 1 AND Total<>0',2,1,1
CREATE PROCEDURE Proc_InventoryConsoleTax
(      
 @Pi_Filter			VARCHAR(1000),      
 @Pi_SupTax			INT,        
 @Pi_RetTax			INT,
 @Pi_UserId			INT
)      
AS      
/*********************************      
* PROCEDURE : Proc_ComputeTax      
* PURPOSE : To Calculate Current Stock with Tax      
* CREATED : Alphonse J      
* CREATED DATE : 04/06/2013      
* MODIFIED
------------------------------------------------      
* {date} {developer}  {brief modification description}            
*********************************/       
SET NOCOUNT ON      
BEGIN
	DECLARE @sSQL NVARCHAR(MAX)
		
	IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TempCurStkTax')
	DROP TABLE TempCurStkTax
	CREATE TABLE TempCurStkTax
	(
		PrdId				INT,
		PrdBatId			INT,
		Saleable			BIGINT,
		UnSaleable			BIGINT,
		Offer				BIGINT,
		Total				BIGINT,
		PurchaseRate		NUMERIC(38,6),
		SalPurRte			NUMERIC(38,6),
		UnSalPurRte			NUMERIC(38,6),
		OffPurRte			NUMERIC(38,6),
		TotPurRte			NUMERIC(38,6),
		SellingRate			NUMERIC(38,6),
		SalSelRte			NUMERIC(38,6),
		UnSalSelRte			NUMERIC(38,6),
		OffSelRte			NUMERIC(38,6),
		TotSelRte			NUMERIC(38,6),
		SalTax				NUMERIC(38,6),
		PurTax				NUMERIC(38,6),
		SalUmo1             BIGINT,
		SalUom2             BIGINT,
		UnsalUom1           BIGINT,
		UnSalUom2           BIGINT,
		OffUom1             BIGINT,
		OffUom2             BIGINT,
		SalUom1PurRate      NUMERIC(38,6),
		SalUom2PurRate      NUMERIC(38,6),
		UnSalUom1PurRate    NUMERIC(38,6), 
		UnSalUom2PurRate    NUMERIC(38,6),
		OffUom1PurRate      NUMERIC(38,6),
		OffUom2PurRate      NUMERIC(38,6),
		SalUom1SelRate      NUMERIC(38,6),
		SalUom2SelRate      NUMERIC(38,6), 
		UnSalUom1SelRate    NUMERIC(38,6),
		UnSalUom2SelRate    NUMERIC(38,6),
		OffUom1SelRate      NUMERIC(38,6),
		OffUom2SelRate      NUMERIC(38,6)
	)
	
	IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TempInventoryConsoleTax')
	DROP TABLE TempInventoryConsoleTax
	CREATE TABLE TempInventoryConsoleTax
	(
		SalTotal		BIGINT,
		Uom1SalTotal	BIGINT,
		Uom2SalTotal	BIGINT,
		UnSalTotal		BIGINT,
		Uom1UnSalTotal	BIGINT,
		Uom2UnSalTotal	BIGINT,
		OffTotal		BIGINT,
		Uom1OffTotal	BIGINT,
		Uom2OffTotal	BIGINT,
		SalPurRte		NUMERIC(38,6),
		Uom1SalPurRte	NUMERIC(38,6),
		Uom2SalPurRte	NUMERIC(38,6),
		UnSalPurRte		NUMERIC(38,6),
		Uom1UnSalPurRte	NUMERIC(38,6),
		Uom2UnSalPurRte	NUMERIC(38,6),
		OffPurRte		NUMERIC(38,6),
		Uom1OffPurRte	NUMERIC(38,6),
		Uom2OffPurRte	NUMERIC(38,6),
		SalSelRte		NUMERIC(38,6),
		Uom1SalSelRte	NUMERIC(38,6),
		Uom2SalSelRte	NUMERIC(38,6),
		UnSalSelRte		NUMERIC(38,6),
		Uom1UnSalSelRte	NUMERIC(38,6),
		Uom2UnSalSelRte	NUMERIC(38,6),
		OffSelRte		NUMERIC(38,6),
		Uom1OffSelRte	NUMERIC(38,6),
		Uom2OffSelRte	NUMERIC(38,6),
		
	)
	
	INSERT INTO TempInventoryConsoleTax SELECT 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    SET @sSQL=	'INSERT INTO TempCurStkTax (PrdId,PrdBatId,Saleable,UnSaleable,Offer,Total,PurchaseRate,SalPurRte,UnSalPurRte,OffPurRte,TotPurRte,
				SellingRate,SalSelRte,UnSalSelRte,OffSelRte,TotSelRte,SalUmo1,SalUom2,UnsalUom1,UnSalUom2,OffUom1,OffUom2,SalUom1PurRate,
				SalUom2PurRate,UnSalUom1PurRate,UnSalUom2PurRate,OffUom1PurRate,OffUom2PurRate,SalUom1SelRate,SalUom2SelRate,UnSalUom1SelRate,
				UnSalUom2SelRate,OffUom1SelRate,OffUom2SelRate) 
				SELECT PrdId,PrdBatId,Saleable,UnSaleable,Offer,Total,PurchaseRate,SalPurRte,UnSalPurRte,OffPurRte,TotPurRte,
				SellingRate,SalSelRte,UnSalSelRte,OffSelRte,TotSelRte,SalUom1,SalUom2,UnSalUom1,UnSalUom2,OffUom1,OffUom2,SalUom1PurRate,
				SalUom2PurRate,UnSalUom1PurRate,UnSalUom2PurRate,OffUom1PurRate,OffUom2PurRate,SalUom1SelRate,SalUom2SelRate,UnSalUom1SelRate,
				UnSalUom2SelRate,OffUom1SelRate,OffUom2SelRate 
				FROM TempCurStk WHERE UserId='+ISNULL(CAST(@Pi_UserId As NVARCHAR(10)),'UserId')+ ISNULL(@Pi_Filter,'')
	PRINT @sSQL
    EXEC (@sSQL)
    
    UPDATE A SET A.SalTotal=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(Saleable),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.UnSalTotal= B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN (SELECT ISNULL(SUM(UnSaleable),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.OffTotal= B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN (SELECT ISNULL(SUM(Offer),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom1SalTotal= B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN (SELECT ISNULL(SUM(SalUmo1),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom2SalTotal= B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN (SELECT ISNULL(SUM(SalUom2),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom1UnSalTotal= B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN (SELECT ISNULL(SUM(UnsalUom1),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom2UnSalTotal= B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN (SELECT ISNULL(SUM(UnSalUom2),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom1OffTotal= B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN (SELECT ISNULL(SUM(OffUom1),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom2OffTotal= B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN (SELECT ISNULL(SUM(OffUom2),0) Amt FROM  TempCurStkTax) B

    
    EXEC Proc_InventoryConsoleTaxCalculation @Pi_SupTax,@Pi_RetTax,1,20,5,@Pi_UserId,1000
    
    UPDATE A SET A.SalTax=B.TaxPercentage FROM  TempCurStkTax A INNER JOIN ProductBatchTaxPercent B On A.PrdId=B.PrdId AND A.PrdBatid=B.PrdBatid --AND B.Usrid=@Pi_UserId AND B.Rptid=1000
    UPDATE A SET A.PurTax=B.TaxPercentage FROM TempCurStkTax A INNER JOIN ProductBatchTaxPercent B On A.PrdId=B.PrdId AND A.PrdBatid=B.PrdBatid --AND B.Usrid=@Pi_UserId AND B.Rptid=1000
    
    UPDATE A SET A.SalPurRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(SalPurRte+(Saleable*PurTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.UnSalPurRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(UnSalPurRte+(UnSaleable*PurTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.OffPurRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(OffPurRte+(Offer*PurTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.SalSelRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(SalSelRte+(Saleable*SalTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.UnSalSelRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(UnSalSelRte+(UnSaleable*SalTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.OffSelRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(OffSelRte+(Offer*SalTax)),0) Amt FROM  TempCurStkTax) B

    UPDATE A SET A.Uom1SalPurRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(SalUom1PurRate+(SalUmo1*PurTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom2SalPurRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(SalUom2PurRate+(SalUom2*PurTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom1UnSalPurRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(UnSalUom1PurRate+(UnsalUom1*PurTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom2UnSalPurRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(UnSalUom2PurRate+(UnSalUom2*PurTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom1OffPurRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(OffUom1PurRate+(OffUom1*PurTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom2OffPurRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(OffUom2PurRate+(OffUom2*PurTax)),0) Amt FROM  TempCurStkTax) B

    UPDATE A SET A.Uom1SalSelRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(SalUom1SelRate+(SalUmo1*SalTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom2SalSelRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(SalUom2SelRate+(SalUom2*SalTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom1UnSalSelRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(UnSalUom1SelRate+(UnsalUom1*SalTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom2UnSalSelRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(UnSalUom2SelRate+(UnSalUom2*SalTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom1OffSelRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(OffUom1SelRate+(OffUom1*SalTax)),0) Amt FROM  TempCurStkTax) B
    UPDATE A SET A.Uom2OffSelRte=B.Amt  FROM TempInventoryConsoleTax A CROSS JOIN(SELECT ISNULL(SUM(OffUom2SelRate+(OffUom2*SalTax)),0) Amt FROM  TempCurStkTax) B

    --select * from ProductBatchTaxPercent
    --select * from TempCurStk
    --select * from TempCurStkTax
    --SELECT * FROM TempInventoryConsoleTax
    --SELECT * FROM ProductBatchTaxPercent
    --delete from ProductBatchTaxPercent

END
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE NAME='Proc_TaxCalCulation' AND XTYPE='P')
DROP PROCEDURE Proc_TaxCalCulation
GO
--Exec Proc_TaxCalCulation 528,1654
CREATE PROCEDURE Proc_TaxCalCulation
(
	@Prdid AS INT,
	@Prdbatid AS INT
	
)
AS
BEGIN
		DECLARE @TaxSettingDet TABLE       
		(      
			TaxSlab   INT,      
			ColNo   INT,      
			SlNo   INT,      
			BillSeqId  INT,      
			TaxSeqId  INT,      
			ColType   INT,       
			ColId   INT,      
			ColVal   NUMERIC(38,2)      
		) 
		
		DECLARE @PrdBatTaxGrp AS INT
		DECLARE @PurSeqId AS INT
		DECLARE @BillSeqId AS INT
		DECLARE @RtrTaxGrp AS INT		 
		DECLARE @TaxSlab  INT  
		DECLARE @MRP INT    
		DECLARE @TaxableAmount  NUMERIC(28,10)      
		DECLARE @ParTaxableAmount NUMERIC(28,10)      
		DECLARE @TaxPer   NUMERIC(38,2)     
		DECLARE @TaxPercentage   NUMERIC(38,5)   
		DECLARE @TaxId   INT    
		--To Take the Batch TaxGroup Id      
		SELECT @PrdBatTaxGrp = TaxGroupId FROM ProductBatch A (NOLOCK) WHERE Prdid=@Prdid and  Prdbatid=@Prdbatid
		SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster (NOLOCK)
		SELECT @RtrTaxGrp=MAX(DISTINCT RtrId) FROM TaxSettingMaster (NOLOCK)
		INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)      
		SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal      
		FROM TaxSettingMaster A (NOLOCK) INNER JOIN      
		TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
		AND B.BillSeqId=@BillSeqId  and Coltype IN(1,3)    
		WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp     
		AND A.TaxSeqId in (SELECT ISNULL(MAX(TaxSeqId),0) FROM TaxSettingMaster WHERE      
		RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp)  
	
		SET @MRP=1
		TRUNCATE TABLE TempProductTax
		DECLARE  CurTax CURSOR FOR      
			SELECT DISTINCT TaxSlab FROM @TaxSettingDet      
		OPEN CurTax        
		FETCH NEXT FROM CurTax INTO @TaxSlab      
		WHILE @@FETCH_STATUS = 0        
		BEGIN      
		SET @TaxableAmount = 0      
		--To Filter the Records Which Has Tax Percentage (>=0)      
		IF EXISTS (SELECT * FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId = 0 and ColVal >= 0)      
		BEGIN      
		--To Get the Tax Percentage for the selected slab      
		SELECT @TaxPer = ColVal FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId = 0      
		--To Get the TaxId for the selected slab      
		SELECT @TaxId = Cast(ColVal as INT) FROM @TaxSettingDet WHERE TaxSlab = @TaxSlab AND ColType = 1      
		AND ColId > 0      
		SET @TaxableAmount = ISNULL(@TaxableAmount,0) + @MRP 
		--To Get the Parent Taxable Amount for the Tax Slab      
		SELECT @ParTaxableAmount =  ISNULL(SUM(TaxAmount),0) FROM TempProductTax A      
		INNER JOIN @TaxSettingDet B ON A.TaxId = B.ColVal and  
		B.ColType = 3 AND B.TaxSlab = @TaxSlab 
		If @ParTaxableAmount>0
		BEGIN
			Set @TaxableAmount=@ParTaxableAmount
		END 
		ELSE
		BEGIN
			Set @TaxableAmount = @TaxableAmount
		END    
 
		INSERT INTO TempProductTax (PrdId,PrdBatId,TaxId,TaxSlabId,TaxPercentage,      
		TaxAmount)      
		SELECT @Prdid,@Prdbatid,@TaxId,@TaxSlab,@TaxPer,      
		cast(@TaxableAmount*(@TaxPer / 100 ) AS NUMERIC(28,10))      
		 
		  
		END      
		FETCH NEXT FROM CurTax INTO @TaxSlab      
		END        
		CLOSE CurTax        
		DEALLOCATE CurTax      
		SELECT @TaxPercentage=Cast(ISNULL(SUM(TaxAmount)*100,0) as Numeric(18,5))
		FROM TempProductTax WHERE Prdid=@Prdid and Prdbatid=@Prdbatid
		PRINT @TaxPercentage
		IF EXISTS(SELECT * FROM ProductBatchTaxPercent WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
		BEGIN			
			UPDATE ProductBatchTaxPercent  SET TaxPercentage=@TaxPercentage
			WHERE Prdid=@Prdid and Prdbatid=@Prdbatid
		END	
		ELSE
		BEGIN			
			INSERT INTO ProductBatchTaxPercent(Prdid,Prdbatid,TaxPercentage)
			SELECT @Prdid,@Prdbatid,@TaxPercentage
		END
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_UpdateStockLedger' AND TYPE='P')
DROP PROCEDURE Proc_UpdateStockLedger
GO
/*
BEGIN TRAN
EXEC Proc_UpdateStockLedger 7,1,5078,35664,1,'2015-03-27',1,1,0
ROLLBACK TRAN
*/
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
						UPDATE ConsolidateStockLedger SET StockValue=  @CurVal + (SELECT DISTINCT StockValue FROM
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
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.2',422
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE FixId = 422)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(422,'D','2015-03-20',GETDATE(),1,'Core Stocky Service Pack 422')