--[Stocky HotFix Version]=415
DELETE FROM Versioncontrol WHERE Hotfixid='415'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('415','3.1.0.0','D','2014-07-03','2014-07-03','2014-07-03',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
--Live Script Updater
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_ReturnSchemeApplicable')
DROP PROCEDURE Proc_ReturnSchemeApplicable
GO
CREATE PROCEDURE Proc_ReturnSchemeApplicable
(
	@Pi_SrpId		INT,
	@Pi_RmId		INT,
	@Pi_RtrId		INT,
	@Pi_BillType		INT,
	@Pi_BillMode		INT,
	@Pi_SchId  		INT,
	@Po_Applicable 		INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_ReturnSchemeApplicable
* PURPOSE		: To Return whether the Scheme is applicable for the Retailer or Not
* CREATED		: Thrinath
* CREATED DATE	: 12/04/2007
* NOTE			: General SP for Returning the whether the Scheme is applicable for the Retailer or Not
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
* Include the Cluster Attribute checking based on Approval Required Status By Boopathy on 16-11-2011
* 18-12-2013   PRAVEENRAJ B	ADDED CPB FOR AMUL CR:CRCRSTAML0008
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @RetDet TABLE
	(
		RtrId 				INT,
		RtrValueClassId		INT,
		CtgMainId			INT,
		CtgLinkId           INT,
		CtgLevelId			INT,
		RtrPotentialClassId	INT,
		RtrKeyAcc			INT,
		VillageId			INT,
		CtgLinkCode         NVARCHAR(100)
	)
	DECLARE @RMDet TABLE
	(
		RMId				INT,
		RMVanRoute			INT,
		RMSRouteType		INT,
		RMLocalUpcountry	INT
	)
	DECLARE @VillageDet TABLE
	(
		VillageId			INT,
		RoadCondition		INT,
		Incomelevel			INT,
		Acceptability		INT,
		Awareness			INT
	)
	DECLARE @SchemeRetAttr TABLE
	(
		AttrType			INT,
		AttrId				INT
	)
	DECLARE @AttrType 				INT
	DECLARE	@AttrId					INT
	DECLARE @Applicable_SM			INT
	DECLARE @Applicable_RM			INT
	DECLARE @Applicable_Vill		INT
	DECLARE @Applicable_RtrLvl		INT
	DECLARE @Applicable_RtrVal		INT
	DECLARE @Applicable_VC			INT
	DECLARE @Applicable_PC			INT
	DECLARE @Applicable_Rtr			INT
	DECLARE @Applicable_BT			INT
	DECLARE @Applicable_BM			INT
	DECLARE @Applicable_RT			INT
	DECLARE @Applicable_CT			INT
	DECLARE @Applicable_VRC			INT
	DECLARE @Applicable_VI			INT
	DECLARE @Applicable_VA			INT
	DECLARE @Applicable_VAw			INT
	DECLARE @Applicable_RouteType	INT
	DECLARE @Applicable_LocUpC		INT
	DECLARE @Applicable_VanRoute	INT
	DECLARE @Applicable_Cluster		INT
	SET @Applicable_SM=0
	SET @Applicable_RM=0
	SET @Applicable_Vill=0
	SET @Applicable_RtrLvl=1
	SET @Applicable_RtrVal=0
	SET @Applicable_VC=0
	SET @Applicable_PC=0
	SET @Applicable_Rtr=0
	SET @Applicable_BT=0
	SET @Applicable_BM=0
	SET @Applicable_RT=0
	SET @Applicable_CT=0
	SET @Applicable_VRC=0
	SET @Applicable_VI=0
	SET @Applicable_VA=0
	SET @Applicable_VAw=0
	SET @Applicable_RouteType=0
	SET @Applicable_LocUpC=0
	SET @Applicable_VanRoute=0	
	SET @Applicable_Cluster=0
	SET @Po_Applicable = 1
	
	--Added by Sathishkumar Veeramani 2014/03/31
	IF EXISTS (SELECT * FROM Configuration WITH(NOLOCK) WHERE ModuleId = 'BILL6' AND Status = 1)
	BEGIN
		--Added by Praveenraj B ON 18-12-2013 For CRCRSTAML0008
		IF EXISTS(SELECT Schid FROM SchemeMaster where CPB=1 and Schid=@Pi_SchId)
		BEGIN
			IF NOT EXISTS(SELECT SyncStatus FROM SYNCSTATUS where SyncStatus=1 and CONVERT(VARCHAR(10),dwnendtime,121)=CONVERT(VARCHAR(10),GETDATE(),121))
			 BEGIN
				SET @Po_Applicable = 0
				RETURN
			 END	
		END
	END
	--Till Here
	--IF EXISTS (SELECT * FROM SchemeMaster (NOLOCK) WHERE Claimable=1 AND SchId=@Pi_SchId)
	--BEGIN
	--	IF EXISTS (SELECT * FROM Retailer (NOLOCK) WHERE Approved=0 AND RtrId=@Pi_RtrId)
	--	BEGIN
	--		SET @Po_Applicable=0
	--		RETURN
	--	END
	--END
	--End here
	INSERT INTO @RetDet(RtrId,RtrValueClassId,CtgMainId,CtgLinkId,CtgLevelId,RtrPotentialClassId,RtrKeyAcc,VillageId,CtgLinkCode)
	SELECT R.RtrId,RVCM.RtrValueClassId,RC.CtgMainId,RC.CtgLinkId,RCL.CtgLevelId,
		ISNULL(RPCM.RtrPotentialClassId,0) AS RtrPotentialClassId,R.RtrKeyAcc,R.VillageId,RC.CtgLinkCode
		FROM Retailer  R INNER JOIN RetailerValueClassmap RVCM ON R.RtrId = RVCM.RtrId and R.RtrId = @Pi_RtrId
		INNER JOIN RetailerValueClass RVC ON RVCM.RtrValueClassId = RVC.RtrClassId
		INNER JOIN RetailerCategory RC ON RC.CtgMainId = RVC.CtgMainId
		INNER JOIN RetailerCategoryLevel RCL ON RC.CtgLevelId = RCL.CtgLevelId
		LEFT OUTER JOIN RetailerPotentialClassmap RPCM on R.RtrId = RPCM.RtrId
		LEFT OUTER JOIN RetailerPotentialClass [RPC] on RPCM.RtrPotentialClassId = [RPC].RtrClassId
	
	INSERT INTO @RMDet(RMId,RMVanRoute,RMSRouteType,RMLocalUpcountry)
	SELECT  RMId,RMVanRoute,RMSRouteType,RMLocalUpcountry
		FROM RouteMaster RM WHERE RM.RMId = @Pi_RmId
	INSERT INTO @VillageDet(VillageId,RoadCondition,Incomelevel,Acceptability,Awareness)
	SELECT  A.VillageId,ISNULL(RoadCondition,0),ISNULL(Incomelevel,0),ISNULL(Acceptability,0),
		ISNULL(Awareness,0) FROM @RetDet A  LEFT OUTER JOIN Routevillage RV
		ON A.VillageId = RV.VillageId
	INSERT INTO @SchemeRetAttr (AttrType,AttrId)
	SELECT AttrType,AttrId FROM SchemeRetAttr  WHERE SchId = @Pi_SchId AND AttrId > 0 ORDER BY AttrType
	
	IF NOT EXISTS(SELECT AttrId FROM SchemeRetAttr WHERE SchId = @Pi_SchId AND AttrType=3)
	BEGIN
		SET @Applicable_Vill=1
	END
	IF NOT EXISTS(SELECT AttrId FROM SchemeRetAttr WHERE SchId = @Pi_SchId AND AttrType=7)
	BEGIN
		SET @Applicable_PC=1
	END
	DECLARE  CurSch1 CURSOR FOR
	SELECT DISTINCT AttrType FROM SchemeRetAttr WHERE AttrId=0 AND SchId = @Pi_SchId ORDER BY AttrType
		OPEN CurSch1
		FETCH NEXT FROM CurSch1 INTO @AttrType
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @AttrType = 1
			SET @Applicable_SM=1
		ELSE IF @AttrType =2
			SET @Applicable_RM=1
		ELSE IF @AttrType =3
			SET @Applicable_Vill=1
		ELSE IF @AttrType =4
			SET @Applicable_RtrLvl=1
		ELSE IF @AttrType =5
			SET @Applicable_RtrVal=1
		ELSE IF @AttrType =6
			SET @Applicable_VC=1
		ELSE IF @AttrType =7
			SET @Applicable_PC=1
		ELSE IF @AttrType =8
			SET @Applicable_Rtr=1
		ELSE IF @AttrType =10
			SET @Applicable_BT=1
		ELSE IF @AttrType =11
			SET @Applicable_BM=1
		ELSE IF @AttrType =12
			SET @Applicable_RT=1
		ELSE IF @AttrType =13
			SET @Applicable_CT=1
		ELSE IF @AttrType =14
			SET @Applicable_VRC=1
		ELSE IF @AttrType =15
			SET @Applicable_VI=1
		ELSE IF @AttrType =16
			SET @Applicable_VA=1
		ELSE IF @AttrType =17
			SET @Applicable_VAw=1
		ELSE IF @AttrType =18
			SET @Applicable_RouteType=1
		ELSE IF @AttrType =19
			SET @Applicable_LocUpC=1
		ELSE IF @AttrType =20
			SET @Applicable_VanRoute=1		
		ELSE IF @AttrType =21
			SET @Applicable_Cluster=1
		FETCH NEXT FROM CurSch1 INTO @AttrType
	END
	CLOSE CurSch1
	DEALLOCATE CurSch1
	
	DECLARE  CurSch CURSOR FOR
	SELECT AttrType,AttrId FROM @SchemeRetAttr ORDER BY AttrType
		OPEN CurSch
		FETCH NEXT FROM CurSch INTO @AttrType,@AttrId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @AttrType = 1 AND @Applicable_SM=0		--SalesMan
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_SrpId)
				SET @Applicable_SM = 1
		END
		IF @AttrType = 2 AND @Applicable_RM=0		--Route
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_RmId)
				SET @Applicable_RM = 1
		END
		IF @AttrType = 3 AND @Applicable_Vill=0		--Village
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.VillageId AND A.AttrType = @AttrType)
				SET @Applicable_Vill = 1
		END
--		IF @AttrType = 4 AND @Applicable_RtrLvl=0		--Retailer Category Level
--		BEGIN
--			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
--						ON A.AttrId = B.CtgLevelId  AND A.AttrType = @AttrType)
--				SET @Applicable_RtrLvl = 1
--		END
			DECLARE @AVI_CTG INT
			IF @AttrType = 5 AND @Applicable_RtrVal=0		--Retailer Category Level Value
			BEGIN
				IF EXISTS (SELECT * FROM COMPANY (NOLOCK) WHERE CMPCODE='AMUL' AND DEFAULTCOMPANY=1)
				BEGIN
					SET  @AVI_CTG=0
					SELECT @AVI_CTG=DBO.FN_RETURNS_SCHEME_APPLICABLE_RETAILER (@Pi_SchId,@PI_RTRID)
					IF @AVI_CTG=0 
					BEGIN
						SET @Applicable_RtrVal=0 
					END
					ELSE
					BEGIN 
						SET @Applicable_RtrVal=1
					END
				END
				ELSE
					IF (SELECT COUNT(A.AttrId) FROM @SchemeRetAttr A WHERE A.AttrType = 4)=1
					BEGIN
						IF EXISTS(SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN RetailerCategoryLevel B
									ON A.AttrId = B.CtgLevelId  AND A.AttrType = 4 AND LevelName ='Level1')
						BEGIN
							IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
								ON A.AttrId = B.CtgLinkId AND A.AttrType = @AttrType)
									SET @Applicable_RtrVal = 1			
						END
					
						ELSE
						BEGIN
							IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
										ON A.AttrId = B.CtgMainId AND A.AttrType = @AttrType)
							BEGIN
								SET @Applicable_RtrVal = 1
							END
						END
					END
					ELSE
					BEGIN
						IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
										ON A.AttrId = B.CtgMainId AND A.AttrType = @AttrType)
						BEGIN
							SET @Applicable_RtrVal = 1
						END
					END
			END
			
		IF @AttrType = 6 AND @Applicable_VC=0		--Retailer Class Value
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON A.AttrId = B.RtrValueClassId AND A.AttrType = @AttrType)
				SET @Applicable_VC = 1
		END
--		IF @AttrType = 7 AND @Applicable_PC=0		--Retailer Potential Class
--		BEGIN
--			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A LEFT JOIN @RetDet B
--						ON A.AttrId = B.RtrPotentialClassId AND A.AttrType = @AttrType)
--				SET @Applicable_PC = 1
--		END
		IF @AttrType = 8 AND @Applicable_Rtr=0		--Retailer
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_RtrId)
			BEGIN
				SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_RtrId
				SET @Applicable_Rtr = 1
			END
		END
		IF @AttrType = 10 AND @Applicable_BT=0		--Bill Type
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_BillType)
				SET @Applicable_BT = 1
		END
		IF @AttrType = 11 AND @Applicable_BM=0		--Bill Mode
		BEGIN
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId = @Pi_BillMode)
				SET @Applicable_BM = 1
		END
		IF @AttrType = 12 AND @Applicable_RT=0		--Retailer Type
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RetDet B
						ON B.RtrKeyAcc =  CASE WHEN A.AttrId=1 THEN 2 WHEN A.AttrId=2 THEN 0 ELSE B.RtrKeyAcc END  AND A.AttrType = @AttrType)
				SET @Applicable_RT = 1
		END
		IF @AttrType = 13 AND @Applicable_CT=0		--Class Type
		BEGIN
			IF EXISTS (SELECT B.RtrPotentialClassId FROM @RetDet B WHERE B.RtrPotentialClassId > 0 )
				SET @Applicable_CT = 1
		END
		IF @AttrType = 14 AND @Applicable_VRC=0		--Village Road Condition
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.RoadCondition AND A.AttrType = @AttrType)
				SET @Applicable_VRC = 1
		END
		IF @AttrType = 15 AND @Applicable_VI=0		--Village Income Level
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.Incomelevel AND A.AttrType = @AttrType)
				SET @Applicable_VI = 1
		END
		IF @AttrType = 16 AND @Applicable_VA=0		--Village Acceptability
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.Acceptability AND A.AttrType = @AttrType)
				SET @Applicable_VA = 1
		END
		IF @AttrType = 17 AND @Applicable_VAw=0		--Village Awareness
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @VillageDet B
						ON A.AttrId = B.Awareness AND A.AttrType = @AttrType)
				SET @Applicable_VAw = 1
		END
		IF @AttrType = 18 AND @Applicable_RouteType=0		--Route Type
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RMDet B
						ON A.AttrId = B.RMSRouteType AND A.AttrType = @AttrType)
				SET @Applicable_RouteType = 1
		END
		IF @AttrType = 19 AND @Applicable_LocUpC=0		--Local / UpCountry
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RMDet B
						ON A.AttrId = B.RMLocalUpcountry AND A.AttrType = @AttrType)
				SET @Applicable_LocUpC = 1
		END
		IF @AttrType = 20 AND @Applicable_VanRoute=0		--Van / NonVan Route
		BEGIN
			IF EXISTS (SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN @RMDet B
						ON A.AttrId = B.RMVanRoute AND A.AttrType = @AttrType)
				SET @Applicable_VanRoute = 1
		END
		IF @AttrType = 21 AND @Applicable_Cluster=0		--Cluster
		BEGIN			
			IF EXISTS (SELECT AttrId FROM @SchemeRetAttr WHERE AttrType = @AttrType AND
						AttrId IN (SELECT DISTINCT B.ClusterId FROM ClusterGroupMaster A INNER JOIN 
									(SELECT DISTINCT B.ClsGroupId,A.ClusterId,A.MAsterRecordId,A.Status FROM ClusterAssign A INNER JOIN ClusterGroupDetails B 
									ON A.ClusterId=B.ClusterId AND A.MasterId=79 ) B ON A.ClsGroupId=B.ClsGroupId
									WHERE B.Status = CASE A.AppReqd WHEN 0 THEN B.Status ELSE 1 END AND MAsterRecordId=@Pi_RtrId))
--						AttrId IN(SELECT DISTINCT ClusterId FROM ClusterAssign A WHERE MasterId=79 AND MAsterRecordId=@Pi_RtrId AND Status=1))
				SET @Applicable_Cluster = 1
		END
		FETCH NEXT FROM CurSch INTO @AttrType,@AttrId
	END
	CLOSE CurSch
	DEALLOCATE CurSch
