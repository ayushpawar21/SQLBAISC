--[Stocky HotFix Version]=429
DELETE FROM Versioncontrol WHERE Hotfixid='429'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
VALUES('429','3.1.0.6','D','2016-06-29','2016-06-29','2016-06-29',CONVERT(VARCHAR(11),GETDATE()),'Product Version-Major: Product Release Dec CR')
GO
/*
	--> 6 New Reports and 6 Upload Process (CAtegory Wise Sales)
	--> Target Setting New Module
	-->Script Updater --> Proc_Cn2Cs_ProductBatch,Proc_Cn2Cs_SpecialDiscount,Proc_ApplySchemeInBill,Proc_Cs2Cn_SyncDetails
*/
IF NOT EXISTS(SELECT SC.NAME FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SC ON S.id=SC.id WHERE S.name='Etl_Prk_SchemeHD_Slabs_Rules'  
and SC.name='CircularNo')  
BEGIN  
	ALTER TABLE Etl_Prk_SchemeHD_Slabs_Rules ADD CircularNo VARCHAR(100)
END
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Cn2Cs_BLSchemeMaster')
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
	DECLARE @SchApplyOn			AS VARCHAR(100)
	DECLARE @SchApplyOnId		AS INT
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
	--ISNULL(BudgetAllocationNo,'') AS BudgetAllocationNo,
	ISNULL(CircularNo,'') AS BudgetAllocationNo,
	ISNULL(SchBasedOn,'') AS SchemeBasedOn,
	ISNULL(FBM,'No') AS FBM,
	ISNULL(SettlementType,'ALL') AS SettlementType,
	ISNULL([AllowUncheck],'NO') AS AllowUncheck,
	ISNULL([CombiType],'NORMAL') AS [CombiType],
	ISNULL(SchApplyOn,'SELLINGRATE') AS SchApplyOn
	FROM Etl_Prk_SchemeHD_Slabs_Rules (NOLOCK)
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'			 
	ORDER BY [Company Scheme Code]
	OPEN Cur_SchMaster
	FETCH NEXT FROM Cur_SchMaster INTO @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
	, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
	, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch,
	@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM,@SettlementType,@AllowUnCheck,@CombiType,@SchApplyOn	
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
		ELSE IF LTRIM(RTRIM(@SchApplyOn))= ''
		BEGIN
			SET @ErrDesc = 'Scheme Apply On should not be blank for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (72,@TabName,'CombiType',@ErrDesc)
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
		IF ((UPPER(LTRIM(RTRIM(@SchApplyOn)))<> 'SELLINGRATE') AND (UPPER(LTRIM(RTRIM(@SchApplyOn)))<> 'MRP') 
		AND (UPPER(LTRIM(RTRIM(@SchApplyOn)))<> 'PURCHASERATE'))
		BEGIN
			SET @ErrDesc = 'Scheme Apply On should be (SELLINGRATE OR MRP OR PURCHASERATE) for Scheme Code:'+@SchCode
			INSERT INTO Errorlog VALUES (72,@TabName,'CombiType',@ErrDesc)
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
			IF UPPER(LTRIM(RTRIM(@CombiType)))= 'FLUCTUATING'
				SET @CombiTypeId=1
			ELSE IF UPPER(LTRIM(RTRIM(@Range)))= 'NORMAL'
				SET @CombiTypeId=0
			
			IF UPPER(LTRIM(RTRIM(@SchApplyOn)))= 'MRP'				
				SET @SchApplyOnId=1
			ELSE IF UPPER(LTRIM(RTRIM(@SchApplyOn)))= 'SELLINGRATE'
				SET @SchApplyOnId=2
			ELSE IF UPPER(LTRIM(RTRIM(@SchApplyOn)))= 'PURCHASERATE'
				SET @SchApplyOnId=3
				
			
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
								CONVERT(VARCHAR(10),GETDATE(),121),@EditSchId,@SelMode,1,@SchApplyOnId,0,
								@BudgetAllocationNo,0,0,@SchBasedOnId,1,@FBMId,@SettlementTypeId,@AllowUnCheckId,@CombiTypeId)
				
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
					convert(varchar(10),getdate(),121),@EditSchId,@SelMode,1,@SchApplyOnId,0,@BudgetAllocationNo,0,0,
					@SchBasedOnId,1,@FBMId,@SettlementTypeId,@AllowUnCheckId,@CombiTypeId)
	
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
		@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM,@SettlementType,@AllowUnCheck,@CombiType,@SchApplyOn
	END
	CLOSE Cur_SchMaster
	DEALLOCATE Cur_SchMaster
END
GO
DELETE FROM CustomCaptions WHERE TransId = 280
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,1,1,'CoreHeaderTool','INSTITUTION','','',1,1,1,GETDATE(),1,GETDATE(),'Institutions Target Setting','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,1,2,'CoreHeaderTool','Stocky','','',1,1,1,GETDATE(),1,GETDATE(),'Stocky','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,2,1,'lblRefNo','Reference No*...','','',1,1,1,GETDATE(),1,GETDATE(),'Reference No','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,3,1,'lblFromDate','From Month','','',1,1,1,GETDATE(),1,GETDATE(),'From Date','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,4,1,'lblToDate','To Month','','',1,1,1,GETDATE(),1,GETDATE(),'To Date','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,1,'DgCommon-280-5-1','Sl No','','',1,1,1,GETDATE(),1,GETDATE(),'Sl No','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,2,'DgCommon-280-5-2','CtgMainId','','',1,1,1,GETDATE(),1,GETDATE(),'CtgMainId','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,3,'DgCommon-280-5-3','Retailer Group','','',1,1,1,GETDATE(),1,GETDATE(),'Retailer Group','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,4,'DgCommon-280-5-4','RtrId','','',1,1,1,GETDATE(),1,GETDATE(),'RtrId','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,5,'DgCommon-280-5-5','Retailer Code','','',1,1,1,GETDATE(),1,GETDATE(),'Retailer Code','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,6,'DgCommon-280-5-6','Retailer Name','','',1,1,1,GETDATE(),1,GETDATE(),'Retailer Name','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,7,'DgCommon-280-5-7','Avg Sale','','',1,1,1,GETDATE(),1,GETDATE(),'Avg Sale','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,8,'DgCommon-280-5-8','Target','','',1,1,1,GETDATE(),1,GETDATE(),'Target','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,9,'DgCommon-280-5-9','Ach.','','',1,1,1,GETDATE(),1,GETDATE(),'Achievement','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,10,'DgCommon-280-5-10','% Base Ach.','','',1,1,1,GETDATE(),1,GETDATE(),'% Base Achievement','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,11,'DgCommon-280-5-11','% Target Ach.','','',1,1,1,GETDATE(),1,GETDATE(),'% Target Achievement','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,12,'DgCommon-280-5-12','Value On Base Ach.','','',1,1,1,GETDATE(),1,GETDATE(),'Value On Base Achievement','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,13,'DgCommon-280-5-13','Value On Target Ach.','','',1,1,1,GETDATE(),1,GETDATE(),'Value On Target Achievement','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,14,'DgCommon-280-5-14','Claim Amount','','',1,1,1,GETDATE(),1,GETDATE(),'Claim Amount','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,5,15,'DgCommon-280-5-15','Liability','','',1,1,1,GETDATE(),1,GETDATE(),'Liability','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,2000,1,'HotSch-280-2000-1','Reference No','','',1,1,1,GETDATE(),1,GETDATE(),'Reference No','','',1,1)
INSERT INTO CustomCaptions([TransId],[CtrlId],[SubCtrlId],[CtrlName],[Caption],[PnlMsg],[MsgBox],[LngId],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate],[DefaultCaption],[DefaultPnlMsg],[DefaultMsgBox],[Visibility],[Enabled]) VALUES (280,1000,1,'MsgBox-280-1000-1','','','Institutions Target Confirmed cannot be edited again. Confirm If the target can be approved.',1,1,1,GETDATE(),1,GETDATE(),'','','Institutions Target Confirmed cannot be edited again. Confirm If the target can be approved',1,1)
GO
DELETE FROM HotSearchEditorHd WHERE FormId = 10209
INSERT INTO HotSearchEditorHd([FormId],[FormName],[ControlName],[SltString],[RemainsltString]) 
VALUES (10209,'InstitutionsTargetSetting','ReferenceNo','Select','SELECT InsId,InsRefNo,TargetMonth MonthId,DATENAME(MM, ''2016-''+ CAST(TargetMonth AS VARCHAR(5)) + ''-01'') + '' - '' + CAST(TargetYear AS VARCHAR(5)) FromMonth,DATENAME(MM, ''2016-''+ CAST(TargetMonth AS VARCHAR(5)) + ''-01'') + '' - '' + CAST(TargetYear AS VARCHAR(5)) ToMonth,TargetYear,Status,CASE Status WHEN 1 THEN ''Active'' Else ''InActive'' END StatusDesc,Confirm FROM InsTargetHD (NOLOCK) ORDER BY InsId')
GO
DELETE FROM HotSearchEditorDt WHERE FormId = 10209
INSERT INTO HotSearchEditorDt([Slno],[FormId],[FieldName],[AliasName],[SrchFieldNm],[Colwidth],[SortedType],[HotSearchName],[TransId])
VALUES (1,10209,'Reference No','Reference No','InsRefNo',5000,0,'HotSch-280-2000-1',280)
GO
IF NOT EXISTS(SELECT 'C' FROM Counters WHERE TabName = 'InsTargetHD')
BEGIN
	INSERT INTO Counters([TabName],[FldName],[Prefix],[Zpad],[CmpId],[CurrValue],[ModuleName],[DisplayFlag],[CurYear],[Availability],[LastModBy],[LastModDate],[AuthId],[AuthDate])
	VALUES ('InsTargetHD','InsId',NULL,0,1,0,'InstitutionsTargetSetting',1,YEAR(GETDATE()),1,1,GETDATE(),1,GETDATE())
END
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'InsTargetHD')
CREATE TABLE InsTargetHD
(
	[InsId] BIGINT PRIMARY KEY,
	[InsRefNo] [nvarchar](50) NOT NULL,
	[TargetDate] DATETIME,
	[TargetMonth] INT,
	[TargetYear] INT,
	[Status] TINYINT,
	[Confirm] TINYINT,
	[Upload] TINYINT,
	[Availability] [tinyint] NOT NULL,
	[LastModBy] [tinyint] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [tinyint] NOT NULL,
	[AuthDate] [datetime] NOT NULL
)
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'InsTargetDetails')
CREATE TABLE InsTargetDetails
(
	[InsId] BIGINT,
	[RtrCtgMainId] INT,
	[RtrId] INT,
	[AvgSal] NUMERIC(18,6),
	[Target] NUMERIC(18,6),
	[Achievement] NUMERIC(18,6),
	[BaseAch] NUMERIC(18,6),
	[TargetAch] NUMERIC(18,6),
	[ValBaseAch] NUMERIC(18,6),
	[ValTargetAch] NUMERIC(18,6),
	[ClmAmount] NUMERIC(18,6),
	[Liability] NUMERIC(18,6),
	[Availability] [tinyint] NOT NULL,
	[LastModBy] [tinyint] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [tinyint] NOT NULL,
	[AuthDate] [datetime] NOT NULL
)
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'F' AND NAME = 'FK_InsTargetDetails_InsId')
BEGIN
	ALTER TABLE InsTargetDetails ADD CONSTRAINT FK_InsTargetDetails_InsId FOREIGN KEY (InsId) REFERENCES InsTargetHD (InsId)
END
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'InsTargetSlabDetails')
CREATE TABLE InsTargetSlabDetails
(
	[InsId] BIGINT,
	[RtrId] INT,
	[SlabId] INT,
	[BaseSlab] NUMERIC(18,2),
	[BasePerc] NUMERIC(18,2),
	[TargetSlab] NUMERIC(18,2),
	[TargetPerc] NUMERIC(18,2),	 
	[Availability] [tinyint] NOT NULL,
	[LastModBy] [tinyint] NOT NULL,
	[LastModDate] [datetime] NOT NULL,
	[AuthId] [tinyint] NOT NULL,
	[AuthDate] [datetime] NOT NULL
)
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'F' AND NAME = 'FK_InsTargetSlabDetails_InsId')
BEGIN
	ALTER TABLE InsTargetSlabDetails ADD CONSTRAINT FK_InsTargetSlabDetails_InsId FOREIGN KEY (InsId) REFERENCES InsTargetHD (InsId)
