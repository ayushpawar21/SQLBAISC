--[Stocky HotFix Version]=352
Delete from Versioncontrol where Hotfixid='352'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('352','2.0.0.5','D','2010-12-22','2010-12-22','2010-12-22',convert(varchar(11),getdate()),'Parle;Major:-;Minor:Changes and Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 352' ,'352'
GO

--SRF-Nanda-184-001

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeAttributes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeAttributes]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeAttributes 0
--SELECT * FROM ErrorLog
SELECT * FROM SchemeRetAttr WHERE SchId=10 ORDER BY AttrType
ROLLBACK TRANSACTION
*/

CREATE   PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeAttributes]
(
@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE: Proc_Cn2Cs_BLSchemeAttributes
* PURPOSE: To Insert and Update Scheme Attributes
* CREATED: Boopathy.P on 02/01/2009
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @SchCode 	AS VARCHAR(50)
	DECLARE @AttrType 	AS VARCHAR(50)
	DECLARE @AttrCode 	AS VARCHAR(50)
	DECLARE @AttrTypeId 	AS INT
	DECLARE @AttrId  	AS INT
	DECLARE @CmpId  	AS INT
	DECLARE @SchLevelId 	AS INT
	DECLARE @SelMode 	AS INT
	DECLARE @ChkCount 	AS INT
	DECLARE @ErrDesc  	AS VARCHAR(1000)
	DECLARE @TabName  	AS VARCHAR(50)
	DECLARE @GetKey  	AS VARCHAR(50)
	DECLARE @Taction  	AS INT
	DECLARE @sSQL   	AS VARCHAR(4000)
	DECLARE @ConFig		AS INT
	DECLARE @CmpCnt		AS INT
	DECLARE @EtlCnt		AS INT
	DECLARE @CombiId	AS INT
	DECLARE @SLevel		AS INT
	DECLARE @iCnt		AS INT
	DECLARE @DepChk		AS INT
	DECLARE @MasterRecordID AS INT
	DECLARE @AttrName 	AS VARCHAR(100)

	SET @DepChk=0
	SET @TabName = 'Etl_Prk_Scheme_OnAttributes'
	SET @Po_ErrNo =0
	SET @iCnt=0

	SELECT @ConFig=ISNULL(Status,0) FROM Configuration WHERE
	ModuleId='GENCONFIG16' AND ModuleName='General Configuration'
	
	DELETE FROM Etl_Prk_SchemeAttribute_Temp

	DECLARE  @Temp_CtgAttrDt TABLE
	(
		SchId		INT,
		CtgMainId	INT
	)
	DECLARE  @Temp_CtgAttrDt_Temp TABLE
	(
		SchId		NVARCHAR(50),
		CtgMainId	INT
	)

	DECLARE  @Temp_ValAttrDt TABLE
	(
		SchId		INT,
		ValClass	VARCHAR(400)
	)
	
	DECLARE  @Temp_ValAttrDt_Temp TABLE
	(
		SchId		NVARCHAR(50),
		ValClass	VARCHAR(400)
	)

	DECLARE  @Temp_KeyAttrDt TABLE
	(
		SchId		INT,
		RtrId		INT
	)

	DECLARE Cur_SchemeAttr CURSOR
	FOR SELECT DISTINCT ISNULL([CmpSchCode],'') AS [Company Scheme Code],ISNULL([AttrType],'') AS [Attribute Type],
	ISNULL([AttrName],'') AS [Attribute Master Code] FROM Etl_Prk_Scheme_OnAttributes 
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D' 
	AND CmpSchCode IN (SELECT CmpSchCode FROM SchemeMaster(NOLOCK))
	ORDER BY [Company Scheme Code], [Attribute Type]
	OPEN Cur_SchemeAttr
	FETCH NEXT FROM Cur_SchemeAttr INTO @SchCode,@AttrType,@AttrCode
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @iCnt=@iCnt+1
		SET @Taction = 2

		SET @Po_ErrNo =0

		IF LTRIM(RTRIM(@SchCode))= ''
		BEGIN
			SET @ErrDesc = 'Company Scheme Code should not be blank'
			INSERT INTO Errorlog VALUES (1,@TabName,'Company Scheme Code',@ErrDesc)
			SET @Taction = 0
			SET @Po_ErrNo =1
		END
		ELSE IF LTRIM(RTRIM(@AttrType))<>''
		BEGIN
			IF LTRIM(RTRIM(@AttrCode))=''
			BEGIN
				SET @ErrDesc = 'Attribute Code should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Attribute Code',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		ELSE IF LTRIM(RTRIM(@AttrCode))<>''
		BEGIN
			IF LTRIM(RTRIM(@AttrType))=''
			BEGIN
				SET @ErrDesc = 'Attribute Type should not be blank for Scheme Code:'+@SchCode
				INSERT INTO Errorlog VALUES (1,@TabName,'Attribute Type',@ErrDesc)
				SET @Taction = 0
				SET @Po_ErrNo =1
			END
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @ConFig<>1
			BEGIN
				IF NOT EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
					
				END
				ELSE
				BEGIN
					SET @DepChk=1
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SelMode=SchemeLvlMode,@CombiId=CombiSch FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END	
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SchId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode)))
				BEGIN
					SET @DepChk=1
					SELECT @GetKey=SchId,@CmpId=CmpId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SelMode=SchemeLvlMode,@CombiId=CombiSch FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					SELECT @SchLevelId=SchLevelId FROM SchemeMaster WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT CmpSchCode FROM ETL_Prk_SchemeMaster_Temp WHERE
					CmpSchCode=LTRIM(RTRIM(@SchCode)) AND UpLoadFlag='N')
					BEGIN	
						IF NOT EXISTS(SELECT [CmpSchCode] FROM Etl_Prk_SchemeHD_Slabs_Rules WHERE
						[CmpSchCode]=LTRIM(RTRIM(@SchCode)))
						BEGIN
							SET @ErrDesc = 'Company Scheme Code not found for Scheme Code:'+@SchCode+ ' in table Etl_Prk_SchemeHD_Slabs_Rules  '
							INSERT INTO Errorlog VALUES (1,@TabName,'Scheme Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @CmpId=B.CmpId FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON
							B.CmpCode=A.[CmpCode] WHERE [CmpSchCode]=LTRIM(RTRIM(@SchCode))
							SELECT @SchLevelId=C.CmpPrdCtgId,
								@SelMode=(CASE A.SchemeLevelMode
								WHEN 'PRODUCT' THEN 0 ELSE 1 END),@CombiId=(CASE A.CombiSch
								WHEN 'NO' THEN 0 ELSE 1 END)
							FROM Etl_Prk_SchemeHD_Slabs_Rules A INNER JOIN COMPANY B ON B.CmpCode=A.CmpCode
							INNER JOIN ProductCategoryLevel C ON A.SchLevel=C.CmpPrdCtgName
							AND B.CmpId=C.CmpId WHERE A.CmpSchCode=LTRIM(RTRIM(@SchCode))
						END
					END
					ELSE
					BEGIN
						SET @DepChk=2
						SELECT @GetKey=CmpSchCode,@CmpId=CmpId FROM ETL_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
	
						SELECT @SelMode=SchemeLvlMode,@CombiId=CombiSch FROM ETL_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
	
						SELECT @SchLevelId=SchLevelId FROM ETL_Prk_SchemeMaster_Temp
						WHERE CmpSchCode=LTRIM(RTRIM(@SchCode))
					END	
				END
			END
			IF UPPER(LTRIM(RTRIM(@AttrType)))= 'SALESMAN'
				BEGIN
				SET @AttrTypeId=1
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT SMID FROM SALESMAN WITH (NOLOCK) WHERE
						SMCODE=LTRIM(RTRIM(@AttrCode)) AND STATUS = 1)
					BEGIN
						SET @ErrDesc = 'Salesman Code:'+ @AttrCode+ ' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'SalesMan',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=SMID FROM SALESMAN WITH (NOLOCK) WHERE
						SMCODE=LTRIM(RTRIM(@AttrCode)) AND STATUS = 1
					END
				END
			END
			--->Added By Nanda on 28/07/2010
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'CLUSTER'
				BEGIN
				SET @AttrTypeId=21
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT ClusterId FROM ClusterMaster WITH (NOLOCK) WHERE
						ClusterCode=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Cluster Code:'+ @AttrCode+ ' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Cluster',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=ClusterId FROM ClusterMaster WITH (NOLOCK) WHERE
						ClusterCode=LTRIM(RTRIM(@AttrCode))
					END
				END
			END
			--->Till Here
			
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'ROUTE'
			BEGIN
				SET @AttrTypeId=2
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT RMID FROM RouteMaster WITH (NOLOCK) WHERE
						RMCODE=LTRIM(RTRIM(@AttrCode)) AND RMStatus = 1)
					BEGIN
						SET @ErrDesc = 'Route Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Route',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=RMID FROM RouteMaster WITH (NOLOCK) WHERE
						RMCODE=LTRIM(RTRIM(@AttrCode)) AND RMStatus = 1
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'VILLAGE'
			BEGIN
				SET @AttrTypeId=3
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT VillageId FROM RouteVillage WITH (NOLOCK) WHERE
						VILLAGECODE=LTRIM(RTRIM(@AttrCode)) AND VillageStatus = 1)
					BEGIN
						SET @ErrDesc = 'Route Village Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'RouteVillage',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=VillageId FROM RouteVillage WITH (NOLOCK) WHERE
						VILLAGECODE=LTRIM(RTRIM(@AttrCode)) AND VillageStatus = 1
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'CATEGORY LEVEL'
			BEGIN
				SET @AttrTypeId=4
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT CtgLevelId FROM RetailerCategoryLevel WITH (NOLOCK) WHERE
						CtgLevelName=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Category Level:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Category Level',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=CtgLevelId FROM RetailerCategoryLevel WITH (NOLOCK) WHERE
						CtgLevelName=LTRIM(RTRIM(@AttrCode))
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'CATEGORY LEVEL VALUE'
			BEGIN
				SET @AttrTypeId=5
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT CtgMainId FROM RetailerCategory WITH (NOLOCK) WHERE
					CtgCOde=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Category Level Value not found''' + LTRIM(RTRIM(@SchCode)) + ''''
						INSERT INTO Errorlog VALUES (1,@TabName,'Category Level Value',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=CtgMainId FROM RetailerCategory WITH (NOLOCK) WHERE
						CtgCOde=LTRIM(RTRIM(@AttrCode))
						--->Modified By Nanda on 24/08/2009
						IF @DepChk=1
						BEGIN
							INSERT INTO @Temp_CtgAttrDt SELECT @GetKey,@AttrId
						END
						ELSE
						BEGIN
							INSERT INTO @Temp_CtgAttrDt_Temp SELECT @GetKey,@AttrId
						END
						--Till Here
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'VALUECLASS'
			BEGIN
				SET @AttrTypeId=6
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT RtrClassId FROM RETAILERVALUECLASS WITH (NOLOCK) WHERE
						ValueClassCode=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Value Class Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Value Class',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=RtrClassId FROM RETAILERVALUECLASS WITH (NOLOCK) WHERE
						ValueClassCode=LTRIM(RTRIM(@AttrCode))
						--->Modified By Nanda on 24/08/2009
						IF @DepChk=1
						BEGIN
							INSERT INTO @Temp_ValAttrDt SELECT @GetKey,@AttrCode
						END
						ELSE
						BEGIN
							INSERT INTO @Temp_ValAttrDt_Temp SELECT @GetKey,@AttrCode
						END
						--Till Here
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'POTENTIALCLASS'
			BEGIN
				SET @AttrTypeId=7
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF NOT EXISTS(SELECT RtrClassId FROM RETAILERPOTENTIALCLASS WITH (NOLOCK) WHERE
						PotentialClassCode=LTRIM(RTRIM(@AttrCode)))
					BEGIN
						SET @ErrDesc = 'Potential Class Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Potential Class',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE
					BEGIN
						SELECT @AttrId=RtrClassId FROM RETAILERPOTENTIALCLASS WITH (NOLOCK) WHERE
						PotentialClassCode=LTRIM(RTRIM(@AttrCode))
					END
				END
			END
			ELSE IF ((UPPER(LTRIM(RTRIM(@AttrType)))= 'KEYGROUP') OR (UPPER(LTRIM(RTRIM(@AttrType)))= 'RETAILER'))
			BEGIN
				SET @AttrTypeId=8
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN	
					IF (UPPER(LTRIM(RTRIM(@AttrType)))= 'KEYGROUP')
					BEGIN
						IF NOT EXISTS(SELECT GrpId FROM KeyGroupMaster WITH (NOLOCK) WHERE
								GrpCode = @AttrCode)
						BEGIN
							SET @ErrDesc = 'Key Code:'+@AttrCode +' not found for Scheme Code:'+@SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'Key Group',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @AttrName = GrpName FROM KeyGroupMaster WITH (NOLOCK) WHERE GrpCode = LTRIM(RTRIM(@AttrCode))
							DECLARE Cur_KeyGrp CURSOR FOR 
							SELECT ISNULL(MasterRecordID,0) AS [MasterRecordID] FROM UdcDetails A INNER JOIN UdcMaster B
							ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
							INNER JOIN RETAILER R ON A.MasterRecordId=R.RtrId INNER JOIN KeyGroupMaster K 
							ON K.GrpName=A.ColumnValue Where A.ColumnValue=@AttrName AND C.MAsterID = 2
							OPEN Cur_KeyGrp
							FETCH NEXT FROM Cur_KeyGrp INTO @MasterRecordID
							WHILE @@FETCH_STATUS=0
							BEGIN
								INSERT INTO @Temp_KeyAttrDt SELECT @GetKey,@MasterRecordID
							FETCH NEXT FROM Cur_KeyGrp INTO @MasterRecordID
							END
							CLOSE Cur_KeyGrp
							DEALLOCATE Cur_KeyGrp
						END
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'RETAILER'
					BEGIN
						IF NOT EXISTS (SELECT RtrId FROM Retailer WITH (NOLOCK) WHERE CmpRtrCode = LTRIM(RTRIM(@AttrCode)))
						BEGIN
							SET @ErrDesc = 'Retailer Code:'+ @AttrCode + ' not found for Scheme Code:'+ @SchCode
							INSERT INTO Errorlog VALUES (1,@TabName,'Retailer Code',@ErrDesc)
							SET @Taction = 0
							SET @Po_ErrNo =1
						END
						ELSE
						BEGIN
							SELECT @AttrId = RtrId FROM Retailer WITH (NOLOCK) WHERE CmpRtrCode = LTRIM(RTRIM(@AttrCode))
						END
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'PRODUCT'
			BEGIN
				SET @AttrTypeId=9
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF @SelMode=0
					BEGIN
						SET @AttrId=1
					END
					ELSE IF @SelMode=1
					BEGIN
						IF NOT EXISTS(SELECT DISTINCT A.UDCUniqueId FROM UdcDetails A INNER JOIN UdcMaster B
							ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
							INNER JOIN Product P ON A.MasterRecordId=P.PrdId AND P.CmpId=@CmpId
							Where A.UdcMasterId=@SchLevelId)
						BEGIN
							SET @AttrId=@AttrCode
						END
						ELSE
						BEGIN
							SELECT DISTINCT @AttrId=A.UDCUniqueId FROM UdcDetails A INNER JOIN UdcMaster B
							ON A.UdcMasterId=B.UdcMasterId INNER JOIN UdcHD C On A.MasterId=C.MasterId
							INNER JOIN Product P ON A.MasterRecordId=P.PrdId AND P.CmpId=@CmpId
							Where A.UdcMasterId=@SchLevelId
						END
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL TYPE'
			BEGIN
				SET @AttrTypeId=10
				IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'VAN SALES' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'READY STOCK'
					AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ORDER BOOKING'
				BEGIN
					SET @ErrDesc = 'BILL TYPE SHOULD BE(VAN SALES OR READY STOCK OR ORDER BOOKING) for Scheme Code:'+@SchCode
					INSERT INTO Errorlog VALUES (1,@TabName,'Bill Type',@ErrDesc)
					SET @Taction = 0
					SET @Po_ErrNo =1
				END
				ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='VAN SALES'
				BEGIN
					SET @AttrId=3
				END
				ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='READY STOCK'
				BEGIN
					SET @AttrId=2
				END
				ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ORDER BOOKING'
				BEGIN
					SET @AttrId=1
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL MODE'
			BEGIN
				SET @AttrTypeId=11
				IF UPPER(LTRIM(RTRIM(@AttrCode)))='ALL'
				BEGIN
					SET @AttrId=1
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'CASH' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'CREDIT'
					BEGIN
						SET @ErrDesc = 'BILL MODE SHOULD BE(CASH OR CREDIT) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'Bill Mode',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='CASH'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='CREDIT'
					BEGIN
						SET @AttrId=2
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'RETAILER TYPE'
			BEGIN
				SET @AttrTypeId=12
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'KEY OUTLET' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'NON-KEY OUTLET'
					BEGIN
						SET @ErrDesc = 'RETAIER TYPE SHOULD BE(KEY OUTLET OR NON-KEY OUTLET) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'RETAILER TYPE',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='KEY OUTLET'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='NON-KEY OUTLET'
					BEGIN
						SET @AttrId=2
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'CLASS TYPE'
			BEGIN
				SET @AttrTypeId=13
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'VALUE CLASSIFICATION' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POTENTIAL CLASSIFICATION'
					BEGIN
						SET @ErrDesc = 'CLASS TYPE SHOULD BE(VALUE CLASSIFICATION OR POTENTIAL CLASSIFICATION) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'CLASS TYPE',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='VALUE CLASSIFICATION'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POTENTIAL CLASSIFICATION'
					BEGIN
						SET @AttrId=2
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'ROAD CONDITION'
			BEGIN
				SET @AttrTypeId=14
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'GOOD' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ABOVE AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'AVERAGE' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'BELOW AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POOR'
					BEGIN
						SET @ErrDesc = 'ROAD CONDITION SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'ROAD CONDITION',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='GOOD'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ABOVE AVERAGE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='AVERAGE'
					BEGIN
						SET @AttrId=3
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='BELOW AVERAGE'
					BEGIN
						SET @AttrId=4
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POOR'
					BEGIN
						SET @AttrId=5
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'INCOME LEVEL'
			BEGIN
				SET @AttrTypeId=15
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'GOOD' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ABOVE AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'AVERAGE' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'BELOW AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POOR'
					BEGIN
						SET @ErrDesc = 'INCOME LEVEL SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'INCOME LEVEL',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='GOOD'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ABOVE AVERAGE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='AVERAGE'					
					BEGIN
						SET @AttrId=3
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='BELOW AVERAGE'
					BEGIN
						SET @AttrId=4
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POOR'
					BEGIN
						SET @AttrId=5
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'ACCEPTABILITY'
			BEGIN
				SET @AttrTypeId=16
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'GOOD' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ABOVE AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'AVERAGE' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'BELOW AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POOR'
					BEGIN
						SET @ErrDesc = 'ACCEPTABILITY SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'ACCEPTABILITY',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='GOOD'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ABOVE AVERAGE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='AVERAGE'
					BEGIN
						SET @AttrId=3
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='BELOW AVERAGE'
					BEGIN
						SET @AttrId=4
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POOR'
					BEGIN
						SET @AttrId=5
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'AWARENESS'
			BEGIN
				SET @AttrTypeId=17
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'GOOD' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'ABOVE AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'AVERAGE' AND UPPER(LTRIM(RTRIM(@AttrCode)))<>'BELOW AVERAGE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'POOR'
					BEGIN
						SET @ErrDesc = 'AWARENESS SHOULD BE(GOOD OR ABOVE AVERAGE OR AVERAGE OR  BELOW AVERAGE OR POOR) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'AWARENESS',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='GOOD'
					BEGIN
						SET @AttrId=1
					END 					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='ABOVE AVERAGE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='AVERAGE'
					BEGIN
						SET @AttrId=3
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='BELOW AVERAGE'
					BEGIN
						SET @AttrId=4
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='POOR'
					BEGIN
						SET @AttrId=5
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'ROUTE TYPE'
			BEGIN
				SET @AttrTypeId=18
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'SALES ROUTE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'DELIVERY ROUTE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'MERCHANDISING ROUTE'
					BEGIN
						SET @ErrDesc = 'ROUTE TYPE SHOULD BE(SALES ROUTE OR DELIVERY ROUTE OR MERCHANDISING ROUTE) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'ROUTE TYPE',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='SALES ROUTE'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='DELIVERY ROUTE'
					BEGIN
						SET @AttrId=2
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='MERCHANDISING ROUTE'
					BEGIN
						SET @AttrId=3
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'LOCALUPCOUNTRY'
			BEGIN
				SET @AttrTypeId=19
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'LOCAL ROUTE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'UPCOUNTRY ROUTE'
					BEGIN
						SET @ErrDesc = 'LOCAL/UPCOUNTRY SHOULD BE(LOCAL ROUTE OR UPCOUNTRY ROUTE) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'LOCALUPCOUNTRY',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='LOCAL ROUTE'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='UPCOUNTRY ROUTE'
					BEGIN
						SET @AttrId=2
					END
				END
			END
			ELSE IF UPPER(LTRIM(RTRIM(@AttrType)))= 'VAN/NON VAN ROUTE'
			BEGIN
				SET @AttrTypeId=20
				IF LTRIM(RTRIM(@AttrCode))='ALL'
				BEGIN
					SET @AttrId=0
				END
				ELSE
				BEGIN
					IF UPPER(LTRIM(RTRIM(@AttrCode)))<>'VAN ROUTE' AND
					UPPER(LTRIM(RTRIM(@AttrCode)))<>'NON VAN ROUTE'
					BEGIN
						SET @ErrDesc = 'VAN/NON VAN ROUTE SHOULD BE(VAN ROUTE OR NON VAN ROUTE) for Scheme Code:'+@SchCode
						INSERT INTO Errorlog VALUES (1,@TabName,'NON VAN ROUTE',@ErrDesc)
						SET @Taction = 0
						SET @Po_ErrNo =1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='VAN ROUTE'
					BEGIN
						SET @AttrId=1
					END
					ELSE IF UPPER(LTRIM(RTRIM(@AttrCode)))='NON VAN ROUTE'
					BEGIN
						SET @AttrId=2
					END
				END
			END
		END
		IF @Po_ErrNo =1
		BEGIN
			IF @DepChk=1
			BEGIN
				EXEC Proc_DependencyCheck 'SCHEMEMASTER',@GetKey
				SELECT @ChkCount=COUNT(*) FROM TempDepCheck
				IF @ChkCount > 0
				BEGIN
					SET @Taction = 0
				END
			END
		END
		ELSE
		BEGIN
			IF @ConFig=1
			BEGIN
				SELECT @SLevel=MAX(CmpPrdCtgId) FROM ProductCategoryLevel WHERE CmpId=@CmpId
				IF @SchLevelId <@SLevel
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
			
						IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL MODE' OR UPPER(LTRIM(RTRIM(@AttrType)))='BILL TYPE' OR UPPER(LTRIM(RTRIM(@AttrType)))='CATEGORY LEVEL VALUE'
						BEGIN
							DELETE FROM SchemeRetAttr WHERE SchId=ISNULL(@GetKey,0) AND AttrType=@AttrTypeId
							AND AttrId=@AttrId
			
							SET @sSQL='DELETE FROM SchemeRetAttr WHERE SchId='+ CAST(@GetKey AS VARCHAR(10)) +
							' AND AttrType=' + CAST(@AttrTypeId AS VARCHAR(10)) + ' AND AttrId=' + CAST(@AttrId AS VARCHAR(10))
						END
						ELSE
						BEGIN
							DELETE FROM SchemeRetAttr WHERE SchId=ISNULL(@GetKey,0) AND AttrType=@AttrTypeId AND AttrId=@AttrId
			
							SET @sSQL='DELETE FROM SchemeRetAttr WHERE SchId='+ CAST(@GetKey AS VARCHAR(10)) +
							' AND AttrType=' + CAST(@AttrTypeId AS VARCHAR(10))
						END
						
						INSERT INTO Translog(strSql1) Values (@sSQL)
						INSERT INTO SchemeRetAttr(SchId,AttrType,AttrId,Availability,LastModBy,LastModDate,
						AuthId,AuthDate) VALUES(ISNULL(@GetKey,0),@AttrTypeId,@AttrId,1,1,convert(varchar(10),getdate(),121),
						1,convert(varchar(10),getdate(),121))
		
						SET @sSQL='INSERT INTO SchemeRetAttr(SchId,AttrType,AttrId,Availability,LastModBy,LastModDate,
						AuthId,AuthDate) VALUES(' + CAST(@GetKey AS VARCHAR(10)) + ',' + CAST(@AttrTypeId AS VARCHAR(10)) +
						',' + CAST(@AttrId AS VARCHAR(10)) + ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
						INSERT INTO Translog(strSql1) Values (@sSQL)
				
					END					
					ELSE
					BEGIN	
						INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag)
						VALUES (LTRIM(RTRIM(@SchCode)),@AttrTypeId,@AttrId,'N')
						SET @sSQL='INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag
						) VALUES(' + CAST(@SchCode AS VARCHAR(50)) + ',' + CAST(@AttrTypeId AS VARCHAR(10)) + ',''N'''')'
						INSERT INTO Translog(strSql1) Values (@sSQL)
					END
			
				END
				ELSE
				BEGIN	
					--Nanda
					--SELECT LTRIM(RTRIM(@SchCode)),@AttrTypeId,@AttrId
					INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag)
						VALUES (LTRIM(RTRIM(@SchCode)),@AttrTypeId,@AttrId,'N')
					SET @sSQL='INSERT INTO Etl_Prk_SchemeAttribute_Temp(CmpSchCode,AttrType,AttrId,UpLoadFlag
					) VALUES(' + CAST(@SchCode AS VARCHAR(50)) + ',' + CAST(@AttrTypeId AS VARCHAR(10)) + ',''N'''')'
					INSERT INTO Translog(strSql1) Values (@sSQL)
					--Nanda
					--SELECT * FROM Etl_Prk_SchemeAttribute_Temp					
				END					
			END
			ELSE
			BEGIN
				IF UPPER(LTRIM(RTRIM(@AttrType)))= 'BILL MODE' OR UPPER(LTRIM(RTRIM(@AttrType)))='BILL TYPE' OR  UPPER(LTRIM(RTRIM(@AttrType)))='CATEGORY LEVEL VALUE'
				BEGIN
					DELETE FROM SchemeRetAttr WHERE SchId=ISNULL(@GetKey,0) AND AttrType=@AttrTypeId
					AND AttrId=@AttrId
	
					SET @sSQL='DELETE FROM SchemeRetAttr WHERE SchId='+ CAST(@GetKey AS VARCHAR(10)) +
					' AND AttrType=' + CAST(@AttrTypeId AS VARCHAR(10)) + ' AND AttrId=' + CAST(@AttrId AS VARCHAR(10))
				END
				ELSE
				BEGIN
					DELETE FROM SchemeRetAttr WHERE SchId=ISNULL(@GetKey,0) AND AttrType=@AttrTypeId
	
					SET @sSQL='DELETE FROM SchemeRetAttr WHERE SchId='+ CAST(@GetKey AS VARCHAR(10)) +
					' AND AttrType=' + CAST(@AttrTypeId AS VARCHAR(10))
				END
	
				INSERT INTO Translog(strSql1) Values (@sSQL)
				INSERT INTO SchemeRetAttr(SchId,AttrType,AttrId,Availability,LastModBy,LastModDate,
				AuthId,AuthDate) VALUES(ISNULL(@GetKey,0),@AttrTypeId,@AttrId,1,1,convert(varchar(10),getdate(),121),
				1,convert(varchar(10),getdate(),121))
	
				SET @sSQL='INSERT INTO SchemeRetAttr(SchId,AttrType,AttrId,Availability,LastModBy,LastModDate,
				AuthId,AuthDate) VALUES(' + CAST(@GetKey AS VARCHAR(10)) + ',' + CAST(@AttrTypeId AS VARCHAR(10)) +
				',' + CAST(@AttrId AS VARCHAR(10)) + ',1,1,''' + convert(varchar(10),getdate(),121) + ''',1,''' + convert(varchar(10),getdate(),121) + ''')'
				INSERT INTO Translog(strSql1) Values (@sSQL)
			END			
		END
	FETCH NEXT FROM Cur_SchemeAttr INTO @SchCode,@AttrType,@AttrCode
	END
	CLOSE Cur_SchemeAttr
	DEALLOCATE Cur_SchemeAttr
	--SELECT * FROM SchemeRetAttr WHERE SchId=10
	IF EXISTS (SELECT * FROM Etl_Prk_Scheme_OnAttributes)
	BEGIN
		-->Modified By Nanda on 30/11/2009  
		IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SchAttrToAvoid') 
		AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
		BEGIN
			DROP TABLE SchAttrToAvoid	
		END
		CREATE TABLE SchAttrToAvoid
		(
			SchId INT
		)
		INSERT INTO SchAttrToAvoid
		SELECT SchId FROM SchemeRetAttr WHERE AttrId=0 AND AttrType=6
		DELETE FROM SchemeRetAttr WHERE AttrType=6 AND SchId IN  (SELECT DISTINCT SchId FROM @Temp_CtgAttrDt)
		AND SchId NOT IN (SELECT SchId FROM SchAttrToAvoid)
		INSERT INTO SchemeRetAttr
		SELECT DISTINCT B.SchId,6,A.RtrClassId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121) 
		FROM RETAILERVALUECLASS A 
		INNER JOIN @Temp_CtgAttrDt B ON A.CtgMainId=B.CtgMainId 
		INNER JOIN @Temp_ValAttrDt C ON A.ValueClassCode = C.ValClass AND B.SchId=C.SchId
		AND B.SchId NOT IN (SELECT SchId FROM SchAttrToAvoid)
		-->Till Here
		
		DELETE FROM Etl_Prk_SchemeAttribute_Temp WHERE AttrType=6 AND CmpSchCode IN  (SELECT DISTINCT SchId FROM @Temp_CtgAttrDt_Temp)
		INSERT INTO Etl_Prk_SchemeAttribute_Temp
		SELECT DISTINCT B.SchId,6,A.RtrClassId,'N'
		FROM RETAILERVALUECLASS A INNER JOIN @Temp_CtgAttrDt_Temp B
		ON A.CtgMainId=B.CtgMainId INNER JOIN @Temp_ValAttrDt_Temp C ON
		A.ValueClassCode = C.ValClass AND B.SchId=C.SchId
		IF EXISTS (SELECT * FROM @Temp_KeyAttrDt)
		BEGIN
			DELETE FROM SchemeRetAttr WHERE AttrType=8 AND SchId IN (SELECT DISTINCT SchId FROM @Temp_KeyAttrDt)
			INSERT INTO SchemeRetAttr
			SELECT DISTINCT SchID,8,RtrId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,CONVERT(VARCHAR(10),GETDATE(),121)
			FROM @Temp_KeyAttrDt
		END
		IF EXISTS (SELECT * FROM @Temp_KeyAttrDt)
		BEGIN
			DELETE FROM Etl_Prk_SchemeAttribute_Temp WHERE AttrType=8 AND CmpSchCode IN  (SELECT DISTINCT SchId FROM @Temp_KeyAttrDt)
			INSERT INTO Etl_Prk_SchemeAttribute_Temp
			SELECT DISTINCT SchID,8,RtrId,'N' FROM @Temp_KeyAttrDt
		END
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-184-002

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClusterAssignApproval]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClusterAssignApproval]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ClusterAssignApproval 0
SELECT * FROM Cn2Cs_Prk_ClusterAssignApproval
--UPDATE Cn2Cs_Prk_ClusterAssignApproval SET DownLoadFlag='D'
SELECT * FROM Errorlog
SELECT * FROM ClusterAssign
ROLLBACK TRANSACTION
*/
CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_ClusterAssignApproval]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClusterAssignApproval
* PURPOSE		: To validate the downloaded Cluster Assign Approval details from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 18/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TabName		NVARCHAR(100)
	DECLARE @ErrDesc		NVARCHAR(1000)
	DECLARE @MasterCmpCode 	NVARCHAR(50)
	DECLARE @MasterDistCode	NVARCHAR(50)
	DECLARE @ClusterCode 	NVARCHAR(50)
	DECLARE @Status		  	NVARCHAR(50)
	DECLARE @AssignDate	  	DATETIME
	
	DECLARE @ClusterId  	INT
	DECLARE @Exist		 	INT	
	DECLARE @RtrId  		INT
	DECLARE @ClsGroupId  	INT
	DECLARE @ClsGrpType		INT
	SET @TabName = 'Cn2Cs_Prk_ClusterAssignApproval'
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClsAppToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClsAppToAvoid	
	END
	CREATE TABLE ClsAppToAvoid
	(
		ClusterCode NVARCHAR(50),
		MasterCmpCode NVARCHAR(50)
	)
	IF EXISTS(SELECT DISTINCT ClusterCode,MasterCmpCode FROM Cn2Cs_Prk_ClusterAssignApproval
	WHERE ClusterCode NOT IN (SELECT ClusterCode FROM ClusterMaster))
	BEGIN
		INSERT INTO ClsAppToAvoid(ClusterCode,MasterCmpCode)
		SELECT DISTINCT ClusterCode,MasterCmpCode FROM Cn2Cs_Prk_ClusterAssignApproval
		WHERE ClusterCode NOT IN (SELECT ClusterCode FROM ClusterMaster)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Assign','ClusterCode','Cluster Code:'+ClusterCode+' not found' FROM Cn2Cs_Prk_ClusterAssignApproval
		WHERE ClusterCode NOT IN (SELECT ClusterCode FROM ClusterMaster)
	END		
	IF EXISTS(SELECT DISTINCT ClusterCode,MasterCmpCode FROM Cn2Cs_Prk_ClusterAssignApproval
	WHERE MasterCmpCode NOT IN (SELECT CmpRtrCode FROM Retailer))
	BEGIN
		INSERT INTO ClsAppToAvoid(ClusterCode,MasterCmpCode)
		SELECT DISTINCT ClusterCode,MasterCmpCode FROM Cn2Cs_Prk_ClusterAssignApproval
		WHERE MasterCmpCode NOT IN (SELECT CmpRtrCode FROM Retailer)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Assign','MasterCmpCode','Retailer:'+MasterCmpCode+' not found' FROM Cn2Cs_Prk_ClusterAssignApproval
		WHERE MasterCmpCode NOT IN (SELECT CmpRtrCode FROM Retailer)
	END
	
	DECLARE Cur_ClusterAssign CURSOR
	FOR SELECT MasterCmpCode,MasterDistCode,ClusterCode,Status,AssignDate
	FROM Cn2Cs_Prk_ClusterAssignApproval WHERE [DownLoadFlag] ='D' AND
	ClusterCode NOT IN (SELECT ClusterCode FROM ClsAppToAvoid)
	OPEN Cur_ClusterAssign
	FETCH NEXT FROM Cur_ClusterAssign INTO @MasterCmpCode,@MasterDistCode,@ClusterCode,@Status,@AssignDate
	WHILE @@FETCH_STATUS=0
	BEGIN		
		SET @Po_ErrNo=0
		SET @Exist=0
		
		SELECT @ClusterId=ClusterId FROM ClusterMaster WHERE ClusterCode=@ClusterCode
		SELECT @RtrId=RtrId FROM Retailer WHERE CmpRtrCode=@MasterCmpCode		
		SELECT @ClsGroupId=ClsGroupId FROM ClusterGroupDetails	WHERE ClusterId=@ClusterId	
		SELECT @ClsGrpType=ClsType FROM ClusterGroupMaster		

		SELECT * FROM ClusterGroupMaster	

		IF @ClsGrpType=0
		BEGIN
			DELETE FROM ClusterAssign WHERE ClusterId IN (SELECT ClusterId FROM ClusterGRoupDetails WHERE ClsGroupId=@ClsGroupId)
			AND ClusterId<>@ClusterId AND MasterRecordId=@RtrId
		END
	
		IF NOT EXISTS(SELECT * FROM ClusterAssign WHERE ClusterId=@ClusterId AND MasterRecordId=@RtrId)
		BEGIN
			INSERT INTO ClusterAssign(ClusterId,MasterId,MasterRecordId,Status,Upload,AssignDate,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			VALUES(@ClusterId,79,@RtrId,(CASE @Status WHEN 'Approved' THEN 1 ELSE 0 END),1,GETDATE(),1,1,GETDATE(),1,GETDATE())
		END	
		ELSE
		BEGIN
			IF @Status='Approved'
			BEGIN
				UPDATE ClusterAssign SET Status=1
				WHERE ClusterId=@ClusterId AND MasterRecordId=@RtrId
			END
			ELSE
			BEGIN
				DELETE FROM ClusterAssign WHERE ClusterId=@ClusterId AND MasterRecordId=@RtrId
			END
		END
		
		FETCH NEXT FROM Cur_ClusterAssign INTO @MasterCmpCode,@MasterDistCode,@ClusterCode,@Status,@AssignDate
	END
	CLOSE Cur_ClusterAssign
	DEALLOCATE Cur_ClusterAssign
	UPDATE Cn2Cs_Prk_ClusterAssignApproval SET DownLoadFlag='Y' WHERE
	DownLoadFlag ='D' AND ClusterCode+'~'+MasterCmpCode NOT IN (SELECT ClusterCode+'~'+MasterCmpCode FROM ClsAppToAvoid)
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-184-003

IF NOT EXISTS(SELECT UserName FROM Users GROUP BY UserName HAVING COUNT(UserName)>1)
BEGIN
	If Not Exists (Select * from Sysobjects where name = 'UK_UserName' and Xtype = 'UQ' and Parent_obj in 
		(Select id from Sysobjects where name = 'Users'))
	Begin
		ALTER TABLE [dbo].[Users] WITH NOCHECK ADD 
		CONSTRAINT [UK_UserName] UNIQUE(UserName)
	End
END
GO

--SRF-Nanda-184-004

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_SupplierMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_SupplierMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_SupplierMaster 0
SELECT * FROM Cn2Cs_Prk_SupplierMaster
--SELECT * FROM ErrorLog
SELECT * FROM Supplier
ROLLBACK TRANSACTION
*/
CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_SupplierMaster]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_SupplierMaster
* PURPOSE		: To validate the downloaded Supplier details from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 15/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TabName		NVARCHAR(100)
	DECLARE @ErrDesc		NVARCHAR(1000)
	DECLARE @SpmCode 		NVARCHAR(50)
	DECLARE @SpmName  		NVARCHAR(100)
	DECLARE @SpmAdd1	  	NVARCHAR(100)
	DECLARE @SpmAdd2		NVARCHAR(100)
	DECLARE @SpmAdd3		NVARCHAR(100)
	DECLARE @TaxGrpCode  	NVARCHAR(100)
	DECLARE @PhoneNo  		NVARCHAR(100)
	DECLARE @FaxNo  		NVARCHAR(100)
	DECLARE @EmailId  		NVARCHAR(100)
	DECLARE @ContPerson  	NVARCHAR(100)
	DECLARE @DefaultSpm  	NVARCHAR(100)
	DECLARE @AcCode			NVARCHAR(100)
	DECLARE @SpmId  		INT
	DECLARE @CoaId  		INT
	DECLARE @CmpId  		INT
	DECLARE @TaxGrpId  		INT
	DECLARE @Exist		 	INT
	SET @TabName = 'Cn2Cs_Prk_SupplierMaster'
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'SpmToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE SpmToAvoid	
	END
	CREATE TABLE SpmToAvoid
	(
		SpmCode NVARCHAR(50)
	)
	IF EXISTS(SELECT DISTINCT SpmCode FROM Cn2Cs_Prk_SupplierMaster
	WHERE LTRIM(RTRIM(ISNULL(SpmCode,'')))='' OR LTRIM(RTRIM(ISNULL(SpmName,'')))='')
	BEGIN
		INSERT INTO SpmToAvoid(SpmCode)
		SELECT DISTINCT SpmCode FROM Cn2Cs_Prk_SupplierMaster
		WHERE LTRIM(RTRIM(ISNULL(SpmCode,'')))='' OR LTRIM(RTRIM(ISNULL(SpmName,'')))=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Supplier Master','SpmCode','Supplier Code/Name Should not be empty' FROM Cn2Cs_Prk_SupplierMaster
		WHERE LTRIM(RTRIM(ISNULL(SpmCode,'')))='' OR LTRIM(RTRIM(ISNULL(SpmName,'')))=''
	END		
	
	IF EXISTS(SELECT DISTINCT SpmCode FROM Cn2Cs_Prk_SupplierMaster
	WHERE LTRIM(RTRIM(ISNULL(SpmAdd1,'')))='')
	BEGIN
		INSERT INTO SpmToAvoid(SpmCode)
		SELECT DISTINCT SpmCode FROM Cn2Cs_Prk_SupplierMaster
		WHERE LTRIM(RTRIM(ISNULL(SpmAdd1,'')))=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Supplier Master','SpmCode','Supplier Address1 Should not be empty' FROM Cn2Cs_Prk_SupplierMaster
		WHERE LTRIM(RTRIM(ISNULL(SpmAdd1,'')))=''
	END
	
	IF EXISTS(SELECT DISTINCT SpmCode FROM Cn2Cs_Prk_SupplierMaster
	WHERE LTRIM(RTRIM(ISNULL(PhoneNo,'')))='')
	BEGIN
		INSERT INTO SpmToAvoid(SpmCode)
		SELECT DISTINCT SpmCode FROM Cn2Cs_Prk_SupplierMaster
		WHERE LTRIM(RTRIM(ISNULL(PhoneNo,'')))=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Supplier Master','SpmCode','Supplier Phone No Should not be empty' FROM Cn2Cs_Prk_SupplierMaster
		WHERE LTRIM(RTRIM(ISNULL(PhoneNo,'')))=''
	END
	DECLARE Cur_SupplierMaster CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([SpmCode])),''),ISNULL(LTRIM(RTRIM([SpmName])),''),ISNULL(LTRIM(RTRIM([SpmAdd1])),''),
	ISNULL(LTRIM(RTRIM([SpmAdd2])),''),ISNULL(LTRIM(RTRIM([SpmAdd3])),''),ISNULL(LTRIM(RTRIM([TaxGroupCode])),''),
	ISNULL(LTRIM(RTRIM([PhoneNo])),''),ISNULL(LTRIM(RTRIM([FaxNo])),''),ISNULL(LTRIM(RTRIM([EmailId])),''),
	ISNULL(LTRIM(RTRIM([ContPerson])),''),ISNULL(LTRIM(RTRIM([DefaultSpm])),'No')
	FROM Cn2Cs_Prk_SupplierMaster WHERE [DownLoadFlag] ='D' AND
	SpmCode NOT IN (SELECT SpmCode FROM SpmToAvoid)
	OPEN Cur_SupplierMaster
	FETCH NEXT FROM Cur_SupplierMaster INTO @SpmCode,@SpmName,@SpmAdd1,@SpmAdd2,@SpmAdd3,
	@TaxGrpCode,@PhoneNo,@FaxNo,@EmailId,@ContPerson,@DefaultSpm
	WHILE @@FETCH_STATUS=0
	BEGIN		
		SET @Po_ErrNo=0
		SET @Exist=0
		IF NOT EXISTS(SELECT * FROM Company WHERE DefaultCompany=1)
		BEGIN
			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT 1,'Supplier Master','CmpCode','Default Company Not Foud'
			SET @Po_ErrNo =1
		END
		ELSE
		BEGIN
			SELECT @CmpId=CmpId FROM Company WHERE DefaultCompany=1
		END
		IF NOT EXISTS(SELECT * FROM TaxGroupSetting WHERE RtrGroup=@TaxGrpCode AND TaxGroup=3)
		BEGIN
--			INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
--			SELECT DISTINCT 1,'Supplier Master','Tax Group Code','Tax Group Code Not Foud'
--			SET @Po_ErrNo =1
			SET @TaxGrpId=0
		END
		ELSE
		BEGIN
			SELECT @TaxGrpId=TaxGroupId FROM TaxGroupSetting WHERE RtrGroup=@TaxGrpCode AND TaxGroup=3
		END
		IF NOT EXISTS (SELECT * FROM Supplier WHERE SpmCode=@SpmCode)
		BEGIN			
			SET @SpmId = dbo.Fn_GetPrimaryKeyInteger('Supplier','SpmId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			SET @Exist=0			
			IF @SpmId<=(SELECT ISNULL(MAX(SpmId),0) AS SpmId FROM Supplier)
			BEGIN
				SET @ErrDesc = 'Reset the counters/Check the system date'
				INSERT INTO ErrorLog VALUES (67,@TabName,'SpmId',@ErrDesc)
				SET @Po_ErrNo =1
			END
		END
		ELSE
		BEGIN
			SELECT @SpmId=SpmId FROM Supplier WHERE SpmCode=@SpmCode			
			SET @Exist=1
		END		
		IF @Po_ErrNo=0
		BEGIN
			IF @Exist=0
			BEGIN
				SET @CoaId = dbo.Fn_GetPrimaryKeyInteger('CoaMaster','CoaId',CAST(YEAR(GetDate()) AS INT),Month(GetDate()))
				SELECT @AcCode = CAST(CAST(AcCode as Numeric(18,0)) + 1 as nVarchar(50)) FROM COAMaster
				WHERE CoaId=(SELECT MAX(A.CoaId) FROM COAMaster A Where A.MainGroup=1
				and A.AcCode LIKE '133%')
				INSERT INTO CoaMaster(CoaId,AcCode,AcName,AcLevel,MainGroup,Status,Availability,LastModBy,
				LastModDate,AuthId,AuthDate)
				Values (@CoaId,@AcCode,@SpmName,4,1,2,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,
				CONVERT(VARCHAR(10),GETDATE(),121))
				INSERT INTO Supplier(SpmId,SpmCode,SpmName,SpmAdd1,SpmAdd2,SpmAdd3,SpmPhone,SpmFax,SpmEmail,
				SpmContact,SpmDefault,CoaId,CmpId,TaxGroupId,SpmOnAcc,Availability,LastModBy,LastModDate,AuthId,AuthDate)			
				VALUES(@SpmId,@SpmCode,@SpmName,@SpmAdd1,@SpmAdd2,@SpmAdd3,@PhoneNo,@FaxNo,@EmailId,
				@ContPerson,(CASE @DefaultSpm WHEN 'Yes' THEN 1 ELSE 0 END),@CoaId,@CmpId,@TaxGrpId,0,1,1,GETDATE(),1,GETDATE())								
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='Supplier' AND FldName='SpmId'	  								
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='CoaMaster' AND FldName='CoaId'
			END		
			ELSE
			BEGIN
				UPDATE Supplier SET SpmName=@SpmName,SpmAdd1=@SpmAdd1,SpmAdd2=@SpmAdd2,SpmAdd3=@SpmAdd3,
				SpmPhone=@PhoneNo,SpmFax=@FaxNo,SpmContact=@ContPerson,SpmDefault=(CASE @DefaultSpm WHEN 'Yes' THEN 1 ELSE 0 END)				
				WHERE SpmId=@SpmId							
			END			
		END
		FETCH NEXT FROM Cur_SupplierMaster INTO @SpmCode,@SpmName,@SpmAdd1,@SpmAdd2,@SpmAdd3,
		@TaxGrpCode,@PhoneNo,@FaxNo,@EmailId,@ContPerson,@DefaultSpm
	END
	CLOSE Cur_SupplierMaster
	DEALLOCATE Cur_SupplierMaster
	UPDATE Cn2Cs_Prk_SupplierMaster SET DownLoadFlag='Y' WHERE
	DownLoadFlag ='D' AND SpmCode IN (SELECT SpmCode FROM Supplier)
	AND SpmCode NOT IN (SELECT SpmCode FROM SpmToAvoid)
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-184-005

if not exists (Select Id,name from Syscolumns where name = 'Remarks' and id in (Select id from 
	Sysobjects where name ='ClaimSheetDetail'))
begin
	ALTER TABLE [dbo].[ClaimSheetDetail]
	ADD [Remarks] NVARCHAR(500) NOT NULL DEFAULT '' WITH VALUES
END
GO

--SRF-Nanda-184-006

if exists (select * from dbo.sysobjects where id = object_id(N'[MultiUserTransValidation]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [MultiUserTransValidation]
GO

CREATE TABLE [dbo].[MultiUserTransValidation]
(
	[UserId] [int] NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[TransId] [int] NOT NULL,
	[TransName] [nvarchar](50) NOT NULL,
	[LockedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO

--SRF-Nanda-184-007

DELETE FROM Configuration WHERE ModuleId='CLAIMTOPSHEET' AND ModuleName='Claim Top Sheet'

INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('CLAIMTOPSHEET','Claim Top Sheet','Remarks is Mandatory when Recommended Amount is less than Claimable Amount',0,'',0,1)

--SRF-Nanda-184-008

DELETE FROM Configuration WHERE ModuleId='BotreeMultiUser' 
INSERT INTO Configuration(ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('BotreeMultiUser','BotreeMultiUser','Enable Multi User Validation',0,'',0.00,1)

--SRF-Nanda-184-009

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClusterGroup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClusterGroup]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ClusterGroup 0
SELECT * FROM Cn2Cs_Prk_ClusterGroup
SELECT * FROM errorlog
ROLLBACK TRANSACTION
*/

CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_ClusterGroup]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClusterGroup
* PURPOSE		: To validate the downloaded Cluster Group details from Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 18/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TabName		NVARCHAR(100)
	DECLARE @ErrDesc		NVARCHAR(1000)
	DECLARE @ClsGroupCode 	NVARCHAR(50)
	DECLARE @ClsGroupName  	NVARCHAR(100)
	DECLARE @ClusterCode 	NVARCHAR(50)
	DECLARE @ClusterName  	NVARCHAR(100)
	DECLARE @ClsCategory  	NVARCHAR(100)
	DECLARE @ClsGroupType	NVARCHAR(100)
	DECLARE @AppReqd		NVARCHAR(10)
	
	DECLARE @ClusterId  	INT
	DECLARE @ClsGroupId  	INT
	DECLARE @ClsTransId  	INT
	DECLARE @Exist		 	INT
	SET @TabName = 'Cn2Cs_Prk_ClusterGroup'
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClsGrpToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClsGrpToAvoid	
	END
	CREATE TABLE ClsGrpToAvoid
	(
		ClsGrpCode NVARCHAR(50)
	)
	IF EXISTS(SELECT DISTINCT ClsGroupCode FROM Cn2Cs_Prk_ClusterGroup
	WHERE LTRIM(RTRIM(ISNULL(ClsGroupCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClsGroupName,'')))='')
	BEGIN
		INSERT INTO ClsGrpToAvoid(ClsGrpCode)
		SELECT DISTINCT ClsGroupCode FROM Cn2Cs_Prk_ClusterGroup
		WHERE LTRIM(RTRIM(ISNULL(ClsGroupCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClsGroupName,'')))=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Group','Cluster Group Code','Cluster Group Code/Name Should not be empty' FROM Cn2Cs_Prk_ClusterGroup
		WHERE LTRIM(RTRIM(ISNULL(ClsGroupCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClsGroupName,'')))=''
	END		
	IF EXISTS(SELECT DISTINCT ClsGroupCode FROM Cn2Cs_Prk_ClusterGroup
	WHERE ClusterCode NOT IN (SELECT ClusterCode FROM ClusterMaster))
	BEGIN
		INSERT INTO ClsGrpToAvoid(ClsGrpCode)
		SELECT DISTINCT ClsGroupCode FROM Cn2Cs_Prk_ClusterGroup
		WHERE ClusterCode NOT IN (SELECT ClusterCode FROM ClusterMaster)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Group','Cluster Code','Cluster:'+ClusterCode+'not found' FROM Cn2Cs_Prk_ClusterGroup
		WHERE ClusterCode NOT IN (SELECT ClusterCode FROM ClusterMaster)
	END
	IF EXISTS(SELECT DISTINCT ClsGroupCode FROM Cn2Cs_Prk_ClusterGroup
	WHERE ClsCategory NOT IN (SELECT TransName FROM ClusterScreens))
	BEGIN
		INSERT INTO ClsGrpToAvoid(ClsGrpCode)
		SELECT DISTINCT ClsGroupCode FROM Cn2Cs_Prk_ClusterGroup
		WHERE ClsCategory NOT IN (SELECT TransName FROM ClusterScreens)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Group','Cluster Code','Cluster Category:'+ClsCategory+'not found' FROM Cn2Cs_Prk_ClusterGroup
		WHERE ClsCategory NOT IN (SELECT TransName FROM ClusterScreens)
	END
	
	DECLARE Cur_ClusterMaster CURSOR
	FOR SELECT ClsGroupCode,ClsGroupName,ClsCategory,AppReqd,ClsGroupType,ClusterCode,ClusterName
	FROM Cn2Cs_Prk_ClusterGroup
	WHERE [DownLoadFlag] ='D' AND ClsGroupCode NOT IN (SELECT ClsGrpCode FROM ClsGrpToAvoid)
	OPEN Cur_ClusterMaster
	FETCH NEXT FROM Cur_ClusterMaster INTO @ClsGroupCode,@ClsGroupName,@ClsCategory,@AppReqd,@ClsGroupType,@ClusterCode,@ClusterName
	WHILE @@FETCH_STATUS=0
	BEGIN		
		SET @Po_ErrNo=0
		SET @Exist=0		
		IF NOT EXISTS (SELECT * FROM ClusterGroupMaster WHERE ClsGroupCode=@ClsGroupCode)
		BEGIN			
			SET @ClsGroupId = dbo.Fn_GetPrimaryKeyInteger('ClusterGroupMaster','ClsGroupId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			SET @Exist=0			
			IF @ClsGroupId<=(SELECT ISNULL(MAX(ClsGroupId),0) AS ClsGroupId FROM ClusterGroupMaster)
			BEGIN
				SET @ErrDesc = 'Reset the counters/Check the system date'
				INSERT INTO Errorlog VALUES (67,@TabName,'ClsGroupId',@ErrDesc)
				SET @Po_ErrNo =1
			END
		END
		ELSE
		BEGIN
			SELECT @ClsGroupId=ClsGroupId FROM ClusterGroupMaster WHERE ClsGroupCode=@ClsGroupCode			
			SET @Exist=1
		END		

		SELECT @ClusterId=ClusterId FROM ClusterMaster WHERE ClusterCode=@ClusterCode		
		SELECT @ClsTransId=TransId FROM ClusterScreens WHERE TransName=@ClsCategory

		IF @Exist=1
		BEGIN
			EXEC Proc_DependencyCheck 'ClusterGroupMaster',@ClusterId
			IF (SELECT COUNT(*) FROM TempDepCheck)>0
			BEGIN
				SET @Exist=2
			END			
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @Exist=0
			BEGIN
				INSERT INTO ClusterGroupMaster(ClsGroupId,ClsGroupCode,ClsGroupName,ClsType,ClsTransId,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DownLoaded,AppReqd)			
				VALUES(@ClsGroupId,@ClsGroupCode,@ClsGroupName,(CASE @ClsGroupType WHEN 'Exclusive' THEN 0 ELSE 1 END),@ClsTransId,1,1,GETDATE(),1,GETDATE(),
				1,(CASE @AppReqd WHEN 'Yes' THEN 1 ELSE 0 END))
			
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ClusterGroupMaster' AND FldName='ClsGroupId'	
				DELETE FROM ClusterGroupDetails WHERE ClsGroupId=@ClsGroupId				
			END		
			ELSE
			BEGIN
				UPDATE ClusterGroupMaster SET ClsGroupName=@ClsGroupName
				WHERE ClsGroupId=@ClsGroupId				
			END
		
			IF @Exist<>2
			BEGIN
				DELETE FROM ClusterGroupDetails WHERE ClsGroupId=@ClsGroupId AND ClusterId=@ClusterId
				INSERT INTO ClusterGroupDetails(ClsGroupId,ClusterId,Availability,LastModBy,LastModDate,AuthId,AuthDate)
				VALUES(@ClsGroupId,@ClusterId,1,1,GETDATE(),1,GETDATE())
			END
		END
		FETCH NEXT FROM Cur_ClusterMaster INTO @ClsGroupCode,@ClsGroupName,@ClsCategory,@AppReqd,@ClsGroupType,@ClusterCode,@ClusterName
	END
	CLOSE Cur_ClusterMaster
	DEALLOCATE Cur_ClusterMaster

	UPDATE Cn2Cs_Prk_ClusterGroup SET DownLoadFlag='Y' WHERE
	DownLoadFlag ='D' AND ClsGroupCode IN (SELECT ClsGroupCode FROM ClusterGroupMaster)
	AND ClsGroupCode NOT IN (SELECT ClsGrpCode FROM ClsGrpToAvoid)
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-184-010

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ReturnSchemeApplicable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ReturnSchemeApplicable]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_ReturnSchemeApplicable 1,11,2,1,2,89,0
--EXEC Proc_ReturnSchemeApplicable 1,1,1,1,2,4,0
CREATE    Procedure [dbo].[Proc_ReturnSchemeApplicable]
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
	SET @Applicable_RtrLvl=0
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
		IF @AttrType = 5 AND @Applicable_RtrVal=0		--Retailer Category Level Value
		BEGIN
			IF (SELECT COUNT(A.AttrId) FROM @SchemeRetAttr A WHERE A.AttrType = 4)=1
			BEGIN
				IF EXISTS(SELECT A.AttrId FROM @SchemeRetAttr A INNER JOIN RetailerCategoryLevel B
							ON A.AttrId = B.CtgLevelId  AND A.AttrType = 4 AND LevelName='Level1')
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
						ON A.AttrId = B.RtrKeyAcc AND A.AttrType = @AttrType)
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
						AttrId IN(SELECT DISTINCT ClusterId FROM ClusterAssign WHERE MasterId=79 AND MAsterRecordId=@Pi_RtrId AND Status=1))
				SET @Applicable_Cluster = 1
		END
		FETCH NEXT FROM CurSch INTO @AttrType,@AttrId
	END
	CLOSE CurSch
	DEALLOCATE CurSch
--
--	PRINT @Applicable_SM
--	PRINT @Applicable_RM
--	PRINT @Applicable_Vill
--	PRINT @Applicable_RtrLvl
--	PRINT @Applicable_RtrVal
--	PRINT @Applicable_VC
--	PRINT @Applicable_PC
--	PRINT @Applicable_Rtr
--	PRINT @Applicable_BT
--	PRINT @Applicable_BM
--	PRINT @Applicable_RT
--	PRINT @Applicable_CT
--	PRINT @Applicable_VRC
--	PRINT @Applicable_VI
--	PRINT @Applicable_VA
--	PRINT @Applicable_VAw
--	PRINT @Applicable_RouteType
--	PRINT @Applicable_LocUpC
--	PRINT @Applicable_VanRoute
--	PRINT @Applicable_Cluster

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
	--PRINT @Po_Applicable
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-184-011

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnQPSGivenAmt]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnQPSGivenAmt]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT ISNULL(Dbo.Fn_ReturnQPSGivenAmt(508,1480),0) AS Amt

CREATE   FUNCTION [dbo].[Fn_ReturnQPSGivenAmt]
(
	@Pi_SchId INT,
	@Pi_RtrId INT	
)
RETURNS NUMERIC(38,6)
AS
/***********************************************
* FUNCTION		: Fn_ReturnQPSGivenAmt
* PURPOSE		: Returns the Given Scheme Amount for the Selected Scheme
* NOTES			:
* CREATED		: Nandakumar R.G
* CREATED DATE	: 27-10-2010
* MODIFIED
* DATE			AUTHOR     DESCRIPTION
------------------------------------------------
* 
************************************************/
BEGIN
	DECLARE @SchemeAmt 		NUMERIC(38,6)	
	DECLARE @QPSFlatGiven	NUMERIC(38,6)	
	
	DECLARE @QPSGivenDisc TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)
	
	INSERT INTO @QPSGivenDisc
	SELECT SISL.SchId,SUM(SISL.DiscountPerAmount+SISL.FlatAmount) AS DiscountPerAmount 
	FROM SalesInvoiceSchemeLineWise SISL (NOLOCK),SalesInvoice SI (NOLOCK)
	Where Si.RtrId = @Pi_RtrId And Si.SalId = SISL.SalId And Si.DlvSts > 3 And SISL.SchId = @Pi_SchId 
	GROUP BY SISL.SchId

	UPDATE A SET A.Amount=A.Amount+C.CrNoteAmount
	FROM @QPSGivenDisc A,
	(SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B (NOLOCK),SalesInvoice SI (NOLOCK)
	Where b.RtrId = @Pi_RtrId AND B.SchId= @Pi_SchId AND SI.SalId = B.SalId AND SI.DlvSts>3
	GROUP BY B.SchId) C
	WHERE A.SchId=C.SchId 	
	
	INSERT INTO @QPSGivenDisc
	SELECT B.SchId,SUM(B.CrNoteAmount) AS CrNoteAmount FROM SalesInvoiceQPSSchemeAdj B (NOLOCK),SalesInvoice SI (NOLOCK)
	WHERE B.RtrId=@Pi_RtrId AND B.SchId NOT IN (SELECT SchId FROM @QPSGivenDisc)
	AND B.SchId= @Pi_SchId AND SI.SalId = B.SalId AND SI.DlvSts>3
	GROUP BY B.SchId	

	SELECT @SchemeAmt=ISNULL(SUM(Amount),0) FROM @QPSGivenDisc WHERE SchId=@Pi_SchId	
	
	SELECT @QPSFlatGiven=ISNULL(Amount,0) FROM BillQPSGivenFlat (NOLOCK) WHERE SchId=@Pi_SchId		
		
	IF @QPSFlatGiven>0 
	BEGIN	
		SELECT @SchemeAmt=0
	END

	RETURN(@SchemeAmt)

END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-184-012

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Fn_ReturnContractPricingDetails]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[Fn_ReturnContractPricingDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM Fn_ReturnContractPricingDetails(1,0,0,1,0,0 ) ORDER BY PrdDCode,PrdBatCode,PriceCode
CREATE    FUNCTION [dbo].[Fn_ReturnContractPricingDetails](@Pi_CmpId INT,@Pi_CmpPrdId INT,@Pi_PrdCtgValMainId INT,
@Pi_ContractId INT,@Pi_Mode INT,@Pi_DicMode INT)    
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
  FlatAmtDisc NUMERIC(38,6)    
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
		(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc)    
		SELECT DISTINCT B.PrdId,B.PrdDCode,B.PrdName,A.PrdBatId,PB.PrdBatCode,A.PriceId,PBD.PriceCode,    
		ISNULL(Discount,0) as Discount, ISNULL(FlatAmtDisc,0) as FlatAmtDisc     
		FROM ProductBatch PB,ProductBatchDetails PBD,ProductCategoryValue C     
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode     
		LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'    
		INNER JOIN Product B On D.PrdCtgValMainId = B.PrdCtgValMainId     
		LEFT OUTER JOIN  ContractPricingDetails A ON A.PrdId = B.PrdId AND A.ContractId= @Pi_ContractId    
		WHERE PB.PrdBatId=A.PrdBatId AND A.PriceId=PBD.PriceId AND     
		C.PrdCtgValMainId = Case @Pi_PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE @Pi_PrdCtgValMainId END AND     
		B.CmpId = Case @Pi_CmpId WHEN 0  THEN B.CmpId ELSE @Pi_CmpId END AND B.PrdStatus=1 AND PrdType<>4 AND PrdType<>3    
	      
		INSERT INTO @ContractDetails    
		(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc)    
		SELECT DISTINCT P.PrdId,P.PrdDCode,P.PrdName,PB.PrdBatId,PB.PrdBatCode,    
		PB.DefaultPriceId AS PriceId,PBD.PriceCode,0 AS Discount,0 AS FlatAmtDisc    
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
		(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc)    
		SELECT DISTINCT B.PrdId,B.PrdDCode,B.PrdName,0,'',0,'',    
		ISNULL(Discount,0) as Discount, ISNULL(FlatAmtDisc,0) as FlatAmtDisc     
		FROM ProductCategoryValue C     
		INNER JOIN ProductCategoryValue D ON D.PrdCtgValLinkCode     
		LIKE CAST(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'    
		INNER JOIN Product B On D.PrdCtgValMainId = B.PrdCtgValMainId     
		INNER JOIN   ContractPricingDetails A ON A.PrdId = B.PrdId AND A.ContractId= @Pi_ContractId    
		WHERE C.PrdCtgValMainId = Case @Pi_PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE @Pi_PrdCtgValMainId END AND     
		B.CmpId = Case @Pi_CmpId WHEN 0  THEN B.CmpId ELSE @Pi_CmpId END AND B.PrdStatus=1 AND PrdType<>4 AND PrdType<>3    
	      
		INSERT INTO @ContractDetails    
		(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc)    
		SELECT DISTINCT P.PrdId,P.PrdDCode,P.PrdName,0,'',    
		0 AS PriceId,'',0 AS Discount,0 AS FlatAmtDisc    
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
	(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc) 
	SELECT DISTINCT C.PrdCtgValMainId AS PrdId,C.PrdCtgValCode AS PrdDCode,
	C.PrdCtgValName AS PrdName,0 AS PrdBatId,'' AS PrdBatCode,0 AS PriceId,'' AS PriceCode    
	,ISNULL(Discount,0) as Discount, ISNULL(FlatAmtDisc,0) as FlatAmtDisc     
	FROM ProductCategoryValue C INNER JOIN ProductCategoryLevel G 
	ON C.CmpPrdCtgId=G.CmpPrdCtgId,ContractPricingDetails A,ContractPricingMaster E
	WHERE  A.ContractId=E.ContractId AND C.PrdCtgValMainId=A.CtgValMainId AND
	C.CmpPrdCtgId = Case E.CmpPrdCtgId WHEN 0 THEN C.CmpPrdCtgId ELSE E.CmpPrdCtgId END  
	AND C.PrdCtgValMainId = A.CtgValMainId
	AND A.ContractId= @Pi_ContractId  AND E.DisplayMode=@Pi_Mode
	INSERT INTO @ContractDetails    
	(PrdId,PrdDCode,PrdName,PrdBatId,PrdBatCode,PriceId,PriceCode,Discount,FlatAmtDisc)   
	SELECT DISTINCT PCV1.PrdCtgValMainId AS PrdId,PCV1.PrdCtgValCode AS PrdDCode,  
	PCV1.PrdCtgValName AS PrdName,0 AS PrdBatId, '' AS PrdBatCode,    
	0  AS PriceId,'' AS PriceCode,0 AS Discount,0 AS FlatAmtDisc    
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

--SRF-Nanda-184-013

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyQPSSchemeInBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyQPSSchemeInBill]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme(NOLOCK) WHERE SchId=522
--SELECT * FROM BillAppliedSchemeHd
--DELETE FROM BillAppliedSchemeHd
EXEC Proc_ApplyQPSSchemeInBill 525,1350,0,2,2
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd(NOLOCK) WHERE TransId = 2 And UsrId = 2
SELECT * FROM BillAppliedSchemeHd (NOLOCK)
SELECT * FROM ApportionSchemeDetails (NOLOCK)
--SELECT * FROM SalesInvoiceQPSCumulative(NOLOCK) WHERE SchId=522
--SELECT * FROM SchemeMaster
--SELECT * FROM Retailer
ROLLBACK TRANSACTION
*/

CREATE        Procedure [dbo].[Proc_ApplyQPSSchemeInBill]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT		
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
		SELECT '1',* FROM @TempBilled1
	END
	IF @QPS <> 0
	BEGIN
		--From all the Bills
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
		SELECT '2',* FROM @TempBilled1
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
		SELECT '3',* FROM @TempBilled1
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
		SELECT '4',* FROM @TempBilled1
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
		SELECT '5',* FROM @TempBilled1
		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
			-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
			-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
			FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
			GROUP BY PrdId,PrdBatId
--		SELECT * FROM @TempBilled1
	END
	SELECT '6',* FROM @TempBilled1
	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
		SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
		ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
		GROUP BY PrdId,PrdBatId,SchId

	--->Added By Nanda on 26/11/2010
	DELETE FROM @TempBilled WHERE SchemeOnQty+SchemeOnAmount+SchemeOnKG=0
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
	SELECT * FROM @TempBilled
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
		SELECT @SlabId
	END
	SELECT @TotalValue = ISNULL(SUM(FrmSchAch),0) FROM @TempBilledAch WHERE SlabId =1
	
	--->Added By Boo and Nanda on 29/11/2010
	IF @SchType = 3 AND @QPSReset=1
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
		SELECT 'New ',* FROM #TemAppQPSSchemes
		DELETE A FROM @TempBilledAch A WHERE NOT EXISTS ( SELECT SlabId FROM #TemAppQPSSchemes B WHERE A.SlabId=B.SlabId)
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
				SELECT @SlabAssginValue
				WHILE @SlabAssginValue > CAST(0 AS NUMERIC(38,6))
				BEGIN
					SET @AssignQty  = 0
					SET @AssignAmount = 0
					SET @AssignKG = 0
					SET @AssignLitre = 0
					SELECT @SlabAssginValue
					SELECT @FrmSchAchRem
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
				FlatAmt
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
					CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN ROUND((FreeQty*@NoOfTimes),0) ELSE FreeQty END
				WHEN 2 THEN
					CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN ROUND((FreeQty*@NoOfTimes),0) ELSE FreeQty END
				WHEN 3 THEN
					CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN ROUND((FreeQty*@NoOfTimes),0) ELSE FreeQty END
			END as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
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
	BEGIN
		SELECT DISTINCT * INTO #TempBillApplied FROM @BillAppliedSchemeHd
		DELETE FROM @BillAppliedSchemeHd
		INSERT INTO @BillAppliedSchemeHd
		SELECT * FROM #TempBillApplied
		
		UPDATE A  SET NoOfTimes=B.NoofTime,SchemeAmount=FlatAmt*B.NoofTime FROM  @BillAppliedSchemeHd A INNER JOIN #TemAppQPSSchemes B ON A.SchId=B.SchId AND A.SlabId=B.SlabId
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
	SELECT @SlabId=SlabId FROM BillAppliedSchemeHd WHERE SchId=@Pi_SchId
	AND Usrid = @Pi_UsrId AND TransId = @Pi_TransId
	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
	EXEC Proc_ApplyDiscountScheme @Pi_SchId,@Pi_UsrId,@Pi_TransId
	UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
	SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
	TransId = @Pi_TransId AND Usrid = @Pi_UsrId

	INSERT INTO @QPSGivenFlat
	SELECT SchId,SUM(FlatAmount)
	FROM
	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount,0) AS FlatAmount
	FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM ,
	(SELECT DISTINCT SchId,SlabId,SchemeDiscount,TransId,UsrId FROM BillAppliedSchemeHd) A,
	SalesInvoice SI
	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND FlexiSch=0 AND A.SchemeDiscount=0 
	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3
	AND SISl.SlabId<=A.SlabId
	) A
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

--	SELECT 'N',* FROM @QPSGivenFlat
	UPDATE BillAppliedSchemeHd SET SchemeAmount=CAST(SchemeAmount-Amount AS NUMERIC(38,4))
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId	
	AND BillAppliedSchemeHd.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)	

	--->For QPS Reset
	DECLARE @MSSchId AS INT
	DECLARE @MaxSlabId AS INT
	DECLARE @AmtToReduced AS NUMERIC(38,6)
	DECLARE Cur_QPSSlabs CURSOR FOR 
	SELECT DISTINCT SchId,SlabId
	FROM BillAppliedSchemeHd 
	WHERE SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
	ORDER BY SchId ASC ,SlabId DESC 
	OPEN Cur_QPSSlabs
	FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	WHILE @@FETCH_STATUS=0
	BEGIN
	
		IF @MaxSlabId=(SELECT MAX(SlabId) FROM BillAppliedSchemeHd WHERE SchId=@MSSchId)
		BEGIN
			IF EXISTS(SELECT * FROM @QPSGivenFlat WHERE SchId=@MSSchId)
			BEGIN
			SELECT @AmtToReduced=SchemeAmount FROM BillAppliedSchemeHd 
			WHERE SlabId=@MaxSlabId AND SchId=@MSSchId

			UPDATE BillAppliedSchemeHd SET SchemeAmount=0
			WHERE BillAppliedSchemeHd.SchId=@MSSchId AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
			END
		END
		ELSE
		BEGIN
			UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount+@AmtToReduced-Amount
			FROM  @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=@MSSchId 
			AND BillAppliedSchemeHd.SlabId=@MaxSlabId			
			AND A.SchId=BillAppliedSchemeHd.SchId
		END
		FETCH NEXT FROM Cur_QPSSlabs INTO @MSSchId,@MaxSlabId
	END
	CLOSE Cur_QPSSlabs
	DEALLOCATE Cur_QPSSlabs

--	UPDATE BillAppliedSchemeHd SET SchemeAmount=SchemeAmount-Amount
--	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId	
--	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
--	AND BillAppliedSchemeHd.SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
--	GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
--	AND CAST(BillAppliedSchemeHd.SchId AS NVARCHAR(10))+'~'+CAST(SlabId AS NVARCHAR(10)) IN 
--	(SELECT CAST(SchId AS NVARCHAR(10))+'~'+CAST(MAX(SlabId) AS NVARCHAR(10)) FROM BillAppliedSchemeHd GROUP BY SchId)	

	DELETE FROM BillAppliedSchemeHd WHERE SchemeAmount+SchemeDiscount+Points+FlxDisc+FlxValueDisc+
	FlxPoints+FreeToBeGiven+GiftToBeGiven+FlxFreePrd+FlxGiftPrd=0

--->Commented By Nanda on 27/11/2010
--	IF @QPS<>0 AND @QPSReset<>0	
--	BEGIN
--		DELETE FROM BillAppliedSchemeHd WHERE CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10))
--		NOT IN (SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BilledPrdHdForQPSScheme WHERE QPSPrd=0 AND SchId=@Pi_SchId) 
--		AND SchId=@Pi_SchId AND SchId IN (
--		SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
--		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
--		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)
--	END
--->Till Here

	IF @QPSReset<>0
	BEGIN
		UPDATE B SET B.NoOfTimes=A.NoOfTimes,B.SchemeAmount=A.SchemeAmount
		FROM BillAppliedSchemeHd B,(SELECT SchId,SlabId,MAX(NoOfTimes) AS NoOfTimes,MAX(SchemeAmount) AS SchemeAmount
			FROM BillAppliedSchemeHd GROUP BY SchId,SlabId) AS A
		WHERE B.SchId=A.SchId AND B.SlabId=A.SlabId AND B.SchId=@Pi_SchId
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
			(SELECT CAST(PrdId AS NVARCHAR(10))+'~'+CAST(PrdBatId AS NVARCHAR(10)) FROM BilledPrdHdForScheme)		
			
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
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-184-014

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_GetStockLedgerSummaryDatewise]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_GetStockLedgerSummaryDatewise]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--Exec Proc_GetStockLedgerSummaryDatewise '2010/12/20','2010/12/20',2,0,0,0
--Select * From TempStockLedSummary where userid=1 and prdid in (3,20) and lcnid=8 and
--Select * From TempStockLedSummaryTotal
--SELECT * FROM StockLedger

CREATE	PROCEDURE [dbo].[Proc_GetStockLedgerSummaryDatewise]
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
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	TRUNCATE TABLE TempStockLedSummaryTotal
	DELETE FROM TaxForReport WHERE UsrId=@Pi_UserId AND RptId=100

	IF @SupTaxGroupId+@RtrTaxFroupId>0
	BEGIN
		EXEC Proc_ReportTaxCalculation @SupTaxGroupId,@RtrTaxFroupId,1,20,5,@Pi_UserId,100
	END
	
	DECLARE @ProdDetail TABLE
		(
			lcnid	INT,
			PrdBatId INT,
			TransDate DATETIME
		)
	DELETE FROM @ProdDetail
	INSERT INTO @ProdDetail
		(
			lcnid,PrdBatId,TransDate
		)
	
	SELECT a.lcnid,a.PrdBatID,a.TransDate FROM
	(
		select lcnid,prdbatid,max(TransDate) as TransDate  FROM StockLedger Stk (nolock)
			WHERE Stk.TransDate NOT BETWEEN @Pi_FromDate AND @Pi_ToDate
		Group by lcnid,prdbatid
	) a LEFT OUTER JOIN
	(
		select distinct lcnid,prdbatid,max(TransDate) as TransDate FROM StockLedger Stk (nolock)
			WHERE Stk.TransDate BETWEEN @Pi_FromDate AND @Pi_ToDate
		Group by lcnid,prdbatid
	) b
	on a.lcnid = b.lcnid and a.prdbatid = b.prdbatid
	where b.lcnid is null and b.prdbatid is null
			
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
	WHERE PrdBat.PrdBatId IN
	(
		SELECT PrdBatId FROM 
		(
			SELECT DISTINCT A.PrdBatId,B.PrdBatId AS NewPrdBatId FROM
			ProductBatch A (nolock) LEFT OUTER JOIN StockLedger B (nolock)
			ON A.Prdid =B.Prdid
		) a
		WHERE ISNULL(NewPrdBatId,0) = 0
	) 
	AND PrdBat.PrdId=Prd.PrdId
	AND Prd.PrdCtgVAlMainId=PCV.PrdCtgValMainId
	GROUP BY Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId,Lcn.LcnName,Prd.PrdId,Prd.PrdDCode,
	Prd.PrdName,PrdBat.PrdBatId,PrdBat.PrdBatCode,PCV.PrdCtgValLinkCode,Prd.CmpId,PrdBat.Status,PrdBat.BatchSeqId
	ORDER BY TransDate,Prd.PrdId,PrdBat.PrdBatId,Lcn.LcnId

	UPDATE TempStockLedSummary SET TotalStock=(Opening+Purchase+Sales+Adjustment+Closing)
	
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

	--SELECT * FROM TempStockLedSummary ORDER BY PrdId,PrdBatId,LcnId,TransDate
	
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-184-015

IF NOT EXISTS(SELECT * FROM RptHeader WHERE RptCaption='Retailer Accounts Statement')
BEGIN
	DECLARE @RptId INT
	SET @RptId=217

	DELETE FROM RptGroup WHERE RptId=@RptId
	INSERT RptGroup(PId,RptId,GrpCode,GrpName) VALUES('DailyReports',@RptId,'RetailerAccountStatement','Retailer Accounts Statement')

	DELETE FROM RptHeader WHERE RptId=@RptId
	INSERT RptHeader(GrpCode,RptCaption,RptId,RpCaption,SPName,TblName,RptName,UserIds) VALUES('RetailerAccountStatement','Retailer Accounts Statement',@RptId,'Retailer Accounts Statement','Proc_RptRetailerAccountStatement','RptRetailerAccountStatement','RptRetailerAccountStatement.rpt','')

	DELETE FROM RptDetails WHERE RptId=@RptId
	INSERT RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES(@RptId,'1','FromDate','-1','','','From Date*','','1','','10','1','1','Enter From Date','0')
	INSERT RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES(@RptId,'2','ToDate','-1','','','To Date*','','1','','11','1','1','Enter To Date','0')
	INSERT RptDetails(RptId,SlNo,TblName,PrntId,PrntRefFld,FldName,FldCaption,PrntTbl,CtrlType,CmnFld,SelcId,SingleMulti,Mandatory,PnlMsg,CaptionChange) VALUES(@RptId,'3','Retailer','-1','','RtrId,RtrCode,RtrName','Retailer*...','','1','','3','1','1','Press F4/Double Click to Select Retailer','0')

	DELETE FROM RptExcelHeaders WHERE RptId=@RptId
	INSERT INTO RptExcelHeaders
	SELECT @RptId,1,'SlNo','SlNo',0,1 UNION ALL
	SELECT @RptId,2,'RtrId','RtrId',0,1 UNION ALL
	SELECT @RptId,3,'CoaId','CoaId',0,1 UNION ALL
	SELECT @RptId,4,'RtrName','RtrName',0,1 UNION ALL
	SELECT @RptId,5,'RtrAddress','RtrAddress',0,1 UNION ALL
	SELECT @RptId,6,'RtrTINNo','RtrTINNo',0,1 UNION ALL
	SELECT @RptId,7,'InvDate','Date',1,1 UNION ALL
	SELECT @RptId,8,'DocumentNo','Document No',1,1 UNION ALL
	SELECT @RptId,9,'Details','Particulars',1,1 UNION ALL
	SELECT @RptId,10,'RefNo','Reference No',1,1 UNION ALL
	SELECT @RptId,11,'DbAmount','Debit Amt',1,1 UNION ALL
	SELECT @RptId,12,'CrAmount','Credit Amt',1,1 UNION ALL
	SELECT @RptId,13,'BalanceAmount','Balance Amt',1,1 UNION ALL
	SELECT @RptId,15,'RtrTINNo','UOM4',0,1

	DELETE FROM RptFormula WHERE RptId=@RptId
	INSERT INTO RptFormula
	SELECT @RptId,1,'InvDate','Date',1,0 UNION ALL
	SELECT @RptId,2,'DocumentNo','Document No',1,0 UNION ALL
	SELECT @RptId,3,'Particulars','Particulars',1,0 UNION ALL
	SELECT @RptId,4,'ReferenceNo','Reference No',1,0 UNION ALL
	SELECT @RptId,5,'DebitAmt','Debit Amt',1,0 UNION ALL
	SELECT @RptId,6,'CreditAmt','Credit Amt',1,0 UNION ALL
	SELECT @RptId,7,'BalanceAmt','Balance Amt',1,0 UNION ALL
	SELECT @RptId,8,'RetailerName','Retailer Name',1,0 UNION ALL
	SELECT @RptId,9,'RetailerAddress','Retailer Address',1,0 UNION ALL
	SELECT @RptId,10,'VATTINNo','VAT/TINNo',1,0 UNION ALL
	SELECT @RptId,11,'Period','Period',1,0 UNION ALL
	SELECT @RptId,12,'Dis_FromDate','FromDate',1,10 UNION ALL
	SELECT @RptId,13,'Dis_ToDate','ToDate',1,11 UNION ALL
	SELECT @RptId,14,'Cap_UserName','User Name',1,0 UNION ALL
	SELECT @RptId,15,'Cap_PrintDate','Date',1,0 UNION ALL
	SELECT @RptId,16,'Cap_To','to',1,0 

	UPDATE RptHeader SET SPName='Proc_RptRetailerAccountStatement',RptName='RptRetailerAccountStatement.rpt',
	TblName='RptRetailerAccountStatement' WHERE RptId=@RptId
END
GO

IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[RptRetailerAccStmtsExecl]') AND type in (N'U'))
DROP TABLE [RptRetailerAccStmtsExecl]
GO
CREATE TABLE [RptRetailerAccStmtsExecl](
	[Slno] [int] NULL,
	[RtrId] [int] NULL,
	[CoaId] [int] NULL,
	[RtrName] [nvarchar](400) NULL,
	[RtrAddress] [nvarchar](400) NULL,
	[RtrTinNo] [nvarchar](100) NULL,
	[InvDate] [datetime] NULL,
	[DocumentNo] [nvarchar](200) NULL,
	[Details] [nvarchar](100) NULL,
	[Refno] [nvarchar](100) NULL,
	[DBAmount] [numeric](18, 6) NULL,
	[CRAmount] [numeric](18, 6) NULL,
	[BalanceAmount] [numeric](18, 6) NULL
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE  id = OBJECT_ID(N'[TempRetailerAccountStatement]') AND type in (N'U'))
DROP TABLE [TempRetailerAccountStatement]
GO
CREATE TABLE [TempRetailerAccountStatement](
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
) ON [PRIMARY]
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RetailerAccountStment]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RetailerAccountStment]
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
	SELECT @SLRHD=Prefix FROM Counters WHERE TabName='ReturnHeader'
	SET @SLRHD=@SLRHD + '%'
	SELECT @RTNHD=Prefix FROM Counters WHERE TabName='ReplacementHd'
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
				INNER JOIN Retailer R (NOLOCK) ON DR.RtrId=R.RtrId AND DR.CoaId<>R.CoaId
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
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Proc_RptRetailerAccountStatement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Proc_RptRetailerAccountStatement]
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


--SRF-Nanda-184-016

if not exists (Select Id,name from Syscolumns where name = 'RptId' and id in (Select id from 
	Sysobjects where name ='RptHeader'))
begin
	ALTER TABLE [dbo].[RptHeader]
	ALTER COLUMN RptId INT
END
GO

--SRF-Nanda-184-017

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
				CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
					WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
						CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) --Second Case Start
							WHEN 1 THEN  
								D.PrdBatDetailValue  
							ELSE 0 
						END     --Second Case End
					ELSE 0 
				END) + SchemeDiscount)/100))      --First Case END
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
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(F.SchId AS NVARCHAR(10))+'-'+CAST(F.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			 D.PrdBatDetailValue  END     --Second Case End
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
			Case WHEN QPS=1 THEN
			--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
			(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
			ELSE  SchemeAmount END  As SchemeAmount,
			C.GrossAmount - (C.GrossAmount /(1 +
			((CASE CAST(PD.PDSchId AS NVARCHAR(10))+'-'+CAST(PD.PDSlabId AS NVARCHAR(10))  --First Case Start
			WHEN CAST(A.SchId AS NVARCHAR(10))+'-'+CAST(A.SlabId AS NVARCHAR(10)) THEN
			CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@Pi_TransId) WHEN 1 THEN  --Second Case Start
			D.PrdBatDetailValue  ELSE 0 END     --Second Case End
			ELSE 0 END) + SchemeDiscount)/100))       --First Case END
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
		---->For Scheme on Another Product QPS
--		SELECT * FROM BillAppliedSchemeHd
--		SELECT * FROM @TempSchGross
--		SELECT * FROM @TempPrdGross
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
	--		SELECT * FROM TG
	--		SELECT * FROM TP
	--
	--		SELECT * FROM TGQ
	--		--SELECT * FROM SchMaxSlab 
	--		SELECT * FROM TPQ
	--		SELECT * FROM BillAppliedSchemeHd
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
			Case WHEN QPS=1 THEN
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

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT DISTINCT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,A.SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
		ELSE  SchemeAmount END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
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

--		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
--		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
--		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
--		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
--		Case WHEN QPS=1 THEN
--		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
--		ELSE  SchemeAmount END  As SchemeAmount
--		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
--		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
--		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
--		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
--		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
--		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
--		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
--		AND SM.CombiSch=0
--		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
--		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
--		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
--		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
--		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
		ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
		AND SM.CombiSch=0
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)

		INSERT INTO ApportionSchemeDetails (RowId,PrdId,PrdBatId,SchId,SlabId,Contri,SchemeAmount,
		SchemeDiscount,FreeQty,TransId,Usrid,DiscPer,SchType)
		SELECT C.RowId,C.PrdId,C.PrdBatId,A.SchId as Schid,SlabId as SlabId,
		(CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END) As Contri,
		Case WHEN QPS=1 THEN
		--(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		SchemeAmount 
		ELSE  (CASE SM.FlexiSch WHEN 1 THEN (SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100 
		ELSE SchemeAmount END) END  As SchemeAmount
		,(C.GrossAmount * A.SchemeDiscount)/100 As SchemeDiscount,0 As FreeQty,
		@Pi_TransId As TransId,@Pi_UsrId as UsrId,SchemeDiscount,A.SchType
		FROM BillAppliedSchemeHd A INNER JOIN @TempSchGross B ON
		A.SchId = B.SchId --AND (A.SchemeAmount + A.SchemeDiscount) > 0
		INNER JOIN @TempPrdGross C ON A.Schid = C.SchId and B.SchId = C.SchId
		AND A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
		INNER JOIN SchemeMaster SM ON SM.Schid=A.Schid and C.Schid=SM.Schid and SM.Schid=B.Schid --AND SM.QPS=0	
		AND SM.CombiSch=1
		WHERE A.UsrId = @Pi_Usrid AND A.TransId = @Pi_TransId AND IsSelected = 1
		AND SM.SchId NOT IN (SELECT SMA.SchId FROM SchemeAnotherPrdHd SMA,SchemeMaster SM WHERE SMA.SchId=SM.SchId AND SM.QPS=1)
		AND SM.SchId NOT IN (SELECT SchId FROM BillAppliedSchemeHd WHERE UsrId=@Pi_UsrId AND TransId=@Pi_TransId
		AND SchId IN (SELECT SchId FROM SchemeMaster WHERE QPS=1 AND QPSReset=1)
		GROUP BY SchId HAVING COUNT(DISTINCT SlabId)>1)		
		---->
	END
	INSERT INTO @FreeQtyDt (FreePrdid,FreePrdBatId,FreeQty)
	--SELECT FreePrdId,FreePrdBatId,Sum(FreeToBeGiven) As FreeQty from BillAppliedSchemeHd A
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
	
--	INSERT INTO @QPSGivenDisc
--	SELECT A.SchId,SUM(A.DiscountPerAmount) FROM 
--	(SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.SlabId,SISL.PrdId,SISL.PrdBatId,SISL.DiscountPerAmount
--	FROM SalesInvoiceSchemeLineWise SISL,(SELECT DISTINCT SchId,SlabId,TransId,UsrId FROM ApportionSchemeDetails 
--	WHERE SchemeAmount=0) A,SchemeMaster SM ,SalesInvoice SI,@RtrQPSIds RQPS
--	WHERE A.TransId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND SM.QPS=1 AND SM.FlexiSch=0--AND A.SchemeAmount=0 
--	AND A.SchId=SM.SchId AND SISL.SchId=A.SchId AND SI.RtrId=RQPS.RtrId AND SI.SalId=SISL.SalId AND Si.DlvSts>3
--	AND SISl.SlabId<=A.SlabId) A	
--	GROUP BY A.SchId

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
	WHERE B.RtrId=QPS.RtrID AND SI.SalId=B.SalId AND SI.DlvSts>3
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
	SELECT A.SchId,SUM(SchemeDiscount)-ISNULL(B.Amount,0) FROM ApportionSchemeDetails A
	LEFT OUTER JOIN @QPSGivenDisc B ON A.SchId=B.SchId
	GROUP BY A.SchId,B.Amount

	SELECT * FROM @QPSNowAvailable

--	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
--	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId	

	SELECT * FROM ApportionSchemeDetails
	SELECT * FROM BillQPSSchemeAdj

	UPDATE A SET A.Contri=100*(B.QPSGrossAmount/C.QPSGrossAmount)	
	FROM ApportionSchemeDetails A,@TempPrdGross B,@TempSchGross C
	WHERE A.TRansId=@Pi_TransId AND A.UsrId=@Pi_UsrId AND A.RowId=B.RowId AND 
	A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatID AND A.SchId=B.SchId AND B.SchId=C.SchId
	
	SELECT * FROM ApportionSchemeDetails
	SELECT * FROM @QPSNowAvailable

	--->Modified By Nanda
--	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
--	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
--	AND ApportionSchemeDetails.SchId NOT IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId)	

	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId NOT IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId AND AdjAmount>0)	

	UPDATE ApportionSchemeDetails SET SchemeDiscount=0
	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId
	AND ApportionSchemeDetails.SchId IN (SELECT SchId FROM BillQPSSchemeAdj WHERE UserId=@Pi_UsrId AND TransId=@Pi_TransId AND AdjAmount=0)	
	-->Till Here

--	UPDATE ASD SET SchemeAmount=Contri*AdjAmount/100,SchemeDiscount=(CASE SM.CombiSch+SM.QPS WHEN 2 THEN 0 ELSE SchemeDiscount END)
--	FROM ApportionSchemeDetails ASD,BillQPSSchemeAdj A,SchemeMaster SM 
--	WHERE ASD.SchId=A.SchId AND SM.SchId=A.SchId
--	AND ASD.UsrId=A.UserId AND ASD.TransId=A.TransId	

	UPDATE ASD SET SchemeAmount=Contri*AdjAmount/100,SchemeDiscount=0
	FROM ApportionSchemeDetails ASD,BillQPSSchemeAdj A,SchemeMaster SM 
	WHERE ASD.SchId=A.SchId AND SM.SchId=A.SchId AND ASD.SlabId=A.SlabId 
	AND ASD.UsrId=A.UserId AND ASD.TransId=A.TransId	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-184-018

if exists (select * from dbo.sysobjects where id = object_id(N'[RptBillTemplate_Scheme]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [RptBillTemplate_Scheme]
GO

CREATE TABLE [dbo].[RptBillTemplate_Scheme]
(
	[SalId] [int] NULL,
	[SalInvNo] [nvarchar](100) NULL,
	[SchId] [int] NULL,
	[SchType] [nvarchar](100) NULL,
	[CmpSchCode] [nvarchar](50) NULL,
	[SchCode] [nvarchar](100) NULL,
	[SchName] [nvarchar](200) NULL,
	[PrdId] [int] NULL,
	[PrdCCode] [nvarchar](100) NULL,
	[PrdDCode] [nvarchar](100) NULL,
	[PrdShrtName] [nvarchar](200) NULL,
	[PrdName] [nvarchar](200) NULL,
	[PrdBatId] [int] NULL,
	[PrdBatCode] [nvarchar](20) NULL,
	[Qty] [numeric](38, 0) NULL,
	[Rate] [numeric](38, 6) NULL,
	[SchemeValueInAmt] [numeric](38, 6) NULL,
	[SchemeValueInPoints] [numeric](38, 0) NULL,
	[SalInvSchemevalue] [numeric](38, 0) NULL,
	[SchemeCumulativePoints] [numeric](38, 0) NULL,
	[UsrId] [int] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-184-019

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_BillPrintingTax]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_BillPrintingTax]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_BillPrintingTax 2,1,1000

CREATE PROCEDURE [dbo].[Proc_BillPrintingTax] 
(
	@Pi_UsrId		INT,
	@Pi_FromBillNo	INT,
	@Pi_ToBillNo	INT
)
AS 
SET NOCOUNT ON
/***************************************************************************************************
* PROCEDURE		: Proc_BillPrintingTax
* PURPOSE		: General Procedure get the tax details 
* NOTES			:
* CREATED		: Nandakumar R.G
* CREATED ON	: 12/11/2010
* MODIFIED
* DATE			    AUTHOR     DESCRIPTION
----------------------------------------------------------------------------------------------------
*
****************************************************************************************************/
BEGIN
	DECLARE @TaxId	AS INT	
	DECLARE @iIdx	AS INT
	DECLARE @sSql	AS NVARCHAR(4000)

	DECLARE @FromDate	AS DATETIME
	DECLARE @ToDate		AS DATETIME

	SELECT @FromDate=FilterDate FROM ReportFilterDt WHERE SelId=10 AND UsrId=@Pi_UsrId AND RptId=16
	SELECT @ToDate=FilterDate FROM ReportFilterDt WHERE SelId=11 AND UsrId=@Pi_UsrId AND RptId=16

	SELECT @Pi_FromBillNo=MIN(SalId) FROM RptSelectedBills
	SELECT @Pi_ToBillNo=MAX(SalId) FROM RptSelectedBills

	DELETE FROM BillPrintTaxTemp WHERE UsrId=@Pi_UsrId	  

	INSERT INTO BillPrintTaxTemp(SalId,PrdId,PrdCode,PrdBatId,BatchCode,Tax1Id,Tax2Id,Tax3Id,Tax4Id,Tax5Id,
	Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax5Perc,Tax1Amount,Tax2Amount,Tax3Amount,Tax4Amount,Tax5Amount,UsrId)	
	SELECT	SIP.SalId,SIP.PrdId,P.PrdCCode,SIP.PrdBatId,PB.PrdBatCode,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
	FROM SalesInvoiceProduct SIP
	INNER JOIN Product P ON P.PrdId=SIP.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdBatId=SIP.PrdBatId AND P.PrdId=PB.PrdId
	INNER JOIN SalesInvoice SI ON SI.SalId=SIP.SalId
	WHERE SIP.SalId BETWEEN @Pi_FromBillNo AND @Pi_ToBillNo AND SI.SalInvDate BETWEEN @FromDate AND @ToDate	 
	ORDER BY SIP.SalId,SIP.PrdId,SIP.PrdBatId
	
	SELECT	SIP.SalId,SIP.PrdId,P.PrdCCode,SIP.PrdBatId,PB.PrdBatCode,ISNULL(SIPT.TaxId,0) AS TaxId,
	ISNULL(SIPT.TaxPerc,0) AS TaxPerc,ISNULL(SIPT.TaxAmount,0) AS TaxAmount 	
	INTO #SalesTaxDetails
	FROM SalesInvoiceProduct SIP
	INNER JOIN Product P ON P.PrdId=SIP.PrdId
	INNER JOIN ProductBatch PB ON PB.PrdBatId=SIP.PrdBatId AND P.PrdId=PB.PrdId
	INNER JOIN SalesInvoice SI ON SI.SalId=SIP.SalId
	LEFT OUTER JOIN SalesInvoiceProductTax SIPT ON SIP.SlNo=SIPT.PrdSlNo AND SIP.SalId=SIPT.SalId 	
	WHERE SIP.SalId BETWEEN @Pi_FromBillNo AND @Pi_ToBillNo AND SI.SalInvDate BETWEEN @FromDate AND @ToDate	 
	AND ISNULL(SIPT.TaxPerc,0)+ISNULL(SIPT.TaxAmount,0)>0
	ORDER BY SIP.SalId,SIP.PrdId,SIP.PrdBatId,SIPT.TaxId	

	SET @iIdx=1
	DECLARE Cur_Tax CURSOR FOR
	SELECT DISTINCT TaxId FROM #SalesTaxDetails ORDER BY TaxId
	OPEN Cur_Tax
	FETCH NEXT FROM Cur_Tax INTO @TaxId
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF NOT @iIdx>5
		BEGIN
			SET @sSql='UPDATE BPT SET BPT.Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id=ST.TaxId,
					   BPT.Tax'+CAST(@iIdx AS NVARCHAR(10))+'Perc=ST.TaxPerc,
					   BPT.Tax'+CAST(@iIdx AS NVARCHAR(10))+'Amount=ST.TaxAmount
					   FROM BillPrintTaxTemp BPT,
					   (
				    		SELECT SalId,PrdId,PrdCCode,PrdBatId,PrdBatCode,TaxId,TaxPerc,TaxAmount
							FROM #SalesTaxDetails WHERE TaxId='+CAST(@TaxId AS NVARCHAR(10))+'			
					   )ST
					   WHERE BPT.SalId=ST.SalId AND BPT.PrdId=ST.PrdId AND BPT.PrdBatId=ST.PrdBatId' 

			EXEC (@sSql)

			IF @iIdx>1
			BEGIN
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id,
						   Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Perc=Tax'+CAST(@iIdx AS NVARCHAR(10))+'Perc,
						   Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Amount=Tax'+CAST(@iIdx AS NVARCHAR(10))+'Amount
						   WHERE Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id=0 AND Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id>0'
				
				EXEC (@sSql)

				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id=0,
						   Tax'+CAST(@iIdx AS NVARCHAR(10))+'Perc=0,
						   Tax'+CAST(@iIdx AS NVARCHAR(10))+'Amount=0
						   WHERE Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx AS NVARCHAR(10))+'Id'

				EXEC (@sSql)
			END

			IF @iIdx>2
			BEGIN
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id,
						   Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Perc=Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Perc,
						   Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Amount=Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Amount
						   WHERE Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id=0 AND Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id>0'
				
				EXEC (@sSql)

				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id=0,
						   Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Perc=0,
						   Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Amount=0
						   WHERE Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-1 AS NVARCHAR(10))+'Id'

				EXEC (@sSql)
			END

			IF @iIdx>3
			BEGIN
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id,
						   Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Perc=Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Perc,
						   Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Amount=Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Amount
						   WHERE Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id=0 AND Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id>0'
				
				EXEC (@sSql)

				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id=0,
						   Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Perc=0,
						   Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Amount=0
						   WHERE Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-2 AS NVARCHAR(10))+'Id'

				EXEC (@sSql)
			END

			IF @iIdx>4
			BEGIN
				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id,
						   Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Perc=Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Perc,
						   Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Amount=Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Amount
						   WHERE Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Id=0 AND Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id>0'
				
				EXEC (@sSql)

				SET @sSql='UPDATE BillPrintTaxTemp SET Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id=0,
						   Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Perc=0,
						   Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Amount=0
						   WHERE Tax'+CAST(@iIdx-4 AS NVARCHAR(10))+'Id=Tax'+CAST(@iIdx-3 AS NVARCHAR(10))+'Id'

				EXEC (@sSql)
			END
		END

		SET @iIdx=@iIdx+1
		FETCH NEXT FROM Cur_Tax INTO @TaxId
	END

	CLOSE Cur_Tax
	DEALLOCATE Cur_Tax
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-184-020

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
		SISFP.PrdBatId,PB.PrdBatCode,0,PBD.PrdBatDetailValue,0,SUM(Points-ReturnPoints),0,0,@Pi_UsrId
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
		INNER JOIN RptBillToPrint R ON R.[Bill Number]=SI.SalInvNo
		GROUP BY SI.RtrId,SISP.SchId) A
		WHERE R.SalId=SI.SalId AND A.RtrId=SI.RtrId
		--->Till Here		
	End
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

--SRF-Nanda-184-021

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_RptBTBillTemplate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_RptBTBillTemplate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Proc_RptBTBillTemplate 2,1,2

CREATE PROCEDURE [dbo].[Proc_RptBTBillTemplate]
(
	@Pi_UsrId Int = 1,
	@Pi_Type INT,
	@Pi_InvDC INT
)
AS
/*********************************
* PROCEDURE		: Proc_RptBTBillTemplate
* PURPOSE		: To Get the Bill Details 
* CREATED		: Nandakumar R.G
* CREATED DATE	: 29/03/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @FROMBillId AS  VARCHAR(25)
	DECLARE @ToBillId   AS  VARCHAR(25)
	DECLARE @Cnt AS INT

	DECLARE @FromDate	AS DATETIME
	DECLARE @ToDate		AS DATETIME

	SELECT @FromDate=FilterDate FROM ReportFilterDt WHERE SelId=10 AND UsrId=@Pi_UsrId AND RptId=16
	SELECT @ToDate=FilterDate FROM ReportFilterDt WHERE SelId=11 AND UsrId=@Pi_UsrId AND RptId=16

	DECLARE @TempSalId TABLE
	(
		SalId INT
	)
	DECLARE  @RptBillTemplate Table
	(
		[Base Qty] numeric(38,0),
		[Batch Code] nvarchar(50),
		[Batch Expiry Date] datetime,
		[Batch Manufacturing Date] datetime,
		[Batch MRP] numeric(38,2),
		[Batch Selling Rate] numeric(38,2),
		[Bill Date] datetime,
		[Bill Doc Ref. Number] nvarchar(50),
		[Bill Mode] tinyint,
		[Bill Type] tinyint,
		[CD Disc Base Qty Amount] numeric(38,2),
		[CD Disc Effect Amount] numeric(38,2),
		[CD Disc Header Amount] numeric(38,2),
		[CD Disc LineUnit Amount] numeric(38,2),
		[CD Disc Qty Percentage] numeric(38,2),
		[CD Disc Unit Percentage] numeric(38,2),
		[CD Disc UOM Amount] numeric(38,2),
		[CD Disc UOM Percentage] numeric(38,2),
		[Company Address1] nvarchar(50),
		[Company Address2] nvarchar(50),
		[Company Address3] nvarchar(50),
		[Company Code] nvarchar(20),
		[Company Contact Person] nvarchar(100),
		[Company EmailId] nvarchar(50),
		[Company Fax Number] nvarchar(50),
		[Company Name] nvarchar(100),
		[Company Phone Number] nvarchar(50),
		[Contact Person] nvarchar(50),
		[CST Number] nvarchar(50),
		[DB Disc Base Qty Amount] numeric(38,2),
		[DB Disc Effect Amount] numeric(38,2),
		[DB Disc Header Amount] numeric(38,2),
		[DB Disc LineUnit Amount] numeric(38,2),
		[DB Disc Qty Percentage] numeric(38,2),
		[DB Disc Unit Percentage] numeric(38,2),
		[DB Disc UOM Amount] numeric(38,2),
		[DB Disc UOM Percentage] numeric(38,2),
		[DC DATE] DATETIME,
		[DC NUMBER] nvarchar(100),
		[Delivery Boy] nvarchar(50),
		[Delivery Date] datetime,
		[Deposit Amount] numeric(38,2),
		[Distributor Address1] nvarchar(50),
		[Distributor Address2] nvarchar(50),
		[Distributor Address3] nvarchar(50),
		[Distributor Code] nvarchar(20),
		[Distributor Name] nvarchar(50),
		[Drug Batch Description] nvarchar(50),
		[Drug Licence Number 1] nvarchar(50),
		[Drug Licence Number 2] nvarchar(50),
		[Drug1 Expiry Date] DateTime,
		[Drug2 Expiry Date] DateTime,
		[EAN Code] varchar(50),
		[EmailID] nvarchar(50),
		[Geo Level] nvarchar(50),
		[Interim Sales] tinyint,
		[Licence Number] nvarchar(50),
		[Line Base Qty Amount] numeric(38,2),
		[Line Base Qty Percentage] numeric(38,2),
		[Line Effect Amount] numeric(38,2),
		[Line Unit Amount] numeric(38,2),
		[Line Unit Percentage] numeric(38,2),
		[Line UOM1 Amount] numeric(38,2),
		[Line UOM1 Percentage] numeric(38,2),
		[LST Number] nvarchar(50),
		[Manual Free Qty] int,
		[Order Date] datetime,
		[Order Number] nvarchar(50),
		[Pesticide Expiry Date] DateTime,
		[Pesticide Licence Number] nvarchar(50),
		[PhoneNo] nvarchar(50),
		[PinCode] int,
		[Product Code] nvarchar(50),
		[Product Name] nvarchar(200),
		[Product Short Name] nvarchar(100),
		[Product SL No] Int,
		[Product Type] int,
		[Remarks] nvarchar(200),
		[Retailer Address1] nvarchar(100),
		[Retailer Address2] nvarchar(100),
		[Retailer Address3] nvarchar(100),
		[Retailer Code] nvarchar(50),
		[Retailer ContactPerson] nvarchar(100),
		[Retailer Coverage Mode] tinyint,
		[Retailer Credit Bills] int,
		[Retailer Credit Days] int,
		[Retailer Credit Limit] numeric(38,2),
		[Retailer CSTNo] nvarchar(50),
		[Retailer Deposit Amount] numeric(38,2),
		[Retailer Drug ExpiryDate] datetime,
		[Retailer Drug License No] nvarchar(50),
		[Retailer EmailId] nvarchar(100),
		[Retailer GeoLevel] nvarchar(50),
		[Retailer License ExpiryDate] datetime,
		[Retailer License No] nvarchar(50),
		[Retailer Name] nvarchar(150),
		[Retailer OffPhone1] nvarchar(50),
		[Retailer OffPhone2] nvarchar(50),
		[Retailer OnAccount] numeric(38,2),
		[Retailer Pestcide ExpiryDate] datetime,
		[Retailer Pestcide LicNo] nvarchar(50),
		[Retailer PhoneNo] nvarchar(50),
		[Retailer Pin Code] nvarchar(50),
		[Retailer ResPhone1] nvarchar(50),
		[Retailer ResPhone2] nvarchar(50),
		[Retailer Ship Address1] nvarchar(100),
		[Retailer Ship Address2] nvarchar(100),
		[Retailer Ship Address3] nvarchar(100),
		[Retailer ShipId] int,
		[Retailer TaxType] tinyint,
		[Retailer TINNo] nvarchar(50),
		[Retailer Village] nvarchar(100),
		[Route Code] nvarchar(50),
		[Route Name] nvarchar(50),
		[Sales Invoice Number] nvarchar(50),
		[SalesInvoice ActNetRateAmount] numeric(38,2),
		[SalesInvoice CDPer] numeric(9,6),
		[SalesInvoice CRAdjAmount] numeric(38,2),
		[SalesInvoice DBAdjAmount] numeric(38,2),
		[SalesInvoice GrossAmount] numeric(38,2),
		[SalesInvoice Line Gross Amount] numeric(38,2),
		[SalesInvoice Line Net Amount] numeric(38,2),
		[SalesInvoice MarketRetAmount] numeric(38,2),
		[SalesInvoice NetAmount] numeric(38,2),
		[SalesInvoice NetRateDiffAmount] numeric(38,2),
		[SalesInvoice OnAccountAmount] numeric(38,2),
		[SalesInvoice OtherCharges] numeric(38,2),
		[SalesInvoice RateDiffAmount] numeric(38,2),
		[SalesInvoice ReplacementDiffAmount] numeric(38,2),
		[SalesInvoice RoundOffAmt] numeric(38,2),
		[SalesInvoice TotalAddition] numeric(38,2),
		[SalesInvoice TotalDeduction] numeric(38,2),
		[SalesInvoice WindowDisplayAmount] numeric(38,2),
		[SalesMan Code] nvarchar(50),
		[SalesMan Name] nvarchar(50),
		[SalId] int,
		[Sch Disc Base Qty Amount] numeric(38,2),
		[Sch Disc Effect Amount] numeric(38,2),
		[Sch Disc Header Amount] numeric(38,2),
		[Sch Disc LineUnit Amount] numeric(38,2),
		[Sch Disc Qty Percentage] numeric(38,2),
		[Sch Disc Unit Percentage] numeric(38,2),
		[Sch Disc UOM Amount] numeric(38,2),
		[Sch Disc UOM Percentage] numeric(38,2),
		[Scheme Points] numeric(38,2),
		[Spl. Disc Base Qty Amount] numeric(38,2),
		[Spl. Disc Effect Amount] numeric(38,2),
		[Spl. Disc Header Amount] numeric(38,2),
		[Spl. Disc LineUnit Amount] numeric(38,2),
		[Spl. Disc Qty Percentage] numeric(38,2),
		[Spl. Disc Unit Percentage] numeric(38,2),
		[Spl. Disc UOM Amount] numeric(38,2),
		[Spl. Disc UOM Percentage] numeric(38,2),
		[Tax 1] numeric(38,2),
		[Tax 2] numeric(38,2),
		[Tax 3] numeric(38,2),
		[Tax 4] numeric(38,2),
		[Tax Amount1] numeric(38,2),
		[Tax Amount2] numeric(38,2),
		[Tax Amount3] numeric(38,2),
		[Tax Amount4] numeric(38,2),
		[Tax Amt Base Qty Amount] numeric(38,2),
		[Tax Amt Effect Amount] numeric(38,2),
		[Tax Amt Header Amount] numeric(38,2),
		[Tax Amt LineUnit Amount] numeric(38,2),
		[Tax Amt Qty Percentage] numeric(38,2),
		[Tax Amt Unit Percentage] numeric(38,2),
		[Tax Amt UOM Amount] numeric(38,2),
		[Tax Amt UOM Percentage] numeric(38,2),
		[Tax Type] tinyint,
		[TIN Number] nvarchar(50),
		[Uom 1 Desc] nvarchar(50),
		[Uom 1 Qty] int,
		[Uom 2 Desc] nvarchar(50),
		[Uom 2 Qty] int,
		[Vehicle Name] nvarchar(50),
		UsrId int,
		Visibility tinyint
	)
	IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[RptBillTemplate]') AND OBJECTPROPERTY(Id, N'IsUserTable') = 1)
	DROP TABLE [RptBillTemplate]
	TRUNCATE TABLE RptSELECTedBills
	IF @Pi_Type=1
	BEGIN
		INSERT INTO @TempSalId
		SELECT R.SelValue FROM ReportFilterDt R,SalesInvoice SI 
		WHERE RptId = 16 AND SelId = 34 AND R.SelValue=Si.SalId AND SI.SalInvDate BETWEEN @FromDate AND @ToDate

		INSERT INTO RptSELECTedBills
		SELECT SalId FROM @TempSalId
	END
	ELSE
	BEGIN
		IF @Pi_InvDC=1
		BEGIN
			DECLARE @FROMId INT
			DECLARE @ToId INT
			DECLARE @FROMSeq INT
			DECLARE @ToSeq INT

			SELECT @FROMId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=14
			SELECT @ToId=SelValue FROM ReportFilterDt WHERE RptId=16 AND SelId=15
			SELECT @FROMSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@FROMId
			SELECT @ToSeq=SeqNo FROM SalInvoiceDeliveryChallan WHERE SalId=@ToId
			
			INSERT INTO RptSELECTedBills
			SELECT SalId FROM SalInvoiceDeliveryChallan WHERE SeqNo BETWEEN @FROMSeq AND @ToSeq
		END
		ELSE
		BEGIN
			SELECT @FROMBillId=SelValue FROM ReportFilterDt WHERE RptId = 16 AND SelId = 14
			SELECT @ToBillId=SelValue FROM ReportFilterDt WHERE RptId = 16 AND SelId = 15
			INSERT INTO RptSELECTedBills
			SELECT SalId FROM SalesINvoice(NOLOCK) WHERE SalId BETWEEN @FROMBillId AND @ToBillId
		END
	END
	IF @Pi_Type=1
	BEGIN
		INSERT INTO @RptBillTemplate
		SELECT DISTINCT BaseQty,PrdBatCode,ExpDate,MnfDate,MRP,[Selling Rate],SalInvDate,SalInvRef,BillMode,BillType,
		[CD Disc_Amount_Dt],[CD Disc_EffectAmt_Dt],[CD Disc_HD],[CD Disc_UnitAmt_Dt],[CD Disc_QtyPerc_Dt],[CD Disc_UnitPerc_Dt],[CD Disc_UomAmt_Dt],
		[CD Disc_UomPerc_Dt],Address1,Address2,Address3,CmpCode,ContactPerson,EmailId,FaxNumber,CmpName,PhoneNumber,D_ContactPerson,CSTNo,
		[DB Disc_Amount_Dt],[DB Disc_EffectAmt_Dt],[DB Disc_HD],[DB Disc_UnitAmt_Dt],[DB Disc_QtyPerc_Dt],[DB Disc_UnitPerc_Dt],[DB Disc_UomAmt_Dt],
		[DB Disc_UomPerc_Dt],DCDate,DCNo,DlvBoyName,SalDlvDate,DepositAmt,DistributorAdd1,DistributorAdd2,DistributorAdd3,DistributorCode,
		DistributorName,DrugBatchDesc,DrugLicNo1,DrugLicNo2,Drug1ExpiryDate,Drug2ExpiryDate,EANCode,D_EmailID,D_GeoLevelName,InterimSales,LicNo,
		LineBaseQtyAmount,LineBaseQtyPerc,LineEffectAmount,LineUnitamount,LineUnitPerc,LineUom1Amount,LineUom1Perc,LSTNo,SalManFreeQty,OrderDate,
		OrderKeyNo,PestExpiryDate,PestLicNo,PhoneNo,PinCode,PrdCCode,PrdName,PrdShrtName,SLNo,PrdType,Remarks,RtrAdd1,RtrAdd2,RtrAdd3,RtrCode,
		RtrContactPerson,RtrCovMode,RtrCrBills,RtrCrDays,RtrCrLimit,RtrCSTNo,RtrDepositAmt,RtrDrugExpiryDate,RtrDrugLicNo,RtrEmailId,
		GeoLevelName,RtrLicExpiryDate,RtrLicNo,RtrName,RtrOffPhone1,RtrOffPhone2,RtrOnAcc,RtrPestExpiryDate,RtrPestLicNo,RtrPhoneNo,RtrPinNo,
		RtrResPhone1,RtrResPhone2,RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipId,RtrTaxType,RtrTINNo,VillageName,RMCode,RMName,SalInvNo,
		SalActNetRateAmount,SalCDPer,CRAdjAmount,DBAdjAmount,SalGrossAmount,PrdGrossAmountAftEdit,PrdNetAmount,MarketRetAmount,SalNetAmt,
		SalNetRateDiffAmount,OnAccountAmount,OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,
		WindowDisplayamount,SMCode,SMName,SalId,[Sch Disc_Amount_Dt],[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],
		[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],
		[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],
		Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],
		[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,
		Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility
		FROM
		(
			SELECT DisDt.*,RepAll.*
			FROM
			(
				SELECT D.DistributorCode,D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3, D.PinCode,D.PhoneNo,
				D.ContactPerson D_ContactPerson,D.EmailID D_EmailID,D.TaxType,D.TINNo,D.DepositAmt,GL.GeoLevelName D_GeoLevelName,
				D.CSTNo,D.LSTNo,D.LicNo,D.DrugLicNo1,D.Drug1ExpiryDate,D.DrugLicNo2,D.Drug2ExpiryDate,D.PestLicNo , D.PestExpiryDate
				FROM Distributor D WITH (NOLOCK)
				LEFT OUTER JOIN Geography G WITH (NOLOCK) ON D.GeoMainId = G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL WITH (NOLOCK) ON G.GeoLevelId = GL.GeoLevelId
			) DisDt ,
			(
				SELECT RepHD.*,RepDt.* FROM
				(
					SELECT SalesInv.* , RtrDt.*, HDAmt.* FROM
					(
						SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
						RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,
						SalRateDiffAmount,SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,
						Replacementdiffamount,TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,
						SalRoundOffAmt,V.VehicleId,V.VehicleCode,D.DlvBoyId , D.DlvBoyName 
						FROM SalesInvoice SI WITH (NOLOCK)
						INNER JOIN RptSELECTedBills RSB (NOLOCK) ON SI.SalId=RSB.SalId	--->Opt
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						--WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
					) SalesInv
					LEFT OUTER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,
						R.RtrCrLimit,R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,
						GL.GeoLevelName,RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2 , R.RtrOffPhone1, R.RtrOffPhone2, R.RtrOnAcc FROM Retailer R WITH (NOLOCK)
						INNER JOIN SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						INNER JOIN RptSELECTedBills RSB (NOLOCK) ON SI.SalId=RSB.SalId	--->Opt
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK) WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId 
						--AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					LEFT OUTER JOIN
					(
						----> By Nanda on 11/11/2010	--->Opt
--						SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
--						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
--						FROM SalesInvoice SI
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D') D ON SI.SalId = D.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E') E ON SI.SalId = E.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F') F ON SI.SalId = F.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G') G ON SI.SalId = G.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H') H ON SI.SalId = H.SalId
--						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)

						SELECT SI.SalId,  ISNULL(SUM(SIP.PrdSplDiscAmount),0) AS [Spl. Disc_HD], ISNULL(SUM(SIP.PrdSchDiscAmount),0) AS [Sch Disc_HD], 
						ISNULL(SUM(SIP.PrdDBDiscAmount),0) AS [DB Disc_HD],ISNULL(SUM(SIP.PrdCDAmount),0) AS [CD Disc_HD], ISNULL(SUM(SIP.PrdTaxAmount),0) AS [Tax Amt_HD]
						FROM SalesInvoice SI,SalesInvoiceProduct SIP,RptSelectedBills Rpt						
						WHERE SI.SalId=SIP.SalId AND Si.SalId=Rpt.SalId 
						GROUP BY SI.SalId
						----> By Nanda on 11/11/2010-Till Here
					)HDAmt ON SalesInv.SalIdHD = HDAmt.SalId
				) RepHD
				LEFT OUTER JOIN
				(
					SELECT SalesInvPrd.*,LiAmt.*,LNUOM.*,BATPRC.MRP,BATPRC.[Selling Rate]
					FROM
					(
						SELECT SPR.*,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,
							U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,SIP.Uom2Qty,SIP.BaseQty,
							SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,BPT.Tax3Perc,
							BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
							FROM SalesInvoiceProduct SIP WITH (NOLOCK)
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId
							INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.SchId,LW.slabId,LW.PrdId, LW.PrdBatId, PO.Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								INNER JOIN RptSELECTedBills RSB (NOLOCK) ON LW.SalId=RSB.SalId
								LEFT OUTER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId AND LW.SchId = PO.SchId AND
								--LW.SlabId = PO.SlabId
								LW.SlabId = PO.SlabId AND LW.PrdId=PO.PrdId AND LW.PrdBatId=PO.PrdBatId 
								--WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->OPt
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							--WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->OPt
							INNER JOIN RptSELECTedBills RSB (NOLOCK) ON SIP.SalId=RSB.SalId	--->OPt
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
--							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
--							P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,'0' Uom1Qty,
--							'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
--							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
--							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
--							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
--							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)

							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,'0' UOM1,'0' Uom1Qty,
							'0' UOM2,'0' Uom2Qty,SUM(SIP.FreeQty) BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN RptSELECTedBills RSB (NOLOCK) ON RSB.SalId=SIP.SalId		--->Opt
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							--WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
							GROUP BY SIP.SalId,SIP.FreePrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.FreePrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,SIP.FreePriceId
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax4Amount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
--							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
--							P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
--							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
--							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
--							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
--							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
--							WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SUM(SIP.GiftQty) AS BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN RptSELECTedBills RSB (NOLOCK) ON RSB.SalId=SIP.SalId	--->Opt
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							---WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
							GROUP BY SIP.SalId,SIP.GiftPrdId,P.PrdCCode,P.PrdName,P.PrdShrtName,
							P.CmpId,P.PrdType,SIP.GiftPrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,SIP.GiftPriceId
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						----> By Nanda on 12/11/2010	--->Opt
--						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
--						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
--						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
--						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
--						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
--						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
--						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
--						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
--						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
--						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
--						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
--						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
--						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
--						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
--						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
--						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
--						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
--						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
--						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt]
--						FROM SalesInvoiceProduct SI WITH (NOLOCK)
--						INNER JOIN RptSELECTedBills RSB WITH (NOLOCK) ON SI.SalId= RSB.SalId	--->Opt
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
--							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
--							FROM View_SalInvLineAmt WHERE RefCode='D'
--						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
--							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
--							FROM View_SalInvLineAmt WHERE RefCode='E'
--						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
--							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
--							FROM View_SalInvLineAmt WHERE RefCode='F'
--						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
--							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
--							FROM View_SalInvLineAmt WHERE RefCode='G'
--						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,
--							LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,LineEffectAmount
--							FROM View_SalInvLineAmt WHERE RefCode='H'
--						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
--						--WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt 	

						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						CAST(PrdSplDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Spl. Disc_UnitAmt_Dt],PrdSplDiscAmount AS [Spl. Disc_Amount_Dt],
						CAST(PrdSplDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Spl. Disc_UomAmt_Dt],CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2))AS [Spl. Disc_UnitPerc_Dt],
						CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Spl. Disc_QtyPerc_Dt],CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Spl. Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit AS [Spl. Disc_EffectAmt_Dt],

						CAST(PrdSchDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Sch Disc_UnitAmt_Dt],PrdSchDiscAmount AS [Sch Disc_Amount_Dt],
						CAST(PrdSchDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Sch Disc_UomAmt_Dt],CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [Sch Disc_UnitPerc_Dt],
						CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Sch Disc_QtyPerc_Dt],CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Sch Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit AS [Sch Disc_EffectAmt_Dt],

						CAST(PrdDBDiscAmount/BaseQty AS NUMERIC(38,6)) AS [DB Disc_UnitAmt_Dt],PrdDBDiscAmount AS [DB Disc_Amount_Dt],
						CAST(PrdDBDiscAmount/BaseQty AS NUMERIC(38,6)) AS [DB Disc_UomAmt_Dt],CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [DB Disc_UnitPerc_Dt],
						CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [DB Disc_QtyPerc_Dt],CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [DB Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit-PrdSplDiscAmount-PrdSchDiscAmount AS [DB Disc_EffectAmt_Dt],

						CAST(PrdCDAmount/BaseQty AS NUMERIC(38,6)) AS [CD Disc_UnitAmt_Dt],PrdCDAmount AS [CD Disc_Amount_Dt],
						CAST(PrdCDAmount/BaseQty AS NUMERIC(38,6)) AS [CD Disc_UomAmt_Dt],CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [CD Disc_UnitPerc_Dt],
						CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [CD Disc_QtyPerc_Dt],CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [CD Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit-PrdSplDiscAmount-PrdSchDiscAmount-PrdDBDiscAmount AS [CD Disc_EffectAmt_Dt],

						CAST(PrdTaxAmount/BaseQty AS NUMERIC(38,2)) AS [Tax Amt_UnitAmt_Dt],CAST(PrdTaxAmount AS NUMERIC(38,2) ) AS [Tax Amt_Amount_Dt],
						CAST(PrdTaxAmount/BaseQty AS NUMERIC(38,2)) AS [Tax Amt_UomAmt_Dt],CAST((PrdTaxAmount/PrdGrossAmountAftEdit)/BaseQty*100 AS NUMERIC(38,2)) AS [Tax Amt_UnitPerc_Dt],
						CAST((PrdTaxAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Tax Amt_QtyPerc_Dt],CAST((PrdTaxAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Tax Amt_UomPerc_Dt],
						PrdGrossAmountAftEdit AS [Tax Amt_EffectAmt_Dt]
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN RptSELECTedBills RSB WITH (NOLOCK) ON SI.SalId= RSB.SalId						
						--->Till Here
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1
					AND SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT SIP.SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						--FROM SalesInvoiceProduct WITH (NOLOCK)	--->Opt
						FROM SalesInvoiceProduct SIP WITH (NOLOCK) INNER JOIN RptSelectedBills RSB (NOLOCK) ON RSB.SalId=SIP.SalId --->Opt
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						--->Modified by Nanda on 11/11/2010
--						SELECT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
--						FROM
--						(
--							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
--							FROM ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
--							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1)							
--						) MRP
--						LEFT OUTER JOIN
--						(
--							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
--							FROM ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
--							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1)
--						) SelRtr ON MRP.PrdId = SelRtr.PrdId AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId
--						AND MRP.PriceId=SelRtr.PriceId

						SELECT PB.PrdId,PB.PrdBatId,PBDM.BatchSeqId,PBDM.PrdBatDetailValue 'MRP',PBDS.PrdBatDetailValue 'Selling Rate',PBDM.PriceId
						FROM ProductBatch PB WITH (NOLOCK),BatchCreation BCM WITH (NOLOCK),ProductBatchDetails PBDM WITH (NOLOCK),
						BatchCreation BCS WITH (NOLOCK),ProductBatchDetails PBDS WITH (NOLOCK)
						WHERE PBDM.BatchSeqId = BCM.BatchSeqId AND PBDM.PrdBatId = PB.PrdBatId AND PBDM.SLNo = BCM.SlNo AND BCM.MRP = 1							
						AND PBDS.BatchSeqId = BCS.BatchSeqId AND PBDS.PrdBatId = PB.PrdBatId AND PBDS.SLNo = BCS.SlNo AND BCS.SelRte = 1							
						AND PBDM.PriceId=PBDS.PriceId
						--->Till Here

					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  WHERE SalId IN (SELECT SalId FROM @TempSalId)
	END
	ELSE
	BEGIN
		INSERT INTO @RptBillTemplate
		SELECT DISTINCT BaseQty,PrdBatCode,ExpDate,MnfDate,MRP,[Selling Rate],SalInvDate,SalInvRef,BillMode,BillType,[CD Disc_Amount_Dt],
		[CD Disc_EffectAmt_Dt],[CD Disc_HD],[CD Disc_UnitAmt_Dt],[CD Disc_QtyPerc_Dt],[CD Disc_UnitPerc_Dt],[CD Disc_UomAmt_Dt],[CD Disc_UomPerc_Dt],
		Address1,Address2,Address3,CmpCode,ContactPerson,EmailId,FaxNumber,CmpName,PhoneNumber,D_ContactPerson,CSTNo,[DB Disc_Amount_Dt],
		[DB Disc_EffectAmt_Dt],[DB Disc_HD],[DB Disc_UnitAmt_Dt],[DB Disc_QtyPerc_Dt],[DB Disc_UnitPerc_Dt],[DB Disc_UomAmt_Dt],[DB Disc_UomPerc_Dt],
		DCDate,DCNo,DlvBoyName,SalDlvDate,DepositAmt,DistributorAdd1,DistributorAdd2,DistributorAdd3,DistributorCode,DistributorName,DrugBatchDesc,
		DrugLicNo1,DrugLicNo2,Drug1ExpiryDate,Drug2ExpiryDate,EANCode,D_EmailID,D_GeoLevelName,InterimSales,LicNo,LineBaseQtyAmount,LineBaseQtyPerc,
		LineEffectAmount,LineUnitamount,LineUnitPerc,LineUom1Amount,LineUom1Perc,LSTNo,SalManFreeQty,OrderDate,OrderKeyNo,PestExpiryDate,PestLicNo,
		PhoneNo,PinCode,PrdCCode,PrdName,PrdShrtName,SLNo,PrdType,Remarks,RtrAdd1,RtrAdd2,RtrAdd3,RtrCode,RtrContactPerson,RtrCovMode,
		RtrCrBills,RtrCrDays,RtrCrLimit,RtrCSTNo,RtrDepositAmt,RtrDrugExpiryDate,RtrDrugLicNo,RtrEmailId,GeoLevelName,RtrLicExpiryDate,RtrLicNo,
		RtrName,RtrOffPhone1,RtrOffPhone2,RtrOnAcc,RtrPestExpiryDate,RtrPestLicNo,RtrPhoneNo,RtrPinNo,RtrResPhone1,RtrResPhone2,
		RtrShipAdd1,RtrShipAdd2,RtrShipAdd3,RtrShipId,RtrTaxType,RtrTINNo,VillageName,RMCode,RMName,SalInvNo,SalActNetRateAmount,SalCDPer,
		CRAdjAmount,DBAdjAmount,SalGrossAmount,PrdGrossAmountAftEdit,PrdNetAmount,MarketRetAmount,SalNetAmt,SalNetRateDiffAmount,OnAccountAmount,
		OtherCharges,SalRateDiffAmount,ReplacementDiffAmount,SalRoundOffAmt,TotalAddition,TotalDeduction,WindowDisplayamount,SMCode,SMName,FinalSI.SalId,
		[Sch Disc_Amount_Dt],[Sch Disc_EffectAmt_Dt],[Sch Disc_HD],[Sch Disc_UnitAmt_Dt],[Sch Disc_QtyPerc_Dt],[Sch Disc_UnitPerc_Dt],[Sch Disc_UomAmt_Dt],
		[Sch Disc_UomPerc_Dt],Points,[Spl. Disc_Amount_Dt],[Spl. Disc_EffectAmt_Dt],[Spl. Disc_HD],[Spl. Disc_UnitAmt_Dt],[Spl. Disc_QtyPerc_Dt],
		[Spl. Disc_UnitPerc_Dt],[Spl. Disc_UomAmt_Dt],[Spl. Disc_UomPerc_Dt],Tax1Perc,Tax2Perc,Tax3Perc,Tax4Perc,Tax1Amount,Tax2Amount,Tax3Amount,
		Tax4Amount,[Tax Amt_Amount_Dt],[Tax Amt_EffectAmt_Dt],[Tax Amt_HD],[Tax Amt_UnitAmt_Dt],[Tax Amt_QtyPerc_Dt],[Tax Amt_UnitPerc_Dt],
		[Tax Amt_UomAmt_Dt],[Tax Amt_UomPerc_Dt],TaxType,TINNo,Uom1Id,Uom1Qty,Uom2Id,Uom2Qty,VehicleCode,@Pi_UsrId,1 Visibility
		FROM
		(
			SELECT DisDt.*,RepAll.*
			FROM
			(
				SELECT D.DistributorCode,D.DistributorName,D.DistributorAdd1,D.DistributorAdd2,D.DistributorAdd3, D.PinCode,D.PhoneNo,
				D.ContactPerson D_ContactPerson,D.EmailID D_EmailID,D.TaxType,D.TINNo,D.DepositAmt,GL.GeoLevelName D_GeoLevelName,
				D.CSTNo,D.LSTNo,D.LicNo,D.DrugLicNo1,D.Drug1ExpiryDate,D.DrugLicNo2,D.Drug2ExpiryDate,D.PestLicNo , D.PestExpiryDate
				FROM Distributor D WITH (NOLOCK)
				LEFT OUTER JOIN Geography G WITH (NOLOCK) ON D.GeoMainId = G.GeoMainId
				LEFT OUTER JOIN GeographyLevel GL WITH (NOLOCK) ON G.GeoLevelId = GL.GeoLevelId
			) DisDt ,
			(
				SELECT RepHD.*,RepDt.* FROM
				(
					SELECT SalesInv.* , RtrDt.*, HDAmt.* FROM
					(
						SELECT SI.SalId SalIdHD,SalInvNo,SalInvDate,SalDlvDate,SalInvRef,SM.SMID,SM.SMCode,SDC.DCDATE,SDC.DCNO,SM.SMName,
						RM.RMID,RM.RMCode,RM.RMName,RtrId,InterimSales,OrderKeyNo,OrderDate,billtype,billmode,remarks,SalGrossAmount,SalRateDiffAmount,
						SalCDPer,DBAdjAmount,CRAdjAmount,Marketretamount,OtherCharges,Windowdisplayamount,onaccountamount,Replacementdiffamount,
						TotalAddition,TotalDeduction,SalActNetRateAmount,SalNetRateDiffAmount,SalNetAmt,SalRoundOffAmt,V.VehicleId,V.VehicleCode,
						D.DlvBoyId,D.DlvBoyName
						FROM SalesInvoice SI WITH (NOLOCK)
						INNER JOIN RptSELECTedBills RSB(NOLOCK) ON RSB.SalId=SI.SalId	--->Opt
						LEFT OUTER JOIN SalInvoiceDeliveryChallan SDC ON SI.SALID=SDC.SALID
						LEFT OUTER JOIN Salesman SM WITH (NOLOCK) ON SI.SMId = SM.SMId
						LEFT OUTER JOIN RouteMaster RM WITH (NOLOCK) ON SI.RMId = RM.RMId
						LEFT OUTER JOIN Vehicle V WITH (NOLOCK) ON SI.VehicleId = V.VehicleId
						LEFT OUTER JOIN DeliveryBoy D WITH (NOLOCK) ON SI.DlvBoyId = D.DlvBoyId
						---WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->OPt
					) SalesInv
					LEFT OUTER JOIN
					(
						SELECT R.RtrId RtrId1,R.RtrCode,R.RtrName,R.RtrAdd1,R.RtrAdd2,R.RtrAdd3,R.RtrPinNo,R.RtrPhoneNo,
						R.RtrEmailId,R.RtrContactPerson,R.RtrCovMode,R.RtrTaxType,R.RtrTINNo,R.RtrCSTNo,R.RtrDepositAmt,R.RtrCrBills,R.RtrCrLimit,
						R.RtrCrDays,R.RtrLicNo,R.RtrLicExpiryDate,R.RtrDrugLicNo,R.RtrDrugExpiryDate,R.RtrPestLicNo,R.RtrPestExpiryDate,GL.GeoLevelName,
						RV.VillageName,R.RtrShipId,RS.RtrShipAdd1,RS.RtrShipAdd2,RS.RtrShipAdd3,R.RtrResPhone1,
						R.RtrResPhone2,R.RtrOffPhone1,R.RtrOffPhone2,R.RtrOnAcc
						FROM Retailer R WITH (NOLOCK)
						INNER JOIN  SalesInvoice SI WITH (NOLOCK) ON R.RtrId=SI.RtrId
						INNER JOIN RptSELECTedBills RSB(NOLOCK) ON RSB.SalId=SI.SalId	--->Opt
						LEFT OUTER JOIN RouteVillage RV WITH (NOLOCK) ON R.VillageId = RV.VillageId
						LEFT OUTER JOIN RetailerShipAdd RS WITH (NOLOCK) ON R.RtrShipId = RS.RtrShipId,
						Geography G WITH (NOLOCK),
						GeographyLevel GL WITH (NOLOCK)
						WHERE R.GeoMainId = G.GeoMainId
						AND G.GeoLevelId = GL.GeoLevelId 
						--AND SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->OPt
					) RtrDt ON SalesInv.RtrId = RtrDt.RtrId1
					LEFT OUTER JOIN
					(
						----> By Nanda on 11/11/2010	--->Opt
--						SELECT SI.SalId,  ISNULL(D.Amount,0) AS [Spl. Disc_HD], ISNULL(E.Amount,0) AS [Sch Disc_HD], ISNULL(F.Amount,0) AS [DB Disc_HD],
--						ISNULL(G.Amount,0) AS [CD Disc_HD], ISNULL(H.Amount,0) AS [Tax Amt_HD]
--						FROM SalesInvoice SI
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='D') D ON SI.SalId = D.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='E') E ON SI.SalId = E.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='F') F ON SI.SalId = F.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='G') G ON SI.SalId = G.SalId
--						INNER JOIN (SELECT SalId,BaseQtyAmount AS Amount FROM View_SalInvHDAmt WHERE RefCode='H') H ON SI.SalId = H.SalId
--						WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)

						SELECT SI.SalId,ISNULL(SUM(SIP.PrdSplDiscAmount),0) AS [Spl. Disc_HD], ISNULL(SUM(SIP.PrdSchDiscAmount),0) AS [Sch Disc_HD], 
						ISNULL(SUM(SIP.PrdDBDiscAmount),0) AS [DB Disc_HD],ISNULL(SUM(SIP.PrdCDAmount),0) AS [CD Disc_HD], ISNULL(SUM(SIP.PrdTaxAmount),0) AS [Tax Amt_HD]
						FROM SalesInvoice SI,SalesInvoiceProduct SIP,RptSelectedBills Rpt
						WHERE SI.SalId=SIP.SalId AND Si.SalId=Rpt.SalId 
						GROUP BY SI.SalId
						----> By Nanda on 11/11/2010-Till Here
					)HDAmt ON SalesInv.SalIdHD = HDAmt.SalId
				) RepHD
				LEFT OUTER JOIN
				(
					SELECT SalesInvPrd.*,LiAmt.*,LNUOM.*,BATPRC.MRP,BATPRC.[Selling Rate]
					FROM
					(
						SELECT SPR.*,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,
						C.EmailId,C.ContactPerson
						FROM
						(
							SELECT SIP.PrdGrossAmountAftEdit,SIP.PrdNetAmount,SIP.SalId SalIdDt,SIP.SlNo,SIP.PrdId,P.PrdCCode,
							P.PrdName,P.PrdShrtName,P.CmpId,P.PrdType,SIP.PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,P.EANCode,
							U1.UomDescription Uom1Id,SIP.Uom1Qty,U2.UomDescription Uom2Id,SIP.Uom2Qty,SIP.BaseQty,
							SIP.DrugBatchDesc,SIP.SalManFreeQty,ISNULL(SPO.Points,0) Points,SIP.PriceId,BPT.Tax1Perc,BPT.Tax2Perc,
							BPT.Tax3Perc,BPT.Tax4Perc,BPT.Tax5Perc,BPT.Tax1Amount,BPT.Tax2Amount,BPT.Tax3Amount,BPT.Tax4Amount,BPT.Tax5Amount
							FROM SalesInvoiceProduct SIP WITH (NOLOCK)
							LEFT OUTER JOIN BillPrintTaxTemp BPT WITH (NOLOCK) ON SIP.SalId=BPT.SalID AND SIP.PrdId=BPT.PrdId AND SIP.PrdBatId=BPT.PrdBatId
							INNER JOIN SalesInvoice SI WITH (NOLOCK) ON SIP.SalId=SI.SalId
							INNER JOIN RptSELECTedBills RSB(NOLOCK) ON RSB.SalId=SI.SalId	--->Opt
							INNER JOIN Product P WITH (NOLOCK) ON SIP.PRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.PrdBatId = PB.PrdBatId
							INNER JOIN UomMaster U1 WITH (NOLOCK) ON SIP.Uom1Id = U1.UomId
							LEFT OUTER JOIN UomMaster U2 WITH (NOLOCK) ON SIP.Uom2Id = U2.UomId
							LEFT OUTER JOIN
							(
								SELECT LW.SalId,LW.RowId,LW.SchId,LW.slabId,LW.PrdId, LW.PrdBatId, PO.Points
								FROM SalesInvoiceSchemeLineWise LW WITH (NOLOCK)
								INNER JOIN RptSELECTedBills RSB(NOLOCK) ON RSB.SalId=LW.SalId	--->Opt
								LEFT OUTER JOIN SalesInvoiceSchemeDtpoints PO WITH (NOLOCK) ON LW.SalId = PO.SalId
								AND LW.SchId = PO.SchId AND LW.SlabId = PO.SlabId
								--WHERE LW.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
							) SPO ON SIP.SalId = SPO.SalId AND SIP.SlNo = SPO.RowId AND
							SIP.PrdId = SPO.PrdId AND SIP.PrdBatId = SPO.PrdBatId
							--WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
						) SPR
						INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,0 Tax4Amount,
						0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.FreePrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.FreePrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.FreeQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.FreePriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN RptSELECTedBills RSB(NOLOCK) ON RSB.SalId=SIP.SalId	--->Opt
							INNER JOIN Product P WITH (NOLOCK) ON SIP.FreePRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.FreePrdBatId = PB.PrdBatId
							--WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
						) SPR INNER JOIN Company C WITH (NOLOCK) ON SPR.CmpId = C.CmpId
						UNION ALL
						SELECT SPR.*,0 AS Points,0 Tax1Perc,0 Tax2Perc,0 Tax3Perc,0 Tax4Perc,0 Tax5Perc,0 Tax1Amount,0 Tax2Amount,0 Tax3Amount,
						0 Tax4Amount,0 Tax5Amount,C.CmpCode,C.CmpName,C.Address1,C.Address2,C.Address3,C.PhoneNumber,C.FaxNumber,C.EmailId,C.ContactPerson
						FROM
						(
							SELECT 0 PrdGrossAmountAftEdit,0 PrdNetAmount,SIP.SalId SalIdDt,0 SlNo,SIP.GiftPrdId PrdId,P.PrdCCode,P.PrdName,
							P.PrdShrtName,P.CmpId,P.PrdType,SIP.GiftPrdBatId PrdBatId,PB.PrdBatCode,PB.MnfDate,PB.ExpDate,'' AS EANCode,
							'0' UOM1,'0' Uom1Qty,'0' UOM2,'0' Uom2Qty,SIP.GiftQty BaseQty,'0' DrugBatchDesc,'0' SalManFreeQty,SIP.GiftPriceId AS PriceId
							FROM SalesInvoiceSchemeDtFreePrd SIP WITH (NOLOCK)
							INNER JOIN RptSELECTedBills RSB(NOLOCK) ON RSB.SalId=SIP.SalId	--->Opt
							INNER JOIN Product P WITH (NOLOCK) ON SIP.GiftPRdID = P.PrdId
							INNER JOIN ProductBatch PB WITH (NOLOCK) ON SIP.GiftPrdBatId = PB.PrdBatId
							--WHERE SIP.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt
						) SPR INNER JOIN Company C ON SPR.CmpId = C.CmpId
					)SalesInvPrd
					LEFT OUTER JOIN
					(
						----> By Nanda on 12/11/2010	--->Opt
--						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
--						ISNULL(D.LineUnitAmount,0) AS [Spl. Disc_UnitAmt_Dt], ISNULL(D.Amount,0) AS [Spl. Disc_Amount_Dt],
--						ISNULL(D.LineUom1Amount,0) AS [Spl. Disc_UomAmt_Dt], ISNULL(D.LineUnitPerc,0) AS [Spl. Disc_UnitPerc_Dt],
--						ISNULL(D.LineBaseQtyPerc,0) AS [Spl. Disc_QtyPerc_Dt], ISNULL(D.LineUom1Perc,0) AS [Spl. Disc_UomPerc_Dt],
--						ISNULL(D.LineEffectAmount,0) AS [Spl. Disc_EffectAmt_Dt], ISNULL(E.LineUnitAmount,0) AS [Sch Disc_UnitAmt_Dt],
--						ISNULL(E.Amount,0) AS [Sch Disc_Amount_Dt], ISNULL(E.LineUom1Amount,0) AS [Sch Disc_UomAmt_Dt],
--						ISNULL(E.LineUnitPerc,0) AS [Sch Disc_UnitPerc_Dt], ISNULL(E.LineBaseQtyPerc,0) AS [Sch Disc_QtyPerc_Dt],
--						ISNULL(E.LineUom1Perc,0) AS [Sch Disc_UomPerc_Dt], ISNULL(E.LineEffectAmount,0) AS [Sch Disc_EffectAmt_Dt],
--						ISNULL(F.LineUnitAmount,0) AS [DB Disc_UnitAmt_Dt], ISNULL(F.Amount,0) AS [DB Disc_Amount_Dt],
--						ISNULL(F.LineUom1Amount,0) AS [DB Disc_UomAmt_Dt], ISNULL(F.LineUnitPerc,0) AS [DB Disc_UnitPerc_Dt],
--						ISNULL(F.LineBaseQtyPerc,0) AS [DB Disc_QtyPerc_Dt], ISNULL(F.LineUom1Perc,0) AS [DB Disc_UomPerc_Dt],
--						ISNULL(F.LineEffectAmount,0) AS [DB Disc_EffectAmt_Dt], ISNULL(G.LineUnitAmount,0) AS [CD Disc_UnitAmt_Dt],
--						ISNULL(G.Amount,0) AS [CD Disc_Amount_Dt], ISNULL(G.LineUom1Amount,0) AS [CD Disc_UomAmt_Dt],
--						ISNULL(G.LineUnitPerc,0) AS [CD Disc_UnitPerc_Dt], ISNULL(G.LineBaseQtyPerc,0) AS [CD Disc_QtyPerc_Dt],
--						ISNULL(G.LineUom1Perc,0) AS [CD Disc_UomPerc_Dt], ISNULL(G.LineEffectAmount,0) AS [CD Disc_EffectAmt_Dt],
--						ISNULL(H.LineUnitAmount,0) AS [Tax Amt_UnitAmt_Dt], ISNULL(H.Amount,0) AS [Tax Amt_Amount_Dt],
--						ISNULL(H.LineUom1Amount,0) AS [Tax Amt_UomAmt_Dt], ISNULL(H.LineUnitPerc,0) AS [Tax Amt_UnitPerc_Dt],
--						ISNULL(H.LineBaseQtyPerc,0) AS [Tax Amt_QtyPerc_Dt], ISNULL(H.LineUom1Perc,0) AS [Tax Amt_UomPerc_Dt],
--						ISNULL(H.LineEffectAmount,0) AS [Tax Amt_EffectAmt_Dt]
--						FROM SalesInvoiceProduct SI WITH (NOLOCK)
--						INNER JOIN RptSELECTedBills RSB WITH (NOLOCK) ON SI.SalId= RSB.SalId	--->Opt
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
--							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='D'
--						) D ON SI.SalId = D.SalId AND SI.SlNo = D.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
--							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='E'
--						) E ON SI.SalId = E.SalId AND SI.SlNo = E.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
--							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='F'
--						) F ON SI.SalId = F.SalId AND SI.SlNo = F.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
--							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='G'
--						) G ON SI.SalId = G.SalId AND SI.SlNo = G.PrdSlNo
--						INNER JOIN
--						(
--							SELECT SalId,PrdSlNo,LineUnitAmount,LineBaseQtyAmount AS Amount,LineUom1Amount,LineUnitPerc,LineBaseQtyPerc,LineUom1Perc,
--							LineEffectAmount FROM View_SalInvLineAmt WHERE RefCode='H'
--						) H ON SI.SalId = H.SalId AND SI.SlNo = H.PrdSlNo
--						--WHERE SI.SalId IN (SELECT SalId FROM RptSELECTedBills)	--->Opt

						SELECT SI.SalId SalId1,ISNULL(SI.SlNo,0) SlNo1,SI.PRdId PrdId1,SI.PRdBatId PRdBatId1,
						CAST(PrdSplDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Spl. Disc_UnitAmt_Dt],PrdSplDiscAmount AS [Spl. Disc_Amount_Dt],
						CAST(PrdSplDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Spl. Disc_UomAmt_Dt],CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2))AS [Spl. Disc_UnitPerc_Dt],
						CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Spl. Disc_QtyPerc_Dt],CAST((PrdSplDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Spl. Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit AS [Spl. Disc_EffectAmt_Dt],

						CAST(PrdSchDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Sch Disc_UnitAmt_Dt],PrdSchDiscAmount AS [Sch Disc_Amount_Dt],
						CAST(PrdSchDiscAmount/BaseQty AS NUMERIC(38,6)) AS [Sch Disc_UomAmt_Dt],CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [Sch Disc_UnitPerc_Dt],
						CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Sch Disc_QtyPerc_Dt],CAST((PrdSchDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Sch Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit AS [Sch Disc_EffectAmt_Dt],

						CAST(PrdDBDiscAmount/BaseQty AS NUMERIC(38,6)) AS [DB Disc_UnitAmt_Dt],PrdDBDiscAmount AS [DB Disc_Amount_Dt],
						CAST(PrdDBDiscAmount/BaseQty AS NUMERIC(38,6)) AS [DB Disc_UomAmt_Dt],CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [DB Disc_UnitPerc_Dt],
						CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [DB Disc_QtyPerc_Dt],CAST((PrdDBDiscAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [DB Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit-PrdSplDiscAmount-PrdSchDiscAmount AS [DB Disc_EffectAmt_Dt],

						CAST(PrdCDAmount/BaseQty AS NUMERIC(38,6)) AS [CD Disc_UnitAmt_Dt],PrdCDAmount AS [CD Disc_Amount_Dt],
						CAST(PrdCDAmount/BaseQty AS NUMERIC(38,6)) AS [CD Disc_UomAmt_Dt],CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100/BaseQty AS NUMERIC(38,2)) AS [CD Disc_UnitPerc_Dt],
						CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [CD Disc_QtyPerc_Dt],CAST((PrdCDAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [CD Disc_UomPerc_Dt],
						PrdGrossAmountAftEdit-PrdSplDiscAmount-PrdSchDiscAmount-PrdDBDiscAmount AS [CD Disc_EffectAmt_Dt],

						CAST(PrdTaxAmount/BaseQty AS NUMERIC(38,2)) AS [Tax Amt_UnitAmt_Dt],CAST(PrdTaxAmount AS NUMERIC(38,2) ) AS [Tax Amt_Amount_Dt],
						CAST(PrdTaxAmount/BaseQty AS NUMERIC(38,2)) AS [Tax Amt_UomAmt_Dt],CAST((PrdTaxAmount/PrdGrossAmountAftEdit)/BaseQty*100 AS NUMERIC(38,2)) AS [Tax Amt_UnitPerc_Dt],
						CAST((PrdTaxAmount/PrdGrossAmountAftEdit)*100 AS NUMERIC(38,2)) AS [Tax Amt_QtyPerc_Dt],CAST((PrdTaxAmount/PrdGrossAmountAftEdit)*100/Uom1Qty AS NUMERIC(38,2)) AS [Tax Amt_UomPerc_Dt],
						PrdGrossAmountAftEdit AS [Tax Amt_EffectAmt_Dt]
						FROM SalesInvoiceProduct SI WITH (NOLOCK)
						INNER JOIN RptSELECTedBills RSB WITH (NOLOCK) ON SI.SalId= RSB.SalId
						--->Till Here
					) LiAmt  ON SalesInvPrd.SalIdDt = LiAmt.SalId1 AND SalesInvPrd.PrdId = LiAmt.PrdId1 AND
					SalesInvPrd.PrdBatId = LiAmt.PRdBatId1 AND SalesInvPrd.SlNo = LiAmt.SlNo1
					LEFT OUTER JOIN
					(
						SELECT SIP.SalId SalId2,SlNo PrdSlNo2,0 LineUnitPerc,0 AS LineBaseQtyPerc,0 LineUom1Perc,Prduom1selrate LineUnitAmount,
						(Prduom1selrate * BaseQty)  LineBaseQtyAmount,PrdUom1EditedSelRate LineUom1Amount, 0 LineEffectAmount
						--FROM SalesInvoiceProduct WITH (NOLOCK)	--->Opt
						FROM SalesInvoiceProduct SIP WITH (NOLOCK) INNER JOIN RptSelectedBills RSB (NOLOCK) ON RSB.SalId=SIP.SalId --->Opt
					) LNUOM  ON SalesInvPrd.SalIdDt = LNUOM.SalId2 AND SalesInvPrd.SlNo = LNUOM.PrdSlNo2
					LEFT OUTER JOIN
					(
						--->Modified by Nanda on 11/11/2010
--						SELECT MRP.PrdId,MRP.PrdBatId,MRP.BatchSeqId,MRP.MRP,SelRtr.[Selling Rate],MRP.PriceId
--						FROM
--						(
--							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'MRP',PBV.PriceId
--							FROM ProductBatch PB WITH (NOLOCK),BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
--							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (MRP = 1 )
--						) MRP
--						LEFT OUTER JOIN
--						(
--							SELECT PB.PrdId,PB.PrdBatId,PBV.BatchSeqId, PBV.PrdBatDetailValue 'Selling Rate',PBV.PriceId
--							FROM ProductBatch PB  WITH (NOLOCK), BatchCreation BC WITH (NOLOCK), ProductBatchDetails PBV WITH (NOLOCK)
--							WHERE PBV.BatchSeqId = BC.BatchSeqId AND PBV.PrdBatId = PB.PrdBatId AND PBV.SLNo = BC.SlNo AND (SelRte= 1 )
--						) SelRtr ON MRP.PrdId = SelRtr.PrdId
--						AND MRP.PrdBatId = SelRtr.PrdBatId AND MRP.BatchSeqId = SelRtr.BatchSeqId AND MRP.PriceId=SelRtr.PriceId

						SELECT PB.PrdId,PB.PrdBatId,PBDM.BatchSeqId,PBDM.PrdBatDetailValue 'MRP',PBDS.PrdBatDetailValue 'Selling Rate',PBDM.PriceId
						FROM ProductBatch PB WITH (NOLOCK),BatchCreation BCM WITH (NOLOCK),ProductBatchDetails PBDM WITH (NOLOCK),
						BatchCreation BCS WITH (NOLOCK),ProductBatchDetails PBDS WITH (NOLOCK)
						WHERE PBDM.BatchSeqId = BCM.BatchSeqId AND PBDM.PrdBatId = PB.PrdBatId AND PBDM.SLNo = BCM.SlNo AND BCM.MRP = 1							
						AND PBDS.BatchSeqId = BCS.BatchSeqId AND PBDS.PrdBatId = PB.PrdBatId AND PBDS.SLNo = BCS.SlNo AND BCS.SelRte = 1							
						AND PBDM.PriceId=PBDS.PriceId
						--->Till Here
					) BATPRC ON SalesInvPrd.PrdId = BATPRC.PrdId AND SalesInvPrd.PrdBatId = BATPRC.PrdBatId AND BATPRC.PriceId=SalesInvPrd.PriceId
				) RepDt ON RepHd.SalIdHd = RepDt.SalIdDt
			) RepAll
		) FinalSI  
		--WHERE SalId IN (SELECT SalId FROM RptSELECTedBills)
		INNER JOIN RptSELECTedBills RSB(NOLOCK) ON RSB.SalId=FinalSI.SalId	--->Opt
	END
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[RptBTBillTemplate]')
	AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	DROP TABLE [RptBTBillTemplate]
	SELECT DISTINCT * INTO RptBTBillTemplate FROM @RptBillTemplate
	SELECT * FROM [RptBTBillTemplate]
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if not exists (select * from hotfixlog where fixid = 352)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(352,'D','2010-12-22',getdate(),1,'Core Stocky Service Pack 352')