--
	PRINT @Applicable_SM
	PRINT @Applicable_RM
	PRINT @Applicable_Vill
	PRINT @Applicable_RtrLvl
	PRINT @Applicable_RtrVal
	PRINT @Applicable_VC
	PRINT @Applicable_PC
	PRINT @Applicable_Rtr
	PRINT @Applicable_BT
	PRINT @Applicable_BM
	PRINT @Applicable_RT
	PRINT @Applicable_CT
	PRINT @Applicable_VRC
	PRINT @Applicable_VI
	PRINT @Applicable_VA
	PRINT @Applicable_VAw
	PRINT @Applicable_RouteType
	PRINT @Applicable_LocUpC
	PRINT @Applicable_VanRoute
	PRINT @Applicable_Cluster
	IF @Applicable_SM=1 AND @Applicable_RM=1 AND @Applicable_Vill=1 AND --@Applicable_RtrLvl=1 AND
	@Applicable_RtrVal=1 AND @Applicable_VC=1 AND @Applicable_PC=1 AND @Applicable_Rtr = 1 AND
	@Applicable_BT=1 AND @Applicable_BM=1 AND @Applicable_RT=1 AND @Applicable_CT=1 AND
	@Applicable_VRC=1 AND @Applicable_VI=1 AND @Applicable_VA=1 AND @Applicable_VAw=1 AND
	@Applicable_RouteType=1 AND @Applicable_LocUpC=1 AND @Applicable_VanRoute=1 AND @Applicable_Cluster=1
	BEGIN
		SET @Po_Applicable=1
	END
	ELSE
	BEGIN
		SET @Po_Applicable=0
	END
	--->Added By Nanda on 08/10/2010 for FBM Validations
	IF @Po_Applicable=1
	BEGIN
		IF EXISTS(SELECT * FROM SchemeMaster WHERE SchId=@Pi_SchId AND FBM=1)
		BEGIN
			IF EXISTS(SELECT * FROM SchemeMaster WHERE SchId=@Pi_SchId AND Budget>0)
			BEGIN
				SET @Po_Applicable=1
			END
			ELSE
			BEGIN
				SET @Po_Applicable=0
			END
		END
	END
	--->Till Here
	--PRINT @Po_Applicable
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME='Proc_Cn2Cs_BLSchemeMaster' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_BLSchemeMaster
GO
/*
BEGIN TRANSACTION
update schememaster set schstatus = 0 where cmpschcode = 'SCH00007'
EXEC Proc_Cn2Cs_BLSchemeMaster 0
select *from schememaster where cmpschcode = 'SCH00007'
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_BLSchemeMaster
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
			IF (UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' AND UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO' AND UPPER(LTRIM(RTRIM(@BatLvl)))<> 'ALL')
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
			IF UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' OR UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO' OR UPPER(LTRIM(RTRIM(@BatLvl)))<> 'ALL'
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
			ELSE IF UPPER(LTRIM(RTRIM(@BatLvl)))= 'NO' OR UPPER(LTRIM(RTRIM(@BatLvl)))= 'ALL'
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
					--Budget=@SchBudget,SchStatus=@StatusId WHERE SchId=@GetKey
					Budget=@SchBudget/*,SchStatus=@StatusId*/ WHERE SchId=@GetKey --Modified by Muthuvel for DCONSPAR0470
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
					--SchemeLvlMode=@SelMode,SchStatus=@StatusId WHERE SchId=@GetKey
					SchemeLvlMode=@SelMode/*,SchStatus=@StatusId*/ WHERE SchId=@GetKey --Modified by Muthuvel for DCONSPAR0470
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
--PARLE Tax Settings Upload Process
DELETE FROM Tbl_UploadIntegration WHERE SequenceNo = 1005
INSERT INTO Tbl_UploadIntegration
SELECT 1005,'TaxSettingDetails','TaxSettingDetails','Cs2Cn_Prk_TempTaxSettingDetails',CONVERT(NVARCHAR(10),GETDATE(),121)
GO
DELETE FROM CustomUpDownload WHERE Module = 'TaxSettingDetails'
INSERT INTO CustomUpDownload
SELECT 129,1,'TaxSettingDetails','TaxSettingDetails','Proc_Cs2Cn_TempTaxSettingDetails','','Cs2Cn_Prk_TempTaxSettingDetails',
'Proc_Cs2Cn_TempTaxSettingDetails','Master','Upload',1
GO
IF EXISTS (SELECT Name FROM Sysobjects WHERE XTYPE = 'U' AND name = 'Cs2Cn_Prk_TempTaxSettingDetails')
DROP TABLE Cs2Cn_Prk_TempTaxSettingDetails
GO
CREATE TABLE Cs2Cn_Prk_TempTaxSettingDetails(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](100) NULL,
	[GroupName] [nvarchar](100) NULL,
	[TaxGroupCode] [nvarchar](100) NULL,
	[TaxGroupName] [nvarchar](100) NULL,
	[UploadFlag] [nvarchar](10) NULL,  
	[SyncId] [numeric](38, 0) NULL,
	[ServerDate] [datetime] NULL,
) ON [PRIMARY]
GO
IF EXISTS (SELECT Name FROM Sysobjects WHERE XTYPE = 'P' AND name = 'Proc_Cs2Cn_TempTaxSettingDetails')
DROP PROCEDURE Proc_Cs2Cn_TempTaxSettingDetails
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_TempTaxSettingDetails 0,'2014-05-27'
SELECT * FROM Cs2Cn_Prk_TempTaxSettingDetails (NOLOCK)
SELECT * FROM DayEndProcess WHERE ProcId = 17
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cs2Cn_TempTaxSettingDetails
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/********************************************************************************
* PROCEDURE		: Proc_Cs2Cn_TempTaxSettingDetails
* PURPOSE		: To Extract Tax Settings from CoreStocky to Upload to Console
* CREATED BY	: SATHISHKUMAR VEERAMANI
* CREATED DATE	: 27/05/2014
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------
* {date} {developer}  {brief modification description}
	
**********************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @DistCode	As nVarchar(50)
	SET @Po_ErrNo=0
	SELECT @DistCode = DistributorCode FROM Distributor WITH(NOLOCK)
	DELETE FROM Cs2Cn_Prk_TempTaxSettingDetails WHERE UploadFlag = 'Y'
	
	IF NOT EXISTS (SELECT ProcDesc FROM DayEndProcess (NOLOCK) WHERE ProcDesc = 'Tax Setting' AND ProcId = 17)
	BEGIN
	    INSERT INTO Cs2Cn_Prk_TempTaxSettingDetails (DistCode,GroupName,TaxGroupCode,TaxGroupName,UploadFlag,SyncId)
	    SELECT DISTINCT @DistCode,(CASE TaxGroup WHEN 1 THEN 'Retailer' WHEN 2 THEN 'Product' WHEN 3 THEN 'Supplier' ELSE 'IDT Management' END) AS GroupName,
	    (CASE TaxGroup WHEN 2 THEN PrdGroup ELSE RtrGroup END) AS TaxGroupCode,TaxGroupName,'N' AS UploadFlag,0 AS SyncId  
	    FROM TaxGroupSetting (NOLOCK)
	    
	    UPDATE Cs2Cn_Prk_TempTaxSettingDetails SET ServerDate=@ServerDate
	    
	    IF EXISTS (SELECT GroupName FROM Cs2Cn_Prk_TempTaxSettingDetails (NOLOCK))
	    BEGIN
	        INSERT INTO DayEndProcess (ProcDate,ProcId,NextUpDate,ProcDesc)
	        SELECT CONVERT(NVARCHAR(10),GETDATE(),121),17,CONVERT(NVARCHAR(10),GETDATE(),121),'Tax Setting' 
	    END
	END
END
GO
IF EXISTS (SELECT Name FROM sysobjects WHERE Xtype = 'P' AND Name = 'Proc_RptBillTemplateFinal')
DROP PROCEDURE Proc_RptBillTemplateFinal
GO
--exec PROC_RptBillTemplateFinal 16,1,0,'Parle',0,0,1,'RptBt_View_Final1_BillTemplate'
CREATE PROCEDURE Proc_RptBillTemplateFinal
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
	--print @Pi_BTTblName
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
		if len(@FieldTypeList) > 3060
		begin
			Set @FieldTypeList2 = @FieldTypeList
			Set @FieldTypeList = ''
		end
		--->Added By Nanda on 12/03/2010
		IF LEN(@FieldList)>3060
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
--	Select @Sub_Val = TaxDt  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
--	If @Sub_Val = 1
--	Begin
        DELETE FROM RptBillTemplate_Tax WHERE UsrId = @Pi_UsrId    
		Insert into RptBillTemplate_Tax(SalId,SalInvNo,PrdSlNo,TaxId,TaxCode,TaxName,TaxPerc,TaxableAmount,TaxAmount,UsrId)
		SELECT SI.SalId,S.SalInvNo,0,SI.TaxId,TaxCode,TaxName,TaxPerc,SUM(TaxableAmount),SUM(TaxAmount),@Pi_UsrId
		FROM SalesInvoiceProductTax SI , TaxConfiguration T,SalesInvoice S,RptBillToPrint B
		WHERE SI.TaxId = T.TaxId and SI.SalId = S.SalId and S.SalInvNo = B.[Bill Number] and B.UsrId = @Pi_UsrId
		GROUP BY SI.SalId,S.SalInvNo,SI.TaxId,TaxCode,TaxName,TaxPerc HAVING SUM(TaxAmount) > 0 --Muthuvel
--	End
	------------------------------ Other
	--Select @Sub_Val = OtherCharges FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	--If @Sub_Val = 1
	--Begin
	    Delete From RptBillTemplate_Other Where UsrId = @Pi_UsrId
		Insert into RptBillTemplate_Other(SalId,SalInvNo,AccDescId,Description,Effect,Amount,UsrId)
		SELECT SI.SalId,S.SalInvNo,
		SI.AccDescId,P.Description,Case P.Effect When 0 Then 'Add' else 'Reduce' End Effect,
		Adjamt Amount,@Pi_UsrId
		FROM SalInvOtherAdj SI,PurSalAccConfig P,SalesInvoice S,RptBillToPrint B
		WHERE P.TransactionId = 2
		and SI.AccDescId = P.AccDescId
		and SI.SalId = S.SalId
		and S.SalInvNo = B.[Bill Number]
	--End
	---------------------------------------Replacement
	--Select @Sub_Val = Replacement FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	--If @Sub_Val = 1
	--Begin
		Delete From RptBillTemplate_Replacement Where UsrId = @Pi_UsrId
		Insert into RptBillTemplate_Replacement(SalId,SalInvNo,RepRefNo,PrdId,PrdName,PrdBatId,PrdBatCode,Qty,Rate,Tax,Amount,UsrId)
		SELECT H.SalId,SI.SalInvNo,H.RepRefNo,D.PrdId,P.PrdName,D.PrdBatId,PB.PrdBatCode,RepQty,SelRte,Tax,RepAmount,@Pi_UsrId
		FROM ReplacementHd H, ReplacementOut D, Product P, ProductBatch PB,SalesInvoice SI,RptBillToPrint B
		WHERE H.SalId <> 0
		and H.RepRefNo = D.RepRefNo
		and D.PrdId = P.PrdId
		and D.PrdBatId = PB.PrdBatId
		and H.SalId = SI.SalId
		and SI.SalInvNo = B.[Bill Number]
	--End
	----------------------------------Credit Debit Adjus
	--Select @Sub_Val = CrDbAdj  FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
	--If @Sub_Val = 1
	--Begin
	    Delete From RptBillTemplate_CrDbAdjustment Where UsrId = @Pi_UsrId
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
	--End
	---------------------------------------Market Return
--	Select @Sub_Val = MarketRet FROM BillTemplateHD WHERE TempName=substring(@Pi_BTTblName,18,len(@Pi_BTTblName))
--	If @Sub_Val = 1
--	Begin
		Delete from RptBillTemplate_MarketReturn where UsrId = @Pi_UsrId
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
--	End
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
	--INSERT INTO RptBillTemplate_PrdUOMDetails(SalId,SalInvNo,TotPrdVolume,TotPrdKG,TotPrdLtrs,TotPrdUnits,
	--TotPrdDrums,TotPrdCartons,TotPrdBuckets,TotPrdPieces,TotPrdBags,UsrId)	
	--SELECT SalId,SalInvNo,SUM(TotPrdVolume) AS TotPrdVolume,SUM(TotPrdKG) AS TotPrdKG,SUM(TotPrdLtrs) AS TotPrdLtrs,SUM(TotPrdUnits) AS TotPrdUnits,
	--SUM(TotPrdDrums) AS TotPrdDrums,SUM(TotPrdCartons) AS TotPrdCartons,SUM(TotPrdBuckets) AS TotPrdBuckets,SUM(TotPrdPieces) AS TotPrdPieces,SUM(TotPrdBags) AS TotPrdBags,@Pi_UsrId
	--FROM
	--(
	--	SELECT DISTINCT SI.SalId,SI.SalInvNo,SIP.PrdId,SIP.BaseQty*dbo.Fn_ReturnProductVolumeInLtrs(SIP.PrdId) AS TotPrdVolume,
	--	SIP.BaseQty*P.PrdUpSKU * (CASE P.PrdUnitId WHEN 2 THEN .001 WHEN 3 THEN 1 ELSE 0 END) AS TotPrdKG,
	--	SIP.BaseQty * P.PrdWgt * (CASE P.PrdUnitId WHEN 4 THEN .001 WHEN 5 THEN 1 ELSE 0 END) AS TotPrdLtrs,
	--	SIP.BaseQty*(CASE P.PrdUnitId WHEN 1 THEN 0 ELSE 0 END) AS TotPrdUnits,
	--	(CASE ISNULL(UMP1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMP2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPP2.UOM2Qty,0) END) AS TotPrdPieces,
	--	(CASE ISNULL(UMBU1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMBU2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBU2.UOM2Qty,0) END) AS TotPrdBuckets,
	--	(CASE ISNULL(UMBA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMBA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPBA2.UOM2Qty,0) END) AS TotPrdBags,
	--	(CASE ISNULL(UMDR1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMDR2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPDR2.UOM2Qty,0) END) AS TotPrdDrums,
	--	(CASE ISNULL(UMCA1.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA1.UOM1Qty,0) END)+
	--	(CASE ISNULL(UMCA2.UOMId,0) WHEN 0 THEN 0 ELSE ISNULL(SIPCA2.UOM2Qty,0) END)+ 
	--	CEILING((CASE ISNULL(UMCN1.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN1.UOM1Qty,0) AS NUMERIC(38,6))/CAST(UGC1.ConvFact AS NUMERIC(38,6)) END))+
	--	CEILING((CASE ISNULL(UMCN2.UOMId,0) WHEN 0 THEN 0 ELSE CAST(ISNULL(SIPCN2.UOM2Qty,0) AS NUMERIC(38,6))/CAST(UGC2.ConvFact AS NUMERIC(38,6)) END)) AS TotPrdCartons
	--	FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
	--	INNER JOIN RptBillToPrint Rpt ON SI.SalInvNo = Rpt.[Bill Number] AND Rpt.UsrId=@Pi_UsrId
	--	INNER JOIN Product P ON SIP.PrdID=P.PrdID
	--	INNER JOIN ProductBatch PB ON SIP.PrdBatID=PB.PrdBatID AND P.PrdID=PB.PrdId
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPP1 ON SI.SalId=SIPP1.SalId AND SIP.PrdID=SIPP1.PrdID AND SIP.PrdBatID=SIPP1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPP2 ON SI.SalId=SIPP2.SalId AND SIP.PrdID=SIPP2.PrdID AND SIP.PrdBatID=SIPP2.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPBU1 ON SI.SalId=SIPBU1.SalId AND SIP.PrdID=SIPBU1.PrdID AND SIP.PrdBatID=SIPBU1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPBU2 ON SI.SalId=SIPBU2.SalId AND SIP.PrdID=SIPBU2.PrdID AND SIP.PrdBatID=SIPBU2.PrdBatID		
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPBA1 ON SI.SalId=SIPBA1.SalId AND SIP.PrdID=SIPBA1.PrdID AND SIP.PrdBatID=SIPBA1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPBA2 ON SI.SalId=SIPBA2.SalId AND SIP.PrdID=SIPBA2.PrdID AND SIP.PrdBatID=SIPBA2.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPDR1 ON SI.SalId=SIPDR1.SalId AND SIP.PrdID=SIPDR1.PrdID AND SIP.PrdBatID=SIPDR1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPDR2 ON SI.SalId=SIPDR2.SalId AND SIP.PrdID=SIPDR2.PrdID AND SIP.PrdBatID=SIPDR2.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPCA1 ON SI.SalId=SIPCA1.SalId AND SIP.PrdID=SIPCA1.PrdID AND SIP.PrdBatID=SIPCA1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPCA2 ON SI.SalId=SIPCA2.SalId AND SIP.PrdID=SIPCA2.PrdID AND SIP.PrdBatID=SIPCA2.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPCN1 ON SI.SalId=SIPCN1.SalId AND SIP.PrdID=SIPCN1.PrdID AND SIP.PrdBatID=SIPCN1.PrdBatID
	--	LEFT OUTER JOIN SalesInvoiceProduct SIPCN2 ON SI.SalId=SIPCN2.SalId AND SIP.PrdID=SIPCN2.PrdID AND SIP.PrdBatID=SIPCN2.PrdBatID
	--	LEFT OUTER JOIN UOMMaster UMP1 ON UMP1.UOMId=SIPP1.UOM1Id AND UMP1.UOMDescription='PIECES'
	--	LEFT OUTER JOIN UOMMaster UMP2 ON UMP1.UOMId=SIPP2.UOM2Id AND UMP2.UOMDescription='PIECES'
	--	LEFT OUTER JOIN UOMMaster UMBU1 ON UMBU1.UOMId=SIPBU1.UOM1Id AND UMBU1.UOMDescription='BUCKETS' 
	--	LEFT OUTER JOIN UOMMaster UMBU2 ON UMBU1.UOMId=SIPBU2.UOM2Id AND UMBU2.UOMDescription='BUCKETS'
	--	LEFT OUTER JOIN UOMMaster UMBA1 ON UMBA1.UOMId=SIPBA1.UOM1Id AND UMBA1.UOMDescription='BAGS' 
	--	LEFT OUTER JOIN UOMMaster UMBA2 ON UMBA1.UOMId=SIPBA2.UOM2Id AND UMBA2.UOMDescription='BAGS'
	--	LEFT OUTER JOIN UOMMaster UMDR1 ON UMDR1.UOMId=SIPDR1.UOM1Id AND UMDR1.UOMDescription='DRUMS' 
	--	LEFT OUTER JOIN UOMMaster UMDR2 ON UMDR1.UOMId=SIPDR2.UOM2Id AND UMDR2.UOMDescription='DRUMS'
	--	LEFT OUTER JOIN UOMMaster UMCA1 ON UMCA1.UOMId=SIPCA1.UOM1Id AND UMCA1.UOMDescription='CARTONS' 
	--	LEFT OUTER JOIN UOMMaster UMCA2 ON UMCA1.UOMId=SIPCA2.UOM2Id AND UMCA2.UOMDescription='CARTONS'
	--	LEFT OUTER JOIN UOMMaster UMCN1 ON UMCN1.UOMId=SIPCN1.UOM1Id AND UMCN1.UOMDescription='CANS' 
	--	LEFT OUTER JOIN UOMMaster UMCN2 ON UMCN1.UOMId=SIPCN2.UOM2Id AND UMCN2.UOMDescription='CANS'
	--	LEFT OUTER JOIN (
	--	SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG
	--	WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN ( 
	--	SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )
	--	GROUP BY P.PrdID) UGC1 ON SIPCN1.PrdId=UGC1.PrdID
	--	LEFT OUTER JOIN (
	--	SELECT P.PrdId,MAX(UG.ConversionFactor) AS ConvFact FROM Product P,UOMGroup UG
	--	WHERE P.UOMGroupId=UG.UOMGroupId AND UG.UOMGroupId IN ( 
	--	SELECT UOMGroupId FROM UOMGroup WHERE UOMId IN (SELECT UOMId FROM UOMMAster WHERE UOMDescription LIKE 'CANS') )
	--	GROUP BY P.PrdID) UGC2 ON SIPCN2.PrdId=UGC2.PrdID
	--) A
	--GROUP BY SalId,SalInvNo
	--->Till Here
	--Added By Sathishkumar Veeramani 2012/12/13
	IF NOT EXISTS (SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')AND name = 'Payment Mode')
	BEGIN
	     ALTER TABLE RptBillTemplateFinal ADD [Payment Mode] NVARCHAR(20)
	END
	IF Exists(SELECT * FROM Syscolumns WHERE ID IN (SELECT ID FROM Sysobjects WHERE XTYPE = 'U' AND name = 'RptBillTemplateFinal')AND name = 'Payment Mode')    
	BEGIN    
		SET @SSQL1='UPDATE A SET A.[Payment Mode] = Z.[Payment Mode] FROM RptBillTemplateFinal A INNER JOIN 
					(SELECT SalId,(CASE RtrPayMode WHEN 1 THEN ''Cash'' ELSE ''Cheque'' END) AS [Payment Mode] FROM SalesInvoice WITH (NOLOCK)) Z ON A.Salid = Z.SalId 
					AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
		EXEC (@SSQL1)    
	END
	--Till Here
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
			[UsrId],[Visibility],[Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd]
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
		[UsrId],[Visibility],[Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd]
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
		[UsrId],[Visibility],[Distributor Product Code],[Allotment No],[Bx Selling Rate],[AmtInWrd]
		FROM RptBillTemplateFinal_Group,Product P
		WHERE P.PrdCCode=RptBillTemplateFinal_Group.[Product Code] AND P.PrdType=5
	END	
	--->Till Here
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDisc')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD InvDisc NUMERIC (18,2) DEFAULT 0 WITH VALUES 
		END
		IF NOT EXISTS (SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDiscPer')
		BEGIN
			ALTER TABLE RptBillTemplateFinal ADD InvDiscPer NUMERIC (18,2) DEFAULT 0 WITH VALUES 
		END
	
		IF Exists(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDisc')    
		BEGIN    
			SET @SSQL1='UPDATE A SET A.InvDisc=B.SalInvLvlDisc FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) 
						ON A.[Sales Invoice Number]=B.SalInvNo AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
			EXEC (@SSQL1)    
		END 
		IF EXISTS(SELECT A.NAME FROM SysObjects A INNER JOIN SysColumns B ON A.id=B.id AND A.name='RptBillTemplateFinal' AND B.name='InvDiscPer')    
		BEGIN  
			SET @SSQL1='UPDATE A SET A.InvDiscPer=B.SalInvLvlDiscPer FROM RptBillTemplateFinal A (NOLOCK) INNER JOIN SalesInvoice B (NOLOCK) 
						ON A.[Sales Invoice Number]=B.SalInvNo AND A.UsrId='+ CAST(@Pi_UsrId AS VARCHAR(10))       
			EXEC (@SSQL1)    
		END 
	
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
IF EXISTS (SELECT Name FROM sysobjects WHERE Xtype = 'P' AND Name = 'Proc_RptDayEndCollection')
DROP PROCEDURE Proc_RptDayEndCollection
GO
--exec Proc_RptDayEndCollection 248,1,0,'',0,0,1
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
		BalanceAmount,CollectedAmount,PayAmount,TotalBillAmount,
		CashBill,Chequebill,DDBill,RTGSBill,[TotalBills] into RptDayEndCollection_Excel FROM #RptCollectionDetail 
		ORDER BY vehno,InvRcpDate		
	END
RETURN
END
GO
IF EXISTS (SELECT Name FROM SYSOBJECTS WHERE name='Proc_RptINPUTVATSummary' AND XTYPE='P')
DROP  PROCEDURE Proc_RptINPUTVATSummary
GO
--Select Flag from RptExcelFlag WITH (NOLOCK) WHERE RptID=28
--EXEC Proc_RptINPUTVATSummary 28,1,0,'CoreStocky',0,0,1
CREATE PROCEDURE Proc_RptINPUTVATSummary
(
	@Pi_RptId		INT,
	@Pi_UsrId		INT,
	@Pi_SnapId		INT,
	@Pi_DbName		nvarchar(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
	--@Po_Errno		INT OUTPUT
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
	
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate		AS	DATETIME
	DECLARE @CmpId	 	AS	INT
	DECLARE @SpmId	 	AS	INT
	DECLARE @TransNo	AS	NVARCHAR(100)
	DECLARE @EXLFlag	AS 	INT
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @SpmId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId))
	SET @TransNo =(SELECT TOP 1 SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,201,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)
	Create TABLE #RptINPUTVATSummary
	(
		InvId 			BIGINT,
		RefNo	  		NVARCHAR(100),		
		InvDate 		DATETIME,		
		PrdId 			INT,
		PrdDCode 		NVARCHAR(100),
		PrdName			NVARCHAR(200),
		IOTaxType 		NVARCHAR(100),
		TaxPerc 		NVARCHAR(50),
		TaxableAmount 		NUMERIC(38,6),		
		TaxFlag 		INT,
		TaxPercent 		NUMERIC(38,6),
		CmpInvNo 		NVARCHAR(100)
	)
	
	SET @TblName = 'RptINPUTVATSummary'
	SET @TblStruct = 'InvId 			BIGINT,
			RefNo	  		NVARCHAR(100),		
			InvDate 		DATETIME,		
			PrdId 			INT,
			PrdDCode 		NVARCHAR(20),
			PrdName			NVARCHAR(100),
			IOTaxType 		NVARCHAR(100),
			TaxPerc 		NVARCHAR(50),
			TaxableAmount 		NUMERIC(38,6),		
			TaxFlag 		INT,
			TaxPercent 		NUMERIC(38,6),
			CmpInvNo 		NVARCHAR(100)'
			
	SET @TblFields = 'InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,TaxPerc,TaxableAmount,TaxFlag
	,TaxPercent,CmpInvNo'
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
		Exec Proc_IOTaxSummary  @Pi_UsrId		
		
		
		INSERT INTO #RptINPUTVATSummary (InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,TaxPerc,
		TaxableAmount,TaxFlag,TaxPercent,CmpInvNo)
	
		Select InvId,RefNo,InvDate,T.PrdId,PrdDCode,PrdName,IOTaxType,TaxPerc,
		SUM(case IOTaxType when 'Purchase' then TaxableAmount when 'PurchaseReturn' then TaxableAmount
		end) as TaxableAmount ,TaxFlag,TaxPerCent,CmpInvNo From TmpRptIOTaxSummary T,Product P,Company C,
		Supplier S where T.PrdId = P.PrdId and S.SpmId = T.SpmId and C.CmpId = T.CmpId and
		IOTaxType in ('Purchase','PurchaseReturn') and t.spmid > 0
		and ( T.CmpId = (CASE @CmpId WHEN 0 THEN T.CmpId ELSE 0 END) OR
		T.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		AND
		( T.SpmId = (CASE @SpmId WHEN 0 THEN T.SpmId ELSE 0 END) OR
		T.SpmId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))
	
		AND  (RefNo = (CASE @TransNo WHEN '0' THEN RefNo ELSE '' END) OR
		RefNo in (SELECT SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,201,@Pi_UsrId)))
		AND
		( INVDATE between @FromDate and @ToDate and Userid = @Pi_UsrId)
		/*Code Modified by Muthuvelsamy R for the PMS id DCRSTPAR0514 begins here*/
		GROUP BY InvId,RefNo,InvDate,T.PrdId,PrdDCode,PrdName,IOTaxType,TaxPerc,TaxFlag,TaxPerCent,CmpInvNo 
		/*Code Modified by Muthuvelsamy R for the PMS id DCRSTPAR0514 ends here*/
		
		INSERT INTO #RptINPUTVATSummary (InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,TaxPerc,
								 TaxableAmount,TaxFlag,TaxPercent,CmpInvNo)	
		SELECT 
			InvId,RefNo,InvDate,T.PrdId,PrdDCode,PrdName,IOTaxType,TaxPerc,
			SUM(case IOTaxType 	when 'IDT IN' then TaxableAmount 
							when 'IDT OUT' then TaxableAmount End) as TaxableAmount ,
			TaxFlag,TaxPerCent,CmpInvNo 
		From 
			TmpRptIOTaxSummary T,Product P,Company C,
			IDTMaster S 
		where T.PrdId = P.PrdId and S.SpmId = T.SpmId and C.CmpId = T.CmpId and
			  IOTaxType in ('IDT IN','IDT OUT') and t.spmid > 0
		and ( T.CmpId = (CASE @CmpId WHEN 0 THEN T.CmpId ELSE 0 END) OR
		T.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
		AND
		( T.SpmId = (CASE @SpmId WHEN 0 THEN T.SpmId ELSE 0 END) OR
		T.SpmId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,9,@Pi_UsrId)))
	
		AND  (RefNo = (CASE @TransNo WHEN '0' THEN RefNo ELSE '' END) OR
				RefNo in (SELECT SCountid FROM Fn_ReturnRptFilterString(@Pi_RptId,201,@Pi_UsrId)))
		AND
		( INVDATE between @FromDate and @ToDate and Userid = @Pi_UsrId) 
		/*Code Modified by Muthuvelsamy R for the PMS id DCRSTPAR0514 begins here*/
		GROUP BY InvId,RefNo,InvDate,T.PrdId,PrdDCode,PrdName,IOTaxType,TaxPerc,TaxFlag,TaxPerCent,CmpInvNo
		/*Code Modified by Muthuvelsamy R for the PMS id DCRSTPAR0514 ends here*/
	
		IF LEN(@PurDBName) > 0
		BEGIN
			SET @SSQL = 'INSERT INTO #RptINPUTVATSummary ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ ' WHERE (T.CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN T.CmpId ELSE 0 END) OR ' +
				' T.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) AND '
				+ ' ( INVDATE Between ''' + @FromDate + ''' AND ''' + @ToDate + '''' + ' and UsrId = ' + CAST(@Pi_UsrId AS nVarChar(10)) + ') AND '
				+ ' WHERE (T.SpmId = (CASE ' + CAST(@SpmId AS nVarchar(10)) + ' WHEN 0 THEN T.SpmId ELSE 0 END) OR ' +
				' T.SpmId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId AS nVarchar(10)) + ',9,' + CAST(@Pi_UsrId AS nVarChar(10)) + '))) '
	
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
				' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptINPUTVATSummary'
			
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
			SET @SSQL = 'INSERT INTO #RptINPUTVATSummary' +
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
			--SET @Po_Errno = 1
			PRINT 'DataBase or Table not Found'
			RETURN
		END
	END
	DELETE FROM RptDataCount WHERE RptId= @Pi_RptId AND UserId=@Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*),0,@Pi_UsrId FROM #RptINPUTVATSummary
	
	INSERT INTO #RptINPUTVATSummary
	SELECT InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,
	'Total Taxable Amount',SUM(TaxableAmount),0,1000.000000,CmpInvNo
	FROM --#RptINPUTVATSummary
	(SELECT DISTINCT InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,TaxableAmount,CmpInvNo,TaxFlag FROM #RptINPUTVATSummary) A
	WHERE TaxFlag=0
	GROUP BY InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,CmpInvNo
	
	INSERT INTO #RptINPUTVATSummary
	SELECT InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,
	'Total Tax Amount',SUM(TaxableAmount),1,1000.000000,CmpInvNo
	FROM --#RptINPUTVATSummary
	(SELECT DISTINCT InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,TaxableAmount,CmpInvNo,TaxFlag FROM #RptINPUTVATSummary) A
	WHERE TaxFlag=1
	GROUP BY InvId,RefNo,InvDate,PrdId,PrdDCode,PrdName,IOTaxType,CmpInvNo
	SELECT * FROM #RptINPUTVATSummary --WHERE PrdId = 1020 --test
	SELECT @EXLFlag=Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId
	
	IF @EXLFlag=1
	BEGIN
		--SELECT DISTINCT(TaxPerc),TaxPercent,TaxFlag FROM #RptINPUTVATSummary ORDER BY TaxPercent ,TaxFlag
		--EXEC Proc_RptINPUTVATSummary 28,1,0,'CoreStocky',0,0,1
		/******************************************************************************************************/
		--Create Table in Dynamic Cols
		--Cursors
		DECLARE  @Values NUMERIC(38,6)
		DECLARE  @Desc VARCHAR(80)
		DECLARE  @PrdId BIGINT
		DECLARE  @InvId BIGINT
		DECLARE  @IOTaxType NVARCHAR(100)	
		DECLARE  @TaxFlag INT
		DECLARE  @TaxPercent INT
		DECLARE  @Column VARCHAR(80)
		DECLARE  @C_SSQL VARCHAR(4000)
		DECLARE  @iCnt INT
		DECLARE  @Name NVARCHAR(100)
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptINPUTVATSummary_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE [RptINPUTVATSummary_Excel]
		DELETE FROM RptExcelHeaders Where RptId=28 AND SlNo>9
		CREATE TABLE RptINPUTVATSummary_Excel (InvId BIGINT,RefNo NVARCHAR(100),InvDate DATETIME,CmpInvNo NVARCHAR(100),PrdId BIGINT,
						PrdCode NVARCHAR(100),PrdName NVARCHAR(500),IOTaxType NVARCHAR(100),UsrId INT)
		SET @iCnt=10
		DECLARE Crosstab_Cur CURSOR FOR
			SELECT DISTINCT(TaxPerc),TaxPercent,TaxFlag FROM #RptINPUTVATSummary ORDER BY TaxPercent ,TaxFlag
		OPEN Crosstab_Cur
			   FETCH NEXT FROM Crosstab_Cur INTO @Column,@TaxPercent,@TaxFlag
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='ALTER TABLE RptINPUTVATSummary_Excel ADD ['+ @Column +'] NUMERIC(38,6)'
					EXEC (@C_SSQL)
					
					SET @C_SSQL='INSERT INTO RptExcelHeaders (RptId,SlNo,FieldName,DisplayName,DisplayFlag,LngId)'
					SET @C_SSQL=@C_SSQL +' VALUES(' + CAST(@Pi_RptId AS VARCHAR(100))+ ',' + CAST(@iCnt AS VARCHAR(100))
					SET @C_SSQL=@C_SSQL + ',''['+ CAST(@Column AS VARCHAR(100))+']'','''+ CAST(@Column AS VARCHAR(100))+ ''',1,1)'
					EXEC (@C_SSQL)
					SET @iCnt=@iCnt+1
					FETCH NEXT FROM Crosstab_Cur INTO @Column,@TaxPercent,@TaxFlag
				END
		CLOSE Crosstab_Cur
		DEALLOCATE Crosstab_Cur
		--Insert table values
		DELETE FROM RptINPUTVATSummary_Excel
		--Select Column_Name sp_Columns RptINPUTVATSummary_Excel
		INSERT INTO RptINPUTVATSummary_Excel (InvId ,RefNo ,InvDate ,CmpInvNo,PrdId ,PrdCode,PrdName,IOTaxType,UsrId)
		SELECT DISTINCT InvId ,RefNo ,InvDate ,CmpInvNo,PrdId,PrdDCode,PrdName,IOTaxType,@Pi_UsrId
				FROM #RptINPUTVATSummary
		DECLARE Values_Cur CURSOR FOR
		/*Code Modified by Muthuvelsamy R for the PMS id DCRSTPAR0514 begins here*/
		--SELECT DISTINCT  InvId,PrdId,IOTaxType,TaxPerc,TaxableAmount FROM #RptINPUTVATSummary
		SELECT DISTINCT  InvId,PrdId,IOTaxType,TaxPerc,SUM(TaxableAmount) TaxableAmount FROM #RptINPUTVATSummary
		GROUP BY InvId,PrdId,IOTaxType,TaxPerc
		/*Code Modified by Muthuvelsamy R for the PMS id DCRSTPAR0514 begins here*/				
		OPEN Values_Cur
			   FETCH NEXT FROM Values_Cur INTO @InvId,@PrdId,@IOTaxType,@Desc,@Values
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptINPUTVATSummary_Excel SET ['+ @Desc +']= '+ CAST(ISNULL(@Values,0) AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE InvId='+ CAST(@InvId AS VARCHAR(1000)) + ' AND PrdId=' + CAST(@PrdId AS VARCHAR(1000)) + '
					AND IOTaxType=''' + CAST(@IOTaxType AS VARCHAR(1000))+''' AND UsrId=' + CAST(@Pi_UsrId AS VARCHAR(10))+ ''
					EXEC (@C_SSQL)
					--PRINT @C_SSQL
					FETCH NEXT FROM Values_Cur INTO @InvId,@PrdId,@IOTaxType,@Desc,@Values
				END
		CLOSE Values_Cur
		DEALLOCATE Values_Cur
		-- To Update the Null Value as 0
		DECLARE NullCursor_Cur CURSOR FOR
		SELECT Name FROM dbo.sysColumns where id = object_id(N'[RptINPUTVATSummary_Excel]')
		OPEN NullCursor_Cur
			   FETCH NEXT FROM NullCursor_Cur INTO @Name
			   WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @C_SSQL='UPDATE RptINPUTVATSummary_Excel SET ['+ @Name +']= '+ CAST(0 AS VARCHAR(1000))
					SET @C_SSQL=@C_SSQL + ' WHERE '+'['+ @Name +']'+'IS NULL'+ ''
					EXEC (@C_SSQL)
					PRINT @C_SSQL
					FETCH NEXT FROM NullCursor_Cur INTO @Name
				END
		CLOSE NullCursor_Cur
		DEALLOCATE NullCursor_Cur
	END
RETURN
END
GO
IF EXISTS (SELECT Name FROM SYSOBJECTS WHERE name='Proc_GetStockLedgerSummaryDatewiseParle' AND XTYPE='P')
DROP  PROCEDURE Proc_GetStockLedgerSummaryDatewiseParle
GO
--Exec Proc_GetStockLedgerSummaryDatewiseParle '2013-04-26','2013-04-26',1,0,0,0
--Select * From TempStockLedSummary where userid=1 and prdid in (3,20) and lcnid=8 and
--Select * From TempStockLedSummaryTotal
--SELECT * FROM StockLedger
CREATE PROCEDURE Proc_GetStockLedgerSummaryDatewiseParle
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
* {date} {developer}  {brief modification description}
------------------------------------------------
* 11/06/2014	Muthuvelsamy R	PMS Id DCRSTPAR0511
*********************************/
SET NOCOUNT ON
BEGIN
DECLARE @StockType AS NUMERIC(18,0)
IF EXISTS (SELECT DISTINCT SelValue FROM ReportFilterDt WHERE RptId = 245 AND SelId = 291 AND SelValue <> 0 AND UsrId = @Pi_UserId)
BEGIN 	
	SELECT @StockType = SystemStockType FROM ReportFilterDt A WITH (NOLOCK),StockType B WITH (NOLOCK) 
	WHERE A.SelValue = B.StockTypeId AND RptId = 245 AND SelId = 291 AND UsrId = @Pi_UserId
END
ELSE
BEGIN
   SET @StockType = 0
END
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
	SELECT LcnId,PrdBatId,MAX(TransDate) FROM StockLedger SL(nolock)  
	/*Code Modified by Muthuvelsamy R for the PMS Id DCRSTPAR0511 begins here*/
	--WHERE TransDate <@Pi_FromDate AND CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) NOT IN
	--(SELECT CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) 
	--FROM StockLedger WHERE TransDAte BETWEEN @Pi_FromDate AND @Pi_ToDate)
	WHERE TransDate <@Pi_FromDate AND NOT EXISTS
	(SELECT CAST(LcnId AS NVARCHAR(10))+'~'+CAST(PrdId AS NVARCHAR(10))+'~'+CAST(LcnId AS NVARCHAR(10)) 
	FROM StockLedger X(NOLOCK) WHERE TransDAte BETWEEN @Pi_FromDate AND @Pi_ToDate 
	AND X.PrdId = SL.PrdId AND X.PrdBatId = SL.PrdBatId AND X.LcnId = SL.LcnId)
	/*Code Modified by Muthuvelsamy R for the PMS Id DCRSTPAR0511 ends here*/
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
		(CASE @StockType WHEN 1 THEN Sl.SalOpenStock WHEN 2 THEN Sl.UnSalOpenStock WHEN 3 THEN Sl.OfferOpenStock
		ELSE (Sl.SalOpenStock+Sl.UnSalOpenStock+Sl.OfferOpenStock) END) AS Opening,
		(CASE @StockType WHEN 1 THEN Sl.SalPurchase WHEN 2 THEN Sl.UnsalPurchase WHEN 3 THEN Sl.OfferPurchase
		ELSE (Sl.SalPurchase+Sl.UnsalPurchase+Sl.OfferPurchase) END) AS Purchase,
		(CASE @StockType WHEN 1 THEN Sl.SalSales WHEN 2 THEN Sl.UnSalSales WHEN 3 THEN Sl.OfferSales
		ELSE (Sl.SalSales+Sl.UnSalSales+Sl.OfferSales) END) AS Sales,
		(CASE @StockType WHEN 1 THEN (-Sl.SalPurReturn+Sl.SalStockIn-Sl.SalStockOut+Sl.SalSalesReturn+Sl.SalStkJurIn-Sl.SalStkJurOut+
		Sl.SalBatTfrIn-Sl.SalBatTfrOut+Sl.SalLcnTfrIn-Sl.SalLcnTfrOut-Sl.SalReplacement)
		WHEN 2 THEN	(-Sl.UnSalPurReturn+Sl.UnSalStockIn-Sl.UnSalStockOut+Sl.UnSalSalesReturn+Sl.UnSalStkJurIn-Sl.UnSalStkJurOut+
		Sl.UnSalBatTfrIn-Sl.UnSalBatTfrOut+Sl.UnSalLcnTfrIn-Sl.UnSalLcnTfrOut+Sl.DamageIn-Sl.DamageOut)	
		WHEN 3 THEN	(-Sl.OfferPurReturn+Sl.OfferStockIn-Sl.OfferStockOut+Sl.OfferSalesReturn+Sl.OfferStkJurIn-Sl.OfferStkJurOut+
		Sl.OfferBatTfrIn-Sl.OfferBatTfrOut+Sl.OfferLcnTfrIn-Sl.OfferLcnTfrOut-Sl.OfferReplacement)
		ELSE(-Sl.SalPurReturn-Sl.UnsalPurReturn-Sl.OfferPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.OfferStockIn-
		Sl.SalStockOut-Sl.UnSalStockOut-Sl.OfferStockOut+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.OfferSalesReturn+
		Sl.SalStkJurIn+Sl.UnSalStkJurIn+Sl.OfferStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut-Sl.OfferStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn+Sl.OfferBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut-Sl.OfferBatTfrOut+
		Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn+Sl.OfferLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-Sl.OfferLcnTfrOut-
		Sl.SalReplacement-Sl.OfferReplacement+Sl.DamageIn-Sl.DamageOut)END) AS Adjustments,
		(CASE @StockType WHEN 1 THEN Sl.SalClsStock WHEN 2 THEN Sl.UnSalClsStock WHEN 3 THEN Sl.OfferClsStock
		ELSE (Sl.SalClsStock+Sl.UnSalClsStock+Sl.OfferClsStock) END) AS Closing,
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
		(CASE @StockType WHEN 1 THEN Sl.SalOpenStock WHEN 2 THEN Sl.UnSalOpenStock WHEN 3 THEN 0
		ELSE (Sl.SalOpenStock+Sl.UnSalOpenStock) END) AS Opening,
		(CASE @StockType WHEN 1 THEN Sl.SalPurchase WHEN 2 THEN Sl.UnsalPurchase WHEN 3 THEN 0
		ELSE (Sl.SalPurchase+Sl.UnsalPurchase) END) AS Purchase,
		(CASE @StockType WHEN 1 THEN Sl.SalSales WHEN 2 THEN Sl.UnSalSales WHEN 3 THEN 0
		ELSE (Sl.SalSales+Sl.UnSalSales) END) AS Sales,
		(CASE @StockType WHEN 1 THEN (-Sl.SalPurReturn+Sl.SalStockIn-Sl.SalStockOut+Sl.SalSalesReturn+Sl.SalStkJurIn-Sl.SalStkJurOut+
		Sl.SalBatTfrIn-Sl.SalBatTfrOut+Sl.SalLcnTfrIn-Sl.SalLcnTfrOut-Sl.SalReplacement)
		WHEN 2 THEN	(-Sl.UnSalPurReturn+Sl.UnSalStockIn-Sl.UnSalStockOut+Sl.UnSalSalesReturn+Sl.UnSalStkJurIn-Sl.UnSalStkJurOut+
		Sl.UnSalBatTfrIn-Sl.UnSalBatTfrOut+Sl.UnSalLcnTfrIn-Sl.UnSalLcnTfrOut+Sl.DamageIn-Sl.DamageOut)	
		WHEN 3 THEN	0 ELSE(-Sl.SalPurReturn-Sl.UnsalPurReturn+Sl.SalStockIn+Sl.UnSalStockIn+Sl.SalStockOut-Sl.UnSalStockOut
		+Sl.SalSalesReturn+Sl.UnSalSalesReturn+Sl.SalStkJurIn+Sl.UnSalStkJurIn-Sl.SalStkJurOut-Sl.UnSalStkJurOut+
		Sl.SalBatTfrIn+Sl.UnSalBatTfrIn-Sl.SalBatTfrOut-Sl.UnSalBatTfrOut+Sl.SalLcnTfrIn+Sl.UnSalLcnTfrIn-Sl.SalLcnTfrOut-Sl.UnSalLcnTfrOut-
		Sl.SalReplacement+Sl.DamageIn-Sl.DamageOut)END) AS Adjustments,
		(CASE @StockType WHEN 1 THEN Sl.SalClsStock WHEN 2 THEN Sl.UnSalClsStock WHEN 3 THEN 0
		ELSE (Sl.SalClsStock+Sl.UnSalClsStock) END) AS Closing,
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
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN ISNULL(Sl.OfferClsStock,0)
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) END) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN ISNULL(Sl.OfferClsStock,0)
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)+ISNULL(Sl.OfferClsStock,0)) END) AS Closing,
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
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN 0
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) END) AS OfferOpenStock,
		0 AS Sales,0 AS Purchase,0 AS Adjustments,
		(CASE @StockType WHEN 1 THEN ISNULL(Sl.SalClsStock,0) WHEN 2 THEN ISNULL(Sl.UnSalClsStock,0) WHEN 3 THEN 0
		ELSE (ISNULL(Sl.SalClsStock,0)+ISNULL(Sl.UnSalClsStock,0)) END) AS Closing,
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
		
	
	INSERT INTO TempStockLedSummary(PrdId,PrdBatId,LcnId,Opening,Purchase,Sales,Adjustment,Closing,
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
	UPDATE TempStockLedSummary SET Purchase=TotPur,Sales=TotSal,
	Adjustment=TotAdj
	FROM #TemDetails T
	WHERE T.PrdId=TempStockLedSummary.PrdId AND T.PrdBatId=TempStockLedSummary.PrdBatId AND
	T.LcnId=TempStockLedSummary.LcnId
	UPDATE TempStockLedSummary SET Closing=Opening+Purchase-Sales+Adjustment
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Proc_RptClosingStockReport' AND XTYPE='P')
DROP  PROCEDURE Proc_RptClosingStockReport
GO
--EXEC Proc_RptClosingStockReport 153,1,0,'',0,0,1
CREATE PROCEDURE Proc_RptClosingStockReport
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
* VIEW	: Proc_RptClosingStockReport
* PURPOSE	: To get the Closing Stock Details
* CREATED BY	: Mahalakshmi.A
* CREATED DATE	: 17/09/2008
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}		{brief modification description}
* 08/11/2013	Jisha Mathew	Bug No : 30534
/*11/06/2014	Muthuvelsamy R	PMS Id DCRSTPAR0511*/
*************************************************************/
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
	
	--Filter Variables
	DECLARE @FromDate	AS	DATETIME
	DECLARE @ToDate	 	AS	DATETIME
	DECLARE @CmpId 		AS	INT
	DECLARE @LcnId 		AS	INT
	DECLARE @PrdCatId	AS	INT
	DECLARE @PrdId		AS	INT
	DECLARE @DispValue	AS	INT
	DECLARE @PrdStatus	AS	INT
	DECLARE @BatchStatus	AS	INT
	DECLARE @SupZeroStock   AS INT
	DECLARE @PrdUnit	AS INT
	----Till Here
	--Assgin Value for the Filter Variable
--	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	SET @CmpId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))
	SET @LcnId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))
	SET @DispValue = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,209,@Pi_UsrId))
	SET @PrdStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,210,@Pi_UsrId))
	SET @BatchStatus = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,211,@Pi_UsrId))
	SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)	
	EXEC Proc_ReturnRptProduct @Pi_RptId,@Pi_UsrId
	SET @PrdCatId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId))
	SET @PrdId = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId))
	SET @SupZeroStock = (SElect  TOP 1 iCountid FRom Fn_ReturnRptFilters(@Pi_RptId,44,@Pi_UsrId))
	
	/*Code Modified by Muthuvelsamy R for the PMS Id DCRSTPAR0511 begins here*/
	--SELECT @PrdUnit=PrdUnitId FROM ProductUnit WHERE UPPER(PrdUnitName) IN ('KILO GRAM','KILOGRAM','KILO GRAMS','KILOGRAMS')
	SELECT @PrdUnit=PrdUnitId FROM ProductUnit WHERE PrdUnitName IN('KILO GRAM','KILOGRAM','KILO GRAMS','KILOGRAMS')
	/*Code Modified by Muthuvelsamy R for the PMS Id DCRSTPAR0511 ends here*/
	---Till Here
	--PRINT @DispValue
	CREATE TABLE #RptClosingStock
	(
				PrdId		INT,
				PrdName		NVARCHAR(100),
				MRP		NUMERIC(38,6),
				Cases		NUMERIC(38,0),
				BoxStrip	NUMERIC(38,0),
				Piece		NUMERIC(38,0),
				StockValue	NUMERIC(38,6),
				KiloGrams   NUMERIC(38,6)				
	)
	SET @TblName = 'RptClosingStock'
	SET @TblStruct = ' PrdId		INT,
		PrdName		NVARCHAR(100),
		MRP		    NUMERIC(38,6),
		Cases		NUMERIC(38,0),
		BoxStrip	NUMERIC(38,0),
		Piece		NUMERIC(38,0),
		StockValue	NUMERIC(38,6),
		KiloGrams   NUMERIC(38,6)'
	SET @TblFields = 'PrdId,PrdName,MRP,Cases,BoxStrip,Piece,StockValue,KiloGrams'
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
	EXEC Proc_ClosingStock @Pi_RptID,@Pi_UsrId,@ToDate
	IF @Pi_GetFromSnap = 0		--To Generate For New Report Data
	BEGIN
		INSERT INTO #RptClosingStock (PrdId,PrdName,MRP,Cases,BoxStrip,Piece,StockValue,KiloGrams)
		SELECT DISTINCT T.PrdId,T.PrdName,MRP,ISNULL(SUM(Cases),0),ISNULL(SUM(BoxStrip),0),ISNULL(SUM(Pieces),0),
		--SUM((CASE @DispValue WHEN 1 THEN CloSelRte ELSE CloPurRte END)) As StockValue
		SUM((CASE @DispValue WHEN 1 THEN (BaseQty*SellingRate) ELSE (BaseQty*ListPrice) END)) As StockValue,0
		FROM TempClosingStock T
		WHERE 	(T.CmpId = (CASE @CmpId WHEN 0 THEN T.CmpId ELSE 0 END) OR
		T.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))				
		AND
		(T.LcnId = (CASE @LcnId WHEN 0 THEN T.LcnId ELSE 0 END) OR
			T.LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))
		AND
		(T.PrdStatus = (CASE @PrdStatus WHEN 0 THEN T.PrdStatus ELSE -1 END) OR
			T.PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,210,@Pi_UsrId)))
		AND
		(T.BatStatus = (CASE @BatchStatus WHEN 0 THEN T.BatStatus ELSE -1 END) OR
			T.BatStatus in (SELECT iCountid-1 FROM Fn_ReturnRptFilters(@Pi_RptId,211,@Pi_UsrId)))
		AND
		(T.PrdId = (CASE @PrdCatId WHEN 0 THEN T.PrdId Else 0 END) OR
			T.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,26,@Pi_UsrId)))
		AND
		(T.PrdId = (CASE @PrdId WHEN 0 THEN T.PrdId Else 0 END) OR
			T.PrdId in (SELECT iCountid from Fn_ReturnRptFilters(@Pi_RptId,5,@Pi_UsrId)))
		AND UsrId=@Pi_UsrId 
		GROUP BY T.PrdId,T.PrdName,MRP
		ORDER BY T.PrdId,T.PrdName,MRP
		UPDATE T SET KiloGrams=(PrdWgt*BaseQty) FROM #RptClosingStock T,Product P,ProductUnit PU,TempClosingStock TT
		WHERE P.PrdId=T.PrdId AND T.PrdId=TT.PrdId AND PU.PrdUnitId=TT.PrdUnitId AND TT.PrdUnitId=@PrdUnit
		
		IF LEN(@PurDBName) > 0
		BEGIN
			EXEC Proc_PurgedDB @PurDBName,@TblName,@Po_PurgeErrno = @ErrNo OUTPUT
			
			SET @SSQL = 'INSERT INTO #RptClosingStock ' +
				'(' + @TblFields + ')' +
				' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName
				+ 'WHERE (CmpId = (CASE ' + CAST(@CmpId AS nVarchar(10)) + ' WHEN 0 THEN CmpId ELSE 0 END) OR '
				+ 'CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',4,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND (LcnId = (CASE ' + CAST(@LcnId AS nVarchar(10)) + ' WHEN 0 THEN LcnId ELSE 0 END) OR '
				+ 'LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',22,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdId = (CASE ' + CAST(@PrdCatId AS nVarchar(10)) + ' WHEN 0 THEN PrdId ELSE 0 END) OR '
				+ 'PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',26,' + CAST(@Pi_UsrId AS nVarchar(10)) + '))) '
				+ 'AND(PrdId=(CASE @PrdId WHEN 0 THEN PrdId ELSE 0 END) OR'
				+ 'PrdId in (SELECT iCountid FROM Fn_ReturnRptFilters('+
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',5,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (PrdStatus = (CASE ' + CAST(@PrdStatus AS nVarchar(10)) + ' WHEN 0 THEN PrdStatus ELSE -1 END) OR '
				+ 'PrdStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',210,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				+ 'AND (BatStatus = (CASE ' + CAST(@BatchStatus AS nVarchar(10)) + ' WHEN 0 THEN BatStatus ELSE -1 END) OR '
				+ 'BatStatus in (SELECT iCountid FROM Fn_ReturnRptFilters(' +
				+ CAST(@Pi_RptId AS nVarchar(10)) + ',211,' + CAST(@Pi_UsrId AS nVarchar(10)) + ')))'
				--+ 'AND TransDate BETWEEN ''' + @FromDate + ''' AND ''' + @ToDate + ''''
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
					' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptClosingStock'
				
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
			SET @SSQL = 'INSERT INTO #RptClosingStock ' +
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
----SELECT *FROM #RptClosingStock		
	IF @SupZeroStock=1 
	BEGIN
		SELECT *FROM #RptClosingStock WHERE (ISNULL([Cases],0)+ISNULL([Piece],0)+ISNULL([BoxStrip],0))<>0
		--Check for Report Data
			Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock WHERE ([Cases]+[Piece]+[BoxStrip])<>0
		-- Till Here
	END
	ELSE
	BEGIN
		SELECT *FROM #RptClosingStock
		--Check for Report Data
			Delete From RptDataCount Where RptId = @Pi_RptId AND UserId = @Pi_UsrId
			INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
			SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptClosingStock 
		-- Till Here
	END
--SELECT *FROM #RptClosingStock	
	IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID=@Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptClosingStock_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE RptClosingStock_Excel
		IF @SupZeroStock=1 
		BEGIN
			SELECT PrdId,PrdName,MRP,Cases,Piece,KiloGrams,StockValue INTO RptClosingStock_Excel FROM #RptClosingStock WHERE (ISNULL([Cases],0)+ISNULL([Piece],0)+ISNULL([BoxStrip],0))<>0
		END
		ELSE
		BEGIN
			SELECT PrdId,PrdName,MRP,Cases,Piece,KiloGrams,StockValue INTO RptClosingStock_Excel FROM #RptClosingStock
		END
	END 
	RETURN
END
GO
IF EXISTS (SELECT NAME FROM SysObjects WHERE XTYPE ='P' AND name='Proc_RptCurrentStockParle')
DROP PROCEDURE Proc_RptCurrentStockParle
GO
--Exec Proc_RptCurrentStockParle 249,1,0,'PARLE',0,0,1,0
CREATE PROCEDURE Proc_RptCurrentStockParle
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
	Inner Join UomMaster UM On U.UomId=Um.UomId
	Where  P.PrdId Not In (Select PrdId From #PrdUomBox) And U.ConversionFactor > 1
			
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
				FROM dbo.View_CurrentStockReportParle VC,#PrdWeight P -- Select * from View_CurrentStockReport
				WHERE VC.PrdId = P.PrdId AND
				(CmpId=  (CASE @CmpId WHEN 0 THEN CmpId ELSE 0 END ) OR
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cn2Cs_RetailerApproval')
DROP PROCEDURE Proc_Cn2Cs_RetailerApproval
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_RetailerApproval 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_RetailerApproval
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_RetailerApproval
* PURPOSE		: To Change the Retailer Status,Classification
* CREATED		: Nandakumar R.G
* CREATED DATE	: 05/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @sSql			NVARCHAR(2000)
	DECLARE @Taction  		INT
	DECLARE @ErrDesc  		NVARCHAR(1000)
	DECLARE @Tabname  		NVARCHAR(50)
	DECLARE @RtrCode  		NVARCHAR(200)
	DECLARE @CmpRtrCode  	NVARCHAR(200)
	DECLARE @RtrClassCode  	NVARCHAR(200)
	DECLARE @RtrChannelCode	NVARCHAR(200)
	DECLARE @RtrGroupCode	NVARCHAR(200)
	DECLARE @Status  		NVARCHAR(200)
	DECLARE @KeyAcc  		NVARCHAR(200)
	DECLARE @StatusId  		INT
	DECLARE @RtrId  		INT
	DECLARE @RtrClassId  	INT
	DECLARE @CtgLevelId  	INT
	DECLARE @CtgMainId  	INT	
	DECLARE @KeyAccId		INT
	DECLARE @Pi_UserId  	INT	
	DECLARE @CtgClassMainId INT
	SET @Po_ErrNo=0
	SET @Tabname = 'Cn2Cs_Prk_RetailerApproval'
	SET @Pi_UserId=1
	
	
	DECLARE Cur_RetailerApproval CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([RtrCode])),''),ISNULL(LTRIM(RTRIM([CmpRtrCode])),''),ISNULL(LTRIM(RTRIM([RtrChannelCode])),''),ISNULL(LTRIM(RTRIM([RtrGroupCode])),''),
	ISNULL(LTRIM(RTRIM([RtrClassCode])),''),ISNULL(LTRIM(RTRIM([Status])),'Active'),ISNULL(LTRIM(RTRIM([KeyAccount])),'Yes')
	FROM Cn2Cs_Prk_RetailerApproval WHERE [DownLoadFlag] ='D'
	OPEN Cur_RetailerApproval
	FETCH NEXT FROM Cur_RetailerApproval INTO @RtrCode,@CmpRtrCode,@RtrChannelCode,@RtrGroupCode,@RtrClassCode,@Status,@KeyAcc
	WHILE @@FETCH_STATUS=0
	BEGIN
		
		SET @Po_ErrNo=0
		IF NOT EXISTS (SELECT RtrId FROM Retailer WHERE CmpRtrCode=@CmpRtrCode)
		BEGIN
			SET @ErrDesc = 'Retailer Code:'+@RtrCode+'does not exists'
			INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Code',@ErrDesc)
			SET @RtrId=0
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @RtrId=RtrId FROM Retailer WHERE CmpRtrCode=@CmpRtrCode			
		END
		
		IF NOT EXISTS (SELECT CtgMainId FROM RetailerCategory WHERE CtgCode=@RtrGroupCode)
		BEGIN
			SET @ErrDesc = 'Retailer Category Level Value:'+@RtrGroupCode+' does not exists'
			INSERT INTO Errorlog VALUES (3,@TabName,'Retailer Category Level Value',@ErrDesc)
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @CtgClassMainId=CtgMainId FROM RetailerCategory
			WHERE CtgCode=@RtrGroupCode
		END
		
		IF NOT EXISTS (SELECT RtrClassId FROM RetailerValueClass WHERE ValueClassCode=@RtrClassCode
		AND CtgMainId=@CtgClassMainId)
		BEGIN
			SET @ErrDesc = 'Retailer Value Class:'+@RtrClassCode+' does not exists'
			INSERT INTO Errorlog VALUES (4,@TabName,'Retailer Value Class',@ErrDesc)
			SET @Po_ErrNo=1
		END
		ELSE
		BEGIN
			SELECT @RtrClassId=RtrClassId FROM RetailerValueClass
			WHERE ValueClassCode=@RtrClassCode AND CtgMainId=@CtgClassMainId
		END
			
		IF UPPER(LTRIM(RTRIM(@Status)))=UPPER('ACTIVE')
		BEGIN
			SET @Status=1	
		END
		ELSE
		BEGIN
			SET @Status=0
		END
		IF UPPER(LTRIM(RTRIM(@KeyAcc)))=UPPER('YES')
		BEGIN
			SET @KeyAccId=1	
		END
		ELSE
		BEGIN
			SET @KeyAccId=0
		END
			
		IF @Po_ErrNo=0
		BEGIN
			UPDATE Retailer SET RtrStatus=@Status,Approved=1,RtrKeyAcc=@KeyAccId WHERE RtrId=@RtrId
			
			SET @sSql='UPDATE Retailer SET RtrStatus='+CAST(@Status AS NVARCHAR(100))+',RtrKeyAcc='+CAST(@KeyAccId AS NVARCHAR(100))+' WHERE RtrId='+CAST(@RtrId AS NVARCHAR(100))+''
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			DECLARE @OldCtgMainId	NUMERIC(38,0)
			DECLARE @OldCtgLevelId	NUMERIC(38,0)
			DECLARE @OldRtrClassId	NUMERIC(38,0)
			DECLARE @NewCtgMainId	NUMERIC(38,0)
			DECLARE @NewCtgLevelId	NUMERIC(38,0)
			DECLARE @NewRtrClassId	NUMERIC(38,0)
			SELECT @OldCtgMainId=A.CtgMainId,@OldCtgLevelId=B.CtgLevelId,@OldRtrClassId=C.RtrClassId 
			FROM RetailerCategory A INNER JOIN RetailerCategoryLevel B ON A.CtgLevelId=B.CtgLevelId
			INNER JOIN RetailerValueClass C ON A.CtgMainId=C.CtgMainId
			INNER JOIN RetailerValueClassMap D ON C.RtrClassId=RtrValueClassId
			WHERE D.RtrId=@RtrId
			
			DELETE FROM RetailerValueClassMap WHERE RtrId=@RtrId
			
			SET @sSql='DELETE FROM RetailerValueClassMap WHERE RtrId='+CAST(@RtrId AS VARCHAR(100))+''
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			
			INSERT INTO RetailerValueClassMap
			(RtrId,RtrValueClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@RtrId,@RtrClassId,
			1,@Pi_UserId,CONVERT(NVARCHAR(10),GETDATE(),121),@Pi_UserId,CONVERT(NVARCHAR(10),GETDATE(),121))
			SELECT @NewCtgMainId=A.CtgMainId,@NewCtgLevelId=B.CtgLevelId,@NewRtrClassId=C.RtrClassId 
			FROM RetailerCategory A INNER JOIN RetailerCategoryLevel B ON A.CtgLevelId=B.CtgLevelId
			INNER JOIN RetailerValueClass C ON A.CtgMainId=C.CtgMainId
			INNER JOIN RetailerValueClassMap D ON C.RtrClassId=RtrValueClassId
			WHERE D.RtrId=@RtrId
			INSERT INTO Track_RtrCategoryandClassChange
			SELECT -3000,@RtrId,@OldCtgLevelId,@OldCtgMainId,@OldRtrClassId,@NewCtgLevelId,@NewCtgMainId, 
			@NewRtrClassId,CONVERT(NVARCHAR(10),GETDATE(),121),CONVERT(NVARCHAR(23),GETDATE(),121),4
			
			SET @sSql='INSERT INTO RetailerValueClassMap
			(RtrId,RtrValueClassId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES('+CAST(@RtrId AS VARCHAR(10))+','+CAST(@RtrClassId AS VARCHAR(10))+',
			1,'+CAST(@Pi_UserId AS VARCHAR(10))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''',
			'+CAST(@Pi_UserId AS VARCHAR(10))+','''+CONVERT(NVARCHAR(10),GETDATE(),121)+''')'
		
			INSERT INTO Translog(strSql1) VALUES (@sSql)			
		END
		FETCH NEXT FROM Cur_RetailerApproval INTO @RtrCode,@CmpRtrCode,@RtrChannelCode,@RtrGroupCode,@RtrClassCode,@Status,@KeyAcc
	END
	CLOSE Cur_RetailerApproval
	DEALLOCATE Cur_RetailerApproval
	UPDATE Cn2Cs_Prk_RetailerApproval SET DownLoadFlag='Y' WHERE DownLoadFlag ='D'
	RETURN
