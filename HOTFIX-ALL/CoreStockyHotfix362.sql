--[Stocky HotFix Version]=362
Delete from Versioncontrol where Hotfixid='362'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('362','2.0.0.5','D','2011-03-16','2011-03-16','2011-03-16',convert(varchar(11),getdate()),'Parle;Major:-Akso Nobel and Henkel CRs;Minor:Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 362' ,'362'
GO

--SRF-Nanda-209-001

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_SpecialRate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_SpecialRate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
-- DELETE FROM ContractPricingDetails WHERE ContractId>28
-- DELETE FROM ContractPricingMaster WHERE ContractId>28
--SELECT * FROM Cn2Cs_Prk_SpecialRate
EXEC Proc_Cn2Cs_SpecialRate 0
--SELECT COUNT(*) FROM ProductBatch --WHERE PrdBatId=21
--SELECT * FROM ProductBatchDetails --WHERE PrdBatId=22 ORDER BY priceid,SlNo
--DELETE FROM ProductBatchDetails WHERE PriceId>51
--SELECT * FROM ETL_Prk_BLContractPricing
--SELECT * FROM ErrorLog
--DELETE FROM ErrorLog
--SELECT * FROM ContractPricingMaster
--SELECT * FROM ContractPricingDetails --WHERE ContractId IN (20,21,22)--PriceId IN (29,30)
--SELECT * FROM SpecialRateAftDownLoad
--DELETE FROM SpecialRateAftDownLoad WHERE PrdCCode='TSRReCalcPrd'
ROLLBACK TRANSACTION
*/

CREATE	PROCEDURE [dbo].[Proc_Cn2Cs_SpecialRate]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_SpecialRate
* PURPOSE		: To Insert and Update Special Rate records in the Table Product Batch Details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 04/05/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
* 21/10/2010	Nanda		 Effective From/To Date changes
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
	SET @Po_ErrNo=0
	SET @ErrStatus=0
	
	SELECT @ContractReq=ISNULL(Status,0) FROM Configuration WHERE ModuleId In ('BL2')
	SELECT @SRReCalc=ISNULL(Status,0) FROM Configuration WHERE ModuleId In ('BL1')
	SET @ContractReq=1
	
	TRUNCATE TABLE ETL_Prk_BLContractPricing	
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SplRateToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE SplRateToAvoid	
	END
	CREATE TABLE SplRateToAvoid
	(
		RtrHierLevel	NVARCHAR(100),
		RtrHierValue	NVARCHAR(100),
		RtrCode			NVARCHAR(100),
		PrdCCode		NVARCHAR(100),
		PrdBatCode		NVARCHAR(100)
	)
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_SpecialRate
	WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product))
	BEGIN
		INSERT INTO SplRateToAvoid(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
		FROM Cn2Cs_Prk_SpecialRate
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','ProductCode','Product Code:'+PrdCCode+' Not Available' FROM Cn2Cs_Prk_SpecialRate
		WHERE PrdCCode NOT IN (SELECT PrdCCode FROM Product)
	END
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_SpecialRate
	WHERE PrdCCode NOT IN (SELECT P.PrdCCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId))
	BEGIN
		INSERT INTO SplRateToAvoid(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
		FROM Cn2Cs_Prk_SpecialRate
		WHERE PrdCCode NOT IN (SELECT P.PrdCCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','ProductCode','Batch is not available for Product Code:'+PrdCCode FROM Cn2Cs_Prk_SpecialRate
		WHERE PrdCCode NOT IN (SELECT P.PrdCCode FROM Product P,ProductBatch PB WHERE P.PrdId=PB.PrdId)
	END
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_SpecialRate
	WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel))
	BEGIN
		INSERT INTO SplRateToAvoid(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
		FROM Cn2Cs_Prk_SpecialRate
		WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer Category Level','Retailer Category Level:'+CtgLevelName+' Not Available' FROM Cn2Cs_Prk_SpecialRate
		WHERE CtgLevelName NOT IN (SELECT CtgLevelName FROM RetailerCategoryLevel)
	END
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_SpecialRate
	WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory))
	BEGIN
		INSERT INTO SplRateToAvoid(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
		FROM Cn2Cs_Prk_SpecialRate
		WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer Category Level Value','Retailer Category Level Value:'+CtgCode+' Not Available' FROM Cn2Cs_Prk_SpecialRate
		WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory)
	END
	IF EXISTS(SELECT * FROM Cn2Cs_Prk_SpecialRate WHERE EffectiveFromDate>GETDATE())
	BEGIN
		INSERT INTO SplRateToAvoid(RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode)
		SELECT DISTINCT CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode
		FROM Cn2Cs_Prk_SpecialRate
		WHERE EffectiveFromDate>GETDATE()
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Effective From Date','Effective Date :'+CAST(EffectiveFromDate AS NVARCHAR(12))+' is greater ' 
		FROM Cn2Cs_Prk_SpecialRate
		WHERE EffectiveFromDate>GETDATE()
	END
	SELECT @CmpId=ISNULL(CmpId,0) FROM Company C WHERE DefaultCompany=1
	DECLARE Cur_SpecialRate CURSOR
	FOR SELECT ISNULL(Prk.CtgLevelName,''),ISNULL(Prk.CtgCode,''),
	ISNULL(Prk.RtrCode,''),ISNULL(Prk.PrdCCode,''),ISNULL(Prk.PrdBatCode,''),ISNULL(SpecialSellingRate,0),
	ISNULL(Prk.EffectiveFromDate,GETDATE()),ISNULL(Prk.EffectiveToDate,'2013-12-31'),ISNULL(CreatedDate,GETDATE()),ISNULL(P.PrdId,0) AS PrdId,
	ISNULL(RCL.CtgLevelId,0) AS CtgLevelId,ISNULL(RC.CtgMainId,0) AS CtgMainId
	FROM Cn2Cs_Prk_SpecialRate Prk 
	INNER JOIN Product P ON Prk.PrdCCode=P.PrdCCode 
	INNER JOIN RetailerCategoryLevel RCL ON Prk.CtgLevelName=RCL.CtgLevelName 
	INNER JOIN RetailerCategory RC ON Prk.CtgCode=RC.CtgCode	
	WHERE Prk.DownloadFlag='D' AND Prk.EffectiveFromDate<=GETDATE() AND Prk.CtgLevelName+'~'+Prk.CtgCode
	+'~'+Prk.RtrCode+'~'+Prk.PrdCCode+'~'+Prk.PrdBatCode
	NOT IN(SELECT RtrHierLevel+'~'+RtrHierValue+'~'+RtrCode+'~'+PrdCCode+'~'+PrdBatCode FROM SplRateToAvoid)
	ORDER BY Prk.CtgLevelName,Prk.CtgCode,Prk.RtrCode,Prk.PrdCCode,
	Prk.PrdBatCode,SpecialSellingRate,EffectiveFromDate,EffectiveToDate,CreatedDate
	OPEN Cur_SpecialRate	
	FETCH NEXT FROM Cur_SpecialRate INTO @RtrHierLevelCode,@RtrHierLevelValueCode,@RtrCode,
	@PrdCCode,@PrdBatCodeAll,@SplRate,@EffFromDate,@EffToDate,@CreatedDate,@PrdId,@CtgLevelId,@CtgMainId
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @ContractPriceIds=''
		SELECT @PrdCtgValMainId=ISNULL(P.PrdCtgValMainId,0)
		FROM Product P,ProductCategoryValue PCV
		WHERE P.PrdCtgValMainId=PCV.PrdCtgValMainId AND P.PrdId=@PrdId
		SELECT @CmpPrdCtgId=ISNULL(PCL.CmpPrdCtgId,0) FROM ProductCategoryLevel PCL,ProductCategoryValue PCV
		WHERE PCL.CmpPrdCtgId=PCV.CmpPrdCtgId AND PCV.PrdCtgValMainId=@PrdCtgValMainId
		IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[BLCmpBatCode]')	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
		BEGIN
			DROP TABLE [BLCmpBatCode]				
		END
		
		CREATE  TABLE [BLCmpBatCode]
		(
			[CmpBatCode] NVARCHAR(100)	
		)
		INSERT INTO BLCmpBatCode
		SELECT CmpBatCode			
		FROM ProductBatch WHERE PrdId=@PrdId AND
		CmpBatCode=(CASE @PrdBatCodeAll WHEN 'All' THEN CmpBatCode ELSE @PrdBatCodeAll END)
		
		DECLARE Cur_Batch CURSOR
		FOR SELECT CmpBatCode FROM BLCmpBatCode
		OPEN Cur_Batch	
		FETCH NEXT FROM Cur_Batch INTO @PrdBatCode
		WHILE @@FETCH_STATUS=0
		BEGIN
			SELECT @PrdBatId=ISNULL(PrdBatId,0) FROM ProductBatch WITH (NOLOCK) WHERE CmpBatCode=@PrdBatCode AND PrdId=@PrdId
			IF @SRReCalc=2
			BEGIN				
				IF (SELECT COUNT(DISTINCT R.TaxGroupId) 
				FROM RetailerValueClass RVC,RetailerValueClassMap RVCM,Retailer R
				WHERE RVC.RtrClassId=RVCM.RtrValueClassId AND R.RtrId=RVCM.RtrId AND R.RtrStatus=1
				AND CtgMainId=@CtgMainId)>1
				BEGIN
					SET @MulTaxGrp=1
				END
				ELSE
				BEGIN
					SET @MulTaxGrp=0
				END	
				
				IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'TempRtrs')
				AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
				BEGIN
					DROP TABLE TempRtrs
				END
				SELECT R.TaxGroupId,COUNT(R.RtrId) NoOfRtrs
				INTO TempRtrs
				FROM RetailerValueClass RVC,RetailerValueClassMap RVCM,Retailer R
				WHERE RVC.RtrClassId=RVCM.RtrValueClassId AND R.RtrId=RVCM.RtrId AND R.RtrStatus=1
				AND CtgMainId=@CtgMainId
				GROUP BY R.TaxGroupId					
								
				SELECT @RtrId=RtrId,@TaxGroupId=R.TaxGroupId FROM Retailer R,TempRtrs TR WHERE R.TaxGroupId=TR.TaxGroupId
				AND TR.NoOfRtrs IN (SELECT MAX(NoOfRtrs) FROM TempRtrs)
				SET @DownldSplRate=@SplRate
				IF @SRReCalc=2
				BEGIN
					EXEC Proc_SellingRateReCalculation @RtrId,@PrdBatId,@SplRate,@Pi_SellingRate=@ReCalculatedSR OUTPUT
					IF @ReCalculatedSR<>0
					BEGIN
						SET @SplRate=@ReCalculatedSR						
					END
				END
			
				IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'TempRtrs')
				AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
				BEGIN
					DROP TABLE TempRtrs
				END
			END
			ELSE
			BEGIN
				SET @DownldSplRate=@SplRate
			END	
			SET @RefPriceId=0
			SELECT @RefPriceId=ISNULL(PriceId,0) FROM ProductBatchDetails WHERE PrdBatId=@PrdBatId AND SlNo=1 AND DefaultPrice=1
			
			IF @RefPriceId=0
			BEGIN
				SELECT @RefPriceId=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails WHERE PrdBatId=@PrdBatId 
			END
			SET @PriceCode=@PrdBatCode+'-Spl Rate-'+CAST(@SplRate AS NVARCHAR(100))+CAST(GETDATE() AS NVARCHAR(20)) 
			SELECT @PriceId=dbo.Fn_GetPrimaryKeyInteger('ProductBatchDetails','PriceId',
			CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			IF NOT @PriceId>(SELECT ISNULL(MAX(PriceId),0) AS PriceId FROM ProductBatchDetails(NOLOCK))
			BEGIN			
				CLOSE Cur_Batch
				DEALLOCATE Cur_Batch
				
				CLOSE Cur_SpecialRate
				DEALLOCATE Cur_SpecialRate
				INSERT INTO Errorlog VALUES (1,'Special Rate','System Date',
				'System is showing Date as :'+CAST(GETDATE() AS NVARCHAR(11))+'. Please change the System Date')
				SET @Po_ErrNo=1
				RETURN
			END
			INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
			DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			SELECT @PriceId,@PrdBatId,@PriceCode,PBD.BatchSeqId,PBD.SlNo,
			(CASE BC.SelRte WHEN 1 THEN @SplRate ELSE PBD.PrdBatDetailValue END) AS SelRte,
			0,1,1,1,GETDATE(),1,GETDATE()	
			FROM ProductBatchDetails PBD,BatchCreation BC
			WHERE PBD.PrdBatId=@PrdBatId AND PBD.BatchSeqId=BC.BatchSeqId AND PBD.SlNo=BC.SlNo
			AND PriceId=@RefPriceId
			UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ProductBatchDetails' AND FldName='PriceId'
			UPDATE ProductBatch SET EnableCloning=1 WHERE PrdBatId=@PrdBatId
			
			IF @ContractPriceIds=''
			BEGIN
				SET @ContractPriceIds='-'+CAST(@PriceId AS NVARCHAR(10))+'-'
			END
			ELSE
			BEGIN
				SET @ContractPriceIds=@ContractPriceIds+',-'+CAST(@PriceId AS NVARCHAR(10))+'-'
			END				
			IF @ContractReq=1
			BEGIN						
				SELECT @RefRtrId=ISNULL(RtrId,0) FROM Retailer WHERE CmpRtrCode=@RtrCode
				IF @RtrCode='ALL'
				BEGIN
					SET @RefRtrId=0
				END
				INSERT INTO Cn2Cs_Prk_ContractPricing(CmpId,CtgLevelId,CtgMainId,RtrClassId,CmpPrdCtgId,PrdCtgValMainId,
				RtrId,PrdId,PrdBatId,PriceId,DiscountPerc,FlatAmount,EffectiveDate,ToDate,CreatedDate,RtrTaxGroupId)
				VALUES(@CmpId,@CtgLevelId,@CtgMainId,0,0,0,@RefRtrId,
				@PrdId,@PrdBatId,@PriceId,0,0,@EffFromDate,@EffToDate,@CreatedDate,CASE @SRReCalc WHEN 2 THEN @TaxGroupId ELSE 0 END)
			END
			IF @SRReCalc=2
			BEGIN
				IF @MulTaxGrp=1 AND @SRReCalc=2
				BEGIN
					DECLARE Cur_MulTaxGroup CURSOR
					FOR SELECT DISTINCT R.TaxGroupId
					FROM Retailer R,RetailerValueClass RVC,RetailerValueClassMap RVCM
					WHERE RVC.RtrClassId=RVCM.RtrValueClassId AND R.RtrId=RVCM.RtrId AND R.RtrStatus=1
					AND RVC.CtgMainId=@CtgMainId AND R.TaxGroupId<>@TaxGroupId
					OPEN Cur_MulTaxGroup	
					FETCH NEXT FROM Cur_MulTaxGroup INTO @MulTaxGroupId
					WHILE @@FETCH_STATUS=0
					BEGIN						
						SELECT @MulRtrId=MAX(R.RtrId)
						FROM Retailer R,RetailerValueClass RVC,RetailerValueClassMap RVCM
						WHERE RVC.RtrClassId=RVCM.RtrValueClassId AND R.RtrId=RVCM.RtrId AND R.RtrStatus=1
						AND RVC.CtgMainId=@CtgMainId AND R.TaxGroupId=@MulTaxGroupId
			
						SET @ReCalculatedSR=0
						EXEC Proc_SellingRateReCalculation @MulRtrId,@PrdBatId,@DownldSplRate,@Pi_SellingRate=@ReCalculatedSR OUTPUT
						IF @ReCalculatedSR<>0
						BEGIN
							SET @SplRate=@ReCalculatedSR
						END
		
						SET @RefPriceId=0
						SELECT @RefPriceId=ISNULL(PriceId,0) FROM ProductBatchDetails WHERE PrdBatId=@PrdBatId AND SlNo=1 AND DefaultPrice=1
						
						IF @RefPriceId=0
						BEGIN
							SELECT @RefPriceId=ISNULL(MAX(PriceId),0) FROM ProductBatchDetails WHERE PrdBatId=@PrdBatId 
						END
						SET @PriceCode=@PrdBatCode+'-Spl Rate-'+CAST(@SplRate AS NVARCHAR(100))
						+CAST(GETDATE() AS NVARCHAR(20)) 
			
						SELECT @PriceId=dbo.Fn_GetPrimaryKeyInteger('ProductBatchDetails','PriceId',
						CAST(YEAR(GetDate()) AS INT),MONTH(GETDATE()))
			
						IF NOT @PriceId>(SELECT ISNULL(MAX(PriceId),0) AS PriceId FROM ProductBatchDetails(NOLOCK))
						BEGIN
							CLOSE Cur_MulTaxGroup
							DEALLOCATE Cur_MulTaxGroup
							CLOSE Cur_Batch
							DEALLOCATE Cur_Batch
							
							CLOSE Cur_SpecialRate
							DEALLOCATE Cur_SpecialRate
							INSERT INTO Errorlog VALUES (1,'Special Rate','System Date',
							'System is showing Date as :'+CAST(GETDATE() AS NVARCHAR(11))+'. Please change the System Date')
							SET @Po_ErrNo=1
							RETURN
						END
						INSERT INTO ProductBatchDetails(PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,
						DefaultPrice,PriceStatus,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						SELECT @PriceId,@PrdBatId,@PriceCode,PBD.BatchSeqId,PBD.SlNo,
						(CASE BC.SelRte WHEN 1 THEN @SplRate ELSE PBD.PrdBatDetailValue END) AS SelRte,0,1,1,1,GETDATE(),1,GETDATE()	
						FROM ProductBatchDetails PBD,BatchCreation BC
						WHERE PBD.PrdBatId=@PrdBatId AND PBD.BatchSeqId=BC.BatchSeqId AND PBD.SlNo=BC.SlNo AND PriceId=@RefPriceId
			
						UPDATE Counters SET CurrValue=@PriceId WHERE TabName='ProductBatchDetails' AND FldName='PriceId'			
						UPDATE ProductBatch SET EnableCloning=1 WHERE PrdBatId=@PrdBatId
						
						IF @ContractPriceIds=''
						BEGIN
							SET @ContractPriceIds='-'+CAST(@PriceId AS NVARCHAR(10))+'-'
						END
						ELSE
						BEGIN
							SET @ContractPriceIds=@ContractPriceIds+',-'+CAST(@PriceId AS NVARCHAR(10))+'-'
						END
	
						IF @ContractReq=1
						BEGIN
							INSERT INTO Cn2Cs_Prk_ContractPricing(CmpId,CtgLevelId,CtgMainId,RtrClassId,CmpPrdCtgId,PrdCtgValMainId,
							RtrId,PrdId,PrdBatId,PriceId,DiscountPerc,FlatAmount,EffectiveDate,ToDate,CreatedDate,RtrTaxGroupId)
							VALUES(@CmpId,@CtgLevelId,@CtgMainId,0,0,0,0,
							@PrdId,@PrdBatId,@PriceId,0,0,@EffFromDate,@EffToDate,@CreatedDate,@MulTaxGroupId)
						END
						FETCH NEXT FROM Cur_MulTaxGroup INTO @MulTaxGroupId
					END
					CLOSE Cur_MulTaxGroup
					DEALLOCATE Cur_MulTaxGroup
				END
			END		
			
			FETCH NEXT FROM Cur_Batch INTO @PrdBatCode
		END
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_Batch
			DEALLOCATE Cur_Batch
			
			CLOSE Cur_SpecialRate
			DEALLOCATE Cur_SpecialRate
			RETURN
		END		
		
		IF @Po_ErrNo=0
		BEGIN
			IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[BLCmpBatCode]')
			AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
			BEGIN
				IF EXISTS(SELECT CmpBatCode FROM BLCmpBatCode)
				BEGIN	
					CLOSE Cur_Batch
					DEALLOCATE Cur_Batch
				END
			END
		END
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_SpecialRate
			DEALLOCATE Cur_SpecialRate
			RETURN
		END
		IF NOT EXISTS(SELECT * FROM SpecialRateAftDownLoad WHERE RtrCtgCode=@RtrHierLevelCode AND
		RtrCtgValueCode=@RtrHierLevelValueCode AND RtrCode=@RtrCode AND PrdCCode=@PrdCCode AND
		PrdBatCCode=@PrdBatCodeAll AND SplSelRate=@SplRate AND FromDate<=@EffFromDate)
		BEGIN
			SET @ContHistExist=0
		END
		ELSE
		BEGIN	
			SET @ContHistExist=1
		END
		IF @ContHistExist=0	
		BEGIN	
			IF NOT EXISTS(SELECT * FROM SpecialRateAftDownLoad WHERE RtrCtgCode=@RtrHierLevelCode AND
			RtrCtgValueCode=@RtrHierLevelValueCode AND RtrCode=@RtrCode AND PrdCCode=@PrdCCode AND
			PrdBatCCode=@PrdBatCodeAll AND FromDate<=@EffFromDate)
			BEGIN
				INSERT INTO SpecialRateAftDownLoad(RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode,
				SplSelRate,FromDate,CreatedDate,DownloadedDate,ContractPriceIds)
				VALUES(@RtrHierLevelCode,@RtrHierLevelValueCode,@RtrCode,
				@PrdCCode,@PrdBatCodeAll,@DownldSplRate,@EffFromDate,@CreatedDate,GETDATE(),@ContractPriceIds)		
			END
			ELSE
			BEGIN
				UPDATE SpecialRateAftDownLoad SET SplSelRate=@DownldSplRate,ContractPriceIds=@ContractPriceIds
				WHERE RtrCtgCode=@RtrHierLevelCode AND RtrCtgValueCode=@RtrHierLevelValueCode AND
				RtrCode=@RtrCode AND PrdCCode=@PrdCCode AND PrdBatCCode=@PrdBatCodeAll
				AND FromDate<=@EffFromDate
			END
		END
		FETCH NEXT FROM Cur_SpecialRate INTO @RtrHierLevelCode,@RtrHierLevelValueCode,@RtrCode,
		@PrdCCode,@PrdBatCodeAll,@SplRate,@EffFromDate,@EffToDate,@CreatedDate,@PrdId,@CtgLevelId,@CtgMainId
	END	
	CLOSE Cur_SpecialRate
	DEALLOCATE Cur_SpecialRate
	IF @ContractReq=1
	BEGIN
		EXEC Proc_Validate_ContractPricing @Po_ErrNo=@ErrStatus
		SET @Po_ErrNo=@ErrStatus
	END	
	IF @Po_ErrNo=0
	BEGIN	
		UPDATE Cn2Cs_Prk_SpecialRate SET DownLoadFlag='Y' 
		WHERE CtgLevelName+'~'+CtgCode+'~'+RtrCode+'~'+PrdCCode+'~'+PrdBatCode
		NOT IN(SELECT RtrHierLevel+'~'+RtrHierValue+'~'+RtrCode+'~'+PrdCCode+'~'+PrdBatCode FROM SplRateToAvoid)
	END
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-209-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptStockandSalesVolume]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptStockandSalesVolume]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_RptStockandSalesVolume 6,1,0,'HK4',0,0,1

CREATE  PROCEDURE [dbo].[Proc_RptStockandSalesVolume]  
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
	DECLARE @FromDate AS DATETIME  
	DECLARE @ToDate  AS DATETIME  
	DECLARE @LcnId   AS INT  
	DECLARE @PrdCatValId AS INT  
	DECLARE @PrdId  AS INT  
	DECLARE @CmpId   AS INT  
	DECLARE @DisplayBatch  AS INT  
	DECLARE @PrdStatus  AS INT  
	DECLARE @BatStatus  AS INT  
	DECLARE @PrdBatId AS INT  
	DECLARE @IncOffStk  AS INT  
	DECLARE @StockValue 	AS	INT
	DECLARE @SupzeroStock AS INT
	DECLARE @RptDispType	AS INT
	--select *  from TempRptStockNSales  
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)  
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)  
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId  
	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))  
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))  
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  
	SET @DisplayBatch =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,28,@Pi_UsrId))  
	SET @PrdStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId))  
	SET @BatStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId))  
	SET @PrdBatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId))  
	SET @IncOffStk =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,202,@Pi_UsrId))
	SET @StockValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,23,@Pi_UsrId))  
	SET @SupZeroStock =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))  
	SET @RptDispType = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,221,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
	IF @IncOffStk=1  
	BEGIN  
		Exec Proc_GetStockNSalesDetailsWithOffer @FromDate,@ToDate,@Pi_UsrId  
	END  
	ELSE  
	BEGIN  
		Exec Proc_GetStockNSalesDetails @FromDate,@ToDate,@Pi_UsrId  
	END  
	IF @DisplayBatch = 1 
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=1 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 
	ELSE
	BEGIN
		UPDATE RptExcelHeaders SET DisplayFlag=0 WHERE SlNo=5 AND RptId=@Pi_RptId
	END 

	--Create TABLE #RptPendingBillsDetails  
	CREATE TABLE #RptStockandSalesVolume  
	(  
		PrdId			INT,  
		PrdDCode			NVARCHAR(20),  
		PrdName			NVARCHAR(100),  
		PrdBatId			INT,  
		PrdBatCode		NVARCHAR(50),  
		CmpId			INT,  
		CmpName			NVARCHAR(50),  
		LcnId			INT,  
		LcnName			NVARCHAR(50),   
		OpeningStock		NUMERIC(38,0),    
		Purchase			NUMERIC (38,0),  
		Sales			NUMERIC (38,0),  
		AdjustmentIn		NUMERIC (38,0),  
		AdjustmentOut    NUMERIC (38,0),  
		PurchaseReturn   NUMERIC (38,0),  
		SalesReturn		NUMERIC (38,0),    
		ClosingStock		NUMERIC (38,0),  
		DispBatch        INT  ,
		ClosingStkValue	NUMERIC (38,6),
		PrdWeight	NUMERIC (38,6)
	)  

	SELECT * INTO #RptStockandSalesVolume1 FROM #RptStockandSalesVolume  

	SET @TblName = 'RptStockandSalesVolume'  
	SET @TblStruct = 'PrdId    INT,  
					  PrdDCode			NVARCHAR(20),  
					  PrdName			NVARCHAR(100),  
					  PrdBatId			INT,  
					  PrdBatCode		NVARCHAR(50),  
					  CmpId				INT,  
					  CmpName			NVARCHAR(50),  
					  LcnId				INT,  
					  LcnName			NVARCHAR(50),   
					  OpeningStock		NUMERIC(38,0),  
					  Purchase			NUMERIC (38,0),  
					  Sales				NUMERIC (38,0),     
					  AdjustmentIn		NUMERIC (38,0),  
					  AdjustmentOut		NUMERIC (38,0),  
					  PurchaseReturn	NUMERIC (38,0),  
					  SalesReturn		NUMERIC (38,0),     
					  ClosingStock		NUMERIC (38,0),  
					  DispBatch         INT,
					  ClosingStkValue	NUMERIC (38,6),
					  PrdWeight	NUMERIC (38,6)'  
	SET @TblFields = 'PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
   					  LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,  
					  PurchaseReturn,SalesReturn,ClosingStock,DispBatch,ClosingStkValue,PrdWeight'  
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
	IF @Pi_GetFromSnap = 0  --To Generate For New Report Data  
	BEGIN  
		INSERT INTO #RptStockandSalesVolume1 (	PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,
												AdjustmentOut,PurchaseReturn,SalesReturn,
												ClosingStock,DispBatch,ClosingStkValue,PrdWeight)  
		SELECT 
			PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,TempRptStockNSales.CmpId,CmpName,LcnId,LcnName,  
			Opening,Purchase,Sales,AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,Closing,@DisplayBatch,
			dbo.Fn_ConvertCurrency(CASE @StockValue WHEN 1 THEN CloSelRte WHEN 2 THEN CloPurRte WHEN 3 THEN CloMRPRte END,@Pi_CurrencyId),0
		FROM 
			TempRptStockNSales INNER JOIN  Company  C ON C.CmpId = TempRptStockNSales.CmpId  
		WHERE 
			( TempRptStockNSales.CmpId = (CASE @CmpId WHEN 0 THEN TempRptStockNSales.CmpId ELSE 0 END) OR  
					TempRptStockNSales.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)) )  
			AND (LcnId = (CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
					LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
			AND (PrdStatus = (CASE @PrdStatus WHEN 0 THEN PrdStatus ELSE 0 END) OR  
					PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,24,@Pi_UsrId)))  
			AND (BatStatus = (CASE @BatStatus WHEN 0 THEN BatStatus ELSE 2 END) OR  
					BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,25,@Pi_UsrId)))  
			AND (PrdId = (CASE @PrdCatValId WHEN 0 THEN PrdId Else 0 END) OR  
					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))  
			AND (PrdId = (CASE @PrdId WHEN 0 THEN PrdId Else 0 END) OR  
					PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))  
			AND UserId=@Pi_UsrId  
		IF @DisplayBatch = 1  
		BEGIN  
			INSERT INTO #RptStockandSalesVolume (PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												 LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,
												 PurchaseReturn,SalesReturn,ClosingStock,DispBatch,
												 ClosingStkValue,PrdWeight)  
			SELECT 
				PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,0,'',  			
				SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase ,SUM(Sales) AS Sales,  
				SUM(AdjustmentIn) AS AdjustmentIN,SUM(AdjustmentOut) AS AdjustmentOut,  
				SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
				SUM(ClosingStock) AS ClosingStock,@DisplayBatch,SUM(ClosingStkValue),0
			FROM #RptStockandSalesVolume1   
			WHERE 
				(PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR  
						PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))      
			GROUP BY PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName  
		END  
		ELSE  
		BEGIN  
			INSERT INTO #RptStockandSalesVolume (PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,  
												LcnName,OpeningStock,Purchase,Sales,AdjustmentIn,AdjustmentOut,
												PurchaseReturn,SalesReturn,ClosingStock,DispBatch,ClosingStkValue,PrdWeight)  
			SELECT 
				PrdId,PrdDCode,PrdName,0,'',CmpId,CmpName,0,'',  
				SUM(OpeningStock) AS OpeningStock,SUM(Purchase) AS Purchase ,SUM(Sales) AS Sales,  
				SUM(AdjustmentIn) AS AdjustmentIN,SUM(AdjustmentOut) AS AdjustmentOut,  
				SUM(PurchaseReturn) AS PurchaseReturn,SUM(SalesReturn) AS SalesReturn,
				SUM(ClosingStock) AS ClosingStock,@DisplayBatch,SUM(ClosingStkValue),0
			FROM #RptStockandSalesVolume1   
			WHERE  
				(PrdBatId=(CASE @PrdBatId WHEN 0 THEN PrdBatId ELSE 0 END ) OR  
						PrdBatId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,7,@Pi_UsrId)))      
			GROUP BY PrdId,PrdDCode,PrdName,CmpId,CmpName  
		END		 

		--->Added By Nanda on 25/02/2011
		UPDATE Rpt SET Rpt.PrdWeight=P.PrdWgt*(CASE P.PrdUnitId WHEN 2 THEN Rpt.ClosingStock/1000000 ELSE Rpt.ClosingStock/1000 END)
		FROM Product P,#RptStockandSalesVolume Rpt WHERE P.PrdId=Rpt.PrdId AND P.PrdUnitId IN (2,3)
		--->Till Here

		IF LEN(@PurDBName) > 0  
		BEGIN  
			SET @SSQL = 'INSERT INTO #RptStockandSalesVolume ' +  
			'(' + @TblFields + ')' +  
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName  
			+ ' WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR ' +  
			' CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ '( LcnId = (CASE ' + CAST(@LcnId AS nVarChar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR ' +  
			' LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',22,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '  
			+ '( PrdStatus = (CASE ' + CAST(@PrdStatus AS nVarchar(10)) + ' WHEN 0 THEN PrdStatus ELSE 0 END) OR ' +  
			' PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',24,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) AND '  
			+ '( BatStatus = (CASE ' + CAST(@BatStatus AS nVarchar(10)) + ' WHEN 0 THEN BatStatus ELSE 0 END) OR ' +  
			' BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',25,' + CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '  
			+ '( PrdId = (CASE ' + CAST(@PrdCatValId AS nVarchar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR ' +  
			' PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + ' ))) AND '  
			+ ' (R.PrdId = (CASE ' + CAST(@PrdId AS nVarChar(10)) + ' WHEN 0 THEN PrdId Else 0 END) OR ' +  
			' PrdId in (SELECT iCountid from Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS  nVarchar(10)) + ',5,' +  CAST(@Pi_UsrId AS nVarchar(10)) + ' )))'  
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
			' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptStockandSalesVolume'  
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
			SET @SSQL = 'INSERT INTO #RptStockandSalesVolume ' +  
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


	IF EXISTS(SELECT * FROM RptExcelFlag WHERE RptId=@Pi_RptId AND  GridFlag=1 AND UsrId=@Pi_UsrId)
	BEGIN
		SELECT a.PrdId,a.PrdDCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.CmpId,a.CmpName,a.LcnId,a.LcnName,
		a.OpeningStock,a.Purchase,Sales,CASE WHEN ConverisonFactor2>0 THEN Case When 
		CAST(Sales AS INT)>nullif(ConverisonFactor2,0) Then CAST(Sales AS INT)/nullif(ConverisonFactor2,0) Else 0 End 
		ELSE 0 END As Uom1,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0) THEN Case When 
		(CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*
		nullif(ConverisonFactor2,0)))>=nullif(ConverisonFactor3,0) Then 
		isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*
		nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0) Else 0 End ELSE 0 END as Uom2,
		CASE WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0) THEN Case 
		When (CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*
		nullif(ConverisonFactor2,0) + isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*
		nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*
		nullif(Converisonfactor3,0)))>=nullif(ConverisonFactor4,0) Then
		(CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + 
		isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/Isnull(ConverisonFactor2,0)*
		Isnull(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*
		ISNULL(Converisonfactor3,0)))/nullif(ConverisonFactor4,0) Else 0 End ELSE 0 END as Uom3,
		CASE WHEN ConverisonFactor3>0 and ConverisonFactor4>0 THEN
		CASE 
			WHEN (ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4>0 AND ConversionFactor1>0) THEN 
				Case 
				When 
					CAST(Sales AS INT)-(((CAST(Sales AS INT)/Isnull(ConverisonFactor2,0))*ISNULL(ConverisonFactor2,0)) + ((isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/isnull(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))>=ISNULL(ConversionFactor1,0) Then
					CAST(Sales AS INT)-(((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0)) + ((isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0))*nullif(ConverisonFactor3,0))+
					(((CAST(Sales AS INT)-((CAST(Sales AS INT)/nullif(ConverisonFactor2,0))*nullif(ConverisonFactor2,0) + isnull(((CAST(Sales AS INT)-(CAST(Sales AS INT)/nullif(ConverisonFactor2,0)*nullif(ConverisonFactor2,0)))/nullif(ConverisonFactor3,0)),0)*nullif(Converisonfactor3,0)))/nullif(ConverisonFactor4,0)) *nullif(ConverisonFactor4,0)))/ISNULL(ConversionFactor1,0) Else 0 End ELSE 0 END
				ELSE
					CASE 
						WHEN ConverisonFactor2>0 AND ConverisonFactor3=0 THEN
					Case
						When CAST(Sum(Sales) AS INT)>Isnull(ConverisonFactor2,0) Then
							CAST(Sum(Sales) AS INT)%nullif(ConverisonFactor2,0)
						Else CAST(Sum(Sales) AS INT) End
						WHEN ConverisonFactor2>0 AND ConverisonFactor3>0 AND ConverisonFactor4=0 THEN
					Case
					When CAST(Sum(Sales) AS INT)>Isnull(ConverisonFactor3,0) Then
					CAST(Sum(Sales) AS INT)%nullif(ConverisonFactor3,0)
					Else CAST(Sum(Sales) AS INT) 
				End			
			ELSE CAST(Sum(Sales) AS INT) END
		END AS Uom4,a.AdjustmentIn,a.AdjustmentOut,a.PurchaseReturn,a.SalesReturn,a.ClosingStock,a.DispBatch INTO #RptColDetails
		FROM #RptStockandSalesVolume A INNER JOIN View_ProdUOMDetails B ON a.prdid=b.prdid WHERE OpeningStock > 0 OR ClosingStock > 0  
		GROUP BY a.PrdId,a.PrdDCode,a.PrdName,a.PrdBatId,a.PrdBatCode,a.CmpId,a.CmpName,a.LcnId,a.LcnName,a.OpeningStock,a.Purchase,Sales,
		a.AdjustmentIn,a.AdjustmentOut,a.PurchaseReturn,a.SalesReturn,a.ClosingStock,a.DispBatch,
		ConversionFactor1,ConverisonFactor2,ConverisonFactor3,ConverisonFactor4
		ORDER BY A.CmpId,A.PrdId,A.PrdBatId,A.LcnId 
		DELETE FROM RptColValues WHERE RptId=@Pi_RptId AND Usrid=@Pi_UsrId
		INSERT INTO RptColvalues(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,C16,C17,C18,Rptid,Usrid)
		SELECT 
			PrdDCode,PrdName,PrdBatCode,CmpName,LcnName,OpeningStock,Purchase,Sales,Uom1,Uom2,Uom3,Uom4,
			AdjustmentIn,AdjustmentOut,PurchaseReturn,SalesReturn,ClosingStock,DispBatch,
			@Pi_RptId,@Pi_UsrId 
		FROM #RptColDetails
	END

	IF @SupZeroStock=1
	BEGIN 
		SELECT  * FROM #RptStockandSalesVolume
		WHERE (OpeningStock+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+ClosingStock)<>0
		IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
		BEGIN
			TRUNCATE TABLE RptStockandSalesVolume_Excel
			INSERT INTO RptStockandSalesVolume_Excel(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,LcnName,OpeningStock,OpeningStockInVolume,
			Purchase,PurchaseStockInVolume,Sales,SalesStockInVolume,AdjustmentIn,AdjustmentInStockVolume,AdjustmentOut,AdjustmentOutStockVolume,PurchaseReturn,
			PurchaseReturnStockInVolume,SalesReturn,SalesReturnStockInVolume,ClosingStock,ClosingStockInVolume,DispBatch,ClosingStkValue,PrdWeight)
			SELECT	PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,
					LcnId,LcnName,
					OpeningStock,0.00 as OpeningStockInVolume,
					Purchase,0.00 as PurchaseStockInVolume,
					Sales, 0.00 as SalesStockInVolume,
					AdjustmentIn,0.00 as AdjustmentInStockVolume,
					AdjustmentOut,0.00 as AdjustmentOutStockVolume,
					PurchaseReturn,0.00 As PurchaseReturnStockInVolume,
					SalesReturn,0.00 SalesReturnStockInVolume,
					ClosingStock,0.00 ClosingStockInVolume,
					DispBatch,ClosingStkValue,PrdWeight
			FROM #RptStockandSalesVolume
			WHERE (OpeningStock+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+ClosingStock)<>0
			Update RptStockandSalesVolume_Excel SET
					OpeningStockInVolume = ((OpeningStock * PrdWgt)/1000),
					PurchaseStockInVolume = ((Purchase * PrdWgt)/1000),
					SalesStockInVolume = ((Sales * PrdWgt)/1000),
					AdjustmentInStockVolume = ((AdjustmentIn * PrdWgt)/1000),
					AdjustmentOutStockVolume = ((AdjustmentOut * PrdWgt)/1000),
					SalesReturnStockInVolume = ((SalesReturn * PrdWgt)/1000),
					ClosingStockInVolume = ((ClosingStock * PrdWgt)/1000)		
			From RptStockandSalesVolume_Excel A,Product B
			WHERE A.PrdId = B.PrdId
		END
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptStockandSalesVolume   
		WHERE (OpeningStock+Purchase+Sales+AdjustmentIn+AdjustmentOut+PurchaseReturn+SalesReturn+ClosingStock)<>0
	END
	ELSE
	BEGIN
		SELECT * FROM #RptStockandSalesVolume
		IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
		BEGIN
			TRUNCATE TABLE RptStockandSalesVolume_Excel
			INSERT INTO RptStockandSalesVolume_Excel(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,LcnId,LcnName,OpeningStock,OpeningStockInVolume,
			Purchase,PurchaseStockInVolume,Sales,SalesStockInVolume,AdjustmentIn,AdjustmentInStockVolume,AdjustmentOut,AdjustmentOutStockVolume,PurchaseReturn,
			PurchaseReturnStockInVolume,SalesReturn,SalesReturnStockInVolume,ClosingStock,ClosingStockInVolume,DispBatch,ClosingStkValue,PrdWeight)
			SELECT PrdId,PrdDcode,PrdName,PrdBatId,PrdBatCode,CmpId,CmpName,
					LcnId,LcnName,
					OpeningStock,0.00 as OpeningStockInVolume,
					Purchase,0.00 as PurchaseStockInVolume,
					Sales, 0.00 as SalesStockInVolume,
					AdjustmentIn,0.00 as AdjustmentInStockVolume,
					AdjustmentOut,0.00 as AdjustmentOutStockVolume,
					PurchaseReturn,0.00 As PurchaseReturnStockInVolume,
					SalesReturn,0.00 SalesReturnStockInVolume,
					ClosingStock,0.00 ClosingStockInVolume,
					DispBatch,ClosingStkValue,PrdWeight 
			FROM #RptStockandSalesVolume		
			Update RptStockandSalesVolume_Excel SET
					OpeningStockInVolume = ((OpeningStock * PrdWgt)/1000),
					PurchaseStockInVolume = ((Purchase * PrdWgt)/1000),
					SalesStockInVolume = ((Sales * PrdWgt)/1000),
					AdjustmentInStockVolume = ((AdjustmentIn * PrdWgt)/1000),
					AdjustmentOutStockVolume = ((AdjustmentOut * PrdWgt)/1000),
					SalesReturnStockInVolume = ((SalesReturn * PrdWgt)/1000),
					ClosingStockInVolume = ((ClosingStock * PrdWgt)/1000)		
			From RptStockandSalesVolume_Excel A,Product B
			WHERE A.PrdId = B.PrdId
		END
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId  
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)  
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptStockandSalesVolume   
	END
	RETURN  
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-209-003

