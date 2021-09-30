--[Stocky HotFix Version]=353
Delete from Versioncontrol where Hotfixid='353'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('353','2.0.0.5','D','2010-12-22','2010-12-22','2010-12-22',convert(varchar(11),getdate()),'Parle;Major:-;Minor:Changes and Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 353' ,'353'
GO

--SRF-Nanda-185-001

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ExportSchemeFreeDt]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ExportSchemeFreeDt]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE FUNCTION [dbo].[Fn_ExportSchemeFreeDt] ()
RETURNS nVarchar(4000)
AS
/*********************************
* FUNCTION: Fn_ExportSchemeFreePrd
* PURPOSE: Return Scheme Slab Free Product query for export
* NOTES:
* CREATED: Boopathy.P 05-02-2008
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
*
*********************************/
BEGIN
	Declare @sSql nVarchar(4000)
	Set @sSql  = 'SELECT Final.* into #Temp FROM (SELECT DISTINCT B.CmpSchCode as [Company Scheme Code],A.SlabId,
			CASE ISNULL(D.SchId,-1) WHEN -1 THEN ''AND'' ELSE ''OR'' END as [Condition],
			PrdDCode as [Product Code],A.FreeQty as [Qty],
			CASE ISNULL(D.SchId,-1) WHEN -1 THEN ''FREE'' ELSE
			CASE D.Type WHEN 1 THEN ''FREE'' WHEN 2 THEN ''GIFT'' END END  as [Type]
			FROM dbo.SchemeSlabFrePrds A
			INNER JOIN SchemeMaster B ON A.SchId = B.SchId
			INNER JOIN Product C ON A.PrdId = C.PrdId
			LEFT OUTER JOIN SchemeSlabMultiFrePrds D ON D.SchId = B.SchId
			AND D.SlabId = A.SlabId
		UNION ALL
		SELECT DISTINCT B.CmpSchCode as [Company Scheme Code],A.SlabId,''OR'' as [Condition],
			PrdDCode as [Product Code],A.FreeQty as [Qty],
			CASE A.Type WHEN 1 THEN ''FREE'' WHEN 2 THEN ''GIFT'' END as [Type]
			FROM dbo.SchemeSlabMultiFrePrds A
			INNER JOIN SchemeMaster B ON A.SchId = B.SchId
			INNER JOIN Product C ON A.PrdId = C.PrdId
		) Final
		SELECT * FROM #Temp'

	Return (@sSql)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-185-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnContractPricingDetails]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnContractPricingDetails]
GO
 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Select * FROM Fn_ReturnContractPricingDetails(1,73,0)
CREATE    FUNCTION [dbo].[Fn_ReturnContractPricingDetails](@Pi_CmpId INT,@Pi_CmpPrdId INT,@Pi_PrdCtgValMainId INT,@Pi_ContractId INT,@Pi_Mode INT,@Pi_DicMode INT)    
RETURNS @ContractDetails TABLE    
 (    
	  PrdId   INT,    
	  PrdDCode NVARCHAR(100),    
	  PrdName  NVARCHAR(100),    
	  PrdBatId  INT,    
	  PrdBatCode NVARCHAR(100),    
	  PriceId  INT,    
	  PriceCode NVARCHAR(400),    
	  Discount NUMERIC(38,6),    
	  FlatAmtDisc NUMERIC(38,6),
	  ClaimablePercOnMRP NUMERIC(38,6)    
 )    
AS
BEGIN    
/*********************************    
* FUNCTION: Fn_ReturnContractPricingDetails    
* PURPOSE: Returns the Product and Batch Details for the Selected Contract Pricing    
* NOTES:     
* CREATED: NandaKumar R.G On 29-11-2007    
* MODIFIED     
* DATE      AUTHOR     DESCRIPTION    
------------------------------------------------    
*     
*********************************/    
    
