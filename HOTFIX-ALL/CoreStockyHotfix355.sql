--[Stocky HotFix Version]=355
Delete from Versioncontrol where Hotfixid='355'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('355','2.0.0.5','D','2010-12-31','2010-12-31','2010-12-31',convert(varchar(11),getdate()),'Parle;Major:Settlement Type in Scheme,Sales Return-Scheme;Minor:Changes and Bug Fixing')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 355' ,'355'
GO

--SRF-Nanda-187-001

if not exists (Select Id,name from Syscolumns where name = 'SettlementType' and id in (Select id from 
	Sysobjects where name ='SchemeMaster'))
begin
	ALTER TABLE [dbo].[SchemeMaster]
	ADD [SettlementType] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-187-002

if not exists (Select Id,name from Syscolumns where name = 'SettlementType' and id in (Select id from 
	Sysobjects where name ='ClaimSheetHd'))
begin
	ALTER TABLE [dbo].[ClaimSheetHd]
	ADD [SettlementType] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-187-003

if not exists (Select Id,name from Syscolumns where name = 'SettlementType' and id in (Select id from 
	Sysobjects where name ='Etl_Prk_SchemeHD_Slabs_Rules'))
begin
	ALTER TABLE [dbo].[Etl_Prk_SchemeHD_Slabs_Rules]
	ADD [SettlementType] NVARCHAR(10) NULL DEFAULT 'ALL' WITH VALUES
END
GO

--SRF-Nanda-187-004

IF NOT EXISTS(SELECT * FROM CustomCaptions WHERE TransId=45 AND CtrlId=117 AND CtrlName='lblSettlementType')
BEGIN 
	INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,
	AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
	VALUES(45,117,1,'lblSettlementType','Settlement Type(+)','','',1,1,1,GETDATE(),1,GETDATE(),'Settlement Type(+)','','',1,1)

	INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,
	AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
	VALUES(45,118,1,'fxtSettlementType','Settlement Type','Press SpacebBar/Double Click to Select Settlement Type','',1,1,1,GETDATE(),1,GETDATE(),'Settlement Type','Press SpacebBar/Double Click to Select Settlement Type','',1,1)

	DELETE FROM ScreenDefaultValues WHERE TransId=45 AND CtrlId=118 

	INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc)
	VALUES(45,118,0,'ALL',1,1,1,1,GETDATE(),1,GETDATE(),'ALL')

	INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc)
	VALUES(45,118,1,'Value',2,1,1,1,GETDATE(),1,GETDATE(),'Value')

	INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc)
	VALUES(45,118,2,'Product',3,1,1,1,GETDATE(),1,GETDATE(),'Product')
END
GO

--SRF-Nanda-187-005

IF NOT EXISTS(SELECT * FROM CustomCaptions WHERE TransId=16 AND CtrlId=15 AND CtrlName='lblSettlementType')
BEGIN 
	INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,
	AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
	VALUES(16,15,1,'lblSettlementType','Settlement Type(+)','','',1,1,1,GETDATE(),1,GETDATE(),'Settlement Type(+)','','',1,1)

	INSERT INTO CustomCaptions(TransId,CtrlId,SubCtrlId,CtrlName,Caption,PnlMsg,MsgBox,LngId,Availability,LastModBy,LastModDate,
	AuthId,AuthDate,DefaultCaption,DefaultPnlMsg,DefaultMsgBox,Visibility,Enabled)
	VALUES(16,16,1,'fxtSettlementType','Settlement Type','Press SpacebBar/Double Click to Select Settlement Type','',1,1,1,GETDATE(),1,GETDATE(),'Settlement Type','Press SpacebBar/Double Click to Select Settlement Type','',1,1)

	DELETE FROM ScreenDefaultValues WHERE TransId=16 AND CtrlId=16 

	INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc)
	VALUES(16,16,0,'ALL',1,1,1,1,GETDATE(),1,GETDATE(),'ALL')

	INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc)
	VALUES(16,16,1,'Value',2,1,1,1,GETDATE(),1,GETDATE(),'Value')

	INSERT INTO ScreenDefaultValues(TransId,CtrlId,CtrlValue,CtrlDesc,SeqId,LngId,Availability,LastModBy,LastModDate,AuthId,AuthDate,DefaultCtrlDesc)
	VALUES(16,16,2,'Product',3,1,1,1,GETDATE(),1,GETDATE(),'Product')
END
GO

--SRF-Nanda-187-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ImportSchemeHD_Slabs_Rules]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ImportSchemeHD_Slabs_Rules]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE Procedure [dbo].[Proc_ImportSchemeHD_Slabs_Rules] 
(
	@Pi_Records TEXT
)
AS
/***************************************************************************************************
* PROCEDURE		: Proc_ImportSchemeHD_Slabs_Rules
* PURPOSE		: To Insert records from xml file in the Table Etl_Prk_SchemeHD_Slabs_Rules
* CREATED		: Aarthi.R
* CREATED DATE	: 21/01/2008
* MODIFIED
* DATE         AUTHOR       DESCRIPTION
****************************************************************************************************
* 25.08.2009   Panneer      Added the BudgetAllacationNo Column in Parking Table(Etl_Prk_SchemeHD_Slabs_Rules)
* 19.10.2009   Thiru		Added the SchBasedOn column in Parking Table(Etl_Prk_SchemeHD_Slabs_Rules)	
* 22/04/2010   Nanda        Added the FBM Column 
* 28/12/2010   Nanda        Added the Settlement Type Column 
****************************************************************************************************/
SET NOCOUNT ON
BEGIN

	DECLARE @hDoc INTEGER
	DECLARE @Company NVARCHAR(100)
	DECLARE @ClmGroupCode NVARCHAR(100)
	SELECT @Company = CmpCode FROM Company WHERE DefaultCompany = 1
	SELECT @ClmGroupCode = ClmGrpCode FROM ClaimGroupMaster WHERE ClmGrpId = 17

	EXEC sp_xml_preparedocument @hDoc OUTPUT,@Pi_Records

	INSERT INTO Etl_Prk_SchemeHD_Slabs_Rules(CmpSchCode,SchDsc,CmpCode,Claimable,ClmAmton,ClmGroupCode,SchLevel,SchType,BatchLevel,FlexiSch,
	FlexiSchType,CombiSch,Range,ProRata,QPS,QPSReset,ApyQPSSch,SchValidFrom,SchValidTill,SchStatus,Budget,AdjWinDispOnlyOnce,PurofEvery,
	SetWindowDisp,EditScheme,SchemeLevelMode,SlabId,PurQty,FromQty,Uom,ToQty,ToUom,ForEveryQty,ForEveryUom,DiscPer,FlatAmt,FlxDisc,
	FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,Points,MaxDiscount,MinDiscount,MaxValue,MinValue,MaxPoints,MinPoints,SchConfig,SchRules,
	NoofBills,FromDate,ToDate,MarketVisit,ApplySchBasedOn,EnableRtrLvl,AllowSaving,AllowSelection,BudgetAllocationNo,SchBasedOn,
	FBM,DownloadFlag,SettlementType)
	SELECT  [CmpSchCode],[SchDsc],@Company AS [CmpCode],[Claimable],[ClmAmton],@ClmGroupCode AS [ClmGroupCode],[SchLevel],[SchType],
	'NO' AS [BatchLevel],[FlexiSch],[FlexiSchType],[CombiSch],[Range],[ProRata],[QPS],[QPSReset],[ApyQPSSch],[SchValidFrom],[SchValidTill],
	[SchStatus],[Budget],[AdjWinDispOnlyOnce],[PurofEvery],[SetWindowDisp],[EditScheme],[SchemeLevelMode],[SlabId],[PurQty],[FromQty],
	[Uom],[ToQty],[ToUom],[ForEveryQty],[ForEveryUom],[DiscPer],[FlatAmt],[FlxDisc],[FlxValueDisc],[FlxFreePrd],[FlxGiftPrd],[FlxPoints],
	[Points],[MaxDiscount],[MinDiscount],[MaxValue],[MinValue],[MaxPoints],[MinPoints],[SchConfig],[SchRules],[NoofBills],[FromDate],
	[ToDate],[MarketVisit],[ApplySchBasedOn],[EnableRtrLvl],[AllowSaving],[AllowSelection],[BudgetAllocationNo],[SchBasedOn],
	[FBM],[DownloadFlag],ISNULL([SettlementType],'ALL')
	FROM OPENXML (@hdoc,'/Root/Console2CS_Scheme_HD_Slabs_Rules ',1)
	WITH 
	(
		[CmpSchCode]			NVARCHAR(25),
		[SchDsc]				NVARCHAR(100),
		[CmpCode]				NVARCHAR(100),
		[Claimable]				NVARCHAR(10),
		[ClmAmton]				NVARCHAR(25) ,
		[ClmGroupCode]			NVARCHAR(100),
		[SchLevel]				NVARCHAR(25),
		[SchType]				NVARCHAR(20),
		[BatchLevel]			NVARCHAR(100),
		[FlexiSch]				NVARCHAR(10),
		[FlexiSchType]			NVARCHAR(15),
		[CombiSch]				NVARCHAR(10),
		[Range]					NVARCHAR(10),
		[ProRata]				NVARCHAR(10),
		[QPS]					NVARCHAR(10),
		[QPSReset]				NVARCHAR(10),
		[ApyQPSSch]				NVARCHAR(10),
		[SchValidFrom]			NVARCHAR(10),
		[SchValidTill]			NVARCHAR(10),
		[SchStatus]				NVARCHAR(10),
		[Budget]				NVARCHAR(20),
		[AdjWinDispOnlyOnce]	NVARCHAR(10),
		[PurofEvery]			NVARCHAR(10),
		[SetWindowDisp]			NVARCHAR(10),
		[EditScheme]			NVARCHAR(10),
		[SchemeLevelMode]		NVARCHAR(10),
		[SlabId]				INT ,
		[PurQty]				NUMERIC(18, 2) ,
		[FromQty]				NUMERIC(18, 2) ,
		[Uom]					NVARCHAR(10) ,
		[ToQty]					NUMERIC(18, 2) ,
		[ToUom]					NVARCHAR(10) ,
		[ForEveryQty]			NUMERIC(18, 2) ,
		[ForEveryUom]			NVARCHAR(10) ,
		[DiscPer]				NUMERIC(18, 2) ,
		[FlatAmt]				NUMERIC(18, 2) ,
		[FlxDisc]				NVARCHAR(10) ,
		[FlxValueDisc]			NVARCHAR(10) ,
		[FlxFreePrd]			NVARCHAR(10) ,
		[FlxGiftPrd]			NVARCHAR(10) ,
		[FlxPoints]				NVARCHAR(10) ,
		[Points]				NUMERIC(18, 2) ,
		[MaxDiscount]			NUMERIC(18, 2) ,
		[MinDiscount]			NUMERIC(18, 2) ,
		[MaxValue]				NUMERIC(18, 2) ,
		[MinValue]				NUMERIC(18, 2) ,
		[MaxPoints]				NUMERIC(18, 2) ,
		[MinPoints]				NUMERIC(18, 2) ,
		[SchConfig]				NVARCHAR(10) ,
		[SchRules]				NVARCHAR(10) ,
		[NoofBills]				INT ,
		[FromDate]				NVARCHAR(10) ,
		[ToDate]				NVARCHAR(10) ,
		[MarketVisit]			INT ,
		[ApplySchBasedOn]		NVARCHAR(10) ,
		[EnableRtrLvl]			NVARCHAR(10) ,
		[AllowSaving]			NVARCHAR(10) ,
		[AllowSelection]		NVARCHAR(10),
		[DownloadFlag]			NVARCHAR(1),
		[BudgetAllocationNo]	NVARCHAR (100),
		[SchBasedOn]			NVARCHAR (50),
		[FBM]					NVARCHAR (10),		
		[SettlementType]		NVARCHAR (10)		
	) XMLObj

	EXEC sp_xml_removedocument @hDoc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-187-007

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_BLSchemeMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_BLSchemeMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_BLSchemeMaster 0
ROLLBACK TRANSACTION
*/

CREATE PROCEDURE [dbo].[Proc_Cn2Cs_BLSchemeMaster]
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

	DECLARE @FBM	AS NVARCHAR(10)
	DECLARE @FBMId	AS INT

	DECLARE @SettlementType		AS NVARCHAR(10)
	DECLARE @SettlementTypeId	AS INT

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
	ISNULL(SettlementType,'ALL') AS SettlementType
	FROM Etl_Prk_SchemeHD_Slabs_Rules
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchToAvoid) AND DownLoadFlag='D'			 
	ORDER BY [Company Scheme Code]
	OPEN Cur_SchMaster
	FETCH NEXT FROM Cur_SchMaster INTO @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
	, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
	, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch,
	@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM,@SettlementType	
	WHILE @@FETCH_STATUS=0
	BEGIN

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
			IF (UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' AND UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO')
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
			IF UPPER(LTRIM(RTRIM(@BatLvl)))<> 'YES' OR UPPER(LTRIM(RTRIM(@BatLvl)))<> 'NO'
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
			ELSE IF UPPER(LTRIM(RTRIM(@BatLvl)))= 'NO'
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
			IF @Taction=1
			BEGIN
				EXEC Proc_DependencyCheck 'SchemeMaster',@GetKey
				SELECT @ChkCount=COUNT(*) FROM TempDepCheck
				IF @ChkCount > 0
				BEGIN
					UPDATE SCHEMEMASTER SET SchValidTill=LTRIM(RTRIM(@SchEndDate)),
					Budget=@SchBudget,SchStatus=@StatusId WHERE SchId=@GetKey
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
					SchemeLvlMode=@SelMode,SchStatus=@StatusId WHERE SchId=@GetKey

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
								BudgetAllocationNo,AllowPrdSelc,ExcludeDM,SchBasedOn,Download,FBM,SettlementType)
								VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
								LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
								@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
								@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
								@ApplySchId,@SettleSchId,1,1,CONVERT(VARCHAR(10),GETDATE(),121),1,
								CONVERT(VARCHAR(10),GETDATE(),121),@EditSchId,@SelMode,1,2,0,@BudgetAllocationNo,0,0,@SchBasedOnId,1,@FBMId,@SettlementTypeId)
				
								UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchId'
								UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchCode'
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
					AllowPrdSelc,ExcludeDM,SchBasedOn,Download,FBM,SettlementType)
					VALUES (@GetKey,LTRIM(RTRIM(@GetKeyStr)),
					LTRIM(RTRIM(@SchDesc)),@CmpId,@ClmableId,@ClmAmtOnId,@ClmGrpId,LTRIM(RTRIM(@SchCode)),@CmpPrdCtgId,
					@SchTypeId,@BatId,@FlexiId,@FlexiConId,@CombiId,@RangeId,@ProRateId,@QPSId,
					@QPSResetId,LTRIM(RTRIM(@SchStartDate)),LTRIM(RTRIM(@SchEndDate)),@StatusId,@SchBudget,@AdjustSchId,@ForEveryId,
					@ApplySchId,@SettleSchId,1,1,convert(varchar(10),getdate(),121),1,
					convert(varchar(10),getdate(),121),@EditSchId,@SelMode,1,2,0,@BudgetAllocationNo,0,0,@SchBasedOnId,1,@FBMId,@SettlementTypeId)
	
					UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchId'
					UPDATE Counters SET CurrValue = CurrValue+1  WHERE TabName = 'SchemeMaster' AND FldName = 'SchCode'

					INSERT INTO SchemeRuleSettings(SchId,SchConfig,SchRules,NoofBills,FromDate,ToDate,MarketVisit,ApplySchBasedOn,
					EnableRtrLvl,AllowSaving,AllowSelection,Availability,LastModBy,LastModDate,AuthId,AuthDate,CalScheme,NoOfRtr,RtrCount)
					Select SchId,0,-1,-1,NULL,NULL,-1,-1,0,0,0,1,1,LastModDate,1,LastModDate,1,0,0 from schememaster (NOLOCK) where Claimable=1
					AND SchId Not In(Select SchId from SchemeRuleSettings (NOLOCK))
				END
			END
		END

		FETCH NEXT FROM Cur_SchMaster INTO  @SchCode, @SchDesc, @CmpCode, @ClmAble, @ClmAmtOn, @ClmGrpCode
		, @SelnOn, @SelLvl, @SchType, @BatLvl, @FlxSch, @FlxCond, @CombiSch, @Range, @ProRata, @Qps
		, @QpsReset, @ApyQpsOn, @ForEvery, @SchStartDate, @SchEndDate, @SchBudget, @EditSch, @AdjDisSch,
		@SetDisMode,@SchStatus,@BudgetAllocationNo,@SchBasedOn,@FBM,@SettlementType
	END

	CLOSE Cur_SchMaster
	DEALLOCATE Cur_SchMaster
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-187-008

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ReturnSchemeClaims]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ReturnSchemeClaims]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--EXEC Proc_ReturnSchemeClaims 17,0,1,'2009-05-01','2009-05-31',1,16