if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptBillTemplateFinal]
GO

CREATE TABLE [dbo].[RptBillTemplateFinal]
(
	[Base Qty] [numeric](38, 2) NULL,
	[Batch Code] [nvarchar](100) NULL,
	[Batch Expiry Date] [datetime] NULL,
	[Batch Manufacturing Date] [datetime] NULL,
	[Batch MRP] [numeric](38, 2) NULL,
	[Batch Selling Rate] [numeric](38, 2) NULL,
	[Bill Date] [datetime] NULL,
	[Bill Doc Ref. Number] [nvarchar](100) NULL,
	[Bill Mode] [tinyint] NULL,
	[Bill Type] [tinyint] NULL,
	[CD Disc Base Qty Amount] [numeric](38, 2) NULL,
	[CD Disc Effect Amount] [numeric](38, 2) NULL,
	[CD Disc Header Amount] [numeric](38, 2) NULL,
	[CD Disc LineUnit Amount] [numeric](38, 2) NULL,
	[CD Disc Qty Percentage] [numeric](38, 2) NULL,
	[CD Disc Unit Percentage] [numeric](38, 2) NULL,
	[CD Disc UOM Amount] [numeric](38, 2) NULL,
	[CD Disc UOM Percentage] [numeric](38, 2) NULL,
	[Company Address1] [nvarchar](100) NULL,
	[Company Address2] [nvarchar](100) NULL,
	[Company Address3] [nvarchar](100) NULL,
	[Company Code] [nvarchar](40) NULL,
	[Company Contact Person] [nvarchar](200) NULL,
	[Company EmailId] [nvarchar](100) NULL,
	[Company Fax Number] [nvarchar](100) NULL,
	[Company Name] [nvarchar](200) NULL,
	[Company Phone Number] [nvarchar](100) NULL,
	[Contact Person] [nvarchar](100) NULL,
	[CST Number] [nvarchar](100) NULL,
	[DB Disc Base Qty Amount] [numeric](38, 2) NULL,
	[DB Disc Effect Amount] [numeric](38, 2) NULL,
	[DB Disc Header Amount] [numeric](38, 2) NULL,
	[DB Disc LineUnit Amount] [numeric](38, 2) NULL,
	[DB Disc Qty Percentage] [numeric](38, 2) NULL,
	[DB Disc Unit Percentage] [numeric](38, 2) NULL,
	[DB Disc UOM Amount] [numeric](38, 2) NULL,
	[DB Disc UOM Percentage] [numeric](38, 2) NULL,
	[DC DATE] [datetime] NULL,
	[DC NUMBER] [nvarchar](200) NULL,
	[Delivery Boy] [nvarchar](100) NULL,
	[Delivery Date] [datetime] NULL,
	[Deposit Amount] [numeric](38, 2) NULL,
	[Distributor Address1] [nvarchar](100) NULL,
	[Distributor Address2] [nvarchar](100) NULL,
	[Distributor Address3] [nvarchar](100) NULL,
	[Distributor Code] [nvarchar](40) NULL,
	[Distributor Name] [nvarchar](100) NULL,
	[Drug Batch Description] [nvarchar](100) NULL,
	[Drug Licence Number 1] [nvarchar](100) NULL,
	[Drug Licence Number 2] [nvarchar](100) NULL,
	[Drug1 Expiry Date] [datetime] NULL,
	[Drug2 Expiry Date] [datetime] NULL,
	[EAN Code] [varchar](50) NULL,
	[EmailID] [nvarchar](100) NULL,
	[Geo Level] [nvarchar](100) NULL,
	[Interim Sales] [tinyint] NULL,
	[Licence Number] [nvarchar](100) NULL,
	[Line Base Qty Amount] [numeric](38, 2) NULL,
	[Line Base Qty Percentage] [numeric](38, 2) NULL,
	[Line Effect Amount] [numeric](38, 2) NULL,
	[Line Unit Amount] [numeric](38, 2) NULL,
	[Line Unit Percentage] [numeric](38, 2) NULL,
	[Line UOM1 Amount] [numeric](38, 2) NULL,
	[Line UOM1 Percentage] [numeric](38, 2) NULL,
	[LST Number] [nvarchar](100) NULL,
	[Manual Free Qty] [int] NULL,
	[Order Date] [datetime] NULL,
	[Order Number] [nvarchar](100) NULL,
	[Pesticide Expiry Date] [datetime] NULL,
	[Pesticide Licence Number] [nvarchar](100) NULL,
	[PhoneNo] [nvarchar](100) NULL,
	[PinCode] [int] NULL,
	[Product Code] [nvarchar](100) NULL,
	[Product Name] [nvarchar](400) NULL,
	[Product Short Name] [nvarchar](200) NULL,
	[Product SL No] [int] NULL,
	[Product Type] [int] NULL,
	[Remarks] [nvarchar](400) NULL,
	[Retailer Address1] [nvarchar](200) NULL,
	[Retailer Address2] [nvarchar](200) NULL,
	[Retailer Address3] [nvarchar](200) NULL,
	[Retailer Code] [nvarchar](100) NULL,
	[Retailer ContactPerson] [nvarchar](200) NULL,
	[Retailer Coverage Mode] [tinyint] NULL,
	[Retailer Credit Bills] [int] NULL,
	[Retailer Credit Days] [int] NULL,
	[Retailer Credit Limit] [numeric](38, 2) NULL,
	[Retailer CSTNo] [nvarchar](100) NULL,
	[Retailer Deposit Amount] [numeric](38, 2) NULL,
	[Retailer Drug ExpiryDate] [datetime] NULL,
	[Retailer Drug License No] [nvarchar](100) NULL,
	[Retailer EmailId] [nvarchar](200) NULL,
	[Retailer GeoLevel] [nvarchar](100) NULL,
	[Retailer License ExpiryDate] [datetime] NULL,
	[Retailer License No] [nvarchar](100) NULL,
	[Retailer Name] [nvarchar](300) NULL,
	[Retailer OffPhone1] [nvarchar](100) NULL,
	[Retailer OffPhone2] [nvarchar](100) NULL,
	[Retailer OnAccount] [numeric](38, 2) NULL,
	[Retailer Pestcide ExpiryDate] [datetime] NULL,
	[Retailer Pestcide LicNo] [nvarchar](100) NULL,
	[Retailer PhoneNo] [nvarchar](100) NULL,
	[Retailer Pin Code] [nvarchar](100) NULL,
	[Retailer ResPhone1] [nvarchar](100) NULL,
	[Retailer ResPhone2] [nvarchar](100) NULL,
	[Retailer Ship Address1] [nvarchar](200) NULL,
	[Retailer Ship Address2] [nvarchar](200) NULL,
	[Retailer Ship Address3] [nvarchar](200) NULL,
	[Retailer ShipId] [int] NULL,
	[Retailer TaxType] [tinyint] NULL,
	[Retailer TINNo] [nvarchar](100) NULL,
	[Retailer Village] [nvarchar](200) NULL,
	[Route Code] [nvarchar](100) NULL,
	[Route Name] [nvarchar](100) NULL,
	[Sales Invoice Number] [nvarchar](100) NULL,
	[SalesInvoice ActNetRateAmount] [numeric](38, 2) NULL,
	[SalesInvoice CDPer] [numeric](38, 2) NULL,
	[SalesInvoice CRAdjAmount] [numeric](38, 2) NULL,
	[SalesInvoice DBAdjAmount] [numeric](38, 2) NULL,
	[SalesInvoice GrossAmount] [numeric](38, 2) NULL,
	[SalesInvoice Line Gross Amount] [numeric](38, 2) NULL,
	[SalesInvoice Line Net Amount] [numeric](38, 2) NULL,
	[SalesInvoice MarketRetAmount] [numeric](38, 2) NULL,
	[SalesInvoice NetAmount] [numeric](38, 2) NULL,
	[SalesInvoice NetRateDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice OnAccountAmount] [numeric](38, 2) NULL,
	[SalesInvoice OtherCharges] [numeric](38, 2) NULL,
	[SalesInvoice RateDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice ReplacementDiffAmount] [numeric](38, 2) NULL,
	[SalesInvoice RoundOffAmt] [numeric](38, 2) NULL,
	[SalesInvoice TotalAddition] [numeric](38, 2) NULL,
	[SalesInvoice TotalDeduction] [numeric](38, 2) NULL,
	[SalesInvoice WindowDisplayAmount] [numeric](38, 2) NULL,
	[SalesMan Code] [nvarchar](100) NULL,
	[SalesMan Name] [nvarchar](100) NULL,
	[SalId] [int] NULL,
	[Sch Disc Base Qty Amount] [numeric](38, 2) NULL,
	[Sch Disc Effect Amount] [numeric](38, 2) NULL,
	[Sch Disc Header Amount] [numeric](38, 2) NULL,
	[Sch Disc LineUnit Amount] [numeric](38, 2) NULL,
	[Sch Disc Qty Percentage] [numeric](38, 2) NULL,
	[Sch Disc Unit Percentage] [numeric](38, 2) NULL,
	[Sch Disc UOM Amount] [numeric](38, 2) NULL,
	[Sch Disc UOM Percentage] [numeric](38, 2) NULL,
	[Scheme Points] [numeric](38, 2) NULL,
	[Spl. Disc Base Qty Amount] [numeric](38, 2) NULL,
	[Spl. Disc Effect Amount] [numeric](38, 2) NULL,
	[Spl. Disc Header Amount] [numeric](38, 2) NULL,
	[Spl. Disc LineUnit Amount] [numeric](38, 2) NULL,
	[Spl. Disc Qty Percentage] [numeric](38, 2) NULL,
	[Spl. Disc Unit Percentage] [numeric](38, 2) NULL,
	[Spl. Disc UOM Amount] [numeric](38, 2) NULL,
	[Spl. Disc UOM Percentage] [numeric](38, 2) NULL,
	[Tax 1] [numeric](38, 2) NULL,
	[Tax 2] [numeric](38, 2) NULL,
	[Tax 3] [numeric](38, 2) NULL,
	[Tax 4] [numeric](38, 2) NULL,
	[Tax Amount1] [numeric](38, 2) NULL,
	[Tax Amount2] [numeric](38, 2) NULL,
	[Tax Amount3] [numeric](38, 2) NULL,
	[Tax Amount4] [numeric](38, 2) NULL,
	[Tax Amt Base Qty Amount] [numeric](38, 2) NULL,
	[Tax Amt Effect Amount] [numeric](38, 2) NULL,
	[Tax Amt Header Amount] [numeric](38, 2) NULL,
	[Tax Amt LineUnit Amount] [numeric](38, 2) NULL,
	[Tax Amt Qty Percentage] [numeric](38, 2) NULL,
	[Tax Amt Unit Percentage] [numeric](38, 2) NULL,
	[Tax Amt UOM Amount] [numeric](38, 2) NULL,
	[Tax Amt UOM Percentage] [numeric](38, 2) NULL,
	[Tax Type] [tinyint] NULL,
	[TIN Number] [nvarchar](100) NULL,
	[Uom 1 Desc] [nvarchar](100) NULL,
	[Uom 1 Qty] [int] NULL,
	[Uom 2 Desc] [nvarchar](100) NULL,
	[Uom 2 Qty] [int] NULL,
	[Vehicle Name] [nvarchar](100) NULL,
	[UsrId] [int] NULL,
	[Visibility] [tinyint] NULL,
	[AmtInWrd] [nvarchar](500) NULL,
	[Product Weight] [numeric](38, 2) NULL,
	[Product UPC] [numeric](38, 0) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-209-004

DELETE FROM RptExcelHeaders WHERE RptId=6

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','1','PrdId','PrdId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','2','PrdDCode','Product Code','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','3','PrdName','Product Name','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','4','PrdBatId','PrdBatId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','5','PrdBatCode','Batch Code','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','6','CmpId','CmpId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','7','CmpName','Company Name','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','8','LcnId','LcnId','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','9','LcnName','Location Name','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','10','OpeningStock','Opening Stock','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','11','OpeningStockInVolume','Opening Stock in Volume','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','12','Purchase','Purchase','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','13','PurchaseStockInVolume','Purchase Stock in Volume','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','14','Sales','Sales','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','15','SalesStockInVolume','Sales Stock in Volume','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','16','AdjustmentIn','AdjustmentIn','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','17','AdjustmentInStockVolume','Adjustmentin Stock in Volume','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','18','AdjustmentOut','AdjustmentOut','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','19','AdjustmentOutStockVolume','AdjustmentOut  Stock in  Volume','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','20','PurchaseReturn','Purchase Return','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','21','PurchaseReturnStockInVolume','PurchaseReturn  Stock in  Volume','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','22','SalesReturn','SalesReturn','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','23','SalesReturnStockInVolume','SalesReturn  Stock in  Volume','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','24','ClosingStock','ClosingStock','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','25','ClosingStockInVolume','Closing  Stock in  Volume','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','26','DispBatch','DispBatch','0','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','27','ClosingStkValue','Closing Stock Value','1','1')

INSERT INTO RptExcelHeaders(RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId) 
VALUES('6','28','PrdWeight','Product Weight In Ton','1','1')

--SRF-Nanda-209-005

if exists (select * from dbo.sysobjects where id = object_id(N'[RptStockandSalesVolume_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptStockandSalesVolume_Excel]
GO

CREATE TABLE [dbo].[RptStockandSalesVolume_Excel]
(
	[PrdId] [int] NULL,
	[PrdDCode] [nvarchar](20) NULL,
	[PrdName] [nvarchar](100) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [nvarchar](50) NULL,
	[CmpId] [int] NULL,
	[CmpName] [nvarchar](50) NULL,
	[LcnId] [int] NULL,
	[LcnName] [nvarchar](50) NULL,
	[OpeningStock] [numeric](38, 0) NULL,
	[OpeningStockInVolume] [numeric](38, 6) NULL,
	[Purchase] [numeric](38, 0) NULL,
	[PurchaseStockInVolume] [numeric](38, 6) NULL,
	[Sales] [numeric](38, 0) NULL,
	[SalesStockInVolume] [numeric](38, 6) NULL,
	[AdjustmentIn] [numeric](38, 0) NULL,
	[AdjustmentInStockVolume] [numeric](38, 6) NULL,
	[AdjustmentOut] [numeric](38, 0) NULL,
	[AdjustmentOutStockVolume] [numeric](38, 6) NULL,
	[PurchaseReturn] [numeric](38, 0) NULL,
	[PurchaseReturnStockInVolume] [numeric](38, 6) NULL,
	[SalesReturn] [numeric](38, 0) NULL,
	[SalesReturnStockInVolume] [numeric](38, 6) NULL,
	[ClosingStock] [numeric](38, 0) NULL,
	[ClosingStockInVolume] [numeric](38, 6) NULL,
	[DispBatch] [int] NULL,
	[ClosingStkValue] [numeric](38, 6) NULL,
	[PrdWeight] [numeric](38, 6) NULL
) ON [PRIMARY]
GO

--SRF-Nanda-209-006

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
	WHERE B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3 AND SI.RtrId=QPS.RtrId AND QPS.SchId=B.SchId
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
	AND ApportionSchemeDetails.SchId IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId AND AdjAmount>=0)	

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

--SRF-Nanda-209-007

if exists (select * from dbo.sysobjects where id = object_id(N'[ETL_Prk_PrdBatchDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [ETL_Prk_PrdBatchDetails]
GO

CREATE TABLE [dbo].[ETL_Prk_PrdBatchDetails]
(
	[Product Code] [nvarchar](100) NULL,
	[Batch Code] [nvarchar](100) NULL,
	[Manufacturing Date] [datetime] NULL,
	[Expiry Date] [datetime] NULL,
	[MRP] [numeric](38, 6) NULL,
	[List Price] [numeric](38, 6) NULL,
	[Selling Rate] [numeric](38, 6) NULL,
	[Claim Rate] [numeric](38, 6) NULL,
	[Effective From Date] [datetime] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-209-008

if not exists (select * from dbo.sysobjects where id = object_id(N'[ETLPrdBatchDetailsEffective]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE [dbo].[ETLPrdBatchDetailsEffective]
	(
		[Product Code] [nvarchar](100) NULL,
		[Batch Code] [nvarchar](100) NULL,
		[Manufacturing Date] [datetime] NULL,
		[Expiry Date] [datetime] NULL,
		[MRP] [numeric](38, 6) NULL,
		[List Price] [numeric](38, 6) NULL,
		[Selling Rate] [numeric](38, 6) NULL,
		[Claim Rate] [numeric](38, 6) NULL,
		[Effective From Date] [datetime] NULL
	) ON [PRIMARY]
end
GO

--SRF-Nanda-209-009

if exists (Select Id,name from Syscolumns where name = 'PrdUpSKU' and id in (Select id from 
	Sysobjects where name ='Product'))
begin
	ALTER TABLE [dbo].[Product]
	ALTER COLUMN [PrdUpSKU] NUMERIC(38,6) NULL
END
GO

--SRF-Nanda-209-010

if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplate_PrdUOMDetails]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptBillTemplate_PrdUOMDetails]
GO

CREATE TABLE [dbo].[RptBillTemplate_PrdUOMDetails]
(
	[SalId] [int] NULL,
	[SalInvNo] [nvarchar](100) NULL,
	[TotPrdVolume] [numeric](38, 6) NULL,
	[TotPrdKG] [numeric](38, 6) NULL,
	[TotPrdLtrs] [numeric](38, 6) NULL,
	[TotPrdUnits] [numeric](38, 6) NULL,
	[TotPrdDrums] [numeric](38, 6) NULL,
	[TotPrdCartons] [numeric](38, 6) NULL,
	[TotPrdBuckets] [numeric](38, 6) NULL,
	[TotPrdPieces] [numeric](38, 6) NULL,
	[TotPrdBags] [numeric](38, 6) NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-209-011

UPDATE ETLMaster SET ExportFnName='Fn_ExportPrdBatchDetails',ImportProcName='Proc_ImportPrdBatchDetails',
ParkTable='ETL_Prk_PrdBatchDetails',ValidateProcName='Proc_ValidatePrdBatchDetails'
WHERE SlNo=13

--SRF-Nanda-209-012

DELETE FROM Configuration WHERE ModuleId LIKE 'BotreePrdUPerSKU'

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) 
VALUES('BotreePrdUPerSKU','BotreePrdUPerSKU','Allow Decimals in Product Units Per SKU',0,'',0.00,1)

--SRF-Nanda-209-013

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ExportPrdBatchDetails]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ExportPrdBatchDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     FUNCTION [dbo].[Fn_ExportPrdBatchDetails] ()
RETURNS nVarchar(4000)
AS
BEGIN
/*********************************
* FUNCTION	: Fn_ExportPrdBatchDetails
* PURPOSE	: Export-ETL For Product Batch
* NOTES		:
* CREATED	: Nandakumar R.G  on 28-02-2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/

	DECLARE @ConStr AS nVarchar(4000)
	SET @ConStr = 'SELECT PrdCCode AS [Product Code],CmpBatCode AS [Batch Code],MnfDate AS [Manufacturing Date],ExpDate AS [Expiry Date],	
	MRP AS [MRP],LSP AS [List Price],SR AS [Selling Rate],CR AS [Claim Rate] 
	INTO #Temp
	FROM 
	(
		SELECT DISTINCT P.PrdCCode,PB.CmpBatCode,PB.MnfDate,PB.ExpDate,PBDM.PrdBatDetailValue AS MRP,
		PBDL.PrdBatDetailValue AS LSP,PBDS.PrdBatDetailValue AS SR,PBDC.PrdBatDetailValue AS CR	
		FROM ProductBatch PB,Product P,ProductBatchDetails PBDM,BatchCreation BCM,
		ProductBatchDetails PBDL,BatchCreation BCL,ProductBatchDetails PBDS,BatchCreation BCS,
		ProductBatchDetails PBDC,BatchCreation BCC
		WHERE P.PrdId=PB.PrdId AND BCM.BatchSeqId=PBDM.BatchSeqId AND PB.PrdBatId=PBDM.PrdBatId AND PBDM.SLNo=BCM.SlNo AND BCM.MRP=1
		AND BCL.BatchSeqId=PBDL.BatchSeqId AND PB.PrdBatId=PBDL.PrdBatId AND PBDL.SLNo=BCL.SlNo AND BCL.ListPrice=1 
		AND BCS.BatchSeqId=PBDS.BatchSeqId AND PB.PrdBatId=PBDS.PrdBatId AND PBDS.SLNo=BCS.SlNo AND BCS.SelRte=1
		AND BCC.BatchSeqId=PBDC.BatchSeqId AND PB.PrdBatId=PBDC.PrdBatId AND PBDC.SLNo=BCC.SlNo AND BCC.ClmRte=1
		AND PBDM.PrdBatId=PBDL.PrdBatId AND PBDM.PrdBatId=PBDS.PrdBatId AND PBDM.PrdBatId=PBDC.PrdBatId
		AND BCC.BatchSeqId=BCS.BatchSeqId AND BCS.BatchSeqId=BCL.BatchSeqId AND BCL.BatchSeqId=BCM.BatchSeqId
	) AS A
	ORDER BY PrdCCode
	SELECT * FROM #Temp'
	RETURN (@ConStr)

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-209-014

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnProductVolumeInLtrs]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnProductVolumeInLtrs]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[Fn_ReturnProductVolumeInLtrs]
(
	@Pi_PrdId	INT	
)
RETURNS NUMERIC(38,6)
AS
/*********************************
* FUNCTION	: Fn_ReturnProductVolumeInLtrs
* PURPOSE	: Returns the Product Volume In Ltrs
* NOTES		: 
* CREATED	: Nandakumar R.G On 01-03-2011
* MODIFIED 
* DATE			AUTHOR     DESCRIPTION
------------------------------------------------
* 22/04/2010	Nanda	   Added FBM Scheme	
*********************************/
BEGIN

	DECLARE @WeightInLtr	NUMERIC(38,6)

	SELECT @WeightInLtr=(CASE P.PrdUnitId WHEN 1 THEN PrdWgt WHEN 2 THEN PrdUpSKU/1000 WHEN 3 THEN PrdUpSKU 
	WHEN 4 THEN PrdWgt/1000 WHEN 5 THEN PrdWgt END) FROM Product P,ProductUnit PU
	WHERE P.PrdUnitId=PU.PrdUnitId AND P.PrdId=@Pi_PrdId
	
	RETURN(@WeightInLtr)
END 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-209-015

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ValidatePrdBatchDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ValidatePrdBatchDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
SELECT * FROM ETL_Prk_PrdBatchDetails(NOLOCK)-- WHERE DownLoadFlag='D'
SELECT COUNT(*) FROM ProductBatch(NOLOCK)
SELECT COUNT(*) FROM ProductBatchDetails(NOLOCK)
--SELECT COUNT(*) FROM ContractPricingMaster(NOLOCK)
--SELECT COUNT(*) FROM ContractPricingDetails(NOLOCK)
EXEC Proc_ValidatePrdBatchDetails 0
SELECT COUNT(*) FROM ProductBatch(NOLOCK)
SELECT COUNT(*) FROM ProductBatchDetails(NOLOCK)
--SELECT COUNT(*) FROM ProductBatchDetails(NOLOCK)
--SELECT * FROM ProductBatchDetails(NOLOCK) WHERE PriceId>15
--SELECT COUNT(*) FROM ContractPricingMaster(NOLOCK)
--SELECT COUNT(*) FROM ContractPricingDetails(NOLOCK)
--SELECT * FROM DefaultPriceHistory
--SELECT * FROM ErrorLog
ROLLBACK TRANSACTION
*/

CREATE	PROCEDURE [dbo].[Proc_ValidatePrdBatchDetails]
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
	
	DECLARE @EffDate			AS 	DATETIME

	DECLARE @PrdId 				AS 	INT
	DECLARE @PrdBatId 			AS 	INT
	DECLARE @PriceId 			AS 	INT
	DECLARE @TaxGroupId 		AS 	INT
	DECLARE @BatchSeqId 		AS 	INT
	DECLARE @BatchStatus		AS 	INT
	
	DECLARE @DefaultPriceId 	AS 	INT
	DECLARE @ExistPriceId 		AS 	INT
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

	DECLARE @MRP				AS  NUMERIC(38,6)
	DECLARE @LSP				AS  NUMERIC(38,6)
	DECLARE @SR					AS  NUMERIC(38,6)
	DECLARE @CR					AS  NUMERIC(38,6)	
	
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

	IF EXISTS(SELECT DISTINCT [Product Code] FROM ETL_Prk_PrdBatchDetails
	WHERE [Product Code] NOT IN (SELECT PrdCCode FROM Product))
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT [Product Code],[Batch Code] FROM ETL_Prk_PrdBatchDetails
		WHERE [Product Code] NOT IN (SELECT PrdCCode FROM Product)

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdCCode','Product :'+[Product Code]+' not available'
		FROM ETL_Prk_PrdBatchDetails
		WHERE [Product Code] NOT IN (SELECT PrdCCode FROM Product)
	END

	IF EXISTS(SELECT DISTINCT [Product Code] FROM ETL_Prk_PrdBatchDetails WHERE LEN(ISNULL([Batch Code],''))=0)
	BEGIN
		INSERT INTO PrdBatToAvoid(PrdCCode,PrdBatCode)
		SELECT DISTINCT [Product Code],[Batch Code] FROM ETL_Prk_PrdBatchDetails
		WHERE LEN(ISNULL([Batch Code],''))=0

		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Product Batch','PrdBatCode','Batch Code should not be empty for Product:'+[Product Code]
		FROM ETL_Prk_PrdBatchDetails
		WHERE LEN(ISNULL([Batch Code],''))=0
	END

	INSERT INTO ETLPrdBatchDetailsEffective([Product Code],[Batch Code],[Manufacturing Date],[Expiry Date],[MRP],
	[List Price],[Selling Rate],[Claim Rate],[Effective From Date])
	SELECT [Product Code],[Batch Code],[Manufacturing Date],[Expiry Date],[MRP],
	[List Price],[Selling Rate],[Claim Rate],[Effective From Date]
	FROM ETL_Prk_PrdBatchDetails PB INNER JOIN Product P ON P.PrdCCode=PB.[Product Code]
	WHERE PB.[Product Code]+'~'+[Batch Code]
	NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM PrdBatToAvoid) AND [Effective From Date]>GETDATE()

	DECLARE Cur_ProductBatch CURSOR
	FOR 
	SELECT DISTINCT [Product Code],[Batch Code],[Manufacturing Date],[Expiry Date],MRP,[List Price],[Selling Rate],[Claim Rate],[Effective From Date]	
	FROM 
	(
		SELECT PB.[Product Code],[Batch Code],[Manufacturing Date],[Expiry Date],MRP,[List Price],[Selling Rate],[Claim Rate],[Effective From Date]	
		FROM ETL_Prk_PrdBatchDetails PB INNER JOIN Product P ON P.PrdCCode=PB.[Product Code]
		WHERE PB.[Product Code]+'~'+[Batch Code]
		NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM PrdBatToAvoid) AND [Effective From Date]<=GETDATE()
		UNION ALL	
		SELECT PB.[Product Code],[Batch Code],[Manufacturing Date],[Expiry Date],MRP,[List Price],[Selling Rate],[Claim Rate],[Effective From Date]	
		FROM ETLPrdBatchDetailsEffective PB INNER JOIN Product P ON P.PrdCCode=PB.[Product Code]
		WHERE PB.[Product Code]+'~'+[Batch Code]
		NOT IN (SELECT PrdCCode+'~'+PrdBatCode FROM PrdBatToAvoid) AND [Effective From Date]<=GETDATE()		
	) A	
	ORDER BY [Product Code],[Batch Code],[Manufacturing Date],[Expiry Date],MRP,[List Price],[Selling Rate],[Claim Rate],[Effective From Date]

	OPEN Cur_ProductBatch
	FETCH NEXT FROM Cur_ProductBatch INTO @PrdCCode,@BatchCode,@MnfDate,@ExpDate,@MRP,@LSP,@SR,@CR,@EffDate
	WHILE @@FETCH_STATUS=0
	BEGIN

		SET @Exist=0
		SET @Po_ErrNo=0
		SET @DefaultPriceId=1
		SET @BatchStatus=1

		SET @PriceCode=@BatchCode+'-'+CAST(@MRP AS NVARCHAR(25))+'-'+CAST(@LSP AS NVARCHAR(25))+'-'+
		CAST(@SR AS NVARCHAR(25))+'-'+CAST(@CR AS NVARCHAR(25))

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
				INSERT INTO Errorlog VALUES (1,'ETL_Prk_PrdBatchDetails','System Date',
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

				UPDATE ProductBatch SET DefaultPriceId=@PriceId WHERE PrdBatId=@PrdBatId AND PrdId=@PrdId
	
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ProductBatchDetails' AND FldName='PriceId'				
			END
			ELSE
			BEGIN
				INSERT INTO Errorlog VALUES (1,'ETL_Prk_PrdBatchDetails','System Date',
				'Reset the Counters/System is showing Date as :'+CAST(GETDATE() AS NVARCHAR(10))+'. Please change the System Date')
				SET @Po_ErrNo=1
				CLOSE Cur_ProductBatch
				DEALLOCATE Cur_ProductBatch
				RETURN
			END
		END
		FETCH NEXT FROM Cur_ProductBatch INTO @PrdCCode,@BatchCode,@MnfDate,@ExpDate,@MRP,@LSP,@SR,@CR,@EffDate
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

	--->To Write Price History
	IF EXISTS(SELECT * FROM ProductBatchDetails WHERE DefaultPrice=1 AND PriceId>@OldPriceId)
	BEGIN
		EXEC Proc_DefaultPriceHistory 0,0,@OldPriceId,2,1
	END
	--->Till Here

	DELETE FROM ETLPrdBatchDetailsEffective WHERE [Effective From Date]<=GETDATE()
	DELETE FROM ETL_Prk_PrdBatchDetails 
	
	RETURN	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-209-016

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ImportPrdBatchDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ImportPrdBatchDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec Proc_ImportPrdBatchDetails '<Data></Data>'

CREATE       Procedure [dbo].[Proc_ImportPrdBatchDetails]
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE		: Proc_ImportPrdBatchDetails
* PURPOSE		: To Insert records from xml file in the Table ETL_Prk_PrdBatchDetails
* CREATED		: Nandakumar R.G
* CREATED DATE	: 28/02/2011
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records

	INSERT INTO ETL_Prk_PrdBatchDetails([Product Code],[Batch Code],[Manufacturing Date],[Expiry Date],
	[MRP],[List Price],[Selling Rate],[Claim Rate],[Effective From Date])
	SELECT [Product Code],[Batch Code],[Manufacturing Date],[Expiry Date],[MRP],[List Price],[Selling Rate],
	[Claim Rate],[Effective From Date]
	FROM OPENXML (@hdoc,'/Data/Product_x0020_Batch ',1)
	WITH 
	(
		[Product Code]			NVARCHAR(100),
		[Batch Code]			NVARCHAR(100),		
		[Manufacturing Date]	DATETIME,
		[Expiry Date]			DATETIME,
		[MRP]					NUMERIC(38,6),
		[List Price]			NUMERIC(38,6),
		[Selling Rate]			NUMERIC(38,6),
		[Claim Rate]			NUMERIC(38,6),
		[Effective From Date]   DATETIME
	) XMLObj

	SELECT * FROM ETL_Prk_PrdBatchDetails
	
	EXEC sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-209-017

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBillTemplateFinal]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC PROC_RptBillTemplateFinal 16,1,0,'NVSPLRATE20100119',0,0,1,'RPTBT_VIEW_FINAL_BILLTEMPLATE'

CREATE PROCEDURE [dbo].[Proc_RptBillTemplateFinal]
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT,
	@Pi_BTTblName   	NVARCHAR(50)
)
AS
/***************************************************************************************************
* PROCEDURE	: Proc_RptBillTemplateFinal
* PURPOSE	: General Procedure
* NOTES		: 	
* CREATED	:
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
* 01.10.2009		Panneer	   Added Tax summary Report Part(UserId Condition)
****************************************************************************************************/
SET NOCOUNT ON
BEGIN

	--Added By Murugan 04/09/2009
	DECLARE @FieldCount AS INT
	DECLARE @UomStatus AS INT	
	DECLARE @UOMCODE AS nVARCHAR(25)
	DECLARE @pUOMID as INT
	DECLARE @UomFieldList as nVARCHAR(3000)
	DECLARE @UomFields as nVARCHAR(3000)
	DECLARE @UomFields1 as nVARCHAR(3000)
	--END

	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @sSql		AS 	nVarChar(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	Declare @Sub_Val 	AS	TINYINT
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @FromBillNo 	AS  	BIGINT
	DECLARE @TOBillNo   	AS  	BIGINT
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @vFieldName   	AS	nvarchar(255)
	DECLARE @vFieldType	AS	nvarchar(10)
	DECLARE @vFieldLength	as	nvarchar(10)
	DECLARE @FieldList	as      nvarchar(4000)
	DECLARE @FieldTypeList	as	varchar(8000)
	DECLARE @FieldTypeList2 as	varchar(8000)
	DECLARE @DeliveredBill 	AS	INT
	DECLARE @SSQL1 AS NVARCHAR(4000)
	DECLARE @FieldList1	as      nvarchar(4000)

	--For B&L Bill Print Configurtion
	SELECT @DeliveredBill=Status FROM  Configuration WHERE ModuleName='Discount & Tax Collection' AND ModuleId='DISTAXCOLL5'
	IF @DeliveredBill=1
	BEGIN		
		DELETE FROM RptBillToPrint WHERE [Bill Number] IN(
		SELECT SalInvNo FROM SalesInvoice WHERE DlvSts NOT IN(4,5))
	END
	--Till Here

	--Added By Murugan 04/09/2009
	SET @FieldCount=0
	SELECT @UomStatus=Isnull(Status,0) FROM configuration  WHERE ModuleName='General Configuration' and ModuleId='GENCONFIG22' and SeqNo=22
	--Till Here
	SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
	SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
	DECLARE CurField CURSOR FOR
	select sc.name fieldname,st.name fieldtype,sc.length from syscolumns sc, systypes st
	where sc.id in (select id from sysobjects where name like @Pi_BTTblName )
	and sc.xtype = st.xtype
	and sc.xusertype = st.xusertype
	Set @FieldList = ''
	Set @FieldTypeList = ''
	OPEN CurField
	FETCH CurField INTO @vFieldName,@vFieldType,@vFieldLength
	WHILE @@Fetch_Status = 0
	BEGIN
		if len(@FieldTypeList) > 3000
		begin
			Set @FieldTypeList2 = @FieldTypeList
			Set @FieldTypeList = ''
		end
		--->Added By Nanda on 12/03/2010
		IF LEN(@FieldList)>3000
		BEGIN
			SET @FieldList1=@FieldList
			SET @FieldList=''
		END
		--->Till Here
		if @vFieldName = 'UsrId'
		begin
			Set @FieldList = @FieldList  + 'V.[' + @vFieldName + '] , '
		end
		else
		begin
			Set @FieldList = @FieldList  + '[' + @vFieldName + '] , '
		end
		if @vFieldType = 'nvarchar' or @vFieldType = 'varchar' or @vFieldType = 'char'
		begin
			Set @FieldTypeList = @FieldTypeList + '[' + @vFieldName + '] ' + @vFieldType + '(' + @vFieldLength + ')' + ','
		end
		else if @vFieldType = 'numeric'
		begin
			Set @FieldTypeList = @FieldTypeList + '[' + @vFieldName + '] ' + @vFieldType + '(38,2)' + ','
		end
		else
		begin
			Set @FieldTypeList = @FieldTypeList + '[' + @vFieldName + '] ' + @vFieldType + ','
		end
		FETCH CurField INTO @vFieldName,@vFieldType,@vFieldLength
	END
	Set @FieldList = left(@FieldList,len(@FieldList)-1)
	Set @FieldTypeList = left(@FieldTypeList,len(@FieldTypeList)-1)
	CLOSE CurField
	DEALLOCATE CurField

	--Added by Murugan UomCoversion 04/09/2009
	IF @UomStatus=1
	BEGIN	
		TRUNCATE TABLE BillTemplateUomBased	
		SET @UomFieldList=''
		SET @UomFields=''
		SET @UomFields1=''
		SET @FieldCount= @FieldCount+1	
		DECLARE CUR_UOM CURSOR
		FOR SELECT UOMID,UOMCODE FROM UOMMASTER  Order BY UOMID
		OPEN CUR_UOM
		FETCH NEXT FROM CUR_UOM INTO @pUOMID,@UOMCODE
		WHILE @@FETCH_STATUS=0
		BEGIN
			SET @FieldCount= @FieldCount+1
			SET @UomFieldList=@UomFieldList+'['+@UOMCODE +'] INT,'
			SET @UomFields=@UomFields+'0 AS ['+@UOMCODE +'],'
			SET @UomFields1=@UomFields1+'['+@UOMCODE +'],'	
			INSERT INTO BillTemplateUomBased(ColId,UOMID,UomCode)
			VALUES (@FieldCount,@pUOMID,@UOMCODE)
	
		FETCH NEXT FROM CUR_UOM INTO @pUOMID,@UOMCODE
		END	
		CLOSE CUR_UOM
		DEALLOCATE CUR_UOM
		SET @UomFieldList= subString(@UomFieldList,1,Len(Ltrim(rtrim(@UomFieldList)))-1)
		SET @UomFields= subString(@UomFields,1,Len(Ltrim(rtrim(@UomFields)))-1)
		SET @UomFields1= subString(@UomFields1,1,Len(Ltrim(rtrim(@UomFields1)))-1)		
		
	END
	-----

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplateFinal]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [RptBillTemplateFinal]
	IF @UomStatus=1
	BEGIN	
		Exec('CREATE TABLE RptBillTemplateFinal
		(' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500),'+ @UomFieldList +')')
	END
	ELSE
	BEGIN
		Exec('CREATE TABLE RptBillTemplateFinal
		(' +  @FieldTypeList2 + @FieldTypeList  + ',AmtInWrd nVarchar(500))')
	END
	SET @TblName = 'RptBillTemplateFinal'
	SET @TblStruct = @FieldTypeList2 + @FieldTypeList
	SET @TblFields = @FieldTypeList2 + @FieldTypeList
	IF @Pi_GetFromSnap = 1
	BEGIN
		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
		SET @DBNAME =   @DBNAME
	END
	ELSE
	BEGIN
		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo =3
		SET @DBNAME = @PI_DBNAME + @DBNAME
	END
	
	--Nanda01
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		Delete from RptBillTemplateFinal Where UsrId = @Pi_UsrId
		IF @UomStatus=1
		BEGIN
			EXEC ('INSERT INTO RptBillTemplateFinal (' + @FieldList1+@FieldList + ','+ @UomFields1 + ')' +
			'Select  DISTINCT' + @FieldList1+@FieldList +','+ @UomFields+'  from ' + @Pi_BTTblName + ' V,RptBillToPrint T Where V.[Sales Invoice Number] = T.[Bill Number]')
		END
		ELSE
		BEGIN
			--SELECT 'Nanda002'	
			Exec ('INSERT INTO RptBillTemplateFinal (' +@FieldList1+ @FieldList + ')' +
			'Select  DISTINCT' + @FieldList1+ @FieldList + '  from ' + @Pi_BTTblName + ' V,RptBillToPrint T Where V.[Sales Invoice Number] = T.[Bill Number]')
		END
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO RptBillTemplateFinal ' +
				'(' + @TblFields + ')' +
			' SELECT DISTINCT' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName + ' Where UsrId = ' + @Pi_UsrId
		
			EXEC (@SSQL)
			PRINT @SSQL
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM RptBillTemplateFinal'
		
				EXEC (@SSQL)
				PRINT 'Saved Data Into SnapShot Table'
			   END
		   END
	END
	--Nanda02
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		   BEGIN
			SET @SSQL = 'INSERT INTO RptBillTemplateFinal ' +
				'(' + @TblFields + ')' +
				' SELECT DISTINCT' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
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
	--Update SplitUp Tax Amount & Perc
	IF @UomStatus=1
	BEGIN	
		EXEC Proc_BillTemplateUOM @Pi_UsrId
	END
--	EXEC Proc_BillPrintingTax @Pi_UsrId
		
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 1')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 1]=BillPrintTaxTemp.[Tax1Perc]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount1')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount1]=BillPrintTaxTemp.[Tax1Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 2')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 2]=BillPrintTaxTemp.[Tax2Perc],[RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount2')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount2]=BillPrintTaxTemp.[Tax2Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 3')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 3]=BillPrintTaxTemp.[Tax3Perc]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount3')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount3] =BillPrintTaxTemp.[Tax3Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 4')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 4]=BillPrintTaxTemp.[Tax4Perc],[RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount4')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount4]=BillPrintTaxTemp.[Tax4Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax 5')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax 5]=BillPrintTaxTemp.[Tax5Perc],[RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Tax Amount5')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Tax Amount5]=BillPrintTaxTemp.[Tax5Amount]
		FROM BillPrintTaxTemp WHERE [RptBillTemplateFinal].SalId=BillPrintTaxTemp.[SalId] AND [RptBillTemplateFinal].[Product Code]=BillPrintTaxTemp.[PrdCode]
		AND [RptBillTemplateFinal].[Batch Code] =BillPrintTaxTemp.[BatchCode]'
		EXEC (@SSQL1)
	END
	--Till Here

	--- Sl No added  ---
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Product SL No')
	BEGIN
		SET @SSQL1='UPDATE [RptBillTemplateFinal] SET [RptBillTemplateFinal].[Product SL No]=SalesInvoiceProduct.[SlNo]
		FROM SalesInvoiceProduct,Product,ProductBatch WHERE [RptBillTemplateFinal].SalId=SalesInvoiceProduct.[SalId] AND [RptBillTemplateFinal].[Product Code]=Product.[PrdCCode]
		AND Product.Prdid=SalesInvoiceProduct.prdid
		And ProductBatch.Prdid=Product.Prdid and ProductBatch.PrdBatid=SalesInvoiceProduct.PrdBatId
		AND [RptBillTemplateFinal].[Batch Code] =ProductBatch.[PrdBatCode]'

		EXEC (@SSQL1)
	END	
	--- End Sl No

	--->Added By Nanda on 2011/02/24 for Henkel
	if not exists (Select Id,name from Syscolumns where name = 'Product Weight' and id in (Select id from 
		Sysobjects where name ='RptBillTemplateFinal'))
	begin
		ALTER TABLE [dbo].[RptBillTemplateFinal]
		ADD [Product Weight] NUMERIC(38,6) NULL DEFAULT 0 WITH VALUES
	END
	
	if not exists (Select Id,name from Syscolumns where name = 'Product UPC' and id in (Select id from 
		Sysobjects where name ='RptBillTemplateFinal'))
	begin
		ALTER TABLE [dbo].[RptBillTemplateFinal]
		ADD [Product UPC] NUMERIC(38,6) NULL DEFAULT 0 WITH VALUES
	END
	
	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Product Weight')
	BEGIN
		SET @SSQL1='UPDATE Rpt SET Rpt.[Product Weight]=P.PrdWgt*(CASE P.PrdUnitId WHEN 2 THEN Rpt.[Base Qty]/1000 ELSE Rpt.[Base Qty] END)
		FROM Product P,RptBillTemplateFinal Rpt WHERE P.PrdCCode=Rpt.[Product Code] AND P.PrdUnitId IN (2,3)'

		EXEC (@SSQL1)
	END

	IF Exists(SELECT Name FROM dbo.sysColumns where id = object_id(N'RptBillTemplateFinal') and name='Product UPC')
	BEGIN
		SET @SSQL1='UPDATE Rpt SET Rpt.[Product UPC]=Rpt.[Base Qty]/P.ConversionFactor 
					FROM 
					(
						SELECT P.PrdId,P.PrdCCode,MAX(U.ConversionFactor)AS ConversionFactor FROM Product P,UOMGroup U
						WHERE P.UOMGroupId=U.UOMGroupId
						GROUP BY P.PrdId,P.PrdCCode
					) P,RptBillTemplateFinal Rpt WHERE P.PrdCCode=Rpt.[Product Code]'
		EXEC (@SSQL1)
	END
	--->Till Here

	--Check for Report Data
	Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM RptBillTemplateFinal
	-- Till Here

	Delete From RptBillTemplate_Tax Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_Other Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_Replacement Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_CrDbAdjustment Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_MarketReturn Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_SampleIssue Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_Scheme Where UsrId = @Pi_UsrId
	Delete From RptBillTemplate_PrdUOMDetails Where UsrId = @Pi_UsrId
	---------------------------------TAX (SubReport)

	Select @Sub_Val = TaxDt  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)
		SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId
		FROM SalesInvoiceProductTax SI , TaxConfiguration T,SalesInvoice S,RptBillToPrint B
		WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc
	End

	------------------------------ Other
	Select @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)
		SELECT SI.SalId,S.SalInvNo,
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,
		Adjamt Amount,@Pi_UsrId
		FROM SalInvOtherAdj SI,PurSalAccConfig P,SalesInvoice S,RptBillToPrint B
		WHERE P.TransactionId = 2
		and SI.AccDescId = P.AccDescId
		and SI.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
	End

	---------------------------------------Replacement
	Select @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId
		FROM ReplacementHd H, ReplacementOut D, Product P, ProductBatch PB,SalesInvoice SI,RptBillToPrint B
		WHERE H.SalId <> 0
		and H.RepRefNo = D.RepRefNo
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = SI.SalId
		and SI.SalInvNo = B.[Bill Number]
	End

	----------------------------------Credit Debit Adjus
	Select @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_CrDbAdjustment(SalId,SalInvNo,NoteNumber,Amount,UsrId)
		Select A.SalId,S.SalInvNo,CrNoteNumber,A.CrAdjAmount,@Pi_UsrId
		from SalInvCrNoteAdj A,SalesInvoice S,RptBillToPrint B
		Where A.SalId = s.SalId
		and S.SalInvNo = B.[Bill Number]
		Union All
		Select A.SalId,S.SalInvNo,DbNoteNumber,A.DbAdjAmount,@Pi_UsrId
		from SalInvDbNoteAdj A,SalesInvoice S,RptBillToPrint B
		Where A.SalId = s.SalId
		and S.SalInvNo = B.[Bill Number]
	End

	---------------------------------------Market Return
	Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_MarketReturn(Type,SalId,SalInvNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Amount,UsrId)
		Select 'Market Return' Type ,H.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,BaseQty,PrdNetAmt,@Pi_UsrId
		From ReturnHeader H,ReturnProduct D,Product P,ProductBatch PB,SalesInvoice S,RptBillToPrint B
		Where returntype = 1
		and H.ReturnID = D.ReturnID
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
		Union ALL
		Select 'Market Return Free Product' Type,D.SalId,S.SalInvNo,D.PrdId,P.PrdName,
		D.PrdBatId,PB.PrdBatCode,D.BaseQty,GrossAmount,@Pi_UsrId
		From ReturnPrdHdForScheme D,Product P,ProductBatch PB,SalesInvoice S,RptBillToPrint B,ReturnHeader H,ReturnProduct T
		WHERE returntype = 1 AND
		D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = T.SalId
		and H.ReturnID = T.ReturnID
		and S.SalInvNo = B.[Bill Number]
	End

	------------------------------ SampleIssue
	Select @Sub_Val = SampleIssue FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		Insert into RptBillTemplate_SampleIssue(SalId,SalInvNo,SchId,SchCode,SchName,PrdId,PrdCCode,CmpId,CmpCode,
		CmpName,PrdDCode,PrdShrtName,PrdBatId,PrdBatCode,UomId,UomCode,Qty,TobeReturned,DueDate,UsrId)
		SELECT A.SalId,C.SalInvNo,D.SchId,D.SchCode,D.SchDsc,B.PrdId,
		E.PrdCCode,E.CmpId,F.CmpCode,F.CmpName,E.PrdDCode,E.PrdShrtName,B.PrdBatId,G.PrdBatCode,
		B.IssueUomID,H.UomCode,B.IssueQty,CASE B.TobeReturned WHEN 0 THEN 'No' ELSE 'Yes' END AS TobeReturned,
		B.DueDate,@Pi_UsrId
		FROM SampleIssueHd A WITH (NOLOCK)
		INNER JOIN SampleIssueDt B WITH(NOLOCK)ON A.IssueId=B.IssueID
		INNER JOIN SalesInvoice C WITH(NOLOCK)ON A.SalId=C.SalId
		INNER JOIN SampleSchemeMaster D WITH(NOLOCK)ON B.SchId=D.SchId
		INNER JOIN Product E WITH (NOLOCK) ON B.PrdID=E.PrdId
		INNER JOIN Company F WITH (NOLOCK) ON E.CmpId=F.CmpId
		INNER JOIN ProductBatch G WITH (NOLOCK) ON E.PrdID=G.PrdID AND B.PrdBatId=G.PrdBatId
		INNER JOIN UOMMaster H WITH (NOLOCK) ON B.IssueUomID=H.UomID
		INNER JOIN RptBillToPrint I WITH (NOLOCK) ON C.SalInvNo=I.[Bill Number]
	End

	--->Added By Nanda on 10/03/2010
	------------------------------ Scheme
	Select @Sub_Val = [Scheme] FROM BillTemplateHD WHERE TempName=SUBSTRING(@Pi_BTTblName,18,LEN(@Pi_BTTblName))
	If @Sub_Val = 1
	Begin
		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemeValue,SchemeCumulativePoints,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISL.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',
		0,'',0,0,SUM(SISL.DiscountPerAmount+SISL.FlatAmount),0,0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceSchemeLineWise SISL,SchemeMaster SM,RptBillToPrint RBT
		WHERE SISL.SchId=SM.SchId AND SI.SalId=SISL.SalId AND RBT.[Bill Number]=SI.SalInvNo
		GROUP BY SI.SalId,SI.SalInvNo,SISL.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc
		HAVING SUM(SISL.DiscountPerAmount+SISL.FlatAmount)>0

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemeValue,SchemeCumulativePoints,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.FreePrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.FreePrdBatId,PB.PrdBatCode,SISFP.FreeQty,PBD.PrdBatDetailValue,SISFP.FreeQty*PBD.PrdBatDetailValue,0,0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceSchemeDtFreePrd SISFP,SchemeMaster SM,RptBillToPrint RBT,Product P,ProductBatch PB,
		ProductBatchDetails PBD,BatchCreation BC
		WHERE SISFP.SchId=SM.SchId AND SI.SalId=SISFP.SalId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.FreePrdId=P.PrdId AND SISFP.FreePrdBatId=PB.PrdBatId AND PB.PrdBatId=PBD.PrdBatId AND
		PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemeValue,SchemeCumulativePoints,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.GiftPrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.GiftPrdBatId,PB.PrdBatCode,SISFP.GiftQty,PBD.PrdBatDetailValue,SISFP.GiftQty*PBD.PrdBatDetailValue,0,0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceSchemeDtFreePrd SISFP,SchemeMaster SM,RptBillToPrint RBT,Product P,ProductBatch PB,
		ProductBatchDetails PBD,BatchCreation BC
		WHERE SISFP.SchId=SM.SchId AND SI.SalId=SISFP.SalId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.GiftPrdId=P.PrdId AND SISFP.GiftPrdBatId=PB.PrdBatId AND PB.PrdBatId=PBD.PrdBatId AND
		PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1

		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemeValue,SchemeCumulativePoints,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SIWD.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,0,'','','','',
		0,'',0,0,SUM(SIWD.AdjAmt),0,0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceWindowDisplay SIWD,SchemeMaster SM,RptBillToPrint RBT
		WHERE SIWD.SchId=SM.SchId AND SI.SalId=SIWD.SalId AND RBT.[Bill Number]=SI.SalInvNo
		GROUP BY SI.SalId,SI.SalInvNo,SIWD.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc
		UPDATE RPT SET SalInvSchemeValue=A.SalInvSchemeValue
		FROM RptBillTemplate_Scheme RPT,(SELECT SalId,SUM(SchemeValueInAmt) AS SalInvSchemeValue FROM RptBillTemplate_Scheme GROUP BY SalId)A
		WHERE A.SAlId=RPT.SalId

		--->Added By Jay on 09/12/2010
		INSERT INTO RptBillTemplate_Scheme(SalId,SalInvNo,SchId,SchType,CmpSchCode,SchCode,SchName,PrdId,PrdCCode,PrdDCode,
		PrdShrtName,PrdName,PrdBatId,PrdBatCode,Qty,Rate,SchemeValueInAmt,SchemeValueInPoints,SalInvSchemeValue,SchemeCumulativePoints,UsrId)
		SELECT SI.SalId,SI.SalInvNo,SISFP.SchId,(CASE SM.SchType WHEN 1 THEN 'Quantity' WHEN 2 THEN 'Amount' WHEN 3 THEN 'Weight'
		WHEN 4 THEN 'Window Display' END),SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.PrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,P.PrdName,
		SISFP.PrdBatId,PB.PrdBatCode,0,PBD.PrdBatDetailValue,0,SUM(Points),0,0,@Pi_UsrId
		FROM SalesInvoice SI,SalesInvoiceSchemeDtPoints SISFP,SchemeMaster SM,
		RptBillToPrint RBT,Product P,ProductBatch PB,ProductBatchDetails PBD,BatchCreation BC
		WHERE SI.SalId=SISFP.SalId AND SISFP.SchId=SM.SchId AND RBT.[Bill Number]=SI.SalInvNo
		AND SISFP.PrdId=P.PrdId AND SISFP.PrdBatId=PB.PrdBatId AND RBT.UsrId=@Pi_UsrId
		AND PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.BatchSeqId=BC.BatchSeqId AND BC.SlNo=PBD.SlNo AND BC.SelRte=1 AND LEN(SISFP.ReDimRefId)=0		
		GROUP BY SI.SalId,SI.SalInvNo,SISFP.SchId,SM.SchType,SM.CmpSchCode,SM.SchCode,SM.SchDsc,SISFP.PrdId,P.PrdCCode,P.PrdDCode,P.PrdShrtName,
		P.PrdName,SISFP.PrdBatId,PB.PrdBatCode,PBD.PrdBatDetailValue
		--->Till Here

		--->Added By Nanda on 22/12/2010 
		UPDATE R SET SchemeCumulativePoints=A.CumulativePoints
		FROM RptBillTemplate_Scheme R,SalesInvoice SI,
		(SELECT SI.RtrId,SISP.SchId,SUM(SISP.Points-SISP.ReturnPoints) AS CumulativePoints
		FROM SalesInvoiceSchemeDtPoints SISP
		INNER JOIN SalesInvoice SI ON SI.SalId=SISP.SalId AND SI.DlvSts<>3
		--INNER JOIN RptBillToPrint R ON R.[Bill Number]=SI.SalInvNo
		GROUP BY SI.RtrId,SISP.SchId) A
		WHERE R.SalId=SI.SalId AND A.RtrId=SI.RtrId
		--->Till Here		
	End
	--->Till Here	

	--->Added By Nanda on 14/03/2011
	------------------------------ Prd UOM Details
	INSERT INTO RptBillTemplate_PrdUOMDetails(SalId,SalInvNo,TotPrdVolume,TotPrdKG,TotPrdLtrs,TotPrdUnits,
	TotPrdDrums,TotPrdCartons,TotPrdBuckets,TotPrdPieces,TotPrdBags,UsrId)	
	SELECT SalId,SalInvNo,SUM(TotPrdVolume) AS TotPrdVolume,SUM(TotPrdKG) AS TotPrdKG,SUM(TotPrdLtrs) AS TotPrdLtrs,SUM(TotPrdUnits) AS TotPrdUnits,
	SUM(TotPrdDrums) AS TotPrdDrums,SUM(TotPrdCartons) AS TotPrdCartons,SUM(TotPrdBuckets) AS TotPrdBuckets,SUM(TotPrdPieces) AS TotPrdPieces,SUM(TotPrdBags) AS TotPrdBags,@Pi_UsrId
	FROM
	(
		SELECT DISTINCT SI.SalId,SI.SalInvNo,SIP.PrdId,SIP.BaseQty*dbo.Fn_ReturnProductVolumeInLtrs(SIP.PrdId) AS TotPrdVolume,
		SIP.BaseQty*P.PrdUpSKU * (CASE P.PrdUnitId WHEN 2 THEN .001 WHEN 3 THEN 1 ELSE 0 END) AS TotPrdKG,
		SIP.BaseQty * P.PrdWgt * (CASE P.PrdUnitId WHEN 4 THEN .001 WHEN 5 THEN 1 ELSE 0 END) AS TotPrdLtrs,
		SIP.BaseQty*(CASE P.PrdUnitId WHEN 1 THEN 0 ELSE 0 END) AS TotPrdUnits,
		(CASE ISNULL(UMP1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP1.UOM1Qty,0) END)+
		(CASE ISNULL(UMP2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP2.UOM2Qty,0) END) AS TotPrdPieces,
		(CASE ISNULL(UMBU1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU1.UOM1Qty,0) END)+
		(CASE ISNULL(UMBU2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU2.UOM2Qty,0) END) AS TotPrdBuckets,
		(CASE ISNULL(UMBA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA1.UOM1Qty,0) END)+
		(CASE ISNULL(UMBA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA2.UOM2Qty,0) END) AS TotPrdBags,
		(CASE ISNULL(UMDR1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR1.UOM1Qty,0) END)+
		(CASE ISNULL(UMDR2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR2.UOM2Qty,0) END) AS TotPrdDrums,
		(CASE ISNULL(UMCA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA1.UOM1Qty,0) END)+
		(CASE ISNULL(UMCA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA2.UOM2Qty,0) END)+ 
		CEILING((CASE ISNULL(UMCN1.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN1.UOM1Qty,0) AS NUMERIC(38,6))/CAST(UGC1.ConvFact AS NUMERIC(38,6)) END))+
		CEILING((CASE ISNULL(UMCN2.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN2.UOM2Qty,0) AS NUMERIC(38,6))/CAST(UGC2.ConvFact AS NUMERIC(38,6)) END)) AS TotPrdCartons
 
		FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
		INNER JOIN RptBillToPrint Rpt ON SI.SalInvNo = Rpt.[Bill Number] AND Rpt.UsrId=@Pi_UsrId
		INNER JOIN Product P ON SIP.PrdID=P.PrdID
		INNER JOIN ProductBatch PB ON SIP.PrdBatID=PB.PrdBatID AND P.PrdID=PB.PrdId
		LEFT OUTER JOIN SalesInvoiceProduct SIPP1 ON SI.SalId=SIPP1.SalId AND SIP.PrdID=SIPP1.PrdID AND SIP.PrdBatID=SIPP1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPP2 ON SI.SalId=SIPP2.SalId AND SIP.PrdID=SIPP2.PrdID AND SIP.PrdBatID=SIPP2.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPBU1 ON SI.SalId=SIPBU1.SalId AND SIP.PrdID=SIPBU1.PrdID AND SIP.PrdBatID=SIPBU1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPBU2 ON SI.SalId=SIPBU2.SalId AND SIP.PrdID=SIPBU2.PrdID AND SIP.PrdBatID=SIPBU2.PrdBatID		
		LEFT OUTER JOIN SalesInvoiceProduct SIPBA1 ON SI.SalId=SIPBA1.SalId AND SIP.PrdID=SIPBA1.PrdID AND SIP.PrdBatID=SIPBA1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPBA2 ON SI.SalId=SIPBA2.SalId AND SIP.PrdID=SIPBA2.PrdID AND SIP.PrdBatID=SIPBA2.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPDR1 ON SI.SalId=SIPDR1.SalId AND SIP.PrdID=SIPDR1.PrdID AND SIP.PrdBatID=SIPDR1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPDR2 ON SI.SalId=SIPDR2.SalId AND SIP.PrdID=SIPDR2.PrdID AND SIP.PrdBatID=SIPDR2.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPCA1 ON SI.SalId=SIPCA1.SalId AND SIP.PrdID=SIPCA1.PrdID AND SIP.PrdBatID=SIPCA1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPCA2 ON SI.SalId=SIPCA2.SalId AND SIP.PrdID=SIPCA2.PrdID AND SIP.PrdBatID=SIPCA2.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPCN1 ON SI.SalId=SIPCN1.SalId AND SIP.PrdID=SIPCN1.PrdID AND SIP.PrdBatID=SIPCN1.PrdBatID
		LEFT OUTER JOIN SalesInvoiceProduct SIPCN2 ON SI.SalId=SIPCN2.SalId AND SIP.PrdID=SIPCN2.PrdID AND SIP.PrdBatID=SIPCN2.PrdBatID

		LEFT OUTER JOIN UOMMaster UMP1 ON UMP1.UOMId=SIPP1.UOM1Id AND UMP1.UOMDescription='PIECES'
		LEFT OUTER JOIN UOMMaster UMP2 ON UMP1.UOMId=SIPP2.UOM2Id AND UMP2.UOMDescription='PIECES'
		LEFT OUTER JOIN UOMMaster UMBU1 ON UMBU1.UOMId=SIPBU1.UOM1Id AND UMBU1.UOMDescription='BUCKETS' 
		LEFT OUTER JOIN UOMMaster UMBU2 ON UMBU1.UOMId=SIPBU2.UOM2Id AND UMBU2.UOMDescription='BUCKETS'
		LEFT OUTER JOIN UOMMaster UMBA1 ON UMBA1.UOMId=SIPBA1.UOM1Id AND UMBA1.UOMDescription='BAGS' 
		LEFT OUTER JOIN UOMMaster UMBA2 ON UMBA1.UOMId=SIPBA2.UOM2Id AND UMBA2.UOMDescription='BAGS'
		LEFT OUTER JOIN UOMMaster UMDR1 ON UMDR1.UOMId=SIPDR1.UOM1Id AND UMDR1.UOMDescription='DRUMS' 
		LEFT OUTER JOIN UOMMaster UMDR2 ON UMDR1.UOMId=SIPDR2.UOM2Id AND UMDR2.UOMDescription='DRUMS'
		LEFT OUTER JOIN UOMMaster UMCA1 ON UMCA1.UOMId=SIPCA1.UOM1Id AND UMCA1.UOMDescription='CARTONS' 
		LEFT OUTER JOIN UOMMaster UMCA2 ON UMCA1.UOMId=SIPCA2.UOM2Id AND UMCA2.UOMDescription='CARTONS'
		LEFT OUTER JOIN UOMMaster UMCN1 ON UMCN1.UOMId=SIPCN1.UOM1Id AND UMCN1.UOMDescription='CANS' 
		LEFT OUTER JOIN UOMMaster UMCN2 ON UMCN1.UOMId=SIPCN2.UOM2Id AND UMCN2.UOMDescription='CANS'
		LEFT OUTER JOIN (
		SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG
		WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN ( 
		SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )
		GROUP BY P.PrdID) UGC1 ON SIPCN1.PrdId=UGC1.PrdID
		LEFT OUTER JOIN (
		SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG
		WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN ( 
		SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )
		GROUP BY P.PrdID) UGC2 ON SIPCN2.PrdId=UGC2.PrdID
	) A
	GROUP BY SalId,SalInvNo
	--->Till Here
	
	--->Added By Nanda on 23/03/2010-For Grouping the details based on product for nondrug products
	IF EXISTS(SELECT * FROM Configuration WHERE ModuleId='BotreeBillPrinting01' AND ModuleName='Botree Bill Printing' AND Status=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplateFinal_Group]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
		DROP TABLE [RptBillTemplateFinal_Group]
		SELECT * INTO RptBillTemplateFinal_Group FROM RptBillTemplateFinal
		DELETE FROM RptBillTemplateFinal
		INSERT INTO RptBillTemplateFinal
		(
			[SalId],[Sales Invoice Number],[Product Code],[Product Name],[Product Short Name],[Product SL No],[Product Type],[Scheme Points],
			[Base Qty],[Batch Code],[Batch Expiry Date],[Batch Manufacturing Date],
			[Batch MRP],[Batch Selling Rate],[Bill Date],[Bill Doc Ref. Number],[Bill Mode],[Bill Type],
			[CD Disc Base Qty Amount],[CD Disc Effect Amount],
			[CD Disc Header Amount],[CD Disc LineUnit Amount],
			[CD Disc Qty Percentage],[CD Disc Unit Percentage],
			[CD Disc UOM Amount],[CD Disc UOM Percentage],
			[DB Disc Base Qty Amount],[DB Disc Effect Amount],
			[DB Disc Header Amount],[DB Disc LineUnit Amount],
			[DB Disc Qty Percentage],[DB Disc Unit Percentage],
			[DB Disc UOM Amount],[DB Disc UOM Percentage],
			[Line Base Qty Amount],[Line Base Qty Percentage],
			[Line Effect Amount],[Line Unit Amount],
			[Line Unit Percentage],[Line UOM1 Amount],[Line UOM1 Percentage],
			[Manual Free Qty],
			[Sch Disc Base Qty Amount],[Sch Disc Effect Amount],
			[Sch Disc Header Amount],[Sch Disc LineUnit Amount],
			[Sch Disc Qty Percentage],[Sch Disc Unit Percentage],
			[Sch Disc UOM Amount],[Sch Disc UOM Percentage],
			[Spl. Disc Base Qty Amount],[Spl. Disc Effect Amount],
			[Spl. Disc Header Amount],[Spl. Disc LineUnit Amount],
			[Spl. Disc Qty Percentage],[Spl. Disc Unit Percentage],
			[Spl. Disc UOM Amount],[Spl. Disc UOM Percentage],
			[Tax 1],[Tax 2],[Tax 3],[Tax 4],
			[Tax Amount1],[Tax Amount2],[Tax Amount3],[Tax Amount4],
			[Tax Amt Base Qty Amount],[Tax Amt Effect Amount],
			[Tax Amt Header Amount],[Tax Amt LineUnit Amount],
			[Tax Amt Qty Percentage],[Tax Amt Unit Percentage],
			[Tax Amt UOM Amount],[Tax Amt UOM Percentage],
			[Uom 1 Desc],[Uom 1 Qty],[Uom 2 Desc],[Uom 2 Qty],[Vehicle Name],
			[SalesInvoice ActNetRateAmount],[SalesInvoice CDPer],[SalesInvoice CRAdjAmount],[SalesInvoice DBAdjAmount],[SalesInvoice GrossAmount],
			[SalesInvoice Line Gross Amount],[SalesInvoice Line Net Amount],
			[SalesInvoice MarketRetAmount],[SalesInvoice NetAmount],[SalesInvoice NetRateDiffAmount],
			[SalesInvoice OnAccountAmount],[SalesInvoice OtherCharges],[SalesInvoice RateDiffAmount],[SalesInvoice ReplacementDiffAmount],[SalesInvoice RoundOffAmt],
			[SalesInvoice TotalAddition],[SalesInvoice TotalDeduction],[SalesInvoice WindowDisplayAmount],[SalesMan Code],[SalesMan Name],
			[Route Code],[Route Name],
			[Retailer Address1],[Retailer Address2],[Retailer Address3],[Retailer Code],[Retailer ContactPerson],[Retailer Coverage Mode],
			[Retailer Credit Bills],[Retailer Credit Days],[Retailer Credit Limit],[Retailer CSTNo],[Retailer Deposit Amount],[Retailer Drug ExpiryDate],
			[Retailer Drug License No],[Retailer EmailId],[Retailer GeoLevel],[Retailer License ExpiryDate],[Retailer License No],[Retailer Name],
			[Retailer OffPhone1],[Retailer OffPhone2],[Retailer OnAccount],[Retailer Pestcide ExpiryDate],[Retailer Pestcide LicNo],[Retailer PhoneNo],
			[Retailer Pin Code],[Retailer ResPhone1],[Retailer ResPhone2],[Retailer Ship Address1],[Retailer Ship Address2],[Retailer Ship Address3],
			[Retailer ShipId],[Retailer TaxType],[Retailer TINNo],[Retailer Village],[Tax Type],[TIN Number],
			[Company Address1],[Company Address2],[Company Address3],[Company Code],[Company Contact Person],
			[Company EmailId],[Company Fax Number],[Company Name],[Company Phone Number],[Contact Person],[CST Number],
			[DC DATE],[DC NUMBER],[Delivery Boy],[Delivery Date],[Deposit Amount],
			[Distributor Address1],[Distributor Address2],[Distributor Address3],[Distributor Code],[Distributor Name],
			[Drug Batch Description],[Drug Licence Number 1],[Drug Licence Number 2],[Drug1 Expiry Date],[Drug2 Expiry Date],
			[EAN Code],[EmailID],[Geo Level],[Interim Sales],[Licence Number],
			[LST Number],[Order Date],[Order Number],
			[Pesticide Expiry Date],[Pesticide Licence Number],[PhoneNo],[PinCode],[Remarks],
			[UsrId],[Visibility],[AmtInWrd]
		)		
		SELECT
		[SalId],
		[Sales Invoice Number],
		[Product Code],[Product Name],[Product Short Name],MIN([Product SL No]) AS [Product SL No],[Product Type],[Scheme Points],
		SUM([Base Qty]) AS [Base Qty],
		'' AS [Batch Code],MAX([Batch Expiry Date]) AS [Batch Expiry Date],MIN([Batch Manufacturing Date]) AS [Batch Manufacturing Date],
		[Batch MRP],[Batch Selling Rate],[Bill Date],[Bill Doc Ref. Number],[Bill Mode],[Bill Type],
		SUM([CD Disc Base Qty Amount]) AS [CD Disc Base Qty Amount],SUM([CD Disc Effect Amount]) AS [CD Disc Effect Amount],
		SUM(DISTINCT [CD Disc Header Amount]) AS [CD Disc Header Amount],SUM([CD Disc LineUnit Amount]) AS [CD Disc LineUnit Amount],
		--SUM([CD Disc Qty Percentage]) AS [CD Disc Qty Percentage],SUM([CD Disc Unit Percentage]) AS [CD Disc Unit Percentage],
		[CD Disc Qty Percentage],[CD Disc Unit Percentage],
		SUM([CD Disc UOM Amount]),SUM([CD Disc UOM Percentage]) AS [CD Disc UOM Percentage],
		SUM([DB Disc Base Qty Amount]) AS [DB Disc Base Qty Amount],SUM([DB Disc Effect Amount]) AS [DB Disc Effect Amount],
		SUM(DISTINCT [DB Disc Header Amount]) AS [DB Disc Header Amount],SUM([DB Disc LineUnit Amount]) AS [DB Disc LineUnit Amount],
		--SUM([DB Disc Qty Percentage]) AS [DB Disc Qty Percentage],SUM([DB Disc Unit Percentage]) AS [DB Disc Unit Percentage],
		[DB Disc Qty Percentage],SUM([DB Disc Unit Percentage]),
		SUM([DB Disc UOM Amount]) AS [DB Disc UOM Amount],SUM([DB Disc UOM Percentage]) AS [DB Disc UOM Percentage],
		SUM([Line Base Qty Amount]) AS [Line Base Qty Amount],SUM([Line Base Qty Percentage]) AS [Line Base Qty Percentage],
		SUM([Line Effect Amount]) AS [Line Effect Amount],
		--SUM([Line Unit Amount]) AS [Line Unit Amount],
		[Line Unit Amount],
		SUM([Line Unit Percentage]) AS [Line Unit Percentage],SUM([Line UOM1 Amount]) AS [Line UOM1 Amount],SUM([Line UOM1 Percentage]) AS [Line UOM1 Percentage],
		SUM([Manual Free Qty]),
		SUM([Sch Disc Base Qty Amount]) AS [Sch Disc Base Qty Amount],SUM([Sch Disc Effect Amount]) AS [Sch Disc Effect Amount],
		SUM(DISTINCT [Sch Disc Header Amount]) AS [Sch Disc Header Amount],SUM([Sch Disc LineUnit Amount]) AS [Sch Disc LineUnit Amount],
		--SUM([Sch Disc Qty Percentage]) AS [Sch Disc Qty Percentage],SUM([Sch Disc Unit Percentage]) AS [Sch Disc Unit Percentage],
		[Sch Disc Qty Percentage],[Sch Disc Unit Percentage],
		SUM([Sch Disc UOM Amount]) AS [Sch Disc UOM Amount],SUM([Sch Disc UOM Percentage]) AS [Sch Disc UOM Percentage],
		SUM([Spl. Disc Base Qty Amount]) AS [Spl. Disc Base Qty Amount],SUM([Spl. Disc Effect Amount]) AS [Spl. Disc Effect Amount],
		SUM(DISTINCT [Spl. Disc Header Amount]) AS [Spl. Disc Header Amount],SUM([Spl. Disc LineUnit Amount]) AS [Spl. Disc LineUnit Amount],
		--SUM([Spl. Disc Qty Percentage]) AS [Spl. Disc Qty Percentage],SUM([Spl. Disc Unit Percentage]) AS [Spl. Disc Unit Percentage],
		[Spl. Disc Qty Percentage],[Spl. Disc Unit Percentage],
		SUM([Spl. Disc UOM Amount]) AS [Spl. Disc UOM Amount],SUM([Spl. Disc UOM Percentage]) AS [Spl. Disc UOM Percentage],
		--SUM([Tax 1]) AS [Tax 1],SUM([Tax 2]) AS [Tax 2],SUM([Tax 3]) AS [Tax 3],SUM([Tax 4]) AS [Tax 4],
		[Tax 1],[Tax 2],[Tax 3],[Tax 4],
		SUM([Tax Amount1]) AS [Tax Amount1],SUM([Tax Amount2]) AS [Tax Amount2],SUM([Tax Amount3]) AS [Tax Amount3],SUM([Tax Amount4]) AS [Tax Amount4],
		SUM([Tax Amt Base Qty Amount]) AS [Tax Amt Base Qty Amount],SUM([Tax Amt Effect Amount]) AS [Tax Amt Effect Amount],
		SUM(DISTINCT [Tax Amt Header Amount]) AS [Tax Amt Header Amount],SUM([Tax Amt LineUnit Amount]) AS [Tax Amt LineUnit Amount],
		SUM([Tax Amt Qty Percentage]) AS [Tax Amt Qty Percentage],SUM([Tax Amt Unit Percentage]) AS [Tax Amt Unit Percentage],
		SUM([Tax Amt UOM Amount]) AS [Tax Amt UOM Amount],SUM([Tax Amt UOM Percentage]) AS [Tax Amt UOM Percentage],
		'' AS [Uom 1 Desc],SUM([Base Qty]) AS [Uom 1 Qty],'' AS [Uom 2 Desc],0 AS [Uom 2 Qty],[Vehicle Name],
		[SalesInvoice ActNetRateAmount],[SalesInvoice CDPer],[SalesInvoice CRAdjAmount],[SalesInvoice DBAdjAmount],[SalesInvoice GrossAmount],
		SUM([SalesInvoice Line Gross Amount]) AS [SalesInvoice Line Gross Amount],SUM([SalesInvoice Line Net Amount]) AS [SalesInvoice Line Net Amount],
		[SalesInvoice MarketRetAmount],[SalesInvoice NetAmount],[SalesInvoice NetRateDiffAmount],
		[SalesInvoice OnAccountAmount],[SalesInvoice OtherCharges],[SalesInvoice RateDiffAmount],[SalesInvoice ReplacementDiffAmount],[SalesInvoice RoundOffAmt],
		[SalesInvoice TotalAddition],[SalesInvoice TotalDeduction],[SalesInvoice WindowDisplayAmount],[SalesMan Code],[SalesMan Name],
		[Route Code],[Route Name],
		[Retailer Address1],[Retailer Address2],[Retailer Address3],[Retailer Code],[Retailer ContactPerson],[Retailer Coverage Mode],
		[Retailer Credit Bills],[Retailer Credit Days],[Retailer Credit Limit],[Retailer CSTNo],[Retailer Deposit Amount],[Retailer Drug ExpiryDate],
		[Retailer Drug License No],[Retailer EmailId],[Retailer GeoLevel],[Retailer License ExpiryDate],[Retailer License No],[Retailer Name],
		[Retailer OffPhone1],[Retailer OffPhone2],[Retailer OnAccount],[Retailer Pestcide ExpiryDate],[Retailer Pestcide LicNo],[Retailer PhoneNo],
		[Retailer Pin Code],[Retailer ResPhone1],[Retailer ResPhone2],[Retailer Ship Address1],[Retailer Ship Address2],[Retailer Ship Address3],
		[Retailer ShipId],[Retailer TaxType],[Retailer TINNo],[Retailer Village],[Tax Type],[TIN Number],
		[Company Address1],[Company Address2],[Company Address3],[Company Code],[Company Contact Person],
		[Company EmailId],[Company Fax Number],[Company Name],[Company Phone Number],[Contact Person],[CST Number],
		[DC DATE],[DC NUMBER],[Delivery Boy],[Delivery Date],[Deposit Amount],
		[Distributor Address1],[Distributor Address2],[Distributor Address3],[Distributor Code],[Distributor Name],
		[Drug Batch Description],[Drug Licence Number 1],[Drug Licence Number 2],[Drug1 Expiry Date],[Drug2 Expiry Date],
		[EAN Code],[EmailID],[Geo Level],[Interim Sales],[Licence Number],
		[LST Number],[Order Date],[Order Number],
		[Pesticide Expiry Date],[Pesticide Licence Number],[PhoneNo],[PinCode],[Remarks],
		[UsrId],[Visibility],[AmtInWrd]
		FROM RptBillTemplateFinal_Group,Product P
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType<>5
		GROUP BY [Batch MRP],[Batch Selling Rate],[Bill Date],[Bill Doc Ref. Number],[Bill Mode],[Bill Type],
		[Company Address1],[Company Address2],[Company Address3],[Company Code],[Company Contact Person],
		[Company EmailId],[Company Fax Number],[Company Name],[Company Phone Number],[Contact Person],[CST Number],
		[DC DATE],[DC NUMBER],[Delivery Boy],[Delivery Date],[Deposit Amount],
		[Distributor Address1],[Distributor Address2],[Distributor Address3],[Distributor Code],[Distributor Name],
		[Drug Batch Description],[Drug Licence Number 1],[Drug Licence Number 2],[Drug1 Expiry Date],[Drug2 Expiry Date],
		[EAN Code],[EmailID],[Geo Level],[Interim Sales],[Licence Number],
		[LST Number],
		[Order Date],[Order Number],
		[Pesticide Expiry Date],[Pesticide Licence Number],[PhoneNo],[PinCode],
		[Product Code],[Product Name],[Product Short Name],[Product Type],
		[Remarks],
		[Retailer Address1],[Retailer Address2],[Retailer Address3],[Retailer Code],[Retailer ContactPerson],[Retailer Coverage Mode],
		[Retailer Credit Bills],[Retailer Credit Days],[Retailer Credit Limit],[Retailer CSTNo],[Retailer Deposit Amount],[Retailer Drug ExpiryDate],
		[Retailer Drug License No],[Retailer EmailId],[Retailer GeoLevel],[Retailer License ExpiryDate],[Retailer License No],[Retailer Name],
		[Retailer OffPhone1],[Retailer OffPhone2],[Retailer OnAccount],[Retailer Pestcide ExpiryDate],[Retailer Pestcide LicNo],[Retailer PhoneNo],
		[Retailer Pin Code],[Retailer ResPhone1],[Retailer ResPhone2],[Retailer Ship Address1],[Retailer Ship Address2],[Retailer Ship Address3],
		[Retailer ShipId],[Retailer TaxType],[Retailer TINNo],[Retailer Village],
		[Route Code],[Route Name],
		[Sales Invoice Number],[SalesInvoice ActNetRateAmount],[SalesInvoice CDPer],[SalesInvoice CRAdjAmount],[SalesInvoice DBAdjAmount],[SalesInvoice GrossAmount],
		[SalesInvoice MarketRetAmount],[SalesInvoice NetAmount],[SalesInvoice NetRateDiffAmount],
		[SalesInvoice OnAccountAmount],[SalesInvoice OtherCharges],[SalesInvoice RateDiffAmount],[SalesInvoice ReplacementDiffAmount],[SalesInvoice RoundOffAmt],
		[SalesInvoice TotalAddition],[SalesInvoice TotalDeduction],[SalesInvoice WindowDisplayAmount],[SalesMan Code],[SalesMan Name],
		[SalId],
		[Scheme Points],
		[Tax Type],[TIN Number],
		[Vehicle Name],[Tax 1],[Tax 2],[Tax 3],[Tax 4],
		[CD Disc Qty Percentage],[CD Disc Unit Percentage],
		[DB Disc Qty Percentage],--[DB Disc Unit Percentage],
		[Line Unit Amount],
		[Sch Disc Qty Percentage],[Sch Disc Unit Percentage],
		[Spl. Disc Qty Percentage],[Spl. Disc Unit Percentage],		
		[UsrId],[Visibility],[AmtInWrd]
		UNION ALL
		SELECT [SalId],[Sales Invoice Number],[Product Code],[Product Name],[Product Short Name],[Product SL No],[Product Type],[Scheme Points],
		[Base Qty],[Batch Code],[Batch Expiry Date],[Batch Manufacturing Date],
		[Batch MRP],[Batch Selling Rate],[Bill Date],[Bill Doc Ref. Number],[Bill Mode],[Bill Type],
		[CD Disc Base Qty Amount],[CD Disc Effect Amount],
		[CD Disc Header Amount],[CD Disc LineUnit Amount],
		[CD Disc Qty Percentage],[CD Disc Unit Percentage],
		[CD Disc UOM Amount],[CD Disc UOM Percentage],
		[DB Disc Base Qty Amount],[DB Disc Effect Amount],
		[DB Disc Header Amount],[DB Disc LineUnit Amount],
		[DB Disc Qty Percentage],[DB Disc Unit Percentage],
		[DB Disc UOM Amount],[DB Disc UOM Percentage],
		[Line Base Qty Amount],[Line Base Qty Percentage],
		[Line Effect Amount],[Line Unit Amount],
		[Line Unit Percentage],[Line UOM1 Amount],[Line UOM1 Percentage],
		[Manual Free Qty],
		[Sch Disc Base Qty Amount],[Sch Disc Effect Amount],
		[Sch Disc Header Amount],[Sch Disc LineUnit Amount],
		[Sch Disc Qty Percentage],[Sch Disc Unit Percentage],
		[Sch Disc UOM Amount],[Sch Disc UOM Percentage],
		[Spl. Disc Base Qty Amount],[Spl. Disc Effect Amount],
		[Spl. Disc Header Amount],[Spl. Disc LineUnit Amount],
		[Spl. Disc Qty Percentage],[Spl. Disc Unit Percentage],
		[Spl. Disc UOM Amount],[Spl. Disc UOM Percentage],
		[Tax 1],[Tax 2],[Tax 3],[Tax 4],
		[Tax Amount1],[Tax Amount2],[Tax Amount3],[Tax Amount4],
		[Tax Amt Base Qty Amount],[Tax Amt Effect Amount],
		[Tax Amt Header Amount],[Tax Amt LineUnit Amount],
		[Tax Amt Qty Percentage],[Tax Amt Unit Percentage],
		[Tax Amt UOM Amount],[Tax Amt UOM Percentage],
		[Uom 1 Desc],[Uom 1 Qty],[Uom 2 Desc],[Uom 2 Qty],[Vehicle Name],
		[SalesInvoice ActNetRateAmount],[SalesInvoice CDPer],[SalesInvoice CRAdjAmount],[SalesInvoice DBAdjAmount],[SalesInvoice GrossAmount],
		[SalesInvoice Line Gross Amount],[SalesInvoice Line Net Amount],
		[SalesInvoice MarketRetAmount],[SalesInvoice NetAmount],[SalesInvoice NetRateDiffAmount],
		[SalesInvoice OnAccountAmount],[SalesInvoice OtherCharges],[SalesInvoice RateDiffAmount],[SalesInvoice ReplacementDiffAmount],[SalesInvoice RoundOffAmt],
		[SalesInvoice TotalAddition],[SalesInvoice TotalDeduction],[SalesInvoice WindowDisplayAmount],[SalesMan Code],[SalesMan Name],
		[Route Code],[Route Name],
		[Retailer Address1],[Retailer Address2],[Retailer Address3],[Retailer Code],[Retailer ContactPerson],[Retailer Coverage Mode],
		[Retailer Credit Bills],[Retailer Credit Days],[Retailer Credit Limit],[Retailer CSTNo],[Retailer Deposit Amount],[Retailer Drug ExpiryDate],
		[Retailer Drug License No],[Retailer EmailId],[Retailer GeoLevel],[Retailer License ExpiryDate],[Retailer License No],[Retailer Name],
		[Retailer OffPhone1],[Retailer OffPhone2],[Retailer OnAccount],[Retailer Pestcide ExpiryDate],[Retailer Pestcide LicNo],[Retailer PhoneNo],
		[Retailer Pin Code],[Retailer ResPhone1],[Retailer ResPhone2],[Retailer Ship Address1],[Retailer Ship Address2],[Retailer Ship Address3],
		[Retailer ShipId],[Retailer TaxType],[Retailer TINNo],[Retailer Village],[Tax Type],[TIN Number],
		[Company Address1],[Company Address2],[Company Address3],[Company Code],[Company Contact Person],
		[Company EmailId],[Company Fax Number],[Company Name],[Company Phone Number],[Contact Person],[CST Number],
		[DC DATE],[DC NUMBER],[Delivery Boy],[Delivery Date],[Deposit Amount],
		[Distributor Address1],[Distributor Address2],[Distributor Address3],[Distributor Code],[Distributor Name],
		[Drug Batch Description],[Drug Licence Number 1],[Drug Licence Number 2],[Drug1 Expiry Date],[Drug2 Expiry Date],
		[EAN Code],[EmailID],[Geo Level],[Interim Sales],[Licence Number],
		[LST Number],[Order Date],[Order Number],
		[Pesticide Expiry Date],[Pesticide Licence Number],[PhoneNo],[PinCode],[Remarks],
		[UsrId],[Visibility],[AmtInWrd]
		FROM RptBillTemplateFinal_Group,Product P
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5
	END	
	--->Till Here

	IF EXISTS (SELECT A.SalId FROM SalInvoiceDeliveryChallan A INNER JOIN SalesInvoice B
				ON A.SalId=B.SalId INNER JOIN RptBillToPrint C ON C.[Bill Number]=SalInvNo)
	BEGIN
		TRUNCATE TABLE RptFinalBillTemplate_DC
		INSERT INTO RptFinalBillTemplate_DC(SalId,InvNo,DCNo,DCDate)
		SELECT A.SalId,B.SalInvNo,A.DCNo,DCDate FROM SalInvoiceDeliveryChallan A INNER JOIN SalesInvoice B
		ON A.SalId=B.SalId INNER JOIN RptBillToPrint C ON C.[Bill Number]=SalInvNo
	END
	ELSE
	BEGIN
		TRUNCATE TABLE RptFinalBillTemplate_DC
	END

	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-209-019

