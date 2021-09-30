--[Stocky HotFix Version]=347
Delete from Versioncontrol where Hotfixid='347'
INSERT INTO VersionControl(HotFixId,VersionNo,FixType,FixedOn,HotFixReleasedOn,VersionReleasedOn,ReplacedOn,ChangesDone) 
values('347','2.0.0.5','D','2010-11-10','2010-11-10','2010-11-10',convert(varchar(11),getdate()),'Parle 1st Phase;Major:Bug Fixings;Minor:')
GO

DELETE FROM APPTITLE
INSERT INTO AppTitle SELECT 'CoreStocky 347' ,'347'
GO

--SRF-Nanda-166-001

EXEC master.dbo.sp_configure 'show advanced options', 1

RECONFIGURE

EXEC master.dbo.sp_configure 'xp_cmdshell', 1

RECONFIGURE

--SRF-Nanda-166-002

if exists (select * from dbo.sysobjects where id = object_id(N'[Cs2Cn_Prk_Retailer_Archive]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [Cs2Cn_Prk_Retailer_Archive]
GO

CREATE TABLE [dbo].[Cs2Cn_Prk_Retailer_Archive]
(
	[SlNo] [numeric](38, 0) NOT NULL,
	[DistCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrId] [int] NULL,
	[RtrCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CmpRtrCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrAddress1] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrAddress2] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrAddress3] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrPINCode] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrChannelCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrGroupCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrClassCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KeyAccount] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RelationStatus] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RtrRegDate] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevel] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeoLevelValue] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VillageId] [int] NULL,
	[VillageCode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VillageName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [tinyint] NULL,
	[Mode] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadFlag] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UploadedDate] [datetime] NULL
) ON [PRIMARY]
GO