CREATE Procedure [dbo].[Proc_ReturnSchemeClaims]
(
	@Pi_ClmGroupId 		INT,
	@Pi_ClmId		INT,
	@Pi_CmpId		INT,
	@Pi_FromDate		DATETIME,
	@Pi_ToDate		DATETIME,
	@Pi_SettleType	INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT
)
AS
/*********************************
* PROCEDURE	: Proc_ReturnSchemeClaims
* PURPOSE	: To Return Scheme Claims
* CREATED	: Thrinath
* CREATED DATE	: 04/12/2007
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
SET NOCOUNT ON
Begin
DECLARE @SchMst Table
(
	SchId 	INT,
	SchCode	nVarchar(100),
	SchDesc	nVarChar(100)
)

DECLARE @SchemeDetails TABLE
(
	SalInvNo		nVarChar(100),
	SchId			INT,
	SchCode			nVarchar(100),
	SchDesc			nVarChar(100),
	SlabId			INT,
	DiscountAmt		Numeric(38,6),
	FreeAmt			Numeric(38,6),
	GiftAmt			Numeric(38,6),
	Type			INT
)

DECLARE @SchemePrd 	TABLE
(
	SalInvNo		nVarChar(100),
	SchId			INT,
	SlabId			INT, 
	PrdId			INT,
	PrdBatId		INT,
	Combi			nVarChar(100)
)

DECLARE @PriScheme	TABLE
(
	SalInvNo		nVarChar(100),
	SchId			INT,
	SlabId			INT, 
	PrdId			INT,
	PrdBatId		INT,
	PriAmt			Numeric(38,6)
)

DECLARE @Claimable	Numeric(38,6)
DECLARE @RefCode	nVarChar(100)

	SELECT @Claimable = Claimable FROM ClaimNormDefinition 
		WHERE CmpID=@Pi_CmpId AND ClmGrpId=@Pi_ClmGroupId

	SET @Claimable = ISNULL(@Claimable,0)

	INSERT INTO @SchMst(SchId,SchCode,SchDesc) 
	SELECT SchId,SchCode,SchDsc FROM SchemeMaster 
	WHERE CmpId = @Pi_CmpId AND	Claimable = 1 AND ClmRefId = @Pi_ClmGroupId 
	AND SettlementType = (CASE @Pi_SettleType WHEN 0 THEN SettlementType ELSE @Pi_SettleType END)

	IF EXISTS (SELECT Status FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 )
	BEGIN
		SELECT @RefCode = Condition FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 

		INSERT INTO @SchemePrd (SalInvNo,SchId,SlabId,PrdId,PrdBatId,Combi)
		SELECT B.SalInvno,MIN(A.SchId),E.SlabId,A.PrdId,A.PrdBatId,
			CAST(MIN(A.SchId) as nVarChar(15)) + ' - ' + CAST(E.SlabId as nVarChar(15))
			FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			INNER JOIN (SELECT Y.SalInvno,X.SchId,X.PrdId,X.PrdBatId,MIN(SlabId) as SlabId 
				FROM SalesInvoiceSchemeLineWise X 
				INNER JOIN SalesInvoice Y ON X.SalId = Y.SalId 
				INNER JOIN @SchMst Z ON X.SchId = Z.SchId
				WHERE Y.DlvSts in (4,5) AND X.SchClmId in (0,@Pi_ClmId)
				AND Y.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
				GROUP BY Y.SalInvno,X.SchId,X.PrdId,X.PrdBatId) AS E ON
			E.SalInvNo = B.SalInvNo AND E.PrdId = A.PrdId AND E.PrdBatId = A.PrdBatId
			AND E.SchId = A.SchId
			WHERE B.DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId)
			AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.SalInvno,E.SlabId,A.PrdId,A.PrdBatId		

		INSERT INTO  @PriScheme	(SalInvNo,SchId,SlabId,PrdId,PrdBatId,PriAmt)
		SELECT DISTINCT B.SalInvNo,B.SchId,B.SlabId,B.PrdId,B.PrdBatId,
			C.PrdGrossAmount - (C.PrdGrossAmount /(1 +(D.PrdBatDetailValue)/100)) 		
		FROM @SchemePrd B INNER JOIN SalesInvoice A ON A.SalInvNo collate database_default= B.SalInvno collate database_default
			INNER JOIN SalesInvoiceProduct C ON A.SalId = C.SalId
			AND B.PrdId = C.PrdId AND B.PrdBatId = C.PrdBatId
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId 
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
	   		AND E.Slno = D.Slno AND E.RefCode = @RefCode

		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.SalInvno,A.SchId,A.SlabId,ISNULL(SUM(FlatAmount),0) +  ISNULL(SUM(DiscountPerAmount),0),
			0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,1
			FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId)
			AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc

		UPDATE @SchemeDetails SET DiscountAmt = DiscountAmt - (B.PriAmt) FROM 
			@SchemeDetails A INNER JOIN (SELECT SalInvno,SchId,SlabId,SUM(PriAmt) as PriAmt
				FROM @PriScheme GROUP BY SalInvno,SchId,SlabId) B ON
			A.SalInvNo collate database_default= B.SalInvNo collate database_default AND A.SchId = B.SchId AND
			A.SlabId = B.SlabId 

	END
	ELSE
	BEGIN
		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.SalInvno,A.SchId,A.SlabId,ISNULL(SUM(FlatAmount),0) +  ISNULL(SUM(DiscountPerAmount),0),
			0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,1
			FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId)
			AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc
	END
	
	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.SalInvno,A.SchId,A.SlabId,0 as DiscountAmt,ISNULL(SUM(FreeQty * D.PrdBatDetailValue),0),
		0 as GiftAmt,SchCode,SchDesc,1
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId)
		AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc


	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.SalInvno,A.SchId,A.SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(GiftQty * D.PrdBatDetailValue),0),SchCode,SchDesc,1
		FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN SalesInvoice B ON A.SalId = B.SalId
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId)
		AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.SalInvno,A.SchId,A.SlabId,SchCode,SchDesc

	IF EXISTS (SELECT Status FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 )
	BEGIN
		SELECT @RefCode = Condition FROM Configuration WHERE ModuleId = 'SCHEMESTNG14' AND Status = 1 

		DELETE FROM @SchemePrd
		DELETE FROM @PriScheme

		INSERT INTO @SchemePrd (SalInvNo,SchId,SlabId,PrdId,PrdBatId,Combi)
		SELECT B.ReturnCode,MIN(A.SchId),E.SlabId,A.PrdId,A.PrdBatId,
			CAST(MIN(A.SchId) as nVarChar(15)) + ' - ' + CAST(E.SlabId as nVarChar(15))
			FROM ReturnSchemeLineDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId  
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			INNER JOIN (SELECT Y.ReturnCode,X.SchId,X.PrdId,X.PrdBatId,MIN(SlabId) as SlabId 
				FROM ReturnSchemeLineDt X 
				INNER JOIN ReturnHeader Y ON X.ReturnId = Y.ReturnId 
				INNER JOIN @SchMst Z ON X.SchId = Z.SchId
				WHERE Y.Status = 0 AND X.SchClmId in (0,@Pi_ClmId)
				AND Y.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
				GROUP BY Y.ReturnCode,X.SchId,X.PrdId,X.PrdBatId) AS E ON
			E.ReturnCode = B.ReturnCode AND E.PrdId = A.PrdId AND E.PrdBatId = A.PrdBatId
			AND E.SchId = A.SchId
			WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId)
			AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.ReturnCode,E.SlabId,A.PrdId,A.PrdBatId		


		INSERT INTO  @PriScheme	(SalInvNo,SchId,SlabId,PrdId,PrdBatId,PriAmt)
		SELECT DISTINCT B.SalInvNo,B.SchId,B.SlabId,B.PrdId,B.PrdBatId,
			C.PrdActualGross - (C.PrdActualGross /(1 +(D.PrdBatDetailValue)/100)) 		
		FROM @SchemePrd B INNER JOIN ReturnHeader A ON A.ReturnCode collate database_default= B.SalInvno collate database_default
			INNER JOIN ReturnProduct C ON A.ReturnId = C.ReturnId 
			AND B.PrdId = C.PrdId AND B.PrdBatId = C.PrdBatId
			INNER JOIN ProductBatchDetails D ON D.PrdBatId = C.PrdBatId 
			AND D.DefaultPrice=1 INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId
	   		AND E.Slno = D.Slno AND E.RefCode = @RefCode

		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.ReturnCode,A.SchId,A.SlabId,((ISNULL(SUM(ReturnFlatAmount),0) + 
			ISNULL(SUM(ReturnDiscountPerAmount),0)))*(-1),0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,1
			FROM ReturnSchemeLineDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId)
			AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc

		UPDATE @SchemeDetails SET DiscountAmt = DiscountAmt - (B.PriAmt) FROM 
			@SchemeDetails A INNER JOIN (SELECT SalInvno,SchId,SlabId,SUM(PriAmt) as PriAmt
				FROM @PriScheme GROUP BY SalInvno,SchId,SlabId) B ON
			A.SalInvNo collate database_default= B.SalInvNo collate database_default AND A.SchId = B.SchId AND
			A.SlabId = B.SlabId 

	END
	ELSE
	BEGIN
		INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
		SELECT B.ReturnCode,A.SchId,A.SlabId,((ISNULL(SUM(ReturnFlatAmount),0) + 
			ISNULL(SUM(ReturnDiscountPerAmount),0)))*(-1),0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,1
			FROM ReturnSchemeLineDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
			INNER JOIN @SchMst S ON A.SchId = S.SchId
			WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId)
			AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
		GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc
	END
			--select DiscountAmt from @SchemeDetails	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.ReturnCode,A.SchId,A.SlabId,0 as DiscountAmt,
		ISNULL(SUM(ReturnFreeQty * D.PrdBatDetailValue),0)*(-1),0 as GiftAmt,SchCode,SchDesc,1
		FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
		INNER JOIN ProductBatch C (NOLOCK) ON A.FreePrdId = C.PrdId AND 
		A.FreePrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.FreePriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId)
		AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc
	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.ReturnCode,A.SchId,A.SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(ReturnGiftQty * D.PrdBatDetailValue),0)*(-1),SchCode,SchDesc,1
		FROM ReturnSchemeFreePrdDt A INNER JOIN ReturnHeader B ON A.ReturnId = B.ReturnId 
		INNER JOIN ProductBatch C (NOLOCK) ON A.GiftPrdId = C.PrdId AND 
		A.GiftPrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.GiftPriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE B.Status = 0 AND A.SchClmId in (0,@Pi_ClmId)
		AND B.ReturnDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.ReturnCode,A.SchId,A.SlabId,SchCode,SchDesc
	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.SalInvno,A.SchId,1 as SlabId,ISNULL(SUM(AdjAmt),0),0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,2
		FROM SalesInvoiceWindowDisplay A 
		INNER JOIN SalesInvoice B ON A.SalId = B.SalId 
		INNER JOIN @SchMst S ON A.SchId = S.SchId
		WHERE DlvSts in (4,5) AND A.SchClmId in (0,@Pi_ClmId)
		AND B.SalInvDate Between @Pi_FromDate AND @Pi_ToDate
	GROUP BY B.SalInvno,A.SchId,SchCode,SchDesc
	
	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.ChqDisRefNo,A.TransId,1 as SlaId,ISNULL(SUM(Amount),0),
		0 as FreeAmt,0 as GiftAmt,SchCode,SchDesc,3 
		FROM ChequeDisbursalMaster A 
		INNER JOIN ChequeDisbursalDetails B ON A.ChqDisRefNo = B.ChqDisRefNo 
		INNER JOIN @SchMst S ON A.TransId = S.SchId
		WHERE TransType = 1 AND A.ChqDisDate Between @Pi_FromDate AND @Pi_ToDate
		AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY B.ChqDisRefNo,A.TransId,SchCode,SchDesc

-- FOR Point Based Schemes
	DELETE FROM @SchMst
	INSERT INTO @SchMst(SchId,SchCode,SchDesc) 
	SELECT PntRedSchId,PntRedSchCode,[Description]
 		FROM PointRedemptionMaster WHERE CmpId = @Pi_CmpId AND
		Claimable = 1 AND ClmRefId = @Pi_ClmGroupId

	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT A.PntRedRefNo,PntRedSchId,SlabId,ISNULL(SUM(CrAmt),0),0 as FreeAmt,0 As GiftAmt,
		SchCode,SchDesc,4
		FROM PntRetSchemeHD A INNER JOIN PntRetSchemeDt B
		ON A.PntRedRefNo = B.PntRedRefNo
		INNER JOIN @SchMst S ON A.PntRedSchId = S.SchId
		WHERE A.Status = 1 AND A.TransDate Between @Pi_FromDate AND @Pi_ToDate
		AND CrAmt>0 AND B.SchClmId in (0,@Pi_ClmId)
	GROUP BY A.PntRedRefNo,PntRedSchId,SlabId,SchCode,SchDesc

	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT A.PntRedRefNo,PntRedSchId,SlabId,0 as DiscountAmt,ISNULL(SUM(Qty * D.PrdBatDetailValue),0),
		0 as GiftAmt,SchCode,SchDesc,4
		FROM PntRetSchemeDt A INNER JOIN PntRetSchemeHD B ON A.PntRedRefNo = B.PntRedRefNo
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON B.PntRedSchId = S.SchId
		WHERE B.Status = 1 AND B.TransDate Between @Pi_FromDate AND @Pi_ToDate
		AND CrAmt=0 AND A.Type=1 AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY A.PntRedRefNo,PntRedSchId,SlabId,SchCode,SchDesc

	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT A.PntRedRefNo,PntRedSchId,SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(Qty * D.PrdBatDetailValue),0) as GiftAmt,SchCode,SchDesc,4
		FROM PntRetSchemeDt A INNER JOIN PntRetSchemeHD B ON A.PntRedRefNo = B.PntRedRefNo
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON B.PntRedSchId = S.SchId
		WHERE B.Status = 1 AND B.TransDate Between @Pi_FromDate AND @Pi_ToDate
		AND CrAmt=0 AND A.Type=2 AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY A.PntRedRefNo,PntRedSchId,SlabId,SchCode,SchDesc

--For Coupon Scheme
	DELETE FROM @SchMst
	INSERT INTO @SchMst(SchId,SchCode,SchDesc) 
	SELECT B.CouponDenomId,B.CouponDenomRefNo,A.CouponDefDescription
 		FROM CouponDefinitionHd A INNER JOIN CouponDenomHd B ON
		A.CouponDefId = B.CouponDefId WHERE A.CmpId = @Pi_CmpId AND 
		A.CouponDefClaimable = 1 AND A.CouponDefClaimGroupID = @Pi_ClmGroupId

	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT A.CpnRedCode,A.CouponDenomId,B.SlabId,ISNULL(SUM(CrAmt),0),0 as FreeAmt,0 As GiftAmt,
		SchCode,SchDesc,5
		FROM CouponRedHd A INNER JOIN CouponRedOtherDt B
		ON A.CpnRefId = B.CpnRefId
		INNER JOIN @SchMst S ON A.CouponDenomId = S.SchId
		WHERE A.Status = 1 AND A.CpnRedDate Between @Pi_FromDate AND @Pi_ToDate
		AND CrAmt>0 AND B.SchClmId in (0,@Pi_ClmId)
	GROUP BY A.CpnRedCode,A.CouponDenomId,B.SlabId,SchCode,SchDesc

	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.CpnRedCode,B.CouponDenomId,A.SlabId,0 as DiscountAmt,ISNULL(SUM(Qty * D.PrdBatDetailValue),0),
		0 as GiftAmt,SchCode,SchDesc,5
		FROM CouponRedProducts A INNER JOIN CouponRedHd B ON A.CpnRefId = B.CpnRefId
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON B.CouponDenomId = S.SchId
		INNER JOIN Product P ON P.PrdId = A.PrdId AND P.PrdId = C.PrdId AND PrdType <> 4
		WHERE B.Status = 1 AND B.CpnRedDate Between @Pi_FromDate AND @Pi_ToDate
		AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY B.CpnRedCode,B.CouponDenomId,A.SlabId,SchCode,SchDesc

	INSERT INTO @SchemeDetails (SalInvNo,SchId,SlabId,DiscountAmt,FreeAmt,GiftAmt,SchCode,SchDesc,Type)
	SELECT B.CpnRedCode,B.CouponDenomId,A.SlabId,0 as DiscountAmt,0 as FreeAmt,
		ISNULL(SUM(Qty * D.PrdBatDetailValue),0) as GiftAmt,SchCode,SchDesc,5
		FROM CouponRedProducts A INNER JOIN CouponRedHd B ON A.CpnRefId = B.CpnRefId
		INNER JOIN ProductBatch C (NOLOCK) ON A.PrdId = C.PrdId AND 
		A.PrdBatId = C.PrdBatId INNER JOIN ProductBatchDetails D (NOLOCK) ON 
		C.PrdBatId = D.PrdBatId AND A.PriceId = D.PriceId INNER JOIN BatchCreation E (NOLOCK)
	        ON E.BatchSeqId = C.BatchSeqId AND D.SlNo = E.SlNo AND E.ClmRte = 1 
		INNER JOIN @SchMst S ON B.CouponDenomId = S.SchId
		INNER JOIN Product P ON P.PrdId = A.PrdId AND P.PrdId = C.PrdId AND PrdType =4
		WHERE B.Status = 1 AND B.CpnRedDate Between @Pi_FromDate AND @Pi_ToDate
		AND A.SchClmId in (0,@Pi_ClmId)
	GROUP BY B.CpnRedCode,B.CouponDenomId,A.SlabId,SchCode,SchDesc

	DELETE FROM TempSchemeClaimDetails WHERE Usrid = @Pi_UsrId AND TransID = @Pi_TransId

--	INSERT INTO TempSchemeClaimDetails (SalInvNo,SchId,SchCode,SchDesc,SlabId,Selected,DiscountAmt,
--		FreeAmt,GiftAmt,TotSpent,Claimable,ClaimableAmt,RecomAmount,RecAmount,DBCRSelection,
--		StatusDesc,Type,Usrid,TransID)
--	SELECT SalInvNo,SchId,SchCode,SchDesc,SlabId,0 as Selected,
--		Convert(Numeric(38,2),Sum(DiscountAmt)) ,
--		Convert(Numeric(38,2),sum(FreeAmt)) ,
--		Convert(Numeric(38,2),Sum(GiftAmt)), 
--		Convert(Numeric(38,2),Sum((DiscountAmt + FreeAmt + GiftAmt))) ,
--		ISNULL(@Claimable,0) , 0.00 , 0 , 0  , 0 ,'Cancelled', Type, @Pi_UsrId,@Pi_TransId
--		FROM @SchemeDetails
--	GROUP BY SalInvNo,SchId,SchCode,SchDesc,SlabId,Type

	INSERT INTO TempSchemeClaimDetails (SalInvNo,SchId,SchCode,CmpSchCode,SchDesc,SlabId,Selected,DiscountAmt,
		FreeAmt,GiftAmt,TotSpent,Claimable,ClaimableAmt,RecomAmount,RecAmount,DBCRSelection,
		StatusDesc,Type,Usrid,TransID)
	SELECT SD.SalInvNo,SD.SchId,SD.SchCode,SM.CmpSchCode,SD.SchDesc,SD.SlabId,0 as Selected,
		Convert(Numeric(38,2),Sum(DiscountAmt)) ,
		Convert(Numeric(38,2),sum(FreeAmt)) ,
		Convert(Numeric(38,2),Sum(GiftAmt)), 
		Convert(Numeric(38,2),Sum((DiscountAmt + FreeAmt + GiftAmt))) ,
		ISNULL(@Claimable,0) , 0.00 , 0 , 0  , 0 ,'Cancelled', Type, @Pi_UsrId,@Pi_TransId
		FROM @SchemeDetails SD,SchemeMaster SM
	WHERE SD.SchId=SM.SchId 
	GROUP BY SD.SalInvNo,SD.SchId,SD.SchCode,SM.CmpSchCode,SD.SchDesc,SD.SlabId,Type	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-187-009

DELETE FROM Configuration WHERE ModuleName='Scheme Master' ANd ModuleId='SCHCON13'

INSERT INTO Configuration (ModuleId,ModuleName,Description,Status,Condition,ConfigValue,SeqNo)
VALUES('SCHCON13','Scheme Master','Enable Settlement Type in Scheme Master',0,'',0.00,13)

--SRF-Nanda-187-010

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplySchemeInBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplySchemeInBill]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--EXEC Proc_ApplySchemeInBill 25,2,152,4,2
-- SELECT * FROM dbo.ApportionSchemeDetails
-- SELECT * FROM Retailer WHERE RtrName Like 'PAN%'
EXEC Proc_ApplySchemeInBill 516,2,2137,2,3
SELECT * FROM BillAppliedSchemeHd
-- DELETE FROM BillAppliedSchemeHd
-- SELECT * FROM BilledPrdHdForScheme(NOLOCK)
ROLLBACK TRANSACTION
*/