DELETE FROM Configuration WHERE ModuleId='PO36' AND ModuleName='Purchase Order'

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo) 
VALUES('PO36','Purchase Order','Display total volume of order (KG + Ltr + Unit)',0,'',0.00,36)

--SRF-Nanda-209-020

DELETE FROM RptHeader WHERE RptId=219

INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
VALUES('StockReportHieararchy','Hierarchywise Stock and Sales Report - Volume Wise',219,'Hierarchywise Stock and Sales Report - Volume Wise','Proc_RptStockandSalesVolumeHierarchy','RptStockandSalesVolumeHierarchy','RptStockandSalesVolumeHierarchy.Rpt','')

DELETE FROM RptGroup WHERE RptId=219

INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName)
VALUES('StockReports',219,'StockReportHieararchy','Hieararchy Stock And Sales volume Report')

DELETE FROM RptDetails WHERE RptId=219

INSERT RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('219','1','FromDate','-1',NULL,'','From Date*',NULL,'1',NULL,'10',NULL,NULL,'Enter To Date','0')

INSERT RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('219','2','ToDate','-1',NULL,'','To Date*',NULL,'1',NULL,'11',NULL,NULL,'Enter From Date','0')

INSERT RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('219','3','Company','-1',NULL,'CmpId,CmpCode,CmpName','Company*...',NULL,'1',NULL,'4',1,1,'Press F4/Double Click to Select Company','0')