--SRF-Nanda-166-003

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cn2Cs_ClusterMaster]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cn2Cs_ClusterMaster]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
BEGIN TRANSACTION
EXEC Proc_Cn2Cs_ClusterMaster 0
SELECT * FROM Cn2Cs_Prk_ClusterMaster
SELECT * FROM errorlog
ROLLBACK TRANSACTION
*/
CREATE      PROCEDURE [dbo].[Proc_Cn2Cs_ClusterMaster]
(
	@Po_ErrNo INT OUTPUT
)
AS
/*********************************
* PROCEDURE		: Proc_Cn2Cs_ClusterMaster
* PURPOSE		: To validate the downloaded Cluster details from Console
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
	DECLARE @ClusterCode 	NVARCHAR(50)
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
	DECLARE @Value			NUMERIC(38,6)
	DECLARE @PrdCtgLevelCode	NVARCHAR(100)
	DECLARE @CmpPrdCtgId  	INT

	SET @TabName = 'Cn2Cs_Prk_ClusterMaster'
	SET @Po_ErrNo=0
	IF EXISTS (SELECT * FROM DBO.SysObjects WHERE ID = OBJECT_ID(N'ClsToAvoid')
	AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
	BEGIN
		DROP TABLE ClsToAvoid	
	END
	CREATE TABLE ClsToAvoid
	(
		ClusterCode NVARCHAR(50)
	)
	IF EXISTS(SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
	WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))='')
	BEGIN
		INSERT INTO ClsToAvoid(ClusterCode)
		SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
		WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))=''
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Master','ClusterCode','Cluster Code/Name Should not be empty' FROM Cn2Cs_Prk_ClusterMaster
		WHERE LTRIM(RTRIM(ISNULL(ClusterCode,'')))='' OR LTRIM(RTRIM(ISNULL(ClusterName,'')))=''
	END		
	IF EXISTS(SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
	WHERE PrdCtgLevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel WHERE LevelName<>'Level1') AND AddMast1='Yes')
	BEGIN
		INSERT INTO ClsToAvoid(ClusterCode)
		SELECT DISTINCT ClusterCode FROM Cn2Cs_Prk_ClusterMaster
		WHERE PrdCtgLevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel WHERE LevelName<>'Level1') AND AddMast1='Yes'
		INSERT INTO ErrorLog(SlNo,TableName,FieldName,ErrDesc)
		SELECT DISTINCT 1,'Cluster Master','ClusterCode','Product Category Level:'+PrdCtgLevelCode+' not found' FROM Cn2Cs_Prk_ClusterMaster
		WHERE PrdCtgLevelCode NOT IN (SELECT CmpPrdCtgName FROM ProductCategoryLevel WHERE LevelName<>'Level1') AND AddMast1='Yes'
	END
	
	DECLARE Cur_ClusterMaster CURSOR
	FOR SELECT ISNULL(LTRIM(RTRIM([ClusterCode])),''),ISNULL(LTRIM(RTRIM([ClusterName])),''),ISNULL(LTRIM(RTRIM([Remarks])),''),
	ISNULL(LTRIM(RTRIM([Salesman])),'No'),ISNULL(LTRIM(RTRIM([Retailer])),'No'),ISNULL(LTRIM(RTRIM([AddMast1])),'No'),
	ISNULL(LTRIM(RTRIM([AddMast2])),'No'),ISNULL(LTRIM(RTRIM([AddMast3])),'No'),ISNULL(LTRIM(RTRIM([AddMast4])),'No'),
	ISNULL(LTRIM(RTRIM([AddMast5])),'No'),ISNULL([Value],0),ISNULL(LTRIM(RTRIM(PrdCtgLevelCode)),'')
	FROM Cn2Cs_Prk_ClusterMaster WHERE [DownLoadFlag] ='D' AND
	ClusterCode NOT IN (SELECT ClusterCode FROM ClsToAvoid)
	OPEN Cur_ClusterMaster
	FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,
	@AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5,@Value,@PrdCtgLevelCode
	WHILE @@FETCH_STATUS=0
	BEGIN		
		SET @Po_ErrNo=0
		SET @Exist=0
		IF @AddMast1='Yes'
		BEGIN
			SELECT @CmpPrdCtgId=CmpPrdCtgId FROM ProductCategoryLevel WHERE CmpPrdCtgName=@PrdCtgLevelCode
		END
		ELSE
		BEGIN
			SET @CmpPrdCtgId=0
		END
		IF NOT EXISTS (SELECT * FROM ClusterMaster WHERE ClusterCode=@ClusterCode)
		BEGIN			
			SET @ClusterId = dbo.Fn_GetPrimaryKeyInteger('ClusterMaster','ClusterId',CAST(YEAR(GETDATE()) AS INT),MONTH(GETDATE()))
			SET @Exist=0			
			IF @ClusterId<=(SELECT ISNULL(MAX(ClusterId),0) AS ClusterId FROM ClusterMaster)
			BEGIN
				SELECT @ClusterId
				SET @ErrDesc = 'Reset the counters/Check the system date'
				INSERT INTO Errorlog VALUES (67,@TabName,'ClusterId',@ErrDesc)
				SET @Po_ErrNo =1
			END
		END
		ELSE
		BEGIN
			SELECT @ClusterId=ClusterId FROM ClusterMaster WHERE ClusterCode=@ClusterCode			
			SET @Exist=1
		END		
		
		IF @Exist=1
		BEGIN
			EXEC Proc_DependencyCheck 'ClusterMaster',@ClusterId
			IF (SELECT COUNT(*) FROM TempDepCheck)>0
			BEGIN
				SET @Exist=2
			END			
		END
		IF @Po_ErrNo=0
		BEGIN
			IF @Exist=0
			BEGIN
				INSERT INTO ClusterMaster(ClusterId,ClusterCode,ClusterName,Remarks,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,ClusterValues)			
				VALUES(@ClusterId,@ClusterCode,@ClusterName,@Remarks,1,1,1,GETDATE(),1,GETDATE(),@Value)
			
				UPDATE Counters SET CurrValue=CurrValue+1 WHERE TabName='ClusterMaster' AND FldName='ClusterId'	
				DELETE FROM ClusterDetails WHERE ClusterId=@ClusterId
				
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),0
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,79,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),0
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,91,'Product',(CASE @AddMast1 WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),@CmpPrdCtgId
			END		
			ELSE IF @Exist=1
			BEGIN
				UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks
				WHERE ClusterId=@ClusterId			
				
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,68,'Salesman',(CASE @Salesman WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),0
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,79,'Retailer',(CASE @Retailer WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),0
				INSERT INTO ClusterDetails(ClusterId,MasterId,MasterName,Status,
				Availability,LastModBy,LastModDate,AuthId,AuthDate,DetailsId)
				SELECT @ClusterId,91,'Product',(CASE @AddMast1 WHEN 'Yes' THEN 1 ELSE 0 END),
				1,1,GETDATE(),1,GETDATE(),@CmpPrdCtgId
			END
			ELSE IF @Exist=2
			BEGIN
				UPDATE ClusterMaster SET ClusterName=@ClusterName,Remarks=@Remarks
				WHERE ClusterId=@ClusterId			
			END
		END
		FETCH NEXT FROM Cur_ClusterMaster INTO @ClusterCode,@ClusterName,@Remarks,@Salesman,@Retailer,
		@AddMast1,@AddMast2,@AddMast3,@AddMast4,@AddMast5,@Value,@PrdCtgLevelCode
	END
	CLOSE Cur_ClusterMaster
	DEALLOCATE Cur_ClusterMaster
	UPDATE Cn2Cs_Prk_ClusterMaster SET DownLoadFlag='Y' WHERE
	DownLoadFlag ='D' AND ClusterCode IN (SELECT ClusterCode FROM ClusterMaster)
	AND CLusterCode NOT IN (SELECT ClusterCode FROM ClsToAvoid)
	RETURN
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-166-004

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
			SELECT @ClusterId=ClusterId FROM ClusterMaster WHERE ClusterCode=@ClusterCode			
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

--SRF-Nanda-166-005

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_ClusterAssign]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_ClusterAssign]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
BEGIN TRANSACTION
EXEC Proc_Cs2Cn_ClusterAssign 0
SELECT * FROM Cs2Cn_Prk_ClusterAssign ORDER BY SlNo
SELECT * FROM ClusterAssign WHERE MasterId=79
ROLLBACK TRANSACTION
*/