END
GO
--Tax Settings Download
IF NOT EXISTS (SELECT A.Name FROM SysColumns A WITH(NOLOCK) INNER JOIN Sysobjects B WITH(NOLOCK) ON A.id = B.id 
AND B.xtype = 'U' AND B.name = 'Etl_Prk_TaxSetting' AND A.Name = 'FreightCharge')
BEGIN
    ALTER TABLE Etl_Prk_TaxSetting ADD FreightCharge NVARCHAR(200) DEFAULT '' WITH VALUES
END
GO
IF EXISTS (SELECT Name FROM Sysobjects WHERE Xtype = 'P' AND Name = 'Proc_ImportTaxConfigGroupSetting')
DROP PROCEDURE Proc_ImportTaxConfigGroupSetting
GO
--Exec Proc_ImportTaxConfigGroupSetting '<Data></Data>'
CREATE PROCEDURE Proc_ImportTaxConfigGroupSetting
(
	@Pi_Records TEXT
)
AS
/*********************************
* PROCEDURE	: Proc_ImportTaxConfigGroupSetting
* PURPOSE	: To Insert records from xml file in the Table Etl_Prk_TaxConfig_GroupSetting
* CREATED	: Mahalakshmi .A
* CREATED DATE	: 02/09/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	DELETE FROM Etl_Prk_TaxSetting WHERE DownloadFlag='Y'
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	INSERT INTO Etl_Prk_TaxSetting(DistCode,TaxGroupCode,Type,PrdTaxGroupCode,TaxCode,Percentage,ApplyOn,Discount,
	SchDiscount,DBDiscount,CDDiscount,ApplyTax,DownloadFlag,CreatedDate,FreightCharge)
	SELECT DistCode,TaxGroupCode,Type,PrdTaxGroupCode,TaxCode,Percentage,ApplyOn,Discount,SchDiscount,DBDiscount,
	CDDiscount,ApplyTax,DownloadFlag,CreatedDate,FreightCharge
	FROM OPENXML (@hdoc,'/Root/Console2CS_TaxSettings',1)
	WITH (
			DistCode             NVARCHAR(100),
			TaxGroupCode		 NVARCHAR(100),
			Type			     NVARCHAR(100),
			PrdTaxGroupCode		 NVARCHAR(100),
			TaxCode				 NVARCHAR(100),
			Percentage			 NVARCHAR(100),
			ApplyOn				 NVARCHAR(100),
			Discount 			 NVARCHAR(100),
			SchDiscount 		 NVARCHAR(100),
			DBDiscount 			 NVARCHAR(100),
			CDDiscount 			 NVARCHAR(100),
			ApplyTax			 NVARCHAR(100),
			DownloadFlag		 NVARCHAR(100),
			CreatedDate          NVARCHAR(100),  
			FreightCharge        NVARCHAR(100)
	) XMLObj
	
	EXEC sp_xml_removedocument @hDoc 
END
GO
IF EXISTS (SELECT Name FROM Sysobjects WHERE Xtype = 'P' AND Name = 'Proc_Cn2Cs_TaxSetting')
DROP PROCEDURE Proc_Cn2Cs_TaxSetting
GO
/*
BEGIN TRANSACTION
EXEC Proc_CN2CS_TaxSetting 0
SELECT * FROM ErrorLog
select * from Etl_Prk_TaxSetting (Nolock)
--SELECT * FROM TaxSettingMaster
--SELECT * FROM TaxSettingDetail
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_TaxSetting 
(
	@Po_ErrNo INT OUTPUT
)
AS
/*************************************************************************************************************
* PROCEDURE	: Proc_CN2CS_TaxSetting
* PURPOSE	: To Store TaxGroup Setting records  from xml file in the Table TaxGroupSetting
* CREATED	: Mahalakshmi.A
* CREATED DATE	: 20/08/2009
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
--------------------------------------------------------------------------------------------------------------
* {date}		{developer}		{brief modification description}
* 07/09/2009    Nandakumar R.G  Change the validations for Tax on Tax and other basic validations
* 09.09.2009    Panneer			Update the Download Flag in Parking Table
* 19/08/2010    Nandakumar R.G  Discount Validation Changes
* 28/04/2011    Nandakumar R.G  Discount Validation Changes
**************************************************************************************************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TaxGroupCode	 AS NVARCHAR(200)
	DECLARE @Type			 AS NVARCHAR(200)
	DECLARE @PrdTaxGroupCode AS NVARCHAR(200)
	DECLARE @TaxCode		 AS NVARCHAR(200)
	DECLARE @Percentage	     AS NUMERIC(38,6)
	DECLARE @ApplyOn		 AS NVARCHAR(100)
	DECLARE @Discount		 AS NVARCHAR(100)
	DECLARE @Tabname		 AS NVARCHAR(100)
	DECLARE @ErrDesc		 AS NVARCHAR(1000)
	DECLARE @sSql			 AS NVARCHAR(4000)
	DECLARE @ErrStatus		 AS INT
	DECLARE @Taction		 AS INT
	DECLARE @TaxSeqId	 AS INT
	DECLARE @RtrId		 AS INT
	DECLARE @PrdId		 AS INT
	DECLARE @BillSeqId	 AS INT
	DECLARE @Slno		 AS INT
	DECLARE @ColNo		 AS INT
	DECLARE @iCntColNo	 AS INT
	DECLARE @iColType	 AS INT
	DECLARE @ColValue	 AS INT
	DECLARE @RowId		 AS INT
	DECLARE @TaxId		 AS INT
	DECLARE @iApplyOn	 AS INT
	DECLARE @iDiscount	 AS INT
	DECLARE @DColNo		 AS INT
	DECLARE @FieldDesc	 AS NVARCHAR(100)
	DECLARE @SColNo		 AS INT
	DECLARE @ColId		 AS INT
	DECLARE @SlNo1		 AS INT
	DECLARE @SlNo2		 AS INT
	DECLARE @BillSeqId_Temp	AS	INT
	DECLARE @EffetOnTax		AS	INT
	DECLARE @SchDiscount		 AS NVARCHAR(100)
	DECLARE @DBDiscount		 AS NVARCHAR(100)
	DECLARE @CDDiscount		 AS NVARCHAR(100)
	DECLARE @FreightCharge   AS NVARCHAR(100)
	/*
		SET @iColType=1   For TaxPercentage Value Column
		SET @iColType=2	  For MRP,SellingRate,PurchaseRate , Bill Column Sequence Value and Purchase Column Sequence
		SET @iColType=3   For Tax Configuration TaxCode Column Value
		SET @ColValue=0	  For "NONE"
		SET @ColValue=1   For "ADD"
		SET @ColValue=2   For "REDUCE"		
	*/
	
	SET @Tabname = 'Etl_Prk_TaxSetting'
	SET @Po_ErrNo=0
	SET @iCntColNo=0
	DECLARE @TblColNo TABLE
	(
		ColNo			INT IDENTITY(0,1) NOT NULL,
		SlNo1			INT,
		SlNo2			INT,
		FieldDesc		NVARCHAR(50)
	)
	DECLARE @T1 TABLE
	(
		SlNo			INT,
		FieldDesc		NVARCHAR(50)
	)
	DELETE FROM Etl_Prk_TaxSetting WHERE DownLoadFlag='Y'
	DECLARE Cur_TaxSettingMaster CURSOR		--TaxSettingMaster Cursor
	FOR SELECT DISTINCT ISNULL(TaxGroupCode,''),ISNULL(Type,''),ISNULL(PrdTaxGroupCode,'')
	FROM Etl_Prk_TaxSetting WHERE DownloadFlag='D'
	OPEN Cur_TaxSettingMaster
	
	FETCH NEXT FROM Cur_TaxSettingMaster INTO @TaxGroupCode,@Type,@PrdTaxGroupCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		--Check the Empty Values for TaxSetting Master
		SET @iCntColNo=6
		IF @TaxGroupCode=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Tax Group Code: ' + @TaxGroupCode + ' should not be Empty'
			INSERT INTO Errorlog VALUES (1,@Tabname,'Tax Group code',@ErrDesc)
		END
		IF @Type=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Type ' + @Type + ' should not be Empty'
			INSERT INTO Errorlog VALUES (1,@Tabname,'Type',@ErrDesc)
		END
		IF @PrdTaxGroupCode=''
		BEGIN
			SET @Po_ErrNo=1
			SET @Taction=0
			SET @ErrDesc = 'Product Tax Group Code ' + @PrdTaxGroupCode + ' should not be Empty'
			INSERT INTO Errorlog VALUES (1,@Tabname,'Type',@ErrDesc)
		END
		--Till Here
		IF NOT EXISTS  (SELECT * FROM TaxgroupSetting WHERE RtrGroup = @TaxGroupCode) --Get the Retailer/Supplier TaxGroupId's
		BEGIN
			SET @Po_ErrNo=1
			SET @ErrDesc = 'TaxGroupCode ' + @TaxGroupCode + ' is not available' 		
			INSERT INTO Errorlog VALUES (2,@Tabname,'Tax Group Code',@ErrDesc)
		END
		ELSE
		BEGIN
			SELECT @RtrId=TaxGroupId FROM TaxGroupSetting WHERE RtrGroup= @TaxGroupCode
		END
		IF NOT EXISTS  (SELECT * FROM TaxgroupSetting WHERE PrdGroup = @PrdTaxGroupCode) --Get the Product TaxGroupId's
		BEGIN
			SET @Po_ErrNo=1
			SET @ErrDesc = 'Product TaxGroupCode ' + @PrdTaxGroupCode + ' is not available' 		
			INSERT INTO Errorlog VALUES (2,@Tabname,'Product Tax Group Code',@ErrDesc)
		END
		ELSE
		BEGIN
			SELECT @PrdId=TaxGroupId FROM TaxGroupSetting WHERE PrdGroup= @PrdTaxGroupCode
		END
		
		DELETE FROM @T1
		IF UPPER(@Type)='RETAILER'
		BEGIN
			SELECT DISTINCT @BillSeqId=BillSeqId FROM BillSequenceDetail (NOLOCK)
			WHERE SlNo >= 4 and SlNo < (SELECT Slno From BillSequenceDetail WHERE RefCode='H' and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)) and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)
			SELECT @iCntColNo=@iCntColNo+COUNT(BillSeqId) FROM BillSequenceDetail (NOLOCK)
			WHERE SlNo >= 4 and SlNo < (SELECT Slno From BillSequenceDetail WHERE RefCode='H' and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)) and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)
			
			INSERT INTO @T1(SlNo,FieldDesc)
			SELECT Slno,FieldDesc
			FROM BillSequenceDetail (NOLOCK)
			WHERE SlNo >= 4 and SlNo <
			(SELECT Slno From BillSequenceDetail WHERE RefCode='H' and BillSeqId in
			(SELECT Max(BillSeqId) FROM BillSequenceMaster)) Order By SlNo
		END
		ELSE IF UPPER(@Type)='SUPPLIER'
		BEGIN
			SELECT DISTINCT @BillSeqId=PurSeqId FROM PurchaseSequenceDetail (NOLOCK)
			WHERE SlNo >= 3 and SlNo <
			(SELECT Slno From PurchaseSequenceDetail WHERE RefCode='D' and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster))  and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster)
			
			SELECT @iCntColNo=@iCntColNo+COUNT(PurSeqId) FROM PurchaseSequenceDetail (NOLOCK)
			WHERE SlNo >= 3 and SlNo <
			(SELECT Slno From PurchaseSequenceDetail WHERE RefCode='D' and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster))  and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster)
			INSERT INTO @T1(SlNo,FieldDesc)
			SELECT Slno,FieldDesc FROM PurchaseSequenceDetail (NOLOCK)
			WHERE SlNo >= 3 and SlNo <
			(SELECT Slno From PurchaseSequenceDetail WHERE RefCode='D' and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster))
			and PurSeqId in
			(SELECT Max(PurSeqId) FROM PurchaseSequenceMaster) Order By SlNo
		END
		SELECT @iCntColNo=@iCntColNo+(COUNT(TaxId)) FROM TaxConfiguration
		SELECT @TaxSeqId= dbo.Fn_GetPrimaryKeyInteger('TaxSettingMaster','TaxSeqId',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))
		IF  @Po_ErrNo=0
		BEGIN	
			INSERT INTO TaxSettingMaster(TaxSeqId,RtrId,PrdId,SequenceDate,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@TaxSeqId,@RtrId,@PrdID,CONVERT(NVARCHAR(11),GETDATE(),121),1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
			SET @sSql= 'INSERT INTO TaxSettingMaster(TaxSeqId,RtrId,PrdId,SequenceDate,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@TaxSeqId AS NVARCHAR(100)) + ',' + CAST(@RtrId AS NVARCHAR(100)) +','+ CAST(@PrdId AS NVARCHAR(100))+ ','''
						+ CONVERT(NVARCHAR(11),GETDATE(),121)+''',1,1,''' + CONVERT(NVARCHAR(11),GETDATE(),121)+''',1,'''+ CONVERT(NVARCHAR(11),GETDATE(),121)+ ''')'
						
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			UPDATE Counters SET Currvalue = Currvalue + 1  WHERE	Tabname = 'TaxSettingMaster' AND Fldname = 'TaxSeqId'
			
			SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSettingMaster'' AND Fldname = ''TaxSeqId'''
			
			INSERT INTO Translog(strSql1) Values (@sSQL)
		END
		
		DECLARE @TaxSettingTable TABLE
		(
			TaxId			INT,
			TaxGrpCode		NVARCHAR(200),
			Type			NVARCHAR(200),
			TaxPrdGrpCode	NVARCHAR(200),
			TaxCode			NVARCHAR(200),
			Percentage		NUMERIC(38,6),
			Applyon			NVARCHAR(200),
			Discount		NVARCHAR(200),
			SchDiscount		NVARCHAR(200),
			DBDiscount		NVARCHAR(200),
			CDDiscount		NVARCHAR(200),
			FreightCharge   NVARCHAR(200)
		)
		DELETE FROM @TaxSettingTable
		INSERT INTO @TaxSettingTable (TaxId,TaxGrpCode,Type,TaxPrdGrpCode,TaxCode,Percentage,Applyon,Discount,
		SchDiscount,DBDiscount,CDDiscount,FreightCharge)
		SELECT DISTINCT TC.TaxId, ISNULL(ETL1.TaxGroupCode,''),ISNULL(ETL1.Type,''),
		ISNULL(ETL1.PrdTaxGroupCode,''),ISNULL(TC.TaxCode,''),ISNULL(ETL1.Percentage,0),
		ISNULL(ETL1.ApplyOn,'None'),ISNULL(ETL1.Discount,'None'),ISNULL(ETL1.SchDiscount,'None'),
		ISNULL(ETL1.DBDiscount,'None'),ISNULL(ETL1.CDDiscount,'None'),ISNULL(ETL1.FreightCharge,'None') 
		FROM
		(SELECT ISNULL(ETL.TaxGroupCode,'') AS TaxGroupCode,ISNULL(ETL.Type,'') AS Type,ISNULL(ETL.TaxCode,'') AS TaxCode,
		ISNULL(ETL.PrdTaxGroupCode,'') AS PrdTaxGroupCode,ISNULL(ETL.Percentage,0) AS Percentage,ISNULL(ETL.ApplyOn,'') AS ApplyOn,
		ISNULL(ETL.Discount,'') AS Discount,ISNULL(ETL.SchDiscount,'') AS SchDiscount,ISNULL(ETL.DBDiscount,'') AS DBDiscount,
		ISNULL(ETL.CDDiscount,'') AS CDDiscount,ISNULL(ETL.FreightCharge,'') AS FreightCharge
		FROM Etl_Prk_TaxSetting ETL
		WHERE DownloadFlag='D' AND TaxGroupCode=@TaxGroupCode AND PrdTaxGroupCode=@PrdTaxGroupCode) ETL1
		RIGHT OUTER JOIN TaxConfiguration TC ON TC.TaxCode=ETL1.TaxCode
		SET @RowId=0
		DECLARE Cur_TaxSettingDetail CURSOR		--TaxSettingDetail Cursor
		FOR SELECT TaxGrpCode,Type,TaxPrdGrpCode,TaxCode,Percentage,Applyon,Discount,SchDiscount,DBDiscount,CDDiscount,FreightCharge
		FROM @TaxSettingTable Order By TaxId
		OPEN Cur_TaxSettingDetail
		FETCH NEXT FROM Cur_TaxSettingDetail INTO @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount,
		@SchDiscount,@DBDiscount,@CDDiscount,@FreightCharge
		WHILE @@FETCH_STATUS=0
		BEGIN
			SET @RowId=@RowId+1
			--Nanda
			--SELECT @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount
			
			IF @TaxCode=''	--Check Empty Values For TaxSetting Details
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Tax Code' + @TaxCode + ' should not be Empty'
				INSERT INTO Errorlog VALUES (1,@Tabname,'Tax Code',@ErrDesc)
			END
			
			IF @Percentage<0
			BEGIN
				SET @Po_ErrNo=1
				SET @Taction=0
				SET @ErrDesc = 'Percentage' + CAST(@Percentage AS NVARCHAR(20)) + ' should not be Empty'
				INSERT INTO Errorlog VALUES (1,@Tabname,'Percentage',@ErrDesc)
			END
			IF @Applyon=''
			BEGIN
				SET @iApplyOn=0
			END
			ELSE IF UPPER(@ApplyOn)='SELLINGRATE' OR UPPER(@ApplyOn)='MRP' OR UPPER(@ApplyOn)='PURCHASERATE'
			BEGIN
				SET @iApplyOn=1
			END
			ELSE
			BEGIN
				SET @iApplyOn=2
			END
			IF @Discount='ADD'
			BEGIN
				SET @iDiscount=1
			END
			ELSE IF UPPER(@Discount)='REDUCE'
			BEGIN
				SET @iDiscount=2
			END
			ELSE
			BEGIN
				SET @iDiscount=0
			END		
			--Till Here
			IF NOT EXISTS  (SELECT * FROM TaxConfiguration WHERE TaxCode = @TaxCode )
			BEGIN
				SET @Po_ErrNo=1
				SET @ErrDesc = 'Tax Code: ' + @TaxCode + ' is not available' 		
				INSERT INTO Errorlog VALUES (1,@Tabname,'Tax Code',@ErrDesc)
			END
			ELSE
			BEGIN
				SELECT @TaxId=TaxId FROM TaxConfiguration WHERE TaxCode=@TaxCode	
			END
			DELETE FROM @TblColNo
			INSERT INTO @TblColNo(SlNo1,SlNo2,FieldDesc)
			SELECT 1,1,'TaxID' AS FieldDesc
			UNION
			SELECT 2,1,'Tax Name' AS FieldDesc
			UNION
			SELECT 3,1,'Tax%' AS FieldDesc
			UNION
			SELECT 4,1,'MRP' AS FieldDesc
			UNION
			SELECT 5,1,'SELLING RATE' AS FieldDesc
			UNION
			SELECT 6,1,'PURCHASE RATE' AS FieldDesc
			UNION
			SELECT 7,Slno,FieldDesc FROM @T1
			UNION
			SELECT 8,TaxId,TaxName FROM TaxConfiguration
			
			SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
			
			INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
			ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@RowId,1,@SlNo,@BillSeqId,@TaxSeqId,1,@TaxId,@TaxId,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
			
			SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
				+ CAST(@RowId AS NVARCHAR(100)) + ',1,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
				+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',1,' + CAST(@TaxId AS NVARCHAR(100)) + ',' +CAST(@TaxId AS NVARCHAR(100)) + ',1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
			SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
			INSERT INTO Translog(strSql1) Values (@sSQL)
			SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
			INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
			ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@RowId,3,@SlNo,@BillSeqId,@TaxSeqId,1,0,@Percentage,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					
			SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
				+ CAST(@RowId AS NVARCHAR(100)) + ',3,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
				+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',1,0,' +CAST(@Percentage AS NVARCHAR(100)) + ',1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
										
			INSERT INTO Translog(strSql1) VALUES (@sSql)
			
			UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
			SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
			INSERT INTO Translog(strSql1) Values (@sSQL)
			SET @sColNo=4
			
			--------TaxSetting1-->Price Settings---------------------
			DECLARE Cur_TaxSetting1 CURSOR		--Column Wise Details Inserts row Wise Cursor
			FOR SELECT ColNo,FieldDesc FROM @TblColNo WHERE SlNo1>3 AND SlNo1<7
			OPEN Cur_TaxSetting1
			FETCH NEXT FROM Cur_TaxSetting1 INTO @DColNo,@FieldDesc
			WHILE @@FETCH_STATUS=0
			BEGIN
				IF @sColNo=4 AND UPPER(@ApplyOn)='MRP'
				BEGIN
					--SET MRP as 1 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,1,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,1,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					--SET Sellling Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Purchase Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE IF @sColNo=5 AND UPPER(@ApplyOn)='SELLINGRATE'	
				BEGIN
					--SET MRP AS Value as 0
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',4,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
		
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
		
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Selling Rate Value as 1
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,1,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',5,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,1,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
		
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
	
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Purchase Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE IF @sColNo=6 AND UPPER(@ApplyOn)='PURCHASERATE'	
				BEGIN
					--SET MRP AS Value as 0
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',4,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
		
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
		
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Sellling Rate as 0 Value
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--SET Purchase Rate as 1						
					SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
					ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,1,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,1,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'											
					
					INSERT INTO Translog(strSql1) VALUES (@sSql)
					UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
					SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
	
					INSERT INTO Translog(strSql1) Values (@sSQL)
				END
				ELSE IF EXISTS(SELECT TaxCode FROM TaxConfiguration WHERE TaxCode=@ApplyOn) OR UPPER(@ApplyOn)='NONE'
				BEGIN					
					IF @sColNo=4
					BEGIN
						--SET MRP as 0 Value
						SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
						
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,4,@SlNo,@BillSeqId,@TaxSeqId,2,1,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
							+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
							+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,1,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
											
						INSERT INTO Translog(strSql1) VALUES (@sSql)
						UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
						SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
					END
					ELSE IF @sColNo=5
					BEGIN
						--SET Sellling Rate as 0 Value
						SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,5,@SlNo,@BillSeqId,@TaxSeqId,2,2,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
							+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
							+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,2,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
						
						INSERT INTO Translog(strSql1) VALUES (@sSql)
						UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
						SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
					ELSE IF @sColNo=6
					BEGIN
						--SET Purchase Rate as 0 Value
						SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,6,@SlNo,@BillSeqId,@TaxSeqId,2,3,0,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
							+ CAST(@RowId AS NVARCHAR(100)) + ',6,' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
							+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,3,0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
												
						INSERT INTO Translog(strSql1) VALUES (@sSql)
						UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
						SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
				END	
--				--Nanda
--				SELECT * FROM TaxSettingDetail WHERE TaxSeqId=@TaxSeqId AND RowId=@RowId
				SET @sColNo=@sColNo+1
	
				FETCH NEXT FROM Cur_TaxSetting1 INTO @DColNo,@FieldDesc
			END
			CLOSE Cur_TaxSetting1
			DEALLOCATE Cur_TaxSetting1
			-----TaxSetting1--------------------------------
			----------------TaxSetting2-->Bill/Purchase Column Sequnce Settings---------------------
			SET @sColNo=7
			SET @ColId=4
			--Nanda
			--SELECT ColNo,SlNo1,FieldDesc FROM @TblColNo WHERE SlNo1=7
			DECLARE Cur_TaxSetting2 CURSOR		--Column Wise Details Inserts row Wise Cursor
			FOR
				SELECT ColNo,SlNo1,FieldDesc,SlNo2  FROM @TblColNo WHERE SlNo1=7
			OPEN Cur_TaxSetting2
			FETCH NEXT FROM Cur_TaxSetting2 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			WHILE @@FETCH_STATUS=0
			BEGIN
				
				SET @EffetOnTax=0
				IF UPPER(@Type)='RETAILER'
				BEGIN
					SELECT @BillSeqId_Temp=MAX(BillSeqId) FROM dbo.BillSequenceMaster
					SELECT @EffetOnTax=EffectInNetAmount FROM dbo.BillSequenceDetail WHERE BillSeqId=@BillSeqId_Temp 
					AND SlNo=@SlNo2
					--->Added By Nanda on 28/04/2011										
					IF @FieldDesc='Spl. Disc' 
					BEGIN
						IF UPPER(@Discount)='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@Discount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					ELSE IF @FieldDesc='Sch Disc' 
					BEGIN
						IF UPPER(@SchDiscount)='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@SchDiscount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					ELSE IF @FieldDesc='DB Disc' 
					BEGIN
						IF UPPER(@DBDiscount)='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@DBDiscount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					ELSE IF @FieldDesc='CD Disc'
					BEGIN
						IF UPPER(@CDDiscount)='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@CDDiscount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					ELSE
					BEGIN
						IF UPPER(@Discount)='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@Discount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
					END	
					--->Till Here
				END
				ELSE IF UPPER(@Type)='SUPPLIER'
				BEGIN
					SELECT @BillSeqId_Temp=MAX(PurSeqId) FROM dbo.PurchaseSequenceMaster
					SELECT @EffetOnTax=EffectInNetAmount FROM dbo.PurchaseSequenceDetail WHERE PurSeqId=@BillSeqId_Temp 
					AND SlNo=@SlNo2
					
					IF UPPER(@FieldDesc)='FREIGHTCHARGES' 
					BEGIN
						IF UPPER(@FreightCharge)='ADD'
						BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@FreightCharge)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END					
				     END
				     ELSE IF UPPER(@FieldDesc) = 'DISC'
					 BEGIN
					    IF UPPER(@Discount)='ADD'
					    BEGIN
							SET @iDiscount=1
						END
						ELSE IF UPPER(@Discount)='REDUCE'
						BEGIN
							SET @iDiscount=2
						END
						ELSE
						BEGIN
							SET @iDiscount=0
						END
					 END
					 ELSE
					 BEGIN
					     SET @iDiscount=0
					 END
				END			        		 
									
				IF @iApplyOn=2
				BEGIN
					SET @EffetOnTax=0
				END				
				SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
				INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
				ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				--VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,2,@ColId,@EffetOnTax,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
				VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,2,@ColId,@iDiscount,1,1,CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',2,'+ CAST(@ColId AS NVARCHAR(100))+ ',' +CAST(@EffetOnTax AS NVARCHAR(100))+',1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
										
				
				INSERT INTO Translog(strSql1) VALUES (@sSql)
				
				UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
				SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
		
				INSERT INTO Translog(strSql1) Values (@sSQL)					
				SET @sColNo=@sColNo+1
				SET @ColId=@ColId+1
				FETCH NEXT FROM Cur_TaxSetting2 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			END
			CLOSE Cur_TaxSetting2
			DEALLOCATE Cur_TaxSetting2
			------TaxSetting2-----------------------
			-------TaxSetting3-->Tax On Tax Settings-----------------------
			SET @sColNo=@sColNo
			SET @ColId=1
			
			DECLARE Cur_TaxSetting3 CURSOR		--Column Wise Details Inserts row Wise Cursor
			FOR SELECT ColNo,SlNo1,FieldDesc,SlNo2 FROM @TblColNo WHERE SlNo1=8 AND SlNo2<>@TaxId
			OPEN Cur_TaxSetting3
			FETCH NEXT FROM Cur_TaxSetting3 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			WHILE @@FETCH_STATUS=0
			BEGIN
				SELECT @Slno= dbo.Fn_GetPrimaryKeyInteger('TaxSetting','SlNo',CAST(YEAR(GetDate())AS INT),MONTH(GETDATE()))					
				IF @iApplyOn<>2
				BEGIN
					INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
					VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,3,@TaxId,0,1,1,
					CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
				END
				ELSE
				BEGIN
					IF EXISTS(SELECT * FROM TaxConfiguration WHERE TaxCode=@Applyon AND TaxId=@SlNo2)
					BEGIN
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,3,@TaxId,@SlNo2,1,1,
						CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
						SET @iApplyOn=1
					END
					ELSE
					BEGIN
						INSERT INTO TaxSettingDetail (RowId,ColNo,SlNo,BillSeqId,TaxSeqId,
						ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)
						VALUES(@RowId,@sColNo,@SlNo,@BillSeqId,@TaxSeqId,3,@TaxId,0,1,1,
						CONVERT(NVARCHAR(11),GETDATE(),121),1,CONVERT(NVARCHAR(11),GETDATE(),121))
					END
				END
				SET @sSql= 'INSERT INTO TaxSettingDetail(RowId,ColNo,SlNo,BillSeqId,TaxSeqId,ColType,ColId,ColVal,Availability,LastModBy,LastModDate,AuthId,AuthDate)VALUES('
						+ CAST(@RowId AS NVARCHAR(100)) + ',' + CAST(@sColNo AS NVARCHAR(100)) + ',' + CAST(@SlNo AS NVARCHAR(100)) +','+ CAST(@BillSeqId AS NVARCHAR(100))
						+ ',' + CAST(@TaxSeqId AS NVARCHAR(100)) + ',3,'+ CAST(@TaxId AS NVARCHAR(100))+ ',0,1,1,'''+CONVERT(NVARCHAR(11),GETDATE(),121) + ''',1,''' + CONVERT(NVARCHAR(11),GETDATE(),121) + ''')'
										
				
				INSERT INTO Translog(strSql1) VALUES (@sSql)
				UPDATE Counters SET Currvalue = Currvalue + 1  WHERE Tabname = 'TaxSetting' AND Fldname = 'SlNo'
	
				SET @sSQL='UPDATE Counters SET Currvalue = Currvalue + 1 WHERE Tabname = ''TaxSetting'' AND Fldname = ''SlNo'''
	
				INSERT INTO Translog(strSql1) Values (@sSQL)
				SET @ColId=@ColId+1
				FETCH NEXT FROM Cur_TaxSetting3 INTO @DColNo,@SlNo1,@FieldDesc,@SlNo2
			END
			CLOSE Cur_TaxSetting3
			DEALLOCATE Cur_TaxSetting3
			UPDATE Etl_Prk_TaxSetting  SET DownloadFlag = 'Y'
			WHERE TaxGroupCode = @TaxGroupCode AND TaxCode = @TaxCode AND Percentage = @Percentage
			AND Type = @Type AND PrdTaxGroupCode = @PrdTaxGroupCode
			FETCH NEXT FROM Cur_TaxSettingDetail INTO @TaxGroupCode,@Type,@PrdTaxGroupCode,@TaxCode,@Percentage,@ApplyOn,@Discount,
			@SchDiscount,@DBDiscount,@CDDiscount,@FreightCharge
		END
		CLOSE Cur_TaxSettingDetail
		DEALLOCATE Cur_TaxSettingDetail
		FETCH NEXT FROM Cur_TaxSettingMaster INTO @TaxGroupCode,@Type,@PrdTaxGroupCode
	END
	CLOSE Cur_TaxSettingMaster
	DEALLOCATE Cur_TaxSettingMaster	
	UPDATE TaxSettingDetail SET ColVal=0 WHERE ColId=1 AND ColType=2 AND CAST(TaxSeqId AS NVARCHAR(10))+'~'+CAST(RowId AS NVARCHAR(10))
	NOT IN (SELECT CAST(TaxSeqId AS NVARCHAR(10))+'~'+CAST(RowId AS NVARCHAR(10)) FROM TaxSettingDetail WHERE ColType=1 AND ColId IN(SELECT TaxId FROM TaxConfiguration WHERE TaxCode='VAT'))
	AND  CAST(TaxSeqId AS NVARCHAR(10))+'~'+CAST(RowId AS NVARCHAR(10)) IN (
	SELECT CAST(TaxSeqId AS NVARCHAR(10))+'~'+CAST(RowId AS NVARCHAR(10)) FROM TaxSettingDetail WHERE ColType=1 AND ColId=0 AND ColVal=0)
	RETURN