INSERT RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('219','4','Location','-1',NULL,'LcnId,LcnCode,LcnName','Location...',NULL,'1',NULL,'22',NULL,NULL,'Press F4/Double Click to Select Location','0')

INSERT RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('219','5','ProductCategoryLevel','3','CmpId','CmpPrdCtgId,LevelName,CmpPrdCtgName','Product Hierarchy Level*...','Company','1','CmpId','16','1',1,'Press F4/Double Click to Select Product Hierarchy Level','1')

INSERT RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('219','6','RptFilter','-1',NULL,'FilterId,FilterDesc,FilterDesc','Include Offer Stock*...',NULL,'1',NULL,'202','1','1','Press F4/Double Click to Select Include Offer Stock option','0')

INSERT RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('219','7','RptFilter','-1',NULL,'FilterId,FilterDesc,FilterDesc','Display Stock Value as per*...',NULL,'1',NULL,'23','1','1','Press F4/Double Click to Select the Stock Value as per','0')

INSERT RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) 
VALUES('219','8','RptFilter','-1',NULL,'FilterId,FilterDesc,FilterDesc','Suppress Zero Stock*...',NULL,'1',NULL,'44','1','1','Press F4/Double Click to Select the Supress Zero Stock','0')

DELETE FROM RptFilter WHERE RptId=219

INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
VALUES(219,23,1,'Selling Rate')

INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
VALUES(219,23,2,'List Price')

INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
VALUES(219,23,3,'MRP')

INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
VALUES(219,44,1,'Yes')

INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
VALUES(219,44,2,'No')

INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
VALUES(219,202,1,'Yes')

INSERT INTO RptFilter(RptId,SelcId,FilterId,FilterDesc)
VALUES(219,202,2,'No')

DELETE FROM RptFormula WHERE RptId=219

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'1','Cap From Date','From Date','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'2','From Date','From Date','1','10')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'3','Cap To Date','To Date','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'4','To Date','To Date','1','11')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'5','Cap Company','Company','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'6','Company','Company','1','4')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'7','Cap Location','Location','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'8','Location','Location','1','22')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'9','Cap Product Hierarchy Level','Product Hierarchy Level','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'10','Product Hierarchy Level','Product Hierarchy Level','1','16')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'11','Fill_Stockasper','Stock Value as per','1','23')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'12','Disp_Stockasper','Stock Value as per','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'13','Disp_SupZeroStock','Suppress Zero Stock','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'14','Fill_SupZeroStock','Suppress Zero Stock','1','44')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'15','Disp_IncOfferStock','Suppress Zero Stock','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'16','Fill_IncOfferStock','Suppress Zero Stock','1','202')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'17','Cap Page','Page','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'18','Cap User Name','User Name','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'19','Cap Print Date','Date','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'20','PrdCtgValName','Hierarchy Name','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'21','LcnName','Location Name','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'21','Opening Stock','Opening Stock','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'22','Purchase','Purchase','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'23','Sales','Sales','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'24','AdjustmentIn','Adjustment-In','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'25','AdjustmentOut','Adjustment-Out','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'26','Purchase Return','Purchase Return','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'27','Sales Return','Sales Return','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'28','Closing Stock','Closing Stock','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'29','ClosingStkValue','Closing Stock Value','1','0')

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId) 
VALUES(219,'30','PrdWeight','Weight In Ton','1','0')

--SRF-Nanda-209-021

if exists (select * from dbo.sysobjects where id = object_id(N'[RptStockandSalesVolumeHierarchy_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptStockandSalesVolumeHierarchy_Excel]
GO

CREATE TABLE [dbo].[RptStockandSalesVolumeHierarchy_Excel]
(
	PrdCtgValMainId			INT,  
	PrdCtgValCode			NVARCHAR(200),  
	PrdCtgValName			NVARCHAR(200),  
	CmpId					INT,  
	CmpName					NVARCHAR(50),  
	LcnId					INT,  
	LcnName					NVARCHAR(50),   
	OpeningStock			NUMERIC(38,0),    
	Purchase				NUMERIC (38,0),  
	Sales					NUMERIC (38,0),  
	AdjustmentIn			NUMERIC (38,0),  
	AdjustmentOut			NUMERIC (38,0),  
	PurchaseReturn			NUMERIC (38,0),  
	SalesReturn				NUMERIC (38,0),    
	ClosingStock			NUMERIC (38,0),  
	ClosingStkValue			NUMERIC (38,6),
	PrdWeight				NUMERIC (38,6),
	PrdCtgValLinkCode		NVARCHAR(100)  
) ON [PRIMARY]
GO

--SRF-Nanda-209-022

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptRetailerAccountStatement]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptRetailerAccountStatement]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptRetailerAccountStatement 217,2,0,'',0,0,1

CREATE	PROCEDURE [dbo].[Proc_RptRetailerAccountStatement]
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
BEGIN
SET NOCOUNT ON
/****************************************************************************
* PROCEDURE: Proc_RptRetailerAccountStatement
* PURPOSE: General Procedure
* NOTES:
* CREATED: MarySubashini.S	23-06-2010
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
* 14.10.2010   Panneer    Excel Report Value Mismatch
* 20-OCT-2010	Jayakumar N		Changes done after discussion made with kanagaraj regarding CreditNote & DebitNote posting	
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
	DECLARE @RtrId				AS	INT
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))


	UPDATE RptFormula SET FormulaValue=RtrCode 
	FROM Retailer WHERE RtrId=@RtrId AND RptId=@Pi_RptId AND SlNo=17

	UPDATE RptFormula SET FormulaValue=RtrPhoneNo 
	FROM Retailer WHERE RtrId=@RtrId AND RptId=@Pi_RptId AND SlNo=18

--	Added by Jay on 20-OCT-2010
	DECLARE @SLRHD AS NVARCHAR(50)
	DECLARE @RTNHD AS NVARCHAR(50)
	SELECT @SLRHD=Prefix FROM Counters WHERE TabName='ReturnHeader'
	SET @SLRHD=@SLRHD + '%'
	SELECT @RTNHD=Prefix FROM Counters WHERE TabName='ReplacementHd'
	SET @RTNHD=@RTNHD + '%'
--	End here

	CREATE    TABLE #RptRetailerAccountStatement
	(
		SlNo			INT NULL,
		RtrId			INT NULL,
		CoaId			INT NULL,
		RtrName			NVARCHAR(100) NULL,
		RtrAddress		NVARCHAR(400) NULL,
		RtrTINNo		NVARCHAR(50) NULL,
		InvDate			DATETIME NULL,
		DocumentNo		NVARCHAR(100) NULL,
		Details			NVARCHAR(400) NULL,
		RefNo			NVARCHAR(100) NULL,
		DbAmount		NUMERIC(38, 6) NULL,
		CrAmount		NUMERIC(38, 6) NULL,
		BalanceAmount	NUMERIC(38, 6) NULL
	)
		SET @TblName = 'RptRetailerAccountStatement'
		SET @TblStruct = '	SlNo			INT NULL,
							RtrId			INT NULL,
							CoaId			INT NULL,
							RtrName			NVARCHAR(100) NULL,
							RtrAddress		NVARCHAR(400) NULL,
							RtrTINNo		NVARCHAR(50) NULL,
							InvDate			DATETIME NULL,
							DocumentNo		NVARCHAR(100) NULL,
							Details			NVARCHAR(400) NULL,
							RefNo			NVARCHAR(100) NULL,
							DbAmount		NUMERIC(38, 6) NULL,
							CrAmount		NUMERIC(38, 6) NULL,
							BalanceAmount	NUMERIC(38, 6) NULL'
	SET @TblFields = '	SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,
						DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount'
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
		EXEC Proc_RetailerAccountStment @FromDate,@ToDate,@RtrId
		INSERT INTO #RptRetailerAccountStatement (	SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,
													DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
		
			SELECT SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,
				RefNo,Round(DbAmount,3) DbAmount,
				Round(CrAmount,3) CrAmount,
				(CASE SlNo WHEN 1 THEN BalanceAmount ELSE (ROund(DbAmount,3)- Round(CrAmount,3))END)
			FROM TempRetailerAccountStatement 
			WHERE RefNo NOT LIKE @RTNHD AND RefNo NOT LIKE @SLRHD OR RefNo IS NOT NULL

		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptRetailerAccountStatement ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptRetailerAccountStatement'
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		   END
	END
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		   BEGIN
			SET @SSQL = 'INSERT INTO #RptRetailerAccountStatement ' +
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
	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId 
	FROM #RptRetailerAccountStatement 
    
		/* Excel report */
			DECLARE @BalAmt Numeric(18,2)
			SET @BalAmt = 0
			Select  @BalAmt = Sum(BalanceAmount)  
			FROM #RptRetailerAccountStatement WHERE Details <> 'Closing Balance'
			Update #RptRetailerAccountStatement SET BalanceAmount = @BalAmt 
			WHERE Details = 'Closing Balance'
			DELETE FROM RptRetailerAccStmtsExecl
			INSERT INTO RptRetailerAccStmtsExecl
			SELECT * from  #RptRetailerAccountStatement  
 
			DECLARE @LineBalAmt   Numeric(18,2)
			DECLARE @SlNo		  INT
			DECLARE @Amt		  Numeric(18,2)
			DECLARE @Details      nVarchar(100)		
			DECLARE @DocDetails   nVarchar(100)	

			DECLARE Balance_Cursor CURSOR
			FOR  	SELECT Slno,Details,BalanceAmount,DocumentNo
					FROM RptRetailerAccStmtsExecl where   Details <> 'Closing Balance' order by Slno,InvDate			  
			OPEN Balance_Cursor		
		
			FETCH NEXT FROM Balance_Cursor INTO  @SlNo,@Details,@Amt,@DocDetails
			SET @LineBalAmt = 0
			WHILE @@FETCH_STATUS = 0
			BEGIN	 		
					 SET @LineBalAmt = @LineBalAmt + @Amt
					 Update RptRetailerAccStmtsExecl SET BalanceAmount = Round(@LineBalAmt,3)
					 WHere SlNo = @SlNo	and Details = @Details and DocumentNo = @DocDetails
			FETCH NEXT FROM Balance_Cursor INTO   @SlNo,@Details,@Amt,@DocDetails
			END
			CLOSE Balance_Cursor
			DEALLOCATE Balance_Cursor 
					/* End Here  */		 
	SELECT * FROM RptRetailerAccStmtsExecl ORDER BY SlNo,InvDate
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


