--[Stocky HotFix Version]=426
DELETE FROM Versioncontrol WHERE Hotfixid='426'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('426','3.1.0.3','D','2015-09-09','2015-09-09','2015-09-09',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
/*
    CR RELEASE DETAILS :    
	1. Scheme Changes
*/
IF NOT EXISTS (SELECT B.NAME FROM SYSOBJECTS A INNER JOIN SYSCOLUMNS B ON A.id=B.id AND A.name='Cn2Cs_Prk_SpecialDiscount' AND B.name='Type')
BEGIN
	ALTER TABLE Cn2Cs_Prk_SpecialDiscount ADD [Type] VARCHAR(50) DEFAULT '' WITH VALUES
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='U' AND NAME='TempSpecialRateDiscountProduct')
DROP TABLE TempSpecialRateDiscountProduct
GO
CREATE TABLE [dbo].[TempSpecialRateDiscountProduct](
	[SlNo] [bigint] IDENTITY(1,1) NOT NULL,
	[CtgLevelName] [nvarchar](100) NULL,
	[CtgCode] [nvarchar](100) NULL,
	[RtrCode] [nvarchar](100) NULL,
	[PrdCCode] [nvarchar](100) NULL,
	[PrdBatCode] [nvarchar](100) NULL,
	[DiscPer] [numeric](18, 2) NULL,
	[SpecialSellingRate] [numeric](38, 6) NULL,
	[EffectiveFromDate] [datetime] NULL,
	[EffectiveToDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[ApplyOn] [tinyint] NULL,
	[Type] INT
)
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_CalculateSpecialDiscountAftRate')
DROP PROCEDURE Proc_CalculateSpecialDiscountAftRate
GO
--EXEC Proc_CalculateSpecialDiscountAftRate
CREATE PROCEDURE [dbo].[Proc_CalculateSpecialDiscountAftRate]
AS  
BEGIN
     --Added by SAthishkumar Veeramani 2015/04/01
	 DECLARE @SplDiscountToAvoid TABLE
	 (
	   RetCategoryLevel       NVARCHAR(100),
	   RetCatLevelValue       NVARCHAR(100),
	   PrdCategoryLevel       NVARCHAR(100),
	   PrdCategoryLevelValue  NVARCHAR(100)
	 )    
     INSERT INTO @SplDiscountToAvoid (RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue)
     SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE (ApplyOn = '' OR ApplyOn IS NULL)
     
     INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	 SELECT DISTINCT 1,'Cn2Cs_Prk_SpecialDiscount','Apply On','Apply On Should Not be Empty or Null-'+PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE (ApplyOn = '' OR ApplyOn IS NULL)
     
     INSERT INTO @SplDiscountToAvoid (RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue)
     SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) NOT IN ('MRP','SELLINGRATE','PURCHASERATE')
     
     INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	 SELECT DISTINCT 1,'Cn2Cs_Prk_SpecialDiscount','Apply On','Apply On Should Not be in MRP Or SELLINGRATE Or PURCHASERATE-'+PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) NOT IN ('MRP','SELLINGRATE','PURCHASERATE')
     --Till Here
	 INSERT INTO @SplDiscountToAvoid (RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue)
     SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) IN ('MRP') AND ISNULL([Type],'')=''
     
     INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	 SELECT DISTINCT 1,'Cn2Cs_Prk_SpecialDiscount','Type','Type Should Not be Empty For Appy On MRP-'+PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) IN ('MRP') AND ISNULL([Type],'')=''
     
     INSERT INTO @SplDiscountToAvoid (RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue)
     SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) IN ('MRP') AND 
     UPPER(LTRIM(RTRIM(ISNULL([Type],'')))) NOT IN ('MARK DOWN','MARK UP')
     
     INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	 SELECT DISTINCT 1,'Cn2Cs_Prk_SpecialDiscount','Type','Type Should be Mark Up/Mark Down For Appy On MRP-'+PrdCategoryLevelValue 
     FROM Cn2Cs_Prk_SpecialDiscount (NOLOCK) WHERE UPPER(LTRIM(RTRIM(ApplyOn))) IN ('MRP') AND 
     UPPER(LTRIM(RTRIM(ISNULL([Type],'')))) NOT IN ('MARK DOWN','MARK UP')
     
     
	 EXEC Proc_GR_Build_PH  
	 TRUNCATE TABLE TempSpecialRateDiscountProduct
	 DELETE FROM Cn2Cs_Prk_SpecialDiscount where DownLoadFlag='Y'   
	 INSERT INTO TempSpecialRateDiscountProduct (CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,DiscPer,SpecialSellingRate,EffectiveFromDate,
     EffectiveToDate,CreatedDate,ApplyOn,[Type])
	 SELECT DISTINCT A.RetCategoryLevel,A.RetCatLevelValue,'ALL',ProductCode,PrdBatCode,DiscPer,
	 --PrdBatDetailValue-(PrdBatDetailValue*(DiscPer/100)) SplRate,
	 (CASE ApplyOn WHEN 1 THEN 
		 (CASE [Type] WHEN 1 THEN (PrdBatDetailValue*100/(100+DiscPer)) WHEN 2 THEN PrdBatDetailValue-(PrdBatDetailValue*(DiscPer/100))
			ELSE PrdBatDetailValue-(PrdBatDetailValue*(DiscPer/100))  END)	 
	 ELSE PrdBatDetailValue-(PrdBatDetailValue*(DiscPer/100)) END) AS SplRate,	 
	 EffFromDate,EffToDate,CreatedDate,ApplyOn,[Type]	 
	 FROM (  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type]
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.COMPANY_Code  
	 WHERE CP.PrdCategoryLevel='COMPANY' and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue) 
	 UNION   
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type] 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.Category_Code  
	 WHERE CP.PrdCategoryLevel='Category'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue) 
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type]
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.Brand_Code  
	 WHERE CP.PrdCategoryLevel='Brand'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue) 
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type] 
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.PriceSlot_Code  
	 WHERE CP.PrdCategoryLevel='PriceSlot'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue)  
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn ,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type]
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.Flavor_Code  
	 WHERE CP.PrdCategoryLevel='Flavor'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue)
	 UNION  
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type]
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.ProductCode  
	 WHERE CP.PrdCategoryLevel='Product'and CP.DownloadFlag='D' AND NOT EXISTS 
	 (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue FROM @SplDiscountToAvoid SA 
	 WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue AND CP.PrdCategoryLevel = SA.PrdCategoryLevel
	 AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue)
	 UNION
	 SELECT CP.PrdCategoryLevel,CP.PrdCategoryLevelValue,CP.RetCatLevelValue,CP.RetCategoryLevel,Prdid,T.ProductCode,DiscPer,EffFromDate,
	 EffToDate,CreatedDate,(CASE UPPER(LTRIM(RTRIM(CP.ApplyOn))) WHEN 'SELLINGRATE' THEN 3 WHEN 'PURCHASERATE' THEN 2 ELSE 1 END) AS ApplyOn,
	 CASE UPPER(LTRIM(RTRIM([Type]))) WHEN 'MARK UP' THEN 1 WHEN 'MARK DOWN' THEN 2 ELSE 0 END AS [Type]
	 FROM Cn2Cs_Prk_SpecialDiscount CP INNER JOIN TBL_GR_BUILD_PH T on CP.PrdCategoryLevelValue=T.ProductCode  
	 WHERE CP.DownloadFlag='D' AND NOT EXISTS (SELECT DISTINCT RetCategoryLevel,RetCatLevelValue,PrdCategoryLevel,PrdCategoryLevelValue 
	 FROM @SplDiscountToAvoid SA WHERE CP.RetCategoryLevel = SA.RetCategoryLevel AND CP.RetCatLevelValue = SA.RetCatLevelValue 
	 AND CP.PrdCategoryLevel = SA.PrdCategoryLevel AND CP.PrdCategoryLevelValue = SA.PrdCategoryLevelValue))A  
	 INNER JOIN Product P (NOLOCK) ON P.PrdId=A.PrdId and A.ProductCode=P.PrdCCode  
	 INNER JOIN ProductBatch PB (NOLOCK) ON PB.PrdId=P.PrdId  
	 INNER JOIN ProductBatchDetails PBD (NOLOCK) ON PBD.PrdBatId=PB.PrdBatId  
	 INNER JOIN BatchCreation BC (NOLOCK) ON BC.SlNo=PBD.SLNo AND BC.SlNo = A.ApplyOn
	 --INNER JOIN Configuration C (NOLOCK) ON BC.SlNo = ISNULL(CAST(C.ConfigValue AS INT),0)
	 WHERE PBD.DefaultPrice=1 --AND C.ModuleId = 'SPLDISC'
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_SellingTaxCalCulation')
DROP PROCEDURE Proc_SellingTaxCalCulation
GO
--Exec Proc_SellingTaxCalCulation 2556,19944
CREATE PROCEDURE [dbo].[Proc_SellingTaxCalCulation]
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
		Select @RtrTaxGrp=max(Distinct RtriD) FROM TaxSettingMaster (NOLOCK)
		INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)      
		SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal      
		FROM TaxSettingMaster A (NOLOCK) INNER JOIN      
		TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
		AND B.BillSeqId=@BillSeqId  and Coltype IN(1,3)    
		WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp     
		AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE      
		RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp)  
	
	--select * from @TaxSettingDet
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
		--PRINT @ParTaxableAmount
		--PRINT @TaxableAmount      
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
		--PRINT @TaxPercentage
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cn2Cs_SpecialDiscount')
DROP PROCEDURE Proc_Cn2Cs_SpecialDiscount
GO
--EXEC Proc_Cn2Cs_SpecialDiscount 0
CREATE PROCEDURE [dbo].[Proc_Cn2Cs_SpecialDiscount]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_SpecialDiscount
* PURPOSE		: To insert SpecialRateDetails in Productbatchdetails table
* CREATED		:  Muthukrishnan.G.P
* CREATED DATE	:  31-12-2012
* MODIFIED      :   
* DATE AUTHOR   : DESCRIPTION
------------------------------------------------
* {date}		{developer}		{brief modification description}
* 2013-03-01	Vijendra Kumar	CR(PM)-CCRSTPVM0001
*********************************/
SET NOCOUNT ON
BEGIN
	
	DECLARE @RtrHierLevelCode 		AS  NVARCHAR(100)
	DECLARE @RtrHierLevelValueCode 	AS  NVARCHAR(100)
	DECLARE @RtrCode				AS 	NVARCHAR(100)
	
	DECLARE @PrdCCode				AS 	NVARCHAR(100)
	DECLARE @PrdBatCode				AS 	NVARCHAR(100)
	DECLARE @PrdBatCodeAll			AS 	NVARCHAR(100)
	DECLARE @PriceCode				AS 	NVARCHAR(4000)
	DECLARE @Disperc                AS 	NUMERIC(38,6)
	DECLARE @SplRate				AS 	NUMERIC(38,6)
	DECLARE @PrdCtgValMainId		AS	INT
	DECLARE @CtgLevelId				AS 	INT
	DECLARE @CtgMainId				AS 	INT
	DECLARE @RtrId 					AS 	INT
	DECLARE @PrdId 					AS 	INT
	DECLARE @PrdBatId				AS 	INT
	DECLARE @PriceId				AS 	INT
	DECLARE @ContractReq			AS 	INT
	DECLARE @SRReCalc				AS 	INT
	DECLARE @ReCalculatedSR			AS 	NUMERIC(38,6)
	DECLARE @EffFromDate			AS 	DATETIME
	DECLARE @EffToDate				AS 	DATETIME
	DECLARE @CreatedDate			AS 	DATETIME
	
	DECLARE @MulTaxGrp				AS 	INT
	DECLARE @TaxGroupId				AS	INT
	DECLARE @MulRtrId				AS	INT
	DECLARE @MulTaxGroupId			AS 	INT
	DECLARE @DownldSplRate			AS 	NUMERIC(38,6)
	DECLARE @ContHistExist			AS	INT
	DECLARE @ContractPriceIds		AS	NVARCHAR(1000)
	DECLARE @RefPriceId				AS	INT
	DECLARE @CmpId					AS	INT
	DECLARE @CmpPrdCtgId			AS	INT
	DECLARE @RefRtrId				AS	INT
	DECLARE @ErrStatus				AS	INT
	DECLARE @RtrTaxGrp AS INT
	SET @Po_ErrNo=0
	SET @ErrStatus=0
	SET @RtrTaxGrp=0
	
	EXEC Proc_CalculateSpecialDiscountAftRate
	
    SET @ContractReq=1
	SET @SRReCalc=2
	
    TRUNCATE TABLE ETL_Prk_BLContractPricing	
	CREATE TABLE #SpecialRateToAvoid
	(
		Slno				BIGINT,
		RtrHierLevel		NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		RtrHierValue		NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		RtrCode				NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		PrdCCode			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		PrdBatCode			NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		EffectiveFromDate	DATETIME
	)
	
		
		SELECT DISTINCT CtgCode INTO #RetailerCategory FROM RetailerCategory RC 
		INNER JOIN RetailerValueClass RVC ON  RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerValueClassMap RCM ON RCM.RtrValueClassId=RVC.RtrClassId
		
		---Retailer Class Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT T.SlNo,CtgLevelName,T.CtgCode,RtrCode,PrdCCode,PrdBatCode,T.EffectiveFromDate
		FROM TempSpecialRateDiscountProduct T
		WHERE NOT EXISTS(SELECT CtgCode FROM #RetailerCategory R WHERE R.CtgCode=T.CtgCode)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer','Retailer Not Attached to Category:'+RtrHierLevel+' Not Available' FROM #SpecialRateToAvoid
		
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno
		
		--Product Batch Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT 1,RetCategoryLevel,RetCatLevelValue,'ALL',PrdCategoryLevelValue,'ALL',EffFromDate 
		FROM Cn2Cs_Prk_SpecialDiscount A (NOLOCK) WHERE DownLoadFlag = 'D' AND PrdCategoryLevel = 'Product'
		AND NOT EXISTS (SELECT DISTINCT PrdCCode FROM Product B (NOLOCK) 
		INNER JOIN ProductBatch C (NOLOCK) ON B.PrdId = C.PrdId WHERE A.PrdCategoryLevelValue = B.PrdCCode)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product','Product & ProductBatch','Product or Product Batch Not Available-'+PrdCategoryLevelValue
		FROM Cn2Cs_Prk_SpecialDiscount A (NOLOCK) WHERE DownLoadFlag = 'D' AND PrdCategoryLevel = 'Product'
		AND NOT EXISTS (SELECT DISTINCT PrdCCode FROM Product B (NOLOCK) 
		INNER JOIN ProductBatch C (NOLOCK) ON B.PrdId = C.PrdId WHERE A.PrdCategoryLevelValue = B.PrdCCode)
		--Till Here		
		---Retailer Category Level Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT SlNo,CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate
		FROM TempSpecialRateDiscountProduct
		WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer Category Level','Retailer Category Level:'+CtgLevelName+' Not Available' FROM TempSpecialRateDiscountProduct
		WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel)
		
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno
		----
		---Retailer Category Code Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT SlNo,CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate
		FROM TempSpecialRateDiscountProduct
		WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer Category Level Value','Retailer Category Level Value:'+CtgCode+' Not Available' FROM TempSpecialRateDiscountProduct
		WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory)
		
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno
		---
		--Eeffective From Date Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT SlNo,CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate
		FROM TempSpecialRateDiscountProduct
		WHERE EffectiveFromDate>GETDATE()
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Effective From Date','Effective Date :'+CAST(EffectiveFromDate AS NVARCHAR(12))+' is greater ' 
		FROM TempSpecialRateDiscountProduct
		WHERE EffectiveFromDate>GETDATE()
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno
		-- 
		IF NOT EXISTS(SELECT * FROM TempSpecialRateDiscountProduct)
		BEGIN
			RETURN
		END
		
		SELECT @CmpId=ISNULL(CmpId,0) FROM Company C WHERE DefaultCompany=1
		Select @RtrTaxGrp=MIN(Distinct RtriD) FROM TaxSettingMaster (NOLOCK)
		
		SELECT DISTINCT ISNULL(Prk.CtgLevelName,'') as RtrHierLevelCode,ISNULL(Prk.CtgCode,'') as RtrHierLevelValueCode,
		RtrCode,ISNULL(Prk.PrdCCode,'') as PrdCCode,ISNULL(Prk.PrdBatCode,'') as PrdBatCodeAll,
		ISNULL(DiscPer,0) as Disperc,ISNULL(SpecialSellingRate,0) as SplRate,
		ISNULL(Prk.EffectiveFromDate,GETDATE()) as EffFromDate,ISNULL(Prk.EffectiveToDate,'2013-12-31') as EffToDate,
		ISNULL(CreatedDate,GETDATE()) as CreatedDate,ISNULL(P.PrdId,0) AS PrdId,
		ISNULL(RCL.CtgLevelId,0) AS CtgLevelId,ISNULL(RC.CtgMainId,0) AS CtgMainId,
		Prdbatid,PCV.PrdCtgValMainId,CmpPrdCtgId,ISNULL(Prk.ApplyOn,0) AS ApplyOn,ISNULL(Prk.[Type],0) AS [Type]
		INTO #SplPriceDetails
		FROM TempSpecialRateDiscountProduct Prk 
		INNER JOIN Product P ON Prk.PrdCCode=P.PrdCCode 
		INNER JOIN Productbatch PB ON PB.prdid=P.Prdid and PB.PrdBatCode=Prk.PrdBatCode
		INNER JOIN ProductCategoryValue PCV ON P.PrdCtgValMainId=PCV.PrdCtgValMainId
		INNER JOIN RetailerCategoryLevel RCL ON Prk.CtgLevelName=RCL.CtgLevelName 
		INNER JOIN RetailerCategory RC ON Prk.CtgCode=RC.CtgCode	
		WHERE  Prk.EffectiveFromDate<=GETDATE()	
	
		---Tax Calculation
		DECLARE @PrdIdTax as BIGINT
		DECLARE @PrdbatIdTax AS BIGINT
		DECLARE Cur_Tax CURSOR
		FOR 
		SELECT DISTINCT PrdId,PrdbatId FROM #SplPriceDetails		
		OPEN Cur_Tax	
		FETCH NEXT FROM Cur_Tax INTO @PrdIdTax,@PrdbatIdTax
		WHILE @@FETCH_STATUS=0
		BEGIN	
				EXEC Proc_SellingTaxCalCulation @PrdIdTax,@PrdbatIdTax
		FETCH NEXT FROM Cur_Tax INTO @PrdIdTax,@PrdbatIdTax		
		END		
		CLOSE Cur_Tax
		DEALLOCATE Cur_Tax	
	
		DECLARE @MaxPriceId as BIGINT
		SELECT @MaxPriceId=ISNULL(MAX(PriceId),0) from ProductBatchDetails
	
		--SELECT A.*,CAST(SplRate*100/(100+TaxPercentage) AS NUMERIC(38,6)) AS NewSellRate
		
		SELECT A.*,CASE A.ApplyOn WHEN 1 THEN 
											(CASE [Type] WHEN 1 THEN (SplRate*100)/(100+TaxPercentage)
											 WHEN 2 THEN (SplRate*100)/(100+TaxPercentage)	END)
		ELSE CAST(SplRate*100/(100+TaxPercentage) AS NUMERIC(38,6)) END AS NewSellRate
		,@MaxPriceId+ROW_NUMBER() OVER(Order by A.PrdId,A.PrdBatId,CtgLevelId,CtgMainId,PrdCtgValMainId,CmpPrdCtgId)
		as NewPriceId
		INTO #PriceMaster
		FROM #SplPriceDetails A INNER JOIN ProductBatchTaxPercent B ON A.PrdId=B.PrdId
		AND A.PrdBatId=b.PrdBatId
		  
		--SELECT A.*,CASE A.ApplyOn WHEN 1 THEN 
		--									(CASE [Type] WHEN 1 THEN SplRate-(SplRate*(TaxPercentage/100))
		--									 WHEN 2 THEN SplRate-(SplRate*(TaxPercentage/100))	END)
		--ELSE CAST(SplRate*100/(100+TaxPercentage) AS NUMERIC(38,6)) END AS NewSellRate
		--,@MaxPriceId+ROW_NUMBER() OVER(Order by A.PrdId,A.PrdBatId,CtgLevelId,CtgMainId,PrdCtgValMainId,CmpPrdCtgId)
		--as NewPriceId
		--INTO #PriceMaster
		--FROM #SplPriceDetails A INNER JOIN ProductBatchTaxPercent B ON A.PrdId=B.PrdId
		--AND A.PrdBatId=b.PrdBatId
	
		--SELECT * FROM ProductBatchTaxPercent WHERE PRDID=2556
		
		SELECT PrdbatId,MAX(PriceId) as PriceId 
		INTO #ProductbatchDetails 
		FROM ProductBatchDetails GROUP BY PrdbatId
	
		INSERT INTO ProductBatchDetails(
		PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
		Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload)
		SELECT DISTINCT 
		NewPriceId,A.PrdBatId,PrdBatCode+'-Spl Rate-'+CAST(NewSellRate AS NVARCHAR(100))
						+CAST(GETDATE() AS NVARCHAR(20)) ,
		
		D.BatchSeqId,D.SlNo,
				(CASE BC.SelRte WHEN 1 THEN NewSellRate ELSE D.PrdBatDetailValue END) AS SelRte,
				0,1,1,1,GETDATE(),1,GETDATE(),0 
		FROM #PriceMaster A 
		INNER JOIN #ProductbatchDetails B ON A.PrdBatId=B.PrdBatId
		INNER JOIN ProductBatchDetails D ON D.PrdBatId=A.PrdBatId and D.PrdBatId=B.PrdBatId and D.PriceId=B.PriceId
		INNER JOIN BatchCreation BC ON BC.BatchSeqId=D.BatchSeqId AND D.SlNo=BC.SlNo
		INNER JOIN ProductBatch C ON C.PrdBatId=A.PrdBatId and C.PrdBatId=B.PrdBatId and C.PrdId=A.PRdId
		and D.PrdBatId=C.PrdBatId
		ORder by NewPriceId,A.PrdBatId,D.SlNo
		
		UPDATE Counters SET CurrValue=(SELECT ISNULL(Max(PriceId),0) FROM ProductBatchDetails) WHERE TabName='ProductBatchDetails' AND FldName='PriceId'
		UPDATE A SET EnableCloning=1 FROM ProductBatch A
		INNER JOIN #PriceMaster B ON B.Prdbatid=A.PrdbatId
		
		--Contract Price Praking Table insert
		INSERT INTO Cn2Cs_Prk_ContractPricing(CmpId,CtgLevelId,CtgMainId,RtrClassId,CmpPrdCtgId,PrdCtgValMainId,
		RtrId,PrdId,PrdBatId,PriceId,DiscountPerc,FlatAmount,EffectiveDate,ToDate,CreatedDate,RtrTaxGroupId)
		SELECT DISTINCT @CmpId,CtgLevelId,CtgMainId,0,0,0,CASE WHEN RtrCode='ALL' THEN '0' ELSE ISNULL(RtrCode,'') END,
		Prdid,Prdbatid,NewPriceId,0,0,EffFromDate,EffToDate,CreatedDate,@RtrTaxGrp
		FROM #PriceMaster
		
		---Special Rate Screen Table Insert and Update
		INSERT INTO SpecialRateAftDownLoad(RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode,
		SplSelRate,FromDate,CreatedDate,DownloadedDate,ContractPriceIds,DiscountPerc)		
		SELECT DISTINCT RtrHierLevelCode,RtrHierLevelValueCode,RtrCode,PrdCCode,PrdBatCodeAll,
		NewSellRate,EffFromDate,CreatedDate,GETDATE(),'-'+CAST(NewPriceId AS NVARCHAR(10))+'-',Disperc 
		FROM #PriceMaster A
		WHERE NOT EXISTS(		
			SELECT RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode, FromDate 
			FROM 
			SpecialRateAftDownLoad B WHERE B.RtrCtgCode=A.RtrHierLevelCode
			and B.RtrCtgValueCode=A.RtrHierLevelValueCode and B.RtrCode= A.RtrCode
			And B.PrdCCode=A.PrdCCode and B.PrdBatCCode=A.PrdBatCodeAll
			and FromDate<=EffFromDate and B.SplSelRate=A.SplRate
						)
		
		UPDATE B  SET SplSelRate=NewSellRate,ContractPriceIds='-'+CAST(NewPriceId AS NVARCHAR(10))+'-',DiscountPerc=Disperc
		FROM #PriceMaster A INNER JOIN SpecialRateAftDownLoad B ON 
		B.RtrCtgCode=A.RtrHierLevelCode
		and B.RtrCtgValueCode=A.RtrHierLevelValueCode and B.RtrCode= A.RtrCode
		And B.PrdCCode=A.PrdCCode and B.PrdBatCCode=A.PrdBatCodeAll
		WHERE  FromDate<=EffFromDate
		---
	
	
		EXEC Proc_Validate_ContractPricing @Po_ErrNo=@ErrStatus
		SET @Po_ErrNo=@ErrStatus
	
		--IF @Po_ErrNo=0
		--BEGIN	
			UPDATE A SET A.DownLoadFlag='Y' FROM Cn2Cs_Prk_SpecialDiscount A (NOLOCK) 
			INNER JOIN SpecialRateAftDownload B (NOLOCK) ON A.PrdCategoryLevelValue = B.PrdCCode 
			AND A.RetCategoryLevel = B.RtrCtgCode AND A.RetCatLevelValue = B.RtrCtgValueCode
		--END
		RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ProductSellingRateWithTax' AND XTYPE='U')