END
GO
IF EXISTS	(	
				SELECT *FROM sys.indexes A(NOLOCK),sys.objects B(NOLOCK) 
				WHERE A.object_id = b.object_id AND A.name = 'Indx_StdVocMaster' AND B.name = 'StdVocMaster'
			)
BEGIN
	DROP INDEX StdVocMaster.Indx_StdVocMaster
END
GO
CREATE INDEX Indx_StdVocMaster ON StdVocMaster(VocRefNo,VocDate)
GO
IF EXISTS	(	
				SELECT *FROM sys.indexes A(NOLOCK),sys.objects B(NOLOCK) 
				WHERE A.object_id = b.object_id AND A.name = 'Indx_StdVocDetails' AND B.name = 'StdVocDetails'
			)
BEGIN
	DROP INDEX StdVocDetails.Indx_StdVocDetails
END
GO
CREATE CLUSTERED INDEX Indx_StdVocDetails ON StdVocDetails(VocRefNo)
GO
IF EXISTS	(	
				SELECT *FROM sys.indexes A(NOLOCK),sys.objects B(NOLOCK) 
				WHERE A.object_id = b.object_id AND A.name = 'Indx1_StdVocDetails' AND B.name = 'StdVocDetails'
			)
BEGIN
	DROP INDEX StdVocDetails.Indx1_StdVocDetails