DELETE FROM RptFormula WHERE RptId=217 AND SlNo IN (17,18,19,20)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(217,17,'RtrCode','Retailer Code',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(217,18,'PhNo','Ph-',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(217,19,'RetailerCode','Retailer Code',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(217,20,'PhoneNo','Ph-',1,0)

--SRF-Nanda-209-023

DELETE FROM RptFormula WHERE RptId=217 AND SlNo IN (17,18,19,20)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(217,17,'RtrCode','Retailer Code',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(217,18,'PhNo','Ph-',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(217,19,'RetailerCode','Retailer Code',1,0)

INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
VALUES(217,20,'PhoneNo','Ph-',1,0)

--SRF-Nanda-209-024

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptRetailerAccountStatement]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptRetailerAccountStatement]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptRetailerAccountStatement 217,2,0,'',0,0,1

CREATE	PROCEDURE [dbo].[Proc_RptRetailerAccountStatement]
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
BEGIN
SET NOCOUNT ON
/****************************************************************************
* PROCEDURE: Proc_RptRetailerAccountStatement
* PURPOSE: General Procedure
* NOTES:
* CREATED: MarySubashini.S	23-06-2010
* MODIFIED
* DATE         AUTHOR     DESCRIPTION
------------------------------------------------------------------------------
* 14.10.2010   Panneer    Excel Report Value Mismatch
* 20-OCT-2010	Jayakumar N		Changes done after discussion made with kanagaraj regarding CreditNote & DebitNote posting	
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
	DECLARE @RtrId				AS	INT
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @RtrId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))


	UPDATE RptFormula SET FormulaValue=RtrCode 
	FROM Retailer WHERE RtrId=@RtrId AND RptId=@Pi_RptId AND SlNo=17

	UPDATE RptFormula SET FormulaValue=RtrPhoneNo 
	FROM Retailer WHERE RtrId=@RtrId AND RptId=@Pi_RptId AND SlNo=18

--	Added by Jay on 20-OCT-2010
	DECLARE @SLRHD AS NVARCHAR(50)
	DECLARE @RTNHD AS NVARCHAR(50)
	SELECT @SLRHD=Prefix FROM Counters WHERE TabName='ReturnHeader'
	SET @SLRHD=@SLRHD + '%'
	SELECT @RTNHD=Prefix FROM Counters WHERE TabName='ReplacementHd'
	SET @RTNHD=@RTNHD + '%'
--	End here

	CREATE    TABLE #RptRetailerAccountStatement
	(
		SlNo			INT NULL,
		RtrId			INT NULL,
		CoaId			INT NULL,
		RtrName			NVARCHAR(100) NULL,
		RtrAddress		NVARCHAR(400) NULL,
		RtrTINNo		NVARCHAR(50) NULL,
		InvDate			DATETIME NULL,
		DocumentNo		NVARCHAR(100) NULL,
		Details			NVARCHAR(400) NULL,
		RefNo			NVARCHAR(100) NULL,
		DbAmount		NUMERIC(38, 6) NULL,
		CrAmount		NUMERIC(38, 6) NULL,
		BalanceAmount	NUMERIC(38, 6) NULL
	)
		SET @TblName = 'RptRetailerAccountStatement'
		SET @TblStruct = '	SlNo			INT NULL,
							RtrId			INT NULL,
							CoaId			INT NULL,
							RtrName			NVARCHAR(100) NULL,
							RtrAddress		NVARCHAR(400) NULL,
							RtrTINNo		NVARCHAR(50) NULL,
							InvDate			DATETIME NULL,
							DocumentNo		NVARCHAR(100) NULL,
							Details			NVARCHAR(400) NULL,
							RefNo			NVARCHAR(100) NULL,
							DbAmount		NUMERIC(38, 6) NULL,
							CrAmount		NUMERIC(38, 6) NULL,
							BalanceAmount	NUMERIC(38, 6) NULL'
	SET @TblFields = '	SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,
						DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount'
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
		EXEC Proc_RetailerAccountStment @FromDate,@ToDate,@RtrId
		INSERT INTO #RptRetailerAccountStatement (	SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,
													DocumentNo,Details,RefNo,DbAmount,CrAmount,BalanceAmount)
		
			SELECT SlNo,RtrId,CoaId,RtrName,RtrAddress,RtrTINNo,InvDate,DocumentNo,Details,
				RefNo,Round(DbAmount,3) DbAmount,
				Round(CrAmount,3) CrAmount,
				(CASE SlNo WHEN 1 THEN BalanceAmount ELSE (ROund(DbAmount,3)- Round(CrAmount,3))END)
			FROM TempRetailerAccountStatement 
			WHERE RefNo NOT LIKE @RTNHD AND RefNo NOT LIKE @SLRHD OR RefNo IS NOT NULL

		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptRetailerAccountStatement ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptRetailerAccountStatement'
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		   END
	END
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		   BEGIN
			SET @SSQL = 'INSERT INTO #RptRetailerAccountStatement ' +
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
	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId 
	FROM #RptRetailerAccountStatement 
    
		/* Excel report */
			DECLARE @BalAmt Numeric(18,2)
			SET @BalAmt = 0
			Select  @BalAmt = Sum(BalanceAmount)  
			FROM #RptRetailerAccountStatement WHERE Details <> 'Closing Balance'
			Update #RptRetailerAccountStatement SET BalanceAmount = @BalAmt 
			WHERE Details = 'Closing Balance'
			DELETE FROM RptRetailerAccStmtsExecl
			INSERT INTO RptRetailerAccStmtsExecl
			SELECT * from  #RptRetailerAccountStatement  
 
			DECLARE @LineBalAmt   Numeric(18,2)
			DECLARE @SlNo		  INT
			DECLARE @Amt		  Numeric(18,2)
			DECLARE @Details      nVarchar(100)		
			DECLARE @DocDetails   nVarchar(100)	

			DECLARE Balance_Cursor CURSOR
			FOR  	SELECT Slno,Details,BalanceAmount,DocumentNo
					FROM RptRetailerAccStmtsExecl where   Details <> 'Closing Balance' order by Slno,InvDate			  
			OPEN Balance_Cursor		
		
			FETCH NEXT FROM Balance_Cursor INTO  @SlNo,@Details,@Amt,@DocDetails
			SET @LineBalAmt = 0
			WHILE @@FETCH_STATUS = 0
			BEGIN	 		
					 SET @LineBalAmt = @LineBalAmt + @Amt
					 Update RptRetailerAccStmtsExecl SET BalanceAmount = Round(@LineBalAmt,3)
					 WHere SlNo = @SlNo	and Details = @Details and DocumentNo = @DocDetails
			FETCH NEXT FROM Balance_Cursor INTO   @SlNo,@Details,@Amt,@DocDetails
			END
			CLOSE Balance_Cursor
			DEALLOCATE Balance_Cursor 
					/* End Here  */		 
	SELECT * FROM RptRetailerAccStmtsExecl ORDER BY SlNo,InvDate
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-209-025

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RDDiscount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RDDiscount]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE  PROCEDURE [dbo].[Proc_RDDiscount]
(
	@Pi_RtrId		INT,
	@Pi_TransId		INT,
	@Pi_UsrId		INT
)
AS
BEGIN	
/*********************************				
* PROCEDURE: Proc_RDDiscount
* PURPOSE: RD and Key Account Discount Calculation
* NOTES:
* CREATED: Boopathy.P 26-09-2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
	DECLARE	@BillSeqId		INT
	DECLARE @RowId			INT
	DECLARE @RtrId			INT
	DECLARE @KeyGrpName		VARCHAR(100)
	DECLARE @KeyGrpId		INT
	DECLARE @CtgMainId		INT
	DECLARE @CtgLinkId		INT
	DECLARE @CtgLevelId		INT
	DECLARE @tempSchDt TABLE
	(
		RowId		INT,
		SchId		INT,
		PrdId		INT,
		PrdBatId	INT,
		SchemeAmount	NUMERIC(38,6),
		SchemeDiscount	NUMERIC(38,6)
	)
	DECLARE @tempClaimNo TABLE
	(
		RowId		INT,
		SchId		INT,
		PrdId		INT,
		PrdBatId	INT,
		SchemeAmount	NUMERIC(38,6),
		SchemeDiscount	NUMERIC(38,6)
	)
	DECLARE @tempClaimYes TABLE
	(
		RowId		INT,
		SchId		INT,
		PrdId		INT,
		PrdBatId	INT,
		SchemeAmount	NUMERIC(38,6),
		SchemeDiscount	NUMERIC(38,6)
	)
	DECLARE @SchDetails TABLE
	(
		PrdId		INT,
		PrdBatId	INT,
		Gross		NUMERIC(38,6),
		SchemeAmount	NUMERIC(38,6),
		SchemeDiscount	NUMERIC(38,6)
	)
	DECLARE @BilledPrdDtCalculatedTax TABLE
	(
		RowId			INT,
		PrdId			INT,
		PrdBatId		INT,
		TaxId			INT,
		TaxSlabId		INT,
		TaxPercentage	NUMERIC(38,6),
		TaxableAmount	NUMERIC(38,6),
		TaxAmount		NUMERIC(38,6),
		Usrid			INT,
		TransId			INT
	)
	DECLARE @ClmNoWithKeyAc TABLE
	(
		PrdId		INT,
		PrdBatId	INT,
		Gross		NUMERIC(38,6)
	)
	DECLARE @ClmYesWithKeyAc TABLE
	(
		PrdId		INT,
		PrdBatId	INT,
		Gross		NUMERIC(38,6)
	)
	
	DECLARE @BilledPrdHdForScheme TABLE
	(
		RowId		INT,
		RtrId		INT,
		PrdId		INT,
		PrdBatId	INT,
		SelRate		NUMERIC(38,6),
		BaseQty		INT,
		GrossAmount	NUMERIC(38,6),
		MRP			NUMERIC(38,6),
		TransId		TINYINT,
		Usrid		INT,
		ListPrice	NUMERIC(38,6)
	)
--	DELETE FROM Temp_RDDiscount WHERE UsrId = @Pi_Usrid AND TransId = @Pi_TransId
--	DELETE FROM Temp_RDClaimable WHERE UsrId = @Pi_Usrid AND TransId = @Pi_TransId
--	DELETE FROM Temp_KeyAcDiscount WHERE UsrId = @Pi_Usrid AND TransId = @Pi_TransId
--
--	SELECT @CtgMainId=CtgMainId,@CtgLinkId=CtgLinkId,@CtgLevelId=CtgLevelId FROM RetailerCategory 
--	WHERE CtgCode='RD'
--
--	IF (@Pi_TransId=2 OR @Pi_TransId=25)
--	BEGIN
--		INSERT INTO @BilledPrdHdForScheme
--		SELECT * FROM BilledPrdHdForScheme WHERE Transid=@Pi_TransId AND UsriD=@Pi_Usrid
--	END
--	ELSE
--	BEGIN
--		INSERT INTO @BilledPrdHdForScheme
--		SELECT A.RowId,A.RtrId,A.PrdId,A.PrdbatId,A.SelRate,B.RealQty ,
--		A.GrossAmount,A.MRP,A.TransId,A.UsrId,A.ListPrice FROM
--		BilledPrdHdForScheme A INNER JOIN ReturnPrdHdForScheme B
--		ON A.RowId=B.RowId AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
--		AND A.TransId=B.Transid AND A.UsrId=B.UsrId
--		WHERE A.Transid=@Pi_TransId AND A.UsriD=@Pi_Usrid
--	END
--	
--	IF EXISTS (SELECT R.RtrId,RC.CtgMainId,RC.CtgLinkId,RCL.CtgLevelId
--		FROM Retailer  R INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId and R.RtrId = @Pi_RtrId
--		INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
--		INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
--		INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId WHERE R.RtrId=@Pi_RtrId AND 
--		RC.CtgMainId=@CtgMainId AND RC.CtgLinkId=@CtgLinkId AND RC.CtgLevelId=@CtgLevelId)
--	BEGIN
--		SELECT @BillSeqId=MAX(BillSeqId) FROM BillSequenceMaster
--		
--		TRUNCATE TABLE BilledPrdDtCalculatedTax
--		TRUNCATE TABLE BilledPrdHdForTax
--		INSERT INTO BilledPrdHdForTax
--		SELECT DISTINCT B.RowId,@Pi_RtrId,B.PrdId,B.PrdBatId,1,@BillSeqId,@Pi_Usrid,@Pi_TransId,0 FROM
--		ApportionSchemeDetails A RIGHT OUTER JOIN @BilledPrdHdForScheme B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
--		AND A.UsrId=B.UsrId AND A.TransId=B.TransId
--		WHERE B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId
--		DECLARE  Cur_Tax CURSOR FOR
--		SELECT RowId FROM BilledPrdHdForTax WHERE UsrId = @Pi_Usrid AND TransId = @Pi_TransId
--		OPEN Cur_Tax
--		FETCH NEXT FROM Cur_Tax INTO @RowId
--		WHILE @@FETCH_STATUS = 0
--		BEGIN		
--				EXEC Proc_ComputeTaxForSRReCalculation @RowId,@Pi_TransId,@Pi_Usrid		
--				INSERT INTO @BilledPrdDtCalculatedTax
--					SELECT * FROM BilledPrdDtCalculatedTax WHERE UsrId = @Pi_Usrid
--					AND TransId = @Pi_TransId AND RowId=@RowId AND TaxPercentage>0
--			TRUNCATE TABLE BilledPrdDtCalculatedTax
--			FETCH NEXT FROM Cur_Tax INTO @RowId
--		END
--		CLOSE Cur_Tax
--		DEALLOCATE Cur_Tax
--		TRUNCATE TABLE BilledPrdDtCalculatedTax
--		INSERT INTO BilledPrdDtCalculatedTax
--		SELECT * FROM @BilledPrdDtCalculatedTax WHERE UsrId = @Pi_Usrid AND TransId = @Pi_TransId
--			INSERT INTO @SchDetails
--			SELECT A.PrdId,A.PrdBatId,Gross,A.SchemeAmount,A.SchemeDiscount FROM
--			(SELECT B.PrdId,B.PrdBatId,ISNULL(((((B.ListPrice * B.BaseQty) + ((B.ListPrice * B.BaseQty)*ISNULL(D.TaxAmount,0)/100)))),0) AS Gross,0 AS Contri,
--			ISNULL(SUM(A.SchemeAmount),0) AS SchemeAmount ,ISNULL(SUM(A.SchemeDiscount),0) AS SchemeDiscount --INTO #SchDetails
--			FROM  BilledPrdHdForScheme B LEFT OUTER JOIN ApportionSchemeDetails A
--			ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.Usrid=B.Usrid AND A.RowId=B.RowId
--			AND A.TransId=B.TransId LEFT OUTER JOIN BilledPrdDtCalculatedTax D ON B.PrdId=D.PrdId
--			AND B.PrdBatId=D.PrdBatId AND B.TransId=D.TransId AND B.Usrid=D.Usrid
--			WHERE B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId
--			GROUP BY B.PrdId,B.PrdBatId,B.ListPrice,B.BaseQty,D.TaxAmount) A
--			IF EXISTS (SELECT A.ColumnValue FROM UdcDetails A INNER JOIN @BilledPrdHdForScheme B
--						ON A.MasterRecordId=B.RtrId WHERE MasterRecordId=@Pi_RtrId AND B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId)
--			BEGIN
--				IF EXISTS (SELECT * FROM @BilledPrdHdForScheme WHERE RtrId=@Pi_RtrId AND UsrId = @Pi_Usrid
--							AND TransId = @Pi_TransId)
--				BEGIN
--					SELECT @KeyGrpName=ColumnValue FROM UdcDetails WHERE MasterRecordId=@Pi_RtrId
--					SELECT @KeyGrpId=GrpId FROM KeyGroupMaster WHERE GrpName=@KeyGrpName
--					
--					INSERT INTO @ClmNoWithKeyAc
--					SELECT B.PrdId,B.PrdBatId,((B.GrossAmount-C.DISC)*ISNULL(A.Disc,0)/100) AS ClaimValue
--					FROM @BilledPrdHdForScheme B LEFT OUTER JOIN KeyGroupDisc A ON A.PrdId=B.PrdId AND GrpId=@KeyGrpId
--					LEFT OUTER JOIN (SELECT A.PrdId,A.PrdBatId,ISNULL(A.SchemeAmount,0)+ISNUll(A.SchemeDiscount,0) AS DISC
--					FROM ApportionSchemeDetails A INNER JOIN SchemeMaster B ON A.SchId=B.SchId AND B.Claimable=0
--					WHERE A.UsrId = @Pi_Usrid	AND A.TransId = @Pi_TransId) C ON B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
--					WHERE B.RtrId=@Pi_RtrId AND B.UsrId = @Pi_Usrid	AND TransId = @Pi_TransId
--					INSERT INTO Temp_RDDiscount
--					SELECT A.PrdId,A.PrdBatId,0,((A.Gross*B.PrdBatDetailValue)/100),@Pi_TransId,@Pi_Usrid FROM
--					(SELECT  A.PrdId,A.PrdBatId,A.Gross-(ISNULL(A.SchemeAmount,0)+ISNULL(A.SchemeDiscount,0)+ISNULL(B.Gross,0)) AS Gross FROM @SchDetails A
--					LEFT OUTER JOIN @ClmNoWithKeyAc B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId) A INNER JOIN
--					ProductBatchDetails B ON A.PrdbatId=B.PrdBatId WHERE B.SLNo=8 AND B.DefaultPrice=1
--				
--					INSERT INTO Temp_RDClaimable
--					SELECT A.PrdId,B.PrdBatId,((B.Gross*A.Percentage)/100) As ClaimValue,@Pi_TransId,@Pi_Usrid
--					FROM RdClaimPercentage A INNER JOIN (SELECT  A.PrdId,A.PrdBatId,A.Gross-(ISNULL(A.SchemeAmount,0)+ISNULL(A.SchemeDiscount,0)+ISNULL(B.Gross,0)) AS Gross FROM @SchDetails A
--					LEFT OUTER JOIN @ClmNoWithKeyAc B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId) B ON A.PrdId=B.PrdId
--			END
--		END
--		ELSE
--		BEGIN
--			INSERT INTO Temp_RDDiscount
--			SELECT A.PrdId,A.PrdBatId,0,((A.Gross*B.PrdBatDetailValue)/100),@Pi_TransId,@Pi_Usrid FROM
--			@SchDetails A INNER JOIN ProductBatchDetails B ON A.PrdbatId=B.PrdBatId WHERE B.SLNo=8 AND B.DefaultPrice=1
--		
--			INSERT INTO Temp_RDClaimable
--			SELECT A.PrdId,B.PrdBatId,((B.Gross*A.Percentage)/100) As ClaimValue,@Pi_TransId,@Pi_Usrid
--			FROM RdClaimPercentage A INNER JOIN @SchDetails B ON 
--			A.PrdId=B.PrdId 
--		END
--			
--		select * from @schdetails
----EXEC Proc_RDDiscount 1318,2,2
----		
--	END
-------------------------------Key Account discount Calculation---------------------------------
--	IF EXISTS (SELECT A.ColumnValue FROM UdcDetails A INNER JOIN @BilledPrdHdForScheme B
--			   ON A.MasterRecordId=B.RtrId WHERE MasterRecordId=@Pi_RtrId)
--	BEGIN
--		IF EXISTS (SELECT * FROM @BilledPrdHdForScheme WHERE RtrId=@Pi_RtrId AND UsrId = @Pi_Usrid
--					AND TransId = @Pi_TransId)
--		BEGIN
--			SELECT @KeyGrpName=ColumnValue FROM UdcDetails WHERE MasterRecordId=@Pi_RtrId
--			SELECT @KeyGrpId=GrpId FROM KeyGroupMaster WHERE GrpName=@KeyGrpName
--			DELETE FROM @tempSchDt
--			INSERT INTO @tempSchDt
--			SELECT D.RowId,A.SchId,D.PrdId,D.PrdBatId,SUM(D.SchemeAmount) AS SchemeAmount,
--			SUM(D.SchemeDiscount) AS SchemeDiscount  FROM
--			SchemeMaster A WITH (NOLOCK) INNER JOIN ApportionSchemeDetails D
--			ON A.SchId=D.SchId WHERE A.Claimable=0
--			AND D.UsrId = @Pi_Usrid AND D.TransId = @Pi_TransId
--			GROUP BY D.RowId,A.SchId,D.PrdId,D.PrdBatId
--			IF EXISTS (SELECT * FROM @tempSchDt)
--			BEGIN
--				DELETE FROM @SchDetails
--				INSERT INTO @SchDetails
--				SELECT B.PrdId,B.PrdBatId,SUM(B.GrossAmount)-(ISNULL(SUM(A.SchemeAmount),0)+ISNULL(SUM(A.SchemeDiscount),0)) AS Gross,
--				ISNULL(SUM(A.SchemeAmount),0) AS SchemeAmount ,ISNULL(SUM(A.SchemeDiscount),0) AS SchemeDiscount
--				FROM ApportionSchemeDetails A RIGHT OUTER JOIN @BilledPrdHdForScheme B
--				ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.Usrid=B.Usrid AND A.RowId=B.RowId
--				AND A.TransId=B.TransId	RIGHT OUTER JOIN @tempSchDt E ON A.SchId=E.SchId AND A.PrdId=E.PrdId AND A.PrdBatId=E.PrdBatId
--				WHERE B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId
--				GROUP BY B.PrdId,B.PrdBatId
--				INSERT INTO Temp_KeyAcDiscount
--				SELECT B.PrdId,B.PrdBatId,
--				ISNULL((SUM(C.Gross)*ISNULL(A.Disc,0))/100,B.GrossAmount*ISNULL(A.Disc,0)/100) AS ClaimValue,
--				@Pi_TransId,@Pi_Usrid
--				FROM @BilledPrdHdForScheme B LEFT OUTER JOIN KeyGroupDisc A ON A.PrdId=B.PrdId AND GrpId=@KeyGrpId
--				LEFT OUTER JOIN @SchDetails C ON B.PrdId=C.PrdId AND B.PrdBatId=C.PrdBatId
--				WHERE B.RtrId=@Pi_RtrId AND B.UsrId = @Pi_Usrid	AND TransId = @Pi_TransId
--				GROUP BY B.PrdId,B.PrdBatId,A.Disc,B.GrossAmount
--			END
--			ELSE
--			BEGIN
--				INSERT INTO Temp_KeyAcDiscount
--				SELECT A.PrdId,B.PrdBatId,(B.GrossAmount*A.Disc)/100 AS ClaimValue,@Pi_TransId,@Pi_Usrid
--				FROM KeyGroupDisc A INNER JOIN @BilledPrdHdForScheme B ON A.PrdId=B.PrdId
--				WHERE B.RtrId=@Pi_RtrId AND B.UsrId = @Pi_Usrid	AND TransId = @Pi_TransId
--				AND GrpId=@KeyGrpId
--			END
--		END
--	END
--------------------------------------------------------------------------------------------------
--IF EXISTS (SELECT SchId FROM ApportionSchemeDetails WHERE UsrId = @Pi_Usrid AND TransId = @Pi_TransId)
--	BEGIN
--		IF EXISTS (SELECT A.SchId FROM SchemeMaster A INNER JOIN ApportionSchemeDetails B
--			ON A.SchId=B.SchId INNER JOIN SchemeRuleSettings C ON A.SchId = C.SchId
--			WHERE C.CalScheme=1 AND B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId)
--			BEGIN
--				SELECT A.SchId,B.SlabId INTO #tempSchDt FROM SchemeMaster A INNER JOIN ApportionSchemeDetails B
--				ON A.SchId=B.SchId INNER JOIN SchemeRuleSettings C ON A.SchId = C.SchId
--				WHERE C.CalScheme=1 AND B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId
--				SELECT SchId INTO #tmpOtherSch FROM ApportionSchemeDetails
--				WHERE SchId NOT IN (SELECT SchId FROM #tempSchDt) AND UsrId = @Pi_Usrid AND TransId = @Pi_TransId
--				IF EXISTS (SELECT * FROM #tmpOtherSch)
--				BEGIN
--				
--					SELECT B.PrdId,B.PrdBatId,B.GrossAmount-(SUM(A.SchemeAmount)+SUM(A.SchemeDiscount)) AS GrossAmt
--					INTO #TempSchemeDt FROM ApportionSchemeDetails A 
--					INNER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
--					AND A.Usrid=B.Usrid AND A.TransId=B.TransId INNER JOIN #tmpOtherSch C ON
--					A.SchId=C.SchId WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
--					GROUP BY B.PrdId,B.PrdBatId,B.GrossAmount
--					IF EXISTS (SELECT A.ColumnValue FROM UdcDetails A INNER JOIN @BilledPrdHdForScheme B
--							ON A.MasterRecordId=B.RtrId WHERE MasterRecordId=@Pi_RtrId)
--					BEGIN
--						IF EXISTS (SELECT * FROM @BilledPrdHdForScheme WHERE RtrId=@Pi_RtrId AND UsrId = @Pi_Usrid
--								AND TransId = @Pi_TransId)
--						BEGIN
--							SELECT @KeyGrpName=ColumnValue FROM UdcDetails WHERE MasterRecordId=@Pi_RtrId
--							SELECT @KeyGrpId=GrpId FROM KeyGroupMaster WHERE GrpName=@KeyGrpName
--							UPDATE B SET GrossAmt= GrossAmt -(GrossAmt*ISNULL(A.Disc,0)/100)
--							FROM #TempSchemeDt B LEFT OUTER JOIN KeyGroupDisc A ON A.PrdId=B.PrdId AND GrpId=@KeyGrpId
--						END
--					END
--					SELECT A.SchId,A.SlabId,A.SchemeAmount,A.SchemeDiscount,A.NoOfTimes
--					INTO #tempSchFinal FROM BillAppliedSchemeHd A INNER JOIN #tempSchDt B ON A.SchId=B.SchId
--					WHERE A.IsSelected = 1 AND A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId
--					UPDATE ApportionSchemeDetails SET SchemeAmount=(A.SchemeAmount),
--					SchemeDiscount=(C.GrossAmt*B.DiscPer/100) FROM #tempSchFinal A,
--					ApportionSchemeDetails B,#TempSchemeDt C WHERE A.SchId=B.SchId AND A.SlabId=B.SlabId AND 
--					C.PrdId=B.PrdId AND C.PrdBatId=B.PrdBatId AND B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId
--				END
--				ELSE IF EXISTS (SELECT * FROM #tempSchDt)
--				BEGIN 
--					IF EXISTS (SELECT A.ColumnValue FROM UdcDetails A INNER JOIN @BilledPrdHdForScheme B
--							ON A.MasterRecordId=B.RtrId WHERE MasterRecordId=@Pi_RtrId)
--					BEGIN
--						IF EXISTS (SELECT * FROM @BilledPrdHdForScheme WHERE RtrId=@Pi_RtrId AND UsrId = @Pi_Usrid
--								AND TransId = @Pi_TransId)
--						BEGIN
--							SELECT @KeyGrpName=ColumnValue FROM UdcDetails WHERE MasterRecordId=@Pi_RtrId
--							SELECT @KeyGrpId=GrpId FROM KeyGroupMaster WHERE GrpName=@KeyGrpName
--					UPDATE ApportionSchemeDetails SET SchemeAmount=(B.SchemeAmount),
--					SchemeDiscount=(C.GrossAmt*B.DiscPer/100) FROM 
--					ApportionSchemeDetails B INNER JOIN
--							(SELECT B.SchId,B.SlabId,A.PrdId,A.PrdBatId,
--							A.GrossAmount-(A.GrossAmount*ISNULL(C.Disc,0)/100) AS GrossAmt FROM BilledPrdHdForScheme A INNER JOIN 
--							ApportionSchemeDetails B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND 
--							A.TransId=B.TransId AND A.UsrId=B.UsrId LEFT OUTER JOIN KeyGroupDisc C
--							ON B.PrdId=C.PrdId AND C.GrpId=@KeyGrpId
--							WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId) C
--							ON  C.SchId=B.SchId AND C.SlabId=B.SlabId AND 
--					C.PrdId=B.PrdId AND C.PrdBatId=B.PrdBatId WHERE B.UsrId = @Pi_Usrid AND B.TransId = @Pi_TransId
--						END
--					END
--				END
--			END
--	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-209-026

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_DBDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_DBDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
DELETE FROM Cs2Cn_Prk_DBDetails
EXEC Proc_Cs2Cn_DBDetails 0
SELECT * FROM Cs2Cn_Prk_DBDetails
ROLLBACK TRANSACTION
*/

CREATE     PROCEDURE [dbo].[Proc_Cs2Cn_DBDetails]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DBDetails
* PURPOSE		: To Extract DataBase Details from CoreStocky to upload to Console
* CREATED BY	: Nandakumar R.G
* CREATED DATE	: 02/10/2010
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpId 			AS INT
	DECLARE @DistCode		AS nVarchar(50)
	DECLARE @DefCmpAlone	AS INT
	DECLARE @Idx			AS INT
	DECLARE @IP				AS VARCHAR(40)
	DECLARE @DBName			AS nVarchar(50)

	SET @Po_ErrNo=0

	DELETE FROM Cs2Cn_Prk_DBDetails WHERE UploadFlag = 'Y'

	SELECT @DistCode=DistributorCode FROM Distributor
	SELECT @DBName=DBName FROM CurrentDB
	
	EXEC Proc_Get_IP_Address @IP OUT

--	INSERT INTO Cs2Cn_Prk_DBDetails(DistCode,IPAddress,MachineName,DBId,DBName,DBCreatedDate,DBRestoredDate,DBRestoreId,DBFileName,UploadFlag)
--	SELECT @DistCode,@IP,@@ServerName,DBId,Name,CrDate,CrDate,0,FileName,'N' FROM Master.dbo.SysDataBases SD,CurrentDB CD
--	WHERE SD.Name=CD.DBName

	INSERT INTO Cs2Cn_Prk_DBDetails(DistCode,IPAddress,MachineName,DBId,DBName,DBCreatedDate,DBRestoredDate,DBRestoreId,DBFileName,UploadFlag)
	SELECT @DistCode+'~'+C.CmpCode,@IP,@@ServerName,DBId,Name,CrDate,CrDate,0,FileName,'N' 
	FROM Master.dbo.SysDataBases SD,CurrentDB CD,Company C
	WHERE SD.Name=CD.DBName AND C.DefaultCompany=1

	UPDATE B SET B.DBRestoredDate=A.Restore_Date,B.DBRestoreId=A.Restore_History_Id
	FROM Cs2Cn_Prk_DBDetails B,
	(SELECT * FROM MSDB..RestoreHistory RS
	WHERE RS.Destination_DataBase_Name=@DBName
	AND RS.Restore_Date IN (SELECT MAX(Restore_Date) FROM MSDB..RestoreHistory WHERE Destination_DataBase_Name= @DBName)) A
	WHERE B.DBName=A.Destination_DataBase_Name
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-209-027

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_YEGetOpenTrans]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_YEGetOpenTrans]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_YEGetOpenTrans '2008-04-01','2009-03-31'
--SELECT * FROM YearEndOpenTrans

CREATE     PROCEDURE [dbo].[Proc_YEGetOpenTrans]
(
	@Pi_FromDate 		DATETIME,
	@Pi_ToDate		DATETIME
)
AS
/*********************************
* PROCEDURE	: Proc_YEGetOpenTrans
* PURPOSE	: To get the Open transactions for Year End
* CREATED	: Nandakumar R.G
* CREATED DATE	: 09/03/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	TRUNCATE TABLE YearEndOpenTrans
	TRUNCATE TABLE YearEndLog
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 1,'Purchase','PurchaseReceipt',ISNULL(COUNT(*),0)
	FROM PurchaseReceipt
	WHERE Status=0 AND GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 1,'Purchase',PurRcptRefNo
	FROM PurchaseReceipt
	WHERE Status=0 AND GoodsRcvdDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 2,'Purchase Return','PurchaseReturn',ISNULL(COUNT(*),0)
	FROM PurchaseReturn
	WHERE Status=0 AND PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 2,'Purchase Return',PurRetRefNo
	FROM PurchaseReturn
	WHERE Status=0 AND PurRetDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 3,'Return To Company','ReturnToCompany',ISNULL(COUNT(*),0)
	FROM ReturnToCompany
	WHERE Status=0 AND RtnCmpDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 3,'Return To Company',RtnCmpRefNo
	FROM ReturnToCompany
	WHERE Status=0 AND RtnCmpDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 4,'Stock Management','StockManagement',ISNULL(COUNT(*),0)
	FROM StockManagement
	WHERE Status=0 AND StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 4,'Stock Management',StkMngRefNo
	FROM StockManagement
	WHERE Status=0 AND StkMngDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 5,'Salvage','Salvage',ISNULL(COUNT(*),0)
	FROM Salvage
	WHERE Status=0 AND SalvageDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 5,'Salvage',SalvageRefNo
	FROM Salvage
	WHERE Status=0 AND SalvageDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 6,'Billing','SalesInvoice',ISNULL(COUNT(*),0)
	FROM SalesInvoice
	WHERE DlvSts NOT IN(5,3,4) AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 6,'Billing',SalInvNo
	FROM SalesInvoice
	WHERE DlvSts NOT IN(5,3,4) AND SalInvDate BETWEEN @Pi_FromDate AND @Pi_ToDate

	--->Added By Nanda on 15/03/2011
--	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
--	SELECT 7,'Sales Return','ReturnHeader',ISNULL(COUNT(*),0)
--	FROM ReturnHeader
--	WHERE Status=1 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
--	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
--	SELECT 7,'Sales Return',ReturnCode
--	FROM ReturnHeader
--	WHERE Status=1 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate

	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 7,'Sales Return','ReturnHeader',A.Counts+B.Counts
	FROM 
	(
		SELECT ISNULL(COUNT(*),0) AS Counts 
		FROM ReturnHeader
		WHERE Status=1 AND ReturnType=2 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	) A	,
	(
		SELECT ISNULL(COUNT(*),0) AS Counts 
		FROM ReturnHeader RH,SalesInvoice SI
		WHERE RH.Status=1 AND RH.ReturnType=1 
		AND RH.SalId=SI.SalId AND SI.DlvSts<3
		AND RH.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	) B

	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 7,'Sales Return',ReturnCode
	FROM ReturnHeader
	WHERE Status=1 AND ReturnType=2 AND ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate

	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 7,'Sales Return',ReturnCode
	FROM ReturnHeader RH,SalesInvoice SI
	WHERE RH.Status=1 AND RH.ReturnType=1 AND RH.SalId=SI.SalId AND SI.DlvSts<3
	AND RH.ReturnDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	--->Till Here

	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 8,'Resell Damage Goods','ResellDamageMaster',ISNULL(COUNT(*),0)
	FROM ResellDamageMaster
	WHERE Status=0 AND ReSellDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 8,'Resell Damage Goods',ReDamRefNo
	FROM ResellDamageMaster
	WHERE Status=0 AND ReSellDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 9,'Salesman Salary & DA Claim','SalesmanClaimMaster',ISNULL(COUNT(*),0)
	FROM SalesmanClaimMaster
	WHERE Status=0 AND ScmDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 9,'Salesman Salary & DA Claim',ScmRefNo
	FROM SalesmanClaimMaster
	WHERE Status=0 AND ScmDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 10,'Delivery boy Salary & DA Claim','DeliveryBoyClaimMaster',ISNULL(COUNT(*),0)
	FROM DeliveryBoyClaimMaster
	WHERE Status=0 AND DbcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 10,'Delivery boy Salary & DA Claim',DbcRefNo
	FROM DeliveryBoyClaimMaster
	WHERE Status=0 AND DbcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 11,'Salesman Incentive Claim','SMIncentiveCalculatorMaster',ISNULL(COUNT(*),0)
	FROM SMIncentiveCalculatorMaster
	WHERE Status=0 AND SicDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 11,'Salesman Incentive Claim',SicRefNo
	FROM SMIncentiveCalculatorMaster
	WHERE Status=0 AND SicDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 12,'Van Subsidy Claim','VanSubsidyHD',ISNULL(COUNT(*),0)
	FROM VanSubsidyHD
	WHERE [Confirm]=0 AND SubsidyDt BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 12,'Van Subsidy Claim',RefNo
	FROM VanSubsidyHD
	WHERE [Confirm]=0 AND SubsidyDt BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 13,'Transporter Claim','TransporterClaimMaster',ISNULL(COUNT(*),0)
	FROM TransporterClaimMaster
	WHERE Status=0 AND TrcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 13,'Transporter Claim',TrcRefNo
	FROM TransporterClaimMaster
	WHERE Status=0 AND TrcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 14,'Special Discount Claim','SpecialDiscountMaster',ISNULL(COUNT(*),0)
	FROM SpecialDiscountMaster
	WHERE Status=0 AND SdcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 14,'Special Discount Claim',SdcRefNo
	FROM SpecialDiscountMaster
	WHERE Status=0 AND SdcDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 15,'Rate Difference Claim','RateDifferenceClaim',ISNULL(COUNT(*),0)
	FROM RateDifferenceClaim
	WHERE Status=0 AND [Date] BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 15,'Rate Difference Claim',RefNo
	FROM RateDifferenceClaim
	WHERE Status=0 AND [Date] BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 16,'Purchase Shortage Claim','PurShortageClaim',ISNULL(COUNT(*),0)
	FROM PurShortageClaim
	WHERE Status=0 AND ClaimDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 16,'Purchase Shortage Claim',PurShortRefNo
	FROM PurShortageClaim
	WHERE Status=0 AND ClaimDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 17,'Purchase Excess Quantity Refusal Claim','PurchaseExcessClaimMaster',ISNULL(COUNT(*),0)
	FROM PurchaseExcessClaimMaster
	WHERE Status=0 AND [Date] BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 17,'Purchase Excess Quantity Refusal Claim',RefNo
	FROM PurchaseExcessClaimMaster
	WHERE Status=0 AND [Date] BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 18,'Manual Claim','ManualClaimMaster',ISNULL(COUNT(*),0)
	FROM ManualClaimMaster
	WHERE Status=0 AND MacDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 18,'Manual Claim',MacRefNo
	FROM ManualClaimMaster
	WHERE Status=0 AND MacDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 19,'VAT Claim','VatTaxClaim',ISNULL(COUNT(*),0)
	FROM VatTaxClaim
	WHERE Status=0 AND VatDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 19,'VAT Claim',SvatNo
	FROM VatTaxClaim
	WHERE Status=0 AND VatDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 20,'Claim Top Sheet','ClaimSheetHD',ISNULL(COUNT(*),0)
	FROM ClaimSheetHD
	WHERE [Confirm]=0 AND ClmDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 20,'Claim Top Sheet',ClmCode
	FROM ClaimSheetHD
	WHERE [Confirm]=0 AND ClmDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 21,'Spent & Received','SpentReceivedHD',ISNULL(COUNT(*),0)
	FROM SpentReceivedHD
	WHERE Status=0 AND SRDDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 21,'Spent & Received',SRDRefNo
	FROM SpentReceivedHD
	WHERE Status=0 AND SRDDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 22,'Point Redemption','PntRetSchemeHD',ISNULL(COUNT(*),0)
	FROM PntRetSchemeHD
	WHERE Status=0 AND TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 22,'Point Redemption',PntRedRefNo
	FROM PntRetSchemeHD
	WHERE Status=0 AND TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndOpenTrans(SlNo,ScreenName,TabName,OpenTrans)	
	SELECT 23,'Coupon Redemption','CouponRedHd',ISNULL(COUNT(*),0)
	FROM CouponRedHd
	WHERE Status=0 AND CpnRedDate BETWEEN @Pi_FromDate AND @Pi_ToDate
	INSERT INTO YearEndLog(SlNo,ScreenName,RefNo)
	SELECT 23,'Coupon Redemption',CpnRedCode
	FROM CouponRedHd
	WHERE Status=0 AND CpnRedDate BETWEEN @Pi_FromDate AND @Pi_ToDate	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-209-028

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnFiltersValue]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnFiltersValue]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[Fn_ReturnFiltersValue]
(
	@Pi_RecordId Bigint,
	@Pi_ScreenId INT,
	@Pi_ReturnId INT
)
RETURNS nVarchar(1000)
AS
/*********************************
* FUNCTION: Fn_ReturnFiltersValue
* PURPOSE: Returns the Code or Name for the MasterId
* NOTES:
* CREATED: Thrinath Kola	31-07-2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
@Pi_ReturnId		1		Code
@Pi_ReturnId		2		Name
*********************************/
BEGIN

	DECLARE @RetValue as nVarchar(1000)

	IF @Pi_ScreenId = 1
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SMCode ELSE SMName END
			FROM SalesMan WHERE SMId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 2
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RMCode ELSE RMName END
			FROM RouteMaster WHERE RMId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 3
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RtrCode ELSE RtrName END
			FROM Retailer WHERE RtrID  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 4
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CmpCode ELSE CmpName END
			FROM Company WHERE CmpId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 5
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdDCode ELSE PrdName END
			FROM Product WHERE PrdId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 7
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdBatCode ELSE PrdBatCode END
			FROM ProductBatch WHERE PrdBatId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 8
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SchCode ELSE SchDsc END
			FROM SchemeMaster WHERE SchID  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 9
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SpmCode ELSE SpmName END
			FROM Supplier WHERE SpmID  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 14
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalInvNo ELSE SalInvNo END
			FROM SALESINVOICE WHERE SALID  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 15
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalInvNo ELSE SalInvNo END
			FROM SALESINVOICE WHERE SALID  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 16
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CmpPrdCtgName ELSE CmpPrdCtgName END
			FROM ProductCategoryLevel WHERE CmpPrdCtgId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 17
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 18
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TaxGroupName ELSE TaxGroupName END
			FROM TaxGroupSetting WHERE TaxGroupId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 19
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TaxGroupName ELSE TaxGroupName END
			FROM TaxGroupSetting WHERE TaxGroupId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 21
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdCtgValCode ELSE PrdCtgValName END
			FROM ProductCategoryValue WHERE PrdCtgValMainId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 22
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LcnCode ELSE LcnName END
			FROM Location WHERE LcnId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 23
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 24
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 25
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId AND RptId IN(7,13)
	END
	IF @Pi_ScreenId = 28
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 29
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CtgLevelName ELSE CtgLevelName END
			FROM RetailerCategoryLevel WHERE CtgLevelId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 30
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CtgName ELSE CtgName END
			FROM RetailerCategory WHERE CtgMainId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 31
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ValueClassCode ELSE ValueClassName END
			FROM RetailerValueClass WHERE RtrClassId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 32
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ReturnCode ELSE ReturnCode END
			FROM ReturnHeader WHERE ReturnId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 33
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 34
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalInvNo ELSE SalInvNo END
			FROM SalesInvoice WHERE SalId  = @Pi_RecordId
	END		
	IF @Pi_ScreenId = 35
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RMCode ELSE RMName END
			FROM RouteMaster WHERE RMId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 36
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VehicleCode ELSE VehicleRegNo END
			FROM Vehicle WHERE VehicleId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 37
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AllotmentNumber ELSE AllotmentNumber END
			FROM VehicleAllocationMaster WHERE AllotmentId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 38
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(67) AND SelId =38)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
		ELSE
		BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN Description ELSE Description END
			FROM StockManagementType WHERE StkMgmtTypeId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 39
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LcnCode ELSE LcnName END
			FROM Location WHERE LcnId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 40
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LcnCode ELSE LcnName END
			FROM Location WHERE LcnId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 41
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ClmCode ELSE ClmDesc END
			FROM ClaimSheetHD WHERE ClmId  = @Pi_RecordId
	END        	
	IF @Pi_ScreenId = 42
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ClmGrpCode ELSE ClmGrpName END
			FROM ClaimGroupMaster WHERE ClmGrpId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 43
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 44
	--Added by Thiru on 03/09/09
	IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =4 AND SelId =44)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=4
		END
	ELSE
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 45
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 46
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 47
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AcName ELSE AcName END
			FROM COAMaster WHERE CoaId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 48
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 49
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AcName ELSE AcName END
			FROM COAMaster WHERE AcCode  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 50
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AcName ELSE AcName END
			FROM COAMaster WHERE AcCode  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 51
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	---Adde By Murugan
	IF @Pi_ScreenId = 53
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(43,44) AND SelId=53)
			BEGIN
				SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
					FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
			END
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(43,44) AND SelId=54)
			BEGIN
				SELECT @RetValue = UomDescription  FROM UomMaster WHERE Uomid in( SELECT SelValue FROM
					Reportfilterdt WHERE Rptid in(44,43) AND SelId=54)
			END
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(43,44) AND SelId=55)
			BEGIN
				SELECT @RetValue = PrdUnitCode  FROM productUnit WHERE PrdUnitId in( SELECT SelValue FROM
					Reportfilterdt WHERE Rptid in(44,43) AND SelId=55)
			END
	END
	IF @Pi_ScreenId = 56
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(44,59) AND SelId =56)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
		
	END
	IF @Pi_ScreenId = 66
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 64
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN Cast(FilterDesc as Varchar(20)) ELSE Cast(FilterDesc as Varchar(20)) END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 63
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 65
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VillageName ELSE VillageName END
			FROM RouteVillage WHERE VillageId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 67
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 68
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 69
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	
	IF @Pi_ScreenId = 70
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN BnkCode ELSE BnkName END
			FROM Bank WHERE BnkId  = @Pi_RecordId
		END
	
	IF @Pi_ScreenId = 71
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN BnkBrCode ELSE BnkBrName END
			FROM BankBranch WHERE BnkBrId  = @Pi_RecordId
		END
	IF @Pi_ScreenId = 77
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	IF @Pi_ScreenId = 75
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	IF @Pi_ScreenId = 52
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UOMCode ELSE UOMDescription END
			FROM UomMaster WHERE UOMId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 12
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN JcmYr ELSE JcmYr END
			FROM JCMast WHERE JcmId  = @Pi_RecordId
		END
	IF @Pi_ScreenId = 79
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(63) AND SelId =79)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
		
	END
	IF @Pi_ScreenId = 80
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(63) AND SelId =80)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	IF @Pi_ScreenId = 88
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN Description ELSE Description END
			FROM StockManagementType WHERE StkMgmtTypeId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 84
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DistributorName ELSE DistributorName END
			FROM Distributor WHERE DistributorId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 85
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TransporterName ELSE TransporterName END
			FROM Transporter WHERE TransporterId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 86
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VehicleCtgName ELSE VehicleCtgName END
			FROM VehicleCategory WHERE VehicleCtgId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 87
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VehicleCode ELSE VehicleCode END
			FROM Vehicle WHERE VehicleId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 83
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(33) AND SelId =83)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	
	IF @Pi_ScreenId = 89
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 90
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 92
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrfCode ELSE PrfName END
			FROM ProfileHd WHERE PrfId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 93
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UserName ELSE UserName END
			FROM Users WHERE UserId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 94
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 95
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrfName ELSE PrfName END
			FROM ProfileHd WHERE PrfId = @Pi_RecordId
	END
	IF @Pi_ScreenId = 96  --User Profile Master
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(80) AND SelId =96)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	
	IF @Pi_ScreenId = 99
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ColumnDataType ELSE ColumnName END
			FROM UdcMaster WHERE UdcMasterId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 100
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN MasterName ELSE MasterName END
			FROM UdcHd WHERE MasterId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 101
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 102 --Credit Note Supplier
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CrNoteNumber ELSE CrNoteNumber END
			FROM CreditNoteSupplier WHERE CrNoteNumber  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 103 --Debit Note Retailer
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DbNoteNumber ELSE DbNoteNumber END
			FROM DebitNoteRetailer WHERE DbNoteNumber  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 108 --Credit Note Retailer
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CrNoteNumber ELSE CrNoteNumber END
			FROM CreditNoteRetailer WHERE CrNoteNumber  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 104
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =90 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=90
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =81 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=81
		END
		ELSE IF  EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =82 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=82
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =84 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=84
		END
		ELSE IF  EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =85 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=85
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =87 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=87
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =88 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=88
		END
		ELSE IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid =89 AND SelId =104)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
				AND RptId=89
		END
		ELSE
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	IF @Pi_ScreenId = 91  --TaxConfiguration
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(78) AND SelId =91)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TaxCode ELSE TaxName END
			FROM TaxConfiguration WHERE TaxId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 97  --TaxGroupSetting
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(79) AND SelId =97)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
	IF @Pi_ScreenId = 98  --TaxGroupSetting
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(79) AND SelId =98)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TaxGroupName ELSE TaxGroupName END
			FROM TaxGroupSetting WHERE TaxGroupId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 109  --SalesForce Level
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(87) AND SelId =109)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LevelName ELSE LevelName END
			FROM SalesForcelevel WHERE SalesForceLevelId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 110  --SalesForce Level Value
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(87) AND SelId =110)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalesForceCode ELSE SalesForceName END
			FROM SalesForce WHERE SalesForceMainId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 111  --SalesForce Level Value
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(89) AND SelId =111)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DlvBoyCode ELSE DlvBoyName END
			FROM DeliveryBoy WHERE DlvBoyId  = @Pi_RecordId
		END
	END
---
	IF @Pi_ScreenId = 106 --Vehicle Subsidy Master
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(86) AND SelId =106)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId AND RptId in (86)
		END
		ELSE
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
				FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
		END
	END