CREATE   PROCEDURE [dbo].[Proc_Cs2Cn_ClusterAssign]
(
	@Po_ErrNo	INT OUTPUT
)
AS
SET NOCOUNT ON
BEGIN
/*********************************
* PROCEDURE		: Proc_Cs2Cn_ClusterAssign
* PURPOSE		: To Extract Cluster Assign Details from CoreStocky to upload to Console
* CREATED		: Nandakumar R.G
* CREATED DATE	: 18/10/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
* {date} {developer}  {brief modification description}
	
*********************************/
	DECLARE @DistCode	As nVarchar(50)
	
	SET @Po_ErrNo=0
	DELETE FROM Cs2Cn_Prk_ClusterAssign WHERE UploadFlag = 'Y'
	
	SELECT @DistCode = DistributorCode FROM Distributor
	INSERT INTO Cs2Cn_Prk_ClusterAssign
	(
		DistCode,
		ClusterId,
		ClusterCode,
		ClusterName,
		ClsGroupId,
		ClsGroupCode,
		ClsGroupName,
		ClsCategory,
		MasterId,
		MasterCmpCode,
		MasterDistCode,
		MasterName,
		AssignDate,
		UploadFlag
	)
	SELECT @DistCode,CA.ClusterId,CM.ClusterCode,CM.ClusterName,CGM.ClsGroupId,CGM.ClsGroupCode,CGM.ClsGroupName,
	CS.TransName,CA.MasterRecordId,R.CmpRtrCode,R.RtrCode,R.RtrName,CA.AssignDate,'N'
	FROM ClusterAssign CA,ClusterMaster CM,ClusterScreens CS,
	ClusterGroupMaster CGM,ClusterGroupDetails CGD,Retailer R
	WHERE CA.ClusterId=CM.ClusterId AND CA.MasterId=CS.TransID AND CGM.ClsGroupId=CGD.ClsGroupId AND
	CGD.ClusterId=CM.ClusterId AND CGD.ClusterId=CA.ClusterId AND CA.MasterId=79 AND CA.MasterRecordId=R.RtrId AND CA.Upload=0

	UPDATE ClusterAssign SET Upload=1
	WHERE ClusterId IN (SELECT ClusterId FROM Cs2Cn_Prk_ClusterAssign)
	AND MasterId=79 AND Upload=0
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-166-006

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Proc_Cs2Cn_UploadArchiving]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Proc_Cs2Cn_UploadArchiving]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--EXEC Proc_Cs2Cn_UploadArchiving 0
CREATE PROCEDURE [dbo].[Proc_Cs2Cn_UploadArchiving]
(
	@PO_ErrNo INT Output
)
AS
/*********************************
* PROCEDURE	: Proc_Cs2Cn_UploadArchiving
* PURPOSE	: To Archive the uploaded data
* NOTES		:
* CREATED	: Nandakumar R.G
* DATE		: 03/02/2010
* MODIFIED
* DATE      AUTHOR     DESCRIPTION
------------------------------------------------
*
*********************************/
BEGIN
SET NOCOUNT ON
	DECLARE @SeqNo INT
	DECLARE @PrkTable VARCHAR(200)
	DECLARE @StrQry VARCHAR(8000)
	SET @PO_ErrNo=0
	SET @PrkTable = ''
	SET @StrQry = ''
	SELECT @SeqNo = MAX(SequenceNo) FROM Tbl_UploadIntegration
	WHILE (@SeqNo > 0)
	BEGIN
		SELECT  @PrkTable  = ISNULL(PrkTableName,'') FROM Tbl_UploadIntegration WHERE SequenceNo =  @SeqNo
		IF @PrkTable<>''
		BEGIN
			IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'['+@PrkTable+'_Archive'+']') AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
			BEGIN
				
				SET @StrQry = 'DELETE FROM '+@PrkTable+'_Archive WHERE UploadedDate<='''+ CONVERT(NVARCHAR(10),DATEADD(DAY,-365,GETDATE()),121) + ''''				
				EXEC(@StrQry)		

				
				SET @StrQry = 'INSERT INTO '+@PrkTable+'_Archive SELECT *,GETDATE() FROM ' + @PrkTable + ' WHERE UploadFlag = ''Y'''
				SELECT @StrQry
				EXEC(@StrQry)		
				
			END
		END
		SET @SeqNo = @SeqNo - 1
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