END
GO
CREATE NONCLUSTERED INDEX Indx1_StdVocDetails ON StdVocDetails(CoaId,DebitCredit)
GO
IF EXISTS(SELECT * FROM sysobjects WHERE name = 'Proc_RptSalesBillWise' AND xtype='P')  
DROP PROCEDURE Proc_RptSalesBillWise
GO
---EXEC Proc_RptSalesBillWise 1,2,0,'Henkel',0,0,1
CREATE PROCEDURE Proc_RptSalesBillWise  
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
/****************************************************************************  
* PROCEDURE  : Proc_RptSalesBillWise  
* PURPOSE    : To Generate Sales Bill Wise  
* CREATED BY : Boopathy.P  
* CREATED ON : 30/07/2007  
* MODIFICATION  
*****************************************************************************  
* DATE        AUTHOR      DESCRIPTION  
07/12/2007  MURUGAN.R     Adding Retailer Category  
01-07-2014  Jai Ganesh R  Order By Billdate, Bll Number added in the Final Output
*****************************************************************************/  
SET NOCOUNT ON  
BEGIN  
DECLARE @NewSnapId  AS INT  
DECLARE @DBNAME  AS  nvarchar(50)  
DECLARE @TblName  AS nvarchar(500)  
DECLARE @TblStruct  AS nVarchar(4000)  
DECLARE @TblFields  AS nVarchar(4000)  
DECLARE @sSql  AS  nVarChar(4000)  
DECLARE @ErrNo   AS INT  
DECLARE @PurDBName AS nVarChar(50)  
--Filter Variable  
DECLARE @FromDate AS DATETIME  
DECLARE @ToDate   AS DATETIME  
DECLARE @FromBillNo AS  BIGINT  
DECLARE @TOBillNo   AS  BIGINT  
DECLARE @CmpId      AS  INT  
DECLARE @LcnId      AS  INT  
DECLARE @SMId   AS INT  
DECLARE @RMId   AS INT  
DECLARE @RtrId   AS INT  
DECLARE @BillType    AS INT  
DECLARE @BillMode    AS INT  
DECLARE @CtgLevelId AS  INT  
DECLARE @RtrClassId AS  INT  
DECLARE @CtgMainId  AS  INT  
DECLARE @BillStatus AS INT  
DECLARE @CancelValue AS INT  
--Till Here  
--Assgin Value for the Filter Variable  
SET @FromDate =(SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId))  
SET @ToDate = (SELECT  TOP 1 dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId))  
SET @SMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId))  
SET @RMId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId))  
SET @RtrId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId))  
SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
SET @LcnId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId))  
SET @FromBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,14,@Pi_UsrId))  
SET @TOBillNo =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,15,@Pi_UsrId))  
SET @BillType =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,17,@Pi_UsrId))  
SET @BillMode =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,33,@Pi_UsrId))  
SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))  
SET @RtrClassId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId))  
SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))  
SET @BillStatus =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,192,@Pi_UsrId))  
SET @CancelValue =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,193,@Pi_UsrId))  
--Till Here  
SELECT @PurDBName = dbo.Fn_ReturnPurgeDBName(@FromDate,@ToDate)  
--Till Here  
CREATE TABLE #RptSalesBillWise  
(  
     [Bill Number]         NVARCHAR(50),  
  [Bill Type]           NVARCHAR(25),  
  [Bill Mode]           NVARCHAR(25),  
  [Bill Date]           DATETIME,  
    [Retailer Name]       NVARCHAR(50),  
  [Gross Amount]        NUMERIC (38,6),  
  [Scheme Disc]         NUMERIC (38,6),  
  [Sales Return]        NUMERIC (38,6),  
  [Replacement]         NUMERIC (38,6),  
  [Discount]            NUMERIC (38,6),  
  [Tax Amount]          NUMERIC (38,6),  
  [Credit Adjustmant]   NUMERIC (38,6),  
  [Debit Adjustment]    NUMERIC (38,6),  
  [Net Amount]          NUMERIC (38,6),  
  [DlvStatus]       INT  
)  
SET @TblName = 'RptSalesBillWise'  
SET @TblStruct = '     [Bill Number]         NVARCHAR(50),  
  [Bill Type]           NVARCHAR(25),  
  [Bill Mode]           NVARCHAR(25),  
  [Bill Date]           DATETIME,  
    [Retailer Name]       NVARCHAR(50),  
  [Gross Amount]   NUMERIC (38,6),  
  [Scheme Disc]         NUMERIC (38,6),  
  [Sales Return]        NUMERIC (38,6),  
  [Replacement]         NUMERIC (38,6),  
  [Discount]            NUMERIC (38,6),  
  [Tax Amount]          NUMERIC (38,6),  
  [Credit Adjustmant]   NUMERIC (38,6),  
  [Debit Adjustment]    NUMERIC (38,6),  
  [Net Amount]          NUMERIC (38,6),  
  [DlvStatus]       INT'  