---
	IF @Pi_ScreenId = 107  --Van Subsidy Master
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(86) AND SelId =107)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VehicleSubCode ELSE VehicleSubCode END
			FROM VehicleSubsidy WHERE VehicleSubId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 109  --SalesForce Level
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(87) AND SelId =109)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN LevelName ELSE LevelName END
			FROM SalesForcelevel WHERE SalesForceLevelId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 110  --SalesForce Level Value
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(87) AND SelId =110)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalesForceCode ELSE SalesForceName END
			FROM SalesForce WHERE SalesForceMainId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 111  --Delivery Boy
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(89,97) AND SelId =111)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DlvBoyCode ELSE DlvBoyName END
			FROM DeliveryBoy WHERE DlvBoyId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 112  --Retailer Potential Class
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(93) AND SelId =112)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PotentialClassCode ELSE PotentialClassName END
			FROM RetailerPotentialClass WHERE RtrClassId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 113
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 114
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 115  --SalesMan Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(96) AND SelId =115)
		BEGIN
			
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ScmRefNo ELSE ScmRefNo END
			FROM SalesmanClaimMaster WHERE scmRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 96 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
		END
	END
	IF @Pi_ScreenId = 116  --Delivery Boy Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(97) AND SelId =116)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN DbcRefNo ELSE DbcRefNo END
			FROM DeliveryBoyClaimMaster WHERE DlvBoyClmId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 117 --Transporter Claim Reference Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TrcRefNo ELSE TrcRefNo END
			FROM TransporterClaimMaster WHERE TrcRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 118  --Purchase Shortage Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(99) AND SelId =118)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurShortRefNo ELSE PurShortRefNo END
			FROM PurShortageClaim WHERE PurShortId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 119 --Purchase Excess Refusal Claim Reference Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RefNo ELSE RefNo END
			FROM PurchaseExcessClaimMaster WHERE RefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 121  --Special Discount Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(102) AND SelId =121)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SdcRefNo ELSE SdcRefNo END
			FROM SpecialDiscountMaster WHERE SplDiscClaimId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 122  --Van Subsidy Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(103) AND SelId =122)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RefNo ELSE RefNo END
			FROM VanSubsidyHD WHERE VanSubsidyId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 126 --Manual Claim Reference Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN MacRefNo ELSE MacRefNo END
			FROM ManualClaimMaster WHERE MacRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 120  --Rate Difference Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(101) AND SelId =120)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RefNo ELSE RefNo END
			FROM RateDifferenceClaim WHERE RateDiffClaimId  = @Pi_RecordId
		END
	END
	IF @Pi_ScreenId = 123
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 124
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 125
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 127
	BEGIN
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid in(106) AND SelId =127)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SicRefNo ELSE SicRefNo END
			FROM SMIncentiveCalculatorMaster WHERE SicRefNo  IN
			( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 106 AND SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
		END
	END
	IF @Pi_ScreenId = 128
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 129
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UOMCode ELSE UOMDescription END
			FROM UOMMaster WHERE UOMId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 130
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 131
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ChequeNo ELSE ChequeNo END
			FROM ChequeInventoryRtrDt WHERE ChequeNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 132
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 134
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UserStockType ELSE UserStockType END
			FROM StockType WHERE UserStockType  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 112 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
	END
	IF @Pi_ScreenId = 135
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UserStockType ELSE UserStockType END
			FROM StockType WHERE UserStockType  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 112 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
	END
	IF @Pi_ScreenId = 136
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN Description ELSE Description END
			FROM ReasonMaster WHERE ReasonId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 137
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN StkJournalRefNo ELSE StkJournalRefNo END
			FROM StockJournal WHERE StkJournalRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 112 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)
	END
	IF @Pi_ScreenId = 138
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN NormDescription ELSE NormDescription END
			FROM Norms WHERE NormId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 141
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN BnkBrCode ELSE BnkBrName END
		FROM BankBranch WHERE BnkBrId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 142 OR  @Pi_ScreenId = 143 OR  @Pi_ScreenId = 144 OR  @Pi_ScreenId = 145
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AttrName ELSE AttrName END
		FROM PurInvSeriesAttribute WHERE AttributeId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 146
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 147
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 148
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN InstrumentNo ELSE InstrumentNo END
			FROM ChequeInventorySuppDt WHERE InstrumentNo  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 149
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN AcmYr ELSE AcmYr END
		FROM AcMaster WHERE AcmYr  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 150
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 151
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 152
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN OrderNo ELSE OrderNo END
			FROM OrderBooking WHERE OrderNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 153
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TransactionDescription ELSE TransactionDescription END
			FROM TransactionMaster WHERE TransactionId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 154
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 155
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 156
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 157
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VocRefNo ELSE VocRefNo END
			FROM StdVocMaster WHERE VocRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 158
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN StkMngRefNo ELSE StkMngRefNo END
			FROM StockManagement WHERE StkMngRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 127 AND
						SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 159
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN [Description] ELSE [Description] END
			FROM ReasonMaster WHERE ReasonId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 160
	BEGIN
	SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ReDamRefNo ELSE ReDamRefNo END
			FROM ResellDamageMaster WHERE ReDamRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 113 AND
						SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 161
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurOrderRefNo ELSE PurOrderRefNo END
			FROM PurchaseorderMaster WHERE PurOrderRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 162
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RefCode ELSE RefCode END
			FROM BatchCreationMaster WHERE BatchSeqId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 163 --Van Load Unload
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN VanLoadRefNo ELSE VanLoadRefNo END
			FROM VanLoadUnloadMaster WHERE VanLoadRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 164
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN UserStockType ELSE UserStockType END
		FROM StockType WHERE StockTypeId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 165
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RtnCmpRefNo ELSE RtnCmpRefNo END
			FROM ReturnToCompany WHERE RtnCmpRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 166
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ModuleName ELSE ModuleName END
			FROM Counters WHERE ModuleName  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 116 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 167
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 168
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 169
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 170
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 171 --Payment
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PayAdvNo ELSE PayAdvNo END
			FROM PurchasePayment WHERE PayAdvNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 172
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 173 --GRN Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRcptRefNo ELSE PurRcptRefNo END
			FROM PurchaseReceipt WHERE PurRcptRefNo  = @Pi_RecordId
	END	
	
	IF @Pi_ScreenId = 174 --Company Invoice Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CmpInvNo ELSE CmpInvNo END
			FROM PurchaseReceipt WHERE CmpInvNo  = @Pi_RecordId
	END
		
	IF @Pi_ScreenId = 175 --Purchase Return Number
	BEGIN
		
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRetRefNo ELSE PurRetRefNo END
			FROM PurchaseReturn WHERE PurRetId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 176--Purchase Return Type
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 177 --From Product Batch
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdBatCode ELSE PrdBatCode END
			FROM ProductBatch WHERE PrdBatId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 178 --To Product Batch
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PrdBatCode ELSE PrdBatCode END
			FROM ProductBatch WHERE PrdBatId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 179
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 180
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN BatRefNo ELSE BatRefNo END
			FROM BatchTRansfer WHERE BatRefNo  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 181
	BEGIN
			
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalvageRefNo ELSE SalvageRefNo END
			FROM Salvage WHERE SalvageRefNo  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 182
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 183
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 184
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FocusRefNo ELSE FocusRefNo END
			FROM FocusBrandHd WHERE FocusRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 140 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 185 OR @Pi_ScreenId = 186 OR @Pi_ScreenId = 187 OR @Pi_ScreenId = 188 OR @Pi_ScreenId = 189 OR @Pi_ScreenId = 192 OR @Pi_ScreenId = 193
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 190
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FormName ELSE FormName END
			FROM HotSearchEditorHd WHERE FormName  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 144 AND
			SelId = @Pi_ScreenId )	
	END
	IF @Pi_ScreenId = 191
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN ControlName ELSE ControlName END
			FROM HotSearchEditorHd WHERE ControlName  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 144 AND
			SelId = @Pi_ScreenId )	
	END
	
	IF @Pi_ScreenId = 194
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN CmpInvNo ELSE CmpInvNo END
			FROM PurchaseReceipt WHERE PurRcptId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 195
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TransactionNo1 ELSE TransactionNo1 END
			FROM (SELECT DISTINCT SalInvNo AS TransactionNo1
			FROM SalesInvoice  UNION  SELECT DISTINCT ReturnCode AS TransactionNo1 FROM ReturnHeader
			UNION  SELECT DISTINCT RepRefNo AS TransactionNo1 FROM ReplacementHd) A WHERE TransactionNo1
			IN ( SELECT CAST(SelDate AS VARCHAR(25)) FROM ReportFilterDt WHERE Rptid= 29 AND
			SelId = @Pi_ScreenId)
	END
	IF @Pi_ScreenId = 196
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 197
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRcptRefNo ELSE PurRcptRefNo END
			FROM PurchaseReceipt WHERE PurRcptId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 199
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN SalvageRefNo ELSE SalvageRefNo END
			FROM sALVAGE WHERE SalvageRefNo  IN ( SELECT Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= 21 AND
			SelId = @Pi_ScreenId AND UsrId = @Pi_ReturnId)	
	END
	IF @Pi_ScreenId = 200
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 201
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN TransactionNo1 ELSE TransactionNo1 END
			FROM (SELECT DISTINCT PurRcptRefNo AS TransactionNo1
			FROM PurchaseReceipt  UNION  SELECT DISTINCT PurRetRefNo AS TransactionNo1 FROM PurchaseReturn) A WHERE TransactionNo1
			IN ( SELECT CAST(SelDate AS VARCHAR(25)) FROM ReportFilterDt WHERE Rptid= 29 AND
			SelId = @Pi_ScreenId)
	END
	IF @Pi_ScreenId = 202
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
		FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 203
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
		FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 204
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
		FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	
	IF @Pi_ScreenId = 205
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRetRefNo ELSE PurRetRefNo END
			FROM PurchaseReturn WHERE PurRetId  = @Pi_RecordId
	END
	IF @Pi_ScreenId = 206
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN PurRetRefNo ELSE PurRetRefNo END
			FROM PurchaseReturn WHERE PurRetId  = @Pi_RecordId
	END
	
	IF @Pi_ScreenId = 208
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 209
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 210
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF @Pi_ScreenId = 211
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId AND RptID=153
	END
	IF @Pi_ScreenId = 215
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN RtrName ELSE RtrName END
			FROM Retailer WHERE RtrId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 216
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN IssueRefNo ELSE IssueRefNo END
			FROM SampleIssueHd WHERE IssueId  = @Pi_RecordId
	END	
	IF @Pi_ScreenId = 217 OR @Pi_ScreenId = 241 OR @Pi_ScreenId = 260
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
		FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId
	END
	IF  @Pi_ScreenId = 232
	BEGIN
		SELECT @RetValue = FilterDesc
		FROM RptFilter INNER JOIN ReportFilterDt ON SelId=SelcId
		AND ReportFilterDt.RptId=RptFilter.RptId  AND FilterId=SelValue
		WHERE  SelcId=@Pi_ScreenId	AND UsrId=@Pi_ReturnId
	END
	IF @Pi_ScreenId = 240 
	BEGIN
		SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN FilterDesc ELSE FilterDesc END
			FROM RptFilter WHERE FilterId  = @Pi_RecordId AND SelcId=@Pi_ScreenId AND RptID=5
	END

	IF @Pi_ScreenId = 255  --Mordern Trade Claim Reference Number
	BEGIN		
		IF EXISTS (SELECT * FROM Reportfilterdt WHERE Rptid IN(213) AND SelId =255)
		BEGIN
			SELECT @RetValue = CASE @Pi_ReturnId WHEN 1 THEN MTCRefNo ELSE MTCRefNo END
			FROM ModernTradeMaster WHERE MTCSplDiscClaimId  = @Pi_RecordId
		END
	END

	RETURN(@RetValue)

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-209-029-From Boo

IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'StkMgmtTypeId' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='StockManagementProduct'))
BEGIN
	ALTER TABLE StockManagementProduct ADD StkMgmtTypeId INT NOT NULL DEFAULT 0 WITH VALUES
END
GO
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_StockManagement_StkMgmtTypeId]') 
	and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
BEGIN
	ALTER TABLE [dbo].[StockManagement] DROP CONSTRAINT [FK_StockManagement_StkMgmtTypeId]
END
GO
IF EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'StkMgmtTypeId' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='StockManagementProduct'))
BEGIN
	IF EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'StkMgmtTypeId' and id in (SELECT id FROM 
	Sysobjects WHERE NAME ='StockManagement'))
	BEGIN
		UPDATE A SET A.StkMgmtTypeId=B.StkMgmtTypeId FROM StockManagementProduct A INNER JOIN StockManagement B
		ON A.StkMngRefNo=B.StkMngRefNo
	END
END
GO
IF NOT EXISTS (SELECT * FROM SysObjects WHERE [NAME] = 'FK_StockManagementProduct_StkMgmtTypeId' AND Xtype = 'F') 
BEGIN 
	ALTER TABLE [dbo].[StockManagementProduct] ADD CONSTRAINT [FK_StockManagementProduct_StkMgmtTypeId] 
	FOREIGN KEY ([StkMgmtTypeId]) REFERENCES [StockManagementType] ([StkMgmtTypeId]) 
END 
GO
IF NOT EXISTS (SELECT Id,name FROM Syscolumns WHERE NAME = 'ConfigValue' and id in (SELECT id FROM 
Sysobjects WHERE NAME ='StockManagement'))
BEGIN
	ALTER TABLE StockManagement ADD ConfigValue INT NOT NULL DEFAULT 0 WITH VALUES
END
GO
DECLARE @default_name AS Varchar(500)
SELECT @default_name=object_name(cdefault) FROM syscolumns
WHERE [id] = object_id('StockManagementProduct')
AND [name] = 'StkMgmtTypeId'
IF LEN(@default_name)>0 
BEGIN
	EXEC('ALTER TABLE StockManagementProduct DROP CONSTRAINT ' + @default_name)
END
GO
DELETE FROM Configuration WHERE ModuleId='BILALERTMGNT16'
INSERT INTO Configuration
SELECT 'BILALERTMGNT16','Alert Management','Track number of credit days against each invoice',
1,0,0,16
GO
DELETE FROM RptGroup WHERE GrpCode='Akso Nobal Reports'
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName)
SELECT 'CORESTOCKY',0,'Akso Nobal Reports','Akso Nobal Reports'
GO
DELETE FROM RptGroup WHERE  Rptid=220
INSERT INTO RptGroup(PId,RptId,GrpCode,GrpName)
SELECT 'Akso Nobal Reports',220,'RetailerandProductWiseSalesVolume','Retailer and Product Wise Sales Volume'
GO
DELETE FROM RptHeader WHERE Rptid=220
INSERT INTO RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds)
SELECT 'RetailerandProductWiseSalesVolume','Retailer and Product Wise Sales Volume',220,'Retailer and Product Wise Sales Volume','Proc_RptRtrPrdWiseSales','RptRtrPrdWiseSales','RptRtrPrdWiseSales.rpt',NULL
GO
DELETE FROM RptDetails WHERE RptId=220
INSERT INTO RptDetails
SELECT 220,1,'FromDate',-1,'','','From Date*','',1,'',10,'','','Enter From Date',0
UNION
SELECT 220,2,'ToDate',-1,'','','To Date*','',1,'',11,'','','Enter To Date',0
UNION
SELECT 220,3,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,'','Press F4/Double Click to select Company',0
UNION
SELECT 220,4,'SalesMan',-1,'','SMId,SMCode,SMName','SalesMan...','',1,'',1,1,'','Press F4/Double Click to select Salesman',0
UNION
SELECT 220,5,'RouteMaster',-1,'','RMId,RMCode,RMName','Route...','',1,'',2,1,'','Press F4/Double Click to select Route',0
UNION
SELECT 220,6,'ProductCategoryLevel',3,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,'','Press F4/Double Click to select Product Hierarchy Level',0
UNION
SELECT 220,7,'ProductCategoryValue',6,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,'','','Press F4/Double Click to select Product Hierarchy Level Value',0
UNION
SELECT 220,8,'Product',7,'PrdCtgValMainId','PrdId,PrdDCode,PrdName','Product...','ProductCategoryValue',1,'PrdCtgValMainId',5,'','','Press F4/Double Click to select Product',0
UNION 
SELECT 220,9,'Retailer',-1,'','RtrId,RtrCode,RtrName','Retailer...','',1,'',3,'','','Press F4/Double Click to select Retailer',0
UNION 
SELECT 220,10,'RptFilter',-1,'','FilterId,FilterDesc,FilterDesc','Display Level*...','',1,'',260,1,1,'Press F4/Double Click to select Display Level',0

GO
DELETE FROM RptSelectionHd WHERE SelcId=260
INSERT INTO RptSelectionHd VALUES(260,'sel_DisplayLevel','RptFilter',1)
GO
DELETE FROM RptFilter WHERE RptId=220 AND SelcId=260
INSERT INTO RptFilter VALUES(220,260,1,'SKU Level')
INSERT INTO RptFilter VALUES(220,260,2,'Hierarchy Level')
GO
DELETE FROM RptFormula WHERE RptId=220
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,1,'Rpt_RtrCode','Retailer Code',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,2,'Rpt_RtrName','Retailer Name',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,3,'Rpt_PrdCtgLevel','Product Category Level',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,4,'Rpt_PrdCtgValue','Product Category Value',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,5,'Rpt_PrdCode','Product Code',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,6,'Rpt_PrdName','Product Name',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,7,'Rpt_SalesQty','Sales Qty',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,8,'Rpt_SalesVolume','Sales Volume',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,9,'Rpt_SalesValue','Sales Value',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,10,'Disp_Company','',1,4
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,11,'Disp_FromDate','',1,10
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,12,'Disp_ToDate','',1,11
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,13,'Disp_Salesman','',1,1
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,14,'Disp_Route','',1,2
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,15,'Disp_Retailer','',1,3
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,16,'Disp_ProductCategoryLevel','',1,16
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,17,'Disp_ProductCategoryValue','',1,21
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,18,'Disp_Product','',1,5
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,19,'Cap_Display','Display Level',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,20,'Dis_Display','',1,260
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,21,'CapPrintDate','Date',1,0
INSERT INTO RptFormula(RptId,SlNo,Formula,FormulaValue,LcId,SelcId)
SELECT 220,22,'CapUserName','User Name',1,0
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_RptRtrPrdWiseSales')
DROP PROCEDURE Proc_RptRtrPrdWiseSales
GO 
--select * from ReportfilterDt where rptid = 90 And selid = 66
--EXEC Proc_RptRtrPrdWiseSales 220,2,0,'ASKO',0,0,1
CREATE     PROCEDURE [dbo].[Proc_RptRtrPrdWiseSales]
/************************************************************
* PROCEDURE	: Proc_RptRtrPrdWiseSales
* PURPOSE	: Retailer and Product Wise Sales Volume
* CREATED BY	: Boopathy.P
* CREATED DATE	: 14/03/2011
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
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
SET NOCOUNT ON
BEGIN
	DECLARE @NewSnapId 		AS	INT
	DECLARE @DBNAME			AS 	nvarchar(50)
	DECLARE @TblName 		AS	nvarchar(500)
	DECLARE @TblStruct 		AS	nVarchar(4000)
	DECLARE @TblFields 		AS	nVarchar(4000)
	DECLARE @SSQL			AS 	VarChar(8000)
	DECLARE @ErrNo	 		AS	INT
	DECLARE @PurDBName		AS	nVarChar(50)
	DECLARE @FromDate		AS	DATETIME
	DECLARE @ToDate			AS	DATETIME
	DECLARE @RMId			AS	INT
	DECLARE @SMId			AS	INT
	DECLARE @RtrId 			AS 	INT
	DECLARE @CmpId 			AS 	INT
	DECLARE @PrdCatLvlId 	AS 	INT
	DECLARE @PrdCatValId 	AS 	INT
	DECLARE @PrdId 			AS 	INT
	DECLARE @Display		AS 	INT

	CREATE  TABLE #RptRtrPrdWiseSales
		(
			RtrId				INT,
			RtrCode				NVARCHAR(100),
			RtrName				NVARCHAR(200),
			CmpPrdCtgId			INT,
			CmpPrdCtgName		NVARCHAR(200),
			PrdCtgValMainId		INT,
			PrdCtgValCode		NVARCHAR(100),
			PrdCtgValName		NVARCHAR(200),
			PrdId				INT,
			PrdCCode			NVARCHAR(100),
			PrdName				NVARCHAR(200),
			BaseQty				NUMERIC(18,0),
			PrdUnitId			INT,
			PrdOnUnit			NUMERIC(18,0),
			PrdOnKg				NUMERIC(18,6),
			PrdOnLitre			NUMERIC(18,6),
			PrdNetAmount		NUMERIC(18,6),
			DispMode			INT
		)


	SET @SMId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @CmpId = (SELECT TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @PrdCatLvlId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCatValId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @Display = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,256,@Pi_UsrId))

	IF @CmpId=0
	BEGIN
		SELECT @CmpId=CmpId FROM Company WHERE DefaultCompany=1
	END
	

	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)

	
	SET @TblName = 'RptRtrPrdWiseSales'
	
	SET @TblStruct ='		
			RtrId				INT,
			RtrCode				NVARCHAR(100),
			RtrName				NVARCHAR(200),
			CmpPrdCtgId			INT,
			CmpPrdCtgName		NVARCHAR(200),
			PrdCtgValMainId		INT,
			PrdCtgValCode		NVARCHAR(100),
			PrdCtgValName		NVARCHAR(200),
			PrdId				INT,
			PrdCCode			NVARCHAR(100),
			PrdName				NVARCHAR(200),
			PrdUnitId			INT,
			PrdOnUnit			NUMERIC(18,0),
			PrdOnKg				NUMERIC(18,6),
			PrdOnLitre			NUMERIC(18,6),
			PrdNetAmount		NUMERIC(18,6),
			DispMode			INT'					
	
	SET @TblFields = 'RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
			PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode'
			
	IF @Display=2
	BEGIN
		IF (@PrdCatLvlId=0 AND @PrdCatValId=0 AND @PrdId=0)
		BEGIN
			INSERT INTO #RptRtrPrdWiseSales (RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
					PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode)
			SELECT RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				   0,'','',PrdUnitId,SUM(PrdOnUnit),SUM(PrdOnKg),SUM(PrdOnLitre),SUM(PrdNetAmount),@Display FROM 
				(
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE WHEN ((SELECT COUNT(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))<=1 AND (SELECT (iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))=0) THEN C.PrdCtgValMainId ELSE 0 END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				UNION
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE WHEN ((SELECT COUNT(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))<=1 AND (SELECT (iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))=0) THEN C.PrdCtgValMainId ELSE 0 END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))) A
					GROUP BY RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				    PrdUnitId
		END
		ELSE IF (@PrdCatLvlId>0 AND @PrdCatValId=0 AND @PrdId=0)
		BEGIN
			INSERT INTO #RptRtrPrdWiseSales (RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
					PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode)
			SELECT RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				   0,'','',PrdUnitId,SUM(PrdOnUnit),SUM(PrdOnKg),SUM(PrdOnLitre),SUM(PrdNetAmount),@Display FROM 
				(
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE WHEN ((SELECT COUNT(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))<=1 AND (SELECT (iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))=0) THEN C.PrdCtgValMainId ELSE 0 END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
				UNION
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE WHEN ((SELECT COUNT(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))<=1 AND (SELECT (iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))=0) THEN C.PrdCtgValMainId ELSE 0 END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))) A
					GROUP BY RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				    PrdUnitId
		END
		ELSE IF (@PrdCatLvlId>0 AND @PrdCatValId>0)
		BEGIN
			INSERT INTO #RptRtrPrdWiseSales (RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
					PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode)
			SELECT RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				   PrdId,PrdCCode,Prdname,PrdUnitId,SUM(PrdOnUnit),SUM(PrdOnKg),SUM(PrdOnLitre),SUM(PrdNetAmount),1 FROM 
				(
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
								FROM salesInvoice A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE 0 END) OR
									D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE WHEN ((SELECT COUNT(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))<=1 AND (SELECT (iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))=0) THEN C.PrdCtgValMainId ELSE 0 END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
				UNION
				SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
				G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
				F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
					FROM ProductCategoryValue C
					INNER JOIN 
						( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
							WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)  
							ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
							A.Prdid from Product A
					INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
						(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
						 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
					INNER JOIN 
							(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
							ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
					INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
								C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
								ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
								ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
								WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
								FROM ReturnHeader A 
								INNER JOIN Retailer B ON A.RtrId=B.RtrId
								INNER JOIN ReturnProduct C ON A.SalId=C.SalId
								INNER JOIN Product D ON D.PrdId=C.PrdId
								WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
								(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
								A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
								AND
								(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
								A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
								AND
								(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
								A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
								(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
									D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
								GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
								ON D.PrdId=F.PrdId 
					INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
					WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
					ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
					AND ( C.PrdCtgValMainId= CASE WHEN ((SELECT COUNT(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))<=1 AND (SELECT (iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))=0) THEN C.PrdCtgValMainId ELSE 0 END OR					
					C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
					(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
					G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) ) A
					GROUP BY RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
				    PrdId,PrdCCode,Prdname,PrdUnitId
		END
	END
	ELSE
	BEGIN
		INSERT INTO #RptRtrPrdWiseSales (RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,
				PrdCtgValName,PrdId,PrdCCode,PrdName,PrdUnitId,PrdOnUnit,PrdOnKg,PrdOnLitre,PrdNetAmount,DispMode)
		SELECT RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
			   PrdId,PrdCCode,Prdname,PrdUnitId,SUM(PrdOnUnit),SUM(PrdOnKg),SUM(PrdOnLitre),SUM(PrdNetAmount),@Display FROM 
			(
			SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
			G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
			F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
				FROM ProductCategoryValue C
				INNER JOIN 
					( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
						WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
						ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
						A.Prdid from Product A
				INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
					(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
					 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				INNER JOIN 
						(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
							FROM salesInvoice A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
								D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
							(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
						ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
				INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmount) AS PrdNetAmount
							FROM salesInvoice A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN SalesInvoiceProduct C ON A.SalId=C.SalId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.SalInvDate BETWEEN @FromDate AND @ToDate AND A.DlvSts>3 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.CmpId = (CASE @CmpId WHEN 0 THEN D.CmpId ELSE @CmpId END) OR
								D.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
							(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
							ON D.PrdId=F.PrdId 
				INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
				AND ( C.PrdCtgValMainId= CASE WHEN ((SELECT COUNT(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))<=1 AND (SELECT (iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))=0) THEN C.PrdCtgValMainId ELSE 0 END OR					
				C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
				(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
				G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) 
			UNION
			SELECT DISTINCT F.RtrId,F.RtrCode,F.RtrName,
			G.CmpPrdCtgId,G.CmpPrdCtgName,C.PrdCtgValMainId,C.PrdCtgValCode,C.PrdCtgValName,
			F.PrdId,F.PrdCCode,F.Prdname,F.PrdUnitId,F.PrdOnUnit,F.PrdOnKg,F.PrdOnLitre,F.PrdNetAmount 
				FROM ProductCategoryValue C
				INNER JOIN 
					( Select DISTINCT LEFT(PrdCtgValLinkCode,(CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) 
						WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId) 
						ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END) *5)  as PrdCtgValLinkCode,
						A.Prdid from Product A
				INNER JOIN ProductCategoryValue B On A.PrdCtgValMainId = B.PrdCtgValMainId AND 				
					(A.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN A.PrdId Else 0 END) OR
					 A.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
				INNER JOIN 
						(SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
							FROM ReturnHeader A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN ReturnProduct C ON A.ReturnId=C.ReturnId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId)F 
						ON A.PrdId = F.PrdId) AS D ON D.PrdCtgValLinkCode = C.PrdCtgValLinkCode 
				INNER JOIN (SELECT DISTINCT B.RtrId,B.RtrCode,B.RtrName,
							C.PrdId,D.PrdCCode,D.Prdname,D.PrdUnitId,SUM(C.BaseQty) AS PrdOnUnit,
							ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 3 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnKg,
							ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0)/1000
							WHEN 5 THEN ISNULL(SUM(PrdWgt * C.BaseQty),0) END,0) AS PrdOnLitre,SUM(C.PrdNetAmt) AS PrdNetAmount
							FROM ReturnHeader A 
							INNER JOIN Retailer B ON A.RtrId=B.RtrId
							INNER JOIN ReturnProduct C ON A.SalId=C.SalId
							INNER JOIN Product D ON D.PrdId=C.PrdId
							WHERE A.ReturnDate BETWEEN @FromDate AND @ToDate AND A.Status=0 AND
							(A.SMId = (CASE @SMId WHEN 0 THEN A.SMId ELSE 0 END) OR
							A.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
							AND
							(A.RMId = (CASE @RMId WHEN 0 THEN A.RMId ELSE 0 END) OR
							A.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							AND
							(A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR
							A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))) AND
							(D.PrdId = (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)) WHEN 0 THEN D.PrdId Else 0 END) OR
								D.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
							GROUP BY B.RtrId,B.RtrCode,B.RtrName,D.PrdCCode,D.Prdname,C.PrdId,D.PrdUnitId) F 
							ON D.PrdId=F.PrdId 
				INNER JOIN ProductCategoryLevel G ON G.CmpPrdCtgId= (CASE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
				WHEN 0 THEN (SELECT Max(CmpPrdCtgId)-1 FROM ProductCategoryLevel WHERE CmpId=@CmpId)
				ELSE (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)) END)
				AND ( C.PrdCtgValMainId= CASE WHEN ((SELECT COUNT(iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))<=1 AND (SELECT (iCountid) FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))=0) THEN C.PrdCtgValMainId ELSE 0 END OR					
				C.PrdCtgValMainId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))) AND
				(G.CmpId = (CASE @CmpId WHEN 0 THEN G.CmpId ELSE @CmpId END) OR
				G.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) ) A
				GROUP BY RtrId,RtrCode,RtrName,CmpPrdCtgId,CmpPrdCtgName,PrdCtgValMainId,PrdCtgValCode,PrdCtgValName,
			    PrdId,PrdCCode,Prdname,PrdUnitId
	END
	UPDATE #RptRtrPrdWiseSales SET BaseQty=PrdOnUnit
	UPDATE #RptRtrPrdWiseSales SET PrdOnUnit=0 WHERE PrdUnitId>1
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptRtrPrdWiseSales
	select * from #RptRtrPrdWiseSales 
RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_RptSupplierCreditNote')
DROP PROCEDURE Proc_RptSupplierCreditNote
GO
--EXEC Proc_RptSupplierCreditNote 84,2,0,'Cavin',0,0,1,0
CREATE   PROCEDURE [dbo].[Proc_RptSupplierCreditNote]
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
/************************************************
* PROCEDURE  : Proc_RptCreditNoteSupplier
* PURPOSE    : To Generate  Credit Note Supplier Report
* CREATED BY : Mahalakshmi.A
* CREATED ON : 20/02/2008  
* MODIFICATION 
*************************************************   
* DATE       AUTHOR      DESCRIPTION    
*************************************************/       
BEGIN
SET NOCOUNT ON
	DECLARE @NewSnapId 			AS	INT
	DECLARE @DBNAME				AS 	NVARCHAR(50)
	DECLARE @TblName 			AS	NVARCHAR(500)
	DECLARE @TblStruct 			AS	NVARCHAR(4000)
	DECLARE @TblFields 			AS	NVARCHAR(4000)
	DECLARE @sSql				AS 	NVARCHAR(4000)
	DECLARE @ErrNo	 			AS	INT
	DECLARE @PurDBName			AS	NVARCHAR(50)
	--Filter Variable
	DECLARE @FromDate			AS DATETIME
	DECLARE @ToDate				AS DATETIME
	DECLARE @SpmId				AS INT
	DECLARE @CrNoteNumber		AS NVARCHAR(50)
	DECLARE @Status				AS INT
	DECLARE @EXLFlag AS INT 
	--Till Here
	--Assgin Value for the Filter Variable
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @SpmId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId))
	SET @CrNoteNumber = (SElect  TOP 1 sCountid FRom Fn_ReturnRptFilterString(@Pi_RptId,102,@Pi_UsrId))
	SET @Status = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId))
	--Till Here
	Create TABLE #RptSupplierCreditNote
	(
			SpmId 				 INT,
			SpmCode				 NVARCHAR(50),
			SpmName 			 NVARCHAR(50),
			CrNoteNo			 NVARCHAR(50),
			CrNoteDate			 DATETIME,
			Reason				 NVARCHAR(50),
			CrAmount			 Numeric(38,2),
			CrAdjAmount			 Numeric(38,2),
			BalanceAmount		 Numeric(38,2),
			Status				 NVARCHAR(50),
			TaxName NVARCHAR(100),
			TaxPerc NUMERIC (38,2) ,
			TaxAmt NUMERIC (38,2)
			
	)
	SET @TblName = 'RptSupplierCreditNote'
	SET @TblStruct ='SpmId 				 INT,
					 SpmCode			 NVARCHAR(50),
					 SpmName 			 NVARCHAR(50),
					 CrNoteNo			 NVARCHAR(50),
					 CrNoteDate			 DATETIME,
					 Reason				 NVARCHAR(50),
					 CrAmount			 Numeric(38,2),
					 CrAdjAmount			 Numeric(38,2),
					 BalanceAmount		 Numeric(38,2),
					 Status				 NVARCHAR(50),
					TaxName NVARCHAR(100),
					TaxPerc NUMERIC (38,2) ,
					TaxAmt NUMERIC (38,2)'
	SET @TblFields = 'SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,CrAdjAmount,
					BalanceAmount,Status,TaxName,TaxPerc,TaxAmt'
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
 		INSERT INTO #RptSupplierCreditNote (SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,
				CrAdjAmount,BalanceAmount,Status,TaxName,TaxPerc,TaxAmt)
 			SELECT DISTINCT B.SpmId,B.SpmCode,B.SpmName,A.CrNoteNumber,A.CrNoteDate,C.Description,
				A.Amount,A.CrAdjAmount,(ISNULL(A.Amount,0)-ISNULL(A.CrAdjAmount,0)) as BalanceAmount,
					(CASE A.Status WHEN 1 THEN ' Active' ELSE ' InActive' END),
					ISNULL(TC.TaxName,'')+' Tax Amt',ISNULL(CTB.TaxPerc,0),ISNULL(CTB.TaxAmt,0)
				FROM CreditNoteSupplier A
			INNER JOIN Supplier B ON A.SpmId=B.SpmId
			INNER JOIN reasonMaster C ON A.ReasonId=C.ReasonId
			LEFT OUTER JOIN CrDbNoteTaxBreakUp CTB ON CTB.RefNo=A.CrNoteNumber AND CTB.TransId=32
			LEFT OUTER JOIN TaxConfiguration TC ON TC.TaxId=CTB.TaxId
 			WHERE 	(B.SpmId = (CASE @SpmID WHEN 0 THEN B.SpmID ELSE 0 END) OR
							B.SpmId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))
					AND
						(A.CrNoteNumber=(CASE @CrNoteNumber WHEN '0' THEN A.CrNoteNumber ELSE '' END)OR
 							A.CrNoteNumber IN (SELECT sCountid FROM Fn_ReturnRptFilterString(84,102,1)))
					AND
 						(A.Status = (CASE @Status WHEN 0 THEN A.Status ELSE 3 END) OR
 							A.Status IN (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId)))
					AND
						 A.CrNoteDate BETWEEN @FromDate AND @ToDate 
			INSERT INTO #RptSupplierCreditNote (SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,
				CrAdjAmount,BalanceAmount,Status,TaxName,TaxPerc,TaxAmt)
 			SELECT DISTINCT B.SpmId,B.SpmCode,B.SpmName,A.CrNoteNumber,A.CrNoteDate,C.Description,
				A.Amount,A.CrAdjAmount,(ISNULL(A.Amount,0)-ISNULL(A.CrAdjAmount,0)) as BalanceAmount,
			(CASE A.Status WHEN 1 THEN ' Active' ELSE ' InActive' END),
				ISNULL(TC.TaxName,'')+' Gross Amt' AS TaxName,ISNULL(CTB.TaxPerc,0),ISNULL(CTB.GrossAmt,0)
				FROM CreditNoteSupplier A
			INNER JOIN Supplier B ON A.SpmId=B.SpmId
			INNER JOIN reasonMaster C ON A.ReasonId=C.ReasonId
			LEFT OUTER JOIN CrDbNoteTaxBreakUp CTB ON CTB.RefNo=A.CrNoteNumber AND CTB.TransId=32
			LEFT OUTER JOIN TaxConfiguration TC ON TC.TaxId=CTB.TaxId
 			WHERE 	(B.SpmId = (CASE @SpmID WHEN 0 THEN B.SpmID ELSE 0 END) OR
							B.SpmId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))
					AND
						(A.CrNoteNumber=(CASE @CrNoteNumber WHEN '0' THEN A.CrNoteNumber ELSE '' END)OR
 							A.CrNoteNumber IN (SELECT sCountid FROM Fn_ReturnRptFilterString(84,102,1)))
					AND
 						(A.Status = (CASE @Status WHEN 0 THEN A.Status ELSE 3 END) OR
 							A.Status IN (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId)))
					AND
						 A.CrNoteDate BETWEEN @FromDate AND @ToDate 
		 
    		IF LEN(@PurDBName) > 0
 		BEGIN
 			SET @SSQL = 'INSERT INTO #RptSupplierCreditNote ' +
 				'(' + @TblFields + ')' +
 				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
 				 +' WHERE (SpmId=  (CASE @SpmId WHEN 0 THEN SpmId ELSE 0 END ) OR
 					SpmId IN (SELECT iCountId FROM dbo.Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))'
				 +' AND
					(A.CrNoteNumber=(CASE @CrNoteNumber WHEN ''0'' THEN A.CrNoteNumber ELSE '' END))OR
 						A.CrNoteNumber IN (SELECT iCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,102,@Pi_UsrId)))'
				 +' AND
 					(A.Status = (CASE @StatusID WHEN 0 THEN A.Status ELSE 0 END) OR
 						A.Status IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,104,@Pi_UsrId)))'
				 +'AND
					 A.CrNoteDate BETWEEN @FromDate AND @ToDate '
				
 			EXEC (@SSQL)
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSupplierCreditNote'
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
			END
	END
	ELSE				--To Retrieve Data From Snap Data
	BEGIN
		PRINT @Pi_DbName
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
		PRINT @ErrNo
		IF @ErrNo = 0
		   BEGIN
			SET @SSQL = 'INSERT INTO #RptSupplierCreditNote ' +
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
			SET @Po_Errno = 1
			PRINT 'DataBase or Table not Found'
			RETURN
		END
	END
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptSupplierCreditNote
	PRINT 'Data Executed'
	SELECT * FROM #RptSupplierCreditNote
	SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
	/***************************************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @InvId BIGINT
		--DECLARE  @RtrId INT
		DECLARE	 @RefNo	NVARCHAR(100)
		DECLARE  @PurRcptRefNo NVARCHAR(50)
		DECLARE	 @TaxPerc 		NVARCHAR(100)
		DECLARE	 @TaxableAmount NUMERIC(38,6)
		DECLARE  @IOTaxType    NVARCHAR(100)
		DECLARE  @SlNo INT		
		DECLARE	 @TaxFlag      INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @TaxPercent NUMERIC(38,6)
		DECLARE  @Name   NVARCHAR(100)
		--DROP TABLE RptOUTPUTVATSummary_Excel
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSupplierCreditNote_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptSupplierCreditNote_Excel]
		DELETE FROM RptExcelHeaders Where RptId=@Pi_RptId AND SlNo>10
		CREATE TABLE [RptSupplierCreditNote_Excel] (SpmId INT,SpmCode	NVARCHAR(50),SpmName NVARCHAR(50),
					CrNoteNo NVARCHAR(50),CrNoteDate DATETIME,Reason	NVARCHAR(50),CrAmount NUMERIC(38,2),
					CrAdjAmount	NUMERIC(38,2),BalanceAmount NUMERIC(38,2),Status NVARCHAR(50))
		SET @iCnt=11
		DECLARE Column_Cur CURSOR FOR
		SELECT DISTINCT TaxName FROM #RptSupplierCreditNote --ORDER BY CrNoteNumber 
		OPEN Column_Cur
			   FETCH NEXT FROM Column_Cur INTO @Column
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptSupplierCreditNote_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
				FETCH NEXT FROM Column_Cur INTO @Column
				END
		CLOSE Column_Cur
		DEALLOCATE Column_Cur
		--Insert table values
		DELETE FROM [RptSupplierCreditNote_Excel]
		INSERT INTO [RptSupplierCreditNote_Excel](SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,
				CrAdjAmount,BalanceAmount,Status)
		SELECT DISTINCT SpmId,SpmCode,SpmName,CrNoteNo,CrNoteDate,Reason,CrAmount,
				CrAdjAmount,BalanceAmount,Status FROM #RptSupplierCreditNote --WHERE UsrId=@Pi_UsrId
		--Select * from RptOUTPUTVATSummary_Excel
		DECLARE Values_Cur CURSOR FOR
		SELECT DISTINCT CrNoteNo,SpmId,TaxName,TaxAmt FROM #RptSupplierCreditNote
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @RefNo,@SpmId,@TaxPerc,@TaxableAmount
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptSupplierCreditNote_Excel  SET ['+ @TaxPerc +']= '+ CAST(@TaxableAmount AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL+ ' WHERE CrNoteNo =''' + CAST(@RefNo AS VARCHAR(1000)) +''' AND  SpmId=' + CAST(@SpmId AS VARCHAR(1000))
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @RefNo,@SpmId,@TaxPerc,@TaxableAmount
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptSupplierCreditNote_Excel]')
		OPEN NullCursor_Cura
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptSupplierCreditNote_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/***************************************************************************************************************************/
	END
RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE Xtype='P' and Name='Proc_VoucherPostingPurchase')
DROP PROCEDURE Proc_VoucherPostingPurchase
GO
/*
BEGIN TRANSACTION
EXEC Proc_VoucherPostingPurchase 5,1,'GRN1000042',5,0,2,'2010-10-27',0
--SELECT * FROM StdVocMaster WHERE VocRefno LIKE 'PUR%'
SELECT * FROM StdVocDetails WHERE VocRefno = 'PUR1000107'
SELECT * FROM CoaMAster WHERE COaId=1586
ROLLBACK TRANSACTION
*/
CREATE             Procedure [dbo].[Proc_VoucherPostingPurchase]
(
	@Pi_TransId		Int,
	@Pi_SubTransId		Int,
	@Pi_ReferNo		nVarChar(100),
	@Pi_VocType		INT,
	@Pi_SubVocType		INT,	
	@Pi_UserId		Int,
	@Pi_VocDate		DateTime,
	@Po_PurErrNo		Int OutPut
)
AS
/*********************************
* PROCEDURE	: Proc_VoucherPostingPurchase
* PURPOSE	: General SP for posting Purchase Voucher
* CREATED	: Thrinath
* CREATED DATE	: 25/12/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @AcmId 		INT
	DECLARE @AcpId		INT
	DECLARE @CoaId		INT
	DECLARE @VocRefNo	nVarChar(100)
	DECLARE @sStr		nVarChar(4000)
	DECLARE @Amt		Numeric(25,6)
	DECLARE @DCoaId		INT
	DECLARE @CCoaId		INT
	DECLARE @DiffAmt	Numeric(25,6)
	DECLARE @sSql           VARCHAR(4000)
	SET @Po_PurErrNo = 1

	IF @Pi_TransId = 5 AND @Pi_SubTransId = 1
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END

		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END

		--For Posting Purchase Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From GRN ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
		
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'

		--For Posting Purchase Account in Details Table on Debit(Gross Amount)
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4110001')
		BEGIN
			SET @Po_PurErrNo = -2
			Return
		END
		
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4110001'
		SELECT @Amt = SUM(PrdGrossAmount) FROM PurchaseReceiptProduct
		WHERE PurRcptId IN (SELECT PurRcptId FROM
		PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo)
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		
		--For Posting Supplier Account in Details Table to Credit(Net Payable)
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReceipt C ON B.SpmId = C.SpmId
			WHERE C.PurRcptRefNo = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -3
			Return
		END

		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReceipt C ON B.SpmId = C.SpmId
			WHERE C.PurRcptRefNo = @Pi_ReferNo

		--->Modified By Nanda on 29/10/2010
		--SELECT @Amt = NetPayable FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
		SELECT @Amt = NetPayable+DbAdjustAmt-CrAdjustAmt FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))

		--For Posting Purchase Discount Account in Details Table to Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,D.CoaId,2,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptHdAmount B ON
				A.PurRcptId = B.PurRcptId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRcptRefNo = @Pi_ReferNo AND
				EffectInNetAmount = 2 AND B.BaseQtyAmount > 0

		--For Posting Purchase Addition Account in Details Table on Debit
		SELECT @VocRefNo AS VocRefNo,D.CoaId,1 AS DebitCredit,B.BaseQtyAmount AS Amount,1 AS Availability,
			@Pi_UserId AS LastModBy,Convert(varchar(10),Getdate(),121) AS LastModDate,
			@Pi_UserId AS AuthId,Convert(varchar(10),Getdate(),121) AS AuthDate
		INTO #PurTotAdd
		FROM PurchaseReceipt A INNER JOIN PurchaseReceiptHdAmount B ON
			A.PurRcptId = B.PurRcptId
		INNER JOIN PurchaseSequenceMaster C ON
			A.PurSeqId = C.PurSeqId
		INNER JOIN PurchaseSequenceDetail D ON
			C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
		WHERE A.PurRcptRefNo = @Pi_ReferNo AND B.RefCode <> 'D' AND
			EffectInNetAmount = 1 AND B.BaseQtyAmount > 0
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT * FROM #PurTotAdd

		--For Posting Purchase Tax Account in Details Table on Debit
		SELECT @VocRefNo AS VocRefNo,C.InputTaxId,1 AS DebitCredit,ISNULL(SUM(B.TaxAmount),0) AS Amount,1 AS Availability,
			@Pi_UserId AS LastModBy,Convert(varchar(10),Getdate(),121) AS LastModDate,@Pi_UserId AS AuthId,
			Convert(varchar(10),Getdate(),121) AS AuthDate
		INTO #PurTaxForDiff
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptProductTax B ON
				A.PurRcptId = B.PurRcptId
			INNER JOIN TaxConfiguration C ON
				B.TaxId = C.TaxId
			WHERE A.PurRcptRefNo = @Pi_ReferNo
			Group By C.InputTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0

		SELECT @DiffAmt=ISNULL((SUM(A.TotalAddition)-(SUM(B.Amount)+SUM(C.Amount))),0)
		FROM PurchaseReceipt A,#PurTaxForDiff B,#PurTotAdd C
		WHERE A.PurRcptRefNo = @Pi_ReferNo
		
		UPDATE #PurTaxForDiff SET Amount=Amount+@DiffAmt
		WHERE InputTaxId IN (SELECT MIN(InputTaxId) FROM #PurTaxForDiff)
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT * FROM #PurTaxForDiff

		--For Posting Scheme Discount in Details Table to Credit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3210002')
		BEGIN
			SET @Po_PurErrNo = -9
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3210002'
		SET @Amt = 0
		SELECT @Amt = LessScheme FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			AND LessScheme > 0
		
		IF @Amt > 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		END

		--For Posting Other Charges Add in Details Table For Debit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,B.CoaId,1,ISNULL(SUM(B.Amount),0),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptOtherCharges B ON
				A.PurRcptId = B.PurRcptId
			WHERE A.PurRcptRefNo = @Pi_ReferNo AND Effect = 0
			Group By B.CoaId
			HAVING ISNULL(SUM(B.Amount),0) > 0

		--For Posting Other Charges Reduce in Details Table To Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,B.CoaId,2,ISNULL(SUM(B.Amount),0),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReceipt A INNER JOIN PurchaseReceiptOtherCharges B ON
				A.PurRcptId = B.PurRcptId
			WHERE A.PurRcptRefNo = @Pi_ReferNo AND Effect = 1
			Group By B.CoaId
			HAVING ISNULL(SUM(B.Amount),0) > 0

		--For Posting Round Off Account reduce in Details Table to Debit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3220001')
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3220001'
		SET @Amt = 0
		SELECT @Amt = DifferenceAmount FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			AND DifferenceAmount > 0
		
		IF @Amt > 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,2,Abs(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		END

		--For Posting Round Off Account Add in Details Table to Credit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4210001')
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4210001'
		SET @Amt = 0
		SELECT @Amt = DifferenceAmount FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
			AND DifferenceAmount < 0
		
		IF @Amt < 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,1,ABS(@Amt),1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		END

		--For Posting Round Off Account Add in Details Table to Debit
		SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
		IF @sSql='-4'
		BEGIN
			SET @Po_PurErrNo = -4
			Return
		END
		ELSE IF @sSql='-5'
		BEGIN
			SET @Po_PurErrNo = -5
			Return
		END
		ELSE IF @sSql<>'0'
		BEGIN
			EXEC(@sSql)
		END

		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	END

	IF @Pi_TransId = 7 AND @Pi_SubTransId = 1	--Purchase Return
	BEGIN
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
				WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		--For Posting Purchase Return Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
		(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Purchase Return ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
		
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'
		--For Posting Purchase Return Account in Details Table on Debit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '4110002')
		BEGIN
			SET @Po_PurErrNo = -22
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '4110002'
		SELECT @Amt = GrossAmount FROM PurchaseReturn WHERE PurRetRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Supplier Account in Details Table to Credit
		IF NOT Exists (SELECT A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReturn C ON B.SpmId = C.SpmId
			WHERE C.PurRetRefNo = @Pi_ReferNo)
		BEGIN
			SET @Po_PurErrNo = -3
			Return
		END
		SELECT @CoaId = A.CoaId FROM CoaMaster A INNER JOIN Supplier B ON
			A.CoaId = B.CoaId INNER JOIN PurchaseReturn C ON B.SpmId = C.SpmId
			WHERE C.PurRetRefNo = @Pi_ReferNo
		SELECT @Amt = NetAmount FROM PurchaseReturn WHERE PurRetRefNo = @Pi_ReferNo
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Purchase Return Discount Account in Details Table to Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,D.CoaId,1,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = @Pi_ReferNo AND
				EffectInNetAmount = 2 AND B.BaseQtyAmount > 0
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',D.CoaId,1,B.BaseQtyAmount,1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			 FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + ''' AND
				EffectInNetAmount = 2 AND B.BaseQtyAmount > 0'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Purchase Return Addition Account in Details Table on Debit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,D.CoaId,2,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = @Pi_ReferNo AND B.RefCode <> 'D' AND
				EffectInNetAmount = 1 AND B.BaseQtyAmount > 0
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',D.CoaId,2,B.BaseQtyAmount,1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			 FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
				A.PurRetId = B.PurRetId
			INNER JOIN PurchaseSequenceMaster C ON
				A.PurSeqId = C.PurSeqId
			INNER JOIN PurchaseSequenceDetail D ON
				C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
			WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + ''' AND B.RefCode <> ''' + 'D' + ''' AND
				EffectInNetAmount = 1 AND B.BaseQtyAmount > 0'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Purchase Return Tax Account in Details Table on Debit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT @VocRefNo,C.InPutTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,Convert(varchar(10),Getdate(),121)
			FROM PurchaseReturn A INNER JOIN PurchaseReturnProductTax B ON
				A.PurRetId = B.PurRetId
			INNER JOIN TaxConfiguration C ON
				B.TaxId = C.TaxId
			WHERE A.PurRetRefNo = @Pi_ReferNo
			Group By C.InPutTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT ''' + @VocRefNo + ''',C.InPutTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,' +
			CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
			FROM PurchaseReturn A INNER JOIN PurchaseReturnProductTax B ON
				A.PurRetId = B.PurRetId
			INNER JOIN TaxConfiguration C ON
				B.TaxId = C.TaxId
			WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + '''
			Group By C.InPutTaxId
			HAVING ISNULL(SUM(B.TaxAmount),0) > 0'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		--For Posting Scheme Discount in Details Table to Credit
		IF NOT Exists (SELECT CoaId FROM CoaMaster Where AcCode = '3210002')
		BEGIN
			SET @Po_PurErrNo = -9
			Return
		END
		SELECT @CoaId = CoaId FROM CoaMaster Where AcCode = '3210002'
		SET @Amt = 0
		SELECT @Amt = LessScheme FROM PurchaseReturn WHERE PurRetRefNo = @Pi_ReferNo
			AND LessScheme > 0
		
		IF @Amt > 0
		BEGIN
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CoaId,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
		
			SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@CoaId as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'
			--INSERT INTO Translog(strSql1) Values (@sstr)
		END

		--For Posting Round Off Account Add in Details Table to Debit
			SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
			IF @sSql='-4'
			BEGIN
				SET @Po_PurErrNo = -4
				Return
			END
			ELSE IF @sSql='-5'
			BEGIN
				SET @Po_PurErrNo = -5
				Return
			END
			ELSE IF @sSql<>'0'
			BEGIN
				EXEC(@sSql)
			END
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			Return
		END
	END	
	IF @Pi_TransId = 13 AND @Pi_SubTransId = 0  -- Stock Out
	BEGIN

		IF EXISTS (SELECT SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo  AND SMT.Coaid=299)	
		BEGIN	
			SELECT @Amt=SUM(Amount)+SUM(TaxAmt) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
		END
		ELSE
		BEGIN
			SELECT @Amt=SUM(Amount) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
		END
				
		
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		
		
		--For Posting StockAdjustment StockAdd Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
			(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Stock Adjustment ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
				
			
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'
		
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=1
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo )
		BEGIN
			SET @Po_PurErrNo = -26
			Return
		END
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo )
		BEGIN
			SET @Po_PurErrNo = -27
			Return
		END
		SELECT @DCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=1
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 

		SELECT @CCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2 
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo AND SMT.Coaid<>299
			
		
		--For Posting Default Sales Account details on Debit
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@DCoaid,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@DCoaid as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'

			--For Posting Default Debtor Account details on Debit

			SELECT @Amt=SUM(Amount) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
			
			INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@CCoaid,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
				@Pi_UserId,Convert(varchar(10),Getdate(),121))
			SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
			(''' + @VocRefNo + ''',' + CAST(@CCoaid as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'

			IF EXISTS (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				WHERE SMP.StkMngRefNo=@Pi_ReferNo  AND SMT.Coaid=299)	
			BEGIN	

				SET @CCoaid=299

				SELECT @Amt=SUM(TaxAmt) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=1
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 

				IF @Amt > 0
				BEGIN
					INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
						LastModDate,AuthId,AuthDate) VALUES
					(@VocRefNo,@CCoaid,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
						@Pi_UserId,Convert(varchar(10),Getdate(),121))
					SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
						LastModDate,AuthId,AuthDate) VALUES
					(''' + @VocRefNo + ''',' + CAST(@CCoaid as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
						',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
						+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
						Convert(nvarchar(10),Getdate(),121) + ''')'
				END

			END



		--For Posting Round Off Account Add in Details Table to Debit
			SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
			IF @sSql='-4'
			BEGIN
				SET @Po_PurErrNo = -4
				Return
			END
			ELSE IF @sSql='-5'
			BEGIN
				SET @Po_PurErrNo = -5
				Return
			END
			ELSE IF @sSql<>'0'
			BEGIN
				EXEC(@sSql)
			END
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			RETURN
		END
	END
	IF @Pi_TransId = 13 AND @Pi_SubTransId = 1   -- Stock In
	BEGIN

		
		Select @Amt=SUM(Amount) FROM StockManagement SM
		INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
		INNER JOIN StockManagementType SMT ON SMT.StkMgmtTypeId=SMP.StkMgmtTypeId AND SMT.TransactionType=0
		WHERE SM.StkMngRefNo=@Pi_ReferNo


			
		IF EXISTS (SELECT AcpId from AcPeriod with (nolock) WHERE @Pi_VocDate between AcmSdt and AcmEdt)
		BEGIN
			SELECT @AcmId = AcmId ,@AcpId = AcpId from AcPeriod with (nolock)
			WHERE @Pi_VocDate between AcmSdt  and AcmEdt
		END
		ELSE
		BEGIN
			SET @Po_PurErrNo = 0
			Return
		END
		
		SELECT @VocRefNo = dbo.Fn_GetPrimaryKeyString('StdVocMaster','PurchaseVoc',
			CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
		IF LTRIM(RTRIM(@VocRefNo)) = ''
		BEGIN
			SET @Po_PurErrNo = -1
			Return
		END
		
		
		--For Posting StockAdjustment StockAdd Header Voucher
		INSERT INTO StdVocMaster(VocRefNo,AcmId,AcpId,VocType,VocDate,Remarks,Availability,LastModBy,
			LastModDate,AuthId,AuthDate,VocSubType,AutoGen,YEEntry) VALUES
			(@VocRefNo,@AcmId,@AcpId,@Pi_VocType,@Pi_VocDate,'Posted From Stock Adjustment ' + @Pi_ReferNo +
			' Dated ' + CONVERT(nVarChar(10),@Pi_VocDate,121),1,@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_UserId,
			Convert(varchar(10),Getdate(),121),@Pi_SubVocType,1,0)
				
		UPDATE Counters SET currvalue = currvalue + 1 WHERE Tabname = 'StdVocMaster' and fldname ='PurchaseVoc'
		
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=1
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo )
		BEGIN
			SET @Po_PurErrNo = -26
			Return
		END
		IF NOT Exists (Select SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo )
		BEGIN
			SET @Po_PurErrNo = -27
			Return
		END
				
		SELECT @DCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=1
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo  AND SMT.CoaId<>298

		SELECT @CCoaid=SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId AND DebitCredit=2
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo 
			
		
		--For Posting Default Purchase Account details on Debit
		
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
			(@VocRefNo,@DCoaid,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
				LastModDate,AuthId,AuthDate) VALUES
				(''' + @VocRefNo + ''',' + CAST(@DCoaid as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
				',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
				+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
				Convert(nvarchar(10),Getdate(),121) + ''')'


		IF EXISTS (SELECT SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId 
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				WHERE SMP.StkMngRefNo=@Pi_ReferNo AND DebitCredit=1 AND SMT.Coaid=298)	
		BEGIN

--			Select @Amt=SUM(TaxAmt) FROM StockManagement SM
--			INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
--			WHERE SM.StkMngRefNo=@Pi_ReferNo

			SELECT @Amt=SUM(TaxAmt) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId 
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo AND DebitCredit=1


			SET @DCoaid=298

			IF @Amt >0 
			BEGIN
				INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
					LastModDate,AuthId,AuthDate) VALUES
					(@VocRefNo,@DCoaid,1,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
					@Pi_UserId,Convert(varchar(10),Getdate(),121))
				SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
						LastModDate,AuthId,AuthDate) VALUES
						(''' + @VocRefNo + ''',' + CAST(@DCoaid as nVarChar(10)) + ',1,' + CAST(@Amt As nVarChar(25)) +
						',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
						+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
						Convert(nvarchar(10),Getdate(),121) + ''')'
			END

		END


--		Select @Amt=SUM(Amount)+SUM(TaxAmt) FROM StockManagement SM
--			INNER JOIN StockManagementProduct SMP ON SM.StkMngRefNo= SMP.StkMngRefNo
--			WHERE SM.StkMngRefNo=@Pi_ReferNo

			SELECT @Amt=SUM(Amount)+SUM(TaxAmt) FROM StockManagementTypeDt SMT 
				INNER JOIN StockManagementProduct SMP ON SMP.StkMgmtTypeId=SMT.StkMgmtTypeId 
				INNER JOIN StockManagementType SM ON SMP.StkMgmtTypeId=SM.StkMgmtTypeId AND SM.TransactionType=0
				INNER JOIN StockManagement Hd ON HD.StkMngRefNo=SMP.StkMngRefNo
				WHERE SMP.StkMngRefNo=@Pi_ReferNo AND DebitCredit=1
			

		--For Posting Default Purchase Account details on Credit
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CCoaid,2,@Amt,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
			@Pi_UserId,Convert(varchar(10),Getdate(),121))
		SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(''' + @VocRefNo + ''',' + CAST(@CCoaid as nVarChar(10)) + ',2,' + CAST(@Amt As nVarChar(25)) +
			',1,' + CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
			+ CAST(@Pi_UserId as nVarChar(10)) + ',''' +
			Convert(nvarchar(10),Getdate(),121) + ''')'



		--For Posting Round Off Account Add in Details Table to Debit
			SELECT @sSql=dbo.Fn_PostRoundOff(@VocRefNo,@Pi_UserId)
			IF @sSql='-4'
			BEGIN
				SET @Po_PurErrNo = -4
				Return
			END
			ELSE IF @sSql='-5'
			BEGIN
				SET @Po_PurErrNo = -5
				Return
			END
			ELSE IF @sSql<>'0'
			BEGIN
				EXEC(@sSql)
			END
		
		--Validate Credit amount is Equal to Debit
		IF NOT EXISTS (SELECT SUM(Amount) FROM(
			SELECT DebitCredit,CASE DebitCredit WHEN 1 then Sum(Amount)
				ELSE -1 * Sum(Amount) END as Amount FROM StdVocDetails
				WHERE VocRefNo = @VocRefNo Group by DebitCredit) as a
			Having SUM(Amount) = 0)
		BEGIN
			SET @Po_PurErrNo = -6
			RETURN
		END
	END
	IF @Po_PurErrNo=1
	BEGIN
			EXEC Proc_PostStdDetails @Pi_VocDate,@VocRefNo,1
	END
	Return
END
GO
if EXISTS (select * from dbo.sysobjects where id = object_id(N'[TrigStockManagementProduct_Track]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
DROP TRIGGER [TrigStockManagementProduct_Track]
GO
CREATE TRIGGER [dbo].[TrigStockManagementProduct_Track]
ON [dbo].[StockManagementProduct]
AFTER INSERT
AS
BEGIN
	--StockAction 1 Add,2 Reduce
	INSERT INTO Unsaleable_In (TransId,RefId,TransCode,TransDate,Prdid,Prdbatid,StockTypeId,LcnId,InQty,StockAction,TolcnId,ToStockTypeId)
	Select 3 AS TransId,0 AS RefId,StockManagement.StkMngRefNo AS TransCode,StkMngDate AS TransDate,PrdId,PrdBatId,
	INSERTED.StockTypeId,StockManagement.LcnId,TotalQty,1,StockManagement.LcnId,INSERTED.StockTypeId From StockManagement With (NoLock) Inner Join
	INSERTED On StockManagement.StkMngRefNo=INSERTED.StkMngRefNo
	INNER JOIN StockType ST With (NoLock) ON ST.StockTypeId=INSERTED.StockTypeId
	WHERE ST.SystemStockType=2 AND StockManagement.Status=1 AND INSERTED.StkMgmtTypeId=1
END
GO

--SRF-Nanda-209-030-From Kalai

DELETE FROM RptExcelHeaders WHERE RptId=3
INSERT INTO RptExcelHeaders VALUES (3,	1,	'SMId',	'SMId',	0,	1)
INSERT INTO RptExcelHeaders VALUES (3,	2,	'SMName',	'Salesman',	1,	1)
INSERT INTO RptExcelHeaders VALUES (3,	3,	'RMId',	'RMId',	0,	1)
INSERT INTO RptExcelHeaders VALUES (3,	4,	'RMName',	'Route',	1,	1)
INSERT INTO RptExcelHeaders VALUES (3,	5,	'RtrId',	'RtrId',	0,	1)
INSERT INTO RptExcelHeaders VALUES (3,	6,	'RtrCode',	'Retailer Code',	0,	1)
INSERT INTO RptExcelHeaders VALUES (3,	7,	'RtrName',	'Retailer',	1,	1)
INSERT INTO RptExcelHeaders VALUES (3,	8,	'SalId',	'SalId',	0,	1)
INSERT INTO RptExcelHeaders VALUES (3,	9,	'SalInvNo',	'Bill Number',	1,	1)
INSERT INTO RptExcelHeaders VALUES (3,	10,	'SalInvDate',	'Bill Date',	1,	1)
INSERT INTO RptExcelHeaders VALUES (3,	11,	'DueDate',	'Due Date',	1,	1)
INSERT INTO RptExcelHeaders VALUES (3,	12,	'SalInvRef',	'Doc Ref No',	0,	1)
INSERT INTO RptExcelHeaders VALUES (3,	13,	'BillAmount',	'Bill Amount',	1,	1)
INSERT INTO RptExcelHeaders VALUES (3,	14,	'CollectedAmount',	'Collected Amount',	1,	1)
INSERT INTO RptExcelHeaders VALUES (3,	15,	'BalanceAmount',	'Balance Amount',	1,	1)
INSERT INTO RptExcelHeaders VALUES (3,	16,	'ArDays',	'AR Days',	1,	1)


IF NOT  EXISTS (SELECT * FROM Sysobjects WHERE xType='U' AND Name='SalesInvoiceCrDays')
	BEGIN
		CREATE TABLE SalesInvoiceCrDays
		(
			SalId  BIGINT,
			RtrId  INT,
			CrDays NUMERIC(18,0),
			ConfigValue INT
		) 
	END 

IF EXISTS (SELECT * FROM sysobjects WHERE xtype='P' AND name='Proc_RptPendingBillReport')
DROP PROCEDURE  Proc_RptPendingBillReport
GO
--EXEC Proc_RptPendingBillReport 3,2,0,'CoreStockyTempReport',0,0,1
CREATE PROCEDURE [Proc_RptPendingBillReport]
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
	
	DECLARE @NewSnapId 	AS	INT
	DECLARE @DBNAME		AS 	nvarchar(50)
	DECLARE @TblName 	AS	nvarchar(500)
	DECLARE @TblStruct 	AS	nVarchar(4000)
	DECLARE @TblFields 	AS	nVarchar(4000)
	DECLARE @sSql		AS 	nVarChar(4000)
	DECLARE @ErrNo	 	AS	INT
	DECLARE @PurDBName	AS	nVarChar(50)
	
	DECLARE @AsOnDate	AS	DATETIME
	DECLARE @SMId 		AS	INT
	DECLARE @RMId	 	AS	INT
	DECLARE @RtrId	 	AS	INT
	DECLARE @SalId	 	AS	BIGINT
	DECLARE @PDCTypeId	 	AS	INT
	SELECT @AsOnDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
	SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
	SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
	SET @SalId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))
	SET @PDCTypeId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,77,@Pi_UsrId))
	
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@AsOnDate,@AsOnDate)
	Create TABLE #RptPendingBillsDetails
	(
			SMId 			INT,
			SMName			NVARCHAR(50),
			RMId 			INT,
			RMName 			NVARCHAR(50),
			RtrId         		INT,
			RtrCode         NVARCHAR(50),
			RtrName 		NVARCHAR(50),	
			SalId         		BIGINT,
			SalInvNo 		NVARCHAR(50),
			SalInvDate              DATETIME,
			DueDate              DATETIME,
			SalInvRef 		NVARCHAR(50),
			BillAmount      	NUMERIC (38,6),
			CollectedAmount 	NUMERIC (38,6),
			BalanceAmount   	NUMERIC (38,6),
			ArDays			INT
	)
	CREATE TABLE #TempReceiptInvoice
	(
		SalId		INT,
		InvInsSta	INT,
		InvInsAmt	NUMERIC(38,2)
	)
	
	SET @TblName = 'RptPendingBillsDetails'
	
	SET @TblStruct = '	SMId 			INT,
				SMName			NVARCHAR(50),
				RMId 			INT,
				RMName 			NVARCHAR(50),
				RtrId         		INT,
				RtrCode         NVARCHAR(50),
				RtrName 		NVARCHAR(50),	
				SalId         		BIGINT,
				SalInvNo 		NVARCHAR(50),
				SalInvDate              DATETIME,
				DueDate              DATETIME,
				SalInvRef 		NVARCHAR(50),
				BillAmount      	NUMERIC (38,6),
				CollectedAmount 	NUMERIC (38,6),
				BalanceAmount   	NUMERIC (38,6),
				ArDays			INT'
	
	SET @TblFields = 'SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName,SalId,SalInvNo,
			  SalInvDate,DueDate,SalInvRef,BillAmount,CollectedAmount,
			  BalanceAmount,ArDays'
	IF @Pi_GetFromSnap = 1
	BEGIN
		Select @DBNAME = DBName  FROM SnapShotHd WHERE SnapId = @Pi_SnapId
		SET @DBNAME = @DBNAME
	END
	ELSE
	BEGIN
		Select @DBNAME = CounterDesc  FROM CounterConfiguration WHERE SlNo = 3
		SET @DBNAME = @PI_DBNAME + @DBNAME
	END
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	 BEGIN
			IF @PDCTypeId=1 --Include PDC
			BEGIN
			
				SELECT  SI.SMId,S.SMName,SI.RMId,R.RMName,SI.RtrId,RE.RtrCode,RE.RtrName,SI.SalId,SI.Salinvno,SI.SalinvDate,DateAdd(d,SIC.CrDays,SI.SalinvDate) AS DueDate,
						SI.SalInvRef,SI.SalNetAmt,Cast(null as numeric(18,2))AS PaidAmt,
					    Cast(null as numeric(18,2))AS BalanceAmount ,DATEDIFF(Day,SI.SalInvDate,GetDate()) AS ArDays
				 INTO #PendingBills1
				 FROM Salesinvoice  SI INNER JOIN Salesman S ON S.SMId = SI.SMId
					   INNER JOIN RouteMaster R ON SI.RMId = R.RMId 
					   INNER JOIN Retailer RE ON SI.RtrId = RE.RtrId
					   LEFT OUTER JOIN SalesInvoiceCrDays SIC ON Si.SalId=SIC.SalID	
				 WHERE  SI.DlvSts IN(4,5)
						AND SI.SalInvDate <= CONVERT(DATETIME,@AsOnDate,103) AND
						(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
						SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
						AND
						(SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
						SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
						AND
						(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
						SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						AND
						(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR
						SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
				UPDATE #PendingBills1
				SET PAIDAMT=isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI, RECEIPT R WHERE RI.INVRCPNO=R.INVRCPNO AND R.INVRCPDATE <=CONVERT(DATETIME,@AsOnDate,103) AND INVRCPMODE=1 and CancelStatus=1  GROUP BY SALID)A
				WHERE #PendingBills1.SALID=a.SALID
				UPDATE #PendingBills1
				SET PAIDAMT=isnull(#PendingBills1.PaidAmt,0)+isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI WHERE INVRCPMODE<>1 and InvInsSta <> 4 GROUP BY SALID)A
				WHERE #PendingBills1.SALID=a.SALID
				Update #PendingBills1
				Set BalanceAmount = SalNetAmt-Isnull(PaidAmt,0)
				
				INSERT INTO #RptPendingBillsDetails
				select * from #pendingbills1
			END
			IF @PDCTypeId<>1 --Exclude PDC
			BEGIN
				SELECT  SI.SMId,S.SMName,SI.RMId,R.RMName,SI.RtrId,RE.RtrCode,RE.RtrName,SI.SalId,SI.Salinvno,SI.SalinvDate,DateAdd(d,SIC.CrDays,SI.SalinvDate) AS DueDate,
						SI.SalInvRef,SI.SalNetAmt,Cast(null as numeric(18,2))AS PaidAmt,
					    Cast(null as numeric(18,2))AS BalanceAmount ,DATEDIFF(Day,SalInvDate,GetDate()) AS ArDays
				 Into #PendingBills
				
				 FROM Salesinvoice  SI INNER JOIN Salesman S ON S.SMId = SI.SMId
					  INNER JOIN RouteMaster R ON SI.RMId = R.RMId
					  INNER JOIN Retailer RE  ON SI.RtrId = RE.RtrId
					  LEFT OUTER JOIN SalesInvoiceCrDays SIC ON Si.SalId=SIC.SalID	
				 WHERE  SI.DlvSts IN (4,5)
						and SI.SalInvDate <= CONVERT(DATETIME,@AsOnDate,103) AND
						(SI.SMId = (CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
						SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
						AND
						(SI.RMId = (CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
						SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
						AND
						(SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
						SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
						AND
						(SI.SalId = (CASE @SalId WHEN 0 THEN SI.SalId ELSE 0 END) OR
						SI.SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId)))
				UPDATE #PENDINGBILLS
				SET PAIDAMT=isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI, RECEIPT R WHERE RI.INVRCPNO=R.INVRCPNO AND R.INVRCPDATE <=CONVERT(DATETIME,@AsOnDate,103) AND INVRCPMODE=1 and CancelStatus=1  GROUP BY SALID)A
				WHERE #PENDINGBILLS.SALID=a.SALID
				UPDATE #PENDINGBILLS
				SET PAIDAMT=isnull(#PendingBills.PaidAmt,0)+isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI WHERE INVRCPMODE<>1 AND InvInsDate<=CONVERT(DATETIME,@AsOnDate,103) and InvInsSta <> 4 GROUP BY SALID)A
				WHERE #PENDINGBILLS.SALID=a.SALID
				Update #PendingBills
				Set BalanceAmount = SalNetAmt-Isnull(PaidAmt,0)
				INSERT INTO #RptPendingBillsDetails
				select * from #pendingbills
			END
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptPendingBillsDetails ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+' WHERE (SMId = (CASE ' + CAST(@SMId AS nVarchar(10)) + ' WHEN 0 THEN SMId ELSE 0 END) OR' +
				' SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',1,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (RMId = (CASE ' + CAST(@RMId AS nVarchar(10)) + ' WHEN 0 THEN RMId ELSE 0 END) OR '+
				'RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',2,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (RtrId = (CASE ' + CAST(@RtrId AS nVarchar(10)) + ' WHEN 0 THEN RtrId ELSE 0 END) OR ' +
				'RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',3,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND (SalId = (CASE ' + CAST(@SalId AS nVarchar(10)) + ' WHEN 0 THEN SalId ELSE 0 END) OR '+
				'SalId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',14,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))
				AND SalInvDate<=''' + @AsOnDate + ''''
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptPendingBillsDetails'
	
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
		SET @SSQL = 'INSERT INTO #RptPendingBillsDetails ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptPendingBillsDetails
-- Till Here
--	SELECT * FROM #RptPendingBillsDetails ORDER BY SMId,SalId,ArDays,SalInvDate
	--Added by Thiru on 13/11/2009
	DELETE FROM #RptPendingBillsDetails WHERE (BillAmount-CollectedAmount)<=0
	SELECT * FROM #RptPendingBillsDetails ORDER BY ArDays DESC

	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptId=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptPendingBillsDetails_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptPendingBillsDetails_Excel
		SELECT  * INTO RptPendingBillsDetails_Excel FROM #RptPendingBillsDetails
	END

	RETURN
END
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_DownloadNotification]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_DownloadNotification]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_DownloadNotification 1,2
SELECT SelectQuery,* FROM CustomUpDownloadCount WHERE UpDownload='Download' AND SelectQuery<>''
ORDER BY SlNo
SELECT * FROM Cs2Cn_Prk_DownloadedDetails
ROLLBACK TRANSACTION 
*/