END
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'InsTargetDetailsTrans')
DROP TABLE InsTargetDetailsTrans
GO
CREATE TABLE InsTargetDetailsTrans
(
	[SlNo] INT,
	[CtgMainId] INT,
	[CtgName] NVARCHAR(100),
	[RtrId] INT,
	[RtrCode]  NVARCHAR(100),
	[RtrName] NVARCHAR(100),
	[AvgSal] NUMERIC(18,6),
	[Target] NUMERIC(18,6),
	[Achievement] NUMERIC(18,6),
	[BaseAch] NUMERIC(18,6),
	[TargetAch] NUMERIC(18,6),
	[ValBaseAch] NUMERIC(18,6),
	[ValTargetAch] NUMERIC(18,6),
	[ClmAmount] NUMERIC(18,6),
	[Liability] NUMERIC(18,6),
	[UserId] INT
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_LoadingInstitutionsTarget')
DROP PROCEDURE Proc_LoadingInstitutionsTarget
GO
CREATE PROCEDURE Proc_LoadingInstitutionsTarget
(
	@iSelcId AS INT,
	@UserId AS INT
)
AS
/*********************************
* PROCEDURE		: Proc_SMIncentiveValidateNProcess
* PURPOSE		: 
* CREATED		: Aravindh Deva C
* CREATED DATE	: 07/03/2016
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}  {brief modification description}
*********************************/
BEGIN
SET NOCOUNT ON
	
		DELETE T FROM InsTargetDetailsTrans T (NOLOCK) WHERE UserId = @UserId
		
		DECLARE @Month INT
		DECLARE @Year INT
		DECLARE @Confirm TINYINT
		
		DECLARE @FromDate DATETIME
		DECLARE @ToDate DATETIME
	
		SELECT @Month = TargetMonth, @Year = TargetYear,@Confirm = Confirm
		FROM InsTargetHD H (NOLOCK) WHERE H.InsId = @iSelcId

		SELECT @FromDate = CAST(@Year AS VARCHAR(5))+ '-' + CAST(@Month AS VARCHAR(2)) + '-01'
		SELECT @ToDate = DATEADD(DD,-1,DATEADD(MM,1,@FromDate))
		
		--SELECT @FromDate FromDate,@ToDate ToDate

		SELECT C.CtgMainId,C.CtgName,R.RtrId,R.RtrCode,R.RtrName,D.AvgSal,D.[Target],D.Achievement,D.BaseAch,D.TargetAch,
		D.ValBaseAch,D.ValTargetAch,D.ClmAmount,D.Liability
		INTO #Institution
		FROM InsTargetHD H (NOLOCK)
		INNER JOIN InsTargetDetails D (NOLOCK) ON H.InsId = D.InsId
		INNER JOIN RetailerCategory C (NOLOCK) ON D.RtrCtgMainId = C.CtgMainId
		INNER JOIN RetailerValueClass V (NOLOCK) ON C.CtgMainId = V.CtgMainId
		INNER JOIN RetailerValueClassMap M (NOLOCK) ON V.RtrClassId = M.RtrValueClassId
		INNER JOIN Retailer R (NOLOCK) ON M.RtrId = R.RtrId AND D.RtrId = R.RtrId
		WHERE H.InsId = @iSelcId
		ORDER BY C.CtgName,R.RtrName
		
		IF @Confirm = 0
		BEGIN
		
			SELECT S.RtrId,CAST(SUM(S.Sales) AS NUMERIC(18,2)) Sales
			INTO #SalesAsAchievement
			FROM 
			(
			SELECT I.RtrId,SUM(S.SalGrossAmount) Sales FROM #Institution I (NOLOCK)
			INNER JOIN SalesInvoice S (NOLOCK) ON I.RtrId = S.RtrId
			WHERE S.SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3
			GROUP BY I.RtrId
			UNION ALL
			SELECT I.RtrId,-1 * SUM(R.RtnGrossAmt) FROM #Institution I (NOLOCK)
			INNER JOIN ReturnHeader R (NOLOCK) ON I.RtrId = R.RtrId
			WHERE R.ReturnDate BETWEEN @FromDate AND @ToDate AND R.Status = 0
			GROUP BY I.RtrId
			) AS S GROUP BY S.RtrId
			
			UPDATE I SET I.Achievement = A.Sales -- IF NEGATIVE?
			FROM #Institution I (NOLOCK),
			#SalesAsAchievement A (NOLOCK)
			WHERE I.RtrId = A.RtrId

			UPDATE I SET I.BaseAch = Achievement / AvgSal
			FROM #Institution I (NOLOCK),
			#SalesAsAchievement A (NOLOCK)
			WHERE I.RtrId = A.RtrId AND AvgSal <> 0

			UPDATE I SET TargetAch = Achievement / [Target] 
			FROM #Institution I (NOLOCK),
			#SalesAsAchievement A (NOLOCK)
			WHERE I.RtrId = A.RtrId AND [Target] <> 0
			
			SELECT * 
			INTO #InsTargetSlabDetails
			FROM InsTargetSlabDetails S (NOLOCK) WHERE S.InsId = @iSelcId
			
			SELECT F.InsId,F.RtrId,F.SlabId,F.BaseSlab FromBase,ISNULL(T.BaseSlab,1000000000) - 0.01 ToBase,F.BasePerc,
			F.TargetSlab FromTarget,ISNULL(T.TargetSlab,1000000000) - 0.01 ToTarget,F.TargetPerc
			INTO #SlabDetails
			FROM #InsTargetSlabDetails F (NOLOCK)
			LEFT OUTER JOIN #InsTargetSlabDetails T (NOLOCK) ON F.SlabId  = T.SlabId - 1 AND F.RtrId = T.RtrId
			
			UPDATE I SET I.ValBaseAch = I.Achievement * (BasePerc / 100)
			FROM #Institution I (NOLOCK),#SlabDetails S (NOLOCK)
			WHERE I.RtrId = S.RtrId AND I.Achievement BETWEEN FromBase AND ToBase

			UPDATE I SET I.ValTargetAch = I.Achievement * (TargetPerc / 100)
			FROM #Institution I (NOLOCK),#SlabDetails S (NOLOCK)
			WHERE I.RtrId = S.RtrId AND I.Achievement BETWEEN FromTarget AND ToTarget
			
			UPDATE I SET I.ClmAmount = (I.ValBaseAch + I.ValTargetAch)
			FROM #Institution I (NOLOCK)

			UPDATE I SET I.Liability = (I.ClmAmount) / I.Achievement
			FROM #Institution I (NOLOCK)
			WHERE I.Achievement <> 0
		
		END
		
		UPDATE I SET 
		I.AvgSal		= CAST(I.AvgSal AS NUMERIC(18,2)),
		I.[Target]		= CAST(I.[Target] AS NUMERIC(18,2)),
		I.Achievement	= CAST(I.Achievement AS NUMERIC(18,2)),
		I.BaseAch		= CAST(I.BaseAch AS NUMERIC(18,2)),
		I.TargetAch		= CAST(I.TargetAch AS NUMERIC(18,2)),
		I.ValBaseAch	= CAST(I.ValBaseAch AS NUMERIC(18,2)),
		I.ValTargetAch	= CAST(I.ValTargetAch AS NUMERIC(18,2)),
		I.ClmAmount		= CAST(I.ClmAmount AS NUMERIC(18,2)),
		I.Liability		= CAST(I.Liability AS NUMERIC(18,2))
		FROM #Institution I (NOLOCK)		
		
		INSERT INTO InsTargetDetailsTrans (SlNo,CtgMainId,CtgName,RtrId,RtrCode,RtrName,AvgSal,[Target],
		Achievement,BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability,UserId)
		
		SELECT SlNo,CtgMainId,CtgName,RtrId,RtrCode,RtrName,AvgSal,[Target],
		Achievement,BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability,@UserId UserId
		FROM
		(
		SELECT ROW_NUMBER() OVER (PARTITION BY CtgMainId ORDER BY CtgName,RtrCode) SlNo,
		CtgMainId,CtgName,RtrId,RtrCode,RtrName,AvgSal,[Target],
		Achievement,BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability 
		FROM #Institution
		UNION ALL
		SELECT 0 SlNo,CtgMainId,'ZZZZZZZZ' CtgName,0 RtrId,'ZZZZZZZZ' RtrCode,'Total' RtrName,SUM(AvgSal) AvgSal,SUM([Target]) [Target],
		SUM(Achievement) Achievement,SUM(BaseAch) BaseAch,SUM(TargetAch) TargetAch,SUM(ValBaseAch) ValBaseAch,SUM(ValTargetAch) ValTargetAch,
		SUM(ClmAmount) ClmAmount,SUM(Liability) 
		FROM #Institution ROLLUP
		GROUP BY CtgMainId
		) Consolidated ORDER BY CtgMainId,RtrCode
		
		UPDATE I SET CtgName = '',RtrCode = ''
		FROM InsTargetDetailsTrans I (NOLOCK) WHERE SlNo = 0
END
GO
DELETE FROM CustomUpDownload WHERE SlNo = 248
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile])
VALUES (248,1,'Target Setting','Target Setting','','Proc_Import_InstitutionsTargetSetting','Cn2Cs_Prk_InstitutionsTargetSetting','Proc_Validate_InstitutionsTargetSetting','Master','Download',1)
GO
DELETE FROM Tbl_DownloadIntegration WHERE SequenceNo = 56
INSERT INTO Tbl_DownloadIntegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate])
VALUES (56,'Target Setting','Cn2Cs_Prk_InstitutionsTargetSetting','Proc_Import_InstitutionsTargetSetting',0,500,GETDATE())
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'Cn2Cs_Prk_InstitutionsTargetSetting')
CREATE TABLE Cn2Cs_Prk_InstitutionsTargetSetting
(
	  DistCode VARCHAR(50),
      ProgramCode VARCHAR(50),
      ProgramYear INT,
      ProgramMonth VARCHAR(50),    
      RtrGroup VARCHAR(50),   
      RtrCode VARCHAR(50),    
      AVGSales NUMERIC(18,6),
      TargetPerc NUMERIC(18,2),
      TargetAmount NUMERIC(18,6),
      BaseSlab1 NUMERIC(18,2),
      BaseSlabPerc1 NUMERIC(18,2),
      BaseSlab2 NUMERIC(18,2),
      BaseSlabPerc2 NUMERIC(18,2),
      BaseSlab3 NUMERIC(18,2),
      BaseSlabPerc3 NUMERIC(18,2),
      TargetSlab1 NUMERIC(18,2),
      TargetSlabPerc1 NUMERIC(18,2),
      TargetSlab2 NUMERIC(18,2),
      TargetSlabPerc2 NUMERIC(18,2),
      TargetSlab3 NUMERIC(18,2),
      TargetSlabPerc3 NUMERIC(18,2),
      CreatedDate DATETIME,
      DownloadFlag VARCHAR(2)
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Import_InstitutionsTargetSetting')
DROP PROCEDURE Proc_Import_InstitutionsTargetSetting
GO
CREATE PROCEDURE Proc_Import_InstitutionsTargetSetting
(
	@Pi_Records NTEXT 
)
AS
/*********************************
* PROCEDURE	: Proc_Import_InstitutionsTargetSetting
* PURPOSE	: To Insert and Update records  from xml file in the Table Proc_Import_InstitutionsTargetSetting 
* CREATED	: Aravindh Deva C
* CREATED DATE	: 31 05 2016
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	INSERT INTO Cn2Cs_Prk_InstitutionsTargetSetting(DistCode,ProgramCode,ProgramYear,ProgramMonth,RtrGroup,RtrCode,AVGSales,TargetPerc,TargetAmount,
	BaseSlab1,BaseSlabPerc1,BaseSlab2,BaseSlabPerc2,BaseSlab3,BaseSlabPerc3,TargetSlab1,TargetSlabPerc1,
	TargetSlab2,TargetSlabPerc2,TargetSlab3,TargetSlabPerc3,CreatedDate,DownloadFlag)

	SELECT DistCode,ProgramCode,ProgramYear,ProgramMonth,RtrGroup,RtrCode,AVGSales,TargetPerc,TargetAmount,
	BaseSlab1,BaseSlabPerc1,BaseSlab2,BaseSlabPerc2,BaseSlab3,BaseSlabPerc3,TargetSlab1,TargetSlabPerc1,
	TargetSlab2,TargetSlabPerc2,TargetSlab3,TargetSlabPerc3,CreatedDate,ISNULL(DownloadFlag,'D') FROM
	OPENXML (@hdoc,'/Root/CS2Console_InstitutionsTargetSetting',1)                              
		WITH 
		(  
			DistCode		VARCHAR(50),
			ProgramCode		VARCHAR(50),
			ProgramYear		INT,
			ProgramMonth	VARCHAR(50),
			RtrGroup		VARCHAR(50),
			RtrCode			VARCHAR(50),
			AVGSales		NUMERIC(18,6),
			TargetPerc		NUMERIC(18,2),
			TargetAmount	NUMERIC(18,6),
			BaseSlab1		NUMERIC(18,2),
			BaseSlabPerc1	NUMERIC(18,2),
			BaseSlab2		NUMERIC(18,2),
			BaseSlabPerc2	NUMERIC(18,2),
			BaseSlab3		NUMERIC(18,2),
			BaseSlabPerc3	NUMERIC(18,2),
			TargetSlab1		NUMERIC(18,2),
			TargetSlabPerc1	NUMERIC(18,2),
			TargetSlab2		NUMERIC(18,2),
			TargetSlabPerc2	NUMERIC(18,2),
			TargetSlab3		NUMERIC(18,2),
			TargetSlabPerc3	NUMERIC(18,2),
			CreatedDate		DATETIME,
			DownloadFlag	VARCHAR(2)
		) XMLObj
		
	EXECUTE sp_xml_removedocument @hDoc
RETURN
END
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Validate_InstitutionsTargetSetting')
DROP PROCEDURE Proc_Validate_InstitutionsTargetSetting
GO
CREATE PROCEDURE Proc_Validate_InstitutionsTargetSetting
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_Validate_InstitutionsTargetSetting
* PURPOSE	: To Validate Proc_Validate_InstitutionsTargetSetting and move to main
* CREATED	: Aravindh Deva C
* CREATED DATE	: 20/05/2016
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
BEGIN

	SET @Po_ErrNo=0

	BEGIN TRY		
			
			DELETE PRK FROM Cn2Cs_Prk_InstitutionsTargetSetting PRK (NOLOCK) WHERE DownloadFlag='Y'
			
			SELECT DISTINCT * INTO #Cn2Cs_Prk_InstitutionsTargetSetting FROM Cn2Cs_Prk_InstitutionsTargetSetting (NOLOCK) WHERE DownloadFlag='D'
			
			IF NOT EXISTS (SELECT * FROM #Cn2Cs_Prk_InstitutionsTargetSetting (NOLOCK)) RETURN
			
			CREATE TABLE #InsToAvoid
			(
				ProgramCode VARCHAR(50),
				SlNo INT,
				TableName NVARCHAR (200),
				FieldName NVARCHAR (200),
				ErrDesc	NVARCHAR (1000)
			)
			
			SELECT DISTINCT C.CtgCode,R.CmpRtrCode,C.CtgMainId,R.RtrId
			INTO #CSCtgCode
			FROM RetailerCategory C (NOLOCK)
			INNER JOIN RetailerValueClass V (NOLOCK) ON C.CtgMainId = V.CtgMainId
			INNER JOIN RetailerValueClassMap M (NOLOCK) ON V.RtrClassId = M.RtrValueClassId
			INNER JOIN Retailer R (NOLOCK) ON M.RtrId = R.RtrId

			
			INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT ProgramCode,1,'Cn2Cs_Prk_InstitutionsTargetSetting','ProgramCode','The program code is already existing ' + 
			ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting Prk (NOLOCK) 
			WHERE EXISTS (SELECT 'C' FROM InsTargetHD C (NOLOCK) WHERE Prk.ProgramCode = C.InsRefNo)
			
			INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT ProgramCode,2,'Cn2Cs_Prk_InstitutionsTargetSetting','CtgCode','Retailer / Category / Retailer and Category mapping is not valid for Program ' + 
			ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting Prk (NOLOCK) WHERE NOT EXISTS
			(SELECT * FROM #CSCtgCode C (NOLOCK) WHERE Prk.RtrGroup = C.CtgCode AND Prk.RtrCode = C.CmpRtrCode)
			
			INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT ProgramCode,3,'Cn2Cs_Prk_InstitutionsTargetSetting','ProgramCode','No values should be NULL for the Program ' +
			ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting 
			WHERE (ProgramYear + ProgramMonth) IS NULL 
			OR (RtrGroup + RtrCode) IS NULL
			OR (AVGSales + TargetPerc + TargetAmount + BaseSlab1 + BaseSlabPerc1 + BaseSlab2 + BaseSlabPerc2 + BaseSlab3 +
			BaseSlabPerc3 + TargetSlab1 + TargetSlabPerc1 + TargetSlab2 + TargetSlabPerc2 + TargetSlab3 + TargetSlabPerc3) IS NULL

			INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT ProgramCode,4,'Cn2Cs_Prk_InstitutionsTargetSetting','TargetAmount','TargetAmount field should not be Zero Or NULL' +
			ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetSetting 
			WHERE ISNULL(TargetAmount,0) = 0
			
			INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
			SELECT DISTINCT SlNo,TableName,FieldName,ErrDesc FROM #InsToAvoid (NOLOCK)
			
			DELETE P FROM #Cn2Cs_Prk_InstitutionsTargetSetting P
			WHERE EXISTS (SELECT 'C' FROM #InsToAvoid A (NOLOCK) WHERE P.ProgramCode = A.ProgramCode)
			
			DECLARE @CurrValue AS INT
			
			SELECT @CurrValue = CurrValue FROM Counters  (NOLOCK) 
			WHERE TabName='InsTargetHD' AND FldName='InsId'
			
			--Header
			INSERT INTO InsTargetHD (InsId,InsRefNo,TargetDate,TargetMonth,TargetYear,[Status],Confirm,Upload,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			
			SELECT ROW_NUMBER() OVER(ORDER BY ProgramCode) + @CurrValue InsId,
			ProgramCode InsRefNo,GETDATE() TargetDate,ProgramMonth [TargetMonth],ProgramYear [TargetYear],1 [Status],0 Confirm,0 Upload,
			1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,MAX(CreatedDate) AuthDate			
			FROM #Cn2Cs_Prk_InstitutionsTargetSetting 
			GROUP BY ProgramCode,[ProgramMonth],[ProgramYear]
			
			--Retailer Details
			INSERT INTO InsTargetDetails (InsId,RtrCtgMainId,RtrId,AvgSal,[Target],Achievement,BaseAch,TargetAch,
			ValBaseAch,ValTargetAch,ClmAmount,Liability,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			
			SELECT DISTINCT H.InsId,C.CtgMainId,C.RtrId,P.AVGSales,P.[TargetAmount],
			0 Achievement,0 BaseAch,0 TargetAch,0 ValBaseAch,0 ValTargetAch,0 ClmAmount,0 Liability,
			1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,CreatedDate AuthDate			
			FROM #Cn2Cs_Prk_InstitutionsTargetSetting P (NOLOCK)
			INNER JOIN InsTargetHD H (NOLOCK) ON P.ProgramCode = H.InsRefNo
			INNER JOIN #CSCtgCode C (NOLOCK) ON P.RtrGroup = C.CtgCode AND P.RtrCode = C.CmpRtrCode
			ORDER BY InsId,C.CtgMainId,C.RtrId
			
			--Slab Details
			INSERT INTO InsTargetSlabDetails (InsId,RtrId,SlabId,BaseSlab,BasePerc,TargetSlab,TargetPerc,Availability,LastModBy,LastModDate,AuthId,AuthDate)
			
			SELECT InsId,RtrId,SlabId,BaseSlab,BaseSlabPerc,TargetSlab,TargetSlabPerc,
			1 Availability,1 LastModBy,GETDATE() LastModDate,1 AuthId,GETDATE() AuthDate		
			FROM
			(
			SELECT H.InsId,C.RtrId,1 SlabId,BaseSlab1 BaseSlab,BaseSlabPerc1 BaseSlabPerc,TargetSlab1 TargetSlab,TargetSlabPerc1 TargetSlabPerc
			FROM #Cn2Cs_Prk_InstitutionsTargetSetting P (NOLOCK)
			INNER JOIN InsTargetHD H (NOLOCK) ON P.ProgramCode = H.InsRefNo
			INNER JOIN #CSCtgCode C (NOLOCK) ON P.RtrGroup = C.CtgCode AND P.RtrCode = C.CmpRtrCode
			UNION ALL
			SELECT H.InsId,C.RtrId,2 SlabId,BaseSlab2,BaseSlabPerc2,TargetSlab2,TargetSlabPerc2
			FROM #Cn2Cs_Prk_InstitutionsTargetSetting P (NOLOCK)
			INNER JOIN InsTargetHD H (NOLOCK) ON P.ProgramCode = H.InsRefNo
			INNER JOIN #CSCtgCode C (NOLOCK) ON P.RtrGroup = C.CtgCode AND P.RtrCode = C.CmpRtrCode	
			UNION ALL
			SELECT H.InsId,C.RtrId,3 SlabId,BaseSlab3,BaseSlabPerc3,TargetSlab3,TargetSlabPerc3
			FROM #Cn2Cs_Prk_InstitutionsTargetSetting P (NOLOCK)
			INNER JOIN InsTargetHD H (NOLOCK) ON P.ProgramCode = H.InsRefNo
			INNER JOIN #CSCtgCode C (NOLOCK) ON P.RtrGroup = C.CtgCode AND P.RtrCode = C.CmpRtrCode
			) Slab ORDER BY InsId,RtrId,SlabId
		
			UPDATE C SET C.CurrValue = (SELECT ISNULL(MAX(InsId),0) FROM InsTargetHD (NOLOCK))
			FROM Counters C (NOLOCK)
			WHERE TabName='InsTargetHD' AND FldName='InsId'
			
			UPDATE P SET P.DownloadFlag='Y'
			FROM Cn2Cs_Prk_InstitutionsTargetSetting P (NOLOCK),
			#Cn2Cs_Prk_InstitutionsTargetSetting HP,
			InsTargetHD H (NOLOCK) WHERE P.ProgramCode = HP.ProgramCode AND P.ProgramCode = H.InsRefNo

	END TRY
	
	BEGIN CATCH
		PRINT 'There is a problem in process!'
		SET @Po_ErrNo=1 -- 1 will rollback the process through Sync EXE
		RETURN
	END CATCH		
		
RETURN
END
GO
--INS Status Begin
DELETE FROM CustomUpDownload WHERE SlNo = 249
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile])
VALUES (249,1,'Target Status','Target Status','','Proc_Import_InstitutionsTargetStatus','Cn2Cs_Prk_InstitutionsTargetStatus','Proc_Validate_InstitutionsTargetStatus','Master','Download',1)
GO
DELETE FROM Tbl_DownloadIntegration WHERE SequenceNo = 57
INSERT INTO Tbl_DownloadIntegration([SequenceNo],[ProcessName],[PrkTableName],[SPName],[TRowCount],[SelectCount],[CreatedDate])
VALUES (57,'Target Status','Cn2Cs_Prk_InstitutionsTargetStatus','Proc_Import_InstitutionsTargetStatus',0,500,GETDATE())
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'Cn2Cs_Prk_InstitutionsTargetStatus')
CREATE TABLE Cn2Cs_Prk_InstitutionsTargetStatus
(	
	DistCode VARCHAR(50),
	ProgramCode VARCHAR(50),
	ProgramStatus INT,
	CreatedDate DATETIME,
	DownloadFlag VARCHAR(2)	
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Import_InstitutionsTargetStatus')
DROP PROCEDURE Proc_Import_InstitutionsTargetStatus
GO
CREATE PROCEDURE Proc_Import_InstitutionsTargetStatus
(
	@Pi_Records NTEXT 
)
AS
/*********************************
* PROCEDURE	: Proc_Import_InstitutionsTargetStatus
* PURPOSE	: To Insert and Update records  from xml file in the Table Proc_Import_InstitutionsTargetStatus 
* CREATED	: Aravindh Deva C
* CREATED DATE	: 31 05 2016
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
SET NOCOUNT ON
BEGIN
	DECLARE @hDoc INTEGER
	
	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records
	
	INSERT INTO Cn2Cs_Prk_InstitutionsTargetStatus(DistCode,ProgramCode,ProgramStatus,CreatedDate,DownloadFlag)

	SELECT DistCode,ProgramCode,ProgramStatus,CreatedDate,ISNULL(DownloadFlag,'D') FROM
	OPENXML (@hdoc,'/Root/Console2CS_TargetStatus',1)                              
		WITH 
		(  
			DistCode VARCHAR(50),
			ProgramCode VARCHAR(50),
			ProgramStatus INT,
			CreatedDate DATETIME,
			DownloadFlag VARCHAR(2)	
		) XMLObj
		
	EXECUTE sp_xml_removedocument @hDoc
RETURN
END
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Validate_InstitutionsTargetStatus')
DROP PROCEDURE Proc_Validate_InstitutionsTargetStatus
GO
CREATE PROCEDURE Proc_Validate_InstitutionsTargetStatus
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE	: Proc_Validate_InstitutionsTargetStatus
* PURPOSE	: To Validate Proc_Validate_InstitutionsTargetStatus and move to main
* CREATED	: Aravindh Deva C
* CREATED DATE	: 20/05/2016
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/ 
BEGIN

	SET @Po_ErrNo=0
	
			
	DELETE PRK FROM Cn2Cs_Prk_InstitutionsTargetStatus PRK (NOLOCK) WHERE DownloadFlag='Y'
	
	SELECT DISTINCT P.* INTO #Cn2Cs_Prk_InstitutionsTargetStatus 
	FROM Cn2Cs_Prk_InstitutionsTargetStatus P (NOLOCK)
	INNER JOIN 
	(
	SELECT ProgramCode,MAX(CreatedDate) LatestCreatedDate 
	FROM Cn2Cs_Prk_InstitutionsTargetStatus (NOLOCK) WHERE DownloadFlag='D'
	GROUP BY ProgramCode
	) AS L ON P.ProgramCode = L.ProgramCode AND P.CreatedDate = L.LatestCreatedDate
	WHERE P.DownloadFlag='D'
	
	IF NOT EXISTS (SELECT * FROM #Cn2Cs_Prk_InstitutionsTargetStatus (NOLOCK)) RETURN
	
	CREATE TABLE #InsToAvoid
	(
		ProgramCode VARCHAR(50),
		SlNo INT,
		TableName NVARCHAR (200),
		FieldName NVARCHAR (200),
		ErrDesc	NVARCHAR (1000)
	)
	
	INSERT INTO #InsToAvoid (ProgramCode,SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT ProgramCode,1,'Cn2Cs_Prk_InstitutionsTargetSetting','ProgramCode','The program code is not existing ' + 
	ProgramCode FROM #Cn2Cs_Prk_InstitutionsTargetStatus Prk (NOLOCK) 
	WHERE NOT EXISTS (SELECT 'C' FROM InsTargetHD C (NOLOCK) WHERE Prk.ProgramCode = C.InsRefNo)
	
	INSERT INTO ErrorLog (SlNo,TableName,FieldName,ErrDesc)
	SELECT DISTINCT SlNo,TableName,FieldName,ErrDesc FROM #InsToAvoid (NOLOCK)
	
	DELETE P FROM #Cn2Cs_Prk_InstitutionsTargetStatus P
	WHERE EXISTS (SELECT 'C' FROM #InsToAvoid A (NOLOCK) WHERE P.ProgramCode = A.ProgramCode)
	
	UPDATE H SET H.[Status] = P.ProgramStatus
	FROM #Cn2Cs_Prk_InstitutionsTargetStatus P (NOLOCK),
	InsTargetHD H (NOLOCK) WHERE P.ProgramCode = H.InsRefNo
	
	UPDATE P SET P.DownloadFlag = 'Y'
	FROM #Cn2Cs_Prk_InstitutionsTargetStatus I (NOLOCK),
	Cn2Cs_Prk_InstitutionsTargetStatus P (NOLOCK)
	WHERE I.ProgramCode = P.ProgramCode

	RETURN
	
END
GO
--INS Status End
DELETE FROM CustomUpDownload WHERE SlNo = 131
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) 
VALUES (131,1,'Institutions Target Setting','Institutions Target Setting','Proc_Cs2Cn_InstitutionsTargetSetting','','Cs2Cn_Prk_InstitutionsTargetSetting','','Transaction','Upload',1)
GO
DELETE FROM Tbl_UploadIntegration WHERE SequenceNo = 1006
INSERT INTO Tbl_UploadIntegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) 
VALUES (1006,'InstitutionsTargetSetting','InstitutionsTargetSetting','Cs2Cn_Prk_InstitutionsTargetSetting',GETDATE())
GO
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'Cs2Cn_Prk_InstitutionsTargetSetting')
CREATE TABLE Cs2Cn_Prk_InstitutionsTargetSetting
(
	SlNo NUMERIC(38, 0) IDENTITY(1,1) NOT NULL,
	DistCode VARCHAR(50),
	ProgramCode VARCHAR(50),   
	RtrGroup VARCHAR(50),   
	RtrCode VARCHAR(50),    
	AvgSales NUMERIC(18,6),
	TargetAmount NUMERIC(18,6),
	Achievement NUMERIC(18,6),
	BaseAch NUMERIC(18,6),
	TargetAch NUMERIC(18,6),
	ValBaseAch NUMERIC(18,6),
	ValTargetAch NUMERIC(18,6),
	ClmAmount NUMERIC(18,6),
	Liability NUMERIC(18,6),
	UploadFlag VARCHAR(10),
	SyncId NUMERIC(38, 0),
	ServerDate DATETIME
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Cs2Cn_InstitutionsTargetSetting')
DROP PROCEDURE Proc_Cs2Cn_InstitutionsTargetSetting
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_InstitutionsTargetSetting 0,'2014-02-04'
select * from Cs2Cn_Prk_InstitutionsTargetSetting order by slno
Rollback Transaction
*/
CREATE PROCEDURE Proc_Cs2Cn_InstitutionsTargetSetting
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_InstitutionsTargetSetting 
* PURPOSE		: To Extract LMISDetails
* CREATED BY	: Aravindh Deva C
* CREATED DATE	: 27.05.2016
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	DECLARE @DistCode   As NVARCHAR(50)

	DELETE FROM Cs2Cn_Prk_InstitutionsTargetSetting WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)

	SELECT InsId,H.InsRefNo,TargetMonth,TargetYear,Confirm,
	CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01' FromDate,
	DATEADD(DD,-1,DATEADD(MM,1,CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01')) ToDate
	INTO #InstitutionToBeUpload	
	FROM InsTargetHD H (NOLOCK) WHERE H.Upload = 0 AND H.[Status] = 1

	SELECT C.CtgMainId,C.CtgCode,R.RtrId,R.CmpRtrCode,D.AvgSal,D.[Target],D.Achievement,D.BaseAch,D.TargetAch,
	D.ValBaseAch,D.ValTargetAch,D.ClmAmount,D.Liability,H.InsId,H.InsRefNo,H.FromDate,H.ToDate,H.Confirm
	INTO #Institution
	FROM #InstitutionToBeUpload H (NOLOCK)
	INNER JOIN InsTargetDetails D (NOLOCK) ON H.InsId = D.InsId
	INNER JOIN RetailerCategory C (NOLOCK) ON D.RtrCtgMainId = C.CtgMainId
	INNER JOIN RetailerValueClass V (NOLOCK) ON C.CtgMainId = V.CtgMainId
	INNER JOIN RetailerValueClassMap M (NOLOCK) ON V.RtrClassId = M.RtrValueClassId
	INNER JOIN Retailer R (NOLOCK) ON M.RtrId = R.RtrId AND D.RtrId = R.RtrId
	ORDER BY C.CtgName,R.RtrName
	
	SELECT *
	INTO #ConfirmInstitution
	FROM #Institution I (NOLOCK) WHERE I.Confirm = 1
	
	DELETE I FROM #Institution I (NOLOCK) WHERE I.Confirm = 1

	SELECT S.InsId,S.RtrId,CAST(SUM(S.Sales) AS NUMERIC(18,2)) Sales
	INTO #SalesAsAchievement
	FROM 
	(
	SELECT I.InsId,I.RtrId,SUM(S.SalGrossAmount) Sales FROM #Institution I (NOLOCK)
	INNER JOIN SalesInvoice S (NOLOCK) ON I.RtrId = S.RtrId
	WHERE S.SalInvDate BETWEEN I.FromDate AND I.ToDate AND S.DlvSts > 3
	GROUP BY I.InsId,I.RtrId
	UNION ALL
	SELECT I.InsId,I.RtrId,-1 * SUM(R.RtnGrossAmt) FROM #Institution I (NOLOCK)
	INNER JOIN ReturnHeader R (NOLOCK) ON I.RtrId = R.RtrId
	WHERE R.ReturnDate BETWEEN I.FromDate AND I.ToDate AND R.Status = 0
	GROUP BY I.InsId,I.RtrId
	) AS S GROUP BY S.InsId,S.RtrId
	
	UPDATE I SET I.Achievement = A.Sales -- IF NEGATIVE?
	FROM #Institution I (NOLOCK),
	#SalesAsAchievement A (NOLOCK)
	WHERE I.InsId = A.InsId AND I.RtrId = A.RtrId

	UPDATE I SET I.BaseAch = Achievement / AvgSal
	FROM #Institution I (NOLOCK),
	#SalesAsAchievement A (NOLOCK)
	WHERE I.InsId = A.InsId AND I.RtrId = A.RtrId AND AvgSal <> 0

	UPDATE I SET TargetAch = Achievement / [Target]
	FROM #Institution I (NOLOCK),
	#SalesAsAchievement A (NOLOCK)
	WHERE I.InsId = A.InsId AND I.RtrId = A.RtrId AND [Target] <> 0

	SELECT * 
	INTO #InsTargetSlabDetails
	FROM InsTargetSlabDetails S (NOLOCK) WHERE S.InsId IN (SELECT InsId FROM #Institution I (NOLOCK))
	
	SELECT F.InsId,F.RtrId,F.SlabId,F.BaseSlab FromBase,ISNULL(T.BaseSlab,1000000000) - 0.01 ToBase,F.BasePerc,
	F.TargetSlab FromTarget,ISNULL(T.TargetSlab,1000000000) - 0.01 ToTarget,F.TargetPerc
	INTO #SlabDetails
	FROM #InsTargetSlabDetails F (NOLOCK)
	LEFT OUTER JOIN #InsTargetSlabDetails T (NOLOCK) ON F.SlabId  = T.SlabId - 1 AND F.RtrId = T.RtrId AND F.InsId = T.InsId
	
	UPDATE I SET I.ValBaseAch = I.Achievement * (BasePerc / 100)
	FROM #Institution I (NOLOCK),#SlabDetails S (NOLOCK)
	WHERE I.InsId = S.InsId AND I.RtrId = S.RtrId AND I.Achievement BETWEEN FromBase AND ToBase

	UPDATE I SET I.ValTargetAch = I.Achievement * (TargetPerc / 100)
	FROM #Institution I (NOLOCK),#SlabDetails S (NOLOCK)
	WHERE I.InsId = S.InsId AND I.RtrId = S.RtrId AND I.Achievement BETWEEN FromTarget AND ToTarget
	
	UPDATE I SET I.ClmAmount = (I.ValBaseAch + I.ValTargetAch)
	FROM #Institution I (NOLOCK)

	UPDATE I SET I.Liability = I.ClmAmount / I.Achievement
	FROM #Institution I (NOLOCK)
	WHERE I.Achievement <> 0

	UPDATE I SET 
	I.AvgSal		= CAST(I.AvgSal AS NUMERIC(18,2)),
	I.[Target]		= CAST(I.[Target] AS NUMERIC(18,2)),
	I.Achievement	= CAST(I.Achievement AS NUMERIC(18,2)),
	I.BaseAch		= CAST(I.BaseAch AS NUMERIC(18,2)),
	I.TargetAch		= CAST(I.TargetAch AS NUMERIC(18,2)),
	I.ValBaseAch	= CAST(I.ValBaseAch AS NUMERIC(18,2)),
	I.ValTargetAch	= CAST(I.ValTargetAch AS NUMERIC(18,2)),
	I.ClmAmount		= CAST(I.ClmAmount AS NUMERIC(18,2)),
	I.Liability		= CAST(I.Liability AS NUMERIC(18,2))
	FROM #Institution I (NOLOCK)

	INSERT INTO Cs2Cn_Prk_InstitutionsTargetSetting (DistCode,ProgramCode,RtrGroup,RtrCode,AvgSales,TargetAmount,Achievement,
	BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability,UploadFlag,SyncId,ServerDate)
	
	SELECT @DistCode,InsRefNo,CtgCode,CmpRtrCode,AvgSal,[Target],Achievement,
	BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability,'N',NULL,@ServerDate FROM #Institution
	UNION ALL
	SELECT @DistCode,InsRefNo,CtgCode,CmpRtrCode,AvgSal,[Target],Achievement,
	BaseAch,TargetAch,ValBaseAch,ValTargetAch,ClmAmount,Liability,'N',NULL,@ServerDate FROM #ConfirmInstitution
	
	UPDATE H SET H.Upload = 1
	FROM InsTargetHD H (NOLOCK),
	Cs2Cn_Prk_InstitutionsTargetSetting P (NOLOCK),
	#ConfirmInstitution C (NOLOCK) 
	WHERE H.InsRefNo = P.ProgramCode AND H.InsRefNo = C.InsRefNo
	
	RETURN			

END
GO
DELETE FROM CustomUpDownloadCount WHERE SlNo=238
INSERT INTO CustomUpDownloadCount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery])
VALUES (238,1,'Target Setting','Target Setting','Cn2Cs_Prk_InstitutionsTargetSetting','Cn2Cs_Prk_InstitutionsTargetSetting','DownloadFlag','','','Download','0',0,'0',0,0,'SELECT DISTINCT ''Institutions Target'' AS [Target],ProgramCode AS [Target Ref No] FROM Cn2Cs_Prk_InstitutionsTargetSetting (NOLOCK) WHERE DownLoadFlag=''Y''')
GO
DELETE FROM CustomUpDownloadCount WHERE SlNo=239
INSERT INTO CustomUpDownloadCount([SlNo],[SeqNo],[Module],[Screen],[ParkTable],[MainTable],[KeyField1],[KeyField2],[KeyField3],[UpDownload],[OldMax],[OldCount],[NewMax],[NewCount],[DownloadedCount],[SelectQuery])
VALUES (239,1,'Target Status','Target Status','Cn2Cs_Prk_InstitutionsTargetStatus','Cn2Cs_Prk_InstitutionsTargetStatus','DownloadFlag','','','Download','0',0,'0',0,0,'SELECT CASE ProgramStatus WHEN  1 THEN ''Active'' ELSE ''Active''  END AS [Target Status],ProgramCode AS [Target Ref No] FROM Cn2Cs_Prk_InstitutionsTargetStatus (NOLOCK) WHERE DownLoadFlag=''Y'' ORDER BY CreatedDate')
GO
IF EXISTS (SELECT '' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_DownloadNotification')
DROP PROCEDURE Proc_DownloadNotification
GO
/*
BEGIN TRANSACTION
EXEC Proc_DownloadNotification 1,2
--SELECT SelectQuery,* FROM CustomUpDownloadCount WHERE UpDownload='Download' AND SelectQuery<>''
--ORDER BY SlNo
--SELECT * FROM Cs2Cn_Prk_DownloadedDetails
ROLLBACK TRANSACTION 
*/
CREATE PROCEDURE Proc_DownloadNotification
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
					select @Module
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
					IF @Module<>'Purchase Order'
					BEGIN
						SELECT @Str='UPDATE CustomUpDownloadCount SET NewMax=A.NewMax,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT('+@KeyField1+'),0) AS NewCount FROM '+@MainTable+' WHERE DownLoadFlag=''Y'') A
						WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo
					END
					ELSE
					BEGIN
						SELECT @Str='UPDATE CustomUpDownloadCount SET NewMax=A.NewMax,NewCount=A.NewCount FROM (SELECT ISNULL(MAX('+@KeyField1+'),0) AS NewMax,ISNULL(COUNT(DISTINCT '+@KeyField3+'),0) AS NewCount FROM '+@MainTable+' WHERE DownLoadFlag=''Y'') A
						WHERE CustomUpDownloadCount.SlNo='+CAST(@SlNo AS NVARCHAR(100)) FROM CustomUpDownloadCount WHERE SlNo=@SlNo
					END
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
				IF UPPER(LTRIM(LTRIM(@Module)))<>'KITITEM'
				BEGIN
					SELECT @Str=REPLACE(SelectQuery,'OldMax',OldMax) FROM CustomUpDownloadCount WHERE UpDownload='Download' AND SlNo=@SlNo
				END
				IF @Str<>''
				BEGIN

					IF @SlNo = 238
					BEGIN
						SET @Str=REPLACE(@Str,'SELECT DISTINCT ',' SELECT DISTINCT '''+@DistCode+''','''+@Module+''',')
					END
					ELSE
					BEGIN				
						SET @Str=REPLACE(@Str,'SELECT ',' SELECT '''+@DistCode+''','''+@Module+''',')
					END

					
					IF @SlNo=218 OR @SlNo=214
					BEGIN
						SET @Str='INSERT INTO Cs2Cn_Prk_DownloadedDetails(DistCode,Process,Detail1,Detail2,Detail3) '+@Str
					END
					ELSE
					BEGIN
						SET @Str='INSERT INTO Cs2Cn_Prk_DownloadedDetails(DistCode,Process,Detail1,Detail2)'+@Str
					END

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
--6 Processes
IF NOT EXISTS(SELECT SC.NAME FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SC ON S.id=SC.id WHERE S.name='SalesInvoice'  
and SC.name='RptUpload')  
BEGIN  
	ALTER TABLE SalesInvoice ADD RptUpload TINYINT
END
GO
UPDATE S SET S.RptUpload = 1 FROM SalesInvoice S (NOLOCK) WHERE DlvSts >= 3 AND RptUpload IS NULL
UPDATE S SET S.RptUpload = 0 FROM SalesInvoice S (NOLOCK) WHERE DlvSts < 3 AND RptUpload IS NULL
GO
IF NOT EXISTS(SELECT SC.NAME FROM SYSOBJECTS S INNER JOIN SYSCOLUMNS SC ON S.id=SC.id WHERE S.name='ReturnHeader'  
and SC.name='RptUpload')  
BEGIN  
	ALTER TABLE ReturnHeader ADD RptUpload TINYINT
END
GO
UPDATE S SET S.RptUpload = 1 FROM ReturnHeader S (NOLOCK) WHERE Status = 0 AND RptUpload IS NULL
UPDATE S SET S.RptUpload = 0 FROM ReturnHeader S (NOLOCK) WHERE Status = 1 AND RptUpload IS NULL
GO
IF NOT EXISTS (SELECT '' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'UploadingReportTransaction')
CREATE TABLE UploadingReportTransaction
(
TransType TINYINT,
TransId BIGINT,
TransNo NVARCHAR(100),
TransDate DATETIME
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'ParleOutputTaxPercentage')
DROP TABLE ParleOutputTaxPercentage
GO
CREATE TABLE ParleOutputTaxPercentage
(
	[TransId] [tinyint] NULL,
	[SalId] [numeric](36, 0) NULL,
	[PrdSlno] [int] NULL,
	[TaxPerc] [numeric](36, 4) NULL
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_ReturnSalesProductTaxPercentage')
DROP PROCEDURE Proc_ReturnSalesProductTaxPercentage
GO
--EXEC Proc_ReturnSalesProductTaxPercentage '2012-09-28 ','2012-10-03 '
--SELECT * FROM OutputTaxPercentage
CREATE PROCEDURE Proc_ReturnSalesProductTaxPercentage
(
@Pi_Fromdate AS DATETIME,
@Pi_ToDate AS DATETIME
)
AS
/*********************************
* PROCEDURE	: Proc_ReturnSalesProductTaxPercentage
* PURPOSE	: To Return Sales Product Taxpercent
* CREATED	: Murugan.R
* CREATED DATE	: 18/06/2012
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
BEGIN
	SET NOCOUNT ON
	
	TRUNCATE TABLE ParleOutputTaxPercentage
	
	CREATE TABLE #SalesTax
	(
		SalId NUMERIC(36,0),
		PrdSlno INT,
		TaxPerc NUMERIC(36,4),
		TaxableAmount NUMERIC(36,4)
	)
		
	INSERT INTO #SalesTax(Salid,PrdSlno,TaxPerc,TaxableAmount)
	SELECT S.Salid,PrdSlno,SUM(TaxPerc) as TaxPerc,TaxableAmount 
	FROM SalesInvoiceProductTax S (NOLOCK) INNER JOIN SalesInvoice SI (NOLOCK) ON S.SalId=SI.Salid
	WHERE  TaxableAmount>0 and DlvSts > 3
	AND SI.SalInvDate Between @Pi_Fromdate AND @Pi_ToDate  
	GROUP BY S.Salid,PrdSlno,TaxableAmount ORDER BY Prdslno
	
	SELECT Salid,PrdSlno Into #TaxCess FROM #SalesTax 
	GROUP BY Salid,PrdSlno
	HAVING Count(PrdSlno)>1
	
	SELECT TT.Salid,TT.PrdSlno, TaxPerc,TaxableAmount INTO #TaxCess1 FROM #SalesTax TT
	INNER JOIN #TaxCess T ON T.SalId= TT.Salid and T.PrdSlNo=TT.PrdSlno
	
	DELETE A FROM #SalesTax  A INNER JOIN #TaxCess B ON A.Salid=B.Salid and A.PrdSlno=B.PrdSlno
	
	SELECT Salid,PrdSlno,Max(TaxableAmount) as TaxableAmount INTO #MaxTaxable FROM #TaxCess1 
	GROUP BY Salid,PrdSlno
	
	SELECT Salid,PrdSlno,Min(TaxableAmount) as TaxableAmount INTO #MinTaxable FROM #TaxCess1 
	GROUP BY Salid,PrdSlno
			
	INSERT INTO #SalesTax(Salid,PrdSlno,TaxPerc,TaxableAmount)
	SELECT Salid,Prdslno,SUM(TaxPercMain)+(SUM(TaxPercMain)*SUM((TaxPercCess/100))),0
	FROM (
			SELECT A.Salid,A.PrdSlno,A.TaxPerc as TaxPercMain,0 as TaxPercCess 
			FROM #TaxCess1 A INNER JOIN #MaxTaxable B ON A.Salid=B.Salid 
			and A.Prdslno=B.PrdSlno and A.TaxableAmount=B.TaxableAmount		
			UNION ALL
			SELECT A.Salid,A.PrdSlno,0 as TaxPercMain,TaxPerc as TaxPercCess 
			FROM #TaxCess1 A INNER JOIN #MinTaxable B ON A.Salid=B.Salid 
			and A.Prdslno=B.PrdSlno and A.TaxableAmount=B.TaxableAmount	
		 
	)X GROUP BY Salid,Prdslno
	
	INSERT INTO ParleOutputTaxPercentage(TransId,Salid,PrdSlno,TaxPerc)
	SELECT 1,Salid,PrdSlno,TaxPerc
	FROM #SalesTax
	
	DELETE FROM #SalesTax
	
	INSERT INTO #SalesTax(Salid,PrdSlno,TaxPerc,TaxableAmount)
	SELECT S.ReturnId,PrdSlno,SUM(TaxPerc) as TaxPerc,TaxableAmt 
	FROM ReturnProductTax S INNER JOIN ReturnHeader SI ON S.ReturnId=SI.ReturnId
	WHERE  TaxableAmt>0 and SI.Status=0
	AND SI.ReturnDate Between @Pi_Fromdate AND @Pi_ToDate
	GROUP BY S.ReturnId,PrdSlno,TaxableAmt ORDER BY PrdSlno
	
	SELECT Salid,PrdSlno Into #ReturnTaxCess FROM #SalesTax 
	GROUP BY Salid,PrdSlno
	HAVING Count(PrdSlno)>1
	
	SELECT TT.Salid,TT.PrdSlno, TaxPerc,TaxableAmount INTO #ReturnTaxCess1 
	FROM #SalesTax TT
	INNER JOIN #ReturnTaxCess T ON T.SalId= TT.Salid and T.PrdSlNo=TT.PrdSlno
	
	DELETE A FROM #SalesTax  A INNER JOIN #ReturnTaxCess B ON A.Salid=B.Salid and A.PrdSlno=B.PrdSlno
	
	SELECT Salid,PrdSlno,Max(TaxableAmount) as TaxableAmount INTO #RetMaxTaxable FROM #ReturnTaxCess1 
	GROUP BY Salid,PrdSlno
	
	SELECT Salid,PrdSlno,Min(TaxableAmount) as TaxableAmount INTO #RetMinTaxable FROM #ReturnTaxCess1 
	GROUP BY Salid,PrdSlno
	
	INSERT INTO #SalesTax(Salid,PrdSlno,TaxPerc,TaxableAmount)
	SELECT Salid,Prdslno,SUM(TaxPercMain)+(SUM(TaxPercMain)*SUM((TaxPercCess/100))),0
	FROM (
			SELECT A.Salid,A.PrdSlno,A.TaxPerc as TaxPercMain,0 as TaxPercCess 
			FROM #ReturnTaxCess1 A INNER JOIN #RetMaxTaxable B ON A.Salid=B.Salid 
			and A.Prdslno=B.PrdSlno and A.TaxableAmount=B.TaxableAmount		
			UNION ALL
			SELECT A.Salid,A.PrdSlno,0 as TaxPercMain,TaxPerc as TaxPercCess 
			FROM #ReturnTaxCess1 A INNER JOIN #RetMinTaxable B ON A.Salid=B.Salid 
			and A.Prdslno=B.PrdSlno and A.TaxableAmount=B.TaxableAmount	
		 
	)X GROUP BY Salid,Prdslno
	
	INSERT INTO ParleOutputTaxPercentage(TransId,Salid,PrdSlno,TaxPerc)
	SELECT 2,Salid,PrdSlno,TaxPerc
	FROM #SalesTax
	
END
GO
DELETE FROM CustomUpDownload WHERE SlNo = 132
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) 
VALUES (132,1,'Railway Discount Reconsolidation','RailwayDiscountReconsolidation','Proc_Cs2Cn_RailwayDiscountReconsolidation','','Cs2Cn_Prk_RailwayDiscountReconsolidation','','Transaction','Upload',1)
GO
DELETE FROM Tbl_UploadIntegration WHERE SequenceNo = 1007
INSERT INTO Tbl_UploadIntegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) 
VALUES (1007,'RailwayDiscountReconsolidation','RailwayDiscountReconsolidation','Cs2Cn_Prk_RailwayDiscountReconsolidation',GETDATE())
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'Cs2Cn_Prk_RailwayDiscountReconsolidation')
CREATE TABLE Cs2Cn_Prk_RailwayDiscountReconsolidation
(
	[SlNo] NUMERIC(38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] NVARCHAR(50),
	[TransDate] DATETIME,
	[CmpRtrCode] NVARCHAR(50),
	[PrdCCode] NVARCHAR(100),
	[TotalPCS] NUMERIC(18, 0),
	[MRP] NUMERIC(18, 6),
	[LCTR] NUMERIC(18,6),
	[IRCTCMargin] NUMERIC(18,2),
	[MarkUpDown] NVARCHAR(50),
	[IRCTCRate] NUMERIC(18,6),
	[TotalMRP] NUMERIC(18, 6),
	[TotalLCTR] NUMERIC(18,6),
	[IRCTCTotal] NUMERIC(18,6),
	[ClmAmount] NUMERIC(18,6),
	[LibOnMRP] NUMERIC(18,2),
	[LibOnLCTR] NUMERIC(18,2),
	[UploadFlag] NVARCHAR(10),
	[SyncId] NUMERIC(38, 0),
	[ServerDate] DATETIME
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Cs2Cn_RailwayDiscountReconsolidation')
DROP PROCEDURE Proc_Cs2Cn_RailwayDiscountReconsolidation
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_RailwayDiscountReconsolidation 0,'2014-02-04'
select * from Cs2Cn_Prk_RailwayDiscountReconsolidation order by slno
Rollback Transaction
*/
CREATE PROCEDURE Proc_Cs2Cn_RailwayDiscountReconsolidation
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_RailwayDiscountReconsolidation 
* PURPOSE		: 
* CREATED BY	: Aravindh Deva C
* CREATED DATE	: 03.06.2016
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	DECLARE @DistCode   As NVARCHAR(50)

	DELETE FROM Cs2Cn_Prk_RailwayDiscountReconsolidation WHERE UploadFlag = 'Y'
	
	TRUNCATE TABLE UploadingReportTransaction
	
	INSERT INTO UploadingReportTransaction (TransType,TransId,TransNo,TransDate)
	SELECT 1,SalId,SalInvNo,SalInvDate FROM SalesInvoice (NOLOCK) WHERE DlvSts > 3 AND RptUpload = 0
	UNION ALL
	SELECT 2,ReturnID,ReturnCode,ReturnDate FROM ReturnHeader (NOLOCK) WHERE Status = 0 AND RptUpload = 0
	
	IF NOT EXISTS (SELECT '' FROM UploadingReportTransaction (NOLOCK))
	BEGIN
		RETURN
	END
	
	DECLARE @FromDate DATETIME
	DECLARE @ToDate DATETIME
	
	SELECT @FromDate = MIN(TransDate),@ToDate = MAX(TransDate) 
	FROM UploadingReportTransaction (NOLOCK)
	
	EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate
	
	SELECT * INTO #ParleOutputTaxPercentage
	FROM ParleOutputTaxPercentage (NOLOCK)

	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	
	
	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgCode
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	AND RC.CtgCode = 'RAI'
	--To Filter Retailers
	
	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	SP.PriceId,SP.SlNo,SP.PrdUom1EditedSelRate
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.SalInvDate)
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND S.DlvSts > 3
	
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	SP.PriceId,SP.SlNo,SP.PrdEditSelRte
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID
	WHERE EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.ReturnDate)
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND S.[Status] = 0
	
	SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty TotalPCS,MRP,PriceId,SlNo,CAST(0 AS NUMERIC(18,6))[SellRate],
	CAST(0 AS NUMERIC(18,2)) IRCTCMargin,CAST(0 AS INT) [Type],CAST(0 AS NUMERIC(18,2)) AS LCTR
	INTO #RailwaySalesDetails
	FROM 
	(
	SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,MRP,PriceId,SlNo FROM #BillingDetails
	
	UNION ALL
	
	SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,MRP,PriceId,SlNo FROM #ReturnDetails
	
	) Consolidated

	DECLARE @SlNo AS INT
	
	SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'
	
	UPDATE R SET R.[SellRate] = D.PrdBatDetailValue
	FROM #RailwaySalesDetails R (NOLOCK),
	ProductBatch B (NOLOCK),
	ProductBatchDetails D (NOLOCK)
	WHERE R.PrdBatId = B.PrdBatId AND B.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo	
	
	SELECT R.PriceId,C.DiscountPerc,C.[TYPE]
	INTO #ExistingSpecialPrice
	FROM #RailwaySalesDetails R (NOLOCK),
	SpecialRateAftDownLoad_Calc C (NOLOCK)
	WHERE R.PriceId = CAST(REPLACE(C.ContractPriceIds,'-','') AS BIGINT)
	
	UPDATE R SET R.IRCTCMargin = S.DiscountPerc,R.[Type] = S.[TYPE]
	FROM #RailwaySalesDetails R (NOLOCK),
	#ExistingSpecialPrice S (NOLOCK)
	WHERE R.PriceId = S.PriceId
	
	UPDATE R SET R.LCTR = R.[SellRate] + (R.[SellRate]*(T.TaxPerc/100))
	FROM #RailwaySalesDetails R (NOLOCK),
	#ParleOutputTaxPercentage T (NOLOCK)
	WHERE R.TransType = T.TransId AND R.SalId = T.Salid AND R.Slno = T.PrdSlno
			
	SELECT RtrId,TransDate,P.PrdId,P.PrdName,P.PrdCCode,SUM(TotalPCS) TotalPCS,MRP,
	LCTR,IRCTCMargin,CASE S.[Type] WHEN 1 THEN 'Mark Up' WHEN 2 THEN 'Mark Down' ELSE '' END MarkUpDown,
	CAST(0 AS NUMERIC(18,6)) IRCTCRate,
	CAST(0 AS NUMERIC(18,6)) TotalMRP,CAST(0 AS NUMERIC(18,6)) TotalLCTR,
	CAST(0 AS NUMERIC(18,6)) IRCTCTotal,CAST(0 AS NUMERIC(18,6)) ClmAmount,
	CAST(0 AS NUMERIC(18,2)) LibOnMRP,CAST(0 AS NUMERIC(18,2)) LibOnLCTR
	INTO #RailwayDiscount
	FROM #RailwaySalesDetails S (NOLOCK)
	INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	GROUP BY RtrId,TransDate,P.PrdId,P.PrdName,P.PrdCCode,MRP,LCTR,IRCTCMargin,S.[Type]
	
	UPDATE R SET R.IRCTCRate = MRP - (MRP * IRCTCMargin / 100.00), TotalMRP  = TotalPCS * MRP, TotalLCTR = TotalPCS * LCTR
	FROM #RailwayDiscount R (NOLOCK)
	
	UPDATE R SET R.IRCTCTotal = TotalPCS * IRCTCRate
	FROM #RailwayDiscount R (NOLOCK)

	UPDATE R SET R.ClmAmount = TotalLCTR - IRCTCTotal
	FROM #RailwayDiscount R (NOLOCK)

	UPDATE R SET R.LibOnMRP = ClmAmount / TotalMRP
	FROM #RailwayDiscount R (NOLOCK)
	WHERE R.TotalMRP <> 0

	UPDATE R SET R.LibOnLCTR = ClmAmount / TotalLCTR
	FROM #RailwayDiscount R (NOLOCK)
	WHERE R.TotalLCTR <> 0
	
	INSERT INTO Cs2Cn_Prk_RailwayDiscountReconsolidation (DistCode,TransDate,CmpRtrCode,PrdCCode,TotalPCS,MRP,LCTR,IRCTCMargin,MarkUpDown,IRCTCRate,TotalMRP,TotalLCTR,IRCTCTotal,ClmAmount,LibOnMRP,
	LibOnLCTR,UploadFlag,SyncId,ServerDate)
	
	SELECT @DistCode,TransDate,R.CmpRtrCode,PrdCCode,TotalPCS,MRP,LCTR,IRCTCMargin,MarkUpDown,IRCTCRate,TotalMRP,TotalLCTR,IRCTCTotal,ClmAmount,LibOnMRP,
	LibOnLCTR,'N' UploadFlag,NULL,@ServerDate
	FROM #RailwayDiscount RD,
	Retailer R (NOLOCK)
	WHERE RD.RtrId = R.RtrId
	
	RETURN			

END
GO
DELETE FROM CustomUpDownload WHERE SlNo = 133
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) 
VALUES (133,1,'ChainWiseBillDetails','ChainWiseBillDetails','Proc_Cs2Cn_ChainWiseBillDetails','','Cs2Cn_Prk_ChainWiseBillDetails','','Transaction','Upload',1)
GO
DELETE FROM Tbl_UploadIntegration WHERE SequenceNo = 1008
INSERT INTO Tbl_UploadIntegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) 
VALUES (1008,'ChainWiseBillDetails','ChainWiseBillDetails','Cs2Cn_Prk_ChainWiseBillDetails',GETDATE())
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'Cs2Cn_Prk_ChainWiseBillDetails')
CREATE TABLE Cs2Cn_Prk_ChainWiseBillDetails
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50),
	[BillNo] NVARCHAR(100),
	[BillDate] DATETIME,
	[CmpRtrCode] NVARCHAR(50),
	[PrdCCode] NVARCHAR(100),
	[PktWgt] NUMERIC(18,4),
	[PktMRP] NUMERIC(18,6),
	[QtyInPkt] NUMERIC(18, 0),
	[ChainLandRate] NUMERIC(18,6),
	[Amount] NUMERIC(18,6),
	[UploadFlag] NVARCHAR(10),
	[SyncId] NUMERIC(38, 0),
	[ServerDate] [datetime]
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Cs2Cn_ChainWiseBillDetails')
DROP PROCEDURE Proc_Cs2Cn_ChainWiseBillDetails
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_ChainWiseBillDetails 0,'2014-02-04'
select * from Cs2Cn_Prk_ChainWiseBillDetails order by slno
Rollback Transaction
*/
CREATE PROCEDURE Proc_Cs2Cn_ChainWiseBillDetails
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_ChainWiseBillDetails 
* PURPOSE		: To Extract LMISDetails
* CREATED BY	: Aravindh Deva C
* CREATED DATE	: 03.06.2016
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	DECLARE @DistCode As NVARCHAR(50)

	DELETE FROM Cs2Cn_Prk_ChainWiseBillDetails WHERE UploadFlag = 'Y'
	
	IF NOT EXISTS (SELECT '' FROM UploadingReportTransaction (NOLOCK))
	BEGIN
		RETURN
	END

	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	
			
	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgCode
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	--To Filter Retailers

	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SUM(SP.BaseQty) TotalPCS,SP.PrdUnitMRP MRP,SP.PriceId,
	CAST(0 AS NUMERIC(18,6)) ChainLandRate
	INTO #ChainSalesDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.SalInvDate)
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND S.DlvSts > 3
	GROUP BY S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdUnitMRP,SP.PriceId

	SELECT R.PriceId,C.SplSelRate
	INTO #ExistingSpecialPrice
	FROM #ChainSalesDetails R (NOLOCK),
	SpecialRateAftDownLoad_Calc C (NOLOCK)
	WHERE R.PriceId = CAST(REPLACE(C.ContractPriceIds,'-','') AS BIGINT)

	UPDATE R SET R.ChainLandRate = S.SplSelRate
	FROM #ChainSalesDetails R (NOLOCK),
	#ExistingSpecialPrice S (NOLOCK)
	WHERE R.PriceId = S.PriceId
	
	SELECT S.SalId,S.SalInvNo BillNo,S.SalInvDate BillDate,S.RtrId,R.RtrName,R.CmpRtrCode,P.PrdId,P.PrdName,P.PrdCCode,
	PrdWgt PktWgt,MRP,TotalPCS QtyInPkt,PriceId,ChainLandRate,
	CAST(0 AS NUMERIC(18,6)) Amount
	INTO #Chain
	FROM #ChainSalesDetails S (NOLOCK)
	INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	INNER JOIN Retailer R (NOLOCK) ON S.RtrId = R.RtrId
	
	UPDATE C SET C.Amount = QtyInPkt * ChainLandRate
	FROM #Chain C (NOLOCK)
	
	INSERT INTO Cs2Cn_Prk_ChainWiseBillDetails (DistCode,BillNo,BillDate,CmpRtrCode,PrdCCode,PktWgt,PktMRP,QtyInPkt,
	ChainLandRate,Amount,UploadFlag,SyncId,ServerDate)
	SELECT @DistCode,BillNo,BillDate,CmpRtrCode,PrdCCode,PktWgt,MRP,QtyInPkt,ChainLandRate,Amount,
	'N' UploadFlag,NULL,@ServerDate
	FROM #Chain (NOLOCK)
	
	--UPDATE S SET S.RptUpload = 1
	--FROM UploadingReportTransaction U (NOLOCK),
	--SalesInvoice S (NOLOCK) WHERE U.TransType = 1 AND U.TransId = S.SalId

	--UPDATE S SET S.RptUpload = 1
	--FROM UploadingReportTransaction U (NOLOCK),
	--ReturnHeader S (NOLOCK) WHERE U.TransType = 2 AND U.TransId = S.ReturnID
	
	RETURN			

END
GO
DELETE FROM CustomUpDownload WHERE SlNo = 134
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) 
VALUES (134,1,'MTChainSKUWise','MTChainSKUWise','Proc_Cs2Cn_MTChainSKUWise','','Cs2Cn_Prk_MTChainSKUWise','','Transaction','Upload',1)
GO
DELETE FROM Tbl_UploadIntegration WHERE SequenceNo = 1009
INSERT INTO Tbl_UploadIntegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) 
VALUES (1009,'MTChainSKUWise','MTChainSKUWise','Cs2Cn_Prk_MTChainSKUWise',GETDATE())
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'Cs2Cn_Prk_MTChainSKUWise')
CREATE TABLE Cs2Cn_Prk_MTChainSKUWise
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50),
	[TransDate] DATETIME,
	[CmpRtrCode] NVARCHAR(50),
	[PrdCCode] NVARCHAR(100),
	[MRP] [numeric](18, 6),
	[QtyInPkt] [numeric](18, 0),	
	[ParleLCTR] NUMERIC(18,6),
	[ChainRate] NUMERIC(18,6),
	[ChainOffRate] NUMERIC(18,6),
	[TotalOffLCTR] NUMERIC(18,6),
	[TotalOffPerTOT] NUMERIC(18,6),
	[TotalOffPerChain] NUMERIC(18,6),
	[OffClmDiff] NUMERIC(18,6),
	[OffLiabVal] NUMERIC(18,6),
	[ClmLiabWOTOT] NUMERIC(18,6),
	[ClmLiabTotSal] NUMERIC(18,6),
	[UploadFlag] NVARCHAR(10),
	[SyncId] [numeric](38, 0),
	[ServerDate] [datetime]
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Cs2Cn_MTChainSKUWise')
DROP PROCEDURE Proc_Cs2Cn_MTChainSKUWise
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_MTChainSKUWise 0,'2014-02-04'
select * from Cs2Cn_Prk_MTChainSKUWise order by slno
Rollback Transaction
*/
CREATE PROCEDURE Proc_Cs2Cn_MTChainSKUWise
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_MTChainSKUWise 
* PURPOSE		: To Extract LMISDetails
* CREATED BY	: Aravindh Deva C
* CREATED DATE	: 03.06.2016
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	DECLARE @DistCode As NVARCHAR(50)

	DELETE FROM Cs2Cn_Prk_MTChainSKUWise WHERE UploadFlag = 'Y'
	
	IF NOT EXISTS (SELECT '' FROM UploadingReportTransaction (NOLOCK))
	BEGIN
		RETURN
	END

	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	

	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgCode
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	--To Filter Retailers	
			
	--To Filter Products
	SELECT DISTINCT P.PrdId
	INTO #FilterProduct
	FROM Product P (NOLOCK) 
	WHERE P.PrdType = 3
	--To Filter Products

	DECLARE @FromDate DATETIME
	DECLARE @ToDate DATETIME
	
	SELECT @FromDate = MIN(TransDate),@ToDate = MAX(TransDate) 
	FROM UploadingReportTransaction (NOLOCK)	

	EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate

	SELECT * INTO #ParleOutputTaxPercentage
	FROM ParleOutputTaxPercentage (NOLOCK)

	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	SP.PriceId,SP.SlNo,SP.PrdUom1EditedSelRate
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE S.DlvSts > 3
	AND EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.SalInvDate)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FR (NOLOCK) WHERE SP.PrdId = FR.PrdId)
	AND S.DlvSts > 3

	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	SP.PriceId,SP.SlNo,SP.PrdEditSelRte
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID
	WHERE S.Status = 0
	AND EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.ReturnDate)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FR (NOLOCK) WHERE SP.PrdId = FR.PrdId)

	SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty TotalPCS,MRP,PriceId,SlNo,[SellRate],
	CAST(0 AS NUMERIC(18,2)) ChainRate,CAST(0 AS NUMERIC(18,2)) AS ParleLCTR,CAST(0 AS NUMERIC(18,2)) ChainOffRate
	INTO #MTSalesDetails
	FROM 
	(
	SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,MRP,PriceId,SlNo,PrdUom1EditedSelRate [SellRate] FROM #BillingDetails
	
	UNION ALL
	
	SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,MRP,PriceId,SlNo,PrdEditSelRte FROM #ReturnDetails
	
	) Consolidated	

	SELECT M.TransType,M.SalId,M.RtrId,M.PrdId,M.SlNo,K.PrdId [NormalPrd],K.PrdBatId [NormalBat],
	CAST(0 AS NUMERIC(18,6)) NormalSellRate,CAST(0 AS NUMERIC(18,6)) NormalSpecialRate
	INTO #NormalProduct
	FROM #MTSalesDetails M,
	KitProductTransDt K (NOLOCK)
	WHERE M.SalId = K.TransNo AND M.PrdId = K.KitPrdId AND M.SlNo = K.SlNo
	AND K.TransId = (CASE M.TransType WHEN 2 THEN 8 ELSE 1 END) -- TransId = 1 - Billing, 8 - Sales Return
	
	DECLARE @SlNo AS INT
	SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'
	
	UPDATE N SET N.NormalSellRate = D.PrdBatDetailValue
	FROM #NormalProduct N (NOLOCK),
	ProductBatch B (NOLOCK),
	ProductBatchDetails D (NOLOCK)
	WHERE N.NormalBat = B.PrdBatId AND B.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo
	
	UPDATE M SET M.SellRate = N.NormalSellRate
	FROM #MTSalesDetails M,
	(
	SELECT TransType,SalId,PrdId,SlNo,SUM(NormalSellRate) NormalSellRate FROM #NormalProduct
	GROUP BY TransType,SalId,PrdId,SlNo
	) N WHERE M.TransType = N.TransType AND M.SalId = N.SalId AND M.PrdId = N.PrdId AND M.SlNo = N.SlNo
	
	SELECT R.RtrId,P.PrdId,B.PrdBatId,S.SplSelRate,DownloadedDate
	INTO #SpecialPrice
	FROM SpecialRateAftDownLoad S (NOLOCK),
	#FilterRetailer R,
	Product P (NOLOCK), ProductBatch B (NOLOCK)
	WHERE S.RtrCtgValueCode = R.CtgCode AND
	S.PrdCCode = P.PrdCCode AND B.PrdBatCode = S.PrdBatCCode AND P.PrdId = B.PrdId
	AND EXISTS (SELECT 'C' FROM #NormalProduct N (NOLOCK) WHERE P.PrdId = N.NormalPrd)
	
	SELECT S.* 
	INTO #LatesSpecialPrice
	FROM #SpecialPrice S,
	(
		SELECT RtrId,PrdId,PrdBatId,MAX(DownloadedDate) DownloadedDate 
		FROM #SpecialPrice
		GROUP BY RtrId,PrdId,PrdBatId
	) L
	WHERE L.RtrId = S.RtrId AND L.PrdId = S.PrdId AND L.PrdBatId = S.PrdBatId AND L.DownloadedDate = S.DownloadedDate

	UPDATE N SET N.NormalSpecialRate = L.SplSelRate
	FROM #NormalProduct N (NOLOCK),
	#LatesSpecialPrice L (NOLOCK)
	WHERE N.RtrId = L.RtrId AND N.NormalPrd = L.PrdId AND N.NormalBat = L.PrdBatId
	
	UPDATE M SET M.ChainRate = N.NormalSpecialRate
	FROM #MTSalesDetails M,
	(
	SELECT TransType,SalId,PrdId,SlNo,SUM(NormalSpecialRate) NormalSpecialRate FROM #NormalProduct
	GROUP BY TransType,SalId,PrdId,SlNo
	) N WHERE M.TransType = N.TransType AND M.SalId = N.SalId AND M.PrdId = N.PrdId AND M.SlNo = N.SlNo		
		
	UPDATE R SET R.ParleLCTR = (R.[SellRate]+(R.[SellRate]*(T.TaxPerc/100)))
	FROM #MTSalesDetails R (NOLOCK),
	#ParleOutputTaxPercentage T (NOLOCK)
	WHERE R.TransType = T.TransId AND R.SalId = T.Salid AND R.Slno = T.PrdSlno	

	UPDATE R SET R.ChainOffRate = D.PrdBatDetailValue
	FROM #MTSalesDetails R (NOLOCK),
	ProductBatch B (NOLOCK),
	ProductBatchDetails D (NOLOCK)
	WHERE R.PrdBatId = B.PrdBatId AND B.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo			
	
	SELECT S.RtrId,R.CmpRtrCode,S.TransDate,P.PrdId,P.PrdCCode,MRP,SUM(TotalPCS) QtyInPkt,
	ParleLCTR,ChainRate,ChainOffRate,
	CAST(0 AS NUMERIC(18,6)) TotalOffLCTR,CAST(0 AS NUMERIC(18,6)) TotalOffPerTOT,
	CAST(0 AS NUMERIC(18,6)) TotalOffPerChain,CAST(0 AS NUMERIC(18,6)) OffClmDiff,
	CAST(0 AS NUMERIC(18,2)) OffLiabVal,CAST(0 AS NUMERIC(18,2)) ClmLiabWOTOT,
	CAST(0 AS NUMERIC(18,2)) ClmLiabTotSal
	INTO #MTChain
	FROM #MTSalesDetails S (NOLOCK)
	INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	INNER JOIN Retailer R (NOLOCK) ON S.RtrId = R.RtrId
	GROUP BY S.RtrId,R.CmpRtrCode,S.TransDate,P.PrdId,P.PrdCCode,MRP,ParleLCTR,ChainRate,ChainOffRate

	UPDATE R SET R.TotalOffLCTR = QtyInPkt * ParleLCTR,
	R.TotalOffPerTOT = QtyInPkt * ChainRate,
	R.TotalOffPerChain = QtyInPkt * ChainOffRate
	FROM #MTChain R (NOLOCK)

	UPDATE R SET R.OffClmDiff = TotalOffLCTR - TotalOffPerChain,
	R.OffLiabVal = TotalOffPerTOT - TotalOffPerChain
	FROM #MTChain R (NOLOCK)

	UPDATE R SET R.ClmLiabWOTOT = OffLiabVal / TotalOffLCTR, ClmLiabTotSal = OffClmDiff / TotalOffLCTR
	FROM #MTChain R (NOLOCK)
	WHERE TotalOffLCTR <> 0

	INSERT INTO Cs2Cn_Prk_MTChainSKUWise (DistCode,TransDate,CmpRtrCode,PrdCCode,MRP,QtyInPkt,ParleLCTR,ChainRate,ChainOffRate,TotalOffLCTR,
	TotalOffPerTOT,TotalOffPerChain,OffClmDiff,OffLiabVal,ClmLiabWOTOT,ClmLiabTotSal,UploadFlag,SyncId,ServerDate)
	
	SELECT @DistCode,TransDate,CmpRtrCode,PrdCCode,MRP,QtyInPkt,ParleLCTR,ChainRate,ChainOffRate,TotalOffLCTR,
	TotalOffPerTOT,TotalOffPerChain,OffClmDiff,OffLiabVal,ClmLiabWOTOT,ClmLiabTotSal,'N' UploadFlag,NULL,@ServerDate
	FROM #MTChain RD
	
	RETURN			

END
GO
DELETE FROM CustomUpDownload WHERE SlNo = 135
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) 
VALUES (135,1,'MTDebitSummary','MTDebitSummary','Proc_Cs2Cn_MTDebitSummary','','Cs2Cn_Prk_MTDebitSummary','','Transaction','Upload',1)
GO
DELETE FROM Tbl_UploadIntegration WHERE SequenceNo = 1010
INSERT INTO Tbl_UploadIntegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) 
VALUES (1010,'MTDebitSummary','MTDebitSummary','Cs2Cn_Prk_MTDebitSummary',GETDATE())
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'Cs2Cn_Prk_MTDebitSummary')
CREATE TABLE Cs2Cn_Prk_MTDebitSummary
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] [nvarchar](50),
	[TransDate] DATETIME,
	[CmpRtrCode] NVARCHAR(50),
	[PrdCCode] NVARCHAR(100),
	[TotalLCTR] NUMERIC(18,6),
	[SalesTOT] NUMERIC(18,6),
	[ClaimDiff] NUMERIC(18,6),
	[LiabSales] NUMERIC(18,6),
	[TotalOffLCTR] NUMERIC(18,6),
	[OffTOT] NUMERIC(18,6),
	[TotalOff] NUMERIC(18,6),
	[OffClaimDiff] NUMERIC(18,6),
	[LiabOff] NUMERIC(18,6),
	[TotalSales] NUMERIC(18,6),
	[LiabWOTOT] NUMERIC(18,6),
	[LiabTOT] NUMERIC(18,6),
	[TotalLiab] NUMERIC(18,6),
	[UploadFlag] NVARCHAR(10),
	[SyncId] NUMERIC(38, 0),
	[ServerDate] DATETIME
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Cs2Cn_MTDebitSummary')
DROP PROCEDURE Proc_Cs2Cn_MTDebitSummary
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_MTDebitSummary 0,'2014-02-04'
select * from Cs2Cn_Prk_MTDebitSummary order by slno
Rollback Transaction
*/
CREATE PROCEDURE Proc_Cs2Cn_MTDebitSummary
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_MTDebitSummary 
* PURPOSE		: To Extract LMISDetails
* CREATED BY	: Aravindh Deva C
* CREATED DATE	: 03.06.2016
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	DECLARE @DistCode As NVARCHAR(50)

	DELETE FROM Cs2Cn_Prk_MTDebitSummary WHERE UploadFlag = 'Y'
	
	IF NOT EXISTS (SELECT '' FROM UploadingReportTransaction (NOLOCK))
	BEGIN
		RETURN
	END

	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	

	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgMainId,RC.CtgName,RC.CtgCode
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)	

	DECLARE @FromDate DATETIME
	DECLARE @ToDate DATETIME
	
	SELECT @FromDate = MIN(TransDate),@ToDate = MAX(TransDate) 
	FROM UploadingReportTransaction (NOLOCK)	

	EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate

	SELECT * INTO #ParleOutputTaxPercentage
	FROM ParleOutputTaxPercentage (NOLOCK)

	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	SP.PriceId,SP.SlNo,SP.PrdUom1EditedSelRate,B.DefaultPriceId
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	WHERE S.DlvSts > 3
	AND EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.SalInvDate)
	
	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	SP.PriceId,SP.SlNo,SP.PrdEditSelRte,B.DefaultPriceId
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	WHERE S.Status = 0
	AND EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate = S.ReturnDate)

	SELECT TransType,RtrId,SalId,TransDate,PrdId,BaseQty TotalPCS,MRP,PriceId,SlNo,[SellRate],DefaultPriceId,
	CAST(0 AS NUMERIC(18,6))[ActualSellRate],CAST(0 AS NUMERIC(18,6))[SpecialSellRate],
	CAST(0 AS NUMERIC(18,6)) TotalLCTR, CAST(0 AS NUMERIC(18,6)) SalesTOT
	INTO #MTSalesDetails
	FROM 
	(
	SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,BaseQty,MRP,PriceId,SlNo,PrdUom1EditedSelRate [SellRate],DefaultPriceId FROM #BillingDetails
	
	UNION ALL
	
	SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,BaseQty,MRP,PriceId,SlNo,PrdEditSelRte,DefaultPriceId FROM #ReturnDetails
	
	) Consolidated
	
	SELECT M.TransType,M.SalId,M.RtrId,M.PrdId,M.SlNo,K.PrdId [NormalPrd],K.PrdBatId [NormalBat],
	CAST(0 AS NUMERIC(18,6)) NormalSellRate,CAST(0 AS NUMERIC(18,6)) NormalSpecialRate
	INTO #NormalProduct
	FROM #MTSalesDetails M,
	KitProductTransDt K (NOLOCK)
	WHERE M.SalId = K.TransNo AND M.PrdId = K.KitPrdId AND M.SlNo = K.SlNo
	AND K.TransId = (CASE M.TransType WHEN 2 THEN 8 ELSE 1 END) -- TransId = 1 - Billing, 8 - Sales Return
	
	DECLARE @SlNo AS INT
	SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'
	
	UPDATE M SET M.ActualSellRate = D.PrdBatDetailValue
	FROM #MTSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo

	UPDATE M SET M.[SpecialSellRate] = D.PrdBatDetailValue
	FROM #MTSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = @SlNo
	AND PriceCode LIKE '%-Spl Rate-%'

	--
	UPDATE N SET N.NormalSellRate = D.PrdBatDetailValue
	FROM #NormalProduct N (NOLOCK),
	ProductBatch B (NOLOCK),
	ProductBatchDetails D (NOLOCK)
	WHERE N.NormalBat = B.PrdBatId AND B.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo
	
	UPDATE M SET M.[ActualSellRate] = N.NormalSellRate
	FROM #MTSalesDetails M,
	(
	SELECT TransType,SalId,PrdId,SlNo,SUM(NormalSellRate) NormalSellRate FROM #NormalProduct
	GROUP BY TransType,SalId,PrdId,SlNo
	) N WHERE M.TransType = N.TransType AND M.SalId = N.SalId AND M.PrdId = N.PrdId AND M.SlNo = N.SlNo
	--
	
	SELECT R.RtrId,P.PrdId,B.PrdBatId,S.SplSelRate,DownloadedDate
	INTO #SpecialPrice
	FROM SpecialRateAftDownLoad S (NOLOCK),
	#FilterRetailer R,
	Product P (NOLOCK), ProductBatch B (NOLOCK)
	WHERE S.RtrCtgValueCode = R.CtgCode AND
	S.PrdCCode = P.PrdCCode AND B.PrdBatCode = S.PrdBatCCode AND P.PrdId = B.PrdId
	AND EXISTS (SELECT 'C' FROM #NormalProduct N (NOLOCK) WHERE P.PrdId = N.NormalPrd)	

	SELECT S.* 
	INTO #LatesSpecialPrice
	FROM #SpecialPrice S,
	(
		SELECT RtrId,PrdId,PrdBatId,MAX(DownloadedDate) DownloadedDate 
		FROM #SpecialPrice
		GROUP BY RtrId,PrdId,PrdBatId
	) L
	WHERE L.RtrId = S.RtrId AND L.PrdId = S.PrdId AND L.PrdBatId = S.PrdBatId AND L.DownloadedDate = S.DownloadedDate

	UPDATE N SET N.NormalSpecialRate = L.SplSelRate
	FROM #NormalProduct N (NOLOCK),
	#LatesSpecialPrice L (NOLOCK)
	WHERE N.RtrId = L.RtrId AND N.NormalPrd = L.PrdId AND N.NormalBat = L.PrdBatId
	
	UPDATE M SET M.[SpecialSellRate] = N.NormalSpecialRate
	FROM #MTSalesDetails M,
	(
	SELECT TransType,SalId,PrdId,SlNo,SUM(NormalSpecialRate) NormalSpecialRate FROM #NormalProduct
	GROUP BY TransType,SalId,PrdId,SlNo
	) N WHERE M.TransType = N.TransType AND M.SalId = N.SalId AND M.PrdId = N.PrdId AND M.SlNo = N.SlNo		

	UPDATE R SET R.TotalLCTR =  R.TotalPCS * (R.[ActualSellRate]+(R.[ActualSellRate]*(T.TaxPerc/100))),
	R.SalesTOT = R.TotalPCS * (R.[SpecialSellRate]+(R.[SpecialSellRate]*(T.TaxPerc/100)))
	FROM #MTSalesDetails R (NOLOCK),
	#ParleOutputTaxPercentage T (NOLOCK)
	WHERE R.TransType = T.TransId AND R.SalId = T.Salid AND R.Slno = T.PrdSlno
	
	SELECT M.RtrId,TransDate,M.PrdId,P.PrdCCode,SUM(CASE P.PrdType WHEN 3 THEN 0 ELSE TotalLCTR END) TotalLCTR,
	SUM(CASE P.PrdType WHEN 3 THEN 0 ELSE SalesTOT END) SalesTOT,
	CAST(0 AS NUMERIC(18,2)) [ClaimDiff], CAST(0 AS NUMERIC(18,2)) [LiabSales],
	SUM(CASE P.PrdType WHEN 3 THEN TotalLCTR ELSE 0 END) [TotalOffLCTR],
	SUM(CASE P.PrdType WHEN 3 THEN SalesTOT ELSE 0 END) [OffTOT],
	CAST(0 AS NUMERIC(18,2)) [TotalOff],CAST(0 AS NUMERIC(18,2)) [OffClaimDiff],
	CAST(0 AS NUMERIC(18,2)) [LiabOff],CAST(0 AS NUMERIC(18,2)) [TotalSales],
	CAST(0 AS NUMERIC(18,2)) [LiabWOTOT],CAST(0 AS NUMERIC(18,2)) [LiabTOT],CAST(0 AS NUMERIC(18,2)) [TotalLiab]
	INTO #DebitNote
	FROM #MTSalesDetails M,
	Product P (NOLOCK) 
	WHERE M.PrdId = P.PrdId
	GROUP BY M.RtrId,TransDate,M.PrdId,P.PrdCCode
	
	UPDATE D SET [ClaimDiff] = TotalLCTR - SalesTOT, [TotalOff] = [TotalOffLCTR] - [OffTOT]
	FROM #DebitNote D (NOLOCK)

	UPDATE D SET [LiabSales] = [ClaimDiff] / TotalLCTR
	FROM #DebitNote D (NOLOCK)
	WHERE TotalLCTR <> 0

	UPDATE D SET [OffClaimDiff] = [TotalOffLCTR] - [TotalOff]
	FROM #DebitNote D (NOLOCK)

	UPDATE D SET [LiabOff] = [OffTOT] - [TotalOff]
	FROM #DebitNote D (NOLOCK)	

	UPDATE D SET [TotalSales] = TotalLCTR + [TotalOffLCTR]
	FROM #DebitNote D (NOLOCK)
	
	UPDATE D SET [LiabWOTOT] = [LiabOff] / [TotalSales]
	FROM #DebitNote D (NOLOCK)	
	WHERE [TotalSales] <> 0

	UPDATE D SET [LiabTOT] = [TotalOffLCTR] / [TotalSales]
	FROM #DebitNote D (NOLOCK)
	WHERE [TotalSales] <> 0		

	UPDATE D SET [TotalLiab] = ([ClaimDiff] + [OffClaimDiff])/[TotalSales]
	FROM #DebitNote D (NOLOCK)
	WHERE [TotalSales] <> 0	


	INSERT INTO Cs2Cn_Prk_MTDebitSummary (DistCode,TransDate,CmpRtrCode,PrdCCode,TotalLCTR,SalesTOT,ClaimDiff,LiabSales,
	TotalOffLCTR,OffTOT,TotalOff,OffClaimDiff,LiabOff,TotalSales,LiabWOTOT,LiabTOT,TotalLiab,UploadFlag,SyncId,ServerDate)

	SELECT @DistCode,TransDate,R.CmpRtrCode,PrdCCode,
	SUM(TotalLCTR) TotalLCTR,
	SUM(SalesTOT) SalesTOT,
	SUM(ClaimDiff) ClaimDiff,
	SUM(LiabSales) LiabSales,
	SUM(TotalOffLCTR) TotalOffLCTR,
	SUM(OffTOT) OffTOT,
	SUM(TotalOff) TotalOff,
	SUM(OffClaimDiff) OffClaimDiff,
	SUM(LiabOff) LiabOff,
	SUM(TotalSales) TotalSales,
	SUM(LiabWOTOT) LiabWOTOT,
	SUM(LiabTOT) LiabTOT,
	SUM(TotalLiab) TotalLiab,'N' UploadFlag,NULL,@ServerDate
	FROM #DebitNote D (NOLOCK),
	Retailer R (NOLOCK)
	WHERE D.RtrId = R.RtrId
	GROUP BY TransDate,R.CmpRtrCode,PrdCCode

	RETURN			

END
GO
DELETE FROM CustomUpDownload WHERE SlNo = 136
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) 
VALUES (136,1,'SchemeStockReconsolidation','SchemeStockReconsolidation','Proc_Cs2Cn_SchemeStockReconsolidation','','Cs2Cn_Prk_SchemeStockReconsolidation','','Transaction','Upload',1)
GO
DELETE FROM Tbl_UploadIntegration WHERE SequenceNo = 1011
INSERT INTO Tbl_UploadIntegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) 
VALUES (1011,'SchemeStockReconsolidation','SchemeStockReconsolidation','Cs2Cn_Prk_SchemeStockReconsolidation',GETDATE())
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'Cs2Cn_Prk_SchemeStockReconsolidation')
CREATE TABLE Cs2Cn_Prk_SchemeStockReconsolidation
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] NVARCHAR(50),
	[CmpSchCode] NVARCHAR(40),
	[PrdCCode] NVARCHAR(100),
	[NoOfPkt] NUMERIC(18, 0),
	[BillNo] NVARCHAR(100),
	[BillDate] DATETIME,
	[BillQty] NUMERIC(18, 0),
	[OpenStock] NUMERIC(18, 0),
	[CloseStock] NUMERIC(18, 0),
	[UploadFlag] NVARCHAR(10),
	[SyncId] NUMERIC(38, 0),
	[ServerDate] DATETIME
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Cs2Cn_SchemeStockReconsolidation')
DROP PROCEDURE Proc_Cs2Cn_SchemeStockReconsolidation
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_SchemeStockReconsolidation 0,'2014-02-04'
select * from Cs2Cn_Prk_SchemeStockReconsolidation order by slno
Rollback Transaction
*/
CREATE PROCEDURE Proc_Cs2Cn_SchemeStockReconsolidation
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_SchemeStockReconsolidation 
* PURPOSE		: To Extract LMISDetails
* CREATED BY	: Aravindh Deva C
* CREATED DATE	: 03.06.2016
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	DECLARE @DistCode As NVARCHAR(50)

	DELETE FROM Cs2Cn_Prk_SchemeStockReconsolidation WHERE UploadFlag = 'Y'
	
	IF NOT EXISTS (SELECT * FROM UploadingReportTransaction (NOLOCK))
	BEGIN
		RETURN
	END

	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	
	
	DECLARE @FromDate DATETIME
	DECLARE @ToDate DATETIME
			
	SELECT @FromDate = MIN(SchValidFrom),@ToDate = MAX(SchValidTill) FROM SchemeMaster S (NOLOCK)
	WHERE EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate BETWEEN S.SchValidFrom AND S.SchValidTill AND TransType = 1)

	SELECT S.SalId,S.SalInvNo,S.SalInvDate,SP.PrdId,SUM(SP.BaseQty) BaseQty
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3
	GROUP BY S.SalId,S.SalInvNo,S.SalInvDate,SP.PrdId

	CREATE TABLE #ApplicableProduct
	(
		SchId		INT,
		PrdId 		INT
	)
	
	INSERT INTO #ApplicableProduct(SchId,PrdId)
	SELECT DISTINCT A.SchId,B.Prdid
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid
		INNER JOIN Product C On B.Prdid = C.PrdId
		WHERE A.SchemeLvlMode = 0 AND B.PrdId <> 0
	UNION ALL
	SELECT DISTINCT A.SchId,E.Prdid
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On
		F.PrdId = E.Prdid
		WHERE A.SchemeLvlMode = 0 AND B.PrdCtgValMainId <> 0
	UNION ALL
	SELECT DISTINCT S.SchId,B.MasterRecordId
		FROM SchemeProducts A 
		INNER JOIN UdcDetails B on B.UDCUniqueId =A.PrdCtgValMainId 
		INNER JOIN SchemeMaster S ON A.SchId = S.SchId
		WHERE S.SchemeLvlMode = 1

	CREATE TABLE #ApplicableScheme
	(
		SchId			INT,
		SchValidFrom	DATETIME,
		SchValidTill	DATETIME,	
		PrdId 		INT
	)	

	INSERT INTO #ApplicableScheme (SchId,SchValidFrom,SchValidTill,PrdId)			
	SELECT DISTINCT A.SchId,S.SchValidFrom,S.SchValidTill,A.PrdId FROM #ApplicableProduct A (NOLOCK),
	SchemeMaster S (NOLOCK),#BillingDetails B (NOLOCK)
	WHERE A.SchId = S.SchId AND B.SalInvDate BETWEEN S.SchValidFrom AND S.SchValidTill
	
	SELECT S.SchId,S.SchValidFrom,S.SchValidTill,
	B.PrdId,CAST(0 AS INT) CB,CAST(0 AS NUMERIC(18,0)) OpenStock,CAST(0 AS NUMERIC(18,0)) CloseStock,
	B.SalId,B.SalInvNo,B.SalInvDate,B.BaseQty
	INTO #SchemeStock
	FROM #ApplicableScheme S (NOLOCK),
	#BillingDetails B (NOLOCK) 
	WHERE S.PrdId = B.PrdId AND B.SalInvDate BETWEEN S.SchValidFrom AND S.SchValidTill
	
	UPDATE S SET S.CB = ConversionFactor
	FROM #SchemeStock S (NOLOCK),
	(
	SELECT P.PrdId,MAX(U.ConversionFactor) ConversionFactor
	FROM Product P (NOLOCK),UomGroup U (NOLOCK)
	WHERE P.UomGroupId = U.UomGroupId 
	GROUP BY P.PrdId
	) C WHERE C.PrdId = S.PrdId
	

	SELECT * INTO #StockLedger 
	FROM StockLedger S (NOLOCK)
	WHERE EXISTS (SELECT '' FROM #ApplicableScheme A (NOLOCK) WHERE S.PrdId = A.PrdId)
	AND S.LcnId = 1
	
	--OpenStock	
	SELECT SchId,SL.PrdId,SL.PrdBatId,MAX(SL.TransDate) TransDate
	INTO #Open
	FROM #SchemeStock S,
	#StockLedger SL (NOLOCK)
	WHERE S.PrdId = SL.PrdId AND SL.TransDate < S.SchValidFrom
	GROUP BY SchId,SL.PrdId,SL.PrdBatId
	
	SELECT SchId,PrdId,SUM(SalClsStock) OpenStock
	INTO #OpenStock
	FROM 
	(
	SELECT O.SchId,O.PrdId,O.PrdBatId,SalClsStock SalClsStock
	FROM #Open O,
	#StockLedger S (NOLOCK)
	WHERE O.PrdId = S.PrdId AND O.PrdBatId = S.PrdBatId AND O.TransDate = S.TransDate
	) O
	GROUP BY SchId,PrdId
	--OpenStock

	--CloseStock
	SELECT SchId,SL.PrdId,SL.PrdBatId,MAX(SL.TransDate) TransDate
	INTO #Close
	FROM #SchemeStock S,
	#StockLedger SL (NOLOCK)
	WHERE S.PrdId = SL.PrdId AND SL.TransDate <= S.SchValidTill
	GROUP BY SchId,SL.PrdId,SL.PrdBatId

	SELECT SchId,PrdId,SUM(SalClsStock) CloseStock
	INTO #CloseStock
	FROM 
	(
	SELECT O.SchId,O.PrdId,O.PrdBatId,SalClsStock
	FROM #Close O,
	#StockLedger S (NOLOCK)
	WHERE O.PrdId = S.PrdId AND O.PrdBatId = S.PrdBatId AND O.TransDate = S.TransDate
	) C
	GROUP BY SchId,PrdId
	--CloseStock

	UPDATE S SET S.OpenStock = O.OpenStock
	FROM #SchemeStock S (NOLOCK),
	#OpenStock O (NOLOCK)
	WHERE S.SchId = O.SchId AND S.PrdId = O.PrdId	
	
	UPDATE S SET S.CloseStock = C.CloseStock
	FROM #SchemeStock S (NOLOCK),
	#CloseStock C (NOLOCK)
	WHERE S.SchId = C.SchId AND S.PrdId = C.PrdId
	
	SELECT SM.CmpSchCode,P.PrdCCode,S.CB NoOfPkt,S.SalInvNo BillNo,SalInvDate BillDate,S.BaseQty BillQty,S.OpenStock,S.CloseStock
	INTO #SchemeStockReconciliation
	FROM #SchemeStock S,
	SchemeMaster SM (NOLOCK),
	Product P (NOLOCK)
	WHERE S.SchId = SM.SchId AND S.PrdId = P.PrdId
	
	INSERT INTO Cs2Cn_Prk_SchemeStockReconsolidation (DistCode,CmpSchCode,PrdCCode,NoOfPkt,BillNo,BillDate,BillQty,
	OpenStock,CloseStock,UploadFlag,SyncId,ServerDate)
	SELECT @DistCode,CmpSchCode,PrdCCode,NoOfPkt,BillNo,BillDate,BillQty,OpenStock,CloseStock,
	'N' UploadFlag,NULL,@ServerDate
	FROM #SchemeStockReconciliation (NOLOCK)
	
	--UPDATE S SET S.RptUpload = 1
	--FROM UploadingReportTransaction U (NOLOCK),
	--SalesInvoice S (NOLOCK) WHERE U.TransType = 1 AND U.TransId = S.SalId

	--UPDATE S SET S.RptUpload = 1
	--FROM UploadingReportTransaction U (NOLOCK),
	--ReturnHeader S (NOLOCK) WHERE U.TransType = 2 AND U.TransId = S.ReturnID
	
	RETURN			

END
GO
IF NOT EXISTS (SELECT '' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'UploadedSampling')
CREATE TABLE UploadedSampling
(
[SamplingRefNo] NVARCHAR(100),
[UploadDate] DATETIME
)
GO
DELETE FROM CustomUpDownload WHERE SlNo = 137
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) 
VALUES (137,1,'Debit Note Top Sheet Sampling','DebitNoteTopSheet1','Proc_Cs2Cn_DebitNoteTopSheet1','','Cs2Cn_Prk_DebitNoteTopSheet1','','Transaction','Upload',1)
GO
DELETE FROM Tbl_UploadIntegration WHERE SequenceNo = 1012
INSERT INTO Tbl_UploadIntegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) 
VALUES (1012,'DebitNoteTopSheet1','DebitNoteTopSheet1','Cs2Cn_Prk_DebitNoteTopSheet1',GETDATE())
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'SamplingBatchTaxPercent')
DROP TABLE SamplingBatchTaxPercent
GO
CREATE TABLE SamplingBatchTaxPercent
(
	[PrdId] INT,
	[PrdBatId] INT,
	[TaxPercentage] NUMERIC(18, 5)
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_SamplingTaxCalCulation') 
DROP PROCEDURE Proc_SamplingTaxCalCulation
GO
--Exec Proc_SamplingTaxCalCulation 2556,19944
CREATE PROCEDURE Proc_SamplingTaxCalCulation
(
	@PrdId AS INT,
	@PrdBatId AS INT
	
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

		SELECT @RtrTaxGrp = MAX(Distinct RTRID) from TaxSettingMaster A,TaxGroupSetting B Where A.Rtrid=B.TaxGroupid and B.TaxGroup=1
		
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
	
		INSERT INTO SamplingBatchTaxPercent(Prdid,Prdbatid,TaxPercentage)
		SELECT @Prdid,@Prdbatid,@TaxPercentage

END
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'Cs2Cn_Prk_DebitNoteTopSheet1')
CREATE TABLE Cs2Cn_Prk_DebitNoteTopSheet1
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] NVARCHAR(50),
	[SamplingRefNo] NVARCHAR(100),
	[SamplingDate] DATETIME,
	[SamplingAmount] NUMERIC(18,6),
	[UploadFlag] NVARCHAR(10),
	[SyncId] NUMERIC(38, 0),
	[ServerDate] DATETIME
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Cs2Cn_DebitNoteTopSheet1')
DROP PROCEDURE Proc_Cs2Cn_DebitNoteTopSheet1
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_DebitNoteTopSheet1 0,'2014-02-04'
select * from Cs2Cn_Prk_DebitNoteTopSheet1 order by slno
Rollback Transaction
*/
CREATE PROCEDURE Proc_Cs2Cn_DebitNoteTopSheet1
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DebitNoteTopSheet1 
* PURPOSE		: To Extract LMISDetails
* CREATED BY	: Aravindh Deva C
* CREATED DATE	: 03.06.2016
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	DECLARE @DistCode As NVARCHAR(50)

	DELETE FROM Cs2Cn_Prk_DebitNoteTopSheet1 WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	
	
	DECLARE @MGSaleable AS INT 
	DECLARE @MGOffer AS INT

	DECLARE @SlNo AS INT
	
	DECLARE @SamplingAmount AS NUMERIC(18,6)

	SELECT @MGSaleable = StockTypeId FROM StockType WHERE UserStockType = 'MGSaleable'
	SELECT @MGOffer = StockTypeId FROM StockType WHERE UserStockType = 'MGOffer'

	SELECT @SlNo = SlNo FROM BatchCreation WHERE FieldDesc = 'Selling Price'

	SELECT DISTINCT J.PrdId,J.PrdBatId,B.TaxGroupId,CAST(0 AS NUMERIC(18,2)) TaxPercentage
	INTO #SamplingBatchTaxPercent
	FROM StockJournal J,
	StockJournalDt D (NOLOCK),
	ProductBatch B (NOLOCK)
	WHERE J.StkJournalRefNo = D.StkJournalRefNo
	AND J.PrdBatId = B.PrdBatId	AND J.PrdId = B.PrdId
	AND StockTypeId = @MGSaleable AND TransferStkTypeId = @MGOffer
	AND NOT EXISTS (SELECT 'C' FROM UploadedSampling L (NOLOCK) WHERE L.SamplingRefNo = J.StkJournalRefNo)
	
	SELECT ROW_NUMBER() OVER (ORDER BY T.TaxGroupId) RowNo,
	MAX(T.PrdBatId) PrdBatId,T.TaxGroupId 
	INTO #BatchTaxPercent
	FROM #SamplingBatchTaxPercent T
	WHERE T.TaxGroupId <> 0
	GROUP BY T.TaxGroupId
	
	DECLARE @PrdId AS INT
	DECLARE @PrdBatId AS INT
	DECLARE @TaxGroupId AS INT
	DECLARE @TaxPercentage AS NUMERIC(18,2)

	DECLARE @RowNo AS INT
	DECLARE @TotalRow AS INT
	
	SET @RowNo = 1
	SELECT @TotalRow = COUNT(TaxGroupId) FROM #BatchTaxPercent D (NOLOCK)	
		
	TRUNCATE TABLE SamplingBatchTaxPercent

	WHILE (@RowNo < = @TotalRow)
	BEGIN	

		SELECT @PrdId = B.PrdId, @PrdBatId = S.PrdBatId, @TaxGroupId = B.TaxGroupId
		FROM #BatchTaxPercent S,
		#SamplingBatchTaxPercent B (NOLOCK)
		WHERE S.PrdBatId = B.PrdBatId AND S.TaxGroupId = B.TaxGroupId
		AND RowNo = @RowNo

		EXEC Proc_SamplingTaxCalCulation @PrdId,@PrdBatId
		
		SELECT @TaxPercentage = TaxPercentage FROM SamplingBatchTaxPercent S (NOLOCK)
		WHERE PrdBatId = @PrdBatId
		
		UPDATE B SET B.TaxPercentage = @TaxPercentage
		FROM #SamplingBatchTaxPercent B
		WHERE B.TaxGroupId = @TaxGroupId
		
		SET @RowNo = @RowNo + 1
		
	END
	
	INSERT INTO Cs2Cn_Prk_DebitNoteTopSheet1 (DistCode,SamplingRefNo,SamplingDate,SamplingAmount,UploadFlag,SyncId,ServerDate)
	SELECT @DistCode,J.StkJournalRefNo,J.StkJournalDate,
	SUM( D.StkTransferQty * (P.PrdBatDetailValue + (P.PrdBatDetailValue * (T.TaxPercentage / 100)))) Amount,
	'N' UploadFlag,NULL,@ServerDate
	FROM StockJournal J,
	StockJournalDt D (NOLOCK),
	ProductBatchDetails P (NOLOCK),
	#SamplingBatchTaxPercent T (NOLOCK)
	WHERE J.StkJournalRefNo = D.StkJournalRefNo AND J.PriceId = P.PriceId
	AND P.PrdBatId = T.PrdBatId
	AND StockTypeId = @MGSaleable AND TransferStkTypeId = @MGOffer
	AND P.SLNo = @SlNo
	AND NOT EXISTS (SELECT 'C' FROM UploadedSampling L (NOLOCK) WHERE L.SamplingRefNo = J.StkJournalRefNo)
	GROUP BY J.StkJournalRefNo,J.StkJournalDate
	
	INSERT INTO UploadedSampling (SamplingRefNo,UploadDate)
	SELECT SamplingRefNo,GETDATE() FROM Cs2Cn_Prk_DebitNoteTopSheet1 P (NOLOCK)
	WHERE NOT EXISTS (SELECT 'C' FROM UploadedSampling L (NOLOCK) WHERE L.SamplingRefNo = P.SamplingRefNo)
	
	RETURN			

END
GO
DELETE FROM CustomUpDownload WHERE SlNo = 138
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) 
VALUES (138,1,'Debit Note Top Sheet Scheme','DebitNoteTopSheet2','Proc_Cs2Cn_DebitNoteTopSheet2','','Cs2Cn_Prk_DebitNoteTopSheet2','','Transaction','Upload',1)
GO
DELETE FROM Tbl_UploadIntegration WHERE SequenceNo = 1013
INSERT INTO Tbl_UploadIntegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) 
VALUES (1013,'DebitNoteTopSheet2','DebitNoteTopSheet2','Cs2Cn_Prk_DebitNoteTopSheet2',GETDATE())
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'Cs2Cn_Prk_DebitNoteTopSheet2')
CREATE TABLE Cs2Cn_Prk_DebitNoteTopSheet2
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] NVARCHAR(50),
	[CmpSchCode] NVARCHAR(40),
	[SecSalesQty] NUMERIC(18,0),
	[SecSalesVal] NUMERIC(18,6),
	[Liab] NUMERIC(18,2),
	[Amount] NUMERIC(18,6),
	[UploadFlag] NVARCHAR(10),
	[SyncId] NUMERIC(38, 0),
	[ServerDate] DATETIME
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Cs2Cn_DebitNoteTopSheet2')
DROP PROCEDURE Proc_Cs2Cn_DebitNoteTopSheet2
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_DebitNoteTopSheet2 0,'2014-02-04'
select * from Cs2Cn_Prk_DebitNoteTopSheet2 order by slno
Rollback Transaction
*/
CREATE PROCEDURE Proc_Cs2Cn_DebitNoteTopSheet2
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DebitNoteTopSheet2 
* PURPOSE		: To Extract LMISDetails
* CREATED BY	: Aravindh Deva C
* CREATED DATE	: 03.06.2016
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	DECLARE @DistCode As NVARCHAR(50)

	DELETE FROM Cs2Cn_Prk_DebitNoteTopSheet2 WHERE UploadFlag = 'Y'
	
	IF NOT EXISTS (SELECT * FROM UploadingReportTransaction (NOLOCK))
	BEGIN
		RETURN
	END

	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	
	
	DECLARE @FromDate DATETIME
	DECLARE @ToDate DATETIME
			
	SELECT @FromDate = MIN(SchValidFrom),@ToDate = MAX(SchValidTill) FROM SchemeMaster S (NOLOCK)
	WHERE EXISTS (SELECT 'C' FROM UploadingReportTransaction FP (NOLOCK) WHERE FP.TransDate BETWEEN S.SchValidFrom AND S.SchValidTill)

	EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate
	
	SELECT * INTO #ParleOutputTaxPercentage
	FROM ParleOutputTaxPercentage (NOLOCK)	

	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,
	B.DefaultPriceId ActualPriceId,SP.SlNo
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3

	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,
	B.DefaultPriceId,SP.SlNo
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId
	WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.[Status] = 0	

	SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,CAST (0 AS NUMERIC(18,6)) AS ActualSellRate,
	CAST (0 AS NUMERIC(18,6)) AS LCTR
	INTO #DebitSalesDetails
	FROM 
	(
	SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo FROM #BillingDetails
	
	UNION ALL
	
	SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,DefaultPriceId,SlNo FROM #ReturnDetails
	
	) Consolidated		
	
	DECLARE @SlNo AS INT
	SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'
	
	UPDATE M SET M.ActualSellRate = D.PrdBatDetailValue
	FROM #DebitSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.ActualPriceId = D.PriceId AND D.SLNo = @SlNo

	UPDATE R SET R.LCTR = R.BaseQty * (R.ActualSellRate+(R.ActualSellRate*(T.TaxPerc/100)))
	FROM #DebitSalesDetails R (NOLOCK),
	#ParleOutputTaxPercentage T (NOLOCK)
	WHERE R.SalId = T.Salid AND R.Slno = T.PrdSlno AND T.TransId = R.TransType

	CREATE TABLE #ApplicableProduct
	(
		SchId		INT,
		PrdId 		INT
	)
	
	INSERT INTO #ApplicableProduct(SchId,PrdId)
	SELECT DISTINCT A.SchId,B.Prdid
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid
		INNER JOIN Product C On B.Prdid = C.PrdId
		WHERE A.SchemeLvlMode = 0 AND B.PrdId <> 0
	UNION ALL
	SELECT DISTINCT A.SchId,E.Prdid
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On
		F.PrdId = E.Prdid
		WHERE A.SchemeLvlMode = 0 AND B.PrdCtgValMainId <> 0
	UNION ALL
	SELECT DISTINCT S.SchId,B.MasterRecordId
		FROM SchemeProducts A 
		INNER JOIN UdcDetails B on B.UDCUniqueId =A.PrdCtgValMainId 
		INNER JOIN SchemeMaster S ON A.SchId = S.SchId
		WHERE S.SchemeLvlMode = 1

	CREATE TABLE #ApplicableScheme
	(
		SchId			INT,
		CmpSchCode		NVARCHAR(40),
		SchValidFrom	DATETIME,
		SchValidTill	DATETIME,	
		Budget			NUMERIC(18,2),
		BudgetAllocationNo VARCHAR(100),
		PrdId 		INT
	)
	
	INSERT INTO #ApplicableScheme (SchId,CmpSchCode,SchValidFrom,SchValidTill,Budget,BudgetAllocationNo,PrdId)			
	SELECT DISTINCT A.SchId,S.CmpSchCode,S.SchValidFrom,S.SchValidTill,S.Budget,S.BudgetAllocationNo, A.PrdId
	FROM #ApplicableProduct A (NOLOCK),
	SchemeMaster S (NOLOCK),#BillingDetails B (NOLOCK)
	WHERE A.SchId = S.SchId AND B.SalInvDate BETWEEN S.SchValidFrom AND S.SchValidTill
	AND S.Claimable	= 1
	
	SELECT S.SchId,S.CmpSchCode,S.SchValidFrom,S.SchValidTill,S.Budget,S.BudgetAllocationNo,
	SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,2)) [SecSalesVal],CAST(0 AS NUMERIC(18,2)) Liab,
	CAST(0 AS NUMERIC(18,2)) Amount
	INTO #SchemeDebit
	FROM #ApplicableScheme S (NOLOCK),
	#DebitSalesDetails B (NOLOCK) 
	WHERE S.PrdId = B.PrdId AND B.TransDate BETWEEN S.SchValidFrom AND S.SchValidTill
	GROUP BY S.SchId,S.CmpSchCode,S.SchValidFrom,S.SchValidTill,Budget,BudgetAllocationNo
	ORDER BY S.SchId
	
	UPDATE SD SET SD.Amount = DBO.Fn_ReturnBudgetUtilized(SD.SchId)
	FROM #SchemeDebit SD (NOLOCK)
	
	UPDATE SD SET SD.Liab = CAST(( SD.Amount / SD.[SecSalesVal]) AS NUMERIC(18,2))
	FROM #SchemeDebit SD (NOLOCK)
	WHERE SD.[SecSalesVal] <> 0
		
	INSERT INTO Cs2Cn_Prk_DebitNoteTopSheet2 (DistCode,CmpSchCode,SecSalesQty,SecSalesVal,Liab,Amount,
	UploadFlag,SyncId,ServerDate)
	SELECT @DistCode,CmpSchCode,[SecSalesQty],[SecSalesVal],Liab,Amount,
	'N' UploadFlag,NULL,@ServerDate
	FROM #SchemeDebit
	
	RETURN			

END
GO
DELETE FROM CustomUpDownload WHERE SlNo = 139
INSERT INTO CustomUpDownload([SlNo],[SeqNo],[Module],[Screen],[ExportFnName],[ImportProcName],[ParkTable],[ValidateProcName],[TranType],[UpDownload],[MandatoryFile]) 
VALUES (139,1,'Debit Note Top Sheet Institution','DebitNoteTopSheet3','Proc_Cs2Cn_DebitNoteTopSheet3','','Cs2Cn_Prk_DebitNoteTopSheet3','','Transaction','Upload',1)
GO
DELETE FROM Tbl_UploadIntegration WHERE SequenceNo = 1014
INSERT INTO Tbl_UploadIntegration([SequenceNo],[ProcessName],[FolderName],[PrkTableName],[CreatedDate]) 
VALUES (1014,'DebitNoteTopSheet3','DebitNoteTopSheet3','Cs2Cn_Prk_DebitNoteTopSheet3',GETDATE())
GO
IF NOT EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'Cs2Cn_Prk_DebitNoteTopSheet3')
CREATE TABLE Cs2Cn_Prk_DebitNoteTopSheet3
(
	[SlNo] [numeric](38, 0) IDENTITY(1,1) NOT NULL,
	[DistCode] NVARCHAR(50),
	[ProgramCode] VARCHAR(50),
	[CtgCode] NVARCHAR(40),
	[Target] NUMERIC(18,6),
	[L2MSales] NUMERIC(18,6),
	[CurMSales] NUMERIC(18,6),
	[Outlet] NUMERIC(18,0),
	[DiscAmount] NUMERIC(18,6),
	[UploadFlag] NVARCHAR(10),
	[SyncId] NUMERIC(38, 0),
	[ServerDate] DATETIME
)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_Cs2Cn_DebitNoteTopSheet3')
DROP PROCEDURE Proc_Cs2Cn_DebitNoteTopSheet3
GO
/*
Begin transaction
EXEC Proc_Cs2Cn_DebitNoteTopSheet3 0,'2014-02-04'
select * from Cs2Cn_Prk_DebitNoteTopSheet3 order by slno
Rollback Transaction
*/
CREATE PROCEDURE Proc_Cs2Cn_DebitNoteTopSheet3
(
	@Po_ErrNo INT OUTPUT,
	@ServerDate DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_DebitNoteTopSheet3 
* PURPOSE		: To Extract LMISDetails
* CREATED BY	: Aravindh Deva C
* CREATED DATE	: 03.06.2016
* NOTE			:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	
	SET @Po_ErrNo=0
	
	DECLARE @DistCode As NVARCHAR(50)

	DELETE FROM Cs2Cn_Prk_DebitNoteTopSheet3 WHERE UploadFlag = 'Y'
	
	IF NOT EXISTS (SELECT * FROM UploadingReportTransaction (NOLOCK))
	BEGIN
		RETURN
	END

	SELECT @DistCode = DistributorCode FROM Distributor(NOLOCK)	
	
	DECLARE @FromDate DATETIME
	DECLARE @ToDate DATETIME

	SELECT ROW_NUMBER() OVER (ORDER BY InsId) SlNo,InsId,H.InsRefNo,TargetMonth,TargetYear,Confirm,
	CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01' FromDate,
	DATEADD(DD,-1,DATEADD(MM,1,CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01')) ToDate
	INTO #InstitutionToBeUpload	
	FROM InsTargetHD H (NOLOCK) WHERE H.[Status] = 1
	
	DECLARE @RowNo AS INT
	SET @RowNo = 1
	
	DECLARE @TotalRow AS INT
	
	DECLARE @TargetNo	AS INT
	
	SELECT @TotalRow = COUNT(InsId) FROM #InstitutionToBeUpload D (NOLOCK)

	CREATE TABLE #Institutions
	(
	InsId INT,
	CtgMainId INT,
	FromDate DATETIME,
	ToDate DATETIME,
	[Target] NUMERIC(18,6),
	DiscAmount NUMERIC(18,6),
	L2MSales  NUMERIC(18,6),
	CurMSales  NUMERIC(18,6),
	Outlet NUMERIC(18,0)
	)	

	WHILE (@RowNo < = @TotalRow)
	BEGIN	

		TRUNCATE TABLE BilledPrdDtCalculatedTax
		TRUNCATE TABLE BilledPrdHdForTax

		SELECT 	@TargetNo = InsId FROM #InstitutionToBeUpload C (NOLOCK) WHERE SlNo = @RowNo
		
		EXEC Proc_LoadingInstitutionsTarget @TargetNo,1

		INSERT INTO #Institutions (InsId,CtgMainId,FromDate,ToDate,[Target],DiscAmount,L2MSales,CurMSales,Outlet)
		SELECT @TargetNo,CtgMainId,FromDate,ToDate,SUM([Target]) [Target],SUM(ClmAmount) DiscAmount,
		0 L2MSales,0 CurMSales,0 Outlet
		FROM InsTargetDetailsTrans T (NOLOCK),
		#InstitutionToBeUpload I
		WHERE UserId = 1 AND T.SlNo <> 0
		AND I.InsId = @TargetNo
		GROUP BY CtgMainId,FromDate,ToDate
		
		SET @RowNo = @RowNo + 1
		
	END

	SELECT DISTINCT R.RtrId,RC.CtgMainId,I.InsId,I.FromDate,I.ToDate
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK),
	#Institutions I (NOLOCK)
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	AND I.CtgMainId = RC.CtgMainId
	
	SELECT S.InsId,S.CtgMainId,CAST(SUM(S.Sales) AS NUMERIC(18,2)) Sales
	INTO #CurrentSales
	FROM 
	(
	SELECT R.InsId,R.CtgMainId,SUM(S.SalGrossAmount) Sales FROM SalesInvoice S (NOLOCK),
	#FilterRetailer R
	WHERE S.SalInvDate BETWEEN FromDate AND ToDate AND S.DlvSts > 3
	AND S.RtrId = R.RtrId
	GROUP BY R.InsId,R.CtgMainId
	UNION ALL
	SELECT F.InsId,F.CtgMainId,-1 * SUM(R.RtnGrossAmt) FROM ReturnHeader R (NOLOCK),
	#FilterRetailer F
	WHERE R.ReturnDate BETWEEN FromDate AND ToDate AND R.Status = 0
	AND F.RtrId = R.RtrId
	GROUP BY F.InsId,F.CtgMainId
	) AS S GROUP BY S.InsId,S.CtgMainId

	SELECT R.InsId,R.CtgMainId,COUNT(DISTINCT S.RtrId) Outlet
	INTO #NoOfOutlet
	FROM SalesInvoice S (NOLOCK),
	#FilterRetailer R
	WHERE S.SalInvDate BETWEEN FromDate AND ToDate AND S.DlvSts > 3
	AND S.RtrId = R.RtrId
	GROUP BY R.InsId,R.CtgMainId
		
	--Last Two Month Sales
	UPDATE F SET F.ToDate = DATEADD (D,-1,FromDate),
	F.FromDate = DATEADD (MONTH,-2,FromDate) 
	FROM #FilterRetailer F (NOLOCK)
	
	SELECT S.InsId,S.CtgMainId,CAST(SUM(S.Sales) AS NUMERIC(18,2)) Sales
	INTO #L2MSales
	FROM 
	(
	SELECT R.InsId,R.CtgMainId,SUM(S.SalGrossAmount) Sales FROM SalesInvoice S (NOLOCK),
	#FilterRetailer R
	WHERE S.SalInvDate BETWEEN FromDate AND ToDate AND S.DlvSts > 3
	AND S.RtrId = R.RtrId
	GROUP BY R.InsId,R.CtgMainId
	UNION ALL
	SELECT F.InsId,F.CtgMainId,-1 * SUM(R.RtnGrossAmt) FROM ReturnHeader R (NOLOCK),
	#FilterRetailer F
	WHERE R.ReturnDate BETWEEN FromDate AND ToDate AND R.Status = 0
	AND F.RtrId = R.RtrId
	GROUP BY F.InsId,F.CtgMainId
	) AS S GROUP BY S.InsId,S.CtgMainId
	
	UPDATE I SET I.CurMSales = C.Sales
	FROM #Institutions I (NOLOCK),
	#CurrentSales C (NOLOCK)
	WHERE I.InsId = C.InsId AND I.CtgMainId = C.CtgMainId

	UPDATE I SET I.L2MSales = C.Sales / 2
	FROM #Institutions I (NOLOCK),
	#L2MSales C (NOLOCK)
	WHERE I.InsId = C.InsId AND I.CtgMainId = C.CtgMainId

	UPDATE I SET I.Outlet = C.Outlet
	FROM #Institutions I (NOLOCK),
	#NoOfOutlet C (NOLOCK)
	WHERE I.InsId = C.InsId AND I.CtgMainId = C.CtgMainId
		
	INSERT INTO Cs2Cn_Prk_DebitNoteTopSheet3 (DistCode,ProgramCode,CtgCode,[Target],L2MSales,CurMSales,Outlet,DiscAmount,
	UploadFlag,SyncId,ServerDate)
	SELECT @DistCode,U.InsRefNo,RC.CtgCode,[Target],L2MSales,CurMSales,Outlet,DiscAmount,
	'N' UploadFlag,NULL,@ServerDate
	FROM #Institutions I (NOLOCK),
	#InstitutionToBeUpload U (NOLOCK),
	RetailerCategory RC (NOLOCK)
	WHERE I.InsId = U.InsId AND I.CtgMainId = RC.CtgMainId
	
	--
	UPDATE S SET S.RptUpload = 1
	FROM UploadingReportTransaction U (NOLOCK),
	SalesInvoice S (NOLOCK) WHERE U.TransType = 1 AND U.TransId = S.SalId

	UPDATE S SET S.RptUpload = 1
	FROM UploadingReportTransaction U (NOLOCK),
	ReturnHeader S (NOLOCK) WHERE U.TransType = 2 AND U.TransId = S.ReturnID	
	--
	
	RETURN			

END
GO
--6 Processes
DELETE FROM RptGroup WHERE RptId = 288
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',288,'TradePromotionReport','Trade Promotion Report',1)
GO
DELETE FROM RptHeader WHERE RptId = 288
INSERT INTO RptHeader([GrpCode],[RptCaption],[RptId],[RpCaption],[SPName],[TblName],[RptName],[UserIds]) VALUES ('TradePromotionReport','Trade Promotion Report','288','Trade Promotion Report','Proc_RptTradePromotionReport','RptTradePromotionReport','RptTradePromotionReport.rpt','')
GO
DELETE FROM RptSelectionHd WHERE SelcId = 315
INSERT INTO RptSelectionHd([SelcId],[SelcName],[TblName],[Condition]) VALUES (315,'Sel_ReportType','RptFilter',1)
GO
DELETE FROM RptFilter WHERE RptId = 288 AND SelcId = 315
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (288,315,1,'Railway Discount Reconsolidation Report')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (288,315,2,'MT Chain SKU wise Offer and Combi details Report')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (288,315,3,'Chain Wise Bill Details Including Railways Report')
INSERT INTO RptFilter([RptId],[SelcId],[FilterId],[FilterDesc]) VALUES (288,315,4,'MT Debit Summary Report')
GO
DELETE FROM RptDetails WHERE RptId = 288
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (288,1,'FromDate',-1,'','','From Date*','',1,'',10,0,1,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (288,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (288,3,'RptFilter',-2,'','FilterId,FilterDesc,FilterDesc','Report Type...*','',1,'',315,1,1,'Press F4/Double Click to select Report Type',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (288,4,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,0,'Press F4/Double Click to select Company',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (288,5,'RetailerCategoryLevel',4,'CmpId','CtgLevelId,CtgLevelName,CtgLevelName','Category Level...','Company',1,'CmpId',29,1,0,'Press F4/Double Click to Category Level',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (288,6,'RetailerCategory',5,'CtgLevelId','CtgMainId,CtgName,CtgName','Category Level Value...','RetailerCategoryLevel',1,'CtgLevelId',30,1,0,'Press F4/Double Click to Category Level Value',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (288,7,'ProductCategoryLevel',4,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,0,'Press F4/Double Click to select Product Hierarchy Level',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (288,8,'ProductCategoryValue',7,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,0,0,'Press F4/Double Click to select Product Hierarchy Level Value',1)
GO
DELETE FROM RptFormula WHERE RptId = 288
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,1,'Hd_DistName','',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,2,'Fil_FromDate','From Date',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,3,'Fil_ToDate','To Date',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,4,'Cap_Company','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,5,'Disp_Company','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,6,'Disp_FromDate','From Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,7,'Disp_ToDate','To Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,8,'CatLevel','Category Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,9,'CatVal','Category Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,10,'Disp_CategoryLevel','CategoryLevel',1,29)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,11,'Disp_CategoryLevelValue','CategoryLevelValue',1,30)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,12,'ProductCategoryLevel','Product Hierarchy Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,13,'ProductCategoryValue','Product Hierarchy Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,14,'Disp_ProductCategoryLevel','ProductCategoryLevel',1,16)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,15,'Disp_ProductCategoryValue','ProductCategoryLevelValue',1,21)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,16,'ValReportType','',1,315)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,17,'Cap Page','Page',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,18,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,19,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,20,'PrdName','Product Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,21,'TotalPCS','Total PCS',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,22,'MRP','MRP',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,23,'LCTR','LCTR',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,24,'IRCTCMargin','IRCTC Margin',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,25,'MarkUpDown','MarkUp /Mark Down',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,26,'IRCTCRate','IRCTC Rate',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,27,'TotalMRP','Parle Total MRP Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,28,'TotalLCTR','Parle Total LCTR Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,29,'IRCTCTotal','IRCTC Total Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,30,'ClmAmount','Claim Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,31,'LibOnMRP','% Lib On MRP',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,32,'LibOnLCTR','% Lib On LCTR',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,33,'BillNo','Bill No',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,34,'BillDate','Bill Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,35,'PartyName','Party Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,36,'PktWgt','Pkt Wgt',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,37,'QtyInPkt','Quantity in Pkts',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,38,'ChainLandRate','Chain Lending Rate',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,39,'Amount','Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,40,'RtrName','Retailer Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,41,'ParleLCTR','Parle LCTR',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,42,'ChainRate','Chain Rate as Per TOT',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,43,'ChainOffRate','Chain Offer Rate',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,44,'TotalOffLCTR','Total Offer LCTR',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,45,'TotalOffPerTOT','Total Offer Sec Sales as Per TOT',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,46,'TotalOffPerChain','Total Offer Sec Sales as Per offer rate to Chain',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,47,'OffClmDiff','Offer Claim Difference',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,48,'OffLiabVal','Offer Liability Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,49,'ClmLiabWOTOT','% Liab Of claims on Total Sales without TOT',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,50,'ClmLiabTotSal','% Liab Of claims on Total Sales',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,51,'CtgName','Chain Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,52,'TotLCTR','Total LCTR',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,53,'SalesTOT','Total Sec Sales As Per TOT',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,54,'ClaimDiff','TOT Diff Claims',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,55,'LiabSales','% Liab on Non Offer Sale',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,56,'OffTOT','Total Offer Sec Sales as Per TOT',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,57,'TotalOff','Total Offer Sec Sale As Per Offer Rate To Chain',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,58,'OffClaimDiff','Offers Claims Diff (TOT+Offer)',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,59,'LiabOff','Offer Liability Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,60,'TotalSales','Total Sale(Offer + Non Offer)',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,61,'LiabWOTOT','% Liab of Offer Claims On Sale Without TOT',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,62,'LiabTOT','% Liab of Offer Claims On Total Sale',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (288,63,'TotalLiab','Total % Liab',1,0)
GO
DELETE FROM RptGridView WHERE RptId = 288
INSERT INTO RptGridView([RptId],[RptName],[CrystalView],[GridView],[ExcelView],[PDFView]) VALUES (288,'RptTradePromotionReport.rpt',1,0,1,0)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_RptRailwayDiscountReconsolidation')
DROP PROCEDURE Proc_RptRailwayDiscountReconsolidation
GO
--EXEC Proc_RptRailwayDiscountReconsolidation 288,2,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptRailwayDiscountReconsolidation
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptTradePromotionReport
* PURPOSE	: To Return the Scheme Utilization Details
* CREATED	: Aravindh Deva C
* CREATED DATE	: 27 05 2016
* NOTE		: Parle SP for Trade Promotion Reports
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/  
BEGIN
	SET NOCOUNT ON
	
	DECLARE @FromDate			AS	DATETIME
	DECLARE @ToDate				AS	DATETIME
	DECLARE @CmpId				AS  INT 
	DECLARE @CtgLevelId			AS  INT  
	DECLARE @CtgMainId			AS  INT	
	DECLARE @CmpPrdCtgId		AS INT
	DECLARE @PrdCtgValMainId	AS INT	
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)

	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))    
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))

	SET @CmpPrdCtgId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCtgValMainId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	
	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgCode
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	AND RC.CtgCode = 'RAI'

	AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
	RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))

	AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
	RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))

	AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
	RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
	--To Filter Retailers

	--To Filter Products
	SELECT DISTINCT E.PrdId
	INTO #FilterProduct
	FROM ProductCategoryValue C (NOLOCK)
	INNER JOIN ProductCategoryValue D (NOLOCK) ON
	D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
	INNER JOIN Product E (NOLOCK) ON D.PrdCtgValMainId = E.PrdCtgValMainId
	INNER JOIN ProductCategoryLevel L (NOLOCK) ON L.CmpPrdCtgId = C.CmpPrdCtgId
	
	WHERE (L.CmpId=(CASE @CmpId WHEN 0 THEN L.CmpId ELSE 0 END) OR
	L.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	 
	AND (L.CmpPrdCtgId = (CASE @CmpPrdCtgId  WHEN 0 THEN L.CmpPrdCtgId ELSE 0 END) OR
	L.CmpPrdCtgId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)))
	
	AND (C.PrdCtgValMainId = (CASE @PrdCtgValMainId  WHEN 0 THEN C.PrdCtgValMainId ELSE 0 END) OR 
	C.PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId ,21, @Pi_UsrId)))
	--To Filter Products

	EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate
	
	SELECT * INTO #ParleOutputTaxPercentage
	FROM ParleOutputTaxPercentage (NOLOCK)	

	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	SP.PriceId,SP.SlNo,SP.PrdUom1EditedSelRate
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)

	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	SP.PriceId,SP.SlNo,SP.PrdEditSelRte
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID
	WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.Status = 0
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)

	SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty TotalPCS,MRP,PriceId,SlNo,CAST(0 AS NUMERIC(18,6))[SellRate],
	CAST(0 AS NUMERIC(18,2)) IRCTCMargin,CAST(0 AS INT) [Type],CAST(0 AS NUMERIC(18,2)) AS LCTR
	INTO #RailwaySalesDetails
	FROM 
	(
	SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,MRP,PriceId,SlNo FROM #BillingDetails
	
	UNION ALL
	
	SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,MRP,PriceId,SlNo FROM #ReturnDetails
	
	) Consolidated
	
	DECLARE @SlNo AS INT
	
	SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'
	
	UPDATE R SET R.[SellRate] = D.PrdBatDetailValue
	FROM #RailwaySalesDetails R (NOLOCK),
	ProductBatch B (NOLOCK),
	ProductBatchDetails D (NOLOCK)
	WHERE R.PrdBatId = B.PrdBatId AND B.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo
	
	SELECT R.PriceId,C.DiscountPerc,C.[TYPE]
	INTO #ExistingSpecialPrice
	FROM #RailwaySalesDetails R (NOLOCK),
	SpecialRateAftDownLoad_Calc C (NOLOCK)
	WHERE R.PriceId = CAST(REPLACE(C.ContractPriceIds,'-','') AS BIGINT)

	UPDATE R SET R.IRCTCMargin = S.DiscountPerc,R.[Type] = S.[TYPE]
	FROM #RailwaySalesDetails R (NOLOCK),
	#ExistingSpecialPrice S (NOLOCK)
	WHERE R.PriceId = S.PriceId
	
	UPDATE R SET R.LCTR = R.[SellRate] + (R.[SellRate]*(T.TaxPerc/100))
	FROM #RailwaySalesDetails R (NOLOCK),
	#ParleOutputTaxPercentage T (NOLOCK)
	WHERE R.TransType = T.TransId AND R.SalId = T.Salid AND R.Slno = T.PrdSlno	
	
	--SELECT RtrId,TransDate,P.PrdId,P.PrdName,P.PrdCCode,SUM(TotalPCS) TotalPCS,MRP,
	SELECT P.PrdId,P.PrdName,SUM(TotalPCS) TotalPCS,MRP,
	LCTR,IRCTCMargin,CASE S.[Type] WHEN 1 THEN 'Mark Up' WHEN 2 THEN 'Mark Down' ELSE '' END MarkUpDown,
	CAST(0 AS NUMERIC(18,6)) IRCTCRate,
	CAST(0 AS NUMERIC(18,6)) TotalMRP,CAST(0 AS NUMERIC(18,6)) TotalLCTR,
	CAST(0 AS NUMERIC(18,6)) IRCTCTotal,CAST(0 AS NUMERIC(18,6)) ClmAmount,
	CAST(0 AS NUMERIC(18,2)) LibOnMRP,CAST(0 AS NUMERIC(18,2)) LibOnLCTR
	INTO #RailwayDiscount
	FROM #RailwaySalesDetails S (NOLOCK)
	INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	GROUP BY P.PrdId,P.PrdName,MRP,LCTR,IRCTCMargin,S.[Type]
	
	UPDATE R SET R.IRCTCRate = MRP - (MRP * IRCTCMargin / 100.00), TotalMRP  = TotalPCS * MRP, TotalLCTR = TotalPCS * LCTR
	FROM #RailwayDiscount R (NOLOCK)
	
	UPDATE R SET R.IRCTCTotal = TotalPCS * IRCTCRate
	FROM #RailwayDiscount R (NOLOCK)

	UPDATE R SET R.ClmAmount = TotalLCTR - IRCTCTotal
	FROM #RailwayDiscount R (NOLOCK)

	UPDATE R SET R.LibOnMRP = ClmAmount / TotalMRP
	FROM #RailwayDiscount R (NOLOCK)
	WHERE R.TotalMRP <> 0

	UPDATE R SET R.LibOnLCTR = ClmAmount / TotalLCTR
	FROM #RailwayDiscount R (NOLOCK)
	WHERE R.TotalLCTR <> 0	

	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptRailwayDiscountReconsolidation_Excel')
	DROP TABLE RptRailwayDiscountReconsolidation_Excel	
	
	SELECT * 
	INTO RptRailwayDiscountReconsolidation_Excel
	FROM #RailwayDiscount (NOLOCK) ORDER BY PrdName

	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptRailwayDiscountReconsolidation_Excel
	
	SELECT * FROM RptRailwayDiscountReconsolidation_Excel ORDER BY PrdName,MarkUpDown

	DELETE FROM RptExcelHeaders WHERE RptId = 288
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,1,'PrdId','PrdId',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,2,'PrdName','Product Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,3,'TotalPCS','Total PCS',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,4,'MRP','MRP',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,5,'LCTR','LCTR',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,6,'IRCTCMargin','IRCTC Margin',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,7,'MarkUpDown','MarkUp /Mark Down',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,8,'IRCTCRate','IRCTC Rate',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,9,'TotalMRP','Parle Total MRP Value',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,10,'TotalLCTR','Parle Total LCTR Value',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,11,'IRCTCTotal','IRCTC Total Value',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,12,'ClmAmount','Claim Amount',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,13,'LibOnMRP','% Lib On MRP',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,14,'LibOnLCTR','% Lib On LCTR',1,1)
	
	RETURN	

END
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_RptMTChainSKUWiseOffer')
DROP PROCEDURE Proc_RptMTChainSKUWiseOffer
GO
--EXEC Proc_RptMTChainSKUWiseOffer 288,2,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptMTChainSKUWiseOffer
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptTradePromotionReport
* PURPOSE	: To Return the Trade Promotion Report
* CREATED	: Aravindh Deva C
* CREATED DATE	: 27 05 2016
* NOTE		: Parle SP for Trade Promotion Reports
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/  
BEGIN
	SET NOCOUNT ON
	
	DECLARE @FromDate			AS	DATETIME
	DECLARE @ToDate				AS	DATETIME
	DECLARE @CmpId				AS  INT 
	DECLARE @CtgLevelId			AS  INT  
	DECLARE @CtgMainId			AS  INT	
	DECLARE @CmpPrdCtgId		AS INT
	DECLARE @PrdCtgValMainId	AS INT	
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)

	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))    
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))

	SET @CmpPrdCtgId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCtgValMainId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))

	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgCode
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId

	AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
	RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))

	AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
	RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))

	AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
	RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
	--To Filter Retailers

	--To Filter Products
	SELECT DISTINCT E.PrdId
	INTO #FilterProduct
	FROM ProductCategoryValue C (NOLOCK)
	INNER JOIN ProductCategoryValue D (NOLOCK) ON
	D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
	INNER JOIN Product E (NOLOCK) ON D.PrdCtgValMainId = E.PrdCtgValMainId
	INNER JOIN ProductCategoryLevel L (NOLOCK) ON L.CmpPrdCtgId = C.CmpPrdCtgId
	
	WHERE 
	(L.CmpId=(CASE @CmpId WHEN 0 THEN L.CmpId ELSE 0 END) OR
	L.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))	AND 
	
	(L.CmpPrdCtgId = (CASE @CmpPrdCtgId  WHEN 0 THEN L.CmpPrdCtgId ELSE 0 END) OR
	L.CmpPrdCtgId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)))
	
	AND (C.PrdCtgValMainId = (CASE @PrdCtgValMainId  WHEN 0 THEN C.PrdCtgValMainId ELSE 0 END) OR 
	C.PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId ,21, @Pi_UsrId)))
	
	AND E.PrdType = 3
	--To Filter Products

	EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate

	SELECT * INTO #ParleOutputTaxPercentage
	FROM ParleOutputTaxPercentage (NOLOCK)		

	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,PrdBatId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	SP.PriceId,SP.SlNo,SP.PrdUom1EditedSelRate
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)

	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	SP.PriceId,SP.SlNo,SP.PrdEditSelRte
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID
	WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.Status = 0
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)

	SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty TotalPCS,MRP,PriceId,SlNo,[SellRate],
	CAST(0 AS NUMERIC(18,2)) ChainRate,CAST(0 AS NUMERIC(18,2)) AS ParleLCTR,CAST(0 AS NUMERIC(18,2)) ChainOffRate
	INTO #MTSalesDetails
	FROM 
	(
	SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,MRP,PriceId,SlNo,PrdUom1EditedSelRate [SellRate] FROM #BillingDetails
	
	UNION ALL
	
	SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,MRP,PriceId,SlNo,PrdEditSelRte FROM #ReturnDetails
	
	) Consolidated	
	
	SELECT M.TransType,M.SalId,M.RtrId,M.PrdId,M.SlNo,K.PrdId [NormalPrd],K.PrdBatId [NormalBat],
	CAST(0 AS NUMERIC(18,6)) NormalSellRate,CAST(0 AS NUMERIC(18,6)) NormalSpecialRate
	INTO #NormalProduct
	FROM #MTSalesDetails M,
	KitProductTransDt K (NOLOCK)
	WHERE M.SalId = K.TransNo AND M.PrdId = K.KitPrdId AND M.SlNo = K.SlNo
	AND K.TransId = (CASE M.TransType WHEN 2 THEN 8 ELSE 1 END) -- TransId = 1 - Billing, 8 - Sales Return
	
	DECLARE @SlNo AS INT
	SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'
	
	UPDATE N SET N.NormalSellRate = D.PrdBatDetailValue
	FROM #NormalProduct N (NOLOCK),
	ProductBatch B (NOLOCK),
	ProductBatchDetails D (NOLOCK)
	WHERE N.NormalBat = B.PrdBatId AND B.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo
	
	UPDATE M SET M.SellRate = N.NormalSellRate
	FROM #MTSalesDetails M,
	(
	SELECT TransType,SalId,PrdId,SlNo,SUM(NormalSellRate) NormalSellRate FROM #NormalProduct
	GROUP BY TransType,SalId,PrdId,SlNo
	) N WHERE M.TransType = N.TransType AND M.SalId = N.SalId AND M.PrdId = N.PrdId AND M.SlNo = N.SlNo
	
	SELECT R.RtrId,P.PrdId,B.PrdBatId,S.SplSelRate,DownloadedDate
	INTO #SpecialPrice
	FROM SpecialRateAftDownLoad S (NOLOCK),
	#FilterRetailer R,
	Product P (NOLOCK), ProductBatch B (NOLOCK)
	WHERE S.RtrCtgValueCode = R.CtgCode AND
	S.PrdCCode = P.PrdCCode AND B.PrdBatCode = S.PrdBatCCode AND P.PrdId = B.PrdId
	AND EXISTS (SELECT 'C' FROM #NormalProduct N (NOLOCK) WHERE P.PrdId = N.NormalPrd)
	
	SELECT S.* 
	INTO #LatesSpecialPrice
	FROM #SpecialPrice S,
	(
		SELECT RtrId,PrdId,PrdBatId,MAX(DownloadedDate) DownloadedDate 
		FROM #SpecialPrice
		GROUP BY RtrId,PrdId,PrdBatId
	) L
	WHERE L.RtrId = S.RtrId AND L.PrdId = S.PrdId AND L.PrdBatId = S.PrdBatId AND L.DownloadedDate = S.DownloadedDate

	UPDATE N SET N.NormalSpecialRate = L.SplSelRate
	FROM #NormalProduct N (NOLOCK),
	#LatesSpecialPrice L (NOLOCK)
	WHERE N.RtrId = L.RtrId AND N.NormalPrd = L.PrdId AND N.NormalBat = L.PrdBatId
	
	UPDATE M SET M.ChainRate = N.NormalSpecialRate
	FROM #MTSalesDetails M,
	(
	SELECT TransType,SalId,PrdId,SlNo,SUM(NormalSpecialRate) NormalSpecialRate FROM #NormalProduct
	GROUP BY TransType,SalId,PrdId,SlNo
	) N WHERE M.TransType = N.TransType AND M.SalId = N.SalId AND M.PrdId = N.PrdId AND M.SlNo = N.SlNo	
	
	UPDATE R SET R.ParleLCTR = (R.[SellRate]+(R.[SellRate]*(T.TaxPerc/100)))
	FROM #MTSalesDetails R (NOLOCK),
	#ParleOutputTaxPercentage T (NOLOCK)
	WHERE R.TransType = T.TransId AND R.SalId = T.Salid AND R.Slno = T.PrdSlno	

	UPDATE R SET R.ChainOffRate = D.PrdBatDetailValue
	FROM #MTSalesDetails R (NOLOCK),
	ProductBatch B (NOLOCK),
	ProductBatchDetails D (NOLOCK)
	WHERE R.PrdBatId = B.PrdBatId AND B.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo		
	
	SELECT S.RtrId,R.RtrName,P.PrdId,P.PrdName,MRP,SUM(TotalPCS) QtyInPkt,
	ParleLCTR,ChainRate,ChainOffRate,
	CAST(0 AS NUMERIC(18,2)) TotalOffLCTR,CAST(0 AS NUMERIC(18,2)) TotalOffPerTOT,
	CAST(0 AS NUMERIC(18,2)) TotalOffPerChain,CAST(0 AS NUMERIC(18,2)) OffClmDiff,
	CAST(0 AS NUMERIC(18,2)) OffLiabVal,CAST(0 AS NUMERIC(18,2)) ClmLiabWOTOT,
	CAST(0 AS NUMERIC(18,2)) ClmLiabTotSal
	INTO #MTChain
	FROM #MTSalesDetails S (NOLOCK)
	INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	INNER JOIN Retailer R (NOLOCK) ON S.RtrId = R.RtrId
	GROUP BY S.RtrId,R.RtrName,P.PrdId,P.PrdName,MRP,ParleLCTR,ChainRate,ChainOffRate

	UPDATE R SET R.TotalOffLCTR = QtyInPkt * ParleLCTR,
	R.TotalOffPerTOT = QtyInPkt * ChainRate,
	R.TotalOffPerChain = QtyInPkt * ChainOffRate
	FROM #MTChain R (NOLOCK)

	UPDATE R SET R.OffClmDiff = TotalOffLCTR - TotalOffPerChain,
	R.OffLiabVal = TotalOffPerTOT - TotalOffPerChain
	FROM #MTChain R (NOLOCK)

	UPDATE R SET R.ClmLiabWOTOT = OffLiabVal / TotalOffLCTR, ClmLiabTotSal = OffClmDiff / TotalOffLCTR
	FROM #MTChain R (NOLOCK)
	WHERE TotalOffLCTR <> 0

	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptMTChainSKUWiseOffer_Excel')
	DROP TABLE RptMTChainSKUWiseOffer_Excel
	
	SELECT * 
	INTO RptMTChainSKUWiseOffer_Excel
	FROM #MTChain (NOLOCK)

	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptMTChainSKUWiseOffer_Excel
	
	SELECT * FROM RptMTChainSKUWiseOffer_Excel	

	DELETE FROM RptExcelHeaders WHERE RptId = 288
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,1,'RtrId','RtrId',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,2,'RtrName','Retailer Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,3,'PrdId','PrdId',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,4,'PrdName','Product Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,5,'MRP','MRP',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,6,'QtyInPkt','Quantity in Pkts',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,7,'ParleLCTR','Parle LCTR',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,8,'ChainRate','Chain Rate as Per TOT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,9,'ChainOffRate','Chain Offer Rate',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,10,'TotalOffLCTR','Total Offer LCTR',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,11,'TotalOffPerTOT','Total Offer Sec Sales as Per TOT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,12,'TotalOffPerChain','Total Offer Sec Sales as Per offer rate to Chain',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,13,'OffClmDiff','Offer Claim Difference',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,14,'OffLiabVal','Offer Liability Value',1,1)		
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,15,'ClmLiabWOTOT','% Liab Of claims on Total Sales without TOT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,16,'ClmLiabTotSal','% Liab Of claims on Total Sales',1,1)

	RETURN
END
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_RptChainWiseBillDetails')
DROP PROCEDURE Proc_RptChainWiseBillDetails
GO
--EXEC Proc_RptChainWiseBillDetails 288,2,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptChainWiseBillDetails
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptChainWiseBillDetsils
* PURPOSE	: 
* CREATED	: Aravindh Deva C
* CREATED DATE	: 27 05 2016
* NOTE		: Parle SP for Trade Promotion Reports
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/  
BEGIN
	SET NOCOUNT ON
	
	DECLARE @FromDate			AS	DATETIME
	DECLARE @ToDate				AS	DATETIME
	DECLARE @CmpId				AS  INT 
	DECLARE @CtgLevelId			AS  INT  
	DECLARE @CtgMainId			AS  INT	
	DECLARE @CmpPrdCtgId		AS INT
	DECLARE @PrdCtgValMainId	AS INT	
	
	DECLARE @ReportType	AS INT	
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)

	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))    
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))

	SET @CmpPrdCtgId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCtgValMainId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	
	SET @ReportType = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,315,@Pi_UsrId))

	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgCode
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId

	AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
	RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))

	AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
	RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))

	AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
	RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
	--To Filter Retailers

	--To Filter Products
	SELECT DISTINCT E.PrdId
	INTO #FilterProduct
	FROM ProductCategoryValue C (NOLOCK)
	INNER JOIN ProductCategoryValue D (NOLOCK) ON
	D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
	INNER JOIN Product E (NOLOCK) ON D.PrdCtgValMainId = E.PrdCtgValMainId
	INNER JOIN ProductCategoryLevel L (NOLOCK) ON L.CmpPrdCtgId = C.CmpPrdCtgId
	
	WHERE 
	(L.CmpId=(CASE @CmpId WHEN 0 THEN L.CmpId ELSE 0 END) OR
	L.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))) AND
	
	(L.CmpPrdCtgId = (CASE @CmpPrdCtgId  WHEN 0 THEN L.CmpPrdCtgId ELSE 0 END) OR
	L.CmpPrdCtgId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)))
	
	AND (C.PrdCtgValMainId = (CASE @PrdCtgValMainId  WHEN 0 THEN C.PrdCtgValMainId ELSE 0 END) OR 
	C.PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId ,21, @Pi_UsrId)))
	--To Filter Products
	
	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SUM(SP.BaseQty) TotalPCS,SP.PrdUnitMRP MRP,SP.PriceId,
	CAST(0 AS NUMERIC(18,6)) ChainLandRate
	INTO #ChainSalesDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	GROUP BY S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdUnitMRP,SP.PriceId

	SELECT R.PriceId,C.SplSelRate
	INTO #ExistingSpecialPrice
	FROM #ChainSalesDetails R (NOLOCK),
	SpecialRateAftDownLoad_Calc C (NOLOCK)
	WHERE R.PriceId = CAST(REPLACE(C.ContractPriceIds,'-','') AS BIGINT)

	UPDATE R SET R.ChainLandRate = S.SplSelRate
	FROM #ChainSalesDetails R (NOLOCK),
	#ExistingSpecialPrice S (NOLOCK)
	WHERE R.PriceId = S.PriceId	

	SELECT S.SalId,S.SalInvNo BillNo,S.SalInvDate BillDate,S.RtrId,R.RtrName,P.PrdId,P.PrdName,
	PrdWgt PktWgt,MRP,TotalPCS QtyInPkt,ChainLandRate,
	CAST(0 AS NUMERIC(18,6)) Amount
	INTO #Chain
	FROM #ChainSalesDetails S (NOLOCK)
	INNER JOIN Product P (NOLOCK) ON S.PrdId = P.PrdId
	INNER JOIN Retailer R (NOLOCK) ON S.RtrId = R.RtrId
	
	UPDATE C SET C.Amount = QtyInPkt * ChainLandRate
	FROM #Chain C (NOLOCK)

	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptChainWiseBillDetails_Excel')
	DROP TABLE RptChainWiseBillDetails_Excel
		
	SELECT * 
	INTO RptChainWiseBillDetails_Excel
	FROM #Chain (NOLOCK)

	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptChainWiseBillDetails_Excel
	
	SELECT * FROM RptChainWiseBillDetails_Excel	

	DELETE FROM RptExcelHeaders WHERE RptId = 288
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,1,'SalId','SalId',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,2,'BillNo','BillNo',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,3,'BillDate','BillDate',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,4,'RtrId','RtrId',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,5,'RtrName','Party Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,6,'PrdId','PrdId',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,7,'PrdName','Product Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,8,'PktWgt','Pkt Wgt',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,9,'MRP','MRP',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,10,'QtyInPkt','Quantity in Pkts',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,11,'ChainLandRate','Chain Lending Rate',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,12,'Amount','Amount',1,1)	

	RETURN
END
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_RptMTDebitSummary')
DROP PROCEDURE Proc_RptMTDebitSummary
GO
--EXEC Proc_RptMTDebitSummary 288,2,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptMTDebitSummary
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptTradePromotionReport
* PURPOSE	: To Return the Trade Promotion Report
* CREATED	: Aravindh Deva C
* CREATED DATE	: 27 05 2016
* NOTE		: Parle SP for Trade Promotion Reports
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/  
BEGIN
	SET NOCOUNT ON
	
	DECLARE @FromDate			AS	DATETIME
	DECLARE @ToDate				AS	DATETIME
	DECLARE @CmpId				AS  INT 
	DECLARE @CtgLevelId			AS  INT  
	DECLARE @CtgMainId			AS  INT	
	DECLARE @CmpPrdCtgId		AS INT
	DECLARE @PrdCtgValMainId	AS INT	
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)

	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))    
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))

	SET @CmpPrdCtgId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCtgValMainId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))

	--To Filter Retailers
	SELECT DISTINCT R.RtrId,RC.CtgMainId,RC.CtgName,RC.CtgCode
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId

	AND (RVC.CmpId=(CASE @CmpId WHEN 0 THEN RVC.CmpId ELSE 0 END) OR
	RVC.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))

	AND (RCL.CtgLevelId=(CASE @CtgLevelId WHEN 0 THEN RCL.CtgLevelId ELSE 0 END) OR  
	RCL.CtgLevelId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId)))

	AND (RC.CtgMainId=(CASE @CtgMainId WHEN 0 THEN RC.CtgMainId ELSE 0 END) OR  
	RC.CtgMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId)))
	--To Filter Retailers

	--To Filter Products
	SELECT DISTINCT E.PrdId,E.PrdType
	INTO #FilterProduct
	FROM ProductCategoryValue C (NOLOCK)
	INNER JOIN ProductCategoryValue D (NOLOCK) ON
	D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
	INNER JOIN Product E (NOLOCK) ON D.PrdCtgValMainId = E.PrdCtgValMainId
	INNER JOIN ProductCategoryLevel L (NOLOCK) ON L.CmpPrdCtgId = C.CmpPrdCtgId
	
	WHERE 
	(L.CmpId=(CASE @CmpId WHEN 0 THEN L.CmpId ELSE 0 END) OR
	L.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))	AND 
	
	(L.CmpPrdCtgId = (CASE @CmpPrdCtgId  WHEN 0 THEN L.CmpPrdCtgId ELSE 0 END) OR
	L.CmpPrdCtgId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)))
	
	AND (C.PrdCtgValMainId = (CASE @PrdCtgValMainId  WHEN 0 THEN C.PrdCtgValMainId ELSE 0 END) OR 
	C.PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId ,21, @Pi_UsrId)))
	--To Filter Products

	EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate

	SELECT * INTO #ParleOutputTaxPercentage
	FROM ParleOutputTaxPercentage (NOLOCK)		

	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	SP.PriceId,SP.SlNo,SP.PrdUom1EditedSelRate,B.DefaultPriceId
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)

	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	SP.PriceId,SP.SlNo,SP.PrdEditSelRte,B.DefaultPriceId
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdId  = B.PrdId AND SP.PrdBatId = B.PrdBatId
	WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.Status = 0
	AND EXISTS (SELECT 'C' FROM #FilterRetailer FR (NOLOCK) WHERE S.RtrId = FR.RtrId)
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)

	SELECT TransType,RtrId,SalId,TransDate,PrdId,BaseQty TotalPCS,MRP,PriceId,SlNo,[SellRate],DefaultPriceId,
	CAST(0 AS NUMERIC(18,6))[ActualSellRate],CAST(0 AS NUMERIC(18,6))[SpecialSellRate],
	CAST(0 AS NUMERIC(18,6)) TotalLCTR, CAST(0 AS NUMERIC(18,6)) SalesTOT
	INTO #MTSalesDetails
	FROM 
	(
	SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,BaseQty,MRP,PriceId,SlNo,PrdUom1EditedSelRate [SellRate],DefaultPriceId FROM #BillingDetails
	
	UNION ALL
	
	SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,BaseQty,MRP,PriceId,SlNo,PrdEditSelRte,DefaultPriceId FROM #ReturnDetails
	
	) Consolidated

	SELECT M.TransType,M.SalId,M.RtrId,M.PrdId,M.SlNo,K.PrdId [NormalPrd],K.PrdBatId [NormalBat],
	CAST(0 AS NUMERIC(18,6)) NormalSellRate,CAST(0 AS NUMERIC(18,6)) NormalSpecialRate
	INTO #NormalProduct
	FROM #MTSalesDetails M,
	KitProductTransDt K (NOLOCK)
	WHERE M.SalId = K.TransNo AND M.PrdId = K.KitPrdId AND M.SlNo = K.SlNo
	AND K.TransId = (CASE M.TransType WHEN 2 THEN 8 ELSE 1 END) -- TransId = 1 - Billing, 8 - Sales Return
	
	DECLARE @SlNo AS INT
	SELECT @SlNo = SlNo FROM BatchCreation (NOLOCK) WHERE FieldDesc = 'Selling Price'
	
	UPDATE M SET M.ActualSellRate = D.PrdBatDetailValue
	FROM #MTSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo

	UPDATE M SET M.[SpecialSellRate] = D.PrdBatDetailValue
	FROM #MTSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.PriceId = D.PriceId AND D.SLNo = @SlNo
	AND PriceCode LIKE '%-Spl Rate-%'
	
	--
	UPDATE N SET N.NormalSellRate = D.PrdBatDetailValue
	FROM #NormalProduct N (NOLOCK),
	ProductBatch B (NOLOCK),
	ProductBatchDetails D (NOLOCK)
	WHERE N.NormalBat = B.PrdBatId AND B.DefaultPriceId = D.PriceId AND D.SLNo = @SlNo
	
	UPDATE M SET M.[ActualSellRate] = N.NormalSellRate
	FROM #MTSalesDetails M,
	(
	SELECT TransType,SalId,PrdId,SlNo,SUM(NormalSellRate) NormalSellRate FROM #NormalProduct
	GROUP BY TransType,SalId,PrdId,SlNo
	) N WHERE M.TransType = N.TransType AND M.SalId = N.SalId AND M.PrdId = N.PrdId AND M.SlNo = N.SlNo
	--
	
	SELECT R.RtrId,P.PrdId,B.PrdBatId,S.SplSelRate,DownloadedDate
	INTO #SpecialPrice
	FROM SpecialRateAftDownLoad S (NOLOCK),
	#FilterRetailer R,
	Product P (NOLOCK), ProductBatch B (NOLOCK)
	WHERE S.RtrCtgValueCode = R.CtgCode AND
	S.PrdCCode = P.PrdCCode AND B.PrdBatCode = S.PrdBatCCode AND P.PrdId = B.PrdId
	AND EXISTS (SELECT 'C' FROM #NormalProduct N (NOLOCK) WHERE P.PrdId = N.NormalPrd)	

	SELECT S.* 
	INTO #LatesSpecialPrice
	FROM #SpecialPrice S,
	(
		SELECT RtrId,PrdId,PrdBatId,MAX(DownloadedDate) DownloadedDate 
		FROM #SpecialPrice
		GROUP BY RtrId,PrdId,PrdBatId
	) L
	WHERE L.RtrId = S.RtrId AND L.PrdId = S.PrdId AND L.PrdBatId = S.PrdBatId AND L.DownloadedDate = S.DownloadedDate

	UPDATE N SET N.NormalSpecialRate = L.SplSelRate
	FROM #NormalProduct N (NOLOCK),
	#LatesSpecialPrice L (NOLOCK)
	WHERE N.RtrId = L.RtrId AND N.NormalPrd = L.PrdId AND N.NormalBat = L.PrdBatId
	
	UPDATE M SET M.[SpecialSellRate] = N.NormalSpecialRate
	FROM #MTSalesDetails M,
	(
	SELECT TransType,SalId,PrdId,SlNo,SUM(NormalSpecialRate) NormalSpecialRate FROM #NormalProduct
	GROUP BY TransType,SalId,PrdId,SlNo
	) N WHERE M.TransType = N.TransType AND M.SalId = N.SalId AND M.PrdId = N.PrdId AND M.SlNo = N.SlNo		

	UPDATE R SET R.TotalLCTR =  R.TotalPCS * (R.[ActualSellRate]+(R.[ActualSellRate]*(T.TaxPerc/100))),
	R.SalesTOT = R.TotalPCS * (R.[SpecialSellRate]+(R.[SpecialSellRate]*(T.TaxPerc/100)))
	FROM #MTSalesDetails R (NOLOCK),
	#ParleOutputTaxPercentage T (NOLOCK)
	WHERE R.TransType = T.TransId AND R.SalId = T.Salid AND R.Slno = T.PrdSlno
	
	SELECT M.RtrId,TransDate,M.PrdId,SUM(CASE P.PrdType WHEN 3 THEN 0 ELSE TotalLCTR END) TotalLCTR,
	SUM(CASE P.PrdType WHEN 3 THEN 0 ELSE SalesTOT END) SalesTOT,
	SUM(CASE P.PrdType WHEN 3 THEN TotalLCTR ELSE 0 END) [TotalOffLCTR],
	SUM(CASE P.PrdType WHEN 3 THEN SalesTOT ELSE 0 END) [OffTOT]
	INTO #DebitNotePrduct
	FROM #MTSalesDetails M,
	Product P (NOLOCK) 
	WHERE M.PrdId = P.PrdId
	GROUP BY M.RtrId,TransDate,M.PrdId

	SELECT R.CtgMainId,R.CtgName,
	CAST(SUM(TotalLCTR) AS NUMERIC(18,2)) TotalLCTR,
	CAST(SUM(SalesTOT) AS NUMERIC(18,2)) SalesTOT,
	CAST(0 AS NUMERIC(18,2)) [ClaimDiff], CAST(0 AS NUMERIC(18,2)) [LiabSales],
	CAST(SUM(TotalOffLCTR) AS NUMERIC(18,2)) TotalOffLCTR,
	CAST(SUM(OffTOT) AS NUMERIC(18,2)) OffTOT,
	CAST(0 AS NUMERIC(18,2)) [TotalOff],CAST(0 AS NUMERIC(18,2)) [OffClaimDiff],
	CAST(0 AS NUMERIC(18,2)) [LiabOff],CAST(0 AS NUMERIC(18,2)) [TotalSales],
	CAST(0 AS NUMERIC(18,2)) [LiabWOTOT],CAST(0 AS NUMERIC(18,2)) [LiabTOT],CAST(0 AS NUMERIC(18,2)) [TotalLiab]
	INTO #DebitNote
	FROM #DebitNotePrduct D (NOLOCK),
	#FilterRetailer R (NOLOCK)
	WHERE D.RtrId = R.RtrId
	GROUP BY R.CtgName,R.CtgMainId	
	
	UPDATE D SET [ClaimDiff] = TotalLCTR - SalesTOT, [TotalOff] = [TotalOffLCTR] - [OffTOT]
	FROM #DebitNote D (NOLOCK)

	UPDATE D SET [LiabSales] = [ClaimDiff] / TotalLCTR
	FROM #DebitNote D (NOLOCK)
	WHERE TotalLCTR <> 0

	UPDATE D SET [OffClaimDiff] = [TotalOffLCTR] - [TotalOff]
	FROM #DebitNote D (NOLOCK)

	UPDATE D SET [LiabOff] = [OffTOT] - [TotalOff]
	FROM #DebitNote D (NOLOCK)	

	UPDATE D SET [TotalSales] = TotalLCTR + [TotalOffLCTR]
	FROM #DebitNote D (NOLOCK)
	
	UPDATE D SET [LiabWOTOT] = [LiabOff] / [TotalSales]
	FROM #DebitNote D (NOLOCK)	
	WHERE [TotalSales] <> 0

	UPDATE D SET [LiabTOT] = [TotalOffLCTR] / [TotalSales]
	FROM #DebitNote D (NOLOCK)
	WHERE [TotalSales] <> 0	
	
	UPDATE D SET [TotalLiab] = ([ClaimDiff] + [OffClaimDiff])/[TotalSales]
	FROM #DebitNote D (NOLOCK)
	WHERE [TotalSales] <> 0	

	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptMTDebitSummary_Excel')
	DROP TABLE RptMTDebitSummary_Excel
	
	SELECT *
	INTO RptMTDebitSummary_Excel
	FROM #DebitNote D (NOLOCK)

	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptMTDebitSummary_Excel
	
	SELECT * FROM RptMTDebitSummary_Excel	

	DELETE FROM RptExcelHeaders WHERE RptId = 288
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,1,'CtgMainId','CtgMainId',0,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,2,'CtgName','Chain Name',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,3,'TotLCTR','Total LCTR',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,4,'SalesTOT','Total Sec Sales As Per TOT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,5,'ClaimDiff','TOT Diff Claims',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,6,'LiabSales','% Liab on Non Offer Sale',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,7,'TotalOffLCTR','Total Offer LCTR',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,8,'OffTOT','Total Offer Sec Sales as Per TOT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,9,'TotalOff','Total Offer Sec Sale As Per Offer Rate To Chain',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,10,'OffClaimDiff','Offers Claims Diff (TOT+Offer)',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,11,'LiabOff','Offer Liability Value',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,12,'TotalSales','Total Sale(Offer + Non Offer)',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,13,'LiabWOTOT','% Liab of Offer Claims On Sale Without TOT',1,1)
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,14,'LiabTOT','% Liab of Offer Claims On Total Sale',1,1)		
	INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (288,15,'TotalLiab','Total % Liab',1,1)

	RETURN
END
GO
DELETE FROM RptGroup WHERE RptId = 289
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',289,'InstitutionsTargetReport','Institutions Target Setting Report',1)
GO
DELETE FROM RptHeader WHERE RptId = 289
INSERT INTO RptHeader([GrpCode],[RptCaption],[RptId],[RpCaption],[SPName],[TblName],[RptName],[UserIds]) 
VALUES ('InstitutionsTargetReport','Institutions Target Setting Report','289','Institutions Target Setting Report','Proc_RptInstitutionsTargetReport',
'RptInstitutionsTargetReport','RptInstitutionsTargetReport.rpt','')
GO
DELETE FROM RptSelectionHd WHERE SelcId = 316
INSERT INTO RptSelectionHd([SelcId],[SelcName],[TblName],[Condition]) VALUES (316,'Sel_TargetNo','InsTargetHD',NULL)
GO
DELETE FROM RptDetails WHERE RptId = 289
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (289,1,'InsTargetHD',-1,'','InsId,InsRefNo,InsRefNo','Program Code...*','',1,'',316,1,1,'Press F4/Double Click to select Program Code',0)
GO
DELETE FROM RptGridView WHERE RptId = 289
INSERT INTO RptGridView([RptId],[RptName],[CrystalView],[GridView],[ExcelView],[PDFView]) VALUES (289,'RptInstitutionsTargetReport.rpt',1,0,1,0)
GO
DELETE FROM RptFormula WHERE RptId = 289
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,1,'Hd_DistName','',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,2,'Disp_ProgramCode','Program Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,3,'ValTargetNo','',1,316)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,4,'Cap Page','Page',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,5,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,6,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,7,'CtgName','Retailer Group',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,8,'RtrCode','Retailer Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,9,'RtrName','Retailer Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,10,'AvgSal','Avg Sale',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,11,'Target','Target',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,12,'Achievement','Achievement',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,13,'BaseAch','% Base Ach.',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,14,'TargetAch','% Target Ach.',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,15,'ValBaseAch','Value On Base Ach.',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,16,'ValTargetAch','Value On Target Ach.',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,17,'ClmAmount','Claim Amount',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (289,18,'Liability','Liability',1,0)
GO
DELETE FROM RptExcelHeaders WHERE RptId = 289
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (289,1,'CtgName','Retailer Group',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (289,2,'RtrCode','Retailer Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (289,3,'RtrName','Retailer Name',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (289,4,'AvgSal','Avg Sale',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (289,5,'Target','Target',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (289,6,'Achievement','Achievement',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (289,7,'BaseAch','% Base Achievement',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (289,8,'TargetAch','% Target Achievement',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (289,9,'ValBaseAch','Value On Base Achievement',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (289,10,'ValTargetAch','Value On Target Achievement',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (289,11,'ClmAmount','Claim Amount',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (289,12,'Liability','Liability',1,1)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_RptInstitutionsTargetReport')
DROP PROCEDURE Proc_RptInstitutionsTargetReport
GO
--EXEC Proc_RptInstitutionsTargetReport 289,2,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptInstitutionsTargetReport
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptInstitutionsTargetReport
* PURPOSE	: 
* CREATED	: Aravindh Deva C
* CREATED DATE	: 27 05 2016
* NOTE		: Parle SP for Trade Promotion Reports
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/  
BEGIN
	SET NOCOUNT ON
		
	DECLARE @TargetNo	AS INT	

	SET @TargetNo = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,316,@Pi_UsrId))

	EXEC Proc_LoadingInstitutionsTarget @TargetNo,@Pi_UsrId
	
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptInstitutionsTargetReport_Excel')
	DROP TABLE RptInstitutionsTargetReport_Excel
	
	SELECT CtgName,RtrCode,RtrName,AvgSal,[Target],Achievement,BaseAch,TargetAch,
	ValBaseAch,ValTargetAch,ClmAmount,Liability 
	INTO RptInstitutionsTargetReport_Excel
	FROM InsTargetDetailsTrans (NOLOCK) 
	WHERE UserId = @Pi_UsrId

	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptInstitutionsTargetReport_Excel
	
	SELECT * FROM RptInstitutionsTargetReport_Excel
	
	RETURN
END
GO
DELETE FROM RptGroup WHERE RptId = 290
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',290,'SchemeStockReconciliationReport','Scheme Stock Reconciliation Report',1)
GO
DELETE FROM RptHeader WHERE RptId = 290
INSERT INTO RptHeader([GrpCode],[RptCaption],[RptId],[RpCaption],[SPName],[TblName],[RptName],[UserIds]) 
VALUES ('SchemeStockReconciliationReport','Scheme Stock Reconciliation Report','290','Scheme Stock Reconciliation Report','Proc_RptSchemeStockReconciliationReport',
'RptSchemeStockReconciliationReport','RptSchemeStockReconciliationReport.rpt','')
GO
DELETE FROM RptDetails WHERE RptId = 290
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange])
VALUES (290,1,'FromDate',-1,'','','From Date*','',1,'',10,0,1,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange])
VALUES (290,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange])
VALUES (290,3,'SchemeMaster',-1,'','SchId,SchCode,SchDsc','Scheme Master...','',1,'',8,0,0,'Press F4/Double Click to select Scheme',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (290,4,'Company',-1,'','CmpId,CmpCode,CmpName','Company...','',1,'',4,1,0,'Press F4/Double Click to select Company',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (290,5,'ProductCategoryLevel',4,'CmpId','CmpPrdCtgId,CmpPrdCtgName,LevelName','Product Hierarchy Level...','Company',1,'CmpId',16,1,0,'Press F4/Double Click to select Product Hierarchy Level',1)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) 
VALUES (290,6,'ProductCategoryValue',5,'CmpPrdCtgId','PrdCtgValMainId,PrdCtgValCode,PrdCtgValName','Product Hierarchy Level Value...','ProductCategoryLevel',1,'CmpPrdCtgId',21,0,0,'Press F4/Double Click to select Product Hierarchy Level Value',1)
GO
DELETE FROM RptGridView WHERE RptId = 290
INSERT INTO RptGridView([RptId],[RptName],[CrystalView],[GridView],[ExcelView],[PDFView]) VALUES (290,'RptSchemeStockReconciliationReport.rpt',1,0,1,0)
GO
DELETE FROM RptFormula WHERE RptId = 290
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,1,'Hd_DistName','',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,2,'PrdName','Name of the SKU & Slot',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,3,'Pkts','No. of Pkts/CB',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,4,'OpenStock','Opening Stock',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,5,'BillNo','Invoice No',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,6,'BillDate','Dated',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,7,'BaseQty','Qty',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,8,'CloseStock','Closing Stock',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,9,'ProductCategoryLevel','Product Hierarchy Level',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,10,'ProductCategoryValue','Product Hierarchy Level Value',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,11,'Disp_ProductCategoryLevel','ProductCategoryLevel',1,16)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,12,'Disp_ProductCategoryValue','ProductCategoryLevelValue',1,21)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,13,'Cap Page','Page',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,14,'Cap User Name','User Name',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,15,'Cap Print Date','Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,16,'SchCode','Scheme Code',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,17,'DispSchCode','SchemeMaster',1,8)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,18,'Cap_Company','Company',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,19,'Disp_Company','Company',1,4)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,20,'Fil_FromDate','From Date',1,10)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,21,'Fil_ToDate','To Date',1,11)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,22,'Disp_FromDate','From Date',1,0)
INSERT INTO RptFormula([RptId],[SlNo],[Formula],[FormulaValue],[LcId],[SelcId]) VALUES (290,23,'Disp_ToDate','To Date',1,0)
GO
DELETE FROM RptExcelHeaders WHERE RptId = 290
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (290,1,'SchId','SchId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (290,2,'SchCode','Scheme Code',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (290,3,'PrdId','PrdId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (290,4,'PrdName','Name of the SKU & Slot',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (290,5,'CB','No. of Pkts/CB',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (290,6,'OpenStock','Opening Stock',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (290,7,'SalId','SalId',0,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (290,8,'SalInvNo','Invoice No',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (290,9,'SalInvDate','Dated',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (290,10,'BaseQty','Qty',1,1)
INSERT INTO RptExcelHeaders([RptId],[SlNo],[FieldName],[DisplayName],[DisplayFlag],[LngId]) VALUES (290,11,'CloseStock','Closing Stock',1,1)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_RptSchemeStockReconciliationReport')
DROP PROCEDURE Proc_RptSchemeStockReconciliationReport
GO
/*
begin tran
EXEC Proc_RptSchemeStockReconciliationReport 290,2,0,'Parle',0,0,1
rollback tran
*/
CREATE PROCEDURE Proc_RptSchemeStockReconciliationReport
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptSchemeStockReconciliationReport
* PURPOSE	: 
* CREATED	: Aravindh Deva C
* CREATED DATE	: 27 05 2016
* NOTE		: Parle SP for Trade Promotion Reports
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/  
BEGIN
	SET NOCOUNT ON
		
	DECLARE @FromDate			AS	DATETIME
	DECLARE @ToDate				AS	DATETIME
	DECLARE @CmpId				AS  INT 
	DECLARE @CtgLevelId			AS  INT  
	DECLARE @CtgMainId			AS  INT	
	DECLARE @CmpPrdCtgId		AS INT
	DECLARE @PrdCtgValMainId	AS INT	
	
	DECLARE @SchId	AS INT		
	
	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)

	SET @CmpId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId))  
	SET @CtgLevelId =(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,29,@Pi_UsrId))    
	SET @CtgMainId=(SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,30,@Pi_UsrId))

	SET @CmpPrdCtgId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId))
	SET @PrdCtgValMainId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,21,@Pi_UsrId))
	
	SET @SchId = (SELECT  TOP 1 iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,8,@Pi_UsrId))

	--To Filter Products
	SELECT DISTINCT E.PrdId
	INTO #FilterProduct
	FROM ProductCategoryValue C (NOLOCK)
	INNER JOIN ProductCategoryValue D (NOLOCK) ON
	D.PrdCtgValLinkCode LIKE Cast(C.PrdCtgValLinkCode AS NVARCHAR(1000)) + '%'
	INNER JOIN Product E (NOLOCK) ON D.PrdCtgValMainId = E.PrdCtgValMainId
	INNER JOIN ProductCategoryLevel L (NOLOCK) ON L.CmpPrdCtgId = C.CmpPrdCtgId
	
	WHERE (L.CmpId=(CASE @CmpId WHEN 0 THEN L.CmpId ELSE 0 END) OR
	L.CmpId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,4,@Pi_UsrId)))
	 
	AND (L.CmpPrdCtgId = (CASE @CmpPrdCtgId  WHEN 0 THEN L.CmpPrdCtgId ELSE 0 END) OR
	L.CmpPrdCtgId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId,16,@Pi_UsrId)))
	
	AND (C.PrdCtgValMainId = (CASE @PrdCtgValMainId  WHEN 0 THEN C.PrdCtgValMainId ELSE 0 END) OR 
	C.PrdCtgValMainId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId ,21, @Pi_UsrId)))
	--To Filter Products

	SELECT S.SalId,S.SalInvNo,S.SalInvDate,SP.PrdId,SUM(SP.BaseQty) BaseQty
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3
	AND EXISTS (SELECT 'C' FROM #FilterProduct FP (NOLOCK) WHERE SP.PrdId = FP.PrdId)
	GROUP BY S.SalId,S.SalInvNo,S.SalInvDate,SP.PrdId
	
	CREATE TABLE #ApplicableProduct
	(
		SchId		INT,
		PrdId 		INT
	)
	
	INSERT INTO #ApplicableProduct(SchId,PrdId)
	SELECT DISTINCT A.SchId,B.Prdid
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid
		INNER JOIN Product C On B.Prdid = C.PrdId
		WHERE A.SchemeLvlMode = 0 AND B.PrdId <> 0
	UNION ALL
	SELECT DISTINCT A.SchId,E.Prdid
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On
		F.PrdId = E.Prdid
		WHERE A.SchemeLvlMode = 0 AND B.PrdCtgValMainId <> 0
	UNION ALL
	SELECT DISTINCT S.SchId,B.MasterRecordId
		FROM SchemeProducts A 
		INNER JOIN UdcDetails B on B.UDCUniqueId =A.PrdCtgValMainId 
		INNER JOIN SchemeMaster S ON A.SchId = S.SchId
		WHERE S.SchemeLvlMode = 1

	CREATE TABLE #ApplicableScheme
	(
		SchId			INT,
		SchValidFrom	DATETIME,
		SchValidTill	DATETIME,	
		PrdId 		INT
	)
	
	INSERT INTO #ApplicableScheme (SchId,SchValidFrom,SchValidTill,PrdId)			
	SELECT DISTINCT A.SchId,S.SchValidFrom,S.SchValidTill,A.PrdId FROM #ApplicableProduct A (NOLOCK),
	SchemeMaster S (NOLOCK),#BillingDetails B (NOLOCK)
	WHERE A.SchId = S.SchId AND B.SalInvDate BETWEEN S.SchValidFrom AND S.SchValidTill
	AND (S.SchId = (CASE @SchId  WHEN 0 THEN S.SchId ELSE 0 END) OR 
	S.SchId in (SELECT iCountid FROM Fn_ReturnRptFilters(@Pi_RptId ,8, @Pi_UsrId)))	
	
	SELECT S.SchId,S.SchValidFrom,S.SchValidTill,
	B.PrdId,CAST(0 AS INT) CB,CAST(0 AS NUMERIC(18,0)) OpenStock,CAST(0 AS NUMERIC(18,0)) CloseStock,
	B.SalId,B.SalInvNo,B.SalInvDate,B.BaseQty
	INTO #SchemeStock
	FROM #ApplicableScheme S (NOLOCK),
	#BillingDetails B (NOLOCK) 
	WHERE S.PrdId = B.PrdId AND B.SalInvDate BETWEEN S.SchValidFrom AND S.SchValidTill
	
	UPDATE S SET S.CB = ConversionFactor
	FROM #SchemeStock S (NOLOCK),
	(
	SELECT P.PrdId,MAX(U.ConversionFactor) ConversionFactor
	FROM Product P (NOLOCK),UomGroup U (NOLOCK)
	WHERE P.UomGroupId = U.UomGroupId 
	GROUP BY P.PrdId
	) C WHERE C.PrdId = S.PrdId
	

	SELECT * INTO #StockLedger 
	FROM StockLedger S (NOLOCK)
	WHERE EXISTS (SELECT '' FROM #ApplicableScheme A (NOLOCK) WHERE S.PrdId = A.PrdId)
	AND S.LcnId = 1
	
	--OpenStock	
	SELECT SchId,SL.PrdId,SL.PrdBatId,MAX(SL.TransDate) TransDate
	INTO #Open
	FROM #SchemeStock S,
	#StockLedger SL (NOLOCK)
	WHERE S.PrdId = SL.PrdId AND SL.TransDate < S.SchValidFrom
	GROUP BY SchId,SL.PrdId,SL.PrdBatId
	
	SELECT SchId,PrdId,SUM(SalClsStock) OpenStock
	INTO #OpenStock
	FROM 
	(
	SELECT O.SchId,O.PrdId,O.PrdBatId,SalClsStock SalClsStock
	FROM #Open O,
	#StockLedger S (NOLOCK)
	WHERE O.PrdId = S.PrdId AND O.PrdBatId = S.PrdBatId AND O.TransDate = S.TransDate
	) O
	GROUP BY SchId,PrdId
	--OpenStock

	--CloseStock
	SELECT SchId,SL.PrdId,SL.PrdBatId,MAX(SL.TransDate) TransDate
	INTO #Close
	FROM #SchemeStock S,
	#StockLedger SL (NOLOCK)
	WHERE S.PrdId = SL.PrdId AND SL.TransDate <= S.SchValidTill
	GROUP BY SchId,SL.PrdId,SL.PrdBatId

	SELECT SchId,PrdId,SUM(SalClsStock) CloseStock
	INTO #CloseStock
	FROM 
	(
	SELECT O.SchId,O.PrdId,O.PrdBatId,SalClsStock
	FROM #Close O,
	#StockLedger S (NOLOCK)
	WHERE O.PrdId = S.PrdId AND O.PrdBatId = S.PrdBatId AND O.TransDate = S.TransDate
	) C
	GROUP BY SchId,PrdId
	--CloseStock

	UPDATE S SET S.OpenStock = O.OpenStock
	FROM #SchemeStock S (NOLOCK),
	#OpenStock O (NOLOCK)
	WHERE S.SchId = O.SchId AND S.PrdId = O.PrdId	
	
	UPDATE S SET S.CloseStock = C.CloseStock
	FROM #SchemeStock S (NOLOCK),
	#CloseStock C (NOLOCK)
	WHERE S.SchId = C.SchId AND S.PrdId = C.PrdId
	
	SELECT SM.SchId SchId,SM.SchCode,CAST(P.PrdId AS NUMERIC(18,2)) PrdId,P.PrdName,S.CB,S.OpenStock,
	S.SalId,S.SalInvNo,CONVERT(NVARCHAR(11),S.SalInvDate,105) SalInvDate,S.BaseQty,S.CloseStock
	INTO #SchemeStockReconciliation
	FROM #SchemeStock S,
	SchemeMaster SM (NOLOCK),
	Product P (NOLOCK)
	WHERE S.SchId = SM.SchId AND S.PrdId = P.PrdId
	
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptSchemeStockReconciliationReport_Excel')
	DROP TABLE RptSchemeStockReconciliationReport_Excel
	
	SELECT *
	INTO RptSchemeStockReconciliationReport_Excel
	FROM #SchemeStockReconciliation (NOLOCK) 


	DELETE FROM RptDataCount WHERE RptId = @Pi_RptId AND UserId = @Pi_UsrId
	INSERT INTO RptDataCount (RptId,RecCount,ErrNo,UserId)
	SELECT @Pi_RptId,Count(*) as RecCount,0,@Pi_UsrId FROM RptSchemeStockReconciliationReport_Excel
	
	IF EXISTS (SELECT 'C' FROM RptSchemeStockReconciliationReport_Excel (NOLOCK))
	BEGIN
		INSERT INTO RptSchemeStockReconciliationReport_Excel (SchId,SchCode,PrdId,PrdName,CB,OpenStock,SalId,SalInvNo,SalInvDate,
		BaseQty,CloseStock)
		
		SELECT SchId,'' SchCode,PrdId + 0.5 ,'Total' PrdName,MAX(CB) CB,MAX(OpenStock) OpenStock,
		MIN(SalId),'' SalInvNo,'' SalInvDate,SUM(BaseQty),MAX(CloseStock)
		FROM RptSchemeStockReconciliationReport_Excel
		GROUP BY SchId,PrdId
		
		UPDATE R SET R.OpenStock = NULL,R.PrdName = '',R.SchCode = ''
		FROM RptSchemeStockReconciliationReport_Excel R (NOLOCK)
		WHERE NOT EXISTS (SELECT 'C' FROM RptSchemeStockReconciliationReport_Excel T 
		WHERE T.PrdName = 'Total' AND R.SchId = T.SchId AND R.PrdId + 0.5 = T.PrdId AND R.SalId = T.SalId)
		AND R.PrdName <> 'Total'
		
		UPDATE R SET R.CloseStock = NULL
		FROM RptSchemeStockReconciliationReport_Excel R (NOLOCK)
		WHERE R.PrdName <> 'Total'
	END

	SELECT * FROM RptSchemeStockReconciliationReport_Excel ORDER BY SchId,PrdId,SalId
	
	RETURN
END
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptExcelDebitNote')
DROP TABLE RptExcelDebitNote
GO
CREATE TABLE RptExcelDebitNote
(
Row INT,
Col INT,
MergeCells NVARCHAR(100),
Value NVARCHAR (MAX)
)
GO
DELETE FROM RptGroup WHERE RptId = 291
INSERT INTO RptGroup([PId],[RptId],[GrpCode],[GrpName],[VISIBILITY]) VALUES ('ParleReports',291,'DebitNoteTopSheet','Debit Note Top Sheet',1)
GO
DELETE FROM RptHeader WHERE RptId = 291
INSERT INTO RptHeader([GrpCode],[RptCaption],[RptId],[RpCaption],[SPName],[TblName],[RptName],[UserIds]) VALUES ('DebitNoteTopSheet','Debit Note Top Sheet','291','Debit Note Top Sheet','Proc_RptDebitNoteTopSheet','RptDebitNoteTopSheet','RptDebitNoteTopSheet.rpt','')
GO
DELETE FROM RptDetails WHERE RptId = 291
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (291,1,'FromDate',-1,'','','From Date*','',1,'',10,0,1,'Enter From Date',0)
INSERT INTO RptDetails([RptId],[SlNo],[TblName],[PrntId],[PrntRefFld],[FldName],[FldCaption],[PrntTbl],[CtrlType],[CmnFld],[SelcId],[SingleMulti],[Mandatory],[PnlMsg],[CaptionChange]) VALUES (291,2,'ToDate',-1,'','','To Date*','',1,'',11,0,0,'Enter To Date',0)
GO
DELETE FROM RptGridView WHERE RptId = 291
INSERT INTO RptGridView([RptId],[RptName],[CrystalView],[GridView],[ExcelView],[PDFView]) VALUES (291,'RptDebitNoteTopSheet.rpt',1,0,1,0)
GO
IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_RptDebitNoteTopSheet')
DROP PROCEDURE Proc_RptDebitNoteTopSheet
GO
--EXEC Proc_RptDebitNoteTopSheet 291,2,0,'Parle',0,0,1
CREATE PROCEDURE Proc_RptDebitNoteTopSheet
(
	@Pi_RptId			INT,
	@Pi_UsrId			INT,
	@Pi_SnapId			INT,
	@Pi_DbName			NVARCHAR(50),
	@Pi_SnapRequired	INT,
	@Pi_GetFromSnap		INT,
	@Pi_CurrencyId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_RptDebitNoteTopSheet
* PURPOSE	: To Return the Scheme Utilization Details
* CREATED	: Aravindh Deva C
* CREATED DATE	: 27 05 2016
* NOTE		: Parle SP for Debit Note Top Sheet
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}      
*********************************/  
BEGIN
	SET NOCOUNT ON
	
	DECLARE @FromDate			AS	DATETIME
	DECLARE @ToDate				AS	DATETIME

	SELECT @FromDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,10,@Pi_UsrId)
	SELECT @ToDate = dSelected FROM Fn_ReturnRptFilterDate(@Pi_RptId,11,@Pi_UsrId)
	
	--Report 1
	DECLARE @CityName AS NVARCHAR(100)
	DECLARE @DistributorCode AS NVARCHAR(40)
	DECLARE @DistributorName AS NVARCHAR(100)
	
	SELECT @DistributorCode = DistributorCode, @DistributorName = DistributorName,
	@CityName = G.GeoName
	FROM Distributor D (NOLOCK),
	Geography G (NOLOCK) WHERE D.GeoMainId = G.GeoMainId
	--Report 1
		
	--Report 2
	DECLARE @MGSaleable AS INT 
	DECLARE @MGOffer AS INT

	DECLARE @SlNo AS INT
	
	DECLARE @SamplingAmount AS NUMERIC(18,2)

	SELECT @MGSaleable = StockTypeId FROM StockType WHERE UserStockType = 'MGSaleable'
	SELECT @MGOffer = StockTypeId FROM StockType WHERE UserStockType = 'MGOffer'

	SELECT @SlNo = SlNo FROM BatchCreation WHERE FieldDesc = 'Selling Price'

	SELECT DISTINCT J.PrdId,J.PrdBatId,B.TaxGroupId,CAST(0 AS NUMERIC(18,2)) TaxPercentage
	INTO #SamplingBatchTaxPercent
	FROM StockJournal J,
	StockJournalDt D (NOLOCK),
	ProductBatch B (NOLOCK)
	WHERE J.StkJournalRefNo = D.StkJournalRefNo
	AND J.PrdBatId = B.PrdBatId	AND J.PrdId = B.PrdId
	AND StockTypeId = @MGSaleable AND TransferStkTypeId = @MGOffer
	
	SELECT ROW_NUMBER() OVER (ORDER BY T.TaxGroupId) RowNo,
	MAX(T.PrdBatId) PrdBatId,T.TaxGroupId 
	INTO #BatchTaxPercent
	FROM #SamplingBatchTaxPercent T
	WHERE T.TaxGroupId <> 0
	GROUP BY T.TaxGroupId
	
	DECLARE @PrdId AS INT
	DECLARE @PrdBatId AS INT
	DECLARE @TaxGroupId AS INT
	DECLARE @TaxPercentage AS NUMERIC(18,2)

	DECLARE @RowNo AS INT
	DECLARE @TotalRow AS INT
	
	SET @RowNo = 1
	SELECT @TotalRow = COUNT(TaxGroupId) FROM #BatchTaxPercent D (NOLOCK)	
		
	TRUNCATE TABLE SamplingBatchTaxPercent

	WHILE (@RowNo < = @TotalRow)
	BEGIN	

		SELECT @PrdId = B.PrdId, @PrdBatId = S.PrdBatId, @TaxGroupId = B.TaxGroupId
		FROM #BatchTaxPercent S,
		#SamplingBatchTaxPercent B (NOLOCK)
		WHERE S.PrdBatId = B.PrdBatId AND S.TaxGroupId = B.TaxGroupId
		AND RowNo = @RowNo

		EXEC Proc_SamplingTaxCalCulation @PrdId,@PrdBatId
		
		SELECT @TaxPercentage = TaxPercentage FROM SamplingBatchTaxPercent S (NOLOCK)
		WHERE PrdBatId = @PrdBatId
		
		UPDATE B SET B.TaxPercentage = @TaxPercentage
		FROM #SamplingBatchTaxPercent B
		WHERE B.TaxGroupId = @TaxGroupId
		
		SET @RowNo = @RowNo + 1
		
	END	

	SELECT @SamplingAmount =  ISNULL(SUM( D.StkTransferQty * (P.PrdBatDetailValue + (P.PrdBatDetailValue * (T.TaxPercentage / 100)))),0)
	FROM StockJournal J,
	StockJournalDt D (NOLOCK),
	ProductBatchDetails P (NOLOCK),
	#SamplingBatchTaxPercent T (NOLOCK)
	WHERE J.StkJournalRefNo = D.StkJournalRefNo AND J.PriceId = P.PriceId
	AND P.PrdBatId = T.PrdBatId
	AND StockTypeId = @MGSaleable AND TransferStkTypeId = @MGOffer
	AND P.SLNo = @SlNo
	--Report 2
	
	--Report 3
	EXEC Proc_ReturnSalesProductTaxPercentage @FromDate,@ToDate
	
	SELECT * INTO #ParleOutputTaxPercentage
	FROM ParleOutputTaxPercentage (NOLOCK)	

	SELECT S.SalId,S.SalInvNo,S.SalInvDate,S.RtrId,SP.PrdId,SP.PrdBatId,SP.BaseQty BaseQty,
	B.DefaultPriceId ActualPriceId,SP.SlNo
	INTO #BillingDetails
	FROM SalesInvoice S (NOLOCK)
	INNER JOIN SalesInvoiceProduct SP (NOLOCK) ON S.SalId = SP.SalId
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId
	WHERE SalInvDate BETWEEN @FromDate AND @ToDate AND S.DlvSts > 3

	SELECT S.ReturnID,S.ReturnCode,S.ReturnDate,S.RtrId,SP.PrdId,SP.PrdBatId,-1 * SP.BaseQty BaseQty,SP.PrdUnitMRP MRP,
	B.DefaultPriceId,SP.SlNo,SP.PrdEditSelRte
	INTO #ReturnDetails
	FROM ReturnHeader S (NOLOCK)
	INNER JOIN ReturnProduct SP (NOLOCK) ON S.ReturnID = SP.ReturnID
	INNER JOIN ProductBatch B (NOLOCK) ON SP.PrdBatId = B.PrdBatId
	WHERE ReturnDate BETWEEN @FromDate AND @ToDate AND S.[Status] = 0	

	SELECT TransType,RtrId,SalId,TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo,CAST (0 AS NUMERIC(18,6)) AS ActualSellRate,
	CAST (0 AS NUMERIC(18,6)) AS LCTR
	INTO #DebitSalesDetails
	FROM 
	(
	SELECT 1 TransType,RtrId,SalId,SalInvDate TransDate,PrdId,PrdBatId,BaseQty,ActualPriceId,SlNo FROM #BillingDetails
	
	UNION ALL
	
	SELECT 2 TransType,RtrId,ReturnID,ReturnDate TransDate,PrdId,PrdBatId,BaseQty,DefaultPriceId,SlNo FROM #ReturnDetails
	
	) Consolidated
	
	
	UPDATE M SET M.ActualSellRate = D.PrdBatDetailValue
	FROM #DebitSalesDetails M (NOLOCK),
	ProductBatchDetails D (NOLOCK) 
	WHERE M.ActualPriceId = D.PriceId AND D.SLNo = @SlNo

	UPDATE R SET R.LCTR = R.BaseQty * (R.ActualSellRate+(R.ActualSellRate*(T.TaxPerc/100)))
	FROM #DebitSalesDetails R (NOLOCK),
	#ParleOutputTaxPercentage T (NOLOCK)
	WHERE R.SalId = T.Salid AND R.Slno = T.PrdSlno AND T.TransId = R.TransType

	CREATE TABLE #ApplicableProduct
	(
		SchId		INT,
		PrdId 		INT
	)
	
	INSERT INTO #ApplicableProduct(SchId,PrdId)
	SELECT DISTINCT A.SchId,B.Prdid
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid
		INNER JOIN Product C On B.Prdid = C.PrdId
		WHERE A.SchemeLvlMode = 0 AND B.PrdId <> 0
	UNION ALL
	SELECT DISTINCT A.SchId,E.Prdid
		FROM SchemeMaster A
		INNER JOIN SchemeProducts B ON A.Schid = B.Schid
		INNER JOIN ProductCategoryValue C ON 
		B.PrdCtgValMainId = C.PrdCtgValMainId 
		INNER JOIN ProductCategoryValue D ON
		D.PrdCtgValLinkCode LIKE Cast(c.PrdCtgValLinkCode as nvarchar(1000)) + '%'
		INNER JOIN Product E On
		D.PrdCtgValMainId = E.PrdCtgValMainId 
		INNER JOIN ProductBatch F On
		F.PrdId = E.Prdid
		WHERE A.SchemeLvlMode = 0 AND B.PrdCtgValMainId <> 0
	UNION ALL
	SELECT DISTINCT S.SchId,B.MasterRecordId
		FROM SchemeProducts A 
		INNER JOIN UdcDetails B on B.UDCUniqueId =A.PrdCtgValMainId 
		INNER JOIN SchemeMaster S ON A.SchId = S.SchId
		WHERE S.SchemeLvlMode = 1

	CREATE TABLE #ApplicableScheme
	(
		SchId			INT,
		SchDsc			NVARCHAR(100),
		SchValidFrom	DATETIME,
		SchValidTill	DATETIME,	
		Budget			NUMERIC(18,2),
		BudgetAllocationNo VARCHAR(100),
		PrdId 		INT
	)
	
	INSERT INTO #ApplicableScheme (SchId,SchDsc,SchValidFrom,SchValidTill,Budget,BudgetAllocationNo,PrdId)			
	SELECT DISTINCT A.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,S.Budget,S.BudgetAllocationNo, A.PrdId
	FROM #ApplicableProduct A (NOLOCK),
	SchemeMaster S (NOLOCK),#BillingDetails B (NOLOCK)
	WHERE A.SchId = S.SchId AND B.SalInvDate BETWEEN S.SchValidFrom AND S.SchValidTill
	AND S.Claimable = 1
	
	SELECT S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,S.Budget,S.BudgetAllocationNo,
	SUM(B.BaseQty) [SecSalesQty],CAST(SUM(B.LCTR) AS NUMERIC(18,2)) [SecSalesVal],CAST(0 AS NUMERIC(18,2)) Liab,
	CAST(0 AS NUMERIC(18,2)) Amount
	INTO #SchemeDebit
	FROM #ApplicableScheme S (NOLOCK),
	#DebitSalesDetails B (NOLOCK) 
	WHERE S.PrdId = B.PrdId AND B.TransDate BETWEEN S.SchValidFrom AND S.SchValidTill
	GROUP BY S.SchId,S.SchDsc,S.SchValidFrom,S.SchValidTill,Budget,BudgetAllocationNo
	ORDER BY S.SchId

	--SELECT S.SchId,SUM(B.BaseQty) [SecSalesQtyInScheme]
	--INTO #SchemeForLiab
	--FROM #ApplicableScheme S (NOLOCK),
	--#BillingDetails B (NOLOCK)
	--WHERE S.PrdId = B.PrdId AND B.SalInvDate BETWEEN S.SchValidFrom AND S.SchValidTill
	--AND EXISTS (SELECT 'C' FROM SalesInvoiceSchemeDtBilled SB (NOLOCK) WHERE B.SalId = SB.SalId AND S.SchId = SB.SchId)
	--GROUP BY S.SchId
	
	UPDATE SD SET SD.Amount = DBO.Fn_ReturnBudgetUtilized(SD.SchId)
	FROM #SchemeDebit SD (NOLOCK)

	UPDATE SD SET SD.Liab = CAST(( SD.Amount / SD.[SecSalesVal]) AS NUMERIC(18,2))
	FROM #SchemeDebit SD (NOLOCK)
	WHERE SD.[SecSalesVal] <> 0
	--Report 3
	
	--Report 4
	DECLARE @TargetNo	AS INT
	
	DECLARE @InsFromDate	AS	DATETIME	
	DECLARE @InsToDate		AS	DATETIME		

	SELECT TOP 1 @TargetNo = InsId,
	@InsFromDate = CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01',
	@InsToDate = DATEADD(DD,-1,DATEADD(MM,1,CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01'))	
	FROM InsTargetHD H (NOLOCK) WHERE H.[Status] = 1	
	AND CAST(TargetYear AS VARCHAR(5))+ '-' + CAST(TargetMonth AS VARCHAR(2)) + '-01' BETWEEN @FromDate AND @ToDate
	ORDER BY InsId DESC

	EXEC Proc_LoadingInstitutionsTarget @TargetNo,@Pi_UsrId
	
	SELECT CtgMainId,CtgName,@InsFromDate FromDate,@InsToDate ToDate,SUM([Target]) [Target],SUM(ClmAmount) DiscAmount,
	CAST(0 AS NUMERIC(18,6)) L2MSales,CAST(0 AS NUMERIC(18,6)) CurMSales,CAST(0 AS NUMERIC(18,0)) Outlet
	INTO #Institutions
	FROM InsTargetDetailsTrans (NOLOCK) 
	WHERE UserId = @Pi_UsrId AND SlNo <> 0
	GROUP BY CtgMainId,CtgName

	SELECT DISTINCT R.RtrId,RC.CtgMainId
	INTO #FilterRetailer
	FROM Retailer R (NOLOCK),
	RetailerValueClassMap RVCM (NOLOCK),
	RetailerValueClass RVC (NOLOCK),
	RetailerCategory RC (NOLOCK),
	RetailerCategoryLevel RCL (NOLOCK)
	WHERE R.Rtrid = RVCM.RtrId AND RVCM.RtrValueClassId = RVC.RtrClassId
	AND  RVC.CtgMainId=RC.CtgMainId AND  RCL.CtgLevelId=RC.CtgLevelId
	AND EXISTS (SELECT '' FROM #Institutions I (NOLOCK) WHERE I.CtgMainId = RC.CtgMainId)
	
	SELECT S.CtgMainId,CAST(SUM(S.Sales) AS NUMERIC(18,2)) Sales
	INTO #CurrentSales
	FROM 
	(
	SELECT R.CtgMainId,SUM(S.SalGrossAmount) Sales FROM SalesInvoice S (NOLOCK),
	#FilterRetailer R
	WHERE S.SalInvDate BETWEEN @InsFromDate AND @InsToDate AND S.DlvSts > 3
	AND S.RtrId = R.RtrId
	GROUP BY R.CtgMainId
	UNION ALL
	SELECT F.CtgMainId,-1 * SUM(R.RtnGrossAmt) FROM ReturnHeader R (NOLOCK),
	#FilterRetailer F
	WHERE R.ReturnDate BETWEEN @InsFromDate AND @InsToDate AND R.Status = 0
	AND F.RtrId = R.RtrId
	GROUP BY F.CtgMainId
	) AS S GROUP BY S.CtgMainId

	SELECT R.CtgMainId,COUNT(DISTINCT S.RtrId) Outlet
	INTO #NoOfOutlet
	FROM SalesInvoice S (NOLOCK),
	#FilterRetailer R
	WHERE S.SalInvDate BETWEEN @InsFromDate AND @InsToDate AND S.DlvSts > 3
	AND S.RtrId = R.RtrId
	GROUP BY R.CtgMainId	
	
	--Last Two Month Sales
	SELECT @InsToDate = DATEADD (D,-1,@InsFromDate) 
	SELECT @InsFromDate = DATEADD (MONTH,-2,@InsFromDate) 
	
	SELECT S.CtgMainId,CAST(SUM(S.Sales) AS NUMERIC(18,2)) Sales
	INTO #L2MSales
	FROM 
	(
	SELECT R.CtgMainId,SUM(S.SalGrossAmount) Sales FROM SalesInvoice S (NOLOCK),
	#FilterRetailer R
	WHERE S.SalInvDate BETWEEN @InsFromDate AND @InsToDate AND S.DlvSts > 3
	AND S.RtrId = R.RtrId
	GROUP BY R.CtgMainId
	UNION ALL
	SELECT F.CtgMainId,-1 * SUM(R.RtnGrossAmt) FROM ReturnHeader R (NOLOCK),
	#FilterRetailer F
	WHERE R.ReturnDate BETWEEN @InsFromDate AND @InsToDate AND R.Status = 0
	AND F.RtrId = R.RtrId
	GROUP BY F.CtgMainId
	) AS S GROUP BY S.CtgMainId
	
	UPDATE I SET I.CurMSales = C.Sales
	FROM #Institutions I (NOLOCK),
	#CurrentSales C (NOLOCK)
	WHERE I.CtgMainId = C.CtgMainId

	UPDATE I SET I.L2MSales = C.Sales / 2
	FROM #Institutions I (NOLOCK),
	#L2MSales C (NOLOCK)
	WHERE I.CtgMainId = C.CtgMainId

	UPDATE I SET I.Outlet = C.Outlet
	FROM #Institutions I (NOLOCK),
	#NoOfOutlet C (NOLOCK)
	WHERE I.CtgMainId = C.CtgMainId
	--Report 4
	
	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel1')
	DROP TABLE RptDebitNoteTopSheet_Excel1	
	
	SELECT S.SchDsc [Scheme Description],S.SchValidFrom [From],S.SchValidTill [To],S.BudgetAllocationNo [Circular No],
	'' [Date],S.Budget [Scheme Budget],[SecSalesQty] [Sec Sales Qty],[SecSalesVal] [Sec Sales Value],Liab [% Liability on Sec Sales],Amount [Claim Amount]
	INTO RptDebitNoteTopSheet_Excel1
	FROM #SchemeDebit S (NOLOCK)

	IF EXISTS (SELECT 'C' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'RptDebitNoteTopSheet_Excel2')
	DROP TABLE RptDebitNoteTopSheet_Excel2	

	SELECT CtgName [Name Of the Category],FromDate [From],ToDate [To],'' [Circular No],[Target] [Monthly Target],
	L2MSales [Last 2 Months Avg Sales],CurMSales [Current Month],Outlet [No of Incentive Outlets],DiscAmount [Total Discount Amount]
	INTO RptDebitNoteTopSheet_Excel2
	FROM #Institutions (NOLOCK)	
	
	DECLARE @RecCount AS BIGINT
	SELECT @RecCount = COUNT(7) FROM RptDebitNoteTopSheet_Excel1
	
	TRUNCATE TABLE RptExcelDebitNote
	
	INSERT INTO RptExcelDebitNote(Row,Col,MergeCells,Value)
	SELECT 1,1,'A1:J1','PARLE - DEBIT NOTE / CREDIT NOTE'
	UNION ALL
	SELECT 2,1,'A2:E2','Name of the Town : ' + ISNULL(@CityName,'')
	UNION ALL
	SELECT 2,6,'F2:J2','Passed by SO / SE :'
	UNION ALL
	SELECT 3,1,'A3:F3','Name of the Wholesaler : ' + ISNULL(@DistributorName,'')
	UNION ALL
	SELECT 3,7,'G3:H3','Debit Note No :'
	UNION ALL
	SELECT 3,9,'I3:J3','Verified by ASM :'
	UNION ALL
	SELECT 4,1,'A4:F4','Wholesaler Code : ' + ISNULL(@DistributorCode,'')
	UNION ALL
	SELECT 4,7,'G4:H4','Credit Note No :'
	UNION ALL
	SELECT 4,9,'I4:J4','Authorized by DSM :'
	UNION ALL
	SELECT 5,1,'A5:F5','Name of the Division :'
	UNION ALL
	SELECT 5,7,'G5:H5','Credit Note Date :'
	UNION ALL
	SELECT 5,9,'I5:J5','Value of Approved credit note :'
	UNION ALL
	SELECT 6,1,'A6:J6',''
	UNION ALL	
	SELECT 7,1,'A7:J7','1.SAMPLING'
	UNION ALL
	SELECT 8,1,'A8:E8','DSM Sanction Letter Date '
	UNION ALL
	SELECT 8,6,'F8:J8','Sampling Amount : ' + CAST(@SamplingAmount AS VARCHAR(30))
	UNION ALL
	SELECT 9,1,'A9:D9','Product Sampled during the period  '
	UNION ALL
	SELECT 9,5,'E9:G9','From : ' + CONVERT(VARCHAR(11),@FromDate,105)
	UNION ALL
	SELECT 9,8,'H9:J9','To : ' + CONVERT(VARCHAR(11),@ToDate,105)
	UNION ALL
	SELECT 10,1,'A10:J10',''	
	UNION ALL
	SELECT 11,1,'A11:J11','2.TRADE SCHEME'	
	UNION ALL
	SELECT 12,C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel1'
	UNION ALL
	SELECT 13,1,'A13','1R'	
	UNION ALL
	SELECT 13 + @RecCount + 1,1,'A' + CAST(13 + @RecCount + 1 AS VARCHAR(10)) + ':J' + CAST(13 + @RecCount + 1 AS VARCHAR(10)) ,'3.INSTITUTIONAL SALES'	
	UNION ALL
	SELECT 13 + @RecCount + 2,C.colid,'',C.name FROM SYSOBJECTS O ,SYSCOLUMNS C WHERE O.id = C.id AND O.name = 'RptDebitNoteTopSheet_Excel2'
	UNION ALL
	SELECT 13 + @RecCount + 3,1,'A' + CAST(13 + @RecCount + 3 AS VARCHAR(10)),'2R'
	UNION ALL
	SELECT 13 + @RecCount,1,'A' + CAST(13 + @RecCount AS VARCHAR(10)) + ':' + 'J' + CAST(13 + @RecCount AS VARCHAR(10)),''	
	UNION ALL
	SELECT 0,0,'A13:A' + CAST(13 + @RecCount AS VARCHAR(10)),'WrapText'	
	UNION ALL
	SELECT 0,10,'B13','ColumnWidth'		
	UNION ALL
	SELECT 0,10,'C13','ColumnWidth'	
	UNION ALL
	SELECT 1,1,'-4108','HorizontalAlignment'
	
	RETURN	

END
GO
IF EXISTS (SELECT '' FROM SYSOBJECTS WHERE XTYPE = 'FN' AND NAME = 'Fn_ValidatingRptDebitNoteDate')
DROP FUNCTION Fn_ValidatingRptDebitNoteDate
GO
--SELECT DBO.Fn_ValidatingRptDebitNoteDate('2016-04-01','2016-04-30') ValidMsg
CREATE FUNCTION Fn_ValidatingRptDebitNoteDate(@FromDate DATETIME,@ToDate DATETIME)
RETURNS NVARCHAR(4000)
AS
BEGIN
/*********************************
* FUNCTION: Fn_ValidatingRptDebitNoteDate
* PURPOSE:  Validating Rpt Debit Note Date
* NOTES:
* CREATED: Aravindh Deva C 10.06.2016
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/

	DECLARE @ValidMsg AS nVarchar(4000)
	SET @ValidMsg = ''
	
	RETURN (@ValidMsg)
END
GO
IF EXISTS (SELECT '' FROM SYSOBJECTS WHERE XTYPE = 'FN' AND NAME = 'Fn_ReturnRptFiltersValue')
DROP FUNCTION Fn_ReturnRptFiltersValue
GO
CREATE FUNCTION Fn_ReturnRptFiltersValue
(
	@iRptid INT,
	@iSelid INT,
	@iUsrId INT
)
RETURNS nVarChar(1000)
AS
/*********************************
* FUNCTION: Fn_ReturnRptFiltersValue
* PURPOSE: Returns the Filters Value For the Selected Report and Selection Id
* NOTES: 
* CREATED: Thrinath Kola	31-07-2007
* MODIFIED 
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* 
*********************************/
BEGIN
	DECLARE @iCnt 		AS	INT
	DECLARE @SCnt 		AS      NVARCHAR(1000)
	DECLARE	@ReturnValue	AS	nVarchar(1000)
	DECLARE @iRtr 		AS	INT
	SELECT @iCnt = Count(*) FROM ReportFilterDt WHERE Rptid= @iRptid AND
	SelId = @iSelid AND usrid = @iUsrId
	IF @iCnt > 1
	BEGIN
		IF @iSelid=3 AND ( @iRptid=1 OR @iRptid=2 OR @iRptid=3 OR @iRptid=4 OR @iRptid=9 OR @iRptid=17 OR @iRptid=18
		OR @iRptid=19 OR @iRptid=30 OR @iRptid=12 ) 
		BEGIN
			SELECT @iRtr=SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND
			SelId = 215 AND Usrid = @iUsrId
			IF @iRtr>0 
			BEGIN
				SELECT @iRtr=COUNT(*) FROM ReportFilterDt WHERE Rptid= @iRptid AND
				SelId = @iSelid AND Usrid = @iUsrId AND SelValue  IN
				(SELECT SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND
				SelId = 215 AND Usrid = @iUsrId
				)
				IF @iRtr>0  
				BEGIN
					SET @ReturnValue = 'ALL'
				END
				ELSE
				BEGIN
					SET @ReturnValue = 'Multiple'
				END 
			END
			ELSE
			BEGIN
				SET @ReturnValue = 'Multiple'
			END
		END
		--Praveenraj B For Parle Salesman Multiple Selection
		 Else if @iCnt>1 And @iSelid=1   
		 Begin  
		 Set @ReturnValue=''
		  Select  @ReturnValue=@ReturnValue+SMName+',' From Salesman Where SMId In (SELECT Top 4 SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND    
			SelId =1 AND Usrid = @iUsrId  )   
			SET @ReturnValue=LEFT(@ReturnValue,LEN(@ReturnValue)-1)
		 End
		 
   --Till Here
   -->Added By Mohana For Parle Multiple Route Selection
--		Else if @iCnt>1 And @iSelid IN (2,35) AND @iRptid IN (3,242)
-->Added By Aravindh Deva C For Parle Multiple Route Selection for the reports 17,18,19
		ELSE IF @iCnt>1 And @iSelid IN (2,35) AND @iRptid IN (3,242,17,18,19)		
		 BEGIN  
		 SET @ReturnValue=''
		  SELECT  @ReturnValue=@ReturnValue+RMname+',' From RouteMaster  Where rmid In (SELECT Top 5 SelValue FROM ReportFilterDt WHERE Rptid=@iRptid AND    
			SelId IN (2,35) AND Usrid = @iUsrId  )
			SET @ReturnValue=LEFT(@ReturnValue,LEN(@ReturnValue)-1)   
		 END
	-->Till Here   
		ELSE
		BEGIN
			SET @ReturnValue = 'Multiple'
		END 
	END
	ELSE
	BEGIN
		--->Added By Nanda on 25/03/2011-->(Same Selection Id is used for Collection Report-Show Based on with Suppress Zero Stock)
		IF @iSelid=44 AND (@iRptid<>4)
		BEGIN
			SELECT @ReturnValue = ISNULL(FilterDesc,'') FROM RptFilter WHERE FilterId IN 
			( 
				SELECT SelValue FROM ReportFilterDt WHERE RptId=@iRptid AND SelId=@iSelid AND usrid = @iUsrId
			)
			AND RptId=@iRptid AND SelcId=@iSelid		
		END
		ELSE IF @iSelid=289 OR @iSelid=290 -- Moorthi For Nivea Filter (Delivered,Undelivered,Cancelled Bills)
		BEGIN
			SELECT @ReturnValue = ISNULL(FilterDesc,'') FROM RptFilter WHERE FilterId IN 
			( 
				SELECT SelValue FROM ReportFilterDt WHERE RptId=@iRptid AND SelId=@iSelid AND usrid = @iUsrId
			)
			AND RptId=@iRptid AND SelcId=@iSelid		
		END
		ELSE IF @iRptid=277 AND @iSelid=314
		 BEGIN
			Set @ReturnValue=''
			SELECT  @ReturnValue=R.FilterDesc FROM ReportFilterDt RD
			INNER JOIN RptFilter R ON RD.RptId=R.RptId AND RD.SelId=R.SelcId AND RD.SelValue=R.FilterId
			WHERE RD.Rptid= @iRptid AND R.SelcId = @iSelid AND RD.UsrId = @iUsrId
		 END
		--->Till Here
		ELSE
		BEGIN
			If @iSelid <> 10 AND @iSelid <> 11  And @iSelid <>66 and @iSelid<>64 AND @iSelid <> 13 AND @iSelid <> 20 
			AND @iSelid <> 102 AND @iSelid <> 103 AND @iSelid <> 105  AND @iSelid <> 108 AND @iSelid <> 115 AND @iSelid <> 117 AND 
			@iSelid <> 119 AND @iSelid <> 126  AND @iSelid <> 139 AND @iSelid <> 140 AND @iSelid <> 152 AND @iSelid <> 157 AND @iSelid <> 158 AND @iSelid <> 161 
			AND @iSelid <> 163 AND @iSelid <> 165 AND @iSelid <> 171  AND @iSelid <> 173 AND @iSelid <> 174 AND @iSelid <> 180 AND @iSelid <> 181
			AND @iSelid <> 195 AND @iSelid <> 199 AND @iSelid <> 201 AND @iSelid <> 278 AND @iSelid <> 275 AND @iSelid <> 316
			BEGIN			
				SELECT @iCnt = SelValue From ReportFilterDt Where Rptid= @iRptid AND
				SelId = @iSelid AND usrid = @iUsrId			
				
				IF @iCnt = 0
				BEGIN
					IF @iSelid=53 and (@iRptid=43 Or @iRptid=44)
					BEGIN
						IF Not Exists(SELECT * FROM ReportFilterDt WHERE Rptid In(43,44) and Selid=54)
						BEGIN
							SELECT @iCnt = SelValue FROM ReportFilterDt WHERE Rptid= @iRptid AND
							SelId = 55 AND usrid = @iUsrId
							SELECT @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,@iUsrId)
						END
						ELSE
						BEGIN
							SELECT @iCnt = SelValue From ReportFilterDt Where Rptid= @iRptid AND
							SelId = 54 AND usrid = @iUsrId
							SELECT @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,@iUsrId)
						END
					END
					ELSE 
					BEGIN
						SET @ReturnValue = 'ALL'
					END
				END
				ELSE
				BEGIN
					If @iSelid=232 
					BEGIN
						Select @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,@iUsrId)
					END
					ELSE
					BEGIN
						Select @ReturnValue = dbo.Fn_ReturnFiltersValue(@iCnt,@iSelid,2)
					END					
			   END
			END
			ELSE
			BEGIN	
				If @iSelid=10 or @iSelid=11	or @iSelid=20 or @iSelid=13 or @iSelid=139 or @iSelid=140
				BEGIN
					SELECT @ReturnValue = Convert(nVarChar(10),FilterDate,121) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId
				End
				If  @iSelid=66 
				BEGIN
					SELECT @ReturnValue = Cast(SelValue as VarChar(20)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End
				If  @iSelid=64
					BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(20)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				If  @iSelid=115 
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				If  @iSelid=152 
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End			
				If  @iSelid=157 or @iSelid=158
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				If  @iSelid=161
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End
				If  @iSelid=199
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End	
				--Aravindh
				If  @iSelid=316
				BEGIN
					SELECT @ReturnValue = Cast(SelDate as VarChar(25)) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId	
				End					
				--Aravindh
				IF @iSelid=102 OR @iSelid=103 OR @iSelid=105 OR  @iSelid=108 OR @iSelid = 117 OR @iSelid = 119 OR @iSelid = 126 OR @iSelid = 159 OR @iSelid = 163  OR @iSelid = 165 OR @iSelid = 180 OR @iSelid = 181
				OR @iSelid = 173 OR @iSelid = 174 OR @iSelid=195 OR @iSelid=201 OR @iSelid = 171 OR @iSelid = 278 OR @iSelid = 275
				BEGIN
					SELECT @SCnt = NULLIF(ISNULL(SelDate,'0'),SelDate) From ReportFilterDt Where Rptid= @iRptid AND
					SelId = @iSelid AND usrid = @iUsrId
					IF @SCnt='0' 
					BEGIN
						Set @ReturnValue = 'ALL'
					END 
					ELSE
					BEGIN
						SELECT @ReturnValue = Cast(SelDate as VarChar(20)) From ReportFilterDt Where Rptid= @iRptid AND
						SelId = @iSelid AND usrid = @iUsrId	
					END
				END			
			END	
		END			
	END
	RETURN(@ReturnValue)
END
GO
--Script Updater Begin
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_Cn2Cs_ProductBatch' AND XTYPE='P')
DROP PROCEDURE Proc_Cn2Cs_ProductBatch
GO
/* 
   BEGIN TRANSACTION
   delete FROM Errorlog 
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
		    --Modified by Rajesh
		    
     	--    SELECT DISTINCT RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,MAX(CreatedDate) AS CreatedDate INTO #SpecialRateCreatedDate
		    --FROM SpecialRateAftDownload WITH(NOLOCK) GROUP BY RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode ORDER BY PrdCCode
		    SELECT DISTINCT RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,MAX(CreatedDate) AS CreatedDate  INTO #SpecialRateCreatedDate1  
			FROM SpecialRateAftDownload_calc WITH(NOLOCK) GROUP BY RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode ORDER BY PrdCCode

			SELECT DISTINCT A.RtrCtgCode,A.RtrCtgValueCode,A.RtrCode,A.PrdCCode,A.CreatedDate ,A.ApplyOn,A.TYPE INTO #SpecialRateCreatedDate
			FROM SpecialRateAftDownload_calc A WITH(NOLOCK) INNER JOIN  #SpecialRateCreatedDate1 B (NOLOCK) 
			ON A.RtrCtgCode = B.RtrCtgCode AND A.RtrCtgValueCode  = B.RtrCtgValueCode AND A.RtrCode= B.RtrCode AND A.PrdCCode= B.PrdCCode
			AND A.CreatedDate = B.CreatedDate AND A.ApplyOn is not null
			
			--SELECT DISTINCT C.PrdId,E.PrdBatId,TransNo AS PriceId,A.RtrCtgCode,A.RtrCtgValueCode,A.RtrCode,A.PrdCCode,
			--D.PrdBatCode,DiscountPerc,(MRP-(MRP*(DiscountPerc/100))) AS SplRate INTO #SpecialRateDetails 
			--FROM SpecialRateAftDownload A WITH(NOLOCK)
			--INNER JOIN #SpecialRateCreatedDate B ON A.RtrCtgCode = B.RtrCtgCode AND A.RtrCtgValueCode = B.RtrCtgValueCode 
			--AND A.RtrCode = B.RtrCode AND A.PrdCCode = B.PrdCCode AND A.CreatedDate = B.CreatedDate
			--INNER JOIN Product C WITH(NOLOCK) ON A.PrdCCode = C.PrdCCode			
			--INNER JOIN ProductBatch D WITH(NOLOCK) ON C.PrdId = D.PrdId
			--INNER JOIN @ProductBatchPriceWithCounter E ON C.PrdId = E.PrdId AND D.PrdBatId = E.PrdBatId
			--ORDER BY A.PrdCCode
			SELECT DISTINCT C.PrdId,E.PrdBatId,TransNo AS PriceId,A.RtrCtgCode,A.RtrCtgValueCode,A.RtrCode,A.PrdCCode,  
		   D.PrdBatCode,DiscountPerc,B.ApplyOn,B.Type,
		   (CASE B.ApplyOn WHEN 1 THEN 
			(CASE B.[Type] WHEN 1 THEN (MRP*100/(100+DiscountPerc)) WHEN 2 THEN MRP-(MRP*(DiscountPerc/100))
				ELSE SellingRate-(SellingRate*(DiscountPerc/100))  END)	 
			ELSE SellingRate-(SellingRate*(DiscountPerc/100)) END) AS SplRate
		   INTO #SpecialRateDetails   
		   FROM SpecialRateAftDownload_calc A WITH(NOLOCK)  
		   INNER JOIN #SpecialRateCreatedDate B ON A.RtrCtgCode = B.RtrCtgCode AND A.RtrCtgValueCode = B.RtrCtgValueCode   
		   AND A.RtrCode = B.RtrCode AND A.PrdCCode = B.PrdCCode AND A.CreatedDate = B.CreatedDate  
		   INNER JOIN Product C WITH(NOLOCK) ON A.PrdCCode = C.PrdCCode     
		   INNER JOIN ProductBatch D WITH(NOLOCK) ON C.PrdId = D.PrdId  
		   INNER JOIN @ProductBatchPriceWithCounter E ON C.PrdId = E.PrdId AND D.PrdBatId = E.PrdBatId  
		   ORDER BY A.PrdCCode 
			--Till Here			
	
			SELECT DISTINCT MAX(E.ContractId) AS ContractId,A.PrdId,A.PrdBatId,A.PriceId,B.CtgLevelId,C.CtgMainId,SplRate,RtrCtgValueCode,A.ApplyOn, A.Type
			INTO #SpecialContractDetails FROM #SpecialRateDetails A WITH(NOLOCK) 
			INNER JOIN RetailerCategoryLevel B WITH(NOLOCK) ON A.RtrCtgCode = B.CtgLevelName 
			INNER JOIN RetailerCategory C WITH(NOLOCK) ON A.RtrCtgValueCode = C.CtgCode AND B.CtgLevelId = C.CtgLevelId
			INNER JOIN ContractPricingMaster D WITH(NOLOCK) ON B.CtgLevelId = D.CtgLevelId AND C.CtgMainId = D.CtgMainId 
			INNER JOIN ContractPricingDetails E WITH(NOLOCK) ON D.ContractId = E.ContractId AND A.PrdId = E.PrdId 
			GROUP BY A.PrdId,A.PrdBatId,A.PriceId,B.CtgLevelId,C.CtgMainId,SplRate,RtrCtgValueCode,A.ApplyOn, A.Type
			
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
			--Modified by Rajesh
						
			SELECT DISTINCT A.PrdId,A.PrdBatId,PriceId,RtrCtgValueCode,DENSE_RANK ()OVER (ORDER BY A.PriceId,A.PrdbatId,RtrCtgValueCode)+ @OldPriceIdExt AS NewPriceId,
			--CAST(SplRate*100/(100+TaxPercentage) AS NUMERIC(38,6)) AS NewSelRate 
			CASE A.ApplyOn WHEN 1 THEN 
										(CASE [Type] WHEN 1 THEN (SplRate*100)/(100+TaxPercentage)
											WHEN 2 THEN (SplRate*100)/(100+TaxPercentage)	END)
			ELSE CAST(SplRate AS NUMERIC(38,6)) END AS NewSelRate
			INTO #SplProductBatchDetails
			FROM #SpecialContractDetails A WITH(NOLOCK) INNER JOIN ProductBatchTaxPercent B WITH(NOLOCK) ON A.PrdId = B.PrdId
			AND A.PrdBatId = B.PrdBatId ORDER BY A.PrdId,A.PrdBatId,PriceId,RtrCtgValueCode
			
		
			--Product Batch Details Value Added			
			INSERT INTO ProductBatchDetails (PriceId,PrdBatId,PriceCode,BatchSeqId,SLNo,PrdBatDetailValue,DefaultPrice,PriceStatus,
            Availability,LastModBy,LastModDate,AuthId,AuthDate,XMLUpload) 
                       
            SELECT DISTINCT NewPriceId,A.PrdBatId,PriceCode+'SplRate'+CONVERT(NVARCHAR(200),B.NewSelRate)+CONVERT(NVARCHAR(10),GETDATE(),121),
            A.BatchSeqId,A.SLNo,(CASE SelRte WHEN 1 THEN B.NewSelRate ELSE PrdBatDetailValue END),0,1,1,1,CONVERT(NVARCHAR(10),GETDATE(),121),1,
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
            --Added By Rajesh
            INSERT INTO SpecialRateAftDownload_calc (RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode,SplSelRate,FromDate,CreatedDate,DownloadedDate,
            ContractPriceIds,DiscountPerc,SplrateId,ApplyOn,TYPE)
            SELECT DISTINCT RtrCtgCode,A.RtrCtgValueCode,A.RtrCode,A.PrdCCode,A.PrdBatCode,A.SplRate,CONVERT(NVARCHAR(10),GETDATE(),121),GETDATE(),GETDATE(),
            '-'+CONVERT(NVARCHAR(50),NewPriceId)+'-',DiscountPerc,0,A.ApplyOn,A.TYPE
            FROM #SpecialRateDetails A INNER JOIN #SplProductBatchDetails B ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId 
            and A.RtrCtgValueCode=B.RtrCtgValueCode
            ORDER BY PrdCCode,PrdBatCode
            
            --Till Here
            			
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
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE name='Proc_Cn2Cs_SpecialDiscount' AND XTYPE='P')
Drop Procedure Proc_Cn2Cs_SpecialDiscount
GO
/*

BEGIN TRAN
EXEC Proc_Cn2Cs_SpecialDiscount 0
select * from SpecialRateAftDownload_calc
ROLLBACK TRAN
*/

CREATE PROCEDURE Proc_Cn2Cs_SpecialDiscount
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
* 05-10-2015	Mahesh Babu D	Tax Not Attached for Product		ICRSTPAR1798
* 28-12-2015	Mahesh Babu D	Selling Rate Spl Rate Calc			ICRSTPAR1960 
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
		SELECT DISTINCT CtgCode INTO #RetailerCategory 
		FROM RetailerCategory RC 
		INNER JOIN RetailerValueClass RVC ON  RC.CtgMainId=RVC.CtgMainId
		INNER JOIN RetailerValueClassMap RCM ON RCM.RtrValueClassId=RVC.RtrClassId
	
		---Retailer Class Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT T.SlNo,CtgLevelName,T.CtgCode,RtrCode,PrdCCode,PrdBatCode,T.EffectiveFromDate
		FROM TempSpecialRateDiscountProduct T
		WHERE NOT EXISTS(SELECT CtgCode FROM #RetailerCategory R WHERE R.CtgCode=T.CtgCode)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer','Retailer Not Attached to Category:'+RtrHierLevel+' Not Available' FROM #SpecialRateToAvoid
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno and A.CtgCode=B.RtrHierValue and A.Prdccode=B.Prdccode--Modified by Raja.C
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
		
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno and A.CtgCode=B.RtrHierValue and A.Prdccode=B.Prdccode--Modified by Raja.C
		----
        --ProductTaxGroup Validation 		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 2,'Tax Group','TaxGroup Not Attached','Tax Group for :'+PrdCCode+' Not Available' FROM TempSpecialRateDiscountProduct
		WHERE PrdCCode  IN (SELECT PrdCCode FROM Product(NOLOCK) WHERE TaxGroupId=0)		
	
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN Product B(NOLOCK)  ON A.PrdCCode=B.PrdCCode and B.TaxGroupId=0 
		--Till here
		
		---Retailer Category Code Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT SlNo,CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate
		FROM TempSpecialRateDiscountProduct
		WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory)
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Retailer Category Level Value','Retailer Category Level Value:'+CtgCode+' Not Available' FROM TempSpecialRateDiscountProduct
		WHERE CtgCode NOT IN (SELECT CtgCode FROM RetailerCategory)		
	
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno and A.CtgCode=B.RtrHierValue and A.Prdccode=B.Prdccode--Modified by Raja.C 
		--Eeffective From Date Validation
		INSERT INTO #SpecialRateToAvoid(SlNo,RtrHierLevel,RtrHierValue,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate)
		SELECT DISTINCT SlNo,CtgLevelName,CtgCode,RtrCode,PrdCCode,PrdBatCode,EffectiveFromDate
		FROM TempSpecialRateDiscountProduct
		WHERE EffectiveFromDate>GETDATE()
		
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Special Rate','Effective From Date','Effective Date :'+CAST(EffectiveFromDate AS NVARCHAR(12))+' is greater ' 
		FROM TempSpecialRateDiscountProduct
		WHERE EffectiveFromDate>GETDATE()
		DELETE A FROM TempSpecialRateDiscountProduct A INNER JOIN #SpecialRateToAvoid B ON A.Slno=B.Slno and A.CtgCode=B.RtrHierValue  and A.Prdccode=B.Prdccode --Modified by Raja.C
			
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
		ELSE CAST(SplRate AS NUMERIC(38,6)) END AS NewSellRate			-- MODIFIED FOR ICRSTPAR1960 
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
		--Added by Rajesh
		INSERT INTO SpecialRateAftDownLoad_Calc(RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode,
		SplSelRate,FromDate,CreatedDate,DownloadedDate,ContractPriceIds,DiscountPerc,ApplyOn,TYPE)		
		SELECT DISTINCT RtrHierLevelCode,RtrHierLevelValueCode,RtrCode,PrdCCode,PrdBatCodeAll,
		NewSellRate,EffFromDate,CreatedDate,GETDATE(),'-'+CAST(NewPriceId AS NVARCHAR(10))+'-',Disperc 
		,ApplyOn,TYPE FROM #PriceMaster A
		WHERE NOT EXISTS(		
			SELECT RtrCtgCode,RtrCtgValueCode,RtrCode,PrdCCode,PrdBatCCode, FromDate 
			FROM 
			SpecialRateAftDownLoad_Calc B WHERE B.RtrCtgCode=A.RtrHierLevelCode
			and B.RtrCtgValueCode=A.RtrHierLevelValueCode and B.RtrCode= A.RtrCode
			And B.PrdCCode=A.PrdCCode and B.PrdBatCCode=A.PrdBatCodeAll
			and FromDate<=EffFromDate and B.SplSelRate=A.SplRate
						)
						
		UPDATE B  SET SplSelRate=NewSellRate,ContractPriceIds='-'+CAST(NewPriceId AS NVARCHAR(10))+'-',DiscountPerc=Disperc
		FROM #PriceMaster A INNER JOIN SpecialRateAftDownLoad_Calc B ON 
		B.RtrCtgCode=A.RtrHierLevelCode
		and B.RtrCtgValueCode=A.RtrHierLevelValueCode and B.RtrCode= A.RtrCode
		And B.PrdCCode=A.PrdCCode and B.PrdBatCCode=A.PrdBatCodeAll 
		AND B.DiscountPerc=A.DisPerc  
		WHERE  FromDate<=EffFromDate
		--Till here 
		
		UPDATE B  SET SplSelRate=NewSellRate,ContractPriceIds='-'+CAST(NewPriceId AS NVARCHAR(10))+'-',DiscountPerc=Disperc
		FROM #PriceMaster A INNER JOIN SpecialRateAftDownLoad B ON 
		B.RtrCtgCode=A.RtrHierLevelCode
		and B.RtrCtgValueCode=A.RtrHierLevelValueCode and B.RtrCode= A.RtrCode
		And B.PrdCCode=A.PrdCCode and B.PrdBatCCode=A.PrdBatCodeAll 
		AND B.DiscountPerc=A.DisPerc  -- Added FOR ICRSTPAR1960
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
IF EXISTS (SELECT 'P' FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'Proc_ApplySchemeInBill')
DROP PROCEDURE Proc_ApplySchemeInBill
GO
/*
BEGIN TRANSACTION
EXEC Proc_ApplySchemeInBill 115,12,0,2,2
SELECT * FROM BillAppliedSchemeHd
-- SELECT * FROM BilledPrdHdForScheme(NOLOCK)
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE Proc_ApplySchemeInBill
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
		/*Commented and Added by Raja.C for PMS No:ICRSTPAR2340 Begins Here*/
		--AND PT.PRDBATID=A.PRDBATID AND PT.Prdbatid= B.PrdBatid
		AND PT.PRDBATID=A.PRDBATID AND PT.Prdbatid= CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
		/*Commented and Added by Raja.C  for PMS No:ICRSTPAR2340 Ends Here*/
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
IF NOT EXISTS (SELECT 'X' FROM SYSOBJECTS WHERE XTYPE = 'U' AND NAME = 'Hotfixupdater_Bck')
CREATE TABLE Hotfixupdater_Bck
(
FixId INT,
FixType VARCHAR(20)
)
GO
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE Name = 'Proc_Cs2Cn_SyncDetails' AND XTYPE='P')
DROP PROCEDURE Proc_Cs2Cn_SyncDetails
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_SyncDetails 0,'2013-05-22'
SELECT * FROM Cs2Cn_Prk_SyncDetails
ROLLBACK TRANSACTION
*/
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_SyncDetails]
(
	@Po_ErrNo INT OUTPUT,
	@Sever_Date AS DATETIME
)
AS
/*********************************
* PROCEDURE		: Proc_Cs2Cn_SyncDetails
* PURPOSE		: To Extract Hot Fix Details
* CREATED		: Nandakumar R.G
* CREATED DATE	: 07/06/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @CmpId 		AS INTEGER
	DECLARE @DistCode	AS NVARCHAR(50)
	DECLARE @HostName   AS NVARCHAR(200)	
	SET @Po_ErrNo=0
	SELECT @DistCode = DistributorCode FROM Distributor
	SELECT TOP 1 HostName AS HostName INTO #HostName FROM Sys.sysprocesses WHERE Status='RUNNABLE' ORDER BY Login_time DESC
	SELECT @HostName = HostName FROM #HostName WITH (NOLOCK)
	
	TRUNCATE TABLE Cs2Cn_Prk_SyncDetails
	INSERT INTO Cs2Cn_Prk_SyncDetails(DistCode,FixId,FixDate,FixVersion,SyncDate,UploadFlag,SyncId,ServerDate,HostName,UpdatedHotfixId,SyncExeVersion)
	SELECT @DistCode,H.FixId,FixedOn AS FixDate,SynVersion AS FixVersion,GETDATE(),'N',
	(SELECT ISNULL(MAX(SyncId),0) AS SYNCID FROM sync_master (NOLOCK)),@Sever_Date,@HostName,U.Fixid,
	--(Select MAX(Fixid) From UpdaterLog (Nolock)),
	(Select VersionId From UtilityProcess (Nolock) Where ProcId = 3)
	FROM AppTitle A ,HotFixLog H,UPdaterLog U WHERE H.FixID IN (SELECT ISNULL(MAX(FixId),0) FROM HotFixLog)
	AND U.FixId NOT IN (SELECT FixId FROM Hotfixupdater_Bck (NOLOCK) WHERE FixType = 'UpdaterLog')
	
	IF NOT EXISTS(SELECT * FROM Cs2Cn_Prk_SyncDetails)
	BEGIN
		INSERT INTO Cs2Cn_Prk_SyncDetails(DistCode,FixId,FixDate,FixVersion,SyncDate,UploadFlag,SyncId,ServerDate,HostName,UpdatedHotfixId,SyncExeVersion)
		SELECT @DistCode,H.FixId,FixedOn AS FixDate,SynVersion AS FixVersion,GETDATE(),'N',
		(SELECT ISNULL(MAX(SyncId),0) AS SYNCID FROM sync_master (NOLOCK)),@Sever_Date,@HostName,U.Fixid,
		--(Select MAX(Fixid) From UpdaterLog (Nolock)),
		(Select VersionId From UtilityProcess (Nolock) Where ProcId = 3)
		FROM AppTitle A ,HotFixLog H,UPdaterLog U WHERE H.FixID IN (SELECT ISNULL(MAX(FixId),0) FROM HotFixLog)
		and u.Fixid = (Select Max(fixid) from Updaterlog where Releaseon = (select MAX(ReleaseOn) from UPdaterLog))
	END
	
	INSERT INTO Hotfixupdater_Bck(Fixid,FixType)
	SELECT DISTINCT UpdatedHotfixId,'UpdaterLog' FROM Cs2Cn_Prk_SyncDetails	
	
END
GO
--Script Updater End
UPDATE UtilityProcess SET VersionId = '3.1.0.6' WHERE ProcId = 1 AND ProcessName = 'Core Stocky.Exe'
GO
DELETE FROM AppTitle
INSERT INTO AppTitle (TitleName,SynVersion)
SELECT 'Core Stocky 3.1.0.6',429
GO
IF NOT EXISTS (SELECT * FROM Hotfixlog WHERE FixId = 429)
INSERT INTO Hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) 
VALUES(429,'D','2016-06-29',GETDATE(),1,'Core Stocky Service Pack 429')