SET @TblFields = '[Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
  [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
  [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus]'  
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
   
 PRINT @CtgLevelId   
 IF @FromBillNo <> 0 AND @TOBillNo <> 0  
 BEGIN  
         PRINT 'A'  
  IF @CtgLevelId=1  
  BEGIN   
   IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='TempRetailerCategory')  
    BEGIN       
     DROP TABLE TempRetailerCategory  
    END   
    SELECT * INTO TempRetailerCategory FROM RetailerCategory   
     WHERE CtgLinkId IN (SELECT CtgMainId FROM RetailerCategory WHERE CtgLevelId IN (SELECT CtgLevelId FROM RetailerCategoryLevel   
      WHERE CtgLevelId=1) AND CtgMainId=(CASE @CtgMainId WHEN 0 THEN CtgMainId ELSE 0 END) OR  
       CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
    
   INSERT INTO #RptSalesBillWise([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
    [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
    [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus])  
   SELECT [Bill Number],[Bill Type],[Bill Mode],[Bill Date],  
      [Retailer Name],[Gross Amount],[Scheme Disc]  
     ,[Sales Return], [Replacement],[Discount],[Tax Amount],[Credit Adjustment]  
     ,[Debit Adjustment],[Net Amount],[DlvSts]  
    FROM view_SalesBillWise A  
   INNER JOIN (  
   SELECT DISTINCT R.Rtrid FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK)  
   ,TempRetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL  
   WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId  
   AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId  
--   AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
--   RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
--   AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
--   RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
   AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
   RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
   AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR  
   RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
     )X On  X.Rtrid=A.RTRId    
     WHERE (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR  
       A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
     AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
       RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
    AND (LcnId=(CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
       LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
         
     AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
       SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
         
     AND ([BillTypeId] =(CASE @BillType WHEN 0 THEN [BillTypeId] ELSE 0 END) OR  
       [BillTypeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,17,@Pi_UsrId)))  
         
     AND ([BillModeId]=(CASE @BillMode WHEN 0 THEN [BillModeId] ELSE 0 END) OR  
       [BillModeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,33,@Pi_UsrId)))  
   AND (DlvSts=(CASE @BillStatus WHEN 0 THEN DlvSts ELSE @BillStatus END))   
    
     AND ([Bill Date] Between @FromDate and @ToDate)  
    
     AND (SalId Between @FromBillNo and @TOBillNo)  
  END  
        ELSE  
        BEGIN   
   INSERT INTO #RptSalesBillWise([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
    [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
    [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus])  
   SELECT [Bill Number],[Bill Type],[Bill Mode],[Bill Date],  
      [Retailer Name],[Gross Amount],[Scheme Disc]  
     ,[Sales Return], [Replacement],[Discount],[Tax Amount],[Credit Adjustment]  
     ,[Debit Adjustment],[Net Amount],[DlvSts]  
    FROM view_SalesBillWise A  
   INNER JOIN (  
   SELECT DISTINCT R.Rtrid FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK)  
   ,RetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL  
   WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId  
   AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId  
   AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
   RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
   AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
   RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
   AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
   RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
   AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR  
   RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
     )X On  X.Rtrid=A.RTRId    
     WHERE (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR  
       A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
     AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
       RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
    AND (LcnId=(CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
       LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
         
     AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
       SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
         
     AND ([BillTypeId] =(CASE @BillType WHEN 0 THEN [BillTypeId] ELSE 0 END) OR  
       [BillTypeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,17,@Pi_UsrId)))  
         
     AND ([BillModeId]=(CASE @BillMode WHEN 0 THEN [BillModeId] ELSE 0 END) OR  
       [BillModeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,33,@Pi_UsrId)))  
   AND (DlvSts=(CASE @BillStatus WHEN 0 THEN DlvSts ELSE @BillStatus END))   
    
     AND ([Bill Date] Between @FromDate and @ToDate)  
    
     AND (SalId Between @FromBillNo and @TOBillNo)  
  END   
 END  
 ELSE  
 BEGIN  
  PRINT 'B'  
  IF @CtgLevelId=1  
  BEGIN   
   IF EXISTS (SELECT * FROM sysobjects WHERE xtype='U' AND name='TempRetailerCategory')  
    BEGIN       
     DROP TABLE TempRetailerCategory  
    END   
    SELECT * INTO TempRetailerCategory FROM RetailerCategory   
     WHERE CtgLinkId IN (SELECT CtgMainId FROM RetailerCategory WHERE CtgLevelId IN (SELECT CtgLevelId FROM RetailerCategoryLevel   
      WHERE CtgLevelId=1) AND CtgMainId=(CASE @CtgMainId WHEN 0 THEN CtgMainId ELSE 0 END) OR  
       CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
    
   INSERT INTO #RptSalesBillWise([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
    [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
    [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus])  
   SELECT [Bill Number],[Bill Type],[Bill Mode],[Bill Date],  
      [Retailer Name],[Gross Amount],[Scheme Disc]  
     ,[Sales Return], [Replacement],[Discount],[Tax Amount],[Credit Adjustment]  
     ,[Debit Adjustment],[Net Amount],[DlvSts]  
     from view_SalesBillWise A  
   INNER JOIN (  
   SELECT DISTINCT R.Rtrid FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK)  
   ,TempRetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL  
   WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId  
   AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId  
--   AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
--   RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
--   AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
--   RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
   AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
   RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
   AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR  
   RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
     )X On  X.Rtrid=A.RTRId   
    
     WHERE (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR  
       A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
         
     AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
       RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
    AND (LcnId=(CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
       LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
         
     AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
       SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
         
     AND ([BillTypeId] =(CASE @BillType WHEN 0 THEN [BillTypeId] ELSE 0 END) OR  
       [BillTypeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,17,@Pi_UsrId)))  
         
     AND ([BillModeId]=(CASE @BillMode WHEN 0 THEN [BillModeId] ELSE 0 END) OR  
       [BillModeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,33,@Pi_UsrId)))  
     AND ([DlvSts]=(CASE @BillStatus WHEN 0 THEN [DlvSts] ELSE 0 END) OR  
       [DlvSts] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,192,@Pi_UsrId)))  
    
     AND ([Bill Date] Between @FromDate and @ToDate)  
  END   
  ELSE  
  BEGIN   
   INSERT INTO #RptSalesBillWise([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
    [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
    [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus])  
   SELECT [Bill Number],[Bill Type],[Bill Mode],[Bill Date],  
      [Retailer Name],[Gross Amount],[Scheme Disc]  
     ,[Sales Return], [Replacement],[Discount],[Tax Amount],[Credit Adjustment]  
     ,[Debit Adjustment],[Net Amount],[DlvSts]  
     from view_SalesBillWise A  
   INNER JOIN (  
   SELECT DISTINCT R.Rtrid FROM Retailer R WITH (NOLOCK),RetailerValueClassMap RVCM WITH (NOLOCK),RetailerValueClass RVC WITH (NOLOCK)  
   ,RetailerCategory RC WITH (NOLOCK),RetailerCategoryLevel RCL  
   WHere  R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId  
   AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId  
   AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
   RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))  
   AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
   RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))  
   AND (RVC.RtrClassId=(CASE @RtrClassId WHEN 0 THEN RVC.RtrClassId ELSE 0 END) OR  
   RVC.RtrClassId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,31,@Pi_UsrId)))  
   AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR  
   RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))  
     )X On  X.Rtrid=A.RTRId   
    
     WHERE (A.RtrId = (CASE @RtrId WHEN 0 THEN A.RtrId ELSE 0 END) OR  
       A.RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,3,@Pi_UsrId)))  
         
     AND (RMId=(CASE @RMId WHEN 0 THEN RMId ELSE 0 END) OR  
       RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,2,@Pi_UsrId)))  
    AND (LcnId=(CASE @LcnId WHEN 0 THEN LcnId ELSE 0 END) OR  
       LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,22,@Pi_UsrId)))  
         
     AND (SMId=(CASE @SMId WHEN 0 THEN SMId ELSE 0 END) OR  
       SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,1,@Pi_UsrId)))  
         
     AND ([BillTypeId] =(CASE @BillType WHEN 0 THEN [BillTypeId] ELSE 0 END) OR  
       [BillTypeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,17,@Pi_UsrId)))  
         
     AND ([BillModeId]=(CASE @BillMode WHEN 0 THEN [BillModeId] ELSE 0 END) OR  
       [BillModeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,33,@Pi_UsrId)))  
     AND ([DlvSts]=(CASE @BillStatus WHEN 0 THEN [DlvSts] ELSE 0 END) OR  
       [DlvSts] in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,192,@Pi_UsrId)))  
    
     AND ([Bill Date] Between @FromDate and @ToDate)  
  END    
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
    
  SET @SSQL = 'INSERT INTO #RptSalesBillWise ' +  
   '(' + @TblFields + ')' +  
   ' SELECT ' + @TblFields + ' FROM ['  + @PurDBName + '].dbo.' + @TblName +  
     
   'WHERE (RtrId = (CASE ' +  CAST(@RtrId AS INTEGER) + ' WHEN 0 THEN RtrId ELSE 0 END) OR  
     RtrId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',3,' + CAST(@Pi_UsrId as INTEGER) +')))  
       
            AND (RMId=(CASE ' + CAST(@RMId AS INTEGER) + ' WHEN 0 THEN RMId ELSE 0 END) OR  
     RMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',2,' + CAST(@Pi_UsrId as INTEGER) +')))  
       
            AND (SMId=(CASE '+ CAST(@SMId AS INTEGER) + 'WHEN 0 THEN SMId ELSE 0 END) OR  
     SMId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',1,' + CAST(@Pi_UsrId as INTEGER) + ')))  
    AND (LcnId=(CASE '+ CAST(@LcnId AS INTEGER) + 'WHEN 0 THEN LcnId ELSE 0 END) OR  
     LcnId in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',22,' + CAST(@Pi_UsrId as INTEGER) + ')))  
       
            AND ([BillTypeId] =(CASE ' + CAST(@BillType AS INTEGER) + ' WHEN 0 THEN [BillTypeId] ELSE 0 END) OR  
     [BillTypeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) + ',17,' + CAST(@Pi_UsrId as INTEGER) +')))  
       
            AND ([BillModeId]=(CASE ' + CAST(@BillMode AS INTEGER) + 'WHEN 0 THEN [BillModeId] ELSE 0 END) OR  
     [BillModeId] in (SELECT iCountid FROM Fn_ReturnRptFilters(' + CAST(@Pi_RptId as INTEGER) +',33,' + CAST(@Pi_UsrId as INTEGER) + ')))  
            AND ([Bill Date] Between ' + @FromDate +' and ' + @ToDate + ')  
            AND (SalId Between ' + @FromBillNo +' and ' + @TOBillNo +')'  
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
    ' ,' + CAST(@Pi_RptId AS VARCHAR(10)) + ', * FROM #RptSalesBillWise'  
   
   EXEC (@SSQL)  
   PRINT 'Saved Data Into SnapShot Table'  
     END  
    END  
   END  
ELSE    --To Retrieve Data From Snap Data  
   BEGIN  
 EXEC Proc_SnapShot_Report @Pi_SnapId,@Pi_UsrId,@Pi_RptId,@Pi_DbName,@TblName,@TblStruct,  
   @Pi_GetFromSnap,@Po_SnapErrno = @ErrNo OUTPUT  
 PRINT @ErrNo  
 IF @ErrNo = 0  
    BEGIN  
  SET @SSQL = 'INSERT INTO #RptSalesBillWise ' +  
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
SELECT @Pi_RptId,Count(*) as RecCount,@ErrNo,@Pi_UsrId FROM #RptSalesBillWise  
-- Till Here  
 IF (@BillStatus=3 AND  @CancelValue=1) OR (@BillStatus=0 AND  @CancelValue=1)  
 BEGIN  
  UPDATE #RptSalesBillWise SET [Gross Amount]=0,[Scheme Disc]=0,[Sales Return]=0,[Replacement]=0,[Discount]=0,  
    [Tax Amount]=0,[Credit Adjustmant]=0,[Debit Adjustment]=0,[Net Amount]=0  
    WHERE [DlvStatus]=3  
 END  
 IF EXISTS (SELECT Flag FROM RptExcelFlag WITH(NOLOCK) WHERE RptID = @Pi_RptID AND UsrId=@Pi_UsrId AND Flag=1)  
 BEGIN  
  IF EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[RptSalesBillWise_Excel]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
  DROP TABLE RptSalesBillWise_Excel  
    
  CREATE TABLE RptSalesBillWise_Excel  
  (  
     [Bill Number]         NVARCHAR(50),  
  [Bill Type]           NVARCHAR(25),  
  [Bill Mode]           NVARCHAR(25),  
  [Bill Date]           DATETIME,  
        [Retailer Code]       NVARCHAR(50),  
    [Retailer Name]       NVARCHAR(150),  
  [Gross Amount]        NUMERIC (38,6),  
  [Scheme Disc]         NUMERIC (38,6),  
  [Sales Return]        NUMERIC (38,6),  
  [Replacement]         NUMERIC (38,6),  
  [Discount]            NUMERIC (38,6),  
  [Tax Amount]          NUMERIC (38,6),  
  [WindowDisplayAmount] NUMERIC (38,6),  
  [Credit Adjustmant]   NUMERIC (38,6),  
  [Debit Adjustment]    NUMERIC (38,6),  
  [Net Amount]          NUMERIC (38,6),  
  [DlvStatus]       INT  
  )  
    
  INSERT INTO RptSalesBillWise_Excel ([Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
  [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
  [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus])  
   SELECT  [Bill Number],[Bill Type],[Bill Mode],[Bill Date],[Retailer Name],  
    [Gross Amount],[Scheme Disc],[Sales Return],[Replacement],[Discount],  
    [Tax Amount],[Credit Adjustmant],[Debit Adjustment],[Net Amount],[DlvStatus] FROM #RptSalesBillWise  Order by [Bill Date],[Bill Number]
  UPDATE RPT SET RPT.[Retailer Code]=R.RtrCode FROM RptSalesBillWise_Excel RPT,Retailer R,SalesINvoice SI WHERE RPT.[Retailer Name]=R.RtrName  
  AND SI.SalInvNo=RPT.[Bill NUmber] AND R.RtrId=SI.RtrId  
       UPDATE RPT SET RPT.[WindowDisplayAmount]=R.[WindowDisplayAmount] FROM RptSalesBillWise_Excel RPT,SalesInvoice R WHERE RPT.[Bill Number]=R.SalInvNo  
 END   
    DELETE FROM #RptSalesBillWise WHERE [Gross Amount]=0 AND [Scheme Disc]=0 AND [Sales Return]=0 AND [Replacement]=0 AND [Discount]=0 AND   
    [Tax Amount]=0 AND [Credit Adjustmant]=0 AND [Debit Adjustment]=0 AND [Net Amount]=0  
 SELECT * FROM #RptSalesBillWise  Order by [Bill Date],[Bill Number]
 RETURN  
END
GO
--PARLE Purchase Receipt Freight Amount CR
IF NOT EXISTS (SELECT A.Name FROM SysColumns A WITH(NOLOCK) INNER JOIN Sysobjects B WITH(NOLOCK) ON A.id = B.id AND B.xtype = 'U' 
AND B.name = 'ETL_Prk_PurchaseReceiptClaim' AND A.Name = 'FreightAmt')
BEGIN
   ALTER TABLE ETL_Prk_PurchaseReceiptClaim ADD FreightAmt NUMERIC(18,6) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS (SELECT A.Name FROM SysColumns A WITH(NOLOCK) INNER JOIN Sysobjects B WITH(NOLOCK) ON A.id = B.id AND B.xtype = 'U' 
AND B.name = 'ETLTempPurchaseReceiptClaimScheme' AND A.Name = 'FreightAmt')
BEGIN
   ALTER TABLE ETLTempPurchaseReceiptClaimScheme ADD FreightAmt NUMERIC(18,6) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS (SELECT A.Name FROM SysColumns A WITH(NOLOCK) INNER JOIN Sysobjects B WITH(NOLOCK) ON A.id = B.id AND B.xtype = 'U' 
AND B.name = 'PurchaseReceiptClaimScheme' AND A.Name = 'FreightAmt')
BEGIN
   ALTER TABLE PurchaseReceiptClaimScheme ADD FreightAmt NUMERIC(18,6) DEFAULT 0 WITH VALUES
END
GO
IF NOT EXISTS (SELECT A.Name FROM SysColumns A WITH(NOLOCK) INNER JOIN Sysobjects B WITH(NOLOCK) ON A.id = B.id AND B.xtype = 'U' 
AND B.name = 'PurchaseReturnClaimScheme' AND A.Name = 'FreightAmt')
BEGIN
   ALTER TABLE PurchaseReturnClaimScheme ADD FreightAmt NUMERIC(18,6) DEFAULT 0 WITH VALUES
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Validate_PurchaseReceiptClaimScheme')
DROP PROCEDURE Proc_Validate_PurchaseReceiptClaimScheme
GO
--Exec Proc_Validate_PurchaseReceiptClaimScheme 0
--SELECT * FROM ETL_Prk_PurchaseReceiptClaim
--SELECT * FROM ETLTempPurchaseReceiptClaimScheme
CREATE PROCEDURE Proc_Validate_PurchaseReceiptClaimScheme
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
	DECLARE @FreightAmt		AS 	NUMERIC(38,6)
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
	ISNULL([Amount],0),ISNULL([FreightAmt],0) FROM ETL_Prk_PurchaseReceiptClaim WITH(NOLOCK)
	OPEN Cur_PurchaseReceiptClaim 
	FETCH NEXT FROM Cur_PurchaseReceiptClaim INTO @CmpInvNo,@Type,@RefCode,@PrdCode,@PrdBatCode,
	@Qty,@StockType,@Amt,@FreightAmt
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
			INSERT INTO ETLTempPurchaseReceiptClaimScheme(CmpInvNo,TypeId,RefCode,RefId,RefDescription,PrdId,
			PrdBatId,StockTypeId,Qty,Amt,FreightAmt)
			VALUES(@CmpInvNo,@TypeId,@RefCode,@RefId,@RefDesc,@PrdId,@PrdBatId,@stockTypeId,@Qty,@Amt,@FreightAmt)
		END
			
		IF @Po_ErrNo<>0
		BEGIN
			CLOSE Cur_PurchaseReceiptClaim
			DEALLOCATE Cur_PurchaseReceiptClaim
			RETURN
		END
		FETCH NEXT FROM Cur_PurchaseReceiptClaim INTO @CmpInvNo,@Type,@RefCode,@PrdCode,@PrdBatCode,
		@Qty,@StockType,@Amt,@FreightAmt
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
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_Cn2Cs_PurchaseReceipt')
DROP PROCEDURE Proc_Cn2Cs_PurchaseReceipt
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_PurchaseReceipt 0
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_Cn2Cs_PurchaseReceipt
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
14/08/2013 Murugan.R	Logistic Material Management
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
    DELETE FROM ETLTempPurchaseReceiptOtherCharges WHERE CmpInvNo in
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)	
	DELETE FROM Etl_LogisticMaterialStock WHERE InvoiceNumber IN 
	(SELECT CmpInvNo FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1)
	DELETE FROM ETLTempPurchaseReceipt  WHERE DownLoadStatus=1
	DELETE FROM ETLTempPurchaseReceiptCrDbAdjustments WHERE CmpInvNo 
	IN (SELECT CmpInvNo FROM PurchaseReceipt WHERE Status = 1) AND DownloadStatus = 1
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt
	TRUNCATE TABLE ETL_Prk_PurchaseReceiptClaim
	TRUNCATE TABLE ETL_Prk_PurchaseReceipt
    TRUNCATE TABLE ETLTempPurchaseReceiptPrdLineDt
    TRUNCATE TABLE ETL_Prk_PurchaseReceiptPrdDt
    TRUNCATE TABLE ETL_Prk_PurchaseReceiptOtherCharges
    TRUNCATE TABLE ETL_Prk_PurchaseReceiptCrDbAdjustments
	--------------------------------------
	DECLARE @ErrStatus			INT
	DECLARE @BatchNo			NVARCHAR(200)
	DECLARE @ProductCode		NVARCHAR(100)
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
	DECLARE @QtyInKg			NUMERIC(38,6)
	DECLARE @ExistCompInvNo		NVARCHAR(25)
	DECLARE @FreightCharges		NUMERIC(38,6)
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
	WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt))
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','CmpInvNo','Company Invoice No:'+CompInvNo+' already downloaded and ready for invoicing' FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvNo IN (SELECT CmpInvNo FROM ETLTempPurchaseReceipt)
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
	--Supplier Credit Note Validations 
	IF EXISTS(SELECT DISTINCT [CompInvNo] FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN
	(SELECT DISTINCT PostedRefNo FROM CreditNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Credit')
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
        SELECT DISTINCT [CompInvNo] FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN
	   (SELECT DISTINCT PostedRefNo FROM CreditNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Credit'
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'CreditNoteSupplier','PostedRefNo','Supplier Credit Note Not Available'+[CompInvNo]
		FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN 
		(SELECT DISTINCT PostedRefNo FROM CreditNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Credit'		
	END
	--Supplier Debit Note Validations 
	IF EXISTS(SELECT DISTINCT [CompInvNo] FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN
	(SELECT DISTINCT PostedRefNo FROM DebitNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Debit')
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
        SELECT DISTINCT [CompInvNo] FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN
	   (SELECT DISTINCT PostedRefNo FROM DebitNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Debit'
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'DebitNoteSupplier','PostedRefNo','Supplier Debit Note Not Available'+[CompInvNo]
		FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WHERE [RefNo] NOT IN 
		(SELECT DISTINCT PostedRefNo FROM DebitNoteSupplier WITH (NOLOCK)) AND [AdjType] = 'Debit'		
	END
	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	WHERE CompInvDate>GETDATE())	
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE CompInvDate>GETDATE()
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Invoice Date','Invoice Date:'+CAST(CompInvDate AS NVARCHAR(10))+' is greater than current date in Invoice:'+CompInvNo 
		FROM Cn2Cs_Prk_BLPurchaseReceipt WITH (NOLOCK) WHERE CompInvDate>GETDATE()
	END
	--Commented and Added By Mohana.S PMS NO: DCRSTKAL0012
	--IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	--WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK)))	
	--BEGIN
	--	INSERT INTO InvToAvoid(CmpInvNo)
	--	SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	--	WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))
		
	--	INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
	--	SELECT DISTINCT 1,'Purchase Receipt','Invoice UOM','UOM:'+UOMCode+' is not available for Invoice:'+CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	--	WHERE UOMCode NOT IN (SELECT UOMCode FROM UOMMaster WITH (NOLOCK))
	--END
	IF EXISTS (SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE PRODUCTCODE+'~'+UomCode NOT IN (SELECT PrdCCode+'~'+UomCode  
	FROM UomGroup UG INNER JOIN UomMaster UM ON UG.UomId =UM.UomId INNER JOIN Product P ON P.UomGroupId = UG.UomGroupId))
	BEGIN
		 INSERT INTO InvToAvoid(CmpInvNo)
		 SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE PRODUCTCODE+'~'+UomCode NOT IN (SELECT PrdCCode+'~'+UomCode  
		 FROM UomGroup UG INNER JOIN UomMaster UM ON UG.UomId =UM.UomId INNER JOIN Product P ON P.UomGroupId = UG.UomGroupId)
		 
		 INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		 SELECT DISTINCT 1,'Purchase Receipt',PRODUCTCODE+'Product UOM','UOMCode:'+UOMCode+' is not available for Invoice:'+CompInvNo 
		 FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE PRODUCTCODE+'~'+UomCode  NOT IN (SELECT PrdCCode+'~'+UomCode  
		 FROM UomGroup UG INNER JOIN UomMaster UM ON UG.UomId =UM.UomId INNER JOIN Product P ON P.UomGroupId = UG.UomGroupId)
	END	
	IF EXISTS(SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
	WHERE SupplierCode NOT IN (SELECT SpmCode FROM Supplier WITH (NOLOCK)))	
	BEGIN
		INSERT INTO InvToAvoid(CmpInvNo)
		SELECT DISTINCT CompInvNo FROM Cn2Cs_Prk_BLPurchaseReceipt
		WHERE SupplierCode NOT IN (SELECT SpmCode FROM Supplier WITH (NOLOCK))
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Purchase Receipt','Invoice Supplier','Supplier:'+SupplierCode+' is not available for Invoice:'+CompInvNo
		FROM Cn2Cs_Prk_BLPurchaseReceipt WITH (NOLOCK) WHERE SupplierCode NOT IN (SELECT SpmCode FROM Supplier WITH (NOLOCK))
	END	
	--->Till Here
	SET @ExistCompInvNo=0
	DECLARE Cur_Purchase CURSOR
	FOR
	SELECT ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,CompInvNo,UOMCode,PurQty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,CashDiscRs,0 AS BundleDeal,
	ISNULL(FreightCharges,0) AS FreightCharges
	FROM Cn2Cs_Prk_BLPurchaseReceipt WHERE [DownLoadFlag]='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
	ORDER BY CompInvNo,ProductCode,BatchNo,ListPriceNSP,
	FreeSchemeFlag,UOMCode,PurQty,PurchaseDiscount,VATTaxValue,SchemeRefrNo,LineLevelAmount,CashDiscRs,FreightCharges
	OPEN Cur_Purchase
	FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
	@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
	@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@QtyInKg,@RowId,@FreightCharges	
	WHILE @@FETCH_STATUS = 0
	BEGIN
--		IF @ExistCompInvNo<>@CompInvNo
--		BEGIN
--			SET @ExistCompInvNo=@CompInvNo
--			SET @RowId=2
--		END
		--To insert into ETL_Prk_PurchaseReceiptPrdDt
		IF(@FreeSchemeFlag='0')
		BEGIN
			INSERT INTO  ETL_Prk_PurchaseReceiptPrdDt([Company Invoice No],[RowId],[Product Code],[Batch Code],
			[PO UOM],[PO Qty],[UOM],[Invoice Qty],[Purchase Rate],[Gross],[Discount In Amount],[Tax In Amount],[Net Amount],FreightCharges)
			VALUES(@CompInvNo,@RowId,@ProductCode,@BatchNo,'',0,@UOMCode,@Qty,@ListPrice,@LineLvlAmt,
			@PurchaseDiscount,@VATTaxValue,(@ListPrice-@PurchaseDiscount+@VATTaxValue)* @Qty,@FreightCharges)
			INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])
			VALUES(@CompInvNo,@RowId,'C',@PurchaseDiscount)
			INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])
			VALUES(@CompInvNo,@RowId,'D',@VATTaxValue)