CREATE          Procedure [dbo].[Proc_ApplySchemeInBill]
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
		PrdId			INT,
		PrdBatId		INT,
		SchemeOnQty 		NUMERIC(38,0),
		SchemeOnAmount		NUMERIC(38,6),
		SchemeOnKG		NUMERIC(38,6),
		SchemeOnLitre		NUMERIC(38,6),
		SchId 			INT
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

	SELECT 'N3',* FROM BilledPrdHdForScheme

	-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
	SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,
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

	--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
	INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
	SELECT ISNULL(CASE @SchType
		WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
	-- 	WHEN 1 THEN SUM(CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
		WHEN 2 THEN SUM(SchemeOnAmount)
		WHEN 3 THEN (CASE A.UomId
				WHEN 2 THEN SUM(SchemeOnKg) * 1000
				WHEN 3 THEN SUM(SchemeOnKg)
				WHEN 4 THEN SUM(SchemeOnLitre) * 1000
				WHEN 5 THEN SUM(SchemeOnLitre)	END)
			END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
		ISNULL(CASE @SchType
		WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
	-- 	WHEN 1 THEN SUM(CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
		WHEN 2 THEN SUM(SchemeOnAmount)
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
	--SELECT * FROM @TempBilled
	--SELECT * FROM @TempBilledAch
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
		SELECT A.FrmSchAch,B.ForEveryQty  FROM
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

	--To Store the Gross amount for the Scheme billed Product
	SELECT @GrossAmount = ISNULL(SUM(SchemeOnAmount),0) FROM @TempBilled

	SELECT 'N1',* FROM @TempBilled
	SELECT 'N2',* FROM @TempSchSlabAmt

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

	--SELECT * FROM @TempSchSlabFree
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

	--SELECT A.PrdBatId FROM StockLedger A LEFT OUTER JOIN BilledPrdHdForScheme B ON A.PrdId=B.PrdId
	--	AND A.PrdBatId=B.PrdBatId WHERE A.TransDate=CONVERT(VARCHAR(10),GETDATE(),121)
	--	AND B.Usrid = @Pi_UsrId AND B.TransId = @Pi_TransId
	--	AND ((A.SalClsStock+A.OfferClsStock)-B.BaseQty)=0

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

	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
	EXEC Proc_ApplyDiscountScheme @Pi_SchId,@Pi_UsrId,@Pi_TransId
	UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
		SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
		TransId = @Pi_TransId AND Usrid = @Pi_UsrId
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-187-011

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyQPSSchemeInBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyQPSSchemeInBill]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--SELECT * FROM BilledPrdHdForQPSScheme(NOLOCK) WHERE SchId=527
--SELECT * FROM BillAppliedSchemeHd
--DELETE FROM BillAppliedSchemeHd
EXEC Proc_ApplyQPSSchemeInBill 527,1,0,2,2
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BilledPrdHdForScheme
--SELECT * FROM BilledPrdHdForQPSScheme
--SELECT * FROM BillAppliedSchemeHd(NOLOCK) WHERE TransId = 2 And UsrId = 2
SELECT * FROM BillAppliedSchemeHd (NOLOCK)
--SELECT * FROM ApportionSchemeDetails (NOLOCK)
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
	--IF @QPSReset=1
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
					(CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END )
				WHEN 2 THEN 
					(CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END)
				WHEN 3 THEN
					(CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END)
			END
			as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
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
	--IF @QPSReset=1
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
	FROM @QPSGivenFlat A WHERE BillAppliedSchemeHd.SchId=A.SchId AND A.SchId=@Pi_SchId	
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

--SRF-Nanda-187-012

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyCombiSchemeInBill]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyCombiSchemeInBill]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
--EXEC Proc_ApplyCombiSchemeInBill 72,3789,0,1,2
EXEC Proc_ApplyCombiSchemeInBill 514,601,0,2,2
-- DELETE FROM BillAppliedSchemeHd
-- SELECT * FROM BillAppliedSchemeHd
--EXEC Proc_ApportionSchemeAmountInLine 1,2
-- SELECT * FROM ApportionSchemeDetails
-- SELECT * FROM BillAppliedSchemeHd
-- SELECT * FROM BilledPrdHdForScheme
--DELETE FROM ApportionSchemeDetails
--DELETE FROM BillAppliedSchemeHd
-- UPDATE BillAppliedSchemeHd SET IsSelected = 1
ROLLBACK TRANSACTION
*/

CREATE        Procedure [dbo].[Proc_ApplyCombiSchemeInBill]
(
	@Pi_SchId  		INT,
	@Pi_RtrId		INT,
	@Pi_SalId  		INT,
	@Pi_UsrId 		INT,
	@Pi_TransId		INT		
)
AS
/*********************************
* PROCEDURE	: Proc_ApplyCombiSchemeInBill
* PURPOSE	: To Apply the Combi Scheme and Get the Scheme Details for the Selected Scheme
* CREATED	: Thrinath
* CREATED DATE	: 17/04/2007
* NOTE		: General SP for Returning the Scheme Details for the Selected Combi Scheme
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date}		{developer}		  {brief modification description}
* 10/04/2010    Nandakumar R.G    Modified for QPS Scheme	
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
	DECLARE @QpsReset		INT
	DECLARE @QpsResetAvail		INT
	DECLARE @PurOfEveryReq		INT
	DECLARE @SchemeBudget		NUMERIC(38,6)
	DECLARE @SlabId			INT
	DECLARE @NoOfTimes		NUMERIC(38,6)
	DECLARE @GrossAmount		NUMERIC(38,6)
	DECLARE @SchemeLvlMode		INT
	DECLARE @PrdId			INT
	DECLARE @PrdBatId		INT
	DECLARE @PrdCtgValMainId	INT
	DECLARE @FrmSchAch		NUMERIC(38,6)
	DECLARE @FrmUomAch		INT
	DECLARE @FromQty		NUMERIC(38,6)
	DECLARE @UomId			INT
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
	DECLARE @SchValidTill	DATETIME
	DECLARE @SchValidFrom	DATETIME
	DECLARE @QPSBasedOn		INT
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
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @TempBilledCombiAch TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
	)
	DECLARE @TempBilledQpsReset TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
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
		PrdbatId		INT
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

	DECLARE @QPSGivenFlat TABLE
	(
		SchId   INT,		
		Amount  NUMERIC(38,6)
	)

	DECLARE @QPSGivenFlatAmt AS NUMERIC(38,6)

	SELECT @SchCode = SchCode,@SchType = SchType,@BatchLevel = BatchLevel,@FlexiSch = FlexiSch,
		@FlexiSchType = FlexiSchType,@CombiScheme = CombiSch,@SchLevelId = SchLevelId,@ProRata = ProRata,
		@Qps = QPS,@QpsReset = QPSReset,@QPSBasedOn=ApyQPSSch,@SchemeBudget = Budget,@PurOfEveryReq = PurofEvery,
		@SchemeLvlMode = SchemeLvlMode,@SchValidTill=SchValidTill,@SchValidFrom=SchValidFrom
	FROM SchemeMaster WHERE SchId = @Pi_SchId AND MasterType=1
	IF EXISTS (SELECT * FROM SalesInvoice WHERE SalId = @Pi_SalId)
	BEGIN
		SELECT @BillDate = SalInvDate FROM SalesInvoice WHERE SalId = @Pi_SalId
	END
	ELSE
	BEGIN
		SET @BillDate = CONVERT(VARCHAR(10),GETDATE(),121)
	END
	IF EXISTS(SELECT * FROM SchemeMaster WHERE SchId = @Pi_SchId AND SchValidTill >= @BillDate)
	BEGIN
		-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
		SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,ISNULL(SUM(A.BaseQty * A.SelRate),0) AS SchemeOnAmount,
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
	END
	IF @QPS <> 0
	BEGIN
--		--To Add the Cumulative Qty
--		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
--		SELECT A.PrdId,A.PrdBatId,ISNULL(SUM(A.SumQty),0) AS SchemeOnQty,
--			ISNULL(SUM(A.SumValue),0) AS SchemeOnAmount,
--			ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(SumInKG),0)
--			WHEN 3 THEN ISNULL(SUM(SumInKG),0) END,0) AS SchemeOnKg,
--			ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(SumInLitre),0)
--			WHEN 5 THEN ISNULL(SUM(SumInLitre),0) END,0) AS SchemeOnLitre,@Pi_SchId
--			FROM SalesInvoiceQPSCumulative A (NOLOCK)
--			INNER JOIN Product C ON A.PrdId = C.PrdId
--			INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
--			WHERE A.SchId = @Pi_SchId AND A.RtrId = @Pi_RtrId
--			GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
--		--To Subtract the Billed Qty in Edit Mode
--		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
--		SELECT A.PrdId,A.PrdBatId,-1 * ISNULL(SUM(A.BaseQty),0) AS SchemeOnQty,
--			-1 * ISNULL(SUM(A.BaseQty * A.PrdUnitSelRate),0) AS SchemeOnAmount,
--			-1 * ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
--			WHEN 3 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnKg,
--			-1 * ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000
--			WHEN 5 THEN ISNULL(SUM(PrdWgt * A.BaseQty),0) END,0) AS SchemeOnLitre,@Pi_SchId
--			FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@Pi_SchId) B ON
--			A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
--			INNER JOIN Product C ON A.PrdId = C.PrdId
--			INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
--			WHERE A.SalId = @Pi_SalId
--			GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId
--		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
--		SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
--			-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
--			-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
--			FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
--			AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
--		INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
--		SELECT PrdId,PrdBatId,ISNULL(SUM(SumQty),0) AS SchemeOnQty,
--			ISNULL(SUM(SumValue),0) AS SchemeOnAmount,ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
--			ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
--			FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
--			GROUP BY PrdId,PrdBatId
--
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
--			SELECT * FROM @TempBilled1
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
	--		SELECT * FROM @TempBilled1
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
--			SELECT '11',* FROM @TempBilled1
			IF @QPSBasedOn=1 OR (@QPSBasedOn<>1 AND @FlexiSch=1)
			BEGIN
				INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
				SELECT PrdId,PrdBatId,-1 * ISNULL(SUM(SumQty),0) AS SchemeOnQty,
					-1 * ISNULL(SUM(SumValue),0) AS SchemeOnAmount,-1 * ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
					-1 * ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
					FROM SalesInvoiceQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
					AND SalId <> @Pi_SalId GROUP BY PrdId,PrdBatId
			END

--			SELECT '22',* FROM @TempBilled1
			INSERT INTO @TempBilled1(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
			SELECT PrdId,PrdBatId,ISNULL(SUM(SumQty),0) AS SchemeOnQty,
				ISNULL(SUM(SumValue),0) AS SchemeOnAmount,ISNULL(SUM(SumInKG),0) AS SchemeOnKG,
				ISNULL(SUM(SumInLitre),0) AS SchemeOnLitre,@Pi_SchId
				FROM ReturnQPSRedeemed WHERE SchId = @Pi_SchId AND RtrId = @Pi_RtrId
				GROUP BY PrdId,PrdBatId

--			SELECT '33',* FROM @TempBilled1
	END

	INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)
	SELECT PrdId,PrdBatId,ISNULL(SUM(SchemeOnQty),0),ISNULL(SUM(SchemeOnAmount),0),
	ISNULL(SUM(SchemeOnKG),0),ISNULL(SUM(SchemeOnLitre),0),SchId FROM @TempBilled1
	GROUP BY PrdId,PrdBatId,SchId
--	SELECT 'N',* FROM @TempBilled1
--	SELECT @SchemeLvlMode
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
	--SELECT 'N',* FROM @TempHier
	--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
	INSERT INTO @TempBilledAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
	SELECT F.PrdId,F.PrdBatId,F.PrdCtgValMainId,ISNULL(CASE @SchType
		WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
		WHEN 2 THEN SUM(SchemeOnAmount)
		WHEN 3 THEN (CASE A.UomId
				WHEN 2 THEN SUM(SchemeOnKg)* 1000
				WHEN 3 THEN SUM(SchemeOnKg)
				WHEN 4 THEN SUM(SchemeOnLitre) * 1000
				WHEN 5 THEN SUM(SchemeOnLitre)	END)
			END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
		A.Slabid,F.SlabValue as FromQty,A.UomId
		FROM SchemeSlabs A
		INNER JOIN SchemeSlabCombiPrds F ON A.SchId = F.SchId AND F.SchId = @Pi_SchId
		AND A.SlabId = F.SlabId
		INNER JOIN @TempBilled B ON A.SchId = B.SchId AND A.SchId = @Pi_SchId
		INNER JOIN Product C ON B.PrdId = C.PrdId
		INNER JOIN @TempHier G ON G.PrdId = CASE F.PrdId WHEN 0 THEN G.PrdId ELSE F.PrdId END
		AND G.PrdBatId = CASE F.PrdBatId WHEN 0 THEN G.PrdBatId ELSE F.PrdBatId END
		AND G.PrdCtgValMainId = CASE F.PrdCtgValMainId WHEN 0 THEN G.PrdCtgValMainId ELSE F.PrdCtgValMainId END
		AND B.PrdId = G.PrdId AND B.PrdBatId = G.PrdBatId
		LEFT OUTER JOIN UomGroup D ON D.UomGroupId = C.UomGroupId AND D.UomId = A.UomId
		GROUP BY F.PrdId,F.PrdBatId,F.PrdCtgValMainId,A.UomId,A.Slabid,A.PurQty,F.SlabValue,A.UomId
	SET @QpsResetAvail = 0
	IF @QpsReset <> 0
	BEGIN
		INSERT INTO @TempBilledQpsReset(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
		SELECT A.* FROM @TempBilledAch A
			INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
			WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
			AND A.PrdCtgValMainId = B.PrdCtgValMainId
		
		--Select the Applicable Slab for the Scheme
		SELECT @SlabId = ISNULL(MAX(A.SlabId),0)  FROM
			(SELECT COUNT(SlabId) AS CntAch,SlabId FROM @TempBilledQpsReset GROUP BY SlabId) AS A
			INNER JOIN
			(SELECT COUNT(SlabId) AS CntSch,SlabId FROM SchemeSlabCombiPrds WHERE SchId = @Pi_SchId
			GROUP BY SlabId) AS B ON A.SlabId = B.SlabId AND A.CntAch = B.CntSch
		SET @QpsResetAvail = 1
	END
	IF @QpsResetAvail = 1
	BEGIN
		INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
		SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,B.SlabValue,A.FrmUomAch,@SlabId,B.SlabValue,A.FrmUomAch
			FROM @TempBilledAch A INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
			AND B.SlabId = @SlabId WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId
			AND A.PrdBatId = B.PrdBatId AND A.PrdCtgValMainId = B.PrdCtgValMainId
			AND B.SchId = @Pi_SchId
	END
	ELSE
	BEGIN
		INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
		SELECT A.* FROM @TempBilledAch A INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
			WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
			AND A.PrdCtgValMainId = B.PrdCtgValMainId AND B.SchId = @Pi_SchId
	END
	WHILE (SELECT ISNULL(SUM(FrmSchAch),0) FROM @TempBilledCombiAch) > 0
	BEGIN
		DELETE FROM @TempRedeem
		--Select the Applicable Slab for the Scheme
		SELECT @SlabId = ISNULL(MAX(A.SlabId),0)  FROM
			(SELECT COUNT(SlabId) AS CntAch,SlabId FROM @TempBilledCombiAch GROUP BY SlabId) AS A
			INNER JOIN
			(SELECT COUNT(SlabId) AS CntSch,SlabId FROM SchemeSlabCombiPrds WHERE SchId = @Pi_SchId
			GROUP BY SlabId) AS B ON A.SlabId = B.SlabId AND A.CntAch = B.CntSch
		
		--SELECT * FROM @TempBilledCombiAch WHERE SlabId = @SlabId ORDER BY FrmSchAch DESC
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
		SELECT @NoOfTimes = ISNULL(MIN(NoOfTimes),1) FROM
			(SELECT FLOOR(FrmSchAch / (CASE FromQty WHEN 0 THEN 1 ELSE FROMQTY END)) AS NoOfTimes
			FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId) AS A
		
		IF @SchType = 1
		BEGIN
			DECLARE Cur_Qty Cursor For
				SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
					FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
					ORDER BY FrmSchAch Desc
			OPEN Cur_Qty
			FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
				@FrmUomAch,@FromQty,@UomId
			WHILE @@FETCH_STATUS =0
			BEGIN
				IF @PrdCtgValMainId > 0
				BEGIN
					DECLARE Cur_Redeem Cursor For
						SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
							WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
							AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE
							A.PrdBatId END AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0
							THEN B.PrdCtgValMainId ELSE A.PrdCtgValMainId END AND
							B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
							AND A.SlabId = @SlabId AND B.PrdCtgValMainId = @PrdCtgValMainId
							ORDER BY FrmSchAch Desc
					OPEN Cur_Redeem
					FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
						@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
					WHILE @@FETCH_STATUS =0
					BEGIN
						WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
						BEGIN
							SET @AssignQty  = 0
							SET @AssignAmount = 0
							SET @AssignKG = 0
							SET @AssignLitre = 0
							SELECT @AssignQty = @FrmSchAchRem * ConversionFactor FROM
							Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
							AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
							SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
						END
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
						@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
						@UomIdRem
						
					END
					CLOSE Cur_Redeem
					DEALLOCATE Cur_Redeem
				END
				ELSE
				IF (@PrdId > 0 AND @PrdBatId = 0)
				BEGIN
					DECLARE Cur_Redeem Cursor For
						SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,
							@TempBilled C WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId
							ELSE A.PrdId END AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN
							B.PrdBatId ELSE A.PrdBatId END AND B.PrdCtgValMainId = CASE
							A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE
							A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND
							B.PrdBatId = C.PrdBatId AND A.SlabId = @SlabId AND
							B.PrdId = @PrdId ORDER BY FrmSchAch Desc
					OPEN Cur_Redeem
					FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
						@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
					WHILE @@FETCH_STATUS =0
					BEGIN
						WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
						BEGIN
							SET @AssignQty  = 0
							SET @AssignAmount = 0
							SET @AssignKG = 0
							SET @AssignLitre = 0
							SELECT @AssignQty = @FrmSchAchRem * ConversionFactor FROM
							Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
							AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
							SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
						END
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
						@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
						@UomIdRem
						
					END
					CLOSE Cur_Redeem
					DEALLOCATE Cur_Redeem
				END	
				ELSE
				IF (@PrdId > 0 AND @PrdBatId > 0)
				BEGIN
					DECLARE Cur_Redeem Cursor For
						SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
						FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
						WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
						AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
						AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId
						ELSE A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
						AND A.SlabId = @SlabId AND B.PrdId = @PrdId AND B.PrdBatId = @PrdBatId
						ORDER BY FrmSchAch Desc
					OPEN Cur_Redeem
					FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
						@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
					WHILE @@FETCH_STATUS =0
					BEGIN
						WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
						BEGIN
							SET @AssignQty  = 0
							SET @AssignAmount = 0
							SET @AssignKG = 0
							SET @AssignLitre = 0
							SELECT @AssignQty = @FrmSchAchRem * ConversionFactor FROM
							Product A INNER JOIN UomGroup B ON A.UomGroupId = B.UomGroupId
							AND B.UomId = @FrmUomAchRem WHERE A.PrdId = @PrdIdRem
							SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
						END
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
						@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
						@UomIdRem
					END
					CLOSE Cur_Redeem
					DEALLOCATE Cur_Redeem
				END
				FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
					@FrmUomAch,@FromQty,@UomId
			END
			CLOSE Cur_Qty
			DEALLOCATE Cur_Qty
		END
		IF @SchType = 2
		BEGIN
			DECLARE Cur_Qty Cursor For
				SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
					FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
					ORDER BY FrmSchAch Desc
			OPEN Cur_Qty
			FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
				@FrmUomAch,@FromQty,@UomId
			WHILE @@FETCH_STATUS =0
			BEGIN
				IF @PrdCtgValMainId > 0
				BEGIN
					DECLARE Cur_Redeem Cursor For
						SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
							WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
							AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE
							A.PrdBatId END AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0
							THEN B.PrdCtgValMainId ELSE A.PrdCtgValMainId END AND
							B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
							AND A.SlabId = @SlabId AND B.PrdCtgValMainId = @PrdCtgValMainId
							ORDER BY FrmSchAch Desc
					OPEN Cur_Redeem
					FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
						@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
					WHILE @@FETCH_STATUS =0
					BEGIN
						WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
						BEGIN
							SET @AssignQty  = 0
							SET @AssignAmount = 0
							SET @AssignKG = 0
							SET @AssignLitre = 0
							SET @AssignAmount = @FrmSchAchRem
							SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
						END
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
						@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
						@UomIdRem
						
					END
					CLOSE Cur_Redeem
					DEALLOCATE Cur_Redeem
				END
				ELSE
				IF (@PrdId > 0 AND @PrdBatId = 0)
				BEGIN
					DECLARE Cur_Redeem Cursor For
						SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,
							@TempBilled C WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId
							ELSE A.PrdId END AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN
							B.PrdBatId ELSE A.PrdBatId END AND B.PrdCtgValMainId = CASE
							A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE
							A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND
							B.PrdBatId = C.PrdBatId AND A.SlabId = @SlabId AND
							B.PrdId = @PrdId ORDER BY FrmSchAch Desc
					OPEN Cur_Redeem
					FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
						@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
					WHILE @@FETCH_STATUS =0
					BEGIN
						WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
						BEGIN
							SET @AssignQty  = 0
							SET @AssignAmount = 0
							SET @AssignKG = 0
							SET @AssignLitre = 0
							SET @AssignAmount = @FrmSchAchRem
							SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
						END
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
						@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
						@UomIdRem
						
					END
					CLOSE Cur_Redeem
					DEALLOCATE Cur_Redeem
				END	
				ELSE
				IF (@PrdId > 0 AND @PrdBatId > 0)
				BEGIN
					DECLARE Cur_Redeem Cursor For
						SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
						FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
						WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
						AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
						AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId
						ELSE A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
						AND A.SlabId = @SlabId AND B.PrdId = @PrdId AND B.PrdBatId = @PrdBatId
						ORDER BY FrmSchAch Desc
					OPEN Cur_Redeem
					FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
						@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
					WHILE @@FETCH_STATUS =0
					BEGIN
						WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
						BEGIN
							SET @AssignQty  = 0
							SET @AssignAmount = 0
							SET @AssignKG = 0
							SET @AssignLitre = 0
							SET @AssignAmount = @FrmSchAchRem
							SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
						END
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
						@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
						@UomIdRem
					END
					CLOSE Cur_Redeem
					DEALLOCATE Cur_Redeem
				END
				FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
					@FrmUomAch,@FromQty,@UomId
			END
			CLOSE Cur_Qty
			DEALLOCATE Cur_Qty
		END
		IF @SchType = 3
		BEGIN
			SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
					FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
					ORDER BY FrmSchAch Desc
			DECLARE Cur_Qty Cursor For
				SELECT A.PrdId,A.PrdBatId,A.PrdCtgValMainId,FrmSchAch,FrmUomAch,FromQty,UomId
					FROM @TempBilledCombiAch A WHERE A.SlabId = @SlabId
					ORDER BY FrmSchAch Desc
			OPEN Cur_Qty
			FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
				@FrmUomAch,@FromQty,@UomId
			WHILE @@FETCH_STATUS =0
			BEGIN
				IF @PrdCtgValMainId > 0
				BEGIN
					DECLARE Cur_Redeem Cursor For
						SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
							WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
							AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE
							A.PrdBatId END AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0
							THEN B.PrdCtgValMainId ELSE A.PrdCtgValMainId END AND
							B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
							AND A.SlabId = @SlabId AND B.PrdCtgValMainId = @PrdCtgValMainId
							ORDER BY FrmSchAch Desc
					OPEN Cur_Redeem
					FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
						@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
					WHILE @@FETCH_STATUS =0
					BEGIN
						WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
						BEGIN
							SET @AssignQty  = 0
							SET @AssignAmount = 0
							SET @AssignKG = 0
							SET @AssignLitre = 0
							SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
								(@FrmSchAchRem / 1000) WHEN 3 THEN
								(@FrmSchAchRem) ELSE
								0 END FROM Product WHERE PrdId = @PrdIdRem)
		
							SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
								(@FrmSchAchRem / 1000) WHEN 5 THEN
								(@FrmSchAchRem) ELSE
								0 END FROM Product WHERE PrdId = @PrdIdRem)
							SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
							SET @AssignQty = (SELECT CASE PrdUnitId
								WHEN 2 THEN
									(@AssignKG /(CASE PrdWgt WHEN 0 THEN 1 ELSE
										PrdWgt END / 1000))
								WHEN 3 THEN
									(@AssignKG/(CASE PrdWgt WHEN 0 THEN 1 ELSE PrdWgt END))
								WHEN 4 THEN
									(@AssignLitre /(CASE PrdWgt WHEN 0 THEN 1 ELSE
										PrdWgt END / 1000))
								WHEN 5 THEN								(@AssignLitre/(CASE PrdWgt WHEN 0 THEN 1
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
						END
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
						@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
						@UomIdRem
						
					END
					CLOSE Cur_Redeem
					DEALLOCATE Cur_Redeem
				END
				ELSE
				IF (@PrdId > 0 AND @PrdBatId = 0)
				BEGIN
					DECLARE Cur_Redeem Cursor For
						SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
							FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,
							@TempBilled C WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId
							ELSE A.PrdId END AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN
							B.PrdBatId ELSE A.PrdBatId END AND B.PrdCtgValMainId = CASE
							A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId ELSE
							A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND
							B.PrdBatId = C.PrdBatId AND A.SlabId = @SlabId AND
							B.PrdId = @PrdId ORDER BY FrmSchAch Desc
					OPEN Cur_Redeem
					FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,					
					@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
					WHILE @@FETCH_STATUS =0
					BEGIN
						WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
						BEGIN
							SET @AssignQty  = 0
							SET @AssignAmount = 0
							SET @AssignKG = 0
							SET @AssignLitre = 0
							SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
								(@FrmSchAchRem / 1000) WHEN 3 THEN
								(@FrmSchAchRem) ELSE
								0 END FROM Product WHERE PrdId = @PrdIdRem)
		
							SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
								(@FrmSchAchRem / 1000) WHEN 5 THEN
								(@FrmSchAchRem) ELSE
								0 END FROM Product WHERE PrdId = @PrdIdRem)
							SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
						END
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
						@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
						@UomIdRem
						
					END
					CLOSE Cur_Redeem
					DEALLOCATE Cur_Redeem
				END	
				ELSE
				IF (@PrdId > 0 AND @PrdBatId > 0)
				BEGIN
					DECLARE Cur_Redeem Cursor For
						SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,FrmSchAch,FrmUomAch,
						FromQty,UomId FROM @TempBilledCombiAch A, @TempHier B,@TempBilled C
						WHERE B.PrdId = CASE A.PrdId WHEN 0 THEN B.PrdId ELSE A.PrdId END
						AND B.PrdBatId = CASE A.PrdBatId WHEN 0 THEN B.PrdBatId ELSE A.PrdBatId END
						AND B.PrdCtgValMainId = CASE A.PrdCtgValMainId WHEN 0 THEN B.PrdCtgValMainId
						ELSE A.PrdCtgValMainId END AND B.PrdID = C.PrdId AND B.PrdBatId = C.PrdBatId
						AND A.SlabId = @SlabId AND B.PrdId = @PrdId AND B.PrdBatId = @PrdBatId
						ORDER BY FrmSchAch Desc
					OPEN Cur_Redeem
					FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,@PrdCtgValMainIdRem,
						@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,@UomIdRem
					WHILE @@FETCH_STATUS =0
					BEGIN
						WHILE @FrmSchAch > CAST(0 AS NUMERIC(38,6))
						BEGIN
							SET @AssignQty  = 0
							SET @AssignAmount = 0
							SET @AssignKG = 0
							SET @AssignLitre = 0
							SET @AssignKG = (SELECT CASE @FrmUomAchRem WHEN 2 THEN
								(@FrmSchAchRem / 1000) WHEN 3 THEN
								(@FrmSchAchRem) ELSE
								0 END FROM Product WHERE PrdId = @PrdIdRem)
		
							SET @AssignLitre = (SELECT CASE @FrmUomAchRem WHEN 4 THEN
								(@FrmSchAchRem / 1000) WHEN 5 THEN
								(@FrmSchAchRem) ELSE
								0 END FROM Product WHERE PrdId = @PrdIdRem)
							SET @FrmSchAch = @FrmSchAch - @FrmSchAchRem
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
						END
						FETCH NEXT FROM Cur_Redeem INTO @PrdIdRem,@PrdBatIdRem,
						@PrdCtgValMainIdRem,@FrmSchAchRem,@FrmUomAchRem,@FromQtyRem,
						@UomIdRem
					END				CLOSE Cur_Redeem
					DEALLOCATE Cur_Redeem
				END
				FETCH NEXT FROM Cur_Qty INTO @PrdId,@PrdBatId,@PrdCtgValMainId,@FrmSchAch,
					@FrmUomAch,@FromQty,@UomId
			END
			CLOSE Cur_Qty
			DEALLOCATE Cur_Qty
		END
		--To Store the Gross amount for the Scheme billed Product
		SELECT @GrossAmount = ISNULL(SUM(SchemeOnAmount),0) FROM @TempRedeem
		INSERT INTO BilledPrdRedeemedForQPS (RtrId,SchId,PrdId,PrdBatId,SumQty,SumValue,SumInKG,
			SumInLitre,UserId,TransId)
		SELECT @Pi_RtrId,@Pi_SchId,PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,
			SchemeOnLitre,@Pi_UsrId,@Pi_TransId FROM @TempRedeem

		--->Added By Nanda on 29/10/2010
		IF EXISTS(SELECT * FROM @TempSchSlabAmt WHERE DiscPer=0)
		BEGIN
			INSERT INTO @QPSGivenFlat
			SELECT SchId,SUM(FlatAmount)
			FROM
			(
				SELECT DISTINCT SISL.SalId,SISL.SchId,SISL.PrdId,SISL.PrdBatId,ISNULL(FlatAmount,0) AS FlatAmount
				FROM SalesInvoiceSchemeLineWise SISL,SchemeMaster SM,SalesInvoice SI
				WHERE SM.QPS=1 AND FlexiSch=0 
				AND SI.RtrId=@Pi_RtrId AND SI.SalId=SISL.SalId AND SI.DlvSts>3			
			) A
			GROUP BY A.SchId	
		END

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

		SELECT 'SS1',* FROM @QPSGivenFlat

		SELECT @QPSGivenFlatAmt=ISNULL(SUM(Amount),0) FROM @QPSGivenFlat WHERE SchId=@Pi_SchId

		DELETE FROM BillQPSGivenFlat WHERE UserId=@Pi_UsrId AND TransID=@Pi_TransId AND SchId=@Pi_SchId
		INSERT INTO BillQPSGivenFlat(SchId,Amount,UserId,TransId) 
		SELECT SchId,Amount,@Pi_UsrId,@Pi_TransId FROM @QPSGivenFlat
		--->Till Here


		--To Calculate the Scheme Flat Amount and Discount Percentage
		--Scheme Discount for Flat amount = ((FlatAmt * (LineLevel Gross / Total Gross) * 100)/100) * number of times
		--Scheme Discount for Disc Perc   = (LineLevel Gross * Disc Percentage) / 100
--		INSERT INTO @BILLAPPLIEDSCHEMEHD(SCHID,SCHCODE,FLEXISCH,FLEXISCHTYPE,SLABID,SCHEMEAMOUNT,SCHEMEDISCOUNT,
--	 		POINTS,FLXDISC,FLXVALUEDISC,FLXFREEPRD,FLXGIFTPRD,FLXPOINTS,FREEPRDID,
--	 		FREEPRDBATID,FREETOBEGIVEN,GIFTPRDID,GIFTPRDBATID,GIFTTOBEGIVEN,NOOFTIMES,ISSELECTED,SCHBUDGET,
--	 		BUDGETUTILIZED,TRANSID,USRID,PrdId,PrdBatId)
--		SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,
--			SchemeDiscount AS SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
--			FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,
--			IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
--			FROM
--			(
--				SELECT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
--				@SlabId as SlabId,PrdId,PrdBatId,
--				(CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END) As Contri,
--				((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
--				As SchemeAmount,DiscPer AS SchemeDiscount,(Points *@NoOfTimes) as Points,
--				FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,0 as FreePrdId,0 as FreePrdBatId,
--				0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,
--				0 as IsSelected,@SchemeBudget as SchBudget,0 as BudgetUtilized,@Pi_TransId As TransId,
--				@Pi_UsrId as UsrId FROM @TempRedeem , @TempSchSlabAmt
--				WHERE (FlatAmt + DiscPer + FlxDisc + FlxValueDisc + FlxFreePrd + FlxGiftPrd + Points) >=0
--			) AS B
--			GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeDiscount,Points,FlxDisc,FlxValueDisc,
--			FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,
--			GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
		
		IF @QPS=0
		BEGIN
			INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
	 			Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
	 			FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
	 			BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
			SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,
				SchemeDiscount AS SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
				FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,
				IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
				FROM
				(
					SELECT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
					@SlabId as SlabId,PrdId,PrdBatId,
					(CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END) As Contri,
					((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
					As SchemeAmount,DiscPer AS SchemeDiscount,(Points *@NoOfTimes) as Points,
					FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,0 as FreePrdId,0 as FreePrdBatId,
					0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,
					0 as IsSelected,@SchemeBudget as SchBudget,0 as BudgetUtilized,@Pi_TransId As TransId,
					@Pi_UsrId as UsrId FROM @TempRedeem , @TempSchSlabAmt
					WHERE (FlatAmt + DiscPer + FlxDisc + FlxValueDisc + FlxFreePrd + FlxGiftPrd + Points) >=0
				) AS B
				GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeDiscount,Points,FlxDisc,FlxValueDisc,
				FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,
				GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
		END
		ELSE
		BEGIN

			SELECT 'S1',* FROM @TempSchSlabAmt
--			SELECT 'S2',* FROM @TempRedeem

--			SELECT 'S1',* FROM @TempSchSlabAmt

			UPDATE @TempSchSlabAmt SET FlatAmt=FlatAmt-@QPSGivenFlatAmt

			INSERT INTO @BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
	 			Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
	 			FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
	 			BudgetUtilized,TransId,Usrid,PrdId,PrdBatId)
			SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount) AS SchemeAmount,
				SchemeDiscount AS SchemeDiscount,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,
				FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,
				IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
				FROM
				(
					SELECT @Pi_SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
					@SlabId as SlabId,PrdId,PrdBatId,
					(CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END) As Contri,
					((FlatAmt * (CASE @GrossAmount WHEN 0 THEN 0 ELSE (SchemeOnAmount / @GrossAmount) * 100 END))/100) * @NoOfTimes
					As SchemeAmount,DiscPer AS SchemeDiscount,(Points *@NoOfTimes) as Points,
					FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,0 as FreePrdId,0 as FreePrdBatId,
					0 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,
					0 as IsSelected,@SchemeBudget as SchBudget,0 as BudgetUtilized,@Pi_TransId As TransId,
					@Pi_UsrId as UsrId FROM @TempRedeem , @TempSchSlabAmt
					WHERE (FlatAmt + DiscPer + FlxDisc + FlxValueDisc + FlxFreePrd + FlxGiftPrd + Points) >=0
				) AS B
				GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeDiscount,Points,FlxDisc,FlxValueDisc,
				FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,
				GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId
		END

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
					(CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END )
				WHEN 2 THEN 
					(CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END)
				WHEN 3 THEN
					(CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END)
			END
			as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
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
		UPDATE @TempBilledQPSReset Set FrmSchach = A.FrmSchAch - B.FrmSchAch
			FROM @TempBilledQPSReset A INNER JOIN @TempBilledCombiAch B
			ON A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId AND
			A.PrdCtgValMainId = B.PrdCtgValMainId
		DELETE FROM @TempBilledCombiAch
		INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
		SELECT A.* FROM @TempBilledQPSReset A
			INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
			WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId AND A.PrdBatId = B.PrdBatId
			AND A.PrdCtgValMainId = B.PrdCtgValMainId  AND B.SchId = @Pi_SchId
		SELECT @SlabId = ISNULL(MAX(A.SlabId),0)  FROM
			(SELECT COUNT(SlabId) AS CntAch,SlabId FROM @TempBilledCombiAch GROUP BY SlabId) AS A
			INNER JOIN
			(SELECT COUNT(SlabId) AS CntSch,SlabId FROM SchemeSlabCombiPrds WHERE SchId = @Pi_SchId
			GROUP BY SlabId) AS B ON A.SlabId = B.SlabId AND A.CntAch = B.CntSch
		DELETE FROM @TempBilledCombiAch
		INSERT INTO @TempBilledCombiAch(PrdId,PrdBatId,PrdCtgValMainId,FrmSchAch,FrmUomAch,SlabId,FromQty,UomId)
		SELECT B.PrdId,B.PrdBatId,B.PrdCtgValMainId,B.SlabValue,A.FrmUomAch,@SlabId,B.SlabValue,A.FrmUomAch
			FROM @TempBilledAch A INNER JOIN SchemeSlabCombiPrds B ON A.SlabId = B.SlabId
			AND B.SlabId = @SlabId WHERE A.FrmSchAch >= B.SlabValue AND A.PrdId = B.PrdId
			AND A.PrdBatId = B.PrdBatId AND A.PrdCtgValMainId = B.PrdCtgValMainId
			AND B.SchId = @Pi_SchId
		
		DELETE FROM @TempSchSlabAmt
		DELETE FROM @TempSchSlabFree
	END

	SELECT 'N1',* FROM @BillAppliedSchemeHd

SELECT 'N21',* FROM BillAppliedSchemeHd
INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
	Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
	FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
	BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
SELECT SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SUM(SchemeAmount),SUM(SchemeDiscount),
	SUM(Points),FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
	FreePrdBatId,SUM(FreeToBeGiven),GiftPrdId,GiftPrdBatId,SUM(GiftToBeGiven),SUM(NoOfTimes),
	IsSelected,SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,0 FROM @BillAppliedSchemeHd
	GROUP BY SchId,SchCode,FlexiSch,FlexiSchType,SlabId,FlxDisc,FlxValueDisc,FlxFreePrd,
	FlxGiftPrd,FlxPoints,FreePrdId,FreePrdBatId,GiftPrdId,GiftPrdBatId,IsSelected,
	SchBudget,BudgetUtilized,TransId,Usrid,PrdId,PrdBatId

SELECT 'N22',* FROM BillAppliedSchemeHd
------
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
	SELECT * FROM BillAppliedSchemeHd 
	EXEC Proc_ApplySchemeInBill_Temp @Pi_SchId,@SlabId,@Pi_UsrId,@Pi_TransId
	UPDATE BillAppliedSchemeHd SET BudgetUtilized = ISNULL(@BudgetUtilized,0),
	SchBudget = ISNULL(@SchemeBudget,0) WHERE SchId = @Pi_SchId AND
	TransId = @Pi_TransId AND Usrid = @Pi_UsrId

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
		END
	END
	--Till Here
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-187-013

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
		(SchemeAmount * (CASE B.GrossAmount WHEN 0 THEN 0 ELSE (C.GrossAmount / B.GrossAmount) * 100 END))/100
		--(SchemeAmount * (CASE B.QPSGrossAmount WHEN 0 THEN 0 ELSE (C.QPSGrossAmount / B.QPSGrossAmount) * 100 END))/100
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
	SELECT A.SchId,SUM(SchemeDiscount)-ISNULL(B.Amount,0) 
	FROM ApportionSchemeDetails A
	INNER JOIN SchemeMaster	SM ON A.SchId=SM.SchId AND SM.QPS=1
	LEFT OUTER JOIN @QPSGivenDisc B ON A.SchId=B.SchId 
	GROUP BY A.SchId,B.Amount 

	SELECT * FROM @QPSNowAvailable

--	UPDATE ApportionSchemeDetails SET SchemeDiscount=Contri*Amount/100
--	FROM @QPSNowAvailable A WHERE ApportionSchemeDetails.SchId=A.SchId	

	SELECT * FROM ApportionSchemeDetails
	SELECT * FROM BillQPSSchemeAdj

	UPDATE A SET A.Contri=100*(B.QPSGrossAmount/CASE C.QPSGrossAmount WHEN 0 THEN 1 ELSE C.QPSGrossAmount END)	
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

	UPDATE ASD SET SchemeAmount=Contri*AdjAmount/100,SchemeDiscount=(CASE SM.CombiSch+SM.QPS WHEN 2 THEN 0 ELSE SchemeDiscount END)
	FROM ApportionSchemeDetails ASD,BillQPSSchemeAdj A,SchemeMaster SM 
	WHERE ASD.SchId=A.SchId AND SM.SchId=A.SchId
	AND ASD.UsrId=A.UserId AND ASD.TransId=A.TransId	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-187-014

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_WDSBudgetValues]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_WDSBudgetValues]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_WDSBudgetValues 0
SELECT * FROM Cn2Cs_Prk_WDSBudgetValues
--SELECT * FROM errorlog
SELECT * FROM SchemeBudgetValues
--DELETE FROM errorlog
ROLLBACK TRANSACTION
*/
CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_WDSBudgetValues]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_WDSBudgetValues
* PURPOSE		: To download the possible budget values for WDS
* CREATED		: Nandakumar R.G
* CREATED DATE	: 30/07/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
*********************************/
SET NOCOUNT ON
BEGIN
	DECLARE @TabName		NVARCHAR(100)
	DECLARE @ErrDesc		NVARCHAR(1000)
	DECLARE @CmpSchCode 	NVARCHAR(50)
	DECLARE @ClusterName  	NVARCHAR(100)
	DECLARE @Remarks	  	NVARCHAR(200)
	DECLARE @Salesman		NVARCHAR(10)
	DECLARE @Retailer		NVARCHAR(10)
	DECLARE @AddMast1  		NVARCHAR(10)
	DECLARE @AddMast2  		NVARCHAR(10)
	DECLARE @AddMast3  		NVARCHAR(10)
	DECLARE @AddMast4  		NVARCHAR(10)
	DECLARE @AddMast5  		NVARCHAR(10)
	DECLARE @ClusterId  	INT
	DECLARE @Exist		 	INT
	SET @TabName = 'Cn2Cs_Prk_WDSBudgetValues'
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'WDSToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE WDSToAvoid	
	END
	CREATE TABLE WDSToAvoid
	(
		CmpSchCode NVARCHAR(50)
	)	
	IF EXISTS(SELECT DISTINCT CmpSchCode FROM Cn2Cs_Prk_WDSBudgetValues
	WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchemeMaster))
	BEGIN
		INSERT INTO WDSToAvoid(CmpSchCode)
		SELECT DISTINCT CmpSchCode FROM Cn2Cs_Prk_WDSBudgetValues
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchemeMaster)
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Scheme Budget','CmpSchCode','Scheme Code:'+CmpSchCode+' not available' FROM Cn2Cs_Prk_WDSBudgetValues		
		WHERE CmpSchCode NOT IN (SELECT CmpSchCode FROM SchemeMaster)
	END		
	DELETE FROM SchemeBudgetValues WHERE SchId IN 
	(SELECT Sch.SchId FROM Cn2Cs_Prk_WDSBudgetValues Prk
	INNER JOIN SchemeMaster Sch ON Prk.CmpSchCode=Sch.CmpSchCode 
	WHERE [DownLoadFlag] ='D' AND Prk.CmpSchCode NOT IN (SELECT CmpSchCode FROM WDSToAvoid)
	AND ISNULL(Prk.BudgetValue,0)>0)

	INSERT INTO SchemeBudgetValues(SchId,BudgetValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT DISTINCT Sch.SchId,Prk.BudgetValue,1,1,GETDATE(),1,GETDATE()
	FROM Cn2Cs_Prk_WDSBudgetValues Prk
	INNER JOIN SchemeMaster Sch ON Prk.CmpSchCode=Sch.CmpSchCode 
	WHERE [DownLoadFlag] ='D' AND Prk.CmpSchCode NOT IN (SELECT CmpSchCode FROM WDSToAvoid)
	AND ISNULL(Prk.BudgetValue,0)>0

	--->Added By Nanda 30/12/2010
	INSERT INTO SchemeBudgetValues(SchId,BudgetValue,Availability,LastModBy,LastModDate,AuthId,AuthDate)
	SELECT DISTINCT SchId,0,1,1,GETDATE(),1,GETDATE() FROM SchemeBudgetValues 
	WHERE SchId NOT IN (SELECT SchId FROM SchemeBudgetValues WHERE BudgetValue= 0)
	--->Till Here

	UPDATE Cn2Cs_Prk_WDSBudgetValues SET DownLoadFlag='Y' WHERE 
	DownLoadFlag ='D' AND CmpSchCode NOT IN (SELECT CmpSchCode FROM WDSToAvoid)
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-187-015

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[View_ItemPriceList]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[View_ItemPriceList]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     VIEW [dbo].[View_ItemPriceList]
/************************************************************
* VIEW	: View_ItemPriceList
* PURPOSE	: To get Price lists of Products
* CREATED BY	: Swapneswar Sharma
* CREATED DATE	: 30/07/2007
* NOTE		:
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*************************************************************/
AS
SELECT P.PrdId, P.PrdDCode, P.PrdName,PB.PrdBatId, PB.PrdBatCode,PBD.PriceID,PBD.PriceCode,PBD.PrdBatDetailValue,
	 P.CmpId,C.CmpName,P.PrdStatus,PB.Status AS PrdBatStatus,BC.FieldDesc
  FROM Product P WITH(NOLOCK),
       ProductBatch PB WITH(NOLOCK),
       BatchCreation BC WITH(NOLOCK),
       ProductBatchDetails PBD WITH(NOLOCK),
       Company C WITH(NOLOCK)
  WHERE P.PrdId =  PB.PrdId
        AND PB.BatchSeqId = BC.BatchSeqId
        AND BC.SlNo = PBD.SLNo
        AND PB.PrdBatId = PBD.PrdBatId
	AND P.CmpId=C.CmpId AND PBD.DefaultPrice=1


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-187-016

if not exists (select * from dbo.sysobjects where id = object_id(N'[SalesReturnDbNoteAlert]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE SalesReturnDbNoteAlert
	(
		SalId				INT,
		SchId				INT,
		SlabId				INT,
		PrdId				INT,
		PrdBatId			INT,
		RowId				INT,
		SchDiscAmt			NUMERIC(18,6),
		SchFlatAmt			NUMERIC(18,6),
		SchPoints			NUMERIC(18,6),
		AlertMode			INT,
		Usrid				INT,
		TransId				INT
) ON [PRIMARY]	
end
go

--SRF-Nanda-187-017

if not exists (select * from dbo.sysobjects where id = object_id(N'[ReturnSchemeDbNote]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	CREATE TABLE ReturnSchemeDbNote
	(
		ReturnId		BIGINT,
		DbNoteNumber	NVARCHAR(25),
		SalId			BIGINT,
		SchId			INT,
		SlabId			INT,
		PrdId			INT,
		PrdBatId		INT,
		FlatAmount		NUMERIC(38,6), 
		DiscAmount		NUMERIC(38,6), 
		Points			NUMERIC(38,0), 
		SelcMode		INT
	) ON [PRIMARY]	
end
go

--SRF-Nanda-187-018

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FK_ReturnSchemeDbNote_ReturnId]') and OBJECTPROPERTY(id, N'IsForeignKey') = 1)
ALTER TABLE [dbo].[ReturnSchemeDbNote] DROP CONSTRAINT [FK_ReturnSchemeDbNote_ReturnId]
GO
ALTER TABLE [dbo].[ReturnSchemeDbNote] ADD 
	CONSTRAINT [FK_ReturnSchemeDbNote_ReturnId] FOREIGN KEY 
	(
		[ReturnId]
	) REFERENCES [dbo].[ReturnHeader] 
	(
		[ReturnId]
	)
GO

--SRF-Nanda-187-019

if not exists (Select Id,name from Syscolumns where name = 'PrdId' and id in (Select id from 
	Sysobjects where name ='ReturnSchemePointsDt'))
begin
	ALTER TABLE [dbo].[ReturnSchemePointsDt]
	ADD [PrdId] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

if not exists (Select Id,name from Syscolumns where name = 'PrdBatId' and id in (Select id from 
	Sysobjects where name ='ReturnSchemePointsDt'))
begin
	ALTER TABLE [dbo].[ReturnSchemePointsDt]
	ADD [PrdBatId] INT NOT NULL DEFAULT 0 WITH VALUES
END
GO

--SRF-Nanda-187-020

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PK_SalesInvoiceSchemeDtPoints_SalId_SchId_SlabId_SchType]') 
and OBJECTPROPERTY(id, N'IsPrimaryKey') = 1)
begin
	ALTER TABLE [dbo].[SalesInvoiceSchemeDtPoints] 
	DROP CONSTRAINT [PK_SalesInvoiceSchemeDtPoints_SalId_SchId_SlabId_SchType]
end
go

--SRF-Nanda-187-021

DELETE FROM dbo.DependencyTable WHERE PrimaryTable='ReturnHeader' AND RelatedTable='ReturnSchemeDbNote' AND FieldName='ReturnId'
INSERT INTO DependencyTable (PrimaryTable,RelatedTable,FieldName)
VALUES ('ReturnHeader','ReturnSchemeDbNote','ReturnId')

DELETE FROM dbo.DependencyTable WHERE PrimaryTable='DebitNoteRetailer' AND RelatedTable='ReturnSchemeDbNote' AND FieldName='DbNoteNumber'
INSERT INTO DependencyTable (PrimaryTable,RelatedTable,FieldName)
VALUES ('DebitNoteRetailer','ReturnSchemeDbNote','DbNoteNumber')

DELETE FROM dbo.DependencyTable WHERE PrimaryTable='Product' AND RelatedTable='ReturnSchemeDbNote' AND FieldName='PrdId'
INSERT INTO DependencyTable (PrimaryTable,RelatedTable,FieldName)
VALUES ('Product','ReturnSchemeDbNote','PrdId')

DELETE FROM dbo.DependencyTable WHERE PrimaryTable='ProductBatch' AND RelatedTable='ReturnSchemeDbNote' AND FieldName='PrdBatId'
INSERT INTO DependencyTable (PrimaryTable,RelatedTable,FieldName)
VALUES ('ProductBatch','ReturnSchemeDbNote','PrdBatId')

DELETE FROM dbo.DependencyTable WHERE PrimaryTable='SalesInvoice' AND RelatedTable='ReturnSchemeDbNote' AND FieldName='SalId'
INSERT INTO DependencyTable (PrimaryTable,RelatedTable,FieldName)
VALUES ('SalesInvoice','ReturnSchemeDbNote','SalId')

--SRF-Nanda-187-022

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_ApplyReturnScheme]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_ApplyReturnScheme]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
BEGIN TRANSACTION
EXEC [Proc_ApplyReturnScheme] 2,1,23
SELECT * FROM UserFetchReturnScheme 
-- DELETE FROM UserFetchReturnScheme
-- SELECT * FROM SalesInvoiceSchemeLineWise WHERE SalId=11865
-- SELECT * FROM ApportionSchemeDetails
-- SELECT * FROM BillAppliedSchemeHd WHERE TransId=3 AND usrId=2
-- DELETE FROM ApportionSchemeDetails
-- DELETE FROM BillAppliedSchemeHd
-- DELETE FROM ReturnPrdHdForScheme
-- SELECT * FROM ReturnPrdHdForScheme
ROLLBACK TRANSACTION
*/