CREATE PROCEDURE [dbo].[Proc_DownloadNotification]
(
		@Pi_UpDownload  INT,
		@Pi_Mode  INT				
)
AS
/*********************************
* PROCEDURE		: Proc_DownloadNotification
* PURPOSE		: To get the Download Notification
* CREATED		: Nandakumar R.G
* CREATED DATE	: 25/01/2010
* MODIFIED
* DATE			AUTHOR				DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON

	/*
	@Pi_UpDownload	= 1 -->Download
	@Pi_UpDownload	= 2 -->Upload
	@Pi_Mode		= 1 -->Before
	@Pi_Mode		= 2 -->After
	*/

	DECLARE @Str	NVARCHAR(4000)
	DECLARE @SlNo	INT
	DECLARe @Module		NVARCHAR(200)
	DECLARE @MainTable	NVARCHAR(200)
	DECLARE @KeyField1	NVARCHAR(200)
	DECLARE	@KeyField2	NVARCHAR(200)
	DECLARE @KeyField3	NVARCHAR(200)
	DECLARE @DistCode	NVARCHAR(100)


	SELECT @DistCode=DistributorCode FROM Distributor

	DELETE FROM Cs2Cn_Prk_DownloadedDetails WHERE UploadFlag='Y'

	IF @Pi_UpDownload =1
	BEGIN	
		DECLARE Cur_DwCount	 Cursor
		FOR SELECT DISTINCT SlNo,Module,MainTable,KeyField1,KeyField2,KeyField3 FROM CustomUpDownloadCount (NOLOCK)	
		WHERE UpDownload='Download'		
		ORDER BY SlNo		
		OPEN Cur_DwCount
		FETCH NEXT FROM Cur_DwCount INTO @SlNo,@Module,@MainTable,@KeyField1,@KeyField2,@KeyField3
		WHILE @@FETCH_STATUS=0
		BEGIN
			
			IF @Pi_Mode=1
			BEGIN		
				IF @KeyField1='DownloadFlag'
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET OldMax=0,OldCount=0 WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
				ELSE IF @KeyField1<>'' AND @KeyField3=''	
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET OldMax=A.OldMax,OldCount=A.OldCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS OldMax,ISNULL(COUNT('+@KeyField1+'),0) AS OldCount FROM '+@MainTable+') A
					WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
				ELSE IF @KeyField1<>'' AND @KeyField3<>''	
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET OldMax=A.OldMax ,OldCount=A.OldCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS OldMax,ISNULL(COUNT('+@KeyField1+'),0) AS OldCount FROM '+@MainTable+' WHERE '+@KeyField3+') A
					WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
			END
			ELSE IF @Pi_Mode=2
			BEGIN		
				IF @KeyField1='DownloadFlag'
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET NewMax=A.NewMax,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT('+@KeyField1+'),0) AS NewCount FROM '+@MainTable+' WHERE DownLoadFlag=''Y'') A
					WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo
				END
				ELSE IF @KeyField1<>'' AND @KeyField3=''	
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET NewMax=A.NewMax,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT('+@KeyField1+'),0) AS NewCount FROM '+@MainTable+') A
					WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
				ELSE IF @KeyField1<>'' AND @KeyField3<>''	
				BEGIN
					SELECT @Str='UPDATE CustomUpDownloadCount SET NewMax=A.NewMax ,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT('+@KeyField1+'),0) AS NewCount FROM '+@MainTable+' WHERE '+@KeyField3+') A
					WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo 
				END
			END
		

			EXEC (@Str)

			IF @Pi_Mode=2
			BEGIN		
				UPDATE CustomUpDownloadCount SET DownloadedCount=NewCount-OldCount WHERE UpDownload='Download'

				SET @Str=''

				SELECT @Str=REPLACE(SelectQuery,'OldMax',OldMax) FROM CustomUpDownloadCount WHERE UpDownload='Download' AND SlNo=@SlNo

				IF @Str<>''
				BEGIN

					SET @Str=REPLACE(@Str,'SELECT ',' SELECT '''+@DistCode+''','''+@Module+''',')

					IF @SlNo=214 OR @SlNo=218
					BEGIN
						SET @Str='INSERT INTO Cs2Cn_Prk_DownloadedDetails(DistCode,Process,Detail1,Detail2,Detail3) '+@Str
					END
					ELSE
					BEGIN
						SET @Str='INSERT INTO Cs2Cn_Prk_DownloadedDetails(DistCode,Process,Detail1,Detail2)'+@Str
					END

					PRINT @Str
					EXEC (@Str)
				
					UPDATE Cs2Cn_Prk_DownloadedDetails SET DownLoadedDate=GETDATE(),UploadFlag='N' WHERE UploadFlag IS NULL

					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail1=''  WHERE Detail1  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail2=''  WHERE Detail2  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail3=''  WHERE Detail3  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail4=''  WHERE Detail4  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail5=''  WHERE Detail5  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail6=''  WHERE Detail6  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail7=''  WHERE Detail7  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail8=''  WHERE Detail8  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail9=''  WHERE Detail9  IS NULL
					UPDATE Cs2Cn_Prk_DownloadedDetails SET Detail10='' WHERE Detail10 IS NULL
				END

			END

			FETCH NEXT FROM Cur_DwCount INTO @SlNo,@Module,@MainTable,@KeyField1,@KeyField2,@KeyField3
		END

		CLOSE Cur_DwCount
		DEALLOCATE Cur_DwCount
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-166-008

--DEFAULT VALUES SCRIPT FOR Tbl_UploadIntegration
--SELECT * FROM Tbl_UploadIntegration
DELETE FROM Tbl_UploadIntegration

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (1,'Upload Record Check','UploadRecordCheck','Cs2Cn_Prk_UploadRecordCheck',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (2,'Retailer','Retailer','Cs2Cn_Prk_Retailer',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (3,'Daily Sales','Daily_Sales','Cs2Cn_Prk_DailySales',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (4,'Stock','Stock','Cs2Cn_Prk_Stock',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (5,'Sales Return','Sales_Return','Cs2Cn_Prk_SalesReturn',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (6,'Purchase Confirmation','Purchase_Confirmation','Cs2Cn_Prk_PurchaseConfirmation',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (7,'Purchase Return','Purchase_Return','Cs2Cn_Prk_PurchaseReturn',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (8,'Claims','Claims','Cs2Cn_Prk_ClaimAll',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (9,'Scheme Utilization','Scheme_Utilization','Cs2Cn_Prk_SchemeUtilizationDetails',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (10,'Sample Issue','Sample_Issue','Cs2Cn_Prk_SampleIssue',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (11,'Sample Receipt','Sample_Receipt','Cs2Cn_Prk_SampleReceipt',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (12,'Sample Return','Sample_Return','Cs2Cn_Prk_SampleReturn',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (13,'Salesman','Salesman','Cs2Cn_Prk_Salesman',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (14,'Route','Route','Cs2Cn_Prk_Route',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (15,'Retailer Route','Retailer_Route','Cs2Cn_Prk_RetailerRoute',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (16,'Order Booking','Order_Booking','Cs2Cn_Prk_OrderBooking',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (17,'Sales Invoice Orders','Sales_Invoice_Orders','Cs2Cn_Prk_SalesInvoiceOrders',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (18,'Scheme Claim Details','Scheme_Claim_Details','Cs2Cn_Prk_Claim_SchemeDetails',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (19,'Daily Business Details','Daily_Business_Details','Cs2Cn_Prk_DailyBusinessDetails',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (20,'DB Details','DB_Details','Cs2Cn_Prk_DBDetails',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (21,'Download Tracing','DownloadTracing','Cs2Cn_Prk_DownLoadTracing',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (22,'Upload Tracing','UploadTracing','Cs2Cn_Prk_UpLoadTracing',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (23,'Daily Retailer Details','Daily_Retailer_Details','Cs2Cn_Prk_DailyRetailerDetails',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (24,'Daily Product Details','Daily_Product_Details','Cs2Cn_Prk_DailyProductDetails',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (25,'Cluster Assign','Cluster_Assign','Cs2Cn_Prk_ClusterAssign',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (26,'Purchase Order','Purchase_Order','Cs2Cn_Prk_PurchaseOrder',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (27,'Route Village','Route_Village','Cs2Cn_Prk_RouteVillage',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (1001,'ReUpload Initiate','ReUploadInitiate','Cs2Cn_Prk_ReUploadInitiate',GETDATE())

INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
VALUES (1002,'Downloaded Details','Downloaded_Details','Cs2Cn_Prk_DownloadedDetails',GETDATE())

--INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
--VALUES (1003,'Sync Details','Sync_Details','Cs2Cn_Prk_SyncDetails',GETDATE())

--SELECT * FROM Tbl_DownloadIntegration
--DEFAULT VALUES SCRIPT FOR Tbl_DownloadIntegration

DELETE FROM Tbl_DownloadIntegration

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (1,'Hierarchy Level','Cn2Cs_Prk_HierarchyLevel','Proc_Import_HierarchyLevel',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (2,'Hierarchy Level Value','Cn2Cs_Prk_HierarchyLevelValue','Proc_Import_HierarchyLevelValue',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (3,'Retailer Hierarchy','Cn2Cs_Prk_BLRetailerCategoryLevelValue','Proc_ImportBLRtrCategoryLevelValue',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (4,'Retailer Classification','Cn2Cs_Prk_BLRetailerValueClass','Proc_ImportBLRetailerValueClass',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (5,'Prefix Master','Cn2Cs_Prk_PrefixMaster','Proc_Import_PrefixMaster',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (6,'Retailer Approval','Cn2Cs_Prk_RetailerApproval','Proc_Import_RetailerApproval',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (7,'UOM','Cn2Cs_Prk_BLUOM','Proc_ImportBLUOM',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (8,'Tax Configuration Group Setting','Etl_Prk_TaxConfig_GroupSetting','Proc_ImportTaxMaster',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (9,'Tax Settings','Etl_Prk_TaxSetting','Proc_ImportTaxConfigGroupSetting',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (10,'Product Hierarchy Change','Cn2Cs_Prk_BLProductHiereachyChange','Proc_ImportBLProductHiereachyChange',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (11,'Product','Cn2Cs_Prk_Product','Proc_Import_Product',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (12,'Product Batch','Cn2Cs_Prk_ProductBatch','Proc_Import_ProductBatch',0,200,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (13,'Product Tax Mapping','Etl_Prk_TaxMapping','Proc_ImportTaxGrpMapping',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (14,'Special Rate','Cn2Cs_Prk_SpecialRate','Proc_Import_SpecialRate',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (15,'Scheme Header Slabs Rules','Etl_Prk_SchemeHD_Slabs_Rules','Proc_ImportSchemeHD_Slabs_Rules',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (16,'Scheme Products','Etl_Prk_SchemeProducts_Combi','Proc_ImportSchemeProducts_Combi',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (17,'Scheme Attributes','Etl_Prk_Scheme_OnAttributes','Proc_ImportScheme_OnAttributes',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (18,'Scheme Free Products','Etl_Prk_Scheme_Free_Multi_Products','Proc_ImportScheme_Free_Multi_Products',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (19,'Scheme On Another Product','Etl_Prk_Scheme_OnAnotherPrd','Proc_ImportScheme_OnAnotherPrd',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (20,'Scheme Retailer Validation','Etl_Prk_Scheme_RetailerLevelValid','Proc_ImportScheme_RetailerLevelValid',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (21,'Purchase','Cn2Cs_Prk_BLPurchaseReceipt','Proc_ImportBLPurchaseReceipt',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (22,'Purchase Receipt Mapping','Cn2Cs_Prk_PurchaseReceiptMapping','Proc_Import_PurchaseReceiptMapping',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (23,'Scheme Master Control','Cn2Cs_Prk_NVSchemeMasterControl','Proc_ImportNVSchemeMasterControl',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (24,'Claim Norm','Cn2Cs_Prk_ClaimNorm','Proc_Import_ClaimNorm',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (25,'Reason Master','Cn2Cs_Prk_ReasonMaster','Proc_Import_ReasonMaster',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (26,'Bulletin Board','Cn2Cs_Prk_BulletinBoard','Proc_Import_BulletinBoard',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (27,'ERP Product Mapping','Cn2Cs_Prk_ERPPrdCCodeMapping','Proc_Import_ERPPrdCCodeMapping',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (28,'Configuration','Cn2Cs_Prk_Configuration','Proc_Import_Configuration',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (29,'Claim Settlement','Cn2Cs_Prk_ClaimSettlementDetails','Proc_Import_ClaimSettlementDetails',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (30,'Cluster Master','Cn2Cs_Prk_ClusterMaster','Proc_Import_ClusterMaster',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (31,'Cluster Group','Cn2Cs_Prk_ClusterGroup','Proc_Import_ClusterGroup',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (32,'Cluster Assign Approval','Cn2Cs_Prk_ClusterAssignApproval','Proc_Import_ClusterAssignApproval',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (33,'Supplier','Cn2Cs_Prk_SupplierMaster','Proc_Import_SupplierMaster',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (34,'UDC Master','Cn2Cs_Prk_UDCMaster','Proc_Import_UDCMaster',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (35,'UDC Details','Cn2Cs_Prk_UDCDetails','Proc_Import_UDCDetails',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (36,'UDC Defaults','Cn2Cs_Prk_UDCDefaults','Proc_Import_UDCDefaults',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (37,'Retailer Migration','Cn2Cs_Prk_RetailerMigration','Proc_Import_RetailerMigration',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (38,'Points Rules Header','Cn2Cs_Prk_PointsRulesHeader','Proc_Import_PointsRulesHeader',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (39,'Points Rules Retailer','Cn2Cs_Prk_PointsRulesRetailer','Proc_Import_PointsRulesRetailer',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (40,'Points Rules Slab','CN2CS_Prk_PointsRulesSlab','Proc_Import_PointsRulesSlab',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (41,'Points Rules Slab Product','Cn2Cs_Prk_PointsRulesProduct','Proc_Import_PointsRulesSlabProduct',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (42,'ReUpload','Cn2Cs_Prk_ReUpload','Proc_Import_ReUpload',0,500,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (43,'Purchase Receipt Adjustments','Cn2Cs_Prk_PurchaseReceiptAdjustments','Proc_Import_PurchaseReceiptAdjustments',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (44,'Village Master','Cn2Cs_Prk_VillageMaster','Proc_Import_VillageMaster',0,100,GETDATE())

INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
VALUES (45,'Scheme Payout','Cn2Cs_Prk_SchemePayout','Proc_Import_SchemePayout',0,100,GETDATE())

--DEFAULT VALUES SCRIPT FOR CustomUpDownload
--SELECT * FROM CustomUpDownload WHERE UpDownLoad='Upload' ORDER BY SlNo
DELETE FROM CustomUpDownload

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (101,1,'Retailer','Retailer','Proc_Cs2Cn_Retailer','Proc_ImportRetailer','Cs2Cn_Prk_Retailer','Proc_CN2CSRetailer','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (102,1,'Daily Sales','Daily Sales','Proc_Cs2Cn_DailySales','Proc_ImportBLDailySales','Cs2Cn_Prk_DailySales','Proc_ValidateDailySales','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (103,1,'Stock','Stock','Proc_Cs2Cn_Stock','Proc_ImportStock','Cs2Cn_Prk_Stock','Proc_ValidateStock','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (104,1,'Sales Return','Sales Return','Proc_Cs2Cn_SalesReturn','Proc_ImportBLSalesReturn','Cs2Cn_Prk_SalesReturn','Proc_CN2CSBLSalesReturn','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (105,1,'Purchase Confirmation','Purchase Confirmation','Proc_Cs2Cn_PurchaseConfirmation','Proc_ImportPurchaseConfirmation','Cs2Cn_Prk_PurchaseConfirmation','Proc_CN2CSBLPurchaseConfirmation','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (106,1,'Purchase Return','Purchase Return','Proc_Cs2Cn_PurchaseReturn','Proc_ImportPurchaseReturn','Cs2Cn_Prk_PurchaseReturn','Proc_CN2CSPurchaseReturn','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (107,1,'Claims','Claims','Proc_Cs2Cn_ClaimAll','Proc_ImportBLClaimAll','Cs2Cn_Prk_ClaimAll','Proc_Cn2Cs_BLClaimAll','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (108,1,'Scheme Utilization','Scheme Utilization','Proc_Cs2Cn_SchemeUtilizationDetails','Proc_Import_SchemeUtilizationDetails','Cs2Cn_Prk_SchemeUtilizationDetails','Proc_Cn2Cs_SchemeUtilizationDetails','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (109,1,'Sample Issue','Sample Issue','Proc_Cs2Cn_SampleIssue','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleIssue','Proc_ValidateSampleIssue','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (110,1,'Sample Receipt','Sample Receipt','Proc_Cs2Cn_SampleReturn','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleReceipt','Proc_ValidateSampleIssue','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (111,1,'Sample Return','Sample Return','Proc_Cs2Cn_SampleReturn','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleReturn','Proc_ValidateSampleIssue','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (112,1,'Purchase Order','Purchase Order','Proc_Cs2Cn_PurchaseOrder','Proc_Import_PurchaseOrder','Cs2Cn_Prk_PurchaseOrder','Proc_Cn2Cs_PurchaseOrder','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (113,1,'Order Booking','Order Booking','Proc_Cs2Cn_OrderBooking','Proc_Import_OrderBooking','Cs2Cn_Prk_OrderBooking','Proc_Cn2Cs_OrderBooking','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (114,1,'Sales Invoice Orders','Sales Invoice Orders','Proc_Cs2Cn_Dummy','Proc_Import_SalesInvoiceOrders','Cs2Cn_Prk_SalesInvoiceOrders','Proc_Cn2Cs_SalesInvoiceOrders','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (115,1,'Salesman','Salesman','Proc_Cs2Cn_Salesman','Proc_Import_Salesman','Cs2Cn_Prk_Salesman','Proc_Cn2Cs_Salesman','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (116,1,'Route','Route','Proc_Cs2Cn_Route','Proc_Import_Route','Cs2Cn_Prk_Route','Proc_Cn2Cs_Route','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (117,1,'Retailer Route','Retailer Route','Proc_Cs2Cn_RetailerRoute','Proc_Import_RetailerRoute','Cs2Cn_Prk_RetailerRoute','Proc_Cn2Cs_RetailerRoute','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (118,1,'Route Village','Route Village','Proc_Cs2Cn_RouteVillage','Proc_Import_RouteVillage','Cs2Cn_Prk_RouteVillage','Proc_Cn2Cs_RouteVillage','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (119,1,'Cluster Assign','Cluster Assign','Proc_Cs2Cn_ClusterAssign','Proc_Import_ClusterAssign','Cs2Cn_Prk_ClusterAssign','Proc_Cn2Cs_ClusterAssign','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (120,1,'Daily Business Details','Daily Business Details','Proc_Cs2Cn_DailyBusinessDetails','Proc_Import_DailyBusinessDetails','Cs2Cn_Prk_DailyBusinessDetails','Proc_Cn2Cs_DailyBusinessDetails','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (121,1,'DB Details','DB Details','Proc_Cs2Cn_DBDetails','Proc_Import_DBDetails','Cs2Cn_Prk_DBDetails','Proc_Cn2Cs_DBDetails','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (122,1,'Download Trace','DownloadTracing','Proc_Cs2Cn_DownLoadTracing','Proc_ImportDownLoadTracing','ETL_PRK_CS2CNDownLoadTracing','Proc_Cn2CsDownLoadTracing','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (123,1,'Upload Trace','UploadTracing','Proc_Cs2Cn_UpLoadTracing','Proc_ImportUpLoadTracing','ETL_PRK_CS2CNUpLoadTracing','Proc_Cn2CsUpLoadTracing','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (124,1,'Daily Retailer Details','Daily Retailer Details','Proc_Cs2Cn_DailyRetailerDetails','','Cs2Cn_Prk_DailyRetailerDetails','','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (125,1,'Daily Product Details','Daily Product Details','Proc_Cs2Cn_DailyProductDetails','','Cs2Cn_Prk_DailyProductDetails','','Master','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (126,1,'Upload Record Check','UploadRecordCheck','Proc_Cs2Cn_UploadRecordCheck','','Cs2Cn_Prk_UploadRecordCheck','','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (127,1,'ReUpload Initiate','ReUploadInitiate','Proc_Cs2Cn_ReUploadInitiate','','Cs2Cn_Prk_ReUploadInitiate','','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (128,1,'For Integration','ForIntegration','Proc_IntegrationHouseKeeping','','Cs2Cn_Prk_IntegrationHouseKeeping','','Transaction','Upload',1)

--DEFAULT VALUES SCRIPT FOR CustomUpDownload
--SELECT * FROM CustomUpDownload WHERE UpDownLoad='Download' ORDER BY SlNo
INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (201,1,'Hierarchy Level','Hieararchy Level','Proc_Cs2Cn_HierarchyLevel','Proc_Import_HierarchyLevel','Cn2Cs_Prk_HierarchyLevel','Proc_Cn2Cs_HierarchyLevel','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (202,1,'Hierarchy Level Value','Hieararchy Level Value','Proc_Cs2Cn_HierarchyLevelValue','Proc_Import_HierarchyLevelValue','Cn2Cs_Prk_HierarchyLevelValue','Proc_Cn2Cs_HierarchyLevelValue','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (203,1,'Retailer Category Level Value','Retailer Category Level Value','Proc_CS2CNBLRetailerCategoryLevelValue','Proc_ImportBLRtrCategoryLevelValue','Cn2Cs_Prk_BLRetailerCategoryLevelValue','Proc_Cn2Cs_BLRetailerCategoryLevelValue','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (204,1,'Retailer Value Classification','Retailer Value Classification','Proc_CS2CNBLRetailerValueClass','Proc_ImportBLRetailerValueClass','Cn2Cs_Prk_BLRetailerValueClass','Proc_Cn2Cs_BLRetailerValueClass','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (205,1,'Prefix Master','Prefix Master','Proc_Cs2Cn_PrefixMaster','Proc_Import_PrefixMaster','Cn2Cs_Prk_PrefixMaster','Proc_Cn2Cs_PrefixMaster','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (206,1,'Retailer Aproval','Retailer Approval','Proc_Cs2Cn_RetailerApproval','Proc_Import_RetailerApproval','Cn2Cs_Prk_RetailerApproval','Proc_Cn2Cs_RetailerApproval','Master','Download',0)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (207,1,'UOM','UOM','Proc_Cn2Cs_BLUOM','Proc_ImportBLUOM','Cn2Cs_Prk_BLUOM','Proc_Cn2Cs_BLUOM','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (208,1,'Tax Configuration','Tax Configuration','Proc_ValidateTaxConfig_Group','Proc_ImportTaxMaster','Etl_Prk_TaxConfig_GroupSetting','Proc_ValidateTaxConfig_Group','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (209,1,'Tax Setting','Tax Setting','Proc_CN2CS_TaxSetting','Proc_ImportTaxConfigGroupSetting','Etl_Prk_TaxSetting','Proc_CN2CS_TaxSetting','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (210,1,'Product Hierarchy Change','Product Hierarchy Change','Proc_CS2CNBLProductHierarchyChange','Proc_ImportBLProductHiereachyChange','Cn2Cs_Prk_BLProductHiereachyChange','Proc_Cn2Cs_BLProductHiereachyChange','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (211,1,'Product','Product','Proc_Cs2Cn_Product','Proc_Import_Product','Cn2Cs_Prk_Product','Proc_Cn2Cs_Product','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (212,1,'Product Batch','Product Batch','Proc_Cs2Cn_ProductBatch','Proc_Import_ProductBatch','Cn2Cs_Prk_ProductBatch','Proc_Cn2Cs_ProductBatch','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (213,1,'Tax Group Mapping','Tax Group Mapping','Proc_ValidateTaxMapping','Proc_ImportTaxGrpMapping','Etl_Prk_TaxMapping','Proc_ValidateTaxMapping','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (214,1,'Special Rate','Special Rate','Proc_Cs2Cn_SpecialRate','Proc_Import_SpecialRate','Cn2Cs_Prk_SpecialRate','Proc_Cn2Cs_SpecialRate','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (215,1,'Cluster Master','Cluster Master','Proc_Cs2Cn_ClusterMaster','Proc_Import_ClusterMaster','Cn2Cs_Prk_ClusterMaster','Proc_Cn2Cs_ClusterMaster','Master','Download',1)	

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (216,1,'Cluster Group','Cluster Group','Proc_Cs2Cn_ClusterGroup','Proc_Import_ClusterGroup','Cn2Cs_Prk_ClusterGroup','Proc_Cn2Cs_ClusterGroup','Master','Download',1)	

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (217,1,'Scheme','Scheme Master','Proc_CS2CNBLSchemeMaster','Proc_ImportBLSchemeMaster','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeMaster','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (217,2,'Scheme','Scheme Attributes','Proc_CS2CNBLSchemeAttributes','Proc_ImportBLSchemeAttributes','Etl_Prk_Scheme_OnAttributes','Proc_CN2CS_BLSchemeAttributes','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (217,3,'Scheme','Scheme Products','Proc_CS2CNBLSchemeProducts','Proc_ImportBLSchemeProducts','Etl_Prk_SchemeProducts_Combi','Proc_CN2CS_BLSchemeProducts','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (217,4,'Scheme','Scheme Slabs','Proc_CS2CNBLSchemeSlab','Proc_ImportBLSchemeSlab','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeSlab','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (217,5,'Scheme','Scheme Rule Setting','Proc_CS2CNBLSchemeRulesetting','Proc_ImportBLSchemeRulesetting','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeRulesetting','Transaction','Download',0)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (217,6,'Scheme','Scheme Free Products','Proc_CS2CNBLSchemeFreeProducts','Proc_ImportBLSchemeFreeProducts','Etl_Prk_Scheme_Free_Multi_Products','Proc_CN2CS_BLSchemeFreeProducts','Transaction','Download',0)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (217,7,'Scheme','Scheme Combi Products','Proc_CS2CNBLSchemeCombiPrd','Proc_ImportBLSchemeCombiPrd','Etl_Prk_SchemeProducts_Combi','Proc_CN2CS_BLSchemeCombiPrd','Transaction','Download',0)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (217,8,'Scheme','Scheme On Another Product','Proc_CS2CNBLSchemeOnAnotherPrd','Proc_ImportBLSchemeOnAnotherPrd','Etl_Prk_Scheme_OnAnotherPrd','Proc_CN2CS_BLSchemeOnAnotherPrd','Transaction','Download',0)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (218,1,'Scheme Master Control','Scheme Master Control','Proc_CS2CNNVSchemeMasterControl','Proc_ImportNVSchemeMasterControl','Cn2Cs_Prk_NVSchemeMasterControl','Proc_Cn2Cs_NVSchemeMasterControl','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (219,1,'Claim Settlement','Claim Settlement','Proc_Cs2Cn_ClaimSettlementDetails','Proc_Import_ClaimSettlementDetails','Cn2Cs_Prk_ClaimSettlementDetails','Proc_Cn2Cs_ClaimSettlementDetails','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (220,1,'Purchase Receipt','Purchase Receipt','Proc_Cs2Cn_PurchaseReceipt','Proc_ImportBLPurchaseReceipt','Cn2Cs_Prk_BLPurchaseReceipt','Proc_Cn2Cs_PurchaseReceipt','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (221,1,'Purchase Receipt Mapping','Purchase Receipt Mapping','Proc_Cs2Cn_PurchaseReceiptMapping','Proc_Import_PurchaseReceiptMapping','Cn2Cs_Prk_PurchaseReceiptMapping','Proc_Cn2Cs_PurchaseReceiptMapping','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (222,1,'Claim Norm Mapping','Claim Norm Mapping','Proc_Cs2Cn_ClaimNorm','Proc_Import_ClaimNorm','Cn2Cs_Prk_ClaimNorm','Proc_Cn2Cs_ClaimNorm','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (223,1,'Reason Master','Reason Master','Proc_Cs2Cn_ReasonMaster','Proc_Import_ReasonMaster','Cn2Cs_Prk_ReasonMaster','Proc_Cn2Cs_ReasonMaster','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (224,1,'Bulletin Board','BulletingBoard','Proc_Cs2Cn_BulletinBoard','Proc_Import_BulletinBoard','Cn2Cs_Prk_BulletinBoard','Proc_Cn2Cs_BulletinBoard','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (225,1,'ERP Product Mapping','ERP Product Mapping','Proc_Cs2Cn_ERPPrdCCodeMapping','Proc_Import_ERPPrdCCodeMapping','Cn2Cs_Prk_ERPPrdCCodeMapping','Proc_Cn2Cs_ERPPrdCCodeMapping','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (226,1,'Configuration','Configuration','Proc_Cs2Cn_Configuration','Proc_Import_Configuration','Cn2Cs_Prk_Configuration','Proc_Cn2Cs_Configuration','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (227,1,'Cluster Assign Approval','Cluster Assign Approval','Proc_Cs2Cn_ClusterAssignApproval','Proc_Import_ClusterAssignApproval','Cn2Cs_Prk_ClusterAssignApproval','Proc_Cn2Cs_ClusterAssignApproval','Master','Download',1)	

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (228,1,'Supplier Master','Supplier Master','Proc_Cs2Cn_SupplierMaster','Proc_Import_SupplierMaster','Cn2Cs_Prk_SupplierMaster','Proc_Cn2Cs_SupplierMaster','Master','Download',1)	

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (229,1,'UDC Master','UDC Master','Proc_Cs2Cn_UDCMaster','Proc_Import_UDCMaster','Cn2Cs_Prk_UDCMaster','Proc_Cn2Cs_UDCMaster','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (230,1,'UDC Details','UDC Details','Proc_Cs2Cn_UDCDetailss','Proc_Import_UDCDetails','Cn2Cs_Prk_UDCDetails','Proc_Cn2Cs_UDCDetails','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (231,1,'UDC Defaults','UDC Defaults','Proc_Cs2Cn_UDCDefaults','Proc_Import_UDCDefaults','Cn2Cs_Prk_UDCDefaults','Proc_Cn2Cs_UDCDefaults','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (232,1,'Retailer Migration','Retailer Migration','Proc_Cs2Cn_RetailerMigration','Proc_Import_RetailerMigration','Cn2Cs_Prk_RetailerMigration','Proc_Cn2Cs_RetailerMigration','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (233,1,'Point Redemption Rules','Point Redemption Rules','Proc_Cs2Cn_PointsRulesSetting','Proc_Import_PointsRulesSetting','Cn2Cs_Prk_PointsRulesHeader','Proc_Cn2Cs_PointsRulesSetting','Master','Download',1)	

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (234,1,'Village Master','Village Master','Proc_Cs2Cn_VillageMaster','Proc_Import_VillageMaster','Cn2Cs_Prk_VillageMaster','Proc_Cn2Cs_Dummy','Master','Download',1)	

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (235,1,'Scheme Payout','Scheme Payout','Proc_Cs2Cn_SchemePayout','Proc_Import_SchemePayout','Cn2Cs_Prk_SchemePayout','Proc_Cn2Cs_SchemePayout','Transaction','Download',1)	

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (236,1,'ReUpload','ReUpload','Proc_Cs2Cn_ReUpload','Proc_Import_ReUpload','Cn2Cs_Prk_ReUpload','Proc_Cn2Cs_ReUpload','Transaction','Download',1)

--DEFAULT VALUES SCRIPT FOR CustomUpDownloadCount
--Upload
DELETE FROM CustomUpDownloadCount

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (101,1,'Retailer','Retailer','Cs2Cn_Prk_Retailer','Cs2Cn_Prk_Retailer','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (102,1,'Daily Sales','Daily Sales','Cs2Cn_Prk_DailySales','Cs2Cn_Prk_DailySales','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (103,1,'Stock','Stock','Cs2Cn_Prk_Stock','Cs2Cn_Prk_Stock','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (104,1,'Sales Return','Sales Return','Cs2Cn_Prk_SalesReturn','Cs2Cn_Prk_SalesReturn','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (105,1,'Purchase Confirmation','Purchase Confirmation','Cs2Cn_Prk_PurchaseConfirmation','Cs2Cn_Prk_PurchaseConfirmation','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (106,1,'Purchase Return','Purchase Return','Cs2Cn_Prk_PurchaseReturn','Cs2Cn_Prk_PurchaseReturn','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (107,1,'Claims','Claims','Cs2Cn_Prk_ClaimAll','Cs2Cn_Prk_ClaimAll','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (108,1,'Scheme Utilization','Scheme Utilization','Cs2Cn_Prk_SchemeUtilizationDetails','Cs2Cn_Prk_SchemeUtilizationDetails','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (109,1,'Sample Issue','Sample Issue','Cs2Cn_Prk_SampleIssue','Cs2Cn_Prk_SampleIssue','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (110,1,'Sample Receipt','Sample Receipt','Cs2Cn_Prk_SampleReceipt','Cs2Cn_Prk_SampleReceipt','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (111,1,'Sample Return','Sample Return','Cs2Cn_Prk_SampleReturn','Cs2Cn_Prk_SampleReturn','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (112,1,'Purchase Order','Purchase Order','Cs2Cn_Prk_PurchaseOrder','Cs2Cn_Prk_PurchaseOrder','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (113,1,'Order Booking','Order Booking','Cs2Cn_Prk_OrderBooking','Cs2Cn_Prk_OrderBooking','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (114,1,'Sales Invoice Orders','Sales Invoice Orders','Cs2Cn_Prk_SalesInvoiceOrders','Cs2Cn_Prk_SalesInvoiceOrders','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (115,1,'Salesman','Salesman','Cs2Cn_Prk_Salesman','Cs2Cn_Prk_Salesman','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (116,1,'Route','Route','Cs2Cn_Prk_Route','Cs2Cn_Prk_Route','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (117,1,'Retailer Route','Retailer Route','Cs2Cn_Prk_RetailerRoute','Cs2Cn_Prk_RetailerRoute','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (118,1,'Route Village','Route Village','Cs2Cn_Prk_RouteVillage','Cs2Cn_Prk_RouteVillage','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (119,1,'Cluster Assign','Cluster Assign','Cs2Cn_Prk_ClusterAssign','Cs2Cn_Prk_ClusterAssign','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (120,1,'Daily Business Details','Daily Business Details','Cs2Cn_Prk_DailyBusinessDetails','Cs2Cn_Prk_DailyBusinessDetails','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (121,1,'DB Details','DB Details','Cs2Cn_Prk_DBDetails','Cs2Cn_Prk_DBDetails','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (122,1,'Download Trace','DownloadTracing','ETL_PRK_CS2CNDownLoadTracing','ETL_PRK_CS2CNDownLoadTracing','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (123,1,'Upload Trace','UploadTracing','ETL_PRK_CS2CNUpLoadTracing','ETL_PRK_CS2CNUpLoadTracing','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (124,1,'Daily Retailer Details','Daily Retailer Details','Cs2Cn_Prk_DailyRetailerDetails','Cs2Cn_Prk_DailyRetailerDetails','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (125,1,'Daily Product Details','Daily Product Details','Cs2Cn_Prk_DailyProductDetails','Cs2Cn_Prk_DailyProductDetails','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (126,1,'Upload Record Check','UploadRecordCheck','Cs2Cn_Prk_UploadRecordCheck','Cs2Cn_Prk_UploadRecordCheck','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (127,1,'ReUpload Initiate','ReUploadInitiate','Cs2Cn_Prk_ReUploadInitiate','Cs2Cn_Prk_ReUploadInitiate','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (128,1,'For Integration','ForIntegration','Cs2Cn_Prk_IntegrationHouseKeeping','Cs2Cn_Prk_IntegrationHouseKeeping','','','','Upload','0',0,'0',0,0,'')

--DownLoad

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (201,1,'Hierarchy Level','Hieararchy Level','Cn2Cs_Prk_HierarchyLevel','Cn2Cs_Prk_HierarchyLevel','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (202,1,'Hierarchy Level Value','Hieararchy Level Value','Cn2Cs_Prk_HierarchyLevelValue','Cn2Cs_Prk_HierarchyLevelValue','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (203,1,'Retailer Category Level Value','Retailer Category Level Value','Cn2Cs_Prk_BLRetailerCategoryLevelValue','RetailerCategory','CtgMainId','','','Download','0',0,'0',0,0,'SELECT CtgCode AS [Category Code],CtgName AS [Category Name] FROM RetailerCategory WHERE CtgMainId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (204,1,'Retailer Value Classification','Retailer Value Classification','Cn2Cs_Prk_BLRetailerValueClass','RetailerValueClass','RtrClassId','','','Download','0',0,'0',0,0,'SELECT ValueClassCode AS [Class Code],ValueClassName AS [Class Name] FROM RetailerValueClass WHERE RtrClassId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (205,1,'Prefix Master','Prefix Master','Cn2Cs_Prk_PrefixMaster','Cn2Cs_Prk_PrefixMaster','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (206,1,'Retailer Aproval','Retailer Approval','Cn2Cs_Prk_RetailerApproval','Cn2Cs_Prk_RetailerApproval','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (207,1,'UOM','UOM','Cn2Cs_Prk_BLUOM','UOMMaster','UOMId','','','Download','0',0,'0',0,0,'SELECT UomCode AS [UOM Code],UomDescription AS [UOM Desc] FROM UOMMaster WHERE UomId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (208,1,'Tax Configuration','Tax Configuration','Etl_Prk_TaxConfig_GroupSetting','TaxConfiguration','TaxId','','','Download','0',0,'0',0,0,'SELECT TaxCode AS [Tax Code],TaxName AS [Tax Name] FROM TaxConfiguration WHERE TaxId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (209,1,'Tax Setting','Tax Setting','Etl_Prk_TaxSetting','Etl_Prk_TaxSetting','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (210,1,'Product Hierarchy Change','Product Hierarchy Change','Cn2Cs_Prk_BLProductHiereachyChange','Cn2Cs_Prk_BLProductHiereachyChange','DownLoadFlag','','','Download','0',0,'0',0,0,'SELECT BusinessCode AS [Business Code],CategoryCode AS [Category Code] FROM Cn2Cs_Prk_BLProductHiereachyChange WHERE DownLoadFlag=''Y''')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (211,1,'Product','Product','Cn2Cs_Prk_Product','Product','PrdId','','','Download','0',0,'0',0,0,'SELECT PrdCCode AS [Product Code],PrdName AS [Product Name] FROM Product WHERE PrdId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (212,1,'Product Batch','Product Batch','Cn2Cs_Prk_ProductBatch','ProductBatch','PrdBatId','','','Download','0',0,'0',0,0,'SELECT PrdCCode AS [Product Code],PrdBatCode AS [Batch Code] FROM ProductBatch PB,Product P   WHERE P.PrdId=PB.PrdId AND PrdBatId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (213,1,'Tax Group Mapping','Tax Group Mapping','Etl_Prk_TaxMapping','Etl_Prk_TaxMapping','DownLoadFlag','','','Download','0',0,'0',0,0,'SELECT PrdCode AS [Product Code],TaxGroupCode AS [Tax Group Code] FROM Etl_Prk_TaxMapping WHERE DownLoadFlag=''Y''')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (214,1,'Special Rate','Special Rate','Cn2Cs_Prk_SpecialRate','Cn2Cs_Prk_SpecialRate','DownLoadFlag','','','Download','0',0,'0',0,0,'SELECT CtgCode AS [Hierarchy],PrdCCode AS [Product Company Code],SpecialSellingRate AS [Special Selling Rate] FROM Cn2Cs_Prk_SpecialRate WHERE DownLoadFlag=''Y''')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,1,'Cluster Master','Cluster Master','Cn2Cs_Prk_ClusterMaster','ClusterMaster','ClusterId','','','Download','0',0,'0',0,0,'SELECT ClusterCode AS [Cluster Code],ClusterName AS [Cluster Name] FROM ClusterMaster WHERE ClusterId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (216,1,'Cluster Group','Cluster Group','Cn2Cs_Prk_ClusterGroup','ClusterGroupMaster','ClsGroupId','','','Download','0',0,'0',0,0,'SELECT ClsGroupCode AS [Cluster Group Code],ClsGroupName AS [Cluster Group Name] FROM ClusterGroupMaster WHERE ClsGroupId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (217,1,'Scheme','Scheme Master','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (217,2,'Scheme','Scheme Attributes','Etl_Prk_Scheme_OnAttributes','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (217,3,'Scheme','Scheme Products','Etl_Prk_SchemeProducts_Combi','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (217,4,'Scheme','Scheme Slabs','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (217,5,'Scheme','Scheme Rule Setting','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (217,6,'Scheme','Scheme Free Products','Etl_Prk_Scheme_Free_Multi_Products','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (217,7,'Scheme','Scheme Combi Products','Etl_Prk_SchemeProducts_Combi','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (217,8,'Scheme','Scheme On Another Product','Etl_Prk_Scheme_OnAnotherPrd','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (218,1,'Scheme Master Control','Scheme Master Control','Cn2Cs_Prk_NVSchemeMasterControl','Cn2Cs_Prk_NVSchemeMasterControl','DownLoadFlag','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],ChangeType AS [Change Type],Description FROM Cn2Cs_Prk_NVSchemeMasterControl WHERE DownLoadFlag=''Y''')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (219,1,'Claim Settlement','Claim Settlement','Cn2Cs_Prk_ClaimSettlementDetails','Cn2Cs_Prk_ClaimSettlementDetails','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (220,1,'Purchase Receipt','Purchase Receipt','Cn2Cs_Prk_BLPurchaseReceipt','ETLTempPurchaseReceipt','CmpInvNo','','DownLoadStatus=0','Download','0',0,'0',0,0,'SELECT CmpInvNo AS [Invoice No],InvDate AS [Invoice Date] FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (221,1,'Purchase Receipt Mapping','Purchase Receipt Mapping','Cn2Cs_Prk_PurchaseReceiptMapping','Cn2Cs_Prk_PurchaseReceiptMapping','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (222,1,'Claim Norm Mapping','Claim Norm Mapping','Cn2Cs_Prk_ClaimNorm','Cn2Cs_Prk_ClaimNorm','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (223,1,'Reason Master','Reason Master','Cn2Cs_Prk_ReasonMaster','ReasonMaster','ReasonId','','','Download','0',0,'0',0,0,'SELECT ReasonCode AS [Reason Code],Description FROM ReasonMaster WHERE ReasonId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (224,1,'Bulletin Board','BulletingBoard','Cn2Cs_Prk_BulletingBoard','Cn2Cs_Prk_BulletingBoard','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (225,1,'ERP Product Mapping','ERP Product Mapping','Cn2Cs_Prk_ERPPrdCCodeMapping','Cn2Cs_Prk_ERPPrdCCodeMapping','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (226,1,'Configuration','Configuration','Cn2Cs_Prk_Configuration','Cn2Cs_Prk_Configuration','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (227,1,'Cluster Assign Approval','Cluster Assign Approval','Cn2Cs_Prk_ClusterAssignApproval','Cn2Cs_Prk_ClusterAssignApproval','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (228,1,'Supplier Master','Supplier Master','Cn2Cs_Prk_SupplierMaster','Supplier','SpmId','','','Download','0',0,'0',0,0,'SELECT SpmCode AS [Supplier Code],SpmName AS [Supplier Name] FROM Supplier WHERE SpmId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (229,1,'UDC Master','UDC Master','Cn2Cs_Prk_UDCMaster','UDCMaster','UdcMasterId','','','Download','0',0,'0',0,0,'SELECT MasterName AS [Master Name],ColumnName AS [Column Name] FROM UDCMaster UM,UDCHd UH WHERE UM.MasterId=UH.MasterId AND UM.UDCMasterId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (230,1,'UDC Details','UDC Details','Cn2Cs_Prk_UDCDetails','Cn2Cs_Prk_UDCDetails','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (231,1,'UDC Defaults','UDC Defaults','Cn2Cs_Prk_UDCDefaults','Cn2Cs_Prk_UDCDefaults','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (232,1,'Retailer Migration','Retailer Migration','Cn2Cs_Prk_RetailerMigration','Cn2Cs_Prk_RetailerMigration','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (233,1,'Point Redemption Rules','Point Redemption Rules','Cn2Cs_Prk_PointsRulesHeader','Cn2Cs_Prk_PointsRulesHeader','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (234,1,'Village Master','Village Master','Cn2Cs_Prk_VillageMaster','Cn2Cs_Prk_VillageMaster','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (235,1,'Scheme Payout','Scheme Payout','Cn2Cs_Prk_SchemePayout','Cn2Cs_Prk_SchemePayout','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (236,1,'ReUpload','ReUpload','Cn2Cs_Prk_ReUpload','Cn2Cs_Prk_ReUpload','DownLoadFlag','','','Download','0',0,'0',0,0,'')

if not exists (select * from hotfixlog where fixid = 362)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(362,'D','2011-03-16',getdate(),1,'Core Stocky Service Pack 362')