--			INSERT INTO ETL_Prk_PurchaseReceiptPrdLineDt([Company Invoice No],[RowId],[Column Code],[Value In Amount])
--			VALUES(@CompInvNo,@RowId,'E',@QtyInKg)
		END
		--To insert into ETL_Prk_PurchaseReceiptClaim
		IF(@FreeSchemeFlag='1')
		BEGIN
			INSERT INTO ETL_Prk_PurchaseReceiptClaim([Company Invoice No],[Type],[Ref No],[Product Code],
			[Batch Code],[Qty],[Stock Type],[Amount],FreightAmt)
			VALUES(@CompInvNo,'Offer',@SchemeRefrNo,@ProductCode,@BatchNo,@Qty,'Offer',0,@FreightCharges)
		END
--		SET @RowId=@RowId+1
		FETCH NEXT FROM Cur_Purchase INTO @ProductCode,@BatchNo,@ListPrice,
		@FreeSchemeFlag,@CompInvNo,@UOMCode,@Qty,
		@PurchaseDiscount,@VATTaxValue,@SchemeRefrNo,@LineLvlAmt,@QtyInKg,@RowId,@FreightCharges
	END
	CLOSE Cur_Purchase
	DEALLOCATE Cur_Purchase
	--To insert into ETL_Prk_PurchaseReceipt
	SELECT @TransporterCode=TransporterCode FROM Transporter
	WHERE TransporterId IN(SELECT MIN(TransporterId) FROM Transporter WITH(NOLOCK))
	
	IF @TransporterCode=''
	BEGIN
		INSERT INTO Errorlog VALUES (1,'Purchase Download','Transporter','Transporter not available')
	END
	
	INSERT INTO ETL_Prk_PurchaseReceipt([Company Code],[Supplier Code],[Company Invoice No],[PO Number],
	[Invoice Date],[Transporter Code],[NetPayable Amount])
	SELECT DISTINCT C.CmpCode,SupplierCode,P.CompInvNo,'',P.CompInvDate,@TransporterCode,P.NetValue
	FROM Company C,Cn2Cs_Prk_BLPurchaseReceipt P
	WHERE  C.DefaultCompany=1 AND DownLoadFlag='D' AND CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid)
	
	--Added By Sathishkumar Veeramani 2013/08/13
	--INSERT INTO ETL_Prk_PurchaseReceiptOtherCharges ([Company Invoice No],[OC Description],Amount)
	--SELECT DISTINCT CompInvNo,'Cash Discounts' AS [OC Description],CashDiscRs FROM Cn2Cs_Prk_BLPurchaseReceipt WITH (NOLOCK)
	--WHERE CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid) AND DownLoadFlag='D'
	
	--Added by Sathishkumar Veeramani 2013/11/22
	INSERT INTO ETL_Prk_PurchaseReceiptCrDbAdjustments([Company Invoice No],[Adjustment Type],[Ref No],[Amount])
	SELECT DISTINCT CompInvNo,AdjType,RefNo,Amount FROM Cn2Cs_Prk_PurchaseReceiptAdjustments WITH (NOLOCK)
	WHERE CompInvNo NOT IN(SELECT CmpInvNo FROM InvToAvoid) AND DownLoadFlag='D'

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
				   EXEC Proc_Validate_PurchaseReceiptOtherCharges @Po_ErrNo= @ErrStatus OUTPUT
				   IF @ErrStatus =0
				   BEGIN
				       EXEC Proc_Validate_PurchaseReceiptCrDbAdjustments @Po_ErrNo= @ErrStatus OUTPUT
				       IF @ErrStatus =0
				       BEGIN
					       SET @ErrStatus=@ErrStatus
					   END    
				   END	   
				END
			END
		END
	END
	--Proc_Validate_PurchaseReceiptCrDbAdjustments
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
DELETE FROM CustomCaptions WHERE TransId = 153 AND CtrlId = 6 AND SubCtrlId = 18
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,
LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 153,6,18,'sprPurClmSch-153-7-18','Freight Amount','','',1,1,1,GETDATE(),1,GETDATE(),'Freight Amount','','',1,1
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND NAME='Fn_ReturnPurchaseClaimScheme')
DROP FUNCTION Fn_ReturnPurchaseClaimScheme
GO
--SELECT DISTINCT * FROM Dbo.Fn_ReturnPurchaseClaimScheme(36)
CREATE FUNCTION dbo.Fn_ReturnPurchaseClaimScheme (@Pi_PurRcptId AS BIGINT)
RETURNS @ReturnPurchaseClaimScheme TABLE
(
    TypeId           INT,
    [Type]           NVARCHAR(200),
    RefId            INT,
    RefCode          NVARCHAR(200),
    SlNo             INT,
    [Description]    NVARCHAR(200),
    PrdId            NUMERIC(18,0),
    PrdName          NVARCHAR(200),
    PrdBatId         NUMERIC(18,0),
    PrdBatCode       NVARCHAR(200),
    Quantity         NUMERIC(18,0),
    StockTypeId      INT,
    UserStockType    NVARCHAR(200),
    RateforClaim     NUMERIC(18,6),
    Value            NUMERIC(18,6),
    Amount           NUMERIC(18,6),
    FreightAmt       NUMERIC(18,6)  
)
AS
BEGIN
/**********************************************************
* FUNCTION    : Fn_ReturnPurchaseClaimScheme
* PURPOSE     : Returns the Purchase Receipt Claim Scheme 
* NOTES: 
* CREATED     : Sathishkumar Veeramani 2014/06/20
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------------------
* 
************************************************************/
    INSERT INTO @ReturnPurchaseClaimScheme (TypeId,[Type],RefId,RefCode,SlNo,[Description],PrdId,PrdName,PrdBatId,PrdBatCode,
    Quantity,StockTypeId,UserStockType,RateforClaim,Value,Amount,FreightAmt)
	SELECT DISTINCT TypeId, 'Claim' AS Type,RefId,RefCode,PCS.SlNo,ClmDesc AS Description,pcs.PrdId,ISNULL(PrdName,'') AS PrdName,
	pcs.PrdBatId,ISNULL(PrdBatCode,'') AS PrdBatCode,Quantity,pcs.StockTypeId,UserStockType,RateforClaim,Value,Amount,FreightAmt  
	FROM PurchASereceiptclaimscheme PCS  LEFT OUTER JOIN  Product P ON P.PrdId = pcs.prdid  
	LEFT OUTER JOIN  productbatch pb ON p.prdid = pb.prdid AND pcs.prdid = pb.prdid AND pcs.prdbatid = pb.prdbatid   
	INNER JOIN stocktype s ON s.stocktypeid = pcs.stocktypeid INNER JOIN claimsheethd ch ON pcs.RefId = ch.clmid 
	INNER JOIN claimsheetDetail cd ON ch.clmid = cd.clmid  AND  PCS.SlNo=cd.SlNo  WHERE Typeid = 1 AND PurRcptId = @Pi_PurRcptId  UNION 
	SELECT TypeId, 'Scheme' AS Type, RefId, SchCode AS RefCode,0 AS SlNo,SchDsc AS Description, pcs.PrdId,
	ISNULL(PrdName,'') AS PrdName,pcs.PrdBatId,ISNULL(PrdBatCode,'') AS PrdBatCode,Quantity,Pcs.StockTypeId, 
	UserStockType,RateforClaim ,Value,Amount,FreightAmt FROM purchASereceiptclaimscheme PCS  LEFT OUTER JOIN  Product P ON  P.PrdId = pcs.prdid 
	LEFT OUTER JOIN  productbatch pb ON p.prdid = pb.prdid AND pcs.prdbatid = pb.prdbatid 
	AND  pcs.prdid = pb.prdid INNER JOIN stocktype s ON s.stocktypeid = pcs.stocktypeid  
	INNER JOIN SchememASter  ch ON pcs.RefId = ch.schid  Where Typeid = 2  AND PurRcptId = @Pi_PurRcptId UNION 
	SELECT DISTINCT TypeId, 'Offer' AS Type, RefId,'' AS RefCode,0 AS SlNo,'' AS Description, pcs.PrdId,ISNULL(PrdName,'') AS  PrdName, 
	pcs.PrdBatId,ISNULL(PrdBatCode,'') AS PrdBatCode,Quantity, pcs.StockTypeId, UserStockType,RateforClaim,Value,Amount,FreightAmt 
	FROM purchASereceiptclaimscheme PCS  LEFT OUTER JOIN  Product P ON  P.PrdId = pcs.prdid 
	LEFT OUTER JOIN productbatch pb ON p.prdid = pb.prdid AND pcs.prdbatid = pb.prdbatid 
	AND PCS.PrdId = pb.prdid INNER JOIN Stocktype s ON s.stocktypeid = pcs.stocktypeid  WHERE Typeid = 3 AND PurRcptId = @Pi_PurRcptId