CREATE PROCEDURE [dbo].[Proc_ApplyReturnScheme]
(
	@Pi_SalId int,
	@Pi_Usrid as int,
	@Pi_TransId as int
)
/******************************************************************************************
* PROCEDURE	: Proc_ApplyReturnScheme
* PURPOSE	: To Apply the Return Scheme and Get the Scheme Details for the Selected Scheme
* CREATED	: Boopathy
* CREATED DATE	: 01/06/2007
* NOTE		: General SP for Returning the Scheme Details for the all type of Schemes
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
-------------------------------------------------------------------------------------------
* {date}		{developer}			{brief modification description}	
* 25/07/2009	Panneerselvam.k		Solve the Divied  By Zero Error
******************************************************************************************/
AS
SET NOCOUNT ON
BEGIN	
	DECLARE @Config		INT
	SET @Config=-1

	IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='SALESRTN18' AND Status=1)
	BEGIN
		SET @Config=0 
	END
	ELSE IF EXISTS (SELECT * FROM Configuration WHERE ModuleId='SALESRTN19' AND Status=1)
	BEGIN
		SET @Config=1
	END
	ELSE
	BEGIN
		SET @Config=-1
	END
	
	DECLARE @SchId				INT
	DECLARE @SlabId				INT
	DECLARE @PurOfEveryReq		INT
	DECLARE @NoOfTimes			NUMERIC(38,6)
	DECLARE @SchType			INT
	DECLARE @ProRata			INT
	DECLARE @RtrId				INT
	DECLARE @CurSlabId			INT
	DECLARE @PrdId				INT
	DECLARE @PrdbatId			INT
	DECLARE @RowId				INT
	DECLARE @Combi				INT
	DECLARE @SchCode			VARCHAR(100)
	DECLARE @FlexiSch			INT
	DECLARE @FlexiSchType		INT
	DECLARE @SchemeBudget		NUMERIC(18,6)
	DECLARE @SchLevelId			INT
	DECLARE @SchemeLvlMode		INT

	DECLARE @TempHier TABLE
	(
		PrdId				INT,
		PrdBatId			INT,
		PrdCtgValMainId		INT
	)

	DECLARE @TempBilledAchCombi TABLE
	(
		PrdId				INT,
		PrdBatId			INT,
		PrdCtgValMainId		INT,
		FrmSchAch			NUMERIC(38,6),
		FrmUomAch			INT,
		SlabId				INT,
		FromQty				NUMERIC(38,6),
		UomId				INT
	)
	DECLARE @SchEligiable TABLE
	(
		ManType			INT,
		Cnt				INT,
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId	INT,
		FrmSchAch 		NUMERIC(38,6),
		NoOfTimes		NUMERIC(38,6),
		SchId			INT,
		SlabId			INT
	)
	DECLARE @TempBilled TABLE
	(
		PrdId				INT,
		PrdBatId			INT,
		SchemeOnQty 		NUMERIC(38,0),
		SchemeOnAmount		NUMERIC(38,6),
		SchemeOnKG			NUMERIC(38,6),
		SchemeOnLitre		NUMERIC(38,6),
		SchId 				INT
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
	DECLARE @TempBilledCombiAch TABLE
	(
		PrdId			INT,
		PrdBatId		INT,
		PrdCtgValMainId		INT,
		FrmSchAch		NUMERIC(38,6),
		FrmUomAch		INT,
		SlabId			INT,
		FromQty			NUMERIC(38,6),
		UomId			INT
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
		SchId			INT,
		SlabId			INT,
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
	DECLARE @FreePrdDt TABLE
	(
		SalId			INT,
		SchId			INT,
		SlabId			INT,
		FreeQty			INT,
		FreePrdId		INT,
		FreePrdBatId	INT,
		FreePriceId		INT,
		GiftQty			INT,
		GiftPrdId		INT,
		GiftPrdBatId	INT,
		GiftPriceId		INT,
		PrdId			INT,
		PrdBatId		INT,
		RowId			INT
		
	)
	DECLARE @ReturnPrdHdForScheme TABLE
	(
		RowId		int,
		RtrId		int,
		PrdId		int,
		PrdBatId	int,
		SelRate		numeric(18,6),
		BaseQty		int,
		GrossAmount	numeric(18,6),
		TransId		tinyint,
		Usrid		int,
		SalId		bigint,
		RealQty		int,
		MRP			numeric(18,6)
	)
	DECLARE @t1 TABLE
	(
		SalId		INT,
		SchId		INT,
		PrdId		INT,
		PrdBatId	INT,
		FlatAmt		NUMERIC(38,6),
		DiscPer		NUMERIC(38,6),
		Points		INT,
		NoofTimes	INT
	)
	DECLARE @TempSch1 Table
	(
		SalId		INT,
		RowId		INT,
		PrdId		INT,
		PrdBatId	INT,
		BaseQty		NUMERIC(38,6),
		Selrate		NUMERIC(38,6),
		Grossvalue	NUMERIC(38,6),
		Schid		INT,
		Slabid		INT,
		Discper		NUMERIC(38,6),
		Flatamt		NUMERIC(38,6),
		Points		NUMERIC(38,6),
		NoofTimes	NUMERIC(38,6)
	)
	DECLARE @TempSch2 Table
	(
		SalId			INT,
		RowId			INT,
		PrdId			INT,
		PrdBatId		INT,
		Schid			INT,
		Slabid			INT,
		SchemeAmount	NUMERIC(38,6),
		SchemeDiscount	NUMERIC(38,6),
		Points			NUMERIC(38,6),
		Contri			NUMERIC(38,6),
		NoofTimes		NUMERIC(38,6)
	)
	DECLARE @MaxSchDt TABLE
	(
		SalId		INT,
		SchId		INT,
		SlabId		INT,
		RowId		INT,
		PrdId		INT,
		PrdBatId	INT,
		SchAmt		NUMERIC(38,6)
	)
	DECLARE @SchGross TABLE
	(
		SchId	INT,
		Amt		NUMERIC(38,6)
	)

	--Apportion scheme amt prd wise
	DECLARE @DiscPer	NUMERIC(38,6)
	DECLARE @FlatAmt	NUMERIC(38,6)
	DECLARE @Points		INT
	DECLARE @SumValue	NUMERIC(38,6)
	DECLARE @FreePrd	INT
	DECLARE @GiftPrd	INT
	DECLARE @MaxPrdId	INT
	DECLARE @SalId		INT
	DECLARE @RefCode	VARCHAR(2)
	DECLARE @CombiSch	INT
	DECLARE @QPS		INT
	DECLARE @BillCnt	INT
	DECLARE @SchCnt		INT
	DECLARE @TempSlabId	INT
	DECLARE @Cnt1	AS	INT
	DECLARE @Cnt2	AS	INT
	DECLARE @FlatChk1 AS INT
	DECLARE @FlatChk2 AS INT
	DELETE FROM SalesReturnDbNoteAlert WHERE SalId=@Pi_SalId
	IF @Config=0
	BEGIN
		DELETE FROM UserFetchReturnScheme WHERE SalId=@Pi_SalId AND Usrid=@Pi_Usrid AND TransId=@Pi_TransId

		INSERT INTO UserFetchReturnScheme(SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,FreeQty,
		FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId)
		SELECT SI.SalId,RPS.PrdId,RPS.PRdBatId,SIL.SchId,SIL.SlabId,
		((SIL.DiscountPerAmount-SIL.PrimarySchemeAmt-SIL.ReturnDiscountPerAmount)/(SIP.BaseQty-SIP.ReturnedQty))*(RPS.RealQty),
		((SIL.FlatAmount-SIL.ReturnFlatAmount)/(SIP.BaseQty-SIP.ReturnedQty))*(RPS.RealQty),0,0,0,0,0,0,0,0,@Pi_Usrid,@Pi_TransId,RPS.RowId,0,0
		FROM SalesInvoice SI INNER JOIN SalesInvoiceProduct SIP ON SI.SalId=SIP.SalId
		INNER JOIN SalesInvoiceSchemeLineWise SIL ON SIL.SalId=SIP.SalId AND SIP.PrdId=SIL.PrdId 
		AND SIP.PrdBatId=SIL.PrdBatId AND SIP.Slno=SIL.RowId INNER JOIN
		ReturnPrdHdForScheme RPS ON RPS.PrdId=SIP.PrdId AND RPS.PrdBatId=SIP.PrdBatId AND RPS.SalId=SI.SalId AND RPS.RtrId=SI.RtrId 
		WHERE SI.SalId=@Pi_SalId AND usrid = @Pi_Usrid AND TransId = @Pi_TransId

		SELECT @RtrId=RtrId FROM SalesInvoice WHERE SalId=@Pi_SalId

		INSERT INTO ReturnPrdHdForScheme
		SELECT A.Slno,@RtrId,A.Prdid,A.PrdBatId,A.PrdUnitSelRate,A.BaseQty-A.ReturnedQty,
		(A.BaseQty-A.ReturnedQty)*A.PrdUnitSelRate,@Pi_TransId,@Pi_UsrId,@Pi_SalId,0,A.PrdUnitMRP
		FROM SalesInvoiceProduct A (NOLOCK) INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
		A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
		WHERE A.SalId=@Pi_SalId AND A.PrdId NOT IN (SELECT Distinct PrdId FROM ReturnPrdHdForScheme
		WHERE usrid = @Pi_Usrid AND TransId = @Pi_TransId AND SalId = @Pi_SalId )


		DECLARE SchemeFreeCur CURSOR FOR
		SELECT DISTINCT SchId,SlabId FROM SalesInvoiceSchemeDtFreePrd WHERE SalId=@Pi_SalId
		OPEN SchemeFreeCur
		FETCH NEXT FROM SchemeFreeCur INTO @SchId,@CurSlabId
		WHILE @@fetch_status= 0
		BEGIN		

			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery,@SchLevelId = SchLevelId,
			@SchemeLvlMode = SchemeLvlMode FROM SchemeMaster WHERE SchId=@SchId


			SELECT @RowId=MIN(RowId)  FROM ReturnPrdHdForScheme WHERE  
			TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId

			SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM ReturnPrdHdForScheme WHERE  
			TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId AND RowId=@RowId

			INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,FreeQty,
			GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
			SELECT A.SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,CEILING((FreeQty/A.BaseQty)*SUM(B.RealQty)),
			0 AS GiftQty,0 AS GiftPrdId,0 AS GiftPrdBatId,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM
			(SELECT A.SalId,A.SchId,A.SlabId,A.FreePrdId,A.FreePrdBatId,(A.FreeQty-A.ReturnFreeQty) AS FreeQty,A.FreePriceId,
			SUM((B.BaseQty-B.ReturnedQty)) AS BaseQty FROM SalesInvoiceSchemeDtFreePrd A INNER JOIN 
			SalesInvoiceProduct B ON A.SalId=B.SalId INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) C 
			ON B.PrdId=C.PrdId AND B.PrdBatId = CASE C.PrdBatId WHEN 0 THEN B.PrdBatId ELSE C.PrdBatId End 
			WHERE A.SchId=@SchId AND A.SlabId=@CurSlabId AND A.SalId=@Pi_SalId
			GROUP BY A.SalId,A.SchId,A.SlabId,A.FreePrdId,A.FreePrdBatId,A.FreeQty,A.ReturnFreeQty,A.FreePriceId) AS A
			INNER JOIN ReturnPrdHdForScheme B ON A.SalId=B.SalId
			WHERE usrid = @Pi_Usrid AND TransId = @Pi_TransId AND A.SalId=@Pi_SalId
			GROUP BY A.SalId,SchId,SlabId,FreePrdId,FreePrdBatId,FreePriceId,FreeQty,A.BaseQty

			FETCH NEXT FROM SchemeFreeCur INTO @schid,@CurSlabId
		END
		CLOSE SchemeFreeCur
		DEALLOCATE SchemeFreeCur

		DELETE FROM UserFetchReturnScheme WHERE (DiscAmt+FlatAmt+Points+FreeQty+GiftQty)<=0

		IF EXISTS(SELECT * FROM @FreePrdDt)
		BEGIN
			IF EXISTS (SELECT * FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
				FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId)
				SELECT DISTINCT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
				FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
				RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 
				WHERE SchId NOT IN (SELECT SchId FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			END
			ELSE
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
				FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId)
				SELECT DISTINCT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
				FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
				RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 	
			END
			DELETE FROM UserFetchReturnScheme WHERE (DiscAmt+FlatAmt+Points+FreeQty+GiftQty)=0
		END	
	END
	ELSE IF @Config=1
	BEGIN
		DECLARE SchemeCur CURSOR FOR
		SELECT DISTINCT C.SchId,C.CombiSch,C.QPS FROM SalesInvoiceSchemeLineWise a 
		INNER JOIN SchemeMaster C ON C.SchId = a.SchId WHERE A.SalId=@Pi_SalId
		UNION
		SELECT DISTINCT C.SchId,C.CombiSch,C.QPS FROM SalesInvoiceSchemeDtPoints a 
		INNER JOIN SchemeMaster C ON C.SchId = a.SchId WHERE A.SalId=@Pi_SalId
		OPEN SchemeCur
		FETCH NEXT FROM SchemeCur into @SchId,@CombiSch,@QPS 
		WHILE @@FETCH_STATUS= 0
		BEGIN
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery,@SchLevelId = SchLevelId,
			@SchemeLvlMode = SchemeLvlMode FROM SchemeMaster WHERE SchId=@SchId

			DELETE FROM @TempBilled
			DELETE FROM @TempBilledAch
			DELETE FROM @TempBilledAchCombi				
			DELETE FROM @TempBilledCombiAch

			SET @SlabId=0
			UPDATE A SET A.BASEQTY=(B.BaseQty-B.ReturnedQty)-A.RealQty FROM ReturnPrdHdForScheme A INNER JOIN 
			SalesInvoiceProduct B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdbatId
			WHERE B.SalId=@Pi_SalId  AND A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BaseQty=0

			SELECT @Cnt1=COUNT(A.PrdId) FROM ReturnPrdHdForScheme A 
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
			AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId

			SELECT @Cnt2=COUNT(PrdId) FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@SchId
			SELECT -1 As Mode,PrdId,PrdBatId,SUM(B.BaseQty-B.ReturnedQty) AS BaseQty INTO #tempBilledPrd 
			FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId GROUP BY PrdId,PrdBatId

			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty),0) END AS SchemeOnQty,
				CASE E.Mode 
				WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty * A.SelRate),0) END AS SchemeOnAmount,
				ISNULL
				(
					(CASE D.PrdUnitId 
					WHEN 2 THEN 
						(CASE E.Mode 
						WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
					WHEN 3 THEN 
						(CASE E.Mode WHEN 0 THEN 0 ELSE (ISNULL(SUM(PrdWgt * A.BaseQty),0)) END) 
				 END),0)					
					AS SchemeOnKg,
				ISNULL
				(
					(CASE D.PrdUnitId 
						WHEN 4 THEN 
							(CASE E.Mode 
									WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
						WHEN 5 THEN 
							(CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0) END)
				 END),0) AS SchemeOnLitre,@SchId
				FROM ReturnPrdHdForScheme A INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C ON A.PrdId = C.PrdId
				INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
				INNER JOIN #tempBilledPrd E ON A.PrdId=E.PrdId AND A.PrdbatId=E.PrdBatId
				WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BASEQTY>0
				GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId	,E.Mode	
			UNION
				SELECT PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,SchId FROM 
				(SELECT DISTINCT E.PrdId,E.PrdBatId,ISNULL(SUM(E.BaseQty-E.ReturnedQty),0) AS SchemeOnQty,
					ISNULL(SUM(E.BaseQty * E.PrdUnitSelRate),0) AS SchemeOnAmount,
					ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnKg,
					ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnLitre,@SchId As SchId
					FROM SalesInvoiceProduct E INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON B.PrdId=E.PrdId AND E.SalId=@Pi_SalId
					AND E.PrdBatId = CASE B.PrdBatId WHEN 0 THEN E.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C ON E.PrdId = C.PrdId
					INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId 
					GROUP BY E.PrdId,E.PrdBatId,D.PrdUnitId) A WHERE NOT EXISTS (SELECT PrdId,PrdBatId FROM ReturnPrdHdForScheme B
					WHERE A.PrdId=B.Prdid AND A.PrdbatId=B.PrdBatId)

			--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
			INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
			SELECT ISNULL(CASE @SchType
				WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
			-- 	WHEN 1 THEN SUM(CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
				WHEN 2 THEN SUM(SchemeOnAmount)
				WHEN 3 THEN (CASE A.UomId
						WHEN 2 THEN SUM(SchemeOnKg) * 1000
						WHEN 3 THEN SUM(SchemeOnKg)
						WHEN 4 THEN SUM(SchemeOnLitre) * 1000
						WHEN 5 THEN SUM(SchemeOnLitre)	END)
					END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
				ISNULL(CASE @SchType
				WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
			-- 	WHEN 1 THEN SUM(CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
				WHEN 2 THEN SUM(SchemeOnAmount)
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
				SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
					INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId
					WHERE
				A.FrmSchAch >= B.FromQty AND
				A.ToSchAch <= (CASE B.ToQty WHEN 0 THEN A.ToSchAch ELSE B.ToQty END)
					ORDER BY A.SlabId DESC) As SlabId
		
			SET @SlabId= ISNULL(@SlabId,0)
			--Store the Slab Amount Details into a temp table
			INSERT INTO @TempSchSlabAmt (ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,
				FlxFreePrd,FlxGiftPrd,FlxPoints)
			SELECT ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints
				FROM SchemeSlabs WHERE Schid = @SchId And SlabId = @SlabId
			
			IF @SlabId> 0 
			BEGIN
				--To Get the Number of Times the Scheme should apply
				IF @PurOfEveryReq = 0
				BEGIN
					SET @NoOfTimes = 1
				END
				ELSE
				BEGIN
				
					SELECT @NoOfTimes = A.FrmSchAch / (CASE B.ForEveryQty WHEN 0 THEN 1 ELSE B.ForEveryQty END) FROM
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
			END
			ELSE
			BEGIN
				SET @NoOfTimes =1
			END

			INSERT INTO @TempSch1 (SalId,RowId,PrdId,PrdBatId,BaseQty,Selrate,Grossvalue,Schid,Slabid,
			Discper,Flatamt,Points,NoofTimes)
   			SELECT DISTINCT a.SalId,a.RowId,C.PrdId,a.PrdBatId,
			CASE A1.BaseQty WHEN 0 THEN A1.RealQty ELSE A1.BaseQty END,a1.SelRate,--A1.BaseQty*a1.SelRate,
			CASE A1.BaseQty WHEN 0 THEN a1.RealQty ELSE A1.BaseQty END *a1.SelRate,
			@SchId,D.SlabId,(d.DiscPer+d.FlxDisc),(d.FlatAmt-d.FlxValueDisc),
			D.Points+D.FlxPoints,@NoOfTimes FROM SalesInvoiceSchemeLineWise A 
			INNER JOIN ReturnPrdHdForScheme a1 ON A.PrdId=a1.PrdId AND a.PrdBatId=a1.PrdbatId 
			AND A.SalId=a1.SalId and a1.Usrid = @Pi_Usrid AND a1.TransId = @Pi_TransId 
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END
			INNER JOIN SchemeSlabs d ON d.SchId=A.SchId AND D.SchId=@SchId AND D.SlabId=@SlabId
			INNER JOIN SalesInvoiceProduct G ON A.PrdId=G.PrdId AND A.PrdBatId=G.PrdBatId AND G.SalId=a.SalId
			WHERE a.SalId= @Pi_SalId

			IF @SlabId>0 
			BEGIN
				SELECT @DiscPer = (SELECT ROUND(ISNULL(SUM(b.DiscountPerAmount-b.ReturnDiscountPerAmount),0),5) FROM SalesInvoiceSchemeLineWise b WHERE
					b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.DiscountPerAmount-b.ReturnDiscountPerAmount)>0)
				
				SELECT @FlatAmt = (SELECT ROUND(ISNULL(SUM(b.FlatAmount-b.ReturnFlatAmount),0),5) FROM SalesInvoiceSchemeLineWise b WHERE
					b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.FlatAmount-b.ReturnFlatAmount)>0) 
				
				SELECT @Points = (SELECT ISNULL(Sum(b.Points-b.ReturnPoints),0) FROM dbo.SalesInvoiceSchemeDtPoints b WHERE
					b.SalId = @Pi_SalId AND b.SchId = @SchId AND (b.Points-b.ReturnPoints)>0)
				SELECT @SumValue = (SELECT Sum(Grossvalue) FROM @TempSch1 WHERE SalId = @Pi_SalId AND SchId = @SchId)

				IF @DiscPer>0 
				BEGIN
					IF @Cnt1=@Cnt2 
					BEGIN
						IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
						BEGIN
							INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
							SchemeDiscount,Points,Contri,NoofTimes)
							SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
							0 as SchemeAmount,
							((A.Grossvalue*A.Discper)/100)*@NoOfTimes as SchemeDiscount,
							0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
							FROM @TempSch1 A 
							INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
							AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
							WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
						END
						ELSE
						BEGIN
							INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
							SchemeDiscount,Points,Contri,NoofTimes)
							SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
							0 as SchemeAmount,
							(C.DiscountPerAmount-C.ReturnDiscountPerAmount)-(((A.Grossvalue*A.Discper)/100)*@NoOfTimes) as SchemeDiscount,
							0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
							FROM @TempSch1 A 
							INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
							AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
							WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
						END
					END
					ELSE
					BEGIN
						IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
						BEGIN
							INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
							SchemeDiscount,Points,Contri,NoofTimes)
							SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
							0 as SchemeAmount,0 as SchemeDiscount,
							0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
							FROM @TempSch1 A 
							INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
							AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
							WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
						END
						ELSE
						BEGIN
							SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
							FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
							A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
							WHERE A.SalId=@Pi_SalId
							INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
							SchemeDiscount,Points,Contri,NoofTimes)
							SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
							0 as SchemeAmount,
							CASE WHEN (C.DiscountPerAmount-C.ReturnDiscountPerAmount)-((A.Grossvalue*A.Discper)/100) <0 
							THEN (C.DiscountPerAmount-C.ReturnDiscountPerAmount)*@NoOfTimes
							ELSE (C.DiscountPerAmount-C.ReturnDiscountPerAmount)-(((A.Grossvalue*A.Discper)/100)*@NoOfTimes) END	as SchemeDiscount,
							0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
							FROM @TempSch1 A 
							INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
							AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
							WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
							 (SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
								(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
								((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId)B ON A.SalId=B.SalId 
							AND A.SchId=B.SchId And A.SlabId=B.SlabId INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
							WHERE (C.Grossvalue)>B.SchemeDiscount)
							BEGIN
								SET ROWCOUNT 1
								UPDATE A SET A.SchemeDiscount=A.SchemeDiscount+B.SchemeDiscount
								FROM @TempSch2 A
								INNER JOIN 
								(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
								(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
								((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId) B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId 
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId 
								WHERE (C.Grossvalue)>B.SchemeDiscount
								SET ROWCOUNT 0
							END
							ELSE
							BEGIN							
								INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
								SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
								SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
								(C.DiscountPerAmount-C.ReturnDiscountPerAmount) - (A.SchemeDiscount*@NoOfTimes) AS SchemeDiscount,0,0,0,@Pi_UsrId,@Pi_TransId FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,0 AS SchemeAmount,
								((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)*C.Discper)/100) As SchemeDiscount,0 As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
							END
						END
					END
				END
		
				IF @FlatAmt>0
				BEGIN
					SELECT @FlatChk1=SUM(B.BaseQty-B.ReturnedQty) FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId
					SELECT @FlatChk2=ISNULL(SUM(B.BaseQty),0) FROM @TempSch1 B WHERE SalId = @Pi_SalId AND SchId=@SchId
					IF @Cnt1=@Cnt2 
					BEGIN
						IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
						BEGIN
							IF @FlatChk1=@FlatChk2
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
								0,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
								And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId AND A.SlabId=@SlabId
								SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat1
								FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
								DELETE FROM @TempSch2 WHERE SchemeAmount<0 
								UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
								FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
								GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
								#temp_Flat1 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								(C.FlatAmount-C.ReturnFlatAmount)-((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes),
								0 as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
								And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId AND A.SlabId=@SlabId
								SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat3
								FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
								DELETE FROM @TempSch2 WHERE SchemeAmount<0 
								UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
								FROM (SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
								GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes) A INNER JOIN 
								#temp_Flat3 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
							END
						END
						ELSE
						BEGIN
							INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
							SchemeDiscount,Points,Contri,NoofTimes)
							SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
							(C.FlatAmount-C.ReturnFlatAmount)-((CAST((A.Grossvalue/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
							0 as SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
							FROM @TempSch1 A INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
							And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
							WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							SELECT SalId,SchId,SlabId,SUM(SchemeAmount) AS SchemeAmount INTO #temp_Flat2 
							FROM @TempSch2 WHERE SchemeAmount<0 GROUP BY SalId,SchId,SlabId
							DELETE FROM @TempSch2 WHERE SchemeAmount<0 
							UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
							FROM 
							(
								SELECT SalId,RowId,MAX(PrdId) AS PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes FROM @TempSch2 WHERE SchemeAmount>0
								GROUP BY SalId,RowId,PrdBatId,Schid,Slabid,SchemeAmount,SchemeDiscount,Points,Contri,NoofTimes
							) A 
							INNER JOIN #temp_Flat2 B ON A.SalId=B.SalId AND A.SchId=B.SchId And A.SlabId=B.SlabId
						END
					END
					ELSE
					BEGIN
						IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeLineWise WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
						BEGIN
							IF @FlatChk1=@FlatChk2
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount,0 as SchemeDiscount,
								0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId 
								And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
							ELSE
							BEGIN
								SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
								FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								WHERE A.SalId=@Pi_SalId
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								(C.FlatAmount-C.ReturnFlatAmount)-((CAST((((B.BaseQty-B.ReturnedQty))*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
								0 AS SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
								INNER JOIN SalesInvoiceProduct B ON 
								A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND C.RowId=B.Slno
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
								IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
								(SELECT A.SalId,A.Schid,A.SlabId,
								CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
								(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
								0 As SchemeDiscount,0 As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId 
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  

								WHERE (C.Grossvalue>B.SchemeAmount))
								BEGIN
									SET ROWCOUNT 1
									UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
									FROM @TempSch2 A INNER JOIN 
									(SELECT A.SalId,A.Schid,A.SlabId,
									CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
									AND A.SchId=B.SchId And A.SlabId=B.SlabId 
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId 
									WHERE (C.Grossvalue>B.SchemeAmount)
									SET ROWCOUNT 0
								END
								ELSE
								BEGIN
									INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
									SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
									SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
									0, CASE WHEN A.SchemeAmount<0 THEN A.SchemeAmount*-1 ELSE A.SchemeAmount END ,0,0,@Pi_UsrId,@Pi_TransId FROM
									(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
									SchemeDiscount,Points,Contri,NoOfTimes FROM
									(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
									(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
									0 As SchemeDiscount,0 As Points,
									(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
									FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
									AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
									INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
									WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
									(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
									A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
									SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
									A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
								END
							END
						END
						ELSE
						BEGIN								
							SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
							FROM SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON 
							A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
							WHERE A.SalId=@Pi_SalId 
							INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
							SchemeDiscount,Points,Contri,NoofTimes)
							SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
							(C.FlatAmount-C.ReturnFlatAmount)-((CAST((((B.BaseQty-B.ReturnedQty))*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Flatamt)*@NoofTimes) as SchemeAmount,
							0 AS SchemeDiscount,0 as Points,((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
							FROM @TempSch1 A 
							INNER JOIN SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
							AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
							INNER JOIN SalesInvoiceProduct B ON 
							A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId AND C.RowId=B.Slno
							WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
							IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
							(SELECT A.SalId,A.Schid,A.SlabId,
							CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
							(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
							SchemeDiscount,Points,Contri,NoOfTimes FROM
							(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
							(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
							0 As SchemeDiscount,0 As Points,
							(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
							FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
							AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
							INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
							WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
							(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
							A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
							SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
							A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
							AND A.SchId=B.SchId And A.SlabId=B.SlabId 
							INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
							WHERE (C.Grossvalue>B.SchemeAmount))
							BEGIN				
								SET ROWCOUNT 1					
								UPDATE A SET A.SchemeAmount=A.SchemeAmount+B.SchemeAmount
								FROM @TempSch2 A INNER JOIN 
								(SELECT A.SalId,A.Schid,A.SlabId,
								CASE WHEN SUM(A.SchemeAmount)<0 THEN SUM(A.SchemeAmount)*-1 ELSE SUM(A.SchemeAmount) END AS SchemeAmount FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
								(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
								0 As SchemeDiscount,0 As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId GROUP BY A.SalId,A.Schid,A.SlabId) B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue>B.SchemeAmount)
								SET ROWCOUNT 0
							END
							ELSE
							BEGIN
								INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
								SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
								SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
								0, CASE WHEN A.SchemeAmount<0 THEN A.SchemeAmount*-1 ELSE A.SchemeAmount END ,0,0,@Pi_UsrId,@Pi_TransId FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
								(A.FlatAmount-A.ReturnFlatAmount)-((CAST(((((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)/@SumValue)) AS NUMERIC(38,6))*C.Flatamt)*@NoofTimes) AS SchemeAmount,
								0 As SchemeDiscount,0 As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeLineWise A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId AND A.RowId=B.Slno
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeLineWise C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.RowId=C.RowId
							END
						END
					END
				END

				IF @Points>0
				BEGIN
					SELECT @FlatChk1=SUM(B.BaseQty-B.ReturnedQty) FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId
					SELECT @FlatChk2=SUM(B.BaseQty) FROM @TempSch1 B WHERE SalId = @Pi_SalId AND SchId=@SchId
					IF @Cnt1=@Cnt2 
					BEGIN
						IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeDtPoints WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
						BEGIN
							IF @FlatChk1=@FlatChk2
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount, 0 as SchemeDiscount,
								(CAST(((A.BaseQty*A.SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes as Points,
								((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
							ELSE
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount, 0 as SchemeDiscount,
								((C.Points-C.ReturnPoints)-(CAST(((A.BaseQty*A.SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
								((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
						END
						ELSE
						BEGIN
							INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
							SchemeDiscount,Points,Contri,NoofTimes)
							SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
							0 as SchemeAmount, 0 as SchemeDiscount,
							(C.Points-C.ReturnPoints)-((CAST((A.BaseQty*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
							((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
							FROM @TempSch1 A 
							INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId
							WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
						END
					END
					ELSE
					BEGIN
						IF EXISTS (SELECT SalId FROM SalesInvoiceSchemeDtPoints WHERE SalId = @Pi_SalId AND SchId = @SchId AND SlabId=@SlabId)
						BEGIN
							IF @FlatChk1=@FlatChk2
							BEGIN
								INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
								SchemeDiscount,Points,Contri,NoofTimes)
								SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
								0 as SchemeAmount, 0 as SchemeDiscount,0 as Points,
								((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
								FROM @TempSch1 A 
								INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId 
								AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId AND A.SlabId=C.SlabId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId 
							END
						END
						ELSE
						BEGIN
							
							SELECT @SumValue=SUM(((B.BaseQty-B.ReturnedQty) *B.PrdUom1SelRate)) 
							FROM SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON 
							A.SalId=B.SalId AND A.PrdId =B.PrdId AND A.PrdBatId=B.PrdBatId 
							WHERE A.SalId=@Pi_SalId 
							INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
							SchemeDiscount,Points,Contri,NoofTimes)
							SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
							0 as SchemeAmount,0 AS SchemeDiscount,
							(C.Points-C.ReturnPoints)-((CAST((A.BaseQty*A.SelRate/@SumValue) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) as Points,
							((A.Grossvalue/@SumValue)*100) as Contri,A.NoofTimes
							FROM @TempSch1 A 
							INNER JOIN SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId And A.PrdId=C.PrdId AND A.SchId=C.SchId
							AND A.PrdBatId=C.PrdBatId AND A.SchId=C.SchId WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
							IF EXISTS(SELECT A.* FROM @TempSch2 A INNER JOIN 
							(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId
							,ROUND(A.Points,0)*@NoOfTimes AS Points FROM
							(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
							SchemeDiscount,Points,Contri,NoOfTimes FROM
							(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
							0 AS SchemeAmount,0 As SchemeDiscount,
							(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
							(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
							FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
							AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
							WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
							(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
							A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
							SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
							A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId) B ON A.SalId=B.SalId 
							AND A.SchId=B.SchId And A.SlabId=B.SlabId 
							INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
							WHERE (C.Grossvalue)>B.Points)
							BEGIN			
								SET ROWCOUNT 1						
								UPDATE A SET A.Points=A.Points+B.Points
								FROM @TempSch2 A INNER JOIN 
								(SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId
								,ROUND(A.Points,0)*@NoOfTimes AS Points FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
								0 AS SchemeAmount,0 As SchemeDiscount,
								(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId) B ON A.SalId=B.SalId 
								AND A.SchId=B.SchId And A.SlabId=B.SlabId
								INNER JOIN @TempSch1 C ON A.SalId=C.SalId AND A.SchId=C.SchId And A.SlabId=C.SlabId  
								WHERE (C.Grossvalue>B.Points)
								SET ROWCOUNT 0
							END
							ELSE
							BEGIN
								INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
								SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
								SELECT A.SalId,A.Schid,A.SlabId,A.PrdId,A.PrdBatId,A.RowId,
								0,0,ROUND(A.Points,0)*@NoOfTimes,0,@Pi_UsrId,@Pi_TransId FROM
								(SELECT A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.SlabId,SchemeAmount,
								SchemeDiscount,Points,Contri,NoOfTimes FROM
								(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
								0 AS SchemeAmount,0 As SchemeDiscount,
								(A.Points-A.ReturnPoints)-((CAST((((B.BaseQty-B.ReturnedQty)*B.PrdUom1SelRate/@SumValue)) AS NUMERIC(38,6))*A.Points)*@NoOfTimes) As Points,
								(((B.BaseQty *B.PrdUom1SelRate)/@SumValue)*100) As Contri,@NoOfTimes AS NoOfTimes
								FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
								AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId
								WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A WHERE NOT EXISTS 
								(SELECT PrdId,PrdBatId,SalId,SchId,RowId FROM @TempSch2 B WHERE A.SalId=B.SalId AND 
								A.PrdBatId=B.PrdBatId AND A.PrdId=B.PrdId AND A.RowId=B.RowId AND A.SchId=B.SchId)) A INNER JOIN 
								SalesInvoiceSchemeDtPoints C ON A.SalId=C.SalId AND A.SchId=C.SchId AND 
								A.PrdId=C.PrdId AND A.PrdBatId=C.PrdBatId 
							END
						END
					END
				END
			END		
			ELSE
			BEGIN
				INSERT INTO @TempSch2 (SalId,RowId,PrdId,PrdBatId,Schid,Slabid,SchemeAmount,
				SchemeDiscount,Points,Contri,NoofTimes)
				SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
				(A.FlatAmount-A.ReturnFlatAmount)*@NoOfTimes as SchemeAmount,
				(A.DiscountPerAmount-A.ReturnDiscountPerAmount) *@NoOfTimes AS SchemeDiscount,0 as Points,100 as Contri,1
				FROM SalesInvoiceSchemeLineWise A WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
				UNION
				SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,@SlabId AS SlabId,
				0 AS SchemeAmount,0 As SchemeDiscount,(A.Points-A.ReturnPoints)*@NoOfTimes As Points,
				100 As Contri,1 AS NoOfTimes
				FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
				AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
				WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId
			
				INSERT INTO SalesReturnDbNoteAlert (SalId,SchId,SlabId,PrdId,PrdBatId,RowId,
				SchDiscAmt,SchFlatAmt,SchPoints,AlertMode,Usrid,TransId)
					SELECT SalId,Schid,Slabid,PrdId,PrdBatId,RowId,
					SchemeDiscount,SchemeAmount,Points,0,@Pi_UsrId,@Pi_TransId FROM
					(SELECT Distinct A.SalId,A.RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid,
					(A.FlatAmount-A.ReturnFlatAmount)*@NoOfTimes as SchemeAmount,
					(A.DiscountPerAmount-A.ReturnDiscountPerAmount) *@NoOfTimes AS SchemeDiscount,0 as Points,100 as Contri,1 AS NoTimes 
					FROM SalesInvoiceSchemeLineWise A WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A
					WHERE NOT EXISTS (
					SELECT PrdId,PrdBatId,SalId FROM
					(SELECT A.PrdId,A.PrdBatId,A.SalId FROM ReturnPrdHdForScheme A 
					INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
					AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
					WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId) X WHERE A.SalId=X.SalId AND 
					A.PrdId=X.PrdId AND A.PrdBatId=X.PrdBatId)
					UNION
					SELECT SalId,Schid,Slabid,PrdId,PrdBatId,RowId,
					SchemeDiscount,SchemeAmount,Points*@NoOfTimes,0,@Pi_UsrId,@Pi_TransId FROM
					(SELECT Distinct A.SalId,B.Slno AS RowId,A.PrdId,A.PrdBatId,A.Schid,A.Slabid AS SlabId,
					0 AS SchemeAmount,0 As SchemeDiscount,(A.Points-A.ReturnPoints) As Points
					FROM  SalesInvoiceSchemeDtPoints A INNER JOIN SalesInvoiceProduct B ON A.SalId=B.SalId
					AND A.PrdId=B.PrdId AND A.PrdBatId=B.PrdBatId 
					WHERE A.SalId = @Pi_SalId AND A.SchId = @SchId) A
					WHERE NOT EXISTS (
						SELECT PrdId,PrdBatId,SalId FROM
						(SELECT A.PrdId,A.PrdBatId,A.SalId FROM ReturnPrdHdForScheme A 
						INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
						AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
						WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId) X WHERE A.SalId=X.SalId AND 
						A.PrdId=X.PrdId AND A.PrdBatId=X.PrdBatId)
				END
			FETCH NEXT FROM SchemeCur INTO @schid ,@CombiSch,@QPS
		END
		CLOSE SchemeCur
		DEALLOCATE SchemeCur

		DELETE FROM SalesReturnDbNoteAlert WHERE (SchDiscAmt+SchFlatAmt+SchPoints)=0

		SELECT SalId,SchId,SlabId,SUM(CAST(SchemeAmount AS NUMERIC(18,6))) AS SchAmt,SUM(SchemeDiscount) AS SchDisc,
		SUM(Points) AS SchPoints INTO #Test1 FROM @TempSch2
		GROUP BY SalId,SchId,SlabId 

		DELETE A FROM  @TempSch2 A INNER JOIN #Test1 B ON A.SalId=B.SalId AND A.SchId=B.SchId
		AND A.SlabId=B.SlabId WHERE B.SchAmt=0 AND B.SchDisc=0 AND B.SchPoints=0

		INSERT INTO UserFetchReturnScheme(SalId,RowId,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,FreeQty,
		FreePrdId,FreePrdBatId,FreePriceId,GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,NoofTimes,Usrid,TransId)
		SELECT a.SalId,a.RowId,a.PrdId,a.PrdBatId,b.SchId,b.SlabId,b.SchemeDiscount,b.SchemeAmount,
		b.Points,0,0,0,0,0,0,0,0,b.NoofTimes,@Pi_Usrid,@Pi_TransId
		FROM ReturnPrdHdForScheme a INNER JOIN @TempSch2 b ON
		a.SalId=b.SalId AND a.PrdId = b.PrdId AND a.PrdBatId=b.PrdBatId --AND a.RowId=B.RowId
		WHERE a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId = @Pi_SalId
		ORDER BY a.RowId

		DECLARE SchUpdateCur CURSOR FOR
		SELECT DISTINCT SalId,SchId,SlabId FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		OPEN SchUpdateCur
		FETCH NEXT FROM SchUpdateCur INTO @SalId,@SchId,@SlabId
		WHILE @@fetch_status= 0
		BEGIN
		   SELECT @MaxPrdId = (SELECT MAX(a.PrdId) FROM UserFetchReturnScheme a WHERE
		   a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId=@Pi_SalId AND a.FreeQty<>0
		   AND a.SchId =@SchId AND a.SlabId = @SlabId HAVING COUNT(a.SchId) >1)
		   SELECT @PrdBatId = (SELECT DISTINCT MAX(a.PrdbatId) FROM UserFetchReturnScheme a WHERE
		   a.usrid = @Pi_Usrid AND a.TransId = @Pi_TransId AND a.SalId=@Pi_SalId AND
		   a.PrdId=@MaxPrdId)
		   UPDATE UserFetchReturnScheme SET FreeQty = 0,GiftQty=0 FROM
		   UserFetchReturnScheme a WHERE a.SalId = @Pi_SalId AND a.Usrid = @Pi_Usrid AND a.TransId = @Pi_TransId
		   AND  a.PrdBatId <> @PrdBatId AND a.SchId = @SchId AND a.SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId = 0 AND FreePrdBatId=0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId=0 AND GiftPrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId <> 0 AND FreePrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE GiftPrdId <> 0 AND GiftPrdBatId=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId <> 0 AND FreePrdBatId<>0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId=0 AND GiftPrdBatId=0 AND FreeQty=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		   DELETE FROM UserFetchReturnScheme WHERE FreePrdId = 0 AND FreePrdBatId=0 AND Flatamt =0 AND
		   DiscAmt=0 AND Points=0 AND GiftPrdId<>0 AND GiftPrdBatId<>0 AND GiftQty=0 AND SalId=@Pi_SalId
		   AND Schid = @SchId AND SlabId = @SlabId
		
		   FETCH NEXT FROM SchUpdateCur INTO @SalId,@SchId,@SlabId
		END
		CLOSE SchUpdateCur
		DEALLOCATE SchUpdateCur

		SELECT @RtrId=RtrId FROM SalesInvoice WHERE SalId=@SalId
		SELECT @RefCode=ISNULL(PrimaryRefCode,'XX') FROM SalesInvoice WHERE SalId=@SalId
		IF @RefCode <> 'XX'
		BEGIN
			SELECT DISTINCT PrdId,PrdBatId,SchId AS SchId ,SlabId,RowId INTO #TmpPrdDt 
			FROM UserFetchReturnScheme WHERE DiscAmt > 0
			UPDATE UserFetchReturnScheme SET DiscAmt = CASE WHEN (DiscAmt - tmp.Prim)>0 THEN (DiscAmt - tmp.Prim) ELSE 0 END FROM
			(SELECT F.SchId,F.SlabId,B.PrdId,B.PrdBatId,B.RowID,B.GrossAmount - (B.GrossAmount /(1 +( CASE dbo.Fn_ReturnPrimarySchRetCategory(@RtrId,@SalId)
			WHEN 1 THEN   D.PrdBatDetailValue ELSE 0 END)/100)) AS Prim FROM BilledPrdHdForScheme B INNER JOIN ProductBatchDetails D ON D.PrdBatId = B.PrdBatId  AND D.DefaultPrice=1
			INNER JOIN BatchCreation E ON D.BatchSeqId = E.BatchSeqId AND E.Slno = D.Slno AND E.RefCode = @RefCode
			INNER JOIN #TmpPrdDt F ON B.PrdId=F.PrdId AND F.PrdBatId=B.PrdBatId AND B.RowId=F.RowId
			WHERE B.usrid = @Pi_Usrid And B.transid = @Pi_TransId) tmp,UserFetchReturnScheme A
			WHERE A.usrid = @Pi_Usrid And A.transid = @Pi_TransId AND A.SchId=tmp.schId AND A.SlabId=tmp.SlabId
			AND A.PrdId=tmp.PrdId AND A.PrdBatId=tmp.PrdBatId AND A.RowId=tmp.RowId AND A.DiscAmt >0
		END

		SELECT DISTINCT * INTO #UserFetchReturnScheme FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		DELETE FROM UserFetchReturnScheme WHERE Usrid=@Pi_Usrid AND TransId=@Pi_TransId
		INSERT INTO UserFetchReturnScheme SELECT  * FROM #UserFetchReturnScheme
		DECLARE SchemeFreeCur CURSOR FOR
		SELECT DISTINCT a.SchId FROM BillAppliedSchemeHd a WHERE a.TransId=@Pi_TransId AND a.UsrId=@Pi_Usrid 
		AND (a.FreeToBeGiven + a.GiftToBeGiven+a.FlxFreePrd+a.FlxGiftPrd)>0 AND a.IsSelected=1
		UNION 
		SELECT SchId FROM dbo.SalesInvoiceSchemeDtFreePrd WHERE SalId=@Pi_SalId
		OPEN SchemeFreeCur
		FETCH NEXT FROM SchemeFreeCur INTO @SchId
		WHILE @@fetch_status= 0
		BEGIN		
			SELECT @SchCode = SchCode,@SchType=SchType,@Combi=CombiSch,@SchemeBudget = Budget,@ProRata=ProRata,
			@FlexiSch = FlexiSch,@FlexiSchType = FlexiSchType,@PurOfEveryReq=PurofEvery FROM SchemeMaster WHERE SchId=@SchId
			DELETE FROM @TempBilled
			DELETE FROM @TempBilledAch
			SET @SlabId=0
			UPDATE A SET A.BASEQTY=(B.BaseQty-B.ReturnedQty)-A.RealQty FROM ReturnPrdHdForScheme A INNER JOIN 
			SalesInvoiceProduct B ON A.PrdId=B.PrdId AND A.PrdBatId=B.PrdbatId
			WHERE B.SalId=@Pi_SalId  AND A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId AND A.BaseQty=0
			SELECT @Cnt1=COUNT(A.PrdId) FROM ReturnPrdHdForScheme A 
			INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) c ON A.PrdId=C.PrdId 
			AND A.PrdBatId= CASE C.PrdBatId WHEN 0 THEN A.PrdBatId ELSE C.PrdBatId END 
			WHERE TransId=@Pi_TransId AND UsrId=@Pi_UsrId AND A.SalId=@Pi_SalId
			SELECT @Cnt2=COUNT(PrdId) FROM SalesInvoiceSchemeLineWise WHERE SalId=@Pi_SalId AND SchId=@SchId
			SELECT -1 As Mode,PrdId,PrdBatId,SUM(B.BaseQty-B.ReturnedQty) AS BaseQty INTO #tempBilledPrd1
			FROM SalesInvoiceProduct B WHERE SalId = @Pi_SalId GROUP BY PrdId,PrdBatId
			-- To Get the Scheme Products - Billed Qty, Billed Value, Billed Weight in KG and Litre
			INSERT INTO @TempBilled(PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKG,SchemeOnLitre,SchId)		
			SELECT A.PrdId,A.PrdBatId,CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty),0) END AS SchemeOnQty,
				CASE E.Mode 
				WHEN 0 THEN 0 ELSE ISNULL(SUM(A.BaseQty * A.SelRate),0) END AS SchemeOnAmount,
				ISNULL
				(
					(CASE D.PrdUnitId 
					WHEN 2 THEN 
						(CASE E.Mode 
						WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
					WHEN 3 THEN 
						(CASE E.Mode WHEN 0 THEN 0 ELSE (ISNULL(SUM(PrdWgt * A.BaseQty),0)) END) 
				 END),0)					
					AS SchemeOnKg,
				ISNULL
				(
					(CASE D.PrdUnitId 
						WHEN 4 THEN 
							(CASE E.Mode 
									WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0)/1000 END)
						WHEN 5 THEN 
							(CASE E.Mode WHEN 0 THEN 0 ELSE ISNULL(SUM(PrdWgt * A.BaseQty),0) END)
				 END),0) AS SchemeOnLitre,@SchId
				FROM ReturnPrdHdForScheme A INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON
				A.PrdId = B.PrdId AND A.PrdBatId = CASE B.PrdBatId WHEN 0 THEN A.PrdBatId ELSE B.PrdBatId End
				INNER JOIN Product C ON A.PrdId = C.PrdId
				INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId
				INNER JOIN #tempBilledPrd1 E ON A.PrdId=E.PrdId AND A.PrdbatId=E.PrdBatId
				WHERE A.Usrid = @Pi_UsrId AND A.TransId = @Pi_TransId 
				GROUP BY A.PrdId,A.PrdBatId,D.PrdUnitId	,E.Mode	
			UNION
				SELECT PrdId,PrdBatId,SchemeOnQty,SchemeOnAmount,SchemeOnKg,SchemeOnLitre,SchId FROM 
				(SELECT DISTINCT E.PrdId,E.PrdBatId,ISNULL(SUM(E.BaseQty-E.ReturnedQty),0) AS SchemeOnQty,
					ISNULL(SUM(E.BaseQty * E.PrdUnitSelRate),0) AS SchemeOnAmount,
					ISNULL(CASE D.PrdUnitId WHEN 2 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 3 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnKg,
					ISNULL(CASE D.PrdUnitId WHEN 4 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0)/1000
					WHEN 5 THEN ISNULL(SUM(PrdWgt * E.BaseQty-E.ReturnedQty),0) END,0) AS SchemeOnLitre,@SchId As SchId
					FROM SalesInvoiceProduct E INNER JOIN Fn_ReturnSchemeProductBatch(@SchId) B ON B.PrdId=E.PrdId AND E.SalId=@Pi_SalId
					AND E.PrdBatId = CASE B.PrdBatId WHEN 0 THEN E.PrdBatId ELSE B.PrdBatId End
					INNER JOIN Product C ON E.PrdId = C.PrdId
					INNER JOIN ProductUnit D ON C.PrdUnitId = D.PrdUnitId 
					GROUP BY E.PrdId,E.PrdBatId,D.PrdUnitId) A WHERE NOT EXISTS (SELECT PrdId,PrdBatId FROM ReturnPrdHdForScheme B
					WHERE A.PrdId=B.Prdid AND A.PrdbatId=B.PrdBatId)
			--To Get the Sum of Quantity, Value or Weight Billed for the Scheme In From and To Uom Conversion - Slab Wise
			INSERT INTO @TempBilledAch(FrmSchAch,FrmUomAch,ToSchAch,ToUomAch,SlabId,FromQty,UomId,ToQty,ToUomId)
			SELECT ISNULL(CASE @SchType
				WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6)))
			-- 	WHEN 1 THEN SUM(CAST(ISNULL(D.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
				WHEN 2 THEN SUM(SchemeOnAmount)
				WHEN 3 THEN (CASE A.UomId
						WHEN 2 THEN SUM(SchemeOnKg) * 1000
						WHEN 3 THEN SUM(SchemeOnKg)
						WHEN 4 THEN SUM(SchemeOnLitre) * 1000
						WHEN 5 THEN SUM(SchemeOnLitre)	END)
					END,0) AS FrmSchAch,A.UomId AS FrmUomAch,
				ISNULL(CASE @SchType
				WHEN 1 THEN SUM(SchemeOnQty / CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6)))
			-- 	WHEN 1 THEN SUM(CAST(ISNULL(E.ConversionFactor,1) AS NUMERIC(38,6))/SchemeOnQty)
				WHEN 2 THEN SUM(SchemeOnAmount)
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
				SELECT @SlabId = SlabId FROM (SELECT TOP 1 A.SlabId FROM @TempBilledAch A
					INNER JOIN @TempBilledAch B ON A.SlabId = B.SlabId
					WHERE
				A.FrmSchAch >= B.FromQty AND
				A.ToSchAch <= (CASE B.ToQty WHEN 0 THEN A.ToSchAch ELSE B.ToQty END)
					ORDER BY A.SlabId DESC) As SlabId
				SET @SlabId= ISNULL(@SlabId,0)
				--Store the Slab Amount Details into a temp table
				INSERT INTO @TempSchSlabAmt (ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,
					FlxFreePrd,FlxGiftPrd,FlxPoints)
				SELECT ForEveryQty,ForEveryUomId,DiscPer,FlatAmt,Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints
					FROM SchemeSlabs WHERE Schid = @SchId And SlabId = @SlabId
				--Store the Slab Free Product Details into a temp table
				INSERT INTO @TempSchSlabFree(ForEveryQty,ForEveryUomId,FreePrdId,FreeQty)
				SELECT A.ForEveryQty,A.ForEveryUomId,B.PrdId,B.FreeQty From
					SchemeSlabs A INNER JOIN SchemeSlabFrePrds B ON A.Schid = B.Schid
					AND A.SlabId = B.SlabId INNER JOIN Product C ON B.PrdId = C.PrdId
					WHERE A.Schid = @SchId And A.SlabId = @SlabId AND C.PrdType <> 4
				--To Get the Number of Times the Scheme should apply
				IF @PurOfEveryReq = 0
				BEGIN
					SET @NoOfTimes = 1
				END
				ELSE
				BEGIN
					SELECT @NoOfTimes = A.FrmSchAch / (CASE B.ForEveryQty WHEN 0 THEN 1 ELSE B.ForEveryQty END) FROM
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
				IF @SlabId>0
				BEGIN
				DELETE FROM BillAppliedSchemeHd WHERE TransId=@Pi_TransId AND UsrId=@Pi_Usrid  AND SchId=@SchId
				INSERT INTO BillAppliedSchemeHd(SchId,SchCode,FlexiSch,FlexiSchType,SlabId,SchemeAmount,SchemeDiscount,
				Points,FlxDisc,FlxValueDisc,FlxFreePrd,FlxGiftPrd,FlxPoints,FreePrdId,
				FreePrdBatId,FreeToBeGiven,GiftPrdId,GiftPrdBatId,GiftToBeGiven,NoOfTimes,IsSelected,SchBudget,
				BudgetUtilized,TransId,Usrid,PrdId,PrdBatId,SchType)
				SELECT DISTINCT @SchId as Schid,@SchCode as SchCode,@FlexiSch as FlexiSch,@FlexiSchType as FlexiSchType,
					@SlabId as SlabId,0 as SchAmount,0 as SchDisc,0 as Points,0 as FlxDisc,0 as FlxValueDisc,
					0 as FlxFreePrd,0 as FlxGiftPrd,0 as FlxPoints,FreePrdId,0 as FreePrdBatId,
					CASE @SchType 
						WHEN 1 THEN 
							CASE  WHEN SUM(SchemeOnQty)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END 
						WHEN 2 THEN 
							CASE  WHEN SUM(SchemeOnAmount)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END
						WHEN 3 THEN
							CASE  WHEN SUM(SchemeOnKG+SchemeOnLitre)>=ForEveryQty THEN (CASE @ProRata WHEN 2 THEN FreeQty*FLOOR(@NoOfTimes) ELSE ROUND((FreeQty*@NoOfTimes),0) END) ELSE FreeQty END
					END
					 as FreeToBeGiven,0 as GiftPrdId,0 as GiftPrdBatId,
					0 as GiftToBeGiven,@NoOfTimes as NoOfTimes,1 as IsSelected,@SchemeBudget as SchBudget,
					0 as BudgetUtilized,@Pi_TransId,@Pi_UsrId as UsrId,MAX(PrdId) AS PrdId,MAX(PrdBatId) AS PrdBatId,0
					FROM @TempBilled , @TempSchSlabFree
					GROUP BY FreePrdId,FreeQty,ForEveryQty
					SELECT @RowId=MIN(RowId)  FROM ReturnPrdHdForScheme WHERE  
					TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId
					INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
					GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
					SELECT DISTINCT @Pi_SalId,@SchId,@SlabId,(E.FreeQty-E.ReturnFreeQty)-B.FreeToBeGiven AS FreeQty,
					E.FreePrdId,E.FreePrdBatId,E.FreePriceId AS FreePriceId,
					0 AS GiftQty,0,0,0 AS GiftPriceId,
					B.PrdId,B.PrdBatId,@RowId AS RowId FROM	BillAppliedSchemeHd B 
					INNER JOIN SalesInvoiceSchemeDtFreePrd E ON  B.SchId=E.SchId AND B.FreePrdId=E.FreePrdId
					WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId
					AND B.IsSelected=1 AND E.SalId=@Pi_SalId
				END
				ELSE IF @SlabId=0
				BEGIN
					IF EXISTS (SELECT * FROM BillAppliedSchemeHd B WHERE B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid 
							AND (B.FreeToBeGiven + B.GiftToBeGiven+B.FlxFreePrd+B.FlxGiftPrd)>0 AND B.IsSelected=1 AND SchId=@SchId )
					BEGIN
						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
						SELECT @Pi_SalId,@SchId,B.SlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,FreePriceId AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,B.PrdId,B.PrdBatId,C.RowId FROM	BillAppliedSchemeHd B 
						INNER JOIN SalesInvoiceSchemeDtFreePrd E ON B.SchId=E.SchId AND B.SlabId=E.SlabId
						INNER JOIN @ReturnPrdHdForScheme C ON B.PrdId=C.PrdId AND B.PrdbatId=C.PrdbatId
						WHERE  B.TransId=@Pi_TransId AND B.UsrId=@Pi_Usrid AND B.SchId=@SchId 
						AND B.IsSelected=1 AND E.SalId=@Pi_SalId
					END
					ELSE
					BEGIN
						SELECT @RowId=MIN(RowId)  FROM ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId
						SELECT @PrdBatId=(PrdBatId),@PrdId=PrdId FROM ReturnPrdHdForScheme WHERE  
						TransId=@Pi_TransId AND UsrId=@Pi_Usrid AND SalId=@Pi_SalId AND RowId=@RowId
						INSERT INTO @FreePrdDt (SalId,SchId,SlabId,FreeQty,FreePrdId,FreePrdBatId,FreePriceId,
						GiftQty,GiftPrdId,GiftPrdBatId,GiftPriceId,PrdId,PrdBatId,RowId)
						SELECT @Pi_SalId,@SchId,E.SlabId,(E.FreeQty-E.ReturnFreeQty) AS FreeQty,
						E.FreePrdId,E.FreePrdBatId,0 AS FreePriceId,
						0 AS GiftQty,0,0,0 AS GiftPriceId,@PrdId,@PrdBatId,@RowId FROM	
						SalesInvoiceSchemeDtFreePrd E WHERE E.SchId=@SchId AND E.SalId=@Pi_SalId
					END
				END
			FETCH NEXT FROM SchemeFreeCur INTO @schid
		END
		CLOSE SchemeFreeCur
		DEALLOCATE SchemeFreeCur	

		IF EXISTS(SELECT * FROM @FreePrdDt)
		BEGIN
			IF EXISTS (SELECT * FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
				FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId)
				SELECT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,
				FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
				RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 
				WHERE SchId NOT IN (SELECT SchId FROM UserFetchReturnScheme WHERE SalID=@Pi_SalId AND TransId=@Pi_TransId AND UsrId=@Pi_Usrid)
			END
			ELSE
			BEGIN
				INSERT INTO UserFetchReturnScheme (SalID,PrdId,PrdBatId,SchId,SlabId,Discamt,Flatamt,Points,
				FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,NoofTimes,Usrid,TransId,RowId,FreePriceId,GiftPriceId)
				SELECT SalId,PrdId,PrdBatId,SchId,SlabId,0,0,0,FreeQty,FreePrdId,FreePrdBatId,GiftQty,GiftPrdId,GiftPrdBatId,0,@Pi_Usrid,@Pi_TransId,
				RowId,FreePriceId,GiftPriceId FROM @FreePrdDt 						
			END
			UPDATE A Set FreeQty=B.FreeQty ,FreePrdId=B.FreePrdId ,FreePrdBatId=B.FreePrdBatId,
			GiftQty=B.GiftQty ,GiftPrdId=B.GiftPrdId,GiftPrdBatId=B.GiftPrdBatId,
			FreePriceId=B.FreePriceId ,GiftPriceId=B.GiftPriceId FROM UserFetchReturnScheme A
			INNER JOIN @FreePrdDt B ON A.SalId=B.SalId AND A.SchId=B.SchId AND A.SlabId=B.SlabId AND A.RowId=B.RowId
			AND A.FreePrdId=B.FreePrdId
			WHERE A.SalId=@Pi_SalId

			DELETE FROM UserFetchReturnScheme WHERE DiscAmt+FlatAmt+Points+FreeQty+GiftQty=0
		END	
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if not exists (select * from hotfixlog where fixid = 355)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(355,'D','2010-12-31',getdate(),1,'Core Stocky Service Pack 355')