--SRF-Nanda-166-007

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

--INSERT INTO Tbl_UploadIntegration (SequenceNo,ProcessName,FolderName,PrkTableName,CreatedDate) 
--VALUES (26,'Purchase Order','Purchase_Order','Cs2Cn_Prk_PurchaseOrder',GETDATE())

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

--INSERT INTO Tbl_DownloadIntegration (SequenceNo,ProcessName,PrkTableName,SPName,TRowCount,SelectCount,CreatedDate) 
--VALUES (22,'Purchase Receipt Mapping','Cn2Cs_Prk_PurchaseReceiptMapping','Proc_Import_PurchaseReceiptMapping',0,500,GETDATE())

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
VALUES (29,'Claim Settlement','Cn2Cs_Prk_ClaimSettlement','Proc_Import_ClaimSettlement',0,500,GETDATE())

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
VALUES (108,1,'Scheme Utilization','Scheme Utilization','Proc_Cs2Cn_SchemeUtilization','Proc_Import_SchemeUtilization','Cs2Cn_Prk_SchemeUtilization','Proc_Cn2Cs_SchemeUtilization','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (109,1,'Sample Issue','Sample Issue','Proc_Cs2Cn_SampleIssue','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleIssue','Proc_ValidateSampleIssue','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (110,1,'Sample Receipt','Sample Receipt','Proc_Cs2Cn_SampleReturn','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleReceipt','Proc_ValidateSampleIssue','Transaction','Upload',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (111,1,'Sample Return','Sample Return','Proc_Cs2Cn_SampleReturn','Proc_ImportSampleIssue','Cs2Cn_Prk_SampleReturn','Proc_ValidateSampleIssue','Transaction','Upload',1)

--INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
--VALUES (112,1,'Purchase Order','Purchase Order','Proc_Cs2Cn_PurchaseOrder','Proc_Import_PurchaseOrder','Cs2Cn_Prk_PurchaseOrder','Proc_Cn2Cs_PurchaseOrder','Transaction','Upload',1)

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
VALUES (215,1,'Scheme','Scheme Master','Proc_CS2CNBLSchemeMaster','Proc_ImportBLSchemeMaster','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeMaster','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (215,2,'Scheme','Scheme Attributes','Proc_CS2CNBLSchemeAttributes','Proc_ImportBLSchemeAttributes','Etl_Prk_Scheme_OnAttributes','Proc_CN2CS_BLSchemeAttributes','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (215,3,'Scheme','Scheme Products','Proc_CS2CNBLSchemeProducts','Proc_ImportBLSchemeProducts','Etl_Prk_SchemeProducts_Combi','Proc_CN2CS_BLSchemeProducts','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (215,4,'Scheme','Scheme Slabs','Proc_CS2CNBLSchemeSlab','Proc_ImportBLSchemeSlab','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeSlab','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (215,5,'Scheme','Scheme Rule Setting','Proc_CS2CNBLSchemeRulesetting','Proc_ImportBLSchemeRulesetting','Etl_Prk_SchemeHD_Slabs_Rules','Proc_CN2CS_BLSchemeRulesetting','Transaction','Download',0)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (215,6,'Scheme','Scheme Free Products','Proc_CS2CNBLSchemeFreeProducts','Proc_ImportBLSchemeFreeProducts','Etl_Prk_Scheme_Free_Multi_Products','Proc_CN2CS_BLSchemeFreeProducts','Transaction','Download',0)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (215,7,'Scheme','Scheme Combi Products','Proc_CS2CNBLSchemeCombiPrd','Proc_ImportBLSchemeCombiPrd','Etl_Prk_SchemeProducts_Combi','Proc_CN2CS_BLSchemeCombiPrd','Transaction','Download',0)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (215,8,'Scheme','Scheme On Another Product','Proc_CS2CNBLSchemeOnAnotherPrd','Proc_ImportBLSchemeOnAnotherPrd','Etl_Prk_Scheme_OnAnotherPrd','Proc_CN2CS_BLSchemeOnAnotherPrd','Transaction','Download',0)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (216,1,'Purchase Receipt','Purchase Receipt','Proc_Cs2Cn_PurchaseReceipt','Proc_ImportBLPurchaseReceipt','Cn2Cs_Prk_BLPurchaseReceipt','Proc_Cn2Cs_PurchaseReceipt','Transaction','Download',1)

--INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
--VALUES (217,1,'Purchase Receipt Mapping','Purchase Receipt Mapping','Proc_Cs2Cn_PurchaseReceiptMapping','Proc_Import_PurchaseReceiptMapping','Cn2Cs_Prk_PurchaseReceiptMapping','Proc_Cn2Cs_PurchaseReceiptMapping','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (218,1,'Scheme Master Control','Scheme Master Control','Proc_CS2CNNVSchemeMasterControl','Proc_ImportNVSchemeMasterControl','Cn2Cs_Prk_NVSchemeMasterControl','Proc_Cn2Cs_NVSchemeMasterControl','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (219,1,'Claim Norm Mapping','Claim Norm Mapping','Proc_Cs2Cn_ClaimNorm','Proc_Import_ClaimNorm','Cn2Cs_Prk_ClaimNorm','Proc_Cn2Cs_ClaimNorm','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (220,1,'Reason Master','Reason Master','Proc_Cs2Cn_ReasonMaster','Proc_Import_ReasonMaster','Cn2Cs_Prk_ReasonMaster','Proc_Cn2Cs_ReasonMaster','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (221,1,'Bulletin Board','BulletingBoard','Proc_Cs2Cn_BulletinBoard','Proc_Import_BulletinBoard','Cn2Cs_Prk_BulletinBoard','Proc_Cn2Cs_BulletinBoard','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (222,1,'ERP Product Mapping','ERP Product Mapping','Proc_Cs2Cn_ERPPrdCCodeMapping','Proc_Import_ERPPrdCCodeMapping','Cn2Cs_Prk_ERPPrdCCodeMapping','Proc_Cn2Cs_ERPPrdCCodeMapping','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (223,1,'Configuration','Configuration','Proc_Cs2Cn_Configuration','Proc_Import_Configuration','Cn2Cs_Prk_Configuration','Proc_Cn2Cs_Configuration','Master','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (224,1,'Claim Settlement','Claim Settlement','Proc_Cs2Cn_ClaimSettlement','Proc_Import_ClaimSettlement','Cn2Cs_Prk_ClaimSettlement','Proc_Cn2Cs_ClaimSettlement','Transaction','Download',1)

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (225,1,'Cluster Master','Cluster Master','Proc_Cs2Cn_ClusterMaster','Proc_Import_ClusterMaster','Cn2Cs_Prk_ClusterMaster','Proc_Cn2Cs_ClusterMaster','Master','Download',1)	

INSERT INTO CustomUpDownload (SlNo,SeqNo,Module,Screen,ExportFnName,ImportProcName,ParkTable,ValidateProcName,TranType,UpDownload,MandatoryFile) 
VALUES (226,1,'Cluster Group','Cluster Group','Proc_Cs2Cn_ClusterGroup','Proc_Import_ClusterGroup','Cn2Cs_Prk_ClusterGroup','Proc_Cn2Cs_ClusterGroup','Master','Download',1)	

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
VALUES (234,1,'ReUpload','ReUpload','Proc_Cs2Cn_ReUpload','Proc_Import_ReUpload','Cn2Cs_Prk_ReUpload','Proc_Cn2Cs_ReUpload','Transaction','Download',1)

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
VALUES (108,1,'Scheme Utilization','Scheme Utilization','Cs2Cn_Prk_SchemeUtilization','Cs2Cn_Prk_SchemeUtilization','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (109,1,'Sample Issue','Sample Issue','Cs2Cn_Prk_SampleIssue','Cs2Cn_Prk_SampleIssue','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (110,1,'Sample Receipt','Sample Receipt','Cs2Cn_Prk_SampleReceipt','Cs2Cn_Prk_SampleReceipt','','','','Upload','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (111,1,'Sample Return','Sample Return','Cs2Cn_Prk_SampleReturn','Cs2Cn_Prk_SampleReturn','','','','Upload','0',0,'0',0,0,'')

--INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
--OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
--VALUES (112,1,'Purchase Order','Purchase Order','Cs2Cn_Prk_PurchaseOrder','Cs2Cn_Prk_PurchaseOrder','','','','Upload','0',0,'0',0,0,'')

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
VALUES (215,1,'Scheme','Scheme Master','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,2,'Scheme','Scheme Attributes','Etl_Prk_Scheme_OnAttributes','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,3,'Scheme','Scheme Products','Etl_Prk_SchemeProducts_Combi','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,4,'Scheme','Scheme Slabs','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,5,'Scheme','Scheme Rule Setting','Etl_Prk_SchemeHD_Slabs_Rules','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,6,'Scheme','Scheme Free Products','Etl_Prk_Scheme_Free_Multi_Products','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,7,'Scheme','Scheme Combi Products','Etl_Prk_SchemeProducts_Combi','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (215,8,'Scheme','Scheme On Another Product','Etl_Prk_Scheme_OnAnotherPrd','SchemeMaster','SchId','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],SchDsc AS [Scheme Description] FROM SchemeMaster WHERE SchId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (216,1,'Purchase Receipt','Purchase Receipt','Cn2Cs_Prk_BLPurchaseReceipt','ETLTempPurchaseReceipt','CmpInvNo','','DownLoadStatus=0','Download','0',0,'0',0,0,'SELECT CmpInvNo AS [Invoice No],InvDate AS [Invoice Date] FROM ETLTempPurchaseReceipt WHERE DownLoadStatus=0')

--INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
--OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
--VALUES (217,1,'Purchase Receipt Mapping','Purchase Receipt Mapping','Cn2Cs_Prk_PurchaseReceiptMapping','Cn2Cs_Prk_PurchaseReceiptMapping','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (218,1,'Scheme Master Control','Scheme Master Control','Cn2Cs_Prk_NVSchemeMasterControl','Cn2Cs_Prk_NVSchemeMasterControl','DownLoadFlag','','','Download','0',0,'0',0,0,'SELECT CmpSchCode AS [Scheme Code],ChangeType AS [Change Type],Description FROM Cn2Cs_Prk_NVSchemeMasterControl WHERE DownLoadFlag=''Y''')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (219,1,'Claim Norm Mapping','Claim Norm Mapping','Cn2Cs_Prk_ClaimNorm','Cn2Cs_Prk_ClaimNorm','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (220,1,'Reason Master','Reason Master','Cn2Cs_Prk_ReasonMaster','ReasonMaster','ReasonId','','','Download','0',0,'0',0,0,'SELECT ReasonCode AS [Reason Code],Description FROM ReasonMaster WHERE ReasonId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (221,1,'Bulletin Board','BulletingBoard','Cn2Cs_Prk_BulletingBoard','Cn2Cs_Prk_BulletingBoard','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (222,1,'ERP Product Mapping','ERP Product Mapping','Cn2Cs_Prk_ERPPrdCCodeMapping','Cn2Cs_Prk_ERPPrdCCodeMapping','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (223,1,'Configuration','Configuration','Cn2Cs_Prk_Configuration','Cn2Cs_Prk_Configuration','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (224,1,'Claim Settlement','Claim Settlement','Cn2Cs_Prk_ClaimSettlement','Cn2Cs_Prk_ClaimSettlement','DownLoadFlag','','','Download','0',0,'0',0,0,'')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (225,1,'Cluster Master','Cluster Master','Cn2Cs_Prk_ClusterMaster','ClusterMaster','ClusterId','','','Download','0',0,'0',0,0,'SELECT ClusterCode AS [Cluster Code],ClusterName AS [Cluster Name] FROM ClusterMaster WHERE ClusterId>OldMax')

INSERT INTO CustomUpDownloadCount (SlNo,SeqNo,Module,Screen,ParkTable,MainTable,KeyField1,KeyField2,KeyField3,UpDownload,
OldMax,OldCount,NewMax,NewCount,DownloadedCount,SelectQuery) 
VALUES (226,1,'Cluster Group','Cluster Group','Cn2Cs_Prk_ClusterGroup','ClusterGroupMaster','ClsGroupId','','','Download','0',0,'0',0,0,'SELECT ClsGroupCode AS [Cluster Group Code],ClsGroupName AS [Cluster Group Name] FROM ClusterGroupMaster WHERE ClsGroupId>OldMax')

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
VALUES (234,1,'ReUpload','ReUpload','Cn2Cs_Prk_ReUpload','Cn2Cs_Prk_ReUpload','DownLoadFlag','','','Download','0',0,'0',0,0,'')


if not exists (select * from hotfixlog where fixid = 347)
insert into hotfixlog(fixid,fixtype,releasedon,fixedon,fixedby,errorsfixed) values
(347,'D','2010-11-10',getdate(),1,'Core Stocky Service Pack 347')