IF @Pi_Mode=0  
BEGIN  
	IF @Pi_DicMode=0 
	BEGIN
		INSERT INTO @ContractDetails    
		(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc,ClaimablePercOnMRP)    
		SELECT DISTINCT B.PrdId,B.PrdDCode,B.PrdName,A.PrdBatId,PB.PrdBatCode,A.PriceId,PBD.PriceCode,    
		ISNULL(Discount,0) as Discount, ISNULL(FlatAmtDisc,0) as FlatAmtDisc ,
		ISNULL(A.ClaimablePercOnMRP,0) AS ClaimablePercOnMRP     
		FROM ProductBatch PB,ProductBatchDetails PBD,ProductCategoryValue C     
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode     
		LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'    
		INNER JOIN Product B On D.PrdCtgValMainId = B.PrdCtgValMainId     
		LEFT OUTER JOIN  ContractPricingDetails A ON A.PrdId = B.PrdId AND A.ContractId= @Pi_ContractId    
		WHERE PB.PrdBatId=A.PrdBatId AND A.PriceId=PBD.PriceId AND     
		C.PrdCtgValMainId = Case @Pi_PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE @Pi_PrdCtgValMainId END AND     
		B.CmpId = Case @Pi_CmpId WHEN 0  THEN B.CmpId ELSE @Pi_CmpId END AND B.PrdStatus=1 AND PrdType<>4 AND PrdType<>3    
	      
		INSERT INTO @ContractDetails    
		(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc,ClaimablePercOnMRP)    
		SELECT DISTINCT P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,    
		PB.DefaultPriceId AS PriceId,PBD.PriceCode,0 AS Discount,0 AS FlatAmtDisc,0   
		FROM ProductCategoryValue PCV    
		INNER JOIN  ProductCategoryValue PCV1 ON  PCV1.PrdCtgValLinkCode     
		LIKE CAST(PCV.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'     
		INNER JOIN Product P On PCV1.PrdCtgValMainId = P.PrdCtgValMainId     
		INNER JOIN ProductBatch PB ON P.PrdId=PB.PrdId    
		INNER JOIN ProductBatchDetails PBD ON PB.PrdBatId=PBD.PrdBatId AND PBD.DefaultPrice=1 AND PBD.SlNo=1    
		WHERE  P.CmpId= CASE @Pi_CmpId WHEN 0 THEN P.CmpId ELSE @Pi_CmpId END AND P.PrdStatus=1 AND P.PrdType NOT IN (3,4) AND    
		PCV.PrdCtgValMainId = Case @Pi_PrdCtgValMainId WHEN 0 THEN P.PrdCtgValMainId ELSE @Pi_PrdCtgValMainId END    
		--AND P.PrdId NOT IN (SELECT PrdId FROM ContractPricingDetails WHERE ContractId=@Pi_ContractId)  --Code commented and added by Vinayaga Raj for the bug id 17399     
		AND PB.PrdBatId NOT IN (SELECT PrdBatId FROM ContractPricingDetails WHERE ContractId=@Pi_ContractId)    
	END
	ELSE
	BEGIN
		INSERT INTO @ContractDetails    
		(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc,ClaimablePercOnMRP)    
		SELECT DISTINCT B.PrdId,B.PrdDCode,B.PrdName,0,'',0,'',    
		ISNULL(Discount,0) as Discount, ISNULL(FlatAmtDisc,0) as FlatAmtDisc,
		ISNULL(A.ClaimablePercOnMRP,0) AS ClaimablePercOnMRP   
		FROM ProductCategoryValue C     
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode     
		LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'    
		INNER JOIN Product B On D.PrdCtgValMainId = B.PrdCtgValMainId     
		INNER JOIN   ContractPricingDetails A ON A.PrdId = B.PrdId AND A.ContractId= @Pi_ContractId    
		WHERE C.PrdCtgValMainId = Case @Pi_PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE @Pi_PrdCtgValMainId END AND     
		B.CmpId = Case @Pi_CmpId WHEN 0  THEN B.CmpId ELSE @Pi_CmpId END AND B.PrdStatus=1 AND PrdType<>4 AND PrdType<>3    
	      
		INSERT INTO @ContractDetails    
		(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc,ClaimablePercOnMRP)    
		SELECT DISTINCT P.PrdId,P.PrdDCode,P.PrdName,0,'',    
		0 AS PriceId,'',0 AS Discount,0 AS FlatAmtDisc,0    
		FROM ProductCategoryValue PCV    
		INNER JOIN  ProductCategoryValue PCV1 ON  PCV1.PrdCtgValLinkCode     
		LIKE CAST(PCV.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'     
		INNER JOIN Product P On PCV1.PrdCtgValMainId = P.PrdCtgValMainId     
		WHERE  P.CmpId= CASE @Pi_CmpId WHEN 0 THEN P.CmpId ELSE @Pi_CmpId END AND P.PrdStatus=1 AND P.PrdType NOT IN (3,4) AND    
		PCV.PrdCtgValMainId = Case @Pi_PrdCtgValMainId WHEN 0 THEN P.PrdCtgValMainId ELSE @Pi_PrdCtgValMainId END    
		AND P.PrdId NOT IN (SELECT PrdId FROM ContractPricingDetails WHERE ContractId=@Pi_ContractId)    
	END 
END  
ELSE  
BEGIN  
	INSERT INTO @ContractDetails    
	(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc,ClaimablePercOnMRP) 
	SELECT DISTINCT C.PrdCtgValMainId AS PrdId,C.PrdCtgValCode AS PrdDCode,
	C.PrdCtgValName AS PrdName,0 AS PrdBatId,'' AS PrdBatCode,0 AS PriceId,'' AS PriceCode,   
	ISNULL(Discount,0) as Discount, ISNULL(FlatAmtDisc,0) as FlatAmtDisc,
	ISNULL(A.ClaimablePercOnMRP,0) AS ClaimablePercOnMRP    
	FROM ProductCategoryValue C INNER JOIN ProductCategoryLevel G 
	ON C.CmpPrdCtgId=G.CmpPrdCtgId,ContractPricingDetails A,ContractPricingMaster E
	WHERE  A.ContractId=E.ContractId AND C.PrdCtgValMainId=A.CtgValMainId AND
	C.CmpPrdCtgId = Case E.CmpPrdCtgId WHEN 0 THEN C.CmpPrdCtgId ELSE E.CmpPrdCtgId END  
	AND C.PrdCtgValMainId = A.CtgValMainId
	AND A.ContractId= @Pi_ContractId  AND E.DisplayMode=@Pi_Mode

	INSERT INTO @ContractDetails    
	(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc,ClaimablePercOnMRP)   
	SELECT DISTINCT PCV1.PrdCtgValMainId AS PrdId,PCV1.PrdCtgValCode AS PrdDCode,  
	PCV1.PrdCtgValName AS PrdName,0 AS PrdBatId, '' AS PrdBatCode,    
	0  AS PriceId,'' AS PriceCode,0 AS Discount,0 AS FlatAmtDisc,0    
	FROM ProductCategoryValue PCV    
	INNER JOIN  ProductCategoryValue PCV1 ON  PCV1.PrdCtgValLinkCode     
	LIKE CAST(PCV.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'     
	INNER JOIN ProductCategoryLevel PV ON PV.CmpPrdCtgId=PCV.CmpPrdCtgId AND PV.CmpPrdCtgId=PCV1.CmpPrdCtgId  
	WHERE  PV.CmpId= CASE @Pi_CmpId WHEN 0 THEN PV.CmpId ELSE @Pi_CmpId END   
	AND PCV.PrdCtgValMainId = Case @Pi_PrdCtgValMainId WHEN 0 THEN PCV.PrdCtgValMainId ELSE @Pi_PrdCtgValMainId END    
	AND PV.CmpPrdCtgId = CASE @Pi_CmpPrdId WHEN 0 THEN PV.CmpPrdCtgId ELSE @Pi_CmpPrdId END  
	AND PV.CmpPrdCtgId NOT IN (SELECT CmpPrdCtgId FROM ContractPricingMaster WHERE ContractId=@Pi_ContractId AND DisplayMode=@Pi_Mode)    
	AND PCV.PrdCtgValMainId NOT IN (SELECT PrdCtgValMainId FROM ContractPricingMaster WHERE ContractId=@Pi_ContractId AND DisplayMode=@Pi_Mode)    
	AND PCV.PrdCtgValMainId NOT IN (SELECT CtgValMainId FROM ContractPricingDetails WHERE ContractId=@Pi_ContractId)    
END  
RETURN    
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-185-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_PointsRulesSetting]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_PointsRulesSetting]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_PointsRulesSetting 0
ROLLBACK TRANSACTION
*/

CREATE PROCEDURE [dbo].[Proc_Cn2Cs_PointsRulesSetting]
(
       @Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_PointsRulesSetting
* PURPOSE		: To save Points Rules Setting
* CREATED		: Murugan.R
* CREATED DATE	: 01/04/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN	
	DECLARE @CmpSchCode			AS NVARCHAR(50)
	DECLARE @SchDesc			AS NVARCHAR(50)
	DECLARE @Status				AS NVARCHAR(10)
	DECLARE @Claimable			AS NVARCHAR(10)
	DECLARE @ClaimRefCode		AS NVARCHAR(50)
	DECLARE @ClmAmtOn			AS NVARCHAR(25)
	DECLARE @ValidFromDt		AS DateTime
	DECLARE @ValidToDt			AS DateTime
	DECLARE @Budget				AS Numeric(36,2)
	DECLARE @RangeBasedSch		AS NVARCHAR(10)
	DECLARE @ForEvery			AS NVARCHAR(10)
	DECLARE @ReapplySch			AS NVARCHAR(10)
	DECLARE @SchemeBasedOn		AS NVARCHAR(10)
	DECLARE @ProRata			AS NVARCHAR(10)
	DECLARE @Transaction		AS INT
	DECLARE @GetKeyStr			AS NVARCHAR(50)
	DECLARE @CmpId				AS INT
	DECLARE @SlNo				AS INT

	SET @Po_ErrNo=0

	DELETE FROM Cn2Cs_Prk_PointsRulesHeader WHERE DownLoadFlag='Y'
	DELETE FROM Cn2Cs_Prk_PointsRulesRetailer  WHERE DownLoadFlag='Y'
	DELETE FROM Cn2Cs_Prk_PointsRulesSlab WHERE DownLoadFlag='Y'
	DELETE FROM Cn2Cs_Prk_PointsRulesProduct WHERE DownLoadFlag='Y'
	DELETE FROM ErrorLog WHERE TableName='Cn2Cs_Prk_PointsRulesHeader'

	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'Cn2Cs_Prk_PointsRulesHeader',CmpSchCode,'Mandatory Field Can Not be Empty for the loyal Company Code:'+CmpSchCode 
	FROM Cn2Cs_Prk_PointsRulesHeader
	WHERE LTRIM(RTRIM(LEN(CmpSchCode)))=0 OR  LTRIM(RTRIM(LEN(SchDesc)))=0 
	OR LTRIM(RTRIM(LEN(Status)))=0 OR LTRIM(RTRIM(LEN(Claimable)))=0 
	OR LTRIM(RTRIM(LEN(ClmAmtOn)))=0 OR LTRIM(RTRIM(LEN(RangeBasedSch)))=0
	OR LTRIM(RTRIM(LEN(ForEvery)))=0 OR LTRIM(RTRIM(LEN(ReapplySch)))=0
	OR LTRIM(RTRIM(LEN(SchemeBasedOn)))=0 OR LTRIM(RTRIM(LEN(ProRata)))=0
	and DownLoadFlag='D'
	--VALIDATE COMPANY CODE EXISTS
	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT 1,'Cn2Cs_Prk_PointsRulesHeader',CmpSchCode,'Company Code No:'+CmpSchCode+' already Available' 
	FROM Cn2Cs_Prk_PointsRulesHeader
	WHERE CmpSchCode IN (SELECT CmpSchCode FROM PointRedemptionMaster) and DownLoadFlag='D'
	
	DECLARE Cur_PointsRulesHeader CURSOR
	FOR
	SELECT DISTINCT CmpSchCode,SchDesc,Status,Claimable,ClaimRefCode,ClmAmtOn,
					ValidFromDt,ValidToDt,Budget,RangeBasedSch,ForEvery,ReapplySch,SchemeBasedOn,ProRata
	FROM Cn2Cs_Prk_PointsRulesHeader WHERE CmpSchCode NOT IN (SELECT DISTINCT FieldName FROM ErrorLog WHERE TableName='Cn2Cs_Prk_PointsRulesHeader')
	AND CmpSchCode NOT IN(SELECT 	CmpSchCode FROM PointRedemptionMaster)
	AND LTRIM(RTRIM(LEN(CmpSchCode)))>0 and DownLoadFlag='D'
	OPEN Cur_PointsRulesHeader
	FETCH NEXT FROM Cur_PointsRulesHeader INTO @CmpSchCode,@SchDesc,@Status,@Claimable,@ClaimRefCode,@ClmAmtOn,@ValidFromDt,	
											@ValidToDt,@Budget,@RangeBasedSch,@ForEvery,@ReapplySch,@SchemeBasedOn,@ProRata
	WHILE @@FETCH_STATUS=0
	BEGIN
			
		SET @Transaction=0
		SET @GetKeyStr=''
		SET @SlNo=0
		--1 Condition
		IF NOT EXISTS(SELECT * FROM Cn2Cs_Prk_PointsRulesRetailer WHERE CmpSchCode=@CmpSchCode)
		BEGIN
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Cn2Cs_Prk_PointsRulesRetailer','CmpSchCode','No Retailer Record Found for:'+@CmpSchCode 
			SET @Transaction=1	
			PRINT '1 Condition Failed'
		END	
		--2 Condition
		IF NOT EXISTS(SELECT * FROM Cn2Cs_Prk_PointsRulesSlab WHERE CmpSchCode=@CmpSchCode)
		BEGIN
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Cn2Cs_Prk_PointsRulesSlab','CmpSchCode','No Slab Found for:'+@CmpSchCode 
			SET @Transaction=1	
			PRINT '2 Condition Failed'
		END	
		--3 Condition--Verify Retailer 
		IF EXISTS(SELECT * FROM Cn2Cs_Prk_PointsRulesRetailer WHERE CmpSchCode=@CmpSchCode  and  UPPER(LTRIM(RTRIM(RtrCode)))<>'ALL')
		BEGIN
			IF EXISTS(SELECT RtrCode FROM Cn2Cs_Prk_PointsRulesRetailer 
								WHERE RtrCode NOT IN(SELECT CmpRtrCode FROM Retailer) and CmpSchCode=@CmpSchCode)
			BEGIN
				INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
				SELECT DISTINCT 1,'Cn2Cs_Prk_PointsRulesRetailer','RtrCode','For the Points Rules Company Code:'+@CmpSchCode+'Retailer Code Does not Exists:'+RtrCode FROM Cn2Cs_Prk_PointsRulesRetailer 
						WHERE RtrCode NOT IN(SELECT CmpRtrCode FROM Retailer) and CmpSchCode=@CmpSchCode
				SET @Transaction=1	
				PRINT '3 Condition Failed'	
			END
		END

		--6 Condition
		IF EXISTS(SELECT Prdccode FROM Cn2Cs_Prk_PointsRulesProduct  WHERE  Prdccode NOT IN(SELECT Prdccode FROM  PRODUCT) 
			  AND DownLoadFlag='D' and CmpSchCode=@CmpSchCode)
		BEGIN
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Cn2Cs_Prk_PointsRulesHeader','Prdccode','For the Loyal Company Code:'+@CmpSchCode+'Product Code Does not Exists:'+Prdccode FROM Cn2Cs_Prk_PointsRulesProduct 
			WHERE Prdccode NOT IN(SELECT Prdccode FROM  PRODUCT) and CmpSchCode=@CmpSchCode
			SET @Transaction=1	
			PRINT '6 Condition Failed'
		END

		SELECT @GetKeyStr = dbo.Fn_GetPrimaryKeyString('PointRedemptionRule','PntRedSchCode',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
		SELECT @SlNo = dbo.Fn_GetPrimaryKeyInteger('PointRedemptionRule','PntRedSchId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))	 
		--4 Condition
		IF LEN(LTRIM(RTRIM(@GetKeyStr)))=0
		BEGIN
			PRINT @GetKeyStr
			SET @Transaction=1
			PRINT '4 Condition Failed'	
		END	
		--5 Condition
		IF (LTRIM(RTRIM(@SlNo)))=0
		BEGIN
			PRINT @SlNo
			SET @Transaction=1
			PRINT '5 Condition Failed'	
		END	
		
		IF @Transaction=0
		BEGIN
			SELECT @CmpId=CmpId FROM Company	WHERE DefaultCompany=1
			INSERT INTO PointRedemptionMaster(
			PntRedSchId,PntRedSchCode,Description,CmpId,CmpSchCode,Status,Claimable,ClmRefId,SchType,ColumnNameId,
			ClmAmtOn,ValidFromDt,ValidToDt,Budget,RangeBasedSch,ForEvery,Reapply,SchBasedOn,ProRata,
			Availability,LastModBy,LastModDate,AuthId,AuthDate,DownLoadFlag)
			SELECT @SlNo,@GetKeyStr,@SchDesc,@CmpId,@CmpSchCode,
			CASE WHEN UPPER(LTRIM(RTRIM(@Status)))='ACTIVE' THEN 1
				 WHEN UPPER(LTRIM(RTRIM(@Status)))='INACTIVE' THEN 0 END AS Status,
			CASE WHEN UPPER(LTRIM(RTRIM(@Claimable)))='YES' THEN 1
				 WHEN UPPER(LTRIM(RTRIM(@Claimable)))='NO' THEN 0 END AS Claimable,
			CASE WHEN UPPER(LTRIM(RTRIM(@Claimable)))='YES' THEN (SELECT DISTINCT ClmGrpId  From ClaimGroupMaster WHERE ClmGrpCode='CG17')
				 WHEN UPPER(LTRIM(RTRIM(@Claimable)))='NO' THEN 0 END AS ClmRefId,1 as SchType ,0 as ColumnNameId,
			CASE WHEN UPPER(LTRIM(RTRIM(@ClmAmtOn)))='SELLING RATE' THEN 0
				 WHEN UPPER(LTRIM(RTRIM(@ClmAmtOn)))='PURCHASE RATE' THEN 1 END AS ClmAmtOn,
			ConVert(DateTime,Convert(NVARCHAR(10),@ValidFromDt,120),120),
			ConVert(DateTime,Convert(NVARCHAR(10),@ValidToDt,120),120),@Budget,
			CASE WHEN UPPER(LTRIM(RTRIM(@RangeBasedSch)))='YES' THEN 1
				 WHEN UPPER(LTRIM(RTRIM(@RangeBasedSch)))='NO' THEN 0 END AS RangeBasedSch,
			CASE WHEN UPPER(LTRIM(RTRIM(@ForEvery)))='YES' THEN 1
				 WHEN UPPER(LTRIM(RTRIM(@ForEvery)))='NO' THEN 0 END AS ForEvery,
			CASE WHEN UPPER(LTRIM(RTRIM(@ReapplySch)))='YES' THEN 1
				 WHEN UPPER(LTRIM(RTRIM(@ReapplySch)))='NO' THEN 0 END AS Reapply,
			CASE WHEN UPPER(LTRIM(RTRIM(@SchemeBasedOn)))='DATE' THEN 1
				 WHEN UPPER(LTRIM(RTRIM(@SchemeBasedOn)))='POINTS' THEN 0 END AS SchBasedOn,
			CASE WHEN UPPER(LTRIM(RTRIM(@ProRata)))='YES' THEN 1
				 WHEN UPPER(LTRIM(RTRIM(@ProRata)))='ACTUAL' THEN 2 
				 WHEN UPPER(LTRIM(RTRIM(@ProRata)))='NO' THEN 0	END AS ProRata,
			1,1,Getdate(),1,Getdate(),1

			IF EXISTS(SELECT CmpSchCode FROM PointRedemptionMaster WHERE CmpSchCode=@CmpSchCode)
			BEGIN
				IF EXISTS(SELECT * FROM Cn2Cs_Prk_PointsRulesRetailer WHERE CmpSchCode=@CmpSchCode  and  UPPER(LTRIM(RTRIM(RtrCode)))<>'ALL')
				BEGIN
					  INSERT INTO PointRedemptionRtr(PntRedSchId,ColValId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					  SELECT @SlNo,RtrId,1,1,Getdate(),1,Getdate() FROM Retailer WHERE CmpRtrCode IN(SELECT DISTINCT RtrCode FROM  	Cn2Cs_Prk_PointsRulesRetailer WHERE CmpSchCode=@CmpSchCode)
				END
				ELSE
				BEGIN
					  INSERT INTO PointRedemptionRtr(PntRedSchId,ColValId,Availability,LastModBy,LastModDate,AuthId,AuthDate)	
					  SELECT @SlNo,0,1,1,Getdate(),1,Getdate()	FROM Cn2Cs_Prk_PointsRulesRetailer WHERE CmpSchCode=@CmpSchCode and  UPPER(LTRIM(RTRIM(RtrCode)))='ALL'
				END
				---Points Slab
				INSERT INTO PointRedemptionSlab(PntRedSchId,SlabId,FromPoint,ToPoint,ForEvery,Amount,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @SlNo,SlabId,ISNULL(FromPoint,0),ISNULL(ToPoint,0),ISNULL(ForEvery,0), ISNULL(Amount,0),
				1,1,Getdate(),1,Getdate()	 
				FROM Cn2Cs_Prk_PointsRulesSlab WHERE CmpSchCode=@CmpSchCode
				---Free and Gift Product
				INSERT INTO PointRedemptionSlabPrd(PntRedSchId,SlabId,FreeOrGift,PrdId,UomId,Qty,AndOr,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				SELECT @SlNo,SlabId,
				CASE WHEN UPPER(LTRIM(RTRIM(FreeOrGift)))='FREE' THEN 1
					 WHEN UPPER(LTRIM(RTRIM(FreeOrGift)))='GIFT' THEN 2 END AS FreeOrGift,
				Prdid,
				UOMID,
				Qty,
				CASE WHEN UPPER(LTRIM(RTRIM(AndOrOption)))='AND' THEN 1
					 WHEN UPPER(LTRIM(RTRIM(AndOrOption)))='OR' THEN 2 END AS AndOr,
				1,1,Getdate(),1,Getdate()
				FROM Cn2Cs_Prk_PointsRulesProduct ET INNER JOIN Product P
				ON P.Prdccode=ET.Prdccode
				INNER JOIN UOMMASTER UM ON UM.UomCode=ET.UomCode
				WHERE CmpSchCode=@CmpSchCode


				UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='PointRedemptionRule' and FldName='PntRedSchCode'
				UPDATE COUNTERS SET CurrValue=CurrValue+1 WHERE TabName='PointRedemptionRule' and FldName='PntRedSchId'

				UPDATE Cn2Cs_Prk_PointsRulesHeader Set DownLoadFlag='Y' WHERE CmpSchCode=@CmpSchCode
				UPDATE Cn2Cs_Prk_PointsRulesRetailer Set DownLoadFlag='Y' WHERE CmpSchCode=@CmpSchCode
				UPDATE Cn2Cs_Prk_PointsRulesSlab Set DownLoadFlag='Y' WHERE CmpSchCode=@CmpSchCode
				UPDATE Cn2Cs_Prk_PointsRulesProduct Set DownLoadFlag='Y' WHERE CmpSchCode=@CmpSchCode		
			END						
		END
	
		FETCH NEXT FROM Cur_PointsRulesHeader INTO @CmpSchCode,@SchDesc,@Status,@Claimable,@ClaimRefCode,@ClmAmtOn,@ValidFromDt,	
		@ValidToDt,@Budget,@RangeBasedSch,@ForEvery,@ReapplySch,@SchemeBasedOn,@ProRata
	END
	CLOSE Cur_PointsRulesHeader
	DEALLOCATE Cur_PointsRulesHeader

END 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-185-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptPendingBillShippAddwiseReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptPendingBillShippAddwiseReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptPendingBillShippAddwiseReport 163,1,0,'Samsung',0,0,1

CREATE PROCEDURE [dbo].[Proc_RptPendingBillShippAddwiseReport]
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
	Create TABLE #RptPendingBillShippAddwise
	(
			SMId 			INT,
			SMName			NVARCHAR(50),
			RMId 			INT,
			RMName 			NVARCHAR(50),
			RtrId         	INT,
			RtrCode       	NVARCHAR(50),	
			RtrName 		NVARCHAR(50),	
			RtrShipAdd1		NVARCHAR(100),	
			RtrShipAdd2 	NVARCHAR(100),	
			RtrShipAdd3		NVARCHAR(100),	
			SalId         	BIGINT,
			SalInvNo 		NVARCHAR(50),
			SalInvDate      DATETIME,
			SalInvRef 		NVARCHAR(50),
			BillAmount      NUMERIC (38,6),
			CollectedAmount NUMERIC (38,6),
			BalanceAmount   NUMERIC (38,6),
			ArDays			INT
	)
	CREATE TABLE #TempReceiptInvoice
	(
		SalId		INT,
		InvInsSta	INT,
		InvInsAmt	NUMERIC(38,2)
	)
	
	SET @TblName = 'RptPendingBillShippAddwise'
	
	SET @TblStruct = '	SMId 	INT,
				SMName			NVARCHAR(50),
				RMId 			INT,
				RMName 			NVARCHAR(50),
				RtrId      		INT,
				RtrCode       	NVARCHAR(50),	
				RtrName 		NVARCHAR(50),	
				RtrShipAdd1		NVARCHAR(100),	
				RtrShipAdd2		NVARCHAR(100),	
				RtrShipAdd3		NVARCHAR(100),	
				SalId      		BIGINT,
				SalInvNo 		NVARCHAR(50),
				SalInvDate      DATETIME,
				SalInvRef 		NVARCHAR(50),
				BillAmount    	NUMERIC (38,6),
				CollectedAmount	NUMERIC (38,6),
				BalanceAmount  	NUMERIC (38,6),
				ArDays			INT'
	
	SET @TblFields = 'SMId,SMName,RMId,RMName,RtrId,RtrCode,RtrName,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,SalId,SalInvNo,
			  SalInvDate,SalInvRef,BillAmount,CollectedAmount,
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
			
				SELECT  SI.SMId,S.SMName,SI.RMId,R.RMName,SI.RtrId,RE.RtrCode,RE.RtrName,RA.RtrShipAdd1,RA.RtrShipAdd2,RA.RtrShipAdd3,SI.SalId,SI.Salinvno,SI.SalinvDate,
						SI.SalInvRef,SI.SalNetAmt,Cast(null as numeric(18,2))AS PaidAmt,
					    Cast(null as numeric(18,2))AS BalanceAmount ,DATEDIFF(Day,SalInvDate,GetDate()) AS ArDays
				 Into #PendingBillsShippAdd
				 FROM Salesinvoice  SI WITH (NOLOCK),
					  RetailerShipAdd RA WITH (NOLOCK),
					  Salesman S WITH (NOLOCK),
					  RouteMaster R WITH (NOLOCK),
					  Retailer RE  WITH (NOLOCK)
				
				 WHERE  SI.SMId = S.SMId  AND SI.RMId = R.RMId AND RA.RtrShipId=SI.RtrShipId
						AND SI.RtrId = RE.RtrId  AND SI.DlvSts IN (4,5)
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
				UPDATE #PendingBillsShippAdd
				SET PAIDAMT=isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI, RECEIPT R WHERE RI.INVRCPNO=R.INVRCPNO AND R.INVRCPDATE <=CONVERT(DATETIME,@AsOnDate,103) AND INVRCPMODE=1 and CancelStatus=1  GROUP BY SALID)A
				WHERE #PendingBillsShippAdd.SALID=a.SALID
				UPDATE #PendingBillsShippAdd
				SET PAIDAMT=isnull(#PendingBillsShippAdd.PaidAmt,0)+isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI WHERE INVRCPMODE<>1 and InvInsSta <> 4 GROUP BY SALID)A
				WHERE #PendingBillsShippAdd.SALID=a.SALID
				Update #PendingBillsShippAdd
				Set BalanceAmount = SalNetAmt-Isnull(PaidAmt,0)
				
				INSERT INTO #RptPendingBillShippAddwise
				SELECT * FROM #PendingBillsShippAdd
			END
			IF @PDCTypeId<>1 --Exclude PDC
			BEGIN
				SELECT  SI.SMId,S.SMName,SI.RMId,R.RMName,SI.RtrId,RE.RtrCode,RE.RtrName,RA.RtrShipAdd1,RA.RtrShipAdd2,RA.RtrShipAdd3,SI.SalId,SI.Salinvno,SI.SalinvDate,
						SI.SalInvRef,SI.SalNetAmt,Cast(null as numeric(18,2))AS PaidAmt,
					    Cast(null as numeric(18,2))AS BalanceAmount ,DATEDIFF(Day,SalInvDate,GetDate()) AS ArDays
				 Into #PendingBillsShippAdd1
				
				 FROM Salesinvoice  SI WITH (NOLOCK),
					  Salesman S WITH (NOLOCK),
					  RetailerShipAdd RA WITH (NOLOCK),
					  RouteMaster R WITH (NOLOCK),
					  Retailer RE  WITH (NOLOCK)
				
				 WHERE  SI.SMId = S.SMId  AND SI.RMId = R.RMId AND RA.RtrShipId=SI.RtrShipId
						AND SI.RtrId = RE.RtrId  AND SI.DlvSts IN (4,5)
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
				UPDATE #PendingBillsShippAdd1
				SET PAIDAMT=isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI, RECEIPT R WHERE RI.INVRCPNO=R.INVRCPNO AND R.INVRCPDATE <=CONVERT(DATETIME,@AsOnDate,103) AND INVRCPMODE=1 and CancelStatus=1  GROUP BY SALID)A
				WHERE #PendingBillsShippAdd1.SALID=a.SALID
				UPDATE #PendingBillsShippAdd1
				SET PAIDAMT=isnull(#PendingBillsShippAdd1.PaidAmt,0)+isnull(a.paidamt,0) FROM (SELECT SALID,SUM(SALINVAMT)PAIDAMT FROM RECEIPTINVOICE RI WHERE INVRCPMODE<>1 AND InvInsDate<=CONVERT(DATETIME,@AsOnDate,103) and InvInsSta <> 4 GROUP BY SALID)A
				WHERE #PendingBillsShippAdd1.SALID=a.SALID
				Update #PendingBillsShippAdd1
				Set BalanceAmount = SalNetAmt-Isnull(PaidAmt,0)
				INSERT INTO #RptPendingBillShippAddwise
				SELECT * FROM #PendingBillsShippAdd1
			END
			IF LEN(@PurDBName) > 0
			BEGIN
				EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
				
				SET @SSQL = 'INSERT INTO #RptPendingBillShippAddwise ' +
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptPendingBillShippAddwise'
		
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
			SET @SSQL = 'INSERT INTO #RptPendingBillShippAddwise ' +
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
	SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptPendingBillShippAddwise
	-- Till Here
	--SELECT * FROM #RptPendingBillShippAddwise ORDER BY SMId,SalId,ArDays
	--Added by Thiru on 13/11/2009
	DELETE FROM #RptPendingBillShippAddwise WHERE (BillAmount-CollectedAmount)<=0	
	SELECT * FROM #RptPendingBillShippAddwise ORDER BY ArDays DESC
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


--SRF-Nanda-185-005

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptPSREfficiencyReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptPSREfficiencyReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Exec [Proc_RptPSREfficiencyReport] 167,2,0,'Loreal',0,0,1

CREATE PROCEDURE [dbo].[Proc_RptPSREfficiencyReport]
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			Nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/****************************************************************************************************************
* PROCEDURE  : Proc_RptPSREfficiencyReport
* PURPOSE    : To Generate PSR Efficiency Report
* CREATED BY : Panneerselvam.k
* CREATED ON : 14/08/2009
* MODIFICATION
*****************************************************************************************************************
* DATE       AUTHOR      DESCRIPTION
*****************************************************************************************************************/
BEGIN
SET NOCOUNT ON
		/* Get the Filter Values  */		
		DECLARE @YearId				AS 	INT
		DECLARE @MonthId			AS 	INT
		DECLARE @CmpId	 			AS	INT
		DECLARE @SMId				AS	INT
		DECLARE @RMId				AS	INT
		DECLARE @RetCatLevelId      AS	INT
		DECLARE @RetCatLevelValId   AS	INT
		DECLARE @RetLevelClassId    AS	INT
		DECLARE @RetailerId		AS	INT
		DECLARE @PrdCatId      		AS	INT
		DECLARE @PrdId			AS	INT
----		DECLARE @PrdCatLevelId      AS	INT
----		DECLARE @PrdCatLevelValueId AS	INT
----		DECLARE @ProductId			AS	INT
		DECLARE @FromDate			AS  DATETIME
		DECLARE @ToDate				AS  DATETIME
		
		SET @YearId				= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,12,@Pi_UsrId))
		SET @MonthId			= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,13,@Pi_UsrId))
		SET @CmpId				= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
		SET @SMId				= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
		SET @RMId				= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
		SET @RetCatLevelId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
		SET @RetCatLevelValId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
		SET @RetLevelClassId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
		SET @RetailerId			= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
------		SET @PrdCatLevelId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
------		SET @PrdCatLevelValueId		= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
------		SET @ProductId			= (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
------				
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
		SET @PrdCatId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
		SET @PrdId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
			/*  CREATE TABLE STRUCTURE */
	DECLARE @NewSnapId 		AS	INT
	DECLARE @DBNAME			AS 	nvarchar(50)
	DECLARE @TblName 		AS	nvarchar(500)
	DECLARE @TblStruct 		AS	nVarchar(4000)
	DECLARE @TblFields 		AS	nVarchar(4000)
	DECLARE @SSQL			AS 	VarChar(8000)
	DECLARE @ErrNo	 		AS	INT
	DECLARE @PurDBName		AS	nVarChar(50)
	DECLARE @TargetTypeId 	AS	INT
	
			/* @TargetTypeId =  1 -- Volume , @TargetTypeId =  2 -- Value */
	SELECT 	@TargetTypeId = TargetType FROM TargetAnalysisHd
						WHERE JcmId = @YearId AND JcmJc = @MonthId AND CmpId = @CmpId
			/*  Till Here  */
	SET @TblName = 'RptEfficiencyReport'
	
	SET @TblStruct ='	SMId INT,
						SMName Varchar(100),
						RMId INT,
						RMName VARCHAR(100),
						TotalOutlets Numeric(18,3),
						OutletsBilled Numeric(18,3),
						Coverage Numeric(18,3),						
						ScheduledCalls Numeric(18,3),
						ActualBills Numeric(18,3),
						Efficiecy Numeric(18,3),
						ValueTarget Numeric(18,3),
						ValueAchieved Numeric(18,3),
						TargetEfficiency Numeric(18,3),
						CompanyId INT'		
										
	SET @TblFields =	'SMId,SMName,RMId,RMName,TotalOutlets,OutletsBilled,Coverage,						
						 ScheduledCalls,ActualBills,Efficiecy,ValueTarget,ValueAchieved,TargetEfficiency,CompanyId'
	CREATE TABLE #RptEfficiencyReport(	SMId INT,SMName VARCHAR(100),RMId INT,RMName VARCHAR(100),
									TotalOutlets Numeric(18,3),OutletsBilled Numeric(18,3),Coverage Numeric(18,3),
									ScheduledCalls Numeric(18,3),ActualBills Numeric(18,3),Efficiecy Numeric(18,3),
									ValueTarget Numeric(18,3),ValueAchieved Numeric(18,3),
									TargetEfficiency Numeric(18,3),CompanyId INT)
	CREATE TABLE #TempRptEfficiencyReport(	SMId INT,SMName VARCHAR(100),RMId INT,RMName VARCHAR(100),
									TotalOutlets Numeric(18,3),OutletsBilled Numeric(18,3),Coverage Numeric(18,3),
									ScheduledCalls Numeric(18,3),ActualBills Numeric(18,3),Efficiecy Numeric(18,3),
									ValueTarget Numeric(18,3),ValueAchieved Numeric(18,3),
									TargetEfficiency Numeric(18,3),CompanyId INT)
			/* Purge DB */
	SELECT @FromDate = JcmSdt FROM JcMonth WHERE JcmJc = @MonthId AND JcmId = @YearId AND JcmId IN (
												 SELECT JcmId FROM JCMast WHERE CmpId = 1)
												
	SELECT @ToDate = JcmEdt FROM JcMonth WHERE JcmJc = @MonthId   AND JcmId = @YearId AND JcmId IN (
												 SELECT JcmId FROM JCMast WHERE CmpId = 1)
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
			/*  Snap Shot Query    */
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
			/* Main Query */
		Delete From #TempRptEfficiencyReport
		Delete From #RptEfficiencyReport	
		INSERT INTO #TempRptEfficiencyReport
		SELECT
				SI.SMId,S.SMName,SI.RMId,RM.RMName,
				0 AS TotalOutlets,0 AS OutletsBilled,0 AS Coverage,
				0 AS ScheduledCalls,Count(DISTINCT SI.SalId) AS ActualBills,0 AS Efficiecy,
				0 AS ValueTarget,0 AS ValueAchieved,0 AS TargetEfficiency,
				P.CmpId CompanyId
		FROM
				SalesInvoice SI				WITH (NOLOCK),Salesman S WITH (NOLOCK),
				RouteMaster RM				WITH (NOLOCK),Retailer R WITH (NOLOCK),
				SalesmanMarket SM			WITH (NOLOCK),RetailerMarket RETMAR		WITH (NOLOCK),
				Product P					WITH (NOLOCK),SalesInvoiceProduct SIP	WITH (NOLOCK),
				ProductBatch PB				WITH (NOLOCK),RetailerValueClass RVC	WITH (NOLOCK),
				RetailerCategory RC			WITH (NOLOCK),RetailerCategorylevel RCL	WITH (NOLOCK),
				ProductCategoryLevel PCL    WITH (NOLOCK),ProductCategoryValue PCV	WITH (NOLOCK),
				RetailerValueClassMap RVCM  WITH (NOLOCK)
		WHERE
				SI.SMId = S.SMId				AND SI.RMId = RM.RMId				
				AND SI.RtrId = R.RtrId			AND R.RtrStatus = 1
				AND SI.SMId = SM.SMId			AND RM.RMId = SI.RMId
				AND SM.RMId = RETMAR.RMId		AND RETMAR.RtrId = R.RtrId
				AND RETMAR.RtrId =Si.RtrId		AND DlvSts <> 3
				AND SIP.PrdId = P.PrdId			AND SI.SalId = SIP.SalId
				AND P.PrdId = PB.PrdId			AND PB.PrdId = SIP.PrdId
				AND SIP.PrdBatId = PB.PrdBatId	AND RVC.CtgMainId=RC.CtgMainId
				AND RVCM.RtrId=SI.RtrId			AND RC.CtgLevelId=RCL.CtgLevelId
				AND RVCM.RtrValueClassId=RVC.RtrClassId				
				AND PCV.PrdCtgValMainId=P.PrdCtgValMainId
				AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId
					/* Filters */
				AND SalInvDate Between @FromDate and @ToDate 	
				--- Company
				AND (P.CmpId =  (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR
								P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				--- SalesMan
				And (S.SMId = (CASE @SMId WHEN 0 THEN S.SMId Else 0 END) OR
							    S.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				--- Route
				AND (RM.RMId = (CASE @RMId WHEN 0 THEN RM.RMId Else 0 END) OR
		    					RM.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				--- Retailer Category Level
				AND (RCL.CtgLevelId = (CASE @RetCatLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
								RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				--- Retailer Category
				AND (RC.CtgMainId = (CASE @RetCatLevelValId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
							RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
				--- Retailer Value Class
				AND (RVC.RtrClassId = (CASE @RetLevelClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
								RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))				
				--- Retailer
				AND (SI.RtrId = (CASE @RetailerId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
								SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
					P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
					AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
------				--- Product Category
------				AND (PCL.CmpPrdCtgId = (CASE @PrdCatLevelId WHEN 0 THEN PCL.CmpPrdCtgId ELSE 0 END) OR
------							PCL.CmpPrdCtgId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)))	
------				--- ProductCategory Level Value
------				AND (PCV.PrdCtgValMainId = (CASE @PrdCatLevelValueId WHEN 0 THEN PCV.PrdCtgValMainId ELSE 0 END) OR
------								PCV.PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId)))
------				--- Product
------				AND (P.PrdId = (CASE @ProductId WHEN 0 THEN P.PrdId ELSE 0 END) OR
------								P.PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))	
					/* Till Here */
		GROUP BY
				SI.SMId,S.SMName,SI.RMId,RM.RMName,P.CmpId
		
					/* Calculate Total Outlets */
		INSERT INTO #TempRptEfficiencyReport
		SELECT
				SM.SMId,SM.SMName,RM.RMId,RM.RMName,
				Count(R.RtrId) AS TotalOutlets ,0 AS OutletsBilled,0 AS Coverage,	
				0 AS ScheduledCalls,0 AS ActualBills,0 AS Efficiecy,
				0 AS ValueTarget,0 AS ValueAchieved,0 AS Efficiency,
				CompanyId
		FROM
				Salesman SM,RouteMaster RM,SalesmanMarket SRM,
				Retailer R,RetailerMarket RMARKET,#TempRptEfficiencyReport T,
				RetailerValueClass RVC,
				RetailerCategory RC,RetailerCategorylevel RCL,
				RetailerValueClassMap RVCM
		WHERE
				SRM.SMId = SM.SMId 					AND SRM.RMId = RM.RMId
				AND SRM.RMId = RMARKET.RMId			AND RM.RMId = RMARKET.RMId
				AND R.RtrId = RMARKET.RtrId			AND RtrStatus = 1
				AND T.SMId = SM.SMId				AND T.RMId = RM.RMId
				AND RVCM.RtrId=R.RtrId				AND RC.CtgLevelId=RCL.CtgLevelId 				
				AND RVC.CmpId = T.CompanyId			AND RVC.CtgMainId = RC.CtgMainId	
				AND RC.CtgLevelId=RCL.CtgLevelId	AND RVCM.RtrValueClassId=RVC.RtrClassId			
				/* Filters */
				--- Company
				AND (T.CompanyId =  (CASE @CmpId WHEN 0 THEN T.CompanyId ELSE 0 END) OR
								T.CompanyId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				--- SalesMan
				And (SM.SMId = (CASE @SMId WHEN 0 THEN SM.SMId Else 0 END) OR
							    SM.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				--- Route
				AND (RM.RMId = (CASE @RMId WHEN 0 THEN RM.RMId Else 0 END) OR
		    					RM.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				--- Retailer Category Level
				AND (RCL.CtgLevelId = (CASE @RetCatLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
								RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				--- Retailer Category
				AND (RC.CtgMainId = (CASE @RetCatLevelValId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
							RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
				--- Retailer Value Class
				AND (RVC.RtrClassId = (CASE @RetLevelClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
								RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))				
				--- Retailer
				AND (R.RtrId = (CASE @RetailerId WHEN 0 THEN R.RtrId ELSE 0 END) OR
								R.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
					/* Till Here */
		GROUP BY
				SM.SMId,SM.SMName,RM.RMId,RM.RMName,CompanyId
				/* Calculate Outlets Billed */
		INSERT INTO #TempRptEfficiencyReport
		SELECT
				SI.SMId,S.SMName,SI.RMId,RM.RMName,
				0 AS TotalOutlets ,Count(DISTINCT SI.RtrId) AS OutletsBilled,0 AS Coverage,	
				0 AS ScheduledCalls,0 AS ActualBills,0 AS Efficiecy,
				0 AS ValueTarget,0 AS ValueAchieved,0 AS Efficiency,
				T.CompanyId
		FROM
				SalesInvoice SI				WITH (NOLOCK),	Salesman S WITH (NOLOCK),
				RouteMaster RM				WITH (NOLOCK),	Retailer R WITH (NOLOCK),
				SalesmanMarket SM			WITH (NOLOCK),  RetailerMarket RETMAR     WITH (NOLOCK),
				Product P					WITH (NOLOCK),	SalesInvoiceProduct SIP   WITH (NOLOCK),
				ProductBatch PB				WITH (NOLOCK),	RetailerValueClass RVC    WITH (NOLOCK),
				RetailerCategory RC			WITH (NOLOCK),	RetailerCategorylevel RCL WITH (NOLOCK),
				ProductCategoryLevel PCL    WITH (NOLOCK),
				ProductCategoryValue PCV    WITH (NOLOCK),
				RetailerValueClassMap RVCM  WITH (NOLOCK),
				#TempRptEfficiencyReport T
		WHERE
				SI.SMId = S.SMId				AND SI.RMId = RM.RMId				
				AND SI.RtrId = R.RtrId			AND R.RtrStatus = 1
				AND SI.SMId = SM.SMId			AND RM.RMId = SI.RMId
				AND SM.RMId = RETMAR.RMId		AND RETMAR.RtrId = R.RtrId
				AND RETMAR.RtrId =Si.RtrId		AND DlvSts <> 3
				AND SIP.PrdId = P.PrdId			AND SI.SalId = SIP.SalId
				AND P.PrdId = PB.PrdId			AND PB.PrdId = SIP.PrdId
				AND SIP.PrdBatId = PB.PrdBatId	AND RVC.CtgMainId=RC.CtgMainId
				AND RVCM.RtrId=SI.RtrId			AND RC.CtgLevelId=RCL.CtgLevelId
				AND T.SMId = SM.SMId				AND T.RMId = RM.RMId
				AND RVCM.RtrValueClassId=RVC.RtrClassId				
				AND PCV.PrdCtgValMainId=P.PrdCtgValMainId
				AND PCL.CmpPrdCtgId=PCV.CmpPrdCtgId
					/* Filters */
				AND SalInvDate Between @FromDate and @ToDate 	
				--- Company
				AND (P.CmpId =  (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR
								P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				--- SalesMan
				And (S.SMId = (CASE @SMId WHEN 0 THEN S.SMId Else 0 END) OR
							    S.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				--- Route
				AND (RM.RMId = (CASE @RMId WHEN 0 THEN RM.RMId Else 0 END) OR
		    					RM.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				--- Retailer Category Level
				AND (RCL.CtgLevelId = (CASE @RetCatLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
								RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				--- Retailer Category
				AND (RC.CtgMainId = (CASE @RetCatLevelValId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
							RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
				--- Retailer Value Class
				AND (RVC.RtrClassId = (CASE @RetLevelClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
								RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))				
				--- Retailer
				AND (SI.RtrId = (CASE @RetailerId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
								SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
					P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
					AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
--------				--- Product Category
--------				AND (PCL.CmpPrdCtgId = (CASE @PrdCatLevelId WHEN 0 THEN PCL.CmpPrdCtgId ELSE 0 END) OR
--------							PCL.CmpPrdCtgId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)))	
--------				--- ProductCategory Level Value
--------				AND (PCV.PrdCtgValMainId = (CASE @PrdCatLevelValueId WHEN 0 THEN PCV.PrdCtgValMainId ELSE 0 END) OR
--------								PCV.PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId)))
--------				--- Product
--------				AND (P.PrdId = (CASE @ProductId WHEN 0 THEN P.PrdId ELSE 0 END) OR
--------								P.PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))	
					/* Till Here */
		GROUP BY
				SI.SMId,S.SMName,SI.RMId,RM.RMName,P.CmpId,T.CompanyId
			/* Calculate Total Outlets */
			---	0 - Weekly,1 - BiWeekly,2 - Fort Nightly,3 - Monthly,4 - Daily
		INSERT INTO #TempRptEfficiencyReport
		SELECT
				SM.SMId,SM.SMName,RM.RMId,RM.RMName,
				0 AS TotalOutlets ,0 AS OutletsBilled,0 AS Coverage,	
				Case RtrFrequency
							When 0 Then Count(DISTINCT R.RtrId) * 4
							When 2 Then Count(DISTINCT R.RtrId) * 2
							When 4 Then Count(DISTINCT R.RtrId) * 24  END AS ScheduledCalls,
				0 AS ActualBills,0 AS Efficiecy,
				0 AS ValueTarget,0 AS ValueAchieved,0 AS Efficiency,
				CompanyId
		FROM
				Salesman SM					WITH (NOLOCK),RouteMaster RM			WITH (NOLOCK) ,
				Retailer R					WITH (NOLOCK),RetailerMarket RMARKET	WITH (NOLOCK),
				#TempRptEfficiencyReport T	WITH (NOLOCK),RetailerValueClass RVC	WITH (NOLOCK),
				RetailerCategory RC			WITH (NOLOCK),RetailerCategorylevel RCL WITH (NOLOCK),
				RetailerValueClassMap RVCM	WITH (NOLOCK),SalesmanMarket SRM		WITH (NOLOCK)
		WHERE
				SRM.SMId = SM.SMId 					AND SRM.RMId = RM.RMId
				AND SRM.RMId = RMARKET.RMId			AND RM.RMId = RMARKET.RMId
				AND R.RtrId = RMARKET.RtrId			AND RtrStatus = 1
				AND T.SMId = SM.SMId				AND T.RMId = RM.RMId
				AND RVCM.RtrId=R.RtrId				AND RC.CtgLevelId=RCL.CtgLevelId 				
				AND RVC.CmpId = T.CompanyId			AND RVC.CtgMainId = RC.CtgMainId	
				AND RC.CtgLevelId=RCL.CtgLevelId	AND RVCM.RtrValueClassId=RVC.RtrClassId			
				/* Filters */
				--- Company
				AND (T.CompanyId =  (CASE @CmpId WHEN 0 THEN T.CompanyId ELSE 0 END) OR
								T.CompanyId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				--- SalesMan
				And (SM.SMId = (CASE @SMId WHEN 0 THEN SM.SMId Else 0 END) OR
							    SM.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				--- Route
				AND (RM.RMId = (CASE @RMId WHEN 0 THEN RM.RMId Else 0 END) OR
		    					RM.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				--- Retailer Category Level
				AND (RCL.CtgLevelId = (CASE @RetCatLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
								RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				--- Retailer Category
				AND (RC.CtgMainId = (CASE @RetCatLevelValId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
							RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
				--- Retailer Value Class
				AND (RVC.RtrClassId = (CASE @RetLevelClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
								RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))				
				--- Retailer
				AND (R.RtrId = (CASE @RetailerId WHEN 0 THEN R.RtrId ELSE 0 END) OR
								R.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
					/* Till Here */
		GROUP BY
				SM.SMId,SM.SMName,RM.RMId,RM.RMName,CompanyId,RtrFrequency
					/* Target Value/Volume Calculated */	
		INSERT INTO #TempRptEfficiencyReport	
		SELECT
				TDT.SMId,	S.SMName,
				TDT.RMId,	RM.RMName,
				0 AS TotalOutlets,0 AS OutletsBilled,0 AS Coverage,
				0 AS ScheduledCalls,0 AS ActualBills,0 AS Efficiecy,
				Round(Sum(CurMonthTarget),2) AS ValueTarget,
				0 AS ValueAchieved,
				0 AS TargetEfficiency,
				TH.CmpId AS CompanyId
		FROM
				TargetAnalysisHd TH			WITH (NOLOCK),TargetAnalysisDt TDT WITH (NOLOCK),
				SalesMan S					WITH (NOLOCK),ProductCategoryLevel PCL	WITH (NOLOCK),		
				RouteMaster RM				WITH (NOLOCK),SalesmanMarket SM WITH (NOLOCK),
				Retailer R					WITH (NOLOCK),RetailerMarket RetMar WITH (NOLOCK),
				Product P					WITH (NOLOCK),RetailerValueClassMap RVCMap WITH (NOLOCK),
				RetailerValueClass RVC		WITH (NOLOCK),RetailerCategory RC WITH (NOLOCK),
				RetailerCategorylevel RCL	WITH (NOLOCK),ProductCategoryValue PCV WITH (NOLOCK)				
		WHERE
				TH.TargetAnalysisId = TDT.TargetAnalysisId
				AND TDT.RMId = RM.RMId				AND TDT.SmId = SM.SMId
				AND S.SMId   = SM.SMId				AND TDT.RMId = SM.RMId
				AND RetMar.RMId   = RM.RMId			AND TDT.RtrId = RetMar.RtrId
				AND R.RtrId  = RetMar.RtrId			AND R.RtrStatus = 1
				AND TDT.PrdId = P.PrdId				AND RVCMap.RtrId = R.RtrId
				AND Rc.CtgMainId = RVC.CtgMainId	AND RVCMap.RtrValueClassId=RVC.RtrClassId	
				AND RCL.CtgLevelId = Rc.CtgLevelId	AND TDT.RtrId = RVCMap.RtrId
				AND RetMar.RtrId = RVCMap.RtrId		AND P.PrdCtgValMainId = PCV.PrdCtgValMainId
				AND PCL.CmpPrdCtgId = PCV.CmpPrdCtgId
				AND TDT.SmId IN (SELECT DISTINCT SMId		FROM #TempRptEfficiencyReport)
				AND TDT.RmId IN (SELECT DISTINCT RMId		FROM #TempRptEfficiencyReport)
				AND TH.CmpId IN (SELECT DISTINCT CompanyID	FROM #TempRptEfficiencyReport)
							/* Filters */
				---		JcYear
				AND TH.JCMId = @YearId
				---		JcMonth
				AND TH.JcmJc = @MonthId
				---     CompanyId
				AND (P.CmpId =  (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR
								P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				--- SalesMan
				And (S.SMId = (CASE @SMId WHEN 0 THEN S.SMId Else 0 END) OR
							    S.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				--- Route
				AND (RM.RMId = (CASE @RMId WHEN 0 THEN RM.RMId Else 0 END) OR
		    					RM.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				--- Retailer Category Level
				AND (RCL.CtgLevelId = (CASE @RetCatLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
								RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				--- Retailer Category
				AND (RC.CtgMainId = (CASE @RetCatLevelValId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
							RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
				--- Retailer Value Class
				AND (RVC.RtrClassId = (CASE @RetLevelClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
								RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))				
				--- Retailer
				AND (R.RtrId = (CASE @RetailerId WHEN 0 THEN R.RtrId ELSE 0 END) OR
								R.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
					P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
					AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
------				--- Product Category
------				AND (PCL.CmpPrdCtgId = (CASE @PrdCatLevelId WHEN 0 THEN PCL.CmpPrdCtgId ELSE 0 END) OR
------							PCL.CmpPrdCtgId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)))	
------				--- ProductCategory Level Value
------				AND (PCV.PrdCtgValMainId = (CASE @PrdCatLevelValueId WHEN 0 THEN PCV.PrdCtgValMainId ELSE 0 END) OR
------								PCV.PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId)))
------				--- Product
------				AND (P.PrdId = (CASE @ProductId WHEN 0 THEN P.PrdId ELSE 0 END) OR
------								P.PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		GROUP BY
				TDT.SMId,TDT.RMId,TH.CmpId,S.SMName,RM.RMName
			/*	Target Achieved Vaule/Volume Calculation */
		INSERT INTO #TempRptEfficiencyReport	
		SELECT
				SI.SMId,	S.SMName,
				SI.RMId,	RM.RMName,
				0 AS TotalOutlets,0 AS OutletsBilled,0 AS Coverage,
				0 AS ScheduledCalls,0 AS ActualBills,0 AS Efficiecy,
				0 AS ValueTarget,
				CASE @TargetTypeId WHEN 2 THEN Sum(SIP.PrdGrossAmount)
								   WHEN 1 THEN Sum(Baseqty) END AS ValueAchieved,
				0 AS TargetEfficiency,
				PCL.CmpId AS CompanyId
		FROM
				SalesInvoice SI				WITH (NOLOCK),SalesInvoiceProduct SIP WITH (NOLOCK),
				SalesMan S					WITH (NOLOCK),ProductCategoryLevel PCL	WITH (NOLOCK),	
				RouteMaster RM				WITH (NOLOCK),SalesmanMarket SM WITH (NOLOCK),
				Retailer R					WITH (NOLOCK),RetailerMarket RetMar WITH (NOLOCK),
				Product P					WITH (NOLOCK),RetailerValueClassMap RVCMap WITH (NOLOCK),
				RetailerValueClass RVC		WITH (NOLOCK),RetailerCategory RC WITH (NOLOCK),
				RetailerCategorylevel RCL	WITH (NOLOCK),ProductCategoryValue PCV WITH (NOLOCK) 				
		WHERE
				SI.SalId = SIP.SalId
				AND SI.RMId = RM.RMId				AND SI.SmId = SM.SMId
				AND S.SMId   = SM.SMId				AND SI.RMId = SM.RMId
				AND RetMar.RMId   = RM.RMId			AND SI.RtrId = RetMar.RtrId
				AND R.RtrId  = RetMar.RtrId			AND R.RtrStatus = 1
				AND SIP.PrdId = P.PrdId				AND RVCMap.RtrId = R.RtrId
				AND Rc.CtgMainId = RVC.CtgMainId	AND RVCMap.RtrValueClassId=RVC.RtrClassId	
				AND RCL.CtgLevelId = Rc.CtgLevelId	AND SI.RtrId = RVCMap.RtrId
				AND RetMar.RtrId = RVCMap.RtrId		AND P.PrdCtgValMainId = PCV.PrdCtgValMainId
				AND DlvSts <> 3     				AND PCL.CmpPrdCtgId = PCV.CmpPrdCtgId 	
				AND SI.SmId IN (SELECT DISTINCT SMId		FROM #TempRptEfficiencyReport )
				AND SI.RmId IN (SELECT DISTINCT RMId		FROM #TempRptEfficiencyReport )
				AND PCL.CmpId IN (SELECT DISTINCT CompanyId	FROM #TempRptEfficiencyReport )
					/*	Filters	*/
				AND SalInvDate Between @FromDate and @ToDate 	
				--- Company
				AND (P.CmpId =  (CASE @CmpId WHEN 0 THEN P.CmpId ELSE 0 END) OR
								P.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
				--- SalesMan
				And (S.SMId = (CASE @SMId WHEN 0 THEN S.SMId Else 0 END) OR
							    S.SMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
				--- Route
				AND (RM.RMId = (CASE @RMId WHEN 0 THEN RM.RMId Else 0 END) OR
		    					RM.RMId IN (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
				--- Retailer Category Level
				AND (RCL.CtgLevelId = (CASE @RetCatLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
								RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				--- Retailer Category
				AND (RC.CtgMainId = (CASE @RetCatLevelValId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
							RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
				--- Retailer Value Class
				AND (RVC.RtrClassId = (CASE @RetLevelClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
								RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))				
				--- Retailer
				AND (SI.RtrId = (CASE @RetailerId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
								SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				AND	(P.PrdId = (CASE @PrdCatId WHEN 0 THEN P.PrdId Else 0 END) OR
					P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
			
					AND (P.PrdId = (CASE @PrdId WHEN 0 THEN P.PrdId Else 0 END) OR
						P.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
------				--- Product Category
------				AND (PCL.CmpPrdCtgId = (CASE @PrdCatLevelId WHEN 0 THEN PCL.CmpPrdCtgId ELSE 0 END) OR
------							PCL.CmpPrdCtgId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)))	
------				--- ProductCategory Level Value
------				AND (PCV.PrdCtgValMainId = (CASE @PrdCatLevelValueId WHEN 0 THEN PCV.PrdCtgValMainId ELSE 0 END) OR
------								PCV.PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId)))
------				--- Product
------				AND (P.PrdId = (CASE @ProductId WHEN 0 THEN P.PrdId ELSE 0 END) OR
------								P.PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))	
					/* Till Here */
		GROUP BY
				SI.SMId,SI.RMId,PCL.CmpId,S.SMName,RM.RMName
					/* Final Output Query  */
		INSERT INTO #RptEfficiencyReport
		SELECT
				SMId,SMName,RMId,RMName,
				Sum(TotalOutlets) AS TotalOutlets,		Sum(OutletsBilled) AS OutletsBilled,
				Isnull(Sum(OutletsBilled)/ NullIf(Sum(TotalOutlets),0),0) * 100 AS Coverage,
				Sum(ScheduledCalls) AS ScheduledCalls,	Sum(ActualBills) AS ActualBills,
				Isnull(Sum(ActualBills)/ NullIf(Sum(ScheduledCalls),0),0) * 100 AS Efficiecy,
				Sum(ValueTarget) AS ValueTarget,	Sum(ValueAchieved) AS ValueAchieved,
				Isnull(Sum(ValueAchieved)/ NullIf(Sum(ValueTarget),0),0) * 100  TargetEfficiency,
				CompanyId AS CompanyId
		FROM
				#TempRptEfficiencyReport
		GROUP BY
				SMId,SMName,RMId,RMName,CompanyId
		ORDER BY
				SMId,RMId
		DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
		INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
		SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptEfficiencyReport
		
		SELECT * FROM #RptEfficiencyReport  ORDER BY SMId,RMId
				
				/* New Snap Shot Data Stored*/
		IF @Pi_SnapRequired = 1
		BEGIN
			SELECT @NewSnapId = @Pi_SnapId
			
			EXEC Proc_SnapShot_Report @NewSnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
				@Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
			
			SET @sSql = 'INSERT INTO [' + @DBNAME + '].dbo.' + @TblName +
				'(SnapId,UserId,RptId,' + @TblFields + ')' +
				' SELECT ' + CAST(@NewSnapId AS VARCHAR(10)) +
				' ,' + CAST(@Pi_UsrId AS VARCHAR(10)) +
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ',* FROM #RptEfficiencyReport'		
			EXEC (@SSQL)
			PRINT 'Saved Data Into SnapShot Table'
		END
	END
			/* To Retrieve Data From Snap Data */
	ELSE				
	BEGIN
		EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,
								  @Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT
			IF @ErrNo = 0
			BEGIN
				SET @SSQL = 'INSERT INTO #RptEfficiencyReport ' +
					'(' + @TblFields + ')' +
					' SELECT ' + @TblFields + ' FROM ['  + @DBNAME + '].dbo.' + @TblName +
					' WHERE SNAPID = ' + CAST(@Pi_SnapId AS VARCHAR(10)) +
					' AND UserId = ' + CAST(@Pi_UsrId AS VARCHAR(10)) +
					' AND RptId = ' + CAST(@Pi_RptId AS VARCHAR(10))	
					EXEC (@SSQL)
					PRINT 'Retrived Data From Snap Shot Table'
					SELECT * FROM #RptEfficiencyReport
			END
			ELSE
			BEGIN
				PRINT 'DataBase or Table not Found'
				RETURN
			END
		END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-185-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptRtrWiseBrandWiseSales]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptRtrWiseBrandWiseSales]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_RptRtrWiseBrandWiseSales 169,1,0,'LorealSite',0,0,1

CREATE PROCEDURE [dbo].[Proc_RptRtrWiseBrandWiseSales]
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
/****************************************************************************
* PROCEDURE  : Proc_RptRtrWiseBrandWiseSales
* PURPOSE    : To Generate Retailer Wise Brand Wise Report
* CREATED BY : Aarthi
* CREATED ON : 16/09/2009
* MODIFICATION
*****************************************************************************/
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
DECLARE @FromDate	AS	DATETIME
DECLARE @ToDate	 	AS	DATETIME
DECLARE @CmpId      AS  INT
DECLARE @SMId 		AS	INT
DECLARE @RMId	 	AS	INT
DECLARE @RtrId	 	AS	INT
DECLARE @CtgLevelId	AS 	INT
DECLARE @RtrClassId	AS 	INT
DECLARE @CtgMainId 	AS 	INT
DECLARE @PDC	AS	INT
DECLARE @PrdCatId	AS	INT
DECLARE @PrdId		AS	INT
DECLARE @HirMainId	AS INT
DECLARE @CtgValue   AS INT
DECLARE	@EXLFlag	AS	INT
--Till Here
--Assgin Value for the Filter Variable
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))
SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))
SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))
SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))
SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))
SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))
SET @HirMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
SET @CtgValue=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
--Till Here
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
--Till Here'
EXEC Proc_GetProductwiseHierarchy
EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
CREATE TABLE #RptRtrWiseBrandWiseSales
		(
	    [Salesman Name]				NVARCHAR(100),
		[Route Name]				NVARCHAR(100),
		[Retailer Category]			NVARCHAR(100),
		[Retailer Classification]	NVARCHAR(100),
		[Retailer Code]       NVARCHAR(50),
		[Retailer Name]       NVARCHAR(100),
		[RtrId]				  INT,
		[Product Hierarchy]	  NUMERIC(18, 2),
		[Hierarchy]			  NVARCHAR(100)
)
SET @TblName = 'RptRtrWiseBrandWiseSales'
SET @TblStruct = '
		[Salesman Name]				NVARCHAR(100),
		[Route Name]				NVARCHAR(100),
		[Retailer Category]			NVARCHAR(100),
		[Retailer Classification]	NVARCHAR(100),
		[Retailer Code]       NVARCHAR(50),
		[Retailer Name]       NVARCHAR(100),
		[RtrId]				  INT,
		[Product Hierarchy]	  [numeric](18, 2),
		[Hierarchy]			  NVARCHAR(100)'
SET @TblFields = '[Salesman Name],[Route Name],
					[Retailer Category],[Retailer Classification],[Retailer Code],[Retailer Name],
					[RtrId],[Product Hierarchy],[Hierarchy]'
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
			SELECT DISTINCT Prdid, C.PrdCtgValName INTO #Tempa FROM
		ProductCategoryValue C
		INNER JOIN ProductCategoryValue D ON
		C.PrdCtgValMainId = (CASE @HirMainId WHEN 0 THEN C.PrdCtgValMainId Else 0 END) OR
		C.PrdCtgValMainId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId)) AND
		D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E On D.PrdCtgValMainId = E.PrdCtgValMainId
		LEFT OUTER JOIN ProductCategoryLevel PCL ON PCL.CmpPrdCtgId=C.CmpPrdCtgId where  PCL.CmpPrdCtgId IN (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
			INSERT INTO #RptRtrWiseBrandWiseSales([Salesman Name],[Route Name],
					[Retailer Category],[Retailer Classification],[Retailer Code],[Retailer Name],
					[RtrId],[Product Hierarchy],[Hierarchy])
				SELECT DISTINCT S.SMName AS [Salesman Name],RM.RMName AS [Route Name],
					RC.CtgName AS [Retailer Category],RVC.ValueClassName AS [Retailer Classification],
					R.RtrCode AS [Retailer Code],R.RtrName AS[Retailer Name],
					SI.[RtrId],0 AS [Product Hierarchy] ,A.PrdCtgValName AS [Hierarchy]
					FROM #Tempa A
					LEFT OUTER JOIN SalesInvoiceProduct SIP ON SIP.PrdId=A.PrdId
					LEFT OUTER JOIN SalesInvoice SI ON SI.SalId=SIP.SalId
					LEFT OUTER JOIN Salesman S ON S.SMId= SI.SMId
					LEFT OUTER JOIN RouteMaster RM ON RM.RMId=SI.RMId
					LEFT OUTER JOIN Retailer R ON R.RtrId=SI.RtrId
					LEFT OUTER JOIN RetailerValueClassMap RVCM WITH (NOLOCK)ON R.Rtrid = RVCM.RtrId
					LEFT OUTER JOIN RetailerValueClass RVC WITH (NOLOCK) ON RVCM.RtrValueClassId = RVC.RtrClassId
				AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR
			RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))
				AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
			RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
			INNER JOIN RetailerCategory RC WITH (NOLOCK) ON RVC.CtgMainId=RC.CtgMainId
				AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR
			RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
			INNER JOIN RetailerCategoryLevel RCL ON RCL.CtgLevelId=RC.CtgLevelId
			AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR
			RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))
				 WHERE (SI.RtrId = (CASE @RtrId WHEN 0 THEN SI.RtrId ELSE 0 END) OR
							SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))
				 AND (SI.RMId=(CASE @RMId WHEN 0 THEN SI.RMId ELSE 0 END) OR
							SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))
							
				 AND (SI.SMId=(CASE @SMId WHEN 0 THEN SI.SMId ELSE 0 END) OR
							SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))
		
				 AND (SI.SalInvDate Between @FromDate and @ToDate) AND SI.DlvSts IN(4,5)
	IF LEN(@PurDBName) > 0
	BEGIN
		EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
		
		SET @SSQL = 'INSERT INTO #RptRtrWiseBrandWiseSales ' +
			'(' + @TblFields + ')' +
			' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +
			
			'WHERE (SI.RtrId = (CASE ' +  CAST(@RtrId AS INTEGER) + ' WHEN 0 THEN SI.RtrId ELSE 0 END) OR
					SI.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',3,' + CAST(@Pi_UsrId as INTEGER) +')))
								
			AND (SI.RMId=(CASE ' + CAST(@RMId AS INTEGER) + ' WHEN 0 THEN SI.RMId ELSE 0 END) OR
								SI.RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',2,' + CAST(@Pi_UsrId as INTEGER) +')))
								
			AND (SI.SMId=(CASE '+ CAST(@SMId AS INTEGER) + 'WHEN 0 THEN SI.SMId ELSE 0 END) OR
								SI.SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',1,' + CAST(@Pi_UsrId as INTEGER) + ')))
			AND (SI.SalInvDate Between ' + @FromDate +' and ' + @ToDate +') and SI.DlvSts IN(4,5)'
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptRtrWiseBrandWiseSales'
	
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
			SET @SSQL = 'INSERT INTO #RptRtrWiseBrandWiseSales ' +
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
SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptRtrWiseBrandWiseSales
-- Till Here
--SELECT * FROM #RptRtrWiseBrandWiseSales
SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	IF @EXLFlag=1
	BEGIN
		
		/***************************************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @Salesman  NVARCHAR(100)
		DECLARE  @Route		NVARCHAR(100)
		DECLARE	 @RtrCat	NVARCHAR(100)
		DECLARE	 @RtrClass	NVARCHAR(100)
		DECLARE  @RetailerId BIGINT
		DECLARE  @RtrCode NVARCHAR(100)
		DECLARE  @RtrName NVARCHAR(100)
		DECLARE	 @Hierarchy NVARCHAR(100)
		DECLARE  @PrdHir	NUMERIC(18, 2)
		DECLARE  @SlNo INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @Name NVARCHAR(100)
		--DROP TABLE RptGRNListing_Excel
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptRtrWiseBrandWiseSales_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptRtrWiseBrandWiseSales_Excel]
		DELETE FROM RptExcelHeaders Where RptId=169 AND SlNo>7
		CREATE TABLE RptRtrWiseBrandWiseSales_Excel ([Salesman Name]NVARCHAR(100),[Route Name]NVARCHAR(100) ,[Retailer Category] NVARCHAR(100),[Retailer Classification] NVARCHAR(100),[Retailer Code] NVARCHAR(50),[Retailer Name]NVARCHAR(100),RtrId INT)
		SET @iCnt=8
		DECLARE Column_Cur CURSOR FOR
		SELECT DISTINCT Hierarchy--,SUM([Product Hierarchy])
					FROM #RptRtrWiseBrandWiseSales-- Group BY Hierarchy
		OPEN Column_Cur
			   FETCH NEXT FROM Column_Cur INTO @Column--,@SlNo
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptRtrWiseBrandWiseSales_Excel  ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					
					PRINT @C_SSQL
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
					FETCH NEXT FROM Column_Cur INTO @Column--,@SlNo
				END
		CLOSE Column_Cur
		DEALLOCATE Column_Cur
		--Insert table values
		DELETE FROM RptRtrWiseBrandWiseSales_Excel
		INSERT INTO RptRtrWiseBrandWiseSales_Excel([Salesman Name],[Route Name],[Retailer Category],[Retailer Classification],[Retailer Code],[Retailer Name],RtrId)
		SELECT DISTINCT [Salesman Name],[Route Name],[Retailer Category],[Retailer Classification],[Retailer Code],[Retailer Name],RtrId
				FROM #RptRtrWiseBrandWiseSales
		DECLARE Values_Cur CURSOR FOR
		SELECT  [Salesman Name],[Route Name],[Retailer Category],[Retailer Classification],[Retailer Code],[Retailer Name],RtrId,[Hierarchy],SUM([Product Hierarchy]) FROM #RptRtrWiseBrandWiseSales
				group by [Salesman Name],[Route Name],[Retailer Category],[Retailer Classification],[Retailer Code],[Retailer Name],RtrId,[Hierarchy]
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @Salesman,@Route,@RtrCat,@RtrClass,@RtrCode,@RtrName,@RetailerId,@Hierarchy,@PrdHir
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptRtrWiseBrandWiseSales_Excel  SET ['+ @Hierarchy +']= '+ CAST(@PrdHir AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL+ ' WHERE RtrId=' + CAST(@RetailerId AS VARCHAR(1000))
					+' AND [Retailer Code]=''' + CAST(@RtrCode AS VARCHAR(1000))+''''
					+' AND [Retailer Category]=''' + CAST(@RtrCat AS VARCHAR(1000)) +''''
					+' AND [Salesman Name]=''' + CAST(@Salesman AS VARCHAR(1000)) +''''
					+' AND [Route Name]=''' + CAST(@Route AS VARCHAR(1000)) +''''
					+' AND [Retailer Classification]=''' + CAST(@RtrClass AS VARCHAR(1000)) +''''
					
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @Salesman,@Route,@RtrCat,@RtrClass,@RtrCode,@RtrName,@RetailerId,@Hierarchy,@PrdHir
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptRtrWiseBrandWiseSales_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptRtrWiseBrandWiseSales_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
		/***************************************************************************************************************************/
--select * from RptRtrWiseBrandWiseSales_Excel
	END
	DECLARE @PrdCtgValue nvarchar(100)
	DECLARE @CtgValueName nVarchar(100)
--DECLARE @sSql nvarchar(4000)
	SELECT @CtgValueName=CmpPrdCtgName FROM ProductCategoryLevel WHERE CmpPrdCtgId=@CtgValue
		SET @sSql='
		UPDATE #RptRtrWiseBrandWiseSales SET [Product Hierarchy]=A.ProductHierarchy
		FROM (SELECT DISTINCT SI.RtrId,SIP.PrdGrossAmountAftEdit AS ProductHierarchy,PCV.PrdCtgValName
		FROM SalesInvoiceProduct SIP,ProductWiseHierarchy P,SalesInvoice SI,ProductCategoryValue PCV,
		ProductCategoryLevel PCL,Retailer R
		WHERE SI.Salid=SIP.salid AND SIP.Prdid=P.ProductId AND (SI.SalInvDate Between ''' + cast(@FromDate AS nVarchar(11)) +''' and ''' + cast(@ToDate AS nVarchar(11)) +''') AND SI.DlvSts IN(4,5)
		AND PCV.PrdCtgValName=P.['+ @CtgValueName +'] AND SI.RtrId=R.RtrId) A
		WHERE A.RtrId=#RptRtrWiseBrandWiseSales.RtrId AND A.PrdCtgValName=#RptRtrWiseBrandWiseSales.Hierarchy'
		Exec (@sSql)
	SELECT * FROM #RptRtrWiseBrandWiseSales
RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if not exists (select * from hotfixlog where fixid = 353)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(353,'D','2010-12-22',getdate(),1,'Core Stocky Service Pack 353')