RETURN
END
GO
--Purchase Return
DELETE FROM CustomCaptions WHERE TransId = 147 AND CtrlId = 2 AND SubCtrlId = 18
INSERT INTO CustomCaptions (TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,
LastModDate,AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
SELECT 147,2,18,'sprPurClmSch-147-5-18','Freight Amount','','',1,1,1,GETDATE(),1,GETDATE(),'Freight Amount','','',1,1
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE IN ('TF','FN') AND NAME='Fn_ReturnPurchaseReturnClaimScheme')
DROP FUNCTION Fn_ReturnPurchaseReturnClaimScheme
GO
--SELECT DISTINCT * FROM Dbo.Fn_ReturnPurchaseReturnClaimScheme(215,2)
CREATE FUNCTION dbo.Fn_ReturnPurchaseReturnClaimScheme (@Pi_PurRcptId AS BIGINT, @TransId AS INT)
RETURNS @ReturnPurchaseReturnClaimScheme TABLE
(
    RefId            INT,
    PrdId            NUMERIC(18,0),
    PrdName          NVARCHAR(200),
    PrdBatId         NUMERIC(18,0),
    PrdBatCode       NVARCHAR(200),
    StockTypeId      INT,
    UserStockType    NVARCHAR(200),
    Quantity         NUMERIC(18,0),
    RetQty           NUMERIC(18,0),    
    Value            NUMERIC(18,6),
    RetValue         NUMERIC(18,6),
    Amount           NUMERIC(18,6),
    RetAmount        NUMERIC(18,6),
    TypeId           INT,
    RateforClaim     NUMERIC(18,6),
    FreightAmt       NUMERIC(18,6)  
)
AS
BEGIN
/**********************************************************
* FUNCTION    : Fn_ReturnPurchaseReturnClaimScheme
* PURPOSE     : Returns the Purchase Return Claim Scheme 
* NOTES: 
* CREATED     : Sathishkumar Veeramani 2014/06/23
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------------------
* 
************************************************************/
IF @TransId = 2
BEGIN
    INSERT INTO @ReturnPurchaseReturnClaimScheme (RefId,PrdId,PrdName,PrdBatId,PrdBatCode,StockTypeId,UserStockType,
    Quantity,RetQty,Value,RetValue,Amount,RetAmount,TypeId,RateForClaim,FreightAmt)
    SELECT PRS.RefId,PRS.PrdId,ISNULL(P.PrdName,'') AS PrdName,PRS.PrdBatId,ISNULL(PB.PrdBatCode,'') AS PrdBatCode,
	PRS.StockTypeId,S.UserStocktype,PRS.Quantity,PRS.RetQuantity AS RetQty,PRS.Value,0 AS RetValue,PRS.Amount,PRS.RetAmount,
	PRS.TypeId,PRS.RateForClaim,PRS.FreightAmt 
	FROM PurchaseReceiptClaimScheme PRS WITH (NOLOCK) 
	LEFT OUTER JOIN Product P WITH (NOLOCK) ON PRS.PrdId=P.PrdId 
	LEFT OUTER JOIN ProductBatch PB WITH (NOLOCK) ON PRS.PrdBatId=PB.PrdBatId 
	INNER JOIN StockType S WITH (NOLOCK) ON PRS.StockTypeId = S.StockTypeId WHERE PRS.PurRcptId = @Pi_PurRcptId
END
ELSE IF @TransId = 1
BEGIN	
	INSERT INTO @ReturnPurchaseReturnClaimScheme (RefId,PrdId,PrdName,PrdBatId,PrdBatCode,StockTypeId,UserStockType,
    Quantity,RetQty,Value,RetValue,Amount,RetAmount,TypeId,RateForClaim,FreightAmt)	
	SELECT PRS.RefId,PRS.PrdId,ISNULL(P.PrdName,'') AS PrdName,PRS.PrdBatId,ISNULL(PB.PrdBatCode,'') AS PrdBatCode,PRS.StockTypeId,
	S.UserStocktype,PRS.Quantity,PRS.RetQty,PRS.Value,0 AS RetValue,PRS.Amount,PRS.RetAmount,PRS.TypeId,0 AS RateForClaim,PRS.FreightAmt            
	FROM PurchaseReturnClaimScheme PRS WITH (NOLOCK) 
	LEFT OUTER JOIN Product P WITH (NOLOCK) ON PRS.PrdId=P.PrdId 
	LEFT OUTER JOIN ProductBatch PB WITH (NOLOCK) ON PRS.PrdBatId=PB.PrdBatId 
	INNER JOIN StockType S WITH (NOLOCK) ON PRS.StockTypeId = S.StockTypeId WHERE PRS.PurRetId =  @Pi_PurRcptId
END	
RETURN
END
GO
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='Proc_VoucherPostingPurchase')
DROP PROCEDURE Proc_VoucherPostingPurchase
GO
/*
BEGIN TRANSACTION
--EXEC Proc_VoucherPostingPurchase 5,1,'GRN14000217',5,0,1,'2014-06-22',0
EXEC Proc_VoucherPostingPurchase 7,1,'PRT14000002',5,0,1,'2014-06-23',0
select * from StdVocDetails (nolock) Where VocRefNo = 'PUR1400246'
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_VoucherPostingPurchase
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
		
		DECLARE @Amt1 AS NUMERIC(38,6)
		SELECT @Amt1=LessScheme FROM PurchaseReceipt WHERE PurRcptRefNo = @Pi_ReferNo
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate) VALUES
		(@VocRefNo,@CoaId,1,@Amt-@Amt1,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
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
		
		--Added by Sathishkumar Veeramani 2013/11/26	
		SELECT @DiffAmt=ISNULL((SUM(A.TotalAddition)-(SUM(B.Amount)+SUM(C.Amount)+SUM(A.CrAdjustAmt))),0)
		FROM PurchaseReceipt A,(SELECT SUM(Amount) AS Amount FROM #PurTaxForDiff)B,#PurTotAdd C
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
		SELECT @VocRefNo AS VocRefNo,D.CoaId,2 AS DebitCredit,B.BaseQtyAmount AS Amount,1 AS Availability,
			@Pi_UserId AS LastModBy,Convert(varchar(10),Getdate(),121) AS LastModDate,
			@Pi_UserId AS AuthId,Convert(varchar(10),Getdate(),121) AS AuthDate
		INTO #PurRetTotAdd
		FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
			A.PurRetId = B.PurRetId
		INNER JOIN PurchaseSequenceMaster C ON A.PurSeqId = C.PurSeqId
		INNER JOIN PurchaseSequenceDetail D ON C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
		WHERE A.PurRetRefNo = @Pi_ReferNo AND B.RefCode <> 'D' AND	EffectInNetAmount = 1 AND B.BaseQtyAmount > 0
			
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,LastModDate,AuthId,AuthDate)
		SELECT * FROM #PurRetTotAdd
		--INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		--	LastModDate,AuthId,AuthDate)
		--SELECT @VocRefNo,D.CoaId,2,B.BaseQtyAmount,1,@Pi_UserId,Convert(varchar(10),Getdate(),121),
		--	@Pi_UserId,Convert(varchar(10),Getdate(),121)
		--	FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
		--		A.PurRetId = B.PurRetId
		--	INNER JOIN PurchaseSequenceMaster C ON
		--		A.PurSeqId = C.PurSeqId
		--	INNER JOIN PurchaseSequenceDetail D ON
		--		C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
		--	WHERE A.PurRetRefNo = @Pi_ReferNo AND B.RefCode <> 'D' AND
		--		EffectInNetAmount = 1 AND B.BaseQtyAmount > 0
		--SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		--	LastModDate,AuthId,AuthDate)
		--SELECT ''' + @VocRefNo + ''',D.CoaId,2,B.BaseQtyAmount,1,' +
		--	CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		--	+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		--	 FROM PurchaseReturn A INNER JOIN PurchaseReturnHdAmount B ON
		--		A.PurRetId = B.PurRetId
		--	INNER JOIN PurchaseSequenceMaster C ON
		--		A.PurSeqId = C.PurSeqId
		--	INNER JOIN PurchaseSequenceDetail D ON
		--		C.PurSeqId = D.PurSeqId AND B.RefCode = D.RefCode
		--	WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + ''' AND B.RefCode <> ''' + 'D' + ''' AND
		--		EffectInNetAmount = 1 AND B.BaseQtyAmount > 0'
		--INSERT INTO Translog(strSql1) Values (@sstr)
		
		--For Posting Purchase Return Tax Account in Details Table on Debit
		SELECT @VocRefNo AS VocRefNo,C.InputTaxId,2 AS DebitCredit,ISNULL(SUM(B.TaxAmount),0) AS Amount,1 AS Availability,
		@Pi_UserId AS LastModBy,Convert(varchar(10),Getdate(),121) AS LastModDate,@Pi_UserId AS AuthId,
		Convert(varchar(10),Getdate(),121) AS AuthDate	INTO #PurRetnTaxForDiff
		FROM PurchaseReturn A INNER JOIN PurchaseReturnProductTax B ON A.PurRetId = B.PurRetId
		INNER JOIN TaxConfiguration C ON B.TaxId = C.TaxId
		WHERE A.PurRetRefNo = @Pi_ReferNo GROUP BY C.InputTaxId HAVING ISNULL(SUM(B.TaxAmount),0) > 0
		
		
		--Added by Sathishkumar Veeramani 2013/11/26	
		SELECT @DiffAmt=ISNULL((SUM(A.TotalAddition)-(SUM(B.Amount)+SUM(C.Amount))),0)
		FROM PurchaseReturn A,(SELECT SUM(Amount) AS Amount FROM #PurRetnTaxForDiff)B,#PurRetTotAdd C
		WHERE A.PurRetRefNo = @Pi_ReferNo
		
		UPDATE #PurRetnTaxForDiff SET Amount=Amount+@DiffAmt
		WHERE InputTaxId IN (SELECT MIN(InputTaxId) FROM #PurRetnTaxForDiff)
			
		INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
			LastModDate,AuthId,AuthDate)
		SELECT * FROM #PurRetnTaxForDiff
		--INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		--	LastModDate,AuthId,AuthDate)
		--SELECT @VocRefNo,C.InPutTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,@Pi_UserId,
		--	Convert(varchar(10),Getdate(),121),@Pi_UserId,Convert(varchar(10),Getdate(),121)
		--	FROM PurchaseReturn A INNER JOIN PurchaseReturnProductTax B ON
		--		A.PurRetId = B.PurRetId
		--	INNER JOIN TaxConfiguration C ON
		--		B.TaxId = C.TaxId
		--	WHERE A.PurRetRefNo = @Pi_ReferNo
		--	Group By C.InPutTaxId
		--	HAVING ISNULL(SUM(B.TaxAmount),0) > 0
			
		--SET @sStr = 'INSERT INTO StdVocDetails(VocRefNo,CoaId,DebitCredit,Amount,Availability,LastModBy,
		--	LastModDate,AuthId,AuthDate)
		--SELECT ''' + @VocRefNo + ''',C.InPutTaxId,2,ISNULL(SUM(B.TaxAmount),0),1,' +
		--	CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + ''','
		--	+ CAST(@Pi_UserId as nVarChar(10)) + ',''' + Convert(nvarchar(10),Getdate(),121) + '''
		--	FROM PurchaseReturn A INNER JOIN PurchaseReturnProductTax B ON
		--		A.PurRetId = B.PurRetId
		--	INNER JOIN TaxConfiguration C ON
		--		B.TaxId = C.TaxId
		--	WHERE A.PurRetRefNo = ''' + @Pi_ReferNo + '''
		--	Group By C.InPutTaxId
		--	HAVING ISNULL(SUM(B.TaxAmount),0) > 0'
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
			IF EXISTS (SELECT SMT.Coaid From CoaMaster CM INNER JOIN StockManagementTypeDt SMT ON SMT.Coaid =CM.Coaid
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
	RETURN
END
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.0',415
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE fixid = 415)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(415,'D','2014-07-03',GETDATE(),1,'Core Stocky Service Pack 415')