DROP TABLE ProductSellingRateWithTax
GO
CREATE TABLE ProductSellingRateWithTax
(
	Prdid		     INT,
	Prdbatid		 INT,	
	TaxPercentage	 NUMERIC(18,5),
	SellRate		 NUMERIC(18,6),
	SellRateWithTax	 NUMERIC(18,6)
)
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_ProductTaxCalCulation' AND XTYPE='P')
DROP PROCEDURE Proc_ProductTaxCalCulation
GO
--Exec Proc_ProductTaxCalCulation 3,768
CREATE PROCEDURE Proc_ProductTaxCalCulation
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
		Select @RtrTaxGrp=MAX(DISTINCT RtriD) FROM TaxSettingMaster (NOLOCK)
		INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)      
		SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal      
		FROM TaxSettingMaster A (NOLOCK) INNER JOIN      
		TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
		AND B.BillSeqId=@BillSeqId  and Coltype IN(1,3)    
		WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp     
		AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE      
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

		IF EXISTS(SELECT * FROM ProductSellingRateWithTax WHERE Prdid=@Prdid and Prdbatid=@Prdbatid)
		BEGIN			
			UPDATE ProductSellingRateWithTax  SET TaxPercentage=@TaxPercentage
			WHERE Prdid=@Prdid and Prdbatid=@Prdbatid
		END	
		ELSE
		BEGIN			
			INSERT INTO ProductSellingRateWithTax(Prdid,Prdbatid,TaxPercentage,SellRate,SellRateWithTax)
			SELECT @Prdid,@Prdbatid,@TaxPercentage,0,0
		END
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='CALCULATE_RATEWITHTAX' AND XTYPE='P')
DROP PROCEDURE CALCULATE_RATEWITHTAX
GO
CREATE PROCEDURE CALCULATE_RATEWITHTAX
(
	@Pi_UsrId 		INT,
	@Pi_TransId		INT	
)
AS
BEGIN
	DECLARE @Prdid AS INT
	DECLARE @prdbatid AS INT
	DECLARE @SellRate AS NUMERIC(18,6)
	
	DELETE FROM ProductSellingRateWithTax  
	
	DECLARE Cur_CalculateTax CURSOR   
	FOR SELECT DISTINCT PrdId,PrdBatID FROM BilledPrdHdForScheme WHERE Usrid=@Pi_UsrId AND TransId=@Pi_TransId 
	OPEN Cur_CalculateTax   
	FETCH NEXT FROM Cur_CalculateTax INTO @Prdid,@Prdbatid
	WHILE @@FETCH_STATUS = 0          
	BEGIN     
	EXEC Proc_ProductTaxCalCulation @Prdid,@Prdbatid   
	FETCH NEXT FROM Cur_CalculateTax INTO @Prdid,@Prdbatid
	END          
	CLOSE Cur_CalculateTax          
	DEALLOCATE Cur_CalculateTax   

	UPDATE P SET P.SellRate=B.SelRate FROM ProductSellingRateWithTax P INNER JOIN BilledPrdHdForScheme B ON P.Prdid=B.PrdId AND P.Prdbatid=B.PRDBATID
	WHERE Usrid=@Pi_UsrId AND TransId=@Pi_TransId 
	
	UPDATE ProductSellingRateWithTax SET SellRateWithTax = (SellRate+((SellRate*TaxPercentage)/100)) 
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='Proc_ApplySchemeInBill' AND XTYPE='P')
DROP PROCEDURE Proc_ApplySchemeInBill
GO
/*
BEGIN TRANSACTION
EXEC Proc_ApplySchemeInBill 115,12,0,2,2
SELECT * FROM BillAppliedSchemeHd
-- SELECT * FROM BilledPrdHdForScheme(NOLOCK)
ROLLBACK TRANSACTION
*/
CREATE Procedure Proc_ApplySchemeInBill
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
* {date}       {developer}  {brief modification description}
* 08-08-2011   Boopathy.P   Stock validation Removed
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
		PrdId				INT,
		PrdBatId			INT,
		SchemeOnQty 		NUMERIC(38,0),
		SchemeOnAmount		NUMERIC(38,6),
		SchemeOnKG			NUMERIC(38,6),
		SchemeOnLitre		NUMERIC(38,6),
		SchId 				INT,
		SchemeOnAmtWithTax NUMERIC(38,6)
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
	
	IF @SchType=2 
	BEGIN
		EXEC CALCULATE_RATEWITHTAX @Pi_UsrId,@Pi_TransId
	END
		
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
	
	--SELECT 'N3',* FROM BilledPrdHdForScheme
	-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
	
	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId,SchemeOnAmtWithTax)		
	SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,
		ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
		WHEN 3 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnKg,
		ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
		WHEN 5 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnLitre,@Pi_SchId,
		ISNULL(SUM(A.BaseQty * ISNULL(PT.SellRateWithTax,0)),0) AS SchemeOnAmtWithTax
		FROM BilledPrdHdForScheme A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
		A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
		INNER JOIN Product C ON A.PrdId = C.PrdId
		INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
		LEFT OUTER JOIN ProductSellingRateWithTax PT ON PT.PRDID=A.PRDID AND PT.PRDID=B.PRDID 
		AND PT.PRDBATID=A.PRDBATID AND PT.Prdbatid=B.PrdBatId
		WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId
		GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
	
	--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
	INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
	SELECT ISNULL(CASE @SchType
		WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
	-- 	WHEN 1 THEN SUM(CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
	--	WHEN 2 THEN SUM(SchemeOnAmount)
		WHEN 2 THEN SUM(SchemeOnAmtWithTax)
		WHEN 3 THEN (CASE A.UomId
				WHEN 2 THEN SUM(SchemeOnKg) * 1000
				WHEN 3 THEN SUM(SchemeOnKg)
				WHEN 4 THEN SUM(SchemeOnLitre) * 1000
				WHEN 5 THEN SUM(SchemeOnLitre)	END)
			END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
		ISNULL(CASE @SchType
		WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
	-- 	WHEN 1 THEN SUM(CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
	--	WHEN 2 THEN SUM(SchemeOnAmount)
		WHEN 2 THEN SUM(SchemeOnAmtWithTax)
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
	--SELECT 'N1',* FROM @TempBilled
	--SELECT 'N2',* FROM @TempSchSlabAmt
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
	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
	EXEC Proc_ApplyDiscountScheme @Pi_SchId,@Pi_UsrId,@Pi_TransId
	UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
		SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
		TransId = @Pi_TransId AND Usrid = @Pi_UsrId
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='ReturnProductRateWithTax' AND XTYPE='FN')
DROP FUNCTION ReturnProductRateWithTax
GO
--SELECT  DBO.ReturnProductRateWithTax(5756,28475,10) as SellRateWithTax
CREATE FUNCTION ReturnProductRateWithTax(@Prdid AS INT,@Prdbatid AS INT,@Rate AS NUMERIC(18,6))
RETURNS NUMERIC(38,5)
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
		
		DECLARE @TempProductTax TABLE       
		(
			PrdId		int,
			PrdBatId	int,
			TaxId		int,
			TaxSlabId	int,
			TaxPercentage	numeric(18,2),
			TaxAmount	NUMERIC (18,6)
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
		DECLARE @RateWithTax AS NUMERIC(38,5)
		
		--To Take the Batch TaxGroup Id      
		SELECT @PrdBatTaxGrp = TaxGroupId FROM ProductBatch A (NOLOCK) WHERE Prdid=@Prdid and  Prdbatid=@Prdbatid
		SELECT @BillSeqId = MAX(BillSeqId)  FROM BillSequenceMaster (NOLOCK)
		Select @RtrTaxGrp=max(Distinct RtriD) FROM TaxSettingMaster (NOLOCK)
		
		INSERT INTO @TaxSettingDet (TaxSlab,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal)      
		SELECT B.RowId,B.ColNo,B.SlNo,B.BillSeqId,B.TaxSeqId,B.ColType,B.ColId,B.ColVal      
		FROM TaxSettingMaster A (NOLOCK) INNER JOIN      
		TaxSettingDetail B (NOLOCK) ON A.TaxSeqId = B.TaxSeqId      
		AND B.BillSeqId=@BillSeqId  and Coltype IN(1,3)    
		WHERE A.RtrId = @RtrTaxGrp AND A.Prdid = @PrdBatTaxGrp     
		AND A.TaxSeqId in (Select ISNULL(Max(TaxSeqId),0) FROM TaxSettingMaster WHERE      
		RtrId = @RtrTaxGrp AND Prdid = @PrdBatTaxGrp)  
	
	--select * from @TaxSettingDet
		SET @MRP=1

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
     
		INSERT INTO @TempProductTax (PrdId,PrdBatId,TaxId,TaxSlabId,TaxPercentage,TaxAmount)      
		SELECT @Prdid,@Prdbatid,@TaxId,@TaxSlab,@TaxPer,CAST(@TaxableAmount*(@TaxPer / 100 ) AS NUMERIC(28,10))      
		END
		
		FETCH NEXT FROM CurTax INTO @TaxSlab      
		END        
		CLOSE CurTax        
		DEALLOCATE CurTax
		
		SELECT @TaxPercentage=Cast(ISNULL(SUM(TaxAmount)*100,0) as Numeric(18,5))
		FROM @TempProductTax WHERE Prdid=@Prdid and Prdbatid=@Prdbatid
		
		SELECT @RateWithTax=(@Rate*100)/(100+@TaxPercentage)
		
RETURN (@RateWithTax)
END
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.3',426
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE FixId = 426)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(426,'D','2015-09-09',GETDATE(),1,'Core Stocky Service Pack 426')